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
    /* editcount on first day */
    ec.ec1 as Cd0_1,
    /* editcount on second day */
    ec.ec2 - ec.ec1 as Cd1_2,
    /* editcount on day 2 to day 5 */
    ec.ec5 - ec.ec2 as Cd2_5,
    /* editcount on day 5 to day 10 */
    ec.ec10 - ec.ec5 as Cd5_10,
    /* editcount on day 10 to day 30 */
    ec.ec30 - ec.ec10 as Cd10_30,
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

