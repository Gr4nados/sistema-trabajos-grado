<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Coordinador" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%-- RF-24: busca un estudiante por codigo o nombre y muestra su proyecto (la coordinacion ve todo). --%>
<c:set var="q" value="${fn:trim(param.q)}" />
<c:if test="${not empty q}">
  <c:set var="patron" value="%${q}%" />
  <sql:query var="res" dataSource="${bd}">
    SELECT u.id_usuario, u.codigo, u.documento, u.nombres, u.apellidos,
           p.id_proyecto, p.radicado, p.modalidad, p.fase, p.estado, p.fecha_limite, p.papeles_solicitados,
           a.titulo,
           CONCAT(d.nombres, ' ', d.apellidos) AS director,
           CONCAT(e.nombres, ' ', e.apellidos) AS evaluador
    FROM usuario u
    JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario JOIN rol r ON r.id_rol = ur.id_rol
    LEFT JOIN proyecto p ON p.id_proyecto = (SELECT MAX(i.id_proyecto) FROM integrante i WHERE i.id_usuario = u.id_usuario)
    LEFT JOIN idea a ON a.id_idea = p.id_idea
    LEFT JOIN usuario d ON d.id_usuario = p.id_director
    LEFT JOIN usuario e ON e.id_usuario = p.id_evaluador
    WHERE r.nombre = 'Estudiante'
      AND (u.codigo LIKE ? OR CONCAT(u.nombres, ' ', u.apellidos) LIKE ?)
    ORDER BY u.apellidos, u.nombres LIMIT 50
    <sql:param value="${patron}" />
    <sql:param value="${patron}" />
  </sql:query>
</c:if>

<c:set var="titulo" value="Buscar estudiante" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Buscar estudiante</h1>
  <form method="get" action="buscar.jsp">
    <label for="q">Código o nombre</label>
    <input type="text" id="q" name="q" maxlength="80" value="<c:out value='${q}' />" required>
    <button type="submit">Buscar</button>
  </form>
</section>

<c:if test="${not empty q}">
  <c:if test="${res.rowCount == 0}">
    <section class="tarjeta"><p class="suave">No se encontraron estudiantes con ese código o nombre.</p></section>
  </c:if>
  <c:forEach var="f" items="${res.rows}">
    <section class="tarjeta">
      <h2><c:out value="${f.nombres} ${f.apellidos}" />
        <small class="suave">cód. <c:out value="${empty f.codigo ? '-' : f.codigo}" /> · doc. <c:out value="${f.documento}" /></small></h2>
      <c:choose>
        <c:when test="${empty f.id_proyecto}"><p class="suave">Aún no tiene proyecto.</p></c:when>
        <c:otherwise>
          <table>
            <tr><th>Proyecto</th><td>#<c:out value="${f.id_proyecto}" /> · <c:out value="${f.modalidad}" /></td></tr>
            <tr><th>Radicado</th><td><c:out value="${empty f.radicado ? 'Sin radicado' : f.radicado}" /></td></tr>
            <tr><th>Idea</th><td><c:out value="${empty f.titulo ? 'Sin asignar' : f.titulo}" /></td></tr>
            <tr><th>Fase / estado</th><td><c:out value="${f.fase}" /> de 6 · <c:set var="valorInsignia" value="${f.estado}" /><%@ include file="/includes/insignia.jsp" %></td></tr>
            <tr><th>Director</th><td><c:out value="${empty f.director ? 'Sin asignar' : f.director}" /></td></tr>
            <tr><th>Evaluador</th><td><c:out value="${empty f.evaluador ? 'Sin asignar' : f.evaluador}" /></td></tr>
            <c:if test="${not empty f.fecha_limite}"><tr><th>Fecha límite</th><td><c:out value="${f.fecha_limite}" /></td></tr></c:if>
            <c:if test="${f.papeles_solicitados}"><tr><th>Papeles de grado</th><td>Solicitados</td></tr></c:if>
          </table>
          <sql:query var="docs" dataSource="${bd}">
            SELECT tipo, version, fase, url FROM documento WHERE id_proyecto = ? ORDER BY tipo, version DESC
            <sql:param value="${f.id_proyecto}" />
          </sql:query>
          <c:if test="${docs.rowCount > 0}">
            <details>
              <summary>Documentos (<c:out value="${docs.rowCount}" />)</summary>
              <c:forEach var="d" items="${docs.rows}">
                <p><c:out value="${d.tipo}" /> v<c:out value="${d.version}" /> (fase <c:out value="${d.fase}" />):
                  <a href="<c:out value='${d.url}' />" target="_blank" rel="noopener"><c:out value="${d.url}" /></a></p>
              </c:forEach>
            </details>
          </c:if>
        </c:otherwise>
      </c:choose>
    </section>
  </c:forEach>
</c:if>

<%@ include file="/includes/pie.jsp" %>
