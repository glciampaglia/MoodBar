SELECT
    "all users" AS category,
    -- percentage of accounts with an authenticated email 
    SUM(user_email_authenticated IS NOT NULL) / COUNT(user_id) AS email_ratio,

    -- average lag (in seconds) between account registration and email
    -- authentication 
    AVG(UNIX_TIMESTAMP(user_email_authenticated) 
      - UNIX_TIMESTAMP(user_registration)) AS avg_email_lag,

    -- standard deviation of registration - authentication lag
    STD(UNIX_TIMESTAMP(user_email_authenticated) 
      - UNIX_TIMESTAMP(user_registration)) AS std_email_lag,

    -- sample size 
    COUNT(user_id) AS num_accounts
FROM
    user
WHERE

UNION

SELECT
    "active users",
    SUM(user_email_authenticated IS NOT NULL) / COUNT(user_id),
    AVG(UNIX_TIMESTAMP(user_email_authenticated) 
      - UNIX_TIMESTAMP(user_registration)) AS avg_email_lag,
    STD(UNIX_TIMESTAMP(user_email_authenticated) 
      - UNIX_TIMESTAMP(user_registration)) AS std_email_lag,
    COUNT(user_id) AS num_accounts
FROM
    user
JOIN
    edit_page_tracking
ON
    user_id = ept_user

UNION

SELECT
    "moodbar users",
    SUM(user_email_authenticated IS NOT NULL) / COUNT(user_id),
    AVG(UNIX_TIMESTAMP(user_email_authenticated) 
      - UNIX_TIMESTAMP(user_registration)) AS avg_email_lag,
    STD(UNIX_TIMESTAMP(user_email_authenticated) 
      - UNIX_TIMESTAMP(user_registration)) AS std_email_lag,
    COUNT(user_id) AS num_accounts
FROM
    user
JOIN
    edit_page_tracking
ON
    user_id = ept_user
JOIN
    moodbar_feedback
ON
    user_id = mbf_user_id;
