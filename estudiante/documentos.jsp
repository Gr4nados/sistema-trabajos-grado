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
  RF-11, RF-16, RF-18 (fases 2 a 5): el estudiante registra, ve, edita o elimina la URL de su
  documento. Fases 2 y 3 (Propuesta I y II) usan el tipo "Anteproyecto"; fases 4 y 5 (Informe I y II)
  el tipo "Informe" (la investigacion a fondo). Cada URL nueva es una version nueva; "editar" registra una version nueva.
  - Fases 2 y 4: puede registrar mientras el director no haya aprobado.
  - Fases 3 y 5: solo corrige si el evaluador o el coordinador lo rechazaron o aplazaron.
  - Eliminar: solo el documento registrado en la fase actual y antes de que alguien lo revise.
  Al registrar, el estado vuelve a "En revisión" y el revisor recibe un recordatorio.
  El evaluador nunca se muestra al estudiante (RNF-06).
--%>
<sql:query var="proy" dataSource="${bd}">
  SELECT p.id_proyecto, p.fase, p.estado, p.id_director
  FROM proyecto p JOIN integrante i ON i.id_proyecto = p.id_proyecto
  WHERE i.id_usuario = ? ORDER BY p.id_proyecto DESC LIMIT 1
  <sql:param value="${sessionScope.idUsuario}" />
</sql:query>
<c:set var="p" value="${proy.rowCount > 0 ? proy.rows[0] : null}" />
<c:set var="tipoDoc" value="${proy.rowCount > 0 && p.fase >= 4 ? 'Informe' : 'Anteproyecto'}" />
<c:set var="etiquetaDoc" value="${tipoDoc == 'Informe' ? 'informe' : 'anteproyecto (FC124)'}" />
<c:set var="enRango" value="${proy.rowCount > 0 && p.fase >= 2 && p.fase <= 5}" />
<c:set var="hayDirector" value="${enRango && not empty p.id_director}" />
<c:set var="puedeRegistrar" value="${hayDirector && (p.fase == 2 || p.fase == 4 || p.estado == 'Rechazado' || p.estado == 'Aplazado')}" />

<c:if test="${enRango}">
  <sql:query var="ultimo" dataSource="${bd}">
    SELECT id_documento, version, url, fase, DATE_FORMAT(subido_en, '%d/%m/%Y %H:%i') AS subido_en FROM documento
    WHERE id_proyecto = ? AND tipo = ? ORDER BY version DESC LIMIT 1
    <sql:param value="${p.id_proyecto}" />
    <sql:param value="${tipoDoc}" />
  </sql:query>
  <sql:query var="revisadas" dataSource="${bd}">
    SELECT COUNT(*) AS n FROM revision WHERE id_proyecto = ? AND fase = ?
    <sql:param value="${p.id_proyecto}" />
    <sql:param value="${p.fase}" />
  </sql:query>
  <c:set var="u" value="${ultimo.rowCount > 0 ? ultimo.rows[0] : null}" />
  <c:set var="puedeEliminar" value="${ultimo.rowCount > 0 && u.fase == p.fase && revisadas.rows[0].n == 0 && p.estado == 'En revisión'}" />
</c:if>

<c:if test="${pageContext.request.method == 'POST' && enRango}">
  <c:choose>
    <c:when test="${param.accion == 'eliminar'}">
      <c:choose>
        <c:when test="${puedeEliminar}">
          <c:catch var="fallo">
            <sql:transaction dataSource="${bd}">
              <sql:update>
                DELETE FROM documento WHERE id_documento = ?
                <sql:param value="${u.id_documento}" />
              </sql:update>
              <sql:update>
                UPDATE recordatorio SET vigente = FALSE WHERE id_proyecto = ? AND tipo = 'Sin revisar'
                <sql:param value="${p.id_proyecto}" />
              </sql:update>
            </sql:transaction>
          </c:catch>
          <c:choose>
            <c:when test="${empty fallo}">
              <c:set var="mensaje" value="Documento eliminado." scope="session" />
              <c:redirect url="/estudiante/documentos.jsp" />
            </c:when>
            <c:otherwise><c:set var="error" value="No se pudo eliminar: ${fallo.message}" /></c:otherwise>
          </c:choose>
        </c:when>
        <c:otherwise>
          <c:set var="error" value="Ese documento ya no se puede eliminar (ya fue revisado o es de una fase anterior)." />
        </c:otherwise>
      </c:choose>
    </c:when>

    <c:when test="${!puedeRegistrar}">
      <c:set var="error" value="Ahora no puedes registrar documentos." />
    </c:when>

    <c:otherwise>
      <c:set var="url" value="${fn:trim(param.url)}" />
      <c:choose>
        <c:when test="${!(fn:startsWith(url, 'http://') || fn:startsWith(url, 'https://')) || fn:length(url) > 500}">
          <c:set var="error" value="Escribe la URL del documento (debe empezar por http:// o https://, máximo 500 caracteres)." />
        </c:when>
        <c:otherwise>
          <c:catch var="fallo">
            <sql:transaction dataSource="${bd}">
              <sql:update>
                INSERT INTO documento (id_proyecto, tipo, version, url, fase, id_autor)
                SELECT ?, ?, COALESCE(MAX(version), 0) + 1, ?, ?, ?
                FROM documento WHERE id_proyecto = ? AND tipo = ?
                <sql:param value="${p.id_proyecto}" />
                <sql:param value="${tipoDoc}" />
                <sql:param value="${url}" />
                <sql:param value="${p.fase}" />
                <sql:param value="${sessionScope.idUsuario}" />
                <sql:param value="${p.id_proyecto}" />
                <sql:param value="${tipoDoc}" />
              </sql:update>
              <sql:update>
                UPDATE proyecto SET estado = 'En revisión' WHERE id_proyecto = ?
                <sql:param value="${p.id_proyecto}" />
              </sql:update>
              <sql:update>
                UPDATE recordatorio SET vigente = FALSE WHERE id_proyecto = ? AND tipo = 'Sin revisar'
                <sql:param value="${p.id_proyecto}" />
              </sql:update>
              <%-- RF-17: fases 2 y 4 las revisa el director; fases 3 y 5 el evaluador --%>
              <sql:update>
                INSERT INTO recordatorio (id_usuario, id_proyecto, tipo, mensaje)
                SELECT x.u, x.id_proyecto, 'Sin revisar', CONCAT('Documento del proyecto ', x.id_proyecto, ' pendiente de revisión')
                FROM (SELECT IF(p.fase IN (2, 4), p.id_director, p.id_evaluador) AS u, p.id_proyecto
                        FROM proyecto p WHERE p.id_proyecto = ?) x
                WHERE x.u IS NOT NULL
                <sql:param value="${p.id_proyecto}" />
              </sql:update>
            </sql:transaction>
          </c:catch>
          <c:choose>
            <c:when test="${empty fallo}">
              <c:set var="mensaje" value="Documento registrado como una versión nueva." scope="session" />
              <c:redirect url="/estudiante/documentos.jsp" />
            </c:when>
            <c:otherwise><c:set var="error" value="No se pudo registrar: ${fallo.message}" /></c:otherwise>
          </c:choose>
        </c:otherwise>
      </c:choose>
    </c:otherwise>
  </c:choose>
