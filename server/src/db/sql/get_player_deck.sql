SELECT
  cards.id as id,
  coalesce(tiles.name, citizens.name) as name,
  tiles.tile_type_id,
  citizens.species_id,
  citizens.home_tile_id
FROM
  cards
  INNER JOIN card_accounts ON card_accounts.card_id = cards.id
  LEFT OUTER JOIN citizens ON cards.id = citizens.id
  LEFT OUTER JOIN tiles ON cards.id = tiles.id
WHERE
  card_accounts.account_id = $1;
