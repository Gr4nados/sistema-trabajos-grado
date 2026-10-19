<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Coordinador" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<c:set var="titulo" value="Inicio" />
<%@ include file="/includes/cabecera.jsp" %>

<sql:query var="n" dataSource="${bd}">
  SELECT
    (SELECT COUNT(*) FROM proyecto WHERE fase = 1 AND id_idea IS NOT NULL) AS ideas,
    (SELECT COUNT(*) FROM idea WHERE disponibilidad = 'Pendiente') AS ideas_docentes,
    (SELECT COUNT(*) FROM proyecto WHERE fase >= 2 AND id_director IS NULL) AS sin_director,
    (SELECT COUNT(*) FROM proyecto WHERE fase = 5 AND estado = 'Aprobado') AS revisiones,
    (SELECT COUNT(*) FROM proyecto WHERE fase = 6 AND sustentacion_fecha IS NULL) AS sustentaciones,
    (SELECT COUNT(*) FROM proyecto WHERE papeles_solicitados = TRUE) AS papeles
</sql:query>
<c:set var="d" value="${n.rows[0]}" />

<section class="tarjeta">
  <h1>Bienvenido, <c:out value="${sessionScope.nombreCompleto}" /></h1>
  <p class="suave">Esto es lo que necesita tu atención hoy.</p>
</section>

<div class="tablero">
  <a class="dato" href="banco_ideas.jsp"><svg class="ico"><use href="#i-ideas"/></svg><span class="num"><c:out value="${d.ideas_docentes}" /></span><span class="rot">Ideas de docentes por revisar</span></a>
  <a class="dato" href="ideas_pendientes.jsp"><svg class="ico"><use href="#i-proyecto"/></svg><span class="num"><c:out value="${d.ideas}" /></span><span class="rot">Ideas de proyectos por asignar</span></a>
  <a class="dato morado" href="asignar_director.jsp"><svg class="ico"><use href="#i-asignar"/></svg><span class="num"><c:out value="${d.sin_director}" /></span><span class="rot">Proyectos sin director</span></a>
  <a class="dato verde" href="revisiones.jsp"><svg class="ico"><use href="#i-revisar"/></svg><span class="num"><c:out value="${d.revisiones}" /></span><span class="rot">Informes por aprobar (fase 5)</span></a>
  <a class="dato morado" href="sustentaciones.jsp"><svg class="ico"><use href="#i-birrete"/></svg><span class="num"><c:out value="${d.sustentaciones}" /></span><span class="rot">Sustentaciones por programar</span></a>
  <a class="dato" href="informes.jsp"><svg class="ico"><use href="#i-doc"/></svg><span class="num"><c:out value="${d.papeles}" /></span><span class="rot">Papeles de grado solicitados</span></a>
</div>

<%@ include file="/includes/recordatorios.jsp" %>
<%@ include file="/includes/pie.jsp" %>
