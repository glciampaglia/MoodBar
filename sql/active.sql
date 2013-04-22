/* Number of active users over account age (days since account creation) for the
 * three experimental groups. A user is considered active if he/she contributed
 * at least an edit on that specific day
 */
select 
    datediff(day, uw_registration) as age,
    uw_group as `group`,
    count(distinct uw_user_id) as `active`
from 
    giovanni.user_window
join
    enwiki.user_daily_contribs
on
    uw_user_id = user_id
group by
    age, uw_group;
