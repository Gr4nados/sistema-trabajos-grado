<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Evaluador" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<%-- RF-28: rejilla de evaluacion solo visual por ahora; los campos no se guardan. --%>
<c:set var="titulo" value="Rejilla de evaluación" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Rejilla de evaluación</h1>
  <p class="suave">Pantalla ilustrativa: los criterios son de ejemplo y no se guardan. La calificación
    oficial se registra en <a href="anteproyectos.jsp">Anteproyectos</a>.</p>
  <table>
    <thead><tr><th>Criterio</th><th>Peso</th><th>Nota (0.0 a 5.0)</th></tr></thead>
    <tbody>
      <tr><td>Título y planteamiento del problema</td><td>15 %</td><td><input type="text" disabled placeholder="-"></td></tr>
      <tr><td>Objetivos</td><td>15 %</td><td><input type="text" disabled placeholder="-"></td></tr>
      <tr><td>Justificación</td><td>10 %</td><td><input type="text" disabled placeholder="-"></td></tr>
      <tr><td>Marco teórico y antecedentes</td><td>20 %</td><td><input type="text" disabled placeholder="-"></td></tr>
      <tr><td>Metodología</td><td>20 %</td><td><input type="text" disabled placeholder="-"></td></tr>
      <tr><td>Cronograma y presupuesto</td><td>10 %</td><td><input type="text" disabled placeholder="-"></td></tr>
      <tr><td>Referencias y redacción</td><td>10 %</td><td><input type="text" disabled placeholder="-"></td></tr>
      <tr><th>Total</th><th>100 %</th><th>---</th></tr>
    </tbody>
  </table>
</section>

<%@ include file="/includes/pie.jsp" %>
