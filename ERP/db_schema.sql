--
-- PostgreSQL database dump
--

\restrict fbJG9nzdeniDmL0d7I71HUFcQxZPsu9ZyZcljTyLIwBiHyjX7chjfg4dHO321a2

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

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
-- Name: dblink; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;


--
-- Name: EXTENSION dblink; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';


--
-- Name: audit(); Type: FUNCTION; Schema: public; Owner: ths_admin
--

CREATE FUNCTION public.audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
_username text;
_client_user text;
_ip text;
_database text;
_log_database text;
_sql text;
_old_val text;
_new_val text;
_id text;
_operatin text;
_tarih timestamp without time zone;
BEGIN
	IF (TG_OP = 'INSERT') OR (TG_OP = 'DELETE') OR ((TG_OP = 'UPDATE') AND (ARRAY[OLD] <> ARRAY[NEW])) THEN
		_username 	:= session_user; 
		_ip 		:= (inet_client_addr());
		_database	:= (SELECT current_database());
		_tarih		:= (SELECT NOW());

		_log_database := _database || '_log';
		
		IF (TG_OP = 'INSERT') THEN
			_old_val	:= null;
			_new_val	:= row_to_json(NEW);
			_id := NEW.id;
			_operatin := 'I';
		ELSE
			_old_val	:= row_to_json(OLD);
			_new_val	:= row_to_json(NEW);
			_id := OLD.id;
			IF (TG_OP = 'UPDATE') THEN
				_operatin := 'U';
			ELSE
				_operatin := 'D';
			END IF;
		END IF;

		SELECT current_setting('ths_erp.user_name') INTO _client_user;

		_sql := 
		(SELECT format('INSERT INTO public.audits(
			user_name, ip_address, table_name, access_type, time_of_change, row_id, client_username, old_val, new_val)
		VALUES (%L, %L, %L, %L, %L, %L, %L, %L, %L);', 
			_username, _ip, TG_TABLE_NAME, _operatin, _tarih, _id, _client_user, _old_val, _new_val));
		
		EXECUTE _sql;
	END IF;
	RETURN NULL;
END
$$;


ALTER FUNCTION public.audit() OWNER TO ths_admin;

--
-- Name: fn_default_currency(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_default_currency() RETURNS character varying
    LANGUAGE sql
    AS $$
	SELECT para_birimi FROM sys_para_birimi WHERE is_varsayilan LIMIT 1;
$$;


ALTER FUNCTION public.fn_default_currency() OWNER TO postgres;

--
-- Name: fn_default_product_type_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_default_product_type_id() RETURNS integer
    LANGUAGE sql
    AS $$ SELECT id FROM stk_product_type WHERE product_type_name='HAMMADDE'; $$;


ALTER FUNCTION public.fn_default_product_type_id() OWNER TO postgres;

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: acc_account; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_account (
    id bigint CONSTRAINT acc_acc_id_nn NOT NULL,
    code character varying(16) CONSTRAINT acc_acc_code_nn NOT NULL,
    name character varying(128) CONSTRAINT acc_acc_name_nn NOT NULL,
    type_id bigint CONSTRAINT acc_acc_type_nn NOT NULL,
    group_id bigint,
    region_id bigint,
    iban character varying(64),
    iban_currency character varying(3),
    notes character varying(512),
    root_code character varying(3),
    sub_code character varying(8),
    discount_rate numeric(5,2) DEFAULT 0,
    e_invoice_active boolean DEFAULT false CONSTRAINT acc_acc_einv_nn NOT NULL,
    e_invoice_package_name character varying(128),
    is_passive boolean DEFAULT false CONSTRAINT acc_acc_passive_nn NOT NULL
);


ALTER TABLE public.acc_account OWNER TO ths_admin;

--
-- Name: acc_account_address; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_account_address (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    address_id bigint NOT NULL,
    address_type character varying(16) NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    valid_from date,
    valid_to date
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
    account_id bigint NOT NULL,
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
    account_id bigint NOT NULL,
    taxpayer_type smallint,
    taxpayer_name character varying(32),
    taxpayer_name2 character varying(32),
    taxpayer_surname character varying(32),
    tax_office character varying(64),
    tax_no character varying(32),
    nace_code character varying(32)
);


ALTER TABLE public.acc_account_taxpayer OWNER TO ths_admin;

--
-- Name: acc_bank; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_bank (
    id bigint CONSTRAINT acc_bank_id_nn NOT NULL,
    name character varying(64) CONSTRAINT acc_bank_name_nn NOT NULL,
    swift_code character varying(16)
);


ALTER TABLE public.acc_bank OWNER TO ths_admin;

--
-- Name: acc_bank_branch; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_bank_branch (
    id bigint CONSTRAINT acc_branch_id_nn NOT NULL,
    bank_id bigint CONSTRAINT acc_branch_bank_nn NOT NULL,
    code integer CONSTRAINT acc_branch_code_nn NOT NULL,
    name character varying(64) CONSTRAINT acc_branch_name_nn NOT NULL,
    city_id bigint CONSTRAINT acc_branch_city_nn NOT NULL
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
    rate numeric(10,4) CONSTRAINT acc_er_rate_nn NOT NULL,
    currency character varying(3)
);


ALTER TABLE public.acc_exchange_rate OWNER TO ths_admin;

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
    name character varying(16) CONSTRAINT acc_set_at_name_nn NOT NULL
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
    name character varying(16) NOT NULL
);


ALTER TABLE public.acc_set_account_type_translation OWNER TO ths_admin;

--
-- Name: acc_set_company_legal_form; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_set_company_legal_form (
    id bigint CONSTRAINT acc_clf_id_nn NOT NULL,
    ownership_id bigint CONSTRAINT acc_clf_own_nn NOT NULL,
    name character varying(48) CONSTRAINT acc_clf_name_nn NOT NULL
);


ALTER TABLE public.acc_set_company_legal_form OWNER TO ths_admin;

--
-- Name: acc_set_company_legal_form_translation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_set_company_legal_form_translation (
    acc_set_company_legal_form_id bigint CONSTRAINT acc_set_company_legal_form__acc_set_company_legal_form_not_null NOT NULL,
    sys_language_id bigint NOT NULL,
    name character varying(48) NOT NULL
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
    name character varying(32) CONSTRAINT acc_otn_name_nn NOT NULL
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
    name character varying(32) NOT NULL
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
    journal_date date
);


ALTER TABLE public.acc_voucher OWNER TO ths_admin;

--
-- Name: acc_voucher_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_voucher_detail (
    id bigint CONSTRAINT mhs_fis_detaylari_id_not_null NOT NULL,
    header_id bigint CONSTRAINT mhs_fis_detaylari_header_id_not_null NOT NULL
);


ALTER TABLE public.acc_voucher_detail OWNER TO ths_admin;

--
-- Name: audits; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.audits (
    id bigint NOT NULL,
    user_name character varying NOT NULL,
    ip_address character varying(32) NOT NULL,
    table_name character varying NOT NULL,
    access_type character varying(1) NOT NULL,
    time_of_change timestamp without time zone NOT NULL,
    row_id bigint NOT NULL,
    client_username character varying,
    old_val text,
    new_val text
);


ALTER TABLE public.audits OWNER TO ths_admin;

--
-- Name: audit_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.audits ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einv_delivery_type; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_delivery_type (
    id bigint CONSTRAINT einv_delivery_type_id_nn NOT NULL,
    delivery_method character varying(16) CONSTRAINT einv_delivery_type_delivery_code_nn NOT NULL,
    description character varying(96) CONSTRAINT einv_delivery_type_description_nn NOT NULL,
    is_efatura boolean DEFAULT false
);


ALTER TABLE public.einv_delivery_type OWNER TO ths_admin;

--
-- Name: einv_delivery_type_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_delivery_type ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_delivery_type_id_seq
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
    invoice_type_code character varying(32) CONSTRAINT set_einv_fatura_tipleri_fatura_tipi_not_null NOT NULL
);


ALTER TABLE public.einv_invoice_type OWNER TO ths_admin;

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
-- Name: einv_packet_type; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.einv_packet_type (
    id bigint CONSTRAINT set_einv_paket_tipleri_id_not_null NOT NULL,
    code character varying(2),
    packet_type_code character varying(128),
    description character varying(512)
);


ALTER TABLE public.einv_packet_type OWNER TO ths_admin;

