#!/bin/bash
# Script para iniciar ngrok y exponer el backend local
# Requiere: ngrok instalado (https://ngrok.com/download)

PORT=5001

echo "🚀 Iniciando ngrok para puerto $PORT..."

# Verificar si ngrok está instalado
if ! command -v ngrok &> /dev/null; then
    echo "❌ ngrok no está instalado"
    echo ""
    echo "📥 Para instalar ngrok:"
    echo "   brew install ngrok/ngrok/ngrok  # macOS"
    echo "   O descarga desde: https://ngrok.com/download"
    echo ""
    echo "💡 Alternativa: Usa 'npx ngrok' si tienes Node.js instalado"
    exit 1
fi

echo "🌐 Creando túnel público en http://localhost:$PORT..."
echo ""
echo "📱 La URL pública aparecerá abajo. Úsala en tu app Flutter."
echo ""

# Iniciar ngrok
ngrok http $PORT

