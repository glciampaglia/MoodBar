-- retrieves the full censored sample of times to first moodbar post
select 
    user_id, 
    mbf_type,  -- if NULL, censored observation
    unix_timestamp(user_registration) / 86400.0 as user_registration, -- days since EPOCH
    unix_timestamp(ifnull(min(mbf_timestamp), cast(now()+0 as binary(14)))) as first_feedback_or_now
from 
    user left join moodbar_feedback 
on mbf_user_id = user_id 
where 
    user_id >= 2539476  -- obtained from select min(mbf_user_id)) from moodbar_feedback
group by user_id 
order by rand()  -- select a random sample
limit 1000       -- sample size
