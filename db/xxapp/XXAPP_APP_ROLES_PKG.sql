-- =============================================================================
-- XXAPP_APP_ROLES_PKG
-- Writes on XXAPP_APP_ROLES (role x app). Called from the Interactive Grid
-- save process (case :APEX$ROW_STATUS) instead of inline DML.
-- =============================================================================

-- # # # # # # # # # # # # # # # # # # # # # # # # # # #
-- # Especificación
-- # # # # # # # # # # # # # # # # # # # # # # # # # # #

create or replace package "XXAPP_APP_ROLES_PKG" as

    -- Makes a role available in an app and returns the new APP_ROLE_ID
    function add_app_role (
      P_ROLE_ID in number
      , P_APP_ID in number
    ) return number;

    -- Updates the role behind an app_role row.
    -- Roles are global: the change is visible in every app that uses the role.
    procedure save_app_role (
      P_APP_ROLE_ID in number
      , P_ROLE_ID in number
      , P_ROLE_CODE in varchar2
      , P_ROLE_NAME in varchar2
      , P_ROLE_DESC in varchar2
    );

end "XXAPP_APP_ROLES_PKG";
/

-- # # # # # # # # # # # # # # # # # # # # # # # # # # #
-- # Cuerpo
-- # # # # # # # # # # # # # # # # # # # # # # # # # # #

create or replace package body "XXAPP_APP_ROLES_PKG" as

    function add_app_role (
      P_ROLE_ID in number
      , P_APP_ID in number
    ) return number
    is
      v_arid number;
    begin

      insert into XXAPP_APP_ROLES (
        APP_ID
        , ROLE_ID
      ) values (
        P_APP_ID
        , P_ROLE_ID
      ) returning APP_ROLE_ID into v_arid;

      return v_arid;

    end add_app_role;

    procedure save_app_role (
      P_APP_ROLE_ID in number
      , P_ROLE_ID in number
      , P_ROLE_CODE in varchar2
      , P_ROLE_NAME in varchar2
      , P_ROLE_DESC in varchar2
    )
    is
    begin

      update XXAPP_ROLES
      set
        ROLE_CODE = P_ROLE_CODE
        , ROLE_NAME = P_ROLE_NAME
        , DESCRIPTION = P_ROLE_DESC
      where ROLE_ID = P_ROLE_ID;

    end save_app_role;

end "XXAPP_APP_ROLES_PKG";
/
