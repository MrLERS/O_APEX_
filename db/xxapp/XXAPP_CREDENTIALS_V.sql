-- =============================================================================
-- XXAPP_CREDENTIALS_V
-- Shows whether a user has at least one active role in a given application.
-- Used by XXAPP_AUTH_PKG.PROCESS_LOGIN to validate access before creating
-- the APEX session.
-- =============================================================================
-- Columns:
--   USERNAME    -> matches APEX session user (V('APP_USER'))
--   APP_CODE    -> application identifier (e.g. 'XXAPP', 'XXLAB')
--   APP_APEX_ID -> APEX application ID
--   HAS_ACCESS  -> 'Y' if the user has at least one active role in that app
-- =============================================================================

CREATE OR REPLACE VIEW XXAPP_CREDENTIALS_V AS
SELECT
    u.USERNAME,
    a.APP_CODE,
    a.APP_APEX_ID,
    CASE
        WHEN COUNT(ur.USER_ROLE_ID) > 0 THEN 'Y'
        ELSE 'N'
    END AS HAS_ACCESS
FROM
    XXAPP_USERS      u
    CROSS JOIN XXAPP_APPS  a
    LEFT JOIN  XXAPP_APP_ROLES  ar ON ar.APP_ID    = a.APP_ID
                                  AND ar.IS_ENABLED  = 'Y'
    LEFT JOIN  XXAPP_USER_ROLES ur ON ur.USER_ID    = u.USER_ID
                                  AND ur.APP_ROLE_ID = ar.APP_ROLE_ID
                                  AND ur.IS_ENABLED   = 'Y'
WHERE
    u.IS_ENABLED = 'Y'
    AND a.IS_ENABLED = 'Y'
GROUP BY
    u.USERNAME,
    a.APP_CODE,
    a.APP_APEX_ID;