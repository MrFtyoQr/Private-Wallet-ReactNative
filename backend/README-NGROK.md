# 🌐 Configuración de ngrok para Backend

## ¿Qué es ngrok?

ngrok crea un túnel público seguro que apunta a tu servidor local, permitiendo que dispositivos móviles se conecten desde cualquier lugar sin necesidad de estar en la misma red WiFi.

## 📥 Instalación

### Opción 1: Descarga directa (Recomendado)
1. Ve a: https://ngrok.com/download
2. Descarga `ngrok.exe` para Windows
3. Extrae el archivo a una carpeta en tu PATH (ej: `C:\Program Files\ngrok\`)
4. O coloca `ngrok.exe` en la carpeta `backend/`

### Opción 2: Usar npx (si tienes Node.js)
```bash
npx ngrok http 5001
```

## 🚀 Uso

### Método 1: Script automático (Windows)
```powershell
cd backend
.\start-ngrok.ps1
```

### Método 2: Comando manual
```bash
ngrok http 5001
```

### Método 3: Con npx
```bash
npx ngrok http 5001
```

## 📱 Configurar en Flutter

1. **Inicia ngrok** y copia la URL que aparece (ej: `https://abc123.ngrok-free.app`)

2. **Abre** `smart_wallet/lib/core/constants/api_constants.dart`

3. **Pega la URL** en la variable `ngrokUrl`:
   ```dart
   static const String ngrokUrl = 'https://abc123.ngrok-free.app';
   ```

4. **Reinicia la app Flutter** (hot restart no es suficiente, haz un rebuild completo)

## ⚠️ Notas Importantes

- **URL temporal**: La URL de ngrok cambia cada vez que lo reinicias (a menos que tengas cuenta paga)
- **Límite gratuito**: ngrok gratuito tiene límites de conexiones y tiempo
- **Seguridad**: La URL es pública, cualquiera que la conozca puede acceder
- **Puerto**: Asegúrate de que el backend esté corriendo en el puerto 5001

## 🔍 Verificar que funciona

1. Inicia el backend: `npm start` en la carpeta `backend/`
2. Inicia ngrok: `ngrok http 5001`
3. Abre http://localhost:4040 para ver el dashboard de ngrok
4. Copia la URL "Forwarding" (ej: `https://abc123.ngrok-free.app`)
5. Pégala en `api_constants.dart`
6. Prueba en tu app móvil

## 🆘 Solución de Problemas

### "ngrok no está instalado"
- Descarga ngrok desde https://ngrok.com/download
- O usa `npx ngrok http 5001`

### "Connection refused"
- Verifica que el backend esté corriendo en el puerto 5001
- Verifica que ngrok esté apuntando al puerto correcto

### "Tunnel not found"
- Reinicia ngrok
- Copia la nueva URL y actualiza `api_constants.dart`

