SELECT 
    SUM(b.num_first_feedback)/SUM(c.num_edit_click) * 100 AS perc_first_mooders 
FROM (
    SELECT 
        date_first AS date, 
        COUNT(date_first) AS num_first_feedback 
    FROM (
        SELECT 
            DATE(MIN(mbf_timestamp)) AS date_first 
        FROM 
            moodbar_feedback 
        GROUP BY 
            mbf_user_id
    ) a 
    GROUP BY 
        date
    ) b 
JOIN (
    SELECT 
        DATE(ept_timestamp) AS date,
        COUNT(DATE(ept_timestamp)) AS num_edit_click 
    FROM 
        edit_page_tracking 
    GROUP BY 
        DATE(ept_timestamp)
    ) c 
ON 
    c.date = b.date 
WHERE 
    b.date > '2011-11-01';
