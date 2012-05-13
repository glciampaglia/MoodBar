/* Compute average editcount at given offset (in days) since registration.
 * Returns estimates for monthly cohorts. */

SET @days_offset=2; /* offset in days since registration */

SELECT 
    DATE_FORMAT(editdate, "%Y-%m") as cohort,
    AVG(editcount) as EC,
    STDDEV_SAMP(editcount) as sdEC,
    SQRT(STDDEV_SAMP(editcount)) / COUNT(editcount) as seEC
FROM (
    SELECT 
        DATE(rev_timestamp) AS editdate, 
        COUNT(user_id) AS editcount 
    FROM 
        user 
    STRAIGHT_JOIN 
        revision 
    ON 
    user_id = rev_user 
    WHERE 
        rev_timestamp - INTERVAL @days_offset DAY <= DATE(user_registration)
    GROUP BY 
        user_id
) a 
GROUP BY 
    YEAR(editdate), MONTH(editdate);
