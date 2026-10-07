# Ajax Callback

Sirve para pedir datos al servidor desde JavaScript sin enviar la página: el usuario elige algo y otros campos se llenan solos.

Son dos piezas: un proceso PL/SQL que responde JSON y una función de JavaScript que lo llama.

**Estado:** el ejemplo está armado a partir de fragmentos de la práctica y no se ha probado completo en una página.

## 1. El proceso en el servidor

En la página: **Processing → Ajax Callback → Create Process**. El nombre va en `UPPER_SNAKE_CASE`; aquí, `GET_APP_DATA`.

Lo que manda JavaScript en `x01` … `x20` llega como `apex_application.g_x01` … `g_x20`. La respuesta se escribe con `apex_json`:

```sql
declare
  v_app_id   XXAPP_APPS.APP_ID%type := to_number(apex_application.g_x01);
  v_app_code XXAPP_APPS.APP_CODE%type;
  v_app_name XXAPP_APPS.APP_NAME%type;
begin

  select
    a.APP_CODE
    , a.APP_NAME
  into
    v_app_code
    , v_app_name
  from XXAPP_APPS a
  where 0 = 0
  and a.APP_ID = v_app_id;

  -- Open a new JSON object
  apex_json.open_object;

  -- Write a key-value pair to the JSON object
  apex_json.write('APP_CODE', v_app_code);
  apex_json.write('APP_NAME', v_app_name);

  -- Close the JSON object
  apex_json.close_object;

end;
```

## 2. La llamada desde JavaScript

En **Function and Global Variable Declaration** de la página, o en un archivo `.js` de la app. La función va en `camelCase`.

```js
const fetchDataApp = (appId) => {
  const spinner$ = apex.util.showSpinner();
  apex.message.clearErrors();

  const result = apex.server.process("GET_APP_DATA", {
    x01: appId
  });

  result.done(function (data) {
    if (data) {
      apex.item("P110_APP_CODE").setValue(data.APP_CODE);
      apex.item("P110_APP_NAME").setValue(data.APP_NAME);
    }

    apex.message.showPageSuccess("Datos cargados!");
  }).fail(function (jqXHR, textStatus, errorThrown) {
    apex.message.showErrors([
      {
        type: "error",
        location: "page",
        message: "Error al buscar los datos!",
        unsafe: false
      }
    ]);
  }).always(function () {
    spinner$.remove();
  });
};
```

- El primer argumento de `apex.server.process` es el nombre del proceso, tal cual se creó.
- Para mandar items de la página en lugar de valores sueltos se usa `pageItems`: `{ pageItems: ["P1_DEPTNO", "P1_EMPNO"] }`. En el servidor se leen como `:P1_DEPTNO`.
- `always` quita el spinner tanto si la llamada salió bien como si falló.
