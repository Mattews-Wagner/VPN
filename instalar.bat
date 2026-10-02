@echo off
:: Verificar privilegios de administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Este script debe ejecutarse como Administrador.
    pause
    exit /b
)

echo ========================================================
echo   Configurando proteccion completa y bloqueo universal
echo ========================================================

:: 1. Crear carpeta local en C:\Scripts
if not exist "C:\Scripts" mkdir "C:\Scripts"

:: 2. Generar el script de PowerShell en C:\Scripts\BloqueoVPN.ps1
(
    echo # Terminar procesos de clientes VPN comunes
    echo $procesos = @("ProtonVPN*", "NordVPN*", "OpenVPN*", "wireguard*", "Psiphon*", "warp*", "expressvpn*", "windscribe*", "surfshark*"^)
    echo Get-Process -Name $procesos -ErrorAction SilentlyContinue ^| Stop-Process -Force -ErrorAction SilentlyContinue
    echo.
    echo # Deshabilitar adaptadores virtuales TAP/TUN/WireGuard
    echo Get-NetAdapter ^| Where-Object { $_.InterfaceDescription -match "TAP|TUN|WireGuard|Wintun|Proton" -or $_.Name -match "Proton|VPN|TAP|TUN" } ^| Disable-NetAdapter -Confirm:$false -ErrorAction SilentlyContinue
    echo.
    echo # Detener servicios en segundo plano
    echo $servicios = @("ProtonVPN Service", "WireGuardTunnel*", "OpenVPNService", "NordVpnService", "WindscribeService"^)
    echo Get-Service -Name $servicios -ErrorAction SilentlyContinue ^| Stop-Service -Force -ErrorAction SilentlyContinue
    echo.
    echo # Eliminar perfiles de VPN de Windows
    echo Get-VpnConnection -AllUserConnection -ErrorAction SilentlyContinue ^| Remove-VpnConnection -Force -ErrorAction SilentlyContinue
    echo Get-VpnConnection -ErrorAction SilentlyContinue ^| Remove-VpnConnection -Force -ErrorAction SilentlyContinue
    echo.
    echo # Borrar libretas de conexiones manuales
    echo Remove-Item -Path "$env:ProgramData\Microsoft\Network\Connections\Pbk\rasphone.pbk" -Force -ErrorAction SilentlyContinue
    echo Get-ChildItem -Path "C:\Users\*\AppData\Roaming\Microsoft\Network\Connections\Pbk\rasphone.pbk" -Force -ErrorAction SilentlyContinue ^| Remove-Item -Force -ErrorAction SilentlyContinue
) > "C:\Scripts\BloqueoVPN.ps1"
echo [OK] Script de monitoreo actualizado.

:: 3. Bloqueo de ejecutables en el registro (IFEO - persistente ante reinstalacion)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ProtonVPN.exe" /v Debugger /t REG_SZ /d "cmd.exe /c exit" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ProtonVPN.Launcher.exe" /v Debugger /t REG_SZ /d "cmd.exe /c exit" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ProtonVPN.WireGuardService.exe" /v Debugger /t REG_SZ /d "cmd.exe /c exit" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ProtonVPN.Service.exe" /v Debugger /t REG_SZ /d "cmd.exe /c exit" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wireguard.exe" /v Debugger /t REG_SZ /d "cmd.exe /c exit" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\openvpn.exe" /v Debugger /t REG_SZ /d "cmd.exe /c exit" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\psiphon3.exe" /v Debugger /t REG_SZ /d "cmd.exe /c exit" /f >nul
echo [OK] Bloqueo de aplicaciones de escritorio aplicado.

:: 4. Prohibir creacion de nuevas VPNs manuales en Windows
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Network Connections" /v NC_AllowAdvancedTCPIPConfig /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Network Connections" /v NC_NewVpnConnection /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Policies\Microsoft\Windows\Network Connections" /v NC_NewVpnConnection /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Network Connections" /v NC_AddDelVpnConnection /t REG_DWORD /d 0 /f >nul
echo [OK] Directivas de VPNs manuales aplicadas.

