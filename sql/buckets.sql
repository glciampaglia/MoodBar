/* testing best MoodBar link text */
select 
    date(mbf_timestamp) as date,
    count(mbf_id) as num_clicks,
    sum(if(mbf_bucket = 'feedback', 1, 0)) as num_feedback,
    sum(if(mbf_bucket = 'editing', 1, 0)) as num_editing, 
    sum(if(mbf_bucket = 'share', 1, 0)) as num_share 
from 
    moodbar_feedback 
group by 
    date(mbf_timestamp);
