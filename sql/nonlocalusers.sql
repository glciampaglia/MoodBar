/* Computes the number of non-local active users */

SOURCE dates.sql;

SELECT
    COUNT(gu_name) `no. non-local active users`
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
    user_registration >= @min_historical
    AND
    user_registration < @max_historical
    AND
    user_registration > IFNULL(gu_registration, user_registration)
