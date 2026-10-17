<%@ page contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %><%@ include file="/WEB-INF/jspf/seguridad.jspf" %><%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<c:choose><c:when test="${pageContext.request.method ne 'POST' or empty param.csrf or param.csrf ne sessionScope.csrf}">ERROR_AUTORIZACION</c:when>
<c:when test="${param.accion eq 'iniciar'}">
<c:choose><c:when test="${(sessionScope.rol ne 'ESTUDIANTE' and sessionScope.rol ne 'COMITE') or (sessionScope.rol eq 'COMITE' and param.tipo ne 'Acta del Comité') or empty param.token or fn:length(param.token) ne 36 or empty param.nombre or fn:length(param.nombre) gt 180 or (sessionScope.rol eq 'ESTUDIANTE' and not (param.tipo eq 'Propuesta F-DC-124' or param.tipo eq 'Desarrollo' or param.tipo eq 'Informe Final' or param.tipo eq 'Manual de usuario' or param.tipo eq 'Código fuente' or param.tipo eq 'Soporte' or param.tipo eq 'Correcciones' or param.tipo eq 'Comprobante de pago')) or param.tamano lt 1 or param.tamano gt 20971520 or param.partes lt 1 or param.partes gt 512}">ERROR_DATOS</c:when>
<c:otherwise><sql:update var="guardado" dataSource="${db}">INSERT INTO archivos(token,proyecto_id,usuario_id,tipo,nombre,mime,tamano,cantidad_partes)
SELECT ?,p.id,?,?,?,?,?,? FROM proyectos p LEFT JOIN proyecto_estudiantes pe ON pe.proyecto_id=p.id AND pe.estudiante_id=CAST(NULLIF(?::text,'') AS bigint)
WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND (?='COMITE' OR pe.estudiante_id=CAST(NULLIF(?::text,'') AS bigint)) AND p.estado NOT IN ('FINALIZADO','RECHAZADO') AND (? != 'Informe Final' OR p.fase IN('DESARROLLO','INFORME_FINAL')) AND (? != 'Propuesta F-DC-124' OR p.fase='PROPUESTA')
<sql:param value="${param.token}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.tipo}"/><sql:param value="${param.nombre}"/><sql:param value="${param.mime}"/><sql:param value="${param.tamano}"/><sql:param value="${param.partes}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.rol}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.tipo}"/><sql:param value="${param.tipo}"/></sql:update><c:choose><c:when test="${guardado eq 1}">OK</c:when><c:otherwise>ERROR_PROYECTO</c:otherwise></c:choose></c:otherwise></c:choose>
</c:when>
<c:when test="${param.accion eq 'parte'}">
<c:choose><c:when test="${(sessionScope.rol ne 'ESTUDIANTE' and sessionScope.rol ne 'COMITE') or empty param.token or fn:length(param.fragmento) gt 70000 or empty param.fragmento or param.numero lt 0 or param.numero gt 511}">ERROR_FRAGMENTO</c:when>
<c:otherwise><sql:update var="guardado" dataSource="${db}">INSERT INTO archivo_partes(archivo_id,numero,contenido) SELECT a.id,?,? FROM archivos a WHERE a.token=? AND a.usuario_id=CAST(NULLIF(?::text,'') AS bigint) AND a.estado='EN_PROGRESO' AND ? < a.cantidad_partes AND MOD(LENGTH(?),4)=0
<sql:param value="${param.numero}"/><sql:param value="${param.fragmento}"/><sql:param value="${param.token}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.numero}"/><sql:param value="${param.fragmento}"/></sql:update><c:choose><c:when test="${guardado eq 1}">OK</c:when><c:otherwise>ERROR_FRAGMENTO</c:otherwise></c:choose></c:otherwise></c:choose>
</c:when>
<c:when test="${param.accion eq 'finalizar'}">
<c:if test="${sessionScope.rol ne 'ESTUDIANTE' and sessionScope.rol ne 'COMITE'}"><c:redirect url="/dashboard.jsp"/></c:if>
<sql:query var="completo" dataSource="${db}">SELECT a.*,COUNT(k.id) AS recibidos,COALESCE(SUM(OCTET_LENGTH(DECODE(k.contenido,'base64'))),0) AS bytes_recibidos FROM archivos a LEFT JOIN archivo_partes k ON k.archivo_id=a.id WHERE a.token=? AND a.usuario_id=CAST(NULLIF(?::text,'') AS bigint) AND a.estado='EN_PROGRESO' GROUP BY a.id
<sql:param value="${param.token}"/><sql:param value="${sessionScope.usuarioId}"/></sql:query>
<c:choose><c:when test="${empty completo.rows or completo.rows[0].recibidos ne completo.rows[0].cantidad_partes or completo.rows[0].bytes_recibidos ne completo.rows[0].tamano}">ERROR_INCOMPLETO</c:when>
<c:otherwise>
<sql:transaction dataSource="${db}">
<sql:update>UPDATE archivos SET estado='COMPLETO' WHERE token=? AND usuario_id=CAST(NULLIF(?::text,'') AS bigint) AND estado='EN_PROGRESO'<sql:param value="${param.token}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
<sql:update>INSERT INTO documentos(proyecto_id,version,tipo,nombre,url,usuario_id,archivo_token) SELECT a.proyecto_id,(SELECT COALESCE(MAX(d.version),0)+1 FROM documentos d WHERE d.proyecto_id=a.proyecto_id AND d.tipo=a.tipo),a.tipo,a.nombre,'CARGA_INTERNA',a.usuario_id,a.token FROM archivos a WHERE a.token=? AND a.usuario_id=CAST(NULLIF(?::text,'') AS bigint) AND a.estado='COMPLETO'
<sql:param value="${param.token}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
<sql:update>INSERT INTO historial(proyecto_id,usuario_id,evento,detalle) SELECT proyecto_id,usuario_id,'Archivo cargado físicamente',CONCAT(tipo,': ',nombre) FROM archivos WHERE token=?<sql:param value="${param.token}"/></sql:update>
<c:if test="${completo.rows[0].tipo eq 'Informe Final'}"><sql:update>UPDATE proyectos SET fase='INFORME_FINAL',estado='INFORME_EN_REVISION' WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND fase IN('DESARROLLO','INFORME_FINAL') AND estado IN('APROBADO','DESARROLLO','INFORME_EN_REVISION','INFORME_AVALADO','LISTO_SUSTENTACION')<sql:param value="${completo.rows[0].proyecto_id}"/></sql:update></c:if>
</sql:transaction>OK
</c:otherwise></c:choose>
</c:when><c:otherwise>ERROR_ACCION</c:otherwise></c:choose>
