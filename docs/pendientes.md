# Pendientes

Lo que falta, lo que no compila y lo que hay que sincronizar con el workspace. Quien cierre un punto lo borra de aquí.

## El repositorio va detrás del workspace

El workspace `XXLERS_DEV` es la fuente de verdad y los archivos lo reflejan solo en parte.

- Las aplicaciones APEX (páginas, componentes compartidos, esquemas de autenticación) no están exportadas. Sin el export no se puede reconstruir ninguna app desde aquí.
- Tres scripts y cinco funciones se armaron a partir de fragmentos de las notas, no de un export. Ver [Scripts reconstruidos](#scripts-reconstruidos-desde-las-notas).

## Base de datos

- **`XXAPP_AUTH_PKG` no compila.** Usa la columna `PWD` de `XXAPP_CREDENTIALS_V` y la vista `XXAPP_USER_INFO_V`; ninguna de las dos está en el repositorio. Hay que exportarlas del workspace.
- **Contraseñas en texto plano.** El login compara `PWD = p_password` y `SAVE_CREDENTIALS` guarda la contraseña en el estado de sesión. Detalle en [Login personalizado](guias/login-personalizado.md#lo-que-falta).
- **Datos de ejemplo.** Los `APP_APEX_ID` del DDL (100 a 102) son de relleno.
- **`XXVAULT` y `XXLAB`** no tienen objetos todavía.
- **Borrado en `grid-roles`.** La rama `'D'` del guardado no hace nada.
- **`save_app_role`** recibe `P_APP_ROLE_ID` y no lo usa.
- **Funciones de `XXAPP_QUERIES_PKG` que no siguen el patrón:**
  - `get_all_enabled_flags` devuelve `L` / `V` y `get_all_apps` devuelve `d` / `v`; la convención para un LOV es `d` / `r`.
  - `get_all_apps` no usa su parámetro `p_only_registered`.
  - `GET_ID_APP` tiene fijo el nombre del workspace (`'XXLERS_DEV'`).

## Scripts reconstruidos desde las notas

No se compilaron contra una base de datos. Hay que compararlos con lo que hay en el workspace:

- [XXAPP_APP_ROLES_V.sql](../db/xxapp/XXAPP_APP_ROLES_V.sql)
- [XXAPP_ROLES_PKG.sql](../db/xxapp/XXAPP_ROLES_PKG.sql)
- [XXAPP_APP_ROLES_PKG.sql](../db/xxapp/XXAPP_APP_ROLES_PKG.sql)
- En [XXAPP_QUERIES_PKG.sql](../db/xxapp/XXAPP_QUERIES_PKG.sql): `get_all_roles`, `get_all_registered_apps`, `get_all_roles_by_app`, `get_all_pages_by_role` y `get_all_pages_by_app_apex`.

Al armarlos se corrigió lo siguiente respecto a los fragmentos. Si el workspace tiene el código original, estos cambios hay que llevarlos allá:

| Dónde | Cambio |
|-------|--------|
| `get_all_roles_by_app` | Se quitó el `;` al final del texto SQL en las ramas `LOV`, `REP` y por defecto. |
| `get_all_roles_by_app` | `p_type` lleva `default null` también en el cuerpo; solo lo tenía la especificación y así no compila. |
| `get_all_roles_by_app`, `get_all_pages_by_app_apex` | `nvl(p_app_id, 0)` en todas las ramas que concatenan el parámetro; antes solo en `LOV`. |
| `get_all_registered_apps` | El alias `card_secondary_ke` pasó a `card_secondary_key`. |
| `XXAPP_AUTH_PKG` | La especificación declaraba `GET_CREDENTIALS` y el cuerpo define `SAVE_CREDENTIALS`; quedó `SAVE_CREDENTIALS` en los dos. Se agregó el `;` que faltaba después del `SELECT ... INTO`. |

## Guías

- **[Web services](guias/web-services.md).** La práctica contra Fusion no está terminada: falta la autenticación y hay cuatro puntos más por verificar, listados en la guía.
- **[Mensajes de error](guias/mensajes-de-error.md).** Depende de un paquete y una función de JavaScript de otro proyecto.
- **[Ajax Callback](guias/ajax-callback.md).** El ejemplo no se ha probado completo en una página.
- **[Convenciones](convenciones.md#regiones-y-botones).** Falta decidir el formato exacto de los nombres de regiones y botones. La nota original decía "lower-snake-case" y el único ejemplo es `grid-roles`, que va con guion.
- **[Application Manager](apps/application-manager.md).** La página 200 no está documentada.

## Consultas sueltas

Consultas que todavía no son una función de `XXAPP_QUERIES_PKG`.

Páginas por rol, con alias de tabla:

```sql
select
  arp.ROLE_PAGE_ID
  , arp.APP_ROLE_ID
  , arp.PAGE_NUMBER
  , arp.PAGE_ALIAS
  , arp.CAN_READ
  , arp.CAN_WRITE
  , arp.IS_ENABLED
from XXAPP_ROLE_PAGES arp
```

Páginas de una app de APEX como LOV, filtrando por el ID de APEX y no por `XXAPP_APPS.APP_ID`:

```sql
select
  '( ' || aap.PAGE_ID || ' ) ' || aap.PAGE_NAME || ' - ' || aap.PAGE_MODE as d
  , aap.PAGE_ID as r
from apex_application_pages aap
where 0 = 0
and aap.APPLICATION_ID = 58317
order by aap.PAGE_ID
```
