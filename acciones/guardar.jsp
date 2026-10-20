<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%-- Único punto de escritura: todas las mutaciones son POST, usan token de sesión y comprobación de rol.
     Sin scriptlets Java, Servlet propios ni clases Java. --%>
<c:if test="${pageContext.request.method ne 'POST' or empty param.csrf or param.csrf ne sessionScope.csrf}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<c:set var="destino" value="/dashboard.jsp?ok=1"/>
<c:choose>
<c:when test="${param.accion eq 'programa_crear'}">
<c:if test="${sessionScope.rol ne 'ADMINISTRADOR' or empty param.nombre}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:update dataSource="${db}">INSERT INTO programas(nombre) VALUES(?)<sql:param value="${param.nombre}"/></sql:update>
<sql:update dataSource="${db}">INSERT INTO auditoria(usuario_id,entidad,accion,nuevo) VALUES(CAST(NULLIF(?::text,'') AS bigint),'PROGRAMAS','CREAR',?)<sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.nombre}"/></sql:update><c:set var="destino" value="/admin/catalogos.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'usuario_crear'}">
<c:if test="${sessionScope.rol ne 'ADMINISTRADOR' or empty param.identificacion or empty param.nombre or empty param.correo or fn:length(param.clave) lt 12 or not (param.rol eq 'ESTUDIANTE' or param.rol eq 'DIRECTOR' or param.rol eq 'EVALUADOR' or param.rol eq 'COMITE' or param.rol eq 'ADMINISTRADOR')}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update dataSource="${db}">INSERT INTO usuarios (identificacion,nombre,correo,rol,sal,clave_hash,programa_id,nivel,plan,creditos,metodologia,seminario_i,seminario_ii,seminario_iii,seminario_iv,matricula_seminario_i,matricula_seminario_iii) SELECT ?,?,?,?,z.s,sha2(CONCAT(z.s,?),256),CAST(NULLIF(?::text,'') AS bigint),NULLIF(?,''),NULLIF(?,''),CAST(NULLIF(?::text,'') AS smallint),uts_if(?='1',1,0),uts_if(?='1',1,0),uts_if(?='1',1,0),uts_if(?='1',1,0),uts_if(?='1',1,0),uts_if(?='1',1,0),uts_if(?='1',1,0) FROM (SELECT sha2(uuid(),256) AS s) z
<sql:param value="${param.identificacion}"/><sql:param value="${param.nombre}"/><sql:param value="${param.correo}"/><sql:param value="${param.rol}"/><sql:param value="${param.clave}"/><sql:param value="${param.programa_id}"/><sql:param value="${param.nivel}"/><sql:param value="${param.plan}"/><sql:param value="${param.creditos}"/><sql:param value="${param.metodologia}"/><sql:param value="${param.s1}"/><sql:param value="${param.s2}"/><sql:param value="${param.s3}"/><sql:param value="${param.s4}"/><sql:param value="${param.m1}"/><sql:param value="${param.m3}"/></sql:update>
<sql:update dataSource="${db}">INSERT INTO auditoria(usuario_id,entidad,accion,nuevo) VALUES(CAST(NULLIF(?::text,'') AS bigint),'USUARIOS','CREAR',?)<sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.correo}"/></sql:update><c:set var="destino" value="/admin/usuarios.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'usuario_actualizar'}">
<c:if test="${sessionScope.rol ne 'ADMINISTRADOR' or empty param.id or empty param.nombre or empty param.correo}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:query var="antes" dataSource="${db}">SELECT rol,activo,creditos FROM usuarios WHERE id=CAST(NULLIF(?::text,'') AS bigint)<sql:param value="${param.id}"/></sql:query>
<sql:update dataSource="${db}">UPDATE usuarios SET nombre=?,correo=?,rol=?,programa_id=CAST(NULLIF(?::text,'') AS bigint),nivel=NULLIF(?,''),plan=NULLIF(?,''),creditos=CAST(NULLIF(?::text,'') AS smallint),metodologia=CAST(NULLIF(?::text,'') AS smallint),seminario_i=CAST(NULLIF(?::text,'') AS smallint),seminario_ii=CAST(NULLIF(?::text,'') AS smallint),seminario_iii=CAST(NULLIF(?::text,'') AS smallint),seminario_iv=CAST(NULLIF(?::text,'') AS smallint),matricula_seminario_i=CAST(NULLIF(?::text,'') AS smallint),matricula_seminario_iii=CAST(NULLIF(?::text,'') AS smallint),activo=CAST(NULLIF(?::text,'') AS smallint) WHERE id=CAST(NULLIF(?::text,'') AS bigint)
<sql:param value="${param.nombre}"/><sql:param value="${param.correo}"/><sql:param value="${param.rol}"/><sql:param value="${param.programa_id}"/><sql:param value="${param.nivel}"/><sql:param value="${param.plan}"/><sql:param value="${param.creditos}"/><sql:param value="${param.metodologia}"/><sql:param value="${param.s1 eq '1' ? 1 : 0}"/><sql:param value="${param.s2 eq '1' ? 1 : 0}"/><sql:param value="${param.s3 eq '1' ? 1 : 0}"/><sql:param value="${param.s4 eq '1' ? 1 : 0}"/><sql:param value="${param.m1 eq '1' ? 1 : 0}"/><sql:param value="${param.m3 eq '1' ? 1 : 0}"/><sql:param value="${param.activo}"/><sql:param value="${param.id}"/></sql:update>
<sql:update dataSource="${db}">INSERT INTO auditoria(usuario_id,entidad,accion,anterior,nuevo) VALUES(CAST(NULLIF(?::text,'') AS bigint),'USUARIOS','ACTUALIZAR',?,?)<sql:param value="${sessionScope.usuarioId}"/><sql:param value="${antes.rows[0].rol}"/><sql:param value="${param.rol}"/></sql:update><c:set var="destino" value="/admin/usuarios.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'periodo_crear'}">
<c:if test="${sessionScope.rol ne 'COMITE' or param.fin lt param.inicio or param.cierre lt param.apertura}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update dataSource="${db}">INSERT INTO periodos(nombre,inicio,fin,apertura_banco,cierre_banco) VALUES(?,?,?,?,?)<sql:param value="${param.nombre}"/><sql:param value="${param.inicio}"/><sql:param value="${param.fin}"/><sql:param value="${param.apertura}"/><sql:param value="${param.cierre}"/></sql:update><c:set var="destino" value="/comite/periodos.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'periodo_estado'}">
<c:if test="${sessionScope.rol ne 'COMITE'}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:update dataSource="${db}">UPDATE periodos SET estado=? WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND ? IN ('BORRADOR','ACTIVO','CERRADO')<sql:param value="${param.estado}"/><sql:param value="${param.id}"/><sql:param value="${param.estado}"/></sql:update><c:set var="destino" value="/comite/periodos.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'calendario_crear'}">
<c:if test="${sessionScope.rol ne 'COMITE' or empty param.actividad}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:update dataSource="${db}">INSERT INTO calendario(periodo_id,actividad,inicio,fin) VALUES(?,?,REPLACE(?,'T',' '),REPLACE(?,'T',' '))<sql:param value="${param.periodo_id}"/><sql:param value="${param.actividad}"/><sql:param value="${param.inicio}"/><sql:param value="${param.fin}"/></sql:update><c:set var="destino" value="/comite/periodos.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'idea_crear'}">
<c:if test="${sessionScope.rol ne 'COMITE' or empty param.titulo or empty param.descripcion}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:update dataSource="${db}">INSERT INTO ideas(periodo_id,programa_id,nivel,modalidad_id,titulo,descripcion) VALUES(?,?,NULLIF(?,''),?,?,?)<sql:param value="${param.periodo_id}"/><sql:param value="${param.programa_id}"/><sql:param value="${param.nivel}"/><sql:param value="${param.modalidad_id}"/><sql:param value="${param.titulo}"/><sql:param value="${param.descripcion}"/></sql:update><c:set var="destino" value="/comite/ideas.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'idea_estado'}">
<c:if test="${sessionScope.rol ne 'COMITE'}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:update dataSource="${db}">UPDATE ideas SET estado=? WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND ? IN ('ABIERTA','CERRADA')<sql:param value="${param.estado}"/><sql:param value="${param.id}"/><sql:param value="${param.estado}"/></sql:update><c:set var="destino" value="/comite/ideas.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'proyecto_crear' or param.accion eq 'proyecto_de_idea'}">
<c:if test="${sessionScope.rol ne 'ESTUDIANTE' or (param.accion eq 'proyecto_crear' and empty fn:trim(param.titulo))}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<c:choose>
<c:when test="${param.accion eq 'proyecto_de_idea'}">
<sql:query var="elegible" dataSource="${db}">SELECT i.titulo,i.id AS idea_id,i.periodo_id,i.modalidad_id,i.programa_id FROM ideas i JOIN periodos p ON p.id=i.periodo_id JOIN modalidades m ON m.id=i.modalidad_id JOIN usuarios u ON u.id=CAST(NULLIF(?::text,'') AS bigint) WHERE i.id=CAST(NULLIF(?::text,'') AS bigint) AND u.rol='ESTUDIANTE' AND u.activo=1 AND i.estado='ABIERTA' AND p.estado='ACTIVO' AND m.activo=1 AND CURRENT_DATE BETWEEN p.apertura_banco AND p.cierre_banco AND i.programa_id=u.programa_id AND (i.nivel IS NULL OR u.nivel IS NULL OR i.nivel=u.nivel) AND NOT EXISTS(SELECT 1 FROM proyectos px JOIN proyecto_estudiantes pe ON pe.proyecto_id=px.id WHERE px.idea_id=i.id AND pe.estudiante_id=u.id AND px.estado NOT IN ('RECHAZADO','FINALIZADO'))
<sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.idea_id}"/></sql:query>
</c:when><c:otherwise>
<sql:query var="elegible" dataSource="${db}">SELECT ? AS titulo,NULL::bigint AS idea_id,p.id AS periodo_id,m.id AS modalidad_id,u.programa_id FROM usuarios u JOIN periodos p ON p.id=CAST(NULLIF(?::text,'') AS bigint) AND p.estado='ACTIVO' JOIN modalidades m ON m.id=CAST(NULLIF(?::text,'') AS bigint) AND m.activo=1 WHERE u.id=CAST(NULLIF(?::text,'') AS bigint) AND u.rol='ESTUDIANTE' AND u.activo=1 AND u.programa_id IS NOT NULL
<sql:param value="${param.titulo}"/><sql:param value="${param.periodo_id}"/><sql:param value="${param.modalidad_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:query>
</c:otherwise></c:choose>
<c:if test="${empty elegible.rows or empty elegible.rows[0].programa_id}"><c:redirect url="/estudiante/habilitacion.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:transaction dataSource="${db}">
<sql:update>INSERT INTO proyectos(titulo,estudiante_id,programa_id,periodo_id,modalidad_id,idea_id) VALUES(?,CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint))<sql:param value="${elegible.rows[0].titulo}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${elegible.rows[0].programa_id}"/><sql:param value="${elegible.rows[0].periodo_id}"/><sql:param value="${elegible.rows[0].modalidad_id}"/><sql:param value="${elegible.rows[0].idea_id}"/></sql:update>
<sql:query var="nuevo">SELECT currval('uts_grado.proyectos_id_seq') AS id</sql:query>
<sql:update>UPDATE proyectos SET codigo=CONCAT('UTS-',LPAD(id::text,7,'0')) WHERE id=CAST(NULLIF(?::text,'') AS bigint)<sql:param value="${nuevo.rows[0].id}"/></sql:update>
<sql:update>INSERT INTO proyecto_estudiantes(proyecto_id,estudiante_id) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint))<sql:param value="${nuevo.rows[0].id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
<sql:update>INSERT INTO historial(proyecto_id,usuario_id,evento,nuevo) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'Proyecto creado','BORRADOR')<sql:param value="${nuevo.rows[0].id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
</sql:transaction><c:set var="destino" value="/estudiante/proyectos.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'propuesta_version'}">
<c:if test="${sessionScope.rol ne 'ESTUDIANTE' or not fn:startsWith(param.fdc124_url,'https://') or fn:length(param.fdc124_url) gt 900}"><c:redirect url="/estudiante/proyectos.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:query var="acceso" dataSource="${db}">SELECT p.id,p.estado FROM proyectos p WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND p.fase='PROPUESTA' AND p.estado IN ('BORRADOR','CON_OBSERVACIONES') AND EXISTS(SELECT 1 FROM proyecto_estudiantes pe WHERE pe.proyecto_id=p.id AND pe.estudiante_id=CAST(NULLIF(?::text,'') AS bigint)) AND EXISTS(SELECT 1 FROM pagos pg WHERE pg.proyecto_id=p.id AND pg.estado='VALIDADO')
<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:query>
<c:if test="${empty acceso.rows}"><c:redirect url="/estudiante/proyectos.jsp"><c:param name="error" value="fase"/></c:redirect></c:if>
<sql:transaction dataSource="${db}">
<sql:update>INSERT INTO propuestas(proyecto_id,version,problema,justificacion,objetivo_general,objetivos_especificos,fdc124_url,autor_id)
SELECT p.id,COALESCE((SELECT MAX(v.version) FROM propuestas v WHERE v.proyecto_id=p.id),0)+1,
'Consultar documento F-DC-124 en el enlace externo','Contenido del formato en Drive','Contenido del formato en Drive','Contenido del formato en Drive',?,CAST(NULLIF(?::text,'') AS bigint)
FROM proyectos p WHERE p.id=CAST(NULLIF(?::text,'') AS bigint)
<sql:param value="${param.fdc124_url}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.proyecto_id}"/></sql:update>
<sql:update>INSERT INTO documentos(proyecto_id,version,tipo,nombre,url,usuario_id)
SELECT p.id,COALESCE((SELECT MAX(d.version) FROM documentos d WHERE d.proyecto_id=p.id AND d.tipo='Propuesta F-DC-124'),0)+1,'Propuesta F-DC-124','F-DC-124 en Google Drive',?,CAST(NULLIF(?::text,'') AS bigint)
FROM proyectos p WHERE p.id=CAST(NULLIF(?::text,'') AS bigint)
<sql:param value="${param.fdc124_url}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.proyecto_id}"/></sql:update>
<sql:update>INSERT INTO historial(proyecto_id,usuario_id,evento,detalle) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'F-DC-124 registrado','Enlace externo registrado para revisión')
<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
</sql:transaction>
<c:set var="destino" value="/estudiante/propuesta.jsp?id=${param.proyecto_id}&amp;ok=1"/>
</c:when>
<c:when test="${param.accion eq 'propuesta_enviar'}">
<c:if test="${sessionScope.rol ne 'ESTUDIANTE'}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:update var="afectadas" dataSource="${db}">UPDATE proyectos p SET estado='EN_REVISION'
WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND p.fase='PROPUESTA' AND p.estado IN ('BORRADOR','CON_OBSERVACIONES') AND p.director_id IS NOT NULL
AND EXISTS(SELECT 1 FROM proyecto_estudiantes e WHERE e.proyecto_id=p.id AND e.estudiante_id=CAST(NULLIF(?::text,'') AS bigint))
AND EXISTS(SELECT 1 FROM pagos pg WHERE pg.proyecto_id=p.id AND pg.estado='VALIDADO')
AND EXISTS(SELECT 1 FROM documentos d WHERE d.proyecto_id=p.id AND d.tipo='Propuesta F-DC-124' AND d.url LIKE 'https://%')
<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
<c:if test="${afectadas eq 0}"><c:redirect url="/estudiante/propuesta.jsp?id=${param.proyecto_id}"><c:param name="error" value="fase"/></c:redirect></c:if>
<sql:update dataSource="${db}">INSERT INTO historial(proyecto_id,usuario_id,evento,anterior,nuevo)
VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'F-DC-124 enviado al Director','BORRADOR','EN_REVISION')
<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
<c:set var="destino" value="/estudiante/propuesta.jsp?id=${param.proyecto_id}&amp;ok=1"/>
</c:when>
<c:when test="${param.accion eq 'documento_crear'}">
<c:if test="${sessionScope.rol ne 'ESTUDIANTE' or not fn:startsWith(param.url,'https://') or fn:length(param.url) gt 900 or empty param.nombre}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:query var="acceso" dataSource="${db}">SELECT p.id FROM proyectos p JOIN proyecto_estudiantes e ON e.proyecto_id=p.id WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND e.estudiante_id=CAST(NULLIF(?::text,'') AS bigint) AND p.estado NOT IN ('FINALIZADO','RECHAZADO') AND (? <> 'Informe Final' OR p.fase IN ('DESARROLLO','INFORME_FINAL'))<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.tipo}"/></sql:query><c:if test="${empty acceso.rows}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:update dataSource="${db}">INSERT INTO documentos(proyecto_id,version,tipo,nombre,url,usuario_id) SELECT CAST(NULLIF(?::text,'') AS bigint),COALESCE(MAX(version),0)+1,?,?,?,CAST(NULLIF(?::text,'') AS bigint) FROM documentos WHERE proyecto_id=CAST(NULLIF(?::text,'') AS bigint) AND tipo=?
<sql:param value="${param.proyecto_id}"/><sql:param value="${param.tipo}"/><sql:param value="${param.nombre}"/><sql:param value="${param.url}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.proyecto_id}"/><sql:param value="${param.tipo}"/></sql:update>
<sql:update dataSource="${db}">INSERT INTO historial(proyecto_id,usuario_id,evento,detalle) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'Documento registrado',?)<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.tipo}"/></sql:update><c:if test="${param.tipo eq 'Informe Final'}"><sql:update dataSource="${db}">UPDATE proyectos SET fase='INFORME_FINAL', estado='INFORME_EN_REVISION' WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND fase IN ('DESARROLLO','INFORME_FINAL') AND estado IN ('APROBADO','DESARROLLO','INFORME_EN_REVISION','INFORME_AVALADO','LISTO_SUSTENTACION')<sql:param value="${param.proyecto_id}"/></sql:update></c:if>
<c:set var="destino" value="/estudiante/documentos.jsp?id=${param.proyecto_id}&ok=1"/>
</c:when>
<c:when test="${param.accion eq 'pago_crear'}">
<c:if test="${sessionScope.rol ne 'ESTUDIANTE' or not fn:startsWith(param.url,'https://') or fn:length(param.url) gt 900}"><c:redirect url="/estudiante/pagos.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update var="afectadas" dataSource="${db}">INSERT INTO pagos(proyecto_id,estudiante_id,modalidad_id,periodo_id,referencia,url,fecha_pago)
SELECT p.id,CAST(NULLIF(?::text,'') AS bigint),p.modalidad_id,p.periodo_id,CONCAT('TG-',p.id,'-',to_char(CURRENT_TIMESTAMP,'YYYYMMDDHH24MISS')),?,CURRENT_DATE
FROM proyectos p WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND p.fase='PROPUESTA' AND p.estado IN('BORRADOR','CON_OBSERVACIONES')
AND EXISTS(SELECT 1 FROM proyecto_estudiantes pe WHERE pe.proyecto_id=p.id AND pe.estudiante_id=CAST(NULLIF(?::text,'') AS bigint))
AND NOT EXISTS(SELECT 1 FROM pagos pg WHERE pg.proyecto_id=p.id AND pg.estado IN('PENDIENTE','VALIDADO'))
<sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.url}"/><sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
<c:if test="${afectadas eq 0}"><c:redirect url="/estudiante/pagos.jsp"><c:param name="error" value="fase"/></c:redirect></c:if>
<sql:update dataSource="${db}">INSERT INTO historial(proyecto_id,usuario_id,evento,detalle) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'Pago presentado','Enlace del comprobante enviado al Comité')
<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
<c:set var="destino" value="/estudiante/pagos.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'cambio_solicitar'}">
<c:if test="${sessionScope.rol ne 'ESTUDIANTE' or empty param.motivo}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:update var="afectadas" dataSource="${db}">INSERT INTO cambios_modalidad(proyecto_id,anterior_id,nueva_id,solicitante_id,motivo) SELECT p.id,p.modalidad_id,m.id,?,? FROM proyectos p JOIN proyecto_estudiantes pe ON pe.proyecto_id=p.id JOIN modalidades m ON m.id=CAST(NULLIF(?::text,'') AS bigint) AND m.activo=1 WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND pe.estudiante_id=CAST(NULLIF(?::text,'') AS bigint) AND p.fase='PROPUESTA' AND p.estado IN ('BORRADOR','CON_OBSERVACIONES') AND p.modalidad_id<>m.id
<sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.motivo}"/><sql:param value="${param.nueva_id}"/><sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update><c:if test="${afectadas eq 0}"><c:redirect url="/estudiante/cambios.jsp"><c:param name="error" value="fase"/></c:redirect></c:if><c:set var="destino" value="/estudiante/cambios.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'director_observar'}">
<c:if test="${sessionScope.rol ne 'DIRECTOR' or empty param.comentario}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:update var="afectadas" dataSource="${db}">INSERT INTO observaciones(proyecto_id,tipo,usuario_id,comentario) SELECT p.id,?,?,? FROM proyectos p WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND p.director_id=CAST(NULLIF(?::text,'') AS bigint) AND p.estado NOT IN ('FINALIZADO','RECHAZADO')
<sql:param value="${param.tipo}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.comentario}"/><sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
<c:if test="${afectadas eq 0}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:update dataSource="${db}">UPDATE proyectos SET estado='CON_OBSERVACIONES' WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND fase='PROPUESTA' AND estado='EN_REVISION'<sql:param value="${param.proyecto_id}"/></sql:update>
<sql:update dataSource="${db}">INSERT INTO historial(proyecto_id,usuario_id,evento,detalle) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'Observación del Director',?)<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.comentario}"/></sql:update><c:set var="destino" value="/director/revision.jsp?id=${param.proyecto_id}&ok=1"/>
</c:when>
<c:when test="${param.accion eq 'director_avalar'}">
<c:if test="${sessionScope.rol ne 'DIRECTOR'}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:query var="fase" dataSource="${db}">SELECT fase,estado FROM proyectos WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND director_id=CAST(NULLIF(?::text,'') AS bigint)<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:query>
<c:if test="${empty fase.rows}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<c:choose><c:when test="${fase.rows[0].fase eq 'PROPUESTA'}">
<sql:update var="afectadas" dataSource="${db}">UPDATE proyectos p SET estado='AVAL_DIRECTOR' WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND p.director_id=CAST(NULLIF(?::text,'') AS bigint) AND p.estado='EN_REVISION' AND EXISTS(SELECT 1 FROM propuestas v WHERE v.proyecto_id=p.id)<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
</c:when><c:otherwise>
<sql:update var="afectadas" dataSource="${db}">UPDATE proyectos p SET estado='INFORME_AVALADO' WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND p.director_id=CAST(NULLIF(?::text,'') AS bigint) AND p.fase='INFORME_FINAL' AND p.estado IN ('INFORME_EN_REVISION','DESARROLLO','INFORME_AVALADO') AND EXISTS(SELECT 1 FROM documentos d WHERE d.proyecto_id=p.id AND d.tipo='Informe Final')<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
</c:otherwise></c:choose>
<c:if test="${afectadas eq 0}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="fase"/></c:redirect></c:if>
<sql:update dataSource="${db}">INSERT INTO historial(proyecto_id,usuario_id,evento,nuevo) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'Aval del Director',?)<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${fase.rows[0].fase}"/></sql:update><c:set var="destino" value="/director/revision.jsp?id=${param.proyecto_id}&ok=1"/>
</c:when>
<c:when test="${param.accion eq 'asignar_docentes'}">
<c:if test="${sessionScope.rol ne 'COMITE' or empty param.director_id or empty param.evaluador_id or param.director_id eq param.evaluador_id}"><c:redirect url="/comite/asignaciones.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update var="afectadas" dataSource="${db}">UPDATE proyectos p SET director_id=CAST(NULLIF(?::text,'') AS bigint),evaluador_id=CAST(NULLIF(?::text,'') AS bigint),codirector_id=CAST(NULLIF(?::text,'') AS bigint)
WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND p.estado NOT IN('FINALIZADO','RECHAZADO') AND
EXISTS(SELECT 1 FROM usuarios d WHERE d.id=CAST(NULLIF(?::text,'') AS bigint) AND d.rol='DIRECTOR' AND d.activo=1)
AND EXISTS(SELECT 1 FROM usuarios e WHERE e.id=CAST(NULLIF(?::text,'') AS bigint) AND e.rol='EVALUADOR' AND e.activo=1)
<sql:param value="${param.director_id}"/><sql:param value="${param.evaluador_id}"/><sql:param value="${param.codirector_id}"/><sql:param value="${param.proyecto_id}"/><sql:param value="${param.director_id}"/><sql:param value="${param.evaluador_id}"/></sql:update>
<c:if test="${afectadas eq 0}"><c:redirect url="/comite/asignaciones.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update dataSource="${db}">INSERT INTO historial(proyecto_id,usuario_id,evento,detalle) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'Docentes asignados','Director y Evaluador designados por Comité')
<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
<c:set var="destino" value="/comite/asignaciones.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'evaluacion_iniciar'}">
<c:if test="${(sessionScope.rol ne 'EVALUADOR' and sessionScope.rol ne 'DIRECTOR') or (param.tipo ne 'PROPUESTA' and param.tipo ne 'INFORME_FINAL')}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:update var="afectadas" dataSource="${db}">INSERT INTO evaluaciones(proyecto_id,evaluador_id,tipo) SELECT p.id,?,? FROM proyectos p WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND (p.evaluador_id=CAST(NULLIF(?::text,'') AS bigint) OR (p.evaluador_propuesta_excepcion_id=CAST(NULLIF(?::text,'') AS bigint) AND ?='PROPUESTA')) AND ((?='PROPUESTA' AND p.fase='PROPUESTA' AND p.estado IN ('AVAL_DIRECTOR','EN_EVALUACION','EVALUADA')) OR (?='INFORME_FINAL' AND p.fase='INFORME_FINAL' AND p.estado IN ('INFORME_AVALADO','EN_EVALUACION_FINAL'))) AND NOT EXISTS(SELECT 1 FROM evaluaciones e WHERE e.proyecto_id=p.id AND e.tipo=? AND e.estado='BORRADOR')
<sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.tipo}"/><sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.tipo}"/><sql:param value="${param.tipo}"/><sql:param value="${param.tipo}"/><sql:param value="${param.tipo}"/></sql:update><c:if test="${afectadas eq 0}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="fase"/></c:redirect></c:if><c:set var="destino" value="/evaluador/evaluacion.jsp?id=${param.proyecto_id}&ok=1"/>
</c:when>
<c:when test="${param.accion eq 'evaluacion_criterio'}">
<c:if test="${(sessionScope.rol ne 'EVALUADOR' and sessionScope.rol ne 'DIRECTOR') or (param.cumple ne '0' and param.cumple ne '1')}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update var="afectadas" dataSource="${db}">INSERT INTO evaluacion_criterios(evaluacion_id,criterio_id,cumple,observacion) SELECT e.id,c.id,?,? FROM evaluaciones e JOIN proyectos p ON p.id=e.proyecto_id JOIN criterios c ON c.id=CAST(NULLIF(?::text,'') AS bigint) AND c.tipo=e.tipo AND (c.modalidad_id IS NULL OR c.modalidad_id=p.modalidad_id) WHERE e.id=CAST(NULLIF(?::text,'') AS bigint) AND e.evaluador_id=CAST(NULLIF(?::text,'') AS bigint) AND e.estado='BORRADOR' ON CONFLICT (evaluacion_id,criterio_id) DO UPDATE SET cumple=EXCLUDED.cumple, observacion=EXCLUDED.observacion
<sql:param value="${param.cumple}"/><sql:param value="${param.observacion}"/><sql:param value="${param.criterio_id}"/><sql:param value="${param.evaluacion_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
<sql:query var="ep" dataSource="${db}">SELECT proyecto_id FROM evaluaciones WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND evaluador_id=CAST(NULLIF(?::text,'') AS bigint)<sql:param value="${param.evaluacion_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:query><c:if test="${empty ep.rows or afectadas eq 0}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if><c:set var="destino" value="/evaluador/evaluacion.jsp?id=${ep.rows[0].proyecto_id}&ok=1"/>
</c:when>
<c:when test="${param.accion eq 'evaluacion_finalizar'}">
<c:if test="${(sessionScope.rol ne 'EVALUADOR' and sessionScope.rol ne 'DIRECTOR') or empty param.observaciones or (param.concepto ne 'APROBADO' and param.concepto ne 'NO_APROBADO' and param.concepto ne 'CORRECCIONES')}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:query var="comprobacion" dataSource="${db}">SELECT e.*,p.modalidad_id,(SELECT COUNT(*) FROM criterios c WHERE c.tipo=e.tipo AND (c.modalidad_id IS NULL OR c.modalidad_id=p.modalidad_id) AND c.obligatorio=1) AS total,(SELECT COUNT(*) FROM evaluacion_criterios ec JOIN criterios c ON c.id=ec.criterio_id WHERE ec.evaluacion_id=e.id AND c.obligatorio=1 AND c.tipo=e.tipo AND (c.modalidad_id IS NULL OR c.modalidad_id=p.modalidad_id)) AS respondidos,(SELECT COUNT(*) FROM evaluacion_criterios ec JOIN criterios c ON c.id=ec.criterio_id WHERE ec.evaluacion_id=e.id AND ec.cumple=0 AND c.obligatorio=1 AND c.tipo=e.tipo AND (c.modalidad_id IS NULL OR c.modalidad_id=p.modalidad_id)) AS negativos FROM evaluaciones e JOIN proyectos p ON p.id=e.proyecto_id WHERE e.id=CAST(NULLIF(?::text,'') AS bigint) AND e.evaluador_id=CAST(NULLIF(?::text,'') AS bigint) AND e.estado='BORRADOR'<sql:param value="${param.evaluacion_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:query>
<c:if test="${empty comprobacion.rows or comprobacion.rows[0].total eq 0 or comprobacion.rows[0].respondidos ne comprobacion.rows[0].total or (param.concepto eq 'APROBADO' and comprobacion.rows[0].negativos gt 0)}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:transaction dataSource="${db}"><sql:update>UPDATE evaluaciones SET estado='DEFINITIVA',concepto=?,observaciones=?,similitud=?,enviado_en=NOW() WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND evaluador_id=CAST(NULLIF(?::text,'') AS bigint) AND estado='BORRADOR'<sql:param value="${param.concepto}"/><sql:param value="${param.observaciones}"/><sql:param value="${param.similitud}"/><sql:param value="${param.evaluacion_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update><sql:update>UPDATE proyectos SET estado=CASE WHEN ?='PROPUESTA' THEN CASE WHEN ?='APROBADO' THEN 'EVALUADA' ELSE 'CON_OBSERVACIONES' END WHEN ?='APROBADO' THEN 'LISTO_SUSTENTACION' ELSE 'INFORME_EN_REVISION' END WHERE id=CAST(NULLIF(?::text,'') AS bigint)<sql:param value="${comprobacion.rows[0].tipo}"/><sql:param value="${param.concepto}"/><sql:param value="${param.concepto}"/><sql:param value="${comprobacion.rows[0].proyecto_id}"/></sql:update><sql:update>INSERT INTO historial(proyecto_id,usuario_id,evento,nuevo,detalle) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'Evaluación finalizada',?,?)<sql:param value="${comprobacion.rows[0].proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.concepto}"/><sql:param value="${param.observaciones}"/></sql:update></sql:transaction>
<c:set var="destino" value="/evaluador/evaluacion.jsp?id=${comprobacion.rows[0].proyecto_id}&ok=1"/>
</c:when>
<c:when test="${param.accion eq 'comite_decidir'}">
<c:if test="${sessionScope.rol ne 'COMITE' or empty param.observacion or (not empty param.acta_url and (not fn:startsWith(param.acta_url,'https://') or fn:length(param.acta_url) gt 900))}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:query var="proyecto" dataSource="${db}">SELECT p.* FROM proyectos p WHERE p.id=CAST(NULLIF(?::text,'') AS bigint)<sql:param value="${param.proyecto_id}"/></sql:query><c:if test="${empty proyecto.rows}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<c:set var="p" value="${proyecto.rows[0]}"/>
<c:if test="${not empty param.acta_token}"><sql:query var="soporteActa" dataSource="${db}">SELECT id FROM archivos WHERE token=? AND proyecto_id=CAST(NULLIF(?::text,'') AS bigint) AND tipo='Acta del Comité' AND estado='COMPLETO'<sql:param value="${param.acta_token}"/><sql:param value="${p.id}"/></sql:query><c:if test="${empty soporteActa.rows}"><c:redirect url="/comite/decisiones.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if></c:if>
<sql:query var="evaluacion" dataSource="${db}">SELECT e.* FROM evaluaciones e WHERE e.proyecto_id=CAST(NULLIF(?::text,'') AS bigint) AND e.tipo='PROPUESTA' AND e.estado='DEFINITIVA' ORDER BY e.id DESC LIMIT 1<sql:param value="${p.id}"/></sql:query>
<c:if test="${param.resultado eq 'APROBADO' and (p.fase ne 'PROPUESTA' or p.estado ne 'EVALUADA' or empty evaluacion.rows or evaluacion.rows[0].concepto ne 'APROBADO')}"><c:redirect url="/comite/decisiones.jsp"><c:param name="error" value="fase"/></c:redirect></c:if>
<c:if test="${param.resultado eq 'FINALIZADO' and (p.fase ne 'SUSTENTACION' and p.fase ne 'INFORME_FINAL')}"><c:redirect url="/comite/decisiones.jsp"><c:param name="error" value="fase"/></c:redirect></c:if>
<c:if test="${param.resultado eq 'FINALIZADO'}"><sql:query var="totalCierre" dataSource="${db}">SELECT COUNT(*) AS total FROM evaluaciones e JOIN sustentaciones s ON s.proyecto_id=e.proyecto_id WHERE e.proyecto_id=CAST(NULLIF(?::text,'') AS bigint) AND e.tipo='INFORME_FINAL' AND e.concepto='APROBADO' AND e.estado='DEFINITIVA' AND s.estado='REALIZADA' AND s.concepto='APROBADA' AND EXISTS(SELECT 1 FROM decisiones de WHERE de.proyecto_id=e.proyecto_id AND de.tipo='PROPUESTA' AND de.resultado='APROBADO') AND EXISTS(SELECT 1 FROM propuestas v WHERE v.proyecto_id=e.proyecto_id AND v.oficial=1) AND EXISTS(SELECT 1 FROM documentos d WHERE d.proyecto_id=e.proyecto_id AND d.tipo='Informe Final') AND NOT EXISTS(SELECT 1 FROM entregables_modalidad em JOIN proyectos ep ON ep.id=e.proyecto_id WHERE em.modalidad_id=ep.modalidad_id AND em.obligatorio=1 AND NOT EXISTS(SELECT 1 FROM documentos d2 WHERE d2.proyecto_id=e.proyecto_id AND d2.tipo=em.tipo))<sql:param value="${p.id}"/></sql:query><c:if test="${totalCierre.rows[0].total eq 0}"><c:redirect url="/comite/decisiones.jsp"><c:param name="error" value="fase"/></c:redirect></c:if></c:if>
<sql:transaction dataSource="${db}">
<sql:update>INSERT INTO decisiones(proyecto_id,comite_id,tipo,resultado,observacion,acta_url,acta_token) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),uts_if(?='FINALIZADO','CIERRE','PROPUESTA'),?,?,NULLIF(?,''),NULLIF(?,''))<sql:param value="${p.id}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.resultado}"/><sql:param value="${param.resultado}"/><sql:param value="${param.observacion}"/><sql:param value="${param.acta_url}"/><sql:param value="${param.acta_token}"/></sql:update>
<c:choose><c:when test="${param.resultado eq 'APROBADO'}">
<sql:update>UPDATE proyectos SET fase='DESARROLLO',estado='APROBADO' WHERE id=CAST(NULLIF(?::text,'') AS bigint)<sql:param value="${p.id}"/></sql:update><sql:update>UPDATE propuestas SET oficial=uts_if(version=(SELECT m.ultima FROM(SELECT MAX(version) AS ultima FROM propuestas WHERE proyecto_id=CAST(NULLIF(?::text,'') AS bigint)) m),1,0) WHERE proyecto_id=CAST(NULLIF(?::text,'') AS bigint)<sql:param value="${p.id}"/><sql:param value="${p.id}"/></sql:update>
</c:when><c:when test="${param.resultado eq 'FINALIZADO'}"><sql:update>UPDATE proyectos SET fase='CIERRE',estado='FINALIZADO' WHERE id=CAST(NULLIF(?::text,'') AS bigint)<sql:param value="${p.id}"/></sql:update></c:when><c:when test="${param.resultado eq 'DEVUELTO'}"><sql:update>UPDATE proyectos SET fase='PROPUESTA',estado='CON_OBSERVACIONES' WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND estado!='FINALIZADO'<sql:param value="${p.id}"/></sql:update></c:when><c:otherwise><sql:update>UPDATE proyectos SET estado='RECHAZADO' WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND fase='PROPUESTA'<sql:param value="${p.id}"/></sql:update></c:otherwise></c:choose>
<sql:update>INSERT INTO historial(proyecto_id,usuario_id,evento,anterior,nuevo,detalle) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'Decisión del Comité',?,?,?)<sql:param value="${p.id}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${p.estado}"/><sql:param value="${param.resultado}"/><sql:param value="${param.observacion}"/></sql:update>
<sql:update>INSERT INTO notificaciones(usuario_id,proyecto_id,mensaje) SELECT u.id,CAST(NULLIF(?::text,'') AS bigint),CONCAT('Decisión del Comité para ',? , ': ',?,' (',to_char(NOW(),'YYYY-MM-DD'),')') FROM usuarios u WHERE (u.id=CAST(NULLIF(?::text,'') AS bigint) OR u.id=CAST(NULLIF(?::text,'') AS bigint)) AND u.activo=1
<sql:param value="${p.id}"/><sql:param value="${p.codigo}"/><sql:param value="${param.resultado}"/><sql:param value="${p.estudiante_id}"/><sql:param value="${p.director_id}"/></sql:update>
<c:if test="${not empty param.numero_acta and not empty param.fecha_acta and fn:length(param.numero_acta) le 90}"><sql:update>INSERT INTO actas_respuestas_uts(proyecto_id,usuario_id,numero_acta,fecha_acta,resultado,comentarios) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),?,?,?,?)<sql:param value="${p.id}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.numero_acta}"/><sql:param value="${param.fecha_acta}"/><sql:param value="${param.resultado}"/><sql:param value="${param.observacion}"/></sql:update></c:if>
</sql:transaction><c:set var="destino" value="/comite/decisiones.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'cambio_resolver'}">
<c:if test="${sessionScope.rol ne 'COMITE' or (param.estado ne 'APROBADO' and param.estado ne 'RECHAZADO')}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:query var="solicitud" dataSource="${db}">SELECT c.*,p.fase,p.estado AS estado_proyecto FROM cambios_modalidad c JOIN proyectos p ON p.id=c.proyecto_id WHERE c.id=CAST(NULLIF(?::text,'') AS bigint) AND c.estado='PENDIENTE'<sql:param value="${param.id}"/></sql:query>
<c:if test="${empty solicitud.rows or (param.estado eq 'APROBADO' and (solicitud.rows[0].fase ne 'PROPUESTA' or (solicitud.rows[0].estado_proyecto ne 'BORRADOR' and solicitud.rows[0].estado_proyecto ne 'CON_OBSERVACIONES')))}"><c:redirect url="/comite/decisiones.jsp"><c:param name="error" value="fase"/></c:redirect></c:if>
<sql:transaction dataSource="${db}"><sql:update>UPDATE cambios_modalidad SET estado=?,responsable_id=CAST(NULLIF(?::text,'') AS bigint),resuelto_en=NOW() WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND estado='PENDIENTE'<sql:param value="${param.estado}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.id}"/></sql:update><c:if test="${param.estado eq 'APROBADO'}"><sql:update>UPDATE proyectos SET modalidad_id=CAST(NULLIF(?::text,'') AS bigint) WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND fase='PROPUESTA' AND estado IN ('BORRADOR','CON_OBSERVACIONES')<sql:param value="${solicitud.rows[0].nueva_id}"/><sql:param value="${solicitud.rows[0].proyecto_id}"/></sql:update></c:if><sql:update>INSERT INTO historial(proyecto_id,usuario_id,evento,anterior,nuevo) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'Cambio de modalidad',?,?)<sql:param value="${solicitud.rows[0].proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${solicitud.rows[0].anterior_id}"/><sql:param value="${solicitud.rows[0].nueva_id}"/></sql:update><sql:update>INSERT INTO notificaciones(usuario_id,proyecto_id,mensaje) SELECT u.id,CAST(NULLIF(?::text,'') AS bigint),CONCAT('Decisión del Comité para ',? , ': ',?,' (',to_char(NOW(),'YYYY-MM-DD'),')') FROM usuarios u WHERE (u.id=CAST(NULLIF(?::text,'') AS bigint) OR u.id=CAST(NULLIF(?::text,'') AS bigint)) AND u.activo=1
<sql:param value="${solicitud.rows[0].proyecto_id}"/><sql:param value="${solicitud.rows[0].proyecto_id}"/><sql:param value="${param.estado}"/><sql:param value="${solicitud.rows[0].solicitante_id}"/><sql:param value="${solicitud.rows[0].solicitante_id}"/></sql:update>
</sql:transaction><c:set var="destino" value="/comite/decisiones.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'sustentacion_crear'}">
<c:if test="${sessionScope.rol ne 'COMITE' or empty param.fecha or empty param.lugar}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:update var="afectadas" dataSource="${db}">INSERT INTO sustentaciones(proyecto_id,fecha,lugar,participantes) SELECT p.id,REPLACE(?,'T',' '),?,? FROM proyectos p WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND p.fase='INFORME_FINAL' AND p.estado='LISTO_SUSTENTACION' AND NOT EXISTS(SELECT 1 FROM sustentaciones s WHERE s.proyecto_id=p.id)<sql:param value="${param.fecha}"/><sql:param value="${param.lugar}"/><sql:param value="${param.participantes}"/><sql:param value="${param.proyecto_id}"/></sql:update><c:if test="${afectadas eq 0}"><c:redirect url="/comite/sustentaciones.jsp"><c:param name="error" value="fase"/></c:redirect></c:if>
<sql:update dataSource="${db}">UPDATE proyectos SET fase='SUSTENTACION' WHERE id=CAST(NULLIF(?::text,'') AS bigint)<sql:param value="${param.proyecto_id}"/></sql:update><c:set var="destino" value="/comite/sustentaciones.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'sustentacion_estado'}">
<c:if test="${sessionScope.rol ne 'COMITE'}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:update dataSource="${db}">UPDATE sustentaciones SET estado=? WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND ? IN ('PROGRAMADA','REALIZADA','CANCELADA')<sql:param value="${param.estado}"/><sql:param value="${param.id}"/><sql:param value="${param.estado}"/></sql:update><c:set var="destino" value="/comite/sustentaciones.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'excepcion_integrantes'}">
<c:if test="${sessionScope.rol ne 'COMITE' or (param.excepcion_tres ne '1' and param.excepcion_tres ne '0')}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:update var="afectadas" dataSource="${db}">UPDATE proyectos SET excepcion_tres=CAST(NULLIF(?::text,'') AS smallint) WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND fase='PROPUESTA' AND modalidad_id IN(SELECT m.id FROM modalidades m WHERE m.nombre IN('Proyecto de Investigación','Desarrollo Tecnológico'))<sql:param value="${param.excepcion_tres}"/><sql:param value="${param.proyecto_id}"/></sql:update>
<c:if test="${afectadas eq 0}"><c:redirect url="/comite/asignaciones.jsp"><c:param name="error" value="fase"/></c:redirect></c:if><sql:update dataSource="${db}">INSERT INTO historial(proyecto_id,usuario_id,evento,nuevo) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'Excepción de integrantes',?)<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.excepcion_tres}"/></sql:update><c:set var="destino" value="/comite/asignaciones.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'integrante_unirse'}">
<c:if test="${sessionScope.rol ne 'ESTUDIANTE' or empty fn:trim(param.codigo)}"><c:redirect url="/estudiante/proyectos.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:query var="proyectoUnir" dataSource="${db}">SELECT p.id,p.codigo FROM proyectos p JOIN usuarios u ON u.id=CAST(NULLIF(?::text,'') AS bigint) WHERE (p.codigo=? OR p.id::text=?) AND p.fase='PROPUESTA' AND p.estado='BORRADOR' AND u.rol='ESTUDIANTE' AND u.activo=1 AND u.programa_id=p.programa_id AND NOT EXISTS(SELECT 1 FROM proyecto_estudiantes e WHERE e.proyecto_id=p.id AND e.estudiante_id=u.id) AND (SELECT COUNT(*) FROM proyecto_estudiantes e2 WHERE e2.proyecto_id=p.id) < CASE WHEN p.excepcion_tres=1 THEN 3 ELSE 2 END
<sql:param value="${sessionScope.usuarioId}"/><sql:param value="${fn:trim(param.codigo)}"/><sql:param value="${fn:trim(param.codigo)}"/></sql:query>
<c:if test="${empty proyectoUnir.rows}"><c:redirect url="/estudiante/proyectos.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update var="afectadas" dataSource="${db}">INSERT INTO proyecto_estudiantes(proyecto_id,estudiante_id)
SELECT p.id,u.id FROM proyectos p JOIN usuarios u ON u.id=CAST(NULLIF(?::text,'') AS bigint)
WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND p.fase='PROPUESTA' AND p.estado='BORRADOR' AND u.rol='ESTUDIANTE' AND u.activo=1 AND u.programa_id=p.programa_id AND NOT EXISTS(SELECT 1 FROM proyecto_estudiantes e WHERE e.proyecto_id=p.id AND e.estudiante_id=u.id) AND (SELECT COUNT(*) FROM proyecto_estudiantes e2 WHERE e2.proyecto_id=p.id) < CASE WHEN p.excepcion_tres=1 THEN 3 ELSE 2 END
<sql:param value="${sessionScope.usuarioId}"/><sql:param value="${proyectoUnir.rows[0].id}"/></sql:update>
<c:if test="${afectadas eq 0}"><c:redirect url="/estudiante/proyectos.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update dataSource="${db}">INSERT INTO historial(proyecto_id,usuario_id,evento,detalle) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'Estudiante vinculado','Integración mediante código del proyecto')
<sql:param value="${proyectoUnir.rows[0].id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
<c:set var="destino" value="/estudiante/proyectos.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'integrante_agregar'}">
<c:if test="${sessionScope.rol ne 'ESTUDIANTE' or empty param.identificacion}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update var="afectadas" dataSource="${db}">INSERT INTO proyecto_estudiantes(proyecto_id,estudiante_id)
SELECT p.id,u.id FROM proyectos p JOIN usuarios u ON u.identificacion=? AND u.rol='ESTUDIANTE' AND u.activo=1 AND u.programa_id=p.programa_id WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND p.estudiante_id=CAST(NULLIF(?::text,'') AS bigint) AND p.estado='BORRADOR' AND NOT EXISTS(SELECT 1 FROM proyecto_estudiantes pe WHERE pe.proyecto_id=p.id AND pe.estudiante_id=u.id) AND (SELECT COUNT(*) FROM proyecto_estudiantes pe2 WHERE pe2.proyecto_id=p.id) < uts_if(p.excepcion_tres=1 AND p.modalidad_id IN (SELECT m.id FROM modalidades m WHERE m.nombre IN('Proyecto de Investigación','Desarrollo Tecnológico')),3,2) AND ((u.plan='ANTERIOR' AND u.metodologia=1 AND (u.creditos>=75 OR (p.modalidad_id IN(SELECT m.id FROM modalidades m WHERE m.nombre='Práctica') AND u.creditos>=uts_if(u.nivel='TECNICO',70,90)))) OR (u.plan='POSTERIOR' AND ((u.nivel='TECNOLOGO' AND u.matricula_seminario_i=1 AND u.seminario_i=1 AND u.seminario_ii=1) OR (u.nivel='PROFESIONAL' AND u.matricula_seminario_iii=1 AND u.seminario_iii=1 AND u.seminario_iv=1) OR (u.nivel='TECNICO' AND u.matricula_seminario_i=1 AND u.seminario_i=1 AND u.seminario_ii=1))))
<sql:param value="${param.identificacion}"/><sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
<c:if test="${afectadas eq 0}"><c:redirect url="/estudiante/proyectos.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if><sql:update dataSource="${db}">INSERT INTO historial(proyecto_id,usuario_id,evento,detalle) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'Integrante registrado',?)<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.identificacion}"/></sql:update><c:set var="destino" value="/estudiante/integrantes.jsp?id=${param.proyecto_id}&ok=1"/>
</c:when>
<c:when test="${param.accion eq 'grupo_crear' or param.accion eq 'linea_crear' or param.accion eq 'formato_crear'}">
<c:if test="${sessionScope.rol ne 'COMITE' or empty param.nombre}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<c:choose>
<c:when test="${param.accion eq 'grupo_crear'}"><sql:update dataSource="${db}">INSERT INTO grupos_investigacion(programa_id,nombre) VALUES(?,?)<sql:param value="${param.programa_id}"/><sql:param value="${param.nombre}"/></sql:update></c:when>
<c:when test="${param.accion eq 'linea_crear'}"><sql:update dataSource="${db}">INSERT INTO lineas_investigacion(grupo_id,nombre) VALUES(?,?)<sql:param value="${param.grupo_id}"/><sql:param value="${param.nombre}"/></sql:update></c:when>
<c:otherwise><c:if test="${not fn:startsWith(param.url,'https://')}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if><sql:update dataSource="${db}">INSERT INTO formatos(nombre,version,url) VALUES(?,?,?)<sql:param value="${param.nombre}"/><sql:param value="${param.version}"/><sql:param value="${param.url}"/></sql:update></c:otherwise>
</c:choose><c:set var="destino" value="/comite/catalogos.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'sustentacion_concepto'}">
<c:if test="${sessionScope.rol ne 'EVALUADOR' or empty param.concepto}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:update var="afectadas" dataSource="${db}">UPDATE sustentaciones s SET concepto=? FROM proyectos p WHERE p.id=s.proyecto_id AND s.proyecto_id=CAST(NULLIF(?::text,'') AS bigint) AND p.evaluador_id=CAST(NULLIF(?::text,'') AS bigint) AND s.estado='REALIZADA'<sql:param value="${param.concepto}"/><sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update><c:if test="${afectadas eq 0}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="fase"/></c:redirect></c:if><c:set var="destino" value="/evaluador/proyectos.jsp?ok=1"/>
</c:when>


