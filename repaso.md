# 📘 Guía de Repaso para Sustentación: Proyecto Inmobiliaria

Este documento está diseñado para ayudarte a estudiar y entender rápidamente **dónde está** y **cómo funciona** cada punto exigido en la rúbrica del proyecto. Está redactado en un lenguaje sencillo, claro y directo para que puedas explicarlo con total seguridad durante tu sustentación.

> 🎨 **Prototipo e Interfaz de Diseño en Figma**: [Enlace al diseño oficial en Figma](https://www.figma.com/design/jbzUldXoyvPxNHptej225I/FIGMA?node-id=147-15&m=dev)

---

## 📑 Índice de Rúbrica

- [Sección 1: Base de Datos I](#1-base-de-datos-i)
  - [1.1 Modelo de Datos, Entidad-Relación, Normalización, PK y FK](#11-modelo-de-datos-entidad-relación-normalización-pk-y-fk)
  - [1.2 Restricciones (CHECK, DEFAULT, UNIQUE), Trigger y Stored Procedure](#12-restricciones-check-default-unique-trigger-y-stored-procedure)
  - [1.3 Reportes con JOIN de Múltiples Tablas](#13-reportes-con-join-de-múltiples-tablas)
  - [1.4 Seguridad, Control de Acceso y Respaldo de la BD](#14-seguridad-control-de-acceso-y-respaldo-de-la-bd)
- [Sección 3: Programación Orientada a Objetos (POO)](#3-programación-orientada-a-objetos-poo)
  - [3.1 Diagrama de Clases](#31-diagrama-de-clases)
  - [3.2 Representación del Dominio del Problema](#32-representación-del-dominio-del-problema)
  - [3.3 Encapsulamiento, Abstracción, Modularidad, Herencia y Polimorfismo](#33-encapsulamiento-abstracción-modularidad-herencia-y-polimorfismo)
  - [3.4 Organización, Buenas Prácticas y Documentación](#34-organización-buenas-prácticas-y-documentación)

---

# 1. Base de Datos I

### 1.1 Modelo de Datos, Entidad-Relación, Normalización, PK y FK

#### 📍 ¿Dónde está en el proyecto?
En el archivo `database/scriptinmobiliaria.sql` y en las definiciones de las clases dentro de `models.py`.

#### 💡 ¿Cómo explicarlo de forma sencilla?
"El sistema utiliza **4 tablas relacionales** organizadas de forma limpia sin duplicar información (normalización):"

1. **`usuarios`**: Guarda únicamente al personal de la inmobiliaria (administradores y agentes).
2. **`propiedades`**: Guarda todos los inmuebles (casas, departamentos y terrenos) en una sola tabla organizada.
3. **`visitas`**: Guarda las solicitudes de clientes que quieren conocer una propiedad.
4. **`compras`**: Guarda el registro formal cuando se concreta la venta de una propiedad.

#### 🔑 Conceptos clave para la defensa:
- **Primary Key (PK - Clave Primaria)**: Es la cédula única de cada registro. En todas las tablas es la columna `id` (autoincremental).
- **Foreign Key (FK - Clave Foránea)**: Es el enlace entre tablas. Por ejemplo:
  - En `propiedades`, la columna `id_agente` apunta al `id` del usuario que la administra.
  - En `visitas`, la columna `id_propiedad` apunta al `id` del inmueble solicitado.
  - En `compras`, la columna `id_propiedad` apunta al inmueble vendido y `id_registrado_por` apunta al agente que cerró la venta.
- **Normalización**: No guardamos los datos del agente repetidos en cada propiedad; solo guardamos su `id_agente` (FK), evitando inconsistencias y datos duplicados.

---

### 1.2 Restricciones (CHECK, DEFAULT, UNIQUE), Trigger y Stored Procedure

#### 📍 ¿Dónde está en el proyecto?
En `database/scriptinmobiliaria.sql`, en `models.py` y en la ruta de compras en `app.py`.

#### 💡 ¿Cómo explicarlo de forma sencilla?

##### A) Restricciones de Integridad (Reglas en las columnas):
- **`CHECK` (Validaciones)**: Garantiza que no se guarden datos absurdos.
  - Ejemplo: `precio CHECK (precio > 0)` impide registrar una propiedad con precio 0 o negativo.
  - Ejemplo: `rol CHECK (rol IN ('agente', 'admin'))` sólo permite esos dos roles.
- **`DEFAULT` (Valores por defecto)**: Si no se envía un dato, PostgreSQL le asigna uno automático.
  - Ejemplo: `estado DEFAULT 'disponible'` en propiedades, `activo DEFAULT TRUE`.
- **`UNIQUE` (Valores no repetidos)**:
  - Ejemplo: `email UNIQUE` en usuarios (dos agentes no pueden tener el mismo correo).
  - Ejemplo: `codigo UNIQUE` en propiedades (ej. `CAS001`) y `codigo_solicitud UNIQUE` en visitas (ej. `VIS-0001`).

##### B) Trigger (Disparador Automático):
- **Nombre**: `trg_compra_confirmada` / `actualizar_estado_propiedad()`
- **¿Qué hace?**: Cada vez que registramos una venta en la tabla `compras`, este disparador salta **automáticamente** en PostgreSQL y cambia el estado de esa propiedad de `'disponible'` a `'vendida'`.
- **Ventaja**: El programador no tiene que acordarse de cambiar manualmente el estado del inmueble en la tabla de propiedades; la base de datos lo hace sola por seguridad.

##### C) Stored Procedure (Procedimiento Almacenado):
- **Nombre**: `registrar_compra(...)`
- **¿Qué hace?**: Es una función almacenada en la base de datos que se llama desde Python mediante `CALL registrar_compra(...)`.
- **Regla de negocio crítica**: Antes de insertar la compra, consulta si la propiedad existe y si ya fue vendida. Si la propiedad ya está vendida, **cancela la operación y lanza un error** (`RAISE EXCEPTION 'La propiedad ya fue vendida'`).
- **¿Cómo se conecta con Flask?**: En `app.py`, la función `nueva_compra()` ejecuta este procedimiento dentro de un bloque `try/except`. Si el procedimiento rechaza la venta, Flask captura ese error y le muestra una alerta roja al usuario en pantalla.

---

### 1.3 Reportes con JOIN de Múltiples Tablas

#### 📍 ¿Dónde está en el proyecto?
En las funciones PL/pgSQL de `database/scriptinmobiliaria.sql` y en la ruta `/admin/reportes` de `app.py`.

#### 💡 ¿Cómo explicarlo de forma sencilla?
"Para cumplir con el requerimiento de reportes complejos, creamos dos funciones SQL que cruzan datos entre varias tablas mediante cláusulas `JOIN`:"

1. **Reporte 1: Ventas Realizadas (`reporte_ventas`)**:
   - **Tablas que une**: `compras` + `propiedades` + `usuarios`.
   - **¿Qué muestra?**: El título del inmueble, el nombre del comprador, el monto final cobrado, la fecha de la venta y el nombre del agente que la registró.

2. **Reporte 2: Visitas Pendientes (`reporte_visitas_pendientes`)**:
   - **Tablas que une**: `visitas` + `propiedades`.
   - **¿Qué muestra?**: El código de solicitud (`VIS-0001`), el nombre del cliente invitado, el título de la propiedad a visitar, la fecha y la hora programada.

---

### 1.4 Seguridad, Control de Acceso y Respaldo de la BD

#### 📍 ¿Dónde está en el proyecto?
En `auth.py`, `models.py` (`set_password` / `check_password`), `app.py` y en la documentación del `README.md`.

#### 💡 ¿Cómo explicarlo de forma sencilla?

1. **Encriptación de Contraseñas (Calidad de la información)**:
   - Las contraseñas del personal **nunca** se guardan en texto plano en la base de datos.
   - Usamos la librería `werkzeug.security` que convierte la contraseña en un hash encriptado mediante `set_password("mi_clave")`.

2. **Control de Acceso (Protección de rutas)**:
   - El sitio público es libre (cualquier visitante puede buscar y agendar visitas).
   - Sin embargo, las rutas administrativas (`/admin`, `/admin/propiedades`, `/admin/compras`) están protegidas con el decorador personalizado `@login_requerido` de `auth.py`. Si alguien intenta entrar sin iniciar sesión, es redirigido automáticamente al login.

3. **Estrategia de Respaldo (Backup & Restore)**:
   - Explicamos la estrategia usando la herramienta estándar de PostgreSQL `pg_dump`:
   - Para sacar respaldo: `pg_dump -U postgres -d inmobiliaria > respaldo.sql`
   - Para restaurar en otro servidor: `psql -U postgres -d inmobiliaria < respaldo.sql` (o usando el script `database/scriptinmobiliaria.sql`).

---

# 3. Programación Orientada a Objetos (POO)

### 3.1 Diagrama de Clases

#### 📍 ¿Dónde está en el proyecto?
Está materializado en las clases declaradas en el archivo `models.py`.

#### 💡 ¿Cómo explicarlo de forma sencilla?
"El diseño del código sigue un diagrama de clases donde identificamos las entidades del negocio inmobiliario con sus atributos (propiedades), métodos (comportamientos) y cómo se relacionan entre sí."

- **Clase Padre**: `Propiedad` (atributos generales: `id`, `titulo`, `precio`, `area_m2`, `sector`).
- **Clases Hijas que heredan de Propiedad**: `Casa` (agrega `num_pisos`), `Departamento` (agrega `tiene_ascensor`), `Terreno` (agrega `uso_suelo`).
- **Otras Entidades del sistema**: `Usuario` (agentes/admin), `Visita` (solicitudes públicas) y `Compra` (ventas cerradas).

---

### 3.2 Representación del Dominio del Problema

#### 📍 ¿Dónde está en el proyecto?
En todo `models.py` y en los formularios de `app.py`.

#### 💡 ¿Cómo explicarlo de forma sencilla?
"Nuestras clases en Python representan exactamente los elementos del mundo real de una inmobiliaria:"
- Una **Casa** no es lo mismo que un **Terreno**; por eso cada tipo de propiedad tiene sus propios datos específicos.
- Un **Cliente** en el prototipo de Figma no crea cuenta de usuario; solo llena un formulario rápido y se registra un objeto `Visita` con un código único `VIS-XXXX`.
- Las funcionalidades requeridas (publicar inmuebles, agendar citas, consultar catálogo, cerrar ventas) se ejecutan manipulando instancias de estas clases.

---

### 3.3 Encapsulamiento, Abstracción, Modularidad, Herencia y Polimorfismo

#### 📍 ¿Dónde está en el proyecto?
Principalmente en `models.py` y en la estructura general del proyecto.

#### 💡 ¿Cómo explicar los 5 Pilares de la POO con ejemplos de nuestro código?

| Pilar de POO | ¿Dónde se ve en el código? | Explicación sencilla sin tecnicismos |
|---|---|---|
| **Abstracción** | Clase `Propiedad` en `models.py` | Modelamos la idea general de un inmueble agrupando sus características esenciales (precio, dirección, área) sin preocuparnos por los detalles de la base de datos. |
| **Encapsulamiento** | Métodos `set_password()` y `check_password()` en `Usuario` | Protegemos el atributo sensible de la contraseña. El mundo exterior no accede directo a la clave, sino a través de métodos seguros que la encriptan o la verifican. |
| **Modularidad** | Separación en archivos (`models.py`, `app.py`, `config.py`, `auth.py`) | El código no está en una sola masa gigante. Cada archivo tiene una responsabilidad única y clara (modular). |
| **Herencia** | `class Casa(Propiedad):`, `class Departamento(Propiedad):`, `class Terreno(Propiedad):` | Las clases `Casa`, `Departamento` y `Terreno` heredan todos los campos de `Propiedad` (título, precio, dirección) sin necesidad de volver a escribirlos. Reutilizamos código al 100%. |
| **Polimorfismo** | Método `descripcion_detalle()` en `models.py` | El método se llama exactamente igual en todas las propiedades, pero se comporta distinto según la clase real del objeto: <br>• En **Casa**: devuelve `"Casa de 2 pisos, 3 dormitorios"`.<br>• En **Departamento**: devuelve `"Departamento con ascensor, 2 dormitorios"`.<br>• En **Terreno**: devuelve `"Terreno de 500 m2, uso de suelo: residencial"`. |

---

### 3.4 Organización, Buenas Prácticas y Documentación

#### 📍 ¿Dónde está en el proyecto?
En todo el repositorio: estructura de carpetas (`static`, `templates`, `database`), variables de entorno (`.env`), nombrado de variables y comentarios en el código.

#### 💡 ¿Cómo explicarlo de forma sencilla?
1. **Limpieza y Estructura Estándar de Flask**:
   - Las vistas HTML están separadas en `templates/` (con subcarpeta `admin/` para el panel interno).
   - Los estilos CSS e imágenes están en `static/`.
   - Las sentencias SQL pesadas de la base de datos están en la carpeta `database/`.
2. **Nombres Descriptivos en Español**:
   - Variables y funciones auto-explicativas como `nombre_cliente`, `agendar_visita()`, `precio_max`.
3. **Seguridad en la Configuración**:
   - Las claves secretas y contraseñas de la base de datos no están escritas directamente en el código ("hardcoded"), sino en un archivo `.env` que se lee a través de `config.py`.
4. **Documentación Completa**:
   - Contamos con un `README.md` detallado para la replicación del proyecto y un archivo `repaso.md` para la sustentación.

---

## 🎯 Resumen de 1 Minuto para Romper el Hielo en la Sustentación

> *"Profesor, nuestro proyecto consiste en una plataforma inmobiliaria desarrollada con Flask y PostgreSQL. Organizamos el sistema respetando fielmente el diseño de Figma: un **sitio público** donde los clientes pueden buscar propiedades con filtros dinámicos y agendar visitas como invitados obteniendo un código de confirmación `VIS-XXXX`, y un **panel interno privado** para agentes.*
>
> *En la **base de datos**, aplicamos 4 tablas normalizadas con claves primarias y foráneas, restricciones `CHECK` y `UNIQUE`, un **Trigger** que cambia automáticamente el estado del inmueble a 'vendida' cuando se registra una compra, y un **Stored Procedure** que valida como regla de negocio crítica que un inmueble no se pueda vender dos veces.*
>
> *En el **código Python**, aplicamos **POO** utilizando herencia y polimorfismo con la clase padre `Propiedad` y las clases derivadas `Casa`, `Departamento` y `Terreno`, las cuales sobrescriben el método `descripcion_detalle()`. Todo el sistema cumple estrictamente con los puntos de la rúbrica."*
