# Mensajes de error configurables

Mostrar un mensaje cuyo texto no está escrito en el código: se busca por nombre y por idioma. El texto se puede corregir o traducir sin tocar la página.

**Estado:** borrador. Los dos primeros ejemplos dependen de `XXFND_NEW_MESSAGES_PKG` y de `getConfiguredMessage`, que son de otro proyecto y no están en este repositorio. Muestran la forma de la llamada; para usarlos hace falta traer esas piezas o usar el equivalente nativo de abajo.

## Desde PL/SQL

En una validación o en un proceso:

```sql
APEX_ERROR.ADD_ERROR(
  p_message => XXFND_NEW_MESSAGES_PKG.GET_MESSAGE(
    P_MESSAGE_NAME => 'pyd.subloDH'
    , P_LANGUAGE_CODE => v('BROWSER_LANGUAGE')
    , P_APPLICATION_ID => :APP_ID
  )
  , p_display_location => apex_error.c_inline_in_notification
);
```

`p_display_location` decide dónde aparece el mensaje. `c_inline_in_notification` lo pone en el área de notificaciones de la página.

## Desde JavaScript

```js
getConfiguredMessage("pyd.CercaniaVuelo").done(
  (xData) => {
    apex.message.clearErrors();
    apex.message.showErrors([makeMessage(xData)]);
  },
)
```

## Equivalente nativo de APEX

APEX trae lo mismo sin paquetes propios: **Shared Components → Text Messages**. Cada mensaje tiene un nombre, un idioma y un texto.

En PL/SQL:

```sql
apex_error.add_error(
  p_message => apex_lang.message('NOMBRE_DEL_MENSAJE')
  , p_display_location => apex_error.c_inline_in_notification
);
```

En JavaScript, si el mensaje tiene **Used in JavaScript** activado:

```js
apex.message.clearErrors();
apex.message.showErrors([
  {
    type: "error",
    location: "page",
    message: apex.lang.getMessage("NOMBRE_DEL_MENSAJE"),
    unsafe: false
  }
]);
```
