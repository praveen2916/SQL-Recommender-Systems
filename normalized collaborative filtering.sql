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
    SUM((norm_rating) * (norm_rating)) AS norm 
FROM NORM_RATINGS 
GROUP BY user_id;

SELECT SUM((rating) * (rating)) AS norm 
FROM reco_my_ratings;

SELECT
    user_id,
    SUM((rmr.rating) * (nmlr.rating)) as dist 
FROM
    norm_ratings nmlr
    INNER JOIN reco_my_ratings rmr
        ON nmlr.item_id = rmr.item_id 
GROUP BY user_id;

SELECT
    users.user_id,
    distances.dist / (SQRT(my.norm) * SQRT(users.norm)) AS score
FROM 
    (SELECT user_id, SUM((rmr.rating)*(nmlr.rating)) AS dist 
    FROM
        norm_ratings nmlr
        INNER JOIN reco_my_ratings rmr
            ON nmlr.item_id = rmr.item_id 
    GROUP BY user_id) distances
    INNER JOIN
    (SELECT user_id,
    SUM((norm_rating)*(norm_rating)) AS norm 
    FROM norm_ratings 
    GROUP BY user_id) users
        ON distances.user_id = users.user_id
    CROSS JOIN
    (SELECT SUM((rating)*(rating)) AS norm 
    FROM reco_my_ratings) my
ORDER BY score DESC;

SELECT
    nmlr.item_id,
    rmr.rating AS my_rating, 
    nmlr.rating AS user_norm_rating,
    movie_title 
FROM
    norm_ratings nmlr
    INNER JOIN reco_my_ratings rmr
        ON nmlr.item_id = rmr.item_id
    INNER JOIN relmdb.ml_items mli
        ON nmlr.item_id = mli.item_id
WHERE nmlr.user_id = 10
ORDER by nmlr.item_id;

CREATE TABLE reco_sim_norm_users ( 
   user_id NUMBER(4,0) PRIMARY KEY, 
   score NUMBER);

INSERT INTO reco_sim_norm_users (user_id, score)
SELECT
    users.user_id,
    distances.dist / (SQRT(my.norm) * SQRT(users.norm)) AS score
FROM 
    (SELECT user_id, SUM((rmr.rating)*(nmlr.rating)) AS dist 
    FROM
        norm_ratings nmlr
        INNER JOIN reco_my_ratings rmr
            ON nmlr.item_id = rmr.item_id 
    GROUP BY user_id) distances
    INNER JOIN
    (SELECT user_id,
    SUM((norm_rating)*(norm_rating)) AS norm 
    FROM norm_ratings 
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
    reco_sim_norm_users rsnu
    INNER JOIN norm_ratings nmlr
        ON rsnu.user_id = nmlr.user_id
    INNER JOIN relmdb.ml_items mli
        ON nmlr.item_id = mli.item_id
WHERE nmlr.item_id NOT IN (
    SELECT item_id FROM reco_my_ratings)
GROUP BY mli.movie_title
HAVING COUNT(*) > 10
ORDER BY score DESC;
