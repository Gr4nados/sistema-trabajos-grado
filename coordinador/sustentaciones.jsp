<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Coordinador" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%--
  Fase 6 (Fase final): con todas las aprobaciones, se define la fecha de la sustentacion.
  Estudiante(s), director y evaluador la "programan"; aqui la registra el coordinador (supuesto,
  PENDIENTES.md #27) y les llega un aviso a los tres.
--%>
<c:if test="${pageContext.request.method == 'POST'}">
  <c:set var="lugar" value="${fn:trim(param.lugar)}" />
  <c:set var="fechaSql" value="${fn:replace(fn:trim(param.fecha), 'T', ' ')}:00" />
  <sql:query var="objetivo" dataSource="${bd}">
    SELECT id_proyecto FROM proyecto WHERE id_proyecto = ? AND fase = 6
    <sql:param value="${param.id}" />
  </sql:query>
  <c:choose>
    <c:when test="${objetivo.rowCount == 0}">
      <c:set var="mensaje" value="Ese proyecto no está en la fase final." scope="session" />
      <c:set var="mensajeTipo" value="error" scope="session" />
      <c:redirect url="/coordinador/sustentaciones.jsp" />
    </c:when>
    <c:when test="${empty fn:trim(param.fecha)}">
      <c:set var="error" value="Escribe la fecha y la hora de la sustentación." />
      <c:set var="idConError" value="${param.id}" />
    </c:when>
    <c:when test="${fn:length(lugar) > 120}">
      <c:set var="error" value="El lugar no puede superar 120 caracteres." />
      <c:set var="idConError" value="${param.id}" />
    </c:when>
    <c:otherwise>
      <c:catch var="fallo">
        <sql:transaction dataSource="${bd}">
          <sql:update>
            UPDATE proyecto SET sustentacion_fecha = ?, sustentacion_lugar = NULLIF(?, '') WHERE id_proyecto = ?
            <sql:param value="${fechaSql}" />
            <sql:param value="${lugar}" />
            <sql:param value="${param.id}" />
          </sql:update>
          <sql:update>
            UPDATE recordatorio SET vigente = FALSE WHERE id_proyecto = ? AND tipo = 'Sustentación'
            <sql:param value="${param.id}" />
          </sql:update>
          <%-- Aviso para cada estudiante, el director y el evaluador (RF-17) --%>
          <sql:update>
            INSERT INTO recordatorio (id_usuario, id_proyecto, tipo, mensaje)
            SELECT x.u, ?, 'Sustentación',
                   CONCAT('Proyecto ', ?, ': ', DATE_FORMAT(?, '%d/%m/%Y %H:%i'), IFNULL(CONCAT(' en ', NULLIF(?, '')), ''))
            FROM (SELECT id_usuario AS u FROM integrante WHERE id_proyecto = ?
                  UNION SELECT id_director FROM proyecto WHERE id_proyecto = ?
                  UNION SELECT id_evaluador FROM proyecto WHERE id_proyecto = ?) x
            WHERE x.u IS NOT NULL
            <sql:param value="${param.id}" />
            <sql:param value="${param.id}" />
            <sql:param value="${fechaSql}" />
            <sql:param value="${lugar}" />
            <sql:param value="${param.id}" />
            <sql:param value="${param.id}" />
            <sql:param value="${param.id}" />
          </sql:update>
        </sql:transaction>
      </c:catch>
      <c:choose>
        <c:when test="${empty fallo}">
          <c:set var="mensaje" value="Sustentación programada para el proyecto ${param.id}." scope="session" />
          <c:redirect url="/coordinador/sustentaciones.jsp" />
        </c:when>
        <c:otherwise>
          <c:set var="error" value="No se pudo programar. Revisa que la fecha y la hora sean válidas." />
          <c:set var="idConError" value="${param.id}" />
        </c:otherwise>
      </c:choose>
    </c:otherwise>
  </c:choose>
</c:if>

<sql:query var="proyectos" dataSource="${bd}">
  SELECT p.id_proyecto, p.radicado, p.sustentacion_fecha, p.sustentacion_lugar,
         DATE_FORMAT(p.sustentacion_fecha, '%Y-%m-%dT%H:%i') AS fecha_input,
         a.titulo,
         (SELECT GROUP_CONCAT(CONCAT(u.nombres, ' ', u.apellidos) SEPARATOR ', ')
            FROM integrante i JOIN usuario u ON u.id_usuario = i.id_usuario
           WHERE i.id_proyecto = p.id_proyecto) AS estudiantes,
         CONCAT(d.nombres, ' ', d.apellidos) AS director,
         CONCAT(e.nombres, ' ', e.apellidos) AS evaluador
  FROM proyecto p
  LEFT JOIN idea a ON a.id_idea = p.id_idea
  LEFT JOIN usuario d ON d.id_usuario = p.id_director
  LEFT JOIN usuario e ON e.id_usuario = p.id_evaluador
  WHERE p.fase = 6 ORDER BY p.sustentacion_fecha IS NOT NULL, p.sustentacion_fecha, p.id_proyecto
</sql:query>

<c:set var="titulo" value="Sustentaciones" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Sustentaciones (fase final)</h1>
  <p class="suave">Proyectos con todas las aprobaciones. Al programar la fecha, estudiantes, director y evaluador reciben un aviso.</p>
  <c:if test="${not empty error}"><p class="error"><c:out value="${error}" /></p></c:if>
  <c:if test="${proyectos.rowCount == 0}"><p class="suave">Aún no hay proyectos en la fase final.</p></c:if>
</section>

<c:forEach var="f" items="${proyectos.rows}">
  <c:set var="conError" value="${idConError == f.id_proyecto}" />
  <section class="tarjeta">
    <h2>Proyecto #<c:out value="${f.id_proyecto}" /> - <c:out value="${f.titulo}" />
      <c:if test="${not empty f.radicado}"> <small class="suave">Rad. <c:out value="${f.radicado}" /></small></c:if></h2>
    <table>
      <tr><th>Estudiante(s)</th><td><c:out value="${f.estudiantes}" /></td></tr>
      <tr><th>Director</th><td><c:out value="${empty f.director ? '-' : f.director}" /></td></tr>
      <tr><th>Evaluador</th><td><c:out value="${empty f.evaluador ? '-' : f.evaluador}" /></td></tr>
      <tr><th>Sustentación</th>
          <td><c:choose>
            <c:when test="${empty f.sustentacion_fecha}"><span class="insignia medio">Por programar</span></c:when>
            <c:otherwise><span class="insignia ok">Programada</span>
              <fmt:formatDate value="${f.sustentacion_fecha}" pattern="dd/MM/yyyy HH:mm" />
              <c:if test="${not empty f.sustentacion_lugar}"> · <c:out value="${f.sustentacion_lugar}" /></c:if></c:otherwise>
          </c:choose></td></tr>
    </table>
    <form method="post" action="sustentaciones.jsp">
      <input type="hidden" name="id" value="${f.id_proyecto}">
      <label for="fecha${f.id_proyecto}">Fecha y hora *</label>
      <input type="datetime-local" id="fecha${f.id_proyecto}" name="fecha" required
             value="<c:out value='${conError ? param.fecha : f.fecha_input}' />">
      <label for="lugar${f.id_proyecto}">Lugar</label>
      <input type="text" id="lugar${f.id_proyecto}" name="lugar" maxlength="120" placeholder="Aula, sala virtual..."
             value="<c:out value='${conError ? param.lugar : f.sustentacion_lugar}' />">
      <button type="submit"><c:out value="${empty f.sustentacion_fecha ? 'Programar sustentación' : 'Actualizar sustentación'}" /></button>
    </form>
  </section>
</c:forEach>

<%@ include file="/includes/pie.jsp" %>
