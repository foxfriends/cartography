INSERT INTO resources (id)
VALUES
('bread'),
('flour'),
('grain'),
('water'),
('lettuce'),
('carrot'),
('tomato'),
('salad')
ON CONFLICT DO NOTHING;

INSERT INTO card_sets (id, release_date)
VALUES
('base', '2026-01-01T00:00:00Z')
ON CONFLICT (id) DO UPDATE
SET release_date = excluded.release_date;

INSERT INTO card_types (id, card_set_id, class)
VALUES
('rabbit', 'base', 'citizen'),
('cat', 'base', 'citizen'),
('bird', 'base', 'citizen'),
('cat-colony', 'base', 'tile'),
('rabbit-warren', 'base', 'tile'),
('bird-nest', 'base', 'tile'),
('water-well', 'base', 'tile'),
('carrot-farm', 'base', 'tile'),
('tomato-farm', 'base', 'tile'),
('lettuce-farm', 'base', 'tile'),
('grain-farm', 'base', 'tile'),
('flour-mill', 'base', 'tile'),
('bread-bakery', 'base', 'tile'),
('salad-shop', 'base', 'tile')
ON CONFLICT (id) DO UPDATE
SET class = excluded.class,
card_set_id = excluded.card_set_id;

INSERT INTO species (id)
VALUES
('rabbit'),
('cat'),
('bird')
ON CONFLICT DO NOTHING;

INSERT INTO pack_banners (id, start_date, end_date)
VALUES
('default', '2026-01-01T00:00:00Z', '2026-01-01T00:00:00Z'),
('base-standard', '2026-01-01T00:00:00Z', NULL),
('halloween-2026', '2026-10-01T00:00:00Z', '2026-10-31T23:59:59Z')
ON CONFLICT (id) DO UPDATE
SET start_date = excluded.start_date,
end_date = excluded.end_date;

INSERT INTO pack_banner_cards (pack_banner_id, card_type_id, frequency)
VALUES
('base-standard', 'cat-colony', 3),
('base-standard', 'rabbit-warren', 3),
('base-standard', 'bird-nest', 3),
('base-standard', 'water-well', 3),
('base-standard', 'carrot-farm', 3),
('base-standard', 'tomato-farm', 3),
('base-standard', 'lettuce-farm', 3),
('base-standard', 'grain-farm', 3),
('base-standard', 'flour-mill', 3),
('base-standard', 'bread-bakery', 3),
('base-standard', 'salad-shop', 3),
('base-standard', 'rabbit', 1),
('base-standard', 'cat', 1),
('base-standard', 'bird', 1)
ON CONFLICT (pack_banner_id, card_type_id) DO UPDATE
SET frequency = excluded.frequency;

INSERT INTO species_needs (species_id, resource_id, quantity)
VALUES
('rabbit', 'salad', 1),
('cat', 'bread', 1),
('bird', 'grain', 1)
ON CONFLICT (species_id, resource_id) DO UPDATE
SET quantity = excluded.quantity;

INSERT INTO tile_types (id, category, houses, employs)
VALUES
('cat-colony', 'residential', 3, 0),
('rabbit-warren', 'residential', 3, 0),
('bird-nest', 'residential', 3, 0),
('water-well', 'source', 0, 1),
('carrot-farm', 'production', 0, 3),
('tomato-farm', 'production', 0, 3),
('lettuce-farm', 'production', 0, 3),
('grain-farm', 'production', 0, 3),
('flour-mill', 'production', 0, 2),
('bread-bakery', 'amenity', 0, 2),
('salad-shop', 'amenity', 0, 2)
ON CONFLICT (id) DO UPDATE
SET category = excluded.category,
houses = excluded.houses,
employs = excluded.employs;

INSERT INTO tile_type_consumes (tile_type_id, resource_id, quantity)
VALUES
('flour-mill', 'grain', 1),
('bread-bakery', 'flour', 3),
('bread-bakery', 'water', 2),
('salad-shop', 'tomato', 1),
('salad-shop', 'lettuce', 1),
('salad-shop', 'carrot', 1)
ON CONFLICT (tile_type_id, resource_id) DO UPDATE
SET quantity = excluded.quantity;

INSERT INTO tile_type_produces (tile_type_id, resource_id, quantity)
VALUES
('water-well', 'water', 10),
('carrot-farm', 'carrot', 5),
('tomato-farm', 'tomato', 5),
('lettuce-farm', 'lettuce', 5),
('grain-farm', 'grain', 5),
('flour-mill', 'flour', 10),
('bread-bakery', 'bread', 5),
('salad-shop', 'salad', 3)
ON CONFLICT (tile_type_id, resource_id) DO UPDATE
SET quantity = excluded.quantity;
