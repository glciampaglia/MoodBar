-- distribution of feedbacks per page
select
    count(mbf_id) as feedbacks_per_page 
from moodbar_feedback 
group by mbf_namespace, mbf_title
