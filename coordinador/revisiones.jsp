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
  RF-12 (fases 3 y 5): despues del evaluador, el coordinador acepta o rechaza el proyecto.
  Un proyecto espera aqui cuando esta en la fase 3 o 5 con estado "Aprobado" (aprobado por el
  evaluador). Aceptar avanza la fase (la 5 pasa a la 6 = proceso finalizado). Rechazar deja el
  proyecto en la misma fase para que el estudiante corrija. La decision queda en revision.
--%>
<c:if test="${pageContext.request.method == 'POST'}">
  <sql:query var="objetivo" dataSource="${bd}">
    SELECT id_proyecto, fase FROM proyecto
    WHERE id_proyecto = ? AND fase IN (3, 5) AND estado = 'Aprobado'
    <sql:param value="${param.id}" />
  </sql:query>
  <c:set var="motivo" value="${fn:trim(param.motivo)}" />
  <c:choose>
    <c:when test="${objetivo.rowCount == 0}">
      <c:set var="mensaje" value="Ese proyecto ya no está pendiente de aceptación." scope="session" />
      <c:set var="mensajeTipo" value="error" scope="session" />
      <c:redirect url="/coordinador/revisiones.jsp" />
    </c:when>
    <c:when test="${param.decision == 'rechazar' && empty motivo}">
      <c:set var="error" value="Para rechazar debes escribir el motivo." />
      <c:set var="idConError" value="${param.id}" />
    </c:when>
    <c:when test="${param.decision == 'aceptar' || param.decision == 'rechazar'}">
      <c:set var="aceptar" value="${param.decision == 'aceptar'}" />
      <c:set var="idProyecto" value="${objetivo.rows[0].id_proyecto}" />
      <c:set var="faseActual" value="${objetivo.rows[0].fase}" />
      <c:catch var="fallo">
        <sql:transaction dataSource="${bd}">
          <sql:update>
            INSERT INTO revision (id_proyecto, fase, id_revisor, rol_revisor, resultado, comentario)
            VALUES (?, ?, ?, 'Coordinador', ?, NULLIF(?, ''))
            <sql:param value="${idProyecto}" />
            <sql:param value="${faseActual}" />
            <sql:param value="${sessionScope.idUsuario}" />
            <sql:param value="${aceptar ? 'Aprobado' : 'Rechazado'}" />
            <sql:param value="${motivo}" />
          </sql:update>
          <c:choose>
            <c:when test="${aceptar}">
              <sql:update>
                UPDATE proyecto SET estado = IF(fase + 1 = 6, 'Aprobado', 'En revisión'), fase = fase + 1
                WHERE id_proyecto = ?
                <sql:param value="${idProyecto}" />
              </sql:update>
            </c:when>
            <c:otherwise>
              <sql:update>
                UPDATE proyecto SET estado = 'Rechazado' WHERE id_proyecto = ?
                <sql:param value="${idProyecto}" />
              </sql:update>
            </c:otherwise>
          </c:choose>
          <sql:update>
            UPDATE recordatorio SET vigente = FALSE WHERE id_proyecto = ? AND tipo = 'Sin revisar'
            <sql:param value="${idProyecto}" />
          </sql:update>
        </sql:transaction>
      </c:catch>
      <c:choose>
        <c:when test="${empty fallo}">
          <c:set var="mensaje" value="${aceptar ? 'Proyecto aceptado: avanzó de fase.' : 'Proyecto rechazado: el estudiante podrá corregir.'}" scope="session" />
          <c:redirect url="/coordinador/revisiones.jsp" />
        </c:when>
        <c:otherwise>
          <c:set var="error" value="No se pudo guardar la decisión: ${fallo.message}" />
          <c:set var="idConError" value="${param.id}" />
        </c:otherwise>
      </c:choose>
    </c:when>
  </c:choose>
</c:if>

