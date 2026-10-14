<%--
  cabecera.jsp - Apertura del HTML + menu. Use antes la variable "titulo":
    <c:set var="titulo" value="Inicio" />
    <%@ include file="/includes/cabecera.jsp" %>
--%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><c:out value="${titulo}" /> - Trabajos de Grado</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body>
<%@ include file="/includes/menu.jsp" %>
<main class="contenido">
<%-- Mensaje de una sola vez (lo deja la pagina de accion antes de redirigir) --%>
<c:if test="${not empty sessionScope.mensaje}">
  <p class="${sessionScope.mensajeTipo == 'error' ? 'error' : 'exito'}"><c:out value="${sessionScope.mensaje}" /></p>
  <c:remove var="mensaje" scope="session" />
  <c:remove var="mensajeTipo" scope="session" />
</c:if>
