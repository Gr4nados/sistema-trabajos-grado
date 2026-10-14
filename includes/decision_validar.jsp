<%--
  decision_validar.jsp - Valida el formulario de decision de director y evaluador.
  Se incluye dentro de la pagina (comparte taglibs y variables). Lee:
    param.decision     aprobar | rechazar | aplazar
    param.calificacion 0.0 a 5.0 (supuesto, PENDIENTES.md #4); acepta coma o punto
    param.comentario   obligatorio si no se aprueba
  Deja: resultado (Aprobado|Rechazado|Aplazado), nota (numero), comentario (texto)
  y "errorDecision" si algo falla.
--%>
<c:remove var="errorDecision" />
<c:remove var="resultado" />
<c:remove var="nota" />
<c:set var="comentario" value="${fn:trim(param.comentario)}" />
<c:set var="notaTxt" value="${fn:replace(fn:trim(param.calificacion), ',', '.')}" />
<c:choose>
  <c:when test="${param.decision == 'aprobar'}"><c:set var="resultado" value="Aprobado" /></c:when>
  <c:when test="${param.decision == 'rechazar'}"><c:set var="resultado" value="Rechazado" /></c:when>
  <c:when test="${param.decision == 'aplazar'}"><c:set var="resultado" value="Aplazado" /></c:when>
  <c:otherwise><c:set var="errorDecision" value="Escoge una decisión." /></c:otherwise>
</c:choose>
<c:if test="${empty errorDecision}">
  <c:catch var="notaMala">
    <fmt:parseNumber var="nota" value="${notaTxt}" type="number" parseLocale="en_US" />
  </c:catch>
  <c:choose>
    <c:when test="${empty notaTxt || not empty notaMala || empty nota || nota < 0 || nota > 5}">
      <c:set var="errorDecision" value="Escribe una calificación entre 0.0 y 5.0." />
    </c:when>
    <c:when test="${resultado != 'Aprobado' && empty comentario}">
      <c:set var="errorDecision" value="Para rechazar o aplazar debes escribir el motivo." />
    </c:when>
  </c:choose>
</c:if>
