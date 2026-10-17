<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ include file="/WEB-INF/jspf/seguridad.jspf" %><%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<sql:query var="proyecto" dataSource="${db}">SELECT p.*,to_char(p.modificado_en,'DD/MM/YYYY HH24:MI') AS modificado_legible,to_char(p.creado_en,'DD/MM/YYYY HH24:MI') AS creado_legible,u.nombre AS estudiante,d.nombre AS director,e.nombre AS evaluador FROM proyectos p JOIN usuarios u ON u.id=p.estudiante_id LEFT JOIN usuarios d ON d.id=p.director_id LEFT JOIN usuarios e ON e.id=p.evaluador_id WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND (? IN ('ADMINISTRADOR','COMITE') OR (?='ESTUDIANTE' AND EXISTS(SELECT 1 FROM proyecto_estudiantes pe WHERE pe.proyecto_id=p.id AND pe.estudiante_id=CAST(NULLIF(?::text,'') AS bigint))) OR (?='DIRECTOR' AND p.director_id=CAST(NULLIF(?::text,'') AS bigint)) OR (?='EVALUADOR' AND p.evaluador_id=CAST(NULLIF(?::text,'') AS bigint)))<sql:param value="${param.id}"/><sql:param value="${sessionScope.rol}"/><sql:param value="${sessionScope.rol}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${sessionScope.rol}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${sessionScope.rol}"/><sql:param value="${sessionScope.usuarioId}"/></sql:query><c:if test="${empty proyecto.rows}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:query var="historial" dataSource="${db}">SELECT h.*,to_char(h.fecha,'DD/MM/YYYY HH24:MI') AS fecha_legible,u.nombre AS autor FROM historial h JOIN usuarios u ON u.id=h.usuario_id WHERE h.proyecto_id=CAST(NULLIF(?::text,'') AS bigint) ORDER BY h.fecha DESC<sql:param value="${param.id}"/></sql:query><sql:query var="evaluaciones" dataSource="${db}">SELECT e.*,to_char(e.enviado_en,'DD/MM/YYYY HH24:MI') AS fecha_legible,u.nombre AS evaluador FROM evaluaciones e JOIN usuarios u ON u.id=e.evaluador_id WHERE e.proyecto_id=CAST(NULLIF(?::text,'') AS bigint) AND (e.estado='DEFINITIVA' OR ? IN ('ADMINISTRADOR','COMITE','EVALUADOR')) ORDER BY e.id DESC<sql:param value="${param.id}"/><sql:param value="${sessionScope.rol}"/></sql:query><sql:query var="decisiones" dataSource="${db}">SELECT d.*,to_char(d.fecha,'DD/MM/YYYY HH24:MI') AS fecha_legible,u.nombre AS responsable FROM decisiones d JOIN usuarios u ON u.id=d.comite_id WHERE d.proyecto_id=CAST(NULLIF(?::text,'') AS bigint) ORDER BY d.fecha DESC<sql:param value="${param.id}"/></sql:query>
<sql:query var="docs" dataSource="${db}">SELECT d.tipo,d.nombre,d.url,d.archivo_token,d.version,to_char(d.fecha,'DD/MM/YYYY HH24:MI') AS fecha_legible FROM documentos d WHERE d.proyecto_id=CAST(NULLIF(?::text,'') AS bigint) ORDER BY d.fecha DESC<sql:param value="${param.id}"/></sql:query><%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<c:set var="p" value="${proyecto.rows[0]}"/>
<div class="uts-case-toolbar">
  <div>
    <h1 class="uts-heading">Expediente del <b>PROYECTO</b></h1>
    <p class="uts-case-title"><c:out value="${p.titulo}"/></p>
    <p class="uts-case-code"><c:out value="${p.codigo}"/></p>
  </div>
  <a href="seguimiento.jsp?id=${p.id}" class="icon-action green uts-back-link"><svg class="ui-icon" aria-hidden="true"><use href="${pageContext.request.contextPath}/img/icons.svg#arrowleft"/></svg> Volver a las fases</a>
</div>
<section class="uts-case-grid">
  <div class="uts-case-card">
    <h2>Responsables</h2>
    <dl class="uts-case-fields">
      <div><dt>Estudiante</dt><dd><c:out value="${p.estudiante}"/></dd></div>
      <div><dt>Director</dt><dd><c:out value="${empty p.director ? 'Sin asignar' : p.director}"/></dd></div>
      <div><dt>Evaluador</dt><dd><c:out value="${empty p.evaluador ? 'Sin asignar' : p.evaluador}"/></dd></div>
    </dl>
  </div>
  <div class="uts-case-card">
    <h2>Estado del proceso</h2>
    <div class="uts-badges uts-case-badges"><span class="uts-tag fase"><c:choose><c:when test="${p.fase eq 'PROPUESTA'}">Propuesta</c:when><c:when test="${p.fase eq 'DESARROLLO'}">Desarrollo</c:when><c:when test="${p.fase eq 'CIERRE'}">Cierre</c:when><c:otherwise><c:out value="${p.fase}"/></c:otherwise></c:choose></span>
      <span class="uts-tag responsable"><c:choose><c:when test="${p.estado eq 'BORRADOR'}">En preparación</c:when><c:when test="${p.estado eq 'EN_REVISION'}">En revisión</c:when><c:when test="${p.estado eq 'FINALIZADO'}">Finalizado</c:when><c:otherwise><c:out value="${p.estado}"/></c:otherwise></c:choose></span>
    </div>
    <p class="uts-case-date"><span>Última actualización</span><strong><c:out value="${p.modificado_legible}"/></strong></p>
  </div>
