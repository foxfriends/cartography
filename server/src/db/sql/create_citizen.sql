WITH
  cards_inserted AS (
    INSERT INTO
      cards (card_type_id)
    VALUES
      ($1)
    RETURNING
      *
  ),
  citizens_inserted AS (
    INSERT INTO
      citizens (id, species_id, name)
    SELECT
      card.id,
      card.card_type_id,
      ''
    FROM
      cards_inserted card
  )
INSERT INTO
  card_accounts (card_id, account_id)
SELECT
  card.id,
  $2
FROM
  cards_inserted card
RETURNING
  *;
