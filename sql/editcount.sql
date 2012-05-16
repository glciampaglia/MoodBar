/*
    compute average contributions at 1, 2, 5, 10, and 30 days since first edit click.
    All users since 2012-12-14.
 */

-- all users
SELECT 
    AVG(ec1), 
    ROUND(STDDEV_SAMP(ec1) / SQRT(COUNT(user_id)),4) AS err1, 
    AVG(ec2), 
    ROUND(STDDEV_SAMP(ec2) / SQRT(COUNT(user_id)),4) AS err2, 
    AVG(ec5), 
    ROUND(STDDEV_SAMP(ec5) / SQRT(COUNT(USER_ID)), 4) AS err5, 
    AVG(ec10), 
    ROUND(STDDEV_SAMP(ec10) / SQRT(COUNT(user_id)), 4) AS err10, 
    AVG(ec30), 
    ROUND(STDDEV_SAMP(ec30) / SQRT(COUNT(USER_ID)), 4) AS err30 
FROM 
    giovanni.editcount;

-- all moodbar users (should discount the feedback contribution)
SELECT 
    AVG(ec1), 
    ROUND(STDDEV_SAMP(ec1) / SQRT(COUNT(user_id)),4) AS err1, 
    AVG(ec2), 
    ROUND(STDDEV_SAMP(ec2) / SQRT(COUNT(user_id)),4) AS err2, 
    AVG(ec5), 
    ROUND(STDDEV_SAMP(ec5) / SQRT(COUNT(USER_ID)), 4) AS err5, 
    AVG(ec10), 
    ROUND(STDDEV_SAMP(ec10) / SQRT(COUNT(user_id)), 4) AS err10, 
    AVG(ec30), 
    ROUND(STDDEV_SAMP(ec30) / SQRT(COUNT(USER_ID)), 4) AS err30 
FROM 
    giovanni.editcount
WHERE
    user_id in (
        SELECT
            DISTINCT mbf_user_id
        FROM
            moodbar_feedback
    );

-- all moodbar users who received at least one response (should discount the feedback contribution)
SELECT 
    AVG(ec1), 
    ROUND(STDDEV_SAMP(ec1) / SQRT(COUNT(user_id)),4) AS err1, 
    AVG(ec2), 
    ROUND(STDDEV_SAMP(ec2) / SQRT(COUNT(user_id)),4) AS err2, 
    AVG(ec5), 
    ROUND(STDDEV_SAMP(ec5) / SQRT(COUNT(USER_ID)), 4) AS err5, 
    AVG(ec10), 
    ROUND(STDDEV_SAMP(ec10) / SQRT(COUNT(user_id)), 4) AS err10, 
    AVG(ec30), 
    ROUND(STDDEV_SAMP(ec30) / SQRT(COUNT(USER_ID)), 4) AS err30 
FROM 
    giovanni.editcount
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

-- all moodbar users who received at least a useful response (should discount the feedback contribution)
SELECT 
    AVG(ec1), 
    ROUND(STDDEV_SAMP(ec1) / SQRT(COUNT(user_id)),4) AS err1, 
    AVG(ec2), 
    ROUND(STDDEV_SAMP(ec2) / SQRT(COUNT(user_id)),4) AS err2, 
    AVG(ec5), 
    ROUND(STDDEV_SAMP(ec5) / SQRT(COUNT(USER_ID)), 4) AS err5, 
    AVG(ec10), 
    ROUND(STDDEV_SAMP(ec10) / SQRT(COUNT(user_id)), 4) AS err10, 
    AVG(ec30), 
    ROUND(STDDEV_SAMP(ec30) / SQRT(COUNT(USER_ID)), 4) AS err30 
FROM 
    giovanni.editcount
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
