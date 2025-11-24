# ✅ Fix de Conexión Aplicado

## 🔧 Cambios Realizados

### 1. **Actualizado `api_constants.dart`**
- ✅ Ahora detecta automáticamente la plataforma
- ✅ Android Emulador: `http://10.0.2.2:5001/api`
- ✅ iOS/Web: `http://localhost:5001/api`
- ✅ Los getters ahora se evalúan dinámicamente

### 2. **Mejorado Manejo de Errores en `api_service.dart`**
- ✅ Agregados logs de debug para ver errores
- ✅ Evita intentar refresh token en login/register
- ✅ Mejor manejo de errores 401

---

## 🚀 Cómo Verificar que Funciona

### Paso 1: Verifica que el Backend Está Corriendo

```bash
# En terminal separada
cd backend
npm start

# Debes ver:
# Server running on port 5001
```

### Paso 2: Verifica la Conexión

En Flutter, cuando intentes hacer login, verás en los logs:

**✅ Si funciona:**
```
API Error: POST /auth/login
Status: 200
```

**❌ Si falla la conexión:**
```
API Error: POST /auth/login
Status: null
Message: Failed host lookup: '10.0.2.2'
```

---

## 🐛 Troubleshooting

### Error: "Failed host lookup"
**Causa:** Backend no está corriendo
**Solución:** Inicia el backend en otra terminal

### Error: "Connection refused"
**Causa:** Puerto bloqueado o backend en puerto diferente
**Solución:** Verifica que backend esté en puerto 5001

### Error: "Timeout"
**Causa:** Firewall o red lenta
**Solución:** Desactiva firewall temporalmente o verifica red

---

## 📱 Para Dispositivo Físico

Si estás probando en dispositivo físico (no emulador):

1. Encuentra tu IP local:
   ```bash
   # Windows
   ipconfig
   # Busca IPv4 Address
   
   # Mac/Linux  
   ifconfig
   # Busca inet
   ```

2. Modifica `api_constants.dart`:
   ```dart
   static String get baseUrl {
     return 'http://TU_IP_AQUI:5001/api';
     // Ejemplo: 'http://192.168.1.100:5001/api'
   }
   ```

3. Asegúrate que ambos dispositivos estén en la misma red WiFi

---

## ✅ Checklist

- [ ] Backend corriendo en puerto 5001
- [ ] Sin errores en terminal del backend
- [ ] Flutter app reiniciada después de cambios
- [ ] Verificas los logs cuando intentas login
- [ ] Redes en la misma WiFi (si es dispositivo físico)

---

## 🎯 Próximos Pasos

1. **Reinicia la app Flutter** (hot restart no es suficiente)
2. **Intenta hacer login**
3. **Revisa los logs** en la terminal de Flutter
4. **Comparte los logs** si aún hay problemas

¡Debería funcionar ahora! 🚀

