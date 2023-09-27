PGDMP     
                      {            ths_erp    14.1    14.1 �   L           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            M           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            N           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            O           1262    140088    ths_erp    DATABASE     d   CREATE DATABASE ths_erp WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'Turkish_Turkey.1254';
    DROP DATABASE ths_erp;
             	   ths_admin    false            P           0    0    SCHEMA public    ACL     {   REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT CREATE ON SCHEMA public TO PUBLIC;
GRANT ALL ON SCHEMA public TO ths_admin;
                   postgres    false    8                        3079    140089    dblink 	   EXTENSION     :   CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;
    DROP EXTENSION dblink;
                   false            Q           0    0    EXTENSION dblink    COMMENT     _   COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';
                        false    2                        3079    140135    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                   false            R           0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                        false    3                        3079    140172 
   pgrowlocks 	   EXTENSION     >   CREATE EXTENSION IF NOT EXISTS pgrowlocks WITH SCHEMA public;
    DROP EXTENSION pgrowlocks;
                   false            S           0    0    EXTENSION pgrowlocks    COMMENT     I   COMMENT ON EXTENSION pgrowlocks IS 'show row-level locking information';
                        false    4                        3079    140174    pldbgapi 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pldbgapi WITH SCHEMA public;
    DROP EXTENSION pldbgapi;
                   false            T           0    0    EXTENSION pldbgapi    COMMENT     Y   COMMENT ON EXTENSION pldbgapi IS 'server-side support for debugging PL/pgSQL functions';
                        false    5                        3079    140211    postgres_fdw 	   EXTENSION     @   CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;
    DROP EXTENSION postgres_fdw;
                   false            U           0    0    EXTENSION postgres_fdw    COMMENT     [   COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';
                        false    6            V           0    0    FUNCTION armor(bytea)    ACL     8   GRANT ALL ON FUNCTION public.armor(bytea) TO ths_admin;
          public          postgres    false    503            W           0    0 %   FUNCTION armor(bytea, text[], text[])    ACL     H   GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO ths_admin;
          public          postgres    false    504                        1255    140218    audit()    FUNCTION       CREATE FUNCTION public.audit() RETURNS trigger
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
       public       	   ths_admin    false            X           0    0    FUNCTION audit()    ACL     i   REVOKE ALL ON FUNCTION public.audit() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.audit() FROM ths_admin;
          public       	   ths_admin    false    512            Y           0    0    FUNCTION crypt(text, text)    ACL     =   GRANT ALL ON FUNCTION public.crypt(text, text) TO ths_admin;
          public          postgres    false    513            Z           0    0    FUNCTION dearmor(text)    ACL     9   GRANT ALL ON FUNCTION public.dearmor(text) TO ths_admin;
          public          postgres    false    459            [           0    0 $   FUNCTION decrypt(bytea, bytea, text)    ACL     G   GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO ths_admin;
          public          postgres    false    514            \           0    0 .   FUNCTION decrypt_iv(bytea, bytea, bytea, text)    ACL     Q   GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO ths_admin;
          public          postgres    false    515            ]           0    0    FUNCTION digest(bytea, text)    ACL     ?   GRANT ALL ON FUNCTION public.digest(bytea, text) TO ths_admin;
          public          postgres    false    516            ^           0    0    FUNCTION digest(text, text)    ACL     >   GRANT ALL ON FUNCTION public.digest(text, text) TO ths_admin;
          public          postgres    false    432            _           0    0 $   FUNCTION encrypt(bytea, bytea, text)    ACL     G   GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO ths_admin;
          public          postgres    false    517            `           0    0 .   FUNCTION encrypt_iv(bytea, bytea, bytea, text)    ACL     Q   GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO ths_admin;
          public          postgres    false    435            a           0    0 "   FUNCTION gen_random_bytes(integer)    ACL     E   GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO ths_admin;
          public          postgres    false    436            b           0    0    FUNCTION gen_random_uuid()    ACL     =   GRANT ALL ON FUNCTION public.gen_random_uuid() TO ths_admin;
          public          postgres    false    518            c           0    0    FUNCTION gen_salt(text)    ACL     :   GRANT ALL ON FUNCTION public.gen_salt(text) TO ths_admin;
          public          postgres    false    519            d           0    0     FUNCTION gen_salt(text, integer)    ACL     C   GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO ths_admin;
          public          postgres    false    434            e           0    0 !   FUNCTION hmac(bytea, bytea, text)    ACL     D   GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO ths_admin;
          public          postgres    false    520            f           0    0    FUNCTION hmac(text, text, text)    ACL     B   GRANT ALL ON FUNCTION public.hmac(text, text, text) TO ths_admin;
          public          postgres    false    433            �           1255    140219    personel_adsoyad()    FUNCTION     ]  CREATE FUNCTION public.personel_adsoyad() RETURNS trigger
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
       public       	   ths_admin    false            g           0    0    FUNCTION personel_adsoyad()    ACL        REVOKE ALL ON FUNCTION public.personel_adsoyad() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.personel_adsoyad() FROM ths_admin;
          public       	   ths_admin    false    490            h           0    0 >   FUNCTION pgp_armor_headers(text, OUT key text, OUT value text)    ACL     a   GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO ths_admin;
          public          postgres    false    521            i           0    0    FUNCTION pgp_key_id(bytea)    ACL     =   GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO ths_admin;
          public          postgres    false    460            j           0    0 &   FUNCTION pgp_pub_decrypt(bytea, bytea)    ACL     I   GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO ths_admin;
          public          postgres    false    461            k           0    0 ,   FUNCTION pgp_pub_decrypt(bytea, bytea, text)    ACL     O   GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO ths_admin;
          public          postgres    false    462            l           0    0 2   FUNCTION pgp_pub_decrypt(bytea, bytea, text, text)    ACL     U   GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO ths_admin;
          public          postgres    false    463            m           0    0 ,   FUNCTION pgp_pub_decrypt_bytea(bytea, bytea)    ACL     O   GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO ths_admin;
          public          postgres    false    464            n           0    0 2   FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text)    ACL     U   GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO ths_admin;
          public          postgres    false    465            o           0    0 8   FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text)    ACL     [   GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO ths_admin;
          public          postgres    false    466            p           0    0 %   FUNCTION pgp_pub_encrypt(text, bytea)    ACL     H   GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO ths_admin;
          public          postgres    false    522            q           0    0 +   FUNCTION pgp_pub_encrypt(text, bytea, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO ths_admin;
          public          postgres    false    523            r           0    0 ,   FUNCTION pgp_pub_encrypt_bytea(bytea, bytea)    ACL     O   GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO ths_admin;
          public          postgres    false    451            s           0    0 2   FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text)    ACL     U   GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO ths_admin;
          public          postgres    false    467            t           0    0 %   FUNCTION pgp_sym_decrypt(bytea, text)    ACL     H   GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO ths_admin;
          public          postgres    false    524            u           0    0 +   FUNCTION pgp_sym_decrypt(bytea, text, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO ths_admin;
          public          postgres    false    525            v           0    0 +   FUNCTION pgp_sym_decrypt_bytea(bytea, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO ths_admin;
          public          postgres    false    440            w           0    0 1   FUNCTION pgp_sym_decrypt_bytea(bytea, text, text)    ACL     T   GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO ths_admin;
          public          postgres    false    441            x           0    0 $   FUNCTION pgp_sym_encrypt(text, text)    ACL     G   GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO ths_admin;
          public          postgres    false    442            y           0    0 *   FUNCTION pgp_sym_encrypt(text, text, text)    ACL     M   GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO ths_admin;
          public          postgres    false    526            z           0    0 +   FUNCTION pgp_sym_encrypt_bytea(bytea, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO ths_admin;
          public          postgres    false    443            {           0    0 1   FUNCTION pgp_sym_encrypt_bytea(bytea, text, text)    ACL     T   GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO ths_admin;
          public          postgres    false    444            |           0    0 �   FUNCTION pgrowlocks(relname text, OUT locked_row tid, OUT locker xid, OUT multi boolean, OUT xids xid[], OUT modes text[], OUT pids integer[])    ACL     �   GRANT ALL ON FUNCTION public.pgrowlocks(relname text, OUT locked_row tid, OUT locker xid, OUT multi boolean, OUT xids xid[], OUT modes text[], OUT pids integer[]) TO ths_admin;
          public          postgres    false    527            }           0    0    FUNCTION postgres_fdw_handler()    ACL     B   GRANT ALL ON FUNCTION public.postgres_fdw_handler() TO ths_admin;
          public          postgres    false    486            ~           0    0 ,   FUNCTION postgres_fdw_validator(text[], oid)    ACL     O   GRANT ALL ON FUNCTION public.postgres_fdw_validator(text[], oid) TO ths_admin;
          public          postgres    false    487            �           1255    140220    spexists_hesap_kodu(text)    FUNCTION     0  CREATE FUNCTION public.spexists_hesap_kodu(phesap_kodu text) RETURNS boolean
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
 <   DROP FUNCTION public.spexists_hesap_kodu(phesap_kodu text);
       public          postgres    false                       0    0 .   FUNCTION spexists_hesap_kodu(phesap_kodu text)    ACL     �   REVOKE ALL ON FUNCTION public.spexists_hesap_kodu(phesap_kodu text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spexists_hesap_kodu(phesap_kodu text) TO ths_admin;
          public          postgres    false    488            �           1255    140221    spget_crypted_data(text)    FUNCTION     �   CREATE FUNCTION public.spget_crypted_data(pval text) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
	vval text;
begin
	SELECT crypt(pval, gen_salt('md5')) INTO vval;
	Return vval;
end
$$;
 4   DROP FUNCTION public.spget_crypted_data(pval text);
       public          postgres    false            �           0    0 &   FUNCTION spget_crypted_data(pval text)    ACL     I   GRANT ALL ON FUNCTION public.spget_crypted_data(pval text) TO ths_admin;
          public          postgres    false    489            �           1255    140222 /   spget_lang_text(text, text, text, bigint, text)    FUNCTION     �  CREATE FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) RETURNS character varying
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
       public          postgres    false            �           0    0 n   FUNCTION spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text)    ACL     "  REVOKE ALL ON FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) TO ths_admin;
          public          postgres    false    491            �           1255    140223 -   spget_lang_text(text, text, text, text, text)    FUNCTION     �  CREATE FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) RETURNS character varying
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
       public          postgres    false            �           0    0 n   FUNCTION spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text)    ACL     "  REVOKE ALL ON FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) TO ths_admin;
          public          postgres    false    493            �           1255    140224    spget_prs_personel_id_list()    FUNCTION     j  CREATE FUNCTION public.spget_prs_personel_id_list() RETURNS TABLE(id integer, emp_name character varying, emp_surname character varying, emp_full_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
		SELECT  prs_personel.id, prs_personel.ad, prs_personel.soyad, prs_personel.ad_soyad FROM prs_personel
		WHERE is_aktif ORDER BY 4;
END
$$;
 3   DROP FUNCTION public.spget_prs_personel_id_list();
       public          postgres    false            �           0    0 %   FUNCTION spget_prs_personel_id_list()    ACL     �   REVOKE ALL ON FUNCTION public.spget_prs_personel_id_list() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_prs_personel_id_list() TO ths_admin;
          public          postgres    false    494            �           1255    140225 "   spget_rct_hammadde_maliyet(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) RETURNS numeric
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
 H   DROP FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint);
       public          postgres    false            �           0    0 :   FUNCTION spget_rct_hammadde_maliyet(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    492            �           1255    140226 !   spget_rct_iscilik_maliyet(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) RETURNS numeric
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
 G   DROP FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint);
       public          postgres    false            �           0    0 9   FUNCTION spget_rct_iscilik_maliyet(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    495            �           1255    140227    spget_rct_toplam(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_toplam(prct_recete_id bigint) RETURNS numeric
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
       public          postgres    false            �           0    0 0   FUNCTION spget_rct_toplam(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_toplam(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_toplam(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    496            �           1255    140228 "   spget_rct_yan_urun_maliyet(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) RETURNS numeric
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
 H   DROP FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint);
       public          postgres    false            �           0    0 :   FUNCTION spget_rct_yan_urun_maliyet(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    497            �           1255    140229 &   spget_sys_kalite_form_no(text, bigint)    FUNCTION     I  CREATE FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) RETURNS character varying
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
       public          postgres    false            �           0    0 H   FUNCTION spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) TO ths_admin;
          public          postgres    false    498            �           1255    140230    spget_sys_lang_id(text)    FUNCTION     �   CREATE FUNCTION public.spget_sys_lang_id(planguage text) RETURNS integer
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
       public          postgres    false            �           0    0 *   FUNCTION spget_sys_lang_id(planguage text)    ACL     �   REVOKE ALL ON FUNCTION public.spget_sys_lang_id(planguage text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_sys_lang_id(planguage text) TO ths_admin;
          public          postgres    false    499            �           1255    140231 '   spget_sys_quality_form_type_id(integer)    FUNCTION     �  CREATE FUNCTION public.spget_sys_quality_form_type_id(ptype integer) RETURNS integer
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
       public          postgres    false            �           0    0 6   FUNCTION spget_sys_quality_form_type_id(ptype integer)    ACL     Y   GRANT ALL ON FUNCTION public.spget_sys_quality_form_type_id(ptype integer) TO ths_admin;
          public          postgres    false    505            �           1255    140232    spget_sys_user_id_list()    FUNCTION       CREATE FUNCTION public.spget_sys_user_id_list() RETURNS TABLE(id bigint, user_name character varying)
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
 /   DROP FUNCTION public.spget_sys_user_id_list();
       public       	   ths_admin    false            �           0    0 !   FUNCTION spget_sys_user_id_list()    ACL     D   REVOKE ALL ON FUNCTION public.spget_sys_user_id_list() FROM PUBLIC;
          public       	   ths_admin    false    506                       1255    140233 1   spget_year_week(date, character varying, boolean)    FUNCTION     �  CREATE FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean DEFAULT true) RETURNS character varying
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
 g   DROP FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean);
       public          postgres    false            �           0    0 Y   FUNCTION spget_year_week(pdate date, pseparate character varying, pis_year_first boolean)    ACL     �   REVOKE ALL ON FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean) TO ths_admin;
          public          postgres    false    528            �           1255    140234    splogin(text, text, text, text)    FUNCTION     �  CREATE FUNCTION public.splogin(puser_name text, puser_pass text, papp_version text, pmac_address text) RETURNS integer
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
 f   DROP FUNCTION public.splogin(puser_name text, puser_pass text, papp_version text, pmac_address text);
       public       	   ths_admin    false            �           1255    140235 (   spset_user_password(text, text, integer)    FUNCTION       CREATE FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) RETURNS boolean
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
 V   DROP FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer);
       public          postgres    false            �           0    0 H   FUNCTION spset_user_password(oldpass text, newpass text, userid integer)    ACL     �   REVOKE ALL ON FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) TO ths_admin;
          public          postgres    false    507            �           1255    140236    spvarsayilan_para_birimi()    FUNCTION     �   CREATE FUNCTION public.spvarsayilan_para_birimi() RETURNS character varying
    LANGUAGE sql
    AS $$
	SELECT para_birimi FROM sys_para_birimi WHERE is_varsayilan LIMIT 1;
$$;
 1   DROP FUNCTION public.spvarsayilan_para_birimi();
       public          postgres    false            �           0    0 #   FUNCTION spvarsayilan_para_birimi()    ACL     �   REVOKE ALL ON FUNCTION public.spvarsayilan_para_birimi() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spvarsayilan_para_birimi() TO ths_admin;
          public          postgres    false    508            �           1255    140237    spvarsayilan_urun_tipi_id()    FUNCTION     �   CREATE FUNCTION public.spvarsayilan_urun_tipi_id() RETURNS integer
    LANGUAGE sql
    AS $$
	SELECT id FROM set_stk_urun_tipi WHERE urun_tipi='HAMMADDE';
$$;
 2   DROP FUNCTION public.spvarsayilan_urun_tipi_id();
       public          postgres    false            �           0    0 $   FUNCTION spvarsayilan_urun_tipi_id()    ACL     �   REVOKE ALL ON FUNCTION public.spvarsayilan_urun_tipi_id() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spvarsayilan_urun_tipi_id() TO ths_admin;
          public          postgres    false    509            �           1255    140238    table_listen(text)    FUNCTION     �   CREATE FUNCTION public.table_listen(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT listen table_name;
  RETURN;
END;
$$;
 4   DROP FUNCTION public.table_listen(table_name text);
       public          postgres    false            �           0    0 &   FUNCTION table_listen(table_name text)    ACL     �   REVOKE ALL ON FUNCTION public.table_listen(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_listen(table_name text) TO ths_admin;
          public          postgres    false    511            �           1255    140239    table_notify()    FUNCTION     �  CREATE FUNCTION public.table_notify() RETURNS trigger
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
       public       	   ths_admin    false            �           0    0    FUNCTION table_notify()    ACL     w   REVOKE ALL ON FUNCTION public.table_notify() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.table_notify() FROM ths_admin;
          public       	   ths_admin    false    500            �           1255    140240    table_notify(text)    FUNCTION     �   CREATE FUNCTION public.table_notify(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT notify table_name;
  RETURN;
END;
$$;
 4   DROP FUNCTION public.table_notify(table_name text);
       public          postgres    false            �           0    0 &   FUNCTION table_notify(table_name text)    ACL     �   REVOKE ALL ON FUNCTION public.table_notify(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_notify(table_name text) TO ths_admin;
          public          postgres    false    510            �           1255    140241    table_unlisten(text)    FUNCTION     �   CREATE FUNCTION public.table_unlisten(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT unlisten table_name;
  RETURN;
END;
$$;
 6   DROP FUNCTION public.table_unlisten(table_name text);
       public          postgres    false            �           0    0 (   FUNCTION table_unlisten(table_name text)    ACL     �   REVOKE ALL ON FUNCTION public.table_unlisten(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_unlisten(table_name text) TO ths_admin;
          public          postgres    false    502            �            1259    140242    a_invoices_id_seq    SEQUENCE     z   CREATE SEQUENCE public.a_invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.a_invoices_id_seq;
       public          postgres    false            �            1259    140243    als_teklif_detaylari    TABLE     �  CREATE TABLE public.als_teklif_detaylari (
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
       public         heap 	   ths_admin    false            �            1259    140259    als_teklif_detaylari_id_seq    SEQUENCE     �   ALTER TABLE public.als_teklif_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.als_teklif_detaylari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    221            �            1259    140260    als_teklifler    TABLE     �  CREATE TABLE public.als_teklifler (
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
       public         heap 	   ths_admin    false            �            1259    140281    als_teklifler_id_seq    SEQUENCE     �   ALTER TABLE public.als_teklifler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.als_teklifler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    223            �            1259    140282    audits    TABLE     �  CREATE TABLE public.audits (
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
       public         heap 	   ths_admin    false            �            1259    140287    audit_id_seq    SEQUENCE     �   ALTER TABLE public.audits ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    225            �            1259    140288    ch_bankalar    TABLE     �   CREATE TABLE public.ch_bankalar (
    id bigint NOT NULL,
    banka_adi character varying(64) NOT NULL,
    swift_kodu character varying(16)
);
    DROP TABLE public.ch_bankalar;
       public         heap 	   ths_admin    false            �            1259    140291    ch_banka_id_seq    SEQUENCE     �   ALTER TABLE public.ch_bankalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_banka_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    227            �            1259    140292    ch_banka_subeleri    TABLE     �   CREATE TABLE public.ch_banka_subeleri (
    id bigint NOT NULL,
    banka_id bigint NOT NULL,
    sube_kodu integer NOT NULL,
    sube_adi character varying(64) NOT NULL,
    sehir_id bigint NOT NULL
);
 %   DROP TABLE public.ch_banka_subeleri;
       public         heap 	   ths_admin    false            �            1259    140295    ch_banka_subesi_id_seq    SEQUENCE     �   ALTER TABLE public.ch_banka_subeleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_banka_subesi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    229            �            1259    140296    ch_bolgeler    TABLE     f   CREATE TABLE public.ch_bolgeler (
    id bigint NOT NULL,
    bolge character varying(32) NOT NULL
);
    DROP TABLE public.ch_bolgeler;
       public         heap 	   ths_admin    false            �            1259    140299    ch_bolge_id_seq    SEQUENCE     �   ALTER TABLE public.ch_bolgeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_bolge_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    231            �            1259    140300    ch_doviz_kurlari    TABLE     �   CREATE TABLE public.ch_doviz_kurlari (
    id bigint NOT NULL,
    kur_tarihi date NOT NULL,
    kur numeric(10,4) NOT NULL,
    para character varying(3)
);
 $   DROP TABLE public.ch_doviz_kurlari;
       public         heap 	   ths_admin    false            �            1259    140303 
   ch_gruplar    TABLE     d   CREATE TABLE public.ch_gruplar (
    id bigint NOT NULL,
    grup character varying(16) NOT NULL
);
    DROP TABLE public.ch_gruplar;
       public         heap 	   ths_admin    false            �            1259    140306    ch_hesaplar    TABLE     �  CREATE TABLE public.ch_hesaplar (
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
    DROP TABLE public.ch_hesaplar;
       public         heap 	   ths_admin    false            �            1259    140314    ch_hesap_karti_id_seq    SEQUENCE     �   ALTER TABLE public.ch_hesaplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_hesap_karti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    235            �            1259    140315    ch_hesap_planlari    TABLE     �   CREATE TABLE public.ch_hesap_planlari (
    id bigint NOT NULL,
    plan_kodu character varying(16) NOT NULL,
    plan_adi character varying(128) NOT NULL,
    seviye smallint NOT NULL
);
 %   DROP TABLE public.ch_hesap_planlari;
       public         heap 	   ths_admin    false            �            1259    140318    mhs_doviz_kuru_id_seq    SEQUENCE     �   ALTER TABLE public.ch_doviz_kurlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_doviz_kuru_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    233            �            1259    140319    mhs_fis_detaylari    TABLE     a   CREATE TABLE public.mhs_fis_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL
);
 %   DROP TABLE public.mhs_fis_detaylari;
       public         heap 	   ths_admin    false            �            1259    140322    mhs_fis_detaylari_id_seq    SEQUENCE     �   ALTER TABLE public.mhs_fis_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_fis_detaylari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    239            �            1259    140323 
   mhs_fisler    TABLE     u   CREATE TABLE public.mhs_fisler (
    id bigint NOT NULL,
    yevmiye_no integer NOT NULL,
    yevmiye_tarihi date
);
    DROP TABLE public.mhs_fisler;
       public         heap 	   ths_admin    false            �            1259    140326    mhs_fisler_id_seq    SEQUENCE     �   ALTER TABLE public.mhs_fisler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_fisler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    241            �            1259    140327    mhs_transfer_kodlari    TABLE     �   CREATE TABLE public.mhs_transfer_kodlari (
    id bigint NOT NULL,
    transfer_kodu character varying(32) NOT NULL,
    aciklama character varying(128) NOT NULL,
    hesap_kodu character varying(16) NOT NULL
);
 (   DROP TABLE public.mhs_transfer_kodlari;
       public         heap 	   ths_admin    false            �            1259    140330    mhs_transfer_kodlari_id_seq    SEQUENCE     �   ALTER TABLE public.mhs_transfer_kodlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_transfer_kodlari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    243            �            1259    140331    prs_ehliyetler    TABLE     n   CREATE TABLE public.prs_ehliyetler (
    id bigint NOT NULL,
    ehliyet_id bigint,
    personel_id bigint
);
 "   DROP TABLE public.prs_ehliyetler;
       public         heap 	   ths_admin    false            �            1259    140334    prs_lisan_bilgileri    TABLE     �   CREATE TABLE public.prs_lisan_bilgileri (
    id bigint NOT NULL,
    lisan_id bigint,
    okuma_id bigint,
    yazma_id bigint,
    konusma_id bigint,
    personel_id bigint
);
 '   DROP TABLE public.prs_lisan_bilgileri;
       public         heap 	   ths_admin    false            �            1259    140337    prs_lisan_bilgisi_id_seq    SEQUENCE     �   ALTER TABLE public.prs_lisan_bilgileri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_lisan_bilgisi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    246            �            1259    140338    prs_personel_ehliyetleri_id_seq    SEQUENCE     �   ALTER TABLE public.prs_ehliyetler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_personel_ehliyetleri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    245            �            1259    140339    prs_personeller    TABLE     �  CREATE TABLE public.prs_personeller (
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
       public         heap 	   ths_admin    false            �           0    0    COLUMN prs_personeller.cinsiyet    COMMENT     F   COMMENT ON COLUMN public.prs_personeller.cinsiyet IS '1 Man
2 Woman';
          public       	   ths_admin    false    249            �           0    0 &   COLUMN prs_personeller.askerlik_durumu    COMMENT     e   COMMENT ON COLUMN public.prs_personeller.askerlik_durumu IS '1 Yapti, 2 Yapmadi, 3 Tecilli, 4 Muaf';
          public       	   ths_admin    false    249            �           0    0 #   COLUMN prs_personeller.medeni_durum    COMMENT     L   COMMENT ON COLUMN public.prs_personeller.medeni_durum IS '1 Evli, 2 Bekar';
          public       	   ths_admin    false    249            �            1259    140349    prs_personel_id_seq    SEQUENCE     �   ALTER TABLE public.prs_personeller ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_personel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    249            �            1259    140350    urt_iscilikler    TABLE     �   CREATE TABLE public.urt_iscilikler (
    id bigint NOT NULL,
    gider_kodu character varying(16) NOT NULL,
    gider_adi character varying(128),
    fiyat numeric(18,6) NOT NULL,
    birim_id bigint NOT NULL,
    gider_tipi smallint NOT NULL
);
 "   DROP TABLE public.urt_iscilikler;
       public         heap 	   ths_admin    false            �            1259    140353    rct_iscilik_gideri_id_seq    SEQUENCE     �   ALTER TABLE public.urt_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_iscilik_gideri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    251            �            1259    140354    urt_paket_hammadde_detaylari    TABLE     �   CREATE TABLE public.urt_paket_hammadde_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    recete_id bigint,
    stok_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 0   DROP TABLE public.urt_paket_hammadde_detaylari;
       public         heap 	   ths_admin    false            �            1259    140357    rct_paket_hammadde_detay_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_hammadde_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_hammadde_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    253            �            1259    140358    urt_paket_hammaddeler    TABLE     u   CREATE TABLE public.urt_paket_hammaddeler (
    id bigint NOT NULL,
    paket_adi character varying(128) NOT NULL
);
 )   DROP TABLE public.urt_paket_hammaddeler;
       public         heap 	   ths_admin    false                        1259    140361    rct_paket_hammadde_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    255                       1259    140362    urt_paket_iscilik_detaylari    TABLE     �   CREATE TABLE public.urt_paket_iscilik_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    iscilik_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 /   DROP TABLE public.urt_paket_iscilik_detaylari;
       public         heap 	   ths_admin    false                       1259    140365    rct_paket_iscilik_detay_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_iscilik_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_iscilik_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    257                       1259    140366    urt_paket_iscilikler    TABLE     t   CREATE TABLE public.urt_paket_iscilikler (
    id bigint NOT NULL,
    paket_adi character varying(128) NOT NULL
);
 (   DROP TABLE public.urt_paket_iscilikler;
       public         heap 	   ths_admin    false                       1259    140369    rct_paket_iscilik_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    259                       1259    140370    urt_recete_hammaddeler    TABLE     �   CREATE TABLE public.urt_recete_hammaddeler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    recete_id bigint,
    stok_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL,
    fire_orani numeric(18,6) DEFAULT 0 NOT NULL
);
 *   DROP TABLE public.urt_recete_hammaddeler;
       public         heap 	   ths_admin    false                       1259    140374    rct_recete_hammadde_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    261                       1259    140375    urt_receteler    TABLE     �   CREATE TABLE public.urt_receteler (
    id bigint NOT NULL,
    urun_kodu character varying(32) NOT NULL,
    urun_adi character varying(128) NOT NULL,
    ornek_miktari numeric(18,6) DEFAULT 1,
    aciklama character varying(128)
);
 !   DROP TABLE public.urt_receteler;
       public         heap 	   ths_admin    false                       1259    140379    rct_recete_id_seq    SEQUENCE     �   ALTER TABLE public.urt_receteler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    263            	           1259    140380    urt_recete_iscilikler    TABLE     �   CREATE TABLE public.urt_recete_iscilikler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    iscilik_kodu character varying(16) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 )   DROP TABLE public.urt_recete_iscilikler;
       public         heap 	   ths_admin    false            
           1259    140383    rct_recete_iscilik_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    265                       1259    140384    urt_recete_paket_hammaddeler    TABLE     �   CREATE TABLE public.urt_recete_paket_hammaddeler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    paket_id bigint NOT NULL,
    miktar numeric(18,6)
);
 0   DROP TABLE public.urt_recete_paket_hammaddeler;
       public         heap 	   ths_admin    false                       1259    140387     rct_recete_paket_hammadde_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_paket_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_paket_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    267                       1259    140388    urt_recete_paket_iscilikler    TABLE     �   CREATE TABLE public.urt_recete_paket_iscilikler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    paket_id bigint NOT NULL,
    miktar numeric(18,6)
);
 /   DROP TABLE public.urt_recete_paket_iscilikler;
       public         heap 	   ths_admin    false                       1259    140391    rct_recete_paket_iscilik_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_paket_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_paket_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    269                       1259    140392    sat_fatura_detaylari    TABLE     �   CREATE TABLE public.sat_fatura_detaylari (
    id bigint NOT NULL,
    header_id bigint,
    teklif_detay_id bigint,
    siparis_detay_id bigint,
    irsaliye_detay_id bigint
);
 (   DROP TABLE public.sat_fatura_detaylari;
       public         heap 	   ths_admin    false                       1259    140395    sat_fatura_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_fatura_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_fatura_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    271                       1259    140396    sat_faturalar    TABLE     �   CREATE TABLE public.sat_faturalar (
    id bigint NOT NULL,
    fatura_no character varying(16),
    fatura_tarihi timestamp without time zone,
    teklif_id bigint,
    siparis_id bigint,
    irsaliye_id bigint
);
 !   DROP TABLE public.sat_faturalar;
       public         heap 	   ths_admin    false                       1259    140399    sat_fatura_id_seq    SEQUENCE     �   ALTER TABLE public.sat_faturalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_fatura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    273                       1259    140400    sat_irsaliye_detaylari    TABLE     �   CREATE TABLE public.sat_irsaliye_detaylari (
    id bigint NOT NULL,
    header_id bigint,
    teklif_detay_id bigint,
    siparis_detay_id bigint,
    fatura_detay_id bigint
);
 *   DROP TABLE public.sat_irsaliye_detaylari;
       public         heap 	   ths_admin    false                       1259    140403    sat_irsaliye_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_irsaliye_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_irsaliye_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    275                       1259    140404    sat_irsaliyeler    TABLE     �   CREATE TABLE public.sat_irsaliyeler (
    id bigint NOT NULL,
    irsaliye_no character varying(16),
    irsaliye_tarihi timestamp without time zone,
    teklif_id bigint,
    siparis_id bigint,
    fatura_id bigint
);
 #   DROP TABLE public.sat_irsaliyeler;
       public         heap 	   ths_admin    false                       1259    140407    sat_irsaliye_id_seq    SEQUENCE     �   ALTER TABLE public.sat_irsaliyeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_irsaliye_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    277                       1259    140408    sat_siparis_detaylari    TABLE     �  CREATE TABLE public.sat_siparis_detaylari (
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
       public         heap 	   ths_admin    false                       1259    140431    sat_siparis_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_siparis_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_siparis_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    279                       1259    140432    sat_siparisler    TABLE     �  CREATE TABLE public.sat_siparisler (
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
       public         heap 	   ths_admin    false                       1259    140453    sat_siparis_id_seq    SEQUENCE     �   ALTER TABLE public.sat_siparisler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_siparis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    281                       1259    140454    set_sls_order_status    TABLE     �   CREATE TABLE public.set_sls_order_status (
    id bigint NOT NULL,
    siparis_durum character varying(32) NOT NULL,
    aciklama character varying(64)
);
 (   DROP TABLE public.set_sls_order_status;
       public         heap 	   ths_admin    false                       1259    140457    stk_gruplar    TABLE     +  CREATE TABLE public.stk_gruplar (
    id bigint NOT NULL,
    grup character varying(32) NOT NULL,
    kdv_orani double precision NOT NULL,
    hammadde_stok_hesap_kodu character varying(16),
    hammadde_kullanim_hesap_kodu character varying(16),
    yari_mamul_hesap_kodu character varying(16)
);
    DROP TABLE public.stk_gruplar;
       public         heap 	   ths_admin    false                       1259    140460    stk_kartlar    TABLE     
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
       public         heap 	   ths_admin    false    509    508    508    508                       1259    140481    sys_sehirler    TABLE     �   CREATE TABLE public.sys_sehirler (
    id bigint NOT NULL,
    sehir character varying(32) NOT NULL,
    plaka_kodu integer,
    ulke_id bigint,
    bolge_id bigint
);
     DROP TABLE public.sys_sehirler;
       public         heap 	   ths_admin    false                       1259    140484    sat_siparis_rapor    VIEW     )  CREATE VIEW public.sat_siparis_rapor AS
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
       public       	   ths_admin    false    281    286    286    285    285    284    284    283    283    281    281    281    281    281    281    281    281    281    279    279    279    279    279    279    279                        1259    140489    sat_teklif_detaylari    TABLE     �  CREATE TABLE public.sat_teklif_detaylari (
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
       public         heap 	   ths_admin    false            !           1259    140505    sat_teklif_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_teklif_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_teklif_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    288            "           1259    140506    sat_teklifler    TABLE     y  CREATE TABLE public.sat_teklifler (
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
       public         heap 	   ths_admin    false            #           1259    140527    sat_teklif_id_seq    SEQUENCE     �   ALTER TABLE public.sat_teklifler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_teklif_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    290            $           1259    140528    set_ch_firma_tipleri    TABLE     �   CREATE TABLE public.set_ch_firma_tipleri (
    id bigint NOT NULL,
    firma_turu_id bigint NOT NULL,
    firma_tipi character varying(48) NOT NULL
);
 (   DROP TABLE public.set_ch_firma_tipleri;
       public         heap 	   ths_admin    false            %           1259    140531    set_ch_firma_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_firma_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_firma_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    292            &           1259    140532    set_ch_firma_turleri    TABLE     t   CREATE TABLE public.set_ch_firma_turleri (
    id bigint NOT NULL,
    firma_turu character varying(32) NOT NULL
);
 (   DROP TABLE public.set_ch_firma_turleri;
       public         heap 	   ths_admin    false            '           1259    140535    set_ch_firma_turu_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_firma_turleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_firma_turu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    294            (           1259    140536    set_ch_grup_id_seq    SEQUENCE     �   ALTER TABLE public.ch_gruplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_grup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    234            )           1259    140537    set_ch_hesap_plani_id_seq    SEQUENCE     �   ALTER TABLE public.ch_hesap_planlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_hesap_plani_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    237            *           1259    140538    set_ch_hesap_tipleri    TABLE     t   CREATE TABLE public.set_ch_hesap_tipleri (
    id bigint NOT NULL,
    hesap_tipi character varying(16) NOT NULL
);
 (   DROP TABLE public.set_ch_hesap_tipleri;
       public         heap 	   ths_admin    false            +           1259    140541    set_ch_hesap_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_hesap_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_hesap_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    298            ,           1259    140542    set_ch_vergi_oranlari    TABLE     I  CREATE TABLE public.set_ch_vergi_oranlari (
    id bigint NOT NULL,
    vergi_orani numeric(5,2) NOT NULL,
    satis_hesap_kodu character varying(16) NOT NULL,
    satis_iade_hesap_kodu character varying(16) NOT NULL,
    alis_hesap_kodu character varying(16) NOT NULL,
    alis_iade_hesap_kodu character varying(16) NOT NULL
);
 )   DROP TABLE public.set_ch_vergi_oranlari;
       public         heap 	   ths_admin    false            -           1259    140545    set_ch_vergi_orani_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_vergi_oranlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_vergi_orani_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    300            .           1259    140546    set_einv_fatura_tipleri    TABLE     x   CREATE TABLE public.set_einv_fatura_tipleri (
    id bigint NOT NULL,
    fatura_tipi character varying(32) NOT NULL
);
 +   DROP TABLE public.set_einv_fatura_tipleri;
       public         heap 	   ths_admin    false            /           1259    140549    set_einv_fatura_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_fatura_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_fatura_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    302            0           1259    140550    set_einv_odeme_sekilleri    TABLE     �   CREATE TABLE public.set_einv_odeme_sekilleri (
    id bigint NOT NULL,
    odeme_sekli character varying(96),
    kod character varying(16),
    aciklama character varying(512),
    is_efatura boolean DEFAULT false
);
 ,   DROP TABLE public.set_einv_odeme_sekilleri;
       public         heap 	   ths_admin    false            1           1259    140556    set_einv_odeme_sekli_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_odeme_sekilleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_odeme_sekli_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    304            2           1259    140557    set_einv_paket_tipleri    TABLE     �   CREATE TABLE public.set_einv_paket_tipleri (
    id bigint NOT NULL,
    kod character varying(2),
    paket_tipi character varying(128),
    aciklama character varying(512)
);
 *   DROP TABLE public.set_einv_paket_tipleri;
       public         heap 	   ths_admin    false            3           1259    140562    set_einv_paket_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_paket_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_paket_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    306            4           1259    140563    set_einv_tasima_ucretleri    TABLE     s   CREATE TABLE public.set_einv_tasima_ucretleri (
    id bigint NOT NULL,
    tasima_ucreti character varying(16)
);
 -   DROP TABLE public.set_einv_tasima_ucretleri;
       public         heap 	   ths_admin    false            5           1259    140566    set_einv_tasima_ucreti_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_tasima_ucretleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_tasima_ucreti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    308            6           1259    140567    set_einv_teslim_sekilleri    TABLE     �   CREATE TABLE public.set_einv_teslim_sekilleri (
    id bigint NOT NULL,
    teslim_sekli character varying(16) NOT NULL,
    aciklama character varying(96) NOT NULL,
    is_efatura boolean DEFAULT false
);
 -   DROP TABLE public.set_einv_teslim_sekilleri;
       public         heap 	   ths_admin    false            7           1259    140571    set_einv_teslim_sekli_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_teslim_sekilleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_teslim_sekli_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    310            8           1259    140572    set_prs_birimler    TABLE     �   CREATE TABLE public.set_prs_birimler (
    id bigint NOT NULL,
    birim character varying(32) NOT NULL,
    bolum_id bigint
);
 $   DROP TABLE public.set_prs_birimler;
       public         heap 	   ths_admin    false            9           1259    140575    set_prs_birim_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_birimler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_birim_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    312            :           1259    140576    set_prs_bolumler    TABLE     k   CREATE TABLE public.set_prs_bolumler (
    id bigint NOT NULL,
    bolum character varying(32) NOT NULL
);
 $   DROP TABLE public.set_prs_bolumler;
       public         heap 	   ths_admin    false            ;           1259    140579    set_prs_bolum_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_bolumler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_bolum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    314            <           1259    140580    set_prs_ehliyetler    TABLE     o   CREATE TABLE public.set_prs_ehliyetler (
    id bigint NOT NULL,
    ehliyet character varying(32) NOT NULL
);
 &   DROP TABLE public.set_prs_ehliyetler;
       public         heap 	   ths_admin    false            =           1259    140583    set_prs_ehliyet_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_ehliyetler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_ehliyet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    316            >           1259    140584    set_prs_gorevler    TABLE     k   CREATE TABLE public.set_prs_gorevler (
    id bigint NOT NULL,
    gorev character varying(32) NOT NULL
);
 $   DROP TABLE public.set_prs_gorevler;
       public         heap 	   ths_admin    false            ?           1259    140587    set_prs_gorev_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_gorevler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_gorev_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    318            @           1259    140588    set_prs_lisanlar    TABLE     k   CREATE TABLE public.set_prs_lisanlar (
    id bigint NOT NULL,
    lisan character varying(16) NOT NULL
);
 $   DROP TABLE public.set_prs_lisanlar;
       public         heap 	   ths_admin    false            A           1259    140591    set_prs_lisan_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_lisanlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_lisan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    320            B           1259    140592    set_prs_lisan_seviyeleri    TABLE     |   CREATE TABLE public.set_prs_lisan_seviyeleri (
    id bigint NOT NULL,
    lisan_seviyesi character varying(16) NOT NULL
);
 ,   DROP TABLE public.set_prs_lisan_seviyeleri;
       public         heap 	   ths_admin    false            C           1259    140595    set_prs_lisan_seviyesi_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_lisan_seviyeleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_lisan_seviyesi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    322            D           1259    140596    set_prs_personel_tipleri    TABLE     {   CREATE TABLE public.set_prs_personel_tipleri (
    id bigint NOT NULL,
    personel_tipi character varying(32) NOT NULL
);
 ,   DROP TABLE public.set_prs_personel_tipleri;
       public         heap 	   ths_admin    false            E           1259    140599    set_prs_personel_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_personel_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_personel_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    324            F           1259    140600    set_prs_tasima_servisleri    TABLE     �   CREATE TABLE public.set_prs_tasima_servisleri (
    id bigint NOT NULL,
    arac_no smallint NOT NULL,
    arac_adi character varying(32) NOT NULL,
    rota double precision[]
);
 -   DROP TABLE public.set_prs_tasima_servisleri;
       public         heap 	   ths_admin    false            G           1259    140605    set_prs_servis_araci_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_tasima_servisleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_servis_araci_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    326            H           1259    140606    set_sat_siparis_durum_id_seq    SEQUENCE     �   ALTER TABLE public.set_sls_order_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_sat_siparis_durum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    283            I           1259    140607    set_sls_offer_status    TABLE     �   CREATE TABLE public.set_sls_offer_status (
    id bigint NOT NULL,
    teklif_durum character varying(32) NOT NULL,
    aciklama character varying(64)
);
 (   DROP TABLE public.set_sls_offer_status;
       public         heap 	   ths_admin    false            J           1259    140610    set_sat_teklif_durum_id_seq    SEQUENCE     �   ALTER TABLE public.set_sls_offer_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_sat_teklif_durum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    329            K           1259    140611    stk_ambarlar    TABLE       CREATE TABLE public.stk_ambarlar (
    id bigint NOT NULL,
    ambar_adi character varying(32),
    is_varsayilan_hammadde boolean DEFAULT false NOT NULL,
    is_varsayilan_uretim boolean DEFAULT false NOT NULL,
    is_varsayilan_satis boolean DEFAULT false NOT NULL
);
     DROP TABLE public.stk_ambarlar;
       public         heap 	   ths_admin    false            �           0    0    TABLE stk_ambarlar    COMMENT     X   COMMENT ON TABLE public.stk_ambarlar IS 'Stok hareketlerinin tutulduğu ambar bilgisi';
          public       	   ths_admin    false    331            L           1259    140617    stk_cins_ozellikleri    TABLE     �  CREATE TABLE public.stk_cins_ozellikleri (
    id bigint NOT NULL,
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
       public         heap 	   ths_admin    false            M           1259    140622    stk_cins_ozellikleri_id_seq    SEQUENCE     �   ALTER TABLE public.stk_cins_ozellikleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_cins_ozellikleri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    332            N           1259    140623    stk_hareketler    TABLE       CREATE TABLE public.stk_hareketler (
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
       public         heap 	   ths_admin    false            O           1259    140628    stk_hareketler_id_seq    SEQUENCE     �   ALTER TABLE public.stk_hareketler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_hareketler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    334            P           1259    140629    stk_kart_cins_bilgileri    TABLE     n  CREATE TABLE public.stk_kart_cins_bilgileri (
    id bigint NOT NULL,
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
       public         heap 	   ths_admin    false            Q           1259    140634    stk_kart_cins_bilgileri_id_seq    SEQUENCE     �   ALTER TABLE public.stk_kart_cins_bilgileri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_kart_cins_bilgileri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    336            R           1259    140635    stk_kart_ozetleri    TABLE     �  CREATE TABLE public.stk_kart_ozetleri (
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
       public         heap 	   ths_admin    false            S           1259    140649    stk_kart_ozetleri_id_seq    SEQUENCE     �   ALTER TABLE public.stk_kart_ozetleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_kart_ozetleri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    338            T           1259    140650    stk_kartlar_id_seq    SEQUENCE     �   ALTER TABLE public.stk_kartlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_kartlar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    285            U           1259    140651    stk_resimler    TABLE     n   CREATE TABLE public.stk_resimler (
    id bigint NOT NULL,
    stk_kart_id bigint NOT NULL,
    resim text
);
     DROP TABLE public.stk_resimler;
       public         heap 	   ths_admin    false            V           1259    140656    stk_resimler_id_seq    SEQUENCE     �   ALTER TABLE public.stk_resimler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_resimler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    341            W           1259    140657    stk_stok_ambar_id_seq    SEQUENCE     �   ALTER TABLE public.stk_ambarlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_stok_ambar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    331            X           1259    140658    stk_stok_grubu_id_seq    SEQUENCE     �   ALTER TABLE public.stk_gruplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_stok_grubu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    284            Y           1259    140659    sys_adresler    TABLE     �  CREATE TABLE public.sys_adresler (
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
       public         heap 	   ths_admin    false            Z           1259    140664    sys_adresler_id_seq    SEQUENCE     �   ALTER TABLE public.sys_adresler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_adresler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    345            [           1259    140665 	   sys_aylar    TABLE     e   CREATE TABLE public.sys_aylar (
    id bigint NOT NULL,
    ay_adi character varying(16) NOT NULL
);
    DROP TABLE public.sys_aylar;
       public         heap 	   ths_admin    false            \           1259    140668    sys_ay_id_seq    SEQUENCE     �   ALTER TABLE public.sys_aylar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    347            ]           1259    140669    sys_bolgeler    TABLE     g   CREATE TABLE public.sys_bolgeler (
    id bigint NOT NULL,
    bolge character varying(64) NOT NULL
);
     DROP TABLE public.sys_bolgeler;
       public         heap 	   ths_admin    false            ^           1259    140672    sys_bolge_id_seq    SEQUENCE     �   ALTER TABLE public.sys_bolgeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_bolge_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    349            _           1259    140673    sys_db_status    VIEW     �  CREATE VIEW public.sys_db_status AS
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
       public       	   ths_admin    false            `           1259    140678    sys_ersim_haklari    TABLE     i  CREATE TABLE public.sys_ersim_haklari (
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
       public         heap 	   ths_admin    false            a           1259    140686    sys_erisim_hakki_id_seq    SEQUENCE     �   ALTER TABLE public.sys_ersim_haklari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_erisim_hakki_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    352            b           1259    140687    sys_grid_filtreler_siralamalar    TABLE     �   CREATE TABLE public.sys_grid_filtreler_siralamalar (
    id bigint NOT NULL,
    tablo_adi character varying(32),
    icerik character varying,
    is_siralama boolean DEFAULT false
);
 2   DROP TABLE public.sys_grid_filtreler_siralamalar;
       public         heap 	   ths_admin    false            c           1259    140693    sys_grid_filtre_siralama_id_seq    SEQUENCE     �   ALTER TABLE public.sys_grid_filtreler_siralamalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_filtre_siralama_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    354            d           1259    140694    sys_grid_kolonlar    TABLE     �  CREATE TABLE public.sys_grid_kolonlar (
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
       public         heap 	   ths_admin    false            e           1259    140709    sys_grid_kolon_id_seq    SEQUENCE     �   ALTER TABLE public.sys_grid_kolonlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_kolon_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    356            f           1259    140710 
   sys_gunler    TABLE     g   CREATE TABLE public.sys_gunler (
    id bigint NOT NULL,
    gun_adi character varying(16) NOT NULL
);
    DROP TABLE public.sys_gunler;
       public         heap 	   ths_admin    false            g           1259    140713    sys_gun_id_seq    SEQUENCE     �   ALTER TABLE public.sys_gunler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_gun_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    358            h           1259    140714    sys_kaynak_gruplari    TABLE     m   CREATE TABLE public.sys_kaynak_gruplari (
    id bigint NOT NULL,
    grup character varying(64) NOT NULL
);
 '   DROP TABLE public.sys_kaynak_gruplari;
       public         heap 	   ths_admin    false            i           1259    140717    sys_kaynak_grup_id_seq    SEQUENCE     �   ALTER TABLE public.sys_kaynak_gruplari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kaynak_grup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    360            j           1259    140718    sys_kaynaklar    TABLE     �   CREATE TABLE public.sys_kaynaklar (
    id bigint NOT NULL,
    kaynak_kodu integer NOT NULL,
    kaynak_adi character varying(64) NOT NULL,
    kaynak_grup_id bigint NOT NULL
);
 !   DROP TABLE public.sys_kaynaklar;
       public         heap 	   ths_admin    false            k           1259    140721    sys_kaynak_id_seq    SEQUENCE     �   ALTER TABLE public.sys_kaynaklar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kaynak_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    362            l           1259    140722    sys_kullanicilar    TABLE     �  CREATE TABLE public.sys_kullanicilar (
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
       public         heap 	   ths_admin    false            m           1259    140731    sys_kullanici_id_seq    SEQUENCE     �   ALTER TABLE public.sys_kullanicilar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kullanici_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    364            n           1259    140732    sys_lisan_gui_icerikler    TABLE     R  CREATE TABLE public.sys_lisan_gui_icerikler (
    id bigint NOT NULL,
    lisan character varying(16) NOT NULL,
    kod character varying(64) NOT NULL,
    deger text,
    is_fabrika boolean DEFAULT false NOT NULL,
    icerik_tipi character varying(32) NOT NULL,
    tablo_adi character varying(64),
    form_adi character varying(64)
);
 +   DROP TABLE public.sys_lisan_gui_icerikler;
       public         heap 	   ths_admin    false            o           1259    140738    sys_lisan_gui_icerik_id_seq    SEQUENCE     �   ALTER TABLE public.sys_lisan_gui_icerikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_lisan_gui_icerik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    366            p           1259    140739    sys_lisanlar    TABLE     g   CREATE TABLE public.sys_lisanlar (
    id bigint NOT NULL,
    lisan character varying(16) NOT NULL
);
     DROP TABLE public.sys_lisanlar;
       public         heap 	   ths_admin    false            q           1259    140742    sys_lisan_id_seq    SEQUENCE     �   ALTER TABLE public.sys_lisanlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_lisan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    368            r           1259    140743    sys_vergi_mukellef_tipleri    TABLE     �   CREATE TABLE public.sys_vergi_mukellef_tipleri (
    id bigint NOT NULL,
    mukellef_tipi character varying(32) NOT NULL,
    is_varsayilan boolean DEFAULT false NOT NULL
);
 .   DROP TABLE public.sys_vergi_mukellef_tipleri;
       public         heap 	   ths_admin    false            s           1259    140747    sys_mukellef_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_vergi_mukellef_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_mukellef_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    370            t           1259    140748    sys_olcu_birimleri    TABLE       CREATE TABLE public.sys_olcu_birimleri (
    id bigint NOT NULL,
    birim character varying(16) NOT NULL,
    birim_einv character varying(3),
    aciklama character varying(64),
    is_ondalik boolean DEFAULT false NOT NULL,
    birim_tipi_id bigint,
    carpan integer
);
 &   DROP TABLE public.sys_olcu_birimleri;
       public         heap 	   ths_admin    false            u           1259    140752    sys_olcu_birimi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_olcu_birimleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_olcu_birimi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    372            v           1259    140753    sys_olcu_birimi_tipleri    TABLE     }   CREATE TABLE public.sys_olcu_birimi_tipleri (
    id bigint NOT NULL,
    olcu_birimi_tipi character varying(16) NOT NULL
);
 +   DROP TABLE public.sys_olcu_birimi_tipleri;
       public         heap 	   ths_admin    false            w           1259    140756    sys_olcu_birimi_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_olcu_birimi_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_olcu_birimi_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    374            x           1259    140757    sys_ondalik_haneler    TABLE     �   CREATE TABLE public.sys_ondalik_haneler (
    id bigint NOT NULL,
    miktar smallint DEFAULT 2,
    fiyat smallint DEFAULT 2,
    tutar smallint DEFAULT 2,
    stok_miktar smallint DEFAULT 4,
    doviz_kuru smallint DEFAULT 4
);
 '   DROP TABLE public.sys_ondalik_haneler;
       public         heap 	   ths_admin    false            y           1259    140765    sys_ondalik_hane_id_seq    SEQUENCE     �   ALTER TABLE public.sys_ondalik_haneler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ondalik_hane_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    376            z           1259    140766    sys_para_birimleri    TABLE     �   CREATE TABLE public.sys_para_birimleri (
    id bigint NOT NULL,
    para character varying(3) NOT NULL,
    sembol character varying(3) NOT NULL,
    aciklama character varying(128)
);
 &   DROP TABLE public.sys_para_birimleri;
       public         heap 	   ths_admin    false            {           1259    140769    sys_para_birimi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_para_birimleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_para_birimi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    378            |           1259    140770    sys_sehir_id_seq    SEQUENCE     �   ALTER TABLE public.sys_sehirler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_sehir_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    286            }           1259    140771    sys_ulkeler    TABLE       CREATE TABLE public.sys_ulkeler (
    id bigint NOT NULL,
    ulke_kodu character varying(2) NOT NULL,
    ulke_adi character varying(128) NOT NULL,
    iso_year integer,
    iso_cctld character varying(3),
    is_eu_member boolean DEFAULT false NOT NULL
);
    DROP TABLE public.sys_ulkeler;
       public         heap 	   ths_admin    false            ~           1259    140775    sys_ulke_id_seq    SEQUENCE     �   ALTER TABLE public.sys_ulkeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ulke_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    381                       1259    140776    sys_uygulama_ayarlari    TABLE     >  CREATE TABLE public.sys_uygulama_ayarlari (
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
 )   DROP TABLE public.sys_uygulama_ayarlari;
       public         heap 	   ths_admin    false            �           1259    140788    sys_uygulama_ayari_id_seq    SEQUENCE     �   ALTER TABLE public.sys_uygulama_ayarlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_uygulama_ayari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    383            �           1259    140789    sys_view_tables    VIEW     �  CREATE VIEW public.sys_view_tables AS
 SELECT (row_number() OVER (ORDER BY tables.table_type, tables.table_name))::integer AS id,
    initcap(replace((tables.table_name)::text, '_'::text, ' '::text)) AS table_name,
    (tables.table_type)::text AS table_type
   FROM information_schema.tables
  WHERE ((tables.table_schema)::text = 'public'::text)
  ORDER BY tables.table_type, tables.table_name;
 "   DROP VIEW public.sys_view_tables;
       public       	   ths_admin    false            �           1259    140793    sys_view_columns    VIEW     '  CREATE VIEW public.sys_view_columns AS
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
       public       	   ths_admin    false    385    385            �           1259    140798    sys_view_databases    VIEW     >  CREATE VIEW public.sys_view_databases AS
 SELECT (pg_database.datname)::text AS database_name,
    pg_shdescription.description AS aciklama
   FROM (pg_shdescription
     JOIN pg_database ON ((pg_shdescription.objoid = pg_database.oid)))
  WHERE ((1 = 1) AND (pg_shdescription.description = 'THS ERP Systems'::text));
 %   DROP VIEW public.sys_view_databases;
       public       	   ths_admin    false            �           1259    140802    urt_recete_yan_urunler    TABLE     �   CREATE TABLE public.urt_recete_yan_urunler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    urun_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 *   DROP TABLE public.urt_recete_yan_urunler;
       public         heap 	   ths_admin    false            �           1259    140805    urt_recete_yan_urunler_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_yan_urunler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urt_recete_yan_urunler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    388            �          0    140243    als_teklif_detaylari 
   TABLE DATA           c  COPY public.als_teklif_detaylari (id, header_id, siparis_detay_id, irsaliye_detay_id, fatura_detay_id, stok_kodu, stok_aciklama, kullanici_aciklama, referans, miktar, olcu_birimi, iskonto_orani, kdv_orani, fiyat, net_fiyat, tutar, iskonto_tutar, net_tutar, kdv_tutar, toplam_tutar, is_ana_urun, referans_ana_urun_id, gtip_no, mensei_ulke_adi) FROM stdin;
    public       	   ths_admin    false    221   �k      �          0    140260    als_teklifler 
   TABLE DATA           �  COPY public.als_teklifler (id, siparis_id, irsaliye_id, fatura_id, is_siparislesti, tutar, iskonto_tutar, ara_toplam, kdv_oran1, kdv_tutar1, kdv_oran2, kdv_tutar2, kdv_oran3, kdv_tutar3, kdv_oran4, kdv_tutar4, kdv_oran5, kdv_tutar5, genel_toplam, islem_tipi_id, teklif_no, teklif_tarihi, gecerlilik_tarihi, musteri_kodu, musteri_adi, vergi_dairesi, vergi_no, ulke_id, sehir_id, ilce, mahalle, semt, cadde, sokak, bina_adi, kapi_no, posta_kodu, web, email, musteri_temsilcisi, muhattap_ad, muhattap_telefon, referans, para_birimi, doviz_kuru_usd, doviz_kuru_eur, aciklama, tevkifat_kodu, tevkifat_aciklama, tevkifat_pay, tevkifat_payda) FROM stdin;
    public       	   ths_admin    false    223   l      �          0    140282    audits 
   TABLE DATA           �   COPY public.audits (id, user_name, ip_address, table_name, access_type, time_of_change, row_id, client_username, old_val, new_val) FROM stdin;
    public       	   ths_admin    false    225   $l      �          0    140292    ch_banka_subeleri 
   TABLE DATA           X   COPY public.ch_banka_subeleri (id, banka_id, sube_kodu, sube_adi, sehir_id) FROM stdin;
    public       	   ths_admin    false    229   \n      �          0    140288    ch_bankalar 
   TABLE DATA           @   COPY public.ch_bankalar (id, banka_adi, swift_kodu) FROM stdin;
    public       	   ths_admin    false    227   �n      �          0    140296    ch_bolgeler 
   TABLE DATA           0   COPY public.ch_bolgeler (id, bolge) FROM stdin;
    public       	   ths_admin    false    231   �n      �          0    140300    ch_doviz_kurlari 
   TABLE DATA           E   COPY public.ch_doviz_kurlari (id, kur_tarihi, kur, para) FROM stdin;
    public       	   ths_admin    false    233   ^o      �          0    140303 
   ch_gruplar 
   TABLE DATA           .   COPY public.ch_gruplar (id, grup) FROM stdin;
    public       	   ths_admin    false    234   q      �          0    140315    ch_hesap_planlari 
   TABLE DATA           L   COPY public.ch_hesap_planlari (id, plan_kodu, plan_adi, seviye) FROM stdin;
    public       	   ths_admin    false    237   �q      �          0    140306    ch_hesaplar 
   TABLE DATA           �  COPY public.ch_hesaplar (id, hesap_kodu, hesap_ismi, hesap_tipi_id, grup_id, bolge_id, mukellef_tipi_id, mukellef_adi, mukellef_adi2, mukellef_soyadi, vergi_dairesi, vergi_no, iban, iban_para, nace, yetkili1, yetkili1_tel, yetkili2, yetkili2_tel, yetkili3, yetkili3_tel, faks, muhasebe_telefon, muhasebe_email, muhasebe_yetkili, ozel_not, kok_kod, ara_kod, iskonto, efatura_kullaniyor, efatura_pb_name, adres_id, pasif) FROM stdin;
    public       	   ths_admin    false    235   �      �          0    140319    mhs_fis_detaylari 
   TABLE DATA           :   COPY public.mhs_fis_detaylari (id, header_id) FROM stdin;
    public       	   ths_admin    false    239    �      �          0    140323 
   mhs_fisler 
   TABLE DATA           D   COPY public.mhs_fisler (id, yevmiye_no, yevmiye_tarihi) FROM stdin;
    public       	   ths_admin    false    241   �      �          0    140327    mhs_transfer_kodlari 
   TABLE DATA           W   COPY public.mhs_transfer_kodlari (id, transfer_kodu, aciklama, hesap_kodu) FROM stdin;
    public       	   ths_admin    false    243   :�      �          0    140331    prs_ehliyetler 
   TABLE DATA           E   COPY public.prs_ehliyetler (id, ehliyet_id, personel_id) FROM stdin;
    public       	   ths_admin    false    245   W�      �          0    140334    prs_lisan_bilgileri 
   TABLE DATA           h   COPY public.prs_lisan_bilgileri (id, lisan_id, okuma_id, yazma_id, konusma_id, personel_id) FROM stdin;
    public       	   ths_admin    false    246   �      �          0    140339    prs_personeller 
   TABLE DATA           i  COPY public.prs_personeller (id, ad, soyad, ad_soyad, tel1, tel2, personel_tipi_id, birim_id, gorev_id, dogum_tarihi, kan_grubu, cinsiyet, askerlik_durumu, medeni_durum, cocuk_sayisi, yakin_adi, yakin_telefon, ayakkabi_no, elbise_bedeni, genel_not, tasima_servis_id, ozel_not, maas, ikramiye_sayisi, ikramiye_tutar, identification, adres_id, pasif) FROM stdin;
    public       	   ths_admin    false    249   ��      �          0    140392    sat_fatura_detaylari 
   TABLE DATA           s   COPY public.sat_fatura_detaylari (id, header_id, teklif_detay_id, siparis_detay_id, irsaliye_detay_id) FROM stdin;
    public       	   ths_admin    false    271   �      �          0    140396    sat_faturalar 
   TABLE DATA           i   COPY public.sat_faturalar (id, fatura_no, fatura_tarihi, teklif_id, siparis_id, irsaliye_id) FROM stdin;
    public       	   ths_admin    false    273   �      �          0    140400    sat_irsaliye_detaylari 
   TABLE DATA           s   COPY public.sat_irsaliye_detaylari (id, header_id, teklif_detay_id, siparis_detay_id, fatura_detay_id) FROM stdin;
    public       	   ths_admin    false    275   ,�      �          0    140404    sat_irsaliyeler 
   TABLE DATA           m   COPY public.sat_irsaliyeler (id, irsaliye_no, irsaliye_tarihi, teklif_id, siparis_id, fatura_id) FROM stdin;
    public       	   ths_admin    false    277   I�      �          0    140408    sat_siparis_detaylari 
   TABLE DATA           �  COPY public.sat_siparis_detaylari (id, header_id, teklif_detay_id, irsaliye_detay_id, fatura_detay_id, stok_kodu, stok_aciklama, kullanici_aciklama, referans, miktar, giden_miktar, olcu_birimi, iskonto_orani, kdv_orani, fiyat, net_fiyat, tutar, iskonto_tutar, net_tutar, kdv_tutar, toplam_tutar, is_ana_urun, referans_ana_urun_id, gtip_no, en, boy, yukseklik, net_agirlik, brut_agirlik, hacim, kab) FROM stdin;
    public       	   ths_admin    false    279   f�      �          0    140432    sat_siparisler 
   TABLE DATA           u  COPY public.sat_siparisler (id, teklif_id, irsaliye_id, fatura_id, tutar, iskonto_tutar, ara_toplam, kdv_oran1, kdv_tutar1, kdv_oran2, kdv_tutar2, kdv_oran3, kdv_tutar3, kdv_oran4, kdv_tutar4, kdv_oran5, kdv_tutar5, genel_toplam, islem_tipi_id, siparis_no, siparis_tarihi, teslim_tarihi, musteri_kodu, musteri_adi, vergi_dairesi, vergi_no, ulke_id, sehir_id, ilce, mahalle, cadde, sokak, posta_kodu, bina_adi, kapi_no, musteri_temsilcisi_id, muhattap_ad, referans, para_birimi, doviz_kuru_usd, doviz_kuru_eur, aciklama, proforma_no, siparis_durum_id, teslim_sekli_id, odeme_sekli_id, paket_tipi_id, tasima_ucreti_id) FROM stdin;
    public       	   ths_admin    false    281   ��      �          0    140489    sat_teklif_detaylari 
   TABLE DATA           R  COPY public.sat_teklif_detaylari (id, header_id, siparis_detay_id, irsaliye_detay_id, fatura_detay_id, stok_kodu, stok_aciklama, kullanici_aciklama, referans, miktar, olcu_birimi, iskonto_orani, kdv_orani, fiyat, net_fiyat, tutar, iskonto_tutar, net_tutar, kdv_tutar, toplam_tutar, is_ana_urun, referans_ana_urun_id, gtip_no) FROM stdin;
    public       	   ths_admin    false    288   ��      �          0    140506    sat_teklifler 
   TABLE DATA           �  COPY public.sat_teklifler (id, siparis_id, irsaliye_id, fatura_id, is_siparislesti, tutar, iskonto_tutar, ara_toplam, kdv_oran1, kdv_tutar1, kdv_oran2, kdv_tutar2, kdv_oran3, kdv_tutar3, kdv_oran4, kdv_tutar4, kdv_oran5, kdv_tutar5, genel_toplam, islem_tipi_id, teklif_no, teklif_tarihi, gecerlilik_tarihi, musteri_kodu, musteri_adi, vergi_dairesi, vergi_no, ulke_id, sehir_id, ilce, mahalle, cadde, sokak, posta_kodu, bina_adi, kapi_no, musteri_temsilcisi_id, muhattap_ad, muhattap_telefon, referans, para_birimi, doviz_kuru_usd, doviz_kuru_eur, aciklama, proforma_no, teslim_sekli_id, odeme_sekli_id, paket_tipi_id, tasima_ucreti_id) FROM stdin;
    public       	   ths_admin    false    290   ��      �          0    140528    set_ch_firma_tipleri 
   TABLE DATA           M   COPY public.set_ch_firma_tipleri (id, firma_turu_id, firma_tipi) FROM stdin;
    public       	   ths_admin    false    292   \�      �          0    140532    set_ch_firma_turleri 
   TABLE DATA           >   COPY public.set_ch_firma_turleri (id, firma_turu) FROM stdin;
    public       	   ths_admin    false    294   ��      �          0    140538    set_ch_hesap_tipleri 
   TABLE DATA           >   COPY public.set_ch_hesap_tipleri (id, hesap_tipi) FROM stdin;
    public       	   ths_admin    false    298   ��      �          0    140542    set_ch_vergi_oranlari 
   TABLE DATA           �   COPY public.set_ch_vergi_oranlari (id, vergi_orani, satis_hesap_kodu, satis_iade_hesap_kodu, alis_hesap_kodu, alis_iade_hesap_kodu) FROM stdin;
    public       	   ths_admin    false    300   �      �          0    140546    set_einv_fatura_tipleri 
   TABLE DATA           B   COPY public.set_einv_fatura_tipleri (id, fatura_tipi) FROM stdin;
    public       	   ths_admin    false    302   n�      �          0    140550    set_einv_odeme_sekilleri 
   TABLE DATA           ^   COPY public.set_einv_odeme_sekilleri (id, odeme_sekli, kod, aciklama, is_efatura) FROM stdin;
    public       	   ths_admin    false    304   ǘ      �          0    140557    set_einv_paket_tipleri 
   TABLE DATA           O   COPY public.set_einv_paket_tipleri (id, kod, paket_tipi, aciklama) FROM stdin;
    public       	   ths_admin    false    306   �      �          0    140563    set_einv_tasima_ucretleri 
   TABLE DATA           F   COPY public.set_einv_tasima_ucretleri (id, tasima_ucreti) FROM stdin;
    public       	   ths_admin    false    308   Y�      �          0    140567    set_einv_teslim_sekilleri 
   TABLE DATA           [   COPY public.set_einv_teslim_sekilleri (id, teslim_sekli, aciklama, is_efatura) FROM stdin;
    public       	   ths_admin    false    310   ��                 0    140572    set_prs_birimler 
   TABLE DATA           ?   COPY public.set_prs_birimler (id, birim, bolum_id) FROM stdin;
    public       	   ths_admin    false    312   ��                0    140576    set_prs_bolumler 
   TABLE DATA           5   COPY public.set_prs_bolumler (id, bolum) FROM stdin;
    public       	   ths_admin    false    314    �                0    140580    set_prs_ehliyetler 
   TABLE DATA           9   COPY public.set_prs_ehliyetler (id, ehliyet) FROM stdin;
    public       	   ths_admin    false    316   ]�                0    140584    set_prs_gorevler 
   TABLE DATA           5   COPY public.set_prs_gorevler (id, gorev) FROM stdin;
    public       	   ths_admin    false    318   ��      
          0    140592    set_prs_lisan_seviyeleri 
   TABLE DATA           F   COPY public.set_prs_lisan_seviyeleri (id, lisan_seviyesi) FROM stdin;
    public       	   ths_admin    false    322   ˝                0    140588    set_prs_lisanlar 
   TABLE DATA           5   COPY public.set_prs_lisanlar (id, lisan) FROM stdin;
    public       	   ths_admin    false    320   �                0    140596    set_prs_personel_tipleri 
   TABLE DATA           E   COPY public.set_prs_personel_tipleri (id, personel_tipi) FROM stdin;
    public       	   ths_admin    false    324   F�                0    140600    set_prs_tasima_servisleri 
   TABLE DATA           P   COPY public.set_prs_tasima_servisleri (id, arac_no, arac_adi, rota) FROM stdin;
    public       	   ths_admin    false    326   ��                0    140607    set_sls_offer_status 
   TABLE DATA           J   COPY public.set_sls_offer_status (id, teklif_durum, aciklama) FROM stdin;
    public       	   ths_admin    false    329   ��      �          0    140454    set_sls_order_status 
   TABLE DATA           K   COPY public.set_sls_order_status (id, siparis_durum, aciklama) FROM stdin;
    public       	   ths_admin    false    283   ��                0    140611    stk_ambarlar 
   TABLE DATA           x   COPY public.stk_ambarlar (id, ambar_adi, is_varsayilan_hammadde, is_varsayilan_uretim, is_varsayilan_satis) FROM stdin;
    public       	   ths_admin    false    331   6�                0    140617    stk_cins_ozellikleri 
   TABLE DATA           �   COPY public.stk_cins_ozellikleri (id, cins, aciklama, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, i1, i2, i3, i4, i5, d1, d2, d3, d4, d5) FROM stdin;
    public       	   ths_admin    false    332   k�      �          0    140457    stk_gruplar 
   TABLE DATA           �   COPY public.stk_gruplar (id, grup, kdv_orani, hammadde_stok_hesap_kodu, hammadde_kullanim_hesap_kodu, yari_mamul_hesap_kodu) FROM stdin;
    public       	   ths_admin    false    284   �                0    140623    stk_hareketler 
   TABLE DATA           �   COPY public.stk_hareketler (id, stok_kodu, miktar, tutar, tutar_doviz, para_birimi, is_giris, tarih, veren_ambar_id, alan_ambar_id, is_donem_basi, aciklama, irsaliye_id, uretim_id) FROM stdin;
    public       	   ths_admin    false    334   W�                0    140629    stk_kart_cins_bilgileri 
   TABLE DATA           �   COPY public.stk_kart_cins_bilgileri (id, stk_kart_id, cins_id, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, i1, i2, i3, i4, i5, d1, d2, d3, d4, d5) FROM stdin;
    public       	   ths_admin    false    336   t�                0    140635    stk_kart_ozetleri 
   TABLE DATA           ;  COPY public.stk_kart_ozetleri (id, stk_kart_id, stok_miktar, ortalama_maliyet, donem_basi_fiyat, donem_basi_miktar, donem_basi_tutar, giren_toplam, giren_toplam_maliyet, cikan_toplam, cikan_toplam_maliyet, son_alis_fiyat, son_alis_para, son_alis_tarih, son_alis_miktar, son_alis_kur, son_alis_kur_para) FROM stdin;
    public       	   ths_admin    false    338   ��      �          0    140460    stk_kartlar 
   TABLE DATA           n  COPY public.stk_kartlar (id, is_satilabilir, stok_kodu, stok_adi, stok_grubu_id, olcu_birimi_id, urun_tipi, alis_iskonto, satis_iskonto, alis_fiyat, alis_para, satis_fiyat, satis_para, ihrac_fiyat, ihrac_para, ortalama_maliyet, en, boy, yukseklik, agirlik, temin_suresi, ozel_kod, marka, mensei_id, gtip_no, diib_urun_tanimi, en_az_stok_seviyesi, tanim) FROM stdin;
    public       	   ths_admin    false    285   ��                0    140651    stk_resimler 
   TABLE DATA           >   COPY public.stk_resimler (id, stk_kart_id, resim) FROM stdin;
    public       	   ths_admin    false    341   ١      !          0    140659    sys_adresler 
   TABLE DATA           �   COPY public.sys_adresler (id, sehir_id, ilce, mahalle, semt, cadde, sokak, bina_adi, kapi_no, posta_kodu, web, email) FROM stdin;
    public       	   ths_admin    false    345   v�      #          0    140665 	   sys_aylar 
   TABLE DATA           /   COPY public.sys_aylar (id, ay_adi) FROM stdin;
    public       	   ths_admin    false    347    �      %          0    140669    sys_bolgeler 
   TABLE DATA           1   COPY public.sys_bolgeler (id, bolge) FROM stdin;
    public       	   ths_admin    false    349   ��      '          0    140678    sys_ersim_haklari 
   TABLE DATA              COPY public.sys_ersim_haklari (id, kaynak_id, is_okuma, is_ekleme, is_guncelleme, is_silme, is_ozel, kullanici_id) FROM stdin;
    public       	   ths_admin    false    352   ��      )          0    140687    sys_grid_filtreler_siralamalar 
   TABLE DATA           \   COPY public.sys_grid_filtreler_siralamalar (id, tablo_adi, icerik, is_siralama) FROM stdin;
    public       	   ths_admin    false    354   ��      +          0    140694    sys_grid_kolonlar 
   TABLE DATA           �   COPY public.sys_grid_kolonlar (id, tablo_adi, kolon_adi, sira_no, kolon_genislik, veri_formati, is_gorunur, is_helper_gorunur, min_deger, min_renk, maks_deger, maks_renk, maks_deger_yuzdesi, bar_rengi, bar_arka_rengi, bar_yazi_rengi) FROM stdin;
    public       	   ths_admin    false    356   ��      -          0    140710 
   sys_gunler 
   TABLE DATA           1   COPY public.sys_gunler (id, gun_adi) FROM stdin;
    public       	   ths_admin    false    358   3�      /          0    140714    sys_kaynak_gruplari 
   TABLE DATA           7   COPY public.sys_kaynak_gruplari (id, grup) FROM stdin;
    public       	   ths_admin    false    360   ��      1          0    140718    sys_kaynaklar 
   TABLE DATA           T   COPY public.sys_kaynaklar (id, kaynak_kodu, kaynak_adi, kaynak_grup_id) FROM stdin;
    public       	   ths_admin    false    362   �      3          0    140722    sys_kullanicilar 
   TABLE DATA           �   COPY public.sys_kullanicilar (id, kullanici_adi, kullanici_sifre, is_aktif, is_yonetici, is_super_kullanici, ip_adres, mac_adres, personel_id) FROM stdin;
    public       	   ths_admin    false    364   3�      5          0    140732    sys_lisan_gui_icerikler 
   TABLE DATA           v   COPY public.sys_lisan_gui_icerikler (id, lisan, kod, deger, is_fabrika, icerik_tipi, tablo_adi, form_adi) FROM stdin;
    public       	   ths_admin    false    366   ��      7          0    140739    sys_lisanlar 
   TABLE DATA           1   COPY public.sys_lisanlar (id, lisan) FROM stdin;
    public       	   ths_admin    false    368   ��      =          0    140753    sys_olcu_birimi_tipleri 
   TABLE DATA           G   COPY public.sys_olcu_birimi_tipleri (id, olcu_birimi_tipi) FROM stdin;
    public       	   ths_admin    false    374   
�      ;          0    140748    sys_olcu_birimleri 
   TABLE DATA           p   COPY public.sys_olcu_birimleri (id, birim, birim_einv, aciklama, is_ondalik, birim_tipi_id, carpan) FROM stdin;
    public       	   ths_admin    false    372   N�      ?          0    140757    sys_ondalik_haneler 
   TABLE DATA           `   COPY public.sys_ondalik_haneler (id, miktar, fiyat, tutar, stok_miktar, doviz_kuru) FROM stdin;
    public       	   ths_admin    false    376   '�      A          0    140766    sys_para_birimleri 
   TABLE DATA           H   COPY public.sys_para_birimleri (id, para, sembol, aciklama) FROM stdin;
    public       	   ths_admin    false    378   D�      �          0    140481    sys_sehirler 
   TABLE DATA           P   COPY public.sys_sehirler (id, sehir, plaka_kodu, ulke_id, bolge_id) FROM stdin;
    public       	   ths_admin    false    286   ��      D          0    140771    sys_ulkeler 
   TABLE DATA           a   COPY public.sys_ulkeler (id, ulke_kodu, ulke_adi, iso_year, iso_cctld, is_eu_member) FROM stdin;
    public       	   ths_admin    false    381   .�      F          0    140776    sys_uygulama_ayarlari 
   TABLE DATA           @  COPY public.sys_uygulama_ayarlari (id, logo, unvan, telefon, faks, vergi_dairesi, vergi_no, donem, lisan, mail_sunucu, mail_kullanici, mail_sifre, mail_smtp_port, grid_renk_1, grid_renk_2, grid_renk_aktif, crypt_key, sms_sunucu, sms_kullanici, sms_sifre, sms_baslik, versiyon, para, adres_id, diger_ayarlar) FROM stdin;
    public       	   ths_admin    false    383   ��      9          0    140743    sys_vergi_mukellef_tipleri 
   TABLE DATA           V   COPY public.sys_vergi_mukellef_tipleri (id, mukellef_tipi, is_varsayilan) FROM stdin;
    public       	   ths_admin    false    370   vX      �          0    140350    urt_iscilikler 
   TABLE DATA           `   COPY public.urt_iscilikler (id, gider_kodu, gider_adi, fiyat, birim_id, gider_tipi) FROM stdin;
    public       	   ths_admin    false    251   �X      �          0    140354    urt_paket_hammadde_detaylari 
   TABLE DATA           c   COPY public.urt_paket_hammadde_detaylari (id, header_id, recete_id, stok_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    253   �X      �          0    140358    urt_paket_hammaddeler 
   TABLE DATA           >   COPY public.urt_paket_hammaddeler (id, paket_adi) FROM stdin;
    public       	   ths_admin    false    255   $Y      �          0    140362    urt_paket_iscilik_detaylari 
   TABLE DATA           Z   COPY public.urt_paket_iscilik_detaylari (id, header_id, iscilik_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    257   ZY      �          0    140366    urt_paket_iscilikler 
   TABLE DATA           =   COPY public.urt_paket_iscilikler (id, paket_adi) FROM stdin;
    public       	   ths_admin    false    259   wY      �          0    140370    urt_recete_hammaddeler 
   TABLE DATA           i   COPY public.urt_recete_hammaddeler (id, header_id, recete_id, stok_kodu, miktar, fire_orani) FROM stdin;
    public       	   ths_admin    false    261   �Y      �          0    140380    urt_recete_iscilikler 
   TABLE DATA           T   COPY public.urt_recete_iscilikler (id, header_id, iscilik_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    265   �Y      �          0    140384    urt_recete_paket_hammaddeler 
   TABLE DATA           W   COPY public.urt_recete_paket_hammaddeler (id, header_id, paket_id, miktar) FROM stdin;
    public       	   ths_admin    false    267   Z      �          0    140388    urt_recete_paket_iscilikler 
   TABLE DATA           V   COPY public.urt_recete_paket_iscilikler (id, header_id, paket_id, miktar) FROM stdin;
    public       	   ths_admin    false    269   /Z      H          0    140802    urt_recete_yan_urunler 
   TABLE DATA           R   COPY public.urt_recete_yan_urunler (id, header_id, urun_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    388   LZ      �          0    140375    urt_receteler 
   TABLE DATA           Y   COPY public.urt_receteler (id, urun_kodu, urun_adi, ornek_miktari, aciklama) FROM stdin;
    public       	   ths_admin    false    263   iZ      �           0    0    a_invoices_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.a_invoices_id_seq', 10, true);
          public          postgres    false    220            �           0    0    als_teklif_detaylari_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.als_teklif_detaylari_id_seq', 1, false);
          public       	   ths_admin    false    222            �           0    0    als_teklifler_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.als_teklifler_id_seq', 1, false);
          public       	   ths_admin    false    224            �           0    0    audit_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.audit_id_seq', 27, true);
          public       	   ths_admin    false    226            �           0    0    ch_banka_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.ch_banka_id_seq', 6, true);
          public       	   ths_admin    false    228            �           0    0    ch_banka_subesi_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.ch_banka_subesi_id_seq', 7, true);
          public       	   ths_admin    false    230            �           0    0    ch_bolge_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.ch_bolge_id_seq', 17, true);
          public       	   ths_admin    false    232            �           0    0    ch_hesap_karti_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.ch_hesap_karti_id_seq', 317, true);
          public       	   ths_admin    false    236            �           0    0    mhs_doviz_kuru_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.mhs_doviz_kuru_id_seq', 310, true);
          public       	   ths_admin    false    238            �           0    0    mhs_fis_detaylari_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.mhs_fis_detaylari_id_seq', 1, false);
          public       	   ths_admin    false    240            �           0    0    mhs_fisler_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.mhs_fisler_id_seq', 1, false);
          public       	   ths_admin    false    242            �           0    0    mhs_transfer_kodlari_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.mhs_transfer_kodlari_id_seq', 1, false);
          public       	   ths_admin    false    244            �           0    0    prs_lisan_bilgisi_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.prs_lisan_bilgisi_id_seq', 2, true);
          public       	   ths_admin    false    247            �           0    0    prs_personel_ehliyetleri_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.prs_personel_ehliyetleri_id_seq', 2, true);
          public       	   ths_admin    false    248            �           0    0    prs_personel_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.prs_personel_id_seq', 16, true);
          public       	   ths_admin    false    250            �           0    0    rct_iscilik_gideri_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.rct_iscilik_gideri_id_seq', 2, false);
          public       	   ths_admin    false    252            �           0    0    rct_paket_hammadde_detay_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.rct_paket_hammadde_detay_id_seq', 2, true);
          public       	   ths_admin    false    254            �           0    0    rct_paket_hammadde_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.rct_paket_hammadde_id_seq', 1, true);
          public       	   ths_admin    false    256            �           0    0    rct_paket_iscilik_detay_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.rct_paket_iscilik_detay_id_seq', 1, false);
          public       	   ths_admin    false    258            �           0    0    rct_paket_iscilik_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.rct_paket_iscilik_id_seq', 1, false);
          public       	   ths_admin    false    260            �           0    0    rct_recete_hammadde_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.rct_recete_hammadde_id_seq', 18, true);
          public       	   ths_admin    false    262            �           0    0    rct_recete_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.rct_recete_id_seq', 9, true);
          public       	   ths_admin    false    264            �           0    0    rct_recete_iscilik_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.rct_recete_iscilik_id_seq', 2, true);
          public       	   ths_admin    false    266            �           0    0     rct_recete_paket_hammadde_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.rct_recete_paket_hammadde_id_seq', 1, false);
          public       	   ths_admin    false    268            �           0    0    rct_recete_paket_iscilik_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.rct_recete_paket_iscilik_id_seq', 1, false);
          public       	   ths_admin    false    270            �           0    0    sat_fatura_detay_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.sat_fatura_detay_id_seq', 1, false);
          public       	   ths_admin    false    272            �           0    0    sat_fatura_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sat_fatura_id_seq', 1, false);
          public       	   ths_admin    false    274            �           0    0    sat_irsaliye_detay_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sat_irsaliye_detay_id_seq', 1, false);
          public       	   ths_admin    false    276            �           0    0    sat_irsaliye_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.sat_irsaliye_id_seq', 1, false);
          public       	   ths_admin    false    278            �           0    0    sat_siparis_detay_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.sat_siparis_detay_id_seq', 1, false);
          public       	   ths_admin    false    280            �           0    0    sat_siparis_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sat_siparis_id_seq', 1, true);
          public       	   ths_admin    false    282            �           0    0    sat_teklif_detay_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.sat_teklif_detay_id_seq', 4, true);
          public       	   ths_admin    false    289            �           0    0    sat_teklif_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sat_teklif_id_seq', 1, true);
          public       	   ths_admin    false    291            �           0    0    set_ch_firma_tipi_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_firma_tipi_id_seq', 5, false);
          public       	   ths_admin    false    293            �           0    0    set_ch_firma_turu_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_firma_turu_id_seq', 2, false);
          public       	   ths_admin    false    295            �           0    0    set_ch_grup_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.set_ch_grup_id_seq', 72, true);
          public       	   ths_admin    false    296            �           0    0    set_ch_hesap_plani_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_ch_hesap_plani_id_seq', 286, false);
          public       	   ths_admin    false    297            �           0    0    set_ch_hesap_tipi_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_hesap_tipi_id_seq', 3, false);
          public       	   ths_admin    false    299            �           0    0    set_ch_vergi_orani_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_vergi_orani_id_seq', 7, true);
          public       	   ths_admin    false    301            �           0    0    set_einv_fatura_tipi_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_einv_fatura_tipi_id_seq', 6, false);
          public       	   ths_admin    false    303            �           0    0    set_einv_odeme_sekli_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_einv_odeme_sekli_id_seq', 32, false);
          public       	   ths_admin    false    305            �           0    0    set_einv_paket_tipi_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.set_einv_paket_tipi_id_seq', 4, false);
          public       	   ths_admin    false    307            �           0    0    set_einv_tasima_ucreti_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_einv_tasima_ucreti_id_seq', 3, true);
          public       	   ths_admin    false    309            �           0    0    set_einv_teslim_sekli_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.set_einv_teslim_sekli_id_seq', 28, false);
          public       	   ths_admin    false    311            �           0    0    set_prs_birim_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.set_prs_birim_id_seq', 46, true);
          public       	   ths_admin    false    313            �           0    0    set_prs_bolum_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.set_prs_bolum_id_seq', 26, true);
          public       	   ths_admin    false    315            �           0    0    set_prs_ehliyet_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.set_prs_ehliyet_id_seq', 6, true);
          public       	   ths_admin    false    317            �           0    0    set_prs_gorev_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.set_prs_gorev_id_seq', 6, true);
          public       	   ths_admin    false    319            �           0    0    set_prs_lisan_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.set_prs_lisan_id_seq', 4, true);
          public       	   ths_admin    false    321            �           0    0    set_prs_lisan_seviyesi_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.set_prs_lisan_seviyesi_id_seq', 4, false);
          public       	   ths_admin    false    323            �           0    0    set_prs_personel_tipi_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_prs_personel_tipi_id_seq', 3, false);
          public       	   ths_admin    false    325            �           0    0    set_prs_servis_araci_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.set_prs_servis_araci_id_seq', 1, true);
          public       	   ths_admin    false    327            �           0    0    set_sat_siparis_durum_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_sat_siparis_durum_id_seq', 3, false);
          public       	   ths_admin    false    328            �           0    0    set_sat_teklif_durum_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_sat_teklif_durum_id_seq', 3, false);
          public       	   ths_admin    false    330            �           0    0    stk_cins_ozellikleri_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.stk_cins_ozellikleri_id_seq', 7, true);
          public       	   ths_admin    false    333            �           0    0    stk_hareketler_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.stk_hareketler_id_seq', 1, false);
          public       	   ths_admin    false    335            �           0    0    stk_kart_cins_bilgileri_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.stk_kart_cins_bilgileri_id_seq', 12, true);
          public       	   ths_admin    false    337            �           0    0    stk_kart_ozetleri_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.stk_kart_ozetleri_id_seq', 1, false);
          public       	   ths_admin    false    339            �           0    0    stk_kartlar_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.stk_kartlar_id_seq', 9, true);
          public       	   ths_admin    false    340            �           0    0    stk_resimler_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.stk_resimler_id_seq', 6, true);
          public       	   ths_admin    false    342            �           0    0    stk_stok_ambar_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.stk_stok_ambar_id_seq', 3, true);
          public       	   ths_admin    false    343            �           0    0    stk_stok_grubu_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.stk_stok_grubu_id_seq', 12, true);
          public       	   ths_admin    false    344            �           0    0    sys_adresler_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.sys_adresler_id_seq', 5, true);
          public       	   ths_admin    false    346            �           0    0    sys_ay_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.sys_ay_id_seq', 24, true);
          public       	   ths_admin    false    348            �           0    0    sys_bolge_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sys_bolge_id_seq', 7, false);
          public       	   ths_admin    false    350            �           0    0    sys_erisim_hakki_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sys_erisim_hakki_id_seq', 1027, true);
          public       	   ths_admin    false    353            �           0    0    sys_grid_filtre_siralama_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.sys_grid_filtre_siralama_id_seq', 22, true);
          public       	   ths_admin    false    355            �           0    0    sys_grid_kolon_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.sys_grid_kolon_id_seq', 289, true);
          public       	   ths_admin    false    357            �           0    0    sys_gun_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.sys_gun_id_seq', 16, true);
          public       	   ths_admin    false    359            �           0    0    sys_kaynak_grup_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.sys_kaynak_grup_id_seq', 16, false);
          public       	   ths_admin    false    361            �           0    0    sys_kaynak_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sys_kaynak_id_seq', 44, true);
          public       	   ths_admin    false    363            �           0    0    sys_kullanici_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.sys_kullanici_id_seq', 66, true);
          public       	   ths_admin    false    365            �           0    0    sys_lisan_gui_icerik_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.sys_lisan_gui_icerik_id_seq', 169, true);
          public       	   ths_admin    false    367            �           0    0    sys_lisan_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sys_lisan_id_seq', 6, false);
          public       	   ths_admin    false    369            �           0    0    sys_mukellef_tipi_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.sys_mukellef_tipi_id_seq', 2, false);
          public       	   ths_admin    false    371            �           0    0    sys_olcu_birimi_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.sys_olcu_birimi_id_seq', 16, true);
          public       	   ths_admin    false    373            �           0    0    sys_olcu_birimi_tipi_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.sys_olcu_birimi_tipi_id_seq', 4, true);
          public       	   ths_admin    false    375            �           0    0    sys_ondalik_hane_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.sys_ondalik_hane_id_seq', 1, false);
          public       	   ths_admin    false    377            �           0    0    sys_para_birimi_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.sys_para_birimi_id_seq', 4, true);
          public       	   ths_admin    false    379            �           0    0    sys_sehir_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.sys_sehir_id_seq', 174, false);
          public       	   ths_admin    false    380            �           0    0    sys_ulke_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sys_ulke_id_seq', 321, true);
          public       	   ths_admin    false    382            �           0    0    sys_uygulama_ayari_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sys_uygulama_ayari_id_seq', 4, false);
          public       	   ths_admin    false    384            �           0    0    urt_recete_yan_urunler_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.urt_recete_yan_urunler_id_seq', 1, false);
          public       	   ths_admin    false    389            P           2606    140808 .   als_teklif_detaylari als_teklif_detaylari_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.als_teklif_detaylari DROP CONSTRAINT als_teklif_detaylari_pkey;
       public         	   ths_admin    false    221            S           2606    140810     als_teklifler als_teklifler_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_pkey;
       public         	   ths_admin    false    223            U           2606    140812 )   als_teklifler als_teklifler_teklif_no_key 
   CONSTRAINT     i   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_teklif_no_key UNIQUE (teklif_no);
 S   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_teklif_no_key;
       public         	   ths_admin    false    223            W           2606    140814    audits audit_pkey 
   CONSTRAINT     O   ALTER TABLE ONLY public.audits
    ADD CONSTRAINT audit_pkey PRIMARY KEY (id);
 ;   ALTER TABLE ONLY public.audits DROP CONSTRAINT audit_pkey;
       public         	   ths_admin    false    225            ]           2606    140816 :   ch_banka_subeleri ch_banka_subeleri_banka_id_sube_kodu_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_banka_id_sube_kodu_key UNIQUE (banka_id, sube_kodu);
 d   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_banka_id_sube_kodu_key;
       public         	   ths_admin    false    229    229            _           2606    140818 (   ch_banka_subeleri ch_banka_subeleri_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_pkey;
       public         	   ths_admin    false    229            Y           2606    140820 %   ch_bankalar ch_bankalar_banka_adi_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.ch_bankalar
    ADD CONSTRAINT ch_bankalar_banka_adi_key UNIQUE (banka_adi);
 O   ALTER TABLE ONLY public.ch_bankalar DROP CONSTRAINT ch_bankalar_banka_adi_key;
       public         	   ths_admin    false    227            [           2606    140822    ch_bankalar ch_bankalar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ch_bankalar
    ADD CONSTRAINT ch_bankalar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ch_bankalar DROP CONSTRAINT ch_bankalar_pkey;
       public         	   ths_admin    false    227            a           2606    140824 !   ch_bolgeler ch_bolgeler_bolge_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.ch_bolgeler
    ADD CONSTRAINT ch_bolgeler_bolge_key UNIQUE (bolge);
 K   ALTER TABLE ONLY public.ch_bolgeler DROP CONSTRAINT ch_bolgeler_bolge_key;
       public         	   ths_admin    false    231            c           2606    140826    ch_bolgeler ch_bolgeler_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ch_bolgeler
    ADD CONSTRAINT ch_bolgeler_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ch_bolgeler DROP CONSTRAINT ch_bolgeler_pkey;
       public         	   ths_admin    false    231            e           2606    140828 5   ch_doviz_kurlari ch_doviz_kurlari_kur_tarihi_para_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_kur_tarihi_para_key UNIQUE (kur_tarihi, para);
 _   ALTER TABLE ONLY public.ch_doviz_kurlari DROP CONSTRAINT ch_doviz_kurlari_kur_tarihi_para_key;
       public         	   ths_admin    false    233    233            g           2606    140830 &   ch_doviz_kurlari ch_doviz_kurlari_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.ch_doviz_kurlari DROP CONSTRAINT ch_doviz_kurlari_pkey;
       public         	   ths_admin    false    233            i           2606    140832    ch_gruplar ch_gruplar_grup_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.ch_gruplar
    ADD CONSTRAINT ch_gruplar_grup_key UNIQUE (grup);
 H   ALTER TABLE ONLY public.ch_gruplar DROP CONSTRAINT ch_gruplar_grup_key;
       public         	   ths_admin    false    234            k           2606    140834    ch_gruplar ch_gruplar_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.ch_gruplar
    ADD CONSTRAINT ch_gruplar_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.ch_gruplar DROP CONSTRAINT ch_gruplar_pkey;
       public         	   ths_admin    false    234            q           2606    140836 (   ch_hesap_planlari ch_hesap_planlari_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.ch_hesap_planlari
    ADD CONSTRAINT ch_hesap_planlari_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.ch_hesap_planlari DROP CONSTRAINT ch_hesap_planlari_pkey;
       public         	   ths_admin    false    237            m           2606    140838 &   ch_hesaplar ch_hesaplar_hesap_kodu_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_hesap_kodu_key UNIQUE (hesap_kodu);
 P   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_hesap_kodu_key;
       public         	   ths_admin    false    235            o           2606    140840    ch_hesaplar ch_hesaplar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_pkey;
       public         	   ths_admin    false    235            s           2606    140842 (   mhs_fis_detaylari mhs_fis_detaylari_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.mhs_fis_detaylari
    ADD CONSTRAINT mhs_fis_detaylari_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.mhs_fis_detaylari DROP CONSTRAINT mhs_fis_detaylari_pkey;
       public         	   ths_admin    false    239            u           2606    140844    mhs_fisler mhs_fisler_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.mhs_fisler
    ADD CONSTRAINT mhs_fisler_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.mhs_fisler DROP CONSTRAINT mhs_fisler_pkey;
       public         	   ths_admin    false    241            w           2606    140846 $   mhs_fisler mhs_fisler_yevmiye_no_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.mhs_fisler
    ADD CONSTRAINT mhs_fisler_yevmiye_no_key UNIQUE (yevmiye_no);
 N   ALTER TABLE ONLY public.mhs_fisler DROP CONSTRAINT mhs_fisler_yevmiye_no_key;
       public         	   ths_admin    false    241            y           2606    140848 .   mhs_transfer_kodlari mhs_transfer_kodlari_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.mhs_transfer_kodlari
    ADD CONSTRAINT mhs_transfer_kodlari_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.mhs_transfer_kodlari DROP CONSTRAINT mhs_transfer_kodlari_pkey;
       public         	   ths_admin    false    243            {           2606    140850 ;   mhs_transfer_kodlari mhs_transfer_kodlari_transfer_kodu_key 
   CONSTRAINT        ALTER TABLE ONLY public.mhs_transfer_kodlari
    ADD CONSTRAINT mhs_transfer_kodlari_transfer_kodu_key UNIQUE (transfer_kodu);
 e   ALTER TABLE ONLY public.mhs_transfer_kodlari DROP CONSTRAINT mhs_transfer_kodlari_transfer_kodu_key;
       public         	   ths_admin    false    243            }           2606    140852 8   prs_ehliyetler prs_ehliyetler_ehliyet_id_personel_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_ehliyet_id_personel_id_key UNIQUE (ehliyet_id, personel_id);
 b   ALTER TABLE ONLY public.prs_ehliyetler DROP CONSTRAINT prs_ehliyetler_ehliyet_id_personel_id_key;
       public         	   ths_admin    false    245    245                       2606    140854 "   prs_ehliyetler prs_ehliyetler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.prs_ehliyetler DROP CONSTRAINT prs_ehliyetler_pkey;
       public         	   ths_admin    false    245            �           2606    140856 @   prs_lisan_bilgileri prs_lisan_bilgileri_lisan_id_personel_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_lisan_id_personel_id_key UNIQUE (lisan_id, personel_id);
 j   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_lisan_id_personel_id_key;
       public         	   ths_admin    false    246    246            �           2606    140858 ,   prs_lisan_bilgileri prs_lisan_bilgileri_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_pkey;
       public         	   ths_admin    false    246            �           2606    140860 $   prs_personeller prs_personeller_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_pkey;
       public         	   ths_admin    false    249            �           2606    140862 .   sat_fatura_detaylari sat_fatura_detaylari_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.sat_fatura_detaylari
    ADD CONSTRAINT sat_fatura_detaylari_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.sat_fatura_detaylari DROP CONSTRAINT sat_fatura_detaylari_pkey;
       public         	   ths_admin    false    271            �           2606    140864     sat_faturalar sat_faturalar_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.sat_faturalar
    ADD CONSTRAINT sat_faturalar_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.sat_faturalar DROP CONSTRAINT sat_faturalar_pkey;
       public         	   ths_admin    false    273            �           2606    140866 2   sat_irsaliye_detaylari sat_irsaliye_detaylari_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.sat_irsaliye_detaylari
    ADD CONSTRAINT sat_irsaliye_detaylari_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.sat_irsaliye_detaylari DROP CONSTRAINT sat_irsaliye_detaylari_pkey;
       public         	   ths_admin    false    275            �           2606    140868 $   sat_irsaliyeler sat_irsaliyeler_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.sat_irsaliyeler
    ADD CONSTRAINT sat_irsaliyeler_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.sat_irsaliyeler DROP CONSTRAINT sat_irsaliyeler_pkey;
       public         	   ths_admin    false    277            �           2606    140870 0   sat_siparis_detaylari sat_siparis_detaylari_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_pkey;
       public         	   ths_admin    false    279            �           2606    140872 "   sat_siparisler sat_siparisler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_pkey;
       public         	   ths_admin    false    281            �           2606    140874 .   sat_teklif_detaylari sat_teklif_detaylari_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_pkey;
       public         	   ths_admin    false    288            �           2606    140876 &   sat_teklifler sat_teklif_teklif_no_key 
   CONSTRAINT     f   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklif_teklif_no_key UNIQUE (teklif_no);
 P   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklif_teklif_no_key;
       public         	   ths_admin    false    290            �           2606    140878     sat_teklifler sat_teklifler_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_pkey;
       public         	   ths_admin    false    290            �           2606    140880 9   set_ch_firma_turleri set_acc_firma_turleri_firma_turu_key 
   CONSTRAINT     z   ALTER TABLE ONLY public.set_ch_firma_turleri
    ADD CONSTRAINT set_acc_firma_turleri_firma_turu_key UNIQUE (firma_turu);
 c   ALTER TABLE ONLY public.set_ch_firma_turleri DROP CONSTRAINT set_acc_firma_turleri_firma_turu_key;
       public         	   ths_admin    false    294            �           2606    140882 /   set_ch_firma_turleri set_acc_firma_turleri_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.set_ch_firma_turleri
    ADD CONSTRAINT set_acc_firma_turleri_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY public.set_ch_firma_turleri DROP CONSTRAINT set_acc_firma_turleri_pkey;
       public         	   ths_admin    false    294            �           2606    140884 8   set_ch_firma_tipleri set_ch_firma_tipleri_firma_tipi_key 
   CONSTRAINT     y   ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_firma_tipi_key UNIQUE (firma_tipi);
 b   ALTER TABLE ONLY public.set_ch_firma_tipleri DROP CONSTRAINT set_ch_firma_tipleri_firma_tipi_key;
       public         	   ths_admin    false    292            �           2606    140886 .   set_ch_firma_tipleri set_ch_firma_tipleri_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.set_ch_firma_tipleri DROP CONSTRAINT set_ch_firma_tipleri_pkey;
       public         	   ths_admin    false    292            �           2606    140888 7   set_ch_hesap_tipleri set_ch_hesap_tipleri_hesa_tipi_key 
   CONSTRAINT     x   ALTER TABLE ONLY public.set_ch_hesap_tipleri
    ADD CONSTRAINT set_ch_hesap_tipleri_hesa_tipi_key UNIQUE (hesap_tipi);
 a   ALTER TABLE ONLY public.set_ch_hesap_tipleri DROP CONSTRAINT set_ch_hesap_tipleri_hesa_tipi_key;
       public         	   ths_admin    false    298            �           2606    140890 .   set_ch_hesap_tipleri set_ch_hesap_tipleri_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.set_ch_hesap_tipleri
    ADD CONSTRAINT set_ch_hesap_tipleri_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.set_ch_hesap_tipleri DROP CONSTRAINT set_ch_hesap_tipleri_pkey;
       public         	   ths_admin    false    298            �           2606    140892 0   set_ch_vergi_oranlari set_ch_vergi_oranlari_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_pkey;
       public         	   ths_admin    false    300            �           2606    140894 :   set_ch_vergi_oranlari set_ch_vergi_oranlari_veri_orani_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_veri_orani_key UNIQUE (vergi_orani);
 d   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_veri_orani_key;
       public         	   ths_admin    false    300            �           2606    140896 ?   set_einv_fatura_tipleri set_einv_fatura_tipleri_fatura_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_fatura_tipleri
    ADD CONSTRAINT set_einv_fatura_tipleri_fatura_tipi_key UNIQUE (fatura_tipi);
 i   ALTER TABLE ONLY public.set_einv_fatura_tipleri DROP CONSTRAINT set_einv_fatura_tipleri_fatura_tipi_key;
       public         	   ths_admin    false    302            �           2606    140898 4   set_einv_fatura_tipleri set_einv_fatura_tipleri_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.set_einv_fatura_tipleri
    ADD CONSTRAINT set_einv_fatura_tipleri_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.set_einv_fatura_tipleri DROP CONSTRAINT set_einv_fatura_tipleri_pkey;
       public         	   ths_admin    false    302            �           2606    140900 6   set_einv_odeme_sekilleri set_einv_odeme_sekilleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.set_einv_odeme_sekilleri
    ADD CONSTRAINT set_einv_odeme_sekilleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.set_einv_odeme_sekilleri DROP CONSTRAINT set_einv_odeme_sekilleri_pkey;
       public         	   ths_admin    false    304            �           2606    140902 A   set_einv_odeme_sekilleri set_einv_odeme_sekli_odeme_sekilleri_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_odeme_sekilleri
    ADD CONSTRAINT set_einv_odeme_sekli_odeme_sekilleri_key UNIQUE (odeme_sekli);
 k   ALTER TABLE ONLY public.set_einv_odeme_sekilleri DROP CONSTRAINT set_einv_odeme_sekli_odeme_sekilleri_key;
       public         	   ths_admin    false    304            �           2606    140904 5   set_einv_paket_tipleri set_einv_paket_tipleri_kod_key 
   CONSTRAINT     o   ALTER TABLE ONLY public.set_einv_paket_tipleri
    ADD CONSTRAINT set_einv_paket_tipleri_kod_key UNIQUE (kod);
 _   ALTER TABLE ONLY public.set_einv_paket_tipleri DROP CONSTRAINT set_einv_paket_tipleri_kod_key;
       public         	   ths_admin    false    306            �           2606    140906 2   set_einv_paket_tipleri set_einv_paket_tipleri_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.set_einv_paket_tipleri
    ADD CONSTRAINT set_einv_paket_tipleri_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.set_einv_paket_tipleri DROP CONSTRAINT set_einv_paket_tipleri_pkey;
       public         	   ths_admin    false    306            �           2606    140908 8   set_einv_tasima_ucretleri set_einv_tasima_ucretleri_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.set_einv_tasima_ucretleri
    ADD CONSTRAINT set_einv_tasima_ucretleri_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.set_einv_tasima_ucretleri DROP CONSTRAINT set_einv_tasima_ucretleri_pkey;
       public         	   ths_admin    false    308            �           2606    140910 E   set_einv_tasima_ucretleri set_einv_tasima_ucretleri_tasima_ucreti_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_tasima_ucretleri
    ADD CONSTRAINT set_einv_tasima_ucretleri_tasima_ucreti_key UNIQUE (tasima_ucreti);
 o   ALTER TABLE ONLY public.set_einv_tasima_ucretleri DROP CONSTRAINT set_einv_tasima_ucretleri_tasima_ucreti_key;
       public         	   ths_admin    false    308            �           2606    140912 8   set_einv_teslim_sekilleri set_einv_teslim_sekilleri_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.set_einv_teslim_sekilleri
    ADD CONSTRAINT set_einv_teslim_sekilleri_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.set_einv_teslim_sekilleri DROP CONSTRAINT set_einv_teslim_sekilleri_pkey;
       public         	   ths_admin    false    310            �           2606    140914 D   set_einv_teslim_sekilleri set_einv_teslim_sekilleri_teslim_sekli_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_teslim_sekilleri
    ADD CONSTRAINT set_einv_teslim_sekilleri_teslim_sekli_key UNIQUE (teslim_sekli);
 n   ALTER TABLE ONLY public.set_einv_teslim_sekilleri DROP CONSTRAINT set_einv_teslim_sekilleri_teslim_sekli_key;
       public         	   ths_admin    false    310            �           2606    140916 4   set_prs_birimler set_prs_birimler_birim_bolum_id_key 
   CONSTRAINT     z   ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_birim_bolum_id_key UNIQUE (birim, bolum_id);
 ^   ALTER TABLE ONLY public.set_prs_birimler DROP CONSTRAINT set_prs_birimler_birim_bolum_id_key;
       public         	   ths_admin    false    312    312            �           2606    140918 &   set_prs_birimler set_prs_birimler_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_birimler DROP CONSTRAINT set_prs_birimler_pkey;
       public         	   ths_admin    false    312            �           2606    140920 +   set_prs_bolumler set_prs_bolumler_bolum_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.set_prs_bolumler
    ADD CONSTRAINT set_prs_bolumler_bolum_key UNIQUE (bolum);
 U   ALTER TABLE ONLY public.set_prs_bolumler DROP CONSTRAINT set_prs_bolumler_bolum_key;
       public         	   ths_admin    false    314            �           2606    140922 &   set_prs_bolumler set_prs_bolumler_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_bolumler
    ADD CONSTRAINT set_prs_bolumler_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_bolumler DROP CONSTRAINT set_prs_bolumler_pkey;
       public         	   ths_admin    false    314                        2606    140924 1   set_prs_ehliyetler set_prs_ehliyetler_ehliyet_key 
   CONSTRAINT     o   ALTER TABLE ONLY public.set_prs_ehliyetler
    ADD CONSTRAINT set_prs_ehliyetler_ehliyet_key UNIQUE (ehliyet);
 [   ALTER TABLE ONLY public.set_prs_ehliyetler DROP CONSTRAINT set_prs_ehliyetler_ehliyet_key;
       public         	   ths_admin    false    316                       2606    140926 *   set_prs_ehliyetler set_prs_ehliyetler_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.set_prs_ehliyetler
    ADD CONSTRAINT set_prs_ehliyetler_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.set_prs_ehliyetler DROP CONSTRAINT set_prs_ehliyetler_pkey;
       public         	   ths_admin    false    316                       2606    140928 +   set_prs_gorevler set_prs_gorevler_gorev_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.set_prs_gorevler
    ADD CONSTRAINT set_prs_gorevler_gorev_key UNIQUE (gorev);
 U   ALTER TABLE ONLY public.set_prs_gorevler DROP CONSTRAINT set_prs_gorevler_gorev_key;
       public         	   ths_admin    false    318                       2606    140930 &   set_prs_gorevler set_prs_gorevler_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_gorevler
    ADD CONSTRAINT set_prs_gorevler_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_gorevler DROP CONSTRAINT set_prs_gorevler_pkey;
       public         	   ths_admin    false    318                       2606    140932 D   set_prs_lisan_seviyeleri set_prs_lisan_seviyeleri_lisan_seviyesi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri
    ADD CONSTRAINT set_prs_lisan_seviyeleri_lisan_seviyesi_key UNIQUE (lisan_seviyesi);
 n   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri DROP CONSTRAINT set_prs_lisan_seviyeleri_lisan_seviyesi_key;
       public         	   ths_admin    false    322                       2606    140934 6   set_prs_lisan_seviyeleri set_prs_lisan_seviyeleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri
    ADD CONSTRAINT set_prs_lisan_seviyeleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri DROP CONSTRAINT set_prs_lisan_seviyeleri_pkey;
       public         	   ths_admin    false    322                       2606    140936 +   set_prs_lisanlar set_prs_lisanlar_lisan_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.set_prs_lisanlar
    ADD CONSTRAINT set_prs_lisanlar_lisan_key UNIQUE (lisan);
 U   ALTER TABLE ONLY public.set_prs_lisanlar DROP CONSTRAINT set_prs_lisanlar_lisan_key;
       public         	   ths_admin    false    320            
           2606    140938 &   set_prs_lisanlar set_prs_lisanlar_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_lisanlar
    ADD CONSTRAINT set_prs_lisanlar_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_lisanlar DROP CONSTRAINT set_prs_lisanlar_pkey;
       public         	   ths_admin    false    320                       2606    140940 C   set_prs_personel_tipleri set_prs_personel_tipleri_personel_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_prs_personel_tipleri
    ADD CONSTRAINT set_prs_personel_tipleri_personel_tipi_key UNIQUE (personel_tipi);
 m   ALTER TABLE ONLY public.set_prs_personel_tipleri DROP CONSTRAINT set_prs_personel_tipleri_personel_tipi_key;
       public         	   ths_admin    false    324                       2606    140942 6   set_prs_personel_tipleri set_prs_personel_tipleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.set_prs_personel_tipleri
    ADD CONSTRAINT set_prs_personel_tipleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.set_prs_personel_tipleri DROP CONSTRAINT set_prs_personel_tipleri_pkey;
       public         	   ths_admin    false    324                       2606    140944 ?   set_prs_tasima_servisleri set_prs_tasima_servisleri_arac_no_key 
   CONSTRAINT     }   ALTER TABLE ONLY public.set_prs_tasima_servisleri
    ADD CONSTRAINT set_prs_tasima_servisleri_arac_no_key UNIQUE (arac_no);
 i   ALTER TABLE ONLY public.set_prs_tasima_servisleri DROP CONSTRAINT set_prs_tasima_servisleri_arac_no_key;
       public         	   ths_admin    false    326                       2606    140946 8   set_prs_tasima_servisleri set_prs_tasima_servisleri_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.set_prs_tasima_servisleri
    ADD CONSTRAINT set_prs_tasima_servisleri_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.set_prs_tasima_servisleri DROP CONSTRAINT set_prs_tasima_servisleri_pkey;
       public         	   ths_admin    false    326            �           2606    140948 /   set_sls_order_status set_sat_siparis_durum_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.set_sls_order_status
    ADD CONSTRAINT set_sat_siparis_durum_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY public.set_sls_order_status DROP CONSTRAINT set_sat_siparis_durum_pkey;
       public         	   ths_admin    false    283            �           2606    140950 <   set_sls_order_status set_sat_siparis_durum_siparis_durum_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_sls_order_status
    ADD CONSTRAINT set_sat_siparis_durum_siparis_durum_key UNIQUE (siparis_durum);
 f   ALTER TABLE ONLY public.set_sls_order_status DROP CONSTRAINT set_sat_siparis_durum_siparis_durum_key;
       public         	   ths_admin    false    283                       2606    140952 .   set_sls_offer_status set_sat_teklif_durum_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.set_sls_offer_status
    ADD CONSTRAINT set_sat_teklif_durum_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.set_sls_offer_status DROP CONSTRAINT set_sat_teklif_durum_pkey;
       public         	   ths_admin    false    329                       2606    140954 :   set_sls_offer_status set_sat_teklif_durum_teklif_durum_key 
   CONSTRAINT     }   ALTER TABLE ONLY public.set_sls_offer_status
    ADD CONSTRAINT set_sat_teklif_durum_teklif_durum_key UNIQUE (teklif_durum);
 d   ALTER TABLE ONLY public.set_sls_offer_status DROP CONSTRAINT set_sat_teklif_durum_teklif_durum_key;
       public         	   ths_admin    false    329                       2606    140956 '   stk_ambarlar stk_ambarlar_ambar_adi_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.stk_ambarlar
    ADD CONSTRAINT stk_ambarlar_ambar_adi_key UNIQUE (ambar_adi);
 Q   ALTER TABLE ONLY public.stk_ambarlar DROP CONSTRAINT stk_ambarlar_ambar_adi_key;
       public         	   ths_admin    false    331                       2606    140958    stk_ambarlar stk_ambarlar_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.stk_ambarlar
    ADD CONSTRAINT stk_ambarlar_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.stk_ambarlar DROP CONSTRAINT stk_ambarlar_pkey;
       public         	   ths_admin    false    331                        2606    140960 2   stk_cins_ozellikleri stk_cins_ozellikleri_cins_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.stk_cins_ozellikleri
    ADD CONSTRAINT stk_cins_ozellikleri_cins_key UNIQUE (cins);
 \   ALTER TABLE ONLY public.stk_cins_ozellikleri DROP CONSTRAINT stk_cins_ozellikleri_cins_key;
       public         	   ths_admin    false    332            "           2606    140962 .   stk_cins_ozellikleri stk_cins_ozellikleri_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.stk_cins_ozellikleri
    ADD CONSTRAINT stk_cins_ozellikleri_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.stk_cins_ozellikleri DROP CONSTRAINT stk_cins_ozellikleri_pkey;
       public         	   ths_admin    false    332            �           2606    140964     stk_gruplar stk_gruplar_grup_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_grup_key UNIQUE (grup);
 J   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_grup_key;
       public         	   ths_admin    false    284            �           2606    140966    stk_gruplar stk_gruplar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_pkey;
       public         	   ths_admin    false    284            $           2606    140968 "   stk_hareketler stk_hareketler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_pkey;
       public         	   ths_admin    false    334            &           2606    140970 4   stk_kart_cins_bilgileri stk_kart_cins_bilgileri_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.stk_kart_cins_bilgileri
    ADD CONSTRAINT stk_kart_cins_bilgileri_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.stk_kart_cins_bilgileri DROP CONSTRAINT stk_kart_cins_bilgileri_pkey;
       public         	   ths_admin    false    336            (           2606    140972 (   stk_kart_ozetleri stk_kart_ozetleri_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.stk_kart_ozetleri
    ADD CONSTRAINT stk_kart_ozetleri_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.stk_kart_ozetleri DROP CONSTRAINT stk_kart_ozetleri_pkey;
       public         	   ths_admin    false    338            *           2606    140974 3   stk_kart_ozetleri stk_kart_ozetleri_stk_kart_id_key 
   CONSTRAINT     u   ALTER TABLE ONLY public.stk_kart_ozetleri
    ADD CONSTRAINT stk_kart_ozetleri_stk_kart_id_key UNIQUE (stk_kart_id);
 ]   ALTER TABLE ONLY public.stk_kart_ozetleri DROP CONSTRAINT stk_kart_ozetleri_stk_kart_id_key;
       public         	   ths_admin    false    338            �           2606    140976    stk_kartlar stk_kartlar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_pkey;
       public         	   ths_admin    false    285            �           2606    140978 %   stk_kartlar stk_kartlar_stok_kodu_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_stok_kodu_key UNIQUE (stok_kodu);
 O   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_stok_kodu_key;
       public         	   ths_admin    false    285            ,           2606    140980    stk_resimler stk_resimler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.stk_resimler
    ADD CONSTRAINT stk_resimler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.stk_resimler DROP CONSTRAINT stk_resimler_pkey;
       public         	   ths_admin    false    341            .           2606    140982 )   stk_resimler stk_resimler_stk_kart_id_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.stk_resimler
    ADD CONSTRAINT stk_resimler_stk_kart_id_key UNIQUE (stk_kart_id);
 S   ALTER TABLE ONLY public.stk_resimler DROP CONSTRAINT stk_resimler_stk_kart_id_key;
       public         	   ths_admin    false    341            0           2606    140984    sys_adresler sys_adresler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_adresler
    ADD CONSTRAINT sys_adresler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_adresler DROP CONSTRAINT sys_adresler_pkey;
       public         	   ths_admin    false    345            2           2606    140986    sys_aylar sys_aylar_ay_adi_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.sys_aylar
    ADD CONSTRAINT sys_aylar_ay_adi_key UNIQUE (ay_adi);
 H   ALTER TABLE ONLY public.sys_aylar DROP CONSTRAINT sys_aylar_ay_adi_key;
       public         	   ths_admin    false    347            4           2606    140988    sys_aylar sys_aylar_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.sys_aylar
    ADD CONSTRAINT sys_aylar_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.sys_aylar DROP CONSTRAINT sys_aylar_pkey;
       public         	   ths_admin    false    347            6           2606    140990 #   sys_bolgeler sys_bolgeler_bolge_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.sys_bolgeler
    ADD CONSTRAINT sys_bolgeler_bolge_key UNIQUE (bolge);
 M   ALTER TABLE ONLY public.sys_bolgeler DROP CONSTRAINT sys_bolgeler_bolge_key;
       public         	   ths_admin    false    349            8           2606    140992    sys_bolgeler sys_bolgeler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_bolgeler
    ADD CONSTRAINT sys_bolgeler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_bolgeler DROP CONSTRAINT sys_bolgeler_pkey;
       public         	   ths_admin    false    349            :           2606    140994 >   sys_ersim_haklari sys_ersim_haklari_kaynak_id_kullanici_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kaynak_id_kullanici_id_key UNIQUE (kaynak_id, kullanici_id);
 h   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_kaynak_id_kullanici_id_key;
       public         	   ths_admin    false    352    352            <           2606    140996 (   sys_ersim_haklari sys_ersim_haklari_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_pkey;
       public         	   ths_admin    false    352            >           2606    140998 B   sys_grid_filtreler_siralamalar sys_grid_filtreler_siralamalar_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar
    ADD CONSTRAINT sys_grid_filtreler_siralamalar_pkey PRIMARY KEY (id);
 l   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar DROP CONSTRAINT sys_grid_filtreler_siralamalar_pkey;
       public         	   ths_admin    false    354            @           2606    141000 W   sys_grid_filtreler_siralamalar sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar
    ADD CONSTRAINT sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key UNIQUE (tablo_adi, is_siralama);
 �   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar DROP CONSTRAINT sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key;
       public         	   ths_admin    false    354    354            B           2606    141002 (   sys_grid_kolonlar sys_grid_kolonlar_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.sys_grid_kolonlar DROP CONSTRAINT sys_grid_kolonlar_pkey;
       public         	   ths_admin    false    356            D           2606    141004 ;   sys_grid_kolonlar sys_grid_kolonlar_tablo_adi_kolon_adi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_tablo_adi_kolon_adi_key UNIQUE (tablo_adi, kolon_adi);
 e   ALTER TABLE ONLY public.sys_grid_kolonlar DROP CONSTRAINT sys_grid_kolonlar_tablo_adi_kolon_adi_key;
       public         	   ths_admin    false    356    356            F           2606    141006 9   sys_grid_kolonlar sys_grid_kolonlar_tablo_adi_sira_no_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_tablo_adi_sira_no_key UNIQUE (tablo_adi, sira_no);
 c   ALTER TABLE ONLY public.sys_grid_kolonlar DROP CONSTRAINT sys_grid_kolonlar_tablo_adi_sira_no_key;
       public         	   ths_admin    false    356    356            H           2606    141008 !   sys_gunler sys_gunler_gun_adi_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.sys_gunler
    ADD CONSTRAINT sys_gunler_gun_adi_key UNIQUE (gun_adi);
 K   ALTER TABLE ONLY public.sys_gunler DROP CONSTRAINT sys_gunler_gun_adi_key;
       public         	   ths_admin    false    358            J           2606    141010    sys_gunler sys_gunler_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.sys_gunler
    ADD CONSTRAINT sys_gunler_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.sys_gunler DROP CONSTRAINT sys_gunler_pkey;
       public         	   ths_admin    false    358            L           2606    141012 1   sys_kaynak_gruplari sys_kaynak_gruplari_grup_ukey 
   CONSTRAINT     l   ALTER TABLE ONLY public.sys_kaynak_gruplari
    ADD CONSTRAINT sys_kaynak_gruplari_grup_ukey UNIQUE (grup);
 [   ALTER TABLE ONLY public.sys_kaynak_gruplari DROP CONSTRAINT sys_kaynak_gruplari_grup_ukey;
       public         	   ths_admin    false    360            N           2606    141014 /   sys_kaynak_gruplari sys_kaynak_gruplari_id_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.sys_kaynak_gruplari
    ADD CONSTRAINT sys_kaynak_gruplari_id_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY public.sys_kaynak_gruplari DROP CONSTRAINT sys_kaynak_gruplari_id_pkey;
       public         	   ths_admin    false    360            P           2606    141016 +   sys_kaynaklar sys_kaynaklar_kaynak_kodu_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_kaynak_kodu_key UNIQUE (kaynak_kodu);
 U   ALTER TABLE ONLY public.sys_kaynaklar DROP CONSTRAINT sys_kaynaklar_kaynak_kodu_key;
       public         	   ths_admin    false    362            R           2606    141018     sys_kaynaklar sys_kaynaklar_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.sys_kaynaklar DROP CONSTRAINT sys_kaynaklar_pkey;
       public         	   ths_admin    false    362            X           2606    141020 S   sys_lisan_gui_icerikler sys_lisan_gui_icerikler_lisan_kod_icerik_tipi_tablo_adi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_lisan_gui_icerikler
    ADD CONSTRAINT sys_lisan_gui_icerikler_lisan_kod_icerik_tipi_tablo_adi_key UNIQUE (lisan, kod, icerik_tipi, tablo_adi);
 }   ALTER TABLE ONLY public.sys_lisan_gui_icerikler DROP CONSTRAINT sys_lisan_gui_icerikler_lisan_kod_icerik_tipi_tablo_adi_key;
       public         	   ths_admin    false    366    366    366    366            Z           2606    141022 4   sys_lisan_gui_icerikler sys_lisan_gui_icerikler_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.sys_lisan_gui_icerikler
    ADD CONSTRAINT sys_lisan_gui_icerikler_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.sys_lisan_gui_icerikler DROP CONSTRAINT sys_lisan_gui_icerikler_pkey;
       public         	   ths_admin    false    366            \           2606    141024 #   sys_lisanlar sys_lisanlar_lisan_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.sys_lisanlar
    ADD CONSTRAINT sys_lisanlar_lisan_key UNIQUE (lisan);
 M   ALTER TABLE ONLY public.sys_lisanlar DROP CONSTRAINT sys_lisanlar_lisan_key;
       public         	   ths_admin    false    368            ^           2606    141026    sys_lisanlar sys_lisanlar_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_lisanlar
    ADD CONSTRAINT sys_lisanlar_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_lisanlar DROP CONSTRAINT sys_lisanlar_pkey;
       public         	   ths_admin    false    368            h           2606    141028 D   sys_olcu_birimi_tipleri sys_olcu_birimi_tipleri_olcu_birimi_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri
    ADD CONSTRAINT sys_olcu_birimi_tipleri_olcu_birimi_tipi_key UNIQUE (olcu_birimi_tipi);
 n   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri DROP CONSTRAINT sys_olcu_birimi_tipleri_olcu_birimi_tipi_key;
       public         	   ths_admin    false    374            j           2606    141030 4   sys_olcu_birimi_tipleri sys_olcu_birimi_tipleri_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri
    ADD CONSTRAINT sys_olcu_birimi_tipleri_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri DROP CONSTRAINT sys_olcu_birimi_tipleri_pkey;
       public         	   ths_admin    false    374            d           2606    141032 /   sys_olcu_birimleri sys_olcu_birimleri_birim_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_birim_key UNIQUE (birim);
 Y   ALTER TABLE ONLY public.sys_olcu_birimleri DROP CONSTRAINT sys_olcu_birimleri_birim_key;
       public         	   ths_admin    false    372            f           2606    141034 *   sys_olcu_birimleri sys_olcu_birimleri_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.sys_olcu_birimleri DROP CONSTRAINT sys_olcu_birimleri_pkey;
       public         	   ths_admin    false    372            l           2606    141036 ,   sys_ondalik_haneler sys_ondalik_haneler_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.sys_ondalik_haneler
    ADD CONSTRAINT sys_ondalik_haneler_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.sys_ondalik_haneler DROP CONSTRAINT sys_ondalik_haneler_pkey;
       public         	   ths_admin    false    376            n           2606    141038 .   sys_para_birimleri sys_para_birimleri_para_key 
   CONSTRAINT     i   ALTER TABLE ONLY public.sys_para_birimleri
    ADD CONSTRAINT sys_para_birimleri_para_key UNIQUE (para);
 X   ALTER TABLE ONLY public.sys_para_birimleri DROP CONSTRAINT sys_para_birimleri_para_key;
       public         	   ths_admin    false    378            p           2606    141040 *   sys_para_birimleri sys_para_birimleri_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.sys_para_birimleri
    ADD CONSTRAINT sys_para_birimleri_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.sys_para_birimleri DROP CONSTRAINT sys_para_birimleri_pkey;
       public         	   ths_admin    false    378            �           2606    141042    sys_sehirler sys_sehirler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_pkey;
       public         	   ths_admin    false    286            �           2606    141044 +   sys_sehirler sys_sehirler_ulke_id_sehir_key 
   CONSTRAINT     p   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_ulke_id_sehir_key UNIQUE (ulke_id, sehir);
 U   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_ulke_id_sehir_key;
       public         	   ths_admin    false    286    286            r           2606    141046    sys_ulkeler sys_ulkeler_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.sys_ulkeler
    ADD CONSTRAINT sys_ulkeler_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.sys_ulkeler DROP CONSTRAINT sys_ulkeler_pkey;
       public         	   ths_admin    false    381            t           2606    141048 %   sys_ulkeler sys_ulkeler_ulke_kodu_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.sys_ulkeler
    ADD CONSTRAINT sys_ulkeler_ulke_kodu_key UNIQUE (ulke_kodu);
 O   ALTER TABLE ONLY public.sys_ulkeler DROP CONSTRAINT sys_ulkeler_ulke_kodu_key;
       public         	   ths_admin    false    381            T           2606    141050    sys_kullanicilar sys_users_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_pkey PRIMARY KEY (id);
 I   ALTER TABLE ONLY public.sys_kullanicilar DROP CONSTRAINT sys_users_pkey;
       public         	   ths_admin    false    364            V           2606    141052 '   sys_kullanicilar sys_users_username_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_username_key UNIQUE (kullanici_adi);
 Q   ALTER TABLE ONLY public.sys_kullanicilar DROP CONSTRAINT sys_users_username_key;
       public         	   ths_admin    false    364            v           2606    141054 0   sys_uygulama_ayarlari sys_uygulama_ayarlari_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_pkey;
       public         	   ths_admin    false    383            `           2606    141056 G   sys_vergi_mukellef_tipleri sys_vergi_mukellef_tipleri_mukellef_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_vergi_mukellef_tipleri
    ADD CONSTRAINT sys_vergi_mukellef_tipleri_mukellef_tipi_key UNIQUE (mukellef_tipi);
 q   ALTER TABLE ONLY public.sys_vergi_mukellef_tipleri DROP CONSTRAINT sys_vergi_mukellef_tipleri_mukellef_tipi_key;
       public         	   ths_admin    false    370            b           2606    141058 :   sys_vergi_mukellef_tipleri sys_vergi_mukellef_tipleri_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.sys_vergi_mukellef_tipleri
    ADD CONSTRAINT sys_vergi_mukellef_tipleri_pkey PRIMARY KEY (id);
 d   ALTER TABLE ONLY public.sys_vergi_mukellef_tipleri DROP CONSTRAINT sys_vergi_mukellef_tipleri_pkey;
       public         	   ths_admin    false    370            �           2606    141060 ,   urt_iscilikler urt_iscilikler_gider_kodu_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_gider_kodu_key UNIQUE (gider_kodu);
 V   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_gider_kodu_key;
       public         	   ths_admin    false    251            �           2606    141062 "   urt_iscilikler urt_iscilikler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_pkey;
       public         	   ths_admin    false    251            �           2606    141064 >   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_pkey;
       public         	   ths_admin    false    253            �           2606    141066 Q   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_stok_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_header_id_key UNIQUE (stok_kodu, header_id);
 {   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_header_id_key;
       public         	   ths_admin    false    253    253            �           2606    141068 9   urt_paket_hammaddeler urt_paket_hammaddeler_paket_adi_key 
   CONSTRAINT     y   ALTER TABLE ONLY public.urt_paket_hammaddeler
    ADD CONSTRAINT urt_paket_hammaddeler_paket_adi_key UNIQUE (paket_adi);
 c   ALTER TABLE ONLY public.urt_paket_hammaddeler DROP CONSTRAINT urt_paket_hammaddeler_paket_adi_key;
       public         	   ths_admin    false    255            �           2606    141070 0   urt_paket_hammaddeler urt_paket_hammaddeler_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.urt_paket_hammaddeler
    ADD CONSTRAINT urt_paket_hammaddeler_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.urt_paket_hammaddeler DROP CONSTRAINT urt_paket_hammaddeler_pkey;
       public         	   ths_admin    false    255            �           2606    141072 <   urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_pkey PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_paket_iscilik_detaylari_pkey;
       public         	   ths_admin    false    257            �           2606    141074 7   urt_paket_iscilikler urt_paket_iscilikler_paket_adi_key 
   CONSTRAINT     w   ALTER TABLE ONLY public.urt_paket_iscilikler
    ADD CONSTRAINT urt_paket_iscilikler_paket_adi_key UNIQUE (paket_adi);
 a   ALTER TABLE ONLY public.urt_paket_iscilikler DROP CONSTRAINT urt_paket_iscilikler_paket_adi_key;
       public         	   ths_admin    false    259            �           2606    141076 .   urt_paket_iscilikler urt_paket_iscilikler_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.urt_paket_iscilikler
    ADD CONSTRAINT urt_paket_iscilikler_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.urt_paket_iscilikler DROP CONSTRAINT urt_paket_iscilikler_pkey;
       public         	   ths_admin    false    259            �           2606    141078 2   urt_recete_hammaddeler urt_recete_hammaddeler_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_pkey;
       public         	   ths_admin    false    261            �           2606    141080 E   urt_recete_hammaddeler urt_recete_hammaddeler_stok_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_stok_kodu_header_id_key UNIQUE (stok_kodu, header_id);
 o   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_stok_kodu_header_id_key;
       public         	   ths_admin    false    261    261            �           2606    141082 <   urt_recete_iscilikler urt_recete_iscilikler_iscilik_kodu_key 
   CONSTRAINT        ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_iscilik_kodu_key UNIQUE (iscilik_kodu);
 f   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_iscilik_kodu_key;
       public         	   ths_admin    false    265            �           2606    141084 0   urt_recete_iscilikler urt_recete_iscilikler_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_pkey;
       public         	   ths_admin    false    265            �           2606    141086 P   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_header_id_paket_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_header_id_paket_id_key UNIQUE (header_id, paket_id);
 z   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_header_id_paket_id_key;
       public         	   ths_admin    false    267    267            �           2606    141088 >   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_pkey;
       public         	   ths_admin    false    267            �           2606    141090 Y   urt_paket_iscilik_detaylari urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key UNIQUE (iscilik_kodu, header_id);
 �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key;
       public         	   ths_admin    false    257    257            �           2606    141092 N   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_header_id_paket_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_header_id_paket_id_key UNIQUE (header_id, paket_id);
 x   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_header_id_paket_id_key;
       public         	   ths_admin    false    269    269            �           2606    141094 <   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_pkey PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_pkey;
       public         	   ths_admin    false    269            x           2606    141096 2   urt_recete_yan_urunler urt_recete_yan_urunler_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_pkey;
       public         	   ths_admin    false    388            z           2606    141098 E   urt_recete_yan_urunler urt_recete_yan_urunler_urun_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_urun_kodu_header_id_key UNIQUE (urun_kodu, header_id);
 o   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_urun_kodu_header_id_key;
       public         	   ths_admin    false    388    388            �           2606    141100     urt_receteler urt_receteler_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.urt_receteler DROP CONSTRAINT urt_receteler_pkey;
       public         	   ths_admin    false    263            �           2606    141102 2   urt_receteler urt_receteler_urun_kodu_urun_adi_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_urun_kodu_urun_adi_key UNIQUE (urun_kodu, urun_adi);
 \   ALTER TABLE ONLY public.urt_receteler DROP CONSTRAINT urt_receteler_urun_kodu_urun_adi_key;
       public         	   ths_admin    false    263    263            Q           1259    141103 "   idx_als_teklif_detaylari_header_id    INDEX     h   CREATE INDEX idx_als_teklif_detaylari_header_id ON public.als_teklif_detaylari USING btree (header_id);
 6   DROP INDEX public.idx_als_teklif_detaylari_header_id;
       public         	   ths_admin    false    221            �           1259    141104 #   idx_sat_siparis_detaylari_header_id    INDEX     j   CREATE INDEX idx_sat_siparis_detaylari_header_id ON public.sat_siparis_detaylari USING btree (header_id);
 7   DROP INDEX public.idx_sat_siparis_detaylari_header_id;
       public         	   ths_admin    false    279            �           1259    141105    idx_sat_siparis_musteri_kodu    INDEX     _   CREATE INDEX idx_sat_siparis_musteri_kodu ON public.sat_siparisler USING btree (musteri_kodu);
 0   DROP INDEX public.idx_sat_siparis_musteri_kodu;
       public         	   ths_admin    false    281            �           1259    141106 "   idx_sat_teklif_detaylari_header_id    INDEX     h   CREATE INDEX idx_sat_teklif_detaylari_header_id ON public.sat_teklif_detaylari USING btree (header_id);
 6   DROP INDEX public.idx_sat_teklif_detaylari_header_id;
       public         	   ths_admin    false    288                       2620    141107    set_prs_bolumler audit    TRIGGER        CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_bolumler FOR EACH ROW EXECUTE FUNCTION public.audit();
 /   DROP TRIGGER audit ON public.set_prs_bolumler;
       public       	   ths_admin    false    512    314            �           2620    141108    prs_ehliyetler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prs_ehliyetler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 .   DROP TRIGGER notify ON public.prs_ehliyetler;
       public       	   ths_admin    false    500    245            �           2620    141109    prs_lisan_bilgileri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prs_lisan_bilgileri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 3   DROP TRIGGER notify ON public.prs_lisan_bilgileri;
       public       	   ths_admin    false    246    500            �           2620    141110    prs_personeller notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prs_personeller FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER notify ON public.prs_personeller;
       public       	   ths_admin    false    249    500                       2620    141111    set_prs_birimler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_birimler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 0   DROP TRIGGER notify ON public.set_prs_birimler;
       public       	   ths_admin    false    500    312            	           2620    141112    set_prs_ehliyetler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_ehliyetler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 2   DROP TRIGGER notify ON public.set_prs_ehliyetler;
       public       	   ths_admin    false    316    500            
           2620    141113    set_prs_gorevler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_gorevler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 0   DROP TRIGGER notify ON public.set_prs_gorevler;
       public       	   ths_admin    false    500    318                       2620    141114    set_prs_lisan_seviyeleri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_lisan_seviyeleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER notify ON public.set_prs_lisan_seviyeleri;
       public       	   ths_admin    false    500    322                       2620    141115    set_prs_lisanlar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_lisanlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 0   DROP TRIGGER notify ON public.set_prs_lisanlar;
       public       	   ths_admin    false    500    320                       2620    141116    set_prs_personel_tipleri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_personel_tipleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER notify ON public.set_prs_personel_tipleri;
       public       	   ths_admin    false    324    500                       2620    141117     set_prs_tasima_servisleri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_tasima_servisleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER notify ON public.set_prs_tasima_servisleri;
       public       	   ths_admin    false    326    500                       2620    141118    stk_ambarlar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_ambarlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 ,   DROP TRIGGER notify ON public.stk_ambarlar;
       public       	   ths_admin    false    331    500                       2620    141119    stk_gruplar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_gruplar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 +   DROP TRIGGER notify ON public.stk_gruplar;
       public       	   ths_admin    false    500    284                       2620    141120    stk_hareketler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_hareketler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 .   DROP TRIGGER notify ON public.stk_hareketler;
       public       	   ths_admin    false    334    500                       2620    141121    stk_kart_cins_bilgileri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_kart_cins_bilgileri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 7   DROP TRIGGER notify ON public.stk_kart_cins_bilgileri;
       public       	   ths_admin    false    336    500                       2620    141122    stk_kartlar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_kartlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 +   DROP TRIGGER notify ON public.stk_kartlar;
       public       	   ths_admin    false    285    500                       2620    141123 1   sys_grid_kolonlar sys_grid_col_width_table_notify    TRIGGER     �   CREATE TRIGGER sys_grid_col_width_table_notify AFTER INSERT OR DELETE OR UPDATE ON public.sys_grid_kolonlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 J   DROP TRIGGER sys_grid_col_width_table_notify ON public.sys_grid_kolonlar;
       public       	   ths_admin    false    356    500                       2620    141124    set_prs_bolumler table_notify    TRIGGER     �   CREATE TRIGGER table_notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_bolumler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 6   DROP TRIGGER table_notify ON public.set_prs_bolumler;
       public       	   ths_admin    false    500    314                       2620    141125 !   stk_cins_ozellikleri table_notify    TRIGGER     �   CREATE TRIGGER table_notify BEFORE INSERT OR DELETE OR UPDATE ON public.stk_cins_ozellikleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 :   DROP TRIGGER table_notify ON public.stk_cins_ozellikleri;
       public       	   ths_admin    false    332    500            �           2620    141126    ch_banka_subeleri trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_banka_subeleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 5   DROP TRIGGER trg_notify ON public.ch_banka_subeleri;
       public       	   ths_admin    false    500    229            �           2620    141127    ch_bankalar trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_bankalar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER trg_notify ON public.ch_bankalar;
       public       	   ths_admin    false    500    227            �           2620    141128    ch_bolgeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_bolgeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER trg_notify ON public.ch_bolgeler;
       public       	   ths_admin    false    231    500            �           2620    141129    ch_doviz_kurlari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_doviz_kurlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 4   DROP TRIGGER trg_notify ON public.ch_doviz_kurlari;
       public       	   ths_admin    false    233    500            �           2620    141130    ch_hesaplar trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_hesaplar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER trg_notify ON public.ch_hesaplar;
       public       	   ths_admin    false    500    235            �           2620    141131    mhs_fis_detaylari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.mhs_fis_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 5   DROP TRIGGER trg_notify ON public.mhs_fis_detaylari;
       public       	   ths_admin    false    500    239            �           2620    141132    mhs_fisler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.mhs_fisler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 .   DROP TRIGGER trg_notify ON public.mhs_fisler;
       public       	   ths_admin    false    500    241            �           2620    141133    mhs_transfer_kodlari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.mhs_transfer_kodlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER trg_notify ON public.mhs_transfer_kodlari;
       public       	   ths_admin    false    500    243                       2620    141134     set_ch_vergi_oranlari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.set_ch_vergi_oranlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER trg_notify ON public.set_ch_vergi_oranlari;
       public       	   ths_admin    false    300    500            �           2620    141135    urt_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 2   DROP TRIGGER trg_notify ON public.urt_iscilikler;
       public       	   ths_admin    false    500    251            �           2620    141136 '   urt_paket_hammadde_detaylari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_hammadde_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 @   DROP TRIGGER trg_notify ON public.urt_paket_hammadde_detaylari;
       public       	   ths_admin    false    253    500            �           2620    141137     urt_paket_hammaddeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER trg_notify ON public.urt_paket_hammaddeler;
       public       	   ths_admin    false    500    255            �           2620    141138 &   urt_paket_iscilik_detaylari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_iscilik_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 ?   DROP TRIGGER trg_notify ON public.urt_paket_iscilik_detaylari;
       public       	   ths_admin    false    500    257            �           2620    141139    urt_paket_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER trg_notify ON public.urt_paket_iscilikler;
       public       	   ths_admin    false    259    500            �           2620    141140 !   urt_recete_hammaddeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 :   DROP TRIGGER trg_notify ON public.urt_recete_hammaddeler;
       public       	   ths_admin    false    261    500                        2620    141141     urt_recete_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER trg_notify ON public.urt_recete_iscilikler;
       public       	   ths_admin    false    500    265                       2620    141142 '   urt_recete_paket_hammaddeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_paket_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 @   DROP TRIGGER trg_notify ON public.urt_recete_paket_hammaddeler;
       public       	   ths_admin    false    500    267                       2620    141143 &   urt_recete_paket_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_paket_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 ?   DROP TRIGGER trg_notify ON public.urt_recete_paket_iscilikler;
       public       	   ths_admin    false    500    269                       2620    141144 !   urt_recete_yan_urunler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_yan_urunler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 :   DROP TRIGGER trg_notify ON public.urt_recete_yan_urunler;
       public       	   ths_admin    false    388    500            �           2620    141145    urt_receteler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_receteler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 1   DROP TRIGGER trg_notify ON public.urt_receteler;
       public       	   ths_admin    false    500    263            {           2606    141146 8   als_teklif_detaylari als_teklif_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.als_teklifler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.als_teklif_detaylari DROP CONSTRAINT als_teklif_detaylari_header_id_fkey;
       public       	   ths_admin    false    221    3923    223            |           2606    141151 :   als_teklif_detaylari als_teklif_detaylari_olcu_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_olcu_birimi_fkey FOREIGN KEY (olcu_birimi) REFERENCES public.sys_olcu_birimleri(birim) ON UPDATE CASCADE ON DELETE RESTRICT;
 d   ALTER TABLE ONLY public.als_teklif_detaylari DROP CONSTRAINT als_teklif_detaylari_olcu_birimi_fkey;
       public       	   ths_admin    false    372    221    4196            }           2606    141156 C   als_teklif_detaylari als_teklif_detaylari_referans_ana_urun_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.als_teklif_detaylari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 m   ALTER TABLE ONLY public.als_teklif_detaylari DROP CONSTRAINT als_teklif_detaylari_referans_ana_urun_id_fkey;
       public       	   ths_admin    false    221    221    3920            ~           2606    141161 8   als_teklif_detaylari als_teklif_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 b   ALTER TABLE ONLY public.als_teklif_detaylari DROP CONSTRAINT als_teklif_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    221    4039    285                       2606    141166 .   als_teklifler als_teklifler_islem_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_islem_tipi_id_fkey FOREIGN KEY (islem_tipi_id) REFERENCES public.set_einv_fatura_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_islem_tipi_id_fkey;
       public       	   ths_admin    false    4070    302    223            �           2606    141171 -   als_teklifler als_teklifler_musteri_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_musteri_kodu_fkey FOREIGN KEY (musteri_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_musteri_kodu_fkey;
       public       	   ths_admin    false    223    235    3949            �           2606    141176 ,   als_teklifler als_teklifler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 V   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_para_birimi_fkey;
       public       	   ths_admin    false    4206    223    378            �           2606    141181 )   als_teklifler als_teklifler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_sehir_id_fkey;
       public       	   ths_admin    false    4041    286    223            �           2606    141186 (   als_teklifler als_teklifler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 R   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_ulke_id_fkey;
       public       	   ths_admin    false    4210    223    381            �           2606    141191 1   ch_banka_subeleri ch_banka_subeleri_banka_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_banka_id_fkey FOREIGN KEY (banka_id) REFERENCES public.ch_bankalar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_banka_id_fkey;
       public       	   ths_admin    false    227    229    3931            �           2606    141196 1   ch_banka_subeleri ch_banka_subeleri_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_sehir_id_fkey;
       public       	   ths_admin    false    229    286    4041            �           2606    141201 +   ch_doviz_kurlari ch_doviz_kurlari_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_para_fkey FOREIGN KEY (para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE CASCADE;
 U   ALTER TABLE ONLY public.ch_doviz_kurlari DROP CONSTRAINT ch_doviz_kurlari_para_fkey;
       public       	   ths_admin    false    4206    378    233            �           2606    141206 %   ch_hesaplar ch_hesaplar_bolge_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_bolge_id_fkey FOREIGN KEY (bolge_id) REFERENCES public.ch_hesap_planlari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 O   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_bolge_id_fkey;
       public       	   ths_admin    false    237    235    3953            �           2606    141211 $   ch_hesaplar ch_hesaplar_grup_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_grup_id_fkey FOREIGN KEY (grup_id) REFERENCES public.ch_gruplar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 N   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_grup_id_fkey;
       public       	   ths_admin    false    235    234    3947            �           2606    141216 *   ch_hesaplar ch_hesaplar_hesap_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_hesap_tipi_id_fkey FOREIGN KEY (hesap_tipi_id) REFERENCES public.set_ch_hesap_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 T   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_hesap_tipi_id_fkey;
       public       	   ths_admin    false    235    4062    298            �           2606    141221 -   ch_hesaplar ch_hesaplar_mukellef_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_mukellef_tipi_id_fkey FOREIGN KEY (mukellef_tipi_id) REFERENCES public.sys_vergi_mukellef_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_mukellef_tipi_id_fkey;
       public       	   ths_admin    false    235    4194    370            �           2606    141226 2   mhs_fis_detaylari mhs_fis_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mhs_fis_detaylari
    ADD CONSTRAINT mhs_fis_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.mhs_fisler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.mhs_fis_detaylari DROP CONSTRAINT mhs_fis_detaylari_header_id_fkey;
       public       	   ths_admin    false    239    3957    241            �           2606    141231 9   mhs_transfer_kodlari mhs_transfer_kodlari_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mhs_transfer_kodlari
    ADD CONSTRAINT mhs_transfer_kodlari_hesap_kodu_fkey FOREIGN KEY (hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 c   ALTER TABLE ONLY public.mhs_transfer_kodlari DROP CONSTRAINT mhs_transfer_kodlari_hesap_kodu_fkey;
       public       	   ths_admin    false    243    3949    235            �           2606    141236 -   prs_ehliyetler prs_ehliyetler_ehliyet_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_ehliyet_id_fkey FOREIGN KEY (ehliyet_id) REFERENCES public.set_prs_ehliyetler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 W   ALTER TABLE ONLY public.prs_ehliyetler DROP CONSTRAINT prs_ehliyetler_ehliyet_id_fkey;
       public       	   ths_admin    false    245    4098    316            �           2606    141241 .   prs_ehliyetler prs_ehliyetler_personel_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_personel_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE CASCADE;
 X   ALTER TABLE ONLY public.prs_ehliyetler DROP CONSTRAINT prs_ehliyetler_personel_id_fkey;
       public       	   ths_admin    false    245    3973    249            �           2606    141246 7   prs_lisan_bilgileri prs_lisan_bilgileri_konusma_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_konusma_id_fkey FOREIGN KEY (konusma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;
 a   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_konusma_id_fkey;
       public       	   ths_admin    false    246    4110    322            �           2606    141251 5   prs_lisan_bilgileri prs_lisan_bilgileri_lisan_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_lisan_id_fkey FOREIGN KEY (lisan_id) REFERENCES public.set_prs_lisanlar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_lisan_id_fkey;
       public       	   ths_admin    false    246    320    4106            �           2606    141256 5   prs_lisan_bilgileri prs_lisan_bilgileri_okuma_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_okuma_id_fkey FOREIGN KEY (okuma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_okuma_id_fkey;
       public       	   ths_admin    false    4110    246    322            �           2606    141261 8   prs_lisan_bilgileri prs_lisan_bilgileri_personel_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_personel_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_personel_id_fkey;
       public       	   ths_admin    false    249    246    3973            �           2606    141266 5   prs_lisan_bilgileri prs_lisan_bilgileri_yazma_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_yazma_id_fkey FOREIGN KEY (yazma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_yazma_id_fkey;
       public       	   ths_admin    false    246    4110    322            �           2606    141271 -   prs_personeller prs_personeller_adres_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_adres_id_fkey FOREIGN KEY (adres_id) REFERENCES public.sys_adresler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 W   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_adres_id_fkey;
       public       	   ths_admin    false    345    4144    249            �           2606    141276 -   prs_personeller prs_personeller_birim_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_birim_id_fkey FOREIGN KEY (birim_id) REFERENCES public.set_prs_birimler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 W   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_birim_id_fkey;
       public       	   ths_admin    false    249    312    4090            �           2606    141281 -   prs_personeller prs_personeller_gorev_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_gorev_id_fkey FOREIGN KEY (gorev_id) REFERENCES public.set_prs_gorevler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 W   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_gorev_id_fkey;
       public       	   ths_admin    false    4102    318    249            �           2606    141286 5   prs_personeller prs_personeller_personel_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_personel_tipi_id_fkey FOREIGN KEY (personel_tipi_id) REFERENCES public.set_prs_personel_tipleri(id) ON UPDATE CASCADE ON DELETE SET NULL;
 _   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_personel_tipi_id_fkey;
       public       	   ths_admin    false    4114    249    324            �           2606    141291 5   prs_personeller prs_personeller_tasima_servis_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_tasima_servis_id_fkey FOREIGN KEY (tasima_servis_id) REFERENCES public.set_prs_tasima_servisleri(id) ON UPDATE CASCADE ON DELETE SET NULL;
 _   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_tasima_servis_id_fkey;
       public       	   ths_admin    false    326    249    4118            �           2606    141296 8   sat_fatura_detaylari sat_fatura_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_fatura_detaylari
    ADD CONSTRAINT sat_fatura_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_faturalar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.sat_fatura_detaylari DROP CONSTRAINT sat_fatura_detaylari_header_id_fkey;
       public       	   ths_admin    false    273    271    4017            �           2606    141301 <   sat_irsaliye_detaylari sat_irsaliye_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_irsaliye_detaylari
    ADD CONSTRAINT sat_irsaliye_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_irsaliyeler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.sat_irsaliye_detaylari DROP CONSTRAINT sat_irsaliye_detaylari_header_id_fkey;
       public       	   ths_admin    false    277    4021    275            �           2606    141306 :   sat_siparis_detaylari sat_siparis_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_siparisler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 d   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_header_id_fkey;
       public       	   ths_admin    false    281    279    4027            �           2606    141311 <   sat_siparis_detaylari sat_siparis_detaylari_olcu_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_olcu_birimi_fkey FOREIGN KEY (olcu_birimi) REFERENCES public.sys_olcu_birimleri(birim) ON UPDATE CASCADE ON DELETE RESTRICT;
 f   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_olcu_birimi_fkey;
       public       	   ths_admin    false    372    279    4196            �           2606    141316 E   sat_siparis_detaylari sat_siparis_detaylari_referans_ana_urun_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.sat_siparis_detaylari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 o   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_referans_ana_urun_id_fkey;
       public       	   ths_admin    false    4024    279    279            �           2606    141321 :   sat_siparis_detaylari sat_siparis_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 d   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    285    4039    279            �           2606    141326 0   sat_siparisler sat_siparisler_islem_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_islem_tipi_id_fkey FOREIGN KEY (islem_tipi_id) REFERENCES public.set_einv_fatura_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_islem_tipi_id_fkey;
       public       	   ths_admin    false    302    4070    281            �           2606    141331 /   sat_siparisler sat_siparisler_musteri_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_musteri_kodu_fkey FOREIGN KEY (musteri_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_musteri_kodu_fkey;
       public       	   ths_admin    false    235    3949    281            �           2606    141336 8   sat_siparisler sat_siparisler_musteri_temsilcisi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_musteri_temsilcisi_id_fkey FOREIGN KEY (musteri_temsilcisi_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 b   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_musteri_temsilcisi_id_fkey;
       public       	   ths_admin    false    3973    281    249            �           2606    141341 4   sat_siparisler sat_siparisler_nakliye_ucreti_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_nakliye_ucreti_id_fkey FOREIGN KEY (tasima_ucreti_id) REFERENCES public.set_einv_tasima_ucretleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 ^   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_nakliye_ucreti_id_fkey;
       public       	   ths_admin    false    281    308    4080            �           2606    141346 1   sat_siparisler sat_siparisler_odeme_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_odeme_sekli_id_fkey FOREIGN KEY (odeme_sekli_id) REFERENCES public.set_einv_odeme_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_odeme_sekli_id_fkey;
       public       	   ths_admin    false    304    4072    281            �           2606    141351 0   sat_siparisler sat_siparisler_paket_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_paket_tipi_id_fkey FOREIGN KEY (paket_tipi_id) REFERENCES public.set_einv_paket_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_paket_tipi_id_fkey;
       public       	   ths_admin    false    4078    281    306            �           2606    141356 .   sat_siparisler sat_siparisler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_para_birimi_fkey;
       public       	   ths_admin    false    378    281    4206            �           2606    141361 +   sat_siparisler sat_siparisler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 U   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_sehir_id_fkey;
       public       	   ths_admin    false    4041    281    286            �           2606    141366 3   sat_siparisler sat_siparisler_siparis_durum_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_siparis_durum_id_fkey FOREIGN KEY (siparis_durum_id) REFERENCES public.set_sls_order_status(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 ]   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_siparis_durum_id_fkey;
       public       	   ths_admin    false    281    283    4029            �           2606    141371 2   sat_siparisler sat_siparisler_teslim_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_teslim_sekli_id_fkey FOREIGN KEY (teslim_sekli_id) REFERENCES public.set_einv_teslim_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 \   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_teslim_sekli_id_fkey;
       public       	   ths_admin    false    281    310    4084            �           2606    141376 *   sat_siparisler sat_siparisler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 T   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_ulke_id_fkey;
       public       	   ths_admin    false    381    281    4210            �           2606    141381 8   sat_teklif_detaylari sat_teklif_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_teklifler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_header_id_fkey;
       public       	   ths_admin    false    4050    290    288            �           2606    141386 :   sat_teklif_detaylari sat_teklif_detaylari_olcu_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_olcu_birimi_fkey FOREIGN KEY (olcu_birimi) REFERENCES public.sys_olcu_birimleri(birim) ON UPDATE CASCADE ON DELETE RESTRICT;
 d   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_olcu_birimi_fkey;
       public       	   ths_admin    false    288    372    4196            �           2606    141391 C   sat_teklif_detaylari sat_teklif_detaylari_referans_ana_urun_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.sat_teklif_detaylari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 m   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_referans_ana_urun_id_fkey;
       public       	   ths_admin    false    288    4046    288            �           2606    141396 8   sat_teklif_detaylari sat_teklif_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 b   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    4039    288    285            �           2606    141401 .   sat_teklifler sat_teklifler_islem_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_islem_tipi_id_fkey FOREIGN KEY (islem_tipi_id) REFERENCES public.set_einv_fatura_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_islem_tipi_id_fkey;
       public       	   ths_admin    false    302    290    4070            �           2606    141406 -   sat_teklifler sat_teklifler_musteri_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_musteri_kodu_fkey FOREIGN KEY (musteri_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_musteri_kodu_fkey;
       public       	   ths_admin    false    290    235    3949            �           2606    141411 6   sat_teklifler sat_teklifler_musteri_temsilcisi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_musteri_temsilcisi_id_fkey FOREIGN KEY (musteri_temsilcisi_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 `   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_musteri_temsilcisi_id_fkey;
       public       	   ths_admin    false    249    3973    290            �           2606    141416 2   sat_teklifler sat_teklifler_nakliye_ucreti_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_nakliye_ucreti_id_fkey FOREIGN KEY (tasima_ucreti_id) REFERENCES public.set_einv_tasima_ucretleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 \   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_nakliye_ucreti_id_fkey;
       public       	   ths_admin    false    290    4080    308            �           2606    141421 /   sat_teklifler sat_teklifler_odeme_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_odeme_sekli_id_fkey FOREIGN KEY (odeme_sekli_id) REFERENCES public.set_einv_odeme_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_odeme_sekli_id_fkey;
       public       	   ths_admin    false    290    304    4072            �           2606    141426 .   sat_teklifler sat_teklifler_paket_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_paket_tipi_id_fkey FOREIGN KEY (paket_tipi_id) REFERENCES public.set_einv_paket_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_paket_tipi_id_fkey;
       public       	   ths_admin    false    290    306    4078            �           2606    141431 ,   sat_teklifler sat_teklifler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 V   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_para_birimi_fkey;
       public       	   ths_admin    false    378    290    4206            �           2606    141436 )   sat_teklifler sat_teklifler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_sehir_id_fkey;
       public       	   ths_admin    false    4041    290    286            �           2606    141441 0   sat_teklifler sat_teklifler_teslim_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_teslim_sekli_id_fkey FOREIGN KEY (teslim_sekli_id) REFERENCES public.set_einv_teslim_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_teslim_sekli_id_fkey;
       public       	   ths_admin    false    310    4084    290            �           2606    141446 (   sat_teklifler sat_teklifler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 R   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_ulke_id_fkey;
       public       	   ths_admin    false    4210    381    290            �           2606    141451 <   set_ch_firma_tipleri set_ch_firma_tipleri_firma_turu_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_firma_turu_id_fkey FOREIGN KEY (firma_turu_id) REFERENCES public.set_ch_firma_turleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 f   ALTER TABLE ONLY public.set_ch_firma_tipleri DROP CONSTRAINT set_ch_firma_tipleri_firma_turu_id_fkey;
       public       	   ths_admin    false    292    4058    294            �           2606    141456 @   set_ch_vergi_oranlari set_ch_vergi_oranlari_alis_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_alis_hesap_kodu_fkey FOREIGN KEY (alis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 j   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_alis_hesap_kodu_fkey;
       public       	   ths_admin    false    3949    235    300            �           2606    141461 E   set_ch_vergi_oranlari set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey FOREIGN KEY (alis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 o   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    235    300    3949            �           2606    141466 A   set_ch_vergi_oranlari set_ch_vergi_oranlari_satis_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_satis_hesap_kodu_fkey FOREIGN KEY (satis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 k   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_satis_hesap_kodu_fkey;
       public       	   ths_admin    false    3949    235    300            �           2606    141471 F   set_ch_vergi_oranlari set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey FOREIGN KEY (satis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 p   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    300    3949    235            �           2606    141476 /   set_prs_birimler set_prs_birimler_bolum_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_bolum_id_fkey FOREIGN KEY (bolum_id) REFERENCES public.set_prs_bolumler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.set_prs_birimler DROP CONSTRAINT set_prs_birimler_bolum_id_fkey;
       public       	   ths_admin    false    312    4094    314            �           2606    141481 9   stk_gruplar stk_gruplar_hammadde_kullanim_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_hammadde_kullanim_hesap_kodu_fkey FOREIGN KEY (hammadde_kullanim_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 c   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_hammadde_kullanim_hesap_kodu_fkey;
       public       	   ths_admin    false    235    3949    284            �           2606    141486 5   stk_gruplar stk_gruplar_hammadde_stok_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_hammadde_stok_hesap_kodu_fkey FOREIGN KEY (hammadde_stok_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 _   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_hammadde_stok_hesap_kodu_fkey;
       public       	   ths_admin    false    235    284    3949            �           2606    141491 2   stk_gruplar stk_gruplar_yari_mamul_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_yari_mamul_hesap_kodu_fkey FOREIGN KEY (yari_mamul_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 \   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_yari_mamul_hesap_kodu_fkey;
       public       	   ths_admin    false    235    3949    284            �           2606    141496 0   stk_hareketler stk_hareketler_alan_ambar_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_alan_ambar_id_fkey FOREIGN KEY (alan_ambar_id) REFERENCES public.stk_ambarlar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_alan_ambar_id_fkey;
       public       	   ths_admin    false    4126    334    331            �           2606    141501 .   stk_hareketler stk_hareketler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_para_birimi_fkey;
       public       	   ths_admin    false    4206    378    334            �           2606    141506 ,   stk_hareketler stk_hareketler_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 V   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_stok_kodu_fkey;
       public       	   ths_admin    false    334    4039    285            �           2606    141511 1   stk_hareketler stk_hareketler_veren_ambar_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_veren_ambar_id_fkey FOREIGN KEY (veren_ambar_id) REFERENCES public.stk_ambarlar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_veren_ambar_id_fkey;
       public       	   ths_admin    false    334    4126    331            �           2606    141516 <   stk_kart_cins_bilgileri stk_kart_cins_bilgileri_cins_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kart_cins_bilgileri
    ADD CONSTRAINT stk_kart_cins_bilgileri_cins_id_fkey FOREIGN KEY (cins_id) REFERENCES public.stk_cins_ozellikleri(id) ON UPDATE CASCADE ON DELETE SET NULL;
 f   ALTER TABLE ONLY public.stk_kart_cins_bilgileri DROP CONSTRAINT stk_kart_cins_bilgileri_cins_id_fkey;
       public       	   ths_admin    false    332    336    4130            �           2606    141521 @   stk_kart_cins_bilgileri stk_kart_cins_bilgileri_stk_kart_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kart_cins_bilgileri
    ADD CONSTRAINT stk_kart_cins_bilgileri_stk_kart_id_fkey FOREIGN KEY (stk_kart_id) REFERENCES public.stk_kartlar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 j   ALTER TABLE ONLY public.stk_kart_cins_bilgileri DROP CONSTRAINT stk_kart_cins_bilgileri_stk_kart_id_fkey;
       public       	   ths_admin    false    4037    336    285            �           2606    141526 4   stk_kart_ozetleri stk_kart_ozetleri_stk_kart_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kart_ozetleri
    ADD CONSTRAINT stk_kart_ozetleri_stk_kart_id_fkey FOREIGN KEY (stk_kart_id) REFERENCES public.stk_kartlar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.stk_kart_ozetleri DROP CONSTRAINT stk_kart_ozetleri_stk_kart_id_fkey;
       public       	   ths_admin    false    285    4037    338            �           2606    141531 &   stk_kartlar stk_kartlar_alis_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_alis_para_fkey FOREIGN KEY (alis_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 P   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_alis_para_fkey;
       public       	   ths_admin    false    378    4206    285            �           2606    141536 '   stk_kartlar stk_kartlar_ihrac_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_ihrac_para_fkey FOREIGN KEY (ihrac_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_ihrac_para_fkey;
       public       	   ths_admin    false    4206    378    285            �           2606    141541 &   stk_kartlar stk_kartlar_mensei_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_mensei_id_fkey FOREIGN KEY (mensei_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 P   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_mensei_id_fkey;
       public       	   ths_admin    false    4210    381    285            �           2606    141546 +   stk_kartlar stk_kartlar_olcu_birimi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_olcu_birimi_id_fkey FOREIGN KEY (olcu_birimi_id) REFERENCES public.sys_olcu_birimleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 U   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_olcu_birimi_id_fkey;
       public       	   ths_admin    false    372    285    4198            �           2606    141551 '   stk_kartlar stk_kartlar_satis_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_satis_para_fkey FOREIGN KEY (satis_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_satis_para_fkey;
       public       	   ths_admin    false    4206    378    285            �           2606    141556 *   stk_kartlar stk_kartlar_stok_grubu_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_stok_grubu_id_fkey FOREIGN KEY (stok_grubu_id) REFERENCES public.stk_gruplar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 T   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_stok_grubu_id_fkey;
       public       	   ths_admin    false    284    285    4035            �           2606    141561 *   stk_resimler stk_resimler_stk_kart_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_resimler
    ADD CONSTRAINT stk_resimler_stk_kart_id_fkey FOREIGN KEY (stk_kart_id) REFERENCES public.stk_kartlar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stk_resimler DROP CONSTRAINT stk_resimler_stk_kart_id_fkey;
       public       	   ths_admin    false    285    341    4037            �           2606    141566 '   sys_adresler sys_adresler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_adresler
    ADD CONSTRAINT sys_adresler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.sys_adresler DROP CONSTRAINT sys_adresler_sehir_id_fkey;
       public       	   ths_admin    false    286    345    4041            �           2606    141571 2   sys_ersim_haklari sys_ersim_haklari_kaynak_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kaynak_id_fkey FOREIGN KEY (kaynak_id) REFERENCES public.sys_kaynaklar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_kaynak_id_fkey;
       public       	   ths_admin    false    4178    362    352            �           2606    141576 5   sys_ersim_haklari sys_ersim_haklari_kullanici_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kullanici_id_fkey FOREIGN KEY (kullanici_id) REFERENCES public.sys_kullanicilar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_kullanici_id_fkey;
       public       	   ths_admin    false    4180    352    364            �           2606    141581 /   sys_kaynaklar sys_kaynaklar_kaynak_grup_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_kaynak_grup_id_fkey FOREIGN KEY (kaynak_grup_id) REFERENCES public.sys_kaynak_gruplari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.sys_kaynaklar DROP CONSTRAINT sys_kaynaklar_kaynak_grup_id_fkey;
       public       	   ths_admin    false    360    362    4174            �           2606    141586 :   sys_lisan_gui_icerikler sys_lisan_gui_icerikler_lisan_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_lisan_gui_icerikler
    ADD CONSTRAINT sys_lisan_gui_icerikler_lisan_fkey FOREIGN KEY (lisan) REFERENCES public.sys_lisanlar(lisan) ON UPDATE CASCADE ON DELETE RESTRICT;
 d   ALTER TABLE ONLY public.sys_lisan_gui_icerikler DROP CONSTRAINT sys_lisan_gui_icerikler_lisan_fkey;
       public       	   ths_admin    false    4188    366    368            �           2606    141591 8   sys_olcu_birimleri sys_olcu_birimleri_birim_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_birim_tipi_id_fkey FOREIGN KEY (birim_tipi_id) REFERENCES public.sys_olcu_birimi_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 b   ALTER TABLE ONLY public.sys_olcu_birimleri DROP CONSTRAINT sys_olcu_birimleri_birim_tipi_id_fkey;
       public       	   ths_admin    false    374    4202    372            �           2606    141596 '   sys_sehirler sys_sehirler_bolge_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_bolge_id_fkey FOREIGN KEY (bolge_id) REFERENCES public.sys_bolgeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_bolge_id_fkey;
       public       	   ths_admin    false    349    4152    286            �           2606    141601 &   sys_sehirler sys_sehirler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 P   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_ulke_id_fkey;
       public       	   ths_admin    false    381    286    4210            �           2606    141606 )   sys_kullanicilar sys_users_person_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_person_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.sys_kullanicilar DROP CONSTRAINT sys_users_person_id_fkey;
       public       	   ths_admin    false    249    364    3973            �           2606    141611 9   sys_uygulama_ayarlari sys_uygulama_ayarlari_adres_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_adres_id_fkey FOREIGN KEY (adres_id) REFERENCES public.sys_adresler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 c   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_adres_id_fkey;
       public       	   ths_admin    false    345    4144    383            �           2606    141616 6   sys_uygulama_ayarlari sys_uygulama_ayarlari_lisan_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_lisan_fkey FOREIGN KEY (lisan) REFERENCES public.sys_lisanlar(lisan) ON UPDATE CASCADE ON DELETE SET NULL;
 `   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_lisan_fkey;
       public       	   ths_admin    false    368    4188    383            �           2606    141621 5   sys_uygulama_ayarlari sys_uygulama_ayarlari_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_para_fkey FOREIGN KEY (para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE SET NULL;
 _   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_para_fkey;
       public       	   ths_admin    false    378    383    4206            �           2606    141626 +   urt_iscilikler urt_iscilikler_birim_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_birim_id_fkey FOREIGN KEY (birim_id) REFERENCES public.sys_olcu_birimleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 U   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_birim_id_fkey;
       public       	   ths_admin    false    251    372    4198            �           2606    141631 -   urt_iscilikler urt_iscilikler_gider_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_gider_kodu_fkey FOREIGN KEY (gider_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_gider_kodu_fkey;
       public       	   ths_admin    false    251    235    3949            �           2606    141636 H   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_paket_hammaddeler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 r   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_header_id_fkey;
       public       	   ths_admin    false    253    255    3985            �           2606    141641 H   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_recete_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_recete_id_fkey FOREIGN KEY (recete_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 r   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_recete_id_fkey;
       public       	   ths_admin    false    3999    253    263            �           2606    141646 H   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 r   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    253    285    4039            �           2606    141651 F   urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_paket_iscilikler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 p   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_paket_iscilik_detaylari_header_id_fkey;
       public       	   ths_admin    false    259    3993    257            �           2606    141656 I   urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_iscilik_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_iscilik_kodu_fkey FOREIGN KEY (iscilik_kodu) REFERENCES public.urt_iscilikler(gider_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 s   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_paket_iscilik_detaylari_iscilik_kodu_fkey;
       public       	   ths_admin    false    251    3975    257            �           2606    141661 <   urt_recete_hammaddeler urt_recete_hammaddeler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_header_id_fkey;
       public       	   ths_admin    false    261    3999    263            �           2606    141666 <   urt_recete_hammaddeler urt_recete_hammaddeler_recete_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_recete_id_fkey FOREIGN KEY (recete_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_recete_id_fkey;
       public       	   ths_admin    false    261    3999    263            �           2606    141671 <   urt_recete_hammaddeler urt_recete_hammaddeler_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_stok_kodu_fkey;
       public       	   ths_admin    false    4039    285    261            �           2606    141676 :   urt_recete_iscilikler urt_recete_iscilikler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 d   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_header_id_fkey;
       public       	   ths_admin    false    265    263    3999            �           2606    141681 8   urt_recete_iscilikler urt_recete_iscilikler_iscilik_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_iscilik_fkey FOREIGN KEY (iscilik_kodu) REFERENCES public.urt_iscilikler(gider_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 b   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_iscilik_fkey;
       public       	   ths_admin    false    3975    265    251            �           2606    141686 H   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 r   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_header_id_fkey;
       public       	   ths_admin    false    267    263    3999            �           2606    141691 G   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_paket_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_paket_id_fkey FOREIGN KEY (paket_id) REFERENCES public.urt_paket_hammaddeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 q   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_paket_id_fkey;
       public       	   ths_admin    false    3985    267    255            �           2606    141696 F   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 p   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_header_id_fkey;
       public       	   ths_admin    false    263    269    3999            �           2606    141701 E   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_paket_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_paket_id_fkey FOREIGN KEY (paket_id) REFERENCES public.urt_paket_iscilikler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 o   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_paket_id_fkey;
       public       	   ths_admin    false    259    269    3993            �           2606    141706 <   urt_recete_yan_urunler urt_recete_yan_urunler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_header_id_fkey;
       public       	   ths_admin    false    3999    263    388            �           2606    141711 <   urt_recete_yan_urunler urt_recete_yan_urunler_urun_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_urun_kodu_fkey FOREIGN KEY (urun_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_urun_kodu_fkey;
       public       	   ths_admin    false    285    4039    388            �           2606    141716 *   urt_receteler urt_receteler_urun_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_urun_kodu_fkey FOREIGN KEY (urun_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.urt_receteler DROP CONSTRAINT urt_receteler_urun_kodu_fkey;
       public       	   ths_admin    false    4039    263    285            �      x������ � �      �      x������ � �      �   (  x����j�0���>^4}�>��L!NRH���Q-��n��Fo�א�H�k�i��v���,r�<�^�ڲǟ������_��"<�%;�<��<�?~�����y`;&�ı�c�F`2ԙ"N@ ��Y�^�-���^�����g����q9?G����2_�O��S��9@�菘A5������qpN;����r�Iس��E���(�
KonW��`)J���M��δi��)���6T�H �̆ĵ!+�P��r�~�5�F�a.�ȵ3��IY��6_��HS����0���+�6T��B/���g�0�Ua��4
Z�$�I9�e%Җ<�)!'����be��|�r@���dI��JZ�ea�]ٿ�H���VZ�A��5��y-��aH��"Տ�J�,�EX�V��`�#j#M�Bj��{�7Uy���R(.���x�e��j��o%j��L�E��{Q���"�(#�Aha�U,�SR���n�7���:�;��(5'#D�$]'꒸�ۋK�\�uo�]�r	N� ��ZV_�G_�7�^�B�'I���'      �   D   x�3�4�461��v��srv�0�2�Yrz��x��id�e
242�p�s9����Ԍ+F��� ���      �   0   x�3�:�!��1�3*($�ɑː��1��/��N� �� G�=... �^      �   ^   x�3�tuw�2��vrtq�;�!�˄���4�t�?2/T������'�˂�Ȇ��p�9���9~����9}��ȑ�Є324(����<O�=... F) �      �   �  x�]�Mn1F��],H���-Rt�Ȯ�?G�'"�3��'�J@������SZ(��O -������#�g�4��������;o!����BȐ�*�B<�ބ��"�����<�U��J3�*B��:#��W4��Y�B9s��d���[�!3����6��c	�x@[��\�z%#����Mhe����p�4V�y����~�u��*��  �U(�|��3���q����*����3��g�^��P�F��(���-���-!Ä-�Q�6Q�-4�ȅ<|���c	e`�k� �=�K��������N�^�](�fT����%T���`�iө�a�P�+���� XB��!Ă�n��he�~���~\��:!�B�B�ȅ@B!<i�����B+ȅ(!=�%ĹG�מ��D��      �   ]   x�3��quq:���p��>�A\f��G6x9:;�p� �G灥�J@�憜N�~ގ>�@��o��c���+��9���9G煸Ả���� �( �      �     x����n�J���Sp9d�]\*�kdف�p0�N�sBH�J ��y����M��fV�I~���yIQ���&�_�꿪��n�6,�7.�4�D�y}����7�ed^D�8Q�J��,0��}���G��fw�>�q6�2�1�/>�&q��>ޯ~MV�V��������X�|���)�(������J��14��9�_2x����g����MM��X���E���|R_�e�)i�F�Q�Ds���(��o��m�e���R��g�X'܁iełn� Z&cs���#���E�H��ٳ�+�B�PMo'�&�}��F�	�z��ǁr�`�+9����1�y����ˇ�d����V_mx��2�F�g��xov��d6/���q�-��y��~%��g�x��\��,�T��b	�Ah\�G�I�u����΁�&�D���]h`7��o��(����c	(&��'5ߎK�5<0�/i$�3��"Oa5��Dr�Ke�|vC��1���ӹ�~�B���� 䄁1RY�ޙ�h�S��f<SI	�������&x|��|gB°�n ZC鸆M8�<��P6��3�h���7F����dC�@ݩ�I�j��=GԞd�&�}?QSe���Ա�ir�����ܓ��{`ؐ�Ք�z�Z�.N�d���:@��'�W�\b�yr���K�K��X�0JƷi�k1կA�����T���u�����>�Xh:U�ԧOˇ�:K(�6�U�%��Z����(�6\�EUF	$ܶ��]N`�m3���%)ܲ(H�4oS�(���;Q���D����Xv]7e�f3�҇tF��Q����l���~%y��?ؐ����XZS4�g/qg'�L�:���rA�3)��_�6�	�=d�ȟ�_������ ��W���Tw��M:�gS]`�����®�g]��se�M��J�B�N�T�Y�y�>���;.��K���;�mMAܦ��[�`�˯�:Y�iT6,!��i�<�'��`*�OI��M4�����;Z̺����A��3�`m-T0��;�
��o� �D\�iܭ�mxr��X��m�b`2(]��t�^���7����t�.�U�8���# 슈(�JCF !�2�ӡ՜�Z�-��M	с��i�c�i/m���:�FO7��_0!N�m!C	�[wD�x�Ғ�5L�iD$D�z�i�%8B-��eJ�>]Dv�	jeg�!Μ�L�X�DZ�g
t;���(�!L������M����lll���#�uq�"��	������	��ݭ0p-���J�gɜ5��YwBQ8��.�R�>}�'%\��enմ���J�eA�M�B��W���*6KG'��A����]��?�#�"��A��T������E��bcd�PE$$���D�|�D���_�O���#D/�tG]�@�3���)y����� Z�W��A�0E�c~�;��J�y�c_��=�7���h�:쯾�9��=�O��X8���Q��N{�TN����t�;�;1����h��b͡�l�oH�o����������	�e�+������j��,��a�_	�űө�aU$�j8��Ol�/�(=���ᗓ��e����TSz
˰����|tv�A-N��Q�p���H�>H��	��d]��e&��ef��t�|�U�o.��]�b8h*��{�)e/��bKq�u�`�1���g��<�g��<��g��D�g�����g������ѹ�,3�K��L	����r]�hט��lA�|�|����7��d����Ii�����!���Y����b�,3��?�ߟo�+t��a�����Ȯ�r%��h'�4@U���9X�'�G��k�耺}E��bO.�nm�Dxߦ�����
�}t�ȴ�k&�Pw���b]5i(!G���d��۠�Z���e.�[�E�s�\��4E����4��ű�A�G3����+5���Ӕ��w�1��qt'�=~���y-mJf���K�\���q� �Y_��;��������ER^�r6w[����}���h��%0�ح	�L�e�1� ��E�<A�����֓�cw�س(�.mq$)Z^Z�Z�]R:�=4 u��KR�ܝ��S��U�P��]�Ƣι{)������xw��9�e���v�_B�S0k/$��+>!٭W|��gM�λO*4�mw둻Rj(���RC	v�(�l2Fy�,��k�p�չa~��\����B�ڊI� �^X��(,��~��$o��H{����|�c[ǳYTɑb��M�i��� �U�^��\��h��|ڸ0��$�ַ�6
�\�ͥ���C�����YeY���(�[�����7�WȒq�Ǝmx$rޕ�=�0`���+Ǻ�Ӂ�8�{�,fU�����p՘��a~���?�$a3S^����@v����L+WQV^�R���Q�!d��^hUǴyiK��e�n��5|+��L������`��jjZi>����(��/
�Ԧ�c���y:�5��1r��������@��%�\,F�s*ـZ���u}ZX�XX�[u'�_p$�MI�����0#� ��w%��-(��l|P��EsI�����W�槥-F����J���5��Ƴ�M�$H�;rvK��/���Z	�J��[�&�|��C��i��V���MwI=���K��(����0���L����o�l*�X��H���4bcA�'�)�5oB �ۺ��޶-(��l�ú��B�0��YjcJv��mҡ�&t�M�@,d��VQ�MWؙ>����v��L =.��柨��ɢH�����V2�-�6Ѣ�.�RA���B��Y]�"��tj;�v�;��Wn1�y� Z�q��J���T�l%o�����Wmo}���~ؾ=�(�(�E��~R��$�.j*YŻ�6�b��K�U�Pe�4���oe.˟�T�UCCk�a��݆G�B��3���`����9ݰb�]Y����G,W+�d�>��]��e�U�n�[~��F���ޤ���-Ҩ�%��A����z�B�X�[�%�eoݴy�|�/4=!Ď��F��M'-�`�p��@}V���"®�u-V
�B�h�t�m��Us��~��x`�W+�������p�Y{��xH���w�ɢ�������!�'h�-�����������j<!k+d�cdGЮ��U�/��e�IS��}���c����NXm�&>k?Kl+�I����t�(
�eE`iY�hz�n�6N:��
�}GY��_Gjq��.�'���|"�h}H���'F�t�}i��^�%�*/N�g��7h}���5� ɇ�^�%�B@��BYx�5�@�	���k��ǡ�{Q~�א/�˯�{'�7�͋��e�$��'_�^������)�W�v����y��g��녅Η����]6g?��e묖!ߏ�����ɰ;�?~7�V?O���.N�~��a�<�~�7��Nx�ߚK����Fݷ���dn<�૳��̮�d��Cr��Ὼ'�ѱx�T>���6��%��>$�q�:C�Z����?_�x�?���      �      x��][n�J�fV�� 3`?�M~�-&�P��2 c��
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
Z�SҒC�Xt;��K��G�Gt������~b�S��Q�3#}��Zw�k�Q����^��G���u�=��W4�����Ř�G1J3�)�����yɴ�)�Yj�t|#�(�>�p���t�:����3%`:�b$]qQ��ϟх�R���K4�Ţ�䝠�%hzo��GV(�Z�r#��^���*��M�Zzd ��7\�����$��t�y�`,�h4=1������]����]GП�{5��"����>}�-��      �      x������ � �      �      x������ � �      �      x������ � �      �      x�3�4�44�2�4Q1z\\\ 'k      �      x�3�4B#NNC�=... �;      �   ;  x�u��n�@@��W̽��,��L��*�mb�-�T�	�&����z���:�'7��y����8�{5�	���]8���e&�D�9Z
qA�8�p�u:�ӄ��`0ҥ����$!)YP"�6�`��M�d����!�q�h�7�,.p�Y��X�9�~_�{�1}�%�dm��3��D͢x��vb��}��.��jpYw���C�C�_ujsZ���p�ks��w�N��T�	�������V	���9�:�nm���!�~i����ᭋ�[�\Ѩ��E���,)ҼqU��t�)L��d_�$�W�a����(      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �   �   x�]�Mn� F���`43��XIS+ƍ�y�u��C�`�?ip� =>F��H=ƽ�nȄI��稧�gM�u���ｉU<����+g��Ua��WD@��Q!d!`eůmxcj��pM�7U���s�y���x��p�"�P�Uf=`���!dV|Z؃��8�^���9~�^�]ΗN˥�ө��у���
;��TeD"��j��V|:=�i�_ ~V�      �   �   x�mPK�@]�Sp&m��rG! 1.0�=�g�x/!~_?y��i	�ݦ7 D�`��~�d����}��8��D����$��ڂ�F]A
��@�Š�?��<�)t�yjRC)�6�!p����е!�G_A��~����/��q�w(�u��aC3O�<�Ch�O�d�3R���U�oX�Y��Ȳ�	K�AB      �   D   x�3�4�tt9��������q�9������u�ʅp�pq���d��p�y�~�~@�=... ���      �       x�3�<:���3�ˈ3�5��1ҕ+F��� Tk�      �      x�3����2�tr�2�t�s����� 4�      �   O   x�e�A�0��ت����0���ӄ�p�P/o���s�۷s{���y�;e�dV�;����<����},�w!� �b"c      �   I   x��I
�0���c�xo4�&Q!���C�Z�5�׈�<^Y���s��'��^�0�R�yˋ�v >*��      �   ;  x���1n�0���k�{N��.�0P�JR&���|��{50�}~z��2D�����?��v8����~��w)�w�����Mq�b��`R�S|s����/������|W\
����ݱ��]�����mZ]��КRm��,�V�n�Rm���Z�#n�����6��G�'�����`�)�����b�2�����0V�/I/�p)�*��#����.�8�4=:�X��ք��9�+fiyZV���2����ieX1K��ʸb���V����b��5q���2�XZ�V�[iyZVl��ieX�����qŧ���� 63��      �   7   x�3���p�v2��@<o�#@<c0���5X!�����$hDpc���� K�$      �   +   x�3��s��9�!�U����ٓ�!�~x���k��W� #6�      �   �  x�}��n�0�竧�� A+�i��F�Z���)�c��������cWk�f��z�Đ;��<��^��8~V(��2Ef�|c����8yQ&�+.ƓJ������q�J�g<�KYT��'t�a##���������p����Φ�Ŕl̛ }��		�HH��98A���G�r]�K}�t-u�Fb^�"C��S1�-1s.K��q\�#�.>��K.�#W	���lč�
]���LH�~����\7���5S��)���X�\�C���*�M�q����"���6�@��s/��I���� �����:��g���V�����ǧm��Ul�t���0��ɠ4��g#����r���,�U��Ff�O߈���BUiY���o+[��7Zpq+�\�S�!G��r�C�Wj��~���j�þ ��4��J�͙2�/1aלP/o��ӥ$���z9�'˾�[��>�<\Z��4ܹ���x��u��eY� y&UP          U   x�31�<���1���#���q�44�21�t������44�21�t��s��L9�\C�����<3�G��#|C8�L�b���� Ax�         M   x�34�<���1���#���q�24�t:���.��ed��������ed���yt�B�c�c����#W� =SI            x�3�t�2�t�2�t2�2�t����� $ �         0   x�3��=<�����Ȇ`.#NWW_G?.c��(m�yt��W� �|      
   *   x�3��
q�2�<�!��.�����
�!�cW� �         1   x�3�<������#��]��9}|���L8݂��=���=... 7'         *   x�3�<<��5��_.#N ����e��txN�?W� ��
�            x������ � �         3   x�3�tr��9�!�?�3Əˈ���1������5�<�! ��Ď���� >$a      �   F   x�3�tr��9�!�?�r�t�S>�!�1�Ȇ��|\���8=�<� $��1���!!G6�h�1z\\\ �$_         %   x�3�tst
:��ۑ3�9]\�9K��=... �x         �   x���M
�0��/���:%�Ep�M�Ž����g���X���I`���|������Y�J�.q���
��$�*�S���/,�:YԠ���;��I�������M�l���|9�н�i4h@,�a-�	��L��i��z�})      �   4   x�3�qQp
��445�500D��9}]#�\}\�8q+����� �ob            x������ � �            x������ � �            x������ � �      �     x���_n�0Ɵ�)|�?%�5��F$5��sO����al���ViՂ��I���8np0Wp�FW�1pz�����?��j����Xx���]�����^A��� �B�Y�*K&����ٴ��G��&��UZ_~�bADET���9�����J'6E�<:�����pƖ%<�CVc�6w��K�s��V��O����?0�g��d�y��<Y��{���` �C�u:��\���
8_����ّ}g�s!m��S�>=�%��7ʫ���']� > 㔿            x��|Y��Ȓ���_�l�}y���� a��.B�~��8�U'�����*�9fe��
9�|��{p��E���w0/3����z?^�������_D3å?�r���lY�9�����|=;�z���?�s�|���ӛ����xw�s�TJ���ʧDJh�z����Z{rkHM�u���\/��<O*#&E���`���=�y�q�֌*w}kbα�����U9��<?2��Z����Z��k���PrH5�t�.(�mJ�J�(d�':L�Ԥ�F�6D�̬:B]�G;w���4�ݫ�9I�G��KH��s��re?+���M	�e[ʰ�%�>���e?�+��9��kڇ�V��SX|!�'!6����+�gsDӈ�x��X+�^9��[0�)�E�ͧ����$���~)�*�nSH\�K�n��=�g���XS��*�s�K=r��ҭ)���p�C�"�<�b#J��O���J0I��t�����d]L�٦ͳ�ѷΧ�y�XZ&�������-'VS�Z�����9��$�W��@1��6��W���(��9�R�7���z<1vS�8��J���n:���9�TT$=�D'���K�BL>�����ɞ�
�*�!Igfə��O���&C\�y���*�$ {��Y �y�T~�?Ռ2���V=-��[��19f�G����Lɤ�mM�M.N�f#�$��+��N��Z��K��r�2�/�P�;�vҚ�̷�^�dѳjD&����t��z�-���gM�����#�`���j�`����5��Ƙg�	,P�5�<���o�� ��c0��ť˴���i��1FZ˩��{��v#�Եd�D��,xV݉��,�2U"8[[n�������+]�W��DåG���?��"��� �/k
���NǦF�h��3��%L�9�
@gn�Lmi!]�5�nuX�g�y��}�S��/�6/k�3ja)e`1�7���Gٖ�|��W��:�ޞZWE���K�#Nd������ř�:�vhV�;����s�!L�R {��mM��*L���Ȳɘ.�1�2&��]�}E�7�͈ۂG5٭���,5��Y��!�6c��nL�i �	�'͵>�Ox` ��#{��t�\b�����X��/?�ЌَR�:GN��M- �(.��N�t*����8o۽!>��x!���67�9_h��?s�&�1`(6�,Ԭ����g]�b�1ͩѤS�ޢ�ҩy�� 6���3�Ќ�3|��7ƖuY]��\0���8�w)o�؏8M�3 �,ة�Oa>�e����pv2y�_D�b����.א4�sOW����eQ4�����Z7�3���1��;$�e`5=)��E�A��(-f!��R�,���"< *%�l8�ν��ܸ�^5�N��/�G^�Е�IrfY�h�O��&�x2����!����w��3����@Z,�$V�k,@���PNkB��!���R� ���x���M�"��q���g����q��yh
핓l>���m�of�	y�[�N���!��l&a��{>g��9�������<RJ^8�5B���#�������i|�P��O8��i�T���#|��t���P��|Ʉ��l7�i�E�Q0K�M�%|��gva����ƺmyc�;�y���+䘰�u�)](��%�*	��=]%�Z���/f�_vS�Y��N�Ǒ�:�!9,�� �B�m��z��i�&���T$��%7�%���TT1w����Y��N�����SsP�����sٞ�@Ȇo�[��JCr��5n���j��n6��
m������B񮯣v���ZC��\��l?��Ѷ�� k�B��6���y���u��Cv����B���t2p
^�**�fp"�$_�G�l���l&W�c�o��̩�P���|���G�-� y�9�N��\4�0gN�ڕ�Ȼ�(/�<"��#���>��.s�&�*�<����U���	�<�6mCfh�F�ь���)}.�D���`�*��M'Fuq�[r�����Ƭ'�z�c��Ր������}�#7�����۪�?�C^�6/�\��ʇ�R���#������#�����/���=}�l�k|����c�!_`�9B�ώ� �<���u�2���������/?��C.2��l�H���Y���8�S3��S}L
�=<}�o+<���3q�y/>ط��ɕ�|"w�+�#����pAq����2���A\�-n�ݪ�E[I.6 ���c�D���������������+DEr�ɂ|�FS��8�`24���`�]M�J��]����.v�*�,gx���#u���`<��i6!��{?��B��o��Պh�uuA6��<oy�)	�,��JǺ��==�~���&h������s��S�Ψ�nz��yK�=�7ԁlI�k�Nb�GenaO�����cɮ���Q�F��zCO �fkt�O�t�-�a�NŘ�[�����G�#�	s�A�<���n�Z8U$�=W<Ѩ���T�
V���f�N��3�VU��a>b�~}����tǫz��c�դ��{��ڋ��GᏰא����ݏ�˵?��]o�
�'�	��6Vv�3�^�'���"91���;�a�>�v�J���:-�#�$�-]�N�X`{?^^���c}G��ih/����T����k�=c��������nց@� ȼ��R}H�UY��o��t�y����w��R���7�K��XQ��#�@����-��ã����|A����_(�i�̇�0�ZEg獒//�>s��yȴy�}�<v�Vz�jzPj�jU�8#Sd+æ�A-?1*��V4U�ȓ�Uz3Q��/��)%�������7S~|І�Qk:�*r�+����.z��t �T��R�Y ��
~z�ړ%��x *"/��'9�Ac�Kt-�h��k#��Pd���b�V�#�&O`KqM�Ӻl
{⏼3Ƭ��I��r�I:�������d-� ���#�n)��J�zH��b�
��2����p{�M�������d�>;�N�ɞ+~v����X�1g����1�,@��!{1p�$ĆY�3�g�J��oÐ#w�e������S�2�dU�:l�[�i���"ڬ#r��L������3o����u��P�����qԓZ�a'�n�˄�)�K<q��?!0.ɐ3�]�/�X�@�Q���|"��p���^��p��L�[���[��9h8�7�9rVB_ԓ��`�Y7�Ⱦz��<�^�"��ߧ��D��>�\;i�:��Do%=GTf�R��y���|V�iO"B���1He��I�#N��C�H���I,b?�	ύG$&�گ���W�q�w�ro��� kq6����SN��4c|�f�p)��)�cs���nJ����6\�5MZ�<��v����I{n�$l�����xx^�F� O�Zp$�{pH�P)}��ҎS-^��C��dz��Jㄆe[�:�#�]4�CD2�
(��0xhaM�������(��aJ~g�9�g�����b�z'���V�F���aI�"����{�Y8��Q�J�h��{�����4HJ�Fq[�VݻHD�RZ*9z;�r8�fñ	�!��C�)��`���L�U�׿���R>Ϲ�F%�a���gJ9�5��`�4+��~�Gj���+vF���,�'��ͣ^H�iT�#OB������«(�Ke�!W��s������b�&X�n┘�����p�
�}j�z����EL�ʓ<"x5E�B1빋�ҋ�2����B�ys��� �VߔZ��h���s�nC"��s�$�З��!�d�)��?�D�	?����+�>��	o�$���	�xC����K���eHßy�Wd�\����>�m�P�l�jbI?{i�Lឳ%C0l���5�#_^Y�O�j�#��}f,}�c�'MX�<�K5�¦��/��� U��/�f���7ƹ��/|i]��p�T��<��U�lB%�����hۅ�{�B �,��x�!Qo    �e�����p�����y>_8����#�%�T��x�.�¡��<
}���ꏐB�g�坋;�}|\4�C9���K����K�5~_`���x�,�_����~�3��"� �:�#D���~���_{�����so�5���&���^����h�j�&�{��k�����~���,��������_{��}>�_��E��M���QX����1�ǲ+�،�QW{F�EJ�<j��� �eܟroǿ���P����׬}`�_u�Җ497H�S���y��K" `�;��^���s;5sC�wu��>��㇮�ׁ�Ȩ�3]�Ԫ��L�����S]�v$�|1t�!(�4�Ԍu@�I>bw	������O�jm�$�UAq���ӏy�_��z�W��� i:�C���)��!QN�t3W&p�:�;�)��Tr�ßn_��C��� �%�ok����=����������_����v����}��I����s�24־�O����Y�׏�Oh�c?���P��_[��%ο���%�?��j���8������N_��B��E;�����b�/y���i��o`25j%��GO�c����[4�U�;G���e�x����yH��K�vC:B���=U��`�8$RuXڡs�F$t�0�˽>�4���O�Q�{�]��V4dR�i��;=Co��8Bzuc�m�Uė�~���p�E&�Z+�J���A�J�t	i�[��}�k.N��c/��^��S�t�G!�f�m
���0{���2H�_�r$t�i�v��J�j��s~�����ϟ��D��BB�~wP甠x�9S���P�_���C��-�?��A���JD�&��N1>�\&�~���vÍ��P�ĩ �(���%�jY���'���?��3~O�V43�[����=k�J:����r�a-�Kq?���S$�&^���qյӸ�IkT�ce�����q���6h�y�)uX�����d?2��|U$G,6�y-�6�CL�{���o����W�c-�����%�1���Z�Z#� ��뼿�۫4��z`�: ��s��G��k�!RKbX���c���e����!i�ٸ�2 �Ş���t������� �nT5��x��fR����`5���yǵ�^��m��auM�azS�����)�Cd�Ց �.��X"�/>�|
��,H��k�ڽ!�����dz��}���URɓ���vF?�����x�;M-K��g�2����D�-�+���8ڐ'�9�^'2�U�H���X�Zu�>Ԑ���%L*�C�Y���������9F Ҙ�P1�9}3n6B4�.ݮ��91�<q��	�Fm;�N�*	d�<v%����%G���9*m�3���s�6Vʍ���ϾΕ���կW5�t����N4����v���KL�c��yw�mQ���h��:O��"�f#��}�#)(�f����F��yz��c�r+h�6�P@�zB�C�]9Ar�ŉ.E�ӥ� 6]�E�����!!2Ֆ�u@b<��翃��ޛ ��.�(f`{��q��O{��&�."�Hj��(;u͐#��X�|=��w�r�Ɲ�_����f!C6�����3J�`N�"䈻��5~��X��A$�1�%,#a�O�ڵ_���=E�Щ���O��O����)���_>`LG��q� �����:��h�P��E�T��)3���;PW��3���ex��G�8�M5�ħ%��TA�&N��ʒG���be��U����5<�4eq�q��si-;�(�N]V���H�N���n��鏲ſ ӝ�h�^�o\;�8�L�ɻ�r��]�F�a]t,T�8p p�5�a��?�����U��w�q�m1"�J5(�pz���nߺ��Ե�x���=�850��&p��]21��;�R�9o���-����SҘ�2ϝ�˔���(=J��L�hG丄<WF�A-{���y�/�_�A_f�=HS�������I�C�{��A�cH45i�Y�>->܀scS/�AH�w�=w(�U��GpA߻�XG>F3��u�՜A�tO��Z
�0�)�H�n%��i��癭a󦔷{>z�v�u��F��yĤ+�c16)�����1&��
�'��h�+jxu���~����o� 6�.rm��Q�@$������v�Ƥ�j˱|E�'�u�u�u����T��7�pDN��{�y��<,�N9{�JtZ���-"It\�Aǚ1|�J�
�_	/5��E��ź���e�3��e���s����pf�
ə O0��� o
{$U��e`F��/���G' d�4���Yw����aLC+�I��gW)-g�����k��'}_�#%cJq�����N�s-2�ƀ�!��z�E<�!+mw[��	|�0!(`�όL�~��H�}���]̥��淙�5Y����5��(8͘9Z��
�O1y�%�j���k�h�zh��#�O}�%�ƹV��АS����+�r�¡�wi=2UV�k����mJך�T�<���/_���\��[�_��o+����z��)�oX�-4M8}���\����zz������� ���]����D��yao�A%H�S���� xim0�43~�3NyM7��Ģ�v<�ptf����n�.$��fm��C�Y:�"�FnW��8MT�-��	Pީ�5Õ�����)���I��^ʟX�;�-�s��x4G��~����s����� 0R�L~[�~?�F�4�@읜`�7RY|�ic�|�2��w,��g�ț35�a��S�3'�������|X�ļ�〱+M������>�^��eŷ՜(��2�V��O��r%~���W�05�h�,�I�!�]�1�^��V ���;�_�IqxY�����.���l�
O�������p��C���@�ad/V�m9������9<{��=$%/7� h3ؓ��Wh����RnM�0K��zufn�o��]wcp�ie+�9�Q���з_�h�&�jr�c����s�C�-��<�.��O,����!L�@����ͳsL5 ^�8V�14<f�J��+���� Y��J@N�%�� �����9�cWRy!q����&=8!1~�6xy��"EI�=e���Ʊj�����iDM���0����A��{�R��F�_z��@�a�=L� �#�]����gl������@�5 �ӗJl`'�z��B�"��7(9s5�+;�D�5�(�q�F@X�;�;�*"~���Ү}Z�aBV���̨���s����}����}����~�����������`?ci��}��=�ݟ��>�O;����>�O;�������ۖ��,�p���������Ry_}�MDC{������17d:�`�@��Z�]�	j���ZuP^�����'��9YϨ�eA}?:�OȄ��<����VP��?=�D�P�[2�1Rg՝�c]�+�1�l�ӥ�o����U��ȅ��+jK��,�n1��d���H����s�2�?���������(�"r}�\})��o:~�o��+k�����q!v���^̹��8�407��rC��ڿz����2�ɻ�<"#{">���U�]�}r���?�m(���R	�>/g)D�ɚ��ݼ4��ON�Do�����ƒ�&C���_ [��baJ����:�xYyy���Ei`�1�xX,��1�'޴�V��߇�~��g<�hӥ���	�4Wl�����gy�PǮ<���圂�y������~D~��c_tS\�Is�s�}�� Y�5y^ל:��=��-<���X�܄TԴ��v�"=���|��$�@�c=f�1��z?��mMG-��8H�����L�,�1cTtR��S�榷,��i��&Y)�f��>S��ss�����w�o1��x�Y�7�P	L��8ڛ�8]r�h|H5X��0���"i@�rq�_���[�X���}�����am�yT������(�V�q)�����\���ɡ���P���|`�{>�/��^�Mo�d�i�iC�q5�K+bb��U(�[�d�g�ϝ9��1 �  ֙{�Pm٦��-/a��0`�'k�ԛ��6�B�(f=>����y5�c��O�:��dY��AEɕیQ��HHH��	#��H��Q��I�s\Y�8��hK��?�ϻ"ʤ*���m@��cMEڐp�U�P��;���/v����V�QMfcJܐx��g�:��X�U�jz��5B���Ɣ4k��)X�Z�
�&��R����3�+�R4C��5�ѯ��G~T��F?㬚d�yD2aE����-Q}��P�K��ZoÀ��I�.N����(}�����v�;��L�^��ȕ�D$>t�#F��S��ˍм�X)̬�z@<L%����V�w�p��g*U	�po6%�Y������7�Z�D0����������e��G� �� ɣ��G�]\�,4,Ҁ5�u����9�ONo>�ϝq����U�e�o���ۛ|y��z����ka�,q�ͪf�U��RĻK�F��9~��$?zzFM��d%�����R�vb|� �o}�CtL�Թ�݈U�ix�J�W�2"�h֤��I2���7���\�����_A�g��h��]uM��}j���St��e��X�`,R�ͪ�fc��|��)6������!��i�n�K����QB��T�7��9��Kܦ�x<�k2�_�k�=��ɏUk4�P��OJ�0eB�E�Y�]h,8)Y;\����
ǖ���b��m��Z�J��{��V��X�o�T���ɬ�GH'8�����^�5�B�oF"����#Lt�����v;7�1+��o��i#����"���LBS�Y:/s�,��vgd�/�V����O��iiz��K@�"����5�d�
�I�� ~6���`���:����aJ��O)��O�$d�]~��+L�F��g�IzXj%�E��>��Ə�L����iKw]�*rm�^�@�.Y�j��+�w���gBJ�^���tbs�Ze�u�oA�s.y�����d� ӣE;��1�9����<�ߝط{�G�A�X�=lZ��=��@���Đ9 �)�\���ϰ���w��7��o[&��>k���t�؇�2xZ��������|�rf��X���(���?u��*O"�����fa�������-�rv����3�ƺ�dn���#��!q �V�4���R&�9txadH���/}c�x1'�ֳ�����-k-L�2z�H0�ŨL�3�i�I���?�A韱ƀ�E����8�$��R�=%k�g���v\PS��;?W��_\`a9x�c���Λ�}�՗,�KĞ�B���!ޘ�&-���D��D���TcDM�C褻ǥo���Y���N��������8�z7&�y�[�����
�h� ��q=�]�@`Q]��^�F��ܠ[ՙ �H��8�;��lJ��MX|��� �>R��Z�U�5��z�û/<�k歐��r"5�{_{�솏�@��R�R�G{���x(	OC ����?�􆤯�Z�e0��u��c>��1��I1�����.02�������G&Q�6q�qg���F����o��E��5(˲�WZ0aͳ��)āAM�R|�á� ?��(T�i�S�"��s�S2��o�`���<&�t|�Ȱ��ԧx���;�p_�sZoY�'T_s������{���?g�?�7�C]����[)q<,���u�ࢳ���׽>�f����ʷ{O&©]̶CJ�3�_��9�v�Kc����ex~����`������ {����@���G`�٤@A�=�MZD����ށ�Q8 O�����X���ֲ4�)�{�ȿ���Q��3ڌ[���Ǎ��X�7�_��N8ec�����(Tե�Ʋ.O�2���&J���S�!K����؎/W�b��q��4�c@{��V�sPk���y�~ս�� 
<�*����+{�8<0Z�Uu�+/Z��,���^�d?�_�u����.������]�?t��_��ͻ��c}������N{��7{�������=��v��?�;=��v����'��N���?q��#���$���g����C�����������?��b꿳�.�ߌ���N����;��������3�����|����ς]�?�};�:��{����������~���=�C���Oa��N����&����?^~�"C���o"��b��M��	G��s�{����V���1�e��Q܅و��.9���e{��}��[_��8���jg�"_��|�߷o��NLF�<g��ڝ3k�a;μ��?�(�=�+�a���7
I�i���4{>xb��}�����:�ϒ�(�n}�lp��$� _�	����=t&B_`�
Ȭ�	ޫVJ��%}:�"�ZBWX��p�)�a�m��=0 ��鼒��"+׳_.�?~�o����Jg�N821��H؇�`���;7����=Z�T�&�h/�� �o�������F)��¤Ż����m:��r\���A���Q1���uC6��^ ������'6~�"Prz
��:�͕�C������|�p��Ń�L�lL��5���m�џ4��;��%5�^Ck�����zxz㢝A��\b=�Q�y
ހ�6=�gDx�eiֹ.�~Y"��`���])�	���޲8��hq���o:b���� 1Мt�`O��/�<`Y��f�X�r.
��w7��t�a����:w�:&Ж� l+���|��/�s`�W��~w�q�s���F�#��t�x�:���S`Z�T@[{N̈́y���=�/���n"6�$ʔ��}�thaa9����p@82Єyu�9(^ױbh1h�s������"�D�����h�� :�ӱ�(؀���zv	�8����!�^�z�e]PuͰǯr��H�(O.�dC0
�U�9����H3현�6_*�m�q:ޜ�i�jR�
� ��"bt`Eq(�wn��kW��Z�m=	����}�ˎ��]�Lsst��zέ�Q�����V�ӛ��Ν֬�r��g��NB4�O��6/��8!�r��$$@eGM��w�.��!�4׺�aXk��}��k��M=)g��j�0����$A\�ȱu����ӟG|^_��j? h�A�Y��.Ӷ��ŕAٶ����&�w�f��1آ��WϸZw!A|<E�D��o��oj˱�i@&�U��_|��f�L\�逹������yEm������0��$t\J" ȵ��] "S]%}j��K.�S"�A1���x�,ԭ},~�Qk_�L��a������X���M��& ���h����M���`N�˘�����ๆ�¢�Z���7W	X�1����7��n���P�%U�x��C��{lr&��KM�w�T"F����t0��}�i~)�& |��^0'����T��|����/rFY �N�I��,w⨪�x@H�nU���A����J����ۢ�N����'*ЙD���{��� -�^�Vd��ӬW	���Ce�f���w*yG_����24즢��&�g,s"����B�y�Ӳþ�[�����6i�}��}��[�����ʋ���`�ez��y��p�^!Ia;��3�<B�K�Bކ��\���!�xx�F����@��y�6.�-����͈���|8�K�L'n{�=�䍶򃚗���R7z޶��_ҹ��-Ă��6���j������"��X/������w:�����i.3궬y���Q<>A)�"����g/a]�'=�dH�Ky��C����� �v5{�%����V�BJ+rm�<�= G1w�L��͛$�% a��-���Y��^��g�{����A�a��Ȳm����J)qq>�ӰJX�^�CF��P�/y�F2�ys��,g 1��>��4;9�&&��޸$���- ��gk���f�>>���?���3/*%�d�������������E��      !   z   x�3�0�p�s9����5����5�3����9�M,,-!|.SNCSN_G_GoNG?�oG�#�:\Os����u=�����1�������II-.I�v(�(�L������K������� �x%?      #   w   x�3��ON��2�<:�4)��˘�7���˄�/�81��ȭ<���ˌ�#�*�(d����[Z�e��xd~iqI~1�%�ke��=9\���ٙ�\���މ�G6YF��E�9G6fs��qqq �;#�      %   P   x�3�tuw�2��u"G.cNGoW�#��L8��"P�)����]�}B��8]������9���s�D����� p�      '   �   x�e�A� ��c*c�������j�U���vYs�:�km�e-���:l���=���9oX��3���Ж�B�fnPOh���y�B�T"-�b����u���5�s?�*�h���x����xtU��ɪ�π��F;9�d���׀��tv9ˍ����.9��i�V�G8�C������UJ� 3ԉ�      )      x������ � �      +   W  x����n�8�����,DR�˴ɦF���z��jBH���"y�R>ɦ2��d���Ù�^Tl^����ٯ�?�컷]k�c�W�8+�����|��_p�O��v���K�ۗ�v��0��WQ�&�.�I�U������]��&��8��2����=a�j���O�v�lk��C8�u�����ϭ{��a��"���� �48�<l��8�m���w�����<�><��7
�?ϣ����v@h�ܱ�*q+t������+�����ׯa�,�%a�IZ��,m�yApe�D��w@������]$"v���EҌ�U���E3��A�g��y��e���y�
{8����>���p}��=�G��UW�ٝ{���/qB�$�E�ۑq�Q-R%����j+s|}�X͗��ף�/!������g����Z�����KTNH�.��9g�g����'�\�$��r��	\?9$D
2߼���mH����	X('��!q��ᆟ���-�+p14✱�S͸ĳ�Hv�)'u��S��i&��O��2'I�1S�/��)�)�F�-JB�@4G�1����o�5��x�B̅���n�Ү���هv��4�� ���!P�%z�"W	��y���(p���I3�-�o]� �	�t.�{��˅TCK��M3���m<�P��l�Wiȗ��ciV�����ˮ�'�C���	ƿuװ�ᝌ�"��M���,�.��"7R�%`�ƃ��"�`Jv�y_�@P��S1���`�P$�é0�K���`^�y*�	:>�#)BMb��qׅC[� ��Uj��^>��P�qd�"\>�����H���ի{�����>�;xx�
D�C�'m�L��H�����[f_l3,�o�m��-(�B���z,������&���"�"OP@↫M�!>yqݴ���V���H3n6�c(��)�z#d�3w- 4�o�By�[�iAB��!$����,<�J��k�p���㿬��4{��\�Ţ��7��?����Mǆ�����,���3�8���,��ϿB�u�CK}Gp}��PCF	��A_6x�7��>c�ǝV��������w�����v��<�E���r�|������m����v<*,YA�M�0�hakpU!h��v[�[��0"8�/p�@�<������	���c;��p��<Ũ��i������tlJ�*^N�O�a����a�p�;����Usl�'�$!E�V��xPL�1i3"��n��v�i�Q�0����f�p����	��Yj���2|D:M_C�F�3N�!]4���~o7G=�pA焿9�BM�k׽q���LQ�[ל������[��f��Ӥ(�W7�Ni[U�����A��#�A�Z��M� �Z��Z�#N	S�1����9.�F�/�TP�/G�c�.�������!"I�n�h�϶Կ$	�����K�r4��P�H|v�ЈB�'_�aUx�)�&�S!����(���9���@{GUL d��Q jPē$ �	�
�I�	@	"M�	�5��& ��I�r""g<�H�����8�&�q&ø�D���Y�<$�D8^��m��xN�d9�W�ZD�yN ���...�ZU�9      -   S   x�3�H�J,*I-��2�N�9��˘�p{b�����I�\&��@vjnR*�)�sin"����1���24�tK-�H,����� -q      /   h   x����@��L6 q��p�/�%�����5Ѓ�zy%<Ǒ5Kg�X���Nqf��\��<C	�>��$�;��y_����S:���s���_�k      1     x�eQKn�0]�O�T��4��" �D��}z�.9���^��v3���7($�h�z��ָ�@�n�����f6�͎�[ �0�[�be֋?���L���f��TŤ�fbg�2�IJP �v)����	��@��h\����W;�;3.��\���_JI�%���O,�07�ҕθx��PU^�Y�I�C����():o�-?�09��Pj�\�b��"�M��]5S���?~����t�����;o'7��(@>���RL�u���7��{      3   �   x���
�0 ��oϱk�7����++2%�K�� ��=Vу59�G)0��(R<��`�@]af�읟�ռ����)<`���$����i��&�L�u��/��=�~R�d�s�mY�䫄E��s�eZ-�V
��.!���|#�      5   �  x��Z�r;��_��-I|����i_�$J%���@��΋;���l�u:��9#�_{3C  ;�H��8}�������Pf6�x�n������eE���s�'l���\�|!��g�j��$f��o��;����i,�w��ryL^5;�t�#���^z�f�;���!���$�]��T��������g��=c�w2��q��'�c�@_߽�G#v9>>�Y��:����txj[�:�7�x����ؾ�al܅�éumS߷���_Y��j�����w�m}מ7����mM����vz9���e8�?�NǗֵ�a������ᾁw~b]g�����/�®o���缗a.Rv�J��B�'�BM�R*��;)%��-��f}ډX��<,�M��0��Fr�%*�2��mC�f��|��I����t1�C���m�J5G�V ��?�Me� �`>�O�L#0	a����E�D$c�L�N�i44���9����$E�t�-����p.�u1���yt	vvO�_�34b�b�����q�3O���섯6��ë�1-/��5Z�]��-O��T�����n��>ƙH��OK�炍�4q�T+=�9��?�lj���ί�)f9��O��~��&ho�ȿ��ː_���-O�e�W��.;���(��f<�Ac�&7y��C�Ӏ}ny(}��)�D^�)�h�9[*�"q;+�2�C�uZF��_�#Ň/(>.�e������x�*}K�\�2eS(aC4���w�Qr�v\�HG�.n�HL��,���)�3�=���Tޗ�8�f�kg����hs��ġ�d�]�pVB��
����d�!�-=p`�N(�]󧇀���u���X�7������Kb_�_p�%q�Y.��	(+�p�k]0��w2��;���@�d��|`S�d�D\�B%ю%�na]���<!˶�d�T�6 ����p�3�'b��nŊ����Be�����6�a�y|z�[����F�p�B��ij�@֒�!e�������H��f�t!�d��^�*��B�e�<��3�Zίɧ� �������s(ى�e����}o8��,c��/���aG�tt����z8�8s�Q�~�n�s�F؆����i�����gP�EX'׆:�Ge��BA�<��(�9}q#)���=$`�ذkX;����aYӡ4>���
�����CZU��u�Au�:��[n`%�٘�9+���xHa�o#쾌�!��h�ϼC����0Q��Tp���pR��\�r���5��Va��C��yN��N��>��p�;]��o '�O��Ԧ��{��AUk��;�h�!� Y�"h�9UXF�n�q�iڨ��8�"�Ww�XC��C����遶���;v0	��7d �dU���%���������ܭR�þb;{u��-(aU�L���o��c�,��7Bg^�{XVre�l�"a���/մm������{!f�RzV ����YY}��7�ߩ�n�SR�� �sP^z��H�Nۻ��g����6�.)�_،��)��N6�)<~�p� ����!�v��E%N��]:��~�ʔ-��P��W[���^�������{�
�Ga>v� ���;T�sqk��b�~��4u�視��\������G�ժ]6���>�����Ψ�TAcD��B��)-;�[�M7J,���N�j&��X71���wppp'����0[}%��1�|�F�����1��U���{^Y��b����N=��N|��[��0�A^:�?�u��uP�5�r-cN�Ə�xX{���v��c�|���/6GlG�oO�i�َ���zs�֨fx���m_Ę�5�I�a=xۗ0o�z���5�o{k{&U�3G �D#�}�h�Zz��&'�+3��O�j#�!zE�D��'r�;!Ӭ�z��_�I���}E�Y���Q^<B��QJ
6�<Va�z�:Ilk�.d��r��H�LX��v�6���~�)��t�1��7P������I$��]v!6��.Jbb]l@Vo�+����C ��"��ufaΩ���w�;�߮ms� �
ކ��N*�+�c�}�̧���PΪEN����fG�Y�d��g��VT��[%sPS��e��X�/�����ߝ�Z���q&��y�</���b�� �#��(�\5����M������UM��X�ޠTM~Ր��$�
�JV�܀:h����}w-�~E�&6�o߫@�[�h���L�:�F��bų�!���a��}�r����G�?��	��$,�D��Q��jvr����ݾ�X�/�����bd'ŀ�҅j���M
�k�S
����y��IFdu�j��Q��.�-G#��M����k�G��E�V�"���	����UL�o�����&2�V�uM[zF�A�$�Ŗ�$��i�f��7��ñ/sx
�Ĺ�5^P ��t�����[Ѽi��Z��fS�����/���t���Ep�$��i�P��w\�A������#F��ޫ�4kJ:�~<�X%�7�F˛$�u�t���kp�j��S;��uhT�<Dí�Ί0�����®�	��d=?ZjF�x�0R��n�s��0�`Ѐ��v��tT�|[k�T���^�����nݠ��ʂ����F�trn]g 2������@oV�9����F'�ţ�_1�g;}gdi������3-^��W��}���}O�kuX��/�+�J���,�J�&Ϗ![@U�� �a6����HF�(��Y�|k��g�@ࢌ�-M��l�����n�5��0R���2UU��X��������'�z^I�~5�]�n�ț$,��:䌗V"���^5IW�"��{� �˭�|{G/e�]�[Q�
�yKߩ8xs���v�˲�GAd�rrG����j)YrN���+�dy����r�}��bI�=�iBΰ�����>�tK|}��ESH'm�_>����P�Ǖ}��~����!��-ɏ�����Q�iw^
�&13�j���0[M�)��7I����UI��'K�[���/����(f��]+d�������3����6�����6nQ�����t�d1{�R� A� �ʲ����ү�-_�ѯl��A/�M�ӊH���w4���j��Xm#i�?>�|��t�>���tԍif�{ǧ��'#��VŻ&5��|K�U���sI�
���[��g���b5�Vo1��z��`J_L��Q����q��ի��q�      7   (   x�3�9��(���T�� .#N׼����W?�=... ��	�      =   4   x�3�r�u��2�t<2�3��ӛ˘34*��'ԛ˄��Ȇ�#|�b���� �[      ;   �   x�U�An� EןSp��;���4����lu��`�����R*=��|1��J�,��*Ǌ����f���_��q9w5t5 ]�=/�]��h��C>�L�k;Bpo�=���s��M�V�iuP�A��ۊoĮG,ɠ�j"�sp'1���8��ZV��@�}����#5���t�S��?��x�m�����'�P�^�s�<1O�      ?      x������ � �      A   �   x�%�;�0��z�.��x\`�XQǱ�6�4�Ѥ�ؚ�$�#���i����<{1�8�~	,#��s}�OR��T���M]b�ӹ�&ڡ��(�L�Q�<�C��ZaӖ�.����t��3�0�      �   I  x�=�]��0���U�
FM�$�����w�������<!����ל�$O��ı���,��]ӺyM$r�ʐ̔�����y�$D����:�L�Db���n[�	�6�jIX)i���#U*��fj;�\��HU�K�x�1�o3�<mL:Ɛ�x���>wE�%�n�_wW恖	�{_�ҁ	!�}?�"`�"EĞ �騴ԯ��+cH���'=���^���
����xȖ��_<-LJVV��ub����?O*L�IȂz7�?)!n�����#���a���Ya�A�D�������y���C����Gd��J�mv��N� r���|�nE�����G�q�ˈdE��ţ:U9���Y;�).ʀ 7�I�
B��7�A����7/T����ްED%І6-d�����ح$�!���;NkO"�њ���~��" c��ݼ$㓦���ѿ?�+��*q�{z?Z��te 1�8��l�f�#�2��Ё;DQA˙{��։/�0~�N�0���g2�������:08?\��:2B��)�I� �u|o�'@d%���gĔ�]y�ze|���mq�)�P���D�Ti/�L*�F����M�*���ꧥ
Cz��0�
�A0좍�Û$E�FӅ�4��"i9Z��狶U�Xc��{�H'� 6��6��� 
C"��̶q7ޘl\�X��g����m����Q�¸%S$��^�� 6��װ^L�H�����q�����Gytz����q - �e�j�rr�X��|�b�! �B���
۰َ�!��P��5��[I%^�7�9�&�]\��1�7���c�}�β�?���      D   m  x�mY�r7]_E/�*�K|���6�~�&E�l$E�e��"Jv��Tj����o��Ξ��so�AJIʉp���\pJꔾ�#SE���SS��hH��~��7�#RF�
��73p�@�TM*��D�j���2> >WZ�_�*$e����)������02&� q&iT����o�Ƣ>.�$e�P�c�3O�H5��*�K��$p-����MW_ch*s�
`�>������$S���}�,YB�B��u|a`�Y��p��G�0k���)��'�/>c�#O�)�1m������Y�6��ƚB9S*j���Y���=Q�
e�~Ԧp�nx�ijQq��������7��v��Y0�v��r��v
:?�uc
�X��*�%��g�Yh�s��xxD2X�L=L�Ui���tiW��7,�:*��)�	bVy�2��{�K�(ll�K3U���^1
�F��mc�(ZP��2Xhw���[S:��e���#c�rF�-ˢ���N)]Y吥���Nv��E3�t�>�YQVWM����_y�#S4W����FC�N1kM�rU���G�E�QY?��V$?����/S
!ʼ���#�0�P� @�v�9�FS��v�m��:�u^Fny�z����/��ǐ8Ŷ2}}�[F����n���(�;<��hn)�%����#��r.)j����L��|�S�O0�ϙ]P��A���҈�-���-�{<��=�����X٩Нݯ90�Ǥ-�qV�)���#S��4SYz�\��r���}�e�Ѭ�b[�W*�bg��hvB3s�9�_���hfu��f���fo����pUf�B��gd�19���f��p3Z�0����1%
#��}�?�P�c:����c&SJ4Fio��K �%s���r� OF� p���5�rf�X��Ͼ�24��b�
�S�5������P0b��M�9��c��a���\����0���C�%��z�����Z��%�t�{ �r�-4�NM�򮀯��E x���2�3��'��<��V�s&��ys��_�͇���B��j���ә@�4/ 1���j�>�y�P����n�м�(���g�^�hJ�&��@��IJ���^�L���g�K �0CoE��eF��>����g\�dٝ�nD`'��M��R���6V�G&�j�b�3|�aH���&T�q�BQ�#J+JK䀷�I��e�k�q��و�b���HO�Cf���/�n˝�"[`�[����0HDR��a| ߝ˖e5��t�.�ߵ\nH��̀zx3ݵ7;�4���N���S"w�ؤUS���7��98[���,�*��W2�G��ُo�?�y+\� E�'�ڕ�yX�K&S�	i��e��\r���Mm��r��;H��i������b�t�l�}�[�1��k���N�����y|�.�_|�5���(`3��}�yT�����O^p��Z���-�7?O��Q]r�W��Qq�cR�+��k�qY���5(�\q2�;gs�Ρ�ٛ㜕4�L0�!�_��W� (J�A��`G�Xg�����83����MsЏ�����yx`����:0�m乐jzDqNq��{�:�����l�ѥ�RІ���F�7��������{Q݆q��ڛ��I�	��t�wp����tR��}����w��5��V��~tL�)K\"M���w�K�E'�.)S^�.H�@'�&���~�9)F��ي`����Nj
Xy�p3��;�<k0N5Hmc�t'I�����Hua#)l=Oy^#ys���oV�Om�j�{�*�qtlX<��pήi�����j�r�)\,Qu�v#��?�%�7/�¸����~ZL��;�v�.6"/�z>Ǽ��*��&7������g
��
�F|t>� �c���x#�
.�7;��.p�,X�V|�U��)䋔v��,G~��J�6��X#��m��V�|�+q8p�<�i���p�m7REA���
y�] ��ߋ U=@�BB׉-w5s#%}@^X�%��;7R&�䊸w���I5���@�L*A���!=�P.&s|�i�[�@�
�=��o?8��A��͋��a��
]�.�K�3(2�3�=�I�w���EtD*k=��E[���Z�V�澽��
��U��&� }G��%�s�{�#������7��h�x%݋�V3*J;+��e�w%�W��%�P%���[��ME�K���p��hw�ç�_�hq��*����� �
ոZʄ���`F��|�!�C'S� ����$I�Wڛ�AT�.�*�2.R����U�����^bP\�r �k�	��.����?��x�('!n��&<�4��0�Z�3I��0���L��&�mF���z�[3����H����/��C1��J�A#����q�}�)��3�[}M��eM��c��l��m�W�S� �ϟw7ވǠ����� �u�Pp�f^5��ݱ�^����	i�����t7��w�I����a��V�{T󱭏]��n�S� ��+��>E�wp�'Y7�"�&6|i��g��&'0o��� #�������l�������z�z��e��2��JRA���;�N�	�	`4E�9���S�O�n-h�$n܁E��b��4}�_��$���t�	[f�}�J�H��oo��B��R������]h����@��
2�5�ȭ���i=��J��k���Y�1^H�?�/}-:1���uKcA�m[Lh�|�p�y@H�k|��;� ZuL��vr��+���b��=so�G������m۞�D�o��7>�B�qM�R��AB�ʳ/Z�ZCY���.���#��Ҹu[Y:��A���^ap.?}ݬm�}M�[�Sf��neK	1nf����O���N����t̮�Ԋ0!�X���2�8��+�Z�����P�'�9ZN��3��C4�� X�qxt�.!W���'�u��.�t�3���$vC��JDH7/����9Bf,L�Z�2T��J�����\cS�A/����"�۬�B�/�/#�I|�-������O�.Q�`��g�i�6��"S�8z���B5`h���k���o Ϣ�ᐚ��̎���~6@td+|�U�~�@V�5F�_X�Y���hh��F9)�H$��P�EB�|Fx�׻,-�[�?�l���e7�l@�-A�M��Y��d͐����,��+��ϥ���Jc�>��\��1�sZ>!~�AE�KZ�<T�R�$��a0!5�H^�+��E�h5�,W�f�	��̒��o�r��y��	�N��g��?I�@ONפV���ϒ�w`�
��%���hV^�xz�,A��`Q���7�
����=�Ucz����?�v��(M!7����I�g�g����Z�D���"˹}�}&]t-��������m�@'W�=�W�Fh<9_0����<��|� M�)���>�7�K�t��g��M�C1@�x�����ªQ��;�K:=5����P��?�A8�dB���b�|�[�9AR���2���.�<�/,G�&ǖ����+S�i��EmS���Q�8���H��
&���:�������7�<��x
�����͗���d@������f?9�0$��S��W�s.���͛�����      F      x���ˮ�v%�>�����&���tf'#���×�Lg�ƽ�
�=խ�^և՜���
��b=���̡sb�R($������?���ش.r١,�+}�7/���o�K���r9~���`0��`0��`0��`0��`0��`0��`0���Am����g�����x��p}��?��~�]�O������;0�3ߝm����=������Җ��<ߪ����{�l�`0ރ�=��{��k����~T�����y�<W~�;x�'� ��x?^۫\�n��e��.V����p[{eM[S#.�[{CԪ���\����p�n���q#,.Ŵ��E��贳�(G����}x��Ӷ���y7m��6<>�qo糣�h���O��`|%Z�.�h˖�iqI㗤�%-��kh�5���y\�˹������k��2��2����m��w|�.��s.��p9_Ȩq9l:\O�³���'�֏��m9��-u���*�-l�4�ν�#ݝ���u����{;K�BgD��MN�Н:��mٟ�`0ވ�U�������[\z_7�N�k}��?�5#�ҷ���ޯ��L=dg϶���{>靔q9��������=:_��Q�$�Koɠ�F$����e䗑{��S���pͭkK�%��H��ܶ���Ӟ;�[\htm�:���lo�(�Q]���}:�������`0ޅ��xՏ��������^��ORyV�"83ڴ�o1��n3��O���R��j���ш7�щMf{�O�¥�m��iۆs�<89�3{��k�L�g���bg��LS��t�3=i�j���>����8��m�k�֛��h�9��hKZh�L/��q�t�I)�K:kܞ�����3\3b�1��tTvtđGz���;�i�����=�O��`��}�
w:��@������6��p�l?��~�A���Q{�0���E��Ѩ���:�d�=�Z3�A�m���u��/���~���y��ff#m �&<����D]o>�egez`���$�Ѓ�;r���o�]y�w��k8>'疜g	i�cFf0�W�iѱ�'�F�k�#��vzOz�<[w�Ƕ#�m׌����|1�+u1��})X���3�Y��ӆ�3=x1�9�>�-�$3סU��Aj����\'=��;��@׃Č��u�ә��܆��k@��x=1����s�֧��edLzO�9� ���E��٢ЖE�rf�_����8�y�6���sa#��9h�q~��>ј}~p�+��G���>>�&"�5]��mW���;h��f6GoՑ��}Y�J�<8XwG�8nOO�ԣ��`0ކ��#sј�o�|f��ζʳ-k���unԨ��X��_ec���8x�P/J꒶?=�d>��S�������~����##{�Qh���ᬌ^��s����Ϝ�3�����/:�%N�ҳG1�|֣�8��凙V���(<��G{�8�������v�s��h�Y�Ҝ afW��[7���"�N{x|�.�I5O|rF^8�`�#��_F�z��RgW�|�~�G�������CQ���I:�gJ�}��֞�%����,N�|2�YG.敆��c.����h�}&���/�χ���*�},鸓h����!}��r���ZG��ᚐ:�vJ��?y_���t������w�l��ɜg��.�`0��{��ꗾ�~�gi_������-��S�1���`�i����3��k�����}�5��x~�o�{�!�V}���:�gk���1}���k,���l��|�s;�m��|�V���~|�e���[�<>�����6�a���;�A����k�ϰ;���c|�_�����c�����y\�k��ϳ��X�¯qw�_o]y-�}���>���UμC���v.���=�9��>~b��?�r�����(�Ь?��ok���C^kI���x�?Oy�m��+�5�ɷ}�̷��s�x?���k�|���n���j���۷ݯ���?
�ο�	���9�;�#������9ӯu?���ዷ��w8�^�~�{�{8�G�ᵣeƯ�ӽ�<�ߖ'���A�wڎ(3�3�����S.Gʦ���Q�J�:朤���s=���C5����m��@��W�x�Jvt!��Ԅ��_{�mh?�nN��}6(�x�׌�}��W���j]���<\Uz���zϯ�]��H{�V~x�{=��U�{{�~]�O:�G��t�,�tv �O��$�l�CN��T�>�X+μ��C]���sV���i�v�����/�䶚7�Y^��3�>��r�G��ı?�O��_�͆w��ބ���kF<�wT?�-�w? �u=^�j�A�l��������7��<P%�'Z2b̑N8��x�r�n6�i2l�W��I~�w)s��W��sa��mo�~u̷?����C������v�8{�S���o��ϕn���c���[r�}=������2=�ӭ�y��y��������>�=���a�7����ZBށ�f�S#ҡ���f�nZ��|�-����h��3�=9ӣO0�Ϯ�X�3���D{_xb_	��<��<���_����WCݽ�w�������y{z�ǟ�g��6��5�W���rQe�tFό�/�cL��q���s�tT3����l���{�P�|Mޣ�/*V�	���2
���|�������s�����δ�5�<{3��l�5�k�g�������_ă�x�.zp�}=?���s�Rz{��3��`i�5�	g�f�����9���Ҹg��[���r��sm5�rq^C�j�������ZPε/��yTs�����vሧ�ha�Yo������7Rp�|�S�e��'󄩺<a�2�.6}�/����|	f���p�fg����Ö�z�ffƟ�'�m{�Ѓ� �jD���Z�3Pz�8��󄂛ٚ�w��q:�y����*��1�x��'���k-��U�㙲>�9�����Ƹ4��8�&���":��!g�*�O.��fr���y�ӝz�{g���\������uq<�z~籥��1��~��mi����Wy���걏�^�qO��{aY}�k�sf�Z��9/T�x��ﶙ͋��@����B��=�E���_=�x<8���]y.<�����/���g,��_�/x�O�������u���b����ˬ=�9��g�ynz��{�����a}>??8��T����]t �m۷�`�8��4<5�4��0쓼V�j��^k2�q�R�/��MU\�v*5�2�f���yg��+g∕�O�y����y:ؽ���[���m�0;��/�5�����{����۶d6�����J��/����m
b�Y�	?�|���Ń�U�y���Ȕ'���<����{����|�1_;��<�� y��~;���}ur_�6vR���w�}���˸=1 Y ���b�sj�ᔞ�mi*{���Ox�]������|�K`�{|���Ń'|���	ki���_�k;�x	2��}���S^G)��?��U��o���Lt	P>�"8/3��g�m���g1�[8c���=N���_�l?ϴ��kԆ3(r�C�����k�I���'�	��.:�7�zV<�}a}���=�J8��>#��E��QH9Ny��®|g#��L"y�3?����(��f�8g�x��˃3��B֣�3��D��"@��2;���9>!M@�-���辵�'�;��轅��&�Йww�સ<��2�����3���}��ޖ�d���[/<��i��x���@�}دc�O�/y28S�C����'q�O6tN9[��u<<�s��L)��ʃ�� 1�a��j�|n{ƕ'����rm�?=ϯ��\�g�3��o���x�K�|����0=�c|�M��m0{޶��g��ӿ��k.�ϛ?ߞ����T�͉�]DR<���{?T��zO˻W�$��Szp��{���u�ȃ�z{Yu���k���=���q���i�6�C�±h�����];���m�X�!f6�W�l?a�Ҙ=o��Sz�1�=悆��SO5��}��5:������g��4.l\̮��>    q�'�D�҃�z�p�z�p�3�9�:?��"W�$������{���Q��u��|��<ݑ�1����gGi��au�t��z��^Ѓ�c���?/f���6�|�s`]5Ӄ������,|�
�9�wϚ=Yhg��6�u ̋菋����k�~���hG�����n��<��+�|>�g^+��0�C�-�����b=��뼟s���[�1]|��:Ԭ9��U|�O��I�qV�a�� ƏŻ��#�a��y�i��C=��瓨�fv�h�|�E��*��Y��c##��3���*	�=Ӭ;��q���<H��ZG�s�]�W�*?_s����%�יM��;=[��_��+v�3�|����*;���1F��ݛ}f~x�}���??�o�:�p��?�m��k��H��t���y��f�(>Vv3�w��c����刻ȳ}�����|
6t���~H#���E��6��%�b�9F͜�3�f��������?�����0����ڼ6���ᯄ�wpfKۡ>8~p���/zm����P����+���F�2fV�~_�d��6�[�T�c<�'[Ny��a�N��?���;'�UҜ=?s�t���pJ����s޲�����t��Y&��8f���1���'�<��Ğ���������T���OQ����z�p���*�����1�C����+�Y�Z�7��|ܫ�+��F泚\y�߄3_P|�l���#�ଊ�!?�i���~g��?���1]?�,�lv{���E����d|O�s��8��}��d�=-�٥���G|�{��e�~fF���O��i��Wb���S�t�Y��*�0���@}��5�0�|�Gh�c��W�j��YZ�I=��=���ՠ+p�8�j����_��w�|ݦ��'g=��/<��:�-|��9�G6��_� ��f�8����G�'v��vV��y=x��9�3>3/��0y�.���hp:1Ӄ���Y����K�6ԪC}�ɹ��!�it�sA��k���5zN^���^:0.���'F=�>�l6�>�����o�����=�l���3Nα&\�G��z��,���/#�����Eb�}��	����W����~#-�3?�W�g �Z��W��J��`���~�gk�e�|�%홺�}�	,�~U8��zSo@o{��Yvng�rf#�8��y�&��k�fO\�1^�W��3=����:Ϫp��_������ɜq(������[ΪE����Z��k�v,D��A3#��Ĵ^��0�a�c���8���b���Xg�������yy#�ވg�y���W��wͤ�~��x���竓��������Ѩv�π׼P#��P��t�Y�֜��zu�'@�yv5����'�\�bf����_�_�,��8���36[���9Gh2~POK��y��3�����ݙ���n��~�e�a]�6ϘX����3�7�V�|���}('��[���f��W�P�]�o�YJ{�:��^=�#�����Y�f��L�O���O��/����s[�qN�K�t����g>*3��}Tj�͚;zI��z���]���w�65wx��G9?{{�>NxG�����k��V}�g�����i�w�&���m���q�_ӆg��g�Q[2��`0��`0��`0��`0��`0��`0��`0�3�E1���c�����o���*�B�~�q��=������x�3�q��z���5�P]���"��&�I'S�	3j���Z=lu�/��{��O밽�m��8�u���t��_�emY%u4ф`���+��X�UIdx��(�l{�E�^��2�l�}��q)�z��9��qF�d�������n?����Z��G�;�(�WTՋTZh)��Uj-�^�Q
�0`��\�$���yd��w��1��4�zD9|BVȼ�䒏�8���*���	���H�`I��EDԙ*��u�6<ʨ<�3��j�9��`0ϡl��r�5�)��"m��$`1'��"�Z;�]� |������FHL�2٬ښ`�6�5�k<�*XS����.���U�le0����^���mm�����'+�WTVE*,'#p�h*�����H'v6�m��ǾMĽ)`T��ר��ƤO�*�>��EIeE���+�F��`0ނZsM�% �$Ӛ�u����{.ۨ�JRe�6ŧ;�m�;��n[\���I��ֶ%�KzOJsӛ�W`N��
���T+��`0~}\{��w3hWۏ[�Re�Ȣ� �մ�o3}�O��K�\(��J��H6�ƪ�h/צCݔ&�'jG�5�Ts�%��\.Λ�`0?^3������o^�z�I�l=�uٕ��Ǿ��wK��F)��*�5�~�+�<x��-֙5����7p�>�M0���M��x�|,�Q��X*,>WX|VyI�'xM�l�J,1G��7�O�Aq�i�6��b�z:������s ��`�Zx��e��w7�&�Pl��Te'�O�RFx�[o���?u[��s�fy���m������"s^�l�W���c0Ư�SƳ�S���T����a2�������y�^+�p��Ò�q�=�qz2���b/�Ae0Ư�y�OBYK�Q+�R=*��F�cg@�D׹oX?�u9�5|�-�[��]���k��ng<�t:^���0����F�|2 ���k�����ߑ�K�C��B�H�>��y>}���]�/�l��]"�ί�,���`0?+NزXG��E�q�E�¢e~�Үe�+(,��YW���-�.�5-�&�|���.�`��~���eE����.�f*�E>f�Y����F����8d<�K\|%5׬��k�63�kX�^S[��I�G�뫯�Z��m�1<�H�3�7��zRyg�+mYo�w����O�/��������"�`0���t����Z��>x����c����^�.h[V�Y�2�E��/���^3b=�<'�e��i#���l���l3�"�DU�$XL��[2��}��ߦl�优���u��^{�:XpS����E�q�f�6�w̓�����t�1&@\��:�=��@������F=ع�jL�<0�<p.����K�s��yl���1����Tǐ��PZ�Ƀ�eU�`0�
�X,/Y$�X寧0'g�G]KM5��k�_����\���$�|p�,����V;녻��;�I?�����t6>[u��*��7�Ǒ��"M��ַ�R���0Q4h.���� V^ ��c���ž�Gy��R!�]�E�l����8�+��]^��J�n��k��e�}��>T��k��W��5�qb�IV�A�&�N��L�`0??N]����]g��+i�����k��>�>�g��}}۫o�w"h��$ZSM���d�c"v�'ա����k�,4�BRN �v��y�1�}��ʿk�A@*wYF������Mt!u��'��uȃ��{�zGw�41��{6b��$b���Ń�+{�bm���!~��v+���(��m����Yp��9��<Hz����xy䔦ˉ׮���w�\lyݾ�`?ㆦ꺄�b�[L��=��k��B�uiq�2��*e������稄���g0�O��v=�+���A��r��?�vZC��]LYf�6�T�d�1�V�N՚ϕ$�q����Q�6ޫ�m��V���|k|K��<�x�[Ê��`0ߛ�ˁ6�K��|g�,�`0��'���b�7��U���Q̃��h��x3�ĐB�E	8#g�)�U�,k(��`0~��)yp2oH9�('�^/+FI��bX2����	��6T�(#lϫv���� ��0����H�����#�w=5��Ǟ�:�8z�'s��o\y!"t����j '�^?�������ӳf0���<WO� ۧ�}�t}���8���ză���N��d��E׃ qe�R��=�y��jkH����>u�
b���Ζ�`0~�8rP9)�r`��{㿛���A9eAR壙-�[2 �� _����x�z0[R�����e��E0ŧpP�g�`    0����*�5�)kXժ���լv����m���B	ů�b��=�vUg�(�s�]I.٘A�z%ߖ�[g����;_dt��V��A
.���KQq��؀�3��3Ʒ�h�L�7�$����k�Z?�KXEu�6� ����*�w�hy��<�.�Y���C�Y)<Xvoa��U��ZLZL�k�L�&	a� ���G��]����q��7��lZo�������%����,}�0E�JU��*��'��T1��s�`ɥ<�v=HuꕊҊ��������3V	�2�3\a��`0~>�����kM%���:,���"Zc���/.��yd)�j�JY�"�-s����ߟ%.��|��;����F�j�R�}�.p������K�e���e0��Í����./��`ܲ$i�ņ��r�G��z��Jkt�yɶc|w$�v�ro�T~���ԮftB��a<���fMƋ5iKYe6��E��`|ζ�4��w�sP+-z9ԒZG���N�
�X�
0`��4`�"J���2�0�$��}�d(}sĺ�G�(�K��Cy���QB)a�
��P ˃Z4
h@��n#�m�a}0&���v�(�猁�\{��9�[9�!_lǪ��`����Igsٚ��~5��Є���ב|ǿ�lҰ��I��@.�"��0�UUKPIM+���o�6Hi�����QZ�B�B�ʠ�M�cE��3��3�Gpb2�^9Eyպշ��$��&(�Ĩ�FF6DKin
mȠ�(&���+� �VW"hF�"\VO�����*��Q��Ԣ�ؓ�m��~�Y7��`|<n�����.@���.�b,0����{�籶B65� 6k
N.:F��
0�L�T��x!6O��%�I%�d.�8��{�F����Dh�T��dŽ�TrQ�=S_���X`-�ms�иt���}f�|��kk�Q.r�� *S[$�`�%zX���W	kV�5����!_�]K�ܫ�:��vO��Y�׭��� ��`�6L�+A��+���	z]`1xom1.���̮�0J��w�!H����3{4*�Y���Rn��7}:.��/-�l�}�+ՉN%@xU�X��.m��%С�v:��}\�5��s�9�&,>�Zd�mr4]�~�RZ��^������`taiL�GM��'ڵE%XvތƋ�,yPy[��.>�� ���}c��j
Q�� Ub@�6����ʘ����c��6=���C�^��72j��4]	�D�3`�t�Ek�O=o;������.ͻ��hk5 6=�D܌I\��>F�2���.tq]�@�V�+�FͳZ.VW�f)��wig��t_i�W�D6\�6���]2��0b��2\��:�[D��u�$٬d���L�����g��j��|{��@?��⽎ک�=$u�hG�z��¬�.�d���/{�uh�=�3~�cj��,�j��8�X$�+�t�XŻ}~�c���H:&R��4Ki�	���EXx*���"����l�����l���h], �/r�g{둵�w���������r`�f�ԭ�M=N'�!%I��?�П��z�qFK ��!d_�u�z�fy*�`��ٶ8��F�B��C+�X>_l��_d��x��SY�j��Ҳ�薉����GAJ��W�7����R=2`���)re�f/�z�Fi���^�u��`0��Y
��RV�c��[o���0a1i�֓+�8b�#R:AG��%�d.�s/q���تTb�@�ׂ��=q���e�� ru�|�<G��Ǧ��3� R�Aϡ��T��ۍ�L"��H�j�7���3��Y/u_��ffqV�m�Y\������a0_���co�G=��������y�6z�{���������ƀ"#UѾ�Ǒ/���U�Wa�Q�[0��|F򭨫�x0ȥ��Aa�U� �����e�#�:۳g��`��G��q~�Hծ^���=Z����kÛutc�6c���H����r��n��y��`|f<8~NیY�_�_n>�s>��z��*k��#���*6������z`�I*�{D�%�VUA�x��,���{�g=��jųg�j3��V�A[� :����	�ؔ+�t��/pa���t��jN�MY7\�(K�ES�i�,}f0��-_A�Y�=yv�:G���q���>��m��9�Gz�~窭���*���S�P�w�ot�l���E���Lv��Z��;���A��s����g�};��	Z�R�tn�V*Zƶ[�V���V�r����T�)�Q��I�����O>�*!�@>Ɩ���вװh��%]���߷g(��.���J<���Xc��c����U!�u�~v�m8bE���6O��z׼�������Ui�)=7�N�jO>�8*�{���
�%�E�J�z%Xl�:�ՋO%���/=�����Vx`a`CQ
��T�r`Þ������Q*�Z},2�=~��9C>�Ȇ�`�Y���pe���j<2�_��y����p�l���C�S�ٵx4�=.6�B��<�%�
E��z
�� �ƿ�~�Ge���[��h�S'o�-�g�L2U�U�e��(������� ��uW�ڴ�K��6m(�Xţ�V#)��z�cZ�mցq��=)���#��`0>3���e���v�~��=փ]�]:|g?��9׬����]q@i0�B�}w�i�6X+\[�-9�*F�}@�����?�^ĭ�|n-�"�n
��ŏ˴�64V
%�R;����G -K���B��oR����霵�6�JI���Y�X���`�Hllq��eQ=�K��~)6֊��2�#�9[D7up�V�u�]֨:��m��0U���׶��c�$K�a�?�f�Ȧw�s��^�I�>�7 �f�v"����[q5F[TWm�_��(���:P�ps��x��i3�R������;�UX�XB�>��
�x����le0_����8��]Y|��L�ḫ�z�S ���#(���v�;�s��i� "���i�b]͡j^�%m������2�,V(��O-?�^3�G�����;�Q��sx},��b�/���{�F9�n6RC�ݨ6������d��j܇����H{�!��:2-!�ݏw��4��
hC�*�:�����`0��r1��K5�[�o��-;�B�@PɅ"ZnIߘ��z�VQ�[N��O�QfXPv/��r�垙d�f�构m1�i�e�em@�$�L1�N���q��fS�*N����HQ��rG��F�ce�4�vur���Ü�c�C�˭������2���!�0Q�ugC��j��R}��>�k��`0>�>��^1g$�b��^M�X/)�e����^V��Q@W�,<�1��qg�+��,e���,p�!Bp�W
%�,{��ы��qW\�Q�D���nv�m����n�R��(��.ơ��#|f��{����έЩe��򖣍ک��B�74[�-�qOw�q��9�6���I��֯|�o�y��6{W�����Ԟ�q�����,��W�5�hU�W�*T(�����f�zjsU6�bt��K�,�5}����D$�(�Zg@� M�*c�g�q[[�#�8Ѵ�O���3�������7�kZ���Z��i̎њ-�ET�Wn��k�{�WB��~����J}�{������C�I��w�x��K��^�u9xݓ�Hy�0>��c4z���K�5���s4܊v�b�虷�hz�ly��u�$�w�,�f�Z�h��ZՖ���x��?�|�={�W,L_�2*��3`���{d�5R����f�)A���lq�!�8o�`0�W~5�x=SE�Ǹ��Gb���$��s�;4}&V�A[Y�BYC��j�A�j���e�گ��#�%A΂
l��6W�Z\aĉR��g�	e%%�Dm*Ҋ6�|�ț�e��ڳy`e"/�ӕl�}�V㬨�a�Y�>W�vϙ͏ԛ$�2 7������{�宲j���#�q����GI����f�X!Vl�����M��e�u��^��s}A_��gQ�,a���T����Q@�VcrY���0���:�jm3nT��_�-    ���<��cI�%+��6WK1�=��qBct����k3�,�N��=��y��`�,83�e�!$�3�!���u�w�
�� )�C�����R�m7k�����K�����L��2��r���|�t��YG��u�cCLڮ7�	ߎw݂����ߥ{��5^md��8���Ӳ�� ���bz��ң��k}�AS�%�7���`0����~�*���[�_j-�A�>Z��b�l�&l>���,�G%��^��7�ܶ�)ƫ�[���d�1�c��V�VI���������{&�!Wj�ڹ��h�5�o�+����^�n�bC��-8b2X�`E�V��C�#b0^�U�1n�;�U`0��WLt�䵸BUSviW���A���P����A���CL��{�?���kqk�:`p�H�9�Qj�mP~��a��!8Ouo���˴��Z�TZU����4A��{ƀ[���m�(�j׬��>3�,yS�l�9�"c4��XyPY��|��ǳ�`0~8�9DL��Zh�ܡ��ym����@��y�[[PX����+KD� ��.*�G[&����5��`��06����,�m��O0�*��(����^/��c������b�˷V:��Ц��:J1�S��I}�0��GI��6��d}���i|��f|ݦ�}�G���G��u������(�\����qk��@epj���M�)� ���e?�w��vOP�)�=/�jІ�%Չ%$#����U�2RŮ
1���֚+�'�?�W�.-�_g��@���
-��\4UIK��i�lq���J�c��b� Ʒ�e�l~�T�Su��ŵ�u�����Тm�u�T��1���=���Q��PxM���!x�,k���be�#�Hn�F�S��[,�*н����9�����D���Y[��k���b���r��?ק���ѓ�1��8�Q�����(����M�Su�[\����L}K�5�ω�s��zʺ��F�?�Jb�~�˪j|P=�h�`0��Fg�$��e�m���i�E��|'6����
��d���*X�AY�����}g�Y������`�$�����8���0F�n
�$ᅱ:��hW��fuT=f�lX�s�}�U��,�|R�{U�e�'Ш[˯-�޺���g����^k�,��Qd�C���F�O[]�P���ԫ9����~B��06���a����U�S_����U�����6Qd����7��������آ��c����Ҽ�y�*LJ/	��BU��.�-v��VU@E�^kx��F���V�O��ןߚ,���΃T��[���Ճ�h�GD�Z���}�C���R}��y9����Z-<���I?���y鳊���5"s!���
��9��,{4z=e�sm�f��)*BXM�����jk��ǴpН�^܏��5�+M4!(�|�K�u���@�z�(R�=ۼJ�tM�/&���S��b��Լ�l���[����"הP":���2�9|�V_Ɉⵎ��GD8c�emk��.�TJ�=��]΅K�����yA��a0?0�wEt\v��xg��<EK�����*�"GP��<ESI5���8K�s�m�G�)D�J[H+��/.k��8"|�B3D b�L^j�A5��jN}���2x�VU]��/n� �s�,=z�v��<�b�zo\�J�W�l�\���"Y�mf0�/tq�����1����>WHvQ�1��R�fU�4?(�R��)�|��s������U�B��TiB���dAA�uPݏ��pI*.��3>t���<�D�J�j*�h�^�����A�u]օ*L�z�-�-W@p��X�V6�g�}D�M�s	�>O,��`�Ԩ����2-�}&(�ԔS��킀QZ6�K���\�:��ҁ?h��O��5n�r�8��Y�(����+��P�b��*֥R͊h��T�b�z��{��}NS�FS���E`� ��\4z�<h�m<h���΃��P�(0������c��|�D��cO�T�u�Fj̾b{?O��������~2s6���7�ְ�e�T�a�S�9s`�L"�`4՜��	�x���]AZ�A�-�g��os���sbs��@���>1{���+�P�.k���<��Q��\��}l��a��TA'T��L����A�==x��X�j�j��n~21�t�[��1�����z�K(�he��k^�s��z��B��=�d\M05Y/�׫J=�D��E:�����H�7���+Fs�v�dj��t=���b�����!�\�Ư��ˡ����]�{�Y�(jl󟩔oD@�i0׊��|�q!x���a>�vkC��Z�:-,����k��4�>?H���L1�v��ڨJ�%�l�DQ���E/�Kѿ�է�x�fw�,�k�ӆe�8��x1dUe�<X�5�y���Vx�tޙ�6S���;$�U�py��g��\t�f�Xgg�LCf-�,����	*�<��Y4G Ib��7��+k�+,��iv�e~�x����GLhm�m�e�X�����k����g�O�K���1Z�q��C)է��)�����E�9aQ��-g��]6�z��}�0�>���5�9dHc0��[���֘�K����1��P�\-�˕r5�5跼j�"��g��	��"媤d	�x�j��5d�%�[���Y�A�e�Qu��n���R�����>�J��z�����f�iu��O�6�h$昢��Si�Ry�Bx�A�C>�VmNK��8�s�0�_�y��ˢ&i�ʀ>��>z�b~Qi���çGOTj�TR���3U�}E��3�"/	cZ��b��{���m���@!��w� =x�%n1&�T!H��M���)��/U�os��F>'�d��/=�^윎\d�\y�溟���Ǌ60���L��ka�-u�ɶ*��n=e�J�.j�N=��*�jP�T���ޚc.�{.�(4�,��S���v�3T�+J`�v���������7� ؼ��r��Q�c��.�����L�6)S��v��
kS�b���^Qk������7K8�?2��7_�ԭ���+p:��m��5s����3�D�����0Ʒ��}��0��|G2�T��FW!�1��nQ�c��
"�}�?T]7�`�sR5���+� 7Ĉ�bXm�!x���XS�%X�j�]�	8L�-�����Z�oB�*+m*N�쐎"\�2jO��(Ј[�>؞\A��n�V_�2��0�[8~��<�L�;���5�4\02�_�>�zBKvQ�+���!�/��]Բ[i��Ja��ﶬ�ױ�Î�� (o6E���7��$�2v�՟�u���Uњ6_�kR����J�;P7KxE?۲�*ԉ�����j\*�o0&��-��h���@�.o�*o�D\2��v���� 	���3��4`��8iCP�խ�~]� ���l�f���#�A��}$v��X�{Ȧ
��J�Q^%�׭��.����dƆ�^�7c.�����=P��B
��ܷ��ă�M�X
x�DY��IIu�����mjm�5Z�9��^�T�iR�w���:Mb�y����6~��]z���+�/�3�m��h%��V����5�=Hw\Ԯՠ+A(�� ��������==�l�blz�f+#+��y���겷
};b\@��%ѭ���C�U���#����!ʛM���XHX�yT�j�c�q��H�E S����X�Q���ȇvQ�e�,�w-g�Z�*v^�x����r�]��+�s�x�g�=`�30�1^-���w�b�,DvѺ��^>*��`�$�6�w=m���TyG���[��[�_������agW{5��1���8o���%w�S���͵Y�Q�R�a��Z=nn�����<^JT��xM��zd�����5}�t��������:{��MGc�O>��2��s-���g$if8Z..i����c��\�׫�3���\k*�c��0��eα$��Xq@���H��%n��o���T��)�\�� ��1f!f�k�#L����A�\,�E�uط��    ��н��s�rg��yѸ�Uѻң���W��}��u��T�5�G���=S͞�Z�%��&������E�R�E��Fn1��B��2i��u�4��RҪ�WՍb0���7�H�Ud�s�3��]/���Do�:f��v����f=j�!�Y�KX��������S�D[e��	fH�7�-R�/�]�:a�����X�~�ࠝ,� ��^��j�}��뛚>x��|¤n��(�}o�8(PR�����a����q~0�����%p�@-��O�Z( ��˶y�[��z���wT�E��wz~	��r����Է��V=������1x��-���\�r�+����!n�؟��eSH��F������:+��s�9� ��h��}��ji-�_|��G}�r����)��^	Q��L�u�ꮱb�kl�ETu�(��YS9�����p�R��]���&��w��1k�O��2�U�޹e���Ta����S��{�״���y���BX@%%��u)�ь�-W��>�q�ҧz�:o��ȃ]������'u�?*^���m�E�J��a������*{��-N�T���g�w4�"[��/&�kΫ�`0~5�CL=�
�Aת'�C�ɛ]��f(�n�U�T�y$��f�D`�6WH����y!���U����9�����i���):F�c~�����x��š��4زyW]e{�G��u#�Jk�3���2�`v%JQ�E&�]�n�?f����,=e�kGb�(���U0T�%6DǘjA�Cݥ<��e�4Bﻍ����.�\�^��j�g@��9;ߎ|գ�C��>Lk^�S+�� �'v��HLw�%?�`��OVF��F�_���hX�0UX�]��+�6�K�S��IۀJ��j�N7�N���,��W�PqP�7[7�0V%+Kne��`0?7pV
tBQ�-��n�l�3��n|7��lh[�ތ64-t��c�\�zϚҢ��vޚf!�ȍ�F�Q���RK��-��e�i���"�J�m�lٹ��%{\SM�9I�t�Aa���-���30yM���۬�og�s.��]u�Tm�i5���e׀�6'��9����w����l��B�A���}��/��`|=n��
�`.�L)�@%�|T�MK���za��<ꈻ
M�`��cé��X�@��(/��x��N��ᥜ�{}y���H@�Zy�$YCǙ�ùK���(
z��2���5�K����?�~x�����f.M#w�8A%����ى�S＀F�_0^��,ಒ��hA��끪χl��KT�����UV��*�qϬrc��JLj�KoQ�k3aW�#��F��K;�b�J���>�Zzm:5jOK�1�ƀ^p�=��S~������X�WS�-S�b����޹�pT�!�ܪ�n~�ɥ�	�j�-(�2��0Xg0�y���3�c���ώ�S���KI��%��ZV�5�2��=�����ѓ�^9R.�d�����Uy�cV�/�GT��\�b÷�Hc�|p�g�l��@ZT3�Ȳ���u�9��&�^����#�X���Ԛk9d�����ߛB����C��v[n7�a�c�߯k��2�h���ј��τ�Z~����	�c��%�=]J�C��=~0���<���أ��{�m�A��XzȸV��u)���՟0��
�t���揱��|�瘋����mE�b�&C��͓��%42.��&�kO�\?�Z��~u�f���J�[���y�O�$��pc�G�R/�g��InFF�{7�]@ޡM}Ko�J�'�0��Bҝ��ƌ���S���m[t~�Ke0���X�'��h�J��?eIg��
2���g��;X�*UH��3�1�w3��=�z˯�=.��5S"�Y2�״]Z�۞g��b��S�6�u�}.�"˯>[w��ͣr�R����{�����h.��1�-c�^U�6�yi= �it�/βɝ[|_�cx�u6)��3���2����������[^�u��e
w� �Nѫ��SY��}D�Kʽ�k9΂�`|>�G�����PK����q�����s힓�:g�KH�����Z�Ǹ�q~p�c~�D����Z��1��Zt���6{4z��m��׶��zͦc���W`\w{][��\|˲�v+"���!�:�,+[὿�M���uL��Rm�6C�����\���Q��l��bLD(-3����)7�o�]�]��[��[���Et<�a����F>f��;�`h��x��\����3p���֌V����ר\���B1�AA'+��!U(���St��w~L��Ɖ�����U�yZ.[����������%�l�v��#����Q��EQ�L��#Z9	��Z{�y�5T��
�]��2�d��T��r���L����j-�<x�c_τ�5DE0�
��ib�t��a:�߷y̕�=�<	�E�JI`��bc�Y��u>-֤Z}�C4�Y���۲1��q�o�V�ͺu��>�������|굙�,ܷ�1�Ȇq�Æ�CcC�P��]w�8TmPV9QB	5hh�_Ǹ��y�Ĝy>e�&/���4���������J��j��Z{ *��),X��t�J���W8д�ʋ�9#�y?�� \=�4���:M�����4�jy~��"j���q�G��T\�u]��ê��N:�չEJ�<���G,U��J���)�k�:c@�>��cp�Ym�=�����猙��zRc�I�Sp�g;�"��#q�e��7�*�S%_ٵ�i~�[�&R�
=!A�9�l��`�82��v/[Lo��gP��5J��=a�S�|\�[�#��:ѡ.�j��[e�j-���ʿ9䘗i���4lfZ8#Ŷl��B�Q%�Pbmg����s���G�c��1W6�i��R���zm�<j֛�`�Ynӏ��v�D�I�а�K�&̉�+��������ѱ_:�d��^o�����<KUW���<Ko�mo�,��4�WW������� ŭ�!� �{���a	�9��5�Yš�O\��)�c�{z�4��T�(to��������[L6ٴE�c,a계�;��cY�[k@��װ���S�E�:z��P;X�X��ʖ�
�/s�nY��k�Q0>5����8�8���k�[�j��Cs��p���E�X*&�����D���\�������xn6�nۆZr�d+k3Mw��j4��-�}�����7�Aq�R��Y���j���W$j%SL
��D,x+z�ڟ�+��,7ȃX���WݣΏ�l[n�-�Vb��9�mщ�l�j��2�袶�q��BKE+2(0����nq�=�c���Eie���Y����c�q�EFl�¸�`����~ogc���K��%�
�R�	��o�6Ѹ�@T���0��`|GF�Dv斢��%�m!z�9/��z��R&	O�� +p&��C�
�2H��v-eK3	�jb� Ti~m�3S\�P�l�}[e�,��#�����:DǬ�A��@�jh�Ev%��(Y+1��bfq�	�e�)�yu��)�|ӿ�0=G�pYZ]�������~T�d�m��/�_s8.���;���u.���z�8��^�}����(
��r?N`0��{Kj��r�U�x�{���Ͳ�"�e��*n�R�bk"����W$rbi*��K��?�Q��D�L�n�[RH M��.�S�}���z����R�Y�i���i9r�sg5�bS�N�ao�j�gg�����XZ���*li{Vҍ�)�im�X!B�� �W��8B�u_�J0u�[|G��O�l�
}Zt��g'r���L���{����x_S��k	�䔗�ׁ��%FgÖfS}�j�`0����ۻۧH�֢��6��ч��r�U��	�A!�(M����奱��g�%��U��kl��J9^������I�F�C��8Y-���2����:�ַ�D�F��U����8���Ю�����Q��7�l�9������Xo�os��x�z�[��1^c�sG�y�`��(�c�ѣ�U��V���t�m��<-8QG_e6÷� �
  ���`|O����6�B�L:E�/�&���a>q�����D�(jP�*g��S���(r���<8(�ƕ��1�Y#����D����R��*��f)��[ƥ�)#uR�Ub�z��D���Ew��bu����U�*u@p\��]���1&���*Je̍�@w�K����~9�o�1�~�()��$ں�L��;��������yd6d0?	���y6���\|%/zi3(�[������V��� �
3�*d�UY�Hj�j���(�t�b���B��wz����7��4�$�I£�}Q�0wS�7=���6�⌤�G҃}��7���l�T������R�cm�/WG�bT����� ����(����&/?��:r��窵'e3�Y�5u�o]�!tNd0��{;�U����bv���V��6����w�\�n�]����_M 򀏬��iQe)�eѡq��Ln���2Y��R6�j���<6:�
<h@�Pݥz<�`�m�%	�������Ֆ;Nv�Z�*����|���5� �f!�A��3U��|���Dl�\�Q~�����ݧύ]���n����,�kJZu�ڷ���f���dU�5!����8���rZ3+��e��U�W?�H����9�d;���Y)'�^a�&tX�C�t�	9d�ø�����Vk��ĚP�eE�l�s�L޼zʝJ�y�� ҅ Z��U;�}Ԙ�ł�pD�yn�e�DW��Ř�{�jR�����;[�r�� ������q��p�$����	vY��7�Y�!j��ޟ�h�5Ve􂑆b���=�W�=f�<Fa��^C�X)�k�呎!-RX����jɡ�t�FS�D�`�<��95��;7�R���|:{��nq%��[��g�Wf�?�j�����]��A��u��l�m3��}66����pׯ����Q�T�b���K{6�Y.����>V�=*Ǻ��*�i6U��@\9�&��?�&�����w[����{_������}:T��%v��ьu�o����^W���`0�y�RW]}
��f��Y�r�ux�y�Oq�#�x��gvf9VK��s��FE�f5Z9�pSp��+���|h:�W��h�5�:a��B��VST`�GÂ�������5e[~X���`0��3������u��*1�vr�!y��8���_��i4�Ƥq�3v�5�Wn��O5�_w�����w�p����+YP\IK/�TU�+���t��B�.˚��+Bz�U㣬K���OU�����`0�)n�?G&��j.з{�=��όB����ZT=?Xj[D���F�x��ar��y_�v��:x���ۚtǆ�sv������w���-�~�T��Z��g�yp}�z]��`0?�:��h�x�y(mف*�+a,�)*�RW"i�2G�[�ƌX+��j�)ΐN<�~��j��
�@�^1�h��*;ܴg:�|�~��e#��~h�ƌ�"R���ˌz�>��9��u��`0��lx�apVK����/Z�{��RN�2,sd��5y�j�3G6C��,K��t�x�Ƽ�ɾ�ͳ}5����Zc�w ���?j�{��0ߧ\�~Ѱ���W_4�f�k���UE�zM.C��8�qŉee�K�������/�pm+�R��QE�Wkr�E��}���`�_�u
,֜7	3K7FS';䖵�6+盖\(��pt�}�%U��fJ]S���"�,f�������v���PԺTqw%�wX�6��e�6��b uH�G���9*�\K�7��`0?O䜤?sj�K\��zv뺞��ۿ��γ��]�QB2�V)x�;�]��3���Ε���-���l�O낾��d�C��Q,X����m��1�K�b�m��tȏ=Ӏ���`0�gur��Q[eI󀇼�#�����^���P�`]N�`�f�K�6&_]�������h���Ol�볝C�U�H�j���,>�\S��`0�gf٪��rA߸��#���3ۜ���ɮX�\e)�X���z�ݴ��}�L�o_�\Mwk�%C��G�*CrN�������`|_ܬ�u�@n�����GUxT��:��,�X=p�[q�_�Ѭ�1�X�)��vAae"��c0�_7�#}t��:j�G�kX\G�]��֗'3���~ކQ��*6��^[V��������IfW��`|o���kj��8�N��zZ3��}� u��ԏ���歳NgB���C��^�j����`0�����Ǻid�c�����z���y��ގr����oS�GK�s���$�X��Я�����Qx��f�/�Y�X�5>�����تo��}��jz��؂|�諭�����gr�+ϙ�~f>��wg�:;���5~(�LhW57+�<��`0��`0��`0��`0��`0��`0��`0���������?����������T)�O���"����������!�?��������������:���"�o�����������������&'��Mh'���i�r��������I,�����w�����_����7�������������O����������_���������ÿ�G�?������f����o���������o�������K������_��x���o�׾����R�[���?��_��_���20�      9      x�3�q���L�2��%\1z\\\ 4�=      �   :   x�3�472�500����q�R8�����G6��pdޑ�Fz`�i�i����� ��      �   (   x�3�4���t�34��3 .#����L8F��� �'�      �   &   x�3�N�(HT���+I�R�LI�I,:��+F��� ��	�      �      x������ � �      �      x������ � �      �   ?   x�34�����t�34�4�3 N(��М�$�����7AW`Q 2���ӄ=... �~�      �      x�3��472�500�4�35 �=... 9"      �      x������ � �      �      x������ � �      H      x������ � �      �   ^   x���q�	64��v��Sqt�qU04V�u;���P� 8c��,9�<����}B9��l ��]=�|��C�\#�P���qqq S=�     