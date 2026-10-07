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

end "XXAPP_QUERIES_PKG";
/
