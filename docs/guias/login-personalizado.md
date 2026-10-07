# Login personalizado

Un esquema de autenticación propio: en lugar de validar contra las cuentas de APEX, el login pregunta a nuestras tablas si el usuario tiene acceso a la aplicación a la que quiere entrar.

**Estado:** borrador. `XXAPP_AUTH_PKG` no compila con lo que hay en el repositorio; ver [Lo que falta](#lo-que-falta) antes de tomarlo como referencia.

## Cómo funciona

1. La página de login de APEX llama a `apex_authentication.login` con el usuario y la contraseña.
2. APEX ejecuta la función del esquema de autenticación: `XXAPP_AUTH_PKG.PROCESS_LOGIN`.
3. `PROCESS_LOGIN` pasa el usuario a mayúsculas y llama a `HAS_ACCESS`.
4. `HAS_ACCESS` busca al usuario en `XXAPP_CREDENTIALS_V` para la app de `V('APP_ID')`.
5. Si devuelve `TRUE`, APEX crea la sesión. Si devuelve `FALSE`, el login falla.

`XXAPP_CREDENTIALS_V` cruza todos los usuarios con todas las apps y marca `HAS_ACCESS = 'Y'` cuando el usuario tiene al menos un rol habilitado en esa app. El modelo está en [Arquitectura](../arquitectura.md#modelo-de-acceso).

## Configurarlo en una app

1. Compila [XXAPP_CREDENTIALS_V.sql](../../db/xxapp/XXAPP_CREDENTIALS_V.sql) y [XXAPP_AUTH_PKG.sql](../../db/xxapp/XXAPP_AUTH_PKG.sql).
2. Registra la app en `XXAPP_APPS` con su ID real de APEX en `APP_APEX_ID`. Los IDs se consultan así:

   ```sql
   select
     application_id
     , application_name
   from apex_applications
   order by application_id
   ```

3. Da al usuario un rol en esa app (`XXAPP_APP_ROLES` y `XXAPP_USER_ROLES`).
4. En la app: **Shared Components → Authentication Schemes → Create**.
   - *Based on a pre-configured scheme from the gallery*
   - **Scheme Type:** Custom
   - **Authentication Function Name:** `XXAPP_AUTH_PKG.PROCESS_LOGIN`
5. Marca el esquema como actual (**Make Current Scheme**).

La función que usa el esquema debe tener esta firma. APEX la llama con esos nombres de parámetro:

```sql
function PROCESS_LOGIN (
    p_username in varchar2,
    p_password in varchar2
) return boolean;
```

## Cuando el login falla sin explicación

`PROCESS_LOGIN` tiene `WHEN OTHERS THEN RETURN FALSE`. Cualquier error (una vista que no existe, una columna mal escrita, un `APP_ID` que no convierte a número) se ve igual que una contraseña equivocada.

Lo primero es preguntar a la vista qué ve para ese usuario:

```sql
select
  USERNAME
  , APP_CODE
  , APP_APEX_ID
  , HAS_ACCESS
from XXAPP_CREDENTIALS_V
where 0 = 0
and USERNAME = 'MI_USUARIO'
```

- Sin filas: el usuario no existe o está deshabilitado.
- `HAS_ACCESS = 'N'`: existe, pero no tiene un rol habilitado en esa app.
- `APP_APEX_ID` distinto del ID de la app: la app está registrada con un ID de relleno.

## Lo que falta

- **No compila.** `HAS_ACCESS` filtra por una columna `PWD` que `XXAPP_CREDENTIALS_V` no tiene en este repositorio, y `SAVE_CREDENTIALS` lee de `XXAPP_USER_INFO_V`, que tampoco está. Las dos cosas existen solo en el workspace y hay que exportarlas.
- **La contraseña se compara en texto plano** (`PWD = p_password`). Antes de usar este login fuera de la práctica hay que guardar un hash y comparar contra el hash.
- **`SAVE_CREDENTIALS` guarda la contraseña en el estado de sesión** (`SESSION_PWD`). Hoy la llamada está comentada. No debe activarse así: la contraseña no tiene por qué salir de la función de login.
- **El `WHEN OTHERS`** debería al menos registrar el error (`apex_debug.error`) antes de devolver `FALSE`.
