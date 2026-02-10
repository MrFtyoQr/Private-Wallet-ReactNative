## 🧾 Guía de uso del Backend con Postman

Esta guía explica **paso a paso** cómo levantar el backend y cómo probar **todas las APIs principales** usando Postman.

---

## 1. Requisitos previos

- **Node.js** instalado (versión 18+ recomendada).
- **MySQL** corriendo en tu máquina (puerto 3306 por defecto).
- **Postman** instalado.

Base de datos por defecto (puedes cambiarla, pero esta es la referencia del proyecto):

- Host: `localhost`
- Puerto: `3306`
- Usuario: `root`
- Contraseña: `654321`
- Base de datos: `private_wallet_db`

> El backend crea automáticamente la base de datos y tablas si la conexión es correcta.

---

## 2. Configurar variables de entorno (`.env`)

En la carpeta `backend/`, crea un archivo `.env` con al menos:

```env
# Opción A: URL completa
DATABASE_URL=mysql://root:654321@localhost:3306/private_wallet_db

# JWT (obligatorio)
JWT_SECRET=tu_clave_jwt_segura
JWT_REFRESH_SECRET=tu_clave_refresh_segura

# CORS (opcional, para permitir tu app móvil/web)
CORS_ORIGINS=http://localhost:3000,http://localhost:8080

# IA (opcional pero recomendado si quieres probar AI)
OPENROUTER=tu_api_key_openrouter

# Stripe (opcional; si no está configurado, los endpoints responden con error controlado)
STRIPE_SECRET_KEY=tu_clave_stripe
```

Si no quieres usar `DATABASE_URL`, puedes usar las variables discretas:

```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=654321
DB_NAME=private_wallet_db
```

---

## 3. Instalar dependencias y arrancar el servidor

Desde la carpeta `backend/`:

```bash
npm install
npm run dev   # desarrollo (nodemon)
# o
npm start     # producción simple
```

Por defecto, el servidor escucha en:

- `http://localhost:5001`

En producción (`NODE_ENV=production`) también se activan los **cron jobs** para datos de mercado y limpieza de logs.

---

## 4. Configurar Postman

### 4.1. Crear variables de entorno

En Postman crea un **Environment** con estas variables:

- **`baseUrl`** = `http://localhost:5001`
- **`accessToken`** = *(se rellenará después del login)*
- **`refreshToken`** = *(opcional, para probar refresh)*

### 4.2. Headers comunes

En todas las requests con JSON añade:

- Header: `Content-Type: application/json`

En todas las rutas protegidas (JWT) añade además:

- Header: `Authorization: Bearer {{accessToken}}`

---

## 5. Flujo básico de autenticación

### 5.1. Registro – `POST /api/auth/register`

- **URL**: `{{baseUrl}}/api/auth/register`
- **Método**: `POST`
- **Body (JSON)**:

```json
{
  "user_id": "usuario_demo",
  "email": "demo@example.com",
  "password": "password_seguro"
}
```

### 5.2. Login – `POST /api/auth/login`

- **URL**: `{{baseUrl}}/api/auth/login`
- **Método**: `POST`
- **Body (JSON)**:

```json
{
  "user_id": "usuario_demo",
  "password": "password_seguro"
}
```

En la respuesta copia:

- `data.accessToken` → variable `accessToken` en Postman.
- `data.refreshToken` → variable `refreshToken` (opcional).

### 5.3. Refresh token – `POST /api/auth/refresh`

- **URL**: `{{baseUrl}}/api/auth/refresh`
- **Método**: `POST`
- **Body (JSON)**:

```json
{
  "refreshToken": "{{refreshToken}}"
}
```

Actualiza `accessToken` en Postman con el nuevo valor.

---

## 6. Usuarios (`/api/users`) – requiere JWT

### 6.1. Perfil – `GET /api/users/profile`

- **URL**: `{{baseUrl}}/api/users/profile`
- **Método**: `GET`
- **Headers**:
  - `Authorization: Bearer {{accessToken}}`

### 6.2. Actualizar suscripción – `PUT /api/users/subscription`

- **URL**: `{{baseUrl}}/api/users/subscription`
- **Método**: `PUT`
- **Body (JSON)**:

```json
{
  "subscriptionType": "premium"
}
```

### 6.3. Uso de IA – `GET /api/users/usage`

- **URL**: `{{baseUrl}}/api/users/usage`
- **Método**: `GET`

---

## 7. Transacciones (`/api/transactions`) – requiere JWT

### 7.1. Listar – `GET /api/transactions`

- **URL**: `{{baseUrl}}/api/transactions`
- **Método**: `GET`

### 7.2. Crear – `POST /api/transactions`

- **URL**: `{{baseUrl}}/api/transactions`
- **Método**: `POST`
- **Body (JSON)**:

