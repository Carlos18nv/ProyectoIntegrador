from datetime import datetime
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash

db = SQLAlchemy()


class Usuario(db.Model):
    __tablename__ = "usuarios"

    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    rol = db.Column(db.String(20), nullable=False, default="agente")
    fecha_registro = db.Column(db.DateTime, default=datetime.utcnow)

    def set_password(self, password_plano):
        self.password_hash = generate_password_hash(password_plano)

    def check_password(self, password_plano):
        return check_password_hash(self.password_hash, password_plano)

    def es_admin(self):
        return self.rol == "admin"


class Propiedad(db.Model):
    __tablename__ = "propiedades"

    id = db.Column(db.Integer, primary_key=True)
    codigo = db.Column(db.String(20), unique=True, nullable=False)
    titulo = db.Column(db.String(150), nullable=False)
    precio = db.Column(db.Numeric(12, 2), nullable=False)
    area_m2 = db.Column(db.Numeric(8, 2), nullable=False)
    direccion = db.Column(db.String(200), nullable=False)
    sector = db.Column(db.String(80))
    descripcion = db.Column(db.Text)
    dormitorios = db.Column(db.Integer)
    banos = db.Column(db.Integer)
    permite_mascotas = db.Column(db.Boolean, default=False)

    num_pisos = db.Column(db.Integer, nullable=True)
    tiene_ascensor = db.Column(db.Boolean, nullable=True)
    uso_suelo = db.Column(db.String(50), nullable=True)

    estado = db.Column(db.String(20), nullable=False, default="disponible")
    id_agente = db.Column(db.Integer, db.ForeignKey("usuarios.id"))
    activo = db.Column(db.Boolean, default=True)
    fecha_publicacion = db.Column(db.DateTime, default=datetime.utcnow)

    tipo = db.Column(db.String(20))
    imagen_url = db.Column(db.String(300))

    __mapper_args__ = {
        "polymorphic_identity": "propiedad",
        "polymorphic_on": tipo,
    }

    def descripcion_detalle(self):
        return f"{self.titulo}, {self.area_m2} m2"


class Casa(Propiedad):
    __mapper_args__ = {"polymorphic_identity": "casa"}

    def descripcion_detalle(self):
        return f"Casa de {self.num_pisos} piso(s), {self.dormitorios} dormitorios"


class Departamento(Propiedad):
    __mapper_args__ = {"polymorphic_identity": "departamento"}

    def descripcion_detalle(self):
        ascensor = "con ascensor" if self.tiene_ascensor else "sin ascensor"
        return f"Departamento {ascensor}, {self.dormitorios} dormitorios"


class Terreno(Propiedad):
    __mapper_args__ = {"polymorphic_identity": "terreno"}

    def descripcion_detalle(self):
        return f"Terreno de {self.area_m2} m2, uso de suelo: {self.uso_suelo}"


class Visita(db.Model):
    __tablename__ = "visitas"

    id = db.Column(db.Integer, primary_key=True)
    codigo_solicitud = db.Column(db.String(20), unique=True, nullable=False)
    id_propiedad = db.Column(db.Integer, db.ForeignKey("propiedades.id"), nullable=False)
    nombre_cliente = db.Column(db.String(100), nullable=False)
    telefono = db.Column(db.String(20), nullable=False)
    correo = db.Column(db.String(120), nullable=False)
    fecha_visita = db.Column(db.Date, nullable=False)
    hora_visita = db.Column(db.String(20), nullable=False)
    mensaje = db.Column(db.Text)
    estado = db.Column(db.String(20), nullable=False, default="pendiente")
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)

    propiedad = db.relationship("Propiedad")


class Compra(db.Model):
    __tablename__ = "compras"

    id = db.Column(db.Integer, primary_key=True)
    id_propiedad = db.Column(db.Integer, db.ForeignKey("propiedades.id"), nullable=False)
    id_visita = db.Column(db.Integer, db.ForeignKey("visitas.id"), nullable=True)
    nombre_comprador = db.Column(db.String(100), nullable=False)
    monto = db.Column(db.Numeric(12, 2), nullable=False)
    id_registrado_por = db.Column(db.Integer, db.ForeignKey("usuarios.id"))
    estado = db.Column(db.String(20), nullable=False, default="confirmada")
    fecha_compra = db.Column(db.DateTime, default=datetime.utcnow)