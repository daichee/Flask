from flask import Blueprint, render_template
from app.routes.main import main_bp

@main_bp.route("/")
def index():
    return render_template("jinja/index.html")
