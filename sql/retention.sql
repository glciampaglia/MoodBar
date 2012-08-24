/* average retention by account age/window, with accuracy figures */

SELECT
    age as day,
    uw_group as `group`,
    AVG(retention) as `retention`,
    ROUND(STDDEV_SAMP(retention) / SQRT(COUNT(user_id)), 4) as `standard error`
    COUNT(user_id) as `sample size`
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
    day,
    uw_group
;
