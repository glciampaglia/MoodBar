/* Time to first feedback of users with 0 edits, without censored observations
 * */
SELECT 
    (MIN(UNIX_TIMESTAMP(mbf_timestamp)) - 
        UNIX_TIMESTAMP(ept_timestamp)) / 86400.0 as ttfeedback
FROM 
    moodbar_feedback JOIN edit_page_tracking 
ON mbf_user_id = ept_user 
WHERE
    mbf_user_editcount = 0
GROUP BY ept_user;
