PGDMP         9                }            ths_erp    14.13    14.13 �   �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16397    ths_erp    DATABASE     f   CREATE DATABASE ths_erp WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'Turkish_Türkiye.utf8';
    DROP DATABASE ths_erp;
             	   ths_admin    false            �           0    0    SCHEMA public    ACL     {   REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT CREATE ON SCHEMA public TO PUBLIC;
GRANT ALL ON SCHEMA public TO ths_admin;
                   postgres    false    3            �           1255    30506    audit()    FUNCTION       CREATE FUNCTION public.audit() RETURNS trigger
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
    DROP FUNCTION public.audit();
       public       	   ths_admin    false            �           0    0    FUNCTION audit()    ACL     i   REVOKE ALL ON FUNCTION public.audit() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.audit() FROM ths_admin;
          public       	   ths_admin    false    389            �           1255    30507    personel_adsoyad()    FUNCTION     ]  CREATE FUNCTION public.personel_adsoyad() RETURNS trigger
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
 )   DROP FUNCTION public.personel_adsoyad();
       public       	   ths_admin    false            �           0    0    FUNCTION personel_adsoyad()    ACL        REVOKE ALL ON FUNCTION public.personel_adsoyad() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.personel_adsoyad() FROM ths_admin;
          public       	   ths_admin    false    387            �           1255    30508 /   spget_lang_text(text, text, text, bigint, text)    FUNCTION     �  CREATE FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) RETURNS character varying
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
 |   DROP FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text);
       public          postgres    false            �           0    0 n   FUNCTION spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text)    ACL     "  REVOKE ALL ON FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) TO ths_admin;
          public          postgres    false    386            �           1255    30509 -   spget_lang_text(text, text, text, text, text)    FUNCTION     �  CREATE FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) RETURNS character varying
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
 |   DROP FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text);
       public          postgres    false            �           0    0 n   FUNCTION spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text)    ACL     "  REVOKE ALL ON FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) TO ths_admin;
          public          postgres    false    390            �           1255    30510 "   spget_rct_hammadde_maliyet(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) RETURNS numeric
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
 H   DROP FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint);
       public          postgres    false            �           0    0 :   FUNCTION spget_rct_hammadde_maliyet(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    388            �           1255    30511 !   spget_rct_iscilik_maliyet(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) RETURNS numeric
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
 G   DROP FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint);
       public          postgres    false            �           0    0 9   FUNCTION spget_rct_iscilik_maliyet(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    385            �           1255    30512    spget_rct_toplam(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_toplam(prct_recete_id bigint) RETURNS numeric
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
 >   DROP FUNCTION public.spget_rct_toplam(prct_recete_id bigint);
       public          postgres    false            �           0    0 0   FUNCTION spget_rct_toplam(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_toplam(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_toplam(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    391            �           1255    30513 "   spget_rct_yan_urun_maliyet(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) RETURNS numeric
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
 H   DROP FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint);
       public          postgres    false            �           0    0 :   FUNCTION spget_rct_yan_urun_maliyet(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    392            �           1255    30514 &   spget_sys_kalite_form_no(text, bigint)    FUNCTION     I  CREATE FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) RETURNS character varying
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$

DECLARE
	formNo text;
BEGIN
	SELECT INTO formNo form_no FROM sys_kalite_form_no WHERE tablo_adi = ptablo_adi AND form_tipi_id = pform_tipi_id;
	RETURN formNo;
end
$$;
 V   DROP FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint);
       public          postgres    false            �           0    0 H   FUNCTION spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) TO ths_admin;
          public          postgres    false    393            �           1255    30515    spget_sys_lang_id(text)    FUNCTION     �   CREATE FUNCTION public.spget_sys_lang_id(planguage text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
 _id Integer;
BEGIN
	SELECT INTO _id id FROM sys_lang WHERE language=planguage;
	RETURN _id;
END;
$$;
 8   DROP FUNCTION public.spget_sys_lang_id(planguage text);
       public          postgres    false            �           0    0 *   FUNCTION spget_sys_lang_id(planguage text)    ACL     �   REVOKE ALL ON FUNCTION public.spget_sys_lang_id(planguage text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_sys_lang_id(planguage text) TO ths_admin;
          public          postgres    false    394            �           1255    30516 '   spget_sys_quality_form_type_id(integer)    FUNCTION     �  CREATE FUNCTION public.spget_sys_quality_form_type_id(ptype integer) RETURNS integer
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
 D   DROP FUNCTION public.spget_sys_quality_form_type_id(ptype integer);
       public          postgres    false            �           0    0 6   FUNCTION spget_sys_quality_form_type_id(ptype integer)    ACL     Y   GRANT ALL ON FUNCTION public.spget_sys_quality_form_type_id(ptype integer) TO ths_admin;
          public          postgres    false    395            �           1255    30517    spvarsayilan_para_birimi()    FUNCTION     �   CREATE FUNCTION public.spvarsayilan_para_birimi() RETURNS character varying
    LANGUAGE sql
    AS $$
	SELECT para_birimi FROM sys_para_birimi WHERE is_varsayilan LIMIT 1;
$$;
 1   DROP FUNCTION public.spvarsayilan_para_birimi();
       public          postgres    false            �           0    0 #   FUNCTION spvarsayilan_para_birimi()    ACL     �   REVOKE ALL ON FUNCTION public.spvarsayilan_para_birimi() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spvarsayilan_para_birimi() TO ths_admin;
          public          postgres    false    396            �           1255    30518    spvarsayilan_urun_tipi_id()    FUNCTION     �   CREATE FUNCTION public.spvarsayilan_urun_tipi_id() RETURNS integer
    LANGUAGE sql
    AS $$
	SELECT id FROM set_stk_urun_tipi WHERE urun_tipi='HAMMADDE';
$$;
 2   DROP FUNCTION public.spvarsayilan_urun_tipi_id();
       public          postgres    false            �           0    0 $   FUNCTION spvarsayilan_urun_tipi_id()    ACL     �   REVOKE ALL ON FUNCTION public.spvarsayilan_urun_tipi_id() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spvarsayilan_urun_tipi_id() TO ths_admin;
          public          postgres    false    397            �           1255    30519    table_listen(text)    FUNCTION     �   CREATE FUNCTION public.table_listen(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT listen table_name;
  RETURN;
END;
$$;
 4   DROP FUNCTION public.table_listen(table_name text);
       public          postgres    false            �           0    0 &   FUNCTION table_listen(table_name text)    ACL     �   REVOKE ALL ON FUNCTION public.table_listen(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_listen(table_name text) TO ths_admin;
          public          postgres    false    398            �           1255    30520    table_notify()    FUNCTION     �  CREATE FUNCTION public.table_notify() RETURNS trigger
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
 %   DROP FUNCTION public.table_notify();
       public       	   ths_admin    false            �           0    0    FUNCTION table_notify()    ACL     w   REVOKE ALL ON FUNCTION public.table_notify() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.table_notify() FROM ths_admin;
          public       	   ths_admin    false    399            �           1255    30521    table_notify(text)    FUNCTION     �   CREATE FUNCTION public.table_notify(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT notify table_name;
  RETURN;
END;
$$;
 4   DROP FUNCTION public.table_notify(table_name text);
       public          postgres    false            �           0    0 &   FUNCTION table_notify(table_name text)    ACL     �   REVOKE ALL ON FUNCTION public.table_notify(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_notify(table_name text) TO ths_admin;
          public          postgres    false    400            �           1255    30522    table_unlisten(text)    FUNCTION     �   CREATE FUNCTION public.table_unlisten(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT unlisten table_name;
  RETURN;
END;
$$;
 6   DROP FUNCTION public.table_unlisten(table_name text);
       public          postgres    false            �           0    0 (   FUNCTION table_unlisten(table_name text)    ACL     �   REVOKE ALL ON FUNCTION public.table_unlisten(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_unlisten(table_name text) TO ths_admin;
          public          postgres    false    401            �            1259    30523    als_teklif_detaylari    TABLE     �  CREATE TABLE public.als_teklif_detaylari (
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
 (   DROP TABLE public.als_teklif_detaylari;
       public         heap 	   ths_admin    false            �            1259    30539    alis_teklif_detaylari_id_seq    SEQUENCE     �   CREATE SEQUENCE public.alis_teklif_detaylari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.alis_teklif_detaylari_id_seq;
       public       	   ths_admin    false    209            �           0    0    alis_teklif_detaylari_id_seq    SEQUENCE OWNED BY     \   ALTER SEQUENCE public.alis_teklif_detaylari_id_seq OWNED BY public.als_teklif_detaylari.id;
          public       	   ths_admin    false    210            �            1259    30540    als_teklifler    TABLE     �  CREATE TABLE public.als_teklifler (
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
 !   DROP TABLE public.als_teklifler;
       public         heap 	   ths_admin    false            �            1259    30561    als_teklifler_id_seq    SEQUENCE     �   ALTER TABLE public.als_teklifler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.als_teklifler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    211            �            1259    30562    audits    TABLE     �  CREATE TABLE public.audits (
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
    DROP TABLE public.audits;
       public         heap 	   ths_admin    false            �            1259    30567    audit_id_seq    SEQUENCE     �   ALTER TABLE public.audits ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    213            �            1259    30568    ch_bankalar    TABLE     �   CREATE TABLE public.ch_bankalar (
    id bigint NOT NULL,
    banka_adi character varying(64) NOT NULL,
    swift_kodu character varying(16)
);
    DROP TABLE public.ch_bankalar;
       public         heap 	   ths_admin    false            �            1259    30571    ch_banka_id_seq    SEQUENCE     �   ALTER TABLE public.ch_bankalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_banka_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    215            �            1259    30572    ch_banka_subeleri    TABLE     �   CREATE TABLE public.ch_banka_subeleri (
    id bigint NOT NULL,
    banka_id bigint NOT NULL,
    sube_kodu integer NOT NULL,
    sube_adi character varying(64) NOT NULL,
    sehir_id bigint NOT NULL
);
 %   DROP TABLE public.ch_banka_subeleri;
       public         heap 	   ths_admin    false            �            1259    30575    ch_banka_subesi_id_seq    SEQUENCE     �   ALTER TABLE public.ch_banka_subeleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_banka_subesi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    217            �            1259    30576    ch_bolgeler    TABLE     f   CREATE TABLE public.ch_bolgeler (
    id bigint NOT NULL,
    bolge character varying(32) NOT NULL
);
    DROP TABLE public.ch_bolgeler;
       public         heap 	   ths_admin    false            �            1259    30579    ch_bolge_id_seq    SEQUENCE     �   ALTER TABLE public.ch_bolgeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_bolge_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    219            �            1259    30580    ch_doviz_kurlari    TABLE     �   CREATE TABLE public.ch_doviz_kurlari (
    id bigint NOT NULL,
    kur_tarihi date NOT NULL,
    kur numeric(10,4) NOT NULL,
    para character varying(3)
);
 $   DROP TABLE public.ch_doviz_kurlari;
       public         heap 	   ths_admin    false            �            1259    30583 
   ch_gruplar    TABLE     d   CREATE TABLE public.ch_gruplar (
    id bigint NOT NULL,
    grup character varying(16) NOT NULL
);
    DROP TABLE public.ch_gruplar;
       public         heap 	   ths_admin    false            �            1259    30586    ch_hesaplar    TABLE     �  CREATE TABLE public.ch_hesaplar (
    id bigint NOT NULL,
    hesap_kodu character varying(16) NOT NULL,
    hesap_ismi character varying(128) NOT NULL,
    hesap_tipi_id bigint NOT NULL,
    grup_id bigint,
    bolge_id bigint,
    mukellef_tipi smallint,
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
    DROP TABLE public.ch_hesaplar;
       public         heap 	   ths_admin    false            �            1259    30594    ch_hesap_karti_id_seq    SEQUENCE     �   ALTER TABLE public.ch_hesaplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_hesap_karti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    223            �            1259    30595    ch_hesap_planlari    TABLE     �   CREATE TABLE public.ch_hesap_planlari (
    id bigint NOT NULL,
    plan_kodu character varying(16) NOT NULL,
    plan_adi character varying(128) NOT NULL,
    seviye smallint NOT NULL
);
 %   DROP TABLE public.ch_hesap_planlari;
       public         heap 	   ths_admin    false            �            1259    30598    mhs_doviz_kuru_id_seq    SEQUENCE     �   ALTER TABLE public.ch_doviz_kurlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_doviz_kuru_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    221            �            1259    30599    mhs_fis_detaylari    TABLE     a   CREATE TABLE public.mhs_fis_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL
);
 %   DROP TABLE public.mhs_fis_detaylari;
       public         heap 	   ths_admin    false            �            1259    30602    mhs_fis_detaylari_id_seq    SEQUENCE     �   ALTER TABLE public.mhs_fis_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_fis_detaylari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    227            �            1259    30603 
   mhs_fisler    TABLE     u   CREATE TABLE public.mhs_fisler (
    id bigint NOT NULL,
    yevmiye_no integer NOT NULL,
    yevmiye_tarihi date
);
    DROP TABLE public.mhs_fisler;
       public         heap 	   ths_admin    false            �            1259    30606    mhs_fisler_id_seq    SEQUENCE     �   ALTER TABLE public.mhs_fisler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_fisler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    229            �            1259    30607    mhs_transfer_kodlari    TABLE     �   CREATE TABLE public.mhs_transfer_kodlari (
    id bigint NOT NULL,
    transfer_kodu character varying(32) NOT NULL,
    aciklama character varying(128) NOT NULL,
    hesap_kodu character varying(16) NOT NULL
);
 (   DROP TABLE public.mhs_transfer_kodlari;
       public         heap 	   ths_admin    false            �            1259    30610    mhs_transfer_kodlari_id_seq    SEQUENCE     �   ALTER TABLE public.mhs_transfer_kodlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_transfer_kodlari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    231            �            1259    30611    prs_ehliyetler    TABLE     n   CREATE TABLE public.prs_ehliyetler (
    id bigint NOT NULL,
    ehliyet_id bigint,
    personel_id bigint
);
 "   DROP TABLE public.prs_ehliyetler;
       public         heap 	   ths_admin    false            �            1259    30614    prs_lisan_bilgileri    TABLE     �   CREATE TABLE public.prs_lisan_bilgileri (
    id bigint NOT NULL,
    lisan_id bigint,
    okuma_id bigint,
    yazma_id bigint,
    konusma_id bigint,
    personel_id bigint
);
 '   DROP TABLE public.prs_lisan_bilgileri;
       public         heap 	   ths_admin    false            �            1259    30617    prs_lisan_bilgisi_id_seq    SEQUENCE     �   ALTER TABLE public.prs_lisan_bilgileri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_lisan_bilgisi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    234            �            1259    30618    prs_personel_ehliyetleri_id_seq    SEQUENCE     �   ALTER TABLE public.prs_ehliyetler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_personel_ehliyetleri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    233            �            1259    30619    prs_personeller    TABLE     �  CREATE TABLE public.prs_personeller (
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
 #   DROP TABLE public.prs_personeller;
       public         heap 	   ths_admin    false            �           0    0    COLUMN prs_personeller.cinsiyet    COMMENT     F   COMMENT ON COLUMN public.prs_personeller.cinsiyet IS '1 Man
2 Woman';
          public       	   ths_admin    false    237            �           0    0 &   COLUMN prs_personeller.askerlik_durumu    COMMENT     e   COMMENT ON COLUMN public.prs_personeller.askerlik_durumu IS '1 Yapti, 2 Yapmadi, 3 Tecilli, 4 Muaf';
          public       	   ths_admin    false    237            �           0    0 #   COLUMN prs_personeller.medeni_durum    COMMENT     L   COMMENT ON COLUMN public.prs_personeller.medeni_durum IS '1 Evli, 2 Bekar';
          public       	   ths_admin    false    237            �            1259    30629    prs_personel_id_seq    SEQUENCE     �   ALTER TABLE public.prs_personeller ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_personel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    237            �            1259    30630    urt_iscilikler    TABLE     �   CREATE TABLE public.urt_iscilikler (
    id bigint NOT NULL,
    gider_kodu character varying(16) NOT NULL,
    gider_adi character varying(128),
    fiyat numeric(18,6) NOT NULL,
    birim_id bigint NOT NULL,
    gider_tipi smallint NOT NULL
);
 "   DROP TABLE public.urt_iscilikler;
       public         heap 	   ths_admin    false            �            1259    30633    rct_iscilik_gideri_id_seq    SEQUENCE     �   ALTER TABLE public.urt_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_iscilik_gideri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    239            �            1259    30634    urt_paket_hammadde_detaylari    TABLE     �   CREATE TABLE public.urt_paket_hammadde_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    recete_id bigint,
    stok_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 0   DROP TABLE public.urt_paket_hammadde_detaylari;
       public         heap 	   ths_admin    false            �            1259    30637    rct_paket_hammadde_detay_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_hammadde_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_hammadde_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    241            �            1259    30638    urt_paket_hammaddeler    TABLE     u   CREATE TABLE public.urt_paket_hammaddeler (
    id bigint NOT NULL,
    paket_adi character varying(128) NOT NULL
);
 )   DROP TABLE public.urt_paket_hammaddeler;
       public         heap 	   ths_admin    false            �            1259    30641    rct_paket_hammadde_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    243            �            1259    30642    urt_paket_iscilik_detaylari    TABLE     �   CREATE TABLE public.urt_paket_iscilik_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    iscilik_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 /   DROP TABLE public.urt_paket_iscilik_detaylari;
       public         heap 	   ths_admin    false            �            1259    30645    rct_paket_iscilik_detay_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_iscilik_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_iscilik_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    245            �            1259    30646    urt_paket_iscilikler    TABLE     t   CREATE TABLE public.urt_paket_iscilikler (
    id bigint NOT NULL,
    paket_adi character varying(128) NOT NULL
);
 (   DROP TABLE public.urt_paket_iscilikler;
       public         heap 	   ths_admin    false            �            1259    30649    rct_paket_iscilik_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    247            �            1259    30650    urt_recete_hammaddeler    TABLE     �   CREATE TABLE public.urt_recete_hammaddeler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    recete_id bigint,
    stok_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL,
    fire_orani numeric(18,6) DEFAULT 0 NOT NULL
);
 *   DROP TABLE public.urt_recete_hammaddeler;
       public         heap 	   ths_admin    false            �            1259    30654    rct_recete_hammadde_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    249            �            1259    30655    urt_receteler    TABLE     �   CREATE TABLE public.urt_receteler (
    id bigint NOT NULL,
    urun_kodu character varying(32) NOT NULL,
    urun_adi character varying(128) NOT NULL,
    ornek_miktari numeric(18,6) DEFAULT 1,
    aciklama character varying(128)
);
 !   DROP TABLE public.urt_receteler;
       public         heap 	   ths_admin    false            �            1259    30659    rct_recete_id_seq    SEQUENCE     �   ALTER TABLE public.urt_receteler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    251            �            1259    30660    urt_recete_iscilikler    TABLE     �   CREATE TABLE public.urt_recete_iscilikler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    iscilik_kodu character varying(16) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 )   DROP TABLE public.urt_recete_iscilikler;
       public         heap 	   ths_admin    false            �            1259    30663    rct_recete_iscilik_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    253            �            1259    30664    urt_recete_paket_hammaddeler    TABLE     �   CREATE TABLE public.urt_recete_paket_hammaddeler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    paket_id bigint NOT NULL,
    miktar numeric(18,6)
);
 0   DROP TABLE public.urt_recete_paket_hammaddeler;
       public         heap 	   ths_admin    false                        1259    30667     rct_recete_paket_hammadde_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_paket_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_paket_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    255                       1259    30668    urt_recete_paket_iscilikler    TABLE     �   CREATE TABLE public.urt_recete_paket_iscilikler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    paket_id bigint NOT NULL,
    miktar numeric(18,6)
);
 /   DROP TABLE public.urt_recete_paket_iscilikler;
       public         heap 	   ths_admin    false                       1259    30671    rct_recete_paket_iscilik_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_paket_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_paket_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    257                       1259    30672    sat_fatura_detaylari    TABLE     �   CREATE TABLE public.sat_fatura_detaylari (
    id bigint NOT NULL,
    header_id bigint,
    teklif_detay_id bigint,
    siparis_detay_id bigint,
    irsaliye_detay_id bigint
);
 (   DROP TABLE public.sat_fatura_detaylari;
       public         heap 	   ths_admin    false                       1259    30675    sat_fatura_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_fatura_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_fatura_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    259                       1259    30676    sat_faturalar    TABLE     �   CREATE TABLE public.sat_faturalar (
    id bigint NOT NULL,
    fatura_no character varying(16),
    fatura_tarihi timestamp without time zone,
    teklif_id bigint,
    siparis_id bigint,
    irsaliye_id bigint
);
 !   DROP TABLE public.sat_faturalar;
       public         heap 	   ths_admin    false                       1259    30679    sat_fatura_id_seq    SEQUENCE     �   ALTER TABLE public.sat_faturalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_fatura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    261                       1259    30680    sat_irsaliye_detaylari    TABLE     �   CREATE TABLE public.sat_irsaliye_detaylari (
    id bigint NOT NULL,
    header_id bigint,
    teklif_detay_id bigint,
    siparis_detay_id bigint,
    fatura_detay_id bigint
);
 *   DROP TABLE public.sat_irsaliye_detaylari;
       public         heap 	   ths_admin    false                       1259    30683    sat_irsaliye_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_irsaliye_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_irsaliye_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    263            	           1259    30684    sat_irsaliyeler    TABLE     �   CREATE TABLE public.sat_irsaliyeler (
    id bigint NOT NULL,
    irsaliye_no character varying(16),
    irsaliye_tarihi timestamp without time zone,
    teklif_id bigint,
    siparis_id bigint,
    fatura_id bigint
);
 #   DROP TABLE public.sat_irsaliyeler;
       public         heap 	   ths_admin    false            
           1259    30687    sat_irsaliye_id_seq    SEQUENCE     �   ALTER TABLE public.sat_irsaliyeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_irsaliye_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    265                       1259    30688    sat_siparis_detaylari    TABLE     �  CREATE TABLE public.sat_siparis_detaylari (
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
 )   DROP TABLE public.sat_siparis_detaylari;
       public         heap 	   ths_admin    false                       1259    30711    sat_siparis_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_siparis_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_siparis_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    267                       1259    30712    sat_siparisler    TABLE     �  CREATE TABLE public.sat_siparisler (
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
 "   DROP TABLE public.sat_siparisler;
       public         heap 	   ths_admin    false                       1259    30733    sat_siparis_id_seq    SEQUENCE     �   ALTER TABLE public.sat_siparisler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_siparis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    269                       1259    30734    set_sls_order_status    TABLE     �   CREATE TABLE public.set_sls_order_status (
    id bigint NOT NULL,
    siparis_durum character varying(32) NOT NULL,
    aciklama character varying(64)
);
 (   DROP TABLE public.set_sls_order_status;
       public         heap 	   ths_admin    false                       1259    30737    stk_gruplar    TABLE     +  CREATE TABLE public.stk_gruplar (
    id bigint NOT NULL,
    grup character varying(32) NOT NULL,
    kdv_orani double precision NOT NULL,
    hammadde_stok_hesap_kodu character varying(16),
    hammadde_kullanim_hesap_kodu character varying(16),
    yari_mamul_hesap_kodu character varying(16)
);
    DROP TABLE public.stk_gruplar;
       public         heap 	   ths_admin    false                       1259    30740    stk_kartlar    TABLE     
  CREATE TABLE public.stk_kartlar (
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
    tanim character varying(384)
);
    DROP TABLE public.stk_kartlar;
       public         heap 	   ths_admin    false    397    396    396    396                       1259    30761    sys_sehirler    TABLE     �   CREATE TABLE public.sys_sehirler (
    id bigint NOT NULL,
    sehir character varying(32) NOT NULL,
    plaka_kodu integer,
    ulke_id bigint,
    bolge_id bigint
);
     DROP TABLE public.sys_sehirler;
       public         heap 	   ths_admin    false                       1259    30764    sat_siparis_rapor    VIEW     )  CREATE VIEW public.sat_siparis_rapor AS
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
 $   DROP VIEW public.sat_siparis_rapor;
       public       	   ths_admin    false    269    269    269    271    271    272    272    273    273    274    274    267    267    267    267    267    267    267    269    269    269    269    269    269    269                       1259    30769    sat_teklif_detaylari    TABLE     �  CREATE TABLE public.sat_teklif_detaylari (
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
 (   DROP TABLE public.sat_teklif_detaylari;
       public         heap 	   ths_admin    false                       1259    30785    sat_teklif_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_teklif_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_teklif_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    276                       1259    30786    sat_teklifler    TABLE     y  CREATE TABLE public.sat_teklifler (
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
 !   DROP TABLE public.sat_teklifler;
       public         heap 	   ths_admin    false                       1259    30807    sat_teklif_id_seq    SEQUENCE     �   ALTER TABLE public.sat_teklifler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_teklif_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    278                       1259    30808    set_ch_firma_tipleri    TABLE     �   CREATE TABLE public.set_ch_firma_tipleri (
    id bigint NOT NULL,
    firma_turu_id bigint NOT NULL,
    firma_tipi character varying(48) NOT NULL
);
 (   DROP TABLE public.set_ch_firma_tipleri;
       public         heap 	   ths_admin    false                       1259    30811    set_ch_firma_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_firma_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_firma_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    280                       1259    30812    set_ch_firma_turleri    TABLE     t   CREATE TABLE public.set_ch_firma_turleri (
    id bigint NOT NULL,
    firma_turu character varying(32) NOT NULL
);
 (   DROP TABLE public.set_ch_firma_turleri;
       public         heap 	   ths_admin    false                       1259    30815    set_ch_firma_turu_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_firma_turleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_firma_turu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    282                       1259    30816    set_ch_grup_id_seq    SEQUENCE     �   ALTER TABLE public.ch_gruplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_grup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    222                       1259    30817    set_ch_hesap_plani_id_seq    SEQUENCE     �   ALTER TABLE public.ch_hesap_planlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_hesap_plani_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    225                       1259    30818    set_ch_hesap_tipleri    TABLE     t   CREATE TABLE public.set_ch_hesap_tipleri (
    id bigint NOT NULL,
    hesap_tipi character varying(16) NOT NULL
);
 (   DROP TABLE public.set_ch_hesap_tipleri;
       public         heap 	   ths_admin    false                       1259    30821    set_ch_hesap_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_hesap_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_hesap_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    286                        1259    30822    set_ch_vergi_oranlari    TABLE     I  CREATE TABLE public.set_ch_vergi_oranlari (
    id bigint NOT NULL,
    vergi_orani numeric(5,2) NOT NULL,
    satis_hesap_kodu character varying(16) NOT NULL,
    satis_iade_hesap_kodu character varying(16) NOT NULL,
    alis_hesap_kodu character varying(16) NOT NULL,
    alis_iade_hesap_kodu character varying(16) NOT NULL
);
 )   DROP TABLE public.set_ch_vergi_oranlari;
       public         heap 	   ths_admin    false            !           1259    30825    set_ch_vergi_orani_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_vergi_oranlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_vergi_orani_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    288            "           1259    30826    set_einv_fatura_tipleri    TABLE     x   CREATE TABLE public.set_einv_fatura_tipleri (
    id bigint NOT NULL,
    fatura_tipi character varying(32) NOT NULL
);
 +   DROP TABLE public.set_einv_fatura_tipleri;
       public         heap 	   ths_admin    false            #           1259    30829    set_einv_fatura_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_fatura_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_fatura_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    290            $           1259    30830    set_einv_odeme_sekilleri    TABLE     �   CREATE TABLE public.set_einv_odeme_sekilleri (
    id bigint NOT NULL,
    odeme_sekli character varying(96),
    kod character varying(16),
    aciklama character varying(512),
    is_efatura boolean DEFAULT false
);
 ,   DROP TABLE public.set_einv_odeme_sekilleri;
       public         heap 	   ths_admin    false            %           1259    30836    set_einv_odeme_sekli_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_odeme_sekilleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_odeme_sekli_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    292            &           1259    30837    set_einv_paket_tipleri    TABLE     �   CREATE TABLE public.set_einv_paket_tipleri (
    id bigint NOT NULL,
    kod character varying(2),
    paket_tipi character varying(128),
    aciklama character varying(512)
);
 *   DROP TABLE public.set_einv_paket_tipleri;
       public         heap 	   ths_admin    false            '           1259    30842    set_einv_paket_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_paket_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_paket_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    294            (           1259    30843    set_einv_tasima_ucretleri    TABLE     s   CREATE TABLE public.set_einv_tasima_ucretleri (
    id bigint NOT NULL,
    tasima_ucreti character varying(16)
);
 -   DROP TABLE public.set_einv_tasima_ucretleri;
       public         heap 	   ths_admin    false            )           1259    30846    set_einv_tasima_ucreti_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_tasima_ucretleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_tasima_ucreti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    296            *           1259    30847    set_einv_teslim_sekilleri    TABLE     �   CREATE TABLE public.set_einv_teslim_sekilleri (
    id bigint NOT NULL,
    teslim_sekli character varying(16) NOT NULL,
    aciklama character varying(96) NOT NULL,
    is_efatura boolean DEFAULT false
);
 -   DROP TABLE public.set_einv_teslim_sekilleri;
       public         heap 	   ths_admin    false            +           1259    30851    set_einv_teslim_sekli_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_teslim_sekilleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_teslim_sekli_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    298            ,           1259    30852    set_prs_birimler    TABLE     �   CREATE TABLE public.set_prs_birimler (
    id bigint NOT NULL,
    birim character varying(32) NOT NULL,
    bolum_id bigint
);
 $   DROP TABLE public.set_prs_birimler;
       public         heap 	   ths_admin    false            -           1259    30855    set_prs_birim_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_birimler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_birim_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    300            .           1259    30856    set_prs_bolumler    TABLE     k   CREATE TABLE public.set_prs_bolumler (
    id bigint NOT NULL,
    bolum character varying(32) NOT NULL
);
 $   DROP TABLE public.set_prs_bolumler;
       public         heap 	   ths_admin    false            /           1259    30859    set_prs_bolum_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_bolumler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_bolum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    302            0           1259    30860    set_prs_ehliyetler    TABLE     o   CREATE TABLE public.set_prs_ehliyetler (
    id bigint NOT NULL,
    ehliyet character varying(32) NOT NULL
);
 &   DROP TABLE public.set_prs_ehliyetler;
       public         heap 	   ths_admin    false            1           1259    30863    set_prs_ehliyet_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_ehliyetler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_ehliyet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    304            2           1259    30864    set_prs_gorevler    TABLE     k   CREATE TABLE public.set_prs_gorevler (
    id bigint NOT NULL,
    gorev character varying(32) NOT NULL
);
 $   DROP TABLE public.set_prs_gorevler;
       public         heap 	   ths_admin    false            3           1259    30867    set_prs_gorev_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_gorevler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_gorev_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    306            4           1259    30868    set_prs_lisanlar    TABLE     k   CREATE TABLE public.set_prs_lisanlar (
    id bigint NOT NULL,
    lisan character varying(16) NOT NULL
);
 $   DROP TABLE public.set_prs_lisanlar;
       public         heap 	   ths_admin    false            5           1259    30871    set_prs_lisan_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_lisanlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_lisan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    308            6           1259    30872    set_prs_lisan_seviyeleri    TABLE     |   CREATE TABLE public.set_prs_lisan_seviyeleri (
    id bigint NOT NULL,
    lisan_seviyesi character varying(16) NOT NULL
);
 ,   DROP TABLE public.set_prs_lisan_seviyeleri;
       public         heap 	   ths_admin    false            7           1259    30875    set_prs_lisan_seviyesi_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_lisan_seviyeleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_lisan_seviyesi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    310            8           1259    30876    set_prs_personel_tipleri    TABLE     {   CREATE TABLE public.set_prs_personel_tipleri (
    id bigint NOT NULL,
    personel_tipi character varying(32) NOT NULL
);
 ,   DROP TABLE public.set_prs_personel_tipleri;
       public         heap 	   ths_admin    false            9           1259    30879    set_prs_personel_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_personel_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_personel_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    312            :           1259    30880    set_prs_tasima_servisleri    TABLE     �   CREATE TABLE public.set_prs_tasima_servisleri (
    id bigint NOT NULL,
    arac_no smallint NOT NULL,
    arac_adi character varying(32) NOT NULL,
    rota double precision[]
);
 -   DROP TABLE public.set_prs_tasima_servisleri;
       public         heap 	   ths_admin    false            ;           1259    30885    set_prs_servis_araci_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_tasima_servisleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_servis_araci_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    314            <           1259    30886    set_sat_siparis_durum_id_seq    SEQUENCE     �   ALTER TABLE public.set_sls_order_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_sat_siparis_durum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    271            =           1259    30887    set_sls_offer_status    TABLE     �   CREATE TABLE public.set_sls_offer_status (
    id bigint NOT NULL,
    teklif_durum character varying(32) NOT NULL,
    aciklama character varying(64)
);
 (   DROP TABLE public.set_sls_offer_status;
       public         heap 	   ths_admin    false            >           1259    30890    set_sat_teklif_durum_id_seq    SEQUENCE     �   ALTER TABLE public.set_sls_offer_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_sat_teklif_durum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    317            ?           1259    30891    stk_ambarlar    TABLE       CREATE TABLE public.stk_ambarlar (
    id bigint NOT NULL,
    ambar_adi character varying(32),
    is_varsayilan_hammadde boolean DEFAULT false NOT NULL,
    is_varsayilan_uretim boolean DEFAULT false NOT NULL,
    is_varsayilan_satis boolean DEFAULT false NOT NULL
);
     DROP TABLE public.stk_ambarlar;
       public         heap 	   ths_admin    false            �           0    0    TABLE stk_ambarlar    COMMENT     X   COMMENT ON TABLE public.stk_ambarlar IS 'Stok hareketlerinin tutulduğu ambar bilgisi';
          public       	   ths_admin    false    319            @           1259    30897    stk_cins_ozellikleri_id_seq    SEQUENCE     �   CREATE SEQUENCE public.stk_cins_ozellikleri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.stk_cins_ozellikleri_id_seq;
       public       	   ths_admin    false            A           1259    30898    stk_cins_ozellikleri    TABLE     ,  CREATE TABLE public.stk_cins_ozellikleri (
    id bigint DEFAULT nextval('public.stk_cins_ozellikleri_id_seq'::regclass) NOT NULL,
    cins character varying(32) NOT NULL,
    aciklama character varying(128),
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
 (   DROP TABLE public.stk_cins_ozellikleri;
       public         heap 	   ths_admin    false    320            B           1259    30904    stk_hareketler    TABLE       CREATE TABLE public.stk_hareketler (
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
 "   DROP TABLE public.stk_hareketler;
       public         heap 	   ths_admin    false            C           1259    30909    stk_hareketler_id_seq    SEQUENCE     �   ALTER TABLE public.stk_hareketler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_hareketler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    322            D           1259    30910    stk_kart_cins_bilgileri_id_seq    SEQUENCE     �   CREATE SEQUENCE public.stk_kart_cins_bilgileri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.stk_kart_cins_bilgileri_id_seq;
       public       	   ths_admin    false            E           1259    30911    stk_kart_cins_bilgileri    TABLE     �  CREATE TABLE public.stk_kart_cins_bilgileri (
    id bigint DEFAULT nextval('public.stk_kart_cins_bilgileri_id_seq'::regclass) NOT NULL,
    stk_kart_id bigint,
    cins_id bigint,
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
 +   DROP TABLE public.stk_kart_cins_bilgileri;
       public         heap 	   ths_admin    false    324            F           1259    30917    stk_kart_ozetleri    TABLE     �  CREATE TABLE public.stk_kart_ozetleri (
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
 %   DROP TABLE public.stk_kart_ozetleri;
       public         heap 	   ths_admin    false            G           1259    30931    stk_kart_ozetleri_id_seq    SEQUENCE     �   ALTER TABLE public.stk_kart_ozetleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_kart_ozetleri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    326            H           1259    30932    stk_kartlar_id_seq    SEQUENCE     �   ALTER TABLE public.stk_kartlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_kartlar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    273            I           1259    30933    stk_resimler    TABLE     �   CREATE TABLE public.stk_resimler (
    id bigint NOT NULL,
    stk_kart_id bigint NOT NULL,
    resim bytea,
    dosya_adi character varying
);
     DROP TABLE public.stk_resimler;
       public         heap 	   ths_admin    false            J           1259    30938    stk_resimler_id_seq    SEQUENCE     �   ALTER TABLE public.stk_resimler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_resimler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    329            K           1259    30939    stk_stok_ambar_id_seq    SEQUENCE     �   ALTER TABLE public.stk_ambarlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_stok_ambar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    319            L           1259    30940    stk_stok_grubu_id_seq    SEQUENCE     �   ALTER TABLE public.stk_gruplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_stok_grubu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    272            M           1259    30941    sys_adresler    TABLE     �  CREATE TABLE public.sys_adresler (
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
     DROP TABLE public.sys_adresler;
       public         heap 	   ths_admin    false            N           1259    30946    sys_adresler_id_seq    SEQUENCE     �   ALTER TABLE public.sys_adresler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_adresler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    333            O           1259    30947 	   sys_aylar    TABLE     e   CREATE TABLE public.sys_aylar (
    id bigint NOT NULL,
    ay_adi character varying(16) NOT NULL
);
    DROP TABLE public.sys_aylar;
       public         heap 	   ths_admin    false            P           1259    30950    sys_ay_id_seq    SEQUENCE     �   ALTER TABLE public.sys_aylar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    335            Q           1259    30951    sys_bolgeler    TABLE     g   CREATE TABLE public.sys_bolgeler (
    id bigint NOT NULL,
    bolge character varying(64) NOT NULL
);
     DROP TABLE public.sys_bolgeler;
       public         heap 	   ths_admin    false            R           1259    30954    sys_bolge_id_seq    SEQUENCE     �   ALTER TABLE public.sys_bolgeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_bolge_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    337            S           1259    30955    sys_db_status    VIEW     �  CREATE VIEW public.sys_db_status AS
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
     DROP VIEW public.sys_db_status;
       public       	   ths_admin    false            T           1259    30960    sys_ersim_haklari    TABLE     i  CREATE TABLE public.sys_ersim_haklari (
    id bigint NOT NULL,
    kaynak_id bigint NOT NULL,
    is_okuma boolean DEFAULT false NOT NULL,
    is_ekleme boolean DEFAULT false NOT NULL,
    is_guncelleme boolean DEFAULT false NOT NULL,
    is_silme boolean DEFAULT false NOT NULL,
    is_ozel boolean DEFAULT false NOT NULL,
    kullanici_id bigint NOT NULL
);
 %   DROP TABLE public.sys_ersim_haklari;
       public         heap 	   ths_admin    false            U           1259    30968    sys_erisim_hakki_id_seq    SEQUENCE     �   ALTER TABLE public.sys_ersim_haklari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_erisim_hakki_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    340            V           1259    30969    sys_grid_filtreler_siralamalar    TABLE     �   CREATE TABLE public.sys_grid_filtreler_siralamalar (
    id bigint NOT NULL,
    tablo_adi character varying(32),
    icerik character varying,
    is_siralama boolean DEFAULT false
);
 2   DROP TABLE public.sys_grid_filtreler_siralamalar;
       public         heap 	   ths_admin    false            W           1259    30975    sys_grid_filtre_siralama_id_seq    SEQUENCE     �   ALTER TABLE public.sys_grid_filtreler_siralamalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_filtre_siralama_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    342            X           1259    30976    sys_grid_kolonlar    TABLE     �  CREATE TABLE public.sys_grid_kolonlar (
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
 %   DROP TABLE public.sys_grid_kolonlar;
       public         heap 	   ths_admin    false            Y           1259    30991    sys_grid_kolon_id_seq    SEQUENCE     �   ALTER TABLE public.sys_grid_kolonlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_kolon_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    344            Z           1259    30992    sys_gui_icerikler    TABLE     "  CREATE TABLE public.sys_gui_icerikler (
    id bigint NOT NULL,
    kod character varying(64) NOT NULL,
    deger text,
    is_fabrika boolean DEFAULT false NOT NULL,
    icerik_tipi character varying(32) NOT NULL,
    tablo_adi character varying(64),
    form_adi character varying(64)
);
 %   DROP TABLE public.sys_gui_icerikler;
       public         heap 	   ths_admin    false            [           1259    30998 
   sys_gunler    TABLE     g   CREATE TABLE public.sys_gunler (
    id bigint NOT NULL,
    gun_adi character varying(16) NOT NULL
);
    DROP TABLE public.sys_gunler;
       public         heap 	   ths_admin    false            \           1259    31001    sys_gun_id_seq    SEQUENCE     �   ALTER TABLE public.sys_gunler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_gun_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    347            ]           1259    31002    sys_kaynak_gruplari    TABLE     m   CREATE TABLE public.sys_kaynak_gruplari (
    id bigint NOT NULL,
    grup character varying(64) NOT NULL
);
 '   DROP TABLE public.sys_kaynak_gruplari;
       public         heap 	   ths_admin    false            ^           1259    31005    sys_kaynak_grup_id_seq    SEQUENCE     �   ALTER TABLE public.sys_kaynak_gruplari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kaynak_grup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    349            _           1259    31006    sys_kaynaklar    TABLE     �   CREATE TABLE public.sys_kaynaklar (
    id bigint NOT NULL,
    kaynak_kodu integer NOT NULL,
    kaynak_adi character varying(64) NOT NULL,
    kaynak_grup_id bigint NOT NULL
);
 !   DROP TABLE public.sys_kaynaklar;
       public         heap 	   ths_admin    false            `           1259    31009    sys_kaynak_id_seq    SEQUENCE     �   ALTER TABLE public.sys_kaynaklar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kaynak_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    351            a           1259    31010    sys_kullanicilar    TABLE     �  CREATE TABLE public.sys_kullanicilar (
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
 $   DROP TABLE public.sys_kullanicilar;
       public         heap 	   ths_admin    false            b           1259    31019    sys_kullanici_id_seq    SEQUENCE     �   ALTER TABLE public.sys_kullanicilar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kullanici_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    353            c           1259    31020    sys_lisan_gui_icerik_id_seq    SEQUENCE     �   ALTER TABLE public.sys_gui_icerikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_lisan_gui_icerik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    346            d           1259    31021    sys_olcu_birimleri    TABLE       CREATE TABLE public.sys_olcu_birimleri (
    id bigint NOT NULL,
    birim character varying(16) NOT NULL,
    birim_einv character varying(3),
    aciklama character varying(64),
    is_ondalik boolean DEFAULT false NOT NULL,
    birim_tipi_id bigint,
    carpan integer
);
 &   DROP TABLE public.sys_olcu_birimleri;
       public         heap 	   ths_admin    false            e           1259    31025    sys_olcu_birimi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_olcu_birimleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_olcu_birimi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    356            f           1259    31026    sys_olcu_birimi_tipleri    TABLE     }   CREATE TABLE public.sys_olcu_birimi_tipleri (
    id bigint NOT NULL,
    olcu_birimi_tipi character varying(16) NOT NULL
);
 +   DROP TABLE public.sys_olcu_birimi_tipleri;
       public         heap 	   ths_admin    false            g           1259    31029    sys_olcu_birimi_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_olcu_birimi_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_olcu_birimi_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    358            h           1259    31030    sys_ondalik_haneler    TABLE     �   CREATE TABLE public.sys_ondalik_haneler (
    id bigint NOT NULL,
    miktar smallint DEFAULT 2,
    fiyat smallint DEFAULT 2,
    tutar smallint DEFAULT 2,
    stok_miktar smallint DEFAULT 4,
    doviz_kuru smallint DEFAULT 4
);
 '   DROP TABLE public.sys_ondalik_haneler;
       public         heap 	   ths_admin    false            i           1259    31038    sys_ondalik_hane_id_seq    SEQUENCE     �   ALTER TABLE public.sys_ondalik_haneler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ondalik_hane_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    360            j           1259    31039    sys_para_birimleri    TABLE     �   CREATE TABLE public.sys_para_birimleri (
    id bigint NOT NULL,
    para character varying(3) NOT NULL,
    sembol character varying(3) NOT NULL,
    aciklama character varying(128)
);
 &   DROP TABLE public.sys_para_birimleri;
       public         heap 	   ths_admin    false            k           1259    31042    sys_para_birimi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_para_birimleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_para_birimi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    362            l           1259    31043    sys_sehir_id_seq    SEQUENCE     �   ALTER TABLE public.sys_sehirler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_sehir_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    274            m           1259    31044    sys_ulkeler    TABLE       CREATE TABLE public.sys_ulkeler (
    id bigint NOT NULL,
    ulke_kodu character varying(2) NOT NULL,
    ulke_adi character varying(128) NOT NULL,
    iso_year integer,
    iso_cctld character varying(3),
    is_eu_member boolean DEFAULT false NOT NULL
);
    DROP TABLE public.sys_ulkeler;
       public         heap 	   ths_admin    false            n           1259    31048    sys_ulke_id_seq    SEQUENCE     �   ALTER TABLE public.sys_ulkeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ulke_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    365            o           1259    31049    sys_uygulama_ayarlari    TABLE     �  CREATE TABLE public.sys_uygulama_ayarlari (
    id bigint NOT NULL,
    unvan character varying(128) DEFAULT 'THUNDERSOFT A.Ş.'::character varying NOT NULL,
    telefon character varying(24) DEFAULT '0123 456 78 90'::character varying NOT NULL,
    faks character varying(24),
    vergi_dairesi character varying(32),
    vergi_no character varying(16),
    donem smallint DEFAULT 2018 NOT NULL,
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
    diger_ayarlar jsonb,
    mukellef_adi character varying(64),
    mukellef_soyadi character varying,
    mukellef_tipi character varying(8),
    logo bytea
);
 )   DROP TABLE public.sys_uygulama_ayarlari;
       public         heap 	   ths_admin    false            �           0    0 )   COLUMN sys_uygulama_ayarlari.mukellef_adi    COMMENT     f   COMMENT ON COLUMN public.sys_uygulama_ayarlari.mukellef_adi IS 'Şahış şirket için kullanılır';
          public       	   ths_admin    false    367            �           0    0 ,   COLUMN sys_uygulama_ayarlari.mukellef_soyadi    COMMENT     i   COMMENT ON COLUMN public.sys_uygulama_ayarlari.mukellef_soyadi IS 'Şahıs şirketi için kullanılır';
          public       	   ths_admin    false    367            �           0    0 *   COLUMN sys_uygulama_ayarlari.mukellef_tipi    COMMENT     L   COMMENT ON COLUMN public.sys_uygulama_ayarlari.mukellef_tipi IS 'TCKN
VKN';
          public       	   ths_admin    false    367            p           1259    31061    sys_uygulama_ayari_id_seq    SEQUENCE     �   ALTER TABLE public.sys_uygulama_ayarlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_uygulama_ayari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    367            q           1259    31062    sys_view_tables    VIEW     �  CREATE VIEW public.sys_view_tables AS
 SELECT (row_number() OVER (ORDER BY tables.table_type, tables.table_name))::integer AS id,
    initcap(replace((tables.table_name)::text, '_'::text, ' '::text)) AS table_name,
    (tables.table_type)::text AS table_type
   FROM information_schema.tables
  WHERE ((tables.table_schema)::text = 'public'::text)
  ORDER BY (tables.table_type)::text, (initcap(replace((tables.table_name)::text, '_'::text, ' '::text)));
 "   DROP VIEW public.sys_view_tables;
       public       	   ths_admin    false            r           1259    31066    sys_view_columns    VIEW     '  CREATE VIEW public.sys_view_columns AS
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
 #   DROP VIEW public.sys_view_columns;
       public       	   ths_admin    false    369    369            s           1259    31071    sys_view_databases    VIEW     >  CREATE VIEW public.sys_view_databases AS
 SELECT (pg_database.datname)::text AS database_name,
    pg_shdescription.description AS aciklama
   FROM (pg_shdescription
     JOIN pg_database ON ((pg_shdescription.objoid = pg_database.oid)))
  WHERE ((1 = 1) AND (pg_shdescription.description = 'THS ERP Systems'::text));
 %   DROP VIEW public.sys_view_databases;
       public       	   ths_admin    false            t           1259    31075    urt_recete_yan_urunler    TABLE     �   CREATE TABLE public.urt_recete_yan_urunler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    urun_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 *   DROP TABLE public.urt_recete_yan_urunler;
       public         heap 	   ths_admin    false            u           1259    31078    urt_recete_yan_urunler_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_yan_urunler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urt_recete_yan_urunler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    372                       2604    31079    als_teklif_detaylari id    DEFAULT     �   ALTER TABLE ONLY public.als_teklif_detaylari ALTER COLUMN id SET DEFAULT nextval('public.alis_teklif_detaylari_id_seq'::regclass);
 F   ALTER TABLE public.als_teklif_detaylari ALTER COLUMN id DROP DEFAULT;
       public       	   ths_admin    false    210    209                      0    30523    als_teklif_detaylari 
   TABLE DATA           c  COPY public.als_teklif_detaylari (id, header_id, siparis_detay_id, irsaliye_detay_id, fatura_detay_id, stok_kodu, stok_aciklama, kullanici_aciklama, referans, miktar, olcu_birimi, iskonto_orani, kdv_orani, fiyat, net_fiyat, tutar, iskonto_tutar, net_tutar, kdv_tutar, toplam_tutar, is_ana_urun, referans_ana_urun_id, gtip_no, mensei_ulke_adi) FROM stdin;
    public       	   ths_admin    false    209   '                0    30540    als_teklifler 
   TABLE DATA           �  COPY public.als_teklifler (id, siparis_id, irsaliye_id, fatura_id, is_siparislesti, tutar, iskonto_tutar, ara_toplam, kdv_oran1, kdv_tutar1, kdv_oran2, kdv_tutar2, kdv_oran3, kdv_tutar3, kdv_oran4, kdv_tutar4, kdv_oran5, kdv_tutar5, genel_toplam, islem_tipi_id, teklif_no, teklif_tarihi, gecerlilik_tarihi, musteri_kodu, musteri_adi, vergi_dairesi, vergi_no, ulke_id, sehir_id, ilce, mahalle, semt, cadde, sokak, bina_adi, kapi_no, posta_kodu, web, email, musteri_temsilcisi, muhattap_ad, muhattap_telefon, referans, para_birimi, doviz_kuru_usd, doviz_kuru_eur, aciklama, tevkifat_kodu, tevkifat_aciklama, tevkifat_pay, tevkifat_payda) FROM stdin;
    public       	   ths_admin    false    211   D                0    30562    audits 
   TABLE DATA           �   COPY public.audits (id, user_name, ip_address, table_name, access_type, time_of_change, row_id, client_username, old_val, new_val) FROM stdin;
    public       	   ths_admin    false    213   a      	          0    30572    ch_banka_subeleri 
   TABLE DATA           X   COPY public.ch_banka_subeleri (id, banka_id, sube_kodu, sube_adi, sehir_id) FROM stdin;
    public       	   ths_admin    false    217   �                0    30568    ch_bankalar 
   TABLE DATA           @   COPY public.ch_bankalar (id, banka_adi, swift_kodu) FROM stdin;
    public       	   ths_admin    false    215   �                0    30576    ch_bolgeler 
   TABLE DATA           0   COPY public.ch_bolgeler (id, bolge) FROM stdin;
    public       	   ths_admin    false    219   -                0    30580    ch_doviz_kurlari 
   TABLE DATA           E   COPY public.ch_doviz_kurlari (id, kur_tarihi, kur, para) FROM stdin;
    public       	   ths_admin    false    221   �                0    30583 
   ch_gruplar 
   TABLE DATA           .   COPY public.ch_gruplar (id, grup) FROM stdin;
    public       	   ths_admin    false    222   �                0    30595    ch_hesap_planlari 
   TABLE DATA           L   COPY public.ch_hesap_planlari (id, plan_kodu, plan_adi, seviye) FROM stdin;
    public       	   ths_admin    false    225                   0    30586    ch_hesaplar 
   TABLE DATA           �  COPY public.ch_hesaplar (id, hesap_kodu, hesap_ismi, hesap_tipi_id, grup_id, bolge_id, mukellef_tipi, mukellef_adi, mukellef_adi2, mukellef_soyadi, vergi_dairesi, vergi_no, iban, iban_para, nace, yetkili1, yetkili1_tel, yetkili2, yetkili2_tel, yetkili3, yetkili3_tel, faks, muhasebe_telefon, muhasebe_email, muhasebe_yetkili, ozel_not, kok_kod, ara_kod, iskonto, efatura_kullaniyor, efatura_pb_name, adres_id, pasif) FROM stdin;
    public       	   ths_admin    false    223   )$                0    30599    mhs_fis_detaylari 
   TABLE DATA           :   COPY public.mhs_fis_detaylari (id, header_id) FROM stdin;
    public       	   ths_admin    false    227   �7                0    30603 
   mhs_fisler 
   TABLE DATA           D   COPY public.mhs_fisler (id, yevmiye_no, yevmiye_tarihi) FROM stdin;
    public       	   ths_admin    false    229   �7                0    30607    mhs_transfer_kodlari 
   TABLE DATA           W   COPY public.mhs_transfer_kodlari (id, transfer_kodu, aciklama, hesap_kodu) FROM stdin;
    public       	   ths_admin    false    231   �7                0    30611    prs_ehliyetler 
   TABLE DATA           E   COPY public.prs_ehliyetler (id, ehliyet_id, personel_id) FROM stdin;
    public       	   ths_admin    false    233   �7                0    30614    prs_lisan_bilgileri 
   TABLE DATA           h   COPY public.prs_lisan_bilgileri (id, lisan_id, okuma_id, yazma_id, konusma_id, personel_id) FROM stdin;
    public       	   ths_admin    false    234   8                0    30619    prs_personeller 
   TABLE DATA           i  COPY public.prs_personeller (id, ad, soyad, ad_soyad, tel1, tel2, personel_tipi_id, birim_id, gorev_id, dogum_tarihi, kan_grubu, cinsiyet, askerlik_durumu, medeni_durum, cocuk_sayisi, yakin_adi, yakin_telefon, ayakkabi_no, elbise_bedeni, genel_not, tasima_servis_id, ozel_not, maas, ikramiye_sayisi, ikramiye_tutar, identification, adres_id, pasif) FROM stdin;
    public       	   ths_admin    false    237   08      3          0    30672    sat_fatura_detaylari 
   TABLE DATA           s   COPY public.sat_fatura_detaylari (id, header_id, teklif_detay_id, siparis_detay_id, irsaliye_detay_id) FROM stdin;
    public       	   ths_admin    false    259   p9      5          0    30676    sat_faturalar 
   TABLE DATA           i   COPY public.sat_faturalar (id, fatura_no, fatura_tarihi, teklif_id, siparis_id, irsaliye_id) FROM stdin;
    public       	   ths_admin    false    261   �9      7          0    30680    sat_irsaliye_detaylari 
   TABLE DATA           s   COPY public.sat_irsaliye_detaylari (id, header_id, teklif_detay_id, siparis_detay_id, fatura_detay_id) FROM stdin;
    public       	   ths_admin    false    263   �9      9          0    30684    sat_irsaliyeler 
   TABLE DATA           m   COPY public.sat_irsaliyeler (id, irsaliye_no, irsaliye_tarihi, teklif_id, siparis_id, fatura_id) FROM stdin;
    public       	   ths_admin    false    265   �9      ;          0    30688    sat_siparis_detaylari 
   TABLE DATA           �  COPY public.sat_siparis_detaylari (id, header_id, teklif_detay_id, irsaliye_detay_id, fatura_detay_id, stok_kodu, stok_aciklama, kullanici_aciklama, referans, miktar, giden_miktar, olcu_birimi, iskonto_orani, kdv_orani, fiyat, net_fiyat, tutar, iskonto_tutar, net_tutar, kdv_tutar, toplam_tutar, is_ana_urun, referans_ana_urun_id, gtip_no, en, boy, yukseklik, net_agirlik, brut_agirlik, hacim, kab) FROM stdin;
    public       	   ths_admin    false    267   �9      =          0    30712    sat_siparisler 
   TABLE DATA           u  COPY public.sat_siparisler (id, teklif_id, irsaliye_id, fatura_id, tutar, iskonto_tutar, ara_toplam, kdv_oran1, kdv_tutar1, kdv_oran2, kdv_tutar2, kdv_oran3, kdv_tutar3, kdv_oran4, kdv_tutar4, kdv_oran5, kdv_tutar5, genel_toplam, islem_tipi_id, siparis_no, siparis_tarihi, teslim_tarihi, musteri_kodu, musteri_adi, vergi_dairesi, vergi_no, ulke_id, sehir_id, ilce, mahalle, cadde, sokak, posta_kodu, bina_adi, kapi_no, musteri_temsilcisi_id, muhattap_ad, referans, para_birimi, doviz_kuru_usd, doviz_kuru_eur, aciklama, proforma_no, siparis_durum_id, teslim_sekli_id, odeme_sekli_id, paket_tipi_id, tasima_ucreti_id) FROM stdin;
    public       	   ths_admin    false    269   :      C          0    30769    sat_teklif_detaylari 
   TABLE DATA           R  COPY public.sat_teklif_detaylari (id, header_id, siparis_detay_id, irsaliye_detay_id, fatura_detay_id, stok_kodu, stok_aciklama, kullanici_aciklama, referans, miktar, olcu_birimi, iskonto_orani, kdv_orani, fiyat, net_fiyat, tutar, iskonto_tutar, net_tutar, kdv_tutar, toplam_tutar, is_ana_urun, referans_ana_urun_id, gtip_no) FROM stdin;
    public       	   ths_admin    false    276   :      E          0    30786    sat_teklifler 
   TABLE DATA           �  COPY public.sat_teklifler (id, siparis_id, irsaliye_id, fatura_id, is_siparislesti, tutar, iskonto_tutar, ara_toplam, kdv_oran1, kdv_tutar1, kdv_oran2, kdv_tutar2, kdv_oran3, kdv_tutar3, kdv_oran4, kdv_tutar4, kdv_oran5, kdv_tutar5, genel_toplam, islem_tipi_id, teklif_no, teklif_tarihi, gecerlilik_tarihi, musteri_kodu, musteri_adi, vergi_dairesi, vergi_no, ulke_id, sehir_id, ilce, mahalle, cadde, sokak, posta_kodu, bina_adi, kapi_no, musteri_temsilcisi_id, muhattap_ad, muhattap_telefon, referans, para_birimi, doviz_kuru_usd, doviz_kuru_eur, aciklama, proforma_no, teslim_sekli_id, odeme_sekli_id, paket_tipi_id, tasima_ucreti_id) FROM stdin;
    public       	   ths_admin    false    278   ;      G          0    30808    set_ch_firma_tipleri 
   TABLE DATA           M   COPY public.set_ch_firma_tipleri (id, firma_turu_id, firma_tipi) FROM stdin;
    public       	   ths_admin    false    280   �;      I          0    30812    set_ch_firma_turleri 
   TABLE DATA           >   COPY public.set_ch_firma_turleri (id, firma_turu) FROM stdin;
    public       	   ths_admin    false    282   .<      M          0    30818    set_ch_hesap_tipleri 
   TABLE DATA           >   COPY public.set_ch_hesap_tipleri (id, hesap_tipi) FROM stdin;
    public       	   ths_admin    false    286   ^<      O          0    30822    set_ch_vergi_oranlari 
   TABLE DATA           �   COPY public.set_ch_vergi_oranlari (id, vergi_orani, satis_hesap_kodu, satis_iade_hesap_kodu, alis_hesap_kodu, alis_iade_hesap_kodu) FROM stdin;
    public       	   ths_admin    false    288   �<      Q          0    30826    set_einv_fatura_tipleri 
   TABLE DATA           B   COPY public.set_einv_fatura_tipleri (id, fatura_tipi) FROM stdin;
    public       	   ths_admin    false    290   �<      S          0    30830    set_einv_odeme_sekilleri 
   TABLE DATA           ^   COPY public.set_einv_odeme_sekilleri (id, odeme_sekli, kod, aciklama, is_efatura) FROM stdin;
    public       	   ths_admin    false    292   E=      U          0    30837    set_einv_paket_tipleri 
   TABLE DATA           O   COPY public.set_einv_paket_tipleri (id, kod, paket_tipi, aciklama) FROM stdin;
    public       	   ths_admin    false    294   �>      W          0    30843    set_einv_tasima_ucretleri 
   TABLE DATA           F   COPY public.set_einv_tasima_ucretleri (id, tasima_ucreti) FROM stdin;
    public       	   ths_admin    false    296   �>      Y          0    30847    set_einv_teslim_sekilleri 
   TABLE DATA           [   COPY public.set_einv_teslim_sekilleri (id, teslim_sekli, aciklama, is_efatura) FROM stdin;
    public       	   ths_admin    false    298   ?      [          0    30852    set_prs_birimler 
   TABLE DATA           ?   COPY public.set_prs_birimler (id, birim, bolum_id) FROM stdin;
    public       	   ths_admin    false    300   A      ]          0    30856    set_prs_bolumler 
   TABLE DATA           5   COPY public.set_prs_bolumler (id, bolum) FROM stdin;
    public       	   ths_admin    false    302   ~A      _          0    30860    set_prs_ehliyetler 
   TABLE DATA           9   COPY public.set_prs_ehliyetler (id, ehliyet) FROM stdin;
    public       	   ths_admin    false    304   �A      a          0    30864    set_prs_gorevler 
   TABLE DATA           5   COPY public.set_prs_gorevler (id, gorev) FROM stdin;
    public       	   ths_admin    false    306   	B      e          0    30872    set_prs_lisan_seviyeleri 
   TABLE DATA           F   COPY public.set_prs_lisan_seviyeleri (id, lisan_seviyesi) FROM stdin;
    public       	   ths_admin    false    310   IB      c          0    30868    set_prs_lisanlar 
   TABLE DATA           5   COPY public.set_prs_lisanlar (id, lisan) FROM stdin;
    public       	   ths_admin    false    308   �B      g          0    30876    set_prs_personel_tipleri 
   TABLE DATA           E   COPY public.set_prs_personel_tipleri (id, personel_tipi) FROM stdin;
    public       	   ths_admin    false    312   �B      i          0    30880    set_prs_tasima_servisleri 
   TABLE DATA           P   COPY public.set_prs_tasima_servisleri (id, arac_no, arac_adi, rota) FROM stdin;
    public       	   ths_admin    false    314   �B      l          0    30887    set_sls_offer_status 
   TABLE DATA           J   COPY public.set_sls_offer_status (id, teklif_durum, aciklama) FROM stdin;
    public       	   ths_admin    false    317   C      ?          0    30734    set_sls_order_status 
   TABLE DATA           K   COPY public.set_sls_order_status (id, siparis_durum, aciklama) FROM stdin;
    public       	   ths_admin    false    271   ^C      n          0    30891    stk_ambarlar 
   TABLE DATA           x   COPY public.stk_ambarlar (id, ambar_adi, is_varsayilan_hammadde, is_varsayilan_uretim, is_varsayilan_satis) FROM stdin;
    public       	   ths_admin    false    319   �C      p          0    30898    stk_cins_ozellikleri 
   TABLE DATA           �   COPY public.stk_cins_ozellikleri (id, cins, aciklama, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, i1, i2, i3, i4, i5, d1, d2, d3, d4, d5) FROM stdin;
    public       	   ths_admin    false    321   �C      @          0    30737    stk_gruplar 
   TABLE DATA           �   COPY public.stk_gruplar (id, grup, kdv_orani, hammadde_stok_hesap_kodu, hammadde_kullanim_hesap_kodu, yari_mamul_hesap_kodu) FROM stdin;
    public       	   ths_admin    false    272   D      q          0    30904    stk_hareketler 
   TABLE DATA           �   COPY public.stk_hareketler (id, stok_kodu, miktar, tutar, tutar_doviz, para_birimi, is_giris, tarih, veren_ambar_id, alan_ambar_id, is_donem_basi, aciklama, irsaliye_id, uretim_id) FROM stdin;
    public       	   ths_admin    false    322   cD      t          0    30911    stk_kart_cins_bilgileri 
   TABLE DATA           �   COPY public.stk_kart_cins_bilgileri (id, stk_kart_id, cins_id, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, i1, i2, i3, i4, i5, d1, d2, d3, d4, d5) FROM stdin;
    public       	   ths_admin    false    325   �D      u          0    30917    stk_kart_ozetleri 
   TABLE DATA           ;  COPY public.stk_kart_ozetleri (id, stk_kart_id, stok_miktar, ortalama_maliyet, donem_basi_fiyat, donem_basi_miktar, donem_basi_tutar, giren_toplam, giren_toplam_maliyet, cikan_toplam, cikan_toplam_maliyet, son_alis_fiyat, son_alis_para, son_alis_tarih, son_alis_miktar, son_alis_kur, son_alis_kur_para) FROM stdin;
    public       	   ths_admin    false    326   �D      A          0    30740    stk_kartlar 
   TABLE DATA           n  COPY public.stk_kartlar (id, is_satilabilir, stok_kodu, stok_adi, stok_grubu_id, olcu_birimi_id, urun_tipi, alis_iskonto, satis_iskonto, alis_fiyat, alis_para, satis_fiyat, satis_para, ihrac_fiyat, ihrac_para, ortalama_maliyet, en, boy, yukseklik, agirlik, temin_suresi, ozel_kod, marka, mensei_id, gtip_no, diib_urun_tanimi, en_az_stok_seviyesi, tanim) FROM stdin;
    public       	   ths_admin    false    273   �D      x          0    30933    stk_resimler 
   TABLE DATA           I   COPY public.stk_resimler (id, stk_kart_id, resim, dosya_adi) FROM stdin;
    public       	   ths_admin    false    329   8F      |          0    30941    sys_adresler 
   TABLE DATA           �   COPY public.sys_adresler (id, sehir_id, ilce, mahalle, semt, cadde, sokak, bina_adi, kapi_no, posta_kodu, web, email) FROM stdin;
    public       	   ths_admin    false    333   %p      ~          0    30947 	   sys_aylar 
   TABLE DATA           /   COPY public.sys_aylar (id, ay_adi) FROM stdin;
    public       	   ths_admin    false    335   \p      �          0    30951    sys_bolgeler 
   TABLE DATA           1   COPY public.sys_bolgeler (id, bolge) FROM stdin;
    public       	   ths_admin    false    337   �p      �          0    30960    sys_ersim_haklari 
   TABLE DATA              COPY public.sys_ersim_haklari (id, kaynak_id, is_okuma, is_ekleme, is_guncelleme, is_silme, is_ozel, kullanici_id) FROM stdin;
    public       	   ths_admin    false    340   Cq      �          0    30969    sys_grid_filtreler_siralamalar 
   TABLE DATA           \   COPY public.sys_grid_filtreler_siralamalar (id, tablo_adi, icerik, is_siralama) FROM stdin;
    public       	   ths_admin    false    342   r      �          0    30976    sys_grid_kolonlar 
   TABLE DATA           �   COPY public.sys_grid_kolonlar (id, tablo_adi, kolon_adi, sira_no, kolon_genislik, veri_formati, is_gorunur, is_helper_gorunur, min_deger, min_renk, maks_deger, maks_renk, maks_deger_yuzdesi, bar_rengi, bar_arka_rengi, bar_yazi_rengi) FROM stdin;
    public       	   ths_admin    false    344   Lr      �          0    30992    sys_gui_icerikler 
   TABLE DATA           i   COPY public.sys_gui_icerikler (id, kod, deger, is_fabrika, icerik_tipi, tablo_adi, form_adi) FROM stdin;
    public       	   ths_admin    false    346   gy      �          0    30998 
   sys_gunler 
   TABLE DATA           1   COPY public.sys_gunler (id, gun_adi) FROM stdin;
    public       	   ths_admin    false    347   N�      �          0    31002    sys_kaynak_gruplari 
   TABLE DATA           7   COPY public.sys_kaynak_gruplari (id, grup) FROM stdin;
    public       	   ths_admin    false    349   ��      �          0    31006    sys_kaynaklar 
   TABLE DATA           T   COPY public.sys_kaynaklar (id, kaynak_kodu, kaynak_adi, kaynak_grup_id) FROM stdin;
    public       	   ths_admin    false    351   �      �          0    31010    sys_kullanicilar 
   TABLE DATA           �   COPY public.sys_kullanicilar (id, kullanici_adi, kullanici_sifre, is_aktif, is_yonetici, is_super_kullanici, ip_adres, mac_adres, personel_id) FROM stdin;
    public       	   ths_admin    false    353   D�      �          0    31026    sys_olcu_birimi_tipleri 
   TABLE DATA           G   COPY public.sys_olcu_birimi_tipleri (id, olcu_birimi_tipi) FROM stdin;
    public       	   ths_admin    false    358   ς      �          0    31021    sys_olcu_birimleri 
   TABLE DATA           p   COPY public.sys_olcu_birimleri (id, birim, birim_einv, aciklama, is_ondalik, birim_tipi_id, carpan) FROM stdin;
    public       	   ths_admin    false    356   �      �          0    31030    sys_ondalik_haneler 
   TABLE DATA           `   COPY public.sys_ondalik_haneler (id, miktar, fiyat, tutar, stok_miktar, doviz_kuru) FROM stdin;
    public       	   ths_admin    false    360   �      �          0    31039    sys_para_birimleri 
   TABLE DATA           H   COPY public.sys_para_birimleri (id, para, sembol, aciklama) FROM stdin;
    public       	   ths_admin    false    362   �      B          0    30761    sys_sehirler 
   TABLE DATA           P   COPY public.sys_sehirler (id, sehir, plaka_kodu, ulke_id, bolge_id) FROM stdin;
    public       	   ths_admin    false    274   ��      �          0    31044    sys_ulkeler 
   TABLE DATA           a   COPY public.sys_ulkeler (id, ulke_kodu, ulke_adi, iso_year, iso_cctld, is_eu_member) FROM stdin;
    public       	   ths_admin    false    365   �      �          0    31049    sys_uygulama_ayarlari 
   TABLE DATA           g  COPY public.sys_uygulama_ayarlari (id, unvan, telefon, faks, vergi_dairesi, vergi_no, donem, mail_sunucu, mail_kullanici, mail_sifre, mail_smtp_port, grid_renk_1, grid_renk_2, grid_renk_aktif, crypt_key, sms_sunucu, sms_kullanici, sms_sifre, sms_baslik, versiyon, para, adres_id, diger_ayarlar, mukellef_adi, mukellef_soyadi, mukellef_tipi, logo) FROM stdin;
    public       	   ths_admin    false    367   c�                0    30630    urt_iscilikler 
   TABLE DATA           `   COPY public.urt_iscilikler (id, gider_kodu, gider_adi, fiyat, birim_id, gider_tipi) FROM stdin;
    public       	   ths_admin    false    239   ��      !          0    30634    urt_paket_hammadde_detaylari 
   TABLE DATA           c   COPY public.urt_paket_hammadde_detaylari (id, header_id, recete_id, stok_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    241   $�      #          0    30638    urt_paket_hammaddeler 
   TABLE DATA           >   COPY public.urt_paket_hammaddeler (id, paket_adi) FROM stdin;
    public       	   ths_admin    false    243   ]�      %          0    30642    urt_paket_iscilik_detaylari 
   TABLE DATA           Z   COPY public.urt_paket_iscilik_detaylari (id, header_id, iscilik_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    245   ��      '          0    30646    urt_paket_iscilikler 
   TABLE DATA           =   COPY public.urt_paket_iscilikler (id, paket_adi) FROM stdin;
    public       	   ths_admin    false    247   ��      )          0    30650    urt_recete_hammaddeler 
   TABLE DATA           i   COPY public.urt_recete_hammaddeler (id, header_id, recete_id, stok_kodu, miktar, fire_orani) FROM stdin;
    public       	   ths_admin    false    249   ��      -          0    30660    urt_recete_iscilikler 
   TABLE DATA           T   COPY public.urt_recete_iscilikler (id, header_id, iscilik_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    253   �      /          0    30664    urt_recete_paket_hammaddeler 
   TABLE DATA           W   COPY public.urt_recete_paket_hammaddeler (id, header_id, paket_id, miktar) FROM stdin;
    public       	   ths_admin    false    255   K�      1          0    30668    urt_recete_paket_iscilikler 
   TABLE DATA           V   COPY public.urt_recete_paket_iscilikler (id, header_id, paket_id, miktar) FROM stdin;
    public       	   ths_admin    false    257   h�      �          0    31075    urt_recete_yan_urunler 
   TABLE DATA           R   COPY public.urt_recete_yan_urunler (id, header_id, urun_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    372   ��      +          0    30655    urt_receteler 
   TABLE DATA           Y   COPY public.urt_receteler (id, urun_kodu, urun_adi, ornek_miktari, aciklama) FROM stdin;
    public       	   ths_admin    false    251   ��      �           0    0    alis_teklif_detaylari_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.alis_teklif_detaylari_id_seq', 1, false);
          public       	   ths_admin    false    210            �           0    0    als_teklifler_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.als_teklifler_id_seq', 1, false);
          public       	   ths_admin    false    212            �           0    0    audit_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.audit_id_seq', 27, true);
          public       	   ths_admin    false    214            �           0    0    ch_banka_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.ch_banka_id_seq', 6, true);
          public       	   ths_admin    false    216            �           0    0    ch_banka_subesi_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.ch_banka_subesi_id_seq', 7, true);
          public       	   ths_admin    false    218            �           0    0    ch_bolge_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.ch_bolge_id_seq', 17, true);
          public       	   ths_admin    false    220            �           0    0    ch_hesap_karti_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.ch_hesap_karti_id_seq', 317, true);
          public       	   ths_admin    false    224            �           0    0    mhs_doviz_kuru_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.mhs_doviz_kuru_id_seq', 430, true);
          public       	   ths_admin    false    226            �           0    0    mhs_fis_detaylari_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.mhs_fis_detaylari_id_seq', 1, false);
          public       	   ths_admin    false    228            �           0    0    mhs_fisler_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.mhs_fisler_id_seq', 1, false);
          public       	   ths_admin    false    230            �           0    0    mhs_transfer_kodlari_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.mhs_transfer_kodlari_id_seq', 1, false);
          public       	   ths_admin    false    232            �           0    0    prs_lisan_bilgisi_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.prs_lisan_bilgisi_id_seq', 2, true);
          public       	   ths_admin    false    235            �           0    0    prs_personel_ehliyetleri_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.prs_personel_ehliyetleri_id_seq', 2, true);
          public       	   ths_admin    false    236            �           0    0    prs_personel_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.prs_personel_id_seq', 16, true);
          public       	   ths_admin    false    238            �           0    0    rct_iscilik_gideri_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.rct_iscilik_gideri_id_seq', 2, false);
          public       	   ths_admin    false    240            �           0    0    rct_paket_hammadde_detay_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.rct_paket_hammadde_detay_id_seq', 2, true);
          public       	   ths_admin    false    242            �           0    0    rct_paket_hammadde_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.rct_paket_hammadde_id_seq', 1, true);
          public       	   ths_admin    false    244            �           0    0    rct_paket_iscilik_detay_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.rct_paket_iscilik_detay_id_seq', 1, false);
          public       	   ths_admin    false    246            �           0    0    rct_paket_iscilik_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.rct_paket_iscilik_id_seq', 1, false);
          public       	   ths_admin    false    248            �           0    0    rct_recete_hammadde_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.rct_recete_hammadde_id_seq', 18, true);
          public       	   ths_admin    false    250            �           0    0    rct_recete_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.rct_recete_id_seq', 9, true);
          public       	   ths_admin    false    252            �           0    0    rct_recete_iscilik_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.rct_recete_iscilik_id_seq', 2, true);
          public       	   ths_admin    false    254            �           0    0     rct_recete_paket_hammadde_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.rct_recete_paket_hammadde_id_seq', 1, false);
          public       	   ths_admin    false    256            �           0    0    rct_recete_paket_iscilik_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.rct_recete_paket_iscilik_id_seq', 1, false);
          public       	   ths_admin    false    258            �           0    0    sat_fatura_detay_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.sat_fatura_detay_id_seq', 1, false);
          public       	   ths_admin    false    260            �           0    0    sat_fatura_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sat_fatura_id_seq', 1, false);
          public       	   ths_admin    false    262            �           0    0    sat_irsaliye_detay_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sat_irsaliye_detay_id_seq', 1, false);
          public       	   ths_admin    false    264            �           0    0    sat_irsaliye_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.sat_irsaliye_id_seq', 1, false);
          public       	   ths_admin    false    266            �           0    0    sat_siparis_detay_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.sat_siparis_detay_id_seq', 1, false);
          public       	   ths_admin    false    268            �           0    0    sat_siparis_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sat_siparis_id_seq', 1, true);
          public       	   ths_admin    false    270            �           0    0    sat_teklif_detay_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.sat_teklif_detay_id_seq', 4, true);
          public       	   ths_admin    false    277            �           0    0    sat_teklif_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sat_teklif_id_seq', 1, true);
          public       	   ths_admin    false    279            �           0    0    set_ch_firma_tipi_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_firma_tipi_id_seq', 5, false);
          public       	   ths_admin    false    281            �           0    0    set_ch_firma_turu_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_firma_turu_id_seq', 2, false);
          public       	   ths_admin    false    283            �           0    0    set_ch_grup_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.set_ch_grup_id_seq', 74, true);
          public       	   ths_admin    false    284            �           0    0    set_ch_hesap_plani_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_ch_hesap_plani_id_seq', 286, false);
          public       	   ths_admin    false    285            �           0    0    set_ch_hesap_tipi_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_hesap_tipi_id_seq', 3, false);
          public       	   ths_admin    false    287            �           0    0    set_ch_vergi_orani_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_vergi_orani_id_seq', 7, true);
          public       	   ths_admin    false    289            �           0    0    set_einv_fatura_tipi_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_einv_fatura_tipi_id_seq', 6, false);
          public       	   ths_admin    false    291            �           0    0    set_einv_odeme_sekli_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_einv_odeme_sekli_id_seq', 32, false);
          public       	   ths_admin    false    293            �           0    0    set_einv_paket_tipi_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.set_einv_paket_tipi_id_seq', 4, false);
          public       	   ths_admin    false    295            �           0    0    set_einv_tasima_ucreti_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_einv_tasima_ucreti_id_seq', 3, true);
          public       	   ths_admin    false    297            �           0    0    set_einv_teslim_sekli_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.set_einv_teslim_sekli_id_seq', 28, false);
          public       	   ths_admin    false    299            �           0    0    set_prs_birim_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.set_prs_birim_id_seq', 46, true);
          public       	   ths_admin    false    301            �           0    0    set_prs_bolum_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.set_prs_bolum_id_seq', 26, true);
          public       	   ths_admin    false    303            �           0    0    set_prs_ehliyet_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.set_prs_ehliyet_id_seq', 6, true);
          public       	   ths_admin    false    305            �           0    0    set_prs_gorev_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.set_prs_gorev_id_seq', 6, true);
          public       	   ths_admin    false    307            �           0    0    set_prs_lisan_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.set_prs_lisan_id_seq', 4, true);
          public       	   ths_admin    false    309            �           0    0    set_prs_lisan_seviyesi_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.set_prs_lisan_seviyesi_id_seq', 4, false);
          public       	   ths_admin    false    311            �           0    0    set_prs_personel_tipi_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_prs_personel_tipi_id_seq', 3, false);
          public       	   ths_admin    false    313            �           0    0    set_prs_servis_araci_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.set_prs_servis_araci_id_seq', 1, true);
          public       	   ths_admin    false    315            �           0    0    set_sat_siparis_durum_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_sat_siparis_durum_id_seq', 3, false);
          public       	   ths_admin    false    316            �           0    0    set_sat_teklif_durum_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_sat_teklif_durum_id_seq', 3, false);
          public       	   ths_admin    false    318            �           0    0    stk_cins_ozellikleri_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.stk_cins_ozellikleri_id_seq', 1, true);
          public       	   ths_admin    false    320            �           0    0    stk_hareketler_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.stk_hareketler_id_seq', 1, false);
          public       	   ths_admin    false    323            �           0    0    stk_kart_cins_bilgileri_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.stk_kart_cins_bilgileri_id_seq', 2, true);
          public       	   ths_admin    false    324            �           0    0    stk_kart_ozetleri_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.stk_kart_ozetleri_id_seq', 1, false);
          public       	   ths_admin    false    327            �           0    0    stk_kartlar_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.stk_kartlar_id_seq', 9, true);
          public       	   ths_admin    false    328            �           0    0    stk_resimler_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.stk_resimler_id_seq', 7, true);
          public       	   ths_admin    false    330            �           0    0    stk_stok_ambar_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.stk_stok_ambar_id_seq', 7, true);
          public       	   ths_admin    false    331            �           0    0    stk_stok_grubu_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.stk_stok_grubu_id_seq', 12, true);
          public       	   ths_admin    false    332            �           0    0    sys_adresler_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.sys_adresler_id_seq', 8, true);
          public       	   ths_admin    false    334            �           0    0    sys_ay_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.sys_ay_id_seq', 24, true);
          public       	   ths_admin    false    336                        0    0    sys_bolge_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sys_bolge_id_seq', 7, false);
          public       	   ths_admin    false    338                       0    0    sys_erisim_hakki_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sys_erisim_hakki_id_seq', 1027, true);
          public       	   ths_admin    false    341                       0    0    sys_grid_filtre_siralama_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.sys_grid_filtre_siralama_id_seq', 23, true);
          public       	   ths_admin    false    343                       0    0    sys_grid_kolon_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.sys_grid_kolon_id_seq', 302, true);
          public       	   ths_admin    false    345                       0    0    sys_gun_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.sys_gun_id_seq', 16, true);
          public       	   ths_admin    false    348                       0    0    sys_kaynak_grup_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.sys_kaynak_grup_id_seq', 16, false);
          public       	   ths_admin    false    350                       0    0    sys_kaynak_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sys_kaynak_id_seq', 44, true);
          public       	   ths_admin    false    352                       0    0    sys_kullanici_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.sys_kullanici_id_seq', 66, true);
          public       	   ths_admin    false    354                       0    0    sys_lisan_gui_icerik_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.sys_lisan_gui_icerik_id_seq', 169, true);
          public       	   ths_admin    false    355            	           0    0    sys_olcu_birimi_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.sys_olcu_birimi_id_seq', 20, true);
          public       	   ths_admin    false    357            
           0    0    sys_olcu_birimi_tipi_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.sys_olcu_birimi_tipi_id_seq', 4, true);
          public       	   ths_admin    false    359                       0    0    sys_ondalik_hane_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.sys_ondalik_hane_id_seq', 1, false);
          public       	   ths_admin    false    361                       0    0    sys_para_birimi_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.sys_para_birimi_id_seq', 5, true);
          public       	   ths_admin    false    363                       0    0    sys_sehir_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.sys_sehir_id_seq', 174, false);
          public       	   ths_admin    false    364                       0    0    sys_ulke_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sys_ulke_id_seq', 321, true);
          public       	   ths_admin    false    366                       0    0    sys_uygulama_ayari_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sys_uygulama_ayari_id_seq', 4, false);
          public       	   ths_admin    false    368                       0    0    urt_recete_yan_urunler_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.urt_recete_yan_urunler_id_seq', 1, false);
          public       	   ths_admin    false    373            �           2606    31083 .   als_teklif_detaylari als_teklif_detaylari_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.als_teklif_detaylari DROP CONSTRAINT als_teklif_detaylari_pkey;
       public         	   ths_admin    false    209            �           2606    31085     als_teklifler als_teklifler_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_pkey;
       public         	   ths_admin    false    211            �           2606    31087 )   als_teklifler als_teklifler_teklif_no_key 
   CONSTRAINT     i   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_teklif_no_key UNIQUE (teklif_no);
 S   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_teklif_no_key;
       public         	   ths_admin    false    211            �           2606    31089    audits audit_pkey 
   CONSTRAINT     O   ALTER TABLE ONLY public.audits
    ADD CONSTRAINT audit_pkey PRIMARY KEY (id);
 ;   ALTER TABLE ONLY public.audits DROP CONSTRAINT audit_pkey;
       public         	   ths_admin    false    213            �           2606    31091 :   ch_banka_subeleri ch_banka_subeleri_banka_id_sube_kodu_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_banka_id_sube_kodu_key UNIQUE (banka_id, sube_kodu);
 d   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_banka_id_sube_kodu_key;
       public         	   ths_admin    false    217    217            �           2606    31093 (   ch_banka_subeleri ch_banka_subeleri_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_pkey;
       public         	   ths_admin    false    217            �           2606    31095 %   ch_bankalar ch_bankalar_banka_adi_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.ch_bankalar
    ADD CONSTRAINT ch_bankalar_banka_adi_key UNIQUE (banka_adi);
 O   ALTER TABLE ONLY public.ch_bankalar DROP CONSTRAINT ch_bankalar_banka_adi_key;
       public         	   ths_admin    false    215            �           2606    31097    ch_bankalar ch_bankalar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ch_bankalar
    ADD CONSTRAINT ch_bankalar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ch_bankalar DROP CONSTRAINT ch_bankalar_pkey;
       public         	   ths_admin    false    215            �           2606    31099 !   ch_bolgeler ch_bolgeler_bolge_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.ch_bolgeler
    ADD CONSTRAINT ch_bolgeler_bolge_key UNIQUE (bolge);
 K   ALTER TABLE ONLY public.ch_bolgeler DROP CONSTRAINT ch_bolgeler_bolge_key;
       public         	   ths_admin    false    219            �           2606    31101    ch_bolgeler ch_bolgeler_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ch_bolgeler
    ADD CONSTRAINT ch_bolgeler_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ch_bolgeler DROP CONSTRAINT ch_bolgeler_pkey;
       public         	   ths_admin    false    219            �           2606    31103 5   ch_doviz_kurlari ch_doviz_kurlari_kur_tarihi_para_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_kur_tarihi_para_key UNIQUE (kur_tarihi, para);
 _   ALTER TABLE ONLY public.ch_doviz_kurlari DROP CONSTRAINT ch_doviz_kurlari_kur_tarihi_para_key;
       public         	   ths_admin    false    221    221            �           2606    31105 &   ch_doviz_kurlari ch_doviz_kurlari_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.ch_doviz_kurlari DROP CONSTRAINT ch_doviz_kurlari_pkey;
       public         	   ths_admin    false    221            �           2606    31107    ch_gruplar ch_gruplar_grup_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.ch_gruplar
    ADD CONSTRAINT ch_gruplar_grup_key UNIQUE (grup);
 H   ALTER TABLE ONLY public.ch_gruplar DROP CONSTRAINT ch_gruplar_grup_key;
       public         	   ths_admin    false    222            �           2606    31109    ch_gruplar ch_gruplar_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.ch_gruplar
    ADD CONSTRAINT ch_gruplar_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.ch_gruplar DROP CONSTRAINT ch_gruplar_pkey;
       public         	   ths_admin    false    222            �           2606    31111 (   ch_hesap_planlari ch_hesap_planlari_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.ch_hesap_planlari
    ADD CONSTRAINT ch_hesap_planlari_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.ch_hesap_planlari DROP CONSTRAINT ch_hesap_planlari_pkey;
       public         	   ths_admin    false    225            �           2606    31113 &   ch_hesaplar ch_hesaplar_hesap_kodu_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_hesap_kodu_key UNIQUE (hesap_kodu);
 P   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_hesap_kodu_key;
       public         	   ths_admin    false    223            �           2606    31115    ch_hesaplar ch_hesaplar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_pkey;
       public         	   ths_admin    false    223            �           2606    31117 (   mhs_fis_detaylari mhs_fis_detaylari_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.mhs_fis_detaylari
    ADD CONSTRAINT mhs_fis_detaylari_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.mhs_fis_detaylari DROP CONSTRAINT mhs_fis_detaylari_pkey;
       public         	   ths_admin    false    227            �           2606    31119    mhs_fisler mhs_fisler_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.mhs_fisler
    ADD CONSTRAINT mhs_fisler_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.mhs_fisler DROP CONSTRAINT mhs_fisler_pkey;
       public         	   ths_admin    false    229            �           2606    31121 $   mhs_fisler mhs_fisler_yevmiye_no_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.mhs_fisler
    ADD CONSTRAINT mhs_fisler_yevmiye_no_key UNIQUE (yevmiye_no);
 N   ALTER TABLE ONLY public.mhs_fisler DROP CONSTRAINT mhs_fisler_yevmiye_no_key;
       public         	   ths_admin    false    229            �           2606    31123 .   mhs_transfer_kodlari mhs_transfer_kodlari_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.mhs_transfer_kodlari
    ADD CONSTRAINT mhs_transfer_kodlari_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.mhs_transfer_kodlari DROP CONSTRAINT mhs_transfer_kodlari_pkey;
       public         	   ths_admin    false    231            �           2606    31125 ;   mhs_transfer_kodlari mhs_transfer_kodlari_transfer_kodu_key 
   CONSTRAINT        ALTER TABLE ONLY public.mhs_transfer_kodlari
    ADD CONSTRAINT mhs_transfer_kodlari_transfer_kodu_key UNIQUE (transfer_kodu);
 e   ALTER TABLE ONLY public.mhs_transfer_kodlari DROP CONSTRAINT mhs_transfer_kodlari_transfer_kodu_key;
       public         	   ths_admin    false    231            �           2606    31127 8   prs_ehliyetler prs_ehliyetler_ehliyet_id_personel_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_ehliyet_id_personel_id_key UNIQUE (ehliyet_id, personel_id);
 b   ALTER TABLE ONLY public.prs_ehliyetler DROP CONSTRAINT prs_ehliyetler_ehliyet_id_personel_id_key;
       public         	   ths_admin    false    233    233            �           2606    31129 "   prs_ehliyetler prs_ehliyetler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.prs_ehliyetler DROP CONSTRAINT prs_ehliyetler_pkey;
       public         	   ths_admin    false    233            �           2606    31131 @   prs_lisan_bilgileri prs_lisan_bilgileri_lisan_id_personel_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_lisan_id_personel_id_key UNIQUE (lisan_id, personel_id);
 j   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_lisan_id_personel_id_key;
       public         	   ths_admin    false    234    234            �           2606    31133 ,   prs_lisan_bilgileri prs_lisan_bilgileri_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_pkey;
       public         	   ths_admin    false    234            �           2606    31135 $   prs_personeller prs_personeller_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_pkey;
       public         	   ths_admin    false    237                       2606    31137 .   sat_fatura_detaylari sat_fatura_detaylari_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.sat_fatura_detaylari
    ADD CONSTRAINT sat_fatura_detaylari_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.sat_fatura_detaylari DROP CONSTRAINT sat_fatura_detaylari_pkey;
       public         	   ths_admin    false    259                       2606    31139     sat_faturalar sat_faturalar_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.sat_faturalar
    ADD CONSTRAINT sat_faturalar_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.sat_faturalar DROP CONSTRAINT sat_faturalar_pkey;
       public         	   ths_admin    false    261                       2606    31141 2   sat_irsaliye_detaylari sat_irsaliye_detaylari_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.sat_irsaliye_detaylari
    ADD CONSTRAINT sat_irsaliye_detaylari_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.sat_irsaliye_detaylari DROP CONSTRAINT sat_irsaliye_detaylari_pkey;
       public         	   ths_admin    false    263                       2606    31143 $   sat_irsaliyeler sat_irsaliyeler_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.sat_irsaliyeler
    ADD CONSTRAINT sat_irsaliyeler_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.sat_irsaliyeler DROP CONSTRAINT sat_irsaliyeler_pkey;
       public         	   ths_admin    false    265            !           2606    31145 0   sat_siparis_detaylari sat_siparis_detaylari_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_pkey;
       public         	   ths_admin    false    267            $           2606    31147 "   sat_siparisler sat_siparisler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_pkey;
       public         	   ths_admin    false    269            7           2606    31149 .   sat_teklif_detaylari sat_teklif_detaylari_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_pkey;
       public         	   ths_admin    false    276            9           2606    31151 &   sat_teklifler sat_teklif_teklif_no_key 
   CONSTRAINT     f   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklif_teklif_no_key UNIQUE (teklif_no);
 P   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklif_teklif_no_key;
       public         	   ths_admin    false    278            ;           2606    31153     sat_teklifler sat_teklifler_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_pkey;
       public         	   ths_admin    false    278            A           2606    31155 9   set_ch_firma_turleri set_acc_firma_turleri_firma_turu_key 
   CONSTRAINT     z   ALTER TABLE ONLY public.set_ch_firma_turleri
    ADD CONSTRAINT set_acc_firma_turleri_firma_turu_key UNIQUE (firma_turu);
 c   ALTER TABLE ONLY public.set_ch_firma_turleri DROP CONSTRAINT set_acc_firma_turleri_firma_turu_key;
       public         	   ths_admin    false    282            C           2606    31157 /   set_ch_firma_turleri set_acc_firma_turleri_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.set_ch_firma_turleri
    ADD CONSTRAINT set_acc_firma_turleri_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY public.set_ch_firma_turleri DROP CONSTRAINT set_acc_firma_turleri_pkey;
       public         	   ths_admin    false    282            =           2606    31159 8   set_ch_firma_tipleri set_ch_firma_tipleri_firma_tipi_key 
   CONSTRAINT     y   ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_firma_tipi_key UNIQUE (firma_tipi);
 b   ALTER TABLE ONLY public.set_ch_firma_tipleri DROP CONSTRAINT set_ch_firma_tipleri_firma_tipi_key;
       public         	   ths_admin    false    280            ?           2606    31161 .   set_ch_firma_tipleri set_ch_firma_tipleri_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.set_ch_firma_tipleri DROP CONSTRAINT set_ch_firma_tipleri_pkey;
       public         	   ths_admin    false    280            E           2606    31163 7   set_ch_hesap_tipleri set_ch_hesap_tipleri_hesa_tipi_key 
   CONSTRAINT     x   ALTER TABLE ONLY public.set_ch_hesap_tipleri
    ADD CONSTRAINT set_ch_hesap_tipleri_hesa_tipi_key UNIQUE (hesap_tipi);
 a   ALTER TABLE ONLY public.set_ch_hesap_tipleri DROP CONSTRAINT set_ch_hesap_tipleri_hesa_tipi_key;
       public         	   ths_admin    false    286            G           2606    31165 .   set_ch_hesap_tipleri set_ch_hesap_tipleri_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.set_ch_hesap_tipleri
    ADD CONSTRAINT set_ch_hesap_tipleri_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.set_ch_hesap_tipleri DROP CONSTRAINT set_ch_hesap_tipleri_pkey;
       public         	   ths_admin    false    286            I           2606    31167 0   set_ch_vergi_oranlari set_ch_vergi_oranlari_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_pkey;
       public         	   ths_admin    false    288            K           2606    31169 :   set_ch_vergi_oranlari set_ch_vergi_oranlari_veri_orani_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_veri_orani_key UNIQUE (vergi_orani);
 d   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_veri_orani_key;
       public         	   ths_admin    false    288            M           2606    31171 ?   set_einv_fatura_tipleri set_einv_fatura_tipleri_fatura_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_fatura_tipleri
    ADD CONSTRAINT set_einv_fatura_tipleri_fatura_tipi_key UNIQUE (fatura_tipi);
 i   ALTER TABLE ONLY public.set_einv_fatura_tipleri DROP CONSTRAINT set_einv_fatura_tipleri_fatura_tipi_key;
       public         	   ths_admin    false    290            O           2606    31173 4   set_einv_fatura_tipleri set_einv_fatura_tipleri_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.set_einv_fatura_tipleri
    ADD CONSTRAINT set_einv_fatura_tipleri_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.set_einv_fatura_tipleri DROP CONSTRAINT set_einv_fatura_tipleri_pkey;
       public         	   ths_admin    false    290            Q           2606    31175 6   set_einv_odeme_sekilleri set_einv_odeme_sekilleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.set_einv_odeme_sekilleri
    ADD CONSTRAINT set_einv_odeme_sekilleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.set_einv_odeme_sekilleri DROP CONSTRAINT set_einv_odeme_sekilleri_pkey;
       public         	   ths_admin    false    292            S           2606    31177 A   set_einv_odeme_sekilleri set_einv_odeme_sekli_odeme_sekilleri_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_odeme_sekilleri
    ADD CONSTRAINT set_einv_odeme_sekli_odeme_sekilleri_key UNIQUE (odeme_sekli);
 k   ALTER TABLE ONLY public.set_einv_odeme_sekilleri DROP CONSTRAINT set_einv_odeme_sekli_odeme_sekilleri_key;
       public         	   ths_admin    false    292            U           2606    31179 5   set_einv_paket_tipleri set_einv_paket_tipleri_kod_key 
   CONSTRAINT     o   ALTER TABLE ONLY public.set_einv_paket_tipleri
    ADD CONSTRAINT set_einv_paket_tipleri_kod_key UNIQUE (kod);
 _   ALTER TABLE ONLY public.set_einv_paket_tipleri DROP CONSTRAINT set_einv_paket_tipleri_kod_key;
       public         	   ths_admin    false    294            W           2606    31181 2   set_einv_paket_tipleri set_einv_paket_tipleri_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.set_einv_paket_tipleri
    ADD CONSTRAINT set_einv_paket_tipleri_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.set_einv_paket_tipleri DROP CONSTRAINT set_einv_paket_tipleri_pkey;
       public         	   ths_admin    false    294            Y           2606    31183 8   set_einv_tasima_ucretleri set_einv_tasima_ucretleri_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.set_einv_tasima_ucretleri
    ADD CONSTRAINT set_einv_tasima_ucretleri_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.set_einv_tasima_ucretleri DROP CONSTRAINT set_einv_tasima_ucretleri_pkey;
       public         	   ths_admin    false    296            [           2606    31185 E   set_einv_tasima_ucretleri set_einv_tasima_ucretleri_tasima_ucreti_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_tasima_ucretleri
    ADD CONSTRAINT set_einv_tasima_ucretleri_tasima_ucreti_key UNIQUE (tasima_ucreti);
 o   ALTER TABLE ONLY public.set_einv_tasima_ucretleri DROP CONSTRAINT set_einv_tasima_ucretleri_tasima_ucreti_key;
       public         	   ths_admin    false    296            ]           2606    31187 8   set_einv_teslim_sekilleri set_einv_teslim_sekilleri_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.set_einv_teslim_sekilleri
    ADD CONSTRAINT set_einv_teslim_sekilleri_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.set_einv_teslim_sekilleri DROP CONSTRAINT set_einv_teslim_sekilleri_pkey;
       public         	   ths_admin    false    298            _           2606    31189 D   set_einv_teslim_sekilleri set_einv_teslim_sekilleri_teslim_sekli_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_teslim_sekilleri
    ADD CONSTRAINT set_einv_teslim_sekilleri_teslim_sekli_key UNIQUE (teslim_sekli);
 n   ALTER TABLE ONLY public.set_einv_teslim_sekilleri DROP CONSTRAINT set_einv_teslim_sekilleri_teslim_sekli_key;
       public         	   ths_admin    false    298            a           2606    31191 4   set_prs_birimler set_prs_birimler_birim_bolum_id_key 
   CONSTRAINT     z   ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_birim_bolum_id_key UNIQUE (birim, bolum_id);
 ^   ALTER TABLE ONLY public.set_prs_birimler DROP CONSTRAINT set_prs_birimler_birim_bolum_id_key;
       public         	   ths_admin    false    300    300            c           2606    31193 &   set_prs_birimler set_prs_birimler_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_birimler DROP CONSTRAINT set_prs_birimler_pkey;
       public         	   ths_admin    false    300            e           2606    31195 +   set_prs_bolumler set_prs_bolumler_bolum_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.set_prs_bolumler
    ADD CONSTRAINT set_prs_bolumler_bolum_key UNIQUE (bolum);
 U   ALTER TABLE ONLY public.set_prs_bolumler DROP CONSTRAINT set_prs_bolumler_bolum_key;
       public         	   ths_admin    false    302            g           2606    31197 &   set_prs_bolumler set_prs_bolumler_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_bolumler
    ADD CONSTRAINT set_prs_bolumler_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_bolumler DROP CONSTRAINT set_prs_bolumler_pkey;
       public         	   ths_admin    false    302            i           2606    31199 1   set_prs_ehliyetler set_prs_ehliyetler_ehliyet_key 
   CONSTRAINT     o   ALTER TABLE ONLY public.set_prs_ehliyetler
    ADD CONSTRAINT set_prs_ehliyetler_ehliyet_key UNIQUE (ehliyet);
 [   ALTER TABLE ONLY public.set_prs_ehliyetler DROP CONSTRAINT set_prs_ehliyetler_ehliyet_key;
       public         	   ths_admin    false    304            k           2606    31201 *   set_prs_ehliyetler set_prs_ehliyetler_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.set_prs_ehliyetler
    ADD CONSTRAINT set_prs_ehliyetler_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.set_prs_ehliyetler DROP CONSTRAINT set_prs_ehliyetler_pkey;
       public         	   ths_admin    false    304            m           2606    31203 +   set_prs_gorevler set_prs_gorevler_gorev_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.set_prs_gorevler
    ADD CONSTRAINT set_prs_gorevler_gorev_key UNIQUE (gorev);
 U   ALTER TABLE ONLY public.set_prs_gorevler DROP CONSTRAINT set_prs_gorevler_gorev_key;
       public         	   ths_admin    false    306            o           2606    31205 &   set_prs_gorevler set_prs_gorevler_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_gorevler
    ADD CONSTRAINT set_prs_gorevler_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_gorevler DROP CONSTRAINT set_prs_gorevler_pkey;
       public         	   ths_admin    false    306            u           2606    31207 D   set_prs_lisan_seviyeleri set_prs_lisan_seviyeleri_lisan_seviyesi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri
    ADD CONSTRAINT set_prs_lisan_seviyeleri_lisan_seviyesi_key UNIQUE (lisan_seviyesi);
 n   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri DROP CONSTRAINT set_prs_lisan_seviyeleri_lisan_seviyesi_key;
       public         	   ths_admin    false    310            w           2606    31209 6   set_prs_lisan_seviyeleri set_prs_lisan_seviyeleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri
    ADD CONSTRAINT set_prs_lisan_seviyeleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri DROP CONSTRAINT set_prs_lisan_seviyeleri_pkey;
       public         	   ths_admin    false    310            q           2606    31211 +   set_prs_lisanlar set_prs_lisanlar_lisan_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.set_prs_lisanlar
    ADD CONSTRAINT set_prs_lisanlar_lisan_key UNIQUE (lisan);
 U   ALTER TABLE ONLY public.set_prs_lisanlar DROP CONSTRAINT set_prs_lisanlar_lisan_key;
       public         	   ths_admin    false    308            s           2606    31213 &   set_prs_lisanlar set_prs_lisanlar_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_lisanlar
    ADD CONSTRAINT set_prs_lisanlar_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_lisanlar DROP CONSTRAINT set_prs_lisanlar_pkey;
       public         	   ths_admin    false    308            y           2606    31215 C   set_prs_personel_tipleri set_prs_personel_tipleri_personel_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_prs_personel_tipleri
    ADD CONSTRAINT set_prs_personel_tipleri_personel_tipi_key UNIQUE (personel_tipi);
 m   ALTER TABLE ONLY public.set_prs_personel_tipleri DROP CONSTRAINT set_prs_personel_tipleri_personel_tipi_key;
       public         	   ths_admin    false    312            {           2606    31217 6   set_prs_personel_tipleri set_prs_personel_tipleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.set_prs_personel_tipleri
    ADD CONSTRAINT set_prs_personel_tipleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.set_prs_personel_tipleri DROP CONSTRAINT set_prs_personel_tipleri_pkey;
       public         	   ths_admin    false    312            }           2606    31219 ?   set_prs_tasima_servisleri set_prs_tasima_servisleri_arac_no_key 
   CONSTRAINT     }   ALTER TABLE ONLY public.set_prs_tasima_servisleri
    ADD CONSTRAINT set_prs_tasima_servisleri_arac_no_key UNIQUE (arac_no);
 i   ALTER TABLE ONLY public.set_prs_tasima_servisleri DROP CONSTRAINT set_prs_tasima_servisleri_arac_no_key;
       public         	   ths_admin    false    314                       2606    31221 8   set_prs_tasima_servisleri set_prs_tasima_servisleri_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.set_prs_tasima_servisleri
    ADD CONSTRAINT set_prs_tasima_servisleri_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.set_prs_tasima_servisleri DROP CONSTRAINT set_prs_tasima_servisleri_pkey;
       public         	   ths_admin    false    314            &           2606    31223 /   set_sls_order_status set_sat_siparis_durum_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.set_sls_order_status
    ADD CONSTRAINT set_sat_siparis_durum_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY public.set_sls_order_status DROP CONSTRAINT set_sat_siparis_durum_pkey;
       public         	   ths_admin    false    271            (           2606    31225 <   set_sls_order_status set_sat_siparis_durum_siparis_durum_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_sls_order_status
    ADD CONSTRAINT set_sat_siparis_durum_siparis_durum_key UNIQUE (siparis_durum);
 f   ALTER TABLE ONLY public.set_sls_order_status DROP CONSTRAINT set_sat_siparis_durum_siparis_durum_key;
       public         	   ths_admin    false    271            �           2606    31227 .   set_sls_offer_status set_sat_teklif_durum_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.set_sls_offer_status
    ADD CONSTRAINT set_sat_teklif_durum_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.set_sls_offer_status DROP CONSTRAINT set_sat_teklif_durum_pkey;
       public         	   ths_admin    false    317            �           2606    31229 :   set_sls_offer_status set_sat_teklif_durum_teklif_durum_key 
   CONSTRAINT     }   ALTER TABLE ONLY public.set_sls_offer_status
    ADD CONSTRAINT set_sat_teklif_durum_teklif_durum_key UNIQUE (teklif_durum);
 d   ALTER TABLE ONLY public.set_sls_offer_status DROP CONSTRAINT set_sat_teklif_durum_teklif_durum_key;
       public         	   ths_admin    false    317            �           2606    31231 '   stk_ambarlar stk_ambarlar_ambar_adi_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.stk_ambarlar
    ADD CONSTRAINT stk_ambarlar_ambar_adi_key UNIQUE (ambar_adi);
 Q   ALTER TABLE ONLY public.stk_ambarlar DROP CONSTRAINT stk_ambarlar_ambar_adi_key;
       public         	   ths_admin    false    319            �           2606    31233    stk_ambarlar stk_ambarlar_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.stk_ambarlar
    ADD CONSTRAINT stk_ambarlar_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.stk_ambarlar DROP CONSTRAINT stk_ambarlar_pkey;
       public         	   ths_admin    false    319            �           2606    31235 2   stk_cins_ozellikleri stk_cins_ozellikleri_cins_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.stk_cins_ozellikleri
    ADD CONSTRAINT stk_cins_ozellikleri_cins_key UNIQUE (cins);
 \   ALTER TABLE ONLY public.stk_cins_ozellikleri DROP CONSTRAINT stk_cins_ozellikleri_cins_key;
       public         	   ths_admin    false    321            �           2606    31237 .   stk_cins_ozellikleri stk_cins_ozellikleri_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.stk_cins_ozellikleri
    ADD CONSTRAINT stk_cins_ozellikleri_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.stk_cins_ozellikleri DROP CONSTRAINT stk_cins_ozellikleri_pkey;
       public         	   ths_admin    false    321            *           2606    31239     stk_gruplar stk_gruplar_grup_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_grup_key UNIQUE (grup);
 J   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_grup_key;
       public         	   ths_admin    false    272            ,           2606    31241    stk_gruplar stk_gruplar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_pkey;
       public         	   ths_admin    false    272            �           2606    31243 "   stk_hareketler stk_hareketler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_pkey;
       public         	   ths_admin    false    322            �           2606    31245 4   stk_kart_cins_bilgileri stk_kart_cins_bilgileri_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.stk_kart_cins_bilgileri
    ADD CONSTRAINT stk_kart_cins_bilgileri_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.stk_kart_cins_bilgileri DROP CONSTRAINT stk_kart_cins_bilgileri_pkey;
       public         	   ths_admin    false    325            �           2606    31247 (   stk_kart_ozetleri stk_kart_ozetleri_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.stk_kart_ozetleri
    ADD CONSTRAINT stk_kart_ozetleri_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.stk_kart_ozetleri DROP CONSTRAINT stk_kart_ozetleri_pkey;
       public         	   ths_admin    false    326            �           2606    31249 3   stk_kart_ozetleri stk_kart_ozetleri_stk_kart_id_key 
   CONSTRAINT     u   ALTER TABLE ONLY public.stk_kart_ozetleri
    ADD CONSTRAINT stk_kart_ozetleri_stk_kart_id_key UNIQUE (stk_kart_id);
 ]   ALTER TABLE ONLY public.stk_kart_ozetleri DROP CONSTRAINT stk_kart_ozetleri_stk_kart_id_key;
       public         	   ths_admin    false    326            .           2606    31251    stk_kartlar stk_kartlar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_pkey;
       public         	   ths_admin    false    273            0           2606    31253 %   stk_kartlar stk_kartlar_stok_kodu_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_stok_kodu_key UNIQUE (stok_kodu);
 O   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_stok_kodu_key;
       public         	   ths_admin    false    273            �           2606    31255    stk_resimler stk_resimler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.stk_resimler
    ADD CONSTRAINT stk_resimler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.stk_resimler DROP CONSTRAINT stk_resimler_pkey;
       public         	   ths_admin    false    329            �           2606    31257 )   stk_resimler stk_resimler_stk_kart_id_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.stk_resimler
    ADD CONSTRAINT stk_resimler_stk_kart_id_key UNIQUE (stk_kart_id);
 S   ALTER TABLE ONLY public.stk_resimler DROP CONSTRAINT stk_resimler_stk_kart_id_key;
       public         	   ths_admin    false    329            �           2606    31259    sys_adresler sys_adresler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_adresler
    ADD CONSTRAINT sys_adresler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_adresler DROP CONSTRAINT sys_adresler_pkey;
       public         	   ths_admin    false    333            �           2606    31261    sys_aylar sys_aylar_ay_adi_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.sys_aylar
    ADD CONSTRAINT sys_aylar_ay_adi_key UNIQUE (ay_adi);
 H   ALTER TABLE ONLY public.sys_aylar DROP CONSTRAINT sys_aylar_ay_adi_key;
       public         	   ths_admin    false    335            �           2606    31263    sys_aylar sys_aylar_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.sys_aylar
    ADD CONSTRAINT sys_aylar_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.sys_aylar DROP CONSTRAINT sys_aylar_pkey;
       public         	   ths_admin    false    335            �           2606    31265 #   sys_bolgeler sys_bolgeler_bolge_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.sys_bolgeler
    ADD CONSTRAINT sys_bolgeler_bolge_key UNIQUE (bolge);
 M   ALTER TABLE ONLY public.sys_bolgeler DROP CONSTRAINT sys_bolgeler_bolge_key;
       public         	   ths_admin    false    337            �           2606    31267    sys_bolgeler sys_bolgeler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_bolgeler
    ADD CONSTRAINT sys_bolgeler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_bolgeler DROP CONSTRAINT sys_bolgeler_pkey;
       public         	   ths_admin    false    337            �           2606    31269 >   sys_ersim_haklari sys_ersim_haklari_kaynak_id_kullanici_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kaynak_id_kullanici_id_key UNIQUE (kaynak_id, kullanici_id);
 h   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_kaynak_id_kullanici_id_key;
       public         	   ths_admin    false    340    340            �           2606    31271 (   sys_ersim_haklari sys_ersim_haklari_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_pkey;
       public         	   ths_admin    false    340            �           2606    31273 B   sys_grid_filtreler_siralamalar sys_grid_filtreler_siralamalar_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar
    ADD CONSTRAINT sys_grid_filtreler_siralamalar_pkey PRIMARY KEY (id);
 l   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar DROP CONSTRAINT sys_grid_filtreler_siralamalar_pkey;
       public         	   ths_admin    false    342            �           2606    31275 W   sys_grid_filtreler_siralamalar sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar
    ADD CONSTRAINT sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key UNIQUE (tablo_adi, is_siralama);
 �   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar DROP CONSTRAINT sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key;
       public         	   ths_admin    false    342    342            �           2606    31277 (   sys_grid_kolonlar sys_grid_kolonlar_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.sys_grid_kolonlar DROP CONSTRAINT sys_grid_kolonlar_pkey;
       public         	   ths_admin    false    344            �           2606    31279 ;   sys_grid_kolonlar sys_grid_kolonlar_tablo_adi_kolon_adi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_tablo_adi_kolon_adi_key UNIQUE (tablo_adi, kolon_adi);
 e   ALTER TABLE ONLY public.sys_grid_kolonlar DROP CONSTRAINT sys_grid_kolonlar_tablo_adi_kolon_adi_key;
       public         	   ths_admin    false    344    344            �           2606    31281 9   sys_grid_kolonlar sys_grid_kolonlar_tablo_adi_sira_no_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_tablo_adi_sira_no_key UNIQUE (tablo_adi, sira_no);
 c   ALTER TABLE ONLY public.sys_grid_kolonlar DROP CONSTRAINT sys_grid_kolonlar_tablo_adi_sira_no_key;
       public         	   ths_admin    false    344    344            �           2606    31283 A   sys_gui_icerikler sys_gui_icerikler_kod_icerik_tipi_tablo_adi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_gui_icerikler
    ADD CONSTRAINT sys_gui_icerikler_kod_icerik_tipi_tablo_adi_key UNIQUE (kod, icerik_tipi, tablo_adi);
 k   ALTER TABLE ONLY public.sys_gui_icerikler DROP CONSTRAINT sys_gui_icerikler_kod_icerik_tipi_tablo_adi_key;
       public         	   ths_admin    false    346    346    346            �           2606    31285 (   sys_gui_icerikler sys_gui_icerikler_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.sys_gui_icerikler
    ADD CONSTRAINT sys_gui_icerikler_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.sys_gui_icerikler DROP CONSTRAINT sys_gui_icerikler_pkey;
       public         	   ths_admin    false    346            �           2606    31287 !   sys_gunler sys_gunler_gun_adi_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.sys_gunler
    ADD CONSTRAINT sys_gunler_gun_adi_key UNIQUE (gun_adi);
 K   ALTER TABLE ONLY public.sys_gunler DROP CONSTRAINT sys_gunler_gun_adi_key;
       public         	   ths_admin    false    347            �           2606    31289    sys_gunler sys_gunler_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.sys_gunler
    ADD CONSTRAINT sys_gunler_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.sys_gunler DROP CONSTRAINT sys_gunler_pkey;
       public         	   ths_admin    false    347            �           2606    31291 1   sys_kaynak_gruplari sys_kaynak_gruplari_grup_ukey 
   CONSTRAINT     l   ALTER TABLE ONLY public.sys_kaynak_gruplari
    ADD CONSTRAINT sys_kaynak_gruplari_grup_ukey UNIQUE (grup);
 [   ALTER TABLE ONLY public.sys_kaynak_gruplari DROP CONSTRAINT sys_kaynak_gruplari_grup_ukey;
       public         	   ths_admin    false    349            �           2606    31293 /   sys_kaynak_gruplari sys_kaynak_gruplari_id_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.sys_kaynak_gruplari
    ADD CONSTRAINT sys_kaynak_gruplari_id_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY public.sys_kaynak_gruplari DROP CONSTRAINT sys_kaynak_gruplari_id_pkey;
       public         	   ths_admin    false    349            �           2606    31295 +   sys_kaynaklar sys_kaynaklar_kaynak_kodu_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_kaynak_kodu_key UNIQUE (kaynak_kodu);
 U   ALTER TABLE ONLY public.sys_kaynaklar DROP CONSTRAINT sys_kaynaklar_kaynak_kodu_key;
       public         	   ths_admin    false    351            �           2606    31297     sys_kaynaklar sys_kaynaklar_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.sys_kaynaklar DROP CONSTRAINT sys_kaynaklar_pkey;
       public         	   ths_admin    false    351            �           2606    31299 D   sys_olcu_birimi_tipleri sys_olcu_birimi_tipleri_olcu_birimi_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri
    ADD CONSTRAINT sys_olcu_birimi_tipleri_olcu_birimi_tipi_key UNIQUE (olcu_birimi_tipi);
 n   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri DROP CONSTRAINT sys_olcu_birimi_tipleri_olcu_birimi_tipi_key;
       public         	   ths_admin    false    358            �           2606    31301 4   sys_olcu_birimi_tipleri sys_olcu_birimi_tipleri_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri
    ADD CONSTRAINT sys_olcu_birimi_tipleri_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri DROP CONSTRAINT sys_olcu_birimi_tipleri_pkey;
       public         	   ths_admin    false    358            �           2606    31303 /   sys_olcu_birimleri sys_olcu_birimleri_birim_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_birim_key UNIQUE (birim);
 Y   ALTER TABLE ONLY public.sys_olcu_birimleri DROP CONSTRAINT sys_olcu_birimleri_birim_key;
       public         	   ths_admin    false    356            �           2606    31305 *   sys_olcu_birimleri sys_olcu_birimleri_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.sys_olcu_birimleri DROP CONSTRAINT sys_olcu_birimleri_pkey;
       public         	   ths_admin    false    356            �           2606    31307 ,   sys_ondalik_haneler sys_ondalik_haneler_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.sys_ondalik_haneler
    ADD CONSTRAINT sys_ondalik_haneler_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.sys_ondalik_haneler DROP CONSTRAINT sys_ondalik_haneler_pkey;
       public         	   ths_admin    false    360            �           2606    31309 .   sys_para_birimleri sys_para_birimleri_para_key 
   CONSTRAINT     i   ALTER TABLE ONLY public.sys_para_birimleri
    ADD CONSTRAINT sys_para_birimleri_para_key UNIQUE (para);
 X   ALTER TABLE ONLY public.sys_para_birimleri DROP CONSTRAINT sys_para_birimleri_para_key;
       public         	   ths_admin    false    362            �           2606    31311 *   sys_para_birimleri sys_para_birimleri_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.sys_para_birimleri
    ADD CONSTRAINT sys_para_birimleri_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.sys_para_birimleri DROP CONSTRAINT sys_para_birimleri_pkey;
       public         	   ths_admin    false    362            2           2606    31313    sys_sehirler sys_sehirler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_pkey;
       public         	   ths_admin    false    274            4           2606    31315 +   sys_sehirler sys_sehirler_ulke_id_sehir_key 
   CONSTRAINT     p   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_ulke_id_sehir_key UNIQUE (ulke_id, sehir);
 U   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_ulke_id_sehir_key;
       public         	   ths_admin    false    274    274            �           2606    31317    sys_ulkeler sys_ulkeler_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.sys_ulkeler
    ADD CONSTRAINT sys_ulkeler_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.sys_ulkeler DROP CONSTRAINT sys_ulkeler_pkey;
       public         	   ths_admin    false    365            �           2606    31319 %   sys_ulkeler sys_ulkeler_ulke_kodu_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.sys_ulkeler
    ADD CONSTRAINT sys_ulkeler_ulke_kodu_key UNIQUE (ulke_kodu);
 O   ALTER TABLE ONLY public.sys_ulkeler DROP CONSTRAINT sys_ulkeler_ulke_kodu_key;
       public         	   ths_admin    false    365            �           2606    31321    sys_kullanicilar sys_users_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_pkey PRIMARY KEY (id);
 I   ALTER TABLE ONLY public.sys_kullanicilar DROP CONSTRAINT sys_users_pkey;
       public         	   ths_admin    false    353            �           2606    31323 '   sys_kullanicilar sys_users_username_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_username_key UNIQUE (kullanici_adi);
 Q   ALTER TABLE ONLY public.sys_kullanicilar DROP CONSTRAINT sys_users_username_key;
       public         	   ths_admin    false    353            �           2606    31325 0   sys_uygulama_ayarlari sys_uygulama_ayarlari_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_pkey;
       public         	   ths_admin    false    367            �           2606    31327 ,   urt_iscilikler urt_iscilikler_gider_kodu_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_gider_kodu_key UNIQUE (gider_kodu);
 V   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_gider_kodu_key;
       public         	   ths_admin    false    239            �           2606    31329 "   urt_iscilikler urt_iscilikler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_pkey;
       public         	   ths_admin    false    239            �           2606    31331 >   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_pkey;
       public         	   ths_admin    false    241            �           2606    31333 Q   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_stok_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_header_id_key UNIQUE (stok_kodu, header_id);
 {   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_header_id_key;
       public         	   ths_admin    false    241    241            �           2606    31335 9   urt_paket_hammaddeler urt_paket_hammaddeler_paket_adi_key 
   CONSTRAINT     y   ALTER TABLE ONLY public.urt_paket_hammaddeler
    ADD CONSTRAINT urt_paket_hammaddeler_paket_adi_key UNIQUE (paket_adi);
 c   ALTER TABLE ONLY public.urt_paket_hammaddeler DROP CONSTRAINT urt_paket_hammaddeler_paket_adi_key;
       public         	   ths_admin    false    243            �           2606    31337 0   urt_paket_hammaddeler urt_paket_hammaddeler_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.urt_paket_hammaddeler
    ADD CONSTRAINT urt_paket_hammaddeler_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.urt_paket_hammaddeler DROP CONSTRAINT urt_paket_hammaddeler_pkey;
       public         	   ths_admin    false    243            �           2606    31339 <   urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_pkey PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_paket_iscilik_detaylari_pkey;
       public         	   ths_admin    false    245                        2606    31341 7   urt_paket_iscilikler urt_paket_iscilikler_paket_adi_key 
   CONSTRAINT     w   ALTER TABLE ONLY public.urt_paket_iscilikler
    ADD CONSTRAINT urt_paket_iscilikler_paket_adi_key UNIQUE (paket_adi);
 a   ALTER TABLE ONLY public.urt_paket_iscilikler DROP CONSTRAINT urt_paket_iscilikler_paket_adi_key;
       public         	   ths_admin    false    247                       2606    31343 .   urt_paket_iscilikler urt_paket_iscilikler_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.urt_paket_iscilikler
    ADD CONSTRAINT urt_paket_iscilikler_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.urt_paket_iscilikler DROP CONSTRAINT urt_paket_iscilikler_pkey;
       public         	   ths_admin    false    247                       2606    31345 2   urt_recete_hammaddeler urt_recete_hammaddeler_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_pkey;
       public         	   ths_admin    false    249                       2606    31347 E   urt_recete_hammaddeler urt_recete_hammaddeler_stok_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_stok_kodu_header_id_key UNIQUE (stok_kodu, header_id);
 o   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_stok_kodu_header_id_key;
       public         	   ths_admin    false    249    249                       2606    31349 <   urt_recete_iscilikler urt_recete_iscilikler_iscilik_kodu_key 
   CONSTRAINT        ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_iscilik_kodu_key UNIQUE (iscilik_kodu);
 f   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_iscilik_kodu_key;
       public         	   ths_admin    false    253                       2606    31351 0   urt_recete_iscilikler urt_recete_iscilikler_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_pkey;
       public         	   ths_admin    false    253                       2606    31353 P   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_header_id_paket_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_header_id_paket_id_key UNIQUE (header_id, paket_id);
 z   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_header_id_paket_id_key;
       public         	   ths_admin    false    255    255                       2606    31355 >   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_pkey;
       public         	   ths_admin    false    255            �           2606    31357 Y   urt_paket_iscilik_detaylari urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key UNIQUE (iscilik_kodu, header_id);
 �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key;
       public         	   ths_admin    false    245    245                       2606    31359 N   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_header_id_paket_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_header_id_paket_id_key UNIQUE (header_id, paket_id);
 x   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_header_id_paket_id_key;
       public         	   ths_admin    false    257    257                       2606    31361 <   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_pkey PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_pkey;
       public         	   ths_admin    false    257            �           2606    31363 2   urt_recete_yan_urunler urt_recete_yan_urunler_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_pkey;
       public         	   ths_admin    false    372            �           2606    31365 E   urt_recete_yan_urunler urt_recete_yan_urunler_urun_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_urun_kodu_header_id_key UNIQUE (urun_kodu, header_id);
 o   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_urun_kodu_header_id_key;
       public         	   ths_admin    false    372    372                       2606    31367     urt_receteler urt_receteler_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.urt_receteler DROP CONSTRAINT urt_receteler_pkey;
       public         	   ths_admin    false    251            
           2606    31369 2   urt_receteler urt_receteler_urun_kodu_urun_adi_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_urun_kodu_urun_adi_key UNIQUE (urun_kodu, urun_adi);
 \   ALTER TABLE ONLY public.urt_receteler DROP CONSTRAINT urt_receteler_urun_kodu_urun_adi_key;
       public         	   ths_admin    false    251    251            �           1259    31370 "   idx_als_teklif_detaylari_header_id    INDEX     h   CREATE INDEX idx_als_teklif_detaylari_header_id ON public.als_teklif_detaylari USING btree (header_id);
 6   DROP INDEX public.idx_als_teklif_detaylari_header_id;
       public         	   ths_admin    false    209                       1259    31371 #   idx_sat_siparis_detaylari_header_id    INDEX     j   CREATE INDEX idx_sat_siparis_detaylari_header_id ON public.sat_siparis_detaylari USING btree (header_id);
 7   DROP INDEX public.idx_sat_siparis_detaylari_header_id;
       public         	   ths_admin    false    267            "           1259    31372    idx_sat_siparis_musteri_kodu    INDEX     _   CREATE INDEX idx_sat_siparis_musteri_kodu ON public.sat_siparisler USING btree (musteri_kodu);
 0   DROP INDEX public.idx_sat_siparis_musteri_kodu;
       public         	   ths_admin    false    269            5           1259    31373 "   idx_sat_teklif_detaylari_header_id    INDEX     h   CREATE INDEX idx_sat_teklif_detaylari_header_id ON public.sat_teklif_detaylari USING btree (header_id);
 6   DROP INDEX public.idx_sat_teklif_detaylari_header_id;
       public         	   ths_admin    false    276            d           2620    31374    set_prs_bolumler audit    TRIGGER        CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_bolumler FOR EACH ROW EXECUTE FUNCTION public.audit();
 /   DROP TRIGGER audit ON public.set_prs_bolumler;
       public       	   ths_admin    false    302    389            R           2620    31375    prs_ehliyetler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prs_ehliyetler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 .   DROP TRIGGER notify ON public.prs_ehliyetler;
       public       	   ths_admin    false    399    233            S           2620    31376    prs_lisan_bilgileri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prs_lisan_bilgileri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 3   DROP TRIGGER notify ON public.prs_lisan_bilgileri;
       public       	   ths_admin    false    399    234            T           2620    31377    prs_personeller notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prs_personeller FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER notify ON public.prs_personeller;
       public       	   ths_admin    false    399    237            b           2620    31378    set_prs_birimler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_birimler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 0   DROP TRIGGER notify ON public.set_prs_birimler;
       public       	   ths_admin    false    300    399            e           2620    31379    set_prs_ehliyetler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_ehliyetler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 2   DROP TRIGGER notify ON public.set_prs_ehliyetler;
       public       	   ths_admin    false    304    399            f           2620    31380    set_prs_gorevler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_gorevler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 0   DROP TRIGGER notify ON public.set_prs_gorevler;
       public       	   ths_admin    false    306    399            h           2620    31381    set_prs_lisan_seviyeleri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_lisan_seviyeleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER notify ON public.set_prs_lisan_seviyeleri;
       public       	   ths_admin    false    399    310            g           2620    31382    set_prs_lisanlar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_lisanlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 0   DROP TRIGGER notify ON public.set_prs_lisanlar;
       public       	   ths_admin    false    308    399            i           2620    31383    set_prs_personel_tipleri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_personel_tipleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER notify ON public.set_prs_personel_tipleri;
       public       	   ths_admin    false    312    399            j           2620    31384     set_prs_tasima_servisleri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_tasima_servisleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER notify ON public.set_prs_tasima_servisleri;
       public       	   ths_admin    false    314    399            k           2620    31385    stk_ambarlar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_ambarlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 ,   DROP TRIGGER notify ON public.stk_ambarlar;
       public       	   ths_admin    false    319    399            _           2620    31386    stk_gruplar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_gruplar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 +   DROP TRIGGER notify ON public.stk_gruplar;
       public       	   ths_admin    false    272    399            m           2620    31387    stk_hareketler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_hareketler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 .   DROP TRIGGER notify ON public.stk_hareketler;
       public       	   ths_admin    false    322    399            n           2620    31388    stk_kart_cins_bilgileri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_kart_cins_bilgileri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 7   DROP TRIGGER notify ON public.stk_kart_cins_bilgileri;
       public       	   ths_admin    false    325    399            `           2620    31389    stk_kartlar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_kartlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 +   DROP TRIGGER notify ON public.stk_kartlar;
       public       	   ths_admin    false    399    273            o           2620    31390 1   sys_grid_kolonlar sys_grid_col_width_table_notify    TRIGGER     �   CREATE TRIGGER sys_grid_col_width_table_notify AFTER INSERT OR DELETE OR UPDATE ON public.sys_grid_kolonlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 J   DROP TRIGGER sys_grid_col_width_table_notify ON public.sys_grid_kolonlar;
       public       	   ths_admin    false    344    399            c           2620    31391    set_prs_bolumler table_notify    TRIGGER     �   CREATE TRIGGER table_notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_bolumler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 6   DROP TRIGGER table_notify ON public.set_prs_bolumler;
       public       	   ths_admin    false    302    399            l           2620    31392 !   stk_cins_ozellikleri table_notify    TRIGGER     �   CREATE TRIGGER table_notify BEFORE INSERT OR DELETE OR UPDATE ON public.stk_cins_ozellikleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 :   DROP TRIGGER table_notify ON public.stk_cins_ozellikleri;
       public       	   ths_admin    false    399    321            K           2620    31393    ch_banka_subeleri trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_banka_subeleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 5   DROP TRIGGER trg_notify ON public.ch_banka_subeleri;
       public       	   ths_admin    false    217    399            J           2620    31394    ch_bankalar trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_bankalar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER trg_notify ON public.ch_bankalar;
       public       	   ths_admin    false    215    399            L           2620    31395    ch_bolgeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_bolgeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER trg_notify ON public.ch_bolgeler;
       public       	   ths_admin    false    399    219            M           2620    31396    ch_doviz_kurlari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_doviz_kurlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 4   DROP TRIGGER trg_notify ON public.ch_doviz_kurlari;
       public       	   ths_admin    false    399    221            N           2620    31397    ch_hesaplar trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_hesaplar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER trg_notify ON public.ch_hesaplar;
       public       	   ths_admin    false    223    399            O           2620    31398    mhs_fis_detaylari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.mhs_fis_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 5   DROP TRIGGER trg_notify ON public.mhs_fis_detaylari;
       public       	   ths_admin    false    399    227            P           2620    31399    mhs_fisler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.mhs_fisler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 .   DROP TRIGGER trg_notify ON public.mhs_fisler;
       public       	   ths_admin    false    399    229            Q           2620    31400    mhs_transfer_kodlari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.mhs_transfer_kodlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER trg_notify ON public.mhs_transfer_kodlari;
       public       	   ths_admin    false    231    399            a           2620    31401     set_ch_vergi_oranlari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.set_ch_vergi_oranlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER trg_notify ON public.set_ch_vergi_oranlari;
       public       	   ths_admin    false    399    288            U           2620    31402    urt_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 2   DROP TRIGGER trg_notify ON public.urt_iscilikler;
       public       	   ths_admin    false    239    399            V           2620    31403 '   urt_paket_hammadde_detaylari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_hammadde_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 @   DROP TRIGGER trg_notify ON public.urt_paket_hammadde_detaylari;
       public       	   ths_admin    false    399    241            W           2620    31404     urt_paket_hammaddeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER trg_notify ON public.urt_paket_hammaddeler;
       public       	   ths_admin    false    243    399            X           2620    31405 &   urt_paket_iscilik_detaylari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_iscilik_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 ?   DROP TRIGGER trg_notify ON public.urt_paket_iscilik_detaylari;
       public       	   ths_admin    false    245    399            Y           2620    31406    urt_paket_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER trg_notify ON public.urt_paket_iscilikler;
       public       	   ths_admin    false    247    399            Z           2620    31407 !   urt_recete_hammaddeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 :   DROP TRIGGER trg_notify ON public.urt_recete_hammaddeler;
       public       	   ths_admin    false    249    399            \           2620    31408     urt_recete_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER trg_notify ON public.urt_recete_iscilikler;
       public       	   ths_admin    false    399    253            ]           2620    31409 '   urt_recete_paket_hammaddeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_paket_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 @   DROP TRIGGER trg_notify ON public.urt_recete_paket_hammaddeler;
       public       	   ths_admin    false    399    255            ^           2620    31410 &   urt_recete_paket_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_paket_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 ?   DROP TRIGGER trg_notify ON public.urt_recete_paket_iscilikler;
       public       	   ths_admin    false    399    257            p           2620    31411 !   urt_recete_yan_urunler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_yan_urunler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 :   DROP TRIGGER trg_notify ON public.urt_recete_yan_urunler;
       public       	   ths_admin    false    399    372            [           2620    31412    urt_receteler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_receteler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 1   DROP TRIGGER trg_notify ON public.urt_receteler;
       public       	   ths_admin    false    399    251            �           2606    31413 8   als_teklif_detaylari als_teklif_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.als_teklifler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.als_teklif_detaylari DROP CONSTRAINT als_teklif_detaylari_header_id_fkey;
       public       	   ths_admin    false    211    3772    209            �           2606    31418 :   als_teklif_detaylari als_teklif_detaylari_olcu_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_olcu_birimi_fkey FOREIGN KEY (olcu_birimi) REFERENCES public.sys_olcu_birimleri(birim) ON UPDATE CASCADE ON DELETE RESTRICT;
 d   ALTER TABLE ONLY public.als_teklif_detaylari DROP CONSTRAINT als_teklif_detaylari_olcu_birimi_fkey;
       public       	   ths_admin    false    4037    356    209            �           2606    31423 C   als_teklif_detaylari als_teklif_detaylari_referans_ana_urun_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.als_teklif_detaylari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 m   ALTER TABLE ONLY public.als_teklif_detaylari DROP CONSTRAINT als_teklif_detaylari_referans_ana_urun_id_fkey;
       public       	   ths_admin    false    209    3769    209            �           2606    31428 8   als_teklif_detaylari als_teklif_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 b   ALTER TABLE ONLY public.als_teklif_detaylari DROP CONSTRAINT als_teklif_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    3888    209    273            �           2606    31433 .   als_teklifler als_teklifler_islem_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_islem_tipi_id_fkey FOREIGN KEY (islem_tipi_id) REFERENCES public.set_einv_fatura_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_islem_tipi_id_fkey;
       public       	   ths_admin    false    3919    290    211            �           2606    31438 -   als_teklifler als_teklifler_musteri_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_musteri_kodu_fkey FOREIGN KEY (musteri_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_musteri_kodu_fkey;
       public       	   ths_admin    false    223    211    3798            �           2606    31443 ,   als_teklifler als_teklifler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 V   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_para_birimi_fkey;
       public       	   ths_admin    false    4047    211    362            �           2606    31448 )   als_teklifler als_teklifler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_sehir_id_fkey;
       public       	   ths_admin    false    274    3890    211            �           2606    31453 (   als_teklifler als_teklifler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 R   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_ulke_id_fkey;
       public       	   ths_admin    false    211    365    4051            �           2606    31458 1   ch_banka_subeleri ch_banka_subeleri_banka_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_banka_id_fkey FOREIGN KEY (banka_id) REFERENCES public.ch_bankalar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_banka_id_fkey;
       public       	   ths_admin    false    215    3780    217            �           2606    31463 1   ch_banka_subeleri ch_banka_subeleri_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_sehir_id_fkey;
       public       	   ths_admin    false    3890    274    217            �           2606    31468 +   ch_doviz_kurlari ch_doviz_kurlari_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_para_fkey FOREIGN KEY (para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE CASCADE;
 U   ALTER TABLE ONLY public.ch_doviz_kurlari DROP CONSTRAINT ch_doviz_kurlari_para_fkey;
       public       	   ths_admin    false    221    4047    362            �           2606    31473 %   ch_hesaplar ch_hesaplar_bolge_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_bolge_id_fkey FOREIGN KEY (bolge_id) REFERENCES public.ch_hesap_planlari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 O   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_bolge_id_fkey;
       public       	   ths_admin    false    223    3802    225            �           2606    31478 $   ch_hesaplar ch_hesaplar_grup_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_grup_id_fkey FOREIGN KEY (grup_id) REFERENCES public.ch_gruplar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 N   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_grup_id_fkey;
       public       	   ths_admin    false    222    223    3796            �           2606    31483 *   ch_hesaplar ch_hesaplar_hesap_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_hesap_tipi_id_fkey FOREIGN KEY (hesap_tipi_id) REFERENCES public.set_ch_hesap_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 T   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_hesap_tipi_id_fkey;
       public       	   ths_admin    false    3911    223    286            �           2606    31488 2   mhs_fis_detaylari mhs_fis_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mhs_fis_detaylari
    ADD CONSTRAINT mhs_fis_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.mhs_fisler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.mhs_fis_detaylari DROP CONSTRAINT mhs_fis_detaylari_header_id_fkey;
       public       	   ths_admin    false    3806    229    227            �           2606    31493 9   mhs_transfer_kodlari mhs_transfer_kodlari_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mhs_transfer_kodlari
    ADD CONSTRAINT mhs_transfer_kodlari_hesap_kodu_fkey FOREIGN KEY (hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 c   ALTER TABLE ONLY public.mhs_transfer_kodlari DROP CONSTRAINT mhs_transfer_kodlari_hesap_kodu_fkey;
       public       	   ths_admin    false    223    3798    231            �           2606    31498 -   prs_ehliyetler prs_ehliyetler_ehliyet_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_ehliyet_id_fkey FOREIGN KEY (ehliyet_id) REFERENCES public.set_prs_ehliyetler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 W   ALTER TABLE ONLY public.prs_ehliyetler DROP CONSTRAINT prs_ehliyetler_ehliyet_id_fkey;
       public       	   ths_admin    false    3947    304    233            �           2606    31503 .   prs_ehliyetler prs_ehliyetler_personel_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_personel_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE CASCADE;
 X   ALTER TABLE ONLY public.prs_ehliyetler DROP CONSTRAINT prs_ehliyetler_personel_id_fkey;
       public       	   ths_admin    false    233    3822    237            �           2606    31508 7   prs_lisan_bilgileri prs_lisan_bilgileri_konusma_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_konusma_id_fkey FOREIGN KEY (konusma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;
 a   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_konusma_id_fkey;
       public       	   ths_admin    false    234    3959    310            �           2606    31513 5   prs_lisan_bilgileri prs_lisan_bilgileri_lisan_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_lisan_id_fkey FOREIGN KEY (lisan_id) REFERENCES public.set_prs_lisanlar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_lisan_id_fkey;
       public       	   ths_admin    false    234    3955    308            �           2606    31518 5   prs_lisan_bilgileri prs_lisan_bilgileri_okuma_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_okuma_id_fkey FOREIGN KEY (okuma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_okuma_id_fkey;
       public       	   ths_admin    false    234    310    3959            �           2606    31523 8   prs_lisan_bilgileri prs_lisan_bilgileri_personel_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_personel_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_personel_id_fkey;
       public       	   ths_admin    false    234    237    3822            �           2606    31528 5   prs_lisan_bilgileri prs_lisan_bilgileri_yazma_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_yazma_id_fkey FOREIGN KEY (yazma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_yazma_id_fkey;
       public       	   ths_admin    false    3959    310    234            �           2606    31533 -   prs_personeller prs_personeller_adres_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_adres_id_fkey FOREIGN KEY (adres_id) REFERENCES public.sys_adresler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 W   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_adres_id_fkey;
       public       	   ths_admin    false    333    237    3993            �           2606    31538 -   prs_personeller prs_personeller_birim_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_birim_id_fkey FOREIGN KEY (birim_id) REFERENCES public.set_prs_birimler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 W   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_birim_id_fkey;
       public       	   ths_admin    false    237    300    3939            �           2606    31543 -   prs_personeller prs_personeller_gorev_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_gorev_id_fkey FOREIGN KEY (gorev_id) REFERENCES public.set_prs_gorevler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 W   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_gorev_id_fkey;
       public       	   ths_admin    false    237    306    3951            �           2606    31548 5   prs_personeller prs_personeller_personel_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_personel_tipi_id_fkey FOREIGN KEY (personel_tipi_id) REFERENCES public.set_prs_personel_tipleri(id) ON UPDATE CASCADE ON DELETE SET NULL;
 _   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_personel_tipi_id_fkey;
       public       	   ths_admin    false    312    3963    237            �           2606    31553 5   prs_personeller prs_personeller_tasima_servis_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_tasima_servis_id_fkey FOREIGN KEY (tasima_servis_id) REFERENCES public.set_prs_tasima_servisleri(id) ON UPDATE CASCADE ON DELETE SET NULL;
 _   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_tasima_servis_id_fkey;
       public       	   ths_admin    false    314    237    3967            
           2606    31558 8   sat_fatura_detaylari sat_fatura_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_fatura_detaylari
    ADD CONSTRAINT sat_fatura_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_faturalar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.sat_fatura_detaylari DROP CONSTRAINT sat_fatura_detaylari_header_id_fkey;
       public       	   ths_admin    false    3866    259    261                       2606    31563 <   sat_irsaliye_detaylari sat_irsaliye_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_irsaliye_detaylari
    ADD CONSTRAINT sat_irsaliye_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_irsaliyeler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.sat_irsaliye_detaylari DROP CONSTRAINT sat_irsaliye_detaylari_header_id_fkey;
       public       	   ths_admin    false    265    3870    263                       2606    31568 :   sat_siparis_detaylari sat_siparis_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_siparisler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 d   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_header_id_fkey;
       public       	   ths_admin    false    3876    267    269                       2606    31573 <   sat_siparis_detaylari sat_siparis_detaylari_olcu_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_olcu_birimi_fkey FOREIGN KEY (olcu_birimi) REFERENCES public.sys_olcu_birimleri(birim) ON UPDATE CASCADE ON DELETE RESTRICT;
 f   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_olcu_birimi_fkey;
       public       	   ths_admin    false    356    267    4037                       2606    31578 E   sat_siparis_detaylari sat_siparis_detaylari_referans_ana_urun_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.sat_siparis_detaylari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 o   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_referans_ana_urun_id_fkey;
       public       	   ths_admin    false    3873    267    267                       2606    31583 :   sat_siparis_detaylari sat_siparis_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 d   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    267    3888    273                       2606    31588 0   sat_siparisler sat_siparisler_islem_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_islem_tipi_id_fkey FOREIGN KEY (islem_tipi_id) REFERENCES public.set_einv_fatura_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_islem_tipi_id_fkey;
       public       	   ths_admin    false    290    269    3919                       2606    31593 /   sat_siparisler sat_siparisler_musteri_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_musteri_kodu_fkey FOREIGN KEY (musteri_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_musteri_kodu_fkey;
       public       	   ths_admin    false    223    3798    269                       2606    31598 8   sat_siparisler sat_siparisler_musteri_temsilcisi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_musteri_temsilcisi_id_fkey FOREIGN KEY (musteri_temsilcisi_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 b   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_musteri_temsilcisi_id_fkey;
       public       	   ths_admin    false    269    3822    237                       2606    31603 4   sat_siparisler sat_siparisler_nakliye_ucreti_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_nakliye_ucreti_id_fkey FOREIGN KEY (tasima_ucreti_id) REFERENCES public.set_einv_tasima_ucretleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 ^   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_nakliye_ucreti_id_fkey;
       public       	   ths_admin    false    269    3929    296                       2606    31608 1   sat_siparisler sat_siparisler_odeme_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_odeme_sekli_id_fkey FOREIGN KEY (odeme_sekli_id) REFERENCES public.set_einv_odeme_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_odeme_sekli_id_fkey;
       public       	   ths_admin    false    3921    269    292                       2606    31613 0   sat_siparisler sat_siparisler_paket_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_paket_tipi_id_fkey FOREIGN KEY (paket_tipi_id) REFERENCES public.set_einv_paket_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_paket_tipi_id_fkey;
       public       	   ths_admin    false    3927    294    269                       2606    31618 .   sat_siparisler sat_siparisler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_para_birimi_fkey;
       public       	   ths_admin    false    362    4047    269                       2606    31623 +   sat_siparisler sat_siparisler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 U   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_sehir_id_fkey;
       public       	   ths_admin    false    274    269    3890                       2606    31628 3   sat_siparisler sat_siparisler_siparis_durum_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_siparis_durum_id_fkey FOREIGN KEY (siparis_durum_id) REFERENCES public.set_sls_order_status(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 ]   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_siparis_durum_id_fkey;
       public       	   ths_admin    false    269    3878    271                       2606    31633 2   sat_siparisler sat_siparisler_teslim_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_teslim_sekli_id_fkey FOREIGN KEY (teslim_sekli_id) REFERENCES public.set_einv_teslim_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 \   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_teslim_sekli_id_fkey;
       public       	   ths_admin    false    269    3933    298                       2606    31638 *   sat_siparisler sat_siparisler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 T   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_ulke_id_fkey;
       public       	   ths_admin    false    269    4051    365            &           2606    31643 8   sat_teklif_detaylari sat_teklif_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_teklifler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_header_id_fkey;
       public       	   ths_admin    false    276    278    3899            '           2606    31648 :   sat_teklif_detaylari sat_teklif_detaylari_olcu_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_olcu_birimi_fkey FOREIGN KEY (olcu_birimi) REFERENCES public.sys_olcu_birimleri(birim) ON UPDATE CASCADE ON DELETE RESTRICT;
 d   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_olcu_birimi_fkey;
       public       	   ths_admin    false    356    4037    276            (           2606    31653 C   sat_teklif_detaylari sat_teklif_detaylari_referans_ana_urun_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.sat_teklif_detaylari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 m   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_referans_ana_urun_id_fkey;
       public       	   ths_admin    false    276    276    3895            )           2606    31658 8   sat_teklif_detaylari sat_teklif_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 b   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    3888    276    273            *           2606    31663 .   sat_teklifler sat_teklifler_islem_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_islem_tipi_id_fkey FOREIGN KEY (islem_tipi_id) REFERENCES public.set_einv_fatura_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_islem_tipi_id_fkey;
       public       	   ths_admin    false    3919    278    290            +           2606    31668 -   sat_teklifler sat_teklifler_musteri_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_musteri_kodu_fkey FOREIGN KEY (musteri_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_musteri_kodu_fkey;
       public       	   ths_admin    false    278    3798    223            ,           2606    31673 6   sat_teklifler sat_teklifler_musteri_temsilcisi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_musteri_temsilcisi_id_fkey FOREIGN KEY (musteri_temsilcisi_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 `   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_musteri_temsilcisi_id_fkey;
       public       	   ths_admin    false    3822    237    278            -           2606    31678 2   sat_teklifler sat_teklifler_nakliye_ucreti_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_nakliye_ucreti_id_fkey FOREIGN KEY (tasima_ucreti_id) REFERENCES public.set_einv_tasima_ucretleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 \   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_nakliye_ucreti_id_fkey;
       public       	   ths_admin    false    296    278    3929            .           2606    31683 /   sat_teklifler sat_teklifler_odeme_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_odeme_sekli_id_fkey FOREIGN KEY (odeme_sekli_id) REFERENCES public.set_einv_odeme_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_odeme_sekli_id_fkey;
       public       	   ths_admin    false    278    292    3921            /           2606    31688 .   sat_teklifler sat_teklifler_paket_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_paket_tipi_id_fkey FOREIGN KEY (paket_tipi_id) REFERENCES public.set_einv_paket_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_paket_tipi_id_fkey;
       public       	   ths_admin    false    3927    294    278            0           2606    31693 ,   sat_teklifler sat_teklifler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 V   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_para_birimi_fkey;
       public       	   ths_admin    false    4047    362    278            1           2606    31698 )   sat_teklifler sat_teklifler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_sehir_id_fkey;
       public       	   ths_admin    false    274    3890    278            2           2606    31703 0   sat_teklifler sat_teklifler_teslim_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_teslim_sekli_id_fkey FOREIGN KEY (teslim_sekli_id) REFERENCES public.set_einv_teslim_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_teslim_sekli_id_fkey;
       public       	   ths_admin    false    3933    278    298            3           2606    31708 (   sat_teklifler sat_teklifler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 R   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_ulke_id_fkey;
       public       	   ths_admin    false    278    4051    365            4           2606    31713 <   set_ch_firma_tipleri set_ch_firma_tipleri_firma_turu_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_firma_turu_id_fkey FOREIGN KEY (firma_turu_id) REFERENCES public.set_ch_firma_turleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 f   ALTER TABLE ONLY public.set_ch_firma_tipleri DROP CONSTRAINT set_ch_firma_tipleri_firma_turu_id_fkey;
       public       	   ths_admin    false    282    3907    280            5           2606    31718 @   set_ch_vergi_oranlari set_ch_vergi_oranlari_alis_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_alis_hesap_kodu_fkey FOREIGN KEY (alis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 j   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_alis_hesap_kodu_fkey;
       public       	   ths_admin    false    288    3798    223            6           2606    31723 E   set_ch_vergi_oranlari set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey FOREIGN KEY (alis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 o   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    223    288    3798            7           2606    31728 A   set_ch_vergi_oranlari set_ch_vergi_oranlari_satis_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_satis_hesap_kodu_fkey FOREIGN KEY (satis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 k   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_satis_hesap_kodu_fkey;
       public       	   ths_admin    false    288    223    3798            8           2606    31733 F   set_ch_vergi_oranlari set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey FOREIGN KEY (satis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 p   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    3798    223    288            9           2606    31738 /   set_prs_birimler set_prs_birimler_bolum_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_bolum_id_fkey FOREIGN KEY (bolum_id) REFERENCES public.set_prs_bolumler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.set_prs_birimler DROP CONSTRAINT set_prs_birimler_bolum_id_fkey;
       public       	   ths_admin    false    3943    300    302                       2606    31743 9   stk_gruplar stk_gruplar_hammadde_kullanim_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_hammadde_kullanim_hesap_kodu_fkey FOREIGN KEY (hammadde_kullanim_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 c   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_hammadde_kullanim_hesap_kodu_fkey;
       public       	   ths_admin    false    3798    223    272                       2606    31748 5   stk_gruplar stk_gruplar_hammadde_stok_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_hammadde_stok_hesap_kodu_fkey FOREIGN KEY (hammadde_stok_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 _   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_hammadde_stok_hesap_kodu_fkey;
       public       	   ths_admin    false    3798    272    223                       2606    31753 2   stk_gruplar stk_gruplar_yari_mamul_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_yari_mamul_hesap_kodu_fkey FOREIGN KEY (yari_mamul_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 \   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_yari_mamul_hesap_kodu_fkey;
       public       	   ths_admin    false    223    272    3798            :           2606    31758 0   stk_hareketler stk_hareketler_alan_ambar_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_alan_ambar_id_fkey FOREIGN KEY (alan_ambar_id) REFERENCES public.stk_ambarlar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_alan_ambar_id_fkey;
       public       	   ths_admin    false    322    3975    319            ;           2606    31763 .   stk_hareketler stk_hareketler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_para_birimi_fkey;
       public       	   ths_admin    false    362    4047    322            <           2606    31768 ,   stk_hareketler stk_hareketler_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 V   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_stok_kodu_fkey;
       public       	   ths_admin    false    3888    322    273            =           2606    31773 1   stk_hareketler stk_hareketler_veren_ambar_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_veren_ambar_id_fkey FOREIGN KEY (veren_ambar_id) REFERENCES public.stk_ambarlar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_veren_ambar_id_fkey;
       public       	   ths_admin    false    322    3975    319            >           2606    31778 4   stk_kart_ozetleri stk_kart_ozetleri_stk_kart_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kart_ozetleri
    ADD CONSTRAINT stk_kart_ozetleri_stk_kart_id_fkey FOREIGN KEY (stk_kart_id) REFERENCES public.stk_kartlar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.stk_kart_ozetleri DROP CONSTRAINT stk_kart_ozetleri_stk_kart_id_fkey;
       public       	   ths_admin    false    326    3886    273                       2606    31783 &   stk_kartlar stk_kartlar_alis_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_alis_para_fkey FOREIGN KEY (alis_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 P   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_alis_para_fkey;
       public       	   ths_admin    false    362    273    4047                       2606    31788 '   stk_kartlar stk_kartlar_ihrac_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_ihrac_para_fkey FOREIGN KEY (ihrac_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_ihrac_para_fkey;
       public       	   ths_admin    false    362    4047    273                        2606    31793 &   stk_kartlar stk_kartlar_mensei_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_mensei_id_fkey FOREIGN KEY (mensei_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 P   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_mensei_id_fkey;
       public       	   ths_admin    false    273    365    4051            !           2606    31798 +   stk_kartlar stk_kartlar_olcu_birimi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_olcu_birimi_id_fkey FOREIGN KEY (olcu_birimi_id) REFERENCES public.sys_olcu_birimleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 U   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_olcu_birimi_id_fkey;
       public       	   ths_admin    false    273    4039    356            "           2606    31803 '   stk_kartlar stk_kartlar_satis_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_satis_para_fkey FOREIGN KEY (satis_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_satis_para_fkey;
       public       	   ths_admin    false    273    4047    362            #           2606    31808 *   stk_kartlar stk_kartlar_stok_grubu_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_stok_grubu_id_fkey FOREIGN KEY (stok_grubu_id) REFERENCES public.stk_gruplar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 T   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_stok_grubu_id_fkey;
       public       	   ths_admin    false    273    3884    272            ?           2606    31813 *   stk_resimler stk_resimler_stk_kart_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_resimler
    ADD CONSTRAINT stk_resimler_stk_kart_id_fkey FOREIGN KEY (stk_kart_id) REFERENCES public.stk_kartlar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stk_resimler DROP CONSTRAINT stk_resimler_stk_kart_id_fkey;
       public       	   ths_admin    false    3886    329    273            @           2606    31818 '   sys_adresler sys_adresler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_adresler
    ADD CONSTRAINT sys_adresler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.sys_adresler DROP CONSTRAINT sys_adresler_sehir_id_fkey;
       public       	   ths_admin    false    3890    274    333            A           2606    31823 2   sys_ersim_haklari sys_ersim_haklari_kaynak_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kaynak_id_fkey FOREIGN KEY (kaynak_id) REFERENCES public.sys_kaynaklar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_kaynak_id_fkey;
       public       	   ths_admin    false    4031    340    351            B           2606    31828 5   sys_ersim_haklari sys_ersim_haklari_kullanici_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kullanici_id_fkey FOREIGN KEY (kullanici_id) REFERENCES public.sys_kullanicilar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_kullanici_id_fkey;
       public       	   ths_admin    false    340    353    4033            C           2606    31833 /   sys_kaynaklar sys_kaynaklar_kaynak_grup_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_kaynak_grup_id_fkey FOREIGN KEY (kaynak_grup_id) REFERENCES public.sys_kaynak_gruplari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.sys_kaynaklar DROP CONSTRAINT sys_kaynaklar_kaynak_grup_id_fkey;
       public       	   ths_admin    false    4027    349    351            E           2606    31838 8   sys_olcu_birimleri sys_olcu_birimleri_birim_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_birim_tipi_id_fkey FOREIGN KEY (birim_tipi_id) REFERENCES public.sys_olcu_birimi_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 b   ALTER TABLE ONLY public.sys_olcu_birimleri DROP CONSTRAINT sys_olcu_birimleri_birim_tipi_id_fkey;
       public       	   ths_admin    false    358    356    4043            $           2606    31843 '   sys_sehirler sys_sehirler_bolge_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_bolge_id_fkey FOREIGN KEY (bolge_id) REFERENCES public.sys_bolgeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_bolge_id_fkey;
       public       	   ths_admin    false    274    337    4001            %           2606    31848 &   sys_sehirler sys_sehirler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 P   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_ulke_id_fkey;
       public       	   ths_admin    false    274    4051    365            D           2606    31853 )   sys_kullanicilar sys_users_person_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_person_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.sys_kullanicilar DROP CONSTRAINT sys_users_person_id_fkey;
       public       	   ths_admin    false    353    3822    237            F           2606    31858 9   sys_uygulama_ayarlari sys_uygulama_ayarlari_adres_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_adres_id_fkey FOREIGN KEY (adres_id) REFERENCES public.sys_adresler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 c   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_adres_id_fkey;
       public       	   ths_admin    false    333    367    3993            G           2606    31863 5   sys_uygulama_ayarlari sys_uygulama_ayarlari_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_para_fkey FOREIGN KEY (para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE SET NULL;
 _   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_para_fkey;
       public       	   ths_admin    false    367    362    4047            �           2606    31868 +   urt_iscilikler urt_iscilikler_birim_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_birim_id_fkey FOREIGN KEY (birim_id) REFERENCES public.sys_olcu_birimleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 U   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_birim_id_fkey;
       public       	   ths_admin    false    239    356    4039            �           2606    31873 -   urt_iscilikler urt_iscilikler_gider_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_gider_kodu_fkey FOREIGN KEY (gider_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_gider_kodu_fkey;
       public       	   ths_admin    false    223    3798    239            �           2606    31878 H   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_paket_hammaddeler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 r   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_header_id_fkey;
       public       	   ths_admin    false    3834    243    241            �           2606    31883 H   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_recete_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_recete_id_fkey FOREIGN KEY (recete_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 r   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_recete_id_fkey;
       public       	   ths_admin    false    241    251    3848            �           2606    31888 H   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 r   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    273    241    3888            �           2606    31893 F   urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_paket_iscilikler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 p   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_paket_iscilik_detaylari_header_id_fkey;
       public       	   ths_admin    false    3842    245    247            �           2606    31898 I   urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_iscilik_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_iscilik_kodu_fkey FOREIGN KEY (iscilik_kodu) REFERENCES public.urt_iscilikler(gider_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 s   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_paket_iscilik_detaylari_iscilik_kodu_fkey;
       public       	   ths_admin    false    3824    239    245                        2606    31903 <   urt_recete_hammaddeler urt_recete_hammaddeler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_header_id_fkey;
       public       	   ths_admin    false    3848    251    249                       2606    31908 <   urt_recete_hammaddeler urt_recete_hammaddeler_recete_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_recete_id_fkey FOREIGN KEY (recete_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_recete_id_fkey;
       public       	   ths_admin    false    249    251    3848                       2606    31913 <   urt_recete_hammaddeler urt_recete_hammaddeler_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_stok_kodu_fkey;
       public       	   ths_admin    false    249    3888    273                       2606    31918 :   urt_recete_iscilikler urt_recete_iscilikler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 d   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_header_id_fkey;
       public       	   ths_admin    false    253    3848    251                       2606    31923 8   urt_recete_iscilikler urt_recete_iscilikler_iscilik_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_iscilik_fkey FOREIGN KEY (iscilik_kodu) REFERENCES public.urt_iscilikler(gider_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 b   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_iscilik_fkey;
       public       	   ths_admin    false    3824    239    253                       2606    31928 H   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 r   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_header_id_fkey;
       public       	   ths_admin    false    3848    251    255                       2606    31933 G   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_paket_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_paket_id_fkey FOREIGN KEY (paket_id) REFERENCES public.urt_paket_hammaddeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 q   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_paket_id_fkey;
       public       	   ths_admin    false    255    243    3834                       2606    31938 F   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 p   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_header_id_fkey;
       public       	   ths_admin    false    251    3848    257            	           2606    31943 E   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_paket_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_paket_id_fkey FOREIGN KEY (paket_id) REFERENCES public.urt_paket_iscilikler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 o   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_paket_id_fkey;
       public       	   ths_admin    false    3842    247    257            H           2606    31948 <   urt_recete_yan_urunler urt_recete_yan_urunler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_header_id_fkey;
       public       	   ths_admin    false    251    372    3848            I           2606    31953 <   urt_recete_yan_urunler urt_recete_yan_urunler_urun_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_urun_kodu_fkey FOREIGN KEY (urun_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_urun_kodu_fkey;
       public       	   ths_admin    false    273    372    3888                       2606    31958 *   urt_receteler urt_receteler_urun_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_urun_kodu_fkey FOREIGN KEY (urun_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.urt_receteler DROP CONSTRAINT urt_receteler_urun_kodu_fkey;
       public       	   ths_admin    false    3888    251    273                  x������ � �            x������ � �         (  x����j�0���>^4}�>��L!NRH���Q-��n��Fo�א�H�k�i��v���,r�<�^�ڲǟ������_��"<�%;�<��<�?~�����y`;&�ı�c�F`2ԙ"N@ ��Y�^�-���^�����g����q9?G����2_�O��S��9@�菘A5������qpN;����r�Iس��E���(�
KonW��`)J���M��δi��)���6T�H �̆ĵ!+�P��r�~�5�F�a.�ȵ3��IY��6_��HS����0���+�6T��B/���g�0�Ua��4
Z�$�I9�e%Җ<�)!'����be��|�r@���dI��JZ�ea�]ٿ�H���VZ�A��5��y-��aH��"Տ�J�,�EX�V��`�#j#M�Bj��{�7Uy���R(.���x�e��j��o%j��L�E��{Q���"�(#�Aha�U,�SR���n�7���:�;��(5'#D�$]'꒸�ۋK�\�uo�]�r	N� ��ZV_�G_�7�^�B�'I���'      	   D   x�3�4�461��v��srv�0�2�Yrz��x��id�e
242�p�s9����Ԍ+F��� ���         0   x�3�:�!��1�3*($�ɑː��1��/��N� �� G�=... �^         ^   x�3�tuw�2��vrtq�;�!�˄���4�t�?2/T������'�˂�Ȇ��p�9���9~����9}��ȑ�Є324(����<O�=... F) �         �  x�]�K�%7@����J��a%�4�g��:�m�z�-�W�c̥1�}C�w>�<����/֐?:t�����@^�#�����E
�2�*6��#�J-��W��oBi�	GE]x����2���*���̯��WC2�	�3y�λ/���̯�!�z�1�����0�����6��)��P'I
~zCUhPQb��ʼ�^�e~e,�ײ��BD��5jȣ��DW�%���FdM�%�آ>JB��!{��8k9U��(��������9��ҐGD��(��b)|���p6ԄVQ������А=&v��+
�\�{	�"ZB�rCKH�P*Z9�DG8>��M�&c)ԆB8�R8+
!��!Gx�A��12��
!�"T��,�e�l ���GV6���8#K!W���9��A��������H�ZQ�<�f1���M��c�Gh1>�2S���ѩ��2H��T-Ny�����p@���D��e)��9�LRQR8
���P/ڵ�+�G8+
!!䡐5��gِ_�k�?��P�Ρ��Gxf?�ұ��/撨] .��`�h�^"��b��z'x����dk kE!��^����)��B�¦zEK��h(����Pn��P��.䆚�)�w�b1ž�|���-f���t᠊�ppCMx�k�?1�H
GE!���PZ���-�Ρ�[��*
��r������3�I4�}+�۸e�=3ۋ�p[xf��q��k~f��v�+����l/
a�ly���A3ڲd#:��F롇'ƧW8�x�޾qƹ�g��*�8w�m��[�����y�
�Z�|�qn%�Z�/��V��
�!��K�|��{$����<�����&�pV$��=��6�p�1�H�7$Q �TB!�C1� �.4j�	��.���d�m4[��6�(�
�[���saM߻l�Ј�ǯ�+ZB���o6΅u�,ǆ�����N��ܳ}yɆ!�)�4
��Q���%�~9�3�φ"�&��*Z[V�z�ƹ��
@C!t<�A +Z�"p�qzTrCM(uafcMD�'���Bm(����Y���	���FLD���%�ސF�9~BE���Lz�x��B����+�B�h�B������&�)Ԋd͢پ��/)ʟ��֐> ���^Q�]�3:�o{�5��F�����jb΢rF�\?�!�|�&���pTԅZ�������A�%|�2ͥ��u&3����E��gA1TK�gc-������?d�:�         ]   x�3��quq:���p��>�A\f��G6x9:;�p� �G灥�J@�憜N�~ގ>�@��o��c���+��9���9G煸Ả���� �( �           x����n�J���Sp9d�]\*�kdف�p0�N�sBH�J ��y����M��fV�I~���yIQ���&�_�꿪��n�6,�7.�4�D�y}����7�ed^D�8Q�J��,0��}���G��fw�>�q6�2�1�/>�&q��>ޯ~MV�V��������X�|���)�(������J��14��9�_2x����g����MM��X���E���|R_�e�)i�F�Q�Ds���(��o��m�e���R��g�X'܁iełn� Z&cs���#���E�H��ٳ�+�B�PMo'�&�}��F�	�z��ǁr�`�+9����1�y����ˇ�d����V_mx��2�F�g��xov��d6/���q�-��y��~%��g�x��\��,�T��b	�Ah\�G�I�u����΁�&�D���]h`7��o��(����c	(&��'5ߎK�5<0�/i$�3��"Oa5��Dr�Ke�|vC��1���ӹ�~�B���� 䄁1RY�ޙ�h�S��f<SI	�������&x|��|gB°�n ZC鸆M8�<��P6��3�h���7F����dC�@ݩ�I�j��=GԞd�&�}?QSe���Ա�ir�����ܓ��{`ؐ�Ք�z�Z�.N�d���:@��'�W�\b�yr���K�K��X�0JƷi�k1կA�����T���u�����>�Xh:U�ԧOˇ�:K(�6�U�%��Z����(�6\�EUF	$ܶ��]N`�m3���%)ܲ(H�4oS�(���;Q���D����Xv]7e�f3�҇tF��Q����l���~%y��?ؐ����XZS4�g/qg'�L�:���rA�3)��_�6�	�=d�ȟ�_������ ��W���Tw��M:�gS]`�����®�g]��se�M��J�B�N�T�Y�y�>���;.��K���;�mMAܦ��[�`�˯�:Y�iT6,!��i�<�'��`*�OI��M4�����;Z̺����A��3�`m-T0��;�
��o� �D\�iܭ�mxr��X��m�b`2(]��t�^���7����t�.�U�8���# 슈(�JCF !�2�ӡ՜�Z�-��M	с��i�c�i/m���:�FO7��_0!N�m!C	�[wD�x�Ғ�5L�iD$D�z�i�%8B-��eJ�>]Dv�	jeg�!Μ�L�X�DZ�g
t;���(�!L������M����lll���#�uq�"��	������	��ݭ0p-���J�gɜ5��YwBQ8��.�R�>}�'%\��enմ���J�eA�M�B��W���*6KG'��A����]��?�#�"��A��T������E��bcd�PE$$���D�|�D���_�O���#D/�tG]�@�3���)y����� Z�W��A�0E�c~�;��J�y�c_��=�7���h�:쯾�9��=�O��X8���Q��N{�TN����t�;�;1����h��b͡�l�oH�o����������	�e�+������j��,��a�_	�űө�aU$�j8��Ol�/�(=���ᗓ��e����TSz
˰����|tv�A-N��Q�p���H�>H��	��d]��e&��ef��t�|�U�o.��]�b8h*��{�)e/��bKq�u�`�1���g��<�g��<��g��D�g�����g������ѹ�,3�K��L	����r]�hט��lA�|�|����7��d����Ii�����!���Y����b�,3��?�ߟo�+t��a�����Ȯ�r%��h'�4@U���9X�'�G��k�耺}E��bO.�nm�Dxߦ�����
�}t�ȴ�k&�Pw���b]5i(!G���d��۠�Z���e.�[�E�s�\��4E����4��ű�A�G3����+5���Ӕ��w�1��qt'�=~���y-mJf���K�\���q� �Y_��;��������ER^�r6w[����}���h��%0�ح	�L�e�1� ��E�<A�����֓�cw�س(�.mq$)Z^Z�Z�]R:�=4 u��KR�ܝ��S��U�P��]�Ƣι{)������xw��9�e���v�_B�S0k/$��+>!٭W|��gM�λO*4�mw둻Rj(���RC	v�(�l2Fy�,��k�p�չa~��\����B�ڊI� �^X��(,��~��$o��H{����|�c[ǳYTɑb��M�i��� �U�^��\��h��|ڸ0��$�ַ�6
�\�ͥ���C�����YeY���(�[�����7�WȒq�Ǝmx$rޕ�=�0`���+Ǻ�Ӂ�8�{�,fU�����p՘��a~���?�$a3S^����@v����L+WQV^�R���Q�!d��^hUǴyiK��e�n��5|+��L������`��jjZi>����(��/
�Ԧ�c���y:�5��1r��������@��%�\,F�s*ـZ���u}ZX�XX�[u'�_p$�MI�����0#� ��w%��-(��l|P��EsI�����W�槥-F����J���5��Ƴ�M�$H�;rvK��/���Z	�J��[�&�|��C��i��V���MwI=���K��(����0���L����o�l*�X��H���4bcA�'�)�5oB �ۺ��޶-(��l�ú��B�0��YjcJv��mҡ�&t�M�@,d��VQ�MWؙ>����v��L =.��柨��ɢH�����V2�-�6Ѣ�.�RA���B��Y]�"��tj;�v�;��Wn1�y� Z�q��J���T�l%o�����Wmo}���~ؾ=�(�(�E��~R��$�.j*YŻ�6�b��K�U�Pe�4���oe.˟�T�UCCk�a��݆G�B��3���`����9ݰb�]Y����G,W+�d�>��]��e�U�n�[~��F���ޤ���-Ҩ�%��A����z�B�X�[�%�eoݴy�|�/4=!Ď��F��M'-�`�p��@}V���"®�u-V
�B�h�t�m��Us��~��x`�W+�������p�Y{��xH���w�ɢ�������!�'h�-�����������j<!k+d�cdGЮ��U�/��e�IS��}���c����NXm�&>k?Kl+�I����t�(
�eE`iY�hz�n�6N:��
�}GY��_Gjq��.�'���|"�h}H���'F�t�}i��^�%�*/N�g��7h}���5� ɇ�^�%�B@��BYx�5�@�	���k��ǡ�{Q~�א/�˯�{'�7�͋��e�$��'_�^������)�W�v����y��g��녅Η����]6g?��e묖!ߏ�����ɰ;�?~7�V?O���.N�~��a�<�~�7��Nx�ߚK����Fݷ���dn<�૳��̮�d��Cr��Ὼ'�ѱx�T>���6��%��>$�q�:C�Z����?_�x�?���            x��][n�J�fV�� 3`?�M~�-&�P��2 c��
f�����5H�ל"����'�Z	np�������M�v�C���Mg�����C��բnC?]������G��,K��>��S��}2�w�U���m��4��mh�p=���y��>o���y�`�=>/?�N�н>�~�w?v���]H���H��������;�W�j <@8G.�In��M�]���y	#��А'�U�Z��<F�sV���u~��z}������ܔF���F�tU�U���Ӯ�VͲ��bJg8�S���F��OY4�`�2?Ù����oޤ�0�U����ZT2��jܗ�d:��",�s̽���@x�N��8JQ`��$�b$�T)g���i�/�T7��F���"! ,��l�D��̷O;����9gI\�d8�;������Ѧ����9��|�eKZ����7#��H�9���_&}x��,�A��gB�����Y�W�U��� @���k=�:1�/ؾ�I
E�5�p�fM���!ʙ6\:Ufɬz�*Z>�كZ�vDR*�e;�iRi�����PJ��p9,�����2\���JM^��!tR���#�9 �O�U�-Qƪ���i�lV���#Q���,ν���{~��
��1'�QU�{ΐc�xɑ����� vH�~�W2X9T���B�N��:��%ޣ�&Mx-.������v�i��k!���t�nON(�	U��*!�fC~8��W���m�h��ƈ=��X��؁�fo��p��[���5h�yk6�����f#o�f���ۂE����ׂa{M\Tm�)�~lð�@[n)� A��E��X$
##�Ҿ�!4�r!�����v���������]�,G9�vz*�A��!��t]yr�U4�¦9B�,q9�y���=F̉��'���$l�?%%�ٺ�n?�0� _[~�m48��A��z��cM�_���J� �z����zV�:T�e���
P�Ǫ�	�tdV����ѕ�,G��J��jU�>c�����÷�]x���HԁDa�����s�s��v5C��� P�#@��цf�X&�s��@x0�����EM��H�^-�ą����_�m��J6}H�st|`I�e��:�^�ۉ�O�/f�O0�;A��q���J�JW_�L텾����`�u����>������X���("@��/��@�p��9J�ɇ�� GQk�~��'�!D��<����Ա�!m`Cq(�qf��`и��ح�/ˆg������Ä́��s�AS�i,�Pm�����Ys����:�!��Z\�<�l�6�l{)n���yV��w>�±E��vR�;T'��p�-����e8͖�
0[���y�(�2͖�
К|�L���4V���Eo��znWH�	���V�dL^n���i���ވN��C-�U� ���Z}}�!�w�Gť��:�x_���>����3��8C��^�+�>	�V�
p`YF_���^�%&�kۄ��Y-����2�
*9�pQBo^-�%��Yv�oRz@��,:���"�f+o�-�z�IEjV�̠�$��5YČ�����"ن{Z��Ь�:@��G���(|b2��=��� }��� 	Gb`���	��´ˉT�e!	8+܉c�v<D�T #�GC��W(��ua���5rFX�ަ.��e�21Z%��v�nP��h�Q�:g��
4f�6c�!jiް�y��1h�*��9a	���B���p�j[�]	XFe��?��z_�fw�\�ʒ�z���U���Cth9�8&ڨ%����C�h)����`�rJ����bt�,y�K(͜�,	 ��	�n_I%�R�p�!�>u�ô�ϰ��lȣ�PP)�svԈ�:/ <���4�3�c������f�)�츛&�r�cQp�lvX�W5�Z~��aw�	[��i'�d�Ͱuc"Z��h�"����w�AtC�Qo��GΏ㏸h�N�&���I:��H�2�&��o"!K{������\�4I��&�,�I:��H�Y$��o"!��A��DB�5א�e��Q�<FBذ�u:wl�:�^-W�0O�n��v^7iS��LM��we�(�"��۪N�V�o����&��1�6O�ϧ������̜B�[�%�׸�d#�.�p��ϒ��"m����[�%Pr��\'�v�J�aO �Ao��[)[��K�KC)�f���`e�:iv?f��CzC��4!$��í7�$S��X�#��û7�|��?L5�Xz�k7(�����T�:[4��ꆪ�C��Ɔ�ӉtS��Z��y�B�lk��Bc�kĆ�+�D�����z$�z}^�T�2@�������y���*8�lTY����1B߄���\�i�24�-A*k�i�����r�"��S�֡��V!-[�T֣%?�q��?)ƳlyM�-���5�D)�r���y���6�V����3pT/z�ײ�����g��^n�r����z9��:=���۸��W?��x���۸��W?u��T ,_�Abѓ�O�#�WL�[>���n�b��NF�L`/<@,�;�����8P`�:����w���1��]7��|�����%K���1�1b�i�Ӂ�����2�հؙ�fe��tYNg�*�A?�:l��f�ڃ-���t7`� ���WI�O��"H9��F�lJ/�a�'T��!�0o�\�m�9x��]��Ds���-�D����n����]�{�>G]�w�!=�Tm=��wD-�,pO��T�!z����\I�8=Z�!%z
K���6[+�Zİ?>��f��8)���Lr8S�~B��}�Q�Uɪt�[���et�]nu�p���Ĺp_�K)Az�K���;�z�8ϖ�	K�2_�;{�͓�3���r�ɍ/� ����щ�s�y�� ����֗��$��^��
�U�N1��
��O�C����Ϋ�3��é)K��"PY�<�J����7��{tJ������Y�~٠�0�'�r��P����C������ͻIe�u�s�o!��wh�G!����K���sp��i#���l\$�d?uG��$�ׇ-*��D�co�T��>詺AN34~s�Z�1uC���Q��+b�8�����E�ɝ9� )#�iP�;�:����ф��4	�����B����I��^m��8(g�:)Z�v�Z�M�n�x����MtB�����e]<��|�3��u�߽�7KqL.��3Р��>��FQ3��w�����2��wc�{0�t�ٻ����]eS�4v��w�AH�2u�E.?54q�e7k�E.�;{���22�/Z�|,��-�Z�����e�M���3k�{��.gnUG��@r���I{��^9)x�����6��OI��P��v�V�@����+�a Lq�r��m�L��/ΘP���͢t���gj1#Z����'.��"K�ߨ���<�!P��~�����?z����S~�@���	�f�?I ��|��&�D2��#DZ*�}�b�Ŀ������}�.�H����"����� Jn]u��Q�*ߕ��)�ή�&K<>�Wa뻰�nh!����I9<[����=BnF���2$+_�����ͺ��o5���xӪI�}|?��I;OX']׉G0���!���d�'�N����w<B��4+l�V���@_�M���B��Lbr���eY�M:Ya� �8���>Ce阗�͋��ӳ^���c�	�J֦@�f��>�vըr��g3����׆b�}�*qX�� u�M�S�}�8�AfS����7�r,u����z���r�}���g��&[P�1e�K;���na�g<H��8M����6c���6���4��2�^��O�.!��V>�nA���K��L���1�����4��\AJF�^	zG���Ĉ5S�u�܂���L�x؛#��ﲟ�����'� �w�~k���R
v�OHw099��)��b�S��5�zu:��l��z�і��'T\dә�Eh K  ���£���Bq����ϯ���B�r�[D�N �ŗo���Ba	��(�����>�x�Gg� <�K�,�ź��͏=h�D�B�HG�Vc*�6�a����h�ݿOoK��&Ǎ����{�Ro���e�i��iW���@�]<�������.9^Z=^|����l]Ё�J�������t`f?���O�:_Y&�\oad���ř.u�7��M7C�'H�+����di�2��H��F)�I����`)���?�[�K��A����$������e�$�O�/�����c�ȓ�n��v/�*�c@&�X�:Y8��D#���bI}�n*Iw/��l]hƁ�,e(�,��r
N��'�BP�
�>>�/���{����_'Z \�u���Y��RU0� �ۚ�\>g멊��Ų�ÿ�%Fa�� �����R�ҳo���	X�Q��j�yb�G��:rCm.��zlt6���\&*�C��y:�#�T�z�gD��z5���,H�JW��W1 ����0��2>�Pc2�;���T�&��d"4����a��^�^E�GDF��H�5d�p1��1"��h�zDV��U<h��i���
Z�SҒC�Xt;��K��G�Gt������~b�S��Q�3#}��Zw�k�Q����^��G���u�=��W4�����Ř�G1J3�)�����yɴ�)�Yj�t|#�(�>�p���t�:����3%`:�b$]qQ��ϟх�R���K4�Ţ�䝠�%hzo��GV(�Z�r#��^���*��M�Zzd ��7\�����$��t�y�`,�h4=1������]����]GП�{5��"����>}�-��            x������ � �            x������ � �            x������ � �            x�3�4�44�2�4Q1z\\\ 'k            x�3�4B#NNC�=... �;         0  x�u��n�0��Oq�MKM�p�̰�:�tK����f/ �S��f6M��m���q��Vo�Z0˲�s���Bt�6�R� �:v�q�0���+`ti�7k��HXT,��i���z[�i��I�7��1�M�|Y튤��[���������czZ��4�g������m.';�n_n�pH�n� �t�
[�C�LSG�6���y�4��眆����G��4��?*�*+6Y��Yy�h
 �W���G(&�!\�����88紜MO���4�������4x�T      3      x������ � �      5      x������ � �      7      x������ � �      9      x������ � �      ;      x������ � �      =      x������ � �      C   �   x�]�Mn� F���`43��XIS+ƍ�y�u��C�`�?ip� =>F��H=ƽ�nȄI��稧�gM�u���ｉU<����+g��Ua��WD@��Q!d!`eůmxcj��pM�7U���s�y���x��p�"�P�Uf=`���!dV|Z؃��8�^���9~�^�]ΗN˥�ө��у���
;��TeD"��j��V|:=�i�_ ~V�      E   �   x�mPK�@]�Sp&m��rG! 1.0�=�g�x/!~_?y��i	�ݦ7 D�`��~�d����}��8��D����$��ڂ�F]A
��@�Š�?��<�)t�yjRC)�6�!p����е!�G_A��~����/��q�w(�u��aC3O�<�Ch�O�d�3R���U�oX�Y��Ȳ�	K�AB      G   D   x�3�4�tt9��������q�9������u�ʅp�pq���d��p�y�~�~@�=... ���      I       x�3�<:���3�ˈ3�5��1ҕ+F��� Tk�      M      x�3����2�tr�2�t�s����� 4�      O   O   x�e�A�0��ت����0���ӄ�p�P/o���s�۷s{���y�;e�dV�;����<����},�w!� �b"c      Q   I   x��I
�0���c�xo4�&Q!���C�Z�5�׈�<^Y���s��'��^�0�R�yˋ�v >*��      S   ;  x���1n�0���k�{N��.�0P�JR&���|��{50�}~z��2D�����?��v8����~��w)�w�����Mq�b��`R�S|s����/������|W\
����ݱ��]�����mZ]��КRm��,�V�n�Rm���Z�#n�����6��G�'�����`�)�����b�2�����0V�/I/�p)�*��#����.�8�4=:�X��ք��9�+fiyZV���2����ieX1K��ʸb���V����b��5q���2�XZ�V�[iyZVl��ieX�����qŧ���� 63��      U   7   x�3���p�v2��@<o�#@<c0���5X!�����$hDpc���� K�$      W   +   x�3��s��9�!�U����ٓ�!�~x���k��W� #6�      Y   �  x�}��n�0�竧�� A+�i��F�Z���)�c��������cWk�f��z�Đ;��<��^��8~V(��2Ef�|c����8yQ&�+.ƓJ������q�J�g<�KYT��'t�a##���������p����Φ�Ŕl̛ }��		�HH��98A���G�r]�K}�t-u�Fb^�"C��S1�-1s.K��q\�#�.>��K.�#W	���lč�
]���LH�~����\7���5S��)���X�\�C���*�M�q����"���6�@��s/��I���� �����:��g���V�����ǧm��Ul�t���0��ɠ4��g#����r���,�U��Ff�O߈���BUiY���o+[��7Zpq+�\�S�!G��r�C�Wj��~���j�þ ��4��J�͙2�/1aלP/o��ӥ$���z9�'˾�[��>�<\Z��4ܹ���x��u��eY� y&UP      [   U   x�31�<���1���#���q�44�21�t������44�21�t��s��L9�\C�����<3�G��#|C8�L�b���� Ax�      ]   M   x�34�<���1���#���q�24�t:���.��ed��������ed���yt�B�c�c����#W� =SI      _      x�3�t�2�t�2�t2�2�t����� $ �      a   0   x�3��=<�����Ȇ`.#NWW_G?.c��(m�yt��W� �|      e   *   x�3��
q�2�<�!��.�����
�!�cW� �      c   1   x�3�<������#��]��9}|���L8݂��=���=... 7'      g   *   x�3�<<��5��_.#N ����e��txN�?W� ��
�      i      x������ � �      l   3   x�3�tr��9�!�?�3Əˈ���1������5�<�! ��Ď���� >$a      ?   F   x�3�tr��9�!�?�r�t�S>�!�1�Ȇ��|\���8=�<� $��1���!!G6�h�1z\\\ �$_      n   (   x�3�tq��,�L�L�2�tst
:����
��qqq �>!      p   #   x�3�tv	�wq�
q��#q��qqq -��      @   4   x�3�qQp
��445�500D��9}]#�\}\�8q+����� �ob      q      x������ � �      t      x�3����q��qqq K��      u      x������ � �      A   e  x���Kn�0�דS�	,?�ց�����M�Ģ]T���J]v����
4�O:�X3����'[�Fv)$��zi
����쐅;��L�t�"ڻ�].�����̰0�KP��Y6�^H��}@R.@���W�~���.��+��Τ&�(Wҷ��ɜ�=�/�<�;8������3�y���VJ����Z[�l�r�aef�"�F�'1�I�C����2�D]{a��
�mmʎM���p<���N��pO��z�X%�Y�� ,�����L�0nꦎ�{�����7����M�	B"S��,S������<��*t�'����.5R�N~��n�I!�o+�m����}/�fA��9�;      x      x��[��������K���I��Ő�z�m�d	��oN�3ӷ4��G����������D.��n�Y%D��P��)+}��>���              �UG? @�Le萵 L#��+��Z��|    �2���3��    ƈ��?S�G?K �QdB���)������w�}���� ��R~�Z��ZxD8  �`��(�ޟ}�� �9SkY<�ܫ���zƫ ��R�o��Y�{E2Ń��D���M �� }��ܧQ:�I5��K�  ��
�l� ��f�2J����*�8�ii����|H�j b*��R�e<͑�"��1�VM���3�m�~��*��i�����I�p6��, �5H�zl71T��Z!�B��e��Y�\ �J�B��s���eDP��o�Z�0����|��7y�>��P����y�4�*%J}ޖl	��"kt����YJ6��WR,� �!�ٸ`�}�ǋK�>OVwe�A���H�H������V=S���	� �w�[}��9�i��o�k��Б
�����0�
�Y��]Qۦ`6��V(̸ `7H%x��jbK�_+���( �5:�H+��=Rv#���5��$�#j�؈騠���= gЊ�hD]�?��2� �S+���Zѽ���� �P�~R���>����.�����@+fw����  ތk�w�
��u� �׊M<�j�hZ�\�Ctβ+X^�0����  �ak������®� l�9�9����  
�'��VXD�V  �e'�XVM�Ȁ �-�
�VXy��<��������j[;�[��auYM���Ǽ ���u�H�+��:�V4��
%kL�%�ִ,�:>�6��h���y�Do�X�yPG]��kE0�;>�j�~� {"�9W'�;=��2$��&jE�E@��֬�,����>Zq^Z1G���<����?"�W�ں�eIXn�8X7Vi �����Mb6F��V� �Պ��3�`O��r������ui��>�y[V��m�Q�%xf�u��&���H ~����������E�+���L� [bvvߚ������m͜V�������s{�B{
�c�H��H�[��X���y�ZA�A��{J�[������%���U���_��k�"���B�ğ8����U��~������+ٌ��q�#i��U��g�}Ə�s	�T���H��L�Н~G�}�c3����խ�u��A9�e��T��e�V�@���R||��Y�*���o@%���\�(�����I����:�a��"�ʊ��VlQѝ������B��uh>9%%��?'T}���M���1�]���4��a����V���Pk�/���_�V�d����ΗjE
��mφL�$�k�J�+�D��]b�3 S�P+��� ��V�b9�3˴"���ZA�V+|����ՕyF�H^E�i����cQ�?�JƢ�{�Q�]��W��Tb��~w���Q[կ�R��q-
 ܼ5A�rZ+����ۚ�Oj�t~p��K�k�E}�S����ÒG�d�U�!nlh����!��R��y��i�[����`��6W���{f��sK� �RO��V�ϧW�i�ꎏ��Iˮ��(�7J�v6{�cF,}�oT��otG��T��7ӊ��l�Ѿ�7��ɻ�i�����������{��	�N�[�:�{uyT��w�6���g����="P���}�#�q�� -}�M�v�݄Jxk�w���Z���Э�C�W�9����$�9��`OU��{E6�Q�0%���_+?*�O�Ubr�@��F�����kk�8�����YWF!��*)�`ה���s��P�$��?��(n���vE
��[���s}�g=����í[m���
���a�^+�J�k�j��C�*��=X��+#��]=j]�h) M�*�V�x�V��ەI���������.�x3���W�ǕR�j�\/�W�kN%0�\�in��I��"����N��.�qU����J2����cQt���`Xw(�ֲ0���Jy�H�����Zs����x�;iE�M�?m�W͸Q�m��u��������|�����v��5�& 8P�T��P�aM���9~r��_+�葜����g��e<�F�C+ē[��XY����
�䣾���� �(2����P';�F�y�kURȭ��{���Vl=9��[F6�g�x����
Cd��,u/�ɣ���g���S5]��^%��j�Bn�[Ƶ�J����ڿ�f�ݞ�4Ž7�m�Z	!=��~�����J�hEh�mQ�O��A�cP�l���b�>��繉�e����K[D��V���Ά��˺�-��'r}�����%����<&|�q|Q�h*]!�^F<�s����ߧ����<�����A���Q��;��ч�(6w�q���l�!3/�RކY�}7�k���E��<���$<��������[+&cr��6P+��S�zg�B��{��Jl�$�O�����Om�K����c��V�$R�}̓oV;�U���l�X�WsYQq���>���4�{�d3����~s��u�Pk�ʲ�V�Ϥ{65�� �a]�^�h�b�� ;�_0}�ъ3��6�)|�d>,�\�}fSd��dW�ħ�<nǞ��y�q�aO�Wb�5�,������������E��W����'�Q�����F�b��=c?�Ʒ�b�V���G��xm%�O�����R�9�0?��LUJ�|զD �����x�7|��Ϣ��b����J��Yc=w3d(V���mا/45��;�^�:����7.�>gn�!<"�fj��c�?����W	��$;�h�2*�nϴ^��/��]oLb���yx�@z���9u�<f�}�0��C+�R�7��8:�h>(2�nT�>�}�*�gv��m[ŧ
�s�V0�����Xkk���+Ky{$H���x#n���{�|���x��ZA��9� ��"�C7���B0�Y�����������*�W0�+7��&f�.������
���֊P�2�[DSy<����V��׺����3��Q�=�4ё{�~�/W����.���q;x])��7�ށ�q�zv�S�Ќ�z!��'�@��D�V�f��#M���EZw��>_�V��R<0�|�[Y2�������{ÿ1�ű�V�GٜaV:����T�kl��IG�c#v���~|b�­��yZ�M�{E��+���4�o�>���NZ���u�7�dpj��(�X����Mw	�L��ƎԊQ����wR����V��EiҎ]�rz�2:L�~c��Z��=�9��/�>Ҋg�7��0b�>�m��W��>j����3w^p}�_���Ԋ1��=9jg��Z�?�r}����oM1����zf�Af�A��K��O�;^qw�y��\
����e[��,s��
�Uc���Y��6[�m9���|j"�pT���s\�[�!廍���귝~l���z`�%Ƴz�I����j�}���b�Q��s���G��ں7�(�1�T���EA�Vp����N:*>�gĭ�C�M�"�T�s�0�mUh��e���˴���W̩�;.ZGQm�/�����������x.>= ��:C�x]��?�j��
u۩��ޭ���>��v��
�5��o���>Z��(�s9Z+B�j��?s�%���+x�JXv�M�W�i�}� Mx.#�L�9�ܶ���
%������y��g�Q\�cP~^�`
�����? �t>j���Z��g�fO������9����r��ȴ�'��{Ώ��O4�և�R�󳟚�>�z^��xl5�Т�v�B��t�H�玙��b��'Dk�u=�m]���#bᵡiX�4{[+�3��(���c�bA��w�nB�$��ε������B/U7�HZ�u�j����+�|*���s�
�q���h����t!H�L�6f:�|��o�	�>�?;��h+K��T��������«��*on������>���b���r�7)�UT>>�
^m�+�ҫ��k�]�x,��    #�3�Ϋ���"�}]E����çH������������9;#�Qd�E�d�"��6z��%|�ǲO�_��R��|�}RH�-������ի'J�\��֣|J��֊s���u�eA�AnK��
?�'��J8���E
!w��mS����K�z����� �bu�E!3r	Ȏ�=��kEO:S��RPI�Q~2�<Y�{y��7�H�z� ׀��B�W���,���+��
VZC�mn�j�x������;^3��+X��?��]�,ȱ�l����E��]n���egz�>�
���rnWl���(?����]!λ[k�^r�o�P�3û�(v�}>��=�"��>��J-��O[���pT�"��>��aZa���2����ϴ�N+�k���l�IH5��x,�W<{f��,�	���}����@+����},�C�?�vZ�逝���S�0�;�[�MxM��w�mC��2���^ſ��A5��(��$�8����^Tq���B�%�+ �j�o/�2�"n~���n��*����q��<�𽪓Wۤ���p��V��b�I������a���m�������ϙb�S��|
�\��)�7���; C�7��ە�=��<��Bk�|�(�Fvñ��C)L��[+��=�ּ��5{��Z����(�+���1�z���S��+8��w�OuQ5��7�ݾ775����5Q}4�n˜�@�Y����QM�g��&�.�[�I-����� Ԟ�������|:�����Ϯ�d>�ͬ�v,��#�J��VZ{R#t�����P����ǧ��c?�O}Iq���+�Z|�W����V()���Z(���ͅ�1N�YPq��Y�%�&
�Xv,�_%�{�2�|�<,�¨� ���'����s����&
�(���ey��K�bW�ʓv����� ���Z�q^gQv�,�"�>�V=���+����xX�{�����΅�����`gL��)6ʎ
��4�2^��"��"�L����Z����x;�2�Q�6�0W���پ�=��O�YO�J��>�}��D��̎] [
�@s �z��9b
����x�u��jů�Tխ�*����{���@��������U"�(�6����+�GҊ�Ř�������>E�FdE@�T�,l���]x^�r�s��XN[v�z�쵗�����f.�@]�m����Uw �k8�%L=Mb��G6ӊ��cŵ( �^�&f�{���{�gBU�d��,:aWXmoW��V������*s�y�-�]�qh��rkpy1�Gt�ף�s�++��d9鉝q�C��8�q�w�V�}��[+�� B��Sa������V�X�VĴ(.�Q_W�	Cv�8�/b�u`[�[�Ĵw��q|�i�}��!D����i�ځ���|�gQZ6�&1̯�r����d�0�Z�0�7��_��w�>��{�{jq�}����/�OZ��UX�'�5�4�'b�h��?�Z�$R1E��) D��"�WlΩ�V��;�����zWl�l ְ�V�֔}�ۗ.sZ�'f��@$�/�g�V���������pqLm�&S[y�tn���],�gn3�����=JReP��i@���yU��M���mcW��R��
���l�g4���Vl��R��s�8��خ�KC+�O*Z�!J�/���V��D8���&�_����ǽT��{H
�g����bO[B�8��6��E`W b���֊]�Ӊ��<���M"�z"j�6b���X��&w_�Q�Λ�)>�5!*�գ����fZ�bJM�q��ZA�v>��#oYr��I�v����{����������.xд��]1z������X�pmrO!h�h6�R����;��d�$��76��i�\m��vE�17�2�J韱w����ɟ�'�ͭqx���}��/�u�FE^�{a�}.�J�㧼��PMܶJ+"}���
�e����Ͼt��k���YԴf��}�#ؔ�8f!�-������#��I/|��Q�e��wMI!h��r[#V^���w�2#r��xpf�&�.�όz�����yx�|����uҩ�Z��_0��ޜ(ȍ���\?���:��&��!����ȴO�+�+JF�d�?u`����>�<��
o�b�'�5�<Lt�|�ւ��9�]F��F�,&�b�:!�� �<�]agT�r����u4�Ϝ�v��{kƷ̡�*� �B<�h����X~�D�"	�����BeK�f�_Xg�@1���������'��z��y*��dD��9[10;��S[�'���P�8BLr3ڜuHQVq�����Y��o��3�P�d�����"G�t��u �EҊ}��"G��T��>k!�]���K��\r=�q�����=/�Z���Ls��� -�Lv��F18�~n\%��V�3G^7�����\��������[P��Ⱦo�hcl\3���������]�2N�|~i�=�v{� ����{,[�5Sb�5ְ�>�cO�͢</���r���K��fQ�����Y��߃x�Zl����f���>읩0�O�
bp���F<�J!�8��x]�P+�� �W]�����wL��#q;2��Uc�Ǳ2μ'��U@�y��9.���v-�lU�e�}ܓ�_���ω<���9���Qf�EѤգ�2w�i/�u�g$�|b��;P�܌#�*���牋��;Fqv���?�'B��"e�N������{���m.�zb>��� ��{u�w��6 �3��>#ʪ�U�׉Z�Z3�".RNd����:~:��H��R���|�I��\���T=�����Zŭ�J
c�1�_#��d��{�ϡ��qq�7��A��]0�խH��sZ�K��@T4J��g�6��k~��sP���5�'���ˤւL�lde!^���q&�m�\�����Zq5�ʐ�|fNqkڝQ}�i!E+x���'�R]��&?Yܶ\�|�"�sZ�#��sU�J��D;���M�U�4e�W�&�H9�l|;G6�f�GeOLyŇ)�P�+mv+�+����=���# �6���nM~�e��Q?�]�0�c=���6� ���0LLR�ey̡�l����-:X�V�9/����k���r�5�b��]�B:`�,쟡�[X�w�S=��]w�}�=������VUHy�^�f�Z�)���9�(�6��?O��hŅ�̿�̓a|�Y��%&b�����ec����k�'���p��w�.�w��ϯ�U�E5��]3��wN��|�!�[(�N�dK(v�w��q��t�Ŧ�ģ���i�_���#��`�~�:?�� �?��:�����~�r�7����f���(K1�`��ڝ��Ɲ�g䣹��>�-�M;ڇ�{�������D}�	� �p�*AP����W�^��rE|���ú
����]�Ƕ�Z�|�9��MZ����x�B����o��Z�k����������2R��0�AF��Ym�1�[�~/�W��0�͢�ȃ���ބ�} �.�eQP������5�և�Y?z_��Y�v٩&���9�"���J�-�� ?�k�J����Ҿ:ͲLs�e1�w?��M��d��vu�Mo{�u/^`;q�"��'��|�BT��{]�UC��x����~��W��N�_��c�Fx*�	T³���] ~ʏ����g��h�·ߵ���;�{����&�꿿r�Z���O�9����=��~q�9S-�l}*����k��JE���JE&6�SpF�+�|ʉ�c��p�&�<��n4[�_�j���*X�=��.#�H�7�=�{_��Uʶ�mc��$ u��?��ѧW�����Q]�����9���Od�L7G�Tj��SM�<�Ե�v����U�>�~�����:��}��h�������d��� ��6O\7#�`v�2��Ds��������0��Eb^, Č?�����J�������ӏ�Qt��ꨄ��,�c���������D>�%d��˦�5���T��_�G�R�V*(�w"cǙgͫv������T���f�o�^��v>ώ9�3 ��ȫig�����'��6v%Mu�U�2��Ő:ɸB7�Nzv�~�mw��A<�L  �7�*�4�ңN:�c�y����6��� �	  ���O��8��Rl�!hU���'�-�j�"�zM31�E������)��+bHj�u�O<#�U��/*C�LC�Y
}4e�=�yܮ;�~�n�)z�J��ϭv�'W>��܋�{��<]_�W�ۍ�1����>�G�I�共���r�nZ��Z�G��.0�h��-�b�É��s�3s��~�"K�w7�s���o�*��M"�	f��Ts�8%{kx�3��A�M�i[��N+0���+kvq>���"�:i[K�y�D^�Y��n��U� �A�VD���Y�ˠ�=�b�B�X� �ı�I�2o�:D�BXӕ83�]��C:s��]e�P%��'?m��˩/}<V=|�v��7�i������V��&�1H+^�V���yM�����w�u�|���%�]�!޾�"}��(dO@��=��IY�јp+����:�S/llK�,��� 'DD�[����CIޓ�O��M�꨽����(��,���LDM�����hgi4Q3k+ɞ����L�՛��w�q��\�3��0��V��ۊ A���S��B�[�i	 H��\�7��	�X�n�熮�\O�k��GW7 6�d�B6�s���ݸXL՘ |�Ns��@1���T'u�՛�( �0���ӊ���xBLmR �N�?j��=7�2ck�/T��������V� �|`QT�t !�l�H���j5Q�D�!��.O�tE5S��{䬢�':�s�"������7�J����B��c�W�yh[B���]���Zs��E��²j��@���6��bϕ�N�?�?o���ws�I�c�6M��O߭�1����$vl���i~.o����UI"�d_�������B'À��&TVu=�"��K�>`Sc�Q��g����Sa�2��Ծ����(L�N3�[;}������^��U����x_J��{n��(D�x��\ٮ���7A-�oR�m�2P��7 �5y[����~uW�n�Q����z�I�j�� ��md���F{���!{�UyAO ���ݔ3�>�S8����!���z9]�E̔䕜 �_�/k��O�&E-�*u6Į�:#�FD�u�GkW��>*�#�f~���F�q��C7u��)�fKM6�M.���ב�~��j7�Ű� ���M�x|�D�t�Z ��TS<���n��
�TpYj�]q���-��s�Y�̷��ۚ 4Q�6�]� ,���ָ�
m{��	�K[O WDO�zZ�Ӯ�t��ыZ�h��죙{���N{B�~`���<���+B�f�>&Q�����Upnh�+�Ŋ�T+.2=q�����㈙�3[4輎����ٸEs0�aU�`���?�hW��Fu����<��A��R��6�gW���~��o����Dޙ�{�[M�� B�;�*A3�[�Ew���Tl���4���G���ܮ���O �9x��Et�B{�fr��k>J+�Ш�y#D-@<\9�Zi�y��ք>���8:.�6�o)Iۋ�g`] pF\� "k<�A��k��<�e@L�����z-���؉6s�ſ���kzC����U��,��!���8��нS,��-�8>ۖ��)Ut�|�;���}���$e�o��2@Ndѻ����2#�cᤌj;�+�.�sD>Hw�}^UJ˪�]%3}O��
�-�ZL����zb�ӊ�f*0���/4�����j���_��a� �|����7�!��JRֵк�m	�q��s��8�l�$ .��(���o�'��u�8in7�
�lǷ�m=;+p�ԣj#&�1Ϸ�{���g��	�U]~�
s��5���XK �mT!�[Щ��n�E!��Iph���^���v���v��m�ub�'���EqHĢ��U`3浢�u
�,�(|�m�����ǡ������muDՔ�v�4
P;�czzƾ@ XO=��A�6j!����oBU^�z��4�P� i�d;��V����S���L��ߜ^��y�vE�{�� �%�󷇘�{����@���r�Nw?s�v��� ~�?N�����:�Ǫ��l��q<�{�sg;�L����B�g7A��J[J��@j�u�6S�ib�k��> `=m�XU��&��9����b����9:v;��o�{L� ��h�B���bs���~=�Juq9u$+�L���'�qN1"DS��Jd��}d�Ttgn�g9K��t������B�Q3͛<ҙ9��i��B��=`ċ�U�n�Yxm�}bfoތ����5H�5�H6S��3����ǣ�i"W�6���E����
q ~:�kg��^��&��B+�(����TS�m���HX�����%�b�-B�q�ݛޝy�����Jb��/Q]!���:�Y� �������>*��6Q�ƱO��dCNd  ��X*�w�u>�`n����}"`7L���HHʓ�s	                      � �������������������N!�(      |   '   x�3�0�p�s9���3��2�#	UbAXI� @�x      ~   w   x�3��ON��2�<:�4)��˘�7���˄�/�81��ȭ<���ˌ�#�*�(d����[Z�e��xd~iqI~1�%�ke��=9\���ٙ�\���މ�G6YF��E�9G6fs��qqq �;#�      �   P   x�3�tuw�2��u"G.cNGoW�#��L8��"P�)����]�}B��8]������9���s�D����� p�      �   �   x�e�A� ��c*c�������j�U���vYs�:�km�e-���:l���=���9oX��3���Ж�B�fnPOh���y�B�T"-�b����u���5�s?�*�h���x����xtU��ɪ�π��F;9�d���׀��tv9ˍ����.9��i�V�G8�C������UJ� 3ԉ�      �   1   x�32�t�Pp�/ˬR�.-�I,���.-�/222\\��9K�b���� .��      �     x���QO�8ǟç�'8�vۏ,plŲ�]ٕ����,XMS�4���ߌ�B�:�hW"E�_����Dn�y�IϞ�_U����kj����OD�����d��G���(�	��m|�~�:��^�}"�V��ӅOT"��ƉOq3���]̓R�̜�D?��D1���Mۥ_�u���6	�	6)u��O��6h}�H��W� �,(�G�6!�@�� ����e ���~�)H��,���w�B����� ���BG)�38�I?����\���#<��d؛�?���a�KF(mq�� ��>�V��"��M�d&�n\���G
�#��#�l�x.贴��>�W/���]���C�S��'[�o��[7U���� ����#3N�<!	r�k��"�hR��*"�n�QmUFۗ��b}���������.���j̓G��A9��f�p	��9�.=]n�Cϵ��`+7�"A맀������-����d�������#�8&\��-�/h14��:�>-F%�'�.	F{a�#�����л�xH��b�)��CmB5�S��#�$��gTsl^����7��J��r����zt������I�t� r{	uZ��)�"����j`7rZ1�r���j�Db�t-�O�^�+���%Ff&�����7};T�5[f6�Z�( ;�N,�
�,º�Mz^=B��?BL0���eb���B�n�m� 7K������	������p%�������D�Xq-��Ŋp,�r�.ݎ�'���"��H����H�&K9����¡��� �͒6f?�V��k1��b����]h�%# J`Wr�~�oP��p7���-<<}"�!!�g��>�����a#.�ίүn9����-��-9��"F�XP=퍝�&���#�2�P@↫M���q�Ų�V�u����8�o���L��✹����)e>����f��Rbu��О�î�+�vA7��/���νB�׀K��[,�P�ig��3�����p16��%���I�?������׾@�t�����}��PÉ����x����?CF�.F�W����������5K7T	x�)JAGS����?�g��1��BNL�N��Lrmj��Gå�U��-p��-nm�È`?>"��5��� �$��)�v�ii��"ƨ�|�ǆ��B}�ñ)G�D95(>D�2-���8C�;;�J��r�?�-O�$!F�V��xP̹1i3"��j�k���}T��QHmG���:\2h�6Yr��:�t~1"_��F3�a]4������q���;�����7/(ntC��1�~�1֢c�	��n��|���F'kY6�:s��k �M�Qa��\��M� �jw�k�#�I���|oUZ�Mql>����_��C��M�G�CF���1#˟�rP��%dƎ��g�r4��(�8��ЈB�;��Ͳt�"Nx?
�N�S�8f.���BM $�w,�	���PL �@9(p79 =(A�Y 3�X�9 ;��gʉ��	��9�a��!L$�LḇE���Y�ca"���&�0���^B�	yA�ed9���^J�a������ ��7f��V[o�m��uV��g�:���uJ��mՑ��æ^��0��Ӌ>��V���L,����C�6}��x|C�fl	O��
��_�����y0��a�g����v �����Y��fێo�:���,;����'�*���U��"NPe�����aY-R|�Su<!���������[      �   �  x��X�r�H>��b\�na�?��-g���-�r`Lf5��Ar-�������1Ws��7��گG���l��{���o\�3�Re�wn���8��H�����J5����>�n���
�!Tg�������:h��ug�����M6H�����{��Ïn�Ur�͆���U�w�X-����߸�|�
d�V��H-}�{FE�(ӡ4{i�U�
���O�*�r�\�*�9�	��Hޕ�Q`�̜F�=~S��^8���O��W�2������@-'2��W��\����)L����������b��d���4X�}&�"�=�H�QA��Xej�]��T���0�Kr_ލ�(�E�\EΚM��=��n�H��:�ų}�:ժ��̈́�������C1�!� 8>U9\�)O�酮1�{eDШ�4H>�+Op/ֈ<Y�a5��:����49L�)��*�<����J�Zȅ
J�E(�pʐ�B��d0F��Uԗ�Ʌ�����?2�ڊ��d��d����o~�+�ȡ }�k
���1?N��0��N��
*��4<������yw�
��y̐�Ds��#1�$!t%�o�	=�����X��#�[t�H$+hD�ӋM��-([^�ʬ�W'��y:9��Cf͖�u&+�͒.2������ZH�R�|��|�]h*M���2�	��_Wا)V�NK�%kUf�y+���v�Tj���B^�8Y#?�b.гێ�^+���A�z��7�-`e��A��n�B�Q4��U[�'fz ������"~�S��Uw�;Q�1���v��E�#M԰^a��f�F�BlJ��^��
���Է�!�4�^D X$
�����Q�dm�� YÕ����/C:N�n�)�u�9����Q�����l�EL"ю�o�(H^��������.�ܝ@荝�ݳ�c�e>!ȹ$��U��`�R�"vs�-�&KQ.�n�N�zmpږ �� Q<��L̦|H��*�n����oIα��ʖ�}n����>fE����z�
����P�o�+��^8[ ��ȍV�%�̓��y�vɂ�xh�\Z�]��Dj���;'�	���5�vk˱െ׹�{'�v>s%P��nĲ�"���é����+�'vm�)���-I�4c�x��V�����\,��u�M�W�4���{Q�s��vc(O{4�i[�֛����+����
��;H:g�ҏ��vs����c�cZ)�=m�"\!xk��� ����U)!�k����,jd�&?B��B5v#A9<Kh��t�y�m���*��m`��C9�v�+��#��ukD�s1�.�X�������{�봘z��U���qb>�g]=a�{�d?�a�����[߽�_���1=ުvCnt�,���wZ���_�_�S29/|@ 3�lO�|@��y��H���4
�}�P?�~V;u�?����0z��� _�B��'w���VK�����5ώ:��Z)�T>�*<,`����M��"�[g����yb_��-�F�쀺���e�ҲPr3Ӡ��ꤐ��U> <%�K��j�=��Z��ދ����G[X~o9�%U��g�!{f}�H�����2s�Z���g�� ᴬ��NR�~f�|U�¥���Zp@���Ur����O./�	���jS��Q�x/�9�B_DʣUnǇo�.����Y��fJ��FA��
��trr�?�`�      �   I   x�3�H�J,*I-��2�N�9��˘�p{b�����I�\&��@vjnR*�)�sin"����1������� �I      �   h   x����@��L6 q��p�/�%�����5Ѓ�zy%<Ǒ5Kg�X���Nqf��\��<C	�>��$�;��y_����S:���s���_�k      �     x�eQKn�0]�O�T��4��" �D��}z�.9���^��v3���7($�h�z��ָ�@�n�����f6�͎�[ �0�[�be֋?���L���f��TŤ�fbg�2�IJP �v)����	��@��h\����W;�;3.��\���_JI�%���O,�07�ҕθx��PU^�Y�I�C����():o�-?�09��Pj�\�b��"�M��]5S���?~����t�����;o'7��(@>���RL�u���7��{      �   {   x��ͱ!F�x)�Y`!��L��@�����y�]���t#�xr�-��&#��­1�D3Ĥ̨Z���C}��ٌs7z����P�kU��XS"x���?��lWBt���f�2J      �   4   x�3�r�u��2�t<2�3��ӛ˘34*��'ԛ˄��Ȇ�#|�b���� �[      �   �   x�U�A��0E�ߧ��(ii5�4�B(u:j���p�"�Ā��"��߶�8J#rH%˜�w�p����R���Qj�a���͡�V�L���j���}��n5����%{�FK{Ĥ0'���;�4'�#��|9�Ɩ���o�E�Z��u�����Z� 锦�j��!�CɗY�;�$��GP=�~p��<����/O�      �      x������ � �      �   �   x�%�;�@D��)��F���9�*���ț�@��sD4��)�'�$ьf��f��k��}ӎ�P����b|��I�ġ2�dj7�0���i��͑6���O��E��pni�����thL�C���j0��T����M�tY���6�      B   I  x�=�]��0���U�
FM�$�����w�������<!����ל�$O��ı���,��]ӺyM$r�ʐ̔�����y�$D����:�L�Db���n[�	�6�jIX)i���#U*��fj;�\��HU�K�x�1�o3�<mL:Ɛ�x���>wE�%�n�_wW恖	�{_�ҁ	!�}?�"`�"EĞ �騴ԯ��+cH���'=���^���
����xȖ��_<-LJVV��ub����?O*L�IȂz7�?)!n�����#���a���Ya�A�D�������y���C����Gd��J�mv��N� r���|�nE�����G�q�ˈdE��ţ:U9���Y;�).ʀ 7�I�
B��7�A����7/T����ްED%І6-d�����ح$�!���;NkO"�њ���~��" c��ݼ$㓦���ѿ?�+��*q�{z?Z��te 1�8��l�f�#�2��Ё;DQA˙{��։/�0~�N�0���g2�������:08?\��:2B��)�I� �u|o�'@d%���gĔ�]y�ze|���mq�)�P���D�Ti/�L*�F����M�*���ꧥ
Cz��0�
�A0좍�Û$E�FӅ�4��"i9Z��狶U�Xc��{�H'� 6��6��� 
C"��̶q7ޘl\�X��g����m����Q�¸%S$��^�� 6��װ^L�H�����q�����Gytz����q - �e�j�rr�X��|�b�! �B���
۰َ�!��P��5��[I%^�7�9�&�]\��1�7���c�}�β�?���      �   Q  x�mY�r7]_E/�*�K|�Kt7؄�i4�4Y�H�$�E�����T��L�7����9�6��T��h��g��ѷg��S�jꟜ����t��wB*�Ua�fn蓪I�ښHA����;��b��Jk=�3CR%�����/<?"ex�1� ��F&� �$�
����a���X��EW�l��1�����vVe	�����#=����mCeNUl���7�)�	�H2�z��wΒ���)�nQw�gf�e 1M��8ipB����<�2�Qx�����	�?�t���6?�e`Ha����Q��*k�)�3e���v�頜wXك�o��P���Am
�W���
����o��\aG?�m7:)�8h���3^7�p�u�^��_�M1�z�@��v{W��O��'d �5�ԋ���[��ƿN[L�v�_�"���B� f��*S^�w�d@��Ʀ�d0Wuɮ���P�a��Y�6��ሢ%E*,���qg�����<,c�5�32�(gD۲,�=l���5�uY���d��P4�H죁��euՄ���/�G=r1E�i��n4��f��]��纽�(A���2*���T�ߊ��W����J!D����wdFS� �n=G�hFQ�N��B����"/ \�!v8��x�Sl+ӗ���h�"Cѷ��m���%|t�G߿�-,E��9��@<�!犢ƪo ɴ�{��7�Q|�a����g*|�^�F��l����G��ܓ%oI�m���:�N���~́1���YfH[��h��\e�qr~�q���q��+�yzB��m�_�䊝}ڣ�)��i�W|u�r2���E���e:���U��]{���cr~E� ��f��a7��JF���~:�$�t�o_��Lg�h��&�Hח f=JG�����A�Tg�k���(�ZG�}�eh�ʧ�kv�٘��P0b��M�9��=c��a���\f���0���#C�%��z�����Z��	%=w�; �j�+4�NM��&8�]_�� �nGe\g���2?�EN�l�L���(�4�p��[�3���lԺ���3�ƴ( 1���j�>�E�P����>
6�E�Q$����O���ɌLM&�G6�*�(D!�����9�����cϼ� ~a,�*^�d��ҭ}��#29ϸ�Ȳ{݈�N5�=��å =:-1l�:�� L ���g�vÐR�aM�Z� 6>
E�(�(-�^'�J��U���?��F�m��E" x2S��{��h�[nż��[��G���@"��2���\�(��ԥ[tY���rC�,e�Û鶽��:Z8]�N�M��b��M���_A/|��l�7�����^�|���߿J���pu���kW��a�.�LM��6���sɱ3�N(7����%�O:"���K.��)�)�|�\ٴ����Ơ�o��:�&_4�����׌)Z�Q�f|e�������
�O^p��Z���5�7?���Q]r}P��Qq�1��L����5ϸ,�W��m�8�uҝ�9a�Ё��q�J�]&���όu~��A ��(�^���P�3��qsс ��G�
�	f�9�GPM	��<<2�޸��g�#y.���P�S\����"���d�;[�kt�A��!�-��n�ͯ2=$��ò����^�C�a ���ydJ�9���]�C{��V���3>��ݧt�mT�̀�:�w)K\"M�TЛ�%ɢ�HW��)�]��h��H�@��<��#��lM0D�oq+5�<s��:�ͭ�^�5�4Hmc�t+I�����Hua+)l=Oy^#ys���o^�Om�n�{�"�qtlY<��p��i����{�j�r�)\,Qu�v+��?��7��¸����~ZL��;�v�.�"/�z����*ˎ�&7���S���g
��
�V|t>� �c���x+�
.�7{��.p�$X��|�u��+䳔v��<G~��J�:��X#��m��V�|�+q8p�<�i���p�m�REA���
y�] ��?� U=@�BB׉-�5s+%}@^X�%��;�R&�䊸w��I5��7@6L�*A���!=�P.&s|�m�[�@�
���k?8��A��͋��a��
]�.�I�3(2�3�=�Iw����EtD*k=��E[���F��VG�殽��
��U��&� }G��%�s�;�#�����7���h�x%݉�Vs*J;/��y�ww%�W��%�P%�/�[��ME�KW��pw�hw�ç�_�hq��*����p/�
ոZʄ����`F��|�!�C'S������%I�Wڛ�^T�.�*�2.R����U�����A�bP\�r �k�	���.���۟Ma<z��7v�qTDDj�Q���$DVX|�3ӹ�I~��t�&�^��,t���u�$R�c��;+�b�P,�#v�r�Ȥ�~{j�k_a
��⣈��&���&:�1qTt6�|���+��k ���o�c��T�~qeκm(8@3��{qt@��Xt��X�ʄ��v_�s��~��$Z�t�0��N�{T󱭏]��m�S� ��+��>E�wp�GY7�"�&6|�vg��&'0o�ݝ #�������l���TCB��`��˲ke�P`%� ���|+��0�"����w���n-h�$nܑE��b��4}�_��$���t�	;f�}�J�H���n��B��R�/�v��]h��ȏ�@w�2��ȭ���i=��J�=�o���Y�1^Hs8�/}-:1���uKcA��ZLh�|�p�y@H�k|��[� ZuL���r��+���b��=so����S����m۞�T�o��7>�B�qC�Jm�QB�ɳ/Z�ZCY���.���#��ʸM[Y:��^���^cp.?}٬��}M�[�Sf��neK	1nf��������N����t̮�؊0%�Xl��2�8��+[�f��X�G�9ZN��3���B4�� X�qxt�.!W���G�u��.�t�3���(vC��JDH7/����9Bf,L�Z�2T��J�����\cS�AϤ���"�۬�B�/��#�Q|�-������O�.�P�`��'�i�6��"S�8z���B5`h���k���o O��ᐚ��̞���~6@tdk|�E�~�@V�F��Y�I���lh��F9)�H$��P�eBK�|Fx�׻,-�[���l��o�e7�l@�9�@�M��y�]ɚ!���Y,�"�P���K�)�ѵ��}}���1mr�?!~�AE7+ژ<T�J�%��a0%5�H^�+��Efh5�,W�f�g	��̒���M�k�<C�z'W�3
���`�'�kR��^�'I��;�V��В��v4k/M<�y� Gk�,h���v�y�Ԟ��1
�A��o��D;�{����U�}vʉ�
t�3�3��w�g-c"�he��ܡ�>�.����E��CT�6x��k���+q+4��/��]f��n?I�&����>ꑷ�K�t��g��M�C1@�������ªQ��;�K:�5��Z�P��?�^8�tJo����|�k�9AR���2���.�ܷ/,'�&ǖ����S�Y��EmS���A�8���Ho�&���:�������3n�10=�0$��R��g�s��?�y����� �o      �      x���K��J�6��W|�!0�L��3��f�䋐 �-�����IV��Y����97�S��"��ʕ+2�o��?�����?o���)����r��_��Ha�.���6��o���������"U{K�	#���MH�̢�q�'����?�I�)����:�߈�����?��S����O��������������5�����_�]�����G����������_��?�_������k{���˿���������m��e�_���"����ƿ�z�^.��ϰ1��`0��`0��`0��`0��`0��`0��`0�:(uy��|�>����|���o�}�����+<���g��W`�g�;����{�ϳ���\���<ߪ����{�l�`0>��=��{��k����~U�����}�<W����<�`0>���*���p������}��ߖ��zYSה���֎b�Zն����w���w��|�����dS�-������\��JW��գ�N�6ޑq7u��6<>�~o���S4A�'��`0~��

�E�e�t+0�/.����Ը��~-��>�׸��2�������~��-�qQ.=h��ݺ��q����B-s�z��x!���iw=�
��6nO�����rjs]ʂ��U�[X�	����+?��ϗ�CZq�T��x,���59�Bwj<w[ѳ?��`|O����\+Z/T�������wj�[��������J�jk*Z�:��z�ƞu!���<蝘pY�@Z��о����/qk�S������J=O�����Kφ�m�)M��Z����եޒ�>���֣���z�scy�큮-]�����F��E���O�jЧ};�=����)<��Ө���U�8���{���c?I=�8zE02ڴ�����f3���O���R��j���ш7�щMf{�O�¥����iۺsi<89�3{���}��L٧���b��t����{���c�}�w_I�����xdlZ��f�2�{N�,ڒZ3����-'�1(��aIg�ۓr���z�kzt6ƑO{eGG�y����O��[I�V�I�>n��v�J�g�p�3�d+��mo��M��ζ��lG�t��z0���[��`��/r�F��߾��ȒI�4Zh͌i�����Q�7����z�;�Jop��FZ=@�M��%�9�����|��Fezb���$�/Ѓ������ۯ�W��]������ؒq���<fd��x���{{�k��f=R?n���w�ٺ�>��mS���F^��<�~^��^���}�K��\���͚��6�������ikI�'���N���RK�P�'���c��M3vV֞Og���];]=ր�k�0z��?��g�#�O��gLzO��� �����}�l���"q����e8�G<��z��m.�G�8'�����'��vv�w�`o��Co"¨�/n���o��R���U{�kW��e�+��`g��5c�==S�&���zH��Ec��M��!.m��-��h���#�3��WY٭�4v^:ԋ���m�OO>�c�T�e��5ޯ����gbO:
ͱ;���><�]��g|�L��m>���h?�,��G1a<��������L+��`|v��=��7��᫽u�V�-���)�	fvŦY�غԯ��7��񥺈$�<���ya<����G��<�F'���N�ή�x�v�{�������ݡ�@ڦ�$�1ƙұz�����`0߂��i�'3�A�u�b^����p��z�3yW:~9}�E�V�G�cYHǝD�M�g�[C4�i��|h	�-ϧkB���)��~���'����S����)��h���Ɍ3�le0?��=�W�K������Y�7���~��������`�x��3-�<�w�̵}��_�^3���W��_����z���߭�ދ���:O��Xދ�l��|�s;�m^�G�O+}�w_�g��*�~�������?߆�-���d�~^|���5X�~M���=�����q��q��ϊ�k�
��a�~޺�^F��'�>���UμC��W;��G�q�+\��O쫁ِ��'G���ϯ����k�����f�^K����{��}��c��]ɟO~��g����-��x���l����j���j���ۏݯ���_��?�?����5�n�{�sd|7�:w�3g����������������u��_��_Ն���6�{My0�z[�H2Uީ;����d�z��O�)��ǚFY+)h�s�js���L��/��P�ʷyjWe{\��3�+�х�sSNG�u趡���9�*�ݠL,�}\3b��S^�Ϸ�.t��swU��n��3��z�f"�mZe��}o�Ⱦ�W�����ȟ4�G����,�tv �o��$�l�]N��T�k��g�����Pk�U�q{*�]d�|"�d�&���~��,�L��d����g8��ϟ9�SGx�w��S�a|Z͈����Gԥ��d���ǋV�8�C�M����w�4�����U�|�%=�鄱��S����ٴ�I��)_��'�tߥ���_���#����>����ç�
5�����q�����_3��n���}���[2澞e�~|��q���V�<�U�<s�vG������f�q�Ml���֞�O���Ԉ�k!i�٭��vϱfs��w�=F�'gz�	f��ٕ��B~X���O�O�;AV����'8q�+�V|�����7~��K��k�����6�|<[���mw���*����*�=3򿨎19���&z<���Q��n~.x��J�xM>��/*V�	���2
���|��������s����Qϴ�5�<{3��l�5�k�g��Q_�|���	_|l�'=�۾�GuO�X��ގ�x��,�ݷ�3A���l<��c?1��WV��L��cK#]��.Gx<�V<.�յ��v�(Qni���b��x���Q�x7�}��O��<�>8��s�7�7Rp�|�S�e��'s�T]�L���M��K��3F&_����'���Ǚm���ے~A������b��}loz�dV����^K�i�C�Gu|�Pp3[�.�q9�c�3�vV	}Ĭ���|vFﵬ>V�g�ڨf�����g�_*NW��?��u�d��쐳g��'��{1������b�z�S�{��x��k�W�A\gQ��c���q[����]�����KE��^�1�z��>�z��=�O�e�	�y�ϙ�gj�{8�P�]�[g6/�r����y��{{<�4��{t�	�xp67��4\xh��/���g,��_ǈ7<y�'dr^���x�:�Zr���&��e֞ǜ��3�<7�W�w~��b�xX?Ã����?��/}f�@v���u9�4��<����f�f���}���Sm���kMf4�/5�2�l���S)	�YO5S������!� #V��q����8
����}i�gl�f�����b����c����[}lKf��
o<������1<ES����H���s6�)��j��0���G�<�G��Y.�睿�1�]��|��;�|�%;��|���}m�.OOo7�<;�~{b@�@���b�3��tJ�̶T�=�kv�'<�.z����U`��#0�=~lo���_f�A��������N�G��,{_�4����QJ����A���0?�����D�H���>���|���!&ϢϷ0b���<N���_�l?ϴ��kԆ�?��!F~~����$�Ax��>h��N=+������~Y�F%�����r��zR�S^Zؔ�ld>�$���'0�Әqʬ�"�i��1���X·�Z�i�7�=�a|&RuJ���96o��	�r�@����O�3v��譅��&�Йww��*�<��2�����3������>��d���[o<��i�`���@�}ٯ��O�/y28S�C����'q�OV4N�܏�:���C�7SJk���l$@�~ڴ�3�ۖq�glj��F�����i���~:<�1~kl��5},����3���X���6U��`�|loMΞ����\�>�7�=����T?͉�]DR<�    ��{?T���L˛W�$��Szp��{���u?ȃ�z;��SO�4�pv��g��`���`3?�o��yhO�ݵ���o�Ƣ1�9�����Gc� |loO���L��*.f���j<;zo��t�}y/g1h�\i\ظ&�]�6�;�TN��>���R��
z�p�3��9�:gߑ�dw�h���g��k�>�CӞ�yS?��mv�vJ�fQ�yA�����=�<�o=�����b� |lo���g<��U3=����_��7� ������c��v�_1���y`^D\���]�ϳ��E=�l�h�G5���\�4����<8�Z���ٶ|bT3k���z!��׸�1�n�-�.�P���j֌{xl�擩8e�y�U�[~�+��k�'v�i��-�|21��x��|���m�����^e���}�g�Oq��?U%��g�ug�C�#n�ۼ����S�hw.�+��\��5'�7㖤^g6���t�~w���Wl�3a�n��wf���C>�����>3<��>�Oy�O����ƣN=��g��6[�3i�N��>5�}���n�A�����@4�Y���<�����>�[x��YGG�!��*F��{mn�%�b��G��Z3�y>�0޵���=?�~����$����xޘ�$<��3[�����3=����轹�_ө��7��wԁF�2fV�v_>d��6�[�T�c<�'[Ny��a�N��?���;'�UҜ=?s�t��s8�?%�t����l������?ˤ���w6&�w�Ď�oO��4�|�����z�������z�p���*�����1�C��쾴+�Y�j�7��|ܫ*��F泚\y�?��/(>n6�u⑇wpV���o��lFr����c������������f�g����Y��ijK�k��㮖������$��i��.]�m�����������,�33b��>����߉YV�O��X�,�UaZ������=�6aj�L������<o�"Ԟ�z��s{�ϻ�AW��;1�j����_��wh�n��擳���7�̇u��>����#���/x��{�s���un#��;�a;�q���}��o����)L����kN�/fz�a_�1K��10�riֆZu��79�72�<��/:��9��J�X���;g�ցq��.��l����<<��?R
}��6��|�ǳ{�ٞ��g��c��L����
�,���/#�����Eb�}��	����W����~#-�3?�w���Z?�W��I�v���O?����Z�e�,?mI{���E�9��e>�
��X��m˟<���v�-g6ҋ�?ў�j��Y�wl�ĕ���q%�?�a�5���<��ٿ�7�S3�'sơ��g�g{��U�� :M=�$??�z�X����fF?�i�ԏa�Ìc���8��΢��k�Xg�������y� �ވg�y���W��wͤ�~��x���竓��������Q�v?π׼Q#��T�~��O���5c4P�.�H5ϮF�?񄏕,f6��������E�r�����<c����1B���zZ��I�^D����wgV�~v�S���~t}��1����Eg�o����O��RN�ٷ:�2�͒/D�&���2dߞ)���lt���z�G장�����o�Pw�Z/�d�-����߈��sk�qN�K?t����g>*3���Wj�͚�{I��z���]���w?65wz�ƣ����^��>�����~M�ת���z�������5y�o�c�|M|�Y�L����諶d0��`0��`0��`0��`0��`0��`0��`0�g0�b����8_%��z��UV�2����{8����<�g2��u���-_\�y�E&�Lܢ�&�(#f��!�����U��|�?J�a{��2�q���Y]����e�Y%u0�xo�MfU�JbSVE��5������*�\eZ�,SL��W>��+w�����`0#�%�\m���[�����RJ��_׀|'���*z�J-�zz�ZK�xo�6��;;��>	o�w���]��`0zLj?M��O��2mktq�8����
���	��mH�`�ˋ�<�U�[�mx�^y�g��"s ��`0�C9�4��B�����CvY�l���bNx �EZ�5v��A�t�'.u����ke�ٴ5�Dm�k0	֬�`M�W�KK,��
�;��E��`0�c�/z5߷յ��b2�?`��4p_VIe�����}���Q��NllX���m��{S��ri�A)�}�I�F��}�����
o���6R���`|����@rQ�--h�>la��s���(%�Q[U|����z�ۉ����5���ʑT�*j�[�����4w�y{����ȁ���M�2��ǵ7�v7�v�}�,E���J
PYU�u�/ �	�Aib���P	���FZYU�ʭ*D�^w�I�Z��sM2E��RN�?���f0����p�������״�ya�,[�k@]v��������R-�Aʤ��~�ۺ�d���/֙�ÿ��7p��&��W®�n�F>�q(�J��5X֤�#1N2���$�C
R�>��΃��QS=mB6٤m8������s ��`�Yx����w7	&H�m�Ue'�O�RF��^_C��f���ݛ�vΏ��#V��,�Li���^]��W��`0.��g1Ō�Ʃ�x��ä����i�w��<�V1��<<��%��b{4�9��d
ۙ��ʃ�`0�?󜟄�堃�V�zT"��V�ƀ���q_����2�5��5�[��]���K���g<�t�_���0���`#�k4 ���i�����ߑ�K �]��B���>��y>���6�?:?X���D<��_�Y�#��`0~WX�X��E�-�`���E9��e�v�K�@aa�ϲ��kY��|��l�q	�ԅ쭷�z��̲�}�ko�3���"�3�l���^���g�l	�2��%,k!5W���i�:3���z�u��&=��/k���`oǌ��Fz��Y5�A��Wڲܸ�A/Q��5����>Nc�(��`�Y���.�[L�k����}��:덭�g�{;��nY`g�Ƞ!Z�Ъ+[͈�4�H�x�1�2��Lw�3�osDd���xl?��TF�a1:lN��5���b�Փ�b6d0����[��`�MA.�g�Y5�$�T���5Ϊ�B�цa��䶼j ���V���`�b�1Q���8������ު/�ơ��I�+�t �/SC�Bi|� $O��U!��`�)�c��$��z7U�99k>�K,a{\���g�'$��%o9�n�Β%Se����`={xg#��?�Z�Kg�S�W'l��myc	,5��Լq��-��`0����	@s�Ԉx������6�{��/�5?�[��ו
���:%�m0���_�N����U�@v3�}���\vݷV݇��7�*��&�6Nl2�"4���p�̄���c������5f	��V�v�:�������:Z���^}�@��(њj<�$�fqX>�ŝN[�g�)�r`���P�x�k�=V��b��2��`0N6�`���E�8A��C�E:j�8����,6�و��:��%��/0,4]>�K��&�5�N�5�[v٤G���`0��KO�~E�A҃����#�T=�^��{ߙ|��u�ʃ������,�-n1�2��즮f~��ץ��ˈ~��	|r�ۿ3ϟ�~>���`0��;�`�������zT�i�%�u6Y$�t�}SE�a>D�w��|�$�`0�K��<x�� ��^��ۿ�Y1���<����y�|��!��`0^��ˁ��K��|�dd0����{�����������A��`T�Q<�`��>�Y	8#g��ڕ�Y�P��`���[��dސr�QN��^V���v��}`=�`0��ߒ'k���Ea[^�[���fHo��`0/�����?��ﲝ#�=��ч��:�8z�'3��W^]kF�ʃ-���|�O3��_�}��=k���K��se��?��ç�    ��4wԛ ��de�_��M�ĕ��J%�[�� �m��->�b�	��]�*���-��`�eq�<(�|b��{���\��rʂ$��G3[�K2 �� _�����x�tz0y�c���e	��7y���
9΂�`0^���*�5�ɛ�Ԧ��_���&ew�:!����)�u��<�Q�̢��w%�hC!hDl�|kFn��W�h�6��,��z��Rp	F�5g���>q�=��`�zg�X�#FYT�^�X����&��!��jV�Pe��5O5������߈�SJJ��|�xà�,:��b�b\�h�`0Q� C�6�<b���:0��[E��f�z�e� ͕Eg�����b�Ҷ1� SD�TQ[�Ҏ~2UO����s����ЃT�^� �H.+Ѐ�Z<�*:c��+3��
�����w��TJ�T��~�����lR��_܊�!�Q�]I/�Z�e�i=���s�ĥU�OzA~�3Z�F�Q���p_�\�bJeC|5F�\J�g��F��z�q_x�c^1�Ҳb��[�(ͶXtQN��P�X��S�"Zi�N-/�~�Wg@Bm�*_��j�+*« ����Pk�0�
�p��F��-jr�d�'6��E��`|F[\��߿���9������KN����EGa�Z�Q0IE�Y%FO��gg�>U2䂾9b[�3k��-U��<���QB)a�
��P ˃Z4
"h���F��8!�zoLB���
�(�猁�\}���9�[>�!]lǪ��`��Q�IgS�ɚ��~5��Є|��ב|翺lҰ�.Q��@.�"=��0�UEKPIU+��К�Dm���u����v��	�
Z�A��
n�g0�g����d(W��UkV�����J�����-��*D�!�N\E6!��_��(d��@3�*�e]i{!�buX�J�`��ZT*{һ���ￋ�f0��ǭ>Bܼ����ЬYoK��̸k�t|�^��X[!����-z'�qrh�v*�`��'�W����K4�m�{�#f�`k�U��}*R^���r�)�힩���U,ЍJ��9�h\:_�}�>3p�Võ�5�(	�'c��)5�g3��VX���W	k6�5����!_�CK�ܫ�:��O��Y��׭��� ��`�6L�+B��
���z]`1xom6.���̡�0J
�w�!H��*�3�h T��@ϿJ��O���8/º�Ғj�6�W�R��T�W�܀�V`ե��:t�.@�i��˻��}r�3甈�'T���5C��+ЮYJ��r8��Ǽa2]�+Ӆ�Q��zmQ	�7�YEB�<��=��M���<�`0�ژeCÿ�BT2:'@����M좠.2����}/��X#�MOGm�X�W/���TI���h"���	:��+o?��Ac�>ĂK��1G��Z��t�n�$.~{_�
o�T�}���.t�[�vl���Y
-��z��j�x0]��/W��M	"nU���]4��0b)�2\��:�[D�_��$٭d���L�K�!4��:{U_�:��y�~xy]u�N��!��F�8�"f�v�E�6����޺���`?�WL͖�EV�^7���ue���x����}�_=bQ�H�U�j)�6�C㵢�ՁJl���t��}7�in�p%)h�� 3Z2�����rfm����*����x|����Z>u�{c���hDI�[��-�祲h��H�7��i���q;{�|hЇ�lk�ff#~��X�����,�o���/���<GL1�$t1�a��ft�DJ�pm��/�T���v��}h��0��b���Z�w
�I�4�\w��:�`0s,�v���V��7�^Z����^��hq�)��Z�s4�ֹ�8��slU�![ �ׂ��-q���e�/Rq�|�#��cS`��M�Π�PPQ
�����u&�|i���u�bJ:pi���i�3�8��l.I\������a0?���co�G=�����G�ּ�c�=u���<pNL�l`e@ፑ*��Ǒ/���U�Wa�Q*g�1��|F�(��x�˥��Na�U� �qMn�G�G��َ�9߃�����,U�z��F���Q��:`̦o�ѝ���#)"~:�6?�]�	� ����x�����X�G��|4��|ʉ�n��o��V3"�#�*۰�����M�&�d��n�]���T]��dVY$���?���U+�=�Z��e���
�)��8Ye����&_������S��S�ZsJ�ʺ��rDYR.�B�H�l`n3�����
Z���H�C��92Ɓ��]n[�ϙ=�k�{����6���ǿ�NBߡ��ѹŲaO��2��k�wl\�i~P{�Қ|Z�s����GhU�Jӹ#[���nm�X��&[L��:��J�{P($oF�j'm�jo?��*o�,��j^�r�B�Qâ��0tq��~ߞ�4<]��x�翱�,����q�ثB����>ZwĂ�+4���0�����o(#�*��V�]���h�;5�=�х^��{h\��Q�,��:��;)�rbCԉ�^|�1�=�yl���3����������l5_�6R����c�ak�7��)E6�x(��O��+��oU��`�qx���̆g����sf{܆�N=~�E&W��D��P�k�C��*�W(j��S �XP�7�{��~U&i��EI�6=5x��8g�)�l�.�����׻A:Z	��j��їd)��P��c�[q���#�q[m�����I��Wc�t���>�,�=����e$����{�XNv��v������&�]���ֻ6��-P���4h5��X�z<ZoWX��2�䌫��}@�:a|~7Kx�^��8� �ɏы_�i�c�����F��W�6R��,=���m�V��I)�~5N���bSJ>縩��ō��Ư��'k\e�bu��m]��������eF��nߊ���Tc@�����Y����X)�R~�ϤY-���������yҮ��k�m;N�7�oV\���[�*���/���b7Jn�Uo�?ufV
�?R�|GS�
�K��Gc܀�>R��m��0���syǧ���P�G�ȤN����0���1zX1��:��q���U�y��\�F��%��$�J��u���b��[��
�>���9j�(�R�w��k�y��e��m^��h���=�Qvq����Pn7��0~��19������6�c����ν������� �d��B��ł��ge|Z�u�,�ZR.F�u��mR�e<�)b*:�E�-�Vf$��.�M��ӥ�b�V��4��h�e&ٳYֹ'ak���p9rYP(Q*�ͦ�);hwܟG��T��S���3�ET��ޮ����E^ͣ]G�\3��0��X����r���q:F���3�.L]�}9ؐ,�Zo1�5�~T_��`0߃s�\s_o�3g1�Oo����P}�
�^ V��Q@��,<�1��Oqg�+�,e���,p�)Bp�W
%�$[���Ek�ˮؠ���u~w��>�F�J�s�pvO�uCW{��3K�=�MP�V�X3��y��F�T�T�
��W[�-[qOw�p��r�m��`�_�����d���b7[6�2�=a�fu�˃Y@}�d�k�����M(��m5#T�� �T窬����/Y�g���$�(�Zc@� ��(c�g�q�j�#Q9���O��g0�k1�o���U�IS��5k�(4n��$��k�{�x�}��~����J}�{���.�
��6�0�J��N)�[[E���uOJ#�W���Ǟ���\UZ�����pځ�͢e�ޣ�qf�浶�))�i����j!0��&iUjγ��]�C������^�0}Iʨ �ƀm��U�HY#�����7�	��L��y[��x\���3��L����n�e�$ԟ�ޡ��3��Z�0Ȧ��TUe�V��4,���4NA�.	rT`���ԹBU�
N�� 4�8k�L(+)�$jCP�V�����G��I�֏�=�VV/�Xy�    �����j��/8��
��9����&J������m�_1��`��X�*��h5��۬)�[���^��n�b[�-��~u%o��{Y�����^_з�sG�Y�:KXZ,!�=,*qd��ń]�Yc.6��)����է��ף%z��_��O�0�׬d���j)FҠ�4Nĥ�[|�}m�l|�%�1{��32��#�[��!�[�hш$�V��� Q��9T�����+5�`n�v���<��[���Z,!y��
*�{)����q�6��]�B�Ѧ|�����My���]�����w�^khͪ�62Sn�Z_�iY�}��Ur1-�ZnQ���5�>à)����`0?�y��u�y�k��-��ϥ��� z-Xc1T2QVQ�N�ȣ��Un�7flۯ���9��pj2���>�h�r��[�^u��j�f�VjE��2yv�R�ε�G��y��YUă&_��=6�*ٌ#!�5V���)n1-"�e\A㺿s^���}q�D7K^�+T%&%x��~A�٬-��<1��V#Ӄ1�c���wWx/n��YB.����3J-W�պ�հ�-޻���Vq��i����ת�����4A��Gƀ[��m�(�hW���13�,yS�lN��"}4��XyPY��|�_��`0�s����ތ��]��[Լ�B��jO��Oy�k�PX��W���%�f��Qg双�5�L����
��7N`I{m����'�K^k�}T�Vo��5X6Q�ZQ1��[ˍ�[hU��a�
�)�ܤk�0��GI��6��d}���i|��ݧ�}�{���G��s������ ��]�h�q��@epj��QM�)� ����8�+�n��'(���g	5hCʒ�����XpU�2Pš
1�Um%�O|��>7\j��N=�*˟*Z`w�h��v��1���F}���-�0��*�o}�8����)*��Ud�l���:�
]�����S��㯈�?�KD-�j�&���sdY}E=�+k�X����ad*��.n��*C�N��ˮ�/dX�F��&�%n���\���=��P(���ޭc}���,�>c|���2�m劲���R�?U'���^K�Է�\C���G.ZOY<���H|�GAI�ُe�T	�g�m���hE1)/����:��h�����CX㯕4V�ѐ���S���0(k���~����l6|A1e����URs�����(�M��(Va���3�T�[Պ�h6����~�*�]�T>�ݣ�Բg�h�-�巚Oo;�{<���s���5I���(�ơ�M]#ڧ�.�/z}l�՜�m��W?!�/�[���O������K]OX+�`E	�^��Ȳ�Z���G�_=�����أ҆�c��<��R��y�*LJ/��LU��.��v[�-*��̭��n#rq�m6��ϟߖ2,�����T��[�5V��;��x��ε�1 �
|	�1����祘�J�� ��&�4ؼ���*�ף׈̅�'P{�K�����mȬ���
�V�STx��:7()�3f��s�i�;�x��k�w"�`�WV��.!�-����G���U��@�K��b��{<l/�*N�k�&��t�6�sW���s@��[�2�/��#�W�y@���G�����C��~�s����~�m^��c�/��]���/"�پvO�\�fx��J�ȃ���WOјc��M|5v�g	u�T#�Σ��B`9/�H�����j���5N� C��f��"1�&/�Π�w5���|p�V�*�H��g�k�e�=a��h�^�r�j\�J�NWl�mn����g���63��8��Qm�C}ӆ��+$�����A)C��i��E)����1�}�/�s���������J�H�r��4�jta����:��GD�
�$f�P�:Q�|�F�c�E5J�S/�YL�נ��-�B�Z�Ś�Gۚ+�;Ws��VV�g9|D�M����}�X����Q�:?���i93A������To$�\��`_Z�$妄�)����E#�q?�[�?V�Ḿ�V,���\d�]	\h�Z�fT�.��VDW�X⊩�7���M9��4�,`4E�YYf �^�@��ƃ��ʃ��n~0<��%���`0~ot~	k�6��h<x�	cǃ
����������S����0i�2���̜/k�M�խ��W��pԩǜ9�JF��7�jN�`V����@Z��,{>�k_���;ω͙�����P��^F�B�R���"0:�_�FD�&�w9E���b0�_��6S�P��3�:k�[�t�1��G`�m�=�5v��Ʉ�Un���<&�z�N�>�Y+���M󊖃Փ ��[E�Y$�f�)Ѯ¬zS�Œ���\��BB�â�i�A�XR�h/�ƃ��L�~2"���1SLvro�j`�$7�A��g��r��~&'���E�0���g
��a̵��H����	��5����|N�ֆ��c%SuZXre|��t�3h�m~��I�b���i�A�6K(N��	"G�)�����U��ݽ>�ST�+fq�6���ٍ��!��[��Ҭ��k��b]�N��f��y�$���/�4��`���"�����,��^��ˬE�E��6^y��U92�&� I��{߿��u�E4{ ͎��o�4�W߷�	��ܣ����	����������^c\�]L�� �xD�����S\�}�U��"��(H͖���.�J=����RS�E�͜2�1��M��kL�% ���`�Y��W��ʍr55���j�"��w�ǀ��"妤�d	�x�j�����-M��,a�� �faŨ�CA�l��~��Ycax�r�K��S��Z����9X�7]�c4R�A��4k)��j>����)�L�6��m��9_Ɵ��<��%Q��Te@�rk��F1���^%��c���*�zH*�k������ř%���15̿F1�^�=|Ŋ�rb��?U���w�����@�$uq�F[���)��/U��s����O�I7�wknq���t�z/#�ʃ6��,n�?Vl����1fb0�?}o�s��V!_��Y+Z��e]tl�EEW�V�∹�����s)�s�W��d��2T�i����QQ+���֏�� u;�z��4��퍊�k��0fX�Ys�Dm�2�ڐ`X��T%(��G8���,J�e-}-������h�ݗ)6�/����b�D�vD͜�Gi,��-矿9����o��F� z���Cf����&�7T�-���?@A{��׀��F�lvN���w����|T������X��k��k6�|��4�	�F��4�^�A��MHUyc���i��Q��{�	<q��1�ۓ���,���KU��F���j+�9���e&̃�å����В]���lH�sXp��j9��4KX����wkV��X¯a��q�7��{��ZT�R���϶�{��hM�/�5��?�rHq%�����%�����YX���J�wf3.�՚�`L�O!j���R9���GL|֪��qфL6��"�2Dh�_͑Y���q�I��-ns��21�w�6�v_	8z��#qXD�j��CVU��U�S�z�*��nY�.���Ǒ��Lfl�u�p3�r)�L��7($��}�H8�߸����7M�9�tAGimV��ަ�V[�E�Sz��5I�F���� �V�I�3����a�Q���K�2p��e��
����I��{+��}�I��;�Nj�jЕ �y~��`�Y�������U�^1T=x����L߼ed�u�k���1.�Z�h��YݡϪ�摃[p�y����&_PL
�G����û<*{5�>�8�GD������	g��X�ƨ@���C�(_�wf໚�EmU�v�/S<{�TC��O.~�j9dV�g9<`�0�1�Z����E�Y��e3Ž}T���M�=l��z�l7Q��n1q�\��,�5�>.v�g�y�0ή�j>��c$)�q��z�o�ܘ��@������b�:�x��6Z��?N/��z�䠀�%�j���,�    �{Q�k�l鞳��R�;=|u�������v��'P�]��������A�h����Qsp�u�sk^��̈́:#S)1���r�`0��9Ǣ(2a��K�#}�զ��S��S��s�"��ǘ����ُ0Qp�;�=s���}�aߣp�Z�n������#�.N��m�
��-��?[?��8fHA��Q��Ou_S}T�<2�Yk�U�YB���?�^�~����os�h���5f�h��C&v��t�f�Yr�t���Q������:����Z��sưx���z�H�������ϣ*��B�Zs�}���V-��/�!����V,|��ZōtD���sg-N�:*�yF�נ�+8h'�6�5�Ui���5�@[���������u����O"`��Q�@Iß��,���n��A�~2��9��(�?qhq��L�/��n5��~�a�U�Qa%z�Q��%HK��)�O��Rߞ/[�|��CM����<�ڶ4��syʙU�mP4=Oqs��Č5ØB*6�`d_g��du�I��m����y86�G�ݾֿ���������g-��5��+�be|=*!�6��>��V�5V��}�-����E���q !k
�a0�Vʃ��_j�D0띭�Ϛ��S`t�LnӠwn�ǚ%0WU�7z�X{����=���9`1s�fPI�~[rp4�y�p��Z\�\c=X�j�*ȃM�ֹ���&uؿ*^���m�Y�J��a������*[��=N�T�����;t��V�#�5�Uc0�)������)���.Z�l3g��P*Q=Uo3m��`�+���z�<�|ZˑU����9����ꩪ��)�G�c~���Ƭ�O�Co�h6�f�.��"&�̯���,ԕ�ZgT�奟�lJ�����p)���y�τ�G�;#$FY��y�����OAW���c�}�Ou�R��>��o6R��+�*u>�
��}T�8J��٭��W=�'t��ø�%:�b%ܾ�^��b$��;Œ�*��飕A���巣�;ZG�&����m�������)�g�6�R��Z�ӕ��βT����U�T����֍v ��X͒�r�y��`0�7pV
tBV�-��n���3u��|���lh{�ބ64-t��c�\��ȚR���v�5�BJ���ף<�Oι�@9[����ӂuuE������ྛ��yM1A�(]�I{�՚r��z����5�>�n��E�\�ǻ�)�SkJ/˦w�uNP�sT-'j>�`���j��YcM;@8��վ����Y�
t�)3��Q]��Q6.�n����#�*TU��1F;��J�}��b �R��h��5;�Z��rn��)z#���٣<e�gBO�.�[�(��|��V��l.�lC�#����P�j0si��� �	*��V�NT��r�Գ����g��T,G2�?T}�'ㅐX\�������n���(U!Gf�\UbRG_z���X�	����o6�ƆX��f�UO|�՚�k��Q�|Z|�y4���#���U�o�Dk#��l�QMI�L5��k�F~�7�{�~�Q>���Z]w���H.5N�K�$_jmAq�!�<��:�	ΫT_�t�y��ϼ�`0~wT�"p�h�)�x�[�r)y^[kF�pDR_�:{��+G��M�X�~�Ul����բ-����c<R�u�w�eڬ��@ZT31˼��屢��@/{P`~M#�W���c�)%�|����ο7������w���ڭ��D���_�I�q��5~��u�wGc�c0��j���Vk&�^g���t1�5�����W���F�55��}{d��C��z��H��&�����VX�s	%V�m��#c.�f�6���q��FwO�V��Ȱ���d�=�s}?�h���g�F�o*Vo���
<��kÍUqK�d�c~$��a��r�Q����[�֫�yrN���.*$�y�h�(�x*���M}���c\*��`�<�z=��E]TBY��)s�87�1>�-�v��6�|L�C��S}'0Ӛ?b���*�*���b�]�!��E�ZMۥV�my��+f�n1Y������ݵ��Ud��g��5�{T�Cj��X~�ȱv�������3�e�ћjզ"�{ :����Y6�����?��I'��=S1�-c*�x��l��~�k��u���,@�.$�)z��B,"�ӕ���|K��c-�Y0����h|_{��K�)xۏ�o�V�~��S�E����6!yo0�Ve�>n�����8��/l�V*r3��](v���^�s��-��V��%�����^��k4�fY��_=�ːy:�,+{὿�M{����uL��Rm�:CW����>��x�g�Ec"|��y�#��>x�r�պ��|ϐs�s����ҍX`�����,}G#MR/q>���Ϟ��`|�{�ۚ��ճ`>��K>��)��+�dE�=�
a�y��Uz����[_91Vӣ[�7�j����^y�l�����m�RN%��o�Ȭ�|T�:DA�#�5�VN�8��VA~A����R��k�_ƚ2�*PP�q����^�R-���v��м� ��YAu�!Mt�B�.���?L���6��R}�G�'AՈB�T)	��%�P�G���h]�kb)k�]4����w�cY���8�7�k�n]���fyR�w6:�5��L}��Z���g�p�a�څ���m(j߮�B�6(���>��5�b�����y�Ĝy>=e�&/���4���������J��j��Z} *���/X��tiJ���W8д�ȋ�9=��y?�. \W<�^7u��	�	0��j@U����E�V;i����bv%�m����6j8� W�)Q��60Y�T!p�&��f�]��2�1�_���j�wW���~��6��gZ���<�JG�T�6v�EL�G���po�W��J��iCS���M�zB��s"Zo���qd���޶�ހ1#Π��k���)z��,��.�LgN�u�C*\�͢��Ȱ�Z�����O!-�V��7,h�L+h�[��RiF��B���1J..H�[#�.����\ٴ�Z;s�s۵��Yo���f�@�U?�~���'�C�/y�0'2���޳�﷋:G�~i�ɸ���z��gb�,UM	ʛV��,�U��e�<2�T6�\A���ڪ�8�:��ﱮ:�% �R�@@f��?q����[&q�-Su�R�#߼e�f{6�JL[�n1�d�Ɏ������9w��2ͺX<��u�˺{��U��ZG���j����\ٲZA�e��=�~�1
f�OMɠ��֏%���Z ݖ���h�Ċ�ga8D��"�N�����1��`0��8����W��fsʾ�/9ŕleu�����]��|�%���!�!�F2�#N�b�<0K�2U��D�d�)@%�oE˂�F��t�U��B���y+28���*G��y�mϭ���JL):g@�-:R�mRm�[Fg�՞;�v�7h��E��1��>�{b�����mAZ,���9a�.�y?��}\o���0n)ت�t����v��mk�k)��I��X�`�w �?WG��`0^g�[ �����{�R��E[��?�%�_��[�(A�i��d΄�X b�C!Ri�׮�li&�_M�*ͯ�|f��ꫭ��a�̛�*��"�׹��:D笪^�A�jh�E�%��(Y+1��`fq��f�ɠyu����|ӿ�0=G^�Ժ��q��?��}���j-�(=^@���W�t�˟x&
ֹ��Ʋ�e��D�
�����GQ0���q��`�*�-��xGH!�²B�K^��n���.��mVq���3XAz�հ�,�sUI�_��x�����(e�tP�}irdw���rl�׬Ի�5���jMs�'O˞��;A�Y [v�{Vk>38�uA��*����W`K۲���N�NK}�

d�
R{�k�#�C��c��w�f���V�ЧE����D*AԜiv��}��;�k��t���Ӓ1�:p4���°��T��Z0ƫ�:�zw�� �ؒ�R5������Wn��ZC55(D�	@XC�ּ4 N
  #�ڬY���JTy��w��(ǋQ�R�[��:���t��P�!��k]yx�\� ��:�h���*W^[*�Q|�uA�a=����>��ʞ�6�#�OPp�;��m����C�ך!'��XZ���b�.�#
�y����El�8Ad�j?��N�a-2������`0^��y(��l�=�N���K��Iw����O�s�m�"Q'�╱�Y���f�0��l�v
�r%E�'�~F��Se��>�r�%�z��f���%�YJe��qqq�H�Z+15=X[�Aϊݢ�[A�:|����@�:�
8��̮U�����y���Fs��RI����x?����sOU?W���gmY@&��:U�^}v#:=���l�`0~����lZ��)+�JZ4�ҦS.�'}5�}ͭ��}5@�f�UH=��h�Ԡ7ԢΩQ���@Y7�����^j���Jm�6I̓&Ċ
��E���M���l�^��3�bI��G�߬<�3�!(S���"�cVЕ�k�~�:b��Bo���(���/�2*�m�����l=��|�j�pR6�E_S���֥�}�D��x}��ٮ"��^���%����p��n�Qs��-]��~3I��>��DM�*K�Uf�+i��V��,��Y/e���=�c��.��4�]*�#vv��F�����-�;�[���dS�Eo�H�lj-� ���$�,����|w�*�����=��5j]�~�q�n��{cn�[�!B�7���7]�^k�ZM�m�	���Ě��`�&������5=��|X��YE~����ۿ�,�}N�S�ߙ��r�h`oB�̀:\��2"�t�����j���Xj�YFѸ(���-�7��|�Ro^@-?�tރV-n�N�kИ�ł�pD�y�ץ�DW��ǘ�{��jR��L۽�-�iZ9�y���g���36��lp�`|�k�]�A��u������Eӭ�*Y��4ݬV������9+�9
��D���J��D^[k����"�����Zth7]V��
a$�y�C����+c����C)��~>�=�d�����-V�̳�+�ϟb5IĻ��]��A��u�b��ζ��>��`�I��׀HSF��(u�[��d��#�,�����p�ʞ�c9X�Ty�T�*�e ��b����	}�q�n�4��x��>�ӷ���j����~��� �����U�����6_�"������e�e���Y�"k��<j�g�9�S����D7^��������Y��w��sF�^QƎ{��O-��8���~{?O�U��gM�N�%E��X�Ѱ���9|0�y�Ʌ��+�1ƫ�|�o��u���S@%&A�N�<$o~ ;G����k�>M��ܙ4ty��ՠ���]��������rSv�9��#F?�>ι�ŕ$���b�E%�a�Ε�^��%Yb��Ǌ��Ī�A�%�M§�*D��mf0��ٟ3��f%e��W�=����B����ZT-?X�j[��F�x��ar��y_�v���y�����xǆ�sv������w��-�-�~,�u[K>�ӑ������um\��`�j�u�����V�P�(,�U�%V�X �U�l
D�Rd
����V`���S�!?�p�/�4��5�C�tV�]�N��b����Wv�i�x�w�n�>�.��k�]wf�����]f��(�Y�>^�����J8�὇��Y-��B����)?�F9��ʰ̑i
�䕛���)���qu��ǳ7�}M�]o��U_#;l�k5ށ��?��I�m��|�r����Vײ�M�	���}nU�ޢ����k@\qb����`0^����%n�b�XJ�:���fM
����pl}�l��N�Ś�&bf��hj�C�Ykn�rkՒe�1	�n�ZR�E㢙R��K�1K<�`ʡ4�=��'�F1d�-E�]��V��l�����@�c�CQ*4�:Fe���Ƽi����x"�$��b��X¢-ճ۶m������;��cv��E��,{��>� 4�glJl��W�:���;�|�c=�H��}_uNr�͓Sm�H`I�8�s��"Ɣ�6̕���I`"�.?�L��r,��`�
Fur��QjeI󀧼�=���jJ�y~U(�{�.E����a�v�%J�Z\�#����h��r�'6��Y�!�S�VUNL^�5�]S��`0���Y�j�\�7.*���t����6�Y�%�MS	Y�,��ߍ�G��d��u��x��_����.�G�d��(�Cma0���f�,[�rㄏ�>�³Zܶ��f��ʉ�?���r�f��Ɗ�){�� ��
+���`�a�q�s��^�8b�aq1w�sZ�O�x��O��z�:��8f��,bS%���&�]����{�����q��һmX3��=V���]:��z\^�֨���n�2�j����m��61��ⱽ�n������k�3s�-�����o����������3�7֯�\7�vZ��`�*<�}3L��w,v��}n��vnՍ��m?�{�nٷ }���`0~\�L�p�9s���G���UgG�#~�e�	�ʣ�f%�Gb2��`0��`0��`0��`0��`0��`0��`0/��������o�����L�         :   x�3�472�500����q�R8�����G6��pdޑ�Fz`�i�i����� ��      !   )   x�3�4���t�34��3 .#�����L8F��� ���      #   &   x�3�N�(HT���+I�R�LI�I,:��+F��� ��	�      %      x������ � �      '      x������ � �      )   ?   x�34�����t�34�4�3 N(��М�$�����7AW`Q 2���ӄ=... �~�      -      x�3��472�500�4�35 �=... 9"      /      x������ � �      1      x������ � �      �      x������ � �      +   ^   x���q�	64��v��Sqt�qU04V�u;���P� 8c��,9�<����}B9��l ��]=�|��C�\#�P���qqq S=�     