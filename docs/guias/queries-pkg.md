# Consultas en paquete (`XXAPP_QUERIES_PKG`)

Los orígenes de reportes, LOV, grids y cards no se escriben dentro de la región de APEX. Cada uno es una función que devuelve el texto SQL, y la región la llama.

## Por qué

- La consulta queda versionada en un `.sql` y se puede buscar; dentro de APEX solo se encuentra abriendo página por página.
- La misma consulta sirve a varias páginas y a varias apps.
- Cambiar una columna es recompilar un paquete, no editar cada región que la usa.

## Cómo se usa en APEX

En la región o en el LOV, el origen es de tipo **Function Body returning SQL Query**:

```sql
return XXAPP_QUERIES_PKG.get_all_roles('LOV');
```

Con parámetros que vienen de la página:

```sql
return XXAPP_QUERIES_PKG.get_all_roles_by_app(
  p_type => 'LOV'
  , p_app_id => :P220_APP_ID
);
```

## El parámetro `p_type`

Una misma consulta se consume con formas distintas. `p_type` elige las columnas:

| `p_type`          | Devuelve |
|-------------------|----------|
| `'LOV'`           | `d` (lo que se muestra) y `r` (lo que se guarda) |
| `'REP'`, `'GRID'` | Las columnas del reporte o del Interactive Grid |
| `'CARDS'`         | Los alias `card_*` de la región [Cards](cards.md) |
| cualquier otro    | Todas las columnas, sin filtro |

## Reglas

- **El texto no termina en `;`.** APEX lo envuelve como subconsulta y el punto y coma la rompe.
- **`q'~ ... ~'`** para el texto SQL, y así no hay que escapar comillas.
- **Comilla simple solo si hay que concatenar un parámetro.** Los que se concatenan hoy son numéricos (`p_app_id`), así que no pueden inyectar SQL. Un parámetro de texto no se concatena: se referencia el item como variable bind dentro del texto (`:P220_NOMBRE`).
- **`nvl(p_app_id, 0)`** al concatenar. Mientras el item de la página está vacío, la consulta sigue siendo válida y no devuelve filas.
- Estilo de [Convenciones](../convenciones.md#estilo-de-las-consultas): comas al inicio y `where 0 = 0`.

## Ejemplo completo

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
```

## Agregar una consulta

1. Si la consulta es grande o se va a reutilizar, crea primero una vista `_V` en `db/xxapp/`.
2. Declara la función en la especificación de [XXAPP_QUERIES_PKG.sql](../../db/xxapp/XXAPP_QUERIES_PKG.sql) y escríbela en el cuerpo, con las ramas de `p_type` que necesites.
3. Compila en el workspace y prueba el texto que devuelve: `select XXAPP_QUERIES_PKG.get_all_roles('LOV') from dual`.
4. Úsala en la región con **Function Body returning SQL Query**.
5. Agrégala al catálogo de abajo.

## Catálogo

El código está en [XXAPP_QUERIES_PKG.sql](../../db/xxapp/XXAPP_QUERIES_PKG.sql).

| Función                     | Parámetros           | `p_type`               | Origen |
|-----------------------------|----------------------|------------------------|--------|
| `get_all_enabled_flags`     | —                    | —                      | `dual`: Activo / InActivo |
| `get_all_apps`              | `p_only_registered`  | —                      | `apex_applications` |
| `GET_ID_APP`                | —                    | —                      | `apex_applications` del workspace |
| `get_all_users`             | —                    | —                      | `XXAPP_USERS` |
| `get_all_roles`             | `p_type`             | `LOV`, `REP`           | `XXAPP_ROLES` |
| `get_all_registered_apps`   | `p_type`             | `LOV`, `REP`, `CARDS`  | `XXAPP_APPS` |
| `get_all_roles_by_app`      | `p_type`, `p_app_id` | `LOV`, `REP`, `GRID`   | `XXAPP_APP_ROLES_V` |
| `get_all_pages_by_role`     | `p_type`             | `GRID`                 | `XXAPP_ROLE_PAGES` |
| `get_all_pages_by_app_apex` | `p_type`, `p_app_id` | `LOV`                  | `apex_application_pages` + `XXAPP_APPS` |

Las tres primeras son anteriores al patrón y no lo siguen del todo: devuelven `L`/`V` o `d`/`v` en lugar de `d`/`r`, y `get_all_apps` no usa su parámetro. Está anotado en [Pendientes](../pendientes.md).
