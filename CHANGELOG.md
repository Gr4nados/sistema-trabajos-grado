# Changelog

## v0.1 - Base del sistema
- Script MySQL `sql/trabajos_grado.sql` (10 tablas + vista del estudiante + datos iniciales).
  Cambios sobre el script del documento: la llave única de `documento` incluye la fase
  (las fases 2 y 4 no chocan), CHECK de calificación 0 a 5, y la vista incluye el título de la idea.
- Login con SHA2 (RF-01), elección de rol para docentes con dos roles, cierre de sesión.
- `includes/seguridad.jsp`: cada página verifica sesión y rol (RNF-06).
- Menú por rol (RF-04), enlaces de la universidad desde la tabla `enlace` (RF-27).
- Página de inicio por rol con recordatorios (RF-17); el estudiante ve fase, estado y director.
