# Changelog

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
