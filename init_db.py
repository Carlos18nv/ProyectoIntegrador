from datetime import date
from app import app
from models import db, Usuario, Casa, Departamento, Terreno

with app.app_context():
    print("Creando tablas...")
    db.drop_all()
    db.create_all()
    print("Tablas creadas.")

    admin = Usuario(nombre="Admin Principal", email="admin@hogar.com", rol="admin")
    admin.set_password("admin123")

    agente = Usuario(nombre="Agente Demo", email="agente@hogar.com", rol="agente")
    agente.set_password("agente123")

    db.session.add_all([admin, agente])
    db.session.commit()

    c1 = Casa(
        codigo="CAS001", titulo="Casa moderna en Cumbaya", precio=350000, area_m2=210,
        direccion="Cumbaya, Quito", sector="Cumbaya", dormitorios=3, banos=2, num_pisos=2,
        permite_mascotas=True, id_agente=agente.id,
        imagen_url="/static/imagenes/property-1.png",
    )
    d1 = Departamento(
        codigo="DEP001", titulo="Departamento con terraza", precio=145000, area_m2=120,
        direccion="Tumbaco, Quito", sector="Tumbaco", dormitorios=3, banos=2,
        tiene_ascensor=True, permite_mascotas=False, id_agente=agente.id,
        imagen_url="/static/imagenes/property-2.png",
    )
    t1 = Terreno(
        codigo="TER001", titulo="Terreno residencial", precio=60000, area_m2=500,
        direccion="Quitumbe, Quito", sector="Quitumbe", uso_suelo="residencial",
        id_agente=agente.id,
        imagen_url="/static/imagenes/property-3.png",
    )

    db.session.add_all([c1, d1, t1])
    db.session.commit()
    print("Usuarios internos y propiedades de prueba insertados.")