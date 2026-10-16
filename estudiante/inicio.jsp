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
      <p class="suave">Aún no tienes un proyecto. <a href="proyecto_nuevo.jsp">Crear mi proyecto</a></p>
    </c:when>
    <c:otherwise>
      <c:set var="p" value="${proy.rows[0]}" />
      <%-- Indicador de las 6 fases; los nombres de 4 y 5 estan por definir (PENDIENTES.md #1) --%>
      <ol class="pasos">
        <c:forTokens var="nombreFase" items="Idea y recibo|Anteproyecto|Evaluación|Entrega 2|Evaluación 2|Finalizado" delims="|" varStatus="v">
          <li class="${v.count < p.fase ? 'hecho' : (v.count == p.fase ? 'actual' : '')}">
            <span class="punto"><c:choose><c:when test="${v.count < p.fase || p.fase == 6}">&#10003;</c:when><c:otherwise><c:out value="${v.count}" /></c:otherwise></c:choose></span>
            <c:out value="${nombreFase}" />
          </li>
        </c:forTokens>
      </ol>
      <table>
        <c:if test="${not empty p.radicado}"><tr><th>Radicado</th><td><c:out value="${p.radicado}" /></td></tr></c:if>
        <tr><th>Modalidad</th><td><c:out value="${p.modalidad}" /></td></tr>
        <tr><th>Idea</th><td><c:out value="${empty p.idea_titulo ? 'Sin asignar' : p.idea_titulo}" /></td></tr>
        <tr><th>Fase</th><td><c:out value="${p.fase}" /> de 6</td></tr>
        <tr><th>Estado</th><td><c:set var="valorInsignia" value="${p.estado}" /><%@ include file="/includes/insignia.jsp" %></td></tr>
        <tr><th>Director</th><td>
          <c:choose>
            <c:when test="${empty p.director_nombres}">Sin asignar</c:when>
            <c:otherwise><c:out value="${p.director_nombres} ${p.director_apellidos}" /></c:otherwise>
          </c:choose>
        </td></tr>
        <c:if test="${p.fase == 1 && empty p.idea_titulo}">
          <tr><th>Siguiente paso</th><td><a href="asignar_idea.jsp">Escoger idea y registrar el recibo de pago</a></td></tr>
        </c:if>
        <c:if test="${p.fase >= 2 && p.fase <= 5}">
          <tr><th>Siguiente paso</th><td>
            <c:choose>
              <c:when test="${empty p.director_nombres}">Esperar a que el coordinador asigne tu director</c:when>
              <c:when test="${p.estado == 'Rechazado' || p.estado == 'Aplazado'}">
                Te devolvieron el documento: revisa las <a href="calificaciones.jsp">calificaciones</a> y
                <a href="documentos.jsp">registra una nueva versión</a></c:when>
              <c:when test="${p.estado == 'Aprobado'}">Esperar la aceptación del coordinador</c:when>
              <c:when test="${p.fase == 2 || p.fase == 4}"><a href="documentos.jsp">Registrar o revisar la URL de tu documento</a></c:when>
              <c:otherwise>Tu documento está en evaluación</c:otherwise>
            </c:choose>
          </td></tr>
        </c:if>
        <c:if test="${not empty p.fecha_limite}">
          <tr><th>Fecha límite</th><td><c:out value="${p.fecha_limite}" /></td></tr>
        </c:if>
      </table>
      <c:if test="${p.fase == 6}">
        <%-- RF-14: papeles de grado (la vista no trae esta columna; no incluye al evaluador) --%>
        <sql:query var="papeles" dataSource="${bd}">
          SELECT papeles_solicitados FROM proyecto WHERE id_proyecto = ?
          <sql:param value="${p.id_proyecto}" />
        </sql:query>
        <c:choose>
          <c:when test="${papeles.rows[0].papeles_solicitados}">
            <p class="exito">Ya solicitaste tus papeles de grado.</p>
          </c:when>
          <c:otherwise>
            <p>¡Tu proceso finalizó!</p>
            <form method="post" action="solicitar_papeles.jsp">
              <button type="submit">Solicitar papeles de grado</button>
            </form>
          </c:otherwise>
        </c:choose>
      </c:if>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/includes/recordatorios.jsp" %>
<%@ include file="/includes/pie.jsp" %>
