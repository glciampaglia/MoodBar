/*
    compute average contributions at 1, 2, 5, 10, and 30 days since first edit click.
    All users since 2012-12-14.
 */

-- all users
SELECT 
    AVG(ret1), 
    ROUND(STDDEV_SAMP(ret1) / SQRT(COUNT(user_id)),4) AS err1, 
    AVG(ret2), 
    ROUND(STDDEV_SAMP(ret2) / SQRT(COUNT(user_id)),4) AS err2, 
    AVG(ret5), 
    ROUND(STDDEV_SAMP(ret5) / SQRT(COUNT(USER_ID)), 4) AS err5, 
    AVG(ret10), 
    ROUND(STDDEV_SAMP(ret10) / SQRT(COUNT(user_id)), 4) AS err10, 
    AVG(ret30), 
    ROUND(STDDEV_SAMP(ret30) / SQRT(COUNT(USER_ID)), 4) AS err30 
FROM 
    giovanni.retention;

-- all moodbar users (should discount the feedback contribution)
SELECT 
    AVG(ret1), 
    ROUND(STDDEV_SAMP(ret1) / SQRT(COUNT(user_id)),4) AS err1, 
    AVG(ret2), 
    ROUND(STDDEV_SAMP(ret2) / SQRT(COUNT(user_id)),4) AS err2, 
    AVG(ret5), 
    ROUND(STDDEV_SAMP(ret5) / SQRT(COUNT(USER_ID)), 4) AS err5, 
    AVG(ret10), 
    ROUND(STDDEV_SAMP(ret10) / SQRT(COUNT(user_id)), 4) AS err10, 
    AVG(ret30), 
    ROUND(STDDEV_SAMP(ret30) / SQRT(COUNT(USER_ID)), 4) AS err30 
FROM 
    giovanni.retention
WHERE
    user_id in (
        SELECT
            DISTINCT mbf_user_id
        FROM
            moodbar_feedback
    );

-- all moodbar users who rreteived at least one response (should discount the feedback contribution)
SELECT 
    AVG(ret1), 
    ROUND(STDDEV_SAMP(ret1) / SQRT(COUNT(user_id)),4) AS err1, 
    AVG(ret2), 
    ROUND(STDDEV_SAMP(ret2) / SQRT(COUNT(user_id)),4) AS err2, 
    AVG(ret5), 
    ROUND(STDDEV_SAMP(ret5) / SQRT(COUNT(USER_ID)), 4) AS err5, 
    AVG(ret10), 
    ROUND(STDDEV_SAMP(ret10) / SQRT(COUNT(user_id)), 4) AS err10, 
    AVG(ret30), 
    ROUND(STDDEV_SAMP(ret30) / SQRT(COUNT(USER_ID)), 4) AS err30 
FROM 
    giovanni.retention
WHERE
    user_id in (
        SELECT 
            DISTINCT mbf_user_id
        FROM
            moodbar_feedback
        JOIN
            moodbar_feedback_response
        ON
            mbf_id = mbfr_mbf_id
    );

-- all moodbar users who rreteived at least a useful response (should discount the feedback contribution)
SELECT 
    AVG(ret1), 
    ROUND(STDDEV_SAMP(ret1) / SQRT(COUNT(user_id)),4) AS err1, 
    AVG(ret2), 
    ROUND(STDDEV_SAMP(ret2) / SQRT(COUNT(user_id)),4) AS err2, 
    AVG(ret5), 
    ROUND(STDDEV_SAMP(ret5) / SQRT(COUNT(USER_ID)), 4) AS err5, 
    AVG(ret10), 
    ROUND(STDDEV_SAMP(ret10) / SQRT(COUNT(user_id)), 4) AS err10, 
    AVG(ret30), 
    ROUND(STDDEV_SAMP(ret30) / SQRT(COUNT(USER_ID)), 4) AS err30 
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
