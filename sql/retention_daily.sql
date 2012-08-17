SELECT
    age as `account age`,
    uw_group as `group`,
    DATE(uw_registration) as `date`,
    AVG(retention) as `retention`,
    ROUND(STDDEV_SAMP(retention) / SQRT(COUNT(user_id)), 4) as `standard error`
FROM
    giovanni.user_window
JOIN
    giovanni.user_treatment
ON
    uw_user_id = ut_user_id
JOIN
    giovanni.retention
ON
    uw_user_id = user_id
GROUP BY
    age,
    uw_group,
    DATE(uw_registration)
;
