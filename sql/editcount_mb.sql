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

/* YEAR_MONTH of inception of MoodBar phase 3 */
SET @min_month=201112;

SELECT 
    ec.user_id,
    age,
    editcount,
    /* Treatment factor: 
     * 0 = sent feedback (reference), 1 = received response, 2 = received useful
     * response
     */
    CASE
        WHEN mah_id IS NOT NULL THEN 2
        WHEN mbfr_id IS NOT NULL THEN 1
        ELSE 0
    END AS treatment,
    /* Cohort generation in number of months since beginning of MB phase 3 */
    PERIOD_DIFF(
        EXTRACT(YEAR_MONTH FROM ept_timestamp),
        @min_month
    ) AS cohort,
    /* Time, in seconds, from account registration until first edit click */
    (UNIX_TIMESTAMP(ept_timestamp) 
        - UNIX_TIMESTAMP(user_registration)) AS ept_lag,
    /* Time, in seconds, from first edit click until first feedback */
    (UNIX_TIMESTAMP(MIN(mbf_timestamp))
        - UNIX_TIMESTAMP(ept_timestamp)) AS feedback_lag,
    /* Mood type (3-levels factor: sad, happy, confused) */
    mbf_type AS mood,
    /* Was the feedback sent while editing? */
    mbf_editing AS is_editing,
    /* Editcount at the moment of the feedback */
    mbf_user_editcount AS feedback_editcount,
    /* Namespace of the page on which the feedback was sent, factor */
    CASE 
        WHEN v IS NULL THEN 'Special' 
        WHEN v IS NOT NULL THEN (
            CASE v WHEN '' THEN 'Main' 
            ELSE v END
        ) 
    END AS namespace,
    /* Number of characters of the feedback text */
    LENGTH(mbf_comment) AS feedback_len,
    /* OS type, factor */
    mbf_system_type AS os,
    /* Browser type, factor */
    SUBSTRING_INDEX(mbf_user_agent, '/', 1) as browser
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
JOIN 
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
LEFT JOIN
    namespaces
ON
    mbf_namespace = i
WHERE
    b.user_id IS NULL
GROUP BY
    mbf_user_id;
