<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Evaluador" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%--
  RF-22, RF-23 (fases 3 y 5): el evaluador ve solo lo que el director ya aprobo (el proyecto esta
  en la fase 3 o 5), abre la URL, califica y aprueba, rechaza o aplaza.
  - Aprobar: estado "Aprobado" en la misma fase = a la espera de la aceptacion del coordinador.
  - Rechazar / aplazar: el estudiante corrige (documentos.jsp) y el estado vuelve a "En revisión".
--%>
<c:if test="${pageContext.request.method == 'POST'}">
  <sql:query var="objetivo" dataSource="${bd}">
    SELECT p.id_proyecto, p.fase FROM proyecto p
    WHERE p.id_proyecto = ? AND p.id_evaluador = ? AND p.fase IN (3, 5) AND p.estado = 'En revisión'
    <sql:param value="${param.id}" />
    <sql:param value="${sessionScope.idUsuario}" />
  </sql:query>
  <%@ include file="/includes/decision_validar.jsp" %>
  <c:choose>
    <c:when test="${objetivo.rowCount == 0}">
      <c:set var="mensaje" value="Ese proyecto ya no está pendiente de tu revisión." scope="session" />
      <c:set var="mensajeTipo" value="error" scope="session" />
      <c:redirect url="/evaluador/anteproyectos.jsp" />
    </c:when>
    <c:when test="${not empty errorDecision}">
      <c:set var="error" value="${errorDecision}" />
      <c:set var="idConError" value="${param.id}" />
    </c:when>
    <c:otherwise>
      <c:set var="idProyecto" value="${objetivo.rows[0].id_proyecto}" />
      <c:set var="faseActual" value="${objetivo.rows[0].fase}" />
      <c:set var="aprobar" value="${resultado == 'Aprobado'}" />
      <c:catch var="fallo">
        <sql:transaction dataSource="${bd}">
          <sql:update>
            INSERT INTO revision (id_proyecto, fase, id_revisor, rol_revisor, resultado, calificacion, comentario)
            VALUES (?, ?, ?, 'Evaluador', ?, ?, NULLIF(?, ''))
            <sql:param value="${idProyecto}" />
            <sql:param value="${faseActual}" />
            <sql:param value="${sessionScope.idUsuario}" />
            <sql:param value="${resultado}" />
            <sql:param value="${nota}" />
            <sql:param value="${comentario}" />
          </sql:update>
          <sql:update>
            UPDATE proyecto SET estado = ? WHERE id_proyecto = ?
            <sql:param value="${resultado}" />
            <sql:param value="${idProyecto}" />
          </sql:update>
          <sql:update>
            UPDATE recordatorio SET vigente = FALSE WHERE id_proyecto = ? AND tipo = 'Sin revisar'
            <sql:param value="${idProyecto}" />
          </sql:update>
          <c:if test="${aprobar}">
            <sql:update>
              INSERT INTO recordatorio (id_usuario, id_proyecto, tipo, mensaje)
              SELECT ur.id_usuario, ?, 'Sin revisar', CONCAT('Proyecto ', ?, ' aprobado por el evaluador: pendiente de aceptación')
              FROM usuario_rol ur JOIN rol r ON r.id_rol = ur.id_rol WHERE r.nombre = 'Coordinador'
              <sql:param value="${idProyecto}" />
              <sql:param value="${idProyecto}" />
            </sql:update>
          </c:if>
        </sql:transaction>
      </c:catch>
      <c:choose>
        <c:when test="${empty fallo}">
          <c:set var="mensaje" value="Decisión registrada: ${resultado}." scope="session" />
          <c:redirect url="/evaluador/anteproyectos.jsp" />
        </c:when>
        <c:otherwise>
          <c:set var="error" value="No se pudo guardar la decisión: ${fallo.message}" />
          <c:set var="idConError" value="${param.id}" />
        </c:otherwise>
      </c:choose>
    </c:otherwise>
  </c:choose>
</c:if>

<sql:query var="pendientes" dataSource="${bd}">
  SELECT p.id_proyecto, p.radicado, p.fase, a.titulo,
         (SELECT GROUP_CONCAT(CONCAT(u.nombres, ' ', u.apellidos) SEPARATOR ', ')
            FROM integrante i JOIN usuario u ON u.id_usuario = i.id_usuario
           WHERE i.id_proyecto = p.id_proyecto) AS estudiantes,
         d.version, d.url, d.subido_en,
         (SELECT r.calificacion FROM revision r
           WHERE r.id_proyecto = p.id_proyecto AND r.rol_revisor = 'Director' AND r.fase = p.fase - 1
           ORDER BY r.id_revision DESC LIMIT 1) AS nota_director,
         (SELECT r.comentario FROM revision r
           WHERE r.id_proyecto = p.id_proyecto AND r.rol_revisor = 'Director' AND r.fase = p.fase - 1
           ORDER BY r.id_revision DESC LIMIT 1) AS comentario_director
  FROM proyecto p
  LEFT JOIN idea a ON a.id_idea = p.id_idea
  JOIN documento d ON d.id_proyecto = p.id_proyecto AND d.tipo = IF(p.fase = 3, 'Anteproyecto', 'Otro')
   AND d.version = (SELECT MAX(d2.version) FROM documento d2 WHERE d2.id_proyecto = p.id_proyecto AND d2.tipo = d.tipo)
  WHERE p.id_evaluador = ? AND p.fase IN (3, 5) AND p.estado = 'En revisión'
  ORDER BY p.id_proyecto
  <sql:param value="${sessionScope.idUsuario}" />
