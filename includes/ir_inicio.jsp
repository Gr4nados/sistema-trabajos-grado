<%--
  ir_inicio.jsp - Redirige a la pagina de inicio segun el rol activo en la sesion.
--%>
<c:choose>
  <c:when test="${sessionScope.rol == 'Administrador'}"><c:redirect url="/admin/inicio.jsp" /></c:when>
  <c:when test="${sessionScope.rol == 'Estudiante'}"><c:redirect url="/estudiante/inicio.jsp" /></c:when>
  <c:when test="${sessionScope.rol == 'Coordinador'}"><c:redirect url="/coordinador/inicio.jsp" /></c:when>
  <c:when test="${sessionScope.rol == 'Director'}"><c:redirect url="/director/inicio.jsp" /></c:when>
  <c:when test="${sessionScope.rol == 'Evaluador'}"><c:redirect url="/evaluador/inicio.jsp" /></c:when>
  <c:otherwise><c:redirect url="/login.jsp" /></c:otherwise>
</c:choose>
