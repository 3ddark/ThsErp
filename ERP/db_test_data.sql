PGDMP                          {            ths_erp    14.1    14.1 �              0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false                       0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false                       0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false                       1262    124916    ths_erp    DATABASE     d   CREATE DATABASE ths_erp WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'Turkish_Turkey.1254';
    DROP DATABASE ths_erp;
             	   ths_admin    false                       0    0    SCHEMA public    ACL     {   REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT CREATE ON SCHEMA public TO PUBLIC;
GRANT ALL ON SCHEMA public TO ths_admin;
                   postgres    false    8                        3079    124917    dblink 	   EXTENSION     :   CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;
    DROP EXTENSION dblink;
                   false                       0    0    EXTENSION dblink    COMMENT     _   COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';
                        false    2                        3079    124963    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                   false                       0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                        false    3                        3079    125000 
   pgrowlocks 	   EXTENSION     >   CREATE EXTENSION IF NOT EXISTS pgrowlocks WITH SCHEMA public;
    DROP EXTENSION pgrowlocks;
                   false                       0    0    EXTENSION pgrowlocks    COMMENT     I   COMMENT ON EXTENSION pgrowlocks IS 'show row-level locking information';
                        false    4                        3079    125002    pldbgapi 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pldbgapi WITH SCHEMA public;
    DROP EXTENSION pldbgapi;
                   false                       0    0    EXTENSION pldbgapi    COMMENT     Y   COMMENT ON EXTENSION pldbgapi IS 'server-side support for debugging PL/pgSQL functions';
                        false    5                        3079    125039    postgres_fdw 	   EXTENSION     @   CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;
    DROP EXTENSION postgres_fdw;
                   false                       0    0    EXTENSION postgres_fdw    COMMENT     [   COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';
                        false    6                       0    0    FUNCTION armor(bytea)    ACL     8   GRANT ALL ON FUNCTION public.armor(bytea) TO ths_admin;
          public          postgres    false    491                       0    0 %   FUNCTION armor(bytea, text[], text[])    ACL     H   GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO ths_admin;
          public          postgres    false    492            �           1255    125046    audit()    FUNCTION     _  CREATE FUNCTION public.audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
declare
_username varchar;
_ip varchar;
_database varchar;
_sql text;
_old_val text[];
_test text;
_tarih timestamp without time zone;
BEGIN

	IF (TG_OP = 'INSERT') OR (TG_OP = 'DELETE') OR ((TG_OP = 'UPDATE') AND (ARRAY[OLD] <> ARRAY[NEW])) THEN

		_username 	:= (upper(session_user)); 
		_ip 		:= (inet_client_addr());
		_database	:= (SELECT current_database());
		_tarih		:= (SELECT NOW());

		IF (TG_OP = 'INSERT') THEN
			_old_val	:= (SELECT array[NEW]);
		ELSE
			_old_val	:= (SELECT array[OLD]);
		END IF;

		_test		:= (SELECT array_to_string(_old_val, ', '));

--		raise exception 'Mesaj =%', _test;

		_test := replace(_test, ',,', ', null,');
		_test := replace(_test, ',,', ', null,');
		_test := replace(_test, ',,', ', null,');
		_test := replace(_test, ',,', ', null,');
		_test := replace(_test, ',,', ', null,');
		_test := replace(_test, ',,', ', null,');
		_test := replace(_test, ',,', ', null,');
		_test := replace(_test, '"', '''');
		_test := replace(_test, '(', '''');
		_test := replace(_test, ')', '''');
		_test := replace(_test, ',', ''', ''');
		_test := replace(_test, '''''', '''');
		_test := replace(_test, ''' null''', ' null');

		--raise exception 'Mesaj =%', _test;

		_sql		:= (SELECT format('INSERT INTO %I.%I VALUES (%L, %L, %L, %L, %s)', _database, TG_TABLE_NAME, _username, _ip, _tarih, TG_OP, _test));

		--raise exception 'Mesaj =%', _sql;

		PERFORM dblink(
			'host=localhost user=ths_admin password=THSERP dbname=ths_erp_log port=5432', 
			' ' || _sql || ';'
		);

	END IF;

	RETURN NULL;
/*
	EXECUTE format('INSERT INTO %I.%I VALUES ($1.*)', (SELECT current_database()), TG_TABLE_NAME, _username, _ip)
	USING OLD;
	RETURN OLD;

	RETURN null;
	IF OLD IS NOT DISTINCT FROM NEW THEN
*/

END
$_$;
    DROP FUNCTION public.audit();
       public       	   ths_admin    false                       0    0    FUNCTION audit()    ACL     i   REVOKE ALL ON FUNCTION public.audit() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.audit() FROM ths_admin;
          public       	   ths_admin    false    503            �           1255    125047    audit_old()    FUNCTION     �  CREATE FUNCTION public.audit_old() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
	_username varchar;
	_client_user varchar;
	_ip varchar;
	_table_name varchar;
	_orj_table_name varchar;
	_row_id integer;
	_access_type varchar;
	_time_of_change timestamp without time zone;
	_db_name varchar;
	_db_name_log varchar;
	_old_data text;
	_new_data text;
BEGIN
	_username			:= upper(session_user);
	_ip					:= inet_client_addr()::text;
	_client_user		:= (SELECT coalesce(kullanici_adi, '') FROM sys_kullanici WHERE ip_adres=inet_client_addr()::text LIMIT 1);
	_table_name 		:= TG_TABLE_NAME; 
	_orj_table_name		:= TG_TABLE_NAME;
	_time_of_change 	:= now();
	_db_name			:= current_database();
	_db_name_log		:= _db_name || '_log';
	_old_data			:= '';
	_new_data			:= '';
	_access_type 	:= (TG_OP);

	IF (TG_OP = 'INSERT') THEN
		_row_id			:= (NEW.id);
		_new_data		:= row_to_json(NEW);
	END IF;

	IF (TG_OP = 'UPDATE') THEN
		IF OLD.* = NEW.* THEN
			RETURN NULL;
		END IF;
		
		_row_id 	:= (OLD.id);
		_old_data	:= row_to_json(OLD);
		_new_data		:= row_to_json(NEW);
	END IF;

	IF (TG_OP = 'DELETE') THEN
		_row_id			:= (OLD.id);
		_old_data		:= row_to_json(OLD);
	END IF;

	PERFORM dblink('host=127.0.0.1 port=5432 user=ths_admin password=THS ' || 'dbname=' || _db_name_log,
		'INSERT INTO audit(uname, ip, table_name, access_type, time_of_change, row_id, old_val, new_val) ' ||
		'VALUES(' ||
			(quote_literal(_username)) || ',' ||
			(quote_literal(_ip)) || ',' ||
			(quote_literal(upper(_table_name))) || ',' ||
			(quote_literal(_access_type)) || ',' ||
			(quote_literal(_time_of_change)) || ',' ||
			(quote_literal(_row_id)) || ',' ||
			(quote_literal(_old_data)) || ',' ||
			(quote_literal(_new_data)) || ');');

	RETURN NULL;
END;
$$;
 "   DROP FUNCTION public.audit_old();
       public       	   ths_admin    false                       0    0    FUNCTION audit_old()    ACL     q   REVOKE ALL ON FUNCTION public.audit_old() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.audit_old() FROM ths_admin;
          public       	   ths_admin    false    504                       0    0    FUNCTION crypt(text, text)    ACL     =   GRANT ALL ON FUNCTION public.crypt(text, text) TO ths_admin;
          public          postgres    false    505                       0    0    FUNCTION dearmor(text)    ACL     9   GRANT ALL ON FUNCTION public.dearmor(text) TO ths_admin;
          public          postgres    false    453                       0    0 $   FUNCTION decrypt(bytea, bytea, text)    ACL     G   GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO ths_admin;
          public          postgres    false    506                       0    0 .   FUNCTION decrypt_iv(bytea, bytea, bytea, text)    ACL     Q   GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO ths_admin;
          public          postgres    false    507                       0    0    FUNCTION digest(bytea, text)    ACL     ?   GRANT ALL ON FUNCTION public.digest(bytea, text) TO ths_admin;
          public          postgres    false    508                        0    0    FUNCTION digest(text, text)    ACL     >   GRANT ALL ON FUNCTION public.digest(text, text) TO ths_admin;
          public          postgres    false    426            !           0    0 $   FUNCTION encrypt(bytea, bytea, text)    ACL     G   GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO ths_admin;
          public          postgres    false    509            "           0    0 .   FUNCTION encrypt_iv(bytea, bytea, bytea, text)    ACL     Q   GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO ths_admin;
          public          postgres    false    429            #           0    0 "   FUNCTION gen_random_bytes(integer)    ACL     E   GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO ths_admin;
          public          postgres    false    430            $           0    0    FUNCTION gen_random_uuid()    ACL     =   GRANT ALL ON FUNCTION public.gen_random_uuid() TO ths_admin;
          public          postgres    false    510            %           0    0    FUNCTION gen_salt(text)    ACL     :   GRANT ALL ON FUNCTION public.gen_salt(text) TO ths_admin;
          public          postgres    false    511            &           0    0     FUNCTION gen_salt(text, integer)    ACL     C   GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO ths_admin;
          public          postgres    false    428            '           0    0 !   FUNCTION hmac(bytea, bytea, text)    ACL     D   GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO ths_admin;
          public          postgres    false    512            (           0    0    FUNCTION hmac(text, text, text)    ACL     B   GRANT ALL ON FUNCTION public.hmac(text, text, text) TO ths_admin;
          public          postgres    false    427            �           1255    125049    personel_adsoyad()    FUNCTION     ]  CREATE FUNCTION public.personel_adsoyad() RETURNS trigger
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
       public       	   ths_admin    false            )           0    0    FUNCTION personel_adsoyad()    ACL        REVOKE ALL ON FUNCTION public.personel_adsoyad() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.personel_adsoyad() FROM ths_admin;
          public       	   ths_admin    false    485            *           0    0 >   FUNCTION pgp_armor_headers(text, OUT key text, OUT value text)    ACL     a   GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO ths_admin;
          public          postgres    false    513            +           0    0    FUNCTION pgp_key_id(bytea)    ACL     =   GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO ths_admin;
          public          postgres    false    454            ,           0    0 &   FUNCTION pgp_pub_decrypt(bytea, bytea)    ACL     I   GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO ths_admin;
          public          postgres    false    455            -           0    0 ,   FUNCTION pgp_pub_decrypt(bytea, bytea, text)    ACL     O   GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO ths_admin;
          public          postgres    false    456            .           0    0 2   FUNCTION pgp_pub_decrypt(bytea, bytea, text, text)    ACL     U   GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO ths_admin;
          public          postgres    false    457            /           0    0 ,   FUNCTION pgp_pub_decrypt_bytea(bytea, bytea)    ACL     O   GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO ths_admin;
          public          postgres    false    458            0           0    0 2   FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text)    ACL     U   GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO ths_admin;
          public          postgres    false    459            1           0    0 8   FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text)    ACL     [   GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO ths_admin;
          public          postgres    false    460            2           0    0 %   FUNCTION pgp_pub_encrypt(text, bytea)    ACL     H   GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO ths_admin;
          public          postgres    false    514            3           0    0 +   FUNCTION pgp_pub_encrypt(text, bytea, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO ths_admin;
          public          postgres    false    515            4           0    0 ,   FUNCTION pgp_pub_encrypt_bytea(bytea, bytea)    ACL     O   GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO ths_admin;
          public          postgres    false    445            5           0    0 2   FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text)    ACL     U   GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO ths_admin;
          public          postgres    false    461            6           0    0 %   FUNCTION pgp_sym_decrypt(bytea, text)    ACL     H   GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO ths_admin;
          public          postgres    false    516            7           0    0 +   FUNCTION pgp_sym_decrypt(bytea, text, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO ths_admin;
          public          postgres    false    517            8           0    0 +   FUNCTION pgp_sym_decrypt_bytea(bytea, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO ths_admin;
          public          postgres    false    434            9           0    0 1   FUNCTION pgp_sym_decrypt_bytea(bytea, text, text)    ACL     T   GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO ths_admin;
          public          postgres    false    435            :           0    0 $   FUNCTION pgp_sym_encrypt(text, text)    ACL     G   GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO ths_admin;
          public          postgres    false    436            ;           0    0 *   FUNCTION pgp_sym_encrypt(text, text, text)    ACL     M   GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO ths_admin;
          public          postgres    false    518            <           0    0 +   FUNCTION pgp_sym_encrypt_bytea(bytea, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO ths_admin;
          public          postgres    false    437            =           0    0 1   FUNCTION pgp_sym_encrypt_bytea(bytea, text, text)    ACL     T   GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO ths_admin;
          public          postgres    false    438            >           0    0 �   FUNCTION pgrowlocks(relname text, OUT locked_row tid, OUT locker xid, OUT multi boolean, OUT xids xid[], OUT modes text[], OUT pids integer[])    ACL     �   GRANT ALL ON FUNCTION public.pgrowlocks(relname text, OUT locked_row tid, OUT locker xid, OUT multi boolean, OUT xids xid[], OUT modes text[], OUT pids integer[]) TO ths_admin;
          public          postgres    false    493            ?           0    0    FUNCTION postgres_fdw_handler()    ACL     B   GRANT ALL ON FUNCTION public.postgres_fdw_handler() TO ths_admin;
          public          postgres    false    480            @           0    0 ,   FUNCTION postgres_fdw_validator(text[], oid)    ACL     O   GRANT ALL ON FUNCTION public.postgres_fdw_validator(text[], oid) TO ths_admin;
          public          postgres    false    481            �           1255    125050    spexists_hesap_kodu(text)    FUNCTION     0  CREATE FUNCTION public.spexists_hesap_kodu(phesap_kodu text) RETURNS boolean
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
       public          postgres    false            A           0    0 .   FUNCTION spexists_hesap_kodu(phesap_kodu text)    ACL     �   REVOKE ALL ON FUNCTION public.spexists_hesap_kodu(phesap_kodu text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spexists_hesap_kodu(phesap_kodu text) TO ths_admin;
          public          postgres    false    486            �           1255    125051    spget_crypted_data(text)    FUNCTION     �   CREATE FUNCTION public.spget_crypted_data(pval text) RETURNS text
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
       public          postgres    false            B           0    0 &   FUNCTION spget_crypted_data(pval text)    ACL     I   GRANT ALL ON FUNCTION public.spget_crypted_data(pval text) TO ths_admin;
          public          postgres    false    487            �           1255    125052 /   spget_lang_text(text, text, text, bigint, text)    FUNCTION     �  CREATE FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) RETURNS character varying
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
       public          postgres    false            C           0    0 n   FUNCTION spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text)    ACL     "  REVOKE ALL ON FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) TO ths_admin;
          public          postgres    false    482            �           1255    125053 -   spget_lang_text(text, text, text, text, text)    FUNCTION     �  CREATE FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) RETURNS character varying
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
       public          postgres    false            D           0    0 n   FUNCTION spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text)    ACL     "  REVOKE ALL ON FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) TO ths_admin;
          public          postgres    false    484            �           1255    125054    spget_prs_personel_id_list()    FUNCTION     j  CREATE FUNCTION public.spget_prs_personel_id_list() RETURNS TABLE(id integer, emp_name character varying, emp_surname character varying, emp_full_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
		SELECT  prs_personel.id, prs_personel.ad, prs_personel.soyad, prs_personel.ad_soyad FROM prs_personel
		WHERE is_aktif ORDER BY 4;
END
$$;
 3   DROP FUNCTION public.spget_prs_personel_id_list();
       public          postgres    false            E           0    0 %   FUNCTION spget_prs_personel_id_list()    ACL     �   REVOKE ALL ON FUNCTION public.spget_prs_personel_id_list() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_prs_personel_id_list() TO ths_admin;
          public          postgres    false    483            �           1255    125055 "   spget_rct_hammadde_maliyet(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) RETURNS numeric
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
       public          postgres    false            F           0    0 :   FUNCTION spget_rct_hammadde_maliyet(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    488                       1255    125056 !   spget_rct_iscilik_maliyet(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) RETURNS numeric
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
       public          postgres    false            G           0    0 9   FUNCTION spget_rct_iscilik_maliyet(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    519                       1255    125057    spget_rct_toplam(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_toplam(prct_recete_id bigint) RETURNS numeric
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
       public          postgres    false            H           0    0 0   FUNCTION spget_rct_toplam(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_toplam(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_toplam(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    520            	           1255    125058 "   spget_rct_yan_urun_maliyet(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) RETURNS numeric
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
       public          postgres    false            I           0    0 :   FUNCTION spget_rct_yan_urun_maliyet(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    521            �           1255    125059 &   spget_sys_kalite_form_no(text, bigint)    FUNCTION     I  CREATE FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) RETURNS character varying
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
       public          postgres    false            J           0    0 H   FUNCTION spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) TO ths_admin;
          public          postgres    false    495            �           1255    125060    spget_sys_lang_id(text)    FUNCTION     �   CREATE FUNCTION public.spget_sys_lang_id(planguage text) RETURNS integer
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
       public          postgres    false            K           0    0 *   FUNCTION spget_sys_lang_id(planguage text)    ACL     �   REVOKE ALL ON FUNCTION public.spget_sys_lang_id(planguage text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_sys_lang_id(planguage text) TO ths_admin;
          public          postgres    false    496            
           1255    125061 '   spget_sys_quality_form_type_id(integer)    FUNCTION     �  CREATE FUNCTION public.spget_sys_quality_form_type_id(ptype integer) RETURNS integer
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
       public          postgres    false            L           0    0 6   FUNCTION spget_sys_quality_form_type_id(ptype integer)    ACL     Y   GRANT ALL ON FUNCTION public.spget_sys_quality_form_type_id(ptype integer) TO ths_admin;
          public          postgres    false    522            �           1255    125062    spget_sys_user_id_list()    FUNCTION       CREATE FUNCTION public.spget_sys_user_id_list() RETURNS TABLE(id bigint, user_name character varying)
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
       public       	   ths_admin    false            M           0    0 !   FUNCTION spget_sys_user_id_list()    ACL     D   REVOKE ALL ON FUNCTION public.spget_sys_user_id_list() FROM PUBLIC;
          public       	   ths_admin    false    494                       1255    125063 1   spget_year_week(date, character varying, boolean)    FUNCTION     �  CREATE FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean DEFAULT true) RETURNS character varying
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
       public          postgres    false            N           0    0 Y   FUNCTION spget_year_week(pdate date, pseparate character varying, pis_year_first boolean)    ACL     �   REVOKE ALL ON FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean) TO ths_admin;
          public          postgres    false    523            �           1255    125064    splogin(text, text, text, text)    FUNCTION     �  CREATE FUNCTION public.splogin(puser_name text, puser_pass text, papp_version text, pmac_address text) RETURNS integer
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
       public       	   ths_admin    false            �           1255    125065 (   spset_user_password(text, text, integer)    FUNCTION       CREATE FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) RETURNS boolean
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
       public          postgres    false            O           0    0 H   FUNCTION spset_user_password(oldpass text, newpass text, userid integer)    ACL     �   REVOKE ALL ON FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) TO ths_admin;
          public          postgres    false    497            �           1255    125066    spvarsayilan_para_birimi()    FUNCTION     �   CREATE FUNCTION public.spvarsayilan_para_birimi() RETURNS character varying
    LANGUAGE sql
    AS $$
	SELECT para_birimi FROM sys_para_birimi WHERE is_varsayilan LIMIT 1;
$$;
 1   DROP FUNCTION public.spvarsayilan_para_birimi();
       public          postgres    false            P           0    0 #   FUNCTION spvarsayilan_para_birimi()    ACL     �   REVOKE ALL ON FUNCTION public.spvarsayilan_para_birimi() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spvarsayilan_para_birimi() TO ths_admin;
          public          postgres    false    499            �           1255    125067    spvarsayilan_urun_tipi_id()    FUNCTION     �   CREATE FUNCTION public.spvarsayilan_urun_tipi_id() RETURNS integer
    LANGUAGE sql
    AS $$
	SELECT id FROM set_stk_urun_tipi WHERE urun_tipi='HAMMADDE';
$$;
 2   DROP FUNCTION public.spvarsayilan_urun_tipi_id();
       public          postgres    false            Q           0    0 $   FUNCTION spvarsayilan_urun_tipi_id()    ACL     �   REVOKE ALL ON FUNCTION public.spvarsayilan_urun_tipi_id() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spvarsayilan_urun_tipi_id() TO ths_admin;
          public          postgres    false    498            �           1255    125068    table_listen(text)    FUNCTION     �   CREATE FUNCTION public.table_listen(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT listen table_name;
  RETURN;
END;
$$;
 4   DROP FUNCTION public.table_listen(table_name text);
       public          postgres    false            R           0    0 &   FUNCTION table_listen(table_name text)    ACL     �   REVOKE ALL ON FUNCTION public.table_listen(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_listen(table_name text) TO ths_admin;
          public          postgres    false    501            �           1255    125069    table_notify()    FUNCTION     �  CREATE FUNCTION public.table_notify() RETURNS trigger
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
       public       	   ths_admin    false            S           0    0    FUNCTION table_notify()    ACL     w   REVOKE ALL ON FUNCTION public.table_notify() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.table_notify() FROM ths_admin;
          public       	   ths_admin    false    489            �           1255    125070    table_notify(text)    FUNCTION     �   CREATE FUNCTION public.table_notify(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT notify table_name;
  RETURN;
END;
$$;
 4   DROP FUNCTION public.table_notify(table_name text);
       public          postgres    false            T           0    0 &   FUNCTION table_notify(table_name text)    ACL     �   REVOKE ALL ON FUNCTION public.table_notify(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_notify(table_name text) TO ths_admin;
          public          postgres    false    502            �           1255    125071    table_unlisten(text)    FUNCTION     �   CREATE FUNCTION public.table_unlisten(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT unlisten table_name;
  RETURN;
END;
$$;
 6   DROP FUNCTION public.table_unlisten(table_name text);
       public          postgres    false            U           0    0 (   FUNCTION table_unlisten(table_name text)    ACL     �   REVOKE ALL ON FUNCTION public.table_unlisten(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_unlisten(table_name text) TO ths_admin;
          public          postgres    false    500            �            1259    125072    a_invoices_id_seq    SEQUENCE     z   CREATE SEQUENCE public.a_invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.a_invoices_id_seq;
       public          postgres    false            �            1259    125073    audits    TABLE     �  CREATE TABLE public.audits (
    id bigint NOT NULL,
    user_name character varying(16) NOT NULL,
    ip_address character varying(32) NOT NULL,
    table_name character varying(36) NOT NULL,
    access_type character varying(1) NOT NULL,
    time_of_change timestamp without time zone NOT NULL,
    row_id bigint NOT NULL,
    client_username character varying(16),
    old_val text,
    new_val text
);
    DROP TABLE public.audits;
       public         heap 	   ths_admin    false            �            1259    125078    audit_id_seq    SEQUENCE     �   ALTER TABLE public.audits ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    221            �            1259    125079    ch_bankalar    TABLE     �   CREATE TABLE public.ch_bankalar (
    id bigint NOT NULL,
    banka_adi character varying(64) NOT NULL,
    swift_kodu character varying(16)
);
    DROP TABLE public.ch_bankalar;
       public         heap 	   ths_admin    false            �            1259    125082    ch_banka_id_seq    SEQUENCE     �   ALTER TABLE public.ch_bankalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_banka_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    223            �            1259    125083    ch_banka_subeleri    TABLE     �   CREATE TABLE public.ch_banka_subeleri (
    id bigint NOT NULL,
    banka_id bigint NOT NULL,
    sube_kodu integer NOT NULL,
    sube_adi character varying(64) NOT NULL,
    sehir_id bigint NOT NULL
);
 %   DROP TABLE public.ch_banka_subeleri;
       public         heap 	   ths_admin    false            �            1259    125086    ch_banka_subesi_id_seq    SEQUENCE     �   ALTER TABLE public.ch_banka_subeleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_banka_subesi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    225            �            1259    125087    ch_bolgeler    TABLE     f   CREATE TABLE public.ch_bolgeler (
    id bigint NOT NULL,
    bolge character varying(32) NOT NULL
);
    DROP TABLE public.ch_bolgeler;
       public         heap 	   ths_admin    false            �            1259    125090    ch_bolge_id_seq    SEQUENCE     �   ALTER TABLE public.ch_bolgeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_bolge_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    227            �            1259    125091    ch_doviz_kurlari    TABLE     �   CREATE TABLE public.ch_doviz_kurlari (
    id bigint NOT NULL,
    kur_tarihi date NOT NULL,
    kur numeric(10,4) NOT NULL,
    para character varying(3)
);
 $   DROP TABLE public.ch_doviz_kurlari;
       public         heap 	   ths_admin    false            �            1259    125094 
   ch_gruplar    TABLE     d   CREATE TABLE public.ch_gruplar (
    id bigint NOT NULL,
    grup character varying(16) NOT NULL
);
    DROP TABLE public.ch_gruplar;
       public         heap 	   ths_admin    false            �            1259    125097    ch_hesaplar    TABLE     �  CREATE TABLE public.ch_hesaplar (
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
       public         heap 	   ths_admin    false            �            1259    125105    ch_hesap_karti_id_seq    SEQUENCE     �   ALTER TABLE public.ch_hesaplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_hesap_karti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    231            �            1259    125106    ch_hesap_planlari    TABLE     �   CREATE TABLE public.ch_hesap_planlari (
    id bigint NOT NULL,
    plan_kodu character varying(16) NOT NULL,
    plan_adi character varying(128) NOT NULL,
    seviye smallint NOT NULL
);
 %   DROP TABLE public.ch_hesap_planlari;
       public         heap 	   ths_admin    false            �            1259    125109    mhs_doviz_kuru_id_seq    SEQUENCE     �   ALTER TABLE public.ch_doviz_kurlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_doviz_kuru_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    229            �            1259    125110    mhs_fis_detaylari    TABLE     a   CREATE TABLE public.mhs_fis_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL
);
 %   DROP TABLE public.mhs_fis_detaylari;
       public         heap 	   ths_admin    false            �            1259    125113    mhs_fis_detaylari_id_seq    SEQUENCE     �   ALTER TABLE public.mhs_fis_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_fis_detaylari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    235            �            1259    125114 
   mhs_fisler    TABLE     u   CREATE TABLE public.mhs_fisler (
    id bigint NOT NULL,
    yevmiye_no integer NOT NULL,
    yevmiye_tarihi date
);
    DROP TABLE public.mhs_fisler;
       public         heap 	   ths_admin    false            �            1259    125117    mhs_fisler_id_seq    SEQUENCE     �   ALTER TABLE public.mhs_fisler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_fisler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    237            �            1259    125118    mhs_transfer_kodlari    TABLE     �   CREATE TABLE public.mhs_transfer_kodlari (
    id bigint NOT NULL,
    transfer_kodu character varying(32) NOT NULL,
    aciklama character varying(128) NOT NULL,
    hesap_kodu character varying(16) NOT NULL
);
 (   DROP TABLE public.mhs_transfer_kodlari;
       public         heap 	   ths_admin    false            �            1259    125121    mhs_transfer_kodlari_id_seq    SEQUENCE     �   ALTER TABLE public.mhs_transfer_kodlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_transfer_kodlari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    239            �            1259    125122    prs_lisan_bilgileri    TABLE     �   CREATE TABLE public.prs_lisan_bilgileri (
    id bigint NOT NULL,
    lisan_id bigint,
    okuma_id bigint,
    yazma_id bigint,
    konusma_id bigint,
    personel_id bigint
);
 '   DROP TABLE public.prs_lisan_bilgileri;
       public         heap 	   ths_admin    false            �            1259    125125    prs_lisan_bilgisi_id_seq    SEQUENCE     �   ALTER TABLE public.prs_lisan_bilgileri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_lisan_bilgisi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    241            �            1259    125126    prs_personel_ehliyetleri    TABLE     x   CREATE TABLE public.prs_personel_ehliyetleri (
    id bigint NOT NULL,
    ehliyet_id bigint,
    personel_id bigint
);
 ,   DROP TABLE public.prs_personel_ehliyetleri;
       public         heap 	   ths_admin    false            �            1259    125129    prs_personel_ehliyetleri_id_seq    SEQUENCE     �   ALTER TABLE public.prs_personel_ehliyetleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_personel_ehliyetleri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    243            �            1259    125130    prs_personeller    TABLE     �  CREATE TABLE public.prs_personeller (
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
    adres_id bigint
);
 #   DROP TABLE public.prs_personeller;
       public         heap 	   ths_admin    false            V           0    0    COLUMN prs_personeller.cinsiyet    COMMENT     F   COMMENT ON COLUMN public.prs_personeller.cinsiyet IS '1 Man
2 Woman';
          public       	   ths_admin    false    245            W           0    0 &   COLUMN prs_personeller.askerlik_durumu    COMMENT     e   COMMENT ON COLUMN public.prs_personeller.askerlik_durumu IS '1 Yapti, 2 Yapmadi, 3 Tecilli, 4 Muaf';
          public       	   ths_admin    false    245            X           0    0 #   COLUMN prs_personeller.medeni_durum    COMMENT     L   COMMENT ON COLUMN public.prs_personeller.medeni_durum IS '1 Evli, 2 Bekar';
          public       	   ths_admin    false    245            �            1259    125139    prs_personel_id_seq    SEQUENCE     �   ALTER TABLE public.prs_personeller ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_personel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    245            �            1259    125140    urt_iscilikler    TABLE     �   CREATE TABLE public.urt_iscilikler (
    id bigint NOT NULL,
    gider_kodu character varying(16) NOT NULL,
    gider_adi character varying(128),
    fiyat numeric(18,6) NOT NULL,
    birim_id bigint NOT NULL,
    gider_tipi smallint NOT NULL
);
 "   DROP TABLE public.urt_iscilikler;
       public         heap 	   ths_admin    false            �            1259    125143    rct_iscilik_gideri_id_seq    SEQUENCE     �   ALTER TABLE public.urt_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_iscilik_gideri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    247            �            1259    125144    urt_paket_hammadde_detaylari    TABLE     �   CREATE TABLE public.urt_paket_hammadde_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    recete_id bigint,
    stok_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 0   DROP TABLE public.urt_paket_hammadde_detaylari;
       public         heap 	   ths_admin    false            �            1259    125147    rct_paket_hammadde_detay_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_hammadde_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_hammadde_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    249            �            1259    125148    urt_paket_hammaddeler    TABLE     u   CREATE TABLE public.urt_paket_hammaddeler (
    id bigint NOT NULL,
    paket_adi character varying(128) NOT NULL
);
 )   DROP TABLE public.urt_paket_hammaddeler;
       public         heap 	   ths_admin    false            �            1259    125151    rct_paket_hammadde_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    251            �            1259    125152    urt_paket_iscilik_detaylari    TABLE     �   CREATE TABLE public.urt_paket_iscilik_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    iscilik_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 /   DROP TABLE public.urt_paket_iscilik_detaylari;
       public         heap 	   ths_admin    false            �            1259    125155    rct_paket_iscilik_detay_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_iscilik_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_iscilik_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    253            �            1259    125156    urt_paket_iscilikler    TABLE     t   CREATE TABLE public.urt_paket_iscilikler (
    id bigint NOT NULL,
    paket_adi character varying(128) NOT NULL
);
 (   DROP TABLE public.urt_paket_iscilikler;
       public         heap 	   ths_admin    false                        1259    125159    rct_paket_iscilik_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    255                       1259    125160    urt_recete_hammaddeler    TABLE     �   CREATE TABLE public.urt_recete_hammaddeler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    recete_id bigint,
    stok_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL,
    fire_orani numeric(18,6) DEFAULT 0 NOT NULL
);
 *   DROP TABLE public.urt_recete_hammaddeler;
       public         heap 	   ths_admin    false                       1259    125164    rct_recete_hammadde_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    257                       1259    125165    urt_receteler    TABLE     �   CREATE TABLE public.urt_receteler (
    id bigint NOT NULL,
    urun_kodu character varying(32) NOT NULL,
    urun_adi character varying(128) NOT NULL,
    ornek_miktari numeric(18,6) DEFAULT 1,
    aciklama character varying(128)
);
 !   DROP TABLE public.urt_receteler;
       public         heap 	   ths_admin    false                       1259    125169    rct_recete_id_seq    SEQUENCE     �   ALTER TABLE public.urt_receteler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    259                       1259    125170    urt_recete_iscilikler    TABLE     �   CREATE TABLE public.urt_recete_iscilikler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    iscilik_kodu character varying(16) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 )   DROP TABLE public.urt_recete_iscilikler;
       public         heap 	   ths_admin    false                       1259    125173    rct_recete_iscilik_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    261                       1259    125174    urt_recete_paket_hammaddeler    TABLE     �   CREATE TABLE public.urt_recete_paket_hammaddeler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    paket_id bigint NOT NULL,
    miktar numeric(18,6)
);
 0   DROP TABLE public.urt_recete_paket_hammaddeler;
       public         heap 	   ths_admin    false                       1259    125177     rct_recete_paket_hammadde_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_paket_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_paket_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    263            	           1259    125178    urt_recete_paket_iscilikler    TABLE     �   CREATE TABLE public.urt_recete_paket_iscilikler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    paket_id bigint NOT NULL,
    miktar numeric(18,6)
);
 /   DROP TABLE public.urt_recete_paket_iscilikler;
       public         heap 	   ths_admin    false            
           1259    125181    rct_recete_paket_iscilik_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_paket_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_paket_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    265                       1259    125182    sat_fatura_detaylari    TABLE     �   CREATE TABLE public.sat_fatura_detaylari (
    id bigint NOT NULL,
    header_id bigint,
    teklif_detay_id bigint,
    siparis_detay_id bigint,
    irsaliye_detay_id bigint
);
 (   DROP TABLE public.sat_fatura_detaylari;
       public         heap 	   ths_admin    false                       1259    125185    sat_fatura_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_fatura_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_fatura_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    267                       1259    125186    sat_faturalar    TABLE     �   CREATE TABLE public.sat_faturalar (
    id bigint NOT NULL,
    fatura_no character varying(16),
    fatura_tarihi timestamp without time zone,
    teklif_id bigint,
    siparis_id bigint,
    irsaliye_id bigint
);
 !   DROP TABLE public.sat_faturalar;
       public         heap 	   ths_admin    false                       1259    125189    sat_fatura_id_seq    SEQUENCE     �   ALTER TABLE public.sat_faturalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_fatura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    269                       1259    125190    sat_irsaliye_detaylari    TABLE     �   CREATE TABLE public.sat_irsaliye_detaylari (
    id bigint NOT NULL,
    header_id bigint,
    teklif_detay_id bigint,
    siparis_detay_id bigint,
    fatura_detay_id bigint
);
 *   DROP TABLE public.sat_irsaliye_detaylari;
       public         heap 	   ths_admin    false                       1259    125193    sat_irsaliye_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_irsaliye_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_irsaliye_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    271                       1259    125194    sat_irsaliyeler    TABLE     �   CREATE TABLE public.sat_irsaliyeler (
    id bigint NOT NULL,
    irsaliye_no character varying(16),
    irsaliye_tarihi timestamp without time zone,
    teklif_id bigint,
    siparis_id bigint,
    fatura_id bigint
);
 #   DROP TABLE public.sat_irsaliyeler;
       public         heap 	   ths_admin    false                       1259    125197    sat_irsaliye_id_seq    SEQUENCE     �   ALTER TABLE public.sat_irsaliyeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_irsaliye_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    273                       1259    125198    sat_siparis_detaylari    TABLE     �  CREATE TABLE public.sat_siparis_detaylari (
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
       public         heap 	   ths_admin    false                       1259    125221    sat_siparis_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_siparis_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_siparis_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    275                       1259    125222    sat_siparisler    TABLE     �  CREATE TABLE public.sat_siparisler (
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
       public         heap 	   ths_admin    false                       1259    125243    sat_siparis_id_seq    SEQUENCE     �   ALTER TABLE public.sat_siparisler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_siparis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    277                       1259    125244    set_sls_order_status    TABLE     �   CREATE TABLE public.set_sls_order_status (
    id bigint NOT NULL,
    siparis_durum character varying(32) NOT NULL,
    aciklama character varying(64)
);
 (   DROP TABLE public.set_sls_order_status;
       public         heap 	   ths_admin    false                       1259    125247    stk_gruplar    TABLE       CREATE TABLE public.stk_gruplar (
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
       public         heap 	   ths_admin    false                       1259    125250    stk_kartlar    TABLE     �  CREATE TABLE public.stk_kartlar (
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
       public         heap 	   ths_admin    false    498    499    499    499                       1259    125271    sys_sehirler    TABLE     �   CREATE TABLE public.sys_sehirler (
    id bigint NOT NULL,
    sehir character varying(32) NOT NULL,
    plaka_kodu integer,
    ulke_id bigint,
    bolge_id bigint
);
     DROP TABLE public.sys_sehirler;
       public         heap 	   ths_admin    false                       1259    125274    sat_siparis_rapor    VIEW     )  CREATE VIEW public.sat_siparis_rapor AS
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
       public       	   ths_admin    false    275    277    277    277    277    279    279    280    280    281    281    282    282    275    275    275    275    275    275    277    277    277    277    277    277                       1259    125279    sat_teklif_detaylari    TABLE     �  CREATE TABLE public.sat_teklif_detaylari (
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
       public         heap 	   ths_admin    false                       1259    125295    sat_teklif_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sat_teklif_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_teklif_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    284                       1259    125296    sat_teklifler    TABLE     y  CREATE TABLE public.sat_teklifler (
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
       public         heap 	   ths_admin    false                       1259    125317    sat_teklif_id_seq    SEQUENCE     �   ALTER TABLE public.sat_teklifler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_teklif_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    286                        1259    125318    set_ch_firma_tipleri    TABLE     �   CREATE TABLE public.set_ch_firma_tipleri (
    id bigint NOT NULL,
    firma_turu_id bigint NOT NULL,
    firma_tipi character varying(48) NOT NULL
);
 (   DROP TABLE public.set_ch_firma_tipleri;
       public         heap 	   ths_admin    false            !           1259    125321    set_ch_firma_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_firma_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_firma_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    288            "           1259    125322    set_ch_firma_turleri    TABLE     t   CREATE TABLE public.set_ch_firma_turleri (
    id bigint NOT NULL,
    firma_turu character varying(32) NOT NULL
);
 (   DROP TABLE public.set_ch_firma_turleri;
       public         heap 	   ths_admin    false            #           1259    125325    set_ch_firma_turu_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_firma_turleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_firma_turu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    290            $           1259    125326    set_ch_grup_id_seq    SEQUENCE     �   ALTER TABLE public.ch_gruplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_grup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    230            %           1259    125327    set_ch_hesap_plani_id_seq    SEQUENCE     �   ALTER TABLE public.ch_hesap_planlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_hesap_plani_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    233            &           1259    125328    set_ch_hesap_tipleri    TABLE     t   CREATE TABLE public.set_ch_hesap_tipleri (
    id bigint NOT NULL,
    hesap_tipi character varying(16) NOT NULL
);
 (   DROP TABLE public.set_ch_hesap_tipleri;
       public         heap 	   ths_admin    false            '           1259    125331    set_ch_hesap_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_hesap_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_hesap_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    294            (           1259    125332    set_ch_vergi_oranlari    TABLE       CREATE TABLE public.set_ch_vergi_oranlari (
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
       public         heap 	   ths_admin    false            )           1259    125335    set_ch_vergi_orani_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_vergi_oranlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_vergi_orani_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    296            *           1259    125336    set_einv_fatura_tipleri    TABLE     x   CREATE TABLE public.set_einv_fatura_tipleri (
    id bigint NOT NULL,
    fatura_tipi character varying(32) NOT NULL
);
 +   DROP TABLE public.set_einv_fatura_tipleri;
       public         heap 	   ths_admin    false            +           1259    125339    set_einv_fatura_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_fatura_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_fatura_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    298            ,           1259    125340    set_einv_odeme_sekilleri    TABLE     �   CREATE TABLE public.set_einv_odeme_sekilleri (
    id bigint NOT NULL,
    odeme_sekli character varying(96),
    kod character varying(16),
    aciklama character varying(512),
    is_efatura boolean DEFAULT false
);
 ,   DROP TABLE public.set_einv_odeme_sekilleri;
       public         heap 	   ths_admin    false            -           1259    125346    set_einv_odeme_sekli_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_odeme_sekilleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_odeme_sekli_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    300            .           1259    125347    set_einv_paket_tipleri    TABLE     �   CREATE TABLE public.set_einv_paket_tipleri (
    id bigint NOT NULL,
    kod character varying(2),
    paket_tipi character varying(128),
    aciklama character varying(512)
);
 *   DROP TABLE public.set_einv_paket_tipleri;
       public         heap 	   ths_admin    false            /           1259    125352    set_einv_paket_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_paket_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_paket_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    302            0           1259    125353    set_einv_tasima_ucretleri    TABLE     s   CREATE TABLE public.set_einv_tasima_ucretleri (
    id bigint NOT NULL,
    tasima_ucreti character varying(16)
);
 -   DROP TABLE public.set_einv_tasima_ucretleri;
       public         heap 	   ths_admin    false            1           1259    125356    set_einv_tasima_ucreti_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_tasima_ucretleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_tasima_ucreti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    304            2           1259    125357    set_einv_teslim_sekilleri    TABLE     �   CREATE TABLE public.set_einv_teslim_sekilleri (
    id bigint NOT NULL,
    teslim_sekli character varying(16) NOT NULL,
    aciklama character varying(96) NOT NULL,
    is_efatura boolean DEFAULT false
);
 -   DROP TABLE public.set_einv_teslim_sekilleri;
       public         heap 	   ths_admin    false            3           1259    125361    set_einv_teslim_sekli_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_teslim_sekilleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_teslim_sekli_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    306            4           1259    125362    set_prs_birimler    TABLE     �   CREATE TABLE public.set_prs_birimler (
    id bigint NOT NULL,
    birim character varying(32) NOT NULL,
    bolum_id bigint
);
 $   DROP TABLE public.set_prs_birimler;
       public         heap 	   ths_admin    false            5           1259    125365    set_prs_birim_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_birimler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_birim_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    308            6           1259    125366    set_prs_bolumler    TABLE     k   CREATE TABLE public.set_prs_bolumler (
    id bigint NOT NULL,
    bolum character varying(32) NOT NULL
);
 $   DROP TABLE public.set_prs_bolumler;
       public         heap 	   ths_admin    false            7           1259    125369    set_prs_bolum_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_bolumler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_bolum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    310            8           1259    125370    set_prs_ehliyetler    TABLE     o   CREATE TABLE public.set_prs_ehliyetler (
    id bigint NOT NULL,
    ehliyet character varying(32) NOT NULL
);
 &   DROP TABLE public.set_prs_ehliyetler;
       public         heap 	   ths_admin    false            9           1259    125373    set_prs_ehliyet_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_ehliyetler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_ehliyet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    312            :           1259    125374    set_prs_gorevler    TABLE     k   CREATE TABLE public.set_prs_gorevler (
    id bigint NOT NULL,
    gorev character varying(32) NOT NULL
);
 $   DROP TABLE public.set_prs_gorevler;
       public         heap 	   ths_admin    false            ;           1259    125377    set_prs_gorev_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_gorevler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_gorev_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    314            <           1259    125378    set_prs_lisanlar    TABLE     k   CREATE TABLE public.set_prs_lisanlar (
    id bigint NOT NULL,
    lisan character varying(16) NOT NULL
);
 $   DROP TABLE public.set_prs_lisanlar;
       public         heap 	   ths_admin    false            =           1259    125381    set_prs_lisan_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_lisanlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_lisan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    316            >           1259    125382    set_prs_lisan_seviyeleri    TABLE     |   CREATE TABLE public.set_prs_lisan_seviyeleri (
    id bigint NOT NULL,
    lisan_seviyesi character varying(16) NOT NULL
);
 ,   DROP TABLE public.set_prs_lisan_seviyeleri;
       public         heap 	   ths_admin    false            ?           1259    125385    set_prs_lisan_seviyesi_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_lisan_seviyeleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_lisan_seviyesi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    318            @           1259    125386    set_prs_personel_tipleri    TABLE     {   CREATE TABLE public.set_prs_personel_tipleri (
    id bigint NOT NULL,
    personel_tipi character varying(32) NOT NULL
);
 ,   DROP TABLE public.set_prs_personel_tipleri;
       public         heap 	   ths_admin    false            A           1259    125389    set_prs_personel_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_personel_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_personel_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    320            B           1259    125390    set_prs_tasima_servisleri    TABLE     �   CREATE TABLE public.set_prs_tasima_servisleri (
    id bigint NOT NULL,
    arac_no smallint NOT NULL,
    arac_adi character varying(32) NOT NULL,
    rota double precision[]
);
 -   DROP TABLE public.set_prs_tasima_servisleri;
       public         heap 	   ths_admin    false            C           1259    125395    set_prs_servis_araci_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_tasima_servisleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_servis_araci_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    322            D           1259    125396    set_sat_siparis_durum_id_seq    SEQUENCE     �   ALTER TABLE public.set_sls_order_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_sat_siparis_durum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    279            E           1259    125397    set_sls_offer_status    TABLE     �   CREATE TABLE public.set_sls_offer_status (
    id bigint NOT NULL,
    teklif_durum character varying(32) NOT NULL,
    aciklama character varying(64)
);
 (   DROP TABLE public.set_sls_offer_status;
       public         heap 	   ths_admin    false            F           1259    125400    set_sat_teklif_durum_id_seq    SEQUENCE     �   ALTER TABLE public.set_sls_offer_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_sat_teklif_durum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    325            G           1259    125401    stk_ambarlar    TABLE       CREATE TABLE public.stk_ambarlar (
    id bigint NOT NULL,
    ambar_adi character varying(32),
    is_varsayilan_hammadde boolean DEFAULT false NOT NULL,
    is_varsayilan_uretim boolean DEFAULT false NOT NULL,
    is_varsayilan_satis boolean DEFAULT false NOT NULL
);
     DROP TABLE public.stk_ambarlar;
       public         heap 	   ths_admin    false            Y           0    0    TABLE stk_ambarlar    COMMENT     X   COMMENT ON TABLE public.stk_ambarlar IS 'Stok hareketlerinin tutulduğu ambar bilgisi';
          public       	   ths_admin    false    327            H           1259    125407    stk_cins_ozellikleri    TABLE     s  CREATE TABLE public.stk_cins_ozellikleri (
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
       public         heap 	   ths_admin    false            I           1259    125412    stk_cins_ozelligi_id_seq    SEQUENCE     �   ALTER TABLE public.stk_cins_ozellikleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_cins_ozelligi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    328            J           1259    125413    stk_hareketler    TABLE       CREATE TABLE public.stk_hareketler (
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
       public         heap 	   ths_admin    false            K           1259    125418    stk_hareketler_id_seq    SEQUENCE     �   ALTER TABLE public.stk_hareketler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_hareketler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    330            L           1259    125419    stk_kart_ozetleri    TABLE     �  CREATE TABLE public.stk_kart_ozetleri (
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
       public         heap 	   ths_admin    false            M           1259    125433    stk_kart_ozetleri_id_seq    SEQUENCE     �   ALTER TABLE public.stk_kart_ozetleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_kart_ozetleri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    332            N           1259    125434    stk_kartlar_id_seq    SEQUENCE     �   ALTER TABLE public.stk_kartlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_kartlar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    281            O           1259    125435    stk_resimler    TABLE     o   CREATE TABLE public.stk_resimler (
    id bigint NOT NULL,
    stk_kart_id bigint NOT NULL,
    resim bytea
);
     DROP TABLE public.stk_resimler;
       public         heap 	   ths_admin    false            P           1259    125440    stk_resimler_id_seq    SEQUENCE     �   ALTER TABLE public.stk_resimler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_resimler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    335            Q           1259    125441    stk_stok_ambar_id_seq    SEQUENCE     �   ALTER TABLE public.stk_ambarlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_stok_ambar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    327            R           1259    125442    stk_stok_grubu_id_seq    SEQUENCE     �   ALTER TABLE public.stk_gruplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_stok_grubu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    280            S           1259    125443    sys_adresler    TABLE     �  CREATE TABLE public.sys_adresler (
    id bigint NOT NULL,
    sehir_id bigint,
    mahalle character varying(64),
    cadde character varying(64),
    sokak character varying(64),
    bina_adi character varying(48),
    kapi_no character varying(16),
    posta_kutusu character varying(16),
    posta_kodu character varying(16),
    web character varying(64),
    email character varying(128)
);
     DROP TABLE public.sys_adresler;
       public         heap 	   ths_admin    false            T           1259    125446    sys_adres_id_seq    SEQUENCE     �   ALTER TABLE public.sys_adresler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_adres_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    339            U           1259    125447 	   sys_aylar    TABLE     e   CREATE TABLE public.sys_aylar (
    id bigint NOT NULL,
    ay_adi character varying(16) NOT NULL
);
    DROP TABLE public.sys_aylar;
       public         heap 	   ths_admin    false            V           1259    125450    sys_ay_id_seq    SEQUENCE     �   ALTER TABLE public.sys_aylar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    341            W           1259    125451    sys_bolgeler    TABLE     g   CREATE TABLE public.sys_bolgeler (
    id bigint NOT NULL,
    bolge character varying(64) NOT NULL
);
     DROP TABLE public.sys_bolgeler;
       public         heap 	   ths_admin    false            X           1259    125454    sys_bolge_id_seq    SEQUENCE     �   ALTER TABLE public.sys_bolgeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_bolge_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    343            Y           1259    125455    sys_db_status    VIEW     �  CREATE VIEW public.sys_db_status AS
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
       public       	   ths_admin    false            Z           1259    125460    sys_ersim_haklari    TABLE     i  CREATE TABLE public.sys_ersim_haklari (
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
       public         heap 	   ths_admin    false            [           1259    125468    sys_erisim_hakki_id_seq    SEQUENCE     �   ALTER TABLE public.sys_ersim_haklari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_erisim_hakki_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    346            \           1259    125469    sys_grid_filtreler_siralamalar    TABLE     �   CREATE TABLE public.sys_grid_filtreler_siralamalar (
    id bigint NOT NULL,
    tablo_adi character varying(32),
    icerik character varying,
    is_siralama boolean DEFAULT false
);
 2   DROP TABLE public.sys_grid_filtreler_siralamalar;
       public         heap 	   ths_admin    false            ]           1259    125475    sys_grid_filtre_siralama_id_seq    SEQUENCE     �   ALTER TABLE public.sys_grid_filtreler_siralamalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_filtre_siralama_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    348            ^           1259    125476    sys_grid_kolonlar    TABLE     �  CREATE TABLE public.sys_grid_kolonlar (
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
       public         heap 	   ths_admin    false            _           1259    125491    sys_grid_kolon_id_seq    SEQUENCE     �   ALTER TABLE public.sys_grid_kolonlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_kolon_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    350            `           1259    125492 
   sys_gunler    TABLE     g   CREATE TABLE public.sys_gunler (
    id bigint NOT NULL,
    gun_adi character varying(16) NOT NULL
);
    DROP TABLE public.sys_gunler;
       public         heap 	   ths_admin    false            a           1259    125495    sys_gun_id_seq    SEQUENCE     �   ALTER TABLE public.sys_gunler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_gun_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    352            b           1259    125496    sys_kaynak_gruplari    TABLE     m   CREATE TABLE public.sys_kaynak_gruplari (
    id bigint NOT NULL,
    grup character varying(64) NOT NULL
);
 '   DROP TABLE public.sys_kaynak_gruplari;
       public         heap 	   ths_admin    false            c           1259    125499    sys_kaynak_grup_id_seq    SEQUENCE     �   ALTER TABLE public.sys_kaynak_gruplari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kaynak_grup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    354            d           1259    125500    sys_kaynaklar    TABLE     �   CREATE TABLE public.sys_kaynaklar (
    id bigint NOT NULL,
    kaynak_kodu integer NOT NULL,
    kaynak_adi character varying(64) NOT NULL,
    kaynak_grup_id bigint NOT NULL
);
 !   DROP TABLE public.sys_kaynaklar;
       public         heap 	   ths_admin    false            e           1259    125503    sys_kaynak_id_seq    SEQUENCE     �   ALTER TABLE public.sys_kaynaklar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kaynak_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    356            f           1259    125504    sys_kullanicilar    TABLE     �  CREATE TABLE public.sys_kullanicilar (
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
       public         heap 	   ths_admin    false            g           1259    125513    sys_kullanici_id_seq    SEQUENCE     �   ALTER TABLE public.sys_kullanicilar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kullanici_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    358            h           1259    125514    sys_lisan_gui_icerikler    TABLE     R  CREATE TABLE public.sys_lisan_gui_icerikler (
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
       public         heap 	   ths_admin    false            i           1259    125520    sys_lisan_gui_icerik_id_seq    SEQUENCE     �   ALTER TABLE public.sys_lisan_gui_icerikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_lisan_gui_icerik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    360            j           1259    125521    sys_lisanlar    TABLE     g   CREATE TABLE public.sys_lisanlar (
    id bigint NOT NULL,
    lisan character varying(16) NOT NULL
);
     DROP TABLE public.sys_lisanlar;
       public         heap 	   ths_admin    false            k           1259    125524    sys_lisan_id_seq    SEQUENCE     �   ALTER TABLE public.sys_lisanlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_lisan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    362            l           1259    125525    sys_vergi_mukellef_tipleri    TABLE     �   CREATE TABLE public.sys_vergi_mukellef_tipleri (
    id bigint NOT NULL,
    mukellef_tipi character varying(32) NOT NULL,
    is_varsayilan boolean DEFAULT false NOT NULL
);
 .   DROP TABLE public.sys_vergi_mukellef_tipleri;
       public         heap 	   ths_admin    false            m           1259    125529    sys_mukellef_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_vergi_mukellef_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_mukellef_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    364            n           1259    125530    sys_olcu_birimleri    TABLE       CREATE TABLE public.sys_olcu_birimleri (
    id bigint NOT NULL,
    birim character varying(16) NOT NULL,
    birim_einv character varying(3),
    aciklama character varying(64),
    is_ondalik boolean DEFAULT false NOT NULL,
    birim_tipi_id bigint,
    carpan integer
);
 &   DROP TABLE public.sys_olcu_birimleri;
       public         heap 	   ths_admin    false            o           1259    125534    sys_olcu_birimi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_olcu_birimleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_olcu_birimi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    366            p           1259    125535    sys_olcu_birimi_tipleri    TABLE     }   CREATE TABLE public.sys_olcu_birimi_tipleri (
    id bigint NOT NULL,
    olcu_birimi_tipi character varying(16) NOT NULL
);
 +   DROP TABLE public.sys_olcu_birimi_tipleri;
       public         heap 	   ths_admin    false            q           1259    125538    sys_olcu_birimi_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_olcu_birimi_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_olcu_birimi_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    368            r           1259    125539    sys_ondalik_haneler    TABLE     �   CREATE TABLE public.sys_ondalik_haneler (
    id bigint NOT NULL,
    miktar smallint DEFAULT 2,
    fiyat smallint DEFAULT 2,
    tutar smallint DEFAULT 2,
    stok_miktar smallint DEFAULT 4,
    doviz_kuru smallint DEFAULT 4
);
 '   DROP TABLE public.sys_ondalik_haneler;
       public         heap 	   ths_admin    false            s           1259    125547    sys_ondalik_hane_id_seq    SEQUENCE     �   ALTER TABLE public.sys_ondalik_haneler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ondalik_hane_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    370            t           1259    125548    sys_para_birimleri    TABLE     �   CREATE TABLE public.sys_para_birimleri (
    id bigint NOT NULL,
    para character varying(3) NOT NULL,
    sembol character varying(3) NOT NULL,
    aciklama character varying(128)
);
 &   DROP TABLE public.sys_para_birimleri;
       public         heap 	   ths_admin    false            u           1259    125551    sys_para_birimi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_para_birimleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_para_birimi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    372            v           1259    125552    sys_sehir_id_seq    SEQUENCE     �   ALTER TABLE public.sys_sehirler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_sehir_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    282            w           1259    125553    sys_ulkeler    TABLE       CREATE TABLE public.sys_ulkeler (
    id bigint NOT NULL,
    ulke_kodu character varying(2) NOT NULL,
    ulke_adi character varying(128) NOT NULL,
    iso_year integer,
    iso_cctld character varying(3),
    is_eu_member boolean DEFAULT false NOT NULL
);
    DROP TABLE public.sys_ulkeler;
       public         heap 	   ths_admin    false            x           1259    125557    sys_ulke_id_seq    SEQUENCE     �   ALTER TABLE public.sys_ulkeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ulke_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    375            y           1259    125558    sys_uygulama_ayarlari    TABLE     >  CREATE TABLE public.sys_uygulama_ayarlari (
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
       public         heap 	   ths_admin    false            z           1259    125570    sys_uygulama_ayari_id_seq    SEQUENCE     �   ALTER TABLE public.sys_uygulama_ayarlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_uygulama_ayari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    377            {           1259    125571    sys_view_tables    VIEW     �  CREATE VIEW public.sys_view_tables AS
 SELECT (row_number() OVER (ORDER BY tables.table_type, tables.table_name))::integer AS id,
    initcap(replace((tables.table_name)::text, '_'::text, ' '::text)) AS table_name,
    (tables.table_type)::text AS table_type
   FROM information_schema.tables
  WHERE ((tables.table_schema)::text = 'public'::text)
  ORDER BY tables.table_type, tables.table_name;
 "   DROP VIEW public.sys_view_tables;
       public       	   ths_admin    false            |           1259    125575    sys_view_columns    VIEW     '  CREATE VIEW public.sys_view_columns AS
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
       public       	   ths_admin    false    379    379            }           1259    125580    sys_view_databases    VIEW     >  CREATE VIEW public.sys_view_databases AS
 SELECT (pg_database.datname)::text AS database_name,
    pg_shdescription.description AS aciklama
   FROM (pg_shdescription
     JOIN pg_database ON ((pg_shdescription.objoid = pg_database.oid)))
  WHERE ((1 = 1) AND (pg_shdescription.description = 'THS ERP Systems'::text));
 %   DROP VIEW public.sys_view_databases;
       public       	   ths_admin    false            ~           1259    125584    urt_recete_yan_urunler    TABLE     �   CREATE TABLE public.urt_recete_yan_urunler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    urun_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 *   DROP TABLE public.urt_recete_yan_urunler;
       public         heap 	   ths_admin    false                       1259    125587    urt_recete_yan_urunler_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_yan_urunler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urt_recete_yan_urunler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    382            m          0    125073    audits 
   TABLE DATA           �   COPY public.audits (id, user_name, ip_address, table_name, access_type, time_of_change, row_id, client_username, old_val, new_val) FROM stdin;
    public       	   ths_admin    false    221   �M      q          0    125083    ch_banka_subeleri 
   TABLE DATA           X   COPY public.ch_banka_subeleri (id, banka_id, sube_kodu, sube_adi, sehir_id) FROM stdin;
    public       	   ths_admin    false    225   �M      o          0    125079    ch_bankalar 
   TABLE DATA           @   COPY public.ch_bankalar (id, banka_adi, swift_kodu) FROM stdin;
    public       	   ths_admin    false    223   �M      s          0    125087    ch_bolgeler 
   TABLE DATA           0   COPY public.ch_bolgeler (id, bolge) FROM stdin;
    public       	   ths_admin    false    227   6N      u          0    125091    ch_doviz_kurlari 
   TABLE DATA           E   COPY public.ch_doviz_kurlari (id, kur_tarihi, kur, para) FROM stdin;
    public       	   ths_admin    false    229   �N      v          0    125094 
   ch_gruplar 
   TABLE DATA           .   COPY public.ch_gruplar (id, grup) FROM stdin;
    public       	   ths_admin    false    230   {O      y          0    125106    ch_hesap_planlari 
   TABLE DATA           L   COPY public.ch_hesap_planlari (id, plan_kodu, plan_adi, seviye) FROM stdin;
    public       	   ths_admin    false    233   �O      w          0    125097    ch_hesaplar 
   TABLE DATA           �  COPY public.ch_hesaplar (id, hesap_kodu, hesap_ismi, hesap_tipi_id, grup_id, bolge_id, mukellef_tipi_id, mukellef_adi, mukellef_adi2, mukellef_soyadi, vergi_dairesi, vergi_no, iban, iban_para, nace, yetkili1, yetkili1_tel, yetkili2, yetkili2_tel, yetkili3, yetkili3_tel, faks, muhasebe_telefon, muhasebe_email, muhasebe_yetkili, ozel_not, kok_kod, ara_kod, iskonto, efatura_kullaniyor, efatura_pb_name, adres_id, pasif) FROM stdin;
    public       	   ths_admin    false    231    ^      {          0    125110    mhs_fis_detaylari 
   TABLE DATA           :   COPY public.mhs_fis_detaylari (id, header_id) FROM stdin;
    public       	   ths_admin    false    235   -q      }          0    125114 
   mhs_fisler 
   TABLE DATA           D   COPY public.mhs_fisler (id, yevmiye_no, yevmiye_tarihi) FROM stdin;
    public       	   ths_admin    false    237   Jq                0    125118    mhs_transfer_kodlari 
   TABLE DATA           W   COPY public.mhs_transfer_kodlari (id, transfer_kodu, aciklama, hesap_kodu) FROM stdin;
    public       	   ths_admin    false    239   gq      �          0    125122    prs_lisan_bilgileri 
   TABLE DATA           h   COPY public.prs_lisan_bilgileri (id, lisan_id, okuma_id, yazma_id, konusma_id, personel_id) FROM stdin;
    public       	   ths_admin    false    241   �q      �          0    125126    prs_personel_ehliyetleri 
   TABLE DATA           O   COPY public.prs_personel_ehliyetleri (id, ehliyet_id, personel_id) FROM stdin;
    public       	   ths_admin    false    243   �q      �          0    125130    prs_personeller 
   TABLE DATA           b  COPY public.prs_personeller (id, ad, soyad, ad_soyad, tel1, tel2, personel_tipi_id, birim_id, gorev_id, dogum_tarihi, kan_grubu, cinsiyet, askerlik_durumu, medeni_durum, cocuk_sayisi, yakin_adi, yakin_telefon, ayakkabi_no, elbise_bedeni, genel_not, tasima_servis_id, ozel_not, maas, ikramiye_sayisi, ikramiye_tutar, identification, adres_id) FROM stdin;
    public       	   ths_admin    false    245   �q      �          0    125182    sat_fatura_detaylari 
   TABLE DATA           s   COPY public.sat_fatura_detaylari (id, header_id, teklif_detay_id, siparis_detay_id, irsaliye_detay_id) FROM stdin;
    public       	   ths_admin    false    267   �r      �          0    125186    sat_faturalar 
   TABLE DATA           i   COPY public.sat_faturalar (id, fatura_no, fatura_tarihi, teklif_id, siparis_id, irsaliye_id) FROM stdin;
    public       	   ths_admin    false    269   �r      �          0    125190    sat_irsaliye_detaylari 
   TABLE DATA           s   COPY public.sat_irsaliye_detaylari (id, header_id, teklif_detay_id, siparis_detay_id, fatura_detay_id) FROM stdin;
    public       	   ths_admin    false    271   �r      �          0    125194    sat_irsaliyeler 
   TABLE DATA           m   COPY public.sat_irsaliyeler (id, irsaliye_no, irsaliye_tarihi, teklif_id, siparis_id, fatura_id) FROM stdin;
    public       	   ths_admin    false    273   �r      �          0    125198    sat_siparis_detaylari 
   TABLE DATA           �  COPY public.sat_siparis_detaylari (id, header_id, teklif_detay_id, irsaliye_detay_id, fatura_detay_id, stok_kodu, stok_aciklama, kullanici_aciklama, referans, miktar, giden_miktar, olcu_birimi, iskonto_orani, kdv_orani, fiyat, net_fiyat, tutar, iskonto_tutar, net_tutar, kdv_tutar, toplam_tutar, is_ana_urun, referans_ana_urun_id, gtip_no, en, boy, yukseklik, net_agirlik, brut_agirlik, hacim, kab) FROM stdin;
    public       	   ths_admin    false    275   s      �          0    125222    sat_siparisler 
   TABLE DATA           u  COPY public.sat_siparisler (id, teklif_id, irsaliye_id, fatura_id, tutar, iskonto_tutar, ara_toplam, kdv_oran1, kdv_tutar1, kdv_oran2, kdv_tutar2, kdv_oran3, kdv_tutar3, kdv_oran4, kdv_tutar4, kdv_oran5, kdv_tutar5, genel_toplam, islem_tipi_id, siparis_no, siparis_tarihi, teslim_tarihi, musteri_kodu, musteri_adi, vergi_dairesi, vergi_no, ulke_id, sehir_id, ilce, mahalle, cadde, sokak, posta_kodu, bina_adi, kapi_no, musteri_temsilcisi_id, muhattap_ad, referans, para_birimi, doviz_kuru_usd, doviz_kuru_eur, aciklama, proforma_no, siparis_durum_id, teslim_sekli_id, odeme_sekli_id, paket_tipi_id, tasima_ucreti_id) FROM stdin;
    public       	   ths_admin    false    277   6s      �          0    125279    sat_teklif_detaylari 
   TABLE DATA           R  COPY public.sat_teklif_detaylari (id, header_id, siparis_detay_id, irsaliye_detay_id, fatura_detay_id, stok_kodu, stok_aciklama, kullanici_aciklama, referans, miktar, olcu_birimi, iskonto_orani, kdv_orani, fiyat, net_fiyat, tutar, iskonto_tutar, net_tutar, kdv_tutar, toplam_tutar, is_ana_urun, referans_ana_urun_id, gtip_no) FROM stdin;
    public       	   ths_admin    false    284   Ss      �          0    125296    sat_teklifler 
   TABLE DATA           �  COPY public.sat_teklifler (id, siparis_id, irsaliye_id, fatura_id, is_siparislesti, tutar, iskonto_tutar, ara_toplam, kdv_oran1, kdv_tutar1, kdv_oran2, kdv_tutar2, kdv_oran3, kdv_tutar3, kdv_oran4, kdv_tutar4, kdv_oran5, kdv_tutar5, genel_toplam, islem_tipi_id, teklif_no, teklif_tarihi, gecerlilik_tarihi, musteri_kodu, musteri_adi, vergi_dairesi, vergi_no, ulke_id, sehir_id, ilce, mahalle, cadde, sokak, posta_kodu, bina_adi, kapi_no, musteri_temsilcisi_id, muhattap_ad, muhattap_telefon, referans, para_birimi, doviz_kuru_usd, doviz_kuru_eur, aciklama, proforma_no, teslim_sekli_id, odeme_sekli_id, paket_tipi_id, tasima_ucreti_id) FROM stdin;
    public       	   ths_admin    false    286   <t      �          0    125318    set_ch_firma_tipleri 
   TABLE DATA           M   COPY public.set_ch_firma_tipleri (id, firma_turu_id, firma_tipi) FROM stdin;
    public       	   ths_admin    false    288   u      �          0    125322    set_ch_firma_turleri 
   TABLE DATA           >   COPY public.set_ch_firma_turleri (id, firma_turu) FROM stdin;
    public       	   ths_admin    false    290   cu      �          0    125328    set_ch_hesap_tipleri 
   TABLE DATA           >   COPY public.set_ch_hesap_tipleri (id, hesap_tipi) FROM stdin;
    public       	   ths_admin    false    294   �u      �          0    125332    set_ch_vergi_oranlari 
   TABLE DATA           �   COPY public.set_ch_vergi_oranlari (id, vergi_orani, satis_hesap_kodu, satis_iade_hesap_kodu, alis_hesap_kodu, alis_iade_hesap_kodu, ihracat_hesap_kodu, ihracat_iade_hesap_kodu, ithalat_hesap_kodu, ithalat_iade_hesap_kodu) FROM stdin;
    public       	   ths_admin    false    296   �u      �          0    125336    set_einv_fatura_tipleri 
   TABLE DATA           B   COPY public.set_einv_fatura_tipleri (id, fatura_tipi) FROM stdin;
    public       	   ths_admin    false    298   2v      �          0    125340    set_einv_odeme_sekilleri 
   TABLE DATA           ^   COPY public.set_einv_odeme_sekilleri (id, odeme_sekli, kod, aciklama, is_efatura) FROM stdin;
    public       	   ths_admin    false    300   �v      �          0    125347    set_einv_paket_tipleri 
   TABLE DATA           O   COPY public.set_einv_paket_tipleri (id, kod, paket_tipi, aciklama) FROM stdin;
    public       	   ths_admin    false    302   �w      �          0    125353    set_einv_tasima_ucretleri 
   TABLE DATA           F   COPY public.set_einv_tasima_ucretleri (id, tasima_ucreti) FROM stdin;
    public       	   ths_admin    false    304   x      �          0    125357    set_einv_teslim_sekilleri 
   TABLE DATA           [   COPY public.set_einv_teslim_sekilleri (id, teslim_sekli, aciklama, is_efatura) FROM stdin;
    public       	   ths_admin    false    306   Xx      �          0    125362    set_prs_birimler 
   TABLE DATA           ?   COPY public.set_prs_birimler (id, birim, bolum_id) FROM stdin;
    public       	   ths_admin    false    308   _z      �          0    125366    set_prs_bolumler 
   TABLE DATA           5   COPY public.set_prs_bolumler (id, bolum) FROM stdin;
    public       	   ths_admin    false    310   �z      �          0    125370    set_prs_ehliyetler 
   TABLE DATA           9   COPY public.set_prs_ehliyetler (id, ehliyet) FROM stdin;
    public       	   ths_admin    false    312   �z      �          0    125374    set_prs_gorevler 
   TABLE DATA           5   COPY public.set_prs_gorevler (id, gorev) FROM stdin;
    public       	   ths_admin    false    314   �z      �          0    125382    set_prs_lisan_seviyeleri 
   TABLE DATA           F   COPY public.set_prs_lisan_seviyeleri (id, lisan_seviyesi) FROM stdin;
    public       	   ths_admin    false    318   >{      �          0    125378    set_prs_lisanlar 
   TABLE DATA           5   COPY public.set_prs_lisanlar (id, lisan) FROM stdin;
    public       	   ths_admin    false    316   x{      �          0    125386    set_prs_personel_tipleri 
   TABLE DATA           E   COPY public.set_prs_personel_tipleri (id, personel_tipi) FROM stdin;
    public       	   ths_admin    false    320   �{      �          0    125390    set_prs_tasima_servisleri 
   TABLE DATA           P   COPY public.set_prs_tasima_servisleri (id, arac_no, arac_adi, rota) FROM stdin;
    public       	   ths_admin    false    322   �{      �          0    125397    set_sls_offer_status 
   TABLE DATA           J   COPY public.set_sls_offer_status (id, teklif_durum, aciklama) FROM stdin;
    public       	   ths_admin    false    325   �{      �          0    125244    set_sls_order_status 
   TABLE DATA           K   COPY public.set_sls_order_status (id, siparis_durum, aciklama) FROM stdin;
    public       	   ths_admin    false    279   >|      �          0    125401    stk_ambarlar 
   TABLE DATA           x   COPY public.stk_ambarlar (id, ambar_adi, is_varsayilan_hammadde, is_varsayilan_uretim, is_varsayilan_satis) FROM stdin;
    public       	   ths_admin    false    327   �|      �          0    125407    stk_cins_ozellikleri 
   TABLE DATA           �   COPY public.stk_cins_ozellikleri (id, cins, aciklama, s1, s2, s3, s4, s5, s6, s7, s8, i1, i2, i3, i4, d1, d2, d3, d4) FROM stdin;
    public       	   ths_admin    false    328   �|      �          0    125247    stk_gruplar 
   TABLE DATA           �   COPY public.stk_gruplar (id, grup, kdv_orani, satis_hesap_kodu, satis_iade_hesap_kodu, alis_hesap_kodu, alis_iade_hesap_kodu, ihracat_hesap_kodu, ihracat_iade_hesap_kodu, hammadde_hesap_kodu, mamul_hesap_kodu) FROM stdin;
    public       	   ths_admin    false    280   B}      �          0    125413    stk_hareketler 
   TABLE DATA           �   COPY public.stk_hareketler (id, stok_kodu, miktar, tutar, tutar_doviz, para_birimi, is_giris, tarih, veren_ambar_id, alan_ambar_id, is_donem_basi, aciklama, irsaliye_id, uretim_id) FROM stdin;
    public       	   ths_admin    false    330   �}      �          0    125419    stk_kart_ozetleri 
   TABLE DATA           ;  COPY public.stk_kart_ozetleri (id, stk_kart_id, stok_miktar, ortalama_maliyet, donem_basi_fiyat, donem_basi_miktar, donem_basi_tutar, giren_toplam, giren_toplam_maliyet, cikan_toplam, cikan_toplam_maliyet, son_alis_fiyat, son_alis_para, son_alis_tarih, son_alis_miktar, son_alis_kur, son_alis_kur_para) FROM stdin;
    public       	   ths_admin    false    332   �}      �          0    125250    stk_kartlar 
   TABLE DATA           �  COPY public.stk_kartlar (id, is_satilabilir, stok_kodu, stok_adi, stok_grubu_id, olcu_birimi_id, urun_tipi, alis_iskonto, satis_iskonto, alis_fiyat, alis_para, satis_fiyat, satis_para, ihrac_fiyat, ihrac_para, ortalama_maliyet, en, boy, yukseklik, agirlik, temin_suresi, ozel_kod, marka, mensei_id, gtip_no, diib_urun_tanimi, en_az_stok_seviyesi, tanim, cins_id, s1, s2, s3, s4, s5, s6, s7, s8, i1, i2, i3, d1, d2, d3, i4, d4) FROM stdin;
    public       	   ths_admin    false    281   �}      �          0    125435    stk_resimler 
   TABLE DATA           >   COPY public.stk_resimler (id, stk_kart_id, resim) FROM stdin;
    public       	   ths_admin    false    335          �          0    125443    sys_adresler 
   TABLE DATA           �   COPY public.sys_adresler (id, sehir_id, mahalle, cadde, sokak, bina_adi, kapi_no, posta_kutusu, posta_kodu, web, email) FROM stdin;
    public       	   ths_admin    false    339   =      �          0    125447 	   sys_aylar 
   TABLE DATA           /   COPY public.sys_aylar (id, ay_adi) FROM stdin;
    public       	   ths_admin    false    341   �      �          0    125451    sys_bolgeler 
   TABLE DATA           1   COPY public.sys_bolgeler (id, bolge) FROM stdin;
    public       	   ths_admin    false    343   �      �          0    125460    sys_ersim_haklari 
   TABLE DATA              COPY public.sys_ersim_haklari (id, kaynak_id, is_okuma, is_ekleme, is_guncelleme, is_silme, is_ozel, kullanici_id) FROM stdin;
    public       	   ths_admin    false    346   q�      �          0    125469    sys_grid_filtreler_siralamalar 
   TABLE DATA           \   COPY public.sys_grid_filtreler_siralamalar (id, tablo_adi, icerik, is_siralama) FROM stdin;
    public       	   ths_admin    false    348   6�      �          0    125476    sys_grid_kolonlar 
   TABLE DATA           �   COPY public.sys_grid_kolonlar (id, tablo_adi, kolon_adi, sira_no, kolon_genislik, veri_formati, is_gorunur, is_helper_gorunur, min_deger, min_renk, maks_deger, maks_renk, maks_deger_yuzdesi, bar_rengi, bar_arka_rengi, bar_yazi_rengi) FROM stdin;
    public       	   ths_admin    false    350   S�      �          0    125492 
   sys_gunler 
   TABLE DATA           1   COPY public.sys_gunler (id, gun_adi) FROM stdin;
    public       	   ths_admin    false    352   ]�      �          0    125496    sys_kaynak_gruplari 
   TABLE DATA           7   COPY public.sys_kaynak_gruplari (id, grup) FROM stdin;
    public       	   ths_admin    false    354   ��      �          0    125500    sys_kaynaklar 
   TABLE DATA           T   COPY public.sys_kaynaklar (id, kaynak_kodu, kaynak_adi, kaynak_grup_id) FROM stdin;
    public       	   ths_admin    false    356   8�      �          0    125504    sys_kullanicilar 
   TABLE DATA           �   COPY public.sys_kullanicilar (id, kullanici_adi, kullanici_sifre, is_aktif, is_yonetici, is_super_kullanici, ip_adres, mac_adres, personel_id) FROM stdin;
    public       	   ths_admin    false    358   ]�      �          0    125514    sys_lisan_gui_icerikler 
   TABLE DATA           v   COPY public.sys_lisan_gui_icerikler (id, lisan, kod, deger, is_fabrika, icerik_tipi, tablo_adi, form_adi) FROM stdin;
    public       	   ths_admin    false    360   ��      �          0    125521    sys_lisanlar 
   TABLE DATA           1   COPY public.sys_lisanlar (id, lisan) FROM stdin;
    public       	   ths_admin    false    362   ��      �          0    125535    sys_olcu_birimi_tipleri 
   TABLE DATA           G   COPY public.sys_olcu_birimi_tipleri (id, olcu_birimi_tipi) FROM stdin;
    public       	   ths_admin    false    368   4�      �          0    125530    sys_olcu_birimleri 
   TABLE DATA           p   COPY public.sys_olcu_birimleri (id, birim, birim_einv, aciklama, is_ondalik, birim_tipi_id, carpan) FROM stdin;
    public       	   ths_admin    false    366   x�                 0    125539    sys_ondalik_haneler 
   TABLE DATA           `   COPY public.sys_ondalik_haneler (id, miktar, fiyat, tutar, stok_miktar, doviz_kuru) FROM stdin;
    public       	   ths_admin    false    370   Q�                0    125548    sys_para_birimleri 
   TABLE DATA           H   COPY public.sys_para_birimleri (id, para, sembol, aciklama) FROM stdin;
    public       	   ths_admin    false    372   n�      �          0    125271    sys_sehirler 
   TABLE DATA           P   COPY public.sys_sehirler (id, sehir, plaka_kodu, ulke_id, bolge_id) FROM stdin;
    public       	   ths_admin    false    282   ��                0    125553    sys_ulkeler 
   TABLE DATA           a   COPY public.sys_ulkeler (id, ulke_kodu, ulke_adi, iso_year, iso_cctld, is_eu_member) FROM stdin;
    public       	   ths_admin    false    375   X�                0    125558    sys_uygulama_ayarlari 
   TABLE DATA           @  COPY public.sys_uygulama_ayarlari (id, logo, unvan, telefon, faks, vergi_dairesi, vergi_no, donem, lisan, mail_sunucu, mail_kullanici, mail_sifre, mail_smtp_port, grid_renk_1, grid_renk_2, grid_renk_aktif, crypt_key, sms_sunucu, sms_kullanici, sms_sifre, sms_baslik, versiyon, para, adres_id, diger_ayarlar) FROM stdin;
    public       	   ths_admin    false    377   ե      �          0    125525    sys_vergi_mukellef_tipleri 
   TABLE DATA           V   COPY public.sys_vergi_mukellef_tipleri (id, mukellef_tipi, is_varsayilan) FROM stdin;
    public       	   ths_admin    false    364   h       �          0    125140    urt_iscilikler 
   TABLE DATA           `   COPY public.urt_iscilikler (id, gider_kodu, gider_adi, fiyat, birim_id, gider_tipi) FROM stdin;
    public       	   ths_admin    false    247   �       �          0    125144    urt_paket_hammadde_detaylari 
   TABLE DATA           c   COPY public.urt_paket_hammadde_detaylari (id, header_id, recete_id, stok_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    249   �       �          0    125148    urt_paket_hammaddeler 
   TABLE DATA           >   COPY public.urt_paket_hammaddeler (id, paket_adi) FROM stdin;
    public       	   ths_admin    false    251         �          0    125152    urt_paket_iscilik_detaylari 
   TABLE DATA           Z   COPY public.urt_paket_iscilik_detaylari (id, header_id, iscilik_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    253   L      �          0    125156    urt_paket_iscilikler 
   TABLE DATA           =   COPY public.urt_paket_iscilikler (id, paket_adi) FROM stdin;
    public       	   ths_admin    false    255   i      �          0    125160    urt_recete_hammaddeler 
   TABLE DATA           i   COPY public.urt_recete_hammaddeler (id, header_id, recete_id, stok_kodu, miktar, fire_orani) FROM stdin;
    public       	   ths_admin    false    257   �      �          0    125170    urt_recete_iscilikler 
   TABLE DATA           T   COPY public.urt_recete_iscilikler (id, header_id, iscilik_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    261   �      �          0    125174    urt_recete_paket_hammaddeler 
   TABLE DATA           W   COPY public.urt_recete_paket_hammaddeler (id, header_id, paket_id, miktar) FROM stdin;
    public       	   ths_admin    false    263         �          0    125178    urt_recete_paket_iscilikler 
   TABLE DATA           V   COPY public.urt_recete_paket_iscilikler (id, header_id, paket_id, miktar) FROM stdin;
    public       	   ths_admin    false    265   !      	          0    125584    urt_recete_yan_urunler 
   TABLE DATA           R   COPY public.urt_recete_yan_urunler (id, header_id, urun_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    382   >      �          0    125165    urt_receteler 
   TABLE DATA           Y   COPY public.urt_receteler (id, urun_kodu, urun_adi, ornek_miktari, aciklama) FROM stdin;
    public       	   ths_admin    false    259   [      Z           0    0    a_invoices_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.a_invoices_id_seq', 10, true);
          public          postgres    false    220            [           0    0    audit_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.audit_id_seq', 1, false);
          public       	   ths_admin    false    222            \           0    0    ch_banka_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.ch_banka_id_seq', 6, true);
          public       	   ths_admin    false    224            ]           0    0    ch_banka_subesi_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.ch_banka_subesi_id_seq', 6, true);
          public       	   ths_admin    false    226            ^           0    0    ch_bolge_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.ch_bolge_id_seq', 17, true);
          public       	   ths_admin    false    228            _           0    0    ch_hesap_karti_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.ch_hesap_karti_id_seq', 316, true);
          public       	   ths_admin    false    232            `           0    0    mhs_doviz_kuru_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.mhs_doviz_kuru_id_seq', 277, true);
          public       	   ths_admin    false    234            a           0    0    mhs_fis_detaylari_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.mhs_fis_detaylari_id_seq', 1, false);
          public       	   ths_admin    false    236            b           0    0    mhs_fisler_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.mhs_fisler_id_seq', 1, false);
          public       	   ths_admin    false    238            c           0    0    mhs_transfer_kodlari_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.mhs_transfer_kodlari_id_seq', 1, false);
          public       	   ths_admin    false    240            d           0    0    prs_lisan_bilgisi_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.prs_lisan_bilgisi_id_seq', 2, false);
          public       	   ths_admin    false    242            e           0    0    prs_personel_ehliyetleri_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.prs_personel_ehliyetleri_id_seq', 1, false);
          public       	   ths_admin    false    244            f           0    0    prs_personel_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.prs_personel_id_seq', 15, true);
          public       	   ths_admin    false    246            g           0    0    rct_iscilik_gideri_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.rct_iscilik_gideri_id_seq', 2, false);
          public       	   ths_admin    false    248            h           0    0    rct_paket_hammadde_detay_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.rct_paket_hammadde_detay_id_seq', 2, true);
          public       	   ths_admin    false    250            i           0    0    rct_paket_hammadde_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.rct_paket_hammadde_id_seq', 1, true);
          public       	   ths_admin    false    252            j           0    0    rct_paket_iscilik_detay_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.rct_paket_iscilik_detay_id_seq', 1, false);
          public       	   ths_admin    false    254            k           0    0    rct_paket_iscilik_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.rct_paket_iscilik_id_seq', 1, false);
          public       	   ths_admin    false    256            l           0    0    rct_recete_hammadde_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.rct_recete_hammadde_id_seq', 18, true);
          public       	   ths_admin    false    258            m           0    0    rct_recete_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.rct_recete_id_seq', 9, true);
          public       	   ths_admin    false    260            n           0    0    rct_recete_iscilik_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.rct_recete_iscilik_id_seq', 2, true);
          public       	   ths_admin    false    262            o           0    0     rct_recete_paket_hammadde_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.rct_recete_paket_hammadde_id_seq', 1, false);
          public       	   ths_admin    false    264            p           0    0    rct_recete_paket_iscilik_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.rct_recete_paket_iscilik_id_seq', 1, false);
          public       	   ths_admin    false    266            q           0    0    sat_fatura_detay_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.sat_fatura_detay_id_seq', 1, false);
          public       	   ths_admin    false    268            r           0    0    sat_fatura_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sat_fatura_id_seq', 1, false);
          public       	   ths_admin    false    270            s           0    0    sat_irsaliye_detay_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sat_irsaliye_detay_id_seq', 1, false);
          public       	   ths_admin    false    272            t           0    0    sat_irsaliye_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.sat_irsaliye_id_seq', 1, false);
          public       	   ths_admin    false    274            u           0    0    sat_siparis_detay_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.sat_siparis_detay_id_seq', 1, false);
          public       	   ths_admin    false    276            v           0    0    sat_siparis_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sat_siparis_id_seq', 1, true);
          public       	   ths_admin    false    278            w           0    0    sat_teklif_detay_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.sat_teklif_detay_id_seq', 4, true);
          public       	   ths_admin    false    285            x           0    0    sat_teklif_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sat_teklif_id_seq', 1, true);
          public       	   ths_admin    false    287            y           0    0    set_ch_firma_tipi_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_firma_tipi_id_seq', 5, false);
          public       	   ths_admin    false    289            z           0    0    set_ch_firma_turu_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_firma_turu_id_seq', 2, false);
          public       	   ths_admin    false    291            {           0    0    set_ch_grup_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.set_ch_grup_id_seq', 72, true);
          public       	   ths_admin    false    292            |           0    0    set_ch_hesap_plani_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_ch_hesap_plani_id_seq', 286, false);
          public       	   ths_admin    false    293            }           0    0    set_ch_hesap_tipi_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_hesap_tipi_id_seq', 3, false);
          public       	   ths_admin    false    295            ~           0    0    set_ch_vergi_orani_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_vergi_orani_id_seq', 7, true);
          public       	   ths_admin    false    297                       0    0    set_einv_fatura_tipi_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_einv_fatura_tipi_id_seq', 6, false);
          public       	   ths_admin    false    299            �           0    0    set_einv_odeme_sekli_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_einv_odeme_sekli_id_seq', 32, false);
          public       	   ths_admin    false    301            �           0    0    set_einv_paket_tipi_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.set_einv_paket_tipi_id_seq', 4, false);
          public       	   ths_admin    false    303            �           0    0    set_einv_tasima_ucreti_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_einv_tasima_ucreti_id_seq', 3, true);
          public       	   ths_admin    false    305            �           0    0    set_einv_teslim_sekli_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.set_einv_teslim_sekli_id_seq', 28, false);
          public       	   ths_admin    false    307            �           0    0    set_prs_birim_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.set_prs_birim_id_seq', 42, true);
          public       	   ths_admin    false    309            �           0    0    set_prs_bolum_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.set_prs_bolum_id_seq', 11, true);
          public       	   ths_admin    false    311            �           0    0    set_prs_ehliyet_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.set_prs_ehliyet_id_seq', 4, false);
          public       	   ths_admin    false    313            �           0    0    set_prs_gorev_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.set_prs_gorev_id_seq', 4, false);
          public       	   ths_admin    false    315            �           0    0    set_prs_lisan_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.set_prs_lisan_id_seq', 3, false);
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
          public       	   ths_admin    false    338            �           0    0    sys_adres_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.sys_adres_id_seq', 5014, false);
          public       	   ths_admin    false    340            �           0    0    sys_ay_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.sys_ay_id_seq', 24, true);
          public       	   ths_admin    false    342            �           0    0    sys_bolge_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sys_bolge_id_seq', 7, false);
          public       	   ths_admin    false    344            �           0    0    sys_erisim_hakki_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sys_erisim_hakki_id_seq', 1027, true);
          public       	   ths_admin    false    347            �           0    0    sys_grid_filtre_siralama_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.sys_grid_filtre_siralama_id_seq', 22, true);
          public       	   ths_admin    false    349            �           0    0    sys_grid_kolon_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.sys_grid_kolon_id_seq', 166, true);
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
          public       	   ths_admin    false    383            &           2606    125590    audits audit_pkey 
   CONSTRAINT     O   ALTER TABLE ONLY public.audits
    ADD CONSTRAINT audit_pkey PRIMARY KEY (id);
 ;   ALTER TABLE ONLY public.audits DROP CONSTRAINT audit_pkey;
       public         	   ths_admin    false    221            ,           2606    125592 :   ch_banka_subeleri ch_banka_subeleri_banka_id_sube_kodu_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_banka_id_sube_kodu_key UNIQUE (banka_id, sube_kodu);
 d   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_banka_id_sube_kodu_key;
       public         	   ths_admin    false    225    225            .           2606    125594 (   ch_banka_subeleri ch_banka_subeleri_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_pkey;
       public         	   ths_admin    false    225            (           2606    125596 %   ch_bankalar ch_bankalar_banka_adi_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.ch_bankalar
    ADD CONSTRAINT ch_bankalar_banka_adi_key UNIQUE (banka_adi);
 O   ALTER TABLE ONLY public.ch_bankalar DROP CONSTRAINT ch_bankalar_banka_adi_key;
       public         	   ths_admin    false    223            *           2606    125598    ch_bankalar ch_bankalar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ch_bankalar
    ADD CONSTRAINT ch_bankalar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ch_bankalar DROP CONSTRAINT ch_bankalar_pkey;
       public         	   ths_admin    false    223            0           2606    125600 !   ch_bolgeler ch_bolgeler_bolge_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.ch_bolgeler
    ADD CONSTRAINT ch_bolgeler_bolge_key UNIQUE (bolge);
 K   ALTER TABLE ONLY public.ch_bolgeler DROP CONSTRAINT ch_bolgeler_bolge_key;
       public         	   ths_admin    false    227            2           2606    125602    ch_bolgeler ch_bolgeler_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ch_bolgeler
    ADD CONSTRAINT ch_bolgeler_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ch_bolgeler DROP CONSTRAINT ch_bolgeler_pkey;
       public         	   ths_admin    false    227            4           2606    125604 5   ch_doviz_kurlari ch_doviz_kurlari_kur_tarihi_para_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_kur_tarihi_para_key UNIQUE (kur_tarihi, para);
 _   ALTER TABLE ONLY public.ch_doviz_kurlari DROP CONSTRAINT ch_doviz_kurlari_kur_tarihi_para_key;
       public         	   ths_admin    false    229    229            6           2606    125606 &   ch_doviz_kurlari ch_doviz_kurlari_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.ch_doviz_kurlari DROP CONSTRAINT ch_doviz_kurlari_pkey;
       public         	   ths_admin    false    229            8           2606    125608    ch_gruplar ch_gruplar_grup_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.ch_gruplar
    ADD CONSTRAINT ch_gruplar_grup_key UNIQUE (grup);
 H   ALTER TABLE ONLY public.ch_gruplar DROP CONSTRAINT ch_gruplar_grup_key;
       public         	   ths_admin    false    230            :           2606    125610    ch_gruplar ch_gruplar_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.ch_gruplar
    ADD CONSTRAINT ch_gruplar_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.ch_gruplar DROP CONSTRAINT ch_gruplar_pkey;
       public         	   ths_admin    false    230            @           2606    125612 (   ch_hesap_planlari ch_hesap_planlari_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.ch_hesap_planlari
    ADD CONSTRAINT ch_hesap_planlari_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.ch_hesap_planlari DROP CONSTRAINT ch_hesap_planlari_pkey;
       public         	   ths_admin    false    233            <           2606    125614 &   ch_hesaplar ch_hesaplar_hesap_kodu_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_hesap_kodu_key UNIQUE (hesap_kodu);
 P   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_hesap_kodu_key;
       public         	   ths_admin    false    231            >           2606    125616    ch_hesaplar ch_hesaplar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_pkey;
       public         	   ths_admin    false    231            B           2606    125618 (   mhs_fis_detaylari mhs_fis_detaylari_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.mhs_fis_detaylari
    ADD CONSTRAINT mhs_fis_detaylari_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.mhs_fis_detaylari DROP CONSTRAINT mhs_fis_detaylari_pkey;
       public         	   ths_admin    false    235            D           2606    125620    mhs_fisler mhs_fisler_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.mhs_fisler
    ADD CONSTRAINT mhs_fisler_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.mhs_fisler DROP CONSTRAINT mhs_fisler_pkey;
       public         	   ths_admin    false    237            F           2606    125622 $   mhs_fisler mhs_fisler_yevmiye_no_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.mhs_fisler
    ADD CONSTRAINT mhs_fisler_yevmiye_no_key UNIQUE (yevmiye_no);
 N   ALTER TABLE ONLY public.mhs_fisler DROP CONSTRAINT mhs_fisler_yevmiye_no_key;
       public         	   ths_admin    false    237            H           2606    125624 .   mhs_transfer_kodlari mhs_transfer_kodlari_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.mhs_transfer_kodlari
    ADD CONSTRAINT mhs_transfer_kodlari_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.mhs_transfer_kodlari DROP CONSTRAINT mhs_transfer_kodlari_pkey;
       public         	   ths_admin    false    239            J           2606    125626 ;   mhs_transfer_kodlari mhs_transfer_kodlari_transfer_kodu_key 
   CONSTRAINT        ALTER TABLE ONLY public.mhs_transfer_kodlari
    ADD CONSTRAINT mhs_transfer_kodlari_transfer_kodu_key UNIQUE (transfer_kodu);
 e   ALTER TABLE ONLY public.mhs_transfer_kodlari DROP CONSTRAINT mhs_transfer_kodlari_transfer_kodu_key;
       public         	   ths_admin    false    239            L           2606    125628 @   prs_lisan_bilgileri prs_lisan_bilgileri_lisan_id_personel_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_lisan_id_personel_id_key UNIQUE (lisan_id, personel_id);
 j   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_lisan_id_personel_id_key;
       public         	   ths_admin    false    241    241            N           2606    125630 ,   prs_lisan_bilgileri prs_lisan_bilgileri_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_pkey;
       public         	   ths_admin    false    241            P           2606    125632 L   prs_personel_ehliyetleri prs_personel_ehliyetleri_ehliyet_id_personel_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.prs_personel_ehliyetleri
    ADD CONSTRAINT prs_personel_ehliyetleri_ehliyet_id_personel_id_key UNIQUE (ehliyet_id, personel_id);
 v   ALTER TABLE ONLY public.prs_personel_ehliyetleri DROP CONSTRAINT prs_personel_ehliyetleri_ehliyet_id_personel_id_key;
       public         	   ths_admin    false    243    243            R           2606    125634 6   prs_personel_ehliyetleri prs_personel_ehliyetleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.prs_personel_ehliyetleri
    ADD CONSTRAINT prs_personel_ehliyetleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.prs_personel_ehliyetleri DROP CONSTRAINT prs_personel_ehliyetleri_pkey;
       public         	   ths_admin    false    243            T           2606    125636 $   prs_personeller prs_personeller_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_pkey;
       public         	   ths_admin    false    245            ~           2606    125638 .   sat_fatura_detaylari sat_fatura_detaylari_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.sat_fatura_detaylari
    ADD CONSTRAINT sat_fatura_detaylari_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.sat_fatura_detaylari DROP CONSTRAINT sat_fatura_detaylari_pkey;
       public         	   ths_admin    false    267            �           2606    125640     sat_faturalar sat_faturalar_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.sat_faturalar
    ADD CONSTRAINT sat_faturalar_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.sat_faturalar DROP CONSTRAINT sat_faturalar_pkey;
       public         	   ths_admin    false    269            �           2606    125642 2   sat_irsaliye_detaylari sat_irsaliye_detaylari_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.sat_irsaliye_detaylari
    ADD CONSTRAINT sat_irsaliye_detaylari_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.sat_irsaliye_detaylari DROP CONSTRAINT sat_irsaliye_detaylari_pkey;
       public         	   ths_admin    false    271            �           2606    125644 $   sat_irsaliyeler sat_irsaliyeler_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.sat_irsaliyeler
    ADD CONSTRAINT sat_irsaliyeler_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.sat_irsaliyeler DROP CONSTRAINT sat_irsaliyeler_pkey;
       public         	   ths_admin    false    273            �           2606    125646 0   sat_siparis_detaylari sat_siparis_detaylari_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_pkey;
       public         	   ths_admin    false    275            �           2606    125648 "   sat_siparisler sat_siparisler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_pkey;
       public         	   ths_admin    false    277            �           2606    125650 .   sat_teklif_detaylari sat_teklif_detaylari_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_pkey;
       public         	   ths_admin    false    284            �           2606    125652 &   sat_teklifler sat_teklif_teklif_no_key 
   CONSTRAINT     f   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklif_teklif_no_key UNIQUE (teklif_no);
 P   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklif_teklif_no_key;
       public         	   ths_admin    false    286            �           2606    125654     sat_teklifler sat_teklifler_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_pkey;
       public         	   ths_admin    false    286            �           2606    125656 9   set_ch_firma_turleri set_acc_firma_turleri_firma_turu_key 
   CONSTRAINT     z   ALTER TABLE ONLY public.set_ch_firma_turleri
    ADD CONSTRAINT set_acc_firma_turleri_firma_turu_key UNIQUE (firma_turu);
 c   ALTER TABLE ONLY public.set_ch_firma_turleri DROP CONSTRAINT set_acc_firma_turleri_firma_turu_key;
       public         	   ths_admin    false    290            �           2606    125658 /   set_ch_firma_turleri set_acc_firma_turleri_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.set_ch_firma_turleri
    ADD CONSTRAINT set_acc_firma_turleri_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY public.set_ch_firma_turleri DROP CONSTRAINT set_acc_firma_turleri_pkey;
       public         	   ths_admin    false    290            �           2606    125660 8   set_ch_firma_tipleri set_ch_firma_tipleri_firma_tipi_key 
   CONSTRAINT     y   ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_firma_tipi_key UNIQUE (firma_tipi);
 b   ALTER TABLE ONLY public.set_ch_firma_tipleri DROP CONSTRAINT set_ch_firma_tipleri_firma_tipi_key;
       public         	   ths_admin    false    288            �           2606    125662 .   set_ch_firma_tipleri set_ch_firma_tipleri_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.set_ch_firma_tipleri DROP CONSTRAINT set_ch_firma_tipleri_pkey;
       public         	   ths_admin    false    288            �           2606    125664 7   set_ch_hesap_tipleri set_ch_hesap_tipleri_hesa_tipi_key 
   CONSTRAINT     x   ALTER TABLE ONLY public.set_ch_hesap_tipleri
    ADD CONSTRAINT set_ch_hesap_tipleri_hesa_tipi_key UNIQUE (hesap_tipi);
 a   ALTER TABLE ONLY public.set_ch_hesap_tipleri DROP CONSTRAINT set_ch_hesap_tipleri_hesa_tipi_key;
       public         	   ths_admin    false    294            �           2606    125666 .   set_ch_hesap_tipleri set_ch_hesap_tipleri_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.set_ch_hesap_tipleri
    ADD CONSTRAINT set_ch_hesap_tipleri_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.set_ch_hesap_tipleri DROP CONSTRAINT set_ch_hesap_tipleri_pkey;
       public         	   ths_admin    false    294            �           2606    125668 0   set_ch_vergi_oranlari set_ch_vergi_oranlari_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_pkey;
       public         	   ths_admin    false    296            �           2606    125670 :   set_ch_vergi_oranlari set_ch_vergi_oranlari_veri_orani_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_veri_orani_key UNIQUE (vergi_orani);
 d   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_veri_orani_key;
       public         	   ths_admin    false    296            �           2606    125672 ?   set_einv_fatura_tipleri set_einv_fatura_tipleri_fatura_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_fatura_tipleri
    ADD CONSTRAINT set_einv_fatura_tipleri_fatura_tipi_key UNIQUE (fatura_tipi);
 i   ALTER TABLE ONLY public.set_einv_fatura_tipleri DROP CONSTRAINT set_einv_fatura_tipleri_fatura_tipi_key;
       public         	   ths_admin    false    298            �           2606    125674 4   set_einv_fatura_tipleri set_einv_fatura_tipleri_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.set_einv_fatura_tipleri
    ADD CONSTRAINT set_einv_fatura_tipleri_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.set_einv_fatura_tipleri DROP CONSTRAINT set_einv_fatura_tipleri_pkey;
       public         	   ths_admin    false    298            �           2606    125676 6   set_einv_odeme_sekilleri set_einv_odeme_sekilleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.set_einv_odeme_sekilleri
    ADD CONSTRAINT set_einv_odeme_sekilleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.set_einv_odeme_sekilleri DROP CONSTRAINT set_einv_odeme_sekilleri_pkey;
       public         	   ths_admin    false    300            �           2606    125678 A   set_einv_odeme_sekilleri set_einv_odeme_sekli_odeme_sekilleri_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_odeme_sekilleri
    ADD CONSTRAINT set_einv_odeme_sekli_odeme_sekilleri_key UNIQUE (odeme_sekli);
 k   ALTER TABLE ONLY public.set_einv_odeme_sekilleri DROP CONSTRAINT set_einv_odeme_sekli_odeme_sekilleri_key;
       public         	   ths_admin    false    300            �           2606    125680 5   set_einv_paket_tipleri set_einv_paket_tipleri_kod_key 
   CONSTRAINT     o   ALTER TABLE ONLY public.set_einv_paket_tipleri
    ADD CONSTRAINT set_einv_paket_tipleri_kod_key UNIQUE (kod);
 _   ALTER TABLE ONLY public.set_einv_paket_tipleri DROP CONSTRAINT set_einv_paket_tipleri_kod_key;
       public         	   ths_admin    false    302            �           2606    125682 2   set_einv_paket_tipleri set_einv_paket_tipleri_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.set_einv_paket_tipleri
    ADD CONSTRAINT set_einv_paket_tipleri_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.set_einv_paket_tipleri DROP CONSTRAINT set_einv_paket_tipleri_pkey;
       public         	   ths_admin    false    302            �           2606    125684 8   set_einv_tasima_ucretleri set_einv_tasima_ucretleri_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.set_einv_tasima_ucretleri
    ADD CONSTRAINT set_einv_tasima_ucretleri_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.set_einv_tasima_ucretleri DROP CONSTRAINT set_einv_tasima_ucretleri_pkey;
       public         	   ths_admin    false    304            �           2606    125686 E   set_einv_tasima_ucretleri set_einv_tasima_ucretleri_tasima_ucreti_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_tasima_ucretleri
    ADD CONSTRAINT set_einv_tasima_ucretleri_tasima_ucreti_key UNIQUE (tasima_ucreti);
 o   ALTER TABLE ONLY public.set_einv_tasima_ucretleri DROP CONSTRAINT set_einv_tasima_ucretleri_tasima_ucreti_key;
       public         	   ths_admin    false    304            �           2606    125688 8   set_einv_teslim_sekilleri set_einv_teslim_sekilleri_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.set_einv_teslim_sekilleri
    ADD CONSTRAINT set_einv_teslim_sekilleri_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.set_einv_teslim_sekilleri DROP CONSTRAINT set_einv_teslim_sekilleri_pkey;
       public         	   ths_admin    false    306            �           2606    125690 D   set_einv_teslim_sekilleri set_einv_teslim_sekilleri_teslim_sekli_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_teslim_sekilleri
    ADD CONSTRAINT set_einv_teslim_sekilleri_teslim_sekli_key UNIQUE (teslim_sekli);
 n   ALTER TABLE ONLY public.set_einv_teslim_sekilleri DROP CONSTRAINT set_einv_teslim_sekilleri_teslim_sekli_key;
       public         	   ths_admin    false    306            �           2606    125692 4   set_prs_birimler set_prs_birimler_birim_bolum_id_key 
   CONSTRAINT     z   ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_birim_bolum_id_key UNIQUE (birim, bolum_id);
 ^   ALTER TABLE ONLY public.set_prs_birimler DROP CONSTRAINT set_prs_birimler_birim_bolum_id_key;
       public         	   ths_admin    false    308    308            �           2606    125694 &   set_prs_birimler set_prs_birimler_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_birimler DROP CONSTRAINT set_prs_birimler_pkey;
       public         	   ths_admin    false    308            �           2606    125696 +   set_prs_bolumler set_prs_bolumler_bolum_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.set_prs_bolumler
    ADD CONSTRAINT set_prs_bolumler_bolum_key UNIQUE (bolum);
 U   ALTER TABLE ONLY public.set_prs_bolumler DROP CONSTRAINT set_prs_bolumler_bolum_key;
       public         	   ths_admin    false    310            �           2606    125698 &   set_prs_bolumler set_prs_bolumler_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_bolumler
    ADD CONSTRAINT set_prs_bolumler_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_bolumler DROP CONSTRAINT set_prs_bolumler_pkey;
       public         	   ths_admin    false    310            �           2606    125700 1   set_prs_ehliyetler set_prs_ehliyetler_ehliyet_key 
   CONSTRAINT     o   ALTER TABLE ONLY public.set_prs_ehliyetler
    ADD CONSTRAINT set_prs_ehliyetler_ehliyet_key UNIQUE (ehliyet);
 [   ALTER TABLE ONLY public.set_prs_ehliyetler DROP CONSTRAINT set_prs_ehliyetler_ehliyet_key;
       public         	   ths_admin    false    312            �           2606    125702 *   set_prs_ehliyetler set_prs_ehliyetler_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.set_prs_ehliyetler
    ADD CONSTRAINT set_prs_ehliyetler_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.set_prs_ehliyetler DROP CONSTRAINT set_prs_ehliyetler_pkey;
       public         	   ths_admin    false    312            �           2606    125704 +   set_prs_gorevler set_prs_gorevler_gorev_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.set_prs_gorevler
    ADD CONSTRAINT set_prs_gorevler_gorev_key UNIQUE (gorev);
 U   ALTER TABLE ONLY public.set_prs_gorevler DROP CONSTRAINT set_prs_gorevler_gorev_key;
       public         	   ths_admin    false    314            �           2606    125706 &   set_prs_gorevler set_prs_gorevler_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_gorevler
    ADD CONSTRAINT set_prs_gorevler_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_gorevler DROP CONSTRAINT set_prs_gorevler_pkey;
       public         	   ths_admin    false    314            �           2606    125708 D   set_prs_lisan_seviyeleri set_prs_lisan_seviyeleri_lisan_seviyesi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri
    ADD CONSTRAINT set_prs_lisan_seviyeleri_lisan_seviyesi_key UNIQUE (lisan_seviyesi);
 n   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri DROP CONSTRAINT set_prs_lisan_seviyeleri_lisan_seviyesi_key;
       public         	   ths_admin    false    318            �           2606    125710 6   set_prs_lisan_seviyeleri set_prs_lisan_seviyeleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri
    ADD CONSTRAINT set_prs_lisan_seviyeleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri DROP CONSTRAINT set_prs_lisan_seviyeleri_pkey;
       public         	   ths_admin    false    318            �           2606    125712 +   set_prs_lisanlar set_prs_lisanlar_lisan_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.set_prs_lisanlar
    ADD CONSTRAINT set_prs_lisanlar_lisan_key UNIQUE (lisan);
 U   ALTER TABLE ONLY public.set_prs_lisanlar DROP CONSTRAINT set_prs_lisanlar_lisan_key;
       public         	   ths_admin    false    316            �           2606    125714 &   set_prs_lisanlar set_prs_lisanlar_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_lisanlar
    ADD CONSTRAINT set_prs_lisanlar_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_lisanlar DROP CONSTRAINT set_prs_lisanlar_pkey;
       public         	   ths_admin    false    316            �           2606    125716 C   set_prs_personel_tipleri set_prs_personel_tipleri_personel_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_prs_personel_tipleri
    ADD CONSTRAINT set_prs_personel_tipleri_personel_tipi_key UNIQUE (personel_tipi);
 m   ALTER TABLE ONLY public.set_prs_personel_tipleri DROP CONSTRAINT set_prs_personel_tipleri_personel_tipi_key;
       public         	   ths_admin    false    320            �           2606    125718 6   set_prs_personel_tipleri set_prs_personel_tipleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.set_prs_personel_tipleri
    ADD CONSTRAINT set_prs_personel_tipleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.set_prs_personel_tipleri DROP CONSTRAINT set_prs_personel_tipleri_pkey;
       public         	   ths_admin    false    320            �           2606    125720 ?   set_prs_tasima_servisleri set_prs_tasima_servisleri_arac_no_key 
   CONSTRAINT     }   ALTER TABLE ONLY public.set_prs_tasima_servisleri
    ADD CONSTRAINT set_prs_tasima_servisleri_arac_no_key UNIQUE (arac_no);
 i   ALTER TABLE ONLY public.set_prs_tasima_servisleri DROP CONSTRAINT set_prs_tasima_servisleri_arac_no_key;
       public         	   ths_admin    false    322            �           2606    125722 8   set_prs_tasima_servisleri set_prs_tasima_servisleri_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.set_prs_tasima_servisleri
    ADD CONSTRAINT set_prs_tasima_servisleri_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.set_prs_tasima_servisleri DROP CONSTRAINT set_prs_tasima_servisleri_pkey;
       public         	   ths_admin    false    322            �           2606    125724 /   set_sls_order_status set_sat_siparis_durum_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.set_sls_order_status
    ADD CONSTRAINT set_sat_siparis_durum_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY public.set_sls_order_status DROP CONSTRAINT set_sat_siparis_durum_pkey;
       public         	   ths_admin    false    279            �           2606    125726 <   set_sls_order_status set_sat_siparis_durum_siparis_durum_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_sls_order_status
    ADD CONSTRAINT set_sat_siparis_durum_siparis_durum_key UNIQUE (siparis_durum);
 f   ALTER TABLE ONLY public.set_sls_order_status DROP CONSTRAINT set_sat_siparis_durum_siparis_durum_key;
       public         	   ths_admin    false    279            �           2606    125728 .   set_sls_offer_status set_sat_teklif_durum_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.set_sls_offer_status
    ADD CONSTRAINT set_sat_teklif_durum_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.set_sls_offer_status DROP CONSTRAINT set_sat_teklif_durum_pkey;
       public         	   ths_admin    false    325            �           2606    125730 :   set_sls_offer_status set_sat_teklif_durum_teklif_durum_key 
   CONSTRAINT     }   ALTER TABLE ONLY public.set_sls_offer_status
    ADD CONSTRAINT set_sat_teklif_durum_teklif_durum_key UNIQUE (teklif_durum);
 d   ALTER TABLE ONLY public.set_sls_offer_status DROP CONSTRAINT set_sat_teklif_durum_teklif_durum_key;
       public         	   ths_admin    false    325            �           2606    125732 '   stk_ambarlar stk_ambarlar_ambar_adi_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.stk_ambarlar
    ADD CONSTRAINT stk_ambarlar_ambar_adi_key UNIQUE (ambar_adi);
 Q   ALTER TABLE ONLY public.stk_ambarlar DROP CONSTRAINT stk_ambarlar_ambar_adi_key;
       public         	   ths_admin    false    327            �           2606    125734    stk_ambarlar stk_ambarlar_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.stk_ambarlar
    ADD CONSTRAINT stk_ambarlar_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.stk_ambarlar DROP CONSTRAINT stk_ambarlar_pkey;
       public         	   ths_admin    false    327            �           2606    125736 2   stk_cins_ozellikleri stk_cins_ozellikleri_cins_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.stk_cins_ozellikleri
    ADD CONSTRAINT stk_cins_ozellikleri_cins_key UNIQUE (cins);
 \   ALTER TABLE ONLY public.stk_cins_ozellikleri DROP CONSTRAINT stk_cins_ozellikleri_cins_key;
       public         	   ths_admin    false    328            �           2606    125738 .   stk_cins_ozellikleri stk_cins_ozellikleri_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.stk_cins_ozellikleri
    ADD CONSTRAINT stk_cins_ozellikleri_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.stk_cins_ozellikleri DROP CONSTRAINT stk_cins_ozellikleri_pkey;
       public         	   ths_admin    false    328            �           2606    125740     stk_gruplar stk_gruplar_grup_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_grup_key UNIQUE (grup);
 J   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_grup_key;
       public         	   ths_admin    false    280            �           2606    125742    stk_gruplar stk_gruplar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_pkey;
       public         	   ths_admin    false    280            �           2606    125744 "   stk_hareketler stk_hareketler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_pkey;
       public         	   ths_admin    false    330            �           2606    125746 (   stk_kart_ozetleri stk_kart_ozetleri_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.stk_kart_ozetleri
    ADD CONSTRAINT stk_kart_ozetleri_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.stk_kart_ozetleri DROP CONSTRAINT stk_kart_ozetleri_pkey;
       public         	   ths_admin    false    332            �           2606    125748 3   stk_kart_ozetleri stk_kart_ozetleri_stk_kart_id_key 
   CONSTRAINT     u   ALTER TABLE ONLY public.stk_kart_ozetleri
    ADD CONSTRAINT stk_kart_ozetleri_stk_kart_id_key UNIQUE (stk_kart_id);
 ]   ALTER TABLE ONLY public.stk_kart_ozetleri DROP CONSTRAINT stk_kart_ozetleri_stk_kart_id_key;
       public         	   ths_admin    false    332            �           2606    125750    stk_kartlar stk_kartlar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_pkey;
       public         	   ths_admin    false    281            �           2606    125752 %   stk_kartlar stk_kartlar_stok_kodu_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_stok_kodu_key UNIQUE (stok_kodu);
 O   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_stok_kodu_key;
       public         	   ths_admin    false    281            �           2606    125754    stk_resimler stk_resimler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.stk_resimler
    ADD CONSTRAINT stk_resimler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.stk_resimler DROP CONSTRAINT stk_resimler_pkey;
       public         	   ths_admin    false    335            �           2606    125756 )   stk_resimler stk_resimler_stk_kart_id_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.stk_resimler
    ADD CONSTRAINT stk_resimler_stk_kart_id_key UNIQUE (stk_kart_id);
 S   ALTER TABLE ONLY public.stk_resimler DROP CONSTRAINT stk_resimler_stk_kart_id_key;
       public         	   ths_admin    false    335            �           2606    125758    sys_adresler sys_adresler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_adresler
    ADD CONSTRAINT sys_adresler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_adresler DROP CONSTRAINT sys_adresler_pkey;
       public         	   ths_admin    false    339            �           2606    125760    sys_aylar sys_aylar_ay_adi_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.sys_aylar
    ADD CONSTRAINT sys_aylar_ay_adi_key UNIQUE (ay_adi);
 H   ALTER TABLE ONLY public.sys_aylar DROP CONSTRAINT sys_aylar_ay_adi_key;
       public         	   ths_admin    false    341                       2606    125762    sys_aylar sys_aylar_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.sys_aylar
    ADD CONSTRAINT sys_aylar_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.sys_aylar DROP CONSTRAINT sys_aylar_pkey;
       public         	   ths_admin    false    341                       2606    125764 #   sys_bolgeler sys_bolgeler_bolge_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.sys_bolgeler
    ADD CONSTRAINT sys_bolgeler_bolge_key UNIQUE (bolge);
 M   ALTER TABLE ONLY public.sys_bolgeler DROP CONSTRAINT sys_bolgeler_bolge_key;
       public         	   ths_admin    false    343                       2606    125766    sys_bolgeler sys_bolgeler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_bolgeler
    ADD CONSTRAINT sys_bolgeler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_bolgeler DROP CONSTRAINT sys_bolgeler_pkey;
       public         	   ths_admin    false    343                       2606    125768 >   sys_ersim_haklari sys_ersim_haklari_kaynak_id_kullanici_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kaynak_id_kullanici_id_key UNIQUE (kaynak_id, kullanici_id);
 h   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_kaynak_id_kullanici_id_key;
       public         	   ths_admin    false    346    346            	           2606    125770 (   sys_ersim_haklari sys_ersim_haklari_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_pkey;
       public         	   ths_admin    false    346                       2606    125772 B   sys_grid_filtreler_siralamalar sys_grid_filtreler_siralamalar_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar
    ADD CONSTRAINT sys_grid_filtreler_siralamalar_pkey PRIMARY KEY (id);
 l   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar DROP CONSTRAINT sys_grid_filtreler_siralamalar_pkey;
       public         	   ths_admin    false    348                       2606    125774 W   sys_grid_filtreler_siralamalar sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar
    ADD CONSTRAINT sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key UNIQUE (tablo_adi, is_siralama);
 �   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar DROP CONSTRAINT sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key;
       public         	   ths_admin    false    348    348                       2606    125776 (   sys_grid_kolonlar sys_grid_kolonlar_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.sys_grid_kolonlar DROP CONSTRAINT sys_grid_kolonlar_pkey;
       public         	   ths_admin    false    350                       2606    125778 ;   sys_grid_kolonlar sys_grid_kolonlar_tablo_adi_kolon_adi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_tablo_adi_kolon_adi_key UNIQUE (tablo_adi, kolon_adi);
 e   ALTER TABLE ONLY public.sys_grid_kolonlar DROP CONSTRAINT sys_grid_kolonlar_tablo_adi_kolon_adi_key;
       public         	   ths_admin    false    350    350                       2606    125780 9   sys_grid_kolonlar sys_grid_kolonlar_tablo_adi_sira_no_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_tablo_adi_sira_no_key UNIQUE (tablo_adi, sira_no);
 c   ALTER TABLE ONLY public.sys_grid_kolonlar DROP CONSTRAINT sys_grid_kolonlar_tablo_adi_sira_no_key;
       public         	   ths_admin    false    350    350                       2606    125782 !   sys_gunler sys_gunler_gun_adi_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.sys_gunler
    ADD CONSTRAINT sys_gunler_gun_adi_key UNIQUE (gun_adi);
 K   ALTER TABLE ONLY public.sys_gunler DROP CONSTRAINT sys_gunler_gun_adi_key;
       public         	   ths_admin    false    352                       2606    125784    sys_gunler sys_gunler_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.sys_gunler
    ADD CONSTRAINT sys_gunler_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.sys_gunler DROP CONSTRAINT sys_gunler_pkey;
       public         	   ths_admin    false    352                       2606    125786 1   sys_kaynak_gruplari sys_kaynak_gruplari_grup_ukey 
   CONSTRAINT     l   ALTER TABLE ONLY public.sys_kaynak_gruplari
    ADD CONSTRAINT sys_kaynak_gruplari_grup_ukey UNIQUE (grup);
 [   ALTER TABLE ONLY public.sys_kaynak_gruplari DROP CONSTRAINT sys_kaynak_gruplari_grup_ukey;
       public         	   ths_admin    false    354                       2606    125788 /   sys_kaynak_gruplari sys_kaynak_gruplari_id_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.sys_kaynak_gruplari
    ADD CONSTRAINT sys_kaynak_gruplari_id_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY public.sys_kaynak_gruplari DROP CONSTRAINT sys_kaynak_gruplari_id_pkey;
       public         	   ths_admin    false    354                       2606    125790 +   sys_kaynaklar sys_kaynaklar_kaynak_kodu_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_kaynak_kodu_key UNIQUE (kaynak_kodu);
 U   ALTER TABLE ONLY public.sys_kaynaklar DROP CONSTRAINT sys_kaynaklar_kaynak_kodu_key;
       public         	   ths_admin    false    356                       2606    125792     sys_kaynaklar sys_kaynaklar_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.sys_kaynaklar DROP CONSTRAINT sys_kaynaklar_pkey;
       public         	   ths_admin    false    356            %           2606    125794 S   sys_lisan_gui_icerikler sys_lisan_gui_icerikler_lisan_kod_icerik_tipi_tablo_adi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_lisan_gui_icerikler
    ADD CONSTRAINT sys_lisan_gui_icerikler_lisan_kod_icerik_tipi_tablo_adi_key UNIQUE (lisan, kod, icerik_tipi, tablo_adi);
 }   ALTER TABLE ONLY public.sys_lisan_gui_icerikler DROP CONSTRAINT sys_lisan_gui_icerikler_lisan_kod_icerik_tipi_tablo_adi_key;
       public         	   ths_admin    false    360    360    360    360            '           2606    125796 4   sys_lisan_gui_icerikler sys_lisan_gui_icerikler_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.sys_lisan_gui_icerikler
    ADD CONSTRAINT sys_lisan_gui_icerikler_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.sys_lisan_gui_icerikler DROP CONSTRAINT sys_lisan_gui_icerikler_pkey;
       public         	   ths_admin    false    360            )           2606    125798 #   sys_lisanlar sys_lisanlar_lisan_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.sys_lisanlar
    ADD CONSTRAINT sys_lisanlar_lisan_key UNIQUE (lisan);
 M   ALTER TABLE ONLY public.sys_lisanlar DROP CONSTRAINT sys_lisanlar_lisan_key;
       public         	   ths_admin    false    362            +           2606    125800    sys_lisanlar sys_lisanlar_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_lisanlar
    ADD CONSTRAINT sys_lisanlar_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_lisanlar DROP CONSTRAINT sys_lisanlar_pkey;
       public         	   ths_admin    false    362            5           2606    125802 D   sys_olcu_birimi_tipleri sys_olcu_birimi_tipleri_olcu_birimi_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri
    ADD CONSTRAINT sys_olcu_birimi_tipleri_olcu_birimi_tipi_key UNIQUE (olcu_birimi_tipi);
 n   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri DROP CONSTRAINT sys_olcu_birimi_tipleri_olcu_birimi_tipi_key;
       public         	   ths_admin    false    368            7           2606    125804 4   sys_olcu_birimi_tipleri sys_olcu_birimi_tipleri_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri
    ADD CONSTRAINT sys_olcu_birimi_tipleri_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri DROP CONSTRAINT sys_olcu_birimi_tipleri_pkey;
       public         	   ths_admin    false    368            1           2606    125806 /   sys_olcu_birimleri sys_olcu_birimleri_birim_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_birim_key UNIQUE (birim);
 Y   ALTER TABLE ONLY public.sys_olcu_birimleri DROP CONSTRAINT sys_olcu_birimleri_birim_key;
       public         	   ths_admin    false    366            3           2606    125808 *   sys_olcu_birimleri sys_olcu_birimleri_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.sys_olcu_birimleri DROP CONSTRAINT sys_olcu_birimleri_pkey;
       public         	   ths_admin    false    366            9           2606    125810 ,   sys_ondalik_haneler sys_ondalik_haneler_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.sys_ondalik_haneler
    ADD CONSTRAINT sys_ondalik_haneler_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.sys_ondalik_haneler DROP CONSTRAINT sys_ondalik_haneler_pkey;
       public         	   ths_admin    false    370            ;           2606    125812 .   sys_para_birimleri sys_para_birimleri_para_key 
   CONSTRAINT     i   ALTER TABLE ONLY public.sys_para_birimleri
    ADD CONSTRAINT sys_para_birimleri_para_key UNIQUE (para);
 X   ALTER TABLE ONLY public.sys_para_birimleri DROP CONSTRAINT sys_para_birimleri_para_key;
       public         	   ths_admin    false    372            =           2606    125814 *   sys_para_birimleri sys_para_birimleri_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.sys_para_birimleri
    ADD CONSTRAINT sys_para_birimleri_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.sys_para_birimleri DROP CONSTRAINT sys_para_birimleri_pkey;
       public         	   ths_admin    false    372            �           2606    125816    sys_sehirler sys_sehirler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_pkey;
       public         	   ths_admin    false    282            �           2606    125818 +   sys_sehirler sys_sehirler_ulke_id_sehir_key 
   CONSTRAINT     p   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_ulke_id_sehir_key UNIQUE (ulke_id, sehir);
 U   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_ulke_id_sehir_key;
       public         	   ths_admin    false    282    282            ?           2606    125820    sys_ulkeler sys_ulkeler_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.sys_ulkeler
    ADD CONSTRAINT sys_ulkeler_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.sys_ulkeler DROP CONSTRAINT sys_ulkeler_pkey;
       public         	   ths_admin    false    375            A           2606    125822 %   sys_ulkeler sys_ulkeler_ulke_kodu_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.sys_ulkeler
    ADD CONSTRAINT sys_ulkeler_ulke_kodu_key UNIQUE (ulke_kodu);
 O   ALTER TABLE ONLY public.sys_ulkeler DROP CONSTRAINT sys_ulkeler_ulke_kodu_key;
       public         	   ths_admin    false    375            !           2606    125824    sys_kullanicilar sys_users_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_pkey PRIMARY KEY (id);
 I   ALTER TABLE ONLY public.sys_kullanicilar DROP CONSTRAINT sys_users_pkey;
       public         	   ths_admin    false    358            #           2606    125826 '   sys_kullanicilar sys_users_username_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_username_key UNIQUE (kullanici_adi);
 Q   ALTER TABLE ONLY public.sys_kullanicilar DROP CONSTRAINT sys_users_username_key;
       public         	   ths_admin    false    358            C           2606    125828 0   sys_uygulama_ayarlari sys_uygulama_ayarlari_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_pkey;
       public         	   ths_admin    false    377            -           2606    125830 G   sys_vergi_mukellef_tipleri sys_vergi_mukellef_tipleri_mukellef_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_vergi_mukellef_tipleri
    ADD CONSTRAINT sys_vergi_mukellef_tipleri_mukellef_tipi_key UNIQUE (mukellef_tipi);
 q   ALTER TABLE ONLY public.sys_vergi_mukellef_tipleri DROP CONSTRAINT sys_vergi_mukellef_tipleri_mukellef_tipi_key;
       public         	   ths_admin    false    364            /           2606    125832 :   sys_vergi_mukellef_tipleri sys_vergi_mukellef_tipleri_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.sys_vergi_mukellef_tipleri
    ADD CONSTRAINT sys_vergi_mukellef_tipleri_pkey PRIMARY KEY (id);
 d   ALTER TABLE ONLY public.sys_vergi_mukellef_tipleri DROP CONSTRAINT sys_vergi_mukellef_tipleri_pkey;
       public         	   ths_admin    false    364            V           2606    125834 ,   urt_iscilikler urt_iscilikler_gider_kodu_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_gider_kodu_key UNIQUE (gider_kodu);
 V   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_gider_kodu_key;
       public         	   ths_admin    false    247            X           2606    125836 "   urt_iscilikler urt_iscilikler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_pkey;
       public         	   ths_admin    false    247            Z           2606    125838 >   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_pkey;
       public         	   ths_admin    false    249            \           2606    125840 Q   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_stok_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_header_id_key UNIQUE (stok_kodu, header_id);
 {   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_header_id_key;
       public         	   ths_admin    false    249    249            ^           2606    125842 9   urt_paket_hammaddeler urt_paket_hammaddeler_paket_adi_key 
   CONSTRAINT     y   ALTER TABLE ONLY public.urt_paket_hammaddeler
    ADD CONSTRAINT urt_paket_hammaddeler_paket_adi_key UNIQUE (paket_adi);
 c   ALTER TABLE ONLY public.urt_paket_hammaddeler DROP CONSTRAINT urt_paket_hammaddeler_paket_adi_key;
       public         	   ths_admin    false    251            `           2606    125844 0   urt_paket_hammaddeler urt_paket_hammaddeler_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.urt_paket_hammaddeler
    ADD CONSTRAINT urt_paket_hammaddeler_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.urt_paket_hammaddeler DROP CONSTRAINT urt_paket_hammaddeler_pkey;
       public         	   ths_admin    false    251            b           2606    125846 <   urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_pkey PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_paket_iscilik_detaylari_pkey;
       public         	   ths_admin    false    253            f           2606    125848 7   urt_paket_iscilikler urt_paket_iscilikler_paket_adi_key 
   CONSTRAINT     w   ALTER TABLE ONLY public.urt_paket_iscilikler
    ADD CONSTRAINT urt_paket_iscilikler_paket_adi_key UNIQUE (paket_adi);
 a   ALTER TABLE ONLY public.urt_paket_iscilikler DROP CONSTRAINT urt_paket_iscilikler_paket_adi_key;
       public         	   ths_admin    false    255            h           2606    125850 .   urt_paket_iscilikler urt_paket_iscilikler_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.urt_paket_iscilikler
    ADD CONSTRAINT urt_paket_iscilikler_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.urt_paket_iscilikler DROP CONSTRAINT urt_paket_iscilikler_pkey;
       public         	   ths_admin    false    255            j           2606    125852 2   urt_recete_hammaddeler urt_recete_hammaddeler_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_pkey;
       public         	   ths_admin    false    257            l           2606    125854 E   urt_recete_hammaddeler urt_recete_hammaddeler_stok_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_stok_kodu_header_id_key UNIQUE (stok_kodu, header_id);
 o   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_stok_kodu_header_id_key;
       public         	   ths_admin    false    257    257            r           2606    125856 <   urt_recete_iscilikler urt_recete_iscilikler_iscilik_kodu_key 
   CONSTRAINT        ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_iscilik_kodu_key UNIQUE (iscilik_kodu);
 f   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_iscilik_kodu_key;
       public         	   ths_admin    false    261            t           2606    125858 0   urt_recete_iscilikler urt_recete_iscilikler_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_pkey;
       public         	   ths_admin    false    261            v           2606    125860 P   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_header_id_paket_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_header_id_paket_id_key UNIQUE (header_id, paket_id);
 z   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_header_id_paket_id_key;
       public         	   ths_admin    false    263    263            x           2606    125862 >   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_pkey;
       public         	   ths_admin    false    263            d           2606    125864 Y   urt_paket_iscilik_detaylari urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key UNIQUE (iscilik_kodu, header_id);
 �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key;
       public         	   ths_admin    false    253    253            z           2606    125866 N   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_header_id_paket_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_header_id_paket_id_key UNIQUE (header_id, paket_id);
 x   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_header_id_paket_id_key;
       public         	   ths_admin    false    265    265            |           2606    125868 <   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_pkey PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_pkey;
       public         	   ths_admin    false    265            E           2606    125870 2   urt_recete_yan_urunler urt_recete_yan_urunler_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_pkey;
       public         	   ths_admin    false    382            G           2606    125872 E   urt_recete_yan_urunler urt_recete_yan_urunler_urun_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_urun_kodu_header_id_key UNIQUE (urun_kodu, header_id);
 o   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_urun_kodu_header_id_key;
       public         	   ths_admin    false    382    382            n           2606    125874     urt_receteler urt_receteler_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.urt_receteler DROP CONSTRAINT urt_receteler_pkey;
       public         	   ths_admin    false    259            p           2606    125876 2   urt_receteler urt_receteler_urun_kodu_urun_adi_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_urun_kodu_urun_adi_key UNIQUE (urun_kodu, urun_adi);
 \   ALTER TABLE ONLY public.urt_receteler DROP CONSTRAINT urt_receteler_urun_kodu_urun_adi_key;
       public         	   ths_admin    false    259    259            �           1259    125877 #   idx_sat_siparis_detaylari_header_id    INDEX     j   CREATE INDEX idx_sat_siparis_detaylari_header_id ON public.sat_siparis_detaylari USING btree (header_id);
 7   DROP INDEX public.idx_sat_siparis_detaylari_header_id;
       public         	   ths_admin    false    275            �           1259    125878    idx_sat_siparis_musteri_kodu    INDEX     _   CREATE INDEX idx_sat_siparis_musteri_kodu ON public.sat_siparisler USING btree (musteri_kodu);
 0   DROP INDEX public.idx_sat_siparis_musteri_kodu;
       public         	   ths_admin    false    277            �           1259    125879 "   idx_sat_teklif_detaylari_header_id    INDEX     h   CREATE INDEX idx_sat_teklif_detaylari_header_id ON public.sat_teklif_detaylari USING btree (header_id);
 6   DROP INDEX public.idx_sat_teklif_detaylari_header_id;
       public         	   ths_admin    false    284            �           2620    125880    stk_cins_ozellikleri audit    TRIGGER     �   CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.stk_cins_ozellikleri FOR EACH ROW EXECUTE FUNCTION public.audit_old();

ALTER TABLE public.stk_cins_ozellikleri DISABLE TRIGGER audit;
 3   DROP TRIGGER audit ON public.stk_cins_ozellikleri;
       public       	   ths_admin    false    504    328            �           2620    132975    set_prs_birimler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_birimler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 0   DROP TRIGGER notify ON public.set_prs_birimler;
       public       	   ths_admin    false    308    489            �           2620    132974    set_prs_bolumler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_bolumler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 0   DROP TRIGGER notify ON public.set_prs_bolumler;
       public       	   ths_admin    false    310    489            �           2620    132977    set_prs_ehliyetler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_ehliyetler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 2   DROP TRIGGER notify ON public.set_prs_ehliyetler;
       public       	   ths_admin    false    312    489            �           2620    132976    set_prs_gorevler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_gorevler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 0   DROP TRIGGER notify ON public.set_prs_gorevler;
       public       	   ths_admin    false    489    314            �           2620    132979    set_prs_lisan_seviyeleri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_lisan_seviyeleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER notify ON public.set_prs_lisan_seviyeleri;
       public       	   ths_admin    false    318    489            �           2620    132978    set_prs_lisanlar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_lisanlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 0   DROP TRIGGER notify ON public.set_prs_lisanlar;
       public       	   ths_admin    false    489    316            �           2620    132980    set_prs_personel_tipleri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_personel_tipleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER notify ON public.set_prs_personel_tipleri;
       public       	   ths_admin    false    489    320            �           2620    132981     set_prs_tasima_servisleri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.set_prs_tasima_servisleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER notify ON public.set_prs_tasima_servisleri;
       public       	   ths_admin    false    489    322            �           2620    125883    stk_ambarlar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_ambarlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 ,   DROP TRIGGER notify ON public.stk_ambarlar;
       public       	   ths_admin    false    489    327            �           2620    125884    stk_cins_ozellikleri notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_cins_ozellikleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 4   DROP TRIGGER notify ON public.stk_cins_ozellikleri;
       public       	   ths_admin    false    489    328            �           2620    125885    stk_gruplar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_gruplar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 +   DROP TRIGGER notify ON public.stk_gruplar;
       public       	   ths_admin    false    489    280            �           2620    125886    stk_hareketler notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_hareketler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 .   DROP TRIGGER notify ON public.stk_hareketler;
       public       	   ths_admin    false    489    330            �           2620    125887    stk_kartlar notify    TRIGGER     �   CREATE TRIGGER notify AFTER INSERT OR DELETE OR UPDATE ON public.stk_kartlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 +   DROP TRIGGER notify ON public.stk_kartlar;
       public       	   ths_admin    false    489    281            �           2620    125888 1   sys_grid_kolonlar sys_grid_col_width_table_notify    TRIGGER     �   CREATE TRIGGER sys_grid_col_width_table_notify AFTER INSERT OR DELETE OR UPDATE ON public.sys_grid_kolonlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 J   DROP TRIGGER sys_grid_col_width_table_notify ON public.sys_grid_kolonlar;
       public       	   ths_admin    false    489    350            �           2620    125889 !   stk_cins_ozellikleri table_notify    TRIGGER     �   CREATE TRIGGER table_notify BEFORE INSERT OR DELETE OR UPDATE ON public.stk_cins_ozellikleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();

ALTER TABLE public.stk_cins_ozellikleri DISABLE TRIGGER table_notify;
 :   DROP TRIGGER table_notify ON public.stk_cins_ozellikleri;
       public       	   ths_admin    false    328    489            �           2620    125890    ch_banka_subeleri trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_banka_subeleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 5   DROP TRIGGER trg_notify ON public.ch_banka_subeleri;
       public       	   ths_admin    false    225    489            �           2620    125891    ch_bankalar trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_bankalar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER trg_notify ON public.ch_bankalar;
       public       	   ths_admin    false    223    489            �           2620    125892    ch_bolgeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_bolgeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER trg_notify ON public.ch_bolgeler;
       public       	   ths_admin    false    227    489            �           2620    125893    ch_doviz_kurlari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_doviz_kurlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 4   DROP TRIGGER trg_notify ON public.ch_doviz_kurlari;
       public       	   ths_admin    false    229    489            �           2620    125894    ch_hesaplar trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_hesaplar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER trg_notify ON public.ch_hesaplar;
       public       	   ths_admin    false    489    231            �           2620    125895    mhs_fis_detaylari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.mhs_fis_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 5   DROP TRIGGER trg_notify ON public.mhs_fis_detaylari;
       public       	   ths_admin    false    235    489            �           2620    125896    mhs_fisler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.mhs_fisler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 .   DROP TRIGGER trg_notify ON public.mhs_fisler;
       public       	   ths_admin    false    237    489            �           2620    125897    mhs_transfer_kodlari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.mhs_transfer_kodlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER trg_notify ON public.mhs_transfer_kodlari;
       public       	   ths_admin    false    239    489            �           2620    125898     set_ch_vergi_oranlari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.set_ch_vergi_oranlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER trg_notify ON public.set_ch_vergi_oranlari;
       public       	   ths_admin    false    489    296            �           2620    125899    urt_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 2   DROP TRIGGER trg_notify ON public.urt_iscilikler;
       public       	   ths_admin    false    489    247            �           2620    125900 '   urt_paket_hammadde_detaylari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_hammadde_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 @   DROP TRIGGER trg_notify ON public.urt_paket_hammadde_detaylari;
       public       	   ths_admin    false    249    489            �           2620    125901     urt_paket_hammaddeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER trg_notify ON public.urt_paket_hammaddeler;
       public       	   ths_admin    false    489    251            �           2620    125902 &   urt_paket_iscilik_detaylari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_iscilik_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 ?   DROP TRIGGER trg_notify ON public.urt_paket_iscilik_detaylari;
       public       	   ths_admin    false    489    253            �           2620    125903    urt_paket_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER trg_notify ON public.urt_paket_iscilikler;
       public       	   ths_admin    false    255    489            �           2620    125904 !   urt_recete_hammaddeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 :   DROP TRIGGER trg_notify ON public.urt_recete_hammaddeler;
       public       	   ths_admin    false    257    489            �           2620    125905     urt_recete_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER trg_notify ON public.urt_recete_iscilikler;
       public       	   ths_admin    false    261    489            �           2620    125906 '   urt_recete_paket_hammaddeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_paket_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 @   DROP TRIGGER trg_notify ON public.urt_recete_paket_hammaddeler;
       public       	   ths_admin    false    263    489            �           2620    125907 &   urt_recete_paket_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_paket_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 ?   DROP TRIGGER trg_notify ON public.urt_recete_paket_iscilikler;
       public       	   ths_admin    false    489    265            �           2620    125908 !   urt_recete_yan_urunler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_yan_urunler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 :   DROP TRIGGER trg_notify ON public.urt_recete_yan_urunler;
       public       	   ths_admin    false    382    489            �           2620    125909    urt_receteler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_receteler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 1   DROP TRIGGER trg_notify ON public.urt_receteler;
       public       	   ths_admin    false    489    259            H           2606    125910 1   ch_banka_subeleri ch_banka_subeleri_banka_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_banka_id_fkey FOREIGN KEY (banka_id) REFERENCES public.ch_bankalar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_banka_id_fkey;
       public       	   ths_admin    false    225    3882    223            I           2606    125915 1   ch_banka_subeleri ch_banka_subeleri_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_sehir_id_fkey;
       public       	   ths_admin    false    3992    225    282            J           2606    125920 +   ch_doviz_kurlari ch_doviz_kurlari_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_para_fkey FOREIGN KEY (para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE CASCADE;
 U   ALTER TABLE ONLY public.ch_doviz_kurlari DROP CONSTRAINT ch_doviz_kurlari_para_fkey;
       public       	   ths_admin    false    229    4155    372            K           2606    125925 %   ch_hesaplar ch_hesaplar_bolge_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_bolge_id_fkey FOREIGN KEY (bolge_id) REFERENCES public.ch_hesap_planlari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 O   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_bolge_id_fkey;
       public       	   ths_admin    false    3904    233    231            L           2606    125930 $   ch_hesaplar ch_hesaplar_grup_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_grup_id_fkey FOREIGN KEY (grup_id) REFERENCES public.ch_gruplar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 N   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_grup_id_fkey;
       public       	   ths_admin    false    230    231    3898            M           2606    125935 *   ch_hesaplar ch_hesaplar_hesap_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_hesap_tipi_id_fkey FOREIGN KEY (hesap_tipi_id) REFERENCES public.set_ch_hesap_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 T   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_hesap_tipi_id_fkey;
       public       	   ths_admin    false    231    294    4013            N           2606    125940 -   ch_hesaplar ch_hesaplar_mukellef_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_mukellef_tipi_id_fkey FOREIGN KEY (mukellef_tipi_id) REFERENCES public.sys_vergi_mukellef_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_mukellef_tipi_id_fkey;
       public       	   ths_admin    false    364    231    4143            O           2606    125945 2   mhs_fis_detaylari mhs_fis_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mhs_fis_detaylari
    ADD CONSTRAINT mhs_fis_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.mhs_fisler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.mhs_fis_detaylari DROP CONSTRAINT mhs_fis_detaylari_header_id_fkey;
       public       	   ths_admin    false    3908    235    237            P           2606    125950 9   mhs_transfer_kodlari mhs_transfer_kodlari_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mhs_transfer_kodlari
    ADD CONSTRAINT mhs_transfer_kodlari_hesap_kodu_fkey FOREIGN KEY (hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 c   ALTER TABLE ONLY public.mhs_transfer_kodlari DROP CONSTRAINT mhs_transfer_kodlari_hesap_kodu_fkey;
       public       	   ths_admin    false    231    3900    239            Q           2606    125955 7   prs_lisan_bilgileri prs_lisan_bilgileri_konusma_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_konusma_id_fkey FOREIGN KEY (konusma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;
 a   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_konusma_id_fkey;
       public       	   ths_admin    false    241    4061    318            R           2606    125960 5   prs_lisan_bilgileri prs_lisan_bilgileri_lisan_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_lisan_id_fkey FOREIGN KEY (lisan_id) REFERENCES public.set_prs_lisanlar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_lisan_id_fkey;
       public       	   ths_admin    false    241    316    4057            S           2606    125965 5   prs_lisan_bilgileri prs_lisan_bilgileri_okuma_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_okuma_id_fkey FOREIGN KEY (okuma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_okuma_id_fkey;
       public       	   ths_admin    false    318    241    4061            T           2606    125970 8   prs_lisan_bilgileri prs_lisan_bilgileri_personel_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_personel_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_personel_id_fkey;
       public       	   ths_admin    false    245    241    3924            U           2606    125975 5   prs_lisan_bilgileri prs_lisan_bilgileri_yazma_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_yazma_id_fkey FOREIGN KEY (yazma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_yazma_id_fkey;
       public       	   ths_admin    false    241    318    4061            V           2606    125980 A   prs_personel_ehliyetleri prs_personel_ehliyetleri_ehliyet_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personel_ehliyetleri
    ADD CONSTRAINT prs_personel_ehliyetleri_ehliyet_id_fkey FOREIGN KEY (ehliyet_id) REFERENCES public.set_prs_ehliyetler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 k   ALTER TABLE ONLY public.prs_personel_ehliyetleri DROP CONSTRAINT prs_personel_ehliyetleri_ehliyet_id_fkey;
       public       	   ths_admin    false    4049    312    243            W           2606    125985 B   prs_personel_ehliyetleri prs_personel_ehliyetleri_personel_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personel_ehliyetleri
    ADD CONSTRAINT prs_personel_ehliyetleri_personel_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE CASCADE;
 l   ALTER TABLE ONLY public.prs_personel_ehliyetleri DROP CONSTRAINT prs_personel_ehliyetleri_personel_id_fkey;
       public       	   ths_admin    false    3924    245    243            X           2606    125990 -   prs_personeller prs_personeller_adres_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_adres_id_fkey FOREIGN KEY (adres_id) REFERENCES public.sys_adresler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 W   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_adres_id_fkey;
       public       	   ths_admin    false    4093    245    339            Y           2606    125995 -   prs_personeller prs_personeller_birim_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_birim_id_fkey FOREIGN KEY (birim_id) REFERENCES public.set_prs_birimler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 W   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_birim_id_fkey;
       public       	   ths_admin    false    245    308    4041            Z           2606    126000 -   prs_personeller prs_personeller_gorev_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_gorev_id_fkey FOREIGN KEY (gorev_id) REFERENCES public.set_prs_gorevler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 W   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_gorev_id_fkey;
       public       	   ths_admin    false    314    245    4053            [           2606    126005 5   prs_personeller prs_personeller_personel_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_personel_tipi_id_fkey FOREIGN KEY (personel_tipi_id) REFERENCES public.set_prs_personel_tipleri(id) ON UPDATE CASCADE ON DELETE SET NULL;
 _   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_personel_tipi_id_fkey;
       public       	   ths_admin    false    320    4065    245            \           2606    126010 5   prs_personeller prs_personeller_tasima_servis_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_tasima_servis_id_fkey FOREIGN KEY (tasima_servis_id) REFERENCES public.set_prs_tasima_servisleri(id) ON UPDATE CASCADE ON DELETE SET NULL;
 _   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_tasima_servis_id_fkey;
       public       	   ths_admin    false    4069    322    245            n           2606    126015 8   sat_fatura_detaylari sat_fatura_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_fatura_detaylari
    ADD CONSTRAINT sat_fatura_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_faturalar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.sat_fatura_detaylari DROP CONSTRAINT sat_fatura_detaylari_header_id_fkey;
       public       	   ths_admin    false    3968    267    269            o           2606    126020 <   sat_irsaliye_detaylari sat_irsaliye_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_irsaliye_detaylari
    ADD CONSTRAINT sat_irsaliye_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_irsaliyeler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.sat_irsaliye_detaylari DROP CONSTRAINT sat_irsaliye_detaylari_header_id_fkey;
       public       	   ths_admin    false    3972    271    273            p           2606    126025 :   sat_siparis_detaylari sat_siparis_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_siparisler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 d   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_header_id_fkey;
       public       	   ths_admin    false    3978    277    275            q           2606    126030 <   sat_siparis_detaylari sat_siparis_detaylari_olcu_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_olcu_birimi_fkey FOREIGN KEY (olcu_birimi) REFERENCES public.sys_olcu_birimleri(birim) ON UPDATE CASCADE ON DELETE RESTRICT;
 f   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_olcu_birimi_fkey;
       public       	   ths_admin    false    4145    275    366            r           2606    126035 E   sat_siparis_detaylari sat_siparis_detaylari_referans_ana_urun_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.sat_siparis_detaylari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 o   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_referans_ana_urun_id_fkey;
       public       	   ths_admin    false    275    3975    275            s           2606    126040 :   sat_siparis_detaylari sat_siparis_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparis_detaylari
    ADD CONSTRAINT sat_siparis_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 d   ALTER TABLE ONLY public.sat_siparis_detaylari DROP CONSTRAINT sat_siparis_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    275    3990    281            t           2606    126045 0   sat_siparisler sat_siparisler_islem_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_islem_tipi_id_fkey FOREIGN KEY (islem_tipi_id) REFERENCES public.set_einv_fatura_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_islem_tipi_id_fkey;
       public       	   ths_admin    false    298    277    4021            u           2606    126050 /   sat_siparisler sat_siparisler_musteri_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_musteri_kodu_fkey FOREIGN KEY (musteri_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_musteri_kodu_fkey;
       public       	   ths_admin    false    231    277    3900            v           2606    126055 8   sat_siparisler sat_siparisler_musteri_temsilcisi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_musteri_temsilcisi_id_fkey FOREIGN KEY (musteri_temsilcisi_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 b   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_musteri_temsilcisi_id_fkey;
       public       	   ths_admin    false    245    3924    277            w           2606    126060 4   sat_siparisler sat_siparisler_nakliye_ucreti_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_nakliye_ucreti_id_fkey FOREIGN KEY (tasima_ucreti_id) REFERENCES public.set_einv_tasima_ucretleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 ^   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_nakliye_ucreti_id_fkey;
       public       	   ths_admin    false    277    4031    304            x           2606    126065 1   sat_siparisler sat_siparisler_odeme_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_odeme_sekli_id_fkey FOREIGN KEY (odeme_sekli_id) REFERENCES public.set_einv_odeme_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_odeme_sekli_id_fkey;
       public       	   ths_admin    false    300    277    4023            y           2606    126070 0   sat_siparisler sat_siparisler_paket_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_paket_tipi_id_fkey FOREIGN KEY (paket_tipi_id) REFERENCES public.set_einv_paket_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_paket_tipi_id_fkey;
       public       	   ths_admin    false    302    277    4029            z           2606    126075 .   sat_siparisler sat_siparisler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_para_birimi_fkey;
       public       	   ths_admin    false    277    372    4155            {           2606    126080 +   sat_siparisler sat_siparisler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 U   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_sehir_id_fkey;
       public       	   ths_admin    false    277    282    3992            |           2606    126085 3   sat_siparisler sat_siparisler_siparis_durum_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_siparis_durum_id_fkey FOREIGN KEY (siparis_durum_id) REFERENCES public.set_sls_order_status(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 ]   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_siparis_durum_id_fkey;
       public       	   ths_admin    false    3980    277    279            }           2606    126090 2   sat_siparisler sat_siparisler_teslim_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_teslim_sekli_id_fkey FOREIGN KEY (teslim_sekli_id) REFERENCES public.set_einv_teslim_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 \   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_teslim_sekli_id_fkey;
       public       	   ths_admin    false    306    4035    277            ~           2606    126095 *   sat_siparisler sat_siparisler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_siparisler
    ADD CONSTRAINT sat_siparisler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 T   ALTER TABLE ONLY public.sat_siparisler DROP CONSTRAINT sat_siparisler_ulke_id_fkey;
       public       	   ths_admin    false    4159    277    375            �           2606    126100 8   sat_teklif_detaylari sat_teklif_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sat_teklifler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_header_id_fkey;
       public       	   ths_admin    false    286    284    4001            �           2606    126105 :   sat_teklif_detaylari sat_teklif_detaylari_olcu_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_olcu_birimi_fkey FOREIGN KEY (olcu_birimi) REFERENCES public.sys_olcu_birimleri(birim) ON UPDATE CASCADE ON DELETE RESTRICT;
 d   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_olcu_birimi_fkey;
       public       	   ths_admin    false    284    366    4145            �           2606    126110 C   sat_teklif_detaylari sat_teklif_detaylari_referans_ana_urun_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.sat_teklif_detaylari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 m   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_referans_ana_urun_id_fkey;
       public       	   ths_admin    false    284    3997    284            �           2606    126115 8   sat_teklif_detaylari sat_teklif_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklif_detaylari
    ADD CONSTRAINT sat_teklif_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 b   ALTER TABLE ONLY public.sat_teklif_detaylari DROP CONSTRAINT sat_teklif_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    3990    281    284            �           2606    126120 .   sat_teklifler sat_teklifler_islem_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_islem_tipi_id_fkey FOREIGN KEY (islem_tipi_id) REFERENCES public.set_einv_fatura_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_islem_tipi_id_fkey;
       public       	   ths_admin    false    4021    286    298            �           2606    126125 -   sat_teklifler sat_teklifler_musteri_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_musteri_kodu_fkey FOREIGN KEY (musteri_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_musteri_kodu_fkey;
       public       	   ths_admin    false    3900    231    286            �           2606    126130 6   sat_teklifler sat_teklifler_musteri_temsilcisi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_musteri_temsilcisi_id_fkey FOREIGN KEY (musteri_temsilcisi_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 `   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_musteri_temsilcisi_id_fkey;
       public       	   ths_admin    false    286    245    3924            �           2606    126135 2   sat_teklifler sat_teklifler_nakliye_ucreti_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_nakliye_ucreti_id_fkey FOREIGN KEY (tasima_ucreti_id) REFERENCES public.set_einv_tasima_ucretleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 \   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_nakliye_ucreti_id_fkey;
       public       	   ths_admin    false    304    286    4031            �           2606    126140 /   sat_teklifler sat_teklifler_odeme_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_odeme_sekli_id_fkey FOREIGN KEY (odeme_sekli_id) REFERENCES public.set_einv_odeme_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_odeme_sekli_id_fkey;
       public       	   ths_admin    false    286    4023    300            �           2606    126145 .   sat_teklifler sat_teklifler_paket_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_paket_tipi_id_fkey FOREIGN KEY (paket_tipi_id) REFERENCES public.set_einv_paket_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_paket_tipi_id_fkey;
       public       	   ths_admin    false    286    302    4029            �           2606    126150 ,   sat_teklifler sat_teklifler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 V   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_para_birimi_fkey;
       public       	   ths_admin    false    4155    286    372            �           2606    126155 )   sat_teklifler sat_teklifler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_sehir_id_fkey;
       public       	   ths_admin    false    282    3992    286            �           2606    126160 0   sat_teklifler sat_teklifler_teslim_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_teslim_sekli_id_fkey FOREIGN KEY (teslim_sekli_id) REFERENCES public.set_einv_teslim_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_teslim_sekli_id_fkey;
       public       	   ths_admin    false    4035    306    286            �           2606    126165 (   sat_teklifler sat_teklifler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sat_teklifler
    ADD CONSTRAINT sat_teklifler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 R   ALTER TABLE ONLY public.sat_teklifler DROP CONSTRAINT sat_teklifler_ulke_id_fkey;
       public       	   ths_admin    false    286    375    4159            �           2606    126170 <   set_ch_firma_tipleri set_ch_firma_tipleri_firma_turu_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_firma_turu_id_fkey FOREIGN KEY (firma_turu_id) REFERENCES public.set_ch_firma_turleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 f   ALTER TABLE ONLY public.set_ch_firma_tipleri DROP CONSTRAINT set_ch_firma_tipleri_firma_turu_id_fkey;
       public       	   ths_admin    false    290    288    4009            �           2606    126175 @   set_ch_vergi_oranlari set_ch_vergi_oranlari_alis_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_alis_hesap_kodu_fkey FOREIGN KEY (alis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 j   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_alis_hesap_kodu_fkey;
       public       	   ths_admin    false    296    3900    231            �           2606    126180 E   set_ch_vergi_oranlari set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey FOREIGN KEY (alis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 o   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    231    3900    296            �           2606    126185 C   set_ch_vergi_oranlari set_ch_vergi_oranlari_ihracat_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_ihracat_hesap_kodu_fkey FOREIGN KEY (ihracat_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 m   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_ihracat_hesap_kodu_fkey;
       public       	   ths_admin    false    231    3900    296            �           2606    126190 H   set_ch_vergi_oranlari set_ch_vergi_oranlari_ihracat_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_ihracat_iade_hesap_kodu_fkey FOREIGN KEY (ihracat_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 r   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_ihracat_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    231    296    3900            �           2606    126195 C   set_ch_vergi_oranlari set_ch_vergi_oranlari_ithalat_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_ithalat_hesap_kodu_fkey FOREIGN KEY (ithalat_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 m   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_ithalat_hesap_kodu_fkey;
       public       	   ths_admin    false    296    3900    231            �           2606    126200 H   set_ch_vergi_oranlari set_ch_vergi_oranlari_ithalat_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_ithalat_iade_hesap_kodu_fkey FOREIGN KEY (ithalat_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 r   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_ithalat_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    3900    296    231            �           2606    126205 A   set_ch_vergi_oranlari set_ch_vergi_oranlari_satis_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_satis_hesap_kodu_fkey FOREIGN KEY (satis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 k   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_satis_hesap_kodu_fkey;
       public       	   ths_admin    false    3900    231    296            �           2606    126210 F   set_ch_vergi_oranlari set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey FOREIGN KEY (satis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 p   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    231    3900    296            �           2606    126215 /   set_prs_birimler set_prs_birimler_bolum_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_bolum_id_fkey FOREIGN KEY (bolum_id) REFERENCES public.set_prs_bolumler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.set_prs_birimler DROP CONSTRAINT set_prs_birimler_bolum_id_fkey;
       public       	   ths_admin    false    308    4045    310                       2606    126220 ,   stk_gruplar stk_gruplar_alis_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_alis_hesap_kodu_fkey FOREIGN KEY (alis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 V   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_alis_hesap_kodu_fkey;
       public       	   ths_admin    false    3900    280    231            �           2606    126225 1   stk_gruplar stk_gruplar_alis_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_alis_iade_hesap_kodu_fkey FOREIGN KEY (alis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_alis_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    280    3900    231            �           2606    126230 /   stk_gruplar stk_gruplar_ihracat_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_ihracat_hesap_kodu_fkey FOREIGN KEY (ihracat_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_ihracat_hesap_kodu_fkey;
       public       	   ths_admin    false    231    280    3900            �           2606    126235 4   stk_gruplar stk_gruplar_ihracat_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_ihracat_iade_hesap_kodu_fkey FOREIGN KEY (ihracat_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 ^   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_ihracat_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    3900    280    231            �           2606    126240 -   stk_gruplar stk_gruplar_satis_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_satis_hesap_kodu_fkey FOREIGN KEY (satis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_satis_hesap_kodu_fkey;
       public       	   ths_admin    false    3900    280    231            �           2606    126245 2   stk_gruplar stk_gruplar_satis_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_satis_iade_hesap_kodu_fkey FOREIGN KEY (satis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 \   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_satis_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    3900    280    231            �           2606    126250 0   stk_hareketler stk_hareketler_alan_ambar_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_alan_ambar_id_fkey FOREIGN KEY (alan_ambar_id) REFERENCES public.stk_ambarlar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_alan_ambar_id_fkey;
       public       	   ths_admin    false    4077    330    327            �           2606    126255 .   stk_hareketler stk_hareketler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_para_birimi_fkey;
       public       	   ths_admin    false    4155    330    372            �           2606    126260 ,   stk_hareketler stk_hareketler_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 V   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_stok_kodu_fkey;
       public       	   ths_admin    false    3990    330    281            �           2606    126265 1   stk_hareketler stk_hareketler_veren_ambar_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_veren_ambar_id_fkey FOREIGN KEY (veren_ambar_id) REFERENCES public.stk_ambarlar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_veren_ambar_id_fkey;
       public       	   ths_admin    false    4077    330    327            �           2606    126270 4   stk_kart_ozetleri stk_kart_ozetleri_stk_kart_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kart_ozetleri
    ADD CONSTRAINT stk_kart_ozetleri_stk_kart_id_fkey FOREIGN KEY (stk_kart_id) REFERENCES public.stk_kartlar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.stk_kart_ozetleri DROP CONSTRAINT stk_kart_ozetleri_stk_kart_id_fkey;
       public       	   ths_admin    false    332    3988    281            �           2606    126275 &   stk_kartlar stk_kartlar_alis_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_alis_para_fkey FOREIGN KEY (alis_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 P   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_alis_para_fkey;
       public       	   ths_admin    false    281    4155    372            �           2606    126280 $   stk_kartlar stk_kartlar_cins_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_cins_id_fkey FOREIGN KEY (cins_id) REFERENCES public.stk_cins_ozellikleri(id) ON UPDATE CASCADE ON DELETE SET NULL;
 N   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_cins_id_fkey;
       public       	   ths_admin    false    281    328    4081            �           2606    126285 '   stk_kartlar stk_kartlar_ihrac_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_ihrac_para_fkey FOREIGN KEY (ihrac_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_ihrac_para_fkey;
       public       	   ths_admin    false    4155    281    372            �           2606    126290 &   stk_kartlar stk_kartlar_mensei_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_mensei_id_fkey FOREIGN KEY (mensei_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 P   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_mensei_id_fkey;
       public       	   ths_admin    false    4159    281    375            �           2606    126295 +   stk_kartlar stk_kartlar_olcu_birimi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_olcu_birimi_id_fkey FOREIGN KEY (olcu_birimi_id) REFERENCES public.sys_olcu_birimleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 U   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_olcu_birimi_id_fkey;
       public       	   ths_admin    false    4147    281    366            �           2606    126300 '   stk_kartlar stk_kartlar_satis_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_satis_para_fkey FOREIGN KEY (satis_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_satis_para_fkey;
       public       	   ths_admin    false    372    281    4155            �           2606    126305 *   stk_kartlar stk_kartlar_stok_grubu_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_kartlar
    ADD CONSTRAINT stk_kartlar_stok_grubu_id_fkey FOREIGN KEY (stok_grubu_id) REFERENCES public.stk_gruplar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 T   ALTER TABLE ONLY public.stk_kartlar DROP CONSTRAINT stk_kartlar_stok_grubu_id_fkey;
       public       	   ths_admin    false    280    3986    281            �           2606    126310 *   stk_resimler stk_resimler_stk_kart_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_resimler
    ADD CONSTRAINT stk_resimler_stk_kart_id_fkey FOREIGN KEY (stk_kart_id) REFERENCES public.stk_kartlar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stk_resimler DROP CONSTRAINT stk_resimler_stk_kart_id_fkey;
       public       	   ths_admin    false    281    3988    335            �           2606    126315 '   sys_adresler sys_adresler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_adresler
    ADD CONSTRAINT sys_adresler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.sys_adresler DROP CONSTRAINT sys_adresler_sehir_id_fkey;
       public       	   ths_admin    false    282    339    3992            �           2606    126320 2   sys_ersim_haklari sys_ersim_haklari_kaynak_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kaynak_id_fkey FOREIGN KEY (kaynak_id) REFERENCES public.sys_kaynaklar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_kaynak_id_fkey;
       public       	   ths_admin    false    346    4127    356            �           2606    126325 5   sys_ersim_haklari sys_ersim_haklari_kullanici_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kullanici_id_fkey FOREIGN KEY (kullanici_id) REFERENCES public.sys_kullanicilar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_kullanici_id_fkey;
       public       	   ths_admin    false    346    358    4129            �           2606    126330 /   sys_kaynaklar sys_kaynaklar_kaynak_grup_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_kaynak_grup_id_fkey FOREIGN KEY (kaynak_grup_id) REFERENCES public.sys_kaynak_gruplari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.sys_kaynaklar DROP CONSTRAINT sys_kaynaklar_kaynak_grup_id_fkey;
       public       	   ths_admin    false    356    354    4123            �           2606    126335 :   sys_lisan_gui_icerikler sys_lisan_gui_icerikler_lisan_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_lisan_gui_icerikler
    ADD CONSTRAINT sys_lisan_gui_icerikler_lisan_fkey FOREIGN KEY (lisan) REFERENCES public.sys_lisanlar(lisan) ON UPDATE CASCADE ON DELETE RESTRICT;
 d   ALTER TABLE ONLY public.sys_lisan_gui_icerikler DROP CONSTRAINT sys_lisan_gui_icerikler_lisan_fkey;
       public       	   ths_admin    false    360    362    4137            �           2606    126340 8   sys_olcu_birimleri sys_olcu_birimleri_birim_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_birim_tipi_id_fkey FOREIGN KEY (birim_tipi_id) REFERENCES public.sys_olcu_birimi_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 b   ALTER TABLE ONLY public.sys_olcu_birimleri DROP CONSTRAINT sys_olcu_birimleri_birim_tipi_id_fkey;
       public       	   ths_admin    false    368    4151    366            �           2606    126345 '   sys_sehirler sys_sehirler_bolge_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_bolge_id_fkey FOREIGN KEY (bolge_id) REFERENCES public.sys_bolgeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_bolge_id_fkey;
       public       	   ths_admin    false    282    343    4101            �           2606    126350 &   sys_sehirler sys_sehirler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 P   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_ulke_id_fkey;
       public       	   ths_admin    false    4159    375    282            �           2606    126355 )   sys_kullanicilar sys_users_person_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_person_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.sys_kullanicilar DROP CONSTRAINT sys_users_person_id_fkey;
       public       	   ths_admin    false    3924    245    358            �           2606    126360 9   sys_uygulama_ayarlari sys_uygulama_ayarlari_adres_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_adres_id_fkey FOREIGN KEY (adres_id) REFERENCES public.sys_adresler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 c   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_adres_id_fkey;
       public       	   ths_admin    false    339    377    4093            �           2606    126365 6   sys_uygulama_ayarlari sys_uygulama_ayarlari_lisan_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_lisan_fkey FOREIGN KEY (lisan) REFERENCES public.sys_lisanlar(lisan) ON UPDATE CASCADE ON DELETE SET NULL;
 `   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_lisan_fkey;
       public       	   ths_admin    false    4137    362    377            �           2606    126370 5   sys_uygulama_ayarlari sys_uygulama_ayarlari_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_para_fkey FOREIGN KEY (para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE SET NULL;
 _   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_para_fkey;
       public       	   ths_admin    false    372    4155    377            ]           2606    126375 +   urt_iscilikler urt_iscilikler_birim_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_birim_id_fkey FOREIGN KEY (birim_id) REFERENCES public.sys_olcu_birimleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 U   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_birim_id_fkey;
       public       	   ths_admin    false    247    4147    366            ^           2606    126380 -   urt_iscilikler urt_iscilikler_gider_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_gider_kodu_fkey FOREIGN KEY (gider_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_gider_kodu_fkey;
       public       	   ths_admin    false    247    231    3900            _           2606    126385 H   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_paket_hammaddeler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 r   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_header_id_fkey;
       public       	   ths_admin    false    249    3936    251            `           2606    126390 H   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_recete_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_recete_id_fkey FOREIGN KEY (recete_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 r   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_recete_id_fkey;
       public       	   ths_admin    false    259    249    3950            a           2606    126395 H   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 r   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    3990    249    281            b           2606    126400 F   urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_paket_iscilikler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 p   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_paket_iscilik_detaylari_header_id_fkey;
       public       	   ths_admin    false    255    253    3944            c           2606    126405 I   urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_iscilik_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_iscilik_kodu_fkey FOREIGN KEY (iscilik_kodu) REFERENCES public.urt_iscilikler(gider_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 s   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_paket_iscilik_detaylari_iscilik_kodu_fkey;
       public       	   ths_admin    false    253    247    3926            d           2606    126410 <   urt_recete_hammaddeler urt_recete_hammaddeler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_header_id_fkey;
       public       	   ths_admin    false    3950    257    259            e           2606    126415 <   urt_recete_hammaddeler urt_recete_hammaddeler_recete_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_recete_id_fkey FOREIGN KEY (recete_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_recete_id_fkey;
       public       	   ths_admin    false    3950    259    257            f           2606    126420 <   urt_recete_hammaddeler urt_recete_hammaddeler_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_stok_kodu_fkey;
       public       	   ths_admin    false    257    281    3990            h           2606    126425 :   urt_recete_iscilikler urt_recete_iscilikler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 d   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_header_id_fkey;
       public       	   ths_admin    false    261    259    3950            i           2606    126430 8   urt_recete_iscilikler urt_recete_iscilikler_iscilik_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_iscilik_fkey FOREIGN KEY (iscilik_kodu) REFERENCES public.urt_iscilikler(gider_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 b   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_iscilik_fkey;
       public       	   ths_admin    false    261    247    3926            j           2606    126435 H   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 r   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_header_id_fkey;
       public       	   ths_admin    false    263    259    3950            k           2606    126440 G   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_paket_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_paket_id_fkey FOREIGN KEY (paket_id) REFERENCES public.urt_paket_hammaddeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 q   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_paket_id_fkey;
       public       	   ths_admin    false    251    3936    263            l           2606    126445 F   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 p   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_header_id_fkey;
       public       	   ths_admin    false    3950    259    265            m           2606    126450 E   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_paket_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_paket_id_fkey FOREIGN KEY (paket_id) REFERENCES public.urt_paket_iscilikler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 o   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_paket_id_fkey;
       public       	   ths_admin    false    255    265    3944            �           2606    126455 <   urt_recete_yan_urunler urt_recete_yan_urunler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_header_id_fkey;
       public       	   ths_admin    false    382    259    3950            �           2606    126460 <   urt_recete_yan_urunler urt_recete_yan_urunler_urun_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_urun_kodu_fkey FOREIGN KEY (urun_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_urun_kodu_fkey;
       public       	   ths_admin    false    3990    281    382            g           2606    126465 *   urt_receteler urt_receteler_urun_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_urun_kodu_fkey FOREIGN KEY (urun_kodu) REFERENCES public.stk_kartlar(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.urt_receteler DROP CONSTRAINT urt_receteler_urun_kodu_fkey;
       public       	   ths_admin    false    3990    281    259            m      x������ � �      q   D   x�3�4�461��v��srv�0�2�Yrz��x��id�e
242�p�s9����Ԍ+F��� ���      o   0   x�3�:�!��1�3*($�ɑː��1��/��N� �� G�=... �^      s   ^   x�3�tuw�2��vrtq�;�!�˄���4�t�?2/T������'�˂�Ȇ��p��	gdhP����y�\�����F��0��u"G�=... J� �      u   �   x�]�=�0�ṹ�b;Y��ظ�9p�@b�Jo���Hl# >A=�Zd�^�K"�!����]_OmM\r��v�'R��� ��bH�*���U� ����R eM�_B8@����H�krP�l�s���Rƅ!�ll� ��/,>��\u�� 9��E۸�ʚ��J_p�A�A4�� 5$2����|��f�i�      v   Z   x�33��=<��נ#|\���,8C\]�<���P!K�#<��C������R@% isCN'G?oGG ۈ�7��1��ɕ+F��� �� �      y     x����n�J���Sp9d�]\*�kdف�p0�N�sBH�J ��y����M��fV�I~���yIQ���&�_�꿪��n�6,�7.�4�D�y}����7�ed^D�8Q�J��,0��}���G��fw�>�q6�2�1�/>�&q��>ޯ~MV�V��������X�|���)�(������J��14��9�_2x����g����MM��X���E���|R_�e�)i�F�Q�Ds���(��o��m�e���R��g�X'܁iełn� Z&cs���#���E�H��ٳ�+�B�PMo'�&�}��F�	�z��ǁr�`�+9����1�y����ˇ�d����V_mx��2�F�g��xov��d6/���q�-��y��~%��g�x��\��,�T��b	�Ah\�G�I�u����΁�&�D���]h`7��o��(����c	(&��'5ߎK�5<0�/i$�3��"Oa5��Dr�Ke�|vC��1���ӹ�~�B���� 䄁1RY�ޙ�h�S��f<SI	�������&x|��|gB°�n ZC鸆M8�<��P6��3�h���7F����dC�@ݩ�I�j��=GԞd�&�}?QSe���Ա�ir�����ܓ��{`ؐ�Ք�z�Z�.N�d���:@��'�W�\b�yr���K�K��X�0JƷi�k1կA�����T���u�����>�Xh:U�ԧOˇ�:K(�6�U�%��Z����(�6\�EUF	$ܶ��]N`�m3���%)ܲ(H�4oS�(���;Q���D����Xv]7e�f3�҇tF��Q����l���~%y��?ؐ����XZS4�g/qg'�L�:���rA�3)��_�6�	�=d�ȟ�_������ ��W���Tw��M:�gS]`�����®�g]��se�M��J�B�N�T�Y�y�>���;.��K���;�mMAܦ��[�`�˯�:Y�iT6,!��i�<�'��`*�OI��M4�����;Z̺����A��3�`m-T0��;�
��o� �D\�iܭ�mxr��X��m�b`2(]��t�^���7����t�.�U�8���# 슈(�JCF !�2�ӡ՜�Z�-��M	с��i�c�i/m���:�FO7��_0!N�m!C	�[wD�x�Ғ�5L�iD$D�z�i�%8B-��eJ�>]Dv�	jeg�!Μ�L�X�DZ�g
t;���(�!L������M����lll���#�uq�"��	������	��ݭ0p-���J�gɜ5��YwBQ8��.�R�>}�'%\��enմ���J�eA�M�B��W���*6KG'��A����]��?�#�"��A��T������E��bcd�PE$$���D�|�D���_�O���#D/�tG]�@�3���)y����� Z�W��A�0E�c~�;��J�y�c_��=�7���h�:쯾�9��=�O��X8���Q��N{�TN����t�;�;1����h��b͡�l�oH�o����������	�e�+������j��,��a�_	�űө�aU$�j8��Ol�/�(=���ᗓ��e����TSz
˰����|tv�A-N��Q�p���H�>H��	��d]��e&��ef��t�|�U�o.��]�b8h*��{�)e/��bKq�u�`�1���g��<�g��<��g��D�g�����g������ѹ�,3�K��L	����r]�hט��lA�|�|����7��d����Ii�����!���Y����b�,3��?�ߟo�+t��a�����Ȯ�r%��h'�4@U���9X�'�G��k�耺}E��bO.�nm�Dxߦ�����
�}t�ȴ�k&�Pw���b]5i(!G���d��۠�Z���e.�[�E�s�\��4E����4��ű�A�G3����+5���Ӕ��w�1��qt'�=~���y-mJf���K�\���q� �Y_��;��������ER^�r6w[����}���h��%0�ح	�L�e�1� ��E�<A�����֓�cw�س(�.mq$)Z^Z�Z�]R:�=4 u��KR�ܝ��S��U�P��]�Ƣι{)������xw��9�e���v�_B�S0k/$��+>!٭W|��gM�λO*4�mw둻Rj(���RC	v�(�l2Fy�,��k�p�չa~��\����B�ڊI� �^X��(,��~��$o��H{����|�c[ǳYTɑb��M�i��� �U�^��\��h��|ڸ0��$�ַ�6
�\�ͥ���C�����YeY���(�[�����7�WȒq�Ǝmx$rޕ�=�0`���+Ǻ�Ӂ�8�{�,fU�����p՘��a~���?�$a3S^����@v����L+WQV^�R���Q�!d��^hUǴyiK��e�n��5|+��L������`��jjZi>����(��/
�Ԧ�c���y:�5��1r��������@��%�\,F�s*ـZ���u}ZX�XX�[u'�_p$�MI�����0#� ��w%��-(��l|P��EsI�����W�槥-F����J���5��Ƴ�M�$H�;rvK��/���Z	�J��[�&�|��C��i��V���MwI=���K��(����0���L����o�l*�X��H���4bcA�'�)�5oB �ۺ��޶-(��l�ú��B�0��YjcJv��mҡ�&t�M�@,d��VQ�MWؙ>����v��L =.��柨��ɢH�����V2�-�6Ѣ�.�RA���B��Y]�"��tj;�v�;��Wn1�y� Z�q��J���T�l%o�����Wmo}���~ؾ=�(�(�E��~R��$�.j*YŻ�6�b��K�U�Pe�4���oe.˟�T�UCCk�a��݆G�B��3���`����9ݰb�]Y����G,W+�d�>��]��e�U�n�[~��F���ޤ���-Ҩ�%��A����z�B�X�[�%�eoݴy�|�/4=!Ď��F��M'-�`�p��@}V���"®�u-V
�B�h�t�m��Us��~��x`�W+�������p�Y{��xH���w�ɢ�������!�'h�-�����������j<!k+d�cdGЮ��U�/��e�IS��}���c����NXm�&>k?Kl+�I����t�(
�eE`iY�hz�n�6N:��
�}GY��_Gjq��.�'���|"�h}H���'F�t�}i��^�%�*/N�g��7h}���5� ɇ�^�%�B@��BYx�5�@�	���k��ǡ�{Q~�א/�˯�{'�7�͋��e�$��'_�^������)�W�v����y��g��녅Η����]6g?��e묖!ߏ�����ɰ;�?~7�V?O���.N�~��a�<�~�7��Nx�ߚK����Fݷ���dn<�૳��̮�d��Cr��Ὼ'�ѱx�T>���6��%��>$�q�:C�Z����?_�x�?���      w      x��]�n�J]3_����`?�M.�s(QE�1��!��de��o��_s���J�\�j%@�jD����t=�a�]�Pu��j�Yu�|��e�P�}�����C���?���C0����eɟ�g~��Of���Ҿ�]��y���gp>/������]5�cA�����i���ݏ���?��
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
���ɢZ�����؃&K�/D�dp��`5���/a3���O�ڋ�������/mrܸ/z��g/���X�ɐF��vժ����K���[;0`��������I������O�:P_YLf�����T��e���Ff�X��R�q�p3h�t3�p~��`��Y��N�v�,��t�o�����M���*��S�5��;�߽�O��^O��^�M"���{{��=6��<)���a���R=d"�%���CKy@4���.���馒t��Z�^��օf��R��r�-���]}.�ϡ���[�2*,q��{����u��[�����ej(5P��¹�i���s���j@^,�>�{JQbv/�^��:�;U�)=�v����5��'�|���#7���P���AgS]��e�2=t����]0bJŞ��yFD��W��@�ɂ�0�t�_}k���(�3�5&��ߚL5n��O&B�??�������QT�Dd�H���C6�;#rq����Gdu	YŃ6����΁����a:%-9�E�z��D�y�|DW��=�'�>��k5=�1җI�u����=�A���{Ę�nX�S�}E����;_�I�q��4Ú��?���L+�⿥6O�7�����IG��l��>S��*F�����]�,��h �DY,�K�	Z_����V�}d��*7���Ez����L�䪥G�s���?>}��?��      {      x������ � �      }      x������ � �            x������ � �      �      x������ � �      �      x������ � �      �   �   x�}�Aj�0E��S�>��Xa-b�[�)�B6j+�q�m�Az����*�N�+���4����X���no�4�r��L��&��vS��cݬ붾���D����b���lf��%q���,�ٔ�DI�Ua��Aw~|��ǝ�������G����0���1�?N�������w)"J��&5;��\ۜ*cIIQY�d���m�$�$�R�      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �   �   x�]�Mn� F���`43��XIS+ƍ�y�u��C�`�?ip� =>F��H=ƽ�nȄI��稧�gM�u���ｉU<����+g��Ua��WD@��Q!d!`eůmxcj��pM�7U���s�y���x��p�"�P�Uf=`���!dV|Z؃��8�^���9~�^�]ΗN˥�ө��у���
;��TeD"��j��V|:=�i�_ ~V�      �   �   x�mPK�@]�Sp&m��rG! 1.0�=�g�x/!~_?y��i	�ݦ7 D�`��~�d����}��8��D����$��ڂ�F]A
��@�Š�?��<�)t�yjRC)�6�!p����е!�G_A��~����/��q�w(�u��aC3O�<�Ch�O�d�3R���U�oX�Y��Ȳ�	K�AB      �   D   x�3�4�tt9��������q�9������u�ʅp�pq���d��p�y�~�~@�=... ���      �       x�3�<:���3�ˈ3�5��1ҕ+F��� Tk�      �      x�3����2�tr�2�t�s����� 4�      �   `   x�e�]
� ��ۻL�����N���c�o���M �7��}��)̓anY����%�bг��(��y��O�{���R�X��9����z��~Lp0      �   I   x��I
�0���c�xo4�&Q!���C�Z�5�׈�<^Y���s��'��^�0�R�yˋ�v >*��      �   ;  x���1n�0���k�{N��.�0P�JR&���|��{50�}~z��2D�����?��v8����~��w)�w�����Mq�b��`R�S|s����/������|W\
����ݱ��]�����mZ]��КRm��,�V�n�Rm���Z�#n�����6��G�'�����`�)�����b�2�����0V�/I/�p)�*��#����.�8�4=:�X��ք��9�+fiyZV���2����ieX1K��ʸb���V����b��5q���2�XZ�V�[iyZVl��ieX�����qŧ���� 63��      �   7   x�3���p�v2��@<o�#@<c0���5X!�����$hDpc���� K�$      �   +   x�3��s��9�!�U����ٓ�!�~x���k��W� #6�      �   �  x�}��n�0�竧�� A+�i��F�Z���)�c��������cWk�f��z�Đ;��<��^��8~V(��2Ef�|c����8yQ&�+.ƓJ������q�J�g<�KYT��'t�a##���������p����Φ�Ŕl̛ }��		�HH��98A���G�r]�K}�t-u�Fb^�"C��S1�-1s.K��q\�#�.>��K.�#W	���lč�
]���LH�~����\7���5S��)���X�\�C���*�M�q����"���6�@��s/��I���� �����:��g���V�����ǧm��Ul�t���0��ɠ4��g#����r���,�U��Ff�O߈���BUiY���o+[��7Zpq+�\�S�!G��r�C�Wj��~���j�þ ��4��J�͙2�/1aלP/o��ӥ$���z9�'˾�[��>�<\Z��4ܹ���x��u��eY� y&UP      �   $   x�31�<���1���#���q�44������ �	$      �   -   x�34�<���1���#���q�24�t:���.������ ���      �      x�3�t�2�t�2�t2�2�t����� $ �      �   0   x�3��=<�����Ȇ`.#NWW_G?.c��(m�yt��W� �|      �   *   x�3��
q�2�<�!��.�����
�!�cW� �      �      x�3�<������#��]�b���� W�      �   *   x�3�<<��5��_.#N ����e��txN�?W� ��
�      �      x������ � �      �   3   x�3�tr��9�!�?�3Əˈ���1������5�<�! ��Ď���� >$a      �   F   x�3�tr��9�!�?�r�t�S>�!�1�Ȇ��|\���8=�<� $��1���!!G6�h�1z\\\ �$_      �   %   x�3�tst
:��ۑ3�9]\�9K��=... �x      �   i   x�}��	�0ߗ*�@+f%�\���Km֐"b_��#���ݙh��)"�%m��V�%^"�z�<�J��[q��H,�T[�._��/�����Yi����[zc�	3�      �   :   x�3�qQp
����CGf��F���\������a�>�A�����qqq о�      �      x������ � �      �      x������ � �      �   J  x�œ_n�@Ɵ�S�	����>.Bq�.5>�=N���:��P���Q��������wX�-W��ڭ�4:�����GU��yQB�?�ݦ@��G�p��p$�l�y��b��х3HRHy�J��<�#C6c�j�\��D:g�,��[9�P���E��w�^A���eab|��ʜZٙ�ȥ�a׵�O����'�դ���\Yϙ���s�td�̣�ۮ����������i�5L�/>���|��Eh���\�
����L{����O#�ń�������q��h��d��L��'})Hvo�%A%��2S:�3�g��ظ���~�7�%�      �      x������ � �      �   =   x�3500��Ã�L�	+1!�Ĕ��] %f�M1'��А�6$�iC>����� ��NT      �   w   x�3��ON��2�<:�4)��˘�7���˄�/�81��ȭ<���ˌ�#�*�(d����[Z�e��xd~iqI~1�%�ke��=9\���ٙ�\���މ�G6YF��E�9G6fs��qqq �;#�      �   P   x�3�tuw�2��u"G.cNGoW�#��L8��"P�)����]�}B��8]������9���s�D����� p�      �   �   x�e�K� Dד�T����t���j�UƑW<ylxb��د�@��>
��IH�t�(S�o(�}�x�
�yA
k�l�EA^���YƷQ�z��?ڳ�����2�fl3���J����l�5!�'Sa�	��f�8��b5ag�	�M�6��N���=r��sU�G:���k۶/*܉�      �      x������ � �      �   �   x��ӱ
�0��|�<A�4�:J�J��N.�J�-��E���̡ .���QE�WVkq��G#��y��k 7��ũ��[�e!�TP\���غ=Tr��LY�L�3c����܍��ԁ\����L5m�D���q�	������lm��&����q=(/!I���:X w*���>��0|��!�ߣ)A�nS��=�"��r�ߣsTE�5�~�� c72�=�(��)s��I�,�����!q֨8x��D��i      �   S   x�3�H�J,*I-��2�N�9��˘�p{b�����I�\&��@vjnR*�)�sin"����1���24�tK-�H,����� -q      �   h   x����@��L6 q��p�/�%�����5Ѓ�zy%<Ǒ5Kg�X���Nqf��\��<C	�>��$�;��y_����S:���s���_�k      �     x�eQKn�0]�O�T��4��" �D��}z�.9���^��v3���7($�h�z��ָ�@�n�����f6�͎�[ �0�[�be֋?���L���f��TŤ�fbg�2�IJP �v)����	��@��h\����W;�;3.��\���_JI�%���O,�07�ҕθx��PU^�Y�I�C����():o�-?�09��Pj�\�b��"�M��]5S���?~����t�����;o'7��(@>���RL�u���7��{      �   �   x���
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
���[��g���b5�Vo1��z��`J_L��Q����q��ի��q�      �   (   x�3�9��(���T�� .#N׼����W?�=... ��	�      �   4   x�3�r�u��2�t<2�3��ӛ˘34*��'ԛ˄��Ȇ�#|�b���� �[      �   �   x�U�An� EןSp��;���4����lu��`�����R*=��|1��J�,��*Ǌ����f���_��q9w5t5 ]�=/�]��h��C>�L�k;Bpo�=���s��M�V�iuP�A��ۊoĮG,ɠ�j"�sp'1���8��ZV��@�}����#5���t�S��?��x�m�����'�P�^�s�<1O�             x������ � �         �   x�%�;�0��z�.��x\`�XQǱ�6�4�Ѥ�ؚ�$�#���i����<{1�8�~	,#��s}�OR��T���M]b�ӹ�&ڡ��(�L�Q�<�C��ZaӖ�.����t��3�0�      �   I  x�=�]��0���U�
FM�$�����w�������<!����ל�$O��ı���,��]ӺyM$r�ʐ̔�����y�$D����:�L�Db���n[�	�6�jIX)i���#U*��fj;�\��HU�K�x�1�o3�<mL:Ɛ�x���>wE�%�n�_wW恖	�{_�ҁ	!�}?�"`�"EĞ �騴ԯ��+cH���'=���^���
����xȖ��_<-LJVV��ub����?O*L�IȂz7�?)!n�����#���a���Ya�A�D�������y���C����Gd��J�mv��N� r���|�nE�����G�q�ˈdE��ţ:U9���Y;�).ʀ 7�I�
B��7�A����7/T����ްED%І6-d�����ح$�!���;NkO"�њ���~��" c��ݼ$㓦���ѿ?�+��*q�{z?Z��te 1�8��l�f�#�2��Ё;DQA˙{��։/�0~�N�0���g2�������:08?\��:2B��)�I� �u|o�'@d%���gĔ�]y�ze|���mq�)�P���D�Ti/�L*�F����M�*���ꧥ
Cz��0�
�A0좍�Û$E�FӅ�4��"i9Z��狶U�Xc��{�H'� 6��6��� 
C"��̶q7ޘl\�X��g����m����Q�¸%S$��^�� 6��װ^L�H�����q�����Gytz����q - �e�j�rr�X��|�b�! �B���
۰َ�!��P��5��[I%^�7�9�&�]\��1�7���c�}�β�?���         m  x�mY�r7]_E/�*�K|���6�~�&E�l$E�e��"Jv��Tj����o��Ξ��so�AJIʉp���\pJꔾ�#SE���SS��hH��~��7�#RF�
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
�����͗���d@������f?9�0$��S��W�s.���͛�����            x���ɲ�:�6����e��p8��l�ʖT���cȮpUn�F��4��X 	&���������<��Ll����?������2)օ/;���m�ƅ�c�����=_�ߟa%�@ �@ �@ �@ �@ �@ �@ �y���}������6�o��O���]�Ͼk�� ��ӷ|&}滳m^���Gy?���Ju����V�����;bC�������aޯ�>���U}�ۮ��1��\����O�A��~��WQeI�.�,�=4�R�o�c9���5uM�e�o�(��Um��\n�ܾ��u�����;6��.KRu�o�29:�?���xuo�wڶ񎌻��?���L���g�O������@�JԾˋ�,�.[�[X�.K���eY�R�~.�?��[��elC�-D�'sY�5㷔,�X���o߭���MY��c._g�2^H/�rڴ��x�gm�G�֎eܱ��\�����*�-�We9�{�G�;���u��,�j{��˂g��mMe�;5����ٟ@ ވ�UO�ڊ���겴���Z�V���?�5=��ښ�֯m���g]P�=z'Ĳ���@��mh�}bv����)������J="O�����Kφ�m�)M��Z����ԥޒ�>���֣���z�scy]�^[�����e?��냟���O�v�{\?��]���Ө���U�8���{���c?�=�8zE02ڴ�����f3���O���R��j���ѐ7�ёMf{�O�(Kk[ǃӶu��xpr�g���u�V7���Ow���F��L+S����3>iǪ����_I�@���xhlZ��f�2�{N�,�\3����.'�1(��aQg�ۣr���z�kzt6ƑO{e�G�y����O��[Q�V�I�޷�	�x�;[%�W�ә�
��V��FW��ζ��lG�t��z0���[�@ |�/2�F��߾��В��4\p͌q����Q�7����z�;�J/p��FZ=@�M��%�9�����|��Fezb�[���ᎌ\v�^������+�����z��dl�8K�k��@ ^��}D���*�Y�ԏ��=�q��Gl�T�魑�$�|��+5��������*K�3�Y����3;=x1��?m-��$��Ԫ�� ��	uyb�A�{��hz�����|:���m�����$��艾�l��=��>m䗞1�=2f?�:6
���E�./�ȼ�.���8�y���osa=��9i�~~�>јm~��+��{��xo����k���ʏ��GJuf��V���]�ޗ�dσ�u�׌���TL=��m������m��3�\6�*G[V���56��G�g,~ͯ��[�i�t�Eu�����|2oc�D.�hkE"j�_��q}�Ȟx�cEv��k}xF�h?��̙>�/�|�G�~,1XJG�b�xֽr?��姙V�@�(�v��=��7��᫽u�V�-���)�	"fvŦY�غد��7���R]��j�����0�d��#��_n��-v�S���1����7������xw0*��#I{�q�x��ǩo��,§`fq���v�e��W��3�2\l9c��B�Lޕ�_N�wy�U�z/�h����!~k�F9��W������|�&�����Rn�O��|�Q��=����G��C�-��'3�D�]�@ |=�{��ꗾ�~����/l��������Yw�@ z|��=-y?�w͵}�ܿϽ&����-�>d֪�����~��z-����<�_cax-�g������Yo��x����}����,�������yl�k�Ϸ!wˬ�����^|���5X��~M���=�����q��q�?ϊ�k�
���!|7|�u嵌��O�8�}��_���y�>���\��=�9���?��Ć����%�g?��"4kï=��Z�=���Z�>�,^���S^o���J~�x�m�>����ޏ�6��-������������m����������B��5�l���H�l�y��{��+G����>|�6�g4�k���s/�G��6�v�L��1�k̃a�<�,d��Sw�����|u�Ϗ�1��ۚ�Y+1h�sls���L����`�̷yjWf��d�����B�������:t��~�ݜd�l`&����׌�}��W����^����]U|���zϯ�^���{�V�����*�ޞ�_����H������D���Or�f��T|OU��z_q����
��Y%��Sy�"��&[_4�m5o����g�g
}&�e��É}���:���_�͊w��ބ�yh5#��֏�K���n]G���qP�>�zm���i~o����DKz�9�cM��~)Cu�iM�n�S���'�t�����_����x��f�j�o����S��^���vw����������c�����o���y�%c��Y6����T��Q�nU�#]��3owd��k���`�����:�k�	y��O�H��v�ݺim��k6��}����g4{r�G�`�+�]��.�g���o��4��ľh�y��y�g��i�7쯺�{�w��������=�m���٢��o�c��U�m�\T�虑�Eu����כ��<OG5���	�����*�#�:��5y�6��X�[$��K������u(��Fw�ϟ�l?O]�z�����ٍٛgc��]�X?����� N��m�<������8�{�Ɗ��v�����di�5�	�g�f�����9���R�g���-�xG��~�-��\�W��ڭ�D>�Sj�XK�Bݏ���n~2�څ=���y�	g�q����/<o�������O怩��_�~���og������O8nӏ3���}�%����L��s1{�޶�=�2�Ft��֒v����*�a�'��ք��W\��X�L��UB1�xxߓ��赖�{�p?S�F5���>zp|6���t���7YGO��9{Vq|��rq/�0�[�_�Sw�y�/?sM�
�#Ё��,*>x���<ν���1��~��u�h��Ы�㩧�W��i�xb/,�Op��>gv��E�v�y������l^��
Կ�=� �v?�4��zt��xp67��8\����~��˅5������1�O��	��W{�+��γ�\l:��ue����_xƞ��*��Ώ�.������3�Ou�K��E;���}]N6��(O���Y�z?�n���T�p=�Z���KM�=��ey۩�X�YO5S�?�O�	����W��!+�O�8��Xu�vv��4�3���S�{�B]s1J�����c���޶%���O�+��=���m
��Y�	?�|���Ń�U�y���Ȕ'���<����;Fܴk>ј��|�҃O �dg����¾:�/�������f�g���o����Z]�s��N�ٖ��g�`����'�E�1{�?
�w�f�Ƿ��]<8�ì�OX3P3^0�g��^�۩=�}$�̲��KLy����~�ī���3ۘh	`��"����3�6�D�Y��F�|��iw�+���^|�0#�'^:����_���$�xb�����yégŭ���+𗅿�iT��k��\.�GA�8�塅M��F��L"z�3?����(��f�3{��r��cyp��_�zt;��L��,/�slޞ�R�h���E���g���[;/Mԡ3������r5�ei�Q#g�o������-?�t�ɷ^x�'>*�8��X�#ց���_G���+^0�dp�>f�����O⢟�h�2Z���:n�q�!_�)���Cyp6@f?m�]���m˸��36�Xv����q~�4��b?����5��~MK�|����0=�=>ۦJ�6�=o�[Ӄ����_�������y���3���\��9{��H��[�z�[1;����y5L�<�gx��z�]��<8�����Ȫ1�M�g�|~�Ơ��i�6�C��±p�[{�쮍m~~�6�����j���o�ك�=���*.f���j<;zo��t�yy/g1h�\i\ظ&�]�76�;�TN��ޥ��\��;�A��Ϥk�,�|�|E    ��I��I��껻��Qگ��t�M{w�>�~v���(��͢N�vX���=�<�o=����s1{޶����3��誙���W����+ �t�=kv����+�6�u@̋菋<���k�~���G�����f��<��P�����3���:��m�'F5���Y�g"=����f�2�|t񅊧.hW�f�ýU|�O��I�>�L�|�W ���]O���[��dn1���Ճ�>�H�8��F��;,��W���zh��G�)�wUI��fݙ������4/���Al��:ڝ�슽:W�x͑���͸%�יM��;���/����{F����|gVٙ=�1��vo��3�'�i��K|��4q����:�l��p��A:����j��*���n�A�����@4�Y���<�����>�Sx��YGG�!��*F��kmn�%�b��G��\3�y>�1޵���=�o?���sk��T/<oĆ�n��̖��C}p��L�����6���k:�;�u��:��H��+cf�k��M��Yosߒ��`�����l9���3�M8ɛ��8���f윴VIs��\�]����,�1�e��gܲ�s���=���I�"���~oL���gߞ��i��Z=8��mO���<8D1�������Uz��+<c�[��쾴+�Z�j�7�߼�����A#�YM��<�o��7��:����U1>���0���s�yl�~��e�tt��}������Y,��s�>�OmI���縫%p6�{��d�=.�٥���{|�{��e�~fF��އ_���+1ˊv�)1k�E�^�!�5+���ޣjƖ�����(x���y�����3Ϟ�S�]�'߉�W3�%���&�C�u��7������d��u�[x��9�G6��_� ��f�ح���F�'v��vV��y=8���	�����S�<{O�0��_���m_�6K���8k��:�כ��B�F�k�]U%x��s򂝇3z��e��.��l�}��ln�>����B�o��:����gh�'�CY�G���z�cP|���r��u��H̼O�=a6�x�_{_�7rk���ɼ�=���.�2�Wb��=���9�W����f�nK�3uE/��,�~U���zSo�o[��Y6��n9��^���<U����c�'�L/��+�������5\�Y���k��y�<�3E<?{>�ø�Z��i�%����k�Bȿ43B�JL륾�f�����u�^�Ģ8�g��|���Q��l8��{߫�_�3�5�����)���W'o�����#�^���o׼P#��T�~��O���5c4P�.�P5ϮF�?񄏕,f6�����ǥ�E�r�����<c���O��I�����y��Ë�~}���J�|��n��2_я�O~�#&��>������4��iwʉ8�V�_f�Y�h�>�>�W��3Ł�Җm ���W��ݳtz;+��u����I��r��O��B�8�[[؏sZ_�����v�8�Q����R{m���K
�����gvͻ{��}�����2>{��b'�#{��{�5}^�>۳��\����]���߶���8�i�3[~�3��-	�@ �@ �@ �@ �@ �@ �@ �̢����竤"�[o��ʪ��ߺo[����)�@ o�}>��m�#�x-�1�l�NUTa2(%�������VW��Ҿ��(qXW�{ޖ@ �3^���J�=���-s�*)���9�uTVX�*�,«gI(��{��<.@�1D��+��s����+��"|�,W�m���a?��%眜u���w|�/�,.$����+����{%��+��c:��rz瞑��%�Ǥ��t���	Z!�j�	�ge��Ё�˅�.��I�uc@|� K�R^�e�A�"XX{n+G��y��Q-�9�M3_�A���;�'��N:� ,f�[�kc�K�O�W�s�R�0.�I�*�Uj�T���za��Wk2��_����&�y��W���y��E���ֺ6e�U����K"��E)�=p�*oԀ�}�z����}�Ɨ�	`T��W/2g�>���O�H�>��Ep���J�+�F�@ ނ�c� ����b�ί�z��L�^X8>�l��O6v�^wv;�ݶ�����^9�*Y�uˢ.�=*�Mo���ԣf�p`�<x�V�@ ����fYfЮ�ﷀ%��R�Ip*�j=[g�<p	��D��P|�J���6�ʪRI�ת]{ݔ&�'J�{�UQe�c�)��\.Λ@ ?���z���7u�q}���Y��Ptٕ��Ǿ��wK��zΣ�"�5�v�+�<x��-֩�����Wp��&��g¦�^C˰�"��O3,6��������l�O>z.�7�O�Avx�TO�TRq��*n�z�@H ����>����M���%�@0A����"�b���o�OY��j�ܼY�`�|�k;b�xI<��+[�յ��r�@�}1d<1�������c=L����V��?��k�����1,���GB�}���~=��KyP	���b����䥗N�,+���z�cc@�DӸ�[��u��@�EXZ(�]��s��ng<�t�_����gb��H�,kZ��?i�w���ykPl��dx-y>m���M�/����]��ί�,��@ ?�,�^-j�ElQx��0G�],�kZ�

�d�̫-��5���5,^�����'���v���eE����.Zg*�Y<g�Y����F	�����e<�_lF5W���i�:3h�[�\C]��I�Gh��:k��m�1<�H�3��UsT�h}�-��}�z^�i�I&�о�qYD	���c�n�Rr����>x9�F;�+����^�.�[f�Y�܋���/���V3b=�<"'>d��i=ӝ��l���l3��Dn�"�`Q�t����k�k�[eUZ=9/bC�@������j/dn�|�<cͺ(K�A�Q�M�]��jnF���נK�ܖWd�^Z���Y�l\�5&j��u8�ѣ��l�[�ؽ��`~�e�c�W�	ɼ���I�*$��,�Ȃ��w�������)�������<{��+���`�uF�%S��#��z�!���F:�Gw�����Ƨl�N�^y��`�2Xj䣪y��[*�@ �&���yU#�M�,��E�*�W��b_��y]���]�Iƨ��J�8�+��C^��J��p����˦�l�}E���^ž�I��a+<3	�5�0�/1!�@ �|䍷.��]c�*I��G����ͱϳ�hQ|�o{����^��ʕ��h��c"v�'֡x��ik�YH��Ĝ ��EX���z��5�}���F���e��@ ~/�l�^y�B��nq�e��� �-�^�/_�э�&f�y�F��@"昭c���x�ti�^�5c?�`:���n�$���OA ���KO�~E�Aԃ����N�z0�v���3�b�������,��",��fQ3��즦f~s�ץ���P�T1���ǿ3ϟ�~>��@ ?��z�U�k�ȃ�=��4��N2��"�2l��,po�������6�*I�?��obUݶ��?+�@ |�5�%jo�E<=�!EH ��̓�ˁ��K��|�$$��x���M�r{��c�� �@ *~+,`�.�$��Q^%i��e�5�@ j�H��b�8�	���(����u��	���#ypo�vY,B1��9�֚ ���@ |[��t��1���	��.�޷�ԡ��c>���q�_ k͈Py�eW����cF��k�x�_�MϚ@ �T8�\b�O���z���l���M ��dy��%z<Ț��C˕�<�V�������:��J���Ss1�@L��l	�O�3�AѤ[�������t�zy+�l�ߒ���j��uǃ�Ӄ���_�7J.��-�J6��*�8�@���vWY��MZ�*V	���j�+ߕݱu,��Kv��9��l�eT    �0?+�J0A�BP��*�֌�2J'd��ڼ��{��
�����6%���}��{�@�6�-��b��x���R�����V�M�*Ȩ��r���;j�j O&�wV#��1
���n�� ��<����
��pM����^�<���|��?�:�o���_��i�β�
��Ex�8KA�l�iiۨ� S.Dk��^�d����;~��R���f׃X�^�5�&	ЀAk<+��+3朡
���p���5�R �#�[x����J	�]�w���58߫��x��)�~N�ei�\
��Y)��(_U�/��CV��ayU�ǔs�g��F	���pp_xʕ�b��Ŗ��)�,��u���,����K=����Qs�dlyɶc|wD�v:�r�v���Ԯf4L�,a<��fʲ5H�SZyv'6|�E�@ |F[\��?����9������r��XG�ҋL3�h%0`�5`�"�=�g��I���T��r��a벞Y#�/����d�KJ0!��+�3`C,jQ-0(�-�Ú�4�q���N�X�f�+0F���3
�2�՝��|n鴇x��N��gF�'���E��w��P�C#�ޓ^G���I��2�!���@%i��Ȓ�J�ZIDP�ZY�*���k�?���e�M T��,T�	p,o�~�y��NL@��
#0�Z���W�R9!�e�ȅ��4V�XlȠ-Kʇ����s�[M���pY-n�xX��6�hr�R�C�reO|������(n�@�x��ꌄ7/@��&�.c40����G�gKm��rH4 l���_����4�Ǚ2�)+C�_=I�Xg*����lc�c�1�d���]�\ݧ@��s�[
)&�>2�՞?���B��6#�����ϊ����p-`�Q��EvQ)`C�r��(3�	�p��Ko��Ú���j���%q�UHB6�'�q���u�6�$�ކ��c:@�,�N�D����Zɀ���3�k���|e�m1���@�o9��'}:�1o�5��҆��}W��8� �e�W`=���}bԞ�@�F��8��qy�x�O�c�J�	Q#�u͐#�
�뀖�,5��<�>oU�.L��|���X��E	��7��,�<��-�ۡ�G�#$n̲����B<�@�(��E��E@��޸����F+�lz2H͘�^=Cϯ��\D��b��\c�'h��Z�Z8�v쑃��}KY�w��#/��U�ش�%psI���g�1��Ȥ�����t�ݚq��cCT�Rh9[M���T߅��B�}�r_jJ���Z���m���Kf���u�9��"J ��Ȼ'�f%��gpf�.Iz�|>��U}U�������%k��F��!)�F+q�E��U�xt����{�Z�ȃ��_�%5[��j�����e�1qPWZȄ����<<���#��^E���j��q�Vaa���[[�.��ﰝ��
�W���6\0�6>�0��{���g�&�?�2X>��'ḱ)��S־7�88��@����\C�+���-��{�9m��ٛ�-�@��/�g]�Jf6�|_�?�B.~�����<��ٍg��1D�̊�>L5ی��HQ.��(�q���Z��x��}�R�3`���i��j�^4ܩ�M�a�q��{M�Q�@�cg)�SZ���2o�q饙r�ZP�՞\��a;��qҋ%.!ui�{���?/�
�'DlAp-e��E#������X̦,��ǈ���X��&�T����3�����u&}i��������3��X/4_�Tgfˬ�U��#�h����!_��̽7�]O}�i��hߚ�o�w̹��qڛ�	q��ȜR\$ik|���mPDxe�)!RҩdT��H�y�et|i���SXh�U�m���zԴ�\����9XJԣe~3qQ�^���<j�%��i��:��a���חH�P>r������x�@ |f<����Y�_�_��9�|b���ǭ��jFD+��k�oK��=��Nt�-"����Ƞk��'�Xt��3��]���3���L2����@ �r{��UV� |�ҕJz���0��t�RkN�MYW\�(K�E��i�Lmfз�5_A�Y�=qv�:G�@����1�˱��ٝ^{��X���۬rn�^t
c��x�+�Z,[�i��z-��p6�I8?(��F���g�};��Z��tf�V�jƶ�m�T��Qg��t����d�I���Iۼ��ڏ>��)���@>��� �дװ���9]�|���3���@ ����k��~l~�~��*Ŀ�����uG��s��������5��-%���L�E�tJˍ��S�ڃ�����C�������$c�H���'6,:�֋)���/=�����Vxba`C��!�r`Ö���������j},ܯ-~��A�����J3��m�����j<����y�����p�l���ש��!�hj<k2x.��<i9�
F��z
��tʾ�~�Ge��%�(�Ѧ�o�-���ĩ��T+�K-�(���x��n�����Z�j�%ZJ�6dκRţ�V�#)��z)}X��ց~��=)��j̑N ���E��2����D�x�}���.vlN�ُ�ut�T+(o�kS��EjLSl�
��T�G����.cKθ��x�H�^����^ĭ�|n5�nrc���eZ{*+��]���j��FZF 5K�b��\��e'oR�������:��R
���Y,LH ~%6�8Y�"˶�N�vI��\�5�e�;�-��:8��:�.���¶GF�̔3�J]}�K�$��a�?g�Ц������^�I�>�7�[�]ɶm�?q��Yqe���&�̿T	�H�K\Y�j@���J���Sgf93q�#��w4v�0ﱄ%�h+��G
ߓm�@ |F��~.o�ԛ̢d��(2.�"Kve�C����AyU�sܸ������gڪ�64�ȑY���ζ[�v�f�L�P���5s[�z�����5�<���2NN:��1Z��p�a�]\�f#U��kC�Ə|>&#�Z��U���F�b��!�s���<��x�;�#�>�Ё64!�R�ݳ2>-��}PX�G�c�J�V���|�x*a�4T0.��[�VfD��.����-#s�',Qf� o^���F�-3ɖͲ�=1]c�uՀ˞�Z�B	\��VN�A��~=jͦ�U�Z��-�-�l���v]Yl���%�<�u��5�s��]��]��};N/Q�5���ce�w6DK��kH��ޏ�c�v	�sp�k���,��%�O�*�R/��e�����V��`@�JY��F1��>ŝ�Sn��g��f���y��-_(��"oY��G/Z#�M2Y{�D`y���E�Y6�V��K���x�Rw�w���Y�9��<�:�L���g�[^l�FD@Z����B�l}�=�Y��/CKy�	��6Z���?��h����W�W�=���e��S���Vɮ׀�-T�^1+.)�jF�ꛁ��Ui���5/\������Qa�H�`.�ƀ�AdJ��e�m�5�X�DU�S�x
�����;��b����a�ԫ�1��2{�֬1,,и�rr�m�aX�LrA�Y�G��+���qz�:��wm&ї�+��;!Lpƶ������`������>��^��YxM|��`��[�8��Z��-���ּ�Z��;�T�W-fTNE)r�yvy��z�w>����k)L��P³�1`���{��V��E�簂J����6��������w��_�#^�T��>.��H̶$ q��L�]�Y���YłYC������jի�e�گ��#��A΂
���:W(j\�/� �VF+8�J�,Y�!�H��|�=�ѝ7����gsceu�1���m�m�V�YQ��Rf��\a�=g6?R�/����t�u�+&��+��ʪ=ZM{��66&�C����+��͂Ҍ��B*�W-z�4��Z7�K/��h�������;|�E�����b��,"G�����D�d��V�zr�(�:��)J���=^����gSH6	�����Z��T�s�+�dɂ.[|�    cm��\�%�!f�������-[c��ح�8��X��1�}*�GT��0�(@S����+%�`j�v��}=���K�A��XB���D����^j��u:�ε|A�hS���� ���y·�]�����w�^Kh��J*�07N��a$��>@�
���o-�(�p�->à)����L _�y��u�y�k��F觜Ӻg}���"� �	��h�Nѣ�^���3���i�����b85[L}�e�V��X!��a�J�JI!lQ�-�g�+5�ڹ��h�5�o�+��8��V�n�bC��Me�¸�j)�ke�#��EĔx���q��9��@ �\\1�aɫq�"�h®��AV�D��m�艁����^�{�?���kq�g	08v[�h��%��	����Vg�ź��G��e�ت�.T�jU�q���x���{ƀ#ό��F2���V�e��{��S/t���"}4��XyP��W����� �s���UI�j��ܡGԼԌe���LΧ<յ�M(�x��w���eA� '�L��Gk&���Sj:пN�alPJ�K���n�?)�T�F�J����8����Z+*Ƈ|k��|� �Jpݭ�CQ|JKnR�9~x.�$�yZ�Ma}���i���ݦ}�{���G��ux��*�?������4��qk��(2B��ATF]4�Ĉ�⬿.��s�{x��.�y��,�m�YR[\Pl1� Z�����{���Ua��Pʊ5�\�?�ϭ,5�_FY<�*˟*j`w�H��v��>���F]���-�0�E��]�8T��%�E٬�%�פ�%�:��]�����S���ψ�?{�r(Z�J�&���sdY}-zP,��<�X ��扡x*�|_��"A����ˮf�/��B��ʋ%�F�l\� ���^(���Ig�X���FK�K%����f����W�_���q��kn����k�<'v�E��1�+%.J$>�#��x��yYE�7ճ�6
�@�l4,��]G�[��#����|k���J�b4D�h���ҁ�@����h�~��>��PL����G�*�9X����.Q���J�Y���g���e�:
[<f��0=�^���P�2��Q��U��-k+F�\Y~�������=��6G��Z�h9�X#kL�kX���%qY.��U��<�O�B �d����n��i�x^��?�u��	k��RQ����G$�q����#�Y���3{%�h����1����R��z�
LB.���U��.�Nz�Ag�@E�Vkx��z��dV�~���o�	�jw�A�I�͜U���k4�#�s-{�Ⱦ_��@�q�6��y1��&��5<9��	�|�uZ��f���kD�B���=s�ٗ��^�uȬ�������S�9��:7�1�sɪ-y�=&�����~�_�_	��rNhak]�R������,8W�g�WI�:����
*l��=۪8U�!u��6�uW���/>5�f_��F2,Y)=z@�Q�1�2��5po���R�-��C΅K����Ǽ y��_ɛ�.�_��}m������`��v"G`�_=EC
9��c?K(c�u�E�9�X�Bjpͫ��/k�Z�<l�B�E �43%y�6��!�Ps�3ϧ,��j�d����r-��Ң't���k�\o��U)�銍�����y�,���f�@�B@�ث�c�m���B������W����A��`����c���6�]��7ǲ�(2g"U��J�F

��h~Dx��KB2�?%�C���S��X�����멗�,��c�s^�u�
S��b��#u����9֬����wѸE�ۘ\x�K ?���A��S����.�s�b�]��#RͦR���'�W���	hD�t����������mjc��e����"+ޕ����e�mF�ԥՊ���dm|�%5��S����Ę�M�EVV��O/�
��K�Amt�A�y7?wt���z�I ?�_��I{��c��=a�xP���*.K���y�Xg*��ǯ�����em�鷺�5C��J{���3V���sJbͩ}����1�F���4`��y�X�:�h���<'6g���\�C!��z�2F�rf�T+ё���8"�5y�I1��m�@ �2t��2�\�=լ��f=��;���z��R��Ckc��OƇ�rk6�1�3P�:1�d�J(���e-KQOT�k1�g��r*m��r�Œ������BB��"n�?�4#r�1�h��ƃ��L�~2,���>S�vr��U0D�+� �@�=�{9�X?��q|��BkF�m�3�0�0Uɵby@��S܄s��/�y�ϩm�ez,'�NK��P^�5��T
4�6?���ʙ���Ӫ�Hm����8�Y
e�0��,r���ݭ>E���vג�u��0�g7�/�"��s�fW��b�e�wf?f��y�$���.�4�@ �Tt���A��Y���^��ˬ��E�%0x��p2y�,�#�$K��7��Kk�+,��qv�f~�x����ELH��m�e��~�bB,n׀i�-��H��zQA�h`�=j��H�>ŕO��_�z/�����r�Y�eS��8��W���;�jU�i��ӱ���9?�q����43�g��ꕋEY�b����W-\�����,,���3����W��8�A{/r��4o�%�x�_,YXKTݮ�k��A��`��0�0�ͥ����}�竲ZeX,쓮�>���Z�T��d]^5�Y����)�L�6�%u�H9_���<��E��Xe@�rk��FK~Q����ÇG�Tr��\־�3U�cE��3�,.��,�0���zew�Z*��ʉ-"�T�����z�%n1&U!H�l�:+��)��/V��s�^{�>'Ҥ�8�M-���^�����y?���G�6P���L��{��-e�A�*��n2k���E��_�ui%(��2��ko�>��#*K&z���g����%J��b��#0'@]���A�ye`{%�q�-��C6�-#kj��u*i�#��+�U	���Q��"��S���e��Y¾�����2�f�-,��ù(Ƌ|ݣf�ѣ82�'_,��9��-pe�*K���C;��A�ѕ1���#���?�AAx���� ���lvN����V�ޗ�Qޭ:I��jx�aM2����Y�qQ�\�2L�5����[-~�7AU��:$#u4��<\��kO�Aϊ7#|�=9���"ڬ�Xe��a��p�V[�ϙ�w|;/�J�pF<H ~;\�Xr�	5�Eͮ�Ά�>y��;d�n-�Y�̙v�[�*_�~;��A`��b�����"�B��?������5u���	����C�+)�Q�q�����g�kVQtb{���*��ʪ���S��s��h.�@�&n�*o�DLP>�v���� ���3�0�w�!��lV��.S�@ |6�ٵ��H�i�+6��"�W�-=dU�Bh!��'����f�e�ޏ�Ag2cCx/�\��K.����{�tj��ٹo��'������<y�������N��oS���Q�S|/�5r�aa{�����S��Ķ�G��mJ�V���Ko�2p��b9��j��d��{�ݒ\,5�:=�w\�Ԯ��+A(�� �@��PF�g;\���z�������V�V2yx�p_��
};���j��YGgu�ޫ
7֛G��x�\SC�7}AKBP`.��x%x�Ge����/�Ad��*����.�X�,Q���Їv�f�L�w5g�X��*6^�x���sDM��+�r��ϲ{�"F`^��Xv��Y�Y��yUټ|T�@�!(=lXzڤW���l1qG��#w���^�sI��a%�.�j>��cD΍2V�x�n�ܘ�zG������b�:L9Vjm���-~ܟ<^�#|�xI^ �s�5�������E4�i��[Ζ:6���t���c4�	2<�`6��;Pϝ���r��ęA�h�� �^sp��u�sm^��̈́�c�!ŏ�rC ��9��<��\�G��8j���D�	�c��h�ϗ�KX�a���w&7=s
�(���aߢ"p��L�����́�P�E�m��    ֤EX�?[?���gHA�mQ��Ou[S}T��3��Yk�U�Y�Y��t�X�J�ZD3F��b���5f�eh��C&t�:w�f�ZRXe���Q������:	<�hZ��sư����Y���*�������U�������٥V�.{��R�7��M[���Iɐ�*n�=Z$u��:�h6L����3���V�A�����J#�,��z٭���v�Yk�|ܤn��Hؿ��vR�����E�	��hg����AG~2��9��(���9�ŀRm�l�':j0��(���Z}G�Z�}G��� -�]N�}���t٪���jb5�d��mKc�:�'����YӃ�7���X3��B�L{�������2
���� 3�e��Qk�����R[��?W���������1�.:b�׽"o���G�Ԫ�J�}V���U,���Ga�8x@ȪL�d��r�G��7�}���YS�x���Y%�#�X���
�vJAOjO��{���o8G ��GL�,�	TR �_���x��Q���6Ѓ�X�E.<ؔ/�`���qR����E.��&�x�0�`���_��hJPe��ŉ�3����h�����&���������S��x���	�m��.��٭�*�U�D��A�H,��
�x�� ��Em޳�U�:gWu"_\U=U�=E������R��S��[���ټ��<��=����:���J��Q�����`6%JQ��M�n��g���b�DYZ̼W�D�Q�𻠫ƋlXc�}�Nu�b��>��o6�R��{�e��
��}X]J����z���o�aX����n_PZd�/i�N��
�h���������^۽XGY)M2,��m��~����)�e�V�R��Z�ӕ��L<W����������a�.v�+a���)ֈ�4�!���2+:!	o��EV���7��g�V�7��
:P�K�\�rϚR���4V�j!�ȍ�F�����R��cΖ}������,�J�u�lٹ��=�����	2J'J���,��3J��g�Y���"c.��]6Ye���5���yӀ�:'(�9��5�w0u��*mt��B�%����G�h__�@�z���`L�L���@|��K���z���<눇
U
����Ćc�׾�F1�~ɞ_��~��N���Ŝ�{}y��(�����쁟���3��s��[�DQ0Г���V�֬&��}�#����P�U%si���`�<i)��^1���g�����2���b)Z�@ �~���.*�/�%2_�����s��*�~Ϭr��U%&���G�=/��JW�"�a#mlXJ;�K���}F���i��E>-��<*bxq������*�o$��ڤ�^MI�L5%���+��x��}?���w��Z]w���H.5N�q�D�kmA��!�<�)u#�W��0�4�ط�x�@ �tT���<�u1�p�[S�i^�5���#���
�=I�#��*�R���*��j��k�fW����m<R���j�6�o'��LL<-��{�"D�<c^E����Q�Hy�֓��59ǜN�8?¢����ϭ�|����ݚۍEl����D���Z�׌1Ro\w4b>��pU��ѷb_#J�h�d2��]OB�I�}l���"O�7������o�K� k)=�L��g���j��%�[3-d�>�ꏱ��|�c������<Pq�&+^��'I�K��_|�M�՞蹾	Ԉ�b���%U��_E��2���+x��І�U�%_��>?�\���m9�0wz�V�ͭv"�<9�����ed�(k3<[�Sצ�E��1.�@ �}��P��.*!/���S�e6,� c|�Z����կ\���>�*U}'J�5��Vo�U�CU����ֻF�C;J���K�~���גy�E%i��e��k�˫�����kt����*.K��=��a�=ہScC�T�QJ��U�j<Xh����f_�e�[�X��{eT!� �gj��vdL-6^�?kū_��y��.���=ă�E/����Ey���/)����8�����o�ko]N)&o���1ou�s%�=�e�6&���9U�kUf��&�����������\0�c%��хl��l��5;���^ꬳi5��Qr/_�~���\�1ٚe%�V���J��,��eY٢�E]����Qպ��}�]��Zk�1��&��l�薘�jf��3�;bn[��p��ͷ9G���E�?�n���TG>j��w4��$���s�z��y�g��9��V����W�\���1�N@'���!V(���)�W��;?�n}��PM�f��\[=-����NA[E����sT{;^�Y�[�(ou�<K{���#R�b�X[�>����KY�][�e�� #��/�2��[�Ts�����z&4��3ϜjVP�eHc]�P'30���x���}�TW�Qɓ jDa�T��풴�����H���V!g�tM?*��]x[� �@x;���h�ڬ[�=��,O��NJFaC���g�>f��\d=�=[�]�**І����)Įj��°��NB+����]ϣ�1K���0�5z�4U%��8��毥�p�4q�U�g��+Q��n)5x�I��԰��}�M�3�ș�3ș��'����-�'���N��<�2z�T(j��s���j'm�n��RH&Ǽ.@�n�F	'����5O)n㑥�*N\y��עuƀ�}���Ym��o��9}��QOʒgR���h��ξ����{c�����Xɗ7m����V�	�(������J�xa���^��(1#F��(F�c�VFh�q]�LgN�u�)T��.����Vk���V��.��L[uV߰�f���c�ؚ[�3����m�|1���5��B��ϕ�k��3%�>�^[8Ϛ��� 7s­���g�-x8����	q"�@�Jl=��~��st�F��G?����w�.)�g�hJ�Z�����l{d��3�T6\M.���h��uK"�/u�KXp��>z	�Vvj��ȗ�߾z��=��x�T��d��5o�����K%�����Ta��^b	C�%�����2ͺ�]Q�vu�]�=E*U��ZG���j�U��\ټZA�e��-�v�K��OUN���ڏ%���Z ݖ���H�-�ga8���,�NL�$����c"�@ |.�q�������m[�Smeu�	���C��t�%���aaC���
��1�u�����TT^X�Wd�J*��}��-kYP^h\��J�R�~�rSx�Td0l������,ۖ[u�/W*1�`��Ȁy�Q�an�d[��:��RV���wGYQ}N�8�ӱ�b�<�����Y������q="#�Oaܒ�U�Oq���1�q�¾m�6õ�k(IٷX��3 ��WG�@ �#��V"�t��﵉ɥm�Z����}�o��'Aj:�e&�� C�
3H��v-fKS���x�A�����g&�Z���Z��ʼ�[�-�^�ڮ����:�B Y*��ەl�uh@�j^"�s�,^�A\�`h^�<vR� �����/ő-\�Z�#�<���3�����֬�R����������g"�:R�m��^�`%�&���.
��8N ��GKj��!��YD�X�{�Q=̲�鼽�����h1Uj"pg�֗x��TU���=���:1���6�
T�@���]��U9��kV���Z4�pFK�s�'O˞��;@�i Zv�{Vk>3eF/�\غT�F�[ꖕtcv�w��k�!@Z��k��e���Ԕ`h>0G|Gn�O^m����������Y͙��G�������&�U��\�!.�d\���(-[�M�	��@ |W\�So�O3���I.U#l����c妫�5XP�B�+4Qj�ꚗF���6k�)�ݯ���ʆ�;����E	P)�,��:�R�x��%��g�ֺ|�<��A��u&Q�^�ҪTym���}Ů���#����C��Yks���繱ޞ��\��=���)�x��U��-��qޢ�ΙG��W;��ʳ�D����h�D�m�Qu�>??��= j
  ���|���
�3��龸��0{Ȼ��-��ZTdщ,;��0��sj�{%�m�;v
�r%F�ǒ�����D]}"a�KD�BI�yKxXJy��1a1Bq������-��g�f�ݬ��:|�_�*@��
8�,�]��k1&���*J�ύf@w������q9�o�>�~�(1�C�I�y��5�*Di]2�Dt:��ؐ@ �����lZ��1	�J\$�ҪS.G������z�Xs���ʸ�U�b���7�"M�S�,�-��n2���ɭ�G_��Rm�%Oc�(��%usp�b=���^��QcQ��G�߬<��!(S��l�y�,�JQ��y�\������:W�����]F���M^~�=��ڙ�Um[�����_SSb���ѹƉ����hg���{ْ],,�ְ8f���:,~��[�,,u��"�|�-/���,!-O�U��ɭ2Z&S�^�j_�1z%��t2*�,Xw)����u{i
LŜӠ�`o���M�f����g6��g�_���k���Ù
�3�<E���-��V�.�~�~������Ǹ��?���fz\��*����_�i��<!�gI��qt���aM�Ry�/�_�@���G|��O�>'۩���JY9��
�7&ݪ@Z#��@������j����&��YF�q�W��[&����R/����@�f�Jì��dtѠ�\Vm���u�F��'n1&�Gq��T#:����FKc�V�x�}��x|:ƌ�%!�2LP.J`��h�@ |C��� �����Eӭ�"j'�iȺY�>��c��sV�sƙ�5��Jq��,�fki,�E1n-�L��.VI�BPc����=;�ʘq�&�P��?�ƞ|��#��!=b�<{�2��i�&�xm>�ʁ�
��h�m3��c66�@���Я��T��D�c݊-'��.���f�\ί}�{_U����2�����T�.re�0M�s���w[�����X�!՘��}8U�`�%v���^�u�V���̽�bu5.�@ ��R)�2��M��i�F��^��1��9���3�p�D��ٹ�Y��7��sF�^Q��{��N-�;���~�8N���A1Ϊ��K�3�G-1*�Σ������)i�s�����T�@ ��g�������5�B*12�v��!y��l�fϯ��4vscR��;W���+7�v�S	���G�Pv�9�#F?�>ι�ƕD�J�E��z-y:-^�r�VyI[W*BZ^��{���W�
��շ�@ S�?g&���rLзے{����W�bZԢh��|W�«�֠5��ͳ��9�cEڍs���wlk�>���~�������K6+���c)���_�=K���M�um\�@ �j�u������y�u`��V�EV*� *	�S^��%��Y�RWf,�s����b����O�)^=TUg��T��h�+F��[e�C{�����9P�`6�R�v-ܘ�VD�zU�Q��gy8�x=���w=]��b�����=�[1'�V����T���嫆��1�3O������&��7G����������u�?k�G�j7�'L�v�����f��b�����ϭʼ�k�p�C5�y�+NL+y^�w�c��xɆk�X��\����j�35���[?���z�S�K�yJf��hb�CnYk�Y9[��oT���hsL!`�b��9��RH� ϖ0yW����S��X������T�+l����@�B�C�Q*8�:Fe���Ƽi�@��x"�$�C��X�"5ֳ[�u��n���;�ޗ�bɱ�Z�J�}܁o�O�K�A���3ii�s����4/��U�ȭk���KU�����8g;!�`��j�T�XKYID��Ǟi��Z��#��Q�<zt�Z��<�)/eϤc���j�_U ������|n
ذZ;����f�c�w�Z�t98=����r}�s2��U���Ɇ�k
�cd�������|Z_/���f�#˃]1'���B�>ɓ���a}+��3پ}�s5<�9�W�-,�?Bf�1<��e������n��98᭹�Ϫ�׵�Y��|���1��ݬ�9�X�!&��4N��D4�G ��C}t���k��#��s~8���ĉ��鴟��ת���c��n��V�#�2Q�8��J ��M�g�)�[�5���c���й��~���5o�:��	�ͣw��{��^�h�@ ~-�����g�s����������y��G9ꪯ����������3���� �U~���@ �
�pߌ��7�����{��ǽ�[u�ָ���`�U��}���W[����gr�+ϙc?3���3V���l�?�Y&�+���J:��$�@ �@ �@ �@ �@ �@ �@ �9��������������_�˿���?��g�/���H�m�X�������������o��5Ric��_8��o������O�O�����?��o���r�p��`�põ�o*&��H.�6�7���g��?�W��^�ſS���g�����o������������?�_�������������?��Qw��쯅�����w�W���W���J�      �      x�3�q���L�2��%\1z\\\ 4�=      �   :   x�3�472�500����q�R8�����G6��pdޑ�Fz`�i�i����� ��      �   (   x�3�4���t�34��3 .#����L8F��� �'�      �   &   x�3�N�(HT���+I�R�LI�I,:��+F��� ��	�      �      x������ � �      �      x������ � �      �   ?   x�34�����t�34�4�3 N(��М�$�����7AW`Q 2���ӄ=... �~�      �      x�3��472�500�4�35 �=... 9"      �      x������ � �      �      x������ � �      	      x������ � �      �   ^   x���q�	64��v��Sqt�qU04V�u;���P� 8c��,9�<����}B9��l ��]=�|��C�\#�P���qqq S=�     