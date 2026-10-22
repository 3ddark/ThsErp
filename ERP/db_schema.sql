--
-- PostgreSQL database dump
--

\restrict FJnOQd8j0XCm8SYapnxYrFH3wAbwIHsdkhOC5PWTfyU04tfuY7Ak66qL7Oqgdog

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: audit_remote; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA audit_remote;


ALTER SCHEMA audit_remote OWNER TO postgres;

--
-- Name: SCHEMA audit_remote; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA audit_remote IS 'ths_audit (ortak işlem geçmişi) yabancı tabloları; yalnız audit_flush() yazar';


--
-- Name: dblink; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;


--
-- Name: EXTENSION dblink; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';


--
-- Name: postgres_fdw; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;


--
-- Name: EXTENSION postgres_fdw; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';


--
-- Name: audit(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.audit() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
DECLARE
    _old jsonb;
    _new jsonb;
    _row_id bigint;
BEGIN
    IF TG_OP = 'INSERT' THEN
        _new := to_jsonb(NEW);
        _row_id := NEW.id;
    ELSIF TG_OP = 'DELETE' THEN
        _old := to_jsonb(OLD);
        _row_id := OLD.id;
    ELSE
        SELECT jsonb_object_agg(n.key, o.value), jsonb_object_agg(n.key, n.value)
        INTO _old, _new
        FROM jsonb_each(to_jsonb(NEW)) n
        JOIN jsonb_each(to_jsonb(OLD)) o ON o.key = n.key
        WHERE n.value IS DISTINCT FROM o.value;

        IF _new IS NULL THEN
            RETURN NULL;   -- hiçbir kolon değişmedi
        END IF;
        _row_id := OLD.id;
    END IF;

    INSERT INTO public.audit_outbox (table_schema, table_name, row_id, action, app_user, client_addr,
                                     application_name, old_data, new_data)
    VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, _row_id, left(TG_OP, 1),
            NULLIF(current_setting('ths_erp.user_name', true), ''), inet_client_addr(),
            NULLIF(left(current_setting('application_name', true), 64), ''), _old, _new);
    RETURN NULL;
END
$$;


ALTER FUNCTION public.audit() OWNER TO postgres;

--
-- Name: audit_configure(text, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.audit_configure(p_host text, p_port integer, p_dbname text DEFAULT 'ths_audit'::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
BEGIN
    EXECUTE format('ALTER SERVER audit_server OPTIONS (SET host %L, SET port %L, SET dbname %L)',
                   p_host, p_port::text, p_dbname);
END
$$;


ALTER FUNCTION public.audit_configure(p_host text, p_port integer, p_dbname text) OWNER TO postgres;

--
-- Name: audit_flush(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.audit_flush(p_batch_size integer DEFAULT 5000, p_max_batches integer DEFAULT 20, OUT moved integer, OUT error_message text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
DECLARE
    _db     varchar := current_database();
    _family varchar := public.fn_db_family();
    _year   smallint := public.fn_active_period();
    _n      integer;
    _opts   text[];
BEGIN
    moved := 0;
    IF NOT EXISTS (SELECT 1 FROM public.audit_outbox) THEN
        RETURN;
    END IF;

    -- Yerel sunucudaki ths_audit: dump başka port'lu makineye taşındıysa port kendini düzeltir
    SELECT srvoptions INTO _opts FROM pg_foreign_server WHERE srvname = 'audit_server';
    IF ('host=localhost' = ANY(_opts) OR 'host=127.0.0.1' = ANY(_opts))
       AND NOT (('port=' || current_setting('port')) = ANY(_opts)) THEN
        EXECUTE format('ALTER SERVER audit_server OPTIONS (SET port %L)', current_setting('port'));
    END IF;

    BEGIN
        -- Kaynak kaydı + dönem bölümü (uzak tetikleyici oluşturur). Eşzamanlı ilk kayıt / dönem değişimi
        -- serileştirme hatası verirse atlanır: bölüm zaten varsa aktarım sürer, yoksa sonraki denemede açılır.
        BEGIN
            INSERT INTO audit_remote.audit_database (db_name, db_family, period_year, company_title)
            VALUES (_db, _family, _year, (SELECT company_title FROM public.sys_application_setting ORDER BY id LIMIT 1))
            ON CONFLICT DO NOTHING;
            UPDATE audit_remote.audit_database SET period_year = _year WHERE db_name = _db AND period_year <> _year;
        EXCEPTION WHEN serialization_failure OR deadlock_detected OR lock_not_available THEN
            NULL;
        END;

        FOR i IN 1 .. GREATEST(p_max_batches, 1) LOOP
            WITH batch AS (
                SELECT id FROM public.audit_outbox ORDER BY id LIMIT GREATEST(p_batch_size, 1) FOR UPDATE SKIP LOCKED
            ), taken AS (
                DELETE FROM public.audit_outbox o USING batch b WHERE o.id = b.id RETURNING o.*
            )
            INSERT INTO audit_remote.audit_log_in (period_year, db_name, db_family, source_id, table_schema, table_name,
                                                   row_id, action, changed_at, transaction_id, db_user, app_user,
                                                   client_addr, application_name, old_data, new_data)
            SELECT _year, _db, _family, t.id, t.table_schema, t.table_name, t.row_id, t.action, t.changed_at,
                   t.transaction_id, t.db_user, t.app_user, t.client_addr, t.application_name, t.old_data, t.new_data
            FROM taken t
            ORDER BY t.id
            ON CONFLICT DO NOTHING;
            GET DIAGNOSTICS _n = ROW_COUNT;
            moved := moved + _n;
            EXIT WHEN _n < GREATEST(p_batch_size, 1);
        END LOOP;

        -- İzleme sayaçları en iyi çaba (aynı satır: eşzamanlı aktarımda biri atlanabilir)
        IF moved > 0 THEN
            BEGIN
                UPDATE audit_remote.audit_database
                SET last_flush_at = now(), flushed_rows = flushed_rows + moved
                WHERE db_name = _db;
            EXCEPTION WHEN serialization_failure OR deadlock_detected OR lock_not_available THEN
                NULL;
            END;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        moved := -1;
        error_message := SQLERRM;
    END;
END
$$;


ALTER FUNCTION public.audit_flush(p_batch_size integer, p_max_batches integer, OUT moved integer, OUT error_message text) OWNER TO postgres;

--
-- Name: fn_acc_account_party(bigint); Type: FUNCTION; Schema: public; Owner: ths_admin
--

CREATE FUNCTION public.fn_acc_account_party(p_acc_account_id bigint) RETURNS TABLE(account_title character varying, taxpayer_type smallint, taxpayer_name character varying, taxpayer_name2 character varying, taxpayer_surname character varying, tax_office character varying, tax_no character varying)
    LANGUAGE sql STABLE
    AS $$
  SELECT a.name, t.taxpayer_type, t.taxpayer_name, t.taxpayer_name2, t.taxpayer_surname, t.tax_office, t.tax_no
    FROM public.acc_account a
    LEFT JOIN public.acc_account_taxpayer t ON t.acc_account_id = a.id
   WHERE a.id = p_acc_account_id
$$;


ALTER FUNCTION public.fn_acc_account_party(p_acc_account_id bigint) OWNER TO ths_admin;

--
-- Name: fn_active_period(); Type: FUNCTION; Schema: public; Owner: ths_admin
--

CREATE FUNCTION public.fn_active_period() RETURNS smallint
    LANGUAGE sql STABLE
    AS $$
    SELECT COALESCE((SELECT s.active_period FROM public.sys_application_setting s ORDER BY s.id LIMIT 1),
                    extract(year FROM current_date)::smallint)
$$;


ALTER FUNCTION public.fn_active_period() OWNER TO ths_admin;

--
-- Name: fn_db_family(); Type: FUNCTION; Schema: public; Owner: ths_admin
--

CREATE FUNCTION public.fn_db_family() RETURNS character varying
    LANGUAGE sql STABLE
    AS $_$ SELECT regexp_replace(current_database(), '_?[0-9]{4}$', '')::varchar $_$;


ALTER FUNCTION public.fn_db_family() OWNER TO ths_admin;

--
-- Name: fn_default_currency(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_default_currency() RETURNS character varying
    LANGUAGE sql STABLE
    AS $$ SELECT COALESCE((SELECT app_currency FROM public.sys_application_setting LIMIT 1), (SELECT currency FROM public.sys_currency ORDER BY id LIMIT 1)) $$;


ALTER FUNCTION public.fn_default_currency() OWNER TO postgres;

--
-- Name: fn_default_product_type_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_default_product_type_id() RETURNS integer
    LANGUAGE sql
    AS $$ SELECT id FROM stk_product_type WHERE product_type_name='HAMMADDE'; $$;


ALTER FUNCTION public.fn_default_product_type_id() OWNER TO postgres;

--
-- Name: fn_document_party_snapshot(); Type: FUNCTION; Schema: public; Owner: ths_admin
--

CREATE FUNCTION public.fn_document_party_snapshot() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    IF NEW.acc_account_id IS NOT DISTINCT FROM OLD.acc_account_id AND NEW.account_title IS NOT NULL THEN
      RETURN NEW;
    END IF;
  END IF;
  SELECT p.account_title, p.taxpayer_type, p.taxpayer_name, p.taxpayer_name2, p.taxpayer_surname, p.tax_office, p.tax_no
    INTO NEW.account_title, NEW.taxpayer_type, NEW.taxpayer_name, NEW.taxpayer_name2, NEW.taxpayer_surname,
         NEW.tax_office, NEW.tax_no
    FROM public.fn_acc_account_party(NEW.acc_account_id) p;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_document_party_snapshot() OWNER TO ths_admin;

--
-- Name: fn_document_trail(character varying, bigint); Type: FUNCTION; Schema: public; Owner: ths_admin
--

CREATE FUNCTION public.fn_document_trail(p_doc_table character varying, p_doc_id bigint) RETURNS TABLE(trail_level integer, doc_table character varying, doc_id bigint, doc_no character varying, doc_date date, acc_account_id bigint, account_code character varying, account_name character varying, status smallint, currency character varying, total_amount numeric)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  v_tables varchar[] := ARRAY[p_doc_table];
  v_ids bigint[] := ARRAY[p_doc_id];
  v_levels integer[] := ARRAY[0];
  v_keys text[] := ARRAY[p_doc_table || ':' || p_doc_id];
  v_front_tables varchar[];
  v_front_ids bigint[];
  v_next_tables varchar[];
  v_next_ids bigint[];
  v_dir integer;
  v_level integer;
  v_table varchar;
  v_link record;
BEGIN
  FOREACH v_dir IN ARRAY ARRAY[-1, 1] LOOP
    v_front_tables := ARRAY[p_doc_table];
    v_front_ids := ARRAY[p_doc_id];
    v_level := 0;
    WHILE cardinality(v_front_ids) > 0 AND abs(v_level) < 10 LOOP
      v_level := v_level + v_dir;
      v_next_tables := '{}';
      v_next_ids := '{}';
      FOR v_table IN SELECT DISTINCT f.t FROM unnest(v_front_tables) f(t) LOOP
        FOR v_link IN
          SELECT DISTINCT
                 CASE WHEN v_dir < 0 THEN l.from_table ELSE l.to_table END AS t,
                 CASE WHEN v_dir < 0 THEN l.from_id ELSE l.to_id END AS i
            FROM public.vw_sys_document_link l
           WHERE (v_dir < 0 AND l.to_table = v_table
                   AND l.to_id = ANY (ARRAY(SELECT f.i FROM unnest(v_front_tables, v_front_ids) f(t, i) WHERE f.t = v_table)))
              OR (v_dir > 0 AND l.from_table = v_table
                   AND l.from_id = ANY (ARRAY(SELECT f.i FROM unnest(v_front_tables, v_front_ids) f(t, i) WHERE f.t = v_table)))
        LOOP
          IF NOT (v_link.t || ':' || v_link.i) = ANY (v_keys) THEN
            v_keys := v_keys || (v_link.t || ':' || v_link.i);
            v_tables := v_tables || v_link.t::varchar;
            v_ids := v_ids || v_link.i;
            v_levels := v_levels || v_level;
            v_next_tables := v_next_tables || v_link.t::varchar;
            v_next_ids := v_next_ids || v_link.i;
          END IF;
        END LOOP;
      END LOOP;
      v_front_tables := v_next_tables;
      v_front_ids := v_next_ids;
    END LOOP;
  END LOOP;

  FOR v_table IN SELECT DISTINCT r.t FROM unnest(v_tables) r(t) LOOP
    RETURN QUERY
      SELECT r.lv, d.doc_table::varchar, d.id, d.doc_no::varchar, d.doc_date, d.acc_account_id, d.account_code::varchar,
             d.account_name::varchar, d.status, d.currency::varchar, d.total_amount
        FROM public.vw_sys_document d
        JOIN unnest(v_tables, v_ids, v_levels) r(t, i, lv) ON r.t = d.doc_table AND r.i = d.id
       WHERE d.doc_table = v_table
         AND d.id = ANY (ARRAY(SELECT r2.i FROM unnest(v_tables, v_ids) r2(t, i) WHERE r2.t = v_table));
  END LOOP;
END;
$$;


ALTER FUNCTION public.fn_document_trail(p_doc_table character varying, p_doc_id bigint) OWNER TO ths_admin;

--
-- Name: fn_exchange_rate(character varying, date); Type: FUNCTION; Schema: public; Owner: ths_admin
--

CREATE FUNCTION public.fn_exchange_rate(p_currency character varying, p_date date) RETURNS numeric
    LANGUAGE sql STABLE
    AS $$
  WITH b AS (SELECT public.fn_default_currency() AS base),
  r AS (
    SELECT c.cur,
           CASE WHEN c.cur = 'TRY' THEN 1::numeric
                ELSE (SELECT x.rate FROM public.acc_exchange_rate x
                       WHERE x.currency = c.cur AND x.rate_date <= p_date
                       ORDER BY x.rate_date DESC LIMIT 1) END AS try_rate
      FROM (SELECT p_currency AS cur UNION ALL SELECT base FROM b) c
  )
  SELECT CASE WHEN p_currency = (SELECT base FROM b) THEN 1::numeric
              ELSE round((SELECT try_rate FROM r WHERE cur = p_currency LIMIT 1) /
                         NULLIF((SELECT try_rate FROM r, b WHERE cur = b.base LIMIT 1), 0), 6) END
$$;


ALTER FUNCTION public.fn_exchange_rate(p_currency character varying, p_date date) OWNER TO ths_admin;

--
-- Name: fn_get_lang_text(text, text, text, bigint, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_get_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) RETURNS character varying
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
	dmp text;
begin
	SELECT INTO dmp deger FROM sys_lisan_data_icerik 
	WHERE	row_id = prow_id
		AND lisan = plang
		AND kolon_adi = pcolumn_name
		AND tablo_adi = ptable_name
	LIMIT 1;
  
	IF (dmp is null) OR (dmp = '') THEN
		return pdefault_value;
	ELSE
		return dmp;
	END IF;

end
$$;


ALTER FUNCTION public.fn_get_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) OWNER TO postgres;

--
-- Name: fn_get_lang_text(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_get_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) RETURNS character varying
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$declare
	--dmp text;
	--_default_val text;
begin
--  _default_val := exec(concat('SELECT raw', _table_name, '.', pRawTableColName, ' FROM ', _table_name, ' as raw', _table_name ' WHERE raw', _table_name, '.id=', pDataTableName, '.', pDataColName));
/*
	SELECT INTO dmp val FROM sys_lang_data_content 
	WHERE	1=1
		AND row_id = _row_id
		AND lang = _lang
		AND column_name = _column_name
		AND table_name = _table_name
	LIMIT 1;
  
	IF (dmp is null) OR (dmp = '') THEN*/
		return _default_value;
/*	ELSE
		return dmp;
	END IF;
*/
end
$$;


ALTER FUNCTION public.fn_get_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) OWNER TO postgres;

--
-- Name: fn_get_rct_hammadde_maliyet(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_get_rct_hammadde_maliyet(prct_recete_id bigint) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
	_row record;
	_toplam numeric;
BEGIN
	_toplam := 0;
	FOR _row IN
		SELECT h.miktar * s.alis_fiyat tutar FROM urt_recete_hammaddeler h
		LEFT JOIN stk_kartlar s ON s.stok_kodu = h.stok_kodu
		WHERE h.header_id = prct_recete_id
	LOOP
		_toplam := _toplam + coalesce(_row.tutar, 0);
	END LOOP;
	
	RETURN _toplam;
END;
$$;


ALTER FUNCTION public.fn_get_rct_hammadde_maliyet(prct_recete_id bigint) OWNER TO postgres;

--
-- Name: fn_get_rct_iscilik_maliyet(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_get_rct_iscilik_maliyet(prct_recete_id bigint) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
	_row record;
	_toplam numeric;
BEGIN
	_toplam := 0;
	FOR _row IN
		SELECT (i.miktar * ig.fiyat) tutar FROM urt_recete_iscilikler i
		LEFT JOIN urt_iscilikler ig ON i.iscilik_kodu = ig.gider_kodu
		WHERE i.header_id = prct_recete_id
	LOOP
		_toplam := _toplam + coalesce(_row.tutar, 0);
	END LOOP;
	
	RETURN _toplam;
END;
$$;


ALTER FUNCTION public.fn_get_rct_iscilik_maliyet(prct_recete_id bigint) OWNER TO postgres;

--
-- Name: fn_get_rct_toplam(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_get_rct_toplam(prct_recete_id bigint) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
	_tmp numeric;
	_toplam numeric;
BEGIN
	_toplam := 0;
	SELECT spget_rct_hammadde_maliyet(prct_recete_id) INTO _tmp;
	_toplam := _toplam + _tmp;
	SELECT spget_rct_iscilik_maliyet(prct_recete_id) INTO _tmp;
	_toplam := _toplam + _tmp;
	SELECT spget_rct_yan_urun_maliyet(prct_recete_id) INTO _tmp;
	_toplam := _toplam - _tmp;
	RETURN _toplam;
END;
$$;


ALTER FUNCTION public.fn_get_rct_toplam(prct_recete_id bigint) OWNER TO postgres;

--
-- Name: fn_get_rct_yan_urun_maliyet(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_get_rct_yan_urun_maliyet(prct_recete_id bigint) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
	_row record;
	_toplam numeric;
BEGIN
	_toplam := 0;
	FOR _row IN
		SELECT (yu.miktar * s.alis_fiyat) tutar FROM urt_recete_yan_urunler yu
		LEFT JOIN stk_kartlar s ON s.stok_kodu = yu.urun_kodu
		WHERE yu.header_id = prct_recete_id
	LOOP
		_toplam := _toplam - coalesce(_row.tutar, 0);
	END LOOP;

	RETURN _toplam;
END;
$$;


ALTER FUNCTION public.fn_get_rct_yan_urun_maliyet(prct_recete_id bigint) OWNER TO postgres;

--
-- Name: fn_get_sys_kalite_form_no(text, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_get_sys_kalite_form_no(p_table_name text, p_form_type_id bigint) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    formNo text;
BEGIN
    SELECT INTO formNo form_no FROM sys_quality_form_no WHERE table_name = p_table_name AND form_type_id = p_form_type_id;
    RETURN formNo;
END
$$;


ALTER FUNCTION public.fn_get_sys_kalite_form_no(p_table_name text, p_form_type_id bigint) OWNER TO postgres;

--
-- Name: fn_get_sys_lang_id(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_get_sys_lang_id(planguage text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
 _id Integer;
BEGIN
	SELECT INTO _id id FROM sys_lang WHERE language=planguage;
	RETURN _id;
END;
$$;


ALTER FUNCTION public.fn_get_sys_lang_id(planguage text) OWNER TO postgres;

--
-- Name: fn_get_sys_quality_form_type_id(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_get_sys_quality_form_type_id(ptype integer) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
	idx Integer;
BEGIN
	CASE
		WHEN ptype = 1 THEN	SELECT INTO idx id FROM sys_quality_form_type WHERE form_type='INPUT';
		WHEN ptype = 2 THEN	SELECT INTO idx id FROM sys_quality_form_type WHERE form_type='OUTPUT';
		WHEN ptype = 3 THEN	SELECT INTO idx id FROM sys_quality_form_type WHERE form_type='PRINT LIST';
		WHEN ptype = 4 THEN	SELECT INTO idx id FROM sys_quality_form_type WHERE form_type='PRINT DETAIL';
		WHEN ptype = 5 THEN	SELECT INTO idx id FROM sys_quality_form_type WHERE form_type='SPECIAL';
	END CASE;
	return idx;
END;
$$;


ALTER FUNCTION public.fn_get_sys_quality_form_type_id(ptype integer) OWNER TO postgres;

--
-- Name: fn_get_table_data_dynamic(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_get_table_data_dynamic(p_table_name character varying) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_columns text;
    v_query text;
    v_has_custom_columns boolean;
BEGIN
    -- sys_grid_columns'da bu tablo için kayıt var mı kontrol et
    SELECT EXISTS(
        SELECT 1 
        FROM sys_grid_columns 
        WHERE table_name = p_table_name
    ) INTO v_has_custom_columns;
    
    IF v_has_custom_columns THEN
        -- Özelleştirilmiş kolonlar varsa, sadece is_show=true olanları sıralı getir
        SELECT string_agg(quote_ident(column_name), ', ' ORDER BY column_order)
        INTO v_columns
        FROM sys_grid_columns
        WHERE table_name = p_table_name
          AND is_show = true;
    
		IF v_columns IS NULL THEN
        	RAISE EXCEPTION 'Table % not found or has no columns', p_table_name;
    	END IF;
    	-- Dinamik sorgu oluştur ve çalıştır
    	v_query := format('SELECT %s FROM %I', v_columns, p_table_name);
    ELSE
        v_query := format('SELECT * FROM %I', p_table_name);
    END IF;

    RETURN QUERY EXECUTE v_query;
END;
$$;


ALTER FUNCTION public.fn_get_table_data_dynamic(p_table_name character varying) OWNER TO postgres;

--
-- Name: fn_sys_address_text(bigint, character varying); Type: FUNCTION; Schema: public; Owner: ths_admin
--

CREATE FUNCTION public.fn_sys_address_text(p_sys_address_id bigint, p_locale character varying) RETURNS character varying
    LANGUAGE sql STABLE
    AS $$
  SELECT NULLIF(concat_ws(E'\n',
           NULLIF(concat_ws(', ', NULLIF(btrim(a.neighborhood), ''), NULLIF(btrim(a.quarter), ''), NULLIF(btrim(a.road), ''),
                            NULLIF(btrim(a.street), ''), NULLIF(btrim(a.building_name), ''), NULLIF(btrim(a.door_number), '')), ''),
           NULLIF(concat_ws(' ', NULLIF(btrim(a.zip_code), ''),
                            NULLIF(concat_ws(' / ', NULLIF(btrim(a.district), ''), NULLIF(btrim(c.city_name), '')), '')), ''),
           NULLIF(btrim(COALESCE(ct.country_name, cn.country_code)), '')), '')::character varying(512)
    FROM public.sys_address a
    LEFT JOIN public.sys_city c ON c.id = a.sys_city_id
    LEFT JOIN public.sys_country cn ON cn.id = c.sys_country_id
    LEFT JOIN public.sys_language l ON l.locale = p_locale
    LEFT JOIN public.sys_country_translation ct ON ct.sys_country_id = c.sys_country_id AND ct.sys_language_id = l.id
   WHERE a.id = p_sys_address_id
$$;


ALTER FUNCTION public.fn_sys_address_text(p_sys_address_id bigint, p_locale character varying) OWNER TO ths_admin;

--
-- Name: fn_tax_summary_refresh(character varying, bigint[]); Type: FUNCTION; Schema: public; Owner: ths_admin
--

CREATE FUNCTION public.fn_tax_summary_refresh(p_doc character varying, p_ids bigint[]) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
  v_summary text := p_doc || '_tax_summary';
  v_detail text := p_doc || '_detail';
  v_fk text := p_doc || '_id';
BEGIN
  IF p_ids IS NULL OR cardinality(p_ids) = 0 THEN
    RETURN;
  END IF;
  EXECUTE format('DELETE FROM public.%I WHERE %I = ANY ($1)', v_summary, v_fk) USING p_ids;
  EXECUTE format(
    'INSERT INTO public.%1$I (%2$I, summary_type, tax_rate, base_amount, tax_amount)
     SELECT d.%2$I, 1, d.vat_rate, sum(d.net_amount), sum(d.vat_amount)
       FROM public.%3$I d
      WHERE d.%2$I = ANY ($1)
      GROUP BY d.%2$I, d.vat_rate', v_summary, v_fk, v_detail) USING p_ids;
  IF p_doc = 'sls_invoice' THEN
    INSERT INTO public.sls_invoice_tax_summary (sls_invoice_id, summary_type, tax_rate, einv_withholding_id, base_amount, tax_amount)
    SELECT d.sls_invoice_id, 2, w.rate, d.einv_withholding_id, sum(d.vat_amount), sum(d.withholding_amount)
      FROM public.sls_invoice_detail d
      JOIN public.einv_withholding w ON w.id = d.einv_withholding_id
     WHERE d.sls_invoice_id = ANY (p_ids)
     GROUP BY d.sls_invoice_id, d.einv_withholding_id, w.rate;
  END IF;
END;
$_$;


ALTER FUNCTION public.fn_tax_summary_refresh(p_doc character varying, p_ids bigint[]) OWNER TO ths_admin;

--
-- Name: fn_tax_summary_trigger(); Type: FUNCTION; Schema: public; Owner: ths_admin
--

CREATE FUNCTION public.fn_tax_summary_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
  v_fk text := TG_ARGV[0] || '_id';
  v_ids bigint[];
BEGIN
  IF TG_OP = 'INSERT' THEN
    EXECUTE format('SELECT array_agg(DISTINCT %I) FROM new_rows', v_fk) INTO v_ids;
  ELSIF TG_OP = 'DELETE' THEN
    EXECUTE format('SELECT array_agg(DISTINCT %I) FROM old_rows', v_fk) INTO v_ids;
  ELSE
    EXECUTE format('SELECT array_agg(DISTINCT x) FROM (SELECT %1$I AS x FROM new_rows UNION SELECT %1$I FROM old_rows) s', v_fk)
      INTO v_ids;
  END IF;
  PERFORM public.fn_tax_summary_refresh(TG_ARGV[0], v_ids);
  RETURN NULL;
END;
$_$;


ALTER FUNCTION public.fn_tax_summary_trigger() OWNER TO ths_admin;

--
-- Name: personel_adsoyad(); Type: FUNCTION; Schema: public; Owner: ths_admin
--

CREATE FUNCTION public.personel_adsoyad() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$DECLARE
    BEGIN
	IF (TG_OP = 'UPDATE') OR (TG_OP = 'INSERT') THEN
		UPDATE personel_karti SET 
			personel_ad_soyad=personel_ad || ' ' || personel_soyad
		WHERE personel_karti.id=NEW.id;
	END IF;
	
        RETURN NULL;
    END;
$$;


ALTER FUNCTION public.personel_adsoyad() OWNER TO ths_admin;

--
-- Name: pur_quotation_order_unlinked(); Type: FUNCTION; Schema: public; Owner: ths_admin
--

CREATE FUNCTION public.pur_quotation_order_unlinked() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.pur_order_id IS NULL AND OLD.pur_order_id IS NOT NULL AND NEW.status = 5 THEN
    NEW.status := 3;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.pur_quotation_order_unlinked() OWNER TO ths_admin;

--
-- Name: table_listen(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.table_listen(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT listen table_name;
  RETURN;
END;
$$;


ALTER FUNCTION public.table_listen(table_name text) OWNER TO postgres;

--
-- Name: table_notify(); Type: FUNCTION; Schema: public; Owner: ths_admin
--

CREATE FUNCTION public.table_notify() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
	IF (TG_OP = 'INSERT') THEN
		PERFORM pg_notify(TG_TABLE_NAME, NEW.id::varchar);
		RETURN NEW;
	ELSIF (TG_OP = 'UPDATE') THEN
		PERFORM pg_notify(TG_TABLE_NAME, NEW.id::varchar);
		RETURN NEW;
	ELSIF (TG_OP = 'DELETE') THEN
		PERFORM pg_notify(TG_TABLE_NAME, OLD.id::varchar);
		RETURN OLD;
	END IF;
END;
$$;


ALTER FUNCTION public.table_notify() OWNER TO ths_admin;

--
-- Name: table_notify(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.table_notify(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT notify table_name;
  RETURN;
END;
$$;


ALTER FUNCTION public.table_notify(table_name text) OWNER TO postgres;

--
-- Name: table_unlisten(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.table_unlisten(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT unlisten table_name;
  RETURN;
END;
$$;


ALTER FUNCTION public.table_unlisten(table_name text) OWNER TO postgres;

--
-- Name: audit_server; Type: SERVER; Schema: -; Owner: postgres
--

CREATE SERVER audit_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (
    batch_size '500',
    dbname 'ths_audit',
    fetch_size '1000',
    host 'localhost',
    port '5432'
);


ALTER SERVER audit_server OWNER TO postgres;

--
-- Name: USER MAPPING public SERVER audit_server; Type: USER MAPPING; Schema: -; Owner: postgres
--

CREATE USER MAPPING FOR public SERVER audit_server OPTIONS (
    password 'qwe',
    "user" 'ths_audit_writer'
);


--
-- Name: audit_database; Type: FOREIGN TABLE; Schema: audit_remote; Owner: postgres
--

CREATE FOREIGN TABLE audit_remote.audit_database (
    db_name character varying(63) NOT NULL,
    db_family character varying(63) NOT NULL,
    period_year smallint NOT NULL,
    company_title character varying(128),
    first_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    last_flush_at timestamp with time zone,
    flushed_rows bigint DEFAULT 0 NOT NULL
)
SERVER audit_server
OPTIONS (
    schema_name 'public',
    table_name 'audit_database'
);


ALTER FOREIGN TABLE audit_remote.audit_database OWNER TO postgres;

--
-- Name: audit_log; Type: FOREIGN TABLE; Schema: audit_remote; Owner: postgres
--

CREATE FOREIGN TABLE audit_remote.audit_log (
    id bigint NOT NULL,
    period_year smallint NOT NULL,
    db_name character varying(63) NOT NULL,
    db_family character varying(63) NOT NULL,
    source_id bigint NOT NULL,
    table_schema character varying(63) NOT NULL,
    table_name character varying(63) NOT NULL,
    row_id bigint,
    action character(1) NOT NULL,
    changed_at timestamp with time zone NOT NULL,
    transaction_id bigint,
    db_user character varying(63) NOT NULL,
    app_user character varying(64),
    client_addr inet,
    application_name character varying(64),
    old_data jsonb,
    new_data jsonb,
    received_at timestamp with time zone NOT NULL
)
SERVER audit_server
OPTIONS (
    schema_name 'public',
    table_name 'audit_log',
    updatable 'false'
);


ALTER FOREIGN TABLE audit_remote.audit_log OWNER TO postgres;

--
-- Name: audit_log_in; Type: FOREIGN TABLE; Schema: audit_remote; Owner: postgres
--

CREATE FOREIGN TABLE audit_remote.audit_log_in (
    period_year smallint NOT NULL,
    db_name character varying(63) NOT NULL,
    db_family character varying(63) NOT NULL,
    source_id bigint NOT NULL,
    table_schema character varying(63) NOT NULL,
    table_name character varying(63) NOT NULL,
    row_id bigint,
    action character(1) NOT NULL,
    changed_at timestamp with time zone NOT NULL,
    transaction_id bigint,
    db_user character varying(63) NOT NULL,
    app_user character varying(64),
    client_addr inet,
    application_name character varying(64),
    old_data jsonb,
    new_data jsonb
)
SERVER audit_server
OPTIONS (
    schema_name 'public',
    table_name 'audit_log'
);


ALTER FOREIGN TABLE audit_remote.audit_log_in OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: acc_account; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_account (
    id bigint CONSTRAINT acc_acc_id_nn NOT NULL,
    code character varying(16) CONSTRAINT acc_acc_code_nn NOT NULL,
    name character varying(128) CONSTRAINT acc_acc_name_nn NOT NULL,
    acc_set_account_type_id bigint CONSTRAINT acc_acc_type_nn NOT NULL,
    acc_group_id bigint,
    acc_region_id bigint,
    iban character varying(64),
    iban_currency character varying(3),
    notes character varying(512),
    root_code character varying(3),
    sub_code character varying(8),
    discount_rate numeric(5,2) DEFAULT 0 NOT NULL,
    e_invoice_active boolean DEFAULT false CONSTRAINT acc_acc_einv_nn NOT NULL,
    e_invoice_pk_alias character varying(256),
    is_passive boolean DEFAULT false CONSTRAINT acc_acc_passive_nn NOT NULL,
    e_despatch_active boolean DEFAULT false NOT NULL,
    e_invoice_gb_alias character varying(256),
    e_despatch_pk_alias character varying(256),
    e_despatch_gb_alias character varying(256),
    CONSTRAINT acc_account_einv_alias_check CHECK ((((e_invoice_pk_alias IS NULL) OR ((e_invoice_pk_alias)::text ~* '^urn:mail:[^@[:space:]]+@[^@[:space:]]+$'::text)) AND ((e_invoice_gb_alias IS NULL) OR ((e_invoice_gb_alias)::text ~* '^urn:mail:[^@[:space:]]+@[^@[:space:]]+$'::text)) AND ((e_despatch_pk_alias IS NULL) OR ((e_despatch_pk_alias)::text ~* '^urn:mail:[^@[:space:]]+@[^@[:space:]]+$'::text)) AND ((e_despatch_gb_alias IS NULL) OR ((e_despatch_gb_alias)::text ~* '^urn:mail:[^@[:space:]]+@[^@[:space:]]+$'::text))))
);


ALTER TABLE public.acc_account OWNER TO ths_admin;

--
-- Name: acc_account_address; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_account_address (
    id bigint NOT NULL,
    acc_account_id bigint CONSTRAINT acc_account_address_account_id_not_null NOT NULL,
    sys_address_id bigint CONSTRAINT acc_account_address_address_id_not_null NOT NULL,
    address_type character varying(16) NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    valid_from date,
    valid_to date,
    CONSTRAINT acc_account_address_type_check CHECK (((address_type)::text = ANY (ARRAY[('BILLING'::character varying)::text, ('SHIPPING'::character varying)::text, ('LEGAL'::character varying)::text, ('OTHER'::character varying)::text])))
);


ALTER TABLE public.acc_account_address OWNER TO ths_admin;

--
-- Name: COLUMN acc_account_address.address_type; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.acc_account_address.address_type IS 'BILLING, SHIPPING, LEGAL, OTHER';


--
-- Name: acc_account_address_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.acc_account_address ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.acc_account_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: acc_account_contact; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_account_contact (
    acc_account_id bigint CONSTRAINT acc_account_contact_account_id_not_null NOT NULL,
    authorized_person_1 character varying(64),
    authorized_phone_1 character varying(32),
    authorized_person_2 character varying(64),
    authorized_phone_2 character varying(32),
    authorized_person_3 character varying(64),
    authorized_phone_3 character varying(32),
    fax character varying(32),
    accountant_phone character varying(32),
    accountant_email character varying(128),
    accountant_authorized character varying(32)
);


ALTER TABLE public.acc_account_contact OWNER TO ths_admin;

--
-- Name: acc_account_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.acc_account ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.acc_account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: acc_account_plan; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_account_plan (
    id bigint CONSTRAINT acc_aplan_id_nn NOT NULL,
    code character varying(16) CONSTRAINT acc_aplan_code_nn NOT NULL,
    name character varying(128) CONSTRAINT acc_aplan_name_nn NOT NULL,
    level smallint CONSTRAINT acc_aplan_level_nn NOT NULL
);


ALTER TABLE public.acc_account_plan OWNER TO ths_admin;

--
-- Name: acc_account_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.acc_account_plan ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.acc_account_plan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: acc_account_taxpayer; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_account_taxpayer (
    acc_account_id bigint CONSTRAINT acc_account_taxpayer_account_id_not_null NOT NULL,
    taxpayer_type smallint,
    taxpayer_name character varying(32),
    taxpayer_name2 character varying(32),
    taxpayer_surname character varying(32),
    tax_office character varying(64),
    tax_no character varying(32),
    nace_code character varying(32),
    CONSTRAINT acc_account_taxpayer_type_check CHECK (((taxpayer_type IS NULL) OR (taxpayer_type = ANY (ARRAY[1, 2]))))
);


ALTER TABLE public.acc_account_taxpayer OWNER TO ths_admin;

--
-- Name: acc_bank; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_bank (
    id bigint CONSTRAINT acc_bank_id_nn NOT NULL,
    bank_name character varying(128) CONSTRAINT acc_bank_name_nn NOT NULL,
    swift_code character varying(16)
);


ALTER TABLE public.acc_bank OWNER TO ths_admin;

--
-- Name: acc_bank_branch; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_bank_branch (
    id bigint CONSTRAINT acc_branch_id_nn NOT NULL,
    acc_bank_id bigint CONSTRAINT acc_branch_bank_nn NOT NULL,
    branch_code integer CONSTRAINT acc_branch_code_nn NOT NULL,
    branch_name character varying(128) CONSTRAINT acc_branch_name_nn NOT NULL,
    sys_city_id bigint CONSTRAINT acc_branch_city_nn NOT NULL
);


ALTER TABLE public.acc_bank_branch OWNER TO ths_admin;

--
-- Name: acc_bank_branch_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.acc_bank_branch ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.acc_bank_branch_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: acc_bank_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.acc_bank ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.acc_bank_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: acc_exchange_rate; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_exchange_rate (
    id bigint CONSTRAINT acc_er_id_nn NOT NULL,
    rate_date date CONSTRAINT acc_er_date_nn NOT NULL,
    rate numeric(18,6) CONSTRAINT acc_er_rate_nn NOT NULL,
    currency character varying(3) NOT NULL,
    forex_selling numeric(18,6),
    banknote_buying numeric(18,6),
    banknote_selling numeric(18,6),
    source character varying(8) DEFAULT 'MANUAL'::character varying NOT NULL,
    CONSTRAINT acc_exchange_rate_rate_check CHECK ((rate > (0)::numeric)),
    CONSTRAINT acc_exchange_rate_source_check CHECK (((source)::text = ANY (ARRAY[('MANUAL'::character varying)::text, ('TCMB'::character varying)::text])))
);


ALTER TABLE public.acc_exchange_rate OWNER TO ths_admin;

--
-- Name: COLUMN acc_exchange_rate.rate_date; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.acc_exchange_rate.rate_date IS 'Kurun geçerli olduğu gün; TCMB cuma kuru cumartesi / pazar için de yazılır';


--
-- Name: COLUMN acc_exchange_rate.rate; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.acc_exchange_rate.rate IS 'Döviz alış (TCMB ForexBuying, 1 birim = rate TRY); belgelerin varsayılan kuru';


--
-- Name: COLUMN acc_exchange_rate.source; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.acc_exchange_rate.source IS 'MANUAL, TCMB (TCMB satırları her çekişte güncellenir, MANUAL satırlara dokunulmaz)';


--
-- Name: acc_group; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_group (
    id bigint CONSTRAINT acc_group_id_nn NOT NULL,
    name character varying(16) CONSTRAINT acc_group_name_nn NOT NULL
);


ALTER TABLE public.acc_group OWNER TO ths_admin;

--
-- Name: acc_group_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.acc_group ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.acc_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: acc_region; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_region (
    id bigint CONSTRAINT acc_region_id_nn NOT NULL,
    name character varying(32) CONSTRAINT acc_region_name_nn NOT NULL
);


ALTER TABLE public.acc_region OWNER TO ths_admin;

--
-- Name: acc_region_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.acc_region ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.acc_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: acc_set_account_type; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_set_account_type (
    id bigint CONSTRAINT acc_set_at_id_nn NOT NULL,
    account_type_key character varying(32) CONSTRAINT acc_set_at_name_nn NOT NULL
);


ALTER TABLE public.acc_set_account_type OWNER TO ths_admin;

--
-- Name: acc_set_account_type_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.acc_set_account_type ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.acc_set_account_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: acc_set_account_type_translation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_set_account_type_translation (
    acc_set_account_type_id bigint CONSTRAINT acc_set_account_type_translati_acc_set_account_type_id_not_null NOT NULL,
    sys_language_id bigint NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.acc_set_account_type_translation OWNER TO ths_admin;

--
-- Name: acc_set_company_legal_form; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_set_company_legal_form (
    id bigint CONSTRAINT acc_clf_id_nn NOT NULL,
    acc_set_ownership_type_id bigint CONSTRAINT acc_clf_own_nn NOT NULL,
    legal_form_key character varying(48) CONSTRAINT acc_clf_name_nn NOT NULL
);


ALTER TABLE public.acc_set_company_legal_form OWNER TO ths_admin;

--
-- Name: acc_set_company_legal_form_translation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_set_company_legal_form_translation (
    acc_set_company_legal_form_id bigint CONSTRAINT acc_set_company_legal_form__acc_set_company_legal_form_not_null NOT NULL,
    sys_language_id bigint NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.acc_set_company_legal_form_translation OWNER TO ths_admin;

--
-- Name: acc_set_company_type_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.acc_set_company_legal_form ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.acc_set_company_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: acc_set_ownership_type; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_set_ownership_type (
    id bigint CONSTRAINT acc_otn_id_nn NOT NULL,
    ownership_type_key character varying(32) CONSTRAINT acc_otn_name_nn NOT NULL
);


ALTER TABLE public.acc_set_ownership_type OWNER TO ths_admin;

--
-- Name: acc_set_legal_form_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.acc_set_ownership_type ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.acc_set_legal_form_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: acc_set_ownership_type_translation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_set_ownership_type_translation (
    acc_set_ownership_type_id bigint CONSTRAINT acc_set_ownership_type_trans_acc_set_ownership_type_id_not_null NOT NULL,
    sys_language_id bigint NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.acc_set_ownership_type_translation OWNER TO ths_admin;

--
-- Name: acc_set_tax_rate; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_set_tax_rate (
    id bigint CONSTRAINT acc_set_tr_id_nn NOT NULL,
    tax_rate numeric(5,2) CONSTRAINT acc_set_tr_vrate_nn NOT NULL,
    sales_account character varying(16) CONSTRAINT acc_set_tr_sa_nn NOT NULL,
    sales_return_account character varying(16) CONSTRAINT acc_set_tr_sr_nn NOT NULL,
    purchase_account character varying(16) CONSTRAINT acc_set_tr_pa_nn NOT NULL,
    purchase_return_account character varying(16) CONSTRAINT acc_set_tr_pr_nn NOT NULL
);


ALTER TABLE public.acc_set_tax_rate OWNER TO ths_admin;

--
-- Name: acc_set_tax_rate_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.acc_set_tax_rate ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.acc_set_tax_rate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: acc_transfer_code; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_transfer_code (
    id bigint CONSTRAINT mhs_transfer_kodlari_id_not_null NOT NULL,
    transfer_code character varying(32) CONSTRAINT mhs_transfer_kodlari_transfer_kodu_not_null NOT NULL,
    description character varying(128) CONSTRAINT mhs_transfer_kodlari_aciklama_not_null NOT NULL,
    account character varying(16) CONSTRAINT mhs_transfer_kodlari_hesap_kodu_not_null NOT NULL
);


ALTER TABLE public.acc_transfer_code OWNER TO ths_admin;

--
-- Name: acc_voucher; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_voucher (
    id bigint CONSTRAINT mhs_fisler_id_not_null NOT NULL,
    journal_no integer CONSTRAINT mhs_fisler_yevmiye_no_not_null NOT NULL,
    voucher_date date NOT NULL,
    voucher_no character varying(16) NOT NULL,
    voucher_type smallint DEFAULT 1 NOT NULL,
    description character varying(256),
    total_debit numeric(18,2) DEFAULT 0 NOT NULL,
    total_credit numeric(18,2) DEFAULT 0 NOT NULL,
    CONSTRAINT acc_voucher_no_check CHECK ((btrim((voucher_no)::text) <> ''::text)),
    CONSTRAINT acc_voucher_type_check CHECK (((voucher_type >= 1) AND (voucher_type <= 5)))
);


ALTER TABLE public.acc_voucher OWNER TO ths_admin;

--
-- Name: COLUMN acc_voucher.journal_no; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.acc_voucher.journal_no IS 'yevmiye no (servis sıradaki numarayı verir)';


--
-- Name: COLUMN acc_voucher.voucher_type; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.acc_voucher.voucher_type IS '1 mahsup, 2 tahsil, 3 tediye, 4 açılış, 5 kapanış';


--
-- Name: COLUMN acc_voucher.total_debit; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.acc_voucher.total_debit IS 'kalemlerden (servis tutar)';


--
-- Name: acc_voucher_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_voucher_detail (
    id bigint CONSTRAINT mhs_fis_detaylari_id_not_null NOT NULL,
    acc_voucher_id bigint CONSTRAINT mhs_fis_detaylari_header_id_not_null NOT NULL,
    line_no smallint NOT NULL,
    acc_account_id bigint NOT NULL,
    description character varying(256),
    debit numeric(18,2) DEFAULT 0 NOT NULL,
    credit numeric(18,2) DEFAULT 0 NOT NULL,
    CONSTRAINT acc_voucher_detail_amount_check CHECK (((debit >= (0)::numeric) AND (credit >= (0)::numeric) AND ((debit = (0)::numeric) OR (credit = (0)::numeric)) AND ((debit + credit) > (0)::numeric)))
);


ALTER TABLE public.acc_voucher_detail OWNER TO ths_admin;

--
-- Name: audit_outbox; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_outbox (
    id bigint NOT NULL,
    table_schema character varying(63) NOT NULL,
    table_name character varying(63) NOT NULL,
    row_id bigint,
    action character(1) NOT NULL,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    transaction_id bigint DEFAULT txid_current() NOT NULL,
    db_user character varying(63) DEFAULT SESSION_USER NOT NULL,
    app_user character varying(64),
    client_addr inet,
    application_name character varying(64),
    old_data jsonb,
    new_data jsonb,
    CONSTRAINT audit_outbox_action_check CHECK ((action = ANY (ARRAY['I'::bpchar, 'U'::bpchar, 'D'::bpchar])))
);


ALTER TABLE public.audit_outbox OWNER TO postgres;

--
-- Name: TABLE audit_outbox; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.audit_outbox IS 'İşlem geçmişi kuyruğu; audit_flush() ths_audit.audit_log''a taşır ve siler';


--
-- Name: audit_outbox_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.audit_outbox ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.audit_outbox_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_delivery_term; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_delivery_term (
    id bigint CONSTRAINT einv_delivery_type_id_nn NOT NULL,
    code character varying(8) CONSTRAINT einv_delivery_type_delivery_code_nn NOT NULL,
    name character varying(128) CONSTRAINT einv_delivery_type_description_nn NOT NULL,
    is_incoterms boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT einv_delivery_term_code_check CHECK ((btrim((code)::text) <> ''::text))
);


ALTER TABLE public.einv_delivery_term OWNER TO ths_admin;

--
-- Name: TABLE einv_delivery_term; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON TABLE public.einv_delivery_term IS 'Teslim şartları; is_incoterms = UBL-TR DeliveryTerms/ID[schemeID=INCOTERMS] (e-belgeye yazılır), diğerleri firma içi teslim şekli';


--
-- Name: einv_delivery_type_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_delivery_term ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_delivery_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_diib; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_diib (
    id bigint NOT NULL,
    document_no character varying(32) NOT NULL,
    holder_type smallint DEFAULT 2 NOT NULL,
    acc_account_id bigint,
    issue_date date,
    valid_until date,
    description character varying(256),
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT einv_diib_dates_check CHECK (((valid_until IS NULL) OR (issue_date IS NULL) OR (valid_until >= issue_date))),
    CONSTRAINT einv_diib_document_no_check CHECK ((btrim((document_no)::text) <> ''::text)),
    CONSTRAINT einv_diib_holder_account_check CHECK ((((holder_type = 1) AND (acc_account_id IS NULL)) OR ((holder_type = 2) AND (acc_account_id IS NOT NULL)))),
    CONSTRAINT einv_diib_holder_type_check CHECK ((holder_type = ANY (ARRAY[1, 2])))
);


ALTER TABLE public.einv_diib OWNER TO ths_admin;

--
-- Name: TABLE einv_diib; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON TABLE public.einv_diib IS 'Dahilde İşleme İzin Belgesi; holder_type 1 firmamız (satıcı DİİB), 2 müşteri / ihracatçı (alıcı DİİB)';


--
-- Name: einv_diib_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_diib ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_diib_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_diib_line; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_diib_line (
    id bigint NOT NULL,
    einv_diib_id bigint NOT NULL,
    line_code character varying(32) NOT NULL,
    line_kind smallint DEFAULT 1 NOT NULL,
    einv_gtip_id bigint NOT NULL,
    product_description character varying(512) NOT NULL,
    stk_inventory_id bigint,
    quantity numeric(18,6) DEFAULT 0 NOT NULL,
    sys_uom_id bigint,
    is_active boolean DEFAULT true NOT NULL,
    line_no smallint NOT NULL,
    CONSTRAINT einv_diib_line_line_code_check CHECK ((btrim((line_code)::text) <> ''::text)),
    CONSTRAINT einv_diib_line_line_kind_check CHECK ((line_kind = ANY (ARRAY[1, 2]))),
    CONSTRAINT einv_diib_line_product_description_check CHECK ((btrim((product_description)::text) <> ''::text)),
    CONSTRAINT einv_diib_line_quantity_check CHECK ((quantity >= (0)::numeric))
);


ALTER TABLE public.einv_diib_line OWNER TO ths_admin;

--
-- Name: TABLE einv_diib_line; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON TABLE public.einv_diib_line IS 'DİİB satırları: line_code = DİİB satır kodu (e-belgede SATICIDIBSATIRKOD / ALICIDIBSATIRKOD), line_kind 1 ihraç / 2 ithal, product_description = DİİB ürün tanımı';


--
-- Name: einv_diib_line_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_diib_line ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_diib_line_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_document; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_document (
    id bigint NOT NULL,
    sls_invoice_id bigint,
    einv_uuid character varying(36) NOT NULL,
    einv_no character varying(16) NOT NULL,
    xml_content text NOT NULL,
    generated_at timestamp without time zone DEFAULT now() NOT NULL,
    is_valid boolean DEFAULT false NOT NULL,
    validation_message text,
    sls_dispatch_id bigint,
    provider_code character varying(32),
    provider_ref character varying(64),
    sent_at timestamp without time zone,
    status_code integer,
    status_message text,
    status_at timestamp without time zone,
    CONSTRAINT einv_document_source_check CHECK ((num_nonnulls(sls_invoice_id, sls_dispatch_id) = 1))
);


ALTER TABLE public.einv_document OWNER TO ths_admin;

--
-- Name: TABLE einv_document; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON TABLE public.einv_document IS 'Satış faturasının son üretilen UBL XML''i (önizleme / doğrulama / gönderim); audit yok (büyük metin)';


--
-- Name: einv_document_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_document ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_document_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_document_setting; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_document_setting (
    id bigint NOT NULL,
    sys_application_setting_id bigint NOT NULL,
    series_scope smallint NOT NULL,
    einv_series_id bigint,
    sys_api_service_id bigint,
    sender_alias character varying(256),
    receiver_alias character varying(256),
    CONSTRAINT einv_document_setting_alias_check CHECK ((((sender_alias IS NULL) OR ((sender_alias)::text ~* '^urn:mail:[^@[:space:]]+@[^@[:space:]]+$'::text)) AND ((receiver_alias IS NULL) OR ((receiver_alias)::text ~* '^urn:mail:[^@[:space:]]+@[^@[:space:]]+$'::text)))),
    CONSTRAINT einv_document_setting_scope_check CHECK ((series_scope = ANY (ARRAY[1, 2, 3])))
);


ALTER TABLE public.einv_document_setting OWNER TO ths_admin;

--
-- Name: einv_document_setting_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_document_setting ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_document_setting_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_driver; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_driver (
    id bigint NOT NULL,
    first_name character varying(64) NOT NULL,
    family_name character varying(64) NOT NULL,
    national_id character varying(11) NOT NULL,
    phone character varying(32),
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT einv_driver_national_id_check CHECK (((national_id)::text ~ '^[1-9][0-9]{10}$'::text))
);


ALTER TABLE public.einv_driver OWNER TO ths_admin;

--
-- Name: einv_driver_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_driver ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_driver_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_gtip; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_gtip (
    id bigint NOT NULL,
    code character varying(12) NOT NULL,
    name character varying(512) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT einv_gtip_code_check CHECK (((code)::text ~ '^[0-9]{12}$'::text))
);


ALTER TABLE public.einv_gtip OWNER TO ths_admin;

--
-- Name: TABLE einv_gtip; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON TABLE public.einv_gtip IS 'GTİP (Gümrük Tarife İstatistik Pozisyonu, 12 hane) — e-belgede RequiredCustomsID';


--
-- Name: einv_gtip_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_gtip ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_gtip_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_invoice_type; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_invoice_type (
    id bigint CONSTRAINT set_einv_fatura_tipleri_id_not_null NOT NULL,
    code character varying(32) CONSTRAINT set_einv_fatura_tipleri_fatura_tipi_not_null NOT NULL,
    name character varying(128) NOT NULL,
    requires_exemption boolean DEFAULT false NOT NULL,
    requires_withholding boolean DEFAULT false NOT NULL,
    is_return boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT einv_invoice_type_code_check CHECK ((btrim((code)::text) <> ''::text))
);


ALTER TABLE public.einv_invoice_type OWNER TO ths_admin;

--
-- Name: TABLE einv_invoice_type; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON TABLE public.einv_invoice_type IS 'UBL-TR InvoiceTypeCode (fatura tipi)';


--
-- Name: einv_invoice_type_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_invoice_type ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_invoice_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_packaging_type; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_packaging_type (
    id bigint NOT NULL,
    code character varying(8) NOT NULL,
    name character varying(128) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT einv_packaging_type_code_check CHECK ((btrim((code)::text) <> ''::text))
);


ALTER TABLE public.einv_packaging_type OWNER TO ths_admin;

--
-- Name: TABLE einv_packaging_type; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON TABLE public.einv_packaging_type IS 'UBL-TR PackagingTypeCode (paket / kap cinsi, UNECE Rec 21)';


--
-- Name: einv_packaging_type_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_packaging_type ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_packaging_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_payment_means; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_payment_means (
    id bigint NOT NULL,
    code character varying(8) NOT NULL,
    name character varying(128) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT einv_payment_means_code_check CHECK ((btrim((code)::text) <> ''::text))
);


ALTER TABLE public.einv_payment_means OWNER TO ths_admin;

--
-- Name: TABLE einv_payment_means; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON TABLE public.einv_payment_means IS 'UBL-TR PaymentMeansCode (UN/EDIFACT 4461 ödeme şekli)';


--
-- Name: einv_payment_means_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_payment_means ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_payment_means_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_payment_method; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_payment_method (
    id bigint CONSTRAINT set_einv_odeme_sekilleri_id_not_null NOT NULL,
    payment_method_code character varying(96),
    code character varying(16),
    description character varying(512),
    is_efatura boolean DEFAULT false
);


ALTER TABLE public.einv_payment_method OWNER TO ths_admin;

--
-- Name: einv_payment_method_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_payment_method ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_payment_method_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_profile; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_profile (
    id bigint NOT NULL,
    code character varying(32) NOT NULL,
    name character varying(128) NOT NULL,
    document_kind smallint DEFAULT 1 NOT NULL,
    requires_export_info boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT einv_profile_code_check CHECK ((btrim((code)::text) <> ''::text)),
    CONSTRAINT einv_profile_document_kind_check CHECK ((document_kind = ANY (ARRAY[1, 2])))
);


ALTER TABLE public.einv_profile OWNER TO ths_admin;

--
-- Name: TABLE einv_profile; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON TABLE public.einv_profile IS 'UBL-TR ProfileID (senaryo); document_kind 1 fatura / 2 irsaliye';


--
-- Name: einv_profile_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_profile ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_profile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_series; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_series (
    id bigint NOT NULL,
    code character varying(3) NOT NULL,
    name character varying(64) NOT NULL,
    series_scope smallint NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT einv_series_code_check CHECK (((code)::text ~ '^[A-Z0-9]{3}$'::text)),
    CONSTRAINT einv_series_scope_check CHECK ((series_scope = ANY (ARRAY[1, 2, 3])))
);


ALTER TABLE public.einv_series OWNER TO ths_admin;

--
-- Name: COLUMN einv_series.series_scope; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.einv_series.series_scope IS '1 e-Fatura senaryoları, 2 e-Arşiv (EARSIVFATURA)';


--
-- Name: einv_series_counter; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_series_counter (
    einv_series_id bigint NOT NULL,
    period_year smallint NOT NULL,
    last_number bigint DEFAULT 0 NOT NULL,
    CONSTRAINT einv_series_counter_number_check CHECK (((last_number >= 0) AND (last_number <= 999999999))),
    CONSTRAINT einv_series_counter_year_check CHECK (((period_year >= 2000) AND (period_year <= 2999)))
);


ALTER TABLE public.einv_series_counter OWNER TO ths_admin;

--
-- Name: einv_series_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_series ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_series_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_tax_exemption; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_tax_exemption (
    id bigint NOT NULL,
    code character varying(8) NOT NULL,
    name character varying(512) NOT NULL,
    exemption_group smallint NOT NULL,
    einv_invoice_type_id bigint,
    requires_gtip boolean DEFAULT false NOT NULL,
    requires_diib boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    requires_zero_vat boolean DEFAULT false NOT NULL,
    CONSTRAINT einv_tax_exemption_code_check CHECK ((btrim((code)::text) <> ''::text)),
    CONSTRAINT einv_tax_exemption_exemption_group_check CHECK (((exemption_group >= 1) AND (exemption_group <= 7)))
);


ALTER TABLE public.einv_tax_exemption OWNER TO ths_admin;

--
-- Name: TABLE einv_tax_exemption; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON TABLE public.einv_tax_exemption IS 'UBL-TR TaxExemptionReasonCode; grup 1 KDV kısmi, 2 KDV tam, 3 diğer işlem türü, 4 ÖTV, 5 konaklama vergisi, 6 özel matrah, 7 ihraç kayıtlı / DİİB; einv_invoice_type_id = kodun kullanılabildiği fatura tipi (boş = tümü)';


--
-- Name: einv_tax_exemption_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_tax_exemption ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_tax_exemption_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_tax_type; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_tax_type (
    id bigint NOT NULL,
    code character varying(8) NOT NULL,
    name character varying(128) NOT NULL,
    short_name character varying(32),
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT einv_tax_type_code_check CHECK ((btrim((code)::text) <> ''::text))
);


ALTER TABLE public.einv_tax_type OWNER TO ths_admin;

--
-- Name: TABLE einv_tax_type; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON TABLE public.einv_tax_type IS 'UBL-TR TaxTypeCode (vergi kodları)';


--
-- Name: einv_tax_type_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_tax_type ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_tax_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_transport_mode; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_transport_mode (
    id bigint NOT NULL,
    code character varying(8) NOT NULL,
    name character varying(128) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT einv_transport_mode_code_check CHECK ((btrim((code)::text) <> ''::text))
);


ALTER TABLE public.einv_transport_mode OWNER TO ths_admin;

--
-- Name: TABLE einv_transport_mode; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON TABLE public.einv_transport_mode IS 'UBL-TR TransportModeCode (taşıma gönderim şekli, UNECE Rec 19)';


--
-- Name: einv_transport_mode_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_transport_mode ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_transport_mode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_transport_price; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_transport_price (
    id bigint CONSTRAINT set_einv_tasima_ucretleri_id_not_null NOT NULL,
    transport_charge character varying(16)
);


ALTER TABLE public.einv_transport_price OWNER TO ths_admin;

--
-- Name: einv_transport_price_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_transport_price ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_transport_price_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_vehicle; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_vehicle (
    id bigint NOT NULL,
    plate_no character varying(16) NOT NULL,
    is_trailer boolean DEFAULT false NOT NULL,
    description character varying(128),
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT einv_vehicle_plate_no_check CHECK (((plate_no)::text ~ '^[0-9A-Z]{4,16}$'::text))
);


ALTER TABLE public.einv_vehicle OWNER TO ths_admin;

--
-- Name: einv_vehicle_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_vehicle ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_vehicle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_withholding; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_withholding (
    id bigint NOT NULL,
    code character varying(8) NOT NULL,
    name character varying(512) NOT NULL,
    rate numeric(5,2) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT einv_withholding_code_check CHECK ((btrim((code)::text) <> ''::text)),
    CONSTRAINT einv_withholding_rate_check CHECK (((rate > (0)::numeric) AND (rate <= (100)::numeric)))
);


ALTER TABLE public.einv_withholding OWNER TO ths_admin;

--
-- Name: TABLE einv_withholding; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON TABLE public.einv_withholding IS 'UBL-TR tevkifat kodları (WithholdingTaxTotal TaxTypeCode); rate = KDV tutarının tevkif edilen yüzdesi';


--
-- Name: einv_withholding_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_withholding ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_withholding_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: emp_driver_ability; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_driver_ability (
    id bigint CONSTRAINT prs_driver_abilities_id_not_null NOT NULL,
    emp_driver_license_type_id bigint NOT NULL,
    emp_employee_id bigint NOT NULL
);


ALTER TABLE public.emp_driver_ability OWNER TO ths_admin;

--
-- Name: emp_driver_license_type; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_driver_license_type (
    id bigint CONSTRAINT prs_set_dlt_id_nn NOT NULL,
    license_name character varying(32) CONSTRAINT prs_set_dlt_nname_nn NOT NULL
);


ALTER TABLE public.emp_driver_license_type OWNER TO ths_admin;

--
-- Name: emp_employee; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_employee (
    id bigint CONSTRAINT prs_persons_id_not_null NOT NULL,
    name character varying(32) CONSTRAINT prs_persons_name_not_null NOT NULL,
    surname character varying(32) CONSTRAINT prs_persons_surname_not_null NOT NULL,
    full_name character varying(64) CONSTRAINT prs_persons_full_name_not_null NOT NULL,
    phone1 character varying(24),
    phone2 character varying(24),
    emp_person_type_id bigint CONSTRAINT prs_persons_person_type_id_not_null NOT NULL,
    emp_unit_id bigint CONSTRAINT prs_persons_unit_id_not_null NOT NULL,
    emp_task_id bigint CONSTRAINT prs_persons_task_id_not_null NOT NULL,
    birth_date date,
    blood_type character varying(8),
    gender smallint CONSTRAINT prs_persons_gender_not_null NOT NULL,
    military_status smallint,
    marital_status smallint CONSTRAINT prs_persons_marital_status_not_null NOT NULL,
    child smallint DEFAULT 0 NOT NULL,
    relative_name character varying(48),
    relative_phone character varying(24),
    shoe_size smallint,
    clothing_size character varying(8),
    notes character varying(256),
    emp_transportation_id bigint,
    special_notes character varying(256),
    salary_amount numeric(18,2) DEFAULT 0 NOT NULL,
    bonus_count integer DEFAULT 0 NOT NULL,
    bonus_amount numeric(18,2) DEFAULT 0 NOT NULL,
    id_document_no text,
    active boolean DEFAULT false CONSTRAINT prs_persons_active_not_null NOT NULL,
    CONSTRAINT emp_employee_blood_type_chk CHECK (((blood_type IS NULL) OR ((blood_type)::text = ANY (ARRAY[('A Rh+'::character varying)::text, ('A Rh-'::character varying)::text, ('B Rh+'::character varying)::text, ('B Rh-'::character varying)::text, ('AB Rh+'::character varying)::text, ('AB Rh-'::character varying)::text, ('0 Rh+'::character varying)::text, ('0 Rh-'::character varying)::text])))),
    CONSTRAINT emp_employee_bonus_count_chk CHECK (((bonus_count >= 0) AND (bonus_count <= 30))),
    CONSTRAINT emp_employee_child_chk CHECK (((child >= 0) AND (child <= 30))),
    CONSTRAINT emp_employee_clothing_size_chk CHECK (((clothing_size IS NULL) OR ((clothing_size)::text = ANY (ARRAY[('XXS'::character varying)::text, ('XS'::character varying)::text, ('S'::character varying)::text, ('M'::character varying)::text, ('L'::character varying)::text, ('XL'::character varying)::text, ('XXL'::character varying)::text, ('3XL'::character varying)::text, ('4XL'::character varying)::text, ('5XL'::character varying)::text])))),
    CONSTRAINT emp_employee_gender_chk CHECK (((gender >= 1) AND (gender <= 2))),
    CONSTRAINT emp_employee_marital_status_chk CHECK (((marital_status >= 1) AND (marital_status <= 2))),
    CONSTRAINT emp_employee_military_status_chk CHECK (((military_status IS NULL) OR ((military_status >= 1) AND (military_status <= 3))))
);


ALTER TABLE public.emp_employee OWNER TO ths_admin;

--
-- Name: COLUMN emp_employee.gender; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.emp_employee.gender IS '1 Man, 2 Woman';


--
-- Name: COLUMN emp_employee.military_status; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.emp_employee.military_status IS '1 Did, 2 Exempt, 3 Did Not';


--
-- Name: COLUMN emp_employee.marital_status; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.emp_employee.marital_status IS '1 Married, 2 Single';


--
-- Name: emp_language; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_language (
    id bigint CONSTRAINT prs_set_lng_id_nn NOT NULL,
    language_name character varying(16) CONSTRAINT prs_set_lng_nname_nn NOT NULL
);


ALTER TABLE public.emp_language OWNER TO ths_admin;

--
-- Name: emp_person_address; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_person_address (
    id bigint NOT NULL,
    emp_employee_id bigint CONSTRAINT emp_person_address_person_id_not_null NOT NULL,
    sys_address_id bigint CONSTRAINT emp_person_address_address_id_not_null NOT NULL,
    address_type character varying(16) NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    valid_from date,
    valid_to date
);


ALTER TABLE public.emp_person_address OWNER TO ths_admin;

--
-- Name: COLUMN emp_person_address.address_type; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.emp_person_address.address_type IS 'HOME, WORK, MAILING, LEGAL, OTHER';


--
-- Name: emp_person_address_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.emp_person_address ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.emp_person_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: emp_person_language_ability; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_person_language_ability (
    id bigint CONSTRAINT prs_language_abilities_id_not_null NOT NULL,
    emp_language_id bigint NOT NULL,
    emp_employee_id bigint NOT NULL,
    read_level smallint NOT NULL,
    write_level smallint NOT NULL,
    speak_level smallint NOT NULL,
    CONSTRAINT emp_person_language_ability_read_level_chk CHECK (((read_level >= 1) AND (read_level <= 4))),
    CONSTRAINT emp_person_language_ability_speak_level_chk CHECK (((speak_level >= 1) AND (speak_level <= 4))),
    CONSTRAINT emp_person_language_ability_write_level_chk CHECK (((write_level >= 1) AND (write_level <= 4)))
);


ALTER TABLE public.emp_person_language_ability OWNER TO ths_admin;

--
-- Name: emp_person_type; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_person_type (
    id bigint CONSTRAINT prs_set_ptp_id_nn NOT NULL,
    person_type_key character varying(32) CONSTRAINT prs_set_ptp_pname_nn NOT NULL
);


ALTER TABLE public.emp_person_type OWNER TO ths_admin;

--
-- Name: emp_person_type_translation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_person_type_translation (
    emp_person_type_id bigint NOT NULL,
    sys_language_id bigint NOT NULL,
    name character varying(64) CONSTRAINT emp_person_type_translation_person_type_not_null NOT NULL
);


ALTER TABLE public.emp_person_type_translation OWNER TO ths_admin;

--
-- Name: emp_section; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_section (
    id bigint CONSTRAINT prs_set_sec_id_nn NOT NULL,
    section_key character varying(32) CONSTRAINT prs_set_sec_nname_nn NOT NULL
);


ALTER TABLE public.emp_section OWNER TO ths_admin;

--
-- Name: emp_section_translation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_section_translation (
    emp_section_id bigint NOT NULL,
    sys_language_id bigint NOT NULL,
    name character varying(64) CONSTRAINT emp_section_translation_section_name_not_null NOT NULL
);


ALTER TABLE public.emp_section_translation OWNER TO ths_admin;

--
-- Name: emp_task; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_task (
    id bigint CONSTRAINT prs_set_tsk_id_nn NOT NULL,
    task_key character varying(32) CONSTRAINT prs_set_tsk_nname_nn NOT NULL
);


ALTER TABLE public.emp_task OWNER TO ths_admin;

--
-- Name: emp_task_translation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_task_translation (
    emp_task_id bigint NOT NULL,
    sys_language_id bigint NOT NULL,
    name character varying(64) CONSTRAINT emp_task_translation_task_name_not_null NOT NULL
);


ALTER TABLE public.emp_task_translation OWNER TO ths_admin;

--
-- Name: emp_transportation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_transportation (
    id bigint CONSTRAINT prs_set_trans_id_nn NOT NULL,
    car_no smallint CONSTRAINT prs_set_trans_cno_nn NOT NULL,
    car_name character varying(32) CONSTRAINT prs_set_trans_cname_nn NOT NULL,
    route_description character varying(512)
);


ALTER TABLE public.emp_transportation OWNER TO ths_admin;

--
-- Name: emp_unit; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_unit (
    id bigint CONSTRAINT prs_set_unit_id_nn NOT NULL,
    unit_key character varying(32) CONSTRAINT prs_set_unit_nname_nn NOT NULL,
    emp_section_id bigint
);


ALTER TABLE public.emp_unit OWNER TO ths_admin;

--
-- Name: emp_unit_translation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_unit_translation (
    emp_unit_id bigint NOT NULL,
    sys_language_id bigint NOT NULL,
    name character varying(64) CONSTRAINT emp_unit_translation_unit_name_not_null NOT NULL
);


ALTER TABLE public.emp_unit_translation OWNER TO ths_admin;

--
-- Name: fin_cheque_note; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.fin_cheque_note (
    id bigint NOT NULL,
    doc_kind smallint NOT NULL,
    direction smallint NOT NULL,
    portfolio_no character varying(16) NOT NULL,
    serial_no character varying(32) NOT NULL,
    issue_date date DEFAULT CURRENT_DATE NOT NULL,
    due_date date NOT NULL,
    amount numeric(18,2) NOT NULL,
    currency character varying(3) DEFAULT public.fn_default_currency() NOT NULL,
    acc_account_id bigint NOT NULL,
    drawer_name character varying(128),
    drawer_tax_no character varying(16),
    issue_place character varying(64),
    acc_bank_id bigint,
    acc_bank_branch_id bigint,
    bank_account_no character varying(32),
    guarantor_name character varying(128),
    status smallint DEFAULT 1 NOT NULL,
    notes character varying(512),
    fin_company_bank_account_id bigint,
    CONSTRAINT fin_cheque_note_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT fin_cheque_note_bank_check CHECK (((doc_kind = 2) OR (acc_bank_id IS NOT NULL))),
    CONSTRAINT fin_cheque_note_company_bank_account_check CHECK (((fin_company_bank_account_id IS NULL) OR (direction = 2))),
    CONSTRAINT fin_cheque_note_direction_check CHECK ((direction = ANY (ARRAY[1, 2]))),
    CONSTRAINT fin_cheque_note_doc_kind_check CHECK ((doc_kind = ANY (ARRAY[1, 2]))),
    CONSTRAINT fin_cheque_note_due_date_check CHECK ((due_date >= issue_date)),
    CONSTRAINT fin_cheque_note_status_check CHECK (((status >= 1) AND (status <= 9)))
);


ALTER TABLE public.fin_cheque_note OWNER TO ths_admin;

--
-- Name: fin_cheque_note_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.fin_cheque_note ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fin_cheque_note_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fin_cheque_note_transaction; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.fin_cheque_note_transaction (
    id bigint NOT NULL,
    fin_cheque_note_id bigint NOT NULL,
    transaction_date date DEFAULT CURRENT_DATE NOT NULL,
    transaction_type smallint NOT NULL,
    acc_account_id bigint,
    acc_bank_id bigint,
    description character varying(256),
    CONSTRAINT fin_cheque_note_transaction_account_check CHECK (((transaction_type <> ALL (ARRAY[2, 9])) OR (acc_account_id IS NOT NULL))),
    CONSTRAINT fin_cheque_note_transaction_bank_check CHECK (((transaction_type <> ALL (ARRAY[3, 4])) OR (acc_bank_id IS NOT NULL))),
    CONSTRAINT fin_cheque_note_transaction_type_check CHECK (((transaction_type >= 1) AND (transaction_type <= 9)))
);


ALTER TABLE public.fin_cheque_note_transaction OWNER TO ths_admin;

--
-- Name: fin_cheque_note_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.fin_cheque_note_transaction ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fin_cheque_note_transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fin_company_bank_account; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.fin_company_bank_account (
    id bigint NOT NULL,
    acc_bank_id bigint NOT NULL,
    branch_code character varying(16),
    branch_name character varying(64),
    sys_city_id bigint,
    account_no character varying(32),
    iban character varying(34) NOT NULL,
    currency character varying(3) DEFAULT public.fn_default_currency() NOT NULL,
    account_holder character varying(128),
    show_on_cheque boolean DEFAULT false NOT NULL,
    show_on_note boolean DEFAULT false NOT NULL,
    show_on_print boolean DEFAULT true NOT NULL,
    sort_order smallint DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    description character varying(256),
    CONSTRAINT fin_company_bank_account_iban_check CHECK (((iban)::text ~ '^[A-Z]{2}[0-9]{2}[A-Z0-9]{11,30}$'::text)),
    CONSTRAINT fin_company_bank_account_sort_check CHECK (((sort_order >= 0) AND (sort_order <= 999)))
);


ALTER TABLE public.fin_company_bank_account OWNER TO ths_admin;

--
-- Name: fin_company_bank_account_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.fin_company_bank_account ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fin_company_bank_account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fin_credit_card; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.fin_credit_card (
    id bigint NOT NULL,
    card_name character varying(64) NOT NULL,
    acc_bank_id bigint NOT NULL,
    card_holder character varying(128),
    card_last_digits character varying(4),
    card_limit numeric(18,2) DEFAULT 0 NOT NULL,
    statement_day smallint,
    payment_day smallint,
    currency character varying(3) DEFAULT public.fn_default_currency() NOT NULL,
    acc_account_code character varying(16),
    is_active boolean DEFAULT true NOT NULL,
    notes character varying(512),
    CONSTRAINT fin_credit_card_last_digits_check CHECK (((card_last_digits IS NULL) OR ((card_last_digits)::text ~ '^[0-9]{4}$'::text))),
    CONSTRAINT fin_credit_card_limit_check CHECK ((card_limit >= (0)::numeric)),
    CONSTRAINT fin_credit_card_payment_day_check CHECK (((payment_day IS NULL) OR ((payment_day >= 1) AND (payment_day <= 31)))),
    CONSTRAINT fin_credit_card_statement_day_check CHECK (((statement_day IS NULL) OR ((statement_day >= 1) AND (statement_day <= 31))))
);


ALTER TABLE public.fin_credit_card OWNER TO ths_admin;

--
-- Name: fin_credit_card_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.fin_credit_card ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fin_credit_card_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fin_credit_card_transaction; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.fin_credit_card_transaction (
    id bigint NOT NULL,
    fin_credit_card_id bigint NOT NULL,
    transaction_date date DEFAULT CURRENT_DATE NOT NULL,
    transaction_type smallint NOT NULL,
    acc_account_id bigint,
    amount numeric(18,2) NOT NULL,
    installment_count smallint DEFAULT 1 NOT NULL,
    description character varying(256),
    CONSTRAINT fin_credit_card_transaction_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT fin_credit_card_transaction_installment_check CHECK (((installment_count >= 1) AND (installment_count <= 36) AND ((transaction_type = 1) OR (installment_count = 1)))),
    CONSTRAINT fin_credit_card_transaction_type_check CHECK (((transaction_type >= 1) AND (transaction_type <= 3)))
);


ALTER TABLE public.fin_credit_card_transaction OWNER TO ths_admin;

--
-- Name: fin_credit_card_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.fin_credit_card_transaction ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fin_credit_card_transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fin_money_account; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.fin_money_account (
    id bigint NOT NULL,
    account_kind smallint NOT NULL,
    code character varying(16) NOT NULL,
    name character varying(64) NOT NULL,
    acc_bank_id bigint,
    acc_bank_branch_id bigint,
    account_no character varying(32),
    iban character varying(34),
    currency character varying(3) DEFAULT public.fn_default_currency() NOT NULL,
    acc_account_code character varying(16),
    is_active boolean DEFAULT true NOT NULL,
    notes character varying(512),
    CONSTRAINT fin_money_account_bank_check CHECK (((account_kind = 1) OR (acc_bank_id IS NOT NULL))),
    CONSTRAINT fin_money_account_cash_check CHECK (((account_kind = 2) OR ((acc_bank_id IS NULL) AND (acc_bank_branch_id IS NULL) AND (account_no IS NULL) AND (iban IS NULL)))),
    CONSTRAINT fin_money_account_iban_check CHECK (((iban IS NULL) OR ((iban)::text ~ '^[A-Z]{2}[0-9]{2}[A-Z0-9]{11,30}$'::text))),
    CONSTRAINT fin_money_account_kind_check CHECK ((account_kind = ANY (ARRAY[1, 2])))
);


ALTER TABLE public.fin_money_account OWNER TO ths_admin;

--
-- Name: fin_money_account_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.fin_money_account ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fin_money_account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fin_money_transaction; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.fin_money_transaction (
    id bigint NOT NULL,
    fin_money_account_id bigint NOT NULL,
    transaction_date date DEFAULT CURRENT_DATE NOT NULL,
    transaction_type smallint NOT NULL,
    transfer_method smallint,
    acc_account_id bigint,
    target_fin_money_account_id bigint,
    amount numeric(18,2) NOT NULL,
    document_no character varying(32),
    counterparty_name character varying(128),
    counterparty_iban character varying(34),
    description character varying(256),
    CONSTRAINT fin_money_transaction_account_check CHECK (((transaction_type <> ALL (ARRAY[1, 2])) OR (acc_account_id IS NOT NULL))),
    CONSTRAINT fin_money_transaction_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT fin_money_transaction_iban_check CHECK (((counterparty_iban IS NULL) OR ((counterparty_iban)::text ~ '^[A-Z]{2}[0-9]{2}[A-Z0-9]{11,30}$'::text))),
    CONSTRAINT fin_money_transaction_method_check CHECK (((transfer_method IS NULL) OR ((transfer_method >= 1) AND (transfer_method <= 5)))),
    CONSTRAINT fin_money_transaction_self_check CHECK (((target_fin_money_account_id IS NULL) OR (target_fin_money_account_id <> fin_money_account_id))),
    CONSTRAINT fin_money_transaction_target_check CHECK (((transaction_type = 3) = (target_fin_money_account_id IS NOT NULL))),
    CONSTRAINT fin_money_transaction_type_check CHECK (((transaction_type >= 1) AND (transaction_type <= 7)))
);


ALTER TABLE public.fin_money_transaction OWNER TO ths_admin;

--
-- Name: fin_money_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.fin_money_transaction ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fin_money_transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fin_pos_terminal; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.fin_pos_terminal (
    id bigint NOT NULL,
    pos_name character varying(64) NOT NULL,
    acc_bank_id bigint NOT NULL,
    terminal_no character varying(32),
    commission_rate numeric(5,2) DEFAULT 0 NOT NULL,
    blocked_days smallint DEFAULT 0 NOT NULL,
    currency character varying(3) DEFAULT public.fn_default_currency() NOT NULL,
    acc_account_code character varying(16),
    is_active boolean DEFAULT true NOT NULL,
    notes character varying(512),
    CONSTRAINT fin_pos_terminal_blocked_days_check CHECK (((blocked_days >= 0) AND (blocked_days <= 365))),
    CONSTRAINT fin_pos_terminal_commission_rate_check CHECK (((commission_rate >= (0)::numeric) AND (commission_rate <= (100)::numeric)))
);


ALTER TABLE public.fin_pos_terminal OWNER TO ths_admin;

--
-- Name: fin_pos_terminal_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.fin_pos_terminal ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fin_pos_terminal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fin_pos_transaction; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.fin_pos_transaction (
    id bigint NOT NULL,
    fin_pos_terminal_id bigint NOT NULL,
    transaction_date date DEFAULT CURRENT_DATE NOT NULL,
    transaction_type smallint NOT NULL,
    acc_account_id bigint NOT NULL,
    amount numeric(18,2) NOT NULL,
    installment_count smallint DEFAULT 1 NOT NULL,
    commission_rate numeric(5,2) DEFAULT 0 NOT NULL,
    commission_amount numeric(18,2) DEFAULT 0 NOT NULL,
    net_amount numeric(18,2) DEFAULT 0 NOT NULL,
    value_date date NOT NULL,
    card_holder character varying(128),
    card_last_digits character varying(4),
    description character varying(256),
    CONSTRAINT fin_pos_transaction_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT fin_pos_transaction_commission_amount_check CHECK (((commission_amount >= (0)::numeric) AND (commission_amount <= amount))),
    CONSTRAINT fin_pos_transaction_commission_rate_check CHECK (((commission_rate >= (0)::numeric) AND (commission_rate <= (100)::numeric))),
    CONSTRAINT fin_pos_transaction_installment_check CHECK (((installment_count >= 1) AND (installment_count <= 36))),
    CONSTRAINT fin_pos_transaction_last_digits_check CHECK (((card_last_digits IS NULL) OR ((card_last_digits)::text ~ '^[0-9]{4}$'::text))),
    CONSTRAINT fin_pos_transaction_net_amount_check CHECK ((net_amount = (amount - commission_amount))),
    CONSTRAINT fin_pos_transaction_type_check CHECK ((transaction_type = ANY (ARRAY[1, 2]))),
    CONSTRAINT fin_pos_transaction_value_date_check CHECK ((value_date >= transaction_date))
);


ALTER TABLE public.fin_pos_transaction OWNER TO ths_admin;

--
-- Name: fin_pos_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.fin_pos_transaction ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fin_pos_transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: mhs_exchange_rate_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.acc_exchange_rate ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_exchange_rate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: mhs_transfer_code_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.acc_transfer_code ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_transfer_code_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: mhs_voucher_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.acc_voucher_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_voucher_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: mhs_voucher_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.acc_voucher ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_voucher_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prd_bom; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_bom (
    id bigint NOT NULL,
    stk_inventory_id bigint NOT NULL,
    bom_name character varying(128) NOT NULL,
    base_quantity numeric(18,6) DEFAULT 1 NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    description character varying(256),
    CONSTRAINT prd_bom_base_quantity_check CHECK ((base_quantity > (0)::numeric))
);


ALTER TABLE public.prd_bom OWNER TO ths_admin;

--
-- Name: COLUMN prd_bom.base_quantity; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.prd_bom.base_quantity IS 'Satır miktarlarının karşılık geldiği mamul miktarı';


--
-- Name: COLUMN prd_bom.is_default; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.prd_bom.is_default IS 'Ürünün varsayılan reçetesi (ürün başına tek)';


--
-- Name: prd_bom_by_product; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_bom_by_product (
    id bigint NOT NULL,
    prd_bom_id bigint NOT NULL,
    stk_inventory_id bigint NOT NULL,
    quantity numeric(18,6) NOT NULL,
    line_no smallint NOT NULL,
    CONSTRAINT prd_bom_by_product_quantity_check CHECK ((quantity > (0)::numeric))
);


ALTER TABLE public.prd_bom_by_product OWNER TO ths_admin;

--
-- Name: prd_bom_by_product_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_bom_by_product ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prd_bom_by_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prd_bom_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_bom ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prd_bom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prd_bom_labour; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_bom_labour (
    id bigint NOT NULL,
    prd_bom_id bigint NOT NULL,
    prd_labour_id bigint NOT NULL,
    quantity numeric(18,6) NOT NULL,
    line_no smallint NOT NULL,
    CONSTRAINT prd_bom_labour_quantity_check CHECK ((quantity > (0)::numeric))
);


ALTER TABLE public.prd_bom_labour OWNER TO ths_admin;

--
-- Name: prd_bom_labour_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_bom_labour ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prd_bom_labour_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prd_bom_packet_labour; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_bom_packet_labour (
    id bigint NOT NULL,
    prd_bom_id bigint NOT NULL,
    prd_packet_labour_id bigint NOT NULL,
    quantity numeric(18,6) DEFAULT 1 NOT NULL,
    line_no smallint NOT NULL,
    CONSTRAINT prd_bom_packet_labour_quantity_check CHECK ((quantity > (0)::numeric))
);


ALTER TABLE public.prd_bom_packet_labour OWNER TO ths_admin;

--
-- Name: prd_bom_packet_labour_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_bom_packet_labour ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prd_bom_packet_labour_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prd_bom_packet_raw; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_bom_packet_raw (
    id bigint NOT NULL,
    prd_bom_id bigint NOT NULL,
    prd_packet_raw_id bigint NOT NULL,
    quantity numeric(18,6) DEFAULT 1 NOT NULL,
    line_no smallint NOT NULL,
    CONSTRAINT prd_bom_packet_raw_quantity_check CHECK ((quantity > (0)::numeric))
);


ALTER TABLE public.prd_bom_packet_raw OWNER TO ths_admin;

--
-- Name: prd_bom_packet_raw_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_bom_packet_raw ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prd_bom_packet_raw_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prd_bom_raw; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_bom_raw (
    id bigint NOT NULL,
    prd_bom_id bigint NOT NULL,
    stk_inventory_id bigint NOT NULL,
    sub_prd_bom_id bigint,
    quantity numeric(18,6) NOT NULL,
    scrap_rate numeric(5,2) DEFAULT 0 NOT NULL,
    line_no smallint NOT NULL,
    CONSTRAINT prd_bom_raw_not_self_check CHECK (((sub_prd_bom_id IS NULL) OR (sub_prd_bom_id <> prd_bom_id))),
    CONSTRAINT prd_bom_raw_quantity_check CHECK ((quantity > (0)::numeric)),
    CONSTRAINT prd_bom_raw_scrap_rate_check CHECK (((scrap_rate >= (0)::numeric) AND (scrap_rate < (100)::numeric)))
);


ALTER TABLE public.prd_bom_raw OWNER TO ths_admin;

--
-- Name: COLUMN prd_bom_raw.sub_prd_bom_id; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.prd_bom_raw.sub_prd_bom_id IS 'Yarı mamul hammaddenin kullanılacak reçetesi (opsiyonel)';


--
-- Name: COLUMN prd_bom_raw.scrap_rate; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.prd_bom_raw.scrap_rate IS 'Fire oranı (%)';


--
-- Name: prd_bom_raw_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_bom_raw ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prd_bom_raw_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prd_labour; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_labour (
    id bigint NOT NULL,
    code character varying(16) NOT NULL,
    name character varying(128) NOT NULL,
    cost_type smallint DEFAULT 1 NOT NULL,
    sys_uom_id bigint NOT NULL,
    unit_price numeric(18,6) DEFAULT 0 NOT NULL,
    currency character varying(3) DEFAULT public.fn_default_currency() NOT NULL,
    acc_account_code character varying(16),
    CONSTRAINT prd_labour_cost_type_check CHECK (((cost_type >= 1) AND (cost_type <= 3))),
    CONSTRAINT prd_labour_unit_price_check CHECK ((unit_price >= (0)::numeric))
);


ALTER TABLE public.prd_labour OWNER TO ths_admin;

--
-- Name: COLUMN prd_labour.cost_type; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.prd_labour.cost_type IS '1 işçilik / 2 makine / 3 genel üretim gideri';


--
-- Name: COLUMN prd_labour.acc_account_code; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.prd_labour.acc_account_code IS 'Maliyetin yazılacağı gider hesabı (opsiyonel)';


--
-- Name: prd_labour_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_labour ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prd_labour_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prd_packet_labour; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_packet_labour (
    id bigint NOT NULL,
    packet_name character varying(128) NOT NULL
);


ALTER TABLE public.prd_packet_labour OWNER TO ths_admin;

--
-- Name: prd_packet_labour_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_packet_labour_detail (
    id bigint NOT NULL,
    prd_packet_labour_id bigint NOT NULL,
    prd_labour_id bigint NOT NULL,
    quantity numeric(18,6) NOT NULL,
    line_no smallint NOT NULL,
    CONSTRAINT prd_packet_labour_detail_quantity_check CHECK ((quantity > (0)::numeric))
);


ALTER TABLE public.prd_packet_labour_detail OWNER TO ths_admin;

--
-- Name: prd_packet_labour_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_packet_labour_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prd_packet_labour_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prd_packet_labour_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_packet_labour ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prd_packet_labour_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prd_packet_raw; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_packet_raw (
    id bigint NOT NULL,
    packet_name character varying(128) NOT NULL
);


ALTER TABLE public.prd_packet_raw OWNER TO ths_admin;

--
-- Name: prd_packet_raw_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_packet_raw_detail (
    id bigint NOT NULL,
    prd_packet_raw_id bigint NOT NULL,
    stk_inventory_id bigint NOT NULL,
    sub_prd_bom_id bigint,
    quantity numeric(18,6) NOT NULL,
    line_no smallint NOT NULL,
    CONSTRAINT prd_packet_raw_detail_quantity_check CHECK ((quantity > (0)::numeric))
);


ALTER TABLE public.prd_packet_raw_detail OWNER TO ths_admin;

--
-- Name: prd_packet_raw_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_packet_raw_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prd_packet_raw_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prd_packet_raw_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_packet_raw ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prd_packet_raw_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prs_lisan_bilgisi_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.emp_person_language_ability ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_lisan_bilgisi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prs_personel_ehliyetleri_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.emp_driver_ability ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_personel_ehliyetleri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prs_personel_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.emp_employee ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_personel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prs_set_language_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.emp_language ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_set_language_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prs_set_license_type_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.emp_driver_license_type ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_set_license_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prs_set_person_type_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.emp_person_type ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_set_person_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prs_set_section_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.emp_section ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_set_section_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prs_set_task_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.emp_task ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_set_task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prs_set_transport_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.emp_transportation ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_set_transport_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prs_set_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.emp_unit ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_set_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pur_invoice; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.pur_invoice (
    id bigint NOT NULL,
    invoice_no character varying(32) NOT NULL,
    invoice_date date DEFAULT CURRENT_DATE NOT NULL,
    acc_account_id bigint NOT NULL,
    due_date date,
    currency character varying(3) DEFAULT public.fn_default_currency() NOT NULL,
    exchange_rate numeric(18,6) DEFAULT 1 NOT NULL,
    gross_amount numeric(18,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(18,2) DEFAULT 0 NOT NULL,
    net_amount numeric(18,2) DEFAULT 0 NOT NULL,
    vat_amount numeric(18,2) DEFAULT 0 NOT NULL,
    total_amount numeric(18,2) DEFAULT 0 NOT NULL,
    description character varying(256),
    account_title character varying(128),
    taxpayer_type smallint,
    taxpayer_name character varying(32),
    taxpayer_name2 character varying(32),
    taxpayer_surname character varying(32),
    tax_office character varying(64),
    tax_no character varying(32),
    CONSTRAINT pur_invoice_due_date_check CHECK (((due_date IS NULL) OR (due_date >= invoice_date))),
    CONSTRAINT pur_invoice_exchange_rate_check CHECK ((exchange_rate > (0)::numeric)),
    CONSTRAINT pur_invoice_taxpayer_type_check CHECK (((taxpayer_type IS NULL) OR (taxpayer_type = ANY (ARRAY[1, 2]))))
);


ALTER TABLE public.pur_invoice OWNER TO ths_admin;

--
-- Name: pur_invoice_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.pur_invoice_detail (
    id bigint NOT NULL,
    pur_invoice_id bigint NOT NULL,
    line_no smallint NOT NULL,
    stk_inventory_id bigint NOT NULL,
    quantity numeric(18,6) NOT NULL,
    unit_price numeric(18,6) DEFAULT 0 NOT NULL,
    discount_rate numeric(5,2) DEFAULT 0 NOT NULL,
    vat_rate numeric(5,2) DEFAULT 0 NOT NULL,
    gross_amount numeric(18,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(18,2) DEFAULT 0 NOT NULL,
    net_amount numeric(18,2) DEFAULT 0 NOT NULL,
    vat_amount numeric(18,2) DEFAULT 0 NOT NULL,
    total_amount numeric(18,2) DEFAULT 0 NOT NULL,
    pur_receipt_detail_id bigint,
    description character varying(128),
    CONSTRAINT pur_invoice_detail_discount_check CHECK (((discount_rate >= (0)::numeric) AND (discount_rate <= (100)::numeric))),
    CONSTRAINT pur_invoice_detail_price_check CHECK ((unit_price >= (0)::numeric)),
    CONSTRAINT pur_invoice_detail_quantity_check CHECK ((quantity > (0)::numeric)),
    CONSTRAINT pur_invoice_detail_vat_check CHECK (((vat_rate >= (0)::numeric) AND (vat_rate <= (100)::numeric)))
);


ALTER TABLE public.pur_invoice_detail OWNER TO ths_admin;

--
-- Name: pur_invoice_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.pur_invoice_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pur_invoice_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pur_invoice_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.pur_invoice ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pur_invoice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pur_invoice_tax_summary; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.pur_invoice_tax_summary (
    id bigint NOT NULL,
    pur_invoice_id bigint NOT NULL,
    summary_type smallint NOT NULL,
    tax_rate numeric(5,2) NOT NULL,
    einv_withholding_id bigint,
    base_amount numeric(18,2) DEFAULT 0 NOT NULL,
    tax_amount numeric(18,2) DEFAULT 0 NOT NULL,
    CONSTRAINT pur_invoice_tax_summary_type_check CHECK ((summary_type = ANY (ARRAY[1, 2]))),
    CONSTRAINT pur_invoice_tax_summary_withholding_check CHECK (((summary_type = 2) = (einv_withholding_id IS NOT NULL)))
);


ALTER TABLE public.pur_invoice_tax_summary OWNER TO ths_admin;

--
-- Name: pur_invoice_tax_summary_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.pur_invoice_tax_summary ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pur_invoice_tax_summary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pur_order; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.pur_order (
    id bigint NOT NULL,
    order_no character varying(16) NOT NULL,
    order_date date DEFAULT CURRENT_DATE NOT NULL,
    acc_account_id bigint NOT NULL,
    supplier_ref_no character varying(32),
    delivery_date date,
    stk_warehouse_id bigint,
    currency character varying(3) DEFAULT public.fn_default_currency() NOT NULL,
    exchange_rate numeric(18,6) DEFAULT 1 NOT NULL,
    payment_term_days smallint DEFAULT 0 NOT NULL,
    status smallint DEFAULT 1 NOT NULL,
    gross_amount numeric(18,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(18,2) DEFAULT 0 NOT NULL,
    net_amount numeric(18,2) DEFAULT 0 NOT NULL,
    vat_amount numeric(18,2) DEFAULT 0 NOT NULL,
    total_amount numeric(18,2) DEFAULT 0 NOT NULL,
    description character varying(256),
    account_title character varying(128),
    taxpayer_type smallint,
    taxpayer_name character varying(32),
    taxpayer_name2 character varying(32),
    taxpayer_surname character varying(32),
    tax_office character varying(64),
    tax_no character varying(32),
    CONSTRAINT pur_order_delivery_date_check CHECK (((delivery_date IS NULL) OR (delivery_date >= order_date))),
    CONSTRAINT pur_order_exchange_rate_check CHECK ((exchange_rate > (0)::numeric)),
    CONSTRAINT pur_order_payment_term_check CHECK (((payment_term_days >= 0) AND (payment_term_days <= 365))),
    CONSTRAINT pur_order_status_check CHECK (((status >= 1) AND (status <= 5))),
    CONSTRAINT pur_order_taxpayer_type_check CHECK (((taxpayer_type IS NULL) OR (taxpayer_type = ANY (ARRAY[1, 2]))))
);


ALTER TABLE public.pur_order OWNER TO ths_admin;

--
-- Name: pur_order_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.pur_order_detail (
    id bigint NOT NULL,
    pur_order_id bigint NOT NULL,
    line_no smallint NOT NULL,
    stk_inventory_id bigint NOT NULL,
    quantity numeric(18,6) NOT NULL,
    unit_price numeric(18,6) DEFAULT 0 NOT NULL,
    discount_rate numeric(5,2) DEFAULT 0 NOT NULL,
    vat_rate numeric(5,2) DEFAULT 0 NOT NULL,
    gross_amount numeric(18,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(18,2) DEFAULT 0 NOT NULL,
    net_amount numeric(18,2) DEFAULT 0 NOT NULL,
    vat_amount numeric(18,2) DEFAULT 0 NOT NULL,
    total_amount numeric(18,2) DEFAULT 0 NOT NULL,
    received_quantity numeric(18,6) DEFAULT 0 NOT NULL,
    delivery_date date,
    pur_request_detail_id bigint,
    description character varying(128),
    CONSTRAINT pur_order_detail_discount_check CHECK (((discount_rate >= (0)::numeric) AND (discount_rate <= (100)::numeric))),
    CONSTRAINT pur_order_detail_price_check CHECK ((unit_price >= (0)::numeric)),
    CONSTRAINT pur_order_detail_quantity_check CHECK ((quantity > (0)::numeric)),
    CONSTRAINT pur_order_detail_received_check CHECK ((received_quantity >= (0)::numeric)),
    CONSTRAINT pur_order_detail_vat_check CHECK (((vat_rate >= (0)::numeric) AND (vat_rate <= (100)::numeric)))
);


ALTER TABLE public.pur_order_detail OWNER TO ths_admin;

--
-- Name: pur_order_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.pur_order_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pur_order_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pur_order_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.pur_order ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pur_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pur_order_tax_summary; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.pur_order_tax_summary (
    id bigint NOT NULL,
    pur_order_id bigint NOT NULL,
    summary_type smallint NOT NULL,
    tax_rate numeric(5,2) NOT NULL,
    einv_withholding_id bigint,
    base_amount numeric(18,2) DEFAULT 0 NOT NULL,
    tax_amount numeric(18,2) DEFAULT 0 NOT NULL,
    CONSTRAINT pur_order_tax_summary_type_check CHECK ((summary_type = ANY (ARRAY[1, 2]))),
    CONSTRAINT pur_order_tax_summary_withholding_check CHECK (((summary_type = 2) = (einv_withholding_id IS NOT NULL)))
);


ALTER TABLE public.pur_order_tax_summary OWNER TO ths_admin;

--
-- Name: pur_order_tax_summary_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.pur_order_tax_summary ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pur_order_tax_summary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pur_quotation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.pur_quotation (
    id bigint NOT NULL,
    quotation_no character varying(16) NOT NULL,
    quotation_date date DEFAULT CURRENT_DATE NOT NULL,
    pur_request_id bigint,
    acc_account_id bigint NOT NULL,
    supplier_ref_no character varying(32),
    valid_until date,
    delivery_days smallint DEFAULT 0 NOT NULL,
    delivery_date date,
    currency character varying(3) DEFAULT public.fn_default_currency() NOT NULL,
    exchange_rate numeric(18,6) DEFAULT 1 NOT NULL,
    payment_term_days smallint DEFAULT 0 NOT NULL,
    payment_terms character varying(256),
    status smallint DEFAULT 1 NOT NULL,
    gross_amount numeric(18,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(18,2) DEFAULT 0 NOT NULL,
    net_amount numeric(18,2) DEFAULT 0 NOT NULL,
    vat_amount numeric(18,2) DEFAULT 0 NOT NULL,
    total_amount numeric(18,2) DEFAULT 0 NOT NULL,
    pur_order_id bigint,
    approved_sys_user_id bigint,
    approved_at timestamp without time zone,
    description character varying(256),
    account_title character varying(128),
    taxpayer_type smallint,
    taxpayer_name character varying(32),
    taxpayer_name2 character varying(32),
    taxpayer_surname character varying(32),
    tax_office character varying(64),
    tax_no character varying(32),
    CONSTRAINT pur_quotation_delivery_date_check CHECK (((delivery_date IS NULL) OR (delivery_date >= quotation_date))),
    CONSTRAINT pur_quotation_delivery_days_check CHECK (((delivery_days >= 0) AND (delivery_days <= 999))),
    CONSTRAINT pur_quotation_exchange_rate_check CHECK ((exchange_rate > (0)::numeric)),
    CONSTRAINT pur_quotation_order_check CHECK (((pur_order_id IS NULL) OR (status = 5))),
    CONSTRAINT pur_quotation_payment_term_check CHECK (((payment_term_days >= 0) AND (payment_term_days <= 365))),
    CONSTRAINT pur_quotation_status_check CHECK (((status >= 1) AND (status <= 6))),
    CONSTRAINT pur_quotation_taxpayer_type_check CHECK (((taxpayer_type IS NULL) OR (taxpayer_type = ANY (ARRAY[1, 2])))),
    CONSTRAINT pur_quotation_valid_until_check CHECK (((valid_until IS NULL) OR (valid_until >= quotation_date)))
);


ALTER TABLE public.pur_quotation OWNER TO ths_admin;

--
-- Name: pur_quotation_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.pur_quotation_detail (
    id bigint NOT NULL,
    pur_quotation_id bigint NOT NULL,
    line_no smallint NOT NULL,
    stk_inventory_id bigint NOT NULL,
    quantity numeric(18,6) NOT NULL,
    unit_price numeric(18,6) DEFAULT 0 NOT NULL,
    discount_rate numeric(5,2) DEFAULT 0 NOT NULL,
    vat_rate numeric(5,2) DEFAULT 0 NOT NULL,
    gross_amount numeric(18,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(18,2) DEFAULT 0 NOT NULL,
    net_amount numeric(18,2) DEFAULT 0 NOT NULL,
    vat_amount numeric(18,2) DEFAULT 0 NOT NULL,
    total_amount numeric(18,2) DEFAULT 0 NOT NULL,
    delivery_date date,
    pur_request_detail_id bigint,
    description character varying(128),
    CONSTRAINT pur_quotation_detail_discount_check CHECK (((discount_rate >= (0)::numeric) AND (discount_rate <= (100)::numeric))),
    CONSTRAINT pur_quotation_detail_price_check CHECK ((unit_price >= (0)::numeric)),
    CONSTRAINT pur_quotation_detail_quantity_check CHECK ((quantity > (0)::numeric)),
    CONSTRAINT pur_quotation_detail_vat_check CHECK (((vat_rate >= (0)::numeric) AND (vat_rate <= (100)::numeric)))
);


ALTER TABLE public.pur_quotation_detail OWNER TO ths_admin;

--
-- Name: pur_quotation_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.pur_quotation_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pur_quotation_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pur_quotation_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.pur_quotation ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pur_quotation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pur_quotation_tax_summary; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.pur_quotation_tax_summary (
    id bigint NOT NULL,
    pur_quotation_id bigint NOT NULL,
    summary_type smallint NOT NULL,
    tax_rate numeric(5,2) NOT NULL,
    einv_withholding_id bigint,
    base_amount numeric(18,2) DEFAULT 0 NOT NULL,
    tax_amount numeric(18,2) DEFAULT 0 NOT NULL,
    CONSTRAINT pur_quotation_tax_summary_type_check CHECK ((summary_type = ANY (ARRAY[1, 2]))),
    CONSTRAINT pur_quotation_tax_summary_withholding_check CHECK (((summary_type = 2) = (einv_withholding_id IS NOT NULL)))
);


ALTER TABLE public.pur_quotation_tax_summary OWNER TO ths_admin;

--
-- Name: pur_quotation_tax_summary_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.pur_quotation_tax_summary ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pur_quotation_tax_summary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pur_receipt; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.pur_receipt (
    id bigint NOT NULL,
    receipt_no character varying(16) NOT NULL,
    receipt_date date DEFAULT CURRENT_DATE NOT NULL,
    acc_account_id bigint NOT NULL,
    stk_warehouse_id bigint NOT NULL,
    waybill_no character varying(32),
    pur_order_id bigint,
    currency character varying(3) DEFAULT public.fn_default_currency() NOT NULL,
    description character varying(256),
    account_title character varying(128),
    taxpayer_type smallint,
    taxpayer_name character varying(32),
    taxpayer_name2 character varying(32),
    taxpayer_surname character varying(32),
    tax_office character varying(64),
    tax_no character varying(32),
    CONSTRAINT pur_receipt_taxpayer_type_check CHECK (((taxpayer_type IS NULL) OR (taxpayer_type = ANY (ARRAY[1, 2]))))
);


ALTER TABLE public.pur_receipt OWNER TO ths_admin;

--
-- Name: pur_receipt_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.pur_receipt_detail (
    id bigint NOT NULL,
    pur_receipt_id bigint NOT NULL,
    stk_inventory_id bigint NOT NULL,
    quantity numeric(18,6) NOT NULL,
    unit_price numeric(18,6) DEFAULT 0 NOT NULL,
    pur_order_detail_id bigint,
    description character varying(128),
    line_no smallint NOT NULL,
    CONSTRAINT pur_receipt_detail_price_check CHECK ((unit_price >= (0)::numeric)),
    CONSTRAINT pur_receipt_detail_quantity_check CHECK ((quantity > (0)::numeric))
);


ALTER TABLE public.pur_receipt_detail OWNER TO ths_admin;

--
-- Name: pur_receipt_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.pur_receipt_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pur_receipt_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pur_receipt_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.pur_receipt ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pur_receipt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pur_request; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.pur_request (
    id bigint NOT NULL,
    request_no character varying(16) NOT NULL,
    request_date date DEFAULT CURRENT_DATE NOT NULL,
    emp_employee_id bigint,
    required_date date,
    status smallint DEFAULT 1 NOT NULL,
    description character varying(256),
    CONSTRAINT pur_request_required_date_check CHECK (((required_date IS NULL) OR (required_date >= request_date))),
    CONSTRAINT pur_request_status_check CHECK (((status >= 1) AND (status <= 5)))
);


ALTER TABLE public.pur_request OWNER TO ths_admin;

--
-- Name: pur_request_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.pur_request_detail (
    id bigint NOT NULL,
    pur_request_id bigint NOT NULL,
    stk_inventory_id bigint NOT NULL,
    quantity numeric(18,6) NOT NULL,
    ordered_quantity numeric(18,6) DEFAULT 0 NOT NULL,
    required_date date,
    description character varying(128),
    line_no smallint NOT NULL,
    CONSTRAINT pur_request_detail_ordered_check CHECK ((ordered_quantity >= (0)::numeric)),
    CONSTRAINT pur_request_detail_quantity_check CHECK ((quantity > (0)::numeric))
);


ALTER TABLE public.pur_request_detail OWNER TO ths_admin;

--
-- Name: pur_request_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.pur_request_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pur_request_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pur_request_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.pur_request ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pur_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: qc_inspection; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.qc_inspection (
    id bigint NOT NULL,
    inspection_no character varying(16) NOT NULL,
    inspection_date date DEFAULT CURRENT_DATE NOT NULL,
    pur_receipt_detail_id bigint NOT NULL,
    stk_inventory_id bigint NOT NULL,
    quantity numeric(18,6) NOT NULL,
    accepted_quantity numeric(18,6) DEFAULT 0 NOT NULL,
    rejected_quantity numeric(18,6) DEFAULT 0 NOT NULL,
    result smallint NOT NULL,
    disposition smallint,
    emp_employee_id bigint,
    description character varying(256),
    CONSTRAINT qc_inspection_disposition_check CHECK ((((rejected_quantity = (0)::numeric) AND (disposition IS NULL)) OR ((rejected_quantity > (0)::numeric) AND (disposition >= 1) AND (disposition <= 4)))),
    CONSTRAINT qc_inspection_quantity_check CHECK (((quantity > (0)::numeric) AND (accepted_quantity >= (0)::numeric) AND (rejected_quantity >= (0)::numeric) AND ((accepted_quantity + rejected_quantity) = quantity))),
    CONSTRAINT qc_inspection_result_check CHECK (((result >= 1) AND (result <= 3)))
);


ALTER TABLE public.qc_inspection OWNER TO ths_admin;

--
-- Name: qc_inspection_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.qc_inspection ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.qc_inspection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: qc_rule; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.qc_rule (
    id bigint NOT NULL,
    stk_group_id bigint,
    stk_inventory_id bigint,
    is_required boolean DEFAULT true NOT NULL,
    inspection_criteria character varying(256),
    CONSTRAINT qc_rule_target_check CHECK (((stk_group_id IS NULL) <> (stk_inventory_id IS NULL)))
);


ALTER TABLE public.qc_rule OWNER TO ths_admin;

--
-- Name: qc_rule_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.qc_rule ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.qc_rule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: qc_setting; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.qc_setting (
    id bigint NOT NULL,
    sys_application_setting_id bigint NOT NULL,
    is_enabled boolean DEFAULT false NOT NULL,
    reject_stk_warehouse_id bigint,
    description character varying(256)
);


ALTER TABLE public.qc_setting OWNER TO ths_admin;

--
-- Name: qc_setting_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.qc_setting ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.qc_setting_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sls_dispatch; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_dispatch (
    id bigint NOT NULL,
    dispatch_no character varying(16) NOT NULL,
    dispatch_date date DEFAULT CURRENT_DATE NOT NULL,
    acc_account_id bigint NOT NULL,
    stk_warehouse_id bigint NOT NULL,
    sls_order_id bigint,
    currency character varying(3) DEFAULT public.fn_default_currency() NOT NULL,
    description character varying(256),
    status smallint DEFAULT 1 NOT NULL,
    einv_profile_id bigint,
    einv_uuid uuid,
    einv_status smallint,
    einv_no character varying(16),
    despatch_time time without time zone,
    carrier_acc_account_id bigint,
    einv_vehicle_id bigint,
    trailer1_einv_vehicle_id bigint,
    trailer2_einv_vehicle_id bigint,
    driver1_einv_driver_id bigint,
    driver2_einv_driver_id bigint,
    account_title character varying(128),
    taxpayer_type smallint,
    taxpayer_name character varying(32),
    taxpayer_name2 character varying(32),
    taxpayer_surname character varying(32),
    tax_office character varying(64),
    tax_no character varying(32),
    CONSTRAINT sls_dispatch_driver_check CHECK (((driver2_einv_driver_id IS NULL) OR (driver1_einv_driver_id IS NOT NULL))),
    CONSTRAINT sls_dispatch_einv_check CHECK ((((einv_profile_id IS NULL) = (einv_status IS NULL)) AND ((einv_profile_id IS NULL) = (einv_uuid IS NULL)))),
    CONSTRAINT sls_dispatch_einv_no_check CHECK (((einv_no IS NULL) OR ((einv_no)::text ~ '^[A-Z0-9]{3}[0-9]{4}[0-9]{9}$'::text))),
    CONSTRAINT sls_dispatch_einv_status_check CHECK (((einv_status >= 1) AND (einv_status <= 7))),
    CONSTRAINT sls_dispatch_status_check CHECK ((status = ANY (ARRAY[1, 2]))),
    CONSTRAINT sls_dispatch_taxpayer_type_check CHECK (((taxpayer_type IS NULL) OR (taxpayer_type = ANY (ARRAY[1, 2])))),
    CONSTRAINT sls_dispatch_trailer_check CHECK (((trailer2_einv_vehicle_id IS NULL) OR (trailer1_einv_vehicle_id IS NOT NULL)))
);


ALTER TABLE public.sls_dispatch OWNER TO ths_admin;

--
-- Name: sls_dispatch_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_dispatch_detail (
    id bigint NOT NULL,
    sls_dispatch_id bigint NOT NULL,
    stk_inventory_id bigint NOT NULL,
    quantity numeric(18,6) NOT NULL,
    unit_price numeric(18,6) DEFAULT 0 NOT NULL,
    sls_order_detail_id bigint,
    description character varying(128),
    line_no smallint NOT NULL,
    CONSTRAINT sls_dispatch_detail_price_check CHECK ((unit_price >= (0)::numeric)),
    CONSTRAINT sls_dispatch_detail_quantity_check CHECK ((quantity > (0)::numeric))
);


ALTER TABLE public.sls_dispatch_detail OWNER TO ths_admin;

--
-- Name: sls_dispatch_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sls_dispatch_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sls_dispatch_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sls_dispatch_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sls_dispatch ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sls_dispatch_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sls_invoice; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_invoice (
    id bigint NOT NULL,
    invoice_no character varying(16) NOT NULL,
    invoice_date date DEFAULT CURRENT_DATE NOT NULL,
    acc_account_id bigint NOT NULL,
    due_date date,
    stk_warehouse_id bigint,
    currency character varying(3) DEFAULT public.fn_default_currency() NOT NULL,
    exchange_rate numeric(18,6) DEFAULT 1 NOT NULL,
    gross_amount numeric(18,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(18,2) DEFAULT 0 NOT NULL,
    net_amount numeric(18,2) DEFAULT 0 NOT NULL,
    vat_amount numeric(18,2) DEFAULT 0 NOT NULL,
    total_amount numeric(18,2) DEFAULT 0 NOT NULL,
    description character varying(256),
    einv_profile_id bigint,
    einv_invoice_type_id bigint,
    einv_uuid uuid,
    einv_status smallint,
    einv_tax_exemption_id bigint,
    einv_delivery_term_id bigint,
    einv_transport_mode_id bigint,
    einv_payment_means_id bigint,
    customs_declaration_no character varying(32),
    gtb_ref_no character varying(32),
    actual_export_date date,
    withholding_amount numeric(18,2) DEFAULT 0 NOT NULL,
    einv_no character varying(16),
    account_title character varying(128),
    taxpayer_type smallint,
    taxpayer_name character varying(32),
    taxpayer_name2 character varying(32),
    taxpayer_surname character varying(32),
    tax_office character varying(64),
    tax_no character varying(32),
    CONSTRAINT sls_invoice_due_date_check CHECK (((due_date IS NULL) OR (due_date >= invoice_date))),
    CONSTRAINT sls_invoice_einv_check CHECK ((((einv_profile_id IS NULL) = (einv_invoice_type_id IS NULL)) AND ((einv_profile_id IS NULL) = (einv_status IS NULL)) AND ((einv_profile_id IS NULL) = (einv_uuid IS NULL)))),
    CONSTRAINT sls_invoice_einv_no_check CHECK (((einv_no IS NULL) OR ((einv_no)::text ~ '^[A-Z0-9]{3}[0-9]{4}[0-9]{9}$'::text))),
    CONSTRAINT sls_invoice_einv_status_check CHECK (((einv_status >= 1) AND (einv_status <= 7))),
    CONSTRAINT sls_invoice_exchange_rate_check CHECK ((exchange_rate > (0)::numeric)),
    CONSTRAINT sls_invoice_taxpayer_type_check CHECK (((taxpayer_type IS NULL) OR (taxpayer_type = ANY (ARRAY[1, 2])))),
    CONSTRAINT sls_invoice_withholding_amount_check CHECK ((withholding_amount >= (0)::numeric))
);


ALTER TABLE public.sls_invoice OWNER TO ths_admin;

--
-- Name: COLUMN sls_invoice.einv_uuid; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.sls_invoice.einv_uuid IS 'ETTN (UBL UUID); senaryo seçilince servis üretir, sonra değişmez';


--
-- Name: COLUMN sls_invoice.einv_status; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.sls_invoice.einv_status IS '1 taslak, 2 kuyrukta, 3 gönderildi, 4 kabul, 5 red, 6 hata, 7 iptal (servis / entegratör tutar)';


--
-- Name: sls_invoice_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_invoice_detail (
    id bigint NOT NULL,
    sls_invoice_id bigint NOT NULL,
    line_no smallint NOT NULL,
    stk_inventory_id bigint NOT NULL,
    quantity numeric(18,6) NOT NULL,
    unit_price numeric(18,6) DEFAULT 0 NOT NULL,
    discount_rate numeric(5,2) DEFAULT 0 NOT NULL,
    vat_rate numeric(5,2) DEFAULT 0 NOT NULL,
    gross_amount numeric(18,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(18,2) DEFAULT 0 NOT NULL,
    net_amount numeric(18,2) DEFAULT 0 NOT NULL,
    vat_amount numeric(18,2) DEFAULT 0 NOT NULL,
    total_amount numeric(18,2) DEFAULT 0 NOT NULL,
    sls_dispatch_detail_id bigint,
    sls_order_detail_id bigint,
    description character varying(128),
    einv_gtip_id bigint,
    einv_withholding_id bigint,
    withholding_amount numeric(18,2) DEFAULT 0 NOT NULL,
    seller_einv_diib_line_id bigint,
    buyer_einv_diib_line_id bigint,
    einv_packaging_type_id bigint,
    package_no character varying(32),
    package_quantity numeric(18,6),
    package_brand character varying(64),
    CONSTRAINT sls_invoice_detail_discount_check CHECK (((discount_rate >= (0)::numeric) AND (discount_rate <= (100)::numeric))),
    CONSTRAINT sls_invoice_detail_package_quantity_check CHECK (((package_quantity IS NULL) OR (package_quantity > (0)::numeric))),
    CONSTRAINT sls_invoice_detail_price_check CHECK ((unit_price >= (0)::numeric)),
    CONSTRAINT sls_invoice_detail_quantity_check CHECK ((quantity > (0)::numeric)),
    CONSTRAINT sls_invoice_detail_source_check CHECK (((sls_dispatch_detail_id IS NULL) OR (sls_order_detail_id IS NULL))),
    CONSTRAINT sls_invoice_detail_vat_check CHECK (((vat_rate >= (0)::numeric) AND (vat_rate <= (100)::numeric))),
    CONSTRAINT sls_invoice_detail_withholding_amount_check CHECK ((withholding_amount >= (0)::numeric))
);


ALTER TABLE public.sls_invoice_detail OWNER TO ths_admin;

--
-- Name: sls_invoice_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sls_invoice_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sls_invoice_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sls_invoice_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sls_invoice ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sls_invoice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sls_invoice_tax_summary; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_invoice_tax_summary (
    id bigint NOT NULL,
    sls_invoice_id bigint NOT NULL,
    summary_type smallint NOT NULL,
    tax_rate numeric(5,2) NOT NULL,
    einv_withholding_id bigint,
    base_amount numeric(18,2) DEFAULT 0 NOT NULL,
    tax_amount numeric(18,2) DEFAULT 0 NOT NULL,
    CONSTRAINT sls_invoice_tax_summary_type_check CHECK ((summary_type = ANY (ARRAY[1, 2]))),
    CONSTRAINT sls_invoice_tax_summary_withholding_check CHECK (((summary_type = 2) = (einv_withholding_id IS NOT NULL)))
);


ALTER TABLE public.sls_invoice_tax_summary OWNER TO ths_admin;

--
-- Name: sls_invoice_tax_summary_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sls_invoice_tax_summary ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sls_invoice_tax_summary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sls_offer; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_offer (
    id bigint NOT NULL,
    offer_no character varying(16) NOT NULL,
    offer_date date DEFAULT CURRENT_DATE NOT NULL,
    valid_until date,
    acc_account_id bigint NOT NULL,
    customer_ref_no character varying(32),
    emp_employee_id bigint,
    currency character varying(3) DEFAULT public.fn_default_currency() NOT NULL,
    exchange_rate numeric(18,6) DEFAULT 1 NOT NULL,
    payment_term_days smallint DEFAULT 0 NOT NULL,
    status smallint DEFAULT 1 NOT NULL,
    gross_amount numeric(18,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(18,2) DEFAULT 0 NOT NULL,
    net_amount numeric(18,2) DEFAULT 0 NOT NULL,
    vat_amount numeric(18,2) DEFAULT 0 NOT NULL,
    total_amount numeric(18,2) DEFAULT 0 NOT NULL,
    description character varying(256),
    billing_address_id bigint,
    shipping_address_id bigint,
    billing_sys_address_id bigint,
    shipping_sys_address_id bigint,
    base_currency character varying(3) DEFAULT public.fn_default_currency() NOT NULL,
    usd_rate numeric(18,6),
    eur_rate numeric(18,6),
    delivery_date date,
    einv_payment_means_id bigint,
    einv_delivery_term_id bigint,
    sale_type smallint DEFAULT 1 NOT NULL,
    account_title character varying(128),
    taxpayer_type smallint,
    taxpayer_name character varying(32),
    taxpayer_name2 character varying(32),
    taxpayer_surname character varying(32),
    tax_office character varying(64),
    tax_no character varying(32),
    CONSTRAINT sls_offer_billing_shipping_address_check CHECK (((billing_sys_address_id IS NULL) OR (shipping_sys_address_id IS NULL) OR (billing_sys_address_id <> shipping_sys_address_id))),
    CONSTRAINT sls_offer_delivery_date_check CHECK (((delivery_date IS NULL) OR (delivery_date >= offer_date))),
    CONSTRAINT sls_offer_eur_rate_check CHECK (((eur_rate IS NULL) OR (eur_rate > (0)::numeric))),
    CONSTRAINT sls_offer_exchange_rate_check CHECK ((exchange_rate > (0)::numeric)),
    CONSTRAINT sls_offer_payment_term_check CHECK (((payment_term_days >= 0) AND (payment_term_days <= 365))),
    CONSTRAINT sls_offer_sale_type_check CHECK (((sale_type >= 1) AND (sale_type <= 5))),
    CONSTRAINT sls_offer_status_check CHECK (((status >= 1) AND (status <= 5))),
    CONSTRAINT sls_offer_taxpayer_type_check CHECK (((taxpayer_type IS NULL) OR (taxpayer_type = ANY (ARRAY[1, 2])))),
    CONSTRAINT sls_offer_usd_rate_check CHECK (((usd_rate IS NULL) OR (usd_rate > (0)::numeric))),
    CONSTRAINT sls_offer_valid_until_check CHECK (((valid_until IS NULL) OR (valid_until >= offer_date)))
);


ALTER TABLE public.sls_offer OWNER TO ths_admin;

--
-- Name: COLUMN sls_offer.exchange_rate; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.sls_offer.exchange_rate IS '1 belge para birimi = exchange_rate ana para (base_currency)';


--
-- Name: COLUMN sls_offer.billing_address_id; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.sls_offer.billing_address_id IS 'Kaynak cari adresi (kopyalandığı acc_account_address)';


--
-- Name: COLUMN sls_offer.billing_sys_address_id; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.sls_offer.billing_sys_address_id IS 'Belgeye ait adres (sys_address kopyası; teklifle birlikte yazılır / silinir)';


--
-- Name: COLUMN sls_offer.shipping_sys_address_id; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.sls_offer.shipping_sys_address_id IS 'Belgeye ait teslimat adresi; boşsa fatura adresi';


--
-- Name: COLUMN sls_offer.usd_rate; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.sls_offer.usd_rate IS '1 USD = usd_rate ana para (teklif tarihi, rapor için)';


--
-- Name: COLUMN sls_offer.eur_rate; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.sls_offer.eur_rate IS '1 EUR = eur_rate ana para (teklif tarihi, rapor için)';


--
-- Name: COLUMN sls_offer.sale_type; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.sls_offer.sale_type IS '1 satis, 2 ihracat, 3 ihrac kayitli, 4 istisna, 5 tevkifatli';


--
-- Name: sls_offer_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_offer_detail (
    id bigint NOT NULL,
    sls_offer_id bigint NOT NULL,
    line_no smallint NOT NULL,
    stk_inventory_id bigint NOT NULL,
    quantity numeric(18,6) NOT NULL,
    unit_price numeric(18,6) DEFAULT 0 NOT NULL,
    discount_rate numeric(5,2) DEFAULT 0 NOT NULL,
    vat_rate numeric(5,2) DEFAULT 0 NOT NULL,
    gross_amount numeric(18,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(18,2) DEFAULT 0 NOT NULL,
    net_amount numeric(18,2) DEFAULT 0 NOT NULL,
    vat_amount numeric(18,2) DEFAULT 0 NOT NULL,
    total_amount numeric(18,2) DEFAULT 0 NOT NULL,
    ordered_quantity numeric(18,6) DEFAULT 0 NOT NULL,
    description character varying(128),
    CONSTRAINT sls_offer_detail_discount_check CHECK (((discount_rate >= (0)::numeric) AND (discount_rate <= (100)::numeric))),
    CONSTRAINT sls_offer_detail_ordered_check CHECK ((ordered_quantity >= (0)::numeric)),
    CONSTRAINT sls_offer_detail_price_check CHECK ((unit_price >= (0)::numeric)),
    CONSTRAINT sls_offer_detail_quantity_check CHECK ((quantity > (0)::numeric)),
    CONSTRAINT sls_offer_detail_vat_check CHECK (((vat_rate >= (0)::numeric) AND (vat_rate <= (100)::numeric)))
);


ALTER TABLE public.sls_offer_detail OWNER TO ths_admin;

--
-- Name: sls_offer_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sls_offer_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sls_offer_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sls_offer_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sls_offer ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sls_offer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sls_offer_tax_summary; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_offer_tax_summary (
    id bigint NOT NULL,
    sls_offer_id bigint NOT NULL,
    summary_type smallint NOT NULL,
    tax_rate numeric(5,2) NOT NULL,
    einv_withholding_id bigint,
    base_amount numeric(18,2) DEFAULT 0 NOT NULL,
    tax_amount numeric(18,2) DEFAULT 0 NOT NULL,
    CONSTRAINT sls_offer_tax_summary_type_check CHECK ((summary_type = ANY (ARRAY[1, 2]))),
    CONSTRAINT sls_offer_tax_summary_withholding_check CHECK (((summary_type = 2) = (einv_withholding_id IS NOT NULL)))
);


ALTER TABLE public.sls_offer_tax_summary OWNER TO ths_admin;

--
-- Name: sls_offer_tax_summary_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sls_offer_tax_summary ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sls_offer_tax_summary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sls_order; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_order (
    id bigint NOT NULL,
    order_no character varying(16) NOT NULL,
    order_date date DEFAULT CURRENT_DATE NOT NULL,
    acc_account_id bigint NOT NULL,
    customer_ref_no character varying(32),
    delivery_date date,
    stk_warehouse_id bigint,
    emp_employee_id bigint,
    currency character varying(3) DEFAULT public.fn_default_currency() NOT NULL,
    exchange_rate numeric(18,6) DEFAULT 1 NOT NULL,
    payment_term_days smallint DEFAULT 0 NOT NULL,
    status smallint DEFAULT 1 NOT NULL,
    gross_amount numeric(18,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(18,2) DEFAULT 0 NOT NULL,
    net_amount numeric(18,2) DEFAULT 0 NOT NULL,
    vat_amount numeric(18,2) DEFAULT 0 NOT NULL,
    total_amount numeric(18,2) DEFAULT 0 NOT NULL,
    description character varying(256),
    account_title character varying(128),
    taxpayer_type smallint,
    taxpayer_name character varying(32),
    taxpayer_name2 character varying(32),
    taxpayer_surname character varying(32),
    tax_office character varying(64),
    tax_no character varying(32),
    CONSTRAINT sls_order_delivery_date_check CHECK (((delivery_date IS NULL) OR (delivery_date >= order_date))),
    CONSTRAINT sls_order_exchange_rate_check CHECK ((exchange_rate > (0)::numeric)),
    CONSTRAINT sls_order_payment_term_check CHECK (((payment_term_days >= 0) AND (payment_term_days <= 365))),
    CONSTRAINT sls_order_status_check CHECK (((status >= 1) AND (status <= 5))),
    CONSTRAINT sls_order_taxpayer_type_check CHECK (((taxpayer_type IS NULL) OR (taxpayer_type = ANY (ARRAY[1, 2]))))
);


ALTER TABLE public.sls_order OWNER TO ths_admin;

--
-- Name: sls_order_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_order_detail (
    id bigint NOT NULL,
    sls_order_id bigint NOT NULL,
    line_no smallint NOT NULL,
    stk_inventory_id bigint NOT NULL,
    quantity numeric(18,6) NOT NULL,
    unit_price numeric(18,6) DEFAULT 0 NOT NULL,
    discount_rate numeric(5,2) DEFAULT 0 NOT NULL,
    vat_rate numeric(5,2) DEFAULT 0 NOT NULL,
    gross_amount numeric(18,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(18,2) DEFAULT 0 NOT NULL,
    net_amount numeric(18,2) DEFAULT 0 NOT NULL,
    vat_amount numeric(18,2) DEFAULT 0 NOT NULL,
    total_amount numeric(18,2) DEFAULT 0 NOT NULL,
    delivered_quantity numeric(18,6) DEFAULT 0 NOT NULL,
    delivery_date date,
    sls_offer_detail_id bigint,
    description character varying(128),
    CONSTRAINT sls_order_detail_delivered_check CHECK ((delivered_quantity >= (0)::numeric)),
    CONSTRAINT sls_order_detail_discount_check CHECK (((discount_rate >= (0)::numeric) AND (discount_rate <= (100)::numeric))),
    CONSTRAINT sls_order_detail_price_check CHECK ((unit_price >= (0)::numeric)),
    CONSTRAINT sls_order_detail_quantity_check CHECK ((quantity > (0)::numeric)),
    CONSTRAINT sls_order_detail_vat_check CHECK (((vat_rate >= (0)::numeric) AND (vat_rate <= (100)::numeric)))
);


ALTER TABLE public.sls_order_detail OWNER TO ths_admin;

--
-- Name: sls_order_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sls_order_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sls_order_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sls_order_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sls_order ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sls_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sls_order_tax_summary; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_order_tax_summary (
    id bigint NOT NULL,
    sls_order_id bigint NOT NULL,
    summary_type smallint NOT NULL,
    tax_rate numeric(5,2) NOT NULL,
    einv_withholding_id bigint,
    base_amount numeric(18,2) DEFAULT 0 NOT NULL,
    tax_amount numeric(18,2) DEFAULT 0 NOT NULL,
    CONSTRAINT sls_order_tax_summary_type_check CHECK ((summary_type = ANY (ARRAY[1, 2]))),
    CONSTRAINT sls_order_tax_summary_withholding_check CHECK (((summary_type = 2) = (einv_withholding_id IS NOT NULL)))
);


ALTER TABLE public.sls_order_tax_summary OWNER TO ths_admin;

--
-- Name: sls_order_tax_summary_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sls_order_tax_summary ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sls_order_tax_summary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stk_card_kind_info_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

CREATE SEQUENCE public.stk_card_kind_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stk_card_kind_info_id_seq OWNER TO ths_admin;

--
-- Name: stk_card_kind_info; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_card_kind_info (
    id bigint DEFAULT nextval('public.stk_card_kind_info_id_seq'::regclass) NOT NULL,
    stk_inventory_id bigint NOT NULL,
    stk_kind_property_id bigint NOT NULL,
    s1 character varying(64),
    s2 character varying(64),
    s3 character varying(64),
    s4 character varying(64),
    s5 character varying(64),
    s6 character varying(64),
    s7 character varying(64),
    s8 character varying(64),
    s9 character varying(64),
    s10 character varying(64),
    i1 integer,
    i2 integer,
    i3 integer,
    i4 integer,
    i5 integer,
    d1 double precision,
    d2 double precision,
    d3 double precision,
    d4 double precision,
    d5 double precision
);


ALTER TABLE public.stk_card_kind_info OWNER TO ths_admin;

--
-- Name: stk_group; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_group (
    id bigint NOT NULL,
    name character varying(32) NOT NULL,
    vat_rate numeric(5,2) NOT NULL,
    raw_material_stock_account character varying(16),
    raw_material_usage_account character varying(16),
    semi_product_account character varying(16)
);


ALTER TABLE public.stk_group OWNER TO ths_admin;

--
-- Name: stk_transaction; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_transaction (
    id bigint NOT NULL,
    quantity numeric(18,6) NOT NULL,
    amount numeric(18,6) DEFAULT 0 NOT NULL,
    amount_foreign numeric(18,6) DEFAULT 0 NOT NULL,
    currency character varying(3),
    transaction_date date DEFAULT CURRENT_DATE NOT NULL,
    from_stk_warehouse_id bigint,
    to_stk_warehouse_id bigint,
    is_opening boolean DEFAULT false NOT NULL,
    description character varying(128),
    dispatch_id bigint,
    production_id bigint,
    stk_inventory_id bigint NOT NULL,
    transaction_type smallint NOT NULL,
    pur_receipt_detail_id bigint,
    sls_dispatch_detail_id bigint,
    sls_invoice_detail_id bigint,
    qc_inspection_id bigint,
    CONSTRAINT stk_transaction_is_opening_check CHECK (((NOT is_opening) OR (transaction_type = 1))),
    CONSTRAINT stk_transaction_pur_receipt_check CHECK (((pur_receipt_detail_id IS NULL) OR (transaction_type = 1))),
    CONSTRAINT stk_transaction_qc_check CHECK (((qc_inspection_id IS NULL) OR (transaction_type = 3))),
    CONSTRAINT stk_transaction_quantity_check CHECK ((quantity > (0)::numeric)),
    CONSTRAINT stk_transaction_sls_check CHECK ((((sls_dispatch_detail_id IS NULL) AND (sls_invoice_detail_id IS NULL)) OR ((transaction_type = 2) AND ((sls_dispatch_detail_id IS NULL) OR (sls_invoice_detail_id IS NULL))))),
    CONSTRAINT stk_transaction_transaction_type_check CHECK ((((transaction_type = 1) AND (to_stk_warehouse_id IS NOT NULL) AND (from_stk_warehouse_id IS NULL)) OR ((transaction_type = 2) AND (from_stk_warehouse_id IS NOT NULL) AND (to_stk_warehouse_id IS NULL)) OR ((transaction_type = 3) AND (from_stk_warehouse_id IS NOT NULL) AND (to_stk_warehouse_id IS NOT NULL) AND (from_stk_warehouse_id <> to_stk_warehouse_id))))
);


ALTER TABLE public.stk_transaction OWNER TO ths_admin;

--
-- Name: stk_hareketler_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.stk_transaction ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_hareketler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stk_image; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_image (
    id bigint NOT NULL,
    stk_inventory_id bigint CONSTRAINT stk_image_card_id_not_null NOT NULL,
    image bytea,
    file_name character varying
);


ALTER TABLE public.stk_image OWNER TO ths_admin;

--
-- Name: stk_inventory; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_inventory (
    id bigint CONSTRAINT stk_inventory_id_nn NOT NULL,
    sellable boolean DEFAULT true NOT NULL,
    code character varying(32) CONSTRAINT stk_inventory_sku_nn NOT NULL,
    name character varying(128) CONSTRAINT stk_inventory_stock_name_nn NOT NULL,
    stk_group_id bigint CONSTRAINT stk_inventory_group_id_nn NOT NULL,
    sys_uom_id bigint CONSTRAINT stk_inventory_uom_code_nn NOT NULL,
    stk_product_type_id bigint CONSTRAINT stk_inventory_product_type_nn NOT NULL,
    buying_discount numeric(5,2) DEFAULT 0 NOT NULL,
    sales_discount numeric(5,2) DEFAULT 0 NOT NULL,
    buying_price numeric(18,6) DEFAULT 0 NOT NULL,
    buying_currency character varying(3) DEFAULT public.fn_default_currency() CONSTRAINT stk_inventory_buy_currency_nn NOT NULL,
    sales_price numeric(18,6) DEFAULT 0 NOT NULL,
    sales_currency character varying(3) DEFAULT public.fn_default_currency() CONSTRAINT stk_inventory_sell_currency_nn NOT NULL,
    export_price numeric(18,6) DEFAULT 0 NOT NULL,
    export_currency character varying(3) DEFAULT public.fn_default_currency() CONSTRAINT stk_inventory_export_currency_nn NOT NULL,
    width double precision DEFAULT 0,
    length double precision DEFAULT 0,
    height double precision DEFAULT 0,
    weight double precision DEFAULT 0,
    supply_duration smallint DEFAULT 0 NOT NULL,
    special_code character varying(16),
    brand character varying(32),
    sys_country_id bigint,
    diib_product_description character varying(512),
    min_stock_amount double precision DEFAULT 0 NOT NULL,
    product_overview text,
    vat_rate numeric(5,2),
    raw_material_stock_account character varying(16),
    raw_material_usage_account character varying(16),
    semi_product_account character varying(16),
    sales_account character varying(16),
    sales_return_account character varying(16),
    purchase_account character varying(16),
    purchase_return_account character varying(16),
    einv_gtip_id bigint,
    CONSTRAINT stk_inventory_buying_discount_check CHECK (((buying_discount >= (0)::numeric) AND (buying_discount <= (100)::numeric))),
    CONSTRAINT stk_inventory_sales_discount_check CHECK (((sales_discount >= (0)::numeric) AND (sales_discount <= (100)::numeric)))
);


ALTER TABLE public.stk_inventory OWNER TO ths_admin;

--
-- Name: COLUMN stk_inventory.vat_rate; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.stk_inventory.vat_rate IS 'Karta özel KDV oranı; NULL = stk_group.vat_rate';


--
-- Name: COLUMN stk_inventory.raw_material_stock_account; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.stk_inventory.raw_material_stock_account IS 'Karta özel hesap; NULL = stk_group değeri';


--
-- Name: COLUMN stk_inventory.raw_material_usage_account; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.stk_inventory.raw_material_usage_account IS 'Karta özel hesap; NULL = stk_group değeri';


--
-- Name: COLUMN stk_inventory.semi_product_account; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.stk_inventory.semi_product_account IS 'Karta özel hesap; NULL = stk_group değeri';


--
-- Name: COLUMN stk_inventory.sales_account; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.stk_inventory.sales_account IS 'Karta özel hesap; NULL = geçerli KDV oranının acc_set_tax_rate değeri';


--
-- Name: COLUMN stk_inventory.sales_return_account; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.stk_inventory.sales_return_account IS 'Karta özel hesap; NULL = geçerli KDV oranının acc_set_tax_rate değeri';


--
-- Name: COLUMN stk_inventory.purchase_account; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.stk_inventory.purchase_account IS 'Karta özel hesap; NULL = geçerli KDV oranının acc_set_tax_rate değeri';


--
-- Name: COLUMN stk_inventory.purchase_return_account; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.stk_inventory.purchase_return_account IS 'Karta özel hesap; NULL = geçerli KDV oranının acc_set_tax_rate değeri';


--
-- Name: stk_inventory_summary; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_inventory_summary (
    id bigint NOT NULL,
    stk_inventory_id bigint CONSTRAINT stk_inventory_summary_inventory_id_not_null NOT NULL,
    current_quantity numeric(18,6) DEFAULT 0 NOT NULL,
    average_cost numeric(18,6) DEFAULT 0 NOT NULL,
    opening_price numeric(18,6) DEFAULT 0 NOT NULL,
    opening_quantity numeric(18,6) DEFAULT 0 NOT NULL,
    opening_amount numeric(18,6) DEFAULT 0 NOT NULL,
    incoming_quantity numeric(18,6) DEFAULT 0 NOT NULL,
    incoming_amount numeric(18,6) DEFAULT 0 NOT NULL,
    outgoing_quantity numeric(18,6) DEFAULT 0 NOT NULL,
    outgoing_amount numeric(18,6) DEFAULT 0 NOT NULL,
    last_buy_price numeric(18,6) DEFAULT 0 NOT NULL,
    last_buy_currency character varying(3),
    last_buy_date date,
    last_buy_quantity numeric(18,6) DEFAULT 0 NOT NULL,
    last_buy_exchange_rate numeric(18,6) DEFAULT 0 NOT NULL
);


ALTER TABLE public.stk_inventory_summary OWNER TO ths_admin;

--
-- Name: stk_kart_ozetleri_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.stk_inventory_summary ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_kart_ozetleri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stk_kartlar_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.stk_inventory ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_kartlar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stk_kind_family; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_kind_family (
    id bigint NOT NULL,
    family character varying(32) NOT NULL,
    description character varying(250),
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.stk_kind_family OWNER TO ths_admin;

--
-- Name: stk_kind_family_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

CREATE SEQUENCE public.stk_kind_family_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stk_kind_family_id_seq OWNER TO ths_admin;

--
-- Name: stk_kind_family_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ths_admin
--

ALTER SEQUENCE public.stk_kind_family_id_seq OWNED BY public.stk_kind_family.id;


--
-- Name: stk_kind_property_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

CREATE SEQUENCE public.stk_kind_property_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stk_kind_property_id_seq OWNER TO ths_admin;

--
-- Name: stk_kind_property; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_kind_property (
    id bigint DEFAULT nextval('public.stk_kind_property_id_seq'::regclass) NOT NULL,
    kind character varying(32) NOT NULL,
    description character varying(128),
    s1 character varying(32),
    s2 character varying(32),
    s3 character varying(32),
    s4 character varying(32),
    s5 character varying(32),
    s6 character varying(32),
    s7 character varying(32),
    s8 character varying(32),
    s9 character varying(32),
    s10 character varying(32),
    i1 character varying(32),
    i2 character varying(32),
    i3 character varying(32),
    i4 character varying(32),
    i5 character varying(32),
    d1 character varying(32),
    d2 character varying(32),
    d3 character varying(32),
    d4 character varying(32),
    d5 character varying(32),
    stk_kind_family_id bigint
);


ALTER TABLE public.stk_kind_property OWNER TO ths_admin;

--
-- Name: stk_product_type; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_product_type (
    id bigint NOT NULL,
    product_type_name character varying(32) NOT NULL,
    description character varying(128),
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.stk_product_type OWNER TO ths_admin;

--
-- Name: stk_product_type_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

CREATE SEQUENCE public.stk_product_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stk_product_type_id_seq OWNER TO ths_admin;

--
-- Name: stk_product_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ths_admin
--

ALTER SEQUENCE public.stk_product_type_id_seq OWNED BY public.stk_product_type.id;


--
-- Name: stk_resimler_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.stk_image ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_resimler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stk_warehouse; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_warehouse (
    id bigint NOT NULL,
    warehouse_name character varying(32) NOT NULL,
    default_raw_material boolean DEFAULT false NOT NULL,
    default_production boolean DEFAULT false NOT NULL,
    default_sales boolean DEFAULT false NOT NULL
);


ALTER TABLE public.stk_warehouse OWNER TO ths_admin;

--
-- Name: TABLE stk_warehouse; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON TABLE public.stk_warehouse IS 'Stok hareketlerinin tutulduğu ambar bilgisi';


--
-- Name: stk_stok_ambar_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.stk_warehouse ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_stok_ambar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stk_stok_grubu_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.stk_group ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_stok_grubu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_access_right; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_access_right (
    id bigint NOT NULL,
    sys_permission_id bigint CONSTRAINT sys_access_rights_permission_id_not_null NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    is_add boolean DEFAULT false NOT NULL,
    is_update boolean DEFAULT false CONSTRAINT sys_access_right_is_upd_not_null NOT NULL,
    is_delete boolean DEFAULT false CONSTRAINT sys_access_right_is_del_not_null NOT NULL,
    is_special boolean DEFAULT false CONSTRAINT sys_access_right_is_spcl_not_null NOT NULL,
    sys_user_id bigint CONSTRAINT sys_access_rights_user_id_not_null NOT NULL,
    deny_read boolean DEFAULT false NOT NULL,
    deny_add boolean DEFAULT false NOT NULL,
    deny_update boolean DEFAULT false NOT NULL,
    deny_delete boolean DEFAULT false NOT NULL,
    deny_special boolean DEFAULT false NOT NULL
);


ALTER TABLE public.sys_access_right OWNER TO ths_admin;

--
-- Name: sys_access_right_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_access_right ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_access_right_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_address; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_address (
    id bigint NOT NULL,
    sys_city_id bigint CONSTRAINT sys_address_city_id_not_null NOT NULL,
    district character varying(64),
    neighborhood character varying(64),
    quarter character varying(64),
    road character varying(64),
    street character varying(64),
    building_name character varying(48),
    door_number character varying(16),
    zip_code character varying(16),
    web character varying(64),
    email character varying(128)
);


ALTER TABLE public.sys_address OWNER TO ths_admin;

--
-- Name: sys_adresler_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_address ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_adresler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_api_service; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_api_service (
    id bigint NOT NULL,
    sys_application_setting_id bigint NOT NULL,
    service_kind character varying(32) NOT NULL,
    provider_code character varying(32),
    environment smallint DEFAULT 1 NOT NULL,
    base_url character varying(512),
    username character varying(128),
    password_enc character varying(1024),
    api_key_enc character varying(2048),
    timeout_seconds smallint DEFAULT 60 NOT NULL,
    options jsonb DEFAULT '{}'::jsonb NOT NULL,
    description character varying(256),
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT sys_api_service_environment_check CHECK ((environment = ANY (ARRAY[1, 2]))),
    CONSTRAINT sys_api_service_kind_check CHECK (((service_kind)::text ~ '^[a-z][a-z0-9_]{1,31}$'::text)),
    CONSTRAINT sys_api_service_options_check CHECK ((jsonb_typeof(options) = 'object'::text)),
    CONSTRAINT sys_api_service_timeout_check CHECK (((timeout_seconds >= 1) AND (timeout_seconds <= 3600)))
);


ALTER TABLE public.sys_api_service OWNER TO ths_admin;

--
-- Name: sys_api_service_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_api_service ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_api_service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_application_setting; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_application_setting (
    id bigint CONSTRAINT sys_app_set_id_not_null NOT NULL,
    company_title character varying(128) DEFAULT 'THUNDERSOFT A.Ş.'::character varying CONSTRAINT sys_app_set_cttl_not_null NOT NULL,
    phone character varying(24) DEFAULT '0123 456 78 90'::character varying CONSTRAINT sys_app_set_phone_not_null NOT NULL,
    fax character varying(24),
    tax_authority character varying(32),
    tax_no character varying(16),
    active_period smallint DEFAULT 2018 CONSTRAINT sys_app_set_apern_not_null NOT NULL,
    mail_host character varying(255),
    mail_user character varying(255),
    mail_password character varying(255),
    mail_smtp_port integer,
    grid_color_1 integer DEFAULT 13171168 CONSTRAINT sys_app_set_gc1_not_null NOT NULL,
    grid_color_2 integer DEFAULT 7467153 CONSTRAINT sys_app_set_gc2_not_null NOT NULL,
    grid_color_active integer DEFAULT 14605509 CONSTRAINT sys_app_set_gca_not_null NOT NULL,
    crypt_key character varying(255) DEFAULT 12345 CONSTRAINT sys_app_set_cke_not_null NOT NULL,
    sms_host character varying(255),
    sms_user character varying(255),
    sms_password character varying(255),
    sms_title character varying(255),
    app_version character varying(128),
    app_currency character varying(3),
    sys_address_id bigint,
    other_settings jsonb,
    taxpayer_name character varying(64),
    taxpayer_surname character varying,
    taxpayer_type character varying(8),
    logo bytea
);


ALTER TABLE public.sys_application_setting OWNER TO ths_admin;

--
-- Name: sys_city; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_city (
    id bigint NOT NULL,
    city_name character varying(128) CONSTRAINT sys_city_name_not_null NOT NULL,
    car_plate_code integer,
    sys_country_id bigint NOT NULL,
    sys_region_id bigint
);


ALTER TABLE public.sys_city OWNER TO ths_admin;

--
-- Name: sys_city_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_city ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_city_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_country; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_country (
    id bigint NOT NULL,
    country_code character varying(2) CONSTRAINT sys_country_code_not_null NOT NULL,
    iso_year integer,
    iso_cctld character varying(3),
    is_eu_member boolean DEFAULT false CONSTRAINT sys_country_eu_not_null NOT NULL
);


ALTER TABLE public.sys_country OWNER TO ths_admin;

--
-- Name: sys_country_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_country ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_country_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_country_translation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_country_translation (
    sys_country_id bigint NOT NULL,
    sys_language_id bigint NOT NULL,
    country_name character varying(128)
);


ALTER TABLE public.sys_country_translation OWNER TO ths_admin;

--
-- Name: sys_currency; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_currency (
    id bigint NOT NULL,
    currency character varying(3) CONSTRAINT sys_currency_cur_not_null NOT NULL,
    symbol character varying(8) CONSTRAINT sys_currency_sym_not_null NOT NULL,
    description character varying(128)
);


ALTER TABLE public.sys_currency OWNER TO ths_admin;

--
-- Name: sys_currency_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_currency ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_currency_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_db_status; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.sys_db_status AS
 SELECT (row_number() OVER (ORDER BY client_addr, usename))::integer AS id,
    pid,
    (datname)::character varying(128) AS db_name,
    (application_name)::character varying(128) AS app_name,
    (usename)::character varying(64) AS user_name,
    (client_addr)::character varying(32) AS client_address,
    (state)::character varying(64) AS state,
    (query)::character varying(1024) AS query,
    (( SELECT string_agg((( SELECT pg_statio_user_tables.relname
                   FROM pg_statio_user_tables
                  WHERE ((pg_statio_user_tables.relid = lck.relation) AND (pg_statio_user_tables.relname IS NOT NULL))))::text, ', '::text) AS string_agg
           FROM pg_locks lck
          WHERE (lck.pid = pa.pid)
          ORDER BY (string_agg((( SELECT pg_statio_user_tables.relname
                   FROM pg_statio_user_tables
                  WHERE ((pg_statio_user_tables.relid = lck.relation) AND (pg_statio_user_tables.relname IS NOT NULL))))::text, ', '::text))))::character varying(1024) AS locked_tables
   FROM pg_stat_activity pa
  WHERE (datname = current_database());


ALTER VIEW public.sys_db_status OWNER TO ths_admin;

--
-- Name: sys_decimal_place; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_decimal_place (
    id bigint CONSTRAINT sys_dp_id_not_null NOT NULL,
    quantity smallint DEFAULT 0 NOT NULL,
    price smallint DEFAULT 0 NOT NULL,
    total smallint DEFAULT 0 NOT NULL,
    stock_quantity smallint DEFAULT 0 NOT NULL,
    exchange_rate smallint DEFAULT 0 NOT NULL,
    CONSTRAINT sys_decimal_place_exchange_rate_check CHECK (((exchange_rate >= 0) AND (exchange_rate <= 4))),
    CONSTRAINT sys_decimal_place_price_check CHECK (((price >= 0) AND (price <= 4))),
    CONSTRAINT sys_decimal_place_quantity_check CHECK (((quantity >= 0) AND (quantity <= 4))),
    CONSTRAINT sys_decimal_place_stock_quantity_check CHECK (((stock_quantity >= 0) AND (stock_quantity <= 4))),
    CONSTRAINT sys_decimal_place_total_check CHECK (((total >= 0) AND (total <= 2)))
);


ALTER TABLE public.sys_decimal_place OWNER TO ths_admin;

--
-- Name: sys_grid_column; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_grid_column (
    id bigint CONSTRAINT sys_gc_iid_not_null NOT NULL,
    table_name character varying(128) CONSTRAINT sys_gc_tn_not_null NOT NULL,
    column_name character varying(128) CONSTRAINT sys_gc_cn_not_null NOT NULL,
    column_order integer DEFAULT 1 CONSTRAINT sys_gc_co_not_null NOT NULL,
    column_width integer DEFAULT 0 CONSTRAINT sys_gc_cw_not_null NOT NULL,
    data_format character varying(16),
    is_show boolean DEFAULT true,
    is_show_helper boolean DEFAULT false,
    min_value double precision DEFAULT 0 NOT NULL,
    min_value_color integer DEFAULT 0 NOT NULL,
    max_value double precision DEFAULT 0 NOT NULL,
    max_value_color integer DEFAULT 0 NOT NULL,
    max_value_percent double precision DEFAULT 0 NOT NULL,
    bar_color integer DEFAULT 0 NOT NULL,
    bar_bg_color integer DEFAULT 0 NOT NULL,
    bar_text_color integer DEFAULT 0 NOT NULL,
    is_fetch boolean DEFAULT true,
    aggregate_type smallint DEFAULT 0 NOT NULL
);


ALTER TABLE public.sys_grid_column OWNER TO ths_admin;

--
-- Name: sys_grid_filter; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_grid_filter (
    id bigint CONSTRAINT sys_gf_iid_not_null NOT NULL,
    table_name character varying(32),
    filter_content character varying
);


ALTER TABLE public.sys_grid_filter OWNER TO ths_admin;

--
-- Name: sys_grid_filtre_siralama_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_grid_filter ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_filtre_siralama_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_grid_kolon_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_grid_column ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_kolon_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_grid_sort; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_grid_sort (
    id bigint CONSTRAINT sys_gs_iid_not_null NOT NULL,
    table_name character varying(32),
    sort_content character varying
);


ALTER TABLE public.sys_grid_sort OWNER TO ths_admin;

--
-- Name: sys_grid_sorts_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_grid_sort ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_sorts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_permission_group; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_permission_group (
    id bigint CONSTRAINT sys_pg_iid_not_null NOT NULL,
    permission_group_key character varying(128)
);


ALTER TABLE public.sys_permission_group OWNER TO ths_admin;

--
-- Name: sys_kaynak_grup_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_permission_group ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kaynak_grup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_permission; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_permission (
    id bigint CONSTRAINT sys_perm_iid_not_null NOT NULL,
    permission_code integer CONSTRAINT sys_perm_pc_not_null NOT NULL,
    sys_permission_group_id bigint CONSTRAINT sys_permissions_permission_group_id_not_null NOT NULL,
    permission_key character varying(128) CONSTRAINT sys_permission_key_not_null NOT NULL
);


ALTER TABLE public.sys_permission OWNER TO ths_admin;

--
-- Name: sys_kaynak_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_permission ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kaynak_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_user; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_user (
    id bigint CONSTRAINT sys_usr_iid_not_null NOT NULL,
    username character varying(64) CONSTRAINT sys_usr_un_not_null NOT NULL,
    user_password text CONSTRAINT sys_usr_pw_not_null NOT NULL,
    active boolean DEFAULT true CONSTRAINT sys_usr_act_not_null NOT NULL,
    manager boolean DEFAULT false CONSTRAINT sys_usr_mgr_not_null NOT NULL,
    super_user boolean DEFAULT false CONSTRAINT sys_usr_su_not_null NOT NULL,
    ip_address character varying(32) DEFAULT '127.0.0.1'::character varying CONSTRAINT sys_usr_ip_not_null NOT NULL,
    mac_address character varying(32),
    emp_employee_id bigint CONSTRAINT sys_users_person_id_not_null NOT NULL
);


ALTER TABLE public.sys_user OWNER TO ths_admin;

--
-- Name: sys_kullanici_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_user ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kullanici_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_language; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_language (
    id bigint CONSTRAINT sys_lng_iid_not_null NOT NULL,
    locale character varying(32) CONSTRAINT sys_lng_lc_not_null NOT NULL,
    native_name character varying(64)
);


ALTER TABLE public.sys_language OWNER TO ths_admin;

--
-- Name: sys_languages_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_language ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_menu; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_menu (
    id bigint NOT NULL,
    menu_code integer NOT NULL,
    parent_code integer GENERATED ALWAYS AS (
CASE
    WHEN ((menu_code % 10000) = 0) THEN NULL::integer
    WHEN ((menu_code % 100) = 0) THEN ((menu_code / 10000) * 10000)
    ELSE ((menu_code / 100) * 100)
END) STORED,
    menu_key character varying(64) NOT NULL,
    action_name character varying(64),
    sys_permission_id bigint,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT sys_menu_folder_check CHECK ((((menu_code % 100) = 0) = (action_name IS NULL))),
    CONSTRAINT sys_menu_folder_permission_check CHECK ((((menu_code % 100) <> 0) OR (sys_permission_id IS NULL))),
    CONSTRAINT sys_menu_menu_code_check CHECK (((menu_code >= 100000) AND (menu_code <= 999999)))
);


ALTER TABLE public.sys_menu OWNER TO ths_admin;

--
-- Name: TABLE sys_menu; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON TABLE public.sys_menu IS 'Menü ağacı ve kalıcı ekran kodları (MMGGSS). Yetki = ekranın okuma yetkisi; NULL = herkese açık.';


--
-- Name: sys_menu_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_menu ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_menu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_menu_translation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_menu_translation (
    sys_menu_id bigint NOT NULL,
    sys_language_id bigint NOT NULL,
    menu_name character varying(128) NOT NULL,
    keywords character varying(512)
);


ALTER TABLE public.sys_menu_translation OWNER TO ths_admin;

--
-- Name: COLUMN sys_menu_translation.keywords; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.sys_menu_translation.keywords IS 'Arama için ek kelimeler (boşlukla ayrılmış)';


--
-- Name: sys_ondalik_hane_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_decimal_place ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ondalik_hane_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_permission_group_translation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_permission_group_translation (
    sys_permission_group_id bigint CONSTRAINT sys_permission_group_translati_sys_permission_group_id_not_null NOT NULL,
    sys_language_id bigint NOT NULL,
    permission_group_name character varying(128)
);


ALTER TABLE public.sys_permission_group_translation OWNER TO ths_admin;

--
-- Name: sys_permission_template; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_permission_template (
    id bigint NOT NULL,
    template_key character varying(64) NOT NULL,
    template_name character varying(128) NOT NULL,
    description character varying(512),
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.sys_permission_template OWNER TO ths_admin;

--
-- Name: sys_permission_template_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_permission_template ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_permission_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_permission_template_right; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_permission_template_right (
    id bigint NOT NULL,
    sys_permission_template_id bigint CONSTRAINT sys_permission_template_rig_sys_permission_template_id_not_null NOT NULL,
    sys_permission_id bigint NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    is_add boolean DEFAULT false NOT NULL,
    is_update boolean DEFAULT false NOT NULL,
    is_delete boolean DEFAULT false NOT NULL,
    is_special boolean DEFAULT false NOT NULL
);


ALTER TABLE public.sys_permission_template_right OWNER TO ths_admin;

--
-- Name: sys_permission_template_right_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_permission_template_right ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_permission_template_right_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_permission_translation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_permission_translation (
    sys_permission_id bigint NOT NULL,
    sys_language_id bigint NOT NULL,
    permission_name character varying(128)
);


ALTER TABLE public.sys_permission_translation OWNER TO ths_admin;

--
-- Name: sys_region; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_region (
    id bigint CONSTRAINT sys_reg_iid_not_null NOT NULL,
    region_name character varying(128) CONSTRAINT sys_reg_rn_not_null NOT NULL
);


ALTER TABLE public.sys_region OWNER TO ths_admin;

--
-- Name: sys_region_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_region ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_uom; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_uom (
    id bigint CONSTRAINT sys_uom_iid_not_null NOT NULL,
    unit_code character varying(16) CONSTRAINT sys_uom_mu_not_null NOT NULL,
    unit_einv character varying(3),
    "decimal" boolean DEFAULT false CONSTRAINT sys_uom_dec_not_null NOT NULL,
    sys_uom_group_id bigint,
    multiplier integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.sys_uom OWNER TO ths_admin;

--
-- Name: sys_uom_group; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_uom_group (
    id bigint CONSTRAINT sys_uomt_iid_not_null NOT NULL,
    uom_group_key character varying(16) CONSTRAINT sys_uomt_nm_not_null NOT NULL
);


ALTER TABLE public.sys_uom_group OWNER TO ths_admin;

--
-- Name: sys_uom_group_translation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_uom_group_translation (
    sys_uom_group_id bigint CONSTRAINT sys_uom_type_translation_sys_uom_type_id_not_null NOT NULL,
    sys_language_id bigint CONSTRAINT sys_uom_type_translation_sys_language_id_not_null NOT NULL,
    uom_group_name character varying(16) CONSTRAINT sys_uom_type_translation_name_not_null NOT NULL
);


ALTER TABLE public.sys_uom_group_translation OWNER TO ths_admin;

--
-- Name: sys_uom_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_uom ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_uom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_uom_translation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_uom_translation (
    sys_uom_id bigint NOT NULL,
    sys_language_id bigint NOT NULL,
    uom_name character varying(64)
);


ALTER TABLE public.sys_uom_translation OWNER TO ths_admin;

--
-- Name: sys_uom_type_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_uom_group ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_uom_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_user_grid_column; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_user_grid_column (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    table_name character varying(128) NOT NULL,
    column_name character varying(128) NOT NULL,
    column_order integer DEFAULT 1 NOT NULL,
    column_width integer DEFAULT 0 NOT NULL,
    is_show boolean DEFAULT true NOT NULL
);


ALTER TABLE public.sys_user_grid_column OWNER TO postgres;

--
-- Name: sys_user_grid_column_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.sys_user_grid_column ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_user_grid_column_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_user_menu; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_user_menu (
    id bigint NOT NULL,
    sys_user_id bigint NOT NULL,
    sys_menu_id bigint NOT NULL,
    is_favorite boolean DEFAULT false NOT NULL,
    open_count integer DEFAULT 0 NOT NULL,
    last_opened_at timestamp without time zone,
    CONSTRAINT sys_user_menu_open_count_check CHECK ((open_count >= 0))
);


ALTER TABLE public.sys_user_menu OWNER TO ths_admin;

--
-- Name: TABLE sys_user_menu; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON TABLE public.sys_user_menu IS 'Kullanıcının menü tercihleri: favori ekranlar ve son kullanılanlar (yalnız ekran satırları)';


--
-- Name: sys_user_menu_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_user_menu ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_user_menu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_user_permission_template; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_user_permission_template (
    id bigint NOT NULL,
    sys_user_id bigint NOT NULL,
    sys_permission_template_id bigint CONSTRAINT sys_user_permission_templat_sys_permission_template_id_not_null NOT NULL
);


ALTER TABLE public.sys_user_permission_template OWNER TO ths_admin;

--
-- Name: sys_user_permission_template_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_user_permission_template ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_user_permission_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_user_setting; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_user_setting (
    id bigint NOT NULL,
    sys_user_id bigint NOT NULL,
    setting_key character varying(64) NOT NULL,
    setting_value text
);


ALTER TABLE public.sys_user_setting OWNER TO ths_admin;

--
-- Name: TABLE sys_user_setting; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON TABLE public.sys_user_setting IS 'Kullanıcı bazında arayüz ayarları (anahtar / değer), ör. nav.width, nav.visible, nav.expanded';


--
-- Name: sys_user_setting_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_user_setting ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_user_setting_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_uygulama_ayari_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_application_setting ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_uygulama_ayari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_view_tables; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.sys_view_tables AS
 SELECT (row_number() OVER (ORDER BY table_type, table_name))::integer AS id,
    table_name,
    table_type
   FROM information_schema.tables
  WHERE ((table_schema)::text = 'public'::text)
  ORDER BY (table_type)::text, (initcap(replace((table_name)::text, '_'::text, ' '::text)));


ALTER VIEW public.sys_view_tables OWNER TO ths_admin;

--
-- Name: sys_view_columns; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.sys_view_columns AS
 SELECT (row_number() OVER (ORDER BY vt.table_type, columns.table_name, columns.ordinal_position))::integer AS id,
    initcap(replace((columns.table_name)::text, '_'::text, ' '::text)) AS table_name,
    initcap(replace((columns.column_name)::text, '_'::text, ' '::text)) AS column_name,
        CASE columns.is_nullable
            WHEN 'YES'::text THEN true
            ELSE false
        END AS is_nullable,
    (columns.data_type)::text AS data_type,
    (columns.character_maximum_length)::integer AS character_maximum_length,
    (columns.ordinal_position)::integer AS ordinal_position,
    (columns.table_name)::text AS orj_table_name,
    (columns.column_name)::text AS orj_column_name,
    vt.table_type,
    columns.numeric_precision,
    columns.numeric_scale
   FROM (information_schema.columns
     JOIN public.sys_view_tables vt ON ((( SELECT lower(replace((vt.table_name)::text, ' '::text, '_'::text)) AS lower) = (columns.table_name)::text)))
  ORDER BY vt.table_type, columns.table_name, columns.ordinal_position;


ALTER VIEW public.sys_view_columns OWNER TO ths_admin;

--
-- Name: sys_view_databases; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.sys_view_databases AS
 SELECT (pg_database.datname)::text AS database_name,
    pg_shdescription.description
   FROM (pg_shdescription
     JOIN pg_database ON ((pg_shdescription.objoid = pg_database.oid)))
  WHERE ((1 = 1) AND (pg_shdescription.description = 'THS ERP Systems'::text));


ALTER VIEW public.sys_view_databases OWNER TO postgres;

--
-- Name: vw_acc_account; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_account AS
 SELECT a.id,
    a.code,
    a.name,
    a.acc_set_account_type_id,
    (COALESCE(att.name, at.account_type_key))::character varying(64) AS account_type_name,
    a.acc_group_id,
    g.name AS group_name,
    a.acc_region_id,
    r.name AS region_name,
    a.iban,
    a.iban_currency,
    a.notes,
    a.root_code,
    a.sub_code,
    a.discount_rate,
    a.e_invoice_active,
    a.e_invoice_pk_alias,
    a.is_passive,
    t.taxpayer_type,
    t.taxpayer_name,
    t.taxpayer_name2,
    t.taxpayer_surname,
    t.tax_office,
    t.tax_no,
    t.nace_code,
    c.authorized_person_1,
    c.authorized_phone_1,
    c.authorized_person_2,
    c.authorized_phone_2,
    c.authorized_person_3,
    c.authorized_phone_3,
    c.fax,
    c.accountant_phone,
    c.accountant_email,
    c.accountant_authorized,
    l.locale,
    a.e_despatch_active,
    a.e_invoice_gb_alias,
    a.e_despatch_pk_alias,
    a.e_despatch_gb_alias
   FROM (((((((public.acc_account a
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.acc_set_account_type at ON ((at.id = a.acc_set_account_type_id)))
     LEFT JOIN public.acc_set_account_type_translation att ON (((att.acc_set_account_type_id = at.id) AND (att.sys_language_id = l.id))))
     LEFT JOIN public.acc_group g ON ((g.id = a.acc_group_id)))
     LEFT JOIN public.acc_region r ON ((r.id = a.acc_region_id)))
     LEFT JOIN public.acc_account_taxpayer t ON ((t.acc_account_id = a.id)))
     LEFT JOIN public.acc_account_contact c ON ((c.acc_account_id = a.id)));


ALTER VIEW public.vw_acc_account OWNER TO ths_admin;

--
-- Name: vw_acc_account_address; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_account_address AS
 SELECT aa.id,
    aa.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    aa.sys_address_id,
    (concat_ws(', '::text, NULLIF((ad.neighborhood)::text, ''::text), NULLIF((ad.street)::text, ''::text), NULLIF((ad.door_number)::text, ''::text), NULLIF((ad.district)::text, ''::text), NULLIF((c.city_name)::text, ''::text)))::character varying(256) AS address_text,
    aa.address_type,
    aa.is_primary,
    aa.valid_from,
    aa.valid_to
   FROM (((public.acc_account_address aa
     LEFT JOIN public.acc_account a ON ((a.id = aa.acc_account_id)))
     LEFT JOIN public.sys_address ad ON ((ad.id = aa.sys_address_id)))
     LEFT JOIN public.sys_city c ON ((c.id = ad.sys_city_id)));


ALTER VIEW public.vw_acc_account_address OWNER TO ths_admin;

--
-- Name: vw_acc_account_plan; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_account_plan AS
 SELECT id,
    code,
    name,
    level
   FROM public.acc_account_plan p;


ALTER VIEW public.vw_acc_account_plan OWNER TO ths_admin;

--
-- Name: vw_acc_account_transaction; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_account_transaction AS
 WITH ct AS (
         SELECT t.id,
            t.fin_cheque_note_id,
            t.transaction_date,
            t.transaction_type,
            t.acc_account_id,
            t.description,
            n.direction,
            n.acc_account_id AS note_account_id,
            n.amount,
            n.currency,
            (((n.portfolio_no)::text || ' / '::text) || (n.serial_no)::text) AS document_no,
            lag(t.transaction_type) OVER w AS prev_type,
            lag(t.acc_account_id) OVER w AS prev_account_id
           FROM (public.fin_cheque_note_transaction t
             JOIN public.fin_cheque_note n ON ((n.id = t.fin_cheque_note_id)))
          WINDOW w AS (PARTITION BY t.fin_cheque_note_id ORDER BY t.transaction_date, t.id)
        ), lines AS (
         SELECT ((t.id * 100) + 10) AS id,
            1 AS source_type,
            t.id AS source_id,
            t.id AS document_id,
            t.acc_account_id,
            t.transaction_date,
            t.document_no,
            t.description,
            m.currency,
                CASE
                    WHEN (t.transaction_type = ANY (ARRAY[2, 4, 7])) THEN t.amount
                    ELSE (0)::numeric
                END AS debit,
                CASE
                    WHEN (t.transaction_type = ANY (ARRAY[1, 5, 6])) THEN t.amount
                    ELSE (0)::numeric
                END AS credit
           FROM (public.fin_money_transaction t
             JOIN public.fin_money_account m ON ((m.id = t.fin_money_account_id)))
          WHERE ((t.acc_account_id IS NOT NULL) AND (t.transaction_type <> 3))
        UNION ALL
         SELECT ((ct.id * 100) + 20),
            2,
            ct.id,
            ct.fin_cheque_note_id,
            ct.note_account_id,
            ct.transaction_date,
            ct.document_no,
            ct.description,
            ct.currency,
                CASE
                    WHEN (ct.direction = 2) THEN ct.amount
                    ELSE (0)::numeric
                END AS "case",
                CASE
                    WHEN (ct.direction = 1) THEN ct.amount
                    ELSE (0)::numeric
                END AS "case"
           FROM ct
          WHERE (ct.prev_type IS NULL)
        UNION ALL
         SELECT ((ct.id * 100) + 20),
            2,
            ct.id,
            ct.fin_cheque_note_id,
            ct.acc_account_id,
            ct.transaction_date,
            ct.document_no,
            ct.description,
            ct.currency,
            ct.amount,
            0
           FROM ct
          WHERE ((ct.prev_type IS NOT NULL) AND (ct.transaction_type = 2) AND (ct.acc_account_id IS NOT NULL))
        UNION ALL
         SELECT ((ct.id * 100) + 20),
            2,
            ct.id,
            ct.fin_cheque_note_id,
            ct.note_account_id,
            ct.transaction_date,
            ct.document_no,
            ct.description,
            ct.currency,
                CASE
                    WHEN (ct.direction = 1) THEN ct.amount
                    ELSE (0)::numeric
                END AS "case",
                CASE
                    WHEN (ct.direction = 2) THEN ct.amount
                    ELSE (0)::numeric
                END AS "case"
           FROM ct
          WHERE ((ct.prev_type IS NOT NULL) AND (ct.transaction_type = 6))
        UNION ALL
         SELECT ((ct.id * 100) + 21),
            2,
            ct.id,
            ct.fin_cheque_note_id,
            ct.prev_account_id,
            ct.transaction_date,
            ct.document_no,
            ct.description,
            ct.currency,
            0,
            ct.amount
           FROM ct
          WHERE ((ct.prev_type = 2) AND (ct.transaction_type = ANY (ARRAY[1, 6])) AND (ct.prev_account_id IS NOT NULL))
        UNION ALL
         SELECT ((ct.id * 100) + 20),
            2,
            ct.id,
            ct.fin_cheque_note_id,
                CASE
                    WHEN (ct.direction = 1) THEN COALESCE(ct.acc_account_id, ct.note_account_id)
                    ELSE ct.note_account_id
                END AS note_account_id,
            ct.transaction_date,
            ct.document_no,
            ct.description,
            ct.currency,
                CASE
                    WHEN (ct.direction = 1) THEN ct.amount
                    ELSE (0)::numeric
                END AS "case",
                CASE
                    WHEN (ct.direction = 2) THEN ct.amount
                    ELSE (0)::numeric
                END AS "case"
           FROM ct
          WHERE ((ct.prev_type IS NOT NULL) AND (ct.transaction_type = 7))
        UNION ALL
         SELECT ((t.id * 100) + 30),
            3,
            t.id,
            t.id,
            t.acc_account_id,
            t.transaction_date,
            p.pos_name,
            t.description,
            p.currency,
                CASE
                    WHEN (t.transaction_type = 2) THEN t.amount
                    ELSE (0)::numeric
                END AS "case",
                CASE
                    WHEN (t.transaction_type = 1) THEN t.amount
                    ELSE (0)::numeric
                END AS "case"
           FROM (public.fin_pos_transaction t
             JOIN public.fin_pos_terminal p ON ((p.id = t.fin_pos_terminal_id)))
        UNION ALL
         SELECT ((t.id * 100) + 40),
            4,
            t.id,
            t.id,
            t.acc_account_id,
            t.transaction_date,
            c.card_name,
            t.description,
            c.currency,
                CASE
                    WHEN (t.transaction_type = 1) THEN t.amount
                    ELSE (0)::numeric
                END AS "case",
                CASE
                    WHEN (t.transaction_type = 3) THEN t.amount
                    ELSE (0)::numeric
                END AS "case"
           FROM (public.fin_credit_card_transaction t
             JOIN public.fin_credit_card c ON ((c.id = t.fin_credit_card_id)))
          WHERE ((t.acc_account_id IS NOT NULL) AND (t.transaction_type = ANY (ARRAY[1, 3])))
        UNION ALL
         SELECT ((f.id * 100) + 50),
            5,
            f.id,
            f.id,
            f.acc_account_id,
            f.invoice_date,
            f.invoice_no,
            f.description,
            f.currency,
            0,
            f.total_amount
           FROM public.pur_invoice f
        UNION ALL
         SELECT ((f.id * 100) + 60),
            6,
            f.id,
            f.id,
            f.acc_account_id,
            f.invoice_date,
            f.invoice_no,
            f.description,
            f.currency,
            (f.total_amount - f.withholding_amount),
            0
           FROM public.sls_invoice f
        )
 SELECT l.id,
    l.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    l.transaction_date,
    l.source_type,
    l.source_id,
    l.document_id,
    l.document_no,
    l.description,
    l.currency,
    (l.debit)::numeric(18,2) AS debit,
    (l.credit)::numeric(18,2) AS credit,
    (sum((l.debit - l.credit)) OVER (PARTITION BY l.acc_account_id, l.currency ORDER BY l.transaction_date, l.id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))::numeric(18,2) AS balance
   FROM (lines l
     JOIN public.acc_account a ON ((a.id = l.acc_account_id)));


ALTER VIEW public.vw_acc_account_transaction OWNER TO ths_admin;

--
-- Name: vw_acc_bank; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_bank AS
 SELECT id,
    bank_name,
    swift_code
   FROM public.acc_bank b;


ALTER VIEW public.vw_acc_bank OWNER TO ths_admin;

--
-- Name: vw_acc_bank_branch; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_bank_branch AS
 SELECT br.id,
    br.acc_bank_id,
    b.bank_name,
    br.branch_code,
    br.branch_name,
    br.sys_city_id,
    c.city_name
   FROM ((public.acc_bank_branch br
     LEFT JOIN public.acc_bank b ON ((b.id = br.acc_bank_id)))
     LEFT JOIN public.sys_city c ON ((c.id = br.sys_city_id)));


ALTER VIEW public.vw_acc_bank_branch OWNER TO ths_admin;

--
-- Name: vw_acc_exchange_rate; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_exchange_rate AS
 SELECT id,
    rate_date,
    currency,
    rate,
    forex_selling,
    banknote_buying,
    banknote_selling,
    source
   FROM public.acc_exchange_rate r;


ALTER VIEW public.vw_acc_exchange_rate OWNER TO ths_admin;

--
-- Name: vw_acc_group; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_group AS
 SELECT id,
    name
   FROM public.acc_group g;


ALTER VIEW public.vw_acc_group OWNER TO ths_admin;

--
-- Name: vw_acc_region; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_region AS
 SELECT id,
    name
   FROM public.acc_region r;


ALTER VIEW public.vw_acc_region OWNER TO ths_admin;

--
-- Name: vw_acc_set_account_type; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_set_account_type AS
 SELECT t.id,
    t.account_type_key,
    (COALESCE(tt.name, t.account_type_key))::character varying(64) AS account_type_name,
    l.locale
   FROM ((public.acc_set_account_type t
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.acc_set_account_type_translation tt ON (((tt.acc_set_account_type_id = t.id) AND (tt.sys_language_id = l.id))));


ALTER VIEW public.vw_acc_set_account_type OWNER TO ths_admin;

--
-- Name: vw_acc_set_company_legal_form; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_set_company_legal_form AS
 SELECT f.id,
    f.legal_form_key,
    (COALESCE(ft.name, f.legal_form_key))::character varying(64) AS legal_form_name,
    f.acc_set_ownership_type_id,
    (COALESCE(ot.name, o.ownership_type_key))::character varying(64) AS ownership_type_name,
    l.locale
   FROM ((((public.acc_set_company_legal_form f
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.acc_set_company_legal_form_translation ft ON (((ft.acc_set_company_legal_form_id = f.id) AND (ft.sys_language_id = l.id))))
     LEFT JOIN public.acc_set_ownership_type o ON ((o.id = f.acc_set_ownership_type_id)))
     LEFT JOIN public.acc_set_ownership_type_translation ot ON (((ot.acc_set_ownership_type_id = o.id) AND (ot.sys_language_id = l.id))));


ALTER VIEW public.vw_acc_set_company_legal_form OWNER TO ths_admin;

--
-- Name: vw_acc_set_ownership_type; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_set_ownership_type AS
 SELECT o.id,
    o.ownership_type_key,
    (COALESCE(ot.name, o.ownership_type_key))::character varying(64) AS ownership_type_name,
    l.locale
   FROM ((public.acc_set_ownership_type o
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.acc_set_ownership_type_translation ot ON (((ot.acc_set_ownership_type_id = o.id) AND (ot.sys_language_id = l.id))));


ALTER VIEW public.vw_acc_set_ownership_type OWNER TO ths_admin;

--
-- Name: vw_acc_set_tax_rate; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_set_tax_rate AS
 SELECT id,
    tax_rate,
    sales_account,
    sales_return_account,
    purchase_account,
    purchase_return_account
   FROM public.acc_set_tax_rate tr;


ALTER VIEW public.vw_acc_set_tax_rate OWNER TO ths_admin;

--
-- Name: vw_acc_transfer_code; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_transfer_code AS
 SELECT tc.id,
    tc.transfer_code,
    tc.description,
    tc.account,
    a.name AS account_name
   FROM (public.acc_transfer_code tc
     LEFT JOIN public.acc_account a ON (((a.code)::text = (tc.account)::text)));


ALTER VIEW public.vw_acc_transfer_code OWNER TO ths_admin;

--
-- Name: vw_acc_voucher; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_voucher AS
 SELECT id,
    voucher_no,
    voucher_date,
    voucher_type,
    journal_no,
    description,
    total_debit,
    total_credit,
    (( SELECT count(*) AS count
           FROM public.acc_voucher_detail d
          WHERE (d.acc_voucher_id = v.id)))::integer AS line_count
   FROM public.acc_voucher v;


ALTER VIEW public.vw_acc_voucher OWNER TO ths_admin;

--
-- Name: vw_acc_voucher_detail; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_voucher_detail AS
 SELECT d.id,
    d.acc_voucher_id,
    v.voucher_no,
    v.voucher_date,
    d.line_no,
    d.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    d.description,
    d.debit,
    d.credit
   FROM ((public.acc_voucher_detail d
     JOIN public.acc_voucher v ON ((v.id = d.acc_voucher_id)))
     JOIN public.acc_account a ON ((a.id = d.acc_account_id)));


ALTER VIEW public.vw_acc_voucher_detail OWNER TO ths_admin;

--
-- Name: vw_einv_delivery_term; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_einv_delivery_term AS
 SELECT id,
    code,
    name,
    is_incoterms,
    is_active
   FROM public.einv_delivery_term x;


ALTER VIEW public.vw_einv_delivery_term OWNER TO ths_admin;

--
-- Name: vw_einv_diib; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_einv_diib AS
 SELECT d.id,
    d.document_no,
    d.holder_type,
    d.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    d.issue_date,
    d.valid_until,
    d.description,
    d.is_active,
    (( SELECT count(*) AS count
           FROM public.einv_diib_line l
          WHERE (l.einv_diib_id = d.id)))::integer AS line_count
   FROM (public.einv_diib d
     LEFT JOIN public.acc_account a ON ((a.id = d.acc_account_id)));


ALTER VIEW public.vw_einv_diib OWNER TO ths_admin;

--
-- Name: vw_einv_diib_line; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_einv_diib_line AS
 SELECT l.id,
    l.einv_diib_id,
    d.document_no,
    d.holder_type,
    d.acc_account_id,
    a.name AS account_name,
    l.line_code,
    l.line_kind,
    l.einv_gtip_id,
    g.code AS gtip_code,
    g.name AS gtip_name,
    l.product_description,
    l.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    l.quantity,
    l.sys_uom_id,
    u.unit_code,
    u.unit_einv AS uom_einv_code,
    l.is_active,
    d.is_active AS diib_is_active,
    d.valid_until,
    l.line_no
   FROM (((((public.einv_diib_line l
     JOIN public.einv_diib d ON ((d.id = l.einv_diib_id)))
     JOIN public.einv_gtip g ON ((g.id = l.einv_gtip_id)))
     LEFT JOIN public.acc_account a ON ((a.id = d.acc_account_id)))
     LEFT JOIN public.stk_inventory i ON ((i.id = l.stk_inventory_id)))
     LEFT JOIN public.sys_uom u ON ((u.id = l.sys_uom_id)));


ALTER VIEW public.vw_einv_diib_line OWNER TO postgres;

--
-- Name: vw_einv_document; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_einv_document AS
 SELECT d.id,
    d.sls_invoice_id,
    d.einv_uuid,
    d.einv_no,
    d.xml_content,
    d.generated_at,
    d.is_valid,
    d.validation_message,
    f.invoice_no,
    d.sls_dispatch_id,
    s.dispatch_no,
    d.provider_code,
    d.provider_ref,
    d.sent_at,
    d.status_code,
    d.status_message,
    d.status_at
   FROM ((public.einv_document d
     LEFT JOIN public.sls_invoice f ON ((f.id = d.sls_invoice_id)))
     LEFT JOIN public.sls_dispatch s ON ((s.id = d.sls_dispatch_id)));


ALTER VIEW public.vw_einv_document OWNER TO ths_admin;

--
-- Name: vw_einv_document_setting; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_einv_document_setting AS
 SELECT d.id,
    d.sys_application_setting_id,
    d.series_scope,
    d.einv_series_id,
    s.code AS series_code,
    s.name AS series_name,
    d.sys_api_service_id,
    a.service_kind,
    a.provider_code,
    a.environment,
    d.sender_alias,
    d.receiver_alias
   FROM ((public.einv_document_setting d
     LEFT JOIN public.einv_series s ON ((s.id = d.einv_series_id)))
     LEFT JOIN public.sys_api_service a ON ((a.id = d.sys_api_service_id)));


ALTER VIEW public.vw_einv_document_setting OWNER TO ths_admin;

--
-- Name: vw_einv_driver; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_einv_driver AS
 SELECT id,
    first_name,
    family_name,
    ((((first_name)::text || ' '::text) || (family_name)::text))::character varying(129) AS full_name,
    national_id,
    phone,
    is_active
   FROM public.einv_driver;


ALTER VIEW public.vw_einv_driver OWNER TO ths_admin;

--
-- Name: vw_einv_gtip; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_einv_gtip AS
 SELECT id,
    code,
    name,
    is_active
   FROM public.einv_gtip x;


ALTER VIEW public.vw_einv_gtip OWNER TO ths_admin;

--
-- Name: vw_einv_invoice_type; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_einv_invoice_type AS
 SELECT id,
    code,
    name,
    requires_exemption,
    requires_withholding,
    is_return,
    is_active
   FROM public.einv_invoice_type x;


ALTER VIEW public.vw_einv_invoice_type OWNER TO ths_admin;

--
-- Name: vw_einv_packaging_type; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_einv_packaging_type AS
 SELECT id,
    code,
    name,
    is_active
   FROM public.einv_packaging_type x;


ALTER VIEW public.vw_einv_packaging_type OWNER TO ths_admin;

--
-- Name: vw_einv_payment_means; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_einv_payment_means AS
 SELECT id,
    code,
    name,
    is_active
   FROM public.einv_payment_means x;


ALTER VIEW public.vw_einv_payment_means OWNER TO ths_admin;

--
-- Name: vw_einv_profile; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_einv_profile AS
 SELECT id,
    code,
    name,
    document_kind,
    requires_export_info,
    is_active
   FROM public.einv_profile x;


ALTER VIEW public.vw_einv_profile OWNER TO ths_admin;

--
-- Name: vw_einv_series; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_einv_series AS
 SELECT s.id,
    s.code,
    s.name,
    s.series_scope,
    s.is_active,
    COALESCE(c.last_number, (0)::bigint) AS last_number
   FROM (public.einv_series s
     LEFT JOIN public.einv_series_counter c ON (((c.einv_series_id = s.id) AND (c.period_year = public.fn_active_period()))));


ALTER VIEW public.vw_einv_series OWNER TO ths_admin;

--
-- Name: vw_einv_tax_exemption; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_einv_tax_exemption AS
 SELECT x.id,
    x.code,
    x.name,
    x.exemption_group,
    x.einv_invoice_type_id,
    t.code AS invoice_type_code,
    x.requires_gtip,
    x.requires_diib,
    x.requires_zero_vat,
    x.is_active
   FROM (public.einv_tax_exemption x
     LEFT JOIN public.einv_invoice_type t ON ((t.id = x.einv_invoice_type_id)));


ALTER VIEW public.vw_einv_tax_exemption OWNER TO ths_admin;

--
-- Name: vw_einv_tax_type; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_einv_tax_type AS
 SELECT id,
    code,
    name,
    short_name,
    is_active
   FROM public.einv_tax_type x;


ALTER VIEW public.vw_einv_tax_type OWNER TO ths_admin;

--
-- Name: vw_einv_transport_mode; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_einv_transport_mode AS
 SELECT id,
    code,
    name,
    is_active
   FROM public.einv_transport_mode x;


ALTER VIEW public.vw_einv_transport_mode OWNER TO ths_admin;

--
-- Name: vw_einv_vehicle; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_einv_vehicle AS
 SELECT id,
    plate_no,
    is_trailer,
    description,
    is_active
   FROM public.einv_vehicle;


ALTER VIEW public.vw_einv_vehicle OWNER TO ths_admin;

--
-- Name: vw_einv_withholding; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_einv_withholding AS
 SELECT id,
    code,
    name,
    rate,
    is_active
   FROM public.einv_withholding x;


ALTER VIEW public.vw_einv_withholding OWNER TO ths_admin;

--
-- Name: vw_emp_driver_ability; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_emp_driver_ability AS
 SELECT d.id,
    d.emp_employee_id,
    e.full_name,
    d.emp_driver_license_type_id,
    lt.license_name
   FROM ((public.emp_driver_ability d
     LEFT JOIN public.emp_employee e ON ((e.id = d.emp_employee_id)))
     LEFT JOIN public.emp_driver_license_type lt ON ((lt.id = d.emp_driver_license_type_id)));


ALTER VIEW public.vw_emp_driver_ability OWNER TO ths_admin;

--
-- Name: vw_emp_driver_license_type; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_emp_driver_license_type AS
 SELECT id,
    license_name
   FROM public.emp_driver_license_type;


ALTER VIEW public.vw_emp_driver_license_type OWNER TO ths_admin;

--
-- Name: vw_emp_employee; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_emp_employee AS
 SELECT e.id,
    e.name,
    e.surname,
    e.full_name,
    e.phone1,
    e.phone2,
    e.emp_person_type_id,
    (COALESCE(ptt.name, pt.person_type_key))::character varying(64) AS person_type,
    e.emp_unit_id,
    (COALESCE(ut.name, u.unit_key))::character varying(64) AS unit_name,
    u.emp_section_id,
    (COALESCE(st.name, s.section_key))::character varying(64) AS section_name,
    e.emp_task_id,
    (COALESCE(tt.name, t.task_key))::character varying(64) AS task_name,
    e.birth_date,
    e.blood_type,
    e.gender,
    e.military_status,
    e.marital_status,
    e.child,
    e.relative_name,
    e.relative_phone,
    e.shoe_size,
    e.clothing_size,
    e.notes,
    e.emp_transportation_id,
    tr.car_name AS transportation_name,
    e.special_notes,
    e.salary_amount,
    e.bonus_count,
    e.bonus_amount,
    e.id_document_no,
    e.active,
    l.locale
   FROM ((((((((((public.emp_employee e
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.emp_person_type pt ON ((pt.id = e.emp_person_type_id)))
     LEFT JOIN public.emp_person_type_translation ptt ON (((ptt.emp_person_type_id = pt.id) AND (ptt.sys_language_id = l.id))))
     LEFT JOIN public.emp_unit u ON ((u.id = e.emp_unit_id)))
     LEFT JOIN public.emp_unit_translation ut ON (((ut.emp_unit_id = u.id) AND (ut.sys_language_id = l.id))))
     LEFT JOIN public.emp_section s ON ((s.id = u.emp_section_id)))
     LEFT JOIN public.emp_section_translation st ON (((st.emp_section_id = s.id) AND (st.sys_language_id = l.id))))
     LEFT JOIN public.emp_task t ON ((t.id = e.emp_task_id)))
     LEFT JOIN public.emp_task_translation tt ON (((tt.emp_task_id = t.id) AND (tt.sys_language_id = l.id))))
     LEFT JOIN public.emp_transportation tr ON ((tr.id = e.emp_transportation_id)));


ALTER VIEW public.vw_emp_employee OWNER TO ths_admin;

--
-- Name: vw_emp_language; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_emp_language AS
 SELECT id,
    language_name
   FROM public.emp_language;


ALTER VIEW public.vw_emp_language OWNER TO ths_admin;

--
-- Name: vw_emp_person_address; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_emp_person_address AS
 SELECT pa.id,
    pa.emp_employee_id,
    e.full_name,
    pa.sys_address_id,
    (concat_ws(', '::text, NULLIF((a.neighborhood)::text, ''::text), NULLIF((a.street)::text, ''::text), NULLIF((a.door_number)::text, ''::text), NULLIF((a.district)::text, ''::text), NULLIF((c.city_name)::text, ''::text)))::character varying(256) AS address_text,
    pa.address_type,
    pa.is_primary,
    pa.valid_from,
    pa.valid_to
   FROM (((public.emp_person_address pa
     LEFT JOIN public.emp_employee e ON ((e.id = pa.emp_employee_id)))
     LEFT JOIN public.sys_address a ON ((a.id = pa.sys_address_id)))
     LEFT JOIN public.sys_city c ON ((c.id = a.sys_city_id)));


ALTER VIEW public.vw_emp_person_address OWNER TO ths_admin;

--
-- Name: vw_emp_person_language_ability; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_emp_person_language_ability AS
 SELECT a.id,
    a.emp_employee_id,
    e.full_name,
    a.emp_language_id,
    lg.language_name,
    a.read_level,
    a.write_level,
    a.speak_level
   FROM ((public.emp_person_language_ability a
     LEFT JOIN public.emp_employee e ON ((e.id = a.emp_employee_id)))
     LEFT JOIN public.emp_language lg ON ((lg.id = a.emp_language_id)));


ALTER VIEW public.vw_emp_person_language_ability OWNER TO ths_admin;

--
-- Name: vw_emp_person_type; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_emp_person_type AS
 SELECT pt.id,
    pt.person_type_key,
    (COALESCE(t.name, pt.person_type_key))::character varying(64) AS person_type,
    l.locale
   FROM ((public.emp_person_type pt
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.emp_person_type_translation t ON (((t.emp_person_type_id = pt.id) AND (t.sys_language_id = l.id))));


ALTER VIEW public.vw_emp_person_type OWNER TO ths_admin;

--
-- Name: vw_emp_section; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_emp_section AS
 SELECT s.id,
    s.section_key,
    (COALESCE(t.name, s.section_key))::character varying(64) AS section_name,
    l.locale
   FROM ((public.emp_section s
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.emp_section_translation t ON (((t.emp_section_id = s.id) AND (t.sys_language_id = l.id))));


ALTER VIEW public.vw_emp_section OWNER TO ths_admin;

--
-- Name: vw_emp_task; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_emp_task AS
 SELECT tk.id,
    tk.task_key,
    (COALESCE(t.name, tk.task_key))::character varying(64) AS task_name,
    l.locale
   FROM ((public.emp_task tk
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.emp_task_translation t ON (((t.emp_task_id = tk.id) AND (t.sys_language_id = l.id))));


ALTER VIEW public.vw_emp_task OWNER TO ths_admin;

--
-- Name: vw_emp_transportation; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_emp_transportation AS
 SELECT id,
    car_no,
    car_name,
    route_description
   FROM public.emp_transportation;


ALTER VIEW public.vw_emp_transportation OWNER TO ths_admin;

--
-- Name: vw_emp_unit; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_emp_unit AS
 SELECT u.id,
    u.unit_key,
    (COALESCE(ut.name, u.unit_key))::character varying(64) AS unit_name,
    u.emp_section_id,
    (COALESCE(st.name, s.section_key))::character varying(64) AS section_name,
    l.locale
   FROM ((((public.emp_unit u
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.emp_unit_translation ut ON (((ut.emp_unit_id = u.id) AND (ut.sys_language_id = l.id))))
     LEFT JOIN public.emp_section s ON ((s.id = u.emp_section_id)))
     LEFT JOIN public.emp_section_translation st ON (((st.emp_section_id = s.id) AND (st.sys_language_id = l.id))));


ALTER VIEW public.vw_emp_unit OWNER TO ths_admin;

--
-- Name: vw_fin_cheque_note; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_fin_cheque_note AS
 SELECT n.id,
    n.doc_kind,
    n.direction,
    n.portfolio_no,
    n.serial_no,
    n.issue_date,
    n.due_date,
    (n.due_date - CURRENT_DATE) AS days_to_due,
    n.amount,
    n.currency,
    n.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    n.drawer_name,
    n.drawer_tax_no,
    n.issue_place,
    n.acc_bank_id,
    b.bank_name,
    n.acc_bank_branch_id,
    br.branch_name,
    n.bank_account_no,
    n.guarantor_name,
    n.fin_company_bank_account_id,
    cba.iban AS company_bank_iban,
    n.status,
    lt.transaction_date AS status_date,
    COALESCE(la.name, lb.bank_name) AS current_holder,
    n.notes
   FROM (((((((public.fin_cheque_note n
     JOIN public.acc_account a ON ((a.id = n.acc_account_id)))
     LEFT JOIN public.acc_bank b ON ((b.id = n.acc_bank_id)))
     LEFT JOIN public.acc_bank_branch br ON ((br.id = n.acc_bank_branch_id)))
     LEFT JOIN public.fin_company_bank_account cba ON ((cba.id = n.fin_company_bank_account_id)))
     LEFT JOIN LATERAL ( SELECT t.transaction_date,
            t.acc_account_id,
            t.acc_bank_id
           FROM public.fin_cheque_note_transaction t
          WHERE (t.fin_cheque_note_id = n.id)
          ORDER BY t.transaction_date DESC, t.id DESC
         LIMIT 1) lt ON (true))
     LEFT JOIN public.acc_account la ON ((la.id = lt.acc_account_id)))
     LEFT JOIN public.acc_bank lb ON ((lb.id = lt.acc_bank_id)));


ALTER VIEW public.vw_fin_cheque_note OWNER TO ths_admin;

--
-- Name: vw_fin_cheque_note_transaction; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_fin_cheque_note_transaction AS
 SELECT t.id,
    t.fin_cheque_note_id,
    n.portfolio_no,
    n.serial_no,
    n.doc_kind,
    n.direction,
    n.due_date,
    n.amount,
    n.currency,
    t.transaction_date,
    t.transaction_type,
    t.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    t.acc_bank_id,
    b.bank_name,
    t.description
   FROM (((public.fin_cheque_note_transaction t
     JOIN public.fin_cheque_note n ON ((n.id = t.fin_cheque_note_id)))
     LEFT JOIN public.acc_account a ON ((a.id = t.acc_account_id)))
     LEFT JOIN public.acc_bank b ON ((b.id = t.acc_bank_id)));


ALTER VIEW public.vw_fin_cheque_note_transaction OWNER TO ths_admin;

--
-- Name: vw_fin_company_bank_account; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_fin_company_bank_account AS
 SELECT a.id,
    a.acc_bank_id,
    b.bank_name,
    b.swift_code,
    a.branch_code,
    a.branch_name,
    a.sys_city_id,
    c.city_name,
    a.account_no,
    a.iban,
    a.currency,
    a.account_holder,
    a.show_on_cheque,
    a.show_on_note,
    a.show_on_print,
    a.sort_order,
    a.is_active,
    a.description,
    concat_ws(' - '::text, b.bank_name, NULLIF(concat_ws(' '::text, NULLIF((a.branch_name)::text, ''::text),
        CASE
            WHEN (a.branch_code IS NOT NULL) THEN (('('::text || (a.branch_code)::text) || ')'::text)
            ELSE NULL::text
        END), ''::text), c.city_name, a.currency,
        CASE
            WHEN (a.account_no IS NOT NULL) THEN ('No: '::text || (a.account_no)::text)
            ELSE NULL::text
        END, ('IBAN: '::text || regexp_replace((a.iban)::text, '(.{4})(?!$)'::text, '\1 '::text, 'g'::text))) AS print_text
   FROM ((public.fin_company_bank_account a
     JOIN public.acc_bank b ON ((b.id = a.acc_bank_id)))
     LEFT JOIN public.sys_city c ON ((c.id = a.sys_city_id)));


ALTER VIEW public.vw_fin_company_bank_account OWNER TO ths_admin;

--
-- Name: vw_fin_credit_card; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_fin_credit_card AS
 SELECT c.id,
    c.card_name,
    c.acc_bank_id,
    b.bank_name,
    c.card_holder,
    c.card_last_digits,
    c.card_limit,
    c.statement_day,
    c.payment_day,
    c.currency,
    c.acc_account_code,
    a.name AS account_name,
    c.is_active,
    (COALESCE(s.total_spending, (0)::numeric))::numeric(18,2) AS total_spending,
    (COALESCE(s.total_payment, (0)::numeric))::numeric(18,2) AS total_payment,
    (COALESCE(s.balance, (0)::numeric))::numeric(18,2) AS balance,
    ((c.card_limit - COALESCE(s.balance, (0)::numeric)))::numeric(18,2) AS available_limit,
    c.notes
   FROM (((public.fin_credit_card c
     JOIN public.acc_bank b ON ((b.id = c.acc_bank_id)))
     LEFT JOIN public.acc_account a ON (((a.code)::text = (c.acc_account_code)::text)))
     LEFT JOIN ( SELECT t.fin_credit_card_id,
            sum(t.amount) FILTER (WHERE (t.transaction_type = 1)) AS total_spending,
            sum(t.amount) FILTER (WHERE (t.transaction_type = 2)) AS total_payment,
            sum(
                CASE
                    WHEN (t.transaction_type = 1) THEN t.amount
                    ELSE (- t.amount)
                END) AS balance
           FROM public.fin_credit_card_transaction t
          GROUP BY t.fin_credit_card_id) s ON ((s.fin_credit_card_id = c.id)));


ALTER VIEW public.vw_fin_credit_card OWNER TO ths_admin;

--
-- Name: vw_fin_credit_card_transaction; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_fin_credit_card_transaction AS
 SELECT t.id,
    t.fin_credit_card_id,
    c.card_name,
    c.currency,
    t.transaction_date,
    t.transaction_type,
    t.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    t.amount,
    t.installment_count,
    (round((t.amount / (t.installment_count)::numeric), 2))::numeric(18,2) AS installment_amount,
    t.description
   FROM ((public.fin_credit_card_transaction t
     JOIN public.fin_credit_card c ON ((c.id = t.fin_credit_card_id)))
     LEFT JOIN public.acc_account a ON ((a.id = t.acc_account_id)));


ALTER VIEW public.vw_fin_credit_card_transaction OWNER TO ths_admin;

--
-- Name: vw_fin_money_ledger; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_fin_money_ledger AS
 WITH lines AS (
         SELECT (t.id * 2) AS id,
            t.id AS fin_money_transaction_id,
            t.fin_money_account_id,
            t.target_fin_money_account_id AS other_fin_money_account_id,
                CASE
                    WHEN (t.transaction_type = ANY (ARRAY[1, 5, 6])) THEN 1
                    ELSE 2
                END AS direction,
            t.transaction_date,
            t.transaction_type,
            t.transfer_method,
            t.acc_account_id,
            t.amount,
            t.document_no,
            t.counterparty_name,
            t.description
           FROM public.fin_money_transaction t
        UNION ALL
         SELECT ((t.id * 2) + 1),
            t.id,
            t.target_fin_money_account_id,
            t.fin_money_account_id,
            1,
            t.transaction_date,
            t.transaction_type,
            t.transfer_method,
            t.acc_account_id,
            t.amount,
            t.document_no,
            t.counterparty_name,
            t.description
           FROM public.fin_money_transaction t
          WHERE (t.transaction_type = 3)
        )
 SELECT l.id,
    l.fin_money_transaction_id,
    l.fin_money_account_id,
    m.name AS money_account_name,
    m.currency,
    l.transaction_date,
    l.transaction_type,
    l.transfer_method,
    l.direction,
    (
        CASE
            WHEN (l.direction = 1) THEN l.amount
            ELSE (0)::numeric
        END)::numeric(18,2) AS amount_in,
    (
        CASE
            WHEN (l.direction = 2) THEN l.amount
            ELSE (0)::numeric
        END)::numeric(18,2) AS amount_out,
    (sum(
        CASE
            WHEN (l.direction = 1) THEN l.amount
            ELSE (- l.amount)
        END) OVER (PARTITION BY l.fin_money_account_id ORDER BY l.transaction_date, l.id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))::numeric(18,2) AS balance,
    l.other_fin_money_account_id,
    o.name AS other_money_account_name,
    l.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    l.document_no,
    l.counterparty_name,
    l.description
   FROM (((lines l
     JOIN public.fin_money_account m ON ((m.id = l.fin_money_account_id)))
     LEFT JOIN public.fin_money_account o ON ((o.id = l.other_fin_money_account_id)))
     LEFT JOIN public.acc_account a ON ((a.id = l.acc_account_id)));


ALTER VIEW public.vw_fin_money_ledger OWNER TO ths_admin;

--
-- Name: vw_fin_money_account; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_fin_money_account AS
 SELECT m.id,
    m.account_kind,
    m.code,
    m.name,
    m.acc_bank_id,
    b.bank_name,
    m.acc_bank_branch_id,
    br.branch_name,
    m.account_no,
    m.iban,
    m.currency,
    m.acc_account_code,
    a.name AS account_name,
    m.is_active,
    (COALESCE(s.total_in, (0)::numeric))::numeric(18,2) AS total_in,
    (COALESCE(s.total_out, (0)::numeric))::numeric(18,2) AS total_out,
    ((COALESCE(s.total_in, (0)::numeric) - COALESCE(s.total_out, (0)::numeric)))::numeric(18,2) AS balance,
    m.notes
   FROM ((((public.fin_money_account m
     LEFT JOIN public.acc_bank b ON ((b.id = m.acc_bank_id)))
     LEFT JOIN public.acc_bank_branch br ON ((br.id = m.acc_bank_branch_id)))
     LEFT JOIN public.acc_account a ON (((a.code)::text = (m.acc_account_code)::text)))
     LEFT JOIN ( SELECT vw_fin_money_ledger.fin_money_account_id,
            sum(vw_fin_money_ledger.amount_in) AS total_in,
            sum(vw_fin_money_ledger.amount_out) AS total_out
           FROM public.vw_fin_money_ledger
          GROUP BY vw_fin_money_ledger.fin_money_account_id) s ON ((s.fin_money_account_id = m.id)));


ALTER VIEW public.vw_fin_money_account OWNER TO ths_admin;

--
-- Name: vw_fin_money_transaction; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_fin_money_transaction AS
 SELECT t.id,
    t.fin_money_account_id,
    m.name AS money_account_name,
    m.account_kind,
    m.currency,
    t.transaction_date,
    t.transaction_type,
    t.transfer_method,
    t.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    t.target_fin_money_account_id,
    tm.name AS target_money_account_name,
    t.amount,
    t.document_no,
    t.counterparty_name,
    t.counterparty_iban,
    t.description
   FROM (((public.fin_money_transaction t
     JOIN public.fin_money_account m ON ((m.id = t.fin_money_account_id)))
     LEFT JOIN public.fin_money_account tm ON ((tm.id = t.target_fin_money_account_id)))
     LEFT JOIN public.acc_account a ON ((a.id = t.acc_account_id)));


ALTER VIEW public.vw_fin_money_transaction OWNER TO ths_admin;

--
-- Name: vw_fin_pos_terminal; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_fin_pos_terminal AS
 SELECT p.id,
    p.pos_name,
    p.acc_bank_id,
    b.bank_name,
    p.terminal_no,
    p.commission_rate,
    p.blocked_days,
    p.currency,
    p.acc_account_code,
    a.name AS account_name,
    p.is_active,
    (COALESCE(s.total_amount, (0)::numeric))::numeric(18,2) AS total_amount,
    (COALESCE(s.total_commission, (0)::numeric))::numeric(18,2) AS total_commission,
    (COALESCE(s.total_net, (0)::numeric))::numeric(18,2) AS total_net,
    p.notes
   FROM (((public.fin_pos_terminal p
     JOIN public.acc_bank b ON ((b.id = p.acc_bank_id)))
     LEFT JOIN public.acc_account a ON (((a.code)::text = (p.acc_account_code)::text)))
     LEFT JOIN ( SELECT t.fin_pos_terminal_id,
            sum(
                CASE
                    WHEN (t.transaction_type = 1) THEN t.amount
                    ELSE (- t.amount)
                END) AS total_amount,
            sum(
                CASE
                    WHEN (t.transaction_type = 1) THEN t.commission_amount
                    ELSE (- t.commission_amount)
                END) AS total_commission,
            sum(
                CASE
                    WHEN (t.transaction_type = 1) THEN t.net_amount
                    ELSE (- t.net_amount)
                END) AS total_net
           FROM public.fin_pos_transaction t
          GROUP BY t.fin_pos_terminal_id) s ON ((s.fin_pos_terminal_id = p.id)));


ALTER VIEW public.vw_fin_pos_terminal OWNER TO ths_admin;

--
-- Name: vw_fin_pos_transaction; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_fin_pos_transaction AS
 SELECT t.id,
    t.fin_pos_terminal_id,
    p.pos_name,
    p.currency,
    t.transaction_date,
    t.transaction_type,
    t.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    t.amount,
    t.installment_count,
    t.commission_rate,
    t.commission_amount,
    t.net_amount,
    t.value_date,
    t.card_holder,
    t.card_last_digits,
    t.description
   FROM ((public.fin_pos_transaction t
     JOIN public.fin_pos_terminal p ON ((p.id = t.fin_pos_terminal_id)))
     JOIN public.acc_account a ON ((a.id = t.acc_account_id)));


ALTER VIEW public.vw_fin_pos_transaction OWNER TO ths_admin;

--
-- Name: vw_prd_bom; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_prd_bom AS
 SELECT b.id,
    b.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    b.bom_name,
    b.base_quantity,
    b.is_default,
    b.is_active,
    b.description,
    ( SELECT count(*) AS count
           FROM public.prd_bom_raw r
          WHERE (r.prd_bom_id = b.id)) AS raw_count,
    ( SELECT count(*) AS count
           FROM public.prd_bom_labour bl
          WHERE (bl.prd_bom_id = b.id)) AS labour_count
   FROM (public.prd_bom b
     LEFT JOIN public.stk_inventory i ON ((i.id = b.stk_inventory_id)));


ALTER VIEW public.vw_prd_bom OWNER TO ths_admin;

--
-- Name: vw_prd_bom_by_product; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_prd_bom_by_product AS
 SELECT p.id,
    p.prd_bom_id,
    b.bom_name,
    p.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    p.quantity,
    p.line_no
   FROM ((public.prd_bom_by_product p
     LEFT JOIN public.prd_bom b ON ((b.id = p.prd_bom_id)))
     LEFT JOIN public.stk_inventory i ON ((i.id = p.stk_inventory_id)));


ALTER VIEW public.vw_prd_bom_by_product OWNER TO ths_admin;

--
-- Name: vw_prd_bom_labour; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_prd_bom_labour AS
 SELECT bl.id,
    bl.prd_bom_id,
    b.bom_name,
    bl.prd_labour_id,
    l.code AS labour_code,
    l.name AS labour_name,
    bl.quantity,
    l.unit_price,
    l.currency,
    round((bl.quantity * l.unit_price), 6) AS total_amount,
    bl.line_no
   FROM ((public.prd_bom_labour bl
     LEFT JOIN public.prd_bom b ON ((b.id = bl.prd_bom_id)))
     LEFT JOIN public.prd_labour l ON ((l.id = bl.prd_labour_id)));


ALTER VIEW public.vw_prd_bom_labour OWNER TO ths_admin;

--
-- Name: vw_prd_bom_packet_labour; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_prd_bom_packet_labour AS
 SELECT bp.id,
    bp.prd_bom_id,
    b.bom_name,
    bp.prd_packet_labour_id,
    p.packet_name,
    bp.quantity,
    bp.line_no
   FROM ((public.prd_bom_packet_labour bp
     LEFT JOIN public.prd_bom b ON ((b.id = bp.prd_bom_id)))
     LEFT JOIN public.prd_packet_labour p ON ((p.id = bp.prd_packet_labour_id)));


ALTER VIEW public.vw_prd_bom_packet_labour OWNER TO ths_admin;

--
-- Name: vw_prd_bom_packet_raw; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_prd_bom_packet_raw AS
 SELECT bp.id,
    bp.prd_bom_id,
    b.bom_name,
    bp.prd_packet_raw_id,
    p.packet_name,
    bp.quantity,
    bp.line_no
   FROM ((public.prd_bom_packet_raw bp
     LEFT JOIN public.prd_bom b ON ((b.id = bp.prd_bom_id)))
     LEFT JOIN public.prd_packet_raw p ON ((p.id = bp.prd_packet_raw_id)));


ALTER VIEW public.vw_prd_bom_packet_raw OWNER TO ths_admin;

--
-- Name: vw_prd_bom_raw; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_prd_bom_raw AS
 SELECT r.id,
    r.prd_bom_id,
    b.bom_name,
    r.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    r.sub_prd_bom_id,
    sb.bom_name AS sub_bom_name,
    r.quantity,
    r.scrap_rate,
    round(((r.quantity * (100)::numeric) / ((100)::numeric - r.scrap_rate)), 6) AS gross_quantity,
    r.line_no
   FROM (((public.prd_bom_raw r
     LEFT JOIN public.prd_bom b ON ((b.id = r.prd_bom_id)))
     LEFT JOIN public.stk_inventory i ON ((i.id = r.stk_inventory_id)))
     LEFT JOIN public.prd_bom sb ON ((sb.id = r.sub_prd_bom_id)));


ALTER VIEW public.vw_prd_bom_raw OWNER TO ths_admin;

--
-- Name: vw_prd_labour; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_prd_labour AS
 SELECT l.id,
    l.code,
    l.name,
    l.cost_type,
    l.sys_uom_id,
    u.unit_code AS uom_code,
    l.unit_price,
    l.currency,
    l.acc_account_code,
    a.name AS account_name
   FROM ((public.prd_labour l
     LEFT JOIN public.sys_uom u ON ((u.id = l.sys_uom_id)))
     LEFT JOIN public.acc_account a ON (((a.code)::text = (l.acc_account_code)::text)));


ALTER VIEW public.vw_prd_labour OWNER TO ths_admin;

--
-- Name: vw_prd_packet_labour; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_prd_packet_labour AS
 SELECT id,
    packet_name,
    ( SELECT count(*) AS count
           FROM public.prd_packet_labour_detail d
          WHERE (d.prd_packet_labour_id = p.id)) AS item_count
   FROM public.prd_packet_labour p;


ALTER VIEW public.vw_prd_packet_labour OWNER TO ths_admin;

--
-- Name: vw_prd_packet_labour_detail; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_prd_packet_labour_detail AS
 SELECT d.id,
    d.prd_packet_labour_id,
    p.packet_name,
    d.prd_labour_id,
    l.code AS labour_code,
    l.name AS labour_name,
    d.quantity,
    l.unit_price,
    l.currency,
    round((d.quantity * l.unit_price), 6) AS total_amount,
    d.line_no
   FROM ((public.prd_packet_labour_detail d
     LEFT JOIN public.prd_packet_labour p ON ((p.id = d.prd_packet_labour_id)))
     LEFT JOIN public.prd_labour l ON ((l.id = d.prd_labour_id)));


ALTER VIEW public.vw_prd_packet_labour_detail OWNER TO ths_admin;

--
-- Name: vw_prd_packet_raw; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_prd_packet_raw AS
 SELECT id,
    packet_name,
    ( SELECT count(*) AS count
           FROM public.prd_packet_raw_detail d
          WHERE (d.prd_packet_raw_id = p.id)) AS item_count
   FROM public.prd_packet_raw p;


ALTER VIEW public.vw_prd_packet_raw OWNER TO ths_admin;

--
-- Name: vw_prd_packet_raw_detail; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_prd_packet_raw_detail AS
 SELECT d.id,
    d.prd_packet_raw_id,
    p.packet_name,
    d.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    d.sub_prd_bom_id,
    sb.bom_name AS sub_bom_name,
    d.quantity,
    d.line_no
   FROM (((public.prd_packet_raw_detail d
     LEFT JOIN public.prd_packet_raw p ON ((p.id = d.prd_packet_raw_id)))
     LEFT JOIN public.stk_inventory i ON ((i.id = d.stk_inventory_id)))
     LEFT JOIN public.prd_bom sb ON ((sb.id = d.sub_prd_bom_id)));


ALTER VIEW public.vw_prd_packet_raw_detail OWNER TO ths_admin;

--
-- Name: vw_pur_invoice; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_pur_invoice AS
 SELECT f.id,
    f.invoice_no,
    f.invoice_date,
    f.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    f.due_date,
    f.currency,
    f.exchange_rate,
    f.gross_amount,
    f.discount_amount,
    f.net_amount,
    f.vat_amount,
    f.total_amount,
    (( SELECT count(*) AS count
           FROM public.pur_invoice_detail d
          WHERE (d.pur_invoice_id = f.id)))::integer AS line_count,
    f.description,
    f.account_title,
    f.taxpayer_type,
    f.taxpayer_name,
    f.taxpayer_name2,
    f.taxpayer_surname,
    f.tax_office,
    f.tax_no
   FROM (public.pur_invoice f
     JOIN public.acc_account a ON ((a.id = f.acc_account_id)));


ALTER VIEW public.vw_pur_invoice OWNER TO ths_admin;

--
-- Name: vw_pur_invoice_detail; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_pur_invoice_detail AS
 SELECT d.id,
    d.pur_invoice_id,
    f.invoice_no,
    f.acc_account_id,
    f.currency,
    d.line_no,
    d.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    u.unit_code AS uom_code,
    d.quantity,
    d.unit_price,
    d.discount_rate,
    d.vat_rate,
    d.gross_amount,
    d.discount_amount,
    d.net_amount,
    d.vat_amount,
    d.total_amount,
    d.pur_receipt_detail_id,
    p.receipt_no,
    d.description
   FROM (((((public.pur_invoice_detail d
     JOIN public.pur_invoice f ON ((f.id = d.pur_invoice_id)))
     JOIN public.stk_inventory i ON ((i.id = d.stk_inventory_id)))
     LEFT JOIN public.sys_uom u ON ((u.id = i.sys_uom_id)))
     LEFT JOIN public.pur_receipt_detail rd ON ((rd.id = d.pur_receipt_detail_id)))
     LEFT JOIN public.pur_receipt p ON ((p.id = rd.pur_receipt_id)));


ALTER VIEW public.vw_pur_invoice_detail OWNER TO ths_admin;

--
-- Name: vw_pur_order; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_pur_order AS
 SELECT o.id,
    o.order_no,
    o.order_date,
    o.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    o.supplier_ref_no,
    o.delivery_date,
    o.stk_warehouse_id,
    w.warehouse_name,
    o.currency,
    o.exchange_rate,
    o.payment_term_days,
    o.status,
    o.gross_amount,
    o.discount_amount,
    o.net_amount,
    o.vat_amount,
    o.total_amount,
    (( SELECT count(*) AS count
           FROM public.pur_order_detail d
          WHERE (d.pur_order_id = o.id)))::integer AS line_count,
    o.description,
    o.account_title,
    o.taxpayer_type,
    o.taxpayer_name,
    o.taxpayer_name2,
    o.taxpayer_surname,
    o.tax_office,
    o.tax_no
   FROM ((public.pur_order o
     JOIN public.acc_account a ON ((a.id = o.acc_account_id)))
     LEFT JOIN public.stk_warehouse w ON ((w.id = o.stk_warehouse_id)));


ALTER VIEW public.vw_pur_order OWNER TO ths_admin;

--
-- Name: vw_pur_order_detail; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_pur_order_detail AS
 SELECT d.id,
    d.pur_order_id,
    o.order_no,
    o.status AS order_status,
    o.acc_account_id,
    o.currency,
    d.line_no,
    d.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    u.unit_code AS uom_code,
    d.quantity,
    d.unit_price,
    d.discount_rate,
    d.vat_rate,
    d.gross_amount,
    d.discount_amount,
    d.net_amount,
    d.vat_amount,
    d.total_amount,
    d.received_quantity,
    (GREATEST((d.quantity - d.received_quantity), (0)::numeric))::numeric(18,6) AS remaining_quantity,
    d.delivery_date,
    d.pur_request_detail_id,
    r.request_no,
    d.description
   FROM (((((public.pur_order_detail d
     JOIN public.pur_order o ON ((o.id = d.pur_order_id)))
     JOIN public.stk_inventory i ON ((i.id = d.stk_inventory_id)))
     LEFT JOIN public.sys_uom u ON ((u.id = i.sys_uom_id)))
     LEFT JOIN public.pur_request_detail rd ON ((rd.id = d.pur_request_detail_id)))
     LEFT JOIN public.pur_request r ON ((r.id = rd.pur_request_id)));


ALTER VIEW public.vw_pur_order_detail OWNER TO ths_admin;

--
-- Name: vw_pur_quotation; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_pur_quotation AS
 SELECT q.id,
    q.quotation_no,
    q.quotation_date,
    q.pur_request_id,
    r.request_no,
    q.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    q.supplier_ref_no,
    q.valid_until,
    q.delivery_days,
    q.delivery_date,
    q.currency,
    q.exchange_rate,
    q.payment_term_days,
    q.payment_terms,
    q.status,
    q.gross_amount,
    q.discount_amount,
    q.net_amount,
    q.vat_amount,
    q.total_amount,
    (round((q.net_amount * q.exchange_rate), 2))::numeric(18,2) AS net_amount_base,
    (round((q.total_amount * q.exchange_rate), 2))::numeric(18,2) AS total_amount_base,
    q.pur_order_id,
    o.order_no,
    q.approved_sys_user_id,
    u.username AS approved_by,
    q.approved_at,
    (( SELECT count(*) AS count
           FROM public.pur_quotation_detail d
          WHERE (d.pur_quotation_id = q.id)))::integer AS line_count,
    q.description,
    q.account_title,
    q.taxpayer_type,
    q.taxpayer_name,
    q.taxpayer_name2,
    q.taxpayer_surname,
    q.tax_office,
    q.tax_no
   FROM ((((public.pur_quotation q
     JOIN public.acc_account a ON ((a.id = q.acc_account_id)))
     LEFT JOIN public.pur_request r ON ((r.id = q.pur_request_id)))
     LEFT JOIN public.pur_order o ON ((o.id = q.pur_order_id)))
     LEFT JOIN public.sys_user u ON ((u.id = q.approved_sys_user_id)));


ALTER VIEW public.vw_pur_quotation OWNER TO ths_admin;

--
-- Name: vw_pur_quotation_comparison; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_pur_quotation_comparison AS
 SELECT d.id,
    rd.pur_request_id,
    r.request_no,
    d.pur_request_detail_id,
    rd.line_no AS request_line_no,
    d.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    u.unit_code AS uom_code,
    rd.quantity AS request_quantity,
    d.pur_quotation_id,
    q.quotation_no,
    q.quotation_date,
    q.status,
    q.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    q.currency,
    q.exchange_rate,
    d.quantity,
    d.unit_price,
    d.discount_rate,
    d.vat_rate,
    (round((d.net_amount / d.quantity), 6))::numeric(18,6) AS net_unit_price,
    (round(((d.net_amount * q.exchange_rate) / d.quantity), 6))::numeric(18,6) AS net_unit_price_base,
    (round((d.net_amount * q.exchange_rate), 2))::numeric(18,2) AS net_amount_base,
    q.delivery_days,
    COALESCE(d.delivery_date, q.delivery_date) AS delivery_date,
    q.payment_term_days,
    q.payment_terms,
    q.valid_until,
    (rank() OVER (PARTITION BY d.pur_request_detail_id ORDER BY (round(((d.net_amount * q.exchange_rate) / d.quantity), 6))))::integer AS price_rank
   FROM ((((((public.pur_quotation_detail d
     JOIN public.pur_quotation q ON ((q.id = d.pur_quotation_id)))
     JOIN public.pur_request_detail rd ON ((rd.id = d.pur_request_detail_id)))
     JOIN public.pur_request r ON ((r.id = rd.pur_request_id)))
     JOIN public.acc_account a ON ((a.id = q.acc_account_id)))
     JOIN public.stk_inventory i ON ((i.id = d.stk_inventory_id)))
     LEFT JOIN public.sys_uom u ON ((u.id = i.sys_uom_id)))
  WHERE (q.status <> 4);


ALTER VIEW public.vw_pur_quotation_comparison OWNER TO ths_admin;

--
-- Name: vw_pur_quotation_detail; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_pur_quotation_detail AS
 SELECT d.id,
    d.pur_quotation_id,
    q.quotation_no,
    q.status AS quotation_status,
    q.acc_account_id,
    q.currency,
    d.line_no,
    d.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    u.unit_code AS uom_code,
    d.quantity,
    d.unit_price,
    d.discount_rate,
    d.vat_rate,
    d.gross_amount,
    d.discount_amount,
    d.net_amount,
    d.vat_amount,
    d.total_amount,
    d.delivery_date,
    d.pur_request_detail_id,
    r.request_no,
    d.description
   FROM (((((public.pur_quotation_detail d
     JOIN public.pur_quotation q ON ((q.id = d.pur_quotation_id)))
     JOIN public.stk_inventory i ON ((i.id = d.stk_inventory_id)))
     LEFT JOIN public.sys_uom u ON ((u.id = i.sys_uom_id)))
     LEFT JOIN public.pur_request_detail rd ON ((rd.id = d.pur_request_detail_id)))
     LEFT JOIN public.pur_request r ON ((r.id = rd.pur_request_id)));


ALTER VIEW public.vw_pur_quotation_detail OWNER TO ths_admin;

--
-- Name: vw_pur_receipt; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_pur_receipt AS
 SELECT p.id,
    p.receipt_no,
    p.receipt_date,
    p.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    p.stk_warehouse_id,
    w.warehouse_name,
    p.waybill_no,
    p.pur_order_id,
    o.order_no,
    p.currency,
    (( SELECT count(*) AS count
           FROM public.pur_receipt_detail d
          WHERE (d.pur_receipt_id = p.id)))::integer AS line_count,
    (( SELECT COALESCE(sum(round((d.quantity * d.unit_price), 2)), (0)::numeric) AS "coalesce"
           FROM public.pur_receipt_detail d
          WHERE (d.pur_receipt_id = p.id)))::numeric(18,2) AS total_amount,
    p.description,
    p.account_title,
    p.taxpayer_type,
    p.taxpayer_name,
    p.taxpayer_name2,
    p.taxpayer_surname,
    p.tax_office,
    p.tax_no
   FROM (((public.pur_receipt p
     JOIN public.acc_account a ON ((a.id = p.acc_account_id)))
     JOIN public.stk_warehouse w ON ((w.id = p.stk_warehouse_id)))
     LEFT JOIN public.pur_order o ON ((o.id = p.pur_order_id)));


ALTER VIEW public.vw_pur_receipt OWNER TO ths_admin;

--
-- Name: vw_pur_receipt_detail; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_pur_receipt_detail AS
 SELECT d.id,
    d.pur_receipt_id,
    p.receipt_no,
    p.acc_account_id,
    p.currency,
    d.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    u.unit_code AS uom_code,
    d.quantity,
    d.unit_price,
    (round((d.quantity * d.unit_price), 2))::numeric(18,2) AS amount,
    d.pur_order_detail_id,
    o.order_no,
    od.line_no AS order_line_no,
    (COALESCE(inv.invoiced_quantity, (0)::numeric))::numeric(18,6) AS invoiced_quantity,
    (GREATEST((d.quantity - COALESCE(inv.invoiced_quantity, (0)::numeric)), (0)::numeric))::numeric(18,6) AS remaining_invoice_quantity,
    d.description,
    d.line_no
   FROM ((((((public.pur_receipt_detail d
     JOIN public.pur_receipt p ON ((p.id = d.pur_receipt_id)))
     JOIN public.stk_inventory i ON ((i.id = d.stk_inventory_id)))
     LEFT JOIN public.sys_uom u ON ((u.id = i.sys_uom_id)))
     LEFT JOIN public.pur_order_detail od ON ((od.id = d.pur_order_detail_id)))
     LEFT JOIN public.pur_order o ON ((o.id = od.pur_order_id)))
     LEFT JOIN ( SELECT pur_invoice_detail.pur_receipt_detail_id,
            sum(pur_invoice_detail.quantity) AS invoiced_quantity
           FROM public.pur_invoice_detail
          WHERE (pur_invoice_detail.pur_receipt_detail_id IS NOT NULL)
          GROUP BY pur_invoice_detail.pur_receipt_detail_id) inv ON ((inv.pur_receipt_detail_id = d.id)));


ALTER VIEW public.vw_pur_receipt_detail OWNER TO ths_admin;

--
-- Name: vw_pur_request; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_pur_request AS
 SELECT r.id,
    r.request_no,
    r.request_date,
    r.emp_employee_id,
    e.full_name AS employee_name,
    r.required_date,
    r.status,
    (( SELECT count(*) AS count
           FROM public.pur_request_detail d
          WHERE (d.pur_request_id = r.id)))::integer AS line_count,
    r.description
   FROM (public.pur_request r
     LEFT JOIN public.emp_employee e ON ((e.id = r.emp_employee_id)));


ALTER VIEW public.vw_pur_request OWNER TO ths_admin;

--
-- Name: vw_pur_request_detail; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_pur_request_detail AS
 SELECT d.id,
    d.pur_request_id,
    r.request_no,
    r.status AS request_status,
    d.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    u.unit_code AS uom_code,
    d.quantity,
    d.ordered_quantity,
    (GREATEST((d.quantity - d.ordered_quantity), (0)::numeric))::numeric(18,6) AS remaining_quantity,
    d.required_date,
    d.description,
    d.line_no
   FROM (((public.pur_request_detail d
     JOIN public.pur_request r ON ((r.id = d.pur_request_id)))
     JOIN public.stk_inventory i ON ((i.id = d.stk_inventory_id)))
     LEFT JOIN public.sys_uom u ON ((u.id = i.sys_uom_id)));


ALTER VIEW public.vw_pur_request_detail OWNER TO ths_admin;

--
-- Name: vw_qc_inspection; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_qc_inspection AS
 SELECT c.id,
    c.inspection_no,
    c.inspection_date,
    c.pur_receipt_detail_id,
    p.id AS pur_receipt_id,
    p.receipt_no,
    p.receipt_date,
    p.acc_account_id,
    a.name AS account_name,
    p.stk_warehouse_id,
    w.warehouse_name,
    rd.line_no AS receipt_line_no,
    c.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    u.unit_code AS uom_code,
    c.quantity,
    c.accepted_quantity,
    c.rejected_quantity,
    c.result,
    c.disposition,
    c.emp_employee_id,
    e.full_name AS employee_name,
    t.id AS stk_transaction_id,
    t.to_stk_warehouse_id AS reject_stk_warehouse_id,
    c.description
   FROM ((((((((public.qc_inspection c
     JOIN public.pur_receipt_detail rd ON ((rd.id = c.pur_receipt_detail_id)))
     JOIN public.pur_receipt p ON ((p.id = rd.pur_receipt_id)))
     JOIN public.acc_account a ON ((a.id = p.acc_account_id)))
     JOIN public.stk_warehouse w ON ((w.id = p.stk_warehouse_id)))
     JOIN public.stk_inventory i ON ((i.id = c.stk_inventory_id)))
     LEFT JOIN public.sys_uom u ON ((u.id = i.sys_uom_id)))
     LEFT JOIN public.emp_employee e ON ((e.id = c.emp_employee_id)))
     LEFT JOIN public.stk_transaction t ON ((t.qc_inspection_id = c.id)));


ALTER VIEW public.vw_qc_inspection OWNER TO ths_admin;

--
-- Name: vw_qc_receipt_line; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_qc_receipt_line AS
 SELECT rd.id,
    p.id AS pur_receipt_id,
    p.receipt_no,
    p.receipt_date,
    p.acc_account_id,
    a.name AS account_name,
    p.stk_warehouse_id,
    w.warehouse_name,
    rd.line_no,
    rd.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    u.unit_code AS uom_code,
    rd.quantity,
    COALESCE(ri.inspection_criteria, rg.inspection_criteria) AS inspection_criteria,
    c.id AS qc_inspection_id,
    c.inspection_no,
    c.inspection_date,
    c.quantity AS inspected_quantity,
    c.accepted_quantity,
    c.rejected_quantity,
    c.result,
    (
        CASE
            WHEN (c.id IS NULL) THEN 1
            WHEN ((c.quantity <> rd.quantity) OR (c.stk_inventory_id <> rd.stk_inventory_id)) THEN 2
            ELSE 3
        END)::smallint AS qc_status
   FROM ((((((((public.pur_receipt_detail rd
     JOIN public.pur_receipt p ON ((p.id = rd.pur_receipt_id)))
     JOIN public.acc_account a ON ((a.id = p.acc_account_id)))
     JOIN public.stk_warehouse w ON ((w.id = p.stk_warehouse_id)))
     JOIN public.stk_inventory i ON ((i.id = rd.stk_inventory_id)))
     LEFT JOIN public.sys_uom u ON ((u.id = i.sys_uom_id)))
     LEFT JOIN public.qc_rule ri ON ((ri.stk_inventory_id = rd.stk_inventory_id)))
     LEFT JOIN public.qc_rule rg ON ((rg.stk_group_id = i.stk_group_id)))
     LEFT JOIN public.qc_inspection c ON ((c.pur_receipt_detail_id = rd.id)))
  WHERE (COALESCE(ri.is_required, rg.is_required, false) AND (EXISTS ( SELECT 1
           FROM public.qc_setting s
          WHERE s.is_enabled)));


ALTER VIEW public.vw_qc_receipt_line OWNER TO ths_admin;

--
-- Name: vw_qc_rule; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_qc_rule AS
 SELECT r.id,
    r.stk_group_id,
    g.name AS group_name,
    r.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    r.is_required,
    r.inspection_criteria
   FROM ((public.qc_rule r
     LEFT JOIN public.stk_group g ON ((g.id = r.stk_group_id)))
     LEFT JOIN public.stk_inventory i ON ((i.id = r.stk_inventory_id)));


ALTER VIEW public.vw_qc_rule OWNER TO ths_admin;

--
-- Name: vw_qc_setting; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_qc_setting AS
 SELECT s.id,
    s.sys_application_setting_id,
    a.company_title,
    s.is_enabled,
    s.reject_stk_warehouse_id,
    w.warehouse_name AS reject_warehouse_name,
    s.description
   FROM ((public.qc_setting s
     JOIN public.sys_application_setting a ON ((a.id = s.sys_application_setting_id)))
     LEFT JOIN public.stk_warehouse w ON ((w.id = s.reject_stk_warehouse_id)));


ALTER VIEW public.vw_qc_setting OWNER TO ths_admin;

--
-- Name: vw_sls_dispatch; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sls_dispatch AS
 SELECT p.id,
    p.dispatch_no,
    p.dispatch_date,
    p.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    p.stk_warehouse_id,
    w.warehouse_name,
    p.sls_order_id,
    o.order_no,
    p.currency,
    (( SELECT count(*) AS count
           FROM public.sls_dispatch_detail d
          WHERE (d.sls_dispatch_id = p.id)))::integer AS line_count,
    (( SELECT COALESCE(sum(round((d.quantity * d.unit_price), 2)), (0)::numeric) AS "coalesce"
           FROM public.sls_dispatch_detail d
          WHERE (d.sls_dispatch_id = p.id)))::numeric(18,2) AS total_amount,
    p.description,
    p.status,
    p.einv_profile_id,
    pr.code AS profile_code,
    (p.einv_uuid)::text AS einv_uuid,
    p.einv_status,
    p.einv_no,
    p.despatch_time,
    p.carrier_acc_account_id,
    ca.code AS carrier_code,
    ca.name AS carrier_name,
    p.einv_vehicle_id,
    v.plate_no AS vehicle_plate,
    p.trailer1_einv_vehicle_id,
    t1.plate_no AS trailer1_plate,
    p.trailer2_einv_vehicle_id,
    t2.plate_no AS trailer2_plate,
    p.driver1_einv_driver_id,
    ((((d1.first_name)::text || ' '::text) || (d1.family_name)::text))::character varying(129) AS driver1_name,
    p.driver2_einv_driver_id,
    ((((d2.first_name)::text || ' '::text) || (d2.family_name)::text))::character varying(129) AS driver2_name,
    a.e_despatch_active AS account_e_despatch_active,
    ed.is_valid AS einv_xml_valid,
    p.account_title,
    p.taxpayer_type,
    p.taxpayer_name,
    p.taxpayer_name2,
    p.taxpayer_surname,
    p.tax_office,
    p.tax_no
   FROM (((((((((((public.sls_dispatch p
     JOIN public.acc_account a ON ((a.id = p.acc_account_id)))
     JOIN public.stk_warehouse w ON ((w.id = p.stk_warehouse_id)))
     LEFT JOIN public.sls_order o ON ((o.id = p.sls_order_id)))
     LEFT JOIN public.einv_profile pr ON ((pr.id = p.einv_profile_id)))
     LEFT JOIN public.acc_account ca ON ((ca.id = p.carrier_acc_account_id)))
     LEFT JOIN public.einv_vehicle v ON ((v.id = p.einv_vehicle_id)))
     LEFT JOIN public.einv_vehicle t1 ON ((t1.id = p.trailer1_einv_vehicle_id)))
     LEFT JOIN public.einv_vehicle t2 ON ((t2.id = p.trailer2_einv_vehicle_id)))
     LEFT JOIN public.einv_driver d1 ON ((d1.id = p.driver1_einv_driver_id)))
     LEFT JOIN public.einv_driver d2 ON ((d2.id = p.driver2_einv_driver_id)))
     LEFT JOIN public.einv_document ed ON ((ed.sls_dispatch_id = p.id)));


ALTER VIEW public.vw_sls_dispatch OWNER TO ths_admin;

--
-- Name: vw_sls_dispatch_detail; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sls_dispatch_detail AS
 SELECT d.id,
    d.sls_dispatch_id,
    p.dispatch_no,
    p.acc_account_id,
    p.currency,
    d.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    u.unit_code AS uom_code,
    d.quantity,
    d.unit_price,
    (round((d.quantity * d.unit_price), 2))::numeric(18,2) AS amount,
    d.sls_order_detail_id,
    o.order_no,
    od.line_no AS order_line_no,
    (COALESCE(inv.invoiced_quantity, (0)::numeric))::numeric(18,6) AS invoiced_quantity,
    (GREATEST((d.quantity - COALESCE(inv.invoiced_quantity, (0)::numeric)), (0)::numeric))::numeric(18,6) AS remaining_invoice_quantity,
    d.description,
    d.line_no
   FROM ((((((public.sls_dispatch_detail d
     JOIN public.sls_dispatch p ON ((p.id = d.sls_dispatch_id)))
     JOIN public.stk_inventory i ON ((i.id = d.stk_inventory_id)))
     LEFT JOIN public.sys_uom u ON ((u.id = i.sys_uom_id)))
     LEFT JOIN public.sls_order_detail od ON ((od.id = d.sls_order_detail_id)))
     LEFT JOIN public.sls_order o ON ((o.id = od.sls_order_id)))
     LEFT JOIN ( SELECT sls_invoice_detail.sls_dispatch_detail_id,
            sum(sls_invoice_detail.quantity) AS invoiced_quantity
           FROM public.sls_invoice_detail
          WHERE (sls_invoice_detail.sls_dispatch_detail_id IS NOT NULL)
          GROUP BY sls_invoice_detail.sls_dispatch_detail_id) inv ON ((inv.sls_dispatch_detail_id = d.id)));


ALTER VIEW public.vw_sls_dispatch_detail OWNER TO ths_admin;

--
-- Name: vw_sls_invoice; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sls_invoice AS
 SELECT f.id,
    f.invoice_no,
    f.invoice_date,
    f.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    f.due_date,
    f.stk_warehouse_id,
    w.warehouse_name,
    f.currency,
    f.exchange_rate,
    f.gross_amount,
    f.discount_amount,
    f.net_amount,
    f.vat_amount,
    f.total_amount,
    (( SELECT count(*) AS count
           FROM public.sls_invoice_detail d
          WHERE (d.sls_invoice_id = f.id)))::integer AS line_count,
    f.description,
    f.einv_profile_id,
    pr.code AS profile_code,
    f.einv_invoice_type_id,
    it.code AS invoice_type_code,
    (f.einv_uuid)::text AS einv_uuid,
    f.einv_status,
    f.einv_tax_exemption_id,
    te.code AS tax_exemption_code,
    te.name AS tax_exemption_name,
    f.einv_delivery_term_id,
    dt.code AS delivery_term_code,
    f.einv_transport_mode_id,
    tm.name AS transport_mode_name,
    f.einv_payment_means_id,
    pm.name AS payment_means_name,
    f.customs_declaration_no,
    f.gtb_ref_no,
    f.actual_export_date,
    f.withholding_amount,
    ((f.total_amount - f.withholding_amount))::numeric(18,2) AS payable_amount,
    a.e_invoice_active AS account_e_invoice_active,
    f.einv_no,
    ed.is_valid AS einv_xml_valid,
    f.account_title,
    f.taxpayer_type,
    f.taxpayer_name,
    f.taxpayer_name2,
    f.taxpayer_surname,
    f.tax_office,
    f.tax_no
   FROM (((((((((public.sls_invoice f
     JOIN public.acc_account a ON ((a.id = f.acc_account_id)))
     LEFT JOIN public.stk_warehouse w ON ((w.id = f.stk_warehouse_id)))
     LEFT JOIN public.einv_profile pr ON ((pr.id = f.einv_profile_id)))
     LEFT JOIN public.einv_invoice_type it ON ((it.id = f.einv_invoice_type_id)))
     LEFT JOIN public.einv_tax_exemption te ON ((te.id = f.einv_tax_exemption_id)))
     LEFT JOIN public.einv_delivery_term dt ON ((dt.id = f.einv_delivery_term_id)))
     LEFT JOIN public.einv_transport_mode tm ON ((tm.id = f.einv_transport_mode_id)))
     LEFT JOIN public.einv_payment_means pm ON ((pm.id = f.einv_payment_means_id)))
     LEFT JOIN public.einv_document ed ON ((ed.sls_invoice_id = f.id)));


ALTER VIEW public.vw_sls_invoice OWNER TO ths_admin;

--
-- Name: vw_sls_invoice_detail; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sls_invoice_detail AS
 SELECT d.id,
    d.sls_invoice_id,
    f.invoice_no,
    f.acc_account_id,
    f.currency,
    d.line_no,
    d.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    u.unit_code AS uom_code,
    d.quantity,
    d.unit_price,
    d.discount_rate,
    d.vat_rate,
    d.gross_amount,
    d.discount_amount,
    d.net_amount,
    d.vat_amount,
    d.total_amount,
    d.sls_dispatch_detail_id,
    p.dispatch_no,
    d.sls_order_detail_id,
    COALESCE(o.order_no, po.order_no) AS order_no,
    d.description,
    d.einv_gtip_id,
    g.code AS gtip_code,
    d.einv_withholding_id,
    wh.code AS withholding_code,
    wh.rate AS withholding_rate,
    d.withholding_amount,
    d.seller_einv_diib_line_id,
    sdl.line_code AS seller_diib_line_code,
    d.buyer_einv_diib_line_id,
    bdl.line_code AS buyer_diib_line_code,
    COALESCE(bdl.product_description, sdl.product_description, i.diib_product_description) AS diib_product_description,
    d.einv_packaging_type_id,
    pk.code AS packaging_type_code,
    d.package_no,
    d.package_quantity,
    d.package_brand,
    u.unit_einv AS uom_einv_code
   FROM (((((((((((((public.sls_invoice_detail d
     JOIN public.sls_invoice f ON ((f.id = d.sls_invoice_id)))
     JOIN public.stk_inventory i ON ((i.id = d.stk_inventory_id)))
     LEFT JOIN public.sys_uom u ON ((u.id = i.sys_uom_id)))
     LEFT JOIN public.sls_dispatch_detail pd ON ((pd.id = d.sls_dispatch_detail_id)))
     LEFT JOIN public.sls_dispatch p ON ((p.id = pd.sls_dispatch_id)))
     LEFT JOIN public.sls_order po ON ((po.id = p.sls_order_id)))
     LEFT JOIN public.sls_order_detail od ON ((od.id = d.sls_order_detail_id)))
     LEFT JOIN public.sls_order o ON ((o.id = od.sls_order_id)))
     LEFT JOIN public.einv_gtip g ON ((g.id = d.einv_gtip_id)))
     LEFT JOIN public.einv_withholding wh ON ((wh.id = d.einv_withholding_id)))
     LEFT JOIN public.einv_diib_line sdl ON ((sdl.id = d.seller_einv_diib_line_id)))
     LEFT JOIN public.einv_diib_line bdl ON ((bdl.id = d.buyer_einv_diib_line_id)))
     LEFT JOIN public.einv_packaging_type pk ON ((pk.id = d.einv_packaging_type_id)));


ALTER VIEW public.vw_sls_invoice_detail OWNER TO ths_admin;

--
-- Name: vw_sls_offer; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sls_offer AS
 SELECT o.id,
    o.offer_no,
    o.offer_date,
    o.valid_until,
    o.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    o.customer_ref_no,
    o.emp_employee_id,
    e.full_name AS employee_name,
    o.currency,
    o.exchange_rate,
    o.payment_term_days,
    o.status,
    o.gross_amount,
    o.discount_amount,
    o.net_amount,
    o.vat_amount,
    o.total_amount,
    (( SELECT count(*) AS count
           FROM public.sls_offer_detail d
          WHERE (d.sls_offer_id = o.id)))::integer AS line_count,
    o.description,
    o.billing_address_id,
    o.billing_sys_address_id,
    (replace((public.fn_sys_address_text(o.billing_sys_address_id, NULL::character varying))::text, '

'::text, ', '::text))::character varying(512) AS billing_address,
    o.shipping_address_id,
    o.shipping_sys_address_id,
    (replace((public.fn_sys_address_text(o.shipping_sys_address_id, NULL::character varying))::text, '

'::text, ', '::text))::character varying(512) AS shipping_address,
    o.base_currency,
    o.usd_rate,
    o.eur_rate,
    ((o.total_amount * o.exchange_rate))::numeric(18,2) AS total_amount_base,
    o.delivery_date,
    o.einv_payment_means_id,
    pm.name AS payment_means_name,
    o.einv_delivery_term_id,
    dt.code AS delivery_term_code,
    dt.name AS delivery_term_name,
    o.tax_office,
    o.tax_no,
    o.sale_type,
    dt.is_incoterms AS delivery_term_is_incoterms,
    o.account_title,
    o.taxpayer_type,
    o.taxpayer_name,
    o.taxpayer_name2,
    o.taxpayer_surname
   FROM ((((public.sls_offer o
     JOIN public.acc_account a ON ((a.id = o.acc_account_id)))
     LEFT JOIN public.emp_employee e ON ((e.id = o.emp_employee_id)))
     LEFT JOIN public.einv_payment_means pm ON ((pm.id = o.einv_payment_means_id)))
     LEFT JOIN public.einv_delivery_term dt ON ((dt.id = o.einv_delivery_term_id)));


ALTER VIEW public.vw_sls_offer OWNER TO ths_admin;

--
-- Name: vw_sls_offer_detail; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sls_offer_detail AS
 SELECT d.id,
    d.sls_offer_id,
    o.offer_no,
    o.status AS offer_status,
    o.acc_account_id,
    o.currency,
    d.line_no,
    d.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    u.unit_code AS uom_code,
    d.quantity,
    d.unit_price,
    d.discount_rate,
    d.vat_rate,
    d.gross_amount,
    d.discount_amount,
    d.net_amount,
    d.vat_amount,
    d.total_amount,
    d.ordered_quantity,
    (GREATEST((d.quantity - d.ordered_quantity), (0)::numeric))::numeric(18,6) AS remaining_quantity,
    d.description
   FROM (((public.sls_offer_detail d
     JOIN public.sls_offer o ON ((o.id = d.sls_offer_id)))
     JOIN public.stk_inventory i ON ((i.id = d.stk_inventory_id)))
     LEFT JOIN public.sys_uom u ON ((u.id = i.sys_uom_id)));


ALTER VIEW public.vw_sls_offer_detail OWNER TO ths_admin;

--
-- Name: vw_sls_order; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sls_order AS
 SELECT o.id,
    o.order_no,
    o.order_date,
    o.acc_account_id,
    a.code AS account_code,
    a.name AS account_name,
    o.customer_ref_no,
    o.delivery_date,
    o.stk_warehouse_id,
    w.warehouse_name,
    o.emp_employee_id,
    e.full_name AS employee_name,
    o.currency,
    o.exchange_rate,
    o.payment_term_days,
    o.status,
    o.gross_amount,
    o.discount_amount,
    o.net_amount,
    o.vat_amount,
    o.total_amount,
    (( SELECT count(*) AS count
           FROM public.sls_order_detail d
          WHERE (d.sls_order_id = o.id)))::integer AS line_count,
    o.description,
    o.account_title,
    o.taxpayer_type,
    o.taxpayer_name,
    o.taxpayer_name2,
    o.taxpayer_surname,
    o.tax_office,
    o.tax_no
   FROM (((public.sls_order o
     JOIN public.acc_account a ON ((a.id = o.acc_account_id)))
     LEFT JOIN public.stk_warehouse w ON ((w.id = o.stk_warehouse_id)))
     LEFT JOIN public.emp_employee e ON ((e.id = o.emp_employee_id)));


ALTER VIEW public.vw_sls_order OWNER TO ths_admin;

--
-- Name: vw_sls_order_detail; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sls_order_detail AS
 SELECT d.id,
    d.sls_order_id,
    o.order_no,
    o.status AS order_status,
    o.acc_account_id,
    o.currency,
    d.line_no,
    d.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    u.unit_code AS uom_code,
    d.quantity,
    d.unit_price,
    d.discount_rate,
    d.vat_rate,
    d.gross_amount,
    d.discount_amount,
    d.net_amount,
    d.vat_amount,
    d.total_amount,
    d.delivered_quantity,
    (GREATEST((d.quantity - d.delivered_quantity), (0)::numeric))::numeric(18,6) AS remaining_quantity,
    d.delivery_date,
    d.sls_offer_detail_id,
    f.offer_no,
    d.description
   FROM (((((public.sls_order_detail d
     JOIN public.sls_order o ON ((o.id = d.sls_order_id)))
     JOIN public.stk_inventory i ON ((i.id = d.stk_inventory_id)))
     LEFT JOIN public.sys_uom u ON ((u.id = i.sys_uom_id)))
     LEFT JOIN public.sls_offer_detail fd ON ((fd.id = d.sls_offer_detail_id)))
     LEFT JOIN public.sls_offer f ON ((f.id = fd.sls_offer_id)));


ALTER VIEW public.vw_sls_order_detail OWNER TO ths_admin;

--
-- Name: vw_stk_card_kind_info; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_stk_card_kind_info AS
 SELECT k.id,
    k.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    k.stk_kind_property_id,
    p.kind AS kind_name,
    k.s1,
    k.s2,
    k.s3,
    k.s4,
    k.s5,
    k.s6,
    k.s7,
    k.s8,
    k.s9,
    k.s10,
    k.i1,
    k.i2,
    k.i3,
    k.i4,
    k.i5,
    k.d1,
    k.d2,
    k.d3,
    k.d4,
    k.d5
   FROM ((public.stk_card_kind_info k
     LEFT JOIN public.stk_inventory i ON ((i.id = k.stk_inventory_id)))
     LEFT JOIN public.stk_kind_property p ON ((p.id = k.stk_kind_property_id)));


ALTER VIEW public.vw_stk_card_kind_info OWNER TO ths_admin;

--
-- Name: vw_stk_group; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_stk_group AS
 SELECT id,
    name,
    vat_rate,
    raw_material_stock_account,
    raw_material_usage_account,
    semi_product_account
   FROM public.stk_group g;


ALTER VIEW public.vw_stk_group OWNER TO ths_admin;

--
-- Name: vw_stk_inventory; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_stk_inventory AS
 SELECT i.id,
    i.code,
    i.name,
    i.sellable,
    i.stk_group_id,
    g.name AS group_name,
    i.sys_uom_id,
    (COALESCE(ut.uom_name, u.unit_code))::character varying(64) AS uom_name,
    i.stk_product_type_id,
    pt.product_type_name,
    i.buying_price,
    i.buying_currency,
    i.buying_discount,
    i.sales_price,
    i.sales_currency,
    i.sales_discount,
    i.export_price,
    i.export_currency,
    i.width,
    i.length,
    i.height,
    i.weight,
    i.supply_duration,
    i.min_stock_amount,
    i.special_code,
    i.brand,
    i.sys_country_id,
    (COALESCE(ct.country_name, c.country_code))::character varying(128) AS country_name,
    i.einv_gtip_id,
    gt.code AS gtip_code,
    gt.name AS gtip_name,
    i.diib_product_description,
    i.product_overview,
    COALESCE(s.current_quantity, (0)::numeric) AS current_quantity,
    COALESCE(s.average_cost, (0)::numeric) AS average_cost,
    i.vat_rate,
    i.raw_material_stock_account,
    i.raw_material_usage_account,
    i.semi_product_account,
    i.sales_account,
    i.sales_return_account,
    i.purchase_account,
    i.purchase_return_account,
    g.vat_rate AS default_vat_rate,
    g.raw_material_stock_account AS default_raw_material_stock_account,
    g.raw_material_usage_account AS default_raw_material_usage_account,
    g.semi_product_account AS default_semi_product_account,
    tr.sales_account AS default_sales_account,
    tr.sales_return_account AS default_sales_return_account,
    tr.purchase_account AS default_purchase_account,
    tr.purchase_return_account AS default_purchase_return_account,
    l.locale
   FROM ((((((((((public.stk_inventory i
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.stk_group g ON ((g.id = i.stk_group_id)))
     LEFT JOIN public.acc_set_tax_rate tr ON ((tr.tax_rate = COALESCE(i.vat_rate, g.vat_rate))))
     LEFT JOIN public.sys_uom u ON ((u.id = i.sys_uom_id)))
     LEFT JOIN public.sys_uom_translation ut ON (((ut.sys_uom_id = u.id) AND (ut.sys_language_id = l.id))))
     LEFT JOIN public.stk_product_type pt ON ((pt.id = i.stk_product_type_id)))
     LEFT JOIN public.sys_country c ON ((c.id = i.sys_country_id)))
     LEFT JOIN public.sys_country_translation ct ON (((ct.sys_country_id = c.id) AND (ct.sys_language_id = l.id))))
     LEFT JOIN public.einv_gtip gt ON ((gt.id = i.einv_gtip_id)))
     LEFT JOIN public.stk_inventory_summary s ON ((s.stk_inventory_id = i.id)));


ALTER VIEW public.vw_stk_inventory OWNER TO ths_admin;

--
-- Name: vw_stk_inventory_account; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_stk_inventory_account AS
 SELECT x.id,
    x.code,
    x.name,
    x.stk_group_id,
    x.group_name,
    x.vat_rate,
    x.is_vat_rate_overridden,
    x.raw_material_stock_account,
    a1.name AS raw_material_stock_account_name,
    x.raw_material_usage_account,
    a2.name AS raw_material_usage_account_name,
    x.semi_product_account,
    a3.name AS semi_product_account_name,
    x.sales_account,
    a4.name AS sales_account_name,
    x.sales_return_account,
    a5.name AS sales_return_account_name,
    x.purchase_account,
    a6.name AS purchase_account_name,
    x.purchase_return_account,
    a7.name AS purchase_return_account_name,
    x.overridden_account_count
   FROM (((((((( SELECT i.id,
            i.code,
            i.name,
            i.stk_group_id,
            g.name AS group_name,
            COALESCE(i.vat_rate, g.vat_rate) AS vat_rate,
            (i.vat_rate IS NOT NULL) AS is_vat_rate_overridden,
            COALESCE(i.raw_material_stock_account, g.raw_material_stock_account) AS raw_material_stock_account,
            COALESCE(i.raw_material_usage_account, g.raw_material_usage_account) AS raw_material_usage_account,
            COALESCE(i.semi_product_account, g.semi_product_account) AS semi_product_account,
            COALESCE(i.sales_account, tr.sales_account) AS sales_account,
            COALESCE(i.sales_return_account, tr.sales_return_account) AS sales_return_account,
            COALESCE(i.purchase_account, tr.purchase_account) AS purchase_account,
            COALESCE(i.purchase_return_account, tr.purchase_return_account) AS purchase_return_account,
            num_nonnulls(i.raw_material_stock_account, i.raw_material_usage_account, i.semi_product_account, i.sales_account, i.sales_return_account, i.purchase_account, i.purchase_return_account) AS overridden_account_count
           FROM ((public.stk_inventory i
             LEFT JOIN public.stk_group g ON ((g.id = i.stk_group_id)))
             LEFT JOIN public.acc_set_tax_rate tr ON ((tr.tax_rate = COALESCE(i.vat_rate, g.vat_rate))))) x
     LEFT JOIN public.acc_account a1 ON (((a1.code)::text = (x.raw_material_stock_account)::text)))
     LEFT JOIN public.acc_account a2 ON (((a2.code)::text = (x.raw_material_usage_account)::text)))
     LEFT JOIN public.acc_account a3 ON (((a3.code)::text = (x.semi_product_account)::text)))
     LEFT JOIN public.acc_account a4 ON (((a4.code)::text = (x.sales_account)::text)))
     LEFT JOIN public.acc_account a5 ON (((a5.code)::text = (x.sales_return_account)::text)))
     LEFT JOIN public.acc_account a6 ON (((a6.code)::text = (x.purchase_account)::text)))
     LEFT JOIN public.acc_account a7 ON (((a7.code)::text = (x.purchase_return_account)::text)));


ALTER VIEW public.vw_stk_inventory_account OWNER TO ths_admin;

--
-- Name: vw_stk_inventory_summary; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_stk_inventory_summary AS
 SELECT s.id,
    s.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    s.current_quantity,
    s.average_cost,
    s.opening_quantity,
    s.opening_price,
    s.opening_amount,
    s.incoming_quantity,
    s.incoming_amount,
    s.outgoing_quantity,
    s.outgoing_amount,
    s.last_buy_date,
    s.last_buy_quantity,
    s.last_buy_price,
    s.last_buy_currency,
    s.last_buy_exchange_rate
   FROM (public.stk_inventory_summary s
     JOIN public.stk_inventory i ON ((i.id = s.stk_inventory_id)));


ALTER VIEW public.vw_stk_inventory_summary OWNER TO ths_admin;

--
-- Name: vw_stk_inventory_warehouse; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_stk_inventory_warehouse AS
 SELECT m.stk_inventory_id,
    m.stk_warehouse_id,
    w.warehouse_name,
    sum(m.quantity) AS quantity
   FROM (( SELECT t.stk_inventory_id,
            t.to_stk_warehouse_id AS stk_warehouse_id,
            t.quantity
           FROM public.stk_transaction t
          WHERE ((t.transaction_type = ANY (ARRAY[1, 3])) AND (t.to_stk_warehouse_id IS NOT NULL))
        UNION ALL
         SELECT t.stk_inventory_id,
            t.from_stk_warehouse_id,
            (- t.quantity)
           FROM public.stk_transaction t
          WHERE ((t.transaction_type = ANY (ARRAY[2, 3])) AND (t.from_stk_warehouse_id IS NOT NULL))) m
     JOIN public.stk_warehouse w ON ((w.id = m.stk_warehouse_id)))
  GROUP BY m.stk_inventory_id, m.stk_warehouse_id, w.warehouse_name;


ALTER VIEW public.vw_stk_inventory_warehouse OWNER TO ths_admin;

--
-- Name: vw_stk_kind_family; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_stk_kind_family AS
 SELECT id,
    family,
    description,
    active
   FROM public.stk_kind_family f;


ALTER VIEW public.vw_stk_kind_family OWNER TO ths_admin;

--
-- Name: vw_stk_kind_property; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_stk_kind_property AS
 SELECT p.id,
    p.kind,
    p.description,
    p.stk_kind_family_id,
    f.family AS family_name,
    p.s1,
    p.s2,
    p.s3,
    p.s4,
    p.s5,
    p.s6,
    p.s7,
    p.s8,
    p.s9,
    p.s10,
    p.i1,
    p.i2,
    p.i3,
    p.i4,
    p.i5,
    p.d1,
    p.d2,
    p.d3,
    p.d4,
    p.d5
   FROM (public.stk_kind_property p
     LEFT JOIN public.stk_kind_family f ON ((f.id = p.stk_kind_family_id)));


ALTER VIEW public.vw_stk_kind_property OWNER TO ths_admin;

--
-- Name: vw_stk_product_type; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_stk_product_type AS
 SELECT id,
    product_type_name,
    description,
    active
   FROM public.stk_product_type t;


ALTER VIEW public.vw_stk_product_type OWNER TO ths_admin;

--
-- Name: vw_stk_transaction; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_stk_transaction AS
 SELECT t.id,
    t.transaction_date,
    t.transaction_type,
    t.stk_inventory_id,
    i.code AS inventory_code,
    i.name AS inventory_name,
    t.from_stk_warehouse_id,
    wf.warehouse_name AS from_warehouse_name,
    t.to_stk_warehouse_id,
    wt.warehouse_name AS to_warehouse_name,
    t.quantity,
    t.amount,
    t.amount_foreign,
    t.currency,
    t.is_opening,
    t.description,
    t.dispatch_id,
    t.production_id
   FROM (((public.stk_transaction t
     LEFT JOIN public.stk_inventory i ON ((i.id = t.stk_inventory_id)))
     LEFT JOIN public.stk_warehouse wf ON ((wf.id = t.from_stk_warehouse_id)))
     LEFT JOIN public.stk_warehouse wt ON ((wt.id = t.to_stk_warehouse_id)));


ALTER VIEW public.vw_stk_transaction OWNER TO ths_admin;

--
-- Name: vw_stk_warehouse; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_stk_warehouse AS
 SELECT id,
    warehouse_name,
    default_raw_material,
    default_production,
    default_sales
   FROM public.stk_warehouse w;


ALTER VIEW public.vw_stk_warehouse OWNER TO ths_admin;

--
-- Name: vw_sys_permission; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_permission AS
 SELECT p.id,
    p.permission_key,
    p.permission_code,
    COALESCE(pt.permission_name, p.permission_key) AS permission_name,
    p.sys_permission_group_id,
    pg.permission_group_key,
    COALESCE(pgt.permission_group_name, pg.permission_group_key) AS permission_group_name,
    l.locale
   FROM ((((public.sys_permission p
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.sys_permission_group pg ON ((pg.id = p.sys_permission_group_id)))
     LEFT JOIN public.sys_permission_translation pt ON (((pt.sys_permission_id = p.id) AND (pt.sys_language_id = l.id))))
     LEFT JOIN public.sys_permission_group_translation pgt ON (((pgt.sys_permission_group_id = pg.id) AND (pgt.sys_language_id = l.id))));


ALTER VIEW public.vw_sys_permission OWNER TO ths_admin;

--
-- Name: vw_sys_access_right; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_access_right AS
 SELECT a.id,
    u.username,
    e.full_name,
    p.permission_code,
    p.permission_name,
    p.permission_group_name,
    a.sys_permission_id,
    a.is_read,
    a.is_add,
    a.is_update,
    a.is_delete,
    a.is_special,
    a.deny_read,
    a.deny_add,
    a.deny_update,
    a.deny_delete,
    a.deny_special,
    a.sys_user_id,
    p.locale
   FROM (((public.sys_access_right a
     JOIN public.vw_sys_permission p ON ((p.id = a.sys_permission_id)))
     JOIN public.sys_user u ON ((u.id = a.sys_user_id)))
     LEFT JOIN public.emp_employee e ON ((e.id = u.emp_employee_id)));


ALTER VIEW public.vw_sys_access_right OWNER TO ths_admin;

--
-- Name: vw_sys_address; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_address AS
 SELECT a.id,
    cnt.country_name,
    ct.city_name,
    a.sys_city_id,
    ct.sys_country_id,
    a.district,
    a.neighborhood,
    a.quarter,
    a.road,
    a.street,
    a.building_name,
    a.door_number,
    a.zip_code,
    a.web,
    a.email,
    l.locale
   FROM (((public.sys_address a
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.sys_city ct ON ((ct.id = a.sys_city_id)))
     LEFT JOIN public.sys_country_translation cnt ON (((cnt.sys_country_id = ct.sys_country_id) AND (cnt.sys_language_id = l.id))));


ALTER VIEW public.vw_sys_address OWNER TO ths_admin;

--
-- Name: vw_sys_api_service; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_api_service AS
 SELECT id,
    sys_application_setting_id,
    service_kind,
    provider_code,
    environment,
    base_url,
    username,
    ((password_enc IS NOT NULL) AND ((password_enc)::text <> ''::text)) AS has_password,
    ((api_key_enc IS NOT NULL) AND ((api_key_enc)::text <> ''::text)) AS has_api_key,
    timeout_seconds,
    (options)::text AS options,
    description,
    is_active
   FROM public.sys_api_service;


ALTER VIEW public.vw_sys_api_service OWNER TO ths_admin;

--
-- Name: vw_sys_audit_log; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_audit_log AS
 SELECT id,
    period_year,
    db_name,
    db_family,
    source_id,
    table_schema,
    table_name,
    row_id AS record_no,
    action,
    changed_at,
    transaction_id,
    db_user,
    app_user,
    (client_addr)::character varying AS client_addr,
    application_name,
    (old_data)::text AS old_data,
    (new_data)::text AS new_data,
    received_at,
        CASE
            WHEN (action = 'U'::bpchar) THEN (( SELECT string_agg(k.k, ', '::text ORDER BY k.k) AS string_agg
               FROM jsonb_object_keys(a.new_data) k(k)))::character varying
            ELSE NULL::character varying
        END AS changed_columns
   FROM audit_remote.audit_log a;


ALTER VIEW public.vw_sys_audit_log OWNER TO ths_admin;

--
-- Name: VIEW vw_sys_audit_log; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON VIEW public.vw_sys_audit_log IS 'İşlem geçmişi (ths_audit.audit_log, postgres_fdw); record_no = kaydın id''si (uzakta row_id). Filtreler uzağa iner.';


--
-- Name: vw_sys_city; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_city AS
 SELECT ct.id,
    ct.city_name,
    ct.car_plate_code,
    ct.sys_country_id,
    ct.sys_region_id,
    cn.country_code,
    (COALESCE(cnt.country_name, cn.country_code))::character varying(128) AS country_name,
    r.region_name,
    l.locale
   FROM ((((public.sys_city ct
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.sys_country cn ON ((cn.id = ct.sys_country_id)))
     LEFT JOIN public.sys_country_translation cnt ON (((cnt.sys_country_id = ct.sys_country_id) AND (cnt.sys_language_id = l.id))))
     LEFT JOIN public.sys_region r ON ((r.id = ct.sys_region_id)));


ALTER VIEW public.vw_sys_city OWNER TO ths_admin;

--
-- Name: vw_sys_country; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_country AS
 SELECT cn.id,
    cn.country_code,
    cn.iso_year,
    cn.iso_cctld,
    cn.is_eu_member,
    (COALESCE(cnt.country_name, cn.country_code))::character varying(128) AS country_name,
    l.locale
   FROM ((public.sys_country cn
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.sys_country_translation cnt ON (((cnt.sys_country_id = cn.id) AND (cnt.sys_language_id = l.id))));


ALTER VIEW public.vw_sys_country OWNER TO ths_admin;

--
-- Name: vw_sys_currency; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_currency AS
 SELECT id,
    currency,
    symbol,
    description
   FROM public.sys_currency;


ALTER VIEW public.vw_sys_currency OWNER TO ths_admin;

--
-- Name: vw_sys_decimal_place; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_decimal_place AS
 SELECT id,
    quantity,
    price,
    total,
    stock_quantity,
    exchange_rate
   FROM public.sys_decimal_place;


ALTER VIEW public.vw_sys_decimal_place OWNER TO ths_admin;

--
-- Name: vw_sys_document; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_document AS
 SELECT 'pur_request'::character varying(32) AS doc_table,
    r.id,
    (r.request_no)::character varying(32) AS doc_no,
    r.request_date AS doc_date,
    NULL::bigint AS acc_account_id,
    NULL::character varying AS account_code,
    (r.employee_name)::character varying AS account_name,
    r.status,
    NULL::character varying(3) AS currency,
    NULL::numeric AS total_amount
   FROM public.vw_pur_request r
UNION ALL
 SELECT 'pur_quotation'::character varying AS doc_table,
    q.id,
    q.quotation_no AS doc_no,
    q.quotation_date AS doc_date,
    q.acc_account_id,
    q.account_code,
    q.account_name,
    q.status,
    q.currency,
    q.total_amount
   FROM public.vw_pur_quotation q
UNION ALL
 SELECT 'pur_order'::character varying AS doc_table,
    o.id,
    o.order_no AS doc_no,
    o.order_date AS doc_date,
    o.acc_account_id,
    o.account_code,
    o.account_name,
    o.status,
    o.currency,
    o.total_amount
   FROM public.vw_pur_order o
UNION ALL
 SELECT 'pur_receipt'::character varying AS doc_table,
    r.id,
    r.receipt_no AS doc_no,
    r.receipt_date AS doc_date,
    r.acc_account_id,
    r.account_code,
    r.account_name,
    NULL::smallint AS status,
    r.currency,
    r.total_amount
   FROM public.vw_pur_receipt r
UNION ALL
 SELECT 'pur_invoice'::character varying AS doc_table,
    i.id,
    i.invoice_no AS doc_no,
    i.invoice_date AS doc_date,
    i.acc_account_id,
    i.account_code,
    i.account_name,
    NULL::smallint AS status,
    i.currency,
    i.total_amount
   FROM public.vw_pur_invoice i
UNION ALL
 SELECT 'sls_offer'::character varying AS doc_table,
    o.id,
    o.offer_no AS doc_no,
    o.offer_date AS doc_date,
    o.acc_account_id,
    o.account_code,
    o.account_name,
    o.status,
    o.currency,
    o.total_amount
   FROM public.vw_sls_offer o
UNION ALL
 SELECT 'sls_order'::character varying AS doc_table,
    o.id,
    o.order_no AS doc_no,
    o.order_date AS doc_date,
    o.acc_account_id,
    o.account_code,
    o.account_name,
    o.status,
    o.currency,
    o.total_amount
   FROM public.vw_sls_order o
UNION ALL
 SELECT 'sls_dispatch'::character varying AS doc_table,
    d.id,
    d.dispatch_no AS doc_no,
    d.dispatch_date AS doc_date,
    d.acc_account_id,
    d.account_code,
    d.account_name,
    d.status,
    d.currency,
    d.total_amount
   FROM public.vw_sls_dispatch d
UNION ALL
 SELECT 'sls_invoice'::character varying AS doc_table,
    i.id,
    i.invoice_no AS doc_no,
    i.invoice_date AS doc_date,
    i.acc_account_id,
    i.account_code,
    i.account_name,
    NULL::smallint AS status,
    i.currency,
    i.total_amount
   FROM public.vw_sls_invoice i;


ALTER VIEW public.vw_sys_document OWNER TO ths_admin;

--
-- Name: vw_sys_document_link; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_document_link AS
 SELECT 'pur_request'::character varying(32) AS from_table,
    q.pur_request_id AS from_id,
    'pur_quotation'::character varying(32) AS to_table,
    q.id AS to_id
   FROM public.pur_quotation q
  WHERE (q.pur_request_id IS NOT NULL)
UNION ALL
 SELECT 'pur_request'::character varying AS from_table,
    rd.pur_request_id AS from_id,
    'pur_order'::character varying AS to_table,
    od.pur_order_id AS to_id
   FROM (public.pur_order_detail od
     JOIN public.pur_request_detail rd ON ((rd.id = od.pur_request_detail_id)))
UNION ALL
 SELECT 'pur_quotation'::character varying AS from_table,
    q.id AS from_id,
    'pur_order'::character varying AS to_table,
    q.pur_order_id AS to_id
   FROM public.pur_quotation q
  WHERE (q.pur_order_id IS NOT NULL)
UNION ALL
 SELECT 'pur_order'::character varying AS from_table,
    r.pur_order_id AS from_id,
    'pur_receipt'::character varying AS to_table,
    r.id AS to_id
   FROM public.pur_receipt r
  WHERE (r.pur_order_id IS NOT NULL)
UNION ALL
 SELECT 'pur_order'::character varying AS from_table,
    od.pur_order_id AS from_id,
    'pur_receipt'::character varying AS to_table,
    rd.pur_receipt_id AS to_id
   FROM (public.pur_receipt_detail rd
     JOIN public.pur_order_detail od ON ((od.id = rd.pur_order_detail_id)))
UNION ALL
 SELECT 'pur_receipt'::character varying AS from_table,
    rd.pur_receipt_id AS from_id,
    'pur_invoice'::character varying AS to_table,
    id.pur_invoice_id AS to_id
   FROM (public.pur_invoice_detail id
     JOIN public.pur_receipt_detail rd ON ((rd.id = id.pur_receipt_detail_id)))
UNION ALL
 SELECT 'sls_offer'::character varying AS from_table,
    ofd.sls_offer_id AS from_id,
    'sls_order'::character varying AS to_table,
    od.sls_order_id AS to_id
   FROM (public.sls_order_detail od
     JOIN public.sls_offer_detail ofd ON ((ofd.id = od.sls_offer_detail_id)))
UNION ALL
 SELECT 'sls_order'::character varying AS from_table,
    d.sls_order_id AS from_id,
    'sls_dispatch'::character varying AS to_table,
    d.id AS to_id
   FROM public.sls_dispatch d
  WHERE (d.sls_order_id IS NOT NULL)
UNION ALL
 SELECT 'sls_order'::character varying AS from_table,
    od.sls_order_id AS from_id,
    'sls_dispatch'::character varying AS to_table,
    dd.sls_dispatch_id AS to_id
   FROM (public.sls_dispatch_detail dd
     JOIN public.sls_order_detail od ON ((od.id = dd.sls_order_detail_id)))
UNION ALL
 SELECT 'sls_dispatch'::character varying AS from_table,
    dd.sls_dispatch_id AS from_id,
    'sls_invoice'::character varying AS to_table,
    id.sls_invoice_id AS to_id
   FROM (public.sls_invoice_detail id
     JOIN public.sls_dispatch_detail dd ON ((dd.id = id.sls_dispatch_detail_id)))
UNION ALL
 SELECT 'sls_order'::character varying AS from_table,
    od.sls_order_id AS from_id,
    'sls_invoice'::character varying AS to_table,
    id.sls_invoice_id AS to_id
   FROM (public.sls_invoice_detail id
     JOIN public.sls_order_detail od ON ((od.id = id.sls_order_detail_id)));


ALTER VIEW public.vw_sys_document_link OWNER TO ths_admin;

--
-- Name: vw_sys_document_tax_summary; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_document_tax_summary AS
 SELECT row_number() OVER (PARTITION BY u.doc_table, u.doc_id ORDER BY u.summary_type, u.tax_rate DESC, w.code) AS id,
    u.doc_table,
    u.doc_id,
    u.summary_type,
    u.tax_rate,
    u.einv_withholding_id,
    w.code AS withholding_code,
    w.name AS withholding_name,
    u.base_amount,
    u.tax_amount
   FROM (( SELECT 'sls_offer'::character varying(32) AS doc_table,
            s.sls_offer_id AS doc_id,
            s.id AS summary_id,
            s.summary_type,
            s.tax_rate,
            s.einv_withholding_id,
            s.base_amount,
            s.tax_amount
           FROM public.sls_offer_tax_summary s
        UNION ALL
         SELECT 'sls_order'::character varying(32) AS doc_table,
            s.sls_order_id AS doc_id,
            s.id AS summary_id,
            s.summary_type,
            s.tax_rate,
            s.einv_withholding_id,
            s.base_amount,
            s.tax_amount
           FROM public.sls_order_tax_summary s
        UNION ALL
         SELECT 'sls_invoice'::character varying(32) AS doc_table,
            s.sls_invoice_id AS doc_id,
            s.id AS summary_id,
            s.summary_type,
            s.tax_rate,
            s.einv_withholding_id,
            s.base_amount,
            s.tax_amount
           FROM public.sls_invoice_tax_summary s
        UNION ALL
         SELECT 'pur_quotation'::character varying(32) AS doc_table,
            s.pur_quotation_id AS doc_id,
            s.id AS summary_id,
            s.summary_type,
            s.tax_rate,
            s.einv_withholding_id,
            s.base_amount,
            s.tax_amount
           FROM public.pur_quotation_tax_summary s
        UNION ALL
         SELECT 'pur_order'::character varying(32) AS doc_table,
            s.pur_order_id AS doc_id,
            s.id AS summary_id,
            s.summary_type,
            s.tax_rate,
            s.einv_withholding_id,
            s.base_amount,
            s.tax_amount
           FROM public.pur_order_tax_summary s
        UNION ALL
         SELECT 'pur_invoice'::character varying(32) AS doc_table,
            s.pur_invoice_id AS doc_id,
            s.id AS summary_id,
            s.summary_type,
            s.tax_rate,
            s.einv_withholding_id,
            s.base_amount,
            s.tax_amount
           FROM public.pur_invoice_tax_summary s) u
     LEFT JOIN public.einv_withholding w ON ((w.id = u.einv_withholding_id)));


ALTER VIEW public.vw_sys_document_tax_summary OWNER TO ths_admin;

--
-- Name: vw_sys_document_trail; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_document_trail AS
 SELECT row_number() OVER (PARTITION BY s.doc_table, s.id ORDER BY t.trail_level, t.doc_date, t.doc_no) AS id,
    s.doc_table AS source_table,
    s.id AS source_id,
    t.trail_level,
    t.doc_table,
    t.doc_id,
    t.doc_no,
    t.doc_date,
    t.acc_account_id,
    t.account_code,
    t.account_name,
    t.status,
    t.currency,
    t.total_amount
   FROM (public.vw_sys_document s
     CROSS JOIN LATERAL public.fn_document_trail(s.doc_table, s.id) t(trail_level, doc_table, doc_id, doc_no, doc_date, acc_account_id, account_code, account_name, status, currency, total_amount));


ALTER VIEW public.vw_sys_document_trail OWNER TO ths_admin;

--
-- Name: vw_sys_grid_column; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_grid_column AS
 SELECT id,
    table_name,
    column_name,
    column_order,
    column_width,
    data_format,
    is_show,
    is_show_helper,
    min_value,
    min_value_color,
    max_value,
    max_value_color,
    max_value_percent,
    bar_color,
    bar_bg_color,
    bar_text_color,
    is_fetch,
    aggregate_type
   FROM public.sys_grid_column;


ALTER VIEW public.vw_sys_grid_column OWNER TO ths_admin;

--
-- Name: vw_sys_grid_filter; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_grid_filter AS
 SELECT id,
    table_name,
    filter_content
   FROM public.sys_grid_filter;


ALTER VIEW public.vw_sys_grid_filter OWNER TO ths_admin;

--
-- Name: vw_sys_grid_sort; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_grid_sort AS
 SELECT id,
    table_name,
    sort_content
   FROM public.sys_grid_sort;


ALTER VIEW public.vw_sys_grid_sort OWNER TO ths_admin;

--
-- Name: vw_sys_language; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_language AS
 SELECT id,
    locale,
    native_name
   FROM public.sys_language;


ALTER VIEW public.vw_sys_language OWNER TO ths_admin;

--
-- Name: vw_sys_menu; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_menu AS
 SELECT m.id,
    m.menu_code,
    m.parent_code,
    m.menu_key,
    m.action_name,
    m.sys_permission_id,
    p.permission_code,
    m.is_active,
    COALESCE(t.menu_name, m.menu_key) AS menu_name,
    t.keywords,
    l.locale,
    COALESCE(pt.permission_name, p.permission_key) AS permission_name,
    NULLIF(concat_ws(' > '::text,
        CASE
            WHEN ((m.menu_code % 10000) <> 0) THEN COALESCE(mt.menu_name, mm.menu_key)
            ELSE NULL::character varying
        END,
        CASE
            WHEN ((m.menu_code % 100) <> 0) THEN COALESCE(gt.menu_name, gm.menu_key)
            ELSE NULL::character varying
        END), ''::text) AS parent_path
   FROM ((((((((public.sys_menu m
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.sys_menu_translation t ON (((t.sys_menu_id = m.id) AND (t.sys_language_id = l.id))))
     LEFT JOIN public.sys_permission p ON ((p.id = m.sys_permission_id)))
     LEFT JOIN public.sys_permission_translation pt ON (((pt.sys_permission_id = p.id) AND (pt.sys_language_id = l.id))))
     LEFT JOIN public.sys_menu mm ON ((mm.menu_code = ((m.menu_code / 10000) * 10000))))
     LEFT JOIN public.sys_menu_translation mt ON (((mt.sys_menu_id = mm.id) AND (mt.sys_language_id = l.id))))
     LEFT JOIN public.sys_menu gm ON ((gm.menu_code = ((m.menu_code / 100) * 100))))
     LEFT JOIN public.sys_menu_translation gt ON (((gt.sys_menu_id = gm.id) AND (gt.sys_language_id = l.id))));


ALTER VIEW public.vw_sys_menu OWNER TO ths_admin;

--
-- Name: vw_sys_permission_group; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_permission_group AS
 SELECT pg.id,
    pg.permission_group_key,
    COALESCE(pgt.permission_group_name, pg.permission_group_key) AS permission_group_name,
    l.locale
   FROM ((public.sys_permission_group pg
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.sys_permission_group_translation pgt ON (((pgt.sys_permission_group_id = pg.id) AND (pgt.sys_language_id = l.id))));


ALTER VIEW public.vw_sys_permission_group OWNER TO ths_admin;

--
-- Name: vw_sys_permission_template; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_permission_template AS
 SELECT id,
    template_key,
    template_name,
    description,
    active,
    ( SELECT count(*) AS count
           FROM public.sys_permission_template_right r
          WHERE (r.sys_permission_template_id = t.id)) AS right_count,
    ( SELECT count(*) AS count
           FROM public.sys_user_permission_template u
          WHERE (u.sys_permission_template_id = t.id)) AS user_count
   FROM public.sys_permission_template t;


ALTER VIEW public.vw_sys_permission_template OWNER TO ths_admin;

--
-- Name: vw_sys_permission_template_right; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_permission_template_right AS
 SELECT r.id,
    r.sys_permission_template_id,
    t.template_key,
    t.template_name,
    r.sys_permission_id,
    p.permission_code,
    p.permission_key,
    p.permission_name,
    p.permission_group_name,
    r.is_read,
    r.is_add,
    r.is_update,
    r.is_delete,
    r.is_special,
    p.locale
   FROM ((public.sys_permission_template_right r
     JOIN public.sys_permission_template t ON ((t.id = r.sys_permission_template_id)))
     JOIN public.vw_sys_permission p ON ((p.id = r.sys_permission_id)));


ALTER VIEW public.vw_sys_permission_template_right OWNER TO ths_admin;

--
-- Name: vw_sys_region; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_region AS
 SELECT id,
    region_name
   FROM public.sys_region;


ALTER VIEW public.vw_sys_region OWNER TO ths_admin;

--
-- Name: vw_sys_uom; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_uom AS
 SELECT u.id,
    u.unit_code,
    u.unit_einv,
    u."decimal",
    u.multiplier,
    u.sys_uom_group_id,
    (COALESCE(ut.uom_name, u.unit_code))::character varying(64) AS uom_name,
    ug.uom_group_key,
    l.locale
   FROM (((public.sys_uom u
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.sys_uom_group ug ON ((ug.id = u.sys_uom_group_id)))
     LEFT JOIN public.sys_uom_translation ut ON (((ut.sys_uom_id = u.id) AND (ut.sys_language_id = l.id))));


ALTER VIEW public.vw_sys_uom OWNER TO ths_admin;

--
-- Name: vw_sys_uom_group; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_uom_group AS
 SELECT ut.id,
    ut.uom_group_key,
    COALESCE(utt.uom_group_name, ut.uom_group_key) AS uom_group_name,
    l.locale
   FROM ((public.sys_uom_group ut
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.sys_uom_group_translation utt ON (((utt.sys_uom_group_id = ut.id) AND (utt.sys_language_id = l.id))));


ALTER VIEW public.vw_sys_uom_group OWNER TO ths_admin;

--
-- Name: vw_sys_user; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_user AS
 SELECT u.id,
    e.name,
    e.surname,
    e.full_name,
    e.section_name,
    e.unit_name,
    u.username,
    u.active,
    u.manager,
    u.super_user,
    u.ip_address,
    u.mac_address,
    u.emp_employee_id,
    l.locale
   FROM ((public.sys_user u
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.vw_emp_employee e ON (((e.id = u.emp_employee_id) AND ((e.locale)::text = (l.locale)::text))));


ALTER VIEW public.vw_sys_user OWNER TO ths_admin;

--
-- Name: vw_sys_user_effective_permission; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_user_effective_permission AS
 WITH tpl AS (
         SELECT ut.sys_user_id,
            r.sys_permission_id,
            bool_or(r.is_read) AS is_read,
            bool_or(r.is_add) AS is_add,
            bool_or(r.is_update) AS is_update,
            bool_or(r.is_delete) AS is_delete,
            bool_or(r.is_special) AS is_special
           FROM ((public.sys_user_permission_template ut
             JOIN public.sys_permission_template t ON (((t.id = ut.sys_permission_template_id) AND t.active)))
             JOIN public.sys_permission_template_right r ON ((r.sys_permission_template_id = t.id)))
          GROUP BY ut.sys_user_id, r.sys_permission_id
        ), k AS (
         SELECT tpl_1.sys_user_id,
            tpl_1.sys_permission_id
           FROM tpl tpl_1
        UNION
         SELECT sys_access_right.sys_user_id,
            sys_access_right.sys_permission_id
           FROM public.sys_access_right
        )
 SELECT k.sys_user_id,
    k.sys_permission_id,
    p.permission_code,
    p.permission_key,
    ((COALESCE(tpl.is_read, false) OR COALESCE(a.is_read, false)) AND (NOT COALESCE(a.deny_read, false))) AS is_read,
    ((COALESCE(tpl.is_add, false) OR COALESCE(a.is_add, false)) AND (NOT COALESCE(a.deny_add, false))) AS is_add,
    ((COALESCE(tpl.is_update, false) OR COALESCE(a.is_update, false)) AND (NOT COALESCE(a.deny_update, false))) AS is_update,
    ((COALESCE(tpl.is_delete, false) OR COALESCE(a.is_delete, false)) AND (NOT COALESCE(a.deny_delete, false))) AS is_delete,
    ((COALESCE(tpl.is_special, false) OR COALESCE(a.is_special, false)) AND (NOT COALESCE(a.deny_special, false))) AS is_special
   FROM (((k
     JOIN public.sys_permission p ON ((p.id = k.sys_permission_id)))
     LEFT JOIN tpl ON (((tpl.sys_user_id = k.sys_user_id) AND (tpl.sys_permission_id = k.sys_permission_id))))
     LEFT JOIN public.sys_access_right a ON (((a.sys_user_id = k.sys_user_id) AND (a.sys_permission_id = k.sys_permission_id))));


ALTER VIEW public.vw_sys_user_effective_permission OWNER TO ths_admin;

--
-- Name: vw_sys_user_permission_template; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_user_permission_template AS
 SELECT ut.id,
    ut.sys_user_id,
    u.username,
    e.full_name,
    ut.sys_permission_template_id,
    t.template_key,
    t.template_name,
    t.active
   FROM (((public.sys_user_permission_template ut
     JOIN public.sys_user u ON ((u.id = ut.sys_user_id)))
     JOIN public.sys_permission_template t ON ((t.id = ut.sys_permission_template_id)))
     LEFT JOIN public.emp_employee e ON ((e.id = u.emp_employee_id)));


ALTER VIEW public.vw_sys_user_permission_template OWNER TO ths_admin;

--
-- Name: stk_kind_family id; Type: DEFAULT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kind_family ALTER COLUMN id SET DEFAULT nextval('public.stk_kind_family_id_seq'::regclass);


--
-- Name: stk_product_type id; Type: DEFAULT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_product_type ALTER COLUMN id SET DEFAULT nextval('public.stk_product_type_id_seq'::regclass);


--
-- Name: acc_account acc_acc_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account
    ADD CONSTRAINT acc_acc_code_key UNIQUE (code);


--
-- Name: acc_account acc_acc_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account
    ADD CONSTRAINT acc_acc_pkey PRIMARY KEY (id);


--
-- Name: acc_account_address acc_account_address_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account_address
    ADD CONSTRAINT acc_account_address_pkey PRIMARY KEY (id);


--
-- Name: acc_account_contact acc_account_contact_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account_contact
    ADD CONSTRAINT acc_account_contact_pkey PRIMARY KEY (acc_account_id);


--
-- Name: acc_account_plan acc_account_plan_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account_plan
    ADD CONSTRAINT acc_account_plan_code_key UNIQUE (code);


--
-- Name: acc_account_taxpayer acc_account_taxpayer_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account_taxpayer
    ADD CONSTRAINT acc_account_taxpayer_pkey PRIMARY KEY (acc_account_id);


--
-- Name: acc_account_plan acc_aplan_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account_plan
    ADD CONSTRAINT acc_aplan_pkey PRIMARY KEY (id);


--
-- Name: acc_bank acc_bank_bank_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_bank
    ADD CONSTRAINT acc_bank_bank_name_key UNIQUE (bank_name);


--
-- Name: acc_bank acc_bank_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_bank
    ADD CONSTRAINT acc_bank_pkey PRIMARY KEY (id);


--
-- Name: acc_bank_branch acc_branch_acc_bank_id_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_bank_branch
    ADD CONSTRAINT acc_branch_acc_bank_id_code_key UNIQUE (acc_bank_id, branch_code);


--
-- Name: acc_bank_branch acc_branch_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_bank_branch
    ADD CONSTRAINT acc_branch_pkey PRIMARY KEY (id);


--
-- Name: acc_set_company_legal_form acc_clf_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_company_legal_form
    ADD CONSTRAINT acc_clf_name_key UNIQUE (legal_form_key);


--
-- Name: acc_set_company_legal_form acc_clf_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_company_legal_form
    ADD CONSTRAINT acc_clf_pkey PRIMARY KEY (id);


--
-- Name: acc_exchange_rate acc_er_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_exchange_rate
    ADD CONSTRAINT acc_er_pkey PRIMARY KEY (id);


--
-- Name: acc_exchange_rate acc_er_rd_curr_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_exchange_rate
    ADD CONSTRAINT acc_er_rd_curr_key UNIQUE (rate_date, currency);


--
-- Name: acc_group acc_group_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_group
    ADD CONSTRAINT acc_group_name_key UNIQUE (name);


--
-- Name: acc_group acc_group_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_group
    ADD CONSTRAINT acc_group_pkey PRIMARY KEY (id);


--
-- Name: acc_set_ownership_type acc_otn_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_ownership_type
    ADD CONSTRAINT acc_otn_name_key UNIQUE (ownership_type_key);


--
-- Name: acc_set_ownership_type acc_otn_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_ownership_type
    ADD CONSTRAINT acc_otn_pkey PRIMARY KEY (id);


--
-- Name: acc_region acc_region_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_region
    ADD CONSTRAINT acc_region_name_key UNIQUE (name);


--
-- Name: acc_region acc_region_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_region
    ADD CONSTRAINT acc_region_pkey PRIMARY KEY (id);


--
-- Name: acc_set_account_type_translation acc_set_account_type_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_account_type_translation
    ADD CONSTRAINT acc_set_account_type_translation_pkey PRIMARY KEY (acc_set_account_type_id, sys_language_id);


--
-- Name: acc_set_account_type acc_set_at_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_account_type
    ADD CONSTRAINT acc_set_at_pkey PRIMARY KEY (id);


--
-- Name: acc_set_account_type acc_set_at_type_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_account_type
    ADD CONSTRAINT acc_set_at_type_key UNIQUE (account_type_key);


--
-- Name: acc_set_company_legal_form_translation acc_set_company_legal_form_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_company_legal_form_translation
    ADD CONSTRAINT acc_set_company_legal_form_translation_pkey PRIMARY KEY (acc_set_company_legal_form_id, sys_language_id);


--
-- Name: acc_set_ownership_type_translation acc_set_ownership_type_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_ownership_type_translation
    ADD CONSTRAINT acc_set_ownership_type_translation_pkey PRIMARY KEY (acc_set_ownership_type_id, sys_language_id);


--
-- Name: acc_set_tax_rate acc_set_tr_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_tax_rate
    ADD CONSTRAINT acc_set_tr_pkey PRIMARY KEY (id);


--
-- Name: acc_set_tax_rate acc_set_tr_vrate_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_tax_rate
    ADD CONSTRAINT acc_set_tr_vrate_key UNIQUE (tax_rate);


--
-- Name: acc_voucher_detail acc_voucher_detail_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_voucher_detail
    ADD CONSTRAINT acc_voucher_detail_line_key UNIQUE (acc_voucher_id, line_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: acc_voucher acc_voucher_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_voucher
    ADD CONSTRAINT acc_voucher_no_key UNIQUE (voucher_no);


--
-- Name: audit_outbox audit_outbox_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_outbox
    ADD CONSTRAINT audit_outbox_pkey PRIMARY KEY (id);


--
-- Name: einv_delivery_term einv_delivery_term_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_delivery_term
    ADD CONSTRAINT einv_delivery_term_code_key UNIQUE (code);


--
-- Name: einv_delivery_term einv_delivery_term_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_delivery_term
    ADD CONSTRAINT einv_delivery_term_pkey PRIMARY KEY (id);


--
-- Name: einv_diib einv_diib_document_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_diib
    ADD CONSTRAINT einv_diib_document_no_key UNIQUE (document_no);


--
-- Name: einv_diib_line einv_diib_line_einv_diib_id_line_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_diib_line
    ADD CONSTRAINT einv_diib_line_einv_diib_id_line_code_key UNIQUE (einv_diib_id, line_code) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: einv_diib_line einv_diib_line_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_diib_line
    ADD CONSTRAINT einv_diib_line_line_key UNIQUE (einv_diib_id, line_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: einv_diib_line einv_diib_line_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_diib_line
    ADD CONSTRAINT einv_diib_line_pkey PRIMARY KEY (id);


--
-- Name: einv_diib einv_diib_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_diib
    ADD CONSTRAINT einv_diib_pkey PRIMARY KEY (id);


--
-- Name: einv_document einv_document_dispatch_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_document
    ADD CONSTRAINT einv_document_dispatch_key UNIQUE (sls_dispatch_id);


--
-- Name: einv_document einv_document_invoice_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_document
    ADD CONSTRAINT einv_document_invoice_key UNIQUE (sls_invoice_id);


--
-- Name: einv_document einv_document_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_document
    ADD CONSTRAINT einv_document_pkey PRIMARY KEY (id);


--
-- Name: einv_document_setting einv_document_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_document_setting
    ADD CONSTRAINT einv_document_setting_pkey PRIMARY KEY (id);


--
-- Name: einv_document_setting einv_document_setting_scope_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_document_setting
    ADD CONSTRAINT einv_document_setting_scope_key UNIQUE (sys_application_setting_id, series_scope);


--
-- Name: einv_driver einv_driver_national_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_driver
    ADD CONSTRAINT einv_driver_national_id_key UNIQUE (national_id);


--
-- Name: einv_driver einv_driver_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_driver
    ADD CONSTRAINT einv_driver_pkey PRIMARY KEY (id);


--
-- Name: einv_gtip einv_gtip_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_gtip
    ADD CONSTRAINT einv_gtip_code_key UNIQUE (code);


--
-- Name: einv_gtip einv_gtip_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_gtip
    ADD CONSTRAINT einv_gtip_pkey PRIMARY KEY (id);


--
-- Name: einv_invoice_type einv_invoice_type_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_invoice_type
    ADD CONSTRAINT einv_invoice_type_code_key UNIQUE (code);


--
-- Name: einv_invoice_type einv_invoice_type_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_invoice_type
    ADD CONSTRAINT einv_invoice_type_pkey PRIMARY KEY (id);


--
-- Name: einv_packaging_type einv_packaging_type_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_packaging_type
    ADD CONSTRAINT einv_packaging_type_code_key UNIQUE (code);


--
-- Name: einv_packaging_type einv_packaging_type_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_packaging_type
    ADD CONSTRAINT einv_packaging_type_pkey PRIMARY KEY (id);


--
-- Name: einv_payment_means einv_payment_means_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_payment_means
    ADD CONSTRAINT einv_payment_means_code_key UNIQUE (code);


--
-- Name: einv_payment_means einv_payment_means_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_payment_means
    ADD CONSTRAINT einv_payment_means_pkey PRIMARY KEY (id);


--
-- Name: einv_profile einv_profile_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_profile
    ADD CONSTRAINT einv_profile_code_key UNIQUE (code);


--
-- Name: einv_profile einv_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_profile
    ADD CONSTRAINT einv_profile_pkey PRIMARY KEY (id);


--
-- Name: einv_series einv_series_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_series
    ADD CONSTRAINT einv_series_code_key UNIQUE (code);


--
-- Name: einv_series_counter einv_series_counter_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_series_counter
    ADD CONSTRAINT einv_series_counter_pkey PRIMARY KEY (einv_series_id, period_year);


--
-- Name: einv_series einv_series_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_series
    ADD CONSTRAINT einv_series_pkey PRIMARY KEY (id);


--
-- Name: einv_tax_exemption einv_tax_exemption_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_tax_exemption
    ADD CONSTRAINT einv_tax_exemption_code_key UNIQUE (code);


--
-- Name: einv_tax_exemption einv_tax_exemption_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_tax_exemption
    ADD CONSTRAINT einv_tax_exemption_pkey PRIMARY KEY (id);


--
-- Name: einv_tax_type einv_tax_type_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_tax_type
    ADD CONSTRAINT einv_tax_type_code_key UNIQUE (code);


--
-- Name: einv_tax_type einv_tax_type_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_tax_type
    ADD CONSTRAINT einv_tax_type_pkey PRIMARY KEY (id);


--
-- Name: einv_transport_mode einv_transport_mode_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_transport_mode
    ADD CONSTRAINT einv_transport_mode_code_key UNIQUE (code);


--
-- Name: einv_transport_mode einv_transport_mode_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_transport_mode
    ADD CONSTRAINT einv_transport_mode_pkey PRIMARY KEY (id);


--
-- Name: einv_vehicle einv_vehicle_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_vehicle
    ADD CONSTRAINT einv_vehicle_pkey PRIMARY KEY (id);


--
-- Name: einv_vehicle einv_vehicle_plate_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_vehicle
    ADD CONSTRAINT einv_vehicle_plate_no_key UNIQUE (plate_no);


--
-- Name: einv_withholding einv_withholding_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_withholding
    ADD CONSTRAINT einv_withholding_code_key UNIQUE (code);


--
-- Name: einv_withholding einv_withholding_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_withholding
    ADD CONSTRAINT einv_withholding_pkey PRIMARY KEY (id);


--
-- Name: emp_employee emp_employee_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_employee
    ADD CONSTRAINT emp_employee_pkey PRIMARY KEY (id);


--
-- Name: emp_person_address emp_person_address_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_address
    ADD CONSTRAINT emp_person_address_pkey PRIMARY KEY (id);


--
-- Name: emp_person_type_translation emp_person_type_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_type_translation
    ADD CONSTRAINT emp_person_type_translation_pkey PRIMARY KEY (emp_person_type_id, sys_language_id);


--
-- Name: emp_section_translation emp_section_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_section_translation
    ADD CONSTRAINT emp_section_translation_pkey PRIMARY KEY (emp_section_id, sys_language_id);


--
-- Name: emp_task_translation emp_task_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_task_translation
    ADD CONSTRAINT emp_task_translation_pkey PRIMARY KEY (emp_task_id, sys_language_id);


--
-- Name: emp_transportation emp_transportation_car_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_transportation
    ADD CONSTRAINT emp_transportation_car_no_key UNIQUE (car_no);


--
-- Name: emp_transportation emp_transportation_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_transportation
    ADD CONSTRAINT emp_transportation_pkey PRIMARY KEY (id);


--
-- Name: emp_unit_translation emp_unit_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_unit_translation
    ADD CONSTRAINT emp_unit_translation_pkey PRIMARY KEY (emp_unit_id, sys_language_id);


--
-- Name: fin_cheque_note fin_cheque_note_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_cheque_note
    ADD CONSTRAINT fin_cheque_note_pkey PRIMARY KEY (id);


--
-- Name: fin_cheque_note fin_cheque_note_portfolio_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_cheque_note
    ADD CONSTRAINT fin_cheque_note_portfolio_no_key UNIQUE (portfolio_no);


--
-- Name: fin_cheque_note_transaction fin_cheque_note_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_cheque_note_transaction
    ADD CONSTRAINT fin_cheque_note_transaction_pkey PRIMARY KEY (id);


--
-- Name: fin_company_bank_account fin_company_bank_account_iban_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_company_bank_account
    ADD CONSTRAINT fin_company_bank_account_iban_key UNIQUE (iban);


--
-- Name: fin_company_bank_account fin_company_bank_account_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_company_bank_account
    ADD CONSTRAINT fin_company_bank_account_pkey PRIMARY KEY (id);


--
-- Name: fin_credit_card fin_credit_card_card_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_credit_card
    ADD CONSTRAINT fin_credit_card_card_name_key UNIQUE (card_name);


--
-- Name: fin_credit_card fin_credit_card_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_credit_card
    ADD CONSTRAINT fin_credit_card_pkey PRIMARY KEY (id);


--
-- Name: fin_credit_card_transaction fin_credit_card_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_credit_card_transaction
    ADD CONSTRAINT fin_credit_card_transaction_pkey PRIMARY KEY (id);


--
-- Name: fin_money_account fin_money_account_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_money_account
    ADD CONSTRAINT fin_money_account_code_key UNIQUE (code);


--
-- Name: fin_money_account fin_money_account_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_money_account
    ADD CONSTRAINT fin_money_account_name_key UNIQUE (name);


--
-- Name: fin_money_account fin_money_account_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_money_account
    ADD CONSTRAINT fin_money_account_pkey PRIMARY KEY (id);


--
-- Name: fin_money_transaction fin_money_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_money_transaction
    ADD CONSTRAINT fin_money_transaction_pkey PRIMARY KEY (id);


--
-- Name: fin_pos_terminal fin_pos_terminal_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_pos_terminal
    ADD CONSTRAINT fin_pos_terminal_pkey PRIMARY KEY (id);


--
-- Name: fin_pos_terminal fin_pos_terminal_pos_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_pos_terminal
    ADD CONSTRAINT fin_pos_terminal_pos_name_key UNIQUE (pos_name);


--
-- Name: fin_pos_transaction fin_pos_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_pos_transaction
    ADD CONSTRAINT fin_pos_transaction_pkey PRIMARY KEY (id);


--
-- Name: acc_voucher_detail mhs_fis_detaylari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_voucher_detail
    ADD CONSTRAINT mhs_fis_detaylari_pkey PRIMARY KEY (id);


--
-- Name: acc_voucher mhs_fisler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_voucher
    ADD CONSTRAINT mhs_fisler_pkey PRIMARY KEY (id);


--
-- Name: acc_voucher mhs_fisler_yevmiye_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_voucher
    ADD CONSTRAINT mhs_fisler_yevmiye_no_key UNIQUE (journal_no);


--
-- Name: acc_transfer_code mhs_transfer_kodlari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_transfer_code
    ADD CONSTRAINT mhs_transfer_kodlari_pkey PRIMARY KEY (id);


--
-- Name: acc_transfer_code mhs_transfer_kodlari_transfer_kodu_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_transfer_code
    ADD CONSTRAINT mhs_transfer_kodlari_transfer_kodu_key UNIQUE (transfer_code);


--
-- Name: prd_bom_by_product prd_bom_by_product_inventory_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_by_product
    ADD CONSTRAINT prd_bom_by_product_inventory_key UNIQUE (prd_bom_id, stk_inventory_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: prd_bom_by_product prd_bom_by_product_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_by_product
    ADD CONSTRAINT prd_bom_by_product_line_key UNIQUE (prd_bom_id, line_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: prd_bom_by_product prd_bom_by_product_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_by_product
    ADD CONSTRAINT prd_bom_by_product_pkey PRIMARY KEY (id);


--
-- Name: prd_bom_labour prd_bom_labour_labour_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_labour
    ADD CONSTRAINT prd_bom_labour_labour_key UNIQUE (prd_bom_id, prd_labour_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: prd_bom_labour prd_bom_labour_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_labour
    ADD CONSTRAINT prd_bom_labour_line_key UNIQUE (prd_bom_id, line_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: prd_bom_labour prd_bom_labour_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_labour
    ADD CONSTRAINT prd_bom_labour_pkey PRIMARY KEY (id);


--
-- Name: prd_bom prd_bom_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom
    ADD CONSTRAINT prd_bom_name_key UNIQUE (stk_inventory_id, bom_name);


--
-- Name: prd_bom_packet_labour prd_bom_packet_labour_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_labour
    ADD CONSTRAINT prd_bom_packet_labour_line_key UNIQUE (prd_bom_id, line_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: prd_bom_packet_labour prd_bom_packet_labour_packet_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_labour
    ADD CONSTRAINT prd_bom_packet_labour_packet_key UNIQUE (prd_bom_id, prd_packet_labour_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: prd_bom_packet_labour prd_bom_packet_labour_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_labour
    ADD CONSTRAINT prd_bom_packet_labour_pkey PRIMARY KEY (id);


--
-- Name: prd_bom_packet_raw prd_bom_packet_raw_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_raw
    ADD CONSTRAINT prd_bom_packet_raw_line_key UNIQUE (prd_bom_id, line_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: prd_bom_packet_raw prd_bom_packet_raw_packet_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_raw
    ADD CONSTRAINT prd_bom_packet_raw_packet_key UNIQUE (prd_bom_id, prd_packet_raw_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: prd_bom_packet_raw prd_bom_packet_raw_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_raw
    ADD CONSTRAINT prd_bom_packet_raw_pkey PRIMARY KEY (id);


--
-- Name: prd_bom prd_bom_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom
    ADD CONSTRAINT prd_bom_pkey PRIMARY KEY (id);


--
-- Name: prd_bom_raw prd_bom_raw_inventory_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_raw
    ADD CONSTRAINT prd_bom_raw_inventory_key UNIQUE (prd_bom_id, stk_inventory_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: prd_bom_raw prd_bom_raw_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_raw
    ADD CONSTRAINT prd_bom_raw_line_key UNIQUE (prd_bom_id, line_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: prd_bom_raw prd_bom_raw_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_raw
    ADD CONSTRAINT prd_bom_raw_pkey PRIMARY KEY (id);


--
-- Name: prd_labour prd_labour_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_labour
    ADD CONSTRAINT prd_labour_code_key UNIQUE (code);


--
-- Name: prd_labour prd_labour_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_labour
    ADD CONSTRAINT prd_labour_pkey PRIMARY KEY (id);


--
-- Name: prd_packet_labour_detail prd_packet_labour_detail_labour_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_labour_detail
    ADD CONSTRAINT prd_packet_labour_detail_labour_key UNIQUE (prd_packet_labour_id, prd_labour_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: prd_packet_labour_detail prd_packet_labour_detail_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_labour_detail
    ADD CONSTRAINT prd_packet_labour_detail_line_key UNIQUE (prd_packet_labour_id, line_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: prd_packet_labour_detail prd_packet_labour_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_labour_detail
    ADD CONSTRAINT prd_packet_labour_detail_pkey PRIMARY KEY (id);


--
-- Name: prd_packet_labour prd_packet_labour_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_labour
    ADD CONSTRAINT prd_packet_labour_name_key UNIQUE (packet_name);


--
-- Name: prd_packet_labour prd_packet_labour_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_labour
    ADD CONSTRAINT prd_packet_labour_pkey PRIMARY KEY (id);


--
-- Name: prd_packet_raw_detail prd_packet_raw_detail_inventory_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_raw_detail
    ADD CONSTRAINT prd_packet_raw_detail_inventory_key UNIQUE (prd_packet_raw_id, stk_inventory_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: prd_packet_raw_detail prd_packet_raw_detail_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_raw_detail
    ADD CONSTRAINT prd_packet_raw_detail_line_key UNIQUE (prd_packet_raw_id, line_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: prd_packet_raw_detail prd_packet_raw_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_raw_detail
    ADD CONSTRAINT prd_packet_raw_detail_pkey PRIMARY KEY (id);


--
-- Name: prd_packet_raw prd_packet_raw_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_raw
    ADD CONSTRAINT prd_packet_raw_name_key UNIQUE (packet_name);


--
-- Name: prd_packet_raw prd_packet_raw_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_raw
    ADD CONSTRAINT prd_packet_raw_pkey PRIMARY KEY (id);


--
-- Name: emp_driver_ability prs_driver_abilities_driver_license_id_person_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_driver_ability
    ADD CONSTRAINT prs_driver_abilities_driver_license_id_person_id_key UNIQUE (emp_driver_license_type_id, emp_employee_id);


--
-- Name: emp_driver_ability prs_driver_abilities_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_driver_ability
    ADD CONSTRAINT prs_driver_abilities_pkey PRIMARY KEY (id);


--
-- Name: emp_person_language_ability prs_language_abilities_language_id_person_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_language_ability
    ADD CONSTRAINT prs_language_abilities_language_id_person_id_key UNIQUE (emp_language_id, emp_employee_id);


--
-- Name: emp_person_language_ability prs_language_abilities_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_language_ability
    ADD CONSTRAINT prs_language_abilities_pkey PRIMARY KEY (id);


--
-- Name: emp_driver_license_type prs_set_dlt_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_driver_license_type
    ADD CONSTRAINT prs_set_dlt_name_key UNIQUE (license_name);


--
-- Name: emp_driver_license_type prs_set_dlt_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_driver_license_type
    ADD CONSTRAINT prs_set_dlt_pkey PRIMARY KEY (id);


--
-- Name: emp_language prs_set_lng_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_language
    ADD CONSTRAINT prs_set_lng_name_key UNIQUE (language_name);


--
-- Name: emp_language prs_set_lng_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_language
    ADD CONSTRAINT prs_set_lng_pkey PRIMARY KEY (id);


--
-- Name: emp_person_type prs_set_ptp_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_type
    ADD CONSTRAINT prs_set_ptp_name_key UNIQUE (person_type_key);


--
-- Name: emp_person_type prs_set_ptp_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_type
    ADD CONSTRAINT prs_set_ptp_pkey PRIMARY KEY (id);


--
-- Name: emp_section prs_set_sec_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_section
    ADD CONSTRAINT prs_set_sec_name_key UNIQUE (section_key);


--
-- Name: emp_section prs_set_sec_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_section
    ADD CONSTRAINT prs_set_sec_pkey PRIMARY KEY (id);


--
-- Name: emp_task prs_set_task_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_task
    ADD CONSTRAINT prs_set_task_pkey PRIMARY KEY (id);


--
-- Name: emp_task prs_set_tsk_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_task
    ADD CONSTRAINT prs_set_tsk_name_key UNIQUE (task_key);


--
-- Name: emp_unit prs_set_unit_ns_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_unit
    ADD CONSTRAINT prs_set_unit_ns_key UNIQUE (unit_key, emp_section_id);


--
-- Name: emp_unit prs_set_unit_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_unit
    ADD CONSTRAINT prs_set_unit_pkey PRIMARY KEY (id);


--
-- Name: pur_invoice_detail pur_invoice_detail_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_invoice_detail
    ADD CONSTRAINT pur_invoice_detail_line_key UNIQUE (pur_invoice_id, line_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: pur_invoice_detail pur_invoice_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_invoice_detail
    ADD CONSTRAINT pur_invoice_detail_pkey PRIMARY KEY (id);


--
-- Name: pur_invoice pur_invoice_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_invoice
    ADD CONSTRAINT pur_invoice_no_key UNIQUE (acc_account_id, invoice_no);


--
-- Name: pur_invoice pur_invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_invoice
    ADD CONSTRAINT pur_invoice_pkey PRIMARY KEY (id);


--
-- Name: pur_invoice_tax_summary pur_invoice_tax_summary_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_invoice_tax_summary
    ADD CONSTRAINT pur_invoice_tax_summary_key UNIQUE NULLS NOT DISTINCT (pur_invoice_id, summary_type, tax_rate, einv_withholding_id);


--
-- Name: pur_invoice_tax_summary pur_invoice_tax_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_invoice_tax_summary
    ADD CONSTRAINT pur_invoice_tax_summary_pkey PRIMARY KEY (id);


--
-- Name: pur_order_detail pur_order_detail_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_order_detail
    ADD CONSTRAINT pur_order_detail_line_key UNIQUE (pur_order_id, line_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: pur_order_detail pur_order_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_order_detail
    ADD CONSTRAINT pur_order_detail_pkey PRIMARY KEY (id);


--
-- Name: pur_order pur_order_order_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_order
    ADD CONSTRAINT pur_order_order_no_key UNIQUE (order_no);


--
-- Name: pur_order pur_order_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_order
    ADD CONSTRAINT pur_order_pkey PRIMARY KEY (id);


--
-- Name: pur_order_tax_summary pur_order_tax_summary_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_order_tax_summary
    ADD CONSTRAINT pur_order_tax_summary_key UNIQUE NULLS NOT DISTINCT (pur_order_id, summary_type, tax_rate, einv_withholding_id);


--
-- Name: pur_order_tax_summary pur_order_tax_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_order_tax_summary
    ADD CONSTRAINT pur_order_tax_summary_pkey PRIMARY KEY (id);


--
-- Name: pur_quotation_detail pur_quotation_detail_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_quotation_detail
    ADD CONSTRAINT pur_quotation_detail_line_key UNIQUE (pur_quotation_id, line_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: pur_quotation_detail pur_quotation_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_quotation_detail
    ADD CONSTRAINT pur_quotation_detail_pkey PRIMARY KEY (id);


--
-- Name: pur_quotation pur_quotation_order_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_quotation
    ADD CONSTRAINT pur_quotation_order_key UNIQUE (pur_order_id);


--
-- Name: pur_quotation pur_quotation_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_quotation
    ADD CONSTRAINT pur_quotation_pkey PRIMARY KEY (id);


--
-- Name: pur_quotation pur_quotation_quotation_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_quotation
    ADD CONSTRAINT pur_quotation_quotation_no_key UNIQUE (quotation_no);


--
-- Name: pur_quotation_tax_summary pur_quotation_tax_summary_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_quotation_tax_summary
    ADD CONSTRAINT pur_quotation_tax_summary_key UNIQUE NULLS NOT DISTINCT (pur_quotation_id, summary_type, tax_rate, einv_withholding_id);


--
-- Name: pur_quotation_tax_summary pur_quotation_tax_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_quotation_tax_summary
    ADD CONSTRAINT pur_quotation_tax_summary_pkey PRIMARY KEY (id);


--
-- Name: pur_receipt_detail pur_receipt_detail_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_receipt_detail
    ADD CONSTRAINT pur_receipt_detail_line_key UNIQUE (pur_receipt_id, line_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: pur_receipt_detail pur_receipt_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_receipt_detail
    ADD CONSTRAINT pur_receipt_detail_pkey PRIMARY KEY (id);


--
-- Name: pur_receipt pur_receipt_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_receipt
    ADD CONSTRAINT pur_receipt_pkey PRIMARY KEY (id);


--
-- Name: pur_receipt pur_receipt_receipt_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_receipt
    ADD CONSTRAINT pur_receipt_receipt_no_key UNIQUE (receipt_no);


--
-- Name: pur_request_detail pur_request_detail_inventory_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_request_detail
    ADD CONSTRAINT pur_request_detail_inventory_key UNIQUE (pur_request_id, stk_inventory_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: pur_request_detail pur_request_detail_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_request_detail
    ADD CONSTRAINT pur_request_detail_line_key UNIQUE (pur_request_id, line_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: pur_request_detail pur_request_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_request_detail
    ADD CONSTRAINT pur_request_detail_pkey PRIMARY KEY (id);


--
-- Name: pur_request pur_request_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_request
    ADD CONSTRAINT pur_request_pkey PRIMARY KEY (id);


--
-- Name: pur_request pur_request_request_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_request
    ADD CONSTRAINT pur_request_request_no_key UNIQUE (request_no);


--
-- Name: qc_inspection qc_inspection_inspection_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.qc_inspection
    ADD CONSTRAINT qc_inspection_inspection_no_key UNIQUE (inspection_no);


--
-- Name: qc_inspection qc_inspection_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.qc_inspection
    ADD CONSTRAINT qc_inspection_pkey PRIMARY KEY (id);


--
-- Name: qc_inspection qc_inspection_receipt_detail_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.qc_inspection
    ADD CONSTRAINT qc_inspection_receipt_detail_key UNIQUE (pur_receipt_detail_id);


--
-- Name: qc_rule qc_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.qc_rule
    ADD CONSTRAINT qc_rule_pkey PRIMARY KEY (id);


--
-- Name: qc_rule qc_rule_stk_group_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.qc_rule
    ADD CONSTRAINT qc_rule_stk_group_key UNIQUE (stk_group_id);


--
-- Name: qc_rule qc_rule_stk_inventory_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.qc_rule
    ADD CONSTRAINT qc_rule_stk_inventory_key UNIQUE (stk_inventory_id);


--
-- Name: qc_setting qc_setting_application_setting_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.qc_setting
    ADD CONSTRAINT qc_setting_application_setting_key UNIQUE (sys_application_setting_id);


--
-- Name: qc_setting qc_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.qc_setting
    ADD CONSTRAINT qc_setting_pkey PRIMARY KEY (id);


--
-- Name: einv_payment_method set_einv_odeme_sekilleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_payment_method
    ADD CONSTRAINT set_einv_odeme_sekilleri_pkey PRIMARY KEY (id);


--
-- Name: einv_payment_method set_einv_odeme_sekli_odeme_sekilleri_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_payment_method
    ADD CONSTRAINT set_einv_odeme_sekli_odeme_sekilleri_key UNIQUE (payment_method_code);


--
-- Name: einv_transport_price set_einv_tasima_ucretleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_transport_price
    ADD CONSTRAINT set_einv_tasima_ucretleri_pkey PRIMARY KEY (id);


--
-- Name: einv_transport_price set_einv_tasima_ucretleri_tasima_ucreti_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_transport_price
    ADD CONSTRAINT set_einv_tasima_ucretleri_tasima_ucreti_key UNIQUE (transport_charge);


--
-- Name: sls_dispatch_detail sls_dispatch_detail_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch_detail
    ADD CONSTRAINT sls_dispatch_detail_line_key UNIQUE (sls_dispatch_id, line_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sls_dispatch_detail sls_dispatch_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch_detail
    ADD CONSTRAINT sls_dispatch_detail_pkey PRIMARY KEY (id);


--
-- Name: sls_dispatch sls_dispatch_dispatch_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch
    ADD CONSTRAINT sls_dispatch_dispatch_no_key UNIQUE (dispatch_no);


--
-- Name: sls_dispatch sls_dispatch_einv_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch
    ADD CONSTRAINT sls_dispatch_einv_no_key UNIQUE (einv_no);


--
-- Name: sls_dispatch sls_dispatch_einv_uuid_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch
    ADD CONSTRAINT sls_dispatch_einv_uuid_key UNIQUE (einv_uuid);


--
-- Name: sls_dispatch sls_dispatch_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch
    ADD CONSTRAINT sls_dispatch_pkey PRIMARY KEY (id);


--
-- Name: sls_invoice_detail sls_invoice_detail_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice_detail
    ADD CONSTRAINT sls_invoice_detail_line_key UNIQUE (sls_invoice_id, line_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sls_invoice_detail sls_invoice_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice_detail
    ADD CONSTRAINT sls_invoice_detail_pkey PRIMARY KEY (id);


--
-- Name: sls_invoice sls_invoice_einv_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice
    ADD CONSTRAINT sls_invoice_einv_no_key UNIQUE (einv_no);


--
-- Name: sls_invoice sls_invoice_einv_uuid_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice
    ADD CONSTRAINT sls_invoice_einv_uuid_key UNIQUE (einv_uuid);


--
-- Name: sls_invoice sls_invoice_invoice_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice
    ADD CONSTRAINT sls_invoice_invoice_no_key UNIQUE (invoice_no);


--
-- Name: sls_invoice sls_invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice
    ADD CONSTRAINT sls_invoice_pkey PRIMARY KEY (id);


--
-- Name: sls_invoice_tax_summary sls_invoice_tax_summary_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice_tax_summary
    ADD CONSTRAINT sls_invoice_tax_summary_key UNIQUE NULLS NOT DISTINCT (sls_invoice_id, summary_type, tax_rate, einv_withholding_id);


--
-- Name: sls_invoice_tax_summary sls_invoice_tax_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice_tax_summary
    ADD CONSTRAINT sls_invoice_tax_summary_pkey PRIMARY KEY (id);


--
-- Name: sls_offer_detail sls_offer_detail_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer_detail
    ADD CONSTRAINT sls_offer_detail_line_key UNIQUE (sls_offer_id, line_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sls_offer_detail sls_offer_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer_detail
    ADD CONSTRAINT sls_offer_detail_pkey PRIMARY KEY (id);


--
-- Name: sls_offer sls_offer_offer_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_offer_no_key UNIQUE (offer_no);


--
-- Name: sls_offer sls_offer_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_pkey PRIMARY KEY (id);


--
-- Name: sls_offer_tax_summary sls_offer_tax_summary_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer_tax_summary
    ADD CONSTRAINT sls_offer_tax_summary_key UNIQUE NULLS NOT DISTINCT (sls_offer_id, summary_type, tax_rate, einv_withholding_id);


--
-- Name: sls_offer_tax_summary sls_offer_tax_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer_tax_summary
    ADD CONSTRAINT sls_offer_tax_summary_pkey PRIMARY KEY (id);


--
-- Name: sls_order_detail sls_order_detail_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order_detail
    ADD CONSTRAINT sls_order_detail_line_key UNIQUE (sls_order_id, line_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sls_order_detail sls_order_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order_detail
    ADD CONSTRAINT sls_order_detail_pkey PRIMARY KEY (id);


--
-- Name: sls_order sls_order_order_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_order_no_key UNIQUE (order_no);


--
-- Name: sls_order sls_order_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_pkey PRIMARY KEY (id);


--
-- Name: sls_order_tax_summary sls_order_tax_summary_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order_tax_summary
    ADD CONSTRAINT sls_order_tax_summary_key UNIQUE NULLS NOT DISTINCT (sls_order_id, summary_type, tax_rate, einv_withholding_id);


--
-- Name: sls_order_tax_summary sls_order_tax_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order_tax_summary
    ADD CONSTRAINT sls_order_tax_summary_pkey PRIMARY KEY (id);


--
-- Name: stk_card_kind_info stk_card_kind_info_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_card_kind_info
    ADD CONSTRAINT stk_card_kind_info_pkey PRIMARY KEY (id);


--
-- Name: stk_card_kind_info stk_card_kind_info_stk_inventory_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_card_kind_info
    ADD CONSTRAINT stk_card_kind_info_stk_inventory_id_key UNIQUE (stk_inventory_id);


--
-- Name: stk_group stk_group_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_group
    ADD CONSTRAINT stk_group_name_key UNIQUE (name);


--
-- Name: stk_group stk_group_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_group
    ADD CONSTRAINT stk_group_pkey PRIMARY KEY (id);


--
-- Name: stk_image stk_image_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_image
    ADD CONSTRAINT stk_image_pkey PRIMARY KEY (id);


--
-- Name: stk_image stk_image_stk_inventory_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_image
    ADD CONSTRAINT stk_image_stk_inventory_id_key UNIQUE (stk_inventory_id);


--
-- Name: stk_inventory stk_inventory_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_code_key UNIQUE (code);


--
-- Name: stk_inventory stk_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_pkey PRIMARY KEY (id);


--
-- Name: stk_inventory_summary stk_inventory_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory_summary
    ADD CONSTRAINT stk_inventory_summary_pkey PRIMARY KEY (id);


--
-- Name: stk_inventory_summary stk_inventory_summary_stk_inventory_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory_summary
    ADD CONSTRAINT stk_inventory_summary_stk_inventory_id_key UNIQUE (stk_inventory_id);


--
-- Name: stk_kind_family stk_kind_family_family_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kind_family
    ADD CONSTRAINT stk_kind_family_family_key UNIQUE (family);


--
-- Name: stk_kind_family stk_kind_family_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kind_family
    ADD CONSTRAINT stk_kind_family_pkey PRIMARY KEY (id);


--
-- Name: stk_kind_property stk_kind_property_kind_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kind_property
    ADD CONSTRAINT stk_kind_property_kind_key UNIQUE (kind);


--
-- Name: stk_kind_property stk_kind_property_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kind_property
    ADD CONSTRAINT stk_kind_property_pkey PRIMARY KEY (id);


--
-- Name: stk_product_type stk_product_type_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_product_type
    ADD CONSTRAINT stk_product_type_pkey PRIMARY KEY (id);


--
-- Name: stk_product_type stk_product_type_product_type_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_product_type
    ADD CONSTRAINT stk_product_type_product_type_name_key UNIQUE (product_type_name);


--
-- Name: stk_transaction stk_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_pkey PRIMARY KEY (id);


--
-- Name: stk_transaction stk_transaction_pur_receipt_detail_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_pur_receipt_detail_key UNIQUE (pur_receipt_detail_id);


--
-- Name: stk_transaction stk_transaction_qc_inspection_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_qc_inspection_key UNIQUE (qc_inspection_id);


--
-- Name: stk_transaction stk_transaction_sls_dispatch_detail_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_sls_dispatch_detail_key UNIQUE (sls_dispatch_detail_id);


--
-- Name: stk_transaction stk_transaction_sls_invoice_detail_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_sls_invoice_detail_key UNIQUE (sls_invoice_detail_id);


--
-- Name: stk_warehouse stk_warehouse_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_warehouse
    ADD CONSTRAINT stk_warehouse_pkey PRIMARY KEY (id);


--
-- Name: stk_warehouse stk_warehouse_warehouse_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_warehouse
    ADD CONSTRAINT stk_warehouse_warehouse_name_key UNIQUE (warehouse_name);


--
-- Name: sys_access_right sys_access_right_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_access_right
    ADD CONSTRAINT sys_access_right_pkey PRIMARY KEY (id);


--
-- Name: sys_access_right sys_access_right_sys_permission_id_sys_user_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_access_right
    ADD CONSTRAINT sys_access_right_sys_permission_id_sys_user_id_key UNIQUE (sys_permission_id, sys_user_id);


--
-- Name: sys_address sys_address_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_address
    ADD CONSTRAINT sys_address_pkey PRIMARY KEY (id);


--
-- Name: sys_api_service sys_api_service_kind_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_api_service
    ADD CONSTRAINT sys_api_service_kind_key UNIQUE (sys_application_setting_id, service_kind);


--
-- Name: sys_api_service sys_api_service_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_api_service
    ADD CONSTRAINT sys_api_service_pkey PRIMARY KEY (id);


--
-- Name: sys_application_setting sys_application_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_application_setting
    ADD CONSTRAINT sys_application_setting_pkey PRIMARY KEY (id);


--
-- Name: sys_city sys_city_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_city
    ADD CONSTRAINT sys_city_pkey PRIMARY KEY (id);


--
-- Name: sys_city sys_city_sys_country_id_city_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_city
    ADD CONSTRAINT sys_city_sys_country_id_city_name_key UNIQUE (sys_country_id, city_name);


--
-- Name: sys_country sys_country_country_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_country
    ADD CONSTRAINT sys_country_country_code_key UNIQUE (country_code);


--
-- Name: sys_country sys_country_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_country
    ADD CONSTRAINT sys_country_pkey PRIMARY KEY (id);


--
-- Name: sys_country_translation sys_country_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_country_translation
    ADD CONSTRAINT sys_country_translation_pkey PRIMARY KEY (sys_country_id, sys_language_id);


--
-- Name: sys_currency sys_currency_curr_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_currency
    ADD CONSTRAINT sys_currency_curr_key UNIQUE (currency);


--
-- Name: sys_currency sys_currency_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_currency
    ADD CONSTRAINT sys_currency_pkey PRIMARY KEY (id);


--
-- Name: sys_decimal_place sys_decimal_place_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_decimal_place
    ADD CONSTRAINT sys_decimal_place_pkey PRIMARY KEY (id);


--
-- Name: sys_grid_column sys_grid_col_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_grid_column
    ADD CONSTRAINT sys_grid_col_pkey PRIMARY KEY (id);


--
-- Name: sys_grid_column sys_grid_col_table_col_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_grid_column
    ADD CONSTRAINT sys_grid_col_table_col_key UNIQUE (table_name, column_name);


--
-- Name: sys_grid_column sys_grid_col_table_ord_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_grid_column
    ADD CONSTRAINT sys_grid_col_table_ord_key UNIQUE (table_name, column_order);


--
-- Name: sys_grid_filter sys_grid_filter_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_grid_filter
    ADD CONSTRAINT sys_grid_filter_pkey PRIMARY KEY (id);


--
-- Name: sys_grid_filter sys_grid_filter_tn_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_grid_filter
    ADD CONSTRAINT sys_grid_filter_tn_key UNIQUE (table_name);


--
-- Name: sys_grid_sort sys_grid_sort_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_grid_sort
    ADD CONSTRAINT sys_grid_sort_pkey PRIMARY KEY (id);


--
-- Name: sys_grid_sort sys_grid_sort_tn_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_grid_sort
    ADD CONSTRAINT sys_grid_sort_tn_key UNIQUE (table_name);


--
-- Name: sys_language sys_language_locale_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_language
    ADD CONSTRAINT sys_language_locale_key UNIQUE (locale);


--
-- Name: sys_language sys_language_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_language
    ADD CONSTRAINT sys_language_pkey PRIMARY KEY (id);


--
-- Name: sys_menu sys_menu_action_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_menu
    ADD CONSTRAINT sys_menu_action_name_key UNIQUE (action_name);


--
-- Name: sys_menu sys_menu_menu_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_menu
    ADD CONSTRAINT sys_menu_menu_code_key UNIQUE (menu_code);


--
-- Name: sys_menu sys_menu_menu_key_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_menu
    ADD CONSTRAINT sys_menu_menu_key_key UNIQUE (menu_key);


--
-- Name: sys_menu sys_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_menu
    ADD CONSTRAINT sys_menu_pkey PRIMARY KEY (id);


--
-- Name: sys_menu_translation sys_menu_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_menu_translation
    ADD CONSTRAINT sys_menu_translation_pkey PRIMARY KEY (sys_menu_id, sys_language_id);


--
-- Name: sys_permission_group sys_permission_group_permission_group_key_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_group
    ADD CONSTRAINT sys_permission_group_permission_group_key_key UNIQUE (permission_group_key);


--
-- Name: sys_permission_group sys_permission_group_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_group
    ADD CONSTRAINT sys_permission_group_pkey PRIMARY KEY (id);


--
-- Name: sys_permission_group_translation sys_permission_group_translat_sys_permission_group_id_sys_l_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_group_translation
    ADD CONSTRAINT sys_permission_group_translat_sys_permission_group_id_sys_l_key UNIQUE (sys_permission_group_id, sys_language_id);


--
-- Name: sys_permission_group_translation sys_permission_group_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_group_translation
    ADD CONSTRAINT sys_permission_group_translation_pkey PRIMARY KEY (sys_permission_group_id, sys_language_id);


--
-- Name: sys_permission sys_permission_permission_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission
    ADD CONSTRAINT sys_permission_permission_code_key UNIQUE (permission_code);


--
-- Name: sys_permission sys_permission_permission_key_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission
    ADD CONSTRAINT sys_permission_permission_key_key UNIQUE (permission_key);


--
-- Name: sys_permission sys_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission
    ADD CONSTRAINT sys_permission_pkey PRIMARY KEY (id);


--
-- Name: sys_permission_template sys_permission_template_key_unique; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_template
    ADD CONSTRAINT sys_permission_template_key_unique UNIQUE (template_key);


--
-- Name: sys_permission_template sys_permission_template_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_template
    ADD CONSTRAINT sys_permission_template_pkey PRIMARY KEY (id);


--
-- Name: sys_permission_template_right sys_permission_template_right_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_template_right
    ADD CONSTRAINT sys_permission_template_right_pkey PRIMARY KEY (id);


--
-- Name: sys_permission_template_right sys_permission_template_right_unique; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_template_right
    ADD CONSTRAINT sys_permission_template_right_unique UNIQUE (sys_permission_template_id, sys_permission_id);


--
-- Name: sys_permission_translation sys_permission_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_translation
    ADD CONSTRAINT sys_permission_translation_pkey PRIMARY KEY (sys_permission_id, sys_language_id);


--
-- Name: sys_permission_translation sys_permission_translation_sys_permission_id_sys_language_i_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_translation
    ADD CONSTRAINT sys_permission_translation_sys_permission_id_sys_language_i_key UNIQUE (sys_permission_id, sys_language_id);


--
-- Name: sys_region sys_region_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_region
    ADD CONSTRAINT sys_region_name_key UNIQUE (region_name);


--
-- Name: sys_region sys_region_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_region
    ADD CONSTRAINT sys_region_pkey PRIMARY KEY (id);


--
-- Name: sys_uom_group sys_uom_group_key_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_uom_group
    ADD CONSTRAINT sys_uom_group_key_key UNIQUE (uom_group_key);


--
-- Name: sys_uom_group sys_uom_group_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_uom_group
    ADD CONSTRAINT sys_uom_group_pkey PRIMARY KEY (id);


--
-- Name: sys_uom_group_translation sys_uom_group_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_uom_group_translation
    ADD CONSTRAINT sys_uom_group_translation_pkey PRIMARY KEY (sys_uom_group_id, sys_language_id);


--
-- Name: sys_uom sys_uom_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_uom
    ADD CONSTRAINT sys_uom_pkey PRIMARY KEY (id);


--
-- Name: sys_uom_translation sys_uom_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_uom_translation
    ADD CONSTRAINT sys_uom_translation_pkey PRIMARY KEY (sys_uom_id, sys_language_id);


--
-- Name: sys_uom sys_uom_unit_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_uom
    ADD CONSTRAINT sys_uom_unit_key UNIQUE (unit_code);


--
-- Name: sys_user_grid_column sys_user_grid_col_user_tbl_col_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_user_grid_column
    ADD CONSTRAINT sys_user_grid_col_user_tbl_col_key UNIQUE (user_id, table_name, column_name);


--
-- Name: sys_user_grid_column sys_user_grid_column_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_user_grid_column
    ADD CONSTRAINT sys_user_grid_column_pkey PRIMARY KEY (id);


--
-- Name: sys_user_menu sys_user_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_user_menu
    ADD CONSTRAINT sys_user_menu_pkey PRIMARY KEY (id);


--
-- Name: sys_user_menu sys_user_menu_user_menu_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_user_menu
    ADD CONSTRAINT sys_user_menu_user_menu_key UNIQUE (sys_user_id, sys_menu_id);


--
-- Name: sys_user_permission_template sys_user_permission_template_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_user_permission_template
    ADD CONSTRAINT sys_user_permission_template_pkey PRIMARY KEY (id);


--
-- Name: sys_user_permission_template sys_user_permission_template_unique; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_user_permission_template
    ADD CONSTRAINT sys_user_permission_template_unique UNIQUE (sys_user_id, sys_permission_template_id);


--
-- Name: sys_user sys_user_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_user_pkey PRIMARY KEY (id);


--
-- Name: sys_user_setting sys_user_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_user_setting
    ADD CONSTRAINT sys_user_setting_pkey PRIMARY KEY (id);


--
-- Name: sys_user_setting sys_user_setting_user_key_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_user_setting
    ADD CONSTRAINT sys_user_setting_user_key_key UNIQUE (sys_user_id, setting_key);


--
-- Name: sys_user sys_user_username_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_user_username_key UNIQUE (username);


--
-- Name: acc_account_acc_group_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX acc_account_acc_group_id_idx ON public.acc_account USING btree (acc_group_id);


--
-- Name: acc_account_acc_region_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX acc_account_acc_region_id_idx ON public.acc_account USING btree (acc_region_id);


--
-- Name: acc_account_acc_set_account_type_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX acc_account_acc_set_account_type_id_idx ON public.acc_account USING btree (acc_set_account_type_id);


--
-- Name: acc_account_address_acc_account_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX acc_account_address_acc_account_id_idx ON public.acc_account_address USING btree (acc_account_id);


--
-- Name: acc_account_address_sys_address_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX acc_account_address_sys_address_id_idx ON public.acc_account_address USING btree (sys_address_id);


--
-- Name: acc_bank_branch_sys_city_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX acc_bank_branch_sys_city_id_idx ON public.acc_bank_branch USING btree (sys_city_id);


--
-- Name: acc_set_company_legal_form_ownership_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX acc_set_company_legal_form_ownership_idx ON public.acc_set_company_legal_form USING btree (acc_set_ownership_type_id);


--
-- Name: acc_voucher_detail_acc_voucher_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX acc_voucher_detail_acc_voucher_id_idx ON public.acc_voucher_detail USING btree (acc_voucher_id);


--
-- Name: acc_voucher_detail_account_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX acc_voucher_detail_account_idx ON public.acc_voucher_detail USING btree (acc_account_id);


--
-- Name: einv_diib_acc_account_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX einv_diib_acc_account_id_idx ON public.einv_diib USING btree (acc_account_id);


--
-- Name: einv_diib_line_einv_gtip_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX einv_diib_line_einv_gtip_id_idx ON public.einv_diib_line USING btree (einv_gtip_id);


--
-- Name: einv_diib_line_stk_inventory_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX einv_diib_line_stk_inventory_id_idx ON public.einv_diib_line USING btree (stk_inventory_id);


--
-- Name: einv_diib_line_sys_uom_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX einv_diib_line_sys_uom_id_idx ON public.einv_diib_line USING btree (sys_uom_id);


--
-- Name: einv_document_setting_einv_series_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX einv_document_setting_einv_series_id_idx ON public.einv_document_setting USING btree (einv_series_id);


--
-- Name: einv_document_setting_sys_api_service_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX einv_document_setting_sys_api_service_id_idx ON public.einv_document_setting USING btree (sys_api_service_id);


--
-- Name: einv_tax_exemption_einv_invoice_type_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX einv_tax_exemption_einv_invoice_type_id_idx ON public.einv_tax_exemption USING btree (einv_invoice_type_id);


--
-- Name: emp_driver_ability_emp_employee_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX emp_driver_ability_emp_employee_id_idx ON public.emp_driver_ability USING btree (emp_employee_id);


--
-- Name: emp_person_address_emp_employee_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX emp_person_address_emp_employee_id_idx ON public.emp_person_address USING btree (emp_employee_id);


--
-- Name: emp_person_address_sys_address_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX emp_person_address_sys_address_id_idx ON public.emp_person_address USING btree (sys_address_id);


--
-- Name: emp_person_language_ability_emp_employee_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX emp_person_language_ability_emp_employee_id_idx ON public.emp_person_language_ability USING btree (emp_employee_id);


--
-- Name: emp_unit_emp_section_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX emp_unit_emp_section_id_idx ON public.emp_unit USING btree (emp_section_id);


--
-- Name: fin_cheque_note_acc_account_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_cheque_note_acc_account_id_idx ON public.fin_cheque_note USING btree (acc_account_id);


--
-- Name: fin_cheque_note_acc_bank_branch_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_cheque_note_acc_bank_branch_id_idx ON public.fin_cheque_note USING btree (acc_bank_branch_id);


--
-- Name: fin_cheque_note_acc_bank_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_cheque_note_acc_bank_id_idx ON public.fin_cheque_note USING btree (acc_bank_id);


--
-- Name: fin_cheque_note_company_bank_account_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_cheque_note_company_bank_account_idx ON public.fin_cheque_note USING btree (fin_company_bank_account_id);


--
-- Name: fin_cheque_note_currency_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_cheque_note_currency_idx ON public.fin_cheque_note USING btree (currency);


--
-- Name: fin_cheque_note_due_date_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_cheque_note_due_date_idx ON public.fin_cheque_note USING btree (due_date);


--
-- Name: fin_cheque_note_serial_key; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE UNIQUE INDEX fin_cheque_note_serial_key ON public.fin_cheque_note USING btree (doc_kind, direction, COALESCE(acc_bank_id, (0)::bigint), serial_no);


--
-- Name: fin_cheque_note_transaction_acc_account_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_cheque_note_transaction_acc_account_id_idx ON public.fin_cheque_note_transaction USING btree (acc_account_id);


--
-- Name: fin_cheque_note_transaction_acc_bank_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_cheque_note_transaction_acc_bank_id_idx ON public.fin_cheque_note_transaction USING btree (acc_bank_id);


--
-- Name: fin_cheque_note_transaction_note_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_cheque_note_transaction_note_idx ON public.fin_cheque_note_transaction USING btree (fin_cheque_note_id, transaction_date, id);


--
-- Name: fin_company_bank_account_acc_bank_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_company_bank_account_acc_bank_id_idx ON public.fin_company_bank_account USING btree (acc_bank_id);


--
-- Name: fin_company_bank_account_currency_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_company_bank_account_currency_idx ON public.fin_company_bank_account USING btree (currency);


--
-- Name: fin_company_bank_account_sys_city_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_company_bank_account_sys_city_id_idx ON public.fin_company_bank_account USING btree (sys_city_id);


--
-- Name: fin_credit_card_acc_account_code_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_credit_card_acc_account_code_idx ON public.fin_credit_card USING btree (acc_account_code);


--
-- Name: fin_credit_card_acc_bank_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_credit_card_acc_bank_id_idx ON public.fin_credit_card USING btree (acc_bank_id);


--
-- Name: fin_credit_card_currency_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_credit_card_currency_idx ON public.fin_credit_card USING btree (currency);


--
-- Name: fin_credit_card_transaction_acc_account_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_credit_card_transaction_acc_account_id_idx ON public.fin_credit_card_transaction USING btree (acc_account_id);


--
-- Name: fin_credit_card_transaction_card_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_credit_card_transaction_card_idx ON public.fin_credit_card_transaction USING btree (fin_credit_card_id, transaction_date);


--
-- Name: fin_money_account_acc_account_code_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_money_account_acc_account_code_idx ON public.fin_money_account USING btree (acc_account_code);


--
-- Name: fin_money_account_acc_bank_branch_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_money_account_acc_bank_branch_id_idx ON public.fin_money_account USING btree (acc_bank_branch_id);


--
-- Name: fin_money_account_acc_bank_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_money_account_acc_bank_id_idx ON public.fin_money_account USING btree (acc_bank_id);


--
-- Name: fin_money_account_currency_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_money_account_currency_idx ON public.fin_money_account USING btree (currency);


--
-- Name: fin_money_account_iban_key; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE UNIQUE INDEX fin_money_account_iban_key ON public.fin_money_account USING btree (iban) WHERE (iban IS NOT NULL);


--
-- Name: fin_money_transaction_acc_account_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_money_transaction_acc_account_id_idx ON public.fin_money_transaction USING btree (acc_account_id);


--
-- Name: fin_money_transaction_account_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_money_transaction_account_idx ON public.fin_money_transaction USING btree (fin_money_account_id, transaction_date, id);


--
-- Name: fin_money_transaction_target_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_money_transaction_target_idx ON public.fin_money_transaction USING btree (target_fin_money_account_id);


--
-- Name: fin_pos_terminal_acc_account_code_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_pos_terminal_acc_account_code_idx ON public.fin_pos_terminal USING btree (acc_account_code);


--
-- Name: fin_pos_terminal_acc_bank_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_pos_terminal_acc_bank_id_idx ON public.fin_pos_terminal USING btree (acc_bank_id);


--
-- Name: fin_pos_terminal_currency_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_pos_terminal_currency_idx ON public.fin_pos_terminal USING btree (currency);


--
-- Name: fin_pos_transaction_acc_account_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_pos_transaction_acc_account_id_idx ON public.fin_pos_transaction USING btree (acc_account_id);


--
-- Name: fin_pos_transaction_pos_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX fin_pos_transaction_pos_idx ON public.fin_pos_transaction USING btree (fin_pos_terminal_id, transaction_date);


--
-- Name: prd_bom_by_product_stk_inventory_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX prd_bom_by_product_stk_inventory_id_idx ON public.prd_bom_by_product USING btree (stk_inventory_id);


--
-- Name: prd_bom_default_uidx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE UNIQUE INDEX prd_bom_default_uidx ON public.prd_bom USING btree (stk_inventory_id) WHERE is_default;


--
-- Name: prd_bom_labour_prd_labour_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX prd_bom_labour_prd_labour_id_idx ON public.prd_bom_labour USING btree (prd_labour_id);


--
-- Name: prd_bom_packet_labour_prd_packet_labour_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX prd_bom_packet_labour_prd_packet_labour_id_idx ON public.prd_bom_packet_labour USING btree (prd_packet_labour_id);


--
-- Name: prd_bom_packet_raw_prd_packet_raw_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX prd_bom_packet_raw_prd_packet_raw_id_idx ON public.prd_bom_packet_raw USING btree (prd_packet_raw_id);


--
-- Name: prd_bom_raw_stk_inventory_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX prd_bom_raw_stk_inventory_id_idx ON public.prd_bom_raw USING btree (stk_inventory_id);


--
-- Name: prd_bom_raw_sub_prd_bom_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX prd_bom_raw_sub_prd_bom_id_idx ON public.prd_bom_raw USING btree (sub_prd_bom_id);


--
-- Name: prd_labour_acc_account_code_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX prd_labour_acc_account_code_idx ON public.prd_labour USING btree (acc_account_code);


--
-- Name: prd_labour_sys_uom_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX prd_labour_sys_uom_id_idx ON public.prd_labour USING btree (sys_uom_id);


--
-- Name: prd_packet_labour_detail_prd_labour_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX prd_packet_labour_detail_prd_labour_id_idx ON public.prd_packet_labour_detail USING btree (prd_labour_id);


--
-- Name: prd_packet_raw_detail_stk_inventory_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX prd_packet_raw_detail_stk_inventory_id_idx ON public.prd_packet_raw_detail USING btree (stk_inventory_id);


--
-- Name: prd_packet_raw_detail_sub_prd_bom_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX prd_packet_raw_detail_sub_prd_bom_id_idx ON public.prd_packet_raw_detail USING btree (sub_prd_bom_id);


--
-- Name: pur_invoice_currency_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_invoice_currency_idx ON public.pur_invoice USING btree (currency);


--
-- Name: pur_invoice_detail_receipt_detail_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_invoice_detail_receipt_detail_idx ON public.pur_invoice_detail USING btree (pur_receipt_detail_id);


--
-- Name: pur_invoice_detail_stk_inventory_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_invoice_detail_stk_inventory_id_idx ON public.pur_invoice_detail USING btree (stk_inventory_id);


--
-- Name: pur_invoice_tax_summary_withholding_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_invoice_tax_summary_withholding_idx ON public.pur_invoice_tax_summary USING btree (einv_withholding_id);


--
-- Name: pur_order_acc_account_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_order_acc_account_id_idx ON public.pur_order USING btree (acc_account_id);


--
-- Name: pur_order_currency_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_order_currency_idx ON public.pur_order USING btree (currency);


--
-- Name: pur_order_detail_request_detail_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_order_detail_request_detail_idx ON public.pur_order_detail USING btree (pur_request_detail_id);


--
-- Name: pur_order_detail_stk_inventory_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_order_detail_stk_inventory_id_idx ON public.pur_order_detail USING btree (stk_inventory_id);


--
-- Name: pur_order_stk_warehouse_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_order_stk_warehouse_id_idx ON public.pur_order USING btree (stk_warehouse_id);


--
-- Name: pur_order_tax_summary_withholding_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_order_tax_summary_withholding_idx ON public.pur_order_tax_summary USING btree (einv_withholding_id);


--
-- Name: pur_quotation_acc_account_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_quotation_acc_account_id_idx ON public.pur_quotation USING btree (acc_account_id);


--
-- Name: pur_quotation_approved_sys_user_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_quotation_approved_sys_user_id_idx ON public.pur_quotation USING btree (approved_sys_user_id);


--
-- Name: pur_quotation_currency_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_quotation_currency_idx ON public.pur_quotation USING btree (currency);


--
-- Name: pur_quotation_detail_request_detail_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_quotation_detail_request_detail_idx ON public.pur_quotation_detail USING btree (pur_request_detail_id);


--
-- Name: pur_quotation_detail_stk_inventory_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_quotation_detail_stk_inventory_id_idx ON public.pur_quotation_detail USING btree (stk_inventory_id);


--
-- Name: pur_quotation_request_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_quotation_request_idx ON public.pur_quotation USING btree (pur_request_id);


--
-- Name: pur_quotation_selected_key; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE UNIQUE INDEX pur_quotation_selected_key ON public.pur_quotation USING btree (pur_request_id) WHERE (status = ANY (ARRAY[2, 3, 5]));


--
-- Name: pur_quotation_tax_summary_withholding_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_quotation_tax_summary_withholding_idx ON public.pur_quotation_tax_summary USING btree (einv_withholding_id);


--
-- Name: pur_receipt_acc_account_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_receipt_acc_account_id_idx ON public.pur_receipt USING btree (acc_account_id);


--
-- Name: pur_receipt_currency_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_receipt_currency_idx ON public.pur_receipt USING btree (currency);


--
-- Name: pur_receipt_detail_order_detail_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_receipt_detail_order_detail_idx ON public.pur_receipt_detail USING btree (pur_order_detail_id);


--
-- Name: pur_receipt_detail_receipt_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_receipt_detail_receipt_idx ON public.pur_receipt_detail USING btree (pur_receipt_id);


--
-- Name: pur_receipt_detail_stk_inventory_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_receipt_detail_stk_inventory_id_idx ON public.pur_receipt_detail USING btree (stk_inventory_id);


--
-- Name: pur_receipt_order_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_receipt_order_idx ON public.pur_receipt USING btree (pur_order_id);


--
-- Name: pur_receipt_stk_warehouse_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_receipt_stk_warehouse_id_idx ON public.pur_receipt USING btree (stk_warehouse_id);


--
-- Name: pur_request_detail_stk_inventory_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_request_detail_stk_inventory_id_idx ON public.pur_request_detail USING btree (stk_inventory_id);


--
-- Name: pur_request_emp_employee_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX pur_request_emp_employee_id_idx ON public.pur_request USING btree (emp_employee_id);


--
-- Name: qc_inspection_emp_employee_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX qc_inspection_emp_employee_id_idx ON public.qc_inspection USING btree (emp_employee_id);


--
-- Name: qc_inspection_stk_inventory_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX qc_inspection_stk_inventory_id_idx ON public.qc_inspection USING btree (stk_inventory_id);


--
-- Name: qc_setting_reject_stk_warehouse_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX qc_setting_reject_stk_warehouse_id_idx ON public.qc_setting USING btree (reject_stk_warehouse_id);


--
-- Name: sls_dispatch_acc_account_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_dispatch_acc_account_id_idx ON public.sls_dispatch USING btree (acc_account_id);


--
-- Name: sls_dispatch_carrier_acc_account_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_dispatch_carrier_acc_account_id_idx ON public.sls_dispatch USING btree (carrier_acc_account_id);


--
-- Name: sls_dispatch_currency_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_dispatch_currency_idx ON public.sls_dispatch USING btree (currency);


--
-- Name: sls_dispatch_detail_dispatch_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_dispatch_detail_dispatch_idx ON public.sls_dispatch_detail USING btree (sls_dispatch_id);


--
-- Name: sls_dispatch_detail_order_detail_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_dispatch_detail_order_detail_idx ON public.sls_dispatch_detail USING btree (sls_order_detail_id);


--
-- Name: sls_dispatch_detail_stk_inventory_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_dispatch_detail_stk_inventory_id_idx ON public.sls_dispatch_detail USING btree (stk_inventory_id);


--
-- Name: sls_dispatch_driver1_einv_driver_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_dispatch_driver1_einv_driver_id_idx ON public.sls_dispatch USING btree (driver1_einv_driver_id);


--
-- Name: sls_dispatch_driver2_einv_driver_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_dispatch_driver2_einv_driver_id_idx ON public.sls_dispatch USING btree (driver2_einv_driver_id);


--
-- Name: sls_dispatch_einv_profile_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_dispatch_einv_profile_id_idx ON public.sls_dispatch USING btree (einv_profile_id);


--
-- Name: sls_dispatch_einv_vehicle_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_dispatch_einv_vehicle_id_idx ON public.sls_dispatch USING btree (einv_vehicle_id);


--
-- Name: sls_dispatch_order_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_dispatch_order_idx ON public.sls_dispatch USING btree (sls_order_id);


--
-- Name: sls_dispatch_stk_warehouse_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_dispatch_stk_warehouse_id_idx ON public.sls_dispatch USING btree (stk_warehouse_id);


--
-- Name: sls_dispatch_trailer1_einv_vehicle_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_dispatch_trailer1_einv_vehicle_id_idx ON public.sls_dispatch USING btree (trailer1_einv_vehicle_id);


--
-- Name: sls_dispatch_trailer2_einv_vehicle_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_dispatch_trailer2_einv_vehicle_id_idx ON public.sls_dispatch USING btree (trailer2_einv_vehicle_id);


--
-- Name: sls_invoice_acc_account_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_invoice_acc_account_id_idx ON public.sls_invoice USING btree (acc_account_id);


--
-- Name: sls_invoice_currency_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_invoice_currency_idx ON public.sls_invoice USING btree (currency);


--
-- Name: sls_invoice_detail_buyer_einv_diib_line_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_invoice_detail_buyer_einv_diib_line_id_idx ON public.sls_invoice_detail USING btree (buyer_einv_diib_line_id);


--
-- Name: sls_invoice_detail_dispatch_detail_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_invoice_detail_dispatch_detail_idx ON public.sls_invoice_detail USING btree (sls_dispatch_detail_id);


--
-- Name: sls_invoice_detail_einv_gtip_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_invoice_detail_einv_gtip_id_idx ON public.sls_invoice_detail USING btree (einv_gtip_id);


--
-- Name: sls_invoice_detail_einv_packaging_type_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_invoice_detail_einv_packaging_type_id_idx ON public.sls_invoice_detail USING btree (einv_packaging_type_id);


--
-- Name: sls_invoice_detail_einv_withholding_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_invoice_detail_einv_withholding_id_idx ON public.sls_invoice_detail USING btree (einv_withholding_id);


--
-- Name: sls_invoice_detail_order_detail_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_invoice_detail_order_detail_idx ON public.sls_invoice_detail USING btree (sls_order_detail_id);


--
-- Name: sls_invoice_detail_seller_einv_diib_line_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_invoice_detail_seller_einv_diib_line_id_idx ON public.sls_invoice_detail USING btree (seller_einv_diib_line_id);


--
-- Name: sls_invoice_detail_stk_inventory_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_invoice_detail_stk_inventory_id_idx ON public.sls_invoice_detail USING btree (stk_inventory_id);


--
-- Name: sls_invoice_einv_delivery_term_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_invoice_einv_delivery_term_id_idx ON public.sls_invoice USING btree (einv_delivery_term_id);


--
-- Name: sls_invoice_einv_invoice_type_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_invoice_einv_invoice_type_id_idx ON public.sls_invoice USING btree (einv_invoice_type_id);


--
-- Name: sls_invoice_einv_payment_means_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_invoice_einv_payment_means_id_idx ON public.sls_invoice USING btree (einv_payment_means_id);


--
-- Name: sls_invoice_einv_profile_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_invoice_einv_profile_id_idx ON public.sls_invoice USING btree (einv_profile_id);


--
-- Name: sls_invoice_einv_tax_exemption_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_invoice_einv_tax_exemption_id_idx ON public.sls_invoice USING btree (einv_tax_exemption_id);


--
-- Name: sls_invoice_einv_transport_mode_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_invoice_einv_transport_mode_id_idx ON public.sls_invoice USING btree (einv_transport_mode_id);


--
-- Name: sls_invoice_stk_warehouse_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_invoice_stk_warehouse_id_idx ON public.sls_invoice USING btree (stk_warehouse_id);


--
-- Name: sls_invoice_tax_summary_withholding_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_invoice_tax_summary_withholding_idx ON public.sls_invoice_tax_summary USING btree (einv_withholding_id);


--
-- Name: sls_offer_acc_account_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_offer_acc_account_id_idx ON public.sls_offer USING btree (acc_account_id);


--
-- Name: sls_offer_base_currency_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_offer_base_currency_idx ON public.sls_offer USING btree (base_currency);


--
-- Name: sls_offer_billing_address_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_offer_billing_address_id_idx ON public.sls_offer USING btree (billing_address_id);


--
-- Name: sls_offer_billing_sys_address_id_key; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE UNIQUE INDEX sls_offer_billing_sys_address_id_key ON public.sls_offer USING btree (billing_sys_address_id);


--
-- Name: sls_offer_currency_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_offer_currency_idx ON public.sls_offer USING btree (currency);


--
-- Name: sls_offer_detail_stk_inventory_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_offer_detail_stk_inventory_id_idx ON public.sls_offer_detail USING btree (stk_inventory_id);


--
-- Name: sls_offer_einv_delivery_term_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_offer_einv_delivery_term_id_idx ON public.sls_offer USING btree (einv_delivery_term_id);


--
-- Name: sls_offer_einv_payment_means_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_offer_einv_payment_means_id_idx ON public.sls_offer USING btree (einv_payment_means_id);


--
-- Name: sls_offer_emp_employee_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_offer_emp_employee_id_idx ON public.sls_offer USING btree (emp_employee_id);


--
-- Name: sls_offer_shipping_address_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_offer_shipping_address_id_idx ON public.sls_offer USING btree (shipping_address_id);


--
-- Name: sls_offer_shipping_sys_address_id_key; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE UNIQUE INDEX sls_offer_shipping_sys_address_id_key ON public.sls_offer USING btree (shipping_sys_address_id);


--
-- Name: sls_offer_tax_summary_withholding_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_offer_tax_summary_withholding_idx ON public.sls_offer_tax_summary USING btree (einv_withholding_id);


--
-- Name: sls_order_acc_account_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_order_acc_account_id_idx ON public.sls_order USING btree (acc_account_id);


--
-- Name: sls_order_currency_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_order_currency_idx ON public.sls_order USING btree (currency);


--
-- Name: sls_order_detail_offer_detail_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_order_detail_offer_detail_idx ON public.sls_order_detail USING btree (sls_offer_detail_id);


--
-- Name: sls_order_detail_stk_inventory_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_order_detail_stk_inventory_id_idx ON public.sls_order_detail USING btree (stk_inventory_id);


--
-- Name: sls_order_emp_employee_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_order_emp_employee_id_idx ON public.sls_order USING btree (emp_employee_id);


--
-- Name: sls_order_stk_warehouse_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_order_stk_warehouse_id_idx ON public.sls_order USING btree (stk_warehouse_id);


--
-- Name: sls_order_tax_summary_withholding_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sls_order_tax_summary_withholding_idx ON public.sls_order_tax_summary USING btree (einv_withholding_id);


--
-- Name: stk_card_kind_info_stk_kind_property_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_card_kind_info_stk_kind_property_id_idx ON public.stk_card_kind_info USING btree (stk_kind_property_id);


--
-- Name: stk_group_vat_rate_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_group_vat_rate_idx ON public.stk_group USING btree (vat_rate);


--
-- Name: stk_inventory_einv_gtip_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_inventory_einv_gtip_id_idx ON public.stk_inventory USING btree (einv_gtip_id);


--
-- Name: stk_inventory_purchase_account_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_inventory_purchase_account_idx ON public.stk_inventory USING btree (purchase_account);


--
-- Name: stk_inventory_purchase_return_account_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_inventory_purchase_return_account_idx ON public.stk_inventory USING btree (purchase_return_account);


--
-- Name: stk_inventory_raw_material_stock_account_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_inventory_raw_material_stock_account_idx ON public.stk_inventory USING btree (raw_material_stock_account);


--
-- Name: stk_inventory_raw_material_usage_account_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_inventory_raw_material_usage_account_idx ON public.stk_inventory USING btree (raw_material_usage_account);


--
-- Name: stk_inventory_sales_account_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_inventory_sales_account_idx ON public.stk_inventory USING btree (sales_account);


--
-- Name: stk_inventory_sales_return_account_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_inventory_sales_return_account_idx ON public.stk_inventory USING btree (sales_return_account);


--
-- Name: stk_inventory_semi_product_account_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_inventory_semi_product_account_idx ON public.stk_inventory USING btree (semi_product_account);


--
-- Name: stk_inventory_stk_group_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_inventory_stk_group_id_idx ON public.stk_inventory USING btree (stk_group_id);


--
-- Name: stk_inventory_stk_product_type_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_inventory_stk_product_type_id_idx ON public.stk_inventory USING btree (stk_product_type_id);


--
-- Name: stk_inventory_sys_country_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_inventory_sys_country_id_idx ON public.stk_inventory USING btree (sys_country_id);


--
-- Name: stk_inventory_sys_uom_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_inventory_sys_uom_id_idx ON public.stk_inventory USING btree (sys_uom_id);


--
-- Name: stk_inventory_vat_rate_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_inventory_vat_rate_idx ON public.stk_inventory USING btree (vat_rate);


--
-- Name: stk_kind_property_stk_kind_family_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_kind_property_stk_kind_family_id_idx ON public.stk_kind_property USING btree (stk_kind_family_id);


--
-- Name: stk_transaction_currency_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_transaction_currency_idx ON public.stk_transaction USING btree (currency);


--
-- Name: stk_transaction_from_stk_warehouse_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_transaction_from_stk_warehouse_id_idx ON public.stk_transaction USING btree (from_stk_warehouse_id);


--
-- Name: stk_transaction_stk_inventory_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_transaction_stk_inventory_id_idx ON public.stk_transaction USING btree (stk_inventory_id, transaction_date);


--
-- Name: stk_transaction_to_stk_warehouse_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_transaction_to_stk_warehouse_id_idx ON public.stk_transaction USING btree (to_stk_warehouse_id);


--
-- Name: stk_warehouse_default_production_uidx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE UNIQUE INDEX stk_warehouse_default_production_uidx ON public.stk_warehouse USING btree ((true)) WHERE default_production;


--
-- Name: stk_warehouse_default_raw_material_uidx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE UNIQUE INDEX stk_warehouse_default_raw_material_uidx ON public.stk_warehouse USING btree ((true)) WHERE default_raw_material;


--
-- Name: stk_warehouse_default_sales_uidx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE UNIQUE INDEX stk_warehouse_default_sales_uidx ON public.stk_warehouse USING btree ((true)) WHERE default_sales;


--
-- Name: sys_city_sys_region_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sys_city_sys_region_id_idx ON public.sys_city USING btree (sys_region_id);


--
-- Name: sys_menu_parent_code_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sys_menu_parent_code_idx ON public.sys_menu USING btree (parent_code);


--
-- Name: sys_menu_sys_permission_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sys_menu_sys_permission_id_idx ON public.sys_menu USING btree (sys_permission_id);


--
-- Name: sys_menu_translation_sys_language_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sys_menu_translation_sys_language_id_idx ON public.sys_menu_translation USING btree (sys_language_id);


--
-- Name: sys_permission_template_right_permission_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sys_permission_template_right_permission_idx ON public.sys_permission_template_right USING btree (sys_permission_id);


--
-- Name: sys_user_menu_sys_menu_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sys_user_menu_sys_menu_id_idx ON public.sys_user_menu USING btree (sys_menu_id);


--
-- Name: sys_user_permission_template_template_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sys_user_permission_template_template_idx ON public.sys_user_permission_template USING btree (sys_permission_template_id);


--
-- Name: acc_voucher audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.acc_voucher FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: acc_voucher_detail audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.acc_voucher_detail FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: einv_delivery_term audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.einv_delivery_term FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: einv_diib audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.einv_diib FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: einv_diib_line audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.einv_diib_line FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: einv_document_setting audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.einv_document_setting FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: einv_driver audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.einv_driver FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: einv_gtip audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.einv_gtip FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: einv_invoice_type audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.einv_invoice_type FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: einv_packaging_type audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.einv_packaging_type FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: einv_payment_means audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.einv_payment_means FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: einv_profile audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.einv_profile FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: einv_series audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.einv_series FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: einv_tax_exemption audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.einv_tax_exemption FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: einv_tax_type audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.einv_tax_type FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: einv_transport_mode audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.einv_transport_mode FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: einv_vehicle audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.einv_vehicle FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: einv_withholding audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.einv_withholding FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: emp_section audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.emp_section FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: pur_quotation audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.pur_quotation FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: pur_quotation_detail audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.pur_quotation_detail FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: qc_inspection audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.qc_inspection FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: qc_rule audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.qc_rule FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: qc_setting audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.qc_setting FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: sys_access_right audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.sys_access_right FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: sys_api_service audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.sys_api_service FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: sys_city audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.sys_city FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: sys_country audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.sys_country FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: sys_currency audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.sys_currency FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: sys_decimal_place audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.sys_decimal_place FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: sys_language audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.sys_language FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: sys_menu audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.sys_menu FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: sys_permission_template audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.sys_permission_template FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: sys_permission_template_right audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.sys_permission_template_right FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: sys_region audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.sys_region FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: sys_user_permission_template audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.sys_user_permission_template FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: emp_driver_ability notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_driver_ability FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_driver_license_type notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_driver_license_type FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_employee notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_employee FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_language notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_language FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_person_language_ability notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_person_language_ability FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_person_type notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_person_type FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_task notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_task FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_transportation notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_transportation FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_unit notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_unit FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: fin_cheque_note notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.fin_cheque_note FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: fin_cheque_note_transaction notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.fin_cheque_note_transaction FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: fin_company_bank_account notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.fin_company_bank_account FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: fin_credit_card notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.fin_credit_card FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: fin_credit_card_transaction notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.fin_credit_card_transaction FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: fin_money_account notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.fin_money_account FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: fin_money_transaction notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.fin_money_transaction FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: fin_pos_terminal notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.fin_pos_terminal FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: fin_pos_transaction notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.fin_pos_transaction FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_bom notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_bom FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_bom_by_product notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_bom_by_product FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_bom_labour notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_bom_labour FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_bom_packet_labour notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_bom_packet_labour FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_bom_packet_raw notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_bom_packet_raw FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_bom_raw notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_bom_raw FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_labour notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_labour FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_packet_labour notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_packet_labour FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_packet_labour_detail notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_packet_labour_detail FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_packet_raw notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_packet_raw FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_packet_raw_detail notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_packet_raw_detail FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: pur_invoice notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.pur_invoice FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: pur_invoice_detail notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.pur_invoice_detail FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: pur_order notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.pur_order FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: pur_order_detail notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.pur_order_detail FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: pur_quotation notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.pur_quotation FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: pur_quotation_detail notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.pur_quotation_detail FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: pur_receipt notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.pur_receipt FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: pur_receipt_detail notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.pur_receipt_detail FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: pur_request notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.pur_request FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: pur_request_detail notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.pur_request_detail FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: qc_inspection notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.qc_inspection FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: sls_dispatch notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.sls_dispatch FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: sls_dispatch_detail notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.sls_dispatch_detail FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: sls_invoice notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.sls_invoice FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: sls_invoice_detail notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.sls_invoice_detail FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: sls_offer notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.sls_offer FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: sls_offer_detail notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.sls_offer_detail FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: sls_order notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.sls_order FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: sls_order_detail notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.sls_order_detail FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_card_kind_info notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_card_kind_info FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_group notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_group FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_inventory notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_inventory FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_transaction notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_transaction FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_warehouse notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_warehouse FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: pur_quotation order_unlinked; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER order_unlinked BEFORE UPDATE OF pur_order_id ON public.pur_quotation FOR EACH ROW EXECUTE FUNCTION public.pur_quotation_order_unlinked();


--
-- Name: pur_invoice party_snapshot; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER party_snapshot BEFORE INSERT OR UPDATE ON public.pur_invoice FOR EACH ROW EXECUTE FUNCTION public.fn_document_party_snapshot();


--
-- Name: pur_order party_snapshot; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER party_snapshot BEFORE INSERT OR UPDATE ON public.pur_order FOR EACH ROW EXECUTE FUNCTION public.fn_document_party_snapshot();


--
-- Name: pur_quotation party_snapshot; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER party_snapshot BEFORE INSERT OR UPDATE ON public.pur_quotation FOR EACH ROW EXECUTE FUNCTION public.fn_document_party_snapshot();


--
-- Name: pur_receipt party_snapshot; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER party_snapshot BEFORE INSERT OR UPDATE ON public.pur_receipt FOR EACH ROW EXECUTE FUNCTION public.fn_document_party_snapshot();


--
-- Name: sls_dispatch party_snapshot; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER party_snapshot BEFORE INSERT OR UPDATE ON public.sls_dispatch FOR EACH ROW EXECUTE FUNCTION public.fn_document_party_snapshot();


--
-- Name: sls_invoice party_snapshot; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER party_snapshot BEFORE INSERT OR UPDATE ON public.sls_invoice FOR EACH ROW EXECUTE FUNCTION public.fn_document_party_snapshot();


--
-- Name: sls_offer party_snapshot; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER party_snapshot BEFORE INSERT OR UPDATE ON public.sls_offer FOR EACH ROW EXECUTE FUNCTION public.fn_document_party_snapshot();


--
-- Name: sls_order party_snapshot; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER party_snapshot BEFORE INSERT OR UPDATE ON public.sls_order FOR EACH ROW EXECUTE FUNCTION public.fn_document_party_snapshot();


--
-- Name: sys_grid_column sys_grid_col_width_table_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER sys_grid_col_width_table_notify AFTER INSERT OR DELETE OR UPDATE ON public.sys_grid_column FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_section table_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER table_notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_section FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_kind_family table_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER table_notify BEFORE INSERT OR DELETE OR UPDATE ON public.stk_kind_family FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_kind_property table_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER table_notify BEFORE INSERT OR DELETE OR UPDATE ON public.stk_kind_property FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: pur_invoice_detail tax_summary_del; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER tax_summary_del AFTER DELETE ON public.pur_invoice_detail REFERENCING OLD TABLE AS old_rows FOR EACH STATEMENT EXECUTE FUNCTION public.fn_tax_summary_trigger('pur_invoice');


--
-- Name: pur_order_detail tax_summary_del; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER tax_summary_del AFTER DELETE ON public.pur_order_detail REFERENCING OLD TABLE AS old_rows FOR EACH STATEMENT EXECUTE FUNCTION public.fn_tax_summary_trigger('pur_order');


--
-- Name: pur_quotation_detail tax_summary_del; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER tax_summary_del AFTER DELETE ON public.pur_quotation_detail REFERENCING OLD TABLE AS old_rows FOR EACH STATEMENT EXECUTE FUNCTION public.fn_tax_summary_trigger('pur_quotation');


--
-- Name: sls_invoice_detail tax_summary_del; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER tax_summary_del AFTER DELETE ON public.sls_invoice_detail REFERENCING OLD TABLE AS old_rows FOR EACH STATEMENT EXECUTE FUNCTION public.fn_tax_summary_trigger('sls_invoice');


--
-- Name: sls_offer_detail tax_summary_del; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER tax_summary_del AFTER DELETE ON public.sls_offer_detail REFERENCING OLD TABLE AS old_rows FOR EACH STATEMENT EXECUTE FUNCTION public.fn_tax_summary_trigger('sls_offer');


--
-- Name: sls_order_detail tax_summary_del; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER tax_summary_del AFTER DELETE ON public.sls_order_detail REFERENCING OLD TABLE AS old_rows FOR EACH STATEMENT EXECUTE FUNCTION public.fn_tax_summary_trigger('sls_order');


--
-- Name: pur_invoice_detail tax_summary_ins; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER tax_summary_ins AFTER INSERT ON public.pur_invoice_detail REFERENCING NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION public.fn_tax_summary_trigger('pur_invoice');


--
-- Name: pur_order_detail tax_summary_ins; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER tax_summary_ins AFTER INSERT ON public.pur_order_detail REFERENCING NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION public.fn_tax_summary_trigger('pur_order');


--
-- Name: pur_quotation_detail tax_summary_ins; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER tax_summary_ins AFTER INSERT ON public.pur_quotation_detail REFERENCING NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION public.fn_tax_summary_trigger('pur_quotation');


--
-- Name: sls_invoice_detail tax_summary_ins; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER tax_summary_ins AFTER INSERT ON public.sls_invoice_detail REFERENCING NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION public.fn_tax_summary_trigger('sls_invoice');


--
-- Name: sls_offer_detail tax_summary_ins; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER tax_summary_ins AFTER INSERT ON public.sls_offer_detail REFERENCING NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION public.fn_tax_summary_trigger('sls_offer');


--
-- Name: sls_order_detail tax_summary_ins; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER tax_summary_ins AFTER INSERT ON public.sls_order_detail REFERENCING NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION public.fn_tax_summary_trigger('sls_order');


--
-- Name: pur_invoice_detail tax_summary_upd; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER tax_summary_upd AFTER UPDATE ON public.pur_invoice_detail REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION public.fn_tax_summary_trigger('pur_invoice');


--
-- Name: pur_order_detail tax_summary_upd; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER tax_summary_upd AFTER UPDATE ON public.pur_order_detail REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION public.fn_tax_summary_trigger('pur_order');


--
-- Name: pur_quotation_detail tax_summary_upd; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER tax_summary_upd AFTER UPDATE ON public.pur_quotation_detail REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION public.fn_tax_summary_trigger('pur_quotation');


--
-- Name: sls_invoice_detail tax_summary_upd; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER tax_summary_upd AFTER UPDATE ON public.sls_invoice_detail REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION public.fn_tax_summary_trigger('sls_invoice');


--
-- Name: sls_offer_detail tax_summary_upd; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER tax_summary_upd AFTER UPDATE ON public.sls_offer_detail REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION public.fn_tax_summary_trigger('sls_offer');


--
-- Name: sls_order_detail tax_summary_upd; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER tax_summary_upd AFTER UPDATE ON public.sls_order_detail REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION public.fn_tax_summary_trigger('sls_order');


--
-- Name: acc_account trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.acc_account FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_bank trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.acc_bank FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_bank_branch trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.acc_bank_branch FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_exchange_rate trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.acc_exchange_rate FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_region trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.acc_region FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_set_tax_rate trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.acc_set_tax_rate FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_transfer_code trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.acc_transfer_code FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_voucher trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.acc_voucher FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_voucher_detail trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.acc_voucher_detail FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_account acc_account_acc_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account
    ADD CONSTRAINT acc_account_acc_group_id_fkey FOREIGN KEY (acc_group_id) REFERENCES public.acc_group(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_account acc_account_acc_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account
    ADD CONSTRAINT acc_account_acc_region_id_fkey FOREIGN KEY (acc_region_id) REFERENCES public.acc_region(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_account acc_account_acc_set_account_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account
    ADD CONSTRAINT acc_account_acc_set_account_type_id_fkey FOREIGN KEY (acc_set_account_type_id) REFERENCES public.acc_set_account_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_account_address acc_account_address_acc_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account_address
    ADD CONSTRAINT acc_account_address_acc_account_id_fkey FOREIGN KEY (acc_account_id) REFERENCES public.acc_account(id) ON DELETE CASCADE;


--
-- Name: acc_account_address acc_account_address_sys_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account_address
    ADD CONSTRAINT acc_account_address_sys_address_id_fkey FOREIGN KEY (sys_address_id) REFERENCES public.sys_address(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_account_contact acc_account_contact_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account_contact
    ADD CONSTRAINT acc_account_contact_account_id_fkey FOREIGN KEY (acc_account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: acc_account_taxpayer acc_account_taxpayer_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account_taxpayer
    ADD CONSTRAINT acc_account_taxpayer_account_id_fkey FOREIGN KEY (acc_account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: acc_bank_branch acc_branch_acc_bank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_bank_branch
    ADD CONSTRAINT acc_branch_acc_bank_id_fkey FOREIGN KEY (acc_bank_id) REFERENCES public.acc_bank(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_bank_branch acc_branch_sys_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_bank_branch
    ADD CONSTRAINT acc_branch_sys_city_id_fkey FOREIGN KEY (sys_city_id) REFERENCES public.sys_city(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_exchange_rate acc_er_curr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_exchange_rate
    ADD CONSTRAINT acc_er_curr_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: acc_set_account_type_translation acc_set_account_type_translation_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_account_type_translation
    ADD CONSTRAINT acc_set_account_type_translation_language_id_fkey FOREIGN KEY (sys_language_id) REFERENCES public.sys_language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: acc_set_account_type_translation acc_set_account_type_translation_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_account_type_translation
    ADD CONSTRAINT acc_set_account_type_translation_type_id_fkey FOREIGN KEY (acc_set_account_type_id) REFERENCES public.acc_set_account_type(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: acc_set_company_legal_form acc_set_company_legal_form_acc_set_ownership_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_company_legal_form
    ADD CONSTRAINT acc_set_company_legal_form_acc_set_ownership_type_id_fkey FOREIGN KEY (acc_set_ownership_type_id) REFERENCES public.acc_set_ownership_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_set_company_legal_form_translation acc_set_company_legal_form_translation_form_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_company_legal_form_translation
    ADD CONSTRAINT acc_set_company_legal_form_translation_form_id_fkey FOREIGN KEY (acc_set_company_legal_form_id) REFERENCES public.acc_set_company_legal_form(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: acc_set_company_legal_form_translation acc_set_company_legal_form_translation_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_company_legal_form_translation
    ADD CONSTRAINT acc_set_company_legal_form_translation_language_id_fkey FOREIGN KEY (sys_language_id) REFERENCES public.sys_language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: acc_set_ownership_type_translation acc_set_ownership_type_translation_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_ownership_type_translation
    ADD CONSTRAINT acc_set_ownership_type_translation_language_id_fkey FOREIGN KEY (sys_language_id) REFERENCES public.sys_language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: acc_set_ownership_type_translation acc_set_ownership_type_translation_ownership_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_ownership_type_translation
    ADD CONSTRAINT acc_set_ownership_type_translation_ownership_id_fkey FOREIGN KEY (acc_set_ownership_type_id) REFERENCES public.acc_set_ownership_type(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: acc_set_tax_rate acc_set_tr_pacct_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_tax_rate
    ADD CONSTRAINT acc_set_tr_pacct_fkey FOREIGN KEY (purchase_account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_set_tax_rate acc_set_tr_prturn_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_tax_rate
    ADD CONSTRAINT acc_set_tr_prturn_fkey FOREIGN KEY (purchase_return_account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_set_tax_rate acc_set_tr_sacct_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_tax_rate
    ADD CONSTRAINT acc_set_tr_sacct_fkey FOREIGN KEY (sales_account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_set_tax_rate acc_set_tr_srturn_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_tax_rate
    ADD CONSTRAINT acc_set_tr_srturn_fkey FOREIGN KEY (sales_return_account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_voucher_detail acc_voucher_detail_acc_voucher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_voucher_detail
    ADD CONSTRAINT acc_voucher_detail_acc_voucher_id_fkey FOREIGN KEY (acc_voucher_id) REFERENCES public.acc_voucher(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: acc_voucher_detail acc_voucher_detail_account_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_voucher_detail
    ADD CONSTRAINT acc_voucher_detail_account_fkey FOREIGN KEY (acc_account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: einv_diib einv_diib_acc_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_diib
    ADD CONSTRAINT einv_diib_acc_account_id_fkey FOREIGN KEY (acc_account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: einv_diib_line einv_diib_line_einv_diib_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_diib_line
    ADD CONSTRAINT einv_diib_line_einv_diib_id_fkey FOREIGN KEY (einv_diib_id) REFERENCES public.einv_diib(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: einv_diib_line einv_diib_line_einv_gtip_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_diib_line
    ADD CONSTRAINT einv_diib_line_einv_gtip_id_fkey FOREIGN KEY (einv_gtip_id) REFERENCES public.einv_gtip(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: einv_diib_line einv_diib_line_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_diib_line
    ADD CONSTRAINT einv_diib_line_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: einv_diib_line einv_diib_line_sys_uom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_diib_line
    ADD CONSTRAINT einv_diib_line_sys_uom_id_fkey FOREIGN KEY (sys_uom_id) REFERENCES public.sys_uom(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: einv_document einv_document_invoice_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_document
    ADD CONSTRAINT einv_document_invoice_fkey FOREIGN KEY (sls_invoice_id) REFERENCES public.sls_invoice(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: einv_document_setting einv_document_setting_einv_series_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_document_setting
    ADD CONSTRAINT einv_document_setting_einv_series_id_fkey FOREIGN KEY (einv_series_id) REFERENCES public.einv_series(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: einv_document_setting einv_document_setting_sys_api_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_document_setting
    ADD CONSTRAINT einv_document_setting_sys_api_service_id_fkey FOREIGN KEY (sys_api_service_id) REFERENCES public.sys_api_service(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: einv_document_setting einv_document_setting_sys_application_setting_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_document_setting
    ADD CONSTRAINT einv_document_setting_sys_application_setting_id_fkey FOREIGN KEY (sys_application_setting_id) REFERENCES public.sys_application_setting(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: einv_document einv_document_sls_dispatch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_document
    ADD CONSTRAINT einv_document_sls_dispatch_id_fkey FOREIGN KEY (sls_dispatch_id) REFERENCES public.sls_dispatch(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: einv_series_counter einv_series_counter_series_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_series_counter
    ADD CONSTRAINT einv_series_counter_series_fkey FOREIGN KEY (einv_series_id) REFERENCES public.einv_series(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: einv_tax_exemption einv_tax_exemption_einv_invoice_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_tax_exemption
    ADD CONSTRAINT einv_tax_exemption_einv_invoice_type_id_fkey FOREIGN KEY (einv_invoice_type_id) REFERENCES public.einv_invoice_type(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: emp_employee emp_employee_emp_person_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_employee
    ADD CONSTRAINT emp_employee_emp_person_type_id_fkey FOREIGN KEY (emp_person_type_id) REFERENCES public.emp_person_type(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: emp_employee emp_employee_emp_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_employee
    ADD CONSTRAINT emp_employee_emp_task_id_fkey FOREIGN KEY (emp_task_id) REFERENCES public.emp_task(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: emp_employee emp_employee_emp_transportation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_employee
    ADD CONSTRAINT emp_employee_emp_transportation_id_fkey FOREIGN KEY (emp_transportation_id) REFERENCES public.emp_transportation(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: emp_employee emp_employee_emp_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_employee
    ADD CONSTRAINT emp_employee_emp_unit_id_fkey FOREIGN KEY (emp_unit_id) REFERENCES public.emp_unit(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: emp_person_address emp_person_address_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_address
    ADD CONSTRAINT emp_person_address_address_id_fkey FOREIGN KEY (sys_address_id) REFERENCES public.sys_address(id) ON DELETE RESTRICT;


--
-- Name: emp_person_address emp_person_address_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_address
    ADD CONSTRAINT emp_person_address_person_id_fkey FOREIGN KEY (emp_employee_id) REFERENCES public.emp_employee(id) ON DELETE CASCADE;


--
-- Name: emp_person_type_translation emp_person_type_translation_emp_person_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_type_translation
    ADD CONSTRAINT emp_person_type_translation_emp_person_type_id_fkey FOREIGN KEY (emp_person_type_id) REFERENCES public.emp_person_type(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_person_type_translation emp_person_type_translation_sys_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_type_translation
    ADD CONSTRAINT emp_person_type_translation_sys_language_id_fkey FOREIGN KEY (sys_language_id) REFERENCES public.sys_language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_section_translation emp_section_translation_emp_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_section_translation
    ADD CONSTRAINT emp_section_translation_emp_section_id_fkey FOREIGN KEY (emp_section_id) REFERENCES public.emp_section(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_section_translation emp_section_translation_sys_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_section_translation
    ADD CONSTRAINT emp_section_translation_sys_language_id_fkey FOREIGN KEY (sys_language_id) REFERENCES public.sys_language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_task_translation emp_task_translation_emp_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_task_translation
    ADD CONSTRAINT emp_task_translation_emp_task_id_fkey FOREIGN KEY (emp_task_id) REFERENCES public.emp_task(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_task_translation emp_task_translation_sys_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_task_translation
    ADD CONSTRAINT emp_task_translation_sys_language_id_fkey FOREIGN KEY (sys_language_id) REFERENCES public.sys_language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_unit_translation emp_unit_translation_emp_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_unit_translation
    ADD CONSTRAINT emp_unit_translation_emp_unit_id_fkey FOREIGN KEY (emp_unit_id) REFERENCES public.emp_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_unit_translation emp_unit_translation_sys_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_unit_translation
    ADD CONSTRAINT emp_unit_translation_sys_language_id_fkey FOREIGN KEY (sys_language_id) REFERENCES public.sys_language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fin_cheque_note fin_cheque_note_acc_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_cheque_note
    ADD CONSTRAINT fin_cheque_note_acc_account_id_fkey FOREIGN KEY (acc_account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_cheque_note fin_cheque_note_acc_bank_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_cheque_note
    ADD CONSTRAINT fin_cheque_note_acc_bank_branch_id_fkey FOREIGN KEY (acc_bank_branch_id) REFERENCES public.acc_bank_branch(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_cheque_note fin_cheque_note_acc_bank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_cheque_note
    ADD CONSTRAINT fin_cheque_note_acc_bank_id_fkey FOREIGN KEY (acc_bank_id) REFERENCES public.acc_bank(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_cheque_note fin_cheque_note_company_bank_account_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_cheque_note
    ADD CONSTRAINT fin_cheque_note_company_bank_account_fkey FOREIGN KEY (fin_company_bank_account_id) REFERENCES public.fin_company_bank_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_cheque_note fin_cheque_note_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_cheque_note
    ADD CONSTRAINT fin_cheque_note_currency_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_cheque_note_transaction fin_cheque_note_transaction_acc_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_cheque_note_transaction
    ADD CONSTRAINT fin_cheque_note_transaction_acc_account_id_fkey FOREIGN KEY (acc_account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_cheque_note_transaction fin_cheque_note_transaction_acc_bank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_cheque_note_transaction
    ADD CONSTRAINT fin_cheque_note_transaction_acc_bank_id_fkey FOREIGN KEY (acc_bank_id) REFERENCES public.acc_bank(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_cheque_note_transaction fin_cheque_note_transaction_note_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_cheque_note_transaction
    ADD CONSTRAINT fin_cheque_note_transaction_note_fkey FOREIGN KEY (fin_cheque_note_id) REFERENCES public.fin_cheque_note(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fin_company_bank_account fin_company_bank_account_acc_bank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_company_bank_account
    ADD CONSTRAINT fin_company_bank_account_acc_bank_id_fkey FOREIGN KEY (acc_bank_id) REFERENCES public.acc_bank(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_company_bank_account fin_company_bank_account_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_company_bank_account
    ADD CONSTRAINT fin_company_bank_account_currency_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_company_bank_account fin_company_bank_account_sys_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_company_bank_account
    ADD CONSTRAINT fin_company_bank_account_sys_city_id_fkey FOREIGN KEY (sys_city_id) REFERENCES public.sys_city(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_credit_card fin_credit_card_acc_account_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_credit_card
    ADD CONSTRAINT fin_credit_card_acc_account_code_fkey FOREIGN KEY (acc_account_code) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_credit_card fin_credit_card_acc_bank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_credit_card
    ADD CONSTRAINT fin_credit_card_acc_bank_id_fkey FOREIGN KEY (acc_bank_id) REFERENCES public.acc_bank(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_credit_card fin_credit_card_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_credit_card
    ADD CONSTRAINT fin_credit_card_currency_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_credit_card_transaction fin_credit_card_transaction_acc_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_credit_card_transaction
    ADD CONSTRAINT fin_credit_card_transaction_acc_account_id_fkey FOREIGN KEY (acc_account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_credit_card_transaction fin_credit_card_transaction_card_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_credit_card_transaction
    ADD CONSTRAINT fin_credit_card_transaction_card_fkey FOREIGN KEY (fin_credit_card_id) REFERENCES public.fin_credit_card(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_money_account fin_money_account_acc_account_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_money_account
    ADD CONSTRAINT fin_money_account_acc_account_code_fkey FOREIGN KEY (acc_account_code) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_money_account fin_money_account_acc_bank_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_money_account
    ADD CONSTRAINT fin_money_account_acc_bank_branch_id_fkey FOREIGN KEY (acc_bank_branch_id) REFERENCES public.acc_bank_branch(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_money_account fin_money_account_acc_bank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_money_account
    ADD CONSTRAINT fin_money_account_acc_bank_id_fkey FOREIGN KEY (acc_bank_id) REFERENCES public.acc_bank(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_money_account fin_money_account_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_money_account
    ADD CONSTRAINT fin_money_account_currency_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_money_transaction fin_money_transaction_acc_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_money_transaction
    ADD CONSTRAINT fin_money_transaction_acc_account_id_fkey FOREIGN KEY (acc_account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_money_transaction fin_money_transaction_account_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_money_transaction
    ADD CONSTRAINT fin_money_transaction_account_fkey FOREIGN KEY (fin_money_account_id) REFERENCES public.fin_money_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_money_transaction fin_money_transaction_target_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_money_transaction
    ADD CONSTRAINT fin_money_transaction_target_fkey FOREIGN KEY (target_fin_money_account_id) REFERENCES public.fin_money_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_pos_terminal fin_pos_terminal_acc_account_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_pos_terminal
    ADD CONSTRAINT fin_pos_terminal_acc_account_code_fkey FOREIGN KEY (acc_account_code) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_pos_terminal fin_pos_terminal_acc_bank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_pos_terminal
    ADD CONSTRAINT fin_pos_terminal_acc_bank_id_fkey FOREIGN KEY (acc_bank_id) REFERENCES public.acc_bank(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_pos_terminal fin_pos_terminal_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_pos_terminal
    ADD CONSTRAINT fin_pos_terminal_currency_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_pos_transaction fin_pos_transaction_acc_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_pos_transaction
    ADD CONSTRAINT fin_pos_transaction_acc_account_id_fkey FOREIGN KEY (acc_account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fin_pos_transaction fin_pos_transaction_pos_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.fin_pos_transaction
    ADD CONSTRAINT fin_pos_transaction_pos_fkey FOREIGN KEY (fin_pos_terminal_id) REFERENCES public.fin_pos_terminal(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_transfer_code mhs_transfer_kodlari_hesap_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_transfer_code
    ADD CONSTRAINT mhs_transfer_kodlari_hesap_kodu_fkey FOREIGN KEY (account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_bom_by_product prd_bom_by_product_prd_bom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_by_product
    ADD CONSTRAINT prd_bom_by_product_prd_bom_id_fkey FOREIGN KEY (prd_bom_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_by_product prd_bom_by_product_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_by_product
    ADD CONSTRAINT prd_bom_by_product_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_bom_labour prd_bom_labour_prd_bom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_labour
    ADD CONSTRAINT prd_bom_labour_prd_bom_id_fkey FOREIGN KEY (prd_bom_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_labour prd_bom_labour_prd_labour_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_labour
    ADD CONSTRAINT prd_bom_labour_prd_labour_id_fkey FOREIGN KEY (prd_labour_id) REFERENCES public.prd_labour(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_bom_packet_labour prd_bom_packet_labour_prd_bom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_labour
    ADD CONSTRAINT prd_bom_packet_labour_prd_bom_id_fkey FOREIGN KEY (prd_bom_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_packet_labour prd_bom_packet_labour_prd_packet_labour_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_labour
    ADD CONSTRAINT prd_bom_packet_labour_prd_packet_labour_id_fkey FOREIGN KEY (prd_packet_labour_id) REFERENCES public.prd_packet_labour(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_bom_packet_raw prd_bom_packet_raw_prd_bom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_raw
    ADD CONSTRAINT prd_bom_packet_raw_prd_bom_id_fkey FOREIGN KEY (prd_bom_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_packet_raw prd_bom_packet_raw_prd_packet_raw_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_raw
    ADD CONSTRAINT prd_bom_packet_raw_prd_packet_raw_id_fkey FOREIGN KEY (prd_packet_raw_id) REFERENCES public.prd_packet_raw(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_bom_raw prd_bom_raw_prd_bom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_raw
    ADD CONSTRAINT prd_bom_raw_prd_bom_id_fkey FOREIGN KEY (prd_bom_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_raw prd_bom_raw_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_raw
    ADD CONSTRAINT prd_bom_raw_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_bom_raw prd_bom_raw_sub_prd_bom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_raw
    ADD CONSTRAINT prd_bom_raw_sub_prd_bom_id_fkey FOREIGN KEY (sub_prd_bom_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: prd_bom prd_bom_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom
    ADD CONSTRAINT prd_bom_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_labour prd_labour_acc_account_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_labour
    ADD CONSTRAINT prd_labour_acc_account_code_fkey FOREIGN KEY (acc_account_code) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_labour prd_labour_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_labour
    ADD CONSTRAINT prd_labour_currency_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_labour prd_labour_sys_uom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_labour
    ADD CONSTRAINT prd_labour_sys_uom_id_fkey FOREIGN KEY (sys_uom_id) REFERENCES public.sys_uom(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_packet_labour_detail prd_packet_labour_detail_prd_labour_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_labour_detail
    ADD CONSTRAINT prd_packet_labour_detail_prd_labour_id_fkey FOREIGN KEY (prd_labour_id) REFERENCES public.prd_labour(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_packet_labour_detail prd_packet_labour_detail_prd_packet_labour_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_labour_detail
    ADD CONSTRAINT prd_packet_labour_detail_prd_packet_labour_id_fkey FOREIGN KEY (prd_packet_labour_id) REFERENCES public.prd_packet_labour(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_packet_raw_detail prd_packet_raw_detail_prd_packet_raw_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_raw_detail
    ADD CONSTRAINT prd_packet_raw_detail_prd_packet_raw_id_fkey FOREIGN KEY (prd_packet_raw_id) REFERENCES public.prd_packet_raw(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_packet_raw_detail prd_packet_raw_detail_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_raw_detail
    ADD CONSTRAINT prd_packet_raw_detail_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_packet_raw_detail prd_packet_raw_detail_sub_prd_bom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_raw_detail
    ADD CONSTRAINT prd_packet_raw_detail_sub_prd_bom_id_fkey FOREIGN KEY (sub_prd_bom_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: emp_driver_ability prs_driver_abilities_driver_license_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_driver_ability
    ADD CONSTRAINT prs_driver_abilities_driver_license_id_fkey FOREIGN KEY (emp_driver_license_type_id) REFERENCES public.emp_driver_license_type(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_driver_ability prs_driver_abilities_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_driver_ability
    ADD CONSTRAINT prs_driver_abilities_person_id_fkey FOREIGN KEY (emp_employee_id) REFERENCES public.emp_employee(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_person_language_ability prs_language_abilities_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_language_ability
    ADD CONSTRAINT prs_language_abilities_language_id_fkey FOREIGN KEY (emp_language_id) REFERENCES public.emp_language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_person_language_ability prs_language_abilities_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_language_ability
    ADD CONSTRAINT prs_language_abilities_person_id_fkey FOREIGN KEY (emp_employee_id) REFERENCES public.emp_employee(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_unit prs_set_unit_ssection_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_unit
    ADD CONSTRAINT prs_set_unit_ssection_fkey FOREIGN KEY (emp_section_id) REFERENCES public.emp_section(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_invoice pur_invoice_acc_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_invoice
    ADD CONSTRAINT pur_invoice_acc_account_id_fkey FOREIGN KEY (acc_account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_invoice pur_invoice_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_invoice
    ADD CONSTRAINT pur_invoice_currency_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_invoice_detail pur_invoice_detail_invoice_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_invoice_detail
    ADD CONSTRAINT pur_invoice_detail_invoice_fkey FOREIGN KEY (pur_invoice_id) REFERENCES public.pur_invoice(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pur_invoice_detail pur_invoice_detail_receipt_detail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_invoice_detail
    ADD CONSTRAINT pur_invoice_detail_receipt_detail_fkey FOREIGN KEY (pur_receipt_detail_id) REFERENCES public.pur_receipt_detail(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_invoice_detail pur_invoice_detail_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_invoice_detail
    ADD CONSTRAINT pur_invoice_detail_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_invoice_tax_summary pur_invoice_tax_summary_header_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_invoice_tax_summary
    ADD CONSTRAINT pur_invoice_tax_summary_header_fkey FOREIGN KEY (pur_invoice_id) REFERENCES public.pur_invoice(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pur_invoice_tax_summary pur_invoice_tax_summary_withholding_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_invoice_tax_summary
    ADD CONSTRAINT pur_invoice_tax_summary_withholding_fkey FOREIGN KEY (einv_withholding_id) REFERENCES public.einv_withholding(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_order pur_order_acc_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_order
    ADD CONSTRAINT pur_order_acc_account_id_fkey FOREIGN KEY (acc_account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_order pur_order_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_order
    ADD CONSTRAINT pur_order_currency_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_order_detail pur_order_detail_order_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_order_detail
    ADD CONSTRAINT pur_order_detail_order_fkey FOREIGN KEY (pur_order_id) REFERENCES public.pur_order(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pur_order_detail pur_order_detail_request_detail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_order_detail
    ADD CONSTRAINT pur_order_detail_request_detail_fkey FOREIGN KEY (pur_request_detail_id) REFERENCES public.pur_request_detail(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: pur_order_detail pur_order_detail_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_order_detail
    ADD CONSTRAINT pur_order_detail_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_order pur_order_stk_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_order
    ADD CONSTRAINT pur_order_stk_warehouse_id_fkey FOREIGN KEY (stk_warehouse_id) REFERENCES public.stk_warehouse(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_order_tax_summary pur_order_tax_summary_header_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_order_tax_summary
    ADD CONSTRAINT pur_order_tax_summary_header_fkey FOREIGN KEY (pur_order_id) REFERENCES public.pur_order(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pur_order_tax_summary pur_order_tax_summary_withholding_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_order_tax_summary
    ADD CONSTRAINT pur_order_tax_summary_withholding_fkey FOREIGN KEY (einv_withholding_id) REFERENCES public.einv_withholding(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_quotation pur_quotation_acc_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_quotation
    ADD CONSTRAINT pur_quotation_acc_account_id_fkey FOREIGN KEY (acc_account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_quotation pur_quotation_approved_sys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_quotation
    ADD CONSTRAINT pur_quotation_approved_sys_user_id_fkey FOREIGN KEY (approved_sys_user_id) REFERENCES public.sys_user(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: pur_quotation pur_quotation_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_quotation
    ADD CONSTRAINT pur_quotation_currency_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_quotation_detail pur_quotation_detail_quotation_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_quotation_detail
    ADD CONSTRAINT pur_quotation_detail_quotation_fkey FOREIGN KEY (pur_quotation_id) REFERENCES public.pur_quotation(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pur_quotation_detail pur_quotation_detail_request_detail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_quotation_detail
    ADD CONSTRAINT pur_quotation_detail_request_detail_fkey FOREIGN KEY (pur_request_detail_id) REFERENCES public.pur_request_detail(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: pur_quotation_detail pur_quotation_detail_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_quotation_detail
    ADD CONSTRAINT pur_quotation_detail_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_quotation pur_quotation_order_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_quotation
    ADD CONSTRAINT pur_quotation_order_fkey FOREIGN KEY (pur_order_id) REFERENCES public.pur_order(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: pur_quotation pur_quotation_request_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_quotation
    ADD CONSTRAINT pur_quotation_request_fkey FOREIGN KEY (pur_request_id) REFERENCES public.pur_request(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: pur_quotation_tax_summary pur_quotation_tax_summary_header_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_quotation_tax_summary
    ADD CONSTRAINT pur_quotation_tax_summary_header_fkey FOREIGN KEY (pur_quotation_id) REFERENCES public.pur_quotation(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pur_quotation_tax_summary pur_quotation_tax_summary_withholding_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_quotation_tax_summary
    ADD CONSTRAINT pur_quotation_tax_summary_withholding_fkey FOREIGN KEY (einv_withholding_id) REFERENCES public.einv_withholding(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_receipt pur_receipt_acc_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_receipt
    ADD CONSTRAINT pur_receipt_acc_account_id_fkey FOREIGN KEY (acc_account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_receipt pur_receipt_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_receipt
    ADD CONSTRAINT pur_receipt_currency_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_receipt_detail pur_receipt_detail_order_detail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_receipt_detail
    ADD CONSTRAINT pur_receipt_detail_order_detail_fkey FOREIGN KEY (pur_order_detail_id) REFERENCES public.pur_order_detail(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_receipt_detail pur_receipt_detail_receipt_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_receipt_detail
    ADD CONSTRAINT pur_receipt_detail_receipt_fkey FOREIGN KEY (pur_receipt_id) REFERENCES public.pur_receipt(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pur_receipt_detail pur_receipt_detail_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_receipt_detail
    ADD CONSTRAINT pur_receipt_detail_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_receipt pur_receipt_order_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_receipt
    ADD CONSTRAINT pur_receipt_order_fkey FOREIGN KEY (pur_order_id) REFERENCES public.pur_order(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_receipt pur_receipt_stk_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_receipt
    ADD CONSTRAINT pur_receipt_stk_warehouse_id_fkey FOREIGN KEY (stk_warehouse_id) REFERENCES public.stk_warehouse(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_request_detail pur_request_detail_request_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_request_detail
    ADD CONSTRAINT pur_request_detail_request_fkey FOREIGN KEY (pur_request_id) REFERENCES public.pur_request(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pur_request_detail pur_request_detail_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_request_detail
    ADD CONSTRAINT pur_request_detail_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_request pur_request_emp_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_request
    ADD CONSTRAINT pur_request_emp_employee_id_fkey FOREIGN KEY (emp_employee_id) REFERENCES public.emp_employee(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: qc_inspection qc_inspection_emp_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.qc_inspection
    ADD CONSTRAINT qc_inspection_emp_employee_id_fkey FOREIGN KEY (emp_employee_id) REFERENCES public.emp_employee(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: qc_inspection qc_inspection_receipt_detail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.qc_inspection
    ADD CONSTRAINT qc_inspection_receipt_detail_fkey FOREIGN KEY (pur_receipt_detail_id) REFERENCES public.pur_receipt_detail(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: qc_inspection qc_inspection_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.qc_inspection
    ADD CONSTRAINT qc_inspection_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: qc_rule qc_rule_stk_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.qc_rule
    ADD CONSTRAINT qc_rule_stk_group_id_fkey FOREIGN KEY (stk_group_id) REFERENCES public.stk_group(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: qc_rule qc_rule_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.qc_rule
    ADD CONSTRAINT qc_rule_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: qc_setting qc_setting_reject_stk_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.qc_setting
    ADD CONSTRAINT qc_setting_reject_stk_warehouse_id_fkey FOREIGN KEY (reject_stk_warehouse_id) REFERENCES public.stk_warehouse(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: qc_setting qc_setting_sys_application_setting_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.qc_setting
    ADD CONSTRAINT qc_setting_sys_application_setting_id_fkey FOREIGN KEY (sys_application_setting_id) REFERENCES public.sys_application_setting(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sls_dispatch sls_dispatch_acc_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch
    ADD CONSTRAINT sls_dispatch_acc_account_id_fkey FOREIGN KEY (acc_account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_dispatch sls_dispatch_carrier_acc_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch
    ADD CONSTRAINT sls_dispatch_carrier_acc_account_id_fkey FOREIGN KEY (carrier_acc_account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_dispatch sls_dispatch_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch
    ADD CONSTRAINT sls_dispatch_currency_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_dispatch_detail sls_dispatch_detail_dispatch_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch_detail
    ADD CONSTRAINT sls_dispatch_detail_dispatch_fkey FOREIGN KEY (sls_dispatch_id) REFERENCES public.sls_dispatch(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sls_dispatch_detail sls_dispatch_detail_order_detail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch_detail
    ADD CONSTRAINT sls_dispatch_detail_order_detail_fkey FOREIGN KEY (sls_order_detail_id) REFERENCES public.sls_order_detail(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_dispatch_detail sls_dispatch_detail_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch_detail
    ADD CONSTRAINT sls_dispatch_detail_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_dispatch sls_dispatch_driver1_einv_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch
    ADD CONSTRAINT sls_dispatch_driver1_einv_driver_id_fkey FOREIGN KEY (driver1_einv_driver_id) REFERENCES public.einv_driver(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_dispatch sls_dispatch_driver2_einv_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch
    ADD CONSTRAINT sls_dispatch_driver2_einv_driver_id_fkey FOREIGN KEY (driver2_einv_driver_id) REFERENCES public.einv_driver(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_dispatch sls_dispatch_einv_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch
    ADD CONSTRAINT sls_dispatch_einv_profile_id_fkey FOREIGN KEY (einv_profile_id) REFERENCES public.einv_profile(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_dispatch sls_dispatch_einv_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch
    ADD CONSTRAINT sls_dispatch_einv_vehicle_id_fkey FOREIGN KEY (einv_vehicle_id) REFERENCES public.einv_vehicle(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_dispatch sls_dispatch_order_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch
    ADD CONSTRAINT sls_dispatch_order_fkey FOREIGN KEY (sls_order_id) REFERENCES public.sls_order(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_dispatch sls_dispatch_stk_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch
    ADD CONSTRAINT sls_dispatch_stk_warehouse_id_fkey FOREIGN KEY (stk_warehouse_id) REFERENCES public.stk_warehouse(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_dispatch sls_dispatch_trailer1_einv_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch
    ADD CONSTRAINT sls_dispatch_trailer1_einv_vehicle_id_fkey FOREIGN KEY (trailer1_einv_vehicle_id) REFERENCES public.einv_vehicle(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_dispatch sls_dispatch_trailer2_einv_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch
    ADD CONSTRAINT sls_dispatch_trailer2_einv_vehicle_id_fkey FOREIGN KEY (trailer2_einv_vehicle_id) REFERENCES public.einv_vehicle(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice sls_invoice_acc_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice
    ADD CONSTRAINT sls_invoice_acc_account_id_fkey FOREIGN KEY (acc_account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice sls_invoice_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice
    ADD CONSTRAINT sls_invoice_currency_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice_detail sls_invoice_detail_buyer_einv_diib_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice_detail
    ADD CONSTRAINT sls_invoice_detail_buyer_einv_diib_line_id_fkey FOREIGN KEY (buyer_einv_diib_line_id) REFERENCES public.einv_diib_line(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice_detail sls_invoice_detail_dispatch_detail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice_detail
    ADD CONSTRAINT sls_invoice_detail_dispatch_detail_fkey FOREIGN KEY (sls_dispatch_detail_id) REFERENCES public.sls_dispatch_detail(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice_detail sls_invoice_detail_einv_gtip_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice_detail
    ADD CONSTRAINT sls_invoice_detail_einv_gtip_id_fkey FOREIGN KEY (einv_gtip_id) REFERENCES public.einv_gtip(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice_detail sls_invoice_detail_einv_packaging_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice_detail
    ADD CONSTRAINT sls_invoice_detail_einv_packaging_type_id_fkey FOREIGN KEY (einv_packaging_type_id) REFERENCES public.einv_packaging_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice_detail sls_invoice_detail_einv_withholding_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice_detail
    ADD CONSTRAINT sls_invoice_detail_einv_withholding_id_fkey FOREIGN KEY (einv_withholding_id) REFERENCES public.einv_withholding(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice_detail sls_invoice_detail_invoice_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice_detail
    ADD CONSTRAINT sls_invoice_detail_invoice_fkey FOREIGN KEY (sls_invoice_id) REFERENCES public.sls_invoice(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sls_invoice_detail sls_invoice_detail_order_detail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice_detail
    ADD CONSTRAINT sls_invoice_detail_order_detail_fkey FOREIGN KEY (sls_order_detail_id) REFERENCES public.sls_order_detail(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice_detail sls_invoice_detail_seller_einv_diib_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice_detail
    ADD CONSTRAINT sls_invoice_detail_seller_einv_diib_line_id_fkey FOREIGN KEY (seller_einv_diib_line_id) REFERENCES public.einv_diib_line(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice_detail sls_invoice_detail_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice_detail
    ADD CONSTRAINT sls_invoice_detail_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice sls_invoice_einv_delivery_term_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice
    ADD CONSTRAINT sls_invoice_einv_delivery_term_id_fkey FOREIGN KEY (einv_delivery_term_id) REFERENCES public.einv_delivery_term(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice sls_invoice_einv_invoice_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice
    ADD CONSTRAINT sls_invoice_einv_invoice_type_id_fkey FOREIGN KEY (einv_invoice_type_id) REFERENCES public.einv_invoice_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice sls_invoice_einv_payment_means_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice
    ADD CONSTRAINT sls_invoice_einv_payment_means_id_fkey FOREIGN KEY (einv_payment_means_id) REFERENCES public.einv_payment_means(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice sls_invoice_einv_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice
    ADD CONSTRAINT sls_invoice_einv_profile_id_fkey FOREIGN KEY (einv_profile_id) REFERENCES public.einv_profile(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice sls_invoice_einv_tax_exemption_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice
    ADD CONSTRAINT sls_invoice_einv_tax_exemption_id_fkey FOREIGN KEY (einv_tax_exemption_id) REFERENCES public.einv_tax_exemption(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice sls_invoice_einv_transport_mode_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice
    ADD CONSTRAINT sls_invoice_einv_transport_mode_id_fkey FOREIGN KEY (einv_transport_mode_id) REFERENCES public.einv_transport_mode(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice sls_invoice_stk_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice
    ADD CONSTRAINT sls_invoice_stk_warehouse_id_fkey FOREIGN KEY (stk_warehouse_id) REFERENCES public.stk_warehouse(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice_tax_summary sls_invoice_tax_summary_header_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice_tax_summary
    ADD CONSTRAINT sls_invoice_tax_summary_header_fkey FOREIGN KEY (sls_invoice_id) REFERENCES public.sls_invoice(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sls_invoice_tax_summary sls_invoice_tax_summary_withholding_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice_tax_summary
    ADD CONSTRAINT sls_invoice_tax_summary_withholding_fkey FOREIGN KEY (einv_withholding_id) REFERENCES public.einv_withholding(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_acc_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_acc_account_id_fkey FOREIGN KEY (acc_account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_base_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_base_currency_fkey FOREIGN KEY (base_currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_billing_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_billing_address_id_fkey FOREIGN KEY (billing_address_id) REFERENCES public.acc_account_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sls_offer sls_offer_billing_sys_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_billing_sys_address_id_fkey FOREIGN KEY (billing_sys_address_id) REFERENCES public.sys_address(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_currency_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer_detail sls_offer_detail_offer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer_detail
    ADD CONSTRAINT sls_offer_detail_offer_fkey FOREIGN KEY (sls_offer_id) REFERENCES public.sls_offer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sls_offer_detail sls_offer_detail_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer_detail
    ADD CONSTRAINT sls_offer_detail_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_einv_delivery_term_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_einv_delivery_term_id_fkey FOREIGN KEY (einv_delivery_term_id) REFERENCES public.einv_delivery_term(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_einv_payment_means_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_einv_payment_means_id_fkey FOREIGN KEY (einv_payment_means_id) REFERENCES public.einv_payment_means(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_emp_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_emp_employee_id_fkey FOREIGN KEY (emp_employee_id) REFERENCES public.emp_employee(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_shipping_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_shipping_address_id_fkey FOREIGN KEY (shipping_address_id) REFERENCES public.acc_account_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sls_offer sls_offer_shipping_sys_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_shipping_sys_address_id_fkey FOREIGN KEY (shipping_sys_address_id) REFERENCES public.sys_address(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer_tax_summary sls_offer_tax_summary_header_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer_tax_summary
    ADD CONSTRAINT sls_offer_tax_summary_header_fkey FOREIGN KEY (sls_offer_id) REFERENCES public.sls_offer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sls_offer_tax_summary sls_offer_tax_summary_withholding_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer_tax_summary
    ADD CONSTRAINT sls_offer_tax_summary_withholding_fkey FOREIGN KEY (einv_withholding_id) REFERENCES public.einv_withholding(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_acc_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_acc_account_id_fkey FOREIGN KEY (acc_account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_currency_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order_detail sls_order_detail_offer_detail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order_detail
    ADD CONSTRAINT sls_order_detail_offer_detail_fkey FOREIGN KEY (sls_offer_detail_id) REFERENCES public.sls_offer_detail(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sls_order_detail sls_order_detail_order_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order_detail
    ADD CONSTRAINT sls_order_detail_order_fkey FOREIGN KEY (sls_order_id) REFERENCES public.sls_order(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sls_order_detail sls_order_detail_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order_detail
    ADD CONSTRAINT sls_order_detail_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_emp_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_emp_employee_id_fkey FOREIGN KEY (emp_employee_id) REFERENCES public.emp_employee(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_stk_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_stk_warehouse_id_fkey FOREIGN KEY (stk_warehouse_id) REFERENCES public.stk_warehouse(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order_tax_summary sls_order_tax_summary_header_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order_tax_summary
    ADD CONSTRAINT sls_order_tax_summary_header_fkey FOREIGN KEY (sls_order_id) REFERENCES public.sls_order(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sls_order_tax_summary sls_order_tax_summary_withholding_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order_tax_summary
    ADD CONSTRAINT sls_order_tax_summary_withholding_fkey FOREIGN KEY (einv_withholding_id) REFERENCES public.einv_withholding(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_card_kind_info stk_card_kind_info_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_card_kind_info
    ADD CONSTRAINT stk_card_kind_info_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: stk_card_kind_info stk_card_kind_info_stk_kind_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_card_kind_info
    ADD CONSTRAINT stk_card_kind_info_stk_kind_property_id_fkey FOREIGN KEY (stk_kind_property_id) REFERENCES public.stk_kind_property(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_group stk_group_raw_material_stock_account_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_group
    ADD CONSTRAINT stk_group_raw_material_stock_account_fkey FOREIGN KEY (raw_material_stock_account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_group stk_group_raw_material_usage_account_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_group
    ADD CONSTRAINT stk_group_raw_material_usage_account_fkey FOREIGN KEY (raw_material_usage_account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_group stk_group_semi_product_account_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_group
    ADD CONSTRAINT stk_group_semi_product_account_fkey FOREIGN KEY (semi_product_account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_group stk_group_vat_rate_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_group
    ADD CONSTRAINT stk_group_vat_rate_fkey FOREIGN KEY (vat_rate) REFERENCES public.acc_set_tax_rate(tax_rate) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_image stk_image_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_image
    ADD CONSTRAINT stk_image_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: stk_inventory stk_inventory_buying_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_buying_currency_fkey FOREIGN KEY (buying_currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_einv_gtip_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_einv_gtip_id_fkey FOREIGN KEY (einv_gtip_id) REFERENCES public.einv_gtip(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_export_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_export_currency_fkey FOREIGN KEY (export_currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_purchase_account_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_purchase_account_fkey FOREIGN KEY (purchase_account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_purchase_return_account_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_purchase_return_account_fkey FOREIGN KEY (purchase_return_account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_raw_material_stock_account_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_raw_material_stock_account_fkey FOREIGN KEY (raw_material_stock_account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_raw_material_usage_account_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_raw_material_usage_account_fkey FOREIGN KEY (raw_material_usage_account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_sales_account_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_sales_account_fkey FOREIGN KEY (sales_account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_sales_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_sales_currency_fkey FOREIGN KEY (sales_currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_sales_return_account_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_sales_return_account_fkey FOREIGN KEY (sales_return_account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_semi_product_account_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_semi_product_account_fkey FOREIGN KEY (semi_product_account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_stk_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_stk_group_id_fkey FOREIGN KEY (stk_group_id) REFERENCES public.stk_group(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_stk_product_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_stk_product_type_id_fkey FOREIGN KEY (stk_product_type_id) REFERENCES public.stk_product_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory_summary stk_inventory_summary_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory_summary
    ADD CONSTRAINT stk_inventory_summary_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: stk_inventory stk_inventory_sys_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_sys_country_id_fkey FOREIGN KEY (sys_country_id) REFERENCES public.sys_country(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_sys_uom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_sys_uom_id_fkey FOREIGN KEY (sys_uom_id) REFERENCES public.sys_uom(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_vat_rate_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_vat_rate_fkey FOREIGN KEY (vat_rate) REFERENCES public.acc_set_tax_rate(tax_rate) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_kind_property stk_kind_property_stk_kind_family_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kind_property
    ADD CONSTRAINT stk_kind_property_stk_kind_family_id_fkey FOREIGN KEY (stk_kind_family_id) REFERENCES public.stk_kind_family(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_transaction stk_transaction_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_currency_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_transaction stk_transaction_from_stk_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_from_stk_warehouse_id_fkey FOREIGN KEY (from_stk_warehouse_id) REFERENCES public.stk_warehouse(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_transaction stk_transaction_pur_receipt_detail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_pur_receipt_detail_fkey FOREIGN KEY (pur_receipt_detail_id) REFERENCES public.pur_receipt_detail(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: stk_transaction stk_transaction_qc_inspection_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_qc_inspection_fkey FOREIGN KEY (qc_inspection_id) REFERENCES public.qc_inspection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: stk_transaction stk_transaction_sls_dispatch_detail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_sls_dispatch_detail_fkey FOREIGN KEY (sls_dispatch_detail_id) REFERENCES public.sls_dispatch_detail(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: stk_transaction stk_transaction_sls_invoice_detail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_sls_invoice_detail_fkey FOREIGN KEY (sls_invoice_detail_id) REFERENCES public.sls_invoice_detail(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: stk_transaction stk_transaction_stk_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_stk_inventory_id_fkey FOREIGN KEY (stk_inventory_id) REFERENCES public.stk_inventory(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_transaction stk_transaction_to_stk_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_to_stk_warehouse_id_fkey FOREIGN KEY (to_stk_warehouse_id) REFERENCES public.stk_warehouse(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sys_access_right sys_access_right_sys_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_access_right
    ADD CONSTRAINT sys_access_right_sys_permission_id_fkey FOREIGN KEY (sys_permission_id) REFERENCES public.sys_permission(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_access_right sys_access_right_sys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_access_right
    ADD CONSTRAINT sys_access_right_sys_user_id_fkey FOREIGN KEY (sys_user_id) REFERENCES public.sys_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_address sys_address_sys_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_address
    ADD CONSTRAINT sys_address_sys_city_id_fkey FOREIGN KEY (sys_city_id) REFERENCES public.sys_city(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sys_api_service sys_api_service_sys_application_setting_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_api_service
    ADD CONSTRAINT sys_api_service_sys_application_setting_id_fkey FOREIGN KEY (sys_application_setting_id) REFERENCES public.sys_application_setting(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_application_setting sys_application_setting_app_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_application_setting
    ADD CONSTRAINT sys_application_setting_app_currency_fkey FOREIGN KEY (app_currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sys_application_setting sys_application_setting_sys_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_application_setting
    ADD CONSTRAINT sys_application_setting_sys_address_id_fkey FOREIGN KEY (sys_address_id) REFERENCES public.sys_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sys_city sys_city_sys_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_city
    ADD CONSTRAINT sys_city_sys_country_id_fkey FOREIGN KEY (sys_country_id) REFERENCES public.sys_country(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sys_city sys_city_sys_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_city
    ADD CONSTRAINT sys_city_sys_region_id_fkey FOREIGN KEY (sys_region_id) REFERENCES public.sys_region(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sys_country_translation sys_country_translation_sys_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_country_translation
    ADD CONSTRAINT sys_country_translation_sys_country_id_fkey FOREIGN KEY (sys_country_id) REFERENCES public.sys_country(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_country_translation sys_country_translation_sys_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_country_translation
    ADD CONSTRAINT sys_country_translation_sys_language_id_fkey FOREIGN KEY (sys_language_id) REFERENCES public.sys_language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_menu sys_menu_parent_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_menu
    ADD CONSTRAINT sys_menu_parent_code_fkey FOREIGN KEY (parent_code) REFERENCES public.sys_menu(menu_code);


--
-- Name: sys_menu sys_menu_sys_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_menu
    ADD CONSTRAINT sys_menu_sys_permission_id_fkey FOREIGN KEY (sys_permission_id) REFERENCES public.sys_permission(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sys_menu_translation sys_menu_translation_sys_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_menu_translation
    ADD CONSTRAINT sys_menu_translation_sys_language_id_fkey FOREIGN KEY (sys_language_id) REFERENCES public.sys_language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_menu_translation sys_menu_translation_sys_menu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_menu_translation
    ADD CONSTRAINT sys_menu_translation_sys_menu_id_fkey FOREIGN KEY (sys_menu_id) REFERENCES public.sys_menu(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_permission_group_translation sys_permission_group_translation_sys_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_group_translation
    ADD CONSTRAINT sys_permission_group_translation_sys_language_id_fkey FOREIGN KEY (sys_language_id) REFERENCES public.sys_language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_permission_group_translation sys_permission_group_translation_sys_permission_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_group_translation
    ADD CONSTRAINT sys_permission_group_translation_sys_permission_group_id_fkey FOREIGN KEY (sys_permission_group_id) REFERENCES public.sys_permission_group(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_permission sys_permission_sys_permission_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission
    ADD CONSTRAINT sys_permission_sys_permission_group_id_fkey FOREIGN KEY (sys_permission_group_id) REFERENCES public.sys_permission_group(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_permission_template_right sys_permission_template_right_permission_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_template_right
    ADD CONSTRAINT sys_permission_template_right_permission_fk FOREIGN KEY (sys_permission_id) REFERENCES public.sys_permission(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_permission_template_right sys_permission_template_right_template_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_template_right
    ADD CONSTRAINT sys_permission_template_right_template_fk FOREIGN KEY (sys_permission_template_id) REFERENCES public.sys_permission_template(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_permission_translation sys_permission_translation_sys_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_translation
    ADD CONSTRAINT sys_permission_translation_sys_language_id_fkey FOREIGN KEY (sys_language_id) REFERENCES public.sys_language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_permission_translation sys_permission_translation_sys_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_translation
    ADD CONSTRAINT sys_permission_translation_sys_permission_id_fkey FOREIGN KEY (sys_permission_id) REFERENCES public.sys_permission(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_uom_group_translation sys_uom_group_translation_sys_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_uom_group_translation
    ADD CONSTRAINT sys_uom_group_translation_sys_language_id_fkey FOREIGN KEY (sys_language_id) REFERENCES public.sys_language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_uom_group_translation sys_uom_group_translation_sys_uom_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_uom_group_translation
    ADD CONSTRAINT sys_uom_group_translation_sys_uom_group_id_fkey FOREIGN KEY (sys_uom_group_id) REFERENCES public.sys_uom_group(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_uom sys_uom_sys_uom_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_uom
    ADD CONSTRAINT sys_uom_sys_uom_group_id_fkey FOREIGN KEY (sys_uom_group_id) REFERENCES public.sys_uom_group(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sys_uom_translation sys_uom_translation_sys_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_uom_translation
    ADD CONSTRAINT sys_uom_translation_sys_language_id_fkey FOREIGN KEY (sys_language_id) REFERENCES public.sys_language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_uom_translation sys_uom_translation_sys_uom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_uom_translation
    ADD CONSTRAINT sys_uom_translation_sys_uom_id_fkey FOREIGN KEY (sys_uom_id) REFERENCES public.sys_uom(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_user sys_user_emp_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_user_emp_employee_id_fkey FOREIGN KEY (emp_employee_id) REFERENCES public.emp_employee(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sys_user_menu sys_user_menu_sys_menu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_user_menu
    ADD CONSTRAINT sys_user_menu_sys_menu_id_fkey FOREIGN KEY (sys_menu_id) REFERENCES public.sys_menu(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_user_menu sys_user_menu_sys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_user_menu
    ADD CONSTRAINT sys_user_menu_sys_user_id_fkey FOREIGN KEY (sys_user_id) REFERENCES public.sys_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_user_permission_template sys_user_permission_template_template_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_user_permission_template
    ADD CONSTRAINT sys_user_permission_template_template_fk FOREIGN KEY (sys_permission_template_id) REFERENCES public.sys_permission_template(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_user_permission_template sys_user_permission_template_user_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_user_permission_template
    ADD CONSTRAINT sys_user_permission_template_user_fk FOREIGN KEY (sys_user_id) REFERENCES public.sys_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_user_setting sys_user_setting_sys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_user_setting
    ADD CONSTRAINT sys_user_setting_sys_user_id_fkey FOREIGN KEY (sys_user_id) REFERENCES public.sys_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA audit_remote; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA audit_remote TO ths_admin;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT CREATE ON SCHEMA public TO PUBLIC;
GRANT ALL ON SCHEMA public TO ths_admin;


--
-- Name: FUNCTION audit(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.audit() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.audit() FROM postgres;


--
-- Name: FUNCTION audit_configure(p_host text, p_port integer, p_dbname text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.audit_configure(p_host text, p_port integer, p_dbname text) FROM PUBLIC;


--
-- Name: FUNCTION fn_default_currency(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_default_currency() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_default_currency() TO ths_admin;


--
-- Name: FUNCTION fn_get_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_get_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_get_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) TO ths_admin;


--
-- Name: FUNCTION fn_get_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_get_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_get_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) TO ths_admin;


--
-- Name: FUNCTION fn_get_rct_hammadde_maliyet(prct_recete_id bigint); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_get_rct_hammadde_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_get_rct_hammadde_maliyet(prct_recete_id bigint) TO ths_admin;


--
-- Name: FUNCTION fn_get_rct_iscilik_maliyet(prct_recete_id bigint); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_get_rct_iscilik_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_get_rct_iscilik_maliyet(prct_recete_id bigint) TO ths_admin;


--
-- Name: FUNCTION fn_get_rct_toplam(prct_recete_id bigint); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_get_rct_toplam(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_get_rct_toplam(prct_recete_id bigint) TO ths_admin;


--
-- Name: FUNCTION fn_get_rct_yan_urun_maliyet(prct_recete_id bigint); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_get_rct_yan_urun_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_get_rct_yan_urun_maliyet(prct_recete_id bigint) TO ths_admin;


--
-- Name: FUNCTION fn_get_sys_lang_id(planguage text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_get_sys_lang_id(planguage text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_get_sys_lang_id(planguage text) TO ths_admin;


--
-- Name: FUNCTION fn_get_sys_quality_form_type_id(ptype integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_get_sys_quality_form_type_id(ptype integer) TO ths_admin;


--
-- Name: FUNCTION personel_adsoyad(); Type: ACL; Schema: public; Owner: ths_admin
--

REVOKE ALL ON FUNCTION public.personel_adsoyad() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.personel_adsoyad() FROM ths_admin;


--
-- Name: FUNCTION table_listen(table_name text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.table_listen(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_listen(table_name text) TO ths_admin;


--
-- Name: FUNCTION table_notify(); Type: ACL; Schema: public; Owner: ths_admin
--

REVOKE ALL ON FUNCTION public.table_notify() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.table_notify() FROM ths_admin;


--
-- Name: FUNCTION table_notify(table_name text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.table_notify(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_notify(table_name text) TO ths_admin;


--
-- Name: FUNCTION table_unlisten(table_name text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.table_unlisten(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_unlisten(table_name text) TO ths_admin;


--
-- Name: TABLE audit_database; Type: ACL; Schema: audit_remote; Owner: postgres
--

GRANT SELECT ON TABLE audit_remote.audit_database TO ths_admin;


--
-- Name: TABLE audit_log; Type: ACL; Schema: audit_remote; Owner: postgres
--

GRANT SELECT ON TABLE audit_remote.audit_log TO ths_admin;


--
-- Name: TABLE vw_einv_diib_line; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.vw_einv_diib_line TO ths_admin;


--
-- PostgreSQL database dump complete
--

\unrestrict FJnOQd8j0XCm8SYapnxYrFH3wAbwIHsdkhOC5PWTfyU04tfuY7Ak66qL7Oqgdog

