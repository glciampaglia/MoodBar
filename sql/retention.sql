/*
    compute average contributions at 1, 2, 5, 10, and 30 days since first edit click.
    All users since 2012-12-14.
 */

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

-- all users
SELECT 
    "reference" as treatment,
    age,
    NULL as mood,
    AVG(retention) as retention,
    STDDEV_SAMP(retention) as retention_std,
    COUNT(user_id) as size
FROM
    giovanni.retention
GROUP BY
    age

-- all moodbar users 
UNION SELECT 
    "moodbar",
    age,
    mbf_type,
    AVG(retention),
    STDDEV_SAMP(retention),
    COUNT(user_id)
FROM 
    giovanni.retention
JOIN
(
    SELECT
        mbf_user_id,
        mbf_type,
        MIN(mbf_timestamp)
    FROM
        moodbar_feedback
    GROUP BY
        mbf_user_id
) a
ON
    mbf_user_id = user_id
GROUP BY
    age,
    mbf_type
WITH ROLLUP

-- all moodbar users who received at least one response 
UNION SELECT 
    "feedback+response",
    age,
    mbf_type,
    AVG(retention),
    STDDEV_SAMP(retention),
    COUNT(user_id)
FROM 
    giovanni.retention
JOIN
(
    SELECT
        mbf_user_id,
        mbf_type,
        MIN(mbf_timestamp)
    FROM
        moodbar_feedback
    JOIN
        moodbar_feedback_response
    ON
        mbf_id = mbfr_mbf_id
    GROUP BY
        mbf_user_id
) a
ON
    mbf_user_id = user_id
GROUP BY
    age,
    mbf_type
WITH ROLLUP

-- all moodbar users who recevived at least a helpful response 
UNION SELECT 
    "feedback+helpful",
    age,
    mbf_type,
    AVG(retention),
    STDDEV_SAMP(retention),
    COUNT(user_id)
FROM 
    giovanni.retention
JOIN
(
    SELECT
        mbf_user_id,
        mbf_type,
        MIN(mbf_timestamp)
    FROM
        moodbar_feedback
    JOIN
        moodbar_feedback_response
    ON
        mbf_id = mbfr_mbf_id
    JOIN
        giovanni.mark_as_helpful
    on
        mbfr_id = mah_item
    GROUP BY
        mbf_user_id
) a
ON
    mbf_user_id = user_id
GROUP BY
    age,
    mbf_type
WITH ROLLUP;
