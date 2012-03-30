-- retrieves the full censored sample of times to first moodbar post
select 
    /* the user id */
    ept_user as user_id,
    /* if -1, censored observation; sad = 0, confused = 1, happy = 2 */
    if(
        mbf_type is NULL, 
        -1, 
        case mbf_type 
            when 'sad' then 0 
            when 'confused' then 1 
            when 'happy' then 2 
        end
    ) as obs_code, 
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
/* TODO remove if edit_page_tracking was deployed at the same time of MB */
-- where 
--    user_id >= 15013111 
group by ept_user
/* select a random sample */
order by rand()  
/* sample size */
limit 10000
