/* compute average retention and standard deviation for each group/treatment
 * combination, with rollup.
 */

SELECT
    age as day,
    uw_group as `group`,
    treatment_name as `treatment`,
    AVG(retention) as `retention`,
    STDDEV_SAMP(retention) as `retention std`,
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
JOIN
    giovanni.treatments
ON
    ut_treatment = treatment_id
GROUP BY
    day,
    uw_group,
    treatment_name
WITH ROLLUP
;
