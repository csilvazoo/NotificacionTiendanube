# Script de configuracion para Dragonfish - Tiendanube
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
        $dirBase = $config.DirectorioBase
    }
    catch {
        Write-Host "Error al leer archivo de configuración. Usando valores predeterminados." -ForegroundColor Red
        $nombreProceso = "Dragonfish - Tiendanube"
        $rutaCompleta = 'C:\Program Files (x86)\Zoo Logic\Integración Dragonfish - Tiendanube\Dragonfish - Tiendanube.exe'
        $dirBase = "C:\Program Files (x86)\Zoo Logic"
    }
}
else {
    # Valores predeterminados si no existe el archivo de configuración
    $nombreProceso = "Dragonfish - Tiendanube"
    $rutaCompleta = 'C:\Program Files (x86)\Zoo Logic\Integración Dragonfish - Tiendanube\Dragonfish - Tiendanube.exe'
    $dirBase = "C:\Program Files (x86)\Zoo Logic"
}

# Funcion para mostrar el menu
function Show-Menu {
    Clear-Host
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host "  MONITOR DRAGONFISH - MENU PRINCIPAL" -ForegroundColor Green
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. Verificar estado actual" -ForegroundColor Cyan
    Write-Host "2. Iniciar monitoreo continuo" -ForegroundColor Cyan
    Write-Host "3. Iniciar Dragonfish" -ForegroundColor Cyan
    Write-Host "4. Detener Dragonfish" -ForegroundColor Cyan
    Write-Host "5. Configurar rutas" -ForegroundColor Yellow
    Write-Host "0. Salir" -ForegroundColor Red
    Write-Host ""
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host ""
}

