<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Administrador" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%-- RF-03: editar los datos de un usuario. Contraseña vacia = no cambiarla. --%>
<c:set var="esPost" value="${pageContext.request.method == 'POST'}" />

<sql:query var="resUsuario" dataSource="${bd}">
  SELECT id_usuario, documento, codigo, nombres, apellidos, usuario, IF(activo, 1, 0) AS activo
  FROM usuario WHERE id_usuario = ?
  <sql:param value="${param.id}" />
</sql:query>
<c:if test="${resUsuario.rowCount == 0}">
  <c:set var="mensaje" value="El usuario no existe." scope="session" />
  <c:set var="mensajeTipo" value="error" scope="session" />
  <c:redirect url="/admin/usuarios.jsp" />
</c:if>
<c:set var="u" value="${resUsuario.rows[0]}" />
<%-- El administrador no puede cambiarse el rol ni desactivarse a si mismo --%>
<c:set var="propio" value="${u.id_usuario == sessionScope.idUsuario}" />

<sql:query var="roles" dataSource="${bd}">SELECT nombre FROM rol ORDER BY id_rol</sql:query>
<sql:query var="rolesActuales" dataSource="${bd}">
  SELECT r.nombre FROM usuario_rol ur JOIN rol r ON r.id_rol = ur.id_rol WHERE ur.id_usuario = ?
  <sql:param value="${u.id_usuario}" />
</sql:query>

<%-- rolesSel: roles actuales (GET) o los marcados en el formulario (POST) --%>
<c:set var="rolesSel" value="," />
<c:choose>
  <c:when test="${esPost && !propio}">
    <c:forEach var="marcado" items="${paramValues.rol}">
      <c:set var="rolesSel" value="${rolesSel}${marcado}," />
    </c:forEach>
  </c:when>
  <c:otherwise>
    <c:forEach var="ra" items="${rolesActuales.rows}">
      <c:set var="rolesSel" value="${rolesSel}${ra.nombre}," />
    </c:forEach>
  </c:otherwise>
</c:choose>

<c:if test="${esPost}">
  <c:set var="nValidos" value="0" />
  <c:set var="otros" value="0" />
  <c:forEach var="x" items="${roles.rows}">
    <c:set var="clave" value=",${x.nombre}," />
    <c:if test="${fn:contains(rolesSel, clave)}">
      <c:set var="nValidos" value="${nValidos + 1}" />
      <c:if test="${x.nombre != 'Director' && x.nombre != 'Evaluador'}">
        <c:set var="otros" value="${otros + 1}" />
      </c:if>
    </c:if>
  </c:forEach>
  <c:set var="esEstudiante" value="${fn:contains(rolesSel, ',Estudiante,')}" />

  <c:choose>
    <c:when test="${empty fn:trim(param.documento) || empty fn:trim(param.nombres) || empty fn:trim(param.apellidos) || empty fn:trim(param.usuario)}">
      <c:set var="error" value="Completa todos los campos obligatorios." />
    </c:when>
    <c:when test="${not empty param.contrasena && fn:length(param.contrasena) < 6}">
      <c:set var="error" value="La contraseña debe tener al menos 6 caracteres." />
    </c:when>
    <c:when test="${nValidos == 0}">
      <c:set var="error" value="Selecciona al menos un rol." />
    </c:when>
    <c:when test="${nValidos > 1 && (otros > 0 || nValidos != 2)}">
      <c:set var="error" value="Solo un docente puede tener dos roles, y deben ser Director y Evaluador." />
    </c:when>
    <c:when test="${esEstudiante && empty fn:trim(param.codigo)}">
      <c:set var="error" value="El estudiante necesita un código." />
    </c:when>
    <c:otherwise>
      <c:catch var="fallo">
        <sql:transaction dataSource="${bd}">
          <sql:update>
            UPDATE usuario
               SET documento = ?, codigo = NULLIF(?, ''), nombres = ?, apellidos = ?,
                   usuario = ?, activo = ?,
                   contrasena = IF(? = '', contrasena, SHA2(?, 256))
             WHERE id_usuario = ?
            <sql:param value="${fn:trim(param.documento)}" />
            <sql:param value="${esEstudiante ? fn:trim(param.codigo) : ''}" />
            <sql:param value="${fn:trim(param.nombres)}" />
            <sql:param value="${fn:trim(param.apellidos)}" />
            <sql:param value="${fn:trim(param.usuario)}" />
            <sql:param value="${(propio || not empty param.activo) ? 1 : 0}" />
            <sql:param value="${empty param.contrasena ? '' : param.contrasena}" />
            <sql:param value="${empty param.contrasena ? '' : param.contrasena}" />
            <sql:param value="${u.id_usuario}" />
          </sql:update>
          <c:if test="${!propio}">
            <sql:update>
              DELETE FROM usuario_rol WHERE id_usuario = ?
              <sql:param value="${u.id_usuario}" />
            </sql:update>
            <c:forEach var="x" items="${roles.rows}">
              <c:set var="clave" value=",${x.nombre}," />
              <c:if test="${fn:contains(rolesSel, clave)}">
                <sql:update>
                  INSERT INTO usuario_rol (id_usuario, id_rol)
                  SELECT ?, id_rol FROM rol WHERE nombre = ?
                  <sql:param value="${u.id_usuario}" />
                  <sql:param value="${x.nombre}" />
                </sql:update>
              </c:if>
            </c:forEach>
          </c:if>
        </sql:transaction>
      </c:catch>
      <c:choose>
        <c:when test="${empty fallo}">
          <c:set var="mensaje" value="Usuario actualizado correctamente." scope="session" />
          <c:redirect url="/admin/usuarios.jsp" />
        </c:when>
        <c:when test="${fn:contains(fallo.message, 'Duplicate')}">
          <c:set var="error" value="Ya existe otro usuario con ese documento, nombre de usuario o código." />
        </c:when>
        <c:otherwise>
          <c:set var="error" value="No se pudo actualizar: ${fallo.message}" />
        </c:otherwise>
      </c:choose>
    </c:otherwise>
  </c:choose>
