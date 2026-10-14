<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<c:set var="rolRequerido" value="Administrador" />
<%@ include file="/includes/seguridad.jsp" %>
<%@ include file="/includes/conexion.jsp" %>
<c:set var="titulo" value="Inicio" />
<%@ include file="/includes/cabecera.jsp" %>

<section class="tarjeta">
  <h1>Bienvenido, <c:out value="${sessionScope.nombreCompleto}" /></h1>
  <p class="suave">Aquí podrás registrar y gestionar los usuarios del sistema.</p>
</section>

<%@ include file="/includes/recordatorios.jsp" %>
<%@ include file="/includes/pie.jsp" %>
