--
-- PostgreSQL database dump
--

-- Dumped from database version 13.4
-- Dumped by pg_dump version 15.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: dblink; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;


--
-- Name: EXTENSION dblink; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: pgrowlocks; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgrowlocks WITH SCHEMA public;


--
-- Name: EXTENSION pgrowlocks; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgrowlocks IS 'show row-level locking information';


--
-- Name: pldbgapi; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pldbgapi WITH SCHEMA public;


--
-- Name: EXTENSION pldbgapi; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pldbgapi IS 'server-side support for debugging PL/pgSQL functions';


--
-- Name: postgres_fdw; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;


--
-- Name: EXTENSION postgres_fdw; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';


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
-- Name: spexists_hesap_kodu(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.spexists_hesap_kodu(phesap_kodu text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$

DECLARE
	vCnt integer;
BEGIN
	SELECT INTO vCnt count(*) FROM ch_hesaplar WHERE hesap_kodu=phesap_kodu;
	
	IF cVnt > 0 THEN
		RETURN True;
	ELSE
		RETURN False;
	END IF;
END;
$$;


ALTER FUNCTION public.spexists_hesap_kodu(phesap_kodu text) OWNER TO postgres;

--
-- Name: spget_crypted_data(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.spget_crypted_data(pval text) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
	vval text;
begin
	SELECT crypt(pval, gen_salt('md5')) INTO vval;
	Return vval;
end
$$;


ALTER FUNCTION public.spget_crypted_data(pval text) OWNER TO postgres;

--
-- Name: spget_lang_text(text, text, text, bigint, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) RETURNS character varying
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


ALTER FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) OWNER TO postgres;

--
-- Name: spget_lang_text(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) RETURNS character varying
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


ALTER FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) OWNER TO postgres;

--
-- Name: spget_prs_personel_id_list(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.spget_prs_personel_id_list() RETURNS TABLE(id integer, emp_name character varying, emp_surname character varying, emp_full_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
		SELECT  prs_personel.id, prs_personel.ad, prs_personel.soyad, prs_personel.ad_soyad FROM prs_personel
		WHERE is_aktif ORDER BY 4;
END
$$;


ALTER FUNCTION public.spget_prs_personel_id_list() OWNER TO postgres;

--
-- Name: spget_rct_hammadde_maliyet(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
	_row record;
	_toplam numeric;
BEGIN
	_toplam := 0;
	FOR _row IN
		SELECT h.miktar * s.alis_fiyat tutar FROM rct_recete_hammadde h
		LEFT JOIN stk_stok_karti s ON s.stok_kodu = h.stok_kodu
		WHERE h.header_id = prct_recete_id
	LOOP
		_toplam := _toplam + coalesce(_row.tutar, 0);
	END LOOP;
	
	RETURN _toplam;
END;
$$;


ALTER FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) OWNER TO postgres;

--
-- Name: spget_rct_iscilik_maliyet(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
	_row record;
	_toplam numeric;
BEGIN
	_toplam := 0;
	FOR _row IN
		SELECT (i.miktar * ig.fiyat) tutar FROM rct_recete_iscilik i
		LEFT JOIN rct_iscilik_gideri ig ON i.gider_kodu = ig.gider_kodu
		WHERE i.header_id = prct_recete_id
	LOOP
		_toplam := _toplam + coalesce(_row.tutar, 0);
	END LOOP;
	
	RETURN _toplam;
END;
$$;


ALTER FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) OWNER TO postgres;

--
-- Name: spget_rct_toplam(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.spget_rct_toplam(prct_recete_id bigint) RETURNS numeric
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


ALTER FUNCTION public.spget_rct_toplam(prct_recete_id bigint) OWNER TO postgres;

--
-- Name: spget_rct_yan_urun_maliyet(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
	_row record;
	_toplam numeric;
BEGIN
	_toplam := 0;
	FOR _row IN
		SELECT (yu.miktar * s.alis_fiyat) tutar FROM rct_recete_yan_urun yu
		LEFT JOIN stk_stok_karti s ON s.stok_kodu = yu.stok_kodu
		WHERE yu.header_id = prct_recete_id
	LOOP
		_toplam := _toplam - coalesce(_row.tutar, 0);
	END LOOP;

	RETURN _toplam;
END;
$$;


ALTER FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) OWNER TO postgres;

--
-- Name: spget_sys_kalite_form_no(text, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) RETURNS character varying
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$

DECLARE
	formNo text;
BEGIN
	SELECT INTO formNo form_no FROM sys_kalite_form_no WHERE tablo_adi = ptablo_adi AND form_tipi_id = pform_tipi_id;
	RETURN formNo;
end
$$;


ALTER FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) OWNER TO postgres;

--
-- Name: spget_sys_lang_id(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.spget_sys_lang_id(planguage text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
 _id Integer;
BEGIN
	SELECT INTO _id id FROM sys_lang WHERE language=planguage;
	RETURN _id;
END;
$$;


ALTER FUNCTION public.spget_sys_lang_id(planguage text) OWNER TO postgres;

--
-- Name: spget_sys_quality_form_type_id(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.spget_sys_quality_form_type_id(ptype integer) RETURNS integer
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


ALTER FUNCTION public.spget_sys_quality_form_type_id(ptype integer) OWNER TO postgres;

--
-- Name: spget_sys_user_id_list(); Type: FUNCTION; Schema: public; Owner: ths_admin
--

CREATE FUNCTION public.spget_sys_user_id_list() RETURNS TABLE(id bigint, user_name character varying)
    LANGUAGE plpgsql
    AS $$

BEGIN
	RETURN QUERY EXECUTE 
	'SELECT 
		sys_user.id, sys_user.user_name
	FROM sys_user
	WHERE is_active ORDER BY 1';

END
$$;


ALTER FUNCTION public.spget_sys_user_id_list() OWNER TO ths_admin;

--
-- Name: spget_year_week(date, character varying, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean DEFAULT true) RETURNS character varying
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
	--Yıl ve hafta bilgisini getiriyor.
	--Girdiler
	--Tarih, Ayraç, Yıl Önce Gelsin		get_year_week('03.01.2019', '/', True)
	--Çıktılar
	--2019/13
	IF pis_year_first THEN
		RETURN date_part('year', pdate::timestamp without time zone)::text || pseparate || date_part('week', pdate::timestamp without time zone)::text;
	ELSE
		RETURN date_part('week', pdate::timestamp without time zone)::text || pseparate || date_part('year', pdate::timestamp without time zone)::text;
	END IF;		
end
$$;


ALTER FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean) OWNER TO postgres;

--
-- Name: splogin(text, text, text, text); Type: FUNCTION; Schema: public; Owner: ths_admin
--

CREATE FUNCTION public.splogin(puser_name text, puser_pass text, papp_version text, pmac_address text) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare 
	id integer;
	usr record;
begin
	SELECT INTO usr * FROM sys_kullanicilar WHERE kullanici_adi = puser_name;
	IF NOT FOUND THEN
		return -1;	--user not found
	ELSE
		IF usr.is_aktif = false THEN
			return -2;	--user inactive
		ELSE
			SELECT INTO usr * FROM sys_uygulama_ayarlari WHERE versiyon = papp_version;
			IF NOT FOUND THEN
				return -6;	--invalid app version
			ELSE
				SELECT INTO usr * FROM sys_kullanicilar WHERE kullanici_adi = puser_name AND kullanici_sifre = crypt(puser_pass, kullanici_sifre);
				IF NOT FOUND THEN
					RETURN -4;	--invalid password
				ELSE
					UPDATE sys_kullanicilar SET is_aktif=true WHERE sys_kullanicilar.id = usr.id;	
					RETURN usr.id;
				END IF;
			END IF;
		END IF;
	END IF;
end
$$;


ALTER FUNCTION public.splogin(puser_name text, puser_pass text, papp_version text, pmac_address text) OWNER TO ths_admin;

--
-- Name: spset_user_password(text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
	sysUser record;
BEGIN
	SELECT INTO sysUser * FROM sys_kullanicilar WHERE sys_kullanicilar.id = userID AND sys_kullanicilar.kullanici_sifre = crypt(oldPass, sys_kullanicilar.kullanici_sifre);
	IF NOT FOUND THEN
		RETURN False;
	ELSE
		UPDATE sys_kullanicilar SET kullanici_sifre=crypt(newPass, gen_salt('md5')) WHERE sys_kullanicilar.id = userID;	
		RETURN True;
	END IF;
	
END;
$$;


ALTER FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) OWNER TO postgres;

--
-- Name: spvarsayilan_para_birimi(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.spvarsayilan_para_birimi() RETURNS character varying
    LANGUAGE sql
    AS $$
	SELECT para_birimi FROM sys_para_birimi WHERE is_varsayilan LIMIT 1;
$$;


ALTER FUNCTION public.spvarsayilan_para_birimi() OWNER TO postgres;

--
-- Name: spvarsayilan_urun_tipi_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.spvarsayilan_urun_tipi_id() RETURNS integer
    LANGUAGE sql
    AS $$
	SELECT id FROM set_stk_urun_tipi WHERE urun_tipi='HAMMADDE';
$$;


ALTER FUNCTION public.spvarsayilan_urun_tipi_id() OWNER TO postgres;

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
	ELSIF (TG_OP = 'UPDATE') THEN
		PERFORM pg_notify(TG_TABLE_NAME, NEW.id::varchar);
	ELSIF (TG_OP = 'DELETE') THEN
		PERFORM pg_notify(TG_TABLE_NAME, OLD.id::varchar);
	END IF;
	RETURN NEW;
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
-- Name: a_invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.a_invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.a_invoices_id_seq OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: als_teklif_detaylari; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.als_teklif_detaylari (
    id bigint NOT NULL,
    header_id bigint,
    siparis_detay_id bigint,
    irsaliye_detay_id bigint,
    fatura_detay_id bigint,
    stok_kodu character varying(32),
    stok_aciklama character varying(128),
    kullanici_aciklama character varying(128),
    referans character varying(128),
    miktar double precision DEFAULT 1 NOT NULL,
    olcu_birimi character varying(8),
    iskonto_orani numeric(6,3) DEFAULT 0,
    kdv_orani integer DEFAULT 0,
    fiyat numeric(18,6) DEFAULT 0,
    net_fiyat numeric(18,6) DEFAULT 0 NOT NULL,
    tutar numeric(18,6) DEFAULT 0 NOT NULL,
    iskonto_tutar numeric(18,6) DEFAULT 0 NOT NULL,
    net_tutar numeric(18,6) DEFAULT 0 NOT NULL,
    kdv_tutar numeric(18,6) DEFAULT 0 NOT NULL,
    toplam_tutar numeric(18,6) DEFAULT 0 NOT NULL,
    is_ana_urun boolean DEFAULT false NOT NULL,
    referans_ana_urun_id bigint,
    gtip_no character varying(16),
    mensei_ulke_adi character varying(128)
);


ALTER TABLE public.als_teklif_detaylari OWNER TO ths_admin;

--
-- Name: als_teklif_detaylari_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.als_teklif_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.als_teklif_detaylari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: als_teklifler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.als_teklifler (
    id bigint NOT NULL,
    siparis_id bigint,
    irsaliye_id bigint,
    fatura_id bigint,
    is_siparislesti boolean NOT NULL,
    tutar numeric(18,6) DEFAULT 0 NOT NULL,
    iskonto_tutar numeric(18,6) DEFAULT 0 NOT NULL,
    ara_toplam numeric(18,6) DEFAULT 0 NOT NULL,
    kdv_oran1 integer DEFAULT 0 NOT NULL,
    kdv_tutar1 numeric(18,6) DEFAULT 0 NOT NULL,
    kdv_oran2 integer DEFAULT 0 NOT NULL,
    kdv_tutar2 numeric(18,6) DEFAULT 0 NOT NULL,
    kdv_oran3 integer DEFAULT 0 NOT NULL,
    kdv_tutar3 numeric(18,6) DEFAULT 0 NOT NULL,
    kdv_oran4 integer DEFAULT 0 NOT NULL,
    kdv_tutar4 numeric(18,6) DEFAULT 0 NOT NULL,
    kdv_oran5 integer DEFAULT 0 NOT NULL,
    kdv_tutar5 numeric(18,6) DEFAULT 0 NOT NULL,
    genel_toplam numeric(18,6) DEFAULT 0 NOT NULL,
    islem_tipi_id bigint,
    teklif_no character varying(16) NOT NULL,
    teklif_tarihi date NOT NULL,
    gecerlilik_tarihi date NOT NULL,
    musteri_kodu character varying(16),
    musteri_adi character varying(128),
    vergi_dairesi character varying(32) NOT NULL,
    vergi_no character varying(32) NOT NULL,
    ulke_id bigint,
    sehir_id bigint,
    ilce character varying(64),
    mahalle character varying(64),
    semt character varying(64),
    cadde character varying(64),
    sokak character varying(64),
    bina_adi character varying(64),
    kapi_no character varying(16),
    posta_kodu character varying(16),
    web character varying(64),
    email character varying(128),
    musteri_temsilcisi character varying(64),
    muhattap_ad character varying(32),
    muhattap_telefon character varying(24),
    referans character varying(128),
    para_birimi character varying(3) NOT NULL,
    doviz_kuru_usd numeric(7,4) DEFAULT 1,
    doviz_kuru_eur numeric(7,4) DEFAULT 1,
    aciklama character varying(128),
    tevkifat_kodu character varying(8),
    tevkifat_aciklama character varying(128),
    tevkifat_pay smallint,
    tevkifat_payda smallint
);


ALTER TABLE public.als_teklifler OWNER TO ths_admin;

--
-- Name: als_teklifler_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.als_teklifler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.als_teklifler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


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
-- Name: ch_bankalar; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.ch_bankalar (
    id bigint NOT NULL,
    banka_adi character varying(64) NOT NULL,
    swift_kodu character varying(16)
);


ALTER TABLE public.ch_bankalar OWNER TO ths_admin;

--
-- Name: ch_banka_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.ch_bankalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_banka_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: ch_banka_subeleri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.ch_banka_subeleri (
    id bigint NOT NULL,
    banka_id bigint NOT NULL,
    sube_kodu integer NOT NULL,
    sube_adi character varying(64) NOT NULL,
    sehir_id bigint NOT NULL
);


ALTER TABLE public.ch_banka_subeleri OWNER TO ths_admin;

--
-- Name: ch_banka_subesi_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.ch_banka_subeleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_banka_subesi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: ch_bolgeler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.ch_bolgeler (
    id bigint NOT NULL,
    bolge character varying(32) NOT NULL
);


ALTER TABLE public.ch_bolgeler OWNER TO ths_admin;

--
-- Name: ch_bolge_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.ch_bolgeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_bolge_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: ch_doviz_kurlari; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.ch_doviz_kurlari (
    id bigint NOT NULL,
    kur_tarihi date NOT NULL,
    kur numeric(10,4) NOT NULL,
    para character varying(3)
);


ALTER TABLE public.ch_doviz_kurlari OWNER TO ths_admin;

--
-- Name: ch_gruplar; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.ch_gruplar (
    id bigint NOT NULL,
    grup character varying(16) NOT NULL
);


ALTER TABLE public.ch_gruplar OWNER TO ths_admin;

--
-- Name: ch_hesaplar; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.ch_hesaplar (
    id bigint NOT NULL,
    hesap_kodu character varying(16) NOT NULL,
    hesap_ismi character varying(128) NOT NULL,
    hesap_tipi_id bigint NOT NULL,
    grup_id bigint,
    bolge_id bigint,
    mukellef_tipi_id bigint,
    mukellef_adi character varying(32),
    mukellef_adi2 character varying(32),
    mukellef_soyadi character varying(32),
    vergi_dairesi character varying(64),
    vergi_no character varying(32),
    iban character varying(64),
    iban_para character varying(3),
    nace character varying(32),
    yetkili1 character varying(64),
    yetkili1_tel character varying(32),
    yetkili2 character varying(64),
    yetkili2_tel character varying(32),
    yetkili3 character varying(64),
    yetkili3_tel character varying(32),
    faks character varying(32),
    muhasebe_telefon character varying(32),
    muhasebe_email character varying(128),
    muhasebe_yetkili character varying(32),
    ozel_not character varying(512),
    kok_kod character varying(3),
    ara_kod character varying(8),
    iskonto numeric(5,2) DEFAULT 0,
    efatura_kullaniyor boolean DEFAULT false NOT NULL,
    efatura_pb_name character varying(128),
    adres_id bigint,
    pasif boolean DEFAULT false NOT NULL
);


ALTER TABLE public.ch_hesaplar OWNER TO ths_admin;

--
-- Name: ch_hesap_karti_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.ch_hesaplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_hesap_karti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: ch_hesap_planlari; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.ch_hesap_planlari (
    id bigint NOT NULL,
    plan_kodu character varying(16) NOT NULL,
    plan_adi character varying(128) NOT NULL,
    seviye smallint NOT NULL
);


ALTER TABLE public.ch_hesap_planlari OWNER TO ths_admin;

--
-- Name: mhs_doviz_kuru_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.ch_doviz_kurlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_doviz_kuru_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: mhs_fis_detaylari; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.mhs_fis_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL
);


ALTER TABLE public.mhs_fis_detaylari OWNER TO ths_admin;

--
-- Name: mhs_fis_detaylari_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.mhs_fis_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_fis_detaylari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: mhs_fisler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.mhs_fisler (
    id bigint NOT NULL,
    yevmiye_no integer NOT NULL,
    yevmiye_tarihi date
);


ALTER TABLE public.mhs_fisler OWNER TO ths_admin;

--
-- Name: mhs_fisler_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.mhs_fisler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_fisler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: mhs_transfer_kodlari; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.mhs_transfer_kodlari (
    id bigint NOT NULL,
    transfer_kodu character varying(32) NOT NULL,
    aciklama character varying(128) NOT NULL,
    hesap_kodu character varying(16) NOT NULL
);


ALTER TABLE public.mhs_transfer_kodlari OWNER TO ths_admin;

--
-- Name: mhs_transfer_kodlari_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.mhs_transfer_kodlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_transfer_kodlari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prs_ehliyetler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prs_ehliyetler (
    id bigint NOT NULL,
    ehliyet_id bigint,
    personel_id bigint
);


ALTER TABLE public.prs_ehliyetler OWNER TO ths_admin;

--
-- Name: prs_lisan_bilgileri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prs_lisan_bilgileri (
    id bigint NOT NULL,
    lisan_id bigint,
    okuma_id bigint,
    yazma_id bigint,
    konusma_id bigint,
    personel_id bigint
);


ALTER TABLE public.prs_lisan_bilgileri OWNER TO ths_admin;

--
-- Name: prs_lisan_bilgisi_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prs_lisan_bilgileri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
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

ALTER TABLE public.prs_ehliyetler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_personel_ehliyetleri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prs_personeller; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.prs_personeller (
    id bigint NOT NULL,
    ad character varying(32) NOT NULL,
    soyad character varying(32) NOT NULL,
    ad_soyad character varying(64) NOT NULL,
    tel1 character varying(24),
    tel2 character varying(24),
    personel_tipi_id bigint NOT NULL,
    birim_id bigint NOT NULL,
    gorev_id bigint NOT NULL,
    dogum_tarihi date,
    kan_grubu character varying(8),
    cinsiyet smallint NOT NULL,
    askerlik_durumu smallint,
    medeni_durum smallint NOT NULL,
    cocuk_sayisi smallint DEFAULT 0,
    yakin_adi character varying(48),
    yakin_telefon character varying(24),
    ayakkabi_no smallint,
    elbise_bedeni character varying(8),
    genel_not character varying(256),
    tasima_servis_id bigint,
    ozel_not character varying(256),
    maas numeric(18,2) DEFAULT 0,
    ikramiye_sayisi integer DEFAULT 0,
    ikramiye_tutar numeric(18,2) DEFAULT 0,
    identification text,
    adres_id bigint,
    pasif boolean DEFAULT false NOT NULL
);


ALTER TABLE public.prs_personeller OWNER TO ths_admin;

--
-- Name: COLUMN prs_personeller.cinsiyet; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.prs_personeller.cinsiyet IS '1 Man
2 Woman';


--
-- Name: COLUMN prs_personeller.askerlik_durumu; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.prs_personeller.askerlik_durumu IS '1 Yapti, 2 Yapmadi, 3 Tecilli, 4 Muaf';


--
-- Name: COLUMN prs_personeller.medeni_durum; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON COLUMN public.prs_personeller.medeni_durum IS '1 Evli, 2 Bekar';


--
-- Name: prs_personel_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.prs_personeller ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_personel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urt_iscilikler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.urt_iscilikler (
    id bigint NOT NULL,
    gider_kodu character varying(16) NOT NULL,
    gider_adi character varying(128),
    fiyat numeric(18,6) NOT NULL,
    birim_id bigint NOT NULL,
    gider_tipi smallint NOT NULL
);


ALTER TABLE public.urt_iscilikler OWNER TO ths_admin;

--
-- Name: rct_iscilik_gideri_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.urt_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_iscilik_gideri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urt_paket_hammadde_detaylari; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.urt_paket_hammadde_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    recete_id bigint,
    stok_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);


ALTER TABLE public.urt_paket_hammadde_detaylari OWNER TO ths_admin;

--
-- Name: rct_paket_hammadde_detay_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.urt_paket_hammadde_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_hammadde_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urt_paket_hammaddeler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.urt_paket_hammaddeler (
    id bigint NOT NULL,
    paket_adi character varying(128) NOT NULL
);


ALTER TABLE public.urt_paket_hammaddeler OWNER TO ths_admin;

--
-- Name: rct_paket_hammadde_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.urt_paket_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urt_paket_iscilik_detaylari; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.urt_paket_iscilik_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    iscilik_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);


ALTER TABLE public.urt_paket_iscilik_detaylari OWNER TO ths_admin;

--
-- Name: rct_paket_iscilik_detay_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.urt_paket_iscilik_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_iscilik_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urt_paket_iscilikler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.urt_paket_iscilikler (
    id bigint NOT NULL,
    paket_adi character varying(128) NOT NULL
);


ALTER TABLE public.urt_paket_iscilikler OWNER TO ths_admin;

--
-- Name: rct_paket_iscilik_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.urt_paket_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urt_recete_hammaddeler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.urt_recete_hammaddeler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    recete_id bigint,
    stok_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL,
    fire_orani numeric(18,6) DEFAULT 0 NOT NULL
);


ALTER TABLE public.urt_recete_hammaddeler OWNER TO ths_admin;

--
-- Name: rct_recete_hammadde_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.urt_recete_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urt_receteler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.urt_receteler (
    id bigint NOT NULL,
    urun_kodu character varying(32) NOT NULL,
    urun_adi character varying(128) NOT NULL,
    ornek_miktari numeric(18,6) DEFAULT 1,
    aciklama character varying(128)
);


ALTER TABLE public.urt_receteler OWNER TO ths_admin;

--
-- Name: rct_recete_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.urt_receteler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urt_recete_iscilikler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.urt_recete_iscilikler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    iscilik_kodu character varying(16) NOT NULL,
    miktar numeric(18,6) NOT NULL
);


ALTER TABLE public.urt_recete_iscilikler OWNER TO ths_admin;

--
-- Name: rct_recete_iscilik_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.urt_recete_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urt_recete_paket_hammaddeler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.urt_recete_paket_hammaddeler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    paket_id bigint NOT NULL,
    miktar numeric(18,6)
);


