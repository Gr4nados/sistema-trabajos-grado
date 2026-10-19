<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<%-- RF-27: enlaces de la universidad, en una sola pagina para todos los roles (tabla enlace). --%>
<c:if test="${empty sessionScope.idUsuario}"><c:redirect url="/login.jsp" /></c:if>
<%@ include file="/includes/conexion.jsp" %>
<sql:query var="enlaces" dataSource="${bd}">SELECT nombre, url FROM enlace ORDER BY id_enlace</sql:query>

<c:set var="titulo" value="Enlaces de la universidad" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Enlaces de la universidad</h1>
  <p class="suave">Se abren en una pestaña nueva.</p>
</section>

<div class="enlaces">
  <c:forEach var="e" items="${enlaces.rows}">
    <c:choose>
      <c:when test="${e.nombre == 'Calendario académico'}"><c:set var="iconoEnlace" value="calendario" /></c:when>
      <c:when test="${e.nombre == 'Valores pecuniarios'}"><c:set var="iconoEnlace" value="pago" /></c:when>
      <c:when test="${e.nombre == 'Formatos de grado' || e.nombre == 'Base documental'}"><c:set var="iconoEnlace" value="doc" /></c:when>
      <c:when test="${e.nombre == 'Reglamento de trabajos de grado' || e.nombre == 'Reglamento estudiantil'}"><c:set var="iconoEnlace" value="escudo" /></c:when>
      <c:otherwise><c:set var="iconoEnlace" value="externo" /></c:otherwise>
    </c:choose>
    <a class="enlace-tarjeta" href="<c:out value='${e.url}' />" target="_blank" rel="noopener">
      <svg class="ico-grande"><use href="#i-${iconoEnlace}"/></svg>
      <strong><c:out value="${e.nombre}" /></strong>
      <span class="abrir">Abrir <svg class="ico"><use href="#i-externo"/></svg></span>
    </a>
  </c:forEach>
</div>

<%@ include file="/includes/pie.jsp" %>
