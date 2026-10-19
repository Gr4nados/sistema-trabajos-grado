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
  Banco de ideas del coordinador (Ruta.md, actualizaciones 4 y 5).
  - Ve todo el banco (el estudiante solo ve las ideas Disponibles o Asignadas).
  - Acepta (pasa a "Disponible") o rechaza con motivo las ideas que propone un docente ("Pendiente").
  - Edita (idea_editar.jsp) y elimina ideas. No se puede eliminar una idea ligada a un proyecto.
--%>
<c:if test="${pageContext.request.method == 'POST'}">
  <c:set var="motivo" value="${fn:trim(param.motivo)}" />
  <c:choose>
    <c:when test="${param.accion == 'aceptar' || param.accion == 'rechazar'}">
      <c:choose>
        <c:when test="${param.accion == 'rechazar' && (empty motivo || fn:length(motivo) > 300)}">
          <c:set var="error" value="Para rechazar escribe el motivo (máximo 300 caracteres)." />
          <c:set var="idConError" value="${param.id}" />
        </c:when>
        <c:otherwise>
          <sql:update dataSource="${bd}" var="filas">
            UPDATE idea SET disponibilidad = ?, motivo_rechazo = NULLIF(?, '')
            WHERE id_idea = ? AND disponibilidad = 'Pendiente'
            <sql:param value="${param.accion == 'aceptar' ? 'Disponible' : 'Rechazada'}" />
            <sql:param value="${param.accion == 'aceptar' ? '' : motivo}" />
            <sql:param value="${param.id}" />
          </sql:update>
          <c:choose>
            <c:when test="${filas == 1}">
              <c:set var="mensaje" value="${param.accion == 'aceptar' ? 'Idea aceptada: ya está disponible en el banco.' : 'Idea rechazada: el docente verá el motivo.'}" scope="session" />
            </c:when>
            <c:otherwise>
              <c:set var="mensaje" value="Esa idea ya no estaba pendiente." scope="session" />
              <c:set var="mensajeTipo" value="error" scope="session" />
            </c:otherwise>
          </c:choose>
          <c:redirect url="/coordinador/banco_ideas.jsp" />
        </c:otherwise>
      </c:choose>
    </c:when>

    <c:when test="${param.accion == 'eliminar'}">
      <sql:query var="enUso" dataSource="${bd}">
        SELECT COUNT(*) AS n FROM proyecto WHERE id_idea = ?
        <sql:param value="${param.id}" />
      </sql:query>
      <c:choose>
        <c:when test="${enUso.rows[0].n > 0}">
          <c:set var="mensaje" value="No se puede eliminar: la idea está ligada a un proyecto." scope="session" />
          <c:set var="mensajeTipo" value="error" scope="session" />
        </c:when>
        <c:otherwise>
          <c:catch var="fallo">
            <sql:update dataSource="${bd}">
              DELETE FROM idea WHERE id_idea = ?
              <sql:param value="${param.id}" />
            </sql:update>
          </c:catch>
          <c:choose>
            <c:when test="${empty fallo}"><c:set var="mensaje" value="Idea eliminada." scope="session" /></c:when>
            <c:otherwise>
              <c:set var="mensaje" value="No se pudo eliminar la idea: ${fallo.message}" scope="session" />
              <c:set var="mensajeTipo" value="error" scope="session" />
            </c:otherwise>
          </c:choose>
        </c:otherwise>
      </c:choose>
      <c:redirect url="/coordinador/banco_ideas.jsp" />
    </c:when>
  </c:choose>
</c:if>

<c:set var="filtro" value="${empty param.estado ? '' : param.estado}" />
<sql:query var="pendientes" dataSource="${bd}">
  SELECT i.id_idea, i.titulo, i.modalidad, i.objetivo_general, i.linea_investigacion, i.nivel,
         i.periodo_academico, CONCAT(u.nombres, ' ', u.apellidos) AS proponente
  FROM idea i JOIN usuario u ON u.id_usuario = i.id_proponente
  WHERE i.disponibilidad = 'Pendiente' ORDER BY i.id_idea
</sql:query>
<sql:query var="ideas" dataSource="${bd}">
  SELECT i.id_idea, i.titulo, i.modalidad, i.objetivo_general, i.linea_investigacion, i.nivel,
         i.periodo_academico, i.disponibilidad, i.motivo_rechazo,
         CONCAT(u.nombres, ' ', u.apellidos) AS proponente,
         IF(EXISTS (SELECT 1 FROM usuario_rol ur JOIN rol r ON r.id_rol = ur.id_rol
                     WHERE ur.id_usuario = i.id_proponente AND r.nombre IN ('Director', 'Evaluador')),
            'Docente', 'Estudiante') AS tipo_proponente,
         (SELECT p.id_proyecto FROM proyecto p WHERE p.id_idea = i.id_idea) AS id_proyecto
  FROM idea i JOIN usuario u ON u.id_usuario = i.id_proponente
  WHERE i.disponibilidad <> 'Pendiente' AND (? = '' OR i.disponibilidad = ?)
  ORDER BY i.id_idea DESC
  <sql:param value="${filtro}" />
  <sql:param value="${filtro}" />
