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
  RF-10: el coordinador agrega el director (y el evaluador) al proyecto. El estudiante solo ve
  a su director (vista_proyecto_estudiante). PENDIENTES.md #3: el coordinador asigna ambos.
  Tambien puede fijar una fecha limite (prorroga), que aparece como recordatorio (RF-17).
  El director no puede ser el evaluador del mismo proyecto (lo exige la base de datos).
--%>
<c:if test="${pageContext.request.method == 'POST'}">
  <c:set var="idDir" value="${fn:trim(param.director)}" />
  <c:set var="idEva" value="${fn:trim(param.evaluador)}" />
  <c:set var="fecha" value="${fn:trim(param.fecha_limite)}" />
  <sql:query var="objetivo" dataSource="${bd}">
    SELECT id_proyecto FROM proyecto WHERE id_proyecto = ? AND fase >= 2
    <sql:param value="${param.id}" />
  </sql:query>
  <c:if test="${not empty idDir}">
    <sql:query var="okDir" dataSource="${bd}">
      SELECT u.id_usuario FROM usuario u
      JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario JOIN rol r ON r.id_rol = ur.id_rol
      WHERE u.id_usuario = ? AND r.nombre = 'Director' AND u.activo = TRUE
      <sql:param value="${idDir}" />
    </sql:query>
  </c:if>
  <c:if test="${not empty idEva}">
    <sql:query var="okEva" dataSource="${bd}">
      SELECT u.id_usuario FROM usuario u
      JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario JOIN rol r ON r.id_rol = ur.id_rol
      WHERE u.id_usuario = ? AND r.nombre = 'Evaluador' AND u.activo = TRUE
      <sql:param value="${idEva}" />
    </sql:query>
  </c:if>
  <c:choose>
    <c:when test="${objetivo.rowCount == 0}">
      <c:set var="mensaje" value="Ese proyecto no está disponible para asignar director." scope="session" />
      <c:set var="mensajeTipo" value="error" scope="session" />
      <c:redirect url="/coordinador/asignar_director.jsp" />
    </c:when>
    <c:when test="${empty idDir || okDir.rowCount == 0}">
      <c:set var="error" value="Escoge un director válido." />
    </c:when>
    <c:when test="${not empty idEva && okEva.rowCount == 0}">
      <c:set var="error" value="El evaluador escogido no es válido." />
    </c:when>
    <c:when test="${idDir == idEva}">
      <c:set var="error" value="El director no puede ser el evaluador del mismo proyecto." />
    </c:when>
    <c:otherwise>
      <c:catch var="fallo">
        <sql:transaction dataSource="${bd}">
          <sql:update>
            UPDATE proyecto SET id_director = ?, id_evaluador = NULLIF(?, ''), fecha_limite = NULLIF(?, '')
            WHERE id_proyecto = ?
            <sql:param value="${idDir}" />
            <sql:param value="${idEva}" />
            <sql:param value="${fecha}" />
            <sql:param value="${param.id}" />
          </sql:update>
          <sql:update>
            UPDATE recordatorio SET vigente = FALSE WHERE id_proyecto = ? AND tipo = 'Fecha límite'
            <sql:param value="${param.id}" />
          </sql:update>
          <c:if test="${not empty fecha}">
            <sql:update>
              INSERT INTO recordatorio (id_usuario, id_proyecto, tipo, mensaje, fecha_limite)
              SELECT i.id_usuario, ?, 'Fecha límite', CONCAT('Fecha límite del proyecto ', ?), ?
              FROM integrante i WHERE i.id_proyecto = ?
              <sql:param value="${param.id}" />
              <sql:param value="${param.id}" />
              <sql:param value="${fecha}" />
              <sql:param value="${param.id}" />
            </sql:update>
            <sql:update>
              INSERT INTO recordatorio (id_usuario, id_proyecto, tipo, mensaje, fecha_limite)
              VALUES (?, ?, 'Fecha límite', CONCAT('Fecha límite del proyecto ', ?), ?)
              <sql:param value="${idDir}" />
              <sql:param value="${param.id}" />
              <sql:param value="${param.id}" />
              <sql:param value="${fecha}" />
            </sql:update>
          </c:if>
        </sql:transaction>
      </c:catch>
      <c:choose>
        <c:when test="${empty fallo}">
          <c:set var="mensaje" value="Asignación guardada para el proyecto ${param.id}." scope="session" />
          <c:redirect url="/coordinador/asignar_director.jsp" />
        </c:when>
        <c:otherwise>
          <c:set var="error" value="No se pudo guardar: ${fallo.message}" />
        </c:otherwise>
      </c:choose>
    </c:otherwise>
  </c:choose>
  <c:set var="idConError" value="${param.id}" />
