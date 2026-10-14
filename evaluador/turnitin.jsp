<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Evaluador" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%-- RF-28: Turnitin es solo una pantalla visual por ahora; no se conecta a ningun servicio. --%>
<c:set var="titulo" value="Turnitin" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Turnitin</h1>
  <p class="suave">Pantalla ilustrativa: todavía no está conectada a ningún servicio de similitud.</p>
  <label for="docTurnitin">URL del documento</label>
  <input type="url" id="docTurnitin" placeholder="https://..." disabled>
  <button type="button" disabled>Analizar similitud</button>
</section>

<section class="tarjeta">
  <h2>Resultado (ejemplo)</h2>
  <table>
    <tr><th>Índice de similitud</th><td>--- %</td></tr>
    <tr><th>Fuentes coincidentes</th><td>---</td></tr>
    <tr><th>Estado del análisis</th><td>Sin analizar</td></tr>
  </table>
</section>

<%@ include file="/includes/pie.jsp" %>
