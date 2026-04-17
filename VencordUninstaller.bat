@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ============================================================
:: VencordUninstaller.bat
:: Entfernt Vencord vollständig:
:: - Deinstalliert Vencord aus Discord (via CLI Installer)
:: - Entfernt den Autostart-Eintrag
:: - Löscht den VBS-Launcher
:: - Löscht den Installer und alle zugehörigen Dateien
:: ============================================================

:: --- Konfiguration ---
set "INSTALL_DIR=%LOCALAPPDATA%\VencordAutoInstaller"
set "INSTALLER_EXE=%INSTALL_DIR%\VencordInstallerCli.exe"
set "VBS_LAUNCHER=%INSTALL_DIR%\VencordSilentLauncher.vbs"
set "AUTOSTART_NAME=VencordAutoInstaller"

echo.
echo ============================================
echo  Vencord Deinstallation
echo ============================================
echo.

:: --- Schritt 1: Vencord aus Discord entfernen ---
echo [1/4] Vencord aus Discord entfernen...
if exist "%INSTALLER_EXE%" (
    :: Discord schließen falls es läuft
    tasklist /FI "IMAGENAME eq Discord.exe" 2>nul | find /I "Discord.exe" >nul
    if not errorlevel 1 (
        echo       Discord wird geschlossen...
        taskkill /IM Discord.exe /F >nul 2>&1
        timeout /t 3 /nobreak >nul
    )

    :: Vencord deinstallieren via CLI
    echo       Führe Vencord Uninstall aus...
    "%INSTALLER_EXE%" --uninstall --branch auto
    if errorlevel 1 (
        "%INSTALLER_EXE%" --uninstall --branch stable
    )
    echo       [OK] Vencord Uninstall ausgeführt.
) else (
    echo       [INFO] Installer nicht gefunden, überspringe Vencord-Entfernung.
)

:: --- Schritt 2: Autostart-Eintrag entfernen ---
echo [2/4] Autostart-Eintrag entfernen...
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "%AUTOSTART_NAME%" >nul 2>&1
if not errorlevel 1 (
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "%AUTOSTART_NAME%" /f >nul 2>&1
    if not errorlevel 1 (
        echo       [OK] Autostart-Eintrag entfernt.
    ) else (
        echo       [FEHLER] Konnte Autostart-Eintrag nicht entfernen.
    )
) else (
    echo       [INFO] Kein Autostart-Eintrag vorhanden.
)

:: --- Schritt 3: VBS-Launcher löschen ---
echo [3/4] VBS-Launcher entfernen...
if exist "%VBS_LAUNCHER%" (
    del /f /q "%VBS_LAUNCHER%" >nul 2>&1
    echo       [OK] VBS-Launcher gelöscht.
) else (
    echo       [INFO] VBS-Launcher nicht vorhanden.
)

:: --- Schritt 4: Installationsverzeichnis löschen ---
echo [4/4] Installationsverzeichnis entfernen...
if exist "%INSTALL_DIR%" (
    rmdir /s /q "%INSTALL_DIR%" >nul 2>&1
    if not exist "%INSTALL_DIR%" (
        echo       [OK] Installationsverzeichnis gelöscht.
    ) else (
        echo       [FEHLER] Konnte Verzeichnis nicht vollständig löschen.
        echo       Pfad: %INSTALL_DIR%
    )
) else (
    echo       [INFO] Installationsverzeichnis nicht vorhanden.
)

:: --- Fertig ---
echo.
echo ============================================
echo  Vencord wurde vollständig deinstalliert.
echo ============================================
echo.
pause
exit /b 0