```json
{
  "title": "Sueldo",
  "amount": 1500.5,
  "category": "salary",
  "type": "income"
}
```

### 7.3. Resumen – `GET /api/transactions/summary`

- **URL**: `{{baseUrl}}/api/transactions/summary`
- **Método**: `GET`

### 7.4. Eliminar – `DELETE /api/transactions/:id`

- **URL**: `{{baseUrl}}/api/transactions/1` (cambia `1` por el ID real).
- **Método**: `DELETE`

---

## 8. Metas (`/api/goals`) – requiere JWT

### 8.1. Crear meta – `POST /api/goals`

- **URL**: `{{baseUrl}}/api/goals`
- **Método**: `POST`
- **Body (JSON)**:

```json
{
  "title": "Comprar laptop",
  "description": "MacBook para trabajo",
  "target_amount": 1200,
  "deadline": "2025-12-31"
}
```

### 8.2. Listar metas – `GET /api/goals`

- **URL**: `{{baseUrl}}/api/goals`
- **Método**: `GET`
- Query opcional: `?status=active|completed|paused`

### 8.3. Actualizar progreso – `PUT /api/goals/:id/progress`

- **URL**: `{{baseUrl}}/api/goals/1/progress`
- **Método**: `PUT`
- **Body (JSON)**:

```json
{
  "amount": 100
}
```

### 8.4. Plan de ahorro – `GET /api/goals/:id/plan`

- **URL**: `{{baseUrl}}/api/goals/1/plan`
- **Método**: `GET`

### 8.5. Cambiar estado – `PUT /api/goals/:id/status`

- **URL**: `{{baseUrl}}/api/goals/1/status`
- **Método**: `PUT`
- **Body (JSON)**:

```json
{
  "status": "completed"
}
```

### 8.6. Eliminar – `DELETE /api/goals/:id`

- **URL**: `{{baseUrl}}/api/goals/1`
- **Método**: `DELETE`

### 8.7. Resumen – `GET /api/goals/summary`

- **URL**: `{{baseUrl}}/api/goals/summary`
- **Método**: `GET`

---

## 9. Recordatorios (`/api/reminders`) – requiere JWT

### 9.1. Crear – `POST /api/reminders`

- **URL**: `{{baseUrl}}/api/reminders`
- **Body (JSON)**:

```json
{
  "title": "Pagar renta",
  "description": "Depto centro",
  "amount": 500,
  "due_date": "2025-03-10",
  "reminder_days": 3,
  "is_recurring": true,
  "recurrence_type": "monthly"
}
```

### 9.2. Listar – `GET /api/reminders`

- **URL**: `{{baseUrl}}/api/reminders`
- Query opcional: `?status=pending|completed|overdue`

### 9.3. Próximos – `GET /api/reminders/upcoming`

- **URL**: `{{baseUrl}}/api/reminders/upcoming?days=7`

### 9.4. Completar – `PUT /api/reminders/:id/complete`

- **URL**: `{{baseUrl}}/api/reminders/1/complete`

### 9.5. Actualizar – `PUT /api/reminders/:id`

- **URL**: `{{baseUrl}}/api/reminders/1`
- **Body (JSON)** (ejemplo):

```json
{
  "title": "Pagar renta actualizada",
  "amount": 550
}
```

### 9.6. Eliminar – `DELETE /api/reminders/:id`

- **URL**: `{{baseUrl}}/api/reminders/1`

### 9.7. Notificaciones – `GET /api/reminders/notifications`

- **URL**: `{{baseUrl}}/api/reminders/notifications`

### 9.8. Resumen – `GET /api/reminders/summary`

- **URL**: `{{baseUrl}}/api/reminders/summary`

---

## 10. IA (`/api/ai`) – requiere JWT

> Para usuarios **free** hay límites de uso, controlados por `checkAIUsage`.

### 10.1. Chat – `POST /api/ai/chat`

- **URL**: `{{baseUrl}}/api/ai/chat`
- **Body (JSON)**:

```json
{
  "message": "¿Cómo puedo mejorar mis ahorros?",
  "conversationId": "opcional-uuid"
}
```

### 10.2. Listar conversaciones – `GET /api/ai/conversations`

- **URL**: `{{baseUrl}}/api/ai/conversations`
- Query opcional: `?conversationId=<id>`

### 10.3. Conversación por ID – `GET /api/ai/conversations/:conversationId`

- **URL**: `{{baseUrl}}/api/ai/conversations/<conversationId>`

### 10.4. Análisis financiero – `GET /api/ai/analysis`

- **URL**: `{{baseUrl}}/api/ai/analysis`

---

## 11. Analytics (`/api/analytics`) – requiere JWT

