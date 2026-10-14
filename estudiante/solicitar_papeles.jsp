<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Estudiante" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%--
  RF-14: en la fase 6 el estudiante solicita sus papeles de grado. Solo POST; el aviso llega
  a los coordinadores como recordatorio (no hay correos).
--%>
<c:if test="${pageContext.request.method != 'POST'}">
  <c:redirect url="/estudiante/inicio.jsp" />
</c:if>
<sql:query var="proy" dataSource="${bd}">
  SELECT p.id_proyecto, p.fase, p.papeles_solicitados
  FROM proyecto p JOIN integrante i ON i.id_proyecto = p.id_proyecto
  WHERE i.id_usuario = ? ORDER BY p.id_proyecto DESC LIMIT 1
  <sql:param value="${sessionScope.idUsuario}" />
</sql:query>
<c:choose>
  <c:when test="${proy.rowCount == 0 || proy.rows[0].fase != 6}">
    <c:set var="mensaje" value="Solo puedes solicitar los papeles cuando tu proceso finaliza (fase 6)." scope="session" />
    <c:set var="mensajeTipo" value="error" scope="session" />
  </c:when>
  <c:when test="${proy.rows[0].papeles_solicitados}">
    <c:set var="mensaje" value="Ya habías solicitado tus papeles de grado." scope="session" />
  </c:when>
  <c:otherwise>
    <c:set var="idProyecto" value="${proy.rows[0].id_proyecto}" />
    <c:catch var="fallo">
      <sql:transaction dataSource="${bd}">
        <sql:update>
          UPDATE proyecto SET papeles_solicitados = TRUE WHERE id_proyecto = ?
          <sql:param value="${idProyecto}" />
        </sql:update>
        <sql:update>
          INSERT INTO recordatorio (id_usuario, id_proyecto, tipo, mensaje)
          SELECT ur.id_usuario, ?, 'Sin revisar', CONCAT('El proyecto ', ?, ' solicitó sus papeles de grado')
          FROM usuario_rol ur JOIN rol r ON r.id_rol = ur.id_rol WHERE r.nombre = 'Coordinador'
          <sql:param value="${idProyecto}" />
          <sql:param value="${idProyecto}" />
        </sql:update>
      </sql:transaction>
    </c:catch>
    <c:choose>
      <c:when test="${empty fallo}">
        <c:set var="mensaje" value="Solicitud de papeles de grado enviada." scope="session" />
      </c:when>
      <c:otherwise>
        <c:set var="mensaje" value="No se pudo enviar la solicitud: ${fallo.message}" scope="session" />
        <c:set var="mensajeTipo" value="error" scope="session" />
      </c:otherwise>
    </c:choose>
  </c:otherwise>
</c:choose>
<c:redirect url="/estudiante/inicio.jsp" />
