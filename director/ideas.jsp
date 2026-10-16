<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Director" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%-- RF-05: el director publica ideas para el banco y ve las suyas. --%>
<sql:query var="ideas" dataSource="${bd}">
  SELECT id_idea, titulo, modalidad, nivel, periodo_academico, disponibilidad, motivo_rechazo
  FROM idea WHERE id_proponente = ? ORDER BY id_idea DESC
  <sql:param value="${sessionScope.idUsuario}" />
</sql:query>

<c:set var="titulo" value="Mis ideas" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <div class="barra">
    <h1>Mis ideas publicadas</h1>
    <a class="boton" href="idea_nueva.jsp">Publicar idea</a>
  </div>
  <c:choose>
    <c:when test="${ideas.rowCount == 0}"><p class="suave">Aún no has publicado ideas.</p></c:when>
    <c:otherwise>
      <table>
        <thead><tr><th>ID</th><th>Título</th><th>Modalidad</th><th>Nivel</th><th>Período</th><th>Disponibilidad</th></tr></thead>
        <tbody>
          <c:forEach var="i" items="${ideas.rows}">
            <tr>
              <td><c:out value="${i.id_idea}" /></td>
              <td><c:out value="${i.titulo}" /></td>
              <td><c:out value="${i.modalidad}" /></td>
              <td><c:out value="${i.nivel}" /></td>
              <td><c:out value="${i.periodo_academico}" /></td>
              <td><c:set var="valorInsignia" value="${i.disponibilidad}" /><%@ include file="/includes/insignia.jsp" %>
                <c:if test="${i.disponibilidad == 'Rechazada' && not empty i.motivo_rechazo}"><br><small class="suave">Motivo: <c:out value="${i.motivo_rechazo}" /></small></c:if></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/includes/pie.jsp" %>
