<%--
  insignia.jsp - Muestra un estado como etiqueta de color. Uso:
    <c:set var="valorInsignia" value="${f.estado}" />
    <%@ include file="/includes/insignia.jsp" %>
--%>
<c:choose>
  <c:when test="${valorInsignia == 'Aprobado' || valorInsignia == 'Disponible' || valorInsignia == 'Activo'}"><c:set var="claseInsignia" value="ok" /></c:when>
  <c:when test="${valorInsignia == 'Rechazado' || valorInsignia == 'Rechazada' || valorInsignia == 'Inactivo'}"><c:set var="claseInsignia" value="mal" /></c:when>
  <c:when test="${valorInsignia == 'Aplazado' || valorInsignia == 'Pendiente'}"><c:set var="claseInsignia" value="medio" /></c:when>
  <c:when test="${valorInsignia == 'En revisión' || valorInsignia == 'Asignada'}"><c:set var="claseInsignia" value="info" /></c:when>
  <c:otherwise><c:set var="claseInsignia" value="neutro" /></c:otherwise>
</c:choose>
<span class="insignia ${claseInsignia}"><c:out value="${valorInsignia}" /></span>
