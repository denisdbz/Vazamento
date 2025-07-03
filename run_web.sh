#!/bin/bash

echo "🚀 Iniciando servidor Flask local..."

# Verifica porta livre
PORTA=5000
while lsof -i :$PORTA >/dev/null 2>&1; do
  PORTA=$((PORTA+1))
done

# Inicia Flask em background
python3 -m flask run --host=0.0.0.0 --port=$PORTA >/dev/null 2>&1 &
FLASK_PID=$!
echo "✅ Flask iniciado (PID: $FLASK_PID) na porta $PORTA"

# Aguarda servidor subir
sleep 3

echo "🌐 Iniciando túnel com Cloudflared..."

# Executa túnel Cloudflared
cloudflared tunnel --url http://localhost:$PORTA --no-autoupdate > cloudflared.log 2>&1 &

# Espera a URL aparecer no log
sleep 5
URL=$(grep -oE "https://[-a-z0-9]+\.trycloudflare.com" cloudflared.log | head -n1)

if [ -n "$URL" ]; then
  echo "🌍 Acesse seu relatório via Cloudflared:"
  echo "🔗 $URL"
else
  echo "❌ Não foi possível obter a URL do Cloudflared."
fi

echo "📁 Flask rodando em segundo plano (PID: $FLASK_PID)"
