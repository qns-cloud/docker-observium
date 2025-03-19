-- Observium Database Initialization Script
-- This script runs when the database container is first initialized
-- It sets proper character sets and optimizes for Observium

-- Set proper character set and collation
ALTER DATABASE `observium` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant necessary privileges to Observium user
GRANT ALL PRIVILEGES ON `observium`.* TO 'observium'@'%';
FLUSH PRIVILEGES;

-- Optimized settings are now handled via command line parameters in docker-compose.yml
-- Removing all GLOBAL settings that could cause initialization conflicts

-- Note: interactive_timeout and wait_timeout will be configured via my.cnf if needed

-- Create basic maintenance stored procedure
DELIMITER //
CREATE PROCEDURE `observium`.`optimize_tables`()
BEGIN
    -- This procedure can be run periodically to optimize tables
    DECLARE done INT DEFAULT FALSE;
    DECLARE tbl_name VARCHAR(255);
    DECLARE cur1 CURSOR FOR 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'observium';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur1;
    read_loop: LOOP
        FETCH cur1 INTO tbl_name;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET @stmt = CONCAT('OPTIMIZE TABLE observium.', tbl_name);
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;
    CLOSE cur1;
END //
DELIMITER ;

-- Add a note that initialization was successful
SELECT 'Observium database initialization completed successfully' as 'Initialization Status';