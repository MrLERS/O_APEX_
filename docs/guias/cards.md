# Cards

La región Cards arma cada tarjeta con las columnas de la consulta. Usamos siempre los mismos alias (`card_*`), para que cualquier consulta se pueda conectar a una región Cards sin volver a mapear columnas.

## Plantilla de la consulta

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

Lo que la tarjeta no usa se deja en `null`, sin quitar la columna.

En **Attributes** de la región se asigna cada alias a su atributo: Title, Subtitle, Body, Secondary Body, Icon, Badge y Media.

## Ejemplo: tarjetas de aplicaciones

La consulta es la rama `'CARDS'` de `get_all_registered_apps`, en [XXAPP_QUERIES_PKG.sql](../../db/xxapp/XXAPP_QUERIES_PKG.sql):

```sql
select
  a.APP_ID as card_primary_key
  , null as card_secondary_key
  , a.APP_NAME as card_title
  , a.APP_CODE as card_subtitle
  , a.DESCRIPTION as card_body
  , null as card_secondary_body
  , null as card_icon
  , case a.IS_ENABLED
      when 'Y' then
        'Activo'
      else
        'InActivo'
    end as card_badge
  , null as card_image
from XXAPP_APPS a
order by a.APP_ID
```

En la región, con origen **Function Body returning SQL Query**:

```sql
return XXAPP_QUERIES_PKG.get_all_registered_apps('CARDS');
```

El patrón de las funciones está en [Consultas en paquete](queries-pkg.md).
