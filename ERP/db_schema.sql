--
-- PostgreSQL database dump
--

\restrict ZpPUuugecgpTkApB7lMZtpCKyQekz1UMzsKXlawg1mxGberxJ5iVqafHgWz1iR7

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
		(SELECT format('INSERT INTO public.audit(
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
    e_invoice_package_name character varying(128),
    is_passive boolean DEFAULT false CONSTRAINT acc_acc_passive_nn NOT NULL
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
    journal_date date
);


ALTER TABLE public.acc_voucher OWNER TO ths_admin;

--
-- Name: acc_voucher_detail; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.acc_voucher_detail (
    id bigint CONSTRAINT mhs_fis_detaylari_id_not_null NOT NULL,
    acc_voucher_id bigint CONSTRAINT mhs_fis_detaylari_header_id_not_null NOT NULL
);


ALTER TABLE public.acc_voucher_detail OWNER TO ths_admin;

--
-- Name: audit; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.audit (
    id bigint CONSTRAINT audits_id_not_null NOT NULL,
    user_name character varying CONSTRAINT audits_user_name_not_null NOT NULL,
    ip_address character varying(32) CONSTRAINT audits_ip_address_not_null NOT NULL,
    table_name character varying CONSTRAINT audits_table_name_not_null NOT NULL,
    access_type character varying(1) CONSTRAINT audits_access_type_not_null NOT NULL,
    time_of_change timestamp without time zone CONSTRAINT audits_time_of_change_not_null NOT NULL,
    row_id bigint CONSTRAINT audits_row_id_not_null NOT NULL,
    client_username character varying,
    old_val text,
    new_val text
);


ALTER TABLE public.audit OWNER TO ths_admin;

--
-- Name: audit_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.audit ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
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
    route double precision[]
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
    CONSTRAINT fin_credit_card_transaction_installment_check CHECK ((((installment_count >= 1) AND (installment_count <= 36)) AND ((transaction_type = 1) OR (installment_count = 1)))),
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
    CONSTRAINT pur_invoice_due_date_check CHECK (((due_date IS NULL) OR (due_date >= invoice_date))),
    CONSTRAINT pur_invoice_exchange_rate_check CHECK ((exchange_rate > (0)::numeric))
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
    CONSTRAINT pur_order_delivery_date_check CHECK (((delivery_date IS NULL) OR (delivery_date >= order_date))),
    CONSTRAINT pur_order_exchange_rate_check CHECK ((exchange_rate > (0)::numeric)),
    CONSTRAINT pur_order_payment_term_check CHECK (((payment_term_days >= 0) AND (payment_term_days <= 365))),
    CONSTRAINT pur_order_status_check CHECK (((status >= 1) AND (status <= 5)))
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
    description character varying(256)
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
    vat_rate numeric(5,2) DEFAULT 0 NOT NULL,
    raw_material_stock_account character varying(16),
    raw_material_usage_account character varying(16),
    semi_product_account character varying(16),
    CONSTRAINT stk_group_vat_rate_check CHECK (((vat_rate >= (0)::numeric) AND (vat_rate <= (100)::numeric)))
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
    CONSTRAINT stk_transaction_is_opening_check CHECK (((NOT is_opening) OR (transaction_type = 1))),
    CONSTRAINT stk_transaction_pur_receipt_check CHECK (((pur_receipt_detail_id IS NULL) OR (transaction_type = 1))),
    CONSTRAINT stk_transaction_quantity_check CHECK ((quantity > (0)::numeric)),
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
    hs_no character varying(16),
    diib_product_description character varying(64),
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
    CONSTRAINT stk_inventory_buying_discount_check CHECK (((buying_discount >= (0)::numeric) AND (buying_discount <= (100)::numeric))),
    CONSTRAINT stk_inventory_sales_discount_check CHECK (((sales_discount >= (0)::numeric) AND (sales_discount <= (100)::numeric))),
    CONSTRAINT stk_inventory_vat_rate_check CHECK (((vat_rate IS NULL) OR ((vat_rate >= (0)::numeric) AND (vat_rate <= (100)::numeric))))
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
    sys_country_id bigint,
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
    exchange_rate smallint DEFAULT 0 NOT NULL
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
    c.accountant_authorized,
    l.locale
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
    rate,
    currency
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
    journal_no,
    journal_date
   FROM public.acc_voucher v;


ALTER VIEW public.vw_acc_voucher OWNER TO ths_admin;

--
-- Name: vw_acc_voucher_detail; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_acc_voucher_detail AS
 SELECT d.id,
    d.acc_voucher_id,
    v.journal_no
   FROM (public.acc_voucher_detail d
     LEFT JOIN public.acc_voucher v ON ((v.id = d.acc_voucher_id)));


ALTER VIEW public.vw_acc_voucher_detail OWNER TO ths_admin;

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
    car_name
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
    p.quantity
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
    round((bl.quantity * l.unit_price), 6) AS total_amount
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
    bp.quantity
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
    bp.quantity
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
    round(((r.quantity * (100)::numeric) / ((100)::numeric - r.scrap_rate)), 6) AS gross_quantity
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
    round((d.quantity * l.unit_price), 6) AS total_amount
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
    d.quantity
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
    f.description
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
    o.description
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
    p.description
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
    d.description
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
    d.description
   FROM (((public.pur_request_detail d
     JOIN public.pur_request r ON ((r.id = d.pur_request_id)))
     JOIN public.stk_inventory i ON ((i.id = d.stk_inventory_id)))
     LEFT JOIN public.sys_uom u ON ((u.id = i.sys_uom_id)));


ALTER VIEW public.vw_pur_request_detail OWNER TO ths_admin;

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
    i.hs_no,
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
   FROM (((((((((public.stk_inventory i
     CROSS JOIN public.sys_language l)
     LEFT JOIN public.stk_group g ON ((g.id = i.stk_group_id)))
     LEFT JOIN public.acc_set_tax_rate tr ON ((tr.tax_rate = COALESCE(i.vat_rate, g.vat_rate))))
     LEFT JOIN public.sys_uom u ON ((u.id = i.sys_uom_id)))
     LEFT JOIN public.sys_uom_translation ut ON (((ut.sys_uom_id = u.id) AND (ut.sys_language_id = l.id))))
     LEFT JOIN public.stk_product_type pt ON ((pt.id = i.stk_product_type_id)))
     LEFT JOIN public.sys_country c ON ((c.id = i.sys_country_id)))
     LEFT JOIN public.sys_country_translation ct ON (((ct.sys_country_id = c.id) AND (ct.sys_language_id = l.id))))
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
-- Name: vw_sys_city; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_city AS
 SELECT ct.id,
    ct.city_name,
    ct.car_plate_code,
    ct.sys_country_id,
    ct.sys_region_id,
    cn.country_code,
    cnt.country_name,
    r.region_name,
    l.locale
   FROM ((((public.sys_city ct
     LEFT JOIN public.sys_country cn ON ((cn.id = ct.sys_country_id)))
     LEFT JOIN public.sys_country_translation cnt ON ((cnt.sys_country_id = ct.sys_country_id)))
     LEFT JOIN public.sys_region r ON ((r.id = ct.sys_region_id)))
     LEFT JOIN public.sys_language l ON ((cnt.sys_language_id = l.id)))
  WHERE (1 = 1);


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
    cnt.country_name,
    l.locale
   FROM ((public.sys_country cn
     LEFT JOIN public.sys_country_translation cnt ON ((cnt.sys_country_id = cn.id)))
     LEFT JOIN public.sys_language l ON ((l.id = cnt.sys_language_id)));


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
-- Name: vw_sys_permission_group; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_permission_group AS
 SELECT pg.id,
    pg.permission_group_key,
    pgt.permission_group_name,
    l.locale
   FROM ((public.sys_permission_group pg
     LEFT JOIN public.sys_permission_group_translation pgt ON ((pgt.sys_permission_group_id = pg.id)))
     LEFT JOIN public.sys_language l ON ((l.id = pgt.sys_language_id)));


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
    ut.uom_name,
    ug.uom_group_key,
    l.locale
   FROM ((((public.sys_uom u
     LEFT JOIN public.sys_uom_group ug ON ((ug.id = u.sys_uom_group_id)))
     LEFT JOIN public.sys_uom_translation ut ON ((ut.sys_uom_id = u.id)))
     LEFT JOIN public.sys_uom_group_translation ugt ON (((ugt.sys_uom_group_id = u.sys_uom_group_id) AND (ugt.sys_language_id = ut.sys_language_id))))
     LEFT JOIN public.sys_language l ON ((l.id = ut.sys_language_id)));


ALTER VIEW public.vw_sys_uom OWNER TO ths_admin;

--
-- Name: vw_sys_uom_group; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.vw_sys_uom_group AS
 SELECT ut.id,
    ut.uom_group_key,
    utt.uom_group_name,
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
    u.user_password,
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
-- Name: pur_offer_detail id; Type: DEFAULT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_offer_detail ALTER COLUMN id SET DEFAULT nextval('public.pur_offer_detail_id_seq'::regclass);


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
-- Name: audit audit_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.audit
    ADD CONSTRAINT audit_pkey PRIMARY KEY (id);


--
-- Name: einv_delivery_type einv_delivery_type_delivery_code_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.einv_delivery_type
    ADD CONSTRAINT einv_delivery_type_delivery_code_key UNIQUE (delivery_method);


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
    ADD CONSTRAINT prd_bom_by_product_inventory_key UNIQUE (prd_bom_id, stk_inventory_id);


--
-- Name: prd_bom_by_product prd_bom_by_product_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_by_product
    ADD CONSTRAINT prd_bom_by_product_pkey PRIMARY KEY (id);


--
-- Name: prd_bom_labour prd_bom_labour_labour_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_labour
    ADD CONSTRAINT prd_bom_labour_labour_key UNIQUE (prd_bom_id, prd_labour_id);


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
-- Name: prd_bom_packet_labour prd_bom_packet_labour_packet_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_labour
    ADD CONSTRAINT prd_bom_packet_labour_packet_key UNIQUE (prd_bom_id, prd_packet_labour_id);


--
-- Name: prd_bom_packet_labour prd_bom_packet_labour_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_labour
    ADD CONSTRAINT prd_bom_packet_labour_pkey PRIMARY KEY (id);


--
-- Name: prd_bom_packet_raw prd_bom_packet_raw_packet_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prd_bom_packet_raw
    ADD CONSTRAINT prd_bom_packet_raw_packet_key UNIQUE (prd_bom_id, prd_packet_raw_id);


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
    ADD CONSTRAINT prd_bom_raw_inventory_key UNIQUE (prd_bom_id, stk_inventory_id);


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
    ADD CONSTRAINT prd_packet_labour_detail_labour_key UNIQUE (prd_packet_labour_id, prd_labour_id);


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
    ADD CONSTRAINT prd_packet_raw_detail_inventory_key UNIQUE (prd_packet_raw_id, stk_inventory_id);


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
    ADD CONSTRAINT pur_invoice_detail_line_key UNIQUE (pur_invoice_id, line_no);


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
-- Name: pur_order_detail pur_order_detail_line_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.pur_order_detail
    ADD CONSTRAINT pur_order_detail_line_key UNIQUE (pur_order_id, line_no);


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
    ADD CONSTRAINT pur_request_detail_inventory_key UNIQUE (pur_request_id, stk_inventory_id);


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
-- Name: stk_card_kind_info_stk_kind_property_id_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX stk_card_kind_info_stk_kind_property_id_idx ON public.stk_card_kind_info USING btree (stk_kind_property_id);


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
-- Name: sys_permission_template_right_permission_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sys_permission_template_right_permission_idx ON public.sys_permission_template_right USING btree (sys_permission_id);


--
-- Name: sys_user_permission_template_template_idx; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX sys_user_permission_template_template_idx ON public.sys_user_permission_template USING btree (sys_permission_template_id);


--
-- Name: emp_section audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.emp_section FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: sys_access_right audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.sys_access_right FOR EACH ROW EXECUTE FUNCTION public.audit();


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
    ADD CONSTRAINT sat_teklifler_musteri_temsilcisi_id_fkey FOREIGN KEY (representative_id) REFERENCES public.emp_employee(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
    ADD CONSTRAINT sls_order_representative_id_fk FOREIGN KEY (customer_representative_id) REFERENCES public.emp_employee(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
    ADD CONSTRAINT sys_city_sys_country_id_fkey FOREIGN KEY (sys_country_id) REFERENCES public.sys_country(id) ON UPDATE SET NULL;


--
-- Name: sys_city sys_city_sys_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_city
    ADD CONSTRAINT sys_city_sys_region_id_fkey FOREIGN KEY (sys_region_id) REFERENCES public.sys_region(id) ON UPDATE SET NULL;


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

\unrestrict ZpPUuugecgpTkApB7lMZtpCKyQekz1UMzsKXlawg1mxGberxJ5iVqafHgWz1iR7

