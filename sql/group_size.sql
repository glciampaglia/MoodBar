SELECT
    uw_group AS `group`,
    COUNT(uw_user_id) AS `size`
FROM
    giovanni.user_window
GROUP BY
    uw_group;

