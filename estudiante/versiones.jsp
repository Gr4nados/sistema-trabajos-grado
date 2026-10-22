<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Estudiante" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%-- RF-16: historial de versiones. Cada URL registrada queda como una version. --%>
<sql:query var="docs" dataSource="${bd}">
  SELECT d.tipo, d.version, d.fase, d.url, DATE_FORMAT(d.subido_en, '%d/%m/%Y %H:%i') AS subido_en,
         CONCAT(u.nombres, ' ', u.apellidos) AS autor
  FROM documento d JOIN usuario u ON u.id_usuario = d.id_autor
  WHERE d.id_proyecto = (SELECT MAX(i.id_proyecto) FROM integrante i WHERE i.id_usuario = ?)
  ORDER BY d.tipo, d.version DESC
  <sql:param value="${sessionScope.idUsuario}" />
</sql:query>

<c:set var="titulo" value="Versiones" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Historial de versiones</h1>
  <c:choose>
    <c:when test="${docs.rowCount == 0}"><p class="suave">Aún no has registrado documentos.</p></c:when>
    <c:otherwise>
      <table>
        <thead><tr><th>Tipo</th><th>Versión</th><th>Fase</th><th>URL</th><th>Registró</th><th>Fecha</th></tr></thead>
        <tbody>
          <c:forEach var="d" items="${docs.rows}">
            <tr>
              <td><c:out value="${d.tipo}" /></td>
              <td><c:out value="${d.version}" /></td>
              <td><c:out value="${d.fase}" /></td>
              <td><a class="chip-enlace" href="<c:out value='${d.url}' />" target="_blank" rel="noopener"><svg class="ico"><use href="#i-externo"/></svg><c:out value="${d.url}" /></a></td>
              <td><c:out value="${d.autor}" /></td>
              <td><c:out value="${d.subido_en}" /></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:otherwise>
  </c:choose>
  <a class="boton contorno" href="documentos.jsp"><svg class="ico"><use href="#i-atras"/></svg>Volver a documentos</a>
</section>

<%@ include file="/includes/pie.jsp" %>
