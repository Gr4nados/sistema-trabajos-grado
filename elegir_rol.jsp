<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<%-- Un docente puede ser Director y Evaluador: aqui escoge con cual entra. --%>
<c:if test="${empty sessionScope.idUsuario}"><c:redirect url="/login.jsp" /></c:if>

<c:if test="${pageContext.request.method == 'POST'}">
  <%-- Solo se acepta un rol que el usuario realmente tenga --%>
  <c:forEach var="r" items="${sessionScope.rolesUsuario.rows}">
    <c:if test="${r.nombre == param.rol}">
      <c:set var="rol" value="${r.nombre}" scope="session" />
      <%@ include file="/includes/ir_inicio.jsp" %>
    </c:if>
  </c:forEach>
</c:if>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Elegir rol - Trabajos de Grado</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body class="pagina-login">
  <form class="tarjeta login" method="post" action="elegir_rol.jsp">
    <h1>Elige tu rol</h1>
    <p class="suave"><c:out value="${sessionScope.nombreCompleto}" />, ¿con qué rol quieres entrar?</p>
    <c:forEach var="r" items="${sessionScope.rolesUsuario.rows}">
      <button type="submit" name="rol" value="${r.nombre}"><c:out value="${r.nombre}" /></button>
    </c:forEach>
    <a href="logout.jsp">Cancelar</a>
  </form>
</body>
</html>