ALTER TABLE public.urt_recete_paket_hammaddeler OWNER TO ths_admin;

--
-- Name: rct_recete_paket_hammadde_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.urt_recete_paket_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_paket_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: urt_recete_paket_iscilikler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.urt_recete_paket_iscilikler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    paket_id bigint NOT NULL,
    miktar numeric(18,6)
);


ALTER TABLE public.urt_recete_paket_iscilikler OWNER TO ths_admin;

--
-- Name: rct_recete_paket_iscilik_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.urt_recete_paket_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_paket_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sat_fatura_detaylari; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sat_fatura_detaylari (
    id bigint NOT NULL,
    header_id bigint,
    teklif_detay_id bigint,
    siparis_detay_id bigint,
    irsaliye_detay_id bigint
);


ALTER TABLE public.sat_fatura_detaylari OWNER TO ths_admin;

--
-- Name: sat_fatura_detay_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sat_fatura_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_fatura_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sat_faturalar; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sat_faturalar (
    id bigint NOT NULL,
    fatura_no character varying(16),
    fatura_tarihi timestamp without time zone,
    teklif_id bigint,
    siparis_id bigint,
    irsaliye_id bigint
);


ALTER TABLE public.sat_faturalar OWNER TO ths_admin;

--
-- Name: sat_fatura_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sat_faturalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_fatura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sat_irsaliye_detaylari; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sat_irsaliye_detaylari (
    id bigint NOT NULL,
    header_id bigint,
    teklif_detay_id bigint,
    siparis_detay_id bigint,
    fatura_detay_id bigint
);


ALTER TABLE public.sat_irsaliye_detaylari OWNER TO ths_admin;

--
-- Name: sat_irsaliye_detay_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sat_irsaliye_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_irsaliye_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sat_irsaliyeler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sat_irsaliyeler (
    id bigint NOT NULL,
    irsaliye_no character varying(16),
    irsaliye_tarihi timestamp without time zone,
    teklif_id bigint,
    siparis_id bigint,
    fatura_id bigint
);


ALTER TABLE public.sat_irsaliyeler OWNER TO ths_admin;

--
-- Name: sat_irsaliye_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sat_irsaliyeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_irsaliye_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sat_siparis_detaylari; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sat_siparis_detaylari (
    id bigint NOT NULL,
    header_id bigint,
    teklif_detay_id bigint,
    irsaliye_detay_id bigint,
    fatura_detay_id bigint,
    stok_kodu character varying(32),
    stok_aciklama character varying(128),
    kullanici_aciklama character varying(128),
    referans character varying(128),
    miktar numeric(18,6) DEFAULT 1 NOT NULL,
    giden_miktar numeric(18,6) DEFAULT 1 NOT NULL,
    olcu_birimi character varying(8),
    iskonto_orani numeric(18,6) DEFAULT 0,
    kdv_orani integer DEFAULT 0,
    fiyat numeric(18,6) DEFAULT 0,
    net_fiyat numeric(18,6) DEFAULT 0 NOT NULL,
    tutar numeric(18,6) DEFAULT 0 NOT NULL,
    iskonto_tutar numeric(18,6) DEFAULT 0 NOT NULL,
    net_tutar numeric(18,6) DEFAULT 0 NOT NULL,
    kdv_tutar numeric(18,6) DEFAULT 0 NOT NULL,
    toplam_tutar numeric(18,6) DEFAULT 0 NOT NULL,
    is_ana_urun boolean DEFAULT false NOT NULL,
    referans_ana_urun_id bigint,
    gtip_no character varying(16),
    en numeric(12,6) DEFAULT 0,
    boy numeric(12,6) DEFAULT 0,
    yukseklik numeric(12,6) DEFAULT 0,
    net_agirlik numeric(12,6) DEFAULT 0,
    brut_agirlik numeric(12,6) DEFAULT 0,
    hacim numeric(12,6) DEFAULT 0,
    kab integer
);


ALTER TABLE public.sat_siparis_detaylari OWNER TO ths_admin;

