<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<c:if test="${pageContext.request.method ne 'POST' or empty param.csrf or param.csrf ne sessionScope.csrf or sessionScope.rol ne 'EVALUADOR' or (param.concepto ne 'APROBADO' and param.concepto ne 'CORRECCIONES') or empty fn:trim(param.observaciones)}"><c:redirect url="/evaluador/proyectos.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:query var="habilitado" dataSource="${db}">SELECT p.id FROM proyectos p WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND p.evaluador_id=CAST(NULLIF(?::text,'') AS bigint) AND p.fase='PROPUESTA' AND p.estado IN ('AVAL_DIRECTOR','EN_EVALUACION') AND EXISTS(SELECT 1 FROM documentos d WHERE d.proyecto_id=p.id AND d.tipo='Propuesta F-DC-124' AND d.url LIKE 'https://%')
<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:query>
<c:if test="${empty habilitado.rows}"><c:redirect url="/evaluador/proyectos.jsp"><c:param name="error" value="fase"/></c:redirect></c:if>
<sql:transaction dataSource="${db}">
<sql:update>INSERT INTO evaluaciones(proyecto_id,evaluador_id,tipo,estado,concepto,observaciones,enviado_en)
SELECT p.id,CAST(NULLIF(?::text,'') AS bigint),'PROPUESTA','DEFINITIVA',?,?,NOW() FROM proyectos p WHERE p.id=CAST(NULLIF(?::text,'') AS bigint)
<sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.concepto}"/><sql:param value="${param.observaciones}"/><sql:param value="${param.proyecto_id}"/></sql:update>
<sql:update>UPDATE proyectos SET estado=CASE WHEN ?='APROBADO' THEN 'EVALUADA' ELSE 'CON_OBSERVACIONES' END WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND fase='PROPUESTA' AND estado IN ('AVAL_DIRECTOR','EN_EVALUACION')
<sql:param value="${param.concepto}"/><sql:param value="${param.proyecto_id}"/></sql:update>
<sql:update>INSERT INTO observaciones(proyecto_id,tipo,usuario_id,comentario) VALUES(CAST(NULLIF(?::text,'') AS bigint),'PROPUESTA',CAST(NULLIF(?::text,'') AS bigint),?)
<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.observaciones}"/></sql:update>
<sql:update>INSERT INTO historial(proyecto_id,usuario_id,evento,nuevo,detalle) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'Evaluación del docente',?,?)
<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.concepto}"/><sql:param value="${param.observaciones}"/></sql:update>
</sql:transaction>
<c:redirect url="/evaluador/evaluacion.jsp?id=${param.proyecto_id}&ok=1"/>
