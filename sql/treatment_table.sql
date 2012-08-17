SOURCE dates.sql

CREATE TEMPORARY TABLE IF NOT EXISTS
    giovanni.mark_as_helpful 
    (
        mah_id int primary key, 
        mah_item int,
        constraint foreign key mbfr_item (mah_item) references moodbar_feedback_response (mbfr_id)
    ) 
    SELECT 
        mah_id,
        mah_item
    FROM 
        mark_as_helpful;

DROP TABLE IF EXISTS giovanni.treatments;

CREATE TABLE giovanni.treatments (
    treatment_id SMALLINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    treatment_name VARCHAR(19) NOT NULL
);

INSERT INTO giovanni.treatments 
    (treatment_name)
VALUES
    ('Reference'),
    ('Feedback'), 
    ('Feedback+Response'),
    ('Feedback+Helpful');

/* 
--------------------------------------------------------------------------------
user_treatment table 
--------------------------------------------------------------------------------
*/

DROP TABLE IF EXISTS giovanni.user_treatment;

CREATE TABLE giovanni.user_treatment (
    ut_user_id INT NOT NULL UNIQUE,
    ut_treatment SMALLINT NOT NULL,
    CONSTRAINT FOREIGN KEY user_id (ut_user_id) REFERENCES user (user_id),
    CONSTRAINT FOREIGN KEY user_treatment (ut_treatment) REFERENCES giovanni.treatments (treatment_id)
) SELECT 
    u.user_id AS ut_user_id,
    MAX(CASE
        WHEN mah_id IS NOT NULL THEN 4
        WHEN mbfr_id IS NOT NULL THEN 3
        WHEN mbf_id IS NOT NULL THEN 2
        ELSE 1
    END) AS ut_treatment
FROM 
    edit_page_tracking 
JOIN
    user u
ON
    ept_user = u.user_id
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
    /* only local users */
LEFT JOIN
    rfaulk.globaluser
ON
    user_name = gu_name
    /* filter out bots */
LEFT JOIN
    giovanni.bot_ext b
ON 
    ept_user = b.user_id
WHERE
    b.user_id IS NULL
AND
    user_registration <= IFNULL(gu_registration, user_registration)
AND
    user_registration BETWEEN @min_historical AND @max_control
GROUP BY
    ept_user
;



