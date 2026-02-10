# 📚 Documentación Completa: Modo Dummy y Estructura del Backend

## 📋 Índice

1. [Descripción General](#descripción-general)
2. [Implementación del Modo Dummy](#implementación-del-modo-dummy)
3. [Estructura de Datos Esperada del Backend](#estructura-de-datos-esperada-del-backend)
4. [Mapeo de Endpoints y Respuestas](#mapeo-de-endpoints-y-respuestas)
5. [Cómo Conectar el Backend Real](#cómo-conectar-el-backend-real)
6. [Guía de Integración](#guía-de-integración)

---

## 🎯 Descripción General

El sistema de datos dummy permite que la aplicación Flutter funcione completamente sin conexión al backend, utilizando datos simulados realistas. Esto es útil para:

- Desarrollo sin necesidad de backend activo
- Testing de la UI/UX
- Demostraciones de la aplicación
- Desarrollo frontend paralelo al backend

### Archivos Principales

- **`lib/core/services/dummy_data_service.dart`**: Servicio que genera datos dummy
- **`lib/core/services/api_service.dart`**: Servicio que detecta y usa datos dummy o backend real
- **`lib/core/constants/api_constants.dart`**: Configuración para habilitar/deshabilitar modo dummy

---

## 🔧 Implementación del Modo Dummy

### Configuración

Para habilitar o deshabilitar el modo dummy, modifica el archivo `lib/core/constants/api_constants.dart`:

```dart
// 🎭 MODO DUMMY (Datos simulados sin backend)
static const bool useDummyData = true; // ⬅️ true = dummy, false = backend real
```

### Funcionamiento

El `ApiService` detecta automáticamente si debe usar datos dummy o conectarse al backend real:

```dart
// Ejemplo de cómo funciona
Future<Response> getTransactions(String userId) async {
  if (ApiConstants.useDummyData) {
    // Usa datos dummy
    await Future.delayed(const Duration(milliseconds: 300)); // Simula delay de red
    final data = _dummyService.getTransactions();
    return _createDummyResponse(data);
  }
  // Conecta al backend real
  return await _dio.get('/transactions');
}
```

### Datos Dummy Incluidos

El servicio de datos dummy genera automáticamente:

#### Transacciones
- **5 ingresos**: Salario, Freelance, Venta, Inversión, Regalo
- **10 gastos**: Supermercado, Transporte, Restaurante, Servicios, Ropa, etc.
- Todas con fechas realistas y montos variados

#### Metas
- Vacaciones en Europa ($5,000 objetivo)
- Nueva Laptop ($1,200 objetivo)
- Fondo de Emergencia ($10,000 objetivo)

#### Recordatorios
- Pago de alquiler (mensual)
- Factura de luz (mensual)
- Seguro del auto (anual)

#### Datos de Mercado
- Criptomonedas: BTC, ETH, BNB, SOL, ADA
- Acciones: AAPL, GOOGL, MSFT, AMZN, TSLA
- Precios simulados con variaciones realistas

---

## 📊 Estructura de Datos Esperada del Backend

### Formato General de Respuestas

Todas las respuestas del backend deben seguir este formato:

```json
{
  "statusCode": 200,
  "data": {
    // Datos específicos del endpoint
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

### Autenticación

#### POST `/auth/login`

**Request:**
```json
{
  "user_id": "usuario123",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "statusCode": 200,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "usuario123",
      "userId": "usuario123",
      "email": "usuario@example.com",
      "subscriptionType": "Free"
    }
  }
}
```

**Campos Importantes:**
- `accessToken`: JWT token para autenticación (15 min duración)
- `refreshToken`: Token para renovar acceso (7 días duración)
- `user.subscriptionType`: "Free" o "Premium"

#### POST `/auth/register`

**Request:**
```json
{
  "user_id": "nuevo_usuario",
  "email": "nuevo@example.com",
  "password": "password123"
}
```

**Response (201):**
```json
{
  "statusCode": 201,
  "data": {
    "accessToken": "...",
    "refreshToken": "...",
    "user": {
      "id": "nuevo_usuario",
      "userId": "nuevo_usuario",
      "email": "nuevo@example.com",
      "subscriptionType": "Free"
    }
  }
}
```

#### POST `/auth/refresh`

**Request:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200):**
```json
{
  "statusCode": 200,
  "data": {
    "accessToken": "nuevo_access_token...",
    "refreshToken": "nuevo_refresh_token..."
  }
}
```

### Transacciones

#### GET `/transactions`

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Response (200):**
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
    },
    {
      "id": "2",
      "title": "Supermercado",
      "amount": "150.50",
      "type": "expense",
      "category": "Alimentación",
      "created_at": "2024-01-14T18:20:00.000Z"
    }
  ]
}
```

**Campos Importantes:**
- `amount`: Puede ser string o number (el frontend parsea ambos)
- `type`: "income" o "expense"
- `created_at`: ISO 8601 date string

#### POST `/transactions`

**Request:**
```json
{
  "title": "Nueva transacción",
  "amount": 100.00,
  "type": "expense",
  "category": "Otros"
}
```

**Response (201):**
```json
{
  "statusCode": 201,
  "data": {
    "id": "123",
    "title": "Nueva transacción",
    "amount": "100.00",
    "type": "expense",
    "category": "Otros",
    "created_at": "2024-01-15T12:00:00.000Z"
  }
}
```

#### PUT `/transactions/:id`

**Request:**
```json
{
  "title": "Transacción actualizada",
  "amount": 150.00,
  "type": "expense",
  "category": "Transporte"
}
```

**Response (200):**
```json
{
  "statusCode": 200,
  "data": {
    "id": "123",
    "title": "Transacción actualizada",
    "amount": "150.00",
    "type": "expense",
    "category": "Transporte",
    "created_at": "2024-01-15T12:00:00.000Z"
  }
}
```

#### DELETE `/transactions/:id`

**Response (200):**
```json
{
  "statusCode": 200,
  "message": "Transacción eliminada"
}
```

#### GET `/transactions/summary`

**Response (200):**
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

**Nota:** Los valores pueden ser string o number, el frontend parsea ambos.

### Metas (Goals)

#### GET `/goals`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": [
    {
      "id": "1",
      "title": "Vacaciones en Europa",
      "target_amount": 5000.00,
      "current_amount": 2100.00,
      "deadline": "2024-07-15",
      "description": "Ahorrar para viaje de 2 semanas",
      "status": "active"
    }
  ]
}
```

**Campos Importantes:**
- `deadline`: Fecha en formato YYYY-MM-DD
- `target_amount` y `current_amount`: Numbers o strings parseables
- `status`: "active", "completed", "cancelled"

#### POST `/goals`

**Request:**
```json
{
  "title": "Nueva meta",
  "target_amount": 3000.00,
  "current_amount": 0.00,
  "deadline": "2024-12-31",
  "description": "Descripción opcional",
  "status": "active"
}
```

**Response (201):** Similar al GET, con el nuevo goal creado.

#### PUT `/goals/:id`

Similar al POST, actualiza un goal existente.

#### DELETE `/goals/:id`

**Response (200):**
```json
{
  "statusCode": 200,
  "message": "Meta eliminada"
}
```

#### GET `/goals/:id/plan`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": {
    "goal": {
      // Objeto goal completo
    },
    "remaining": 2900.00,
    "daysRemaining": 180,
    "dailyAmount": 16.11,
    "monthlyAmount": 483.33
  }
}
```

### Recordatorios (Reminders)

#### GET `/reminders`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": [
    {
      "id": "1",
      "title": "Pago de alquiler",
      "description": "Recordatorio para pagar el alquiler del mes",
      "due_date": "2024-02-01",
      "amount": 800.00,
      "is_recurring": 1,
      "recurrence_type": "monthly",
      "reminder_days": 3,
      "status": "pending"
    }
  ]
}
```

**Campos Importantes:**
- `is_recurring`: 1 o 0 (o true/false)
- `recurrence_type`: "monthly", "yearly", "weekly", etc.
- `due_date`: Formato YYYY-MM-DD
- `status`: "pending", "completed", "overdue"

#### POST `/reminders`

**Request:**
```json
{
  "title": "Nuevo recordatorio",
  "description": "Descripción",
  "due_date": "2024-02-15",
  "amount": 100.00,
  "is_recurring": 1,
  "recurrence_type": "monthly",
  "reminder_days": 3
}
```

#### PUT `/reminders/:id/complete`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": {
    // Recordatorio actualizado con status: "completed"
  }
}
```

