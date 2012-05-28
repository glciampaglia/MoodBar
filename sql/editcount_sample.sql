CREATE TEMPORARY TABLE IF NOT EXISTS
    giovanni.mark_as_helpful 
    (
        mah_id int primary key, 
        mah_item int,
        constraint foreign key mbfr_item (mah_item) references moodbar_feedback_response (mbf_id)
    ) 
    SELECT 
        mah_id,
        mah_item
    FROM 
        mark_as_helpful;

SELECT 
    /* edit counts are transformed into rates so they share the same offset in
     * the regression
     */
    ec.ec1 as Rd0_1,
    ec.ec2 - ec.ec1 as Rd1_2,
    ec.ec5 - ec.ec2 / 3 as Rd2_5,
    ec.ec10 - ec.ec5 / 5 as Rd5_10,
    ec.ec30 - ec.ec10 / 20 as Rd10_30,
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
                mbf_id IS NOT NULL, 
                1, 
                0
            )
        )
    ) AS treatment, 
    /* Indicates the cohort */
    DATE_FORMAT(ept_timestamp, '%Y-%m-01') AS generation
FROM 
    edit_page_tracking 
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
AND
    /* select users who either sent no feedback, or those who sent a feedback
     * after the first day of activity
     */
   IFNULL(DATEDIFF(mbf_timestamp, ept_timestamp) > 0, 1)

