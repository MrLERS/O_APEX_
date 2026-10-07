-- =============================================================================
-- XXAPP_QUERIES_PKG
-- Every report, LOV, grid and cards source used by the APEX apps.
-- Each function returns the SQL text as a CLOB; the APEX region uses
-- "Function Body returning SQL Query":
--   return XXAPP_QUERIES_PKG.get_all_roles('LOV');
-- =============================================================================
-- p_type selects the column shape:
--   'LOV'          -> d (display) / r (return)
--   'REP', 'GRID'  -> report or Interactive Grid columns
--   'CARDS'        -> card_* aliases of the Cards region
--   anything else  -> unfiltered full select
-- The returned text must not end in ';' (APEX wraps it as a subquery).
-- Depends on: XXAPP tables, XXAPP_APP_ROLES_V
-- =============================================================================

-- # # # # # # # # # # # # # # # # # # # # # # # # # # #
-- # Especificación
-- # # # # # # # # # # # # # # # # # # # # # # # # # # #

create or replace package "XXAPP_QUERIES_PKG" as

    function get_all_enabled_flags
    return clob;

    FUNCTION get_all_apps (
        p_only_registered IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION GET_ID_APP
    RETURN CLOB;

    function get_all_users
    return clob;

    function get_all_roles (
      p_type varchar2
    ) return clob;

    function get_all_registered_apps (
      p_type varchar2
    ) return clob;

    function get_all_roles_by_app (
      p_type varchar2 default null
      , p_app_id number
    ) return clob;

    function get_all_pages_by_role (
      p_type varchar2 default null
    ) return clob;

    function get_all_pages_by_app_apex (
      p_type varchar2 default null
      , p_app_id number
    ) return clob;

end "XXAPP_QUERIES_PKG";
/

-- # # # # # # # # # # # # # # # # # # # # # # # # # # #
-- # Cuerpo
-- # # # # # # # # # # # # # # # # # # # # # # # # # # #

create or replace package body "XXAPP_QUERIES_PKG" as

    function get_all_enabled_flags
    return clob
    is
      v_query clob;
    begin

        v_query := q'~
            select
                'Activo' as L
                , 'Y' as V
            from dual
            union
            select
                'InActivo' as L
                , 'N' as V
            from dual
        ~';

        return v_query;

    end get_all_enabled_flags;

    FUNCTION get_all_apps (
        p_only_registered  IN VARCHAR2
    ) RETURN VARCHAR2
    is
    begin
        return '
            select
                APPLICATION_NAME as d
                , APPLICATION_ID as v
            from apex_applications
        ';
    end get_all_apps;

    FUNCTION GET_ID_APP
    RETURN CLOB
    IS
        V_QUERY CLOB;
        BEGIN
        V_QUERY := q'~
            SELECT application_name || ' (' || application_id || ')' AS D,
                   application_id AS R
            FROM   apex_applications
            WHERE  workspace = 'XXLERS_DEV'
            ORDER  BY application_name
        ~';
        RETURN V_QUERY;
    END GET_ID_APP;


    function get_all_users
    return clob
    is
      v_query clob;
    begin

      v_query := q'~
        select
          USER_ID
          , USERNAME
          , FULL_NAME
        from XXAPP_USERS
        where 0 = 0
        and IS_ENABLED = 'Y'
      ~';

      return v_query;

    end get_all_users;

    function get_all_roles (
      p_type varchar2
    ) return clob
    is
      v_query clob;
    begin

      case
        when (p_type = 'LOV') then
          v_query := q'~
            select
              r.ROLE_NAME as d
              , r.ROLE_ID as r
            from XXAPP_ROLES r
            where 0 = 0
            and r.IS_ENABLED = 'Y'
          ~';
        when (p_type = 'REP') then
          v_query := q'~
            select
              r.ROLE_ID
              , r.ROLE_CODE
              , r.ROLE_NAME
              , r.DESCRIPTION
            from XXAPP_ROLES r
            where 0 = 0
            and r.IS_ENABLED = 'Y'
          ~';
        else
          v_query := q'~
            select
              r.ROLE_ID
              , r.ROLE_CODE
              , r.ROLE_NAME
              , r.DESCRIPTION
            from XXAPP_ROLES r
          ~';
      end case;

      return v_query;

    end get_all_roles;

    function get_all_registered_apps (
      p_type varchar2
    ) return clob
    is
      v_query clob;
    begin

      case
        when (p_type = 'LOV') then
          v_query := q'~
            select
              a.APP_NAME as d
              , a.APP_ID as r
            from XXAPP_APPS a
            where 0 = 0
            and a.IS_ENABLED = 'Y'
          ~';
        when (p_type = 'REP') then
          v_query := q'~
            select
              a.APP_ID
              , a.APP_CODE
              , a.APP_NAME
              , a.APP_APEX_ID
            from XXAPP_APPS a
            where 0 = 0
            and a.IS_ENABLED = 'Y'
          ~';
        when (p_type = 'CARDS') then
          v_query := q'~
            select
              a.APP_ID as card_primary_key
              , null as card_secondary_key
              , a.APP_NAME as card_title
              , a.APP_CODE as card_subtitle
              , a.DESCRIPTION as card_body
              , null as card_secondary_body
              , null as card_icon
              , case a.IS_ENABLED
                  when 'Y' then
                    'Activo'
                  else
                    'InActivo'
                end as card_badge
              , null as card_image
            from XXAPP_APPS a
            order by a.APP_ID
          ~';
        else
          v_query := q'~
            select
              a.APP_ID
              , a.APP_CODE
              , a.APP_NAME
              , a.APP_APEX_ID
            from XXAPP_APPS a
          ~';
      end case;

      return v_query;

    end get_all_registered_apps;

    -- p_app_id is a number, so concatenating it cannot inject SQL.
    -- nvl(p_app_id, 0) keeps the query valid while the page item is still null.
    function get_all_roles_by_app (
      p_type varchar2 default null
      , p_app_id number
    ) return clob
    is
      v_query clob;
    begin

      case
        when (p_type = 'LOV') then
          v_query := '
            select
              arv.ROLE_NAME as d
              , arv.ROLE_ID as r
            from XXAPP_APP_ROLES_V arv
            where 0 = 0
            and arv.APP_ID = ' || nvl(p_app_id, 0) || '
          ';
        when (p_type = 'REP') then
          v_query := '
            select
              arv.APP_ID
              , arv.APP_CODE
              , arv.APP_NAME
              , arv.APP_APEX_ID
              , arv.APP_DESC
              , arv.APP_ROLE_ID
              , arv.ROLE_ID
              , arv.ROLE_CODE
              , arv.ROLE_NAME
              , arv.ROLE_DESC
            from XXAPP_APP_ROLES_V arv
            where 0 = 0
            and arv.APP_ID = ' || nvl(p_app_id, 0) || '
          ';
        when (p_type = 'GRID') then
          v_query := '
            select
              arv.APP_ROLE_ID
              , arv.APP_ID
              , arv.ROLE_ID
              , arv.ROLE_CODE
              , arv.ROLE_NAME
              , arv.ROLE_DESC
            from XXAPP_APP_ROLES_V arv
            where 0 = 0
            and arv.APP_ID = ' || nvl(p_app_id, 0) || '
          ';
        else
          v_query := q'~
            select
              arv.APP_ID
              , arv.APP_CODE
              , arv.APP_NAME
              , arv.APP_APEX_ID
              , arv.APP_DESC
              , arv.APP_ROLE_ID
              , arv.ROLE_ID
              , arv.ROLE_CODE
              , arv.ROLE_NAME
              , arv.ROLE_DESC
            from XXAPP_APP_ROLES_V arv
          ~';
      end case;

      return v_query;

    end get_all_roles_by_app;

    function get_all_pages_by_role (
      p_type varchar2 default null
    ) return clob
    is
      v_query clob;
    begin

      case
        when (p_type = 'GRID') then
          v_query := q'~
            select
              ROLE_PAGE_ID
              , APP_ROLE_ID
              , PAGE_NUMBER
              , PAGE_ALIAS
              , CAN_READ
              , CAN_WRITE
            from XXAPP_ROLE_PAGES
            where 0 = 0
            and IS_ENABLED = 'Y'
            order by PAGE_NUMBER
          ~';
        else
          v_query := q'~
            select
              ROLE_PAGE_ID
              , APP_ROLE_ID
              , PAGE_NUMBER
              , PAGE_ALIAS
              , CAN_READ
              , CAN_WRITE
              , IS_ENABLED
            from XXAPP_ROLE_PAGES
            order by PAGE_NUMBER
          ~';
      end case;

      return v_query;

    end get_all_pages_by_role;

    function get_all_pages_by_app_apex (
      p_type varchar2 default null
      , p_app_id number
    ) return clob
    is
      v_query clob;
    begin

      case
        when (p_type = 'LOV') then
          v_query := '
            select
              ''('' || aap.PAGE_ID || '') '' || aap.PAGE_NAME || '' - '' || aap.PAGE_MODE as d
              , aap.PAGE_ID as r
            from apex_application_pages aap
            join XXAPP_APPS aa
              on aa.APP_APEX_ID = aap.APPLICATION_ID
            where 0 = 0
            and aa.APP_ID = ' || nvl(p_app_id, 0) || '
            order by aap.PAGE_ID
          ';
        else
          v_query := q'~
            select
              aa.APP_ID
              , aap.APPLICATION_ID as APP_APEX_ID
              , aap.PAGE_ID
              , aap.PAGE_NAME
              , aap.PAGE_MODE
              , aa.IS_ENABLED
            from apex_application_pages aap
            join XXAPP_APPS aa
              on aa.APP_APEX_ID = aap.APPLICATION_ID
            where 0 = 0
          ~';
      end case;

      return v_query;

    end get_all_pages_by_app_apex;

end "XXAPP_QUERIES_PKG";
/