--
-- Name: einv_packet_type_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.einv_packet_type ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einv_packet_type_id_seq
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
-- Name: emp_driver_ability; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_driver_ability (
    id bigint CONSTRAINT prs_driver_abilities_id_not_null NOT NULL,
    driver_license_id bigint,
    person_id bigint
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
-- Name: emp_language; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_language (
    id bigint CONSTRAINT prs_set_lng_id_nn NOT NULL,
    language_name character varying(16) CONSTRAINT prs_set_lng_nname_nn NOT NULL
);


ALTER TABLE public.emp_language OWNER TO ths_admin;

--
-- Name: emp_language_level; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_language_level (
    id bigint CONSTRAINT prs_set_lll_id_nn NOT NULL,
    language_level character varying(16) CONSTRAINT prs_set_lll_lname_nn NOT NULL
);


ALTER TABLE public.emp_language_level OWNER TO ths_admin;

--
-- Name: emp_person; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_person (
    id bigint CONSTRAINT prs_persons_id_not_null NOT NULL,
    name character varying(32) CONSTRAINT prs_persons_name_not_null NOT NULL,
    surname character varying(32) CONSTRAINT prs_persons_surname_not_null NOT NULL,
    full_name character varying(64) CONSTRAINT prs_persons_full_name_not_null NOT NULL,
    phone1 character varying(24),
    phone2 character varying(24),
    person_type_id bigint CONSTRAINT prs_persons_person_type_id_not_null NOT NULL,
    unit_id bigint CONSTRAINT prs_persons_unit_id_not_null NOT NULL,
    task_id bigint CONSTRAINT prs_persons_task_id_not_null NOT NULL,
    birth_date date,
    blood_type character varying(8),
    gender smallint CONSTRAINT prs_persons_gender_not_null NOT NULL,
    military_status smallint,
    marital_status smallint CONSTRAINT prs_persons_marital_status_not_null NOT NULL,
    child smallint DEFAULT 0,
    relative_name character varying(48),
    relative_phone character varying(24),
    shoe_size smallint,
    clothing_size character varying(8),
    notes character varying(256),
    transportation_id bigint,
    special_notes character varying(256),
    salary_amount numeric(18,2) DEFAULT 0,
    bonus_count integer DEFAULT 0,
    bonus_amount numeric(18,2) DEFAULT 0,
    id_document_no text,
    active boolean DEFAULT false CONSTRAINT prs_persons_active_not_null NOT NULL
);


ALTER TABLE public.emp_person OWNER TO ths_admin;

--
-- Name: COLUMN emp_person.gender; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.emp_person.gender IS '1 Man, 2 Woman';


--
-- Name: COLUMN emp_person.military_status; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.emp_person.military_status IS '1 Did, 2 Exempt, 3 Did Not';


--
-- Name: COLUMN emp_person.marital_status; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.emp_person.marital_status IS '1 Married, 2 Single';


--
-- Name: emp_person_address; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_person_address (
    id bigint NOT NULL,
    person_id bigint NOT NULL,
    address_id bigint NOT NULL,
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
    language_id bigint,
    read_id bigint,
    write_id bigint,
    speak_id bigint,
    person_id bigint
);


ALTER TABLE public.emp_person_language_ability OWNER TO ths_admin;

--
-- Name: emp_person_type; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_person_type (
    id bigint CONSTRAINT prs_set_ptp_id_nn NOT NULL,
    person_type character varying(32) CONSTRAINT prs_set_ptp_pname_nn NOT NULL
);


ALTER TABLE public.emp_person_type OWNER TO ths_admin;

--
-- Name: emp_person_type_translation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_person_type_translation (
    emp_person_type_id bigint NOT NULL,
    sys_language_id bigint NOT NULL,
    person_type character varying(64) NOT NULL
);


ALTER TABLE public.emp_person_type_translation OWNER TO ths_admin;

--
-- Name: emp_section; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_section (
    id bigint CONSTRAINT prs_set_sec_id_nn NOT NULL,
    section_name character varying(32) CONSTRAINT prs_set_sec_nname_nn NOT NULL
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
    task_name character varying(32) CONSTRAINT prs_set_tsk_nname_nn NOT NULL
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
    route double precision[]
);


ALTER TABLE public.emp_transportation OWNER TO ths_admin;

--
-- Name: emp_unit; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.emp_unit (
    id bigint CONSTRAINT prs_set_unit_id_nn NOT NULL,
    unit_name character varying(32) CONSTRAINT prs_set_unit_nname_nn NOT NULL,
    section_id bigint
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
    id bigint CONSTRAINT prd_bom_id_nn NOT NULL,
    product_sku character varying(32) CONSTRAINT prd_bom_product_sku_nn NOT NULL,
    product_name character varying(128) CONSTRAINT prd_bom_product_name_nn NOT NULL,
    sample_quantity numeric(18,6) DEFAULT 1,
    description character varying(128)
);


ALTER TABLE public.prd_bom OWNER TO ths_admin;

--
-- Name: prd_bom_by_product; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_bom_by_product (
    id bigint CONSTRAINT prd_bom_by_product_id_nn NOT NULL,
    header_id bigint CONSTRAINT prd_bom_by_product_header_nn NOT NULL,
    product_sku character varying(32) CONSTRAINT prd_bom_by_product_sku_nn NOT NULL,
    quantity numeric(18,6) CONSTRAINT prd_bom_by_product_qty_nn NOT NULL
);


ALTER TABLE public.prd_bom_by_product OWNER TO ths_admin;

--
-- Name: prd_bom_labour; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_bom_labour (
    id bigint CONSTRAINT prd_bom_labour_id_nn NOT NULL,
    header_id bigint CONSTRAINT prd_bom_labour_header_nn NOT NULL,
    labor_code character varying(16) CONSTRAINT prd_bom_labour_labor_code_nn NOT NULL,
    quantity numeric(18,6) CONSTRAINT prd_bom_labour_qty_nn NOT NULL
);


ALTER TABLE public.prd_bom_labour OWNER TO ths_admin;

--
-- Name: prd_bom_packet_labour; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_bom_packet_labour (
    id bigint CONSTRAINT prd_bom_packet_labour_id_nn NOT NULL,
    header_id bigint CONSTRAINT prd_bom_packet_labour_header_nn NOT NULL,
    paket_id bigint CONSTRAINT urt_recete_paket_iscilikler_paket_id_not_null NOT NULL,
    quantity numeric(18,6)
);


ALTER TABLE public.prd_bom_packet_labour OWNER TO ths_admin;

--
-- Name: prd_bom_packet_raw; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_bom_packet_raw (
    id bigint CONSTRAINT prd_bom_packet_raw_id_nn NOT NULL,
    header_id bigint CONSTRAINT prd_bom_packet_raw_header_nn NOT NULL,
    paket_id bigint CONSTRAINT urt_recete_paket_hammaddeler_paket_id_not_null NOT NULL,
    quantity numeric(18,6)
);


ALTER TABLE public.prd_bom_packet_raw OWNER TO ths_admin;

--
-- Name: prd_bom_raw; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_bom_raw (
    id bigint CONSTRAINT prd_bom_raw_id_nn NOT NULL,
    header_id bigint CONSTRAINT prd_bom_raw_header_nn NOT NULL,
    recete_id bigint,
    stok_kodu character varying(32) CONSTRAINT prd_bom_raw_sku_nn NOT NULL,
    quantity numeric(18,6) CONSTRAINT prd_bom_raw_qty_nn NOT NULL,
    scrap_rate numeric(18,6) DEFAULT 0 CONSTRAINT prd_bom_raw_scrap_rate_nn NOT NULL
);


ALTER TABLE public.prd_bom_raw OWNER TO ths_admin;

--
-- Name: prd_labour; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_labour (
    id bigint CONSTRAINT prd_labour_id_nn NOT NULL,
    cost_code character varying(16) CONSTRAINT prd_labour_cost_code_nn NOT NULL,
    cost_name character varying(128),
    unit_price numeric(18,6) CONSTRAINT prd_labour_price_nn NOT NULL,
    uom_code character varying(8) CONSTRAINT prd_labour_unit_nn NOT NULL,
    cost_type smallint CONSTRAINT prd_labour_cost_type_nn NOT NULL
);


ALTER TABLE public.prd_labour OWNER TO ths_admin;

--
-- Name: prd_packet_labour; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_packet_labour (
    id bigint CONSTRAINT prd_packet_labour_id_nn NOT NULL,
    package_name character varying(128) CONSTRAINT prd_packet_labour_package_name_nn NOT NULL
);


ALTER TABLE public.prd_packet_labour OWNER TO ths_admin;

--
-- Name: prd_packet_labour_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_packet_labour_detail (
    id bigint CONSTRAINT prd_packet_labour_detail_id_nn NOT NULL,
    header_id bigint CONSTRAINT prd_packet_labour_detail_header_nn NOT NULL,
    labor_code character varying(32) CONSTRAINT prd_packet_labour_detail_labor_code_nn NOT NULL,
    quantity numeric(18,6) CONSTRAINT prd_packet_labour_detail_qty_nn NOT NULL
);


ALTER TABLE public.prd_packet_labour_detail OWNER TO ths_admin;

--
-- Name: prd_packet_raw; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_packet_raw (
    id bigint CONSTRAINT urt_paket_hammaddeler_id_not_null NOT NULL,
    package_name character varying(128) CONSTRAINT urt_paket_hammaddeler_paket_adi_not_null NOT NULL
);


ALTER TABLE public.prd_packet_raw OWNER TO ths_admin;

--
-- Name: prd_packet_raw_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prd_packet_raw_detail (
    id bigint CONSTRAINT prd_packet_raw_detail_id_nn NOT NULL,
    header_id bigint CONSTRAINT prd_packet_raw_detail_header_nn NOT NULL,
    recete_id bigint,
    sku_code character varying(32) CONSTRAINT prd_packet_raw_detail_sku_nn NOT NULL,
    quantity numeric(18,6) CONSTRAINT prd_packet_raw_detail_qty_nn NOT NULL
);


ALTER TABLE public.prd_packet_raw_detail OWNER TO ths_admin;

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

ALTER TABLE public.emp_person ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_personel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prs_set_lang_level_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.emp_language_level ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_set_lang_level_id_seq
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
-- Name: pur_offer; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.pur_offer (
    id bigint CONSTRAINT als_teklifler_id_not_null NOT NULL,
    order_id bigint,
    irsaliye_id bigint,
    fatura_id bigint,
    is_confirmed boolean CONSTRAINT pur_offer_is_confirmed_nn NOT NULL,
    total_amount numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_total_amount_nn NOT NULL,
    discount_amount numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_discount_amount_nn NOT NULL,
    ara_toplam numeric(18,6) DEFAULT 0 CONSTRAINT als_teklifler_ara_toplam_not_null NOT NULL,
    tax_rate_1 integer DEFAULT 0 CONSTRAINT pur_offer_tax_rate_1_nn NOT NULL,
    tax_amount_1 numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_tax_amount_1_nn NOT NULL,
    tax_rate_2 integer DEFAULT 0 CONSTRAINT pur_offer_tax_rate_2_nn NOT NULL,
    tax_amount_2 numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_tax_amount_2_nn NOT NULL,
    tax_rate_3 integer DEFAULT 0 CONSTRAINT pur_offer_tax_rate_3_nn NOT NULL,
    tax_amount_3 numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_tax_amount_3_nn NOT NULL,
    tax_rate_4 integer DEFAULT 0 CONSTRAINT pur_offer_tax_rate_4_nn NOT NULL,
    tax_amount_4 numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_tax_amount_4_nn NOT NULL,
    tax_rate_5 integer DEFAULT 0 CONSTRAINT pur_offer_tax_rate_5_nn NOT NULL,
    tax_amount_5 numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_tax_amount_5_nn NOT NULL,
    genel_toplam numeric(18,6) DEFAULT 0 CONSTRAINT als_teklifler_genel_toplam_not_null NOT NULL,
    operation_type_id bigint,
    offer_number character varying(16) CONSTRAINT als_teklifler_teklif_no_not_null NOT NULL,
    offer_date date CONSTRAINT als_teklifler_teklif_tarihi_not_null NOT NULL,
    validity_date date CONSTRAINT als_teklifler_gecerlilik_tarihi_not_null NOT NULL,
    customer_code character varying(16),
    customer_name character varying(128),
    tax_office character varying(32) CONSTRAINT als_teklifler_vergi_dairesi_not_null NOT NULL,
    tax_number character varying(32) CONSTRAINT als_teklifler_vergi_no_not_null NOT NULL,
    country_id bigint,
    city_id bigint,
    district character varying(64),
    mahalle character varying(64),
    semt character varying(64),
    cadde character varying(64),
    sokak character varying(64),
    building_name character varying(64),
    door_number character varying(16),
    posta_kodu character varying(16),
    web character varying(64),
    email character varying(128),
    customer_representative character varying(64),
    contact_name character varying(32),
    contact_phone character varying(24),
    referans character varying(128),
    currency_code character varying(3) CONSTRAINT pur_offer_currency_code_nn NOT NULL,
    exchange_rate_usd numeric(7,4) DEFAULT 1,
    exchange_rate_eur numeric(7,4) DEFAULT 1,
    description character varying(128),
    withholding_code character varying(8),
    withholding_description character varying(128),
    withholding_share smallint,
    withholding_denominator smallint
);


ALTER TABLE public.pur_offer OWNER TO ths_admin;

--
-- Name: pur_offer_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.pur_offer_detail (
    id bigint CONSTRAINT als_teklif_detaylari_id_not_null NOT NULL,
    header_id bigint,
    order_detail_id bigint,
    delivery_note_detail_id bigint,
    invoice_detail_id bigint,
    sku_code character varying(32),
    stock_description character varying(128),
    user_description character varying(128),
    referans character varying(128),
    miktar double precision DEFAULT 1 CONSTRAINT als_teklif_detaylari_miktar_not_null NOT NULL,
    uom_code character varying(8),
    discount_rate numeric(6,3) DEFAULT 0,
    tax_rate integer DEFAULT 0,
    fiyat numeric(18,6) DEFAULT 0,
    net_fiyat numeric(18,6) DEFAULT 0 CONSTRAINT als_teklif_detaylari_net_fiyat_not_null NOT NULL,
    amount numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_detail_amount_nn NOT NULL,
    discount_amount numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_detail_discount_amount_nn NOT NULL,
    net_amount numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_detail_net_amount_nn NOT NULL,
    tax_amount numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_detail_tax_amount_nn NOT NULL,
    total_amount numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_detail_total_amount_nn NOT NULL,
    is_ana_urun boolean DEFAULT false CONSTRAINT als_teklif_detaylari_is_ana_urun_not_null NOT NULL,
    referans_ana_urun_id bigint,
    gtip_no character varying(16),
    mensei_ulke_adi character varying(128)
);


ALTER TABLE public.pur_offer_detail OWNER TO ths_admin;

--
-- Name: pur_offer_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

CREATE SEQUENCE public.pur_offer_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pur_offer_detail_id_seq OWNER TO ths_admin;

--
-- Name: pur_offer_detail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ths_admin
--

ALTER SEQUENCE public.pur_offer_detail_id_seq OWNED BY public.pur_offer_detail.id;


--
-- Name: pur_offer_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.pur_offer ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pur_offer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: rct_labor_cost_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_labour ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_labor_cost_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: rct_paket_hammadde_detay_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_packet_raw_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_hammadde_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: rct_paket_hammadde_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_packet_raw ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: rct_paket_iscilik_detay_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_packet_labour_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_iscilik_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: rct_paket_iscilik_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_packet_labour ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: rct_recete_hammadde_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_bom_raw ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: rct_recete_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_bom ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: rct_recete_iscilik_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_bom_labour ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: rct_recete_paket_hammadde_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_bom_packet_raw ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_paket_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: rct_recete_paket_iscilik_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_bom_packet_labour ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_paket_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sls_order_status; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_order_status (
    id bigint CONSTRAINT set_sls_order_status_id_not_null NOT NULL,
    order_status character varying(32) CONSTRAINT set_sls_order_status_siparis_durum_not_null NOT NULL,
    description character varying(64)
);


ALTER TABLE public.sls_order_status OWNER TO ths_admin;

--
-- Name: set_sat_siparis_durum_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sls_order_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_sat_siparis_durum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sls_offer_status; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_offer_status (
    id bigint CONSTRAINT set_sls_offer_status_id_not_null NOT NULL,
    status_code character varying(32) CONSTRAINT set_sls_offer_status_teklif_durum_not_null NOT NULL,
    aciklama character varying(64)
);


ALTER TABLE public.sls_offer_status OWNER TO ths_admin;

--
-- Name: set_sat_teklif_durum_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sls_offer_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_sat_teklif_durum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sls_dispatch_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_dispatch_detail (
    id bigint CONSTRAINT sat_irsaliye_detaylari_id_not_null NOT NULL,
    header_id bigint,
    teklif_detay_id bigint,
    order_detail_id bigint,
    fatura_detay_id bigint
);


ALTER TABLE public.sls_dispatch_detail OWNER TO ths_admin;

--
-- Name: sls_delivery_note_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sls_dispatch_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sls_delivery_note_detail_id_seq
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
    id bigint CONSTRAINT sat_irsaliyeler_id_not_null NOT NULL,
    delivery_note_number character varying(16),
    delivery_note_date timestamp without time zone,
    teklif_id bigint,
    order_id bigint,
    fatura_id bigint
);