</c:if>

<sql:query var="directores" dataSource="${bd}">
  SELECT u.id_usuario, u.nombres, u.apellidos FROM usuario u
  JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario JOIN rol r ON r.id_rol = ur.id_rol
  WHERE r.nombre = 'Director' AND u.activo = TRUE ORDER BY u.apellidos, u.nombres
</sql:query>
<sql:query var="evaluadores" dataSource="${bd}">
  SELECT u.id_usuario, u.nombres, u.apellidos FROM usuario u
  JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario JOIN rol r ON r.id_rol = ur.id_rol
  WHERE r.nombre = 'Evaluador' AND u.activo = TRUE ORDER BY u.apellidos, u.nombres
</sql:query>
<sql:query var="proyectos" dataSource="${bd}">
  SELECT p.id_proyecto, p.fase, p.estado, p.id_director, p.id_evaluador, p.fecha_limite,
         a.titulo,
         (SELECT GROUP_CONCAT(CONCAT(u.nombres, ' ', u.apellidos) SEPARATOR ', ')
            FROM integrante i JOIN usuario u ON u.id_usuario = i.id_usuario
           WHERE i.id_proyecto = p.id_proyecto) AS estudiantes
  FROM proyecto p LEFT JOIN idea a ON a.id_idea = p.id_idea
  WHERE p.fase >= 2 ORDER BY p.id_proyecto
</sql:query>

<c:set var="titulo" value="Asignar director" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Asignar director y evaluador</h1>
  <p class="suave">Los proyectos aparecen aquí cuando su idea ya fue asignada (fase 2 en adelante).
    El estudiante solo verá a su director.</p>
  <c:if test="${not empty error}"><p class="error"><c:out value="${error}" /></p></c:if>
  <c:if test="${proyectos.rowCount == 0}"><p class="suave">No hay proyectos con idea asignada.</p></c:if>
  <c:if test="${directores.rowCount == 0}">
    <p class="error">No hay docentes con el rol Director. El administrador debe registrarlos.</p>
  </c:if>
</section>

<c:forEach var="f" items="${proyectos.rows}">
  <c:set var="conError" value="${idConError == f.id_proyecto}" />
  <section class="tarjeta">
    <h2>Proyecto #<c:out value="${f.id_proyecto}" /> - <c:out value="${f.titulo}" /></h2>
    <p class="suave"><c:out value="${f.estudiantes}" /> · Fase <c:out value="${f.fase}" /> · <c:out value="${f.estado}" /></p>
    <form method="post" action="asignar_director.jsp">
      <input type="hidden" name="id" value="${f.id_proyecto}">
      <c:set var="selDir" value="${conError ? param.director : f.id_director}" />
      <c:set var="selEva" value="${conError ? param.evaluador : f.id_evaluador}" />
      <label for="dir${f.id_proyecto}">Director *</label>
      <select id="dir${f.id_proyecto}" name="director" required>
        <option value="">Selecciona...</option>
        <c:forEach var="d" items="${directores.rows}">
          <option value="${d.id_usuario}" ${selDir == d.id_usuario ? 'selected' : ''}><c:out value="${d.apellidos} ${d.nombres}" /></option>
        </c:forEach>
      </select>
      <label for="eva${f.id_proyecto}">Evaluador</label>
      <select id="eva${f.id_proyecto}" name="evaluador">
        <option value="">Sin asignar</option>
        <c:forEach var="d" items="${evaluadores.rows}">
          <option value="${d.id_usuario}" ${selEva == d.id_usuario ? 'selected' : ''}><c:out value="${d.apellidos} ${d.nombres}" /></option>
        </c:forEach>
      </select>
      <label for="fec${f.id_proyecto}">Fecha límite (opcional)</label>
      <input type="date" id="fec${f.id_proyecto}" name="fecha_limite" value="${conError ? param.fecha_limite : f.fecha_limite}">
      <button type="submit">Guardar</button>
    </form>
  </section>
</c:forEach>

<%@ include file="/includes/pie.jsp" %>
