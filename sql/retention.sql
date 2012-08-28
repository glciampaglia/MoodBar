/* average retention by account age/window, with accuracy figures */

SELECT
    age `account age`,
    uw_group `group`,
    SUM(retention) `still active`,
    COUNT(user_id) `group size`
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
