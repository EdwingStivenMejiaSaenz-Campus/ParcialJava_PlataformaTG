# Guion de demostración para el profesor — Edwing y Juan

**Plataforma TG UTS** — Recorrido real de estudiantes, administrador, comité, director y evaluador.

El código está diseñado para ejecutar este flujo con enlaces HTTPS de Google Drive en vez de subir archivos físicos. La demostración debe realizarse con usuarios y proyectos de práctica. No usar comprobantes bancarios reales ni compartir contraseñas.

## Guion de 20 pasos

1. **Administrador**: iniciar sesión desde `login.jsp`.
2. **Administrador**: abrir `Usuarios` → `+ Crear nuevo usuario`, registrar a **Yebrahín1** con rol *Estudiante* y seleccionar programa.
3. **Yebrahín1**: iniciar sesión.
4. **Yebrahín1**: abrir **Banco de ideas** y elegir una idea abierta compatible con su programa.
5. **Yebrahín1**: pulsar inscribir idea, comprobar que aparece en **Mis proyectos** y **anotar su código UTS-...**.
6. **Administrador**: iniciar sesión de nuevo.
7. **Administrador**: crear a **Yebrahín2**, también *Estudiante* y **en el mismo programa**.
8. **Yebrahín2**: iniciar sesión.
9. **Yebrahín2**: ir a **Mis proyectos → Unirme a un proyecto existente**. Pegar código `UTS-...` de Yebrahín1 y pulsar Unirme. Comprobar que ambos figuran como integrantes del **mismo proyecto**.
10. **Yebrahín2**: abrir **Pago y fases**, pegar el enlace HTTPS al comprobante en Google Drive y enviarlo. Ver estado **PENDIENTE**.
11. **Comité**: iniciar sesión.
12. **Comité**: abrir **Fase 1 · Validar pagos**, revisar el enlace y pulsar **Aceptar pago · pasar a Fase 2**. Se habilita el F-DC-124.
13. **Yebrahín2**: volver a **Pago y fases**, comprobar **pago aprobado** y pegar el enlace de Google Drive del **F-DC-124**. El proyecto se envía automáticamente si ya tiene Director; de lo contrario queda guardado para su asignación.
14. **Comité**: abrir **Proyectos de grado → Asignar docentes**, seleccionar **Director** y **Evaluador** activos. Si el F-DC-124 y el pago ya estaban guardados, el sistema pasa automáticamente a **EN_REVISION**.
15. **Administrador**: entrar a **Usuarios** y mostrar que están Yebrahín1 y Yebrahín2.
16. **Director asignado**: ir a **Docente Director → Abrir expediente**. Abrir el enlace de Drive del F-DC-124 y pulsar **Avalar propuesta y pasar a evaluación**.
17. **Evaluador asignado**: abrir **Docente Evaluador → Abrir evaluación**, elegir **Solicitar correcciones** y escribir las observaciones. La propuesta queda **CON_OBSERVACIONES**.
18. **Yebrahín2**: abrir **Pago y fases**, consultar las observaciones y registrar el **nuevo enlace corregido** del F-DC-124. Con Director asignado, vuelve automáticamente a **EN_REVISION**.
19. **Director**: volver a avalar la propuesta. **Evaluador**: revisar el enlace actualizado y emitir **Aprobar propuesta**.
20. **Comité**: abrir **Aprobación final**, pulsar **Aprobación final · pasar de fase** en el proyecto con estado **EVALUADA**. Debe finalizar en **DESARROLLO / APROBADO**.

## Correcciones técnicas incluidas

- IDs `proyecto_id`, `usuario_id` y claves relacionadas convertidos explícitamente a `BIGINT` en las operaciones del recorrido, incluidos historial y auditoría.
- Alta de usuarios con programa obligatorio desde el formulario nuevo.
- El segundo estudiante se vincula mediante el código, sin crear otra idea.
- Pago presentado por enlace y validado por Comité; no exige configurar antes una regla inexistente.
- F-DC-124 mediante enlace y solo después del pago validado.
- Asignación de docentes por el Comité, sin exigir perfiles académicos opcionales para las cuentas de demo.
- Reevaluación tras correcciones, con historial preservado.
- Decisión de Comité solo después de concepto aprobado.
- Seguimiento simplificado con las etapas académicas.
- Sin cambios destructivos, sin limpiar tablas y sin credenciales en el repositorio.

## Verificación de ejecución

Las consultas principales de PostgreSQL se validaron en modo solo lectura con `PREPARE` y parámetros `varchar` representativos para detectar los errores de tipos reportados. Las páginas y formularios se revisaron estáticamente. **Todavía hay que ejecutar el recorrido completo en Render con cuentas de prueba después del despliegue**; no se afirma que los veinte pasos hayan pasado una prueba autenticada antes de esa ejecución.

Si aparece un error nuevo durante la demostración, anota el rol, paso, URL, acción y mensaje exacto para corregirlo sin tocar datos reales.
