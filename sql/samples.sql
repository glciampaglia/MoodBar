/* compute sample size and size of each treatment group */

/* Needed to get index access on mah_item */
CREATE TEMPORARY TABLE IF NOT EXISTS
    giovanni.mark_as_helpful 
    (
        mah_id int primary key, 
        mah_item int,
        constraint foreign key mbfr_item (mah_item) references moodbar_feedback_response (mbfr_id)
    ) 
    SELECT 
        mah_id,
        mah_item
    FROM 
        mark_as_helpful;

SET @treatment_start_date='20120523140000';
SET @treatment_stop_date='20120613000000';
SET @control_start_date='20120614000000';
SET @control_stop_date='20120629000000';

/* Treatment sample size */
SELECT
    DATE(@treatment_start_date) as start_date,
    DATE(@treatment_stop_date) as stop_date,
    DATEDIFF(@treatment_stop_date, @treatment_start_date) as days,
    /* total number of moodbar activations */
    COUNT(ept_user) AS nr_reference,
    /* total number of users who sent a feedback */
    COUNT(DISTINCT mbf_user_id) AS nr_feedback,
    /* total number of users who received at least one response */
    COUNT(DISTINCT mbfr_mbf_id) AS nr_response,
    /* total number of users who marked at least on response as useful */
    COUNT(DISTINCT mah_item) AS nr_useful
FROM
    user
JOIN
    edit_page_tracking
ON
    user_id = ept_user
LEFT JOIN
    moodbar_feedback
ON
    ept_user = mbf_user_id
LEFT JOIN
    moodbar_feedback_response
ON
    mbf_id = mbfr_mbf_id
LEFT JOIN
    giovanni.mark_as_helpful
ON
    mbfr_id = mah_item 
WHERE
    user_registration >= @treatment_start_date
AND
    user_registration < @treatment_stop_date

UNION

SELECT 
    DATE(@control_start_date) as start_date,
    DATE(@control_stop_date) as stop_date,
    DATEDIFF(@control_stop_date, @control_start_date) as days,
    count(ept_user) AS nr_reference,
    'N/A' as nr_feedback,
    'N/A' as nr_response,
    'N/A' as nr_useful
FROM
    user
JOIN
    edit_page_tracking
ON
    user_id = ept_user
WHERE
    user_registration >= @control_start_date
AND
    user_registration <= @control_stop_date;
