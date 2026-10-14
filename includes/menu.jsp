<%--
  menu.jsp - Menu independiente por rol (RF-04). Requiere la fuente de datos "bd".
  Nota v0.1: solo se listan las paginas que ya existen; se agregan al avanzar.
--%>
<c:set var="raiz" value="${pageContext.request.contextPath}" />
<sql:query var="enlaces" dataSource="${bd}">SELECT nombre, url FROM enlace ORDER BY id_enlace</sql:query>
<nav class="menu">
  <span class="marca">Trabajos de Grado</span>
  <a href="${raiz}/index.jsp">Inicio</a>

  <c:choose>
    <c:when test="${sessionScope.rol == 'Administrador'}">
      <a href="${raiz}/admin/usuarios.jsp">Usuarios</a>
    </c:when>
    <c:when test="${sessionScope.rol == 'Estudiante'}">
      <%-- v0.3+: Banco de ideas, Proyecto, Documentos, Calificaciones --%>
    </c:when>
    <c:when test="${sessionScope.rol == 'Coordinador'}">
      <%-- v0.4+: Buscar, Ideas pendientes, Asignar director/evaluador, Revisiones, Informes --%>
    </c:when>
    <c:when test="${sessionScope.rol == 'Director'}">
      <%-- v0.3+: Ideas, Anteproyectos --%>
    </c:when>
    <c:when test="${sessionScope.rol == 'Evaluador'}">
      <%-- v0.5+: Anteproyectos, Turnitin y Rejilla (solo visuales) --%>
    </c:when>
  </c:choose>

  <c:forEach var="e" items="${enlaces.rows}">
    <a href="${e.url}" target="_blank" rel="noopener"><c:out value="${e.nombre}" /></a>
  </c:forEach>

  <span class="espacio"></span>
  <span class="sesion">
    <c:out value="${sessionScope.nombreCompleto}" /> (<c:out value="${sessionScope.rol}" />)
  </span>
  <c:if test="${sessionScope.cantidadRoles > 1}">
    <a href="${raiz}/elegir_rol.jsp">Cambiar rol</a>
  </c:if>
  <a href="${raiz}/logout.jsp">Salir</a>
</nav>
