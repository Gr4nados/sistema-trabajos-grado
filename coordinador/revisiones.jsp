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
  RF-12 (fase 5, Informe II): despues del evaluador, el coordinador da la aprobacion final.
  Un proyecto espera aqui cuando esta en la fase 5 con estado "Aprobado" (aprobado por el
  evaluador). Aceptar lo pasa a la fase 6 (fase final: se programa la sustentacion). Rechazar deja
  el proyecto en la fase 5 para que el estudiante corrija. La decision queda en revision.
  (La fase 3 ya no pasa por el coordinador: la decide solo el evaluador.)
--%>
<c:if test="${pageContext.request.method == 'POST'}">
  <sql:query var="objetivo" dataSource="${bd}">
    SELECT id_proyecto, fase FROM proyecto
    WHERE id_proyecto = ? AND fase = 5 AND estado = 'Aprobado'
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
  SELECT p.id_proyecto, p.radicado, p.fase, a.titulo,
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
  LEFT JOIN documento d ON d.id_proyecto = p.id_proyecto AND d.tipo = 'Informe'
   AND d.version = (SELECT MAX(d2.version) FROM documento d2 WHERE d2.id_proyecto = p.id_proyecto AND d2.tipo = d.tipo)
  WHERE p.fase = 5 AND p.estado = 'Aprobado'
  ORDER BY p.id_proyecto
</sql:query>

<%-- Informes en curso (fases 4 y 5): el coordinador los puede ver mientras avanzan (solo lectura) --%>
<sql:query var="enCurso" dataSource="${bd}">
  SELECT p.id_proyecto, p.radicado, p.fase, p.estado, a.titulo,
         (SELECT GROUP_CONCAT(CONCAT(u.nombres, ' ', u.apellidos) SEPARATOR ', ')
            FROM integrante i JOIN usuario u ON u.id_usuario = i.id_usuario
           WHERE i.id_proyecto = p.id_proyecto) AS estudiantes,
         d.version, d.url
  FROM proyecto p
  LEFT JOIN idea a ON a.id_idea = p.id_idea
  JOIN documento d ON d.id_proyecto = p.id_proyecto AND d.tipo = 'Informe'
   AND d.version = (SELECT MAX(d2.version) FROM documento d2 WHERE d2.id_proyecto = p.id_proyecto AND d2.tipo = 'Informe')
  WHERE p.fase IN (4, 5) AND NOT (p.fase = 5 AND p.estado = 'Aprobado')
  ORDER BY p.fase, p.id_proyecto
</sql:query>

<c:set var="titulo" value="Revisiones" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Aprobación final (fase 5)</h1>
  <p class="suave">Informes aprobados por el evaluador que esperan tu aprobación final.</p>
  <c:if test="${not empty error}"><p class="error"><c:out value="${error}" /></p></c:if>
  <c:if test="${pendientes.rowCount == 0}"><p class="suave">No hay proyectos pendientes de aceptación.</p></c:if>
</section>

<c:forEach var="f" items="${pendientes.rows}">
  <section class="tarjeta">
    <h2>Proyecto #<c:out value="${f.id_proyecto}" /> - <c:out value="${f.titulo}" /><c:if test="${not empty f.radicado}"> <small class="suave">Rad. <c:out value="${f.radicado}" /></small></c:if></h2>
    <table>
      <tr><th>Estudiante(s)</th><td><c:out value="${f.estudiantes}" /></td></tr>
      <tr><th>Fase</th><td><c:out value="${f.fase}" /> de 6</td></tr>
      <tr><th>Documento</th>
          <td>Versión <c:out value="${f.version}" /> ·
              <a class="chip-enlace" href="<c:out value='${f.url}' />" target="_blank" rel="noopener"><svg class="ico"><use href="#i-externo"/></svg><c:out value="${f.url}" /></a></td></tr>
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

<section class="tarjeta">
  <h2>Informes en curso (fases 4 y 5)</h2>
  <p class="suave">Solo lectura: el informe lo decide primero el director (fase 4) y luego el evaluador (fase 5).</p>
  <c:choose>
    <c:when test="${enCurso.rowCount == 0}"><p class="suave">No hay informes en curso.</p></c:when>
    <c:otherwise>
      <table>
        <thead><tr><th>#</th><th>Radicado</th><th>Idea</th><th>Estudiante(s)</th><th>Fase</th><th>Estado</th><th>Informe</th></tr></thead>
        <tbody>
          <c:forEach var="f" items="${enCurso.rows}">
            <tr>
              <td><c:out value="${f.id_proyecto}" /></td>
              <td><c:out value="${empty f.radicado ? '-' : f.radicado}" /></td>
              <td><c:out value="${empty f.titulo ? 'Sin idea' : f.titulo}" /></td>
              <td><c:out value="${f.estudiantes}" /></td>
              <td><c:out value="${f.fase}" /></td>
              <td><c:set var="valorInsignia" value="${f.estado}" /><%@ include file="/includes/insignia.jsp" %></td>
              <td>v<c:out value="${f.version}" /> · <a class="chip-enlace" href="<c:out value='${f.url}' />" target="_blank" rel="noopener"><svg class="ico"><use href="#i-externo"/></svg>Abrir</a></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/includes/pie.jsp" %>