#### GET `/reminders/upcoming`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": [
    // Array de recordatorios pendientes ordenados por fecha
  ]
}
```

### Mercado (Market)

#### GET `/market/crypto`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": [
    {
      "symbol": "BTC",
      "price": 45000.00,
      "change": 2.5
    },
    {
      "symbol": "ETH",
      "price": 2500.00,
      "change": 1.8
    }
  ]
}
```

**Campos:**
- `price`: Precio actual
- `change`: Porcentaje de cambio

#### GET `/market/stocks`

Similar a crypto, pero con símbolos de acciones (AAPL, GOOGL, etc.).

#### GET `/market/analysis`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": {
    "summary": "Mercado en tendencia alcista...",
    "recommendations": [
      "Mantener posición en BTC",
      "Considerar ETH para diversificación"
    ],
    "trend": "bullish"
  }
}
```

#### GET `/market/personalized-analysis`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": {
    "analysis": "Basado en tu perfil...",
    "riskLevel": "moderate",
    "recommendations": [
      "Invertir en fondos indexados",
      "Mantener liquidez para emergencias"
    ]
  }
}
```

### Analytics

#### GET `/analytics/dashboard`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": {
    "balance": "2349.50",
    "income": "2500.00",
    "expenses": "150.50",
    "transactionsCount": 15,
    "goalsCount": 3,
    "remindersCount": 5
  }
}
```

#### GET `/analytics/trends?period=month`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": {
    "period": "month",
    "income": [
      {
        "date": "2024-01-01",
        "amount": 1000.00
      }
    ],
    "expenses": [
      {
        "date": "2024-01-01",
        "amount": 800.00
      }
    ]
  }
}
```

