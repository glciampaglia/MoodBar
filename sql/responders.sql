SELECT 
    u.user_id, 
    u.user_name, 
    CASE 
        WHEN
            mt.user_id IS NOT NULL 
        THEN 
            1 
        ELSE 
            0 
    END AS th_host, 
    COUNT(mbfr_id) AS n_response 
FROM 
    user u 
JOIN (
    /* simulate full outer join using the union of a right- and a left-outer join */
    SELECT 
        user_id, 
        mbfr_user_id 
    FROM 
        moodbar_feedback_response 
    LEFT JOIN 
        jmorgan.teahouse_hosts_and_colleagues 
    ON 
        mbfr_user_id = user_id 
    UNION 
    SELECT 
        user_id, 
        mbfr_user_id 
    FROM 
        moodbar_feedback_response 
    RIGHT JOIN 
        jmorgan.teahouse_hosts_and_colleagues 
    ON mbfr_user_id = user_id
) mt 
ON 
    u.user_id = IFNULL(mt.user_id, mt.mbfr_user_id) 
LEFT JOIN 
    moodbar_feedback_response m 
ON 
    u.user_id = m.mbfr_user_id 
GROUP BY 
    u.user_id
ORDER BY 
    COUNT(mbfr_id) DESC

