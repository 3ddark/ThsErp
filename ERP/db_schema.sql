--
-- PostgreSQL database dump
--

\restrict F2nAKi9LLYA1aSIGOYqnQ9SdDCMaUgdLnug7B6gWTbowv7HjfEskCGgEP0D22Qc

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
-- Name: acc_default_currency(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.acc_default_currency() RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE v_id BIGINT;
BEGIN
    SELECT id INTO v_id FROM public.sys_currency WHERE is_default = true LIMIT 1;
    RETURN COALESCE(v_id, (SELECT id FROM public.sys_currency ORDER BY id LIMIT 1));
END;
$$;


--
-- Name: audit(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: emp_person_full_name(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.emp_person_full_name() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    result TEXT;
BEGIN
    SELECT COALESCE(p.full_name, p.name || ' ' || p.surname) INTO result
    FROM public.emp_person p
    WHERE p.id = (SELECT su.person_id FROM public.sys_user su LIMIT 1);
    RETURN result;
END;
$$;


--
-- Name: fn_default_product_type_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_default_product_type_id() RETURNS integer
    LANGUAGE sql
    AS $$ SELECT id FROM stk_product_type WHERE product_type_name='HAMMADDE'; $$;


--
-- Name: fn_get_by_product_cost(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_by_product_cost(p_recipe_id bigint) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE v_total NUMERIC := 0;
BEGIN
    SELECT COALESCE(SUM(bp.quantity * si.average_cost), 0) INTO v_total
    FROM public.prd_bom_by_product bp JOIN public.stk_inventory si ON si.code = bp.product_sku
    WHERE bp.header_id = p_recipe_id;
    RETURN v_total;
END;
$$;


--
-- Name: fn_get_lang_text(text, text, text, bigint, text); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: fn_get_lang_text(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: fn_get_recipe_labour_cost(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_recipe_labour_cost(p_recipe_id bigint) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE v_total NUMERIC := 0;
BEGIN
    SELECT COALESCE(SUM(pl.quantity * pl.unit_price), 0) INTO v_total
    FROM public.prd_bom_labour pl WHERE pl.header_id = p_recipe_id;
    RETURN v_total;
END;
$$;


--
-- Name: fn_get_recipe_raw_material_cost(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_recipe_raw_material_cost(p_recipe_id bigint) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE v_total NUMERIC := 0;
BEGIN
    SELECT COALESCE(SUM(pr.quantity * si.average_cost), 0) INTO v_total
    FROM public.prd_bom_raw pr JOIN public.stk_inventory si ON si.code = pr.sku_code
    WHERE pr.recete_id = p_recipe_id;
    RETURN v_total;
END;
$$;


--
-- Name: fn_get_recipe_total(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_recipe_total(p_recipe_id bigint) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE v_raw_cost NUMERIC; v_labour_cost NUMERIC; v_by_product_discount NUMERIC;
BEGIN
    SELECT fn_get_recipe_raw_material_cost(p_recipe_id) INTO v_raw_cost;
    SELECT fn_get_recipe_labour_cost(p_recipe_id) INTO v_labour_cost;
    SELECT COALESCE(fn_get_by_product_cost(p_recipe_id), 0) INTO v_by_product_discount;
    RETURN v_raw_cost + v_labour_cost - v_by_product_discount;
END;
$$;


--
-- Name: fn_get_sys_kalite_form_no(text, bigint); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: fn_get_sys_lang_id(text); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: fn_get_sys_quality_form_type_id(integer); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: fn_get_table_data_dynamic(character varying); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: table_listen(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.table_listen(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT listen table_name;
  RETURN;
END;
$$;


--
-- Name: table_notify(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: table_notify(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.table_notify(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT notify table_name;
  RETURN;
END;
$$;


--
-- Name: table_unlisten(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.table_unlisten(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT unlisten table_name;
  RETURN;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: acc_account; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acc_account (
    id bigint CONSTRAINT acc_acc_id_nn NOT NULL,
    code character varying(16) CONSTRAINT acc_acc_code_nn NOT NULL,
    name character varying(128) CONSTRAINT acc_acc_name_nn NOT NULL,
    type_id bigint CONSTRAINT acc_acc_type_nn NOT NULL,
    group_id bigint,
    region_id bigint,
    taxpayer_type smallint,
    taxpayer_name character varying(32),
    taxpayer_name2 character varying(32),
    taxpayer_surname character varying(32),
    tax_office character varying(64),
    tax_no character varying(32),
    iban character varying(64),
    iban_currency character varying(3),
    nace_code character varying(32),
    authorized_person_1 character varying(64),
    authorized_phone_1 character varying(32),
    authorized_person_2 character varying(64),
    authorized_phone_2 character varying(32),
    authorized_person_3 character varying(64),
    authorized_phone_3 character varying(32),
    fax character varying(32),
    accountant_phone character varying(32),
    accountant_email character varying(128),
    accountant_authorized character varying(32),
    notes character varying(512),
    root_code character varying(3),
    sub_code character varying(8),
    discount_rate numeric(5,2) DEFAULT 0,
    e_invoice_active boolean DEFAULT false CONSTRAINT acc_acc_einv_nn NOT NULL,
    e_invoice_package_name character varying(128),
    address_id bigint,
    is_passive boolean DEFAULT false CONSTRAINT acc_acc_passive_nn NOT NULL
);


--
-- Name: acc_account_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: acc_account_plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acc_account_plan (
    id bigint CONSTRAINT acc_aplan_id_nn NOT NULL,
    code character varying(16) CONSTRAINT acc_aplan_code_nn NOT NULL,
    name character varying(128) CONSTRAINT acc_aplan_name_nn NOT NULL,
    level smallint CONSTRAINT acc_aplan_level_nn NOT NULL
);


--
-- Name: acc_account_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: acc_bank; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acc_bank (
    id bigint CONSTRAINT acc_bank_id_nn NOT NULL,
    name character varying(64) CONSTRAINT acc_bank_name_nn NOT NULL,
    swift_code character varying(16)
);


--
-- Name: acc_bank_branch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acc_bank_branch (
    id bigint CONSTRAINT acc_branch_id_nn NOT NULL,
    bank_id bigint CONSTRAINT acc_branch_bank_nn NOT NULL,
    code integer CONSTRAINT acc_branch_code_nn NOT NULL,
    name character varying(64) CONSTRAINT acc_branch_name_nn NOT NULL,
    city_id bigint CONSTRAINT acc_branch_city_nn NOT NULL
);


--
-- Name: acc_bank_branch_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: acc_bank_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: acc_exchange_rate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acc_exchange_rate (
    id bigint CONSTRAINT acc_er_id_nn NOT NULL,
    rate_date date CONSTRAINT acc_er_date_nn NOT NULL,
    rate numeric(10,4) CONSTRAINT acc_er_rate_nn NOT NULL,
    currency character varying(3)
);


--
-- Name: acc_exchange_rate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.acc_exchange_rate ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.acc_exchange_rate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: acc_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acc_group (
    id bigint CONSTRAINT acc_group_id_nn NOT NULL,
    name character varying(16) CONSTRAINT acc_group_name_nn NOT NULL
);


--
-- Name: acc_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: acc_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acc_region (
    id bigint CONSTRAINT acc_region_id_nn NOT NULL,
    name character varying(32) CONSTRAINT acc_region_name_nn NOT NULL
);


--
-- Name: acc_region_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: acc_set_account_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acc_set_account_type (
    id bigint CONSTRAINT acc_set_at_id_nn NOT NULL,
    name character varying(16) CONSTRAINT acc_set_at_name_nn NOT NULL
);


--
-- Name: acc_set_account_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: acc_set_company_legal_form; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acc_set_company_legal_form (
    id bigint CONSTRAINT acc_clf_id_nn NOT NULL,
    ownership_id bigint CONSTRAINT acc_clf_own_nn NOT NULL,
    name character varying(48) CONSTRAINT acc_clf_name_nn NOT NULL
);


--
-- Name: acc_set_company_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: acc_set_ownership_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acc_set_ownership_type (
    id bigint CONSTRAINT acc_otn_id_nn NOT NULL,
    name character varying(32) CONSTRAINT acc_otn_name_nn NOT NULL
);


--
-- Name: acc_set_legal_form_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: acc_set_tax_rate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acc_set_tax_rate (
    id bigint CONSTRAINT acc_set_tr_id_nn NOT NULL,
    tax_rate numeric(5,2) CONSTRAINT acc_set_tr_vrate_nn NOT NULL,
    sales_account character varying(16) CONSTRAINT acc_set_tr_sa_nn NOT NULL,
    sales_return_account character varying(16) CONSTRAINT acc_set_tr_sr_nn NOT NULL,
    purchase_account character varying(16) CONSTRAINT acc_set_tr_pa_nn NOT NULL,
    purchase_return_account character varying(16) CONSTRAINT acc_set_tr_pr_nn NOT NULL
);


--
-- Name: acc_set_tax_rate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: acc_transfer_code; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acc_transfer_code (
    id bigint CONSTRAINT acc_transfer_code_id_nn NOT NULL,
    transfer_code character varying(32) CONSTRAINT acc_transfer_code_code_nn NOT NULL,
    description character varying(128) CONSTRAINT acc_transfer_code_description_nn NOT NULL,
    account character varying(16) CONSTRAINT acc_transfer_code_account_nn NOT NULL
);


--
-- Name: acc_transfer_code_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.acc_transfer_code ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.acc_transfer_code_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: acc_voucher; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acc_voucher (
    id bigint CONSTRAINT acc_voucher_id_nn NOT NULL,
    journal_no integer CONSTRAINT acc_voucher_journal_no_nn NOT NULL,
    journal_date date
);


--
-- Name: acc_voucher_detail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acc_voucher_detail (
    id bigint CONSTRAINT acc_voucher_detail_id_nn NOT NULL,
    header_id bigint CONSTRAINT acc_voucher_detail_header_nn NOT NULL
);


--
-- Name: acc_voucher_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.acc_voucher_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.acc_voucher_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: acc_voucher_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.acc_voucher ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.acc_voucher_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: audit; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: audit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: einv_delivery_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.einv_delivery_type (
    id bigint CONSTRAINT einv_delivery_type_id_nn NOT NULL,
    delivery_method character varying(16) CONSTRAINT einv_delivery_type_delivery_code_nn NOT NULL,
    description character varying(96) CONSTRAINT einv_delivery_type_description_nn NOT NULL,
    is_einvoice boolean DEFAULT false
);


--
-- Name: einv_delivery_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: einv_invoice_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.einv_invoice_type (
    id bigint CONSTRAINT einv_invoice_type_id_nn NOT NULL,
    invoice_type_code character varying(32) CONSTRAINT einv_invoice_type_code_nn NOT NULL
);


--
-- Name: einv_invoice_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: einv_packet_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.einv_packet_type (
    id bigint CONSTRAINT einv_packet_type_id_nn NOT NULL,
    code character varying(2),
    packet_type_code character varying(128),
    description character varying(512)
);


--
-- Name: einv_packet_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: einv_payment_method; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.einv_payment_method (
    id bigint CONSTRAINT einv_payment_method_id_nn NOT NULL,
    payment_method_code character varying(96),
    code character varying(16),
    description character varying(512),
    is_einvoice boolean DEFAULT false
);


--
-- Name: einv_payment_method_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: einv_transport_price; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.einv_transport_price (
    id bigint CONSTRAINT einv_transport_price_id_nn NOT NULL,
    transport_charge character varying(16)
);


--
-- Name: einv_transport_price_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: emp_driver_ability; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emp_driver_ability (
    id bigint CONSTRAINT prs_driver_abilities_id_not_null NOT NULL,
    driver_license_id bigint,
    person_id bigint
);


--
-- Name: emp_driver_license_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.emp_driver_ability ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.emp_driver_license_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: emp_driver_license_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emp_driver_license_type (
    id bigint CONSTRAINT prs_set_dlt_id_nn NOT NULL,
    license_name character varying(32) CONSTRAINT prs_set_dlt_nname_nn NOT NULL
);


--
-- Name: emp_driver_license_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.emp_driver_license_type ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.emp_driver_license_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: emp_language; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emp_language (
    id bigint CONSTRAINT prs_set_lng_id_nn NOT NULL,
    language_name character varying(16) CONSTRAINT prs_set_lng_nname_nn NOT NULL
);


--
-- Name: emp_person_language_ability; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emp_person_language_ability (
    id bigint CONSTRAINT prs_language_abilities_id_not_null NOT NULL,
    language_id bigint,
    read_id bigint,
    write_id bigint,
    speak_id bigint,
    person_id bigint
);


--
-- Name: emp_language_ability_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.emp_person_language_ability ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.emp_language_ability_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: emp_language_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.emp_language ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.emp_language_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: emp_language_level; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emp_language_level (
    id bigint CONSTRAINT prs_set_lll_id_nn NOT NULL,
    language_level character varying(16) CONSTRAINT prs_set_lll_lname_nn NOT NULL
);


--
-- Name: emp_language_level_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.emp_language_level ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.emp_language_level_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: emp_person; Type: TABLE; Schema: public; Owner: -
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
    address_id bigint,
    active boolean DEFAULT false CONSTRAINT prs_persons_active_not_null NOT NULL
);


--
-- Name: COLUMN emp_person.gender; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.emp_person.gender IS '1 Man, 2 Woman';


--
-- Name: COLUMN emp_person.military_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.emp_person.military_status IS '1 Did, 2 Exempt, 3 Did Not';


--
-- Name: COLUMN emp_person.marital_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.emp_person.marital_status IS '1 Married, 2 Single';


--
-- Name: emp_person_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.emp_person ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.emp_person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: emp_person_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emp_person_type (
    id bigint CONSTRAINT prs_set_ptp_id_nn NOT NULL,
    person_type character varying(32) CONSTRAINT prs_set_ptp_pname_nn NOT NULL
);


--
-- Name: emp_person_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.emp_person_type ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.emp_person_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: emp_section; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emp_section (
    id bigint CONSTRAINT prs_set_sec_id_nn NOT NULL,
    section_name character varying(32) CONSTRAINT prs_set_sec_nname_nn NOT NULL
);


--
-- Name: emp_section_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.emp_section ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.emp_section_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: emp_task; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emp_task (
    id bigint CONSTRAINT prs_set_tsk_id_nn NOT NULL,
    task_name character varying(32) CONSTRAINT prs_set_tsk_nname_nn NOT NULL
);


--
-- Name: emp_task_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.emp_task ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.emp_task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: emp_transportation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emp_transportation (
    id bigint CONSTRAINT prs_set_trans_id_nn NOT NULL,
    car_no smallint CONSTRAINT prs_set_trans_cno_nn NOT NULL,
    car_name character varying(32) CONSTRAINT prs_set_trans_cname_nn NOT NULL,
    route double precision[]
);


--
-- Name: emp_transportation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.emp_transportation ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.emp_transportation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: emp_unit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emp_unit (
    id bigint CONSTRAINT prs_set_unit_id_nn NOT NULL,
    unit_name character varying(32) CONSTRAINT prs_set_unit_nname_nn NOT NULL,
    section_id bigint
);


--
-- Name: emp_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.emp_unit ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.emp_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prd_bom; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prd_bom (
    id bigint CONSTRAINT prd_bom_id_nn NOT NULL,
    product_sku character varying(32) CONSTRAINT prd_bom_product_sku_nn NOT NULL,
    product_name character varying(128) CONSTRAINT prd_bom_product_name_nn NOT NULL,
    sample_quantity numeric(18,6) DEFAULT 1,
    description character varying(128)
);


--
-- Name: prd_bom_by_product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prd_bom_by_product (
    id bigint CONSTRAINT prd_bom_by_product_id_nn NOT NULL,
    header_id bigint CONSTRAINT prd_bom_by_product_header_nn NOT NULL,
    product_sku character varying(32) CONSTRAINT prd_bom_by_product_sku_nn NOT NULL,
    quantity numeric(18,6) CONSTRAINT prd_bom_by_product_qty_nn NOT NULL
);


--
-- Name: prd_bom_labour; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prd_bom_labour (
    id bigint CONSTRAINT prd_bom_labour_id_nn NOT NULL,
    header_id bigint CONSTRAINT prd_bom_labour_header_nn NOT NULL,
    labor_code character varying(16) CONSTRAINT prd_bom_labour_labor_code_nn NOT NULL,
    quantity numeric(18,6) CONSTRAINT prd_bom_labour_qty_nn NOT NULL
);


--
-- Name: prd_bom_packet_labour; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prd_bom_packet_labour (
    id bigint CONSTRAINT prd_bom_packet_labour_id_nn NOT NULL,
    header_id bigint CONSTRAINT prd_bom_packet_labour_header_nn NOT NULL,
    package_id bigint CONSTRAINT urt_recete_paket_iscilikler_paket_id_not_null NOT NULL,
    quantity numeric(18,6)
);


--
-- Name: prd_bom_packet_raw; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prd_bom_packet_raw (
    id bigint CONSTRAINT prd_bom_packet_raw_id_nn NOT NULL,
    header_id bigint CONSTRAINT prd_bom_packet_raw_header_nn NOT NULL,
    package_id bigint CONSTRAINT urt_recete_paket_hammaddeler_paket_id_not_null NOT NULL,
    quantity numeric(18,6)
);


--
-- Name: prd_bom_raw; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prd_bom_raw (
    id bigint CONSTRAINT prd_bom_raw_id_nn NOT NULL,
    header_id bigint CONSTRAINT prd_bom_raw_header_nn NOT NULL,
    recete_id bigint,
    sku_code character varying(32) CONSTRAINT prd_bom_raw_sku_nn NOT NULL,
    quantity numeric(18,6) CONSTRAINT prd_bom_raw_qty_nn NOT NULL,
    scrap_rate numeric(18,6) DEFAULT 0 CONSTRAINT prd_bom_raw_scrap_rate_nn NOT NULL
);


--
-- Name: prd_labour; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prd_labour (
    id bigint CONSTRAINT prd_labour_id_nn NOT NULL,
    cost_code character varying(16) CONSTRAINT prd_labour_cost_code_nn NOT NULL,
    cost_name character varying(128),
    unit_price numeric(18,6) CONSTRAINT prd_labour_price_nn NOT NULL,
    uom_code character varying(8) CONSTRAINT prd_labour_unit_nn NOT NULL,
    cost_type smallint CONSTRAINT prd_labour_cost_type_nn NOT NULL
);


--
-- Name: prd_packet_labour; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prd_packet_labour (
    id bigint CONSTRAINT prd_packet_labour_id_nn NOT NULL,
    package_name character varying(128) CONSTRAINT prd_packet_labour_package_name_nn NOT NULL
);


--
-- Name: prd_packet_labour_detail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prd_packet_labour_detail (
    id bigint CONSTRAINT prd_packet_labour_detail_id_nn NOT NULL,
    header_id bigint CONSTRAINT prd_packet_labour_detail_header_nn NOT NULL,
    labor_code character varying(32) CONSTRAINT prd_packet_labour_detail_labor_code_nn NOT NULL,
    quantity numeric(18,6) CONSTRAINT prd_packet_labour_detail_qty_nn NOT NULL
);


--
-- Name: prd_packet_raw; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prd_packet_raw (
    id bigint CONSTRAINT urt_paket_hammaddeler_id_not_null NOT NULL,
    package_name character varying(128) CONSTRAINT urt_paket_hammaddeler_paket_adi_not_null NOT NULL
);


--
-- Name: prd_packet_raw_detail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prd_packet_raw_detail (
    id bigint CONSTRAINT prd_packet_raw_detail_id_nn NOT NULL,
    header_id bigint CONSTRAINT prd_packet_raw_detail_header_nn NOT NULL,
    recete_id bigint,
    sku_code character varying(32) CONSTRAINT prd_packet_raw_detail_sku_nn NOT NULL,
    quantity numeric(18,6) CONSTRAINT prd_packet_raw_detail_qty_nn NOT NULL
);


--
-- Name: pur_offer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pur_offer (
    id bigint CONSTRAINT pur_offer_id_nn NOT NULL,
    order_id bigint,
    delivery_note_id bigint,
    invoice_id bigint,
    is_confirmed boolean CONSTRAINT pur_offer_is_confirmed_nn NOT NULL,
    total_amount numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_total_amount_nn NOT NULL,
    discount_amount numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_discount_amount_nn NOT NULL,
    ara_toplam numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_subtotal_nn NOT NULL,
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
    genel_toplam numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_grand_total_nn NOT NULL,
    operation_type_id bigint,
    offer_number character varying(16) CONSTRAINT pur_offer_number_nn NOT NULL,
    offer_date date CONSTRAINT pur_offer_date_nn NOT NULL,
    validity_date date CONSTRAINT pur_offer_validity_nn NOT NULL,
    customer_code character varying(16),
    customer_name character varying(128),
    tax_office character varying(32) CONSTRAINT pur_offer_tax_office_nn NOT NULL,
    tax_number character varying(32) CONSTRAINT pur_offer_tax_number_nn NOT NULL,
    country_id bigint,
    city_id bigint,
    district character varying(64),
    neighborhood character varying(64),
    district_area character varying(64),
    avenue character varying(64),
    street character varying(64),
    building_name character varying(64),
    door_number character varying(16),
    postal_code character varying(16),
    web character varying(64),
    email character varying(128),
    customer_representative character varying(64),
    contact_name character varying(32),
    contact_phone character varying(24),
    reference character varying(128),
    currency_code character varying(3) CONSTRAINT pur_offer_currency_code_nn NOT NULL,
    exchange_rate_usd numeric(7,4) DEFAULT 1,
    exchange_rate_eur numeric(7,4) DEFAULT 1,
    description character varying(128),
    withholding_code character varying(8),
    withholding_description character varying(128),
    withholding_share smallint,
    withholding_denominator smallint
);


--
-- Name: pur_offer_detail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pur_offer_detail (
    id bigint CONSTRAINT pur_offer_detail_id_nn NOT NULL,
    header_id bigint,
    order_detail_id bigint,
    delivery_note_detail_id bigint,
    invoice_detail_id bigint,
    sku_code character varying(32),
    stock_description character varying(128),
    user_description character varying(128),
    reference character varying(128),
    quantity double precision DEFAULT 1 CONSTRAINT pur_offer_detail_quantity_nn NOT NULL,
    uom_code character varying(8),
    discount_rate numeric(6,3) DEFAULT 0,
    tax_rate integer DEFAULT 0,
    unit_price numeric(18,6) DEFAULT 0,
    net_unit_price numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_detail_net_price_nn NOT NULL,
    amount numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_detail_amount_nn NOT NULL,
    discount_amount numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_detail_discount_amount_nn NOT NULL,
    net_amount numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_detail_net_amount_nn NOT NULL,
    tax_amount numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_detail_tax_amount_nn NOT NULL,
    total_amount numeric(18,6) DEFAULT 0 CONSTRAINT pur_offer_detail_total_amount_nn NOT NULL,
    is_main_product boolean DEFAULT false CONSTRAINT pur_offer_detail_main_product_nn NOT NULL,
    reference_main_product_id bigint,
    hs_code character varying(16),
    origin_country_name character varying(128)
);


--
-- Name: pur_offer_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pur_offer_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pur_offer_detail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pur_offer_detail_id_seq OWNED BY public.pur_offer_detail.id;


--
-- Name: pur_offer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: sls_dispatch_detail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sls_dispatch_detail (
    id bigint CONSTRAINT sls_delivery_note_detail_id_nn NOT NULL,
    header_id bigint,
    offer_detail_id bigint,
    order_detail_id bigint,
    invoice_detail_id bigint
);


--
-- Name: sls_delivery_note_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: sls_dispatch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sls_dispatch (
    id bigint CONSTRAINT sls_delivery_note_id_nn NOT NULL,
    delivery_note_number character varying(16),
    delivery_note_date timestamp without time zone,
    offer_id bigint,
    order_id bigint,
    invoice_id bigint
);


--
-- Name: sls_delivery_note_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: sls_invoice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sls_invoice (
    id bigint CONSTRAINT sls_invoice_id_nn NOT NULL,
    invoice_number character varying(16),
    invoice_date timestamp without time zone,
    offer_id bigint,
    order_id bigint,
    delivery_note_id bigint
);


--
-- Name: sls_invoice_detail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sls_invoice_detail (
    id bigint CONSTRAINT sls_invoice_detail_id_nn NOT NULL,
    header_id bigint,
    offer_detail_id bigint,
    order_detail_id bigint,
    delivery_note_detail_id bigint
);


--
-- Name: sls_invoice_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: sls_invoice_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: sls_offer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sls_offer (
    id bigint CONSTRAINT sls_offer_id_nn NOT NULL,
    order_id bigint,
    delivery_note_id bigint,
    invoice_id bigint,
    is_confirmed boolean CONSTRAINT sls_offer_is_confirmed_nn NOT NULL,
    total_amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_offer_total_amount_nn NOT NULL,
    discount_amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_offer_discount_amount_nn NOT NULL,
    ara_toplam numeric(18,6) DEFAULT 0 CONSTRAINT sls_offer_subtotal_nn NOT NULL,
    tax_rate_1 integer DEFAULT 0 CONSTRAINT sls_offer_tax_rate_1_nn NOT NULL,
    tax_amount_1 numeric(18,6) DEFAULT 0 CONSTRAINT sls_offer_tax_amount_1_nn NOT NULL,
    tax_rate_2 integer DEFAULT 0 CONSTRAINT sls_offer_tax_rate_2_nn NOT NULL,
    tax_amount_2 numeric(18,6) DEFAULT 0 CONSTRAINT sls_offer_tax_amount_2_nn NOT NULL,
    tax_rate_3 integer DEFAULT 0 CONSTRAINT sls_offer_tax_rate_3_nn NOT NULL,
    tax_amount_3 numeric(18,6) DEFAULT 0 CONSTRAINT sls_offer_tax_amount_3_nn NOT NULL,
    tax_rate_4 integer DEFAULT 0 CONSTRAINT sls_offer_tax_rate_4_nn NOT NULL,
    tax_amount_4 numeric(18,6) DEFAULT 0 CONSTRAINT sls_offer_tax_amount_4_nn NOT NULL,
    tax_rate_5 integer DEFAULT 0 CONSTRAINT sls_offer_tax_rate_5_nn NOT NULL,
    tax_amount_5 numeric(18,6) DEFAULT 0 CONSTRAINT sls_offer_tax_amount_5_nn NOT NULL,
    genel_toplam numeric(18,6) DEFAULT 0 CONSTRAINT sls_offer_grand_total_nn NOT NULL,
    operation_type_id bigint,
    offer_number character varying(16) CONSTRAINT sls_offer_number_nn NOT NULL,
    offer_date date CONSTRAINT sls_offer_date_nn NOT NULL,
    validity_date date CONSTRAINT sls_offer_validity_nn NOT NULL,
    customer_code character varying(16),
    customer_name character varying(128),
    tax_office character varying(32) CONSTRAINT sls_offer_tax_office_nn NOT NULL,
    tax_number character varying(32) CONSTRAINT sls_offer_tax_number_nn NOT NULL,
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
    contact_phone character varying(24),
    reference character varying(128),
    currency_code character varying(3) CONSTRAINT sls_offer_currency_code_nn NOT NULL,
    exchange_rate_usd numeric(7,4) DEFAULT 1,
    exchange_rate_eur numeric(7,4) DEFAULT 1,
    description character varying(128),
    proforma_no integer,
    delivery_method_id bigint CONSTRAINT sls_offer_delivery_type_id_nn NOT NULL,
    payment_method_id bigint CONSTRAINT sls_offer_payment_method_nn NOT NULL,
    packet_type_id bigint CONSTRAINT sls_offer_packet_type_nn NOT NULL,
    transport_charge_id bigint CONSTRAINT sls_offer_shipping_cost_nn NOT NULL
);


--
-- Name: sls_offer_detail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sls_offer_detail (
    id bigint CONSTRAINT sls_offer_detail_id_nn NOT NULL,
    header_id bigint,
    order_detail_id bigint,
    delivery_note_detail_id bigint,
    invoice_detail_id bigint,
    sku_code character varying(32),
    stock_description character varying(128),
    user_description character varying(128),
    reference character varying(128),
    quantity double precision DEFAULT 1 CONSTRAINT sls_offer_detail_quantity_nn NOT NULL,
    uom_code character varying(8),
    discount_rate numeric(6,3) DEFAULT 0,
    tax_rate integer DEFAULT 0,
    unit_price numeric(18,6) DEFAULT 0,
    net_unit_price numeric(18,6) DEFAULT 0 CONSTRAINT sls_offer_detail_net_price_nn NOT NULL,
    amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_offer_detail_amount_nn NOT NULL,
    discount_amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_offer_detail_discount_amount_nn NOT NULL,
    net_amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_offer_detail_net_amount_nn NOT NULL,
    tax_amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_offer_detail_tax_amount_nn NOT NULL,
    total_amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_offer_detail_total_amount_nn NOT NULL,
    is_main_product boolean DEFAULT false CONSTRAINT sls_offer_detail_main_product_nn NOT NULL,
    reference_main_product_id bigint,
    hs_code character varying(16)
);


--
-- Name: sls_offer_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: sls_offer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: sls_offer_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sls_offer_status (
    id bigint CONSTRAINT sls_offer_status_id_nn NOT NULL,
    status_code character varying(32) CONSTRAINT sls_offer_status_description_nn NOT NULL,
    description character varying(64)
);


--
-- Name: sls_offer_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sls_offer_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sls_offer_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sls_order; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sls_order (
    id bigint CONSTRAINT sls_order_id_nn NOT NULL,
    offer_id bigint,
    delivery_note_id bigint,
    invoice_id bigint,
    total_amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_amount_nn NOT NULL,
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


--
-- Name: sls_order_detail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sls_order_detail (
    id bigint CONSTRAINT sls_order_detail_id_nn NOT NULL,
    header_id bigint,
    offer_detail_id bigint,
    delivery_note_detail_id bigint,
    invoice_detail_id bigint,
    sku_code character varying(32),
    stock_description character varying(128),
    user_description character varying(128),
    reference character varying(128),
    quantity numeric(18,6) DEFAULT 1 CONSTRAINT sls_order_detail_qty_nn NOT NULL,
    outgoing_quantity numeric(18,6) DEFAULT 1 CONSTRAINT sls_order_detail_sent_qty_nn NOT NULL,
    uom_code character varying(8),
    discount_rate numeric(18,6) DEFAULT 0,
    tax_rate integer DEFAULT 0,
    unit_price numeric(18,6) DEFAULT 0,
    net_unit_price numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_detail_net_price_nn NOT NULL,
    amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_detail_amount_nn NOT NULL,
    discount_amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_detail_discount_amount_nn NOT NULL,
    net_amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_detail_net_amount_nn NOT NULL,
    tax_amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_detail_tax_amount_nn NOT NULL,
    total_amount numeric(18,6) DEFAULT 0 CONSTRAINT sls_order_detail_total_amount_nn NOT NULL,
    is_main_product boolean DEFAULT false CONSTRAINT sls_order_detail_is_main_product_nn NOT NULL,
    reference_main_product_id bigint,
    hs_code character varying(16),
    en numeric(12,6) DEFAULT 0,
    boy numeric(12,6) DEFAULT 0,
    height_en numeric(12,6) DEFAULT 0,
    net_weight numeric(12,6) DEFAULT 0,
    gross_weight numeric(12,6) DEFAULT 0,
    volume numeric(12,6) DEFAULT 0,
    thickness integer
);


--
-- Name: sls_order_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: sls_order_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: sls_order_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sls_order_status (
    id bigint CONSTRAINT sls_order_status_id_nn NOT NULL,
    order_status character varying(32) CONSTRAINT sls_order_status_description_nn NOT NULL,
    description character varying(64)
);


--
-- Name: sls_order_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sls_order_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sls_order_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stk_card_kind_info_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stk_card_kind_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stk_card_kind_info; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: stk_inventory; Type: TABLE; Schema: public; Owner: -
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
    buying_currency character varying(3) CONSTRAINT stk_inventory_buy_currency_nn NOT NULL,
    sales_price numeric(18,6) DEFAULT 0,
    sales_currency character varying(3) CONSTRAINT stk_inventory_sell_currency_nn NOT NULL,
    export_price numeric(18,6) DEFAULT 0,
    export_currency character varying(3) CONSTRAINT stk_inventory_export_currency_nn NOT NULL,
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


--
-- Name: stk_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.stk_inventory ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stk_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stk_group (
    id bigint NOT NULL,
    name character varying(32) NOT NULL,
    vat_rate double precision NOT NULL,
    raw_material_stock_account character varying(16),
    raw_material_usage_account character varying(16),
    semi_product_account character varying(16)
);


--
-- Name: stk_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.stk_group ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stk_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stk_image (
    id bigint NOT NULL,
    card_id bigint NOT NULL,
    image bytea,
    file_name character varying
);


--
-- Name: stk_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.stk_image ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stk_inventory_summary; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: stk_inventory_summary_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.stk_inventory_summary ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_inventory_summary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stk_kind_family; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stk_kind_family (
    id bigint NOT NULL,
    family character varying(32) NOT NULL,
    description character varying(250),
    active boolean DEFAULT true NOT NULL
);


--
-- Name: stk_kind_family_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stk_kind_family_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stk_kind_family_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stk_kind_family_id_seq OWNED BY public.stk_kind_family.id;


--
-- Name: stk_kind_property_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stk_kind_property_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stk_kind_property; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: stk_product_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stk_product_type (
    id bigint NOT NULL,
    product_type_name character varying(32) NOT NULL,
    description character varying(128),
    active boolean DEFAULT true
);


--
-- Name: stk_product_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stk_product_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stk_product_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stk_product_type_id_seq OWNED BY public.stk_product_type.id;


--
-- Name: stk_transaction; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: stk_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.stk_transaction ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stk_warehouse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stk_warehouse (
    id bigint NOT NULL,
    warehouse_name character varying(32),
    default_raw_material boolean DEFAULT false NOT NULL,
    default_production boolean DEFAULT false NOT NULL,
    default_sales boolean DEFAULT false NOT NULL
);


--
-- Name: TABLE stk_warehouse; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.stk_warehouse IS 'Stok hareketlerinin tutulduğu ambar bilgisi';


--
-- Name: stk_warehouse_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.stk_warehouse ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_warehouse_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_access_right; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: sys_access_right_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: sys_address; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: sys_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sys_address ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_application_setting; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: sys_app_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sys_application_setting ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_app_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vw_sys_application_setting; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_sys_application_setting AS
 SELECT s.id,
    s.company_title,
    s.phone,
    s.fax,
    s.tax_authority,
    s.tax_no,
    s.active_period,
    s.mail_host,
    s.mail_user,
    s.mail_smtp_port,
    s.grid_color_1,
    s.grid_color_2,
    s.grid_color_active,
    s.crypt_key,
    s.sms_host,
    s.sms_user,
    s.sms_title,
    s.app_version,
    s.app_currency,
    s.address_id,
    s.other_settings,
    s.taxpayer_name,
    s.taxpayer_surname,
    s.taxpayer_type,
    a.web AS address_web,
    a.email AS address_email,
    a.district AS address_district,
    a.neighborhood AS address_neighborhood,
    a.quarter AS address_quarter,
    a.road AS address_road,
    a.street AS address_street,
    a.building_name AS address_building_name,
    a.door_number AS address_door_number,
    a.zip_code AS address_zip_code,
    c.name AS currency_name
   FROM (public.sys_application_setting s
     LEFT JOIN public.sys_address a ON ((a.id = s.address_id))
     LEFT JOIN public.sys_currency c ON ((c.currency = s.app_currency)))
  WHERE (1 = 1);


--
-- Name: sys_city; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_city (
    id bigint NOT NULL,
    name character varying(32) NOT NULL,
    plate_code integer,
    country_id bigint,
    region_id bigint
);


--
-- Name: sys_city_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: sys_country; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_country (
    id bigint NOT NULL,
    code character varying(2) NOT NULL,
    name character varying(128) NOT NULL,
    iso_year integer,
    iso_cctld character varying(3),
    is_eu_member boolean DEFAULT false CONSTRAINT sys_country_eu_not_null NOT NULL
);


--
-- Name: sys_country_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: vw_sys_countries; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_sys_countries AS
 SELECT id,
    code AS country_code,
    name AS country_name,
    iso_year,
    iso_cctld AS iso_cctld,
    is_eu_member
   FROM public.sys_country
  WHERE (1 = 1);


--
-- Name: sys_currency; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_currency (
    id bigint NOT NULL,
    currency character varying(3) CONSTRAINT sys_currency_cur_not_null NOT NULL,
    symbol character varying(3) CONSTRAINT sys_currency_sym_not_null NOT NULL,
    description character varying(128)
);


--
-- Name: sys_currency_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: vw_sys_currencies; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_sys_currencies AS
 SELECT id,
    currency,
    symbol,
    description
   FROM public.sys_currency
  WHERE (1 = 1);


--
-- Name: sys_day; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_day (
    id bigint NOT NULL,
    name character varying(16) NOT NULL
);


--
-- Name: sys_day_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sys_day ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_day_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vw_sys_days; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_sys_days AS
 SELECT id,
    name AS day_name
   FROM public.sys_day
  WHERE (1 = 1);


--
-- Name: sys_db_status; Type: VIEW; Schema: public; Owner: -
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


--
-- Name: sys_decimal_place; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_decimal_place (
    id bigint CONSTRAINT sys_dp_id_not_null NOT NULL,
    quantity smallint DEFAULT 2,
    price smallint DEFAULT 2,
    total smallint DEFAULT 2,
    stock_quantity smallint DEFAULT 4,
    exchange_rate smallint DEFAULT 4
);


--
-- Name: sys_decimal_places_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sys_decimal_place ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_decimal_places_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vw_sys_decimal_places; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_sys_decimal_places AS
 SELECT id,
    quantity,
    price,
    total,
    stock_quantity,
    exchange_rate
   FROM public.sys_decimal_place
  WHERE (1 = 1);


--
-- Name: sys_grid_column; Type: TABLE; Schema: public; Owner: -
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
    bar_text_coolor integer DEFAULT 0
);


--
-- Name: sys_grid_column_title; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_grid_column_title (
    id bigint CONSTRAINT sys_gct_iid_not_null NOT NULL,
    table_name character varying(64) CONSTRAINT sys_gct_tn_not_null NOT NULL,
    column_name character varying(64) CONSTRAINT sys_gct_cn_not_null NOT NULL,
    lng_code character varying(2) CONSTRAINT sys_gct_lc_not_null NOT NULL,
    column_label character varying(64)
);


--
-- Name: sys_grid_column_titles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sys_grid_column_title ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_column_titles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vw_sys_grid_column_titles; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_sys_grid_column_titles AS
 SELECT id,
    table_name,
    column_name,
    lng_code,
    column_label
   FROM public.sys_grid_column_title
  WHERE (1 = 1);


--
-- Name: sys_grid_columns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sys_grid_column ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_columns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vw_sys_grid_columns; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_sys_grid_columns AS
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
    bar_text_color
   FROM public.sys_grid_column
  WHERE (1 = 1);

--
-- Name: sys_grid_filter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_grid_filter (
    id bigint CONSTRAINT sys_gf_iid_not_null NOT NULL,
    table_name character varying(32),
    filter_content character varying
);


--
-- Name: sys_grid_sort; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_grid_sort (
    id bigint CONSTRAINT sys_gs_iid_not_null NOT NULL,
    table_name character varying(32),
    sort_content character varying
);


--
-- Name: sys_grid_sort_filter_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sys_grid_filter ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_sort_filter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vw_sys_grid_filters; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_sys_grid_filters AS
 SELECT id,
    table_name,
    filter_content
   FROM public.sys_grid_filter
  WHERE (1 = 1);


--
-- Name: sys_grid_sorts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: vw_sys_grid_sorts; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_sys_grid_sorts AS
 SELECT id,
    table_name,
    sort_content
   FROM public.sys_grid_sort
  WHERE (1 = 1);


--
-- Name: sys_gui_content; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_gui_content (
    id bigint CONSTRAINT sys_guc_iid_not_null NOT NULL,
    code character varying(64) CONSTRAINT sys_guc_cd_not_null NOT NULL,
    content text,
    is_factory boolean DEFAULT false CONSTRAINT sys_guc_if_not_null NOT NULL,
    content_type character varying(32) CONSTRAINT sys_guc_ct_not_null NOT NULL,
    table_name character varying(64),
    form_name character varying(64)
);


--
-- Name: sys_language; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_language (
    id bigint CONSTRAINT sys_lng_iid_not_null NOT NULL,
    lng_code character varying(2) CONSTRAINT sys_lng_lc_not_null NOT NULL,
    description character varying(128)
);


--
-- Name: sys_language_gui_content_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sys_gui_content ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_language_gui_content_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_languages_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sys_language ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_languages_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_month; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_month (
    id bigint CONSTRAINT sys_mo_iid_not_null NOT NULL,
    name character varying(16) CONSTRAINT sys_mo_nm_not_null NOT NULL
);


--
-- Name: sys_month_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sys_month ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_month_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_permission (
    id bigint CONSTRAINT sys_perm_iid_not_null NOT NULL,
    code integer CONSTRAINT sys_perm_pc_not_null NOT NULL,
    name character varying(64) CONSTRAINT sys_perm_pn_not_null NOT NULL,
    group_id bigint CONSTRAINT sys_permissions_permission_group_id_not_null NOT NULL
);


--
-- Name: sys_permission_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_permission_group (
    id bigint CONSTRAINT sys_pg_iid_not_null NOT NULL,
    name character varying(64) CONSTRAINT sys_pg_nn_not_null NOT NULL
);


--
-- Name: sys_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_region (
    id bigint CONSTRAINT sys_reg_iid_not_null NOT NULL,
    name character varying(64) CONSTRAINT sys_reg_rn_not_null NOT NULL
);


--
-- Name: sys_region_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: sys_resource_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sys_permission_group ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_resource_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_resources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sys_permission ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_uom; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_uom (
    id bigint CONSTRAINT sys_uom_iid_not_null NOT NULL,
    unit_code character varying(16) CONSTRAINT sys_uom_mu_not_null NOT NULL,
    unit_einv character varying(3),
    description character varying(64),
    "decimal" boolean DEFAULT false CONSTRAINT sys_uom_dec_not_null NOT NULL,
    measure_type_id bigint,
    multiplier integer
);


--
-- Name: sys_uom_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: sys_uom_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_uom_type (
    id bigint CONSTRAINT sys_uomt_iid_not_null NOT NULL,
    name character varying(16) CONSTRAINT sys_uomt_nm_not_null NOT NULL
);


--
-- Name: sys_uom_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sys_uom_type ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_uom_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_user; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: sys_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sys_user ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_view_tables; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.sys_view_tables AS
 SELECT (row_number() OVER (ORDER BY tables.table_type, tables.table_name))::integer AS id,
    initcap(replace((table_name)::text, '_'::text, ' '::text)) AS table_name,
    (table_type)::text AS table_type
   FROM information_schema.tables
  WHERE ((table_schema)::text = 'public'::text)
  ORDER BY (table_type)::text, (initcap(replace((table_name)::text, '_'::text, ' '::text)));


--
-- Name: sys_view_columns; Type: VIEW; Schema: public; Owner: -
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


--
-- Name: sys_view_databases; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.sys_view_databases AS
 SELECT (pg_database.datname)::text AS database_name,
    pg_shdescription.description
   FROM (pg_shdescription
     JOIN pg_database ON ((pg_shdescription.objoid = pg_database.oid)))
  WHERE ((1 = 1) AND (pg_shdescription.description = 'THS ERP Systems'::text));


--
-- Name: urd_by_product_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.prd_bom_by_product ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urd_by_product_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urd_labor_cost_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.prd_labour ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urd_labor_cost_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urd_package_labour_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.prd_packet_labour_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urd_package_labour_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urd_package_labour_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.prd_packet_labour ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urd_package_labour_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urd_package_raw_material_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.prd_packet_raw_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urd_package_raw_material_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urd_package_raw_material_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.prd_packet_raw ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urd_package_raw_material_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urd_recipe_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.prd_bom ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urd_recipe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urd_recipe_labour_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.prd_bom_labour ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urd_recipe_labour_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urd_recipe_package_labour_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.prd_bom_packet_labour ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urd_recipe_package_labour_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urd_recipe_package_raw_material_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.prd_bom_packet_raw ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urd_recipe_package_raw_material_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urd_recipe_raw_material_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.prd_bom_raw ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urd_recipe_raw_material_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vw_sys_cities; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_sys_cities AS
 SELECT ct.id,
    ct.name AS city_name,
    ct.plate_code AS car_plate_code,
    ct.country_id,
    ct.region_id,
    cn.code AS country_code,
    cn.name AS country_name,
    r.name AS region_name
   FROM ((public.sys_city ct
     LEFT JOIN public.sys_country cn ON ((cn.id = ct.country_id)))
     LEFT JOIN public.sys_region r ON ((r.id = ct.region_id)))
  WHERE (1 = 1);


--
-- Name: pur_offer_detail id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pur_offer_detail ALTER COLUMN id SET DEFAULT nextval('public.pur_offer_detail_id_seq'::regclass);


--
-- Name: stk_kind_family id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_kind_family ALTER COLUMN id SET DEFAULT nextval('public.stk_kind_family_id_seq'::regclass);


--
-- Name: stk_product_type id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_product_type ALTER COLUMN id SET DEFAULT nextval('public.stk_product_type_id_seq'::regclass);


--
-- Name: acc_account acc_acc_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_account
    ADD CONSTRAINT acc_acc_code_key UNIQUE (code);


--
-- Name: acc_account acc_acc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_account
    ADD CONSTRAINT acc_acc_pkey PRIMARY KEY (id);


--
-- Name: acc_account_plan acc_aplan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_account_plan
    ADD CONSTRAINT acc_aplan_pkey PRIMARY KEY (id);


--
-- Name: acc_bank acc_bank_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_bank
    ADD CONSTRAINT acc_bank_name_key UNIQUE (name);


--
-- Name: acc_bank acc_bank_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_bank
    ADD CONSTRAINT acc_bank_pkey PRIMARY KEY (id);


--
-- Name: acc_bank_branch acc_branch_bc_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_bank_branch
    ADD CONSTRAINT acc_branch_bc_key UNIQUE (bank_id, code);


--
-- Name: acc_bank_branch acc_branch_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_bank_branch
    ADD CONSTRAINT acc_branch_pkey PRIMARY KEY (id);


--
-- Name: acc_set_company_legal_form acc_clf_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_set_company_legal_form
    ADD CONSTRAINT acc_clf_name_key UNIQUE (name);


--
-- Name: acc_set_company_legal_form acc_clf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_set_company_legal_form
    ADD CONSTRAINT acc_clf_pkey PRIMARY KEY (id);


--
-- Name: acc_exchange_rate acc_er_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_exchange_rate
    ADD CONSTRAINT acc_er_pkey PRIMARY KEY (id);


--
-- Name: acc_exchange_rate acc_er_rd_curr_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_exchange_rate
    ADD CONSTRAINT acc_er_rd_curr_key UNIQUE (rate_date, currency);


--
-- Name: acc_group acc_group_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_group
    ADD CONSTRAINT acc_group_name_key UNIQUE (name);


--
-- Name: acc_group acc_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_group
    ADD CONSTRAINT acc_group_pkey PRIMARY KEY (id);


--
-- Name: acc_set_ownership_type acc_otn_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_set_ownership_type
    ADD CONSTRAINT acc_otn_name_key UNIQUE (name);


--
-- Name: acc_set_ownership_type acc_otn_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_set_ownership_type
    ADD CONSTRAINT acc_otn_pkey PRIMARY KEY (id);


--
-- Name: acc_region acc_region_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_region
    ADD CONSTRAINT acc_region_name_key UNIQUE (name);


--
-- Name: acc_region acc_region_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_region
    ADD CONSTRAINT acc_region_pkey PRIMARY KEY (id);


--
-- Name: acc_set_account_type acc_set_at_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_set_account_type
    ADD CONSTRAINT acc_set_at_pkey PRIMARY KEY (id);


--
-- Name: acc_set_account_type acc_set_at_type_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_set_account_type
    ADD CONSTRAINT acc_set_at_type_key UNIQUE (name);


--
-- Name: acc_set_tax_rate acc_set_tr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_set_tax_rate
    ADD CONSTRAINT acc_set_tr_pkey PRIMARY KEY (id);


--
-- Name: acc_set_tax_rate acc_set_tr_vrate_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_set_tax_rate
    ADD CONSTRAINT acc_set_tr_vrate_key UNIQUE (tax_rate);


--
-- Name: acc_transfer_code acc_transfer_code_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_transfer_code
    ADD CONSTRAINT acc_transfer_code_code_key UNIQUE (transfer_code);


--
-- Name: acc_transfer_code acc_transfer_code_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_transfer_code
    ADD CONSTRAINT acc_transfer_code_pkey PRIMARY KEY (id);


--
-- Name: acc_voucher_detail acc_voucher_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_voucher_detail
    ADD CONSTRAINT acc_voucher_detail_pkey PRIMARY KEY (id);


--
-- Name: acc_voucher acc_voucher_journal_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_voucher
    ADD CONSTRAINT acc_voucher_journal_no_key UNIQUE (journal_no);


--
-- Name: acc_voucher acc_voucher_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_voucher
    ADD CONSTRAINT acc_voucher_pkey PRIMARY KEY (id);


--
-- Name: audit audit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit
    ADD CONSTRAINT audit_pkey PRIMARY KEY (id);


--
-- Name: einv_delivery_type einv_delivery_type_delivery_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.einv_delivery_type
    ADD CONSTRAINT einv_delivery_type_delivery_code_key UNIQUE (delivery_method);


--
-- Name: einv_delivery_type einv_delivery_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.einv_delivery_type
    ADD CONSTRAINT einv_delivery_type_pkey PRIMARY KEY (id);


--
-- Name: einv_invoice_type einv_invoice_type_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.einv_invoice_type
    ADD CONSTRAINT einv_invoice_type_code_key UNIQUE (invoice_type_code);


--
-- Name: einv_invoice_type einv_invoice_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.einv_invoice_type
    ADD CONSTRAINT einv_invoice_type_pkey PRIMARY KEY (id);


--
-- Name: einv_packet_type einv_packet_type_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.einv_packet_type
    ADD CONSTRAINT einv_packet_type_code_key UNIQUE (code);


--
-- Name: einv_packet_type einv_packet_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.einv_packet_type
    ADD CONSTRAINT einv_packet_type_pkey PRIMARY KEY (id);


--
-- Name: einv_payment_method einv_payment_method_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.einv_payment_method
    ADD CONSTRAINT einv_payment_method_code_key UNIQUE (payment_method_code);


--
-- Name: einv_payment_method einv_payment_method_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.einv_payment_method
    ADD CONSTRAINT einv_payment_method_pkey PRIMARY KEY (id);


--
-- Name: einv_transport_price einv_transport_price_charge_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.einv_transport_price
    ADD CONSTRAINT einv_transport_price_charge_key UNIQUE (transport_charge);


--
-- Name: einv_transport_price einv_transport_price_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.einv_transport_price
    ADD CONSTRAINT einv_transport_price_pkey PRIMARY KEY (id);


--
-- Name: prd_bom_by_product prd_bom_by_product_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_by_product
    ADD CONSTRAINT prd_bom_by_product_pkey PRIMARY KEY (id);


--
-- Name: prd_bom_by_product prd_bom_by_product_sku_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_by_product
    ADD CONSTRAINT prd_bom_by_product_sku_key UNIQUE (product_sku, header_id);


--
-- Name: prd_bom_labour prd_bom_labour_cost_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_labour
    ADD CONSTRAINT prd_bom_labour_cost_code_key UNIQUE (labor_code);


--
-- Name: prd_bom_labour prd_bom_labour_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_labour
    ADD CONSTRAINT prd_bom_labour_pkey PRIMARY KEY (id);


--
-- Name: prd_bom_packet_labour prd_bom_packet_labour_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_packet_labour
    ADD CONSTRAINT prd_bom_packet_labour_pkey PRIMARY KEY (id);


--
-- Name: prd_bom_packet_labour prd_bom_packet_labour_pkg_id_nn; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_packet_labour
    ADD CONSTRAINT prd_bom_packet_labour_pkg_id_nn UNIQUE (header_id, package_id);


--
-- Name: prd_bom_packet_raw prd_bom_packet_raw_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_packet_raw
    ADD CONSTRAINT prd_bom_packet_raw_pkey PRIMARY KEY (id);


--
-- Name: prd_bom_packet_raw prd_bom_packet_raw_pkg_id_nn; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_packet_raw
    ADD CONSTRAINT prd_bom_packet_raw_pkg_id_nn UNIQUE (header_id, package_id);


--
-- Name: prd_bom prd_bom_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom
    ADD CONSTRAINT prd_bom_pkey PRIMARY KEY (id);


--
-- Name: prd_bom prd_bom_product_sku_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom
    ADD CONSTRAINT prd_bom_product_sku_key UNIQUE (product_sku, product_name);


--
-- Name: prd_labour prd_labour_cost_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_labour
    ADD CONSTRAINT prd_labour_cost_code_key UNIQUE (cost_code);


--
-- Name: prd_labour prd_labour_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_labour
    ADD CONSTRAINT prd_labour_pkey PRIMARY KEY (id);


--
-- Name: prd_packet_labour_detail prd_packet_labour_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_packet_labour_detail
    ADD CONSTRAINT prd_packet_labour_detail_pkey PRIMARY KEY (id);


--
-- Name: prd_packet_labour_detail prd_packet_labour_detail_sku_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_packet_labour_detail
    ADD CONSTRAINT prd_packet_labour_detail_sku_key UNIQUE (labor_code, header_id);


--
-- Name: prd_packet_labour prd_packet_labour_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_packet_labour
    ADD CONSTRAINT prd_packet_labour_name_key UNIQUE (package_name);


--
-- Name: prd_packet_labour prd_packet_labour_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_packet_labour
    ADD CONSTRAINT prd_packet_labour_pkey PRIMARY KEY (id);


--
-- Name: prd_packet_raw_detail prd_packet_raw_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_packet_raw_detail
    ADD CONSTRAINT prd_packet_raw_detail_pkey PRIMARY KEY (id);


--
-- Name: prd_packet_raw_detail prd_packet_raw_detail_sku_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_packet_raw_detail
    ADD CONSTRAINT prd_packet_raw_detail_sku_key UNIQUE (sku_code, header_id);


--
-- Name: prd_packet_raw prd_packet_raw_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_packet_raw
    ADD CONSTRAINT prd_packet_raw_name_key UNIQUE (package_name);


--
-- Name: prd_packet_raw prd_packet_raw_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_packet_raw
    ADD CONSTRAINT prd_packet_raw_pkey PRIMARY KEY (id);


--
-- Name: prd_bom_raw prd_rhmd_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_raw
    ADD CONSTRAINT prd_rhmd_pkey PRIMARY KEY (id);


--
-- Name: prd_bom_raw prd_rhmd_sih_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_raw
    ADD CONSTRAINT prd_rhmd_sih_key UNIQUE (sku_code, header_id);


--
-- Name: emp_driver_ability prs_driver_abilities_driver_license_id_person_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_driver_ability
    ADD CONSTRAINT prs_driver_abilities_driver_license_id_person_id_key UNIQUE (driver_license_id, person_id);


--
-- Name: emp_driver_ability prs_driver_abilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_driver_ability
    ADD CONSTRAINT prs_driver_abilities_pkey PRIMARY KEY (id);


--
-- Name: emp_person_language_ability prs_language_abilities_language_id_person_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_person_language_ability
    ADD CONSTRAINT prs_language_abilities_language_id_person_id_key UNIQUE (language_id, person_id);


--
-- Name: emp_person_language_ability prs_language_abilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_person_language_ability
    ADD CONSTRAINT prs_language_abilities_pkey PRIMARY KEY (id);


--
-- Name: emp_person prs_persons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_person
    ADD CONSTRAINT prs_persons_pkey PRIMARY KEY (id);


--
-- Name: emp_driver_license_type prs_set_dlt_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_driver_license_type
    ADD CONSTRAINT prs_set_dlt_name_key UNIQUE (license_name);


--
-- Name: emp_driver_license_type prs_set_dlt_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_driver_license_type
    ADD CONSTRAINT prs_set_dlt_pkey PRIMARY KEY (id);


--
-- Name: emp_language_level prs_set_lll_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_language_level
    ADD CONSTRAINT prs_set_lll_key UNIQUE (language_level);


--
-- Name: emp_language_level prs_set_lll_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_language_level
    ADD CONSTRAINT prs_set_lll_pkey PRIMARY KEY (id);


--
-- Name: emp_language prs_set_lng_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_language
    ADD CONSTRAINT prs_set_lng_name_key UNIQUE (language_name);


--
-- Name: emp_language prs_set_lng_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_language
    ADD CONSTRAINT prs_set_lng_pkey PRIMARY KEY (id);


--
-- Name: emp_person_type prs_set_ptp_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_person_type
    ADD CONSTRAINT prs_set_ptp_name_key UNIQUE (person_type);


--
-- Name: emp_person_type prs_set_ptp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_person_type
    ADD CONSTRAINT prs_set_ptp_pkey PRIMARY KEY (id);


--
-- Name: emp_section prs_set_sec_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_section
    ADD CONSTRAINT prs_set_sec_name_key UNIQUE (section_name);


--
-- Name: emp_section prs_set_sec_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_section
    ADD CONSTRAINT prs_set_sec_pkey PRIMARY KEY (id);


--
-- Name: emp_task prs_set_task_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_task
    ADD CONSTRAINT prs_set_task_pkey PRIMARY KEY (id);


--
-- Name: emp_transportation prs_set_trans_car_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_transportation
    ADD CONSTRAINT prs_set_trans_car_key UNIQUE (car_no);


--
-- Name: emp_transportation prs_set_trans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_transportation
    ADD CONSTRAINT prs_set_trans_pkey PRIMARY KEY (id);


--
-- Name: emp_task prs_set_tsk_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_task
    ADD CONSTRAINT prs_set_tsk_name_key UNIQUE (task_name);


--
-- Name: emp_unit prs_set_unit_ns_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_unit
    ADD CONSTRAINT prs_set_unit_ns_key UNIQUE (unit_name, section_id);


--
-- Name: emp_unit prs_set_unit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_unit
    ADD CONSTRAINT prs_set_unit_pkey PRIMARY KEY (id);


--
-- Name: pur_offer_detail pur_offer_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pur_offer_detail
    ADD CONSTRAINT pur_offer_detail_pkey PRIMARY KEY (id);


--
-- Name: pur_offer pur_offer_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pur_offer
    ADD CONSTRAINT pur_offer_number_key UNIQUE (offer_number);


--
-- Name: pur_offer pur_offer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pur_offer
    ADD CONSTRAINT pur_offer_pkey PRIMARY KEY (id);


--
-- Name: sls_dispatch_detail sls_delivery_note_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_dispatch_detail
    ADD CONSTRAINT sls_delivery_note_detail_pkey PRIMARY KEY (id);


--
-- Name: sls_dispatch sls_delivery_note_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_dispatch
    ADD CONSTRAINT sls_delivery_note_pkey PRIMARY KEY (id);


--
-- Name: sls_invoice_detail sls_invoice_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_invoice_detail
    ADD CONSTRAINT sls_invoice_detail_pkey PRIMARY KEY (id);


--
-- Name: sls_invoice sls_invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_invoice
    ADD CONSTRAINT sls_invoice_pkey PRIMARY KEY (id);


--
-- Name: sls_offer_detail sls_offer_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer_detail
    ADD CONSTRAINT sls_offer_detail_pkey PRIMARY KEY (id);


--
-- Name: sls_offer sls_offer_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_number_key UNIQUE (offer_number);


--
-- Name: sls_offer sls_offer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_pkey PRIMARY KEY (id);


--
-- Name: sls_offer_status sls_offer_status_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer_status
    ADD CONSTRAINT sls_offer_status_code_key UNIQUE (status_code);


--
-- Name: sls_offer_status sls_offer_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer_status
    ADD CONSTRAINT sls_offer_status_pkey PRIMARY KEY (id);


--
-- Name: sls_order_detail sls_order_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order_detail
    ADD CONSTRAINT sls_order_detail_pkey PRIMARY KEY (id);


--
-- Name: sls_order sls_order_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_pkey PRIMARY KEY (id);


--
-- Name: sls_order_status sls_order_status_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order_status
    ADD CONSTRAINT sls_order_status_code_key UNIQUE (order_status);


--
-- Name: sls_order_status sls_order_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order_status
    ADD CONSTRAINT sls_order_status_pkey PRIMARY KEY (id);


--
-- Name: stk_card_kind_info stk_card_kind_info_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_card_kind_info
    ADD CONSTRAINT stk_card_kind_info_pkey PRIMARY KEY (id);


--
-- Name: stk_group stk_group_group_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_group
    ADD CONSTRAINT stk_group_group_key UNIQUE (name);


--
-- Name: stk_group stk_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_group
    ADD CONSTRAINT stk_group_pkey PRIMARY KEY (id);


--
-- Name: stk_image stk_image_card_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_image
    ADD CONSTRAINT stk_image_card_id_key UNIQUE (card_id);


--
-- Name: stk_image stk_image_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_image
    ADD CONSTRAINT stk_image_pkey PRIMARY KEY (id);


--
-- Name: stk_inventory stk_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_pkey PRIMARY KEY (id);


--
-- Name: stk_inventory stk_inventory_sku_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_sku_key UNIQUE (code);


--
-- Name: stk_inventory_summary stk_inventory_summary_inventory_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_inventory_summary
    ADD CONSTRAINT stk_inventory_summary_inventory_id_key UNIQUE (inventory_id);


--
-- Name: stk_inventory_summary stk_inventory_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_inventory_summary
    ADD CONSTRAINT stk_inventory_summary_pkey PRIMARY KEY (id);


--
-- Name: stk_kind_family stk_kind_family_family_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_kind_family
    ADD CONSTRAINT stk_kind_family_family_key UNIQUE (family);


--
-- Name: stk_kind_family stk_kind_family_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_kind_family
    ADD CONSTRAINT stk_kind_family_pkey PRIMARY KEY (id);


--
-- Name: stk_kind_property stk_kind_property_kind_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_kind_property
    ADD CONSTRAINT stk_kind_property_kind_key UNIQUE (kind);


--
-- Name: stk_kind_property stk_kind_property_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_kind_property
    ADD CONSTRAINT stk_kind_property_pkey PRIMARY KEY (id);


--
-- Name: stk_product_type stk_product_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_product_type
    ADD CONSTRAINT stk_product_type_pkey PRIMARY KEY (id);


--
-- Name: stk_transaction stk_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_pkey PRIMARY KEY (id);


--
-- Name: stk_warehouse stk_warehouse_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_warehouse
    ADD CONSTRAINT stk_warehouse_pkey PRIMARY KEY (id);


--
-- Name: stk_warehouse stk_warehouse_warehouse_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_warehouse
    ADD CONSTRAINT stk_warehouse_warehouse_name_key UNIQUE (warehouse_name);


--
-- Name: sys_access_right sys_access_right_pid_uid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_access_right
    ADD CONSTRAINT sys_access_right_pid_uid_key UNIQUE (permission_id, user_id);


--
-- Name: sys_access_right sys_access_right_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_access_right
    ADD CONSTRAINT sys_access_right_pkey PRIMARY KEY (id);


--
-- Name: sys_address sys_address_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_address
    ADD CONSTRAINT sys_address_pkey PRIMARY KEY (id);


--
-- Name: sys_application_setting sys_application_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_application_setting
    ADD CONSTRAINT sys_application_setting_pkey PRIMARY KEY (id);


--
-- Name: sys_city sys_city_cid_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_city
    ADD CONSTRAINT sys_city_cid_name_key UNIQUE (country_id, name);


--
-- Name: sys_city sys_city_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_city
    ADD CONSTRAINT sys_city_pkey PRIMARY KEY (id);


--
-- Name: sys_country sys_country_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_country
    ADD CONSTRAINT sys_country_code_key UNIQUE (code);


--
-- Name: sys_country sys_country_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_country
    ADD CONSTRAINT sys_country_pkey PRIMARY KEY (id);


--
-- Name: sys_currency sys_currency_curr_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_currency
    ADD CONSTRAINT sys_currency_curr_key UNIQUE (currency);


--
-- Name: sys_currency sys_currency_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_currency
    ADD CONSTRAINT sys_currency_pkey PRIMARY KEY (id);


--
-- Name: sys_day sys_day_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_day
    ADD CONSTRAINT sys_day_name_key UNIQUE (name);


--
-- Name: sys_day sys_day_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_day
    ADD CONSTRAINT sys_day_pkey PRIMARY KEY (id);


--
-- Name: sys_decimal_place sys_decimal_place_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_decimal_place
    ADD CONSTRAINT sys_decimal_place_pkey PRIMARY KEY (id);


--
-- Name: sys_grid_column sys_grid_col_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_grid_column
    ADD CONSTRAINT sys_grid_col_pkey PRIMARY KEY (id);


--
-- Name: sys_grid_column sys_grid_col_table_col_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_grid_column
    ADD CONSTRAINT sys_grid_col_table_col_key UNIQUE (table_name, column_name);


--
-- Name: sys_grid_column sys_grid_col_table_ord_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_grid_column
    ADD CONSTRAINT sys_grid_col_table_ord_key UNIQUE (table_name, column_order);


--
-- Name: sys_grid_column_title sys_grid_col_title_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_grid_column_title
    ADD CONSTRAINT sys_grid_col_title_pkey PRIMARY KEY (id);


--
-- Name: sys_grid_column_title sys_grid_col_title_tn_cn_lc_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_grid_column_title
    ADD CONSTRAINT sys_grid_col_title_tn_cn_lc_key UNIQUE (table_name, column_name, lng_code);


--
-- Name: sys_grid_filter sys_grid_filter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_grid_filter
    ADD CONSTRAINT sys_grid_filter_pkey PRIMARY KEY (id);


--
-- Name: sys_grid_filter sys_grid_filter_tn_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_grid_filter
    ADD CONSTRAINT sys_grid_filter_tn_key UNIQUE (table_name);


--
-- Name: sys_grid_sort sys_grid_sort_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_grid_sort
    ADD CONSTRAINT sys_grid_sort_pkey PRIMARY KEY (id);


--
-- Name: sys_grid_sort sys_grid_sort_tn_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_grid_sort
    ADD CONSTRAINT sys_grid_sort_tn_key UNIQUE (table_name);


--
-- Name: sys_gui_content sys_gui_content_ct_table_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_gui_content
    ADD CONSTRAINT sys_gui_content_ct_table_key UNIQUE (code, content_type, table_name);


--
-- Name: sys_gui_content sys_gui_content_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_gui_content
    ADD CONSTRAINT sys_gui_content_pkey PRIMARY KEY (id);


--
-- Name: sys_language sys_language_lc_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_language
    ADD CONSTRAINT sys_language_lc_key UNIQUE (lng_code);


--
-- Name: sys_language sys_language_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_language
    ADD CONSTRAINT sys_language_pkey PRIMARY KEY (id);


--
-- Name: sys_month sys_month_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_month
    ADD CONSTRAINT sys_month_name_key UNIQUE (name);


--
-- Name: sys_month sys_month_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_month
    ADD CONSTRAINT sys_month_pkey PRIMARY KEY (id);


--
-- Name: sys_permission_group sys_perm_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_permission_group
    ADD CONSTRAINT sys_perm_group_pkey PRIMARY KEY (id);


--
-- Name: sys_permission_group sys_perm_grp_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_permission_group
    ADD CONSTRAINT sys_perm_grp_name_key UNIQUE (name);


--
-- Name: sys_permission sys_permission_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_permission
    ADD CONSTRAINT sys_permission_code_key UNIQUE (code);


--
-- Name: sys_permission sys_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_permission
    ADD CONSTRAINT sys_permission_pkey PRIMARY KEY (id);


--
-- Name: sys_region sys_region_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_region
    ADD CONSTRAINT sys_region_name_key UNIQUE (name);


--
-- Name: sys_region sys_region_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_region
    ADD CONSTRAINT sys_region_pkey PRIMARY KEY (id);


--
-- Name: sys_uom sys_uom_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_uom
    ADD CONSTRAINT sys_uom_pkey PRIMARY KEY (id);


--
-- Name: sys_uom_type sys_uom_type_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_uom_type
    ADD CONSTRAINT sys_uom_type_name_key UNIQUE (name);


--
-- Name: sys_uom_type sys_uom_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_uom_type
    ADD CONSTRAINT sys_uom_type_pkey PRIMARY KEY (id);


--
-- Name: sys_uom sys_uom_unit_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_uom
    ADD CONSTRAINT sys_uom_unit_key UNIQUE (unit_code);


--
-- Name: sys_user sys_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_user_pkey PRIMARY KEY (id);


--
-- Name: sys_user sys_user_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_user_username_key UNIQUE (username);


--
-- Name: idx_als_teklif_detaylari_header_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_als_teklif_detaylari_header_id ON public.pur_offer_detail USING btree (header_id);


--
-- Name: idx_sat_siparis_detaylari_header_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sat_siparis_detaylari_header_id ON public.sls_order_detail USING btree (header_id);


--
-- Name: idx_sat_siparis_musteri_kodu; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sat_siparis_musteri_kodu ON public.sls_order USING btree (customer_code);


--
-- Name: idx_sat_teklif_detaylari_header_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sat_teklif_detaylari_header_id ON public.sls_offer_detail USING btree (header_id);


--
-- Name: emp_section audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.emp_section FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: emp_driver_ability notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_driver_ability FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_driver_license_type notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_driver_license_type FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_language notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_language FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_language_level notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_language_level FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_person notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_person FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_person_language_ability notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_person_language_ability FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_person_type notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_person_type FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_task notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_task FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_transportation notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_transportation FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_unit notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_unit FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_card_kind_info notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_card_kind_info FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_group notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_group FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_inventory notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_inventory FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_transaction notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_transaction FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_warehouse notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_warehouse FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: sys_grid_column sys_grid_col_width_table_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER sys_grid_col_width_table_notify AFTER INSERT OR DELETE OR UPDATE ON public.sys_grid_column FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: emp_section table_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER table_notify AFTER INSERT OR DELETE OR UPDATE ON public.emp_section FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_kind_family table_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER table_notify BEFORE INSERT OR DELETE OR UPDATE ON public.stk_kind_family FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_kind_property table_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER table_notify BEFORE INSERT OR DELETE OR UPDATE ON public.stk_kind_property FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_account trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.acc_account FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_bank trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.acc_bank FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_bank_branch trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.acc_bank_branch FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_exchange_rate trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.acc_exchange_rate FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_region trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.acc_region FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_set_tax_rate trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.acc_set_tax_rate FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_transfer_code trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.acc_transfer_code FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_voucher trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.acc_voucher FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_voucher_detail trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.acc_voucher_detail FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_bom trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_bom FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_bom_by_product trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_bom_by_product FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_bom_labour trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_bom_labour FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_bom_packet_labour trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_bom_packet_labour FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_bom_packet_raw trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_bom_packet_raw FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_bom_raw trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_bom_raw FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_labour trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_labour FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_packet_labour trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_packet_labour FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_packet_labour_detail trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_packet_labour_detail FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_packet_raw trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_packet_raw FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prd_packet_raw_detail trg_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.prd_packet_raw_detail FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: acc_account acc_acc_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_account
    ADD CONSTRAINT acc_acc_group_fkey FOREIGN KEY (group_id) REFERENCES public.acc_group(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_account acc_acc_region_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_account
    ADD CONSTRAINT acc_acc_region_fkey FOREIGN KEY (region_id) REFERENCES public.acc_account_plan(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_account acc_acc_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_account
    ADD CONSTRAINT acc_acc_type_fkey FOREIGN KEY (type_id) REFERENCES public.acc_set_account_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_bank_branch acc_branch_bank_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_bank_branch
    ADD CONSTRAINT acc_branch_bank_fkey FOREIGN KEY (bank_id) REFERENCES public.acc_bank(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_bank_branch acc_branch_city_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_bank_branch
    ADD CONSTRAINT acc_branch_city_fkey FOREIGN KEY (city_id) REFERENCES public.sys_city(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_set_company_legal_form acc_clf_own_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_set_company_legal_form
    ADD CONSTRAINT acc_clf_own_fkey FOREIGN KEY (ownership_id) REFERENCES public.acc_set_ownership_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_exchange_rate acc_er_curr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_exchange_rate
    ADD CONSTRAINT acc_er_curr_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: acc_set_tax_rate acc_set_tr_pacct_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_set_tax_rate
    ADD CONSTRAINT acc_set_tr_pacct_fkey FOREIGN KEY (purchase_account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_set_tax_rate acc_set_tr_prturn_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_set_tax_rate
    ADD CONSTRAINT acc_set_tr_prturn_fkey FOREIGN KEY (purchase_return_account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_set_tax_rate acc_set_tr_sacct_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_set_tax_rate
    ADD CONSTRAINT acc_set_tr_sacct_fkey FOREIGN KEY (sales_account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_set_tax_rate acc_set_tr_srturn_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_set_tax_rate
    ADD CONSTRAINT acc_set_tr_srturn_fkey FOREIGN KEY (sales_return_account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_transfer_code acc_transfer_code_account_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_transfer_code
    ADD CONSTRAINT acc_transfer_code_account_fk FOREIGN KEY (account) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: acc_voucher_detail acc_voucher_detail_header_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acc_voucher_detail
    ADD CONSTRAINT acc_voucher_detail_header_id_fk FOREIGN KEY (header_id) REFERENCES public.acc_voucher(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_by_product prd_bom_by_product_header_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_by_product
    ADD CONSTRAINT prd_bom_by_product_header_fk FOREIGN KEY (header_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_by_product prd_bom_by_product_sku_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_by_product
    ADD CONSTRAINT prd_bom_by_product_sku_fk FOREIGN KEY (product_sku) REFERENCES public.stk_inventory(code) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_labour prd_bom_labour_cost_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_labour
    ADD CONSTRAINT prd_bom_labour_cost_code_fk FOREIGN KEY (labor_code) REFERENCES public.prd_labour(cost_code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_bom_labour prd_bom_labour_header_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_labour
    ADD CONSTRAINT prd_bom_labour_header_fk FOREIGN KEY (header_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_packet_labour prd_bom_packet_labour_header_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_packet_labour
    ADD CONSTRAINT prd_bom_packet_labour_header_fk FOREIGN KEY (header_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_packet_labour prd_bom_packet_labour_pkg_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_packet_labour
    ADD CONSTRAINT prd_bom_packet_labour_pkg_fk FOREIGN KEY (package_id) REFERENCES public.prd_packet_labour(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_bom_packet_raw prd_bom_packet_raw_header_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_packet_raw
    ADD CONSTRAINT prd_bom_packet_raw_header_fk FOREIGN KEY (header_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_packet_raw prd_bom_packet_raw_pkg_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_packet_raw
    ADD CONSTRAINT prd_bom_packet_raw_pkg_fk FOREIGN KEY (package_id) REFERENCES public.prd_packet_raw(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_bom prd_bom_product_sku_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom
    ADD CONSTRAINT prd_bom_product_sku_fk FOREIGN KEY (product_sku) REFERENCES public.stk_inventory(code) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_raw prd_bom_raw_sku_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_raw
    ADD CONSTRAINT prd_bom_raw_sku_fk FOREIGN KEY (sku_code) REFERENCES public.stk_inventory(code) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_labour prd_labour_cost_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_labour
    ADD CONSTRAINT prd_labour_cost_code_fk FOREIGN KEY (cost_code) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_labour prd_labour_unit_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_labour
    ADD CONSTRAINT prd_labour_unit_code_fk FOREIGN KEY (uom_code) REFERENCES public.sys_uom(unit_code) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: prd_packet_labour_detail prd_packet_labour_detail_cost_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_packet_labour_detail
    ADD CONSTRAINT prd_packet_labour_detail_cost_code_fk FOREIGN KEY (labor_code) REFERENCES public.prd_labour(cost_code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_packet_labour_detail prd_packet_labour_detail_header_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_packet_labour_detail
    ADD CONSTRAINT prd_packet_labour_detail_header_fk FOREIGN KEY (header_id) REFERENCES public.prd_packet_labour(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_packet_raw_detail prd_packet_raw_detail_header_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_packet_raw_detail
    ADD CONSTRAINT prd_packet_raw_detail_header_fk FOREIGN KEY (header_id) REFERENCES public.prd_packet_raw(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_packet_raw_detail prd_packet_raw_detail_recipe_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_packet_raw_detail
    ADD CONSTRAINT prd_packet_raw_detail_recipe_fk FOREIGN KEY (recete_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: prd_packet_raw_detail prd_packet_raw_detail_sku_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_packet_raw_detail
    ADD CONSTRAINT prd_packet_raw_detail_sku_fk FOREIGN KEY (sku_code) REFERENCES public.stk_inventory(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prd_bom_raw prd_rhmd_hdr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_raw
    ADD CONSTRAINT prd_rhmd_hdr_fkey FOREIGN KEY (header_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prd_bom_raw prd_rhmd_rct_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prd_bom_raw
    ADD CONSTRAINT prd_rhmd_rct_fkey FOREIGN KEY (recete_id) REFERENCES public.prd_bom(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_driver_ability prs_driver_abilities_driver_license_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_driver_ability
    ADD CONSTRAINT prs_driver_abilities_driver_license_id_fkey FOREIGN KEY (driver_license_id) REFERENCES public.emp_driver_license_type(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_driver_ability prs_driver_abilities_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_driver_ability
    ADD CONSTRAINT prs_driver_abilities_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.emp_person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_person_language_ability prs_language_abilities_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_person_language_ability
    ADD CONSTRAINT prs_language_abilities_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.emp_language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_person_language_ability prs_language_abilities_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_person_language_ability
    ADD CONSTRAINT prs_language_abilities_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.emp_person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_person_language_ability prs_language_abilities_read_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_person_language_ability
    ADD CONSTRAINT prs_language_abilities_read_id_fkey FOREIGN KEY (read_id) REFERENCES public.emp_language_level(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_person_language_ability prs_language_abilities_speak_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_person_language_ability
    ADD CONSTRAINT prs_language_abilities_speak_id_fkey FOREIGN KEY (speak_id) REFERENCES public.emp_language_level(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_person_language_ability prs_language_abilities_write_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_person_language_ability
    ADD CONSTRAINT prs_language_abilities_write_id_fkey FOREIGN KEY (write_id) REFERENCES public.emp_language_level(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emp_person prs_persons_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_person
    ADD CONSTRAINT prs_persons_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.sys_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: emp_person prs_persons_person_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_person
    ADD CONSTRAINT prs_persons_person_type_id_fkey FOREIGN KEY (person_type_id) REFERENCES public.emp_person_type(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: emp_person prs_persons_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_person
    ADD CONSTRAINT prs_persons_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.emp_task(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: emp_person prs_persons_transportation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_person
    ADD CONSTRAINT prs_persons_transportation_id_fkey FOREIGN KEY (transportation_id) REFERENCES public.emp_transportation(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: emp_person prs_persons_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_person
    ADD CONSTRAINT prs_persons_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.emp_unit(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: emp_unit prs_set_unit_ssection_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emp_unit
    ADD CONSTRAINT prs_set_unit_ssection_fkey FOREIGN KEY (section_id) REFERENCES public.emp_section(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_offer pur_offer_city_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pur_offer
    ADD CONSTRAINT pur_offer_city_id_fk FOREIGN KEY (city_id) REFERENCES public.sys_city(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_offer pur_offer_country_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pur_offer
    ADD CONSTRAINT pur_offer_country_id_fk FOREIGN KEY (country_id) REFERENCES public.sys_country(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_offer pur_offer_currency_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pur_offer
    ADD CONSTRAINT pur_offer_currency_code_fk FOREIGN KEY (currency_code) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_offer pur_offer_customer_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pur_offer
    ADD CONSTRAINT pur_offer_customer_code_fk FOREIGN KEY (customer_code) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_offer_detail pur_offer_detail_header_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pur_offer_detail
    ADD CONSTRAINT pur_offer_detail_header_id_fk FOREIGN KEY (header_id) REFERENCES public.pur_offer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pur_offer_detail pur_offer_detail_ref_product_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pur_offer_detail
    ADD CONSTRAINT pur_offer_detail_ref_product_fk FOREIGN KEY (reference_main_product_id) REFERENCES public.pur_offer_detail(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_offer_detail pur_offer_detail_sku_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pur_offer_detail
    ADD CONSTRAINT pur_offer_detail_sku_fk FOREIGN KEY (sku_code) REFERENCES public.stk_inventory(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_offer_detail pur_offer_detail_uom_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pur_offer_detail
    ADD CONSTRAINT pur_offer_detail_uom_code_fk FOREIGN KEY (uom_code) REFERENCES public.sys_uom(unit_code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pur_offer pur_offer_op_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pur_offer
    ADD CONSTRAINT pur_offer_op_type_fk FOREIGN KEY (operation_type_id) REFERENCES public.einv_invoice_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_dispatch_detail sls_delivery_note_detail_header_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_dispatch_detail
    ADD CONSTRAINT sls_delivery_note_detail_header_id_fk FOREIGN KEY (header_id) REFERENCES public.sls_dispatch(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sls_invoice_detail sls_invoice_detail_header_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_invoice_detail
    ADD CONSTRAINT sls_invoice_detail_header_id_fk FOREIGN KEY (header_id) REFERENCES public.sls_invoice(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sls_offer sls_offer_city_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_city_id_fk FOREIGN KEY (city_id) REFERENCES public.sys_city(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_country_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_country_id_fk FOREIGN KEY (country_id) REFERENCES public.sys_country(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_currency_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_currency_code_fk FOREIGN KEY (currency_code) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_customer_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_customer_code_fk FOREIGN KEY (customer_code) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_delivery_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_delivery_type_id_fk FOREIGN KEY (delivery_method_id) REFERENCES public.einv_delivery_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer_detail sls_offer_detail_header_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer_detail
    ADD CONSTRAINT sls_offer_detail_header_id_fk FOREIGN KEY (header_id) REFERENCES public.sls_offer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sls_offer_detail sls_offer_detail_ref_product_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer_detail
    ADD CONSTRAINT sls_offer_detail_ref_product_fk FOREIGN KEY (reference_main_product_id) REFERENCES public.sls_offer_detail(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer_detail sls_offer_detail_sku_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer_detail
    ADD CONSTRAINT sls_offer_detail_sku_fk FOREIGN KEY (sku_code) REFERENCES public.stk_inventory(code) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: sls_offer_detail sls_offer_detail_uom_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer_detail
    ADD CONSTRAINT sls_offer_detail_uom_code_fk FOREIGN KEY (uom_code) REFERENCES public.sys_uom(unit_code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_op_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_op_type_fk FOREIGN KEY (operation_type_id) REFERENCES public.einv_invoice_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_packet_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_packet_type_fk FOREIGN KEY (packet_type_id) REFERENCES public.einv_packet_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_payment_method_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_payment_method_fk FOREIGN KEY (payment_method_id) REFERENCES public.einv_payment_method(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_representative_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_representative_fk FOREIGN KEY (customer_representative_id) REFERENCES public.emp_person(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_offer sls_offer_transport_charge_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_offer
    ADD CONSTRAINT sls_offer_transport_charge_fk FOREIGN KEY (transport_charge_id) REFERENCES public.einv_transport_price(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_city_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_city_fk FOREIGN KEY (city_id) REFERENCES public.sys_city(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sls_order sls_order_country_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_country_fk FOREIGN KEY (country_id) REFERENCES public.sys_country(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sls_order sls_order_currency_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_currency_code_fk FOREIGN KEY (currency_code) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_customer_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_customer_code_fk FOREIGN KEY (customer_code) REFERENCES public.acc_account(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_delivery_method_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_delivery_method_fk FOREIGN KEY (delivery_method_id) REFERENCES public.einv_delivery_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order_detail sls_order_detail_header_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order_detail
    ADD CONSTRAINT sls_order_detail_header_id_fk FOREIGN KEY (header_id) REFERENCES public.sls_order(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sls_order_detail sls_order_detail_ref_main_product_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order_detail
    ADD CONSTRAINT sls_order_detail_ref_main_product_id_fk FOREIGN KEY (reference_main_product_id) REFERENCES public.sls_order_detail(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order_detail sls_order_detail_sku_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order_detail
    ADD CONSTRAINT sls_order_detail_sku_fk FOREIGN KEY (sku_code) REFERENCES public.stk_inventory(code) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: sls_order_detail sls_order_detail_uom_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order_detail
    ADD CONSTRAINT sls_order_detail_uom_code_fk FOREIGN KEY (uom_code) REFERENCES public.sys_uom(unit_code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_package_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_package_type_id_fk FOREIGN KEY (packet_type_id) REFERENCES public.einv_packet_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_payment_method_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_payment_method_id_fk FOREIGN KEY (payment_method_id) REFERENCES public.einv_payment_method(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_representative_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_representative_id_fk FOREIGN KEY (customer_representative_id) REFERENCES public.emp_person(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_shipping_cost_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_shipping_cost_id_fk FOREIGN KEY (transport_charge_id) REFERENCES public.einv_transport_price(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_status_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_status_fk FOREIGN KEY (status_id) REFERENCES public.sls_order_status(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sls_order sls_order_trans_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sls_order
    ADD CONSTRAINT sls_order_trans_type_id_fk FOREIGN KEY (operation_type_id) REFERENCES public.einv_invoice_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_image stk_image_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_image
    ADD CONSTRAINT stk_image_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.stk_inventory(id);


--
-- Name: stk_inventory stk_inventory_buy_currency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_buy_currency_fk FOREIGN KEY (buying_currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_export_currency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_export_currency_fk FOREIGN KEY (export_currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_group_id_fk FOREIGN KEY (group_id) REFERENCES public.stk_group(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_origin_country_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_origin_country_id_fk FOREIGN KEY (origin_id) REFERENCES public.sys_country(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory stk_inventory_sell_currency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_sell_currency_fk FOREIGN KEY (sales_currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_inventory_summary stk_inventory_summary_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_inventory_summary
    ADD CONSTRAINT stk_inventory_summary_inventory_id_fkey FOREIGN KEY (inventory_id) REFERENCES public.stk_inventory(id);


--
-- Name: stk_inventory stk_inventory_uom_code_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_inventory
    ADD CONSTRAINT stk_inventory_uom_code_fk FOREIGN KEY (measurement_id) REFERENCES public.sys_uom(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_transaction stk_transaction_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_currency_fkey FOREIGN KEY (currency) REFERENCES public.sys_currency(currency) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_transaction stk_transaction_from_warehouse_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_from_warehouse_fkey FOREIGN KEY (from_warehouse) REFERENCES public.stk_warehouse(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_transaction stk_transaction_stock_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_stock_code_fkey FOREIGN KEY (sku) REFERENCES public.stk_inventory(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_transaction stk_transaction_to_warehouse_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stk_transaction
    ADD CONSTRAINT stk_transaction_to_warehouse_fkey FOREIGN KEY (to_warehouse) REFERENCES public.stk_warehouse(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sys_access_right sys_access_right_perm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_access_right
    ADD CONSTRAINT sys_access_right_perm_id_fkey FOREIGN KEY (permission_id) REFERENCES public.sys_permission(id);


--
-- Name: sys_access_right sys_access_right_usr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_access_right
    ADD CONSTRAINT sys_access_right_usr_id_fkey FOREIGN KEY (user_id) REFERENCES public.sys_user(id);


--
-- Name: sys_address sys_address_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_address
    ADD CONSTRAINT sys_address_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.sys_city(id);


--
-- Name: sys_application_setting sys_app_set_addr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_application_setting
    ADD CONSTRAINT sys_app_set_addr_fkey FOREIGN KEY (address_id) REFERENCES public.sys_address(id);


--
-- Name: sys_application_setting sys_app_set_curr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_application_setting
    ADD CONSTRAINT sys_app_set_curr_fkey FOREIGN KEY (app_currency) REFERENCES public.sys_currency(currency);


--
-- Name: sys_city sys_city_cid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_city
    ADD CONSTRAINT sys_city_cid_fkey FOREIGN KEY (country_id) REFERENCES public.sys_country(id);


--
-- Name: sys_city sys_city_rid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_city
    ADD CONSTRAINT sys_city_rid_fkey FOREIGN KEY (region_id) REFERENCES public.sys_region(id);


--
-- Name: sys_permission sys_perm_grp_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_permission
    ADD CONSTRAINT sys_perm_grp_fkey FOREIGN KEY (group_id) REFERENCES public.sys_permission_group(id);


--
-- Name: sys_uom sys_uom_utype_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_uom
    ADD CONSTRAINT sys_uom_utype_fkey FOREIGN KEY (measure_type_id) REFERENCES public.sys_uom_type(id);


--
-- Name: sys_user sys_usr_prs_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_usr_prs_fkey FOREIGN KEY (person_id) REFERENCES public.emp_person(id);


--
-- PostgreSQL database dump complete
--

\unrestrict F2nAKi9LLYA1aSIGOYqnQ9SdDCMaUgdLnug7B6gWTbowv7HjfEskCGgEP0D22Qc

