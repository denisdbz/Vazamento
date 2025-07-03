#!/bin/bash

EMAIL="$1"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DIR="relatorios/leak_report_$TIMESTAMP"
mkdir -p "$DIR"

echo "📧 Verificando: $EMAIL"
echo "📂 Salvando em: $DIR"

# === GitHub Search (pegar links de repositórios) ===
echo "🔍 Buscando no GitHub..."
GITHUB_RESULTS=$(curl -s "https://github.com/search?q=$EMAIL" | grep -oE 'https://github\.com/[^"]+' | sort -u | head -n 5)
echo "$GITHUB_RESULTS" > "$DIR/github.txt"

# === DuckDuckGo Search (pegar links úteis) ===
echo "🔍 Buscando no DuckDuckGo..."
DUCK_URL="https://html.duckduckgo.com/html"
DUCK_RESULTS=$(curl -s -L -X POST "$DUCK_URL" -d "q=$EMAIL" | grep -oE 'https?://[a-zA-Z0-9./?=_-]*' | grep -v "duckduckgo" | sort -u | head -n 5)
echo "$DUCK_RESULTS" > "$DIR/duck.txt"

# === Gerar HTML Final ===
echo "📁 Gerando relatório HTML..."

cat <<EOF > "$DIR/relatorio.html"
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8">
  <title>Relatório de Vazamentos</title>
  <link rel="stylesheet" href="../static/style.css">
</head>
<body class="relatorios">
  <h1>🧪 Relatório de Vazamentos</h1>
  <p><strong>Email analisado:</strong> $EMAIL</p>
EOF

# === DuckDuckGo Section ===
echo "<h2>🔎 DuckDuckGo</h2>" >> "$DIR/relatorio.html"
echo "<div class=\"section\">" >> "$DIR/relatorio.html"
if [ -s "$DIR/duck.txt" ]; then
  while read -r url; do
    echo "<a href=\"$url\" target=\"_blank\">$url</a><br>" >> "$DIR/relatorio.html"
  done < "$DIR/duck.txt"
else
  echo "<p class=\"fail\">Nenhum resultado encontrado no DuckDuckGo.</p>" >> "$DIR/relatorio.html"
fi
echo "</div>" >> "$DIR/relatorio.html"

# === GitHub Section ===
echo "<h2>💻 GitHub</h2>" >> "$DIR/relatorio.html"
echo "<div class=\"section\">" >> "$DIR/relatorio.html"
if [ -s "$DIR/github.txt" ]; then
  while read -r url; do
    echo "<a href=\"$url\" target=\"_blank\">$url</a><br>" >> "$DIR/relatorio.html"
  done < "$DIR/github.txt"
else
  echo "<p class=\"fail\">Nenhum resultado encontrado no GitHub.</p>" >> "$DIR/relatorio.html"
fi
echo "</div>" >> "$DIR/relatorio.html"

# === Rodapé ===
cat <<EOF >> "$DIR/relatorio.html"
  <footer>
    <p>🕒 Relatório gerado automaticamente em $(date +"%d/%m/%Y %H:%M")</p>
  </footer>
</body>
</html>
EOF

# === Envio para Telegram (opcional) ===
echo "📤 Enviando para Telegram..."
if [ -f token.env ]; then
  source token.env
  if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
    curl -F chat_id="$TELEGRAM_CHAT_ID" \
         -F document=@"$DIR/relatorio.html" \
         "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendDocument" >/dev/null 2>&1 && \
    echo "✅ Enviado via Telegram!"
  else
    echo "⚠️  Variáveis TELEGRAM_BOT_TOKEN e TELEGRAM_CHAT_ID não encontradas."
  fi
else
  echo "⚠️  Arquivo token.env não encontrado (envie manualmente, se quiser)."
fi

echo "✅ Relatório salvo em: $DIR/relatorio.html"