:: 5. BLOQUEO TOTAL DE EXTENSIONES EN TODOS LOS NAVEGADORES (Chrome, Edge, Brave y Firefox)
:: Limpiar listas anteriores
reg delete "HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallBlocklist" /f >nul 2>&1
reg delete "HKCU\Software\Policies\Google\Chrome\ExtensionInstallBlocklist" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallAllowlist" /f >nul 2>&1
reg delete "HKCU\Software\Policies\Google\Chrome\ExtensionInstallAllowlist" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallBlocklist" /f >nul 2>&1
reg delete "HKCU\Software\Policies\Microsoft\Edge\ExtensionInstallBlocklist" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallAllowlist" /f >nul 2>&1
reg delete "HKCU\Software\Policies\Microsoft\Edge\ExtensionInstallAllowlist" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\BraveSoftware\Brave\ExtensionInstallBlocklist" /f >nul 2>&1
reg delete "HKCU\Software\Policies\BraveSoftware\Brave\ExtensionInstallBlocklist" /f >nul 2>&1

:: Bloqueo absoluto (*) en Google Chrome
reg add "HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallBlocklist" /v 1 /t REG_SZ /d "*" /f >nul
reg add "HKCU\Software\Policies\Google\Chrome\ExtensionInstallBlocklist" /v 1 /t REG_SZ /d "*" /f >nul

:: Bloqueo absoluto (*) en Microsoft Edge
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallBlocklist" /v 1 /t REG_SZ /d "*" /f >nul
reg add "HKCU\Software\Policies\Microsoft\Edge\ExtensionInstallBlocklist" /v 1 /t REG_SZ /d "*" /f >nul

:: Bloqueo absoluto (*) en Brave
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave\ExtensionInstallBlocklist" /v 1 /t REG_SZ /d "*" /f >nul
reg add "HKCU\Software\Policies\BraveSoftware\Brave\ExtensionInstallBlocklist" /v 1 /t REG_SZ /d "*" /f >nul

:: Bloqueo absoluto (*) en Mozilla Firefox
reg add "HKLM\SOFTWARE\Policies\Mozilla\Firefox\Extensions\Block" /v 1 /t REG_SZ /d "*" /f >nul
echo [OK] Bloqueo total de extensiones activado en todos los navegadores.

:: 6. Refresco forzado de todos los navegadores para aplicar directivas al instante
taskkill /F /IM chrome.exe /T >nul 2>&1
taskkill /F /IM msedge.exe /T >nul 2>&1
taskkill /F /IM brave.exe /T >nul 2>&1
taskkill /F /IM firefox.exe /T >nul 2>&1
echo [OK] Procesos de navegadores refrescados.

:: 7. Detener y deshabilitar servicios de Proton
sc stop "ProtonVPN Service" >nul 2>&1
sc config "ProtonVPN Service" start= disabled >nul 2>&1

:: 8. Bloqueo de dominios de descarga en archivo hosts
findstr /C:"protonvpn.com" "%WINDIR%\System32\drivers\etc\hosts" >nul
if %errorLevel% neq 0 (
    echo. >> "%WINDIR%\System32\drivers\etc\hosts"
    echo # Bloqueo VPN >> "%WINDIR%\System32\drivers\etc\hosts"
    echo 127.0.0.1  protonvpn.com >> "%WINDIR%\System32\drivers\etc\hosts"
    echo 127.0.0.1  www.protonvpn.com >> "%WINDIR%\System32\drivers\etc\hosts"
    echo 127.0.0.1  account.proton.me >> "%WINDIR%\System32\drivers\etc\hosts"
    echo 127.0.0.1  api.protonvpn.ch >> "%WINDIR%\System32\drivers\etc\hosts"
    echo 127.0.0.1  tunnelbear.com >> "%WINDIR%\System32\drivers\etc\hosts"
    echo 127.0.0.1  ultrasurf.us >> "%WINDIR%\System32\drivers\etc\hosts"
    echo 127.0.0.1  touchvpn.net >> "%WINDIR%\System32\drivers\etc\hosts"
    echo 127.0.0.1  urban-vpn.com >> "%WINDIR%\System32\drivers\etc\hosts"
    echo 127.0.0.1  veepn.com >> "%WINDIR%\System32\drivers\etc\hosts"
    echo [OK] Dominios bloqueados en archivo hosts.
)

:: 9. Tarea programada cada 1 minuto (schtasks nativo en cuenta SYSTEM)
schtasks /delete /tn "NetworkIntegrityCheck" /f >nul 2>&1
schtasks /create /tn "NetworkIntegrityCheck" /tr "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File C:\Scripts\BloqueoVPN.ps1" /sc minute /mo 1 /ru "SYSTEM" /rl HIGHEST /f >nul
echo [OK] Monitoreo cada 1 minuto programado con exito.

:: 10. Limpieza y purga inmediata
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\BloqueoVPN.ps1"

echo ========================================================
echo   Instalacion completada con exito.
echo ========================================================
timeout /t 2 >nul
exit