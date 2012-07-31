SELECT
    "all users" AS category,
    -- percentage of accounts with an authenticated email. Note that COUNT(expr)
    -- returns the count of non-NULL values of expr.
    COUNT(user_email_authenticated) / COUNT(user_id) AS email_ratio,

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
LEFT JOIN
    rfaulk.globaluser
ON
    user_name = gu_name
WHERE
    -- take only users that registered the account on enwiki
    user_registration <= IFNULL(gu_registration, user_registration) 

UNION SELECT
    "active users",
    COUNT(user_email_authenticated) / COUNT(user_id) AS email_ratio,
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
LEFT JOIN
    rfaulk.globaluser
ON
    user_name = gu_name
WHERE
    user_registration <= IFNULL(gu_registration, user_registration) 

UNION SELECT
    "moodbar users",
    COUNT(user_email_authenticated) / COUNT(user_id) AS email_ratio,
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
    user_id = mbf_user_id
LEFT JOIN
    rfaulk.globaluser
ON
    user_name = gu_name
WHERE
    user_registration <= IFNULL(gu_registration, user_registration);

