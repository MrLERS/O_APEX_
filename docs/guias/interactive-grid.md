# Interactive Grid

Dos cosas que el Interactive Grid no trae de fábrica: un botón propio en la barra de herramientas y un guardado que pasa por nuestros paquetes.

## Botón propio en la barra de herramientas

Va en la región, en **Attributes → Initialization JavaScript Function** (en versiones anteriores, *JavaScript Initialization Code*).

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

- `toolbarFind("actions3")` elige el grupo de la barra donde se agrega el botón.
- El `action` del control y el `name` de la acción tienen que ser el mismo texto: así se enlaza el botón con lo que hace.

## Guardado propio

Por defecto el grid escribe directo en su tabla. Cuando el grid sale de una vista, o guardar una fila toca más de una tabla, el proceso de guardado se cambia por código PL/SQL.

En el proceso **Interactive Grid - Automatic Row Processing (DML)** de la página: **Settings → Target Type → PL/SQL Code**.

El código se ejecuta una vez por fila modificada. `:APEX$ROW_STATUS` dice qué le pasó a la fila: `C` creada, `U` actualizada, `D` borrada. Las columnas del grid se leen como variables bind (`:ROLE_CODE`).

### Forma básica

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

Al crear, hay que devolver la llave a la columna del grid (`returning ... into`). Sin eso el grid no puede identificar la fila nueva después de guardar.

### Ejemplo real: `grid-roles` (página 100, Application Manager)

El grid muestra los roles de la app seleccionada. Sus columnas son las de `XXAPP_APP_ROLES_V`, que une dos tablas, así que crear una fila son dos `insert`: el rol en `XXAPP_ROLES` y su relación con la app en `XXAPP_APP_ROLES`.

El DML no se escribe en la página. Va en un paquete por entidad y el proceso solo los llama:

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

- Las funciones `add_*` devuelven el ID que generó el disparador, y el proceso lo asigna a la columna del grid (`:ROLE_ID := ...`).
- Una fila nueva todavía no tiene `APP_ID`, por eso se toma del item de la página: `nvl(:APP_ID, :P100_SELECTED_APP_ID)`.
- Los roles son globales. `save_app_role` actualiza `XXAPP_ROLES`, así que el cambio se ve en todas las apps que usan ese rol.
- El borrado (`'D'`) todavía no hace nada.

Paquetes: [XXAPP_ROLES_PKG.sql](../../db/xxapp/XXAPP_ROLES_PKG.sql) y [XXAPP_APP_ROLES_PKG.sql](../../db/xxapp/XXAPP_APP_ROLES_PKG.sql).
