/*
    Create a table with retention indicators at 1, 2, 5, 10, and 30 days since
    first edit click
*/

SET @min_registration='2011-12-14'; -- latest iteration of MB

SET @_create="CREATE TEMPORARY TABLE IF NOT EXISTS ";
SET @_select="
SELECT 
    ept.ept_user as user_id,
    IFNULL(MAX(rev_timestamp) - INTERVAL ? DAY >= DATE(ept.ept_timestamp), 0) as retention
FROM 
    edit_page_tracking ept
JOIN
    user u
ON
    u.user_id = ept.ept_user
LEFT JOIN
    revision r
ON 
    ept.ept_user = r.rev_user
WHERE 
    DATE(u.user_registration) >= @min_registration
GROUP BY
    ept.ept_user";

-- create temp table giovanni.r1
SET @days_offset=1; 
SET @stmt=CONCAT(@_create, "giovanni.r", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
CREATE INDEX user_id ON giovanni.r1 (user_id);

-- create temp table giovanni.r2
SET @days_offset=2; 
SET @stmt=CONCAT(@_create, "giovanni.r", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
CREATE INDEX user_id ON giovanni.r2 (user_id);

-- create temp table giovanni.r5
SET @days_offset=5; 
SET @stmt=CONCAT(@_create, "giovanni.r", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
CREATE INDEX user_id ON giovanni.r5 (user_id);

-- create temp table giovanni.r10
SET @days_offset=10; 
SET @stmt=CONCAT(@_create, "giovanni.r", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
CREATE INDEX user_id ON giovanni.r10 (user_id);

-- create temp table giovanni.r30
SET @days_offset=30; 
SET @stmt=CONCAT(@_create, "giovanni.r", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
CREATE INDEX user_id ON giovanni.r30 (user_id);

DEALLOCATE PREPARE stmt;

-- join everything together
DROP TABLE IF EXISTS giovanni.retention;
CREATE TABLE giovanni.retention 
SELECT
    r1.user_id,
    r1.retention as ret1,
    r2.retention as ret2,
    r5.retention as ret5,
    r10.retention as ret10,
    r30.retention as ret30
FROM 
    giovanni.r1 r1
JOIN
    giovanni.r2 r2
USING
    (user_id)
JOIN
    giovanni.r5 r5
USING
    (user_id)
JOIN
    giovanni.r10 r10
USING
    (user_id)
JOIN
    giovanni.r30 r30
USING
    (user_id);

CREATE INDEX user_id on giovanni.retention (user_id);
