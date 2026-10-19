<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Estudiante" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%--
  RF-08 (fase 1): el estudiante escoge una idea (del banco o propia) y registra la URL del
  recibo de pago. Queda a la espera del coordinador. Proponer una idea y asignarla son pasos
  distintos. Al escoger, la idea queda reservada para este proyecto (proyecto.id_idea es unico).
--%>
<sql:query var="proy" dataSource="${bd}">
  SELECT p.id_proyecto, p.fase, p.id_idea
  FROM proyecto p JOIN integrante i ON i.id_proyecto = p.id_proyecto
  WHERE i.id_usuario = ? ORDER BY p.id_proyecto DESC LIMIT 1
  <sql:param value="${sessionScope.idUsuario}" />
</sql:query>
<c:set var="p" value="${proy.rowCount > 0 ? proy.rows[0] : null}" />
<c:set var="puedeElegir" value="${proy.rowCount > 0 && p.fase == 1 && empty p.id_idea}" />

<c:if test="${pageContext.request.method == 'POST' && puedeElegir}">
  <c:set var="url" value="${fn:trim(param.url_recibo)}" />
  <sql:query var="valida" dataSource="${bd}">
    SELECT id_idea FROM idea
    WHERE id_idea = ? AND disponibilidad = 'Disponible'
      AND id_idea NOT IN (SELECT id_idea FROM proyecto WHERE id_idea IS NOT NULL)
    <sql:param value="${param.idea}" />
  </sql:query>
  <c:choose>
    <c:when test="${valida.rowCount == 0}">
      <c:set var="error" value="Selecciona una idea disponible." />
    </c:when>
    <c:when test="${!(fn:startsWith(url, 'http://') || fn:startsWith(url, 'https://')) || fn:length(url) > 500}">
      <c:set var="error" value="Escribe la URL del recibo de pago (debe empezar por http:// o https://, máximo 500 caracteres)." />
    </c:when>
    <c:otherwise>
      <c:catch var="fallo">
        <sql:transaction dataSource="${bd}">
          <sql:update>
            UPDATE proyecto SET id_idea = ? WHERE id_proyecto = ? AND fase = 1 AND id_idea IS NULL
            <sql:param value="${param.idea}" />
            <sql:param value="${p.id_proyecto}" />
          </sql:update>
          <%-- Cada URL nueva es una version nueva; no se sobrescribe la anterior --%>
          <sql:update>
            INSERT INTO documento (id_proyecto, tipo, version, url, fase, id_autor)
            SELECT ?, 'Recibo de pago', COALESCE(MAX(version), 0) + 1, ?, 1, ?
            FROM documento WHERE id_proyecto = ? AND tipo = 'Recibo de pago' AND fase = 1
            <sql:param value="${p.id_proyecto}" />
            <sql:param value="${url}" />
            <sql:param value="${sessionScope.idUsuario}" />
            <sql:param value="${p.id_proyecto}" />
          </sql:update>
          <%-- RF-17: aviso "sin revisar" para cada coordinador --%>
          <sql:update>
            INSERT INTO recordatorio (id_usuario, id_proyecto, tipo, mensaje)
            SELECT ur.id_usuario, ?, 'Sin revisar', CONCAT('Idea del proyecto ', ?, ' pendiente de revisión')
            FROM usuario_rol ur JOIN rol r ON r.id_rol = ur.id_rol WHERE r.nombre = 'Coordinador'
            <sql:param value="${p.id_proyecto}" />
            <sql:param value="${p.id_proyecto}" />
          </sql:update>
        </sql:transaction>
      </c:catch>
      <c:choose>
        <c:when test="${empty fallo}">
          <c:set var="mensaje" value="Idea y recibo registrados. Quedan a la espera del coordinador." scope="session" />
          <c:redirect url="/estudiante/inicio.jsp" />
        </c:when>
        <c:when test="${fn:contains(fallo.message, 'Duplicate')}">
          <c:set var="error" value="Esa idea acaba de ser tomada por otro proyecto. Escoge otra." />
        </c:when>
        <c:otherwise>
          <c:set var="error" value="No se pudo registrar: ${fallo.message}" />
        </c:otherwise>
      </c:choose>
    </c:otherwise>
  </c:choose>
</c:if>

