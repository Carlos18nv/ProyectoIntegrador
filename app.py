from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, session, flash
from sqlalchemy import text
from config import Config
from models import db, Usuario, Propiedad, Casa, Departamento, Terreno, Visita, Compra
from auth import login_requerido

app = Flask(__name__)
app.config.from_object(Config)
db.init_app(app)


# ── Publico: inicio, busqueda y detalle ───────────────────────────

@app.route("/")
def inicio():
    destacadas = Propiedad.query.filter_by(activo=True, estado="disponible").limit(4).all()
    return render_template("index.html", propiedades=destacadas)


@app.route("/buscar")
def buscar():
    return render_template("buscar.html")


@app.route("/resultados")
def resultados():
    query = Propiedad.query.filter_by(activo=True, estado="disponible")

    tipo = request.args.get("tipo")
    sector = request.args.get("sector")
    presupuesto_max = request.args.get("presupuesto_max")
    dormitorios_min = request.args.get("dormitorios_min")
    mascotas = request.args.get("mascotas")

    if tipo:
        query = query.filter(Propiedad.tipo == tipo)
    if sector:
        query = query.filter(Propiedad.sector == sector)
    if presupuesto_max:
        query = query.filter(Propiedad.precio <= presupuesto_max)
    if dormitorios_min:
        query = query.filter(Propiedad.dormitorios >= dormitorios_min)
    if mascotas == "on":
        query = query.filter(Propiedad.permite_mascotas.is_(True))

    propiedades = query.all()
    return render_template("resultados.html", propiedades=propiedades)


@app.route("/propiedad/<int:propiedad_id>")
def detalle_propiedad(propiedad_id):
    propiedad = Propiedad.query.get_or_404(propiedad_id)
    return render_template("detalle.html", propiedad=propiedad)


@app.route("/propiedad/<int:propiedad_id>/mapa")
def mapa_propiedad(propiedad_id):
    propiedad = Propiedad.query.get_or_404(propiedad_id)
    return render_template("mapa.html", propiedad=propiedad)


# ── Publico: agendar visita (sin login, tal como el Figma) ────────

@app.route("/propiedad/<int:propiedad_id>/agendar-visita", methods=["GET", "POST"])
def agendar_visita(propiedad_id):
    propiedad = Propiedad.query.get_or_404(propiedad_id)

    if request.method == "POST":
        visita = Visita(
            id_propiedad=propiedad_id,
            nombre_cliente=request.form["nombre_cliente"],
            telefono=request.form["telefono"],
            correo=request.form["correo"],
            fecha_visita=request.form["fecha_visita"],
            hora_visita=request.form["hora_visita"],
            mensaje=request.form.get("mensaje"),
            codigo_solicitud="TEMP",
        )
        db.session.add(visita)
        db.session.flush()
        visita.codigo_solicitud = f"VIS-{visita.id:04d}"
        db.session.commit()

        return redirect(url_for("confirmacion_visita", codigo=visita.codigo_solicitud))

    return render_template("agendar_visita.html", propiedad=propiedad)


@app.route("/visita/confirmacion/<codigo>")
def confirmacion_visita(codigo):
    visita = Visita.query.filter_by(codigo_solicitud=codigo).first_or_404()
    return render_template("confirmacion.html", visita=visita)


# ── Panel interno: login ──────────────────────────────────────────

@app.route("/admin/login", methods=["GET", "POST"])
def admin_login():
    if request.method == "POST":
        email = request.form["email"].strip().lower()
        password = request.form["password"]
        usuario = Usuario.query.filter_by(email=email).first()

        if usuario and usuario.check_password(password):
            session["usuario_id"] = usuario.id 
            session["usuario_nombre"] = usuario.nombre
            flash(f"Bienvenido, {usuario.nombre}.", "success")
            return redirect(url_for("admin_dashboard"))
        flash("Correo o contrasena incorrectos.", "danger")
    return render_template("admin/login.html")
 

@app.route("/admin/logout")
def admin_logout():
    session.clear()
    flash("Sesion cerrada.", "success")
    return redirect(url_for("admin_login"))


@app.route("/admin")
@login_requerido
def admin_dashboard():
    total_propiedades = Propiedad.query.filter_by(activo=True).count()
    visitas_pendientes = Visita.query.filter_by(estado="pendiente").count()
    return render_template("admin/dashboard.html",
                            total_propiedades=total_propiedades,
                            visitas_pendientes=visitas_pendientes)


# ── Panel interno: CRUD de propiedades ────────────────────────────

@app.route("/admin/propiedades")
@login_requerido
def admin_propiedades():
    propiedades = Propiedad.query.filter_by(activo=True).all()
    return render_template("admin/propiedades.html", propiedades=propiedades)


@app.route("/admin/propiedades/nueva/casa", methods=["GET", "POST"])
@login_requerido
def nueva_casa():
    if request.method == "POST":
        casa = Casa(
            codigo=request.form["codigo"],
            titulo=request.form["titulo"],
            precio=request.form["precio"],
            area_m2=request.form["area_m2"],
            direccion=request.form["direccion"],
            sector=request.form.get("sector"),
            descripcion=request.form.get("descripcion"),
            dormitorios=request.form.get("dormitorios"),
            banos=request.form.get("banos"),
            permite_mascotas=bool(request.form.get("permite_mascotas")),
            num_pisos=request.form.get("num_pisos"),
            imagen_url=request.form.get("imagen_url") or None,
            id_agente=session["usuario_id"],
        )
        db.session.add(casa)
        db.session.commit()
        flash("Casa publicada correctamente.", "success")
        return redirect(url_for("admin_propiedades"))
    return render_template("admin/nueva_casa.html")

