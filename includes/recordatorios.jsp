<%--
  recordatorios.jsp - Avisos vigentes del usuario en sesion (RF-17).
  Solo se muestran en la interfaz; no hay correos.
--%>
<sql:query var="avisos" dataSource="${bd}">
  SELECT tipo, mensaje, fecha_limite FROM recordatorio
  WHERE id_usuario = ? AND vigente = TRUE ORDER BY id_recordatorio DESC
  <sql:param value="${sessionScope.idUsuario}" />
</sql:query>
<section class="tarjeta">
  <h2>Recordatorios</h2>
  <c:choose>
    <c:when test="${avisos.rowCount == 0}"><p class="suave">No tienes recordatorios.</p></c:when>
    <c:otherwise>
      <ul class="avisos">
        <c:forEach var="a" items="${avisos.rows}">
          <li>
            <strong><c:out value="${a.tipo}" />:</strong> <c:out value="${a.mensaje}" />
            <c:if test="${not empty a.fecha_limite}"> (hasta <c:out value="${a.fecha_limite}" />)</c:if>
          </li>
        </c:forEach>
      </ul>
    </c:otherwise>
  </c:choose>
</section>
