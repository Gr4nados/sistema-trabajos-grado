-- ============================================================
-- ideas_ejemplo.sql
-- Agrega 20 ideas de ejemplo al banco de ideas para hacer pruebas.
-- Se reparten entre los docentes con rol Director que ya existan (los crea el administrador).
-- 17 quedan "Disponible" (listas para que un estudiante las elija) y 3 "Pendiente"
-- (para probar que el coordinador las acepte o las rechace en "Banco de ideas").
-- Se puede ejecutar mas de una vez: no repite una idea con el mismo titulo.
-- Requiere al menos un docente con rol Director.
-- ============================================================
USE trabajos_grado;

INSERT INTO idea (titulo, modalidad, objetivo_general, linea_investigacion, nivel, periodo_academico, disponibilidad, id_proponente)
SELECT t.titulo, t.modalidad, t.objetivo_general, t.linea_investigacion, t.nivel, t.periodo_academico, t.disponibilidad, d.id_usuario
FROM (
  SELECT 'Sistema web de gestión de inventarios para tiendas de barrio' AS titulo, 'Desarrollo tecnológico' AS modalidad, 'Desarrollar una aplicación web que permita registrar productos, entradas y salidas, y generar alertas de stock mínimo para pequeños comercios.' AS objetivo_general, 'Ingeniería de software' AS linea_investigacion, 'Tecnológico' AS nivel, '2026-2' AS periodo_academico, 'Disponible' AS disponibilidad, 1 AS k
  UNION ALL
  SELECT 'Aplicación móvil para el control de asistencia estudiantil mediante códigos QR' AS titulo, 'Desarrollo tecnológico' AS modalidad, 'Construir una aplicación móvil que registre la asistencia a clase escaneando códigos QR y genere reportes por curso y por estudiante.' AS objetivo_general, 'Aplicaciones móviles' AS linea_investigacion, 'Tecnológico' AS nivel, '2026-2' AS periodo_academico, 'Disponible' AS disponibilidad, 2 AS k
  UNION ALL
  SELECT 'Plataforma de citas médicas con recordatorios automáticos para una IPS pequeña' AS titulo, 'Desarrollo tecnológico' AS modalidad, 'Implementar una plataforma web que gestione la asignación de citas, la agenda de los médicos y el envío de recordatorios a los pacientes.' AS objetivo_general, 'Ingeniería de software' AS linea_investigacion, 'Profesional' AS nivel, '2026-2' AS periodo_academico, 'Disponible' AS disponibilidad, 3 AS k
  UNION ALL
  SELECT 'Sistema de monitoreo de consumo energético con sensores IoT' AS titulo, 'Desarrollo tecnológico' AS modalidad, 'Diseñar e implementar un sistema que mida el consumo eléctrico con sensores conectados y lo muestre en un panel web en tiempo real.' AS objetivo_general, 'Internet de las cosas' AS linea_investigacion, 'Profesional' AS nivel, '2026-2' AS periodo_academico, 'Disponible' AS disponibilidad, 4 AS k
  UNION ALL
  SELECT 'Chatbot de atención al estudiante para consultas académicas frecuentes' AS titulo, 'Desarrollo tecnológico' AS modalidad, 'Desarrollar un asistente conversacional que responda preguntas sobre calendario, trámites y requisitos de grado a partir de una base de conocimiento.' AS objetivo_general, 'Inteligencia artificial' AS linea_investigacion, 'Profesional' AS nivel, '2027-1' AS periodo_academico, 'Disponible' AS disponibilidad, 5 AS k
  UNION ALL
  SELECT 'Aplicación web para la reserva de canchas deportivas' AS titulo, 'Desarrollo tecnológico' AS modalidad, 'Crear una aplicación web donde los usuarios consulten la disponibilidad de canchas, reserven horarios y paguen en línea.' AS objetivo_general, 'Ingeniería de software' AS linea_investigacion, 'Tecnológico' AS nivel, '2026-2' AS periodo_academico, 'Disponible' AS disponibilidad, 6 AS k
  UNION ALL
  SELECT 'Control de acceso vehicular con reconocimiento de placas' AS titulo, 'Desarrollo tecnológico' AS modalidad, 'Implementar un prototipo que identifique placas de vehículos mediante procesamiento de imágenes y registre las entradas y salidas de un parqueadero.' AS objetivo_general, 'Visión por computador' AS linea_investigacion, 'Profesional' AS nivel, '2027-1' AS periodo_academico, 'Pendiente' AS disponibilidad, 7 AS k
  UNION ALL
  SELECT 'Plataforma de seguimiento de prácticas empresariales' AS titulo, 'Desarrollo tecnológico' AS modalidad, 'Desarrollar un sistema que permita a estudiantes, tutores y empresas registrar avances, evidencias y evaluaciones de la práctica profesional.' AS objetivo_general, 'Ingeniería de software' AS linea_investigacion, 'Tecnológico' AS nivel, '2026-2' AS periodo_academico, 'Disponible' AS disponibilidad, 8 AS k
  UNION ALL
  SELECT 'Plan de negocio para una plataforma de domicilios de productos campesinos de Santander' AS titulo, 'Emprendimiento' AS modalidad, 'Estructurar un plan de negocio y un prototipo funcional para comercializar productos del campo santandereano directamente al consumidor.' AS objetivo_general, 'Emprendimiento digital' AS linea_investigacion, 'Tecnológico' AS nivel, '2026-2' AS periodo_academico, 'Disponible' AS disponibilidad, 9 AS k
  UNION ALL
  SELECT 'Reciclaje tecnológico: recolección y reacondicionamiento de equipos de cómputo' AS titulo, 'Emprendimiento' AS modalidad, 'Plantear una empresa que recolecte, repare y reutilice equipos de cómputo en desuso, con un modelo de ingresos y de impacto ambiental.' AS objetivo_general, 'Sostenibilidad y tecnología' AS linea_investigacion, 'Tecnológico' AS nivel, '2027-1' AS periodo_academico, 'Disponible' AS disponibilidad, 10 AS k
  UNION ALL
  SELECT 'Tienda en línea para artesanías locales con pasarela de pagos' AS titulo, 'Emprendimiento' AS modalidad, 'Crear una tienda virtual para artesanos de la región, con catálogo, carrito de compras y pagos en línea, junto con su plan comercial.' AS objetivo_general, 'Comercio electrónico' AS linea_investigacion, 'Tecnológico' AS nivel, '2026-2' AS periodo_academico, 'Disponible' AS disponibilidad, 11 AS k
  UNION ALL
  SELECT 'Servicio por suscripción de mantenimiento preventivo de equipos para pymes' AS titulo, 'Emprendimiento' AS modalidad, 'Diseñar un servicio de mantenimiento preventivo de equipos de cómputo para pequeñas empresas, con un sistema de agendamiento y seguimiento.' AS objetivo_general, 'Emprendimiento digital' AS linea_investigacion, 'Profesional' AS nivel, '2027-1' AS periodo_academico, 'Disponible' AS disponibilidad, 12 AS k
  UNION ALL
  SELECT 'Adopción de metodologías ágiles en pymes de software de Bucaramanga' AS titulo, 'Monografía' AS modalidad, 'Analizar el grado de adopción, los beneficios y las dificultades de las metodologías ágiles en pequeñas empresas de desarrollo de software de la ciudad.' AS objetivo_general, 'Ingeniería de software' AS linea_investigacion, 'Profesional' AS nivel, '2026-2' AS periodo_academico, 'Disponible' AS disponibilidad, 13 AS k
  UNION ALL
  SELECT 'Estudio comparativo de frameworks de desarrollo web' AS titulo, 'Monografía' AS modalidad, 'Comparar frameworks de desarrollo web actuales según rendimiento, curva de aprendizaje y comunidad, para orientar su elección en proyectos académicos.' AS objetivo_general, 'Ingeniería de software' AS linea_investigacion, 'Tecnológico' AS nivel, '2026-2' AS periodo_academico, 'Disponible' AS disponibilidad, 14 AS k
  UNION ALL
  SELECT 'Diagnóstico de ciberseguridad básica en micro y pequeñas empresas' AS titulo, 'Monografía' AS modalidad, 'Diagnosticar las prácticas de ciberseguridad de micro y pequeñas empresas y proponer una guía de buenas prácticas de bajo costo.' AS objetivo_general, 'Seguridad informática' AS linea_investigacion, 'Profesional' AS nivel, '2027-1' AS periodo_academico, 'Pendiente' AS disponibilidad, 15 AS k
  UNION ALL
  SELECT 'Modelo predictivo de deserción estudiantil con aprendizaje automático' AS titulo, 'Proyecto de investigación' AS modalidad, 'Construir y validar un modelo que identifique tempranamente a los estudiantes con riesgo de deserción a partir de datos académicos.' AS objetivo_general, 'Ciencia de datos' AS linea_investigacion, 'Profesional' AS nivel, '2026-2' AS periodo_academico, 'Disponible' AS disponibilidad, 16 AS k
  UNION ALL
  SELECT 'Evaluación de la usabilidad de plataformas virtuales de aprendizaje' AS titulo, 'Proyecto de investigación' AS modalidad, 'Evaluar la usabilidad de las plataformas virtuales usadas en educación tecnológica y proponer mejoras basadas en pruebas con usuarios.' AS objetivo_general, 'Interacción humano-computador' AS linea_investigacion, 'Profesional' AS nivel, '2027-1' AS periodo_academico, 'Disponible' AS disponibilidad, 17 AS k
  UNION ALL
  SELECT 'Detección temprana de enfermedades en cultivos mediante procesamiento de imágenes' AS titulo, 'Proyecto de investigación' AS modalidad, 'Desarrollar un método que identifique enfermedades en hojas de cultivos de la región a partir de fotografías tomadas con un celular.' AS objetivo_general, 'Visión por computador' AS linea_investigacion, 'Profesional' AS nivel, '2026-2' AS periodo_academico, 'Disponible' AS disponibilidad, 18 AS k
  UNION ALL
  SELECT 'Optimización de rutas de transporte urbano con algoritmos heurísticos' AS titulo, 'Proyecto de investigación' AS modalidad, 'Aplicar algoritmos heurísticos para proponer rutas más eficientes de transporte urbano y comparar su desempeño con las rutas actuales.' AS objetivo_general, 'Optimización' AS linea_investigacion, 'Profesional' AS nivel, '2027-1' AS periodo_academico, 'Disponible' AS disponibilidad, 19 AS k
  UNION ALL
  SELECT 'Análisis de sentimientos en redes sociales sobre servicios universitarios' AS titulo, 'Proyecto de investigación' AS modalidad, 'Recolectar y analizar opiniones públicas sobre los servicios de la universidad para identificar percepciones y oportunidades de mejora.' AS objetivo_general, 'Procesamiento de lenguaje natural' AS linea_investigacion, 'Tecnológico' AS nivel, '2026-2' AS periodo_academico, 'Pendiente' AS disponibilidad, 20 AS k
) t
JOIN (
  SELECT id_usuario, ROW_NUMBER() OVER (ORDER BY id_usuario) AS rn, COUNT(*) OVER () AS total
  FROM (SELECT DISTINCT u.id_usuario
          FROM usuario u
          JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario
          JOIN rol r ON r.id_rol = ur.id_rol
         WHERE r.nombre = 'Director' AND u.activo = TRUE) x
) d ON d.rn = ((t.k - 1) % d.total) + 1
WHERE NOT EXISTS (SELECT 1 FROM idea i WHERE i.titulo = t.titulo);
