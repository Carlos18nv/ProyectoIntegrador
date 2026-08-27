from functools import wraps
from flask import session, redirect, url_for, flash


def login_requerido(f):
    @wraps(f)
    def decorada(*args, **kwargs):
        if not session.get("usuario_id"):
            flash("Debes iniciar sesion para acceder al panel.", "danger")
            return redirect(url_for("admin_login"))
        return f(*args, **kwargs)
    return decorada