--
-- Name: sat_siparis_detay_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sat_siparis_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_siparis_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sat_siparisler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sat_siparisler (
    id bigint NOT NULL,
    teklif_id bigint,
    irsaliye_id bigint,
    fatura_id bigint,
    tutar numeric(18,6) DEFAULT 0 NOT NULL,
    iskonto_tutar numeric(18,6) DEFAULT 0 NOT NULL,
    ara_toplam numeric(18,6) DEFAULT 0 NOT NULL,
    kdv_oran1 integer DEFAULT 0 NOT NULL,
    kdv_tutar1 numeric(18,6) DEFAULT 0 NOT NULL,
    kdv_oran2 integer DEFAULT 0 NOT NULL,
    kdv_tutar2 numeric(18,6) DEFAULT 0 NOT NULL,
    kdv_oran3 integer DEFAULT 0 NOT NULL,
    kdv_tutar3 numeric(18,6) DEFAULT 0 NOT NULL,
    kdv_oran4 integer DEFAULT 0 NOT NULL,
    kdv_tutar4 numeric(18,6) DEFAULT 0 NOT NULL,
    kdv_oran5 integer DEFAULT 0 NOT NULL,
    kdv_tutar5 numeric(18,6) DEFAULT 0 NOT NULL,
    genel_toplam numeric(18,6) DEFAULT 0 NOT NULL,
    islem_tipi_id bigint,
    siparis_no character varying(16),
    siparis_tarihi date,
    teslim_tarihi date,
    musteri_kodu character varying(16),
    musteri_adi character varying(128),
    vergi_dairesi character varying(32),
    vergi_no character varying(32),
    ulke_id bigint,
    sehir_id bigint,
    ilce character varying(32),
    mahalle character varying(40),
    cadde character varying(40),
    sokak character varying(40),
    posta_kodu character varying(7),
    bina_adi character varying(40),
    kapi_no character varying(6),
    musteri_temsilcisi_id bigint,
    muhattap_ad character varying(32),
    referans character varying(128),
    para_birimi character varying(3) NOT NULL,
    doviz_kuru_usd numeric(7,4) DEFAULT 1,
    doviz_kuru_eur numeric(7,4) DEFAULT 1,
    aciklama character varying(128),
    proforma_no integer,
    siparis_durum_id bigint,
    teslim_sekli_id bigint,
    odeme_sekli_id bigint,
    paket_tipi_id bigint,
    tasima_ucreti_id bigint
);


ALTER TABLE public.sat_siparisler OWNER TO ths_admin;

--
-- Name: sat_siparis_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sat_siparisler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_siparis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_sls_order_status; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_sls_order_status (
    id bigint NOT NULL,
    siparis_durum character varying(32) NOT NULL,
    aciklama character varying(64)
);


ALTER TABLE public.set_sls_order_status OWNER TO ths_admin;

--
-- Name: stk_gruplar; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_gruplar (
    id bigint NOT NULL,
    grup character varying(32) NOT NULL,
    kdv_orani double precision NOT NULL,
    satis_hesap_kodu character varying(16),
    satis_iade_hesap_kodu character varying(16),
    alis_hesap_kodu character varying(16),
    alis_iade_hesap_kodu character varying(16),
    hammadde_stok_hesap_kodu character varying(16),
    hammadde_kullanim_hesap_kodu character varying(16),
    yari_mamul_hesap_kodu character varying(16)
);


ALTER TABLE public.stk_gruplar OWNER TO ths_admin;

--
-- Name: stk_kartlar; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_kartlar (
    id bigint NOT NULL,
    is_satilabilir boolean DEFAULT true,
    stok_kodu character varying(32) NOT NULL,
    stok_adi character varying(128) NOT NULL,
    stok_grubu_id bigint NOT NULL,
    olcu_birimi_id bigint NOT NULL,
    urun_tipi smallint DEFAULT public.spvarsayilan_urun_tipi_id() NOT NULL,
    alis_iskonto numeric(5,2) DEFAULT 0,
    satis_iskonto numeric(5,2) DEFAULT 0,
    alis_fiyat numeric(18,6) DEFAULT 0,
    alis_para character varying(3) DEFAULT public.spvarsayilan_para_birimi() NOT NULL,
    satis_fiyat numeric(18,6) DEFAULT 0,
    satis_para character varying(3) DEFAULT public.spvarsayilan_para_birimi() NOT NULL,
    ihrac_fiyat numeric(18,6) DEFAULT 0,
    ihrac_para character varying(3) DEFAULT public.spvarsayilan_para_birimi() NOT NULL,
    ortalama_maliyet numeric(18,6) DEFAULT 0,
    en double precision DEFAULT 0,
    boy double precision DEFAULT 0,
    yukseklik double precision DEFAULT 0,
    agirlik double precision DEFAULT 0,
    temin_suresi smallint,
    ozel_kod character varying(16),
    marka character varying(32),
    mensei_id bigint,
    gtip_no character varying(16),
    diib_urun_tanimi character varying(64),
    en_az_stok_seviyesi double precision DEFAULT 0,
    tanim character varying(384),
    cins_id bigint,
    s1 character varying(32),
    s2 character varying(32),
    s3 character varying(32),
    s4 character varying(32),
    s5 character varying(32),
    s6 character varying(32),
    s7 character varying(32),
    s8 character varying(32),
    i1 integer,
    i2 integer,
    i3 integer,
    d1 double precision,
    d2 double precision,
    d3 double precision,
    i4 integer,
    d4 double precision
);


ALTER TABLE public.stk_kartlar OWNER TO ths_admin;

--
-- Name: sys_sehirler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_sehirler (
    id bigint NOT NULL,
    sehir character varying(32) NOT NULL,
    plaka_kodu integer,
    ulke_id bigint,
    bolge_id bigint
);


ALTER TABLE public.sys_sehirler OWNER TO ths_admin;

--
-- Name: sat_siparis_rapor; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.sat_siparis_rapor AS
 SELECT sd.id,
    s.musteri_kodu,
    s.musteri_adi,
    ct.sehir AS sehir_adi,
    sg.grup AS stok_grubu,
    sd.stok_kodu,
    sd.stok_aciklama,
    sd.miktar,
    sd.olcu_birimi,
    s.siparis_no,
    s.siparis_tarihi,
    s.teslim_tarihi,
    ss.siparis_durum,
    s.aciklama,
    s.referans,
    sd.referans AS referans_satir
   FROM (((((public.sat_siparis_detaylari sd
     LEFT JOIN public.sat_siparisler s ON ((s.id = sd.header_id)))
     LEFT JOIN public.sys_sehirler ct ON ((ct.id = s.sehir_id)))
     LEFT JOIN public.set_sls_order_status ss ON ((ss.id = s.siparis_durum_id)))
     LEFT JOIN public.stk_kartlar stk ON (((stk.stok_kodu)::text = (sd.stok_kodu)::text)))
     LEFT JOIN public.stk_gruplar sg ON ((sg.id = stk.stok_grubu_id)))
  WHERE (1 = 1);


ALTER TABLE public.sat_siparis_rapor OWNER TO ths_admin;

--
-- Name: sat_teklif_detaylari; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sat_teklif_detaylari (
    id bigint NOT NULL,
    header_id bigint,
    siparis_detay_id bigint,
    irsaliye_detay_id bigint,
    fatura_detay_id bigint,
    stok_kodu character varying(32),
    stok_aciklama character varying(128),
    kullanici_aciklama character varying(128),
    referans character varying(128),
    miktar double precision DEFAULT 1 NOT NULL,
    olcu_birimi character varying(8),
    iskonto_orani numeric(6,3) DEFAULT 0,
    kdv_orani integer DEFAULT 0,
    fiyat numeric(18,6) DEFAULT 0,
    net_fiyat numeric(18,6) DEFAULT 0 NOT NULL,
    tutar numeric(18,6) DEFAULT 0 NOT NULL,
    iskonto_tutar numeric(18,6) DEFAULT 0 NOT NULL,
    net_tutar numeric(18,6) DEFAULT 0 NOT NULL,
    kdv_tutar numeric(18,6) DEFAULT 0 NOT NULL,
    toplam_tutar numeric(18,6) DEFAULT 0 NOT NULL,
    is_ana_urun boolean DEFAULT false NOT NULL,
    referans_ana_urun_id bigint,
    gtip_no character varying(16)
);


ALTER TABLE public.sat_teklif_detaylari OWNER TO ths_admin;

--
-- Name: sat_teklif_detay_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sat_teklif_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_teklif_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sat_teklifler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sat_teklifler (
    id bigint NOT NULL,
    siparis_id bigint,
    irsaliye_id bigint,
    fatura_id bigint,
    is_siparislesti boolean NOT NULL,
    tutar numeric(18,6) DEFAULT 0 NOT NULL,
    iskonto_tutar numeric(18,6) DEFAULT 0 NOT NULL,
    ara_toplam numeric(18,6) DEFAULT 0 NOT NULL,
    kdv_oran1 integer DEFAULT 0 NOT NULL,
    kdv_tutar1 numeric(18,6) DEFAULT 0 NOT NULL,
    kdv_oran2 integer DEFAULT 0 NOT NULL,
    kdv_tutar2 numeric(18,6) DEFAULT 0 NOT NULL,
    kdv_oran3 integer DEFAULT 0 NOT NULL,
    kdv_tutar3 numeric(18,6) DEFAULT 0 NOT NULL,
    kdv_oran4 integer DEFAULT 0 NOT NULL,
    kdv_tutar4 numeric(18,6) DEFAULT 0 NOT NULL,
    kdv_oran5 integer DEFAULT 0 NOT NULL,
    kdv_tutar5 numeric(18,6) DEFAULT 0 NOT NULL,
    genel_toplam numeric(18,6) DEFAULT 0 NOT NULL,
    islem_tipi_id bigint,
    teklif_no character varying(16) NOT NULL,
    teklif_tarihi date NOT NULL,
    gecerlilik_tarihi date NOT NULL,
    musteri_kodu character varying(16),
    musteri_adi character varying(128),
    vergi_dairesi character varying(32) NOT NULL,
    vergi_no character varying(32) NOT NULL,
    ulke_id bigint,
    sehir_id bigint,
    ilce character varying(32),
    mahalle character varying(40),
    cadde character varying(40),
    sokak character varying(40),
    posta_kodu character varying(7),
    bina_adi character varying(40),
    kapi_no character varying(6),
    musteri_temsilcisi_id bigint,
    muhattap_ad character varying(32),
    muhattap_telefon character varying(24),
    referans character varying(128),
    para_birimi character varying(3) NOT NULL,
    doviz_kuru_usd numeric(7,4) DEFAULT 1,
    doviz_kuru_eur numeric(7,4) DEFAULT 1,
    aciklama character varying(128),
    proforma_no integer,
    teslim_sekli_id bigint NOT NULL,
    odeme_sekli_id bigint NOT NULL,
    paket_tipi_id bigint NOT NULL,
    tasima_ucreti_id bigint NOT NULL
);


ALTER TABLE public.sat_teklifler OWNER TO ths_admin;

--
-- Name: sat_teklif_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sat_teklifler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_teklif_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_ch_firma_tipleri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_ch_firma_tipleri (
    id bigint NOT NULL,
    firma_turu_id bigint NOT NULL,
    firma_tipi character varying(48) NOT NULL
);


ALTER TABLE public.set_ch_firma_tipleri OWNER TO ths_admin;

--
-- Name: set_ch_firma_tipi_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_ch_firma_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_firma_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_ch_firma_turleri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_ch_firma_turleri (
    id bigint NOT NULL,
    firma_turu character varying(32) NOT NULL
);


ALTER TABLE public.set_ch_firma_turleri OWNER TO ths_admin;

--
-- Name: set_ch_firma_turu_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_ch_firma_turleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_firma_turu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_ch_grup_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.ch_gruplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_grup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_ch_hesap_plani_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.ch_hesap_planlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_hesap_plani_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_ch_hesap_tipleri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_ch_hesap_tipleri (
    id bigint NOT NULL,
    hesap_tipi character varying(16) NOT NULL
);


ALTER TABLE public.set_ch_hesap_tipleri OWNER TO ths_admin;

--
-- Name: set_ch_hesap_tipi_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_ch_hesap_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_hesap_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_ch_vergi_oranlari; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_ch_vergi_oranlari (
    id bigint NOT NULL,
    vergi_orani numeric(5,2) NOT NULL,
    satis_hesap_kodu character varying(16) NOT NULL,
    satis_iade_hesap_kodu character varying(16) NOT NULL,
    alis_hesap_kodu character varying(16) NOT NULL,
    alis_iade_hesap_kodu character varying(16) NOT NULL,
    ihracat_hesap_kodu character varying(16),
    ihracat_iade_hesap_kodu character varying(16),
    ithalat_hesap_kodu character varying(16),
    ithalat_iade_hesap_kodu character varying(16)
);


ALTER TABLE public.set_ch_vergi_oranlari OWNER TO ths_admin;

--
-- Name: set_ch_vergi_orani_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_ch_vergi_oranlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_vergi_orani_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_einv_fatura_tipleri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_einv_fatura_tipleri (
    id bigint NOT NULL,
    fatura_tipi character varying(32) NOT NULL
);


ALTER TABLE public.set_einv_fatura_tipleri OWNER TO ths_admin;

--
-- Name: set_einv_fatura_tipi_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_einv_fatura_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_fatura_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_einv_odeme_sekilleri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_einv_odeme_sekilleri (
    id bigint NOT NULL,
    odeme_sekli character varying(96),
    kod character varying(16),
    aciklama character varying(512),
    is_efatura boolean DEFAULT false
);


ALTER TABLE public.set_einv_odeme_sekilleri OWNER TO ths_admin;

--
-- Name: set_einv_odeme_sekli_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_einv_odeme_sekilleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_odeme_sekli_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_einv_paket_tipleri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_einv_paket_tipleri (
    id bigint NOT NULL,
    kod character varying(2),
    paket_tipi character varying(128),
    aciklama character varying(512)
);


ALTER TABLE public.set_einv_paket_tipleri OWNER TO ths_admin;

