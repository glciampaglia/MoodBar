/*
    Create a table with retention indicators at 1, 2, 5, 10, and 30 days since
    first edit click
*/

-- uncomment only one block of the following

-- historical data
SET @min_registration='20111214'; -- phase 3 of MoodBar deployed
SET @max_registration='20120523'; -- temporary UI enhancements deployed

/*
-- treatment
SET @min_registration='20120523';
SET @max_registration='20120614';

-- control group
SET @min_registration='20120614';
SET @max_registration='20120629';
*/

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
