<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Coordinador" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%@ include file="/includes/catalogos.jsp" %>
<%--
  Edita una idea del banco (Ruta.md, actualizacion 5). Si la idea esta ligada a un proyecto,
  su disponibilidad no se puede cambiar (queda como esta).
--%>
<sql:query var="res" dataSource="${bd}">
  SELECT i.*, (SELECT p.id_proyecto FROM proyecto p WHERE p.id_idea = i.id_idea) AS id_proyecto
  FROM idea i WHERE i.id_idea = ?
  <sql:param value="${param.id}" />
</sql:query>
<c:if test="${res.rowCount == 0}">
  <c:set var="mensaje" value="La idea no existe." scope="session" />
  <c:set var="mensajeTipo" value="error" scope="session" />
  <c:redirect url="/coordinador/banco_ideas.jsp" />
</c:if>
<c:set var="i" value="${res.rows[0]}" />
<c:set var="ligada" value="${not empty i.id_proyecto}" />
<c:set var="esPost" value="${pageContext.request.method == 'POST'}" />

<c:if test="${esPost}">
  <c:set var="claveMod" value="|${param.modalidad}|" />
  <c:set var="dispNueva" value="${ligada ? i.disponibilidad : param.disponibilidad}" />
  <c:choose>
    <c:when test="${empty fn:trim(param.titulo) || empty fn:trim(param.objetivo_general) || empty fn:trim(param.periodo_academico)}">
      <c:set var="error" value="Completa título, objetivo general y período académico." />
    </c:when>
    <c:when test="${fn:length(fn:trim(param.titulo)) > 200 || fn:length(fn:trim(param.periodo_academico)) > 10 || fn:length(param.linea_investigacion) > 120}">
      <c:set var="error" value="Alguno de los campos supera la longitud permitida." />
    </c:when>
    <c:when test="${!fn:contains(listaMod, claveMod)}">
      <c:set var="error" value="Selecciona una modalidad válida." />
    </c:when>
    <c:when test="${param.nivel != 'Tecnológico' && param.nivel != 'Profesional'}">
      <c:set var="error" value="Selecciona un nivel válido." />
    </c:when>
    <c:when test="${dispNueva != 'Pendiente' && dispNueva != 'Disponible' && dispNueva != 'Asignada' && dispNueva != 'Rechazada'}">
      <c:set var="error" value="Selecciona la disponibilidad." />
    </c:when>
    <c:otherwise>
      <c:catch var="fallo">
        <sql:update dataSource="${bd}">
          UPDATE idea SET titulo = ?, modalidad = ?, objetivo_general = ?, linea_investigacion = NULLIF(?, ''),
                 nivel = ?, periodo_academico = ?, disponibilidad = ?,
                 motivo_rechazo = IF(? = 'Rechazada', motivo_rechazo, NULL)
          WHERE id_idea = ?
          <sql:param value="${fn:trim(param.titulo)}" />
          <sql:param value="${param.modalidad}" />
          <sql:param value="${fn:trim(param.objetivo_general)}" />
          <sql:param value="${fn:trim(param.linea_investigacion)}" />
          <sql:param value="${param.nivel}" />
          <sql:param value="${fn:trim(param.periodo_academico)}" />
          <sql:param value="${dispNueva}" />
          <sql:param value="${dispNueva}" />
          <sql:param value="${i.id_idea}" />
        </sql:update>
      </c:catch>
      <c:choose>
        <c:when test="${empty fallo}">
          <c:set var="mensaje" value="Idea actualizada." scope="session" />
          <c:redirect url="/coordinador/banco_ideas.jsp" />
        </c:when>
        <c:otherwise><c:set var="error" value="No se pudo guardar la idea: ${fallo.message}" /></c:otherwise>
      </c:choose>
    </c:otherwise>
  </c:choose>
</c:if>

<%-- Valores del formulario: lo enviado si hubo error; si no, lo guardado --%>
<c:set var="vTitulo" value="${esPost ? param.titulo : i.titulo}" />
<c:set var="vModalidad" value="${esPost ? param.modalidad : i.modalidad}" />
<c:set var="vObjetivo" value="${esPost ? param.objetivo_general : i.objetivo_general}" />
<c:set var="vLinea" value="${esPost ? param.linea_investigacion : i.linea_investigacion}" />
<c:set var="vNivel" value="${esPost ? param.nivel : i.nivel}" />
<c:set var="vPeriodo" value="${esPost ? param.periodo_academico : i.periodo_academico}" />
<c:set var="vDisp" value="${esPost ? param.disponibilidad : i.disponibilidad}" />

<c:set var="titulo" value="Editar idea" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Editar idea #<c:out value="${i.id_idea}" /></h1>
  <c:if test="${not empty error}"><p class="error"><c:out value="${error}" /></p></c:if>

  <form method="post" action="idea_editar.jsp?id=${i.id_idea}">
    <label for="titulo">Título *</label>
    <input type="text" id="titulo" name="titulo" maxlength="200" required value="<c:out value='${vTitulo}' />">

    <label for="modalidad">Modalidad *</label>
    <select id="modalidad" name="modalidad" required>
      <c:forTokens var="m" items="${modalidades}" delims="|">
        <option value="${m}" ${m == vModalidad ? 'selected' : ''}><c:out value="${m}" /></option>
      </c:forTokens>
    </select>

    <label for="objetivo_general">Objetivo general *</label>
    <textarea id="objetivo_general" name="objetivo_general" rows="4" required><c:out value="${vObjetivo}" /></textarea>

    <label for="linea_investigacion">Línea de investigación</label>
    <input type="text" id="linea_investigacion" name="linea_investigacion" maxlength="120" value="<c:out value='${vLinea}' />">

    <label for="nivel">Nivel *</label>
    <select id="nivel" name="nivel" required>
      <option value="Tecnológico" ${vNivel == 'Tecnológico' ? 'selected' : ''}>Tecnológico</option>
      <option value="Profesional" ${vNivel == 'Profesional' ? 'selected' : ''}>Profesional</option>
    </select>

    <label for="periodo_academico">Período académico * (ej. 2026-2)</label>
    <input type="text" id="periodo_academico" name="periodo_academico" maxlength="10" required value="<c:out value='${vPeriodo}' />">

    <label for="disponibilidad">Disponibilidad</label>
    <c:choose>
      <c:when test="${ligada}">
        <p><c:set var="valorInsignia" value="${i.disponibilidad}" /><%@ include file="/includes/insignia.jsp" %>
          <span class="suave">No se puede cambiar: la idea está ligada al proyecto #<c:out value="${i.id_proyecto}" />.</span></p>
      </c:when>
      <c:otherwise>
        <select id="disponibilidad" name="disponibilidad" required>
          <c:forTokens var="d" items="Pendiente|Disponible|Asignada|Rechazada" delims="|">
            <option value="${d}" ${d == vDisp ? 'selected' : ''}><c:out value="${d}" /></option>
          </c:forTokens>
        </select>
      </c:otherwise>
    </c:choose>

    <button type="submit">Guardar cambios</button>
    <a class="boton secundario" href="banco_ideas.jsp">Cancelar</a>
  </form>
</section>

<%@ include file="/includes/pie.jsp" %>
