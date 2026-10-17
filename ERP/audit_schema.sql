--
-- PostgreSQL database dump
--

\restrict pAP7VYWwrzaasl4XCuT7oQPtiPbfz9HjSumFsHUafYkyjQIw1D2uy1SvBAJ7l1V

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
-- Name: audit_create_partition(smallint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.audit_create_partition(p_year smallint) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
DECLARE
    _name text := format('audit_log_%s', p_year);
BEGIN
    IF p_year IS NULL OR p_year NOT BETWEEN 2000 AND 2999 THEN
        RAISE EXCEPTION 'audit_create_partition: geçersiz yıl %', p_year;
    END IF;
    IF to_regclass('public.' || _name) IS NOT NULL THEN
        RETURN false;
    END IF;
    -- Eşzamanlı ilk aktarımlar aynı yılı açabilir: kilit beklenir, diğeri oluşturduysa hata yutulur
    PERFORM pg_advisory_xact_lock(hashtext('audit_create_partition'), p_year);
    BEGIN
        EXECUTE format('CREATE TABLE public.%I PARTITION OF public.audit_log FOR VALUES IN (%s)', _name, p_year);
        EXECUTE format('ALTER TABLE public.%I OWNER TO postgres', _name);
    EXCEPTION WHEN duplicate_table THEN
        RETURN false;
    END;
    RETURN true;
END
$$;


ALTER FUNCTION public.audit_create_partition(p_year smallint) OWNER TO postgres;

--
-- Name: audit_database_partition(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.audit_database_partition() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
BEGIN
    PERFORM public.audit_create_partition(NEW.period_year);
    RETURN NEW;
END
$$;


ALTER FUNCTION public.audit_database_partition() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_database; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_database (
    db_name character varying(63) NOT NULL,
    db_family character varying(63) NOT NULL,
    period_year smallint NOT NULL,
    company_title character varying(128),
    first_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    last_flush_at timestamp with time zone,
    flushed_rows bigint DEFAULT 0 NOT NULL,
    CONSTRAINT audit_database_flushed_rows_check CHECK ((flushed_rows >= 0)),
    CONSTRAINT audit_database_period_year_check CHECK (((period_year >= 2000) AND (period_year <= 2999)))
);


ALTER TABLE public.audit_database OWNER TO postgres;

--
-- Name: TABLE audit_database; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.audit_database IS 'ths_audit kaynak veritabanları (dönem DB''leri); audit_flush() ilk aktarımda ekler';


--
-- Name: COLUMN audit_database.db_family; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit_database.db_family IS 'Dönem eki atılmış ad (ths_erp2026 -> ths_erp): aynı firmanın tüm yılları';


--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_log (
    id bigint NOT NULL,
    period_year smallint NOT NULL,
    db_name character varying(63) NOT NULL,
    db_family character varying(63) NOT NULL,
    source_id bigint NOT NULL,
    table_schema character varying(63) NOT NULL,
    table_name character varying(63) NOT NULL,
    row_id bigint,
    action character(1) NOT NULL,
    changed_at timestamp with time zone NOT NULL,
    transaction_id bigint,
    db_user character varying(63) NOT NULL,
    app_user character varying(64),
    client_addr inet,
    application_name character varying(64),
    old_data jsonb,
    new_data jsonb,
    received_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT audit_log_action_check CHECK ((action = ANY (ARRAY['I'::bpchar, 'U'::bpchar, 'D'::bpchar]))),
    CONSTRAINT audit_log_data_check CHECK ((((action = 'I'::bpchar) AND (old_data IS NULL) AND (new_data IS NOT NULL)) OR ((action = 'D'::bpchar) AND (old_data IS NOT NULL) AND (new_data IS NULL)) OR ((action = 'U'::bpchar) AND (old_data IS NOT NULL) AND (new_data IS NOT NULL))))
)
PARTITION BY LIST (period_year);


ALTER TABLE public.audit_log OWNER TO postgres;

--
-- Name: TABLE audit_log; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.audit_log IS 'Ortak işlem geçmişi; I: yeni satır (new_data tam), D: silinen (old_data tam), U: yalnız değişen kolonlar (eski / yeni)';


--
-- Name: audit_log_2026; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_log_2026 (
    id bigint CONSTRAINT audit_log_id_not_null NOT NULL,
    period_year smallint CONSTRAINT audit_log_period_year_not_null NOT NULL,
    db_name character varying(63) CONSTRAINT audit_log_db_name_not_null NOT NULL,
    db_family character varying(63) CONSTRAINT audit_log_db_family_not_null NOT NULL,
    source_id bigint CONSTRAINT audit_log_source_id_not_null NOT NULL,
    table_schema character varying(63) CONSTRAINT audit_log_table_schema_not_null NOT NULL,
    table_name character varying(63) CONSTRAINT audit_log_table_name_not_null NOT NULL,
    row_id bigint,
    action character(1) CONSTRAINT audit_log_action_not_null NOT NULL,
    changed_at timestamp with time zone CONSTRAINT audit_log_changed_at_not_null NOT NULL,
    transaction_id bigint,
    db_user character varying(63) CONSTRAINT audit_log_db_user_not_null NOT NULL,
    app_user character varying(64),
    client_addr inet,
    application_name character varying(64),
    old_data jsonb,
    new_data jsonb,
    received_at timestamp with time zone DEFAULT now() CONSTRAINT audit_log_received_at_not_null NOT NULL,
    CONSTRAINT audit_log_action_check CHECK ((action = ANY (ARRAY['I'::bpchar, 'U'::bpchar, 'D'::bpchar]))),
    CONSTRAINT audit_log_data_check CHECK ((((action = 'I'::bpchar) AND (old_data IS NULL) AND (new_data IS NOT NULL)) OR ((action = 'D'::bpchar) AND (old_data IS NOT NULL) AND (new_data IS NULL)) OR ((action = 'U'::bpchar) AND (old_data IS NOT NULL) AND (new_data IS NOT NULL))))
);


ALTER TABLE public.audit_log_2026 OWNER TO postgres;

--
-- Name: audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.audit_log ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.audit_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: audit_log_2026; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log ATTACH PARTITION public.audit_log_2026 FOR VALUES IN ('2026');


--
-- Name: audit_database audit_database_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_database
    ADD CONSTRAINT audit_database_pkey PRIMARY KEY (db_name);


--
-- Name: audit_log audit_log_source_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_source_key UNIQUE (period_year, db_name, source_id, changed_at);


--
-- Name: audit_log_2026 audit_log_2026_period_year_db_name_source_id_changed_at_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log_2026
    ADD CONSTRAINT audit_log_2026_period_year_db_name_source_id_changed_at_key UNIQUE (period_year, db_name, source_id, changed_at);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (period_year, id);


--
-- Name: audit_log_2026 audit_log_2026_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log_2026
    ADD CONSTRAINT audit_log_2026_pkey PRIMARY KEY (period_year, id);


--
-- Name: audit_log_app_user_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX audit_log_app_user_idx ON ONLY public.audit_log USING btree (app_user, changed_at);


--
-- Name: audit_log_2026_app_user_changed_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX audit_log_2026_app_user_changed_at_idx ON public.audit_log_2026 USING btree (app_user, changed_at);


--
-- Name: audit_log_changed_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX audit_log_changed_at_idx ON ONLY public.audit_log USING btree (changed_at);


--
-- Name: audit_log_2026_changed_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX audit_log_2026_changed_at_idx ON public.audit_log_2026 USING btree (changed_at);


--
-- Name: audit_log_record_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX audit_log_record_idx ON ONLY public.audit_log USING btree (db_family, table_name, row_id);


--
-- Name: audit_log_2026_db_family_table_name_row_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX audit_log_2026_db_family_table_name_row_id_idx ON public.audit_log_2026 USING btree (db_family, table_name, row_id);


--
-- Name: audit_log_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX audit_log_id_idx ON ONLY public.audit_log USING btree (id);


--
-- Name: audit_log_2026_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX audit_log_2026_id_idx ON public.audit_log_2026 USING btree (id);


--
-- Name: audit_log_2026_app_user_changed_at_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.audit_log_app_user_idx ATTACH PARTITION public.audit_log_2026_app_user_changed_at_idx;


--
-- Name: audit_log_2026_changed_at_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.audit_log_changed_at_idx ATTACH PARTITION public.audit_log_2026_changed_at_idx;


--
-- Name: audit_log_2026_db_family_table_name_row_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.audit_log_record_idx ATTACH PARTITION public.audit_log_2026_db_family_table_name_row_id_idx;


--
-- Name: audit_log_2026_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.audit_log_id_idx ATTACH PARTITION public.audit_log_2026_id_idx;


--
-- Name: audit_log_2026_period_year_db_name_source_id_changed_at_key; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.audit_log_source_key ATTACH PARTITION public.audit_log_2026_period_year_db_name_source_id_changed_at_key;


--
-- Name: audit_log_2026_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.audit_log_pkey ATTACH PARTITION public.audit_log_2026_pkey;


--
-- Name: audit_database audit_database_partition; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER audit_database_partition BEFORE INSERT OR UPDATE OF period_year ON public.audit_database FOR EACH ROW EXECUTE FUNCTION public.audit_database_partition();


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO ths_audit_writer;


--
-- Name: FUNCTION audit_create_partition(p_year smallint); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.audit_create_partition(p_year smallint) FROM PUBLIC;


--
-- Name: TABLE audit_database; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT ON TABLE public.audit_database TO ths_audit_writer;


--
-- Name: COLUMN audit_database.period_year; Type: ACL; Schema: public; Owner: postgres
--

GRANT UPDATE(period_year) ON TABLE public.audit_database TO ths_audit_writer;


--
-- Name: COLUMN audit_database.company_title; Type: ACL; Schema: public; Owner: postgres
--

GRANT UPDATE(company_title) ON TABLE public.audit_database TO ths_audit_writer;


--
-- Name: COLUMN audit_database.last_flush_at; Type: ACL; Schema: public; Owner: postgres
--

GRANT UPDATE(last_flush_at) ON TABLE public.audit_database TO ths_audit_writer;


--
-- Name: COLUMN audit_database.flushed_rows; Type: ACL; Schema: public; Owner: postgres
--

GRANT UPDATE(flushed_rows) ON TABLE public.audit_database TO ths_audit_writer;


--
-- Name: TABLE audit_log; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT ON TABLE public.audit_log TO ths_audit_writer;


--
-- PostgreSQL database dump complete
--

\unrestrict pAP7VYWwrzaasl4XCuT7oQPtiPbfz9HjSumFsHUafYkyjQIw1D2uy1SvBAJ7l1V

