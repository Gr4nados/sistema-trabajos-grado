-- ============================================================
-- migracion_v0.8.sql
-- Pone al dia una base creada con una version anterior de trabajos_grado.sql,
-- SIN borrar datos. Ejecutar UNA sola vez (MySQL Workbench o el cliente de MySQL 8).
-- Si la base se crea desde cero con trabajos_grado.sql, este archivo no hace falta.
-- ============================================================
USE trabajos_grado;

-- Ideas de docentes: quedan 'Pendiente' hasta que el coordinador las acepte o rechace.
ALTER TABLE idea
  MODIFY disponibilidad ENUM('Pendiente','Disponible','Asignada','Rechazada') NOT NULL DEFAULT 'Disponible',
  ADD COLUMN motivo_rechazo VARCHAR(300) NULL AFTER disponibilidad;

-- Radicado que el coordinador asigna a cada proyecto aceptado.
ALTER TABLE proyecto
  ADD COLUMN radicado VARCHAR(30) NULL UNIQUE AFTER id_proyecto;

-- La vista del estudiante ahora incluye el radicado (sigue sin traer al evaluador).
CREATE OR REPLACE VIEW vista_proyecto_estudiante AS
SELECT i.id_usuario AS id_estudiante,
       p.id_proyecto, p.radicado, p.modalidad, p.fase, p.estado, p.fecha_limite,
       a.titulo AS idea_titulo,
       d.nombres AS director_nombres, d.apellidos AS director_apellidos
FROM proyecto p
JOIN integrante i ON i.id_proyecto = p.id_proyecto
LEFT JOIN idea a ON a.id_idea = p.id_idea
LEFT JOIN usuario d ON d.id_usuario = p.id_director;

-- Enlaces de la universidad.
UPDATE enlace SET url = 'https://www.uts.edu.co/calendario-academico/' WHERE nombre = 'Calendario académico';
UPDATE enlace SET url = 'https://www.dropbox.com/scl/fo/pudgcaq639agy7t06ahjs/AN084HnuyHffgYL5i--v_Ks/DOCUMENTOS%20DE%20GRADO?rlkey=6s0b9ajweteyx2ang7ywvk6xm&subfolder_nav_tracking=1&e=1&dl=0' WHERE nombre = 'Formatos de grado';
INSERT INTO enlace (nombre, url) VALUES
  ('Reglamento de trabajos de grado', 'https://www.uts.edu.co/sitio/wp-content/uploads/normatividad/acuerdos/acu-73.pdf');
