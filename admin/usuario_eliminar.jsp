<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Administrador" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%--
  RF-03: eliminar un usuario. Pagina de accion (sin HTML): procesa y redirige.
  Si el usuario ya tiene registros (proyectos, ideas, revisiones) la base de datos
  impide borrarlo; en ese caso se desactiva en lugar de eliminarlo.
--%>
<c:choose>
  <c:when test="${pageContext.request.method != 'POST' || empty param.id}">
    <c:redirect url="/admin/usuarios.jsp" />
  </c:when>
  <c:when test="${param.id == sessionScope.idUsuario}">
    <c:set var="mensaje" value="No puedes eliminar tu propia cuenta." scope="session" />
    <c:set var="mensajeTipo" value="error" scope="session" />
  </c:when>
  <c:otherwise>
    <c:catch var="fallo">
      <sql:transaction dataSource="${bd}">
        <sql:update>
          DELETE FROM usuario_rol WHERE id_usuario = ?
          <sql:param value="${param.id}" />
        </sql:update>
        <sql:update>
          DELETE FROM usuario WHERE id_usuario = ?
          <sql:param value="${param.id}" />
        </sql:update>
      </sql:transaction>
    </c:catch>
    <c:choose>
      <c:when test="${empty fallo}">
        <c:set var="mensaje" value="Usuario eliminado." scope="session" />
      </c:when>
      <c:otherwise>
        <%-- La transaccion se deshizo: los roles siguen intactos. Se desactiva la cuenta. --%>
        <sql:update dataSource="${bd}">
          UPDATE usuario SET activo = FALSE WHERE id_usuario = ?
          <sql:param value="${param.id}" />
        </sql:update>
        <c:set var="mensaje" value="El usuario tiene registros asociados y no se puede eliminar; se desactivó su cuenta." scope="session" />
      </c:otherwise>
    </c:choose>
  </c:otherwise>
</c:choose>
<c:redirect url="/admin/usuarios.jsp" />
