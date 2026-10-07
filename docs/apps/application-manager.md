# Application Manager (`XXAPP`)

La aplicación que mantiene apps, usuarios, roles y acceso a páginas. Existe solo en el workspace; aquí se anota lo que hace cada página y qué código usa, para poder reconstruirla o copiar un patrón.

El modelo de datos está en [Arquitectura](../arquitectura.md).

## Páginas

| #   | Página       | Documentada |
|-----|--------------|-------------|
| 100 | Apps N Roles | Sí          |
| 200 | User N Roles | No          |

## 100 - Apps N Roles

### Grid (`grid-roles`)

Roles de la app seleccionada en `P100_SELECTED_APP_ID`.

- **Origen:** las columnas coinciden con `XXAPP_QUERIES_PKG.get_all_roles_by_app` con `p_type => 'GRID'`. Falta confirmarlo en el workspace.
- **Guardado:** proceso PL/SQL con `case :APEX$ROW_STATUS` que llama a `XXAPP_ROLES_PKG` y `XXAPP_APP_ROLES_PKG`. El código y su explicación están en [Interactive Grid](../guias/interactive-grid.md#ejemplo-real-grid-roles-página-100-application-manager).

## 200 - User N Roles

Sin documentar.
