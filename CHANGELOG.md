# Changelog

## v0.9.1 - Correcciones tras la prueba completa
- Mensaje al aceptar una idea: mostraba `{radicado}` en lugar del número (una expresión dentro de otra no se evalúa). Ahora muestra, por ejemplo,
  "Idea asignada con el radicado 2026-001: el proyecto avanzó a la fase 2."
- Los campos de fecha y hora (`datetime-local`) tenían el aspecto por defecto del navegador; ahora usan el mismo estilo que el resto.
- `estudiante/documentos.jsp`: el botón "Eliminar documento" queda en la misma fila que los demás, con icono.
- `coordinador/ideas_pendientes.jsp`: las filas "Modalidad del proyecto" y "Modalidad de la idea" salían vacías (JSTL ignoraba los alias de columnas reales).
- Error 500 al programar una sustentación: `fmt:formatDate` no acepta las fechas que entrega el conector. Afectaba el inicio del estudiante,
  `coordinador/sustentaciones.jsp` y `coordinador/buscar.jsp`. Las fechas se formatean ahora en SQL (`DATE_FORMAT`).
- Las fechas de todas las pantallas se muestran como `14/10/2026 09:40` (antes `2026-10-14T09:40:42`).
- Prueba completa de punta a punta en un entorno aislado (107 comprobaciones: 6 fases, rechazos, aplazamientos, radicado, sustentación,
  papeles de grado, seguridad por rol y visibilidad del evaluador).

## v0.9 - Continuidad de las fases
- Fases con sus nombres: 1 Pago, 2 Propuesta I, 3 Propuesta II, 4 Informe I, 5 Informe II, 6 Fase final.
- **Fase 3:** decide solo el evaluador; al aprobar, el proyecto avanza a la fase 4 (antes esperaba al coordinador).
- **Fases 4 y 5:** el documento es el *informe* (tipo `Informe`, distinto del anteproyecto; también por URL y con versiones).
- **Fase 5:** el evaluador aprueba y el coordinador da la aprobación final (`coordinador/revisiones.jsp`, ahora solo fase 5).
- **Fase 6:** `coordinador/sustentaciones.jsp` programa fecha, hora y lugar; el estudiante, el director y el evaluador reciben un aviso.
- Inicio del estudiante: las 6 fases como tarjetas con iconos (hecha = check, actual = reloj de arena) y enlace "ver".
- Más iconos: nuevos símbolos y un icono en cada tarjeta de contadores.
- `enlaces.jsp`: una sola página con todos los enlaces de la universidad (tarjetas con iconos); el menú lateral queda con
  una opción "Enlaces de la universidad". Nuevos enlaces: Base documental, Valores pecuniarios y Reglamento estudiantil.
- `coordinador/revisiones.jsp`: además de la aprobación final, el coordinador ve en solo lectura los informes de las fases 4 y 5.
- Controles más modernos: las acciones que eran texto subrayado ahora son botones (con iconos de más, editar, papelera y volver); los filtros y "cuenta activa" son interruptores; las opciones (modalidad, trabajo individual o en pareja, roles) son etiquetas seleccionables; las listas desplegables tienen flecha propia; los enlaces a documentos son etiquetas con icono; los detalles desplegables llevan flecha.
- Esquema: `documento.tipo` suma `Informe`, `proyecto.sustentacion_fecha` y `sustentacion_lugar`, y `recordatorio.tipo` suma
  `Sustentación`. Una base existente se actualiza con `sql/migracion_v0.9.sql` (también pasa a la fase 4 los proyectos que
  esperaban al coordinador en la fase 3).

## v0.8 - Ajustes de Ruta.md
- Enlaces de la universidad: nuevo Calendario académico y Formatos de grado (Dropbox), y nuevo
  "Reglamento de trabajos de grado" (tabla `enlace`, mostrada en el menú).
- `coordinador/banco_ideas.jsp`: el coordinador ve todo el banco, acepta o rechaza (con motivo) las
  ideas de docentes, y edita (`coordinador/idea_editar.jsp`) o elimina ideas. No se elimina una idea ligada a un proyecto.
- Las ideas de docentes nacen "Pendiente" hasta que el coordinador las acepte; las de estudiantes siguen
  entrando directo como "Disponible". El estudiante solo ve ideas Disponibles o Asignadas.
  El docente ve en "Mis ideas" el estado y el motivo si fue rechazada.
- Radicado: lo escribe el coordinador al asignar la idea en `ideas_pendientes.jsp` (obligatorio y único) y
  puede completarlo o corregirlo en `asignar_director.jsp`. Se muestra al estudiante y en búsqueda, informes y revisiones.
- `perfil.jsp` ("Mi perfil"): datos del usuario, para todos los roles.
- Esquema: `idea.disponibilidad` suma Pendiente y Rechazada, `idea.motivo_rechazo`, `proyecto.radicado` (único) y la
  vista del estudiante incluye el radicado. Una base existente se actualiza con `sql/migracion_v0.8.sql`.

## v0.7 - Rediseño de interfaces
- Paleta de la universidad (verde oscuro, lima y morado sobre crema) y estilos nuevos en `css/estilo.css`.
- Menú lateral por rol, con iconos, grupos y la página activa resaltada; en celular se abre con un botón.
- Barra superior con el título de la página y el rol; el nombre y "Salir" quedan al pie del menú.
- Inicio de cada rol con contadores que enlazan a la tarea (coordinador, director, evaluador y administrador).
- Inicio del estudiante con el indicador de las 6 fases (los nombres de las fases 4 y 5 están por definir).
- Estados con etiquetas de color (`includes/insignia.jsp`) y recordatorios con etiqueta por tipo.
- Login y elección de rol con la mascota; animaciones suaves que respetan "reducir movimiento".
- `js/app.js`: menú en celular y mensajes de éxito que se ocultan solos (solo cliente, RNF-02).

