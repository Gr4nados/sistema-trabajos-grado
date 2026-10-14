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
  RF-09 (fase 1): el coordinador ve la idea (indicando si viene del banco) y el recibo,
  y la asigna o la rechaza escribiendo el motivo.
  PENDIENTE (PENDIENTES.md #2): quien decide la fase 1 es un supuesto.
  - Asignar: la idea pasa a "Asignada" y el proyecto avanza a la fase 2.
  - Rechazar: se libera la idea del proyecto para que el estudiante escoja otra.
  Cada decision queda en la tabla revision (RNF-08).
--%>
<c:if test="${pageContext.request.method == 'POST'}">
  <sql:query var="objetivo" dataSource="${bd}">
    SELECT id_proyecto, id_idea FROM proyecto
    WHERE id_proyecto = ? AND fase = 1 AND id_idea IS NOT NULL
    <sql:param value="${param.id}" />
  </sql:query>
  <c:set var="motivo" value="${fn:trim(param.motivo)}" />
  <c:choose>
    <c:when test="${objetivo.rowCount == 0}">
      <c:set var="mensaje" value="Ese proyecto ya no está pendiente de revisión." scope="session" />
      <c:set var="mensajeTipo" value="error" scope="session" />
      <c:redirect url="/coordinador/ideas_pendientes.jsp" />
    </c:when>
    <c:when test="${param.decision == 'rechazar' && empty motivo}">
      <c:set var="error" value="Para rechazar debes escribir el motivo." />
      <c:set var="idConError" value="${param.id}" />
    </c:when>
    <c:when test="${param.decision == 'asignar' || param.decision == 'rechazar'}">
      <c:set var="asignar" value="${param.decision == 'asignar'}" />
      <c:set var="idProyecto" value="${objetivo.rows[0].id_proyecto}" />
      <c:set var="idIdea" value="${objetivo.rows[0].id_idea}" />
      <c:catch var="fallo">
        <sql:transaction dataSource="${bd}">
          <c:choose>
            <c:when test="${asignar}">
              <sql:update>
                UPDATE idea SET disponibilidad = 'Asignada' WHERE id_idea = ?
                <sql:param value="${idIdea}" />
              </sql:update>
              <sql:update>
                UPDATE proyecto SET fase = 2 WHERE id_proyecto = ?
                <sql:param value="${idProyecto}" />
              </sql:update>
            </c:when>
            <c:otherwise>
              <sql:update>
                UPDATE proyecto SET id_idea = NULL WHERE id_proyecto = ?
                <sql:param value="${idProyecto}" />
              </sql:update>
            </c:otherwise>
          </c:choose>
          <sql:update>
            INSERT INTO revision (id_proyecto, fase, id_revisor, rol_revisor, resultado, comentario)
            VALUES (?, 1, ?, 'Coordinador', ?, NULLIF(?, ''))
            <sql:param value="${idProyecto}" />
            <sql:param value="${sessionScope.idUsuario}" />
            <sql:param value="${asignar ? 'Aprobado' : 'Rechazado'}" />
            <sql:param value="${motivo}" />
          </sql:update>
          <sql:update>
            UPDATE recordatorio SET vigente = FALSE
            WHERE id_proyecto = ? AND tipo = 'Sin revisar'
            <sql:param value="${idProyecto}" />
          </sql:update>
        </sql:transaction>
      </c:catch>
      <c:choose>
        <c:when test="${empty fallo}">
          <c:set var="mensaje" value="${asignar ? 'Idea asignada: el proyecto avanzó a la fase 2.' : 'Idea rechazada: el estudiante podrá escoger otra.'}" scope="session" />
          <c:redirect url="/coordinador/ideas_pendientes.jsp" />
        </c:when>
        <c:otherwise>
          <c:set var="error" value="No se pudo guardar la decisión: ${fallo.message}" />
        </c:otherwise>
      </c:choose>
    </c:when>
  </c:choose>
</c:if>

<sql:query var="pendientes" dataSource="${bd}">
  SELECT p.id_proyecto, p.modalidad AS modalidad_proyecto,
         a.titulo, a.objetivo_general, a.modalidad AS modalidad_idea,
         (SELECT GROUP_CONCAT(CONCAT(u.nombres, ' ', u.apellidos, ' (', u.documento, ')') SEPARATOR ', ')
            FROM integrante i JOIN usuario u ON u.id_usuario = i.id_usuario
           WHERE i.id_proyecto = p.id_proyecto) AS estudiantes,
         IF(EXISTS (SELECT 1 FROM integrante i2
                     WHERE i2.id_proyecto = p.id_proyecto AND i2.id_usuario = a.id_proponente),
            'Idea propia del estudiante', 'Banco de ideas') AS origen,
         (SELECT d.url FROM documento d
           WHERE d.id_proyecto = p.id_proyecto AND d.tipo = 'Recibo de pago'
           ORDER BY d.version DESC LIMIT 1) AS recibo
  FROM proyecto p JOIN idea a ON a.id_idea = p.id_idea
  WHERE p.fase = 1 ORDER BY p.id_proyecto
</sql:query>

<c:set var="titulo" value="Ideas pendientes" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Ideas pendientes (fase 1)</h1>
  <c:if test="${not empty error}"><p class="error"><c:out value="${error}" /></p></c:if>
  <c:if test="${pendientes.rowCount == 0}"><p class="suave">No hay ideas pendientes de revisión.</p></c:if>
</section>

<c:forEach var="f" items="${pendientes.rows}">
  <section class="tarjeta">
    <h2>Proyecto #<c:out value="${f.id_proyecto}" /> - <c:out value="${f.titulo}" /></h2>
    <table>
      <tr><th>Estudiante(s)</th><td><c:out value="${f.estudiantes}" /></td></tr>
      <tr><th>Modalidad del proyecto</th><td><c:out value="${f.modalidad_proyecto}" /></td></tr>
      <tr><th>Origen de la idea</th><td><c:out value="${f.origen}" /></td></tr>
      <tr><th>Modalidad de la idea</th><td><c:out value="${f.modalidad_idea}" /></td></tr>
      <tr><th>Descripción</th><td><c:out value="${f.objetivo_general}" /></td></tr>
      <tr><th>Recibo de pago</th>
          <td><a href="<c:out value='${f.recibo}' />" target="_blank" rel="noopener"><c:out value="${f.recibo}" /></a></td></tr>
    </table>

    <form method="post" action="ideas_pendientes.jsp" class="decision">
      <input type="hidden" name="id" value="${f.id_proyecto}">
      <label for="motivo${f.id_proyecto}">Motivo (obligatorio para rechazar)</label>
      <textarea id="motivo${f.id_proyecto}" name="motivo" rows="2"><c:out value="${idConError == f.id_proyecto ? param.motivo : ''}" /></textarea>
      <button type="submit" name="decision" value="asignar">Asignar idea</button>
      <button type="submit" name="decision" value="rechazar" class="peligro">Rechazar</button>
    </form>
  </section>
</c:forEach>

<%@ include file="/includes/pie.jsp" %>
