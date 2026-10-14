# Changelog

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
