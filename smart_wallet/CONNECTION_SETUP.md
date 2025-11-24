# 🔌 Configuración de Conexión

## ⚠️ Problema Común: Error de Conexión

Si ves errores de conexión al intentar conectarte al backend, sigue estos pasos:

---

## 🛠️ Solución 1: Verificar Backend Está Corriendo

### Backend debe estar corriendo en el puerto 5001

```bash
# Terminal 1: Iniciar backend
cd backend
npm start

# Deberías ver:
# Server running on port 5001
```

---

## 📱 Solución 2: Configuración según Plataforma

### Android Emulador
- ✅ Usa: `http://10.0.2.2:5001/api`
- La app ya está configurada para esto automáticamente

### iOS Emulador / macOS
- ✅ Usa: `http://localhost:5001/api`
- La app ya está configurada para esto automáticamente

### Dispositivo Físico (Android/iOS)
Debes usar la IP de tu computadora en la red local:

1. **Encuentra tu IP local:**
   ```bash
   # Windows
   ipconfig
   # Busca "IPv4 Address" (ejemplo: 192.168.1.100)
   
   # Mac/Linux
   ifconfig
   # Busca "inet" (ejemplo: 192.168.1.100)
   ```

2. **Modifica temporalmente la baseUrl:**
   ```dart
   // En lib/core/constants/api_constants.dart
   static String get baseUrl {
     return 'http://192.168.1.100:5001/api'; // Usa TU IP
   }
   ```

3. **Asegúrate que el backend acepta conexiones externas:**
   ```javascript
   // En backend/src/server.js
   const PORT = process.env.PORT || 5001;
   app.listen(PORT, '0.0.0.0', () => { // Cambia 'localhost' por '0.0.0.0'
     console.log(`Server running on port ${PORT}`);
   });
   ```

---

## 🔍 Solución 3: Verificar Logs de Error

### Si ves errores como:

```
DioException [connection error]: Failed host lookup: '10.0.2.2'
```
**Solución:** Verifica que el backend esté corriendo

```
SocketException: OS Error: Connection refused
```
**Solución:** El backend no está corriendo o hay firewall bloqueando

```
DioException [request error]: Http status error [404]
```
**Solución:** La URL base está incorrecta o el endpoint no existe

```
DioException [connection timeout]
```
**Solución:** Timeout, verifica conexión de red

---

## ✅ Verificación Rápida

### 1. Verifica que el backend está corriendo:
```bash
curl http://localhost:5001/api/health
# o
curl http://10.0.2.2:5001/api/health
```

### 2. Verifica desde Flutter:
En los logs de Flutter, busca:
```
Error connecting to API
```
Si ves esto, el problema es de conexión.

### 3. Prueba la conexión manualmente:
En `AuthService.login()`, puedes agregar debug:
```dart
print('Connecting to: ${ApiConstants.baseUrl}');
print('Full URL: ${ApiConstants.login}');
```

---

## 🔄 Reiniciar Todo

Si nada funciona:

1. **Detén el backend** (Ctrl+C)
2. **Detén Flutter** (Detener en VS Code/Android Studio)
3. **Inicia backend primero:**
   ```bash
   cd backend
   npm start
   ```
4. **Espera a ver:** `Server running on port 5001`
5. **Luego inicia Flutter**
6. **Intenta login de nuevo**

---

## 📋 Checklist de Diagnóstico

- [ ] Backend está corriendo en puerto 5001
- [ ] No hay firewall bloqueando el puerto
- [ ] La IP es correcta según tu plataforma
- [ ] Los logs muestran que intenta conectarse
- [ ] Backend muestra requests recibidas en la consola

---

## 🆘 Si Todo Falla

### Opción A: Usar URL pública (para testing)
Si tienes un backend desplegado:
```dart
static String get baseUrl => 'https://tu-backend.herokuapp.com/api';
```

### Opción B: Usar ngrok para tunneling
```bash
# Instala ngrok
ngrok http 5001

# Usa la URL que te da (ejemplo: https://abc123.ngrok.io)
# Modifica api_constants.dart:
static String get baseUrl => 'https://abc123.ngrok.io/api';
```

---

## 📝 Notas Importantes

- **Android Emulador:** Siempre usa `10.0.2.2`
- **iOS Simulator:** Usa `localhost`
- **Dispositivo Físico:** Usa IP de tu red local
- **Backend debe estar corriendo ANTES de iniciar Flutter**
- Los logs de Flutter mostrarán el error exacto

