# 📱 Diary Flutter - Diario Personal Multimedia

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)

> Una aplicación completa de diario personal con funcionalidades multimedia, seguridad PIN, notificaciones inteligentes e integración meteorológica.

## ✨ Características Principales

### 🔐 **Seguridad Avanzada**
- Sistema PIN de 4-6 dígitos con encriptación SHA-256
- Bloqueo automático de la aplicación
- Protección de datos locales

### 📝 **Editor Multimedia Completo**
- Texto enriquecido con formato
- Captura de fotos (cámara/galería)
- Grabación y reproducción de audio
- Fechas automáticas con calendario

### 🌤️ **Widget Meteorológico**
- Clima en tiempo real
- Integración con OpenWeatherMap
- Detección automática de ubicación
- Timeout inteligente (5 segundos)

### 🔔 **Sistema de Notificaciones**
- Recordatorios personalizables por días
- Mensajes motivacionales aleatorios
- Resúmenes semanales automáticos
- Compatible con Android 13+

### 📊 **Estadísticas y Análisis**
- Contador de entradas por mes/año
- Racha de escritura diaria
- Progreso visual con gráficos
- Métricas de productividad

### 🎨 **Personalización**
- Modo claro/oscuro automático
- Perfil personalizable con foto
- Temas adaptativos
- Interfaz intuitiva

## 🚀 Instalación Rápida

### Prerrequisitos
- Flutter 3.x instalado
- Android Studio / VS Code
- Java 17 (para compilación Android)

### Pasos de Instalación

```bash
# Clonar el repositorio
git clone https://github.com/eliascoca85/Diary-flutter.git
cd Diary-flutter

# Instalar dependencias
flutter pub get

# Generar archivos de base de datos
dart run build_runner build --delete-conflicting-outputs

# Ejecutar en modo desarrollo
flutter run

# Compilar APK para distribución
flutter build apk --release
```

## 🏗️ Arquitectura del Proyecto

```
lib/
├── 📱 main.dart                 # Punto de entrada
├── 🔐 app_lock_wrapper.dart     # Sistema de seguridad
├── 🧩 components/               # Componentes reutilizables
├── 📺 screens/                  # Pantallas principales
├── ⚙️ services/                 # Lógica de negocio
├── 📦 models/                   # Modelos de datos
├── 🎨 themes/                   # Configuración de UI
└── 🔄 providers/                # Gestión de estado
```

### Servicios Principales
- **`database_service_isar.dart`** - Base de datos NoSQL local
- **`notification_service.dart`** - Gestión de recordatorios
- **`weather_service.dart`** - Integración meteorológica
- **`access_code_service.dart`** - Seguridad PIN
- **`media_service.dart`** - Manejo multimedia

## 📱 Capturas de Pantalla

### Widget de Clima Integrado
El componente meteorológico permite consultar el clima en tiempo real de cualquier ciudad:

<p align="center">
	<img src="lib/assets/img/cochabamba.png" alt="Clima en Cochabamba" width="250" />
	<img src="lib/assets/img/misque.png" alt="Clima en Misque" width="250" />
</p>

## 🛠️ Comandos de Desarrollo

```bash
# Desarrollo diario
flutter run                     # Ejecutar con hot reload
flutter clean                   # Limpiar cache
flutter pub get                 # Actualizar dependencias

# Base de datos
dart run build_runner build     # Regenerar archivos Isar
dart run build_runner clean     # Limpiar archivos generados

# Compilación
flutter build apk              # APK debug
flutter build apk --release    # APK producción
flutter build appbundle        # Android App Bundle
```

## 🔧 Configuración Adicional

### API de Clima
Para activar el widget meteorológico, configura tu API key de OpenWeatherMap:

```dart
// lib/services/weather_service.dart
static const String _apiKey = 'TU_API_KEY_AQUI';
```

### Notificaciones Android
Las notificaciones requieren permisos específicos que ya están configurados en `AndroidManifest.xml`.

## 📖 Documentación Técnica

Para información detallada sobre desarrollo y arquitectura, consulta:
- [`DEVELOPMENT_GUIDE.md`](DEVELOPMENT_GUIDE.md) - Guía completa de desarrollo
- [`ISAR_SETUP_GUIDE.md`](ISAR_SETUP_GUIDE.md) - Configuración de base de datos

## 🤝 Contribución

Las contribuciones son bienvenidas. Para cambios importantes:

1. Fork el proyecto
2. Crea una branch (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add AmazingFeature'`)
4. Push a la branch (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ve el archivo [LICENSE](LICENSE) para detalles.

## 👨‍💻 Desarrollador

**Elias Coca**
- GitHub: [@eliascoca85](https://github.com/eliascoca85)
- Proyecto: [Diary-flutter](https://github.com/eliascoca85/Diary-flutter)

---

### 🏆 Estado del Proyecto: **Completamente Funcional** ✅

*Última actualización: Agosto 2025*
