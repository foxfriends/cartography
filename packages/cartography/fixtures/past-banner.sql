INSERT INTO card_sets (id, release_date)
VALUES ('past-banner-card-set', now() - '30 days'::interval);

INSERT INTO card_types (id, card_set_id, class)
VALUES ('past-banner-card', 'past-banner-card-set', 'tile');

INSERT INTO tile_types (id, category, houses, employs)
VALUES ('past-banner-card', 'residential', 3, 0);

INSERT INTO pack_banners (id, start_date, end_date)
VALUES ('past-banner', now() - '2 day'::interval, now() - '1 day'::interval);

INSERT INTO pack_banner_cards (pack_banner_id, card_type_id, frequency)
VALUES ('past-banner', 'past-banner-card', 1);
