<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Director" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%--
  RF-20, RF-21 (fases 2 y 4): el director ve los proyectos a su cargo con los datos del alumno,
  abre la URL del documento, lo califica y lo aprueba, rechaza o aplaza.
  - Aprobar: el proyecto pasa a la fase siguiente (el evaluador) y queda "En revisión".
  - Rechazar / aplazar: el proyecto conserva la fase y el estudiante registra otra version.
  Cada decision queda en revision (RNF-08).
--%>
<c:if test="${pageContext.request.method == 'POST'}">
  <sql:query var="objetivo" dataSource="${bd}">
    SELECT p.id_proyecto, p.fase, p.id_evaluador FROM proyecto p
    WHERE p.id_proyecto = ? AND p.id_director = ? AND p.fase IN (2, 4) AND p.estado = 'En revisión'
      AND EXISTS (SELECT 1 FROM documento d WHERE d.id_proyecto = p.id_proyecto
                   AND d.tipo = IF(p.fase = 2, 'Anteproyecto', 'Informe'))
    <sql:param value="${param.id}" />
    <sql:param value="${sessionScope.idUsuario}" />
  </sql:query>
  <%@ include file="/includes/decision_validar.jsp" %>
  <c:choose>
    <c:when test="${objetivo.rowCount == 0}">
      <c:set var="mensaje" value="Ese proyecto ya no está pendiente de tu revisión." scope="session" />
      <c:set var="mensajeTipo" value="error" scope="session" />
      <c:redirect url="/director/anteproyectos.jsp" />
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
            VALUES (?, ?, ?, 'Director', ?, ?, NULLIF(?, ''))
            <sql:param value="${idProyecto}" />
            <sql:param value="${faseActual}" />
            <sql:param value="${sessionScope.idUsuario}" />
            <sql:param value="${resultado}" />
            <sql:param value="${nota}" />
            <sql:param value="${comentario}" />
          </sql:update>
          <sql:update>
            UPDATE proyecto SET fase = fase + ?, estado = ? WHERE id_proyecto = ?
            <sql:param value="${aprobar ? 1 : 0}" />
            <sql:param value="${aprobar ? 'En revisión' : resultado}" />
            <sql:param value="${idProyecto}" />
          </sql:update>
          <sql:update>
            UPDATE recordatorio SET vigente = FALSE WHERE id_proyecto = ? AND tipo = 'Sin revisar'
            <sql:param value="${idProyecto}" />
          </sql:update>
          <c:if test="${aprobar}">
            <%-- RF-17: aviso al evaluador; si aun no hay evaluador, aviso a la coordinacion --%>
            <sql:update>
              INSERT INTO recordatorio (id_usuario, id_proyecto, tipo, mensaje)
              SELECT p.id_evaluador, p.id_proyecto, 'Sin revisar',
                     CONCAT('Documento del proyecto ', p.id_proyecto, ' pendiente de revisión')
              FROM proyecto p WHERE p.id_proyecto = ? AND p.id_evaluador IS NOT NULL
              <sql:param value="${idProyecto}" />
            </sql:update>
            <sql:update>
              INSERT INTO recordatorio (id_usuario, id_proyecto, tipo, mensaje)
              SELECT ur.id_usuario, p.id_proyecto, 'Sin revisar',
                     CONCAT('Proyecto ', p.id_proyecto, ' aprobado por el director: falta asignar evaluador')
              FROM proyecto p, usuario_rol ur JOIN rol r ON r.id_rol = ur.id_rol
              WHERE p.id_proyecto = ? AND p.id_evaluador IS NULL AND r.nombre = 'Coordinador'
              <sql:param value="${idProyecto}" />
            </sql:update>
          </c:if>
        </sql:transaction>
      </c:catch>
      <c:choose>
        <c:when test="${empty fallo}">
          <c:set var="mensaje" value="Decisión registrada: ${resultado}." scope="session" />
          <c:redirect url="/director/anteproyectos.jsp" />
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
         (SELECT GROUP_CONCAT(CONCAT(u.nombres, ' ', u.apellidos, ' - doc. ', u.documento, IFNULL(CONCAT(' - cód. ', u.codigo), ''))
                              SEPARATOR '; ')
            FROM integrante i JOIN usuario u ON u.id_usuario = i.id_usuario
           WHERE i.id_proyecto = p.id_proyecto) AS estudiantes,
         d.version, d.url, d.subido_en
  FROM proyecto p
  LEFT JOIN idea a ON a.id_idea = p.id_idea
  JOIN documento d ON d.id_proyecto = p.id_proyecto AND d.tipo = IF(p.fase = 2, 'Anteproyecto', 'Informe')
   AND d.version = (SELECT MAX(d2.version) FROM documento d2 WHERE d2.id_proyecto = p.id_proyecto AND d2.tipo = d.tipo)
  WHERE p.id_director = ? AND p.fase IN (2, 4) AND p.estado = 'En revisión'
  ORDER BY p.id_proyecto
  <sql:param value="${sessionScope.idUsuario}" />
