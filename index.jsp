<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- Punto de entrada: manda a cada usuario a su inicio, o al login si no hay sesion. --%>
<c:choose>
  <c:when test="${empty sessionScope.idUsuario}"><c:redirect url="/login.jsp" /></c:when>
  <c:when test="${empty sessionScope.rol}"><c:redirect url="/elegir_rol.jsp" /></c:when>
  <c:otherwise><%@ include file="/includes/ir_inicio.jsp" %></c:otherwise>
</c:choose>
