/* compute average retention and standard deviation for each group/treatment
 * combination, with rollup.
 */

SELECT
    age `account age`,
    uw_group `group`,
    treatment_name `treatment`,
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
JOIN
    giovanni.treatments
ON
    ut_treatment = treatment_id
GROUP BY
    age,
    uw_group,
    treatment_name
WITH ROLLUP
;
