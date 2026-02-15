INSERT INTO card_sets (id, release_date)
VALUES ('future-banner-card-set', now() - '30 days'::interval);

INSERT INTO card_types (id, card_set_id, class)
VALUES ('future-banner-card', 'future-banner-card-set', 'tile');

INSERT INTO tile_types (id, category, houses, employs)
VALUES ('future-banner-card', 'residential', 3, 0);

INSERT INTO pack_banners (id, start_date, end_date)
VALUES ('future-banner', now() + '1 day'::interval, now() + '2 day'::interval);

INSERT INTO pack_banner_cards (pack_banner_id, card_type_id, frequency)
VALUES ('future-banner', 'future-banner-card', 1);
