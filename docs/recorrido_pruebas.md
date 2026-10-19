# Recorrido de prueba (RNF-11)

Ocho pasos entre roles. Usa la base recién creada con `sql/trabajos_grado.sql`
(administrador de arranque: `admin` / `admin123`). Contraseñas de prueba: mínimo 6 caracteres.

| # | Rol | Acción | Resultado esperado |
|---|-----|--------|--------------------|
| 1 | Administrador | En `admin/usuario_nuevo.jsp` crea un estudiante (con código), un coordinador, un docente Director y un docente Evaluador. | Los cuatro aparecen en `admin/usuarios.jsp`. |
| 2 | Estudiante | En `proyecto_nuevo.jsp` crea el proyecto. En `idea_nueva.jsp` propone una idea (o usa una del banco) y en `asignar_idea.jsp` la elige con la URL del recibo. | Proyecto en fase 1; el coordinador recibe el recordatorio "Sin revisar". |
| 3 | Coordinador | En `ideas_pendientes.jsp` asigna la idea escribiendo el radicado (si la idea es de un docente, antes debe aceptarla en `banco_ideas.jsp`). En `asignar_director.jsp` escoge director, evaluador y (opcional) fecha límite. | Proyecto en fase 2; el estudiante ve a su director y no ve al evaluador. |
| 4 | Estudiante | En `documentos.jsp` registra la URL del anteproyecto. | Versión 1 en `versiones.jsp`; el director recibe un recordatorio. |
| 5 | Director | En `anteproyectos.jsp` pone nota (0.0 a 5.0) y aprueba. | Proyecto pasa a la fase 3 (Propuesta II); el evaluador recibe un recordatorio. |
| 6 | Evaluador | En `anteproyectos.jsp` ve la propuesta, pone nota y aprueba. | El proyecto avanza a la fase 4 (Informe I). |
| 7 | Estudiante | En `documentos.jsp` registra la URL del **informe**. (Si le rechazan o aplazan algo, registra una versión nueva.) El director lo califica y aprueba. | Versión en `versiones.jsp`; el proyecto pasa a la fase 5 (Informe II). |
| 8 | Evaluador y coordinador | El evaluador aprueba el informe; el coordinador da la aprobación final en `revisiones.jsp`. | El proyecto avanza a la fase 6 (Fase final). |

## Continuación (fase 6)

- El coordinador programa fecha, hora y lugar en `sustentaciones.jsp`; el estudiante, el director y el evaluador reciben el aviso.
- El estudiante ve la sustentación en su inicio y el botón "Solicitar papeles de grado"; al pulsarlo, el coordinador recibe el aviso.

## Comprobaciones de seguridad

- Un estudiante que abra `director/anteproyectos.jsp` vuelve al inicio (cada página verifica el rol).
- En `estudiante/calificaciones.jsp` la revisión del evaluador aparece como "Evaluación", sin nombre.
- Un director no puede ser el evaluador del mismo proyecto (`asignar_director.jsp` lo rechaza).
- La calificación fuera de 0.0 a 5.0 o sin motivo al rechazar muestra un error y no guarda nada.
