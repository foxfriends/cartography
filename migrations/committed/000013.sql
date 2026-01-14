--! Previous: sha1:88d84bf5c81b47ff8aadf93f93569e2d9a478495
--! Hash: sha1:6899eea812121a36fcdc877f6c5c8111b43e6fd7

DROP TABLE IF EXISTS pack_banner_cards;

CREATE TABLE pack_banner_cards (
  pack_banner_id TEXT NOT NULL REFERENCES pack_banners (id) ON DELETE CASCADE ON UPDATE CASCADE,
  card_type_id TEXT NOT NULL REFERENCES card_types (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  frequency INT NOT NULL CHECK (frequency > 0),
  PRIMARY KEY (pack_banner_id, card_type_id)
);

COMMENT ON TABLE pack_banner_cards IS 'Lists relative frequencies of cards available to be pulled from each banner.';

-- Extraneous index after changing type to CITEXT
DROP INDEX IF EXISTS accounts_id_case_insensitive;
