# Anotaciones
Aqui se anotaran las cosas que se fueron ocupando a lo largo de la practica

## Prompt's
Listado de prompts

### Prompt 1
Quiero hacer una practica en Oracle APEX.

Mi inteción es crear 3 aplicaciones:
1. Gestor de Applicaciones
   * Esta app se encargara de gestionar:
       - apps
       - usuarios
       - roles
       - app_roles
       - user_roles
       - role_pages
2. Baul de aplicaciones
   * Esta app mostrar las apps que tiene disponibles el usuario dependiendo de los roles que tenga(ejp: admin = ve todo, colab = solo Laboratorio)
   * Su proposito es ser la entrada principal y compartir la sesión con las demas apps(SSO)
3. Laboratorio
   * Esta app sera donde practiquemos cosas de APEX
       - Como primera practica realizare un "BPM"

Necesito tu ayuda con los scripts de BD.
- estandarizar los nombrados en ingles
- Dado que es un abiente de pruebas gratuito, simularemos tener diferentes esquemas
- El prefijo de los objetos de BD seran los siguientes dependiendo de la app XXAPP y XXLAB
- Los subfijos seran:
  * secuencias: "_SEQ"
  * disparadores: "_TRG"
  * paquetes: "_PKG"
  * vistas: "_V"
- Todas las tablas deben contar con:
  * columnas de auditoria
     - Evita usar "IS_ACTIVE", mejor usa "IS_ENABLED"
  * secuencias
  * disparadores

Por ahora solo necesito XXAPP

### Prompt 2
Quiero customizar el login con un paquete "XXAPP_AUTH_PKG" dedicado
Este paquete contara con una función "process_login"
Aparte del paquete, puedes guiarme en para lograr ese login custom?

### Prompt 3
- Crea una vista llamada "XXAPP_CREDENTIALS_V"
  - esta vista ayudara a saber si el usuario tiene credenciales para esa app
- modifica el "PROCESS_LOGIN" para que haga uso de "XXAPP_CREDENTIALS_V"

---

