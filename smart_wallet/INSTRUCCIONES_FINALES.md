# ✅ Configuración Lista para Dispositivo Físico

## 🎯 Lo que se ha configurado:

1. ✅ **IP Local configurada:** `192.168.1.74`
2. ✅ **ApiService apunta a dispositivo físico**
3. ✅ **Backend configurado para aceptar conexiones externas**

---

## 🚀 Pasos para Conectar

### Paso 1: Verifica que el Backend Está Corriendo

```bash
cd backend
npm start
```

**Debes ver:**
```
Server is up and running on PORT: 5001
```

### Paso 2: Reinicia la App Flutter COMPLETAMENTE

⚠️ **IMPORTANTE:** No basta con hot reload. Debes:
- Stop la app completamente
- Run de nuevo

Esto es porque la baseUrl se configura al inicio.

### Paso 3: Intenta Login

La app ahora intentará conectarse a:
```
http://192.168.1.74:5001/api
```

---

## 🔍 Verificar la Conexión

### Desde tu navegador (en tu computadora):
```
http://192.168.1.74:5001/api/health
```

Si ves:
```json
{"status":"ok"}
```

Entonces el backend está accesible y debería funcionar desde tu dispositivo.

---

## ⚠️ Asegúrate que:

1. ✅ Tu computadora y tu dispositivo están en la **misma red WiFi**
2. ✅ Backend está corriendo (`npm start`)
3. ✅ No hay firewall bloqueando el puerto 5001
4. ✅ La app Flutter fue reiniciada completamente

---

## 🐛 Si Aún No Funciona

### Verifica en los logs de Flutter:

Cuando intentes hacer login, verás algo como:

**✅ Si funciona:**
```
API Error: POST /auth/login
Status: 200
```

**❌ Si hay problema de conexión:**
```
API Error: POST /auth/login
Status: null
Message: [error específico]
```

### Errores Comunes:

**"Cannot reach host"**
- La IP está incorrecta o ambos dispositivos no están en la misma red

**"Connection refused"**
- El backend no está corriendo o firewall bloquea el puerto

**"Timeout"**
- Problema de red o el backend está lento

---

## 📝 Resumen de Archivos

- `lib/core/constants/api_constants.dart` - IP configurada: `192.168.1.74`
- `backend/src/server.js` - Ya acepta conexiones externas

---

## ✅ Checklist Final

- [ ] Backend corriendo en puerto 5001
- [ ] App Flutter reiniciada completamente
- [ ] Ambos dispositivos en misma WiFi
- [ ] Puedes acceder a http://192.168.1.74:5001/api/health desde navegador
- [ ] Sin firewall bloqueando puerto 5001

**¡Ahora debería funcionar!** 🎉

