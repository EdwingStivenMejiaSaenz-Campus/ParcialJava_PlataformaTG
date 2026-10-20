<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:if test="${sessionScope.rol ne 'ESTUDIANTE'}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<sql:query var="proyectos" dataSource="${db}">SELECT p.id,p.codigo,p.titulo FROM proyectos p JOIN proyecto_estudiantes e ON e.proyecto_id=p.id WHERE e.estudiante_id=CAST(NULLIF(?::text,'') AS bigint) ORDER BY p.id DESC<sql:param value="${sessionScope.usuarioId}"/></sql:query>
<sql:query var="pagos" dataSource="${db}">SELECT pg.*,p.codigo,p.titulo FROM pagos pg JOIN proyectos p ON p.id=pg.proyecto_id WHERE EXISTS(SELECT 1 FROM proyecto_estudiantes pe WHERE pe.proyecto_id=p.id AND pe.estudiante_id=CAST(NULLIF(?::text,'') AS bigint)) ORDER BY pg.fecha DESC LIMIT 100<sql:param value="${sessionScope.usuarioId}"/></sql:query>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<h1>Fase 1 · Pago del proyecto</h1><p class="sub">Todos los comprobantes se presentan con un enlace HTTPS de Google Drive. El Comité revisa y valida los pagos; solo después se habilita el enlace del F-DC-124.</p>
<div class="panel"><h2>Mis proyectos</h2><c:forEach var="p" items="${proyectos.rows}"><p><strong><c:out value="${p.codigo}"/> — <c:out value="${p.titulo}"/></strong> <a class="btn secondary" href="propuesta.jsp?id=${p.id}">Abrir pago y fases</a></p></c:forEach><c:if test="${empty proyectos.rows}"><p>Primero debes inscribir una idea o unirte al proyecto de tu compañero.</p></c:if></div>
<div class="panel table-scroll"><h2>Comprobantes registrados</h2><table><thead><tr><th>Proyecto</th><th>Enlace</th><th>Estado</th><th>Registrado</th></tr></thead><tbody><c:forEach var="pg" items="${pagos.rows}"><tr><td><c:out value="${pg.codigo}"/> — <c:out value="${pg.titulo}"/></td><td><c:if test="${not empty pg.url}"><a href="<c:out value='${pg.url}'/>" target="_blank" rel="noopener noreferrer">Abrir comprobante ↗</a></c:if></td><td><strong><c:out value="${pg.estado}"/></strong></td><td>${pg.fecha_pago}</td></tr></c:forEach></tbody></table></div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
