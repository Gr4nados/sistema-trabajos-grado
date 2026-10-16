# Recorrido de prueba (RNF-11)

Ocho pasos entre roles. Usa la base recién creada con `sql/trabajos_grado.sql`
(administrador de arranque: `admin` / `admin123`). Contraseñas de prueba: mínimo 6 caracteres.

| # | Rol | Acción | Resultado esperado |
|---|-----|--------|--------------------|
| 1 | Administrador | En `admin/usuario_nuevo.jsp` crea un estudiante (con código), un coordinador, un docente Director y un docente Evaluador. | Los cuatro aparecen en `admin/usuarios.jsp`. |
| 2 | Estudiante | En `proyecto_nuevo.jsp` crea el proyecto. En `idea_nueva.jsp` propone una idea (o usa una del banco) y en `asignar_idea.jsp` la elige con la URL del recibo. | Proyecto en fase 1; el coordinador recibe el recordatorio "Sin revisar". |
| 3 | Coordinador | En `ideas_pendientes.jsp` asigna la idea escribiendo el radicado (si la idea es de un docente, antes debe aceptarla en `banco_ideas.jsp`). En `asignar_director.jsp` escoge director, evaluador y (opcional) fecha límite. | Proyecto en fase 2; el estudiante ve a su director y no ve al evaluador. |
| 4 | Estudiante | En `documentos.jsp` registra la URL del anteproyecto. | Versión 1 en `versiones.jsp`; el director recibe un recordatorio. |
| 5 | Director | En `anteproyectos.jsp` pone nota (0.0 a 5.0) y aprueba. | Proyecto pasa a la fase 3; el evaluador recibe un recordatorio. |
| 6 | Evaluador | En `anteproyectos.jsp` ve el documento, pone nota y aprueba. | Estado "Aprobado" en la fase 3; el coordinador recibe un recordatorio. |
| 7 | Estudiante | (Solo si hace falta) tras un rechazo o aplazamiento, registra una versión nueva en `documentos.jsp`. | Versión 2; el estado vuelve a "En revisión" y el revisor se entera por recordatorio. |
| 8 | Coordinador | En `revisiones.jsp` acepta. | El proyecto avanza a la fase 4. |

## Continuación (fases 4 a 6)

- Fase 4: el estudiante registra su documento (tipo "Otro") y el director decide, igual que en la fase 2.
- Fase 5: igual que la fase 3 (evaluador y luego coordinador).
- Fase 6: el estudiante ve "Solicitar papeles de grado"; al pulsarlo, el coordinador recibe el aviso.

## Comprobaciones de seguridad

- Un estudiante que abra `director/anteproyectos.jsp` vuelve al inicio (cada página verifica el rol).
- En `estudiante/calificaciones.jsp` la revisión del evaluador aparece como "Evaluación", sin nombre.
- Un director no puede ser el evaluador del mismo proyecto (`asignar_director.jsp` lo rechaza).
- La calificación fuera de 0.0 a 5.0 o sin motivo al rechazar muestra un error y no guarda nada.
