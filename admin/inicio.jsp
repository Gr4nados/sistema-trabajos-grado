<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Administrador" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<c:set var="titulo" value="Inicio" />
<%@ include file="/includes/cabecera.jsp" %>

<sql:query var="porRol" dataSource="${bd}">
  SELECT r.nombre, COUNT(u.id_usuario) AS n
  FROM rol r
  LEFT JOIN usuario_rol ur ON ur.id_rol = r.id_rol
  LEFT JOIN usuario u ON u.id_usuario = ur.id_usuario AND u.activo = TRUE
  GROUP BY r.id_rol, r.nombre ORDER BY r.id_rol
</sql:query>

<section class="tarjeta">
  <h1>Bienvenido, <c:out value="${sessionScope.nombreCompleto}" /></h1>
  <p class="suave">Aquí registras y gestionas los usuarios del sistema. Usuarios activos por rol:</p>
</section>

<div class="tablero">
  <c:forEach var="r" items="${porRol.rows}" varStatus="v">
    <a class="dato ${v.index % 3 == 1 ? 'morado' : (v.index % 3 == 2 ? 'verde' : '')}"
       href="usuarios.jsp?rol=<c:out value='${r.nombre}' />">
      <span class="num"><c:out value="${r.n}" /></span><span class="rot"><c:out value="${r.nombre}" /></span>
    </a>
  </c:forEach>
</div>

<%@ include file="/includes/recordatorios.jsp" %>
<%@ include file="/includes/pie.jsp" %>
