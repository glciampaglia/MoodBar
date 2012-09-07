DROP TABLE IF EXISTS giovanni.bot_ext;

CREATE TABLE 
    giovanni.bot_ext 
(
    user_id INT NOT NULL, 
    user_name VARBINARY(255) NOT NULL, 
    CONSTRAINT FOREIGN KEY (user_id) REFERENCES user (user_id)
) 
SELECT 
    *
FROM 
    halfak.bot 
UNION 
SELECT 
    * 
FROM 
    giovanni.bot 
ORDER BY 
    user_id;

-- Manually add any other bot that is not catched by gimmebot.py
INSERT INTO giovanni.bot_ext VALUE (16529866, 'BlevintronBot');
