# Notas

## Cards

### Template base
```sql
select
  -- data
  card_primary_key,    -- primary key
  card_secondary_key,  -- secondary key if needed
  card_title,          -- title
  card_subtitle,       -- subtitle
  card_body,           -- card body text
  card_secondary_body, -- card secondary text, positioned near bottom

  -- ui and other attributes
  card_icon,           -- icon class, e.g. fa-cloud
  card_badge,          -- badge, can be a small text
  card_image           -- image url, url or blob columns
from dual
```

## Grids

### Add Custom Button on Toolbar

```js
function(config) {
  var $ = apex.jQuery;
  var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar();
  var toolbarGroup = toolbarData.toolbarFind("actions3");
  // Example label
  let restoreLabel = "Restore Default Department";
  // Add button
  toolbarGroup.controls.push({
    type: "BUTTON",
    action: "cust-restore-default",
    label: restoreLabel,
    iconBeforeLabel: true
  });
  // Define button action
  config.initActions = function(actions) {
    actions.add({
      name: "cust-restore-default",
      action: function() {
        apex.message.alert("Restore button clicked!");
      }
    });
  };
  config.toolbarData = toolbarData;
  return config;
}
```

### Custom Save Process
- Ejemplo **PL/SQL** basico
```sql
begin
  case :APEX$ROW_STATUS
  when 'C' then
      insert into emp ( empno, ename, deptno )
      values ( :EMPNO, :ENAME, :DEPTNO )
      returning rowid into :ROWID;
  when 'U' then
      update emp
          set ename  = :ENAME,
              deptno = :DEPTNO
        where rowid  = :ROWID;
  when 'D' then
      delete emp
        where rowid = :ROWID;
  end case;
end;
```

---

## Queries
Queries registradas en `XXAPP_QUERIES_PKG`

### get_all_users

- Specification
  ```sql
  function get_all_users
  return clob;
  ```
- Body
  ```sql
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
  ```
- Function Body returning SQL Query
  ```sql
  return XXAPP_QUERIES_PKG.get_all_users();
  ```

### get_all_roles

- Specification
  ```sql
  function get_all_roles (
    p_type varchar2
  ) return clob;
  ```
- Body
  ```sql
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
            r.ROLE_ID as r
            , r.ROLE_NAME as d
          from XXAPP_ROLES r
          where 0 = 0
          and IS_ENABLED = 'Y'
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
  ```
- Function Body returning SQL Query
  ```sql
  return XXAPP_QUERIES_PKG.get_all_roles();
  ```

### get_all_registered_apps

- Specification
  ```sql
  function get_all_registered_apps (
    p_type varchar2
  ) return clob;
  ```
- Body
  ```sql
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
          app_id as card_primary_key
          , null as card_secondary_ke
          , app_name as card_title
          , app_code as card_subtitle
          , description as card_body
          , null as card_secondary_body
          , null as card_icon
          , case IS_ENABLED
              when 'Y' then
                'Activo'
              else
                'InActivo'
            end as card_badge
          , null as card_image
        from xxapp_apps
        order by app_id
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
  ```
- Function Body returning SQL Query
  ```sql
  return XXAPP_QUERIES_PKG.get_all_registered_apps();
  ```

### get_all_roles_by_app

- Specification
  ```sql
  function get_all_roles_by_app (
    p_type varchar2 default null
    , p_app_id number
  ) return clob;
  ```
- Body
  ```sql
  function get_all_roles_by_app (
    p_type varchar2
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
          and arv.APP_ID = ' || nvl(p_app_id, 0) || ';
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
          and arv.APP_ID = ' || p_app_id || ';
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
          and arv.APP_ID = ' || p_app_id || '
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
          from XXAPP_APP_ROLES_V arv;
        ~';
    end case;

    return v_query;

  end get_all_roles_by_app;
  ```
- Function Body returning SQL Query
  ```sql
  return XXAPP_QUERIES_PKG.get_all_roles_by_app(
    p_type => 'LOV'
    , p_app_id => :P220_APP_ID
  );
  ```

### get_all_pages_by_role
- Specification
  ```sql
  function get_all_pages_by_role (
    p_type varchar2 default null
  ) return clob;
  ```
- Body
  ```sql
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
        from xxapp_role_pages
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
        from xxapp_role_pages
        order by PAGE_NUMBER
        ~';
    end case;

    return v_query;
  end get_all_pages_by_role;
  ```
- Use
  ```sql
  XXAPP_QUERIES_PKG.get_all_pages_by_role('GRID');
  ```

### get_all_pages_by_app_apex
- Specification
  ```sql
  function get_all_pages_by_app_apex (
    p_type varchar2 default null
    , p_app_id number
  ) return clob;
  ```
