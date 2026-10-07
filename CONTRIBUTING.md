# Cómo contribuir

La guía sirve si lo que aprendiste resolviendo algo queda escrito donde el siguiente lo encuentra. No hace falta que esté terminado: un borrador marcado como borrador vale más que una nota que nunca se subió.

## Dónde va cada cosa

| Tengo…                                               | Va en |
|------------------------------------------------------|-------|
| Una forma de resolver algo en APEX                   | Una guía en [docs/guias/](docs/guias/) |
| Una regla de nombrado o de estilo                    | [docs/convenciones.md](docs/convenciones.md) |
| Una tabla, vista, paquete o disparador               | Un script en [db/](db/) |
| Código o configuración de una página concreta        | El archivo de su app en [docs/apps/](docs/apps/) |
| Algo roto, incompleto o por decidir                  | [docs/pendientes.md](docs/pendientes.md) |
| Un tema que habría que cubrir                        | [docs/temario.md](docs/temario.md) |
| El prompt con el que generé un script                | [docs/bitacora.md](docs/bitacora.md) |

## Escribir una guía

1. Copia [docs/guias/_plantilla.md](docs/guias/_plantilla.md) con un nombre en minúsculas y con guiones: `subir-archivos.md`.
2. Ponle de título lo que resuelve, no el nombre del API.
3. Marca el estado. **Borrador** si no lo probaste completo o depende de algo que no está aquí, y di qué le falta. **En uso** si funciona en una app.
4. Agrégala a la tabla de guías del [README](README.md) y al [temario](docs/temario.md).

Lo que hace útil a una guía:

- **Di dónde se configura en APEX**, con la ruta de menús. El código solo no alcanza si no se sabe en qué propiedad de qué componente va.
- **Explica el porqué** de lo que no es obvio.
- **Código que compile.** Si es un fragmento o no lo probaste, dilo.
- **Sin datos reales.** Nada de hosts de ambientes, usuarios, contraseñas, tokens ni datos de personas. Usa marcadores: `https://{host}/...`.

## Agregar un objeto de base de datos

1. Un archivo por objeto en `db/<prefijo>/`, con el nombre del objeto: `XXAPP_ROLES_PKG.sql`. Especificación y cuerpo de un paquete van en el mismo archivo.
2. Sigue las [convenciones](docs/convenciones.md): prefijo, sufijo, columnas de auditoría, `IS_ENABLED`.
3. Agrégalo a [db/install.sql](db/install.sql) en el lugar que le toca por sus dependencias, y a la tabla de instalación del [README](README.md).
4. El script es la única copia del código. Las guías lo enlazan; si necesitan mostrar un fragmento, que sea corto.

**El workspace es la fuente de verdad.** Si cambias un objeto en APEX, exporta el cambio al script en el mismo movimiento. Si sabes que un script quedó atrás, anótalo en [pendientes](docs/pendientes.md).

## Idioma

- La prosa va en español.
- Los nombres de objetos, las columnas y los comentarios dentro del SQL van en inglés.

## Proponer el cambio

Trabaja en una rama y abre un pull request. Para el nombre de la rama sirve el mismo patrón de las working copies de APEX:

- `feature/<SIGLAS>-nombre_del_cambio`
- `fix/<SIGLAS>-nombre_del_cambio`

Si corriges algo que está en [pendientes](docs/pendientes.md), bórralo de ahí en el mismo cambio.
