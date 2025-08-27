# Script para parchear isar_flutter_libs y agregar namespace
$isarBuildFile = "$env:USERPROFILE\AppData\Local\Pub\Cache\hosted\pub.dev\isar_flutter_libs-3.1.0+1\android\build.gradle"

if (Test-Path $isarBuildFile) {
    Write-Host "Parcheando archivo de build de isar_flutter_libs..."
    
    $content = Get-Content $isarBuildFile -Raw
    
    # Verificar si ya tiene namespace
    if ($content -notmatch "namespace") {
        # Agregar namespace después de la línea "android {"
        $content = $content -replace "(android\s*\{)", "`$1`n    namespace = `"dev.isar.isar_flutter_libs`""
        
        # Escribir el archivo modificado
        Set-Content -Path $isarBuildFile -Value $content -Encoding UTF8
        Write-Host "✓ Namespace agregado exitosamente a isar_flutter_libs"
    } else {
        Write-Host "✓ isar_flutter_libs ya tiene namespace configurado"
    }
} else {
    Write-Host "⚠ Archivo de build de isar_flutter_libs no encontrado en: $isarBuildFile"
}
