<%--
  menu.jsp - Menu lateral independiente por rol (RF-04). Requiere la fuente de datos "bd".
  Lo incluye cabecera.jsp dentro de <aside class="lateral">.
  Solo se listan las paginas que ya existen; se agregan al avanzar.
  "ruta" es la pagina actual y sirve para resaltar el enlace activo.
--%>
<c:set var="raiz" value="${pageContext.request.contextPath}" />
<c:set var="ruta" value="${pageContext.request.servletPath}" />
<sql:query var="enlaces" dataSource="${bd}">SELECT nombre, url FROM enlace ORDER BY id_enlace</sql:query>

<a class="marca" href="${raiz}/index.jsp">
  <span class="marca-logo">TG</span>
  <span><strong>Trabajos de Grado</strong><small>${sessionScope.rol}</small></span>
</a>

<nav>
  <a href="${raiz}/index.jsp" class="${ruta.endsWith('/inicio.jsp') ? 'activo' : ''}"><svg class="ico"><use href="#i-inicio"/></svg><span>Inicio</span></a>

  <c:choose>
    <c:when test="${sessionScope.rol == 'Administrador'}">
      <p class="grupo">Gestión</p>
      <a href="${raiz}/admin/usuarios.jsp" class="${ruta.startsWith('/admin/usuario') ? 'activo' : ''}"><svg class="ico"><use href="#i-usuarios"/></svg><span>Usuarios</span></a>
    </c:when>

    <c:when test="${sessionScope.rol == 'Estudiante'}">
      <p class="grupo">Ideas</p>
      <a href="${raiz}/estudiante/banco_ideas.jsp" class="${ruta == '/estudiante/banco_ideas.jsp' || ruta == '/estudiante/idea_nueva.jsp' ? 'activo' : ''}"><svg class="ico"><use href="#i-ideas"/></svg><span>Banco de ideas</span></a>
      <p class="grupo">Mi proyecto</p>
      <a href="${raiz}/estudiante/proyecto_nuevo.jsp" class="${ruta == '/estudiante/proyecto_nuevo.jsp' ? 'activo' : ''}"><svg class="ico"><use href="#i-proyecto"/></svg><span>Nuevo proyecto</span></a>
      <a href="${raiz}/estudiante/asignar_idea.jsp" class="${ruta == '/estudiante/asignar_idea.jsp' ? 'activo' : ''}"><svg class="ico"><use href="#i-asignar"/></svg><span>Asignar idea</span></a>
      <a href="${raiz}/estudiante/documentos.jsp" class="${ruta == '/estudiante/documentos.jsp' || ruta == '/estudiante/versiones.jsp' ? 'activo' : ''}"><svg class="ico"><use href="#i-doc"/></svg><span>Documentos</span></a>
      <a href="${raiz}/estudiante/calificaciones.jsp" class="${ruta == '/estudiante/calificaciones.jsp' ? 'activo' : ''}"><svg class="ico"><use href="#i-estrella"/></svg><span>Calificaciones</span></a>
    </c:when>

    <c:when test="${sessionScope.rol == 'Coordinador'}">
      <p class="grupo">Proyectos</p>
      <a href="${raiz}/coordinador/banco_ideas.jsp" class="${ruta == '/coordinador/banco_ideas.jsp' || ruta == '/coordinador/idea_editar.jsp' ? 'activo' : ''}"><svg class="ico"><use href="#i-ideas"/></svg><span>Banco de ideas</span></a>
      <a href="${raiz}/coordinador/ideas_pendientes.jsp" class="${ruta == '/coordinador/ideas_pendientes.jsp' ? 'activo' : ''}"><svg class="ico"><use href="#i-proyecto"/></svg><span>Ideas por asignar</span></a>
      <a href="${raiz}/coordinador/asignar_director.jsp" class="${ruta == '/coordinador/asignar_director.jsp' ? 'activo' : ''}"><svg class="ico"><use href="#i-asignar"/></svg><span>Asignar director</span></a>
      <a href="${raiz}/coordinador/revisiones.jsp" class="${ruta == '/coordinador/revisiones.jsp' ? 'activo' : ''}"><svg class="ico"><use href="#i-revisar"/></svg><span>Revisiones</span></a>
      <p class="grupo">Consulta</p>
      <a href="${raiz}/coordinador/buscar.jsp" class="${ruta == '/coordinador/buscar.jsp' ? 'activo' : ''}"><svg class="ico"><use href="#i-buscar"/></svg><span>Buscar estudiante</span></a>
      <a href="${raiz}/coordinador/informes.jsp" class="${ruta == '/coordinador/informes.jsp' ? 'activo' : ''}"><svg class="ico"><use href="#i-informe"/></svg><span>Informes</span></a>
    </c:when>

    <c:when test="${sessionScope.rol == 'Director'}">
      <p class="grupo">Trabajo</p>
      <a href="${raiz}/director/anteproyectos.jsp" class="${ruta == '/director/anteproyectos.jsp' ? 'activo' : ''}"><svg class="ico"><use href="#i-doc"/></svg><span>Anteproyectos</span></a>
      <a href="${raiz}/director/ideas.jsp" class="${ruta == '/director/ideas.jsp' || ruta == '/director/idea_nueva.jsp' ? 'activo' : ''}"><svg class="ico"><use href="#i-ideas"/></svg><span>Mis ideas</span></a>
    </c:when>

    <c:when test="${sessionScope.rol == 'Evaluador'}">
      <p class="grupo">Evaluación</p>
      <a href="${raiz}/evaluador/anteproyectos.jsp" class="${ruta == '/evaluador/anteproyectos.jsp' ? 'activo' : ''}"><svg class="ico"><use href="#i-doc"/></svg><span>Anteproyectos</span></a>
      <a href="${raiz}/evaluador/turnitin.jsp" class="${ruta == '/evaluador/turnitin.jsp' ? 'activo' : ''}"><svg class="ico"><use href="#i-escudo"/></svg><span>Turnitin</span></a>
      <a href="${raiz}/evaluador/rejilla.jsp" class="${ruta == '/evaluador/rejilla.jsp' ? 'activo' : ''}"><svg class="ico"><use href="#i-rejilla"/></svg><span>Rejilla</span></a>
    </c:when>
  </c:choose>

  <p class="grupo">Cuenta</p>
  <a href="${raiz}/perfil.jsp" class="${ruta == '/perfil.jsp' ? 'activo' : ''}"><svg class="ico"><use href="#i-persona"/></svg><span>Mi perfil</span></a>

  <p class="grupo">Universidad</p>
  <c:forEach var="e" items="${enlaces.rows}">
    <a href="<c:out value='${e.url}' />" target="_blank" rel="noopener"><svg class="ico"><use href="#i-externo"/></svg><span><c:out value="${e.nombre}" /></span></a>
  </c:forEach>
</nav>

<div class="usuario">
  <div class="quien">
    <span class="avatar"><svg class="ico"><use href="#i-persona"/></svg></span>
    <span><strong><c:out value="${sessionScope.nombreCompleto}" /></strong><small><c:out value="${sessionScope.rol}" /></small></span>
  </div>
  <div class="acciones-sesion">
    <c:if test="${sessionScope.cantidadRoles > 1}">
      <a href="${raiz}/elegir_rol.jsp"><svg class="ico"><use href="#i-cambiar"/></svg>Cambiar rol</a>
    </c:if>
    <a href="${raiz}/logout.jsp"><svg class="ico"><use href="#i-salir"/></svg>Salir</a>
  </div>
</div>
