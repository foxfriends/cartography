CREATE
OR REPLACE FUNCTION current_account_id () RETURNS VARCHAR(32) AS $$
  SELECT cast(nullif(current_setting('current_account_id'), '') AS VARCHAR(32));
$$ LANGUAGE SQL STABLE;
