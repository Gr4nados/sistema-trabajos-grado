# Pendientes por confirmar con el profesor

Los que bloqueen el flujo se detienen; los demás se resuelven con un supuesto y quedan aquí.

| # | Tema | Supuesto actual | Estado |
|---|------|-----------------|--------|
| 1 | Contenido de las fases 4 y 5 | Repiten el ciclo de las fases 2 y 3 (documento tipo "Otro") | Pendiente |
| 2 | Quién decide la fase 1 | El coordinador asigna o rechaza la idea | Pendiente |
| 3 | Quién asigna director y evaluador | El coordinador asigna ambos; el estudiante nunca ve al evaluador | Confirmado por el usuario |
| 4 | Escala de la calificación | 0.0 a 5.0 | Pendiente |
| 5 | Significado de "Aplazado" | Solo existe como estado; sin reglas propias | Pendiente |
| 6 | ¿Puede reintentar el estudiante tras un rechazo? | Sin definir | Pendiente |
| 7 | ¿Anteproyecto = propuesta FC124? | Se tratan como lo mismo | Pendiente |
| 8 | ¿Se permiten JavaBeans / DAO? | No; solo JSP + JSTL (etiquetas sql:) | Pendiente |
| 9 | ¿Se aceptan las etiquetas sql: de JSTL? | Sí (RNF-03) | Por confirmar |
| 10 | Un estudiante con varios proyectos | Se muestra el más reciente | Pendiente |
| 11 | Eliminar un usuario con registros asociados | Se desactiva (activo = FALSE) en vez de borrarlo | Pendiente |
| 12 | Reglas de roles y contraseña | Dos roles solo Director+Evaluador; estudiante con código; contraseña mínimo 6 caracteres | Supuesto mío |
| 13 | Idea propia del estudiante | Se guarda en el banco como cualquier idea; otro estudiante podría escogerla | Pendiente |
| 14 | Rechazo de la idea en fase 1 | El proyecto sigue en fase 1 sin idea; el estudiante escoge otra (no se marca el proyecto como Rechazado) | Pendiente |
| 15 | Modalidad del proyecto vs modalidad de la idea | No se exige que coincidan | Pendiente |
| 16 | Un estudiante, un proyecto | Solo puede tener un proyecto, sin importar su estado (un rechazo no lo cierra) | Supuesto mío |
| 17 | Rechazo o aplazamiento en fases 2 a 5 | El proyecto conserva la fase y el estado queda Rechazado/Aplazado; el estudiante registra otra versión y vuelve a "En revisión" | Supuesto mío (aclara #5 y #6) |
| 18 | Estado "a la espera del coordinador" | En fases 3 y 5, estado Aprobado = aprobado por el evaluador; el coordinador acepta (avanza) o rechaza | Supuesto mío |
| 19 | Rechazo del coordinador en fases 3 y 5 | El estudiante corrige y el evaluador vuelve a revisar | Supuesto mío |
| 20 | Calificación obligatoria | Director y evaluador siempre ponen nota (0.0 a 5.0), también al rechazar o aplazar; el coordinador no califica | Supuesto mío |
| 21 | Evaluador aún sin asignar al aprobar el director | El proyecto espera en la fase 3 y se avisa a la coordinación | Supuesto mío |
| 22 | Eliminar un documento | Solo el registrado en la fase actual y antes de que alguien lo revise | Supuesto mío |
| 23 | Fecha límite | La fija el coordinador al asignar director; genera recordatorio al estudiante y al director | Supuesto mío |
| 24 | Aceptación de ideas de docentes | Las ideas de docentes quedan Pendiente hasta que el coordinador las acepte o rechace; las del estudiante entran directo al banco | Supuesto mío (interpreta Ruta.md, act. 4) |
| 25 | Radicado | Texto libre (máx. 30), único, lo escribe el coordinador al asignar la idea de la fase 1 (formato por definir) | Supuesto mío (Ruta.md, act. 6) |
| 26 | Eliminar ideas del banco | El coordinador puede eliminarlas salvo que estén ligadas a un proyecto | Supuesto mío (Ruta.md, act. 5) |
