# 🚀 Guía Completa: Configuración de Isar Database en Flutter

## 📋 Resumen
Esta guía documenta el proceso completo para configurar Isar como base de datos local en un proyecto Flutter, resolviendo problemas de compatibilidad con Java, Gradle y Android Gradle Plugin.

## ⚡ Resultado Final
- ✅ APK generado exitosamente con Isar 3.1.0+1
- ✅ Tamaño: 53.2MB
- ✅ Compatible con Java 17, AGP 8.6.0, Gradle 8.8, Kotlin 2.1.0

---

## 🎯 Configuración Inicial Requerida

### 1. Versiones de Software
- **Java:** 17.0.12 LTS
- **Flutter:** Versión actual (compatible con AGP 8.6.0+)
- **Android Gradle Plugin:** 8.6.0
- **Gradle:** 8.8
- **Kotlin:** 2.1.0

### 2. Dependencias en pubspec.yaml
```yaml
dependencies:
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.4

dev_dependencies:
  isar_generator: ^3.1.0+1
  build_runner: ^2.4.10
```

---

## 🔧 Proceso de Configuración Paso a Paso

### **PASO 1: Configuración de Java 17**

#### 1.1 Verificar instalación de Java 17
```powershell
# Verificar versiones de Java instaladas
dir "C:\Program Files\Java\"

# Debería mostrar: jdk-17 y posiblemente otras versiones
```

#### 1.2 Configurar variables de entorno
```powershell
# Configurar JAVA_HOME y PATH para la sesión actual
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "C:\Program Files\Java\jdk-17\bin;" + $env:PATH

# Verificar que Java 17 está activo
java -version
# Debería mostrar: java version "17.0.12" 2024-07-16 LTS
```

### **PASO 2: Configuración de Android/Gradle**

#### 2.1 Actualizar android/settings.gradle
```groovy
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.6.0" apply false
    id "org.jetbrains.kotlin.android" version "2.1.0" apply false
}
```

#### 2.2 Actualizar gradle-wrapper.properties
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.8-all.zip
```

#### 2.3 Configurar android/app/build.gradle
```groovy
android {
    namespace = "com.example.diary"  // ⚠️ IMPORTANTE: Agregar namespace
    compileSdk = flutter.compileSdkVersion
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = '17'
    }
}
```

### **PASO 3: Limpieza de Caches**

#### 3.1 Limpiar caches de Gradle
```powershell
# Eliminar caches de Gradle completamente
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\caches" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\wrapper" -ErrorAction SilentlyContinue
```

#### 3.2 Limpiar proyecto Flutter
```powershell
flutter clean
```

### **PASO 4: Configuración de Dependencias**

#### 4.1 Obtener dependencias
```powershell
flutter pub get
```

### **PASO 5: ⚠️ CRÍTICO - Parchear isar_flutter_libs**

Este es el paso MÁS IMPORTANTE para resolver el problema de namespace:

#### 5.1 Recrear build.gradle de isar_flutter_libs
```powershell
$isarPath = "$env:USERPROFILE\AppData\Local\Pub\Cache\hosted\pub.dev\isar_flutter_libs-3.1.0+1\android\build.gradle"

$originalContent = @"
group 'dev.isar.isar_flutter_libs'
version '1.0'

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.6.0'
    }
}

apply plugin: 'com.android.library'

android {
    namespace = "dev.isar.isar_flutter_libs"
    compileSdkVersion 33

    defaultConfig {
        minSdkVersion 16
    }
}
"@

