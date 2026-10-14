<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Estudiante" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<c:set var="titulo" value="Inicio" />
<%@ include file="/includes/cabecera.jsp" %>

<%-- La vista nunca incluye al evaluador (RNF-06) --%>
<sql:query var="proy" dataSource="${bd}">
  SELECT * FROM vista_proyecto_estudiante
  WHERE id_estudiante = ? ORDER BY id_proyecto DESC LIMIT 1
  <sql:param value="${sessionScope.idUsuario}" />
</sql:query>

<section class="tarjeta">
  <h1>Bienvenido, <c:out value="${sessionScope.nombreCompleto}" /></h1>
</section>

<section class="tarjeta">
  <h2>Estado de tu proyecto</h2>
  <c:choose>
    <c:when test="${proy.rowCount == 0}">
      <p class="suave">Aún no tienes un proyecto.</p>
    </c:when>
    <c:otherwise>
      <c:set var="p" value="${proy.rows[0]}" />
      <table>
        <tr><th>Modalidad</th><td><c:out value="${p.modalidad}" /></td></tr>
        <tr><th>Idea</th><td><c:out value="${empty p.idea_titulo ? 'Sin asignar' : p.idea_titulo}" /></td></tr>
        <tr><th>Fase</th><td><c:out value="${p.fase}" /> de 6</td></tr>
        <tr><th>Estado</th><td><c:out value="${p.estado}" /></td></tr>
        <tr><th>Director</th><td>
          <c:choose>
            <c:when test="${empty p.director_nombres}">Sin asignar</c:when>
            <c:otherwise><c:out value="${p.director_nombres} ${p.director_apellidos}" /></c:otherwise>
          </c:choose>
        </td></tr>
        <c:if test="${not empty p.fecha_limite}">
          <tr><th>Fecha límite</th><td><c:out value="${p.fecha_limite}" /></td></tr>
        </c:if>
      </table>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/includes/recordatorios.jsp" %>
<%@ include file="/includes/pie.jsp" %>