--
-- Name: set_einv_paket_tipi_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_einv_paket_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_paket_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_einv_tasima_ucretleri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_einv_tasima_ucretleri (
    id bigint NOT NULL,
    tasima_ucreti character varying(16)
);


ALTER TABLE public.set_einv_tasima_ucretleri OWNER TO ths_admin;

--
-- Name: set_einv_tasima_ucreti_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_einv_tasima_ucretleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_tasima_ucreti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_einv_teslim_sekilleri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_einv_teslim_sekilleri (
    id bigint NOT NULL,
    teslim_sekli character varying(16) NOT NULL,
    aciklama character varying(96) NOT NULL,
    is_efatura boolean DEFAULT false
);


ALTER TABLE public.set_einv_teslim_sekilleri OWNER TO ths_admin;

--
-- Name: set_einv_teslim_sekli_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_einv_teslim_sekilleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_teslim_sekli_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_prs_birimler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_prs_birimler (
    id bigint NOT NULL,
    birim character varying(32) NOT NULL,
    bolum_id bigint
);


ALTER TABLE public.set_prs_birimler OWNER TO ths_admin;

--
-- Name: set_prs_birim_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_prs_birimler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_birim_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_prs_bolumler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_prs_bolumler (
    id bigint NOT NULL,
    bolum character varying(32) NOT NULL
);


ALTER TABLE public.set_prs_bolumler OWNER TO ths_admin;

--
-- Name: set_prs_bolum_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_prs_bolumler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_bolum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_prs_ehliyetler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_prs_ehliyetler (
    id bigint NOT NULL,
    ehliyet character varying(32) NOT NULL
);


ALTER TABLE public.set_prs_ehliyetler OWNER TO ths_admin;

--
-- Name: set_prs_ehliyet_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_prs_ehliyetler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_ehliyet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_prs_gorevler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_prs_gorevler (
    id bigint NOT NULL,
    gorev character varying(32) NOT NULL
);


ALTER TABLE public.set_prs_gorevler OWNER TO ths_admin;

--
-- Name: set_prs_gorev_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_prs_gorevler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_gorev_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_prs_lisanlar; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_prs_lisanlar (
    id bigint NOT NULL,
    lisan character varying(16) NOT NULL
);


ALTER TABLE public.set_prs_lisanlar OWNER TO ths_admin;

--
-- Name: set_prs_lisan_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_prs_lisanlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_lisan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_prs_lisan_seviyeleri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_prs_lisan_seviyeleri (
    id bigint NOT NULL,
    lisan_seviyesi character varying(16) NOT NULL
);


ALTER TABLE public.set_prs_lisan_seviyeleri OWNER TO ths_admin;

--
-- Name: set_prs_lisan_seviyesi_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_prs_lisan_seviyeleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_lisan_seviyesi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_prs_personel_tipleri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_prs_personel_tipleri (
    id bigint NOT NULL,
    personel_tipi character varying(32) NOT NULL
);


ALTER TABLE public.set_prs_personel_tipleri OWNER TO ths_admin;

--
-- Name: set_prs_personel_tipi_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_prs_personel_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_personel_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_prs_tasima_servisleri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_prs_tasima_servisleri (
    id bigint NOT NULL,
    arac_no smallint NOT NULL,
    arac_adi character varying(32) NOT NULL,
    rota double precision[]
);


ALTER TABLE public.set_prs_tasima_servisleri OWNER TO ths_admin;

--
-- Name: set_prs_servis_araci_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_prs_tasima_servisleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_servis_araci_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_sat_siparis_durum_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_sls_order_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_sat_siparis_durum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_sls_offer_status; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.set_sls_offer_status (
    id bigint NOT NULL,
    teklif_durum character varying(32) NOT NULL,
    aciklama character varying(64)
);


ALTER TABLE public.set_sls_offer_status OWNER TO ths_admin;

--
-- Name: set_sat_teklif_durum_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.set_sls_offer_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_sat_teklif_durum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stk_ambarlar; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_ambarlar (
    id bigint NOT NULL,
    ambar_adi character varying(32),
    is_varsayilan_hammadde boolean DEFAULT false NOT NULL,
    is_varsayilan_uretim boolean DEFAULT false NOT NULL,
    is_varsayilan_satis boolean DEFAULT false NOT NULL
);


ALTER TABLE public.stk_ambarlar OWNER TO ths_admin;

--
-- Name: TABLE stk_ambarlar; Type: COMMENT; Schema: public; Owner: ths_admin
--

COMMENT ON TABLE public.stk_ambarlar IS 'Stok hareketlerinin tutulduğu ambar bilgisi';


--
-- Name: stk_cins_ozellikleri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_cins_ozellikleri (
    id bigint NOT NULL,
    cins character varying(32) NOT NULL,
    aciklama character varying(128),
    s1 character varying(24),
    s2 character varying(24),
    s3 character varying(24),
    s4 character varying(24),
    s5 character varying(24),
    s6 character varying(24),
    s7 character varying(24),
    s8 character varying(24),
    i1 character varying(24),
    i2 character varying(24),
    i3 character varying(24),
    i4 character varying(24),
    d1 character varying(24),
    d2 character varying(24),
    d3 character varying(24),
    d4 character varying(24)
);


ALTER TABLE public.stk_cins_ozellikleri OWNER TO ths_admin;

--
-- Name: stk_cins_ozelligi_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.stk_cins_ozellikleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_cins_ozelligi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stk_hareketler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_hareketler (
    id bigint NOT NULL,
    stok_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL,
    tutar numeric(18,6) NOT NULL,
    tutar_doviz numeric(18,6) NOT NULL,
    para_birimi character varying(3),
    is_giris boolean DEFAULT true,
    tarih timestamp without time zone NOT NULL,
    veren_ambar_id bigint NOT NULL,
    alan_ambar_id bigint NOT NULL,
    is_donem_basi boolean DEFAULT false,
    aciklama character varying(128),
    irsaliye_id bigint,
    uretim_id bigint
);


ALTER TABLE public.stk_hareketler OWNER TO ths_admin;

--
-- Name: stk_hareketler_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.stk_hareketler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_hareketler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stk_kart_ozetleri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_kart_ozetleri (
    id bigint NOT NULL,
    stk_kart_id bigint NOT NULL,
    stok_miktar numeric(18,6) DEFAULT 0,
    ortalama_maliyet numeric(18,6) DEFAULT 0,
    donem_basi_fiyat numeric(18,6) DEFAULT 0,
    donem_basi_miktar numeric(18,6) DEFAULT 0,
    donem_basi_tutar numeric(18,6) DEFAULT 0,
    giren_toplam numeric(18,6) DEFAULT 0,
    giren_toplam_maliyet numeric(18,6) DEFAULT 0,
    cikan_toplam numeric(18,6) DEFAULT 0,
    cikan_toplam_maliyet numeric(18,6) DEFAULT 0,
    son_alis_fiyat numeric(18,6),
    son_alis_para character varying(3),
    son_alis_tarih date,
    son_alis_miktar numeric(18,6) DEFAULT 0,
    son_alis_kur numeric(18,6) DEFAULT 0,
    son_alis_kur_para character varying(3)
);


ALTER TABLE public.stk_kart_ozetleri OWNER TO ths_admin;

--
-- Name: stk_kart_ozetleri_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.stk_kart_ozetleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
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

ALTER TABLE public.stk_kartlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_kartlar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stk_resimler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.stk_resimler (
    id bigint NOT NULL,
    stk_kart_id bigint NOT NULL,
    resim bytea
);


ALTER TABLE public.stk_resimler OWNER TO ths_admin;

--
-- Name: stk_resimler_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.stk_resimler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_resimler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stk_stok_ambar_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.stk_ambarlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
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

ALTER TABLE public.stk_gruplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_stok_grubu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_adresler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_adresler (
    id bigint NOT NULL,
    sehir_id bigint,
    ilce character varying(64),
    mahalle character varying(64),
    semt character varying(64),
    cadde character varying(64),
    sokak character varying(64),
    bina_adi character varying(48),
    kapi_no character varying(16),
    posta_kodu character varying(16),
    web character varying(64),
    email character varying(128)
);


ALTER TABLE public.sys_adresler OWNER TO ths_admin;

--
-- Name: sys_adresler_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_adresler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_adresler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_aylar; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_aylar (
    id bigint NOT NULL,
    ay_adi character varying(16) NOT NULL
);


ALTER TABLE public.sys_aylar OWNER TO ths_admin;

--
-- Name: sys_ay_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_aylar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_bolgeler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_bolgeler (
    id bigint NOT NULL,
    bolge character varying(64) NOT NULL
);


ALTER TABLE public.sys_bolgeler OWNER TO ths_admin;

--
-- Name: sys_bolge_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_bolgeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_bolge_id_seq
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
 SELECT (row_number() OVER (ORDER BY pa.client_addr, pa.usename))::integer AS id,
    pa.pid,
    (pa.datname)::character varying(128) AS db_name,
    (pa.application_name)::character varying(128) AS app_name,
    (pa.usename)::character varying(64) AS user_name,
    (pa.client_addr)::character varying(32) AS client_address,
    (pa.state)::character varying(64) AS state,
    (pa.query)::character varying(1024) AS query,
    (( SELECT string_agg((( SELECT pg_statio_user_tables.relname
                   FROM pg_statio_user_tables
                  WHERE ((pg_statio_user_tables.relid = lck.relation) AND (pg_statio_user_tables.relname IS NOT NULL))))::text, ', '::text) AS string_agg
           FROM pg_locks lck
          WHERE (lck.pid = pa.pid)
          ORDER BY (string_agg((( SELECT pg_statio_user_tables.relname
                   FROM pg_statio_user_tables
                  WHERE ((pg_statio_user_tables.relid = lck.relation) AND (pg_statio_user_tables.relname IS NOT NULL))))::text, ', '::text))))::character varying(1024) AS locked_tables
   FROM pg_stat_activity pa
  WHERE (pa.datname = current_database());


ALTER TABLE public.sys_db_status OWNER TO ths_admin;

--
-- Name: sys_ersim_haklari; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_ersim_haklari (
    id bigint NOT NULL,
    kaynak_id bigint NOT NULL,
    is_okuma boolean DEFAULT false NOT NULL,
    is_ekleme boolean DEFAULT false NOT NULL,
    is_guncelleme boolean DEFAULT false NOT NULL,
    is_silme boolean DEFAULT false NOT NULL,
    is_ozel boolean DEFAULT false NOT NULL,
    kullanici_id bigint NOT NULL
);


ALTER TABLE public.sys_ersim_haklari OWNER TO ths_admin;

--
-- Name: sys_erisim_hakki_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_ersim_haklari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_erisim_hakki_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_grid_filtreler_siralamalar; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_grid_filtreler_siralamalar (
    id bigint NOT NULL,
    tablo_adi character varying(32),
    icerik character varying,
    is_siralama boolean DEFAULT false
);


ALTER TABLE public.sys_grid_filtreler_siralamalar OWNER TO ths_admin;

--
-- Name: sys_grid_filtre_siralama_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_grid_filtreler_siralamalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_filtre_siralama_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_grid_kolonlar; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_grid_kolonlar (
    id bigint NOT NULL,
    tablo_adi character varying(128) NOT NULL,
    kolon_adi character varying(128) NOT NULL,
    sira_no integer DEFAULT 1 NOT NULL,
    kolon_genislik integer DEFAULT 0 NOT NULL,
    veri_formati character varying(16),
    is_gorunur boolean DEFAULT true,
    is_helper_gorunur boolean DEFAULT false,
    min_deger double precision DEFAULT 0,
    min_renk integer DEFAULT 0,
    maks_deger double precision DEFAULT 0,
    maks_renk integer DEFAULT 0,
    maks_deger_yuzdesi double precision DEFAULT 0,
    bar_rengi integer DEFAULT 0,
    bar_arka_rengi integer DEFAULT 0,
    bar_yazi_rengi integer DEFAULT 0
);


ALTER TABLE public.sys_grid_kolonlar OWNER TO ths_admin;

--
-- Name: sys_grid_kolon_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_grid_kolonlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_kolon_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_gunler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_gunler (
    id bigint NOT NULL,
    gun_adi character varying(16) NOT NULL
);


ALTER TABLE public.sys_gunler OWNER TO ths_admin;

--
-- Name: sys_gun_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_gunler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_gun_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_kaynak_gruplari; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_kaynak_gruplari (
    id bigint NOT NULL,
    grup character varying(64) NOT NULL
);


ALTER TABLE public.sys_kaynak_gruplari OWNER TO ths_admin;

--
-- Name: sys_kaynak_grup_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_kaynak_gruplari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kaynak_grup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_kaynaklar; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_kaynaklar (
    id bigint NOT NULL,
    kaynak_kodu integer NOT NULL,
    kaynak_adi character varying(64) NOT NULL,
    kaynak_grup_id bigint NOT NULL
);


ALTER TABLE public.sys_kaynaklar OWNER TO ths_admin;

--
-- Name: sys_kaynak_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_kaynaklar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kaynak_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_kullanicilar; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_kullanicilar (
    id bigint NOT NULL,
    kullanici_adi character varying(64) NOT NULL,
    kullanici_sifre text NOT NULL,
    is_aktif boolean DEFAULT true NOT NULL,
    is_yonetici boolean DEFAULT false NOT NULL,
    is_super_kullanici boolean DEFAULT false NOT NULL,
    ip_adres character varying(32) DEFAULT '127.0.0.1'::character varying NOT NULL,
    mac_adres character varying(32),
    personel_id bigint NOT NULL
);


ALTER TABLE public.sys_kullanicilar OWNER TO ths_admin;

--
-- Name: sys_kullanici_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_kullanicilar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kullanici_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_lisan_gui_icerikler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_lisan_gui_icerikler (
    id bigint NOT NULL,
    lisan character varying(16) NOT NULL,
    kod character varying(64) NOT NULL,
    deger text,
    is_fabrika boolean DEFAULT false NOT NULL,
    icerik_tipi character varying(32) NOT NULL,
    tablo_adi character varying(64),
    form_adi character varying(64)
);


