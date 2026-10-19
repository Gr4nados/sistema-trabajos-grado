# Guía para probar el sistema de Trabajos de Grado

Gracias por ayudar a probarlo. Esta guía te lleva desde instalar el proyecto hasta recorrerlo completo, y al final dice cómo reportar lo que encuentres. Empiezas **desde cero**: la base de datos nueva solo trae un administrador, y tú creas los demás usuarios.

## 1. Qué es el sistema

Una aplicación web (JSP + JSTL) que guía un proyecto de grado por **6 fases** entre 5 roles:

| Rol | Qué hace |
|---|---|
| Administrador | Crea, edita y desactiva usuarios. |
| Estudiante | Crea el proyecto (solo o en pareja), elige idea, sube el recibo y los documentos (como URL) y consulta sus notas. |
| Coordinador | Gestiona el banco de ideas, asigna la idea con su radicado, asigna director y evaluador, da la aprobación final y programa la sustentación. |
| Director | Publica ideas y califica los documentos de las fases 2 y 4. |
| Evaluador | Califica los documentos de las fases 3 y 5. |

| Fase | Nombre | Qué pasa |
|---|---|---|
| 1 | Pago | El estudiante elige una idea y registra la URL del recibo; el coordinador la asigna (con radicado) o la rechaza. |
| 2 | Propuesta I | El estudiante envía el anteproyecto (URL); decide el director. |
| 3 | Propuesta II | El anteproyecto pasa al evaluador; decide solo el evaluador. |
| 4 | Informe I | El estudiante envía el informe (URL); decide el director. |
| 5 | Informe II | Decide el evaluador y luego el coordinador da la aprobación final. |
| 6 | Fase final | El coordinador programa la sustentación; el estudiante puede solicitar sus papeles de grado. |

## 2. Qué necesitas instalado

- **Tomcat 8.5 o 9** (no sirve la 10 ni posteriores). Si usas XAMPP, ya trae la 8.5: asegúrate de haber instalado el componente *Tomcat*.
- **Java 8 a 17**.
- **MySQL 8** (o MariaDB 10.11, que trae XAMPP).
- **Git**, o bien el proyecto en un `.zip`.

## 3. Instalación paso a paso

### 3.1 Obtener el código
Debe quedar en una carpeta llamada **exactamente `TrabajosGrado`** dentro de `webapps` de Tomcat (el nombre de la carpeta forma parte de la dirección web). Con XAMPP:

```
git clone https://github.com/Gr4nados/sistema-trabajos-grado.git C:\xampp\tomcat\webapps\TrabajosGrado
```

