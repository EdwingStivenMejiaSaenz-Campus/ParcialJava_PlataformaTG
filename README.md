# ParcialJava_PlataformaTG

Plataforma de gestión de trabajos de grado UTS, desarrollada en JSP para Apache Tomcat 8.5 con PostgreSQL.

## Estructura

- `index.jsp`, `login.jsp`, `dashboard.jsp`: acceso y panel principal.
- `estudiante/`, `director/`, `evaluador/`, `comite/`, `admin/`: módulos por perfil.
- `acciones/` y `comun/`: funcionalidades compartidas.
- `WEB-INF/`: configuración, fragmentos JSPF, librerías y material de verificación.
- `css/`, `js/`, `img/`: recursos visuales.

## Ejecutar en local

1. Copiar los archivos del proyecto en `C:\xampp\tomcat\webapps\Parcial_EdwingMejia_JuanLache\`.
2. Configurar la base de datos PostgreSQL en `WEB-INF/web.xml` de tu instalación local. El campo `DB_PASSWORD` incluye un marcador y no es una contraseña válida.
3. Iniciar Tomcat desde XAMPP y abrir `http://localhost:8080/Parcial_EdwingMejia_JuanLache/`.

Para más detalles, consultar `INSTRUCCIONES.txt`.

> **Importante:** el repositorio es público. No publicar contraseñas, tokens ni copias locales de `web.xml` con credenciales reales. La versión incluida usa un marcador de posición para la contraseña.
