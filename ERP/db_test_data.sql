PGDMP     5            	        {            ths_erp_per    13.4    15.2 �   �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    4047138    ths_erp_per    DATABASE        CREATE DATABASE ths_erp_per WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Turkish_Turkey.1254';
    DROP DATABASE ths_erp_per;
             	   ths_admin    false            
            2615    2200    public    SCHEMA     2   -- *not* creating schema, since initdb creates it
 2   -- *not* dropping schema, since initdb creates it
                postgres    false            �           0    0    SCHEMA public    ACL     T   REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO ths_admin;
                   postgres    false    10                        3079    4047139    dblink 	   EXTENSION     :   CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;
    DROP EXTENSION dblink;
                   false    10            �           0    0    EXTENSION dblink    COMMENT     _   COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';
                        false    2                        3079    4047185    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                   false    10            �           0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                        false    3                        3079    4047222 
   pgrowlocks 	   EXTENSION     >   CREATE EXTENSION IF NOT EXISTS pgrowlocks WITH SCHEMA public;
    DROP EXTENSION pgrowlocks;
                   false    10            �           0    0    EXTENSION pgrowlocks    COMMENT     I   COMMENT ON EXTENSION pgrowlocks IS 'show row-level locking information';
                        false    4                        3079    4047224    pldbgapi 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pldbgapi WITH SCHEMA public;
    DROP EXTENSION pldbgapi;
                   false    10            �           0    0    EXTENSION pldbgapi    COMMENT     Y   COMMENT ON EXTENSION pldbgapi IS 'server-side support for debugging PL/pgSQL functions';
                        false    5                        3079    4047261    postgres_fdw 	   EXTENSION     @   CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;
    DROP EXTENSION postgres_fdw;
                   false    10            �           0    0    EXTENSION postgres_fdw    COMMENT     [   COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';
                        false    6            �           0    0    FUNCTION armor(bytea)    ACL     8   GRANT ALL ON FUNCTION public.armor(bytea) TO ths_admin;
          public          postgres    false    458            �           0    0 %   FUNCTION armor(bytea, text[], text[])    ACL     H   GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO ths_admin;
          public          postgres    false    459            �           1255    4047265    audit()    FUNCTION     _  CREATE FUNCTION public.audit() RETURNS trigger
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
       public       	   ths_admin    false    10            �           0    0    FUNCTION audit()    ACL     i   REVOKE ALL ON FUNCTION public.audit() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.audit() FROM ths_admin;
          public       	   ths_admin    false    489            �           1255    4047266    audit_old()    FUNCTION     �  CREATE FUNCTION public.audit_old() RETURNS trigger
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
       public       	   ths_admin    false    10            �           0    0    FUNCTION audit_old()    ACL     q   REVOKE ALL ON FUNCTION public.audit_old() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.audit_old() FROM ths_admin;
          public       	   ths_admin    false    490            �           0    0    FUNCTION crypt(text, text)    ACL     =   GRANT ALL ON FUNCTION public.crypt(text, text) TO ths_admin;
          public          postgres    false    491            �           0    0    FUNCTION dearmor(text)    ACL     9   GRANT ALL ON FUNCTION public.dearmor(text) TO ths_admin;
          public          postgres    false    460            �           0    0 $   FUNCTION decrypt(bytea, bytea, text)    ACL     G   GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO ths_admin;
          public          postgres    false    492            �           0    0 .   FUNCTION decrypt_iv(bytea, bytea, bytea, text)    ACL     Q   GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO ths_admin;
          public          postgres    false    493            �           1255    4047267    delete_table_lang_content()    FUNCTION     ]  CREATE FUNCTION public.delete_table_lang_content() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$DECLARE
    BEGIN
    
	IF (TG_OP = 'DELETE') THEN
            DELETE FROM sys_lang_data_content WHERE table_name=initcap(replace(TG_TABLE_NAME, '_', ' ')) AND row_id=OLD.id;
        END IF;

        RETURN NULL;
    END;
$$;
 2   DROP FUNCTION public.delete_table_lang_content();
       public       	   ths_admin    false    10            �           0    0 $   FUNCTION delete_table_lang_content()    ACL     �   REVOKE ALL ON FUNCTION public.delete_table_lang_content() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.delete_table_lang_content() FROM ths_admin;
          public       	   ths_admin    false    464            �           0    0    FUNCTION digest(bytea, text)    ACL     ?   GRANT ALL ON FUNCTION public.digest(bytea, text) TO ths_admin;
          public          postgres    false    494            �           0    0    FUNCTION digest(text, text)    ACL     >   GRANT ALL ON FUNCTION public.digest(text, text) TO ths_admin;
          public          postgres    false    408            �           0    0 $   FUNCTION encrypt(bytea, bytea, text)    ACL     G   GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO ths_admin;
          public          postgres    false    410            �           0    0 .   FUNCTION encrypt_iv(bytea, bytea, bytea, text)    ACL     Q   GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO ths_admin;
          public          postgres    false    411            �           0    0 "   FUNCTION gen_random_bytes(integer)    ACL     E   GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO ths_admin;
          public          postgres    false    495            �           0    0    FUNCTION gen_random_uuid()    ACL     =   GRANT ALL ON FUNCTION public.gen_random_uuid() TO ths_admin;
          public          postgres    false    496            �           0    0    FUNCTION gen_salt(text)    ACL     :   GRANT ALL ON FUNCTION public.gen_salt(text) TO ths_admin;
          public          postgres    false    412            �           0    0     FUNCTION gen_salt(text, integer)    ACL     C   GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO ths_admin;
          public          postgres    false    497            �           0    0 !   FUNCTION hmac(bytea, bytea, text)    ACL     D   GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO ths_admin;
          public          postgres    false    498            �           0    0    FUNCTION hmac(text, text, text)    ACL     B   GRANT ALL ON FUNCTION public.hmac(text, text, text) TO ths_admin;
          public          postgres    false    409            �           1255    4047268    personel_adsoyad()    FUNCTION     ]  CREATE FUNCTION public.personel_adsoyad() RETURNS trigger
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
       public       	   ths_admin    false    10                        0    0    FUNCTION personel_adsoyad()    ACL        REVOKE ALL ON FUNCTION public.personel_adsoyad() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.personel_adsoyad() FROM ths_admin;
          public       	   ths_admin    false    465                       0    0 >   FUNCTION pgp_armor_headers(text, OUT key text, OUT value text)    ACL     a   GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO ths_admin;
          public          postgres    false    461                       0    0    FUNCTION pgp_key_id(bytea)    ACL     =   GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO ths_admin;
          public          postgres    false    462                       0    0 &   FUNCTION pgp_pub_decrypt(bytea, bytea)    ACL     I   GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO ths_admin;
          public          postgres    false    424                       0    0 ,   FUNCTION pgp_pub_decrypt(bytea, bytea, text)    ACL     O   GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO ths_admin;
          public          postgres    false    425                       0    0 2   FUNCTION pgp_pub_decrypt(bytea, bytea, text, text)    ACL     U   GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO ths_admin;
          public          postgres    false    499                       0    0 ,   FUNCTION pgp_pub_decrypt_bytea(bytea, bytea)    ACL     O   GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO ths_admin;
          public          postgres    false    426                       0    0 2   FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text)    ACL     U   GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO ths_admin;
          public          postgres    false    427                       0    0 8   FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text)    ACL     [   GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO ths_admin;
          public          postgres    false    428            	           0    0 %   FUNCTION pgp_pub_encrypt(text, bytea)    ACL     H   GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO ths_admin;
          public          postgres    false    429            
           0    0 +   FUNCTION pgp_pub_encrypt(text, bytea, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO ths_admin;
          public          postgres    false    500                       0    0 ,   FUNCTION pgp_pub_encrypt_bytea(bytea, bytea)    ACL     O   GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO ths_admin;
          public          postgres    false    430                       0    0 2   FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text)    ACL     U   GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO ths_admin;
          public          postgres    false    431                       0    0 %   FUNCTION pgp_sym_decrypt(bytea, text)    ACL     H   GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO ths_admin;
          public          postgres    false    432                       0    0 +   FUNCTION pgp_sym_decrypt(bytea, text, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO ths_admin;
          public          postgres    false    433                       0    0 +   FUNCTION pgp_sym_decrypt_bytea(bytea, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO ths_admin;
          public          postgres    false    501                       0    0 1   FUNCTION pgp_sym_decrypt_bytea(bytea, text, text)    ACL     T   GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO ths_admin;
          public          postgres    false    434                       0    0 $   FUNCTION pgp_sym_encrypt(text, text)    ACL     G   GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO ths_admin;
          public          postgres    false    435                       0    0 *   FUNCTION pgp_sym_encrypt(text, text, text)    ACL     M   GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO ths_admin;
          public          postgres    false    436                       0    0 +   FUNCTION pgp_sym_encrypt_bytea(bytea, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO ths_admin;
          public          postgres    false    437                       0    0 1   FUNCTION pgp_sym_encrypt_bytea(bytea, text, text)    ACL     T   GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO ths_admin;
          public          postgres    false    502                       0    0 �   FUNCTION pgrowlocks(relname text, OUT locked_row tid, OUT locker xid, OUT multi boolean, OUT xids xid[], OUT modes text[], OUT pids integer[])    ACL     �   GRANT ALL ON FUNCTION public.pgrowlocks(relname text, OUT locked_row tid, OUT locker xid, OUT multi boolean, OUT xids xid[], OUT modes text[], OUT pids integer[]) TO ths_admin;
          public          postgres    false    503                       0    0    FUNCTION postgres_fdw_handler()    ACL     B   GRANT ALL ON FUNCTION public.postgres_fdw_handler() TO ths_admin;
          public          postgres    false    466                       0    0 ,   FUNCTION postgres_fdw_validator(text[], oid)    ACL     O   GRANT ALL ON FUNCTION public.postgres_fdw_validator(text[], oid) TO ths_admin;
          public          postgres    false    467            �           1255    4047269 !   sp_get_ch_hesap_karti(text, text)    FUNCTION     �  CREATE FUNCTION public.sp_get_ch_hesap_karti(pfilter text, plang text) RETURNS TABLE(id bigint, hesap_kodu character varying, hesap_ismi character varying, muhasebe_kodu character varying, hesap_tipi_id bigint, hesap_tipi character varying, hesap_grubu_id bigint, grup character varying, bolge_id bigint, bolge character varying, mukellef_tipi_id bigint, mukellef_tipi character varying, mukellef_adi character varying, mukellef_ikinci_adi character varying, mukellef_soyadi character varying, vergi_dairesi character varying, vergi_no character varying, para_birimi character varying, iban character varying, iban_para character varying, nace_kodu character varying, yetkili1 character varying, yetkili1_tel character varying, yetkili2 character varying, yetkili2_tel character varying, yetkili3 character varying, yetkili3_tel character varying, faks character varying, muhasebe_telefon character varying, muhasebe_eposta character varying, muhasebe_yetkili character varying, ozel_bilgi character varying, kok_hesap_kodu character varying, ara_hesap_kodu character varying, hesap_iskonto numeric, is_efatura_hesabi boolean, efatura_pk_name character varying, ulke_id bigint, ulke_adi character varying, sehir_id bigint, sehir_adi character varying, ilce character varying, mahalle character varying, cadde character varying, sokak character varying, bina_adi character varying, kapi_no character varying, posta_kutusu character varying, posta_kodu character varying, web_site character varying, email character varying)
    LANGUAGE plpgsql
    AS $$

begin
RETURN QUERY EXECUTE 
'SELECT 
	ch_hesap_karti.id, 
	ch_hesap_karti.hesap_kodu, 
	ch_hesap_karti.hesap_ismi, 
	ch_hesap_karti.muhasebe_kodu, 
	ch_hesap_karti.hesap_tipi_id, 
	spget_lang_text((SELECT rawset_ch_hesap_tipi.hesap_tipi FROM set_ch_hesap_tipi as rawset_ch_hesap_tipi WHERE rawset_ch_hesap_tipi.id=ch_hesap_karti.hesap_tipi_id),''set_ch_hesap_tipi'',''hesap_tipi'', hesap_tipi_id, ' || quote_nullable(plang) || ') as hesap_tipi, 
	ch_hesap_karti.hesap_grubu_id, 
	spget_lang_text((SELECT rawset_ch_grup.grup FROM set_ch_grup as rawset_ch_grup WHERE rawset_ch_grup.id=ch_hesap_karti.hesap_grubu_id),''set_ch_grup2'',''grup'', hesap_grubu_id, ' || quote_nullable(plang) || ') as grup, 
	ch_hesap_karti.bolge_id, 
	spget_lang_text((SELECT rawch_bolge.bolge FROM ch_bolge as rawch_bolge WHERE rawch_bolge.id=ch_hesap_karti.bolge_id),''ch_bolge'',''bolge'', bolge_id, ' || quote_nullable(plang) || ') as bolge, 
	ch_hesap_karti.mukellef_tipi_id, 
	spget_lang_text((SELECT rawsys_mukellef_tipi.mukellef_tipi FROM sys_mukellef_tipi as rawsys_mukellef_tipi WHERE rawsys_mukellef_tipi.id=ch_hesap_karti.mukellef_tipi_id),''sys_mukellef_tipi'',''mukellef_tipi'', mukellef_tipi_id, ' || quote_nullable(plang) || ') as mukellef_tipi, 
	ch_hesap_karti.mukellef_adi, 
	ch_hesap_karti.mukellef_ikinci_adi, 
	ch_hesap_karti.mukellef_soyadi, 
	ch_hesap_karti.vergi_dairesi, 
	ch_hesap_karti.vergi_no, 
	ch_hesap_karti.para_birimi, 
	ch_hesap_karti.iban, 
	ch_hesap_karti.iban_para, 
	ch_hesap_karti.nace_kodu, 
	ch_hesap_karti.yetkili1, 
	ch_hesap_karti.yetkili1_tel, 
	ch_hesap_karti.yetkili2, 
	ch_hesap_karti.yetkili2_tel, 
	ch_hesap_karti.yetkili3, 
	ch_hesap_karti.yetkili3_tel, 
	ch_hesap_karti.faks, 
	ch_hesap_karti.muhasebe_telefon, 
	ch_hesap_karti.muhasebe_eposta, 
	ch_hesap_karti.muhasebe_yetkili, 
	ch_hesap_karti.ozel_bilgi, 
	ch_hesap_karti.kok_hesap_kodu, 
	ch_hesap_karti.ara_hesap_kodu, 
	ch_hesap_karti.hesap_iskonto, 
	ch_hesap_karti.is_efatura_hesabi, 
	ch_hesap_karti.efatura_pk_name, 
	ch_hesap_karti.ulke_id, 
	spget_lang_text((SELECT rawsys_ulke.ulke_adi FROM sys_ulke as rawsys_ulke WHERE rawsys_ulke.id=ch_hesap_karti.ulke_id),''sys_ulke'',''ulke_adi'', ulke_id, ' || quote_nullable(plang) || ') as ulke_adi, 
	ch_hesap_karti.sehir_id, 
	spget_lang_text((SELECT rawsys_sehir.sehir_adi FROM sys_sehir as rawsys_sehir WHERE rawsys_sehir.id=ch_hesap_karti.sehir_id),''sys_sehir'',''sehir_adi'', sehir_id, ' || quote_nullable(plang) || ') as sehir_adi, 
	ch_hesap_karti.ilce, 
	ch_hesap_karti.mahalle, 
	ch_hesap_karti.cadde, 
	ch_hesap_karti.sokak, 
	ch_hesap_karti.bina_adi, 
	ch_hesap_karti.kapi_no, 
	ch_hesap_karti.posta_kutusu, 
	ch_hesap_karti.posta_kodu, 
	ch_hesap_karti.web_site, 
	ch_hesap_karti.email 
FROM ch_hesap_karti 
WHERE 1=1 ' || pfilter;
END
$$;
 F   DROP FUNCTION public.sp_get_ch_hesap_karti(pfilter text, plang text);
       public          postgres    false    10                       0    0 8   FUNCTION sp_get_ch_hesap_karti(pfilter text, plang text)    ACL     �   REVOKE ALL ON FUNCTION public.sp_get_ch_hesap_karti(pfilter text, plang text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.sp_get_ch_hesap_karti(pfilter text, plang text) TO ths_admin;
          public          postgres    false    504            �           1255    4047270    spexists_hesap_kodu(text)    FUNCTION     0  CREATE FUNCTION public.spexists_hesap_kodu(phesap_kodu text) RETURNS boolean
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
       public          postgres    false    10                       0    0 .   FUNCTION spexists_hesap_kodu(phesap_kodu text)    ACL     �   REVOKE ALL ON FUNCTION public.spexists_hesap_kodu(phesap_kodu text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spexists_hesap_kodu(phesap_kodu text) TO ths_admin;
          public          postgres    false    470            �           1255    4047271    spget_crypted_data(text)    FUNCTION     �   CREATE FUNCTION public.spget_crypted_data(pval text) RETURNS text
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
       public          postgres    false    10                       0    0 &   FUNCTION spget_crypted_data(pval text)    ACL     I   GRANT ALL ON FUNCTION public.spget_crypted_data(pval text) TO ths_admin;
          public          postgres    false    471            �           1255    4047272 /   spget_lang_text(text, text, text, bigint, text)    FUNCTION     �  CREATE FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) RETURNS character varying
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
       public          postgres    false    10                       0    0 n   FUNCTION spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text)    ACL     "  REVOKE ALL ON FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_lang_text(pdefault_value text, ptable_name text, pcolumn_name text, prow_id bigint, plang text) TO ths_admin;
          public          postgres    false    469            �           1255    4047273 -   spget_lang_text(text, text, text, text, text)    FUNCTION     �  CREATE FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) RETURNS character varying
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
       public          postgres    false    10                       0    0 n   FUNCTION spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text)    ACL     "  REVOKE ALL ON FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_lang_text(_default_value text, _table_name text, _column_name text, _data_col text, _lang text) TO ths_admin;
          public          postgres    false    472            �           1255    4047274    spget_prs_personel_id_list()    FUNCTION     j  CREATE FUNCTION public.spget_prs_personel_id_list() RETURNS TABLE(id integer, emp_name character varying, emp_surname character varying, emp_full_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
		SELECT  prs_personel.id, prs_personel.ad, prs_personel.soyad, prs_personel.ad_soyad FROM prs_personel
		WHERE is_aktif ORDER BY 4;
END
$$;
 3   DROP FUNCTION public.spget_prs_personel_id_list();
       public          postgres    false    10                       0    0 %   FUNCTION spget_prs_personel_id_list()    ACL     �   REVOKE ALL ON FUNCTION public.spget_prs_personel_id_list() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_prs_personel_id_list() TO ths_admin;
          public          postgres    false    474            �           1255    4047275 "   spget_rct_hammadde_maliyet(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) RETURNS numeric
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
       public          postgres    false    10                       0    0 :   FUNCTION spget_rct_hammadde_maliyet(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_hammadde_maliyet(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    473            �           1255    4047276 !   spget_rct_iscilik_maliyet(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) RETURNS numeric
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
       public          postgres    false    10                       0    0 9   FUNCTION spget_rct_iscilik_maliyet(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_iscilik_maliyet(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    475            �           1255    4047277    spget_rct_toplam(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_toplam(prct_recete_id bigint) RETURNS numeric
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
       public          postgres    false    10                        0    0 0   FUNCTION spget_rct_toplam(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_toplam(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_toplam(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    476            �           1255    4047278 "   spget_rct_yan_urun_maliyet(bigint)    FUNCTION     �  CREATE FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) RETURNS numeric
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
       public          postgres    false    10            !           0    0 :   FUNCTION spget_rct_yan_urun_maliyet(prct_recete_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_rct_yan_urun_maliyet(prct_recete_id bigint) TO ths_admin;
          public          postgres    false    477            �           1255    4047279 &   spget_sys_kalite_form_no(text, bigint)    FUNCTION     I  CREATE FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) RETURNS character varying
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
       public          postgres    false    10            "           0    0 H   FUNCTION spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint)    ACL     �   REVOKE ALL ON FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_sys_kalite_form_no(ptablo_adi text, pform_tipi_id bigint) TO ths_admin;
          public          postgres    false    478            �           1255    4047280    spget_sys_lang_id(text)    FUNCTION     �   CREATE FUNCTION public.spget_sys_lang_id(planguage text) RETURNS integer
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
       public          postgres    false    10            #           0    0 *   FUNCTION spget_sys_lang_id(planguage text)    ACL     �   REVOKE ALL ON FUNCTION public.spget_sys_lang_id(planguage text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_sys_lang_id(planguage text) TO ths_admin;
          public          postgres    false    479            �           1255    4047281 '   spget_sys_quality_form_type_id(integer)    FUNCTION     �  CREATE FUNCTION public.spget_sys_quality_form_type_id(ptype integer) RETURNS integer
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
       public          postgres    false    10            $           0    0 6   FUNCTION spget_sys_quality_form_type_id(ptype integer)    ACL     Y   GRANT ALL ON FUNCTION public.spget_sys_quality_form_type_id(ptype integer) TO ths_admin;
          public          postgres    false    505            �           1255    4047282    spget_sys_user_id_list()    FUNCTION       CREATE FUNCTION public.spget_sys_user_id_list() RETURNS TABLE(id bigint, user_name character varying)
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
       public       	   ths_admin    false    10            %           0    0 !   FUNCTION spget_sys_user_id_list()    ACL     D   REVOKE ALL ON FUNCTION public.spget_sys_user_id_list() FROM PUBLIC;
          public       	   ths_admin    false    468            �           1255    4047283 1   spget_year_week(date, character varying, boolean)    FUNCTION     �  CREATE FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean DEFAULT true) RETURNS character varying
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
       public          postgres    false    10            &           0    0 Y   FUNCTION spget_year_week(pdate date, pseparate character varying, pis_year_first boolean)    ACL     �   REVOKE ALL ON FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spget_year_week(pdate date, pseparate character varying, pis_year_first boolean) TO ths_admin;
          public          postgres    false    482            �           1255    4047284    splogin(text, text, text, text)    FUNCTION     �  CREATE FUNCTION public.splogin(puser_name text, puser_pass text, papp_version text, pmac_address text) RETURNS integer
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
       public       	   ths_admin    false    10            �           1255    4047285 (   spset_user_password(text, text, integer)    FUNCTION       CREATE FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) RETURNS boolean
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
       public          postgres    false    10            '           0    0 H   FUNCTION spset_user_password(oldpass text, newpass text, userid integer)    ACL     �   REVOKE ALL ON FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.spset_user_password(oldpass text, newpass text, userid integer) TO ths_admin;
          public          postgres    false    484            �           1255    4047286    spvarsayilan_para_birimi()    FUNCTION     �   CREATE FUNCTION public.spvarsayilan_para_birimi() RETURNS character varying
    LANGUAGE sql
    AS $$
	SELECT para_birimi FROM sys_para_birimi WHERE is_varsayilan LIMIT 1;
$$;
 1   DROP FUNCTION public.spvarsayilan_para_birimi();
       public          postgres    false    10            (           0    0 #   FUNCTION spvarsayilan_para_birimi()    ACL     �   REVOKE ALL ON FUNCTION public.spvarsayilan_para_birimi() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spvarsayilan_para_birimi() TO ths_admin;
          public          postgres    false    483            �           1255    4047287    spvarsayilan_urun_tipi_id()    FUNCTION     �   CREATE FUNCTION public.spvarsayilan_urun_tipi_id() RETURNS integer
    LANGUAGE sql
    AS $$
	SELECT id FROM set_stk_urun_tipi WHERE urun_tipi='HAMMADDE';
$$;
 2   DROP FUNCTION public.spvarsayilan_urun_tipi_id();
       public          postgres    false    10            )           0    0 $   FUNCTION spvarsayilan_urun_tipi_id()    ACL     �   REVOKE ALL ON FUNCTION public.spvarsayilan_urun_tipi_id() FROM PUBLIC;
GRANT ALL ON FUNCTION public.spvarsayilan_urun_tipi_id() TO ths_admin;
          public          postgres    false    486            �           1255    4047288    table_listen(text)    FUNCTION     �   CREATE FUNCTION public.table_listen(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT listen table_name;
  RETURN;
END;
$$;
 4   DROP FUNCTION public.table_listen(table_name text);
       public          postgres    false    10            *           0    0 &   FUNCTION table_listen(table_name text)    ACL     �   REVOKE ALL ON FUNCTION public.table_listen(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_listen(table_name text) TO ths_admin;
          public          postgres    false    487            �           1255    4047289    table_notify()    FUNCTION     �  CREATE FUNCTION public.table_notify() RETURNS trigger
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
       public       	   ths_admin    false    10            +           0    0    FUNCTION table_notify()    ACL     w   REVOKE ALL ON FUNCTION public.table_notify() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.table_notify() FROM ths_admin;
          public       	   ths_admin    false    488            �           1255    4047290    table_notify(text)    FUNCTION     �   CREATE FUNCTION public.table_notify(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT notify table_name;
  RETURN;
END;
$$;
 4   DROP FUNCTION public.table_notify(table_name text);
       public          postgres    false    10            ,           0    0 &   FUNCTION table_notify(table_name text)    ACL     �   REVOKE ALL ON FUNCTION public.table_notify(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_notify(table_name text) TO ths_admin;
          public          postgres    false    481            �           1255    4047291    table_unlisten(text)    FUNCTION     �   CREATE FUNCTION public.table_unlisten(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT unlisten table_name;
  RETURN;
END;
$$;
 6   DROP FUNCTION public.table_unlisten(table_name text);
       public          postgres    false    10            -           0    0 (   FUNCTION table_unlisten(table_name text)    ACL     �   REVOKE ALL ON FUNCTION public.table_unlisten(table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.table_unlisten(table_name text) TO ths_admin;
          public          postgres    false    485            �            1259    4047292    a_invoices_id_seq    SEQUENCE     z   CREATE SEQUENCE public.a_invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.a_invoices_id_seq;
       public          postgres    false    10            �            1259    4047294    audits    TABLE     �  CREATE TABLE public.audits (
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
       public         heap 	   ths_admin    false    10            �            1259    4047300    audit_id_seq    SEQUENCE     �   ALTER TABLE public.audits ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    212    10            �            1259    4047302    ch_bankalar    TABLE     �   CREATE TABLE public.ch_bankalar (
    id bigint NOT NULL,
    banka_adi character varying(64) NOT NULL,
    swift_kodu character varying(16)
);
    DROP TABLE public.ch_bankalar;
       public         heap 	   ths_admin    false    10            �            1259    4047305    ch_banka_id_seq    SEQUENCE     �   ALTER TABLE public.ch_bankalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_banka_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    214            �            1259    4047307    ch_banka_subeleri    TABLE     �   CREATE TABLE public.ch_banka_subeleri (
    id bigint NOT NULL,
    banka_id bigint NOT NULL,
    sube_kodu integer NOT NULL,
    sube_adi character varying(64) NOT NULL,
    sehir_id bigint NOT NULL
);
 %   DROP TABLE public.ch_banka_subeleri;
       public         heap 	   ths_admin    false    10            �            1259    4047310    ch_banka_subesi_id_seq    SEQUENCE     �   ALTER TABLE public.ch_banka_subeleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_banka_subesi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    216    10            �            1259    4047312    ch_bolgeler    TABLE     f   CREATE TABLE public.ch_bolgeler (
    id bigint NOT NULL,
    bolge character varying(32) NOT NULL
);
    DROP TABLE public.ch_bolgeler;
       public         heap 	   ths_admin    false    10            �            1259    4047315    ch_bolge_id_seq    SEQUENCE     �   ALTER TABLE public.ch_bolgeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_bolge_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    218            �            1259    4047317    ch_doviz_kurlari    TABLE     �   CREATE TABLE public.ch_doviz_kurlari (
    id bigint NOT NULL,
    kur_tarihi date NOT NULL,
    kur numeric(10,4) NOT NULL,
    para character varying(3)
);
 $   DROP TABLE public.ch_doviz_kurlari;
       public         heap 	   ths_admin    false    10            �            1259    4047320 
   ch_gruplar    TABLE     d   CREATE TABLE public.ch_gruplar (
    id bigint NOT NULL,
    grup character varying(16) NOT NULL
);
    DROP TABLE public.ch_gruplar;
       public         heap 	   ths_admin    false    10            �            1259    4047323    ch_hesaplar    TABLE     �  CREATE TABLE public.ch_hesaplar (
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
    adres_id bigint
);
    DROP TABLE public.ch_hesaplar;
       public         heap 	   ths_admin    false    10            �            1259    4047331    ch_hesap_karti_id_seq    SEQUENCE     �   ALTER TABLE public.ch_hesaplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ch_hesap_karti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    222            �            1259    4047333    ch_hesap_planlari    TABLE     �   CREATE TABLE public.ch_hesap_planlari (
    id bigint NOT NULL,
    plan_kodu character varying(16) NOT NULL,
    plan_adi character varying(128) NOT NULL,
    seviye smallint NOT NULL
);
 %   DROP TABLE public.ch_hesap_planlari;
       public         heap 	   ths_admin    false    10            �            1259    4047336    mhs_doviz_kuru_id_seq    SEQUENCE     �   ALTER TABLE public.ch_doviz_kurlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mhs_doviz_kuru_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    220            �            1259    4047338    prs_lisan_bilgileri    TABLE     �   CREATE TABLE public.prs_lisan_bilgileri (
    id bigint NOT NULL,
    lisan_id bigint,
    okuma_id bigint,
    yazma_id bigint,
    konusma_id bigint,
    personel_id bigint
);
 '   DROP TABLE public.prs_lisan_bilgileri;
       public         heap 	   ths_admin    false    10            �            1259    4047341    prs_lisan_bilgisi_id_seq    SEQUENCE     �   ALTER TABLE public.prs_lisan_bilgileri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_lisan_bilgisi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    226    10            �            1259    4047343    prs_personel_ehliyetleri    TABLE     x   CREATE TABLE public.prs_personel_ehliyetleri (
    id bigint NOT NULL,
    ehliyet_id bigint,
    personel_id bigint
);
 ,   DROP TABLE public.prs_personel_ehliyetleri;
       public         heap 	   ths_admin    false    10            �            1259    4047346    prs_personel_ehliyetleri_id_seq    SEQUENCE     �   ALTER TABLE public.prs_personel_ehliyetleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_personel_ehliyetleri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    228            �            1259    4047348    prs_personeller    TABLE     �  CREATE TABLE public.prs_personeller (
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
       public         heap 	   ths_admin    false    10            .           0    0    COLUMN prs_personeller.cinsiyet    COMMENT     F   COMMENT ON COLUMN public.prs_personeller.cinsiyet IS '1 Man
2 Woman';
          public       	   ths_admin    false    230            /           0    0 &   COLUMN prs_personeller.askerlik_durumu    COMMENT     e   COMMENT ON COLUMN public.prs_personeller.askerlik_durumu IS '1 Yapti, 2 Yapmadi, 3 Tecilli, 4 Muaf';
          public       	   ths_admin    false    230            0           0    0 #   COLUMN prs_personeller.medeni_durum    COMMENT     L   COMMENT ON COLUMN public.prs_personeller.medeni_durum IS '1 Evli, 2 Bekar';
          public       	   ths_admin    false    230            �            1259    4047358    prs_personel_id_seq    SEQUENCE     �   ALTER TABLE public.prs_personeller ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prs_personel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    230    10            �            1259    4047360    urt_iscilikler    TABLE     �   CREATE TABLE public.urt_iscilikler (
    id bigint NOT NULL,
    gider_kodu character varying(16) NOT NULL,
    gider_adi character varying(128),
    fiyat numeric(18,6) NOT NULL,
    birim_id bigint NOT NULL,
    gider_tipi smallint NOT NULL
);
 "   DROP TABLE public.urt_iscilikler;
       public         heap 	   ths_admin    false    10            �            1259    4047363    rct_iscilik_gideri_id_seq    SEQUENCE     �   ALTER TABLE public.urt_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_iscilik_gideri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    232    10            �            1259    4047365    urt_paket_hammadde_detaylari    TABLE     �   CREATE TABLE public.urt_paket_hammadde_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    recete_id bigint,
    stok_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 0   DROP TABLE public.urt_paket_hammadde_detaylari;
       public         heap 	   ths_admin    false    10            �            1259    4047368    rct_paket_hammadde_detay_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_hammadde_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_hammadde_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    234    10            �            1259    4047370    urt_paket_hammaddeler    TABLE     u   CREATE TABLE public.urt_paket_hammaddeler (
    id bigint NOT NULL,
    paket_adi character varying(128) NOT NULL
);
 )   DROP TABLE public.urt_paket_hammaddeler;
       public         heap 	   ths_admin    false    10            �            1259    4047373    rct_paket_hammadde_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    236    10            �            1259    4047375    urt_paket_iscilik_detaylari    TABLE     �   CREATE TABLE public.urt_paket_iscilik_detaylari (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    iscilik_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 /   DROP TABLE public.urt_paket_iscilik_detaylari;
       public         heap 	   ths_admin    false    10            �            1259    4047378    rct_paket_iscilik_detay_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_iscilik_detaylari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_iscilik_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    238            �            1259    4047380    urt_paket_iscilikler    TABLE     t   CREATE TABLE public.urt_paket_iscilikler (
    id bigint NOT NULL,
    paket_adi character varying(128) NOT NULL
);
 (   DROP TABLE public.urt_paket_iscilikler;
       public         heap 	   ths_admin    false    10            �            1259    4047383    rct_paket_iscilik_id_seq    SEQUENCE     �   ALTER TABLE public.urt_paket_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_paket_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    240            �            1259    4047385    urt_recete_hammaddeler    TABLE     �   CREATE TABLE public.urt_recete_hammaddeler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    recete_id bigint,
    stok_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL,
    fire_orani numeric(18,6) DEFAULT 0 NOT NULL
);
 *   DROP TABLE public.urt_recete_hammaddeler;
       public         heap 	   ths_admin    false    10            �            1259    4047389    rct_recete_hammadde_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    242            �            1259    4047391    urt_receteler    TABLE     �   CREATE TABLE public.urt_receteler (
    id bigint NOT NULL,
    urun_kodu character varying(32) NOT NULL,
    urun_adi character varying(128) NOT NULL,
    ornek_miktari numeric(18,6) DEFAULT 1,
    aciklama character varying(128)
);
 !   DROP TABLE public.urt_receteler;
       public         heap 	   ths_admin    false    10            �            1259    4047395    rct_recete_id_seq    SEQUENCE     �   ALTER TABLE public.urt_receteler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    244    10            �            1259    4047397    urt_recete_iscilikler    TABLE     �   CREATE TABLE public.urt_recete_iscilikler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    iscilik_kodu character varying(16) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 )   DROP TABLE public.urt_recete_iscilikler;
       public         heap 	   ths_admin    false    10            �            1259    4047400    rct_recete_iscilik_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    246    10            �            1259    4047402    urt_recete_paket_hammaddeler    TABLE     �   CREATE TABLE public.urt_recete_paket_hammaddeler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    paket_id bigint NOT NULL,
    miktar numeric(18,6)
);
 0   DROP TABLE public.urt_recete_paket_hammaddeler;
       public         heap 	   ths_admin    false    10            �            1259    4047405     rct_recete_paket_hammadde_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_paket_hammaddeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_paket_hammadde_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    248    10            �            1259    4047407    urt_recete_paket_iscilikler    TABLE     �   CREATE TABLE public.urt_recete_paket_iscilikler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    paket_id bigint NOT NULL,
    miktar numeric(18,6)
);
 /   DROP TABLE public.urt_recete_paket_iscilikler;
       public         heap 	   ths_admin    false    10            �            1259    4047410    rct_recete_paket_iscilik_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_paket_iscilikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rct_recete_paket_iscilik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    250    10            �            1259    4047412    sls_invoice_details    TABLE     �   CREATE TABLE public.sls_invoice_details (
    id bigint NOT NULL,
    header_id bigint,
    teklif_detay_id bigint,
    siparis_detay_id bigint,
    irsaliye_detay_id bigint
);
 '   DROP TABLE public.sls_invoice_details;
       public         heap 	   ths_admin    false    10            �            1259    4047415    sat_fatura_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sls_invoice_details ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_fatura_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    252    10            �            1259    4047417    sls_invoices    TABLE     �   CREATE TABLE public.sls_invoices (
    id bigint NOT NULL,
    fatura_no character varying(16),
    fatura_tarihi timestamp without time zone,
    teklif_id bigint,
    siparis_id bigint,
    irsaliye_id bigint
);
     DROP TABLE public.sls_invoices;
       public         heap 	   ths_admin    false    10            �            1259    4047420    sat_fatura_id_seq    SEQUENCE     �   ALTER TABLE public.sls_invoices ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_fatura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    254                        1259    4047422    sls_dispatch_note_details    TABLE     �   CREATE TABLE public.sls_dispatch_note_details (
    id bigint NOT NULL,
    header_id bigint,
    teklif_detay_id bigint,
    siparis_detay_id bigint,
    fatura_detay_id bigint
);
 -   DROP TABLE public.sls_dispatch_note_details;
       public         heap 	   ths_admin    false    10                       1259    4047425    sat_irsaliye_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sls_dispatch_note_details ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_irsaliye_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    256    10                       1259    4047427    sls_dispatch_notes    TABLE     �   CREATE TABLE public.sls_dispatch_notes (
    id bigint NOT NULL,
    irsaliye_no character varying(16),
    irsaliye_tarihi timestamp without time zone,
    teklif_id bigint,
    siparis_id bigint,
    fatura_id bigint
);
 &   DROP TABLE public.sls_dispatch_notes;
       public         heap 	   ths_admin    false    10                       1259    4047430    sat_irsaliye_id_seq    SEQUENCE     �   ALTER TABLE public.sls_dispatch_notes ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_irsaliye_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    258                       1259    4047432    sls_order_details    TABLE     �  CREATE TABLE public.sls_order_details (
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
 %   DROP TABLE public.sls_order_details;
       public         heap 	   ths_admin    false    10                       1259    4047456    sat_siparis_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sls_order_details ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_siparis_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    260    10                       1259    4047458 
   sls_orders    TABLE     �  CREATE TABLE public.sls_orders (
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
    DROP TABLE public.sls_orders;
       public         heap 	   ths_admin    false    10                       1259    4047480    sat_siparis_id_seq    SEQUENCE     �   ALTER TABLE public.sls_orders ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_siparis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    262    10                       1259    4047482    set_sls_order_status    TABLE     �   CREATE TABLE public.set_sls_order_status (
    id bigint NOT NULL,
    siparis_durum character varying(32) NOT NULL,
    aciklama character varying(64)
);
 (   DROP TABLE public.set_sls_order_status;
       public         heap 	   ths_admin    false    10            	           1259    4047485    stk_gruplar    TABLE       CREATE TABLE public.stk_gruplar (
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
       public         heap 	   ths_admin    false    10            
           1259    4047488    stk_stok_kartlari    TABLE     �  CREATE TABLE public.stk_stok_kartlari (
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
    stok_resim bytea,
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
 %   DROP TABLE public.stk_stok_kartlari;
       public         heap 	   ths_admin    false    486    483    483    483    10                       1259    4047510    sys_sehirler    TABLE     �   CREATE TABLE public.sys_sehirler (
    id bigint NOT NULL,
    sehir character varying(32) NOT NULL,
    plaka_kodu integer,
    ulke_id bigint,
    bolge_id bigint
);
     DROP TABLE public.sys_sehirler;
       public         heap 	   ths_admin    false    10                       1259    4047513    sat_siparis_rapor    VIEW     '  CREATE VIEW public.sat_siparis_rapor AS
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
   FROM (((((public.sls_order_details sd
     LEFT JOIN public.sls_orders s ON ((s.id = sd.header_id)))
     LEFT JOIN public.sys_sehirler ct ON ((ct.id = s.sehir_id)))
     LEFT JOIN public.set_sls_order_status ss ON ((ss.id = s.siparis_durum_id)))
     LEFT JOIN public.stk_stok_kartlari stk ON (((stk.stok_kodu)::text = (sd.stok_kodu)::text)))
     LEFT JOIN public.stk_gruplar sg ON ((sg.id = stk.stok_grubu_id)))
  WHERE (1 = 1);
 $   DROP VIEW public.sat_siparis_rapor;
       public       	   ths_admin    false    260    265    267    264    264    262    267    262    262    260    262    260    262    262    262    262    260    260    260    260    266    265    262    266    262    10                       1259    4047518    sls_offer_details    TABLE     �  CREATE TABLE public.sls_offer_details (
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
 %   DROP TABLE public.sls_offer_details;
       public         heap 	   ths_admin    false    10                       1259    4047535    sat_teklif_detay_id_seq    SEQUENCE     �   ALTER TABLE public.sls_offer_details ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_teklif_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    269                       1259    4047537 
   sls_offers    TABLE     v  CREATE TABLE public.sls_offers (
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
    DROP TABLE public.sls_offers;
       public         heap 	   ths_admin    false    10                       1259    4047559    sat_teklif_id_seq    SEQUENCE     �   ALTER TABLE public.sls_offers ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sat_teklif_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    271    10                       1259    4047561    set_ch_firma_tipleri    TABLE     �   CREATE TABLE public.set_ch_firma_tipleri (
    id bigint NOT NULL,
    firma_turu_id bigint NOT NULL,
    firma_tipi character varying(48) NOT NULL
);
 (   DROP TABLE public.set_ch_firma_tipleri;
       public         heap 	   ths_admin    false    10                       1259    4047564    set_ch_firma_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_firma_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_firma_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    273                       1259    4047566    set_ch_firma_turleri    TABLE     t   CREATE TABLE public.set_ch_firma_turleri (
    id bigint NOT NULL,
    firma_turu character varying(32) NOT NULL
);
 (   DROP TABLE public.set_ch_firma_turleri;
       public         heap 	   ths_admin    false    10                       1259    4047569    set_ch_firma_turu_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_firma_turleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_firma_turu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    275                       1259    4047571    set_ch_grup_id_seq    SEQUENCE     �   ALTER TABLE public.ch_gruplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_grup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    221                       1259    4047573    set_ch_hesap_plani_id_seq    SEQUENCE     �   ALTER TABLE public.ch_hesap_planlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_hesap_plani_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    224                       1259    4047575    set_ch_hesap_tipleri    TABLE     t   CREATE TABLE public.set_ch_hesap_tipleri (
    id bigint NOT NULL,
    hesap_tipi character varying(16) NOT NULL
);
 (   DROP TABLE public.set_ch_hesap_tipleri;
       public         heap 	   ths_admin    false    10                       1259    4047578    set_ch_hesap_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_hesap_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_hesap_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    279    10                       1259    4047580    set_ch_vergi_oranlari    TABLE     �  CREATE TABLE public.set_ch_vergi_oranlari (
    id bigint NOT NULL,
    vergi_orani numeric(5,2) NOT NULL,
    satis_hesap_kodu character varying(16) NOT NULL,
    satis_iade_hesap_kodu character varying(16) NOT NULL,
    alis_hesap_kodu character varying(16) NOT NULL,
    alis_iade_hesap_kodu character varying(16) NOT NULL,
    ihrac_hesap_kodu character varying(16),
    ihrac_iade_hesap_kodu character varying(16)
);
 )   DROP TABLE public.set_ch_vergi_oranlari;
       public         heap 	   ths_admin    false    10                       1259    4047583    set_ch_vergi_orani_id_seq    SEQUENCE     �   ALTER TABLE public.set_ch_vergi_oranlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_ch_vergi_orani_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    281    10                       1259    4047585    set_einv_fatura_tipleri    TABLE     x   CREATE TABLE public.set_einv_fatura_tipleri (
    id bigint NOT NULL,
    fatura_tipi character varying(32) NOT NULL
);
 +   DROP TABLE public.set_einv_fatura_tipleri;
       public         heap 	   ths_admin    false    10                       1259    4047588    set_einv_fatura_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_fatura_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_fatura_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    283    10                       1259    4047590    set_einv_odeme_sekilleri    TABLE     �   CREATE TABLE public.set_einv_odeme_sekilleri (
    id bigint NOT NULL,
    odeme_sekli character varying(96),
    kod character varying(16),
    aciklama character varying(512),
    is_efatura boolean DEFAULT false
);
 ,   DROP TABLE public.set_einv_odeme_sekilleri;
       public         heap 	   ths_admin    false    10                       1259    4047597    set_einv_odeme_sekli_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_odeme_sekilleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_odeme_sekli_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    285    10                       1259    4047599    set_einv_paket_tipleri    TABLE     �   CREATE TABLE public.set_einv_paket_tipleri (
    id bigint NOT NULL,
    kod character varying(2),
    paket_tipi character varying(128),
    aciklama character varying(512)
);
 *   DROP TABLE public.set_einv_paket_tipleri;
       public         heap 	   ths_admin    false    10                        1259    4047605    set_einv_paket_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_paket_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_paket_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    287            !           1259    4047607    set_einv_tasima_ucretleri    TABLE     s   CREATE TABLE public.set_einv_tasima_ucretleri (
    id bigint NOT NULL,
    tasima_ucreti character varying(16)
);
 -   DROP TABLE public.set_einv_tasima_ucretleri;
       public         heap 	   ths_admin    false    10            "           1259    4047610    set_einv_tasima_ucreti_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_tasima_ucretleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_tasima_ucreti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    289    10            #           1259    4047612    set_einv_teslim_sekilleri    TABLE     �   CREATE TABLE public.set_einv_teslim_sekilleri (
    id bigint NOT NULL,
    teslim_sekli character varying(16) NOT NULL,
    aciklama character varying(96) NOT NULL,
    is_efatura boolean DEFAULT false
);
 -   DROP TABLE public.set_einv_teslim_sekilleri;
       public         heap 	   ths_admin    false    10            $           1259    4047616    set_einv_teslim_sekli_id_seq    SEQUENCE     �   ALTER TABLE public.set_einv_teslim_sekilleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_einv_teslim_sekli_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    291            %           1259    4047618    set_prs_birimler    TABLE     �   CREATE TABLE public.set_prs_birimler (
    id bigint NOT NULL,
    birim character varying(32) NOT NULL,
    bolum_id bigint
);
 $   DROP TABLE public.set_prs_birimler;
       public         heap 	   ths_admin    false    10            &           1259    4047621    set_prs_birim_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_birimler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_birim_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    293    10            '           1259    4047623    set_prs_bolumler    TABLE     k   CREATE TABLE public.set_prs_bolumler (
    id bigint NOT NULL,
    bolum character varying(32) NOT NULL
);
 $   DROP TABLE public.set_prs_bolumler;
       public         heap 	   ths_admin    false    10            (           1259    4047626    set_prs_bolum_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_bolumler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_bolum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    295            )           1259    4047628    set_prs_ehliyetler    TABLE     o   CREATE TABLE public.set_prs_ehliyetler (
    id bigint NOT NULL,
    ehliyet character varying(32) NOT NULL
);
 &   DROP TABLE public.set_prs_ehliyetler;
       public         heap 	   ths_admin    false    10            *           1259    4047631    set_prs_ehliyet_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_ehliyetler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_ehliyet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    297            +           1259    4047633    set_prs_gorevler    TABLE     k   CREATE TABLE public.set_prs_gorevler (
    id bigint NOT NULL,
    gorev character varying(32) NOT NULL
);
 $   DROP TABLE public.set_prs_gorevler;
       public         heap 	   ths_admin    false    10            ,           1259    4047636    set_prs_gorev_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_gorevler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_gorev_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    299    10            -           1259    4047638    set_prs_lisanlar    TABLE     k   CREATE TABLE public.set_prs_lisanlar (
    id bigint NOT NULL,
    lisan character varying(16) NOT NULL
);
 $   DROP TABLE public.set_prs_lisanlar;
       public         heap 	   ths_admin    false    10            .           1259    4047641    set_prs_lisan_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_lisanlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_lisan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    301            /           1259    4047643    set_prs_lisan_seviyeleri    TABLE     |   CREATE TABLE public.set_prs_lisan_seviyeleri (
    id bigint NOT NULL,
    lisan_seviyesi character varying(16) NOT NULL
);
 ,   DROP TABLE public.set_prs_lisan_seviyeleri;
       public         heap 	   ths_admin    false    10            0           1259    4047646    set_prs_lisan_seviyesi_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_lisan_seviyeleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_lisan_seviyesi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    303    10            1           1259    4047648    set_prs_personel_tipleri    TABLE     {   CREATE TABLE public.set_prs_personel_tipleri (
    id bigint NOT NULL,
    personel_tipi character varying(32) NOT NULL
);
 ,   DROP TABLE public.set_prs_personel_tipleri;
       public         heap 	   ths_admin    false    10            2           1259    4047651    set_prs_personel_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_personel_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_personel_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    305            3           1259    4047653    set_prs_tasima_servisleri    TABLE     �   CREATE TABLE public.set_prs_tasima_servisleri (
    id bigint NOT NULL,
    arac_no smallint NOT NULL,
    arac_adi character varying(32) NOT NULL,
    rota double precision[]
);
 -   DROP TABLE public.set_prs_tasima_servisleri;
       public         heap 	   ths_admin    false    10            4           1259    4047659    set_prs_servis_araci_id_seq    SEQUENCE     �   ALTER TABLE public.set_prs_tasima_servisleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_prs_servis_araci_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    307            5           1259    4047661    set_sat_siparis_durum_id_seq    SEQUENCE     �   ALTER TABLE public.set_sls_order_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_sat_siparis_durum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    264    10            6           1259    4047663    set_sls_offer_status    TABLE     �   CREATE TABLE public.set_sls_offer_status (
    id bigint NOT NULL,
    teklif_durum character varying(32) NOT NULL,
    aciklama character varying(64)
);
 (   DROP TABLE public.set_sls_offer_status;
       public         heap 	   ths_admin    false    10            7           1259    4047666    set_sat_teklif_durum_id_seq    SEQUENCE     �   ALTER TABLE public.set_sls_offer_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_sat_teklif_durum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    310    10            8           1259    4047668    stk_ambarlar    TABLE       CREATE TABLE public.stk_ambarlar (
    id bigint NOT NULL,
    ambar_adi character varying(32),
    is_varsayilan_hammadde boolean DEFAULT false NOT NULL,
    is_varsayilan_uretim boolean DEFAULT false NOT NULL,
    is_varsayilan_satis boolean DEFAULT false NOT NULL
);
     DROP TABLE public.stk_ambarlar;
       public         heap 	   ths_admin    false    10            1           0    0    TABLE stk_ambarlar    COMMENT     X   COMMENT ON TABLE public.stk_ambarlar IS 'Stok hareketlerinin tutulduğu ambar bilgisi';
          public       	   ths_admin    false    312            9           1259    4047674    stk_cins_ozellikleri    TABLE     s  CREATE TABLE public.stk_cins_ozellikleri (
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
       public         heap 	   ths_admin    false    10            :           1259    4047680    stk_cins_ozelligi_id_seq    SEQUENCE     �   ALTER TABLE public.stk_cins_ozellikleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_cins_ozelligi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    313            ;           1259    4047682    stk_hareketler    TABLE       CREATE TABLE public.stk_hareketler (
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
       public         heap 	   ths_admin    false    10            <           1259    4047687    stk_hareketler_id_seq    SEQUENCE     �   ALTER TABLE public.stk_hareketler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_hareketler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    315            =           1259    4047689    stk_stok_ambar_id_seq    SEQUENCE     �   ALTER TABLE public.stk_ambarlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_stok_ambar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    312    10            >           1259    4047691    stk_stok_grubu_id_seq    SEQUENCE     �   ALTER TABLE public.stk_gruplar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_stok_grubu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    265            ?           1259    4047693    stk_stok_karti_id_seq    SEQUENCE     �   ALTER TABLE public.stk_stok_kartlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_stok_karti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    266            @           1259    4047695    stk_stok_karti_ozetleri    TABLE     g  CREATE TABLE public.stk_stok_karti_ozetleri (
    id bigint NOT NULL,
    stok_karti_id bigint NOT NULL,
    stok_miktar numeric(18,6) DEFAULT 0,
    donem_basi_miktar numeric(18,6) DEFAULT 0,
    donem_basi_tutar numeric(18,6) DEFAULT 0,
    ortalama_maliyet numeric(18,6) DEFAULT 0,
    giren_toplam numeric(18,6) DEFAULT 0,
    giren_toplam_maliyet numeric(18,6) DEFAULT 0,
    cikan_toplam numeric(18,6) DEFAULT 0,
    cikan_toplam_maliyet numeric(18,6) DEFAULT 0,
    son_alis_fiyat numeric(18,6),
    son_alis_para character varying(3),
    son_alis_tarih date,
    son_alis_miktar numeric(18,6) DEFAULT 0
);
 +   DROP TABLE public.stk_stok_karti_ozetleri;
       public         heap 	   ths_admin    false    10            A           1259    4047707    stk_stok_ozetleri_id_seq    SEQUENCE     �   ALTER TABLE public.stk_stok_karti_ozetleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stk_stok_ozetleri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    320    10            B           1259    4047709    sys_adresler    TABLE     �  CREATE TABLE public.sys_adresler (
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
       public         heap 	   ths_admin    false    10            C           1259    4047712    sys_adres_id_seq    SEQUENCE     �   ALTER TABLE public.sys_adresler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_adres_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    322    10            D           1259    4047714 	   sys_aylar    TABLE     e   CREATE TABLE public.sys_aylar (
    id bigint NOT NULL,
    ay_adi character varying(16) NOT NULL
);
    DROP TABLE public.sys_aylar;
       public         heap 	   ths_admin    false    10            E           1259    4047717    sys_ay_id_seq    SEQUENCE     �   ALTER TABLE public.sys_aylar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    324            F           1259    4047719    sys_bolgeler    TABLE     g   CREATE TABLE public.sys_bolgeler (
    id bigint NOT NULL,
    bolge character varying(64) NOT NULL
);
     DROP TABLE public.sys_bolgeler;
       public         heap 	   ths_admin    false    10            G           1259    4047722    sys_bolge_id_seq    SEQUENCE     �   ALTER TABLE public.sys_bolgeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_bolge_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    326    10            H           1259    4047724    sys_db_status    VIEW     �  CREATE VIEW public.sys_db_status AS
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
       public       	   ths_admin    false    10            I           1259    4047729    sys_ersim_haklari    TABLE     i  CREATE TABLE public.sys_ersim_haklari (
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
       public         heap 	   ths_admin    false    10            J           1259    4047737    sys_erisim_hakki_id_seq    SEQUENCE     �   ALTER TABLE public.sys_ersim_haklari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_erisim_hakki_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    329            K           1259    4047739    sys_grid_filtreler_siralamalar    TABLE     �   CREATE TABLE public.sys_grid_filtreler_siralamalar (
    id bigint NOT NULL,
    tablo_adi character varying(32),
    icerik character varying,
    is_siralama boolean DEFAULT false
);
 2   DROP TABLE public.sys_grid_filtreler_siralamalar;
       public         heap 	   ths_admin    false    10            L           1259    4047746    sys_grid_filtre_siralama_id_seq    SEQUENCE     �   ALTER TABLE public.sys_grid_filtreler_siralamalar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_filtre_siralama_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    331    10            M           1259    4047748    sys_grid_kolonlar    TABLE     �  CREATE TABLE public.sys_grid_kolonlar (
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
       public         heap 	   ths_admin    false    10            N           1259    4047763    sys_grid_kolon_id_seq    SEQUENCE     �   ALTER TABLE public.sys_grid_kolonlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_grid_kolon_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    333            O           1259    4047765 
   sys_gunler    TABLE     g   CREATE TABLE public.sys_gunler (
    id bigint NOT NULL,
    gun_adi character varying(16) NOT NULL
);
    DROP TABLE public.sys_gunler;
       public         heap 	   ths_admin    false    10            P           1259    4047768    sys_gun_id_seq    SEQUENCE     �   ALTER TABLE public.sys_gunler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_gun_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    335    10            Q           1259    4047770    sys_kaynak_gruplari    TABLE     m   CREATE TABLE public.sys_kaynak_gruplari (
    id bigint NOT NULL,
    grup character varying(64) NOT NULL
);
 '   DROP TABLE public.sys_kaynak_gruplari;
       public         heap 	   ths_admin    false    10            R           1259    4047773    sys_kaynak_grup_id_seq    SEQUENCE     �   ALTER TABLE public.sys_kaynak_gruplari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kaynak_grup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    337            S           1259    4047775    sys_kaynaklar    TABLE     �   CREATE TABLE public.sys_kaynaklar (
    id bigint NOT NULL,
    kaynak_kodu integer NOT NULL,
    kaynak_adi character varying(64) NOT NULL,
    kaynak_grup_id bigint NOT NULL
);
 !   DROP TABLE public.sys_kaynaklar;
       public         heap 	   ths_admin    false    10            T           1259    4047778    sys_kaynak_id_seq    SEQUENCE     �   ALTER TABLE public.sys_kaynaklar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kaynak_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    339    10            U           1259    4047780    sys_kullanicilar    TABLE     �  CREATE TABLE public.sys_kullanicilar (
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
       public         heap 	   ths_admin    false    10            V           1259    4047790    sys_kullanici_id_seq    SEQUENCE     �   ALTER TABLE public.sys_kullanicilar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_kullanici_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    341            W           1259    4047792    sys_lisan_gui_icerikler    TABLE     R  CREATE TABLE public.sys_lisan_gui_icerikler (
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
       public         heap 	   ths_admin    false    10            X           1259    4047799    sys_lisan_gui_icerik_id_seq    SEQUENCE     �   ALTER TABLE public.sys_lisan_gui_icerikler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_lisan_gui_icerik_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    343            Y           1259    4047801    sys_lisanlar    TABLE     g   CREATE TABLE public.sys_lisanlar (
    id bigint NOT NULL,
    lisan character varying(16) NOT NULL
);
     DROP TABLE public.sys_lisanlar;
       public         heap 	   ths_admin    false    10            Z           1259    4047804    sys_lisan_id_seq    SEQUENCE     �   ALTER TABLE public.sys_lisanlar ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_lisan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    345    10            [           1259    4047806    sys_vergi_mukellef_tipleri    TABLE     �   CREATE TABLE public.sys_vergi_mukellef_tipleri (
    id bigint NOT NULL,
    mukellef_tipi character varying(32) NOT NULL,
    is_varsayilan boolean DEFAULT false NOT NULL
);
 .   DROP TABLE public.sys_vergi_mukellef_tipleri;
       public         heap 	   ths_admin    false    10            \           1259    4047810    sys_mukellef_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_vergi_mukellef_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_mukellef_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    347    10            ]           1259    4047812    sys_olcu_birimleri    TABLE       CREATE TABLE public.sys_olcu_birimleri (
    id bigint NOT NULL,
    birim character varying(16) NOT NULL,
    birim_einv character varying(3),
    aciklama character varying(64),
    is_ondalik boolean DEFAULT false NOT NULL,
    birim_tipi_id bigint,
    carpan integer
);
 &   DROP TABLE public.sys_olcu_birimleri;
       public         heap 	   ths_admin    false    10            ^           1259    4047816    sys_olcu_birimi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_olcu_birimleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_olcu_birimi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    349            _           1259    4047818    sys_olcu_birimi_tipleri    TABLE     }   CREATE TABLE public.sys_olcu_birimi_tipleri (
    id bigint NOT NULL,
    olcu_birimi_tipi character varying(16) NOT NULL
);
 +   DROP TABLE public.sys_olcu_birimi_tipleri;
       public         heap 	   ths_admin    false    10            `           1259    4047821    sys_olcu_birimi_tipi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_olcu_birimi_tipleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_olcu_birimi_tipi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    351            a           1259    4047823    sys_ondalik_haneler    TABLE     �   CREATE TABLE public.sys_ondalik_haneler (
    id bigint NOT NULL,
    miktar smallint DEFAULT 2,
    fiyat smallint DEFAULT 2,
    tutar smallint DEFAULT 2,
    stok_miktar smallint DEFAULT 4,
    doviz_kuru smallint DEFAULT 4
);
 '   DROP TABLE public.sys_ondalik_haneler;
       public         heap 	   ths_admin    false    10            b           1259    4047831    sys_ondalik_hane_id_seq    SEQUENCE     �   ALTER TABLE public.sys_ondalik_haneler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ondalik_hane_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    353            c           1259    4047833    sys_para_birimleri    TABLE     �   CREATE TABLE public.sys_para_birimleri (
    id bigint NOT NULL,
    para character varying(3) NOT NULL,
    sembol character varying(3) NOT NULL,
    aciklama character varying(128)
);
 &   DROP TABLE public.sys_para_birimleri;
       public         heap 	   ths_admin    false    10            d           1259    4047836    sys_para_birimi_id_seq    SEQUENCE     �   ALTER TABLE public.sys_para_birimleri ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_para_birimi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    355    10            e           1259    4047838    sys_sehir_id_seq    SEQUENCE     �   ALTER TABLE public.sys_sehirler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_sehir_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    267    10            f           1259    4047840    sys_ulkeler    TABLE       CREATE TABLE public.sys_ulkeler (
    id bigint NOT NULL,
    ulke_kodu character varying(2) NOT NULL,
    ulke_adi character varying(128) NOT NULL,
    iso_year integer,
    iso_cctld character varying(3),
    is_eu_member boolean DEFAULT false NOT NULL
);
    DROP TABLE public.sys_ulkeler;
       public         heap 	   ths_admin    false    10            g           1259    4047844    sys_ulke_id_seq    SEQUENCE     �   ALTER TABLE public.sys_ulkeler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_ulke_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    358    10            h           1259    4047846    sys_uygulama_ayarlari    TABLE     >  CREATE TABLE public.sys_uygulama_ayarlari (
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
       public         heap 	   ths_admin    false    10            i           1259    4047859    sys_uygulama_ayari_id_seq    SEQUENCE     �   ALTER TABLE public.sys_uygulama_ayarlari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sys_uygulama_ayari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    360    10            j           1259    4047861    sys_view_tables    VIEW     �  CREATE VIEW public.sys_view_tables AS
 SELECT (row_number() OVER (ORDER BY tables.table_type, tables.table_name))::integer AS id,
    initcap(replace((tables.table_name)::text, '_'::text, ' '::text)) AS table_name,
    (tables.table_type)::text AS table_type
   FROM information_schema.tables
  WHERE ((tables.table_schema)::text = 'public'::text)
  ORDER BY tables.table_type, tables.table_name;
 "   DROP VIEW public.sys_view_tables;
       public       	   ths_admin    false    10            k           1259    4047865    sys_view_columns    VIEW     '  CREATE VIEW public.sys_view_columns AS
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
       public       	   ths_admin    false    362    362    10            l           1259    4047870    sys_view_databases    VIEW     >  CREATE VIEW public.sys_view_databases AS
 SELECT (pg_database.datname)::text AS database_name,
    pg_shdescription.description AS aciklama
   FROM (pg_shdescription
     JOIN pg_database ON ((pg_shdescription.objoid = pg_database.oid)))
  WHERE ((1 = 1) AND (pg_shdescription.description = 'THS ERP Systems'::text));
 %   DROP VIEW public.sys_view_databases;
       public       	   ths_admin    false    10            m           1259    4047874    urt_recete_yan_urunler    TABLE     �   CREATE TABLE public.urt_recete_yan_urunler (
    id bigint NOT NULL,
    header_id bigint NOT NULL,
    urun_kodu character varying(32) NOT NULL,
    miktar numeric(18,6) NOT NULL
);
 *   DROP TABLE public.urt_recete_yan_urunler;
       public         heap 	   ths_admin    false    10            n           1259    4047877    urt_recete_yan_urunler_id_seq    SEQUENCE     �   ALTER TABLE public.urt_recete_yan_urunler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.urt_recete_yan_urunler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   ths_admin    false    10    365            K          0    4047294    audits 
   TABLE DATA           �   COPY public.audits (id, user_name, ip_address, table_name, access_type, time_of_change, row_id, client_username, old_val, new_val) FROM stdin;
    public       	   ths_admin    false    212   �/      O          0    4047307    ch_banka_subeleri 
   TABLE DATA           X   COPY public.ch_banka_subeleri (id, banka_id, sube_kodu, sube_adi, sehir_id) FROM stdin;
    public       	   ths_admin    false    216   �/      M          0    4047302    ch_bankalar 
   TABLE DATA           @   COPY public.ch_bankalar (id, banka_adi, swift_kodu) FROM stdin;
    public       	   ths_admin    false    214   ;0      Q          0    4047312    ch_bolgeler 
   TABLE DATA           0   COPY public.ch_bolgeler (id, bolge) FROM stdin;
    public       	   ths_admin    false    218   {0      S          0    4047317    ch_doviz_kurlari 
   TABLE DATA           E   COPY public.ch_doviz_kurlari (id, kur_tarihi, kur, para) FROM stdin;
    public       	   ths_admin    false    220   �0      T          0    4047320 
   ch_gruplar 
   TABLE DATA           .   COPY public.ch_gruplar (id, grup) FROM stdin;
    public       	   ths_admin    false    221   e1      W          0    4047333    ch_hesap_planlari 
   TABLE DATA           L   COPY public.ch_hesap_planlari (id, plan_kodu, plan_adi, seviye) FROM stdin;
    public       	   ths_admin    false    224   �1      U          0    4047323    ch_hesaplar 
   TABLE DATA           �  COPY public.ch_hesaplar (id, hesap_kodu, hesap_ismi, hesap_tipi_id, grup_id, bolge_id, mukellef_tipi_id, mukellef_adi, mukellef_adi2, mukellef_soyadi, vergi_dairesi, vergi_no, iban, iban_para, nace, yetkili1, yetkili1_tel, yetkili2, yetkili2_tel, yetkili3, yetkili3_tel, faks, muhasebe_telefon, muhasebe_email, muhasebe_yetkili, ozel_not, kok_kod, ara_kod, iskonto, efatura_kullaniyor, efatura_pb_name, adres_id) FROM stdin;
    public       	   ths_admin    false    222   �?      Y          0    4047338    prs_lisan_bilgileri 
   TABLE DATA           h   COPY public.prs_lisan_bilgileri (id, lisan_id, okuma_id, yazma_id, konusma_id, personel_id) FROM stdin;
    public       	   ths_admin    false    226   �R      [          0    4047343    prs_personel_ehliyetleri 
   TABLE DATA           O   COPY public.prs_personel_ehliyetleri (id, ehliyet_id, personel_id) FROM stdin;
    public       	   ths_admin    false    228   �R      ]          0    4047348    prs_personeller 
   TABLE DATA           b  COPY public.prs_personeller (id, ad, soyad, ad_soyad, tel1, tel2, personel_tipi_id, birim_id, gorev_id, dogum_tarihi, kan_grubu, cinsiyet, askerlik_durumu, medeni_durum, cocuk_sayisi, yakin_adi, yakin_telefon, ayakkabi_no, elbise_bedeni, genel_not, tasima_servis_id, ozel_not, maas, ikramiye_sayisi, ikramiye_tutar, identification, adres_id) FROM stdin;
    public       	   ths_admin    false    230   S      �          0    4047561    set_ch_firma_tipleri 
   TABLE DATA           M   COPY public.set_ch_firma_tipleri (id, firma_turu_id, firma_tipi) FROM stdin;
    public       	   ths_admin    false    273   �S      �          0    4047566    set_ch_firma_turleri 
   TABLE DATA           >   COPY public.set_ch_firma_turleri (id, firma_turu) FROM stdin;
    public       	   ths_admin    false    275   OT      �          0    4047575    set_ch_hesap_tipleri 
   TABLE DATA           >   COPY public.set_ch_hesap_tipleri (id, hesap_tipi) FROM stdin;
    public       	   ths_admin    false    279   T      �          0    4047580    set_ch_vergi_oranlari 
   TABLE DATA           �   COPY public.set_ch_vergi_oranlari (id, vergi_orani, satis_hesap_kodu, satis_iade_hesap_kodu, alis_hesap_kodu, alis_iade_hesap_kodu, ihrac_hesap_kodu, ihrac_iade_hesap_kodu) FROM stdin;
    public       	   ths_admin    false    281   �T      �          0    4047585    set_einv_fatura_tipleri 
   TABLE DATA           B   COPY public.set_einv_fatura_tipleri (id, fatura_tipi) FROM stdin;
    public       	   ths_admin    false    283   �T      �          0    4047590    set_einv_odeme_sekilleri 
   TABLE DATA           ^   COPY public.set_einv_odeme_sekilleri (id, odeme_sekli, kod, aciklama, is_efatura) FROM stdin;
    public       	   ths_admin    false    285   WU      �          0    4047599    set_einv_paket_tipleri 
   TABLE DATA           O   COPY public.set_einv_paket_tipleri (id, kod, paket_tipi, aciklama) FROM stdin;
    public       	   ths_admin    false    287   �V      �          0    4047607    set_einv_tasima_ucretleri 
   TABLE DATA           F   COPY public.set_einv_tasima_ucretleri (id, tasima_ucreti) FROM stdin;
    public       	   ths_admin    false    289   �V      �          0    4047612    set_einv_teslim_sekilleri 
   TABLE DATA           [   COPY public.set_einv_teslim_sekilleri (id, teslim_sekli, aciklama, is_efatura) FROM stdin;
    public       	   ths_admin    false    291   $W      �          0    4047618    set_prs_birimler 
   TABLE DATA           ?   COPY public.set_prs_birimler (id, birim, bolum_id) FROM stdin;
    public       	   ths_admin    false    293   +Y      �          0    4047623    set_prs_bolumler 
   TABLE DATA           5   COPY public.set_prs_bolumler (id, bolum) FROM stdin;
    public       	   ths_admin    false    295   _Y      �          0    4047628    set_prs_ehliyetler 
   TABLE DATA           9   COPY public.set_prs_ehliyetler (id, ehliyet) FROM stdin;
    public       	   ths_admin    false    297   �Y      �          0    4047633    set_prs_gorevler 
   TABLE DATA           5   COPY public.set_prs_gorevler (id, gorev) FROM stdin;
    public       	   ths_admin    false    299   �Y      �          0    4047643    set_prs_lisan_seviyeleri 
   TABLE DATA           F   COPY public.set_prs_lisan_seviyeleri (id, lisan_seviyesi) FROM stdin;
    public       	   ths_admin    false    303   �Y      �          0    4047638    set_prs_lisanlar 
   TABLE DATA           5   COPY public.set_prs_lisanlar (id, lisan) FROM stdin;
    public       	   ths_admin    false    301   8Z      �          0    4047648    set_prs_personel_tipleri 
   TABLE DATA           E   COPY public.set_prs_personel_tipleri (id, personel_tipi) FROM stdin;
    public       	   ths_admin    false    305   dZ      �          0    4047653    set_prs_tasima_servisleri 
   TABLE DATA           P   COPY public.set_prs_tasima_servisleri (id, arac_no, arac_adi, rota) FROM stdin;
    public       	   ths_admin    false    307   �Z      �          0    4047663    set_sls_offer_status 
   TABLE DATA           J   COPY public.set_sls_offer_status (id, teklif_durum, aciklama) FROM stdin;
    public       	   ths_admin    false    310   �Z                0    4047482    set_sls_order_status 
   TABLE DATA           K   COPY public.set_sls_order_status (id, siparis_durum, aciklama) FROM stdin;
    public       	   ths_admin    false    264   �Z      w          0    4047422    sls_dispatch_note_details 
   TABLE DATA           v   COPY public.sls_dispatch_note_details (id, header_id, teklif_detay_id, siparis_detay_id, fatura_detay_id) FROM stdin;
    public       	   ths_admin    false    256   T[      y          0    4047427    sls_dispatch_notes 
   TABLE DATA           p   COPY public.sls_dispatch_notes (id, irsaliye_no, irsaliye_tarihi, teklif_id, siparis_id, fatura_id) FROM stdin;
    public       	   ths_admin    false    258   q[      s          0    4047412    sls_invoice_details 
   TABLE DATA           r   COPY public.sls_invoice_details (id, header_id, teklif_detay_id, siparis_detay_id, irsaliye_detay_id) FROM stdin;
    public       	   ths_admin    false    252   �[      u          0    4047417    sls_invoices 
   TABLE DATA           h   COPY public.sls_invoices (id, fatura_no, fatura_tarihi, teklif_id, siparis_id, irsaliye_id) FROM stdin;
    public       	   ths_admin    false    254   �[      �          0    4047518    sls_offer_details 
   TABLE DATA           O  COPY public.sls_offer_details (id, header_id, siparis_detay_id, irsaliye_detay_id, fatura_detay_id, stok_kodu, stok_aciklama, kullanici_aciklama, referans, miktar, olcu_birimi, iskonto_orani, kdv_orani, fiyat, net_fiyat, tutar, iskonto_tutar, net_tutar, kdv_tutar, toplam_tutar, is_ana_urun, referans_ana_urun_id, gtip_no) FROM stdin;
    public       	   ths_admin    false    269   �[      �          0    4047537 
   sls_offers 
   TABLE DATA           �  COPY public.sls_offers (id, siparis_id, irsaliye_id, fatura_id, is_siparislesti, tutar, iskonto_tutar, ara_toplam, kdv_oran1, kdv_tutar1, kdv_oran2, kdv_tutar2, kdv_oran3, kdv_tutar3, kdv_oran4, kdv_tutar4, kdv_oran5, kdv_tutar5, genel_toplam, islem_tipi_id, teklif_no, teklif_tarihi, gecerlilik_tarihi, musteri_kodu, musteri_adi, vergi_dairesi, vergi_no, ulke_id, sehir_id, ilce, mahalle, cadde, sokak, posta_kodu, bina_adi, kapi_no, musteri_temsilcisi_id, muhattap_ad, muhattap_telefon, referans, para_birimi, doviz_kuru_usd, doviz_kuru_eur, aciklama, proforma_no, teslim_sekli_id, odeme_sekli_id, paket_tipi_id, tasima_ucreti_id) FROM stdin;
    public       	   ths_admin    false    271   �\      {          0    4047432    sls_order_details 
   TABLE DATA           �  COPY public.sls_order_details (id, header_id, teklif_detay_id, irsaliye_detay_id, fatura_detay_id, stok_kodu, stok_aciklama, kullanici_aciklama, referans, miktar, giden_miktar, olcu_birimi, iskonto_orani, kdv_orani, fiyat, net_fiyat, tutar, iskonto_tutar, net_tutar, kdv_tutar, toplam_tutar, is_ana_urun, referans_ana_urun_id, gtip_no, en, boy, yukseklik, net_agirlik, brut_agirlik, hacim, kab) FROM stdin;
    public       	   ths_admin    false    260   �]      }          0    4047458 
   sls_orders 
   TABLE DATA           q  COPY public.sls_orders (id, teklif_id, irsaliye_id, fatura_id, tutar, iskonto_tutar, ara_toplam, kdv_oran1, kdv_tutar1, kdv_oran2, kdv_tutar2, kdv_oran3, kdv_tutar3, kdv_oran4, kdv_tutar4, kdv_oran5, kdv_tutar5, genel_toplam, islem_tipi_id, siparis_no, siparis_tarihi, teslim_tarihi, musteri_kodu, musteri_adi, vergi_dairesi, vergi_no, ulke_id, sehir_id, ilce, mahalle, cadde, sokak, posta_kodu, bina_adi, kapi_no, musteri_temsilcisi_id, muhattap_ad, referans, para_birimi, doviz_kuru_usd, doviz_kuru_eur, aciklama, proforma_no, siparis_durum_id, teslim_sekli_id, odeme_sekli_id, paket_tipi_id, tasima_ucreti_id) FROM stdin;
    public       	   ths_admin    false    262   �]      �          0    4047668    stk_ambarlar 
   TABLE DATA           x   COPY public.stk_ambarlar (id, ambar_adi, is_varsayilan_hammadde, is_varsayilan_uretim, is_varsayilan_satis) FROM stdin;
    public       	   ths_admin    false    312   �]      �          0    4047674    stk_cins_ozellikleri 
   TABLE DATA           �   COPY public.stk_cins_ozellikleri (id, cins, aciklama, s1, s2, s3, s4, s5, s6, s7, s8, i1, i2, i3, i4, d1, d2, d3, d4) FROM stdin;
    public       	   ths_admin    false    313   �]      �          0    4047485    stk_gruplar 
   TABLE DATA           �   COPY public.stk_gruplar (id, grup, kdv_orani, satis_hesap_kodu, satis_iade_hesap_kodu, alis_hesap_kodu, alis_iade_hesap_kodu, ihracat_hesap_kodu, ihracat_iade_hesap_kodu, hammadde_hesap_kodu, mamul_hesap_kodu) FROM stdin;
    public       	   ths_admin    false    265   j^      �          0    4047682    stk_hareketler 
   TABLE DATA           �   COPY public.stk_hareketler (id, stok_kodu, miktar, tutar, tutar_doviz, para_birimi, is_giris, tarih, veren_ambar_id, alan_ambar_id, is_donem_basi, aciklama, irsaliye_id, uretim_id) FROM stdin;
    public       	   ths_admin    false    315   �^      �          0    4047695    stk_stok_karti_ozetleri 
   TABLE DATA             COPY public.stk_stok_karti_ozetleri (id, stok_karti_id, stok_miktar, donem_basi_miktar, donem_basi_tutar, ortalama_maliyet, giren_toplam, giren_toplam_maliyet, cikan_toplam, cikan_toplam_maliyet, son_alis_fiyat, son_alis_para, son_alis_tarih, son_alis_miktar) FROM stdin;
    public       	   ths_admin    false    320   �^      �          0    4047488    stk_stok_kartlari 
   TABLE DATA           �  COPY public.stk_stok_kartlari (id, is_satilabilir, stok_kodu, stok_adi, stok_grubu_id, olcu_birimi_id, urun_tipi, alis_iskonto, satis_iskonto, alis_fiyat, alis_para, satis_fiyat, satis_para, ihrac_fiyat, ihrac_para, ortalama_maliyet, en, boy, yukseklik, agirlik, temin_suresi, ozel_kod, marka, mensei_id, gtip_no, diib_urun_tanimi, en_az_stok_seviyesi, tanim, stok_resim, cins_id, s1, s2, s3, s4, s5, s6, s7, s8, i1, i2, i3, d1, d2, d3, i4, d4) FROM stdin;
    public       	   ths_admin    false    266   �^      �          0    4047709    sys_adresler 
   TABLE DATA           �   COPY public.sys_adresler (id, sehir_id, mahalle, cadde, sokak, bina_adi, kapi_no, posta_kutusu, posta_kodu, web, email) FROM stdin;
    public       	   ths_admin    false    322   6      �          0    4047714 	   sys_aylar 
   TABLE DATA           /   COPY public.sys_aylar (id, ay_adi) FROM stdin;
    public       	   ths_admin    false    324   �      �          0    4047719    sys_bolgeler 
   TABLE DATA           1   COPY public.sys_bolgeler (id, bolge) FROM stdin;
    public       	   ths_admin    false    326   
      �          0    4047729    sys_ersim_haklari 
   TABLE DATA              COPY public.sys_ersim_haklari (id, kaynak_id, is_okuma, is_ekleme, is_guncelleme, is_silme, is_ozel, kullanici_id) FROM stdin;
    public       	   ths_admin    false    329   j      �          0    4047739    sys_grid_filtreler_siralamalar 
   TABLE DATA           \   COPY public.sys_grid_filtreler_siralamalar (id, tablo_adi, icerik, is_siralama) FROM stdin;
    public       	   ths_admin    false    331   /      �          0    4047748    sys_grid_kolonlar 
   TABLE DATA           �   COPY public.sys_grid_kolonlar (id, tablo_adi, kolon_adi, sira_no, kolon_genislik, veri_formati, is_gorunur, is_helper_gorunur, min_deger, min_renk, maks_deger, maks_renk, maks_deger_yuzdesi, bar_rengi, bar_arka_rengi, bar_yazi_rengi) FROM stdin;
    public       	   ths_admin    false    333   L      �          0    4047765 
   sys_gunler 
   TABLE DATA           1   COPY public.sys_gunler (id, gun_adi) FROM stdin;
    public       	   ths_admin    false    335         �          0    4047770    sys_kaynak_gruplari 
   TABLE DATA           7   COPY public.sys_kaynak_gruplari (id, grup) FROM stdin;
    public       	   ths_admin    false    337   i      �          0    4047775    sys_kaynaklar 
   TABLE DATA           T   COPY public.sys_kaynaklar (id, kaynak_kodu, kaynak_adi, kaynak_grup_id) FROM stdin;
    public       	   ths_admin    false    339   �      �          0    4047780    sys_kullanicilar 
   TABLE DATA           �   COPY public.sys_kullanicilar (id, kullanici_adi, kullanici_sifre, is_aktif, is_yonetici, is_super_kullanici, ip_adres, mac_adres, personel_id) FROM stdin;
    public       	   ths_admin    false    341         �          0    4047792    sys_lisan_gui_icerikler 
   TABLE DATA           v   COPY public.sys_lisan_gui_icerikler (id, lisan, kod, deger, is_fabrika, icerik_tipi, tablo_adi, form_adi) FROM stdin;
    public       	   ths_admin    false    343   �      �          0    4047801    sys_lisanlar 
   TABLE DATA           1   COPY public.sys_lisanlar (id, lisan) FROM stdin;
    public       	   ths_admin    false    345   �      �          0    4047818    sys_olcu_birimi_tipleri 
   TABLE DATA           G   COPY public.sys_olcu_birimi_tipleri (id, olcu_birimi_tipi) FROM stdin;
    public       	   ths_admin    false    351   �      �          0    4047812    sys_olcu_birimleri 
   TABLE DATA           p   COPY public.sys_olcu_birimleri (id, birim, birim_einv, aciklama, is_ondalik, birim_tipi_id, carpan) FROM stdin;
    public       	   ths_admin    false    349   !      �          0    4047823    sys_ondalik_haneler 
   TABLE DATA           `   COPY public.sys_ondalik_haneler (id, miktar, fiyat, tutar, stok_miktar, doviz_kuru) FROM stdin;
    public       	   ths_admin    false    353   �      �          0    4047833    sys_para_birimleri 
   TABLE DATA           H   COPY public.sys_para_birimleri (id, para, sembol, aciklama) FROM stdin;
    public       	   ths_admin    false    355         �          0    4047510    sys_sehirler 
   TABLE DATA           P   COPY public.sys_sehirler (id, sehir, plaka_kodu, ulke_id, bolge_id) FROM stdin;
    public       	   ths_admin    false    267   �      �          0    4047840    sys_ulkeler 
   TABLE DATA           a   COPY public.sys_ulkeler (id, ulke_kodu, ulke_adi, iso_year, iso_cctld, is_eu_member) FROM stdin;
    public       	   ths_admin    false    358   #      �          0    4047846    sys_uygulama_ayarlari 
   TABLE DATA           @  COPY public.sys_uygulama_ayarlari (id, logo, unvan, telefon, faks, vergi_dairesi, vergi_no, donem, lisan, mail_sunucu, mail_kullanici, mail_sifre, mail_smtp_port, grid_renk_1, grid_renk_2, grid_renk_aktif, crypt_key, sms_sunucu, sms_kullanici, sms_sifre, sms_baslik, versiyon, para, adres_id, diger_ayarlar) FROM stdin;
    public       	   ths_admin    false    360   ~1      �          0    4047806    sys_vergi_mukellef_tipleri 
   TABLE DATA           V   COPY public.sys_vergi_mukellef_tipleri (id, mukellef_tipi, is_varsayilan) FROM stdin;
    public       	   ths_admin    false    347   �      _          0    4047360    urt_iscilikler 
   TABLE DATA           `   COPY public.urt_iscilikler (id, gider_kodu, gider_adi, fiyat, birim_id, gider_tipi) FROM stdin;
    public       	   ths_admin    false    232   =�      a          0    4047365    urt_paket_hammadde_detaylari 
   TABLE DATA           c   COPY public.urt_paket_hammadde_detaylari (id, header_id, recete_id, stok_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    234   ��      c          0    4047370    urt_paket_hammaddeler 
   TABLE DATA           >   COPY public.urt_paket_hammaddeler (id, paket_adi) FROM stdin;
    public       	   ths_admin    false    236   ��      e          0    4047375    urt_paket_iscilik_detaylari 
   TABLE DATA           Z   COPY public.urt_paket_iscilik_detaylari (id, header_id, iscilik_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    238   ��      g          0    4047380    urt_paket_iscilikler 
   TABLE DATA           =   COPY public.urt_paket_iscilikler (id, paket_adi) FROM stdin;
    public       	   ths_admin    false    240   �      i          0    4047385    urt_recete_hammaddeler 
   TABLE DATA           i   COPY public.urt_recete_hammaddeler (id, header_id, recete_id, stok_kodu, miktar, fire_orani) FROM stdin;
    public       	   ths_admin    false    242   /�      m          0    4047397    urt_recete_iscilikler 
   TABLE DATA           T   COPY public.urt_recete_iscilikler (id, header_id, iscilik_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    246   ~�      o          0    4047402    urt_recete_paket_hammaddeler 
   TABLE DATA           W   COPY public.urt_recete_paket_hammaddeler (id, header_id, paket_id, miktar) FROM stdin;
    public       	   ths_admin    false    248   ��      q          0    4047407    urt_recete_paket_iscilikler 
   TABLE DATA           V   COPY public.urt_recete_paket_iscilikler (id, header_id, paket_id, miktar) FROM stdin;
    public       	   ths_admin    false    250   ʍ      �          0    4047874    urt_recete_yan_urunler 
   TABLE DATA           R   COPY public.urt_recete_yan_urunler (id, header_id, urun_kodu, miktar) FROM stdin;
    public       	   ths_admin    false    365   �      k          0    4047391    urt_receteler 
   TABLE DATA           Y   COPY public.urt_receteler (id, urun_kodu, urun_adi, ornek_miktari, aciklama) FROM stdin;
    public       	   ths_admin    false    244   �      2           0    0    a_invoices_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.a_invoices_id_seq', 10, true);
          public          postgres    false    211            3           0    0    audit_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.audit_id_seq', 1, false);
          public       	   ths_admin    false    213            4           0    0    ch_banka_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.ch_banka_id_seq', 6, true);
          public       	   ths_admin    false    215            5           0    0    ch_banka_subesi_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.ch_banka_subesi_id_seq', 6, true);
          public       	   ths_admin    false    217            6           0    0    ch_bolge_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.ch_bolge_id_seq', 17, true);
          public       	   ths_admin    false    219            7           0    0    ch_hesap_karti_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.ch_hesap_karti_id_seq', 311, true);
          public       	   ths_admin    false    223            8           0    0    mhs_doviz_kuru_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.mhs_doviz_kuru_id_seq', 265, true);
          public       	   ths_admin    false    225            9           0    0    prs_lisan_bilgisi_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.prs_lisan_bilgisi_id_seq', 2, false);
          public       	   ths_admin    false    227            :           0    0    prs_personel_ehliyetleri_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.prs_personel_ehliyetleri_id_seq', 1, false);
          public       	   ths_admin    false    229            ;           0    0    prs_personel_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.prs_personel_id_seq', 15, true);
          public       	   ths_admin    false    231            <           0    0    rct_iscilik_gideri_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.rct_iscilik_gideri_id_seq', 2, false);
          public       	   ths_admin    false    233            =           0    0    rct_paket_hammadde_detay_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.rct_paket_hammadde_detay_id_seq', 2, true);
          public       	   ths_admin    false    235            >           0    0    rct_paket_hammadde_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.rct_paket_hammadde_id_seq', 1, true);
          public       	   ths_admin    false    237            ?           0    0    rct_paket_iscilik_detay_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.rct_paket_iscilik_detay_id_seq', 1, false);
          public       	   ths_admin    false    239            @           0    0    rct_paket_iscilik_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.rct_paket_iscilik_id_seq', 1, false);
          public       	   ths_admin    false    241            A           0    0    rct_recete_hammadde_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.rct_recete_hammadde_id_seq', 18, true);
          public       	   ths_admin    false    243            B           0    0    rct_recete_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.rct_recete_id_seq', 9, true);
          public       	   ths_admin    false    245            C           0    0    rct_recete_iscilik_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.rct_recete_iscilik_id_seq', 2, true);
          public       	   ths_admin    false    247            D           0    0     rct_recete_paket_hammadde_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.rct_recete_paket_hammadde_id_seq', 1, false);
          public       	   ths_admin    false    249            E           0    0    rct_recete_paket_iscilik_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.rct_recete_paket_iscilik_id_seq', 1, false);
          public       	   ths_admin    false    251            F           0    0    sat_fatura_detay_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.sat_fatura_detay_id_seq', 1, false);
          public       	   ths_admin    false    253            G           0    0    sat_fatura_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sat_fatura_id_seq', 1, false);
          public       	   ths_admin    false    255            H           0    0    sat_irsaliye_detay_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sat_irsaliye_detay_id_seq', 1, false);
          public       	   ths_admin    false    257            I           0    0    sat_irsaliye_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.sat_irsaliye_id_seq', 1, false);
          public       	   ths_admin    false    259            J           0    0    sat_siparis_detay_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.sat_siparis_detay_id_seq', 1, false);
          public       	   ths_admin    false    261            K           0    0    sat_siparis_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sat_siparis_id_seq', 1, true);
          public       	   ths_admin    false    263            L           0    0    sat_teklif_detay_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.sat_teklif_detay_id_seq', 4, true);
          public       	   ths_admin    false    270            M           0    0    sat_teklif_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sat_teklif_id_seq', 1, true);
          public       	   ths_admin    false    272            N           0    0    set_ch_firma_tipi_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_firma_tipi_id_seq', 5, false);
          public       	   ths_admin    false    274            O           0    0    set_ch_firma_turu_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_firma_turu_id_seq', 2, false);
          public       	   ths_admin    false    276            P           0    0    set_ch_grup_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.set_ch_grup_id_seq', 71, false);
          public       	   ths_admin    false    277            Q           0    0    set_ch_hesap_plani_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_ch_hesap_plani_id_seq', 286, false);
          public       	   ths_admin    false    278            R           0    0    set_ch_hesap_tipi_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.set_ch_hesap_tipi_id_seq', 3, false);
          public       	   ths_admin    false    280            S           0    0    set_ch_vergi_orani_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.set_ch_vergi_orani_id_seq', 4, false);
          public       	   ths_admin    false    282            T           0    0    set_einv_fatura_tipi_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_einv_fatura_tipi_id_seq', 6, false);
          public       	   ths_admin    false    284            U           0    0    set_einv_odeme_sekli_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_einv_odeme_sekli_id_seq', 32, false);
          public       	   ths_admin    false    286            V           0    0    set_einv_paket_tipi_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.set_einv_paket_tipi_id_seq', 4, false);
          public       	   ths_admin    false    288            W           0    0    set_einv_tasima_ucreti_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_einv_tasima_ucreti_id_seq', 3, true);
          public       	   ths_admin    false    290            X           0    0    set_einv_teslim_sekli_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.set_einv_teslim_sekli_id_seq', 28, false);
          public       	   ths_admin    false    292            Y           0    0    set_prs_birim_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.set_prs_birim_id_seq', 41, false);
          public       	   ths_admin    false    294            Z           0    0    set_prs_bolum_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.set_prs_bolum_id_seq', 10, false);
          public       	   ths_admin    false    296            [           0    0    set_prs_ehliyet_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.set_prs_ehliyet_id_seq', 4, false);
          public       	   ths_admin    false    298            \           0    0    set_prs_gorev_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.set_prs_gorev_id_seq', 4, false);
          public       	   ths_admin    false    300            ]           0    0    set_prs_lisan_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.set_prs_lisan_id_seq', 3, false);
          public       	   ths_admin    false    302            ^           0    0    set_prs_lisan_seviyesi_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.set_prs_lisan_seviyesi_id_seq', 4, false);
          public       	   ths_admin    false    304            _           0    0    set_prs_personel_tipi_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_prs_personel_tipi_id_seq', 3, false);
          public       	   ths_admin    false    306            `           0    0    set_prs_servis_araci_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_prs_servis_araci_id_seq', 1, false);
          public       	   ths_admin    false    308            a           0    0    set_sat_siparis_durum_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.set_sat_siparis_durum_id_seq', 3, false);
          public       	   ths_admin    false    309            b           0    0    set_sat_teklif_durum_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.set_sat_teklif_durum_id_seq', 3, false);
          public       	   ths_admin    false    311            c           0    0    stk_cins_ozelligi_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.stk_cins_ozelligi_id_seq', 3, true);
          public       	   ths_admin    false    314            d           0    0    stk_hareketler_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.stk_hareketler_id_seq', 1, false);
          public       	   ths_admin    false    316            e           0    0    stk_stok_ambar_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.stk_stok_ambar_id_seq', 2, false);
          public       	   ths_admin    false    317            f           0    0    stk_stok_grubu_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.stk_stok_grubu_id_seq', 9, true);
          public       	   ths_admin    false    318            g           0    0    stk_stok_karti_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.stk_stok_karti_id_seq', 59, true);
          public       	   ths_admin    false    319            h           0    0    stk_stok_ozetleri_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.stk_stok_ozetleri_id_seq', 1, false);
          public       	   ths_admin    false    321            i           0    0    sys_adres_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.sys_adres_id_seq', 5014, false);
          public       	   ths_admin    false    323            j           0    0    sys_ay_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.sys_ay_id_seq', 24, true);
          public       	   ths_admin    false    325            k           0    0    sys_bolge_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sys_bolge_id_seq', 7, false);
          public       	   ths_admin    false    327            l           0    0    sys_erisim_hakki_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sys_erisim_hakki_id_seq', 1027, true);
          public       	   ths_admin    false    330            m           0    0    sys_grid_filtre_siralama_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.sys_grid_filtre_siralama_id_seq', 22, true);
          public       	   ths_admin    false    332            n           0    0    sys_grid_kolon_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.sys_grid_kolon_id_seq', 157, true);
          public       	   ths_admin    false    334            o           0    0    sys_gun_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.sys_gun_id_seq', 16, true);
          public       	   ths_admin    false    336            p           0    0    sys_kaynak_grup_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.sys_kaynak_grup_id_seq', 16, false);
          public       	   ths_admin    false    338            q           0    0    sys_kaynak_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sys_kaynak_id_seq', 44, true);
          public       	   ths_admin    false    340            r           0    0    sys_kullanici_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.sys_kullanici_id_seq', 66, true);
          public       	   ths_admin    false    342            s           0    0    sys_lisan_gui_icerik_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.sys_lisan_gui_icerik_id_seq', 169, true);
          public       	   ths_admin    false    344            t           0    0    sys_lisan_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sys_lisan_id_seq', 6, false);
          public       	   ths_admin    false    346            u           0    0    sys_mukellef_tipi_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.sys_mukellef_tipi_id_seq', 2, false);
          public       	   ths_admin    false    348            v           0    0    sys_olcu_birimi_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.sys_olcu_birimi_id_seq', 16, true);
          public       	   ths_admin    false    350            w           0    0    sys_olcu_birimi_tipi_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.sys_olcu_birimi_tipi_id_seq', 4, true);
          public       	   ths_admin    false    352            x           0    0    sys_ondalik_hane_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.sys_ondalik_hane_id_seq', 1, false);
          public       	   ths_admin    false    354            y           0    0    sys_para_birimi_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.sys_para_birimi_id_seq', 4, true);
          public       	   ths_admin    false    356            z           0    0    sys_sehir_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.sys_sehir_id_seq', 174, false);
          public       	   ths_admin    false    357            {           0    0    sys_ulke_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sys_ulke_id_seq', 321, true);
          public       	   ths_admin    false    359            |           0    0    sys_uygulama_ayari_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sys_uygulama_ayari_id_seq', 4, false);
          public       	   ths_admin    false    361            }           0    0    urt_recete_yan_urunler_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.urt_recete_yan_urunler_id_seq', 1, false);
          public       	   ths_admin    false    366            /           2606    4047882    audits audit_pkey 
   CONSTRAINT     O   ALTER TABLE ONLY public.audits
    ADD CONSTRAINT audit_pkey PRIMARY KEY (id);
 ;   ALTER TABLE ONLY public.audits DROP CONSTRAINT audit_pkey;
       public         	   ths_admin    false    212            5           2606    4047884 :   ch_banka_subeleri ch_banka_subeleri_banka_id_sube_kodu_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_banka_id_sube_kodu_key UNIQUE (banka_id, sube_kodu);
 d   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_banka_id_sube_kodu_key;
       public         	   ths_admin    false    216    216            7           2606    4047886 (   ch_banka_subeleri ch_banka_subeleri_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_pkey;
       public         	   ths_admin    false    216            1           2606    4047888 %   ch_bankalar ch_bankalar_banka_adi_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.ch_bankalar
    ADD CONSTRAINT ch_bankalar_banka_adi_key UNIQUE (banka_adi);
 O   ALTER TABLE ONLY public.ch_bankalar DROP CONSTRAINT ch_bankalar_banka_adi_key;
       public         	   ths_admin    false    214            3           2606    4047890    ch_bankalar ch_bankalar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ch_bankalar
    ADD CONSTRAINT ch_bankalar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ch_bankalar DROP CONSTRAINT ch_bankalar_pkey;
       public         	   ths_admin    false    214            9           2606    4047892 !   ch_bolgeler ch_bolgeler_bolge_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.ch_bolgeler
    ADD CONSTRAINT ch_bolgeler_bolge_key UNIQUE (bolge);
 K   ALTER TABLE ONLY public.ch_bolgeler DROP CONSTRAINT ch_bolgeler_bolge_key;
       public         	   ths_admin    false    218            ;           2606    4047894    ch_bolgeler ch_bolgeler_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ch_bolgeler
    ADD CONSTRAINT ch_bolgeler_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ch_bolgeler DROP CONSTRAINT ch_bolgeler_pkey;
       public         	   ths_admin    false    218            =           2606    4047896 5   ch_doviz_kurlari ch_doviz_kurlari_kur_tarihi_para_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_kur_tarihi_para_key UNIQUE (kur_tarihi, para);
 _   ALTER TABLE ONLY public.ch_doviz_kurlari DROP CONSTRAINT ch_doviz_kurlari_kur_tarihi_para_key;
       public         	   ths_admin    false    220    220            ?           2606    4047898 &   ch_doviz_kurlari ch_doviz_kurlari_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.ch_doviz_kurlari DROP CONSTRAINT ch_doviz_kurlari_pkey;
       public         	   ths_admin    false    220            A           2606    4047900    ch_gruplar ch_gruplar_grup_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.ch_gruplar
    ADD CONSTRAINT ch_gruplar_grup_key UNIQUE (grup);
 H   ALTER TABLE ONLY public.ch_gruplar DROP CONSTRAINT ch_gruplar_grup_key;
       public         	   ths_admin    false    221            C           2606    4047902    ch_gruplar ch_gruplar_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.ch_gruplar
    ADD CONSTRAINT ch_gruplar_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.ch_gruplar DROP CONSTRAINT ch_gruplar_pkey;
       public         	   ths_admin    false    221            I           2606    4047904 (   ch_hesap_planlari ch_hesap_planlari_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.ch_hesap_planlari
    ADD CONSTRAINT ch_hesap_planlari_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.ch_hesap_planlari DROP CONSTRAINT ch_hesap_planlari_pkey;
       public         	   ths_admin    false    224            E           2606    4047906 &   ch_hesaplar ch_hesaplar_hesap_kodu_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_hesap_kodu_key UNIQUE (hesap_kodu);
 P   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_hesap_kodu_key;
       public         	   ths_admin    false    222            G           2606    4047908    ch_hesaplar ch_hesaplar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_pkey;
       public         	   ths_admin    false    222            K           2606    4047910 @   prs_lisan_bilgileri prs_lisan_bilgileri_lisan_id_personel_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_lisan_id_personel_id_key UNIQUE (lisan_id, personel_id);
 j   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_lisan_id_personel_id_key;
       public         	   ths_admin    false    226    226            M           2606    4047912 ,   prs_lisan_bilgileri prs_lisan_bilgileri_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_pkey;
       public         	   ths_admin    false    226            O           2606    4047914 L   prs_personel_ehliyetleri prs_personel_ehliyetleri_ehliyet_id_personel_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.prs_personel_ehliyetleri
    ADD CONSTRAINT prs_personel_ehliyetleri_ehliyet_id_personel_id_key UNIQUE (ehliyet_id, personel_id);
 v   ALTER TABLE ONLY public.prs_personel_ehliyetleri DROP CONSTRAINT prs_personel_ehliyetleri_ehliyet_id_personel_id_key;
       public         	   ths_admin    false    228    228            Q           2606    4047916 6   prs_personel_ehliyetleri prs_personel_ehliyetleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.prs_personel_ehliyetleri
    ADD CONSTRAINT prs_personel_ehliyetleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.prs_personel_ehliyetleri DROP CONSTRAINT prs_personel_ehliyetleri_pkey;
       public         	   ths_admin    false    228            S           2606    4047918 $   prs_personeller prs_personeller_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_pkey;
       public         	   ths_admin    false    230            }           2606    4047920 )   sls_invoice_details sat_fatura_detay_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.sls_invoice_details
    ADD CONSTRAINT sat_fatura_detay_pkey PRIMARY KEY (id);
 S   ALTER TABLE ONLY public.sls_invoice_details DROP CONSTRAINT sat_fatura_detay_pkey;
       public         	   ths_admin    false    252                       2606    4047922    sls_invoices sat_fatura_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.sls_invoices
    ADD CONSTRAINT sat_fatura_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.sls_invoices DROP CONSTRAINT sat_fatura_pkey;
       public         	   ths_admin    false    254            �           2606    4047924 1   sls_dispatch_note_details sat_irsaliye_detay_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY public.sls_dispatch_note_details
    ADD CONSTRAINT sat_irsaliye_detay_pkey PRIMARY KEY (id);
 [   ALTER TABLE ONLY public.sls_dispatch_note_details DROP CONSTRAINT sat_irsaliye_detay_pkey;
       public         	   ths_admin    false    256            �           2606    4047926 $   sls_dispatch_notes sat_irsaliye_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.sls_dispatch_notes
    ADD CONSTRAINT sat_irsaliye_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.sls_dispatch_notes DROP CONSTRAINT sat_irsaliye_pkey;
       public         	   ths_admin    false    258            �           2606    4047928 (   sls_order_details sat_siparis_detay_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.sls_order_details
    ADD CONSTRAINT sat_siparis_detay_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.sls_order_details DROP CONSTRAINT sat_siparis_detay_pkey;
       public         	   ths_admin    false    260            �           2606    4047930    sls_orders sat_siparis_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.sls_orders
    ADD CONSTRAINT sat_siparis_pkey PRIMARY KEY (id);
 E   ALTER TABLE ONLY public.sls_orders DROP CONSTRAINT sat_siparis_pkey;
       public         	   ths_admin    false    262            �           2606    4047932 '   sls_offer_details sat_teklif_detay_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.sls_offer_details
    ADD CONSTRAINT sat_teklif_detay_pkey PRIMARY KEY (id);
 Q   ALTER TABLE ONLY public.sls_offer_details DROP CONSTRAINT sat_teklif_detay_pkey;
       public         	   ths_admin    false    269            �           2606    4047934    sls_offers sat_teklif_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.sls_offers
    ADD CONSTRAINT sat_teklif_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.sls_offers DROP CONSTRAINT sat_teklif_pkey;
       public         	   ths_admin    false    271            �           2606    4047936 #   sls_offers sat_teklif_teklif_no_key 
   CONSTRAINT     c   ALTER TABLE ONLY public.sls_offers
    ADD CONSTRAINT sat_teklif_teklif_no_key UNIQUE (teklif_no);
 M   ALTER TABLE ONLY public.sls_offers DROP CONSTRAINT sat_teklif_teklif_no_key;
       public         	   ths_admin    false    271            �           2606    4047938 9   set_ch_firma_turleri set_acc_firma_turleri_firma_turu_key 
   CONSTRAINT     z   ALTER TABLE ONLY public.set_ch_firma_turleri
    ADD CONSTRAINT set_acc_firma_turleri_firma_turu_key UNIQUE (firma_turu);
 c   ALTER TABLE ONLY public.set_ch_firma_turleri DROP CONSTRAINT set_acc_firma_turleri_firma_turu_key;
       public         	   ths_admin    false    275            �           2606    4047940 /   set_ch_firma_turleri set_acc_firma_turleri_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.set_ch_firma_turleri
    ADD CONSTRAINT set_acc_firma_turleri_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY public.set_ch_firma_turleri DROP CONSTRAINT set_acc_firma_turleri_pkey;
       public         	   ths_admin    false    275            �           2606    4047942 8   set_ch_firma_tipleri set_ch_firma_tipleri_firma_tipi_key 
   CONSTRAINT     y   ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_firma_tipi_key UNIQUE (firma_tipi);
 b   ALTER TABLE ONLY public.set_ch_firma_tipleri DROP CONSTRAINT set_ch_firma_tipleri_firma_tipi_key;
       public         	   ths_admin    false    273            �           2606    4047944 .   set_ch_firma_tipleri set_ch_firma_tipleri_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.set_ch_firma_tipleri DROP CONSTRAINT set_ch_firma_tipleri_pkey;
       public         	   ths_admin    false    273            �           2606    4047946 7   set_ch_hesap_tipleri set_ch_hesap_tipleri_hesa_tipi_key 
   CONSTRAINT     x   ALTER TABLE ONLY public.set_ch_hesap_tipleri
    ADD CONSTRAINT set_ch_hesap_tipleri_hesa_tipi_key UNIQUE (hesap_tipi);
 a   ALTER TABLE ONLY public.set_ch_hesap_tipleri DROP CONSTRAINT set_ch_hesap_tipleri_hesa_tipi_key;
       public         	   ths_admin    false    279            �           2606    4047948 .   set_ch_hesap_tipleri set_ch_hesap_tipleri_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.set_ch_hesap_tipleri
    ADD CONSTRAINT set_ch_hesap_tipleri_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.set_ch_hesap_tipleri DROP CONSTRAINT set_ch_hesap_tipleri_pkey;
       public         	   ths_admin    false    279            �           2606    4047950 0   set_ch_vergi_oranlari set_ch_vergi_oranlari_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_pkey;
       public         	   ths_admin    false    281            �           2606    4047952 :   set_ch_vergi_oranlari set_ch_vergi_oranlari_veri_orani_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_veri_orani_key UNIQUE (vergi_orani);
 d   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_veri_orani_key;
       public         	   ths_admin    false    281            �           2606    4047954 ?   set_einv_fatura_tipleri set_einv_fatura_tipleri_fatura_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_fatura_tipleri
    ADD CONSTRAINT set_einv_fatura_tipleri_fatura_tipi_key UNIQUE (fatura_tipi);
 i   ALTER TABLE ONLY public.set_einv_fatura_tipleri DROP CONSTRAINT set_einv_fatura_tipleri_fatura_tipi_key;
       public         	   ths_admin    false    283            �           2606    4047956 4   set_einv_fatura_tipleri set_einv_fatura_tipleri_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.set_einv_fatura_tipleri
    ADD CONSTRAINT set_einv_fatura_tipleri_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.set_einv_fatura_tipleri DROP CONSTRAINT set_einv_fatura_tipleri_pkey;
       public         	   ths_admin    false    283            �           2606    4047958 6   set_einv_odeme_sekilleri set_einv_odeme_sekilleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.set_einv_odeme_sekilleri
    ADD CONSTRAINT set_einv_odeme_sekilleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.set_einv_odeme_sekilleri DROP CONSTRAINT set_einv_odeme_sekilleri_pkey;
       public         	   ths_admin    false    285            �           2606    4047960 A   set_einv_odeme_sekilleri set_einv_odeme_sekli_odeme_sekilleri_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_odeme_sekilleri
    ADD CONSTRAINT set_einv_odeme_sekli_odeme_sekilleri_key UNIQUE (odeme_sekli);
 k   ALTER TABLE ONLY public.set_einv_odeme_sekilleri DROP CONSTRAINT set_einv_odeme_sekli_odeme_sekilleri_key;
       public         	   ths_admin    false    285            �           2606    4047962 5   set_einv_paket_tipleri set_einv_paket_tipleri_kod_key 
   CONSTRAINT     o   ALTER TABLE ONLY public.set_einv_paket_tipleri
    ADD CONSTRAINT set_einv_paket_tipleri_kod_key UNIQUE (kod);
 _   ALTER TABLE ONLY public.set_einv_paket_tipleri DROP CONSTRAINT set_einv_paket_tipleri_kod_key;
       public         	   ths_admin    false    287            �           2606    4047964 2   set_einv_paket_tipleri set_einv_paket_tipleri_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.set_einv_paket_tipleri
    ADD CONSTRAINT set_einv_paket_tipleri_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.set_einv_paket_tipleri DROP CONSTRAINT set_einv_paket_tipleri_pkey;
       public         	   ths_admin    false    287            �           2606    4047966 8   set_einv_tasima_ucretleri set_einv_tasima_ucretleri_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.set_einv_tasima_ucretleri
    ADD CONSTRAINT set_einv_tasima_ucretleri_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.set_einv_tasima_ucretleri DROP CONSTRAINT set_einv_tasima_ucretleri_pkey;
       public         	   ths_admin    false    289            �           2606    4047968 E   set_einv_tasima_ucretleri set_einv_tasima_ucretleri_tasima_ucreti_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_tasima_ucretleri
    ADD CONSTRAINT set_einv_tasima_ucretleri_tasima_ucreti_key UNIQUE (tasima_ucreti);
 o   ALTER TABLE ONLY public.set_einv_tasima_ucretleri DROP CONSTRAINT set_einv_tasima_ucretleri_tasima_ucreti_key;
       public         	   ths_admin    false    289            �           2606    4047970 8   set_einv_teslim_sekilleri set_einv_teslim_sekilleri_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.set_einv_teslim_sekilleri
    ADD CONSTRAINT set_einv_teslim_sekilleri_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.set_einv_teslim_sekilleri DROP CONSTRAINT set_einv_teslim_sekilleri_pkey;
       public         	   ths_admin    false    291            �           2606    4047972 D   set_einv_teslim_sekilleri set_einv_teslim_sekilleri_teslim_sekli_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_einv_teslim_sekilleri
    ADD CONSTRAINT set_einv_teslim_sekilleri_teslim_sekli_key UNIQUE (teslim_sekli);
 n   ALTER TABLE ONLY public.set_einv_teslim_sekilleri DROP CONSTRAINT set_einv_teslim_sekilleri_teslim_sekli_key;
       public         	   ths_admin    false    291            �           2606    4047974 4   set_prs_birimler set_prs_birimler_birim_bolum_id_key 
   CONSTRAINT     z   ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_birim_bolum_id_key UNIQUE (birim, bolum_id);
 ^   ALTER TABLE ONLY public.set_prs_birimler DROP CONSTRAINT set_prs_birimler_birim_bolum_id_key;
       public         	   ths_admin    false    293    293            �           2606    4047976 &   set_prs_birimler set_prs_birimler_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_birimler DROP CONSTRAINT set_prs_birimler_pkey;
       public         	   ths_admin    false    293            �           2606    4047978 +   set_prs_bolumler set_prs_bolumler_bolum_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.set_prs_bolumler
    ADD CONSTRAINT set_prs_bolumler_bolum_key UNIQUE (bolum);
 U   ALTER TABLE ONLY public.set_prs_bolumler DROP CONSTRAINT set_prs_bolumler_bolum_key;
       public         	   ths_admin    false    295            �           2606    4047980 &   set_prs_bolumler set_prs_bolumler_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_bolumler
    ADD CONSTRAINT set_prs_bolumler_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_bolumler DROP CONSTRAINT set_prs_bolumler_pkey;
       public         	   ths_admin    false    295            �           2606    4047982 1   set_prs_ehliyetler set_prs_ehliyetler_ehliyet_key 
   CONSTRAINT     o   ALTER TABLE ONLY public.set_prs_ehliyetler
    ADD CONSTRAINT set_prs_ehliyetler_ehliyet_key UNIQUE (ehliyet);
 [   ALTER TABLE ONLY public.set_prs_ehliyetler DROP CONSTRAINT set_prs_ehliyetler_ehliyet_key;
       public         	   ths_admin    false    297            �           2606    4047984 *   set_prs_ehliyetler set_prs_ehliyetler_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.set_prs_ehliyetler
    ADD CONSTRAINT set_prs_ehliyetler_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.set_prs_ehliyetler DROP CONSTRAINT set_prs_ehliyetler_pkey;
       public         	   ths_admin    false    297            �           2606    4047986 +   set_prs_gorevler set_prs_gorevler_gorev_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.set_prs_gorevler
    ADD CONSTRAINT set_prs_gorevler_gorev_key UNIQUE (gorev);
 U   ALTER TABLE ONLY public.set_prs_gorevler DROP CONSTRAINT set_prs_gorevler_gorev_key;
       public         	   ths_admin    false    299            �           2606    4047988 &   set_prs_gorevler set_prs_gorevler_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_gorevler
    ADD CONSTRAINT set_prs_gorevler_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_gorevler DROP CONSTRAINT set_prs_gorevler_pkey;
       public         	   ths_admin    false    299            �           2606    4047990 D   set_prs_lisan_seviyeleri set_prs_lisan_seviyeleri_lisan_seviyesi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri
    ADD CONSTRAINT set_prs_lisan_seviyeleri_lisan_seviyesi_key UNIQUE (lisan_seviyesi);
 n   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri DROP CONSTRAINT set_prs_lisan_seviyeleri_lisan_seviyesi_key;
       public         	   ths_admin    false    303            �           2606    4047992 6   set_prs_lisan_seviyeleri set_prs_lisan_seviyeleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri
    ADD CONSTRAINT set_prs_lisan_seviyeleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.set_prs_lisan_seviyeleri DROP CONSTRAINT set_prs_lisan_seviyeleri_pkey;
       public         	   ths_admin    false    303            �           2606    4047994 +   set_prs_lisanlar set_prs_lisanlar_lisan_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.set_prs_lisanlar
    ADD CONSTRAINT set_prs_lisanlar_lisan_key UNIQUE (lisan);
 U   ALTER TABLE ONLY public.set_prs_lisanlar DROP CONSTRAINT set_prs_lisanlar_lisan_key;
       public         	   ths_admin    false    301            �           2606    4047996 &   set_prs_lisanlar set_prs_lisanlar_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.set_prs_lisanlar
    ADD CONSTRAINT set_prs_lisanlar_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.set_prs_lisanlar DROP CONSTRAINT set_prs_lisanlar_pkey;
       public         	   ths_admin    false    301            �           2606    4047998 C   set_prs_personel_tipleri set_prs_personel_tipleri_personel_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_prs_personel_tipleri
    ADD CONSTRAINT set_prs_personel_tipleri_personel_tipi_key UNIQUE (personel_tipi);
 m   ALTER TABLE ONLY public.set_prs_personel_tipleri DROP CONSTRAINT set_prs_personel_tipleri_personel_tipi_key;
       public         	   ths_admin    false    305            �           2606    4048000 6   set_prs_personel_tipleri set_prs_personel_tipleri_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.set_prs_personel_tipleri
    ADD CONSTRAINT set_prs_personel_tipleri_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.set_prs_personel_tipleri DROP CONSTRAINT set_prs_personel_tipleri_pkey;
       public         	   ths_admin    false    305            �           2606    4048002 ?   set_prs_tasima_servisleri set_prs_tasima_servisleri_arac_no_key 
   CONSTRAINT     }   ALTER TABLE ONLY public.set_prs_tasima_servisleri
    ADD CONSTRAINT set_prs_tasima_servisleri_arac_no_key UNIQUE (arac_no);
 i   ALTER TABLE ONLY public.set_prs_tasima_servisleri DROP CONSTRAINT set_prs_tasima_servisleri_arac_no_key;
       public         	   ths_admin    false    307            �           2606    4048004 8   set_prs_tasima_servisleri set_prs_tasima_servisleri_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.set_prs_tasima_servisleri
    ADD CONSTRAINT set_prs_tasima_servisleri_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.set_prs_tasima_servisleri DROP CONSTRAINT set_prs_tasima_servisleri_pkey;
       public         	   ths_admin    false    307            �           2606    4048006 /   set_sls_order_status set_sat_siparis_durum_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.set_sls_order_status
    ADD CONSTRAINT set_sat_siparis_durum_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY public.set_sls_order_status DROP CONSTRAINT set_sat_siparis_durum_pkey;
       public         	   ths_admin    false    264            �           2606    4048008 <   set_sls_order_status set_sat_siparis_durum_siparis_durum_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.set_sls_order_status
    ADD CONSTRAINT set_sat_siparis_durum_siparis_durum_key UNIQUE (siparis_durum);
 f   ALTER TABLE ONLY public.set_sls_order_status DROP CONSTRAINT set_sat_siparis_durum_siparis_durum_key;
       public         	   ths_admin    false    264            �           2606    4048010 .   set_sls_offer_status set_sat_teklif_durum_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.set_sls_offer_status
    ADD CONSTRAINT set_sat_teklif_durum_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.set_sls_offer_status DROP CONSTRAINT set_sat_teklif_durum_pkey;
       public         	   ths_admin    false    310            �           2606    4048012 :   set_sls_offer_status set_sat_teklif_durum_teklif_durum_key 
   CONSTRAINT     }   ALTER TABLE ONLY public.set_sls_offer_status
    ADD CONSTRAINT set_sat_teklif_durum_teklif_durum_key UNIQUE (teklif_durum);
 d   ALTER TABLE ONLY public.set_sls_offer_status DROP CONSTRAINT set_sat_teklif_durum_teklif_durum_key;
       public         	   ths_admin    false    310            �           2606    4048014 '   stk_ambarlar stk_ambarlar_ambar_adi_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.stk_ambarlar
    ADD CONSTRAINT stk_ambarlar_ambar_adi_key UNIQUE (ambar_adi);
 Q   ALTER TABLE ONLY public.stk_ambarlar DROP CONSTRAINT stk_ambarlar_ambar_adi_key;
       public         	   ths_admin    false    312            �           2606    4048016    stk_ambarlar stk_ambarlar_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.stk_ambarlar
    ADD CONSTRAINT stk_ambarlar_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.stk_ambarlar DROP CONSTRAINT stk_ambarlar_pkey;
       public         	   ths_admin    false    312            �           2606    4048018 2   stk_cins_ozellikleri stk_cins_ozellikleri_cins_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.stk_cins_ozellikleri
    ADD CONSTRAINT stk_cins_ozellikleri_cins_key UNIQUE (cins);
 \   ALTER TABLE ONLY public.stk_cins_ozellikleri DROP CONSTRAINT stk_cins_ozellikleri_cins_key;
       public         	   ths_admin    false    313            �           2606    4048020 .   stk_cins_ozellikleri stk_cins_ozellikleri_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.stk_cins_ozellikleri
    ADD CONSTRAINT stk_cins_ozellikleri_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.stk_cins_ozellikleri DROP CONSTRAINT stk_cins_ozellikleri_pkey;
       public         	   ths_admin    false    313            �           2606    4048022     stk_gruplar stk_gruplar_grup_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_grup_key UNIQUE (grup);
 J   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_grup_key;
       public         	   ths_admin    false    265            �           2606    4048024    stk_gruplar stk_gruplar_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_pkey;
       public         	   ths_admin    false    265            �           2606    4048026 "   stk_hareketler stk_hareketler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_pkey;
       public         	   ths_admin    false    315            �           2606    4048028 4   stk_stok_karti_ozetleri stk_stok_karti_ozetleri_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.stk_stok_karti_ozetleri
    ADD CONSTRAINT stk_stok_karti_ozetleri_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.stk_stok_karti_ozetleri DROP CONSTRAINT stk_stok_karti_ozetleri_pkey;
       public         	   ths_admin    false    320            �           2606    4048030 (   stk_stok_kartlari stk_stok_kartlari_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.stk_stok_kartlari
    ADD CONSTRAINT stk_stok_kartlari_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.stk_stok_kartlari DROP CONSTRAINT stk_stok_kartlari_pkey;
       public         	   ths_admin    false    266            �           2606    4048032 1   stk_stok_kartlari stk_stok_kartlari_stok_kodu_key 
   CONSTRAINT     q   ALTER TABLE ONLY public.stk_stok_kartlari
    ADD CONSTRAINT stk_stok_kartlari_stok_kodu_key UNIQUE (stok_kodu);
 [   ALTER TABLE ONLY public.stk_stok_kartlari DROP CONSTRAINT stk_stok_kartlari_stok_kodu_key;
       public         	   ths_admin    false    266            �           2606    4048034 ;   stk_stok_karti_ozetleri stk_stok_ozetleri_stok_karti_id_key 
   CONSTRAINT        ALTER TABLE ONLY public.stk_stok_karti_ozetleri
    ADD CONSTRAINT stk_stok_ozetleri_stok_karti_id_key UNIQUE (stok_karti_id);
 e   ALTER TABLE ONLY public.stk_stok_karti_ozetleri DROP CONSTRAINT stk_stok_ozetleri_stok_karti_id_key;
       public         	   ths_admin    false    320            �           2606    4048036    sys_adresler sys_adresler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_adresler
    ADD CONSTRAINT sys_adresler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_adresler DROP CONSTRAINT sys_adresler_pkey;
       public         	   ths_admin    false    322            �           2606    4048038    sys_aylar sys_aylar_ay_adi_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.sys_aylar
    ADD CONSTRAINT sys_aylar_ay_adi_key UNIQUE (ay_adi);
 H   ALTER TABLE ONLY public.sys_aylar DROP CONSTRAINT sys_aylar_ay_adi_key;
       public         	   ths_admin    false    324            �           2606    4048040    sys_aylar sys_aylar_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.sys_aylar
    ADD CONSTRAINT sys_aylar_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.sys_aylar DROP CONSTRAINT sys_aylar_pkey;
       public         	   ths_admin    false    324            �           2606    4048042 #   sys_bolgeler sys_bolgeler_bolge_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.sys_bolgeler
    ADD CONSTRAINT sys_bolgeler_bolge_key UNIQUE (bolge);
 M   ALTER TABLE ONLY public.sys_bolgeler DROP CONSTRAINT sys_bolgeler_bolge_key;
       public         	   ths_admin    false    326                        2606    4048044    sys_bolgeler sys_bolgeler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_bolgeler
    ADD CONSTRAINT sys_bolgeler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_bolgeler DROP CONSTRAINT sys_bolgeler_pkey;
       public         	   ths_admin    false    326                       2606    4048046 >   sys_ersim_haklari sys_ersim_haklari_kaynak_id_kullanici_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kaynak_id_kullanici_id_key UNIQUE (kaynak_id, kullanici_id);
 h   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_kaynak_id_kullanici_id_key;
       public         	   ths_admin    false    329    329                       2606    4048048 (   sys_ersim_haklari sys_ersim_haklari_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_pkey;
       public         	   ths_admin    false    329                       2606    4048050 B   sys_grid_filtreler_siralamalar sys_grid_filtreler_siralamalar_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar
    ADD CONSTRAINT sys_grid_filtreler_siralamalar_pkey PRIMARY KEY (id);
 l   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar DROP CONSTRAINT sys_grid_filtreler_siralamalar_pkey;
       public         	   ths_admin    false    331                       2606    4048052 W   sys_grid_filtreler_siralamalar sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar
    ADD CONSTRAINT sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key UNIQUE (tablo_adi, is_siralama);
 �   ALTER TABLE ONLY public.sys_grid_filtreler_siralamalar DROP CONSTRAINT sys_grid_filtreler_siralamalar_tablo_adi_is_siralama_key;
       public         	   ths_admin    false    331    331            
           2606    4048054 (   sys_grid_kolonlar sys_grid_kolonlar_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.sys_grid_kolonlar DROP CONSTRAINT sys_grid_kolonlar_pkey;
       public         	   ths_admin    false    333                       2606    4048056 ;   sys_grid_kolonlar sys_grid_kolonlar_tablo_adi_kolon_adi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_tablo_adi_kolon_adi_key UNIQUE (tablo_adi, kolon_adi);
 e   ALTER TABLE ONLY public.sys_grid_kolonlar DROP CONSTRAINT sys_grid_kolonlar_tablo_adi_kolon_adi_key;
       public         	   ths_admin    false    333    333                       2606    4048058 9   sys_grid_kolonlar sys_grid_kolonlar_tablo_adi_sira_no_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_grid_kolonlar
    ADD CONSTRAINT sys_grid_kolonlar_tablo_adi_sira_no_key UNIQUE (tablo_adi, sira_no);
 c   ALTER TABLE ONLY public.sys_grid_kolonlar DROP CONSTRAINT sys_grid_kolonlar_tablo_adi_sira_no_key;
       public         	   ths_admin    false    333    333                       2606    4048060 !   sys_gunler sys_gunler_gun_adi_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.sys_gunler
    ADD CONSTRAINT sys_gunler_gun_adi_key UNIQUE (gun_adi);
 K   ALTER TABLE ONLY public.sys_gunler DROP CONSTRAINT sys_gunler_gun_adi_key;
       public         	   ths_admin    false    335                       2606    4048062    sys_gunler sys_gunler_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.sys_gunler
    ADD CONSTRAINT sys_gunler_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.sys_gunler DROP CONSTRAINT sys_gunler_pkey;
       public         	   ths_admin    false    335                       2606    4048064 1   sys_kaynak_gruplari sys_kaynak_gruplari_grup_ukey 
   CONSTRAINT     l   ALTER TABLE ONLY public.sys_kaynak_gruplari
    ADD CONSTRAINT sys_kaynak_gruplari_grup_ukey UNIQUE (grup);
 [   ALTER TABLE ONLY public.sys_kaynak_gruplari DROP CONSTRAINT sys_kaynak_gruplari_grup_ukey;
       public         	   ths_admin    false    337                       2606    4048066 /   sys_kaynak_gruplari sys_kaynak_gruplari_id_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.sys_kaynak_gruplari
    ADD CONSTRAINT sys_kaynak_gruplari_id_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY public.sys_kaynak_gruplari DROP CONSTRAINT sys_kaynak_gruplari_id_pkey;
       public         	   ths_admin    false    337                       2606    4048068 +   sys_kaynaklar sys_kaynaklar_kaynak_kodu_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_kaynak_kodu_key UNIQUE (kaynak_kodu);
 U   ALTER TABLE ONLY public.sys_kaynaklar DROP CONSTRAINT sys_kaynaklar_kaynak_kodu_key;
       public         	   ths_admin    false    339                       2606    4048070     sys_kaynaklar sys_kaynaklar_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.sys_kaynaklar DROP CONSTRAINT sys_kaynaklar_pkey;
       public         	   ths_admin    false    339                        2606    4048072 S   sys_lisan_gui_icerikler sys_lisan_gui_icerikler_lisan_kod_icerik_tipi_tablo_adi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_lisan_gui_icerikler
    ADD CONSTRAINT sys_lisan_gui_icerikler_lisan_kod_icerik_tipi_tablo_adi_key UNIQUE (lisan, kod, icerik_tipi, tablo_adi);
 }   ALTER TABLE ONLY public.sys_lisan_gui_icerikler DROP CONSTRAINT sys_lisan_gui_icerikler_lisan_kod_icerik_tipi_tablo_adi_key;
       public         	   ths_admin    false    343    343    343    343            "           2606    4048074 4   sys_lisan_gui_icerikler sys_lisan_gui_icerikler_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.sys_lisan_gui_icerikler
    ADD CONSTRAINT sys_lisan_gui_icerikler_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.sys_lisan_gui_icerikler DROP CONSTRAINT sys_lisan_gui_icerikler_pkey;
       public         	   ths_admin    false    343            $           2606    4048076 #   sys_lisanlar sys_lisanlar_lisan_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.sys_lisanlar
    ADD CONSTRAINT sys_lisanlar_lisan_key UNIQUE (lisan);
 M   ALTER TABLE ONLY public.sys_lisanlar DROP CONSTRAINT sys_lisanlar_lisan_key;
       public         	   ths_admin    false    345            &           2606    4048078    sys_lisanlar sys_lisanlar_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_lisanlar
    ADD CONSTRAINT sys_lisanlar_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_lisanlar DROP CONSTRAINT sys_lisanlar_pkey;
       public         	   ths_admin    false    345            0           2606    4048080 D   sys_olcu_birimi_tipleri sys_olcu_birimi_tipleri_olcu_birimi_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri
    ADD CONSTRAINT sys_olcu_birimi_tipleri_olcu_birimi_tipi_key UNIQUE (olcu_birimi_tipi);
 n   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri DROP CONSTRAINT sys_olcu_birimi_tipleri_olcu_birimi_tipi_key;
       public         	   ths_admin    false    351            2           2606    4048082 4   sys_olcu_birimi_tipleri sys_olcu_birimi_tipleri_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri
    ADD CONSTRAINT sys_olcu_birimi_tipleri_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.sys_olcu_birimi_tipleri DROP CONSTRAINT sys_olcu_birimi_tipleri_pkey;
       public         	   ths_admin    false    351            ,           2606    4048084 /   sys_olcu_birimleri sys_olcu_birimleri_birim_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_birim_key UNIQUE (birim);
 Y   ALTER TABLE ONLY public.sys_olcu_birimleri DROP CONSTRAINT sys_olcu_birimleri_birim_key;
       public         	   ths_admin    false    349            .           2606    4048086 *   sys_olcu_birimleri sys_olcu_birimleri_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.sys_olcu_birimleri DROP CONSTRAINT sys_olcu_birimleri_pkey;
       public         	   ths_admin    false    349            4           2606    4048088 ,   sys_ondalik_haneler sys_ondalik_haneler_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.sys_ondalik_haneler
    ADD CONSTRAINT sys_ondalik_haneler_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.sys_ondalik_haneler DROP CONSTRAINT sys_ondalik_haneler_pkey;
       public         	   ths_admin    false    353            6           2606    4048090 .   sys_para_birimleri sys_para_birimleri_para_key 
   CONSTRAINT     i   ALTER TABLE ONLY public.sys_para_birimleri
    ADD CONSTRAINT sys_para_birimleri_para_key UNIQUE (para);
 X   ALTER TABLE ONLY public.sys_para_birimleri DROP CONSTRAINT sys_para_birimleri_para_key;
       public         	   ths_admin    false    355            8           2606    4048092 *   sys_para_birimleri sys_para_birimleri_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.sys_para_birimleri
    ADD CONSTRAINT sys_para_birimleri_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.sys_para_birimleri DROP CONSTRAINT sys_para_birimleri_pkey;
       public         	   ths_admin    false    355            �           2606    4048094    sys_sehirler sys_sehirler_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_pkey;
       public         	   ths_admin    false    267            �           2606    4048096 +   sys_sehirler sys_sehirler_ulke_id_sehir_key 
   CONSTRAINT     p   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_ulke_id_sehir_key UNIQUE (ulke_id, sehir);
 U   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_ulke_id_sehir_key;
       public         	   ths_admin    false    267    267            :           2606    4048098    sys_ulkeler sys_ulkeler_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.sys_ulkeler
    ADD CONSTRAINT sys_ulkeler_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.sys_ulkeler DROP CONSTRAINT sys_ulkeler_pkey;
       public         	   ths_admin    false    358            <           2606    4048100 %   sys_ulkeler sys_ulkeler_ulke_kodu_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.sys_ulkeler
    ADD CONSTRAINT sys_ulkeler_ulke_kodu_key UNIQUE (ulke_kodu);
 O   ALTER TABLE ONLY public.sys_ulkeler DROP CONSTRAINT sys_ulkeler_ulke_kodu_key;
       public         	   ths_admin    false    358                       2606    4048102    sys_kullanicilar sys_users_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_pkey PRIMARY KEY (id);
 I   ALTER TABLE ONLY public.sys_kullanicilar DROP CONSTRAINT sys_users_pkey;
       public         	   ths_admin    false    341                       2606    4048104 '   sys_kullanicilar sys_users_username_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_username_key UNIQUE (kullanici_adi);
 Q   ALTER TABLE ONLY public.sys_kullanicilar DROP CONSTRAINT sys_users_username_key;
       public         	   ths_admin    false    341            >           2606    4048106 0   sys_uygulama_ayarlari sys_uygulama_ayarlari_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_pkey;
       public         	   ths_admin    false    360            (           2606    4048108 G   sys_vergi_mukellef_tipleri sys_vergi_mukellef_tipleri_mukellef_tipi_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.sys_vergi_mukellef_tipleri
    ADD CONSTRAINT sys_vergi_mukellef_tipleri_mukellef_tipi_key UNIQUE (mukellef_tipi);
 q   ALTER TABLE ONLY public.sys_vergi_mukellef_tipleri DROP CONSTRAINT sys_vergi_mukellef_tipleri_mukellef_tipi_key;
       public         	   ths_admin    false    347            *           2606    4048110 :   sys_vergi_mukellef_tipleri sys_vergi_mukellef_tipleri_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.sys_vergi_mukellef_tipleri
    ADD CONSTRAINT sys_vergi_mukellef_tipleri_pkey PRIMARY KEY (id);
 d   ALTER TABLE ONLY public.sys_vergi_mukellef_tipleri DROP CONSTRAINT sys_vergi_mukellef_tipleri_pkey;
       public         	   ths_admin    false    347            U           2606    4048112 ,   urt_iscilikler urt_iscilikler_gider_kodu_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_gider_kodu_key UNIQUE (gider_kodu);
 V   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_gider_kodu_key;
       public         	   ths_admin    false    232            W           2606    4048114 "   urt_iscilikler urt_iscilikler_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_pkey;
       public         	   ths_admin    false    232            Y           2606    4048116 >   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_pkey;
       public         	   ths_admin    false    234            [           2606    4048118 Q   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_stok_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_header_id_key UNIQUE (stok_kodu, header_id);
 {   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_header_id_key;
       public         	   ths_admin    false    234    234            ]           2606    4048120 9   urt_paket_hammaddeler urt_paket_hammaddeler_paket_adi_key 
   CONSTRAINT     y   ALTER TABLE ONLY public.urt_paket_hammaddeler
    ADD CONSTRAINT urt_paket_hammaddeler_paket_adi_key UNIQUE (paket_adi);
 c   ALTER TABLE ONLY public.urt_paket_hammaddeler DROP CONSTRAINT urt_paket_hammaddeler_paket_adi_key;
       public         	   ths_admin    false    236            _           2606    4048122 0   urt_paket_hammaddeler urt_paket_hammaddeler_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.urt_paket_hammaddeler
    ADD CONSTRAINT urt_paket_hammaddeler_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.urt_paket_hammaddeler DROP CONSTRAINT urt_paket_hammaddeler_pkey;
       public         	   ths_admin    false    236            a           2606    4048124 <   urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_pkey PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_paket_iscilik_detaylari_pkey;
       public         	   ths_admin    false    238            e           2606    4048126 7   urt_paket_iscilikler urt_paket_iscilikler_paket_adi_key 
   CONSTRAINT     w   ALTER TABLE ONLY public.urt_paket_iscilikler
    ADD CONSTRAINT urt_paket_iscilikler_paket_adi_key UNIQUE (paket_adi);
 a   ALTER TABLE ONLY public.urt_paket_iscilikler DROP CONSTRAINT urt_paket_iscilikler_paket_adi_key;
       public         	   ths_admin    false    240            g           2606    4048128 .   urt_paket_iscilikler urt_paket_iscilikler_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.urt_paket_iscilikler
    ADD CONSTRAINT urt_paket_iscilikler_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.urt_paket_iscilikler DROP CONSTRAINT urt_paket_iscilikler_pkey;
       public         	   ths_admin    false    240            i           2606    4048130 2   urt_recete_hammaddeler urt_recete_hammaddeler_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_pkey;
       public         	   ths_admin    false    242            k           2606    4048132 E   urt_recete_hammaddeler urt_recete_hammaddeler_stok_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_stok_kodu_header_id_key UNIQUE (stok_kodu, header_id);
 o   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_stok_kodu_header_id_key;
       public         	   ths_admin    false    242    242            q           2606    4048134 <   urt_recete_iscilikler urt_recete_iscilikler_iscilik_kodu_key 
   CONSTRAINT        ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_iscilik_kodu_key UNIQUE (iscilik_kodu);
 f   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_iscilik_kodu_key;
       public         	   ths_admin    false    246            s           2606    4048136 0   urt_recete_iscilikler urt_recete_iscilikler_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_pkey;
       public         	   ths_admin    false    246            u           2606    4048138 P   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_header_id_paket_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_header_id_paket_id_key UNIQUE (header_id, paket_id);
 z   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_header_id_paket_id_key;
       public         	   ths_admin    false    248    248            w           2606    4048140 >   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_pkey;
       public         	   ths_admin    false    248            c           2606    4048142 Y   urt_paket_iscilik_detaylari urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key UNIQUE (iscilik_kodu, header_id);
 �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_recete_paket_iscilik_detaylari_iscilik_kodu_header_id_key;
       public         	   ths_admin    false    238    238            y           2606    4048144 N   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_header_id_paket_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_header_id_paket_id_key UNIQUE (header_id, paket_id);
 x   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_header_id_paket_id_key;
       public         	   ths_admin    false    250    250            {           2606    4048146 <   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_pkey PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_pkey;
       public         	   ths_admin    false    250            @           2606    4048148 2   urt_recete_yan_urunler urt_recete_yan_urunler_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_pkey;
       public         	   ths_admin    false    365            B           2606    4048150 E   urt_recete_yan_urunler urt_recete_yan_urunler_urun_kodu_header_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_urun_kodu_header_id_key UNIQUE (urun_kodu, header_id);
 o   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_urun_kodu_header_id_key;
       public         	   ths_admin    false    365    365            m           2606    4048152     urt_receteler urt_receteler_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.urt_receteler DROP CONSTRAINT urt_receteler_pkey;
       public         	   ths_admin    false    244            o           2606    4048154 2   urt_receteler urt_receteler_urun_kodu_urun_adi_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_urun_kodu_urun_adi_key UNIQUE (urun_kodu, urun_adi);
 \   ALTER TABLE ONLY public.urt_receteler DROP CONSTRAINT urt_receteler_urun_kodu_urun_adi_key;
       public         	   ths_admin    false    244    244            �           1259    4048155    idx_sat_siparis_detay_header_id    INDEX     b   CREATE INDEX idx_sat_siparis_detay_header_id ON public.sls_order_details USING btree (header_id);
 3   DROP INDEX public.idx_sat_siparis_detay_header_id;
       public         	   ths_admin    false    260            �           1259    4048156    idx_sat_siparis_musteri_kodu    INDEX     [   CREATE INDEX idx_sat_siparis_musteri_kodu ON public.sls_orders USING btree (musteri_kodu);
 0   DROP INDEX public.idx_sat_siparis_musteri_kodu;
       public         	   ths_admin    false    262            �           1259    4048157    idx_sat_teklif_detay_header_id    INDEX     a   CREATE INDEX idx_sat_teklif_detay_header_id ON public.sls_offer_details USING btree (header_id);
 2   DROP INDEX public.idx_sat_teklif_detay_header_id;
       public         	   ths_admin    false    269            �           2620    4048158    stk_cins_ozellikleri audit    TRIGGER     �   CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.stk_cins_ozellikleri FOR EACH ROW EXECUTE FUNCTION public.audit_old();

ALTER TABLE public.stk_cins_ozellikleri DISABLE TRIGGER audit;
 3   DROP TRIGGER audit ON public.stk_cins_ozellikleri;
       public       	   ths_admin    false    313    490            �           2620    4048159 *   set_prs_birimler delete_table_lang_content    TRIGGER     �   CREATE TRIGGER delete_table_lang_content AFTER DELETE ON public.set_prs_birimler FOR EACH ROW EXECUTE FUNCTION public.delete_table_lang_content();
 C   DROP TRIGGER delete_table_lang_content ON public.set_prs_birimler;
       public       	   ths_admin    false    464    293            �           2620    4048160 *   set_prs_gorevler delete_table_lang_content    TRIGGER     �   CREATE TRIGGER delete_table_lang_content AFTER DELETE ON public.set_prs_gorevler FOR EACH ROW EXECUTE FUNCTION public.delete_table_lang_content();
 C   DROP TRIGGER delete_table_lang_content ON public.set_prs_gorevler;
       public       	   ths_admin    false    299    464            �           2620    4048161 1   sys_grid_kolonlar sys_grid_col_width_table_notify    TRIGGER     �   CREATE TRIGGER sys_grid_col_width_table_notify AFTER INSERT OR DELETE OR UPDATE ON public.sys_grid_kolonlar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 J   DROP TRIGGER sys_grid_col_width_table_notify ON public.sys_grid_kolonlar;
       public       	   ths_admin    false    488    333            �           2620    4048162 !   stk_cins_ozellikleri table_notify    TRIGGER     �   CREATE TRIGGER table_notify BEFORE INSERT OR DELETE OR UPDATE ON public.stk_cins_ozellikleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();

ALTER TABLE public.stk_cins_ozellikleri DISABLE TRIGGER table_notify;
 :   DROP TRIGGER table_notify ON public.stk_cins_ozellikleri;
       public       	   ths_admin    false    488    313            �           2620    4048163    ch_banka_subeleri trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_banka_subeleri FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 5   DROP TRIGGER trg_notify ON public.ch_banka_subeleri;
       public       	   ths_admin    false    488    216            �           2620    4048164    ch_bankalar trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_bankalar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER trg_notify ON public.ch_bankalar;
       public       	   ths_admin    false    488    214            �           2620    4048165    ch_bolgeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_bolgeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER trg_notify ON public.ch_bolgeler;
       public       	   ths_admin    false    488    218            �           2620    4048166    ch_doviz_kurlari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_doviz_kurlari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 4   DROP TRIGGER trg_notify ON public.ch_doviz_kurlari;
       public       	   ths_admin    false    220    488            �           2620    4048167    ch_hesaplar trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.ch_hesaplar FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 /   DROP TRIGGER trg_notify ON public.ch_hesaplar;
       public       	   ths_admin    false    222    488            �           2620    4048168    urt_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 2   DROP TRIGGER trg_notify ON public.urt_iscilikler;
       public       	   ths_admin    false    232    488            �           2620    4048169 '   urt_paket_hammadde_detaylari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_hammadde_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 @   DROP TRIGGER trg_notify ON public.urt_paket_hammadde_detaylari;
       public       	   ths_admin    false    234    488            �           2620    4048170     urt_paket_hammaddeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER trg_notify ON public.urt_paket_hammaddeler;
       public       	   ths_admin    false    236    488            �           2620    4048171 &   urt_paket_iscilik_detaylari trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_iscilik_detaylari FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 ?   DROP TRIGGER trg_notify ON public.urt_paket_iscilik_detaylari;
       public       	   ths_admin    false    238    488            �           2620    4048172    urt_paket_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_paket_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 8   DROP TRIGGER trg_notify ON public.urt_paket_iscilikler;
       public       	   ths_admin    false    488    240            �           2620    4048173 !   urt_recete_hammaddeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 :   DROP TRIGGER trg_notify ON public.urt_recete_hammaddeler;
       public       	   ths_admin    false    488    242            �           2620    4048174     urt_recete_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 9   DROP TRIGGER trg_notify ON public.urt_recete_iscilikler;
       public       	   ths_admin    false    488    246            �           2620    4048175 '   urt_recete_paket_hammaddeler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_paket_hammaddeler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 @   DROP TRIGGER trg_notify ON public.urt_recete_paket_hammaddeler;
       public       	   ths_admin    false    248    488            �           2620    4048176 &   urt_recete_paket_iscilikler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_paket_iscilikler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 ?   DROP TRIGGER trg_notify ON public.urt_recete_paket_iscilikler;
       public       	   ths_admin    false    488    250            �           2620    4048177 !   urt_recete_yan_urunler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_recete_yan_urunler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 :   DROP TRIGGER trg_notify ON public.urt_recete_yan_urunler;
       public       	   ths_admin    false    488    365            �           2620    4048178    urt_receteler trg_notify    TRIGGER     �   CREATE TRIGGER trg_notify AFTER INSERT OR DELETE OR UPDATE ON public.urt_receteler FOR EACH ROW EXECUTE FUNCTION public.table_notify();
 1   DROP TRIGGER trg_notify ON public.urt_receteler;
       public       	   ths_admin    false    244    488            C           2606    4048179 1   ch_banka_subeleri ch_banka_subeleri_banka_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_banka_id_fkey FOREIGN KEY (banka_id) REFERENCES public.ch_bankalar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_banka_id_fkey;
       public       	   ths_admin    false    216    214    3635            D           2606    4048184 1   ch_banka_subeleri ch_banka_subeleri_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_banka_subeleri
    ADD CONSTRAINT ch_banka_subeleri_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.ch_banka_subeleri DROP CONSTRAINT ch_banka_subeleri_sehir_id_fkey;
       public       	   ths_admin    false    267    216    3735            E           2606    4048189 +   ch_doviz_kurlari ch_doviz_kurlari_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_doviz_kurlari
    ADD CONSTRAINT ch_doviz_kurlari_para_fkey FOREIGN KEY (para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE CASCADE;
 U   ALTER TABLE ONLY public.ch_doviz_kurlari DROP CONSTRAINT ch_doviz_kurlari_para_fkey;
       public       	   ths_admin    false    3894    220    355            F           2606    4048194 %   ch_hesaplar ch_hesaplar_bolge_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_bolge_id_fkey FOREIGN KEY (bolge_id) REFERENCES public.ch_hesap_planlari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 O   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_bolge_id_fkey;
       public       	   ths_admin    false    224    3657    222            G           2606    4048199 $   ch_hesaplar ch_hesaplar_grup_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_grup_id_fkey FOREIGN KEY (grup_id) REFERENCES public.ch_gruplar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 N   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_grup_id_fkey;
       public       	   ths_admin    false    222    221    3651            H           2606    4048204 *   ch_hesaplar ch_hesaplar_hesap_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_hesap_tipi_id_fkey FOREIGN KEY (hesap_tipi_id) REFERENCES public.set_ch_hesap_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 T   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_hesap_tipi_id_fkey;
       public       	   ths_admin    false    222    3756    279            I           2606    4048209 -   ch_hesaplar ch_hesaplar_mukellef_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ch_hesaplar
    ADD CONSTRAINT ch_hesaplar_mukellef_tipi_id_fkey FOREIGN KEY (mukellef_tipi_id) REFERENCES public.sys_vergi_mukellef_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.ch_hesaplar DROP CONSTRAINT ch_hesaplar_mukellef_tipi_id_fkey;
       public       	   ths_admin    false    222    3882    347            J           2606    4048214 7   prs_lisan_bilgileri prs_lisan_bilgileri_konusma_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_konusma_id_fkey FOREIGN KEY (konusma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;
 a   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_konusma_id_fkey;
       public       	   ths_admin    false    226    3804    303            K           2606    4048219 5   prs_lisan_bilgileri prs_lisan_bilgileri_lisan_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_lisan_id_fkey FOREIGN KEY (lisan_id) REFERENCES public.set_prs_lisanlar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_lisan_id_fkey;
       public       	   ths_admin    false    3800    226    301            L           2606    4048224 5   prs_lisan_bilgileri prs_lisan_bilgileri_okuma_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_okuma_id_fkey FOREIGN KEY (okuma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_okuma_id_fkey;
       public       	   ths_admin    false    226    303    3804            M           2606    4048229 8   prs_lisan_bilgileri prs_lisan_bilgileri_personel_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_personel_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE CASCADE;
 b   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_personel_id_fkey;
       public       	   ths_admin    false    230    3667    226            N           2606    4048234 5   prs_lisan_bilgileri prs_lisan_bilgileri_yazma_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_lisan_bilgileri
    ADD CONSTRAINT prs_lisan_bilgileri_yazma_id_fkey FOREIGN KEY (yazma_id) REFERENCES public.set_prs_lisan_seviyeleri(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.prs_lisan_bilgileri DROP CONSTRAINT prs_lisan_bilgileri_yazma_id_fkey;
       public       	   ths_admin    false    226    3804    303            O           2606    4048239 A   prs_personel_ehliyetleri prs_personel_ehliyetleri_ehliyet_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personel_ehliyetleri
    ADD CONSTRAINT prs_personel_ehliyetleri_ehliyet_id_fkey FOREIGN KEY (ehliyet_id) REFERENCES public.set_prs_ehliyetler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 k   ALTER TABLE ONLY public.prs_personel_ehliyetleri DROP CONSTRAINT prs_personel_ehliyetleri_ehliyet_id_fkey;
       public       	   ths_admin    false    297    3792    228            P           2606    4048244 B   prs_personel_ehliyetleri prs_personel_ehliyetleri_personel_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personel_ehliyetleri
    ADD CONSTRAINT prs_personel_ehliyetleri_personel_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE CASCADE;
 l   ALTER TABLE ONLY public.prs_personel_ehliyetleri DROP CONSTRAINT prs_personel_ehliyetleri_personel_id_fkey;
       public       	   ths_admin    false    3667    230    228            Q           2606    4048249 -   prs_personeller prs_personeller_adres_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_adres_id_fkey FOREIGN KEY (adres_id) REFERENCES public.sys_adresler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 W   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_adres_id_fkey;
       public       	   ths_admin    false    322    3832    230            R           2606    4048254 -   prs_personeller prs_personeller_birim_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_birim_id_fkey FOREIGN KEY (birim_id) REFERENCES public.set_prs_birimler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 W   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_birim_id_fkey;
       public       	   ths_admin    false    230    3784    293            S           2606    4048259 -   prs_personeller prs_personeller_gorev_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_gorev_id_fkey FOREIGN KEY (gorev_id) REFERENCES public.set_prs_gorevler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 W   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_gorev_id_fkey;
       public       	   ths_admin    false    230    299    3796            T           2606    4048264 5   prs_personeller prs_personeller_personel_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_personel_tipi_id_fkey FOREIGN KEY (personel_tipi_id) REFERENCES public.set_prs_personel_tipleri(id) ON UPDATE CASCADE ON DELETE SET NULL;
 _   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_personel_tipi_id_fkey;
       public       	   ths_admin    false    305    230    3808            U           2606    4048269 5   prs_personeller prs_personeller_tasima_servis_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prs_personeller
    ADD CONSTRAINT prs_personeller_tasima_servis_id_fkey FOREIGN KEY (tasima_servis_id) REFERENCES public.set_prs_tasima_servisleri(id) ON UPDATE CASCADE ON DELETE SET NULL;
 _   ALTER TABLE ONLY public.prs_personeller DROP CONSTRAINT prs_personeller_tasima_servis_id_fkey;
       public       	   ths_admin    false    3812    307    230            g           2606    4048274 3   sls_invoice_details sat_fatura_detay_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_invoice_details
    ADD CONSTRAINT sat_fatura_detay_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sls_invoices(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ]   ALTER TABLE ONLY public.sls_invoice_details DROP CONSTRAINT sat_fatura_detay_header_id_fkey;
       public       	   ths_admin    false    252    3711    254            h           2606    4048279 ;   sls_dispatch_note_details sat_irsaliye_detay_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_dispatch_note_details
    ADD CONSTRAINT sat_irsaliye_detay_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sls_dispatch_notes(id) ON UPDATE CASCADE ON DELETE CASCADE;
 e   ALTER TABLE ONLY public.sls_dispatch_note_details DROP CONSTRAINT sat_irsaliye_detay_header_id_fkey;
       public       	   ths_admin    false    3715    258    256            i           2606    4048284 2   sls_order_details sat_siparis_detay_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_order_details
    ADD CONSTRAINT sat_siparis_detay_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sls_orders(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.sls_order_details DROP CONSTRAINT sat_siparis_detay_header_id_fkey;
       public       	   ths_admin    false    260    262    3721            j           2606    4048289 4   sls_order_details sat_siparis_detay_olcu_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_order_details
    ADD CONSTRAINT sat_siparis_detay_olcu_birimi_fkey FOREIGN KEY (olcu_birimi) REFERENCES public.sys_olcu_birimleri(birim) ON UPDATE CASCADE ON DELETE RESTRICT;
 ^   ALTER TABLE ONLY public.sls_order_details DROP CONSTRAINT sat_siparis_detay_olcu_birimi_fkey;
       public       	   ths_admin    false    260    349    3884            k           2606    4048294 =   sls_order_details sat_siparis_detay_referans_ana_urun_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_order_details
    ADD CONSTRAINT sat_siparis_detay_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.sls_order_details(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 g   ALTER TABLE ONLY public.sls_order_details DROP CONSTRAINT sat_siparis_detay_referans_ana_urun_id_fkey;
       public       	   ths_admin    false    260    3718    260            l           2606    4048299 2   sls_order_details sat_siparis_detay_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_order_details
    ADD CONSTRAINT sat_siparis_detay_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_stok_kartlari(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 \   ALTER TABLE ONLY public.sls_order_details DROP CONSTRAINT sat_siparis_detay_stok_kodu_fkey;
       public       	   ths_admin    false    260    3733    266            m           2606    4048304 )   sls_orders sat_siparis_islem_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_orders
    ADD CONSTRAINT sat_siparis_islem_tipi_id_fkey FOREIGN KEY (islem_tipi_id) REFERENCES public.set_einv_fatura_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.sls_orders DROP CONSTRAINT sat_siparis_islem_tipi_id_fkey;
       public       	   ths_admin    false    262    3764    283            n           2606    4048309 (   sls_orders sat_siparis_musteri_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_orders
    ADD CONSTRAINT sat_siparis_musteri_kodu_fkey FOREIGN KEY (musteri_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 R   ALTER TABLE ONLY public.sls_orders DROP CONSTRAINT sat_siparis_musteri_kodu_fkey;
       public       	   ths_admin    false    222    3653    262            o           2606    4048314 1   sls_orders sat_siparis_musteri_temsilcisi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_orders
    ADD CONSTRAINT sat_siparis_musteri_temsilcisi_id_fkey FOREIGN KEY (musteri_temsilcisi_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.sls_orders DROP CONSTRAINT sat_siparis_musteri_temsilcisi_id_fkey;
       public       	   ths_admin    false    262    230    3667            p           2606    4048319 -   sls_orders sat_siparis_nakliye_ucreti_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_orders
    ADD CONSTRAINT sat_siparis_nakliye_ucreti_id_fkey FOREIGN KEY (tasima_ucreti_id) REFERENCES public.set_einv_tasima_ucretleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.sls_orders DROP CONSTRAINT sat_siparis_nakliye_ucreti_id_fkey;
       public       	   ths_admin    false    262    3774    289            q           2606    4048324 *   sls_orders sat_siparis_odeme_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_orders
    ADD CONSTRAINT sat_siparis_odeme_sekli_id_fkey FOREIGN KEY (odeme_sekli_id) REFERENCES public.set_einv_odeme_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 T   ALTER TABLE ONLY public.sls_orders DROP CONSTRAINT sat_siparis_odeme_sekli_id_fkey;
       public       	   ths_admin    false    262    285    3766            r           2606    4048329 )   sls_orders sat_siparis_paket_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_orders
    ADD CONSTRAINT sat_siparis_paket_tipi_id_fkey FOREIGN KEY (paket_tipi_id) REFERENCES public.set_einv_paket_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.sls_orders DROP CONSTRAINT sat_siparis_paket_tipi_id_fkey;
       public       	   ths_admin    false    287    3772    262            s           2606    4048334 '   sls_orders sat_siparis_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_orders
    ADD CONSTRAINT sat_siparis_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.sls_orders DROP CONSTRAINT sat_siparis_para_birimi_fkey;
       public       	   ths_admin    false    355    3894    262            t           2606    4048339 $   sls_orders sat_siparis_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_orders
    ADD CONSTRAINT sat_siparis_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 N   ALTER TABLE ONLY public.sls_orders DROP CONSTRAINT sat_siparis_sehir_id_fkey;
       public       	   ths_admin    false    262    3735    267            u           2606    4048344 ,   sls_orders sat_siparis_siparis_durum_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_orders
    ADD CONSTRAINT sat_siparis_siparis_durum_id_fkey FOREIGN KEY (siparis_durum_id) REFERENCES public.set_sls_order_status(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 V   ALTER TABLE ONLY public.sls_orders DROP CONSTRAINT sat_siparis_siparis_durum_id_fkey;
       public       	   ths_admin    false    3723    262    264            v           2606    4048349 +   sls_orders sat_siparis_teslim_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_orders
    ADD CONSTRAINT sat_siparis_teslim_sekli_id_fkey FOREIGN KEY (teslim_sekli_id) REFERENCES public.set_einv_teslim_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 U   ALTER TABLE ONLY public.sls_orders DROP CONSTRAINT sat_siparis_teslim_sekli_id_fkey;
       public       	   ths_admin    false    3778    262    291            w           2606    4048354 #   sls_orders sat_siparis_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_orders
    ADD CONSTRAINT sat_siparis_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 M   ALTER TABLE ONLY public.sls_orders DROP CONSTRAINT sat_siparis_ulke_id_fkey;
       public       	   ths_admin    false    358    3898    262            �           2606    4048359 1   sls_offer_details sat_teklif_detay_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_offer_details
    ADD CONSTRAINT sat_teklif_detay_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.sls_offers(id) ON UPDATE CASCADE ON DELETE CASCADE;
 [   ALTER TABLE ONLY public.sls_offer_details DROP CONSTRAINT sat_teklif_detay_header_id_fkey;
       public       	   ths_admin    false    269    271    3742            �           2606    4048364 3   sls_offer_details sat_teklif_detay_olcu_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_offer_details
    ADD CONSTRAINT sat_teklif_detay_olcu_birimi_fkey FOREIGN KEY (olcu_birimi) REFERENCES public.sys_olcu_birimleri(birim) ON UPDATE CASCADE ON DELETE RESTRICT;
 ]   ALTER TABLE ONLY public.sls_offer_details DROP CONSTRAINT sat_teklif_detay_olcu_birimi_fkey;
       public       	   ths_admin    false    349    269    3884            �           2606    4048369 <   sls_offer_details sat_teklif_detay_referans_ana_urun_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_offer_details
    ADD CONSTRAINT sat_teklif_detay_referans_ana_urun_id_fkey FOREIGN KEY (referans_ana_urun_id) REFERENCES public.sls_offer_details(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 f   ALTER TABLE ONLY public.sls_offer_details DROP CONSTRAINT sat_teklif_detay_referans_ana_urun_id_fkey;
       public       	   ths_admin    false    269    269    3740            �           2606    4048374 1   sls_offer_details sat_teklif_detay_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_offer_details
    ADD CONSTRAINT sat_teklif_detay_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_stok_kartlari(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.sls_offer_details DROP CONSTRAINT sat_teklif_detay_stok_kodu_fkey;
       public       	   ths_admin    false    3733    269    266            �           2606    4048379 (   sls_offers sat_teklif_islem_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_offers
    ADD CONSTRAINT sat_teklif_islem_tipi_id_fkey FOREIGN KEY (islem_tipi_id) REFERENCES public.set_einv_fatura_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 R   ALTER TABLE ONLY public.sls_offers DROP CONSTRAINT sat_teklif_islem_tipi_id_fkey;
       public       	   ths_admin    false    271    283    3764            �           2606    4048384 '   sls_offers sat_teklif_musteri_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_offers
    ADD CONSTRAINT sat_teklif_musteri_kodu_fkey FOREIGN KEY (musteri_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.sls_offers DROP CONSTRAINT sat_teklif_musteri_kodu_fkey;
       public       	   ths_admin    false    271    222    3653            �           2606    4048389 0   sls_offers sat_teklif_musteri_temsilcisi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_offers
    ADD CONSTRAINT sat_teklif_musteri_temsilcisi_id_fkey FOREIGN KEY (musteri_temsilcisi_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.sls_offers DROP CONSTRAINT sat_teklif_musteri_temsilcisi_id_fkey;
       public       	   ths_admin    false    3667    230    271            �           2606    4048394 ,   sls_offers sat_teklif_nakliye_ucreti_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_offers
    ADD CONSTRAINT sat_teklif_nakliye_ucreti_id_fkey FOREIGN KEY (tasima_ucreti_id) REFERENCES public.set_einv_tasima_ucretleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 V   ALTER TABLE ONLY public.sls_offers DROP CONSTRAINT sat_teklif_nakliye_ucreti_id_fkey;
       public       	   ths_admin    false    289    3774    271            �           2606    4048399 )   sls_offers sat_teklif_odeme_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_offers
    ADD CONSTRAINT sat_teklif_odeme_sekli_id_fkey FOREIGN KEY (odeme_sekli_id) REFERENCES public.set_einv_odeme_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.sls_offers DROP CONSTRAINT sat_teklif_odeme_sekli_id_fkey;
       public       	   ths_admin    false    285    3766    271            �           2606    4048404 (   sls_offers sat_teklif_paket_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_offers
    ADD CONSTRAINT sat_teklif_paket_tipi_id_fkey FOREIGN KEY (paket_tipi_id) REFERENCES public.set_einv_paket_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 R   ALTER TABLE ONLY public.sls_offers DROP CONSTRAINT sat_teklif_paket_tipi_id_fkey;
       public       	   ths_admin    false    3772    271    287            �           2606    4048409 &   sls_offers sat_teklif_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_offers
    ADD CONSTRAINT sat_teklif_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 P   ALTER TABLE ONLY public.sls_offers DROP CONSTRAINT sat_teklif_para_birimi_fkey;
       public       	   ths_admin    false    3894    355    271            �           2606    4048414 #   sls_offers sat_teklif_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_offers
    ADD CONSTRAINT sat_teklif_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 M   ALTER TABLE ONLY public.sls_offers DROP CONSTRAINT sat_teklif_sehir_id_fkey;
       public       	   ths_admin    false    267    271    3735            �           2606    4048419 *   sls_offers sat_teklif_teslim_sekli_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_offers
    ADD CONSTRAINT sat_teklif_teslim_sekli_id_fkey FOREIGN KEY (teslim_sekli_id) REFERENCES public.set_einv_teslim_sekilleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 T   ALTER TABLE ONLY public.sls_offers DROP CONSTRAINT sat_teklif_teslim_sekli_id_fkey;
       public       	   ths_admin    false    271    291    3778            �           2606    4048424 "   sls_offers sat_teklif_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sls_offers
    ADD CONSTRAINT sat_teklif_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 L   ALTER TABLE ONLY public.sls_offers DROP CONSTRAINT sat_teklif_ulke_id_fkey;
       public       	   ths_admin    false    271    358    3898            �           2606    4048429 <   set_ch_firma_tipleri set_ch_firma_tipleri_firma_turu_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_firma_tipleri
    ADD CONSTRAINT set_ch_firma_tipleri_firma_turu_id_fkey FOREIGN KEY (firma_turu_id) REFERENCES public.set_ch_firma_turleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 f   ALTER TABLE ONLY public.set_ch_firma_tipleri DROP CONSTRAINT set_ch_firma_tipleri_firma_turu_id_fkey;
       public       	   ths_admin    false    3752    275    273            �           2606    4048434 @   set_ch_vergi_oranlari set_ch_vergi_oranlari_alis_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_alis_hesap_kodu_fkey FOREIGN KEY (alis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 j   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_alis_hesap_kodu_fkey;
       public       	   ths_admin    false    222    3653    281            �           2606    4048439 E   set_ch_vergi_oranlari set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey FOREIGN KEY (alis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 o   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_alis_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    3653    281    222            �           2606    4048444 A   set_ch_vergi_oranlari set_ch_vergi_oranlari_ihrac_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_ihrac_hesap_kodu_fkey FOREIGN KEY (ihrac_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 k   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_ihrac_hesap_kodu_fkey;
       public       	   ths_admin    false    3653    222    281            �           2606    4048449 F   set_ch_vergi_oranlari set_ch_vergi_oranlari_ihrac_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_ihrac_iade_hesap_kodu_fkey FOREIGN KEY (ihrac_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 p   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_ihrac_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    281    3653    222            �           2606    4048454 A   set_ch_vergi_oranlari set_ch_vergi_oranlari_satis_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_satis_hesap_kodu_fkey FOREIGN KEY (satis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 k   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_satis_hesap_kodu_fkey;
       public       	   ths_admin    false    281    3653    222            �           2606    4048459 F   set_ch_vergi_oranlari set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_ch_vergi_oranlari
    ADD CONSTRAINT set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey FOREIGN KEY (satis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 p   ALTER TABLE ONLY public.set_ch_vergi_oranlari DROP CONSTRAINT set_ch_vergi_oranlari_satis_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    222    281    3653            �           2606    4048464 /   set_prs_birimler set_prs_birimler_bolum_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.set_prs_birimler
    ADD CONSTRAINT set_prs_birimler_bolum_id_fkey FOREIGN KEY (bolum_id) REFERENCES public.set_prs_bolumler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.set_prs_birimler DROP CONSTRAINT set_prs_birimler_bolum_id_fkey;
       public       	   ths_admin    false    293    295    3788            x           2606    4048469 ,   stk_gruplar stk_gruplar_alis_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_alis_hesap_kodu_fkey FOREIGN KEY (alis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 V   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_alis_hesap_kodu_fkey;
       public       	   ths_admin    false    222    3653    265            y           2606    4048474 1   stk_gruplar stk_gruplar_alis_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_alis_iade_hesap_kodu_fkey FOREIGN KEY (alis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_alis_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    3653    265    222            z           2606    4048479 /   stk_gruplar stk_gruplar_ihracat_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_ihracat_hesap_kodu_fkey FOREIGN KEY (ihracat_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_ihracat_hesap_kodu_fkey;
       public       	   ths_admin    false    3653    222    265            {           2606    4048484 4   stk_gruplar stk_gruplar_ihracat_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_ihracat_iade_hesap_kodu_fkey FOREIGN KEY (ihracat_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 ^   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_ihracat_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    265    3653    222            |           2606    4048489 -   stk_gruplar stk_gruplar_satis_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_satis_hesap_kodu_fkey FOREIGN KEY (satis_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_satis_hesap_kodu_fkey;
       public       	   ths_admin    false    265    222    3653            }           2606    4048494 2   stk_gruplar stk_gruplar_satis_iade_hesap_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_gruplar
    ADD CONSTRAINT stk_gruplar_satis_iade_hesap_kodu_fkey FOREIGN KEY (satis_iade_hesap_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 \   ALTER TABLE ONLY public.stk_gruplar DROP CONSTRAINT stk_gruplar_satis_iade_hesap_kodu_fkey;
       public       	   ths_admin    false    3653    265    222            �           2606    4048499 0   stk_hareketler stk_hareketler_alan_ambar_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_alan_ambar_id_fkey FOREIGN KEY (alan_ambar_id) REFERENCES public.stk_ambarlar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_alan_ambar_id_fkey;
       public       	   ths_admin    false    315    3820    312            �           2606    4048504 .   stk_hareketler stk_hareketler_para_birimi_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_para_birimi_fkey FOREIGN KEY (para_birimi) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 X   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_para_birimi_fkey;
       public       	   ths_admin    false    315    355    3894            �           2606    4048509 ,   stk_hareketler stk_hareketler_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_stok_kartlari(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 V   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_stok_kodu_fkey;
       public       	   ths_admin    false    266    315    3733            �           2606    4048514 1   stk_hareketler stk_hareketler_veren_ambar_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_hareketler
    ADD CONSTRAINT stk_hareketler_veren_ambar_id_fkey FOREIGN KEY (veren_ambar_id) REFERENCES public.stk_ambarlar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 [   ALTER TABLE ONLY public.stk_hareketler DROP CONSTRAINT stk_hareketler_veren_ambar_id_fkey;
       public       	   ths_admin    false    315    312    3820            ~           2606    4048519 2   stk_stok_kartlari stk_stok_karlarti_mensei_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_stok_kartlari
    ADD CONSTRAINT stk_stok_karlarti_mensei_id_fkey FOREIGN KEY (mensei_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 \   ALTER TABLE ONLY public.stk_stok_kartlari DROP CONSTRAINT stk_stok_karlarti_mensei_id_fkey;
       public       	   ths_admin    false    266    358    3898            �           2606    4048524 B   stk_stok_karti_ozetleri stk_stok_karti_ozetleri_stok_karti_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_stok_karti_ozetleri
    ADD CONSTRAINT stk_stok_karti_ozetleri_stok_karti_id_fkey FOREIGN KEY (stok_karti_id) REFERENCES public.stk_stok_kartlari(id) ON UPDATE CASCADE ON DELETE CASCADE;
 l   ALTER TABLE ONLY public.stk_stok_karti_ozetleri DROP CONSTRAINT stk_stok_karti_ozetleri_stok_karti_id_fkey;
       public       	   ths_admin    false    266    320    3731                       2606    4048529 8   stk_stok_kartlari stk_stok_kartlari_alis_para_birim_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_stok_kartlari
    ADD CONSTRAINT stk_stok_kartlari_alis_para_birim_fkey FOREIGN KEY (alis_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 b   ALTER TABLE ONLY public.stk_stok_kartlari DROP CONSTRAINT stk_stok_kartlari_alis_para_birim_fkey;
       public       	   ths_admin    false    266    3894    355            �           2606    4048534 0   stk_stok_kartlari stk_stok_kartlari_cins_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_stok_kartlari
    ADD CONSTRAINT stk_stok_kartlari_cins_id_fkey FOREIGN KEY (cins_id) REFERENCES public.stk_cins_ozellikleri(id) ON UPDATE CASCADE ON DELETE SET NULL;
 Z   ALTER TABLE ONLY public.stk_stok_kartlari DROP CONSTRAINT stk_stok_kartlari_cins_id_fkey;
       public       	   ths_admin    false    266    3824    313            �           2606    4048539 9   stk_stok_kartlari stk_stok_kartlari_ihrac_para_birim_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_stok_kartlari
    ADD CONSTRAINT stk_stok_kartlari_ihrac_para_birim_fkey FOREIGN KEY (ihrac_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 c   ALTER TABLE ONLY public.stk_stok_kartlari DROP CONSTRAINT stk_stok_kartlari_ihrac_para_birim_fkey;
       public       	   ths_admin    false    266    3894    355            �           2606    4048544 7   stk_stok_kartlari stk_stok_kartlari_olcu_birimi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_stok_kartlari
    ADD CONSTRAINT stk_stok_kartlari_olcu_birimi_id_fkey FOREIGN KEY (olcu_birimi_id) REFERENCES public.sys_olcu_birimleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 a   ALTER TABLE ONLY public.stk_stok_kartlari DROP CONSTRAINT stk_stok_kartlari_olcu_birimi_id_fkey;
       public       	   ths_admin    false    3886    349    266            �           2606    4048549 9   stk_stok_kartlari stk_stok_kartlari_satis_para_birim_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_stok_kartlari
    ADD CONSTRAINT stk_stok_kartlari_satis_para_birim_fkey FOREIGN KEY (satis_para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE RESTRICT;
 c   ALTER TABLE ONLY public.stk_stok_kartlari DROP CONSTRAINT stk_stok_kartlari_satis_para_birim_fkey;
       public       	   ths_admin    false    266    3894    355            �           2606    4048554 6   stk_stok_kartlari stk_stok_kartlari_stok_grubu_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stk_stok_kartlari
    ADD CONSTRAINT stk_stok_kartlari_stok_grubu_id_fkey FOREIGN KEY (stok_grubu_id) REFERENCES public.stk_gruplar(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 `   ALTER TABLE ONLY public.stk_stok_kartlari DROP CONSTRAINT stk_stok_kartlari_stok_grubu_id_fkey;
       public       	   ths_admin    false    265    3729    266            �           2606    4048559 '   sys_adresler sys_adresler_sehir_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_adresler
    ADD CONSTRAINT sys_adresler_sehir_id_fkey FOREIGN KEY (sehir_id) REFERENCES public.sys_sehirler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.sys_adresler DROP CONSTRAINT sys_adresler_sehir_id_fkey;
       public       	   ths_admin    false    267    3735    322            �           2606    4048564 2   sys_ersim_haklari sys_ersim_haklari_kaynak_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kaynak_id_fkey FOREIGN KEY (kaynak_id) REFERENCES public.sys_kaynaklar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_kaynak_id_fkey;
       public       	   ths_admin    false    339    329    3866            �           2606    4048569 5   sys_ersim_haklari sys_ersim_haklari_kullanici_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_ersim_haklari
    ADD CONSTRAINT sys_ersim_haklari_kullanici_id_fkey FOREIGN KEY (kullanici_id) REFERENCES public.sys_kullanicilar(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.sys_ersim_haklari DROP CONSTRAINT sys_ersim_haklari_kullanici_id_fkey;
       public       	   ths_admin    false    341    329    3868            �           2606    4048574 /   sys_kaynaklar sys_kaynaklar_kaynak_grup_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_kaynaklar
    ADD CONSTRAINT sys_kaynaklar_kaynak_grup_id_fkey FOREIGN KEY (kaynak_grup_id) REFERENCES public.sys_kaynak_gruplari(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.sys_kaynaklar DROP CONSTRAINT sys_kaynaklar_kaynak_grup_id_fkey;
       public       	   ths_admin    false    3862    339    337            �           2606    4048579 :   sys_lisan_gui_icerikler sys_lisan_gui_icerikler_lisan_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_lisan_gui_icerikler
    ADD CONSTRAINT sys_lisan_gui_icerikler_lisan_fkey FOREIGN KEY (lisan) REFERENCES public.sys_lisanlar(lisan) ON UPDATE CASCADE ON DELETE RESTRICT;
 d   ALTER TABLE ONLY public.sys_lisan_gui_icerikler DROP CONSTRAINT sys_lisan_gui_icerikler_lisan_fkey;
       public       	   ths_admin    false    343    345    3876            �           2606    4048584 8   sys_olcu_birimleri sys_olcu_birimleri_birim_tipi_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_olcu_birimleri
    ADD CONSTRAINT sys_olcu_birimleri_birim_tipi_id_fkey FOREIGN KEY (birim_tipi_id) REFERENCES public.sys_olcu_birimi_tipleri(id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;
 b   ALTER TABLE ONLY public.sys_olcu_birimleri DROP CONSTRAINT sys_olcu_birimleri_birim_tipi_id_fkey;
       public       	   ths_admin    false    351    3890    349            �           2606    4048589 '   sys_sehirler sys_sehirler_bolge_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_bolge_id_fkey FOREIGN KEY (bolge_id) REFERENCES public.sys_bolgeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_bolge_id_fkey;
       public       	   ths_admin    false    267    326    3840            �           2606    4048594 &   sys_sehirler sys_sehirler_ulke_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_sehirler
    ADD CONSTRAINT sys_sehirler_ulke_id_fkey FOREIGN KEY (ulke_id) REFERENCES public.sys_ulkeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 P   ALTER TABLE ONLY public.sys_sehirler DROP CONSTRAINT sys_sehirler_ulke_id_fkey;
       public       	   ths_admin    false    267    358    3898            �           2606    4048599 )   sys_kullanicilar sys_users_person_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_kullanicilar
    ADD CONSTRAINT sys_users_person_id_fkey FOREIGN KEY (personel_id) REFERENCES public.prs_personeller(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.sys_kullanicilar DROP CONSTRAINT sys_users_person_id_fkey;
       public       	   ths_admin    false    3667    341    230            �           2606    4048604 9   sys_uygulama_ayarlari sys_uygulama_ayarlari_adres_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_adres_id_fkey FOREIGN KEY (adres_id) REFERENCES public.sys_adresler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 c   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_adres_id_fkey;
       public       	   ths_admin    false    322    360    3832            �           2606    4048609 6   sys_uygulama_ayarlari sys_uygulama_ayarlari_lisan_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_lisan_fkey FOREIGN KEY (lisan) REFERENCES public.sys_lisanlar(lisan) ON UPDATE CASCADE ON DELETE SET NULL;
 `   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_lisan_fkey;
       public       	   ths_admin    false    360    3876    345            �           2606    4048614 5   sys_uygulama_ayarlari sys_uygulama_ayarlari_para_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sys_uygulama_ayarlari
    ADD CONSTRAINT sys_uygulama_ayarlari_para_fkey FOREIGN KEY (para) REFERENCES public.sys_para_birimleri(para) ON UPDATE CASCADE ON DELETE SET NULL;
 _   ALTER TABLE ONLY public.sys_uygulama_ayarlari DROP CONSTRAINT sys_uygulama_ayarlari_para_fkey;
       public       	   ths_admin    false    355    3894    360            V           2606    4048619 +   urt_iscilikler urt_iscilikler_birim_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_birim_id_fkey FOREIGN KEY (birim_id) REFERENCES public.sys_olcu_birimleri(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 U   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_birim_id_fkey;
       public       	   ths_admin    false    349    3886    232            W           2606    4048624 -   urt_iscilikler urt_iscilikler_gider_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_iscilikler
    ADD CONSTRAINT urt_iscilikler_gider_kodu_fkey FOREIGN KEY (gider_kodu) REFERENCES public.ch_hesaplar(hesap_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.urt_iscilikler DROP CONSTRAINT urt_iscilikler_gider_kodu_fkey;
       public       	   ths_admin    false    3653    222    232            X           2606    4048629 H   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_paket_hammaddeler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 r   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_header_id_fkey;
       public       	   ths_admin    false    3679    236    234            Y           2606    4048634 H   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_recete_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_recete_id_fkey FOREIGN KEY (recete_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE SET NULL;
 r   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_recete_id_fkey;
       public       	   ths_admin    false    234    244    3693            Z           2606    4048639 H   urt_paket_hammadde_detaylari urt_paket_hammadde_detaylari_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari
    ADD CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_stok_kartlari(stok_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 r   ALTER TABLE ONLY public.urt_paket_hammadde_detaylari DROP CONSTRAINT urt_paket_hammadde_detaylari_stok_kodu_fkey;
       public       	   ths_admin    false    3733    234    266            [           2606    4048644 F   urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_paket_iscilikler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 p   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_paket_iscilik_detaylari_header_id_fkey;
       public       	   ths_admin    false    3687    238    240            \           2606    4048649 I   urt_paket_iscilik_detaylari urt_paket_iscilik_detaylari_iscilik_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari
    ADD CONSTRAINT urt_paket_iscilik_detaylari_iscilik_kodu_fkey FOREIGN KEY (iscilik_kodu) REFERENCES public.urt_iscilikler(gider_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 s   ALTER TABLE ONLY public.urt_paket_iscilik_detaylari DROP CONSTRAINT urt_paket_iscilik_detaylari_iscilik_kodu_fkey;
       public       	   ths_admin    false    238    3669    232            ]           2606    4048654 <   urt_recete_hammaddeler urt_recete_hammaddeler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_header_id_fkey;
       public       	   ths_admin    false    3693    244    242            ^           2606    4048659 <   urt_recete_hammaddeler urt_recete_hammaddeler_recete_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_recete_id_fkey FOREIGN KEY (recete_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_recete_id_fkey;
       public       	   ths_admin    false    244    3693    242            _           2606    4048664 <   urt_recete_hammaddeler urt_recete_hammaddeler_stok_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_hammaddeler
    ADD CONSTRAINT urt_recete_hammaddeler_stok_kodu_fkey FOREIGN KEY (stok_kodu) REFERENCES public.stk_stok_kartlari(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_hammaddeler DROP CONSTRAINT urt_recete_hammaddeler_stok_kodu_fkey;
       public       	   ths_admin    false    3733    266    242            a           2606    4048669 :   urt_recete_iscilikler urt_recete_iscilikler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 d   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_header_id_fkey;
       public       	   ths_admin    false    3693    246    244            b           2606    4048674 8   urt_recete_iscilikler urt_recete_iscilikler_iscilik_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_iscilikler
    ADD CONSTRAINT urt_recete_iscilikler_iscilik_fkey FOREIGN KEY (iscilik_kodu) REFERENCES public.urt_iscilikler(gider_kodu) ON UPDATE CASCADE ON DELETE RESTRICT;
 b   ALTER TABLE ONLY public.urt_recete_iscilikler DROP CONSTRAINT urt_recete_iscilikler_iscilik_fkey;
       public       	   ths_admin    false    232    3669    246            c           2606    4048679 H   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 r   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_header_id_fkey;
       public       	   ths_admin    false    3693    248    244            d           2606    4048684 G   urt_recete_paket_hammaddeler urt_recete_paket_hammaddeler_paket_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler
    ADD CONSTRAINT urt_recete_paket_hammaddeler_paket_id_fkey FOREIGN KEY (paket_id) REFERENCES public.urt_paket_hammaddeler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 q   ALTER TABLE ONLY public.urt_recete_paket_hammaddeler DROP CONSTRAINT urt_recete_paket_hammaddeler_paket_id_fkey;
       public       	   ths_admin    false    3679    236    248            e           2606    4048689 F   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 p   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_header_id_fkey;
       public       	   ths_admin    false    250    3693    244            f           2606    4048694 E   urt_recete_paket_iscilikler urt_recete_paket_iscilikler_paket_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_paket_iscilikler
    ADD CONSTRAINT urt_recete_paket_iscilikler_paket_id_fkey FOREIGN KEY (paket_id) REFERENCES public.urt_paket_iscilikler(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 o   ALTER TABLE ONLY public.urt_recete_paket_iscilikler DROP CONSTRAINT urt_recete_paket_iscilikler_paket_id_fkey;
       public       	   ths_admin    false    3687    250    240            �           2606    4048699 <   urt_recete_yan_urunler urt_recete_yan_urunler_header_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_header_id_fkey FOREIGN KEY (header_id) REFERENCES public.urt_receteler(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_header_id_fkey;
       public       	   ths_admin    false    244    365    3693            �           2606    4048704 <   urt_recete_yan_urunler urt_recete_yan_urunler_urun_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_recete_yan_urunler
    ADD CONSTRAINT urt_recete_yan_urunler_urun_kodu_fkey FOREIGN KEY (urun_kodu) REFERENCES public.stk_stok_kartlari(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.urt_recete_yan_urunler DROP CONSTRAINT urt_recete_yan_urunler_urun_kodu_fkey;
       public       	   ths_admin    false    266    365    3733            `           2606    4048709 *   urt_receteler urt_receteler_urun_kodu_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urt_receteler
    ADD CONSTRAINT urt_receteler_urun_kodu_fkey FOREIGN KEY (urun_kodu) REFERENCES public.stk_stok_kartlari(stok_kodu) ON UPDATE CASCADE ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.urt_receteler DROP CONSTRAINT urt_receteler_urun_kodu_fkey;
       public       	   ths_admin    false    3733    266    244            K      x������ � �      O   D   x�3�4�461��v��srv�0�2�Yrz��x��id�e
242�p�s9����Ԍ+F��� ���      M   0   x�3�:�!��1�3*($�ɑː��1��/��N� �� G�=... �^      Q   ^   x�3�tuw�2��vrtq�;�!�˄���4�t�?2/T������'�˂�Ȇ��p��	gdhP����y�\�����F��0��u"G�=... J� �      S   l   x�]�=� @��ERZZ`5W�a��������/y$�,,:&��Ď�U�`�J-��^�e\�?�אQ��P��RKu��G�7�uCi� NK�-�      T   O   x�33��=<��נ#|\���,8C\]�<���P!K�#<��C������R@% isCN'G?oG� �=... ^�(      W     x����n�J���Sp9d�]\*�kdف�p0�N�sBH�J ��y����M��fV�I~���yIQ���&����UW��-۰l߸��x%�a���.�ߘ��yM�D�'*5���8�W�Qj^�U�݉���Y�K{�x��|��)��mH�bT�x��5Y�Z�����w:��������<N�E�5fV��p�WjuOG�,�Ӱ�%�ת�Az��(��$Ѥ9�u@�_,q�W�x�'�%X�����EI4ǰ�<����&��f�[6�*)�~���;0��X��@�dl��uğ��hI<{�q�R�������wۨ~�\�1r?0Bn�z�"G��T��:�| Nt�����~�0�,V��j��^XF�(��l��f��Jf�R@W��2����կ�\�LK<�%����"c\zBr��nݻ���B`��90�D��c46���s�M|�!6�v,�������qi"���a�%�$v�_�+���H�c�T�[`7��oPz:���w )���l4BN#����9�&p>5Oo�3��@�;�!|��o�ŗ*�w�`!$��Օ�kظ��Ǐ4e�x|���^��{���K�O6�ԝJt���_�sD�Ifjb��5U摊�L�&�ܡ�>�+����6�g9e3��ͻ��k�/;����Ʌ�ߥ'_쟞\������.x)V4���-NZ�ZL�4�)p�����8�α�_կM�j����i�0_G	�І�*�D�U�}�biԆ�6�J+��۶V��H�m��?c	
�L
�<���T5ҁG0��NT�����.�]�MٳوD��!Qsl�U���6�c*��EI�*�6��b�f�},�)�ų��3��HxRw9�$�կ|��8�����4�_q���v}�J��X�+��x�+��&�ǳ�N��r}�daW�NU�2�&t�X�T�|(جԼJ���[և%V������&� ��n���-f�����O,�4*�GʹY��X0�⧓��&�X���%f]F����N�\�����T��r@"�`4���6,9Vw,Ef۹�J��5]��#��>���:�]��m��A���""J�ҐH{����th5ǸVf���@sSBt�5t����i/e���:�FO��_0!F�e!C	�[wD�R��5�aD$D�z�i�%8\-��eH�>]Dv�	jeg�!Μ�L�X�DZ�G
t;���(� L������M����l��F/�G���VE���Y��58ƻ�[a�Z�kiA���9j<���,��p
�]�Kv��%��p=�˼W��GϨ�Y���N.d� }�~�)�b�Tt��t��JNإj�;�q�+���KI���pЋ�KM.Z��A/6Z6Ux�A�M��g�>K��I�u��{n8|B�2͠;�jz��@�vO����w���t�=t��}�_���'�l^����a����|�k0�����`������aO�SL���q4ꙣ�i�Bw�&'��:�ޝ����PC4�� g�fS>������d�m���{����x������;�L�՜E;l�+��8v:=���_CGU �I��� J!<�A��d!l��=l=Ք��2l���4��fP����ET7L"l+�:�7�m���!Xׂ�w�I�9�A��']!�Ai���u������:�^b��ER������R�z4�s���=�YF"N<�YF"<�YF"P<�YF"�<�YF"���9Frt,=�H��5S"?6��\�9(�5ft3[P5�,� �c��>���bR��,F�-H�}iVk�e�X�L'�����mt��X>L�Q�5�C��D���j}!25�����ҘF�����R�Ʌ��ԭ����4�6�rU!���|̀�NW<L��&���\���s�X�z����v�HsΖ���F��z���8�;H��h�>#VTq�fq�w������P �Q:��ĸ��"� ��L�(�q����#9<��9�+�u�RT�Qs�HʋZ��n���8]�O՗%����\ �5��ɸL2� ����'H=�#v��zr�n{�٥,�$D�+C�T�k@R���$/�{i@Ҟ�S�pJw�JR��K�X�9w/%�y�������/68ǻ�����.�K�}fmB��{����z��{�$���DC�v��+����nO5�`���1�&c��r�v�X���Qv���Oyo�!x�-�T��%p�Ē���/_�:��uyk���7<��q<�E�)v��4�;*�Z��>�%�P���w�����]�y%�]�����o.�d�;�w�Bv�nx�CY%��,��Vc,0%��M��d\��c��W�E784X�h��ʱ�֩@l�սJ��*Bp���T�j��0�L[˟|���)/hjdw ��zOP���(��a�FN�(���w/��m�{ٗ6����M�x|�#6u.nE�q�'�t��|���:�Q��v]÷�˕I��(-&� X��ܚV�W�(� ������!٭x�,*a9N���՞37�!`{>��n�k>�\��ZGe��d�`�آ�Sqު;q5��#QJ�\t�F7|�H
���+��<nA��`�I���%���3�G�w���ԖN��}S����6��Ƴ�M�h�I(�{zvK�˯��_q��>J����&�|$�C��i��[Q4�Ms	=���K��(m�~����X}$x_?���"J<�c5�*�X���Cg��M�z[W����ޚ��vX�6Xh�	�^+��6�dG��&��BG�/и�Bf�(�M�4���#��%s�R%*u��=��L�E��l�]d�6o�x���KM��+)7gu�k~�`gӨ�x\��n�6^ql�yHE��%@�plh=�I6��<�˹�Y�6f&���mo}��wu?lߞU�c$�B?o?�Y�AW'5��
��]�V�
9K�%̪p��2�q�������,pS9VW;�t�vwl�1�����Q�P����t����3��s�a�Shvei�����>��C`[�P�ˠ����o��ceƗ{�j�Nx�|H��;y\~K�EP#p�cmCl1?��u�ϫ��|��i	.v��}��p:ia�ۺ�gő�9vE�k�R�*��F�N�چh_��s�~[���/g�_@�Vo?���8ֳ��o�o3����E��9{�+݇ �ɶ�KHp�����b �#8ت�4�P���-�A�v\sW� �/�����nL���}z8	8����x<����-�j$n�?���H,�M��d��m���8��+D��e��ŵ�l��?��g��1��+Bq�ѥ��yNy�אǪ�z�F�֯����{A�t�+��2����f�#���Pc���ȡ�{Q>�ځkț����މ9��C�{|�?�^�m�����B~�k7W?��^o48;�xgX/,t�<E��w٘�|З��Z��@�ﻧ��aw��n�~�vOG]�Z�<g�a�<�~�7��N��gͥ��P�{��[J�h�=26j��Y���+0Y?���|u����`t�����/��;��      U      x��]Kn�J��V��k����0��-V��eP�=���;���5�� y_�E}�����
��[���q2~����.y��z^�鬺_>��2}�ҾZ�m��KT�����C0�W��,K����c�'�z�Rui_߆�N�<܆F�G��E���}�����T�E�1Z~�6�{{����~�����?�D)#Q�D��^�^��x�Ͱ��K ���%FMrv/�d��z��~�,��_eΓ��[-�j>Ť�Ta��|�T����\\�Ll`Jc�ha{�tU�U��Ӯ�VͲ��b�fbsS����N�����,��O��28���,nޤ�0�U���c��d��"x.W�&t��EX���s!4���r�����\�IF���)Pΰ�*?�Ϫ_ʩk�7�EB08��������o�w��T��Ƕ��>K6 ÜC�	�ﻟm�{m�^B��CX��[څz��y|��,�ˤoX�e;�t�Z�ChWb;�c�� �"K�W��jҰ�Cݧ��YՉ�{���Q(���"���4k���O!�ؔᨩ2Kf�CW���d�Jfz��R��YM�I�+����Q�E�!�D�K���bTj����0 ��y�ع0pkJ��H`�V�T�H�e�
�$|L��.UY�^�l����>�n�,�$�9��*˃�Tl]�el�q|@�Ph���R�a�|t%��b��S�qM�J�1l�&<��
�f���qq�
�A�4��~�c:p4	''��E*0|��]3;[�;BẌ́�6K4(hCN?үG�
�SΚ	����"g�D��`x��Y3���M9k&r��kFΚ��-��wį��_-�wпE�6k���f1,����]�n�D�D��{Ni q��%�cUP�n68 B���>��g��� ῆe�q��~��QWޖ������b�1�0c��A��Z3L�MLv�	������]µGw�R
�l�qG�@"l�-?Şl%b��A��s��cM~]��kJ͞I�`XJ'K] &�e���P�Ǫ�s��a����}��hL��I��jU��b����h���]x��	Ӂ0a������s���H�4C(�� N+&;����jf��L6��́�`(7uW7��r,\�Zi1�dҴD�ل�!$l��.��&�v(*7혩�
�2I�~8��l��m3��F(�[}�725��Di��z������?���a�.�c:W��\�A���y��,(�=�gjb:�#����c5?K��Ť�AJο'�%Lg���0\l�l=��0S�U��l��6�AP�b��KX�|lS���
u�]�X�=cT`)T��^�uiȦ���W1Ϩh̟��A���-�f�Q3p��J͘�X&;+�+��e1͔�
P؄e1͔�
�X�>�w�I�W�)^�0��f�W(�4犙���&�"F�,�T$H���>Ѹ}����i�=6�̔^g�d���$��K�~@8*�T��!R�6���c�� ͕��xM3���
\�;:4S}+�we9���T��,1�B�&�MW�j�Ӎ~7�SVI\u�ܼZxKfr��OR�O��$�:���"�fka�-�x�"���e0l��㚬`F���� l�=�K}hV�>{O��G�]�	�a2�����Q�aq���L GLY��������ˑ@%!���J�aw������I���1\$q� �Z�O؉��c,D(0�>�(l�W���*p����)�+��h�O�^f�r�e�6�6LZ7Lq\��h�MX�N�0P��'���'@�ޤ�W`�����C�M����(�%w�jU	�-�n��0~�>�$QK��~��1^&?���9��Z�S�at��Z�,Q1�
�e��9�0$��A�`>tsTҰM���\Q�d�_ΰ�i�l����N)�izX�w���Gv��"����8_\��02s)�]����c�⇂�e��q���������!�5�<�c�dR�0�["T��V�"������ R�8�H�B�"�q�B4ɦ����$��C�c�[�l���!9M��?D�8U�d�����$��C��.��l����|=�����8���,ٻ?�۞"yk�7��5N�!���M��߷�U;����Vu�&�
�28 \�P�lU�߫����I��jsʗ����V�q�Ah�}^ :�S�"��aj���W����"0G;\y�d��H����W�ÒJ����,).X�2�-9��l�z/cK�w�dqi��L�X�^'���b��qH�`9ߗ�`�q8�ƛdLP�J������ٍ/���c�|*}�tt}�f�x�E�)�ҍmC5�a��5\��p�f�)UrW���<Pd UF5L�V!21�[�Tl�A"�^T]S=�*���o*�����Fje��ނ/��Fݕ��T&����"�M�	���,�V.�b����6��-�
�9Ư^�\��:���ʠe*��z��Q�i_��b7˔��-0�[�"�X���+|Y.��g���e���RauF�Eo�Z�V,�Ta'*�Y�̆��^��f�2�z{�2���l����	��'�����K�#����',W�@�l����\�>aM�4�\�a��b��rIs���q��x��WBs��a8܁⮐ͷ\6߁�&��[.���t׊S-�:p�u�D˅��w��W2P�\��@���8aV4��pհљp��<j,�l��� �˅�N�`F.�:﹛(Բ\��U����5V���`�y6&mհ�#��!�s�7I������~��1�2��Yo1����}O��������w�s��crQsw���z6<|��AZ��؞B+I�����o�_I�=��1}yJu��2S��ƏDp�F��fC��Fr_&9\�1�>���qΡܪd��-<?�	z�-�:�÷{	�x�Zx��s� �ӵ{�m��2�d~��xQ��sN\.���K]��,�Dƕc
Y�@?�Do���T���c�
��X�Ad��S��T��T�ɥً"q��f��8��Ou:$}䮿;�7(J��=���Z�4.3[��ˎEQ��q9T��Sc�_�B>y|��%ǵ���uJ`���)c���`���g�r��"������=d���̹{e�quB���"p��0�O"�ՏЇ<6�����Ԅ�7�N  ��0�d��*����P�Q�}x��	R��:�:z��M L�v�Bpz�tC'J_O��<�
�u6���������z���@5�؝=|��ſ�D�v����+�Bp���I��^m��8dl�:Z�v�Z�M_�x�a���*���l��Fw4>YG�1��he�o��R1ε��g}rH���(��:(!I�~��A�����=8Vz�̫�pt�饱1��O�8v�@�y����MK�M��d�����њ� f�J���v%�9��X+�Y~��)P�R`�<�/�UgLL��r��V�$����ǆ6�`h)�d���2���!I~�#�L۱V�;��]��V�@��<e��۪_h_D�'ŻL�)�,�|���}��>$���Y�}�R����e@A�n��v
��i	D"���eJ)��=��f2�-��i�q��&�X2�܇04H�T��b+�}?C�W���cJq�UbBJE����ε�luL�)=P�Jޭ��f�:D�?T�뻰�n����Rǂ��I��k�a3#8��㸑�QO��>��r�ǯm=?�u��/*�äw�=\�Ořhu�Ԧ6��sq�՛Џ=�B�0vlr���%Y�M:YQ��ĸ��3�y{�>�tK��B��]����g�S���զ��f��>�v�^)��4�db��^F������%`���LM6f	�]�Q�I�҇�Q�p�R.�j��Ǽk,�����>������Oc.JBO].�S�*ӖJ�� �K�4�>��^~]���{ZjJ$Y�
\.%mA�V]JG���qBO/IB{�����v�KU[Pf�k�!�7�>W�$�T{�<�@���Œ6����wٯ׵d$��1�λ�Pa�jø4M�u�/�v439������bP���h���"�T[��r0��k�'���
�n��7��� �  ����Bq�Sm ������f�����Yz��/�}@�ie���_j\�CH� ��,>X��:YT�u7!2����� �U�W��
��-lfá��C���<ӁO�U�MN���o�{�k��e�IȯiW���b�]�j�w��ە.9=�<\-����>S;s���OGs\с��b��r��	I�K$:�\Y&�ia\&�×Eܷ7����&wh��'����dH�.��H��2ԣ_'��!�����ٚ�8;\�߽���^���ݽ���^ž/̴��"OJz��zؽn�T�+�����a�<�Q<FK���.H�{]-v�T��B�_��R�����+'h��>������OG���p��^�A���'�- ��Z8�u��ll��m,0�嶦�D�˯zC��w�l��cJ+�{E@��� �a�����J=_ioGXMW��+�扉�!��"v��8[�б��5�2Q�������1Ub���#4{<��W�k ��f����H^}�;���(S�?�kl"�����j�v��B��]�ro��d��#bEʣ���8��m��-.���=�����6��n4�g�C`��,�؊��#v�	�ļ9�|��>�Yt܏�|n��2}zbOU&���rz�2*;���'n���?�}E;��?16w�ا��x�Nhc�h���dZ��Yj�t����\�(�q�b�:�����%N:�T$[qQ�񟿢���ח/_�ˮ      Y      x������ � �      [      x������ � �      ]   �   x�}�Aj�0E��S�>��Xa-b�[�)�B6j+�q�m�Az����*�N�+���4����X���no�4�r��L��&��vS��cݬ붾���D����b���lf��%q���,�ٔ�DI�Ua��Aw~|��ǝ�������G����0���1�?N�������w)"J��&5;��\ۜ*cIIQY�d���m�$�$�R�      �   D   x�3�4�tt9��������q�9������u�ʅp�pq���d��p�y�~�~@�=... ���      �       x�3�<:���3�ˈ3�5��1ҕ+F��� Tk�      �      x�3����2�tr�2�t�s����� 4�      �   @   x�3�4�30�4�4�500�4D�a�1~@�e�i�PlU��a��&��ՆPUH4L�:F��� �	      �   I   x��I
�0���c�xo4�&Q!���C�Z�5�׈�<^Y���s��'��^�0�R�yˋ�v >*��      �   ;  x���1n�0���k�{N��.�0P�JR&���|��{50�}~z��2D�����?��v8����~��w)�w�����Mq�b��`R�S|s����/������|W\
����ݱ��]�����mZ]��КRm��,�V�n�Rm���Z�#n�����6��G�'�����`�)�����b�2�����0V�/I/�p)�*��#����.�8�4=:�X��ք��9�+fiyZV���2����ieX1K��ʸb���V����b��5q���2�XZ�V�[iyZVl��ieX�����qŧ���� 63��      �   7   x�3���p�v2��@<o�#@<c0���5X!�����$hDpc���� K�$      �   +   x�3��s��9�!�U����ٓ�!�~x���k��W� #6�      �   �  x�}��n�0�竧�� A+�i��F�Z���)�c��������cWk�f��z�Đ;��<��^��8~V(��2Ef�|c����8yQ&�+.ƓJ������q�J�g<�KYT��'t�a##���������p����Φ�Ŕl̛ }��		�HH��98A���G�r]�K}�t-u�Fb^�"C��S1�-1s.K��q\�#�.>��K.�#W	���lč�
]���LH�~����\7���5S��)���X�\�C���*�M�q����"���6�@��s/��I���� �����:��g���V�����ǧm��Ul�t���0��ɠ4��g#����r���,�U��Ff�O߈���BUiY���o+[��7Zpq+�\�S�!G��r�C�Wj��~���j�þ ��4��J�͙2�/1aלP/o��ӥ$���z9�'˾�[��>�<\Z��4ܹ���x��u��eY� y&UP      �   $   x�31�<���1���#���q�44������ �	$      �   !   x�34�<���1���#���q����� y��      �      x�3�t�2�t�2�t2�2�t����� $ �      �   0   x�3��=<�����Ȇ`.#NWW_G?.c��(m�yt��W� �|      �   *   x�3��
q�2�<�!��.�����
�!�cW� �      �      x�3�<������#��]�b���� W�      �   *   x�3�<<��5��_.#N ����e��txN�?W� ��
�      �      x������ � �      �   3   x�3�tr��9�!�?�3Əˈ���1������5�<�! ��Ď���� >$a         F   x�3�tr��9�!�?�r�t�S>�!�1�Ȇ��|\���8=�<� $��1���!!G6�h�1z\\\ �$_      w      x������ � �      y      x������ � �      s      x������ � �      u      x������ � �      �   �   x�]�Mn� F���`43��XIS+ƍ�y�u��C�`�?ip� =>F��H=ƽ�nȄI��稧�gM�u���ｉU<����+g��Ua��WD@��Q!d!`eůmxcj��pM�7U���s�y���x��p�"�P�Uf=`���!dV|Z؃��8�^���9~�^�]ΗN˥�ө��у���
;��TeD"��j��V|:=�i�_ ~V�      �   �   x�mPK�@]�Sp&m��rG! 1.0�=�g�x/!~_?y��i	�ݦ7 D�`��~�d����}��8��D����$��ڂ�F]A
��@�Š�?��<�)t�yjRC)�6�!p����е!�G_A��~����/��q�w(�u��aC3O�<�Ch�O�d�3R���U�oX�Y��Ȳ�	K�AB      {      x������ � �      }      x������ � �      �   #   x�3�tst
:��ۑ3�9]\���=... ��      �   i   x�}��	�0ߗ*�@+f%�\���Km֐"b_��#���ݙh��)"�%m��V�%^"�z�<�J��[q��H,�T[�._��/�����Yi����[zc�	3�      �       x�3�qQp
�4����Ê�b���� ��	�      �      x������ � �      �      x������ � �      �      x��9�%��e''G�! p4��$����J*�c8,�Ƶp#��L�4*4����Ž��i�>mI�r��?�/�5���������������ۿD�����?��/�������������o����g�����J����>S�Wϔ��{�������#�0��_;���\��U<�������5w����7b{J�-�7Ʒ�����Orm9杣���=a�Uc(�������s���������89x��c���|�ޡ��?�����Ώ����GH�zv�%�\b̡�}���#�T"�zH��_�Mo~b�}�Hs����2�(s����k=�}_K�����9s��y�i���83�ݞ��<���п�"����m���<�)�L��{_�'������o�~.���h�S�מL����u��q�ۿއW��'�>J��~�T�q?5Tn)��C��:<\�|�|�|�|��O�#�߾���/a��l��+���w�xB�C}�Xq%?�)_*�iԅ7�|j�O
��u2f�`�O�e������#���{˚�(.o~�X|.�5T�	�΁�*����_X�������=?����3���ٞo��Y��WpCs�����H뭳�f�#����;���v�����{}�~���F�g������w}������[£��k%~��:S�`���>g>H��������m��G����q��O�a�;��g��8u�{F�7�&�
\8�������9�I�-��Ms���A+?����o���P�<��7����w�o��j�_� ���y�<)���ۑ��>�|Jq��ߏ�_ op���x�59�����j�|9�������9>nd�}�؇��}��s����w������WX���ȟ}aG� ����;� ��=�YOo5�s������6VۊE�)�g������o�a��F�`���p�}�(T,T9+ z��}_-�] /5�R��8����SL�3�^��AƧ  �>q˓~z\2�X�;g�]S�1��<�>w:AOO_>�����p��%�H��y�����>^�s.�W*_�yХ���/�'�㻬����d����Y?�=����
�S|x�)ԇ�_�}:�u{}�~8�������9���8ľq�:
mN�!�qm>�+�ˁ�@��+���*�m{/�������J|��+E>&�������&& ��gչ�T8c���Y���9{D^�b�$�<WQm���`�[O��ߚB�����c}gݹ!��C�s�H6J�Q<�L#��$`-絊��TOt&W }<�X������ض�=(���Ay������QS(��j����[�8�m�g ,/Sy��u�"x�W.�4�S;��>�X�����+���@�'r;��|&������ݻD�8��j\h�B	8Ռm��Ml�:5CQ�:D�)�3�Z7F�9�"�2~�f�����λ�[�[&���XG$�����cO��h�zZEO��k��6�G�|��`�={��ܥ,�
��a<�CKҹ̅��C��t��5�2N@"^4���mٿ^�'����=�6�cE_��?���p��O�a9������a�wz�2<�O�߃4~���c'��_M@r'& ��gt�/N���������k��ı��O:��ɟ��O�|d���c��h���J(j�@�1���	����Z�6'8[�`��x1�~ϗP��6����ϥ�ϋ�C�6�ua�5��Xd� E������.��/CSb�"�1k4x�ոX�.�,sz��N$K����|_*Ax�;����0K����>#��k{����w�8��n���bS�6Sµ�/����:���pQ����i����#�3�z�>#���@ӑ��y/JB���b���xn��5E���:fpi�0�a\�szo�/n^��vM(8��}
�s�5�'XVAoR��c8+�3��ȍv�������/�u8���e����>3�IO����&ss�}1��>klu���p ��ԛ���&� S6x�u]��;�2�^@Z楪p�����,��������{���7r�j0�H `��(��1�'��q��`^'"�i>k���c��މi����H��aS�	��������[(�<��X$%2���@������p����$���,������$��µp��T�^vb��r���� F�W���8\~���TT2s�o�@��9:^+�o.�9V�To<���<�p�> ��UL��d?@��m 4������?�V�0�α:�j�RS[� ľ���yf�}�0=�TWXCyNAҰ&�,�'�0r�,�9|ӳ�N���Y�O?�a"�\.��UD-�>p��O���ջY1f�ˈ��O�9�����t�7	��f�<�<;��l+n�#��7�P�o��᜵�<|�� Oh}`�F������[��2P�;���@8����8�ps�1��{
��<�0��@�2�����-d3��>�35^�;����@0�h�9�=�[��O�i`?�x��y`ؐ4�7�b�ao�Z5@��]�(}�}y��4��}� A�_�<�L���F W��h���P$�Yc@2�������	�j����ǎ�"Y�S��I�JP� b��ȟ��Q:gT�5��a��n�7h��'�~�	B�k;y�ڎ�Ɓ�U�B	^b��x�7���D�c8����'j�g7�98%ؒ���}_�R���}��F�S���H�=��9P�D�Y�w�4=U���<0��-"�ҞrJ��d�)��������|�!p��>s����˟Q-���g��!҂��K�R�Gc��a�LO�`�b���2�����pr�  5�F���l8�4�K�_��O�A�^iʞ*>g"����w"�q��� #H*͛�H�}b��G w(W��}�b������]D�[�="d��� �k�sII��V]qd���L'�A��JQ������Z��u.��������*�x��q!	�Y�B+��}A�x9.���<��~���
M����6+��/�%Â� �7��>��cB�B�僴`�������93	"PQ��x��Ň���gBl��˒�dv����,���E�V��GMk�!~g7�O����r=�}�0rq�sY��h��}�ד׀�@e�{\?'��U�޾#7 �?HVI�φ�Ę?tV`��\ �/<��Rt��>W�N�%��T�>x���#��HF]��� o�لr}{�r:����^p�[�R##6�QAV �l����u�M��Z��#r��\�ݕ�p��k��I�?O|��UN�F�����Z�����������M��r+{�����X���N��++t�u��
O�c���Ja}e(R������K(���o�`m�c��x�,�"Zش�u|�b;Š�%�X��_l= %|��I\�V����C�8(m+/!|��H��%IPJI��N.ܘa�^LUe�
����<��qZ��P�p�=���~�Y�2_���b�Q藞*bݰ@�����дq���1�U��9Iz��%���_��ǅ�A��� A}�����1ҁ]5��ۙX���
���ƈJs�u����kjbɊ�Ԇ\�,v��}H8�D��Ys��>'�eVԛ�C{9O;Ҋ~(&̾y8����šTL�<���e>�兀���`!�Z�H��+,�������r�H9�>ѽ�x���9�xI��:�! �4�O��������E0��/����r�n�M�,^�����GV��b�R���*������woε�ě��~�eD
�&E�������TW�5caJ��0�RA�P> �*Q�Я�^&!�ҝ���Oë�C>���>��lE? 93��1o$8!��l���@���g����E�z��S���9�	<H�k��f�?!� �nF!&�G�;�����C��˪�}����lMy.\G��M`�f����    ����_>������8��?
�9!P8}d�!dT�gۘ�>`�'&^��������5�ڼ^]ڏ]�o�a5xF���+826	Q����s��3x�`$�g@��z�@qK)"N�R��q,S�z3d��p��'^iC������(�㔌���j�c�/�9�RC�6^��}cf�e�8��G�O/h@EP��a���^�������rG�+�~y�`��*�H��R `�ѐ�������^�@F�K�� ��17ʫ7�L�s}���D_*#� ��Э+C� t¾�{۸=��V�B��>�K[��߅|�]�$8\D
�X��$X�k<��}�"��bY`�T�����5f_b��G���,y���N���(U`�_�k��1��pP��d �G���pL��)�����Ow�!=o��OeI���F1���0�#/^�Q	�$��#������;s�!���8z�����A� dcJ���qe����"؉�a��/�y�.=]��y�ۃM�*��0,��A?� 3>p�#{MC����okb�1Y�~��H�̲߼��)�3W�$��|���l!Y<Z N���/���E�} ��f�
 s���b�u�!�I|b��	�� wp!Iw��|�p������s��M5Vd�H�-!�%��Ľoc�z�������:dq7�+���I�S>�(�98(�0�h���\���������L�}���'&��3�a���L�l  2.#�Ƒ�
X'$ܘ �q5��EM"�Oɖ�� ��nW��~؅�E}n5��G���`�fv��$@_og_K�G��1�]�g8R�.B�B�A����'�����=[�4>����rN Q�������J�op�b(�Bޡ%���SE�������^?
P�P����8Y�w�͈�`1�ǎ����8�y��a#7��� AP!@D���a/>�K��6��j"��3Q�e5l�̸5��I05c�5H8H�\A%�M��,٢�H�`:#Ԑ+��oh�<PU�d<co�?ξ�{AO�h�}ăI���9�v� ��1F����5�7 ��x�h����b	^��䁎�	X0�U]&��pD�4�l!��`D�����}�6�w���H�4U ��\��P��4#\5�lFk n��nf�]�Y�u�	s�X:���p">�=�7L���^ ��'�O�Q�o��	S�1hk<���d�)2żQ�?^�7��:k B���>���;�3��x�rk�:'1����i�d��~�����G�D�ɀI>he\,Z'h�	!
X��=�����vK,`H��;�2�" �9����	@N�}s��#h�a�y�#����<��21���Z��?z���r��|�2�W��|��t.̓�\��@�ėW��֘=�5����)f�)�a@D���@4�Mg>*=���Je�~�"Q��-�0|�aZ��!B������<-��Ū  �~{uq�ߍ�M-��,}�i��n�>(�4�W8{#r�/f�`hx�=��t���J�ƬR9�9}4Z���2@�dY@ �������y�p�|�.�r $�6��g�a�LT@�0�c�̱L������J��y%	��@�f~Pm �A��aM`)��Ѓ|t�8]�0�U��˥�(�$���s���ذת^���<���__�$<�0���1��n#ze����h�ˇ���}TP"F��i=���a�'F9{��5h�"@��H�K`Y9����U�Q��@\pP�xc2W �΀�냓ŵ�2�$4Om�6El�3�5)�m���C8<L :��rfh����w���=���
��<�����a�>�Y������N�xd�*`�	0>�@�{�$�fk�f���v� �Z2D�ђ�/d���w�7]\yF���ngZ\���y��xP���h�>�$�7���a�a�L[�n��bFt݌h�0AO�b���/�ŷ DA{��]��5COs����Z`�>}���;�jX��j�9��ۉ3��~f�!���8B�阵����f�>���EN�*SL9����f e�v���&	x $%�&��;�l0��� ح��?�o���ʴ�Y�\X:��W���T �(�X�ה%�E�I�*�|��ll'��%B����*��,��>#��&���>��F� qa&C'�*h���a
�IqXP�J�iF(�]�A�l|s��Yl#���<�����8���,�nrj|�ԇ�?�X^���/��;ς?#c�2/���7g�ףr����
�����L5�έX�*�{a�7&0A�&%J��.'��A�'^��'�������p,3�"�'��X���ԧ��l�@�[�_�0��cD�̂4�u~�j�����4���A[[x@�+a]�ʫEr�	�8�������VL���2��=S����
X=�I"pqe�u�	 "G�n��e��-��-�ǎ`AM`�,�K�� �ǂ���4!�M	��ݛJr�h`Ð���+�2%���@7IŶ���0kD��\�k��!D��XɃpD3+�A�WK�ptrh�bXH��b��ܣQ�D���9?�y�Cm&LM1@���x�3���I�Z�@$�Q��Rд"U_�ͨ8�b��K�t|$�?�r��~��+5�<�O�\`��q#��0J������5|��I��'m��.��y�3�w�&��qmآukM� m��V������>G�b%�ql�a�D[��ԋ��smh,q����?k� 0h,hVl�>�a:�BK#������<�R��v7k\��Q�+�#yQd���U���2��q��\���-�[��ᬋU7��H�ڀ;<�us�;3r�'��$�P����I 8
!�p^�ˬ�����6��U���"�`6N:Vs�}��:��ks�����u-�಑{8�Ū�.�F��v [�["�X?q��x6�f	V�'P��k|� v�ٰ� zk��1���xي8\�h ����r��l�䷞���1�rSM�]�l����`��z�2CW,'��I���;��ٯ��d� ����rW�06
�PQ����k����^�f�Q+��⋘�fq�#��*,����
Vx;�{	34�p�����b�n��3M�s`j8B��Y�-�o�,/�}+����[f�ּ���Z�w�[A�6zɗ�@5$a��:TD=_��d(R ���}��+`�\/�7ahzZ�����k����&8�C�;�����L���o������XfR5���	3��#�\tBlH1 �����+��'�'t[���3��i"0�b������+<=]������B1�x�rq^� ��Ċ�Ѩ]�a8^.a�#`ZV�]ek��Ţ�[�Y�]K�"y�
��݊(�Tŉ"�-X����4Bf�w� Ҹ�e5�U\�+~�mLG��1~�Ò���N D3����@"�`��|c�d��!�(S�qŃ[� �/uK�#�Sv�xH�njEn}�A�Z��c�P\�	�z>�y4i\�����PC{�IY#*�%h�ň!������	E(f���Dq��_���K���@�6�]Ě��9��Zжsz�gB�Ma�'��\'��0����f~}���"�j�Ж�~�l�e}h�#�����A1�ߴ&b�_��J�"(R9��HW�/�8Y{�K��ֆ0>����_��\e���>���,��=ys�����*���J�W̫�^!�ָ�=^�ט��6�?C��$�Pm6���1ֱ-��![��~�@L���BΜH	�3n嫁��6Mv��Y&��!J4��6�~ۭ������ȿ�:仿�yt�@DXw��z�mR�kAj�-V��ap���qK�Fܠ��@�Fn�|��w"���B6,�X�l,U�sT��gn
#����_�U\�p�Ba�Vl;[��z�v{�    �F��+�g@@�t#J�˸�&��r<�n����n��"�ʅ�С�ˊXxN��t����{��� .]�iO]�@Z/��׻����3�Bޗ9C3�9n��n��2��F58 �C8Ri�� :d�	���A�w�X#2�!h�hÄO�4^<���ׂ���7c+_v����dyǩ���)��x�3�m�	;|����n;|- ��,��g}=g;5�0�ك�;�>�x߰�bL������0FҚ+"b���Mv˂���m�I��
��|�%/զ���$	4�QÂ�͢L��{ne�Z<��7C�_[�8S�C�(9�V��¬B���:@`U��Q}t$��z3�� ���-}�]�{3�$N�F�+x����:o��~��@@�E|�.5��Os�ѷGR���S���i�߷�����FK� ,@6�L�|����[XT�:[4g�.?�O���7+���8�J������!?A���M�Aa8���ͣ�p��24߀I�5B�'�m����o��7���=�Y �^o�����zt�0%��R��=�JX(�JQ���hET��6���Ņ�A1f�����'`�74\.ٜ3���B����N&�����Y�`�}�5���F����ct�s�V!�fگ{N\e�9�Y
�����10,�>��	�/n��(Z��>�X97�9I�CV�-�C�A:�)J�q�?Mӄ�%|2� �Ob@u���퍀�m�W���k�Q����3���gO7l�*��� 6 g�Aκ�	�-�7>	-;C�l��=�|W�������9��c��Ĳr���I�Qym��i�Z>�-��M]��o"`���h;8e�l�֟�s�d�%����Cñ`�_��1
7&������m�ؖ�����*���Z_qA��EVͼq �x<QA��Ś�}�Yq �+�-�-X�^���1�o� �f0��G˥��,Sf�g=#�jط�6��`N2[n��M����u����1[S�F�N��@�!c�O�,m |4�b���c�|;PmU�Z��N�Z3_+����߯ۼkIh���>gőu������!!sظ�F��`��"[�οѪ��<�83D{���qM�=7k���"�#5�n!i4����X���ևɂJ�.�f��w����L�$�+��1 �[�+S1@��p�6�{���� ��Bo��)�������.��o&��"?y�W��O:o�]����3��N=6) ����7����*jI���B�%�_?̟�&�|>��=�K�ƭO~�Ko!����U�a ��^����}v��񧧻j�h��ZzT����l�.g��4���Unؖұ��������)�F�e���ՔZ4L����}� �:�EnO�D���_�7B�PS,��6` ��Ѱ辀��0��g7>���#7m�/g2���`g�� ���Dⴗ	��V;�������rڨo��gA����'ފ6D��ղ��T�h¯tX�����}7�36�b� �cE�9�Ϛ�+����,�뷿��^�lRZ�lS�m@B)E�g�Ն�.�O��JOЇ"��ɅB���ۡlN��)��fO3�
#�M�±��$!Z���Aq[�8"t��֌��T^��lDQF���h�5"����[�5�jW�F���Z��E-����	�t4U^�G����A�<={���է�>6���,���C�jѰ��7���Y�!��h����>K�&�����	��Y(��U��0�gEJvB�xw c�ș%��B|2�f�vY6�y~HI�7S���hR��=��b#z�����I.��Y2Ql�2\�{b�����1t�]����\� �;-�1Kև�J��i���rJ�%����$9�eML#�ya&�����hf��>�=N��-�3�l3v�[[nhu!g�k� �h��3?�_�����~� �q�.\Vz��>���e�ɾ�dy��w:ς�AԊ�=O���|f������>����A_��àΰ����NB����}���1�ƧQ�霞%��Dh���X�4��W���0�{,�:L��M<�0���@��2�7G"�i��������������F*À�񲟭�QO3��MfҬv�VG��"�M�2 ���<wJğ�W�� nVnp
�����P�\2@�d�!����_n4tg���~���G9ʯr�b�Y��*]�FV�m��>Ԭý�mx���A�YL�V�BD�u��p���3�{�A�l���-�Z�29K���x�A��$>��[D�6��ܪE��o���-�2�%�A�4�D5,q��ۿkX^i�xg�R��B%�h�1oÿ��~\����=�����͖��Fr�~��vH�u�:b��H��[���ֳ &r�B.����5Hl�DW]�6�|~2�(-Ii2.e]�s�"^j��������h�ϊ~����y�V���gOȔJ�62�Y/����lղ�`Z�!�R�vOpŤ�w�s~�X?`��w,3�F�8LD�W�f	y1�0K�i?�za|U��s \�0_>~.���e����C�z�V�%���r.�tW�h�ع���'�jD��dX���h�1V:�"���IP��ΤXX���B`Q�&|P�fdD�8��8���t؄�čUd���,�ڇe+�ݮ��n6W��n3֒����؂�G�f�eް��N�j�б~��k�Y\��;�?3��|�+�,4��s�K������/v8ܞK��j���F�!i+ފl�8�#��4Z�ж��۟��,<DY{N�9��;/���7�F-�9���ktQ{�K�K�`�6�ָ�Cf7���W�E�i�x�~������߇O���:�mlӑE��C� �����j����� <�i���6ø�A�]o�f����2l3ɠ�C:�u e�����L��ߪ=L�I�?�����
��xc6�ĆT1'�
gW?L�绝:����EF�2�S����[�rn�2�U�HӐ��� w��&wW� ����x.tgл-V �8���hZi�3�Vg�
�M�y DT�u�6�� �pҭ��U#֒9k��~IJ��`̺�.�� Ɩn�=�#��k�e��<�c>�Yb2;��L�'X�@h�,���o(�\ � �eH �%ʀ��pg�YCXC��MG��#�3�v��P+�lU�C	��36s�]�w���f$8�^�k��][3+jc��:�	0�����,�Z����h:�\�U�yUP��A���q���)��QX9�*خ��?8=̖h�zq\A/KNft4.�橃��<8wY���(3}[uZS����_,�{�������x�����&���`]h�V[{l�R�:���������.EB�Ӆ��w�ŅcN��i��#,?�雂O��F��է��)VU.�G��� <�j�8�$��}�$t��ݯd]V?��_�s<�q���l+�
Ϝ�0�\u 	`��}�39
�5�ul���K?�xM��;tj��؛m��DyT�����8Q�k:6b[>���>��V���:)��N
/U�,��8=��t�������;�g�!��s���V�'{J#z�x���:t�6��n���������ڏw�������k��F����&||�5��-ߝ��&l�6/�Y�mcڋ�o�j���4Sc7�m����OhF��6�
��~ً�q���qt���ɯ���$�ki�V��⠥ɴ6�֎�m�����c��M�s�?��\��	s��8��m2���!�#^�ߑ9�l���l�X���|Vfg��uD�ލW�B`M���~	���r�[��mD���g�bC�;�o�r�;;-�q�$�O�ke���+�����6X��k�������x��\[�U�v$��̀`��=3jL�s4���n0�p����%jϝY&�5�C�2B�:�0��e��Ύ�l�A �	 �q$9�;�С�a&�Z�    �X�
�>��䛚1ci~�ݜ�d�YwJ�к�[ �� ���-`A��Yqn!�-�����3�(�c`��m�!7�ֹU�Ht	��T2$����y��*@ӡР��!>|qJ{:b�ӏ�:��r&H��S�����?��p~u	��}_ �L�������:�H6��	;m��h��浦�um�Ѕ���b;���Tw�>�}L	�Z����H�Fl&C~��>M�p~a-<��Z���lpT����/t�ݻ��0��g����#�A�}}��z;���F�>��a^�g��L/���-��������%Y��E�`ʟ���ta�pr����O�L��'�o�!m>^�+o /؃C|��8��|L�DU��M�oT��u�%�Á/Z�t눰���:���o� ���jZ{�6��&�U_;Oɬy�V��BUX�k%&lӠdO5-x��,���z3/���|�}�����3e��V���"���UY�{�ϟlG�z,�PZ���)��ԩ�s�L��˯���[Ɩ9�lb8F�q����h�o=!7�m�8�{���aK��T�ގ�WS�g)Rhl����^�e�Tcg������5�Β�`��X�t���6�j^v$c�6����Z��-�t~»~g�:d㲝�vV�5 ���>��d��3�or�X��yĥ%�8N��!��h~q4��ey�P+j�t̗�V���~N@��]��ڣ�o! ��֨8-'����QMav��ߏ�z��	cM�Ub�S\��i���nG�g��_k��o����/��)e�3��1K���q3f8=����k	�?�J�a� ��t+��q�x�E'	:G�����3��(tg�Upw@��/�0rڒ�
"��-� �%:R��T��=(`-K�zp�j��qH�������]lND���
6ځ�����ѝ�w��{z�ڴ�ج���7lg9��F�ƞ�@A��2��X�q[�%�r	��U�������OBĐ�N$<T��M�8����6M���R�7�;}�L�v���K=3��u���o�q_��A/	5uU��ޱ�2��6��9��i�_$��~�f;�c4vmn>8��IK=�w��y�ʥc���\�`��I��;��1�bU	����!W�x~�֖z��z?߯r��Fkq�-��0�T�_XJ��>x�bn������>�5����ҿ����'[�%y�)v�3����a����.�R�:>Þ�����o�Tʆ�b9�͸�9��p��&8�.�i�C���8I�����l��z�Q8��r���Ş�h8@j���S�mk�V�e�Ej<��@��������?,�#|@��j#y��]��܁�`�W�����em��p�"�x��C��:0��NS��m@�o���L��Dt"��n�g�h'��7Nq�0؂IOJܠ�<lM�V�n,�N"N���^���s�ی��u"���g��<�s�f!^7���gc�X�ٝ��4Ձ��v��1��w��ʉ����֗Y�2�5q�5~�
�O-���!n�"��9������A��y�<���fUS1=���F��Ǽ�7�\�d����� |r���3�P8,��v��QM&k��A��䣐<��fɦ��ks�۾�� ��k��ĺLۧ,ȗ|�2�hz��m�p+���-|���e���B�;E:��W��<���1�r;l�u4��nu?J�:�z�q�=G�W���ԉ� �ڝ�h�ׁ61��s�j1YO���GHϝ�x�}��P�Z����
���C���f��?�xs��;�.�ؓ�̸.�x���zR[�=�Ժ�q]�Q{	9�ݭ^;�`�D�*�A.(�9qg�oɰ��M-����a0����~���*�X���4��V0?d�ԷހG1z�����ǡ7��K�}yb^����v@�����]���d�ǜ��X�ȱ�彧f�O�Q�m���^��$��t�h�
�-�=��z�sZ�c}뷧s0`����`'�|�}��GBQ>G�[��o���.��Kb#�|����<�l�ﭞ�{f���O�}����8��,V�P�퀩~��s�'�Z>@I�%3:�adO����/���������/�t���r���f���������=�������7�v
���#/��xqp��TC��H���N�0[��� 
�l}�_�ڊ�U��X������5���>qs������cUNstyjPZ�b�3w�_��N���:e���@�Uk�����U�gl�V6h���%;����1��X���d=.fHc�:���\|�(���쟚w�o ����Na��s�9�Z eG�[M���ǚW������{�y`Hc�S��ܾ7�:��Nd���n�xh�.���v����i �SF�ߩ���u��+N�b��"B|l����� ��L����]��
ȑ�"_8� 8�3�ye�Av'53�|s�NgU��U��&[ �_4��a���{ӭu���% e'���͑�����V��N�w�i����#��[η��a굆��ܣu�`'.�����E�Ga�H̶���D�O���=wW39�`4qY9Fg}�~���|�
k������@���F��2a�/9VwiMN@	�Eh�3v���FU�9#����2pX�� ���lbAjZ	��t�9�K��c���8�h5���WU��I!'�>![�c/�|r������B��ͬ��Pq��,���!e�|r�.F�I��p6�H�I@|�\�:FЎ�i������6GE
�-�~=����}�ᎌ�ke^�*+a@c[���ll:>�Sq�M?�o#�4��C��y�o�ط�k�)X��ڎ�2*`�팎F�n�ܫCy�	������8��7v݇#c�,��.Cc��v�b��|�?�twv�i����4��M�5���<\�M̳[����劊��,<�e�ޖs�T�4��Wp0؄DaZ0����W��"	7;[���r���1�c��e����D\��t�*��ͫ�(�����c������M�+��r�^�^��Tx���_s�IG�����X;�q�+͊[%�/��Z����C���{�zK��6s)?:�T~�j�e������3���M�����] ~N)Ւ�Ǯ�t�r��W�J��~,���#���>��Xxl#'0�yQ�/��=�L�>��.
s&�cM�gr>�Mj�
�Wp{p��d��Zޙ�
6��B@s'V������{q>��bM�����WfG'o=�Arw=��)� @U�l��8�쩿9/?��3ees�8��3x��;�˼��X/�s�ι�b��*���B獾c&�6(��#&:��js�8�Y?mr��0f-Y��<1<Mp�H�Tw�#X�^rl��H��֏�x�*��J�(���#�n|'{E3�ϏZHe\�hG
�~A�NL��?�4t��<E�]�|�s�so5�3ܧ���{w���RGO�i��	9qpv�s�8��6�k̗���cg��N=)'d��Nz�<d,�`,�.=�ˇ̏�'��=C?��<�+�rk���$�GIV�?�6��u/�W�|��:W�t�a�4���9Z����Ӱ�l�:G �P5L��������-�&,MD�� 7t�2@�x `�uT��zQ�y��lr$8:e���܉4�
�;���e�L!�'N�J��Ѐ�ي�x�[�1�,<��ލ��Z�e?;�ah+�x��[����o��b�+�yK��]?΅9��ݾ4�0/NIDa7��+�ix���)X=V��KK�_96k��������繳h&�|��YX�Pm�|j�}�Հ7 �+�/G~�������n����I�61�H��l�W�=7\�Y�0�'��������t��v�n:޾���b�?����r��̗ݴ0��q�Z贗��"�0A c��V#$�+��B���n+*xbx�C��cZmy�C���u¼���9Hq�󟍁w;d��_�'�(2�@����@�8��f�.�����w�	���u��8��)Î<|�CP�s�    ��6��30ۡ��=�J�����$H��d�~:��z���Ar7�A�-[w�F/N��v�=}+�~�1�36'i����P�����ڿ�>��,��R=Z*��zY�v!ޫ��w����q@�v{� &v��fS�x�8���Kr�c"��~����?G�m��9���:�?�ztξ�s�,Pz]B�<�y�I��l���V};���;ZZvM�����G^�8���稫�x\h�c����L<X���ʁ�v�hV�,���w�l���v8�>8���;��2��e�"��ӵ�}���q ��:)Ƕ}���=?���*Fμx?�6&�ޞ�����N].�׭��7o�kz�t�D���j�ٌB�f����8i�X�	7�bC;ɹ��<5!��Bݶ�t0[���נ��F/7��g�����[�g�r<& �eB�jtbĝ։�������+٤Ew�}w�.6�m%���#N�%������<�<���q1�{�l{�9�  �,�|X�L�o�q�����2���|�Y���&x�Z=z�j���_��7X)d��]������������ȇlC�X4��_�V�M���g���Z��Z�Ts�����<��Ur`?Ⱦ3N�+p�d��./?��_G�����V�z>Po���b6�z�����&��"�7z`�q���E��?S:c{{uڴ��8��퇜�b���ۂ���m�:⋳���ഫ`DO��n`Z�1(����dD�q��
zC�|������D�,ʹ-�
`�DiN�h�l�0�z���|����#���B���w��Ӯ��T�l�.&��dm�I�}N��6��I�Q��n#��,(�e�!�wg�ҋ� p����=N�1�$��k�m���T�,�dP��������u�/<���.��ǉ8�[Mc�zY�� �|����c��<��T���8�E��N��0Yaps�a�����9�T^Q�&�!���N4h�'�6@T�Q�v)8ƹ�@z�J�I��E�[�A�9)<�k�����9��(��M7�Ezp[��������?���횢�q���w��>;R���C=�]���^Xp54;+��P�t����~Bk#J�5'S %��M�;��
|�1��T�匞�ˈT���(����t�@Z'p'����,kӜ8�C��ͱON�[�]�	�9:��s��U_���ė[�k���&P�(����r��u`�P0f��8�f�O�0�i��8�@�.�+��d�\2*h.���@y� �����v�&����y
Ù#N�͂Q�F8�v�K�%@�YX�e��o-v���akE�79�	Ӝ��,��KpK�rw�ѱ��vV�Y��ο'f'���3�gw�I�6�B�����9�wi]����O�>���w;R�~��!1���φs�@�d޽i'���z�(��n� w���C� ��U�X[/�A�Mg�Ƽ�kc�T��~ʑCX�о,'��A^�A6]�eO��+��r;h�p���ݵ��չq}V^~�Y��ν��C�1n��!���/x��8u'�[-��5F:�_�t����u]��b�~3�L�� �	���NB�K"+D����� v'�G�XpX��:��[��xI�d杴�����^ٸ����
.�s�`����gvʛZ�SOrsc�g��oì1�ϱ�u)T훊 /�����OOr݆�\�u)� wc��3�-�w �q�ҷap�~J{l@D�3ט�:��[��,H�S����\uQ#�ޢ)�l��A��eq����D�x𶜷+�H���������z�iF�̵iH~a��+1�{w�����H,��db�A����.��K�߱����譆l����b����I���8Y๽>�pgp=5t�F�|��������ۙ�o_�x{*!���m���Ƕn�I��q���\*N@]��ŰVX�1��b,�ۥ�_��q�	��Q�T�vk��MF����������D�K�S�0��������� 2��l�T�Em�q�����/#��F�����H���ra(�fR����s���,p�wm��Gjܓ��w���?g@ᄝT���Q��nbA�֌>�_�F����ED�u��gQ�h�nC�[��49�bbE-����]����q��+H_�*Mw :+��?�u+#������!t��_��nw��#
5ؗ�����rLpa�hm�I���m#&��c��Fe�_�o/Gw�#����*�X�~i;��X�F�d���t=79�}Kşc肋���3��%'�l�K�]	�;��Fw�Uy����u9����Q߰��1\F����XI��KJFcR{���qI��s\$
���8h# pķ�)�PL��5U��ϸ���5�;��)Φ �/�b5���X���ל0.�
�RL��j{k�N� ����x�?Q�l��Mr�ߴvG`������
�٨��	9�7�"�-�0=0���q7�"��3 �8������C LA�]��۽�{��!���6��J��g�m����w��ldqN�O��H�$m����W�� �X��p-y���y�7NC���v&CpP*sK�,B���I���������h}�S��s=ޭ�-Xr-&��u�\��DB�&-Qx����+U1�+��p*I��h����
�ݫ��Nx�������Ҿ�tW��7�|Z긞j�����b���i}�л�R��wp "���99�s�3[]?n>\���^���|�$L˥���J��B�)�ƃ���F���sqГ��m5��9���x3>4�ғ#h�V?���}gg�����;�.�w�����nNL�Z�8����%^��k�����_��SD[pw��N%ھb��Ѣ��l����`���f�J�%���X�s��������K_����H�À�&{P�Kw|����K ��?��.��N_N���O��8��J���r���qz�Y�D�|������4� kk���������:�������? *��%Ͼ}�����^;ܻ�e�;���<l!�NZ�a��j�
��n����'��9b{H��zq�|q�����2�Z��@F|��X		'��1S�:�;z��FZ0�÷&}�G��Zo��g�o�nP(
�J"�E �>+N6^m��.��h_5���ZaѥM�����aǩ���v��sS�6Ԣ�t��-=����<��\@�wF�f3� \]���m<W�Cد��V�r�[Zuo���
��2w�����/5.(�w'&����Q��81+<��4V�st���:�yD's�a;R�CUʝd�7~�q�~8�\����j/���7����WQ��m�p�P��}�a>�>��"]Xe�HJ�筹rrOl���]�w��o�C_�x޶VdG��ޣ���r!��R��)Z��,g-9/Ǖ'7�y�+!�v'�Z*���h˭-��\/��V
 ����;�*D�m�Y��E�K��xO�l:��u?�ݒ#j�Nگ.���G��P�
E����~��뭓���B�WVa��wH]�,�ޏ],��	�5؎q�����UDU:��K-�v	��N����Yg��tKn�u���pd^+�f5�y�Ln=�\v�ꝾZ"�Qq?D3��6_��<z�!oeo��@��ɲp��� dEjqG�98F��c�O�#**x1�X��j��ߌ��W�WW�;�D�K�S}���r���{]�B|!)!�C>܎��m��v�]q���l�c�����KK�N��9-c� �Û����-�׫ܢ��V��N3��'o/ȣAO�z#�X��ۻ��;��Ϊ@�-��R�V�ﴰ.�bE��x:��nk<ϯ�n��s'�dc�HM��=�6�d���&�
D
�4�ivE�7�a1���
06�����s�h�n��V�B�������WS�3����p����8��;�Z[�����Ef]L�-cxbWK�s�kO���|�� �J��+,�Mطԍ��͢h�\�Ky�M���~,b}���8�ZqJ�G�c�<B��F�d�b'�    �������n;�]YЌ(��I�u�ۿ�4�<�K�؍���
�M��C:1l�לȫ�8�͵��m ���}�+T���iDǇ���n�n�ƭN�����ZN�[�Ʒ�Ѣ��y��`�۰�g�f�p�sX@H�m h/�.%�����3C*D��)ñ<":u��
�Q�BֵaݱX�s8�Ƀ��m�A�6�ȂV���#�5PG5�閳���F�)b<w��C:��}���_ǴH|~�燿��;]���������Y�!/����M��|��Q.'��|/�f���+.�8i��=�m��[��K�.~5;�>��ҝ;�Xs�W�.��	��(-�r���w�Ś �s'���nmus��Mn=s4���]�<&w�6��1�V��- �pR�Q���sn��Q{+���`��bǷcU~{���7�n�oC���7IqCٝ+���vY���n��D��@ų
ȥ�N��҈K~/0���.�p� w|2(븳'�f���d�z7����9	�qW��:���(���v�+ՠ������q�ߓ��ev�9���vA[�q�F4���T�4bh��߂������+�?:��_[uq�;�yyN�2��Iv�7����l�'����.V����8��Ux!`�R7������\e}�=ps�� ���2���&౺h<̈́�+$pV��^G�:8Tg�o��ך�7g����پY�P�(�����G��P�E�iAٝ���Pf��� I���NX���������v�ϧe���ܼl��c�
L���䲣�ᰎ_��p��k�Lp���2�V݋��WC3ujօY����R��y�=���e��
�[���tw�y8^z:��v>�.a:��ֹ�w��ݐ�1�*�[��}6&`	����~�2H�p�$s�w��h� � ��� ��7����xZ�7h��iPi��B����c�өg�֍X1i5��48���b��f)�y�A�m���l����41{1�����6,ĩ������ɘ��0^7]ܭ*�:��0���/�"�T���1�h�ʭd�n�E�9@�8��Ŕ`M�l ҂��e���w�C����n������jD��N�ψ����$�f��}.�*���}-2;n�>�;��ݽ�(��د�:��Dr�����״_]y�Nµ�њ'5c �`��\p� Ì�7Ɖv3��sT���v ����ZT׾�Bu���Î�Af�om�m{�4��{�n�f�Ű��D�?f�s������؎g��
B�Ӗ9��u�	[�Ab��t��-��$�$�9̼��n�����ZX�>��I���ݷs�M������s�ެ4t��q�ΰԆ����8�Ջy��35����`��p(�-ި����\�R�sνN���[�,����y ��ҽ�io��p�l�1���5/��������k��6��$�2܉s��҄��� p`�~g_Ќ�����6�͡�(۶��tL�66}�'�~!7D�p�r�ۅ�օ=_��T��Z�0^��MuY����-F���W��&��E�1�t�kq���ζ}����5M����?6���_#���= ޻Q�ٚ� _PA�]��p�'���Yd�<���m����c޼k	<N}8�Ͱj�1\�c`���g2`G�G�8�Xe��j�yF��,kʎ�vs�os7�l�E�Qy[���\�~��"]�mq���bn��UC!�c��n�XN$/7�ߣS��s���AU�(v�a~\��&z���o{��'��S��ύ�w
X�o�!Kf�2��[���oO�90� SQ܂;�Yn��e��M��i>_�v��[��>��0(�a�8�C���jv�sP].�9Y�"Cg�`m_��`݊��:��=:�kE��ښ�5�1��J�hG#=�/.=������!c�T�0FԷna��Ž��\m(;s��!�?6Ǡ�@E�L��&��Muj�ٮ�|��������%�!b�Q�7WW��	;��Z��S
v^����L�`�|������ d�9n�ߞ ���0X�}��Vϸ��A�5�p
�룝�oM�1��r>G�T]Tr����y}�����E8�C�o�L_ċ�d���c$/6�5c'ּt�3�w�Lyۙ�l�l�s��xKU?K`�FI�t�L�y��3r���E�0���H���s�[�����`��yt+W輏u��nk"���M����,ESӭױ�í7w�G��(�r������~l���1�7� �'6C~�i:�����V �2ˆ-��Ƶl�?����,v�Yn�G�CW�<�/cK�=Ip?���
��q��!@��ř���NP̘{0��7�|��je��{2���X��c/[�ק����0�;.����1���9[�[��v4p��go����s���:f�7���u��4wL���"�-F�q薥�b%���^�X�m75��M�}1F'N�7�k!��5�3��U(o�R�_2h}�F?�&@� �aٗ����Z��(֪��槏Bg�"�\��d3G1�����j����EϣY����ዷ�^{"��
�ו/�V�{�q�_)���4[��6�+���`����P��D�d�)�!�3�?<�;U6<F�f�4��Z���ur�Y��J�0#[0�����|3��i���k@0"F��~`R5 I�?�fI��,B>�
���ǹ�u'I������Y���`�؋]t���C��C,��$�[Y��L��8ё-<���^:YH+��v8I�ïf��tew�c���vj.+��a��,�񬌛�'�ݪ���;�{�Vo�is��{\����T��E���j�	��jb�Q� ���j<�iր�']��-_��I�W��D�q?�ˎn�xڑ���@��y���A����������;ɮ�jw�炝�?9��jz�+Ġ�[��*���m@��>�!̼o�h���(p��7��1��`NW"��������`w�[ޛ�>�+nX8�\^�6����/oۙ8NO��r�S��3�����q�*H�g�ʶ�y��l��p�Ŭ]h����l"��$̀"��q�͒��F��H��e�N2�P�$�ӓ�	��y|�m�3�h9l�uD_З�Z��tT�P�%��m�ˉ�&|@��P���,jC:��3<�Ib�u��#�+��R�q�5k�܁�Ȝ��)j�0��x����G7�}8�s����՞;�첖d�,�l0����4�͈��1��'�	r��k�&��Y�h6���� N�.C=n�r�3(�&x���c0>�jơ�N��Wzw�+�<eR=��[/�D������ �{p"�ò�^w����3%�؇�ps �y�!�6��@v�;�H[�1�!\�mݴa t��a��]��;vn��r���-ۗ�`�<�[��� ��sWv�r4�t����ʶ8fm�5olXy4O�摚���!�ǨfT��t^%qٞ�S���(%0�	��6 c�b�+r<hv���zY;l�F��%/����
g���������)��{#�򈿦#۠����@׸� v����@0��c�Ӝ^�w�+�o���|]���۰y0D�Uڔ�+���k�~{wȩ):���3	�(����;Sz_P�T����-W��8���(8��U둲�2aR2LIP~����Ӄ�Z�����M��6`@�d](����j������+ǓFJ�$��O(�JV�]��t	R������d���o�ebʪ���C��^Vx#h�+`�q�kJh#��H�8� g��X"{��A�6q	70o �-�&���A�31Y��Ka�v`H��9���q$���}��I
���`�\复ˀ/���M����篙��n�˜�5+���V@�!*+�Z��5�9����I<�Ƒ\9
$��3���.��N�6�*�n��b��z;mT>�������@2;��;�ra]��lM4�v.��5�|�����'2������ɉ��?[�D��X�� ����>.���Eڼ_�M�#/f�h�߰�#QR*9G��7�    �
�2�|��.n�����Z"���s�N�P�؃ck}5��w6�(�"�>��=(�d��@� z���\4W�(�?��D�d�ix�H���4��Ұs�g����m�ӂu�w?�R9��.F��hz��<���R�%�.�g� 0xk�疈�������l�P	kx�mه��%����JNw�TQ�܌Ȏ� P��B7����<�iM�:�tsS�T�^z|V"dc�^���[/�%Ivjt�'}�d��A~˝��d�G2�^�GK|�]l�c#w�|mò�c���q���י�]5{%u�ݾ������o�����F���#�V���e
_� q�����s��.����nK1)N.Dy����(�F#,7��n�j�oJ�<G}1LOMI��eұ�p:���6:���9��V.r�<HɐX����n��<ЋZ�{u7�V�y#��ܭ�:V���&��u3:I��*�Y����5�ScNW�ͮ��>��(���EY�_ʭS4i`/{D"�����,�&��
��\��w{~[����Lˊ�잢w���),�ͽؒ�kA��R���5D�:�h���)s�@��qz�jb���4$�Ngg��`�!0;�L#a��qT�@z�b͗�Ĺ�H?�҅�K�k>�������C�y��hR#psA��L��3�x�3ɦ�>zз
��`�Xf��ZCi��\(KF��d7���s�r�saf.w[�$�6��6	���Y�K��n[�jԛ���EW\=.�g�S�c�����}6=֑4yOh͎�+�pm�k�K�:IǚH@M�2�����|�ӻ��0��F�jO":.�le�b�d0�>�<)�+�Ǜ�f�p�����n���:�4��S9��H��!K�:��Zk�,q����*��kD�$c����<?�m/�˫�C4������������*�&���W7�l�Y�SIF{��D�0)��io"u��>��x��Xt��g�r������H
��F�ֱ@��?h꬞�d���7I��0�LN�3<��_��O��pb�N3 �C�IV=w"	�lhlS�ׅm�D /\u"��W��OJ����<���.?A�^�TJ2K�gg=G�37=� ���c,$���Tw��I��D1~�Yq��RvxK�evbD4t(��y��sRƑ�1%�"/��'̕E��������<���_�-��"�N*�<���~��4Z�0�ħl
�H[�b1���!�x-Iۚs�wZX]���?�Ӆ_�}߁PR�c�'�U���Vܔ�x��t���&0�e�9�#�rf>�`����wg�r}���"C"r_���M3NV�����9���*�{�'b}�G� �FL@ ���b��lx|���w�_A.=����mDu�'V`�GP�4��_(��yu�i�������ٗ�&�ז{ʅwB-D ƌy�df8O/pL��<ҚL��[��9���(�w�_�-�wC��1 �S��c��w\7��	q�Wp�@��#��r��i�c1���gXm�	��tͮ&ө!��������C��9����m���e��=��-�':������;�ƬG`}�c��k���i�Jm4�jpԈ�	\+�ϟh��m�B��C.�pS
���n�7�F����	6�sS�;�@I���t�1b,������5'�1��فѯi+� �`���V�����\9 b�+�ћ�	#�N��A��~1�x;T���fڀ�H�?����;�l	g$�;5����\1-}(����TE���+�r�{#o�=*Ƞ]w�?
�	MŎ�U\Q����I:����-��KP�j��>t�5�\�A&h��B�������j�ݻ�U�9���H.�;���~N���lK�P�+$�#���w1z�KD<�jHf)�Ik�����)F^/"��J��]�^�֔��eH����Gd(J�E������'s���Ԣ�.X)&fy�A�.���.���ۀ��g.�H�"������s��|�T=ʨw��A�wg�@B'|h�>o��iI�J�h�)I��8�h�]������o�I"�ʹ��٤�!>F7Ѧ�e&®�0S����L�)���7s磒��h	m�R����%b�ޙؙ�˕K�Ő�D���c���h�m���JuY��"+��������ڰM�ZJs����b�%E.��L<�B[$����I���Fg>Y��d���s�<(�W&K�gB�S���t��*XAI
P��A翡�3�ϕ���q�ŗ�(���&1�|-a����V�ӕJ����m��m�f�z _��_nC�VmꫢQ�u���䄝`n=z(��w�üj<^8#o띴Ɏ�1/N�݉V����0��y���<�D~�->F�C�;�*}cY����Y�_1�.NWhl���4.ˀ�2�g�tV�k������-*�|�S���w����W?�,��R���E�4���2�o����c F�hxv���������jX4?-��u��Id��_�
T�h/��D��ÈQ��D&����~�hʪ�S��Sc���X>rC�{t�x�~L`gM?��g	x�W5v�;��|� l��6�:�>f��/��u���<Ց��O�^�Ǜ*�Uj�U���Z�=�2�2�I���OD����N�Κi��̢Ǖ8����&;�`�&v�9K��,qS��8�3�:0I���$�]�ľᮏ�2�9{U����%;AM!�����JN5`�)� .@cEO������>���V��Gx !��+̔���?�x�A��6��&� ��B��{��Xm(}b�e�:�0�V���|H��eORy��&���q§�:�7ˣ7)�Tc-V�;r�7�֧���� ��s�f�8wZ?G���� ��<�������Уٷ�k
�ݟ%���m{�{��w��o���Խ�k��:��O�ɖ�����ۯ"d��d��ûnE6�A_���Tt�)�6�)h�'7�G
��lq��]�`l]�@�iV�6{qo.���Mꆓ�V��B� `��c�o��k	k����M`���K�������Ϳ�=Q)'��7�N<�������y,��}���ܪ���;�J�o��]��������}��c@3V��w�B;�G8�.S��فRHjkj�zp�Փ�a�{���ډ�	��R��c�����@���}q�;L6���Ny��{�E�Z"�]]�ܰ��Ł�v��jΟPF#u��B
�+�C_����PT�;��].�6��K1���ǖ�4w�5����3%)�0�&�Tf����q�$��BJ +�Gj�3�d#��s&v����wI���{�V|�)�"DN�����żG�v��%����ׯ)aؙ?ʺ�Kڲ&�[p�i5(�m�˳nߤ��n)�Pu��j�q�Bœ�V	z�Fa����mgʌf�����<���V�+�i+��2��m��\�̗H�{Y���'�}}�t�}�"B����s!�%����n�uѬLQ��Ђ|βT�D�+9��mPe��� Q�΁�6���׃�~�؛c�k����y��[��2�1�����9�h��M�9^)}�tZr`N~�=3]}�5��8�]&�,� ���� �#����/�I<�͢�ޅO��}u枙�٫��^�VdQ��D���ͅ��J;�#h��?�S��ջI}�^����'��V[f%��:��
�ћ�&ò�lF�y��4��-�#w��~>Zn���2�3I�]A�;�l#<{�:Q�i2�����������3��s��p�8��!��ޱ������˱�H��y�!w����9��:�'��y��Eݱ�dX�rzf&<ʹi$�Yf?�ǲ�8��jN�CGr�lg�G��v+H �c��~�|K�9����O)��{aS���	�ZG�a΅�j�<�TbiM(}�	�Rćd�����	�7{�4G,� _G~3S~��X�zy�m�C0�S�K� ���}�0���{��-8� +��w	��|�أ$%V�lm�MRjC����K���X[1O�<�C��wX�9%u���t+�f!쮞��Q͋��[r�C�����#�բ{��m(d�i�T�� 	��;NOmҡ    _���\Kp\�u�: �}� L$ǹOL����h���~��By�,���R$t �w����$?�IF�7yR�O��F��+uӭ��{�h��a�=E�b+s�^�;7���l��j0��L���vJ�Gx2NK�o%��z���o�lr�v�ɞH��k������,�rG��M�t'�B�.Pv-�ד��QR�	�B����>)��ZB��\�2�%���̔��4��#L�\�3-v�W��TRKŲ	L]-x�m���(�t�u�E�>v�ܱ��ڰƔ��s��ҝ6?ͥ��`�Sz'�.ݔ@��+���^��O3k~�-������[-r.%?�qlfSN�.s�@�Kx��4Z��׹�w/�� ��Gb6�e����>����c�t��~�M_dM$��iP��v�Uu%���X��fs^nϱT-������}�5�7���5��ۿYJJfͻ�؁k�.ݦ��Qߔ����|t�ܧ�Y��U�f���ݖ<� .�{B��<����9&	���w��7J�����E��IC�+�`�Lg���{s��1mu�9��u+�YTj'դ�(߆-o��#�v��*#����>�h��\5	��ByM����,h���B�Kfn4HMvl'�@14����UK`�͹�u�n��nF�h�ګ=U�wϵ�i�����.��je��=�\.���,���-�j�S}�J�c;	���҉�Ò����4�s�Z�3��<̦g��J���K�(�H-�[gş��,_�˜�<���B�$�t���(x�a��0�������� Ξ�<��N�:��	�p�`ވ��3郖��qa�3�J_��E�_��ܦi6�MŘ���N�Տ6#�k<h`yy7�~�yt�V0�|Ձ@.没J=�[:؉ib�$yL����L��'������l�+e'�+��S �I�~K�d�=caqRiW��s�X��6�K�� _p��3T�^:h?�z&x$�5�xz�:3�V=j�;y7��j�sj�LW~�`Gk�f�T�{�K}���s�sl�AI�=���X�B�L8�gf���/�#�υ̿\�i�����>G�a��������j��	�DD�C��9����8y���s! &F�Y����=/��;x�ȝv������p>���=.Rd	��j���i���F֋9����&F^[-T�+,4�{j�y���-�X���l�#�J���5��邻��!����z:k	s�TO�:U�^���AB�ԛ��K�VՖcI��)�q��w2�$%n$��[Hyl��62u ��`鞧3[�[�N��U5�u��x���ꚜ�sŏ)w��1g��su/٩w�֬�N�eu�fK�\ק/NDj��� ��K�!�m�M��޺� /�2�iG��I�>Z5l[n���r���dT��c/�Á�, 12@�M��g��zYm�e�ڥ���`5�9"���A�bv_ x�$4�lF�]���ۖ�����8���c�;�],U�;�g�2{�֔�}̬ӎQgL'�F|׹IT��ǰ+~�3%��NZV�/���gy��L�ey�B�AX��Mɴ����E����띵��hh�j'��Q�?��
��d	J{�V�/�St5\���[ٔЛ^��D�w��8.���t��8PP��A ���=a�R�gtܗ��L�}	d���U���ڀ�I��˖�M��ֿs��z��I�s�t`����k9��OY�����X�ۃ s\��W�L�o{�ڑ�����	cٞ����p4�T,"��C��l�M8�&!�p��ͥf)֏򪖶��4�?q� �%XmF��t��R��YF$F�\Љ���5l�N�A.��v/��o�NT��հņ򺑽�G�IPT%E�I��=���I��O�a��g�&�s;�uݖ�: &@�U1�A.]
�1�4p���$?S�H�:�ʚW%�S�6<_w�f0���>;����J̭m1�Kt[�"���✓.Ѯ�#i� �O�4O�mf���sXD�%�q� ��L�Xb����nb���N�.�
���I{ϖwK��%�ݚ��4��?�;��G4�1�����.���2�3k���.��V���0ݦ9m1��+J��1 ��U[��Ŏ���)W�������RJ\*�-�Ew�^,����Trۈ$���r�smHoCYF�-i˪�M�o�U�c\�t�B&���xs�U�wZJ�u����H�5�d���J�z���<h��)��y$Q�_�]��K�ͫK���]R{����Ԯ�ei�߈��z�y�%���	J�S}�Ŵo�h'Y���g8��L��6�T�P�K}�e���8�`��Qs�%	�+�T-�K!v�N:,w� {�r�u�0p�Xx�X�n���"o{ rng�E��'"�!7�n���^x�C���=�ȈE��ұ�;'�u~�iᵠa��x�&~�������ZWc{ו��}\O��Iy�41S4�N�L�r���k��a~�3u��b>���HQ=)O0�#����;�ԲN���e�%W�~�w�;�T`+k���S�:�|<����ܩ�z~�&l���,�z+È1�՟J���ٺM�
���8�v���I��L:Ѡ�/Ge�1j_"����E�+�1 ֤��l%��Lښ�;��J]����2H����}�5�s��}s���Ɣ?��IW��H�6�����E����s�U���9V�s?6���|F�T�#�؂%r�נ�����V��ɶ�;݂�(�|:��p͕n����`k�9�*'��n�@���U���$��ܗ���7�ayj�8I�@4�D�)o@&���ݏ+o�l��ռ�1���ׯ�j�@ޝ\��jֻI1������y�P%k�����Le�C�C�An+͡�Y �v4Y���}Q�Az[&�D%�6$��r���^N�h���\��q���}��p��K�������+���tV)�P20�,E� �Q�r@��vՖq����`p�\k���]/'E��XkI�G56�����rt(�PaK�]2l�fI���hV%�y���@�s2������?�ٛ�k����Fv����U�]�|�A�-0��0hv�I���U��S�0��N@,�gX]p2�S9,��q[��ڔ[��Y�މ�adR���Dj��'2E/���t?�`>J��O������S��vs�Lk����+4q�u]ӣ��w�}��:ud�^}j�[�_�PzI'��_�U���p�I�
�〄����\U^g�ϸ��8$!.��a5S�+'^���K~	��NFna����#��QN���t������k�"K�}�I�=� NGD�{I{`�XsS����N����i�LL_�:�`��&��O�]\��&�z����/��޸nZ,���eٚ����T�T��o�Kap@��eU����O����Dl��\�1x+��;�,�ߙ�P�;%�L	&�e�&B*wW�y����$�;1u�rg��C�!~� ��Y��'�=�cI�/R����从Uy�q��9�]̣:'�٬��!@y�\H�Ӕ��\]๼��N�XQ�z3����џ�tv�p�ڥ�	\:R��C8�S)�#O3E�ז��.�q.��x��Z���:&Ԟ*U9Д����.�ň��`bS�Z|Jp+m!ӎ����3�Ŕsc�`����J����nZ�����̉zB��S9�ܕ�w�r��3ST]�0I�'�oP��\�a�k0o�[�����!Fk�����S���dt�S8<T$R-����b�U��w�|�T��N	/��n��ĝc�Q��Uz�V�"�$ݥh���ªN��٭��ڨ+.�nl��;'
�Ci���%%3w�٭�1���ot4;E���x�1P�NN|RO~F�:/��t���:�I�F�9En�D��^5u���A���13����"D횑�њz3�8�y��S���׬�TL��S�=�UUm�sRA0��k[�d�1�~rp�rXh�l���]���A�.k� ���~.�h�z���j��%\J�`���y��~CNZ���^��Z,��&��P9�}��$f�x    �Qj�Z�>۝��u�ʨ@@
�%�<��̏�m�3�b��:�7�T5�ę(r��CTيT[��6(���D%��V�yIU3R�O��t�E
���f��ib���ˤ7v����NL�j% ���;�Q�n�)��z�)��V$
��(Z̔�΅���,gtI�:�Wc���Q"I��z���R�$��3�2���-Ͷ����O�Byf�:u�dt���0Lwr���3�J�Ο��=N"�lW�ıV햲��sF�������p�p�	��Ź 7�O�@ı�n��2$��C5��F���>W�Qjlv�m���cy�O�'_ �Ob)0��#{�;¦�x0t>8�A�������@t��Xc��q9G�EA�����S9;��싔�q{B敼,2����S�ts�F��OFx��;�(�ؓk�2uxG�4��,O����Y��SOa��µ��K����u{�ݮ�%*��$%�����x�S��TC:��|o��)�������h~K=F!�}�ZXW�6{��\����B�6y��+��`��?�[yS9U�b9��J��9~���7�+-ZfC�>����{�{�L�4�z�t'��{���D�S�*LR�lO7yў��m!���rּ�B�_�ȼU��96��P^�9%��luN�vQ�޼Z�wwd���Zʹ�8W&E��.�F8	�'���������?߭I�=97�+�ZB��Z��FF��M�{g�@r2�+2�)-���I�z����J���'��X�籤��Y�Ӂ�r�L��{Q81M��'���x%��"@hy�!am�ֆmW�䓞�}Lz-9�GQ��\�D�ԗ	��!�q�2M�+��V���4yt'��<v�����V㡨EN"?c�_�m���3�;K�Ee��ajpغ�O��S��ЎA�[iD��/�����Jt��q@^�ݱɽ��dw"vU>k�-em�a��2�IF'q=!����%�0��唙,�v�k]a�s	�k�N�S���)��� ҺU~lo��'E�7ք��brV����A�'e�fSNg�����ٗ9/���{�o4_���ǖo�����FZ������s��r�Vh�t|i5R���0�l��{"�����ٴ&t$E��OZS�Y;�G�]�ǼGV|�E��	q0�bt��L/�'A�¬}�{fδY�&&�-��}����9��>��Yc��9%)Wǜ�6Y�F��9)�,�w p��|�T앿�v���ɩ�^�֗�������v�ld&�H3�%1Ӷ�\[�y��c�xaFn���Z.SS��a����G�%�h���k�b0�,	(������=�I�x1��_S� ��^s�L�È$Gj��À�����ty�[�189w/_�4�hA{d���'�]�è��L�(�l�)�R�����
ܬ��+�	��s���s4Z�
3�!�}�gn�<�k,Љ~�<�}LO'�D�)��m�aG��(xlc+�e�4V�|��<�LpmB�>u��D�7�%����'ه&QJ]��n ��Z��{"���|��B��	Pm�6$��F+���̡�;��̯&��|�v�g��;f�+$�'��OIF|0\���l$`F�.�`àML��h %��)~���j�P�(�[�ӄC6~������\�d�|�.O��a�;��N�= `(Ձ���I��_`@�e�sD:ň�C��8�o�?��M)DV�X�2�NW�C�s�Dp���5,A�c�E�7ULrB>g��e���S��Z����u�<�SR��W�.Ͱ��\N�R�����y��1?�¶ȉ����>e0"f�*�u{���ϟ7�c��Ṣ3C�RH�{	E��ɽ��O��ҟ{��9�or�fY�4`N�A�C�L+��x���w�Sr��	(=�@>�j[�\5�۝��u���w��mPy���������H�=�N�����HJ���FJ9߉lK�6N�N��u+�x9q��{Ύ�[`h`�a���v%|\�~����a�
ۚY���3.��-z/��,��`ǩ#���O	v	c�9--��
�d�έ_�	�c繀{�ХF@�JՊ՞@�t{Qg9'}��H�:Jk4ecW֑(�g;�Vr̵�G��> S�NL�e£̜�S����k��W���Ȗ�t��!Y���u�-[�z��/���ʷ�d>�Q�2�&[��M}ܭi�J[:5��C��z�ݽ������̱�FJ~�8���Rl��e�X27;b�Tcyd��OF�	���}
�3�=���s��yJ�ZJy���'��ĥ�v�v��Oz[Ւ9����-5��{g�5T
JK��qГ���Z��I�[��)h�a��R�j�9�Qw�z�Y;8Cj�[U�l���g0� k�ysT1�Τ������䊣Xu׻�j7��S5���#e�U��:QE�@�ܽ�[=�*��C$eq��f/�`�`�uK�X)��0�|�w��)m��d�a�g�\E&�݆�O��x0%o��h�A�ݘ��0�J,�]Rw�#'�<�ܓԦ��'�� ΉU���S�l݂6��\��j2?��$7&B4�|��[�4�Ľ��|~�"�V�gw2�LM�=��Q�Þ�G�����Te�����#y�%
E�x��<6����qi���H�ຆ��Ҥ-�S��A֬<w8��������[�̛W��D�o��_���>IǰT:Q���3�������S&����MOn,�%5��M�2*�O��"�^���3 �-�ѧi�qߌ �K���WA��BV�z[�I�
���V.Sb��2F����ښ�EV
Fj�(��,y����,���u'!�uf���vYVZ��q:s+N�n�x��&�98��	V���q�>�T������`7S	J��/�ܟ�N��g=�� �-��Zx9�4[K����++Bb� �r����ּe3W$Xq"A�O�����k����]��Är��H&`h�PR�W���s4U7%O"�@"힀`�
�����b4�8�y��Kt��<1cȫ7u�	�����ߠD3u�k3-q��b`9([^L)����u����|v6�m��?S�����3��"T_�/9����j.��'�r*�m�\T�P7���u�g��\��%�4RQ&�����V����n-Z_�����:�yS9���W�:���l�kY>n5JJٵ�o|��rW�Q�����ə�X���4�-&uu��$Nneޓ�	e,7h����J_uZ7�-|s�`��D,O�� ���rZ�%��DT�(d�)�q2�i����%�T��Ie-�B����]�:���ضd��8�̑���D���x����w���L��h�!�m���:�^�'I���V���0�N�'VA�DDm}_�t��R2d��֊kk��Շؙ�d7�Ad6��7�Xi�P�q2��#����(��Px��(N��L1�lV<%z$���~�����H��̀s �+s'��{g`��|��t�S�	Ԇ�bCW?�ճ�u:���~#��R�X�oz�j�%��"q�:.Ҧg�fޠ��*p�k�"�{��}��q1X���qy����GP��J6�=��5�(X����pvwL�M���J#h��Xy<���:��ݵ�����r`�W70'	2�oy`�T��/rA���d�("ON� �`n����\9>M��v���+�9�^K��]��Ƹ]��o���#��;=�
E�T)7q��^��JC�D��X)M�������\\�Z����3@�݄v-W����j��<��/�QHj ]�6�:^-���*��""�h��,������(��@%�k����߉�����g+����B&i��S���XKbȉ�s��'�%���$��~Ӣ]2avPeIy�-˥�1(�X�'��*AqI;��4���n#�`��b
�K;*�n�:Μ�k�>��qlIk�6Z\�a��MSt/%� ��C+#i��=7e0#L~�	s@?$�(Jvg%������P7��&G�aM��E&�m*�L<��ƶ�N
b&�4�K�Ҟ|�~����5@�A��`n*��7�9l]���fc�!�_�+��Np��~��	[l>۞#v��    NP�)U>�KnW�Ct�����F����jY;�x���v��:s��4�;�Ş�`��aW}#Z��5&b�C�X���ɒ6ͦ��~v�˒�xK�7�;��8���-�*ִ���S�!Y�B-��1�fKh��$ �1ZK�(���=2|`���-���7T�L�wE���j�<�<|�$�Ii�9����R>�m,�nl�����δW-D$�'���(�XΤ^�;Ծ��ɮ�_�c�\����؏h$�U�W�X7�Y�Z�;���{�W$N���h�j�&��Η6�υ��L��m�ב������%�ˍ��ş��2i�_e>�z+99�+y�\M�Z�ѷr�af�E2�:��	?�{����԰?�g�*)g�#��mK۶O��f\�'����&�í�P2O�b��D�!��sEcXuiG�X�F
�|h��Á���5Xa#~����w��tOb�C�/uc!���F�3�B|�}8�3zI��X�B�}siz�B�W�t�k^�/r7K�Չ����_�iǻ��
�(���ޗm�͟rc�Cf��)
���:���|� u��sj�H�]��͖g�J۔|�&uѷ�B��Ŧ�E�q��+6��8ϻ��0g�/$�l�>�����-��՞�=+���=��Oz��/K���?E��4�7l����Pd^�2ܓ����3��[j�)��̾o{����t�EW #pL!J�� Y��[�m;O���>�<.5��2'����D��wM�|g��`r���.���t6)�O�Q������'�r����G�)�?uR��npQXP��ȉ{�C�&I�ZbqT>�LF`�Łp�g�|f�mo)�egȉ-%�m��>j�h�J���>�@)#|�EC�����N��mOI2��$�J�G��S��A�_:�,0+O���C�Q��v��j!�	L��]��B�f|R���M�FP*�l�!۹������A��Onf�5���Wm+ȅMa�XUȋ�N%��3v�qaO��}���r1^0lt �Zͪ�C�=�@/g[����N�����A �Rl��6g# _R/�A�}���n��[^��yS�7�ń>!���w��/2R��߁C��pQl9�P��<�0X��eT)�Y@�p����y��=-a^�w^|^J�HCݒ��]��k
��`�}��}�����AJ�T
�(�����}Z�� ��뮿�K�Ȯ�|-Z�Eb:c�X����aN�2�n״=�U�3��B�9q���P����޸��/��O�P_�L:����/��(�����s�8�>�,��Bd����i�{ӄ	kS�+I�N�ő�v^*�}D�L�G�H#a?K���}sFK��Z���y��u��?�`�%�� f��Mb9Q
]��z���ґK=~7D�C1���͹��c�þw,�n>d$��FLV[	�p���\��"J�W�^���6�Cn����h���Zt*��6���b_�ʻ
������K�#�ū���Q���.�Ǹ�L�0!����ՠdEJ2�8̨�V �y��1�Daߑ$rUé!��g)$_+���7����G�Z" ��9�d)�' !'���U�{�x�����L+��Ɲ40��o �n��d��;9�/6vT��s��`YB=v���4�^�_��(�W3(Y�
���-@��dM]gqr`'���:YLO��碵������f��!=����-�uu=�B
�k�s���e{:'֛v$3�bv:NԯS�~='j���x��{�>�,Ɉ���3՞�rxۛa��C_~Ù�|��z8<�զ��'��)0kN�`)�S�,�颗vϦWm]`�̼L�ws�a�t�p98����6]��^�=A��PJQ�]�����hnC�j��60<{͇UJ�|+!�k(�│�(����R"�P�l�6�[�/xh.��WA�oA��o�7R��s��:{:�Q��ӧ{u�m��:^򏁘����ϯG�p�|����)dbZ~r����߄m¶(�=5��	��;��ml�]�����wgO��2�����w�[J�T�k�A�d7Ȍ=:;g���S��O<w�rf�]~���p�|��2_��S3�,^%V%�0�9���R֌f�<qiw_ĭR�貖d�L�"�;+���J��η���p��ۭ�S�����s�۫>6��|%dn�y)�I����$���k�߽���V��T�yh� ���I=֦nc��$��5 &����E�/�/qN'�=�03J�Փ>7��6�Gn���\�9���wO~L�q�&BLӬ)�ۣw̜6G&�}`�WO� ��kXk�!�i�;��xq����R��߉���inV�	)�t|�ޖz,5�<��\I���8hC�Ћ�=��[�h%q،ա��M����'N���>V����tO7��G��ܑ�QE�]�|�������VW)���zaU�B�����SwQ����u�����R�MƖ�?�Q����RM���i3P=���;6�ơ\�l���t%JȮ�\�)�eR�՚t��SF\�ȫ���dO�OS7���=*_�������,<5�J1Ӡw�nN���etN�l���Fߌ���`������.�LQ�Gs��0Pd���=5���i�.t��k�?d����q�E�����J �$���Tn�t(�E���Ծ�Δd���$�z#���kVX�����խ:�Uߜ����Е�d^2�X߭����<8'Ǚ�9������<�j6�0�]�>[�ǋmyqچ󫦐��� ���a	�,��}�[���k�Y֜��{�֧ɋ =��8Ϋ���Ȼ��XM���҆�v"�]���o��a��N ���ϚuO�f��-%�>"V�y�d��y��cx�lN�>r.�����|I.�w�
�ʝ���Hѥy�,e�җ'ϛ��`0+����j-J�<_a�C�>I{�7m�S��ѧf*"d-���r-|�
�.?��fi�-w���+�Ж�h7��2^�ѕ�Jӓ4ɦUXщF}%\>C�@�U���#	s���ϧ2�	��A-������O:��DلՠC˵:V���ˋ�z�o��zv�[���I]����+�����ˍzw�_�1�D�Z�M͞5�J>�
�:�KU���K���>���k��c�p����l��L��Nz�3b��>[�Z5H�=S*�b�X.�l<������XͳM�0|�q�p�b�|��z�����vu�k��
���f}kz��Գ��|\� �	����H�2�4�����[���|�� G�:5�9_߬3q�/�b�y�h!�ᔹ��o ���	��ֺ�u�E�S�g��s�[�Q�ڐM�7Oj�M��J5��/�@�o�<�Jr�rؑ�=�Sa5�J*�,�hx'>��-�S6�}����i�F�ї���h�%B�k�O��U@�)��7��S�p�=r=�s�8���x���?Ұ}�Lϻb�}�	N�tԍS���/�D��7?�B��fG�d9ʱ��Y��jh))랝E����bJ�׸��K�}_l.��U-�M�(�95����r�%�����g��5O���W��'�ݭ�tRp��pN|[��R���c����,6o�8���\	
�*�ǗS:�v��G���r�'��������������o�Ñk����,�vِ��sB�z���qo�	Z'��������Jt5`M�J��4!�2;����nm�I�]=�al=$�hk��5�n��R��)����1�_"�Ӯ?�����NK��г0�̵Gт�U��-(�-��7j=���6r��u���Y^7�)�D;���4�9�>'恌,0K_^"⫽�
����#]^��<�=���w��"h��n*}�<ť�J�ZQ�r%$S��-�_�lMst,r�R����̹�۳�b�x�w�
�|�ًy����=%�uwb�������4��|y���K2�H���㳜J�+ׂ�&�:������Eg������aN&I}�'�2��J~C�V�J�"��^�Z�	��m���k�"7U�8�) �3���zS��A \�rQo�E X�Ď�    �\�h��ȤI����h���R��<c��~�������=R�|����D�t�Jk���TN<��)��Awo�rG>���j�nyV�2Y�l6l�>`���R��2%��]ɍ������M٩�}9`��:?�-ىS�H��Ih�<�C����ҢI�bL�Jno�o�����B.ى��F0�q��%�5�kK�R:��D��ؿ����mS�s*��&[ I"��^O�z�$��,g�s�C��|I�Ds�S*��C��T��(_FV,�H�b�>�g|PO�=	ߴ�(]6�w)o&�Cm!h%�uv4�O3��KԖ�t^F��ü�'�� � 0����$6SA7�� v��cj�̈́ήU+:���C����uL�E
:�I��ݖD�U���*�'}~�����O�w	�
�D�Ug9�'�n=񞕦�Fσ�͂�`�k�����fV�j��S���E�/UC��L~�(C�⟞�E=3/a���|�h0�$����u�_�,��!�LV����"]�:)�=���!s��)��� 3d���H?�5М�7�%��@U=t�7"�k��1�:Pd�N��ƍ�bϦ�m�0�t(�N�9���C'����*w�n��KD�F���A]^;�rY�{�0vsj[�����ur��;կi��Z��Z(A�uS��:���đ��t��Gr	���V2[�b<6M+2��r�0��s��.���3�XZ��X�ɖSH���5�������^Cu[g@@�8�#[��0�i�XL�	H%�{k���o=���q,�I��ŒΡ��&Й3%���?o��eݐSۓ�\k��8ۊy����@���p�W��Z�C~��}�Ի���|H��m5ng����(6�Nm�e�OF�)��$C��Q7A0�ƞ/����Z���	�2�JϢ��m�#u�Fe�h��L���Z���yYK@�(Fdj���`�r+M�y`\M/"�F�=Y��f�,����U�}��Zfl^o�R�_�v�����UJ��cW���-��
�p��o�R���V�>c�nϿ�&�q�m7bz�����R�j5x�S��^�˶`�V0�bۓ6o���S>�Hǡ{�Mm�D'�E6�� 9F�)p�N�9���H���� ]�L���f���[ճֆ�$��j��c2n�5k"[�{������Ay��:.d^6��hz�i/=�C+��t�{�a~�'���F��wd`����wľ8�l5�Zż���<9������r+�P��޵j[l]������H�H/9�� }!�����&WS���'����yh��q���%�K"'��)�o�#��U�H"�G�L��؍��k�ʑN�e�B��T3M8N�b"��Lz�`�g&:4�?�QV�S�'��:�5�>����j���h���yl�S���U��IN�|�&�����Ú=73�Gp��4�'W��߱4�s4+�������X0O��aH���Su��.S�Y%r]��G����	j;C:^�'�%���f�$��n�s�1V�3!��,Y[�.��tQy��g��#ϛ�rU��e��s�}8�UII��(W�����NI6{�}�JT�$ȕä\�|�n_/���g8>�֭�U��xa���Q�H3�s�-�Dd*LPNl'2OաH>K�����6��<�������g!��x]������k���fne����{��R3����Qa��J��9��b�%2[o���>�t@o)'+��u�'!�
�ИL0�l�-� ���S�q缌@C����.Fn���(��d����CA�*o��w�5�"�LC|Ɂ��)7M���U
�F��-�3T/���E�,�v�d�h��L'Ȁ�f�0�b'��Dh`o뜗}�f���=rՙ��ml�Α*��7�Rs�E����G?���XBAG�zv�8(s<��s@o*�Y���%�͸|O�S�r��s�gv{�z�z.~���|d4I���|}��x��b+�^{My|]�B=5���G�{���T��츮�a�绫7�EG��E��wf���&X��ip��5
0mWi����� N��eY���J���
Ya/��vH�v�E��vN�fr[��x�^ԑpHwl~=���ܘ{��-K�(�[�$��:�B��կ��!ql�X
����v�i;�i�a�r�Z�e\�2Ym�Q�q�So�Zj{'S�^��5E1�Sw��/�^����?ԕ����,���_�M����eo;����]���T��z�	ld�g�^��z���Ǔ�E��<N8?�	P��	�FH7T�~e ���&f�{62�Tϝ5K�,ؓ�p�}hv����;�+b�d�Ʒ�	�9U��9���+� *?A�d��^/W]n]^x;TF���-���j*�ۄFJ'�L�:?�m�ʝ]ŔD=��,_��j�*���^�r��P��j��������$.�N������fA'��R��֛@Ay��U�+$unJR�H3��k�����$ռ����-�Snd՗�t�b�������Z'�蜷�Fr��g�+�!�.�2o�\�$<������;�:x�CcÕ�Q�����-�Sa���	֤�!8I(��R�T�}T�侚wɆ���TO�W�r��j2P>�#���ܟ;�"�=l�n��M�׳����;��W�;m�ş<��6�������o��o��o��o��o��o�py�m)�Y+����M46n�z���O�����?1���ק����雯Rl˧?}��o��"�\����/�X~��O�����ƹ�����÷��4������)_�������������o�_�)�ӯ���o���~��/��_�ӧ|�O˧/����W������g�����~�ߎ_��ӿ����O_|����/����������������?�ן��0.���+O|�'��/��������|���~��/�����o����?���?��Ï�h������1���_��O>������2����'o�����ͯ�ǧ���������_}1�i��G��߿�~�!��?��1��Wt����_�1_����?~��/��&�ٳ��9�X��S����s�>���g����/~�� �m�      �   =   x�3500��Ã�L�	+1!�Ĕ��] %f�M1'��А�6$�iC>����� ��NT      �   w   x�3��ON��2�<:�4)��˘�7���˄�/�81��ȭ<���ˌ�#�*�(d����[Z�e��xd~iqI~1�%�ke��=9\���ٙ�\���މ�G6YF��E�9G6fs��qqq �;#�      �   P   x�3�tuw�2��u"G.cNGoW�#��L8��"P�)����]�}B��8]������9���s�D����� p�      �   �   x�e�K� Dד�T����t���j�UƑW<ylxb��د�@��>
��IH�t�(S�o(�}�x�
�yA
k�l�EA^���YƷQ�z��?ڳ�����2�fl3���J����l�5!�'Sa�	��f�8��b5ag�	�M�6��N���=r��sU�G:���k۶/*܉�      �      x������ � �      �   �   x��ҽ
�0���)�b��:��C��K0�J����q2��\Y�{½L�ڙ{z������q����t`��s8��W�������M�d'���y�#t�rj�kz�����f��ț2iF\��?ˉ��	�	y��4Y�5��2�D!�f�a̵q��D��v��q�%      �   S   x�3�H�J,*I-��2�N�9��˘�p{b�����I�\&��@vjnR*�)�sin"����1���24�tK-�H,����� -q      �   h   x����@��L6 q��p�/�%�����5Ѓ�zy%<Ǒ5Kg�X���Nqf��\��<C	�>��$�;��y_����S:���s���_�k      �     x�eQKn�0]�O�T��4��" �D��}z�.9���^��v3���7($�h�z��ָ�@�n�����f6�͎�[ �0�[�be֋?���L���f��TŤ�fbg�2�IJP �v)����	��@��h\����W;�;3.��\���_JI�%���O,�07�ҕθx��PU^�Y�I�C����():o�-?�09��Pj�\�b��"�M��]5S���?~����t�����;o'7��(@>���RL�u���7��{      �   �   x���
�0 ��oϱk�7����++2%�K�� ��=Vу59�G)0��(R<��`�@]af�읟�ռ����)<`���$����i��&�L�u��/��=�~R�d�s�mY�䫄E��s�eZ-�V
��.!���|#�      �   �  x��Z�r;��_��-I|����i_�$J%���@��΋;���l�u:��9#�_{3C  ;�H��8}�������Pf6�x�n������eE���s�'l���\�|!��g�j��$f��o��;����i,�w��ryL^5;�t�#���^z�f�;���!���$�]��T��������g��=c�w2��q��'�c�@_߽�G#v9>>�Y��:����txj[�:�7�x����ؾ�al܅�éumS߷���_Y��j�����w�m}מ7����mM����vz9���e8�?�NǗֵ�a������ᾁw~b]g�����/�®o���缗a.Rv�J��B�'�BM�R*��;)%��-��f}ډX��<,�M��0��Fr�%*�2��mC�f��|��I����t1�C���m�J5G�V ��?�Me� �`>�O�L#0	a����E�D$c�L�N�i44���9����$E�t�-����p.�u1���yt	vvO�_�34b�b�����q�3O���섯6��ë�1-/��5Z�]��-O��T�����n��>ƙH��OK�炍�4q�T+=�9��?�lj���ί�)f9��O��~��&ho�ȿ��ː_���-O�e�W��.;���(��f<�Ac�&7y��C�Ӏ}ny(}��)�D^�)�h�9[*�"q;+�2�C�uZF��_�#Ň/(>.�e������x�*}K�\�2eS(aC4���w�Qr�v\�HG�.n�HL��,���)�3�=���Tޗ�8�f�kg����hs��ġ�d�]�pVB��
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
���[��g���b5�Vo1��z��`J_L��Q����q��ի��q�      �   (   x�3�9��(���T�� .#N׼����W?�=... ��	�      �   4   x�3�r�u��2�t<2�3��ӛ˘34*��'ԛ˄��Ȇ�#|�b���� �[      �   �   x�U�An� EןSp��;���4����lu��`�����R*=��|1��J�,��*Ǌ����f���_��q9w5t5 ]�=/�]��h��C>�L�k;Bpo�=���s��M�V�iuP�A��ۊoĮG,ɠ�j"�sp'1���8��ZV��@�}����#5���t�S��?��x�m�����'�P�^�s�<1O�      �      x������ � �      �   �   x�%�;�0��z�.��x\`�XQǱ�6�4�Ѥ�ؚ�$�#���i����<{1�8�~	,#��s}�OR��T���M]b�ӹ�&ڡ��(�L�Q�<�C��ZaӖ�.����t��3�0�      �   I  x�=�]��0���U�
FM�$�����w�������<!����ל�$O��ı���,��]ӺyM$r�ʐ̔�����y�$D����:�L�Db���n[�	�6�jIX)i���#U*��fj;�\��HU�K�x�1�o3�<mL:Ɛ�x���>wE�%�n�_wW恖	�{_�ҁ	!�}?�"`�"EĞ �騴ԯ��+cH���'=���^���
����xȖ��_<-LJVV��ub����?O*L�IȂz7�?)!n�����#���a���Ya�A�D�������y���C����Gd��J�mv��N� r���|�nE�����G�q�ˈdE��ţ:U9���Y;�).ʀ 7�I�
B��7�A����7/T����ްED%І6-d�����ح$�!���;NkO"�њ���~��" c��ݼ$㓦���ѿ?�+��*q�{z?Z��te 1�8��l�f�#�2��Ё;DQA˙{��։/�0~�N�0���g2�������:08?\��:2B��)�I� �u|o�'@d%���gĔ�]y�ze|���mq�)�P���D�Ti/�L*�F����M�*���ꧥ
Cz��0�
�A0좍�Û$E�FӅ�4��"i9Z��狶U�Xc��{�H'� 6��6��� 
C"��̶q7ޘl\�X��g����m����Q�¸%S$��^�� 6��װ^L�H�����q�����Gytz����q - �e�j�rr�X��|�b�! �B���
۰َ�!��P��5��[I%^�7�9�&�]\��1�7���c�}�β�?���      �   m  x�mY�r7]_E/�*�K|���6�~�&E�l$E�e��"Jv��Tj����o��Ξ��so�AJIʉp���\pJꔾ�#SE���SS��hH��~��7�#RF�
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
�����͗���d@������f?9�0$��S��W�s.���͛�����      �      x���ɲ�:�6����e��p8��l�ʖT���cȮpUn�F��4��X 	&���������<��Ll����?������2)օ/;���m�ƅ�c�����=_�ߟa%�@ �@ �@ �@ �@ �@ �@ �y���}������6�o��O���]�Ͼk�� ��ӷ|&}滳m^���Gy?���Ju����V�����;bC�������aޯ�>���U}�ۮ��1��\����O�A��~��WQeI�.�,�=4�R�o�c9���5uM�e�o�(��Um��\n�ܾ��u�����;6��.KRu�o�29:�?���xuo�wڶ񎌻��?���L���g�O������@�JԾˋ�,�.[�[X�.K���eY�R�~.�?��[��elC�-D�'sY�5㷔,�X���o߭���MY��c._g�2^H/�rڴ��x�gm�G�֎eܱ��\�����*�-�We9�{�G�;���u��,�j{��˂g��mMe�;5����ٟ@ ވ�UO�ڊ���겴���Z�V���?�5=��ښ�֯m���g]P�=z'Ĳ���@��mh�}bv����)������J="O�����Kφ�m�)M��Z����ԥޒ�>���֣���z�scy]�^[�����e?��냟���O�v�{\?��]���Ө���U�8���{���c?�=�8zE02ڴ�����f3���O���R��j���ѐ7�ёMf{�O�(Kk[ǃӶu��xpr�g���u�V7���Ow���F��L+S����3>iǪ����_I�@���xhlZ��f�2�{N�,�\3����.'�1(��aQg�ۣr���z�kzt6ƑO{e�G�y����O��[Q�V�I�޷�	�x�;[%�W�ә�
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
�pߌ��7�����{��ǽ�[u�ָ���`�U��}���W[����gr�+ϙc?3���3V���l�?�Y&�+���J:��$�@ �@ �@ �@ �@ �@ �@ �9��������������_�˿���?��g�/���H�m�X�������������o��5Ric��_8��o������O�O�����?��o���r�p��`�põ�o*&��H.�6�7���g��?�W��^�ſS���g�����o������������?�_�������������?��Qw��쯅�����w�W���W���J�      �      x�3�q���L�2��%\1z\\\ 4�=      _   :   x�3�472�500����q�R8�����G6��pdޑ�Fz`�i�i����� ��      a   (   x�3�4���t�34��3 .#����L8F��� �'�      c   &   x�3�N�(HT���+I�R�LI�I,:��+F��� ��	�      e      x������ � �      g      x������ � �      i   ?   x�34�����t�34�4�3 N(��М�$�����7AW`Q 2���ӄ=... �~�      m      x�3��472�500�4�35 �=... 9"      o      x������ � �      q      x������ � �      �      x������ � �      k   ^   x���q�	64��v��Sqt�qU04V�u;���P� 8c��,9�<����}B9��l ��]=�|��C�\#�P���qqq S=�     