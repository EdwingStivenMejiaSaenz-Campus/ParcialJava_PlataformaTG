<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<sql:query var="q" dataSource="${db}">SELECT p.*,u.nombre AS estudiante,m.nombre AS modalidad,pe.nombre AS periodo FROM proyectos p JOIN usuarios u ON u.id=p.estudiante_id JOIN modalidades m ON m.id=p.modalidad_id JOIN periodos pe ON pe.id=p.periodo_id WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND ((? IN('COMITE','ADMINISTRADOR')) OR (?='ESTUDIANTE' AND EXISTS(SELECT 1 FROM proyecto_estudiantes s WHERE s.proyecto_id=p.id AND s.estudiante_id=CAST(NULLIF(?::text,'') AS bigint))) OR (?='DIRECTOR' AND p.director_id=CAST(NULLIF(?::text,'') AS bigint)) OR (?='EVALUADOR' AND p.evaluador_id=CAST(NULLIF(?::text,'') AS bigint))) LIMIT 1
<sql:param value="${param.id}"/><sql:param value="${sessionScope.rol}"/><sql:param value="${sessionScope.rol}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${sessionScope.rol}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${sessionScope.rol}"/><sql:param value="${sessionScope.usuarioId}"/></sql:query>
<c:if test="${empty q.rows}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<c:set var="p" value="${q.rows[0]}"/>
<sql:query var="pago" dataSource="${db}">SELECT COUNT(*) AS total FROM pagos WHERE proyecto_id=CAST(NULLIF(?::text,'') AS bigint) AND estado='VALIDADO'<sql:param value="${p.id}"/></sql:query>
<sql:query var="fdc" dataSource="${db}">SELECT COUNT(*) AS total FROM documentos WHERE proyecto_id=CAST(NULLIF(?::text,'') AS bigint) AND tipo='Propuesta F-DC-124' AND url LIKE 'https://%'<sql:param value="${p.id}"/></sql:query>
<sql:query var="evaluacion" dataSource="${db}">SELECT concepto,observaciones,enviado_en FROM evaluaciones WHERE proyecto_id=CAST(NULLIF(?::text,'') AS bigint) AND tipo='PROPUESTA' AND estado='DEFINITIVA' ORDER BY id DESC LIMIT 1<sql:param value="${p.id}"/></sql:query>
<sql:query var="aprobacion" dataSource="${db}">SELECT COUNT(*) AS total FROM decisiones WHERE proyecto_id=CAST(NULLIF(?::text,'') AS bigint) AND tipo='PROPUESTA' AND resultado='APROBADO'<sql:param value="${p.id}"/></sql:query>
<sql:query var="integrantes" dataSource="${db}">SELECT u.nombre FROM proyecto_estudiantes e JOIN usuarios u ON u.id=e.estudiante_id WHERE e.proyecto_id=CAST(NULLIF(?::text,'') AS bigint)<sql:param value="${p.id}"/></sql:query>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<h1 class="uts-heading">Seguimiento del <b>PROYECTO</b></h1><p class="sub"><c:out value="${p.codigo}"/> · <c:out value="${p.titulo}"/> · <c:out value="${p.modalidad}"/></p>
<div class="panel"><h2>Participantes y estado</h2><p>Integrantes: <c:forEach var="u" items="${integrantes.rows}"><strong><c:out value="${u.nombre}"/></strong> · </c:forEach></p><p>Estado actual: <strong><c:out value="${p.estado}"/></strong> / <c:out value="${p.fase}"/></p></div>
<div class="uts-phases">
<div class="uts-phase ${pago.rows[0].total gt 0 ? 'done' : 'current'}"><div class="phase-symbol">1</div><strong>Fase 1 · Pago</strong><small>${pago.rows[0].total gt 0 ? 'Validado por el Comité' : 'Pendiente de validación'}</small></div>
<div class="uts-phase ${fdc.rows[0].total gt 0 ? 'done' : (pago.rows[0].total gt 0 ? 'current' : '')}"><div class="phase-symbol">2</div><strong>Fase 2 · F-DC-124</strong><small>${fdc.rows[0].total gt 0 ? 'Enlace de Drive registrado' : 'Se habilita después del pago'}</small></div>
<div class="uts-phase ${p.estado eq 'AVAL_DIRECTOR' or p.estado eq 'EVALUADA' or p.fase ne 'PROPUESTA' ? 'done' : (fdc.rows[0].total gt 0 ? 'current' : '')}"><div class="phase-symbol">3</div><strong>Fase 3 · Director</strong><small>Aval y observaciones de la propuesta</small></div>
<div class="uts-phase ${(not empty evaluacion.rows and evaluacion.rows[0].concepto eq 'APROBADO') ? 'done' : ''}"><div class="phase-symbol">4</div><strong>Evaluador</strong><small><c:choose><c:when test="${empty evaluacion.rows}">Pendiente</c:when><c:otherwise><c:out value="${evaluacion.rows[0].concepto}"/></c:otherwise></c:choose></small></div>
<div class="uts-phase ${aprobacion.rows[0].total gt 0 ? 'done' : ''}"><div class="phase-symbol">5</div><strong>Comité · Cambio de fase</strong><small>${aprobacion.rows[0].total gt 0 ? 'Aprobación final registrada' : 'Requiere evaluación aprobada'}</small></div>
</div>
<c:choose>
<c:when test="${p.estado eq 'CON_OBSERVACIONES'}"><div class="panel"><h2>Correcciones pendientes</h2><p>El estudiante debe actualizar el enlace del F-DC-124 y enviarlo de nuevo al Director; después el Evaluador repetirá su concepto.</p></div></c:when>
<c:when test="${p.fase eq 'DESARROLLO' and p.estado eq 'APROBADO'}"><div class="panel"><h2>Propuesta aprobada</h2><p>El Comité realizó el cambio de fase. El proyecto se encuentra en desarrollo.</p></div></c:when>
</c:choose>
<div class="panel"><h2>Siguiente acción según tu rol</h2>
<c:if test="${sessionScope.rol eq 'ESTUDIANTE'}"><a class="btn secondary" href="../estudiante/propuesta.jsp?id=${p.id}">Pago y propuesta por Drive</a> <a class="btn secondary" href="../estudiante/documentos.jsp?id=${p.id}">Entregables por enlace</a></c:if>
<c:if test="${sessionScope.rol eq 'DIRECTOR'}"><a class="btn secondary" href="../director/revision.jsp?id=${p.id}">Revisar F-DC-124 y avalar</a></c:if>
<c:if test="${sessionScope.rol eq 'EVALUADOR'}"><a class="btn secondary" href="../evaluador/evaluacion.jsp?id=${p.id}">Registrar evaluación</a></c:if>
<c:if test="${sessionScope.rol eq 'COMITE'}"><a class="btn secondary" href="../comite/pagos.jsp">Validar pagos</a> <a class="btn secondary" href="../comite/asignaciones.jsp">Asignar docentes</a> <a class="btn secondary" href="../comite/decisiones.jsp">Aprobación final</a></c:if>
<a class="btn secondary" href="historial.jsp?id=${p.id}">Ver historial del proyecto</a></div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
