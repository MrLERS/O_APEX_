# Convenciones

Cómo nombramos y escribimos las cosas en base de datos y en APEX. Si una guía contradice este documento, manda este documento; si una regla ya no sirve, se cambia aquí y no en cada guía.

## Base de datos

### Nombrado de objetos

`XX<ESQUEMA>_<NOMBRE><SUFIJO>`

El prefijo hace las veces de esquema: como el ambiente de práctica es gratuito y solo hay un esquema, `XXAPP`, `XXVAULT` y `XXLAB` separan los objetos de cada aplicación.

| Objeto        | Prefijo | Sufijo              | Ejemplo             |
|---------------|---------|---------------------|---------------------|
| Tabla         | Sí      | No                  | `XXAPP_ROLES`       |
| Vista         | Sí      | `_V` (o `_VW`)      | `XXAPP_APP_ROLES_V` |
| Paquete       | Sí      | `_PKG`              | `XXAPP_QUERIES_PKG` |
| Disparador    | Sí      | `_TRG`              | `XXAPP_ROLES_TRG`   |
| Secuencia     | Sí      | `_SEQ`              | `XXAPP_ROLES_SEQ`   |
| Procedimiento | Sí      | `_P` (o `_PRC`)     |                     |
| Función       | Sí      | `_F` (o `_FUN`)     |                     |

Los objetos que ya existen usan la forma corta (`_V`, `_P`, `_F`). Usa esa salvo que haya una razón para no hacerlo.

Las restricciones e índices toman el nombre de su tabla más un sufijo, como en [XXAPP_DDL.sql](../db/xxapp/XXAPP_DDL.sql): `_PK`, `_UK`, `_FK`, `_CK` e `_IX`.

### Tablas

Toda tabla lleva:

- Las cuatro columnas de auditoría: `CREATED_BY`, `CREATED_DATE`, `UPDATED_BY`, `UPDATED_DATE`.
- Una secuencia (`_SEQ`) y un disparador (`_TRG`). El disparador llena la llave primaria desde la secuencia y mantiene la auditoría con `V('APP_USER')`, o `USER` si no hay sesión de APEX.
- `IS_ENABLED` (`'Y'` / `'N'`) como bandera de borrado lógico. No usar `IS_ACTIVE`.

Por eso los `insert` omiten el ID y las columnas de auditoría:

```sql
insert into XXAPP_ROLES (ROLE_CODE, ROLE_NAME, DESCRIPTION)
values ('ADMIN', 'Administrator', 'Full access to all applications and configuration');
```

### Paquetes

Los subprogramas se cierran con su nombre, no con un `end;` suelto:

```sql
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

    -- Evitar
    -- end;

    -- Deseado
    end get_all_enabled_flags;

end "XXAPP_QUERIES_PKG";
```

### Estilo de las consultas

- Comas al inicio de la línea.
- `where 0 = 0` y después una línea por condición, todas con `and`. Así se puede comentar cualquier condición sin romper la consulta.
- El texto SQL dentro de PL/SQL va entre `q'~ ... ~'`, para no escapar comillas. Solo se usa comilla simple cuando hay que concatenar un parámetro.

```sql
select
  r.ROLE_ID
  , r.ROLE_CODE
  , r.ROLE_NAME
from XXAPP_ROLES r
where 0 = 0
and r.IS_ENABLED = 'Y'
```

### Vistas

Una vista guarda una consulta grande o compleja que se va a reutilizar. Si la consulta es simple o se usa una sola vez, no necesita vista.

Ejemplo: [XXAPP_APP_ROLES_V](../db/xxapp/XXAPP_APP_ROLES_V.sql) une apps, roles y su relación.

La vista no se consulta directo desde APEX: se expone con una función en `XXAPP_QUERIES_PKG` (aquí, `get_all_roles_by_app`). El patrón está en [Consultas en paquete](guias/queries-pkg.md).

---

## APEX

### Numeración de páginas

- **Centenas** para la página principal de un módulo: 100, 200, 300…
- **Decenas y cincos** para las páginas dentro de ese módulo: 110, 115, 120…
- La página 1 es Home.

Con la numeración corrida no se sabe a qué módulo pertenece una página, ni queda lugar para insertar una nueva junto a las suyas.

**Evitar**

| #  | Página           | Tipo       |
|----|------------------|------------|
| 1  | Home             | Página     |
| 2  | Usuarios         | Lista      |
| 3  | Roles            |            |
| 4  | Apps             |            |
| 5  | Páginas          |            |
| 6  | Usuarios         | Formulario |
| 7  | Páginas          | Formulario |
| 8  | Apps             | Formulario |
| 9  | Roles            | Formulario |
| 10 | Usuarios - Roles | Formulario |
| 11 | Apps - Roles     | Formulario |

**Deseado**

| #   | Página                     | Tipo       |
|-----|----------------------------|------------|
| 1   | Home                       | Página     |
| 100 | Usuarios                   | Lista      |
| 110 | Usuarios                   | Formulario |
| 120 | Usuarios - Roles           | Formulario |
| 200 | Roles                      |            |
| 205 | Roles - Usuarios           |            |
| 210 | Roles - Páginas            |            |
| 215 | Roles - Páginas - Permisos |            |
| 220 | Roles - Modales            |            |
| 300 | Apps                       |            |
| 310 | Apps - Roles               | Formulario |
| 400 | Páginas                    |            |

### Componentes compartidos

Las listas de valores se nombran en `UPPER_SNAKE_CASE` con sufijo `_LOV`.

### Regiones y botones

En minúsculas antes que en `UPPER_SNAKE_CASE`. Ejemplo: `grid-roles`.

### Dynamic Actions y JavaScript

Los nombres van en `camelCase`, porque son eventos y funciones de JavaScript:

```js
function nombreFuncion() {}

const nombreFuncion = () => {};
```

Las acciones de un Dynamic Action se ejecutan en el orden de **Execution → Sequence**.

### Ajax Callback

El nombre del proceso va en `UPPER_SNAKE_CASE`. El ejemplo completo está en [Ajax Callback](guias/ajax-callback.md).

### Working copies

- `feature/<SIGLAS>-nombre_del_cambio`
- `fix/<SIGLAS>-nombre_del_cambio`
- `hotfix/<SIGLAS>-nombre_del_cambio`

Ejemplos:

- `feature/AJGC3-list_cards`
- `feature/GJL2-enabled_n_disabled_button`
