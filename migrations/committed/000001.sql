--! Previous: -
--! Hash: sha1:65c958d9ec2c529c56698cb241fc16ceebe16092

CREATE EXTENSION IF NOT EXISTS "citext";

DROP TABLE IF EXISTS accounts CASCADE;

CREATE TABLE accounts (id VARCHAR(32) PRIMARY KEY);

CREATE UNIQUE INDEX accounts_id_case_insensitive ON accounts (lower(id));

COMMENT ON TABLE accounts IS 'Player/user accounts. Represents one person.';

DROP TABLE IF EXISTS card_types CASCADE;

DROP TYPE IF EXISTS card_category;

CREATE TYPE card_category AS ENUM ('residential', 'production', 'source', 'trade');

CREATE TABLE card_types (
  id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(64) NOT NULL,
  description TEXT NOT NULL,
  category card_category NOT NULL
);

COMMENT ON TABLE card_types IS 'Data representation of the types of cards available in the game. The implementation of most card functions is handled at runtime keyed off of the id.';

DROP TABLE IF EXISTS cards CASCADE;

CREATE TABLE cards (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  card_type_id VARCHAR(64) NOT NULL REFERENCES card_types (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

COMMENT ON TABLE cards IS 'Every instance of every card that exists in the game. Not all are necessarily owned by an account, as some may be in packs still waiting to be found/opened.';

DROP TABLE IF EXISTS card_accounts CASCADE;

CREATE TABLE card_accounts (
  card_id BIGINT PRIMARY KEY REFERENCES cards (id) ON DELETE CASCADE ON UPDATE CASCADE,
  account_id CITEXT NOT NULL REFERENCES accounts (id) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE (card_id, account_id)
);

COMMENT ON TABLE card_accounts IS 'Records owners of card. Each card has at most one owner at any time.';

CREATE INDEX IF NOT EXISTS card_accounts_account_id_index ON card_accounts (account_id);

DROP TABLE IF EXISTS fields CASCADE;

CREATE TABLE fields (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name VARCHAR(64) NOT NULL DEFAULT '',
  account_id CITEXT NOT NULL REFERENCES accounts (id) ON DELETE CASCADE ON UPDATE CASCADE,
  grid_x INT NOT NULL,
  grid_y INT NOT NULL,
  width INT NOT NULL GENERATED ALWAYS AS (8) STORED,
  height INT NOT NULL GENERATED ALWAYS AS (8) STORED,
  UNIQUE (id, account_id),
  UNIQUE (account_id, grid_x, grid_y)
);

COMMENT ON TABLE fields IS 'Every card is played onto a field. Each account has any number of fields arranged in an infinite space.';

DROP TABLE IF EXISTS field_cards CASCADE;

CREATE TABLE field_cards (
  card_id BIGINT PRIMARY KEY REFERENCES cards (id) ON DELETE CASCADE ON UPDATE CASCADE,
  account_id CITEXT NOT NULL REFERENCES accounts (id) ON DELETE CASCADE ON UPDATE CASCADE,
  field_id BIGINT NOT NULL REFERENCES fields (id) ON DELETE CASCADE ON UPDATE CASCADE,
  grid_x INT NOT NULL,
  grid_y INT NOT NULL,
  UNIQUE (field_id, card_id),
  UNIQUE (field_id, grid_x, grid_y),
  FOREIGN KEY (account_id, card_id) REFERENCES card_accounts (account_id, card_id),
  FOREIGN KEY (account_id, field_id) REFERENCES fields (account_id, id)
);

COMMENT ON TABLE field_cards IS 'Tracks the location of cards placed into fields.';