<sql:query var="pendientes" dataSource="${bd}">
  SELECT p.id_proyecto, p.fase, a.titulo,
         (SELECT GROUP_CONCAT(CONCAT(u.nombres, ' ', u.apellidos) SEPARATOR ', ')
            FROM integrante i JOIN usuario u ON u.id_usuario = i.id_usuario
           WHERE i.id_proyecto = p.id_proyecto) AS estudiantes,
         d.version, d.url,
         (SELECT r.calificacion FROM revision r WHERE r.id_proyecto = p.id_proyecto
            AND r.rol_revisor = 'Director' AND r.fase = p.fase - 1 ORDER BY r.id_revision DESC LIMIT 1) AS nota_director,
         (SELECT r.calificacion FROM revision r WHERE r.id_proyecto = p.id_proyecto
            AND r.rol_revisor = 'Evaluador' AND r.fase = p.fase ORDER BY r.id_revision DESC LIMIT 1) AS nota_evaluador,
         (SELECT r.comentario FROM revision r WHERE r.id_proyecto = p.id_proyecto
            AND r.rol_revisor = 'Evaluador' AND r.fase = p.fase ORDER BY r.id_revision DESC LIMIT 1) AS comentario_evaluador
  FROM proyecto p
  LEFT JOIN idea a ON a.id_idea = p.id_idea
  LEFT JOIN documento d ON d.id_proyecto = p.id_proyecto AND d.tipo = IF(p.fase = 3, 'Anteproyecto', 'Otro')
   AND d.version = (SELECT MAX(d2.version) FROM documento d2 WHERE d2.id_proyecto = p.id_proyecto AND d2.tipo = d.tipo)
  WHERE p.fase IN (3, 5) AND p.estado = 'Aprobado'
  ORDER BY p.id_proyecto
</sql:query>

<c:set var="titulo" value="Revisiones" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Revisiones pendientes (fases 3 y 5)</h1>
  <p class="suave">Proyectos aprobados por el evaluador que esperan tu aceptación.</p>
  <c:if test="${not empty error}"><p class="error"><c:out value="${error}" /></p></c:if>
  <c:if test="${pendientes.rowCount == 0}"><p class="suave">No hay proyectos pendientes de aceptación.</p></c:if>
</section>

<c:forEach var="f" items="${pendientes.rows}">
  <section class="tarjeta">
    <h2>Proyecto #<c:out value="${f.id_proyecto}" /> - <c:out value="${f.titulo}" /></h2>
    <table>
      <tr><th>Estudiante(s)</th><td><c:out value="${f.estudiantes}" /></td></tr>
      <tr><th>Fase</th><td><c:out value="${f.fase}" /> de 6</td></tr>
      <tr><th>Documento</th>
          <td>Versión <c:out value="${f.version}" /> ·
              <a href="<c:out value='${f.url}' />" target="_blank" rel="noopener"><c:out value="${f.url}" /></a></td></tr>
      <tr><th>Calificación del director</th><td><c:out value="${empty f.nota_director ? '-' : f.nota_director}" /></td></tr>
      <tr><th>Calificación del evaluador</th>
          <td><c:out value="${empty f.nota_evaluador ? '-' : f.nota_evaluador}" />
              <c:if test="${not empty f.comentario_evaluador}"> · <c:out value="${f.comentario_evaluador}" /></c:if></td></tr>
    </table>
    <form method="post" action="revisiones.jsp" class="decision">
      <input type="hidden" name="id" value="${f.id_proyecto}">
      <label for="motivo${f.id_proyecto}">Motivo (obligatorio para rechazar)</label>
      <textarea id="motivo${f.id_proyecto}" name="motivo" rows="2"><c:out value="${idConError == f.id_proyecto ? param.motivo : ''}" /></textarea>
      <button type="submit" name="decision" value="aceptar">Aceptar</button>
      <button type="submit" name="decision" value="rechazar" class="peligro">Rechazar</button>
    </form>
  </section>
</c:forEach>

<%@ include file="/includes/pie.jsp" %>
