# Buenas practicas

## BD

### Nombrado de objetos

#### Prefijo y Subfijo

"XX<SCHEMA>_" + "<NOMBRE_OBJETO>" + "<TIPO_OBJETO>"

| Objeto          | Prefijo | Subfijo | CODE      |
|-----------------|---------|---------|-----------|
| Tabla           | Si      | No      |           |
| Vistas          | Si      | Si      | _V / _VW  |
| Procedimiento   | Si      | Si      | _P / _PRC |
| Funsión         | Si      | Si      | _F / _FUN |
| Paquetes        | Si      | Si      | _PKG      |
| Disparadores    | Si      | Si      | _TRG      |
| Secuencias      | Si      | Si      | _SEQ      |

#### Paquetes: Procesos, funciones, etc...

```sql
create or replace package body "XXAPP_QUERIES_PKG" as

    function get_all_enabled_flags
    return varchar2
    is
      v_query varchar2(200);
    begin

      v_query := '
        select 
            \'\Activo\'\ as L
            , \'\Y\'\ as V
        from dual
        union
        select 
            \'\InActivo\'\ as L
            , \'\N\'\ as V
        from dual
      ';

      return v_query;
    -- Evitar
    -- end;

    -- Desado
    end get_all_enabled_flags;

end "XXAPP_QUERIES_PKG";
```

### Proposito de las vistas
El proposito de las vistas, es conbtener aquellas consultas **"grandes/avanzadas/complejas"** que puedan ser reutilizables.

#### Ejemplo:
- Nombre: `XXAPP_APP_ROLES_V`
- Script:
```sql
CREATE OR REPLACE FORCE EDITIONABLE VIEW "XXAPP_APP_ROLES_V" ("APP_ID", "APP_CODE", "APP_NAME", "APP_APEX_ID", "APP_DESC", "APP_ROLE_ID", "ROLE_ID", "ROLE_CODE", "ROLE_NAME", "ROLE_DESC") AS
select
    a.APP_ID
    , a.APP_CODE
    , a.APP_NAME
    , a.APP_APEX_ID
    , a.DESCRIPTION as APP_DESC
    , ar.APP_ROLE_ID
    , r.ROLE_ID
    , r.ROLE_CODE
    , r.ROLE_NAME
    , r.DESCRIPTION as ROLE_DESC
from XXAPP_APPS a 
join XXAPP_APP_ROLES ar
  on ar.APP_ID = a.APP_ID
join XXAPP_ROLES r
  on r.ROLE_ID = ar.ROLE_ID
where 0 = 0
 and a.IS_ENABLED = 'Y'
 and ar.IS_ENABLED = 'Y'
 and r.IS_ENABLED = 'Y';
```
- Registrar sus uso mediante una función en `XXAPP_QUERIES_PKG`:
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

---

## APEX

### Creación de paginas

#### Numeración

Para paginas principales **"centenas"**(ejp: 100, 200, 300, n...)

Para paginas del mismo modulo **"decenas"**(ejp: 110, 115, 120, n...)

**Evitar:**
| #   | Pagina    | Tipo    |
|-----|-----------|---------|
| 1   | Home      | Pagina  |
| 2   | Usuarios  | Lista   |
| 3   | Roles     |         |
| 4   | Apps      |         |
| 5   | Paginas   |         |
| 6   | Usuarios  | Formulario  |
| 7   | Paginas   | Formulario  |
| 8   | Apps      | Formulario  |
| 9   | Roles     | Formulario  |
| 10  | Usuarios - Roles | Formulario  |
| 11  | Apps - Roles | Formulario  |

**Deseado**
| #   | Pagina    | Tipo    |
|-----|-----------|---------|
| 1   | Home      | Pagina  |
| 100   | Usuarios  | Lista   |
| 110   | Usuarios  | Formulario  |
| 120  | Usuarios - Roles | Formulario  |
| 200   | Roles     |         |
| 205   | Roles - Usarios     |         |
| 210   | Roles - Paginas     |         |
| 215   | Roles - Paginas - Permisos     |         |
| 220   | Roles - Modales     |         |
| 300   | Apps      |         |
| 310  | Apps - Roles | Formulario  |
| 400   | Paginas   |         |

### Componentes Compartidos
Nombrado es **"UPPER_SNAKE_CASE"** con subfijo **_LOV**

### Nombrado de "Regiones", "Botones"

Se prioriza "lower-snake-case" sobre "UPPER_SNAKE_CASE"
El "camelCase" "PascalCase"


### Creación de "Dynamic Action"

#### Nombrado
Al ser eventos JavaScript el nombra debe ser en **"camelCase"**

```js
function nombreFuncion {}

const nombreFuncion = () => {}
```

#### Orden de ejecución
Se ejcutan de acuerdo al valor de **"Execuion -> Sequence"**


### Ajax Callback

#### Nombrado

Priorizar **"UPPER_SNAKE_CASE"**


```sql
apex_application.g_x01

-- Open a new JSON object
apex_json.open_object;

-- Write a key-value pair to the JSON object
apex_json.write('FROM_NB', FROM_NB_V);

-- Write another key-value pair to the JSON object
apex_json.write('TILL_NB', TILL_NB_V);

-- Close the JSON object
apex_json.close_object;
```

```js
const fetchDataApp = () => {
  const spinner$ = apex.util.showSpinner();
  apex.message.clearErrors();

  var result = apex.server.process( "MY_PROCESS", {
      x01: "test",
      pageItems: ["P1_DEPTNO","P1_EMPNO"]
  } );

  result.done( function( data ) {
    if (data) {
      $("#P110_APP_CODE").val();
      $("#P110_APP_NAME").val();
    }

    apex.message.showPageSuccess( "Datos cargados!" );
  } ).fail(function( jqXHR, textStatus, errorThrown ) {
    apex.message.showErrors( [
      {
        type:       "error",
        location:   "page",
        message:    "Error al buscar lso datos!",
        unsafe:     false
      }
    ] );
  } ).always( function() {
      spinner$.remove();
  } );
}
```



### Workin Copies

- feature/<SIGLAS>-ejmple_de_nombrado
- fix/<SIGLAS>-ejmple_de_nombrado
- hotfix/<SIGLAS>-ejmple_de_nombrado

Ejemplo:
- feature/AJGC3-list_cards
- feature/GJL2-enabled_n_disabled_button

