/*
    Create a table with editcount at 1, 2, 5, 10, and 30 days since first edit click
*/

SOURCE dates.sql

SET @db='giovanni'; -- change it to whatever you need

SET @_create="CREATE TEMPORARY TABLE IF NOT EXISTS ";
SET @_select="
SELECT 
    u.user_id as user_id,
    SUM(CASE 
        WHEN udc.contribs IS NULL THEN 0
        WHEN udc.day - INTERVAL ? DAY <= DATE(ept.ept_timestamp) THEN udc.contribs 
        ELSE 0
    END) as editcount
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
LEFT JOIN
    rfaulk.globaluser
ON
    user_name = gu_name
WHERE
-- only users that registered locally on enwiki within the eligibility window 
    u.user_registration >= @min_registration
    AND
    u.user_registration < @max_registration
    AND
    u.user_registration <= IFNULL(gu_registration, user_registration)
GROUP BY
    u.user_id";

-- create temp table giovanni.ec1
SET @days_offset=1; 
SET @stmt=CONCAT(@_create, @db, ".ec", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt USING @days_offset;
SET @index_stmt=CONCAT("CREATE INDEX user_id ON ", @db, ".ec", @days_offset, " (user_id)");
PREPARE index_stmt FROM @index_stmt;
EXECUTE index_stmt;

-- create temp table giovanni.ec2
SET @days_offset=2; 
SET @stmt=CONCAT(@_create, @db, ".ec", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
SET @index_stmt=CONCAT("CREATE INDEX user_id ON ", @db, ".ec", @days_offset, " (user_id)");
PREPARE index_stmt FROM @index_stmt;
EXECUTE index_stmt;

-- create temp table giovanni.ec5
SET @days_offset=5; 
SET @stmt=CONCAT(@_create, @db, ".ec", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
SET @index_stmt=CONCAT("CREATE INDEX user_id ON ", @db, ".ec", @days_offset, " (user_id)");
PREPARE index_stmt FROM @index_stmt;
EXECUTE index_stmt;

-- create temp table giovanni.ec10
SET @days_offset=10; 
SET @stmt=CONCAT(@_create, @db, ".ec", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
SET @index_stmt=CONCAT("CREATE INDEX user_id ON ", @db, ".ec", @days_offset, " (user_id)");
PREPARE index_stmt FROM @index_stmt;
EXECUTE index_stmt;

-- create temp table giovanni.ec30
SET @days_offset=30; 
SET @stmt=CONCAT(@_create, @db, ".ec", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
SET @index_stmt=CONCAT("CREATE INDEX user_id ON ", @db, ".ec", @days_offset, " (user_id)");
PREPARE index_stmt FROM @index_stmt;
EXECUTE index_stmt;

DEALLOCATE PREPARE stmt;

-- merge all tables together
DROP TABLE IF EXISTS giovanni.editcount;
CREATE TABLE giovanni.editcount (
    user_id INT NOT NULL,
    age SMALLINT NOT NULL,
    editcount INT NOT NULL,
    CONSTRAINT FOREIGN KEY (user_id) REFERENCES user (user_id),
    INDEX user_age (user_id, age)
)
SELECT 
    user_id,
    1 AS age,
    editcount
FROM    
    giovanni.ec1
UNION SELECT 
    user_id,
    2 AS age,
    editcount
FROM    
    giovanni.ec2
UNION SELECT 
    user_id,
    5 AS age,
    editcount
FROM    
    giovanni.ec5
UNION SELECT 
    user_id,
    10 AS age,
    editcount
FROM    
    giovanni.ec10
UNION SELECT 
    user_id,
    30 AS age,
    editcount
FROM    
    giovanni.ec30
ORDER BY
    user_id,
    age;
