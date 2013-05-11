SELECT 
    COUNT(DISTINCT uw_user_id) AS `retained`, 
    FLOOR(DATEDIFF(day, uw_registration) / 30) AS `period`, 
    uw_group AS `group` 
FROM 
    giovanni.user_window 
JOIN 
    enwiki.user_daily_contribs 
ON 
    uw_user_id = user_id 
GROUP BY 
    `period`, 
    uw_group 
ORDER BY 
    `group`, 
    `period`;

