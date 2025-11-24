# 🔍 Logs de Debugging para Credenciales

## 📋 Logs Implementados

### **1. Registro de Usuario**

#### **Logs de Entrada:**
```
📝 REGISTER ATTEMPT:
  - user_id: [valor]
  - email: [valor]
  - password length: [longitud]
```

#### **Logs de Validación:**
```
🔍 Checking if user already exists...
📊 Existing users found: [número]
❌ User already exists (si existe)
```

#### **Logs de Hash:**
```
🔐 Hashing password...
  - Hash length: [longitud]
  - Hash starts with: [primeros 10 caracteres]...
```

#### **Logs de Creación:**
```
💾 Creating user in database...
🎫 Generating tokens...
  - Access token length: [longitud]
  - Refresh token length: [longitud]
✅ REGISTER SUCCESSFUL
  - User created: [user_id]
  - Email: [email]
  - Subscription: free
```

---

### **2. Login de Usuario**

#### **Logs de Entrada:**
```
🔐 LOGIN ATTEMPT:
  - user_id: [valor]
  - password length: [longitud]
  - user_id type: [tipo]
  - user_id length: [longitud]
```

#### **Logs de Búsqueda:**
```
🔍 Searching user in database...
📊 Database query result:
  - Users found: [número]
  - Found user_id: [valor] (si existe)
  - Found email: [valor] (si existe)
  - Subscription: [tipo] (si existe)
❌ User not found in database (si no existe)
```

#### **Logs de Verificación:**
```
🔑 Verifying password...
  - Stored hash length: [longitud]
  - Stored hash starts with: [primeros 10 caracteres]...
  - Password valid: [true/false]
❌ Password verification failed (si falla)
```

#### **Logs de Éxito:**
```
🎫 Generating tokens...
  - Access token length: [longitud]
  - Refresh token length: [longitud]
✅ LOGIN SUCCESSFUL
  - User authenticated: [user_id]
  - Email: [email]
  - Subscription: [tipo]
```

---

## 🧪 Cómo Usar los Logs

### **Paso 1: Iniciar Backend**
```bash
cd backend
npm start
```

### **Paso 2: Intentar Registro**
1. Ve a la app Flutter
2. Presiona "Crear cuenta"
3. Llena los campos
4. Presiona "Crear cuenta"
5. **Revisa los logs del backend**

### **Paso 3: Intentar Login**
1. Ve a "Ingresar"
2. Usa las credenciales del registro
3. Presiona "Ingresar"
4. **Revisa los logs del backend**

---

## 🔍 Qué Buscar en los Logs

### **Registro Exitoso:**
```
📝 REGISTER ATTEMPT:
  - user_id: testuser
  - email: test@example.com
  - password length: 8
🔍 Checking if user already exists...
📊 Existing users found: 0
🔐 Hashing password...
  - Hash length: 60
  - Hash starts with: $2a$12$LQv3c...
💾 Creating user in database...
🎫 Generating tokens...
✅ REGISTER SUCCESSFUL
```

### **Login Exitoso:**
```
🔐 LOGIN ATTEMPT:
  - user_id: testuser
  - password length: 8
🔍 Searching user in database...
📊 Database query result:
  - Users found: 1
  - Found user_id: testuser
  - Found email: test@example.com
  - Subscription: free
🔑 Verifying password...
  - Password valid: true
✅ LOGIN SUCCESSFUL
```

### **Login Fallido - Usuario No Encontrado:**
```
🔐 LOGIN ATTEMPT:
  - user_id: wronguser
  - password length: 8
🔍 Searching user in database...
📊 Database query result:
  - Users found: 0
❌ User not found in database
```

### **Login Fallido - Contraseña Incorrecta:**
```
🔐 LOGIN ATTEMPT:
  - user_id: testuser
  - password length: 8
🔍 Searching user in database...
📊 Database query result:
  - Users found: 1
  - Found user_id: testuser
🔑 Verifying password...
  - Password valid: false
❌ Password verification failed
```

---

## 🚨 Problemas Comunes

### **1. Usuario No Encontrado**
**Síntoma:** `❌ User not found in database`
**Causas:**
- userId incorrecto (espacios, mayúsculas)
- Usuario no registrado
- Base de datos vacía

**Solución:**
- Verificar userId exacto
- Registrar usuario primero
- Verificar datos en BD

### **2. Contraseña Incorrecta**
**Síntoma:** `❌ Password verification failed`
**Causas:**
- Contraseña incorrecta
- Hash corrupto
- Problema de encoding

**Solución:**
- Verificar contraseña exacta
- Re-registrar usuario
- Verificar hash en BD

### **3. Campos Faltantes**
**Síntoma:** `❌ Missing credentials` o `❌ Missing required fields`
**Causas:**
- Campos vacíos
- Problema de envío de datos

**Solución:**
- Verificar formulario
- Verificar API calls
- Verificar validación

---

## 📊 Información de Debugging

### **Hash de Contraseña:**
- **Longitud:** 60 caracteres
- **Formato:** `$2a$12$...`
- **Salt:** 12 rounds

### **Tokens:**
- **Access Token:** ~200+ caracteres
- **Refresh Token:** ~200+ caracteres
- **Formato:** JWT

### **Base de Datos:**
- **Tabla:** `users`
- **Campos:** `user_id`, `email`, `password_hash`
- **Índices:** `user_id` único

---

## 🎯 Próximos Pasos

1. **Ejecutar backend** con logs
2. **Intentar registro** y revisar logs
3. **Intentar login** y revisar logs
4. **Identificar problema** específico
5. **Aplicar solución** correspondiente

---

## 📝 Notas Importantes

- Los logs se muestran en la **consola del backend**
- Cada intento genera logs detallados
- Los logs incluyen información sensible (hashes parciales)
- Usar solo para debugging, no en producción

**¡Ahora puedes ver exactamente qué está pasando con las credenciales!** 🔍