</sql:query>
<sql:query var="otros" dataSource="${bd}">
  SELECT p.id_proyecto, p.fase, p.estado, a.titulo,
         (SELECT GROUP_CONCAT(CONCAT(u.nombres, ' ', u.apellidos) SEPARATOR ', ')
            FROM integrante i JOIN usuario u ON u.id_usuario = i.id_usuario
           WHERE i.id_proyecto = p.id_proyecto) AS estudiantes
  FROM proyecto p LEFT JOIN idea a ON a.id_idea = p.id_idea
  WHERE p.id_director = ?
    AND NOT (p.fase IN (2, 4) AND p.estado = 'En revisión'
             AND EXISTS (SELECT 1 FROM documento d WHERE d.id_proyecto = p.id_proyecto
                          AND d.tipo = IF(p.fase = 2, 'Anteproyecto', 'Informe')))
  ORDER BY p.id_proyecto
  <sql:param value="${sessionScope.idUsuario}" />
</sql:query>

<c:set var="titulo" value="Anteproyectos" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Anteproyectos por revisar</h1>
  <c:if test="${not empty error}"><p class="error"><c:out value="${error}" /></p></c:if>
  <c:if test="${pendientes.rowCount == 0}"><p class="suave">No tienes documentos pendientes de revisión.</p></c:if>
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
              <a class="chip-enlace" href="<c:out value='${f.url}' />" target="_blank" rel="noopener"><svg class="ico"><use href="#i-externo"/></svg><c:out value="${f.url}" /></a>
              <small class="suave">(<c:out value="${f.subido_en}" />)</small></td></tr>
    </table>
    <form method="post" action="anteproyectos.jsp" class="decision">
      <input type="hidden" name="id" value="${f.id_proyecto}">
      <label for="nota${f.id_proyecto}">Calificación (0.0 a 5.0) *</label>
      <input type="text" id="nota${f.id_proyecto}" name="calificacion" maxlength="4" inputmode="decimal"
             value="<c:out value='${conError ? param.calificacion : ""}' />">
      <label for="com${f.id_proyecto}">Comentario (obligatorio para rechazar o aplazar)</label>
      <textarea id="com${f.id_proyecto}" name="comentario" rows="2"><c:out value="${conError ? param.comentario : ''}" /></textarea>
      <button type="submit" name="decision" value="aprobar">Aprobar y pasar al evaluador</button>
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
        <thead><tr><th>#</th><th>Idea</th><th>Estudiante(s)</th><th>Fase</th><th>Estado</th></tr></thead>
        <tbody>
          <c:forEach var="o" items="${otros.rows}">
            <tr>
              <td><c:out value="${o.id_proyecto}" /></td>
              <td><c:out value="${empty o.titulo ? 'Sin idea' : o.titulo}" /></td>
              <td><c:out value="${o.estudiantes}" /></td>
              <td><c:out value="${o.fase}" /></td>
              <td><c:set var="valorInsignia" value="${o.estado}" /><%@ include file="/includes/insignia.jsp" %></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/includes/pie.jsp" %>
