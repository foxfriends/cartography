--! Previous: sha1:89a4b9a4f85f4098f1be0ec580b74d5fa4aff955
--! Hash: sha1:65dafe4a33434398472ab9d11d46b78520a1453c

ALTER TABLE fields
DROP COLUMN IF EXISTS width,
DROP COLUMN IF EXISTS height,
DROP COLUMN IF EXISTS grid_x,
DROP COLUMN IF EXISTS grid_y;

COMMENT ON TABLE fields IS 'Every card is played onto a field. An account may have multiple fields, but likely only has one.';
