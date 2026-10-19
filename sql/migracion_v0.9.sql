-- ============================================================
-- migracion_v0.9.sql
-- Pone al dia una base que ya paso por migracion_v0.8.sql, SIN borrar datos.
-- Ejecutar UNA sola vez. Si la base se crea desde cero con trabajos_grado.sql, no hace falta.
-- Cambios: fases 4 y 5 usan el tipo de documento "Informe"; la fase 3 la decide solo el
-- evaluador (ya no pasa por el coordinador); la fase 6 programa la sustentacion.
-- ============================================================
USE trabajos_grado;

-- Tipo de documento "Informe" (fases 4 y 5); lo que estaba como "Otro" pasa a "Informe".
ALTER TABLE documento
  MODIFY tipo ENUM('Recibo de pago','Anteproyecto','Informe','Otro') NOT NULL;
UPDATE documento SET tipo = 'Informe' WHERE tipo = 'Otro';

-- Sustentacion (fase 6): la programa el coordinador.
ALTER TABLE proyecto
  ADD COLUMN sustentacion_fecha DATETIME NULL,
  ADD COLUMN sustentacion_lugar VARCHAR(120) NULL;

-- Proyectos que esperaban al coordinador en la fase 3 (regla anterior): la aprobacion del
-- evaluador ya los hace avanzar a la fase 4.
UPDATE recordatorio SET vigente = FALSE
 WHERE tipo = 'Sin revisar'
   AND id_proyecto IN (SELECT id_proyecto FROM (SELECT id_proyecto FROM proyecto WHERE fase = 3 AND estado = 'Aprobado') x);
UPDATE proyecto SET estado = 'En revisión', fase = 4 WHERE fase = 3 AND estado = 'Aprobado';

-- Aviso propio para la sustentacion (se muestra con su fecha en el inicio de cada participante).
ALTER TABLE recordatorio
  MODIFY tipo ENUM('Fecha límite','Sin revisar','Sustentación') NOT NULL;

-- Mas enlaces de la universidad (se ven en la pagina "Enlaces de la universidad").
INSERT INTO enlace (nombre, url) VALUES
  ('Base documental', 'https://www.dropbox.com/scl/fo/pudgcaq639agy7t06ahjs/AF-dMByc71OWsxcfY2dLe3A?rlkey=6s0b9ajweteyx2ang7ywvk6xm&dl=0'),
  ('Valores pecuniarios', 'https://www.uts.edu.co/valores-pecuniarios/'),
  ('Reglamento estudiantil', 'https://www.uts.edu.co/sitio/wp-content/uploads/2019/10/REGLAMENTO_ESTUDIANTIL_ENERO_2022-2.pdf');
