--! Previous: sha1:c8526edc66dd8055553ca1582b30383d43183b71
--! Hash: sha1:377073ebca8a3c79b8e666c4cb005a8b375dd82a

-- I did not do the checks well in the last migration.
ALTER TABLE accounts
DROP CONSTRAINT IF EXISTS accounts_id_check;

ALTER TABLE accounts
ADD CONSTRAINT accounts_id_check CHECK (
  0 < length(id)
  AND length(id) <= 64
);

ALTER TABLE card_types
DROP CONSTRAINT IF EXISTS card_types_id_check;

ALTER TABLE card_types
ADD CONSTRAINT card_types_id_check CHECK (
  0 < length(id)
  AND length(id) <= 64
);

ALTER TABLE fields
DROP CONSTRAINT IF EXISTS fields_name_check;

ALTER TABLE fields
ADD CONSTRAINT fields_name_check CHECK (
  0 < length(name)
  AND length(name) <= 64
);

-- Removing these in favour of using localization files based on the ids.
ALTER TABLE card_types
DROP COLUMN IF EXISTS name,
DROP COLUMN IF EXISTS description;

-- Then here's the tables that implement the gameplay concerns.
DROP TABLE IF EXISTS citizens;

DROP TABLE IF EXISTS card_type_consumes;

DROP TABLE IF EXISTS card_type_produces;

DROP TABLE IF EXISTS card_type_houses;

DROP TABLE IF EXISTS card_type_employs;

DROP TABLE IF EXISTS species_needs;

DROP TABLE IF EXISTS species;

DROP TABLE IF EXISTS resources;

CREATE TABLE species (
  id TEXT PRIMARY KEY CHECK (
    0 < length(id)
    AND length(id) <= 64
  )
);

COMMENT ON TABLE species IS 'Definitions of all species of citizen that exist in the game.';

CREATE TABLE resources (
  id TEXT PRIMARY KEY CHECK (
    0 < length(id)
    AND length(id) <= 64
  )
);

COMMENT ON TABLE resources IS 'Definitions of all types of resources that exist in the game.';

CREATE TABLE species_needs (
  species_id TEXT NOT NULL REFERENCES species (id) ON DELETE CASCADE ON UPDATE CASCADE,
  resource_id TEXT NOT NULL REFERENCES resources (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  quantity INT NOT NULL CHECK (quantity > 0),
  PRIMARY KEY (species_id, resource_id)
);

COMMENT ON TABLE species_needs IS 'The types of resources that this species needs to consume per day in order to be satisfied.';

CREATE TABLE card_type_consumes (
  card_type_id TEXT NOT NULL REFERENCES card_types (id) ON DELETE CASCADE ON UPDATE CASCADE,
  resource_id TEXT NOT NULL REFERENCES resources (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  quantity INT NOT NULL CHECK (quantity > 0),
  PRIMARY KEY (card_type_id, resource_id)
);

COMMENT ON TABLE card_type_consumes IS 'The types of resources that are consumed by this card type, to produce its outputs.';

CREATE TABLE card_type_produces (
  card_type_id TEXT NOT NULL REFERENCES card_types (id) ON DELETE CASCADE ON UPDATE CASCADE,
  resource_id TEXT NOT NULL REFERENCES resources (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  quantity INT NOT NULL CHECK (quantity > 0),
  PRIMARY KEY (card_type_id, resource_id)
);

COMMENT ON TABLE card_type_produces IS 'The types of resources that are produced by this card type, if all its inputs are satisfied.';

CREATE TABLE card_type_houses (
  card_type_id TEXT NOT NULL REFERENCES card_types (id) ON DELETE CASCADE ON UPDATE CASCADE,
  species_id TEXT REFERENCES species (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  quantity INT NOT NULL CHECK (quantity > 0),
  PRIMARY KEY (card_type_id, species_id)
);

COMMENT ON TABLE card_type_houses IS 'The types of citizens that this card type provides homes for.';

CREATE TABLE card_type_employs (
  card_type_id TEXT NOT NULL REFERENCES card_types (id) ON DELETE CASCADE ON UPDATE CASCADE,
  species_id TEXT REFERENCES species (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  quantity INT NOT NULL CHECK (quantity > 0),
  PRIMARY KEY (card_type_id, species_id)
);

COMMENT ON TABLE card_type_employs IS 'The types of citizens that can work at this card type.';

CREATE TABLE citizens (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  account_id CITEXT NOT NULL REFERENCES accounts (id) ON DELETE CASCADE ON UPDATE CASCADE,
  species_id TEXT NOT NULL REFERENCES species (id) ON DELETE CASCADE ON UPDATE CASCADE,
  card_id BIGINT REFERENCES cards (id) ON DELETE CASCADE ON UPDATE CASCADE,
  name TEXT NOT NULL CHECK (
    0 < length(name)
    AND length(name) < 64
  )
);

COMMENT ON TABLE citizens IS 'Citizens that are loyal to a player. These citizens may or may not be currently housed.';

ALTER TYPE card_category
ADD VALUE IF NOT EXISTS 'transportation'
AFTER 'trade';

ALTER TYPE card_category
ADD VALUE IF NOT EXISTS 'amenity'
AFTER 'production';
