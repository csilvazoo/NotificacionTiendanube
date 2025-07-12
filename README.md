# Monitor de Dragonfish - Tiendanube

Sistema de monitoreo para la aplicación "Dragonfish - Tiendanube" que permite verificar si la aplicación está en ejecución y enviar notificaciones cuando no lo está.

## Características

- **Verificación automática**: Monitoreo continuo del estado de la aplicación
- **Notificaciones en tiempo real**: Alerta cuando la aplicación no está en ejecución
- **Configuración flexible**: Personalización de rutas y ajustes
- **Instalación sencilla**: Configuración como tarea programada de Windows
- **Interfaz amigable**: Menú interactivo para todas las operaciones

## Archivos Principales

- `VerificarDragonfish.ps1`: Realiza una verificación única del estado de la aplicación
- `MonitorDragonfish.ps1`: Ejecuta un monitoreo continuo
- `ConfigurarDragonfish.ps1`: Menú de configuración para todos los ajustes
- `InstalarMonitor.ps1`: Instala el monitor como tarea programada
- `ConfigDragonfish.json`: Almacena la configuración del monitor
- `Instructivo_Monitor_Dragonfish.txt`: Manual de usuario detallado

## Requisitos

- Windows 10 o superior
- PowerShell 5.1 o superior
- Permisos de administrador (para la instalación)

## Instalación

1. Descomprima todos los archivos en una carpeta fija
2. Ejecute `InstalarMonitor.ps1` con PowerShell como administrador
3. Siga las instrucciones en pantalla

## Configuración

Para personalizar la configuración:

1. Ejecute `ConfigurarDragonfish.ps1`
2. Utilice el menú interactivo para modificar:
   - Ruta del ejecutable
   - Intervalo de verificación
   - Otras opciones

## Uso Manual

Si prefiere ejecutar el monitor manualmente:

```powershell
.\MonitorDragonfish.ps1
```

## Solución de Problemas

Consulte el archivo `Instructivo_Monitor_Dragonfish.txt` para obtener información detallada sobre solución de problemas comunes.

## Versión

Versión 1.0 (11/07/2025)

## Licencia

Todos los derechos reservados.