#### GET `/analytics/categories`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": [
    {
      "category": "Alimentación",
      "amount": 500.00,
      "percentage": "35.5"
    },
    {
      "category": "Transporte",
      "amount": 300.00,
      "percentage": "21.3"
    }
  ]
}
```

### Inversiones (Investments)

#### GET `/investments/analysis`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": {
    "totalValue": 15000.00,
    "profit": 1500.00,
    "profitPercentage": 10.0,
    "allocations": [
      {
        "asset": "Stocks",
        "percentage": 60.0,
        "value": 9000.00
      }
    ]
  }
}
```

#### GET `/investments/recommendation`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": {
    "recommendation": "Basado en tu perfil...",
    "riskScore": 6,
    "suggestedAllocation": {
      "stocks": 65.0,
      "crypto": 25.0,
      "bonds": 10.0
    }
  }
}
```

#### GET `/investments/portfolio`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": {
    "holdings": [
      {
        "symbol": "AAPL",
        "shares": 10,
        "price": 175.00,
        "value": 1750.00
      }
    ],
    "totalValue": 6950.00
  }
}
```

### IA (AI)

#### POST `/ai/chat`

**Request:**
```json
{
  "message": "¿Cuánto debo ahorrar cada mes?",
  "conversationId": "conv_123" // Opcional
}
```

**Response (200):**
```json
{
  "statusCode": 200,
  "data": {
    "response": "Basado en tus ingresos y gastos...",
    "conversationId": "conv_123"
  }
}
```

#### GET `/ai/conversations`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": [
    {
      "id": "conv_123",
      "title": "Consulta sobre ahorros",
      "created_at": "2024-01-15T10:30:00.000Z",
      "message_count": 5
    }
  ]
}
```

#### GET `/ai/analysis`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": {
    "analysis": "Tu situación financiera es estable...",
    "recommendations": [
      "Mantén tu tasa de ahorro actual",
      "Considera aumentar tus inversiones"
    ]
  }
}
```

### Pagos (Payments)

#### POST `/payments/create`

**Request:**
```json
{
  "amount": 9.99,
  "currency": "usd"
}
```

**Response (200):**
```json
{
  "statusCode": 200,
  "data": {
    "paymentId": "pay_123",
    "status": "pending",
    "amount": 9.99,
    "clientSecret": "pi_xxx_secret_xxx" // Para Stripe
  }
}
```

#### POST `/payments/confirm`

**Request:**
```json
{
  "paymentId": "pay_123",
  "paymentIntentId": "pi_xxx"
}
```

**Response (200):**
```json
{
  "statusCode": 200,
  "data": {
    "paymentId": "pay_123",
    "status": "completed"
  }
}
```

#### GET `/payments/history`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": [
    {
      "id": "pay_123",
      "amount": 9.99,
      "status": "completed",
      "created_at": "2024-01-15T10:30:00.000Z"
    }
  ]
}
```

#### GET `/payments/subscription`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": {
    "plan": "Free",
    "status": "active",
    "expiresAt": null
  }
}
```

### Usuarios (Users)

#### GET `/users/usage`

**Response (200):**
```json
{
  "statusCode": 200,
  "data": {
    "used": 2,
    "limit": 10,
    "resetAt": "2024-02-15T00:00:00.000Z"
  }
}
```

**Campos:**
- `used`: Número de preguntas IA usadas este mes
- `limit`: Límite según plan (Free: 3, Premium: ilimitado)
- `resetAt`: Fecha cuando se reinicia el contador

---

## 🔄 Cómo Conectar el Backend Real

### Paso 1: Deshabilitar Modo Dummy

En `lib/core/constants/api_constants.dart`:

```dart
static const bool useDummyData = false; // Cambiar a false
```

### Paso 2: Configurar URL del Backend

En el mismo archivo, configura la URL correcta:

```dart
static const String localIP = '192.168.1.100'; // Tu IP local
// O si usas ngrok:
static const String ngrokUrl = 'https://abc123.ngrok-free.app';
```

