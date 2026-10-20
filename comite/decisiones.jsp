<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:if test="${sessionScope.rol ne 'COMITE'}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<sql:query var="proyectos" dataSource="${db}">SELECT p.*,u.nombre AS estudiante FROM proyectos p JOIN usuarios u ON u.id=p.estudiante_id ORDER BY p.modificado_en DESC LIMIT 150</sql:query>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<h1>Comité · Aprobación final</h1><p class="sub">La aprobación académica definitiva se realiza después del aval del Director y la evaluación aprobada. Para habilitar Fase 2 después del pago, usa <a href="pagos.jsp">Validar pagos</a>.</p>
<div class="panel table-scroll"><table><thead><tr><th>Proyecto</th><th>Estado</th><th>Revisión</th><th>Decisión</th></tr></thead><tbody>
<c:forEach var="p" items="${proyectos.rows}"><tr><td><strong><c:out value="${p.titulo}"/></strong><div class="mini"><c:out value="${p.codigo}"/> · <c:out value="${p.estudiante}"/></div></td><td><c:out value="${p.fase}"/> / <strong><c:out value="${p.estado}"/></strong></td><td><a href="../comun/historial.jsp?id=${p.id}">Ver historial</a> · <a href="../comun/seguimiento.jsp?id=${p.id}">Seguimiento</a></td><td>
<c:choose><c:when test="${p.fase eq 'PROPUESTA' and p.estado eq 'EVALUADA'}">
<form method="post" action="../acciones/guardar.jsp"><input type="hidden" name="csrf" value="${sessionScope.csrf}"><input type="hidden" name="accion" value="comite_decidir"><input type="hidden" name="proyecto_id" value="${p.id}"><input type="hidden" name="resultado" value="APROBADO">
<div class="field"><label>Observación / decisión</label><input name="observacion" required value="Evaluación aprobada, propuesta autorizada" maxlength="280"></div><div class="field"><label>Acta de Comité por Drive (opcional)</label><input type="url" name="acta_url" maxlength="900" placeholder="https://drive.google.com/..."></div><button type="submit">Aprobación final · pasar de fase</button></form>
</c:when><c:otherwise><span class="mini">Pendiente de completar los requisitos anteriores.</span></c:otherwise></c:choose>
</td></tr></c:forEach></tbody></table></div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
