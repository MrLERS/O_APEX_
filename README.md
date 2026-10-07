# O_APEX_ — Guía viva de Oracle APEX

> Mausequeherramientas que nos servirán más tarde.

Convenciones, guías y scripts que vamos juntando al implementar soluciones en Oracle APEX. Sirve para dos cosas: consultar cómo se resuelve algo (un grid con guardado propio, un login personalizado, una llamada SOAP) y acordar entre todos cómo lo escribimos.

No es una aplicación y no tiene build. Las guías se leen aquí; los scripts se ejecutan a mano contra el esquema.

Es una guía viva: está incompleta a propósito y crece con lo que cada quien va resolviendo. Para sumar algo, lee [Cómo contribuir](CONTRIBUTING.md).

## Por dónde empezar

| Si quieres…                                                   | Ve a |
|---------------------------------------------------------------|------|
| Saber cómo nombramos objetos, páginas y componentes           | [Convenciones](docs/convenciones.md) |
| Entender el sistema que usan los ejemplos                     | [Arquitectura](docs/arquitectura.md) |
| Resolver algo puntual en APEX                                 | [Guías](#guías) |
| Montar los objetos de base de datos en tu esquema             | [Instalación](#instalar-los-objetos-de-base-de-datos) |
| Ver qué temas faltan o qué está roto                          | [Temario](docs/temario.md) y [Pendientes](docs/pendientes.md) |

## Guías

| Guía | Qué resuelve | Estado |
|------|--------------|--------|
| [Consultas en paquete](docs/guias/queries-pkg.md)       | Orígenes de reportes, LOV, grids y cards como funciones que devuelven SQL | En uso |
| [Interactive Grid](docs/guias/interactive-grid.md)      | Botón propio en la barra de herramientas y guardado por paquetes | En uso |
| [Cards](docs/guias/cards.md)                            | Plantilla de consulta con los alias `card_*` | En uso |
| [Ajax Callback](docs/guias/ajax-callback.md)            | Pedir datos al servidor desde JavaScript y llenar items | Borrador |
| [Login personalizado](docs/guias/login-personalizado.md) | Esquema de autenticación contra nuestras tablas de usuarios y roles | Borrador |
| [Web services](docs/guias/web-services.md)              | SOAP y REST con `APEX_WEB_SERVICE`; reporte de BI Publisher a una colección | Borrador |
| [Mensajes de error](docs/guias/mensajes-de-error.md)    | Mensajes configurables por nombre e idioma | Borrador |

## Estructura

```
├── README.md
├── CONTRIBUTING.md        Cómo agregar o corregir contenido
├── docs/
│   ├── convenciones.md    Nombrado y estilo en BD y en APEX
│   ├── arquitectura.md    El caso práctico: tres apps, usuarios, roles, permisos
│   ├── temario.md         Temas cubiertos y por cubrir
│   ├── pendientes.md      Lo que falta, no compila o hay que sincronizar
│   ├── bitacora.md        Prompts con los que se generaron los scripts
│   ├── guias/             Una guía por tema (_plantilla.md para empezar una)
│   └── apps/              Material por aplicación y por página
└── db/
    ├── install.sql        Instala todo en orden (SQLcl o SQL*Plus)
    └── xxapp/             Un script por objeto, con el nombre del objeto
```

## Instalar los objetos de base de datos

Los scripts usan `/` como terminador, así que corren en SQL Workshop, SQLcl y SQL*Plus.

Con SQLcl o SQL*Plus, desde la raíz del repositorio:

```
@db/install.sql
```

En SQL Workshop no existe `@@`: sube cada archivo a **SQL Scripts** y ejecútalos en este orden.

| # | Script | Crea |
|---|--------|------|
| 1 | [XXAPP_DDL.sql](db/xxapp/XXAPP_DDL.sql)                     | Tablas, secuencias, disparadores, índices y datos de ejemplo |
| 2 | [XXAPP_CREDENTIALS_V.sql](db/xxapp/XXAPP_CREDENTIALS_V.sql) | Vista que dice si un usuario tiene acceso a una app |
| 3 | [XXAPP_APP_ROLES_V.sql](db/xxapp/XXAPP_APP_ROLES_V.sql)     | Vista de roles por app |
| 4 | [XXAPP_ROLES_PKG.sql](db/xxapp/XXAPP_ROLES_PKG.sql)         | Escrituras sobre roles |
| 5 | [XXAPP_APP_ROLES_PKG.sql](db/xxapp/XXAPP_APP_ROLES_PKG.sql) | Escrituras sobre roles por app |
| 6 | [XXAPP_QUERIES_PKG.sql](db/xxapp/XXAPP_QUERIES_PKG.sql)     | Consultas para reportes, LOV, grids y cards |
| 7 | [XXAPP_AUTH_PKG.sql](db/xxapp/XXAPP_AUTH_PKG.sql)           | Login personalizado. **Todavía no compila.** |

Después de instalar, cambia los `APP_APEX_ID` de `XXAPP_APPS` por los IDs reales de tus aplicaciones: los del DDL (100 a 102) son de relleno.

> **Cuidado:** [XXAPP_TRUNCATE.sql](db/xxapp/XXAPP_TRUNCATE.sql) borra los datos de todas las tablas `XXAPP%` y reinicia sus secuencias en 1. No forma parte de la instalación.

## Estado

El repositorio va detrás del workspace de APEX, que es la fuente de verdad:

- Las aplicaciones APEX no están exportadas aquí; solo los objetos de base de datos y las notas.
- Los scripts 3 a 5 y parte del 6 se armaron a partir de fragmentos de las notas y no se han compilado contra una base de datos.
- `XXAPP_AUTH_PKG` depende de una columna y una vista que no están en el repositorio.

El detalle, y la lista de lo que hay que sincronizar, está en [Pendientes](docs/pendientes.md).
