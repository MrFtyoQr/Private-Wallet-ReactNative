# 🔌 Guía de Integración con Backend Real

## 📋 Resumen Rápido

Esta guía te ayudará a integrar el backend real con la aplicación Flutter una vez que el backend esté listo y funcional.

---

## 🚀 Pasos Rápidos

### 1. Desactivar Modo Dummy

Abre `lib/core/constants/api_constants.dart` y cambia:

```dart
static const bool useDummyData = false; // ⬅️ Cambiar de true a false
```

### 2. Verificar URL del Backend

En el mismo archivo, asegúrate que la URL esté configurada correctamente:

```dart
// Para dispositivo físico
static const String localIP = '192.168.1.100'; // Tu IP local

// O para ngrok (túnel público)
static const String ngrokUrl = 'https://abc123.ngrok-free.app';
```

### 3. Verificar que el Backend Está Corriendo

```bash
# En la terminal del backend
cd backend
npm start

# Deberías ver:
# Server running on port 5001
```

### 4. Probar la Conexión

1. Abre la app Flutter
2. Intenta hacer login
3. Verifica los logs de Flutter para ver errores de conexión

---

## 🔍 Verificación de Endpoints

### Checklist de Pruebas

Ejecuta estas pruebas para verificar que todo funciona:

#### ✅ Autenticación

```dart
// 1. Login
POST /auth/login
Body: {"user_id": "test", "password": "test123"}
Expected: 200 con tokens

// 2. Refresh Token
POST /auth/refresh
Body: {"refreshToken": "..."}
Expected: 200 con nuevos tokens

// 3. Register
POST /auth/register
Body: {"user_id": "nuevo", "email": "test@test.com", "password": "123"}
Expected: 201 con tokens
```

#### ✅ Transacciones

```dart
// 1. Obtener transacciones
GET /transactions
Headers: Authorization: Bearer {token}
Expected: 200 con array de transacciones

// 2. Crear transacción
POST /transactions
Headers: Authorization: Bearer {token}
Body: {"title": "Test", "amount": 100, "type": "expense", "category": "Otros"}
Expected: 201 con transacción creada

// 3. Obtener resumen
GET /transactions/summary
Headers: Authorization: Bearer {token}
Expected: 200 con balance, income, expenses
```

#### ✅ Metas

```dart
// 1. Obtener metas
GET /goals
Headers: Authorization: Bearer {token}
Expected: 200 con array de metas

// 2. Crear meta
POST /goals
Headers: Authorization: Bearer {token}
Body: {"title": "Test", "target_amount": 1000, "current_amount": 0, "deadline": "2024-12-31"}
Expected: 201 con meta creada
```

---

## 🐛 Troubleshooting Común

### Error: "Failed host lookup"

**Problema:** No puede encontrar el servidor

**Soluciones:**
1. Verifica que el backend esté corriendo: `npm start` en la carpeta backend
2. Verifica la IP en `api_constants.dart`
3. Si usas emulador Android, usa `10.0.2.2` en lugar de `localhost`

### Error: "Connection refused"

**Problema:** El backend rechaza la conexión

**Soluciones:**
1. Verifica que el backend esté en el puerto 5001
2. Verifica que no haya firewall bloqueando
3. Si estás en dispositivo físico, asegúrate que esté en la misma red WiFi

### Error: "401 Unauthorized"

**Problema:** Token inválido o expirado

**Soluciones:**
1. Haz logout y login de nuevo
2. Verifica que el token se esté enviando en el header `Authorization`
3. Verifica que el backend esté validando el token correctamente

### Error: "404 Not Found"

**Problema:** El endpoint no existe

**Soluciones:**
1. Verifica la ruta en `api_service.dart`
2. Verifica que el backend tenga el endpoint implementado
3. Verifica que la base URL sea correcta (debe terminar en `/api`)

### Error: Parsing Error

**Problema:** El formato de la respuesta no coincide

**Soluciones:**
1. Verifica que el backend devuelva el formato esperado:
   ```json
   {
     "statusCode": 200,
     "data": { /* datos */ }
   }
   ```
2. Verifica los tipos de datos (strings vs numbers)
3. Verifica el formato de fechas (ISO 8601)

---

## 📊 Estructura de Respuestas Esperada

### Formato General

Todas las respuestas deben seguir este formato:

```json
{
  "statusCode": 200,
  "data": {
    // Contenido específico
  }
}
```

O para arrays:

```json
{
  "statusCode": 200,
  "data": [
    // Array de objetos
  ]
}
```

### Ejemplos Específicos

#### Login

```json
{
  "statusCode": 200,
  "data": {
    "accessToken": "eyJhbGci...",
    "refreshToken": "eyJhbGci...",
    "user": {
      "id": "usuario123",
      "userId": "usuario123",
      "email": "user@example.com",
      "subscriptionType": "Free"
    }
  }
}
```

#### Transacciones

```json
{
  "statusCode": 200,
  "data": [
    {
      "id": "1",
      "title": "Salario",
      "amount": "2500.00",
      "type": "income",
      "category": "Trabajo",
      "created_at": "2024-01-15T10:30:00.000Z"
    }
  ]
}
```

#### Resumen

```json
{
  "statusCode": 200,
  "data": {
    "balance": "2349.50",
    "income": "2500.00",
    "expenses": "150.50"
  }
}
```