ALTER TABLE public.sys_lisan_gui_icerikler OWNER TO ths_admin;

--
-- Name: sys_lisan_gui_icerik_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_lisan_gui_icerikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_lisan_gui_icerik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_lisanlar; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_lisanlar (
    id bigint NOT NULL,
    lisan character varying(16) NOT NULL
);


ALTER TABLE public.sys_lisanlar OWNER TO ths_admin;

--
-- Name: sys_lisan_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_lisanlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_lisan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_vergi_mukellef_tipleri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_vergi_mukellef_tipleri (
    id bigint NOT NULL,
    mukellef_tipi character varying(32) NOT NULL,
    is_varsayilan boolean DEFAULT false NOT NULL
);


ALTER TABLE public.sys_vergi_mukellef_tipleri OWNER TO ths_admin;

--
-- Name: sys_mukellef_tipi_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_vergi_mukellef_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_mukellef_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_olcu_birimleri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_olcu_birimleri (
    id bigint NOT NULL,
    birim character varying(16) NOT NULL,
    birim_einv character varying(3),
    aciklama character varying(64),
    is_ondalik boolean DEFAULT false NOT NULL,
    birim_tipi_id bigint,
    carpan integer
);


ALTER TABLE public.sys_olcu_birimleri OWNER TO ths_admin;

--
-- Name: sys_olcu_birimi_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_olcu_birimleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_olcu_birimi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_olcu_birimi_tipleri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_olcu_birimi_tipleri (
    id bigint NOT NULL,
    olcu_birimi_tipi character varying(16) NOT NULL
);


ALTER TABLE public.sys_olcu_birimi_tipleri OWNER TO ths_admin;

--
-- Name: sys_olcu_birimi_tipi_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_olcu_birimi_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_olcu_birimi_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_ondalik_haneler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_ondalik_haneler (
    id bigint NOT NULL,
    miktar smallint DEFAULT 2,
    fiyat smallint DEFAULT 2,
    tutar smallint DEFAULT 2,
    stok_miktar smallint DEFAULT 4,
    doviz_kuru smallint DEFAULT 4
);


ALTER TABLE public.sys_ondalik_haneler OWNER TO ths_admin;

--
-- Name: sys_ondalik_hane_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_ondalik_haneler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ondalik_hane_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_para_birimleri; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_para_birimleri (
    id bigint NOT NULL,
    para character varying(3) NOT NULL,
    sembol character varying(3) NOT NULL,
    aciklama character varying(128)
);


ALTER TABLE public.sys_para_birimleri OWNER TO ths_admin;

--
-- Name: sys_para_birimi_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_para_birimleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_para_birimi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_sehir_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_sehirler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_sehir_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_ulkeler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_ulkeler (
    id bigint NOT NULL,
    ulke_kodu character varying(2) NOT NULL,
    ulke_adi character varying(128) NOT NULL,
    iso_year integer,
    iso_cctld character varying(3),
    is_eu_member boolean DEFAULT false NOT NULL
);


ALTER TABLE public.sys_ulkeler OWNER TO ths_admin;

--
-- Name: sys_ulke_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_ulkeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ulke_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sys_uygulama_ayarlari; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.sys_uygulama_ayarlari (
    id bigint NOT NULL,
    logo bytea,
    unvan character varying(128) DEFAULT 'THUNDERSOFT A.Ş.'::character varying NOT NULL,
    telefon character varying(24) DEFAULT '0123 456 78 90'::character varying NOT NULL,
    faks character varying(24),
    vergi_dairesi character varying(32),
    vergi_no character varying(16),
    donem smallint DEFAULT 2018 NOT NULL,
    lisan character varying(16),
    mail_sunucu character varying(255),
    mail_kullanici character varying(255),
    mail_sifre character varying(255),
    mail_smtp_port integer,
    grid_renk_1 integer DEFAULT 13171168 NOT NULL,
    grid_renk_2 integer DEFAULT 7467153 NOT NULL,
    grid_renk_aktif integer DEFAULT 14605509 NOT NULL,
    crypt_key character varying(255) DEFAULT 12345 NOT NULL,
    sms_sunucu character varying(255),
    sms_kullanici character varying(255),
    sms_sifre character varying(255),
    sms_baslik character varying(255),
    versiyon character varying(128),
    para character varying(3),
    adres_id bigint,
    diger_ayarlar json
);


ALTER TABLE public.sys_uygulama_ayarlari OWNER TO ths_admin;

--
-- Name: sys_uygulama_ayari_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.sys_uygulama_ayarlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
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
    initcap(replace((tables.table_name)::text, '_'::text, ' '::text)) AS table_name,
    (tables.table_type)::text AS table_type
   FROM information_schema.tables
  WHERE ((tables.table_schema)::text = 'public'::text)
  ORDER BY tables.table_type, tables.table_name;


ALTER TABLE public.sys_view_tables OWNER TO ths_admin;

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


ALTER TABLE public.sys_view_columns OWNER TO ths_admin;

--
-- Name: sys_view_databases; Type: VIEW; Schema: public; Owner: ths_admin
--

CREATE VIEW public.sys_view_databases AS
 SELECT (pg_database.datname)::text AS database_name,
    pg_shdescription.description AS aciklama
   FROM (pg_shdescription
     JOIN pg_database ON ((pg_shdescription.objoid = pg_database.oid)))
  WHERE ((1 = 1) AND (pg_shdescription.description = 'THS ERP Systems'::text));


ALTER TABLE public.sys_view_databases OWNER TO ths_admin;

--
-- Name: urt_recete_yan_urunler; Type: TABLE; Schema: public; Owner: ths_admin
--

CREATE TABLE public.urt_recete_yan_urunler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    urun_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);


ALTER TABLE public.urt_recete_yan_urunler OWNER TO ths_admin;

--
-- Name: urt_recete_yan_urunler_id_seq; Type: SEQUENCE; Schema: public; Owner: ths_admin
--

ALTER TABLE public.urt_recete_yan_urunler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urt_recete_yan_urunler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: als_teklif_detaylari als_teklif_detaylari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_pkey PRIMARY KEY (id);


--
-- Name: als_teklifler als_teklifler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_pkey PRIMARY KEY (id);


--
-- Name: als_teklifler als_teklifler_teklif_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_teklif_no_key UNIQUE (teklif_no);


--
-- Name: audits audit_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.audits
    ADD CONSTRAINT audit_pkey PRIMARY KEY (id);


--
-- Name: ch_banka_subeleri ch_banka_subeleri_banka_id_sube_kodu_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_banka_id_sube_kodu_key UNIQUE (banka_id, sube_kodu);


--
-- Name: ch_banka_subeleri ch_banka_subeleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_pkey PRIMARY KEY (id);


--
-- Name: ch_bankalar ch_bankalar_banka_adi_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_bankalar
    ADD CONSTRAINT ch_bankalar_banka_adi_key UNIQUE (banka_adi);


--
-- Name: ch_bankalar ch_bankalar_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_bankalar
    ADD CONSTRAINT ch_bankalar_pkey PRIMARY KEY (id);


--
-- Name: ch_bolgeler ch_bolgeler_bolge_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_bolgeler
    ADD CONSTRAINT ch_bolgeler_bolge_key UNIQUE (bolge);


--
-- Name: ch_bolgeler ch_bolgeler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_bolgeler
    ADD CONSTRAINT ch_bolgeler_pkey PRIMARY KEY (id);


--
-- Name: ch_doviz_kurlari ch_doviz_kurlari_kur_tarihi_para_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_kur_tarihi_para_key UNIQUE (kur_tarihi, para);


--
-- Name: ch_doviz_kurlari ch_doviz_kurlari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_pkey PRIMARY KEY (id);


--
-- Name: ch_gruplar ch_gruplar_grup_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_gruplar
    ADD CONSTRAINT ch_gruplar_grup_key UNIQUE (grup);


--
-- Name: ch_gruplar ch_gruplar_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_gruplar
    ADD CONSTRAINT ch_gruplar_pkey PRIMARY KEY (id);


--
-- Name: ch_hesap_planlari ch_hesap_planlari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_hesap_planlari
    ADD CONSTRAINT ch_hesap_planlari_pkey PRIMARY KEY (id);


--
-- Name: ch_hesaplar ch_hesaplar_hesap_kodu_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_hesap_kodu_key UNIQUE (hesap_kodu);


--
-- Name: ch_hesaplar ch_hesaplar_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_pkey PRIMARY KEY (id);


--
-- Name: mhs_fis_detaylari mhs_fis_detaylari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.mhs_fis_detaylari
    ADD CONSTRAINT mhs_fis_detaylari_pkey PRIMARY KEY (id);


--
-- Name: mhs_fisler mhs_fisler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.mhs_fisler
    ADD CONSTRAINT mhs_fisler_pkey PRIMARY KEY (id);


--
-- Name: mhs_fisler mhs_fisler_yevmiye_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.mhs_fisler
    ADD CONSTRAINT mhs_fisler_yevmiye_no_key UNIQUE (yevmiye_no);


--
-- Name: mhs_transfer_kodlari mhs_transfer_kodlari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.mhs_transfer_kodlari
    ADD CONSTRAINT mhs_transfer_kodlari_pkey PRIMARY KEY (id);


--
-- Name: mhs_transfer_kodlari mhs_transfer_kodlari_transfer_kodu_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.mhs_transfer_kodlari
    ADD CONSTRAINT mhs_transfer_kodlari_transfer_kodu_key UNIQUE (transfer_kodu);


--
-- Name: prs_ehliyetler prs_ehliyetler_ehliyet_id_personel_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_ehliyet_id_personel_id_key UNIQUE (ehliyet_id, personel_id);


--
-- Name: prs_ehliyetler prs_ehliyetler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_pkey PRIMARY KEY (id);


--
-- Name: prs_lisan_bilgileri prs_lisan_bilgileri_lisan_id_personel_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_lisan_id_personel_id_key UNIQUE (lisan_id, personel_id);


--
-- Name: prs_lisan_bilgileri prs_lisan_bilgileri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_pkey PRIMARY KEY (id);


--
-- Name: prs_personeller prs_personeller_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_pkey PRIMARY KEY (id);


--
-- Name: sat_fatura_detaylari sat_fatura_detaylari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_fatura_detaylari
    ADD CONSTRAINT sat_fatura_detaylari_pkey PRIMARY KEY (id);


--
-- Name: sat_faturalar sat_faturalar_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_faturalar
    ADD CONSTRAINT sat_faturalar_pkey PRIMARY KEY (id);


--
-- Name: sat_irsaliye_detaylari sat_irsaliye_detaylari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_irsaliye_detaylari
    ADD CONSTRAINT sat_irsaliye_detaylari_pkey PRIMARY KEY (id);


--
-- Name: sat_irsaliyeler sat_irsaliyeler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_irsaliyeler
    ADD CONSTRAINT sat_irsaliyeler_pkey PRIMARY KEY (id);


--
-- Name: sat_siparis_detaylari sat_siparis_detaylari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_pkey PRIMARY KEY (id);


--
-- Name: sat_siparisler sat_siparisler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_pkey PRIMARY KEY (id);


--
-- Name: sat_teklif_detaylari sat_teklif_detaylari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_pkey PRIMARY KEY (id);


--
-- Name: sat_teklifler sat_teklif_teklif_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklif_teklif_no_key UNIQUE (teklif_no);


--
-- Name: sat_teklifler sat_teklifler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_pkey PRIMARY KEY (id);


--
-- Name: set_ch_firma_turleri set_acc_firma_turleri_firma_turu_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_ch_firma_turleri
    ADD CONSTRAINT set_acc_firma_turleri_firma_turu_key UNIQUE (firma_turu);


--
-- Name: set_ch_firma_turleri set_acc_firma_turleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_ch_firma_turleri
    ADD CONSTRAINT set_acc_firma_turleri_pkey PRIMARY KEY (id);


--
-- Name: set_ch_firma_tipleri set_ch_firma_tipleri_firma_tipi_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_firma_tipi_key UNIQUE (firma_tipi);


--
-- Name: set_ch_firma_tipleri set_ch_firma_tipleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_pkey PRIMARY KEY (id);


--
-- Name: set_ch_hesap_tipleri set_ch_hesap_tipleri_hesa_tipi_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_ch_hesap_tipleri
    ADD CONSTRAINT set_ch_hesap_tipleri_hesa_tipi_key UNIQUE (hesap_tipi);


--
-- Name: set_ch_hesap_tipleri set_ch_hesap_tipleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_ch_hesap_tipleri
    ADD CONSTRAINT set_ch_hesap_tipleri_pkey PRIMARY KEY (id);


--
-- Name: set_ch_vergi_oranlari set_ch_vergi_oranlari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_pkey PRIMARY KEY (id);


--
-- Name: set_ch_vergi_oranlari set_ch_vergi_oranlari_veri_orani_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_veri_orani_key UNIQUE (vergi_orani);


--
-- Name: set_einv_fatura_tipleri set_einv_fatura_tipleri_fatura_tipi_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_einv_fatura_tipleri
    ADD CONSTRAINT set_einv_fatura_tipleri_fatura_tipi_key UNIQUE (fatura_tipi);


--
-- Name: set_einv_fatura_tipleri set_einv_fatura_tipleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_einv_fatura_tipleri
    ADD CONSTRAINT set_einv_fatura_tipleri_pkey PRIMARY KEY (id);


--
-- Name: set_einv_odeme_sekilleri set_einv_odeme_sekilleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_einv_odeme_sekilleri
    ADD CONSTRAINT set_einv_odeme_sekilleri_pkey PRIMARY KEY (id);


--
-- Name: set_einv_odeme_sekilleri set_einv_odeme_sekli_odeme_sekilleri_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_einv_odeme_sekilleri
    ADD CONSTRAINT set_einv_odeme_sekli_odeme_sekilleri_key UNIQUE (odeme_sekli);


