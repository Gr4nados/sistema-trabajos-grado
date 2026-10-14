<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Administrador" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%-- RF-02: el administrador registra docentes, coordinadores y alumnos. --%>
<sql:query var="roles" dataSource="${bd}">SELECT nombre FROM rol ORDER BY id_rol</sql:query>

<c:set var="rolesSel" value="," />
<c:if test="${pageContext.request.method == 'POST'}">
  <%-- Roles marcados, como texto ",Director,Evaluador," --%>
  <c:forEach var="marcado" items="${paramValues.rol}">
    <c:set var="rolesSel" value="${rolesSel}${marcado}," />
  </c:forEach>
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
    <c:when test="${empty fn:trim(param.documento) || empty fn:trim(param.nombres) || empty fn:trim(param.apellidos) || empty fn:trim(param.usuario) || empty param.contrasena}">
      <c:set var="error" value="Completa todos los campos obligatorios." />
    </c:when>
    <c:when test="${fn:length(param.contrasena) < 6}">
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
            INSERT INTO usuario (documento, codigo, nombres, apellidos, usuario, contrasena)
            VALUES (?, NULLIF(?, ''), ?, ?, ?, SHA2(?, 256))
            <sql:param value="${fn:trim(param.documento)}" />
            <sql:param value="${esEstudiante ? fn:trim(param.codigo) : ''}" />
            <sql:param value="${fn:trim(param.nombres)}" />
            <sql:param value="${fn:trim(param.apellidos)}" />
            <sql:param value="${fn:trim(param.usuario)}" />
            <sql:param value="${param.contrasena}" />
          </sql:update>
          <c:forEach var="x" items="${roles.rows}">
            <c:set var="clave" value=",${x.nombre}," />
            <c:if test="${fn:contains(rolesSel, clave)}">
              <sql:update>
                INSERT INTO usuario_rol (id_usuario, id_rol)
                SELECT u.id_usuario, r.id_rol FROM usuario u, rol r
                WHERE u.usuario = ? AND r.nombre = ?
                <sql:param value="${fn:trim(param.usuario)}" />
                <sql:param value="${x.nombre}" />
              </sql:update>
            </c:if>
          </c:forEach>
        </sql:transaction>
      </c:catch>
      <c:choose>
        <c:when test="${empty fallo}">
          <c:set var="mensaje" value="Usuario registrado correctamente." scope="session" />
          <c:redirect url="/admin/usuarios.jsp" />
        </c:when>
        <c:when test="${fn:contains(fallo.message, 'Duplicate')}">
          <c:set var="error" value="Ya existe un usuario con ese documento, nombre de usuario o código." />
        </c:when>
        <c:otherwise>
          <c:set var="error" value="No se pudo registrar: ${fallo.message}" />
        </c:otherwise>
      </c:choose>
    </c:otherwise>
  </c:choose>
</c:if>

<c:set var="titulo" value="Registrar usuario" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Registrar usuario</h1>
  <c:if test="${not empty error}"><p class="error"><c:out value="${error}" /></p></c:if>

  <form method="post" action="usuario_nuevo.jsp">
    <label for="documento">Documento *</label>
    <input type="text" id="documento" name="documento" maxlength="20" required value="<c:out value='${param.documento}' />">

    <label for="nombres">Nombres *</label>
    <input type="text" id="nombres" name="nombres" maxlength="80" required value="<c:out value='${param.nombres}' />">

    <label for="apellidos">Apellidos *</label>
    <input type="text" id="apellidos" name="apellidos" maxlength="80" required value="<c:out value='${param.apellidos}' />">

    <label for="usuario">Usuario *</label>
    <input type="text" id="usuario" name="usuario" maxlength="40" required value="<c:out value='${param.usuario}' />">

    <label for="contrasena">Contraseña * (mínimo 6 caracteres)</label>
    <input type="password" id="contrasena" name="contrasena" required>

    <label>Rol *</label>
    <div class="opciones">
      <c:forEach var="x" items="${roles.rows}">
        <c:set var="clave" value=",${x.nombre}," />
        <label class="opcion">
          <input type="checkbox" name="rol" value="${x.nombre}" ${fn:contains(rolesSel, clave) ? 'checked' : ''}>
          <c:out value="${x.nombre}" />
        </label>
      </c:forEach>
    </div>
    <p class="suave">Solo un docente puede tener dos roles: Director y Evaluador.</p>

    <label for="codigo">Código estudiantil (solo estudiantes)</label>
    <input type="text" id="codigo" name="codigo" maxlength="20" value="<c:out value='${param.codigo}' />">

    <button type="submit">Registrar</button>
    <a class="boton secundario" href="usuarios.jsp">Cancelar</a>
  </form>
</section>

<%@ include file="/includes/pie.jsp" %>
