<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Administrador" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%-- RF-03: lista de usuarios con filtro por rol, y acceso a editar / eliminar. --%>
<c:set var="filtro" value="${empty param.rol ? '' : param.rol}" />

<sql:query var="roles" dataSource="${bd}">SELECT nombre FROM rol ORDER BY id_rol</sql:query>
<sql:query var="lista" dataSource="${bd}">
  SELECT u.id_usuario, u.documento, u.codigo, u.nombres, u.apellidos, u.usuario,
         IF(u.activo, 1, 0) AS activo,
         (SELECT GROUP_CONCAT(r.nombre ORDER BY r.id_rol SEPARATOR ', ')
            FROM usuario_rol ur JOIN rol r ON r.id_rol = ur.id_rol
           WHERE ur.id_usuario = u.id_usuario) AS roles
  FROM usuario u
  WHERE ? = ''
     OR EXISTS (SELECT 1 FROM usuario_rol ur2 JOIN rol r2 ON r2.id_rol = ur2.id_rol
                 WHERE ur2.id_usuario = u.id_usuario AND r2.nombre = ?)
  ORDER BY u.apellidos, u.nombres
  <sql:param value="${filtro}" />
  <sql:param value="${filtro}" />
</sql:query>

<c:set var="titulo" value="Usuarios" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <div class="barra">
    <h1>Usuarios</h1>
    <a class="boton" href="usuario_nuevo.jsp"><svg class="ico"><use href="#i-mas"/></svg>Registrar usuario</a>
  </div>

  <form method="get" action="usuarios.jsp" class="filtros">
    <label for="rol">Filtrar por rol</label>
    <select id="rol" name="rol" onchange="this.form.submit()">
      <option value="">Todos</option>
      <c:forEach var="r" items="${roles.rows}">
        <option value="${r.nombre}" ${r.nombre == filtro ? 'selected' : ''}><c:out value="${r.nombre}" /></option>
      </c:forEach>
    </select>
    <noscript><button type="submit">Filtrar</button></noscript>
  </form>

  <c:choose>
    <c:when test="${lista.rowCount == 0}">
      <p class="suave">No hay usuarios para mostrar.</p>
    </c:when>
    <c:otherwise>
      <table>
        <thead>
          <tr><th>Documento</th><th>Código</th><th>Nombre</th><th>Usuario</th><th>Roles</th><th>Estado</th><th>Acciones</th></tr>
        </thead>
        <tbody>
          <c:forEach var="f" items="${lista.rows}">
            <tr>
              <td><c:out value="${f.documento}" /></td>
              <td><c:out value="${f.codigo}" /></td>
              <td><c:out value="${f.apellidos}, ${f.nombres}" /></td>
              <td><c:out value="${f.usuario}" /></td>
              <td><c:out value="${f.roles}" /></td>
              <td><c:set var="valorInsignia" value="${f.activo == 1 ? 'Activo' : 'Inactivo'}" /><%@ include file="/includes/insignia.jsp" %></td>
              <td class="acciones">
                <a class="boton pequeno contorno" href="usuario_editar.jsp?id=${f.id_usuario}"><svg class="ico"><use href="#i-editar"/></svg>Editar</a>
                <c:if test="${f.id_usuario != sessionScope.idUsuario}">
                  <form method="post" action="usuario_eliminar.jsp"
                        onsubmit="return confirm('¿Eliminar este usuario?');">
                    <input type="hidden" name="id" value="${f.id_usuario}">
                    <button type="submit" class="peligro"><svg class="ico"><use href="#i-papelera"/></svg>Eliminar</button>
                  </form>
                </c:if>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/includes/pie.jsp" %>
