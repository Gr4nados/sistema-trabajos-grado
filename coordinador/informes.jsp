<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Coordinador" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%-- RF-25: estado de los proyectos por alumno, por director y por evaluador. --%>
<sql:query var="porAlumno" dataSource="${bd}">
  SELECT CONCAT(u.apellidos, ' ', u.nombres) AS alumno, u.codigo,
         p.id_proyecto, p.fase, p.estado,
         CONCAT(d.nombres, ' ', d.apellidos) AS director,
         CONCAT(e.nombres, ' ', e.apellidos) AS evaluador
  FROM integrante i
  JOIN usuario u ON u.id_usuario = i.id_usuario
  JOIN proyecto p ON p.id_proyecto = i.id_proyecto
  LEFT JOIN usuario d ON d.id_usuario = p.id_director
  LEFT JOIN usuario e ON e.id_usuario = p.id_evaluador
  ORDER BY u.apellidos, u.nombres
</sql:query>
<sql:query var="porDirector" dataSource="${bd}">
  SELECT CONCAT(u.apellidos, ' ', u.nombres) AS docente, COUNT(*) AS total,
         SUM(p.fase < 6) AS en_curso, SUM(p.fase = 6) AS finalizados,
         SUM(p.estado = 'Rechazado') AS rechazados, SUM(p.estado = 'Aplazado') AS aplazados
  FROM proyecto p JOIN usuario u ON u.id_usuario = p.id_director
  GROUP BY u.id_usuario, u.apellidos, u.nombres ORDER BY u.apellidos, u.nombres
</sql:query>
<sql:query var="porEvaluador" dataSource="${bd}">
  SELECT CONCAT(u.apellidos, ' ', u.nombres) AS docente, COUNT(*) AS total,
         SUM(p.fase < 6) AS en_curso, SUM(p.fase = 6) AS finalizados,
         SUM(p.estado = 'Rechazado') AS rechazados, SUM(p.estado = 'Aplazado') AS aplazados
  FROM proyecto p JOIN usuario u ON u.id_usuario = p.id_evaluador
  GROUP BY u.id_usuario, u.apellidos, u.nombres ORDER BY u.apellidos, u.nombres
</sql:query>

<c:set var="titulo" value="Informes" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Informes del estado de los proyectos</h1>
  <h2>Por alumno</h2>
  <c:choose>
    <c:when test="${porAlumno.rowCount == 0}"><p class="suave">Aún no hay proyectos.</p></c:when>
    <c:otherwise>
      <table>
        <thead><tr><th>Alumno</th><th>Código</th><th>Proyecto</th><th>Fase</th><th>Estado</th><th>Director</th><th>Evaluador</th></tr></thead>
        <tbody>
          <c:forEach var="f" items="${porAlumno.rows}">
            <tr>
              <td><c:out value="${f.alumno}" /></td>
              <td><c:out value="${empty f.codigo ? '-' : f.codigo}" /></td>
              <td>#<c:out value="${f.id_proyecto}" /></td>
              <td><c:out value="${f.fase}" /></td>
              <td><c:out value="${f.estado}" /></td>
              <td><c:out value="${empty f.director ? '-' : f.director}" /></td>
              <td><c:out value="${empty f.evaluador ? '-' : f.evaluador}" /></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:otherwise>
  </c:choose>
</section>

<section class="tarjeta">
  <h2>Por director</h2>
  <c:choose>
    <c:when test="${porDirector.rowCount == 0}"><p class="suave">Ningún director tiene proyectos asignados.</p></c:when>
    <c:otherwise>
      <table>
        <thead><tr><th>Director</th><th>Total</th><th>En curso</th><th>Finalizados</th><th>Rechazados</th><th>Aplazados</th></tr></thead>
        <tbody>
          <c:forEach var="f" items="${porDirector.rows}">
            <tr>
              <td><c:out value="${f.docente}" /></td><td><c:out value="${f.total}" /></td>
              <td><c:out value="${f.en_curso}" /></td><td><c:out value="${f.finalizados}" /></td>
              <td><c:out value="${f.rechazados}" /></td><td><c:out value="${f.aplazados}" /></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:otherwise>
  </c:choose>
</section>

<section class="tarjeta">
  <h2>Por evaluador</h2>
  <c:choose>
    <c:when test="${porEvaluador.rowCount == 0}"><p class="suave">Ningún evaluador tiene proyectos asignados.</p></c:when>
    <c:otherwise>
      <table>
        <thead><tr><th>Evaluador</th><th>Total</th><th>En curso</th><th>Finalizados</th><th>Rechazados</th><th>Aplazados</th></tr></thead>
        <tbody>
          <c:forEach var="f" items="${porEvaluador.rows}">
            <tr>
              <td><c:out value="${f.docente}" /></td><td><c:out value="${f.total}" /></td>
              <td><c:out value="${f.en_curso}" /></td><td><c:out value="${f.finalizados}" /></td>
              <td><c:out value="${f.rechazados}" /></td><td><c:out value="${f.aplazados}" /></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/includes/pie.jsp" %>
