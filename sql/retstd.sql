/*
    selrett standard deviation of retention at 1, 2, 5, 10, and 30 days since
    first edit click. All users since 2011-12-14.
*/

-- all users
SELECT
    STDDEV_SAMP(ret1) as sd1,
    STDDEV_SAMP(ret2) as sd2,
    STDDEV_SAMP(ret5) as sd5,
    STDDEV_SAMP(ret10) as sd10,
    STDDEV_SAMP(ret30) as sd30
FROM
    giovanni.retention;

-- MoodBar users
SELECT
    STDDEV_SAMP(ret1 - 1) as sd1,
    STDDEV_SAMP(ret2 - 1) as sd2,
    STDDEV_SAMP(ret5 - 1) as sd5,
    STDDEV_SAMP(ret10 - 1) as sd10,
    STDDEV_SAMP(ret30 - 1) as sd30
FROM
    giovanni.retention
WHERE
    user_id 
IN (
    SELECT
        DISTINCT mbf_user_id
    FROM 
        moodbar_feedback
    );

-- MoodBar users who rreteived at least one response
SELECT
    STDDEV_SAMP(ret1 - 1) as sd1,
    STDDEV_SAMP(ret2 - 1) as sd2,
    STDDEV_SAMP(ret5 - 1) as sd5,
    STDDEV_SAMP(ret10 - 1) as sd10,
    STDDEV_SAMP(ret30 - 1) as sd30
FROM
    giovanni.retention
WHERE
    user_id
IN (
    SELECT
        DISTINCT mbf_user_id
    FROM
        moodbar_feedback
    JOIN
        moodbar_feedback_response
    ON
        mbf_id = mbfr_mbf_id
    );

-- MoodBar users who rreteived at least a useful response
SELECT
    STDDEV_SAMP(ret1 - 1) as sd1,
    STDDEV_SAMP(ret2 - 1) as sd2,
    STDDEV_SAMP(ret5 - 1) as sd5,
    STDDEV_SAMP(ret10 - 1) as sd10,
    STDDEV_SAMP(ret30 - 1) as sd30
FROM
    giovanni.retention
WHERE
    user_id 
    IN (
        SELECT 
            DISTINCT mbf_user_id
        FROM
            moodbar_feedback
        JOIN
            moodbar_feedback_response
        ON
            mbf_id = mbfr_mbf_id
        JOIN 
            mark_as_helpful
        ON
            mbfr_id = mah_item
    );
