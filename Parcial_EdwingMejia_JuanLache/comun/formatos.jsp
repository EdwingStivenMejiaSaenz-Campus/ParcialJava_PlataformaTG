<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ include file="/WEB-INF/jspf/seguridad.jspf" %><%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<sql:query var="formatos" dataSource="${db}">SELECT nombre,version,url FROM formatos WHERE activo=1 ORDER BY CASE WHEN nombre LIKE 'F-DC-%' THEN 0 ELSE 1 END,nombre</sql:query>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<h1>Formatos de grado</h1>
<p class="sub">Enlaces a documentos institucionales y al repositorio oficial de Ingeniería de Sistemas UTS.</p>
<div class="panel table-scroll uts-doc-panel">
<table class="uts-table uts-doc-table" aria-label="Documentos de grado UTS">
<thead><tr><th>Nombre</th><th>Versión</th><th>Documento</th></tr></thead>
<tbody>
<c:forEach var="f" items="${formatos.rows}">
<tr><td><strong><c:out value="${f.nombre}"/></strong></td><td><span class="uts-doc-version"><c:out value="${f.version}"/></span></td><td>
<c:if test="${fn:startsWith(f.url,'https://')}">
<a class="uts-doc-link" href="<c:out value='${f.url}'/>" target="_blank" rel="noopener noreferrer" aria-label="Abrir recurso oficial">
<svg class="ui-icon" aria-hidden="true"><use href="${pageContext.request.contextPath}/img/icons.svg#file"/></svg> Abrir recurso
</a>
</c:if>
</td></tr>
</c:forEach>
<c:if test="${empty formatos.rows}"><tr><td colspan="3">Aún no hay documentos publicados. Consulta el repositorio oficial de las UTS.</td></tr></c:if>
</tbody></table>
</div>
<p class="uts-doc-note">Los enlaces F-DC llevan al repositorio oficial de documentos de grado. Verifica allí la versión vigente del formato antes de utilizarlo. El Reglamento 01-026 de 2021 enlaza directamente a su PDF institucional.</p>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
