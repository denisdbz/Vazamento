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

        # Diretório de relatórios
        relatorio_dir = "relatorios"
        pastas = sorted(os.listdir(relatorio_dir), reverse=True)

        for pasta in pastas:
            caminho_relatorio = os.path.join(relatorio_dir, pasta, "relatorio.html")
            if os.path.exists(caminho_relatorio):
                with open(caminho_relatorio, "r", encoding="utf-8") as f:
                    html = f.read()
                    soup = BeautifulSoup(html, "html.parser")
                    bloco = soup.find("div", class_="relatorio-bloco")
                    if bloco:
                        relatorio_html = str(bloco)
                        break

    return render_template("index.html", relatorio_html=relatorio_html)