### 11.1. Dashboard – `GET /api/analytics/dashboard`

- **URL**: `{{baseUrl}}/api/analytics/dashboard?period=30`

### 11.2. Tendencias – `GET /api/analytics/trends`

- **URL**: `{{baseUrl}}/api/analytics/trends?period=month`
- O:
- **URL**: `{{baseUrl}}/api/analytics/trends?startDate=2025-01-01&endDate=2025-02-01`

### 11.3. Por categorías – `GET /api/analytics/categories`

- **URL**: `{{baseUrl}}/api/analytics/categories?period=30`

### 11.4. Predicciones – `GET /api/analytics/predictions`

- **URL**: `{{baseUrl}}/api/analytics/predictions`

### 11.5. Reporte mensual – `GET /api/analytics/monthly-report`

- **URL**: `{{baseUrl}}/api/analytics/monthly-report?year=2025&month=2`

---

## 12. Mercado (`/api/market`) – requiere JWT

### 12.1. Criptomonedas – `GET /api/market/crypto`

- **URL**: `{{baseUrl}}/api/market/crypto`

### 12.2. Acciones – `GET /api/market/stocks`

- **URL**: `{{baseUrl}}/api/market/stocks`

### 12.3. Análisis de mercado – `GET /api/market/analysis`

- **URL**: `{{baseUrl}}/api/market/analysis`

### 12.4. Análisis personalizado – `GET /api/market/personalized-analysis`

- **URL**: `{{baseUrl}}/api/market/personalized-analysis`
- Solo disponible para suscripciones avanzadas (`premium+`).

---

## 13. Inversiones (`/api/investments`) – requiere JWT

### 13.1. Análisis – `GET /api/investments/analysis`

- **URL**: `{{baseUrl}}/api/investments/analysis`

### 13.2. Recomendación personalizada – `POST /api/investments/recommend`

- **URL**: `{{baseUrl}}/api/investments/recommend`
- **Body (JSON)**: dependerá de cómo quieras consumirlo; como mínimo puedes enviar información del perfil o símbolo.

### 13.3. Portfolio – `GET /api/investments/portfolio`

- **URL**: `{{baseUrl}}/api/investments/portfolio`

### 13.4. Alertas – `POST /api/investments/alert`

- **URL**: `{{baseUrl}}/api/investments/alert`
- **Body (JSON)**: define condiciones de alerta (símbolo, precio objetivo, etc.).

### 13.5. Tendencias – `GET /api/investments/trends`

- **URL**: `{{baseUrl}}/api/investments/trends`

---

## 14. Pagos (`/api/payments`)

### 14.1. Webhook Stripe – `POST /api/payments/webhook/stripe`

- **Uso**: Solo para Stripe, **sin JWT**.
- En Postman normalmente no lo necesitas salvo pruebas específicas de webhook.

### 14.2. Crear pago – `POST /api/payments/create` (JWT)

- **URL**: `{{baseUrl}}/api/payments/create`
- **Body (JSON)**:

```json
{
  "amount": 9.99,
  "currency": "usd",
  "subscriptionType": "premium"
}
```

### 14.3. Confirmar pago – `POST /api/payments/confirm` (JWT)

- **URL**: `{{baseUrl}}/api/payments/confirm`
- Body y detalles dependen de la implementación de `paymentsController.js`.

### 14.4. Historial – `GET /api/payments/history` (JWT)

- **URL**: `{{baseUrl}}/api/payments/history`

### 14.5. Info de suscripción – `GET /api/payments/subscription` (JWT)

- **URL**: `{{baseUrl}}/api/payments/subscription`

### 14.6. Cancelar suscripción – `POST /api/payments/cancel` (JWT)

- **URL**: `{{baseUrl}}/api/payments/cancel`

---

## 15. Salud del servidor

### 15.1. Healthcheck – `GET /api/health`

- **URL**: `{{baseUrl}}/api/health`
- **Método**: `GET`
- **Auth**: NO
- Respuesta esperada:

```json
{
  "status": "ok"
}
```

---

## 16. Resumen de flujo recomendado en Postman

1. **Levantar backend** (`npm run dev` en `backend/`).
2. **Healthcheck**: `GET {{baseUrl}}/api/health`.
3. **Registro**: `POST {{baseUrl}}/api/auth/register`.
4. **Login**: `POST {{baseUrl}}/api/auth/login` → guardar `accessToken`/`refreshToken`.
5. **Probar módulos principales**:
   - Transacciones.
   - Metas.
   - Recordatorios.
   - IA.
   - Analytics y mercado.
6. Opcional: pagos y rutas avanzadas de inversiones.

Con este archivo deberías poder **importar fácilmente las rutas en Postman (copiando las URLs)** y seguir el flujo completo del backend sin mirar el código.

