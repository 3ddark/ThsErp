PGDMP                        {            ths_erp    16.1    16.1 �   +           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            ,           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            -           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            .           1262    34409    ths_erp    DATABASE     {   CREATE DATABASE ths_erp WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Turkish_Turkey.1254';
    DROP DATABASE ths_erp;
             	   ths_admin    false            
            2615    2200    public    SCHEMA     2   -- *not* creating schema, since initdb creates it
 2   -- *not* dropping schema, since initdb creates it
                postgres    false            /           0    0    SCHEMA public    ACL     }   REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT CREATE ON SCHEMA public TO PUBLIC;
GRANT ALL ON SCHEMA public TO ths_admin;
                   postgres    false    10                        3079    34410    dblink 	   EXTENSION     :   CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;
    DROP EXTENSION dblink;
                   false    10            0           0    0    EXTENSION dblink    COMMENT     _   COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';
                        false    2                        3079    34456    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                   false    10            1           0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                        false    3                        3079    34493 
   pgrowlocks 	   EXTENSION     >   CREATE EXTENSION IF NOT EXISTS pgrowlocks WITH SCHEMA public;
    DROP EXTENSION pgrowlocks;
                   false    10            2           0    0    EXTENSION pgrowlocks    COMMENT     I   COMMENT ON EXTENSION pgrowlocks IS 'show row-level locking information';
                        false    4                        3079    34495    pldbgapi 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pldbgapi WITH SCHEMA public;
    DROP EXTENSION pldbgapi;
                   false    10            3           0    0    EXTENSION pldbgapi    COMMENT     Y   COMMENT ON EXTENSION pldbgapi IS 'server-side support for debugging PL/pgSQL functions';
                        false    5                        3079    34532    postgres_fdw 	   EXTENSION     @   CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;
    DROP EXTENSION postgres_fdw;
                   false    10            4           0    0    EXTENSION postgres_fdw    COMMENT     [   COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';
                        false    6            5           0    0    FUNCTION armor(bytea)    ACL     8   GRANT ALL ON FUNCTION public.armor(bytea) TO ths_admin;
          public          postgres    false    428            6           0    0 %   FUNCTION armor(bytea, text[], text[])    ACL     H   GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO ths_admin;
          public          postgres    false    418            �           1255    34539    audit()    FUNCTION       CREATE FUNCTION public.audit() RETURNS trigger
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
       public       	   ths_admin    false    10            7           0    0    FUNCTION audit()    ACL     i   REVOKE ALL ON FUNCTION public.audit() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.audit() FROM ths_admin;
          public       	   ths_admin    false    505            8           0    0    FUNCTION crypt(text, text)    ACL     =   GRANT ALL ON FUNCTION public.crypt(text, text) TO ths_admin;
          public          postgres    false    394            9           0    0    FUNCTION dearmor(text)    ACL     9   GRANT ALL ON FUNCTION public.dearmor(text) TO ths_admin;
          public          postgres    false    460            :           0    0 $   FUNCTION decrypt(bytea, bytea, text)    ACL     G   GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO ths_admin;
          public          postgres    false    446            ;           0    0 .   FUNCTION decrypt_iv(bytea, bytea, bytea, text)    ACL     Q   GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO ths_admin;
          public          postgres    false    473            <           0    0    FUNCTION digest(bytea, text)    ACL     ?   GRANT ALL ON FUNCTION public.digest(bytea, text) TO ths_admin;
          public          postgres    false    522            =           0    0    FUNCTION digest(text, text)    ACL     >   GRANT ALL ON FUNCTION public.digest(text, text) TO ths_admin;
          public          postgres    false    400            >           0    0 $   FUNCTION encrypt(bytea, bytea, text)    ACL     G   GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO ths_admin;
          public          postgres    false    523            ?           0    0 .   FUNCTION encrypt_iv(bytea, bytea, bytea, text)    ACL     Q   GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO ths_admin;
          public          postgres    false    501            @           0    0 "   FUNCTION gen_random_bytes(integer)    ACL     E   GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO ths_admin;
          public          postgres    false    467            A           0    0    FUNCTION gen_random_uuid()    ACL     =   GRANT ALL ON FUNCTION public.gen_random_uuid() TO ths_admin;
          public          postgres    false    412            B           0    0    FUNCTION gen_salt(text)    ACL     :   GRANT ALL ON FUNCTION public.gen_salt(text) TO ths_admin;
          public          postgres    false    482            C           0    0     FUNCTION gen_salt(text, integer)    ACL     C   GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO ths_admin;
          public          postgres    false    398            D           0    0 !   FUNCTION hmac(bytea, bytea, text)    ACL     D   GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO ths_admin;
          public          postgres    false    401            E           0    0    FUNCTION hmac(text, text, text)    ACL     B   GRANT ALL ON FUNCTION public.hmac(text, text, text) TO ths_admin;
          public          postgres    false    437            �           1255    34540    personel_adsoyad()    FUNCTION     ]  CREATE FUNCTION public.personel_adsoyad() RETURNS trigger
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
       public       	   ths_admin    false    10            F           0    0    FUNCTION personel_adsoyad()    ACL        REVOKE ALL ON FUNCTION public.personel_adsoyad() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.personel_adsoyad() FROM ths_admin;
          public       	   ths_admin    false    458            G           0    0 >   FUNCTION pgp_armor_headers(text, OUT key text, OUT value text)    ACL     a   GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO ths_admin;
          public          postgres    false    530            H           0    0    FUNCTION pgp_key_id(bytea)    ACL     =   GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO ths_admin;
          public          postgres    false    526            I           0    0 &   FUNCTION pgp_pub_decrypt(bytea, bytea)    ACL     I   GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO ths_admin;
          public          postgres    false    432            J           0    0 ,   FUNCTION pgp_pub_decrypt(bytea, bytea, text)    ACL     O   GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO ths_admin;
          public          postgres    false    481            K           0    0 2   FUNCTION pgp_pub_decrypt(bytea, bytea, text, text)    ACL     U   GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO ths_admin;
          public          postgres    false    488            L           0    0 ,   FUNCTION pgp_pub_decrypt_bytea(bytea, bytea)    ACL     O   GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO ths_admin;
          public          postgres    false    464            M           0    0 2   FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text)    ACL     U   GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO ths_admin;
          public          postgres    false    444            N           0    0 8   FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text)    ACL     [   GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO ths_admin;
          public          postgres    false    495            O           0    0 %   FUNCTION pgp_pub_encrypt(text, bytea)    ACL     H   GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO ths_admin;
          public          postgres    false    512            P           0    0 +   FUNCTION pgp_pub_encrypt(text, bytea, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO ths_admin;
          public          postgres    false    527            Q           0    0 ,   FUNCTION pgp_pub_encrypt_bytea(bytea, bytea)    ACL     O   GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO ths_admin;
          public          postgres    false    494            R           0    0 2   FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text)    ACL     U   GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO ths_admin;
          public          postgres    false    416            S           0    0 %   FUNCTION pgp_sym_decrypt(bytea, text)    ACL     H   GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO ths_admin;
          public          postgres    false    507            T           0    0 +   FUNCTION pgp_sym_decrypt(bytea, text, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO ths_admin;
          public          postgres    false    457            U           0    0 +   FUNCTION pgp_sym_decrypt_bytea(bytea, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO ths_admin;
          public          postgres    false    436            V           0    0 1   FUNCTION pgp_sym_decrypt_bytea(bytea, text, text)    ACL     T   GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO ths_admin;
          public          postgres    false    513            W           0    0 $   FUNCTION pgp_sym_encrypt(text, text)    ACL     G   GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO ths_admin;
          public          postgres    false    454            X           0    0 *   FUNCTION pgp_sym_encrypt(text, text, text)    ACL     M   GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO ths_admin;
          public          postgres    false    466            Y           0    0 +   FUNCTION pgp_sym_encrypt_bytea(bytea, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO ths_admin;
          public          postgres    false    419            Z           0    0 1   FUNCTION pgp_sym_encrypt_bytea(bytea, text, text)    ACL     T   GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO ths_admin;
          public          postgres    false    476            [           0    0 �   FUNCTION pgrowlocks(relname text, OUT locked_row tid, OUT locker xid, OUT multi boolean, OUT xids xid[], OUT modes text[], OUT pids integer[])    ACL     �   GRANT ALL ON FUNCTION public.pgrowlocks(relname text, OUT locked_row tid, OUT locker xid, OUT multi boolean, OUT xids xid[], OUT modes text[], OUT pids integer[]) TO ths_admin;
          public          postgres    false    524            \           0    0    FUNCTION postgres_fdw_handler()    ACL     B   GRANT ALL ON FUNCTION public.postgres_fdw_handler() TO ths_admin;
          public          postgres    false    426            ]           0    0 ,   FUNCTION postgres_fdw_validator(text[], oid)    ACL     O   GRANT ALL ON FUNCTION public.postgres_fdw_validator(text[], oid) TO ths_admin;
          public          postgres    false    469            �           1255    34541    spexists_hesap_kodu(text)    FUNCTION     0  CREATE FUNCTION public.spexists_hesap_kodu(phesap_kodu text) RETURNS boolean
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
       public          postgres    false    10            ^           0    0 .   FUNCTION spexists_hesap_kodu(phesap_kodu text)    ACL     �   REVOKE ALL ON FUNCTION public.spexists_hesap_kodu(phesap_kodu text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spexists_hesap_kodu(phesap_kodu text) TO ths_admin;
          public          postgres    false    396            �           1255    34542    spget_crypted_data(text)    FUNCTION     �   CREATE FUNCTION public.spget_crypted_data(pval text) RETURNS text
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
       public          postgres    false    10            _           0    0 &   FUNCTION spget_crypted_data(pval text)    ACL     I   GRANT ALL ON FUNCTION public.spget_crypted_data(pval text) TO ths_admin;
          public          postgres    false    399                       1255    34543 /   spget_lang_text(text, text, text, bigint, text)    FUNCTION     �  CREATE FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) RETURNS character varying
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
       public          postgres    false    10            `           0    0 n   FUNCTION spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text)    ACL     "  REVOKE ALL ON FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) TO ths_admin;
          public          postgres    false    514            �           1255    34544 -   spget_lang_text(text, text, text, text, text)    FUNCTION     �  CREATE FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) RETURNS character varying
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
       public          postgres    false    10            a           0    0 n   FUNCTION spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text)    ACL     "  REVOKE ALL ON FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) TO ths_admin;
          public          postgres    false    450                       1255    34545    spget_prs_personel_id_list()    FUNCTION     j  CREATE FUNCTION public.spget_prs_personel_id_list() RETURNS TABLE(id integer, emp_name character varying, emp_surname character varying, emp_full_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
		SELECT  prs_personel.id, prs_personel.ad, prs_personel.soyad, prs_personel.ad_soyad FROM prs_personel
		WHERE is_aktif ORDER BY 4;
END
$$;
 3   DROP FUNCTION public.spget_prs_personel_id_list();
       public          postgres    false    10            b           0    0 %   FUNCTION spget_prs_personel_id_list()    ACL     �   REVOKE ALL ON FUNCTION public.spget_prs_personel_id_list() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_prs_personel_id_list() TO ths_admin;
          public          postgres    false    529            �           1255    34546 "   spget_rct_hammadde_maliyet(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) RETURNS numeric
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
       public          postgres    false    10            c           0    0 :   FUNCTION spget_rct_hammadde_maliyet(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    445                       1255    34547 !   spget_rct_iscilik_maliyet(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) RETURNS numeric
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
       public          postgres    false    10            d           0    0 9   FUNCTION spget_rct_iscilik_maliyet(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    516            �           1255    34548    spget_rct_toplam(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_toplam(prct_recete_id bigint) RETURNS numeric
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
       public          postgres    false    10            e           0    0 0   FUNCTION spget_rct_toplam(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_toplam(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_toplam(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    491            �           1255    34549 "   spget_rct_yan_urun_maliyet(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) RETURNS numeric
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
       public          postgres    false    10            f           0    0 :   FUNCTION spget_rct_yan_urun_maliyet(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    449            �           1255    34550 &   spget_sys_kalite_form_no(text, bigint)    FUNCTION     I  CREATE FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) RETURNS character varying
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
       public          postgres    false    10            g           0    0 H   FUNCTION spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) TO ths_admin;
          public          postgres    false    417                       1255    34551    spget_sys_lang_id(text)    FUNCTION     �   CREATE FUNCTION public.spget_sys_lang_id(planguage text) RETURNS integer
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
       public          postgres    false    10            h           0    0 *   FUNCTION spget_sys_lang_id(planguage text)    ACL     �   REVOKE ALL ON FUNCTION public.spget_sys_lang_id(planguage text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_sys_lang_id(planguage text) TO ths_admin;
          public          postgres    false    528            �           1255    34552 '   spget_sys_quality_form_type_id(integer)    FUNCTION     �  CREATE FUNCTION public.spget_sys_quality_form_type_id(ptype integer) RETURNS integer
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
       public          postgres    false    10            i           0    0 6   FUNCTION spget_sys_quality_form_type_id(ptype integer)    ACL     Y   GRANT ALL ON FUNCTION public.spget_sys_quality_form_type_id(ptype integer) TO ths_admin;
          public          postgres    false    459            �           1255    34553    spget_sys_user_id_list()    FUNCTION       CREATE FUNCTION public.spget_sys_user_id_list() RETURNS TABLE(id bigint, user_name character varying)
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
       public       	   ths_admin    false    10            j           0    0 !   FUNCTION spget_sys_user_id_list()    ACL     D   REVOKE ALL ON FUNCTION public.spget_sys_user_id_list() FROM PUBLIC;
          public       	   ths_admin    false    489            �           1255    34554 1   spget_year_week(date, character varying, boolean)    FUNCTION     �  CREATE FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean DEFAULT true) RETURNS character varying
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
       public          postgres    false    10            k           0    0 Y   FUNCTION spget_year_week(pdate date, pseparate character varying, pis_year_first boolean)    ACL     �   REVOKE ALL ON FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean) TO ths_admin;
          public          postgres    false    456            �           1255    34555    splogin(text, text, text, text)    FUNCTION     �  CREATE FUNCTION public.splogin(puser_name text, puser_pass text, papp_version text, pmac_address text) RETURNS integer
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
       public       	   ths_admin    false    10            �           1255    34556 (   spset_user_password(text, text, integer)    FUNCTION       CREATE FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) RETURNS boolean
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
       public          postgres    false    10            l           0    0 H   FUNCTION spset_user_password(oldpass text, newpass text, userid integer)    ACL     �   REVOKE ALL ON FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) TO ths_admin;
          public          postgres    false    453            �           1255    34557    spvarsayilan_para_birimi()    FUNCTION     �   CREATE FUNCTION public.spvarsayilan_para_birimi() RETURNS character varying
    LANGUAGE sql
    AS $$
	SELECT para_birimi FROM sys_para_birimi WHERE is_varsayilan LIMIT 1;
$$;
 1   DROP FUNCTION public.spvarsayilan_para_birimi();
       public          postgres    false    10            m           0    0 #   FUNCTION spvarsayilan_para_birimi()    ACL     �   REVOKE ALL ON FUNCTION public.spvarsayilan_para_birimi() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spvarsayilan_para_birimi() TO ths_admin;
          public          postgres    false    405                       1255    34558    spvarsayilan_urun_tipi_id()    FUNCTION     �   CREATE FUNCTION public.spvarsayilan_urun_tipi_id() RETURNS integer
    LANGUAGE sql
    AS $$
	SELECT id FROM set_stk_urun_tipi WHERE urun_tipi='HAMMADDE';
$$;
 2   DROP FUNCTION public.spvarsayilan_urun_tipi_id();
       public          postgres    false    10            n           0    0 $   FUNCTION spvarsayilan_urun_tipi_id()    ACL     �   REVOKE ALL ON FUNCTION public.spvarsayilan_urun_tipi_id() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spvarsayilan_urun_tipi_id() TO ths_admin;
          public          postgres    false    517                       1255    34559    table_listen(text)    FUNCTION     �   CREATE FUNCTION public.table_listen(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT listen table_name;
  RETURN;
END;
$$;
 4   DROP FUNCTION public.table_listen(table_name text);
       public          postgres    false    10            o           0    0 &   FUNCTION table_listen(table_name text)    ACL     �   REVOKE ALL ON FUNCTION public.table_listen(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_listen(table_name text) TO ths_admin;
          public          postgres    false    519            �           1255    34560    table_notify()    FUNCTION     �  CREATE FUNCTION public.table_notify() RETURNS trigger
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
       public       	   ths_admin    false    10            p           0    0    FUNCTION table_notify()    ACL     w   REVOKE ALL ON FUNCTION public.table_notify() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.table_notify() FROM ths_admin;
          public       	   ths_admin    false    395            �           1255    34561    table_notify(text)    FUNCTION     �   CREATE FUNCTION public.table_notify(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT notify table_name;
  RETURN;
END;
$$;
 4   DROP FUNCTION public.table_notify(table_name text);
       public          postgres    false    10            q           0    0 &   FUNCTION table_notify(table_name text)    ACL     �   REVOKE ALL ON FUNCTION public.table_notify(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_notify(table_name text) TO ths_admin;
          public          postgres    false    433            �           1255    34562    table_unlisten(text)    FUNCTION     �   CREATE FUNCTION public.table_unlisten(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT unlisten table_name;
  RETURN;
END;
$$;
 6   DROP FUNCTION public.table_unlisten(table_name text);
       public          postgres    false    10            r           0    0 (   FUNCTION table_unlisten(table_name text)    ACL     �   REVOKE ALL ON FUNCTION public.table_unlisten(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_unlisten(table_name text) TO ths_admin;
          public          postgres    false    499            �            1259    34563    a_invoices_id_seq    SEQUENCE     z   CREATE SEQUENCE public.a_invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.a_invoices_id_seq;
       public          postgres    false    10            �            1259    34564    als_teklif_detaylari    TABLE     �  CREATE TABLE public.als_teklif_detaylari (
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
       public         heap 	   ths_admin    false    10            �            1259    34580    als_teklif_detaylari_id_seq    SEQUENCE     �   ALTER TABLE public.als_teklif_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.als_teklif_detaylari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    227    10            �            1259    34581    als_teklifler    TABLE     �  CREATE TABLE public.als_teklifler (
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
       public         heap 	   ths_admin    false    10            �            1259    34602    als_teklifler_id_seq    SEQUENCE     �   ALTER TABLE public.als_teklifler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.als_teklifler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    229            �            1259    34603    audits    TABLE     �  CREATE TABLE public.audits (
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
       public         heap 	   ths_admin    false    10            �            1259    34608    audit_id_seq    SEQUENCE     �   ALTER TABLE public.audits ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    231            �            1259    34609    ch_bankalar    TABLE     �   CREATE TABLE public.ch_bankalar (
    id bigint NOT NULL,
    banka_adi character varying(64) NOT NULL,
    swift_kodu character varying(16)
);
    DROP TABLE public.ch_bankalar;
       public         heap 	   ths_admin    false    10            �            1259    34612    ch_banka_id_seq    SEQUENCE     �   ALTER TABLE public.ch_bankalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_banka_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    233            �            1259    34613    ch_banka_subeleri    TABLE     �   CREATE TABLE public.ch_banka_subeleri (
    id bigint NOT NULL,
    banka_id bigint NOT NULL,
    sube_kodu integer NOT NULL,
    sube_adi character varying(64) NOT NULL,
    sehir_id bigint NOT NULL
);
 %   DROP TABLE public.ch_banka_subeleri;
       public         heap 	   ths_admin    false    10            �            1259    34616    ch_banka_subesi_id_seq    SEQUENCE     �   ALTER TABLE public.ch_banka_subeleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_banka_subesi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    235            �            1259    34617    ch_bolgeler    TABLE     f   CREATE TABLE public.ch_bolgeler (
    id bigint NOT NULL,
    bolge character varying(32) NOT NULL
);
    DROP TABLE public.ch_bolgeler;
       public         heap 	   ths_admin    false    10            �            1259    34620    ch_bolge_id_seq    SEQUENCE     �   ALTER TABLE public.ch_bolgeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_bolge_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    237    10            �            1259    34621    ch_doviz_kurlari    TABLE     �   CREATE TABLE public.ch_doviz_kurlari (
    id bigint NOT NULL,
    kur_tarihi date NOT NULL,
    kur numeric(10,4) NOT NULL,
    para character varying(3)
);
 $   DROP TABLE public.ch_doviz_kurlari;
       public         heap 	   ths_admin    false    10            �            1259    34624 
   ch_gruplar    TABLE     d   CREATE TABLE public.ch_gruplar (
    id bigint NOT NULL,
    grup character varying(16) NOT NULL
);
    DROP TABLE public.ch_gruplar;
       public         heap 	   ths_admin    false    10            �            1259    34627    ch_hesaplar    TABLE     �  CREATE TABLE public.ch_hesaplar (
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
       public         heap 	   ths_admin    false    10            �            1259    34635    ch_hesap_karti_id_seq    SEQUENCE     �   ALTER TABLE public.ch_hesaplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_hesap_karti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    241            �            1259    34636    ch_hesap_planlari    TABLE     �   CREATE TABLE public.ch_hesap_planlari (
    id bigint NOT NULL,
    plan_kodu character varying(16) NOT NULL,
    plan_adi character varying(128) NOT NULL,
    seviye smallint NOT NULL
);
 %   DROP TABLE public.ch_hesap_planlari;
       public         heap 	   ths_admin    false    10            �            1259    34639    mhs_doviz_kuru_id_seq    SEQUENCE     �   ALTER TABLE public.ch_doviz_kurlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_doviz_kuru_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    239    10            �            1259    34640    mhs_fis_detaylari    TABLE     a   CREATE TABLE public.mhs_fis_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL
);
 %   DROP TABLE public.mhs_fis_detaylari;
       public         heap 	   ths_admin    false    10            �            1259    34643    mhs_fis_detaylari_id_seq    SEQUENCE     �   ALTER TABLE public.mhs_fis_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_fis_detaylari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    245    10            �            1259    34644 
   mhs_fisler    TABLE     u   CREATE TABLE public.mhs_fisler (
    id bigint NOT NULL,
    yevmiye_no integer NOT NULL,
    yevmiye_tarihi date
);
    DROP TABLE public.mhs_fisler;
       public         heap 	   ths_admin    false    10            �            1259    34647    mhs_fisler_id_seq    SEQUENCE     �   ALTER TABLE public.mhs_fisler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_fisler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    247            �            1259    34648    mhs_transfer_kodlari    TABLE     �   CREATE TABLE public.mhs_transfer_kodlari (
    id bigint NOT NULL,
    transfer_kodu character varying(32) NOT NULL,
    aciklama character varying(128) NOT NULL,
    hesap_kodu character varying(16) NOT NULL
);
 (   DROP TABLE public.mhs_transfer_kodlari;
       public         heap 	   ths_admin    false    10            �            1259    34651    mhs_transfer_kodlari_id_seq    SEQUENCE     �   ALTER TABLE public.mhs_transfer_kodlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_transfer_kodlari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    249    10            �            1259    34652    prs_ehliyetler    TABLE     n   CREATE TABLE public.prs_ehliyetler (
    id bigint NOT NULL,
    ehliyet_id bigint,
    personel_id bigint
);
 "   DROP TABLE public.prs_ehliyetler;
       public         heap 	   ths_admin    false    10            �            1259    34655    prs_lisan_bilgileri    TABLE     �   CREATE TABLE public.prs_lisan_bilgileri (
    id bigint NOT NULL,
    lisan_id bigint,
    okuma_id bigint,
    yazma_id bigint,
    konusma_id bigint,
    personel_id bigint
);
 '   DROP TABLE public.prs_lisan_bilgileri;
       public         heap 	   ths_admin    false    10            �            1259    34658    prs_lisan_bilgisi_id_seq    SEQUENCE     �   ALTER TABLE public.prs_lisan_bilgileri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_lisan_bilgisi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    252            �            1259    34659    prs_personel_ehliyetleri_id_seq    SEQUENCE     �   ALTER TABLE public.prs_ehliyetler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_personel_ehliyetleri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    251            �            1259    34660    prs_personeller    TABLE     �  CREATE TABLE public.prs_personeller (
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
       public         heap 	   ths_admin    false    10            s           0    0    COLUMN prs_personeller.cinsiyet    COMMENT     F   COMMENT ON COLUMN public.prs_personeller.cinsiyet IS '1 Man
2 Woman';
          public       	   ths_admin    false    255            t           0    0 &   COLUMN prs_personeller.askerlik_durumu    COMMENT     e   COMMENT ON COLUMN public.prs_personeller.askerlik_durumu IS '1 Yapti, 2 Yapmadi, 3 Tecilli, 4 Muaf';
          public       	   ths_admin    false    255            u           0    0 #   COLUMN prs_personeller.medeni_durum    COMMENT     L   COMMENT ON COLUMN public.prs_personeller.medeni_durum IS '1 Evli, 2 Bekar';
          public       	   ths_admin    false    255                        1259    34670    prs_personel_id_seq    SEQUENCE     �   ALTER TABLE public.prs_personeller ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_personel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    255                       1259    34671    urt_iscilikler    TABLE     �   CREATE TABLE public.urt_iscilikler (
    id bigint NOT NULL,
    gider_kodu character varying(16) NOT NULL,
    gider_adi character varying(128),
    fiyat numeric(18,6) NOT NULL,
    birim_id bigint NOT NULL,
    gider_tipi smallint NOT NULL
);
 "   DROP TABLE public.urt_iscilikler;
       public         heap 	   ths_admin    false    10                       1259    34674    rct_iscilik_gideri_id_seq    SEQUENCE     �   ALTER TABLE public.urt_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_iscilik_gideri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    257    10                       1259    34675    urt_paket_hammadde_detaylari    TABLE     �   CREATE TABLE public.urt_paket_hammadde_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    recete_id bigint,
    stok_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 0   DROP TABLE public.urt_paket_hammadde_detaylari;
       public         heap 	   ths_admin    false    10                       1259    34678    rct_paket_hammadde_detay_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_hammadde_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_hammadde_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    259                       1259    34679    urt_paket_hammaddeler    TABLE     u   CREATE TABLE public.urt_paket_hammaddeler (
    id bigint NOT NULL,
    paket_adi character varying(128) NOT NULL
);
 )   DROP TABLE public.urt_paket_hammaddeler;
       public         heap 	   ths_admin    false    10                       1259    34682    rct_paket_hammadde_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    261                       1259    34683    urt_paket_iscilik_detaylari    TABLE     �   CREATE TABLE public.urt_paket_iscilik_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    iscilik_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 /   DROP TABLE public.urt_paket_iscilik_detaylari;
       public         heap 	   ths_admin    false    10                       1259    34686    rct_paket_iscilik_detay_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_iscilik_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_iscilik_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    263    10            	           1259    34687    urt_paket_iscilikler    TABLE     t   CREATE TABLE public.urt_paket_iscilikler (
    id bigint NOT NULL,
    paket_adi character varying(128) NOT NULL
);
 (   DROP TABLE public.urt_paket_iscilikler;
       public         heap 	   ths_admin    false    10            
           1259    34690    rct_paket_iscilik_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    265    10                       1259    34691    urt_recete_hammaddeler    TABLE     �   CREATE TABLE public.urt_recete_hammaddeler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    recete_id bigint,
    stok_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL,
    fire_orani numeric(18,6) DEFAULT 0 NOT NULL
);
 *   DROP TABLE public.urt_recete_hammaddeler;
       public         heap 	   ths_admin    false    10                       1259    34695    rct_recete_hammadde_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    267                       1259    34696    urt_receteler    TABLE     �   CREATE TABLE public.urt_receteler (
    id bigint NOT NULL,
    urun_kodu character varying(32) NOT NULL,
    urun_adi character varying(128) NOT NULL,
    ornek_miktari numeric(18,6) DEFAULT 1,
    aciklama character varying(128)
);
 !   DROP TABLE public.urt_receteler;
       public         heap 	   ths_admin    false    10                       1259    34700    rct_recete_id_seq    SEQUENCE     �   ALTER TABLE public.urt_receteler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    269                       1259    34701    urt_recete_iscilikler    TABLE     �   CREATE TABLE public.urt_recete_iscilikler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    iscilik_kodu character varying(16) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 )   DROP TABLE public.urt_recete_iscilikler;
       public         heap 	   ths_admin    false    10                       1259    34704    rct_recete_iscilik_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    271    10                       1259    34705    urt_recete_paket_hammaddeler    TABLE     �   CREATE TABLE public.urt_recete_paket_hammaddeler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    paket_id bigint NOT NULL,
    miktar numeric(18,6)
);
 0   DROP TABLE public.urt_recete_paket_hammaddeler;
       public         heap 	   ths_admin    false    10                       1259    34708     rct_recete_paket_hammadde_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_paket_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_paket_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    273    10                       1259    34709    urt_recete_paket_iscilikler    TABLE     �   CREATE TABLE public.urt_recete_paket_iscilikler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    paket_id bigint NOT NULL,
    miktar numeric(18,6)
);
 /   DROP TABLE public.urt_recete_paket_iscilikler;
       public         heap 	   ths_admin    false    10                       1259    34712    rct_recete_paket_iscilik_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_paket_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_paket_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    275    10                       1259    34713    sat_fatura_detaylari    TABLE     �   CREATE TABLE public.sat_fatura_detaylari (
    id bigint NOT NULL,
    header_id bigint,
    teklif_detay_id bigint,
    siparis_detay_id bigint,
    irsaliye_detay_id bigint
);
 (   DROP TABLE public.sat_fatura_detaylari;
       public         heap 	   ths_admin    false    10                       1259    34716    sat_fatura_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_fatura_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_fatura_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    277    10                       1259    34717    sat_faturalar    TABLE     �   CREATE TABLE public.sat_faturalar (
    id bigint NOT NULL,
    fatura_no character varying(16),
    fatura_tarihi timestamp without time zone,
    teklif_id bigint,
    siparis_id bigint,
    irsaliye_id bigint
);
 !   DROP TABLE public.sat_faturalar;
       public         heap 	   ths_admin    false    10                       1259    34720    sat_fatura_id_seq    SEQUENCE     �   ALTER TABLE public.sat_faturalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_fatura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    279    10                       1259    34721    sat_irsaliye_detaylari    TABLE     �   CREATE TABLE public.sat_irsaliye_detaylari (
    id bigint NOT NULL,
    header_id bigint,
    teklif_detay_id bigint,
    siparis_detay_id bigint,
    fatura_detay_id bigint
);
 *   DROP TABLE public.sat_irsaliye_detaylari;
       public         heap 	   ths_admin    false    10                       1259    34724    sat_irsaliye_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_irsaliye_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_irsaliye_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    281    10                       1259    34725    sat_irsaliyeler    TABLE     �   CREATE TABLE public.sat_irsaliyeler (
    id bigint NOT NULL,
    irsaliye_no character varying(16),
    irsaliye_tarihi timestamp without time zone,
    teklif_id bigint,
    siparis_id bigint,
    fatura_id bigint
);
 #   DROP TABLE public.sat_irsaliyeler;
       public         heap 	   ths_admin    false    10                       1259    34728    sat_irsaliye_id_seq    SEQUENCE     �   ALTER TABLE public.sat_irsaliyeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_irsaliye_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    283    10                       1259    34729    sat_siparis_detaylari    TABLE     �  CREATE TABLE public.sat_siparis_detaylari (
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
       public         heap 	   ths_admin    false    10                       1259    34752    sat_siparis_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_siparis_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_siparis_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    285    10                       1259    34753    sat_siparisler    TABLE     �  CREATE TABLE public.sat_siparisler (
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
       public         heap 	   ths_admin    false    10                        1259    34774    sat_siparis_id_seq    SEQUENCE     �   ALTER TABLE public.sat_siparisler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_siparis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    287            !           1259    34775    set_sls_order_status    TABLE     �   CREATE TABLE public.set_sls_order_status (
    id bigint NOT NULL,
    siparis_durum character varying(32) NOT NULL,
    aciklama character varying(64)
);
 (   DROP TABLE public.set_sls_order_status;
       public         heap 	   ths_admin    false    10            "           1259    34778    stk_gruplar    TABLE     +  CREATE TABLE public.stk_gruplar (
    id bigint NOT NULL,
    grup character varying(32) NOT NULL,
    kdv_orani double precision NOT NULL,
    hammadde_stok_hesap_kodu character varying(16),
    hammadde_kullanim_hesap_kodu character varying(16),
    yari_mamul_hesap_kodu character varying(16)
);
    DROP TABLE public.stk_gruplar;
       public         heap 	   ths_admin    false    10            #           1259    34781    stk_kartlar    TABLE     
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
       public         heap 	   ths_admin    false    517    405    405    405    10            $           1259    34802    sys_sehirler    TABLE     �   CREATE TABLE public.sys_sehirler (
    id bigint NOT NULL,
    sehir character varying(32) NOT NULL,
    plaka_kodu integer,
    ulke_id bigint,
    bolge_id bigint
);
     DROP TABLE public.sys_sehirler;
       public         heap 	   ths_admin    false    10            %           1259    34805    sat_siparis_rapor    VIEW     )  CREATE VIEW public.sat_siparis_rapor AS
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
       public       	   ths_admin    false    285    292    292    291    291    290    290    289    289    287    287    287    287    287    287    287    287    287    287    285    285    285    285    285    285    10            &           1259    34810    sat_teklif_detaylari    TABLE     �  CREATE TABLE public.sat_teklif_detaylari (
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
       public         heap 	   ths_admin    false    10            '           1259    34826    sat_teklif_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_teklif_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_teklif_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    294            (           1259    34827    sat_teklifler    TABLE     y  CREATE TABLE public.sat_teklifler (
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
       public         heap 	   ths_admin    false    10            )           1259    34848    sat_teklif_id_seq    SEQUENCE     �   ALTER TABLE public.sat_teklifler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_teklif_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    296            *           1259    34849    set_ch_firma_tipleri    TABLE     �   CREATE TABLE public.set_ch_firma_tipleri (
    id bigint NOT NULL,
    firma_turu_id bigint NOT NULL,
    firma_tipi character varying(48) NOT NULL
);
 (   DROP TABLE public.set_ch_firma_tipleri;
       public         heap 	   ths_admin    false    10            +           1259    34852    set_ch_firma_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_firma_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_firma_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    298    10            ,           1259    34853    set_ch_firma_turleri    TABLE     t   CREATE TABLE public.set_ch_firma_turleri (
    id bigint NOT NULL,
    firma_turu character varying(32) NOT NULL
);
 (   DROP TABLE public.set_ch_firma_turleri;
       public         heap 	   ths_admin    false    10            -           1259    34856    set_ch_firma_turu_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_firma_turleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_firma_turu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    300            .           1259    34857    set_ch_grup_id_seq    SEQUENCE     �   ALTER TABLE public.ch_gruplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_grup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    240            /           1259    34858    set_ch_hesap_plani_id_seq    SEQUENCE     �   ALTER TABLE public.ch_hesap_planlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_hesap_plani_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    243            0           1259    34859    set_ch_hesap_tipleri    TABLE     t   CREATE TABLE public.set_ch_hesap_tipleri (
    id bigint NOT NULL,
    hesap_tipi character varying(16) NOT NULL
);
 (   DROP TABLE public.set_ch_hesap_tipleri;
       public         heap 	   ths_admin    false    10            1           1259    34862    set_ch_hesap_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_hesap_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_hesap_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    304            2           1259    34863    set_ch_vergi_oranlari    TABLE     I  CREATE TABLE public.set_ch_vergi_oranlari (
    id bigint NOT NULL,
    vergi_orani numeric(5,2) NOT NULL,
    satis_hesap_kodu character varying(16) NOT NULL,
    satis_iade_hesap_kodu character varying(16) NOT NULL,
    alis_hesap_kodu character varying(16) NOT NULL,
    alis_iade_hesap_kodu character varying(16) NOT NULL
);
 )   DROP TABLE public.set_ch_vergi_oranlari;
       public         heap 	   ths_admin    false    10            3           1259    34866    set_ch_vergi_orani_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_vergi_oranlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_vergi_orani_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    306    10            4           1259    34867    set_einv_fatura_tipleri    TABLE     x   CREATE TABLE public.set_einv_fatura_tipleri (
    id bigint NOT NULL,
    fatura_tipi character varying(32) NOT NULL
);
 +   DROP TABLE public.set_einv_fatura_tipleri;
       public         heap 	   ths_admin    false    10            5           1259    34870    set_einv_fatura_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_fatura_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_fatura_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    308    10            6           1259    34871    set_einv_odeme_sekilleri    TABLE     �   CREATE TABLE public.set_einv_odeme_sekilleri (
    id bigint NOT NULL,
    odeme_sekli character varying(96),
    kod character varying(16),
    aciklama character varying(512),
    is_efatura boolean DEFAULT false
);
 ,   DROP TABLE public.set_einv_odeme_sekilleri;
       public         heap 	   ths_admin    false    10            7           1259    34877    set_einv_odeme_sekli_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_odeme_sekilleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_odeme_sekli_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    310    10            8           1259    34878    set_einv_paket_tipleri    TABLE     �   CREATE TABLE public.set_einv_paket_tipleri (
    id bigint NOT NULL,
    kod character varying(2),
    paket_tipi character varying(128),
    aciklama character varying(512)
);
 *   DROP TABLE public.set_einv_paket_tipleri;
       public         heap 	   ths_admin    false    10            9           1259    34883    set_einv_paket_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_paket_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_paket_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    312            :           1259    34884    set_einv_tasima_ucretleri    TABLE     s   CREATE TABLE public.set_einv_tasima_ucretleri (
    id bigint NOT NULL,
    tasima_ucreti character varying(16)
);
 -   DROP TABLE public.set_einv_tasima_ucretleri;
       public         heap 	   ths_admin    false    10            ;           1259    34887    set_einv_tasima_ucreti_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_tasima_ucretleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_tasima_ucreti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    314    10            <           1259    34888    set_einv_teslim_sekilleri    TABLE     �   CREATE TABLE public.set_einv_teslim_sekilleri (
    id bigint NOT NULL,
    teslim_sekli character varying(16) NOT NULL,
    aciklama character varying(96) NOT NULL,
    is_efatura boolean DEFAULT false
);
 -   DROP TABLE public.set_einv_teslim_sekilleri;
       public         heap 	   ths_admin    false    10            =           1259    34892    set_einv_teslim_sekli_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_teslim_sekilleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_teslim_sekli_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    316            >           1259    34893    set_prs_birimler    TABLE     �   CREATE TABLE public.set_prs_birimler (
    id bigint NOT NULL,
    birim character varying(32) NOT NULL,
    bolum_id bigint
);
 $   DROP TABLE public.set_prs_birimler;
       public         heap 	   ths_admin    false    10            ?           1259    34896    set_prs_birim_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_birimler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_birim_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    318            @           1259    34897    set_prs_bolumler    TABLE     k   CREATE TABLE public.set_prs_bolumler (
    id bigint NOT NULL,
    bolum character varying(32) NOT NULL
);
 $   DROP TABLE public.set_prs_bolumler;
       public         heap 	   ths_admin    false    10            A           1259    34900    set_prs_bolum_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_bolumler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_bolum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    320            B           1259    34901    set_prs_ehliyetler    TABLE     o   CREATE TABLE public.set_prs_ehliyetler (
    id bigint NOT NULL,
    ehliyet character varying(32) NOT NULL
);
 &   DROP TABLE public.set_prs_ehliyetler;
       public         heap 	   ths_admin    false    10            C           1259    34904    set_prs_ehliyet_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_ehliyetler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_ehliyet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    322    10            D           1259    34905    set_prs_gorevler    TABLE     k   CREATE TABLE public.set_prs_gorevler (
    id bigint NOT NULL,
    gorev character varying(32) NOT NULL
);
 $   DROP TABLE public.set_prs_gorevler;
       public         heap 	   ths_admin    false    10            E           1259    34908    set_prs_gorev_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_gorevler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_gorev_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    324    10            F           1259    34909    set_prs_lisanlar    TABLE     k   CREATE TABLE public.set_prs_lisanlar (
    id bigint NOT NULL,
    lisan character varying(16) NOT NULL
);
 $   DROP TABLE public.set_prs_lisanlar;
       public         heap 	   ths_admin    false    10            G           1259    34912    set_prs_lisan_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_lisanlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_lisan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    326            H           1259    34913    set_prs_lisan_seviyeleri    TABLE     |   CREATE TABLE public.set_prs_lisan_seviyeleri (
    id bigint NOT NULL,
    lisan_seviyesi character varying(16) NOT NULL
);
 ,   DROP TABLE public.set_prs_lisan_seviyeleri;
       public         heap 	   ths_admin    false    10            I           1259    34916    set_prs_lisan_seviyesi_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_lisan_seviyeleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_lisan_seviyesi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    328    10            J           1259    34917    set_prs_personel_tipleri    TABLE     {   CREATE TABLE public.set_prs_personel_tipleri (
    id bigint NOT NULL,
    personel_tipi character varying(32) NOT NULL
);
 ,   DROP TABLE public.set_prs_personel_tipleri;
       public         heap 	   ths_admin    false    10            K           1259    34920    set_prs_personel_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_personel_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_personel_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    330    10            L           1259    34921    set_prs_tasima_servisleri    TABLE     �   CREATE TABLE public.set_prs_tasima_servisleri (
    id bigint NOT NULL,
    arac_no smallint NOT NULL,
    arac_adi character varying(32) NOT NULL,
    rota double precision[]
);
 -   DROP TABLE public.set_prs_tasima_servisleri;
       public         heap 	   ths_admin    false    10            M           1259    34926    set_prs_servis_araci_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_tasima_servisleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_servis_araci_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    332    10            N           1259    34927    set_sat_siparis_durum_id_seq    SEQUENCE     �   ALTER TABLE public.set_sls_order_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_sat_siparis_durum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    289    10            O           1259    34928    set_sls_offer_status    TABLE     �   CREATE TABLE public.set_sls_offer_status (
    id bigint NOT NULL,
    teklif_durum character varying(32) NOT NULL,
    aciklama character varying(64)
);
 (   DROP TABLE public.set_sls_offer_status;
       public         heap 	   ths_admin    false    10            P           1259    34931    set_sat_teklif_durum_id_seq    SEQUENCE     �   ALTER TABLE public.set_sls_offer_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_sat_teklif_durum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    335            Q           1259    34932    stk_ambarlar    TABLE       CREATE TABLE public.stk_ambarlar (
    id bigint NOT NULL,
    ambar_adi character varying(32),
    is_varsayilan_hammadde boolean DEFAULT false NOT NULL,
    is_varsayilan_uretim boolean DEFAULT false NOT NULL,
    is_varsayilan_satis boolean DEFAULT false NOT NULL
);
     DROP TABLE public.stk_ambarlar;
       public         heap 	   ths_admin    false    10            v           0    0    TABLE stk_ambarlar    COMMENT     X   COMMENT ON TABLE public.stk_ambarlar IS 'Stok hareketlerinin tutulduğu ambar bilgisi';
          public       	   ths_admin    false    337            R           1259    34938    stk_cins_ozellikleri    TABLE     �  CREATE TABLE public.stk_cins_ozellikleri (
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
       public         heap 	   ths_admin    false    10            S           1259    34943    stk_cins_ozellikleri_id_seq    SEQUENCE     �   ALTER TABLE public.stk_cins_ozellikleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_cins_ozellikleri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    338    10            T           1259    34944    stk_hareketler    TABLE       CREATE TABLE public.stk_hareketler (
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
       public         heap 	   ths_admin    false    10            U           1259    34949    stk_hareketler_id_seq    SEQUENCE     �   ALTER TABLE public.stk_hareketler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_hareketler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    340            V           1259    34950    stk_kart_cins_bilgileri    TABLE     n  CREATE TABLE public.stk_kart_cins_bilgileri (
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
       public         heap 	   ths_admin    false    10            W           1259    34955    stk_kart_cins_bilgileri_id_seq    SEQUENCE     �   ALTER TABLE public.stk_kart_cins_bilgileri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_kart_cins_bilgileri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    342    10            X           1259    34956    stk_kart_ozetleri    TABLE     �  CREATE TABLE public.stk_kart_ozetleri (
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
       public         heap 	   ths_admin    false    10            Y           1259    34970    stk_kart_ozetleri_id_seq    SEQUENCE     �   ALTER TABLE public.stk_kart_ozetleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_kart_ozetleri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    344            Z           1259    34971    stk_kartlar_id_seq    SEQUENCE     �   ALTER TABLE public.stk_kartlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_kartlar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    291    10            [           1259    34972    stk_resimler    TABLE     n   CREATE TABLE public.stk_resimler (
    id bigint NOT NULL,
    stk_kart_id bigint NOT NULL,
    resim text
);
     DROP TABLE public.stk_resimler;
       public         heap 	   ths_admin    false    10            \           1259    34977    stk_resimler_id_seq    SEQUENCE     �   ALTER TABLE public.stk_resimler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_resimler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    347            ]           1259    34978    stk_stok_ambar_id_seq    SEQUENCE     �   ALTER TABLE public.stk_ambarlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_stok_ambar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    337    10            ^           1259    34979    stk_stok_grubu_id_seq    SEQUENCE     �   ALTER TABLE public.stk_gruplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_stok_grubu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    290    10            _           1259    34980    sys_adresler    TABLE     �  CREATE TABLE public.sys_adresler (
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
       public         heap 	   ths_admin    false    10            `           1259    34985    sys_adresler_id_seq    SEQUENCE     �   ALTER TABLE public.sys_adresler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_adresler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    351    10            a           1259    34986 	   sys_aylar    TABLE     e   CREATE TABLE public.sys_aylar (
    id bigint NOT NULL,
    ay_adi character varying(16) NOT NULL
);
    DROP TABLE public.sys_aylar;
       public         heap 	   ths_admin    false    10            b           1259    34989    sys_ay_id_seq    SEQUENCE     �   ALTER TABLE public.sys_aylar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    353            c           1259    34990    sys_bolgeler    TABLE     g   CREATE TABLE public.sys_bolgeler (
    id bigint NOT NULL,
    bolge character varying(64) NOT NULL
);
     DROP TABLE public.sys_bolgeler;
       public         heap 	   ths_admin    false    10            d           1259    34993    sys_bolge_id_seq    SEQUENCE     �   ALTER TABLE public.sys_bolgeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_bolge_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    355    10            e           1259    34994    sys_db_status    VIEW     m  CREATE VIEW public.sys_db_status AS
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
     DROP VIEW public.sys_db_status;
       public       	   ths_admin    false    10            f           1259    34999    sys_ersim_haklari    TABLE     i  CREATE TABLE public.sys_ersim_haklari (
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
       public         heap 	   ths_admin    false    10            g           1259    35007    sys_erisim_hakki_id_seq    SEQUENCE     �   ALTER TABLE public.sys_ersim_haklari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_erisim_hakki_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    358            h           1259    35008    sys_grid_filtreler_siralamalar    TABLE     �   CREATE TABLE public.sys_grid_filtreler_siralamalar (
    id bigint NOT NULL,
    tablo_adi character varying(32),
    icerik character varying,
    is_siralama boolean DEFAULT false
);
 2   DROP TABLE public.sys_grid_filtreler_siralamalar;
       public         heap 	   ths_admin    false    10            i           1259    35014    sys_grid_filtre_siralama_id_seq    SEQUENCE     �   ALTER TABLE public.sys_grid_filtreler_siralamalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_filtre_siralama_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    360    10            j           1259    35015    sys_grid_kolonlar    TABLE     �  CREATE TABLE public.sys_grid_kolonlar (
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
       public         heap 	   ths_admin    false    10            k           1259    35030    sys_grid_kolon_id_seq    SEQUENCE     �   ALTER TABLE public.sys_grid_kolonlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_kolon_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    362            t           1259    35053    sys_gui_icerikler    TABLE     "  CREATE TABLE public.sys_gui_icerikler (
    id bigint NOT NULL,
    kod character varying(64) NOT NULL,
    deger text,
    is_fabrika boolean DEFAULT false NOT NULL,
    icerik_tipi character varying(32) NOT NULL,
    tablo_adi character varying(64),
    form_adi character varying(64)
);
 %   DROP TABLE public.sys_gui_icerikler;
       public         heap 	   ths_admin    false    10            l           1259    35031 
   sys_gunler    TABLE     g   CREATE TABLE public.sys_gunler (
    id bigint NOT NULL,
    gun_adi character varying(16) NOT NULL
);
    DROP TABLE public.sys_gunler;
       public         heap 	   ths_admin    false    10            m           1259    35034    sys_gun_id_seq    SEQUENCE     �   ALTER TABLE public.sys_gunler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_gun_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    364    10            n           1259    35035    sys_kaynak_gruplari    TABLE     m   CREATE TABLE public.sys_kaynak_gruplari (
    id bigint NOT NULL,
    grup character varying(64) NOT NULL
);
 '   DROP TABLE public.sys_kaynak_gruplari;
       public         heap 	   ths_admin    false    10            o           1259    35038    sys_kaynak_grup_id_seq    SEQUENCE     �   ALTER TABLE public.sys_kaynak_gruplari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kaynak_grup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    366    10            p           1259    35039    sys_kaynaklar    TABLE     �   CREATE TABLE public.sys_kaynaklar (
    id bigint NOT NULL,
    kaynak_kodu integer NOT NULL,
    kaynak_adi character varying(64) NOT NULL,
    kaynak_grup_id bigint NOT NULL
);
 !   DROP TABLE public.sys_kaynaklar;
       public         heap 	   ths_admin    false    10            q           1259    35042    sys_kaynak_id_seq    SEQUENCE     �   ALTER TABLE public.sys_kaynaklar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kaynak_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    368            r           1259    35043    sys_kullanicilar    TABLE     �  CREATE TABLE public.sys_kullanicilar (
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
       public         heap 	   ths_admin    false    10            s           1259    35052    sys_kullanici_id_seq    SEQUENCE     �   ALTER TABLE public.sys_kullanicilar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kullanici_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    370    10            u           1259    35059    sys_lisan_gui_icerik_id_seq    SEQUENCE     �   ALTER TABLE public.sys_gui_icerikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_lisan_gui_icerik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    372    10            v           1259    35069    sys_olcu_birimleri    TABLE       CREATE TABLE public.sys_olcu_birimleri (
    id bigint NOT NULL,
    birim character varying(16) NOT NULL,
    birim_einv character varying(3),
    aciklama character varying(64),
    is_ondalik boolean DEFAULT false NOT NULL,
    birim_tipi_id bigint,
    carpan integer
);
 &   DROP TABLE public.sys_olcu_birimleri;
       public         heap 	   ths_admin    false    10            w           1259    35073    sys_olcu_birimi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_olcu_birimleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_olcu_birimi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    374    10            x           1259    35074    sys_olcu_birimi_tipleri    TABLE     }   CREATE TABLE public.sys_olcu_birimi_tipleri (
    id bigint NOT NULL,
    olcu_birimi_tipi character varying(16) NOT NULL
);
 +   DROP TABLE public.sys_olcu_birimi_tipleri;
       public         heap 	   ths_admin    false    10            y           1259    35077    sys_olcu_birimi_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_olcu_birimi_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_olcu_birimi_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    376            z           1259    35078    sys_ondalik_haneler    TABLE     �   CREATE TABLE public.sys_ondalik_haneler (
    id bigint NOT NULL,
    miktar smallint DEFAULT 2,
    fiyat smallint DEFAULT 2,
    tutar smallint DEFAULT 2,
    stok_miktar smallint DEFAULT 4,
    doviz_kuru smallint DEFAULT 4
);
 '   DROP TABLE public.sys_ondalik_haneler;
       public         heap 	   ths_admin    false    10            {           1259    35086    sys_ondalik_hane_id_seq    SEQUENCE     �   ALTER TABLE public.sys_ondalik_haneler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ondalik_hane_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    378            |           1259    35087    sys_para_birimleri    TABLE     �   CREATE TABLE public.sys_para_birimleri (
    id bigint NOT NULL,
    para character varying(3) NOT NULL,
    sembol character varying(3) NOT NULL,
    aciklama character varying(128)
);
 &   DROP TABLE public.sys_para_birimleri;
       public         heap 	   ths_admin    false    10            }           1259    35090    sys_para_birimi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_para_birimleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_para_birimi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    380    10            ~           1259    35091    sys_sehir_id_seq    SEQUENCE     �   ALTER TABLE public.sys_sehirler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_sehir_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    292                       1259    35092    sys_ulkeler    TABLE       CREATE TABLE public.sys_ulkeler (
    id bigint NOT NULL,
    ulke_kodu character varying(2) NOT NULL,
    ulke_adi character varying(128) NOT NULL,
    iso_year integer,
    iso_cctld character varying(3),
    is_eu_member boolean DEFAULT false NOT NULL
);
    DROP TABLE public.sys_ulkeler;
       public         heap 	   ths_admin    false    10            �           1259    35096    sys_ulke_id_seq    SEQUENCE     �   ALTER TABLE public.sys_ulkeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ulke_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    383            �           1259    35097    sys_uygulama_ayarlari    TABLE       CREATE TABLE public.sys_uygulama_ayarlari (
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
    diger_ayarlar json,
    logo text
);
 )   DROP TABLE public.sys_uygulama_ayarlari;
       public         heap 	   ths_admin    false    10            �           1259    35109    sys_uygulama_ayari_id_seq    SEQUENCE     �   ALTER TABLE public.sys_uygulama_ayarlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_uygulama_ayari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    385    10            �           1259    35110    sys_view_tables    VIEW     \  CREATE VIEW public.sys_view_tables AS
 SELECT (row_number() OVER (ORDER BY table_type, table_name))::integer AS id,
    initcap(replace((table_name)::text, '_'::text, ' '::text)) AS table_name,
    (table_type)::text AS table_type
   FROM information_schema.tables
  WHERE ((table_schema)::text = 'public'::text)
  ORDER BY table_type, table_name;
 "   DROP VIEW public.sys_view_tables;
       public       	   ths_admin    false    10            �           1259    35114    sys_view_columns    VIEW     '  CREATE VIEW public.sys_view_columns AS
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
       public       	   ths_admin    false    387    387    10            �           1259    35119    sys_view_databases    VIEW     >  CREATE VIEW public.sys_view_databases AS
 SELECT (pg_database.datname)::text AS database_name,
    pg_shdescription.description AS aciklama
   FROM (pg_shdescription
     JOIN pg_database ON ((pg_shdescription.objoid = pg_database.oid)))
  WHERE ((1 = 1) AND (pg_shdescription.description = 'THS ERP Systems'::text));
 %   DROP VIEW public.sys_view_databases;
       public       	   ths_admin    false    10            �           1259    35124    urt_recete_yan_urunler    TABLE     �   CREATE TABLE public.urt_recete_yan_urunler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    urun_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 *   DROP TABLE public.urt_recete_yan_urunler;
       public         heap 	   ths_admin    false    10            �           1259    35127    urt_recete_yan_urunler_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_yan_urunler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urt_recete_yan_urunler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    390            �          0    34564    als_teklif_detaylari 
   TABLE DATA           c  COPY public.als_teklif_detaylari (id, header_id, siparis_detay_id, irsaliye_detay_id, fatura_detay_id, stok_kodu, stok_aciklama, kullanici_aciklama, referans, miktar, olcu_birimi, iskonto_orani, kdv_orani, fiyat, net_fiyat, tutar, iskonto_tutar, net_tutar, kdv_tutar, toplam_tutar, is_ana_urun, referans_ana_urun_id, gtip_no, mensei_ulke_adi) FROM stdin;
    public       	   ths_admin    false    227   �Y      �          0    34581    als_teklifler 
   TABLE DATA           �  COPY public.als_teklifler (id, siparis_id, irsaliye_id, fatura_id, is_siparislesti, tutar, iskonto_tutar, ara_toplam, kdv_oran1, kdv_tutar1, kdv_oran2, kdv_tutar2, kdv_oran3, kdv_tutar3, kdv_oran4, kdv_tutar4, kdv_oran5, kdv_tutar5, genel_toplam, islem_tipi_id, teklif_no, teklif_tarihi, gecerlilik_tarihi, musteri_kodu, musteri_adi, vergi_dairesi, vergi_no, ulke_id, sehir_id, ilce, mahalle, semt, cadde, sokak, bina_adi, kapi_no, posta_kodu, web, email, musteri_temsilcisi, muhattap_ad, muhattap_telefon, referans, para_birimi, doviz_kuru_usd, doviz_kuru_eur, aciklama, tevkifat_kodu, tevkifat_aciklama, tevkifat_pay, tevkifat_payda) FROM stdin;
    public       	   ths_admin    false    229    Z      �          0    34603    audits 
   TABLE DATA           �   COPY public.audits (id, user_name, ip_address, table_name, access_type, time_of_change, row_id, client_username, old_val, new_val) FROM stdin;
    public       	   ths_admin    false    231   Z      �          0    34613    ch_banka_subeleri 
   TABLE DATA           X   COPY public.ch_banka_subeleri (id, banka_id, sube_kodu, sube_adi, sehir_id) FROM stdin;
    public       	   ths_admin    false    235   U\      �          0    34609    ch_bankalar 
   TABLE DATA           @   COPY public.ch_bankalar (id, banka_adi, swift_kodu) FROM stdin;
    public       	   ths_admin    false    233   �\      �          0    34617    ch_bolgeler 
   TABLE DATA           0   COPY public.ch_bolgeler (id, bolge) FROM stdin;
    public       	   ths_admin    false    237   �\      �          0    34621    ch_doviz_kurlari 
   TABLE DATA           E   COPY public.ch_doviz_kurlari (id, kur_tarihi, kur, para) FROM stdin;
    public       	   ths_admin    false    239   W]      �          0    34624 
   ch_gruplar 
   TABLE DATA           .   COPY public.ch_gruplar (id, grup) FROM stdin;
    public       	   ths_admin    false    240   �_      �          0    34636    ch_hesap_planlari 
   TABLE DATA           L   COPY public.ch_hesap_planlari (id, plan_kodu, plan_adi, seviye) FROM stdin;
    public       	   ths_admin    false    243   `      �          0    34627    ch_hesaplar 
   TABLE DATA           �  COPY public.ch_hesaplar (id, hesap_kodu, hesap_ismi, hesap_tipi_id, grup_id, bolge_id, mukellef_tipi, mukellef_adi, mukellef_adi2, mukellef_soyadi, vergi_dairesi, vergi_no, iban, iban_para, nace, yetkili1, yetkili1_tel, yetkili2, yetkili2_tel, yetkili3, yetkili3_tel, faks, muhasebe_telefon, muhasebe_email, muhasebe_yetkili, ozel_not, kok_kod, ara_kod, iskonto, efatura_kullaniyor, efatura_pb_name, adres_id, pasif) FROM stdin;
    public       	   ths_admin    false    241   )n      �          0    34640    mhs_fis_detaylari 
   TABLE DATA           :   COPY public.mhs_fis_detaylari (id, header_id) FROM stdin;
    public       	   ths_admin    false    245   ��      �          0    34644 
   mhs_fisler 
   TABLE DATA           D   COPY public.mhs_fisler (id, yevmiye_no, yevmiye_tarihi) FROM stdin;
    public       	   ths_admin    false    247   ��      �          0    34648    mhs_transfer_kodlari 
   TABLE DATA           W   COPY public.mhs_transfer_kodlari (id, transfer_kodu, aciklama, hesap_kodu) FROM stdin;
    public       	   ths_admin    false    249   Á      �          0    34652    prs_ehliyetler 
   TABLE DATA           E   COPY public.prs_ehliyetler (id, ehliyet_id, personel_id) FROM stdin;
    public       	   ths_admin    false    251   ��      �          0    34655    prs_lisan_bilgileri 
   TABLE DATA           h   COPY public.prs_lisan_bilgileri (id, lisan_id, okuma_id, yazma_id, konusma_id, personel_id) FROM stdin;
    public       	   ths_admin    false    252   �      �          0    34660    prs_personeller 
   TABLE DATA           i  COPY public.prs_personeller (id, ad, soyad, ad_soyad, tel1, tel2, personel_tipi_id, birim_id, gorev_id, dogum_tarihi, kan_grubu, cinsiyet, askerlik_durumu, medeni_durum, cocuk_sayisi, yakin_adi, yakin_telefon, ayakkabi_no, elbise_bedeni, genel_not, tasima_servis_id, ozel_not, maas, ikramiye_sayisi, ikramiye_tutar, identification, adres_id, pasif) FROM stdin;
    public       	   ths_admin    false    255   0�      �          0    34713    sat_fatura_detaylari 
   TABLE DATA           s   COPY public.sat_fatura_detaylari (id, header_id, teklif_detay_id, siparis_detay_id, irsaliye_detay_id) FROM stdin;
    public       	   ths_admin    false    277   {�      �          0    34717    sat_faturalar 
   TABLE DATA           i   COPY public.sat_faturalar (id, fatura_no, fatura_tarihi, teklif_id, siparis_id, irsaliye_id) FROM stdin;
    public       	   ths_admin    false    279   ��      �          0    34721    sat_irsaliye_detaylari 
   TABLE DATA           s   COPY public.sat_irsaliye_detaylari (id, header_id, teklif_detay_id, siparis_detay_id, fatura_detay_id) FROM stdin;
    public       	   ths_admin    false    281   ��      �          0    34725    sat_irsaliyeler 
   TABLE DATA           m   COPY public.sat_irsaliyeler (id, irsaliye_no, irsaliye_tarihi, teklif_id, siparis_id, fatura_id) FROM stdin;
    public       	   ths_admin    false    283   ҃      �          0    34729    sat_siparis_detaylari 
   TABLE DATA           �  COPY public.sat_siparis_detaylari (id, header_id, teklif_detay_id, irsaliye_detay_id, fatura_detay_id, stok_kodu, stok_aciklama, kullanici_aciklama, referans, miktar, giden_miktar, olcu_birimi, iskonto_orani, kdv_orani, fiyat, net_fiyat, tutar, iskonto_tutar, net_tutar, kdv_tutar, toplam_tutar, is_ana_urun, referans_ana_urun_id, gtip_no, en, boy, yukseklik, net_agirlik, brut_agirlik, hacim, kab) FROM stdin;
    public       	   ths_admin    false    285   �      �          0    34753    sat_siparisler 
   TABLE DATA           u  COPY public.sat_siparisler (id, teklif_id, irsaliye_id, fatura_id, tutar, iskonto_tutar, ara_toplam, kdv_oran1, kdv_tutar1, kdv_oran2, kdv_tutar2, kdv_oran3, kdv_tutar3, kdv_oran4, kdv_tutar4, kdv_oran5, kdv_tutar5, genel_toplam, islem_tipi_id, siparis_no, siparis_tarihi, teslim_tarihi, musteri_kodu, musteri_adi, vergi_dairesi, vergi_no, ulke_id, sehir_id, ilce, mahalle, cadde, sokak, posta_kodu, bina_adi, kapi_no, musteri_temsilcisi_id, muhattap_ad, referans, para_birimi, doviz_kuru_usd, doviz_kuru_eur, aciklama, proforma_no, siparis_durum_id, teslim_sekli_id, odeme_sekli_id, paket_tipi_id, tasima_ucreti_id) FROM stdin;
    public       	   ths_admin    false    287   �      �          0    34810    sat_teklif_detaylari 
   TABLE DATA           R  COPY public.sat_teklif_detaylari (id, header_id, siparis_detay_id, irsaliye_detay_id, fatura_detay_id, stok_kodu, stok_aciklama, kullanici_aciklama, referans, miktar, olcu_birimi, iskonto_orani, kdv_orani, fiyat, net_fiyat, tutar, iskonto_tutar, net_tutar, kdv_tutar, toplam_tutar, is_ana_urun, referans_ana_urun_id, gtip_no) FROM stdin;
    public       	   ths_admin    false    294   )�      �          0    34827    sat_teklifler 
   TABLE DATA           �  COPY public.sat_teklifler (id, siparis_id, irsaliye_id, fatura_id, is_siparislesti, tutar, iskonto_tutar, ara_toplam, kdv_oran1, kdv_tutar1, kdv_oran2, kdv_tutar2, kdv_oran3, kdv_tutar3, kdv_oran4, kdv_tutar4, kdv_oran5, kdv_tutar5, genel_toplam, islem_tipi_id, teklif_no, teklif_tarihi, gecerlilik_tarihi, musteri_kodu, musteri_adi, vergi_dairesi, vergi_no, ulke_id, sehir_id, ilce, mahalle, cadde, sokak, posta_kodu, bina_adi, kapi_no, musteri_temsilcisi_id, muhattap_ad, muhattap_telefon, referans, para_birimi, doviz_kuru_usd, doviz_kuru_eur, aciklama, proforma_no, teslim_sekli_id, odeme_sekli_id, paket_tipi_id, tasima_ucreti_id) FROM stdin;
    public       	   ths_admin    false    296   �      �          0    34849    set_ch_firma_tipleri 
   TABLE DATA           M   COPY public.set_ch_firma_tipleri (id, firma_turu_id, firma_tipi) FROM stdin;
    public       	   ths_admin    false    298   �      �          0    34853    set_ch_firma_turleri 
   TABLE DATA           >   COPY public.set_ch_firma_turleri (id, firma_turu) FROM stdin;
    public       	   ths_admin    false    300   9�      �          0    34859    set_ch_hesap_tipleri 
   TABLE DATA           >   COPY public.set_ch_hesap_tipleri (id, hesap_tipi) FROM stdin;
    public       	   ths_admin    false    304   i�      �          0    34863    set_ch_vergi_oranlari 
   TABLE DATA           �   COPY public.set_ch_vergi_oranlari (id, vergi_orani, satis_hesap_kodu, satis_iade_hesap_kodu, alis_hesap_kodu, alis_iade_hesap_kodu) FROM stdin;
    public       	   ths_admin    false    306   ��      �          0    34867    set_einv_fatura_tipleri 
   TABLE DATA           B   COPY public.set_einv_fatura_tipleri (id, fatura_tipi) FROM stdin;
    public       	   ths_admin    false    308   ��      �          0    34871    set_einv_odeme_sekilleri 
   TABLE DATA           ^   COPY public.set_einv_odeme_sekilleri (id, odeme_sekli, kod, aciklama, is_efatura) FROM stdin;
    public       	   ths_admin    false    310   P�      �          0    34878    set_einv_paket_tipleri 
   TABLE DATA           O   COPY public.set_einv_paket_tipleri (id, kod, paket_tipi, aciklama) FROM stdin;
    public       	   ths_admin    false    312   ��      �          0    34884    set_einv_tasima_ucretleri 
   TABLE DATA           F   COPY public.set_einv_tasima_ucretleri (id, tasima_ucreti) FROM stdin;
    public       	   ths_admin    false    314   �      �          0    34888    set_einv_teslim_sekilleri 
   TABLE DATA           [   COPY public.set_einv_teslim_sekilleri (id, teslim_sekli, aciklama, is_efatura) FROM stdin;
    public       	   ths_admin    false    316   �      �          0    34893    set_prs_birimler 
   TABLE DATA           ?   COPY public.set_prs_birimler (id, birim, bolum_id) FROM stdin;
    public       	   ths_admin    false    318   $�      �          0    34897    set_prs_bolumler 
   TABLE DATA           5   COPY public.set_prs_bolumler (id, bolum) FROM stdin;
    public       	   ths_admin    false    320   ��      �          0    34901    set_prs_ehliyetler 
   TABLE DATA           9   COPY public.set_prs_ehliyetler (id, ehliyet) FROM stdin;
    public       	   ths_admin    false    322   �      �          0    34905    set_prs_gorevler 
   TABLE DATA           5   COPY public.set_prs_gorevler (id, gorev) FROM stdin;
    public       	   ths_admin    false    324   �      �          0    34913    set_prs_lisan_seviyeleri 
   TABLE DATA           F   COPY public.set_prs_lisan_seviyeleri (id, lisan_seviyesi) FROM stdin;
    public       	   ths_admin    false    328   T�      �          0    34909    set_prs_lisanlar 
   TABLE DATA           5   COPY public.set_prs_lisanlar (id, lisan) FROM stdin;
    public       	   ths_admin    false    326   ��      �          0    34917    set_prs_personel_tipleri 
   TABLE DATA           E   COPY public.set_prs_personel_tipleri (id, personel_tipi) FROM stdin;
    public       	   ths_admin    false    330   ό      �          0    34921    set_prs_tasima_servisleri 
   TABLE DATA           P   COPY public.set_prs_tasima_servisleri (id, arac_no, arac_adi, rota) FROM stdin;
    public       	   ths_admin    false    332   	�      �          0    34928    set_sls_offer_status 
   TABLE DATA           J   COPY public.set_sls_offer_status (id, teklif_durum, aciklama) FROM stdin;
    public       	   ths_admin    false    335   &�      �          0    34775    set_sls_order_status 
   TABLE DATA           K   COPY public.set_sls_order_status (id, siparis_durum, aciklama) FROM stdin;
    public       	   ths_admin    false    289   i�      �          0    34932    stk_ambarlar 
   TABLE DATA           x   COPY public.stk_ambarlar (id, ambar_adi, is_varsayilan_hammadde, is_varsayilan_uretim, is_varsayilan_satis) FROM stdin;
    public       	   ths_admin    false    337   ��      �          0    34938    stk_cins_ozellikleri 
   TABLE DATA           �   COPY public.stk_cins_ozellikleri (id, cins, aciklama, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, i1, i2, i3, i4, i5, d1, d2, d3, d4, d5) FROM stdin;
    public       	   ths_admin    false    338   ��      �          0    34778    stk_gruplar 
   TABLE DATA           �   COPY public.stk_gruplar (id, grup, kdv_orani, hammadde_stok_hesap_kodu, hammadde_kullanim_hesap_kodu, yari_mamul_hesap_kodu) FROM stdin;
    public       	   ths_admin    false    290   ��      �          0    34944    stk_hareketler 
   TABLE DATA           �   COPY public.stk_hareketler (id, stok_kodu, miktar, tutar, tutar_doviz, para_birimi, is_giris, tarih, veren_ambar_id, alan_ambar_id, is_donem_basi, aciklama, irsaliye_id, uretim_id) FROM stdin;
    public       	   ths_admin    false    340   �      �          0    34950    stk_kart_cins_bilgileri 
   TABLE DATA           �   COPY public.stk_kart_cins_bilgileri (id, stk_kart_id, cins_id, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, i1, i2, i3, i4, i5, d1, d2, d3, d4, d5) FROM stdin;
    public       	   ths_admin    false    342    �      �          0    34956    stk_kart_ozetleri 
   TABLE DATA           ;  COPY public.stk_kart_ozetleri (id, stk_kart_id, stok_miktar, ortalama_maliyet, donem_basi_fiyat, donem_basi_miktar, donem_basi_tutar, giren_toplam, giren_toplam_maliyet, cikan_toplam, cikan_toplam_maliyet, son_alis_fiyat, son_alis_para, son_alis_tarih, son_alis_miktar, son_alis_kur, son_alis_kur_para) FROM stdin;
    public       	   ths_admin    false    344   T�      �          0    34781    stk_kartlar 
   TABLE DATA           n  COPY public.stk_kartlar (id, is_satilabilir, stok_kodu, stok_adi, stok_grubu_id, olcu_birimi_id, urun_tipi, alis_iskonto, satis_iskonto, alis_fiyat, alis_para, satis_fiyat, satis_para, ihrac_fiyat, ihrac_para, ortalama_maliyet, en, boy, yukseklik, agirlik, temin_suresi, ozel_kod, marka, mensei_id, gtip_no, diib_urun_tanimi, en_az_stok_seviyesi, tanim) FROM stdin;
    public       	   ths_admin    false    291   q�                 0    34972    stk_resimler 
   TABLE DATA           >   COPY public.stk_resimler (id, stk_kart_id, resim) FROM stdin;
    public       	   ths_admin    false    347   ߐ                0    34980    sys_adresler 
   TABLE DATA           �   COPY public.sys_adresler (id, sehir_id, ilce, mahalle, semt, cadde, sokak, bina_adi, kapi_no, posta_kodu, web, email) FROM stdin;
    public       	   ths_admin    false    351   |�                0    34986 	   sys_aylar 
   TABLE DATA           /   COPY public.sys_aylar (id, ay_adi) FROM stdin;
    public       	   ths_admin    false    353   �                0    34990    sys_bolgeler 
   TABLE DATA           1   COPY public.sys_bolgeler (id, bolge) FROM stdin;
    public       	   ths_admin    false    355   ��      
          0    34999    sys_ersim_haklari 
   TABLE DATA              COPY public.sys_ersim_haklari (id, kaynak_id, is_okuma, is_ekleme, is_guncelleme, is_silme, is_ozel, kullanici_id) FROM stdin;
    public       	   ths_admin    false    358   ��                0    35008    sys_grid_filtreler_siralamalar 
   TABLE DATA           \   COPY public.sys_grid_filtreler_siralamalar (id, tablo_adi, icerik, is_siralama) FROM stdin;
    public       	   ths_admin    false    360   ��                0    35015    sys_grid_kolonlar 
   TABLE DATA           �   COPY public.sys_grid_kolonlar (id, tablo_adi, kolon_adi, sira_no, kolon_genislik, veri_formati, is_gorunur, is_helper_gorunur, min_deger, min_renk, maks_deger, maks_renk, maks_deger_yuzdesi, bar_rengi, bar_arka_rengi, bar_yazi_rengi) FROM stdin;
    public       	   ths_admin    false    362   ��                0    35053    sys_gui_icerikler 
   TABLE DATA           i   COPY public.sys_gui_icerikler (id, kod, deger, is_fabrika, icerik_tipi, tablo_adi, form_adi) FROM stdin;
    public       	   ths_admin    false    372   ?�                0    35031 
   sys_gunler 
   TABLE DATA           1   COPY public.sys_gunler (id, gun_adi) FROM stdin;
    public       	   ths_admin    false    364   &�                0    35035    sys_kaynak_gruplari 
   TABLE DATA           7   COPY public.sys_kaynak_gruplari (id, grup) FROM stdin;
    public       	   ths_admin    false    366   �                0    35039    sys_kaynaklar 
   TABLE DATA           T   COPY public.sys_kaynaklar (id, kaynak_kodu, kaynak_adi, kaynak_grup_id) FROM stdin;
    public       	   ths_admin    false    368   ��                0    35043    sys_kullanicilar 
   TABLE DATA           �   COPY public.sys_kullanicilar (id, kullanici_adi, kullanici_sifre, is_aktif, is_yonetici, is_super_kullanici, ip_adres, mac_adres, personel_id) FROM stdin;
    public       	   ths_admin    false    370   �                0    35074    sys_olcu_birimi_tipleri 
   TABLE DATA           G   COPY public.sys_olcu_birimi_tipleri (id, olcu_birimi_tipi) FROM stdin;
    public       	   ths_admin    false    376   ��                0    35069    sys_olcu_birimleri 
   TABLE DATA           p   COPY public.sys_olcu_birimleri (id, birim, birim_einv, aciklama, is_ondalik, birim_tipi_id, carpan) FROM stdin;
    public       	   ths_admin    false    374   ��                0    35078    sys_ondalik_haneler 
   TABLE DATA           `   COPY public.sys_ondalik_haneler (id, miktar, fiyat, tutar, stok_miktar, doviz_kuru) FROM stdin;
    public       	   ths_admin    false    378   ��                 0    35087    sys_para_birimleri 
   TABLE DATA           H   COPY public.sys_para_birimleri (id, para, sembol, aciklama) FROM stdin;
    public       	   ths_admin    false    380   ��      �          0    34802    sys_sehirler 
   TABLE DATA           P   COPY public.sys_sehirler (id, sehir, plaka_kodu, ulke_id, bolge_id) FROM stdin;
    public       	   ths_admin    false    292   ��      #          0    35092    sys_ulkeler 
   TABLE DATA           a   COPY public.sys_ulkeler (id, ulke_kodu, ulke_adi, iso_year, iso_cctld, is_eu_member) FROM stdin;
    public       	   ths_admin    false    383   ��      %          0    35097    sys_uygulama_ayarlari 
   TABLE DATA           9  COPY public.sys_uygulama_ayarlari (id, unvan, telefon, faks, vergi_dairesi, vergi_no, donem, mail_sunucu, mail_kullanici, mail_sifre, mail_smtp_port, grid_renk_1, grid_renk_2, grid_renk_aktif, crypt_key, sms_sunucu, sms_kullanici, sms_sifre, sms_baslik, versiyon, para, adres_id, diger_ayarlar, logo) FROM stdin;
    public       	   ths_admin    false    385   [�      �          0    34671    urt_iscilikler 
   TABLE DATA           `   COPY public.urt_iscilikler (id, gider_kodu, gider_adi, fiyat, birim_id, gider_tipi) FROM stdin;
    public       	   ths_admin    false    257   �C      �          0    34675    urt_paket_hammadde_detaylari 
   TABLE DATA           c   COPY public.urt_paket_hammadde_detaylari (id, header_id, recete_id, stok_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    259   �C      �          0    34679    urt_paket_hammaddeler 
   TABLE DATA           >   COPY public.urt_paket_hammaddeler (id, paket_adi) FROM stdin;
    public       	   ths_admin    false    261   D      �          0    34683    urt_paket_iscilik_detaylari 
   TABLE DATA           Z   COPY public.urt_paket_iscilik_detaylari (id, header_id, iscilik_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    263   CD      �          0    34687    urt_paket_iscilikler 
   TABLE DATA           =   COPY public.urt_paket_iscilikler (id, paket_adi) FROM stdin;
    public       	   ths_admin    false    265   `D      �          0    34691    urt_recete_hammaddeler 
   TABLE DATA           i   COPY public.urt_recete_hammaddeler (id, header_id, recete_id, stok_kodu, miktar, fire_orani) FROM stdin;
    public       	   ths_admin    false    267   }D      �          0    34701    urt_recete_iscilikler 
   TABLE DATA           T   COPY public.urt_recete_iscilikler (id, header_id, iscilik_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    271   �D      �          0    34705    urt_recete_paket_hammaddeler 
   TABLE DATA           W   COPY public.urt_recete_paket_hammaddeler (id, header_id, paket_id, miktar) FROM stdin;
    public       	   ths_admin    false    273   �D      �          0    34709    urt_recete_paket_iscilikler 
   TABLE DATA           V   COPY public.urt_recete_paket_iscilikler (id, header_id, paket_id, miktar) FROM stdin;
    public       	   ths_admin    false    275   E      '          0    35124    urt_recete_yan_urunler 
   TABLE DATA           R   COPY public.urt_recete_yan_urunler (id, header_id, urun_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    390   5E      �          0    34696    urt_receteler 
   TABLE DATA           Y   COPY public.urt_receteler (id, urun_kodu, urun_adi, ornek_miktari, aciklama) FROM stdin;
    public       	   ths_admin    false    269   RE      w           0    0    a_invoices_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.a_invoices_id_seq', 10, true);
          public          postgres    false    226            x           0    0    als_teklif_detaylari_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.als_teklif_detaylari_id_seq', 1, false);
          public       	   ths_admin    false    228            y           0    0    als_teklifler_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.als_teklifler_id_seq', 1, false);
          public       	   ths_admin    false    230            z           0    0    audit_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.audit_id_seq', 27, true);
          public       	   ths_admin    false    232            {           0    0    ch_banka_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.ch_banka_id_seq', 6, true);
          public       	   ths_admin    false    234            |           0    0    ch_banka_subesi_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.ch_banka_subesi_id_seq', 7, true);
          public       	   ths_admin    false    236            }           0    0    ch_bolge_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.ch_bolge_id_seq', 17, true);
          public       	   ths_admin    false    238            ~           0    0    ch_hesap_karti_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.ch_hesap_karti_id_seq', 317, true);
          public       	   ths_admin    false    242                       0    0    mhs_doviz_kuru_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.mhs_doviz_kuru_id_seq', 331, true);
          public       	   ths_admin    false    244            �           0    0    mhs_fis_detaylari_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.mhs_fis_detaylari_id_seq', 1, false);
          public       	   ths_admin    false    246            �           0    0    mhs_fisler_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.mhs_fisler_id_seq', 1, false);
          public       	   ths_admin    false    248            �           0    0    mhs_transfer_kodlari_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.mhs_transfer_kodlari_id_seq', 1, false);
          public       	   ths_admin    false    250            �           0    0    prs_lisan_bilgisi_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.prs_lisan_bilgisi_id_seq', 2, true);
          public       	   ths_admin    false    253            �           0    0    prs_personel_ehliyetleri_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.prs_personel_ehliyetleri_id_seq', 2, true);
          public       	   ths_admin    false    254            �           0    0    prs_personel_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.prs_personel_id_seq', 16, true);
          public       	   ths_admin    false    256            �           0    0    rct_iscilik_gideri_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.rct_iscilik_gideri_id_seq', 2, false);
          public       	   ths_admin    false    258            �           0    0    rct_paket_hammadde_detay_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.rct_paket_hammadde_detay_id_seq', 2, true);
          public       	   ths_admin    false    260            �           0    0    rct_paket_hammadde_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.rct_paket_hammadde_id_seq', 1, true);
          public       	   ths_admin    false    262            �           0    0    rct_paket_iscilik_detay_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.rct_paket_iscilik_detay_id_seq', 1, false);
          public       	   ths_admin    false    264            �           0    0    rct_paket_iscilik_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.rct_paket_iscilik_id_seq', 1, false);
          public       	   ths_admin    false    266            �           0    0    rct_recete_hammadde_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.rct_recete_hammadde_id_seq', 18, true);
          public       	   ths_admin    false    268            �           0    0    rct_recete_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.rct_recete_id_seq', 9, true);
          public       	   ths_admin    false    270            �           0    0    rct_recete_iscilik_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.rct_recete_iscilik_id_seq', 2, true);
          public       	   ths_admin    false    272            �           0    0     rct_recete_paket_hammadde_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.rct_recete_paket_hammadde_id_seq', 1, false);
          public       	   ths_admin    false    274            �           0    0    rct_recete_paket_iscilik_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.rct_recete_paket_iscilik_id_seq', 1, false);
          public       	   ths_admin    false    276            �           0    0    sat_fatura_detay_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.sat_fatura_detay_id_seq', 1, false);
          public       	   ths_admin    false    278            �           0    0    sat_fatura_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sat_fatura_id_seq', 1, false);
          public       	   ths_admin    false    280            �           0    0    sat_irsaliye_detay_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sat_irsaliye_detay_id_seq', 1, false);
          public       	   ths_admin    false    282            �           0    0    sat_irsaliye_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.sat_irsaliye_id_seq', 1, false);
          public       	   ths_admin    false    284            �           0    0    sat_siparis_detay_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.sat_siparis_detay_id_seq', 1, false);
          public       	   ths_admin    false    286            �           0    0    sat_siparis_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sat_siparis_id_seq', 1, true);
          public       	   ths_admin    false    288            �           0    0    sat_teklif_detay_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.sat_teklif_detay_id_seq', 4, true);
          public       	   ths_admin    false    295            �           0    0    sat_teklif_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sat_teklif_id_seq', 1, true);
          public       	   ths_admin    false    297            �           0    0    set_ch_firma_tipi_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_firma_tipi_id_seq', 5, false);
          public       	   ths_admin    false    299            �           0    0    set_ch_firma_turu_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_firma_turu_id_seq', 2, false);
          public       	   ths_admin    false    301            �           0    0    set_ch_grup_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.set_ch_grup_id_seq', 72, true);
          public       	   ths_admin    false    302            �           0    0    set_ch_hesap_plani_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_ch_hesap_plani_id_seq', 286, false);
          public       	   ths_admin    false    303            �           0    0    set_ch_hesap_tipi_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_hesap_tipi_id_seq', 3, false);
          public       	   ths_admin    false    305            �           0    0    set_ch_vergi_orani_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_vergi_orani_id_seq', 7, true);
          public       	   ths_admin    false    307            �           0    0    set_einv_fatura_tipi_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_einv_fatura_tipi_id_seq', 6, false);
          public       	   ths_admin    false    309            �           0    0    set_einv_odeme_sekli_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_einv_odeme_sekli_id_seq', 32, false);
          public       	   ths_admin    false    311            �           0    0    set_einv_paket_tipi_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.set_einv_paket_tipi_id_seq', 4, false);
          public       	   ths_admin    false    313            �           0    0    set_einv_tasima_ucreti_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_einv_tasima_ucreti_id_seq', 3, true);
          public       	   ths_admin    false    315            �           0    0    set_einv_teslim_sekli_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.set_einv_teslim_sekli_id_seq', 28, false);
          public       	   ths_admin    false    317            �           0    0    set_prs_birim_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.set_prs_birim_id_seq', 46, true);
          public       	   ths_admin    false    319            �           0    0    set_prs_bolum_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.set_prs_bolum_id_seq', 26, true);
          public       	   ths_admin    false    321            �           0    0    set_prs_ehliyet_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.set_prs_ehliyet_id_seq', 6, true);
          public       	   ths_admin    false    323            �           0    0    set_prs_gorev_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.set_prs_gorev_id_seq', 6, true);
          public       	   ths_admin    false    325            �           0    0    set_prs_lisan_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.set_prs_lisan_id_seq', 4, true);
          public       	   ths_admin    false    327            �           0    0    set_prs_lisan_seviyesi_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.set_prs_lisan_seviyesi_id_seq', 4, false);
          public       	   ths_admin    false    329            �           0    0    set_prs_personel_tipi_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_prs_personel_tipi_id_seq', 3, false);
          public       	   ths_admin    false    331            �           0    0    set_prs_servis_araci_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.set_prs_servis_araci_id_seq', 1, true);
          public       	   ths_admin    false    333            �           0    0    set_sat_siparis_durum_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_sat_siparis_durum_id_seq', 3, false);
          public       	   ths_admin    false    334            �           0    0    set_sat_teklif_durum_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_sat_teklif_durum_id_seq', 3, false);
          public       	   ths_admin    false    336            �           0    0    stk_cins_ozellikleri_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.stk_cins_ozellikleri_id_seq', 7, true);
          public       	   ths_admin    false    339            �           0    0    stk_hareketler_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.stk_hareketler_id_seq', 1, false);
          public       	   ths_admin    false    341            �           0    0    stk_kart_cins_bilgileri_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.stk_kart_cins_bilgileri_id_seq', 16, true);
          public       	   ths_admin    false    343            �           0    0    stk_kart_ozetleri_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.stk_kart_ozetleri_id_seq', 1, false);
          public       	   ths_admin    false    345            �           0    0    stk_kartlar_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.stk_kartlar_id_seq', 9, true);
          public       	   ths_admin    false    346            �           0    0    stk_resimler_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.stk_resimler_id_seq', 6, true);
          public       	   ths_admin    false    348            �           0    0    stk_stok_ambar_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.stk_stok_ambar_id_seq', 4, true);
          public       	   ths_admin    false    349            �           0    0    stk_stok_grubu_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.stk_stok_grubu_id_seq', 12, true);
          public       	   ths_admin    false    350            �           0    0    sys_adresler_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.sys_adresler_id_seq', 6, true);
          public       	   ths_admin    false    352            �           0    0    sys_ay_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.sys_ay_id_seq', 24, true);
          public       	   ths_admin    false    354            �           0    0    sys_bolge_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sys_bolge_id_seq', 7, false);
          public       	   ths_admin    false    356            �           0    0    sys_erisim_hakki_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sys_erisim_hakki_id_seq', 1027, true);
          public       	   ths_admin    false    359            �           0    0    sys_grid_filtre_siralama_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.sys_grid_filtre_siralama_id_seq', 22, true);
          public       	   ths_admin    false    361            �           0    0    sys_grid_kolon_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.sys_grid_kolon_id_seq', 289, true);
          public       	   ths_admin    false    363            �           0    0    sys_gun_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.sys_gun_id_seq', 16, true);
          public       	   ths_admin    false    365            �           0    0    sys_kaynak_grup_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.sys_kaynak_grup_id_seq', 16, false);
          public       	   ths_admin    false    367            �           0    0    sys_kaynak_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sys_kaynak_id_seq', 44, true);
          public       	   ths_admin    false    369            �           0    0    sys_kullanici_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.sys_kullanici_id_seq', 66, true);
          public       	   ths_admin    false    371            �           0    0    sys_lisan_gui_icerik_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.sys_lisan_gui_icerik_id_seq', 169, true);
          public       	   ths_admin    false    373            �           0    0    sys_olcu_birimi_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.sys_olcu_birimi_id_seq', 19, true);
          public       	   ths_admin    false    375            �           0    0    sys_olcu_birimi_tipi_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.sys_olcu_birimi_tipi_id_seq', 4, true);
          public       	   ths_admin    false    377            �           0    0    sys_ondalik_hane_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.sys_ondalik_hane_id_seq', 1, false);
          public       	   ths_admin    false    379            �           0    0    sys_para_birimi_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.sys_para_birimi_id_seq', 4, true);
          public       	   ths_admin    false    381            �           0    0    sys_sehir_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.sys_sehir_id_seq', 174, false);
          public       	   ths_admin    false    382            �           0    0    sys_ulke_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sys_ulke_id_seq', 321, true);
          public       	   ths_admin    false    384            �           0    0    sys_uygulama_ayari_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sys_uygulama_ayari_id_seq', 4, false);
          public       	   ths_admin    false    386            �           0    0    urt_recete_yan_urunler_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.urt_recete_yan_urunler_id_seq', 1, false);
          public       	   ths_admin    false    391            :           2606    35131 .   als_teklif_detaylari als_teklif_detaylari_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.als_teklif_detaylari DROP CONSTRAINT als_teklif_detaylari_pkey;
       public         	   ths_admin    false    227            =           2606    35133     als_teklifler als_teklifler_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_pkey;
       public         	   ths_admin    false    229            ?           2606    35135 )   als_teklifler als_teklifler_teklif_no_key 
   CONSTRAINT     i   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_teklif_no_key UNIQUE (teklif_no);
 S   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_teklif_no_key;
       public         	   ths_admin    false    229            A           2606    35137    audits audit_pkey 
   CONSTRAINT     O   ALTER TABLE ONLY public.audits
    ADD CONSTRAINT audit_pkey PRIMARY KEY (id);
 ;   ALTER TABLE ONLY public.audits DROP CONSTRAINT audit_pkey;
       public         	   ths_admin    false    231            G           2606    35139 :   ch_banka_subeleri ch_banka_subeleri_banka_id_sube_kodu_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_banka_id_sube_kodu_key UNIQUE (banka_id, sube_kodu);
 d   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_banka_id_sube_kodu_key;
       public         	   ths_admin    false    235    235            I           2606    35141 (   ch_banka_subeleri ch_banka_subeleri_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_pkey;
       public         	   ths_admin    false    235            C           2606    35143 %   ch_bankalar ch_bankalar_banka_adi_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.ch_bankalar
    ADD CONSTRAINT ch_bankalar_banka_adi_key UNIQUE (banka_adi);
 O   ALTER TABLE ONLY public.ch_bankalar DROP CONSTRAINT ch_bankalar_banka_adi_key;
       public         	   ths_admin    false    233            E           2606    35145    ch_bankalar ch_bankalar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ch_bankalar
    ADD CONSTRAINT ch_bankalar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ch_bankalar DROP CONSTRAINT ch_bankalar_pkey;
       public         	   ths_admin    false    233            K           2606    35147 !   ch_bolgeler ch_bolgeler_bolge_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.ch_bolgeler
    ADD CONSTRAINT ch_bolgeler_bolge_key UNIQUE (bolge);
 K   ALTER TABLE ONLY public.ch_bolgeler DROP CONSTRAINT ch_bolgeler_bolge_key;
       public         	   ths_admin    false    237            M           2606    35149    ch_bolgeler ch_bolgeler_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ch_bolgeler
    ADD CONSTRAINT ch_bolgeler_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ch_bolgeler DROP CONSTRAINT ch_bolgeler_pkey;
       public         	   ths_admin    false    237            O           2606    35151 5   ch_doviz_kurlari ch_doviz_kurlari_kur_tarihi_para_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_kur_tarihi_para_key UNIQUE (kur_tarihi, para);
 _   ALTER TABLE ONLY public.ch_doviz_kurlari DROP CONSTRAINT ch_doviz_kurlari_kur_tarihi_para_key;
       public         	   ths_admin    false    239    239            Q           2606    35153 &   ch_doviz_kurlari ch_doviz_kurlari_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.ch_doviz_kurlari DROP CONSTRAINT ch_doviz_kurlari_pkey;
       public         	   ths_admin    false    239            S           2606    35155    ch_gruplar ch_gruplar_grup_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.ch_gruplar
    ADD CONSTRAINT ch_gruplar_grup_key UNIQUE (grup);
 H   ALTER TABLE ONLY public.ch_gruplar DROP CONSTRAINT ch_gruplar_grup_key;
       public         	   ths_admin    false    240            U           2606    35157    ch_gruplar ch_gruplar_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.ch_gruplar
    ADD CONSTRAINT ch_gruplar_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.ch_gruplar DROP CONSTRAINT ch_gruplar_pkey;
       public         	   ths_admin    false    240            [           2606    35159 (   ch_hesap_planlari ch_hesap_planlari_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.ch_hesap_planlari
    ADD CONSTRAINT ch_hesap_planlari_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.ch_hesap_planlari DROP CONSTRAINT ch_hesap_planlari_pkey;
       public         	   ths_admin    false    243            W           2606    35161 &   ch_hesaplar ch_hesaplar_hesap_kodu_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_hesap_kodu_key UNIQUE (hesap_kodu);
 P   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_hesap_kodu_key;
       public         	   ths_admin    false    241            Y           2606    35163    ch_hesaplar ch_hesaplar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_pkey;
       public         	   ths_admin    false    241            ]           2606    35165 (   mhs_fis_detaylari mhs_fis_detaylari_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.mhs_fis_detaylari
    ADD CONSTRAINT mhs_fis_detaylari_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.mhs_fis_detaylari DROP CONSTRAINT mhs_fis_detaylari_pkey;
       public         	   ths_admin    false    245            _           2606    35167    mhs_fisler mhs_fisler_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.mhs_fisler
    ADD CONSTRAINT mhs_fisler_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.mhs_fisler DROP CONSTRAINT mhs_fisler_pkey;
       public         	   ths_admin    false    247            a           2606    35169 $   mhs_fisler mhs_fisler_yevmiye_no_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.mhs_fisler
    ADD CONSTRAINT mhs_fisler_yevmiye_no_key UNIQUE (yevmiye_no);
 N   ALTER TABLE ONLY public.mhs_fisler DROP CONSTRAINT mhs_fisler_yevmiye_no_key;
       public         	   ths_admin    false    247            c           2606    35171 .   mhs_transfer_kodlari mhs_transfer_kodlari_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.mhs_transfer_kodlari
    ADD CONSTRAINT mhs_transfer_kodlari_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.mhs_transfer_kodlari DROP CONSTRAINT mhs_transfer_kodlari_pkey;
       public         	   ths_admin    false    249            e           2606    35173 ;   mhs_transfer_kodlari mhs_transfer_kodlari_transfer_kodu_key 
   CONSTRAINT        ALTER TABLE ONLY public.mhs_transfer_kodlari
    ADD CONSTRAINT mhs_transfer_kodlari_transfer_kodu_key UNIQUE (transfer_kodu);
 e   ALTER TABLE ONLY public.mhs_transfer_kodlari DROP CONSTRAINT mhs_transfer_kodlari_transfer_kodu_key;
       public         	   ths_admin    false    249            g           2606    35175 8   prs_ehliyetler prs_ehliyetler_ehliyet_id_personel_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_ehliyet_id_personel_id_key UNIQUE (ehliyet_id, personel_id);
 b   ALTER TABLE ONLY public.prs_ehliyetler DROP CONSTRAINT prs_ehliyetler_ehliyet_id_personel_id_key;
       public         	   ths_admin    false    251    251            i           2606    35177 "   prs_ehliyetler prs_ehliyetler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.prs_ehliyetler DROP CONSTRAINT prs_ehliyetler_pkey;
       public         	   ths_admin    false    251            k           2606    35179 @   prs_lisan_bilgileri prs_lisan_bilgileri_lisan_id_personel_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_lisan_id_personel_id_key UNIQUE (lisan_id, personel_id);
 j   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_lisan_id_personel_id_key;
       public         	   ths_admin    false    252    252            m           2606    35181 ,   prs_lisan_bilgileri prs_lisan_bilgileri_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_pkey;
       public         	   ths_admin    false    252            o           2606    35183 $   prs_personeller prs_personeller_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_pkey;
       public         	   ths_admin    false    255            �           2606    35185 .   sat_fatura_detaylari sat_fatura_detaylari_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.sat_fatura_detaylari
    ADD CONSTRAINT sat_fatura_detaylari_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.sat_fatura_detaylari DROP CONSTRAINT sat_fatura_detaylari_pkey;
       public         	   ths_admin    false    277            �           2606    35187     sat_faturalar sat_faturalar_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.sat_faturalar
    ADD CONSTRAINT sat_faturalar_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.sat_faturalar DROP CONSTRAINT sat_faturalar_pkey;
       public         	   ths_admin    false    279            �           2606    35189 2   sat_irsaliye_detaylari sat_irsaliye_detaylari_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.sat_irsaliye_detaylari
    ADD CONSTRAINT sat_irsaliye_detaylari_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.sat_irsaliye_detaylari DROP CONSTRAINT sat_irsaliye_detaylari_pkey;
       public         	   ths_admin    false    281            �           2606    35191 $   sat_irsaliyeler sat_irsaliyeler_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.sat_irsaliyeler
    ADD CONSTRAINT sat_irsaliyeler_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.sat_irsaliyeler DROP CONSTRAINT sat_irsaliyeler_pkey;
       public         	   ths_admin    false    283            �           2606    35193 0   sat_siparis_detaylari sat_siparis_detaylari_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_pkey;
       public         	   ths_admin    false    285            �           2606    35195 "   sat_siparisler sat_siparisler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_pkey;
       public         	   ths_admin    false    287            �           2606    35197 .   sat_teklif_detaylari sat_teklif_detaylari_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_pkey;
       public         	   ths_admin    false    294            �           2606    35199 &   sat_teklifler sat_teklif_teklif_no_key 
   CONSTRAINT     f   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklif_teklif_no_key UNIQUE (teklif_no);
 P   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklif_teklif_no_key;
       public         	   ths_admin    false    296            �           2606    35201     sat_teklifler sat_teklifler_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_pkey;
       public         	   ths_admin    false    296            �           2606    35203 9   set_ch_firma_turleri set_acc_firma_turleri_firma_turu_key 
   CONSTRAINT     z   ALTER TABLE ONLY public.set_ch_firma_turleri
    ADD CONSTRAINT set_acc_firma_turleri_firma_turu_key UNIQUE (firma_turu);
 c   ALTER TABLE ONLY public.set_ch_firma_turleri DROP CONSTRAINT set_acc_firma_turleri_firma_turu_key;
       public         	   ths_admin    false    300            �           2606    35205 /   set_ch_firma_turleri set_acc_firma_turleri_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.set_ch_firma_turleri
    ADD CONSTRAINT set_acc_firma_turleri_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY public.set_ch_firma_turleri DROP CONSTRAINT set_acc_firma_turleri_pkey;
       public         	   ths_admin    false    300            �           2606    35207 8   set_ch_firma_tipleri set_ch_firma_tipleri_firma_tipi_key 
   CONSTRAINT     y   ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_firma_tipi_key UNIQUE (firma_tipi);
 b   ALTER TABLE ONLY public.set_ch_firma_tipleri DROP CONSTRAINT set_ch_firma_tipleri_firma_tipi_key;
       public         	   ths_admin    false    298            �           2606    35209 .   set_ch_firma_tipleri set_ch_firma_tipleri_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.set_ch_firma_tipleri DROP CONSTRAINT set_ch_firma_tipleri_pkey;
       public         	   ths_admin    false    298            �           2606    35211 7   set_ch_hesap_tipleri set_ch_hesap_tipleri_hesa_tipi_key 
   CONSTRAINT     x   ALTER TABLE ONLY public.set_ch_hesap_tipleri
    ADD CONSTRAINT set_ch_hesap_tipleri_hesa_tipi_key UNIQUE (hesap_tipi);
 a   ALTER TABLE ONLY public.set_ch_hesap_tipleri DROP CONSTRAINT set_ch_hesap_tipleri_hesa_tipi_key;
       public         	   ths_admin    false    304            �           2606    35213 .   set_ch_hesap_tipleri set_ch_hesap_tipleri_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.set_ch_hesap_tipleri
    ADD CONSTRAINT set_ch_hesap_tipleri_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.set_ch_hesap_tipleri DROP CONSTRAINT set_ch_hesap_tipleri_pkey;
       public         	   ths_admin    false    304            �           2606    35215 0   set_ch_vergi_oranlari set_ch_vergi_oranlari_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_pkey;
       public         	   ths_admin    false    306            �           2606    35217 :   set_ch_vergi_oranlari set_ch_vergi_oranlari_veri_orani_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_veri_orani_key UNIQUE (vergi_orani);
 d   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_veri_orani_key;
       public         	   ths_admin    false    306            �           2606    35219 ?   set_einv_fatura_tipleri set_einv_fatura_tipleri_fatura_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_fatura_tipleri
    ADD CONSTRAINT set_einv_fatura_tipleri_fatura_tipi_key UNIQUE (fatura_tipi);
 i   ALTER TABLE ONLY public.set_einv_fatura_tipleri DROP CONSTRAINT set_einv_fatura_tipleri_fatura_tipi_key;
       public         	   ths_admin    false    308            �           2606    35221 4   set_einv_fatura_tipleri set_einv_fatura_tipleri_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.set_einv_fatura_tipleri
    ADD CONSTRAINT set_einv_fatura_tipleri_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.set_einv_fatura_tipleri DROP CONSTRAINT set_einv_fatura_tipleri_pkey;
       public         	   ths_admin    false    308            �           2606    35223 6   set_einv_odeme_sekilleri set_einv_odeme_sekilleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.set_einv_odeme_sekilleri
    ADD CONSTRAINT set_einv_odeme_sekilleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.set_einv_odeme_sekilleri DROP CONSTRAINT set_einv_odeme_sekilleri_pkey;
       public         	   ths_admin    false    310            �           2606    35225 A   set_einv_odeme_sekilleri set_einv_odeme_sekli_odeme_sekilleri_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_odeme_sekilleri
    ADD CONSTRAINT set_einv_odeme_sekli_odeme_sekilleri_key UNIQUE (odeme_sekli);
 k   ALTER TABLE ONLY public.set_einv_odeme_sekilleri DROP CONSTRAINT set_einv_odeme_sekli_odeme_sekilleri_key;
       public         	   ths_admin    false    310            �           2606    35227 5   set_einv_paket_tipleri set_einv_paket_tipleri_kod_key 
   CONSTRAINT     o   ALTER TABLE ONLY public.set_einv_paket_tipleri
    ADD CONSTRAINT set_einv_paket_tipleri_kod_key UNIQUE (kod);
 _   ALTER TABLE ONLY public.set_einv_paket_tipleri DROP CONSTRAINT set_einv_paket_tipleri_kod_key;
       public         	   ths_admin    false    312            �           2606    35229 2   set_einv_paket_tipleri set_einv_paket_tipleri_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.set_einv_paket_tipleri
    ADD CONSTRAINT set_einv_paket_tipleri_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.set_einv_paket_tipleri DROP CONSTRAINT set_einv_paket_tipleri_pkey;
       public         	   ths_admin    false    312            �           2606    35231 8   set_einv_tasima_ucretleri set_einv_tasima_ucretleri_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.set_einv_tasima_ucretleri
    ADD CONSTRAINT set_einv_tasima_ucretleri_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.set_einv_tasima_ucretleri DROP CONSTRAINT set_einv_tasima_ucretleri_pkey;
       public         	   ths_admin    false    314            �           2606    35233 E   set_einv_tasima_ucretleri set_einv_tasima_ucretleri_tasima_ucreti_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_tasima_ucretleri
    ADD CONSTRAINT set_einv_tasima_ucretleri_tasima_ucreti_key UNIQUE (tasima_ucreti);
 o   ALTER TABLE ONLY public.set_einv_tasima_ucretleri DROP CONSTRAINT set_einv_tasima_ucretleri_tasima_ucreti_key;
       public         	   ths_admin    false    314            �           2606    35235 8   set_einv_teslim_sekilleri set_einv_teslim_sekilleri_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.set_einv_teslim_sekilleri
    ADD CONSTRAINT set_einv_teslim_sekilleri_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.set_einv_teslim_sekilleri DROP CONSTRAINT set_einv_teslim_sekilleri_pkey;
       public         	   ths_admin    false    316            �           2606    35237 D   set_einv_teslim_sekilleri set_einv_teslim_sekilleri_teslim_sekli_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_teslim_sekilleri
    ADD CONSTRAINT set_einv_teslim_sekilleri_teslim_sekli_key UNIQUE (teslim_sekli);
 n   ALTER TABLE ONLY public.set_einv_teslim_sekilleri DROP CONSTRAINT set_einv_teslim_sekilleri_teslim_sekli_key;
       public         	   ths_admin    false    316            �           2606    35239 4   set_prs_birimler set_prs_birimler_birim_bolum_id_key 
   CONSTRAINT     z   ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_birim_bolum_id_key UNIQUE (birim, bolum_id);
 ^   ALTER TABLE ONLY public.set_prs_birimler DROP CONSTRAINT set_prs_birimler_birim_bolum_id_key;
       public         	   ths_admin    false    318    318            �           2606    35241 &   set_prs_birimler set_prs_birimler_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_birimler DROP CONSTRAINT set_prs_birimler_pkey;
       public         	   ths_admin    false    318            �           2606    35243 +   set_prs_bolumler set_prs_bolumler_bolum_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.set_prs_bolumler
    ADD CONSTRAINT set_prs_bolumler_bolum_key UNIQUE (bolum);
 U   ALTER TABLE ONLY public.set_prs_bolumler DROP CONSTRAINT set_prs_bolumler_bolum_key;
       public         	   ths_admin    false    320            �           2606    35245 &   set_prs_bolumler set_prs_bolumler_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_bolumler
    ADD CONSTRAINT set_prs_bolumler_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_bolumler DROP CONSTRAINT set_prs_bolumler_pkey;
       public         	   ths_admin    false    320            �           2606    35247 1   set_prs_ehliyetler set_prs_ehliyetler_ehliyet_key 
   CONSTRAINT     o   ALTER TABLE ONLY public.set_prs_ehliyetler
    ADD CONSTRAINT set_prs_ehliyetler_ehliyet_key UNIQUE (ehliyet);
 [   ALTER TABLE ONLY public.set_prs_ehliyetler DROP CONSTRAINT set_prs_ehliyetler_ehliyet_key;
       public         	   ths_admin    false    322            �           2606    35249 *   set_prs_ehliyetler set_prs_ehliyetler_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.set_prs_ehliyetler
    ADD CONSTRAINT set_prs_ehliyetler_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.set_prs_ehliyetler DROP CONSTRAINT set_prs_ehliyetler_pkey;
       public         	   ths_admin    false    322            �           2606    35251 +   set_prs_gorevler set_prs_gorevler_gorev_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.set_prs_gorevler
    ADD CONSTRAINT set_prs_gorevler_gorev_key UNIQUE (gorev);
 U   ALTER TABLE ONLY public.set_prs_gorevler DROP CONSTRAINT set_prs_gorevler_gorev_key;
       public         	   ths_admin    false    324            �           2606    35253 &   set_prs_gorevler set_prs_gorevler_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_gorevler
    ADD CONSTRAINT set_prs_gorevler_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_gorevler DROP CONSTRAINT set_prs_gorevler_pkey;
       public         	   ths_admin    false    324            �           2606    35255 D   set_prs_lisan_seviyeleri set_prs_lisan_seviyeleri_lisan_seviyesi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri
    ADD CONSTRAINT set_prs_lisan_seviyeleri_lisan_seviyesi_key UNIQUE (lisan_seviyesi);
 n   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri DROP CONSTRAINT set_prs_lisan_seviyeleri_lisan_seviyesi_key;
       public         	   ths_admin    false    328            �           2606    35257 6   set_prs_lisan_seviyeleri set_prs_lisan_seviyeleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri
    ADD CONSTRAINT set_prs_lisan_seviyeleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri DROP CONSTRAINT set_prs_lisan_seviyeleri_pkey;
       public         	   ths_admin    false    328            �           2606    35259 +   set_prs_lisanlar set_prs_lisanlar_lisan_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.set_prs_lisanlar
    ADD CONSTRAINT set_prs_lisanlar_lisan_key UNIQUE (lisan);
 U   ALTER TABLE ONLY public.set_prs_lisanlar DROP CONSTRAINT set_prs_lisanlar_lisan_key;
       public         	   ths_admin    false    326            �           2606    35261 &   set_prs_lisanlar set_prs_lisanlar_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_lisanlar
    ADD CONSTRAINT set_prs_lisanlar_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_lisanlar DROP CONSTRAINT set_prs_lisanlar_pkey;
       public         	   ths_admin    false    326            �           2606    35263 C   set_prs_personel_tipleri set_prs_personel_tipleri_personel_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_prs_personel_tipleri
    ADD CONSTRAINT set_prs_personel_tipleri_personel_tipi_key UNIQUE (personel_tipi);
 m   ALTER TABLE ONLY public.set_prs_personel_tipleri DROP CONSTRAINT set_prs_personel_tipleri_personel_tipi_key;
       public         	   ths_admin    false    330            �           2606    35265 6   set_prs_personel_tipleri set_prs_personel_tipleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.set_prs_personel_tipleri
    ADD CONSTRAINT set_prs_personel_tipleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.set_prs_personel_tipleri DROP CONSTRAINT set_prs_personel_tipleri_pkey;
       public         	   ths_admin    false    330            �           2606    35267 ?   set_prs_tasima_servisleri set_prs_tasima_servisleri_arac_no_key 
   CONSTRAINT     }   ALTER TABLE ONLY public.set_prs_tasima_servisleri
    ADD CONSTRAINT set_prs_tasima_servisleri_arac_no_key UNIQUE (arac_no);
 i   ALTER TABLE ONLY public.set_prs_tasima_servisleri DROP CONSTRAINT set_prs_tasima_servisleri_arac_no_key;
       public         	   ths_admin    false    332                        2606    35269 8   set_prs_tasima_servisleri set_prs_tasima_servisleri_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.set_prs_tasima_servisleri
    ADD CONSTRAINT set_prs_tasima_servisleri_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.set_prs_tasima_servisleri DROP CONSTRAINT set_prs_tasima_servisleri_pkey;
       public         	   ths_admin    false    332            �           2606    35271 /   set_sls_order_status set_sat_siparis_durum_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.set_sls_order_status
    ADD CONSTRAINT set_sat_siparis_durum_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY public.set_sls_order_status DROP CONSTRAINT set_sat_siparis_durum_pkey;
       public         	   ths_admin    false    289            �           2606    35273 <   set_sls_order_status set_sat_siparis_durum_siparis_durum_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_sls_order_status
    ADD CONSTRAINT set_sat_siparis_durum_siparis_durum_key UNIQUE (siparis_durum);
 f   ALTER TABLE ONLY public.set_sls_order_status DROP CONSTRAINT set_sat_siparis_durum_siparis_durum_key;
       public         	   ths_admin    false    289                       2606    35275 .   set_sls_offer_status set_sat_teklif_durum_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.set_sls_offer_status
    ADD CONSTRAINT set_sat_teklif_durum_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.set_sls_offer_status DROP CONSTRAINT set_sat_teklif_durum_pkey;
       public         	   ths_admin    false    335                       2606    35277 :   set_sls_offer_status set_sat_teklif_durum_teklif_durum_key 
   CONSTRAINT     }   ALTER TABLE ONLY public.set_sls_offer_status
    ADD CONSTRAINT set_sat_teklif_durum_teklif_durum_key UNIQUE (teklif_durum);
 d   ALTER TABLE ONLY public.set_sls_offer_status DROP CONSTRAINT set_sat_teklif_durum_teklif_durum_key;
       public         	   ths_admin    false    335                       2606    35279 '   stk_ambarlar stk_ambarlar_ambar_adi_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.stk_ambarlar
    ADD CONSTRAINT stk_ambarlar_ambar_adi_key UNIQUE (ambar_adi);
 Q   ALTER TABLE ONLY public.stk_ambarlar DROP CONSTRAINT stk_ambarlar_ambar_adi_key;
       public         	   ths_admin    false    337                       2606    35281    stk_ambarlar stk_ambarlar_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.stk_ambarlar
    ADD CONSTRAINT stk_ambarlar_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.stk_ambarlar DROP CONSTRAINT stk_ambarlar_pkey;
       public         	   ths_admin    false    337            
           2606    35283 2   stk_cins_ozellikleri stk_cins_ozellikleri_cins_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.stk_cins_ozellikleri
    ADD CONSTRAINT stk_cins_ozellikleri_cins_key UNIQUE (cins);
 \   ALTER TABLE ONLY public.stk_cins_ozellikleri DROP CONSTRAINT stk_cins_ozellikleri_cins_key;
       public         	   ths_admin    false    338                       2606    35285 .   stk_cins_ozellikleri stk_cins_ozellikleri_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.stk_cins_ozellikleri
    ADD CONSTRAINT stk_cins_ozellikleri_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.stk_cins_ozellikleri DROP CONSTRAINT stk_cins_ozellikleri_pkey;
       public         	   ths_admin    false    338            �           2606    35287     stk_gruplar stk_gruplar_grup_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_grup_key UNIQUE (grup);
 J   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_grup_key;
       public         	   ths_admin    false    290            �           2606    35289    stk_gruplar stk_gruplar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_pkey;
       public         	   ths_admin    false    290                       2606    35291 "   stk_hareketler stk_hareketler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_pkey;
       public         	   ths_admin    false    340                       2606    35293 4   stk_kart_cins_bilgileri stk_kart_cins_bilgileri_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.stk_kart_cins_bilgileri
    ADD CONSTRAINT stk_kart_cins_bilgileri_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.stk_kart_cins_bilgileri DROP CONSTRAINT stk_kart_cins_bilgileri_pkey;
       public         	   ths_admin    false    342                       2606    35295 (   stk_kart_ozetleri stk_kart_ozetleri_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.stk_kart_ozetleri
    ADD CONSTRAINT stk_kart_ozetleri_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.stk_kart_ozetleri DROP CONSTRAINT stk_kart_ozetleri_pkey;
       public         	   ths_admin    false    344                       2606    35297 3   stk_kart_ozetleri stk_kart_ozetleri_stk_kart_id_key 
   CONSTRAINT     u   ALTER TABLE ONLY public.stk_kart_ozetleri
    ADD CONSTRAINT stk_kart_ozetleri_stk_kart_id_key UNIQUE (stk_kart_id);
 ]   ALTER TABLE ONLY public.stk_kart_ozetleri DROP CONSTRAINT stk_kart_ozetleri_stk_kart_id_key;
       public         	   ths_admin    false    344            �           2606    35299    stk_kartlar stk_kartlar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_pkey;
       public         	   ths_admin    false    291            �           2606    35301 %   stk_kartlar stk_kartlar_stok_kodu_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_stok_kodu_key UNIQUE (stok_kodu);
 O   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_stok_kodu_key;
       public         	   ths_admin    false    291                       2606    35303    stk_resimler stk_resimler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.stk_resimler
    ADD CONSTRAINT stk_resimler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.stk_resimler DROP CONSTRAINT stk_resimler_pkey;
       public         	   ths_admin    false    347                       2606    35305 )   stk_resimler stk_resimler_stk_kart_id_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.stk_resimler
    ADD CONSTRAINT stk_resimler_stk_kart_id_key UNIQUE (stk_kart_id);
 S   ALTER TABLE ONLY public.stk_resimler DROP CONSTRAINT stk_resimler_stk_kart_id_key;
       public         	   ths_admin    false    347                       2606    35307    sys_adresler sys_adresler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_adresler
    ADD CONSTRAINT sys_adresler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_adresler DROP CONSTRAINT sys_adresler_pkey;
       public         	   ths_admin    false    351                       2606    35309    sys_aylar sys_aylar_ay_adi_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.sys_aylar
    ADD CONSTRAINT sys_aylar_ay_adi_key UNIQUE (ay_adi);
 H   ALTER TABLE ONLY public.sys_aylar DROP CONSTRAINT sys_aylar_ay_adi_key;
       public         	   ths_admin    false    353                       2606    35311    sys_aylar sys_aylar_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.sys_aylar
    ADD CONSTRAINT sys_aylar_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.sys_aylar DROP CONSTRAINT sys_aylar_pkey;
       public         	   ths_admin    false    353                        2606    35313 #   sys_bolgeler sys_bolgeler_bolge_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.sys_bolgeler
    ADD CONSTRAINT sys_bolgeler_bolge_key UNIQUE (bolge);
 M   ALTER TABLE ONLY public.sys_bolgeler DROP CONSTRAINT sys_bolgeler_bolge_key;
       public         	   ths_admin    false    355            "           2606    35315    sys_bolgeler sys_bolgeler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_bolgeler
    ADD CONSTRAINT sys_bolgeler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_bolgeler DROP CONSTRAINT sys_bolgeler_pkey;
       public         	   ths_admin    false    355            $           2606    35317 >   sys_ersim_haklari sys_ersim_haklari_kaynak_id_kullanici_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kaynak_id_kullanici_id_key UNIQUE (kaynak_id, kullanici_id);
 h   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_kaynak_id_kullanici_id_key;
       public         	   ths_admin    false    358    358            &           2606    35319 (   sys_ersim_haklari sys_ersim_haklari_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_pkey;
       public         	   ths_admin    false    358            (           2606    35321 B   sys_grid_filtreler_siralamalar sys_grid_filtreler_siralamalar_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar
    ADD CONSTRAINT sys_grid_filtreler_siralamalar_pkey PRIMARY KEY (id);
 l   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar DROP CONSTRAINT sys_grid_filtreler_siralamalar_pkey;
       public         	   ths_admin    false    360            *           2606    35323 W   sys_grid_filtreler_siralamalar sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar
    ADD CONSTRAINT sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key UNIQUE (tablo_adi, is_siralama);
 �   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar DROP CONSTRAINT sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key;
       public         	   ths_admin    false    360    360            ,           2606    35325 (   sys_grid_kolonlar sys_grid_kolonlar_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.sys_grid_kolonlar DROP CONSTRAINT sys_grid_kolonlar_pkey;
       public         	   ths_admin    false    362            .           2606    35327 ;   sys_grid_kolonlar sys_grid_kolonlar_tablo_adi_kolon_adi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_tablo_adi_kolon_adi_key UNIQUE (tablo_adi, kolon_adi);
 e   ALTER TABLE ONLY public.sys_grid_kolonlar DROP CONSTRAINT sys_grid_kolonlar_tablo_adi_kolon_adi_key;
       public         	   ths_admin    false    362    362            0           2606    35329 9   sys_grid_kolonlar sys_grid_kolonlar_tablo_adi_sira_no_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_tablo_adi_sira_no_key UNIQUE (tablo_adi, sira_no);
 c   ALTER TABLE ONLY public.sys_grid_kolonlar DROP CONSTRAINT sys_grid_kolonlar_tablo_adi_sira_no_key;
       public         	   ths_admin    false    362    362            B           2606    36050 A   sys_gui_icerikler sys_gui_icerikler_kod_icerik_tipi_tablo_adi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_gui_icerikler
    ADD CONSTRAINT sys_gui_icerikler_kod_icerik_tipi_tablo_adi_key UNIQUE (kod, icerik_tipi, tablo_adi);
 k   ALTER TABLE ONLY public.sys_gui_icerikler DROP CONSTRAINT sys_gui_icerikler_kod_icerik_tipi_tablo_adi_key;
       public         	   ths_admin    false    372    372    372            D           2606    35345 (   sys_gui_icerikler sys_gui_icerikler_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.sys_gui_icerikler
    ADD CONSTRAINT sys_gui_icerikler_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.sys_gui_icerikler DROP CONSTRAINT sys_gui_icerikler_pkey;
       public         	   ths_admin    false    372            2           2606    35331 !   sys_gunler sys_gunler_gun_adi_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.sys_gunler
    ADD CONSTRAINT sys_gunler_gun_adi_key UNIQUE (gun_adi);
 K   ALTER TABLE ONLY public.sys_gunler DROP CONSTRAINT sys_gunler_gun_adi_key;
       public         	   ths_admin    false    364            4           2606    35333    sys_gunler sys_gunler_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.sys_gunler
    ADD CONSTRAINT sys_gunler_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.sys_gunler DROP CONSTRAINT sys_gunler_pkey;
       public         	   ths_admin    false    364            6           2606    35335 1   sys_kaynak_gruplari sys_kaynak_gruplari_grup_ukey 
   CONSTRAINT     l   ALTER TABLE ONLY public.sys_kaynak_gruplari
    ADD CONSTRAINT sys_kaynak_gruplari_grup_ukey UNIQUE (grup);
 [   ALTER TABLE ONLY public.sys_kaynak_gruplari DROP CONSTRAINT sys_kaynak_gruplari_grup_ukey;
       public         	   ths_admin    false    366            8           2606    35337 /   sys_kaynak_gruplari sys_kaynak_gruplari_id_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.sys_kaynak_gruplari
    ADD CONSTRAINT sys_kaynak_gruplari_id_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY public.sys_kaynak_gruplari DROP CONSTRAINT sys_kaynak_gruplari_id_pkey;
       public         	   ths_admin    false    366            :           2606    35339 +   sys_kaynaklar sys_kaynaklar_kaynak_kodu_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_kaynak_kodu_key UNIQUE (kaynak_kodu);
 U   ALTER TABLE ONLY public.sys_kaynaklar DROP CONSTRAINT sys_kaynaklar_kaynak_kodu_key;
       public         	   ths_admin    false    368            <           2606    35341     sys_kaynaklar sys_kaynaklar_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.sys_kaynaklar DROP CONSTRAINT sys_kaynaklar_pkey;
       public         	   ths_admin    false    368            J           2606    35351 D   sys_olcu_birimi_tipleri sys_olcu_birimi_tipleri_olcu_birimi_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri
    ADD CONSTRAINT sys_olcu_birimi_tipleri_olcu_birimi_tipi_key UNIQUE (olcu_birimi_tipi);
 n   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri DROP CONSTRAINT sys_olcu_birimi_tipleri_olcu_birimi_tipi_key;
       public         	   ths_admin    false    376            L           2606    35353 4   sys_olcu_birimi_tipleri sys_olcu_birimi_tipleri_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri
    ADD CONSTRAINT sys_olcu_birimi_tipleri_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri DROP CONSTRAINT sys_olcu_birimi_tipleri_pkey;
       public         	   ths_admin    false    376            F           2606    35355 /   sys_olcu_birimleri sys_olcu_birimleri_birim_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_birim_key UNIQUE (birim);
 Y   ALTER TABLE ONLY public.sys_olcu_birimleri DROP CONSTRAINT sys_olcu_birimleri_birim_key;
       public         	   ths_admin    false    374            H           2606    35357 *   sys_olcu_birimleri sys_olcu_birimleri_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.sys_olcu_birimleri DROP CONSTRAINT sys_olcu_birimleri_pkey;
       public         	   ths_admin    false    374            N           2606    35359 ,   sys_ondalik_haneler sys_ondalik_haneler_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.sys_ondalik_haneler
    ADD CONSTRAINT sys_ondalik_haneler_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.sys_ondalik_haneler DROP CONSTRAINT sys_ondalik_haneler_pkey;
       public         	   ths_admin    false    378            P           2606    35361 .   sys_para_birimleri sys_para_birimleri_para_key 
   CONSTRAINT     i   ALTER TABLE ONLY public.sys_para_birimleri
    ADD CONSTRAINT sys_para_birimleri_para_key UNIQUE (para);
 X   ALTER TABLE ONLY public.sys_para_birimleri DROP CONSTRAINT sys_para_birimleri_para_key;
       public         	   ths_admin    false    380            R           2606    35363 *   sys_para_birimleri sys_para_birimleri_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.sys_para_birimleri
    ADD CONSTRAINT sys_para_birimleri_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.sys_para_birimleri DROP CONSTRAINT sys_para_birimleri_pkey;
       public         	   ths_admin    false    380            �           2606    35365    sys_sehirler sys_sehirler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_pkey;
       public         	   ths_admin    false    292            �           2606    35367 +   sys_sehirler sys_sehirler_ulke_id_sehir_key 
   CONSTRAINT     p   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_ulke_id_sehir_key UNIQUE (ulke_id, sehir);
 U   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_ulke_id_sehir_key;
       public         	   ths_admin    false    292    292            T           2606    35369    sys_ulkeler sys_ulkeler_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.sys_ulkeler
    ADD CONSTRAINT sys_ulkeler_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.sys_ulkeler DROP CONSTRAINT sys_ulkeler_pkey;
       public         	   ths_admin    false    383            V           2606    35371 %   sys_ulkeler sys_ulkeler_ulke_kodu_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.sys_ulkeler
    ADD CONSTRAINT sys_ulkeler_ulke_kodu_key UNIQUE (ulke_kodu);
 O   ALTER TABLE ONLY public.sys_ulkeler DROP CONSTRAINT sys_ulkeler_ulke_kodu_key;
       public         	   ths_admin    false    383            >           2606    35373    sys_kullanicilar sys_users_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_pkey PRIMARY KEY (id);
 I   ALTER TABLE ONLY public.sys_kullanicilar DROP CONSTRAINT sys_users_pkey;
       public         	   ths_admin    false    370            @           2606    35375 '   sys_kullanicilar sys_users_username_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_username_key UNIQUE (kullanici_adi);
 Q   ALTER TABLE ONLY public.sys_kullanicilar DROP CONSTRAINT sys_users_username_key;
       public         	   ths_admin    false    370            X           2606    35377 0   sys_uygulama_ayarlari sys_uygulama_ayarlari_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_pkey;
       public         	   ths_admin    false    385            q           2606    35383 ,   urt_iscilikler urt_iscilikler_gider_kodu_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_gider_kodu_key UNIQUE (gider_kodu);
 V   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_gider_kodu_key;
       public         	   ths_admin    false    257            s           2606    35385 "   urt_iscilikler urt_iscilikler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_pkey;
       public         	   ths_admin    false    257            u           2606    35387 >   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_pkey;
       public         	   ths_admin    false    259            w           2606    35389 Q   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_stok_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_header_id_key UNIQUE (stok_kodu, header_id);
 {   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_header_id_key;
       public         	   ths_admin    false    259    259            y           2606    35391 9   urt_paket_hammaddeler urt_paket_hammaddeler_paket_adi_key 
   CONSTRAINT     y   ALTER TABLE ONLY public.urt_paket_hammaddeler
    ADD CONSTRAINT urt_paket_hammaddeler_paket_adi_key UNIQUE (paket_adi);
 c   ALTER TABLE ONLY public.urt_paket_hammaddeler DROP CONSTRAINT urt_paket_hammaddeler_paket_adi_key;
       public         	   ths_admin    false    261            {           2606    35393 0   urt_paket_hammaddeler urt_paket_hammaddeler_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.urt_paket_hammaddeler
    ADD CONSTRAINT urt_paket_hammaddeler_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.urt_paket_hammaddeler DROP CONSTRAINT urt_paket_hammaddeler_pkey;
       public         	   ths_admin    false    261            }           2606    35395 <   urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_pkey PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_paket_iscilik_detaylari_pkey;
       public         	   ths_admin    false    263            �           2606    35397 7   urt_paket_iscilikler urt_paket_iscilikler_paket_adi_key 
   CONSTRAINT     w   ALTER TABLE ONLY public.urt_paket_iscilikler
    ADD CONSTRAINT urt_paket_iscilikler_paket_adi_key UNIQUE (paket_adi);
 a   ALTER TABLE ONLY public.urt_paket_iscilikler DROP CONSTRAINT urt_paket_iscilikler_paket_adi_key;
       public         	   ths_admin    false    265            �           2606    35399 .   urt_paket_iscilikler urt_paket_iscilikler_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.urt_paket_iscilikler
    ADD CONSTRAINT urt_paket_iscilikler_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.urt_paket_iscilikler DROP CONSTRAINT urt_paket_iscilikler_pkey;
       public         	   ths_admin    false    265            �           2606    35401 2   urt_recete_hammaddeler urt_recete_hammaddeler_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_pkey;
       public         	   ths_admin    false    267            �           2606    35403 E   urt_recete_hammaddeler urt_recete_hammaddeler_stok_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_stok_kodu_header_id_key UNIQUE (stok_kodu, header_id);
 o   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_stok_kodu_header_id_key;
       public         	   ths_admin    false    267    267            �           2606    35405 <   urt_recete_iscilikler urt_recete_iscilikler_iscilik_kodu_key 
   CONSTRAINT        ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_iscilik_kodu_key UNIQUE (iscilik_kodu);
 f   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_iscilik_kodu_key;
       public         	   ths_admin    false    271            �           2606    35407 0   urt_recete_iscilikler urt_recete_iscilikler_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_pkey;
       public         	   ths_admin    false    271            �           2606    35409 P   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_header_id_paket_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_header_id_paket_id_key UNIQUE (header_id, paket_id);
 z   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_header_id_paket_id_key;
       public         	   ths_admin    false    273    273            �           2606    35411 >   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_pkey;
       public         	   ths_admin    false    273                       2606    35413 Y   urt_paket_iscilik_detaylari urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key UNIQUE (iscilik_kodu, header_id);
 �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key;
       public         	   ths_admin    false    263    263            �           2606    35415 N   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_header_id_paket_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_header_id_paket_id_key UNIQUE (header_id, paket_id);
 x   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_header_id_paket_id_key;
       public         	   ths_admin    false    275    275            �           2606    35417 <   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_pkey PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_pkey;
       public         	   ths_admin    false    275            Z           2606    35419 2   urt_recete_yan_urunler urt_recete_yan_urunler_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_pkey;
       public         	   ths_admin    false    390            \           2606    35421 E   urt_recete_yan_urunler urt_recete_yan_urunler_urun_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_urun_kodu_header_id_key UNIQUE (urun_kodu, header_id);
 o   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_urun_kodu_header_id_key;
       public         	   ths_admin    false    390    390            �           2606    35423     urt_receteler urt_receteler_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.urt_receteler DROP CONSTRAINT urt_receteler_pkey;
       public         	   ths_admin    false    269            �           2606    35425 2   urt_receteler urt_receteler_urun_kodu_urun_adi_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_urun_kodu_urun_adi_key UNIQUE (urun_kodu, urun_adi);
 \   ALTER TABLE ONLY public.urt_receteler DROP CONSTRAINT urt_receteler_urun_kodu_urun_adi_key;
       public         	   ths_admin    false    269    269            ;           1259    35426 "   idx_als_teklif_detaylari_header_id    INDEX     h   CREATE INDEX idx_als_teklif_detaylari_header_id ON public.als_teklif_detaylari USING btree (header_id);
 6   DROP INDEX public.idx_als_teklif_detaylari_header_id;
       public         	   ths_admin    false    227            �           1259    35427 #   idx_sat_siparis_detaylari_header_id    INDEX     j   CREATE INDEX idx_sat_siparis_detaylari_header_id ON public.sat_siparis_detaylari USING btree (header_id);
 7   DROP INDEX public.idx_sat_siparis_detaylari_header_id;
       public         	   ths_admin    false    285            �           1259    35428    idx_sat_siparis_musteri_kodu    INDEX     _   CREATE INDEX idx_sat_siparis_musteri_kodu ON public.sat_siparisler USING btree (musteri_kodu);
 0   DROP INDEX public.idx_sat_siparis_musteri_kodu;
       public         	   ths_admin    false    287            �           1259    35429 "   idx_sat_teklif_detaylari_header_id    INDEX     h   CREATE INDEX idx_sat_teklif_detaylari_header_id ON public.sat_teklif_detaylari USING btree (header_id);
 6   DROP INDEX public.idx_sat_teklif_detaylari_header_id;
       public         	   ths_admin    false    294            �           2620    35430    set_prs_bolumler audit    TRIGGER        CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_bolumler FOR EACH ROW EXECUTE FUNCTION public.audit();
 /   DROP TRIGGER audit ON public.set_prs_bolumler;
       public       	   ths_admin    false    505    320            �           2620    35431    prs_ehliyetler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prs_ehliyetler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 .   DROP TRIGGER notify ON public.prs_ehliyetler;
       public       	   ths_admin    false    251    395            �           2620    35432    prs_lisan_bilgileri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prs_lisan_bilgileri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 3   DROP TRIGGER notify ON public.prs_lisan_bilgileri;
       public       	   ths_admin    false    252    395            �           2620    35433    prs_personeller notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prs_personeller FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER notify ON public.prs_personeller;
       public       	   ths_admin    false    255    395            �           2620    35434    set_prs_birimler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_birimler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 0   DROP TRIGGER notify ON public.set_prs_birimler;
       public       	   ths_admin    false    318    395            �           2620    35435    set_prs_ehliyetler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_ehliyetler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 2   DROP TRIGGER notify ON public.set_prs_ehliyetler;
       public       	   ths_admin    false    395    322            �           2620    35436    set_prs_gorevler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_gorevler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 0   DROP TRIGGER notify ON public.set_prs_gorevler;
       public       	   ths_admin    false    324    395            �           2620    35437    set_prs_lisan_seviyeleri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_lisan_seviyeleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER notify ON public.set_prs_lisan_seviyeleri;
       public       	   ths_admin    false    328    395            �           2620    35438    set_prs_lisanlar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_lisanlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 0   DROP TRIGGER notify ON public.set_prs_lisanlar;
       public       	   ths_admin    false    326    395            �           2620    35439    set_prs_personel_tipleri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_personel_tipleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER notify ON public.set_prs_personel_tipleri;
       public       	   ths_admin    false    330    395            �           2620    35440     set_prs_tasima_servisleri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_tasima_servisleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER notify ON public.set_prs_tasima_servisleri;
       public       	   ths_admin    false    332    395            �           2620    35441    stk_ambarlar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_ambarlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 ,   DROP TRIGGER notify ON public.stk_ambarlar;
       public       	   ths_admin    false    337    395            �           2620    35442    stk_gruplar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_gruplar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 +   DROP TRIGGER notify ON public.stk_gruplar;
       public       	   ths_admin    false    290    395            �           2620    35443    stk_hareketler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_hareketler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 .   DROP TRIGGER notify ON public.stk_hareketler;
       public       	   ths_admin    false    340    395            �           2620    35444    stk_kart_cins_bilgileri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_kart_cins_bilgileri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 7   DROP TRIGGER notify ON public.stk_kart_cins_bilgileri;
       public       	   ths_admin    false    342    395            �           2620    35445    stk_kartlar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_kartlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 +   DROP TRIGGER notify ON public.stk_kartlar;
       public       	   ths_admin    false    395    291            �           2620    35446 1   sys_grid_kolonlar sys_grid_col_width_table_notify    TRIGGER     �   CREATE TRIGGER sys_grid_col_width_table_notify AFTER INSERT OR DELETE OR UPDATE ON public.sys_grid_kolonlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 J   DROP TRIGGER sys_grid_col_width_table_notify ON public.sys_grid_kolonlar;
       public       	   ths_admin    false    362    395            �           2620    35447    set_prs_bolumler table_notify    TRIGGER     �   CREATE TRIGGER table_notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_bolumler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 6   DROP TRIGGER table_notify ON public.set_prs_bolumler;
       public       	   ths_admin    false    320    395            �           2620    35448 !   stk_cins_ozellikleri table_notify    TRIGGER     �   CREATE TRIGGER table_notify BEFORE INSERT OR DELETE OR UPDATE ON public.stk_cins_ozellikleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 :   DROP TRIGGER table_notify ON public.stk_cins_ozellikleri;
       public       	   ths_admin    false    338    395            �           2620    35449    ch_banka_subeleri trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_banka_subeleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 5   DROP TRIGGER trg_notify ON public.ch_banka_subeleri;
       public       	   ths_admin    false    235    395            �           2620    35450    ch_bankalar trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_bankalar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER trg_notify ON public.ch_bankalar;
       public       	   ths_admin    false    233    395            �           2620    35451    ch_bolgeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_bolgeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER trg_notify ON public.ch_bolgeler;
       public       	   ths_admin    false    237    395            �           2620    35452    ch_doviz_kurlari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_doviz_kurlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 4   DROP TRIGGER trg_notify ON public.ch_doviz_kurlari;
       public       	   ths_admin    false    239    395            �           2620    35453    ch_hesaplar trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_hesaplar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER trg_notify ON public.ch_hesaplar;
       public       	   ths_admin    false    241    395            �           2620    35454    mhs_fis_detaylari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.mhs_fis_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 5   DROP TRIGGER trg_notify ON public.mhs_fis_detaylari;
       public       	   ths_admin    false    245    395            �           2620    35455    mhs_fisler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.mhs_fisler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 .   DROP TRIGGER trg_notify ON public.mhs_fisler;
       public       	   ths_admin    false    247    395            �           2620    35456    mhs_transfer_kodlari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.mhs_transfer_kodlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER trg_notify ON public.mhs_transfer_kodlari;
       public       	   ths_admin    false    249    395            �           2620    35457     set_ch_vergi_oranlari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.set_ch_vergi_oranlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER trg_notify ON public.set_ch_vergi_oranlari;
       public       	   ths_admin    false    306    395            �           2620    35458    urt_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 2   DROP TRIGGER trg_notify ON public.urt_iscilikler;
       public       	   ths_admin    false    257    395            �           2620    35459 '   urt_paket_hammadde_detaylari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_hammadde_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 @   DROP TRIGGER trg_notify ON public.urt_paket_hammadde_detaylari;
       public       	   ths_admin    false    259    395            �           2620    35460     urt_paket_hammaddeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER trg_notify ON public.urt_paket_hammaddeler;
       public       	   ths_admin    false    261    395            �           2620    35461 &   urt_paket_iscilik_detaylari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_iscilik_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 ?   DROP TRIGGER trg_notify ON public.urt_paket_iscilik_detaylari;
       public       	   ths_admin    false    263    395            �           2620    35462    urt_paket_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER trg_notify ON public.urt_paket_iscilikler;
       public       	   ths_admin    false    395    265            �           2620    35463 !   urt_recete_hammaddeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 :   DROP TRIGGER trg_notify ON public.urt_recete_hammaddeler;
       public       	   ths_admin    false    395    267            �           2620    35464     urt_recete_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER trg_notify ON public.urt_recete_iscilikler;
       public       	   ths_admin    false    395    271            �           2620    35465 '   urt_recete_paket_hammaddeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_paket_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 @   DROP TRIGGER trg_notify ON public.urt_recete_paket_hammaddeler;
       public       	   ths_admin    false    395    273            �           2620    35466 &   urt_recete_paket_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_paket_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 ?   DROP TRIGGER trg_notify ON public.urt_recete_paket_iscilikler;
       public       	   ths_admin    false    275    395            �           2620    35467 !   urt_recete_yan_urunler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_yan_urunler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 :   DROP TRIGGER trg_notify ON public.urt_recete_yan_urunler;
       public       	   ths_admin    false    390    395            �           2620    35468    urt_receteler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_receteler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 1   DROP TRIGGER trg_notify ON public.urt_receteler;
       public       	   ths_admin    false    269    395            ]           2606    35469 8   als_teklif_detaylari als_teklif_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.als_teklifler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.als_teklif_detaylari DROP CONSTRAINT als_teklif_detaylari_header_id_fkey;
       public       	   ths_admin    false    5437    227    229            ^           2606    35474 :   als_teklif_detaylari als_teklif_detaylari_olcu_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_olcu_birimi_fkey FOREIGN KEY (olcu_birimi) REFERENCES public.sys_olcu_birimleri(birim) ON UPDATE CASCADE ON DELETE RESTRICT;
 d   ALTER TABLE ONLY public.als_teklif_detaylari DROP CONSTRAINT als_teklif_detaylari_olcu_birimi_fkey;
       public       	   ths_admin    false    374    227    5702            _           2606    35479 C   als_teklif_detaylari als_teklif_detaylari_referans_ana_urun_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.als_teklif_detaylari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 m   ALTER TABLE ONLY public.als_teklif_detaylari DROP CONSTRAINT als_teklif_detaylari_referans_ana_urun_id_fkey;
       public       	   ths_admin    false    227    5434    227            `           2606    35484 8   als_teklif_detaylari als_teklif_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklif_detaylari
    ADD CONSTRAINT als_teklif_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 b   ALTER TABLE ONLY public.als_teklif_detaylari DROP CONSTRAINT als_teklif_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    227    5553    291            a           2606    35489 .   als_teklifler als_teklifler_islem_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_islem_tipi_id_fkey FOREIGN KEY (islem_tipi_id) REFERENCES public.set_einv_fatura_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_islem_tipi_id_fkey;
       public       	   ths_admin    false    229    5584    308            b           2606    35494 -   als_teklifler als_teklifler_musteri_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_musteri_kodu_fkey FOREIGN KEY (musteri_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_musteri_kodu_fkey;
       public       	   ths_admin    false    241    229    5463            c           2606    35499 ,   als_teklifler als_teklifler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 V   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_para_birimi_fkey;
       public       	   ths_admin    false    380    5712    229            d           2606    35504 )   als_teklifler als_teklifler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_sehir_id_fkey;
       public       	   ths_admin    false    292    229    5555            e           2606    35509 (   als_teklifler als_teklifler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.als_teklifler
    ADD CONSTRAINT als_teklifler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 R   ALTER TABLE ONLY public.als_teklifler DROP CONSTRAINT als_teklifler_ulke_id_fkey;
       public       	   ths_admin    false    5716    383    229            f           2606    35514 1   ch_banka_subeleri ch_banka_subeleri_banka_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_banka_id_fkey FOREIGN KEY (banka_id) REFERENCES public.ch_bankalar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_banka_id_fkey;
       public       	   ths_admin    false    233    235    5445            g           2606    35519 1   ch_banka_subeleri ch_banka_subeleri_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_sehir_id_fkey;
       public       	   ths_admin    false    235    5555    292            h           2606    35524 +   ch_doviz_kurlari ch_doviz_kurlari_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_para_fkey FOREIGN KEY (para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE CASCADE;
 U   ALTER TABLE ONLY public.ch_doviz_kurlari DROP CONSTRAINT ch_doviz_kurlari_para_fkey;
       public       	   ths_admin    false    239    5712    380            i           2606    35529 %   ch_hesaplar ch_hesaplar_bolge_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_bolge_id_fkey FOREIGN KEY (bolge_id) REFERENCES public.ch_hesap_planlari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 O   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_bolge_id_fkey;
       public       	   ths_admin    false    241    5467    243            j           2606    35534 $   ch_hesaplar ch_hesaplar_grup_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_grup_id_fkey FOREIGN KEY (grup_id) REFERENCES public.ch_gruplar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 N   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_grup_id_fkey;
       public       	   ths_admin    false    241    5461    240            k           2606    35539 *   ch_hesaplar ch_hesaplar_hesap_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_hesap_tipi_id_fkey FOREIGN KEY (hesap_tipi_id) REFERENCES public.set_ch_hesap_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 T   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_hesap_tipi_id_fkey;
       public       	   ths_admin    false    241    5576    304            l           2606    35549 2   mhs_fis_detaylari mhs_fis_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mhs_fis_detaylari
    ADD CONSTRAINT mhs_fis_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.mhs_fisler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.mhs_fis_detaylari DROP CONSTRAINT mhs_fis_detaylari_header_id_fkey;
       public       	   ths_admin    false    245    5471    247            m           2606    35554 9   mhs_transfer_kodlari mhs_transfer_kodlari_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mhs_transfer_kodlari
    ADD CONSTRAINT mhs_transfer_kodlari_hesap_kodu_fkey FOREIGN KEY (hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 c   ALTER TABLE ONLY public.mhs_transfer_kodlari DROP CONSTRAINT mhs_transfer_kodlari_hesap_kodu_fkey;
       public       	   ths_admin    false    249    5463    241            n           2606    35559 -   prs_ehliyetler prs_ehliyetler_ehliyet_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_ehliyet_id_fkey FOREIGN KEY (ehliyet_id) REFERENCES public.set_prs_ehliyetler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 W   ALTER TABLE ONLY public.prs_ehliyetler DROP CONSTRAINT prs_ehliyetler_ehliyet_id_fkey;
       public       	   ths_admin    false    251    5612    322            o           2606    35564 .   prs_ehliyetler prs_ehliyetler_personel_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_personel_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE CASCADE;
 X   ALTER TABLE ONLY public.prs_ehliyetler DROP CONSTRAINT prs_ehliyetler_personel_id_fkey;
       public       	   ths_admin    false    251    5487    255            p           2606    35569 7   prs_lisan_bilgileri prs_lisan_bilgileri_konusma_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_konusma_id_fkey FOREIGN KEY (konusma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;
 a   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_konusma_id_fkey;
       public       	   ths_admin    false    252    5624    328            q           2606    35574 5   prs_lisan_bilgileri prs_lisan_bilgileri_lisan_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_lisan_id_fkey FOREIGN KEY (lisan_id) REFERENCES public.set_prs_lisanlar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_lisan_id_fkey;
       public       	   ths_admin    false    252    5620    326            r           2606    35579 5   prs_lisan_bilgileri prs_lisan_bilgileri_okuma_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_okuma_id_fkey FOREIGN KEY (okuma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_okuma_id_fkey;
       public       	   ths_admin    false    252    5624    328            s           2606    35584 8   prs_lisan_bilgileri prs_lisan_bilgileri_personel_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_personel_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_personel_id_fkey;
       public       	   ths_admin    false    252    5487    255            t           2606    35589 5   prs_lisan_bilgileri prs_lisan_bilgileri_yazma_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_yazma_id_fkey FOREIGN KEY (yazma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_yazma_id_fkey;
       public       	   ths_admin    false    252    5624    328            u           2606    35594 -   prs_personeller prs_personeller_adres_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_adres_id_fkey FOREIGN KEY (adres_id) REFERENCES public.sys_adresler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 W   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_adres_id_fkey;
       public       	   ths_admin    false    255    5658    351            v           2606    35599 -   prs_personeller prs_personeller_birim_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_birim_id_fkey FOREIGN KEY (birim_id) REFERENCES public.set_prs_birimler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 W   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_birim_id_fkey;
       public       	   ths_admin    false    255    5604    318            w           2606    35604 -   prs_personeller prs_personeller_gorev_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_gorev_id_fkey FOREIGN KEY (gorev_id) REFERENCES public.set_prs_gorevler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 W   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_gorev_id_fkey;
       public       	   ths_admin    false    255    5616    324            x           2606    35609 5   prs_personeller prs_personeller_personel_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_personel_tipi_id_fkey FOREIGN KEY (personel_tipi_id) REFERENCES public.set_prs_personel_tipleri(id) ON UPDATE CASCADE ON DELETE SET NULL;
 _   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_personel_tipi_id_fkey;
       public       	   ths_admin    false    255    5628    330            y           2606    35614 5   prs_personeller prs_personeller_tasima_servis_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_tasima_servis_id_fkey FOREIGN KEY (tasima_servis_id) REFERENCES public.set_prs_tasima_servisleri(id) ON UPDATE CASCADE ON DELETE SET NULL;
 _   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_tasima_servis_id_fkey;
       public       	   ths_admin    false    255    5632    332            �           2606    35619 8   sat_fatura_detaylari sat_fatura_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_fatura_detaylari
    ADD CONSTRAINT sat_fatura_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_faturalar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.sat_fatura_detaylari DROP CONSTRAINT sat_fatura_detaylari_header_id_fkey;
       public       	   ths_admin    false    277    5531    279            �           2606    35624 <   sat_irsaliye_detaylari sat_irsaliye_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_irsaliye_detaylari
    ADD CONSTRAINT sat_irsaliye_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_irsaliyeler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.sat_irsaliye_detaylari DROP CONSTRAINT sat_irsaliye_detaylari_header_id_fkey;
       public       	   ths_admin    false    283    5535    281            �           2606    35629 :   sat_siparis_detaylari sat_siparis_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_siparisler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 d   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_header_id_fkey;
       public       	   ths_admin    false    287    5541    285            �           2606    35634 <   sat_siparis_detaylari sat_siparis_detaylari_olcu_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_olcu_birimi_fkey FOREIGN KEY (olcu_birimi) REFERENCES public.sys_olcu_birimleri(birim) ON UPDATE CASCADE ON DELETE RESTRICT;
 f   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_olcu_birimi_fkey;
       public       	   ths_admin    false    374    5702    285            �           2606    35639 E   sat_siparis_detaylari sat_siparis_detaylari_referans_ana_urun_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.sat_siparis_detaylari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 o   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_referans_ana_urun_id_fkey;
       public       	   ths_admin    false    285    285    5538            �           2606    35644 :   sat_siparis_detaylari sat_siparis_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 d   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    5553    285    291            �           2606    35649 0   sat_siparisler sat_siparisler_islem_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_islem_tipi_id_fkey FOREIGN KEY (islem_tipi_id) REFERENCES public.set_einv_fatura_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_islem_tipi_id_fkey;
       public       	   ths_admin    false    308    287    5584            �           2606    35654 /   sat_siparisler sat_siparisler_musteri_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_musteri_kodu_fkey FOREIGN KEY (musteri_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_musteri_kodu_fkey;
       public       	   ths_admin    false    5463    287    241            �           2606    35659 8   sat_siparisler sat_siparisler_musteri_temsilcisi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_musteri_temsilcisi_id_fkey FOREIGN KEY (musteri_temsilcisi_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 b   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_musteri_temsilcisi_id_fkey;
       public       	   ths_admin    false    255    287    5487            �           2606    35664 4   sat_siparisler sat_siparisler_nakliye_ucreti_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_nakliye_ucreti_id_fkey FOREIGN KEY (tasima_ucreti_id) REFERENCES public.set_einv_tasima_ucretleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 ^   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_nakliye_ucreti_id_fkey;
       public       	   ths_admin    false    287    314    5594            �           2606    35669 1   sat_siparisler sat_siparisler_odeme_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_odeme_sekli_id_fkey FOREIGN KEY (odeme_sekli_id) REFERENCES public.set_einv_odeme_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_odeme_sekli_id_fkey;
       public       	   ths_admin    false    5586    310    287            �           2606    35674 0   sat_siparisler sat_siparisler_paket_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_paket_tipi_id_fkey FOREIGN KEY (paket_tipi_id) REFERENCES public.set_einv_paket_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_paket_tipi_id_fkey;
       public       	   ths_admin    false    5592    312    287            �           2606    35679 .   sat_siparisler sat_siparisler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_para_birimi_fkey;
       public       	   ths_admin    false    5712    380    287            �           2606    35684 +   sat_siparisler sat_siparisler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 U   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_sehir_id_fkey;
       public       	   ths_admin    false    5555    292    287            �           2606    35689 3   sat_siparisler sat_siparisler_siparis_durum_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_siparis_durum_id_fkey FOREIGN KEY (siparis_durum_id) REFERENCES public.set_sls_order_status(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 ]   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_siparis_durum_id_fkey;
       public       	   ths_admin    false    287    5543    289            �           2606    35694 2   sat_siparisler sat_siparisler_teslim_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_teslim_sekli_id_fkey FOREIGN KEY (teslim_sekli_id) REFERENCES public.set_einv_teslim_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 \   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_teslim_sekli_id_fkey;
       public       	   ths_admin    false    316    287    5598            �           2606    35699 *   sat_siparisler sat_siparisler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 T   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_ulke_id_fkey;
       public       	   ths_admin    false    287    383    5716            �           2606    35704 8   sat_teklif_detaylari sat_teklif_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_teklifler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_header_id_fkey;
       public       	   ths_admin    false    296    294    5564            �           2606    35709 :   sat_teklif_detaylari sat_teklif_detaylari_olcu_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_olcu_birimi_fkey FOREIGN KEY (olcu_birimi) REFERENCES public.sys_olcu_birimleri(birim) ON UPDATE CASCADE ON DELETE RESTRICT;
 d   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_olcu_birimi_fkey;
       public       	   ths_admin    false    5702    294    374            �           2606    35714 C   sat_teklif_detaylari sat_teklif_detaylari_referans_ana_urun_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.sat_teklif_detaylari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 m   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_referans_ana_urun_id_fkey;
       public       	   ths_admin    false    294    5560    294            �           2606    35719 8   sat_teklif_detaylari sat_teklif_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 b   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    5553    294    291            �           2606    35724 .   sat_teklifler sat_teklifler_islem_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_islem_tipi_id_fkey FOREIGN KEY (islem_tipi_id) REFERENCES public.set_einv_fatura_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_islem_tipi_id_fkey;
       public       	   ths_admin    false    296    308    5584            �           2606    35729 -   sat_teklifler sat_teklifler_musteri_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_musteri_kodu_fkey FOREIGN KEY (musteri_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_musteri_kodu_fkey;
       public       	   ths_admin    false    241    296    5463            �           2606    35734 6   sat_teklifler sat_teklifler_musteri_temsilcisi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_musteri_temsilcisi_id_fkey FOREIGN KEY (musteri_temsilcisi_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 `   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_musteri_temsilcisi_id_fkey;
       public       	   ths_admin    false    255    5487    296            �           2606    35739 2   sat_teklifler sat_teklifler_nakliye_ucreti_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_nakliye_ucreti_id_fkey FOREIGN KEY (tasima_ucreti_id) REFERENCES public.set_einv_tasima_ucretleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 \   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_nakliye_ucreti_id_fkey;
       public       	   ths_admin    false    296    5594    314            �           2606    35744 /   sat_teklifler sat_teklifler_odeme_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_odeme_sekli_id_fkey FOREIGN KEY (odeme_sekli_id) REFERENCES public.set_einv_odeme_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_odeme_sekli_id_fkey;
       public       	   ths_admin    false    310    296    5586            �           2606    35749 .   sat_teklifler sat_teklifler_paket_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_paket_tipi_id_fkey FOREIGN KEY (paket_tipi_id) REFERENCES public.set_einv_paket_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_paket_tipi_id_fkey;
       public       	   ths_admin    false    5592    296    312            �           2606    35754 ,   sat_teklifler sat_teklifler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 V   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_para_birimi_fkey;
       public       	   ths_admin    false    5712    296    380            �           2606    35759 )   sat_teklifler sat_teklifler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_sehir_id_fkey;
       public       	   ths_admin    false    5555    296    292            �           2606    35764 0   sat_teklifler sat_teklifler_teslim_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_teslim_sekli_id_fkey FOREIGN KEY (teslim_sekli_id) REFERENCES public.set_einv_teslim_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_teslim_sekli_id_fkey;
       public       	   ths_admin    false    5598    296    316            �           2606    35769 (   sat_teklifler sat_teklifler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 R   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_ulke_id_fkey;
       public       	   ths_admin    false    296    5716    383            �           2606    35774 <   set_ch_firma_tipleri set_ch_firma_tipleri_firma_turu_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_firma_turu_id_fkey FOREIGN KEY (firma_turu_id) REFERENCES public.set_ch_firma_turleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 f   ALTER TABLE ONLY public.set_ch_firma_tipleri DROP CONSTRAINT set_ch_firma_tipleri_firma_turu_id_fkey;
       public       	   ths_admin    false    300    5572    298            �           2606    35779 @   set_ch_vergi_oranlari set_ch_vergi_oranlari_alis_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_alis_hesap_kodu_fkey FOREIGN KEY (alis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 j   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_alis_hesap_kodu_fkey;
       public       	   ths_admin    false    5463    241    306            �           2606    35784 E   set_ch_vergi_oranlari set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey FOREIGN KEY (alis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 o   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    241    306    5463            �           2606    35789 A   set_ch_vergi_oranlari set_ch_vergi_oranlari_satis_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_satis_hesap_kodu_fkey FOREIGN KEY (satis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 k   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_satis_hesap_kodu_fkey;
       public       	   ths_admin    false    241    5463    306            �           2606    35794 F   set_ch_vergi_oranlari set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey FOREIGN KEY (satis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 p   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    5463    241    306            �           2606    35799 /   set_prs_birimler set_prs_birimler_bolum_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_bolum_id_fkey FOREIGN KEY (bolum_id) REFERENCES public.set_prs_bolumler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.set_prs_birimler DROP CONSTRAINT set_prs_birimler_bolum_id_fkey;
       public       	   ths_admin    false    5608    320    318            �           2606    35804 9   stk_gruplar stk_gruplar_hammadde_kullanim_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_hammadde_kullanim_hesap_kodu_fkey FOREIGN KEY (hammadde_kullanim_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 c   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_hammadde_kullanim_hesap_kodu_fkey;
       public       	   ths_admin    false    5463    290    241            �           2606    35809 5   stk_gruplar stk_gruplar_hammadde_stok_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_hammadde_stok_hesap_kodu_fkey FOREIGN KEY (hammadde_stok_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 _   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_hammadde_stok_hesap_kodu_fkey;
       public       	   ths_admin    false    290    241    5463            �           2606    35814 2   stk_gruplar stk_gruplar_yari_mamul_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_yari_mamul_hesap_kodu_fkey FOREIGN KEY (yari_mamul_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 \   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_yari_mamul_hesap_kodu_fkey;
       public       	   ths_admin    false    5463    290    241            �           2606    35819 0   stk_hareketler stk_hareketler_alan_ambar_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_alan_ambar_id_fkey FOREIGN KEY (alan_ambar_id) REFERENCES public.stk_ambarlar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_alan_ambar_id_fkey;
       public       	   ths_admin    false    337    5640    340            �           2606    35824 .   stk_hareketler stk_hareketler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_para_birimi_fkey;
       public       	   ths_admin    false    340    380    5712            �           2606    35829 ,   stk_hareketler stk_hareketler_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 V   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_stok_kodu_fkey;
       public       	   ths_admin    false    5553    291    340            �           2606    35834 1   stk_hareketler stk_hareketler_veren_ambar_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_veren_ambar_id_fkey FOREIGN KEY (veren_ambar_id) REFERENCES public.stk_ambarlar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_veren_ambar_id_fkey;
       public       	   ths_admin    false    340    5640    337            �           2606    35839 <   stk_kart_cins_bilgileri stk_kart_cins_bilgileri_cins_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kart_cins_bilgileri
    ADD CONSTRAINT stk_kart_cins_bilgileri_cins_id_fkey FOREIGN KEY (cins_id) REFERENCES public.stk_cins_ozellikleri(id) ON UPDATE CASCADE ON DELETE SET NULL;
 f   ALTER TABLE ONLY public.stk_kart_cins_bilgileri DROP CONSTRAINT stk_kart_cins_bilgileri_cins_id_fkey;
       public       	   ths_admin    false    5644    338    342            �           2606    35844 @   stk_kart_cins_bilgileri stk_kart_cins_bilgileri_stk_kart_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kart_cins_bilgileri
    ADD CONSTRAINT stk_kart_cins_bilgileri_stk_kart_id_fkey FOREIGN KEY (stk_kart_id) REFERENCES public.stk_kartlar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 j   ALTER TABLE ONLY public.stk_kart_cins_bilgileri DROP CONSTRAINT stk_kart_cins_bilgileri_stk_kart_id_fkey;
       public       	   ths_admin    false    5551    291    342            �           2606    35849 4   stk_kart_ozetleri stk_kart_ozetleri_stk_kart_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kart_ozetleri
    ADD CONSTRAINT stk_kart_ozetleri_stk_kart_id_fkey FOREIGN KEY (stk_kart_id) REFERENCES public.stk_kartlar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.stk_kart_ozetleri DROP CONSTRAINT stk_kart_ozetleri_stk_kart_id_fkey;
       public       	   ths_admin    false    291    5551    344            �           2606    35854 &   stk_kartlar stk_kartlar_alis_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_alis_para_fkey FOREIGN KEY (alis_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 P   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_alis_para_fkey;
       public       	   ths_admin    false    291    380    5712            �           2606    35859 '   stk_kartlar stk_kartlar_ihrac_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_ihrac_para_fkey FOREIGN KEY (ihrac_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_ihrac_para_fkey;
       public       	   ths_admin    false    380    291    5712            �           2606    35864 &   stk_kartlar stk_kartlar_mensei_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_mensei_id_fkey FOREIGN KEY (mensei_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 P   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_mensei_id_fkey;
       public       	   ths_admin    false    5716    383    291            �           2606    35869 +   stk_kartlar stk_kartlar_olcu_birimi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_olcu_birimi_id_fkey FOREIGN KEY (olcu_birimi_id) REFERENCES public.sys_olcu_birimleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 U   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_olcu_birimi_id_fkey;
       public       	   ths_admin    false    374    291    5704            �           2606    35874 '   stk_kartlar stk_kartlar_satis_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_satis_para_fkey FOREIGN KEY (satis_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_satis_para_fkey;
       public       	   ths_admin    false    380    291    5712            �           2606    35879 *   stk_kartlar stk_kartlar_stok_grubu_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_stok_grubu_id_fkey FOREIGN KEY (stok_grubu_id) REFERENCES public.stk_gruplar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 T   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_stok_grubu_id_fkey;
       public       	   ths_admin    false    5549    291    290            �           2606    35884 *   stk_resimler stk_resimler_stk_kart_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_resimler
    ADD CONSTRAINT stk_resimler_stk_kart_id_fkey FOREIGN KEY (stk_kart_id) REFERENCES public.stk_kartlar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stk_resimler DROP CONSTRAINT stk_resimler_stk_kart_id_fkey;
       public       	   ths_admin    false    291    347    5551            �           2606    35889 '   sys_adresler sys_adresler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_adresler
    ADD CONSTRAINT sys_adresler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.sys_adresler DROP CONSTRAINT sys_adresler_sehir_id_fkey;
       public       	   ths_admin    false    292    351    5555            �           2606    35894 2   sys_ersim_haklari sys_ersim_haklari_kaynak_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kaynak_id_fkey FOREIGN KEY (kaynak_id) REFERENCES public.sys_kaynaklar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_kaynak_id_fkey;
       public       	   ths_admin    false    368    5692    358            �           2606    35899 5   sys_ersim_haklari sys_ersim_haklari_kullanici_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kullanici_id_fkey FOREIGN KEY (kullanici_id) REFERENCES public.sys_kullanicilar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_kullanici_id_fkey;
       public       	   ths_admin    false    370    358    5694            �           2606    35904 /   sys_kaynaklar sys_kaynaklar_kaynak_grup_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_kaynak_grup_id_fkey FOREIGN KEY (kaynak_grup_id) REFERENCES public.sys_kaynak_gruplari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.sys_kaynaklar DROP CONSTRAINT sys_kaynaklar_kaynak_grup_id_fkey;
       public       	   ths_admin    false    5688    366    368            �           2606    35914 8   sys_olcu_birimleri sys_olcu_birimleri_birim_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_birim_tipi_id_fkey FOREIGN KEY (birim_tipi_id) REFERENCES public.sys_olcu_birimi_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 b   ALTER TABLE ONLY public.sys_olcu_birimleri DROP CONSTRAINT sys_olcu_birimleri_birim_tipi_id_fkey;
       public       	   ths_admin    false    376    5708    374            �           2606    35919 '   sys_sehirler sys_sehirler_bolge_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_bolge_id_fkey FOREIGN KEY (bolge_id) REFERENCES public.sys_bolgeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_bolge_id_fkey;
       public       	   ths_admin    false    355    292    5666            �           2606    35924 &   sys_sehirler sys_sehirler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 P   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_ulke_id_fkey;
       public       	   ths_admin    false    5716    292    383            �           2606    35929 )   sys_kullanicilar sys_users_person_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_person_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.sys_kullanicilar DROP CONSTRAINT sys_users_person_id_fkey;
       public       	   ths_admin    false    370    5487    255            �           2606    35934 9   sys_uygulama_ayarlari sys_uygulama_ayarlari_adres_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_adres_id_fkey FOREIGN KEY (adres_id) REFERENCES public.sys_adresler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 c   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_adres_id_fkey;
       public       	   ths_admin    false    5658    385    351            �           2606    35944 5   sys_uygulama_ayarlari sys_uygulama_ayarlari_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_para_fkey FOREIGN KEY (para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE SET NULL;
 _   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_para_fkey;
       public       	   ths_admin    false    5712    380    385            z           2606    35949 +   urt_iscilikler urt_iscilikler_birim_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_birim_id_fkey FOREIGN KEY (birim_id) REFERENCES public.sys_olcu_birimleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 U   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_birim_id_fkey;
       public       	   ths_admin    false    5704    257    374            {           2606    35954 -   urt_iscilikler urt_iscilikler_gider_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_gider_kodu_fkey FOREIGN KEY (gider_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_gider_kodu_fkey;
       public       	   ths_admin    false    5463    241    257            |           2606    35959 H   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_paket_hammaddeler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 r   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_header_id_fkey;
       public       	   ths_admin    false    5499    259    261            }           2606    35964 H   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_recete_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_recete_id_fkey FOREIGN KEY (recete_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 r   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_recete_id_fkey;
       public       	   ths_admin    false    269    5513    259            ~           2606    35969 H   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 r   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    291    5553    259                       2606    35974 F   urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_paket_iscilikler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 p   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_paket_iscilik_detaylari_header_id_fkey;
       public       	   ths_admin    false    265    5507    263            �           2606    35979 I   urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_iscilik_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_iscilik_kodu_fkey FOREIGN KEY (iscilik_kodu) REFERENCES public.urt_iscilikler(gider_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 s   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_paket_iscilik_detaylari_iscilik_kodu_fkey;
       public       	   ths_admin    false    257    5489    263            �           2606    35984 <   urt_recete_hammaddeler urt_recete_hammaddeler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_header_id_fkey;
       public       	   ths_admin    false    5513    269    267            �           2606    35989 <   urt_recete_hammaddeler urt_recete_hammaddeler_recete_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_recete_id_fkey FOREIGN KEY (recete_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_recete_id_fkey;
       public       	   ths_admin    false    267    269    5513            �           2606    35994 <   urt_recete_hammaddeler urt_recete_hammaddeler_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_stok_kodu_fkey;
       public       	   ths_admin    false    291    267    5553            �           2606    35999 :   urt_recete_iscilikler urt_recete_iscilikler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 d   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_header_id_fkey;
       public       	   ths_admin    false    5513    271    269            �           2606    36004 8   urt_recete_iscilikler urt_recete_iscilikler_iscilik_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_iscilik_fkey FOREIGN KEY (iscilik_kodu) REFERENCES public.urt_iscilikler(gider_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 b   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_iscilik_fkey;
       public       	   ths_admin    false    5489    257    271            �           2606    36009 H   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 r   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_header_id_fkey;
       public       	   ths_admin    false    269    5513    273            �           2606    36014 G   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_paket_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_paket_id_fkey FOREIGN KEY (paket_id) REFERENCES public.urt_paket_hammaddeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 q   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_paket_id_fkey;
       public       	   ths_admin    false    5499    273    261            �           2606    36019 F   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 p   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_header_id_fkey;
       public       	   ths_admin    false    275    5513    269            �           2606    36024 E   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_paket_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_paket_id_fkey FOREIGN KEY (paket_id) REFERENCES public.urt_paket_iscilikler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 o   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_paket_id_fkey;
       public       	   ths_admin    false    275    265    5507            �           2606    36029 <   urt_recete_yan_urunler urt_recete_yan_urunler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_header_id_fkey;
       public       	   ths_admin    false    269    390    5513            �           2606    36034 <   urt_recete_yan_urunler urt_recete_yan_urunler_urun_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_urun_kodu_fkey FOREIGN KEY (urun_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_urun_kodu_fkey;
       public       	   ths_admin    false    5553    390    291            �           2606    36039 *   urt_receteler urt_receteler_urun_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_urun_kodu_fkey FOREIGN KEY (urun_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.urt_receteler DROP CONSTRAINT urt_receteler_urun_kodu_fkey;
       public       	   ths_admin    false    291    269    5553            �      x������ � �      �      x������ � �      �   (  x����j�0���>^4}�>��L!NRH���Q-��n��Fo�א�H�k�i��v���,r�<�^�ڲǟ������_��"<�%;�<��<�?~�����y`;&�ı�c�F`2ԙ"N@ ��Y�^�-���^�����g����q9?G����2_�O��S��9@�菘A5������qpN;����r�Iس��E���(�
KonW��`)J���M��δi��)���6T�H �̆ĵ!+�P��r�~�5�F�a.�ȵ3��IY��6_��HS����0���+�6T��B/���g�0�Ua��4
Z�$�I9�e%Җ<�)!'����be��|�r@���dI��JZ�ea�]ٿ�H���VZ�A��5��y-��aH��"Տ�J�,�EX�V��`�#j#M�Bj��{�7Uy���R(.���x�e��j��o%j��L�E��{Q���"�(#�Aha�U,�SR���n�7���:�;��(5'#D�$]'꒸�ۋK�\�uo�]�r	N� ��ZV_�G_�7�^�B�'I���'      �   D   x�3�4�461��v��srv�0�2�Yrz��x��id�e
242�p�s9����Ԍ+F��� ���      �   0   x�3�:�!��1�3*($�ɑː��1��/��N� �� G�=... �^      �   ^   x�3�tuw�2��vrtq�;�!�˄���4�t�?2/T������'�˂�Ȇ��p�9���9~����9}��ȑ�Є324(����<O�=... F) �      �   :  x�]�ˎ�1F�ɻ�2`s�V���Zu���b��0����������������$���?qjA�x�<~����2���z�����/�-��G�P��2f��:�B�ȾGAE83���2�}J�f�&�ĩ۲�z�1G�!� kBbG(�/�}J�)*��d�2dd��`�S�ܾ��:B.��곇P2r!�ޖ���,ԞQBNc%?f�\�_W����{
i!D�x2�wPJ��F|Ko�^YZ*�[��80�M���aFD��/~�nK(@ї������gF.4�wP��_�RPjFUh[�j�S�iӡgz�CF.�����:^�Kh�9�T��[82Z�?�#�������rA.��!��\��_��4po6�ZA.$	!􌖐F���������B���R5���j�s��a�7C8�2��#�|�82�H��}O/x�G�4�!!����C��[���kݪ�-�Y���g��[�X�~_B�h!E�82r���C8r��!_�g�V�G(��ǥ��^��ؠ]�g�>�L=��!G�q$�5m�Q�׿�|>�(�bY      �   ]   x�3��quq:���p��>�A\f��G6x9:;�p� �G灥�J@�憜N�~ގ>�@��o��c���+��9���9G煸Ả���� �( �      �     x����n�J���Sp9d�]\*�kdف�p0�N�sBH�J ��y����M��fV�I~���yIQ���&�_�꿪��n�6,�7.�4�D�y}����7�ed^D�8Q�J��,0��}���G��fw�>�q6�2�1�/>�&q��>ޯ~MV�V��������X�|���)�(������J��14��9�_2x����g����MM��X���E���|R_�e�)i�F�Q�Ds���(��o��m�e���R��g�X'܁iełn� Z&cs���#���E�H��ٳ�+�B�PMo'�&�}��F�	�z��ǁr�`�+9����1�y����ˇ�d����V_mx��2�F�g��xov��d6/���q�-��y��~%��g�x��\��,�T��b	�Ah\�G�I�u����΁�&�D���]h`7��o��(����c	(&��'5ߎK�5<0�/i$�3��"Oa5��Dr�Ke�|vC��1���ӹ�~�B���� 䄁1RY�ޙ�h�S��f<SI	�������&x|��|gB°�n ZC鸆M8�<��P6��3�h���7F����dC�@ݩ�I�j��=GԞd�&�}?QSe���Ա�ir�����ܓ��{`ؐ�Ք�z�Z�.N�d���:@��'�W�\b�yr���K�K��X�0JƷi�k1կA�����T���u�����>�Xh:U�ԧOˇ�:K(�6�U�%��Z����(�6\�EUF	$ܶ��]N`�m3���%)ܲ(H�4oS�(���;Q���D����Xv]7e�f3�҇tF��Q����l���~%y��?ؐ����XZS4�g/qg'�L�:���rA�3)��_�6�	�=d�ȟ�_������ ��W���Tw��M:�gS]`�����®�g]��se�M��J�B�N�T�Y�y�>���;.��K���;�mMAܦ��[�`�˯�:Y�iT6,!��i�<�'��`*�OI��M4�����;Z̺����A��3�`m-T0��;�
��o� �D\�iܭ�mxr��X��m�b`2(]��t�^���7����t�.�U�8���# 슈(�JCF !�2�ӡ՜�Z�-��M	с��i�c�i/m���:�FO7��_0!N�m!C	�[wD�x�Ғ�5L�iD$D�z�i�%8B-��eJ�>]Dv�	jeg�!Μ�L�X�DZ�g
t;���(�!L������M����lll���#�uq�"��	������	��ݭ0p-���J�gɜ5��YwBQ8��.�R�>}�'%\��enմ���J�eA�M�B��W���*6KG'��A����]��?�#�"��A��T������E��bcd�PE$$���D�|�D���_�O���#D/�tG]�@�3���)y����� Z�W��A�0E�c~�;��J�y�c_��=�7���h�:쯾�9��=�O��X8���Q��N{�TN����t�;�;1����h��b͡�l�oH�o����������	�e�+������j��,��a�_	�űө�aU$�j8��Ol�/�(=���ᗓ��e����TSz
˰����|tv�A-N��Q�p���H�>H��	��d]��e&��ef��t�|�U�o.��]�b8h*��{�)e/��bKq�u�`�1���g��<�g��<��g��D�g�����g������ѹ�,3�K��L	����r]�hט��lA�|�|����7��d����Ii�����!���Y����b�,3��?�ߟo�+t��a�����Ȯ�r%��h'�4@U���9X�'�G��k�耺}E��bO.�nm�Dxߦ�����
�}t�ȴ�k&�Pw���b]5i(!G���d��۠�Z���e.�[�E�s�\��4E����4��ű�A�G3����+5���Ӕ��w�1��qt'�=~���y-mJf���K�\���q� �Y_��;��������ER^�r6w[����}���h��%0�ح	�L�e�1� ��E�<A�����֓�cw�س(�.mq$)Z^Z�Z�]R:�=4 u��KR�ܝ��S��U�P��]�Ƣι{)������xw��9�e���v�_B�S0k/$��+>!٭W|��gM�λO*4�mw둻Rj(���RC	v�(�l2Fy�,��k�p�չa~��\����B�ڊI� �^X��(,��~��$o��H{����|�c[ǳYTɑb��M�i��� �U�^��\��h��|ڸ0��$�ַ�6
�\�ͥ���C�����YeY���(�[�����7�WȒq�Ǝmx$rޕ�=�0`���+Ǻ�Ӂ�8�{�,fU�����p՘��a~���?�$a3S^����@v����L+WQV^�R���Q�!d��^hUǴyiK��e�n��5|+��L������`��jjZi>����(��/
�Ԧ�c���y:�5��1r��������@��%�\,F�s*ـZ���u}ZX�XX�[u'�_p$�MI�����0#� ��w%��-(��l|P��EsI�����W�槥-F����J���5��Ƴ�M�$H�;rvK��/���Z	�J��[�&�|��C��i��V���MwI=���K��(����0���L����o�l*�X��H���4bcA�'�)�5oB �ۺ��޶-(��l�ú��B�0��YjcJv��mҡ�&t�M�@,d��VQ�MWؙ>����v��L =.��柨��ɢH�����V2�-�6Ѣ�.�RA���B��Y]�"��tj;�v�;��Wn1�y� Z�q��J���T�l%o�����Wmo}���~ؾ=�(�(�E��~R��$�.j*YŻ�6�b��K�U�Pe�4���oe.˟�T�UCCk�a��݆G�B��3���`����9ݰb�]Y����G,W+�d�>��]��e�U�n�[~��F���ޤ���-Ҩ�%��A����z�B�X�[�%�eoݴy�|�/4=!Ď��F��M'-�`�p��@}V���"®�u-V
�B�h�t�m��Us��~��x`�W+�������p�Y{��xH���w�ɢ�������!�'h�-�����������j<!k+d�cdGЮ��U�/��e�IS��}���c����NXm�&>k?Kl+�I����t�(
�eE`iY�hz�n�6N:��
�}GY��_Gjq��.�'���|"�h}H���'F�t�}i��^�%�*/N�g��7h}���5� ɇ�^�%�B@��BYx�5�@�	���k��ǡ�{Q~�א/�˯�{'�7�͋��e�$��'_�^������)�W�v����y��g��녅Η����]6g?��e묖!ߏ�����ɰ;�?~7�V?O���.N�~��a�<�~�7��Nx�ߚK����Fݷ���dn<�૳��̮�d��Cr��Ὼ'�ѱx�T>���6��%��>$�q�:C�Z����?_�x�?���      �      x��][n�J�fV�� 3`?�M~�-&�P��2 c��
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
Z�SҒC�Xt;��K��G�Gt������~b�S��Q�3#}��Zw�k�Q����^��G���u�=��W4�����Ř�G1J3�)�����yɴ�)�Yj�t|#�(�>�p���t�:����3%`:�b$]qQ��ϟх�R���K4�Ţ�䝠�%hzo��GV(�Z�r#��^���*��M�Zzd ��7\�����$��t�y�`,�h4=1������]����]GП�{5��"����>}�-��      �      x������ � �      �      x������ � �      �      x������ � �      �      x�3�4�44�2�4Q1z\\\ 'k      �      x�3�4B#NNC�=... �;      �   ;  x�u��n�@@��W̽��,��L��*�mb�-�T�	�&����z���:�'7��y����8�{5�	���]8���e&�D�9Z
qA�8�p�u:�ӄ��`0ҥ����$!)YP"�6�`��M�d����!�q�h�7�,.p�Y��X�9�~_�{�1}�%�dm��3��D͢x��vb��}��.��jpYw���C�C�_ujsZ���p�ks��w�N��T�	�������V	���9�:�nm���!�~i����ᭋ�[�\Ѩ��E���,)ҼqU��t�)L��d_�$�W�a����(      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �   �   x�]�Mn� F���`43��XIS+ƍ�y�u��C�`�?ip� =>F��H=ƽ�nȄI��稧�gM�u���ｉU<����+g��Ua��WD@��Q!d!`eůmxcj��pM�7U���s�y���x��p�"�P�Uf=`���!dV|Z؃��8�^���9~�^�]ΗN˥�ө��у���
;��TeD"��j��V|:=�i�_ ~V�      �   �   x�mPK�@]�Sp&m��rG! 1.0�=�g�x/!~_?y��i	�ݦ7 D�`��~�d����}��8��D����$��ڂ�F]A
��@�Š�?��<�)t�yjRC)�6�!p����е!�G_A��~����/��q�w(�u��aC3O�<�Ch�O�d�3R���U�oX�Y��Ȳ�	K�AB      �   D   x�3�4�tt9��������q�9������u�ʅp�pq���d��p�y�~�~@�=... ���      �       x�3�<:���3�ˈ3�5��1ҕ+F��� Tk�      �      x�3����2�tr�2�t�s����� 4�      �   O   x�e�A�0��ت����0���ӄ�p�P/o���s�۷s{���y�;e�dV�;����<����},�w!� �b"c      �   I   x��I
�0���c�xo4�&Q!���C�Z�5�׈�<^Y���s��'��^�0�R�yˋ�v >*��      �   ;  x���1n�0���k�{N��.�0P�JR&���|��{50�}~z��2D�����?��v8����~��w)�w�����Mq�b��`R�S|s����/������|W\
����ݱ��]�����mZ]��КRm��,�V�n�Rm���Z�#n�����6��G�'�����`�)�����b�2�����0V�/I/�p)�*��#����.�8�4=:�X��ք��9�+fiyZV���2����ieX1K��ʸb���V����b��5q���2�XZ�V�[iyZVl��ieX�����qŧ���� 63��      �   7   x�3���p�v2��@<o�#@<c0���5X!�����$hDpc���� K�$      �   +   x�3��s��9�!�U����ٓ�!�~x���k��W� #6�      �   �  x�}��n�0�竧�� A+�i��F�Z���)�c��������cWk�f��z�Đ;��<��^��8~V(��2Ef�|c����8yQ&�+.ƓJ������q�J�g<�KYT��'t�a##���������p����Φ�Ŕl̛ }��		�HH��98A���G�r]�K}�t-u�Fb^�"C��S1�-1s.K��q\�#�.>��K.�#W	���lč�
]���LH�~����\7���5S��)���X�\�C���*�M�q����"���6�@��s/��I���� �����:��g���V�����ǧm��Ul�t���0��ɠ4��g#����r���,�U��Ff�O߈���BUiY���o+[��7Zpq+�\�S�!G��r�C�Wj��~���j�þ ��4��J�͙2�/1aלP/o��ӥ$���z9�'˾�[��>�<\Z��4ܹ���x��u��eY� y&UP      �   U   x�31�<���1���#���q�44�21�t������44�21�t��s��L9�\C�����<3�G��#|C8�L�b���� Ax�      �   M   x�34�<���1���#���q�24�t:���.��ed��������ed���yt�B�c�c����#W� =SI      �      x�3�t�2�t�2�t2�2�t����� $ �      �   0   x�3��=<�����Ȇ`.#NWW_G?.c��(m�yt��W� �|      �   *   x�3��
q�2�<�!��.�����
�!�cW� �      �   1   x�3�<������#��]��9}|���L8݂��=���=... 7'      �   *   x�3�<<��5��_.#N ����e��txN�?W� ��
�      �      x������ � �      �   3   x�3�tr��9�!�?�3Əˈ���1������5�<�! ��Ď���� >$a      �   F   x�3�tr��9�!�?�r�t�S>�!�1�Ȇ��|\���8=�<� $��1���!!G6�h�1z\\\ �$_      �   (   x�3�tq��,�L�L�2�tst
:����
��qqq ��      �   �   x���M
�0��/���:%�Ep�M�Ž����g���X���I`���|������Y�J�.q���
��$�*�S���/,�:YԠ���;��I�������M�l���|9�н�i4h@,�a-�	��L��i��z�})      �   4   x�3�qQp
��445�500D��9}]#�\}\�8q+����� �ob      �      x������ � �      �   D   x�����@����9r@Tp�ׁ�R>;����b��O�8���I1S7�q4ϣ��-M��I� �g      �      x������ � �      �   ^  x����n�0���S�	�8i�:��D[�*.;l��0�,;M�q����e���A�F����o[�%
��R��9������J{~~kB�~Ĕ�Ll��A�]Q�ԉM�9�l�=H�<��i� �_�h�E�����cs�3]&V�u��T
����r�V�^+��J��ܟ'�$��0$Bj�� 3gjú�%]�WD�k3���VP�y�H�s�$���KO��I��g���Q(�
Vz�#S��I��$�P2>�Rc����S�O����K��"�k���أ��/�)9�����s�Zpz�iHU�
�8Tq(E��ۦm�n�a{�ؾ?�����iӾn�u��"�             x��|Y��Ȓ���_�l�}y���� a��.B�~��8�U'�����*�9fe��
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
� ��"bt`Eq(�wn��kW��Z�m=	����}�ˎ��]�Lsst��zέ�Q�����V�ӛ��Ν֬�r��g��NB4�O��6/��8!�r��$$@eGM��w�.��!�4׺�aXk��}��k��M=)g��j�0����$A\�ȱu����ӟG|^_��j? h�A�Y��.Ӷ��ŕAٶ����&�w�f��1آ��WϸZw!A|<E�D��o��oj˱�i@&�U��_|��f�L\�逹������yEm������0��$t\J" ȵ��] "S]%}j��K.�S"�A1���x�,ԭ},~�Qk_�L��a������X���M��& ���h����M���`N�˘�����ๆ�¢�Z���7W	X�1����7��n���P�%U�x��C��{lr&��KM�w�T"F����t0��}�i~)�& |��^0'����T��|����/rFY �N�I��,w⨪�x@H�nU���A����J����ۢ�N����'*ЙD���{��� -�^�Vd��ӬW	���Ce�f���w*yG_����24즢��&�g,s"����B�y�Ӳþ�[�����6i�}��}��[�����ʋ���`�ez��y��p�^!Ia;��3�<B�K�Bކ��\���!�xx�F����@��y�6.�-����͈���|8�K�L'n{�=�䍶򃚗���R7z޶��_ҹ��-Ă��6���j������"��X/������w:�����i.3궬y���Q<>A)�"����g/a]�'=�dH�Ky��C����� �v5{�%����V�BJ+rm�<�= G1w�L��͛$�% a��-���Y��^��g�{����A�a��Ȳm����J)qq>�ӰJX�^�CF��P�/y�F2�ys��,g 1��>��4;9�&&��޸$���- ��gk���f�>>���?���3/*%�d�������������E��         �   x�3�0�p�s9����5����5�3����9�M,,-!|.SNCSN_G_GoNG?�oG�#�:\Os����u=�����1�������II-.I�v(�(�L������K���2C������ N-0         w   x�3��ON��2�<:�4)��˘�7���˄�/�81��ȭ<���ˌ�#�*�(d����[Z�e��xd~iqI~1�%�ke��=9\���ٙ�\���މ�G6YF��E�9G6fs��qqq �;#�         P   x�3�tuw�2��u"G.cNGoW�#��L8��"P�)����]�}B��8]������9���s�D����� p�      
   �   x�e�A� ��c*c�������j�U���vYs�:�km�e-���:l���=���9oX��3���Ж�B�fnPOh���y�B�T"-�b����u���5�s?�*�h���x����xtU��ɪ�π��F;9�d���׀��tv9ˍ����.9��i�V�G8�C������UJ� 3ԉ�            x������ � �         W  x����n�8�����,DR�˴ɦF���z��jBH���"y�R>ɦ2��d���Ù�^Tl^����ٯ�?�컷]k�c�W�8+�����|��_p�O��v���K�ۗ�v��0��WQ�&�.�I�U������]��&��8��2����=a�j���O�v�lk��C8�u�����ϭ{��a��"���� �48�<l��8�m���w�����<�><��7
�?ϣ����v@h�ܱ�*q+t������+�����ׯa�,�%a�IZ��,m�yApe�D��w@������]$"v���EҌ�U���E3��A�g��y��e���y�
{8����>���p}��=�G��UW�ٝ{���/qB�$�E�ۑq�Q-R%����j+s|}�X͗��ף�/!������g����Z�����KTNH�.��9g�g����'�\�$��r��	\?9$D
2߼���mH����	X('��!q��ᆟ���-�+p14✱�S͸ĳ�Hv�)'u��S��i&��O��2'I�1S�/��)�)�F�-JB�@4G�1����o�5��x�B̅���n�Ү���هv��4�� ���!P�%z�"W	��y���(p���I3�-�o]� �	�t.�{��˅TCK��M3���m<�P��l�Wiȗ��ciV�����ˮ�'�C���	ƿuװ�ᝌ�"��M���,�.��"7R�%`�ƃ��"�`Jv�y_�@P��S1���`�P$�é0�K���`^�y*�	:>�#)BMb��qׅC[� ��Uj��^>��P�qd�"\>�����H���ի{�����>�;xx�
D�C�'m�L��H�����[f_l3,�o�m��-(�B���z,������&���"�"OP@↫M�!>yqݴ���V���H3n6�c(��)�z#d�3w- 4�o�By�[�iAB��!$����,<�J��k�p���㿬��4{��\�Ţ��7��?����Mǆ�����,���3�8���,��ϿB�u�CK}Gp}��PCF	��A_6x�7��>c�ǝV��������w�����v��<�E���r�|������m����v<*,YA�M�0�hakpU!h��v[�[��0"8�/p�@�<������	���c;��p��<Ũ��i������tlJ�*^N�O�a����a�p�;����Usl�'�$!E�V��xPL�1i3"��n��v�i�Q�0����f�p����	��Yj���2|D:M_C�F�3N�!]4���~o7G=�pA焿9�BM�k׽q���LQ�[ל������[��f��Ӥ(�W7�Ni[U�����A��#�A�Z��M� �Z��Z�#N	S�1����9.�F�/�TP�/G�c�.�������!"I�n�h�϶Կ$	�����K�r4��P�H|v�ЈB�'_�aUx�)�&�S!����(���9���@{GUL d��Q jPē$ �	�
�I�	@	"M�	�5��& ��I�r""g<�H�����8�&�q&ø�D���Y�<$�D8^��m��xN�d9�W�ZD�yN ���...�ZU�9         �  x��X�r�H>��b\�na�?��-g���-�r`Lf5��Ar-�������1Ws��7��گG���l��{���o\�3�Re�wn���8��H�����J5����>�n���
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
��trr�?�`�         I   x�3�H�J,*I-��2�N�9��˘�p{b�����I�\&��@vjnR*�)�sin"����1������� �I         h   x����@��L6 q��p�/�%�����5Ѓ�zy%<Ǒ5Kg�X���Nqf��\��<C	�>��$�;��y_����S:���s���_�k           x�eQKn�0]�O�T��4��" �D��}z�.9���^��v3���7($�h�z��ָ�@�n�����f6�͎�[ �0�[�be֋?���L���f��TŤ�fbg�2�IJP �v)����	��@��h\����W;�;3.��\���_JI�%���O,�07�ҕθx��PU^�Y�I�C����():o�-?�09��Pj�\�b��"�M��]5S���?~����t�����;o'7��(@>���RL�u���7��{         �   x���
�0 ��oϱk�7����++2%�K�� ��=Vу59�G)0��(R<��`�@]af�읟�ռ����)<`���$����i��&�L�u��/��=�~R�d�s�mY�䫄E��s�eZ-�V
��.!���|#�         4   x�3�r�u��2�t<2�3��ӛ˘34*��'ԛ˄��Ȇ�#|�b���� �[         �   x�U�A��0E�ߧ��(ii5�4�B(u:j���p�"�Ā��"��߶�8J#rH%˜�w�p����R���Qj�a���͡�V�L���j���}��n5����%{�FK{Ĥ0'���;�4'�#��|9�Ɩ���o�E�Z��u�����Z� 锦�j��!�CɗY�;�$��GP=�~p��<����/O�            x������ � �          �   x�%�;�0��z�.��x\`�XQǱ�6�4�Ѥ�ؚ�$�#���i����<{1�8�~	,#��s}�OR��T���M]b�ӹ�&ڡ��(�L�Q�<�C��ZaӖ�.����t��3�0�      �   I  x�=�]��0���U�
FM�$�����w�������<!����ל�$O��ı���,��]ӺyM$r�ʐ̔�����y�$D����:�L�Db���n[�	�6�jIX)i���#U*��fj;�\��HU�K�x�1�o3�<mL:Ɛ�x���>wE�%�n�_wW恖	�{_�ҁ	!�}?�"`�"EĞ �騴ԯ��+cH���'=���^���
����xȖ��_<-LJVV��ub����?O*L�IȂz7�?)!n�����#���a���Ya�A�D�������y���C����Gd��J�mv��N� r���|�nE�����G�q�ˈdE��ţ:U9���Y;�).ʀ 7�I�
B��7�A����7/T����ްED%І6-d�����ح$�!���;NkO"�њ���~��" c��ݼ$㓦���ѿ?�+��*q�{z?Z��te 1�8��l�f�#�2��Ё;DQA˙{��։/�0~�N�0���g2�������:08?\��:2B��)�I� �u|o�'@d%���gĔ�]y�ze|���mq�)�P���D�Ti/�L*�F����M�*���ꧥ
Cz��0�
�A0좍�Û$E�FӅ�4��"i9Z��狶U�Xc��{�H'� 6��6��� 
C"��̶q7ޘl\�X��g����m����Q�¸%S$��^�� 6��װ^L�H�����q�����Gytz����q - �e�j�rr�X��|�b�! �B���
۰َ�!��P��5��[I%^�7�9�&�]\��1�7���c�}�β�?���      #   m  x�mY�r7]_E/�*�K|���6�~�&E�l$E�e��"Jv��Tj����o��Ξ��so�AJIʉp���\pJꔾ�#SE���SS��hH��~��7�#RF�
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
�����͗���d@������f?9�0$��S��W�s.���͛�����      %      x��}ٖ��������sk�{��
SM[ľ�T��.Mk�;�Cԃ3B��̵v��1�bi*~0����՚���\�7};����Wl<ַ�_�h$��H4��x�_I��p$���������応O≤�J�����ѿ��^�E��'����M�����,'�ʇ_r�H�L.���\���������ٿ���o����_[e}��7&����������sm�ݭW���w��X�O����W݊t�oEQ���Ὴ�S���f����")�-O�C���g%}!	<�'���xO�	<�'���xO�	<�'���xO�	<�'���xO�	<�'���xO����z�G7��;�'������&�]�={������8�/�G���}��H�	�ߎ����_=����������1�}X~��o�X:踾㻇���ǭ�����x?�O��o�_����^����_��>#O~`�|��ѝ��1׳�x����i����v8����!G�1`x���6����w�}������c������0n�|a_��8Y�����ȸ�A�h�0�x0N������s~��7���0(����0c�u�[_:^��Џ������sO��5S��2(��y-��˃|��.�������Q<�6x�����,0,6���ތ��	}�냝|���S��a������RF����^$&=�47��&o�s����~O�f�I�_P	����e��|��m��c��^�qR�s����߫f��+�;��vycL��y��<�����%���?�zx�l�;��_��y��fk��9z������	�_Q^	������9>ܛp_�L����D��{���[�@nl���.��8�OR�f7|=!|��|)�^c�����б~�d/*�9D�+��_gkv�@��c?�sA���#>�ѻ�/�3������� ��p��>�ǄW������q��׳�x�P�>H�	W�s��I�/P9���ބ��#op��c< ~B�E�+�qR�͏�P������c�\�5~���C�L��ձ�x`_���_��(����9��"z����8���+�G�{X/��[��o|~��Qx�㱶7�����Ee&z�ς�`���,�q���G~ad�/A΢߃���d?>�� ���H*��3������Wp��/���o�'���Q~Ke�+۟C WS{ ����ѪD�=�g*��;����l,�O���/��8��cp߱x����1��=������ ڱ�8V�	x	k{��?�Nx`�G�7�����%$K�0VΤc<��!?�.H���B��c��S�}� ���?%�A�����[��?�'��O��	��@���*7���"jo���x�s��P]�ջ(�<���ڟ�|B����'�A����:�`�����w{"!����M?�Ů�:����2���َ���8`�H�s��:0叼=�Ŧ�:�3��>g�c�g�'�nQ@�-�_�Ϲ|ƹ�X�Cy!��`��Q}�=��K�)���?=�fl����{K6��#�!��\9�����dC؏ꑁ�;BT���?�+�!�3Tfv�J���ϗ�9t^�,y�0*��sc���Y��׳�x��Ƿ��@ƀ��g|��AY}��G��r�Q��Y��3���@���>��Q
��Ǧ����\��r踅�)� �H��`�^��LA>VJ�.Km}4>��;� �,|N}��FJ����d7�7N׀�����s��\%�~��Qx������R���Tby�w�8��R����a|����!Y���ܿ~�o�~��q�vd��Ay�Gy����~�8_ wG�H~�,.�C���]��9߳z6��Q�I?�x4��bQ=6�6�菺���{���=y>x4��7�o����+���Ӂ��︟��7ؐև_��?.V�?W:^O^C���>H�xx�G��sL*��+��6D~=@�ʫ`�����k!�9��ͫ`����>��x��=�x��]����^^�3�P����(Cė<���x�Z>x��|�S���s~����}����>��
�1?�_��=K���}�^�������x����/�8Ώ��}�h=#��~����+�G�g�կ��_�wol�ȓ��#x�3���&^�u�%��>25q|�ǟ9���'��3Ϸg���\o7�N�ߓ��]� ��{����ݚSf-?t�7����߳Ϗ�8��ҏ���Z_��Ǿ�y�>�%�4����xl�3!H_�9��<?~��R��?8��ϣ_�����Y��\�wl��|�Z{R����/=� ��Y�ǳ:�g쓏��?���a~�^0���N�_i?��\k}o]�������2y�ߣ��W�C?�w��z|��>�_~��=�w����<�?k�������{�R�zv�~��"����Q�$���9w��q������+��C�lln�=<T����t�&�jc@�%[G�A(���N��Ǉ���\����q�|T�x����j�<�G��o���y�P��Ž1n��o��lN�3tk}!��a~o�L���z-ώ���4����/\p,�:"7�ۃ����X\~<~���x���˓g������<�[�)��ů�
�Ys�ONr"���[xl�_Z����h�$���������<9����~��H��7�s����7J��Q�Gy�-�@\���9��������윣Z'>�@����ݏ���y�9N@mv�^�7T/�N�
Z�������� ��l	�n�ct=�6t��Ϛ��?\���y>J��<~����\<1��5�A9M_��x��{��\7�W��zؿu�=������s7����'tI��/�9��e�`=����'��OJ��}rz4?g0������Z'��Zr<�������������V
�W�����@�Gk~���I�#��]�;��`��.��a|�4t��q~��M�\�9�_Ӵ7��8n���g4Ţ�8i�vO����lr��7N��(�����3�j	}�z��1�5?y<Z�=�Ge^X'~}]���v@���ЯF
;���'c�5>��<g��6"����r��ğ��낹���'�ۿ3�:�~cz��"WW ���3��?��#�W�����;$���U�\j�⟝T?~ ����zO��p�锨.1����3�^
O���=(����E����癡�7�#�hm<J������}��T��'r�Ur��4�8>��'䉭O�ǯ�3%zt_���;�;��z�b���k ><�<���W�^�>�����x�z=����^�W
X� ]��k�#����������H����j��5���ϣ��.�����8��w��o}}�;v��Ǝ��_��@��\zW�K���Q���y��$d�F������yj��i�k��BmR�X��M��GW�=��
��x�.{G�c�\�dZ|��gꣶr�������5���{�� �����k�O�p�~��~���2(?~�A}����ٛXy��ow���������65~�X�O������t��!F��w����8v���͟/����5�����������;�V���s>{�w������Y�uY*۱��M�9�e����ϭ�Nx�+�38,y�Wnۛxrm���[<������xv���Ϡ{����ɵ󎿏x��|����#�y��C��3�Q�:Ȧ���џ��/�3����A��l�~㣘�NԶL�Np�����0�J�r���{��y^ ��O���G~�ۛn���u�}�qDm"�_�G��������{��y��7���o�t?�O�-|dcb���lH��3���ޢ@�����k�Q����am �kMl�~���������}~0�c׌�����[��A�*��N���Z}I�+>��w�=� ~wo|O���֗|r�#�/��������zTb�y&^��e��>X#�<c�������lG�_bx4�K�n���    m�����Pp,�	��-������ 
/���q�9���I����ɯ�w�:ޭ5����r�g˃������f}�����*�|���?ۃ9�|d�+����Î�>���Go�����{|#|���W�x�|���w@�<K��/g����;6&f�]_�~��!_+����꘴'�Ar<���o
�"/�|O{y�ϐ�*��γ��^�	����w����Q���	>���sn�� ΟpgG����Ĥ��������O��?��(??�=�޽��ܟ
�7�= �~���ܛ���h�$����y4�_���\B(w!`�x������v3�/&��3>��]���k�~����]�3�,~��G_������S�����O>��c���y���kz]{��� �
k+
:.=_��G6yv>y�$���������g�ѩ�d�{�#��}�=+B2r�?��[���_�22����ϯ|a����6?y�~�gϾ�,���9��u��8�X~ß�_����>�@ٮ~���������CW��0x <�7z�_qKF�~V�����A<��x~��^|�]��@֣��Q�����lt��>r\>���۱�<��"�2+ߒs�8�d�?v�HVd��/ޘ�R�=�=��.Kj��ʁ%�X~z��l��O}��V,�#��Q�����~���٦��+t���_,{=1�a�td�=c�#/������#�ד'&�%�^��,�3��cW��|�{��C{����8>wk}?b��x�o����z&�.@����bs��xʻ����6?�o⯵[�Kky�M��U^��7i�}��X7��l�A'����Yc?<�,��_�j�����gwr}��[��6���g�ߡ����(F��(?}��{��inİr9"�}�=��G��>���q��C�������n�\�4S���J��^��}�\�t}���sJud�z�e�{yDW����|��,^���{8ނY3>)����6����)�7�<�)ozf�<�Q��D����m��d��≋u^��6O� 2�_u\�[R��w�gY��O>_V������Rr�,�x�~���	��@���9��g�W�g��b�����o��7�G�x���~����:g�����^On��'�1�s�YӒ�	��#^�z�^$o��_����!��<0�ݕlG�����<�|�o=Р��5��	�z������+�5���Ճ�3��8��y��}�V,ʃϫo�_�#7����5���J>w���]���H�1�=�uAx|��Ge�������x�x���T�/����k?��q���L,s�>z��9�@����W ��q�տf�lXxq���y[ ��+�r|��6:��z�ߙ?���h>�9(������}�����'��'@?w��d�c<���𻀵��{D��s���(���������6lֿౣ3X|�?�ȍ_�|�'?O��xy�fm��G�n�G�O�w�zpy;�P�:{���\Y���[�s���ˍ��1���[S�:R�x~~W����v>��j|�=]_�׹5��q��<�|�_�/��c����~�@�D����W�tY�{�������~�n�6��q��1�x����<�Sǎě `Q����/��y����cC|�:�Ƥ1���x�@�< �A�?A��t|�C�v7>���w�&��
/W���:���'���?@�CPNKAq>_s���Q�3d�t��[����O�W"V�����̵�笞��~�W���Ɵ/�{��ާyx��ڝ�Y�q]��A�}�$,�:�����lR�˳��A�9n޿||Xн���y�_�=�{����>�X�7ݲ����x|�և����g�>y0W�xׯ�Wџ��[G\y<ޑ���e��3����c��;��?��ݟA5x�?���ɫ�{UH>__�ú�E�[�=�_ު�䩕�C�j}��ʞ�d�������n]df�n>�6	�O�<��zu�uRw �:`k��?������O6�'r3>�Z�>�n���GG߅�|;<���v��i|�x4����������ߨ��){�ty��}�q�
�3�l����*o�9�{��k[������`/�k�nqk=�<���.p�����K ��}�ד������l�+ x�5������e����CqB7|@���1|�?�'�7P��r��w��0&���^�'���l2O��#1��Z1s���ͭ!��#�0���3�#�>����>�_|�Q�'���������x�Ϟ������>�<��}˾���������~$xO�	<�'���xO�	<�'���xO�	<�'���xO�	<�'���xO�	<�'���x�Ͽf�u�'��R:�߸�1yo\���X�� �W�y�'����Yx~�<C�I�x^vN%'���<��Ҿ���e��F�����.� ����'�����x����}^$���B��ւ���ԯe��܍Ts=V[}�u:��˛v�_1o����� _6�%����
������q,�|�"YJ����4/;�m���ƚ���vq�nV}U���tNk*��;>��x�O�+�1����xO��Z�[��Y���%��8�o/���&����YŅ�ϵ�K���5����tN�*b`p<�og�*���2+���zO�	��ۨɼ2$׮��a72T[���V�Z�Y��e��F��=�y��:�E��O�v;�<���n���v��b�bO�Dh8w�O֤�y�O�	��_�&�mN��n�IϘ�O)5;kٰY��v=�[ye:�q�%�z��x��쓫��]���Vx�63>�����6�l|Z5��Aw�u��O�H�	<����ɵ��P��S/1�;T�G�<��]���5��pd9�4�a~���sk��^A�^��_��̔�#�+ȇHF�[-���yUB�c�l��z� �'�ޏ����3��Ɩ0:�#���q�Ul��h\�Z�쵛i�����W�d;_YtZ�G6�ӣ#�m��Ȇ/���Myg/�(��������x�3x7m[�O��C�� �&�u��vq$�f��eW��o���)������DH2�ici�h<�EB�u���:�m���	���+���{�d����cR�vl/��;�xo���iT�߫��V�k����e�?��P[#=2�ihL���ơxy��/xO�����D�55���<v�C-�����zn�!��t�]�,��e���몏�?�?Dx_�ry��r��~�z<�'�~��u�D���(��������o�Y�ϊ}>�����u�}��f-=���^{�o������H�	<����|���қr�x����O��%�s
�I��4�Ƒ ��Q{�g�m�z�(�b�h�������x#����O�	<������P��+f�� � �� |535'���?���#�y)������v��� ߡ�������*��y���W�	<����u�{��W�����r��K�pU��j�!��b�T�����o�Ce�_l�"�U�ya�WP}�����������E=(�'����� ��Z�_j �9���:�ۙ��$�z�����������u��\�ֵ�a��������m{��U��0��Zt��=�M�CxO�]������Q;��-�ls���|]t^�|M��-|U&eSi@N,ȃP�𰝏�K�Q���Y��6wv]k�ͷvԌ�c=�����hzۍ��~�l�U'1��ܸ���o=��x_����&%B�L=������ ﴫ�.r�/q_�|�Wt�y9��-䐍V�)ԯ���E_�~ȓpsȈ��k��@Y��~
��m�u7��/o��ڪ��MTu�O�xO�y�¿ު�q����l�� _�����Wu��j�CqU��(�Z+5�ӼX�������^俍�������6߇y�ã���鿒A��O�V\����x�o��䟭ZT����l|V��    [I�&�]��%��������C�}��w7]Tţ�*ťJq�h����ayn:A����j`�q7V�#��o��{�=�ȯxO�td�cJ�&9�����Wrt�7���4$o}OFt�4O߳_L
���V���S�So��V��r�sP������|�,ߠ�ʡb�{����ǷT-}ɛ�P��xW��}2]�(��m����A���;%�[�����oy�#�)O�kk𚭞�c�����ܸ��tI�T�W^{$6�6}��xO�})�קJ�"~��#gA\��o� ��ar2bR�\��T�Ǘ�����{}�����q�֨�ZO!��|VP���B\|cK�y�~��
<�'���&���������j|��&'�eD�5�v��yw��z/&j���'����s��w�x|��w���s
�����	<�'�� �����~\��=�����?4>�'�����:�	~�����q}�P�F��quw�'����C�n�v��?L[g�����;��x�{F��-�3��e�V[�^w)$k&���W�O�	<��c�>c����8[�A^�K��,��t�8]j�=�����xO��:���U|���>�f���խ����<���xO������bs�X�A�_a���됏_;���(���w�3r5�ɶm�ڪ~���������+�����<��������z�8~��!]�.����'�jk�j� ����׹���c���ں=���n!���dlS�\����p��S�6��~n�~�O���x�>;��]�!JޜS�<�美�0A�&^w���}h|��!~g�{P[����R��!���RVs��<��w�l+�<����:����X���1�0�� �y��49�D5��k�&��������<���j+��Y+g���9Q�+Eh�~+�N��lO��?�Y_�'�%���<#�wMUʍ��#�Q�@��Ku�3��n��Kv=�E���ױ�>:g�V{�u�մ��k&��0�+��H�7ü�0��pݟ�����
<�'�x�?6�M�Y{~/խ)�q�0���a>O�H��3q��:��l}9Dx_d������v-;B��o|^/���3�|r���í;G&�x�o��x��~�l��q�荒b;<Ct�]M�l2q���q}���R��j���e��㻦Ա�:��SLͪ�ٰU���J91U����y��i�'�Ak��������x�	��8�"�^�8'���R^��J��l655\�����c٩��-���/=_�֦�Z5��_��-9e��'��P�b}v�/�;fT6n_�w���xO��:�#_��ׄ	y��]�_d��\}6�ڿ��䢛��Q�n������L����樿�_{># ����Cl��
o?ALb�w5�gO7��:h|�j�7έ����Q�^����ߑ�F��_��Ωf�<�}����q�9[�Y�K?5�1$7�Ńs����"��O�s����}4٭�qL^�b!��^��H��cRk[��o��˽\�q~�=�I˦P�n~�������DLZٯM5;����xWy]���{�*O�Xz�VϐC��勺v����/v��x��px�~����t�ݾ䉬�Nim�+��v��sیe״�ll߹��(�q��W�����"����#uB��q54ɖ���5��1�6d���+�i��ir��!� /�3�M�m'����YE�!V���q��\��ӇG�!sY�V�oM��*f�M�[���l�gΗ�n�f�Z�bƩY�u=\\6ZkK�T���	�JE�(:��"�<�d��bG��03W�E|�X{��;��:��ȬT>M	���x� �褠;�B�ZAV���������6�Fo;��X�>�
����RוrB)EZ���hM����r����i�t��x�:s��6�������q\�z}�C�9���������:��Y�>۴���jV��GTl�;�A�d���`���9=q+c�7�B%3��[�2����1���"�ޏ��{��H֫nǧL��9rMWI�'��&��dL�<h���4f��H��k�H4� '�۹�mˮǓ�f���(�����Niٷ�9��q+E��z�V����["�D�=�5���a89��� ��%=��f�]��@�͔C����,_�Į�9o�+ɝ�Y�� ��s`on���(��ߍwt�)7't>mu��M�[m�^���[�{�ҙ��r�ߦ�b�r�
b��x��~�>�������͎�<_oR�ۺ����Bˆ����B�W��a�����-ȕZ;r�˦�zy�P����k#�sX�C:��wh;�������d_�{r�]������o}�<��S�X{�%��kCDY��gGom;�6�q�LE5_�{��	�F6�y�ꃐ������ɋ����Bvy9�^��s����Zm�u۶G_�wѡCG�k�����*x�E.���V#W�q�ٔ�8[�b�()���9|��P^7�yg�{�9t���=m�<?����}��E�	�?�á��؃�_�>w��� S9��f=�üɑ�����[%��p��L�z|�Mo����S�������'62n�c<x�l�%^���4���j�n5��~zy�h���(���y%y¼d=�{�st^{����爆���W<����|���>|Ľ�e��z��W���59�}��n�>�����s�A�����z+l�$�	Z.7kw���~X��>D����èjZSdó�����j���8đ��J�~�<}d=R5y��l�6�s�Q�
�N�o&��V���N�y^rO|����q�+4�o�� �O����x8B��iϢ��<vr�	c���]/�j����4�����T2㌾j��;�&1k�9�i�v��t�����!���#��Ԇ2z�]�|3��a~J�����0��5��=���m/��J͐�Ț��׭�_��Gs�ׁ|�kr�E��h�Ͽl|���x?���?z�/F?���� b\M:Y��҉,H�
��YN���Q!�̹�ue[2�Ѵ��Z&�?��r�R�񺘞���w�-/��v���V�&Xk�z��ׄ.��9�
^Yݶ�'!�t[�}[�:�Ë�ЕJ~�u���B�T������ʷn��W��c$�޷����0��.����2�f�5W�t󜒒qR��6�P��
�/�==l,^��B��!�9�����7��C��d)��j��u�y�%�">gz^~*?�;�����¸)�53�D�g���͵Y����#}�-�g�e�A�|8B<Vߖ?5�?�zx���:��oI��/�����ObóC�������\~��H����X7�(j��~W�N�Š[�Y����?q���v��*���M6lv#�|�(��y{����~p�=Ȯ�V����..�n��y��E	d�K\
�9n7��Wɐ�3�y�O�>Ks�}=<������:JIO������\9,D^����n�s��&��Avٖ&�W+����Ez�����Y+-��<��<q-ϝ����[���<1�VцX������]��z�>C�&3�9��kOtx?�d���5�|!-�!�z�j�6�������`>*�!<��1�q�{���jeq���A�Vgo��a�X$\�/��Xh\M��ׁn�cN&���߰���9���	�M�<ן��z�ĸ��'�lOP3����+�MO�N���p��v�����q����Ubˏk�9�
6�b�C�>�j!�;��(O���14T��!t�v��������x�Bvc��6�B.��`��^�fʋ��2�U/%mc #a���VB:�#�^��ڑA�A*:�v�/���l��u����3�����;���Dq�����хYۙWW����"{��z��H�q�H��H��vu9jP��'��)
��cjlP=c���e�K�mm_�<�[c}�䗹�x�^CNfBR�27���x��tN��Γ��;!��A�[&�C�kU�'�Fv����Q��P����XW    �E���'��Hn�d�7�z������
x�yg�:銛K0��|�|��Q�f	��=6��xD��~��q����>��'?���J-�N�<P��Ȯ��X#Kb�F$�x�����S��C~����'��o�s�s��OcI��Z�WC�l2���Ky�O��Ԧ3F!K���u��l�u¹���L��e7��s��o�r��/��|�X��%l���k�"]v��Y����z�_��q���P7�1��[��ʡ��W���� ��s��Ky��%�1�1�0�����Y;�v�	<��;�H���������qx4��:o�-�� /_Q7P�͕�0���'G��%"]�uR�:%��8���n����r�M��|/�=j�['k=�s{���N����SsT�.�^Cl�a;?�����:���_��C�V{�v�����s
����3�e�u�Z���[��~�	<���d�ߏ��Fmj��!MN�]/t<���qV�EjU{݄ڟPLq�����n�/حު������z����a�pd9쯨.!�R�����|������)+Kك������q�d�'�Nm��sH���0�[{CtX"ە��o�X����m3�~��'������˕�.6����;����z&�Z�c�s��e:�ץ� 7�o�*}l��c?BO���OIk�S-��_��}֓v����>�An����vn����e"Ys�u���ͫ}h|>:�5x̀ot|�k6��en��aޞ�{ ��t6,UTz[x��O��������x^[<�p��}���ֶ(�Ď`E�3+��F+�F5��K��m�ͮ�87�'��#�%t<&�^���ru���YZ�~���T��?k��j�i���@��Ǔgq����/�6[��G���ܪ�ڙ�^>�T��Ϣ��@��m䯨5��/���?�'��<���6����g)��G�"��b;�d�R��i�������Ÿ�������!�^(����r�y%�X���N�N���ԉ?�&�~�`�^�������Y����v{y�����N�=���������<nL�/�@�/ �'��xW�Ŝ�ɝ%��|S��sd��jw&c-��[�7���g�=="{,NF�R���!�"�J�͝m�-�W��m(ߋt��웁rYI�yw|%`^��>}���-JzdJ+�J��vq���J�4scR�՞u�]�� ��^O�}'<�o"�#���I�r��!{�0?ɖ"}��x�?1�=[?,$�ܑ�>w����;��6�,՛��h����nO��f�ڛ�Ya�m�,g����{b�}zE|r=><ı�8��5����K��=��mp.^y���u�[ɫ[{�v����c�\��>A��,��M<�����:�ZŹ�$7��7f����z��8�{X�T���C_�C��j��	�?���V=R<g���ն�t?ڨ�Z�h���wrsK�>��PJ+�f{t�+�!fz�a���e�����}�%3��`KH�p��Ƙ������cݞ���{=<�w�R�)dHɊ�H���X؏\�z�3S{��K$�Â؏��zs��Ox||A�}�v�0��[�M���S�\i���cS/B�pΆx�OF2^j��L%�&�	�S~���q=�m���'��zx�b�z�U2#���%(�q��߬1y��-'76��eʑ�VIH���9f���(鞿q�g��O�Bx��s끮�Iɹ�4%�7P��#�l�Ƭ�Z����9������S��W�/ /��V@f#�d��cy�V�JI�V���j<���#�=�B��I�
�>Q��)W�d���@���_���X��e$o܏{?�ш�٤w-��^� .9�<�Cu�4���Gp��7�����]x���&=5c;���G��؏h^��V��F���
r)�4��/�|�`
��Hդm�G���U5w��r�R�Cf��k�c�b �A/���ciY����x���
dO\�JA9n��ZC�ux��z'ҋ;2$����A�'_��z@3|VJ(��;xlv����s�'����q��+�6t�3u���3�\������ld(�l���e�W�/�Pڳ�l;���o�Z��7�-���z����~��V��"�v=����֟r�
 wb^�#�˔�k_QPO���L��A��N��C�fv����>�=K�~=��f/)`߻�'%Z/��������vx��~�mۊ�ј�&�뤣^Z���u��5r�-�خ��l����8������n��@5�:��V�f�j�&��B��g�N8hm�J7�G�)�$ԁ?���A�;:��"��}����2�}��4�Ρu��˙�2M���'H_o<x��Yݺ{���������xo5�����{��T'�c�R�����;�� � ��q�_��t�c2�������Z\C�j���gkV(��ʰ4��Yy�62�5�o����с��q=-��������OA��C���h��W�2��6QԛvփZ����b�cį�����O�	�߅w��Z��ݞ�$<έ��l�>�OD:�hC�l��U�j��k��n|�yg�������y�e�3�c�ꡜ�f���E�U���tjr$5|=�k��糶Q�~�������U"�� q����7�S�j�Y�Eô�ro�Q*����NP̳=��2|��$��?/��^��)�Q���e܏��WT����h�������ι�y$�}A?���͑��'3��`�Ia����S��uN�Z>����&1��f��&���yN�_��P,��C��W�+RF��;�ab�����8�n0'�;,�ً�j����'�~,�e������5h�@Ǝ>B})J�f����Y����l�sNW>������z����7�fꐠ��ʲ�n�E���<�~���c�e-۟ ���y`�37%o-���=��C�)�Z;�j�@�"�{��2�n�,<_�qs�~�={��	<��;�Hm��V�)�Nǿ&FX�">�mi�,�GOD�ca�8l�d|\�ɕm�Gދ�Ͷ�j����&�q���O!&��`�����3�\J��tp�Z���Z. ۳���}�|��󺖵�隷b�(+���s�����,Z�q���6�w�	<����H�T�ވ�{�I�v�~u҉�by �rf��M�ub�Gq(�y���׶�������gʵ�m�=y���Am*+���A��:��w:��^ �R�v�~�����о�n�z
��d�9/�����A3�����x6�x-�����Z�<S��!xO�1DbS���Ȕ��_1(�����$�Z�m}T�_3��5�]������x(�tB����H�Ww;��
q(�\��`l�����EG2ݥO���5+��~~����1�Iύlu���|"�̙�����| {���H7Θ�����U�/��1y�H�	�.��S(�\��^�q׵ۑ�&��p��j~z�|w\��m=y�ߵ����ʹ8 }гA�1�������a���/�SۑOq����d���p�N�=���yo�� ^Z2NϜ���ߖ3ȩ <d'l�<2=����I^�>땷�}�ى��O��:<�F�$�
ے��ʒ� ��.��.�T�C��HO��fU-�7ܕ��Ϸ��$��^��V��bG�Dn�۠�����m��p}�6�/�4�Ql�m]�&Rz4�G�)P���{>z|�|�Ĵ,K���ux���\<���L�M� g���C���}�	<��7��{t��Q�<�c]��o���b��rf۸f��mc{iL���K���_sx`to�Ԗ5�P�=���러���s6�=;��ߖ󚍯aeQ�-J/�Ҕȧ�~!y��Af���{��.�n��5)�Z6<�'��C�^S�0��Ӂ>H>��H�$�c���9,����f��-������E$���g��Me)�ù��}�F�8�4�g{G��A�A�k�c��z𜉽bK�϶ֳ���m��ps��7�}c�>47��� qj��F�t,�ST+˧���i�����[�F��Bڪ��1�k����'�szLO�;�ġ�tY�gC�Q�9Q~    �&!'ύߦ���A#f��>CO�	<J^_h��0?���N�����Y}6n��L��L��{��Mb>:>�8G�s4�-��:J��\�*(��D���x���`+��Hw}bj��1�SiLu�z�B_0ȧ����}�n~�ű)���n����Q{�?ː[Ok/w��#�b�w�k��sf�\7�sr^CMH�.�{]/O��T<�v�W�.U;T�鱌<��#�U��ܻ�/ �t��2��o���ϓC�v*U3�&`�s���Q"���8d��L�?y����7n�zE�l��M��˥e\*-S�R7B���T1�k�M�(��:� �	�V�����g��N���X:BO ��H?�z���N-W���MR�s�%���}�;��Ax���Ii��BR�;�~��\��ѷ2�_Q^%
PS�������n:-���#���&�l�����@XY6��굴oB����k��v�W�����Yd��Ѣ�Z/���i�[�Z����~�ݜ��C<b���-�R��&hZ�Y�O��Ͱ����Z�L߰���C"?�w#��{^�}�	<����d\\�%r,@}�6�S���#�VJ%3}Dzu��z���oܛ��蒱�T���Ϟ/į�^7X���"�A^��k{\C�� ~�U�C]�͵���U�K�cVE�G�נ�E��q���i�ߩ��>��Ӥ'y��]�3�LŬ��-�v֢X�gq����eG�~����Ox��q�U5���'���»�hQ�j7��(v��r�-}���:�3�̬���Q�E��h��s*�G|��h�ϽM;j��닆1����x�
�ZP-t����nF�Jf�O��(�z�A,�U�`{cj#<������;����3�ˊ��o���3�+r�ב�]� 1̤n�R���/�D�⧠��$Gy\�J��/���x�x<�F���P(��Y��[ԯ��'b���R���]���Zo��kb(�@���]�<9�.��:�E�vk���!<EV��_���GP�}z�&�N;.�[��c��X�}�Q��~�Y
��߀�˯�Ҽ(W8��~���W5��ɔ?�,Z]*Q��M.�"�v�4�}����$��?
ύ��:�,��(��t�M�q�x�+�m==�&g�zG9Qm�*ڎ���S��Q��>e��n3���f{�V;�������F�g��#1�įoާ��P=��M�ָ?r�z���^$-�!mI�x�p޳�s<x��y���R�%���qM�"���������l�+�mx:�O��֩�%�?�8���O�	����`����X��՞�e�\�莕��R��V�V�غ}Б����gL���:�u��ڢ�axY�(Ǭ>�Q�	�)De&C\��O��[�t�M���w`o���W�!��w|�>��R��r�;�u�S�N!����G��)��#T�]��R�c�c6O��}����C�Bn+��f��pѻ��"�Qp�ķX�+���7���z���!By��}2��Ъ�^�9YPw=� y�Xr�:�뗥�����v`u�{ߋj�{�H�*3N7��C���`��f|���:��B��
�ī�UM�G{��u�X�q��ͯ!�������������=x�_)�G1�ˬ��5�hO���W��*ꤼ.�؆���A��Nd�MN�k4u5�G�u}�9�^b��T��/ ;5�/�'�����ʢk<�ۍd˪q=���*���d��b~E{x=B4�LJ��ݡ������k�o�Z8|�$7%�0���H���F{�oWk��[I��M��'�~8^Ȑ�ƾ������+;�W�Ƈ�Fmy�Ǝ�fˑY}�����֮��5��fp�^|�O����Pl,��@�cC�B!��c+�������5@y z�R�[9+����wf���k^���x|l0�}�P�jw�i���Ql�ua뵯��?%BzE�<κ����
3x�.v��]��'�~��B�ɹW�7ik<����I~�1/��w�]{�pd�b��i��ЗqAk�@�ȶ��{��������P+ �+�X���J�L�4a틮����4T�z�|���7�$�%����0>�߁�c��k��S��f-�ҭG2��c�R߭��蠑��7�c�L�ݏ������xF,�u9{?�{("r�,T�n3��K�����.�c���R�U���(��^�x^�ލ����>;�o�0bMk�N���kt��=����𒫰��-���9��T�!���O����{f|rz���j��G�_�,���ɖ]�;v�X�gĬW�!MJ���]�ɵ>�,���O�	�߅��7����Ԩ�;p���>E�ε��������~P;`?i�x��^R��`53>�����j�������Y|A����]G������	/a��(�]����J;O�?F���t5��!���,���*���
�ؓl�*Ւ2,�x�89Y7����ե=��E$��?�Ss�bs"~X�R������!����A�ޝ�zE�@�]T}��m���k䪨'��X#�@�]UM�+O<�g,���q��ɲ���ܶ_6��͌.�������Dvm�}��x0�wC��+&��D����B^~���N#=�zyC>�Z���[~�p�93u��n����Wdʛ����1��HW��I�<��������g�'����F!�_H\H\��*��{�ʤ�s�	����6<%�׳R�5����+�H�x�vwt���Ry�oA��zN��xVqQs���"RLV���Q�0���乁��Tg��J�6�/7��ջ��lz�aI�Sq�;��j���ACs��%���.v5��q�v�f�:imŭ� �N]��Lǽ1����[��"'ǚ*��y���������?�'�~ɛp�*#8���$6�L$�t�+ro��cj_kU��}w��(��s�C!�.�#�?���'=�̫}Uk�-S�1��gv~�������0%�
ەgnǫ\�]4}�gk���ܪ��-*�|rp�݉� �tP�7��b������u��yqC���o}��է��øbV��FB��Ϊ����`�ƹ�K]v��s�O_8�:{��Oz*�!CL\�te��H����x?�{�0�FH��	�ΐ.�ҥ�4ĿZ��II�(�Ԅ���Gz���v��j��9�y ぞ�e߬�"R8��䧟��P�{��M���z�s����hV�%Tk�f|*T�rt�ܶ��zl0�g�F
�5�Y�gˡ����\ݟ�/�k���+ԎG�:�Ӷ�3k����&f���ޅ��!��oU���T���&���V2�����|�c��~tѿG�	�@�ܷ���t'�
݇ͥE1�؞ީ�*�6ԥ:�����~�m��=�絬��,$둚$�9�ɶ��1w�^������Ur�������9�}��\��Q{���SOd�y4E2�����^"4�{�>(�q�*1)U���x#��F�ϫYo�;�&�u,�"���vB�w6�U"��1kDm��zvȈ�\)������Rnh�ai}8��^y\��u���������G��c�%W���1|ol=Kr��;�W+�3�h]|��ka��q�����[�Z�ԛ��Q���mj��j�'&ϡ:�o��c�Nd���v���~�ofc1��o�Ԃ��_"�e�ά�H縍�2�cr=�z	��:j��8����x`��@�U#��L��W ����%�>��c�j��V��z�a�Zz��zF�������4&�68>���x�O�������r�W�7J��e�d�/��������Uʃ[���L�e����x�X��l7�9>G�]�W�p{]�����(��߭��wr��K���u]mA�pd���\ͩ�cBcL������d�8�� ��l=����7#=291��k&^�����U�i6�_+�z��o�Lٓ;��c7×�#��"�1v��<Kk4H���9z-(�Z���\�Ǐ���Mꦽ�$����s�׵��'h��b�j��K)/���tۉ7�b?�䮢܋Ƭ�>5��с�nD�-�ϵd'��u�5SR�-ho   �Z�����ȕ5����t�_�����2����
� ��+Z����Y�<���q�|�t:S	zU`;_uI�������2���L�Z\����I�	�l�Jڞ�@Jb����2B�q��]�f+���mz���������x���|1elc�q�X�A*:F�*�fx��E7&Ot[2��@[�%�� >�e=ȩϡz��'֍D
�=Gx`7�}���z0�wC�>����LC�3o�e��;(�G���v�e�q_�#_�w�D����b���Z+n!_䆐Z���Y�C��/��gz��ϐ{n����Q�Z7e�%������d=3��&��>�BM���8���n|]A!�	<��I�K����c[��/��;������=����j���F��.5��c�}k�w[_P_'�wR���P���v����w�@�C��-e���#o�z����R�Ĺe����OoQ.F�h֭���4��H�����X3�K��#=-�u�j�G��M���c�,���C�kſ�~h���\Z����h���4)����a;������/�𤋮�)�A�S��@��������<o���!���p_�82���1L�(�{���?6��]ҫˈҰ�+�o�{�a�
�@s+�y�i�ю(����Ģ �w�yeY�;����X�[�Lz�F�a�7�G��st�Vx�ⅉ=��_����^��+�-�]l�4��D�9N���>�bST���G���X>�@= ꯹��\�7nTV�T9����=h۵J�]�'sn��'�����k�~���Kuk�|�$���@��=�&�=����#��Wب]5ZL#{\k��\��#��SL�5�:K���r���O���'��пBΜ��.��a$�9�V��C�4�_�)b��pꭸ�� /c7zH��=�Qmx6�憍���y@�B���� o���@�@1YPF�6�l�����>=h�Ǔ�,�Ρ��<��oy�	<����h��_��ŗ�
��Q�<�y���:y�=���ԧ��㌞�6��.��Fn��8�L�6�sRq]O�y�/h��FΑ˲�e��:��K:�DƴW�+Ob9S/o���	q ߑ�+��P�Q���>��w����q�G�I�3/��j�x�Yt�o�Ã�׃�qD���~$�jՔ�Z�$�A�����}h�}��\O��n<7����+-�Q~��S��:�"_������w��A߉rz�K��Һ�֢u	ǫL��V
ՑC�5���G
:'��7�َ���`��at�Q�e�yT��=X[���q��H��R�r7���ڋ>Bl	�s'6��;ŲibD�M�<	����jIn|t, ��� ��!|��6�y'�R�nV_�~[���Z���'�ޟ�w��j0�	��c2�L�7Ak�c��zTǤ�f�Fh��=�����i�/����X-G�J}1�^-�^�n�S�Fk�lfw����ȉT���,�Y$]�7��ϥ�b\X���M��A�ѭg��:F�p��jZ_���"C&������|��y�xt�#�'�����b�l��Gގ�ywԬ�Cr�Q~��'����Ӯ�nq�� ��)���b������}ZO*��o��)̟F��6^ʋ����~Md�b^+��/�W,vԌ~�~_}���xp\��E�o�4��˾��z��]�vL�k��~	�<ztM���*'�����s�x7v���,���O�	�o�w��ϡ�û5TG�m�:y�!��@��>Eb�<�v�<z��"�⊁��O�v�ԥ[��68M�z�`��Э�B��L
~g���]^���f�q'%�������}���x��c��[���lF�ֲ��4q�<&�­J��˓�~�$��p���͑�葓K��ƅg�.�����]{"�C{zr��K��K���_=�9=aa�|���.�sߩj�SR2��L�!�+���C�1�|5T[j��2�_@��n�(�O;��m&��m���8?�Rk��	2�!3�q�s���q���oa�G��E5U& �����^���y�M��p�����t?9�Y�O���3�7��R �~�+���cȭ��_I=�����ad����[��Q�P�RIB�Ն�W�~@�9��N�m/5�In*͇%u3����_��C������2!S�ī;;cI��vd���=�;�zX,�\b�&�X�'�ޯ�c���!C*m�{\�xӠx�q͎5{W�������}�;1�}n����)�r>���{3�Pݔ��q�AHM��j�L�X�	����m�5{ѧ�*�A��ı�g�Q�}?<>S?~���=EO�	�o���_1dȩ�$�Y_I��k�b)\�����5�=}<�@_�<��pA��'e�Ӻ����R���I�Z�������T9�4F/���Y�L�9T����m�U��W>5�8�g<V��Ǯ��x�x<O|D��!W����ɱ6ٽ�tƵ��L���R����c���U^���h��7�rٸy���}���q�w�I��jM��Y�Ђl��U���;��3�˯_�!)����i2n/���Ñ%w�?���u�g�{���x�%��N����w�M)g^���c���(��1c�א&���2B��K�1:�j�pt��ab�/҈>yѫe�,��֭Q��TEo47{9��k�����~�9<��:���ؽf��3�ύx��c���[���x�K���=�bs��!<õ�<�Ѻ��'���p��=��@_-VJ��f��*��U�(�m������u�cB/�2r���<��h0���!����ux��5ye��_/��=��%o����=2>Vf�ڶ���d�|?�ӡK={#ty���*K������{�(l��ӏ__�'�^ �ލԾObTɷ6�5ӧG�ĵ��^��U������䱺yY!=(�|�JO�����'����Ax��!&�֨���0�T�ص���L�H�����X[�#�Ә�+�k����]'լr��?l=��x_���K`�G0���J����G�?��ćK�.�Jcz�>UӒ��I^y���Xn����F��oзY�'����������Qc���&�^&�<��4���1���&]����Oa�S�����y��ȷX�'�����9^_dz7`�S�7F�L�ÿXl?c�����Ȓ�̋�ҔC�>-I�̷�G���x��yk���[��y���W�|��E�cwu���������B���א�xO�	<�'���xO�	<�'���xO�	<�'���xO�	<�'���xO�	<�'��?������_���5yO�      �   :   x�3�472�500����q�R8�����G6��pdޑ�Fz`�i�i����� ��      �   )   x�3�4���t�34��3 .#�����L8F��� ���      �   &   x�3�N�(HT���+I�R�LI�I,:��+F��� ��	�      �      x������ � �      �      x������ � �      �   ?   x�34�����t�34�4�3 N(��М�$�����7AW`Q 2���ӄ=... �~�      �      x�3��472�500�4�35 �=... 9"      �      x������ � �      �      x������ � �      '      x������ � �      �   ^   x���q�	64��v��Sqt�qU04V�u;���P� 8c��,9�<����}B9��l ��]=�|��C�\#�P���qqq S=�     