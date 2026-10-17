<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<c:if test="${not empty sessionScope.usuarioId}"><c:redirect url="/dashboard.jsp"/></c:if>
<c:if test="${pageContext.request.method eq 'POST'}">
<c:choose><c:when test="${empty param.correo or empty param.clave}"><c:set var="errorLogin" value="Introduce el correo y la contraseña."/></c:when><c:otherwise>
<c:catch var="falloConexion"><%@ include file="/WEB-INF/jspf/pool.jspf" %><%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<sql:query var="autenticacion" dataSource="${db}">SELECT id,nombre,rol FROM usuarios WHERE correo=? AND clave_hash=sha2(CONCAT(sal,CAST(? AS TEXT)),256) AND activo=1 LIMIT 1
<sql:param value="${param.correo}"/><sql:param value="${param.clave}"/></sql:query></c:catch>
<c:choose><c:when test="${not empty falloConexion}"><c:set var="errorLogin" value="No se pudo consultar Supabase. Revisa el registro de Tomcat para identificar la causa de la conexión o la consulta."/></c:when>
<c:when test="${autenticacion.rowCount eq 1}"><c:set var="usuarioId" value="${autenticacion.rows[0].id}" scope="session"/><c:set var="rol" value="${autenticacion.rows[0].rol}" scope="session"/><c:set var="nombre" value="${autenticacion.rows[0].nombre}" scope="session"/>
<c:catch var="falloToken"><sql:query var="token" dataSource="${db}">SELECT uuid() AS v</sql:query></c:catch>
<c:if test="${empty falloToken}"><c:set var="csrf" value="${token.rows[0].v}" scope="session"/><c:redirect url="/dashboard.jsp"/></c:if>
<c:if test="${not empty falloToken}"><c:set var="errorLogin" value="No fue posible abrir la sesión. Comprueba la conexión a Supabase."/></c:if></c:when>
<c:otherwise><c:set var="errorLogin" value="Correo o contraseña incorrectos, o cuenta inactiva."/></c:otherwise></c:choose></c:otherwise></c:choose>
</c:if>
<!doctype html><html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Iniciar sesión · Ingeniería de Sistemas UTS</title><link rel="stylesheet" href="css/estilos.css"></head><body class="auth-page">
<section class="uts-auth"><img class="uts-auth-logo" src="img/logo-sistemas-transparente.png" alt="Ingeniería de Sistemas UTS"><form class="uts-auth-card" method="post" action="login.jsp" autocomplete="on">
<h1>Iniciar <span class="label-dark">SESIÓN</span></h1>
<c:if test="${not empty errorLogin}"><div class="alert error" role="alert"><c:out value="${errorLogin}"/></div></c:if>
<c:if test="${param.error eq 'sesion'}"><div class="alert error">Tu sesión ha finalizado. Inicia sesión de nuevo.</div></c:if>
<div class="field"><label for="correo">✉ Correo:</label><input type="email" id="correo" name="correo" value="<c:out value='${param.correo}'/>" placeholder="Ingrese su correo institucional." maxlength="160" autocomplete="username" required></div>
<div class="field"><label for="clave">♙ Contraseña:</label><input type="password" id="clave" name="clave" placeholder="**********" autocomplete="current-password" required></div>
<label class="check-simple"><input type="checkbox" name="recordar" value="1"> Mantener sesión activa</label>
<div class="auth-submit"><button type="submit" class="lime-button">ENVIAR</button></div>
<div class="auth-foot"><a href="ayuda_acceso.jsp?tipo=cuenta">Crear cuenta</a><a href="ayuda_acceso.jsp?tipo=clave">¿Olvidó su contraseña?</a></div></form></section>
</body></html>