</section>
<section class="uts-case-section">
  <div class="uts-case-section-heading"><h2>Trazabilidad</h2><span class="uts-section-count">${fn:length(historial.rows)} movimientos</span></div>
  <div class="table-scroll"><table class="uts-table uts-case-table"><thead><tr><th>Fecha</th><th>Autor</th><th>Evento</th><th>Antes / Después</th></tr></thead><tbody>
    <c:forEach var="h" items="${historial.rows}"><tr>
      <td><c:out value="${h.fecha_legible}"/></td><td><c:out value="${h.autor}"/></td>
      <td><strong><c:out value="${h.evento}"/></strong><c:if test="${not empty h.detalle}"><p class="uts-small"><c:out value="${h.detalle}"/></p></c:if></td>
      <td><span class="uts-tag"><c:out value="${h.anterior}" default="Sin estado anterior"/></span> <span aria-hidden="true">→</span> <span class="uts-tag fase"><c:out value="${h.nuevo}" default="Sin cambio de estado"/></span></td>
    </tr></c:forEach>
    <c:if test="${empty historial.rows}"><tr><td><c:out value="${p.creado_legible}"/></td><td><c:out value="${p.estudiante}"/></td><td>Registro inicial del proyecto</td><td><span class="uts-tag">Expediente creado</span></td></tr></c:if>
  </tbody></table></div>
</section>
<section class="uts-case-section">
  <div class="uts-case-section-heading"><h2>Evaluaciones emitidas</h2><span class="uts-section-count">${fn:length(evaluaciones.rows)} registros</span></div>
  <c:choose><c:when test="${empty evaluaciones.rows}"><p class="uts-case-empty">Todavía no hay evaluaciones registradas para este expediente.</p></c:when><c:otherwise>
    <div class="uts-case-record-list"><c:forEach var="e" items="${evaluaciones.rows}"><article class="uts-case-record">
      <div class="uts-case-record-top"><strong><c:out value="${e.tipo}"/></strong><span class="uts-tag fase"><c:out value="${empty e.concepto ? e.estado : e.concepto}"/></span></div>
      <p class="uts-case-meta">Docente evaluador: <c:out value="${e.evaluador}"/><c:if test="${not empty e.fecha_legible}"> · <c:out value="${e.fecha_legible}"/></c:if></p>
      <c:if test="${not empty e.observaciones}"><p><c:out value="${e.observaciones}"/></p></c:if>
    </article></c:forEach></div>
  </c:otherwise></c:choose>
</section>
<section class="uts-case-section">
  <div class="uts-case-section-heading"><h2>Documentos y entregables</h2><span class="uts-section-count">${fn:length(docs.rows)} archivos</span></div>
  <c:choose><c:when test="${empty docs.rows}"><p class="uts-case-empty">No se han adjuntado documentos a este proyecto.</p></c:when><c:otherwise>
    <div class="table-scroll"><table class="uts-table uts-case-table"><thead><tr><th>Tipo</th><th>Nombre</th><th>Versión</th><th>Fecha</th></tr></thead><tbody>
    <c:forEach var="d" items="${docs.rows}"><tr><td><c:out value="${d.tipo}"/></td><td>
    <c:choose><c:when test="${not empty d.archivo_token}"><a href="archivo.jsp?token=<c:out value='${d.archivo_token}'/>"><c:out value="${d.nombre}"/></a></c:when>
      <c:when test="${fn:startsWith(d.url,'https://')}"><a rel="noopener noreferrer" target="_blank" href="<c:out value='${d.url}'/>"><c:out value="${d.nombre}"/></a></c:when>
      <c:otherwise><c:out value="${d.nombre}"/></c:otherwise></c:choose>
    </td><td><c:out value="${d.version}"/></td><td><c:out value="${d.fecha_legible}"/></td></tr></c:forEach>
    </tbody></table></div>
  </c:otherwise></c:choose>
</section>
<section class="uts-case-section">
  <div class="uts-case-section-heading"><h2>Decisiones del Comité</h2><span class="uts-section-count">${fn:length(decisiones.rows)} decisiones</span></div>
  <c:choose><c:when test="${empty decisiones.rows}"><p class="uts-case-empty">Aún no se ha registrado una decisión del Comité para este proyecto.</p></c:when><c:otherwise>
    <div class="uts-case-record-list"><c:forEach var="d" items="${decisiones.rows}"><article class="uts-case-record">
      <div class="uts-case-record-top"><strong><c:out value="${d.tipo}"/></strong><span class="uts-tag fase"><c:out value="${d.resultado}"/></span></div>
      <p class="uts-case-meta">Comité: <c:out value="${d.responsable}"/> · <c:out value="${d.fecha_legible}"/></p>
      <c:if test="${not empty d.observacion}"><p><c:out value="${d.observacion}"/></p></c:if>
      <c:if test="${fn:startsWith(d.acta_url,'https://')}"><a href="<c:out value='${d.acta_url}'/>" rel="noopener noreferrer" target="_blank">Consultar acta</a></c:if>
      <c:if test="${not empty d.acta_token}"><a href="archivo.jsp?token=<c:out value='${d.acta_token}'/>">Consultar acta</a></c:if>
    </article></c:forEach></div>
  </c:otherwise></c:choose>
</section>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
