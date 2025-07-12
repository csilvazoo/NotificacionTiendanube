# Script de verificacion para Dragonfish - Tiendanube
# Version 1.0 (11/07/2025)

# Establecer codificación UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Cargar configuración desde archivo JSON
$rutaConfig = Join-Path $PSScriptRoot "ConfigDragonfish.json"

if (Test-Path $rutaConfig) {
    try {
        $config = Get-Content -Path $rutaConfig -Raw | ConvertFrom-Json
        $nombreProceso = $config.NombreProceso
        $rutaCompleta = $config.RutaEjecutable
    }
    catch {
        Write-Host "Error al leer archivo de configuración. Usando valores predeterminados." -ForegroundColor Red
        $nombreProceso = "Dragonfish - Tiendanube"
        $rutaCompleta = 'C:\Program Files (x86)\Zoo Logic\Integración Dragonfish - Tiendanube\Dragonfish - Tiendanube.exe'
    }
}
else {
    # Valores predeterminados si no existe el archivo de configuración
    $nombreProceso = "Dragonfish - Tiendanube"
    $rutaCompleta = 'C:\Program Files (x86)\Zoo Logic\Integración Dragonfish - Tiendanube\Dragonfish - Tiendanube.exe'
}

# Funcion para mostrar notificacion
function Show-Notification {
    param([string]$Title, [string]$Message, [string]$Icon = "Info")
    
    try {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        
        $notification = New-Object System.Windows.Forms.NotifyIcon
        $notification.Icon = [System.Drawing.SystemIcons]::Information
        $notification.BalloonTipIcon = $Icon
        $notification.BalloonTipTitle = $Title
        $notification.BalloonTipText = $Message
        $notification.Visible = $true
        $notification.ShowBalloonTip(5000)
        
        Start-Sleep -Seconds 5
        $notification.Dispose()
    }
    catch {
        Write-Host "[$Title] $Message" -ForegroundColor Yellow
    }
}

Write-Host "=== VERIFICACION DE DRAGONFISH - TIENDANUBE ===" -ForegroundColor Green

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$proceso = Get-Process -Name $nombreProceso -ErrorAction SilentlyContinue

if ($proceso) {
    $mensaje = "La aplicacion '$nombreProceso' esta EJECUTANDOSE."
    Write-Host "[$timestamp] $mensaje" -ForegroundColor Green
    Write-Host "  - PID: $($proceso.Id)" -ForegroundColor Cyan
    Write-Host "  - Memoria: $([math]::Round($proceso.WorkingSet64/1MB, 2)) MB" -ForegroundColor Cyan
    Write-Host "  - Iniciado: $($proceso.StartTime.ToString('MM/dd/yyyy HH:mm:ss'))" -ForegroundColor Cyan
    
    # Mostrar notificacion
    Show-Notification -Title "Dragonfish - Tiendanube" -Message "Aplicacion en ejecucion (PID: $($proceso.Id))" -Icon "Info"
} 
else {
    $mensaje = "La aplicacion '$nombreProceso' NO esta ejecutandose."
    Write-Host "[$timestamp] $mensaje" -ForegroundColor Red
    
    # Verificar si el ejecutable existe
    if (Test-Path -LiteralPath $rutaCompleta) {
        Write-Host "  - La aplicacion necesita ser iniciada. Usa la opcion 3 del menu principal." -ForegroundColor Yellow
    }
    else {
        Write-Host "  - La aplicación no está instalada o la ruta es incorrecta." -ForegroundColor Red
        Write-Host "  - Ruta configurada: $rutaCompleta" -ForegroundColor Yellow
        Write-Host "  - Configura la ruta correcta con la opción 5 del menú principal." -ForegroundColor Yellow
    }
    
    # Mostrar notificacion
    Show-Notification -Title "Dragonfish - Tiendanube" -Message "Aplicacion NO esta en ejecucion" -Icon "Warning"
}

Write-Host "Verificacion completada." -ForegroundColor Gray