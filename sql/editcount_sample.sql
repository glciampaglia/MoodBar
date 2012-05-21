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
    ec.*, 
    IF(
        mah_id IS NOT NULL, 
        'mb-useful', 
        IF(
            mbfr_id IS NOT NULL, 
            'mb-response', 
            IF(
                mbf_id IS NOT NULL, 
                'moodbar', 
                'no-moodbar'
            )
        )
    ) AS code, 
    DATE_FORMAT(ept_timestamp, '%Y-%m') AS cohort 
FROM 
    edit_page_tracking 
JOIN 
    giovanni.editcount ec 
ON 
    ept_user = user_id 
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
