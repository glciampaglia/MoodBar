/* Constants defining the windows. ATTENTION! these cannot overlap > 1 day!!! */

SOURCE dates.sql

/* 
--------------------------------------------------------------------------------
windows table 
--------------------------------------------------------------------------------
*/

DROP TABLE IF EXISTS giovanni.windows;

CREATE TABLE giovanni.windows (
    window_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    window_name VARCHAR(10) NOT NULL,
    /* mediawiki timestamp */
    window_begins VARBINARY(18) NOT NULL,
    /* mediawiki timestamp */
    window_ends VARBINARY(18) NOT NULL,
    INDEX window_name_range (window_name, window_begins, window_ends)
);

INSERT INTO giovanni.windows
    (window_name, window_begins, window_ends)
VALUES 
    ('historical', @min_historical, @max_historical),
    ('treatment', @min_treatment, @max_treatment),
    ('control', @min_control, @max_control);

/* 
--------------------------------------------------------------------------------
user_window table 
--------------------------------------------------------------------------------
*/

DROP TABLE IF EXISTS giovanni.user_window;

CREATE TABLE giovanni.user_window (
    uw_user_id INT NOT NULL UNIQUE,
    uw_registration VARBINARY(18) NOT NULL,
    uw_group VARBINARY(10) NOT NULL,
    CONSTRAINT FOREIGN KEY (uw_user_id) REFERENCES user (user_id),
    INDEX user_window_id_group (uw_user_id, uw_group)
) SELECT DISTINCT
    u.user_id as uw_user_id,
    u.user_registration as uw_registration,
    window_name as uw_group
FROM 
    edit_page_tracking 
JOIN
    user u
ON
    ept_user = u.user_id
JOIN
    giovanni.windows
ON
    user_registration BETWEEN window_begins and window_ends
LEFT JOIN
    rfaulk.globaluser
ON
    user_name = gu_name
LEFT JOIN
    giovanni.bot_ext b
ON 
    ept_user = b.user_id
WHERE
    b.user_id IS NULL
AND
    u.user_registration <= IFNULL(gu_registration, user_registration)
AND
    user_registration BETWEEN @min_historical AND @max_control
;
