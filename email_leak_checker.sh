#!/bin/bash

EMAIL=$1
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_DIR="relatorios/leak_report_$TIMESTAMP"
mkdir -p "$OUTPUT_DIR"

REPORT_FILE="$OUTPUT_DIR/relatorio.html"
RAW_FILE="$OUTPUT_DIR/raw.txt"

echo "Email analisado: $EMAIL" > "$RAW_FILE"
echo "--------------------------------------" >> "$RAW_FILE"

############################################
# DUCKDUCKGO
############################################
DUCK_URL="https://lite.duckduckgo.com/lite"

DUCK_RESULTS=$(curl -s -L -X POST "$DUCK_URL" -d "q=$EMAIL" | grep -oP 'https?://[^\s"<]+' | grep -Ev '\.(css|js|ico|png|jpg|jpeg|svg|woff|ttf)' | grep -v 'duckduckgo.com' | sort -u | head -n 10)

echo -e "\n[DuckDuckGo Results]\n$DUCK_RESULTS" >> "$RAW_FILE"

############################################
# GITHUB
############################################
GITHUB_SEARCH_URL="https://github.com/search?q=$EMAIL"

GITHUB_RESULTS=$(curl -s "$GITHUB_SEARCH_URL" \
  | grep -oP 'href="/[^"]+"' \
  | grep -E '^href="/[^/]+/[^/"]+"' \
  | sed 's/href="//;s/"$//' \
  | sed 's|^|https://github.com|' \
  | sort -u | head -n 10)

echo -e "\n[GitHub Results]\n$GITHUB_RESULTS" >> "$RAW_FILE"

############################################
# GERAR HTML
############################################

cat <<EOF > "$REPORT_FILE"
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8">
  <title>Relatório de Vazamentos</title>
  <style>
    body {
      background-color: #0d0d0d;
      color: #00ffcc;
      font-family: monospace;
      padding: 2em;
    }
    h1 {
      color: #00ffcc;
      text-align: center;
    }
    .section {
      margin-top: 2em;
    }
    a {
      color: #00ffcc;
      text-decoration: underline;
    }
    hr {
      border: 0;
      border-top: 1px solid #00ffcc44;
      margin: 2em 0;
    }
  </style>
</head>
<body>

<h1>🧪 Relatório de Vazamentos</h1>

<p><strong>Email analisado:</strong> $EMAIL</p>

<div class="section">
  <h2>🔎 DuckDuckGo</h2>
  <ul>
EOF

for link in $DUCK_RESULTS; do
  echo "    <li><a href=\"$link\" target=\"_blank\">$link</a></li>" >> "$REPORT_FILE"
done

cat <<EOF >> "$REPORT_FILE"
  </ul>
</div>

<div class="section">
  <h2>💻 GitHub</h2>
  <ul>
EOF

for link in $GITHUB_RESULTS; do
  echo "    <li><a href=\"$link\" target=\"_blank\">$link</a></li>" >> "$REPORT_FILE"
done

DATA_ATUAL=$(date "+%d/%m/%Y %H:%M")

cat <<EOF >> "$REPORT_FILE"
  </ul>
</div>

<hr>
<p>🕒 Relatório gerado automaticamente em $DATA_ATUAL</p>

</body>
</html>
EOF

echo -e "\n[+] Relatório salvo em: $REPORT_FILE"
