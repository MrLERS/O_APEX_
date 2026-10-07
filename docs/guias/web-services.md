# Web services (`APEX_WEB_SERVICE`)

Llamar un servicio SOAP o REST desde PL/SQL y trabajar con lo que responde.

**Estado:** borrador. La sintaxis y los ejemplos 1 y 2 vienen de la documentación de Oracle. La práctica contra Fusion está sin terminar; ver [Lo que falta](#lo-que-falta).

## SOAP: `MAKE_REQUEST`

### Sintaxis

```sql
APEX_WEB_SERVICE.MAKE_REQUEST (
  p_url                  IN VARCHAR2,
  p_action               IN VARCHAR2 DEFAULT NULL,
  p_version              IN VARCHAR2 DEFAULT '1.1',
  p_envelope             IN CLOB,
  p_username             IN VARCHAR2 DEFAULT NULL,
  p_password             IN VARCHAR2 DEFAULT NULL,
  p_scheme               IN VARCHAR2 DEFAULT 'Basic',
  p_proxy_override       IN VARCHAR2 DEFAULT NULL,
  p_transfer_timeout     IN NUMBER   DEFAULT 180,
  p_wallet_path          IN VARCHAR2 DEFAULT NULL,
  p_wallet_pwd           IN VARCHAR2 DEFAULT NULL,
  p_https_host           IN VARCHAR2 DEFAULT NULL
) RETURN sys.xmltype;
```

### Parámetros

| Parámetro            | Descripción |
|----------------------|-------------|
| `p_url`              | The URL endpoint of the Web service. |
| `p_action`           | The SOAP Action corresponding to the operation to be invoked. |
| `p_version`          | The SOAP version (1.1 or 1.2). The default is 1.1. |
| `p_envelope`         | The SOAP envelope to post to the service. |
| `p_username`         | The username if basic authentication is required for this service. |
| `p_password`         | The password if basic authentication is required for this service. |
| `p_scheme`           | The authentication scheme. Basic (default), AWS, Digest, or OAUTH_CLIENT_CRED if supported by your database release. |
| `p_proxy_override`   | The proxy to use for the request. The proxy supplied overrides the proxy defined in the application attributes. |
| `p_transfer_timeout` | The amount of time in seconds to wait for a response. |
| `p_wallet_path`      | The file system path to a wallet if the URL endpoint is HTTPS. For example, `file:/usr/home/oracle/WALLETS`. The wallet path provided overrides the wallet defined in the instance settings. |
| `p_wallet_pwd`       | The password to access the wallet. |
| `p_https_host`       | The host name to be matched against the common name (CN) of the remote server's certificate for an HTTPS request. |

### Ejemplo 1

```sql
DECLARE
    l_envelope  CLOB;
    l_xml       XMLTYPE;
BEGIN
    l_envelope := '<?xml version="1.0" encoding="UTF-8"?>
    <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:tns="http://www.ignyte.com/whatsshowing"
    xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <soap:Body>
            <tns:GetTheatersAndMovies>
                <tns:zipCode>43221</tns:zipCode>
                <tns:radius>5</tns:radius>
            </tns:GetTheatersAndMovies>
        </soap:Body>
    </soap:Envelope>';

    l_xml := apex_web_service.make_request(
        p_url => 'http://www.ignyte.com/webservices/ignyte.whatsshowing.webservice/moviefunctions.asmx',
        p_action => 'http://www.ignyte.com/whatsshowing/GetTheatersAndMovies',
        p_envelope => l_envelope
    );
END;
```

### Ejemplo 2

```sql
DECLARE
    l_xml sys.xmltype;
BEGIN
    l_xml := apex_web_service.make_request(
        p_url            => 'http://{host}:{port}/path/to/soap/service/',
        p_action         => 'doSoapRequest',
        p_envelope       => '{SOAP envelope in XML format}' );
END;
```

---

## REST: `MAKE_REST_REQUEST`

Ejemplo base; todavía no hay una práctica propia con REST.

```sql
DECLARE
    l_response CLOB;
BEGIN
    apex_web_service.set_request_headers(
        p_name_01  => 'Content-Type',
        p_value_01 => 'application/json'
    );

    l_response := apex_web_service.make_rest_request(
        p_url         => 'https://{host}/path/to/resource',
        p_http_method => 'GET'
    );

    IF apex_web_service.g_status_code != 200 THEN
        raise_application_error(-20001, 'HTTP ' || apex_web_service.g_status_code);
    END IF;
END;
```

`make_rest_request` no falla cuando el servicio responde 4xx o 5xx: devuelve el cuerpo de la respuesta. El código HTTP queda en `apex_web_service.g_status_code` y hay que revisarlo.

---

## Práctica: reporte de BI Publisher (Fusion) a una `apex_collection`

Pide un reporte de BI Publisher en CSV por SOAP y carga sus filas en una colección, para mostrarlas en un reporte o un grid sin crear una tabla.

Los pasos:

1. Armar el envelope de `runReport` con los parámetros del reporte.
2. Llamar el servicio. La respuesta trae el archivo en base64 dentro de `reportBytes`.
3. Sacar `reportBytes`, pasarlo a `BLOB` y de ahí a `CLOB`: ese es el CSV.
4. Partir el CSV en líneas y guardar cada línea como un miembro de la colección.

```sql
DECLARE
  -- Replace with the host of your Fusion environment and the path of your report
  c_host         CONSTANT VARCHAR2(200) := 'https://{pod}.fa.{region}.oraclecloud.com';
  c_report_path  CONSTANT VARCHAR2(500) := '/Integration/COMMON/HCM/Worker/ALL_REP_EMPLOYEES_DATA_ONLY_TEST.xdo';

  l_envelope      CLOB;
  l_response_xml  XMLTYPE;
  l_param         CLOB;
  l_report_byts   CLOB;
  l_report_csv    CLOB;
  l_blob          BLOB;
  l_line          VARCHAR2(32767);
  l_seq           PLS_INTEGER := 1;
BEGIN
  l_param := '
    <pub:parameterNameValues>
      <pub:item>
        <pub:name>P_FH_INI</pub:name>
        <pub:values>
          <pub:item>2026-01-01T00:00:00.000 -06:00</pub:item>
        </pub:values>
      </pub:item>
      <pub:item>
        <pub:name>P_FH_FIN</pub:name>
        <pub:values>
          <pub:item>2026-01-10T12:00:44.017 -06:00</pub:item>
        </pub:values>
      </pub:item>
    </pub:parameterNameValues>
  ';

  l_envelope := '
  <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:pub="http://xmlns.oracle.com/oxp/service/PublicReportService">
    <soap:Header/>
    <soap:Body>

      <pub:runReport>
        <pub:reportRequest>
          <pub:attributeFormat>csv</pub:attributeFormat>
          <pub:attributeTemplate>default_csv</pub:attributeTemplate>
          <pub:reportAbsolutePath>' || c_report_path || '</pub:reportAbsolutePath>
          ' || l_param || '
          <pub:flattenXML>false</pub:flattenXML>
          <pub:sizeOfDataChunkDownload>-1</pub:sizeOfDataChunkDownload>
        </pub:reportRequest>
      </pub:runReport>

    </soap:Body>
  </soap:Envelope>
  ';

  -- Realizamos la solicitud al web service
  l_response_xml := apex_web_service.make_request(
      p_url => c_host || '/xmlpserver/services/ExternalReportWSSService?wsdl',
      p_envelope => l_envelope
  );

  -- Parseamos el resultado del web service
  -- Obtenemos el resultado del reporte en base64
  l_report_byts := apex_web_service.PARSE_XML_CLOB(
    P_XML => l_response_xml,
    P_XPATH => '//*:reportBytes/text()'
  );

  -- Convertimos el resultado a BLOB
  l_blob := apex_web_service.clobbase642blob(l_report_byts);

  -- Convertimos el resultado a CLOB
  -- De esta forma obtenemos un csv en CLOB
  l_report_csv := apex_web_service.blob2clob(l_blob, nls_charset_id('AL32UTF8'));

  -- Leer el csv que viene de la respuesta del web service
  dbms_output.put_line(l_report_csv);

  -- Guardar en apex_collections
  IF apex_collection.collection_exists('OTBI_REPORT_DATA') THEN
    apex_collection.delete_collection('OTBI_REPORT_DATA');
  END IF;

  apex_collection.create_collection('OTBI_REPORT_DATA');

  FOR r IN (
    SELECT regexp_substr(l_report_csv, '[^' || chr(10) || ']+', 1, level) AS csv_line
    FROM   dual
    CONNECT BY regexp_substr(l_report_csv, '[^' || chr(10) || ']+', 1, level) IS NOT NULL
  ) LOOP

    -- omite la línea de encabezado (la primera) si no la quieres en la collection
    IF l_seq = 1 THEN
      l_seq := l_seq + 1;
      CONTINUE;
    END IF;

    l_line := rtrim(r.csv_line, chr(13)); -- quita el CR si el CSV viene con CRLF

    apex_collection.add_member(
      p_collection_name => 'OTBI_REPORT_DATA',
      p_c001 => regexp_substr(l_line, '[^,]+', 1, 1),   -- PERSON_ID
      p_c002 => regexp_substr(l_line, '[^,]+', 1, 2),   -- PERSON_NUMBER
      p_c003 => regexp_substr(l_line, '[^,]+', 1, 3),   -- BUSINESS_UNIT
      p_c004 => regexp_substr(l_line, '[^,]+', 1, 4),   -- JOB_NAME
      p_c005 => regexp_substr(l_line, '[^,]+', 1, 5),   -- DEPARTMENT_NAME
      p_c006 => regexp_substr(l_line, '[^,]+', 1, 6),   -- POSITION_CODE
      p_c007 => regexp_substr(l_line, '[^,]+', 1, 7),   -- MIDDLE_NAMES
      p_c008 => regexp_substr(l_line, '[^,]+', 1, 8),   -- LAST_NAME
      p_c009 => regexp_substr(l_line, '[^,]+', 1, 9),   -- SECOND_NAME
      p_c010 => regexp_substr(l_line, '[^,]+', 1, 10),  -- FIRST_NAME
      p_c011 => regexp_substr(l_line, '[^,]+', 1, 11),  -- FULL_NAME
      p_c012 => regexp_substr(l_line, '[^,]+', 1, 12),  -- EMAIL
      p_c013 => regexp_substr(l_line, '[^,]+', 1, 13),  -- PERSON_NUMBER_M
      p_c014 => regexp_substr(l_line, '[^,]+', 1, 14),  -- FULL_NAME_M
      p_c015 => regexp_substr(l_line, '[^,]+', 1, 15),  -- JOB_LEVEL
      p_c016 => regexp_substr(l_line, '[^,]+', 1, 16),  -- JOB_CODE
      p_c017 => regexp_substr(l_line, '[^,]+', 1, 17),  -- JOB_FAMILY
      p_c018 => regexp_substr(l_line, '[^,]+', 1, 18),  -- HIRING_DATE
      p_c019 => regexp_substr(l_line, '[^,]+', 1, 19),  -- TERMINATION_DATE
      p_c020 => regexp_substr(l_line, '[^,]+', 1, 20),  -- POSITION_NAME
      p_c021 => regexp_substr(l_line, '[^,]+', 1, 21),  -- USER_STATUS
      p_c022 => regexp_substr(l_line, '[^,]+', 1, 22),  -- EXPENSE_ACCOUNT
      p_c023 => regexp_substr(l_line, '[^,]+', 1, 23),  -- POSITION_CODE_PARENT
      p_c024 => regexp_substr(l_line, '[^,]+', 1, 24),  -- POSITION_NAME_PARENT
      p_c025 => regexp_substr(l_line, '[^,]+', 1, 25),  -- LEGAL_EMPLOYER
      p_c026 => regexp_substr(l_line, '[^,]+', 1, 26),  -- COUNTRY
      p_c027 => regexp_substr(l_line, '[^,]+', 1, 27),  -- CREATION_DATE
      p_c028 => regexp_substr(l_line, '[^,]+', 1, 28),  -- LAST_UPDATE_DATE
      p_c029 => regexp_substr(l_line, '[^,]+', 1, 29)   -- TAX_REGISTRATION
    );

    l_seq := l_seq + 1;
  END LOOP;
END;
```

La colección se consulta después así:

```sql
select
  c001 as PERSON_ID
  , c002 as PERSON_NUMBER
  , c011 as FULL_NAME
from apex_collections
where 0 = 0
and collection_name = 'OTBI_REPORT_DATA'
```

### Lo que falta

El bloque no se ha ejecutado completo. Antes de usarlo:

- **Autenticación.** La llamada no manda usuario ni contraseña y el `<soap:Header/>` va vacío; el servicio de Fusion la va a rechazar. Las credenciales no se escriben en el código: van en una Web Credential de APEX.
- **Versión de SOAP.** El envelope usa el namespace de SOAP 1.2 y `p_version` se queda en su valor por defecto, `'1.1'`. Probablemente haya que mandar `p_version => '1.2'`.
- **`apex_web_service.blob2clob`.** No aparece en la documentación pública del paquete. Si no compila, la conversión de `BLOB` a `CLOB` hay que hacerla con otra función.
- **Campos vacíos.** `regexp_substr(l_line, '[^,]+', 1, n)` se salta los campos vacíos, así que una fila con un valor nulo recorre todas las columnas siguientes. Tampoco entiende comas dentro de un valor entre comillas. `apex_data_parser.parse` lee el CSV completo y evita los dos problemas.
- **Tamaño.** `dbms_output.put_line` falla con líneas de más de 32,767 bytes; con un reporte real hay que quitarlo.
