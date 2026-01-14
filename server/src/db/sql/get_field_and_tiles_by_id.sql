SELECT
  to_json(fields.*) AS field,
  json_arrayagg (field_tiles.* ABSENT ON NULL) AS field_tiles
FROM
  fields
  LEFT JOIN field_tiles ON field_tiles.field_id = fields.id
WHERE
  fields.id = $1
GROUP BY
  fields.id