<c:when test="${param.accion eq 'similitud_registrar'}">
<c:if test="${(sessionScope.rol ne 'DIRECTOR' and sessionScope.rol ne 'EVALUADOR') or empty param.resultado or fn:length(param.resultado) gt 120}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update var="registrado" dataSource="${db}">INSERT INTO observaciones(proyecto_id,tipo,usuario_id,comentario) SELECT p.id,'PROPUESTA',?,CONCAT('Revisión de similitud (Turnitin): ',?) FROM proyectos p WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND ((?='DIRECTOR' AND p.director_id=CAST(NULLIF(?::text,'') AS bigint)) OR (?='EVALUADOR' AND p.evaluador_id=CAST(NULLIF(?::text,'') AS bigint)))
<sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.resultado}"/><sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.rol}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${sessionScope.rol}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update><c:set var="destino" value="/comun/historial.jsp?id=${param.proyecto_id}&amp;ok=1"/>
</c:when>
<c:when test="${param.accion eq 'notificacion_leida'}">
<sql:update dataSource="${db}">UPDATE notificaciones SET leida=1 WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND usuario_id=CAST(NULLIF(?::text,'') AS bigint)<sql:param value="${param.id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update><c:set var="destino" value="/comun/notificaciones.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'periodo_actualizar'}">
<c:if test="${sessionScope.rol ne 'COMITE' or empty param.nombre or param.fin lt param.inicio or param.cierre lt param.apertura or param.apertura lt param.inicio or param.cierre gt param.fin}"><c:redirect url="/comite/periodos.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update var="modificados" dataSource="${db}">UPDATE periodos SET nombre=?, inicio=?,fin=?,apertura_banco=?,cierre_banco=? WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND estado!='CERRADO'<sql:param value="${param.nombre}"/><sql:param value="${param.inicio}"/><sql:param value="${param.fin}"/><sql:param value="${param.apertura}"/><sql:param value="${param.cierre}"/><sql:param value="${param.id}"/></sql:update>
<c:if test="${modificados eq 0}"><c:redirect url="/comite/periodos.jsp"><c:param name="error" value="fase"/></c:redirect></c:if><c:set var="destino" value="/comite/periodos.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'calendario_actualizar'}">
<c:if test="${sessionScope.rol ne 'COMITE' or empty param.actividad or param.fin lt param.inicio}"><c:redirect url="/comite/periodos.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update var="modificados" dataSource="${db}">UPDATE calendario c SET actividad=?,inicio=REPLACE(?,'T',' '),fin=REPLACE(?,'T',' ') FROM periodos p WHERE p.id=c.periodo_id AND c.id=CAST(NULLIF(?::text,'') AS bigint) AND p.estado!='CERRADO'<sql:param value="${param.actividad}"/><sql:param value="${param.inicio}"/><sql:param value="${param.fin}"/><sql:param value="${param.id}"/></sql:update>
<c:if test="${modificados eq 0}"><c:redirect url="/comite/periodos.jsp"><c:param name="error" value="fase"/></c:redirect></c:if><c:set var="destino" value="/comite/periodos.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'idea_actualizar'}">
<c:if test="${sessionScope.rol ne 'COMITE' or empty param.titulo or empty param.descripcion or (param.estado ne 'ABIERTA' and param.estado ne 'CERRADA')}"><c:redirect url="/comite/ideas.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update var="modificados" dataSource="${db}">UPDATE ideas SET titulo=?,descripcion=?,estado=? WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND NOT EXISTS(SELECT 1 FROM proyectos p WHERE p.idea_id=ideas.id AND p.estado NOT IN('BORRADOR','RECHAZADO'))<sql:param value="${param.titulo}"/><sql:param value="${param.descripcion}"/><sql:param value="${param.estado}"/><sql:param value="${param.id}"/></sql:update>
<c:if test="${modificados eq 0}"><c:redirect url="/comite/ideas.jsp"><c:param name="error" value="fase"/></c:redirect></c:if><c:set var="destino" value="/comite/ideas.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'pago_validar'}">
<c:if test="${sessionScope.rol ne 'COMITE' or (param.estado ne 'VALIDADO' and param.estado ne 'RECHAZADO')}"><c:redirect url="/comite/pagos.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update var="modificados" dataSource="${db}">UPDATE pagos SET estado=?,validado_por=CAST(NULLIF(?::text,'') AS bigint),validado_en=NOW()
WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND estado='PENDIENTE'
<sql:param value="${param.estado}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.id}"/></sql:update>
<c:if test="${modificados eq 0}"><c:redirect url="/comite/pagos.jsp"><c:param name="error" value="fase"/></c:redirect></c:if>
<sql:query var="pagoActual" dataSource="${db}">SELECT proyecto_id FROM pagos WHERE id=CAST(NULLIF(?::text,'') AS bigint)<sql:param value="${param.id}"/></sql:query>
<sql:update dataSource="${db}">INSERT INTO historial(proyecto_id,usuario_id,evento,nuevo) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'Pago revisado',?)
<sql:param value="${pagoActual.rows[0].proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.estado}"/></sql:update>
<c:set var="destino" value="/comite/pagos.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'publicacion_configurar'}">
<c:if test="${sessionScope.rol ne 'COMITE' or (param.acceso ne 'PUBLICO' and param.acceso ne 'RESTRINGIDO' and param.acceso ne 'RESERVADO') or (param.estado ne 'PENDIENTE' and param.estado ne 'PUBLICADO') or (param.estado eq 'PUBLICADO' and not fn:startsWith(param.link_repositorio,'https://'))}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:update var="modificados" dataSource="${db}">INSERT INTO publicaciones(proyecto_id,acceso,estado,motivo,link_repositorio,responsable_id) SELECT p.id,?,?,?,?,? FROM proyectos p WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND p.estado='FINALIZADO' ON CONFLICT (proyecto_id) DO UPDATE SET acceso=EXCLUDED.acceso,estado=EXCLUDED.estado,motivo=EXCLUDED.motivo,link_repositorio=EXCLUDED.link_repositorio,responsable_id=EXCLUDED.responsable_id,fecha=NOW()<sql:param value="${param.acceso}"/><sql:param value="${param.estado}"/><sql:param value="${param.motivo}"/><sql:param value="${param.link_repositorio}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.proyecto_id}"/></sql:update><c:set var="destino" value="/comite/publicaciones.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'perfil_docente'}">
<c:if test="${sessionScope.rol ne 'COMITE' or (param.disponible ne '0' and param.disponible ne '1') or (param.habilitado ne '0' and param.habilitado ne '1')}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update var="n" dataSource="${db}">INSERT INTO perfiles_docentes(usuario_id,programa_id,disponible,habilitado_evaluador) SELECT u.id,pr.id,?,? FROM usuarios u JOIN programas pr ON pr.id=CAST(NULLIF(?::text,'') AS bigint) AND pr.activo=1 WHERE u.id=CAST(NULLIF(?::text,'') AS bigint) AND u.rol IN('DIRECTOR','EVALUADOR') AND u.activo=1 ON CONFLICT (usuario_id,programa_id) DO UPDATE SET disponible=EXCLUDED.disponible,habilitado_evaluador=EXCLUDED.habilitado_evaluador
<sql:param value="${param.disponible}"/><sql:param value="${param.habilitado}"/><sql:param value="${param.programa_id}"/><sql:param value="${param.usuario_id}"/></sql:update>
<c:if test="${n eq 0}"><c:redirect url="/comite/perfiles.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if><c:set var="destino" value="/comite/perfiles.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'excepcion_evaluador_propuesta'}">
<c:if test="${sessionScope.rol ne 'COMITE' or (param.habilitar ne '0' and param.habilitar ne '1')}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:update var="n" dataSource="${db}">UPDATE proyectos p SET evaluador_propuesta_excepcion_id=CASE WHEN ?='1' THEN p.director_id ELSE NULL END FROM usuarios u WHERE u.id=p.estudiante_id AND p.id=CAST(NULLIF(?::text,'') AS bigint) AND p.fase='PROPUESTA' AND p.estado IN('BORRADOR','EN_REVISION','AVAL_DIRECTOR') AND u.plan='POSTERIOR' AND p.director_id IS NOT NULL AND (SELECT COUNT(*) FROM evaluaciones e WHERE e.proyecto_id=p.id AND e.tipo='PROPUESTA' AND e.estado='DEFINITIVA')=0
<sql:param value="${param.habilitar}"/><sql:param value="${param.proyecto_id}"/></sql:update>
<c:if test="${n eq 0}"><c:redirect url="/comite/asignaciones.jsp"><c:param name="error" value="fase"/></c:redirect></c:if>
<sql:update dataSource="${db}">INSERT INTO historial(proyecto_id,usuario_id,evento,nuevo) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'Excepción Director/Evaluador de propuesta',?)<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.habilitar}"/></sql:update><c:set var="destino" value="/comite/asignaciones.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'autorizar_cambio_oficial'}">
<c:if test="${sessionScope.rol ne 'COMITE' or empty param.motivo}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update var="afectadas" dataSource="${db}">UPDATE proyectos SET cambio_oficial_autorizado=1 WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND fase='DESARROLLO' AND estado IN('APROBADO','DESARROLLO') AND EXISTS(SELECT 1 FROM propuestas v WHERE v.proyecto_id=proyectos.id AND v.oficial=1)
<sql:param value="${param.proyecto_id}"/></sql:update>
<c:if test="${afectadas eq 0}"><c:redirect url="/comite/decisiones.jsp"><c:param name="error" value="fase"/></c:redirect></c:if>
<sql:update dataSource="${db}">INSERT INTO historial(proyecto_id,usuario_id,evento,anterior,nuevo,detalle) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'Autorización cambio oficial','BLOQUEADO','UN_CAMBIO',?)<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.motivo}"/></sql:update><c:set var="destino" value="/comite/decisiones.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'regla_pago'}">
<c:if test="${sessionScope.rol ne 'COMITE' or (param.plan ne 'ANTERIOR' and param.plan ne 'POSTERIOR') or param.periodos_vigencia lt 1 or param.periodos_vigencia gt 24 or (param.requiere_pago ne '0' and param.requiere_pago ne '1')}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update var="n" dataSource="${db}">INSERT INTO reglas_pagos(modalidad_id,plan,periodos_vigencia,requiere_pago) SELECT id,?,?,? FROM modalidades WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND activo=1 ON CONFLICT (modalidad_id,plan) DO UPDATE SET periodos_vigencia=EXCLUDED.periodos_vigencia,requiere_pago=EXCLUDED.requiere_pago,activo=1
<sql:param value="${param.plan}"/><sql:param value="${param.periodos_vigencia}"/><sql:param value="${param.requiere_pago}"/><sql:param value="${param.modalidad_id}"/></sql:update><c:set var="destino" value="/comite/reglas_pagos.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'criterio_crear'}">
<c:if test="${sessionScope.rol ne 'COMITE' or empty param.nombre or fn:length(param.nombre) gt 160 or (param.tipo ne 'PROPUESTA' and param.tipo ne 'INFORME_FINAL') or (param.obligatorio ne '0' and param.obligatorio ne '1')}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update dataSource="${db}">INSERT INTO criterios(modalidad_id,tipo,nombre,obligatorio) SELECT CAST(NULLIF(?::text,'') AS bigint),?,?,? FROM (SELECT 1 AS x) a WHERE (?='' OR EXISTS(SELECT 1 FROM modalidades WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND activo=1))
<sql:param value="${param.modalidad_id}"/><sql:param value="${param.tipo}"/><sql:param value="${param.nombre}"/><sql:param value="${param.obligatorio}"/><sql:param value="${param.modalidad_id}"/><sql:param value="${param.modalidad_id}"/></sql:update><c:set var="destino" value="/comite/criterios.jsp?ok=1"/>
</c:when>
<c:when test="${param.accion eq 'solicitar_reevaluacion'}">
<c:if test="${sessionScope.rol ne 'DIRECTOR'}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:if>
<sql:update var="n" dataSource="${db}">UPDATE proyectos p SET estado='INFORME_AVALADO' WHERE p.id=CAST(NULLIF(?::text,'') AS bigint) AND p.director_id=CAST(NULLIF(?::text,'') AS bigint) AND p.fase='INFORME_FINAL' AND p.estado='INFORME_EN_REVISION' AND EXISTS(SELECT 1 FROM evaluaciones e WHERE e.proyecto_id=p.id AND e.tipo='INFORME_FINAL' AND e.estado='DEFINITIVA' AND e.concepto='CORRECCIONES') AND (SELECT COUNT(*) FROM documentos d WHERE d.proyecto_id=p.id AND d.tipo='Informe Final')>=2
<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
<c:if test="${n eq 0}"><c:redirect url="/director/proyectos.jsp"><c:param name="error" value="fase"/></c:redirect></c:if>
<sql:update dataSource="${db}">INSERT INTO historial(proyecto_id,usuario_id,evento,anterior,nuevo) VALUES(CAST(NULLIF(?::text,'') AS bigint),CAST(NULLIF(?::text,'') AS bigint),'Nueva evaluación solicitada','INFORME_EN_REVISION','INFORME_AVALADO')<sql:param value="${param.proyecto_id}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update><c:set var="destino" value="/director/revision.jsp?id=${param.proyecto_id}&amp;ok=1"/>
</c:when>
<c:when test="${param.accion eq 'entregable_parametrizar'}">
<c:if test="${sessionScope.rol ne 'COMITE' or empty param.tipo or fn:length(param.tipo) gt 90 or (param.obligatorio ne '0' and param.obligatorio ne '1')}"><c:redirect url="/dashboard.jsp"><c:param name="error" value="validacion"/></c:redirect></c:if>
<sql:update dataSource="${db}">INSERT INTO entregables_modalidad(modalidad_id,tipo,obligatorio) SELECT id,?,? FROM modalidades WHERE id=CAST(NULLIF(?::text,'') AS bigint) AND activo=1 ON CONFLICT (modalidad_id,tipo) DO UPDATE SET obligatorio=EXCLUDED.obligatorio
<sql:param value="${param.tipo}"/><sql:param value="${param.obligatorio}"/><sql:param value="${param.modalidad_id}"/></sql:update><c:set var="destino" value="/comite/entregables.jsp?ok=1"/>
</c:when>
<c:otherwise><c:redirect url="/dashboard.jsp"><c:param name="error" value="acceso"/></c:redirect></c:otherwise>
</c:choose>
<%-- Rastro de TODA petición de escritura completada. Anterior/nuevo de fases se guardan en historial. --%>
<sql:update dataSource="${db}">INSERT INTO auditoria(usuario_id,proyecto_id,entidad,accion,anterior,nuevo) VALUES(CAST(NULLIF(?::text,'') AS bigint),(SELECT p.id FROM proyectos p WHERE p.id=CAST(NULLIF(?::text,'') AS bigint)),?,?,?,?)
<sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.proyecto_id}"/><sql:param value="${param.accion}"/><sql:param value="${param.accion}"/><sql:param value="${not empty antes.rows ? antes.rows[0].rol : ''}"/><sql:param value="${not empty param.estado ? param.estado : (not empty param.resultado ? param.resultado : (not empty param.rol ? param.rol : 'REGISTRO'))}"/></sql:update>
<%-- Refuerzo de trazabilidad: operación asociada al proyecto, si el cambio se completó. --%>
<sql:update dataSource="${db}">INSERT INTO historial(proyecto_id,usuario_id,evento,nuevo,detalle)
 SELECT p.id,CAST(NULLIF(?::text,'') AS bigint),LEFT(CONCAT('Operación ',?),150),p.estado,LEFT(CONCAT('Acción de ',?,' desde panel institucional'),300)
 FROM proyectos p WHERE p.id=CAST(NULLIF(?::text,'') AS bigint)
<sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.accion}"/><sql:param value="${sessionScope.rol}"/><sql:param value="${param.proyecto_id}"/></sql:update>
<c:redirect url="${destino}"/>
