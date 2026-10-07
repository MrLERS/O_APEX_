-- =============================================================================
-- XXAPP_ROLES_PKG
-- Writes on XXAPP_ROLES. Called from the Interactive Grid save process
-- (case :APEX$ROW_STATUS) instead of inline DML.
-- =============================================================================

-- # # # # # # # # # # # # # # # # # # # # # # # # # # #
-- # Especificación
-- # # # # # # # # # # # # # # # # # # # # # # # # # # #

create or replace package "XXAPP_ROLES_PKG" as

    -- Inserts a role and returns its ROLE_ID (filled by XXAPP_ROLES_TRG)
    function add_role (
      P_ROLE_CODE in varchar2
      , P_ROLE_NAME in varchar2
      , P_ROLE_DESC in varchar2
    ) return number;

end "XXAPP_ROLES_PKG";
/

-- # # # # # # # # # # # # # # # # # # # # # # # # # # #
-- # Cuerpo
-- # # # # # # # # # # # # # # # # # # # # # # # # # # #

create or replace package body "XXAPP_ROLES_PKG" as

    function add_role (
      P_ROLE_CODE in varchar2
      , P_ROLE_NAME in varchar2
      , P_ROLE_DESC in varchar2
    ) return number
    is
      v_rid number;
    begin

      insert into XXAPP_ROLES (
        ROLE_CODE
        , ROLE_NAME
        , DESCRIPTION
      ) values (
        P_ROLE_CODE
        , P_ROLE_NAME
        , P_ROLE_DESC
      ) returning ROLE_ID into v_rid;

      return v_rid;

    end add_role;

end "XXAPP_ROLES_PKG";
/
