-- retrieves the full censored sample of times to first moodbar post
select 
    /* the user id */
    ept_user as user_id,
    /* sad = 0, confused = 1, happy = 2; if -1, censored observation */
    if(
        mbf_type is NULL, 
        -1, 
        case mbf_type 
            when 'sad' then 0 
            when 'confused' then 1 
            when 'happy' then 2 
        end
    ) as mood_code, 
    /* self-explanatory ... */
    if(mbf_type is NULL, 0, 1) as is_uncensored,
    /* time of first click on 'edit', in days since EPOCH */
    unix_timestamp(ept_timestamp) / 86400.0 as first_edit_click, 
    /* end of observation window for censored observations, else time of first
     * mood feedback, in days since EPOCH */
    unix_timestamp(ifnull(
            min(mbf_timestamp), 
            cast(now()+0 as binary(14)))
    ) / 86400.0 as first_feedback_or_censored 
from 
    edit_page_tracking left join moodbar_feedback
on ept_user = mbf_user_id 
where 
    /* the first record on moodbar_feedback is a test so it is fine to assume
     * its timestamp as the time of the deployment of MoodBar */
    ept_timestamp > '20110725231036'
group by ept_user
/* select a random sample */
order by rand()  
/* sample size */
limit 10000