<c:if test="${proy.rowCount > 0}">
  <%-- Idea elegida (si espera al coordinador), ultimo recibo y ultimo rechazo de la fase 1 --%>
  <c:if test="${not empty p.id_idea}">
    <sql:query var="elegida" dataSource="${bd}">
      SELECT a.titulo, a.objetivo_general FROM idea a WHERE a.id_idea = ?
      <sql:param value="${p.id_idea}" />
    </sql:query>
  </c:if>
  <sql:query var="ultimoRechazo" dataSource="${bd}">
    SELECT comentario, revisada_en FROM revision
    WHERE id_proyecto = ? AND fase = 1 AND resultado = 'Rechazado'
    ORDER BY id_revision DESC LIMIT 1
    <sql:param value="${p.id_proyecto}" />
  </sql:query>
  <sql:query var="recibos" dataSource="${bd}">
    SELECT version, url, subido_en FROM documento
    WHERE id_proyecto = ? AND tipo = 'Recibo de pago' ORDER BY version DESC
    <sql:param value="${p.id_proyecto}" />
  </sql:query>
</c:if>
<c:if test="${puedeElegir}">
  <sql:query var="disponibles" dataSource="${bd}">
    SELECT id_idea, titulo, modalidad, nivel, periodo_academico FROM idea
    WHERE disponibilidad = 'Disponible'
      AND id_idea NOT IN (SELECT id_idea FROM proyecto WHERE id_idea IS NOT NULL)
    ORDER BY id_idea DESC
  </sql:query>
</c:if>

<c:set var="titulo" value="Asignar idea" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Fase 1: idea y recibo de pago</h1>

  <c:choose>
    <c:when test="${proy.rowCount == 0}">
      <p class="suave">Primero debes crear tu proyecto.</p>
      <a class="boton" href="proyecto_nuevo.jsp"><svg class="ico"><use href="#i-mas"/></svg>Crear mi proyecto</a>
    </c:when>

    <c:when test="${p.fase != 1}">
      <p class="suave">Tu proyecto ya superó la fase 1 (está en la fase <c:out value="${p.fase}" />).</p>
    </c:when>

    <c:when test="${not empty p.id_idea}">
      <p><strong>Idea elegida:</strong> <c:out value="${elegida.rows[0].titulo}" /></p>
      <p><c:out value="${elegida.rows[0].objetivo_general}" /></p>
      <p class="suave">Estás a la espera de la decisión del coordinador.</p>
    </c:when>

    <c:otherwise>
      <c:if test="${ultimoRechazo.rowCount > 0}">
        <p class="error"><strong>El coordinador rechazó tu última idea.</strong>
          Motivo: <c:out value="${ultimoRechazo.rows[0].comentario}" /></p>
      </c:if>
      <c:if test="${not empty error}"><p class="error"><c:out value="${error}" /></p></c:if>

      <c:choose>
        <c:when test="${disponibles.rowCount == 0}">
          <p class="suave">No hay ideas disponibles. Puedes proponer una propia y volver.</p>
          <a class="boton" href="idea_nueva.jsp"><svg class="ico"><use href="#i-mas"/></svg>Proponer una idea</a>
        </c:when>
        <c:otherwise>
          <form method="post" action="asignar_idea.jsp">
            <label>Escoge una idea * (del banco o una propia)</label>
            <c:forEach var="d" items="${disponibles.rows}">
              <label class="opcion bloque">
                <input type="radio" name="idea" value="${d.id_idea}" required
                       ${param.idea == d.id_idea ? 'checked' : ''}>
                <span>#<c:out value="${d.id_idea}" /> - <c:out value="${d.titulo}" />
                  <small class="suave">(<c:out value="${d.modalidad}" />, <c:out value="${d.nivel}" />, <c:out value="${d.periodo_academico}" />)</small></span>
              </label>
            </c:forEach>
            <p class="suave">¿No ves la tuya? Propón una idea y vuelve aquí.</p>
            <a class="boton pequeno contorno" href="idea_nueva.jsp"><svg class="ico"><use href="#i-mas"/></svg>Proponer una idea</a>

            <label for="url_recibo">URL del recibo de pago *</label>
            <input type="url" id="url_recibo" name="url_recibo" maxlength="500" required
                   placeholder="https://..." value="<c:out value='${param.url_recibo}' />">

            <button type="submit">Enviar al coordinador</button>
          </form>
        </c:otherwise>
      </c:choose>
    </c:otherwise>
  </c:choose>
</section>

<c:if test="${proy.rowCount > 0 && recibos.rowCount > 0}">
  <section class="tarjeta">
    <h2>Historial de recibos</h2>
    <table>
      <thead><tr><th>Versión</th><th>URL</th><th>Registrado</th></tr></thead>
      <tbody>
        <c:forEach var="r" items="${recibos.rows}">
          <tr>
            <td><c:out value="${r.version}" /></td>
            <td><a class="chip-enlace" href="<c:out value='${r.url}' />" target="_blank" rel="noopener"><svg class="ico"><use href="#i-externo"/></svg><c:out value="${r.url}" /></a></td>
            <td><c:out value="${r.subido_en}" /></td>
          </tr>
        </c:forEach>
      </tbody>
    </table>
  </section>
</c:if>

<%@ include file="/includes/pie.jsp" %>
