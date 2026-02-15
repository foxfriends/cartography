INSERT INTO pack_banners (id, start_date, end_date)
VALUES ('empty-banner', now() - '1 day'::interval, now() + '1 day'::interval);
