<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:if test="${sessionScope.rol ne 'EVALUADOR'}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<sql:query var="proyecto" dataSource="${db}">SELECT p.*,u.nombre AS estudiante FROM proyectos p JOIN usuarios u ON u.id=p.estudiante_id WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND p.evaluador_id=CAST(NULLIF(?::text,'') AS bigint)
<sql:param value="${param.id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:query>
<c:if test="${empty proyecto.rows}"><c:redirect url="/evaluador/proyectos.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<c:set var="p" value="${proyecto.rows[0]}"/>
<sql:query var="documentos" dataSource="${db}">SELECT * FROM documentos WHERE proyecto_id=CAST(NULLIF(?::text,'') AS bigint) AND tipo='Propuesta F-DC-124' ORDER BY version DESC<sql:param value="${p.id}"/></sql:query>
<sql:query var="evals" dataSource="${db}">SELECT * FROM evaluaciones WHERE proyecto_id=CAST(NULLIF(?::text,'') AS bigint) AND evaluador_id=CAST(NULLIF(?::text,'') AS bigint) AND tipo='PROPUESTA' AND estado='DEFINITIVA' ORDER BY id DESC
<sql:param value="${p.id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:query>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<h1>Evaluación de propuesta</h1><p class="sub"><c:out value="${p.codigo}"/> · <c:out value="${p.titulo}"/> · <c:out value="${p.estudiante}"/></p>
<div class="panel"><h2>Documentación de Google Drive</h2><p>Revisa el F-DC-124 antes de aprobar o solicitar correcciones.</p><c:forEach var="d" items="${documentos.rows}"><p>Versión ${d.version}: <a href="<c:out value='${d.url}'/>" target="_blank" rel="noopener noreferrer">Abrir F-DC-124 ↗</a></p></c:forEach><c:if test="${empty documentos.rows}"><p class="alert error">Todavía no hay un enlace de F-DC-124 registrado.</p></c:if></div>
<c:choose><c:when test="${p.fase eq 'PROPUESTA' and (p.estado eq 'AVAL_DIRECTOR' or p.estado eq 'EN_EVALUACION') and not empty documentos.rows}">
<div class="panel"><h2>Emitir concepto</h2><p>Registra la decisión de la evaluación. Si solicitas correcciones, el proyecto regresa al estudiante; luego el Director debe volver a avalarlo.</p>
<form method="post" action="../acciones/evaluacion_simple.jsp"><input type="hidden" name="csrf" value="${sessionScope.csrf}"><input type="hidden" name="proyecto_id" value="${p.id}">
<div class="field"><label>Resultado</label><select name="concepto" required><option value="CORRECCIONES">Solicitar correcciones</option><option value="APROBADO">Aprobar propuesta</option></select></div>
<div class="field"><label>Observaciones de la evaluación</label><textarea name="observaciones" required placeholder="Escribe la justificación del resultado"></textarea></div>
<button type="submit">Guardar evaluación</button></form></div>
</c:when><c:otherwise><div class="panel"><h2>Estado de la evaluación</h2><c:choose><c:when test="${p.estado eq 'EN_REVISION'}"><p>Pendiente de aval por el Director.</p></c:when><c:when test="${p.estado eq 'CON_OBSERVACIONES'}"><p>El estudiante debe corregir el documento y reenviarlo al Director.</p></c:when><c:when test="${p.estado eq 'EVALUADA'}"><p>Propuesta aprobada por el Evaluador. Pendiente de decisión del Comité.</p></c:when><c:otherwise><p>Estado actual: <c:out value="${p.estado}"/>. No hay evaluación habilitada en esta etapa.</p></c:otherwise></c:choose></div></c:otherwise></c:choose>
<div class="panel"><h2>Historial de evaluaciones</h2><c:forEach var="e" items="${evals.rows}"><p><strong><c:out value="${e.concepto}"/></strong> · ${e.enviado_en} — <c:out value="${e.observaciones}"/></p></c:forEach><c:if test="${empty evals.rows}"><p>Sin evaluaciones registradas.</p></c:if></div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
