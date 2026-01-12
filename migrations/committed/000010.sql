--! Previous: sha1:1c30308291350d7cfd97991f95730e8139f16355
--! Hash: sha1:c1ad937fdc2f57ac1eadff2a5674149ec7bf2df7

ALTER TABLE card_types
DROP COLUMN IF EXISTS card_set_id;

DROP TABLE IF EXISTS pack_contents;

DROP TABLE IF EXISTS packs;

DROP TABLE IF EXISTS card_sets;

DROP TABLE IF EXISTS pack_banners;

CREATE TABLE card_sets (
  id TEXT PRIMARY KEY CHECK (
    0 < length(id)
    AND length(id) <= 64
  ),
  release_date TIMESTAMP WITH TIME ZONE NOT NULL
);

COMMENT ON TABLE card_sets IS 'Every card is initially released as part of some card set, which can be used for collectors to organize their collections.';

INSERT INTO
  card_sets (id, release_date)
VALUES
  ('default', now());

ALTER TABLE card_types
ADD COLUMN card_set_id TEXT NOT NULL DEFAULT 'default' REFERENCES card_sets (id) ON DELETE RESTRICT ON UPDATE CASCADE;

DELETE FROM card_sets
WHERE
  NOT EXISTS (
    SELECT
      1
    FROM
      card_types
    WHERE
      card_set_id = card_sets.id
  );

CREATE TABLE pack_banners (
  id TEXT PRIMARY KEY CHECK (
    0 < length(id)
    AND length(id) <= 64
  ),
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE
);

COMMENT ON TABLE pack_banners IS 'Every pack that is opened is created using the template of some pack banner.';

CREATE TABLE packs (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  account_id CITEXT NOT NULL REFERENCES accounts (id) ON DELETE CASCADE ON UPDATE CASCADE,
  pack_banner_id TEXT NOT NULL REFERENCES pack_banners (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  opened_at TIMESTAMP WITH TIME ZONE
);

COMMENT ON TABLE packs IS 'A historical record of all packs opened by an account.';

CREATE TABLE pack_contents (
  pack_id BIGINT NOT NULL REFERENCES packs (id) ON DELETE CASCADE ON UPDATE CASCADE,
  position INT NOT NULL,
  card_id BIGINT NOT NULL REFERENCES cards (id) ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY (pack_id, position)
);

ALTER TYPE card_category
ADD VALUE IF NOT EXISTS 'citizen'
AFTER 'transportation';

ALTER TABLE citizens
ALTER COLUMN card_id
SET NOT NULL;

ALTER TABLE citizens
DROP CONSTRAINT IF EXISTS citizens_account_id_card_id_fkey;

ALTER TABLE citizens
ADD FOREIGN KEY (account_id, card_id) REFERENCES card_accounts (account_id, card_id) ON DELETE CASCADE ON UPDATE CASCADE;
