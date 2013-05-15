select 
    user_id as `user`,
    datediff(day, uw_registration) as age,
    uw_group as `group`,
    date(day) as `date`,
    contribs
from 
    giovanni.user_window
join
    enwiki.user_daily_contribs
on
    uw_user_id = user_id
where
    uw_group in ('treatment', 'control')
order by
    user_id, age;
