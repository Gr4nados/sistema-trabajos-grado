<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Evaluador" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<c:set var="titulo" value="Inicio" />
<%@ include file="/includes/cabecera.jsp" %>

<sql:query var="n" dataSource="${bd}">
  SELECT
    (SELECT COUNT(*) FROM proyecto p
      WHERE p.id_evaluador = ? AND p.fase IN (3, 5) AND p.estado = 'En revisión') AS por_evaluar,
    (SELECT COUNT(*) FROM proyecto p
      WHERE p.id_evaluador = ? AND p.fase IN (3, 5) AND p.estado = 'Aprobado') AS espera_coordinador,
    (SELECT COUNT(*) FROM proyecto WHERE id_evaluador = ?) AS a_cargo
  <sql:param value="${sessionScope.idUsuario}" />
  <sql:param value="${sessionScope.idUsuario}" />
  <sql:param value="${sessionScope.idUsuario}" />
</sql:query>
<c:set var="d" value="${n.rows[0]}" />

<section class="tarjeta">
  <h1>Bienvenido, <c:out value="${sessionScope.nombreCompleto}" /></h1>
  <p class="suave">Aquí evalúas los anteproyectos que el director ya aprobó.</p>
</section>

<div class="tablero">
  <a class="dato" href="anteproyectos.jsp"><span class="num"><c:out value="${d.por_evaluar}" /></span><span class="rot">Documentos por evaluar</span></a>
  <a class="dato morado" href="anteproyectos.jsp"><span class="num"><c:out value="${d.espera_coordinador}" /></span><span class="rot">Aprobados, esperan al coordinador</span></a>
  <a class="dato verde" href="anteproyectos.jsp"><span class="num"><c:out value="${d.a_cargo}" /></span><span class="rot">Proyectos a mi cargo</span></a>
</div>

<%@ include file="/includes/recordatorios.jsp" %>
<%@ include file="/includes/pie.jsp" %>
