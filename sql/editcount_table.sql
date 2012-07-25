/*
    Create a table with editcount at 1, 2, 5, 10, and 30 days since first edit click
*/

SET @min_registration='2011-12-14'; -- phase 3 of MoodBar deployed
SET @max_registration='2012-05-22'; -- temporary UI enhancements deployed
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
WHERE 
    DATE(u.user_registration) >= @min_registration
    AND
    DATE(u.user_registration) < @max_registration
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

-- join everything together
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
UNION
SELECT 
    user_id,
    2 AS age,
    editcount
FROM    
    giovanni.ec2
UNION
SELECT 
    user_id,
    5 AS age,
    editcount
FROM    
    giovanni.ec5
UNION
SELECT 
    user_id,
    10 AS age,
    editcount
FROM    
    giovanni.ec10
UNION
SELECT 
    user_id,
    30 AS age,
    editcount
FROM    
    giovanni.ec30
ORDER BY
    user_id,
    age;
