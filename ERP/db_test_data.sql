PGDMP         ;                {            ths_erp    14.1    14.1 �              0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false                       0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false                       0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false                       1262    134555    ths_erp    DATABASE     d   CREATE DATABASE ths_erp WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'Turkish_Turkey.1254';
    DROP DATABASE ths_erp;
             	   ths_admin    false                       0    0    SCHEMA public    ACL     {   REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT CREATE ON SCHEMA public TO PUBLIC;
GRANT ALL ON SCHEMA public TO ths_admin;
                   postgres    false    8                        3079    134556    dblink 	   EXTENSION     :   CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;
    DROP EXTENSION dblink;
                   false                       0    0    EXTENSION dblink    COMMENT     _   COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';
                        false    2                        3079    134602    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                   false                       0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                        false    3                        3079    134639 
   pgrowlocks 	   EXTENSION     >   CREATE EXTENSION IF NOT EXISTS pgrowlocks WITH SCHEMA public;
    DROP EXTENSION pgrowlocks;
                   false                       0    0    EXTENSION pgrowlocks    COMMENT     I   COMMENT ON EXTENSION pgrowlocks IS 'show row-level locking information';
                        false    4                        3079    134641    pldbgapi 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pldbgapi WITH SCHEMA public;
    DROP EXTENSION pldbgapi;
                   false                       0    0    EXTENSION pldbgapi    COMMENT     Y   COMMENT ON EXTENSION pldbgapi IS 'server-side support for debugging PL/pgSQL functions';
                        false    5                        3079    134678    postgres_fdw 	   EXTENSION     @   CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;
    DROP EXTENSION postgres_fdw;
                   false                       0    0    EXTENSION postgres_fdw    COMMENT     [   COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';
                        false    6                       0    0    FUNCTION armor(bytea)    ACL     8   GRANT ALL ON FUNCTION public.armor(bytea) TO ths_admin;
          public          postgres    false    497                       0    0 %   FUNCTION armor(bytea, text[], text[])    ACL     H   GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO ths_admin;
          public          postgres    false    498            �           1255    134685    audit()    FUNCTION       CREATE FUNCTION public.audit() RETURNS trigger
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
       public       	   ths_admin    false                       0    0    FUNCTION audit()    ACL     i   REVOKE ALL ON FUNCTION public.audit() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.audit() FROM ths_admin;
          public       	   ths_admin    false    506                       0    0    FUNCTION crypt(text, text)    ACL     =   GRANT ALL ON FUNCTION public.crypt(text, text) TO ths_admin;
          public          postgres    false    507                       0    0    FUNCTION dearmor(text)    ACL     9   GRANT ALL ON FUNCTION public.dearmor(text) TO ths_admin;
          public          postgres    false    453                       0    0 $   FUNCTION decrypt(bytea, bytea, text)    ACL     G   GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO ths_admin;
          public          postgres    false    508                        0    0 .   FUNCTION decrypt_iv(bytea, bytea, bytea, text)    ACL     Q   GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO ths_admin;
          public          postgres    false    509            !           0    0    FUNCTION digest(bytea, text)    ACL     ?   GRANT ALL ON FUNCTION public.digest(bytea, text) TO ths_admin;
          public          postgres    false    510            "           0    0    FUNCTION digest(text, text)    ACL     >   GRANT ALL ON FUNCTION public.digest(text, text) TO ths_admin;
          public          postgres    false    426            #           0    0 $   FUNCTION encrypt(bytea, bytea, text)    ACL     G   GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO ths_admin;
          public          postgres    false    511            $           0    0 .   FUNCTION encrypt_iv(bytea, bytea, bytea, text)    ACL     Q   GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO ths_admin;
          public          postgres    false    429            %           0    0 "   FUNCTION gen_random_bytes(integer)    ACL     E   GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO ths_admin;
          public          postgres    false    430            &           0    0    FUNCTION gen_random_uuid()    ACL     =   GRANT ALL ON FUNCTION public.gen_random_uuid() TO ths_admin;
          public          postgres    false    512            '           0    0    FUNCTION gen_salt(text)    ACL     :   GRANT ALL ON FUNCTION public.gen_salt(text) TO ths_admin;
          public          postgres    false    513            (           0    0     FUNCTION gen_salt(text, integer)    ACL     C   GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO ths_admin;
          public          postgres    false    428            )           0    0 !   FUNCTION hmac(bytea, bytea, text)    ACL     D   GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO ths_admin;
          public          postgres    false    514            *           0    0    FUNCTION hmac(text, text, text)    ACL     B   GRANT ALL ON FUNCTION public.hmac(text, text, text) TO ths_admin;
          public          postgres    false    427            �           1255    134686    personel_adsoyad()    FUNCTION     ]  CREATE FUNCTION public.personel_adsoyad() RETURNS trigger
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
       public       	   ths_admin    false            +           0    0    FUNCTION personel_adsoyad()    ACL        REVOKE ALL ON FUNCTION public.personel_adsoyad() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.personel_adsoyad() FROM ths_admin;
          public       	   ths_admin    false    484            ,           0    0 >   FUNCTION pgp_armor_headers(text, OUT key text, OUT value text)    ACL     a   GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO ths_admin;
          public          postgres    false    515            -           0    0    FUNCTION pgp_key_id(bytea)    ACL     =   GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO ths_admin;
          public          postgres    false    454            .           0    0 &   FUNCTION pgp_pub_decrypt(bytea, bytea)    ACL     I   GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO ths_admin;
          public          postgres    false    455            /           0    0 ,   FUNCTION pgp_pub_decrypt(bytea, bytea, text)    ACL     O   GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO ths_admin;
          public          postgres    false    456            0           0    0 2   FUNCTION pgp_pub_decrypt(bytea, bytea, text, text)    ACL     U   GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO ths_admin;
          public          postgres    false    457            1           0    0 ,   FUNCTION pgp_pub_decrypt_bytea(bytea, bytea)    ACL     O   GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO ths_admin;
          public          postgres    false    458            2           0    0 2   FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text)    ACL     U   GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO ths_admin;
          public          postgres    false    459            3           0    0 8   FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text)    ACL     [   GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO ths_admin;
          public          postgres    false    460            4           0    0 %   FUNCTION pgp_pub_encrypt(text, bytea)    ACL     H   GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO ths_admin;
          public          postgres    false    516            5           0    0 +   FUNCTION pgp_pub_encrypt(text, bytea, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO ths_admin;
          public          postgres    false    517            6           0    0 ,   FUNCTION pgp_pub_encrypt_bytea(bytea, bytea)    ACL     O   GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO ths_admin;
          public          postgres    false    445            7           0    0 2   FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text)    ACL     U   GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO ths_admin;
          public          postgres    false    461            8           0    0 %   FUNCTION pgp_sym_decrypt(bytea, text)    ACL     H   GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO ths_admin;
          public          postgres    false    518            9           0    0 +   FUNCTION pgp_sym_decrypt(bytea, text, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO ths_admin;
          public          postgres    false    519            :           0    0 +   FUNCTION pgp_sym_decrypt_bytea(bytea, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO ths_admin;
          public          postgres    false    434            ;           0    0 1   FUNCTION pgp_sym_decrypt_bytea(bytea, text, text)    ACL     T   GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO ths_admin;
          public          postgres    false    435            <           0    0 $   FUNCTION pgp_sym_encrypt(text, text)    ACL     G   GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO ths_admin;
          public          postgres    false    436            =           0    0 *   FUNCTION pgp_sym_encrypt(text, text, text)    ACL     M   GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO ths_admin;
          public          postgres    false    520            >           0    0 +   FUNCTION pgp_sym_encrypt_bytea(bytea, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO ths_admin;
          public          postgres    false    437            ?           0    0 1   FUNCTION pgp_sym_encrypt_bytea(bytea, text, text)    ACL     T   GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO ths_admin;
          public          postgres    false    438            @           0    0 �   FUNCTION pgrowlocks(relname text, OUT locked_row tid, OUT locker xid, OUT multi boolean, OUT xids xid[], OUT modes text[], OUT pids integer[])    ACL     �   GRANT ALL ON FUNCTION public.pgrowlocks(relname text, OUT locked_row tid, OUT locker xid, OUT multi boolean, OUT xids xid[], OUT modes text[], OUT pids integer[]) TO ths_admin;
          public          postgres    false    521            A           0    0    FUNCTION postgres_fdw_handler()    ACL     B   GRANT ALL ON FUNCTION public.postgres_fdw_handler() TO ths_admin;
          public          postgres    false    480            B           0    0 ,   FUNCTION postgres_fdw_validator(text[], oid)    ACL     O   GRANT ALL ON FUNCTION public.postgres_fdw_validator(text[], oid) TO ths_admin;
          public          postgres    false    481            �           1255    134687    spexists_hesap_kodu(text)    FUNCTION     0  CREATE FUNCTION public.spexists_hesap_kodu(phesap_kodu text) RETURNS boolean
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
       public          postgres    false            C           0    0 .   FUNCTION spexists_hesap_kodu(phesap_kodu text)    ACL     �   REVOKE ALL ON FUNCTION public.spexists_hesap_kodu(phesap_kodu text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spexists_hesap_kodu(phesap_kodu text) TO ths_admin;
          public          postgres    false    482            �           1255    134688    spget_crypted_data(text)    FUNCTION     �   CREATE FUNCTION public.spget_crypted_data(pval text) RETURNS text
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
       public          postgres    false            D           0    0 &   FUNCTION spget_crypted_data(pval text)    ACL     I   GRANT ALL ON FUNCTION public.spget_crypted_data(pval text) TO ths_admin;
          public          postgres    false    483            �           1255    134689 /   spget_lang_text(text, text, text, bigint, text)    FUNCTION     �  CREATE FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) RETURNS character varying
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
       public          postgres    false            E           0    0 n   FUNCTION spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text)    ACL     "  REVOKE ALL ON FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) TO ths_admin;
          public          postgres    false    485            �           1255    134690 -   spget_lang_text(text, text, text, text, text)    FUNCTION     �  CREATE FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) RETURNS character varying
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
       public          postgres    false            F           0    0 n   FUNCTION spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text)    ACL     "  REVOKE ALL ON FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) TO ths_admin;
          public          postgres    false    487            �           1255    134691    spget_prs_personel_id_list()    FUNCTION     j  CREATE FUNCTION public.spget_prs_personel_id_list() RETURNS TABLE(id integer, emp_name character varying, emp_surname character varying, emp_full_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
		SELECT  prs_personel.id, prs_personel.ad, prs_personel.soyad, prs_personel.ad_soyad FROM prs_personel
		WHERE is_aktif ORDER BY 4;
END
$$;
 3   DROP FUNCTION public.spget_prs_personel_id_list();
       public          postgres    false            G           0    0 %   FUNCTION spget_prs_personel_id_list()    ACL     �   REVOKE ALL ON FUNCTION public.spget_prs_personel_id_list() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_prs_personel_id_list() TO ths_admin;
          public          postgres    false    488            �           1255    134692 "   spget_rct_hammadde_maliyet(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) RETURNS numeric
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
       public          postgres    false            H           0    0 :   FUNCTION spget_rct_hammadde_maliyet(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    486            �           1255    134693 !   spget_rct_iscilik_maliyet(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) RETURNS numeric
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
       public          postgres    false            I           0    0 9   FUNCTION spget_rct_iscilik_maliyet(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    489            �           1255    134694    spget_rct_toplam(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_toplam(prct_recete_id bigint) RETURNS numeric
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
       public          postgres    false            J           0    0 0   FUNCTION spget_rct_toplam(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_toplam(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_toplam(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    490            �           1255    134695 "   spget_rct_yan_urun_maliyet(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) RETURNS numeric
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
       public          postgres    false            K           0    0 :   FUNCTION spget_rct_yan_urun_maliyet(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    491            �           1255    134696 &   spget_sys_kalite_form_no(text, bigint)    FUNCTION     I  CREATE FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) RETURNS character varying
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
       public          postgres    false            L           0    0 H   FUNCTION spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) TO ths_admin;
          public          postgres    false    492            �           1255    134697    spget_sys_lang_id(text)    FUNCTION     �   CREATE FUNCTION public.spget_sys_lang_id(planguage text) RETURNS integer
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
       public          postgres    false            M           0    0 *   FUNCTION spget_sys_lang_id(planguage text)    ACL     �   REVOKE ALL ON FUNCTION public.spget_sys_lang_id(planguage text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_sys_lang_id(planguage text) TO ths_admin;
          public          postgres    false    493            �           1255    134698 '   spget_sys_quality_form_type_id(integer)    FUNCTION     �  CREATE FUNCTION public.spget_sys_quality_form_type_id(ptype integer) RETURNS integer
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
       public          postgres    false            N           0    0 6   FUNCTION spget_sys_quality_form_type_id(ptype integer)    ACL     Y   GRANT ALL ON FUNCTION public.spget_sys_quality_form_type_id(ptype integer) TO ths_admin;
          public          postgres    false    499            �           1255    134699    spget_sys_user_id_list()    FUNCTION       CREATE FUNCTION public.spget_sys_user_id_list() RETURNS TABLE(id bigint, user_name character varying)
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
       public       	   ths_admin    false            O           0    0 !   FUNCTION spget_sys_user_id_list()    ACL     D   REVOKE ALL ON FUNCTION public.spget_sys_user_id_list() FROM PUBLIC;
          public       	   ths_admin    false    500            
           1255    134700 1   spget_year_week(date, character varying, boolean)    FUNCTION     �  CREATE FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean DEFAULT true) RETURNS character varying
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
       public          postgres    false            P           0    0 Y   FUNCTION spget_year_week(pdate date, pseparate character varying, pis_year_first boolean)    ACL     �   REVOKE ALL ON FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean) TO ths_admin;
          public          postgres    false    522            �           1255    134701    splogin(text, text, text, text)    FUNCTION     �  CREATE FUNCTION public.splogin(puser_name text, puser_pass text, papp_version text, pmac_address text) RETURNS integer
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
       public       	   ths_admin    false            �           1255    134702 (   spset_user_password(text, text, integer)    FUNCTION       CREATE FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) RETURNS boolean
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
       public          postgres    false            Q           0    0 H   FUNCTION spset_user_password(oldpass text, newpass text, userid integer)    ACL     �   REVOKE ALL ON FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) TO ths_admin;
          public          postgres    false    501            �           1255    134703    spvarsayilan_para_birimi()    FUNCTION     �   CREATE FUNCTION public.spvarsayilan_para_birimi() RETURNS character varying
    LANGUAGE sql
    AS $$
	SELECT para_birimi FROM sys_para_birimi WHERE is_varsayilan LIMIT 1;
$$;
 1   DROP FUNCTION public.spvarsayilan_para_birimi();
       public          postgres    false            R           0    0 #   FUNCTION spvarsayilan_para_birimi()    ACL     �   REVOKE ALL ON FUNCTION public.spvarsayilan_para_birimi() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spvarsayilan_para_birimi() TO ths_admin;
          public          postgres    false    502            �           1255    134704    spvarsayilan_urun_tipi_id()    FUNCTION     �   CREATE FUNCTION public.spvarsayilan_urun_tipi_id() RETURNS integer
    LANGUAGE sql
    AS $$
	SELECT id FROM set_stk_urun_tipi WHERE urun_tipi='HAMMADDE';
$$;
 2   DROP FUNCTION public.spvarsayilan_urun_tipi_id();
       public          postgres    false            S           0    0 $   FUNCTION spvarsayilan_urun_tipi_id()    ACL     �   REVOKE ALL ON FUNCTION public.spvarsayilan_urun_tipi_id() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spvarsayilan_urun_tipi_id() TO ths_admin;
          public          postgres    false    503            �           1255    134705    table_listen(text)    FUNCTION     �   CREATE FUNCTION public.table_listen(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT listen table_name;
  RETURN;
END;
$$;
 4   DROP FUNCTION public.table_listen(table_name text);
       public          postgres    false            T           0    0 &   FUNCTION table_listen(table_name text)    ACL     �   REVOKE ALL ON FUNCTION public.table_listen(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_listen(table_name text) TO ths_admin;
          public          postgres    false    505            �           1255    134706    table_notify()    FUNCTION     �  CREATE FUNCTION public.table_notify() RETURNS trigger
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
       public       	   ths_admin    false            U           0    0    FUNCTION table_notify()    ACL     w   REVOKE ALL ON FUNCTION public.table_notify() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.table_notify() FROM ths_admin;
          public       	   ths_admin    false    494            �           1255    134707    table_notify(text)    FUNCTION     �   CREATE FUNCTION public.table_notify(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT notify table_name;
  RETURN;
END;
$$;
 4   DROP FUNCTION public.table_notify(table_name text);
       public          postgres    false            V           0    0 &   FUNCTION table_notify(table_name text)    ACL     �   REVOKE ALL ON FUNCTION public.table_notify(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_notify(table_name text) TO ths_admin;
          public          postgres    false    504            �           1255    134708    table_unlisten(text)    FUNCTION     �   CREATE FUNCTION public.table_unlisten(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT unlisten table_name;
  RETURN;
END;
$$;
 6   DROP FUNCTION public.table_unlisten(table_name text);
       public          postgres    false            W           0    0 (   FUNCTION table_unlisten(table_name text)    ACL     �   REVOKE ALL ON FUNCTION public.table_unlisten(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_unlisten(table_name text) TO ths_admin;
          public          postgres    false    496            �            1259    134709    a_invoices_id_seq    SEQUENCE     z   CREATE SEQUENCE public.a_invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.a_invoices_id_seq;
       public          postgres    false            �            1259    134710    audits    TABLE     �  CREATE TABLE public.audits (
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
       public         heap 	   ths_admin    false            �            1259    134715    audit_id_seq    SEQUENCE     �   ALTER TABLE public.audits ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    221            �            1259    134716    ch_bankalar    TABLE     �   CREATE TABLE public.ch_bankalar (
    id bigint NOT NULL,
    banka_adi character varying(64) NOT NULL,
    swift_kodu character varying(16)
);
    DROP TABLE public.ch_bankalar;
       public         heap 	   ths_admin    false            �            1259    134719    ch_banka_id_seq    SEQUENCE     �   ALTER TABLE public.ch_bankalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_banka_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    223            �            1259    134720    ch_banka_subeleri    TABLE     �   CREATE TABLE public.ch_banka_subeleri (
    id bigint NOT NULL,
    banka_id bigint NOT NULL,
    sube_kodu integer NOT NULL,
    sube_adi character varying(64) NOT NULL,
    sehir_id bigint NOT NULL
);
 %   DROP TABLE public.ch_banka_subeleri;
       public         heap 	   ths_admin    false            �            1259    134723    ch_banka_subesi_id_seq    SEQUENCE     �   ALTER TABLE public.ch_banka_subeleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_banka_subesi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    225            �            1259    134724    ch_bolgeler    TABLE     f   CREATE TABLE public.ch_bolgeler (
    id bigint NOT NULL,
    bolge character varying(32) NOT NULL
);
    DROP TABLE public.ch_bolgeler;
       public         heap 	   ths_admin    false            �            1259    134727    ch_bolge_id_seq    SEQUENCE     �   ALTER TABLE public.ch_bolgeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_bolge_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    227            �            1259    134728    ch_doviz_kurlari    TABLE     �   CREATE TABLE public.ch_doviz_kurlari (
    id bigint NOT NULL,
    kur_tarihi date NOT NULL,
    kur numeric(10,4) NOT NULL,
    para character varying(3)
);
 $   DROP TABLE public.ch_doviz_kurlari;
       public         heap 	   ths_admin    false            �            1259    134731 
   ch_gruplar    TABLE     d   CREATE TABLE public.ch_gruplar (
    id bigint NOT NULL,
    grup character varying(16) NOT NULL
);
    DROP TABLE public.ch_gruplar;
       public         heap 	   ths_admin    false            �            1259    134734    ch_hesaplar    TABLE     �  CREATE TABLE public.ch_hesaplar (
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
       public         heap 	   ths_admin    false            �            1259    134742    ch_hesap_karti_id_seq    SEQUENCE     �   ALTER TABLE public.ch_hesaplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_hesap_karti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    231            �            1259    134743    ch_hesap_planlari    TABLE     �   CREATE TABLE public.ch_hesap_planlari (
    id bigint NOT NULL,
    plan_kodu character varying(16) NOT NULL,
    plan_adi character varying(128) NOT NULL,
    seviye smallint NOT NULL
);
 %   DROP TABLE public.ch_hesap_planlari;
       public         heap 	   ths_admin    false            �            1259    134746    mhs_doviz_kuru_id_seq    SEQUENCE     �   ALTER TABLE public.ch_doviz_kurlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_doviz_kuru_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    229            �            1259    134747    mhs_fis_detaylari    TABLE     a   CREATE TABLE public.mhs_fis_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL
);
 %   DROP TABLE public.mhs_fis_detaylari;
       public         heap 	   ths_admin    false            �            1259    134750    mhs_fis_detaylari_id_seq    SEQUENCE     �   ALTER TABLE public.mhs_fis_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_fis_detaylari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    235            �            1259    134751 
   mhs_fisler    TABLE     u   CREATE TABLE public.mhs_fisler (
    id bigint NOT NULL,
    yevmiye_no integer NOT NULL,
    yevmiye_tarihi date
);
    DROP TABLE public.mhs_fisler;
       public         heap 	   ths_admin    false            �            1259    134754    mhs_fisler_id_seq    SEQUENCE     �   ALTER TABLE public.mhs_fisler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_fisler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    237            �            1259    134755    mhs_transfer_kodlari    TABLE     �   CREATE TABLE public.mhs_transfer_kodlari (
    id bigint NOT NULL,
    transfer_kodu character varying(32) NOT NULL,
    aciklama character varying(128) NOT NULL,
    hesap_kodu character varying(16) NOT NULL
);
 (   DROP TABLE public.mhs_transfer_kodlari;
       public         heap 	   ths_admin    false            �            1259    134758    mhs_transfer_kodlari_id_seq    SEQUENCE     �   ALTER TABLE public.mhs_transfer_kodlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_transfer_kodlari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    239            �            1259    134759    prs_ehliyetler    TABLE     n   CREATE TABLE public.prs_ehliyetler (
    id bigint NOT NULL,
    ehliyet_id bigint,
    personel_id bigint
);
 "   DROP TABLE public.prs_ehliyetler;
       public         heap 	   ths_admin    false            �            1259    134762    prs_lisan_bilgileri    TABLE     �   CREATE TABLE public.prs_lisan_bilgileri (
    id bigint NOT NULL,
    lisan_id bigint,
    okuma_id bigint,
    yazma_id bigint,
    konusma_id bigint,
    personel_id bigint
);
 '   DROP TABLE public.prs_lisan_bilgileri;
       public         heap 	   ths_admin    false            �            1259    134765    prs_lisan_bilgisi_id_seq    SEQUENCE     �   ALTER TABLE public.prs_lisan_bilgileri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_lisan_bilgisi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    242            �            1259    134766    prs_personel_ehliyetleri_id_seq    SEQUENCE     �   ALTER TABLE public.prs_ehliyetler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_personel_ehliyetleri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    241            �            1259    134767    prs_personeller    TABLE     �  CREATE TABLE public.prs_personeller (
    id bigint NOT NULL,
    ad character varying(24) NOT NULL,
    soyad character varying(24) NOT NULL,
    ad_soyad character varying(48) NOT NULL,
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
       public         heap 	   ths_admin    false            X           0    0    COLUMN prs_personeller.cinsiyet    COMMENT     F   COMMENT ON COLUMN public.prs_personeller.cinsiyet IS '1 Man
2 Woman';
          public       	   ths_admin    false    245            Y           0    0 &   COLUMN prs_personeller.askerlik_durumu    COMMENT     e   COMMENT ON COLUMN public.prs_personeller.askerlik_durumu IS '1 Yapti, 2 Yapmadi, 3 Tecilli, 4 Muaf';
          public       	   ths_admin    false    245            Z           0    0 #   COLUMN prs_personeller.medeni_durum    COMMENT     L   COMMENT ON COLUMN public.prs_personeller.medeni_durum IS '1 Evli, 2 Bekar';
          public       	   ths_admin    false    245            �            1259    134776    prs_personel_id_seq    SEQUENCE     �   ALTER TABLE public.prs_personeller ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_personel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    245            �            1259    134777    urt_iscilikler    TABLE     �   CREATE TABLE public.urt_iscilikler (
    id bigint NOT NULL,
    gider_kodu character varying(16) NOT NULL,
    gider_adi character varying(128),
    fiyat numeric(18,6) NOT NULL,
    birim_id bigint NOT NULL,
    gider_tipi smallint NOT NULL
);
 "   DROP TABLE public.urt_iscilikler;
       public         heap 	   ths_admin    false            �            1259    134780    rct_iscilik_gideri_id_seq    SEQUENCE     �   ALTER TABLE public.urt_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_iscilik_gideri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    247            �            1259    134781    urt_paket_hammadde_detaylari    TABLE     �   CREATE TABLE public.urt_paket_hammadde_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    recete_id bigint,
    stok_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 0   DROP TABLE public.urt_paket_hammadde_detaylari;
       public         heap 	   ths_admin    false            �            1259    134784    rct_paket_hammadde_detay_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_hammadde_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_hammadde_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    249            �            1259    134785    urt_paket_hammaddeler    TABLE     u   CREATE TABLE public.urt_paket_hammaddeler (
    id bigint NOT NULL,
    paket_adi character varying(128) NOT NULL
);
 )   DROP TABLE public.urt_paket_hammaddeler;
       public         heap 	   ths_admin    false            �            1259    134788    rct_paket_hammadde_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    251            �            1259    134789    urt_paket_iscilik_detaylari    TABLE     �   CREATE TABLE public.urt_paket_iscilik_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    iscilik_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 /   DROP TABLE public.urt_paket_iscilik_detaylari;
       public         heap 	   ths_admin    false            �            1259    134792    rct_paket_iscilik_detay_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_iscilik_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_iscilik_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    253            �            1259    134793    urt_paket_iscilikler    TABLE     t   CREATE TABLE public.urt_paket_iscilikler (
    id bigint NOT NULL,
    paket_adi character varying(128) NOT NULL
);
 (   DROP TABLE public.urt_paket_iscilikler;
       public         heap 	   ths_admin    false                        1259    134796    rct_paket_iscilik_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    255                       1259    134797    urt_recete_hammaddeler    TABLE     �   CREATE TABLE public.urt_recete_hammaddeler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    recete_id bigint,
    stok_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL,
    fire_orani numeric(18,6) DEFAULT 0 NOT NULL
);
 *   DROP TABLE public.urt_recete_hammaddeler;
       public         heap 	   ths_admin    false                       1259    134801    rct_recete_hammadde_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    257                       1259    134802    urt_receteler    TABLE     �   CREATE TABLE public.urt_receteler (
    id bigint NOT NULL,
    urun_kodu character varying(32) NOT NULL,
    urun_adi character varying(128) NOT NULL,
    ornek_miktari numeric(18,6) DEFAULT 1,
    aciklama character varying(128)
);
 !   DROP TABLE public.urt_receteler;
       public         heap 	   ths_admin    false                       1259    134806    rct_recete_id_seq    SEQUENCE     �   ALTER TABLE public.urt_receteler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    259                       1259    134807    urt_recete_iscilikler    TABLE     �   CREATE TABLE public.urt_recete_iscilikler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    iscilik_kodu character varying(16) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 )   DROP TABLE public.urt_recete_iscilikler;
       public         heap 	   ths_admin    false                       1259    134810    rct_recete_iscilik_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    261                       1259    134811    urt_recete_paket_hammaddeler    TABLE     �   CREATE TABLE public.urt_recete_paket_hammaddeler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    paket_id bigint NOT NULL,
    miktar numeric(18,6)
);
 0   DROP TABLE public.urt_recete_paket_hammaddeler;
       public         heap 	   ths_admin    false                       1259    134814     rct_recete_paket_hammadde_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_paket_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_paket_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    263            	           1259    134815    urt_recete_paket_iscilikler    TABLE     �   CREATE TABLE public.urt_recete_paket_iscilikler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    paket_id bigint NOT NULL,
    miktar numeric(18,6)
);
 /   DROP TABLE public.urt_recete_paket_iscilikler;
       public         heap 	   ths_admin    false            
           1259    134818    rct_recete_paket_iscilik_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_paket_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_paket_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    265                       1259    134819    sat_fatura_detaylari    TABLE     �   CREATE TABLE public.sat_fatura_detaylari (
    id bigint NOT NULL,
    header_id bigint,
    teklif_detay_id bigint,
    siparis_detay_id bigint,
    irsaliye_detay_id bigint
);
 (   DROP TABLE public.sat_fatura_detaylari;
       public         heap 	   ths_admin    false                       1259    134822    sat_fatura_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_fatura_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_fatura_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    267                       1259    134823    sat_faturalar    TABLE     �   CREATE TABLE public.sat_faturalar (
    id bigint NOT NULL,
    fatura_no character varying(16),
    fatura_tarihi timestamp without time zone,
    teklif_id bigint,
    siparis_id bigint,
    irsaliye_id bigint
);
 !   DROP TABLE public.sat_faturalar;
       public         heap 	   ths_admin    false                       1259    134826    sat_fatura_id_seq    SEQUENCE     �   ALTER TABLE public.sat_faturalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_fatura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    269                       1259    134827    sat_irsaliye_detaylari    TABLE     �   CREATE TABLE public.sat_irsaliye_detaylari (
    id bigint NOT NULL,
    header_id bigint,
    teklif_detay_id bigint,
    siparis_detay_id bigint,
    fatura_detay_id bigint
);
 *   DROP TABLE public.sat_irsaliye_detaylari;
       public         heap 	   ths_admin    false                       1259    134830    sat_irsaliye_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_irsaliye_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_irsaliye_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    271                       1259    134831    sat_irsaliyeler    TABLE     �   CREATE TABLE public.sat_irsaliyeler (
    id bigint NOT NULL,
    irsaliye_no character varying(16),
    irsaliye_tarihi timestamp without time zone,
    teklif_id bigint,
    siparis_id bigint,
    fatura_id bigint
);
 #   DROP TABLE public.sat_irsaliyeler;
       public         heap 	   ths_admin    false                       1259    134834    sat_irsaliye_id_seq    SEQUENCE     �   ALTER TABLE public.sat_irsaliyeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_irsaliye_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    273                       1259    134835    sat_siparis_detaylari    TABLE     �  CREATE TABLE public.sat_siparis_detaylari (
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
       public         heap 	   ths_admin    false                       1259    134858    sat_siparis_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_siparis_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_siparis_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    275                       1259    134859    sat_siparisler    TABLE     �  CREATE TABLE public.sat_siparisler (
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
       public         heap 	   ths_admin    false                       1259    134880    sat_siparis_id_seq    SEQUENCE     �   ALTER TABLE public.sat_siparisler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_siparis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    277                       1259    134881    set_sls_order_status    TABLE     �   CREATE TABLE public.set_sls_order_status (
    id bigint NOT NULL,
    siparis_durum character varying(32) NOT NULL,
    aciklama character varying(64)
);
 (   DROP TABLE public.set_sls_order_status;
       public         heap 	   ths_admin    false                       1259    134884    stk_gruplar    TABLE       CREATE TABLE public.stk_gruplar (
    id bigint NOT NULL,
    grup character varying(32) NOT NULL,
    kdv_orani double precision NOT NULL,
    satis_hesap_kodu character varying(16),
    satis_iade_hesap_kodu character varying(16),
    alis_hesap_kodu character varying(16),
    alis_iade_hesap_kodu character varying(16),
    ihracat_hesap_kodu character varying(16),
    ihracat_iade_hesap_kodu character varying(16),
    hammadde_hesap_kodu character varying(16),
    mamul_hesap_kodu character varying(16)
);
    DROP TABLE public.stk_gruplar;
       public         heap 	   ths_admin    false                       1259    134887    stk_kartlar    TABLE     �  CREATE TABLE public.stk_kartlar (
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
    DROP TABLE public.stk_kartlar;
       public         heap 	   ths_admin    false    503    502    502    502                       1259    134908    sys_sehirler    TABLE     �   CREATE TABLE public.sys_sehirler (
    id bigint NOT NULL,
    sehir character varying(32) NOT NULL,
    plaka_kodu integer,
    ulke_id bigint,
    bolge_id bigint
);
     DROP TABLE public.sys_sehirler;
       public         heap 	   ths_admin    false                       1259    134911    sat_siparis_rapor    VIEW     )  CREATE VIEW public.sat_siparis_rapor AS
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
       public       	   ths_admin    false    277    277    275    275    277    282    282    281    281    275    275    280    279    279    277    277    277    277    277    275    275    275    277    277    280                       1259    134916    sat_teklif_detaylari    TABLE     �  CREATE TABLE public.sat_teklif_detaylari (
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
       public         heap 	   ths_admin    false                       1259    134932    sat_teklif_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_teklif_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_teklif_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    284                       1259    134933    sat_teklifler    TABLE     y  CREATE TABLE public.sat_teklifler (
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
       public         heap 	   ths_admin    false                       1259    134954    sat_teklif_id_seq    SEQUENCE     �   ALTER TABLE public.sat_teklifler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_teklif_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    286                        1259    134955    set_ch_firma_tipleri    TABLE     �   CREATE TABLE public.set_ch_firma_tipleri (
    id bigint NOT NULL,
    firma_turu_id bigint NOT NULL,
    firma_tipi character varying(48) NOT NULL
);
 (   DROP TABLE public.set_ch_firma_tipleri;
       public         heap 	   ths_admin    false            !           1259    134958    set_ch_firma_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_firma_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_firma_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    288            "           1259    134959    set_ch_firma_turleri    TABLE     t   CREATE TABLE public.set_ch_firma_turleri (
    id bigint NOT NULL,
    firma_turu character varying(32) NOT NULL
);
 (   DROP TABLE public.set_ch_firma_turleri;
       public         heap 	   ths_admin    false            #           1259    134962    set_ch_firma_turu_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_firma_turleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_firma_turu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    290            $           1259    134963    set_ch_grup_id_seq    SEQUENCE     �   ALTER TABLE public.ch_gruplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_grup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    230            %           1259    134964    set_ch_hesap_plani_id_seq    SEQUENCE     �   ALTER TABLE public.ch_hesap_planlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_hesap_plani_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    233            &           1259    134965    set_ch_hesap_tipleri    TABLE     t   CREATE TABLE public.set_ch_hesap_tipleri (
    id bigint NOT NULL,
    hesap_tipi character varying(16) NOT NULL
);
 (   DROP TABLE public.set_ch_hesap_tipleri;
       public         heap 	   ths_admin    false            '           1259    134968    set_ch_hesap_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_hesap_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_hesap_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    294            (           1259    134969    set_ch_vergi_oranlari    TABLE       CREATE TABLE public.set_ch_vergi_oranlari (
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
 )   DROP TABLE public.set_ch_vergi_oranlari;
       public         heap 	   ths_admin    false            )           1259    134972    set_ch_vergi_orani_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_vergi_oranlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_vergi_orani_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    296            *           1259    134973    set_einv_fatura_tipleri    TABLE     x   CREATE TABLE public.set_einv_fatura_tipleri (
    id bigint NOT NULL,
    fatura_tipi character varying(32) NOT NULL
);
 +   DROP TABLE public.set_einv_fatura_tipleri;
       public         heap 	   ths_admin    false            +           1259    134976    set_einv_fatura_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_fatura_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_fatura_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    298            ,           1259    134977    set_einv_odeme_sekilleri    TABLE     �   CREATE TABLE public.set_einv_odeme_sekilleri (
    id bigint NOT NULL,
    odeme_sekli character varying(96),
    kod character varying(16),
    aciklama character varying(512),
    is_efatura boolean DEFAULT false
);
 ,   DROP TABLE public.set_einv_odeme_sekilleri;
       public         heap 	   ths_admin    false            -           1259    134983    set_einv_odeme_sekli_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_odeme_sekilleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_odeme_sekli_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    300            .           1259    134984    set_einv_paket_tipleri    TABLE     �   CREATE TABLE public.set_einv_paket_tipleri (
    id bigint NOT NULL,
    kod character varying(2),
    paket_tipi character varying(128),
    aciklama character varying(512)
);
 *   DROP TABLE public.set_einv_paket_tipleri;
       public         heap 	   ths_admin    false            /           1259    134989    set_einv_paket_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_paket_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_paket_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    302            0           1259    134990    set_einv_tasima_ucretleri    TABLE     s   CREATE TABLE public.set_einv_tasima_ucretleri (
    id bigint NOT NULL,
    tasima_ucreti character varying(16)
);
 -   DROP TABLE public.set_einv_tasima_ucretleri;
       public         heap 	   ths_admin    false            1           1259    134993    set_einv_tasima_ucreti_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_tasima_ucretleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_tasima_ucreti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    304            2           1259    134994    set_einv_teslim_sekilleri    TABLE     �   CREATE TABLE public.set_einv_teslim_sekilleri (
    id bigint NOT NULL,
    teslim_sekli character varying(16) NOT NULL,
    aciklama character varying(96) NOT NULL,
    is_efatura boolean DEFAULT false
);
 -   DROP TABLE public.set_einv_teslim_sekilleri;
       public         heap 	   ths_admin    false            3           1259    134998    set_einv_teslim_sekli_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_teslim_sekilleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_teslim_sekli_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    306            4           1259    134999    set_prs_birimler    TABLE     �   CREATE TABLE public.set_prs_birimler (
    id bigint NOT NULL,
    birim character varying(32) NOT NULL,
    bolum_id bigint
);
 $   DROP TABLE public.set_prs_birimler;
       public         heap 	   ths_admin    false            5           1259    135002    set_prs_birim_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_birimler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_birim_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    308            6           1259    135003    set_prs_bolumler    TABLE     k   CREATE TABLE public.set_prs_bolumler (
    id bigint NOT NULL,
    bolum character varying(32) NOT NULL
);
 $   DROP TABLE public.set_prs_bolumler;
       public         heap 	   ths_admin    false            7           1259    135006    set_prs_bolum_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_bolumler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_bolum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    310            8           1259    135007    set_prs_ehliyetler    TABLE     o   CREATE TABLE public.set_prs_ehliyetler (
    id bigint NOT NULL,
    ehliyet character varying(32) NOT NULL
);
 &   DROP TABLE public.set_prs_ehliyetler;
       public         heap 	   ths_admin    false            9           1259    135010    set_prs_ehliyet_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_ehliyetler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_ehliyet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    312            :           1259    135011    set_prs_gorevler    TABLE     k   CREATE TABLE public.set_prs_gorevler (
    id bigint NOT NULL,
    gorev character varying(32) NOT NULL
);
 $   DROP TABLE public.set_prs_gorevler;
       public         heap 	   ths_admin    false            ;           1259    135014    set_prs_gorev_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_gorevler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_gorev_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    314            <           1259    135015    set_prs_lisanlar    TABLE     k   CREATE TABLE public.set_prs_lisanlar (
    id bigint NOT NULL,
    lisan character varying(16) NOT NULL
);
 $   DROP TABLE public.set_prs_lisanlar;
       public         heap 	   ths_admin    false            =           1259    135018    set_prs_lisan_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_lisanlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_lisan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    316            >           1259    135019    set_prs_lisan_seviyeleri    TABLE     |   CREATE TABLE public.set_prs_lisan_seviyeleri (
    id bigint NOT NULL,
    lisan_seviyesi character varying(16) NOT NULL
);
 ,   DROP TABLE public.set_prs_lisan_seviyeleri;
       public         heap 	   ths_admin    false            ?           1259    135022    set_prs_lisan_seviyesi_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_lisan_seviyeleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_lisan_seviyesi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    318            @           1259    135023    set_prs_personel_tipleri    TABLE     {   CREATE TABLE public.set_prs_personel_tipleri (
    id bigint NOT NULL,
    personel_tipi character varying(32) NOT NULL
);
 ,   DROP TABLE public.set_prs_personel_tipleri;
       public         heap 	   ths_admin    false            A           1259    135026    set_prs_personel_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_personel_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_personel_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    320            B           1259    135027    set_prs_tasima_servisleri    TABLE     �   CREATE TABLE public.set_prs_tasima_servisleri (
    id bigint NOT NULL,
    arac_no smallint NOT NULL,
    arac_adi character varying(32) NOT NULL,
    rota double precision[]
);
 -   DROP TABLE public.set_prs_tasima_servisleri;
       public         heap 	   ths_admin    false            C           1259    135032    set_prs_servis_araci_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_tasima_servisleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_servis_araci_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    322            D           1259    135033    set_sat_siparis_durum_id_seq    SEQUENCE     �   ALTER TABLE public.set_sls_order_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_sat_siparis_durum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    279            E           1259    135034    set_sls_offer_status    TABLE     �   CREATE TABLE public.set_sls_offer_status (
    id bigint NOT NULL,
    teklif_durum character varying(32) NOT NULL,
    aciklama character varying(64)
);
 (   DROP TABLE public.set_sls_offer_status;
       public         heap 	   ths_admin    false            F           1259    135037    set_sat_teklif_durum_id_seq    SEQUENCE     �   ALTER TABLE public.set_sls_offer_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_sat_teklif_durum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    325            G           1259    135038    stk_ambarlar    TABLE       CREATE TABLE public.stk_ambarlar (
    id bigint NOT NULL,
    ambar_adi character varying(32),
    is_varsayilan_hammadde boolean DEFAULT false NOT NULL,
    is_varsayilan_uretim boolean DEFAULT false NOT NULL,
    is_varsayilan_satis boolean DEFAULT false NOT NULL
);
     DROP TABLE public.stk_ambarlar;
       public         heap 	   ths_admin    false            [           0    0    TABLE stk_ambarlar    COMMENT     X   COMMENT ON TABLE public.stk_ambarlar IS 'Stok hareketlerinin tutulduğu ambar bilgisi';
          public       	   ths_admin    false    327            H           1259    135044    stk_cins_ozellikleri    TABLE     s  CREATE TABLE public.stk_cins_ozellikleri (
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
 (   DROP TABLE public.stk_cins_ozellikleri;
       public         heap 	   ths_admin    false            I           1259    135049    stk_cins_ozelligi_id_seq    SEQUENCE     �   ALTER TABLE public.stk_cins_ozellikleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_cins_ozelligi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    328            J           1259    135050    stk_hareketler    TABLE       CREATE TABLE public.stk_hareketler (
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
       public         heap 	   ths_admin    false            K           1259    135055    stk_hareketler_id_seq    SEQUENCE     �   ALTER TABLE public.stk_hareketler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_hareketler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    330            L           1259    135056    stk_kart_ozetleri    TABLE     �  CREATE TABLE public.stk_kart_ozetleri (
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
       public         heap 	   ths_admin    false            M           1259    135070    stk_kart_ozetleri_id_seq    SEQUENCE     �   ALTER TABLE public.stk_kart_ozetleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_kart_ozetleri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    332            N           1259    135071    stk_kartlar_id_seq    SEQUENCE     �   ALTER TABLE public.stk_kartlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_kartlar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    281            O           1259    135072    stk_resimler    TABLE     o   CREATE TABLE public.stk_resimler (
    id bigint NOT NULL,
    stk_kart_id bigint NOT NULL,
    resim bytea
);
     DROP TABLE public.stk_resimler;
       public         heap 	   ths_admin    false            P           1259    135077    stk_resimler_id_seq    SEQUENCE     �   ALTER TABLE public.stk_resimler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_resimler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    335            Q           1259    135078    stk_stok_ambar_id_seq    SEQUENCE     �   ALTER TABLE public.stk_ambarlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_stok_ambar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    327            R           1259    135079    stk_stok_grubu_id_seq    SEQUENCE     �   ALTER TABLE public.stk_gruplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_stok_grubu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    280            S           1259    135080    sys_adresler    TABLE     �  CREATE TABLE public.sys_adresler (
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
       public         heap 	   ths_admin    false            T           1259    135085    sys_adresler_id_seq    SEQUENCE     �   ALTER TABLE public.sys_adresler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_adresler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    339            U           1259    135086 	   sys_aylar    TABLE     e   CREATE TABLE public.sys_aylar (
    id bigint NOT NULL,
    ay_adi character varying(16) NOT NULL
);
    DROP TABLE public.sys_aylar;
       public         heap 	   ths_admin    false            V           1259    135089    sys_ay_id_seq    SEQUENCE     �   ALTER TABLE public.sys_aylar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    341            W           1259    135090    sys_bolgeler    TABLE     g   CREATE TABLE public.sys_bolgeler (
    id bigint NOT NULL,
    bolge character varying(64) NOT NULL
);
     DROP TABLE public.sys_bolgeler;
       public         heap 	   ths_admin    false            X           1259    135093    sys_bolge_id_seq    SEQUENCE     �   ALTER TABLE public.sys_bolgeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_bolge_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    343            Y           1259    135094    sys_db_status    VIEW     �  CREATE VIEW public.sys_db_status AS
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
       public       	   ths_admin    false            Z           1259    135099    sys_ersim_haklari    TABLE     i  CREATE TABLE public.sys_ersim_haklari (
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
       public         heap 	   ths_admin    false            [           1259    135107    sys_erisim_hakki_id_seq    SEQUENCE     �   ALTER TABLE public.sys_ersim_haklari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_erisim_hakki_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    346            \           1259    135108    sys_grid_filtreler_siralamalar    TABLE     �   CREATE TABLE public.sys_grid_filtreler_siralamalar (
    id bigint NOT NULL,
    tablo_adi character varying(32),
    icerik character varying,
    is_siralama boolean DEFAULT false
);
 2   DROP TABLE public.sys_grid_filtreler_siralamalar;
       public         heap 	   ths_admin    false            ]           1259    135114    sys_grid_filtre_siralama_id_seq    SEQUENCE     �   ALTER TABLE public.sys_grid_filtreler_siralamalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_filtre_siralama_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    348            ^           1259    135115    sys_grid_kolonlar    TABLE     �  CREATE TABLE public.sys_grid_kolonlar (
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
       public         heap 	   ths_admin    false            _           1259    135130    sys_grid_kolon_id_seq    SEQUENCE     �   ALTER TABLE public.sys_grid_kolonlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_kolon_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    350            `           1259    135131 
   sys_gunler    TABLE     g   CREATE TABLE public.sys_gunler (
    id bigint NOT NULL,
    gun_adi character varying(16) NOT NULL
);
    DROP TABLE public.sys_gunler;
       public         heap 	   ths_admin    false            a           1259    135134    sys_gun_id_seq    SEQUENCE     �   ALTER TABLE public.sys_gunler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_gun_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    352            b           1259    135135    sys_kaynak_gruplari    TABLE     m   CREATE TABLE public.sys_kaynak_gruplari (
    id bigint NOT NULL,
    grup character varying(64) NOT NULL
);
 '   DROP TABLE public.sys_kaynak_gruplari;
       public         heap 	   ths_admin    false            c           1259    135138    sys_kaynak_grup_id_seq    SEQUENCE     �   ALTER TABLE public.sys_kaynak_gruplari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kaynak_grup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    354            d           1259    135139    sys_kaynaklar    TABLE     �   CREATE TABLE public.sys_kaynaklar (
    id bigint NOT NULL,
    kaynak_kodu integer NOT NULL,
    kaynak_adi character varying(64) NOT NULL,
    kaynak_grup_id bigint NOT NULL
);
 !   DROP TABLE public.sys_kaynaklar;
       public         heap 	   ths_admin    false            e           1259    135142    sys_kaynak_id_seq    SEQUENCE     �   ALTER TABLE public.sys_kaynaklar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kaynak_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    356            f           1259    135143    sys_kullanicilar    TABLE     �  CREATE TABLE public.sys_kullanicilar (
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
       public         heap 	   ths_admin    false            g           1259    135152    sys_kullanici_id_seq    SEQUENCE     �   ALTER TABLE public.sys_kullanicilar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kullanici_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    358            h           1259    135153    sys_lisan_gui_icerikler    TABLE     R  CREATE TABLE public.sys_lisan_gui_icerikler (
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
       public         heap 	   ths_admin    false            i           1259    135159    sys_lisan_gui_icerik_id_seq    SEQUENCE     �   ALTER TABLE public.sys_lisan_gui_icerikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_lisan_gui_icerik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    360            j           1259    135160    sys_lisanlar    TABLE     g   CREATE TABLE public.sys_lisanlar (
    id bigint NOT NULL,
    lisan character varying(16) NOT NULL
);
     DROP TABLE public.sys_lisanlar;
       public         heap 	   ths_admin    false            k           1259    135163    sys_lisan_id_seq    SEQUENCE     �   ALTER TABLE public.sys_lisanlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_lisan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    362            l           1259    135164    sys_vergi_mukellef_tipleri    TABLE     �   CREATE TABLE public.sys_vergi_mukellef_tipleri (
    id bigint NOT NULL,
    mukellef_tipi character varying(32) NOT NULL,
    is_varsayilan boolean DEFAULT false NOT NULL
);
 .   DROP TABLE public.sys_vergi_mukellef_tipleri;
       public         heap 	   ths_admin    false            m           1259    135168    sys_mukellef_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_vergi_mukellef_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_mukellef_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    364            n           1259    135169    sys_olcu_birimleri    TABLE       CREATE TABLE public.sys_olcu_birimleri (
    id bigint NOT NULL,
    birim character varying(16) NOT NULL,
    birim_einv character varying(3),
    aciklama character varying(64),
    is_ondalik boolean DEFAULT false NOT NULL,
    birim_tipi_id bigint,
    carpan integer
);
 &   DROP TABLE public.sys_olcu_birimleri;
       public         heap 	   ths_admin    false            o           1259    135173    sys_olcu_birimi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_olcu_birimleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_olcu_birimi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    366            p           1259    135174    sys_olcu_birimi_tipleri    TABLE     }   CREATE TABLE public.sys_olcu_birimi_tipleri (
    id bigint NOT NULL,
    olcu_birimi_tipi character varying(16) NOT NULL
);
 +   DROP TABLE public.sys_olcu_birimi_tipleri;
       public         heap 	   ths_admin    false            q           1259    135177    sys_olcu_birimi_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_olcu_birimi_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_olcu_birimi_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    368            r           1259    135178    sys_ondalik_haneler    TABLE     �   CREATE TABLE public.sys_ondalik_haneler (
    id bigint NOT NULL,
    miktar smallint DEFAULT 2,
    fiyat smallint DEFAULT 2,
    tutar smallint DEFAULT 2,
    stok_miktar smallint DEFAULT 4,
    doviz_kuru smallint DEFAULT 4
);
 '   DROP TABLE public.sys_ondalik_haneler;
       public         heap 	   ths_admin    false            s           1259    135186    sys_ondalik_hane_id_seq    SEQUENCE     �   ALTER TABLE public.sys_ondalik_haneler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ondalik_hane_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    370            t           1259    135187    sys_para_birimleri    TABLE     �   CREATE TABLE public.sys_para_birimleri (
    id bigint NOT NULL,
    para character varying(3) NOT NULL,
    sembol character varying(3) NOT NULL,
    aciklama character varying(128)
);
 &   DROP TABLE public.sys_para_birimleri;
       public         heap 	   ths_admin    false            u           1259    135190    sys_para_birimi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_para_birimleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_para_birimi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    372            v           1259    135191    sys_sehir_id_seq    SEQUENCE     �   ALTER TABLE public.sys_sehirler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_sehir_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    282            w           1259    135192    sys_ulkeler    TABLE       CREATE TABLE public.sys_ulkeler (
    id bigint NOT NULL,
    ulke_kodu character varying(2) NOT NULL,
    ulke_adi character varying(128) NOT NULL,
    iso_year integer,
    iso_cctld character varying(3),
    is_eu_member boolean DEFAULT false NOT NULL
);
    DROP TABLE public.sys_ulkeler;
       public         heap 	   ths_admin    false            x           1259    135196    sys_ulke_id_seq    SEQUENCE     �   ALTER TABLE public.sys_ulkeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ulke_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    375            y           1259    135197    sys_uygulama_ayarlari    TABLE     >  CREATE TABLE public.sys_uygulama_ayarlari (
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
       public         heap 	   ths_admin    false            z           1259    135209    sys_uygulama_ayari_id_seq    SEQUENCE     �   ALTER TABLE public.sys_uygulama_ayarlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_uygulama_ayari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    377            {           1259    135210    sys_view_tables    VIEW     �  CREATE VIEW public.sys_view_tables AS
 SELECT (row_number() OVER (ORDER BY tables.table_type, tables.table_name))::integer AS id,
    initcap(replace((tables.table_name)::text, '_'::text, ' '::text)) AS table_name,
    (tables.table_type)::text AS table_type
   FROM information_schema.tables
  WHERE ((tables.table_schema)::text = 'public'::text)
  ORDER BY tables.table_type, tables.table_name;
 "   DROP VIEW public.sys_view_tables;
       public       	   ths_admin    false            |           1259    135214    sys_view_columns    VIEW     '  CREATE VIEW public.sys_view_columns AS
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
       public       	   ths_admin    false    379    379            }           1259    135219    sys_view_databases    VIEW     >  CREATE VIEW public.sys_view_databases AS
 SELECT (pg_database.datname)::text AS database_name,
    pg_shdescription.description AS aciklama
   FROM (pg_shdescription
     JOIN pg_database ON ((pg_shdescription.objoid = pg_database.oid)))
  WHERE ((1 = 1) AND (pg_shdescription.description = 'THS ERP Systems'::text));
 %   DROP VIEW public.sys_view_databases;
       public       	   ths_admin    false            ~           1259    135223    urt_recete_yan_urunler    TABLE     �   CREATE TABLE public.urt_recete_yan_urunler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    urun_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 *   DROP TABLE public.urt_recete_yan_urunler;
       public         heap 	   ths_admin    false                       1259    135226    urt_recete_yan_urunler_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_yan_urunler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urt_recete_yan_urunler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    382            t          0    134720    ch_banka_subeleri 
   TABLE DATA           X   COPY public.ch_banka_subeleri (id, banka_id, sube_kodu, sube_adi, sehir_id) FROM stdin;
    public       	   ths_admin    false    225   HD      r          0    134716    ch_bankalar 
   TABLE DATA           @   COPY public.ch_bankalar (id, banka_adi, swift_kodu) FROM stdin;
    public       	   ths_admin    false    223   �D      v          0    134724    ch_bolgeler 
   TABLE DATA           0   COPY public.ch_bolgeler (id, bolge) FROM stdin;
    public       	   ths_admin    false    227   �D      x          0    134728    ch_doviz_kurlari 
   TABLE DATA           E   COPY public.ch_doviz_kurlari (id, kur_tarihi, kur, para) FROM stdin;
    public       	   ths_admin    false    229   JE      y          0    134731 
   ch_gruplar 
   TABLE DATA           .   COPY public.ch_gruplar (id, grup) FROM stdin;
    public       	   ths_admin    false    230   `F      |          0    134743    ch_hesap_planlari 
   TABLE DATA           L   COPY public.ch_hesap_planlari (id, plan_kodu, plan_adi, seviye) FROM stdin;
    public       	   ths_admin    false    233   �F      z          0    134734    ch_hesaplar 
   TABLE DATA           �  COPY public.ch_hesaplar (id, hesap_kodu, hesap_ismi, hesap_tipi_id, grup_id, bolge_id, mukellef_tipi_id, mukellef_adi, mukellef_adi2, mukellef_soyadi, vergi_dairesi, vergi_no, iban, iban_para, nace, yetkili1, yetkili1_tel, yetkili2, yetkili2_tel, yetkili3, yetkili3_tel, faks, muhasebe_telefon, muhasebe_email, muhasebe_yetkili, ozel_not, kok_kod, ara_kod, iskonto, efatura_kullaniyor, efatura_pb_name, adres_id, pasif) FROM stdin;
    public       	   ths_admin    false    231   �T      ~          0    134747    mhs_fis_detaylari 
   TABLE DATA           :   COPY public.mhs_fis_detaylari (id, header_id) FROM stdin;
    public       	   ths_admin    false    235   h      �          0    134751 
   mhs_fisler 
   TABLE DATA           D   COPY public.mhs_fisler (id, yevmiye_no, yevmiye_tarihi) FROM stdin;
    public       	   ths_admin    false    237   /h      �          0    134755    mhs_transfer_kodlari 
   TABLE DATA           W   COPY public.mhs_transfer_kodlari (id, transfer_kodu, aciklama, hesap_kodu) FROM stdin;
    public       	   ths_admin    false    239   Lh      �          0    134759    prs_ehliyetler 
   TABLE DATA           E   COPY public.prs_ehliyetler (id, ehliyet_id, personel_id) FROM stdin;
    public       	   ths_admin    false    241   ih      �          0    134762    prs_lisan_bilgileri 
   TABLE DATA           h   COPY public.prs_lisan_bilgileri (id, lisan_id, okuma_id, yazma_id, konusma_id, personel_id) FROM stdin;
    public       	   ths_admin    false    242   �h      �          0    134767    prs_personeller 
   TABLE DATA           i  COPY public.prs_personeller (id, ad, soyad, ad_soyad, tel1, tel2, personel_tipi_id, birim_id, gorev_id, dogum_tarihi, kan_grubu, cinsiyet, askerlik_durumu, medeni_durum, cocuk_sayisi, yakin_adi, yakin_telefon, ayakkabi_no, elbise_bedeni, genel_not, tasima_servis_id, ozel_not, maas, ikramiye_sayisi, ikramiye_tutar, identification, adres_id, pasif) FROM stdin;
    public       	   ths_admin    false    245   �h      �          0    134819    sat_fatura_detaylari 
   TABLE DATA           s   COPY public.sat_fatura_detaylari (id, header_id, teklif_detay_id, siparis_detay_id, irsaliye_detay_id) FROM stdin;
    public       	   ths_admin    false    267   �i      �          0    134823    sat_faturalar 
   TABLE DATA           i   COPY public.sat_faturalar (id, fatura_no, fatura_tarihi, teklif_id, siparis_id, irsaliye_id) FROM stdin;
    public       	   ths_admin    false    269   �i      �          0    134827    sat_irsaliye_detaylari 
   TABLE DATA           s   COPY public.sat_irsaliye_detaylari (id, header_id, teklif_detay_id, siparis_detay_id, fatura_detay_id) FROM stdin;
    public       	   ths_admin    false    271   �i      �          0    134831    sat_irsaliyeler 
   TABLE DATA           m   COPY public.sat_irsaliyeler (id, irsaliye_no, irsaliye_tarihi, teklif_id, siparis_id, fatura_id) FROM stdin;
    public       	   ths_admin    false    273   �i      �          0    134835    sat_siparis_detaylari 
   TABLE DATA           �  COPY public.sat_siparis_detaylari (id, header_id, teklif_detay_id, irsaliye_detay_id, fatura_detay_id, stok_kodu, stok_aciklama, kullanici_aciklama, referans, miktar, giden_miktar, olcu_birimi, iskonto_orani, kdv_orani, fiyat, net_fiyat, tutar, iskonto_tutar, net_tutar, kdv_tutar, toplam_tutar, is_ana_urun, referans_ana_urun_id, gtip_no, en, boy, yukseklik, net_agirlik, brut_agirlik, hacim, kab) FROM stdin;
    public       	   ths_admin    false    275   j      �          0    134859    sat_siparisler 
   TABLE DATA           u  COPY public.sat_siparisler (id, teklif_id, irsaliye_id, fatura_id, tutar, iskonto_tutar, ara_toplam, kdv_oran1, kdv_tutar1, kdv_oran2, kdv_tutar2, kdv_oran3, kdv_tutar3, kdv_oran4, kdv_tutar4, kdv_oran5, kdv_tutar5, genel_toplam, islem_tipi_id, siparis_no, siparis_tarihi, teslim_tarihi, musteri_kodu, musteri_adi, vergi_dairesi, vergi_no, ulke_id, sehir_id, ilce, mahalle, cadde, sokak, posta_kodu, bina_adi, kapi_no, musteri_temsilcisi_id, muhattap_ad, referans, para_birimi, doviz_kuru_usd, doviz_kuru_eur, aciklama, proforma_no, siparis_durum_id, teslim_sekli_id, odeme_sekli_id, paket_tipi_id, tasima_ucreti_id) FROM stdin;
    public       	   ths_admin    false    277   1j      �          0    134916    sat_teklif_detaylari 
   TABLE DATA           R  COPY public.sat_teklif_detaylari (id, header_id, siparis_detay_id, irsaliye_detay_id, fatura_detay_id, stok_kodu, stok_aciklama, kullanici_aciklama, referans, miktar, olcu_birimi, iskonto_orani, kdv_orani, fiyat, net_fiyat, tutar, iskonto_tutar, net_tutar, kdv_tutar, toplam_tutar, is_ana_urun, referans_ana_urun_id, gtip_no) FROM stdin;
    public       	   ths_admin    false    284   Nj      �          0    134933    sat_teklifler 
   TABLE DATA           �  COPY public.sat_teklifler (id, siparis_id, irsaliye_id, fatura_id, is_siparislesti, tutar, iskonto_tutar, ara_toplam, kdv_oran1, kdv_tutar1, kdv_oran2, kdv_tutar2, kdv_oran3, kdv_tutar3, kdv_oran4, kdv_tutar4, kdv_oran5, kdv_tutar5, genel_toplam, islem_tipi_id, teklif_no, teklif_tarihi, gecerlilik_tarihi, musteri_kodu, musteri_adi, vergi_dairesi, vergi_no, ulke_id, sehir_id, ilce, mahalle, cadde, sokak, posta_kodu, bina_adi, kapi_no, musteri_temsilcisi_id, muhattap_ad, muhattap_telefon, referans, para_birimi, doviz_kuru_usd, doviz_kuru_eur, aciklama, proforma_no, teslim_sekli_id, odeme_sekli_id, paket_tipi_id, tasima_ucreti_id) FROM stdin;
    public       	   ths_admin    false    286   7k      �          0    134955    set_ch_firma_tipleri 
   TABLE DATA           M   COPY public.set_ch_firma_tipleri (id, firma_turu_id, firma_tipi) FROM stdin;
    public       	   ths_admin    false    288   
l      �          0    134959    set_ch_firma_turleri 
   TABLE DATA           >   COPY public.set_ch_firma_turleri (id, firma_turu) FROM stdin;
    public       	   ths_admin    false    290   ^l      �          0    134965    set_ch_hesap_tipleri 
   TABLE DATA           >   COPY public.set_ch_hesap_tipleri (id, hesap_tipi) FROM stdin;
    public       	   ths_admin    false    294   �l      �          0    134969    set_ch_vergi_oranlari 
   TABLE DATA           �   COPY public.set_ch_vergi_oranlari (id, vergi_orani, satis_hesap_kodu, satis_iade_hesap_kodu, alis_hesap_kodu, alis_iade_hesap_kodu, ihracat_hesap_kodu, ihracat_iade_hesap_kodu, ithalat_hesap_kodu, ithalat_iade_hesap_kodu) FROM stdin;
    public       	   ths_admin    false    296   �l      �          0    134973    set_einv_fatura_tipleri 
   TABLE DATA           B   COPY public.set_einv_fatura_tipleri (id, fatura_tipi) FROM stdin;
    public       	   ths_admin    false    298   -m      �          0    134977    set_einv_odeme_sekilleri 
   TABLE DATA           ^   COPY public.set_einv_odeme_sekilleri (id, odeme_sekli, kod, aciklama, is_efatura) FROM stdin;
    public       	   ths_admin    false    300   �m      �          0    134984    set_einv_paket_tipleri 
   TABLE DATA           O   COPY public.set_einv_paket_tipleri (id, kod, paket_tipi, aciklama) FROM stdin;
    public       	   ths_admin    false    302   �n      �          0    134990    set_einv_tasima_ucretleri 
   TABLE DATA           F   COPY public.set_einv_tasima_ucretleri (id, tasima_ucreti) FROM stdin;
    public       	   ths_admin    false    304   o      �          0    134994    set_einv_teslim_sekilleri 
   TABLE DATA           [   COPY public.set_einv_teslim_sekilleri (id, teslim_sekli, aciklama, is_efatura) FROM stdin;
    public       	   ths_admin    false    306   So      �          0    134999    set_prs_birimler 
   TABLE DATA           ?   COPY public.set_prs_birimler (id, birim, bolum_id) FROM stdin;
    public       	   ths_admin    false    308   Zq      �          0    135003    set_prs_bolumler 
   TABLE DATA           5   COPY public.set_prs_bolumler (id, bolum) FROM stdin;
    public       	   ths_admin    false    310   �q      �          0    135007    set_prs_ehliyetler 
   TABLE DATA           9   COPY public.set_prs_ehliyetler (id, ehliyet) FROM stdin;
    public       	   ths_admin    false    312   �q      �          0    135011    set_prs_gorevler 
   TABLE DATA           5   COPY public.set_prs_gorevler (id, gorev) FROM stdin;
    public       	   ths_admin    false    314   r      �          0    135019    set_prs_lisan_seviyeleri 
   TABLE DATA           F   COPY public.set_prs_lisan_seviyeleri (id, lisan_seviyesi) FROM stdin;
    public       	   ths_admin    false    318   [r      �          0    135015    set_prs_lisanlar 
   TABLE DATA           5   COPY public.set_prs_lisanlar (id, lisan) FROM stdin;
    public       	   ths_admin    false    316   �r      �          0    135023    set_prs_personel_tipleri 
   TABLE DATA           E   COPY public.set_prs_personel_tipleri (id, personel_tipi) FROM stdin;
    public       	   ths_admin    false    320   �r      �          0    135027    set_prs_tasima_servisleri 
   TABLE DATA           P   COPY public.set_prs_tasima_servisleri (id, arac_no, arac_adi, rota) FROM stdin;
    public       	   ths_admin    false    322   s      �          0    135034    set_sls_offer_status 
   TABLE DATA           J   COPY public.set_sls_offer_status (id, teklif_durum, aciklama) FROM stdin;
    public       	   ths_admin    false    325   -s      �          0    134881    set_sls_order_status 
   TABLE DATA           K   COPY public.set_sls_order_status (id, siparis_durum, aciklama) FROM stdin;
    public       	   ths_admin    false    279   ps      �          0    135038    stk_ambarlar 
   TABLE DATA           x   COPY public.stk_ambarlar (id, ambar_adi, is_varsayilan_hammadde, is_varsayilan_uretim, is_varsayilan_satis) FROM stdin;
    public       	   ths_admin    false    327   �s      �          0    135044    stk_cins_ozellikleri 
   TABLE DATA           �   COPY public.stk_cins_ozellikleri (id, cins, aciklama, s1, s2, s3, s4, s5, s6, s7, s8, i1, i2, i3, i4, d1, d2, d3, d4) FROM stdin;
    public       	   ths_admin    false    328   �s      �          0    134884    stk_gruplar 
   TABLE DATA           �   COPY public.stk_gruplar (id, grup, kdv_orani, satis_hesap_kodu, satis_iade_hesap_kodu, alis_hesap_kodu, alis_iade_hesap_kodu, ihracat_hesap_kodu, ihracat_iade_hesap_kodu, hammadde_hesap_kodu, mamul_hesap_kodu) FROM stdin;
    public       	   ths_admin    false    280   tt      �          0    135050    stk_hareketler 
   TABLE DATA           �   COPY public.stk_hareketler (id, stok_kodu, miktar, tutar, tutar_doviz, para_birimi, is_giris, tarih, veren_ambar_id, alan_ambar_id, is_donem_basi, aciklama, irsaliye_id, uretim_id) FROM stdin;
    public       	   ths_admin    false    330   �t      �          0    135056    stk_kart_ozetleri 
   TABLE DATA           ;  COPY public.stk_kart_ozetleri (id, stk_kart_id, stok_miktar, ortalama_maliyet, donem_basi_fiyat, donem_basi_miktar, donem_basi_tutar, giren_toplam, giren_toplam_maliyet, cikan_toplam, cikan_toplam_maliyet, son_alis_fiyat, son_alis_para, son_alis_tarih, son_alis_miktar, son_alis_kur, son_alis_kur_para) FROM stdin;
    public       	   ths_admin    false    332   �t      �          0    134887    stk_kartlar 
   TABLE DATA           �  COPY public.stk_kartlar (id, is_satilabilir, stok_kodu, stok_adi, stok_grubu_id, olcu_birimi_id, urun_tipi, alis_iskonto, satis_iskonto, alis_fiyat, alis_para, satis_fiyat, satis_para, ihrac_fiyat, ihrac_para, ortalama_maliyet, en, boy, yukseklik, agirlik, temin_suresi, ozel_kod, marka, mensei_id, gtip_no, diib_urun_tanimi, en_az_stok_seviyesi, tanim, cins_id, s1, s2, s3, s4, s5, s6, s7, s8, i1, i2, i3, d1, d2, d3, i4, d4) FROM stdin;
    public       	   ths_admin    false    281   �t      �          0    135072    stk_resimler 
   TABLE DATA           >   COPY public.stk_resimler (id, stk_kart_id, resim) FROM stdin;
    public       	   ths_admin    false    335   Rv      �          0    135080    sys_adresler 
   TABLE DATA           �   COPY public.sys_adresler (id, sehir_id, ilce, mahalle, semt, cadde, sokak, bina_adi, kapi_no, posta_kodu, web, email) FROM stdin;
    public       	   ths_admin    false    339   ov      �          0    135086 	   sys_aylar 
   TABLE DATA           /   COPY public.sys_aylar (id, ay_adi) FROM stdin;
    public       	   ths_admin    false    341   �v      �          0    135090    sys_bolgeler 
   TABLE DATA           1   COPY public.sys_bolgeler (id, bolge) FROM stdin;
    public       	   ths_admin    false    343   aw      �          0    135099    sys_ersim_haklari 
   TABLE DATA              COPY public.sys_ersim_haklari (id, kaynak_id, is_okuma, is_ekleme, is_guncelleme, is_silme, is_ozel, kullanici_id) FROM stdin;
    public       	   ths_admin    false    346   �w      �          0    135108    sys_grid_filtreler_siralamalar 
   TABLE DATA           \   COPY public.sys_grid_filtreler_siralamalar (id, tablo_adi, icerik, is_siralama) FROM stdin;
    public       	   ths_admin    false    348   �x      �          0    135115    sys_grid_kolonlar 
   TABLE DATA           �   COPY public.sys_grid_kolonlar (id, tablo_adi, kolon_adi, sira_no, kolon_genislik, veri_formati, is_gorunur, is_helper_gorunur, min_deger, min_renk, maks_deger, maks_renk, maks_deger_yuzdesi, bar_rengi, bar_arka_rengi, bar_yazi_rengi) FROM stdin;
    public       	   ths_admin    false    350   �x      �          0    135131 
   sys_gunler 
   TABLE DATA           1   COPY public.sys_gunler (id, gun_adi) FROM stdin;
    public       	   ths_admin    false    352   Cz      �          0    135135    sys_kaynak_gruplari 
   TABLE DATA           7   COPY public.sys_kaynak_gruplari (id, grup) FROM stdin;
    public       	   ths_admin    false    354   �z      �          0    135139    sys_kaynaklar 
   TABLE DATA           T   COPY public.sys_kaynaklar (id, kaynak_kodu, kaynak_adi, kaynak_grup_id) FROM stdin;
    public       	   ths_admin    false    356   {      �          0    135143    sys_kullanicilar 
   TABLE DATA           �   COPY public.sys_kullanicilar (id, kullanici_adi, kullanici_sifre, is_aktif, is_yonetici, is_super_kullanici, ip_adres, mac_adres, personel_id) FROM stdin;
    public       	   ths_admin    false    358   C|      �          0    135153    sys_lisan_gui_icerikler 
   TABLE DATA           v   COPY public.sys_lisan_gui_icerikler (id, lisan, kod, deger, is_fabrika, icerik_tipi, tablo_adi, form_adi) FROM stdin;
    public       	   ths_admin    false    360   �|      �          0    135160    sys_lisanlar 
   TABLE DATA           1   COPY public.sys_lisanlar (id, lisan) FROM stdin;
    public       	   ths_admin    false    362   �                0    135174    sys_olcu_birimi_tipleri 
   TABLE DATA           G   COPY public.sys_olcu_birimi_tipleri (id, olcu_birimi_tipi) FROM stdin;
    public       	   ths_admin    false    368   �      �          0    135169    sys_olcu_birimleri 
   TABLE DATA           p   COPY public.sys_olcu_birimleri (id, birim, birim_einv, aciklama, is_ondalik, birim_tipi_id, carpan) FROM stdin;
    public       	   ths_admin    false    366   ^�                0    135178    sys_ondalik_haneler 
   TABLE DATA           `   COPY public.sys_ondalik_haneler (id, miktar, fiyat, tutar, stok_miktar, doviz_kuru) FROM stdin;
    public       	   ths_admin    false    370   7�                0    135187    sys_para_birimleri 
   TABLE DATA           H   COPY public.sys_para_birimleri (id, para, sembol, aciklama) FROM stdin;
    public       	   ths_admin    false    372   T�      �          0    134908    sys_sehirler 
   TABLE DATA           P   COPY public.sys_sehirler (id, sehir, plaka_kodu, ulke_id, bolge_id) FROM stdin;
    public       	   ths_admin    false    282   �                0    135192    sys_ulkeler 
   TABLE DATA           a   COPY public.sys_ulkeler (id, ulke_kodu, ulke_adi, iso_year, iso_cctld, is_eu_member) FROM stdin;
    public       	   ths_admin    false    375   >�      
          0    135197    sys_uygulama_ayarlari 
   TABLE DATA           @  COPY public.sys_uygulama_ayarlari (id, logo, unvan, telefon, faks, vergi_dairesi, vergi_no, donem, lisan, mail_sunucu, mail_kullanici, mail_sifre, mail_smtp_port, grid_renk_1, grid_renk_2, grid_renk_aktif, crypt_key, sms_sunucu, sms_kullanici, sms_sifre, sms_baslik, versiyon, para, adres_id, diger_ayarlar) FROM stdin;
    public       	   ths_admin    false    377   ��      �          0    135164    sys_vergi_mukellef_tipleri 
   TABLE DATA           V   COPY public.sys_vergi_mukellef_tipleri (id, mukellef_tipi, is_varsayilan) FROM stdin;
    public       	   ths_admin    false    364   }�      �          0    134777    urt_iscilikler 
   TABLE DATA           `   COPY public.urt_iscilikler (id, gider_kodu, gider_adi, fiyat, birim_id, gider_tipi) FROM stdin;
    public       	   ths_admin    false    247   ��      �          0    134781    urt_paket_hammadde_detaylari 
   TABLE DATA           c   COPY public.urt_paket_hammadde_detaylari (id, header_id, recete_id, stok_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    249   ��      �          0    134785    urt_paket_hammaddeler 
   TABLE DATA           >   COPY public.urt_paket_hammaddeler (id, paket_adi) FROM stdin;
    public       	   ths_admin    false    251   +�      �          0    134789    urt_paket_iscilik_detaylari 
   TABLE DATA           Z   COPY public.urt_paket_iscilik_detaylari (id, header_id, iscilik_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    253   a�      �          0    134793    urt_paket_iscilikler 
   TABLE DATA           =   COPY public.urt_paket_iscilikler (id, paket_adi) FROM stdin;
    public       	   ths_admin    false    255   ~�      �          0    134797    urt_recete_hammaddeler 
   TABLE DATA           i   COPY public.urt_recete_hammaddeler (id, header_id, recete_id, stok_kodu, miktar, fire_orani) FROM stdin;
    public       	   ths_admin    false    257   ��      �          0    134807    urt_recete_iscilikler 
   TABLE DATA           T   COPY public.urt_recete_iscilikler (id, header_id, iscilik_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    261   ��      �          0    134811    urt_recete_paket_hammaddeler 
   TABLE DATA           W   COPY public.urt_recete_paket_hammaddeler (id, header_id, paket_id, miktar) FROM stdin;
    public       	   ths_admin    false    263   �      �          0    134815    urt_recete_paket_iscilikler 
   TABLE DATA           V   COPY public.urt_recete_paket_iscilikler (id, header_id, paket_id, miktar) FROM stdin;
    public       	   ths_admin    false    265   6�                0    135223    urt_recete_yan_urunler 
   TABLE DATA           R   COPY public.urt_recete_yan_urunler (id, header_id, urun_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    382   S�      �          0    134802    urt_receteler 
   TABLE DATA           Y   COPY public.urt_receteler (id, urun_kodu, urun_adi, ornek_miktari, aciklama) FROM stdin;
    public       	   ths_admin    false    259   p�      \           0    0    a_invoices_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.a_invoices_id_seq', 10, true);
          public          postgres    false    220            ]           0    0    audit_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.audit_id_seq', 7, true);
          public       	   ths_admin    false    222            ^           0    0    ch_banka_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.ch_banka_id_seq', 6, true);
          public       	   ths_admin    false    224            _           0    0    ch_banka_subesi_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.ch_banka_subesi_id_seq', 6, true);
          public       	   ths_admin    false    226            `           0    0    ch_bolge_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.ch_bolge_id_seq', 17, true);
          public       	   ths_admin    false    228            a           0    0    ch_hesap_karti_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.ch_hesap_karti_id_seq', 316, true);
          public       	   ths_admin    false    232            b           0    0    mhs_doviz_kuru_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.mhs_doviz_kuru_id_seq', 286, true);
          public       	   ths_admin    false    234            c           0    0    mhs_fis_detaylari_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.mhs_fis_detaylari_id_seq', 1, false);
          public       	   ths_admin    false    236            d           0    0    mhs_fisler_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.mhs_fisler_id_seq', 1, false);
          public       	   ths_admin    false    238            e           0    0    mhs_transfer_kodlari_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.mhs_transfer_kodlari_id_seq', 1, false);
          public       	   ths_admin    false    240            f           0    0    prs_lisan_bilgisi_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.prs_lisan_bilgisi_id_seq', 2, true);
          public       	   ths_admin    false    243            g           0    0    prs_personel_ehliyetleri_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.prs_personel_ehliyetleri_id_seq', 1, false);
          public       	   ths_admin    false    244            h           0    0    prs_personel_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.prs_personel_id_seq', 20, true);
          public       	   ths_admin    false    246            i           0    0    rct_iscilik_gideri_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.rct_iscilik_gideri_id_seq', 2, false);
          public       	   ths_admin    false    248            j           0    0    rct_paket_hammadde_detay_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.rct_paket_hammadde_detay_id_seq', 2, true);
          public       	   ths_admin    false    250            k           0    0    rct_paket_hammadde_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.rct_paket_hammadde_id_seq', 1, true);
          public       	   ths_admin    false    252            l           0    0    rct_paket_iscilik_detay_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.rct_paket_iscilik_detay_id_seq', 1, false);
          public       	   ths_admin    false    254            m           0    0    rct_paket_iscilik_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.rct_paket_iscilik_id_seq', 1, false);
          public       	   ths_admin    false    256            n           0    0    rct_recete_hammadde_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.rct_recete_hammadde_id_seq', 18, true);
          public       	   ths_admin    false    258            o           0    0    rct_recete_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.rct_recete_id_seq', 9, true);
          public       	   ths_admin    false    260            p           0    0    rct_recete_iscilik_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.rct_recete_iscilik_id_seq', 2, true);
          public       	   ths_admin    false    262            q           0    0     rct_recete_paket_hammadde_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.rct_recete_paket_hammadde_id_seq', 1, false);
          public       	   ths_admin    false    264            r           0    0    rct_recete_paket_iscilik_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.rct_recete_paket_iscilik_id_seq', 1, false);
          public       	   ths_admin    false    266            s           0    0    sat_fatura_detay_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.sat_fatura_detay_id_seq', 1, false);
          public       	   ths_admin    false    268            t           0    0    sat_fatura_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sat_fatura_id_seq', 1, false);
          public       	   ths_admin    false    270            u           0    0    sat_irsaliye_detay_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sat_irsaliye_detay_id_seq', 1, false);
          public       	   ths_admin    false    272            v           0    0    sat_irsaliye_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.sat_irsaliye_id_seq', 1, false);
          public       	   ths_admin    false    274            w           0    0    sat_siparis_detay_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.sat_siparis_detay_id_seq', 1, false);
          public       	   ths_admin    false    276            x           0    0    sat_siparis_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sat_siparis_id_seq', 1, true);
          public       	   ths_admin    false    278            y           0    0    sat_teklif_detay_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.sat_teklif_detay_id_seq', 4, true);
          public       	   ths_admin    false    285            z           0    0    sat_teklif_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sat_teklif_id_seq', 1, true);
          public       	   ths_admin    false    287            {           0    0    set_ch_firma_tipi_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_firma_tipi_id_seq', 5, false);
          public       	   ths_admin    false    289            |           0    0    set_ch_firma_turu_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_firma_turu_id_seq', 2, false);
          public       	   ths_admin    false    291            }           0    0    set_ch_grup_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.set_ch_grup_id_seq', 72, true);
          public       	   ths_admin    false    292            ~           0    0    set_ch_hesap_plani_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_ch_hesap_plani_id_seq', 286, false);
          public       	   ths_admin    false    293                       0    0    set_ch_hesap_tipi_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_hesap_tipi_id_seq', 3, false);
          public       	   ths_admin    false    295            �           0    0    set_ch_vergi_orani_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_vergi_orani_id_seq', 7, true);
          public       	   ths_admin    false    297            �           0    0    set_einv_fatura_tipi_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_einv_fatura_tipi_id_seq', 6, false);
          public       	   ths_admin    false    299            �           0    0    set_einv_odeme_sekli_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_einv_odeme_sekli_id_seq', 32, false);
          public       	   ths_admin    false    301            �           0    0    set_einv_paket_tipi_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.set_einv_paket_tipi_id_seq', 4, false);
          public       	   ths_admin    false    303            �           0    0    set_einv_tasima_ucreti_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_einv_tasima_ucreti_id_seq', 3, true);
          public       	   ths_admin    false    305            �           0    0    set_einv_teslim_sekli_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.set_einv_teslim_sekli_id_seq', 28, false);
          public       	   ths_admin    false    307            �           0    0    set_prs_birim_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.set_prs_birim_id_seq', 45, true);
          public       	   ths_admin    false    309            �           0    0    set_prs_bolum_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.set_prs_bolum_id_seq', 19, true);
          public       	   ths_admin    false    311            �           0    0    set_prs_ehliyet_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.set_prs_ehliyet_id_seq', 5, true);
          public       	   ths_admin    false    313            �           0    0    set_prs_gorev_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.set_prs_gorev_id_seq', 6, true);
          public       	   ths_admin    false    315            �           0    0    set_prs_lisan_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.set_prs_lisan_id_seq', 4, true);
          public       	   ths_admin    false    317            �           0    0    set_prs_lisan_seviyesi_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.set_prs_lisan_seviyesi_id_seq', 4, false);
          public       	   ths_admin    false    319            �           0    0    set_prs_personel_tipi_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_prs_personel_tipi_id_seq', 3, false);
          public       	   ths_admin    false    321            �           0    0    set_prs_servis_araci_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_prs_servis_araci_id_seq', 1, false);
          public       	   ths_admin    false    323            �           0    0    set_sat_siparis_durum_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_sat_siparis_durum_id_seq', 3, false);
          public       	   ths_admin    false    324            �           0    0    set_sat_teklif_durum_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_sat_teklif_durum_id_seq', 3, false);
          public       	   ths_admin    false    326            �           0    0    stk_cins_ozelligi_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.stk_cins_ozelligi_id_seq', 3, true);
          public       	   ths_admin    false    329            �           0    0    stk_hareketler_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.stk_hareketler_id_seq', 1, false);
          public       	   ths_admin    false    331            �           0    0    stk_kart_ozetleri_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.stk_kart_ozetleri_id_seq', 1, false);
          public       	   ths_admin    false    333            �           0    0    stk_kartlar_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.stk_kartlar_id_seq', 8, true);
          public       	   ths_admin    false    334            �           0    0    stk_resimler_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.stk_resimler_id_seq', 1, true);
          public       	   ths_admin    false    336            �           0    0    stk_stok_ambar_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.stk_stok_ambar_id_seq', 2, false);
          public       	   ths_admin    false    337            �           0    0    stk_stok_grubu_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.stk_stok_grubu_id_seq', 11, true);
          public       	   ths_admin    false    338            �           0    0    sys_adresler_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.sys_adresler_id_seq', 7, true);
          public       	   ths_admin    false    340            �           0    0    sys_ay_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.sys_ay_id_seq', 24, true);
          public       	   ths_admin    false    342            �           0    0    sys_bolge_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sys_bolge_id_seq', 7, false);
          public       	   ths_admin    false    344            �           0    0    sys_erisim_hakki_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sys_erisim_hakki_id_seq', 1027, true);
          public       	   ths_admin    false    347            �           0    0    sys_grid_filtre_siralama_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.sys_grid_filtre_siralama_id_seq', 22, true);
          public       	   ths_admin    false    349            �           0    0    sys_grid_kolon_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.sys_grid_kolon_id_seq', 181, true);
          public       	   ths_admin    false    351            �           0    0    sys_gun_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.sys_gun_id_seq', 16, true);
          public       	   ths_admin    false    353            �           0    0    sys_kaynak_grup_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.sys_kaynak_grup_id_seq', 16, false);
          public       	   ths_admin    false    355            �           0    0    sys_kaynak_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sys_kaynak_id_seq', 44, true);
          public       	   ths_admin    false    357            �           0    0    sys_kullanici_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.sys_kullanici_id_seq', 66, true);
          public       	   ths_admin    false    359            �           0    0    sys_lisan_gui_icerik_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.sys_lisan_gui_icerik_id_seq', 169, true);
          public       	   ths_admin    false    361            �           0    0    sys_lisan_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sys_lisan_id_seq', 6, false);
          public       	   ths_admin    false    363            �           0    0    sys_mukellef_tipi_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.sys_mukellef_tipi_id_seq', 2, false);
          public       	   ths_admin    false    365            �           0    0    sys_olcu_birimi_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.sys_olcu_birimi_id_seq', 16, true);
          public       	   ths_admin    false    367            �           0    0    sys_olcu_birimi_tipi_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.sys_olcu_birimi_tipi_id_seq', 4, true);
          public       	   ths_admin    false    369            �           0    0    sys_ondalik_hane_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.sys_ondalik_hane_id_seq', 1, false);
          public       	   ths_admin    false    371            �           0    0    sys_para_birimi_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.sys_para_birimi_id_seq', 4, true);
          public       	   ths_admin    false    373            �           0    0    sys_sehir_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.sys_sehir_id_seq', 174, false);
          public       	   ths_admin    false    374            �           0    0    sys_ulke_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sys_ulke_id_seq', 321, true);
          public       	   ths_admin    false    376            �           0    0    sys_uygulama_ayari_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sys_uygulama_ayari_id_seq', 4, false);
          public       	   ths_admin    false    378            �           0    0    urt_recete_yan_urunler_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.urt_recete_yan_urunler_id_seq', 1, false);
          public       	   ths_admin    false    383            &           2606    135229    audits audit_pkey 
   CONSTRAINT     O   ALTER TABLE ONLY public.audits
    ADD CONSTRAINT audit_pkey PRIMARY KEY (id);
 ;   ALTER TABLE ONLY public.audits DROP CONSTRAINT audit_pkey;
       public         	   ths_admin    false    221            ,           2606    135231 :   ch_banka_subeleri ch_banka_subeleri_banka_id_sube_kodu_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_banka_id_sube_kodu_key UNIQUE (banka_id, sube_kodu);
 d   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_banka_id_sube_kodu_key;
       public         	   ths_admin    false    225    225            .           2606    135233 (   ch_banka_subeleri ch_banka_subeleri_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_pkey;
       public         	   ths_admin    false    225            (           2606    135235 %   ch_bankalar ch_bankalar_banka_adi_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.ch_bankalar
    ADD CONSTRAINT ch_bankalar_banka_adi_key UNIQUE (banka_adi);
 O   ALTER TABLE ONLY public.ch_bankalar DROP CONSTRAINT ch_bankalar_banka_adi_key;
       public         	   ths_admin    false    223            *           2606    135237    ch_bankalar ch_bankalar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ch_bankalar
    ADD CONSTRAINT ch_bankalar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ch_bankalar DROP CONSTRAINT ch_bankalar_pkey;
       public         	   ths_admin    false    223            0           2606    135239 !   ch_bolgeler ch_bolgeler_bolge_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.ch_bolgeler
    ADD CONSTRAINT ch_bolgeler_bolge_key UNIQUE (bolge);
 K   ALTER TABLE ONLY public.ch_bolgeler DROP CONSTRAINT ch_bolgeler_bolge_key;
       public         	   ths_admin    false    227            2           2606    135241    ch_bolgeler ch_bolgeler_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ch_bolgeler
    ADD CONSTRAINT ch_bolgeler_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ch_bolgeler DROP CONSTRAINT ch_bolgeler_pkey;
       public         	   ths_admin    false    227            4           2606    135243 5   ch_doviz_kurlari ch_doviz_kurlari_kur_tarihi_para_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_kur_tarihi_para_key UNIQUE (kur_tarihi, para);
 _   ALTER TABLE ONLY public.ch_doviz_kurlari DROP CONSTRAINT ch_doviz_kurlari_kur_tarihi_para_key;
       public         	   ths_admin    false    229    229            6           2606    135245 &   ch_doviz_kurlari ch_doviz_kurlari_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.ch_doviz_kurlari DROP CONSTRAINT ch_doviz_kurlari_pkey;
       public         	   ths_admin    false    229            8           2606    135247    ch_gruplar ch_gruplar_grup_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.ch_gruplar
    ADD CONSTRAINT ch_gruplar_grup_key UNIQUE (grup);
 H   ALTER TABLE ONLY public.ch_gruplar DROP CONSTRAINT ch_gruplar_grup_key;
       public         	   ths_admin    false    230            :           2606    135249    ch_gruplar ch_gruplar_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.ch_gruplar
    ADD CONSTRAINT ch_gruplar_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.ch_gruplar DROP CONSTRAINT ch_gruplar_pkey;
       public         	   ths_admin    false    230            @           2606    135251 (   ch_hesap_planlari ch_hesap_planlari_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.ch_hesap_planlari
    ADD CONSTRAINT ch_hesap_planlari_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.ch_hesap_planlari DROP CONSTRAINT ch_hesap_planlari_pkey;
       public         	   ths_admin    false    233            <           2606    135253 &   ch_hesaplar ch_hesaplar_hesap_kodu_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_hesap_kodu_key UNIQUE (hesap_kodu);
 P   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_hesap_kodu_key;
       public         	   ths_admin    false    231            >           2606    135255    ch_hesaplar ch_hesaplar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_pkey;
       public         	   ths_admin    false    231            B           2606    135257 (   mhs_fis_detaylari mhs_fis_detaylari_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.mhs_fis_detaylari
    ADD CONSTRAINT mhs_fis_detaylari_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.mhs_fis_detaylari DROP CONSTRAINT mhs_fis_detaylari_pkey;
       public         	   ths_admin    false    235            D           2606    135259    mhs_fisler mhs_fisler_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.mhs_fisler
    ADD CONSTRAINT mhs_fisler_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.mhs_fisler DROP CONSTRAINT mhs_fisler_pkey;
       public         	   ths_admin    false    237            F           2606    135261 $   mhs_fisler mhs_fisler_yevmiye_no_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.mhs_fisler
    ADD CONSTRAINT mhs_fisler_yevmiye_no_key UNIQUE (yevmiye_no);
 N   ALTER TABLE ONLY public.mhs_fisler DROP CONSTRAINT mhs_fisler_yevmiye_no_key;
       public         	   ths_admin    false    237            H           2606    135263 .   mhs_transfer_kodlari mhs_transfer_kodlari_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.mhs_transfer_kodlari
    ADD CONSTRAINT mhs_transfer_kodlari_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.mhs_transfer_kodlari DROP CONSTRAINT mhs_transfer_kodlari_pkey;
       public         	   ths_admin    false    239            J           2606    135265 ;   mhs_transfer_kodlari mhs_transfer_kodlari_transfer_kodu_key 
   CONSTRAINT        ALTER TABLE ONLY public.mhs_transfer_kodlari
    ADD CONSTRAINT mhs_transfer_kodlari_transfer_kodu_key UNIQUE (transfer_kodu);
 e   ALTER TABLE ONLY public.mhs_transfer_kodlari DROP CONSTRAINT mhs_transfer_kodlari_transfer_kodu_key;
       public         	   ths_admin    false    239            L           2606    135267 8   prs_ehliyetler prs_ehliyetler_ehliyet_id_personel_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_ehliyet_id_personel_id_key UNIQUE (ehliyet_id, personel_id);
 b   ALTER TABLE ONLY public.prs_ehliyetler DROP CONSTRAINT prs_ehliyetler_ehliyet_id_personel_id_key;
       public         	   ths_admin    false    241    241            N           2606    135269 "   prs_ehliyetler prs_ehliyetler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.prs_ehliyetler DROP CONSTRAINT prs_ehliyetler_pkey;
       public         	   ths_admin    false    241            P           2606    135271 @   prs_lisan_bilgileri prs_lisan_bilgileri_lisan_id_personel_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_lisan_id_personel_id_key UNIQUE (lisan_id, personel_id);
 j   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_lisan_id_personel_id_key;
       public         	   ths_admin    false    242    242            R           2606    135273 ,   prs_lisan_bilgileri prs_lisan_bilgileri_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_pkey;
       public         	   ths_admin    false    242            T           2606    136125 ,   prs_personeller prs_personeller_ad_soyad_key 
   CONSTRAINT     l   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_ad_soyad_key UNIQUE (ad, soyad);
 V   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_ad_soyad_key;
       public         	   ths_admin    false    245    245            V           2606    135275 $   prs_personeller prs_personeller_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_pkey;
       public         	   ths_admin    false    245            �           2606    135277 .   sat_fatura_detaylari sat_fatura_detaylari_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.sat_fatura_detaylari
    ADD CONSTRAINT sat_fatura_detaylari_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.sat_fatura_detaylari DROP CONSTRAINT sat_fatura_detaylari_pkey;
       public         	   ths_admin    false    267            �           2606    135279     sat_faturalar sat_faturalar_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.sat_faturalar
    ADD CONSTRAINT sat_faturalar_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.sat_faturalar DROP CONSTRAINT sat_faturalar_pkey;
       public         	   ths_admin    false    269            �           2606    135281 2   sat_irsaliye_detaylari sat_irsaliye_detaylari_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.sat_irsaliye_detaylari
    ADD CONSTRAINT sat_irsaliye_detaylari_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.sat_irsaliye_detaylari DROP CONSTRAINT sat_irsaliye_detaylari_pkey;
       public         	   ths_admin    false    271            �           2606    135283 $   sat_irsaliyeler sat_irsaliyeler_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.sat_irsaliyeler
    ADD CONSTRAINT sat_irsaliyeler_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.sat_irsaliyeler DROP CONSTRAINT sat_irsaliyeler_pkey;
       public         	   ths_admin    false    273            �           2606    135285 0   sat_siparis_detaylari sat_siparis_detaylari_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_pkey;
       public         	   ths_admin    false    275            �           2606    135287 "   sat_siparisler sat_siparisler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_pkey;
       public         	   ths_admin    false    277            �           2606    135289 .   sat_teklif_detaylari sat_teklif_detaylari_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_pkey;
       public         	   ths_admin    false    284            �           2606    135291 &   sat_teklifler sat_teklif_teklif_no_key 
   CONSTRAINT     f   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklif_teklif_no_key UNIQUE (teklif_no);
 P   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklif_teklif_no_key;
       public         	   ths_admin    false    286            �           2606    135293     sat_teklifler sat_teklifler_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_pkey;
       public         	   ths_admin    false    286            �           2606    135295 9   set_ch_firma_turleri set_acc_firma_turleri_firma_turu_key 
   CONSTRAINT     z   ALTER TABLE ONLY public.set_ch_firma_turleri
    ADD CONSTRAINT set_acc_firma_turleri_firma_turu_key UNIQUE (firma_turu);
 c   ALTER TABLE ONLY public.set_ch_firma_turleri DROP CONSTRAINT set_acc_firma_turleri_firma_turu_key;
       public         	   ths_admin    false    290            �           2606    135297 /   set_ch_firma_turleri set_acc_firma_turleri_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.set_ch_firma_turleri
    ADD CONSTRAINT set_acc_firma_turleri_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY public.set_ch_firma_turleri DROP CONSTRAINT set_acc_firma_turleri_pkey;
       public         	   ths_admin    false    290            �           2606    135299 8   set_ch_firma_tipleri set_ch_firma_tipleri_firma_tipi_key 
   CONSTRAINT     y   ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_firma_tipi_key UNIQUE (firma_tipi);
 b   ALTER TABLE ONLY public.set_ch_firma_tipleri DROP CONSTRAINT set_ch_firma_tipleri_firma_tipi_key;
       public         	   ths_admin    false    288            �           2606    135301 .   set_ch_firma_tipleri set_ch_firma_tipleri_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.set_ch_firma_tipleri DROP CONSTRAINT set_ch_firma_tipleri_pkey;
       public         	   ths_admin    false    288            �           2606    135303 7   set_ch_hesap_tipleri set_ch_hesap_tipleri_hesa_tipi_key 
   CONSTRAINT     x   ALTER TABLE ONLY public.set_ch_hesap_tipleri
    ADD CONSTRAINT set_ch_hesap_tipleri_hesa_tipi_key UNIQUE (hesap_tipi);
 a   ALTER TABLE ONLY public.set_ch_hesap_tipleri DROP CONSTRAINT set_ch_hesap_tipleri_hesa_tipi_key;
       public         	   ths_admin    false    294            �           2606    135305 .   set_ch_hesap_tipleri set_ch_hesap_tipleri_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.set_ch_hesap_tipleri
    ADD CONSTRAINT set_ch_hesap_tipleri_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.set_ch_hesap_tipleri DROP CONSTRAINT set_ch_hesap_tipleri_pkey;
       public         	   ths_admin    false    294            �           2606    135307 0   set_ch_vergi_oranlari set_ch_vergi_oranlari_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_pkey;
       public         	   ths_admin    false    296            �           2606    135309 :   set_ch_vergi_oranlari set_ch_vergi_oranlari_veri_orani_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_veri_orani_key UNIQUE (vergi_orani);
 d   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_veri_orani_key;
       public         	   ths_admin    false    296            �           2606    135311 ?   set_einv_fatura_tipleri set_einv_fatura_tipleri_fatura_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_fatura_tipleri
    ADD CONSTRAINT set_einv_fatura_tipleri_fatura_tipi_key UNIQUE (fatura_tipi);
 i   ALTER TABLE ONLY public.set_einv_fatura_tipleri DROP CONSTRAINT set_einv_fatura_tipleri_fatura_tipi_key;
       public         	   ths_admin    false    298            �           2606    135313 4   set_einv_fatura_tipleri set_einv_fatura_tipleri_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.set_einv_fatura_tipleri
    ADD CONSTRAINT set_einv_fatura_tipleri_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.set_einv_fatura_tipleri DROP CONSTRAINT set_einv_fatura_tipleri_pkey;
       public         	   ths_admin    false    298            �           2606    135315 6   set_einv_odeme_sekilleri set_einv_odeme_sekilleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.set_einv_odeme_sekilleri
    ADD CONSTRAINT set_einv_odeme_sekilleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.set_einv_odeme_sekilleri DROP CONSTRAINT set_einv_odeme_sekilleri_pkey;
       public         	   ths_admin    false    300            �           2606    135317 A   set_einv_odeme_sekilleri set_einv_odeme_sekli_odeme_sekilleri_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_odeme_sekilleri
    ADD CONSTRAINT set_einv_odeme_sekli_odeme_sekilleri_key UNIQUE (odeme_sekli);
 k   ALTER TABLE ONLY public.set_einv_odeme_sekilleri DROP CONSTRAINT set_einv_odeme_sekli_odeme_sekilleri_key;
       public         	   ths_admin    false    300            �           2606    135319 5   set_einv_paket_tipleri set_einv_paket_tipleri_kod_key 
   CONSTRAINT     o   ALTER TABLE ONLY public.set_einv_paket_tipleri
    ADD CONSTRAINT set_einv_paket_tipleri_kod_key UNIQUE (kod);
 _   ALTER TABLE ONLY public.set_einv_paket_tipleri DROP CONSTRAINT set_einv_paket_tipleri_kod_key;
       public         	   ths_admin    false    302            �           2606    135321 2   set_einv_paket_tipleri set_einv_paket_tipleri_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.set_einv_paket_tipleri
    ADD CONSTRAINT set_einv_paket_tipleri_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.set_einv_paket_tipleri DROP CONSTRAINT set_einv_paket_tipleri_pkey;
       public         	   ths_admin    false    302            �           2606    135323 8   set_einv_tasima_ucretleri set_einv_tasima_ucretleri_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.set_einv_tasima_ucretleri
    ADD CONSTRAINT set_einv_tasima_ucretleri_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.set_einv_tasima_ucretleri DROP CONSTRAINT set_einv_tasima_ucretleri_pkey;
       public         	   ths_admin    false    304            �           2606    135325 E   set_einv_tasima_ucretleri set_einv_tasima_ucretleri_tasima_ucreti_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_tasima_ucretleri
    ADD CONSTRAINT set_einv_tasima_ucretleri_tasima_ucreti_key UNIQUE (tasima_ucreti);
 o   ALTER TABLE ONLY public.set_einv_tasima_ucretleri DROP CONSTRAINT set_einv_tasima_ucretleri_tasima_ucreti_key;
       public         	   ths_admin    false    304            �           2606    135327 8   set_einv_teslim_sekilleri set_einv_teslim_sekilleri_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.set_einv_teslim_sekilleri
    ADD CONSTRAINT set_einv_teslim_sekilleri_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.set_einv_teslim_sekilleri DROP CONSTRAINT set_einv_teslim_sekilleri_pkey;
       public         	   ths_admin    false    306            �           2606    135329 D   set_einv_teslim_sekilleri set_einv_teslim_sekilleri_teslim_sekli_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_teslim_sekilleri
    ADD CONSTRAINT set_einv_teslim_sekilleri_teslim_sekli_key UNIQUE (teslim_sekli);
 n   ALTER TABLE ONLY public.set_einv_teslim_sekilleri DROP CONSTRAINT set_einv_teslim_sekilleri_teslim_sekli_key;
       public         	   ths_admin    false    306            �           2606    135331 4   set_prs_birimler set_prs_birimler_birim_bolum_id_key 
   CONSTRAINT     z   ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_birim_bolum_id_key UNIQUE (birim, bolum_id);
 ^   ALTER TABLE ONLY public.set_prs_birimler DROP CONSTRAINT set_prs_birimler_birim_bolum_id_key;
       public         	   ths_admin    false    308    308            �           2606    135333 &   set_prs_birimler set_prs_birimler_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_birimler DROP CONSTRAINT set_prs_birimler_pkey;
       public         	   ths_admin    false    308            �           2606    135335 +   set_prs_bolumler set_prs_bolumler_bolum_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.set_prs_bolumler
    ADD CONSTRAINT set_prs_bolumler_bolum_key UNIQUE (bolum);
 U   ALTER TABLE ONLY public.set_prs_bolumler DROP CONSTRAINT set_prs_bolumler_bolum_key;
       public         	   ths_admin    false    310            �           2606    135337 &   set_prs_bolumler set_prs_bolumler_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_bolumler
    ADD CONSTRAINT set_prs_bolumler_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_bolumler DROP CONSTRAINT set_prs_bolumler_pkey;
       public         	   ths_admin    false    310            �           2606    135339 1   set_prs_ehliyetler set_prs_ehliyetler_ehliyet_key 
   CONSTRAINT     o   ALTER TABLE ONLY public.set_prs_ehliyetler
    ADD CONSTRAINT set_prs_ehliyetler_ehliyet_key UNIQUE (ehliyet);
 [   ALTER TABLE ONLY public.set_prs_ehliyetler DROP CONSTRAINT set_prs_ehliyetler_ehliyet_key;
       public         	   ths_admin    false    312            �           2606    135341 *   set_prs_ehliyetler set_prs_ehliyetler_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.set_prs_ehliyetler
    ADD CONSTRAINT set_prs_ehliyetler_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.set_prs_ehliyetler DROP CONSTRAINT set_prs_ehliyetler_pkey;
       public         	   ths_admin    false    312            �           2606    135343 +   set_prs_gorevler set_prs_gorevler_gorev_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.set_prs_gorevler
    ADD CONSTRAINT set_prs_gorevler_gorev_key UNIQUE (gorev);
 U   ALTER TABLE ONLY public.set_prs_gorevler DROP CONSTRAINT set_prs_gorevler_gorev_key;
       public         	   ths_admin    false    314            �           2606    135345 &   set_prs_gorevler set_prs_gorevler_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_gorevler
    ADD CONSTRAINT set_prs_gorevler_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_gorevler DROP CONSTRAINT set_prs_gorevler_pkey;
       public         	   ths_admin    false    314            �           2606    135347 D   set_prs_lisan_seviyeleri set_prs_lisan_seviyeleri_lisan_seviyesi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri
    ADD CONSTRAINT set_prs_lisan_seviyeleri_lisan_seviyesi_key UNIQUE (lisan_seviyesi);
 n   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri DROP CONSTRAINT set_prs_lisan_seviyeleri_lisan_seviyesi_key;
       public         	   ths_admin    false    318            �           2606    135349 6   set_prs_lisan_seviyeleri set_prs_lisan_seviyeleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri
    ADD CONSTRAINT set_prs_lisan_seviyeleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri DROP CONSTRAINT set_prs_lisan_seviyeleri_pkey;
       public         	   ths_admin    false    318            �           2606    135351 +   set_prs_lisanlar set_prs_lisanlar_lisan_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.set_prs_lisanlar
    ADD CONSTRAINT set_prs_lisanlar_lisan_key UNIQUE (lisan);
 U   ALTER TABLE ONLY public.set_prs_lisanlar DROP CONSTRAINT set_prs_lisanlar_lisan_key;
       public         	   ths_admin    false    316            �           2606    135353 &   set_prs_lisanlar set_prs_lisanlar_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_lisanlar
    ADD CONSTRAINT set_prs_lisanlar_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_lisanlar DROP CONSTRAINT set_prs_lisanlar_pkey;
       public         	   ths_admin    false    316            �           2606    135355 C   set_prs_personel_tipleri set_prs_personel_tipleri_personel_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_prs_personel_tipleri
    ADD CONSTRAINT set_prs_personel_tipleri_personel_tipi_key UNIQUE (personel_tipi);
 m   ALTER TABLE ONLY public.set_prs_personel_tipleri DROP CONSTRAINT set_prs_personel_tipleri_personel_tipi_key;
       public         	   ths_admin    false    320            �           2606    135357 6   set_prs_personel_tipleri set_prs_personel_tipleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.set_prs_personel_tipleri
    ADD CONSTRAINT set_prs_personel_tipleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.set_prs_personel_tipleri DROP CONSTRAINT set_prs_personel_tipleri_pkey;
       public         	   ths_admin    false    320            �           2606    135359 ?   set_prs_tasima_servisleri set_prs_tasima_servisleri_arac_no_key 
   CONSTRAINT     }   ALTER TABLE ONLY public.set_prs_tasima_servisleri
    ADD CONSTRAINT set_prs_tasima_servisleri_arac_no_key UNIQUE (arac_no);
 i   ALTER TABLE ONLY public.set_prs_tasima_servisleri DROP CONSTRAINT set_prs_tasima_servisleri_arac_no_key;
       public         	   ths_admin    false    322            �           2606    135361 8   set_prs_tasima_servisleri set_prs_tasima_servisleri_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.set_prs_tasima_servisleri
    ADD CONSTRAINT set_prs_tasima_servisleri_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.set_prs_tasima_servisleri DROP CONSTRAINT set_prs_tasima_servisleri_pkey;
       public         	   ths_admin    false    322            �           2606    135363 /   set_sls_order_status set_sat_siparis_durum_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.set_sls_order_status
    ADD CONSTRAINT set_sat_siparis_durum_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY public.set_sls_order_status DROP CONSTRAINT set_sat_siparis_durum_pkey;
       public         	   ths_admin    false    279            �           2606    135365 <   set_sls_order_status set_sat_siparis_durum_siparis_durum_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_sls_order_status
    ADD CONSTRAINT set_sat_siparis_durum_siparis_durum_key UNIQUE (siparis_durum);
 f   ALTER TABLE ONLY public.set_sls_order_status DROP CONSTRAINT set_sat_siparis_durum_siparis_durum_key;
       public         	   ths_admin    false    279            �           2606    135367 .   set_sls_offer_status set_sat_teklif_durum_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.set_sls_offer_status
    ADD CONSTRAINT set_sat_teklif_durum_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.set_sls_offer_status DROP CONSTRAINT set_sat_teklif_durum_pkey;
       public         	   ths_admin    false    325            �           2606    135369 :   set_sls_offer_status set_sat_teklif_durum_teklif_durum_key 
   CONSTRAINT     }   ALTER TABLE ONLY public.set_sls_offer_status
    ADD CONSTRAINT set_sat_teklif_durum_teklif_durum_key UNIQUE (teklif_durum);
 d   ALTER TABLE ONLY public.set_sls_offer_status DROP CONSTRAINT set_sat_teklif_durum_teklif_durum_key;
       public         	   ths_admin    false    325            �           2606    135371 '   stk_ambarlar stk_ambarlar_ambar_adi_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.stk_ambarlar
    ADD CONSTRAINT stk_ambarlar_ambar_adi_key UNIQUE (ambar_adi);
 Q   ALTER TABLE ONLY public.stk_ambarlar DROP CONSTRAINT stk_ambarlar_ambar_adi_key;
       public         	   ths_admin    false    327            �           2606    135373    stk_ambarlar stk_ambarlar_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.stk_ambarlar
    ADD CONSTRAINT stk_ambarlar_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.stk_ambarlar DROP CONSTRAINT stk_ambarlar_pkey;
       public         	   ths_admin    false    327            �           2606    135375 2   stk_cins_ozellikleri stk_cins_ozellikleri_cins_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.stk_cins_ozellikleri
    ADD CONSTRAINT stk_cins_ozellikleri_cins_key UNIQUE (cins);
 \   ALTER TABLE ONLY public.stk_cins_ozellikleri DROP CONSTRAINT stk_cins_ozellikleri_cins_key;
       public         	   ths_admin    false    328            �           2606    135377 .   stk_cins_ozellikleri stk_cins_ozellikleri_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.stk_cins_ozellikleri
    ADD CONSTRAINT stk_cins_ozellikleri_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.stk_cins_ozellikleri DROP CONSTRAINT stk_cins_ozellikleri_pkey;
       public         	   ths_admin    false    328            �           2606    135379     stk_gruplar stk_gruplar_grup_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_grup_key UNIQUE (grup);
 J   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_grup_key;
       public         	   ths_admin    false    280            �           2606    135381    stk_gruplar stk_gruplar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_pkey;
       public         	   ths_admin    false    280            �           2606    135383 "   stk_hareketler stk_hareketler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_pkey;
       public         	   ths_admin    false    330            �           2606    135385 (   stk_kart_ozetleri stk_kart_ozetleri_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.stk_kart_ozetleri
    ADD CONSTRAINT stk_kart_ozetleri_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.stk_kart_ozetleri DROP CONSTRAINT stk_kart_ozetleri_pkey;
       public         	   ths_admin    false    332            �           2606    135387 3   stk_kart_ozetleri stk_kart_ozetleri_stk_kart_id_key 
   CONSTRAINT     u   ALTER TABLE ONLY public.stk_kart_ozetleri
    ADD CONSTRAINT stk_kart_ozetleri_stk_kart_id_key UNIQUE (stk_kart_id);
 ]   ALTER TABLE ONLY public.stk_kart_ozetleri DROP CONSTRAINT stk_kart_ozetleri_stk_kart_id_key;
       public         	   ths_admin    false    332            �           2606    135389    stk_kartlar stk_kartlar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_pkey;
       public         	   ths_admin    false    281            �           2606    135391 %   stk_kartlar stk_kartlar_stok_kodu_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_stok_kodu_key UNIQUE (stok_kodu);
 O   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_stok_kodu_key;
       public         	   ths_admin    false    281            �           2606    135393    stk_resimler stk_resimler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.stk_resimler
    ADD CONSTRAINT stk_resimler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.stk_resimler DROP CONSTRAINT stk_resimler_pkey;
       public         	   ths_admin    false    335            �           2606    135395 )   stk_resimler stk_resimler_stk_kart_id_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.stk_resimler
    ADD CONSTRAINT stk_resimler_stk_kart_id_key UNIQUE (stk_kart_id);
 S   ALTER TABLE ONLY public.stk_resimler DROP CONSTRAINT stk_resimler_stk_kart_id_key;
       public         	   ths_admin    false    335            �           2606    135397    sys_adresler sys_adresler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_adresler
    ADD CONSTRAINT sys_adresler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_adresler DROP CONSTRAINT sys_adresler_pkey;
       public         	   ths_admin    false    339                       2606    135399    sys_aylar sys_aylar_ay_adi_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.sys_aylar
    ADD CONSTRAINT sys_aylar_ay_adi_key UNIQUE (ay_adi);
 H   ALTER TABLE ONLY public.sys_aylar DROP CONSTRAINT sys_aylar_ay_adi_key;
       public         	   ths_admin    false    341                       2606    135401    sys_aylar sys_aylar_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.sys_aylar
    ADD CONSTRAINT sys_aylar_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.sys_aylar DROP CONSTRAINT sys_aylar_pkey;
       public         	   ths_admin    false    341                       2606    135403 #   sys_bolgeler sys_bolgeler_bolge_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.sys_bolgeler
    ADD CONSTRAINT sys_bolgeler_bolge_key UNIQUE (bolge);
 M   ALTER TABLE ONLY public.sys_bolgeler DROP CONSTRAINT sys_bolgeler_bolge_key;
       public         	   ths_admin    false    343                       2606    135405    sys_bolgeler sys_bolgeler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_bolgeler
    ADD CONSTRAINT sys_bolgeler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_bolgeler DROP CONSTRAINT sys_bolgeler_pkey;
       public         	   ths_admin    false    343            	           2606    135407 >   sys_ersim_haklari sys_ersim_haklari_kaynak_id_kullanici_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kaynak_id_kullanici_id_key UNIQUE (kaynak_id, kullanici_id);
 h   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_kaynak_id_kullanici_id_key;
       public         	   ths_admin    false    346    346                       2606    135409 (   sys_ersim_haklari sys_ersim_haklari_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_pkey;
       public         	   ths_admin    false    346                       2606    135411 B   sys_grid_filtreler_siralamalar sys_grid_filtreler_siralamalar_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar
    ADD CONSTRAINT sys_grid_filtreler_siralamalar_pkey PRIMARY KEY (id);
 l   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar DROP CONSTRAINT sys_grid_filtreler_siralamalar_pkey;
       public         	   ths_admin    false    348                       2606    135413 W   sys_grid_filtreler_siralamalar sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar
    ADD CONSTRAINT sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key UNIQUE (tablo_adi, is_siralama);
 �   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar DROP CONSTRAINT sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key;
       public         	   ths_admin    false    348    348                       2606    135415 (   sys_grid_kolonlar sys_grid_kolonlar_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.sys_grid_kolonlar DROP CONSTRAINT sys_grid_kolonlar_pkey;
       public         	   ths_admin    false    350                       2606    135417 ;   sys_grid_kolonlar sys_grid_kolonlar_tablo_adi_kolon_adi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_tablo_adi_kolon_adi_key UNIQUE (tablo_adi, kolon_adi);
 e   ALTER TABLE ONLY public.sys_grid_kolonlar DROP CONSTRAINT sys_grid_kolonlar_tablo_adi_kolon_adi_key;
       public         	   ths_admin    false    350    350                       2606    135419 9   sys_grid_kolonlar sys_grid_kolonlar_tablo_adi_sira_no_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_tablo_adi_sira_no_key UNIQUE (tablo_adi, sira_no);
 c   ALTER TABLE ONLY public.sys_grid_kolonlar DROP CONSTRAINT sys_grid_kolonlar_tablo_adi_sira_no_key;
       public         	   ths_admin    false    350    350                       2606    135421 !   sys_gunler sys_gunler_gun_adi_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.sys_gunler
    ADD CONSTRAINT sys_gunler_gun_adi_key UNIQUE (gun_adi);
 K   ALTER TABLE ONLY public.sys_gunler DROP CONSTRAINT sys_gunler_gun_adi_key;
       public         	   ths_admin    false    352                       2606    135423    sys_gunler sys_gunler_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.sys_gunler
    ADD CONSTRAINT sys_gunler_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.sys_gunler DROP CONSTRAINT sys_gunler_pkey;
       public         	   ths_admin    false    352                       2606    135425 1   sys_kaynak_gruplari sys_kaynak_gruplari_grup_ukey 
   CONSTRAINT     l   ALTER TABLE ONLY public.sys_kaynak_gruplari
    ADD CONSTRAINT sys_kaynak_gruplari_grup_ukey UNIQUE (grup);
 [   ALTER TABLE ONLY public.sys_kaynak_gruplari DROP CONSTRAINT sys_kaynak_gruplari_grup_ukey;
       public         	   ths_admin    false    354                       2606    135427 /   sys_kaynak_gruplari sys_kaynak_gruplari_id_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.sys_kaynak_gruplari
    ADD CONSTRAINT sys_kaynak_gruplari_id_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY public.sys_kaynak_gruplari DROP CONSTRAINT sys_kaynak_gruplari_id_pkey;
       public         	   ths_admin    false    354                       2606    135429 +   sys_kaynaklar sys_kaynaklar_kaynak_kodu_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_kaynak_kodu_key UNIQUE (kaynak_kodu);
 U   ALTER TABLE ONLY public.sys_kaynaklar DROP CONSTRAINT sys_kaynaklar_kaynak_kodu_key;
       public         	   ths_admin    false    356            !           2606    135431     sys_kaynaklar sys_kaynaklar_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.sys_kaynaklar DROP CONSTRAINT sys_kaynaklar_pkey;
       public         	   ths_admin    false    356            '           2606    135433 S   sys_lisan_gui_icerikler sys_lisan_gui_icerikler_lisan_kod_icerik_tipi_tablo_adi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_lisan_gui_icerikler
    ADD CONSTRAINT sys_lisan_gui_icerikler_lisan_kod_icerik_tipi_tablo_adi_key UNIQUE (lisan, kod, icerik_tipi, tablo_adi);
 }   ALTER TABLE ONLY public.sys_lisan_gui_icerikler DROP CONSTRAINT sys_lisan_gui_icerikler_lisan_kod_icerik_tipi_tablo_adi_key;
       public         	   ths_admin    false    360    360    360    360            )           2606    135435 4   sys_lisan_gui_icerikler sys_lisan_gui_icerikler_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.sys_lisan_gui_icerikler
    ADD CONSTRAINT sys_lisan_gui_icerikler_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.sys_lisan_gui_icerikler DROP CONSTRAINT sys_lisan_gui_icerikler_pkey;
       public         	   ths_admin    false    360            +           2606    135437 #   sys_lisanlar sys_lisanlar_lisan_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.sys_lisanlar
    ADD CONSTRAINT sys_lisanlar_lisan_key UNIQUE (lisan);
 M   ALTER TABLE ONLY public.sys_lisanlar DROP CONSTRAINT sys_lisanlar_lisan_key;
       public         	   ths_admin    false    362            -           2606    135439    sys_lisanlar sys_lisanlar_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_lisanlar
    ADD CONSTRAINT sys_lisanlar_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_lisanlar DROP CONSTRAINT sys_lisanlar_pkey;
       public         	   ths_admin    false    362            7           2606    135441 D   sys_olcu_birimi_tipleri sys_olcu_birimi_tipleri_olcu_birimi_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri
    ADD CONSTRAINT sys_olcu_birimi_tipleri_olcu_birimi_tipi_key UNIQUE (olcu_birimi_tipi);
 n   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri DROP CONSTRAINT sys_olcu_birimi_tipleri_olcu_birimi_tipi_key;
       public         	   ths_admin    false    368            9           2606    135443 4   sys_olcu_birimi_tipleri sys_olcu_birimi_tipleri_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri
    ADD CONSTRAINT sys_olcu_birimi_tipleri_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri DROP CONSTRAINT sys_olcu_birimi_tipleri_pkey;
       public         	   ths_admin    false    368            3           2606    135445 /   sys_olcu_birimleri sys_olcu_birimleri_birim_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_birim_key UNIQUE (birim);
 Y   ALTER TABLE ONLY public.sys_olcu_birimleri DROP CONSTRAINT sys_olcu_birimleri_birim_key;
       public         	   ths_admin    false    366            5           2606    135447 *   sys_olcu_birimleri sys_olcu_birimleri_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.sys_olcu_birimleri DROP CONSTRAINT sys_olcu_birimleri_pkey;
       public         	   ths_admin    false    366            ;           2606    135449 ,   sys_ondalik_haneler sys_ondalik_haneler_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.sys_ondalik_haneler
    ADD CONSTRAINT sys_ondalik_haneler_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.sys_ondalik_haneler DROP CONSTRAINT sys_ondalik_haneler_pkey;
       public         	   ths_admin    false    370            =           2606    135451 .   sys_para_birimleri sys_para_birimleri_para_key 
   CONSTRAINT     i   ALTER TABLE ONLY public.sys_para_birimleri
    ADD CONSTRAINT sys_para_birimleri_para_key UNIQUE (para);
 X   ALTER TABLE ONLY public.sys_para_birimleri DROP CONSTRAINT sys_para_birimleri_para_key;
       public         	   ths_admin    false    372            ?           2606    135453 *   sys_para_birimleri sys_para_birimleri_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.sys_para_birimleri
    ADD CONSTRAINT sys_para_birimleri_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.sys_para_birimleri DROP CONSTRAINT sys_para_birimleri_pkey;
       public         	   ths_admin    false    372            �           2606    135455    sys_sehirler sys_sehirler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_pkey;
       public         	   ths_admin    false    282            �           2606    135457 +   sys_sehirler sys_sehirler_ulke_id_sehir_key 
   CONSTRAINT     p   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_ulke_id_sehir_key UNIQUE (ulke_id, sehir);
 U   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_ulke_id_sehir_key;
       public         	   ths_admin    false    282    282            A           2606    135459    sys_ulkeler sys_ulkeler_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.sys_ulkeler
    ADD CONSTRAINT sys_ulkeler_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.sys_ulkeler DROP CONSTRAINT sys_ulkeler_pkey;
       public         	   ths_admin    false    375            C           2606    135461 %   sys_ulkeler sys_ulkeler_ulke_kodu_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.sys_ulkeler
    ADD CONSTRAINT sys_ulkeler_ulke_kodu_key UNIQUE (ulke_kodu);
 O   ALTER TABLE ONLY public.sys_ulkeler DROP CONSTRAINT sys_ulkeler_ulke_kodu_key;
       public         	   ths_admin    false    375            #           2606    135463    sys_kullanicilar sys_users_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_pkey PRIMARY KEY (id);
 I   ALTER TABLE ONLY public.sys_kullanicilar DROP CONSTRAINT sys_users_pkey;
       public         	   ths_admin    false    358            %           2606    135465 '   sys_kullanicilar sys_users_username_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_username_key UNIQUE (kullanici_adi);
 Q   ALTER TABLE ONLY public.sys_kullanicilar DROP CONSTRAINT sys_users_username_key;
       public         	   ths_admin    false    358            E           2606    135467 0   sys_uygulama_ayarlari sys_uygulama_ayarlari_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_pkey;
       public         	   ths_admin    false    377            /           2606    135469 G   sys_vergi_mukellef_tipleri sys_vergi_mukellef_tipleri_mukellef_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_vergi_mukellef_tipleri
    ADD CONSTRAINT sys_vergi_mukellef_tipleri_mukellef_tipi_key UNIQUE (mukellef_tipi);
 q   ALTER TABLE ONLY public.sys_vergi_mukellef_tipleri DROP CONSTRAINT sys_vergi_mukellef_tipleri_mukellef_tipi_key;
       public         	   ths_admin    false    364            1           2606    135471 :   sys_vergi_mukellef_tipleri sys_vergi_mukellef_tipleri_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.sys_vergi_mukellef_tipleri
    ADD CONSTRAINT sys_vergi_mukellef_tipleri_pkey PRIMARY KEY (id);
 d   ALTER TABLE ONLY public.sys_vergi_mukellef_tipleri DROP CONSTRAINT sys_vergi_mukellef_tipleri_pkey;
       public         	   ths_admin    false    364            X           2606    135473 ,   urt_iscilikler urt_iscilikler_gider_kodu_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_gider_kodu_key UNIQUE (gider_kodu);
 V   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_gider_kodu_key;
       public         	   ths_admin    false    247            Z           2606    135475 "   urt_iscilikler urt_iscilikler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_pkey;
       public         	   ths_admin    false    247            \           2606    135477 >   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_pkey;
       public         	   ths_admin    false    249            ^           2606    135479 Q   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_stok_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_header_id_key UNIQUE (stok_kodu, header_id);
 {   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_header_id_key;
       public         	   ths_admin    false    249    249            `           2606    135481 9   urt_paket_hammaddeler urt_paket_hammaddeler_paket_adi_key 
   CONSTRAINT     y   ALTER TABLE ONLY public.urt_paket_hammaddeler
    ADD CONSTRAINT urt_paket_hammaddeler_paket_adi_key UNIQUE (paket_adi);
 c   ALTER TABLE ONLY public.urt_paket_hammaddeler DROP CONSTRAINT urt_paket_hammaddeler_paket_adi_key;
       public         	   ths_admin    false    251            b           2606    135483 0   urt_paket_hammaddeler urt_paket_hammaddeler_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.urt_paket_hammaddeler
    ADD CONSTRAINT urt_paket_hammaddeler_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.urt_paket_hammaddeler DROP CONSTRAINT urt_paket_hammaddeler_pkey;
       public         	   ths_admin    false    251            d           2606    135485 <   urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_pkey PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_paket_iscilik_detaylari_pkey;
       public         	   ths_admin    false    253            h           2606    135487 7   urt_paket_iscilikler urt_paket_iscilikler_paket_adi_key 
   CONSTRAINT     w   ALTER TABLE ONLY public.urt_paket_iscilikler
    ADD CONSTRAINT urt_paket_iscilikler_paket_adi_key UNIQUE (paket_adi);
 a   ALTER TABLE ONLY public.urt_paket_iscilikler DROP CONSTRAINT urt_paket_iscilikler_paket_adi_key;
       public         	   ths_admin    false    255            j           2606    135489 .   urt_paket_iscilikler urt_paket_iscilikler_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.urt_paket_iscilikler
    ADD CONSTRAINT urt_paket_iscilikler_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.urt_paket_iscilikler DROP CONSTRAINT urt_paket_iscilikler_pkey;
       public         	   ths_admin    false    255            l           2606    135491 2   urt_recete_hammaddeler urt_recete_hammaddeler_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_pkey;
       public         	   ths_admin    false    257            n           2606    135493 E   urt_recete_hammaddeler urt_recete_hammaddeler_stok_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_stok_kodu_header_id_key UNIQUE (stok_kodu, header_id);
 o   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_stok_kodu_header_id_key;
       public         	   ths_admin    false    257    257            t           2606    135495 <   urt_recete_iscilikler urt_recete_iscilikler_iscilik_kodu_key 
   CONSTRAINT        ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_iscilik_kodu_key UNIQUE (iscilik_kodu);
 f   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_iscilik_kodu_key;
       public         	   ths_admin    false    261            v           2606    135497 0   urt_recete_iscilikler urt_recete_iscilikler_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_pkey;
       public         	   ths_admin    false    261            x           2606    135499 P   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_header_id_paket_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_header_id_paket_id_key UNIQUE (header_id, paket_id);
 z   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_header_id_paket_id_key;
       public         	   ths_admin    false    263    263            z           2606    135501 >   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_pkey;
       public         	   ths_admin    false    263            f           2606    135503 Y   urt_paket_iscilik_detaylari urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key UNIQUE (iscilik_kodu, header_id);
 �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key;
       public         	   ths_admin    false    253    253            |           2606    135505 N   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_header_id_paket_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_header_id_paket_id_key UNIQUE (header_id, paket_id);
 x   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_header_id_paket_id_key;
       public         	   ths_admin    false    265    265            ~           2606    135507 <   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_pkey PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_pkey;
       public         	   ths_admin    false    265            G           2606    135509 2   urt_recete_yan_urunler urt_recete_yan_urunler_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_pkey;
       public         	   ths_admin    false    382            I           2606    135511 E   urt_recete_yan_urunler urt_recete_yan_urunler_urun_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_urun_kodu_header_id_key UNIQUE (urun_kodu, header_id);
 o   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_urun_kodu_header_id_key;
       public         	   ths_admin    false    382    382            p           2606    135513     urt_receteler urt_receteler_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.urt_receteler DROP CONSTRAINT urt_receteler_pkey;
       public         	   ths_admin    false    259            r           2606    135515 2   urt_receteler urt_receteler_urun_kodu_urun_adi_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_urun_kodu_urun_adi_key UNIQUE (urun_kodu, urun_adi);
 \   ALTER TABLE ONLY public.urt_receteler DROP CONSTRAINT urt_receteler_urun_kodu_urun_adi_key;
       public         	   ths_admin    false    259    259            �           1259    135516 #   idx_sat_siparis_detaylari_header_id    INDEX     j   CREATE INDEX idx_sat_siparis_detaylari_header_id ON public.sat_siparis_detaylari USING btree (header_id);
 7   DROP INDEX public.idx_sat_siparis_detaylari_header_id;
       public         	   ths_admin    false    275            �           1259    135517    idx_sat_siparis_musteri_kodu    INDEX     _   CREATE INDEX idx_sat_siparis_musteri_kodu ON public.sat_siparisler USING btree (musteri_kodu);
 0   DROP INDEX public.idx_sat_siparis_musteri_kodu;
       public         	   ths_admin    false    277            �           1259    135518 "   idx_sat_teklif_detaylari_header_id    INDEX     h   CREATE INDEX idx_sat_teklif_detaylari_header_id ON public.sat_teklif_detaylari USING btree (header_id);
 6   DROP INDEX public.idx_sat_teklif_detaylari_header_id;
       public         	   ths_admin    false    284            �           2620    135519    set_prs_bolumler audit    TRIGGER        CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_bolumler FOR EACH ROW EXECUTE FUNCTION public.audit();
 /   DROP TRIGGER audit ON public.set_prs_bolumler;
       public       	   ths_admin    false    506    310            �           2620    135520    prs_ehliyetler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prs_ehliyetler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 .   DROP TRIGGER notify ON public.prs_ehliyetler;
       public       	   ths_admin    false    241    494            �           2620    135521    prs_lisan_bilgileri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prs_lisan_bilgileri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 3   DROP TRIGGER notify ON public.prs_lisan_bilgileri;
       public       	   ths_admin    false    242    494            �           2620    135522    prs_personeller notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.prs_personeller FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER notify ON public.prs_personeller;
       public       	   ths_admin    false    245    494            �           2620    135523    set_prs_birimler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_birimler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 0   DROP TRIGGER notify ON public.set_prs_birimler;
       public       	   ths_admin    false    494    308            �           2620    135524    set_prs_ehliyetler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_ehliyetler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 2   DROP TRIGGER notify ON public.set_prs_ehliyetler;
       public       	   ths_admin    false    312    494            �           2620    135525    set_prs_gorevler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_gorevler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 0   DROP TRIGGER notify ON public.set_prs_gorevler;
       public       	   ths_admin    false    494    314            �           2620    135526    set_prs_lisan_seviyeleri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_lisan_seviyeleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER notify ON public.set_prs_lisan_seviyeleri;
       public       	   ths_admin    false    494    318            �           2620    135527    set_prs_lisanlar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_lisanlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 0   DROP TRIGGER notify ON public.set_prs_lisanlar;
       public       	   ths_admin    false    494    316            �           2620    135528    set_prs_personel_tipleri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_personel_tipleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER notify ON public.set_prs_personel_tipleri;
       public       	   ths_admin    false    494    320            �           2620    135529     set_prs_tasima_servisleri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_tasima_servisleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER notify ON public.set_prs_tasima_servisleri;
       public       	   ths_admin    false    494    322            �           2620    135530    stk_ambarlar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_ambarlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 ,   DROP TRIGGER notify ON public.stk_ambarlar;
       public       	   ths_admin    false    494    327            �           2620    135531    stk_gruplar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_gruplar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 +   DROP TRIGGER notify ON public.stk_gruplar;
       public       	   ths_admin    false    280    494            �           2620    135532    stk_hareketler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_hareketler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 .   DROP TRIGGER notify ON public.stk_hareketler;
       public       	   ths_admin    false    494    330            �           2620    135533    stk_kartlar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_kartlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 +   DROP TRIGGER notify ON public.stk_kartlar;
       public       	   ths_admin    false    281    494            �           2620    135534 1   sys_grid_kolonlar sys_grid_col_width_table_notify    TRIGGER     �   CREATE TRIGGER sys_grid_col_width_table_notify AFTER INSERT OR DELETE OR UPDATE ON public.sys_grid_kolonlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 J   DROP TRIGGER sys_grid_col_width_table_notify ON public.sys_grid_kolonlar;
       public       	   ths_admin    false    350    494            �           2620    135535    set_prs_bolumler table_notify    TRIGGER     �   CREATE TRIGGER table_notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_bolumler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 6   DROP TRIGGER table_notify ON public.set_prs_bolumler;
       public       	   ths_admin    false    310    494            �           2620    135536 !   stk_cins_ozellikleri table_notify    TRIGGER     �   CREATE TRIGGER table_notify BEFORE INSERT OR DELETE OR UPDATE ON public.stk_cins_ozellikleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 :   DROP TRIGGER table_notify ON public.stk_cins_ozellikleri;
       public       	   ths_admin    false    328    494            �           2620    135537    ch_banka_subeleri trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_banka_subeleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 5   DROP TRIGGER trg_notify ON public.ch_banka_subeleri;
       public       	   ths_admin    false    225    494            �           2620    135538    ch_bankalar trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_bankalar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER trg_notify ON public.ch_bankalar;
       public       	   ths_admin    false    223    494            �           2620    135539    ch_bolgeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_bolgeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER trg_notify ON public.ch_bolgeler;
       public       	   ths_admin    false    227    494            �           2620    135540    ch_doviz_kurlari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_doviz_kurlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 4   DROP TRIGGER trg_notify ON public.ch_doviz_kurlari;
       public       	   ths_admin    false    229    494            �           2620    135541    ch_hesaplar trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_hesaplar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER trg_notify ON public.ch_hesaplar;
       public       	   ths_admin    false    231    494            �           2620    135542    mhs_fis_detaylari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.mhs_fis_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 5   DROP TRIGGER trg_notify ON public.mhs_fis_detaylari;
       public       	   ths_admin    false    494    235            �           2620    135543    mhs_fisler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.mhs_fisler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 .   DROP TRIGGER trg_notify ON public.mhs_fisler;
       public       	   ths_admin    false    237    494            �           2620    135544    mhs_transfer_kodlari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.mhs_transfer_kodlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER trg_notify ON public.mhs_transfer_kodlari;
       public       	   ths_admin    false    494    239            �           2620    135545     set_ch_vergi_oranlari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.set_ch_vergi_oranlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER trg_notify ON public.set_ch_vergi_oranlari;
       public       	   ths_admin    false    296    494            �           2620    135546    urt_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 2   DROP TRIGGER trg_notify ON public.urt_iscilikler;
       public       	   ths_admin    false    247    494            �           2620    135547 '   urt_paket_hammadde_detaylari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_hammadde_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 @   DROP TRIGGER trg_notify ON public.urt_paket_hammadde_detaylari;
       public       	   ths_admin    false    249    494            �           2620    135548     urt_paket_hammaddeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER trg_notify ON public.urt_paket_hammaddeler;
       public       	   ths_admin    false    251    494            �           2620    135549 &   urt_paket_iscilik_detaylari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_iscilik_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 ?   DROP TRIGGER trg_notify ON public.urt_paket_iscilik_detaylari;
       public       	   ths_admin    false    494    253            �           2620    135550    urt_paket_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER trg_notify ON public.urt_paket_iscilikler;
       public       	   ths_admin    false    494    255            �           2620    135551 !   urt_recete_hammaddeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 :   DROP TRIGGER trg_notify ON public.urt_recete_hammaddeler;
       public       	   ths_admin    false    257    494            �           2620    135552     urt_recete_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER trg_notify ON public.urt_recete_iscilikler;
       public       	   ths_admin    false    494    261            �           2620    135553 '   urt_recete_paket_hammaddeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_paket_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 @   DROP TRIGGER trg_notify ON public.urt_recete_paket_hammaddeler;
       public       	   ths_admin    false    263    494            �           2620    135554 &   urt_recete_paket_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_paket_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 ?   DROP TRIGGER trg_notify ON public.urt_recete_paket_iscilikler;
       public       	   ths_admin    false    494    265            �           2620    135555 !   urt_recete_yan_urunler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_yan_urunler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 :   DROP TRIGGER trg_notify ON public.urt_recete_yan_urunler;
       public       	   ths_admin    false    494    382            �           2620    135556    urt_receteler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_receteler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 1   DROP TRIGGER trg_notify ON public.urt_receteler;
       public       	   ths_admin    false    494    259            J           2606    135557 1   ch_banka_subeleri ch_banka_subeleri_banka_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_banka_id_fkey FOREIGN KEY (banka_id) REFERENCES public.ch_bankalar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_banka_id_fkey;
       public       	   ths_admin    false    223    3882    225            K           2606    135562 1   ch_banka_subeleri ch_banka_subeleri_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_sehir_id_fkey;
       public       	   ths_admin    false    225    282    3994            L           2606    135567 +   ch_doviz_kurlari ch_doviz_kurlari_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_para_fkey FOREIGN KEY (para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE CASCADE;
 U   ALTER TABLE ONLY public.ch_doviz_kurlari DROP CONSTRAINT ch_doviz_kurlari_para_fkey;
       public       	   ths_admin    false    4157    372    229            M           2606    135572 %   ch_hesaplar ch_hesaplar_bolge_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_bolge_id_fkey FOREIGN KEY (bolge_id) REFERENCES public.ch_hesap_planlari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 O   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_bolge_id_fkey;
       public       	   ths_admin    false    231    3904    233            N           2606    135577 $   ch_hesaplar ch_hesaplar_grup_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_grup_id_fkey FOREIGN KEY (grup_id) REFERENCES public.ch_gruplar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 N   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_grup_id_fkey;
       public       	   ths_admin    false    3898    231    230            O           2606    135582 *   ch_hesaplar ch_hesaplar_hesap_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_hesap_tipi_id_fkey FOREIGN KEY (hesap_tipi_id) REFERENCES public.set_ch_hesap_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 T   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_hesap_tipi_id_fkey;
       public       	   ths_admin    false    4015    231    294            P           2606    135587 -   ch_hesaplar ch_hesaplar_mukellef_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_mukellef_tipi_id_fkey FOREIGN KEY (mukellef_tipi_id) REFERENCES public.sys_vergi_mukellef_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_mukellef_tipi_id_fkey;
       public       	   ths_admin    false    364    4145    231            Q           2606    135592 2   mhs_fis_detaylari mhs_fis_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mhs_fis_detaylari
    ADD CONSTRAINT mhs_fis_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.mhs_fisler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.mhs_fis_detaylari DROP CONSTRAINT mhs_fis_detaylari_header_id_fkey;
       public       	   ths_admin    false    237    3908    235            R           2606    135597 9   mhs_transfer_kodlari mhs_transfer_kodlari_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mhs_transfer_kodlari
    ADD CONSTRAINT mhs_transfer_kodlari_hesap_kodu_fkey FOREIGN KEY (hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 c   ALTER TABLE ONLY public.mhs_transfer_kodlari DROP CONSTRAINT mhs_transfer_kodlari_hesap_kodu_fkey;
       public       	   ths_admin    false    239    231    3900            S           2606    135602 -   prs_ehliyetler prs_ehliyetler_ehliyet_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_ehliyet_id_fkey FOREIGN KEY (ehliyet_id) REFERENCES public.set_prs_ehliyetler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 W   ALTER TABLE ONLY public.prs_ehliyetler DROP CONSTRAINT prs_ehliyetler_ehliyet_id_fkey;
       public       	   ths_admin    false    4051    312    241            T           2606    135607 .   prs_ehliyetler prs_ehliyetler_personel_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_ehliyetler
    ADD CONSTRAINT prs_ehliyetler_personel_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE CASCADE;
 X   ALTER TABLE ONLY public.prs_ehliyetler DROP CONSTRAINT prs_ehliyetler_personel_id_fkey;
       public       	   ths_admin    false    3926    245    241            U           2606    135612 7   prs_lisan_bilgileri prs_lisan_bilgileri_konusma_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_konusma_id_fkey FOREIGN KEY (konusma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;
 a   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_konusma_id_fkey;
       public       	   ths_admin    false    4063    242    318            V           2606    135617 5   prs_lisan_bilgileri prs_lisan_bilgileri_lisan_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_lisan_id_fkey FOREIGN KEY (lisan_id) REFERENCES public.set_prs_lisanlar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_lisan_id_fkey;
       public       	   ths_admin    false    316    242    4059            W           2606    135622 5   prs_lisan_bilgileri prs_lisan_bilgileri_okuma_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_okuma_id_fkey FOREIGN KEY (okuma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_okuma_id_fkey;
       public       	   ths_admin    false    318    242    4063            X           2606    135627 8   prs_lisan_bilgileri prs_lisan_bilgileri_personel_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_personel_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_personel_id_fkey;
       public       	   ths_admin    false    242    3926    245            Y           2606    135632 5   prs_lisan_bilgileri prs_lisan_bilgileri_yazma_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_yazma_id_fkey FOREIGN KEY (yazma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_yazma_id_fkey;
       public       	   ths_admin    false    242    318    4063            Z           2606    135637 -   prs_personeller prs_personeller_adres_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_adres_id_fkey FOREIGN KEY (adres_id) REFERENCES public.sys_adresler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 W   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_adres_id_fkey;
       public       	   ths_admin    false    4095    339    245            [           2606    135642 -   prs_personeller prs_personeller_birim_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_birim_id_fkey FOREIGN KEY (birim_id) REFERENCES public.set_prs_birimler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 W   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_birim_id_fkey;
       public       	   ths_admin    false    4043    308    245            \           2606    135647 -   prs_personeller prs_personeller_gorev_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_gorev_id_fkey FOREIGN KEY (gorev_id) REFERENCES public.set_prs_gorevler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 W   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_gorev_id_fkey;
       public       	   ths_admin    false    245    314    4055            ]           2606    135652 5   prs_personeller prs_personeller_personel_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_personel_tipi_id_fkey FOREIGN KEY (personel_tipi_id) REFERENCES public.set_prs_personel_tipleri(id) ON UPDATE CASCADE ON DELETE SET NULL;
 _   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_personel_tipi_id_fkey;
       public       	   ths_admin    false    245    320    4067            ^           2606    135657 5   prs_personeller prs_personeller_tasima_servis_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_tasima_servis_id_fkey FOREIGN KEY (tasima_servis_id) REFERENCES public.set_prs_tasima_servisleri(id) ON UPDATE CASCADE ON DELETE SET NULL;
 _   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_tasima_servis_id_fkey;
       public       	   ths_admin    false    245    322    4071            p           2606    135662 8   sat_fatura_detaylari sat_fatura_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_fatura_detaylari
    ADD CONSTRAINT sat_fatura_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_faturalar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.sat_fatura_detaylari DROP CONSTRAINT sat_fatura_detaylari_header_id_fkey;
       public       	   ths_admin    false    269    3970    267            q           2606    135667 <   sat_irsaliye_detaylari sat_irsaliye_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_irsaliye_detaylari
    ADD CONSTRAINT sat_irsaliye_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_irsaliyeler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.sat_irsaliye_detaylari DROP CONSTRAINT sat_irsaliye_detaylari_header_id_fkey;
       public       	   ths_admin    false    3974    273    271            r           2606    135672 :   sat_siparis_detaylari sat_siparis_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_siparisler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 d   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_header_id_fkey;
       public       	   ths_admin    false    275    3980    277            s           2606    135677 <   sat_siparis_detaylari sat_siparis_detaylari_olcu_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_olcu_birimi_fkey FOREIGN KEY (olcu_birimi) REFERENCES public.sys_olcu_birimleri(birim) ON UPDATE CASCADE ON DELETE RESTRICT;
 f   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_olcu_birimi_fkey;
       public       	   ths_admin    false    4147    275    366            t           2606    135682 E   sat_siparis_detaylari sat_siparis_detaylari_referans_ana_urun_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.sat_siparis_detaylari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 o   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_referans_ana_urun_id_fkey;
       public       	   ths_admin    false    275    275    3977            u           2606    135687 :   sat_siparis_detaylari sat_siparis_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 d   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    275    281    3992            v           2606    135692 0   sat_siparisler sat_siparisler_islem_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_islem_tipi_id_fkey FOREIGN KEY (islem_tipi_id) REFERENCES public.set_einv_fatura_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_islem_tipi_id_fkey;
       public       	   ths_admin    false    277    298    4023            w           2606    135697 /   sat_siparisler sat_siparisler_musteri_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_musteri_kodu_fkey FOREIGN KEY (musteri_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_musteri_kodu_fkey;
       public       	   ths_admin    false    231    3900    277            x           2606    135702 8   sat_siparisler sat_siparisler_musteri_temsilcisi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_musteri_temsilcisi_id_fkey FOREIGN KEY (musteri_temsilcisi_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 b   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_musteri_temsilcisi_id_fkey;
       public       	   ths_admin    false    3926    245    277            y           2606    135707 4   sat_siparisler sat_siparisler_nakliye_ucreti_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_nakliye_ucreti_id_fkey FOREIGN KEY (tasima_ucreti_id) REFERENCES public.set_einv_tasima_ucretleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 ^   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_nakliye_ucreti_id_fkey;
       public       	   ths_admin    false    4033    304    277            z           2606    135712 1   sat_siparisler sat_siparisler_odeme_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_odeme_sekli_id_fkey FOREIGN KEY (odeme_sekli_id) REFERENCES public.set_einv_odeme_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_odeme_sekli_id_fkey;
       public       	   ths_admin    false    300    4025    277            {           2606    135717 0   sat_siparisler sat_siparisler_paket_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_paket_tipi_id_fkey FOREIGN KEY (paket_tipi_id) REFERENCES public.set_einv_paket_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_paket_tipi_id_fkey;
       public       	   ths_admin    false    4031    277    302            |           2606    135722 .   sat_siparisler sat_siparisler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_para_birimi_fkey;
       public       	   ths_admin    false    277    4157    372            }           2606    135727 +   sat_siparisler sat_siparisler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 U   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_sehir_id_fkey;
       public       	   ths_admin    false    277    3994    282            ~           2606    135732 3   sat_siparisler sat_siparisler_siparis_durum_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_siparis_durum_id_fkey FOREIGN KEY (siparis_durum_id) REFERENCES public.set_sls_order_status(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 ]   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_siparis_durum_id_fkey;
       public       	   ths_admin    false    277    3982    279                       2606    135737 2   sat_siparisler sat_siparisler_teslim_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_teslim_sekli_id_fkey FOREIGN KEY (teslim_sekli_id) REFERENCES public.set_einv_teslim_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 \   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_teslim_sekli_id_fkey;
       public       	   ths_admin    false    277    4037    306            �           2606    135742 *   sat_siparisler sat_siparisler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 T   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_ulke_id_fkey;
       public       	   ths_admin    false    277    4161    375            �           2606    135747 8   sat_teklif_detaylari sat_teklif_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_teklifler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_header_id_fkey;
       public       	   ths_admin    false    284    4003    286            �           2606    135752 :   sat_teklif_detaylari sat_teklif_detaylari_olcu_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_olcu_birimi_fkey FOREIGN KEY (olcu_birimi) REFERENCES public.sys_olcu_birimleri(birim) ON UPDATE CASCADE ON DELETE RESTRICT;
 d   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_olcu_birimi_fkey;
       public       	   ths_admin    false    284    4147    366            �           2606    135757 C   sat_teklif_detaylari sat_teklif_detaylari_referans_ana_urun_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.sat_teklif_detaylari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 m   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_referans_ana_urun_id_fkey;
       public       	   ths_admin    false    3999    284    284            �           2606    135762 8   sat_teklif_detaylari sat_teklif_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 b   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    284    3992    281            �           2606    135767 .   sat_teklifler sat_teklifler_islem_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_islem_tipi_id_fkey FOREIGN KEY (islem_tipi_id) REFERENCES public.set_einv_fatura_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_islem_tipi_id_fkey;
       public       	   ths_admin    false    286    4023    298            �           2606    135772 -   sat_teklifler sat_teklifler_musteri_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_musteri_kodu_fkey FOREIGN KEY (musteri_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_musteri_kodu_fkey;
       public       	   ths_admin    false    286    3900    231            �           2606    135777 6   sat_teklifler sat_teklifler_musteri_temsilcisi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_musteri_temsilcisi_id_fkey FOREIGN KEY (musteri_temsilcisi_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 `   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_musteri_temsilcisi_id_fkey;
       public       	   ths_admin    false    286    3926    245            �           2606    135782 2   sat_teklifler sat_teklifler_nakliye_ucreti_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_nakliye_ucreti_id_fkey FOREIGN KEY (tasima_ucreti_id) REFERENCES public.set_einv_tasima_ucretleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 \   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_nakliye_ucreti_id_fkey;
       public       	   ths_admin    false    286    4033    304            �           2606    135787 /   sat_teklifler sat_teklifler_odeme_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_odeme_sekli_id_fkey FOREIGN KEY (odeme_sekli_id) REFERENCES public.set_einv_odeme_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_odeme_sekli_id_fkey;
       public       	   ths_admin    false    286    4025    300            �           2606    135792 .   sat_teklifler sat_teklifler_paket_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_paket_tipi_id_fkey FOREIGN KEY (paket_tipi_id) REFERENCES public.set_einv_paket_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_paket_tipi_id_fkey;
       public       	   ths_admin    false    286    4031    302            �           2606    135797 ,   sat_teklifler sat_teklifler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 V   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_para_birimi_fkey;
       public       	   ths_admin    false    286    4157    372            �           2606    135802 )   sat_teklifler sat_teklifler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_sehir_id_fkey;
       public       	   ths_admin    false    286    3994    282            �           2606    135807 0   sat_teklifler sat_teklifler_teslim_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_teslim_sekli_id_fkey FOREIGN KEY (teslim_sekli_id) REFERENCES public.set_einv_teslim_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_teslim_sekli_id_fkey;
       public       	   ths_admin    false    286    4037    306            �           2606    135812 (   sat_teklifler sat_teklifler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 R   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_ulke_id_fkey;
       public       	   ths_admin    false    286    4161    375            �           2606    135817 <   set_ch_firma_tipleri set_ch_firma_tipleri_firma_turu_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_firma_turu_id_fkey FOREIGN KEY (firma_turu_id) REFERENCES public.set_ch_firma_turleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 f   ALTER TABLE ONLY public.set_ch_firma_tipleri DROP CONSTRAINT set_ch_firma_tipleri_firma_turu_id_fkey;
       public       	   ths_admin    false    288    4011    290            �           2606    135822 @   set_ch_vergi_oranlari set_ch_vergi_oranlari_alis_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_alis_hesap_kodu_fkey FOREIGN KEY (alis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 j   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_alis_hesap_kodu_fkey;
       public       	   ths_admin    false    296    3900    231            �           2606    135827 E   set_ch_vergi_oranlari set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey FOREIGN KEY (alis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 o   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    296    3900    231            �           2606    135832 C   set_ch_vergi_oranlari set_ch_vergi_oranlari_ihracat_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_ihracat_hesap_kodu_fkey FOREIGN KEY (ihracat_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 m   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_ihracat_hesap_kodu_fkey;
       public       	   ths_admin    false    296    3900    231            �           2606    135837 H   set_ch_vergi_oranlari set_ch_vergi_oranlari_ihracat_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_ihracat_iade_hesap_kodu_fkey FOREIGN KEY (ihracat_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 r   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_ihracat_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    231    296    3900            �           2606    135842 C   set_ch_vergi_oranlari set_ch_vergi_oranlari_ithalat_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_ithalat_hesap_kodu_fkey FOREIGN KEY (ithalat_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 m   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_ithalat_hesap_kodu_fkey;
       public       	   ths_admin    false    296    3900    231            �           2606    135847 H   set_ch_vergi_oranlari set_ch_vergi_oranlari_ithalat_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_ithalat_iade_hesap_kodu_fkey FOREIGN KEY (ithalat_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 r   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_ithalat_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    296    3900    231            �           2606    135852 A   set_ch_vergi_oranlari set_ch_vergi_oranlari_satis_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_satis_hesap_kodu_fkey FOREIGN KEY (satis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 k   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_satis_hesap_kodu_fkey;
       public       	   ths_admin    false    296    3900    231            �           2606    135857 F   set_ch_vergi_oranlari set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey FOREIGN KEY (satis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 p   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    296    3900    231            �           2606    135862 /   set_prs_birimler set_prs_birimler_bolum_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_bolum_id_fkey FOREIGN KEY (bolum_id) REFERENCES public.set_prs_bolumler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.set_prs_birimler DROP CONSTRAINT set_prs_birimler_bolum_id_fkey;
       public       	   ths_admin    false    308    4047    310            �           2606    135867 ,   stk_gruplar stk_gruplar_alis_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_alis_hesap_kodu_fkey FOREIGN KEY (alis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 V   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_alis_hesap_kodu_fkey;
       public       	   ths_admin    false    280    3900    231            �           2606    135872 1   stk_gruplar stk_gruplar_alis_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_alis_iade_hesap_kodu_fkey FOREIGN KEY (alis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_alis_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    280    3900    231            �           2606    135877 /   stk_gruplar stk_gruplar_ihracat_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_ihracat_hesap_kodu_fkey FOREIGN KEY (ihracat_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_ihracat_hesap_kodu_fkey;
       public       	   ths_admin    false    280    3900    231            �           2606    135882 4   stk_gruplar stk_gruplar_ihracat_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_ihracat_iade_hesap_kodu_fkey FOREIGN KEY (ihracat_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 ^   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_ihracat_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    280    3900    231            �           2606    135887 -   stk_gruplar stk_gruplar_satis_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_satis_hesap_kodu_fkey FOREIGN KEY (satis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_satis_hesap_kodu_fkey;
       public       	   ths_admin    false    280    3900    231            �           2606    135892 2   stk_gruplar stk_gruplar_satis_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_satis_iade_hesap_kodu_fkey FOREIGN KEY (satis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 \   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_satis_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    280    3900    231            �           2606    135897 0   stk_hareketler stk_hareketler_alan_ambar_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_alan_ambar_id_fkey FOREIGN KEY (alan_ambar_id) REFERENCES public.stk_ambarlar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_alan_ambar_id_fkey;
       public       	   ths_admin    false    330    4079    327            �           2606    135902 .   stk_hareketler stk_hareketler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_para_birimi_fkey;
       public       	   ths_admin    false    330    4157    372            �           2606    135907 ,   stk_hareketler stk_hareketler_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 V   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_stok_kodu_fkey;
       public       	   ths_admin    false    330    3992    281            �           2606    135912 1   stk_hareketler stk_hareketler_veren_ambar_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_veren_ambar_id_fkey FOREIGN KEY (veren_ambar_id) REFERENCES public.stk_ambarlar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_veren_ambar_id_fkey;
       public       	   ths_admin    false    330    4079    327            �           2606    135917 4   stk_kart_ozetleri stk_kart_ozetleri_stk_kart_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kart_ozetleri
    ADD CONSTRAINT stk_kart_ozetleri_stk_kart_id_fkey FOREIGN KEY (stk_kart_id) REFERENCES public.stk_kartlar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.stk_kart_ozetleri DROP CONSTRAINT stk_kart_ozetleri_stk_kart_id_fkey;
       public       	   ths_admin    false    332    3990    281            �           2606    135922 &   stk_kartlar stk_kartlar_alis_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_alis_para_fkey FOREIGN KEY (alis_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 P   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_alis_para_fkey;
       public       	   ths_admin    false    281    4157    372            �           2606    135927 $   stk_kartlar stk_kartlar_cins_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_cins_id_fkey FOREIGN KEY (cins_id) REFERENCES public.stk_cins_ozellikleri(id) ON UPDATE CASCADE ON DELETE SET NULL;
 N   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_cins_id_fkey;
       public       	   ths_admin    false    281    4083    328            �           2606    135932 '   stk_kartlar stk_kartlar_ihrac_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_ihrac_para_fkey FOREIGN KEY (ihrac_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_ihrac_para_fkey;
       public       	   ths_admin    false    281    4157    372            �           2606    135937 &   stk_kartlar stk_kartlar_mensei_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_mensei_id_fkey FOREIGN KEY (mensei_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 P   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_mensei_id_fkey;
       public       	   ths_admin    false    281    4161    375            �           2606    135942 +   stk_kartlar stk_kartlar_olcu_birimi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_olcu_birimi_id_fkey FOREIGN KEY (olcu_birimi_id) REFERENCES public.sys_olcu_birimleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 U   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_olcu_birimi_id_fkey;
       public       	   ths_admin    false    281    4149    366            �           2606    135947 '   stk_kartlar stk_kartlar_satis_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_satis_para_fkey FOREIGN KEY (satis_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_satis_para_fkey;
       public       	   ths_admin    false    281    4157    372            �           2606    135952 *   stk_kartlar stk_kartlar_stok_grubu_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_stok_grubu_id_fkey FOREIGN KEY (stok_grubu_id) REFERENCES public.stk_gruplar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 T   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_stok_grubu_id_fkey;
       public       	   ths_admin    false    281    3988    280            �           2606    135957 *   stk_resimler stk_resimler_stk_kart_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_resimler
    ADD CONSTRAINT stk_resimler_stk_kart_id_fkey FOREIGN KEY (stk_kart_id) REFERENCES public.stk_kartlar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stk_resimler DROP CONSTRAINT stk_resimler_stk_kart_id_fkey;
       public       	   ths_admin    false    335    3990    281            �           2606    135962 '   sys_adresler sys_adresler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_adresler
    ADD CONSTRAINT sys_adresler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.sys_adresler DROP CONSTRAINT sys_adresler_sehir_id_fkey;
       public       	   ths_admin    false    339    3994    282            �           2606    135967 2   sys_ersim_haklari sys_ersim_haklari_kaynak_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kaynak_id_fkey FOREIGN KEY (kaynak_id) REFERENCES public.sys_kaynaklar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_kaynak_id_fkey;
       public       	   ths_admin    false    346    4129    356            �           2606    135972 5   sys_ersim_haklari sys_ersim_haklari_kullanici_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kullanici_id_fkey FOREIGN KEY (kullanici_id) REFERENCES public.sys_kullanicilar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_kullanici_id_fkey;
       public       	   ths_admin    false    346    4131    358            �           2606    135977 /   sys_kaynaklar sys_kaynaklar_kaynak_grup_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_kaynak_grup_id_fkey FOREIGN KEY (kaynak_grup_id) REFERENCES public.sys_kaynak_gruplari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.sys_kaynaklar DROP CONSTRAINT sys_kaynaklar_kaynak_grup_id_fkey;
       public       	   ths_admin    false    356    4125    354            �           2606    135982 :   sys_lisan_gui_icerikler sys_lisan_gui_icerikler_lisan_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_lisan_gui_icerikler
    ADD CONSTRAINT sys_lisan_gui_icerikler_lisan_fkey FOREIGN KEY (lisan) REFERENCES public.sys_lisanlar(lisan) ON UPDATE CASCADE ON DELETE RESTRICT;
 d   ALTER TABLE ONLY public.sys_lisan_gui_icerikler DROP CONSTRAINT sys_lisan_gui_icerikler_lisan_fkey;
       public       	   ths_admin    false    360    4139    362            �           2606    135987 8   sys_olcu_birimleri sys_olcu_birimleri_birim_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_birim_tipi_id_fkey FOREIGN KEY (birim_tipi_id) REFERENCES public.sys_olcu_birimi_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 b   ALTER TABLE ONLY public.sys_olcu_birimleri DROP CONSTRAINT sys_olcu_birimleri_birim_tipi_id_fkey;
       public       	   ths_admin    false    366    4153    368            �           2606    135992 '   sys_sehirler sys_sehirler_bolge_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_bolge_id_fkey FOREIGN KEY (bolge_id) REFERENCES public.sys_bolgeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_bolge_id_fkey;
       public       	   ths_admin    false    282    4103    343            �           2606    135997 &   sys_sehirler sys_sehirler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 P   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_ulke_id_fkey;
       public       	   ths_admin    false    282    4161    375            �           2606    136002 )   sys_kullanicilar sys_users_person_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_person_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.sys_kullanicilar DROP CONSTRAINT sys_users_person_id_fkey;
       public       	   ths_admin    false    358    3926    245            �           2606    136007 9   sys_uygulama_ayarlari sys_uygulama_ayarlari_adres_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_adres_id_fkey FOREIGN KEY (adres_id) REFERENCES public.sys_adresler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 c   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_adres_id_fkey;
       public       	   ths_admin    false    377    4095    339            �           2606    136012 6   sys_uygulama_ayarlari sys_uygulama_ayarlari_lisan_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_lisan_fkey FOREIGN KEY (lisan) REFERENCES public.sys_lisanlar(lisan) ON UPDATE CASCADE ON DELETE SET NULL;
 `   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_lisan_fkey;
       public       	   ths_admin    false    377    4139    362            �           2606    136017 5   sys_uygulama_ayarlari sys_uygulama_ayarlari_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_para_fkey FOREIGN KEY (para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE SET NULL;
 _   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_para_fkey;
       public       	   ths_admin    false    377    4157    372            _           2606    136022 +   urt_iscilikler urt_iscilikler_birim_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_birim_id_fkey FOREIGN KEY (birim_id) REFERENCES public.sys_olcu_birimleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 U   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_birim_id_fkey;
       public       	   ths_admin    false    247    4149    366            `           2606    136027 -   urt_iscilikler urt_iscilikler_gider_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_gider_kodu_fkey FOREIGN KEY (gider_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_gider_kodu_fkey;
       public       	   ths_admin    false    247    3900    231            a           2606    136032 H   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_paket_hammaddeler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 r   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_header_id_fkey;
       public       	   ths_admin    false    249    3938    251            b           2606    136037 H   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_recete_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_recete_id_fkey FOREIGN KEY (recete_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 r   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_recete_id_fkey;
       public       	   ths_admin    false    249    3952    259            c           2606    136042 H   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 r   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    249    3992    281            d           2606    136047 F   urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_paket_iscilikler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 p   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_paket_iscilik_detaylari_header_id_fkey;
       public       	   ths_admin    false    253    3946    255            e           2606    136052 I   urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_iscilik_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_iscilik_kodu_fkey FOREIGN KEY (iscilik_kodu) REFERENCES public.urt_iscilikler(gider_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 s   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_paket_iscilik_detaylari_iscilik_kodu_fkey;
       public       	   ths_admin    false    253    3928    247            f           2606    136057 <   urt_recete_hammaddeler urt_recete_hammaddeler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_header_id_fkey;
       public       	   ths_admin    false    257    3952    259            g           2606    136062 <   urt_recete_hammaddeler urt_recete_hammaddeler_recete_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_recete_id_fkey FOREIGN KEY (recete_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_recete_id_fkey;
       public       	   ths_admin    false    257    3952    259            h           2606    136067 <   urt_recete_hammaddeler urt_recete_hammaddeler_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_stok_kodu_fkey;
       public       	   ths_admin    false    257    3992    281            j           2606    136072 :   urt_recete_iscilikler urt_recete_iscilikler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 d   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_header_id_fkey;
       public       	   ths_admin    false    261    3952    259            k           2606    136077 8   urt_recete_iscilikler urt_recete_iscilikler_iscilik_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_iscilik_fkey FOREIGN KEY (iscilik_kodu) REFERENCES public.urt_iscilikler(gider_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 b   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_iscilik_fkey;
       public       	   ths_admin    false    261    3928    247            l           2606    136082 H   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 r   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_header_id_fkey;
       public       	   ths_admin    false    263    3952    259            m           2606    136087 G   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_paket_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_paket_id_fkey FOREIGN KEY (paket_id) REFERENCES public.urt_paket_hammaddeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 q   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_paket_id_fkey;
       public       	   ths_admin    false    263    3938    251            n           2606    136092 F   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 p   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_header_id_fkey;
       public       	   ths_admin    false    265    3952    259            o           2606    136097 E   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_paket_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_paket_id_fkey FOREIGN KEY (paket_id) REFERENCES public.urt_paket_iscilikler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 o   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_paket_id_fkey;
       public       	   ths_admin    false    265    3946    255            �           2606    136102 <   urt_recete_yan_urunler urt_recete_yan_urunler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_header_id_fkey;
       public       	   ths_admin    false    382    3952    259            �           2606    136107 <   urt_recete_yan_urunler urt_recete_yan_urunler_urun_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_urun_kodu_fkey FOREIGN KEY (urun_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_urun_kodu_fkey;
       public       	   ths_admin    false    382    3992    281            i           2606    136112 *   urt_receteler urt_receteler_urun_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_urun_kodu_fkey FOREIGN KEY (urun_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.urt_receteler DROP CONSTRAINT urt_receteler_urun_kodu_fkey;
       public       	   ths_admin    false    259    3992    281            t   D   x�3�4�461��v��srv�0�2�Yrz��x��id�e
242�p�s9����Ԍ+F��� ���      r   0   x�3�:�!��1�3*($�ɑː��1��/��N� �� G�=... �^      v   ^   x�3�tuw�2��vrtq�;�!�˄���4�t�?2/T������'�˂�Ȇ��p��	gdhP����y�\�����F��0��u"G�=... J� �      x     x�]�Kn�0��]"P��ѶH�m�"����d"�30�����z  ��n0�@%=^����EX��~=�Q+�+?_�6�%$�K(5�)d
F4��o!m�?�-�$䈲p�\aMYE�����O���37���P/J�/��)mէ(�^X���ь!د���:�UGA�Pw�5�!���}2⇰'�ea�m��{x�����c��e{
i"D�z��g{e�*��.��d��BNh
M\(��x	��y��H��      y   Z   x�33��=<��נ#|\���,8C\]�<���P!K�#<��C������R@% isCN'G?oGG ۈ�7��1��ɕ+F��� �� �      |     x����n�J���Sp9d�]\*�kdف�p0�N�sBH�J ��y����M��fV�I~���yIQ���&�_�꿪��n�6,�7.�4�D�y}����7�ed^D�8Q�J��,0��}���G��fw�>�q6�2�1�/>�&q��>ޯ~MV�V��������X�|���)�(������J��14��9�_2x����g����MM��X���E���|R_�e�)i�F�Q�Ds���(��o��m�e���R��g�X'܁iełn� Z&cs���#���E�H��ٳ�+�B�PMo'�&�}��F�	�z��ǁr�`�+9����1�y����ˇ�d����V_mx��2�F�g��xov��d6/���q�-��y��~%��g�x��\��,�T��b	�Ah\�G�I�u����΁�&�D���]h`7��o��(����c	(&��'5ߎK�5<0�/i$�3��"Oa5��Dr�Ke�|vC��1���ӹ�~�B���� 䄁1RY�ޙ�h�S��f<SI	�������&x|��|gB°�n ZC鸆M8�<��P6��3�h���7F����dC�@ݩ�I�j��=GԞd�&�}?QSe���Ա�ir�����ܓ��{`ؐ�Ք�z�Z�.N�d���:@��'�W�\b�yr���K�K��X�0JƷi�k1կA�����T���u�����>�Xh:U�ԧOˇ�:K(�6�U�%��Z����(�6\�EUF	$ܶ��]N`�m3���%)ܲ(H�4oS�(���;Q���D����Xv]7e�f3�҇tF��Q����l���~%y��?ؐ����XZS4�g/qg'�L�:���rA�3)��_�6�	�=d�ȟ�_������ ��W���Tw��M:�gS]`�����®�g]��se�M��J�B�N�T�Y�y�>���;.��K���;�mMAܦ��[�`�˯�:Y�iT6,!��i�<�'��`*�OI��M4�����;Z̺����A��3�`m-T0��;�
��o� �D\�iܭ�mxr��X��m�b`2(]��t�^���7����t�.�U�8���# 슈(�JCF !�2�ӡ՜�Z�-��M	с��i�c�i/m���:�FO7��_0!N�m!C	�[wD�x�Ғ�5L�iD$D�z�i�%8B-��eJ�>]Dv�	jeg�!Μ�L�X�DZ�g
t;���(�!L������M����lll���#�uq�"��	������	��ݭ0p-���J�gɜ5��YwBQ8��.�R�>}�'%\��enմ���J�eA�M�B��W���*6KG'��A����]��?�#�"��A��T������E��bcd�PE$$���D�|�D���_�O���#D/�tG]�@�3���)y����� Z�W��A�0E�c~�;��J�y�c_��=�7���h�:쯾�9��=�O��X8���Q��N{�TN����t�;�;1����h��b͡�l�oH�o����������	�e�+������j��,��a�_	�űө�aU$�j8��Ol�/�(=���ᗓ��e����TSz
˰����|tv�A-N��Q�p���H�>H��	��d]��e&��ef��t�|�U�o.��]�b8h*��{�)e/��bKq�u�`�1���g��<�g��<��g��D�g�����g������ѹ�,3�K��L	����r]�hט��lA�|�|����7��d����Ii�����!���Y����b�,3��?�ߟo�+t��a�����Ȯ�r%��h'�4@U���9X�'�G��k�耺}E��bO.�nm�Dxߦ�����
�}t�ȴ�k&�Pw���b]5i(!G���d��۠�Z���e.�[�E�s�\��4E����4��ű�A�G3����+5���Ӕ��w�1��qt'�=~���y-mJf���K�\���q� �Y_��;��������ER^�r6w[����}���h��%0�ح	�L�e�1� ��E�<A�����֓�cw�س(�.mq$)Z^Z�Z�]R:�=4 u��KR�ܝ��S��U�P��]�Ƣι{)������xw��9�e���v�_B�S0k/$��+>!٭W|��gM�λO*4�mw둻Rj(���RC	v�(�l2Fy�,��k�p�չa~��\����B�ڊI� �^X��(,��~��$o��H{����|�c[ǳYTɑb��M�i��� �U�^��\��h��|ڸ0��$�ַ�6
�\�ͥ���C�����YeY���(�[�����7�WȒq�Ǝmx$rޕ�=�0`���+Ǻ�Ӂ�8�{�,fU�����p՘��a~���?�$a3S^����@v����L+WQV^�R���Q�!d��^hUǴyiK��e�n��5|+��L������`��jjZi>����(��/
�Ԧ�c���y:�5��1r��������@��%�\,F�s*ـZ���u}ZX�XX�[u'�_p$�MI�����0#� ��w%��-(��l|P��EsI�����W�槥-F����J���5��Ƴ�M�$H�;rvK��/���Z	�J��[�&�|��C��i��V���MwI=���K��(����0���L����o�l*�X��H���4bcA�'�)�5oB �ۺ��޶-(��l�ú��B�0��YjcJv��mҡ�&t�M�@,d��VQ�MWؙ>����v��L =.��柨��ɢH�����V2�-�6Ѣ�.�RA���B��Y]�"��tj;�v�;��Wn1�y� Z�q��J���T�l%o�����Wmo}���~ؾ=�(�(�E��~R��$�.j*YŻ�6�b��K�U�Pe�4���oe.˟�T�UCCk�a��݆G�B��3���`����9ݰb�]Y����G,W+�d�>��]��e�U�n�[~��F���ޤ���-Ҩ�%��A����z�B�X�[�%�eoݴy�|�/4=!Ď��F��M'-�`�p��@}V���"®�u-V
�B�h�t�m��Us��~��x`�W+�������p�Y{��xH���w�ɢ�������!�'h�-�����������j<!k+d�cdGЮ��U�/��e�IS��}���c����NXm�&>k?Kl+�I����t�(
�eE`iY�hz�n�6N:��
�}GY��_Gjq��.�'���|"�h}H���'F�t�}i��^�%�*/N�g��7h}���5� ɇ�^�%�B@��BYx�5�@�	���k��ǡ�{Q~�א/�˯�{'�7�͋��e�$��'_�^������)�W�v����y��g��녅Η����]6g?��e묖!ߏ�����ɰ;�?~7�V?O���.N�~��a�<�~�7��Nx�ߚK����Fݷ���dn<�૳��̮�d��Cr��Ὼ'�ѱx�T>���6��%��>$�q�:C�Z����?_�x�?���      z      x��]�n�J]3_����`?�M.�s(QE�1��!��de��o��_s���J�\�j%@�jD����t=�a�]�Pu��j�Yu�|��e�P�}�����C���?���C0����eɟ�g~��Of���Ҿ�]��y���gp>/������]5�cA�����i���ݏ���?��
	S2��2:ٽ�>�u���A����%>7�M�=������A�� /�a$P���V˶���x��*4���o�U��u?�=Ù��h8�ۈ�����1�u�UժY��ZL�g|ʠ�����#7��)����X�g8�S�<��͛tf�
��E%���f0�}�J6���-�b=���)���D��6�M2*FRL�r�?@a���V�RNus�l4�*/�B=�ζO���|����X��s���%>K6�C�C�	���m�{i_�C�ɇX��e��z3���D��l^�e҇W�Ͳ��{6�!�+���1kPK�%_�yu[5i���O�ֳ�����;��P^Ñ
w�i֤��B��iåSe�̪���峙=Ƞ�lA$�Y���&�Y����{�����*��;(��䕜b@'�;�?�b���>Y���e��9�k���fZI8�/������m������M^��s�Ue���9��i�h,,`���7}%���A%��N!D΀�k�S�]Ba�=l҄��bp��~��� �nWa�6���a�/�~L�&�䄲�P��k6�#�E �� �f�)��g�ؓ���Uh�xk6�׊�5y[�����f#o��yk6��kFޚ��-��WD���~-�����E�6k����f1���"�^��n�E�02�(�[�B�h!�.O�*(h�,!��m�z���rԐ�a��b��B*Lו'�[Es�(l�cQ!T��r'l�C�'��ރPaĜ8�|�8��A����SR"��� �������F�������<����>������K��a��@�_�O�� �x�Z���MG�`U�]��r��@����V��3���ۊ:|[߅G9h�DH�I���9w>�ЁaW3�� ��8t ��mh6�e�9Gx������YԔ�Y����bH\��+��u /�&��dӇt9G�7�DYV��s���^��(�T�b�#�t��J����q�����^�(��Yw���:�~��u���b!t/y������$��|\�Rp�AQ�����j~RB�ʃ��KK�6�Bg���M!��z �r�l�q6�AZ�j(�LX�<ga4���զٌ�ܞ510�?�ڨ�pp���A��ŕͳ�j�ʶ�����)�g|�c)[�+�n'E�CuR���2\Z�X��l� ���}�g!�R*�l�� �ɗ�4[*+@c�y�_����7�q�d1��@l�M����,�&yJ���<1=Ԓ[�
�_I�����}�xT\���C��e(��sz�+=S_�3� ��W��l�� �e����Yb2ʰ�MH����b+}/�Р��
%��Ղ�[2��e��&��ȢѠ���+�k��6���'�T�f���L�~\�E�(�,�m���ͪ�d��~�;���'&����C=?�1��I��p$f1Y���*)L��Hu_6����ҡ��H0Vn��C�J2�x4�y��]��0]#�a��Q��m�R؀Y�*�U2 	o0�v�ߌ���s��.�@cF�a3F���[�W�+�&��̞v�P��+Ԉ�	'A���ؕ@�eTvH�#8��>9`v�1�E�,��W�JX��{9D��c�c��Z����9d��2y��V�!��x�;�1/F�Ȓ��D����Β �n+!�0���T��,u�b�Q:L����Ɇ<���?waG�����s;�O#>��18i�nalv�Rpώ�i�/��1��f��zU�a���v�����Y�v�H��[7&�59�&/ҟ��D7��Vx��8���&��o"!�[��ӿ��,�k���&���I:��H�űJ�t�o"!�⚤s�����E���&����M$d]s�\�����c$�[]�s�Ʃ��r�	�����j�u�6ժn{��$[{W��+ʸ���k��F9���i���3oc�d�|�i�� ��>-��)��� �U[�|�+OF0�����,N�,�f��nؿ�nX%W��u�l��� �6^���%;�T�4�r)`�L�V��f�cA��8�w0�oKB"�<�z�M2�����8"�+8�{�˷~��T���7�v��/�ݜN�Ƞ�Ec:�n�j<t[�jlت1�H7�J�U���!�ʶ�-+�1F�Fl��� M�닪k�GR����ME9�!D���_>-`���:~�����A��#�M�	���5�V.Cc���6��j��O/�-W/BZ>�lZ~mҲUHe=Z��X��b<˖ה-��[_#@N�-�+�Y�P�gh�Xa�l��n�:G���-{��n���
z�/��-W(�Y������Sг|AA��[��|����W��|1 ṍ[��|�Q��N���$=o�d<�~{�d����-��&,֛�d�����r��]�N`�:�F�X�N��~׊q-�:��uL��|xq_�d�i�Ӂ#���1x��Y��-aZ��	oV�|p�@��t6���Ñ�æx!h��=ؒ�NwF
�,�y���d:�+���l4ϦT�fB�Zr>�&���6�����1O4�}_oѢND��}Oa�������'�s��5|g��M�ֳ�*�qGԂ���IJ��why{�����ӣ�R���T)Ya��B_��@���j6쎓�M��$��0e�'D@�'��[���@羅��^�A��V'pwϡ�N������w�t�l]�ì�Y��l9��,�弳W��<98cY�p*G����Or+�G8��9��w�
�Xy��a}�jO2��u�� Y��s�`_�4>�q�!�/�:>S	9���TX(���S�Ď�8~3-�G��x�n!�����Z�|,���M�>!H1����}^Z�߼�T�hQG�7��F�|�}�~\�����)�h1G }�6����E�L�Sw�Ibx}(Ѣ���HD9��H��@郞�k��4C�7g(��S7ļ}��"����٭�=\�ܙ��2B���E������M~>@�p��ޟ)�O�њ�Y.��fي�r�3��� m׫uڄ�֊��+!��Dg D����LQ��s��g:+ZG�ݛz���2�:Z��S�i5�z�����/�0��p7ּ�J�����;�U6Mc׉y'�$`/S�[��SC�XvS��[�r���`[1�Y+S ������2���(.?ZZ\��X.?�6��gN��r��Vu�!��$���ݐ����吓�7=О˨n�
�����)a7kt��1��R���)g��V�tO��	�ؘ�,Jw�;�3�x`qX���+�d��ʉ�ϓE98�z*h/���^\q>91��'�Y\��h�[�"-Ϸjo�>A$�?ҡA����'.6J��\K�Qߧ�b�Jh�,b���p���U�����]ɻ����*h���}f�����!�-�!��ó�J���#�f� ��z,C�b��	>٬����V�KX�7��d�����󟛄��u�u�x� ���B=�O�px������ ��XzG�#$�P�H��&h��h���ބ~�?*$�$&G��X�E��������N����3T��y�޼���1={��=����dm
�hF���mW��!�?z6�L�/xm!Vۧ���UR7ٔ9%�7�Sd6�L�+x�.!�R>l�����,7ۧ~�M|F�l��sQ��s1�a��Vzf��T/�ӄ���{��aS1�ji��P��K���� ��u���r,m��d
��$�D:�>�nA����d�`w|�~J�X3�^'A�-�\�_�����9��]�.�����,|	z�ꇱ��O.�`���t����B���.�9e��G\sP�W�cM�y��ƞ��mIX~B@�E6�i\�Vz.   .<*�-�k��Z�-4+��E��^|��n.���Ϭ�B�������ytv
���ɢZ�����؃&K�/D�dp��`5���/a3���O�ڋ�������/mrܸ/z��g/���X�ɐF��vժ����K���[;0`��������I������O�:P_YLf�����T��e���Ff�X��R�q�p3h�t3�p~��`��Y��N�v�,��t�o�����M���*��S�5��;�߽�O��^O��^�M"���{{��=6��<)���a���R=d"�%���CKy@4���.���馒t��Z�^��օf��R��r�-���]}.�ϡ���[�2*,q��{����u��[�����ej(5P��¹�i���s���j@^,�>�{JQbv/�^��:�;U�)=�v����5��'�|���#7���P���AgS]��e�2=t����]0bJŞ��yFD��W��@�ɂ�0�t�_}k���(�3�5&��ߚL5n��O&B�??�������QT�Dd�H���C6�;#rq����Gdu	YŃ6����΁����a:%-9�E�z��D�y�|DW��=�'�>��k5=�1җI�u����=�A���{Ę�nX�S�}E����;_�I�q��4Ú��?���L+�⿥6O�7�����IG��l��>S��*F�����]�,��h �DY,�K�	Z_����V�}d��*7���Ez����L�䪥G�s���?>}��?��      ~      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x�3�4�4�4���44������ ��      �   �   x�u��j�@�ϓ���fv��z�4ŔX$4���.�I#Ĵ����g�s�1�$���߰���
��|���Ug���W'��m���{Z�D� ���9�F�L��)ɒ��I)�̌B��7�O��$�� �[��Q�"�褤���b@  �����ʔ��Eq>V���q�iJ]����;�Ҟ~����m��fa
B"��&yuӱ�?�F�_�����Cg��y�Ty      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �   �   x�]�Mn� F���`43��XIS+ƍ�y�u��C�`�?ip� =>F��H=ƽ�nȄI��稧�gM�u���ｉU<����+g��Ua��WD@��Q!d!`eůmxcj��pM�7U���s�y���x��p�"�P�Uf=`���!dV|Z؃��8�^���9~�^�]ΗN˥�ө��у���
;��TeD"��j��V|:=�i�_ ~V�      �   �   x�mPK�@]�Sp&m��rG! 1.0�=�g�x/!~_?y��i	�ݦ7 D�`��~�d����}��8��D����$��ڂ�F]A
��@�Š�?��<�)t�yjRC)�6�!p����е!�G_A��~����/��q�w(�u��aC3O�<�Ch�O�d�3R���U�oX�Y��Ȳ�	K�AB      �   D   x�3�4�tt9��������q�9������u�ʅp�pq���d��p�y�~�~@�=... ���      �       x�3�<:���3�ˈ3�5��1ҕ+F��� Tk�      �      x�3����2�tr�2�t�s����� 4�      �   `   x�e�]
� ��ۻL�����N���c�o���M �7��}��)̓anY����%�bг��(��y��O�{���R�X��9����z��~Lp0      �   I   x��I
�0���c�xo4�&Q!���C�Z�5�׈�<^Y���s��'��^�0�R�yˋ�v >*��      �   ;  x���1n�0���k�{N��.�0P�JR&���|��{50�}~z��2D�����?��v8����~��w)�w�����Mq�b��`R�S|s����/������|W\
����ݱ��]�����mZ]��КRm��,�V�n�Rm���Z�#n�����6��G�'�����`�)�����b�2�����0V�/I/�p)�*��#����.�8�4=:�X��ք��9�+fiyZV���2����ieX1K��ʸb���V����b��5q���2�XZ�V�[iyZVl��ieX�����qŧ���� 63��      �   7   x�3���p�v2��@<o�#@<c0���5X!�����$hDpc���� K�$      �   +   x�3��s��9�!�U����ٓ�!�~x���k��W� #6�      �   �  x�}��n�0�竧�� A+�i��F�Z���)�c��������cWk�f��z�Đ;��<��^��8~V(��2Ef�|c����8yQ&�+.ƓJ������q�J�g<�KYT��'t�a##���������p����Φ�Ŕl̛ }��		�HH��98A���G�r]�K}�t-u�Fb^�"C��S1�-1s.K��q\�#�.>��K.�#W	���lč�
]���LH�~����\7���5S��)���X�\�C���*�M�q����"���6�@��s/��I���� �����:��g���V�����ǧm��Ul�t���0��ɠ4��g#����r���,�U��Ff�O߈���BUiY���o+[��7Zpq+�\�S�!G��r�C�Wj��~���j�þ ��4��J�͙2�/1aלP/o��ӥ$���z9�'˾�[��>�<\Z��4ܹ���x��u��eY� y&UP      �   F   x�31�<���1���#���q�44�21�t������44�21�t��s��L9�\C����A�=... ��%      �   -   x�34�<���1���#���q�24�t:���.������ ���      �      x�3�t�2�t�2�t2�2�t����� $ �      �   0   x�3��=<�����Ȇ`.#NWW_G?.c��(m�yt��W� �|      �   *   x�3��
q�2�<�!��.�����
�!�cW� �      �   1   x�3�<������#��]��9}|���L8݂��=���=... 7'      �   *   x�3�<<��5��_.#N ����e��txN�?W� ��
�      �      x������ � �      �   3   x�3�tr��9�!�?�3Əˈ���1������5�<�! ��Ď���� >$a      �   F   x�3�tr��9�!�?�r�t�S>�!�1�Ȇ��|\���8=�<� $��1���!!G6�h�1z\\\ �$_      �   %   x�3�tst
:��ۑ3�9]\�9K��=... �x      �   i   x�}��	�0ߗ*�@+f%�\���Km֐"b_��#���ݙh��)"�%m��V�%^"�z�<�J��[q��H,�T[�._��/�����Yi����[zc�	3�      �   :   x�3�qQp
����CGf��F���\������a�>�A�����qqq о�      �      x������ � �      �      x������ � �      �   J  x�œ_n�@Ɵ�S�	����>.Bq�.5>�=N���:��P���Q��������wX�-W��ڭ�4:�����GU��yQB�?�ݦ@��G�p��p$�l�y��b��х3HRHy�J��<�#C6c�j�\��D:g�,��[9�P���E��w�^A���eab|��ʜZٙ�ȥ�a׵�O����'�դ���\Yϙ���s�td�̣�ۮ����������i�5L�/>���|��Eh���\�
����L{����O#�ń�������q��h��d��L��'})Hvo�%A%��2S:�3�g��ظ���~�7�%�      �      x������ � �      �   [   x�3��Ï��9-�8\�\�l��tv��qIy�9�(x��;Fq{�8�6�7�46����j7!l�)e6�Q�݈�UUU\1z\\\ V�R      �   w   x�3��ON��2�<:�4)��˘�7���˄�/�81��ȭ<���ˌ�#�*�(d����[Z�e��xd~iqI~1�%�ke��=9\���ٙ�\���މ�G6YF��E�9G6fs��qqq �;#�      �   P   x�3�tuw�2��u"G.cNGoW�#��L8��"P�)����]�}B��8]������9���s�D����� p�      �   �   x�e�K� Dד�T����t���j�UƑW<ylxb��د�@��>
��IH�t�(S�o(�}�x�
�yA
k�l�EA^���YƷQ�z��?ڳ�����2�fl3���J����l�5!�'Sa�	��f�8��b5ag�	�M�6��N���=r��sU�G:���k۶/*܉�      �      x������ � �      �   �  x����n�0���)�S�C��[5i�ĴS/و�hP�@'��炦�B�$��?;��8\j(l�v���/�^��W�;(L�Z�d[s`��A\Hؾ@�~�ބKq�6�1e30�;o>M7�(�J	�U�˸2�ꪺh$�qE.n�*�qꨐ:�ng��N�8m�"�ׅ�)$B��_"DJ�j����My�0+����TF3e��{��hQBE�����1T:5#�4� �Ӹ,��3�����QD��L�=`,i�6�e��fo��zX�hhEW��IhќL��՚�3�� ��ґ9!���7wp��\�5��7ձ>_	�>2��I�����9=^t>	l����#�� �FoX�������xL1_����PEA�s�է��LmP�T�V��%I���.I      �   S   x�3�H�J,*I-��2�N�9��˘�p{b�����I�\&��@vjnR*�)�sin"����1���24�tK-�H,����� -q      �   h   x����@��L6 q��p�/�%�����5Ѓ�zy%<Ǒ5Kg�X���Nqf��\��<C	�>��$�;��y_����S:���s���_�k      �     x�eQKn�0]�O�T��4��" �D��}z�.9���^��v3���7($�h�z��ָ�@�n�����f6�͎�[ �0�[�be֋?���L���f��TŤ�fbg�2�IJP �v)����	��@��h\����W;�;3.��\���_JI�%���O,�07�ҕθx��PU^�Y�I�C����():o�-?�09��Pj�\�b��"�M��]5S���?~����t�����;o'7��(@>���RL�u���7��{      �   �   x���
�0 ��oϱk�7����++2%�K�� ��=Vу59�G)0��(R<��`�@]af�읟�ռ����)<`���$����i��&�L�u��/��=�~R�d�s�mY�䫄E��s�eZ-�V
��.!���|#�      �   �  x��Z�r;��_��-I|����i_�$J%���@��΋;���l�u:��9#�_{3C  ;�H��8}�������Pf6�x�n������eE���s�'l���\�|!��g�j��$f��o��;����i,�w��ryL^5;�t�#���^z�f�;���!���$�]��T��������g��=c�w2��q��'�c�@_߽�G#v9>>�Y��:����txj[�:�7�x����ؾ�al܅�éumS߷���_Y��j�����w�m}מ7����mM����vz9���e8�?�NǗֵ�a������ᾁw~b]g�����/�®o���缗a.Rv�J��B�'�BM�R*��;)%��-��f}ډX��<,�M��0��Fr�%*�2��mC�f��|��I����t1�C���m�J5G�V ��?�Me� �`>�O�L#0	a����E�D$c�L�N�i44���9����$E�t�-����p.�u1���yt	vvO�_�34b�b�����q�3O���섯6��ë�1-/��5Z�]��-O��T�����n��>ƙH��OK�炍�4q�T+=�9��?�lj���ί�)f9��O��~��&ho�ȿ��ː_���-O�e�W��.;���(��f<�Ac�&7y��C�Ӏ}ny(}��)�D^�)�h�9[*�"q;+�2�C�uZF��_�#Ň/(>.�e������x�*}K�\�2eS(aC4���w�Qr�v\�HG�.n�HL��,���)�3�=���Tޗ�8�f�kg����hs��ġ�d�]�pVB��
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
���[��g���b5�Vo1��z��`J_L��Q����q��ի��q�      �   (   x�3�9��(���T�� .#N׼����W?�=... ��	�         4   x�3�r�u��2�t<2�3��ӛ˘34*��'ԛ˄��Ȇ�#|�b���� �[      �   �   x�U�An� EןSp��;���4����lu��`�����R*=��|1��J�,��*Ǌ����f���_��q9w5t5 ]�=/�]��h��C>�L�k;Bpo�=���s��M�V�iuP�A��ۊoĮG,ɠ�j"�sp'1���8��ZV��@�}����#5���t�S��?��x�m�����'�P�^�s�<1O�            x������ � �         �   x�%�;�0��z�.��x\`�XQǱ�6�4�Ѥ�ؚ�$�#���i����<{1�8�~	,#��s}�OR��T���M]b�ӹ�&ڡ��(�L�Q�<�C��ZaӖ�.����t��3�0�      �   I  x�=�]��0���U�
FM�$�����w�������<!����ל�$O��ı���,��]ӺyM$r�ʐ̔�����y�$D����:�L�Db���n[�	�6�jIX)i���#U*��fj;�\��HU�K�x�1�o3�<mL:Ɛ�x���>wE�%�n�_wW恖	�{_�ҁ	!�}?�"`�"EĞ �騴ԯ��+cH���'=���^���
����xȖ��_<-LJVV��ub����?O*L�IȂz7�?)!n�����#���a���Ya�A�D�������y���C����Gd��J�mv��N� r���|�nE�����G�q�ˈdE��ţ:U9���Y;�).ʀ 7�I�
B��7�A����7/T����ްED%І6-d�����ح$�!���;NkO"�њ���~��" c��ݼ$㓦���ѿ?�+��*q�{z?Z��te 1�8��l�f�#�2��Ё;DQA˙{��։/�0~�N�0���g2�������:08?\��:2B��)�I� �u|o�'@d%���gĔ�]y�ze|���mq�)�P���D�Ti/�L*�F����M�*���ꧥ
Cz��0�
�A0좍�Û$E�FӅ�4��"i9Z��狶U�Xc��{�H'� 6��6��� 
C"��̶q7ޘl\�X��g����m����Q�¸%S$��^�� 6��װ^L�H�����q�����Gytz����q - �e�j�rr�X��|�b�! �B���
۰َ�!��P��5��[I%^�7�9�&�]\��1�7���c�}�β�?���         m  x�mY�r7]_E/�*�K|���6�~�&E�l$E�e��"Jv��Tj����o��Ξ��so�AJIʉp���\pJꔾ�#SE���SS��hH��~��7�#RF�
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
�����͗���d@������f?9�0$��S��W�s.���͛�����      
      x���ˮ�v%�>�����&��@fV'�H۽��K��Yv�ޛ�
�=խ�^և՜���
��b=���̡sb�R($������-u16��\v(K�J��͋�s�����\�ߟae0��`0��`0��`0��`0��`0��`0��`�~P��}������6<��;\�q�ϻ��}׾�S�`0~=��o�L��wgۼv�k��~�9����6Ϸ�mm�(���12���q������c{��g��:|C=ϕ�����<�`0ޏ��*��ۢp������}�0ܖ��FY��Ԉ��֞���os>��{��}�:����@�{n��K1m�o�29:�l<���tu^=:�m�;r�M�����t�����)�`<�Ó�`0_��wE��"ڲe��EZ\R��%�qI.�Zh}:�q��rn��-B�'+.���E������w�~f��g�����78\�2j\�ד��m��	��c�p[mnK]p��Jc�".�so�Hw�|�t���|����ǒ���q{�.t���nF�g0�7�i�3�����Bm�����S��Z�~��i�ȭ��������6S�ٳ-�q��Oz'e\άA �Am��}bv�Η�u�)I��[2h������h�ed�޶┮�F-9\s���n��>��:�m�x��������][���?�)�qAׇ>��A�������<f`0�w�!'F���a�Ac�>*��W?���C�ǨΌ6��G�:��G���p�T���l`4��vtb�ٞ�S�p�mxpڶ�\:N����F����0S��3��نp8����=�LO�ű�>黏�$��`|γxd�Z��f�2{N�,ڒZ3��a�-�qR
#Ò��'�r1?�׌l�g>�q�ކa?㎻n%e�,����mOp�S<8�*i���<6��`�r���7\�;��z�eй��i��2�k@}�k8k4����Ǿ�,�dO����x�fi�h�yË9�������i^����H�H�	���4�50QכOp�Y���?	���鎜�����;�iW��]�����ɹ%�YBZ��x�Gt��I����H㸝ޓ�9��]���}��5�5��!_��J]G�:n��c_���2��}�l��!��A^�x�O{K?���uh�l~�Z�<0�I>�N�+�� 1�`e�tf??�a�k�����`|,FO��g��y��ig~��c�3���F�>i�(�e��������tv3�x^�����\؈�q�s���O4f�슯���.z����gM�}qە?��)����[u�~�F_V��#��Q3���S1�hb0��ᡇ��\4���4�ⲳ��l�q�w�5�#�3��W�ح�4^:ԋ���m�O>�c�T��lk%"����i��Ğt�c%v8+�������<�3g���h�>���c�����QL8���<�yFk�a���`0>
��ў9���髣��0ZDGtV�4'H���f9�֍�~�����_���AR�����G<�{ǈ?◇��;8����8����7��������PT m3F��8ǙұF����g��`0>3��9��lC֑�y�a?�X��-g,0Zh�ɻ2����!"���<B�B:�$�oz=�kH�:E��?*������|�&�����R��O���ƣ4�{h�C<�>:�:�r�|2�h��2�������ﶟ���Y�����~��������`��>=�{Z�~~����k����{�`0ރ�[��}ȬUߡ������x�_��i��k�=[�`�����z���#���>���g��(|�>��c��+~�uXf-��w��}��Z�3�N��������{����s|�.�w��(?֪�k��w��[W^�h���G�����3��gxờ���q�w������fC�ς�%�g??�"4kÏ=��Z�=���Z�>�,^���S^o���J~�x�m�>����2ޏ�6��-������������m����������B��5�l�����l�~��{��+Gݏ��}��m,��h������^���Qmx�h��k�t�)���d!sP坶#��L�Ǡ���ˑ�)��i���r��9'i�6��_��?��_�i�|��v5Pf�Ǖ,ރ��]�175�p��^�a�O����b���2���5#f�=�}��BW��=W���~���+nׁj&�ަU���^��z��ޞ�_��N��.>3=����=�=��S�=U��5�Ǌ3�n�PW���U�q{�]d�|"�d�&���~��,�L��d���{8q�ϟ9�SGx�w��]�7��<����Տh����n�F���qЀ1��xm���i~�9?TI󉖌s��55������Mk����?|�_��]ʜ��`�\�=o�۬_��O�|��P�f@4�<��=����zz�[f�s���-��X�����s_ϲy?>z*�L��t�z�D�9x�#�����}f�q�Ml���֟�w`��Ԉth!i�٭��v<�c��:��4Z{��fO����~ų+3օ��6�ў���W��:O=?Op��W0��F��Pw��ݱ>,��ޞ�����٢��o�c��U�m�\T8��3#�����}\ob��\<����'��.���1�A>_��h��E�0y���ev7��C1}6�3}�g�y�r�3�u�&���n<k�����٨אָy>�� ���/޶˃m_Ϗ����\��ޞk�;8X�oMg��٫�xr�Ǿc�}��4�z�ǖF��g���\[�\����ڽ�D�-�)�Ԇs-�u՜��'c�]8⩹ �G�p��:Gn=���0_��}����<a�.O�̸��M_�K��3F&_����'��Ǚ}����%���������I{��.� 1Ȭ��'絖��Ԁ^9���<��f�&�]��r��u�頷�J�g�*>��gg�Z��c��x���j�w�����1.�+0���:z���v�ٳJ㓀�Ž8ᅙ���b��t���ޙ��3�d�p}9p]�E������yl)b|g���e[z?�U㩧z죨Wy��>��^XV�������y���c�0޵�mf��.7��}����yo�g�fc�W�.ށ�f�fW����g?��˅5������q��<�29���7<s�g-����&>�2k�cN�{��^��^;?��f�xX�Ã���0>��/}f@v���m9�4NGyj?O�"�0�!�$����F�ך�h����˩gS���J͸�z����i�d�����ʙ8b��p�}�z�v��}��gl�'�Nq<��m��(e8�����ml��-�*��ľ/��>��)z��g.F�O<��9�w�`�hU{އᰇ12�>j6�r�>���#n�5�h�׎j>O��'@^����{pa_�ܗ�������f�g�B�2nOH���Zx8�gf[�ʞ��u;��`=��i�(0����߶�w��	f�A��?�����N�G��,{�4����Qʨ���tU�����bf;�Fԟ�����g�b��Y��Θ�:v���,�W0��3-�����ܟx�#??��g�� ��}o��N����E_X�@�,�EO�N�����r��vR�S^>��+����<�H^C���Oc�)�>�|x�Y>Ι=�r>����Lk������3���P���α{{�OH�g$�.�o���yƎq>zo��I:t���=�*.��ƸL#�>j���E1{b߶���'�n3��O��Ge'8kr�6�v����z�F�� ����P�3z�I\���S�V��~���C�6SJo���l$@�~�t�3�۞q�glj�F��O��k�y���L,��[��<^3��>}<�9L���mSe|�������������������Ϸ�`p�8�ws"�B�O�����������0ɯ����^�mv�7��į�ޞGV��'��tv��g��`�4�yD�3�����p,��=av��m~~�>}�����8�O�4f�����|�t����bF��SM�gG-u��?/��,�+C#���k�ƦG    ����7ѻ��^*\��$�L�v΢��3���U2��?h�����x��k>=_��=Ow�qL��&��Q�)a�E��"��������|.�ϋك������FW���c?�'~4߽hN�ݳf�AڙŹ�t��"��� �������/�(�Qf�G�>�۾(��� ��Ā��������:��}�'F5����X�"DF�:��g7�y�G_hx�5k�{xl��i8d�y�UfX��+��c�'���sX��db7�P>��$*���7�6�a���D�u�#�����8�L���JBk�4�Τ�|E�ħy)|Rk����\fW�չ��ל��4�9oI�uf�>�N���������L8_���;����!o�Q}h�f����zb�ƻ���O�����G'z���vm�Zg4�� �xq}j��*����̃�]=�X���f9�.�l���'�9��:z�҈��l}���lɼg�Q3'����<?�p�k��O8����3L�?'�6��@����l�+������v������<x�^����k:�;�u��:����c���ծߗ7YGg���<��_�ɖS|:c�􀓼yď���i��I�g�4g����%���9�şf�l������<���=���I�"���~mL���=Ͼ=�����z𴷷=���_��Sù�y�^ \�`�J/��x�gL�ж3�/��<�AV�����7���������&�E��7��7��:���;8�b|ȏw��lF�Ǚ�f�+.gLG����6K8�ݞ��:g�ç��-��w����'�mO�lv��nC����~�ަgY�����ӯxZ�eE��8k�E��
#Lk26P_=�G�&L-��Z�أ�գ��mV��sR�<{n��p5�
|'N��i-��7�:_�i}��Y���O�úNc������<H��9k�:��䉝氝ո|^��y��O����)L�����4��_���þ�m���c`��Ҭ��P_or�/dy�_�\C���*�c����|:���˴v��F�����1��ã�x�m �0������|v�?�3����s�	�����^�9(�}�ˈ8��uxl��y�v{�l>���~�}���C��O���@��w��1�g;������q��Z�a�,�mI{���E�y�˼_�y����۞?yփ��ٶ��H/��D{��IGg�ڱ�Wf�xŕ|�LO����u�γ*����z�?5�>y2gJx~�|���j�oĠ������Z��~���+1���6Lz��v�>4N���}�:&��<�3��3u^ވ�7b�Ye�ǽz�U>�]3�_�12�����!-������qD4���3��5/Ԉo8T�?�ǧFV�5�h�^]�	�j�]��+~�	?W���䧿�g ��=�5:΢>���?|r���� �����y����E�鸾}wf% �g��e�oG���3&��1�����4��awʉ4���_f�Y���>�>CW���3�A�Ҟm����W��ótx�pV���!S�œ,���>9�1������q����7]=z��(ř��do��k��^R�<��9�f�|�G�ݷM����Q����^��ޑ����=��>�U����}��{Z�ݮ��~�o����g��״�-��}Ԗ��`0��`0��`0��`0��`0��`0��`0��fQ̷��竤"�[o��ʪP��zܶq��s<6��`0ނ��Lf\���9h�ky�5TWm��l�Ik��ĔdZ!��V[]��*��ƣ��:l�q[��`0�x]>�+�w�W9mY[VIM4!�h��ʫ,VeU^�(�(��{���y��)�}_�p�Gʯ޽r�.��`�Q/��j����E��ϸ~�������N.��U�"�ZJx�ZK�xo�6�;;��>	/�w��]��`0FLj?M�Q��2�>��c5�D��辊�v�}B+i;��X�cyQ�u��`i��2*���Zdd0�s��f�\C(�_�wJ,�H[l1	X̉ $�H���n�<�n�a�ĥ�R��L6��&��M�&��
�Tx���Ģ���c�+[D��<���W�}k[[�������J��U�
����'��;k@�>`=҉�k�~���oqo
U.�5�*���1�Ӥ
�ϰ~QRY����J���`0����\Su	H.ɴ�m�)�5����6*����GY�M���n���n����z?*GR����m��ޓ������S�z�B#�ƃ7��`0�_��,�������TYE)�()@e5���L_������>��|A!�����6�˵)��_7�I�ZƑsM6Uǜs�z<���f0�ς��p���9�[�׼�ya�,[�k@]v���������,�Qʬ�JaM�_�
2^=�n��uf�m��E���q���=a�x7^#˴Fz5�
���U^R"��^:��K�Q*��͇��yP�<j��M,������*n�z���`0��{}8��M��2[@0%�A���Ӣ�����k��O���f�ܼY�`�|�k?b�x)�Ȝ�+[�յy|������,�T0|�8U� 2y��3ww>-��n~����#\���ǰ�v\l��6G���q=��KyP���b��P�u��ʪ�@�Jd����8�u�֏y]�q_�E�"��f�8������2��W��l9���9q��&�H����Zo�?��w����k��P#��b�Oߣ!t׆�K���v׃����4�d0�ϊ�,��,fQ�GlQx��(G�_��kY�

3�գ�e�qMK��&3�%�`���dfY�>�u����J�A���k��yFc�Q����p���_I�5��������Ԗ+o����ꫭ�� {�g6����ͪ��T���J[��"�%���.�}��4��2Ư��>�Ⴙ�$��m��g)�����f縗�ږvV��j��m��׌X3�ĉwc(C��t�<3�6{D�!�L����-Q�+	S0�Ö�a_�����[=9/fC���9q]���^���ByƺuQc�A�Y�M�]��jn%$�l�	�d�Nnϫ2�.�n`�Qv.�-́�������j{�<�bL0?�2�1�+ �1� B�yY2Ư�;�K�7ֻ�*����Q�RS�����<��=!W.e-�;�%K�*聣��z�.���Fzҏ�`k%/��O�V���ʾ��q$���G����-�T��`|?LM���EĻ>'���E����+||���Q^�ļ�T�u�l�9�`��=N��vz��������Z�s�t�o�Ua�0�U�qM�m�Xe�Uh�ɥ��22�ϏE}�4י%��GZ-�-�����ϣ�٢x_���[��,$��T�> Y5ǘ���Iu(�<p�<M��� �]��j^�k�u_����a��]�Qf@����p�aF]H�.��	�l�-�^��^�ѝ+M�b�X���Xs�A�a����X[�6y��t�l�݊+&?��{[<��`0~\zr�+:��<0-^9���r�+���)[^��>�ϸ���.!ò��)�h�n�Z��|]Z\�L�J��'G��;��9*��c���� �]�
}}~�x�\���G���Pc�ESD�Y��7U$}1��S��s%	��`\���{�����n������`0� ߚ��7�"^�ְ"d0���A��r����<�Y22c�	x���ͮzU{��}�� ��`0~)�01��|Q�șh�v��2��`0��5~J��R�8�	�����Q�k'��փ����)yp��U-����rĭ-#@~y/����83ҵ��9����H�]Oq��g�N-���ɜy�W^��jF�ƃ=��ɲ�O<gĹ�6��������w�#��S,���}>]-� Φ���� f'�S=�-�0�A�� H\�z�T����Ab�6��R��,��O�Ũ��|��e0��-�TN���r����=�`PNYЃăT�hfK��H�<��jghi�������"�3zY"lL�)T!�Y0    �w�h���rMo�V�j��}5�]��n[gd�PB�X�hϳ�D��,��\yW�K6f�F�^ɷe��Y���j��0��+�f��K4��RT�",6���q���m0Z8���)ɪ2��Z����VQݰ)�l��z���;Z�j O��wVg�sV� ���[AFme�)���$���I�D*������Dׁ�`0~q�*���0��,{i�.*:#EI���-K���L��RU��J;��4=C!�\<Xr)E��]R�z���"��@&k�`nl�U��9�W�`0�������ZSI�z��l=���e��aqYCʽڻ�A�`�\�?����D�K�8����g�F�Q���p_�\�jjcC|5F�Rkg��F���p�|⩀yŴˋ��?�,I�u�!ꪜn����;��fE���{^��ߝ	����[%��**« ����P�j$l�YG��bM��RVYÁ�y��`0��-.���]����ƃG�^����`좓�B-֨��"ح��'��"�3��v*JE��.�5�����P�-��b�PJؽB� 6�������?��Hs'DX���6�]�s��9c�/�^��|��V{�۱�d0�g�~�ٜC�&Ǡ�_M-;4��=�u$��!�4l�k�)9�:�� ��hhU�TR�J*�*�ƛ�RZ���~�֮P�7�P�C�2�c��Xѭ���L��X��WNQ^�n���*I��	J-1ꦑ��R��BD2�D/��)G$��<'@!�Օ�ѫ����B����ʮb��<��6��w�����`0�[}����í���E�K��̸iż�^�y���MM%���Ś�����8���4S;h0^�͓$�EIaRI5��6�=��Q1����*�>)/Yqo%�\�z��W{�(F5Cۜ.4.�/�@�8_��Z�g����1����I�3��p�����U}M���pw��tג4���N����v���ukmf%�`0���J�e�
,�l�^X�[[�� >���5̀�c��p�k�g�*���
=c�������M��"��KK��p_��Ju�S	^r����K�'E�E	t�]���z�w�����gΩ	�O�Yo[�MW�_��Vm�8�(��a6]X���Q;��vmQ	��7��"#KTޖ����Ϭ�<�`0~ߘeCÿ�BT29'@����M좠�2��}/��X#�MO'm��ЫW����Z�,M�A4Q���]p�Z�S�ێ}�s�>ĂK�1{��Z�M:Q7c��>��Q��L����]\A:Э��
6��A�,�����YJ5�]ڙ.5�W����צ=(n���0�X�����q�Q���F�=I6+��?C3S~):����f�ګ!_��?/�/�x��v�tI�5��!�0���.Y����{Zrσ�_�-+��ڼnb;"�9	��*](V�n����ؿv�$���ԫ*�R�l»:�kEށJ쾵�t��}7�i�p{%)h�� 3Z�����zdm����*���������Y>u�{S���	hDI�k��-�統h��H�7C�`ݴ�Yނ
4�{�-N3���{���
A����[s�Yd7��#�C����l3�e"%m��6�QD�R*`���xC�>�T����l�}�\٬ً�;�ޤFG����le0�9v��n���X���c/-LX�BZ���
4�����N�Q-yI%�K��K�t�9�*�X,����,a�F\�=�x8'�\.�����)���&�Tg�s(�$�i�v�6�H�4ҵA���1%��t�K�״��Y����D[jm��2��e�W�8#���QO}�io6ó}k޿��1Ǟz�ao8'�m6�1��HU�o�q���y@��Ua�*�̨6��|+�jqr鳄rPXd�5ȃ>��|;j�������9X0�� ai��,R����ntϟe)�����f�ذ����1�"᧧��G�?ad0_����6c��藛����O=��������kF�$���k�o1�{���`��:�?DɩUU�5^'%�*"����Y�Z����L���f�V ��=��*kD>6�J%���� \�k28����SbS֍�=ʒr�T�D�gK���}�W�s�n�@���Α�`0v�g���r��~��^��ùj�mo�ʹc�;�!�z�]z,��q��!�]��Vac��5��u�9��r:��q��~�VE�0�۳�����ֶ�~m��ĵ��?��?�b@�j�iv�>o����ϭ
FȺ����%��-��5,Z�n	C�����ʧ���`0����7֘����>�� GUH���gC�X�sE����&��5��� %bD�B;mU�tJύF�ӢړO.����C����g	uѹR��A	��Nl��SI)m�K�c�����X�P�l(�ذgfk��-�a�J�F��k��yΐO)���;�Ai�p�-\�~�����l�G6<z�-�3��z�����Tev-Mt�����P14O{	�BQ{��y��"�:�񯩟�Q��%�%5����[u����8�L�fm��9J��p>�v7HG+|�U�6-��,�M��V�h��H�-�^�Vo�u`�lO�8�:�Hg0����":rY��_F�]�߾wπ�`�m��ُom�5+��kW��E� L��PCqߝe�ǣ��
זsK����x�$�3����q�-�[������9z��2����B	ů��v��n#�H�ҳ8��gl����"�q:g���9�RҪ�z7fd0?[�qYT���R��_���������e��Mܾ�pt�5�΀da�##L&8�m��X)�R~�ϤY-���������yҮ���>ƀٶ���;��V\���U[�*�3��_lA�Ů�8(�ܪ4���̬.�~�����A�=�����!}��=�F�W���2���FWE�B�"�:/�+è:�@,8`�ʫ頝�����nZ/�}�o�X�As����dIlk��n��0�
}�S�����Q�)�(��oԤ�^�8��⋤h���-�Qq����Pn7��0~��19�����l6�c����΃LK�b���� �dƸ� �Х���g���0���\̾�R�F�V�ۤ|�x�P�4Tr���[�7f$�ޮ�UT��ӵ�b�V��4��h�g&ٲY��'a[��mp�sYP(I*S̪�!;�pܯG��T��S���3�ET��Ѯ���XDY2ͣ]G�\3��0��X9���r��;p:F��3�f�.�C�}�ِ,�Z��T�G?����e0����On��W�����WS#�K�rY#���C��utT�,�y`��8�Cܙ<���{6K�j�:�w���B�"˞��{��-r�WmTA%Q�:��]t�e#m�۹8;�����q�������s�*+�s+tj{���h�v*������z��6F�ӝuFF*xγ�`0~l��+_��x����U�j��r�'l\��uy0h��F8�B���
���f�j����\���b��%|M�z>*,Q	:ʥ��<H����g��V�H4N4�>�S������~,&�⚖hA��#i�c�f�aՁ�핛�)����5���짟��`|F�R��ǭ�����g#�]��)�Rp�Wt]^��1R�;��>�����EzM|�������"z��-�g[^kk�2��6�٫3�`�V��<�<�u=ď;�{����׬��b���j�Ye��u�0¹YAoJyp%�@\`����2�w��_�=^�T��1.��X=& 	��\�MC��U~���AV�P�Ю�k��Z��a����q��vI���[�ߥ��Wq����YgBYI�%Q�������#=�&}Y?��lXY���t%u���8+*dXp����sf�#�&I�����íg�b���^�b����g��r���b�Q�y�v�Y2V��[h��'o��{��Fu���\_З0rG�Y�6KX{,!�=�*q���Ę\�Ec.6��)��Zیէ���gK    ��*>=�XR�E�
|���R��A�%i�И]�����Lń6K�S�v�gd0?�xo�:g���Ls�Fd�{�ݧ�|D5H
�P:��s�����G������>nŒ�a����-�*8��\���&l���B�Ѯ|�����My·�]�����w�^kh��FY(7N���l�>@�*���o��(�t�E�aДe��mf0���<j��߼�5z�E�Z˺g��l�*���	��(f'��Q	}��k��9���i�����b85�{L��e�U�U�y���i�Ƭ�h�<*Ǟ�sȕ��v��<�|����ʪ"4�W�[�ؐ�d�X��,XѾU���P���q}����y����,y-�PՔ]ڕ�mfP��9�{4yb��E��S4�^��Ϯ��Z�ZC��\ �-Ru�f�Zz�_�jXok�S���#n�2-b��"U�V��<c�c<M���1��g&h�"
���5+����=K��+[rc��Mx8�E�G��+����l0����AQ�So���!w�-j^[!��:P&�C���ߖV>��;����2�餋
{�іI�y�`M�7�"����6l6�̥
�-�>��i�׋��,��k�������=�)�u��R��bnR%~d�Q���=�Y_��y��_�)�{�=y���`|��p�'�5׽#��e��=(�CF�$e4Dh�8@g�uُ�{���l
e�K����!eIub	Ɉ�%,�E���C��B��0ƫ��������K���Y�'Pc�C�B�.MC���u�G>[�hh�R���X%��mh�0�_1U�T��Eqq-v]�l#�8�h}]??z��`0~���s��&�^S5��G#��+�A�X��z`҃�'���T����K�
t���j��BF�42�4Q-iu�V��$�|�B��fA���)�jn�di�;�@�a�j+=ʾ��j��T��Wx{�=S��r�s��\4���.,q�����0����겪T�:�(��0�jrYl�ouZo�d7߉͇��_+i�B�!�E���JVaPֲ����y���l�0�b*8?��ɫ��`�7Ne�/�Q���)Ixa�N�3�U�Y�G�Y4���k_�.�*���^Ujٲ�	4����k˧���=�Y��9�ך$���zY��릭��V�$T��>6�jN�6�����;��-t{اm�y�G����'l�z��l��GYi����#1� ���3{%�h��b�� �4/ Gް
��K���P�"��d�]}�UP����l�Q.����S������#��� դ ����v��5��ѱ��5d_�/�P �T_0y^N��)�VB-piR�O�-k^��"�x=F��\�`0��gκF,��^O���\[�Y�*y��V��%erƬ�Zb�1-t�����x�JDM�*��b�"�?�8.�z�6��]S��I&m���ت85�!�m��Vm����5%��>-�e_��F2�x�#y@��nG������b��~�s����~�m^��c���]���/"�پ6O���fx��J�ȃ���7O�TRM�E�n�8�ꜨFF�G���rA
������f��˚�5N�C ߲���f��ZgP黚S�y>�^�UUW%�3���2K����k4�X��תR��;�6������H�c��]\(j�6x���iò��]ԅb𠔱Y�4�ʪ��}t�/���\~�y�z�{k�EeU�P��U�P-�0YPPpT�#�k\���(�����{>O#ѱҢ��5ک��,��cPk]�u�
S��b���m��k9ּ���YwѼE��\B���`0?5�o�>��L�i�	�C<5��z�  AG��M���')W%��hļt����S���c�۴8λhq�0ʥ�"C�J�B#Բ�>��u�T�"�2պ�<��^e�6u�������Gde�-�|z)W �^:ZgZ+�����`02�2
L����1�%�Xl$�?�y�����A�������S����0y-2��̜/k�M�5�o�=Uj���c�X%��!M5��qB4^�:cWP�VyЀu���b�ۜ��A��؜�?�+k�E���e�� *���,�#�EiD�j�Wrr�*���aj3U�	�=ӭ��e�EO��z��ڶ�Ckg���LL)]���l�c"�g����/ZeD�W�,�����c(F�"WLM����R�%=�hх�d�E=l�,�������A��G?���dD2]�}�����(o`�$W�A��k`�rh�~�d��E�0���g*��a̵�e"��C�D��/�y�ϩ�ڐqz��NKi�����}���R=)<S̱�@=�6��g	�!�@0Q��3�ůnы�R��n�)0���]1���aY?�n<^YUY;�n�n^�h��'�wf��o1�Iz�5\^i���Y1D.� ݣY4��ٽӐY�2��%0Em�
:#��g��@��M|�ʚ�
���@�k��.^iF���Z[�E�mG3��3B�%���|���9�S��.&i�V vܣ��FJ�)�|�>���{�cNX�e��fu�M���G_)��"%a�j��g�������5&���afp̬5�+W��r�\�{�-�Z��'���qB�H�*)Y/^�Z�y�{����yq�p�}��bTݮ�[�����䬱0�p�ϥ����}��k�YuZ,⓮�>�9�(z�T��C^��w���O�U��Ҷ4�/���}��ﲨIZ�2����^��_Tڠ2����S��<$�ԭo�LUx_���̲�K��ߢĨ��b�y�8�G�*P���;@�l�[�I$U���l����x
��K��\a�чω4F"��K��;�#��(W���gq���b��j�1��`�Z{K]b��
���EO�����Z��S�/*���G*�൷�K���?
�%K=蔡��]�U���X����~�hk���#6���loTrA��Øa��F�ed-=�M�kc�`��ڔ������WE�Z��c-������h�͗)u�/��
��b�D��G��Gi,�,-��9��-pe�¿5��A� ߑ��?��!��U�`��[�X0���v��U�M4��T�=��5�1b��V[t^-������Tz	֬څlWid���i��<ě��
�J���6;��ק��x0
4�VGc��'W��[D�՗��1����k+�9�o�e&̃�å����В]�튠�lH�K��C���B�%�R�`�-��u,�ǰ��8ʛ�F�-~��-*I��]n�g{ݽuU��͗���d9���T���^��Ķ,�
ub��;���������)D�9�:Z*'<��[��{��[=�L,d��,�=3@�&o�̢7��;N��lu��_�)��`0>�ٵ��H�i�+v��":V����B��R�zԃWI�u�����c�G��3��!��E��͘˥n3}h��,��Bt;�m�!��2֟�4Q�hlR�E���E�+z�Z�l�}N齆�,|����&.�N��f)G��/���p��~e�
��Kh�Ìj��$Z�ὕa)!c��A�W�k5�J�<?�`0~-���h�COϦ[������J�o�22���B�΃ЬpIt����{U��z���5��B�j��f�/(&�V����C����o�#�r��������|,VcT����]Th�;�]�٢֦C�ʆ��)��e��\9d�>�
�2�YvX���k�Wˮp����2�]�������`0?	��M�]O[�**U��=&�k�����ק�."�b0o���^�G5�,�3�[�����Fɝ�T��qsm�rT�TgA� ��F��������8"6��0�^S=����~/�sM�-�r���A�~�����q���� ÓOn�����E���I����KZ�5�9��f?�����L�32ךJ��,7��q�s,�*3V���<�7�[m�[<���9��1W="��y�Y�k�����3y�3��~�{�-j     )/t�/�,����tq^4ncU���(B���U�(�b�!ŷE6?�mM�Q�zp�T�g��Vg	ᣉ:�/b�)�f����F�"j��[�`�Ш��L�u2�:�����Uu��1��<�d��\�ǌai���3���������/�*��B��r�}���V��F�/�!;�Ԯ�V-|��zō�G�����`�N�:*�yF1֠�*8h'�6�5�Wi���-�@_��������{8�0���$J�G�%
�T0��(;a�z�l�p��'�`0~	#�G�b���
����m��V���G�&k�fQb���_��D��"�d?.���UϷ�9��j:h���mKg�6����
m����t��#�'fl�R���F#�:��%���ʮn�d�,���=Z�v���ZZ������Q_�\>���f���WB�}6}D]��k��gE�[hU�?����� B�T�%�`0~-��;?B�����h���l̚2�S`t��nՠwn�Ǻ%�4Um0z��z����5�}�9`1s�PI	�~]Jt4�y�p��z\��)��Λ�*�`W�ămn��k�I����8Gz[d�9��C��zX��~�àʞ=f��3ս������+��	���1�_�SO�xе�	�m�f�C���[wU(�h�j��6�X�����{�A�A�!��gk>*mή�D���z�*<z���&&k�1�iq�v��l�UWY�Ğ���Ac�ň��Z�j���3�]	�R�v�	.E׿p�hzg��(KO��ڑ�:�`0~�x��1�Z�G�Pw)�q3���n#�*�2z��>W�W���Pbm�η#_����}�Ӛ���J�c5@�|5��b��*��铕Q����׽�;ZG�&L׶�J���R�)�e�6�R��ڬӍ��.�6�w��U�T���֍v ���f��ǒ[�D�ƿ0�����PTt����"��L��ߍ3�7�V�7�MK(��1W�޳��hn����YH)r����F�G�)��)g�>w�|Z���Ƞ�|�/[v�y��TuN�%�uPX��t�h��L^���6+��Y䜋uW]5UaZM)�e�5�ƃ��	�v���D-�,�=��:[`�P4F����h���`0_��%�B7�0S��E��Ua���f�^�'�:�BAS�*c���p��:V|�(�/5ʋ�=^�nux)��^_��'0P�V�=�C��q&�p��e0�B��,��m-k��+6�9�ϰy��� uy��K��ȝ1NP�b�2pv�y��;/������8���b9Z��`�z���!� ���U�f�/v�=E�
a�3��X�����[����L���r��v6���X�x�Ϩք^�NG�����ẓ1 �� q����_�Fj�6��-V�Քt�T�񀘻���7zýw��b�>��[��-Friq�A�%��j��9�1��p^��������~�E�����D>�R�!oI.��xͷ�jq����+t�$�W���;���z�oU����բ�����m<���;��6�o'��L,�,��{"D�yƢɠ�(���Hy/փ��5��Z�8?¢8����|��������ݖ�Mdl�E��D���Z㷌1Z���p4f>��3᪖߽ožFa��tqI�CO�R�Ő}l���"��72�����o�k� +�2���s�FJ}5y�'���*]j���c��<�9��ef�s[����kt�$�u	��Kl�I��#׏#�q��_]C��`t��R�!~o^��S1��6�X���K����@�ۄ�F��Ír�whS��۠��9�滨�t�-�1����Tl-/C���ߟ�R��1��I�/���OY��ٰ���1�y�ٶ�ָJRv�LoL��Lka����Ļ�G���w�T�v���5m�V���k��y����e��k�˫�����kt����*����c�f�=ځKgCgz��WիMuDZ t�싳lr��W��g�MJ:i�L�ll���h�%��5�����n�oY��]<H�S�*:��TEև+��r/�Z��`0���������9�Rr1�v���n�F�礫����61�`0�Vc�1nb���8��/l�V*r3��](6���޲s�쵭��^��%����^זk4߲��݊���e�ⅎ=��Ex�/z��A�):`Ӭ�T۷��5���>:�y�q��c=�,�J����|�z�Aʍ�un���!�+�h�e��h����Y,��&��1^�x.W�=/���\�<�5��kd���5*���PuP�Ɋ6{H
�r���ƝӰ�qbj�G�@on�o���Vy�l�����m�r�5��/�Ȭ�m|T�:DQ�=�5�VN�8��^A���F��kע��5d$U����-���Z�%���3�eQDL���!C��]�w����ms��v�0O�j���R�=���Xe@���h]�O�5�V_�MV�ǻ�A��v���k�n]���fy��w1:+�zm�1�mm�E6�a��a����Ѐ6�o�]!U�UN�PBZ��1.�z��`��@٭�K��*,&��04�*ý��-��8��^�J�l
��&]�R����4���"g�� G�O��+W��'���N��<�:Ƹ4�Z��c���k'm���k)Ws]��*h����pun�-O)m�K'��n|��Z������`��lV����o��o�9c����ԘgR����Ǝ����H�{c�����T�Wvmh���V���BOHPpN$l21��2����0f�T��y�R4=EOX�%��V����NthA�˰Z��V�ZK����o9�eڪ����ك�H�-*��fT�/�X������-���n̕Mk����>�^[8���f+XAn����#�g�-x84��Ǳ	s"���Jl=��~��st��>�~���C��C115�RՕ��i�;��[e�[6�=#Mc��U���*~��*�Cq�c�1���cXpN�1GdVqh��(b��ؼe�ǁ�2M'.>
�[�jfpdC�Ĵ����A6m��K��,��ι��G����P5�5,~!�T�DQ���?���ﹲe�����[��c��OM-���:�%���Z Ö���萅�ܳ0"�b�@'����l��9��`0>�q����_#��ͩ۶���<���L����`K<F�/c}CdC��l�G���ź{`��e�/,��Z�S�j,ފ�����
�0a��-�� Vdpb�U����,ۖ[u�/���rr΀x[t�<ۤ�(��.��-w��:��Rъ
̻c�j>�[b�����mQZ-��o9a�!��8�}\o�ۧ0n��j䧼����v�Ҿm��µ�k¤�[�M4.8��#�`0�G�k�����{�r	�G[���K6��緔I��� 5�
�	k� �P�B��b�]K��LB��#U�_����*�7[k��V�7K/����m����1�j%%����A�]�b�CJ�J����Y�ABj`
h^�=vJ� ����L�ő=\�V�#�<�7�g9��7Y�E��������w���g�b��m�-Ng�W�F�$��<����܏��ޒ��w�sU9.�^�B4w�l��t�_o��������2������X�J"�R���u�@'&�)Ӧ[��H�=��ߔc߾e�ެ���TpVk��<xZ��8�ܙB���Գ�d��Z�����+�5V�f�
[ڞ�tcv�wZ�+V�P =H��!�v�W�L���Q��S6[�B����ى\�h9��z��^?�w�5��T��ZB(9�`�u�hh���ð��T��Z0�w�u<����i����i��3�`�t���jjP�2J�&���myi,F��Y�AI�~�����R��@�$�8�u���=�0�CV���r�<��A��m&ѬQ;lUi��4���>����z�-�}�}��=[mG�����<7�����?޷�����d��Xz���b�/�-
�y�����U��:�@d�f?O�N��W����� �
  ��`0���y�Ǿͬ�=�N���˻��w��r�O�r���"Q'����Y���g�0��l�;
�q%E�g�~F��Ce��>�r�%�y��n���%�YJe�qiq�H��o���l-Ѡg�f�ݬ�X�ǿ�zU�JPWcfצ�z��`���Rs�9�]���뿿��A��۹g���+J��3��. �c�N5��}(.bDg }��O�1>z�M��>_ɋ�^����d�f���U���H���
�GU-��Z��95�2ݣ(��c����@mq�M�-�&�y҄�@w_�2����M�F��Ͱ8#)��`�y���Ƴ� �2���.��C4ƃ�T�X����G�G;m0p%@y��<ʨ�r����¸Ǻ�\;�jm�Iٌw}M��[�s������v!>���],-�հ���;mu���5���r�eii�W��<�#�%zhZTYJ{Yth�)�[c:�L�n��;�b�0����,Tw��8�uGiI�*#B���`o�厓]�V��*�E(_u�s�/H�Y�u����LU��3�<Eo1[6Wk�_�~�~�n��scn�[�!¨7����V]��-����6��$YUfM�`0�'Σ����֌���qY�j��<o�z�@�9�u~gV�Ɖ�WX��	V��;]dB�0��+D-#���<3�&�oYFѸ(��-�7��r�Ro^@=?�t!�V�n�Nx5ft���\�l���uF��'n1&�Gy���":�z��Ζ�<��<����3p�t�36�,	��0���}�]V�A��q�}��?��g/�a�U��`��f��l��~�Y1�QG&��P7Vʻ�%�oy�c�F�#���Zrh7]��T�0��<�!��GvN�1��Mġ��sA?�Ξr��[\�m���x�����O��d ���vWnxP��bݳ8�Eg�̿{����`0~%��k@�� a�:խ�r�Ł�Ҟ�m����:F��Ue�ʱ�,C���n�M��2W�	����	c���ݖi|����}(-�o{��:�`���l);A4c�[�p����U���E0�{�b^��UW�B�E�"k���k�g�9�S����D7^���8�م�Y��7��cF�QQ��G�V-��8���~{?��U��gM�N�%�����Ѱ��k9|0�yM�Ŗ�+�1�w���2~o�wݧ0�Ĵ���yH��@6��w3���8|���1i��A��F��S���G���s��G4��<��9�JW�E�ҋ1U��y:=]%�P�˲�b}���^b��(��*�SE"��63c���ϑ	�x����s���3#����,��U���Ѥ����7�<z��p�W����^(c|Ƕ&ݱ�����.��]��d�q�+կ���:�Yz\߲^��e0Əƹ��1�;�jJ��Ev�ʰ�J`����U�HZ��Q���1#�
���q�3�����C�y�������8(вW�:�?��7��.߭��@�B�ȱ�Z�1c��T�j�2��G���p��zle0��#�{����,�V�򃭔z�����bM^�Z�̑͐�9˒�3]?�1�k�oz�l_-��6������n�Ï��ަ:��)��_4l�m�՗M����cnU�^��ː��k@\qbY���`0���=�K6\[�
��fuT��՚�k��q��>?���}��5�M��ҍ����e������%�xc2�f_sIU㢙R�j)�H<�`�4�=��'�E1�.U�]��V�M+l���6�@R�C�Q*4�z��<��:�Mc0Ə�9'�ϜZ<�m��ݺ�gk���1���=f+A��̲U
�bW|���h}E�se�s�G}�'��Ӻ��.Y��=9E���,��8f; �`̹i�Ҹ�j�&"�c�4�|-��1�w�Y��{t�VA�<�!/�Ȥ�|5��<�� ��=X�S�|nذY;咤��W�o�(����t98���<����l�t�9R�'� �O/�f0�wǙY�j�\�7.����|����6�9�z�+�"WYE�5}���7�oe<����9W�ݚC|e��B��Q�ʐ��%���7���`0�7�f]G?�'�57�Q�⺎�6�4V\�V��{4kw�0Vm�%�EE�]PX��g��Í�H뷎����s~8�������尟�aԪ�����ÖU��f�A��y�ٕ�`0�co���#��Sz���̲�+@�g����c=.�y�Ǚ�a�2��k�׸�u��61��ⱽ�n���}���k�#s-����ꪯ����������3�7�o���� ;-��`0~���o�;;F��>7�{;���[�m߯G��n9� �8�j+��`�<����s涟������Ύ>F6|��,ڕG��J:��d0��`0��`0��`0��`0��`0��`0��`0�9~�������ֿ���O��������m���AH�m�`�o�������?�����hc��or�������������_~�����&'��Mh'���i�r����.��?��X���o�o����ۿ��7�o�����?�&~�?���ǿ��������?�?���K��?�o�������������o�Z���������?�g��/��?�����������������%�����������_���]G 4      �      x�3�q���L�2��%\1z\\\ 4�=      �   :   x�3�472�500����q�R8�����G6��pdޑ�Fz`�i�i����� ��      �   (   x�3�4���t�34��3 .#����L8F��� �'�      �   &   x�3�N�(HT���+I�R�LI�I,:��+F��� ��	�      �      x������ � �      �      x������ � �      �   ?   x�34�����t�34�4�3 N(��М�$�����7AW`Q 2���ӄ=... �~�      �      x�3��472�500�4�35 �=... 9"      �      x������ � �      �      x������ � �            x������ � �      �   ^   x���q�	64��v��Sqt�qU04V�u;���P� 8c��,9�<����}B9��l ��]=�|��C�\#�P���qqq S=�     