--
-- Name: set_einv_paket_tipleri set_einv_paket_tipleri_kod_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_einv_paket_tipleri
    ADD CONSTRAINT set_einv_paket_tipleri_kod_key UNIQUE (kod);


--
-- Name: set_einv_paket_tipleri set_einv_paket_tipleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_einv_paket_tipleri
    ADD CONSTRAINT set_einv_paket_tipleri_pkey PRIMARY KEY (id);


--
-- Name: set_einv_tasima_ucretleri set_einv_tasima_ucretleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_einv_tasima_ucretleri
    ADD CONSTRAINT set_einv_tasima_ucretleri_pkey PRIMARY KEY (id);


--
-- Name: set_einv_tasima_ucretleri set_einv_tasima_ucretleri_tasima_ucreti_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_einv_tasima_ucretleri
    ADD CONSTRAINT set_einv_tasima_ucretleri_tasima_ucreti_key UNIQUE (tasima_ucreti);


--
-- Name: set_einv_teslim_sekilleri set_einv_teslim_sekilleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_einv_teslim_sekilleri
    ADD CONSTRAINT set_einv_teslim_sekilleri_pkey PRIMARY KEY (id);


--
-- Name: set_einv_teslim_sekilleri set_einv_teslim_sekilleri_teslim_sekli_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_einv_teslim_sekilleri
    ADD CONSTRAINT set_einv_teslim_sekilleri_teslim_sekli_key UNIQUE (teslim_sekli);


--
-- Name: set_prs_birimler set_prs_birimler_birim_bolum_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_birim_bolum_id_key UNIQUE (birim, bolum_id);


--
-- Name: set_prs_birimler set_prs_birimler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_pkey PRIMARY KEY (id);


--
-- Name: set_prs_bolumler set_prs_bolumler_bolum_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_prs_bolumler
    ADD CONSTRAINT set_prs_bolumler_bolum_key UNIQUE (bolum);


--
-- Name: set_prs_bolumler set_prs_bolumler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_prs_bolumler
    ADD CONSTRAINT set_prs_bolumler_pkey PRIMARY KEY (id);


--
-- Name: set_prs_ehliyetler set_prs_ehliyetler_ehliyet_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_prs_ehliyetler
    ADD CONSTRAINT set_prs_ehliyetler_ehliyet_key UNIQUE (ehliyet);


--
-- Name: set_prs_ehliyetler set_prs_ehliyetler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_prs_ehliyetler
    ADD CONSTRAINT set_prs_ehliyetler_pkey PRIMARY KEY (id);


--
-- Name: set_prs_gorevler set_prs_gorevler_gorev_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_prs_gorevler
    ADD CONSTRAINT set_prs_gorevler_gorev_key UNIQUE (gorev);


--
-- Name: set_prs_gorevler set_prs_gorevler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_prs_gorevler
    ADD CONSTRAINT set_prs_gorevler_pkey PRIMARY KEY (id);


--
-- Name: set_prs_lisan_seviyeleri set_prs_lisan_seviyeleri_lisan_seviyesi_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_prs_lisan_seviyeleri
    ADD CONSTRAINT set_prs_lisan_seviyeleri_lisan_seviyesi_key UNIQUE (lisan_seviyesi);


--
-- Name: set_prs_lisan_seviyeleri set_prs_lisan_seviyeleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_prs_lisan_seviyeleri
    ADD CONSTRAINT set_prs_lisan_seviyeleri_pkey PRIMARY KEY (id);


--
-- Name: set_prs_lisanlar set_prs_lisanlar_lisan_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_prs_lisanlar
    ADD CONSTRAINT set_prs_lisanlar_lisan_key UNIQUE (lisan);


--
-- Name: set_prs_lisanlar set_prs_lisanlar_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_prs_lisanlar
    ADD CONSTRAINT set_prs_lisanlar_pkey PRIMARY KEY (id);


--
-- Name: set_prs_personel_tipleri set_prs_personel_tipleri_personel_tipi_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_prs_personel_tipleri
    ADD CONSTRAINT set_prs_personel_tipleri_personel_tipi_key UNIQUE (personel_tipi);


--
-- Name: set_prs_personel_tipleri set_prs_personel_tipleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_prs_personel_tipleri
    ADD CONSTRAINT set_prs_personel_tipleri_pkey PRIMARY KEY (id);


--
-- Name: set_prs_tasima_servisleri set_prs_tasima_servisleri_arac_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_prs_tasima_servisleri
    ADD CONSTRAINT set_prs_tasima_servisleri_arac_no_key UNIQUE (arac_no);


--
-- Name: set_prs_tasima_servisleri set_prs_tasima_servisleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_prs_tasima_servisleri
    ADD CONSTRAINT set_prs_tasima_servisleri_pkey PRIMARY KEY (id);


--
-- Name: set_sls_order_status set_sat_siparis_durum_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_sls_order_status
    ADD CONSTRAINT set_sat_siparis_durum_pkey PRIMARY KEY (id);


--
-- Name: set_sls_order_status set_sat_siparis_durum_siparis_durum_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_sls_order_status
    ADD CONSTRAINT set_sat_siparis_durum_siparis_durum_key UNIQUE (siparis_durum);


--
-- Name: set_sls_offer_status set_sat_teklif_durum_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_sls_offer_status
    ADD CONSTRAINT set_sat_teklif_durum_pkey PRIMARY KEY (id);


--
-- Name: set_sls_offer_status set_sat_teklif_durum_teklif_durum_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_sls_offer_status
    ADD CONSTRAINT set_sat_teklif_durum_teklif_durum_key UNIQUE (teklif_durum);


--
-- Name: stk_ambarlar stk_ambarlar_ambar_adi_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_ambarlar
    ADD CONSTRAINT stk_ambarlar_ambar_adi_key UNIQUE (ambar_adi);


--
-- Name: stk_ambarlar stk_ambarlar_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_ambarlar
    ADD CONSTRAINT stk_ambarlar_pkey PRIMARY KEY (id);


--
-- Name: stk_cins_ozellikleri stk_cins_ozellikleri_cins_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_cins_ozellikleri
    ADD CONSTRAINT stk_cins_ozellikleri_cins_key UNIQUE (cins);


--
-- Name: stk_cins_ozellikleri stk_cins_ozellikleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_cins_ozellikleri
    ADD CONSTRAINT stk_cins_ozellikleri_pkey PRIMARY KEY (id);


--
-- Name: stk_gruplar stk_gruplar_grup_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_grup_key UNIQUE (grup);


--
-- Name: stk_gruplar stk_gruplar_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_pkey PRIMARY KEY (id);


--
-- Name: stk_hareketler stk_hareketler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_pkey PRIMARY KEY (id);


--
-- Name: stk_kart_ozetleri stk_kart_ozetleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kart_ozetleri
    ADD CONSTRAINT stk_kart_ozetleri_pkey PRIMARY KEY (id);


--
-- Name: stk_kart_ozetleri stk_kart_ozetleri_stk_kart_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kart_ozetleri
    ADD CONSTRAINT stk_kart_ozetleri_stk_kart_id_key UNIQUE (stk_kart_id);


--
-- Name: stk_kartlar stk_kartlar_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_pkey PRIMARY KEY (id);


--
-- Name: stk_kartlar stk_kartlar_stok_kodu_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_stok_kodu_key UNIQUE (stok_kodu);


--
-- Name: stk_resimler stk_resimler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_resimler
    ADD CONSTRAINT stk_resimler_pkey PRIMARY KEY (id);


--
-- Name: stk_resimler stk_resimler_stk_kart_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_resimler
    ADD CONSTRAINT stk_resimler_stk_kart_id_key UNIQUE (stk_kart_id);


--
-- Name: sys_adresler sys_adresler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_adresler
    ADD CONSTRAINT sys_adresler_pkey PRIMARY KEY (id);


--
-- Name: sys_aylar sys_aylar_ay_adi_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_aylar
    ADD CONSTRAINT sys_aylar_ay_adi_key UNIQUE (ay_adi);


--
-- Name: sys_aylar sys_aylar_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_aylar
    ADD CONSTRAINT sys_aylar_pkey PRIMARY KEY (id);


--
-- Name: sys_bolgeler sys_bolgeler_bolge_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_bolgeler
    ADD CONSTRAINT sys_bolgeler_bolge_key UNIQUE (bolge);


--
-- Name: sys_bolgeler sys_bolgeler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_bolgeler
    ADD CONSTRAINT sys_bolgeler_pkey PRIMARY KEY (id);


--
-- Name: sys_ersim_haklari sys_ersim_haklari_kaynak_id_kullanici_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kaynak_id_kullanici_id_key UNIQUE (kaynak_id, kullanici_id);


--
-- Name: sys_ersim_haklari sys_ersim_haklari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_pkey PRIMARY KEY (id);


--
-- Name: sys_grid_filtreler_siralamalar sys_grid_filtreler_siralamalar_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar
    ADD CONSTRAINT sys_grid_filtreler_siralamalar_pkey PRIMARY KEY (id);


--
-- Name: sys_grid_filtreler_siralamalar sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar
    ADD CONSTRAINT sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key UNIQUE (tablo_adi, is_siralama);


--
-- Name: sys_grid_kolonlar sys_grid_kolonlar_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_pkey PRIMARY KEY (id);


--
-- Name: sys_grid_kolonlar sys_grid_kolonlar_tablo_adi_kolon_adi_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_tablo_adi_kolon_adi_key UNIQUE (tablo_adi, kolon_adi);


--
-- Name: sys_grid_kolonlar sys_grid_kolonlar_tablo_adi_sira_no_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_tablo_adi_sira_no_key UNIQUE (tablo_adi, sira_no);


--
-- Name: sys_gunler sys_gunler_gun_adi_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_gunler
    ADD CONSTRAINT sys_gunler_gun_adi_key UNIQUE (gun_adi);


--
-- Name: sys_gunler sys_gunler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_gunler
    ADD CONSTRAINT sys_gunler_pkey PRIMARY KEY (id);


--
-- Name: sys_kaynak_gruplari sys_kaynak_gruplari_grup_ukey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_kaynak_gruplari
    ADD CONSTRAINT sys_kaynak_gruplari_grup_ukey UNIQUE (grup);


--
-- Name: sys_kaynak_gruplari sys_kaynak_gruplari_id_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_kaynak_gruplari
    ADD CONSTRAINT sys_kaynak_gruplari_id_pkey PRIMARY KEY (id);


--
-- Name: sys_kaynaklar sys_kaynaklar_kaynak_kodu_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_kaynak_kodu_key UNIQUE (kaynak_kodu);


--
-- Name: sys_kaynaklar sys_kaynaklar_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_pkey PRIMARY KEY (id);


--
-- Name: sys_lisan_gui_icerikler sys_lisan_gui_icerikler_lisan_kod_icerik_tipi_tablo_adi_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_lisan_gui_icerikler
    ADD CONSTRAINT sys_lisan_gui_icerikler_lisan_kod_icerik_tipi_tablo_adi_key UNIQUE (lisan, kod, icerik_tipi, tablo_adi);


--
-- Name: sys_lisan_gui_icerikler sys_lisan_gui_icerikler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_lisan_gui_icerikler
    ADD CONSTRAINT sys_lisan_gui_icerikler_pkey PRIMARY KEY (id);


--
-- Name: sys_lisanlar sys_lisanlar_lisan_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_lisanlar
    ADD CONSTRAINT sys_lisanlar_lisan_key UNIQUE (lisan);


--
-- Name: sys_lisanlar sys_lisanlar_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_lisanlar
    ADD CONSTRAINT sys_lisanlar_pkey PRIMARY KEY (id);


--
-- Name: sys_olcu_birimi_tipleri sys_olcu_birimi_tipleri_olcu_birimi_tipi_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_olcu_birimi_tipleri
    ADD CONSTRAINT sys_olcu_birimi_tipleri_olcu_birimi_tipi_key UNIQUE (olcu_birimi_tipi);


--
-- Name: sys_olcu_birimi_tipleri sys_olcu_birimi_tipleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_olcu_birimi_tipleri
    ADD CONSTRAINT sys_olcu_birimi_tipleri_pkey PRIMARY KEY (id);


--
-- Name: sys_olcu_birimleri sys_olcu_birimleri_birim_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_birim_key UNIQUE (birim);


--
-- Name: sys_olcu_birimleri sys_olcu_birimleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_pkey PRIMARY KEY (id);


--
-- Name: sys_ondalik_haneler sys_ondalik_haneler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_ondalik_haneler
    ADD CONSTRAINT sys_ondalik_haneler_pkey PRIMARY KEY (id);


--
-- Name: sys_para_birimleri sys_para_birimleri_para_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_para_birimleri
    ADD CONSTRAINT sys_para_birimleri_para_key UNIQUE (para);


--
-- Name: sys_para_birimleri sys_para_birimleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_para_birimleri
    ADD CONSTRAINT sys_para_birimleri_pkey PRIMARY KEY (id);


--
-- Name: sys_sehirler sys_sehirler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_pkey PRIMARY KEY (id);


--
-- Name: sys_sehirler sys_sehirler_ulke_id_sehir_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_ulke_id_sehir_key UNIQUE (ulke_id, sehir);


--
-- Name: sys_ulkeler sys_ulkeler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_ulkeler
    ADD CONSTRAINT sys_ulkeler_pkey PRIMARY KEY (id);


--
-- Name: sys_ulkeler sys_ulkeler_ulke_kodu_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_ulkeler
    ADD CONSTRAINT sys_ulkeler_ulke_kodu_key UNIQUE (ulke_kodu);


--
-- Name: sys_kullanicilar sys_users_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_pkey PRIMARY KEY (id);


--
-- Name: sys_kullanicilar sys_users_username_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_username_key UNIQUE (kullanici_adi);


