-- =============================================================================
-- XXAPP_AUTH_PKG
-- Custom authentication package for Oracle APEX
-- =============================================================================
-- Function : PROCESS_LOGIN
--   Validates that the user exists in XXAPP_USERS and is active.
--   Returns TRUE  -> APEX creates the session (login succeeds)
--   Returns FALSE -> APEX rejects login (login fails)
-- =============================================================================
-- NOT COMPILABLE FROM THIS REPO YET. It references two things that exist only
-- in the workspace and still have to be exported:
--   * column PWD in XXAPP_CREDENTIALS_V (HAS_ACCESS, SAVE_CREDENTIALS)
--   * view XXAPP_USER_INFO_V            (SAVE_CREDENTIALS)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- SPEC
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE XXAPP_AUTH_PKG AS

    /* Main entry point called by the APEX custom auth scheme */
    FUNCTION PROCESS_LOGIN (
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN BOOLEAN;

    function HAS_ACCESS (
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN BOOLEAN;

    procedure SAVE_CREDENTIALS (
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    );

END XXAPP_AUTH_PKG;
/


-- -----------------------------------------------------------------------------
-- BODY
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY XXAPP_AUTH_PKG AS

    -- -------------------------------------------------------------------------
    -- PROCESS_LOGIN
    -- Validates:
    --   1. User exists and is active             (XXAPP_USERS)
    --   2. User has access to the current app    (XXAPP_CREDENTIALS_V)
    --      The current app is resolved via V('APP_ID') from the APEX session.
    -- -------------------------------------------------------------------------
    FUNCTION PROCESS_LOGIN (
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN BOOLEAN
    AS
        v_username  XXAPP_USERS.USERNAME%TYPE;
    BEGIN

        v_username := UPPER(TRIM(p_username));

        IF XXAPP_AUTH_PKG.HAS_ACCESS(
            p_username => v_username
            , p_password => p_password
        ) THEN
            -- XXAPP_AUTH_PKG.SAVE_CREDENTIALS(
            --     p_username => v_username
            --     , p_password => p_password
            -- );
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END PROCESS_LOGIN;


    function HAS_ACCESS (
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN BOOLEAN
    is
        v_app_id    XXAPP_APPS.APP_APEX_ID%TYPE;
        v_count     NUMBER := 0;
    begin
        v_app_id := TO_NUMBER(V('APP_ID'));

        SELECT COUNT(*)
          INTO v_count
          FROM XXAPP_CREDENTIALS_V
         WHERE UPPER(USERNAME) = p_username
           AND PWD             = p_password
           AND APP_APEX_ID     = v_app_id
           AND HAS_ACCESS      = 'Y';

        return v_count > 0;
    end HAS_ACCESS;

    procedure SAVE_CREDENTIALS (
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    )
    is
        V_USER_ID   XXAPP_USERS.USER_ID%TYPE;
        V_ROLE_ID   XXAPP_ROLES.ROLE_ID%TYPE;
        V_ROLE_NAME XXAPP_ROLES.ROLE_NAME%TYPE;
    begin
        SELECT
            USER_ID
            , ROLE_ID
            , ROLE_NAME
        INTO
            v_user_id
            , v_role_id
            , v_role_name
        FROM XXAPP_USER_INFO_V
        WHERE 0 = 0
        AND IS_PRIMARY = 'Y'
        AND USERNAME = p_username
        AND PWD = p_password;

        APEX_UTIL.SET_SESSION_STATE(
            P_NAME  => 'SESSION_USERNAME',
            P_VALUE => p_username
        );
        APEX_UTIL.SET_SESSION_STATE(
            P_NAME  => 'SESSION_PWD',
            P_VALUE => p_password
        );

        APEX_UTIL.SET_SESSION_STATE(
            P_NAME  => 'SESSION_USER_ID',
            P_VALUE => V_USER_ID
        );

        APEX_UTIL.SET_SESSION_STATE(
            P_NAME  => 'SESSION_ROLE_ID',
            P_VALUE => V_ROLE_ID
        );

        APEX_UTIL.SET_SESSION_STATE(
            P_NAME  => 'SESSION_ROLE_NAME',
            P_VALUE => V_ROLE_NAME
        );
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, 'Error saving credentials to session state: ' || SQLERRM);

    end SAVE_CREDENTIALS;

END XXAPP_AUTH_PKG;
/