</c:if>

<c:set var="titulo" value="Documentos" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Documentos del proyecto</h1>
  <c:choose>
    <c:when test="${proy.rowCount == 0}">
      <p class="suave">Primero debes crear tu proyecto.</p>
      <a class="boton" href="proyecto_nuevo.jsp"><svg class="ico"><use href="#i-mas"/></svg>Crear mi proyecto</a>
    </c:when>
    <c:when test="${p.fase == 1}">
      <p class="suave">Tu proyecto está en la fase 1. Primero completa la idea y el recibo de pago.</p>
      <a class="boton" href="asignar_idea.jsp">Ir a idea y recibo</a>
    </c:when>
    <c:when test="${p.fase == 6}">
      <p class="suave">Tu proceso finalizó. Puedes consultar el historial de versiones.</p>
      <a class="boton" href="versiones.jsp">Ver historial de versiones</a>
    </c:when>
    <c:otherwise>
      <p>Fase <strong><c:out value="${p.fase}" /></strong> de 6 · Estado: <c:set var="valorInsignia" value="${p.estado}" /><%@ include file="/includes/insignia.jsp" %></p>
      <c:if test="${not empty error}"><p class="error"><c:out value="${error}" /></p></c:if>

      <c:choose>
        <c:when test="${!hayDirector}">
          <p class="suave">Aún no tienes director asignado. Cuando el coordinador lo asigne podrás registrar tu <c:out value="${etiquetaDoc}" />.</p>
        </c:when>
        <c:otherwise>
          <c:if test="${ultimo.rowCount > 0}">
            <table>
              <tr><th>Versión actual</th><td><c:out value="${u.version}" /></td></tr>
              <tr><th>URL</th><td><a class="chip-enlace" href="<c:out value='${u.url}' />" target="_blank" rel="noopener"><svg class="ico"><use href="#i-externo"/></svg><c:out value="${u.url}" /></a></td></tr>
              <tr><th>Registrada</th><td><c:out value="${u.subido_en}" /></td></tr>
            </table>
          </c:if>

          <c:choose>
            <c:when test="${puedeRegistrar}">
              <c:set var="editando" value="${ultimo.rowCount > 0}" />
              <form method="post" action="documentos.jsp">
                <label for="url">URL del ${etiquetaDoc} *</label>
                <input type="url" id="url" name="url" maxlength="500" required placeholder="https://..."
                       value="<c:out value='${not empty param.url ? param.url : (editando ? u.url : "")}' />">
                <p class="suave"><c:choose>
                  <c:when test="${editando}">Al guardar se crea una versión nueva; la anterior se conserva.</c:when>
                  <c:otherwise>Solo se registra la URL; el sistema no recibe archivos.</c:otherwise>
                </c:choose></p>
                <button type="submit"><c:out value="${editando ? 'Guardar nueva versión' : 'Registrar'}" /></button>
              </form>
            </c:when>
            <c:when test="${p.estado == 'Aprobado'}">
              <p class="suave">Tu documento fue aprobado por el evaluador y espera la aceptación del coordinador.</p>
            </c:when>
            <c:otherwise>
              <p class="suave">Tu documento está en revisión. Podrás corregirlo si te lo devuelven.</p>
            </c:otherwise>
          </c:choose>

          <div class="acciones-fila">
          <c:if test="${puedeEliminar}">
            <form method="post" action="documentos.jsp" onsubmit="return confirm('¿Eliminar este documento?');">
              <input type="hidden" name="accion" value="eliminar">
              <button type="submit" class="peligro"><svg class="ico"><use href="#i-papelera"/></svg>Eliminar documento</button>
            </form>
          </c:if>
          <a class="boton pequeno contorno" href="versiones.jsp"><svg class="ico"><use href="#i-doc"/></svg>Historial de versiones</a>
          <a class="boton pequeno contorno" href="calificaciones.jsp"><svg class="ico"><use href="#i-estrella"/></svg>Calificaciones</a></div>
        </c:otherwise>
      </c:choose>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/includes/pie.jsp" %>
