CREATE
OR REPLACE FUNCTION is_current_account_id (account_id VARCHAR(32)) RETURNS boolean AS $$
  SELECT current_account_id() IS NULL OR current_account_id() = account_id;
$$ LANGUAGE SQL STABLE;
