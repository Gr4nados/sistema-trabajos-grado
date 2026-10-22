<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Estudiante" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%--
  RF-19: calificaciones y decisiones del proyecto. RNF-06: el estudiante no ve al evaluador;
  la consulta no trae su nombre y la revision del evaluador se rotula "Evaluación".
  La fase 1 es la decision del coordinador sobre la idea.
--%>
<sql:query var="revs" dataSource="${bd}">
  SELECT r.fase, r.resultado, r.calificacion, r.comentario, DATE_FORMAT(r.revisada_en, '%d/%m/%Y %H:%i') AS revisada_en,
         CASE r.rol_revisor
           WHEN 'Director' THEN CONCAT('Director: ', u.nombres, ' ', u.apellidos)
           WHEN 'Coordinador' THEN 'Coordinación'
           ELSE 'Evaluación'
         END AS revisor
  FROM revision r JOIN usuario u ON u.id_usuario = r.id_revisor
  WHERE r.id_proyecto = (SELECT MAX(i.id_proyecto) FROM integrante i WHERE i.id_usuario = ?)
  ORDER BY r.id_revision DESC
  <sql:param value="${sessionScope.idUsuario}" />
</sql:query>

<c:set var="titulo" value="Calificaciones" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Calificaciones y decisiones</h1>
  <c:choose>
    <c:when test="${revs.rowCount == 0}"><p class="suave">Aún no hay calificaciones ni decisiones sobre tu proyecto.</p></c:when>
    <c:otherwise>
      <table>
        <thead><tr><th>Fase</th><th>Quién</th><th>Resultado</th><th>Nota</th><th>Comentario</th><th>Fecha</th></tr></thead>
        <tbody>
          <c:forEach var="r" items="${revs.rows}">
            <tr>
              <td><c:out value="${r.fase}" /></td>
              <td><c:out value="${r.revisor}" /></td>
              <td><span class="insignia ${r.resultado == 'Aprobado' ? 'ok' : (r.resultado == 'Rechazado' ? 'mal' : 'medio')}"><c:out value="${r.resultado}" /></span></td>
              <td><c:out value="${empty r.calificacion ? '-' : r.calificacion}" /></td>
              <td><c:out value="${r.comentario}" /></td>
              <td><c:out value="${r.revisada_en}" /></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/includes/pie.jsp" %>
