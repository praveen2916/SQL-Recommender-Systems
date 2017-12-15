CREATE TABLE reco_my_ratings ( 
    item_id NUMBER(4,0) PRIMARY KEY, 
    rating NUMBER(1,0));
    
INSERT INTO reco_my_ratings (item_id, rating) VALUES (100, 5);
INSERT INTO reco_my_ratings (item_id, rating) VALUES (69, 5);
INSERT INTO reco_my_ratings (item_id, rating) VALUES (257, 4);
INSERT INTO reco_my_ratings (item_id, rating) VALUES (28, 2);
INSERT INTO reco_my_ratings (item_id, rating) VALUES (64, 5);
INSERT INTO reco_my_ratings (item_id, rating) VALUES (156, 4);
INSERT INTO reco_my_ratings (item_id, rating) VALUES (202, 3);
INSERT INTO reco_my_ratings (item_id, rating) VALUES (79, 5);
INSERT INTO reco_my_ratings (item_id, rating) VALUES (127, 4);
INSERT INTO reco_my_ratings (item_id, rating) VALUES (480, 5);
INSERT INTO reco_my_ratings (item_id, rating) VALUES (657, 4);
INSERT INTO reco_my_ratings (item_id, rating) VALUES (498, 5);
INSERT INTO reco_my_ratings (item_id, rating) VALUES (22, 4);
INSERT INTO reco_my_ratings (item_id, rating) VALUES (313, 3);
INSERT INTO reco_my_ratings (item_id, rating) VALUES (302, 4);    
INSERT INTO reco_my_ratings (item_id, rating) VALUES (56, 5);    

SELECT rmr.item_id, rating, movie_title
FROM
    reco_my_ratings rmr
    INNER JOIN relmdb.ml_items itm
        ON rmr.item_id = itm.item_id;    

SELECT
    user_id,
    SUM((rating) * (rating)) AS norm 
FROM RELMDB.ML_RATINGS 
GROUP BY user_id;

SELECT SUM((rating) * (rating)) AS norm 
FROM reco_my_ratings;

SELECT
    user_id,
    SUM((rmr.rating) * (mlr.rating)) as dist 
FROM
    relmdb.ml_ratings mlr
    INNER JOIN reco_my_ratings rmr
        ON mlr.item_id = rmr.item_id 
GROUP BY user_id;

SELECT
    users.user_id,
    distances.dist / (SQRT(my.norm) * SQRT(users.norm)) AS score
FROM 
    (SELECT user_id, SUM((rmr.rating)*(mlr.rating)) AS dist 
    FROM
        relmdb.ml_ratings mlr
        INNER JOIN reco_my_ratings rmr
            ON mlr.item_id = rmr.item_id 
    GROUP BY user_id) distances
    INNER JOIN
    (SELECT user_id,
    SUM((rating)*(rating)) AS norm 
    FROM relmdb.ml_ratings 
    GROUP BY user_id) users
        ON distances.user_id = users.user_id
    CROSS JOIN
    (SELECT SUM((rating)*(rating)) AS norm 
    FROM reco_my_ratings) my
ORDER BY score DESC;

SELECT
    mlr.item_id,
    rmr.rating AS my_rating, 
    mlr.rating AS user_rating,
    movie_title 
FROM
    relmdb.ml_ratings mlr
    INNER JOIN reco_my_ratings rmr
        ON mlr.item_id = rmr.item_id
    INNER JOIN relmdb.ml_items mli
        ON mlr.item_id = mli.item_id
WHERE mlr.user_id = 416
ORDER by mlr.item_id;

CREATE TABLE reco_sim_users ( 
   user_id NUMBER(4,0) PRIMARY KEY, 
   score NUMBER);

INSERT INTO reco_sim_users (user_id, score)
SELECT
    users.user_id,
    distances.dist / (SQRT(my.norm) * SQRT(users.norm)) AS score
FROM 
    (SELECT user_id, SUM((rmr.rating)*(mlr.rating)) AS dist 
    FROM
        relmdb.ml_ratings mlr
        INNER JOIN reco_my_ratings rmr
            ON mlr.item_id = rmr.item_id 
    GROUP BY user_id) distances
    INNER JOIN
    (SELECT user_id,
    SUM((rating)*(rating)) AS norm 
    FROM relmdb.ml_ratings 
    GROUP BY user_id) users
        ON distances.user_id = users.user_id
    CROSS JOIN
    (SELECT SUM((rating)*(rating)) AS norm 
    FROM reco_my_ratings) my
ORDER BY score DESC
FETCH FIRST 20 ROWS ONLY;

SELECT
    mli.movie_title,
    ROUND(SUM(rating) / COUNT(*), 1) AS score
FROM
    reco_sim_users rsu
    INNER JOIN relmdb.ml_ratings mlr
        ON rsu.user_id = mlr.user_id
    INNER JOIN relmdb.ml_items mli
        ON mlr.item_id = mli.item_id
WHERE mlr.item_id NOT IN (
    SELECT item_id FROM reco_my_ratings)
GROUP BY mli.movie_title
HAVING COUNT(*) > 10
ORDER BY score DESC;
