-- =============================================================================
-- XXAPP_TRUNCATE.sql
-- Deletes all data and resets sequences.
-- Objects (tables, views, packages) are preserved.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- DISABLE FK constraints temporarily to allow TRUNCATE in any order
-- -----------------------------------------------------------------------------
BEGIN
    FOR c IN (
        SELECT constraint_name, table_name
        FROM user_constraints
        WHERE constraint_type = 'R'
        AND table_name LIKE 'XXAPP%'
    ) LOOP
        EXECUTE IMMEDIATE 'ALTER TABLE ' || c.table_name
            || ' DISABLE CONSTRAINT ' || c.constraint_name;
    END LOOP;
END;
/

-- -----------------------------------------------------------------------------
-- TRUNCATE tables
-- -----------------------------------------------------------------------------
TRUNCATE TABLE XXAPP_ROLE_PAGES;
TRUNCATE TABLE XXAPP_USER_ROLES;
TRUNCATE TABLE XXAPP_APP_ROLES;
TRUNCATE TABLE XXAPP_ROLES;
TRUNCATE TABLE XXAPP_USERS;
TRUNCATE TABLE XXAPP_APPS;

-- -----------------------------------------------------------------------------
-- RE-ENABLE FK constraints
-- -----------------------------------------------------------------------------
BEGIN
    FOR c IN (
        SELECT constraint_name, table_name
        FROM user_constraints
        WHERE constraint_type = 'R'
        AND table_name LIKE 'XXAPP%'
    ) LOOP
        EXECUTE IMMEDIATE 'ALTER TABLE ' || c.table_name
            || ' ENABLE CONSTRAINT ' || c.constraint_name;
    END LOOP;
END;
/

-- -----------------------------------------------------------------------------
-- RESET sequences back to 1
-- -----------------------------------------------------------------------------
BEGIN
    FOR s IN (
        SELECT sequence_name
        FROM user_sequences
        WHERE sequence_name LIKE 'XXAPP%'
    ) LOOP
        -- Get current value then restart from 1
        EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || s.sequence_name || ' RESTART START WITH 1';
    END LOOP;
END;
/

-- -----------------------------------------------------------------------------
-- VERIFICATION
-- -----------------------------------------------------------------------------
SELECT table_name, num_rows
FROM user_tables
WHERE table_name LIKE 'XXAPP%'
ORDER BY table_name;

SELECT sequence_name, last_number
FROM user_sequences
WHERE sequence_name LIKE 'XXAPP%'
ORDER BY sequence_name;