# 🔍 Cómo Encontrar tu IP Local

## Paso 1: Encuentra tu IP

### Windows:
```bash
ipconfig
```

Busca la línea que dice:
```
IPv4 Address. . . . . . . . . . . : 192.168.1.XXX
                                              ^^^^^^^^ 
                                              Esta es tu IP
```

### Mac/Linux:
```bash
ifconfig
```

O simplemente:
```bash
ipconfig getifaddr en0
```

Busca algo como: `192.168.1.XXX`

---

## Paso 2: Actualiza la IP en el Código

Abre el archivo: `lib/core/constants/api_constants.dart`

Cambia esta línea:
```dart
static const String localIP = '192.168.1.100'; // ⬅️ CAMBIA ESTA IP
```

Por tu IP real, por ejemplo:
```dart
static const String localIP = '192.168.1.50'; // Tu IP aquí
```

---

## Paso 3: Reinicia la App

**Importante:** Debes hacer un **hot restart completo**:
- Stop la app completamente
- Run nuevamente

Un simple hot reload no es suficiente porque la baseUrl se calcula al inicio.

---

## ⚠️ Importante

### Asegúrate que:

1. ✅ Tu computadora y tu dispositivo están en la **misma red WiFi**
2. ✅ El backend está corriendo en el puerto 5001
3. ✅ El firewall no está bloqueando el puerto 5001

### Verificar Backend:
```bash
cd backend
npm start
```

Deberías ver:
```
Server running on port 5001
```

---

## 🧪 Probar la Conexión

Desde tu computadora, abre un navegador y ve a:
```
http://TU_IP:5001/api/health
```

Si ves una respuesta, el backend está accesible desde la red local.

---

## 💡 Ejemplo Completo

Si tu IP es `192.168.1.50`:

1. Abre `lib/core/constants/api_constants.dart`
2. Cambia:
   ```dart
   static const String localIP = '192.168.1.50';
   ```
3. Guarda el archivo
4. Reinicia la app Flutter completamente
5. ¡Listo! 🎉

---

## 🆘 Si No Funciona

### Problema: "Cannot reach host"
- Verifica que ambos dispositivos están en la misma WiFi
- Verifica que la IP es correcta
- Verifica que el backend está corriendo

### Problema: "Connection refused"
- El puerto 5001 puede estar bloqueado por firewall
- Desactiva temporalmente el firewall
- O configura el firewall para permitir el puerto 5001

### Problema: Backend no responde
- Verifica que el backend está corriendo: `npm start`
- Verifica que está escuchando en el puerto correcto
- Revisa los logs del backend

