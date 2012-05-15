/*
    Create a table with editcount at 1, 2, 5, 10, and 30 days since first edit click
*/

SET @min_registration='2011-12-14'; -- latest iteration of MB

SET @_create="CREATE TEMPORARY TABLE IF NOT EXISTS ";
SET @_select="
SELECT 
    u.user_id as user_id,
    SUM(IFNULL(udc.contribs, 0)) as editcount
FROM 
    user u
JOIN
    edit_page_tracking ept
ON
    u.user_id = ept.ept_user
LEFT JOIN
    user_daily_contribs udc
ON 
    u.user_id = udc.user_id
WHERE 
    IFNULL(udc.day, ept.ept_timestamp) - INTERVAL ? DAY <= DATE(ept.ept_timestamp)
    AND DATE(u.user_registration) >= @min_registration
GROUP BY
    u.user_id";

-- create temp table giovanni.ec1
SET @days_offset=1; 
SET @stmt=CONCAT(@_create, "giovanni.ec", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
CREATE INDEX user_id ON giovanni.ec1 (user_id);

-- create temp table giovanni.ec2
SET @days_offset=2; 
SET @stmt=CONCAT(@_create, "giovanni.ec", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
CREATE INDEX user_id ON giovanni.ec2 (user_id);

-- create temp table giovanni.ec5
SET @days_offset=5; 
SET @stmt=CONCAT(@_create, "giovanni.ec", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
CREATE INDEX user_id ON giovanni.ec5 (user_id);

-- create temp table giovanni.ec10
SET @days_offset=10; 
SET @stmt=CONCAT(@_create, "giovanni.ec", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
CREATE INDEX user_id ON giovanni.ec10 (user_id);

-- create temp table giovanni.ec30
SET @days_offset=30; 
SET @stmt=CONCAT(@_create, "giovanni.ec", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
CREATE INDEX user_id ON giovanni.ec30 (user_id);

DEALLOCATE PREPARE stmt;

-- join everything together
DROP TABLE IF EXISTS giovanni.editcount;
CREATE TABLE giovanni.editcount 
SELECT
    e1.user_id,
    e1.editcount as ec1,
    e2.editcount as ec2,
    e5.editcount as ec5,
    e10.editcount as ec10,
    e30.editcount as ec30
FROM 
    giovanni.ec1 e1
JOIN
    giovanni.ec2 e2
USING
    (user_id)
JOIN
    giovanni.ec5 e5
USING
    (user_id)
JOIN
    giovanni.ec10 e10
USING
    (user_id)
JOIN
    giovanni.ec30 e30
USING
    (user_id);

CREATE INDEX user_id on giovanni.editcount (user_id);
