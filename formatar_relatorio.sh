#!/bin/bash

# Caminho do relatório original
RELATORIO_BRUTO="relatorio.html"
# Caminho final do HTML bonito
DESTINO="docs/index.html"

# Verifica se o arquivo original existe
if [ ! -f "$RELATORIO_BRUTO" ]; then
  echo "❌ Arquivo relatorio.html não encontrado."
  exit 1
fi

# Cria o destino se não existir
mkdir -p docs

# Escapa os caracteres HTML e insere no modelo estilizado
{
  echo '<!DOCTYPE html>'
  echo '<html lang="pt-br">'
  echo '<head>'
  echo '  <meta charset="UTF-8">'
  echo '  <meta name="viewport" content="width=device-width, initial-scale=1.0">'
  echo '  <title>Relatório de Vazamento</title>'
  echo '  <style>'
  echo '    body { background-color: black; color: #00ff00; font-family: monospace; padding: 2rem; }'
  echo '    h1 { color: #00ffe0; text-align: center; }'
  echo '    pre { white-space: pre-wrap; word-wrap: break-word; background-color: #111; padding: 1rem; border-radius: 10px; }'
  echo '    .container { max-width: 900px; margin: auto; }'
  echo '  </style>'
  echo '</head>'
  echo '<body>'
  echo '  <div class="container">'
  echo '    <h1>🔐 Relatório de Vazamento</h1>'
  echo '    <pre>'
  # Aqui escapamos os caracteres do HTML
  cat "$RELATORIO_BRUTO" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
  echo '    </pre>'
  echo '  </div>'
  echo '</body>'
  echo '</html>'
} > "$DESTINO"

echo "✅ Relatório estilizado gerado com sucesso em: $DESTINO"
