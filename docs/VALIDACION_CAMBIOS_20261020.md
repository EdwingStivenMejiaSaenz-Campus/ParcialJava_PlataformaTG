# Validación de cambios · Plataforma TG · 20 de octubre de 2026

## Alcance

Cambios en la portada pública, alta de usuarios, Banco de Ideas, visibilidad de proyectos por rol y evaluación de propuestas/informes. No se han modificado datos existentes, contraseñas, variables de Render ni el flujo de inicio de sesión.

## Comprobaciones realizadas (sin escritura en base de datos)

- Inspección de código y comparación con la rama `main`.
- Verificación de balance de etiquetas JSTL/JSP y formularios en los 11 archivos intervenidos (sin incidencias en esas reglas).
- Consulta read-only a Supabase: esquema `uts_grado` disponible y periodo 2026-2 activo.
- Consulta read-only de elegibilidad: un estudiante de prueba habilitado y una idea seleccionable.
- Consulta read-only del Banco de Ideas con el filtro nuevo: SQL válido, devuelve ideas.
- `EXPLAIN` read-only del SQL de creación de usuario y del cambio de estado de evaluación: ambas sentencias aceptadas por PostgreSQL.
- Expediente de referencia ID 5: `PROPUESTA / EN_REVISION`, evaluador asignado, todavía sin aval del Director. El botón de crear evaluación queda deshabilitado explicando por qué, sin alterar fases.

**No está verificado:** servidor JSP compilado y abierto en Render, datos persistidos después de formularios, envío real de email, permisos con sesiones de los cinco roles, pago de prueba y recorrido completo hasta cierre. No se deben declarar aprobados estos casos antes de ejecutarlos.

## Recorrido funcional a ejecutar en Render

1. **Portada/login** (sin credenciales en capturas): abrir `/` en móvil y PC; comprobar imágenes, navegación y enlaces; ingresar por `/login.jsp` y cerrar sesión.
2. **Administrador, altas**: iniciar sesión como Administrador, ir a Usuarios > Crear nuevo usuario. Comprobar que abre `/admin/nuevo_usuario.jsp`. Crear un ESTUDIANTE **de prueba** con identificación y correo únicos, programa/nivel/plan y requisitos académicos correctos. Verificar que aparece en la tabla y puede autenticarse. Repetir con Director y Evaluador si no hay cuentas de prueba habilitadas. No compartir contraseñas en la entrega.
3. **Permisos**: autenticarse como Estudiante. `/estudiante/proyectos.jsp` debe listar solo sus proyectos. Si intenta visitar `/comun/proyectos_visual.jsp` debe volver a `Mis proyectos`; abrir expedientes de otros usuarios por ID tampoco debe revelar sus datos. Administrador/Comité ven la lista institucional. Director/Evaluador ven solo asignaciones.
4. **Banco de Ideas**: desde perfil Estudiante, entrar al Banco de Ideas y elegir una idea académicamente habilitada. Debe crear exactamente **un** proyecto BORRADOR del estudiante conectado, con su ID en `proyecto_estudiantes`; después, la misma idea ya inscrita no debe estar disponible para reinscribirla mientras siga activa. Probar otra cuenta no autorizada y verificar rechazo.
5. **Integrantes**: agregar segundo estudiante de prueba habilitado, sin duplicación; comprobar el límite de integrantes previsto por modalidad.
6. **Fase 1**: registrar soporte de pago **de prueba** y permitir a Comité validarlo conforme reglas vigentes. Verificar historial, sin utilizar comprobantes reales.
7. **Propuesta**: cargar F-DC-124 de prueba y completar campos, enviar propuesta a revisión. Director asignado escribe observación y avanza de `EN_REVISION` a `AVAL_DIRECTOR` cuando cumple los requisitos.
8. **Evaluador**: antes del aval del Director, `/evaluador/evaluacion.jsp?id=5` debe explicar el bloqueo. Tras el aval correspondiente en **un expediente de prueba**, crear borrador, guardar criterios y emitir concepto.
9. **Correcciones**: emitir `CORRECCIONES` en propuesta de prueba; confirmar que el proyecto pasa a `CON_OBSERVACIONES` y que el Estudiante puede corregir y reenviar. Nuevo aval del Director debe permitir otra evaluación sin borrar la anterior.
10. **Aprobación**: repetir con concepto `APROBADO`, verificar `EVALUADA` y decisión formal del Comité para entrar en DESARROLLO. Continuar con informe final, evaluación y sustentación si existen los documentos, perfiles y condiciones.
11. **Regresión**: revisar dashboard, notificaciones, historial, pagos y documentos; inspeccionar errores 403/404/500, JSP SQL, sesiones y fallos de formulario; recargar para confirmar persistencia real.

## Seguridad para la revisión

- Usar exclusivamente registros identificados como prueba y no cambiar proyectos reales ni usuarios ajenos.
- Guardar evidencia con URL, rol, acción, resultado, fecha y captura (sin credenciales).
- No subir `WEB-INF/web.xml` con claves, cadenas de conexión, backups o tokens a GitHub.
- No integrar esta rama en `main` ni desplegar hasta verificar las pruebas de Render, especialmente altas, evaluación y permisos por rol.


## Incidencias adicionales recibidas (capturas de Render, 20 oct 2026)

- **Pago: fecha_pago PostgreSQL DATE**. Captura: error `column "fecha_pago" is of type date but expression is of type character varying`. Corregido en `acciones/guardar.jsp` usando `CAST(NULLIF(?::text,'') AS date)` y validación de longitud de la fecha. En `estudiante/pagos.jsp` se aclara que la URL HTTPS o el comprobante almacenado son obligatorios. Se ejecutó `EXPLAIN` del INSERT con fecha `2026-10-20` contra `uts_grado`, sin efectuar escrituras. **No se probó el POST real en Render**.
- **Banco de Ideas: HTTP 500 en consulta SQL**. Se ejecutó `EXPLAIN` de la consulta de `estudiante/banco.jsp` en las ramas `main` y esta rama con la base real; ambas se analizaron sin error SQL. La captura de Render corresponde a una versión desplegada que muestra una falla distinta: es indispensable desplegar la nueva fuente y probarla allí.
- **guardar.jsp: error de análisis EL ${final.rows[0].total eq 0}**. Esa expresión **no existe** en `acciones/guardar.jsp` de esta rama. La captura de Render puede reflejar un despliegue desactualizado. No declarar corregido en servidor hasta confirmar el nuevo build.
- **Acceso por estudiante**: lectura de datos: los **11 proyectos existentes están asociados al mismo estudiante de prueba (ID 2)**; es el único ESTUDIANTE en la base consultada. El filtrado por dueño no ocultará proyectos que efectivamente pertenecen a ese mismo usuario. Para comprobar aislamiento, crear otra cuenta de prueba y revisar que no vea estos proyectos. No reasignar ni eliminar registros existentes.