# Funcion para verificar estado
function Check-Status {
    Write-Host "`n=== VERIFICANDO ESTADO ===" -ForegroundColor Green
    
    & ".\VerificarDragonfish.ps1"
    
    Write-Host "`nPresiona cualquier tecla para continuar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Funcion para iniciar monitoreo
function Start-Monitoring {
    Write-Host "`n=== INICIANDO MONITOREO CONTINUO ===" -ForegroundColor Green
    Write-Host "Presiona Ctrl+C para detener" -ForegroundColor Yellow
    Write-Host ""
    
    & ".\MonitorDragonfish.ps1"
}

# Funcion para iniciar Dragonfish
function Start-DragonfishApp {
    Write-Host "`n=== INICIANDO DRAGONFISH ===" -ForegroundColor Green
    
    $proceso = Get-Process -Name $nombreProceso -ErrorAction SilentlyContinue
    
    if ($proceso) {
        Write-Host "La aplicacion ya esta en ejecucion (PID: $($proceso.Id))" -ForegroundColor Yellow
    }
    else {
        # Usar la ruta exacta con LiteralPath
        Write-Host "- Verificando ejecutable..." -ForegroundColor Cyan
        
        if (Test-Path -LiteralPath $rutaCompleta) {
            Write-Host "- Ejecutable encontrado en:" -ForegroundColor Green
            Write-Host "  $rutaCompleta" -ForegroundColor Yellow
              try {
                # Usar Start-Process para manejar caracteres especiales
                Start-Process -FilePath $rutaCompleta -WindowStyle Normal
                Write-Host "- Comando de inicio ejecutado correctamente" -ForegroundColor Green
                
                # Esperar un momento y verificar si inició
                Write-Host "- Esperando 5 segundos para verificar inicio..." -ForegroundColor Yellow
                Start-Sleep -Seconds 5
                
                $procesoNuevo = Get-Process -Name $nombreProceso -ErrorAction SilentlyContinue
                
                if ($procesoNuevo) {
                    Write-Host "- ¡Aplicacion iniciada correctamente!" -ForegroundColor Green
                    Write-Host "   PID: $($procesoNuevo.Id)" -ForegroundColor Cyan
                    Write-Host "   Memoria: $([math]::Round($procesoNuevo.WorkingSet64/1MB, 2)) MB" -ForegroundColor Cyan
                }
                else {
                    Write-Host "- La aplicacion esta tardando en iniciar o hubo un problema" -ForegroundColor Yellow
                    Write-Host "  Intenta verificar el estado en unos segundos (opción 1)" -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "- Error al iniciar la aplicacion: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "  Detalles: $($Error[0])" -ForegroundColor Red
            }
        }
        else {
            Write-Host "- ERROR: No se encontro el ejecutable en:" -ForegroundColor Red
            Write-Host "  $rutaCompleta" -ForegroundColor Yellow
            
            # Verificar si existe el directorio base
            $dirBase = "C:\Program Files (x86)\Zoo Logic"
            if (Test-Path -LiteralPath $dirBase) {
                Write-Host "- El directorio base existe. Verificando subdirectorios..." -ForegroundColor Cyan
                
                # Listar subdirectorios disponibles
                $subDirs = Get-ChildItem -Path $dirBase -Directory 
                if ($subDirs) {
                    Write-Host "- Subdirectorios disponibles:" -ForegroundColor Cyan
                    foreach ($dir in $subDirs) {
                        Write-Host "  * $($dir.Name)" -ForegroundColor Yellow
                    }
                      # Buscar ejecutables de Dragonfish en cualquier subdirectorio
                    Write-Host "- Buscando ejecutables de Dragonfish..." -ForegroundColor Cyan
                    $encontrados = Get-ChildItem -Path $dirBase -Recurse -Filter "*Dragonfish*.exe" -ErrorAction SilentlyContinue
                    
                    if ($encontrados) {
                        Write-Host "- Ejecutables encontrados:" -ForegroundColor Green
                        foreach ($exe in $encontrados) {
                            Write-Host "  * $($exe.FullName)" -ForegroundColor Yellow
                        }
                        
                        # Buscar específicamente el ejecutable de Tiendanube
                        $ejecutableTiendanube = $encontrados | Where-Object { $_.Name -eq "Dragonfish - Tiendanube.exe" }
                        
                        if ($ejecutableTiendanube) {
                            Write-Host "- Ejecutable de Tiendanube encontrado. Intentando iniciar..." -ForegroundColor Green
                            try {
                                Start-Process -FilePath $ejecutableTiendanube.FullName -WindowStyle Normal
                                Write-Host "- Comando de inicio ejecutado correctamente" -ForegroundColor Green
                            }
                            catch {
                                Write-Host "- Error al iniciar: $($_.Exception.Message)" -ForegroundColor Red
                            }
                        }
                        else {
                            Write-Host "- No se encontro especificamente el ejecutable 'Dragonfish - Tiendanube.exe'" -ForegroundColor Red

                            # Buscar en la ruta específica que sabemos que existe
                            $rutaEspecifica = 'C:\Program Files (x86)\Zoo Logic\Integración Dragonfish - Tiendanube\Dragonfish - Tiendanube.exe'
                            Write-Host "- Intentando iniciar directamente desde: $rutaEspecifica" -ForegroundColor Cyan
                            
                            try {
                                Start-Process -FilePath $rutaEspecifica -WindowStyle Normal
                                Write-Host "- Comando de inicio ejecutado correctamente" -ForegroundColor Green
                            }
                            catch {
                                Write-Host "- Error al iniciar: $($_.Exception.Message)" -ForegroundColor Red
                            }
                        }
                    }
                    else {
                        Write-Host "- No se encontraron ejecutables de Dragonfish" -ForegroundColor Red
                    }
                }
            }
            else {
                Write-Host "- El directorio base tampoco existe: $dirBase" -ForegroundColor Red
                Write-Host "- Verifica que la aplicacion este instalada correctamente" -ForegroundColor Red
            }
        }
    }
    
    Write-Host "`nPresiona cualquier tecla para continuar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Funcion para detener Dragonfish
function Stop-DragonfishApp {
    Write-Host "`n=== DETENIENDO DRAGONFISH ===" -ForegroundColor Yellow
    
    $proceso = Get-Process -Name $nombreProceso -ErrorAction SilentlyContinue
    
    if ($proceso) {
        try {
            Stop-Process -Id $proceso.Id -Force
            Write-Host "- Aplicacion detenida correctamente" -ForegroundColor Green
        }
        catch {
            Write-Host "- Error al detener la aplicacion: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "La aplicacion no esta en ejecucion" -ForegroundColor Yellow
    }
      Write-Host "`nPresiona cualquier tecla para continuar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Funcion para configurar rutas
function Configure-Paths {
    Write-Host "`n=== CONFIGURAR RUTAS ===" -ForegroundColor Green
    
    Write-Host "Configuracion actual:" -ForegroundColor Cyan
    Write-Host "1. Nombre del proceso: $nombreProceso" -ForegroundColor Yellow
    Write-Host "2. Ruta ejecutable: $rutaCompleta" -ForegroundColor Yellow
    Write-Host "3. Directorio base: $dirBase" -ForegroundColor Yellow
    Write-Host "4. Guardar configuracion" -ForegroundColor Green
    Write-Host "0. Volver al menu principal" -ForegroundColor Red
    Write-Host ""
    
    $opcion = Read-Host "Selecciona una opcion (0-4)"
    
    switch ($opcion) {
        "1" { 
            $nuevoNombre = Read-Host "Ingresa el nuevo nombre del proceso (actual: $nombreProceso)"
            if (![string]::IsNullOrWhiteSpace($nuevoNombre)) {
                $nombreProceso = $nuevoNombre
                Write-Host "Nombre del proceso actualizado." -ForegroundColor Green
            }
            Configure-Paths  # Volver al menú de configuración
        }
        "2" { 
            Write-Host "Selecciona el metodo para configurar la ruta:" -ForegroundColor Cyan
            Write-Host "1. Ingresar manualmente" -ForegroundColor Yellow
            Write-Host "2. Buscar automaticamente" -ForegroundColor Yellow
            $metodo = Read-Host "Selecciona (1-2)"
            
            if ($metodo -eq "1") {
                $nuevaRuta = Read-Host "Ingresa la nueva ruta completa al ejecutable"
                if (![string]::IsNullOrWhiteSpace($nuevaRuta)) {
                    if (Test-Path -LiteralPath $nuevaRuta) {
                        $rutaCompleta = $nuevaRuta
                        Write-Host "Ruta actualizada y verificada." -ForegroundColor Green
                    } else {
                        Write-Host "ADVERTENCIA: La ruta ingresada no existe. No se ha actualizado." -ForegroundColor Red
                    }
                }
            } elseif ($metodo -eq "2") {
                Write-Host "Buscando ejecutables de Dragonfish en el sistema..." -ForegroundColor Cyan
                
                # Definir ubicaciones comunes donde buscar
                $ubicaciones = @(
                    "C:\Program Files",
                    "C:\Program Files (x86)"
                )
                
                $encontrados = @()
                foreach ($ubicacion in $ubicaciones) {
                    if (Test-Path $ubicacion) {
                        Write-Host "Buscando en $ubicacion..." -ForegroundColor Yellow
                        $encontrados += Get-ChildItem -Path $ubicacion -Recurse -Filter "*Dragonfish*.exe" -ErrorAction SilentlyContinue
                    }
                }
                
                if ($encontrados.Count -gt 0) {
                    Write-Host "Se encontraron los siguientes ejecutables:" -ForegroundColor Green
                    for ($i = 0; $i -lt $encontrados.Count; $i++) {
                        Write-Host "$($i+1). $($encontrados[$i].FullName)" -ForegroundColor Yellow
                    }
                    
                    $seleccion = Read-Host "Selecciona el número del ejecutable o 0 para cancelar"
                    if ($seleccion -match '^\d+$' -and [int]$seleccion -gt 0 -and [int]$seleccion -le $encontrados.Count) {
                        $rutaCompleta = $encontrados[[int]$seleccion-1].FullName
                        $dirBase = Split-Path (Split-Path $rutaCompleta -Parent) -Parent
                        Write-Host "Ruta actualizada a: $rutaCompleta" -ForegroundColor Green
                    } elseif ($seleccion -ne "0") {
                        Write-Host "Seleccion invalida. No se ha actualizado la ruta." -ForegroundColor Red
                    }
                } else {
                    Write-Host "No se encontraron ejecutables de Dragonfish." -ForegroundColor Red
                }
            }
            Configure-Paths  # Volver al menú de configuración
        }
        "3" { 
            $nuevoDir = Read-Host "Ingresa el nuevo directorio base (actual: $dirBase)"
            if (![string]::IsNullOrWhiteSpace($nuevoDir)) {
                if (Test-Path -LiteralPath $nuevoDir) {
                    $dirBase = $nuevoDir
                    Write-Host "Directorio base actualizado." -ForegroundColor Green
                } else {
                    Write-Host "ADVERTENCIA: El directorio ingresado no existe. No se ha actualizado." -ForegroundColor Red
                }
            }
            Configure-Paths  # Volver al menú de configuración
        }
        "4" { 
            # Guardar configuración en archivo JSON
            $config = @{
                NombreProceso = $nombreProceso
                RutaEjecutable = $rutaCompleta
                DirectorioBase = $dirBase
                IntervaloSegundos = 10  # Valor predeterminado
            }
            
            try {
                $config | ConvertTo-Json | Out-File -FilePath $rutaConfig -Encoding UTF8
                Write-Host "Configuracion guardada correctamente en $rutaConfig" -ForegroundColor Green
            }
            catch {
                Write-Host "Error al guardar la configuracion: $($_.Exception.Message)" -ForegroundColor Red
            }

            Write-Host "`nPresiona cualquier tecla para continuar..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "0" { return }  # Volver al menú principal
        default {
            Write-Host "`nOpción inválida. Presiona cualquier tecla para continuar..." -ForegroundColor Red
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            Configure-Paths  # Volver al menú de configuración
        }
    }
}

# Menu principal
do {
    Show-Menu
    $opcion = Read-Host "Selecciona una opcion (0-5)"
    
    switch ($opcion) {
        "1" { Check-Status }
        "2" { Start-Monitoring }
        "3" { Start-DragonfishApp }
        "4" { Stop-DragonfishApp }
        "5" { Configure-Paths }
        "0" { 
            Write-Host "`nSaliendo..." -ForegroundColor Green
            break
        }
        default {
            Write-Host "`nOpcion invalida. Presiona cualquier tecla para continuar..." -ForegroundColor Red
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
} while ($opcion -ne "0")

Write-Host "Programa finalizado." -ForegroundColor Green