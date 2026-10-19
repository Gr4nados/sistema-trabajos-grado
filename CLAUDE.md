# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Sistema de Trabajos de Grado: una webapp de JSP + JSTL que guía un proyecto de grado por 6 fases entre cinco roles (Administrador, Estudiante, Coordinador, Director, Evaluador). Interfaz, comentarios y mensajes están en español; mantén ese idioma.

## Ejecutar y verificar

No hay build, lint ni pruebas automáticas. La carpeta del repo **es** la webapp desplegada: Tomcat (XAMPP) la sirve desde `C:\xampp\tomcat\webapps\TrabajosGrado`, así que editar un `.jsp` y recargar basta (Tomcat recompila solo).

- Iniciar Tomcat: `C:\xampp\catalina_start.bat`. URL: `http://localhost:8080/TrabajosGrado/login.jsp`. MySQL 8 debe estar en el puerto 3306.
- Base de datos: ejecutar `sql/trabajos_grado.sql` (**borra y recrea** `trabajos_grado`). Una base creada con una versión anterior se actualiza **sin perder datos** con `sql/migracion_v0.8.sql` y luego `sql/migracion_v0.9.sql` (una sola vez cada una). Todo cambio de esquema se refleja en las dos. Administrador de arranque: `admin` / `admin123`.
- El cliente `mysql.exe` de XAMPP no puede autenticarse contra este servidor (`caching_sha2_password`); usar `C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe`.
- `includes/conexion.jsp` está en `.gitignore` (lleva la clave de MySQL). Si falta, copiar `includes/conexion.ejemplo.jsp` y poner la clave.
- Verificación sin tocar datos: pedir la página con `curl` sin sesión. Un 302 hacia el login significa que **compiló**; un 500 es error de JSP. Las expresiones EL solo se evalúan con sesión (probar con `admin`). Validar SQL nuevo con `EXPLAIN`.
- `docs/recorrido_pruebas.md` es el recorrido manual de ocho pasos entre roles (RNF-11).

## Restricciones de tecnología (RNF-01/02)

Solo JSP + JSTL (`c`, `sql`, `fmt`, `fn`). **Sin Servlets, scriptlets, JavaBeans/DAO, Maven ni Node.js.** El acceso a MySQL es con las etiquetas `sql:` de JSTL. JavaScript solo del lado del cliente (`js/app.js`). Archivos y recibos se registran como **URL**; el sistema no recibe archivos.

## Arquitectura

**Estructura de cada página.** Una carpeta por rol (`admin/`, `estudiante/`, `coordinador/`, `director/`, `evaluador/`). Cada página sigue el mismo esqueleto, en este orden:
1. taglibs y `fmt:requestEncoding`;
2. `<c:set var="rolRequerido" .../>` + `includes/seguridad.jsp` (sin sesión → login; rol distinto → `index.jsp`) antes de cualquier HTML;
3. `includes/conexion.jsp` (define la fuente `bd`);
4. procesamiento del POST en la misma página, con `c:redirect` al terminar (patrón post/redirect/get);
5. consultas de lectura, `<c:set var="titulo" .../>` y `includes/cabecera.jsp` (abre HTML, menú lateral, barra superior);
6. contenido y `includes/pie.jsp`.

Los includes son estáticos (`<%@ include %>`): comparten taglibs y variables con la página que los incluye. Otros: `menu.jsp` (menú por rol; resalta la página activa con `servletPath`), `recordatorios.jsp`, `insignia.jsp` (estado → etiqueta de color; se usa con `valorInsignia`), `decision_validar.jsp` (nota y motivo de director/evaluador), `catalogos.jsp`, `ir_inicio.jsp`.

**Sesión.** `login.jsp` guarda `idUsuario`, `nombreCompleto`, `rol`, `cantidadRoles` y `rolesUsuario`. Un docente puede ser Director y Evaluador (`elegir_rol.jsp`). Contraseñas con `SHA2(...,256)`. Los mensajes de una sola vez van en `sessionScope.mensaje` / `mensajeTipo` y los consume `cabecera.jsp`.

