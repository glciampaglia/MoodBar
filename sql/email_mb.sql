SELECT 
    /* which experimental window does the user fall in? */
    uw_group, 

    /* did the user sends a MB feedback, receive a response etc. ? */
    ut_treatment,

    /* group size */
    COUNT(uw_user_id) AS `group size`,

    /* how many accounts have an authenticated email address? */
    COUNT(user_email_authenticated) AS `no. auth emails`, 
    ROUND(COUNT(user_email_authenticated)/COUNT(uw_user_id),4) AS `% auth emails`,

    /* average lag (in seconds) between account registration and email
     * authentication 
     */
    ROUND(AVG(UNIX_TIMESTAMP(user_email_authenticated) 
      - UNIX_TIMESTAMP(user_registration))/86400.,2) AS `authentication lag`,

    /* standard deviation of above */
    ROUND(STD(UNIX_TIMESTAMP(user_email_authenticated) 
      - UNIX_TIMESTAMP(user_registration))/86400.,2) AS `auth lag std`
FROM 
    giovanni.user_window 
JOIN
    giovanni.user_treatment
ON
    uw_user_id = ut_user_id
JOIN
    user 
ON 
    user_id = uw_user_id 
GROUP BY 
    uw_group,
    ut_treatment
WITH ROLLUP
;


