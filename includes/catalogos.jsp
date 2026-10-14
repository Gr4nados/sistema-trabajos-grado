<%--
  catalogos.jsp - Listas fijas que reflejan los ENUM de la base de datos.
  Uso: <%@ include file="/includes/catalogos.jsp" %>  (requiere la taglib c)
  Para validar: <c:set var="clave" value="|${param.modalidad}|" /> y fn:contains(listaMod, clave)
--%>
<c:set var="modalidades" value="Desarrollo tecnológico|Emprendimiento|Monografía|Proyecto de investigación" />
<c:set var="listaMod" value="|${modalidades}|" />