--
-- Name: sys_uygulama_ayarlari sys_uygulama_ayarlari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_pkey PRIMARY KEY (id);


--
-- Name: sys_vergi_mukellef_tipleri sys_vergi_mukellef_tipleri_mukellef_tipi_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_vergi_mukellef_tipleri
    ADD CONSTRAINT sys_vergi_mukellef_tipleri_mukellef_tipi_key UNIQUE (mukellef_tipi);


--
-- Name: sys_vergi_mukellef_tipleri sys_vergi_mukellef_tipleri_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_vergi_mukellef_tipleri
    ADD CONSTRAINT sys_vergi_mukellef_tipleri_pkey PRIMARY KEY (id);


--
-- Name: urt_iscilikler urt_iscilikler_gider_kodu_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_gider_kodu_key UNIQUE (gider_kodu);


--
-- Name: urt_iscilikler urt_iscilikler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_pkey PRIMARY KEY (id);


--
-- Name: urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_pkey PRIMARY KEY (id);


--
-- Name: urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_stok_kodu_header_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_header_id_key UNIQUE (stok_kodu, header_id);


--
-- Name: urt_paket_hammaddeler urt_paket_hammaddeler_paket_adi_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_paket_hammaddeler
    ADD CONSTRAINT urt_paket_hammaddeler_paket_adi_key UNIQUE (paket_adi);


--
-- Name: urt_paket_hammaddeler urt_paket_hammaddeler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_paket_hammaddeler
    ADD CONSTRAINT urt_paket_hammaddeler_pkey PRIMARY KEY (id);


--
-- Name: urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_pkey PRIMARY KEY (id);


--
-- Name: urt_paket_iscilikler urt_paket_iscilikler_paket_adi_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_paket_iscilikler
    ADD CONSTRAINT urt_paket_iscilikler_paket_adi_key UNIQUE (paket_adi);


--
-- Name: urt_paket_iscilikler urt_paket_iscilikler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_paket_iscilikler
    ADD CONSTRAINT urt_paket_iscilikler_pkey PRIMARY KEY (id);


--
-- Name: urt_recete_hammaddeler urt_recete_hammaddeler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_pkey PRIMARY KEY (id);


--
-- Name: urt_recete_hammaddeler urt_recete_hammaddeler_stok_kodu_header_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_stok_kodu_header_id_key UNIQUE (stok_kodu, header_id);


--
-- Name: urt_recete_iscilikler urt_recete_iscilikler_iscilik_kodu_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_iscilik_kodu_key UNIQUE (iscilik_kodu);


--
-- Name: urt_recete_iscilikler urt_recete_iscilikler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_pkey PRIMARY KEY (id);


--
-- Name: urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_header_id_paket_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_header_id_paket_id_key UNIQUE (header_id, paket_id);


--
-- Name: urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_pkey PRIMARY KEY (id);


--
-- Name: urt_paket_iscilik_detaylari urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key UNIQUE (iscilik_kodu, header_id);


--
-- Name: urt_recete_paket_iscilikler urt_recete_paket_iscilikler_header_id_paket_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_header_id_paket_id_key UNIQUE (header_id, paket_id);


--
-- Name: urt_recete_paket_iscilikler urt_recete_paket_iscilikler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_pkey PRIMARY KEY (id);


--
-- Name: urt_recete_yan_urunler urt_recete_yan_urunler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_pkey PRIMARY KEY (id);


--
-- Name: urt_recete_yan_urunler urt_recete_yan_urunler_urun_kodu_header_id_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_urun_kodu_header_id_key UNIQUE (urun_kodu, header_id);


--
-- Name: urt_receteler urt_receteler_pkey; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_pkey PRIMARY KEY (id);


--
-- Name: urt_receteler urt_receteler_urun_kodu_urun_adi_key; Type: CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_urun_kodu_urun_adi_key UNIQUE (urun_kodu, urun_adi);


--
-- Name: idx_als_teklif_detaylari_header_id; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX idx_als_teklif_detaylari_header_id ON public.als_teklif_detaylari USING btree (header_id);


--
-- Name: idx_sat_siparis_detaylari_header_id; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX idx_sat_siparis_detaylari_header_id ON public.sat_siparis_detaylari USING btree (header_id);


--
-- Name: idx_sat_siparis_musteri_kodu; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX idx_sat_siparis_musteri_kodu ON public.sat_siparisler USING btree (musteri_kodu);


--
-- Name: idx_sat_teklif_detaylari_header_id; Type: INDEX; Schema: public; Owner: ths_admin
--

CREATE INDEX idx_sat_teklif_detaylari_header_id ON public.sat_teklif_detaylari USING btree (header_id);


--
-- Name: set_prs_bolumler audit; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_bolumler FOR EACH ROW EXECUTE FUNCTION public.audit();


--
-- Name: prs_ehliyetler notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prs_ehliyetler FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prs_lisan_bilgileri notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prs_lisan_bilgileri FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: prs_personeller notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prs_personeller FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: set_prs_birimler notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_birimler FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: set_prs_ehliyetler notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_ehliyetler FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: set_prs_gorevler notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_gorevler FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: set_prs_lisan_seviyeleri notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_lisan_seviyeleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: set_prs_lisanlar notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_lisanlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: set_prs_personel_tipleri notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_personel_tipleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: set_prs_tasima_servisleri notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_tasima_servisleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_ambarlar notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_ambarlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_gruplar notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_gruplar FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_hareketler notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_hareketler FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_kartlar notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_kartlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: sys_grid_kolonlar sys_grid_col_width_table_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER sys_grid_col_width_table_notify AFTER INSERT OR DELETE OR UPDATE ON public.sys_grid_kolonlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: set_prs_bolumler table_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER table_notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_bolumler FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: stk_cins_ozellikleri table_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER table_notify BEFORE INSERT OR DELETE OR UPDATE ON public.stk_cins_ozellikleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: ch_banka_subeleri trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_banka_subeleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: ch_bankalar trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_bankalar FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: ch_bolgeler trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_bolgeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: ch_doviz_kurlari trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_doviz_kurlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: ch_hesaplar trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_hesaplar FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: mhs_fis_detaylari trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.mhs_fis_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: mhs_fisler trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.mhs_fisler FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: mhs_transfer_kodlari trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.mhs_transfer_kodlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: set_ch_vergi_oranlari trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.set_ch_vergi_oranlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: urt_iscilikler trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: urt_paket_hammadde_detaylari trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_hammadde_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: urt_paket_hammaddeler trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: urt_paket_iscilik_detaylari trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_iscilik_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: urt_paket_iscilikler trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: urt_recete_hammaddeler trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: urt_recete_iscilikler trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: urt_recete_paket_hammaddeler trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_paket_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: urt_recete_paket_iscilikler trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_paket_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: urt_recete_yan_urunler trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_yan_urunler FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: urt_receteler trg_notify; Type: TRIGGER; Schema: public; Owner: ths_admin
--

CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_receteler FOR EACH ROW EXECUTE FUNCTION public.table_notify();


