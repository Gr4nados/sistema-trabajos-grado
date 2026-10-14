<%--
  menu.jsp - Menu independiente por rol (RF-04). Requiere la fuente de datos "bd".
  Solo se listan las paginas que ya existen; se agregan al avanzar.
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
      <a href="${raiz}/estudiante/banco_ideas.jsp">Banco de ideas</a>
      <a href="${raiz}/estudiante/proyecto_nuevo.jsp">Nuevo proyecto</a>
      <a href="${raiz}/estudiante/asignar_idea.jsp">Asignar idea</a>
      <a href="${raiz}/estudiante/documentos.jsp">Documentos</a>
      <a href="${raiz}/estudiante/calificaciones.jsp">Calificaciones</a>
    </c:when>
    <c:when test="${sessionScope.rol == 'Coordinador'}">
      <a href="${raiz}/coordinador/buscar.jsp">Buscar</a>
      <a href="${raiz}/coordinador/ideas_pendientes.jsp">Ideas pendientes</a>
      <a href="${raiz}/coordinador/asignar_director.jsp">Asignar director</a>
      <a href="${raiz}/coordinador/revisiones.jsp">Revisiones</a>
      <a href="${raiz}/coordinador/informes.jsp">Informes</a>
    </c:when>
    <c:when test="${sessionScope.rol == 'Director'}">
      <a href="${raiz}/director/ideas.jsp">Mis ideas</a>
      <a href="${raiz}/director/anteproyectos.jsp">Anteproyectos</a>
    </c:when>
    <c:when test="${sessionScope.rol == 'Evaluador'}">
      <a href="${raiz}/evaluador/anteproyectos.jsp">Anteproyectos</a>
      <a href="${raiz}/evaluador/turnitin.jsp">Turnitin</a>
      <a href="${raiz}/evaluador/rejilla.jsp">Rejilla</a>
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
