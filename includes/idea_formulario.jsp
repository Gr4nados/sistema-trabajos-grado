<%--
  idea_formulario.jsp - Formulario y proceso para proponer una idea (RF-05).
  Lo comparten director/idea_nueva.jsp y estudiante/idea_nueva.jsp.
  La pagina que lo incluye ya hizo: taglibs c, sql, fmt, fn, seguridad, conexion, catalogos,
  y define la variable "destino" (a donde ir tras guardar).
  La idea de un docente (Director/Evaluador) nace "Pendiente" hasta que el coordinador la acepte
  (pasa a "Disponible") o la rechace; la de un estudiante nace "Disponible" (PENDIENTES.md #13).
--%>
<c:set var="esDocente" value="${sessionScope.rol != 'Estudiante'}" />
<c:set var="estadoIdea" value="${esDocente ? 'Pendiente' : 'Disponible'}" />
<c:if test="${pageContext.request.method == 'POST'}">
  <c:set var="claveMod" value="|${param.modalidad}|" />
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
    <c:otherwise>
      <c:catch var="fallo">
        <sql:update dataSource="${bd}">
          INSERT INTO idea (titulo, modalidad, objetivo_general, linea_investigacion, nivel,
                            periodo_academico, disponibilidad, id_proponente)
          VALUES (?, ?, ?, NULLIF(?, ''), ?, ?, ?, ?)
          <sql:param value="${fn:trim(param.titulo)}" />
          <sql:param value="${param.modalidad}" />
          <sql:param value="${fn:trim(param.objetivo_general)}" />
          <sql:param value="${fn:trim(param.linea_investigacion)}" />
          <sql:param value="${param.nivel}" />
          <sql:param value="${fn:trim(param.periodo_academico)}" />
          <sql:param value="${estadoIdea}" />
          <sql:param value="${sessionScope.idUsuario}" />
        </sql:update>
      </c:catch>
      <c:choose>
        <c:when test="${empty fallo}">
          <c:set var="mensaje" value="${esDocente ? 'Idea enviada: queda pendiente de aceptación del coordinador.' : 'Idea guardada correctamente.'}" scope="session" />
          <c:redirect url="${destino}" />
        </c:when>
        <c:otherwise>
          <c:set var="error" value="No se pudo guardar la idea: ${fallo.message}" />
        </c:otherwise>
      </c:choose>
    </c:otherwise>
  </c:choose>
</c:if>

<c:set var="titulo" value="Proponer idea" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Proponer una idea</h1>
  <c:if test="${not empty error}"><p class="error"><c:out value="${error}" /></p></c:if>

  <form method="post" action="${pageContext.request.requestURI}">
    <label for="titulo">Título *</label>
    <input type="text" id="titulo" name="titulo" maxlength="200" required value="<c:out value='${param.titulo}' />">

    <label for="modalidad">Modalidad *</label>
    <select id="modalidad" name="modalidad" required>
      <option value="">Selecciona...</option>
      <c:forTokens var="m" items="${modalidades}" delims="|">
        <option value="${m}" ${m == param.modalidad ? 'selected' : ''}><c:out value="${m}" /></option>
      </c:forTokens>
    </select>

    <label for="objetivo_general">Objetivo general *</label>
    <textarea id="objetivo_general" name="objetivo_general" rows="4" required><c:out value="${param.objetivo_general}" /></textarea>

    <label for="linea_investigacion">Línea de investigación</label>
    <input type="text" id="linea_investigacion" name="linea_investigacion" maxlength="120"
           value="<c:out value='${param.linea_investigacion}' />">

    <label for="nivel">Nivel *</label>
    <select id="nivel" name="nivel" required>
      <option value="">Selecciona...</option>
      <option value="Tecnológico" ${param.nivel == 'Tecnológico' ? 'selected' : ''}>Tecnológico</option>
      <option value="Profesional" ${param.nivel == 'Profesional' ? 'selected' : ''}>Profesional</option>
    </select>

    <label for="periodo_academico">Período académico * (ej. 2026-2)</label>
    <input type="text" id="periodo_academico" name="periodo_academico" maxlength="10" required
           value="<c:out value='${param.periodo_academico}' />">

    <label>Disponibilidad</label>
    <p class="suave"><c:choose>
      <c:when test="${esDocente}">Al guardar, la idea queda <strong>Pendiente</strong> hasta que el coordinador la acepte para el banco.</c:when>
      <c:otherwise>Al guardar, la idea queda <strong>Disponible</strong> en el banco.</c:otherwise>
    </c:choose></p>

    <button type="submit">Guardar idea</button>
    <a class="boton secundario" href="${pageContext.request.contextPath}${destino}">Cancelar</a>
  </form>
</section>

<%@ include file="/includes/pie.jsp" %>
