/* Retrieves a censored sample of times to first MoodBar post. By default, it
 * will retrieve a row for each user who posted at least a MoodBar feedback
 * (uncensored observation) plus a row for each censored observation. See the
 * WHERE and HAVING clauses for conditions that determine what constitutes a
 * censored observations.
 */
SELECT 
/*
    -- DEBUGGING STARTS HERE
    ept_timestamp,
    u.user_registration,
    MAX(day),
    -- DEBUGGING ENDS HERE
*/
    /* the user id */
    ept_user AS user_id,
    /* sad = 0, confused = 1, happy = 2; if -1, censored observation */
    IF(
        mbf_type IS NULL, 
        -1, 
        CASE mbf_type 
            WHEN 'sad' THEN 0 
            WHEN 'confused' THEN 1 
            WHEN 'happy' THEN 2 
        end
    ) AS mood_code, 
    /* self-explanatory ... */
    IF(mbf_type IS NULL, 0, 1) AS is_uncensored,
    /* time of first click on 'edit', in days since EPOCH */
    ROUND(UNIX_TIMESTAMP(ept_timestamp) / 86400.0, 4) AS first_edit_click, 
    /* end of observation window for censored observations, else time of first
     * mood feedback, in days since EPOCH */
    UNIX_TIMESTAMP(IFNULL(
            MIN(mbf_timestamp), 
            CONVERT(NOW() + 0, BINARY(14)))
    ) / 86400.0 AS first_feedback_or_now
FROM
    /* for each user ... */
    user u
STRAIGHT_JOIN
    /* ... who clicked the 'edit' button at least once ... */
    edit_page_tracking ept
ON
    u.user_id = ept.ept_user
LEFT JOIN
    /* ... lookup his contributions, if any (note the LEFT JOIN) ... */
    user_daily_contribs udc
ON
    u.user_id = udc.user_id
LEFT JOIN 
    /* ... lookup his feedbacks, if any (note the LEFT JOIN). */
    moodbar_feedback mbf
ON 
    u.user_id = mbf.mbf_user_id 
WHERE 
    /* The first record on moodbar_feedback is a test so it is fine to assume
     * its timestamp as the time of the deployment of MoodBar. This essentially
     * says to give me only users who clicked on 'EDIT' after the MoodBar was
     * actually deployed. */
    ept_timestamp > '20110725231036'
GROUP BY u.user_id
HAVING is_uncensored = 1 
    /* ... otherwise all users who have edited in the past 30 days (but did not
     * send any feedback) ... */
    OR MAX(day) > NOW() - INTERVAL 30 DAY 
    /* ... otherwise all users who registered in the past 5 days (but who either
     * did not send any feedback nor performed any edit). Note that the MAX() is
     * a dummy and it is essentially required to let this condition appear in
     * the having clause. Without the MAX(), it would be only possible to have
     * it in the WHERE clause. But the WHERE conditions are evaluated in
     * *conjunction* with the HAVING conditions, whereas we want this one to be
     * in disjunction with the two conditions above. */
    OR MAX(DATE(u.user_registration)) > NOW() - INTERVAL 5 DAY
/* select a random sample */
-- ORDER BY RAND()  
/* sample size */
lIMIT 10
