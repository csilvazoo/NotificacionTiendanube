# Script de instalación para el monitor de Dragonfish - Tiendanube
# Version 1.0 (11/07/2025)

# Asegurarse de estar ejecutando como administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Este script requiere permisos de administrador." -ForegroundColor Red
    Write-Host "Por favor, ejecute PowerShell como administrador e intente nuevamente." -ForegroundColor Yellow
    
    # Preguntar al usuario si desea reiniciar con permisos de administrador
    $respuesta = Read-Host "¿Desea reiniciar este script con permisos de administrador? (S/N)"
    if ($respuesta -eq 'S' -or $respuesta -eq 's') {
        # Reiniciar con permisos de administrador
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    }
    exit
}

# Establecer codificación UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Definir ruta del script de monitoreo
$scriptPath = Join-Path $PSScriptRoot "MonitorDragonfish.ps1"
$nombreTarea = "MonitorDragonfish"

# Verificar que el script exista
if (-not (Test-Path $scriptPath)) {
    Write-Host "Error: No se encuentra el script de monitoreo en $scriptPath" -ForegroundColor Red
    exit
}

# Crear acción para la tarea programada
$accion = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`" -Background"

# Crear disparador para la tarea programada (al iniciar sesión)
$disparador = New-ScheduledTaskTrigger -AtLogOn

# Configuración de la tarea
$configuracion = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable

# Registrar la tarea programada
Register-ScheduledTask -TaskName $nombreTarea -Action $accion -Trigger $disparador -Settings $configuracion -Description "Monitor de Dragonfish - Tiendanube" -Force

# Verificar si la tarea se creó correctamente
$tarea = Get-ScheduledTask -TaskName $nombreTarea -ErrorAction SilentlyContinue
if ($tarea) {
    Write-Host "La tarea '$nombreTarea' ha sido instalada correctamente." -ForegroundColor Green
    Write-Host "El monitor de Dragonfish se iniciará automáticamente cada vez que inicies sesión." -ForegroundColor Green
    
    # Preguntar si desea iniciar el monitor ahora
    $iniciarAhora = Read-Host "¿Desea iniciar el monitor ahora? (S/N)"
    if ($iniciarAhora -eq 'S' -or $iniciarAhora -eq 's') {
        Start-ScheduledTask -TaskName $nombreTarea
        Write-Host "Monitor de Dragonfish iniciado." -ForegroundColor Green
    }
} else {
    Write-Host "Error: No se pudo instalar la tarea programada." -ForegroundColor Red
}

# Pausa final
Write-Host "`nPresione cualquier tecla para salir..." -ForegroundColor Cyan
$null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")