--
-- Name: als_teklif_detaylari als_teklif_detaylari_header_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.als_teklifler(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: als_teklif_detaylari als_teklif_detaylari_olcu_birimi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_olcu_birimi_fkey FOREIGN KEY (olcu_birimi) REFERENCES public.sys_olcu_birimleri(birim) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: als_teklif_detaylari als_teklif_detaylari_referans_ana_urun_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.als_teklif_detaylari(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: als_teklif_detaylari als_teklif_detaylari_stok_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: als_teklifler als_teklifler_islem_tipi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_islem_tipi_id_fkey FOREIGN KEY (islem_tipi_id) REFERENCES public.set_einv_fatura_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: als_teklifler als_teklifler_musteri_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_musteri_kodu_fkey FOREIGN KEY (musteri_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: als_teklifler als_teklifler_para_birimi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: als_teklifler als_teklifler_sehir_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: als_teklifler als_teklifler_ulke_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ch_banka_subeleri ch_banka_subeleri_banka_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_banka_id_fkey FOREIGN KEY (banka_id) REFERENCES public.ch_bankalar(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ch_banka_subeleri ch_banka_subeleri_sehir_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ch_doviz_kurlari ch_doviz_kurlari_para_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_para_fkey FOREIGN KEY (para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ch_hesaplar ch_hesaplar_bolge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_bolge_id_fkey FOREIGN KEY (bolge_id) REFERENCES public.ch_hesap_planlari(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ch_hesaplar ch_hesaplar_grup_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_grup_id_fkey FOREIGN KEY (grup_id) REFERENCES public.ch_gruplar(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ch_hesaplar ch_hesaplar_hesap_tipi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_hesap_tipi_id_fkey FOREIGN KEY (hesap_tipi_id) REFERENCES public.set_ch_hesap_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ch_hesaplar ch_hesaplar_mukellef_tipi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_mukellef_tipi_id_fkey FOREIGN KEY (mukellef_tipi_id) REFERENCES public.sys_vergi_mukellef_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: mhs_fis_detaylari mhs_fis_detaylari_header_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.mhs_fis_detaylari
    ADD CONSTRAINT mhs_fis_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.mhs_fisler(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mhs_transfer_kodlari mhs_transfer_kodlari_hesap_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.mhs_transfer_kodlari
    ADD CONSTRAINT mhs_transfer_kodlari_hesap_kodu_fkey FOREIGN KEY (hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: prs_ehliyetler prs_ehliyetler_ehliyet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_ehliyet_id_fkey FOREIGN KEY (ehliyet_id) REFERENCES public.set_prs_ehliyetler(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prs_ehliyetler prs_ehliyetler_personel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_personel_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prs_lisan_bilgileri prs_lisan_bilgileri_konusma_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_konusma_id_fkey FOREIGN KEY (konusma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prs_lisan_bilgileri prs_lisan_bilgileri_lisan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_lisan_id_fkey FOREIGN KEY (lisan_id) REFERENCES public.set_prs_lisanlar(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prs_lisan_bilgileri prs_lisan_bilgileri_okuma_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_okuma_id_fkey FOREIGN KEY (okuma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prs_lisan_bilgileri prs_lisan_bilgileri_personel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_personel_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prs_lisan_bilgileri prs_lisan_bilgileri_yazma_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_yazma_id_fkey FOREIGN KEY (yazma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prs_personeller prs_personeller_adres_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_adres_id_fkey FOREIGN KEY (adres_id) REFERENCES public.sys_adresler(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: prs_personeller prs_personeller_birim_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_birim_id_fkey FOREIGN KEY (birim_id) REFERENCES public.set_prs_birimler(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: prs_personeller prs_personeller_gorev_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_gorev_id_fkey FOREIGN KEY (gorev_id) REFERENCES public.set_prs_gorevler(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: prs_personeller prs_personeller_personel_tipi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_personel_tipi_id_fkey FOREIGN KEY (personel_tipi_id) REFERENCES public.set_prs_personel_tipleri(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: prs_personeller prs_personeller_tasima_servis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_tasima_servis_id_fkey FOREIGN KEY (tasima_servis_id) REFERENCES public.set_prs_tasima_servisleri(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sat_fatura_detaylari sat_fatura_detaylari_header_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_fatura_detaylari
    ADD CONSTRAINT sat_fatura_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_faturalar(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sat_irsaliye_detaylari sat_irsaliye_detaylari_header_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_irsaliye_detaylari
    ADD CONSTRAINT sat_irsaliye_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_irsaliyeler(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sat_siparis_detaylari sat_siparis_detaylari_header_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_siparisler(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sat_siparis_detaylari sat_siparis_detaylari_olcu_birimi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_olcu_birimi_fkey FOREIGN KEY (olcu_birimi) REFERENCES public.sys_olcu_birimleri(birim) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_siparis_detaylari sat_siparis_detaylari_referans_ana_urun_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.sat_siparis_detaylari(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_siparis_detaylari sat_siparis_detaylari_stok_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: sat_siparisler sat_siparisler_islem_tipi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_islem_tipi_id_fkey FOREIGN KEY (islem_tipi_id) REFERENCES public.set_einv_fatura_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_siparisler sat_siparisler_musteri_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_musteri_kodu_fkey FOREIGN KEY (musteri_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_siparisler sat_siparisler_musteri_temsilcisi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_musteri_temsilcisi_id_fkey FOREIGN KEY (musteri_temsilcisi_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_siparisler sat_siparisler_nakliye_ucreti_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_nakliye_ucreti_id_fkey FOREIGN KEY (tasima_ucreti_id) REFERENCES public.set_einv_tasima_ucretleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_siparisler sat_siparisler_odeme_sekli_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_odeme_sekli_id_fkey FOREIGN KEY (odeme_sekli_id) REFERENCES public.set_einv_odeme_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_siparisler sat_siparisler_paket_tipi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_paket_tipi_id_fkey FOREIGN KEY (paket_tipi_id) REFERENCES public.set_einv_paket_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_siparisler sat_siparisler_para_birimi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_siparisler sat_siparisler_sehir_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sat_siparisler sat_siparisler_siparis_durum_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_siparis_durum_id_fkey FOREIGN KEY (siparis_durum_id) REFERENCES public.set_sls_order_status(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_siparisler sat_siparisler_teslim_sekli_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_teslim_sekli_id_fkey FOREIGN KEY (teslim_sekli_id) REFERENCES public.set_einv_teslim_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_siparisler sat_siparisler_ulke_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sat_teklif_detaylari sat_teklif_detaylari_header_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_teklifler(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sat_teklif_detaylari sat_teklif_detaylari_olcu_birimi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_olcu_birimi_fkey FOREIGN KEY (olcu_birimi) REFERENCES public.sys_olcu_birimleri(birim) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_teklif_detaylari sat_teklif_detaylari_referans_ana_urun_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.sat_teklif_detaylari(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_teklif_detaylari sat_teklif_detaylari_stok_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: sat_teklifler sat_teklifler_islem_tipi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_islem_tipi_id_fkey FOREIGN KEY (islem_tipi_id) REFERENCES public.set_einv_fatura_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_teklifler sat_teklifler_musteri_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_musteri_kodu_fkey FOREIGN KEY (musteri_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_teklifler sat_teklifler_musteri_temsilcisi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_musteri_temsilcisi_id_fkey FOREIGN KEY (musteri_temsilcisi_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_teklifler sat_teklifler_nakliye_ucreti_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_nakliye_ucreti_id_fkey FOREIGN KEY (tasima_ucreti_id) REFERENCES public.set_einv_tasima_ucretleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_teklifler sat_teklifler_odeme_sekli_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_odeme_sekli_id_fkey FOREIGN KEY (odeme_sekli_id) REFERENCES public.set_einv_odeme_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_teklifler sat_teklifler_paket_tipi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_paket_tipi_id_fkey FOREIGN KEY (paket_tipi_id) REFERENCES public.set_einv_paket_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_teklifler sat_teklifler_para_birimi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_teklifler sat_teklifler_sehir_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_teklifler sat_teklifler_teslim_sekli_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_teslim_sekli_id_fkey FOREIGN KEY (teslim_sekli_id) REFERENCES public.set_einv_teslim_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sat_teklifler sat_teklifler_ulke_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: set_ch_firma_tipleri set_ch_firma_tipleri_firma_turu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_firma_turu_id_fkey FOREIGN KEY (firma_turu_id) REFERENCES public.set_ch_firma_turleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: set_ch_vergi_oranlari set_ch_vergi_oranlari_alis_hesap_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_alis_hesap_kodu_fkey FOREIGN KEY (alis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: set_ch_vergi_oranlari set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey FOREIGN KEY (alis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: set_ch_vergi_oranlari set_ch_vergi_oranlari_ihracat_hesap_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_ihracat_hesap_kodu_fkey FOREIGN KEY (ihracat_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: set_ch_vergi_oranlari set_ch_vergi_oranlari_ihracat_iade_hesap_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_ihracat_iade_hesap_kodu_fkey FOREIGN KEY (ihracat_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: set_ch_vergi_oranlari set_ch_vergi_oranlari_ithalat_hesap_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_ithalat_hesap_kodu_fkey FOREIGN KEY (ithalat_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: set_ch_vergi_oranlari set_ch_vergi_oranlari_ithalat_iade_hesap_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_ithalat_iade_hesap_kodu_fkey FOREIGN KEY (ithalat_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: set_ch_vergi_oranlari set_ch_vergi_oranlari_satis_hesap_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_satis_hesap_kodu_fkey FOREIGN KEY (satis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: set_ch_vergi_oranlari set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey FOREIGN KEY (satis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: set_prs_birimler set_prs_birimler_bolum_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_bolum_id_fkey FOREIGN KEY (bolum_id) REFERENCES public.set_prs_bolumler(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_gruplar stk_gruplar_alis_hesap_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_alis_hesap_kodu_fkey FOREIGN KEY (alis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_gruplar stk_gruplar_alis_iade_hesap_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_alis_iade_hesap_kodu_fkey FOREIGN KEY (alis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_gruplar stk_gruplar_hammadde_kullanim_hesap_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_hammadde_kullanim_hesap_kodu_fkey FOREIGN KEY (hammadde_kullanim_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_gruplar stk_gruplar_hammadde_stok_hesap_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_hammadde_stok_hesap_kodu_fkey FOREIGN KEY (hammadde_stok_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_gruplar stk_gruplar_satis_hesap_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_satis_hesap_kodu_fkey FOREIGN KEY (satis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_gruplar stk_gruplar_satis_iade_hesap_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_satis_iade_hesap_kodu_fkey FOREIGN KEY (satis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_gruplar stk_gruplar_yari_mamul_hesap_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_yari_mamul_hesap_kodu_fkey FOREIGN KEY (yari_mamul_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_hareketler stk_hareketler_alan_ambar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_alan_ambar_id_fkey FOREIGN KEY (alan_ambar_id) REFERENCES public.stk_ambarlar(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_hareketler stk_hareketler_para_birimi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_hareketler stk_hareketler_stok_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: stk_hareketler stk_hareketler_veren_ambar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_veren_ambar_id_fkey FOREIGN KEY (veren_ambar_id) REFERENCES public.stk_ambarlar(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_kart_ozetleri stk_kart_ozetleri_stk_kart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kart_ozetleri
    ADD CONSTRAINT stk_kart_ozetleri_stk_kart_id_fkey FOREIGN KEY (stk_kart_id) REFERENCES public.stk_kartlar(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: stk_kartlar stk_kartlar_alis_para_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_alis_para_fkey FOREIGN KEY (alis_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_kartlar stk_kartlar_cins_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_cins_id_fkey FOREIGN KEY (cins_id) REFERENCES public.stk_cins_ozellikleri(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: stk_kartlar stk_kartlar_ihrac_para_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_ihrac_para_fkey FOREIGN KEY (ihrac_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_kartlar stk_kartlar_mensei_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_mensei_id_fkey FOREIGN KEY (mensei_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_kartlar stk_kartlar_olcu_birimi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_olcu_birimi_id_fkey FOREIGN KEY (olcu_birimi_id) REFERENCES public.sys_olcu_birimleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_kartlar stk_kartlar_satis_para_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_satis_para_fkey FOREIGN KEY (satis_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_kartlar stk_kartlar_stok_grubu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_stok_grubu_id_fkey FOREIGN KEY (stok_grubu_id) REFERENCES public.stk_gruplar(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stk_resimler stk_resimler_stk_kart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.stk_resimler
    ADD CONSTRAINT stk_resimler_stk_kart_id_fkey FOREIGN KEY (stk_kart_id) REFERENCES public.stk_kartlar(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_adresler sys_adresler_sehir_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_adresler
    ADD CONSTRAINT sys_adresler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sys_ersim_haklari sys_ersim_haklari_kaynak_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kaynak_id_fkey FOREIGN KEY (kaynak_id) REFERENCES public.sys_kaynaklar(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_ersim_haklari sys_ersim_haklari_kullanici_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kullanici_id_fkey FOREIGN KEY (kullanici_id) REFERENCES public.sys_kullanicilar(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_kaynaklar sys_kaynaklar_kaynak_grup_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_kaynak_grup_id_fkey FOREIGN KEY (kaynak_grup_id) REFERENCES public.sys_kaynak_gruplari(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sys_lisan_gui_icerikler sys_lisan_gui_icerikler_lisan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_lisan_gui_icerikler
    ADD CONSTRAINT sys_lisan_gui_icerikler_lisan_fkey FOREIGN KEY (lisan) REFERENCES public.sys_lisanlar(lisan) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sys_olcu_birimleri sys_olcu_birimleri_birim_tipi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_birim_tipi_id_fkey FOREIGN KEY (birim_tipi_id) REFERENCES public.sys_olcu_birimi_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: sys_sehirler sys_sehirler_bolge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_bolge_id_fkey FOREIGN KEY (bolge_id) REFERENCES public.sys_bolgeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sys_sehirler sys_sehirler_ulke_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sys_kullanicilar sys_users_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_person_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sys_uygulama_ayarlari sys_uygulama_ayarlari_adres_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_adres_id_fkey FOREIGN KEY (adres_id) REFERENCES public.sys_adresler(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sys_uygulama_ayarlari sys_uygulama_ayarlari_lisan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_lisan_fkey FOREIGN KEY (lisan) REFERENCES public.sys_lisanlar(lisan) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sys_uygulama_ayarlari sys_uygulama_ayarlari_para_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_para_fkey FOREIGN KEY (para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: urt_iscilikler urt_iscilikler_birim_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_birim_id_fkey FOREIGN KEY (birim_id) REFERENCES public.sys_olcu_birimleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: urt_iscilikler urt_iscilikler_gider_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_gider_kodu_fkey FOREIGN KEY (gider_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_header_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_paket_hammaddeler(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_recete_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_recete_id_fkey FOREIGN KEY (recete_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_stok_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_header_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_paket_iscilikler(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_iscilik_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_iscilik_kodu_fkey FOREIGN KEY (iscilik_kodu) REFERENCES public.urt_iscilikler(gider_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: urt_recete_hammaddeler urt_recete_hammaddeler_header_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: urt_recete_hammaddeler urt_recete_hammaddeler_recete_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_recete_id_fkey FOREIGN KEY (recete_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: urt_recete_hammaddeler urt_recete_hammaddeler_stok_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: urt_recete_iscilikler urt_recete_iscilikler_header_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: urt_recete_iscilikler urt_recete_iscilikler_iscilik_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_iscilik_fkey FOREIGN KEY (iscilik_kodu) REFERENCES public.urt_iscilikler(gider_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_header_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_paket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_paket_id_fkey FOREIGN KEY (paket_id) REFERENCES public.urt_paket_hammaddeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: urt_recete_paket_iscilikler urt_recete_paket_iscilikler_header_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: urt_recete_paket_iscilikler urt_recete_paket_iscilikler_paket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_paket_id_fkey FOREIGN KEY (paket_id) REFERENCES public.urt_paket_iscilikler(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: urt_recete_yan_urunler urt_recete_yan_urunler_header_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: urt_recete_yan_urunler urt_recete_yan_urunler_urun_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_urun_kodu_fkey FOREIGN KEY (urun_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: urt_receteler urt_receteler_urun_kodu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ths_admin
--

ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_urun_kodu_fkey FOREIGN KEY (urun_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT CREATE ON SCHEMA public TO PUBLIC;
GRANT ALL ON SCHEMA public TO ths_admin;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.armor(bytea) TO ths_admin;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO ths_admin;


--
-- Name: FUNCTION audit(); Type: ACL; Schema: public; Owner: ths_admin
--

REVOKE ALL ON FUNCTION public.audit() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.audit() FROM ths_admin;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.crypt(text, text) TO ths_admin;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.dearmor(text) TO ths_admin;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO ths_admin;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO ths_admin;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.digest(bytea, text) TO ths_admin;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.digest(text, text) TO ths_admin;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO ths_admin;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO ths_admin;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO ths_admin;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_random_uuid() TO ths_admin;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_salt(text) TO ths_admin;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO ths_admin;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO ths_admin;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.hmac(text, text, text) TO ths_admin;


--
-- Name: FUNCTION personel_adsoyad(); Type: ACL; Schema: public; Owner: ths_admin
--

REVOKE ALL ON FUNCTION public.personel_adsoyad() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.personel_adsoyad() FROM ths_admin;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO ths_admin;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO ths_admin;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO ths_admin;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO ths_admin;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO ths_admin;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO ths_admin;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO ths_admin;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO ths_admin;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO ths_admin;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO ths_admin;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO ths_admin;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO ths_admin;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO ths_admin;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO ths_admin;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO ths_admin;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO ths_admin;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO ths_admin;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO ths_admin;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO ths_admin;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO ths_admin;


--
-- Name: FUNCTION pgrowlocks(relname text, OUT locked_row tid, OUT locker xid, OUT multi boolean, OUT xids xid[], OUT modes text[], OUT pids integer[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgrowlocks(relname text, OUT locked_row tid, OUT locker xid, OUT multi boolean, OUT xids xid[], OUT modes text[], OUT pids integer[]) TO ths_admin;


--
-- Name: FUNCTION postgres_fdw_handler(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgres_fdw_handler() TO ths_admin;


--
-- Name: FUNCTION postgres_fdw_validator(text[], oid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgres_fdw_validator(text[], oid) TO ths_admin;


--
-- Name: FUNCTION spexists_hesap_kodu(phesap_kodu text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.spexists_hesap_kodu(phesap_kodu text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spexists_hesap_kodu(phesap_kodu text) TO ths_admin;


--
-- Name: FUNCTION spget_crypted_data(pval text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.spget_crypted_data(pval text) TO ths_admin;


--
-- Name: FUNCTION spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) TO ths_admin;


--
-- Name: FUNCTION spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) TO ths_admin;


--
-- Name: FUNCTION spget_prs_personel_id_list(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.spget_prs_personel_id_list() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_prs_personel_id_list() TO ths_admin;


--
-- Name: FUNCTION spget_rct_hammadde_maliyet(prct_recete_id bigint); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) TO ths_admin;


--
-- Name: FUNCTION spget_rct_iscilik_maliyet(prct_recete_id bigint); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) TO ths_admin;


--
-- Name: FUNCTION spget_rct_toplam(prct_recete_id bigint); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.spget_rct_toplam(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_toplam(prct_recete_id bigint) TO ths_admin;


--
-- Name: FUNCTION spget_rct_yan_urun_maliyet(prct_recete_id bigint); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) TO ths_admin;


--
-- Name: FUNCTION spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) TO ths_admin;


--
-- Name: FUNCTION spget_sys_lang_id(planguage text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.spget_sys_lang_id(planguage text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_sys_lang_id(planguage text) TO ths_admin;


--
-- Name: FUNCTION spget_sys_quality_form_type_id(ptype integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.spget_sys_quality_form_type_id(ptype integer) TO ths_admin;


--
-- Name: FUNCTION spget_sys_user_id_list(); Type: ACL; Schema: public; Owner: ths_admin
--

REVOKE ALL ON FUNCTION public.spget_sys_user_id_list() FROM PUBLIC;


--
-- Name: FUNCTION spget_year_week(pdate date, pseparate character varying, pis_year_first boolean); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean) TO ths_admin;


--
-- Name: FUNCTION spset_user_password(oldpass text, newpass text, userid integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) TO ths_admin;


--
-- Name: FUNCTION spvarsayilan_para_birimi(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.spvarsayilan_para_birimi() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spvarsayilan_para_birimi() TO ths_admin;


--
-- Name: FUNCTION spvarsayilan_urun_tipi_id(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.spvarsayilan_urun_tipi_id() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spvarsayilan_urun_tipi_id() TO ths_admin;


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

