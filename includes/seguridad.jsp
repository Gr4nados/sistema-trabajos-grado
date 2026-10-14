<%--
  seguridad.jsp - Control de acceso. Se incluye al INICIO de cada pagina protegida,
  despues de declarar las taglibs y ANTES de cualquier salida HTML:
    <c:set var="rolRequerido" value="Estudiante" />
    <%@ include file="/includes/seguridad.jsp" %>
  Si no hay sesion -> login.jsp. Si el rol no corresponde -> index.jsp (inicio).
--%>
<c:choose>
  <c:when test="${empty sessionScope.idUsuario}">
    <c:redirect url="/login.jsp" />
  </c:when>
  <c:when test="${sessionScope.rol != rolRequerido}">
    <c:redirect url="/index.jsp" />
  </c:when>
</c:choose>
