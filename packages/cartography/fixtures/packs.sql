WITH inserted_packs AS (
    INSERT INTO packs (account_id, pack_banner_id, opened_at, seed, algorithm)
    VALUES
    ('foxfriends', 'base-standard', null, 1, 'constant'),
    ('foxfriends', 'base-standard', null, 2, 'constant'),
    ('foxfriends', 'base-standard', now(), 3, 'constant')
    RETURNING id, seed
),

pack_one_cards AS (
    INSERT INTO cards (card_type_id) VALUES ('bread-bakery'),
    ('salad-shop'),
    ('grain-farm'),
    ('cat-colony'),
    ('water-well')
    RETURNING *, 1 as seed
),

pack_two_cards AS (
    INSERT INTO cards (card_type_id) VALUES ('bread-bakery'),
    ('salad-shop'),
    ('grain-farm'),
    ('cat-colony'),
    ('water-well')
    RETURNING *, 2 as seed
),

pack_three_cards AS (
    INSERT INTO cards (card_type_id) VALUES ('bread-bakery'),
    ('salad-shop'),
    ('grain-farm'),
    ('cat-colony'),
    ('water-well')
    RETURNING *, 3 as seed
),

all_cards AS (
    SELECT * FROM pack_one_cards
    UNION ALL
    SELECT * FROM pack_two_cards
    UNION ALL
    SELECT * FROM pack_three_cards
),

inserted_tiles AS ( -- noqa: ST03
    INSERT INTO tiles (id, tile_type_id, name)
    SELECT id, card_type_id, card_type_id AS name
    FROM all_cards
)

INSERT INTO pack_contents (pack_id, card_id, "position")
SELECT
    inserted_packs.id AS pack_id,
    all_cards.id AS card_id,
    row_number() OVER (PARTITION BY inserted_packs.id) AS "position"
FROM inserted_packs
INNER JOIN all_cards ON inserted_packs.seed = all_cards.seed
