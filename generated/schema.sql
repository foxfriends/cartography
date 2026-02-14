--
-- PostgreSQL database dump
--

\restrict aa4b4bc410c5cacbd97fc326d0f62806

-- Dumped from database version 18.1 (Debian 18.1-1.pgdg13+2)
-- Dumped by pg_dump version 18.1 (Debian 18.1-1.pgdg13+2)

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
-- Name: card_class; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.card_class AS ENUM (
    'tile',
    'citizen'
);


--
-- Name: tile_category; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tile_category AS ENUM (
    'residential',
    'production',
    'amenity',
    'source',
    'trade',
    'transportation'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id public.citext NOT NULL,
    CONSTRAINT accounts_id_check CHECK (((0 < length((id)::text)) AND (length((id)::text) <= 64)))
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
-- Name: card_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.card_sets (
    id text NOT NULL,
    release_date timestamp with time zone NOT NULL,
    CONSTRAINT card_sets_id_check CHECK (((0 < length(id)) AND (length(id) <= 64)))
);


--
-- Name: TABLE card_sets; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.card_sets IS 'Every card is initially released as part of some card set, which can be used for collectors to organize their collections.';


--
-- Name: card_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.card_types (
    id text NOT NULL,
    card_set_id text DEFAULT 'default'::text NOT NULL,
    class public.card_class NOT NULL,
    CONSTRAINT card_types_id_check CHECK (((0 < length(id)) AND (length(id) <= 64)))
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
    card_type_id text NOT NULL
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
-- Name: citizens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.citizens (
    species_id text NOT NULL,
    name text NOT NULL,
    home_tile_id bigint,
    id bigint NOT NULL,
    CONSTRAINT citizens_name_check CHECK (((0 < length(name)) AND (length(name) < 64)))
);


--
-- Name: TABLE citizens; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.citizens IS 'Citizens that are loyal to a player. Citizens each correspond to some card.';


--
-- Name: field_citizens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.field_citizens (
    citizen_id bigint NOT NULL,
    account_id public.citext NOT NULL,
    field_id bigint NOT NULL,
    grid_x integer NOT NULL,
    grid_y integer NOT NULL
);


--
-- Name: TABLE field_citizens; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.field_citizens IS 'Tracks the state of citizens currently deployed on the field.';


--
-- Name: field_tiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.field_tiles (
    tile_id bigint NOT NULL,
    account_id public.citext NOT NULL,
    field_id bigint NOT NULL,
    grid_x integer NOT NULL,
    grid_y integer NOT NULL
);


--
-- Name: TABLE field_tiles; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.field_tiles IS 'Tile cards that have been played onto a field.';


--
-- Name: fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fields (
    id bigint NOT NULL,
    name text NOT NULL,
    account_id public.citext NOT NULL,
    CONSTRAINT fields_name_check CHECK (((0 < length(name)) AND (length(name) <= 64)))
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
-- Name: pack_banner_cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pack_banner_cards (
    pack_banner_id text NOT NULL,
    card_type_id text NOT NULL,
    frequency integer NOT NULL,
    CONSTRAINT pack_banner_cards_frequency_check CHECK ((frequency > 0))
);


--
-- Name: TABLE pack_banner_cards; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.pack_banner_cards IS 'Lists relative frequencies of cards available to be pulled from each banner.';


--
-- Name: pack_banners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pack_banners (
    id text NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone,
    pack_size integer DEFAULT 5 NOT NULL,
    CONSTRAINT pack_banners_id_check CHECK (((0 < length(id)) AND (length(id) <= 64)))
);


--
-- Name: TABLE pack_banners; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.pack_banners IS 'Every pack that is opened is created using the template of some pack banner.';


--
-- Name: pack_contents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pack_contents (
    pack_id bigint NOT NULL,
    "position" integer NOT NULL,
    card_id bigint NOT NULL
);


--
-- Name: TABLE pack_contents; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.pack_contents IS 'Lists all cards that were part of each pack.';


--
-- Name: packs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.packs (
    id bigint NOT NULL,
    account_id public.citext NOT NULL,
    pack_banner_id text NOT NULL,
    opened_at timestamp with time zone,
    seed bigint NOT NULL,
    algorithm text NOT NULL
);


--
-- Name: TABLE packs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.packs IS 'A historical record of all packs opened by an account.';


--
-- Name: COLUMN packs.seed; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.packs.seed IS 'The u64 seed used to generate this pack. It is cast to i64 and stored here; interpret as raw bytes not meaningful number.';


--
-- Name: COLUMN packs.algorithm; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.packs.algorithm IS 'The seedable random number generation algorithm used to generate this pack.';


--
-- Name: packs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.packs ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.packs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: resources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resources (
    id text NOT NULL,
    CONSTRAINT resources_id_check CHECK (((0 < length(id)) AND (length(id) <= 64)))
);


--
-- Name: TABLE resources; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.resources IS 'Definitions of all types of resources that exist in the game.';


--
-- Name: species; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.species (
    id text NOT NULL,
    class public.card_class GENERATED ALWAYS AS ('citizen'::public.card_class) STORED NOT NULL,
    CONSTRAINT species_id_check CHECK (((0 < length(id)) AND (length(id) <= 64)))
);


--
-- Name: TABLE species; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.species IS 'Definitions of all species of citizen that exist in the game.';


--
-- Name: species_needs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.species_needs (
    species_id text NOT NULL,
    resource_id text NOT NULL,
    quantity integer NOT NULL,
    CONSTRAINT species_needs_quantity_check CHECK ((quantity > 0))
);


--
-- Name: TABLE species_needs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.species_needs IS 'The types of resources that this species needs to consume per day in order to be satisfied.';


--
-- Name: tile_type_consumes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tile_type_consumes (
    tile_type_id text NOT NULL,
    resource_id text NOT NULL,
    quantity integer NOT NULL,
    CONSTRAINT tile_type_consumes_quantity_check CHECK ((quantity > 0))
);


--
-- Name: TABLE tile_type_consumes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tile_type_consumes IS 'The types of resources that are consumed by this tile type, to produce its outputs.';


--
-- Name: tile_type_produces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tile_type_produces (
    tile_type_id text NOT NULL,
    resource_id text NOT NULL,
    quantity integer NOT NULL,
    CONSTRAINT tile_type_produces_quantity_check CHECK ((quantity > 0))
);


--
-- Name: TABLE tile_type_produces; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tile_type_produces IS 'The types of resources that are produced by this tile type, if all its inputs are satisfied.';


--
-- Name: tile_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tile_types (
    id text NOT NULL,
    class public.card_class GENERATED ALWAYS AS ('tile'::public.card_class) STORED NOT NULL,
    category public.tile_category NOT NULL,
    houses integer NOT NULL,
    employs integer NOT NULL
);


--
-- Name: TABLE tile_types; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tile_types IS 'Contains additional information about card types that correspond to tiles.';


--
-- Name: tiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tiles (
    id bigint NOT NULL,
    tile_type_id text NOT NULL,
    name text NOT NULL,
    CONSTRAINT tiles_name_check CHECK (((0 < length(name)) AND (length(name) <= 64)))
);


--
-- Name: TABLE tiles; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tiles IS 'Contains tile-specific information, corresponding to some card.';


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
-- Name: card_sets card_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.card_sets
    ADD CONSTRAINT card_sets_pkey PRIMARY KEY (id);


--
-- Name: card_types card_types_id_class_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.card_types
    ADD CONSTRAINT card_types_id_class_key UNIQUE (id, class);


--
-- Name: card_types card_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.card_types
    ADD CONSTRAINT card_types_pkey PRIMARY KEY (id);


--
-- Name: cards cards_id_card_type_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_id_card_type_id_key UNIQUE (id, card_type_id);


--
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- Name: citizens citizens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.citizens
    ADD CONSTRAINT citizens_pkey PRIMARY KEY (id);


--
-- Name: field_citizens field_citizens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_citizens
    ADD CONSTRAINT field_citizens_pkey PRIMARY KEY (citizen_id);


--
-- Name: field_tiles field_tiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_tiles
    ADD CONSTRAINT field_tiles_pkey PRIMARY KEY (tile_id);


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
-- Name: pack_banner_cards pack_banner_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pack_banner_cards
    ADD CONSTRAINT pack_banner_cards_pkey PRIMARY KEY (pack_banner_id, card_type_id);


--
-- Name: pack_banners pack_banners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pack_banners
    ADD CONSTRAINT pack_banners_pkey PRIMARY KEY (id);


--
-- Name: pack_contents pack_contents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pack_contents
    ADD CONSTRAINT pack_contents_pkey PRIMARY KEY (pack_id, "position");


--
-- Name: packs packs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packs
    ADD CONSTRAINT packs_pkey PRIMARY KEY (id);


--
-- Name: resources resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resources
    ADD CONSTRAINT resources_pkey PRIMARY KEY (id);


--
-- Name: species_needs species_needs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species_needs
    ADD CONSTRAINT species_needs_pkey PRIMARY KEY (species_id, resource_id);


--
-- Name: species species_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species
    ADD CONSTRAINT species_pkey PRIMARY KEY (id);


--
-- Name: tile_type_consumes tile_type_consumes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tile_type_consumes
    ADD CONSTRAINT tile_type_consumes_pkey PRIMARY KEY (tile_type_id, resource_id);


--
-- Name: tile_type_produces tile_type_produces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tile_type_produces
    ADD CONSTRAINT tile_type_produces_pkey PRIMARY KEY (tile_type_id, resource_id);


--
-- Name: tile_types tile_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tile_types
    ADD CONSTRAINT tile_types_pkey PRIMARY KEY (id);


--
-- Name: tiles tiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tiles
    ADD CONSTRAINT tiles_pkey PRIMARY KEY (id);


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
-- Name: card_types card_types_card_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.card_types
    ADD CONSTRAINT card_types_card_set_id_fkey FOREIGN KEY (card_set_id) REFERENCES public.card_sets(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cards cards_card_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_card_type_id_fkey FOREIGN KEY (card_type_id) REFERENCES public.card_types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: citizens citizens_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.citizens
    ADD CONSTRAINT citizens_id_fkey FOREIGN KEY (id) REFERENCES public.cards(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: citizens citizens_id_species_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.citizens
    ADD CONSTRAINT citizens_id_species_id_fkey FOREIGN KEY (id, species_id) REFERENCES public.cards(id, card_type_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: citizens citizens_species_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.citizens
    ADD CONSTRAINT citizens_species_id_fkey FOREIGN KEY (species_id) REFERENCES public.species(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: field_citizens field_citizens_account_id_citizen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_citizens
    ADD CONSTRAINT field_citizens_account_id_citizen_id_fkey FOREIGN KEY (account_id, citizen_id) REFERENCES public.card_accounts(account_id, card_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: field_citizens field_citizens_account_id_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_citizens
    ADD CONSTRAINT field_citizens_account_id_field_id_fkey FOREIGN KEY (account_id, field_id) REFERENCES public.fields(account_id, id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: field_citizens field_citizens_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_citizens
    ADD CONSTRAINT field_citizens_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: field_citizens field_citizens_citizen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_citizens
    ADD CONSTRAINT field_citizens_citizen_id_fkey FOREIGN KEY (citizen_id) REFERENCES public.citizens(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: field_citizens field_citizens_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_citizens
    ADD CONSTRAINT field_citizens_field_id_fkey FOREIGN KEY (field_id) REFERENCES public.fields(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: field_tiles field_tiles_account_id_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_tiles
    ADD CONSTRAINT field_tiles_account_id_field_id_fkey FOREIGN KEY (account_id, field_id) REFERENCES public.fields(account_id, id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: field_tiles field_tiles_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_tiles
    ADD CONSTRAINT field_tiles_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: field_tiles field_tiles_account_id_tile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_tiles
    ADD CONSTRAINT field_tiles_account_id_tile_id_fkey FOREIGN KEY (account_id, tile_id) REFERENCES public.card_accounts(account_id, card_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: field_tiles field_tiles_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_tiles
    ADD CONSTRAINT field_tiles_field_id_fkey FOREIGN KEY (field_id) REFERENCES public.fields(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: field_tiles field_tiles_tile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_tiles
    ADD CONSTRAINT field_tiles_tile_id_fkey FOREIGN KEY (tile_id) REFERENCES public.tiles(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fields fields_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fields_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pack_banner_cards pack_banner_cards_card_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pack_banner_cards
    ADD CONSTRAINT pack_banner_cards_card_type_id_fkey FOREIGN KEY (card_type_id) REFERENCES public.card_types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pack_banner_cards pack_banner_cards_pack_banner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pack_banner_cards
    ADD CONSTRAINT pack_banner_cards_pack_banner_id_fkey FOREIGN KEY (pack_banner_id) REFERENCES public.pack_banners(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pack_contents pack_contents_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pack_contents
    ADD CONSTRAINT pack_contents_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.cards(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pack_contents pack_contents_pack_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pack_contents
    ADD CONSTRAINT pack_contents_pack_id_fkey FOREIGN KEY (pack_id) REFERENCES public.packs(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: packs packs_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packs
    ADD CONSTRAINT packs_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: packs packs_pack_banner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packs
    ADD CONSTRAINT packs_pack_banner_id_fkey FOREIGN KEY (pack_banner_id) REFERENCES public.pack_banners(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: species species_id_class_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species
    ADD CONSTRAINT species_id_class_fkey FOREIGN KEY (id, class) REFERENCES public.card_types(id, class) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: species species_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species
    ADD CONSTRAINT species_id_fkey FOREIGN KEY (id) REFERENCES public.card_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: species_needs species_needs_resource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species_needs
    ADD CONSTRAINT species_needs_resource_id_fkey FOREIGN KEY (resource_id) REFERENCES public.resources(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: species_needs species_needs_species_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species_needs
    ADD CONSTRAINT species_needs_species_id_fkey FOREIGN KEY (species_id) REFERENCES public.species(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tile_type_consumes tile_type_consumes_resource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tile_type_consumes
    ADD CONSTRAINT tile_type_consumes_resource_id_fkey FOREIGN KEY (resource_id) REFERENCES public.resources(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: tile_type_consumes tile_type_consumes_tile_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tile_type_consumes
    ADD CONSTRAINT tile_type_consumes_tile_type_id_fkey FOREIGN KEY (tile_type_id) REFERENCES public.tile_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tile_type_produces tile_type_produces_resource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tile_type_produces
    ADD CONSTRAINT tile_type_produces_resource_id_fkey FOREIGN KEY (resource_id) REFERENCES public.resources(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: tile_type_produces tile_type_produces_tile_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tile_type_produces
    ADD CONSTRAINT tile_type_produces_tile_type_id_fkey FOREIGN KEY (tile_type_id) REFERENCES public.tile_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tile_types tile_types_id_class_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tile_types
    ADD CONSTRAINT tile_types_id_class_fkey FOREIGN KEY (id, class) REFERENCES public.card_types(id, class) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: tile_types tile_types_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tile_types
    ADD CONSTRAINT tile_types_id_fkey FOREIGN KEY (id) REFERENCES public.card_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tiles tiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tiles
    ADD CONSTRAINT tiles_id_fkey FOREIGN KEY (id) REFERENCES public.cards(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tiles tiles_id_tile_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tiles
    ADD CONSTRAINT tiles_id_tile_type_id_fkey FOREIGN KEY (id, tile_type_id) REFERENCES public.cards(id, card_type_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tiles tiles_tile_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tiles
    ADD CONSTRAINT tiles_tile_type_id_fkey FOREIGN KEY (tile_type_id) REFERENCES public.tile_types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict aa4b4bc410c5cacbd97fc326d0f62806

