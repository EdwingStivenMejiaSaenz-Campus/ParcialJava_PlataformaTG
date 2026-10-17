<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:remove var="usuarioId" scope="session"/><c:remove var="rol" scope="session"/><c:remove var="nombre" scope="session"/><c:remove var="csrf" scope="session"/>
<c:redirect url="/index.jsp"/>