Si te lo pasaron en un `.zip`, descomprímelo en `C:\xampp\tomcat\webapps\` y renombra la carpeta a `TrabajosGrado`.

### 3.2 Crear la base de datos
Abre MySQL Workbench (o phpMyAdmin) y ejecuta completo el archivo `sql/trabajos_grado.sql`.

> **Ojo:** ese script **borra y recrea** la base `trabajos_grado`. Si ya tienes una con ese nombre, perderás sus datos. También sirve para **empezar de cero** cuando quieras.

Crea las tablas, los 5 roles, los enlaces de la universidad y el usuario `admin` (clave `admin123`).

### 3.3 Configurar la conexión
1. En la carpeta `includes`, copia `conexion.ejemplo.jsp` y llama a la copia **`conexion.jsp`**.
2. Ábrelo y cambia `TU_CLAVE` por la clave de tu MySQL. Si tu usuario no es `root`, cambia también `user`. Si tu MySQL no tiene clave (típico en XAMPP), deja `password=""`.

`conexion.jsp` es solo tuyo: no se sube a GitHub.

### 3.4 Arrancar
1. Inicia **MySQL** y **Tomcat** desde el panel de XAMPP (o ejecuta `C:\xampp\catalina_start.bat` para Tomcat).
2. Abre <http://localhost:8080/TrabajosGrado/login.jsp>.
3. Entra con `admin` / `admin123`.

### 3.5 Si algo no arranca

| Síntoma | Causa probable |
|---|---|
| Error 404 | La carpeta no se llama `TrabajosGrado`, o Tomcat no terminó de iniciar (espera un momento). |
| Error 500 con un mensaje sobre la conexión o "Access denied" | Clave o usuario mal en `conexion.jsp`, o MySQL apagado. |
| Error 500 con "Table ... doesn't exist" | No se ejecutó `sql/trabajos_grado.sql`, o se ejecutó en otra base. |
| La página se ve sin estilos | Recarga con Ctrl + F5. |
| Tomcat no abre el puerto 8080 | Otro programa usa ese puerto; ciérralo o cambia el puerto de Tomcat. |

## 4. Crear los usuarios de prueba

Entra como `admin`, ve a **Usuarios → Registrar usuario** y crea estas cuentas (puedes cambiar los nombres, pero apunta cuáles usaste). Usa una clave de al menos 6 caracteres, por ejemplo `prueba123`.

| Usuario | Rol | Notas |
|---|---|---|
| `est1` | Estudiante | El **código estudiantil** es obligatorio. |
| `est2` | Estudiante | Para probar el trabajo en pareja. |
| `coord1` | Coordinador | |
| `dir1` | Director | |
| `dir-eva1` | Director **y** Evaluador | Un docente puede tener los dos roles; al entrar elige con cuál. |
| `eva1` | Evaluador | |

Reglas que el sistema debe hacer cumplir (pruébalas, ver sección 7): el documento y el usuario no se repiten, solo un docente puede tener dos roles (Director y Evaluador), y el director y el evaluador de un mismo proyecto no pueden ser la misma persona.

## 5. Recorrido principal (de principio a fin)

Abre cada rol en una ventana distinta (por ejemplo, una ventana normal y otra de incógnito), o cierra sesión entre pasos. Usa URLs inventadas que empiecen por `https://`, por ejemplo `https://ejemplo.com/recibo`.

| # | Quién | Qué hacer | Qué debería pasar |
|---|---|---|---|
| 1 | `dir1` | En **Mis ideas** → **Publicar idea**, llena el formulario. | La idea queda **Pendiente**. |
| 2 | `coord1` | En **Banco de ideas**, acepta la idea. | Pasa a **Disponible**. |
| 3 | `est1` | En **Nuevo proyecto**, elige modalidad y "En pareja" con el documento de `est2`. | Se crea el proyecto en fase 1. |
| 4 | `est1` | En **Asignar idea**, elige la idea y escribe la URL del recibo. | Queda a la espera del coordinador. |
| 5 | `coord1` | En **Ideas por asignar**, escribe un radicado (ej. `2026-001`) y asigna. | El proyecto pasa a la fase 2. |
| 6 | `coord1` | En **Asignar director**, escoge director y evaluador (y una fecha límite si quieres). | El estudiante ve a su director, **nunca** al evaluador. |
| 7 | `est1` | En **Documentos**, registra la URL del anteproyecto. | Versión 1; el director recibe un aviso. |
| 8 | `dir1` | En **Anteproyectos**, pon una nota (0.0 a 5.0) y aprueba. | Pasa a la fase 3. |
| 9 | evaluador | En **Anteproyectos**, califica y aprueba. | Pasa a la fase 4. |
| 10 | `est1` | En **Documentos**, registra la URL del **informe**. | Versión nueva del informe. |
| 11 | `dir1` | Califica y aprueba el informe. | Pasa a la fase 5. |
| 12 | evaluador | Califica y aprueba el informe. | Queda a la espera del coordinador. |
| 13 | `coord1` | En **Aprobación final**, acepta. (Antes, en la misma pantalla, mira "Informes en curso".) | Pasa a la fase 6. |
| 14 | `coord1` | En **Sustentaciones**, programa fecha, hora y lugar. | Estudiante, director y evaluador reciben un aviso. |
| 15 | `est1` | En su inicio, mira la sustentación y pulsa **Solicitar papeles de grado**. | Queda registrado y el coordinador lo ve en su inicio. |