@app.route("/admin/propiedades/nueva/departamento", methods=["GET", "POST"])
@login_requerido
def nueva_departamento():
    if request.method == "POST":
        departamento = Departamento(
            codigo=request.form["codigo"],
            titulo=request.form["titulo"],
            precio=request.form["precio"],
            area_m2=request.form["area_m2"],
            direccion=request.form["direccion"],
            sector=request.form.get("sector"),
            descripcion=request.form.get("descripcion"),
            dormitorios=request.form.get("dormitorios"),
            banos=request.form.get("banos"),
            permite_mascotas=bool(request.form.get("permite_mascotas")),
            imagen_url=request.form.get("imagen_url") or None,
            id_agente=session["usuario_id"],
        )
        db.session.add(departamento)
        db.session.commit()
        flash("Departamento publicado correctamente.", "success")
        return redirect(url_for("admin_propiedades"))
    return render_template("admin/nueva_departamento.html")


@app.route("/admin/propiedades/nueva/terreno", methods=["GET", "POST"])
@login_requerido
def nueva_terreno():
    if request.method == "POST":
        terreno = Terreno(
            codigo=request.form["codigo"],
            titulo=request.form["titulo"],
            precio=request.form["precio"],
            area_m2=request.form["area_m2"],
            direccion=request.form["direccion"],
            sector=request.form.get("sector"),
            descripcion=request.form.get("descripcion"), 
            imagen_url=request.form.get("imagen_url") or None,
            id_agente=session["usuario_id"],
        )
        db.session.add(terreno)
        db.session.commit()
        flash("Terreno publicado correctamente.", "success")
        return redirect(url_for("admin_propiedades"))
    return render_template("admin/nueva_terreno.html")


# nueva_departamento y nueva_terreno siguen la misma estructura,
# cambiando los campos propios de cada tipo


@app.route("/admin/propiedades/<int:propiedad_id>/editar", methods=["GET", "POST"])
@login_requerido
def editar_propiedad(propiedad_id):
    propiedad = Propiedad.query.get_or_404(propiedad_id)
    if request.method == "POST":
        propiedad.precio = request.form["precio"]
        propiedad.descripcion = request.form.get("descripcion")
        db.session.commit()
        flash("Propiedad actualizada.", "success")
        return redirect(url_for("admin_propiedades"))
    return render_template("admin/editar_propiedad.html", propiedad=propiedad)


@app.route("/admin/propiedades/<int:propiedad_id>/desactivar", methods=["POST"])
@login_requerido
def desactivar_propiedad(propiedad_id):
    propiedad = Propiedad.query.get_or_404(propiedad_id)
    propiedad.activo = False
    db.session.commit()
    flash("Propiedad desactivada.", "success")
    return redirect(url_for("admin_propiedades"))


# ── Panel interno: visitas ─────────────────────────────────────────

@app.route("/admin/visitas")
@login_requerido
def admin_visitas():
    visitas = Visita.query.filter_by(estado="pendiente").order_by(Visita.fecha_visita).all()
    return render_template("admin/visitas.html", visitas=visitas)


@app.route("/admin/visitas/<int:visita_id>/completar", methods=["POST"])
@login_requerido
def completar_visita(visita_id):
    visita = Visita.query.get_or_404(visita_id)
    visita.estado = "realizada"
    db.session.commit()
    flash("Visita marcada como realizada.", "success")
    return redirect(url_for("admin_visitas"))


# ── Panel interno: modulo de compras (usa el PROCEDURE de Postgres) ──

@app.route("/admin/compras/nueva", methods=["GET", "POST"])
@login_requerido
def nueva_compra():
    propiedades = Propiedad.query.filter_by(activo=True, estado="disponible").all()

    if request.method == "POST":
        try:
            db.session.execute(
                text("CALL registrar_compra(:p_prop, :p_nombre, :p_monto, :p_visita, :p_reg)"),
                {
                    "p_prop": request.form["id_propiedad"],
                    "p_nombre": request.form["nombre_comprador"],
                    "p_monto": request.form["monto"],
                    "p_visita": request.form.get("id_visita") or None,
                    "p_reg": session["usuario_id"],
                },
            )
            db.session.commit()
            flash("Compra registrada, la propiedad se marco como vendida.", "success")
            return redirect(url_for("admin_propiedades"))
        except Exception as error:
            db.session.rollback()
            flash(f"No se pudo registrar la compra: {error}", "danger")

    return render_template("admin/nueva_compra.html", propiedades=propiedades)


@app.route("/admin/reportes")
@login_requerido
def admin_reportes():
    ventas = db.session.execute(
        text("SELECT * FROM reporte_ventas(:inicio, :fin)"),
        {"inicio": request.args.get("inicio", "2020-01-01"),
         "fin": request.args.get("fin", datetime.utcnow().date())},
    ).fetchall()

    visitas_pendientes = db.session.execute(
        text("SELECT * FROM reporte_visitas_pendientes()")
    ).fetchall()

    return render_template("admin/reportes.html", ventas=ventas, visitas_pendientes=visitas_pendientes)


if __name__ == "__main__":
    app.run(debug=True)