## v0.6 - Consulta, informes y pantallas visuales
- `coordinador/buscar.jsp`: busca un estudiante por código o nombre y ve su proyecto (RF-24).
- `coordinador/informes.jsp`: estado de los proyectos por alumno, por director y por evaluador (RF-25).
- `evaluador/turnitin.jsp` y `evaluador/rejilla.jsp`: solo visuales, sin guardar nada (RF-28).
- Menús de todos los roles completos; `estudiante/inicio.jsp` indica el siguiente paso por fase.
- `docs/recorrido_pruebas.md`: recorrido de prueba de ocho pasos (RNF-11).

## v0.5 - Flujo de las fases 2 a 6
- `coordinador/asignar_director.jsp`: asigna director y evaluador (el estudiante no ve al evaluador)
  y, opcionalmente, una fecha límite que aparece como recordatorio (RF-10, RF-17).
- `estudiante/documentos.jsp`: registra, ve, edita (versión nueva) o elimina la URL del documento en
  las fases 2 a 5; `estudiante/versiones.jsp`: historial de versiones (RF-11, RF-16, RF-18).
- `director/anteproyectos.jsp`: ve los datos del alumno, abre la URL, califica y aprueba, rechaza o
  aplaza en las fases 2 y 4; al aprobar pasa al evaluador (RF-20, RF-21).
- `evaluador/anteproyectos.jsp`: solo ve lo aprobado por el director; califica y decide en las
  fases 3 y 5 (RF-22, RF-23).
- `coordinador/revisiones.jsp`: acepta o rechaza después del evaluador; aceptar avanza la fase (RF-12).
- `estudiante/calificaciones.jsp`: calificaciones y decisiones; la evaluación aparece sin nombre (RF-19).
- Fase 6: botón "Solicitar papeles de grado" (`estudiante/solicitar_papeles.jsp`) con aviso al
  coordinador (RF-14).
- `includes/decision_validar.jsp`: validación compartida de calificación y motivo.
- Regla de estados: en las fases 3 y 5, "Aprobado" = aprobado por el evaluador, a la espera del
  coordinador. Un rechazo no cierra el proyecto: conserva la fase y el estudiante corrige.
- `estudiante/proyecto_nuevo.jsp`: ahora un estudiante tiene un solo proyecto (sin importar el estado).
- Sin cambios en el script SQL.

## v0.4 - Proyecto y fase 1
- `estudiante/proyecto_nuevo.jsp`: modalidad, individual o en pareja (por documento) (RF-07). Nace en fase 1.
- `estudiante/asignar_idea.jsp`: escoge idea del banco o propia + URL del recibo; historial de recibos
  con versiones (RF-08, RF-16). Si el coordinador rechaza, ve el motivo y puede escoger otra.
- `coordinador/ideas_pendientes.jsp`: ve la idea, su origen (banco o propia) y el recibo; asigna o
  rechaza con motivo (RF-09). Asignar pasa el proyecto a la fase 2. La decisión queda en `revision`.
- Recordatorio "Sin revisar" para los coordinadores al enviar la idea (RF-17); se cierra al decidir.

## v0.3 - Banco de ideas
- `director/ideas.jsp` y `director/idea_nueva.jsp`: el director publica y ve sus ideas (RF-05).
- `estudiante/banco_ideas.jsp`: ID, título, disponibilidad, período, nivel y quién la propuso (RF-06).
- `estudiante/idea_nueva.jsp`: el estudiante propone una idea propia (RF-05).
- `includes/idea_formulario.jsp` (formulario compartido) e `includes/catalogos.jsp` (listas fijas).

## v0.2 - Módulo de usuarios del administrador
- `admin/usuarios.jsp`: lista con filtro por rol, roles de cada usuario y estado (RF-03).
- `admin/usuario_nuevo.jsp`: registro con validaciones (RF-02). Contraseña con SHA2, mínimo 6 caracteres.
- `admin/usuario_editar.jsp`: edición de datos, roles y estado; contraseña vacía = no cambiarla.
- `admin/usuario_eliminar.jsp`: elimina; si el usuario tiene registros asociados, lo desactiva.
- Reglas: dos roles solo si son Director y Evaluador; el estudiante requiere código;
  el administrador no puede eliminarse ni cambiarse el rol a sí mismo.
- Mensajes de confirmación de una sola vez (en `includes/cabecera.jsp`).

## v0.1 - Base del sistema
- Script MySQL `sql/trabajos_grado.sql` (10 tablas + vista del estudiante + datos iniciales).
  Cambios sobre el script del documento: la llave única de `documento` incluye la fase
  (las fases 2 y 4 no chocan), CHECK de calificación 0 a 5, y la vista incluye el título de la idea.
- Login con SHA2 (RF-01), elección de rol para docentes con dos roles, cierre de sesión.
- `includes/seguridad.jsp`: cada página verifica sesión y rol (RNF-06).
- Menú por rol (RF-04), enlaces de la universidad desde la tabla `enlace` (RF-27).
- Página de inicio por rol con recordatorios (RF-17); el estudiante ve fase, estado y director.