Mientras avanzas, revisa en cada inicio: las tarjetas de fases del estudiante (verde = hecha, resaltada = actual), los contadores de los demás roles y los **Recordatorios**.

## 6. Otras pantallas para mirar

- **Mi perfil**: los datos del usuario (todos los roles).
- **Enlaces de la universidad**: se abren en una pestaña nueva; confirma que cada uno carga.
- **Buscar estudiante** e **Informes** (coordinador): búsqueda por código o nombre y estado de los proyectos por alumno, director y evaluador.
- **Versiones** y **Calificaciones** (estudiante): historial de URLs y notas recibidas.
- **Turnitin** y **Rejilla** (evaluador): son solo pantallas de muestra, no hacen nada.

## 7. Pruebas de error y de seguridad

Intenta "romper" el sistema. Todo esto debería mostrar un mensaje claro y **no** guardar datos incorrectos:

- **Rechazos:** que el director o el evaluador **rechacen** o **aplacen** un documento sin escribir motivo (debe pedirlo). Con motivo: el proyecto conserva su fase y el estudiante puede registrar una versión nueva (se conservan las anteriores).
- **Notas:** calificar con `7`, `-1` o texto (debe rechazarlo).
- **Radicado:** repetir un radicado en otro proyecto (debe avisar que ya existe).
- **Fase 1:** que el coordinador rechace una idea con motivo; el estudiante debe ver el motivo y poder escoger otra.
- **Banco de ideas:** editar una idea; intentar eliminar una idea ya asignada a un proyecto (no debe dejar).
- **Roles:** asignar el mismo docente como director y evaluador del mismo proyecto (no debe dejar).
- **Acceso:** con la sesión de un estudiante, escribir en la barra la dirección de una página de otro rol (por ejemplo `.../director/anteproyectos.jsp`): debe devolverte al inicio. Sin sesión, cualquier página debe llevar al login.
- **El evaluador es invisible para el estudiante:** en ninguna pantalla del estudiante debe aparecer su nombre.
- **Usuarios:** intentar eliminar o quitarse el rol al propio administrador (no debe dejar); eliminar un usuario que ya participa en un proyecto (debe **desactivarse**, no borrarse), e intentar entrar con él.
- **Formularios:** dejar campos vacíos, URLs sin `https://` y textos muy largos.
- **Celular:** achica la ventana del navegador; el menú lateral debe pasar a un botón de hamburguesa.

## 8. Qué no es un error

- Turnitin y la rejilla de evaluación son solo visuales.
- Los documentos y recibos son **solo URL**: el sistema no recibe archivos.
- No hay correos ni recuperación de contraseña (el administrador la cambia editando el usuario).
- No hay límite de intentos de contraseña (así se acordó).
- Algunas decisiones están pendientes de confirmar con el profesor (por ejemplo, qué significa exactamente "Aplazado").

## 9. Empezar de cero

Para repetir todo con la base limpia, vuelve a ejecutar `sql/trabajos_grado.sql` (borra todo y deja solo el `admin`) y crea de nuevo los usuarios.

## 10. Cómo reportar lo que encuentres

Mándalo como un **Issue** en GitHub (pestaña *Issues* del repositorio) o por mensaje, **uno por error**, con:

1. **Qué esperabas** y **qué pasó**.
2. **Usuario y rol** con el que estabas.
3. **Página** (la dirección de la barra) y **los pasos** para repetirlo.
4. **Captura de pantalla**. Si apareció una página de error de Tomcat, copia el texto del mensaje.

También sirven las sugerencias de diseño o de uso: dime qué te pareció confuso aunque no sea un error.
