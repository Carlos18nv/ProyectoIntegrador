# Sistema de Gestión Inmobiliaria 🏡

Plataforma web para la gestión de bienes raíces desarrollada con **Python (Flask)**, **PostgreSQL**, **Flask-SQLAlchemy** y **HTML5/CSS3 responsivo** (diseñado a partir de Figma).

El sistema combina un **sitio web público** enfocado en la experiencia del cliente (búsqueda, filtrado y agendamiento de visitas sin requerir inicio de sesión) con un **panel administrativo interno** para agentes y administradores (gestión CRUD de inmuebles, seguimiento de visitas, módulo de ventas/compras con procedimientos almacenados y reportes dinámicos).

---

## 📋 Tabla de Contenidos
- [Resumen del Proyecto](#-resumen-del-proyecto)
- [Características Principales](#-características-principales)
- [Rúbrica y Arquitectura del Sistema](#-rúbrica-y-arquitectura-del-sistema)
- [Requisitos Previos](#-requisitos-previos)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Guía Paso a Paso para Replicar el Proyecto](#-guía-paso-a-paso-para-replicar-el-proyecto)
  - [1. Clonar o Descargar el Proyecto](#1-clonar-o-descargar-el-proyecto)
  - [2. Crear y Activar el Entorno Virtual](#2-crear-y-activar-el-entorno-virtual)
  - [3. Instalar Dependencias](#3-instalar-dependencias)
  - [4. Configurar la Base de Datos PostgreSQL](#4-configurar-la-base-de-datos-postgresql)
  - [5. Configurar el Archivo `.env`](#5-configurar-el-archivo-env)
  - [6. Inicialización de la Base de Datos (Opciones de Replicación)](#6-inicialización-de-la-base-de-datos-opciones-de-replicación)
    - [🌟 Opción 1 (Primera Opción / Recomendada): Restauración Directa mediante Script SQL](#-opción-1-primera-opción--recomendada-restauración-directa-mediante-script-sql)
    - [🛠️ Opción 2: Inicialización mediante Python y Sentencias SQL Manuales](#️-opción-2-inicialización-mediante-python-y-sentencias-sql-manuales)
  - [7. Ejecutar la Aplicación](#7-ejecutar-la-aplicación)
- [Credenciales de Prueba](#-credenciales-de-prueba)
- [Flujo de Verificación y Pruebas](#-flujo-de-verificación-y-pruebas)

---

## 💡 Resumen del Proyecto

Este proyecto resuelve de manera integral las necesidades operativas de una inmobiliaria:

1. **Sitio Público (Experiencia de Usuario sin Fricción)**:
   - Los visitantes navegan por el catálogo de inmuebles disponibles.
   - Filtros avanzados por tipo de inmueble (Casa, Departamento, Terreno), sector, presupuesto máximo, número de dormitorios y si se permiten mascotas.
   - **Agendamiento de Visitas en modo Invitado**: El usuario llena un formulario básico y obtiene al instante un **código de solicitud único** (ejemplo: `VIS-0001`), idéntico al prototipo de Figma.

2. **Panel Interno Administrativo (Staff de Inmobiliaria)**:
   - Autenticación segura mediante contraseñas encriptadas (hashes Werkzeug).
   - Control de acceso por roles (`admin`, `agente`).
   - CRUD de propiedades en base de datos.
   - Módulo de compras/ventas que invoca un **Stored Procedure** nativo en PostgreSQL (`registrar_compra`) para garantizar que un inmueble no pueda venderse dos veces.
   - **Triggers automáticos** que actualizan el estado del inmueble a `vendida` tras una compra confirmada.
   - **Módulo de Reportes** que ejecuta funciones con `JOIN` relacionales.

---

## ✨ Características Principales

- **Programación Orientada a Objetos (POO)**: Jerarquía de clases con herencia y polimorfismo (`Propiedad` $\rightarrow$ `Casa`, `Departamento`, `Terreno`) implementada mediante mapeo polimórfico de tabla única (*Single Table Inheritance*) en SQLAlchemy.
- **Seguridad Integrada**: Encriptación de claves, sesiones HTTP seguras, y restricción de rutas privadas con decoradores (`@login_requerido`).
- **Diseño Responsivo**: Plantillas HTML5 organizadas con Jinja2 (`base.html`) y CSS unificado con media queries (`mobile`, `tablet`, `desktop`).

---

## 📐 Rúbrica y Arquitectura del Sistema

| Punto | Requerimiento Técnico | Solución Implementada |
|---|---|---|
| **1.1** | Modelo de datos, PK, FK, normalización | 4 tablas relacionales (`usuarios`, `propiedades`, `visitas`, `compras`) con claves primarias y foráneas explícitas. |
| **1.2** | CHECK / DEFAULT / UNIQUE, triggers y stored procedures | Restricciones `CHECK` en montos y precios (> 0), `UNIQUE` en correos, códigos de propiedad y visitas. Trigger `trg_compra_confirmada` y Stored Procedure `registrar_compra`. |
| **1.3** | Reportes con JOIN relacionales | Funciones de PostgreSQL `reporte_ventas` y `reporte_visitas_pendientes`. |
| **1.4** | Medidas básicas de seguridad | Encriptación bcrypt/pbkdf2 de contraseñas de personal, decoradores de autenticación y respaldo de BD. |
| **2.1 - 2.3** | Diseño responsivo y fidelidad Figma | Flujo público exacto al prototipo (búsqueda, detalle, agendar visita con código `VIS-XXXX`). |
| **3.1 - 3.4** | POO, Herencia y Polimorfismo | Clases `Casa`, `Departamento` y `Terreno` heredan de `Propiedad` y sobrescriben `descripcion_detalle()`. |
| **5.0** | CRUD y Módulo de Compras | Gestión completa de inmuebles y registro de ventas desde el panel de control. |

---

## 🛠️ Requisitos Previos

Asegúrate de contar con lo siguiente instalado en tu equipo:

- **Python**: Versión 3.10 o superior.
- **PostgreSQL**: Servidor de base de datos activo (ej. v14, v15, v16 o v18).
- **Herramienta SQL (Opcional)**: `psql` (línea de comandos), **pgAdmin 4** o **DBeaver** para ejecutar sentencias SQL.

---

## 📁 Estructura del Proyecto

```text
inmobiliaria/
│
├── .env                       # Variables de entorno (Credenciales de BD y Secret Key)
├── .gitignore                 # Archivos ignorados por Git
├── app.py                     # Aplicación principal Flask (Rutas públicas y administrativas)
├── auth.py                    # Decoradores de autenticación y seguridad
├── config.py                  # Lectura de variables de entorno y configuración de SQLAlchemy
├── init_db.py                 # Script de creación de tablas SQLAlchemy y datos de prueba
├── models.py                  # Modelos de datos en POO (Propiedad, Casa, Departamento, etc.)
├── README.md                  # Guía de replicación del proyecto
│
├── database/                  # Scripts de base de datos
│   └── scriptinmobiliaria.sql # Dump completo de BD (Tablas, datos, triggers, stored procedures)
│
├── static/                    # Archivos estáticos
│   ├── css/                   # Estilos CSS generales y responsivos
│   └── imagenes/              # Imágenes de los inmuebles y assets
│
└── templates/                 # Plantillas HTML con Jinja2
    ├── base.html              # Layout base (Header, Footer, Navegación)
    ├── index.html             # Inicio / Propiedades destacadas
    ├── buscar.html            # Vista de búsqueda con filtros
    ├── resultados.html        # Galería de resultados filtrados
    ├── detalle.html           # Ficha detallada del inmueble
    ├── agendar_visita.html    # Formulario público de visita
    ├── confirmacion.html      # Pantalla de confirmación con código VIS-XXXX
    └── admin/                 # Vistas del panel de administración
        ├── login.html         # Login del personal
        ├── dashboard.html     # Resumen de métricas
        ├── propiedades.html   # Tabla CRUD de inmuebles
        ├── nueva_casa.html    # Formulario de alta de casa
        ├── editar_propiedad.html # Formulario de edición
        ├── visitas.html       # Control de citas agendadas
        ├── nueva_compra.html  # Formulario para registrar ventas (Stored Procedure)
        └── reportes.html      # Vista de reportes de ventas y visitas
```

---

## 🚀 Guía Paso a Paso para Replicar el Proyecto

Sigue exactamente estos pasos en orden para levantar el proyecto desde cero en cualquier máquina:

### 1. Clonar o Descargar el Proyecto
Abre la terminal en la carpeta donde deseas instalar el proyecto:
```bash
git clone <URL_DEL_REPOSITORIO>
cd inmobiliaria
```

---

### 2. Crear y Activar el Entorno Virtual

- **En Windows (PowerShell)**:
  ```powershell
  python -m venv venv
  .\venv\Scripts\Activate.ps1
  ```

- **En Windows (CMD)**:
  ```cmd
  python -m venv venv
  venv\Scripts\activate.bat
  ```

- **En macOS / Linux**:
  ```bash
  python3 -m venv venv
  source venv/bin/activate
  ```

---

### 3. Instalar Dependencias
Con el entorno virtual activado, instala los paquetes necesarios:
```bash
pip install Flask Flask-SQLAlchemy psycopg2-binary python-dotenv Werkzeug
```

---

### 4. Configurar la Base de Datos PostgreSQL
1. Abre tu cliente de PostgreSQL (pgAdmin, DBeaver o `psql`).
2. Crea una base de datos vacía llamada `inmobiliaria`:
```sql
CREATE DATABASE inmobiliaria;
```

---

### 5. Configurar el Archivo `.env`
Crea un archivo llamado `.env` en la raíz del proyecto (junto a `app.py`) y configura los parámetros de conexión de tu PostgreSQL local:

```env
DB_USER=postgres
DB_PASSWORD=tu_contrasena_postgres_aqui
DB_HOST=localhost
DB_PORT=5432
DB_NAME=inmobiliaria
SECRET_KEY=clave_secreta_super_segura_para_desarrollo_123
```

> ⚠️ **Nota**: Reemplaza `tu_contrasena_postgres_aqui` por la clave real de tu usuario de PostgreSQL.

---

### 6. Inicialización de la Base de Datos (Opciones de Replicación)

Puedes replicar la base de datos eligiendo una de las dos opciones a continuación. **La Opción 1 es la primera opción y la recomendada**, ya que deja lista toda la base de datos en un solo paso.

---

#### 🌟 Opción 1 (Primera Opción / Recomendada): Restauración Directa mediante Script SQL

Dentro de la carpeta `database/` se encuentra el archivo `scriptinmobiliaria.sql`, que contiene la estructura completa de la base de datos (tablas, secuencias, claves primarias y foráneas, restricciones CHECK/UNIQUE), los datos semilla iniciales, el **Stored Procedure** (`registrar_compra`), el **Trigger** (`actualizar_estado_propiedad`) y las **Funciones de Reporte**.

Para restaurar la base de datos usando este script:

- **Desde la Línea de Comandos (`psql`)**:
  ```bash
  psql -U postgres -d inmobiliaria -f database/scriptinmobiliaria.sql
  ```

- **Desde pgAdmin 4**:
  1. En el panel izquierdo, haz clic derecho sobre la base de datos `inmobiliaria` recién creada y selecciona **Query Tool** (Herramienta de Consultas).
  2. Haz clic en el ícono de carpeta **Open File** (Abrir Archivo) y selecciona `database/scriptinmobiliaria.sql`.
  3. Ejecuta todo el archivo haciendo clic en el botón de reproducción **Execute/Refresh (F5)**.

- **Desde DBeaver**:
  1. Conéctate a la base de datos `inmobiliaria`.
  2. Ve a **File -> Open File** y selecciona `database/scriptinmobiliaria.sql`.
  3. Ejecuta el script completo presionando **Alt + X** o el botón de ejecutar script SQL.

---

#### 🛠️ Opción 2: Inicialización mediante Python y Sentencias SQL Manuales

Si prefieres construir la base de datos paso a paso manualmente usando SQLAlchemy y la consola SQL:

##### A. Inicializar Tablas y Datos Semilla (Python)
Ejecuta el script `init_db.py`. Este script se encarga de crear las estructuras de las tablas base mediante SQLAlchemy e insertar los usuarios internos de prueba y propiedades iniciales:

```bash
python init_db.py
```

**Salida esperada**:
```text
Creando tablas...
Tablas creadas.
Usuarios internos y propiedades de prueba insertados.
```

##### B. Crear Procedimientos Almacenados, Triggers y Funciones (SQL)
Conéctate a la base de datos `inmobiliaria` mediante pgAdmin, DBeaver o `psql` y ejecuta las siguientes 4 sentencias SQL:

###### 1. Trigger para actualizar el estado del inmueble a 'vendida'
```sql
CREATE OR REPLACE FUNCTION actualizar_estado_propiedad()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.estado = 'confirmada' THEN
        UPDATE propiedades SET estado = 'vendida' WHERE id = NEW.id_propiedad;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_compra_confirmada
AFTER INSERT OR UPDATE ON compras
FOR EACH ROW
EXECUTE FUNCTION actualizar_estado_propiedad();
```

###### 2. Stored Procedure para registrar compras con validación de negocio
```sql
CREATE OR REPLACE PROCEDURE registrar_compra(
    p_id_propiedad INTEGER,
    p_nombre_comprador VARCHAR,
    p_monto NUMERIC,
    p_id_visita INTEGER DEFAULT NULL,
    p_id_registrado_por INTEGER DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_estado_actual VARCHAR(20);
BEGIN
    SELECT estado INTO v_estado_actual FROM propiedades WHERE id = p_id_propiedad;

    IF v_estado_actual IS NULL THEN
        RAISE EXCEPTION 'La propiedad % no existe', p_id_propiedad;
    END IF;

    IF v_estado_actual = 'vendida' THEN
        RAISE EXCEPTION 'La propiedad % ya fue vendida, no se puede registrar otra compra', p_id_propiedad;
    END IF;

    INSERT INTO compras (id_propiedad, id_visita, nombre_comprador, monto, id_registrado_por)
    VALUES (p_id_propiedad, p_id_visita, p_nombre_comprador, p_monto, p_id_registrado_por);
END;
$$;
```

###### 3. Función de Reporte 1: Ventas confirmadas con JOIN
```sql
CREATE OR REPLACE FUNCTION reporte_ventas(fecha_inicio DATE, fecha_fin DATE)
RETURNS TABLE(propiedad VARCHAR, comprador VARCHAR, monto NUMERIC, registrado_por VARCHAR, fecha TIMESTAMP) AS $$
BEGIN
    RETURN QUERY
    SELECT p.titulo, c.nombre_comprador, c.monto, u.nombre, c.fecha_compra
    FROM compras c
    JOIN propiedades p ON c.id_propiedad = p.id
    LEFT JOIN usuarios u ON c.id_registrado_por = u.id
    WHERE c.estado = 'confirmada'
      AND c.fecha_compra BETWEEN fecha_inicio AND fecha_fin;
END;
$$ LANGUAGE plpgsql;
```

###### 4. Función de Reporte 2: Visitas pendientes con JOIN
```sql
CREATE OR REPLACE FUNCTION reporte_visitas_pendientes()
RETURNS TABLE(codigo VARCHAR, cliente VARCHAR, propiedad VARCHAR, fecha DATE, hora VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT v.codigo_solicitud, v.nombre_cliente, p.titulo, v.fecha_visita, v.hora_visita
    FROM visitas v
    JOIN propiedades p ON v.id_propiedad = p.id
    WHERE v.estado = 'pendiente'
    ORDER BY v.fecha_visita, v.hora_visita;
END;
$$ LANGUAGE plpgsql;
```

---

### 7. Ejecutar la Aplicación
Inicia el servidor web de desarrollo de Flask:

```bash
python app.py
```

La aplicación se ejecutará en: `http://127.0.0.1:5000`

---

## 🔑 Credenciales de Prueba

Tanto la **Opción 1** (script SQL) como la **Opción 2** (`init_db.py`) crean los siguientes usuarios por defecto para acceder al panel administrativo (`http://127.0.0.1:5000/admin/login`):

| Rol | Correo Electrónico | Contraseña |
|---|---|---|
| **Administrador** | `admin@hogar.com` | `admin123` |
| **Agente Inmobiliario** | `agente@hogar.com` | `agente123` |

---

## 🧪 Flujo de Verificación y Pruebas

Para constatar que todo el sistema funciona correctamente:

1. **Sitio Público**:
   - Ingresa a `http://127.0.0.1:5000`.
   - Navega al buscador (`/buscar`) y aplica filtros (por ejemplo: Sector "Cumbaya" o filtro de mascotas).
   - Selecciona un inmueble para ver su detalle (`/propiedad/1`).
   - Haz clic en **Agendar Visita**, llena los datos del cliente y confirma. Verás la pantalla de éxito con tu código (ej. `VIS-0001`).

2. **Panel Interno (Administración)**:
   - Dirígete a `http://127.0.0.1:5000/admin/login` e inicia sesión con `agente@hogar.com` / `agente123`.
   - En el menú, revisa **Visitas Pendientes** (`/admin/visitas`) y comprueba que la solicitud agendada anteriormente aparece listada.
   - Ve a **Registrar Compra** (`/admin/compras/nueva`), selecciona el inmueble y registra la venta.
   - **Verificación de Negocio**: 
     - El formulario llama al Stored Procedure `registrar_compra`.
     - El Trigger de PostgreSQL cambia automáticamente el estado del inmueble a `vendida`.
     - Si intentas registrar nuevamente una compra sobre la misma propiedad, el procedimiento lanzará una excepción y Flask mostrará un mensaje de alerta impidiendo la duplicidad.
   - Ve a **Reportes** (`/admin/reportes`) para consultar la información consolidada mediante los procedimientos almacenados y funciones con `JOIN`.

---

## 📄 Respaldo de Base de Datos (Opcional)

Para generar una copia de seguridad rápida de la base de datos con `pg_dump`:
```bash
pg_dump -U postgres -d inmobiliaria > respaldo_inmobiliaria.sql
```
Para restaurarlo en otro equipo:
```bash
psql -U postgres -d inmobiliaria < respaldo_inmobiliaria.sql
```
