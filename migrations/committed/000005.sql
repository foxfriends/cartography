--! Previous: sha1:bc62df145480bcf6395559dcc60d95fe473cff01
--! Hash: sha1:89a4b9a4f85f4098f1be0ec580b74d5fa4aff955

DROP POLICY IF EXISTS field_cards_public_read ON field_cards;

DROP POLICY IF EXISTS field_cards_owner_write ON field_cards;

ALTER TABLE field_cards DISABLE ROW LEVEL SECURITY;

DROP FUNCTION IF EXISTS current_account_id ();

DROP FUNCTION IF EXISTS is_current_account_id (VARCHAR(32));
