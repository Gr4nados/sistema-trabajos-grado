<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Estudiante" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%-- RF-06: banco de ideas (pagina interna): ID, titulo, disponibilidad, periodo, nivel y proponente. --%>
<c:set var="soloDisp" value="${param.disp == '1'}" />
<sql:query var="ideas" dataSource="${bd}">
  SELECT i.id_idea, i.titulo, i.modalidad, i.objetivo_general, i.linea_investigacion, i.nivel,
         i.periodo_academico, i.disponibilidad,
         CONCAT(u.nombres, ' ', u.apellidos) AS proponente,
         IF(EXISTS (SELECT 1 FROM usuario_rol ur JOIN rol r ON r.id_rol = ur.id_rol
                     WHERE ur.id_usuario = i.id_proponente AND r.nombre IN ('Director', 'Evaluador')),
            'Docente', 'Estudiante') AS tipo_proponente
  FROM idea i JOIN usuario u ON u.id_usuario = i.id_proponente
  WHERE i.disponibilidad IN ('Disponible', 'Asignada')
    AND (? = 0 OR i.disponibilidad = 'Disponible')
  ORDER BY i.id_idea DESC
  <sql:param value="${soloDisp ? 1 : 0}" />
</sql:query>

<c:set var="titulo" value="Banco de ideas" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <div class="barra">
    <h1>Banco de ideas</h1>
    <a class="boton" href="idea_nueva.jsp"><svg class="ico"><use href="#i-mas"/></svg>Proponer una idea</a>
  </div>
  <form method="get" action="banco_ideas.jsp" class="filtros">
    <label class="opcion interruptor">
      <input type="checkbox" name="disp" value="1" ${soloDisp ? 'checked' : ''} onchange="this.form.submit()">
      Solo ideas disponibles
    </label>
    <noscript><button type="submit">Filtrar</button></noscript>
  </form>

  <c:choose>
    <c:when test="${ideas.rowCount == 0}"><p class="suave">No hay ideas para mostrar.</p></c:when>
    <c:otherwise>
      <table>
        <thead><tr><th>ID</th><th>Título</th><th>Disponibilidad</th><th>Período</th><th>Nivel</th><th>Propuesta por</th></tr></thead>
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
                </details>
              </td>
              <td><c:set var="valorInsignia" value="${i.disponibilidad}" /><%@ include file="/includes/insignia.jsp" %></td>
              <td><c:out value="${i.periodo_academico}" /></td>
              <td><c:out value="${i.nivel}" /></td>
              <td><c:out value="${i.proponente}" /> (<c:out value="${i.tipo_proponente}" />)</td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/includes/pie.jsp" %>
