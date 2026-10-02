# Windows Endpoint VPN & Proxy Hardening Tool

Script automatizado en Batch y PowerShell diseñado para mitigar la evasión de políticas de red en estaciones de trabajo Windows. Implementa una estrategia de defensa en profundidad contra clientes VPN de escritorio, conexiones nativas y extensiones de navegador.

## Características

- **Bloqueo de extensiones:** Directivas empresariales (`ExtensionInstallBlocklist`) para Chrome, Edge, Brave y Firefox.
- **Restricción persistente de ejecutables:** Control por `Image File Execution Options` (IFEO) que impide el arranque de clientes conocidos (Proton, OpenVPN, WireGuard, Psiphon), persistente ante reinstalaciones.
- **Monitoreo en segundo plano:** Tarea programada oculta en cuenta `SYSTEM` que deshabilita adaptadores virtuales (TAP/TUN/Wintun) e interrumpe procesos cada 60 segundos.
- **Purga de conexiones nativas:** Restricción en políticas de red locales y eliminación de libretas de telefonía (`rasphone.pbk`) en `ncpa.cpl`.
- **Sumidero DNS:** Redirección preventiva de dominios de descarga y autenticación en el archivo `hosts`.

## Requisitos y Uso

1. Descargar el archivo `instalar.bat`.
2. Hacer clic derecho sobre el archivo y seleccionar **Ejecutar como administrador**.
3. El script aplicará las directivas, generará el monitoreo y refrescará los navegadores automáticamente.
