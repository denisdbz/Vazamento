from flask import Flask, render_template, request
import os
import datetime
from bs4 import BeautifulSoup

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def index():
    relatorio_html = None

    if request.method == "POST":
        email = request.form["email"]
        relatorio_dir = "relatorios"
        pastas = sorted(os.listdir(relatorio_dir), reverse=True)

        for pasta in pastas:
            caminho_relatorio = os.path.join(relatorio_dir, pasta, "relatorio.html")
            if os.path.exists(caminho_relatorio):
                with open(caminho_relatorio, "r", encoding="utf-8") as f:
                    html = f.read()
                    soup = BeautifulSoup(html, "html.parser")
                    corpo = soup.body
                    if corpo:
                        relatorio_html = str(corpo)
                        break

    return render_template("index.html", relatorio_html=relatorio_html)
