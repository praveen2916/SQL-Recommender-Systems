ALTER USER db239 IDENTIFIED BY "dusi2916";

SELECT * 
FROM relmdb.ml_items mli  
WHERE mli.movie_title like '%Pulp%';

Select * 
from reco_sim_users;

delete RECO_SIM_USERS;

select* 
from NORM_RATINGS;