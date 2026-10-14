<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- Cierra la sesion: elimina todos los datos del usuario. --%>
<c:remove var="idUsuario" scope="session" />
<c:remove var="nombreCompleto" scope="session" />
<c:remove var="rolesUsuario" scope="session" />
<c:remove var="cantidadRoles" scope="session" />
<c:remove var="rol" scope="session" />
<c:redirect url="/login.jsp" />
