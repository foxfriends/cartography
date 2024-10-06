--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0 (Debian 17.0-1.pgdg120+1)
-- Dumped by pg_dump version 17.0 (Ubuntu 17.0-1.pgdg24.04+1)

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
    account_id public.citext NOT NULL
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
    account_id public.citext NOT NULL,
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
    account_id public.citext NOT NULL,
    grid_x integer NOT NULL,
    grid_y integer NOT NULL,
    width integer GENERATED ALWAYS AS (8) STORED NOT NULL,
    height integer GENERATED ALWAYS AS (8) STORED NOT NULL
);


--
-- Name: TABLE fields; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.fields IS 'Every card is played onto a field. Each account has any number of fields arranged in an infinite space.';


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
-- Name: fields fields_account_id_grid_x_grid_y_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fields_account_id_grid_x_grid_y_key UNIQUE (account_id, grid_x, grid_y);


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

