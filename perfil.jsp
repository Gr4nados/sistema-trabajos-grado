<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<%-- Mi perfil: lo ve cualquier usuario con sesion (no exige un rol concreto). --%>
<c:if test="${empty sessionScope.idUsuario}"><c:redirect url="/login.jsp" /></c:if>
<%@ include file="/includes/conexion.jsp" %>
<sql:query var="res" dataSource="${bd}">
  SELECT documento, codigo, nombres, apellidos, usuario, IF(activo, 1, 0) AS activo, creado_en,
         (SELECT GROUP_CONCAT(r.nombre ORDER BY r.id_rol SEPARATOR ', ')
            FROM usuario_rol ur JOIN rol r ON r.id_rol = ur.id_rol
           WHERE ur.id_usuario = u.id_usuario) AS roles
  FROM usuario u WHERE u.id_usuario = ?
  <sql:param value="${sessionScope.idUsuario}" />
</sql:query>
<c:set var="u" value="${res.rows[0]}" />

<c:set var="titulo" value="Mi perfil" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1><c:out value="${u.nombres} ${u.apellidos}" /></h1>
  <p class="suave">Estos son tus datos en el sistema. Si alguno es incorrecto, pide al administrador que lo corrija.</p>
  <table>
    <tr><th>Nombres</th><td><c:out value="${u.nombres}" /></td></tr>
    <tr><th>Apellidos</th><td><c:out value="${u.apellidos}" /></td></tr>
    <tr><th>Documento</th><td><c:out value="${u.documento}" /></td></tr>
    <c:if test="${not empty u.codigo}"><tr><th>Código estudiantil</th><td><c:out value="${u.codigo}" /></td></tr></c:if>
    <tr><th>Usuario</th><td><c:out value="${u.usuario}" /></td></tr>
    <tr><th>Roles</th><td><c:out value="${u.roles}" /></td></tr>
    <tr><th>Rol activo en esta sesión</th><td><c:out value="${sessionScope.rol}" /></td></tr>
    <tr><th>Estado</th><td><c:set var="valorInsignia" value="${u.activo == 1 ? 'Activo' : 'Inactivo'}" /><%@ include file="/includes/insignia.jsp" %></td></tr>
    <tr><th>Registrado</th><td><c:out value="${u.creado_en}" /></td></tr>
  </table>
</section>

<%@ include file="/includes/pie.jsp" %>
