# Guion de pruebas integrales – Parcial Edwing Mejía / Juan Lache

## Antes de empezar

Este guion es una lista de pruebas pendiente de ejecución en Render, **no** una certificación de que todos los pasos funcionan. Usar cuentas ficticias y documentos sin datos personales reales. Probar en un entorno de demostración sin alterar expedientes institucionales. El sistema utiliza JSP/JSTL/JSPF y PostgreSQL/Supabase.

El repositorio público **no contiene** la contraseña de Supabase. Configurar `DB_PASSWORD` únicamente en variables privadas de Render.

## Caso completo: Yebrahín 1 y Yebrahín 2

| Nº | Sesión/rol | Acción a realizar | Comprobación esperada |
|---|---|---|---|
| 01 | Público | Abrir `/`, revisar noticias, recursos, calendario. | Aparece portada; «Sistemas TG» dirige a `/login.jsp`. |
| 02 | Administrador | Crear cuenta de Yebrahín 1 como ESTUDIANTE, con identificación única, programa, plan académico, nivel y contraseña de al menos 12 caracteres. | El usuario aparece activo en Gestión de Usuarios. |
| 03 | Administrador | Cerrar sesión. | Acceso al formulario de login. |
| 04 | Yebrahín 1 / Estudiante | Iniciar sesión con credenciales recién creadas. | Panel del estudiante; sin módulos del Comité ni del Administrador. |
| 05 | Estudiante 1 | Revisar «Mi perfil» y «Habilitación académica». | Créditos, modalidad y plan muestran los datos ingresados. |
| 06 | Estudiante 1 | Abrir Banco de Ideas y seleccionar una idea **ABIERTA**, del programa y periodo **ACTIVO**. | Solo opciones elegibles; no aparece HTTP 500. |
| 07 | Estudiante 1 | Seleccionar «Elegir idea» o crear propuesta propia. | Se crea un nuevo expediente en borrador, vinculado al estudiante 1. |
| 08 | Administrador | Crear a Yebrahín 2 como ESTUDIANTE, con identificación y correo diferentes, elegible para el mismo programa. | Segunda cuenta activa. |
| 09 | Yebrahín 2 / Estudiante | Iniciar sesión y entrar en Proyectos de grado. | No aparecen expedientes ajenos. |
| 10 | Yebrahín 1 / Estudiante | Abrir Integrantes del expediente creado y vincular a Yebrahín 2 por su identificación. | El equipo incluye a ambos; no se crea un segundo expediente separado. |
| 11 | Yebrahín 2 / Estudiante | Iniciar sesión de nuevo y abrir su lista de proyectos. | Ya puede ver el expediente compartido. |
| 12 | Estudiante | Fase Pago: cargar comprobante o URL, referencia y fecha. | Se registra el pago pendiente de validación. |
| 13 | Comité | Revisar el pago y validarlo si cumple los requisitos. | Queda constancia de validación, no se salta una fase sin soporte. |
| 14 | Estudiante | Registrar y guardar propuesta F-DC-124, datos y documento requerido. | Aparece una versión del anteproyecto. |
| 15 | Comité | Asignar director y evaluador habilitados al expediente. | Aparecen los responsables correctos, sin asignar la misma persona a roles incompatibles. |
| 16 | Estudiante | Enviar propuesta a revisión. | Estado EN_REVISION si los datos, documentos y equipo cumplen todas las reglas. |
| 17 | Director | Ingresar a «Mis proyectos», abrir la propuesta y registrar observación o aval. | Acción guardada en historial, accesible solo al docente asignado. |
| 18 | Estudiante | Corregir y crear nueva versión cuando el director la devuelva. | Se mantiene trazabilidad de la versión anterior. |
| 19 | Director | Aprobar/avalar versión corregida. | La propuesta queda habilitada para evaluación según reglas de estado. |
| 20 | Evaluador | Abrir expediente propio, pulsar «Crear borrador de evaluación». | Crea un registro BORRADOR sin HTTP 500. |
| 21 | Evaluador | Responder criterios y enviar concepto CORRECCIONES o NO_APROBADO para comprobar la devolución. | Observaciones registradas; estudiante puede consultar respuesta. |
| 22 | Estudiante | Presentar las correcciones solicitadas. | Nueva versión y evidencias registradas. |
| 23 | Director y Evaluador | Repetir aval y emitir una evaluación APROBADO con criterios obligatorios diligenciados. | Evaluación DEFINITIVA aprobada, sin modificar evaluaciones anteriores. |
| 24 | Comité | Revisar evaluación y soporte de acta; registrar decisión sobre propuesta. | Solo aprueba cuando cumple estado, documentos y acta. |
| 25 | Estudiante | Continuar seguimiento de desarrollo e Informe I. | Entregas/versiones e historial visibles únicamente a integrantes y docentes asignados. |
| 26 | Estudiante | Registrar Informe Final y anexos requeridos. | Expediente pasa a revisión del informe cuando corresponda. |
| 27 | Director | Revisar Informe Final, avalar o solicitar corrección. | Queda evidencia de la decisión. |
| 28 | Evaluador | Iniciar evaluación final, registrar criterios y concepto. | Evaluación final guardada y vinculada al expediente. |
| 29 | Comité | Revisar los requisitos de sustentación, fecha y acta. | No se permite cierre sin los requisitos documentales definidos. |
| 30 | Comité | Registrar aprobación de cierre después de sustentación y evaluación final. | Proyecto FINALIZADO, historial completo. |
| 31 | Estudiante 1 y 2 | Consultar expediente, documentos y trazabilidad final. | Ambos observan exclusivamente su expediente compartido. |
| 32 | Administrador | Consultar auditoría y todos los proyectos. | Admin ve movimientos registrados; no hay acciones atribuidas a otro usuario. |

