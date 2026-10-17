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

## Desplegar en Render

1. Crear un **Web Service** con este repositorio, rama `main`, región **Oregon** y **Language: Docker**.
2. Dejar **Root Directory** vacío y usar `./Dockerfile` como **Dockerfile Path**.
3. Seleccionar plan **Free** si es para la demostración o pruebas.
4. En **Environment Variables**, crear `DB_PASSWORD` con la contraseña vigente de PostgreSQL/Supabase. **No ponerla en archivos públicos ni en commits.**
5. Hacer clic en **Deploy Web Service**. Tomcat 9 sirve el proyecto desde la raíz `/` en el puerto `10000`.
6. Probar `/login.jsp`, el inicio de sesión y las operaciones que usan la base de datos. El despliegue del servidor no garantiza que las tablas y funciones SQL sean compatibles.

La configuración `WEB-INF/web.xml` utiliza `${DB_PASSWORD:-CONFIGURAR_LOCALMENTE}` y la imagen Docker activa `EnvironmentPropertySource` de Tomcat, para leer `DB_PASSWORD` en tiempo de ejecución. La opción local sigue permitiendo sustituir el marcador en tu copia privada del archivo.

**Importante:** en un plan Free el servidor se suspende tras periodos de inactividad y se reactiva al recibir visitas. Conserva los datos permanentes en PostgreSQL, no en el disco local del contenedor.
