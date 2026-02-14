--! Previous: sha1:e1df9dc29a55d976f7f130d613fc1ba172e2df1b
--! Hash: sha1:2aab3a026b4d550dd38394a42fbb742817b3eae0

ALTER TABLE packs DROP COLUMN IF EXISTS seed, DROP COLUMN IF EXISTS algorithm;
ALTER TABLE packs ADD COLUMN seed BIGINT NOT NULL, ADD COLUMN algorithm TEXT NOT NULL;

COMMENT ON COLUMN packs.seed IS 'The u64 seed used to generate this pack. It is cast to i64 and stored here; interpret as raw bytes not meaningful number.';
COMMENT ON COLUMN packs.algorithm IS 'The seedable random number generation algorithm used to generate this pack.';

ALTER TABLE pack_banners DROP COLUMN IF EXISTS pack_size;
ALTER TABLE pack_banners ADD COLUMN pack_size INT NOT NULL DEFAULT 5;