- Body
  ```sql
  function get_all_pages_by_app_apex (
    p_type varchar2 default null
    , p_app_id number
  ) return clob
  is
    v_query clob;
  begin
    case p_type
      when 'LOV' then
        v_query := '
        select
          ''('' || aap.PAGE_ID || '') '' || aap.PAGE_NAME || '' - '' || PAGE_MODE as D
          , aap.PAGE_ID as R
        from apex_application_pages aap
        join XXAPP_APPS aa
        on aa.APP_APEX_ID = aap.APPLICATION_ID
        where 0 = 0
        and aa.APP_ID = '|| p_app_id || '
        order by aap.PAGE_ID
        ';
      else
        v_query := '
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
        ';
    end case;

    return v_query;
  end get_all_pages_by_app_apex;
  ```
- Use
  ```sql
  XXAPP_QUERIES_PKG.get_all_pages_by_app_apex(
    p_type => 'LOV'
    , p_app_id => :
  );
  ```

---

## Packages
Documentación de **Funciones** y **Procesos** por **Paquete**

### XXAPP_ROLES_PKG

#### add_role

- Specification
  ```sql
  function add_role (
    P_ROLE_CODE in varchar2
    , P_ROLE_NAME in varchar2
    , P_ROLE_DESC in varchar2
  ) return number;
  ```
- Body
  ```sql
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
  ```
- Use
  ```sql
  XXAPP_ROLES_PKG.add_role (
    P_ROLE_CODE => :ROLE_CODE
    , P_ROLE_NAME => :ROLE_NAME
    , P_ROLE_DESC => :ROLE_DESC
  ):
  ```

### XXAPP_APP_ROLES_PKG

#### add_app_role

- Specification
  ```sql
  function add_app_role (
    P_ROLE_ID in number
    , P_APP_ID in number
  ) return number;
  ```
- Body
  ```sql
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
  ```
- PL/SQL Code to Insert/Update/Delete
  ```sql
  XXAPP_APP_ROLES_PKG.add_app_role(
    P_ROLE_ID => :ROLE_ID
    , P_APP_ID => :APP_ID
  );
  ```

#### save_app_role

- Specification
  ```sql
  procedure save_app_role (
    P_APP_ROLE_ID in number
    , P_ROLE_ID in number
    , P_ROLE_CODE in varchar2
    , P_ROLE_NAME in varchar2
    , P_ROLE_DESC in varchar2
  );
  ```
- Body
  ```sql
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
  ```
- PL/SQL Code to Insert/Update/Delete
  ```sql
  XXAPP_APP_ROLES_PKG.save_app_role (
    P_APP_ROLE_ID => :APP_ROLE_ID
    , P_ROLE_ID => :ROLE_ID
    , P_ROLE_CODE => :ROLE_CODE
    , P_ROLE_NAME => :ROLE_NAME
    , P_ROLE_DESC => :ROLE_DESC
  );
  ```

---

## Paginas
Material por pagina

### 100 - Apps N Roles

#### Grid ( grid-roles )

- Code to Insert/Update/Delete
  ```sql
  begin
    case :APEX$ROW_STATUS
    when 'C' then
      :ROLE_ID := XXAPP_ROLES_PKG.add_role (
        P_ROLE_CODE => :ROLE_CODE
        , P_ROLE_NAME => :ROLE_NAME
        , P_ROLE_DESC => :ROLE_DESC
      );

      :APP_ROLE_ID := XXAPP_APP_ROLES_PKG.add_app_role(
        P_ROLE_ID => :ROLE_ID
        , P_APP_ID => nvl(:APP_ID, :P100_SELECTED_APP_ID)
      );

    when 'U' then
      XXAPP_APP_ROLES_PKG.save_app_role (
        P_APP_ROLE_ID => :APP_ROLE_ID
        , P_ROLE_ID => :ROLE_ID
        , P_ROLE_CODE => :ROLE_CODE
        , P_ROLE_NAME => :ROLE_NAME
        , P_ROLE_DESC => :ROLE_DESC
      );
    when 'D' then
      null;
    end case;
  end;
  ```

### 200 - User N Roles

---

## Consultas pendientes

```sql
select
    , arp.ROLE_PAGE_ID
    , arp.APP_ROLE_ID
    , arp.PAGE_NUMBER
    , arp.PAGE_ALIAS
    , arp.CAN_READ
    , arp.CAN_WRITE
    , arp.IS_ENABLED
from XXAPP_ROLE_PAGES arp


select
    '( ' || aap.PAGE_ID || ' ) ' || aap.PAGE_NAME || ' - ' || aap.PAGE_MODE as D
    , aap.PAGE_ID as R
from apex_application_pages aap
where 0 = 0
and APPLICATION_ID = 58317
order by PAGE_ID

```
