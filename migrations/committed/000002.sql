--! Previous: sha1:65c958d9ec2c529c56698cb241fc16ceebe16092
--! Hash: sha1:d53067e5e81447b0a8a73fa6f4f7961b16ed6175

CREATE
OR REPLACE FUNCTION current_account_id () RETURNS VARCHAR(32) AS $$
  SELECT cast(nullif(current_setting('current_account_id'), '') AS VARCHAR(32));
$$ LANGUAGE SQL STABLE;

CREATE
OR REPLACE FUNCTION is_current_account_id (account_id VARCHAR(32)) RETURNS boolean AS $$
  SELECT current_account_id() IS NULL OR current_account_id() = account_id;
$$ LANGUAGE SQL STABLE;

ALTER TABLE field_cards ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS field_cards_public_read ON field_cards;

DROP POLICY IF EXISTS field_cards_owner_write ON field_cards;

ALTER TABLE card_accounts
ALTER COLUMN account_id
SET DATA TYPE VARCHAR(32);

ALTER TABLE fields
ALTER COLUMN account_id
SET DATA TYPE VARCHAR(32);

ALTER TABLE field_cards
ALTER COLUMN account_id
SET DATA TYPE VARCHAR(32);

CREATE POLICY field_cards_public_read ON field_cards FOR
SELECT
  USING (true);

CREATE POLICY field_cards_owner_write ON field_cards FOR
SELECT
  USING (is_current_account_id (field_cards.account_id));
