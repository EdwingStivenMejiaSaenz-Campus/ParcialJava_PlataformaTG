<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:if test="${sessionScope.rol ne 'ESTUDIANTE'}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<sql:query var="proyecto" dataSource="${db}">SELECT p.*,d.nombre AS director,e.nombre AS evaluador FROM proyectos p JOIN proyecto_estudiantes pe ON pe.proyecto_id=p.id LEFT JOIN usuarios d ON d.id=p.director_id LEFT JOIN usuarios e ON e.id=p.evaluador_id WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND pe.estudiante_id=CAST(NULLIF(?::text,'') AS bigint) LIMIT 1
<sql:param value="${param.id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:query>
<c:if test="${empty proyecto.rows}"><c:redirect url="/estudiante/proyectos.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<c:set var="p" value="${proyecto.rows[0]}"/>
<sql:query var="pagos" dataSource="${db}">SELECT id,estado,url,fecha_pago FROM pagos WHERE proyecto_id=CAST(NULLIF(?::text,'') AS bigint) ORDER BY id DESC LIMIT 10<sql:param value="${p.id}"/></sql:query>
<sql:query var="pagoValido" dataSource="${db}">SELECT COUNT(*) AS total FROM pagos WHERE proyecto_id=CAST(NULLIF(?::text,'') AS bigint) AND estado='VALIDADO'<sql:param value="${p.id}"/></sql:query>
<sql:query var="versiones" dataSource="${db}">SELECT v.*,u.nombre AS autor FROM propuestas v JOIN usuarios u ON u.id=v.autor_id WHERE v.proyecto_id=CAST(NULLIF(?::text,'') AS bigint) ORDER BY v.version DESC<sql:param value="${p.id}"/></sql:query>
<sql:query var="obs" dataSource="${db}">SELECT o.*,u.nombre AS autor FROM observaciones o JOIN usuarios u ON u.id=o.usuario_id WHERE o.proyecto_id=CAST(NULLIF(?::text,'') AS bigint) ORDER BY o.fecha DESC<sql:param value="${p.id}"/></sql:query>
<c:set var="pagoListo" value="${pagoValido.rows[0].total gt 0}"/>
<c:set var="pagoEnEspera" value="${not empty pagos.rows and pagos.rows[0].estado eq 'PENDIENTE'}"/>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<h1 class="uts-heading">Mi proyecto · <b>SEGUIMIENTO</b></h1>
<p class="sub"><c:out value="${p.codigo}"/> · <c:out value="${p.titulo}"/></p>
<div class="panel"><p>Estado: <strong><c:out value="${p.estado}"/></strong> · Director: <strong><c:out value="${empty p.director ? 'Por asignar por el Comité' : p.director}"/></strong></p><p><a class="btn secondary" href="integrantes.jsp?id=${p.id}">Ver integrantes</a> <a class="btn secondary" href="../comun/historial.jsp?id=${p.id}">Ver historial</a></p></div>

