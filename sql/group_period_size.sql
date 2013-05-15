/* sample size by day of registration and experimental group */
select 
    uw_group as `group`,
    date(uw_registration) as `registration`,
    count(uw_user_id) as `size`
from
    giovanni.user_window
where
    uw_group <> 'historical'
group by
    uw_group, `registration`;


