# Script de monitoreo continuo para Dragonfish - Tiendanube
# Version 1.0 (11/07/2025)

# Establecer codificación UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Verificar si se está ejecutando en modo oculto/background
$modoOculto = $args -contains "-Background" -or $args -contains "-Hidden"

# Cargar configuración desde archivo JSON
$rutaConfig = Join-Path $PSScriptRoot "ConfigDragonfish.json"

if (Test-Path $rutaConfig) {
    try {
        $config = Get-Content -Path $rutaConfig -Raw | ConvertFrom-Json
        $nombreProceso = $config.NombreProceso
        $rutaCompleta = $config.RutaEjecutable
        $intervaloSegundos = $config.IntervaloSegundos
    }
    catch {
        Write-Host "Error al leer archivo de configuración. Usando valores predeterminados." -ForegroundColor Red
        $nombreProceso = "Dragonfish - Tiendanube"
        $rutaCompleta = 'C:\Program Files (x86)\Zoo Logic\Integración Dragonfish - Tiendanube\Dragonfish - Tiendanube.exe'
        $intervaloSegundos = 10
    }
}
else {
    # Valores predeterminados si no existe el archivo de configuración
    $nombreProceso = "Dragonfish - Tiendanube"
    $rutaCompleta = 'C:\Program Files (x86)\Zoo Logic\Integración Dragonfish - Tiendanube\Dragonfish - Tiendanube.exe'
    $intervaloSegundos = 10
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

# Bucle principal de monitoreo
if (-not $modoOculto) {
    Write-Host "=== MONITOR CONTINUO - DRAGONFISH TIENDANUBE ===" -ForegroundColor Green
    Write-Host "Monitoreando proceso: $nombreProceso" -ForegroundColor Cyan
    Write-Host "Intervalo de verificacion: $intervaloSegundos segundos" -ForegroundColor Cyan
    Write-Host "Presiona Ctrl+C para detener el monitoreo" -ForegroundColor Yellow
    Write-Host "Iniciando monitoreo..." -ForegroundColor Green
    Write-Host ("-" * 60) -ForegroundColor Gray
}

# Mostrar notificación de inicio
Show-Notification -Title "Monitor Dragonfish" -Message "Monitor iniciado. Vigilando el proceso '$nombreProceso'" -Icon "Info"

$contador = 0
$estadoAnterior = $null

try {
    while ($true) {
        $contador++
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        
        # Verificar si el proceso esta ejecutandose
        $proceso = Get-Process -Name $nombreProceso -ErrorAction SilentlyContinue
        
        if ($proceso) {
            $mensaje = "La aplicacion '$nombreProceso' esta EJECUTANDOSE."
            
            # Solo mostrar si hay cambio de estado o cada 10 verificaciones
            if ($estadoAnterior -eq $false -or $contador % 10 -eq 0) {
                if (-not $modoOculto) {
                    Write-Host "[$timestamp] $mensaje (Verificacion #$contador)" -ForegroundColor Green
                    Write-Host "   PID: $($proceso.Id) | Memoria: $([math]::Round($proceso.WorkingSet64/1MB, 2)) MB" -ForegroundColor Cyan
                }
                
                # Solo notificar si cambio de estado (no estaba ejecutandose antes)
                if ($estadoAnterior -eq $false) {
                    Show-Notification -Title "Dragonfish Monitor" -Message "Aplicacion INICIADA correctamente" -Icon "Info"
                }
            }
            else {
                # Mostrar punto para indicar actividad
                if (-not $modoOculto) {
                    Write-Host "." -NoNewline -ForegroundColor Green
                    if ($contador % 50 -eq 0) { Write-Host "" }  # Nueva linea cada 50 puntos
                }
            }
            
            $estadoAnterior = $true
        }
        else {
            $mensaje = "La aplicacion '$nombreProceso' NO esta ejecutandose."
            
            # Mostrar mensaje en consola solo si hay cambio de estado o cada 10 verificaciones
            if ($estadoAnterior -eq $true -or $estadoAnterior -eq $null -or $contador % 10 -eq 0) {
                if (-not $modoOculto) {
                    Write-Host "[$timestamp] $mensaje (Verificacion #$contador)" -ForegroundColor Red
                    # Verificar si el ejecutable existe
                    if (Test-Path $rutaCompleta) {
                        Write-Host "   La aplicacion necesita ser iniciada. Usa la opcion 3 del menu principal." -ForegroundColor Yellow
                    }
                    else {
                        Write-Host "   La aplicacion no está en ejecucion. Usa la opcion 3 del menu principal para iniciarla." -ForegroundColor Yellow
                    }
                }
            }
            else {
                # Mostrar punto para indicar actividad
                if (-not $modoOculto) {
                    Write-Host "." -NoNewline -ForegroundColor Red
                    if ($contador % 50 -eq 0) { Write-Host "" }  # Nueva linea cada 50 puntos
                }
            }
            
            # Enviar notificación CADA VEZ que se verifica y no está en ejecución
            # (en TODAS las verificaciones, no solo en algunas)
            Show-Notification -Title "ALERTA: Dragonfish - Tiendanube" -Message "Aplicacion NO esta en ejecucion" -Icon "Warning"
            
            $estadoAnterior = $false
        }
        
        # Esperar antes de la siguiente verificacion
        Start-Sleep -Seconds $intervaloSegundos
    }
}
catch {
    if (-not $modoOculto) {
        Write-Host "`nMonitoreo interrumpido por el usuario." -ForegroundColor Yellow
        Write-Host "Total de verificaciones realizadas: $contador" -ForegroundColor Cyan
    }
}
finally {
    if (-not $modoOculto) {
        Write-Host "`nMonitor finalizado." -ForegroundColor Green
    }
}