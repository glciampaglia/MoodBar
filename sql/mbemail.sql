SELECT
    COUNT(user_id)
FROM (
    SELECT 
        user_id,
        user_email_authenticated
    FROM
        user
    JOIN
        moodbar_feedback
    ON
        user_id = mbf_user_id
    LEFT JOIN
        rfaulk.globaluser
    ON
        user_name = gu_name
    WHERE
        /* only local users */
        user_registration <= IFNULL(gu_registration, user_registration) 
    AND
        /* registered after MoodBar phase 3 on enwiki */
        user_registration > '20111214'
    GROUP BY
        user_id
    HAVING
        user_email_authenticated > MIN(mbf_timestamp)
    )a;


SELECT
    COUNT(DISTINCT user_id)
FROM 
    user
JOIN
    moodbar_feedback
ON
    user_id = mbf_user_id
LEFT JOIN
    rfaulk.globaluser
ON
    user_name = gu_name
WHERE
    user_registration <= IFNULL(gu_registration, user_registration)
AND
    user_registration > '20111214'
AND
    user_email_authenticated IS NOT NULL;