### Paso 3: Verificar Autenticación

Asegúrate que el backend:
1. ✅ Devuelve tokens JWT válidos
2. ✅ El formato de respuesta coincide con lo esperado
3. ✅ Los headers de autenticación funcionan correctamente

### Paso 4: Verificar Estructura de Respuestas

Asegúrate que todas las respuestas sigan el formato:

```json
{
  "statusCode": 200,
  "data": { /* datos */ }
}
```

### Paso 5: Testing

1. **Login**: Verifica que puedas hacer login exitosamente
2. **Token Refresh**: Verifica que los tokens se renueven automáticamente
3. **Endpoints**: Prueba cada endpoint para verificar que las respuestas coincidan

---

## 🛠️ Guía de Integración

### Checklist para Backend

#### Autenticación
- [ ] POST `/auth/login` devuelve accessToken y refreshToken
- [ ] POST `/auth/register` crea usuario y devuelve tokens
- [ ] POST `/auth/refresh` renueva tokens correctamente
- [ ] Todos los endpoints protegidos requieren Bearer token

#### Transacciones
- [ ] GET `/transactions` devuelve array con formato correcto
- [ ] POST `/transactions` crea transacción y devuelve objeto completo
- [ ] PUT `/transactions/:id` actualiza y devuelve objeto actualizado
- [ ] DELETE `/transactions/:id` elimina correctamente
- [ ] GET `/transactions/summary` devuelve balance, income, expenses

#### Metas
- [ ] GET `/goals` devuelve array de metas
- [ ] POST `/goals` crea meta correctamente
- [ ] PUT `/goals/:id` actualiza meta
- [ ] DELETE `/goals/:id` elimina meta
- [ ] GET `/goals/:id/plan` devuelve plan de ahorro

#### Recordatorios
- [ ] GET `/reminders` devuelve array de recordatorios
- [ ] POST `/reminders` crea recordatorio
- [ ] PUT `/reminders/:id/complete` marca como completado
- [ ] GET `/reminders/upcoming` devuelve solo pendientes

#### Mercado
- [ ] GET `/market/crypto` devuelve datos de cripto
- [ ] GET `/market/stocks` devuelve datos de acciones
- [ ] GET `/market/analysis` devuelve análisis general
- [ ] GET `/market/personalized-analysis` devuelve análisis personalizado

#### Analytics
- [ ] GET `/analytics/dashboard` devuelve resumen completo
- [ ] GET `/analytics/trends?period=month` devuelve tendencias
- [ ] GET `/analytics/categories` devuelve análisis por categoría

#### Inversiones
- [ ] GET `/investments/analysis` devuelve análisis de inversiones
- [ ] GET `/investments/recommendation` devuelve recomendaciones
- [ ] GET `/investments/portfolio` devuelve cartera

#### IA
- [ ] POST `/ai/chat` devuelve respuesta de IA
- [ ] GET `/ai/conversations` devuelve conversaciones
- [ ] GET `/ai/analysis` devuelve análisis financiero

#### Pagos
- [ ] POST `/payments/create` crea payment intent
- [ ] POST `/payments/confirm` confirma pago
- [ ] GET `/payments/history` devuelve historial
- [ ] GET `/payments/subscription` devuelve info de suscripción

#### Usuarios
- [ ] GET `/users/usage` devuelve uso de IA

### Manejo de Errores

El backend debe devolver errores en este formato:

```json
{
  "statusCode": 400,
  "message": "Mensaje de error descriptivo"
}
```

**Códigos de Estado:**
- `200`: Éxito
- `201`: Creado exitosamente
- `400`: Error de validación
- `401`: No autorizado (token inválido/expirado)
- `404`: No encontrado
- `500`: Error del servidor

### Consideraciones Especiales

1. **Parsing de Números**: El frontend acepta tanto strings como numbers para campos numéricos (`amount`, `balance`, etc.)

2. **Fechas**: Todas las fechas deben estar en formato ISO 8601 o YYYY-MM-DD

3. **Autenticación**: El JWT debe incluir el `userId` en el payload

4. **Refresh Token**: Se debe renovar automáticamente cuando expira el access token

5. **CORS**: Si usas web, asegúrate de configurar CORS correctamente

---

## 📝 Notas Finales

- El modo dummy está completamente funcional y permite desarrollar toda la app sin backend
- Cuando el backend esté listo, solo cambia `useDummyData` a `false`
- Todas las estructuras de datos están documentadas para facilitar la integración
- Los modelos de Flutter (`TransactionModel`, `GoalModel`, etc.) ya están preparados para parsear las respuestas del backend

**¡La aplicación está lista para funcionar con datos dummy y fácilmente migrable al backend real!** 🚀
