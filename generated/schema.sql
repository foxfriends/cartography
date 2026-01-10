--
-- PostgreSQL database dump
--

\restrict aa4b4bc410c5cacbd97fc326d0f62806

-- Dumped from database version 17.7 (Debian 17.7-3.pgdg13+1)
-- Dumped by pg_dump version 17.7 (Debian 17.7-3.pgdg13+1)

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
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: card_category; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.card_category AS ENUM (
    'residential',
    'production',
    'source',
    'trade'
);


--
-- Name: notify_changes_int_target(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_changes_int_target() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
  v_process_new bool = (TG_OP = 'INSERT' OR TG_OP = 'UPDATE');
  v_process_old bool = (TG_OP = 'UPDATE' OR TG_OP = 'DELETE');
  v_event text = TG_ARGV[0];
  v_topic_template text = TG_ARGV[1];
  v_attribute text = TG_ARGV[2];
  v_id text = TG_ARGV[3];
  v_record record;
  v_sub text;
  v_target bigint;
  v_topic text;
  v_i int = 0;
  v_last_topic text;
BEGIN
  -- On UPDATE sometimes topic may be changed for NEW record,
  -- so we need notify to both topics NEW and OLD.
  FOR v_i in 0..1 LOOP
    IF (v_i = 0) AND v_process_new IS TRUE THEN
      v_record = NEW;
    ELSIF (v_i = 1) AND v_process_old IS TRUE THEN
      v_record = OLD;
    ELSE
      CONTINUE;
    END IF;
    IF v_attribute IS NOT NULL THEN
      EXECUTE 'select $1.' || quote_ident(v_attribute) || ', $1.' || quote_ident(v_id)
        USING v_record
        INTO v_sub, v_target;
    END IF;
    IF v_sub IS NOT NULL THEN
      v_topic = replace(v_topic_template, '$1', v_sub);
    ELSE
      v_topic = v_topic_template;
    END IF;
    IF v_topic IS DISTINCT FROM v_last_topic THEN
      -- This if statement prevents us from triggering the notification twice for the same row
      v_last_topic = v_topic;
      PERFORM pg_notify(v_topic, json_build_object(
        'event', v_event,
        'subject', v_sub,
        'target', v_target
      )::text);
    END IF;
  END LOOP;
  RETURN v_record;
end;
$_$;


--
-- Name: notify_changes_text_target(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_changes_text_target() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
  v_process_new bool = (TG_OP = 'INSERT' OR TG_OP = 'UPDATE');
  v_process_old bool = (TG_OP = 'UPDATE' OR TG_OP = 'DELETE');
  v_event text = TG_ARGV[0];
  v_topic_template text = TG_ARGV[1];
  v_attribute text = TG_ARGV[2];
  v_id text = TG_ARGV[3];
  v_record record;
  v_sub text;
  v_target text;
  v_topic text;
  v_i int = 0;
  v_last_topic text;
BEGIN
  -- On UPDATE sometimes topic may be changed for NEW record,
  -- so we need notify to both topics NEW and OLD.
  FOR v_i in 0..1 LOOP
    IF (v_i = 0) AND v_process_new IS TRUE THEN
      v_record = NEW;
    ELSIF (v_i = 1) AND v_process_old IS TRUE THEN
      v_record = OLD;
    ELSE
      CONTINUE;
    END IF;
    IF v_attribute IS NOT NULL THEN
      EXECUTE 'select $1.' || quote_ident(v_attribute) || ', $1.' || quote_ident(v_id)
        USING v_record
        INTO v_sub, v_target;
    END IF;
    IF v_sub IS NOT NULL THEN
      v_topic = replace(v_topic_template, '$1', v_sub);
    ELSE
      v_topic = v_topic_template;
    END IF;
    IF v_topic IS DISTINCT FROM v_last_topic THEN
      -- This if statement prevents us from triggering the notification twice for the same row
      v_last_topic = v_topic;
      PERFORM pg_notify(v_topic, json_build_object(
        'event', v_event,
        'subject', v_sub,
        'target', v_target
      )::text);
    END IF;
  END LOOP;
  RETURN v_record;
end;
$_$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id character varying(32) NOT NULL
);


--
-- Name: TABLE accounts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.accounts IS 'Player/user accounts. Represents one person.';


--
-- Name: card_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.card_accounts (
    card_id bigint NOT NULL,
    account_id character varying(32) NOT NULL
);


--
-- Name: TABLE card_accounts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.card_accounts IS 'Records owners of card. Each card has at most one owner at any time.';


--
-- Name: card_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.card_types (
    id character varying(64) NOT NULL,
    name character varying(64) NOT NULL,
    description text NOT NULL,
    category public.card_category NOT NULL
);


--
-- Name: TABLE card_types; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.card_types IS 'Data representation of the types of cards available in the game. The implementation of most card functions is handled at runtime keyed off of the id.';


--
-- Name: cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cards (
    id bigint NOT NULL,
    card_type_id character varying(64) NOT NULL
);


--
-- Name: TABLE cards; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cards IS 'Every instance of every card that exists in the game. Not all are necessarily owned by an account, as some may be in packs still waiting to be found/opened.';


--
-- Name: cards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.cards ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: field_cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.field_cards (
    card_id bigint NOT NULL,
    account_id character varying(32) NOT NULL,
    field_id bigint NOT NULL,
    grid_x integer NOT NULL,
    grid_y integer NOT NULL
);


--
-- Name: TABLE field_cards; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.field_cards IS 'Tracks the location of cards placed into fields.';


--
-- Name: fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fields (
    id bigint NOT NULL,
    name character varying(64) DEFAULT ''::character varying NOT NULL,
    account_id character varying(32) NOT NULL
);


--
-- Name: TABLE fields; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.fields IS 'Every card is played onto a field. An account may have multiple fields, but likely only has one.';


--
-- Name: fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.fields ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: card_accounts card_accounts_card_id_account_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.card_accounts
    ADD CONSTRAINT card_accounts_card_id_account_id_key UNIQUE (card_id, account_id);


--
-- Name: card_accounts card_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.card_accounts
    ADD CONSTRAINT card_accounts_pkey PRIMARY KEY (card_id);


--
-- Name: card_types card_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.card_types
    ADD CONSTRAINT card_types_pkey PRIMARY KEY (id);


--
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- Name: field_cards field_cards_field_id_card_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_cards
    ADD CONSTRAINT field_cards_field_id_card_id_key UNIQUE (field_id, card_id);


--
-- Name: field_cards field_cards_field_id_grid_x_grid_y_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_cards
    ADD CONSTRAINT field_cards_field_id_grid_x_grid_y_key UNIQUE (field_id, grid_x, grid_y);


--
-- Name: field_cards field_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_cards
    ADD CONSTRAINT field_cards_pkey PRIMARY KEY (card_id);


--
-- Name: fields fields_id_account_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fields_id_account_id_key UNIQUE (id, account_id);


--
-- Name: fields fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fields_pkey PRIMARY KEY (id);


--
-- Name: accounts_id_case_insensitive; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX accounts_id_case_insensitive ON public.accounts USING btree (lower((id)::text));


--
-- Name: card_accounts_account_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX card_accounts_account_id_index ON public.card_accounts USING btree (account_id);


--
-- Name: field_cards _500_subscription_card_moved; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER _500_subscription_card_moved AFTER INSERT OR UPDATE ON public.field_cards FOR EACH ROW EXECUTE FUNCTION public.notify_changes_int_target('place_card', 'field_cards:$1', 'field_id', 'card_id');


--
-- Name: field_cards _500_subscription_card_removed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER _500_subscription_card_removed AFTER DELETE ON public.field_cards FOR EACH ROW EXECUTE FUNCTION public.notify_changes_int_target('unplace_card', 'field_cards:$1', 'field_id', 'card_id');


--
-- Name: card_accounts _500_subscription_card_transferred; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER _500_subscription_card_transferred AFTER INSERT OR DELETE OR UPDATE ON public.card_accounts FOR EACH ROW EXECUTE FUNCTION public.notify_changes_int_target('transfer_card', 'card_accounts:$1', 'account_id', 'card_id');


--
-- Name: fields _500_subscription_fields_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER _500_subscription_fields_changed AFTER UPDATE ON public.fields FOR EACH ROW EXECUTE FUNCTION public.notify_changes_int_target('edit_field', 'fields:$1', 'account_id', 'id');


--
-- Name: fields _500_subscription_fields_created; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER _500_subscription_fields_created AFTER INSERT ON public.fields FOR EACH ROW EXECUTE FUNCTION public.notify_changes_int_target('new_field', 'fields:$1', 'account_id', 'id');


--
-- Name: card_accounts card_accounts_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.card_accounts
    ADD CONSTRAINT card_accounts_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: card_accounts card_accounts_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.card_accounts
    ADD CONSTRAINT card_accounts_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.cards(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cards cards_card_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_card_type_id_fkey FOREIGN KEY (card_type_id) REFERENCES public.card_types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: field_cards field_cards_account_id_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_cards
    ADD CONSTRAINT field_cards_account_id_card_id_fkey FOREIGN KEY (account_id, card_id) REFERENCES public.card_accounts(account_id, card_id);


--
-- Name: field_cards field_cards_account_id_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_cards
    ADD CONSTRAINT field_cards_account_id_field_id_fkey FOREIGN KEY (account_id, field_id) REFERENCES public.fields(account_id, id);


--
-- Name: field_cards field_cards_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_cards
    ADD CONSTRAINT field_cards_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: field_cards field_cards_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_cards
    ADD CONSTRAINT field_cards_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.cards(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: field_cards field_cards_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_cards
    ADD CONSTRAINT field_cards_field_id_fkey FOREIGN KEY (field_id) REFERENCES public.fields(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fields fields_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fields_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict aa4b4bc410c5cacbd97fc326d0f62806