</sql:query>
<sql:query var="otros" dataSource="${bd}">
  SELECT p.id_proyecto, p.fase, p.estado, a.titulo
  FROM proyecto p LEFT JOIN idea a ON a.id_idea = p.id_idea
  WHERE p.id_evaluador = ? AND p.fase >= 3 AND NOT (p.fase IN (3, 5) AND p.estado = 'En revisión')
  ORDER BY p.id_proyecto
  <sql:param value="${sessionScope.idUsuario}" />
</sql:query>

<c:set var="titulo" value="Anteproyectos" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Anteproyectos por evaluar</h1>
  <p class="suave">Solo aparecen los documentos que el director ya aprobó.</p>
  <c:if test="${not empty error}"><p class="error"><c:out value="${error}" /></p></c:if>
  <c:if test="${pendientes.rowCount == 0}"><p class="suave">No tienes documentos pendientes de evaluación.</p></c:if>
</section>

<c:forEach var="f" items="${pendientes.rows}">
  <c:set var="conError" value="${idConError == f.id_proyecto}" />
  <section class="tarjeta">
    <h2>Proyecto #<c:out value="${f.id_proyecto}" /> - <c:out value="${f.titulo}" /><c:if test="${not empty f.radicado}"> <small class="suave">Rad. <c:out value="${f.radicado}" /></small></c:if></h2>
    <table>
      <tr><th>Estudiante(s)</th><td><c:out value="${f.estudiantes}" /></td></tr>
      <tr><th>Fase</th><td><c:out value="${f.fase}" /> de 6</td></tr>
      <tr><th>Documento</th>
          <td>Versión <c:out value="${f.version}" /> ·
              <a href="<c:out value='${f.url}' />" target="_blank" rel="noopener"><c:out value="${f.url}" /></a>
              <small class="suave">(<c:out value="${f.subido_en}" />)</small></td></tr>
      <tr><th>Calificación del director</th>
          <td><c:out value="${empty f.nota_director ? '-' : f.nota_director}" />
              <c:if test="${not empty f.comentario_director}"> · <c:out value="${f.comentario_director}" /></c:if></td></tr>
    </table>
    <form method="post" action="anteproyectos.jsp" class="decision">
      <input type="hidden" name="id" value="${f.id_proyecto}">
      <label for="nota${f.id_proyecto}">Calificación (0.0 a 5.0) *</label>
      <input type="text" id="nota${f.id_proyecto}" name="calificacion" maxlength="4" inputmode="decimal"
             value="<c:out value='${conError ? param.calificacion : ""}' />">
      <label for="com${f.id_proyecto}">Comentario (obligatorio para rechazar o aplazar)</label>
      <textarea id="com${f.id_proyecto}" name="comentario" rows="2"><c:out value="${conError ? param.comentario : ''}" /></textarea>
      <button type="submit" name="decision" value="aprobar">Aprobar</button>
      <button type="submit" name="decision" value="aplazar" class="secundario">Aplazar</button>
      <button type="submit" name="decision" value="rechazar" class="peligro">Rechazar</button>
    </form>
  </section>
</c:forEach>

<section class="tarjeta">
  <h2>Otros proyectos a mi cargo</h2>
  <c:choose>
    <c:when test="${otros.rowCount == 0}"><p class="suave">No hay más proyectos a tu cargo.</p></c:when>
    <c:otherwise>
      <table>
        <thead><tr><th>#</th><th>Idea</th><th>Fase</th><th>Estado</th></tr></thead>
        <tbody>
          <c:forEach var="o" items="${otros.rows}">
            <tr>
              <td><c:out value="${o.id_proyecto}" /></td>
              <td><c:out value="${empty o.titulo ? 'Sin idea' : o.titulo}" /></td>
              <td><c:out value="${o.fase}" /></td>
              <td><c:set var="valorInsignia" value="${o.estado}" /><%@ include file="/includes/insignia.jsp" %><c:if test="${o.estado == 'Aprobado' && (o.fase == 3 || o.fase == 5)}"> <small class="suave">espera al coordinador</small></c:if></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/includes/pie.jsp" %>