**Nota:** Los valores numéricos pueden ser strings o numbers, el frontend parsea ambos.

---

## 🔐 Autenticación JWT

### Flujo de Autenticación

1. **Login**: Usuario envía `user_id` y `password`
2. **Backend responde**: Con `accessToken` y `refreshToken`
3. **Frontend guarda**: Tokens en almacenamiento seguro
4. **Cada request**: Frontend envía `Authorization: Bearer {accessToken}`
5. **Token expira**: Frontend usa `refreshToken` para obtener nuevo `accessToken`

### Interceptor Automático

El `ApiService` tiene un interceptor que:
- ✅ Agrega automáticamente el token a cada request
- ✅ Detecta cuando el token expira (401)
- ✅ Renueva automáticamente el token usando refreshToken
- ✅ Reintenta el request original con el nuevo token

### Manejo de Errores de Autenticación

Si el refresh falla:
- El usuario es automáticamente deslogueado
- Se limpia el almacenamiento
- El usuario debe hacer login de nuevo

---

## 🧪 Testing Manual

### Test 1: Login

1. Abre la app
2. Ingresa credenciales de prueba
3. Verifica que puedas entrar al dashboard
4. Verifica los logs de Flutter para ver el request

### Test 2: Transacciones

1. Entra al dashboard
2. Verifica que se muestren las transacciones
3. Intenta crear una nueva transacción
4. Verifica que aparezca en la lista

### Test 3: Metas

1. Ve a la pantalla de metas
2. Verifica que se muestren las metas existentes
3. Crea una nueva meta
4. Verifica que se guarde correctamente

### Test 4: Refresh Token

1. Espera 15 minutos (o modifica el tiempo de expiración en el backend)
2. Intenta hacer una acción que requiera el backend
3. Verifica que el token se renueve automáticamente
4. Verifica que la acción se complete exitosamente

---

## 📱 Configuración por Plataforma

### Android Emulador

```dart
// En api_constants.dart
static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:5001/api'; // ⬅️ Para emulador
  }
  // ...
}
```

### Android Dispositivo Físico

```dart
// En api_constants.dart
static const String localIP = '192.168.1.100'; // ⬅️ Tu IP local

static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://$localIP:5001/api'; // ⬅️ Para dispositivo físico
  }
  // ...
}
```

### iOS Simulator

```dart
// En api_constants.dart
static String get baseUrl {
  if (Platform.isIOS) {
    return 'http://localhost:5001/api'; // ⬅️ Para simulator
  }
  // ...
}
```

### iOS Dispositivo Físico

Similar a Android físico, usa tu IP local.

### Web

```dart
// En api_constants.dart
static String get baseUrl {
  return 'http://localhost:5001/api'; // ⬅️ Para web
}
```

---

## 🔄 Migración desde Dummy a Backend Real

### Paso 1: Preparar Backend

Asegúrate que el backend tenga todos los endpoints implementados según la documentación en `DOCUMENTACION_DUMMY_DATA.md`.

### Paso 2: Cambiar Configuración

En `api_constants.dart`:

```dart
static const bool useDummyData = false; // ⬅️ Cambiar aquí
```

### Paso 3: Probar Endpoints Críticos

1. Login
2. Obtener transacciones
3. Crear transacción
4. Obtener resumen

### Paso 4: Probar Todas las Funcionalidades

1. Dashboard completo
2. Gestión de transacciones
3. Metas
4. Recordatorios
5. Chat con IA
6. Market data
7. Analytics
8. Pagos

### Paso 5: Verificar Errores

Revisa los logs de Flutter para ver si hay errores de parsing o conexión.

---

## 📝 Checklist Final

Antes de considerar la integración completa:

- [ ] Todos los endpoints responden correctamente
- [ ] El formato de respuestas coincide con lo esperado
- [ ] La autenticación JWT funciona correctamente
- [ ] El refresh token funciona automáticamente
- [ ] Todos los modelos parsean correctamente
- [ ] No hay errores en la consola
- [ ] La app funciona igual que en modo dummy
- [ ] Los datos se guardan correctamente en el backend
- [ ] Los datos se actualizan correctamente
- [ ] Los datos se eliminan correctamente

---

## 🆘 Si Necesitas Ayuda

### Logs de Flutter

Habilita logs detallados para debugging:

```dart
// En api_service.dart, ya están habilitados logs para:
// - Requests que fallan
// - Errores de conexión
// - Errores de parsing
```

### Verificar Request/Response

Puedes agregar más logs en `api_service.dart`:

```dart
print('Request URL: ${options.uri}');
print('Request Headers: ${options.headers}');
print('Response Status: ${response.statusCode}');
print('Response Data: ${response.data}');
```

### Usar Postman o curl

Prueba los endpoints manualmente para verificar que el backend funciona:

```bash
# Ejemplo de login
curl -X POST http://localhost:5001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"user_id":"test","password":"test123"}'
```

---

## ✅ Listo

Una vez que completes todos los pasos y verifiques que todo funciona, tu app Flutter estará completamente integrada con el backend real. 🎉

**Recuerda:** Si encuentras problemas, puedes volver a activar el modo dummy cambiando `useDummyData` a `true` temporalmente para seguir desarrollando mientras se solucionan los problemas del backend.
