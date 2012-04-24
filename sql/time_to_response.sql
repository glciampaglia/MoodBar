SELECT 
    /* censoring status */
    IF(mbfr_id IS NULL, 0, 1) AS status,
    /* feedback mood */
    mbf_type AS mood, 
    /* length of the feedback message */
    LENGTH(mbf_comment) AS message_len, 
    /* was the feedback sent anonymously? */
    mbf_anonymous AS is_anonymous,
    /* was the feedback sent while editing? */
    mbf_editing AS is_editing,
    /* edit count of the user sending the feedback */
    mbf_user_editcount AS user_edits,
    /* edit count of the user sending the feedback, at the time the feedback is
     * respondend to (?) */
    mbfr_commenter_editcount AS user_edits_later,
    /* edit count of the editor responding to the feedback */
    mbfr_user_editcount AS resp_edits, 
    /* time the feedback was posted, UTC */
    CAST(mbf_timestamp AS DATETIME) AS mood_time,
    /* time the feedback was responded to, UTC */
    CAST(mbfr_timestamp AS DATETIME) AS response_time 
FROM 
    moodbar_feedback a 
LEFT JOIN 
    moodbar_feedback_response b 
ON 
    a.mbf_id = b.mbfr_mbf_id 
WHERE 
    /* select only mood feedbacks that were sent after the feedback dashboard
     * was deployed */
    -- TODO: check if this is really needed.
    DATE(mbf_timestamp) >= '2011-12-14';
