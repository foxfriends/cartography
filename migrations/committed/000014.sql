--! Previous: sha1:6899eea812121a36fcdc877f6c5c8111b43e6fd7
--! Hash: sha1:e1df9dc29a55d976f7f130d613fc1ba172e2df1b

DROP TABLE IF EXISTS field_citizens;

CREATE TABLE field_citizens (
  citizen_id BIGINT PRIMARY KEY REFERENCES citizens (id) ON DELETE CASCADE ON UPDATE CASCADE,
  account_id CITEXT NOT NULL REFERENCES accounts (id) ON DELETE CASCADE ON UPDATE CASCADE,
  field_id BIGINT NOT NULL REFERENCES fields (id) ON DELETE CASCADE ON UPDATE CASCADE,
  grid_x INTEGER NOT NULL,
  grid_y INTEGER NOT NULL,
  FOREIGN KEY (account_id, field_id) REFERENCES fields (account_id, id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (account_id, citizen_id) REFERENCES card_accounts (account_id, card_id) ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON TABLE field_citizens IS 'Tracks the state of citizens currently deployed on the field.';
