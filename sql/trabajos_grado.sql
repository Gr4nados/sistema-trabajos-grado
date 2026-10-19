-- ============================================================
-- trabajos_grado.sql  (v0.9)
-- Motor: MySQL 8.0  |  Se ejecuta desde MySQL Workbench
-- ATENCION: borra y recrea la base de datos trabajos_grado.
-- ============================================================
DROP DATABASE IF EXISTS trabajos_grado;
CREATE DATABASE trabajos_grado CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE trabajos_grado;

CREATE TABLE rol (
  id_rol TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE usuario (
  id_usuario INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  documento  VARCHAR(20) NOT NULL UNIQUE,
  codigo     VARCHAR(20) NULL UNIQUE,          -- codigo estudiantil (solo alumnos)
  nombres    VARCHAR(80) NOT NULL,
  apellidos  VARCHAR(80) NOT NULL,
  usuario    VARCHAR(40) NOT NULL UNIQUE,
  contrasena CHAR(64) NOT NULL,                -- SHA2(clave, 256)
  activo     BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Un usuario puede tener varios roles (un docente: Director y Evaluador)
CREATE TABLE usuario_rol (
  id_usuario INT UNSIGNED NOT NULL,
  id_rol     TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (id_usuario, id_rol),
  FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  FOREIGN KEY (id_rol) REFERENCES rol (id_rol)
);

CREATE TABLE idea (
  id_idea INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  titulo VARCHAR(200) NOT NULL,
  modalidad ENUM('Desarrollo tecnológico','Emprendimiento','Monografía','Proyecto de investigación') NOT NULL,
  objetivo_general TEXT NOT NULL,
  linea_investigacion VARCHAR(120) NULL,
  nivel ENUM('Tecnológico','Profesional') NOT NULL,
  periodo_academico VARCHAR(10) NOT NULL,
  -- Pendiente: idea de un docente a la espera del coordinador; Rechazada: ver motivo_rechazo
  disponibilidad ENUM('Pendiente','Disponible','Asignada','Rechazada') NOT NULL DEFAULT 'Disponible',
  motivo_rechazo VARCHAR(300) NULL,
  id_proponente INT UNSIGNED NOT NULL,         -- docente o estudiante que la propone
  creada_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_proponente) REFERENCES usuario (id_usuario)
);

CREATE TABLE proyecto (
  id_proyecto INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  radicado VARCHAR(30) NULL UNIQUE,            -- lo asigna el coordinador al aceptar el proyecto
  modalidad ENUM('Desarrollo tecnológico','Emprendimiento','Monografía','Proyecto de investigación') NOT NULL,
  id_idea INT UNSIGNED NULL UNIQUE,            -- idea asignada (1 a 1)
  id_director INT UNSIGNED NULL,
  id_evaluador INT UNSIGNED NULL,
  fase TINYINT UNSIGNED NOT NULL DEFAULT 1,
  estado ENUM('En revisión','Aprobado','Rechazado','Aplazado') NOT NULL DEFAULT 'En revisión',
  fecha_limite DATE NULL,
  papeles_solicitados BOOLEAN NOT NULL DEFAULT FALSE,
  sustentacion_fecha DATETIME NULL,            -- fase 6: la programa el coordinador
  sustentacion_lugar VARCHAR(120) NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_idea) REFERENCES idea (id_idea),
  FOREIGN KEY (id_director) REFERENCES usuario (id_usuario),
  FOREIGN KEY (id_evaluador) REFERENCES usuario (id_usuario),
  CONSTRAINT ck_fase CHECK (fase BETWEEN 1 AND 6),
  CONSTRAINT ck_director_evaluador
    CHECK (id_director IS NULL OR id_evaluador IS NULL OR id_director <> id_evaluador)
);

CREATE TABLE integrante (
  id_proyecto INT UNSIGNED NOT NULL,
  id_usuario  INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_proyecto, id_usuario),
  FOREIGN KEY (id_proyecto) REFERENCES proyecto (id_proyecto),
  FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
);

-- Cada URL registrada es una version nueva; nunca se sobrescribe.
-- La fase se incluye en la llave para que las fases 2 y 4 no choquen.
CREATE TABLE documento (
  id_documento INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_proyecto INT UNSIGNED NOT NULL,
  tipo ENUM('Recibo de pago','Anteproyecto','Informe','Otro') NOT NULL,   -- Informe: fases 4 y 5
  version INT UNSIGNED NOT NULL DEFAULT 1,
  url VARCHAR(500) NOT NULL,
  fase TINYINT UNSIGNED NOT NULL,
  id_autor INT UNSIGNED NOT NULL,
  subido_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (id_proyecto, tipo, fase, version),
  FOREIGN KEY (id_proyecto) REFERENCES proyecto (id_proyecto),
  FOREIGN KEY (id_autor) REFERENCES usuario (id_usuario)
);

