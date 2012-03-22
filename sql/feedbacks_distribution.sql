-- number of feedback posts by user
select count(*) from moodbar_feedback group by mbf_user_id;
