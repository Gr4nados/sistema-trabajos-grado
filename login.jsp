<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<%@ include file="/includes/conexion.jsp" %>
<%-- RF-01: inicio de sesion. Procesa el formulario en esta misma pagina. --%>
<c:if test="${pageContext.request.method == 'POST'}">
  <sql:query var="resUsuario" dataSource="${bd}">
    SELECT id_usuario, nombres, apellidos FROM usuario
    WHERE usuario = ? AND contrasena = SHA2(?, 256) AND activo = TRUE
    <sql:param value="${param.usuario}" />
    <sql:param value="${param.clave}" />
  </sql:query>

  <c:choose>
    <c:when test="${resUsuario.rowCount == 1}">
      <c:set var="u" value="${resUsuario.rows[0]}" />
      <sql:query var="resRoles" dataSource="${bd}">
        SELECT r.nombre FROM usuario_rol ur JOIN rol r ON r.id_rol = ur.id_rol
        WHERE ur.id_usuario = ? ORDER BY r.id_rol
        <sql:param value="${u.id_usuario}" />
      </sql:query>

      <c:choose>
        <c:when test="${resRoles.rowCount == 0}">
          <c:set var="error" value="El usuario no tiene ningún rol asignado." />
        </c:when>
        <c:otherwise>
          <c:set var="idUsuario" value="${u.id_usuario}" scope="session" />
          <c:set var="nombreCompleto" value="${u.nombres} ${u.apellidos}" scope="session" />
          <c:set var="rolesUsuario" value="${resRoles}" scope="session" />
          <c:set var="cantidadRoles" value="${resRoles.rowCount}" scope="session" />
          <c:choose>
            <c:when test="${resRoles.rowCount == 1}">
              <c:set var="rol" value="${resRoles.rows[0].nombre}" scope="session" />
              <%@ include file="/includes/ir_inicio.jsp" %>
            </c:when>
            <c:otherwise>
              <c:redirect url="/elegir_rol.jsp" />
            </c:otherwise>
          </c:choose>
        </c:otherwise>
      </c:choose>
    </c:when>
    <c:otherwise>
      <c:set var="error" value="Usuario o contraseña incorrectos." />
    </c:otherwise>
  </c:choose>
</c:if>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Iniciar sesión - Trabajos de Grado</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css?v=0.9.3">
</head>
<body class="pagina-login">
  <div class="acceso">
    <div class="acceso-panel">
      <img src="${pageContext.request.contextPath}/img/mascota.png" alt="">
      <h2>Trabajos de Grado</h2>
      <p>Sigue tu proyecto de principio a fin</p>
    </div>
    <form class="acceso-form" method="post" action="login.jsp">
      <h1>Iniciar sesión</h1>
      <p class="suave">Ingresa con tu usuario y contraseña.</p>
      <c:if test="${not empty error}">
        <p class="error"><c:out value="${error}" /></p>
      </c:if>
      <label for="usuario">Usuario</label>
      <input type="text" id="usuario" name="usuario" required autofocus
             value="<c:out value='${param.usuario}' />">
      <label for="clave">Contraseña</label>
      <input type="password" id="clave" name="clave" required>
      <button type="submit">Entrar</button>
    </form>
  </div>
</body>
</html>
