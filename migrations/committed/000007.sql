--! Previous: sha1:65dafe4a33434398472ab9d11d46b78520a1453c
--! Hash: sha1:c8526edc66dd8055553ca1582b30383d43183b71

-- Doing some major data renovations, to some preferences I have taken on since leaving this project.
ALTER TABLE card_accounts
DROP CONSTRAINT IF EXISTS card_accounts_account_id_fkey;

ALTER TABLE fields
DROP CONSTRAINT IF EXISTS fields_account_id_fkey;

ALTER TABLE field_cards
DROP CONSTRAINT IF EXISTS field_cards_account_id_fkey;

ALTER TABLE field_cards
DROP CONSTRAINT IF EXISTS field_cards_account_id_card_id_fkey;

ALTER TABLE field_cards
DROP CONSTRAINT IF EXISTS field_cards_account_id_field_id_fkey;

ALTER TABLE accounts
ALTER COLUMN id
SET DATA TYPE CITEXT;

ALTER TABLE card_accounts
ALTER COLUMN account_id
SET DATA TYPE CITEXT;

ALTER TABLE fields
ALTER COLUMN account_id
SET DATA TYPE CITEXT;

ALTER TABLE field_cards
ALTER COLUMN account_id
SET DATA TYPE CITEXT;

ALTER TABLE accounts
DROP CONSTRAINT IF EXISTS accounts_id_check;

ALTER TABLE accounts
ADD CONSTRAINT accounts_id_check CHECK (length(id) <= 64);

ALTER TABLE card_accounts
ADD FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE fields
ADD FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE field_cards
ADD FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE field_cards
ADD FOREIGN KEY (account_id, card_id) REFERENCES card_accounts (account_id, card_id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE field_cards
ADD FOREIGN KEY (account_id, field_id) REFERENCES fields (account_id, id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE card_types
ALTER COLUMN id
SET DATA TYPE TEXT;

ALTER TABLE card_types
ALTER COLUMN name
SET DATA TYPE TEXT;

ALTER TABLE card_types
DROP CONSTRAINT IF EXISTS card_types_id_check;

ALTER TABLE card_types
DROP CONSTRAINT IF EXISTS card_types_name_check;

ALTER TABLE card_types
ADD CONSTRAINT card_types_id_check CHECK (length(id) <= 64);

ALTER TABLE card_types
ADD CONSTRAINT card_types_name_check CHECK (length(name) <= 64);

ALTER TABLE cards
ALTER COLUMN card_type_id
SET DATA TYPE TEXT;

ALTER TABLE fields
DROP CONSTRAINT IF EXISTS fields_name_check;

ALTER TABLE fields
ADD CONSTRAINT fields_name_check CHECK (length(name) <= 64);

ALTER TABLE fields
ALTER COLUMN name
SET DATA TYPE TEXT;

ALTER TABLE fields
ALTER COLUMN name
DROP DEFAULT;
