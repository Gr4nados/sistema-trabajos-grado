<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Director" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<c:set var="titulo" value="Inicio" />
<%@ include file="/includes/cabecera.jsp" %>

<sql:query var="n" dataSource="${bd}">
  SELECT
    (SELECT COUNT(*) FROM proyecto p
      WHERE p.id_director = ? AND p.fase IN (2, 4) AND p.estado = 'En revisión'
        AND EXISTS (SELECT 1 FROM documento d WHERE d.id_proyecto = p.id_proyecto
                     AND d.tipo = IF(p.fase = 2, 'Anteproyecto', 'Informe'))) AS por_revisar,
    (SELECT COUNT(*) FROM proyecto WHERE id_director = ?) AS a_cargo,
    (SELECT COUNT(*) FROM idea WHERE id_proponente = ?) AS ideas
  <sql:param value="${sessionScope.idUsuario}" />
  <sql:param value="${sessionScope.idUsuario}" />
  <sql:param value="${sessionScope.idUsuario}" />
</sql:query>
<c:set var="d" value="${n.rows[0]}" />

<section class="tarjeta">
  <h1>Bienvenido, <c:out value="${sessionScope.nombreCompleto}" /></h1>
  <p class="suave">Aquí publicas ideas y revisas los anteproyectos a tu cargo.</p>
</section>

<div class="tablero">
  <a class="dato" href="anteproyectos.jsp"><svg class="ico"><use href="#i-doc"/></svg><span class="num"><c:out value="${d.por_revisar}" /></span><span class="rot">Documentos por revisar</span></a>
  <a class="dato morado" href="anteproyectos.jsp"><svg class="ico"><use href="#i-proyecto"/></svg><span class="num"><c:out value="${d.a_cargo}" /></span><span class="rot">Proyectos a mi cargo</span></a>
  <a class="dato verde" href="ideas.jsp"><svg class="ico"><use href="#i-ideas"/></svg><span class="num"><c:out value="${d.ideas}" /></span><span class="rot">Ideas publicadas</span></a>
</div>

<%@ include file="/includes/recordatorios.jsp" %>
<%@ include file="/includes/pie.jsp" %>
