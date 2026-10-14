<%--
  conexion.ejemplo.jsp - Plantilla SIN clave real (esta si va a GitHub).
  Copiela como conexion.jsp y reemplace TU_CLAVE en su equipo.
--%>
<sql:setDataSource var="bd"
    driver="com.mysql.cj.jdbc.Driver"
    url="jdbc:mysql://127.0.0.1:3306/trabajos_grado?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=America/Bogota&characterEncoding=UTF-8"
    user="root"
    password="TU_CLAVE" />
