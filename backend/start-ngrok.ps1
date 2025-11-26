# Script para iniciar ngrok y exponer el backend local
# Requiere: ngrok instalado (https://ngrok.com/download)

$PORT = 5001
$NGROK_PATH = "ngrok"

Write-Host "🚀 Iniciando ngrok para puerto $PORT..." -ForegroundColor Cyan

# Verificar si ngrok está instalado
try {
    $ngrokVersion = & $NGROK_PATH version 2>&1
    Write-Host "✅ ngrok encontrado" -ForegroundColor Green
} catch {
    Write-Host "❌ ngrok no está instalado" -ForegroundColor Red
    Write-Host ""
    Write-Host "📥 Para instalar ngrok:" -ForegroundColor Yellow
    Write-Host "   1. Descarga desde: https://ngrok.com/download" -ForegroundColor Yellow
    Write-Host "   2. Extrae ngrok.exe a una carpeta en tu PATH" -ForegroundColor Yellow
    Write-Host "   3. O coloca ngrok.exe en esta carpeta (backend)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 Alternativa: Usa 'npx ngrok' si tienes Node.js instalado" -ForegroundColor Yellow
    exit 1
}

# Iniciar ngrok
Write-Host "🌐 Creando túnel público en http://localhost:$PORT..." -ForegroundColor Cyan
Write-Host ""
Write-Host "📱 La URL pública aparecerá abajo. Úsala en tu app Flutter." -ForegroundColor Yellow
Write-Host ""

# Iniciar ngrok en background y mostrar la URL
Start-Process -FilePath $NGROK_PATH -ArgumentList "http", $PORT -NoNewWindow

Write-Host "✅ ngrok iniciado. Presiona Ctrl+C para detener." -ForegroundColor Green
Write-Host ""
Write-Host "💡 Para ver la URL pública, abre: http://localhost:4040" -ForegroundColor Cyan
Write-Host "   O ejecuta: ngrok http $PORT" -ForegroundColor Cyan

