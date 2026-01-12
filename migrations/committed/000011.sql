--! Previous: sha1:c1ad937fdc2f57ac1eadff2a5674149ec7bf2df7
--! Hash: sha1:e3cce54cd6700bd0c50cc621d6f39b57778a1b75

DROP TABLE IF EXISTS card_type_consumes;

DROP TABLE IF EXISTS card_type_produces;

DROP TABLE IF EXISTS tile_type_consumes;

DROP TABLE IF EXISTS tile_type_produces;

DROP TABLE IF EXISTS tiles CASCADE;

DROP TABLE IF EXISTS tile_types;

ALTER TABLE card_types
DROP COLUMN IF EXISTS class CASCADE;

ALTER TABLE species
DROP COLUMN IF EXISTS class CASCADE;

DROP TYPE IF EXISTS tile_category;

DROP TYPE IF EXISTS card_class;

CREATE TYPE card_class AS ENUM('tile', 'citizen');

CREATE TYPE tile_category AS ENUM(
  'residential',
  'production',
  'amenity',
  'source',
  'trade',
  'transportation'
);

ALTER TABLE card_types
DROP COLUMN IF EXISTS category,
DROP COLUMN IF EXISTS houses,
DROP COLUMN IF EXISTS employs;

ALTER TABLE card_types
ADD COLUMN IF NOT EXISTS class card_class NOT NULL DEFAULT 'tile';

ALTER TABLE card_types
ALTER COLUMN class
DROP DEFAULT;

ALTER TABLE card_types
DROP CONSTRAINT IF EXISTS card_types_id_class_key;

ALTER TABLE card_types
ADD CONSTRAINT card_types_id_class_key UNIQUE (id, class);

CREATE TABLE tile_types (
  id TEXT PRIMARY KEY REFERENCES card_types (id) ON DELETE CASCADE ON UPDATE CASCADE,
  class card_class NOT NULL GENERATED ALWAYS AS ('tile') STORED,
  category tile_category NOT NULL,
  houses INT NOT NULL,
  employs INT NOT NULL,
  FOREIGN KEY (id, class) REFERENCES card_types (id, class) ON DELETE CASCADE ON UPDATE RESTRICT
);

COMMENT ON TABLE tile_types IS 'Contains additional information about card types that correspond to tiles.';

ALTER TABLE species
DROP CONSTRAINT IF EXISTS species_id_fkey;

INSERT INTO
  card_types (id, card_set_id, class)
SELECT
  id,
  'default',
  'citizen'
FROM
  species
ON CONFLICT (id) DO UPDATE
SET
  class = EXCLUDED.class;

ALTER TABLE species
ADD FOREIGN KEY (id) REFERENCES card_types (id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE species
ADD COLUMN class card_class NOT NULL GENERATED ALWAYS AS ('citizen') STORED;

ALTER TABLE species
ADD FOREIGN KEY (id, class) REFERENCES card_types (id, class) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE cards
DROP CONSTRAINT IF EXISTS cards_id_card_type_id_key CASCADE;

ALTER TABLE cards
ADD CONSTRAINT cards_id_card_type_id_key UNIQUE (id, card_type_id);

CREATE TABLE tiles (
  id BIGINT PRIMARY KEY REFERENCES cards (id) ON DELETE CASCADE ON UPDATE CASCADE,
  tile_type_id TEXT NOT NULL REFERENCES tile_types (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  name TEXT NOT NULL CHECK (
    0 < length(name)
    AND length(name) <= 64
  ),
  FOREIGN KEY (id, tile_type_id) REFERENCES cards (id, card_type_id) ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON TABLE tiles IS 'Contains tile-specific information, corresponding to some card.';

ALTER TABLE citizens
DROP CONSTRAINT IF EXISTS citizens_id_species_id_fkey;

ALTER TABLE citizens
DROP COLUMN IF EXISTS id;

ALTER TABLE citizens
DROP COLUMN IF EXISTS card_id;

ALTER TABLE citizens
ADD COLUMN id BIGINT PRIMARY KEY REFERENCES cards (id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE citizens
ADD FOREIGN KEY (id, species_id) REFERENCES cards (id, card_type_id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE citizens
DROP COLUMN IF EXISTS account_id CASCADE;

COMMENT ON TABLE citizens IS 'Citizens that are loyal to a player. Citizens each correspond to some card.';

DROP TABLE IF EXISTS field_cards;

DROP TABLE IF EXISTS field_tiles;

CREATE TABLE field_tiles (
  tile_id BIGINT PRIMARY KEY REFERENCES tiles (id) ON DELETE CASCADE ON UPDATE CASCADE,
  account_id CITEXT NOT NULL REFERENCES accounts (id) ON DELETE CASCADE ON UPDATE CASCADE,
  field_id BIGINT NOT NULL REFERENCES fields (id) ON DELETE CASCADE ON UPDATE CASCADE,
  grid_x INTEGER NOT NULL,
  grid_y INTEGER NOT NULL,
  FOREIGN KEY (account_id, field_id) REFERENCES fields (account_id, id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (account_id, tile_id) REFERENCES card_accounts (account_id, card_id) ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON TABLE field_tiles IS 'Tile cards that have been played onto a field.';

ALTER TABLE citizens
ADD COLUMN IF NOT EXISTS home_tile_id BIGINT REFERENCES tiles (id) ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE tile_type_consumes (
  tile_type_id TEXT NOT NULL REFERENCES tile_types (id) ON DELETE CASCADE ON UPDATE CASCADE,
  resource_id TEXT NOT NULL REFERENCES resources (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  quantity INT NOT NULL CHECK (quantity > 0),
  PRIMARY KEY (tile_type_id, resource_id)
);

COMMENT ON TABLE tile_type_consumes IS 'The types of resources that are consumed by this tile type, to produce its outputs.';

CREATE TABLE tile_type_produces (
  tile_type_id TEXT NOT NULL REFERENCES tile_types (id) ON DELETE CASCADE ON UPDATE CASCADE,
  resource_id TEXT NOT NULL REFERENCES resources (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  quantity INT NOT NULL CHECK (quantity > 0),
  PRIMARY KEY (tile_type_id, resource_id)
);

COMMENT ON TABLE tile_type_produces IS 'The types of resources that are produced by this tile type, if all its inputs are satisfied.';

DROP TYPE IF EXISTS card_category;

COMMENT ON TABLE pack_contents IS 'Lists all cards that were part of each pack.';
