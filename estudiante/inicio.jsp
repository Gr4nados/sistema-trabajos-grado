<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Estudiante" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<c:set var="titulo" value="Inicio" />
<%@ include file="/includes/cabecera.jsp" %>

<%-- La vista nunca incluye al evaluador (RNF-06) --%>
<sql:query var="proy" dataSource="${bd}">
  SELECT * FROM vista_proyecto_estudiante
  WHERE id_estudiante = ? ORDER BY id_proyecto DESC LIMIT 1
  <sql:param value="${sessionScope.idUsuario}" />
</sql:query>

<section class="tarjeta">
  <h1>Bienvenido, <c:out value="${sessionScope.nombreCompleto}" /></h1>
</section>

<section class="tarjeta">
  <h2>Estado de tu proyecto</h2>
  <c:choose>
    <c:when test="${proy.rowCount == 0}">
      <p class="suave">Aún no tienes un proyecto.</p>
      <a class="boton" href="proyecto_nuevo.jsp"><svg class="ico"><use href="#i-mas"/></svg>Crear mi proyecto</a>
    </c:when>
    <c:otherwise>
      <c:set var="p" value="${proy.rows[0]}" />
      <%-- Las 6 fases como tarjetas: nombre;descripcion;icono. Hechas = check; actual = resaltada. --%>
      <div class="fases">
        <c:forTokens var="item" items="Pago;El estudiante describe su idea y sube el pago;pago|Propuesta I;El estudiante envía la propuesta al director;doc|Propuesta II;El director envía la propuesta al evaluador;avion|Informe I;El estudiante envía el informe al director;doc|Informe II;El director envía el informe al evaluador y al coordinador;avion|Fase final;Estudiante(s), director y evaluador programan la sustentación;birrete" delims="|" varStatus="v">
          <c:set var="parte" value="${fn:split(item, ';')}" />
          <c:set var="hecha" value="${v.count < p.fase}" />
          <div class="fase-tarjeta ${hecha ? 'hecha' : (v.count == p.fase ? 'actual' : '')}">
            <svg class="ico-grande"><use href="#i-${hecha ? 'check' : (v.count == p.fase && v.count < 6 ? 'reloj' : parte[2])}"/></svg>
            <strong>Fase <c:out value="${v.count}" />: <c:out value="${parte[0]}" /></strong>
            <span><c:out value="${parte[1]}" /></span>
            <c:if test="${v.count <= p.fase}">
              <a class="ojo" href="${v.count == 1 ? 'asignar_idea.jsp' : (v.count == 6 ? 'calificaciones.jsp' : 'documentos.jsp')}" title="Ver"><svg class="ico"><use href="#i-ojo"/></svg></a>
            </c:if>
          </div>
        </c:forTokens>
      </div>
      <table>
        <c:if test="${not empty p.radicado}"><tr><th>Radicado</th><td><c:out value="${p.radicado}" /></td></tr></c:if>
        <tr><th>Modalidad</th><td><c:out value="${p.modalidad}" /></td></tr>
        <tr><th>Idea</th><td><c:out value="${empty p.idea_titulo ? 'Sin asignar' : p.idea_titulo}" /></td></tr>
        <tr><th>Fase</th><td><c:out value="${p.fase}" /> de 6</td></tr>
        <tr><th>Estado</th><td><c:set var="valorInsignia" value="${p.estado}" /><%@ include file="/includes/insignia.jsp" %></td></tr>
        <tr><th>Director</th><td>
          <c:choose>
            <c:when test="${empty p.director_nombres}">Sin asignar</c:when>
            <c:otherwise><c:out value="${p.director_nombres} ${p.director_apellidos}" /></c:otherwise>
          </c:choose>
        </td></tr>
        <c:if test="${p.fase == 1 && empty p.idea_titulo}">
          <tr><th>Siguiente paso</th><td><a class="boton pequeno" href="asignar_idea.jsp">Escoger idea y registrar el recibo de pago</a></td></tr>
        </c:if>
        <c:if test="${p.fase >= 2 && p.fase <= 5}">
          <tr><th>Siguiente paso</th><td>
            <c:choose>
              <c:when test="${empty p.director_nombres}">Esperar a que el coordinador asigne tu director</c:when>
              <c:when test="${p.estado == 'Rechazado' || p.estado == 'Aplazado'}">
                Te devolvieron el documento.
                <div class="acciones-fila"><a class="boton pequeno contorno" href="calificaciones.jsp">Ver calificaciones</a>
                <a class="boton pequeno" href="documentos.jsp">Registrar nueva versión</a></div></c:when>
              <c:when test="${p.estado == 'Aprobado'}">Esperar la aprobación final del coordinador</c:when>
              <c:when test="${p.fase == 2}"><a class="boton pequeno" href="documentos.jsp">Registrar o revisar la URL de tu anteproyecto</a></c:when>
              <c:when test="${p.fase == 4}"><a class="boton pequeno" href="documentos.jsp">Registrar o revisar la URL de tu informe</a></c:when>
              <c:otherwise>Tu documento está en evaluación por el evaluador</c:otherwise>
            </c:choose>
          </td></tr>
        </c:if>
        <c:if test="${not empty p.fecha_limite}">
          <tr><th>Fecha límite</th><td><c:out value="${p.fecha_limite}" /></td></tr>
        </c:if>
      </table>
      <c:if test="${p.fase == 6}">
        <%-- RF-14: papeles de grado (la vista no trae esta columna; no incluye al evaluador) --%>
        <sql:query var="papeles" dataSource="${bd}">
          SELECT papeles_solicitados, sustentacion_fecha, DATE_FORMAT(sustentacion_fecha, '%d/%m/%Y %H:%i') AS sustentacion_txt, sustentacion_lugar FROM proyecto WHERE id_proyecto = ?
          <sql:param value="${p.id_proyecto}" />
        </sql:query>
        <p><svg class="ico"><use href="#i-calendario"/></svg> <strong>Sustentación:</strong>
          <c:choose>
            <c:when test="${empty papeles.rows[0].sustentacion_fecha}">por programar (el coordinador la definirá).</c:when>
            <c:otherwise><c:out value="${papeles.rows[0].sustentacion_txt}" />
              <c:if test="${not empty papeles.rows[0].sustentacion_lugar}"> · <c:out value="${papeles.rows[0].sustentacion_lugar}" /></c:if></c:otherwise>
          </c:choose></p>
        <c:choose>
          <c:when test="${papeles.rows[0].papeles_solicitados}">
            <p class="exito">Ya solicitaste tus papeles de grado.</p>
          </c:when>
          <c:otherwise>
            <p>¡Tu proceso finalizó!</p>
            <form method="post" action="solicitar_papeles.jsp">
              <button type="submit">Solicitar papeles de grado</button>
            </form>
          </c:otherwise>
        </c:choose>
      </c:if>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/includes/recordatorios.jsp" %>
<%@ include file="/includes/pie.jsp" %>
