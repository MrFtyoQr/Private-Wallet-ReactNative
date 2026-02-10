# 🎭 Sistema de Datos Dummy - Private Wallet

## 📋 Resumen

Este proyecto incluye un sistema completo de datos dummy que permite que la aplicación Flutter funcione **sin conexión al backend**, utilizando datos simulados realistas.

---

## 🚀 Inicio Rápido

### Activado por Defecto

El modo dummy está **activado por defecto**. La app funciona inmediatamente sin necesidad de backend.

### Cambiar entre Modo Dummy y Backend Real

Abre `lib/core/constants/api_constants.dart`:

```dart
// Para usar datos dummy (sin backend)
static const bool useDummyData = true; // ⬅️ Activado

// Para usar backend real
static const bool useDummyData = false; // ⬅️ Desactivado
```

---

## 📚 Documentación Completa

### 1. Documentación Técnica Completa
📄 **`DOCUMENTACION_DUMMY_DATA.md`**
- Estructura completa de datos esperados del backend
- Mapeo detallado de todos los endpoints
- Formatos de request/response
- Ejemplos de código

### 2. Guía de Integración
📄 **`GUIA_INTEGRACION_BACKEND.md`**
- Pasos para conectar el backend real
- Troubleshooting común
- Testing y verificación
- Checklist de integración

---

## ✨ Características

### Datos Dummy Incluidos

✅ **Autenticación**
- Login y registro funcionan sin backend
- Tokens simulados

✅ **Transacciones**
- 15 transacciones pre-generadas (5 ingresos, 10 gastos)
- CRUD completo (crear, leer, actualizar, eliminar)
- Resumen de balance calculado automáticamente

✅ **Metas Financieras**
- 3 metas pre-definidas
- Progreso calculado automáticamente
- Planes de ahorro generados

✅ **Recordatorios**
- 3 recordatorios pre-configurados
- Recordatorios recurrentes
- Próximos recordatorios

✅ **Datos de Mercado**
- Precios de criptomonedas (BTC, ETH, etc.)
- Precios de acciones (AAPL, GOOGL, etc.)
- Análisis de mercado simulado

✅ **Analytics**
- Resumen del dashboard
- Tendencias de ingresos/gastos
- Análisis por categorías

✅ **Inversiones**
- Análisis de inversiones
- Recomendaciones personalizadas
- Portafolio simulado

✅ **IA**
- Chat con IA (respuestas simuladas)
- Análisis financiero
- Uso de IA (límites)

✅ **Pagos**
- Creación de pagos
- Confirmación de pagos
- Historial de pagos
- Información de suscripción

---

## 🔧 Configuración

### Modo Dummy (Actual)

```dart
// lib/core/constants/api_constants.dart
static const bool useDummyData = true;
```

**Ventajas:**
- ✅ Funciona sin backend
- ✅ Datos realistas
- ✅ Desarrollo rápido
- ✅ Testing de UI/UX

### Modo Backend Real

```dart
// lib/core/constants/api_constants.dart
static const bool useDummyData = false;
static const String localIP = '192.168.1.100'; // Tu IP
```

**Requisitos:**
- Backend corriendo en puerto 5001
- Todos los endpoints implementados
- Formato de respuestas correcto

---

## 📖 Estructura del Proyecto

```
smart_wallet/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── api_constants.dart       # ⬅️ Configuración dummy/backend
│   │   └── services/
│   │       ├── api_service.dart          # ⬅️ Detecta y usa dummy o backend
│   │       └── dummy_data_service.dart   # ⬅️ Genera datos dummy
│   └── ...
├── DOCUMENTACION_DUMMY_DATA.md           # 📚 Documentación completa
├── GUIA_INTEGRACION_BACKEND.md          # 🔌 Guía de integración
└── README_DUMMY_DATA.md                 # 📋 Este archivo
```

---

## 🎯 Casos de Uso

### Desarrollo Frontend
- Desarrolla y prueba la UI sin necesidad del backend
- Itera rápidamente en diseño y funcionalidades
- Prueba diferentes escenarios con datos variados

### Demostraciones
- Muestra la app completamente funcional
- No requiere configuración adicional
- Datos realistas para presentaciones

### Testing
- Prueba todas las funcionalidades
- Verifica comportamientos de la app
- Testing de integración sin backend

### Desarrollo Paralelo
- Frontend y backend pueden desarrollarse en paralelo
- No hay dependencias entre equipos
- Fácil integración cuando el backend esté listo

---

## 🔄 Migración a Backend Real

Cuando el backend esté listo:

1. **Leer la documentación**: `DOCUMENTACION_DUMMY_DATA.md`
2. **Verificar endpoints**: Asegurar que todos los endpoints estén implementados
3. **Cambiar configuración**: `useDummyData = false`
4. **Configurar URL**: Establecer la URL correcta del backend
5. **Probar**: Seguir `GUIA_INTEGRACION_BACKEND.md`

---

## ⚠️ Notas Importantes

### Datos Dummy vs Backend Real

| Característica | Dummy | Backend Real |
|---------------|-------|--------------|
| Persistencia | En memoria (se pierde al cerrar) | Base de datos |
| Datos | Pre-generados | Reales del usuario |
| Sincronización | No aplica | Multi-dispositivo |
| IA | Respuestas simuladas | IA real con OpenRouter |

### Limitaciones del Modo Dummy

- ❌ Los datos no se persisten (se reinician al reiniciar la app)
- ❌ La IA no funciona realmente (solo respuestas simuladas)
- ❌ Los pagos no son reales
- ❌ No hay sincronización entre dispositivos

### Cuándo Usar Backend Real

- ✅ Cuando necesites persistencia de datos
- ✅ Cuando necesites IA real
- ✅ Cuando necesites pagos reales
- ✅ Para producción

---

## 🐛 Troubleshooting

### La app no muestra datos

1. Verifica que `useDummyData = true`
2. Reinicia la app completamente (hot restart no es suficiente)
3. Verifica los logs de Flutter

### Quiero cambiar a backend real

1. Verifica que el backend esté corriendo
2. Cambia `useDummyData = false`
3. Configura la URL correcta
4. Sigue `GUIA_INTEGRACION_BACKEND.md`

### Los datos no se guardan

Esto es normal en modo dummy. Los datos están en memoria y se pierden al cerrar la app. Para persistencia, usa el backend real.

---

## 📞 Soporte

Si tienes problemas:

1. Revisa `DOCUMENTACION_DUMMY_DATA.md` para verificar formatos
2. Revisa `GUIA_INTEGRACION_BACKEND.md` para troubleshooting
3. Verifica los logs de Flutter para errores específicos

---

## ✅ Checklist de Implementación

Cuando el backend esté listo, verifica:

- [ ] Todos los endpoints están implementados
- [ ] Los formatos de respuesta coinciden con la documentación
- [ ] La autenticación JWT funciona correctamente
- [ ] El refresh token funciona automáticamente
- [ ] Los datos se parsean correctamente
- [ ] No hay errores en los logs

---

## 🎉 ¡Listo!

El sistema de datos dummy está completamente funcional y documentado. Puedes:

- ✅ Desarrollar sin backend
- ✅ Probar todas las funcionalidades
- ✅ Hacer demostraciones
- ✅ Migrar fácilmente cuando el backend esté listo

**¡Disfruta desarrollando!** 🚀
