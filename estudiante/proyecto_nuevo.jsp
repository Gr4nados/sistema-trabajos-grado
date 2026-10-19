<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Estudiante" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%@ include file="/includes/catalogos.jsp" %>
<%--
  RF-07: boton "Nuevo proyecto". Modalidad + trabajo individual o en pareja.
  La pareja se vincula por numero de documento y debe tener cuenta de estudiante.
  El proyecto nace en la fase 1.
  Supuesto: un estudiante tiene un solo proyecto. Un rechazo no lo cierra: el proyecto conserva
  su fase y el estudiante corrige (PENDIENTES.md #6 y #16).
--%>
<sql:query var="enCurso" dataSource="${bd}">
  SELECT COUNT(*) AS n FROM integrante i WHERE i.id_usuario = ?
  <sql:param value="${sessionScope.idUsuario}" />
</sql:query>
<c:set var="yaTiene" value="${enCurso.rows[0].n > 0}" />

<c:if test="${pageContext.request.method == 'POST' && !yaTiene}">
  <c:set var="claveMod" value="|${param.modalidad}|" />
  <c:set var="enPareja" value="${param.trabajo == 'pareja'}" />
  <c:set var="docPareja" value="${fn:trim(param.documento_pareja)}" />

  <c:if test="${!fn:contains(listaMod, claveMod)}">
    <c:set var="error" value="Selecciona una modalidad válida." />
  </c:if>
  <c:if test="${empty error && param.trabajo != 'individual' && param.trabajo != 'pareja'}">
    <c:set var="error" value="Indica si trabajas solo o en pareja." />
  </c:if>
  <c:if test="${empty error && enPareja && empty docPareja}">
    <c:set var="error" value="Escribe el número de documento de tu pareja." />
  </c:if>

  <c:if test="${empty error && enPareja}">
    <sql:query var="pareja" dataSource="${bd}">
      SELECT u.id_usuario FROM usuario u
      JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario
      JOIN rol r ON r.id_rol = ur.id_rol
      WHERE u.documento = ? AND r.nombre = 'Estudiante' AND u.activo = TRUE
      <sql:param value="${docPareja}" />
    </sql:query>
    <c:choose>
      <c:when test="${pareja.rowCount == 0}">
        <c:set var="error" value="No existe un estudiante con ese documento. Tu pareja debe tener cuenta." />
      </c:when>
      <c:when test="${pareja.rows[0].id_usuario == sessionScope.idUsuario}">
        <c:set var="error" value="No puedes ser tu propia pareja." />
      </c:when>
      <c:otherwise>
        <c:set var="idPareja" value="${pareja.rows[0].id_usuario}" />
        <sql:query var="parejaEnCurso" dataSource="${bd}">
          SELECT COUNT(*) AS n FROM integrante i WHERE i.id_usuario = ?
          <sql:param value="${idPareja}" />
        </sql:query>
        <c:if test="${parejaEnCurso.rows[0].n > 0}">
          <c:set var="error" value="Tu pareja ya tiene un proyecto en curso." />
        </c:if>
      </c:otherwise>
    </c:choose>
  </c:if>

  <c:if test="${empty error}">
    <c:catch var="fallo">
      <sql:transaction dataSource="${bd}">
        <sql:update>
          INSERT INTO proyecto (modalidad) VALUES (?)
          <sql:param value="${param.modalidad}" />
        </sql:update>
        <sql:query var="nuevo">SELECT LAST_INSERT_ID() AS id</sql:query>
        <sql:update>
          INSERT INTO integrante (id_proyecto, id_usuario) VALUES (?, ?)
          <sql:param value="${nuevo.rows[0].id}" />
          <sql:param value="${sessionScope.idUsuario}" />
        </sql:update>
        <c:if test="${enPareja}">
          <sql:update>
            INSERT INTO integrante (id_proyecto, id_usuario) VALUES (?, ?)
            <sql:param value="${nuevo.rows[0].id}" />
            <sql:param value="${idPareja}" />
          </sql:update>
        </c:if>
      </sql:transaction>
    </c:catch>
    <c:choose>
      <c:when test="${empty fallo}">
        <c:set var="mensaje" value="Proyecto creado. Ahora asigna una idea y registra el recibo de pago." scope="session" />
        <c:redirect url="/estudiante/asignar_idea.jsp" />
      </c:when>
      <c:otherwise>
        <c:set var="error" value="No se pudo crear el proyecto: ${fallo.message}" />
      </c:otherwise>
    </c:choose>
  </c:if>
</c:if>

<c:set var="titulo" value="Nuevo proyecto" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Nuevo proyecto</h1>
  <c:choose>
    <c:when test="${yaTiene}">
      <p class="suave">Ya tienes un proyecto en curso. Puedes seguirlo desde tu inicio.</p>
      <a class="boton" href="inicio.jsp">Ir a mi inicio</a>
    </c:when>
    <c:otherwise>
      <c:if test="${not empty error}"><p class="error"><c:out value="${error}" /></p></c:if>
      <form method="post" action="proyecto_nuevo.jsp">
        <label for="modalidad">Modalidad *</label>
        <select id="modalidad" name="modalidad" required>
          <option value="">Selecciona...</option>
          <c:forTokens var="m" items="${modalidades}" delims="|">
            <option value="${m}" ${m == param.modalidad ? 'selected' : ''}><c:out value="${m}" /></option>
          </c:forTokens>
        </select>

        <label>Tipo de trabajo *</label>
        <div class="opciones">
          <label class="opcion">
            <input type="radio" name="trabajo" value="individual" required
                   ${param.trabajo != 'pareja' ? 'checked' : ''} onclick="document.getElementById('bloquePareja').hidden = true">
            Individual
          </label>
          <label class="opcion">
            <input type="radio" name="trabajo" value="pareja"
                   ${param.trabajo == 'pareja' ? 'checked' : ''} onclick="document.getElementById('bloquePareja').hidden = false">
            En pareja
          </label>
        </div>

        <div id="bloquePareja" ${param.trabajo == 'pareja' ? '' : 'hidden'}>
          <label for="documento_pareja">Documento de tu pareja</label>
          <input type="text" id="documento_pareja" name="documento_pareja" maxlength="20"
                 value="<c:out value='${param.documento_pareja}' />">
          <p class="suave">Tu pareja ya debe tener una cuenta de estudiante.</p>
        </div>

        <button type="submit">Crear proyecto</button>
        <a class="boton secundario" href="inicio.jsp">Cancelar</a>
      </form>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/includes/pie.jsp" %>
