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

/* YEAR_MONTH of inception of MoodBar phase 3 */
SET @min_month=201112;

SELECT 
    ec.user_id,
    age,
    editcount,
    /* 0 = reference, 1 = sent feedback, 2 = sent feedback & received response,
     * 3 = sent feedback & received response & marked response as helpful
     */
    IF(
        mah_id IS NOT NULL, 
        3, 
        IF(
            mbfr_id IS NOT NULL, 
            2, 
            IF(
                MIN(mbf_id) IS NOT NULL, 
                1, 
                0
            )
        )
    ) AS treatment, 
    /* Cohort generation in number of months since beginning of MB phase 3 */
    PERIOD_DIFF(
        EXTRACT(YEAR_MONTH FROM ept_timestamp),
        @min_month
    ) as cohort,
    /* Time, in seconds, from account registration until first edit click */
    (UNIX_TIMESTAMP(ept_timestamp) 
        - UNIX_TIMESTAMP(user_registration)) AS ept_lag
FROM 
    edit_page_tracking 
JOIN
    user u
ON
    ept_user = u.user_id
JOIN 
    giovanni.editcount ec 
ON 
    ept_user = ec.user_id 
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
LEFT JOIN
    giovanni.bot_ext b
ON 
    ept_user = b.user_id
WHERE
    b.user_id IS NULL
GROUP BY
    ept_user,
    age;
