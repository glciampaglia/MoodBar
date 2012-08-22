SELECT
    "all users" AS category,
    /* percentage of accounts with an authenticated email. Note that COUNT(expr)
     * returns the count of non-NULL values of expr.
     */
    COUNT(user_email_authenticated) / COUNT(user_id) AS `% auth emails`,

    /* average lag (in seconds) between account registration and email
     * authentication 
     */
    ROUND(AVG(UNIX_TIMESTAMP(user_email_authenticated) 
      - UNIX_TIMESTAMP(user_registration))/86400., 2) AS `authentication lag`,

    /* standard deviation of registration - authentication lag */
    ROUND(STD(UNIX_TIMESTAMP(user_email_authenticated) 
      - UNIX_TIMESTAMP(user_registration))/86400., 2) AS `auth lag std`,

    /* sample size */
    COUNT(user_id) AS `group size`
FROM
    user
LEFT JOIN
    rfaulk.globaluser
ON
    user_name = gu_name
WHERE
    -- take only users that registered the account on enwiki
    user_registration <= IFNULL(gu_registration, user_registration) 
AND
    user_registration > '20111214'

UNION SELECT
    "active users",
    COUNT(user_email_authenticated) / COUNT(user_id),
    ROUND(AVG(UNIX_TIMESTAMP(user_email_authenticated) 
      - UNIX_TIMESTAMP(user_registration))/86400.,2),
    ROUND(STD(UNIX_TIMESTAMP(user_email_authenticated) 
      - UNIX_TIMESTAMP(user_registration))/86400.,2),
    COUNT(user_id)
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
AND
    user_registration > '20111214'

UNION SELECT
    "moodbar users",
    COUNT(user_email_authenticated) / COUNT(user_id),
    ROUND(AVG(UNIX_TIMESTAMP(user_email_authenticated) 
      - UNIX_TIMESTAMP(user_registration))/86400.,2),
    ROUND(STD(UNIX_TIMESTAMP(user_email_authenticated) 
      - UNIX_TIMESTAMP(user_registration))/86400.,2),
    COUNT(user_id)
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
    user_registration <= IFNULL(gu_registration, user_registration)
AND
    user_registration > '20111214';
