/*
    Create a table with retention indicators at 1, 2, 5, 10, and 30 days since
    first edit click
*/

SOURCE dates.sql

SET @db='giovanni'; -- change it to whatever you need

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
LEFT JOIN
    page p
ON
    r.rev_page = p.page_id
LEFT JOIN
    rfaulk.globaluser
ON
    user_name = gu_name
LEFT JOIN
    giovanni.bot_ext b
ON 
    ept_user = b.user_id
WHERE
-- remove bots
    b.user_id IS NULL
AND
-- only users that registered locally on enwiki within the eligibility window 
    u.user_registration >= @min_historical
AND
    u.user_registration < @max_control
AND
    u.user_registration <= IFNULL(gu_registration, user_registration)
-- only edits to articles count for determining the retention value
AND
    p.page_namespace = 0
GROUP BY
    ept.ept_user";

-- create temp table giovanni.r1
SET @days_offset=1; 
SET @stmt=CONCAT(@_create, @db, ".r", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
SET @index_stmt=CONCAT("CREATE INDEX user_id ON ", @db, ".r", @days_offset, " (user_id)");
PREPARE index_stmt FROM @index_stmt;
EXECUTE index_stmt;

-- create temp table giovanni.r2
SET @days_offset=2; 
SET @stmt=CONCAT(@_create, @db, ".r", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
SET @index_stmt=CONCAT("CREATE INDEX user_id ON ", @db, ".r", @days_offset, " (user_id)");
PREPARE index_stmt FROM @index_stmt;
EXECUTE index_stmt;

-- create temp table giovanni.r5
SET @days_offset=5; 
SET @stmt=CONCAT(@_create, @db, ".r", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
SET @index_stmt=CONCAT("CREATE INDEX user_id ON ", @db, ".r", @days_offset, " (user_id)");
PREPARE index_stmt FROM @index_stmt;
EXECUTE index_stmt;

-- create temp table giovanni.r10
SET @days_offset=10; 
SET @stmt=CONCAT(@_create, @db, ".r", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
SET @index_stmt=CONCAT("CREATE INDEX user_id ON ", @db, ".r", @days_offset, " (user_id)");
PREPARE index_stmt FROM @index_stmt;
EXECUTE index_stmt;

-- create temp table giovanni.r30
SET @days_offset=30; 
SET @stmt=CONCAT(@_create, @db, ".r", @days_offset, @_select);
PREPARE stmt FROM @stmt;
EXECUTE stmt using @days_offset;
SET @index_stmt=CONCAT("CREATE INDEX user_id ON ", @db, ".r", @days_offset, " (user_id)");
PREPARE index_stmt FROM @index_stmt;
EXECUTE index_stmt;

DEALLOCATE PREPARE stmt;
DEALLOCATE PREPARE index_stmt;

-- put everything together
DROP TABLE IF EXISTS giovanni.retention;
CREATE TABLE giovanni.retention (
    user_id INT NOT NULL,
    age SMALLINT NOT NULL,
    retention SMALLINT NOT NULL,
    CONSTRAINT FOREIGN KEY (user_id) REFERENCES user (user_id),
    INDEX user_age (user_id, age)
)
SELECT 
    user_id,
    1 AS age,
    retention
FROM    
    giovanni.r1
UNION SELECT 
    user_id,
    2 AS age,
    retention
FROM    
    giovanni.r2
UNION SELECT 
    user_id,
    5 AS age,
    retention
FROM    
    giovanni.r5
UNION SELECT 
    user_id,
    10 AS age,
    retention
FROM    
    giovanni.r10
UNION SELECT 
    user_id,
    30 AS age,
    retention
FROM    
    giovanni.r30
ORDER BY
    user_id,
    age;
