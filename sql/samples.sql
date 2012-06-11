/* compute sample size and size of each treatment group */

/* Needed to get index access on mah_item */
CREATE TEMPORARY TABLE IF NOT EXISTS
    giovanni.mark_as_helpful 
    (
        mah_id int primary key, 
        mah_item int,
        constraint foreign key mbfr_item (mah_item) references moodbar_feedback_response (mbf_id)
    ) 
    SELECT 
        mah_id,
        mah_item
    FROM 
        mark_as_helpful;

/* Each uses is assigned to one (and only one) sample based on the day of
 * activation of moodbar. Samples correspond to 7 days intervals, with reference
 * date equal to the date of introduction of the temporary UI enhancements
 * (2012-05-23). To allow for a fair comparison between older and newer
 * intervals, only feedbacks/posts/markings performed within the first 7 days
 * since activation are counted.
 */
SELECT
    /* day of start of sample interval */
    MIN(DATE(ept_timestamp)) AS start_day,
    /* day of end of sample interval */
    MAX(DATE(ept_timestamp)) as end_day,
    /* total number of moodbar activations */
    COUNT(ept_user) AS n_total,
    /* total number of users who sent a feedback */
    COUNT(DISTINCT mbf_user_id) AS n_feedback,
    /* total number of users who received at least one response */
    COUNT(DISTINCT mbfr_mbf_id) AS n_responses,
    /* total number of users who marked at least on response as useful */
    COUNT(DISTINCT mah_item) AS n_useful
FROM 
    edit_page_tracking
LEFT JOIN
    moodbar_feedback
ON
    ept_user = mbf_user_id
LEFT JOIN
    moodbar_feedback_response
ON
    mbf_id = mbfr_mbf_id
LEFT JOIN
    giovanni.mark_as_helpful
ON
    mbfr_id = mah_item 
WHERE
    IFNULL(mbf_timestamp, ept_timestamp) - INTERVAL 7 DAY <= DATE(ept_timestamp)
GROUP BY
    CEIL(DATEDIFF(ept_timestamp, '2012-05-23') / 7)
ORDER BY 
    ept_timestamp;
