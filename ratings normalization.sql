SELECT
  user_id,
  AVG(rating) AS avg_rating,
  COUNT(*) AS rating_tally
FROM relmdb.ml_ratings
GROUP BY user_id
ORDER BY user_id;

CREATE TABLE norm_ratings AS
SELECT
  ir.user_id,
  item_id,
  rating,
  rating - avg_rating AS norm_rating,
  rating_tstamp
FROM
  (SELECT user_id, item_id, rating, rating_tstamp
  FROM relmdb.ml_ratings) ir
  INNER JOIN
  (SELECT user_id, AVG(rating) AS avg_rating
  FROM relmdb.ml_ratings
  GROUP BY user_id) ar
    ON ir.user_id = ar.user_id;