</sql:query>

<c:set var="titulo" value="Banco de ideas" />
<%@ include file="/includes/cabecera.jsp" %>

<c:if test="${not empty error}"><p class="error"><c:out value="${error}" /></p></c:if>

<c:if test="${pendientes.rowCount > 0}">
  <section class="tarjeta">
    <h1>Ideas de docentes por revisar</h1>
    <p class="suave">Al aceptarlas pasan al banco y los estudiantes pueden elegirlas.</p>
  </section>
  <c:forEach var="f" items="${pendientes.rows}">
    <section class="tarjeta">
      <h2>#<c:out value="${f.id_idea}" /> - <c:out value="${f.titulo}" /></h2>
      <table>
        <tr><th>Propuesta por</th><td><c:out value="${f.proponente}" /> (Docente)</td></tr>
        <tr><th>Modalidad</th><td><c:out value="${f.modalidad}" /></td></tr>
        <tr><th>Objetivo general</th><td><c:out value="${f.objetivo_general}" /></td></tr>
        <c:if test="${not empty f.linea_investigacion}"><tr><th>Línea de investigación</th><td><c:out value="${f.linea_investigacion}" /></td></tr></c:if>
        <tr><th>Nivel / período</th><td><c:out value="${f.nivel}" /> · <c:out value="${f.periodo_academico}" /></td></tr>
      </table>
      <form method="post" action="banco_ideas.jsp" class="decision">
        <input type="hidden" name="id" value="${f.id_idea}">
        <label for="motivo${f.id_idea}">Motivo (obligatorio para rechazar)</label>
        <textarea id="motivo${f.id_idea}" name="motivo" rows="2" maxlength="300"><c:out value="${idConError == f.id_idea ? param.motivo : ''}" /></textarea>
        <button type="submit" name="accion" value="aceptar">Aceptar idea</button>
        <button type="submit" name="accion" value="rechazar" class="peligro">Rechazar</button>
      </form>
    </section>
  </c:forEach>
</c:if>

<section class="tarjeta">
  <h1>Banco de ideas</h1>
  <form method="get" action="banco_ideas.jsp" class="filtros">
    <label for="estado">Filtrar por disponibilidad</label>
    <select id="estado" name="estado" onchange="this.form.submit()">
      <option value="">Todas</option>
      <option value="Disponible" ${filtro == 'Disponible' ? 'selected' : ''}>Disponible</option>
      <option value="Asignada" ${filtro == 'Asignada' ? 'selected' : ''}>Asignada</option>
      <option value="Rechazada" ${filtro == 'Rechazada' ? 'selected' : ''}>Rechazada</option>
    </select>
    <noscript><button type="submit">Filtrar</button></noscript>
  </form>

  <c:choose>
    <c:when test="${ideas.rowCount == 0}"><p class="suave">No hay ideas para mostrar.</p></c:when>
    <c:otherwise>
      <table>
        <thead><tr><th>ID</th><th>Título</th><th>Disponibilidad</th><th>Período</th><th>Nivel</th><th>Propuesta por</th><th>Acciones</th></tr></thead>
        <tbody>
          <c:forEach var="i" items="${ideas.rows}">
            <tr>
              <td><c:out value="${i.id_idea}" /></td>
              <td>
                <details>
                  <summary><c:out value="${i.titulo}" /></summary>
                  <p><strong>Modalidad:</strong> <c:out value="${i.modalidad}" /></p>
                  <p><strong>Objetivo general:</strong> <c:out value="${i.objetivo_general}" /></p>
                  <c:if test="${not empty i.linea_investigacion}">
                    <p><strong>Línea de investigación:</strong> <c:out value="${i.linea_investigacion}" /></p>
                  </c:if>
                  <c:if test="${not empty i.id_proyecto}"><p><strong>Proyecto:</strong> #<c:out value="${i.id_proyecto}" /></p></c:if>
                </details>
              </td>
              <td><c:set var="valorInsignia" value="${i.disponibilidad}" /><%@ include file="/includes/insignia.jsp" %>
                <c:if test="${i.disponibilidad == 'Rechazada' && not empty i.motivo_rechazo}"><br><small class="suave">Motivo: <c:out value="${i.motivo_rechazo}" /></small></c:if></td>
              <td><c:out value="${i.periodo_academico}" /></td>
              <td><c:out value="${i.nivel}" /></td>
              <td><c:out value="${i.proponente}" /> (<c:out value="${i.tipo_proponente}" />)</td>
              <td class="acciones">
                <a class="boton pequeno contorno" href="idea_editar.jsp?id=${i.id_idea}"><svg class="ico"><use href="#i-editar"/></svg>Editar</a>
                <c:if test="${empty i.id_proyecto}">
                  <form method="post" action="banco_ideas.jsp" onsubmit="return confirm('¿Eliminar esta idea?');">
                    <input type="hidden" name="id" value="${i.id_idea}">
                    <button type="submit" name="accion" value="eliminar" class="peligro"><svg class="ico"><use href="#i-papelera"/></svg>Eliminar</button>
                  </form>
                </c:if>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/includes/pie.jsp" %>
