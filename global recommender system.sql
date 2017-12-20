/* GENERAL RECOMMENDER SYSTEM */

/* The query below uses the main ratings table (ML_RATINGS) to count users, items and the actual ratings.  
We can also count the number of users (ML_USERS) and movies (ML_ITEMS) in the other tables, but we are more interested 
in the participation in the ratings. */

SELECT
    COUNT(DISTINCT user_id) AS user_tally,
    COUNT(DISTINCT item_id) AS item_tally,
    COUNT(*) AS rating_tally
FROM relmdb.ml_ratings;

/* The query below outputs the no. of ratings (rating_tally) he/she rated.  The minimum number of ratings per user is 20 
set by movielens 100k (1998) dataset */

SELECT
    user_id,
    COUNT(item_id) as rating_tally
FROM relmdb.ml_ratings 
GROUP BY user_id
ORDER BY COUNT(item_id) DESC;

/*This query returns a histogram based on the number of ratings (rounded to multiples of 10) by users, 
which gives us a much better idea about the distribution of ratings.There are plenty of users with significant 
numbers of ratings. */

SELECT
    rating_bin,
    COUNT(user_id) AS user_tally
FROM (
    SELECT
        user_id,
        ROUND(COUNT(item_id), -1) as rating_bin
    FROM relmdb.ml_ratings 
    GROUP BY user_id)
GROUP BY rating_bin
ORDER BY rating_bin;

SELECT
    rating_bin,
    COUNT(item_id) AS item_tally
FROM (
    SELECT
        item_id,
        ROUND(COUNT(user_id), -1) AS rating_bin
    FROM relmdb.ml_ratings
    GROUP BY item_id)
GROUP BY rating_bin
ORDER BY rating_bin;

SELECT AVG(rating) AS avg_rating
FROM relmdb.ml_ratings;

SELECT
    rating,
    COUNT(*) AS rating_tally
FROM relmdb.ml_ratings
GROUP BY rating
ORDER BY rating DESC;

SELECT
    rating_bin,
    COUNT(user_id) AS user_tally
FROM (
    SELECT ROUND(AVG(rating), 1) AS rating_bin, user_id
    FROM relmdb.ml_ratings
    GROUP BY user_id)
GROUP BY rating_bin
ORDER BY rating_bin DESC;

SELECT
    rating_bin,
    COUNT(item_id) AS item_tally
FROM (
    SELECT ROUND(AVG(rating), 1) AS rating_bin, item_id
    FROM relmdb.ml_ratings
    GROUP BY item_id)
GROUP BY rating_bin
ORDER BY rating_bin DESC;

SELECT
    ROUND(AVG(rating), 1) AS avg_rating, 
    COUNT(user_id) AS rating_tally,
    movie_title 
FROM
    relmdb.ml_ratings mr
    INNER JOIN relmdb.ml_items mi
        ON mr.item_id = mi.item_id
GROUP BY movie_title
HAVING COUNT(user_id) > 10 
ORDER BY avg_rating  DESC
FETCH FIRST 10 ROWS ONLY;