-- Cada decision queda registrada: quien, cuando, resultado y motivo.
CREATE TABLE revision (
  id_revision INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_proyecto INT UNSIGNED NOT NULL,
  fase TINYINT UNSIGNED NOT NULL,
  id_revisor INT UNSIGNED NOT NULL,
  rol_revisor ENUM('Coordinador','Director','Evaluador') NOT NULL,
  resultado ENUM('Aprobado','Rechazado','Aplazado') NOT NULL,
  calificacion DECIMAL(2,1) NULL,              -- PENDIENTE: escala 0.0 a 5.0 (supuesto)
  comentario TEXT NULL,
  revisada_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_proyecto) REFERENCES proyecto (id_proyecto),
  FOREIGN KEY (id_revisor) REFERENCES usuario (id_usuario),
  CONSTRAINT ck_calificacion CHECK (calificacion IS NULL OR calificacion BETWEEN 0 AND 5)
);

CREATE TABLE recordatorio (
  id_recordatorio INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_usuario INT UNSIGNED NOT NULL,
  id_proyecto INT UNSIGNED NULL,
  tipo ENUM('Fecha límite','Sin revisar','Sustentación') NOT NULL,
  mensaje VARCHAR(200) NOT NULL,
  fecha_limite DATE NULL,
  vigente BOOLEAN NOT NULL DEFAULT TRUE,
  FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  FOREIGN KEY (id_proyecto) REFERENCES proyecto (id_proyecto)
);

CREATE TABLE enlace (
  id_enlace TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(60) NOT NULL UNIQUE,
  url VARCHAR(500) NOT NULL
);

-- El estudiante ve su proyecto y a su director, NUNCA al evaluador.
CREATE VIEW vista_proyecto_estudiante AS
SELECT i.id_usuario AS id_estudiante,
       p.id_proyecto, p.radicado, p.modalidad, p.fase, p.estado, p.fecha_limite,
       a.titulo AS idea_titulo,
       d.nombres AS director_nombres, d.apellidos AS director_apellidos
FROM proyecto p
JOIN integrante i ON i.id_proyecto = p.id_proyecto
LEFT JOIN idea a ON a.id_idea = p.id_idea
LEFT JOIN usuario d ON d.id_usuario = p.id_director;

-- ---------------- Datos iniciales ----------------
INSERT INTO rol (nombre) VALUES
  ('Administrador'), ('Estudiante'), ('Coordinador'), ('Director'), ('Evaluador');

-- Administrador de arranque: usuario admin / clave admin123 (CAMBIAR)
INSERT INTO usuario (documento, nombres, apellidos, usuario, contrasena)
VALUES ('0000000000', 'Administrador', 'Sistema', 'admin', SHA2('admin123', 256));

INSERT INTO usuario_rol (id_usuario, id_rol)
SELECT u.id_usuario, r.id_rol FROM usuario u, rol r
WHERE u.usuario = 'admin' AND r.nombre = 'Administrador';

INSERT INTO enlace (nombre, url) VALUES
  ('Calendario académico', 'https://www.uts.edu.co/calendario-academico/'),
  ('Formatos de grado', 'https://www.dropbox.com/scl/fo/pudgcaq639agy7t06ahjs/AN084HnuyHffgYL5i--v_Ks/DOCUMENTOS%20DE%20GRADO?rlkey=6s0b9ajweteyx2ang7ywvk6xm&subfolder_nav_tracking=1&e=1&dl=0'),
  ('Reglamento de trabajos de grado', 'https://www.uts.edu.co/sitio/wp-content/uploads/normatividad/acuerdos/acu-73.pdf'),
  ('Base documental', 'https://www.dropbox.com/scl/fo/pudgcaq639agy7t06ahjs/AF-dMByc71OWsxcfY2dLe3A?rlkey=6s0b9ajweteyx2ang7ywvk6xm&dl=0'),
  ('Valores pecuniarios', 'https://www.uts.edu.co/valores-pecuniarios/'),
  ('Reglamento estudiantil', 'https://www.uts.edu.co/sitio/wp-content/uploads/2019/10/REGLAMENTO_ESTUDIANTIL_ENERO_2022-2.pdf');