<c:choose>
<c:when test="${not pagoListo}">
<div class="panel"><h2>Fase 1 · Registro del pago</h2><p>Antes de elaborar y enviar el F-DC-124, registra el enlace de Google Drive del comprobante. El Comité revisará el pago y habilitará la fase 2.</p>
<c:choose><c:when test="${pagoEnEspera}"><p class="alert ok">Tu pago ya fue enviado. Está pendiente de validación por el Comité.</p><a class="btn secondary" href="pagos.jsp">Consultar pagos</a></c:when>
<c:otherwise>
<c:if test="${p.fase eq 'PROPUESTA' and p.estado eq 'BORRADOR'}"><form method="post" action="../acciones/guardar.jsp"><input type="hidden" name="csrf" value="${sessionScope.csrf}"><input type="hidden" name="accion" value="pago_crear"><input type="hidden" name="proyecto_id" value="${p.id}"><div class="field"><label for="enlace-pago">Enlace de Google Drive del comprobante de pago</label><input id="enlace-pago" type="url" name="url" placeholder="https://drive.google.com/..." required pattern="https://.*"></div><button type="submit">Enviar pago al Comité</button></form></c:if>
<c:if test="${not empty pagos.rows and pagos.rows[0].estado eq 'RECHAZADO'}"><p class="alert error">El último comprobante fue rechazado. Puedes registrar un nuevo enlace válido.</p></c:if>
</c:otherwise></c:choose></div>
</c:when>
<c:otherwise>
<div class="panel"><h2>Fase 1 · Pago aprobado</h2><p>El Comité validó el comprobante. Ya puedes presentar tu propuesta por Google Drive.</p></div>
<c:choose><c:when test="${p.fase eq 'PROPUESTA'}">
<div class="panel"><h2>Fase 2 · F-DC-124 en Google Drive</h2>
<c:if test="${p.estado eq 'BORRADOR' or p.estado eq 'CON_OBSERVACIONES'}">
<p>Completa el F-DC-124 en tu documento de Google Drive. Aquí <strong>solo debes pegar el enlace</strong>, no volver a diligenciar todos sus campos.</p>
<form method="post" action="../acciones/guardar.jsp"><input type="hidden" name="csrf" value="${sessionScope.csrf}"><input type="hidden" name="accion" value="propuesta_version"><input type="hidden" name="proyecto_id" value="${p.id}"><div class="field"><label for="fdc-link">Enlace del F-DC-124</label><input id="fdc-link" type="url" name="fdc124_url" placeholder="https://drive.google.com/..." pattern="https://.*" required></div><button type="submit">${p.estado eq 'CON_OBSERVACIONES' ? 'Guardar propuesta corregida' : 'Guardar enlace de propuesta'}</button></form>
<c:choose><c:when test="${empty versiones.rows}"><p class="mini">Todavía no has registrado el enlace del formato.</p></c:when><c:otherwise><p class="mini">Última versión guardada: ${versiones.rows[0].version}.</p></c:otherwise></c:choose>
<c:if test="${not empty versiones.rows}"><c:choose><c:when test="${not empty p.director_id}">
<form method="post" action="../acciones/guardar.jsp"><input type="hidden" name="csrf" value="${sessionScope.csrf}"><input type="hidden" name="accion" value="propuesta_enviar"><input type="hidden" name="proyecto_id" value="${p.id}"><button type="submit">Enviar F-DC-124 al Director</button></form>
</c:when><c:otherwise><p class="alert error">Tu propuesta está guardada. Falta que el Comité asigne un Director antes de enviarla a revisión.</p></c:otherwise></c:choose></c:if>
</c:if>
<c:if test="${p.estado eq 'EN_REVISION'}"><p class="alert ok">La propuesta está en revisión del Director. Espera su aval u observaciones.</p></c:if>
<c:if test="${p.estado eq 'AVAL_DIRECTOR' or p.estado eq 'EN_EVALUACION'}"><p>El Director avaló la propuesta. Ahora corresponde la evaluación.</p></c:if>
<c:if test="${p.estado eq 'EVALUADA'}"><p class="alert ok">Evaluación aprobada. El Comité debe registrar la aprobación final para pasar a la siguiente fase.</p></c:if>
</div>
</c:when><c:otherwise><div class="panel"><h2>Propuesta aprobada</h2><p>La propuesta avanzó a <strong><c:out value="${p.fase}"/></strong>. Consulta las entregas posteriores en Documentos.</p><a class="btn secondary" href="documentos.jsp?id=${p.id}">Mis entregables por enlace</a></div></c:otherwise></c:choose>
</c:otherwise></c:choose>
<div class="panel"><h2>Enlaces entregados</h2><c:forEach var="v" items="${versiones.rows}"><p>F-DC-124 versión ${v.version} · <c:out value="${v.autor}"/> — <c:if test="${not empty v.fdc124_url}"><a href="<c:out value='${v.fdc124_url}'/>" target="_blank" rel="noopener noreferrer">Abrir Google Drive ↗</a></c:if></p></c:forEach><c:if test="${empty versiones.rows}"><p class="mini">Sin propuesta cargada todavía.</p></c:if></div>
<c:if test="${not empty obs.rows}"><div class="panel"><h2>Correcciones y observaciones</h2><c:forEach var="o" items="${obs.rows}"><p><strong><c:out value="${o.autor}"/></strong> — <c:out value="${o.comentario}"/></p></c:forEach></div></c:if>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