**Máquina de estados del proyecto** (tabla `proyecto`: `fase` 1–6 y `estado`):
- Fase 1: el estudiante elige idea + URL del recibo; el coordinador la asigna escribiendo el **radicado** (único, obligatorio; → fase 2) o la rechaza (se libera `id_idea`; sigue en fase 1).
- Nombres de fase: 1 Pago, 2 Propuesta I, 3 Propuesta II, 4 Informe I, 5 Informe II, 6 Fase final. *Anteproyecto* (justifica la idea) e *Informe* (la investigación a fondo) son documentos distintos, ambos por URL.
- Fases 2 y 4: el estudiante registra el documento (`Anteproyecto` en 2, `Informe` en 4); el director califica. Aprobar → fase+1.
- Fase 3: el evaluador califica; **al aprobar avanza a la fase 4** (el coordinador no interviene).
- Fase 5: el evaluador califica y **`estado = 'Aprobado'` en la fase 5 significa "aprobado por el evaluador, espera la aprobación final del coordinador"**. El coordinador acepta (→ fase 6, estado `Aprobado`) o rechaza.
- Fase 6: el coordinador programa la sustentación (`proyecto.sustentacion_fecha`/`sustentacion_lugar`, aviso tipo `Sustentación`); el estudiante puede solicitar sus papeles.
- Un rechazo o aplazamiento **no cierra** el proyecto: conserva la fase, el estado queda `Rechazado`/`Aplazado` y el estudiante registra otra versión, que lo devuelve a `En revisión`.
- Cada decisión se inserta en `revision` (RNF-08). Cada URL nueva en `documento` es una versión nueva (versión = MAX + 1 por proyecto y tipo; nunca se sobrescribe).
- Los avisos (`recordatorio`, tipos `Sin revisar` y `Fecha límite`) se cierran (`vigente = FALSE`) y se crean en las mismas transacciones que cambian el estado.

**El estudiante no ve al evaluador (RNF-06).** El estudiante lee el proyecto por la vista `vista_proyecto_estudiante` (solo trae al director) y en `estudiante/calificaciones.jsp` la revisión del evaluador sale como "Evaluación", sin nombre. No agregar consultas del estudiante que traigan `id_evaluador` para mostrarlo.

**Banco de ideas.** `idea.disponibilidad`: `Pendiente` (idea de un docente a la espera del coordinador) → `Disponible` / `Rechazada` (con `motivo_rechazo`); `Asignada` cuando un proyecto la toma. Las ideas de estudiantes nacen `Disponible`. El estudiante solo ve `Disponible` y `Asignada`; el coordinador gestiona todo en `coordinador/banco_ideas.jsp`.

**Integridad en la base.** `ck_fase` (1–6), `ck_director_evaluador` (director ≠ evaluador), `proyecto.id_idea` único (una idea, un proyecto) y `ck_calificacion` (0–5), `proyecto.radicado` único. Un estudiante tiene un solo proyecto (cuenta cualquier proyecto en `integrante`).

## Convenciones de código

- Parámetros siempre con `<sql:param>` (nunca concatenar); toda salida con `<c:out>` (excepto valores controlados por el sistema).
- Cambios de varias tablas dentro de `<sql:transaction>` envuelto en `<c:catch var="fallo">`.
- En un `UPDATE` de MySQL las asignaciones se evalúan de izquierda a derecha: poner `estado = IF(fase + 1 = 6, ...)` **antes** de `fase = fase + 1`.
- Borrar un usuario con registros asociados lo desactiva (`activo = FALSE`); la base no tiene `ON DELETE CASCADE`, así que borrar un proyecto exigiría eliminar a mano `recordatorio`, `revision`, `documento` e `integrante` (y devolver la idea a `Disponible`).
- Los enlaces de la universidad viven en la tabla `enlace` y se muestran en `enlaces.jsp` (una opción del menú lateral); para agregar uno, insertarlo en esa tabla (y en `trabajos_grado.sql`).
- Los enlaces a `css/estilo.css` y `js/app.js` llevan `?v=X.Y.Z` (en `cabecera.jsp`, `login.jsp` y `elegir_rol.jsp`) para que el navegador no use una copia vieja: **súbelo al cambiar el CSS o el JS**.
- Estilos en `css/estilo.css` (variables de la paleta UTS: verde, lima, morado). Iconos: sprite SVG en `cabecera.jsp`.

## Documentación del proyecto

- `PENDIENTES.md`: supuestos pendientes de confirmar con el profesor. Todo supuesto nuevo se agrega ahí.
- `CHANGELOG.md`: una entrada por versión (`v0.N`). Los commits llevan el prefijo `vN.N:` y se hacen por bloques grandes de avance, **solo cuando el usuario lo pide**.
- `Ruta.md`: lista de tareas pendientes que mantiene el usuario (no editarla sin que lo pida).
- Fuente de requisitos: requerimientos RF-01…RF-28 y RNF-01…RNF-12 (citados en los comentarios de cada página).
