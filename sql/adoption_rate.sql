SELECT 
    DATE(window_begins) AS `window begins`, 
    DATE(window_ends) AS `window ends`, 
    DATEDIFF(window_ends, window_begins) AS days, 
    uw_group AS `group`,
    treatment_name AS `treatment`, 
    COUNT(ut_user_id) AS `sample size`, 
    COUNT(ut_user_id)/DATEDIFF(window_ends, window_begins) AS `adoption rate` 
FROM 
    giovanni.user_treatment 
JOIN 
    giovanni.user_window 
ON 
    ut_user_id = uw_user_id
JOIN 
    giovanni.treatments 
ON 
    treatment_id = ut_treatment 
JOIN 
    giovanni.windows 
ON 
    window_name = uw_group 
GROUP BY 
    uw_group, 
    treatment_name 
ORDER BY 
    window_id
;