</c:if>

<c:set var="titulo" value="Editar usuario" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Editar usuario</h1>
  <c:if test="${not empty error}"><p class="error"><c:out value="${error}" /></p></c:if>

  <form method="post" action="usuario_editar.jsp">
    <input type="hidden" name="id" value="${u.id_usuario}">

    <label for="documento">Documento *</label>
    <input type="text" id="documento" name="documento" maxlength="20" required
           value="<c:out value='${esPost ? param.documento : u.documento}' />">

    <label for="nombres">Nombres *</label>
    <input type="text" id="nombres" name="nombres" maxlength="80" required
           value="<c:out value='${esPost ? param.nombres : u.nombres}' />">

    <label for="apellidos">Apellidos *</label>
    <input type="text" id="apellidos" name="apellidos" maxlength="80" required
           value="<c:out value='${esPost ? param.apellidos : u.apellidos}' />">

    <label for="usuario">Usuario *</label>
    <input type="text" id="usuario" name="usuario" maxlength="40" required
           value="<c:out value='${esPost ? param.usuario : u.usuario}' />">

    <label for="contrasena">Nueva contraseña (déjala vacía para conservar la actual)</label>
    <input type="password" id="contrasena" name="contrasena">

    <label>Rol *</label>
    <div class="opciones">
      <c:forEach var="x" items="${roles.rows}">
        <c:set var="clave" value=",${x.nombre}," />
        <label class="opcion">
          <input type="checkbox" name="rol" value="${x.nombre}"
                 ${fn:contains(rolesSel, clave) ? 'checked' : ''} ${propio ? 'disabled' : ''}>
          <c:out value="${x.nombre}" />
        </label>
      </c:forEach>
    </div>
    <c:choose>
      <c:when test="${propio}"><p class="suave">No puedes cambiar tu propio rol ni desactivarte.</p></c:when>
      <c:otherwise><p class="suave">Solo un docente puede tener dos roles: Director y Evaluador.</p></c:otherwise>
    </c:choose>

    <label for="codigo">Código estudiantil (solo estudiantes)</label>
    <input type="text" id="codigo" name="codigo" maxlength="20"
           value="<c:out value='${esPost ? param.codigo : u.codigo}' />">

    <label class="opcion">
      <input type="checkbox" name="activo" value="1"
             ${(esPost ? not empty param.activo : u.activo == 1) || propio ? 'checked' : ''} ${propio ? 'disabled' : ''}>
      Cuenta activa
    </label>

    <button type="submit">Guardar cambios</button>
    <a class="boton secundario" href="usuarios.jsp">Cancelar</a>
  </form>
</section>

<%@ include file="/includes/pie.jsp" %>