ALTER TABLE public.sls_dispatch OWNER TO ths_admin;

--
-- Name: sls_delivery_note_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sls_dispatch ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sls_delivery_note_id_seq
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
    id bigint CONSTRAINT sat_faturalar_id_not_null NOT NULL,
    invoice_number character varying(16),
    invoice_date timestamp without time zone,
    teklif_id bigint,
    order_id bigint,
    irsaliye_id bigint
);


ALTER TABLE public.sls_invoice OWNER TO ths_admin;

--
-- Name: sls_invoice_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_invoice_detail (
    id bigint CONSTRAINT sat_fatura_detaylari_id_not_null NOT NULL,
    header_id bigint,
    teklif_detay_id bigint,
    order_detail_id bigint,
    irsaliye_detay_id bigint
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
-- Name: sls_offer; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_offer (
    id bigint NOT NULL,
    confirmed boolean DEFAULT false NOT NULL,
    total_amount numeric(18,6) DEFAULT 0 NOT NULL,
    discount_amount numeric(18,6) DEFAULT 0 NOT NULL,
    sub_total numeric(18,6) DEFAULT 0 NOT NULL,
    tax_rate1 integer DEFAULT 0 NOT NULL,
    tax_amount1 numeric(18,6) DEFAULT 0 NOT NULL,
    tax_rate2 integer DEFAULT 0 NOT NULL,
    tax_amount2 numeric(18,6) DEFAULT 0 NOT NULL,
    tax_rate3 integer DEFAULT 0 NOT NULL,
    tax_amount3 numeric(18,6) DEFAULT 0 NOT NULL,
    tax_rate4 integer DEFAULT 0 NOT NULL,
    tax_amount4 numeric(18,6) DEFAULT 0 NOT NULL,
    tax_rate5 integer DEFAULT 0 NOT NULL,
    tax_amount5 numeric(18,6) DEFAULT 0 NOT NULL,
    tax_total numeric(18,6) GENERATED ALWAYS AS (((((tax_amount1 + tax_amount2) + tax_amount3) + tax_amount4) + tax_amount5)) STORED,
    grand_total numeric(18,6) DEFAULT 0 NOT NULL,
    operation_type_id bigint,
    offer_number character varying(16) NOT NULL,
    offer_date date NOT NULL,
    validity_date date NOT NULL,
    customer_code character varying(16),
    customer_name character varying(128),
    tax_office character varying(32) NOT NULL,
    tax_number character varying(32) NOT NULL,
    country_id bigint,
    city_id bigint,
    district character varying(32),
    mahalle character varying(40),
    road character varying(40),
    street character varying(40),
    postal_code character varying(7),
    building_name character varying(40),
    door_number character varying(6),
    representative_id bigint,
    contact_name character varying(32),
    contact_phone character varying(24),
    reference character varying(128),
    currency_code character varying(3) NOT NULL,
    exchange_rate_usd numeric(7,4) DEFAULT 1,
    exchange_rate_eur numeric(7,4) DEFAULT 1,
    description character varying(128),
    proforma_no integer,
    delivery_method_id bigint NOT NULL,
    payment_method_id bigint NOT NULL,
    packet_type_id bigint NOT NULL,
    transport_charge_id bigint NOT NULL
);


ALTER TABLE public.sls_offer OWNER TO ths_admin;

--
-- Name: sls_offer_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_offer_detail (
    id bigint NOT NULL,
    header_id bigint,
    stock_code character varying(32),
    description character varying(128),
    user_description character varying(128),
    reference character varying(128),
    quantity double precision DEFAULT 1 NOT NULL,
    uom character varying(8),
    discount_rate numeric(6,3) DEFAULT 0,
    tax_rate integer DEFAULT 0,
    price numeric(18,6) DEFAULT 0,
    net_price numeric(18,6) DEFAULT 0 NOT NULL,
    amount numeric(18,6) DEFAULT 0 NOT NULL,
    discount_amount numeric(18,6) DEFAULT 0 NOT NULL,
    net_amount numeric(18,6) DEFAULT 0 NOT NULL,
    tax_amount numeric(18,6) DEFAULT 0 NOT NULL,
    total_amount numeric(18,6) DEFAULT 0 NOT NULL,
    packet_id bigint,
    gtip_no character varying(16)
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
-- Name: sls_order; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_order (
    id bigint CONSTRAINT sls_order_id_nn NOT NULL,
    teklif_id bigint,
    irsaliye_id bigint,
    fatura_id bigint,
    total_amount numeric(18,6) DEFAULT 0 CONSTRAINT sat_siparisler_tutar_not_null NOT NULL,
    discount_amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_discount_amount_nn NOT NULL,
    subtotal numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_subtotal_nn NOT NULL,
    tax_rate_1 integer DEFAULT 0 CONSTRAINT sls_order_tax_rate_1_nn NOT NULL,
    tax_amount_1 numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_tax_amount_1_nn NOT NULL,
    tax_rate_2 integer DEFAULT 0 CONSTRAINT sls_order_tax_rate_2_nn NOT NULL,
    tax_amount_2 numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_tax_amount_2_nn NOT NULL,
    tax_rate_3 integer DEFAULT 0 CONSTRAINT sls_order_tax_rate_3_nn NOT NULL,
    tax_amount_3 numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_tax_amount_3_nn NOT NULL,
    tax_rate_4 integer DEFAULT 0 CONSTRAINT sls_order_tax_rate_4_nn NOT NULL,
    tax_amount_4 numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_tax_amount_4_nn NOT NULL,
    tax_rate_5 integer DEFAULT 0 CONSTRAINT sls_order_tax_rate_5_nn NOT NULL,
    tax_amount_5 numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_tax_amount_5_nn NOT NULL,
    grand_total numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_total_amount_nn NOT NULL,
    operation_type_id bigint,
    order_number character varying(16),
    order_date date,
    delivery_date date,
    customer_code character varying(16),
    customer_name character varying(128),
    tax_office character varying(32),
    tax_number character varying(32),
    country_id bigint,
    city_id bigint,
    district character varying(32),
    neighborhood character varying(40),
    avenue character varying(40),
    street character varying(40),
    postal_code character varying(7),
    building_name character varying(40),
    door_number character varying(6),
    customer_representative_id bigint,
    contact_name character varying(32),
    reference character varying(128),
    currency_code character varying(3) CONSTRAINT sls_order_currency_code_nn NOT NULL,
    exchange_rate_usd numeric(7,4) DEFAULT 1,
    exchange_rate_eur numeric(7,4) DEFAULT 1,
    description character varying(128),
    proforma_no integer,
    status_id bigint,
    delivery_method_id bigint,
    payment_method_id bigint,
    packet_type_id bigint,
    transport_charge_id bigint
);


ALTER TABLE public.sls_order OWNER TO ths_admin;

--
-- Name: sls_order_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sls_order_detail (
    id bigint CONSTRAINT sls_order_detail_id_nn NOT NULL,
    header_id bigint,
    teklif_detay_id bigint,
    irsaliye_detay_id bigint,
    fatura_detay_id bigint,
    stok_kodu character varying(32),
    stock_description character varying(128),
    user_description character varying(128),
    referans character varying(128),
    miktar numeric(18,6) DEFAULT 1 CONSTRAINT sls_order_detail_qty_nn NOT NULL,
    outgoing_quantity numeric(18,6) DEFAULT 1 CONSTRAINT sls_order_detail_sent_qty_nn NOT NULL,
    uom_code character varying(8),
    discount_rate numeric(18,6) DEFAULT 0,
    tax_rate integer DEFAULT 0,
    fiyat numeric(18,6) DEFAULT 0,
    net_fiyat numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_detail_net_price_nn NOT NULL,
    amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_detail_amount_nn NOT NULL,
    discount_amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_detail_discount_amount_nn NOT NULL,
    net_amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_detail_net_amount_nn NOT NULL,
    tax_amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_detail_tax_amount_nn NOT NULL,
    total_amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_detail_total_amount_nn NOT NULL,
    is_ana_urun boolean DEFAULT false CONSTRAINT sls_order_detail_is_main_product_nn NOT NULL,
    referans_ana_urun_id bigint,
    gtip_no character varying(16),
    en numeric(12,6) DEFAULT 0,
    boy numeric(12,6) DEFAULT 0,
    height_en numeric(12,6) DEFAULT 0,
    net_weight numeric(12,6) DEFAULT 0,
    gross_weight numeric(12,6) DEFAULT 0,
    volume numeric(12,6) DEFAULT 0,
    thickness integer
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
    card_id bigint,
    kind_id bigint,
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
    vat_rate double precision NOT NULL,
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
    sku character varying(32) NOT NULL,
    quantity numeric(18,6) NOT NULL,
    amount numeric(18,6) NOT NULL,
    amount_foreign numeric(18,6) NOT NULL,
    currency character varying(3),
    direction boolean DEFAULT true,
    transaction_date timestamp without time zone NOT NULL,
    from_warehouse bigint NOT NULL,
    to_warehouse bigint NOT NULL,
    is_opening boolean DEFAULT false,
    description character varying(128),
    dispatch_id bigint,
    production_id bigint
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
    card_id bigint NOT NULL,
    image bytea,
    file_name character varying
);


ALTER TABLE public.stk_image OWNER TO ths_admin;

--
-- Name: stk_inventory; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_inventory (
    id bigint CONSTRAINT stk_inventory_id_nn NOT NULL,
    sellable boolean DEFAULT true,
    code character varying(32) CONSTRAINT stk_inventory_sku_nn NOT NULL,
    name character varying(128) CONSTRAINT stk_inventory_stock_name_nn NOT NULL,
    group_id bigint CONSTRAINT stk_inventory_group_id_nn NOT NULL,
    measurement_id bigint CONSTRAINT stk_inventory_uom_code_nn NOT NULL,
    product_type smallint CONSTRAINT stk_inventory_product_type_nn NOT NULL,
    buying_discount numeric(5,2) DEFAULT 0,
    sales_discount numeric(5,2) DEFAULT 0,
    buying_price numeric(18,6) DEFAULT 0,
    buying_currency character varying(3) DEFAULT public.fn_default_currency() CONSTRAINT stk_inventory_buy_currency_nn NOT NULL,
    sales_price numeric(18,6) DEFAULT 0,
    sales_currency character varying(3) DEFAULT public.fn_default_currency() CONSTRAINT stk_inventory_sell_currency_nn NOT NULL,
    export_price numeric(18,6) DEFAULT 0,
    export_currency character varying(3) DEFAULT public.fn_default_currency() CONSTRAINT stk_inventory_export_currency_nn NOT NULL,
    width double precision DEFAULT 0,
    length double precision DEFAULT 0,
    height double precision DEFAULT 0,
    weight double precision DEFAULT 0,
    supply_duration smallint,
    special_code character varying(16),
    brand character varying(32),
    origin_id bigint,
    hs_no character varying(16),
    diib_product_description character varying(64),
    min_stock_amount double precision DEFAULT 0,
    product_overview text
);


ALTER TABLE public.stk_inventory OWNER TO ths_admin;

--
-- Name: stk_inventory_summary; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_inventory_summary (
    id bigint NOT NULL,
    inventory_id bigint NOT NULL,
    current_quantity numeric(18,6) DEFAULT 0,
    average_cost numeric(18,6) DEFAULT 0,
    opening_price numeric(18,6) DEFAULT 0,
    opening_quantity numeric(18,6) DEFAULT 0,
    opening_amount numeric(18,6) DEFAULT 0,
    incoming_quantity numeric(18,6) DEFAULT 0,
    incoming_amount numeric(18,6) DEFAULT 0,
    outgoing_quantity numeric(18,6) DEFAULT 0,
    outgoing_amount numeric(18,6) DEFAULT 0,
    last_buy_price numeric(18,6),
    last_buy_money character varying(3),
    last_buy_date date,
    last_buy_quantity numeric(18,6) DEFAULT 0,
    last_buy_exchange_rate numeric(18,6) DEFAULT 0
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
    d5 character varying(32)
);


ALTER TABLE public.stk_kind_property OWNER TO ths_admin;

--
-- Name: stk_product_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stk_product_type (
    id bigint NOT NULL,
    product_type_name character varying(32) NOT NULL,
    description character varying(128),
    active boolean DEFAULT true
);


ALTER TABLE public.stk_product_type OWNER TO postgres;

--
-- Name: stk_product_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stk_product_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stk_product_type_id_seq OWNER TO postgres;

--
-- Name: stk_product_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
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
    warehouse_name character varying(32),
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
    permission_id bigint CONSTRAINT sys_access_rights_permission_id_not_null NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    is_add boolean DEFAULT false NOT NULL,
    is_update boolean DEFAULT false CONSTRAINT sys_access_right_is_upd_not_null NOT NULL,
    is_delete boolean DEFAULT false CONSTRAINT sys_access_right_is_del_not_null NOT NULL,
    is_special boolean DEFAULT false CONSTRAINT sys_access_right_is_spcl_not_null NOT NULL,
    user_id bigint CONSTRAINT sys_access_rights_user_id_not_null NOT NULL
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
    city_id bigint NOT NULL,
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
    address_id bigint,
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
    name character varying(32) NOT NULL,
    plate_code integer,
    country_id bigint,
    region_id bigint
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
    code character varying(2) NOT NULL,
    key character varying(128) CONSTRAINT sys_country_name_not_null NOT NULL,
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
    name character varying(64)
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
    quantity smallint DEFAULT 2,
    price smallint DEFAULT 2,
    total smallint DEFAULT 2,
    stock_quantity smallint DEFAULT 4,
    exchange_rate smallint DEFAULT 4
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
    min_value double precision DEFAULT 0,
    min_value_color integer DEFAULT 0,
    max_value double precision DEFAULT 0,
    max_value_color integer DEFAULT 0,
    max_value_percent double precision DEFAULT 0,
    bar_color integer DEFAULT 0,
    bar_bg_color integer DEFAULT 0,
    bar_text_color integer DEFAULT 0
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
    key character varying(64)
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
    code integer CONSTRAINT sys_perm_pc_not_null NOT NULL,
    group_id bigint CONSTRAINT sys_permissions_permission_group_id_not_null NOT NULL,
    key character varying(64) NOT NULL
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
    person_id bigint CONSTRAINT sys_users_person_id_not_null NOT NULL
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
    name character varying(64)
);


ALTER TABLE public.sys_permission_group_translation OWNER TO ths_admin;

--
-- Name: sys_permission_translation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_permission_translation (
    sys_permission_id bigint NOT NULL,
    sys_language_id bigint NOT NULL,
    name character varying(64)
);


ALTER TABLE public.sys_permission_translation OWNER TO ths_admin;

--
-- Name: sys_region; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_region (
    id bigint CONSTRAINT sys_reg_iid_not_null NOT NULL,
    name character varying(64) CONSTRAINT sys_reg_rn_not_null NOT NULL
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
    group_id bigint,
    multiplier integer
);


ALTER TABLE public.sys_uom OWNER TO ths_admin;

--
-- Name: sys_uom_group; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_uom_group (
    id bigint CONSTRAINT sys_uomt_iid_not_null NOT NULL,
    key character varying(16) CONSTRAINT sys_uomt_nm_not_null NOT NULL
);


ALTER TABLE public.sys_uom_group OWNER TO ths_admin;

--
-- Name: sys_uom_group_translation; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_uom_group_translation (
    sys_uom_group_id bigint CONSTRAINT sys_uom_type_translation_sys_uom_type_id_not_null NOT NULL,
    sys_language_id bigint CONSTRAINT sys_uom_type_translation_sys_language_id_not_null NOT NULL,
    name character varying(16) CONSTRAINT sys_uom_type_translation_name_not_null NOT NULL
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
    name character varying(64)
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
 SELECT (row_number() OVER (ORDER BY tables.table_type, tables.table_name))::integer AS id,
    initcap(replace((table_name)::text, '_'::text, ' '::text)) AS table_name,
    (table_type)::text AS table_type
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
     JOIN public.sys_view_tables vt ON ((( SELECT lower(replace(vt.table_name, ' '::text, '_'::text)) AS lower) = (columns.table_name)::text)))
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
-- Name: urt_recete_yan_urunler_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prd_bom_by_product ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urt_recete_yan_urunler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vw_acc_account; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_account AS
 SELECT a.id,
    a.code,
    a.name,
    a.type_id,
    a.group_id,
    a.region_id,
    a.iban,
    a.iban_currency,
    a.notes,
    a.root_code,
    a.sub_code,
    a.discount_rate,
    a.e_invoice_active,
    a.e_invoice_package_name,
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
    c.accountant_authorized
   FROM ((public.acc_account a
     LEFT JOIN public.acc_account_taxpayer t ON ((t.account_id = a.id)))
     LEFT JOIN public.acc_account_contact c ON ((c.account_id = a.id)));


ALTER VIEW public.vw_acc_account OWNER TO ths_admin;

--
-- Name: vw_acc_set_account_type; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_set_account_type AS
 SELECT t.id,
    tt.name,
    l.locale
   FROM ((public.acc_set_account_type t
     LEFT JOIN public.acc_set_account_type_translation tt ON ((tt.acc_set_account_type_id = t.id)))
     LEFT JOIN public.sys_language l ON ((l.id = tt.sys_language_id)));


ALTER VIEW public.vw_acc_set_account_type OWNER TO ths_admin;

--
-- Name: vw_acc_set_company_legal_form; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_set_company_legal_form AS
 SELECT f.id,
    f.ownership_id,
    ft.name,
    l.locale
   FROM ((public.acc_set_company_legal_form f
     LEFT JOIN public.acc_set_company_legal_form_translation ft ON ((ft.acc_set_company_legal_form_id = f.id)))
     LEFT JOIN public.sys_language l ON ((l.id = ft.sys_language_id)));


ALTER VIEW public.vw_acc_set_company_legal_form OWNER TO ths_admin;

--
-- Name: vw_acc_set_ownership_type; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_set_ownership_type AS
 SELECT o.id,
    ot.name,
    l.locale
   FROM ((public.acc_set_ownership_type o
     LEFT JOIN public.acc_set_ownership_type_translation ot ON ((ot.acc_set_ownership_type_id = o.id)))
     LEFT JOIN public.sys_language l ON ((l.id = ot.sys_language_id)));


ALTER VIEW public.vw_acc_set_ownership_type OWNER TO ths_admin;

--
-- Name: vw_emp_person_type; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_emp_person_type AS
 SELECT pt.id,
    ptt.person_type,
    l.locale
   FROM ((public.emp_person_type pt
     LEFT JOIN public.emp_person_type_translation ptt ON ((ptt.emp_person_type_id = pt.id)))
     LEFT JOIN public.sys_language l ON ((l.id = ptt.sys_language_id)));


ALTER VIEW public.vw_emp_person_type OWNER TO ths_admin;

--
-- Name: vw_emp_section; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_emp_section AS
 SELECT s.id,
    st.name AS section_name,
    l.locale
   FROM ((public.emp_section s
     LEFT JOIN public.emp_section_translation st ON ((st.emp_section_id = s.id)))
     LEFT JOIN public.sys_language l ON ((l.id = st.sys_language_id)));


ALTER VIEW public.vw_emp_section OWNER TO ths_admin;

--
-- Name: vw_emp_task; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_emp_task AS
 SELECT t.id,
    tt.name AS task_name,
    l.locale
   FROM ((public.emp_task t
     LEFT JOIN public.emp_task_translation tt ON ((tt.emp_task_id = t.id)))
     LEFT JOIN public.sys_language l ON ((l.id = tt.sys_language_id)));


ALTER VIEW public.vw_emp_task OWNER TO ths_admin;

--
-- Name: vw_emp_unit; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_emp_unit AS
 SELECT u.id,
    u.section_id,
    ut.name AS unit_name,
    l.locale,
    sec.section_name
   FROM (((public.emp_unit u
     LEFT JOIN public.emp_unit_translation ut ON ((ut.emp_unit_id = u.id)))
     LEFT JOIN public.sys_language l ON ((l.id = ut.sys_language_id)))
     LEFT JOIN public.vw_emp_section sec ON (((sec.id = u.section_id) AND ((sec.locale)::text = (l.locale)::text))));


ALTER VIEW public.vw_emp_unit OWNER TO ths_admin;

--
-- Name: vw_sys_access_right; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_access_right AS
 SELECT DISTINCT a.id,
    u.username,
    e.full_name,
    p.code,
    pt.name AS permission_name,
    pgt.name AS permission_group,
    a.permission_id,
    a.is_read,
    a.is_add,
    a.is_update,
    a.is_delete,
    a.is_special,
    a.user_id,
    l.locale
   FROM (((((((public.sys_access_right a
     LEFT JOIN public.sys_permission p ON ((p.id = a.permission_id)))
     LEFT JOIN public.sys_permission_translation pt ON ((pt.sys_permission_id = p.id)))
     LEFT JOIN public.sys_permission_group pg ON ((pg.id = p.group_id)))
     LEFT JOIN public.sys_permission_group_translation pgt ON (((pgt.sys_permission_group_id = p.group_id) AND (pt.sys_language_id = pgt.sys_language_id))))
     LEFT JOIN public.sys_language l ON ((l.id = pt.sys_language_id)))
     LEFT JOIN public.sys_user u ON ((u.id = a.user_id)))
     LEFT JOIN public.emp_person e ON ((e.id = u.person_id)));


ALTER VIEW public.vw_sys_access_right OWNER TO ths_admin;

--
-- Name: vw_sys_cities; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_cities AS
 SELECT ct.id,
    ct.name AS city_name,
    ct.plate_code AS car_plate_code,
    ct.country_id,
    ct.region_id,
    cn.code AS country_code,
    cn.key AS country_name,
    r.name AS region_name
   FROM ((public.sys_city ct
     LEFT JOIN public.sys_country cn ON ((cn.id = ct.country_id)))
     LEFT JOIN public.sys_region r ON ((r.id = ct.region_id)))
  WHERE (1 = 1);


ALTER VIEW public.vw_sys_cities OWNER TO ths_admin;

--
-- Name: vw_sys_countries; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_countries AS
 SELECT id,
    code,
    key AS name,
    iso_year,
    iso_cctld,
    is_eu_member
   FROM public.sys_country ct
  WHERE (1 = 1);


ALTER VIEW public.vw_sys_countries OWNER TO ths_admin;

--
-- Name: vw_sys_country; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_country AS
 SELECT a.id,
    cnt.name AS country,
    ct.name AS city,
    a.city_id,
    cn.id AS country_id,
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
   FROM ((((public.sys_address a
     LEFT JOIN public.sys_city ct ON ((ct.id = a.city_id)))
     LEFT JOIN public.sys_country cn ON ((cn.id = ct.country_id)))
     LEFT JOIN public.sys_country_translation cnt ON ((cnt.sys_country_id = cn.id)))
     LEFT JOIN public.sys_language l ON ((l.id = cnt.sys_language_id)));


ALTER VIEW public.vw_sys_country OWNER TO ths_admin;

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
-- Name: vw_sys_permission; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_permission AS
 SELECT p.id,
    p.key,
    p.code,
    pt.name,
    p.group_id,
    pg.key AS group_key,
    pgt.name AS group_name,
    l.locale
   FROM ((((public.sys_permission p
     LEFT JOIN public.sys_permission_group pg ON ((pg.id = p.group_id)))
     LEFT JOIN public.sys_permission_translation pt ON ((pt.sys_permission_id = p.id)))
     LEFT JOIN public.sys_language l ON ((l.id = pt.sys_language_id)))
     LEFT JOIN public.sys_permission_group_translation pgt ON (((pgt.sys_permission_group_id = pg.id) AND (pgt.sys_language_id = l.id))));


ALTER VIEW public.vw_sys_permission OWNER TO ths_admin;

--
-- Name: vw_sys_permission_group; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_permission_group AS
 SELECT pg.id,
    pg.key,
    pgt.name,
    l.locale
   FROM ((public.sys_permission_group pg
     LEFT JOIN public.sys_permission_group_translation pgt ON ((pgt.sys_permission_group_id = pg.id)))
     LEFT JOIN public.sys_language l ON ((l.id = pgt.sys_language_id)));


ALTER VIEW public.vw_sys_permission_group OWNER TO ths_admin;

--
-- Name: vw_sys_uom; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_uom AS
 SELECT u.id,
    u.unit_code,
    u.unit_einv,
    u."decimal",
    u.multiplier,
    u.group_id,
    ut.name,
    ug.key AS group_key,
    l.locale
   FROM ((((public.sys_uom u
     LEFT JOIN public.sys_uom_group ug ON ((ug.id = u.group_id)))
     LEFT JOIN public.sys_uom_translation ut ON ((ut.sys_uom_id = u.id)))
     LEFT JOIN public.sys_uom_group_translation ugt ON (((ugt.sys_uom_group_id = u.group_id) AND (ugt.sys_language_id = ut.sys_language_id))))
     LEFT JOIN public.sys_language l ON ((l.id = ut.sys_language_id)));


ALTER VIEW public.vw_sys_uom OWNER TO ths_admin;

--
-- Name: vw_sys_uom_group; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_uom_group AS
 SELECT ut.id,
    ut.key,
    utt.name,
    l.locale
   FROM ((public.sys_uom_group ut
     LEFT JOIN public.sys_uom_group_translation utt ON ((utt.sys_uom_group_id = ut.id)))
     LEFT JOIN public.sys_language l ON ((l.id = utt.sys_language_id)));


ALTER VIEW public.vw_sys_uom_group OWNER TO ths_admin;

--
-- Name: vw_sys_user; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_user AS
 SELECT u.id,
    e.name,
    e.surname,
    e.full_name,
    est.name AS section_name,
    eut.name AS unit_name,
    u.username,
    u.user_password,
    u.active,
    u.manager,
    u.super_user,
    u.ip_address,
    u.mac_address,
    u.person_id,
    l.locale
   FROM ((((((public.sys_user u
     LEFT JOIN public.emp_person e ON ((e.id = u.person_id)))
     LEFT JOIN public.emp_unit eu ON ((eu.id = e.unit_id)))
     LEFT JOIN public.emp_section es ON ((es.id = eu.section_id)))
     LEFT JOIN public.emp_unit_translation eut ON ((eut.emp_unit_id = eu.id)))
     LEFT JOIN public.emp_section_translation est ON ((est.emp_section_id = eu.section_id)))
     LEFT JOIN public.sys_language l ON ((l.id = eut.sys_language_id)));


ALTER VIEW public.vw_sys_user OWNER TO ths_admin;

--
-- Name: pur_offer_detail id; Type: DEFAULT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_offer_detail ALTER COLUMN id SET DEFAULT nextval('public.pur_offer_detail_id_seq'::regclass);


--
-- Name: stk_kind_family id; Type: DEFAULT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kind_family ALTER COLUMN id SET DEFAULT nextval('public.stk_kind_family_id_seq'::regclass);


--
-- Name: stk_product_type id; Type: DEFAULT; Schema: public; Owner: postgres
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
    ADD CONSTRAINT acc_account_contact_pkey PRIMARY KEY (account_id);


--
-- Name: acc_account_taxpayer acc_account_taxpayer_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account_taxpayer
    ADD CONSTRAINT acc_account_taxpayer_pkey PRIMARY KEY (account_id);


--
-- Name: acc_account_plan acc_aplan_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account_plan
    ADD CONSTRAINT acc_aplan_pkey PRIMARY KEY (id);


--
-- Name: acc_bank acc_bank_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_bank
    ADD CONSTRAINT acc_bank_name_key UNIQUE (name);


--
-- Name: acc_bank acc_bank_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_bank
    ADD CONSTRAINT acc_bank_pkey PRIMARY KEY (id);


--
-- Name: acc_bank_branch acc_branch_bc_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_bank_branch
    ADD CONSTRAINT acc_branch_bc_key UNIQUE (bank_id, code);


--
-- Name: acc_bank_branch acc_branch_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_bank_branch
    ADD CONSTRAINT acc_branch_pkey PRIMARY KEY (id);


--
-- Name: acc_set_company_legal_form acc_clf_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_company_legal_form
    ADD CONSTRAINT acc_clf_name_key UNIQUE (name);


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
    ADD CONSTRAINT acc_otn_name_key UNIQUE (name);


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
    ADD CONSTRAINT acc_set_at_type_key UNIQUE (name);


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
-- Name: pur_offer_detail als_teklif_detaylari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_offer_detail
    ADD CONSTRAINT als_teklif_detaylari_pkey PRIMARY KEY (id);


--
-- Name: pur_offer als_teklifler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_offer
    ADD CONSTRAINT als_teklifler_pkey PRIMARY KEY (id);


--
-- Name: pur_offer als_teklifler_teklif_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_offer
    ADD CONSTRAINT als_teklifler_teklif_no_key UNIQUE (offer_number);


--
-- Name: audits audits_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.audits
    ADD CONSTRAINT audits_pkey PRIMARY KEY (id);


--
-- Name: einv_delivery_type einv_delivery_type_delivery_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_delivery_type
    ADD CONSTRAINT einv_delivery_type_delivery_code_key UNIQUE (delivery_method);


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
-- Name: emp_unit_translation emp_unit_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_unit_translation
    ADD CONSTRAINT emp_unit_translation_pkey PRIMARY KEY (emp_unit_id, sys_language_id);


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
-- Name: prd_bom_by_product prd_bom_by_product_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_by_product
    ADD CONSTRAINT prd_bom_by_product_pkey PRIMARY KEY (id);


--
-- Name: prd_bom_by_product prd_bom_by_product_sku_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_by_product
    ADD CONSTRAINT prd_bom_by_product_sku_key UNIQUE (product_sku, header_id);


--
-- Name: prd_bom_labour prd_bom_labour_cost_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_labour
    ADD CONSTRAINT prd_bom_labour_cost_code_key UNIQUE (labor_code);


--
-- Name: prd_bom_labour prd_bom_labour_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_labour
    ADD CONSTRAINT prd_bom_labour_pkey PRIMARY KEY (id);


--
-- Name: prd_bom_packet_labour prd_bom_packet_labour_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_labour
    ADD CONSTRAINT prd_bom_packet_labour_pkey PRIMARY KEY (id);


--
-- Name: prd_bom_packet_labour prd_bom_packet_labour_pkg_id_nn; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_labour
    ADD CONSTRAINT prd_bom_packet_labour_pkg_id_nn UNIQUE (header_id, paket_id);


--
-- Name: prd_bom_packet_raw prd_bom_packet_raw_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_raw
    ADD CONSTRAINT prd_bom_packet_raw_pkey PRIMARY KEY (id);


--
-- Name: prd_bom_packet_raw prd_bom_packet_raw_pkg_id_nn; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_raw
    ADD CONSTRAINT prd_bom_packet_raw_pkg_id_nn UNIQUE (header_id, paket_id);


--
-- Name: prd_bom prd_bom_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom
    ADD CONSTRAINT prd_bom_pkey PRIMARY KEY (id);


--
-- Name: prd_bom prd_bom_product_sku_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom
    ADD CONSTRAINT prd_bom_product_sku_key UNIQUE (product_sku, product_name);


--
-- Name: prd_labour prd_labour_cost_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_labour
    ADD CONSTRAINT prd_labour_cost_code_key UNIQUE (cost_code);


--
-- Name: prd_labour prd_labour_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_labour
    ADD CONSTRAINT prd_labour_pkey PRIMARY KEY (id);


--
-- Name: prd_packet_labour_detail prd_packet_labour_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_labour_detail
    ADD CONSTRAINT prd_packet_labour_detail_pkey PRIMARY KEY (id);


--
-- Name: prd_packet_labour_detail prd_packet_labour_detail_sku_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_labour_detail
    ADD CONSTRAINT prd_packet_labour_detail_sku_key UNIQUE (labor_code, header_id);


--
-- Name: prd_packet_labour prd_packet_labour_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_labour
    ADD CONSTRAINT prd_packet_labour_name_key UNIQUE (package_name);


--
-- Name: prd_packet_labour prd_packet_labour_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_labour
    ADD CONSTRAINT prd_packet_labour_pkey PRIMARY KEY (id);


--
-- Name: prd_packet_raw_detail prd_packet_raw_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_raw_detail
    ADD CONSTRAINT prd_packet_raw_detail_pkey PRIMARY KEY (id);


--
-- Name: prd_packet_raw_detail prd_packet_raw_detail_sku_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_raw_detail
    ADD CONSTRAINT prd_packet_raw_detail_sku_key UNIQUE (sku_code, header_id);


--
-- Name: prd_packet_raw prd_packet_raw_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_raw
    ADD CONSTRAINT prd_packet_raw_name_key UNIQUE (package_name);


--
-- Name: prd_packet_raw prd_packet_raw_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_raw
    ADD CONSTRAINT prd_packet_raw_pkey PRIMARY KEY (id);


--
-- Name: prd_bom_raw prd_rhmd_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_raw
    ADD CONSTRAINT prd_rhmd_pkey PRIMARY KEY (id);


--
-- Name: prd_bom_raw prd_rhmd_sih_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_raw
    ADD CONSTRAINT prd_rhmd_sih_key UNIQUE (stok_kodu, header_id);


--
-- Name: emp_driver_ability prs_driver_abilities_driver_license_id_person_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_driver_ability
    ADD CONSTRAINT prs_driver_abilities_driver_license_id_person_id_key UNIQUE (driver_license_id, person_id);


--
-- Name: emp_driver_ability prs_driver_abilities_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_driver_ability
    ADD CONSTRAINT prs_driver_abilities_pkey PRIMARY KEY (id);


--
-- Name: emp_person_language_ability prs_language_abilities_language_id_person_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_language_ability
    ADD CONSTRAINT prs_language_abilities_language_id_person_id_key UNIQUE (language_id, person_id);


--
-- Name: emp_person_language_ability prs_language_abilities_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_language_ability
    ADD CONSTRAINT prs_language_abilities_pkey PRIMARY KEY (id);


--
-- Name: emp_person prs_persons_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person
    ADD CONSTRAINT prs_persons_pkey PRIMARY KEY (id);


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
-- Name: emp_language_level prs_set_lll_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_language_level
    ADD CONSTRAINT prs_set_lll_key UNIQUE (language_level);


--
-- Name: emp_language_level prs_set_lll_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_language_level
    ADD CONSTRAINT prs_set_lll_pkey PRIMARY KEY (id);


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
    ADD CONSTRAINT prs_set_ptp_name_key UNIQUE (person_type);


--
-- Name: emp_person_type prs_set_ptp_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_type
    ADD CONSTRAINT prs_set_ptp_pkey PRIMARY KEY (id);


--
-- Name: emp_section prs_set_sec_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_section
    ADD CONSTRAINT prs_set_sec_name_key UNIQUE (section_name);


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
-- Name: emp_transportation prs_set_trans_car_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_transportation
    ADD CONSTRAINT prs_set_trans_car_key UNIQUE (car_no);


--
-- Name: emp_transportation prs_set_trans_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_transportation
    ADD CONSTRAINT prs_set_trans_pkey PRIMARY KEY (id);


--
-- Name: emp_task prs_set_tsk_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_task
    ADD CONSTRAINT prs_set_tsk_name_key UNIQUE (task_name);


--
-- Name: emp_unit prs_set_unit_ns_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_unit
    ADD CONSTRAINT prs_set_unit_ns_key UNIQUE (unit_name, section_id);


--
-- Name: emp_unit prs_set_unit_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_unit
    ADD CONSTRAINT prs_set_unit_pkey PRIMARY KEY (id);


--
-- Name: sls_invoice_detail sat_fatura_detaylari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice_detail
    ADD CONSTRAINT sat_fatura_detaylari_pkey PRIMARY KEY (id);


--
-- Name: sls_invoice sat_faturalar_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice
    ADD CONSTRAINT sat_faturalar_pkey PRIMARY KEY (id);


--
-- Name: sls_dispatch_detail sat_irsaliye_detaylari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch_detail
    ADD CONSTRAINT sat_irsaliye_detaylari_pkey PRIMARY KEY (id);


--
-- Name: sls_dispatch sat_irsaliyeler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch
    ADD CONSTRAINT sat_irsaliyeler_pkey PRIMARY KEY (id);


--
-- Name: sls_offer sat_teklif_teklif_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sat_teklif_teklif_no_key UNIQUE (offer_number);


--
-- Name: sls_offer sat_teklifler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sat_teklifler_pkey PRIMARY KEY (id);


--
-- Name: einv_invoice_type set_einv_fatura_tipleri_fatura_tipi_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_invoice_type
    ADD CONSTRAINT set_einv_fatura_tipleri_fatura_tipi_key UNIQUE (invoice_type_code);


--
-- Name: einv_invoice_type set_einv_fatura_tipleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_invoice_type
    ADD CONSTRAINT set_einv_fatura_tipleri_pkey PRIMARY KEY (id);


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
-- Name: einv_packet_type set_einv_paket_tipleri_kod_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_packet_type
    ADD CONSTRAINT set_einv_paket_tipleri_kod_key UNIQUE (code);


--
-- Name: einv_packet_type set_einv_paket_tipleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_packet_type
    ADD CONSTRAINT set_einv_paket_tipleri_pkey PRIMARY KEY (id);


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
-- Name: einv_delivery_type set_einv_teslim_sekilleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_delivery_type
    ADD CONSTRAINT set_einv_teslim_sekilleri_pkey PRIMARY KEY (id);


--
-- Name: sls_order_status set_sat_siparis_durum_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order_status
    ADD CONSTRAINT set_sat_siparis_durum_pkey PRIMARY KEY (id);


--
-- Name: sls_order_status set_sat_siparis_durum_siparis_durum_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order_status
    ADD CONSTRAINT set_sat_siparis_durum_siparis_durum_key UNIQUE (order_status);


--
-- Name: sls_offer_status set_sat_teklif_durum_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer_status
    ADD CONSTRAINT set_sat_teklif_durum_pkey PRIMARY KEY (id);


--
-- Name: sls_offer_status set_sat_teklif_durum_teklif_durum_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer_status
    ADD CONSTRAINT set_sat_teklif_durum_teklif_durum_key UNIQUE (status_code);


--
-- Name: sls_offer_detail sls_offer_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer_detail
    ADD CONSTRAINT sls_offer_detail_pkey PRIMARY KEY (id);


--
-- Name: sls_order_detail sls_order_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order_detail
    ADD CONSTRAINT sls_order_detail_pkey PRIMARY KEY (id);


--
-- Name: sls_order sls_order_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_pkey PRIMARY KEY (id);


--
-- Name: stk_card_kind_info stk_card_kind_info_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_card_kind_info
    ADD CONSTRAINT stk_card_kind_info_pkey PRIMARY KEY (id);


--
-- Name: stk_group stk_group_group_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_group
    ADD CONSTRAINT stk_group_group_key UNIQUE (name);


--
-- Name: stk_group stk_group_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_group
    ADD CONSTRAINT stk_group_pkey PRIMARY KEY (id);


--
-- Name: stk_image stk_image_card_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_image
    ADD CONSTRAINT stk_image_card_id_key UNIQUE (card_id);


--
-- Name: stk_image stk_image_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_image
    ADD CONSTRAINT stk_image_pkey PRIMARY KEY (id);


--
-- Name: stk_inventory stk_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_pkey PRIMARY KEY (id);


--
-- Name: stk_inventory stk_inventory_sku_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_sku_key UNIQUE (code);


--
-- Name: stk_inventory_summary stk_inventory_summary_inventory_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory_summary
    ADD CONSTRAINT stk_inventory_summary_inventory_id_key UNIQUE (inventory_id);


--
-- Name: stk_inventory_summary stk_inventory_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory_summary
    ADD CONSTRAINT stk_inventory_summary_pkey PRIMARY KEY (id);


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
-- Name: stk_product_type stk_product_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stk_product_type
    ADD CONSTRAINT stk_product_type_pkey PRIMARY KEY (id);


--
-- Name: stk_transaction stk_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_pkey PRIMARY KEY (id);


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
-- Name: sys_access_right sys_access_right_permission_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_access_right
    ADD CONSTRAINT sys_access_right_permission_id_user_id_key UNIQUE (permission_id, user_id);


--
-- Name: sys_access_right sys_access_right_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_access_right
    ADD CONSTRAINT sys_access_right_pkey PRIMARY KEY (id);


--
-- Name: sys_address sys_address_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_address
    ADD CONSTRAINT sys_address_pkey PRIMARY KEY (id);


--
-- Name: sys_application_setting sys_application_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_application_setting
    ADD CONSTRAINT sys_application_setting_pkey PRIMARY KEY (id);


--
-- Name: sys_city sys_city_cid_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_city
    ADD CONSTRAINT sys_city_cid_name_key UNIQUE (country_id, name);


--
-- Name: sys_city sys_city_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_city
    ADD CONSTRAINT sys_city_pkey PRIMARY KEY (id);


--
-- Name: sys_country sys_country_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_country
    ADD CONSTRAINT sys_country_code_key UNIQUE (code);


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
-- Name: sys_permission_group sys_perm_group_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_group
    ADD CONSTRAINT sys_perm_group_pkey PRIMARY KEY (id);


--
-- Name: sys_permission sys_permission_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission
    ADD CONSTRAINT sys_permission_code_key UNIQUE (code);


--
-- Name: sys_permission_group sys_permission_group_key_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_group
    ADD CONSTRAINT sys_permission_group_key_key UNIQUE (key);


--
-- Name: sys_permission_group_translation sys_permission_group_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_group_translation
    ADD CONSTRAINT sys_permission_group_translation_pkey PRIMARY KEY (sys_permission_group_id, sys_language_id);


--
-- Name: sys_permission sys_permission_key_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission
    ADD CONSTRAINT sys_permission_key_key UNIQUE (key);


--
-- Name: sys_permission sys_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission
    ADD CONSTRAINT sys_permission_pkey PRIMARY KEY (id);


--
-- Name: sys_permission_translation sys_permission_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission_translation
    ADD CONSTRAINT sys_permission_translation_pkey PRIMARY KEY (sys_permission_id, sys_language_id);


--
-- Name: sys_region sys_region_name_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_region
    ADD CONSTRAINT sys_region_name_key UNIQUE (name);


--
-- Name: sys_region sys_region_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_region
    ADD CONSTRAINT sys_region_pkey PRIMARY KEY (id);


--
-- Name: sys_uom_group sys_uom_group_key_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_uom_group
    ADD CONSTRAINT sys_uom_group_key_key UNIQUE (key);


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
-- Name: sys_user sys_user_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_user_pkey PRIMARY KEY (id);


--
-- Name: sys_user sys_user_username_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_user_username_key UNIQUE (username);


--
-- Name: idx_als_teklif_detaylari_header_id; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX idx_als_teklif_detaylari_header_id ON public.pur_offer_detail USING btree (header_id);


--
-- Name: idx_sat_siparis_detaylari_header_id; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX idx_sat_siparis_detaylari_header_id ON public.sls_order_detail USING btree (header_id);


--
-- Name: idx_sat_siparis_musteri_kodu; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX idx_sat_siparis_musteri_kodu ON public.sls_order USING btree (customer_code);


--
-- Name: idx_sat_teklif_detaylari_header_id; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX idx_sat_teklif_detaylari_header_id ON public.sls_offer_detail USING btree (header_id);


--
-- Name: emp_section audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.emp_section FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: emp_driver_ability notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_driver_ability FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_driver_license_type notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_driver_license_type FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_language notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_language FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_language_level notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_language_level FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_person notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_person FOR EACH ROW EXECUTE FUNCTION public.table_notify();


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
-- Name: prd_bom trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_bom FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_bom_by_product trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_bom_by_product FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_bom_labour trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_bom_labour FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_bom_packet_labour trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_bom_packet_labour FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_bom_packet_raw trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_bom_packet_raw FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_bom_raw trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_bom_raw FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_labour trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_labour FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_packet_labour trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_packet_labour FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_packet_labour_detail trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_packet_labour_detail FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_packet_raw trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_packet_raw FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_packet_raw_detail trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_packet_raw_detail FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_account acc_acc_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account
    ADD CONSTRAINT acc_acc_group_fkey FOREIGN KEY (group_id) REFERENCES public.acc_group(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_account acc_acc_region_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account
    ADD CONSTRAINT acc_acc_region_fkey FOREIGN KEY (region_id) REFERENCES public.acc_account_plan(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_account acc_acc_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account
    ADD CONSTRAINT acc_acc_type_fkey FOREIGN KEY (type_id) REFERENCES public.acc_set_account_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_account_address acc_account_address_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account_address
    ADD CONSTRAINT acc_account_address_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.acc_account(id) ON DELETE CASCADE;


--
-- Name: acc_account_address acc_account_address_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account_address
    ADD CONSTRAINT acc_account_address_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.sys_address(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_account_contact acc_account_contact_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account_contact
    ADD CONSTRAINT acc_account_contact_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: acc_account_taxpayer acc_account_taxpayer_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_account_taxpayer
    ADD CONSTRAINT acc_account_taxpayer_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.acc_account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: acc_bank_branch acc_branch_bank_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_bank_branch
    ADD CONSTRAINT acc_branch_bank_fkey FOREIGN KEY (bank_id) REFERENCES public.acc_bank(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_bank_branch acc_branch_city_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_bank_branch
    ADD CONSTRAINT acc_branch_city_fkey FOREIGN KEY (city_id) REFERENCES public.sys_city(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_set_company_legal_form acc_clf_own_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_set_company_legal_form
    ADD CONSTRAINT acc_clf_own_fkey FOREIGN KEY (ownership_id) REFERENCES public.acc_set_ownership_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: pur_offer_detail als_teklif_detaylari_header_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_offer_detail
    ADD CONSTRAINT als_teklif_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.pur_offer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pur_offer_detail als_teklif_detaylari_referans_ana_urun_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_offer_detail
    ADD CONSTRAINT als_teklif_detaylari_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.pur_offer_detail(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_offer_detail als_teklif_detaylari_stok_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_offer_detail
    ADD CONSTRAINT als_teklif_detaylari_stok_kodu_fkey FOREIGN KEY (sku_code) REFERENCES public.stk_inventory(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_offer als_teklifler_islem_tipi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_offer
    ADD CONSTRAINT als_teklifler_islem_tipi_id_fkey FOREIGN KEY (operation_type_id) REFERENCES public.einv_invoice_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_offer als_teklifler_musteri_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_offer
    ADD CONSTRAINT als_teklifler_musteri_kodu_fkey FOREIGN KEY (customer_code) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: emp_person_address emp_person_address_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_address
    ADD CONSTRAINT emp_person_address_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.sys_address(id) ON DELETE RESTRICT;


--
-- Name: emp_person_address emp_person_address_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_address
    ADD CONSTRAINT emp_person_address_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.emp_person(id) ON DELETE CASCADE;


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
-- Name: acc_voucher_detail mhs_fis_detaylari_header_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_voucher_detail
    ADD CONSTRAINT mhs_fis_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.acc_voucher(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: acc_transfer_code mhs_transfer_kodlari_hesap_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.acc_transfer_code
    ADD CONSTRAINT mhs_transfer_kodlari_hesap_kodu_fkey FOREIGN KEY (account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_bom_by_product prd_bom_by_product_header_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_by_product
    ADD CONSTRAINT prd_bom_by_product_header_fk FOREIGN KEY (header_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_by_product prd_bom_by_product_sku_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_by_product
    ADD CONSTRAINT prd_bom_by_product_sku_fk FOREIGN KEY (product_sku) REFERENCES public.stk_inventory(code) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_labour prd_bom_labour_cost_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_labour
    ADD CONSTRAINT prd_bom_labour_cost_code_fk FOREIGN KEY (labor_code) REFERENCES public.prd_labour(cost_code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_bom_labour prd_bom_labour_header_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_labour
    ADD CONSTRAINT prd_bom_labour_header_fk FOREIGN KEY (header_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_packet_labour prd_bom_packet_labour_header_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_labour
    ADD CONSTRAINT prd_bom_packet_labour_header_fk FOREIGN KEY (header_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_packet_labour prd_bom_packet_labour_pkg_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_labour
    ADD CONSTRAINT prd_bom_packet_labour_pkg_fk FOREIGN KEY (paket_id) REFERENCES public.prd_packet_labour(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_bom_packet_raw prd_bom_packet_raw_header_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_raw
    ADD CONSTRAINT prd_bom_packet_raw_header_fk FOREIGN KEY (header_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_packet_raw prd_bom_packet_raw_pkg_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_raw
    ADD CONSTRAINT prd_bom_packet_raw_pkg_fk FOREIGN KEY (paket_id) REFERENCES public.prd_packet_raw(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_bom prd_bom_product_sku_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom
    ADD CONSTRAINT prd_bom_product_sku_fk FOREIGN KEY (product_sku) REFERENCES public.stk_inventory(code) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_raw prd_bom_raw_sku_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_raw
    ADD CONSTRAINT prd_bom_raw_sku_fk FOREIGN KEY (stok_kodu) REFERENCES public.stk_inventory(code) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_labour prd_labour_cost_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_labour
    ADD CONSTRAINT prd_labour_cost_code_fk FOREIGN KEY (cost_code) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_labour prd_labour_unit_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_labour
    ADD CONSTRAINT prd_labour_unit_code_fk FOREIGN KEY (uom_code) REFERENCES public.sys_uom(unit_code) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: prd_packet_labour_detail prd_packet_labour_detail_cost_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_labour_detail
    ADD CONSTRAINT prd_packet_labour_detail_cost_code_fk FOREIGN KEY (labor_code) REFERENCES public.prd_labour(cost_code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_packet_labour_detail prd_packet_labour_detail_header_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_labour_detail
    ADD CONSTRAINT prd_packet_labour_detail_header_fk FOREIGN KEY (header_id) REFERENCES public.prd_packet_labour(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_packet_raw_detail prd_packet_raw_detail_header_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_raw_detail
    ADD CONSTRAINT prd_packet_raw_detail_header_fk FOREIGN KEY (header_id) REFERENCES public.prd_packet_raw(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_packet_raw_detail prd_packet_raw_detail_recipe_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_raw_detail
    ADD CONSTRAINT prd_packet_raw_detail_recipe_fk FOREIGN KEY (recete_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: prd_packet_raw_detail prd_packet_raw_detail_sku_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_packet_raw_detail
    ADD CONSTRAINT prd_packet_raw_detail_sku_fk FOREIGN KEY (sku_code) REFERENCES public.stk_inventory(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_bom_raw prd_rhmd_hdr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_raw
    ADD CONSTRAINT prd_rhmd_hdr_fkey FOREIGN KEY (header_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_raw prd_rhmd_rct_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_raw
    ADD CONSTRAINT prd_rhmd_rct_fkey FOREIGN KEY (recete_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_driver_ability prs_driver_abilities_driver_license_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_driver_ability
    ADD CONSTRAINT prs_driver_abilities_driver_license_id_fkey FOREIGN KEY (driver_license_id) REFERENCES public.emp_driver_license_type(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_driver_ability prs_driver_abilities_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_driver_ability
    ADD CONSTRAINT prs_driver_abilities_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.emp_person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_person_language_ability prs_language_abilities_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_language_ability
    ADD CONSTRAINT prs_language_abilities_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.emp_language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_person_language_ability prs_language_abilities_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_language_ability
    ADD CONSTRAINT prs_language_abilities_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.emp_person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_person_language_ability prs_language_abilities_read_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_language_ability
    ADD CONSTRAINT prs_language_abilities_read_id_fkey FOREIGN KEY (read_id) REFERENCES public.emp_language_level(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_person_language_ability prs_language_abilities_speak_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_language_ability
    ADD CONSTRAINT prs_language_abilities_speak_id_fkey FOREIGN KEY (speak_id) REFERENCES public.emp_language_level(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_person_language_ability prs_language_abilities_write_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person_language_ability
    ADD CONSTRAINT prs_language_abilities_write_id_fkey FOREIGN KEY (write_id) REFERENCES public.emp_language_level(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_person prs_persons_person_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person
    ADD CONSTRAINT prs_persons_person_type_id_fkey FOREIGN KEY (person_type_id) REFERENCES public.emp_person_type(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: emp_person prs_persons_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person
    ADD CONSTRAINT prs_persons_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.emp_task(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: emp_person prs_persons_transportation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person
    ADD CONSTRAINT prs_persons_transportation_id_fkey FOREIGN KEY (transportation_id) REFERENCES public.emp_transportation(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: emp_person prs_persons_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_person
    ADD CONSTRAINT prs_persons_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.emp_unit(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: emp_unit prs_set_unit_ssection_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.emp_unit
    ADD CONSTRAINT prs_set_unit_ssection_fkey FOREIGN KEY (section_id) REFERENCES public.emp_section(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_offer pur_offer_city_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_offer
    ADD CONSTRAINT pur_offer_city_id_fk FOREIGN KEY (city_id) REFERENCES public.sys_city(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_offer pur_offer_country_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_offer
    ADD CONSTRAINT pur_offer_country_id_fk FOREIGN KEY (country_id) REFERENCES public.sys_country(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_offer pur_offer_currency_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_offer
    ADD CONSTRAINT pur_offer_currency_code_fk FOREIGN KEY (currency_code) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_offer_detail pur_offer_detail_uom_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_offer_detail
    ADD CONSTRAINT pur_offer_detail_uom_code_fk FOREIGN KEY (uom_code) REFERENCES public.sys_uom(unit_code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_invoice_detail sat_fatura_detaylari_header_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_invoice_detail
    ADD CONSTRAINT sat_fatura_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sls_invoice(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sls_dispatch_detail sat_irsaliye_detaylari_header_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_dispatch_detail
    ADD CONSTRAINT sat_irsaliye_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sls_dispatch(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sls_order sat_siparisler_sehir_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sat_siparisler_sehir_id_fkey FOREIGN KEY (city_id) REFERENCES public.sys_city(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sls_order sat_siparisler_siparis_durum_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sat_siparisler_siparis_durum_id_fkey FOREIGN KEY (status_id) REFERENCES public.sls_order_status(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sat_siparisler_teslim_sekli_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sat_siparisler_teslim_sekli_id_fkey FOREIGN KEY (delivery_method_id) REFERENCES public.einv_delivery_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sat_siparisler_ulke_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sat_siparisler_ulke_id_fkey FOREIGN KEY (country_id) REFERENCES public.sys_country(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sls_offer_detail sat_teklif_detaylari_header_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer_detail
    ADD CONSTRAINT sat_teklif_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sls_offer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sls_offer_detail sat_teklif_detaylari_stok_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer_detail
    ADD CONSTRAINT sat_teklif_detaylari_stok_kodu_fkey FOREIGN KEY (stock_code) REFERENCES public.stk_inventory(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sat_teklifler_islem_tipi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sat_teklifler_islem_tipi_id_fkey FOREIGN KEY (operation_type_id) REFERENCES public.einv_invoice_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sat_teklifler_musteri_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sat_teklifler_musteri_kodu_fkey FOREIGN KEY (customer_code) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sat_teklifler_musteri_temsilcisi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sat_teklifler_musteri_temsilcisi_id_fkey FOREIGN KEY (representative_id) REFERENCES public.emp_person(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sat_teklifler_nakliye_ucreti_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sat_teklifler_nakliye_ucreti_id_fkey FOREIGN KEY (transport_charge_id) REFERENCES public.einv_transport_price(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sat_teklifler_odeme_sekli_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sat_teklifler_odeme_sekli_id_fkey FOREIGN KEY (payment_method_id) REFERENCES public.einv_payment_method(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sat_teklifler_paket_tipi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sat_teklifler_paket_tipi_id_fkey FOREIGN KEY (packet_type_id) REFERENCES public.einv_packet_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_city_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_city_id_fk FOREIGN KEY (city_id) REFERENCES public.sys_city(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_country_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_country_id_fk FOREIGN KEY (country_id) REFERENCES public.sys_country(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_currency_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_currency_code_fk FOREIGN KEY (currency_code) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_delivery_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_delivery_type_id_fk FOREIGN KEY (delivery_method_id) REFERENCES public.einv_delivery_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer_detail sls_offer_detail_uom_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_offer_detail
    ADD CONSTRAINT sls_offer_detail_uom_code_fk FOREIGN KEY (uom) REFERENCES public.sys_uom(unit_code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_currency_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_currency_code_fk FOREIGN KEY (currency_code) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_customer_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_customer_code_fk FOREIGN KEY (customer_code) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order_detail sls_order_detail_header_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order_detail
    ADD CONSTRAINT sls_order_detail_header_id_fk FOREIGN KEY (header_id) REFERENCES public.sls_order(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sls_order_detail sls_order_detail_ref_main_product_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order_detail
    ADD CONSTRAINT sls_order_detail_ref_main_product_id_fk FOREIGN KEY (referans_ana_urun_id) REFERENCES public.sls_order_detail(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order_detail sls_order_detail_sku_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order_detail
    ADD CONSTRAINT sls_order_detail_sku_fk FOREIGN KEY (stok_kodu) REFERENCES public.stk_inventory(code) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: sls_order_detail sls_order_detail_uom_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order_detail
    ADD CONSTRAINT sls_order_detail_uom_code_fk FOREIGN KEY (uom_code) REFERENCES public.sys_uom(unit_code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_package_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_package_type_id_fk FOREIGN KEY (packet_type_id) REFERENCES public.einv_packet_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_payment_method_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_payment_method_id_fk FOREIGN KEY (payment_method_id) REFERENCES public.einv_payment_method(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_representative_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_representative_id_fk FOREIGN KEY (customer_representative_id) REFERENCES public.emp_person(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_shipping_cost_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_shipping_cost_id_fk FOREIGN KEY (transport_charge_id) REFERENCES public.einv_transport_price(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_trans_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_trans_type_id_fk FOREIGN KEY (operation_type_id) REFERENCES public.einv_invoice_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_image stk_image_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_image
    ADD CONSTRAINT stk_image_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.stk_inventory(id);


--
-- Name: stk_inventory stk_inventory_buy_currency_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_buy_currency_fk FOREIGN KEY (buying_currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_export_currency_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_export_currency_fk FOREIGN KEY (export_currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_group_id_fk FOREIGN KEY (group_id) REFERENCES public.stk_group(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_origin_country_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_origin_country_id_fk FOREIGN KEY (origin_id) REFERENCES public.sys_country(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_sell_currency_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_sell_currency_fk FOREIGN KEY (sales_currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory_summary stk_inventory_summary_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory_summary
    ADD CONSTRAINT stk_inventory_summary_inventory_id_fkey FOREIGN KEY (inventory_id) REFERENCES public.stk_inventory(id);


--
-- Name: stk_inventory stk_inventory_uom_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_uom_code_fk FOREIGN KEY (measurement_id) REFERENCES public.sys_uom(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_transaction stk_transaction_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_currency_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_transaction stk_transaction_from_warehouse_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_from_warehouse_fkey FOREIGN KEY (from_warehouse) REFERENCES public.stk_warehouse(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_transaction stk_transaction_stock_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_stock_code_fkey FOREIGN KEY (sku) REFERENCES public.stk_inventory(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_transaction stk_transaction_to_warehouse_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_to_warehouse_fkey FOREIGN KEY (to_warehouse) REFERENCES public.stk_warehouse(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sys_access_right sys_access_right_perm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_access_right
    ADD CONSTRAINT sys_access_right_perm_id_fkey FOREIGN KEY (permission_id) REFERENCES public.sys_permission(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_access_right sys_access_right_usr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_access_right
    ADD CONSTRAINT sys_access_right_usr_id_fkey FOREIGN KEY (user_id) REFERENCES public.sys_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_address sys_address_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_address
    ADD CONSTRAINT sys_address_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.sys_city(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sys_application_setting sys_app_set_addr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_application_setting
    ADD CONSTRAINT sys_app_set_addr_fkey FOREIGN KEY (address_id) REFERENCES public.sys_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sys_application_setting sys_app_set_curr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_application_setting
    ADD CONSTRAINT sys_app_set_curr_fkey FOREIGN KEY (app_currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sys_city sys_city_cid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_city
    ADD CONSTRAINT sys_city_cid_fkey FOREIGN KEY (country_id) REFERENCES public.sys_country(id) ON UPDATE SET NULL;


--
-- Name: sys_city sys_city_rid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_city
    ADD CONSTRAINT sys_city_rid_fkey FOREIGN KEY (region_id) REFERENCES public.sys_region(id) ON UPDATE SET NULL;


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
-- Name: sys_permission sys_perm_grp_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_permission
    ADD CONSTRAINT sys_perm_grp_fkey FOREIGN KEY (group_id) REFERENCES public.sys_permission_group(id) ON UPDATE CASCADE ON DELETE CASCADE;


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
-- Name: sys_uom sys_uom_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_uom
    ADD CONSTRAINT sys_uom_group_fkey FOREIGN KEY (group_id) REFERENCES public.sys_uom_group(id) ON UPDATE CASCADE ON DELETE SET NULL;


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
-- Name: sys_user sys_usr_prs_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_usr_prs_fkey FOREIGN KEY (person_id) REFERENCES public.emp_person(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT CREATE ON SCHEMA public TO PUBLIC;
GRANT ALL ON SCHEMA public TO ths_admin;


--
-- Name: FUNCTION audit(); Type: ACL; Schema: public; Owner: ths_admin
--

REVOKE ALL ON FUNCTION public.audit() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.audit() FROM ths_admin;


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
-- PostgreSQL database dump complete
--

\unrestrict fbJG9nzdeniDmL0d7I71HUFcQxZPsu9ZyZcljTyLIwBiHyjX7chjfg4dHO321a2