Set-Content -Path $isarPath -Value $originalContent -Encoding UTF8
Write-Host "✅ Archivo de build de Isar recreado con namespace"
```

#### 5.2 Verificar el parcheo
```powershell
$isarPath = "$env:USERPROFILE\AppData\Local\Pub\Cache\hosted\pub.dev\isar_flutter_libs-3.1.0+1\android\build.gradle"
Get-Content $isarPath
```

### **PASO 6: Generación de Archivos Isar**

#### 6.1 Generar archivos .g.dart
```powershell
dart run build_runner build --delete-conflicting-outputs
```

### **PASO 7: Construcción del APK**

#### 7.1 Construir APK de release
```powershell
flutter build apk --release
```

---

## 🚨 Problemas Comunes y Soluciones

### Problema 1: "Namespace not specified"
**Solución:** Ejecutar el PASO 5 (parcheo de isar_flutter_libs)

### Problema 2: "Unsupported class file major version 65"
**Solución:** Verificar que Java 17 está activo (PASO 1.2)

### Problema 3: "Could not compile build file"
**Solución:** 
1. Eliminar cache de isar_flutter_libs
2. Ejecutar `flutter pub get`
3. Reejecutar el parcheo del PASO 5

### Problema 4: Errores de red en Maven
**Solución:** 
1. Verificar conexión a internet
2. Limpiar caches de Gradle (PASO 3.1)
3. Reintentar

---

## 📝 Script de Automatización Completo

### Crear archivo: `setup_isar.ps1`
```powershell
# Script completo para configurar Isar en Flutter
Write-Host "🚀 Configurando Isar Database para Flutter..."

# 1. Configurar Java 17
Write-Host "📋 Paso 1: Configurando Java 17..."
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "C:\Program Files\Java\jdk-17\bin;" + $env:PATH
java -version

# 2. Limpiar caches
Write-Host "🧹 Paso 2: Limpiando caches..."
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\caches" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\wrapper" -ErrorAction SilentlyContinue
flutter clean

# 3. Obtener dependencias
Write-Host "📦 Paso 3: Obteniendo dependencias..."
flutter pub get

# 4. Parchear isar_flutter_libs
Write-Host "🔧 Paso 4: Parcheando isar_flutter_libs..."
$isarPath = "$env:USERPROFILE\AppData\Local\Pub\Cache\hosted\pub.dev\isar_flutter_libs-3.1.0+1\android\build.gradle"

$originalContent = @"
group 'dev.isar.isar_flutter_libs'
version '1.0'

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.6.0'
    }
}

apply plugin: 'com.android.library'

android {
    namespace = "dev.isar.isar_flutter_libs"
    compileSdkVersion 33

    defaultConfig {
        minSdkVersion 16
    }
}
"@

Set-Content -Path $isarPath -Value $originalContent -Encoding UTF8
Write-Host "✅ isar_flutter_libs parcheado exitosamente"

# 5. Generar archivos Isar
Write-Host "⚙️ Paso 5: Generando archivos Isar..."
dart run build_runner build --delete-conflicting-outputs

# 6. Construir APK
Write-Host "🔨 Paso 6: Construyendo APK..."
flutter build apk --release

Write-Host "🎉 ¡Proceso completado! APK generado en build\app\outputs\flutter-apk\app-release.apk"
```

---

## 🎯 Uso del Script

### Para usar el script en futuros proyectos:
1. Copiar el contenido del script a `setup_isar.ps1`
2. Ejecutar desde el directorio del proyecto Flutter:
```powershell
.\setup_isar.ps1
```

---

## 🔍 Verificación Final

### Comandos de verificación:
```powershell
# Verificar Java
java -version

# Verificar archivo APK generado
dir build\app\outputs\flutter-apk\app-release.apk

# Verificar que el archivo de Isar fue parcheado
$isarPath = "$env:USERPROFILE\AppData\Local\Pub\Cache\hosted\pub.dev\isar_flutter_libs-3.1.0+1\android\build.gradle"
Get-Content $isarPath | Select-String "namespace"
```

---

## 📚 Notas Importantes

1. **Siempre verificar Java 17:** El problema más común es que el sistema vuelve a Java 24
2. **El parcheo es temporal:** Se debe reejecutar después de `flutter clean` o `flutter pub get`
3. **Mantener versiones:** AGP 8.6.0, Gradle 8.8, Kotlin 2.1.0 son las versiones que funcionan
4. **Namespace es obligatorio:** Sin el namespace en isar_flutter_libs, el build fallará

---

## 🏆 Resultado Esperado

```
√ Built build\app\outputs\flutter-apk\app-release.apk (53.2MB)
```

**¡Éxito! Tu aplicación Flutter con Isar Database está lista para usar! 🎉**