**La fase y disponibilidad de cada botón dependen de los datos de prueba.** Si el sistema bloquea el avance por criterios, periodos, documentos o pagos, registrar el mensaje y la evidencia, no manipular la base para forzar estados.

## Casos de seguridad y errores

1. Como estudiante nuevo sin proyectos, verificar que «Proyectos de grado» está vacío, no que muestre los ocho expedientes iniciales de otro estudiante.
2. Modificar manualmente un `id` de expediente ajeno en la URL y verificar que no se muestren documentos, integrantes ni historial.
3. Abrir páginas del Comité/Administrador como estudiante; debe impedir acceso.
4. Intentar crear un usuario con el mismo correo/documento; se debe informar duplicidad sin crear una segunda cuenta.
5. Validar UTF-8: nombres con tildes, ñ y símbolos no deben aparecer como «IngenierÃ­a».
6. Elegir una idea fuera de periodo o incompatible con el perfil; debe impedir el registro con mensaje controlado.
7. Intentar enviar una evaluación sin responder todos los criterios obligatorios; debe rechazar el avance.
8. Registrar devolución y comprobar que no se presenta como aprobación.
9. Verificar los archivos y los permisos por rol.
10. Probar el login, rutas y recursos CSS en Render después del despliegue.

## Correcciones de octubre de 2026

- `estudiante/banco.jsp`: `CURRENT_DATE()` → `CURRENT_DATE` para PostgreSQL.
- `acciones/guardar.jsp`: variable JSP `final` reemplazada por `totalCierre` para resolver fallo de compilación EL.
- `acciones/guardar.jsp`: conversiones explícitas a `bigint` y `smallint` en alta de usuarios.
- `index.jsp` y `css/portada-uts.css`: portada pública informativa, acceso «Sistemas TG» al login actual.

La cuenta inicial «Estudiante registrado» figura como integrante de varios expedientes de demostración en Supabase; eso no implica que todo estudiante nuevo tenga acceso a ellos. La comprobación debe hacerse con usuarios nuevos y expedientes propios.

## Evidencia a conservar

Fecha, rol, expediente, acción, resultado esperado, resultado obtenido (✅/❌), URL, captura y observaciones. No adjuntar contraseñas, cadenas de conexión o datos privados de la base al repositorio.
