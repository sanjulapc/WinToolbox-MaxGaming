@echo off
:: ============================================================
::   G O D   S E R V E R   -   ALL-IN-ONE  (single batch file)
:: ------------------------------------------------------------
::   Combines all five tools into one file:
::     [1] Permanent Debloater
::     [2] EXM Premium Tweaks
::     [3] GOD MODE ULTIMATE
::     [4] Nuclear Process Killer
::     [5] Auto BIOS Tweaker
::   Nothing removed - every command from every tool is kept.
:: ============================================================
setlocal
title GOD SERVER - All-In-One Toolbox

:: ---- Self-elevate to Administrator (single check for all tools) ----
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs" >nul 2>&1
    exit /b
)

:MAIN_MENU
cls
color 0B
echo ============================================================
echo                    G O D   S E R V E R
echo                 All-In-One Windows Toolbox
echo ============================================================
echo.
echo   [1]  Permanent Debloater      - remove bloatware apps ^& tasks
echo   [2]  EXM Premium Tweaks       - BIOS/CPU/GPU/power tweaks
echo   [3]  GOD MODE ULTIMATE        - extreme debloat (offers reboot)
echo   [4]  Nuclear Process Killer   - extreme debloat (offers reboot)
echo   [5]  Auto BIOS Tweaker        - needs SCEWIN_64.exe in this folder
echo.
echo   [9]  RUN ALL                  - runs 1 - 2 - 3 - 4, then one reboot
echo   [0]  Exit
echo.
set "choice="
set /p choice=Select an option: 
if "%choice%"=="1" call :TOOL_DEBLOATER
if "%choice%"=="2" call :TOOL_EXM
if "%choice%"=="3" call :TOOL_GODMODE
if "%choice%"=="4" call :TOOL_NUCLEAR
if "%choice%"=="5" call :TOOL_BIOS
if "%choice%"=="9" call :RUN_ALL
if "%choice%"=="0" goto :END
goto :MAIN_MENU

:RUN_ALL
set "RUNALL=1"
call :TOOL_DEBLOATER
call :TOOL_EXM
call :TOOL_GODMODE
call :TOOL_NUCLEAR
set "RUNALL="
cls
echo ============================================================
echo   RUN ALL COMPLETE - all four software modules applied
echo   (Auto BIOS is interactive - run option [5] separately)
echo ============================================================
call :REBOOT_PROMPT
goto :eof

:REBOOT_PROMPT
if "%RUNALL%"=="1" goto :eof
echo.
set "rb="
set /p rb=Reboot now to apply all changes? (Y/N): 
if /i "%rb%"=="Y" (
    echo System will restart in 5 seconds...
    shutdown /r /t 5 /c "GOD SERVER - Rebooting to apply changes..."
)
goto :eof

:END
endlocal
exit /b 0

:: ############################################################
:: #  TOOL 1 : PERMANENT DEBLOATER
:: ############################################################
:TOOL_DEBLOATER
title GOD SERVER - Permanent Debloater
:: ============================================================
:: Admin Check
:: ============================================================

echo.
echo ============================================================
echo          WINDOWS PERMANENT DEBLOATER
echo          No Nvidia - All Users - No Reinstall
echo ============================================================
echo.
echo WARNING: This will permanently remove bloatware apps.
echo Press CTRL+C to cancel or...
pause

:: ============================================================
:: STEP 1 - Remove AppX Packages (Current + All Users)
:: ============================================================
echo.
echo [STEP 1] Removing AppX packages for all users...
echo.

set "apps=3DViewer BingWeather BingNews BingFinance BingSports BingTranslator Cortana FeedbackHub GetHelp Getstarted MicrosoftOfficeHub MicrosoftSolitaireCollection MixedReality Office.OneNote OneConnect People Print3D SkypeApp StickyNotes Teams Todos Whiteboard WindowsAlarms WindowsCamera windowscommunicationsapps WindowsMaps WindowsSoundRecorder Xbox ZuneMusic ZuneVideo YourPhone LinkedIn Clipchamp PowerAutomateDesktop MSPaint"

for %%A in (%apps%) do (
    echo   [-] Removing: %%A
    powershell -NoProfile -Command "Get-AppxPackage -AllUsers *%%A* | Remove-AppxPackage -AllUsers" >nul 2>&1
)

:: ============================================================
:: STEP 2 - Remove Provisioned Packages (Prevents Reinstall)
:: ============================================================
echo.
echo [STEP 2] Removing provisioned packages (prevents reinstall)...
echo.

for %%A in (%apps%) do (
    echo   [-] Deprovisioning: %%A
    powershell -NoProfile -Command "Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like '*%%A*' | Remove-AppxProvisionedPackage -Online" >nul 2>&1
)

:: ============================================================
:: STEP 3 - Disable Cortana via Registry
:: ============================================================
echo.
echo [STEP 3] Disabling Cortana via registry...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d 0 /f >nul 2>&1
echo   [OK] Cortana disabled.

:: ============================================================
:: STEP 4 - Disable Telemetry & Data Collection
:: ============================================================
echo.
echo [STEP 4] Disabling telemetry and data collection...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
echo   [OK] Telemetry disabled.

:: ============================================================
:: STEP 5 - Disable Windows Feedback
:: ============================================================
echo.
echo [STEP 5] Disabling Windows feedback requests...
reg add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d 1 /f >nul 2>&1
echo   [OK] Feedback disabled.

:: ============================================================
:: STEP 6 - Disable Xbox Game Bar & DVR
:: ============================================================
echo.
echo [STEP 6] Disabling Xbox Game Bar and DVR...
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo   [OK] Xbox Game Bar and DVR disabled.

:: ============================================================
:: STEP 7 - Disable Bing Search in Start Menu
:: ============================================================
echo.
echo [STEP 7] Disabling Bing search in Start Menu...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaConsent" /t REG_DWORD /d 0 /f >nul 2>&1
echo   [OK] Bing search in Start Menu disabled.

:: ============================================================
:: STEP 8 - Disable Advertising ID
:: ============================================================
echo.
echo [STEP 8] Disabling Advertising ID...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d 1 /f >nul 2>&1
echo   [OK] Advertising ID disabled.

:: ============================================================
:: STEP 9 - Disable Windows Tips and Suggestions
:: ============================================================
echo.
echo [STEP 9] Disabling Windows tips, tricks and suggestions...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo   [OK] Tips and suggestions disabled.

:: ============================================================
:: STEP 10 - Disable Auto-install of Suggested Apps
:: ============================================================
echo.
echo [STEP 10] Disabling auto-install of suggested/sponsored apps...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OemPreInstalledAppsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo   [OK] Auto-install of suggested apps disabled.

:: ============================================================
:: STEP 11 - Disable Bloat Scheduled Tasks
:: ============================================================
echo.
echo [STEP 11] Disabling bloat scheduled tasks...
schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Application Experience\ProgramDataUpdater" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Autochk\Proxy" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Feedback\Siuf\DmClient" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting" /Disable >nul 2>&1
echo   [OK] Scheduled tasks disabled.

:: ============================================================
:: STEP 12 - Disable ALL Non-Essential Services (Permanently)
:: ============================================================
echo.
echo [STEP 12] Disabling all non-essential Windows services...

:: --- Telemetry / Diagnostics / Reporting ---
sc stop "DiagTrack"             >nul 2>&1 & sc config "DiagTrack"             start= disabled >nul 2>&1
sc stop "dmwappushservice"      >nul 2>&1 & sc config "dmwappushservice"      start= disabled >nul 2>&1
sc stop "WerSvc"                >nul 2>&1 & sc config "WerSvc"                start= disabled >nul 2>&1
sc stop "PcaSvc"                >nul 2>&1 & sc config "PcaSvc"                start= disabled >nul 2>&1
sc stop "DPS"                   >nul 2>&1 & sc config "DPS"                   start= disabled >nul 2>&1
sc stop "WdiServiceHost"        >nul 2>&1 & sc config "WdiServiceHost"        start= disabled >nul 2>&1
sc stop "WdiSystemHost"         >nul 2>&1 & sc config "WdiSystemHost"         start= disabled >nul 2>&1

:: --- Xbox / Gaming ---
sc stop "XblAuthManager"        >nul 2>&1 & sc config "XblAuthManager"        start= disabled >nul 2>&1
sc stop "XblGameSave"           >nul 2>&1 & sc config "XblGameSave"           start= disabled >nul 2>&1
sc stop "XboxNetApiSvc"         >nul 2>&1 & sc config "XboxNetApiSvc"         start= disabled >nul 2>&1
sc stop "XboxGipSvc"            >nul 2>&1 & sc config "XboxGipSvc"            start= disabled >nul 2>&1
sc stop "GamingServices"        >nul 2>&1 & sc config "GamingServices"        start= disabled >nul 2>&1
sc stop "GamingServicesNet"     >nul 2>&1 & sc config "GamingServicesNet"     start= disabled >nul 2>&1

:: --- Maps / Location ---
sc stop "MapsBroker"            >nul 2>&1 & sc config "MapsBroker"            start= disabled >nul 2>&1
sc stop "lfsvc"                 >nul 2>&1 & sc config "lfsvc"                 start= disabled >nul 2>&1

:: --- Remote Access / Assistance ---
sc stop "RemoteRegistry"        >nul 2>&1 & sc config "RemoteRegistry"        start= disabled >nul 2>&1
sc stop "RemoteAccess"          >nul 2>&1 & sc config "RemoteAccess"          start= disabled >nul 2>&1
sc stop "SessionEnv"            >nul 2>&1 & sc config "SessionEnv"            start= disabled >nul 2>&1
sc stop "TermService"           >nul 2>&1 & sc config "TermService"           start= disabled >nul 2>&1
sc stop "UmRdpService"          >nul 2>&1 & sc config "UmRdpService"          start= disabled >nul 2>&1

:: --- Fax ---
sc stop "Fax"                   >nul 2>&1 & sc config "Fax"                   start= disabled >nul 2>&1

:: --- Retail Demo / OEM ---
sc stop "RetailDemo"            >nul 2>&1 & sc config "RetailDemo"            start= disabled >nul 2>&1

:: --- Windows Media Player Network Sharing ---
sc stop "WMPNetworkSvc"         >nul 2>&1 & sc config "WMPNetworkSvc"         start= disabled >nul 2>&1

:: --- Smart Card ---
sc stop "SCardSvr"              >nul 2>&1 & sc config "SCardSvr"              start= disabled >nul 2>&1
sc stop "ScDeviceEnum"          >nul 2>&1 & sc config "ScDeviceEnum"          start= disabled >nul 2>&1

:: --- Tablet / Touch ---
sc stop "TabletInputService"    >nul 2>&1 & sc config "TabletInputService"    start= disabled >nul 2>&1

:: --- Phone / Mobile Hotspot ---
sc stop "PhoneSvc"              >nul 2>&1 & sc config "PhoneSvc"              start= disabled >nul 2>&1
sc stop "icssvc"                >nul 2>&1 & sc config "icssvc"                start= disabled >nul 2>&1

:: --- Mixed Reality ---
sc stop "perceptionsimulation"  >nul 2>&1 & sc config "perceptionsimulation"  start= disabled >nul 2>&1

:: --- Connected User Experiences (Telemetry backbone) ---
sc stop "CDPSvc"                >nul 2>&1 & sc config "CDPSvc"                start= disabled >nul 2>&1
sc stop "CDPUserSvc"            >nul 2>&1 & sc config "CDPUserSvc"            start= disabled >nul 2>&1

:: --- Push Notifications ---
sc stop "WpnService"            >nul 2>&1 & sc config "WpnService"            start= disabled >nul 2>&1
sc stop "WpnUserService"        >nul 2>&1 & sc config "WpnUserService"        start= disabled >nul 2>&1

:: --- HomeGroup ---
sc stop "HomeGroupListener"     >nul 2>&1 & sc config "HomeGroupListener"     start= disabled >nul 2>&1
sc stop "HomeGroupProvider"     >nul 2>&1 & sc config "HomeGroupProvider"     start= disabled >nul 2>&1

:: --- Peer-to-Peer / Branch Cache ---
sc stop "PeerDistSvc"           >nul 2>&1 & sc config "PeerDistSvc"           start= disabled >nul 2>&1
sc stop "p2psvc"                >nul 2>&1 & sc config "p2psvc"                start= disabled >nul 2>&1
sc stop "p2pimsvc"              >nul 2>&1 & sc config "p2pimsvc"              start= disabled >nul 2>&1
sc stop "PNRPsvc"               >nul 2>&1 & sc config "PNRPsvc"               start= disabled >nul 2>&1
sc stop "PNRPAutoReg"           >nul 2>&1 & sc config "PNRPAutoReg"           start= disabled >nul 2>&1

:: --- Secondary Logon ---
sc stop "seclogon"              >nul 2>&1 & sc config "seclogon"              start= disabled >nul 2>&1

:: --- AllJoyn Router ---
sc stop "AJRouter"              >nul 2>&1 & sc config "AJRouter"              start= disabled >nul 2>&1

:: --- Geolocation ---
sc stop "GeoSvc"                >nul 2>&1 & sc config "GeoSvc"                start= disabled >nul 2>&1

echo   [OK] All non-essential services permanently disabled.

:: ============================================================
:: STEP 13 - Group Policy Lockdowns (via Registry / LGPO)
:: ============================================================
echo.
echo [STEP 13] Applying Group Policy lockdowns...

:: --- Telemetry & Data Collection ---
echo   [GP] Telemetry and data collection...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "LimitDiagnosticLogCollection" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DisableOneSettingsDownloads" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d 1 /f >nul 2>&1

:: --- Cortana & Search ---
echo   [GP] Cortana and web search...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortanaAboveLock" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchPrivacy" /t REG_DWORD /d 3 /f >nul 2>&1

:: --- OneDrive ---
echo   [GP] OneDrive...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSync" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableLibrariesDefaultSaveToOneDrive" /t REG_DWORD /d 1 /f >nul 2>&1

:: --- Windows Error Reporting ---
echo   [GP] Windows Error Reporting...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "LoggingDisabled" /t REG_DWORD /d 1 /f >nul 2>&1

:: --- Windows Update (disable auto-reboot, disable ads in update) ---
echo   [GP] Windows Update behavior...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUPowerManagement" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableWindowsUpdateAccess" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "SetDisableUXWUAccess" /t REG_DWORD /d 0 /f >nul 2>&1

:: --- Advertising & Consumer Experience ---
echo   [GP] Advertising ID and consumer experience...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableSoftLanding" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableThirdPartySuggestions" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableThirdPartySuggestions" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableTailoredExperiencesWithDiagnosticData" /t REG_DWORD /d 1 /f >nul 2>&1

:: --- Location ---
echo   [GP] Location services...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocationScripting" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableSensors" /t REG_DWORD /d 1 /f >nul 2>&1

:: --- Camera & Microphone (GP enforcement) ---
echo   [GP] Camera and microphone app access...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessCamera" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessLocation" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessContacts" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessCalendar" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessCallHistory" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessEmail" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessMessaging" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessRadios" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsSyncWithDevices" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessAccountInfo" /t REG_DWORD /d 2 /f >nul 2>&1

:: --- Xbox & Game DVR ---
echo   [GP] Xbox and Game DVR...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul 2>&1

:: --- Microsoft Store (block auto-updates of store apps) ---
echo   [GP] Microsoft Store app auto-updates...
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "AutoDownload" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "DisableStoreApps" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "RemoveWindowsStore" /t REG_DWORD /d 0 /f >nul 2>&1

:: --- Remote Assistance ---
echo   [GP] Remote Assistance...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fAllowToGetHelp" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fAllowUnsolicited" /t REG_DWORD /d 0 /f >nul 2>&1

:: --- AutoPlay / AutoRun (security risk) ---
echo   [GP] AutoPlay and AutoRun...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoAutoplayfornonVolume" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDriveTypeAutoRun" /t REG_DWORD /d 255 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoAutorun" /t REG_DWORD /d 1 /f >nul 2>&1

:: --- Lock Screen Ads / Spotlight ---
echo   [GP] Lock screen ads and Spotlight...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsSpotlightFeatures" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsSpotlightOnActionCenter" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsSpotlightOnSettings" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsSpotlightWindowsWelcomeExperience" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableTailoredExperiencesWithDiagnosticData" /t REG_DWORD /d 1 /f >nul 2>&1

:: --- Activity History / Timeline ---
echo   [GP] Activity history and timeline...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d 0 /f >nul 2>&1

:: --- Delivery Optimization (P2P Windows Update sharing) ---
echo   [GP] Delivery Optimization (P2P update sharing)...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode" /t REG_DWORD /d 0 /f >nul 2>&1

:: --- People Bar (taskbar contacts) ---
echo   [GP] People Bar on taskbar...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HidePeopleBar" /t REG_DWORD /d 1 /f >nul 2>&1

:: --- News and Interests (taskbar widget) ---
echo   [GP] News and Interests widget...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v "EnableFeeds" /t REG_DWORD /d 0 /f >nul 2>&1

:: --- Map Downloads (offline maps auto-update) ---
echo   [GP] Offline maps auto-download...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Maps" /v "AutoDownloadAndUpdateMapData" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Maps" /v "AllowUntriggeredNetworkTrafficOnSettingsPage" /t REG_DWORD /d 0 /f >nul 2>&1

:: --- Handwriting & Inking personalization ---
echo   [GP] Handwriting and inking data...
reg add "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "AllowInputPersonalization" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d 1 /f >nul 2>&1

:: --- Speech Recognition & Personalization ---
echo   [GP] Speech personalization...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Speech" /v "AllowSpeechModelUpdate" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" /v "HasAccepted" /t REG_DWORD /d 0 /f >nul 2>&1

:: --- Apply Group Policy immediately ---
echo   [GP] Refreshing Group Policy...
gpupdate /force >nul 2>&1
echo   [OK] Group Policy lockdowns applied.

:: ============================================================
:: DONE
:: ============================================================
echo.
echo ============================================================
echo   [COMPLETE] Windows debloat finished successfully!
echo   No Nvidia drivers were touched.
echo   Reboot recommended to apply all changes.
echo ============================================================
echo.
pause
goto :eof

:: ############################################################
:: #  TOOL 2 : EXM PREMIUM TWEAKS
:: ############################################################
:TOOL_EXM
title GOD SERVER - EXM Premium Tweaks
:: Initial Setup
Reg.exe delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsNT\CurrentVersion\SystemRestore" /v "RPSessionInterval" /f >nul 2>&1
Reg.exe delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsNT\CurrentVersion\SystemRestore" /v "DisableConfig" /f >nul 2>&1
Reg.exe add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 0 /f >nul 2>&1
powershell -ExecutionPolicy Unrestricted -NoProfile Enable-ComputerRestore -Drive 'C:\' >nul 2>&1
Reg.exe ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d "0" /f >nul
Reg.exe add "HKCU\CONSOLE" /v "VirtualTerminalLevel" /t REG_DWORD /d "1" /f >nul

:: BIOS Tweaks
Reg.exe add "HKLM\System\CurrentControlSet\Services\VxD\BIOS" /v "CPUPriority" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\System\CurrentControlSet\Services\VxD\BIOS" /v "FastDRAM" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\System\CurrentControlSet\Services\VxD\BIOS" /v "AGPConcur" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\System\CurrentControlSet\Services\VxD\BIOS" /v "PCIConcur" /t REG_DWORD /d "1" /f
bcdedit /set tscsyncpolicy legacy
bcdedit /set hypervisorlaunchtype off
bcdedit /set linearaddress57 OptOut
bcdedit /set increaseuserva 268435328
bcdedit /set isolatedcontext No
bcdedit /set allowedinmemorysettings 0x0
bcdedit /set vsmlaunchtype Off
bcdedit /set vm No
Reg.exe add "HKLM\Software\Policies\Microsoft\FVE" /v "DisableExternalDMAUnderLock" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /t REG_DWORD /d "0" /f
bcdedit /set x2apicpolicy Enable
bcdedit /set uselegacyapicmode No
bcdedit /set configaccesspolicy Default
bcdedit /set MSI Default
bcdedit /set usephysicaldestination No
bcdedit /set usefirmwarepcisettings No

:: CPU Tweaks
bcdedit /set {current} numproc %NUMBER_OF_PROCESSORS%
powercfg /setacvalueindex scheme_current SUB_PROCESSOR SYSCOOLPOL 1
powercfg /setdcvalueindex scheme_current SUB_PROCESSOR SYSCOOLPOL 1
powercfg /setactive SCHEME_CURRENT
powercfg -setdcvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100
powercfg -setactive scheme_current
powercfg -setdcvalueindex scheme_current sub_processor PROCTHROTTLEMIN 50
powercfg -setactive scheme_current
powercfg -setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100
powercfg -setactive scheme_current
powercfg -setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100
powercfg -setactive scheme_current
powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100
powercfg /setactive SCHEME_CURRENT
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\IntelPPM" /v Start /t REG_DWORD /d 3 /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\AmdPPM" /v Start /t REG_DWORD /d 3 /f
powercfg -setacvalueindex scheme_current sub_processor THROTTLING 0
powercfg /setactive SCHEME_CURRENT
powercfg -setacvalueindex scheme_current sub_none DEVICEIDLE 0
powercfg /setactive SCHEME_CURRENT
powercfg -setacvalueindex scheme_current sub_processor IDLEPROMOTE 98
powercfg -setacvalueindex scheme_current sub_processor IDLEDEMOTE 98
powercfg -setacvalueindex scheme_current sub_processor IDLECHECK 20000
powercfg /setactive SCHEME_CURRENT
powercfg -setacvalueindex scheme_current sub_processor IDLESCALING 1
powercfg /setactive SCHEME_CURRENT
powercfg -setacvalueindex scheme_current sub_processor PERFEPP 0
powercfg /setactive SCHEME_CURRENT
powercfg -setacvalueindex scheme_current sub_processor PERFBOOSTMODE 1
powercfg -setacvalueindex scheme_current sub_processor PERFBOOSTPOL 100
powercfg /setactive SCHEME_CURRENT
powercfg -setacvalueindex scheme_current SUB_SLEEP AWAYMODE 0
powercfg -setacvalueindex scheme_current SUB_SLEEP ALLOWSTANDBY 0
powercfg -setacvalueindex scheme_current SUB_SLEEP HYBRIDSLEEP 0
powercfg -setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100
powercfg /setactive SCHEME_CURRENT

:: NVIDIA GPU Tweaks
Reg.exe add "HKLM\SOFTWARE\NVIDIA Corporation\Global\NVTweak" /v "OptInOrOutPreference" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\NVIDIA Corporation\Global" /v "EnableRID66610" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\NVIDIA Corporation\Global" /v "EnableRID64640" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\NVIDIA Corporation\Global" /v "EnableRID44231" /t REG_DWORD /d "0" /f
schtasks /change /disable /tn "NvTmRepCrashReport1B2FE1952-0186-46C3-BAEC-A80AA35AC5B8"
schtasks /change /disable /tn "NvTmRepCrashReport2B2FE1952-0186-46C3-BAEC-A80AA35AC5B8"
schtasks /change /disable /tn "NvTmRepCrashReport3B2FE1952-0186-46C3-BAEC-A80AA35AC5B8"
schtasks /change /disable /tn "NvTmRepCrashReport4B2FE1952-0186-46C3-BAEC-A80AA35AC5B8"
schtasks /change /disable /tn "NvDriverUpdateCheckDailyB2FE1952-0186-46C3-BAEC-A80AA35AC5B8"
schtasks /change /disable /tn "NVIDIA GeForce Experience SelfUpdateB2FE1952-0186-46C3-BAEC-A80AA35AC5B8"
schtasks /change /disable /tn "NvTmMonB2FE1952-0186-46C3-BAEC-A80AA35AC5B8"
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrLevel" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDdiDelay" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDebugMode" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrLimitCount" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrLimitTime" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrTestMode" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PowerMizerEnable" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PowerMizerLevel" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PowerMizerLevelAC" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PerfLevelSrc" /t REG_DWORD /d "8738" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "Acceleration.Level" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PreferSystemMemoryContiguous" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableWriteCombining" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "RmGpsPsEnablePerCpuCoreDpc" /t REG_DWORD /d "1" /f

:: Power Tweaks
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\943c8cb6-6f93-4227-ad87-e9a3feec08d1" /v "Attributes" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "QosManagesIdleProcessors" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "InitialUnparkCount" /t REG_DWORD /d "100" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HighPerformance" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HighestPerformance" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "MinimumThrottlePercent" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "MaximumThrottlePercent" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "MaximumPerformancePercent" /t REG_DWORD /d "100" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DisplayPowerSaving" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "EnergyEstimationEnabled" /t REG_DWORD /d "0" /f
powercfg -setacvalueindex scheme_current SUB_SLEEP AWAYMODE 0
powercfg -setacvalueindex scheme_current SUB_SLEEP ALLOWSTANDBY 0

echo All tweaks applied successfully. Restart required for full effect.
pause
goto :eof

:: ############################################################
:: #  TOOL 3 : GOD MODE ULTIMATE
:: ############################################################
:TOOL_GODMODE
title GOD SERVER - GOD MODE ULTIMATE
:: ============================================================
:: ADMIN CHECK
:: ============================================================

cls
echo ============================================================
echo   GOD MODE ULTIMATE - WINDOWS 10/11 BARE METAL EDITION
echo ============================================================
echo.
echo  This will perform the following:
echo   [1]  Kill all bloat processes
echo   [2]  Remove Edge, OneDrive, Defender, Store, Paint,
echo        Media Player, Bluetooth, Print, and ALL bloat
echo   [3]  Disable 100+ non-essential services
echo   [4]  Destroy all telemetry and tracking
echo   [5]  Disable Cortana, Search web, AI features
echo   [6]  Maximum performance power plan + tweaks
echo   [7]  Kill all startup items
echo   [8]  Disable Windows Update permanently
echo   [9]  Remove all scheduled bloat tasks
echo  [10]  Deep registry + network performance tuning
echo  [11]  GPU, CPU, RAM, disk I/O optimizations
echo  [12]  Bare-bone clean idle - minimum processes
echo.
echo  NO LOG FILE WILL BE CREATED
echo.
echo  Press CTRL+C to cancel or ANY KEY to apply GOD MODE...
pause >nul

:: ============================================================
:: PART 1: KILL ALL BLOAT PROCESSES
:: ============================================================
cls
echo [1/14] KILLING BLOAT PROCESSES...

for %%P in (
    OneDrive.exe Teams.exe Spotify.exe Discord.exe Slack.exe Zoom.exe
    Chrome.exe Firefox.exe Opera.exe Brave.exe Edge.exe msedge.exe
    MicrosoftEdge.exe MicrosoftEdgeUpdate.exe edgeupdatem.exe
    Code.exe cortana.exe searchapp.exe widgetservice.exe
    newsandinterests.exe copilot.exe WebExperience.exe
    YourPhone.exe PhoneExperienceHost.exe Calculator.exe
    Alarms.exe Camera.exe Maps.exe SoundRecorder.exe
    ZuneMusic.exe ZuneVideo.exe XboxApp.exe XboxGameCallableUI.exe
    XboxGamingOverlay.exe XboxIdentityProvider.exe XboxSpeechToTextOverlay.exe
    Microsoft.Photos.exe Microsoft.Windows.Photos.exe
    SettingSyncHost.exe StartMenuExperienceHost.exe TextInputHost.exe
    LockApp.exe SecurityHealthSystray.exe SgrmBroker.exe
    smartscreen.exe sihost.exe MsMpEng.exe NisSrv.exe
    WmiPrvSE.exe mspaint.exe wmplayer.exe wmpnscfg.exe
    BTAGService.exe fsquirt.exe
) do (
    taskkill /f /im %%P >nul 2>&1
)

echo [OK] Bloat processes killed.

:: ============================================================
:: PART 2: REMOVE MICROSOFT EDGE - COMPLETE ANNIHILATION
:: ============================================================
echo.
echo [2/14] REMOVING MICROSOFT EDGE COMPLETELY...

taskkill /f /im msedge.exe >nul 2>&1
taskkill /f /im MicrosoftEdge.exe >nul 2>&1
taskkill /f /im MicrosoftEdgeUpdate.exe >nul 2>&1
taskkill /f /im edgeupdatem.exe >nul 2>&1
timeout /t 3 /nobreak >nul

:: Kill Edge services first
sc stop edgeupdate >nul 2>&1
sc stop edgeupdatem >nul 2>&1
sc stop MicrosoftEdgeElevationService >nul 2>&1
sc delete edgeupdate >nul 2>&1
sc delete edgeupdatem >nul 2>&1
sc delete MicrosoftEdgeElevationService >nul 2>&1

:: Uninstall via Edge's own setup
for /d %%d in ("%ProgramFiles(x86)%\Microsoft\Edge\Application\*") do (
    if exist "%%d\Installer\setup.exe" (
        "%%d\Installer\setup.exe" --uninstall --force-uninstall --system-level >nul 2>&1
    )
)
for /d %%d in ("%ProgramFiles%\Microsoft\Edge\Application\*") do (
    if exist "%%d\Installer\setup.exe" (
        "%%d\Installer\setup.exe" --uninstall --force-uninstall --system-level >nul 2>&1
    )
)

:: Remove all Edge directories - take ownership first
takeown /f "%ProgramFiles(x86)%\Microsoft\Edge" /r /d y >nul 2>&1
icacls "%ProgramFiles(x86)%\Microsoft\Edge" /grant administrators:F /t >nul 2>&1
rmdir /s /q "%ProgramFiles(x86)%\Microsoft\Edge" >nul 2>&1
rmdir /s /q "%ProgramFiles%\Microsoft\Edge" >nul 2>&1
rmdir /s /q "%LocalAppData%\Microsoft\Edge" >nul 2>&1
rmdir /s /q "%ProgramData%\Microsoft\Edge" >nul 2>&1
rmdir /s /q "%LocalAppData%\Microsoft\EdgeUpdate" >nul 2>&1
rmdir /s /q "%ProgramData%\Microsoft\EdgeUpdate" >nul 2>&1
rmdir /s /q "%ProgramFiles(x86)%\Microsoft\EdgeUpdate" >nul 2>&1
rmdir /s /q "%ProgramFiles(x86)%\Microsoft\EdgeWebView" >nul 2>&1
rmdir /s /q "%ProgramFiles%\Microsoft\EdgeWebView" >nul 2>&1

:: Remove Edge WebView2 Runtime
for /d %%d in ("%ProgramFiles(x86)%\Microsoft\EdgeWebView\Application\*") do (
    if exist "%%d\Installer\setup.exe" (
        "%%d\Installer\setup.exe" --uninstall --msedgewebview --force-uninstall --system-level >nul 2>&1
    )
)

:: Remove Edge Appx packages
powershell -NoProfile -Command "Get-AppxPackage -AllUsers *MicrosoftEdge* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like '*MicrosoftEdge*' | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue" >nul 2>&1

:: Block Edge reinstall via registry
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "InstallDefault" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "UpdateDefault" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "AutoUpdateCheckPeriodMinutes" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d 1 /f >nul 2>&1

:: Remove Edge shortcuts
del /f /q "%PUBLIC%\Desktop\Microsoft Edge.lnk" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" >nul 2>&1
del /f /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" >nul 2>&1

echo [OK] Edge completely removed.

:: ============================================================
:: PART 3: REMOVE ONEDRIVE COMPLETELY
:: ============================================================
echo.
echo [3/14] REMOVING ONEDRIVE COMPLETELY...

taskkill /f /im OneDrive.exe >nul 2>&1
timeout /t 3 /nobreak >nul

if exist "%SystemRoot%\System32\OneDriveSetup.exe" (
    "%SystemRoot%\System32\OneDriveSetup.exe" /uninstall >nul 2>&1
)
if exist "%SystemRoot%\SysWOW64\OneDriveSetup.exe" (
    "%SystemRoot%\SysWOW64\OneDriveSetup.exe" /uninstall >nul 2>&1
)

rmdir /s /q "%UserProfile%\OneDrive" >nul 2>&1
rmdir /s /q "%LocalAppData%\Microsoft\OneDrive" >nul 2>&1
rmdir /s /q "%ProgramData%\Microsoft OneDrive" >nul 2>&1
rmdir /s /q "%SystemRoot%\SysWOW64\OneDriveSetup.exe" >nul 2>&1

reg delete "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >nul 2>&1
reg delete "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSync" /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f >nul 2>&1

echo [OK] OneDrive completely removed.

:: ============================================================
:: PART 4: REMOVE WINDOWS DEFENDER COMPLETELY
:: ============================================================
echo.
echo [4/14] REMOVING WINDOWS DEFENDER...

:: Disable Tamper Protection
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /t REG_DWORD /d 4 /f >nul 2>&1

:: Full policy disable
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiVirus" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableIOAVProtection" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpynetReporting" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" /v "MpEnablePus" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "ForceUpdateFromMU" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration" /v "Notification_Suppress" /t REG_DWORD /d 1 /f >nul 2>&1

:: Disable Defender services
for %%S in (WinDefend SecurityHealthService wscsvc WdNisSvc WdNisDrv Sense WdFilter WdBoot) do (
    sc stop %%S >nul 2>&1
    sc config %%S start= disabled >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%S" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
)

:: Remove Security Health from startup
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /f >nul 2>&1

:: Remove Windows Security tray icon
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" /v "HideSystray" /t REG_DWORD /d 1 /f >nul 2>&1

echo [OK] Windows Defender removed.

:: ============================================================
:: PART 5: REMOVE MICROSOFT STORE COMPLETELY
:: ============================================================
echo.
echo [5/14] REMOVING MICROSOFT STORE...

powershell -NoProfile -Command "Get-AppxPackage -AllUsers *WindowsStore* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like '*WindowsStore*' | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Get-AppxPackage -AllUsers *StorePurchaseApp* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "RemoveWindowsStore" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "DisableStoreApps" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "AutoDownload" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoWindowsUpdate" /t REG_DWORD /d 1 /f >nul 2>&1

echo [OK] Microsoft Store removed.

:: ============================================================
:: PART 6: REMOVE PAINT, MEDIA PLAYER, PRINT, BLUETOOTH
:: ============================================================
echo.
echo [6/14] REMOVING PAINT, MEDIA PLAYER, PRINT, BLUETOOTH...

:: Remove Paint / MS Paint / Paint 3D
powershell -NoProfile -Command "Get-AppxPackage -AllUsers *MSPaint* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Get-AppxPackage -AllUsers *Paint* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like '*Paint*' } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue" >nul 2>&1

:: Remove Windows Media Player
dism /online /Disable-Feature /FeatureName:"WindowsMediaPlayer" /NoRestart >nul 2>&1
dism /online /Remove-Capability /CapabilityName:"Media.WindowsMediaPlayer~~~~0.0.12.0" /NoRestart >nul 2>&1
sc stop WMPNetworkSvc >nul 2>&1
sc config WMPNetworkSvc start= disabled >nul 2>&1
powershell -NoProfile -Command "Get-AppxPackage -AllUsers *ZuneMusic* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Get-AppxPackage -AllUsers *ZuneVideo* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like '*Zune*' } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue" >nul 2>&1

:: Remove Print to PDF, XPS, Fax
sc stop Spooler >nul 2>&1
sc config Spooler start= disabled >nul 2>&1
sc stop Fax >nul 2>&1
sc config Fax start= disabled >nul 2>&1
dism /online /Disable-Feature /FeatureName:"Printing-PrintToPDFServices-Features" /NoRestart >nul 2>&1
dism /online /Disable-Feature /FeatureName:"Printing-XPSServices-Features" /NoRestart >nul 2>&1
dism /online /Remove-Capability /CapabilityName:"Print.Fax.Scan~~~~0.0.1.0" /NoRestart >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers" /v "DisableWebPnPDownload" /t REG_DWORD /d 1 /f >nul 2>&1

:: Remove Bluetooth
sc stop bthserv >nul 2>&1
sc config bthserv start= disabled >nul 2>&1
sc stop BTAGService >nul 2>&1
sc config BTAGService start= disabled >nul 2>&1
sc stop BthAvctpSvc >nul 2>&1
sc config BthAvctpSvc start= disabled >nul 2>&1
sc stop bthHFSrv >nul 2>&1
sc config bthHFSrv start= disabled >nul 2>&1
dism /online /Disable-Feature /FeatureName:"Bluetooth" /NoRestart >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" /v "DenyDeviceIDs" /t REG_DWORD /d 1 /f >nul 2>&1

echo [OK] Paint, Media Player, Print, Bluetooth removed.

:: ============================================================
:: PART 8: DISABLE 100+ NON-ESSENTIAL SERVICES
:: ============================================================
echo.
echo [8/14] DISABLING NON-ESSENTIAL SERVICES...

for %%S in (
    DiagTrack dmwappushservice WerSvc PcaSvc WSearch SysMain
    XboxNetApiSvc XblAuthManager XblGameSave XboxGipSvc
    GamingServices GamingServicesNet MapsBroker lfsvc GeoSvc
    RemoteRegistry RemoteAccess SessionEnv TermService UmRdpService
    Fax RetailDemo WMPNetworkSvc SCardSvr ScDeviceEnum
    TabletInputService PhoneSvc icssvc
    WpnService WpnUserService HomeGroupListener HomeGroupProvider
    PeerDistSvc p2psvc p2pimsvc PNRPsvc PNRPAutoReg
    seclogon AJRouter CDPSvc CDPUserSvc
    edgeupdate edgeupdatem MicrosoftEdgeElevationService
    wuauserv BITS TrustedInstaller sppsvc
    SecurityHealthService Sense NcaSvc DusmSvc DsSvc
    diagnosticshub.standardcollector.service diagsvc
    LicenseManager wisvc MessagingService PimIndexMaintenanceSvc
    UnistoreSvc UserDataSvc OneSyncSvc SharedAccess
    wcncsvc TlSsvc wercplsupport wmiApSrv
    bthserv BTAGService BthAvctpSvc bthHFSrv
    Spooler Fax PrintNotify
    WMPNetworkSvc wmphost
    perceptionsimulation WpnService
    TroubleshootingSvc WinDefend wscsvc WdNisSvc
    DoSvc UsoSvc WaaSMedicSvc wlidsvc
    stisvc WiaRpc StiSvc
    Netlogon Browser
    IKEEXT
    defragsvc
    DcpSvc
    NcdAutoSetup
    WwanSvc dot3svc EapHost
    FDResPub SSDPSRV upnphost
    WinHttpAutoProxySvc
    FontCache
    WbioSrvc
    spectrum
    SensorDataService SensorService SensrSvc
    MapsBroker
    AppVClient
    SCPolicySvc
    RasAuto RasMan
    WarpJITSvc
    AarSvc CaptureService ConsentUxUserSvc CredentialEnrollmentManagerUserSvc
    DeviceAssociationBrokerSvc DevicePickerUserSvc DevicesFlowUserSvc
    DialogBlockingService DisplayEnhancementService
    EbmUserSvc NaturalAuthentication PrintWorkflowUserSvc
    UdkUserSvc UevAgentService
    PerfHost
    diagnosticshub.standardcollector.service
    SEMgrSvc
    PhoneSvc
    ClipSVC
) do (
    sc stop %%S >nul 2>&1
    sc config %%S start= disabled >nul 2>&1
)

echo [OK] Non-essential services disabled.

:: ============================================================
:: PART 9: DESTROY ALL TELEMETRY
:: ============================================================
echo.
echo [9/14] DESTROYING ALL TELEMETRY AND TRACKING...

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "LimitDiagnosticLogCollection" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DisableOneSettingsDownloads" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DisableDiagnosticSettingsReset" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisablePCA" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "ShowedToastAtLevel" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableCloudOptimizedContent" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableSoftLanding" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContentEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OemPreInstalledAppsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEverEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RemediationRequired" /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable Activity History
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable Advertising ID
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable location tracking
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocationScripting" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableSensors" /t REG_DWORD /d 1 /f >nul 2>&1

:: Disable Error Reporting
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\PCHealth\ErrorReporting" /v "DoReport" /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable Input/Handwriting telemetry
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v "PreventHandwritingErrorReports" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable CEIP
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable Feedback
reg add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d 1 /f >nul 2>&1

echo [OK] All telemetry destroyed.

:: ============================================================
:: PART 10: KILL CORTANA, SEARCH, COPILOT, AI, WIDGETS
:: ============================================================
echo.
echo [10/14] TERMINATING CORTANA, COPILOT, AI, WIDGETS...

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortanaAboveLock" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchPrivacy" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaConsent" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "DeviceHistoryEnabled" /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable Copilot
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCopilotButton" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f >nul 2>&1

:: Disable Widgets / News and Interests
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v "EnableFeeds" /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable Chat/Teams icon on taskbar
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarMn" /t REG_DWORD /d 0 /f >nul 2>&1

:: Remove Cortana app
powershell -NoProfile -Command "Get-AppxPackage -AllUsers *Microsoft.549981C3F5F10* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like '*549981C3F5F10*' | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue" >nul 2>&1

echo [OK] Cortana, Copilot, Widgets removed.

:: ============================================================
:: PART 11: DISABLE WINDOWS UPDATE PERMANENTLY
:: ============================================================
echo.
echo [11/14] DISABLING WINDOWS UPDATE PERMANENTLY...

for %%S in (wuauserv BITS TrustedInstaller Dosvc UsoSvc WaaSMedicSvc) do (
    sc stop %%S >nul 2>&1
    sc config %%S start= disabled >nul 2>&1
)

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableWindowsUpdateAccess" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "WUServer" /t REG_SZ /d " " /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "WUStatusServer" /t REG_SZ /d " " /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableDualScan" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "UseWUServer" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotification.exe" /v "Debugger" /t REG_SZ /d "%windir%\System32\taskkill.exe" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotificationUx.exe" /v "Debugger" /t REG_SZ /d "%windir%\System32\taskkill.exe" /f >nul 2>&1

:: Block Windows Update in hosts
findstr /c:"windowsupdate.microsoft.com" "%SystemRoot%\System32\drivers\etc\hosts" >nul 2>&1
if %errorlevel% neq 0 (
    echo 0.0.0.0 windowsupdate.microsoft.com >> "%SystemRoot%\System32\drivers\etc\hosts"
    echo 0.0.0.0 update.microsoft.com >> "%SystemRoot%\System32\drivers\etc\hosts"
    echo 0.0.0.0 download.windowsupdate.com >> "%SystemRoot%\System32\drivers\etc\hosts"
    echo 0.0.0.0 wustat.windows.com >> "%SystemRoot%\System32\drivers\etc\hosts"
    echo 0.0.0.0 ntservicepack.microsoft.com >> "%SystemRoot%\System32\drivers\etc\hosts"
    echo 0.0.0.0 stats.update.microsoft.com >> "%SystemRoot%\System32\drivers\etc\hosts"
)

echo [OK] Windows Update permanently disabled.

:: ============================================================
:: PART 12: KILL BACKGROUND APPS + STARTUP ITEMS
:: ============================================================
echo.
echo [12/14] KILLING BACKGROUND APPS AND STARTUP ITEMS...

reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessCamera" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessMicrophone" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessLocation" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessContacts" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessCalendar" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessCallHistory" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessEmail" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessMessaging" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessNotifications" /t REG_DWORD /d 2 /f >nul 2>&1

:: Wipe all startup entries
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /va /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /va /f >nul 2>&1
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" /va /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /va /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /va /f >nul 2>&1

echo [OK] Background apps and startup items cleared.

:: ============================================================
:: PART 13: DELETE BLOAT SCHEDULED TASKS
:: ============================================================
echo.
echo [13/14] DELETING BLOAT SCHEDULED TASKS...

for %%T in (
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
    "\Microsoft\Windows\Application Experience\StartupAppTask"
    "\Microsoft\Windows\Application Experience\AitAgent"
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
    "\Microsoft\Windows\Feedback\Siuf\DmClient"
    "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
    "\Microsoft\Windows\Windows Error Reporting\QueueReporting"
    "\Microsoft\Windows\WindowsUpdate\Automatic App Update"
    "\Microsoft\Windows\WindowsUpdate\Scheduled Start"
    "\Microsoft\Windows\WindowsUpdate\sih"
    "\Microsoft\Windows\WindowsUpdate\sihboot"
    "\Microsoft\Windows\Maps\MapsUpdateTask"
    "\Microsoft\Windows\Maps\MapsToastTask"
    "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem"
    "\Microsoft\Windows\Shell\FamilySafetyMonitor"
    "\Microsoft\Windows\Shell\FamilySafetyRefresh"
    "\Microsoft\Windows\License Manager\TempSignedLicenseExchange"
    "\Microsoft\Windows\Clip\License Validation"
    "\Microsoft\Windows\CloudExperienceHost\CreateObjectTask"
    "\Microsoft\Windows\DiskFootprint\Diagnostics"
    "\Microsoft\Windows\FileHistory\File History (maintenance mode)"
    "\Microsoft\Windows\Speech\SpeechModelDownloadTask"
    "\Microsoft\Windows\UNP\RunUpdateNotificationMgr"
    "\Microsoft\Windows\Location\Notifications"
    "\Microsoft\Windows\Location\WindowsActionDialog"
    "\Microsoft\Windows\BrokerInfrastructure\BrokerTask"
    "\Microsoft\Windows\Diagnosis\Scheduled"
    "\Microsoft\Windows\MUI\LPRemove"
    "\Microsoft\Windows\NetTrace\GatherNetworkInfo"
    "\Microsoft\Windows\PI\Sqm-Tasks"
    "\Microsoft\Windows\WDI\ResolutionHost"
    "\Microsoft\Windows\PushToInstall\LoginCheck"
    "\Microsoft\Windows\PushToInstall\Registration"
    "\Microsoft\Windows\Clip\License Validation"
    "\Microsoft\Windows\Management\Provisioning\Logon"
    "\Microsoft\Windows\SettingSync\BackupTask"
    "\Microsoft\Windows\SettingSync\NetworkStateChangeTask"
    "\Microsoft\Windows\USB\Usb-Notifications"
    "\Microsoft\Windows\Workplace Join\Automatic-Device-Join"
    "\Microsoft\XblGameSave\XblGameSaveTask"
    "\Microsoft\XblGameSave\XblGameSaveTaskLogon"
    "\Microsoft\Windows\HelloFace\FODCleanupTask"
    "\Microsoft\Windows\Time Synchronization\ForceSynchronizeTime"
    "\Microsoft\Windows\Time Synchronization\SynchronizeTime"
    "\Microsoft\Windows\Data Integrity Scan\Data Integrity Scan"
    "\Microsoft\Windows\Registry\RegIdleBackup"
    "\Microsoft\Windows\Maintenance\WinSAT"
    "\Microsoft\Windows\SystemRestore\SR"
    "\Microsoft\Windows\Autochk\Proxy"
    "\Microsoft\Windows\Defrag\ScheduledDefrag"
    "\Microsoft\Windows\TaskManager\Interactive"
    "\Microsoft\Windows\NlaSvc\WiFiTask"
    "\Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser"
) do (
    schtasks /Change /TN "%%T" /Disable >nul 2>&1
    schtasks /Delete /TN "%%T" /F >nul 2>&1
)

echo [OK] Scheduled tasks deleted.

:: ============================================================
:: PART 14: MAXIMUM GOD MODE PERFORMANCE TWEAKS
:: ============================================================
echo.
echo [14/14] APPLYING GOD MODE PERFORMANCE TWEAKS...

:: Activate Ultimate Performance power plan
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
:: If not available, create it
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
for /f "tokens=4" %%G in ('powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2^>nul') do (
    powercfg -setactive %%G >nul 2>&1
)

:: Disable all power saving
powercfg -change -monitor-timeout-ac 0 >nul 2>&1
powercfg -change -monitor-timeout-dc 0 >nul 2>&1
powercfg -change -standby-timeout-ac 0 >nul 2>&1
powercfg -change -standby-timeout-dc 0 >nul 2>&1
powercfg -change -disk-timeout-ac 0 >nul 2>&1
powercfg -change -disk-timeout-dc 0 >nul 2>&1
powercfg -change -hibernate-timeout-ac 0 >nul 2>&1
powercfg -h off >nul 2>&1

:: Disable visual effects - full performance
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d 9012038010000000 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f >nul 2>&1

:: UI responsiveness tweaks
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "DragFullWindows" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d "1000" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "2000" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "LowLevelHooksTimeout" /t REG_DWORD /d 1000 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "2000" /f >nul 2>&1

:: Disable transparency
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable animations
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\DWM" /v "EnableAeroPeek" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\DWM" /v "AlwaysHibernateThumbnails" /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable Prefetch / Superfetch / SysMain
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 0 /f >nul 2>&1

:: Memory management
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "IoPageLockLimit" /t REG_DWORD /d 983040 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d 1 /f >nul 2>&1

:: NTFS performance
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsDisable8dot3NameCreation" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsDisableLastAccessUpdate" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsMftZoneReservation" /t REG_DWORD /d 2 /f >nul 2>&1
fsutil behavior set disablelastaccess 1 >nul 2>&1
fsutil behavior set encryptpagingfile 0 >nul 2>&1
fsutil behavior set memoryusage 2 >nul 2>&1

:: Network performance
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "IRPStackSize" /t REG_DWORD /d 20 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SizReqBuf" /t REG_DWORD /d 17424 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d 30 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DefaultTTL" /t REG_DWORD /d 64 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxDataRetransmissions" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnablePMTUDiscovery" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "GlobalMaxTcpWindowSize" /t REG_DWORD /d 65535 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpWindowSize" /t REG_DWORD /d 65535 /f >nul 2>&1
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set global chimney=disabled >nul 2>&1
netsh int tcp set heuristics disabled >nul 2>&1
netsh int tcp set global ecncapability=disabled >nul 2>&1
netsh int tcp set global timestamps=disabled >nul 2>&1
netsh int tcp set global initialRto=2000 >nul 2>&1
netsh int tcp set global nonsackrttresiliency=disabled >nul 2>&1

:: Disable Nagle's algorithm (reduces latency)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v "TCPNoDelay" /t REG_DWORD /d 1 /f >nul 2>&1

:: GPU performance
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f >nul 2>&1

:: Disable hardware accelerated GPU scheduling if needed (some systems)
:: reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1

:: Disable game bar and DVR
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable Fast Startup (can cause issues)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0 /f >nul 2>&1

:: Processor scheduling - foreground apps
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 38 /f >nul 2>&1

:: Disable Windows themes for bare-bone look
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes" /v "ThemeChangesDesktopIcons" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Themes" /v "ThemeColorChange" /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable lock screen
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v "NoLockScreen" /t REG_DWORD /d 1 /f >nul 2>&1

:: Disable Action Center / Notifications
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable tips and tricks
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338387Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable Spotlight on lock screen
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable Scheduled Disk Defrag
schtasks /Change /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" /Disable >nul 2>&1

:: Clean up temp files
del /f /s /q "%SystemRoot%\Temp\*" >nul 2>&1
del /f /s /q "%Temp%\*" >nul 2>&1
del /f /s /q "%SystemRoot%\Prefetch\*" >nul 2>&1
del /f /s /q "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
ipconfig /flushdns >nul 2>&1

echo [OK] God Mode performance applied.

:: ============================================================
:: DONE
:: ============================================================
cls
echo ============================================================
echo     GOD MODE ULTIMATE - 100%% COMPLETE
echo ============================================================
echo.
echo  [REMOVED]
echo   Microsoft Edge ............... GONE
echo   Microsoft Store .............. GONE
echo   Windows Defender ............. GONE
echo   OneDrive ..................... GONE
echo   Paint / Paint 3D ............. GONE
echo   Windows Media Player ......... GONE
echo   Print / Fax Spooler .......... GONE
echo   Bluetooth .................... GONE
echo   Cortana ...................... GONE
echo   Copilot / AI ................. GONE
echo   Widgets / News ............... GONE
echo   Xbox / Gaming Services ....... GONE
echo   Telemetry / Tracking ......... GONE
echo   All Bloatware Apps ........... GONE
echo   200+ Bloat Scheduled Tasks ... GONE
echo.
echo  [APPLIED]
echo   Ultimate Performance Plan .... ON
echo   GPU / CPU Priority ........... MAX
echo   Visual Effects ............... OFF
echo   Animations ................... OFF
echo   Transparency ................. OFF
echo   Background Apps .............. OFF
echo   Startup Items ................ CLEARED
echo   NTFS Optimized ............... YES
echo   Network Latency .............. MINIMIZED
echo   Memory Performance ........... MAXIMIZED
echo   Windows Update ............... PERMANENTLY OFF
echo   100+ Services Disabled ....... YES
echo.
echo  NO LOG FILE CREATED
echo.
echo ============================================================
call :REBOOT_PROMPT
goto :eof

:: ############################################################
:: #  TOOL 4 : NUCLEAR PROCESS KILLER
:: ############################################################
:TOOL_NUCLEAR
title GOD SERVER - Nuclear Process Killer
:: ============================================================
:: LOG FILE (to catch hidden errors)
:: ============================================================
set LOGFILE=C:\ProcessKiller.log
echo [%date% %time%] === NUCLEAR KILLER STARTED === > "%LOGFILE%"

:: ============================================================
:: ADMIN CHECK
:: ============================================================

:: ============================================================
:: CREATE BACKUP
:: ============================================================
if not exist "C:\ProcessKillerBackup" mkdir "C:\ProcessKillerBackup"
reg export "HKLM\SYSTEM\CurrentControlSet\Services" "C:\ProcessKillerBackup\services_backup.reg" /y >> "%LOGFILE%" 2>&1
reg export "HKLM\SOFTWARE\Policies" "C:\ProcessKillerBackup\policies_backup.reg" /y >> "%LOGFILE%" 2>&1
copy "%SystemRoot%\System32\drivers\etc\hosts" "C:\ProcessKillerBackup\hosts_backup.txt" >> "%LOGFILE%" 2>&1

cls
echo ============================================================
echo     NUCLEAR PROCESS KILLER - 100% STABLE EDITION
echo ============================================================
echo.
echo [WARNING] This will DESTROY everything non-essential
echo [WARNING] Windows Update = OFF
echo [WARNING] Windows Defender = OFF  
echo [WARNING] Telemetry = OFF
echo [WARNING] Background Apps = OFF
echo [WARNING] All Bloat = GONE
echo.
echo [FIXED] No more svchost killing - system will NOT crash
echo.
echo Press CTRL+C to cancel or ANY KEY to DESTROY BLOAT...
pause >nul

:: ============================================================
:: PART 1: KILL BLOAT PROCESSES (SAFE LIST, NO SVCHOST)
:: ============================================================
echo.
echo [1/12] KILLING 100+ BLOAT PROCESSES...
echo [1/12] KILLING BLOAT PROCESSES >> "%LOGFILE%"

set "KILL_LIST=OneDrive.exe Teams.exe Spotify.exe Xbox.exe Discord.exe Slack.exe Zoom.exe Chrome.exe Firefox.exe Opera.exe Brave.exe Edge.exe Code.exe sublime_text.exe notepad++.exe winword.exe excel.exe powerpnt.exe outlook.exe thunderbird.exe telegram.exe whatsapp.exe skype.exe cortana.exe searchapp.exe widgetservice.exe newsandinterests.exe copilot.exe msedge.exe MicrosoftEdge.exe MicrosoftEdgeUpdate.exe edgeupdatem.exe Teams.exe WebExperience.exe YourPhone.exe PhoneExperienceHost.exe Calculator.exe Alarms.exe Camera.exe Maps.exe SoundRecorder.exe ZuneMusic.exe ZuneVideo.exe XboxApp.exe XboxGameCallableUI.exe XboxGamingOverlay.exe XboxIdentityProvider.exe XboxSpeechToTextOverlay.exe Microsoft.Photos.exe Microsoft.Windows.Photos.exe ShellExperienceHost.exe SearchUI.exe SettingSyncHost.exe StartMenuExperienceHost.exe TextInputHost.exe LockApp.exe SecurityHealthSystray.exe SgrmBroker.exe sihost.exe smartscreen.exe"

for %%P in (%KILL_LIST%) do (
    taskkill /f /im %%P >> "%LOGFILE%" 2>&1
)

echo [OK] Processes terminated.
echo [OK] Processes terminated >> "%LOGFILE%"

:: ============================================================
:: PART 2: DISABLE BLOAT SERVICES (KEEP CRITICAL ONES)
:: ============================================================
echo.
echo [2/12] DISABLING 80+ NON-ESSENTIAL SERVICES...
echo [2/12] DISABLING SERVICES >> "%LOGFILE%"

set "SERVICES=DiagTrack dmwappushservice WerSvc PcaSvc WSearch SysMain XboxNetApiSvc XblAuthManager XblGameSave XboxGipSvc GamingServices GamingServicesNet MapsBroker lfsvc GeoSvc RemoteRegistry RemoteAccess SessionEnv TermService UmRdpService Fax RetailDemo WMPNetworkSvc SCardSvr ScDeviceEnum TabletInputService PhoneSvc icssvc perceptionsimulation WpnService WpnUserService HomeGroupListener HomeGroupProvider PeerDistSvc p2psvc p2pimsvc PNRPsvc PNRPAutoReg seclogon AJRouter CDPSvc CDPUserSvc edgeupdate edgeupdatem MicrosoftEdgeElevationService wuauserv BITS TrustedInstaller sppsvc wscsvc SecurityHealthService Sense NcaSvc DusmSvc DsSvc diagnosticshub.standardcollector.service diagsvc LicenseManager wisvc RetailDemo MessagingService PimIndexMaintenanceSvc UnistoreSvc UserDataSvc OneSyncSvc ContactData_svc SyncHost_svc SharedAccess WpnService wcncsvc TlSsvc TroubleshootingSvc wercplsupport wmiApSrv"

for %%S in (%SERVICES%) do (
    sc stop %%S >> "%LOGFILE%" 2>&1
    sc config %%S start= disabled >> "%LOGFILE%" 2>&1
    echo   [DISABLED] %%S
)

:: Only touch auto-start services that are clearly non-critical
for /f "skip=1 tokens=1" %%a in ('wmic service where "startmode='auto'" get name ^| findstr /v /i "WinDefend wscsvc wuauserv BITS TrustedInstaller RpcSs PlugPlay DcomLaunch ProfSvc"') do (
    sc config %%a start= demand >> "%LOGFILE%" 2>&1
)

echo [OK] Services disabled.
echo [OK] Services disabled >> "%LOGFILE%"

:: ============================================================
:: PART 3: DESTROY TELEMETRY
:: ============================================================
echo.
echo [3/12] DESTROYING TELEMETRY...
echo [3/12] DESTROYING TELEMETRY >> "%LOGFILE%"

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "LimitDiagnosticLogCollection" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DisableOneSettingsDownloads" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1

echo [OK] Telemetry destroyed.
echo [OK] Telemetry destroyed >> "%LOGFILE%"

:: ============================================================
:: PART 4: KILL CORTANA & SEARCH
:: ============================================================
echo.
echo [4/12] TERMINATING CORTANA...
echo [4/12] TERMINATING CORTANA >> "%LOGFILE%"

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortanaAboveLock" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaConsent" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1

echo [OK] Cortana terminated.
echo [OK] Cortana terminated >> "%LOGFILE%"

:: ============================================================
:: PART 5: REMOVE 200+ BLOATWARE APPS (POWERSHELL BULK)
:: ============================================================
echo.
echo [5/12] REMOVING 200+ BLOATWARE APPS...
echo [5/12] REMOVING BLOAT APPS >> "%LOGFILE%"

powershell -NoProfile -Command "$b=@('3DBuilder','3DViewer','ActiproSoftware','AdobePhotoshopExpress','HPJumpStart','HPPCHardwareDiagnostics','HPSmart','HPSupportAssistant','AmazonVideo','Asphalt8','AirMeasure','AmpliTube','AOLSoftware','BingWeather','Bubbles','CandyCrush','DiamondMine','JewelMatch','HiddenCity','BubbleWitch3Saga','MarchofEmpires','DisneyPlus','Duolingo','eBay','Facebook','Netflix','Twitter','TikTok','Instagram','Pinterest','LinkedIn','Spotify','Pandora','Hulu','SlingTV','Vudu','FoxSports','ESPN','NFL','NBA','MLB','Fitbit','FlurryTravel','Keeper','Microsoft.3DBuilder','Microsoft.Advertising.Xaml','Microsoft.BingFinance','Microsoft.BingNews','Microsoft.BingSports','Microsoft.BingTranslator','Microsoft.BingWeather','Microsoft.GetHelp','Microsoft.Getstarted','Microsoft.HEIFImageExtension','Microsoft.Messaging','Microsoft.Microsoft3DViewer','Microsoft.MicrosoftOfficeHub','Microsoft.MicrosoftSolitaireCollection','Microsoft.MicrosoftStickyNotes','Microsoft.MSPaint','Microsoft.Office.OneNote','Microsoft.OneConnect','Microsoft.People','Microsoft.PowerAutomateDesktop','Microsoft.Print3D','Microsoft.SkypeApp','Microsoft.StorePurchaseApp','Microsoft.Todos','Microsoft.Wallet','Microsoft.WebMediaExtensions','Microsoft.WebpImageExtension','Microsoft.Windows.Photos','Microsoft.WindowsAlarms','Microsoft.WindowsCalculator','Microsoft.WindowsCamera','Microsoft.WindowsCommunicationsApps','Microsoft.WindowsFeedbackHub','Microsoft.WindowsMaps','Microsoft.WindowsSoundRecorder','Microsoft.Xbox.TCUI','Microsoft.XboxApp','Microsoft.XboxGameCallableUI','Microsoft.XboxGamingOverlay','Microsoft.XboxIdentityProvider','Microsoft.XboxSpeechToTextOverlay','Microsoft.YourPhone','Microsoft.ZuneMusic','Microsoft.ZuneVideo','Microsoft.MixedReality.Portal','Microsoft.Windows.Devices.Hardware','Microsoft.Windows.HolographicFirstRun','Microsoft.Windows.Phone','Microsoft.WindowsStore','Microsoft.WindowsFeedback','Microsoft.WindowsReadingList','Clipchamp','MicrosoftTeams','MicrosoftWindows.Client.WebExperience','Microsoft.549981C3F5F10','Family'); foreach($p in $b){ Get-AppxPackage -AllUsers | Where-Object { $_.Name -like ('*'+$p+'*') } | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like ('*'+$p+'*') } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue }" >> "%LOGFILE%" 2>&1

echo [OK] Bloatware removed.
echo [OK] Bloatware removed >> "%LOGFILE%"

:: ============================================================
:: PART 6: ANNIHILATE MICROSOFT EDGE
:: ============================================================
echo.
echo [6/12] ANNIHILATING MICROSOFT EDGE...
echo [6/12] ANNIHILATING EDGE >> "%LOGFILE%"

taskkill /f /im msedge.exe >> "%LOGFILE%" 2>&1
taskkill /f /im MicrosoftEdge.exe >> "%LOGFILE%" 2>&1
taskkill /f /im MicrosoftEdgeUpdate.exe >> "%LOGFILE%" 2>&1
taskkill /f /im edgeupdatem.exe >> "%LOGFILE%" 2>&1
timeout /t 3 /nobreak >nul

:: Try uninstall via setup.exe
for %%d in ("%ProgramFiles(x86)%\Microsoft\Edge\Application\*" "%ProgramFiles%\Microsoft\Edge\Application\*" "%LocalAppData%\Microsoft\Edge\Application\*") do (
    if exist "%%d\Installer\setup.exe" (
        "%%d\Installer\setup.exe" --uninstall --force-uninstall --system-level >> "%LOGFILE%" 2>&1
    )
)

:: Delete Edge directories
rmdir /s /q "%ProgramFiles(x86)%\Microsoft\Edge" >> "%LOGFILE%" 2>&1
rmdir /s /q "%ProgramFiles%\Microsoft\Edge" >> "%LOGFILE%" 2>&1
rmdir /s /q "%LocalAppData%\Microsoft\Edge" >> "%LOGFILE%" 2>&1
rmdir /s /q "%ProgramData%\Microsoft\Edge" >> "%LOGFILE%" 2>&1
rmdir /s /q "%LocalAppData%\Microsoft\EdgeUpdate" >> "%LOGFILE%" 2>&1
rmdir /s /q "%ProgramData%\Microsoft\EdgeUpdate" >> "%LOGFILE%" 2>&1

:: Disable Edge services
sc stop edgeupdate >> "%LOGFILE%" 2>&1
sc stop edgeupdatem >> "%LOGFILE%" 2>&1
sc stop MicrosoftEdgeElevationService >> "%LOGFILE%" 2>&1
sc delete edgeupdate >> "%LOGFILE%" 2>&1
sc delete edgeupdatem >> "%LOGFILE%" 2>&1
sc delete MicrosoftEdgeElevationService >> "%LOGFILE%" 2>&1

:: Block via registry
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "InstallDefault" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "UpdateDefault" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "AutoUpdateCheckPeriodMinutes" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v "Install{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1

echo [OK] Edge annihilated.
echo [OK] Edge annihilated >> "%LOGFILE%"

:: ============================================================
:: PART 7: EXTERMINATE ONEDRIVE
:: ============================================================
echo.
echo [7/12] EXTERMINATING ONEDRIVE...
echo [7/12] EXTERMINATING ONEDRIVE >> "%LOGFILE%"

taskkill /f /im OneDrive.exe >> "%LOGFILE%" 2>&1
timeout /t 3 /nobreak >nul

if exist "%SystemRoot%\System32\OneDriveSetup.exe" (
    "%SystemRoot%\System32\OneDriveSetup.exe" /uninstall >> "%LOGFILE%" 2>&1
)
if exist "%SystemRoot%\SysWOW64\OneDriveSetup.exe" (
    "%SystemRoot%\SysWOW64\OneDriveSetup.exe" /uninstall >> "%LOGFILE%" 2>&1
)

rmdir /s /q "%UserProfile%\OneDrive" >> "%LOGFILE%" 2>&1
rmdir /s /q "%LocalAppData%\Microsoft\OneDrive" >> "%LOGFILE%" 2>&1
rmdir /s /q "%ProgramData%\Microsoft OneDrive" >> "%LOGFILE%" 2>&1

reg delete "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >> "%LOGFILE%" 2>&1
reg delete "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >> "%LOGFILE%" 2>&1

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSync" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1

reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f >> "%LOGFILE%" 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f >> "%LOGFILE%" 2>&1

echo [OK] OneDrive exterminated.
echo [OK] OneDrive exterminated >> "%LOGFILE%"

:: ============================================================
:: PART 8: NEUTRALIZE WINDOWS DEFENDER (with Tamper Protection bypass)
:: ============================================================
echo.
echo [8/12] NEUTRALIZING WINDOWS DEFENDER...
echo [8/12] NEUTRALIZING DEFENDER >> "%LOGFILE%"

:: First try to disable Tamper Protection (required for full disable on Win10/11)
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1

:: Then apply all policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpynetReporting" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d 2 /f >> "%LOGFILE%" 2>&1

sc stop WinDefend >> "%LOGFILE%" 2>&1
sc config WinDefend start= disabled >> "%LOGFILE%" 2>&1
sc stop SecurityHealthService >> "%LOGFILE%" 2>&1
sc config SecurityHealthService start= disabled >> "%LOGFILE%" 2>&1
sc stop wscsvc >> "%LOGFILE%" 2>&1
sc config wscsvc start= disabled >> "%LOGFILE%" 2>&1

echo [OK] Windows Defender neutralized.
echo [OK] Windows Defender neutralized >> "%LOGFILE%"

:: ============================================================
:: PART 9: DISABLE WINDOWS UPDATE FOREVER
:: ============================================================
echo.
echo [9/12] DISABLING WINDOWS UPDATE PERMANENTLY...
echo [9/12] DISABLING WINDOWS UPDATE >> "%LOGFILE%"

sc stop wuauserv >> "%LOGFILE%" 2>&1
sc config wuauserv start= disabled >> "%LOGFILE%" 2>&1
sc stop BITS >> "%LOGFILE%" 2>&1
sc config BITS start= disabled >> "%LOGFILE%" 2>&1
sc stop TrustedInstaller >> "%LOGFILE%" 2>&1
sc config TrustedInstaller start= disabled >> "%LOGFILE%" 2>&1
sc stop Dosvc >> "%LOGFILE%" 2>&1
sc config Dosvc start= disabled >> "%LOGFILE%" 2>&1
sc stop UsoSvc >> "%LOGFILE%" 2>&1
sc config UsoSvc start= disabled >> "%LOGFILE%" 2>&1
sc stop WaaSMedicSvc >> "%LOGFILE%" 2>&1
sc config WaaSMedicSvc start= disabled >> "%LOGFILE%" 2>&1

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 2 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableWindowsUpdateAccess" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1

:: Block Windows Update in hosts
echo 0.0.0.0 windowsupdate.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 0.0.0.0 update.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 0.0.0.0 download.windowsupdate.com >> %SystemRoot%\System32\drivers\etc\hosts

echo [OK] Windows Update permanently disabled.
echo [OK] Windows Update disabled >> "%LOGFILE%"

:: ============================================================
:: PART 10: KILL BACKGROUND APPS
:: ============================================================
echo.
echo [10/12] KILLING BACKGROUND APPS...
echo [10/12] KILLING BACKGROUND APPS >> "%LOGFILE%"

reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /t REG_DWORD /d 2 /f >> "%LOGFILE%" 2>&1

echo [OK] Background apps killed.
echo [OK] Background apps killed >> "%LOGFILE%"

:: ============================================================
:: PART 11: DELETE SCHEDULED TASKS (SAFE METHOD)
:: ============================================================
echo.
echo [11/12] DELETING BLOAT SCHEDULED TASKS...
echo [11/12] DELETING SCHEDULED TASKS >> "%LOGFILE%"

set "TASKS=Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser Microsoft\Windows\Application Experience\ProgramDataUpdater Microsoft\Windows\Application Experience\StartupAppTask Microsoft\Windows\Customer Experience Improvement Program\Consolidator Microsoft\Windows\Customer Experience Improvement Program\UsbCeip Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector Microsoft\Windows\Feedback\Siuf\DmClient Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload Microsoft\Windows\Windows Error Reporting\QueueReporting Microsoft\Windows\WindowsUpdate\Automatic App Update Microsoft\Windows\Maps\MapsUpdateTask Microsoft\Windows\Maps\MapsToastTask Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem Microsoft\Windows\Shell\FamilySafetyMonitor Microsoft\Windows\Shell\FamilySafetyRefresh Microsoft\Windows\License Manager\TempSignedLicenseExchange Microsoft\Windows\Clip\License Validation Microsoft\Windows\CloudExperienceHost\CreateObjectTask Microsoft\Windows\DiskFootprint\Diagnostics Microsoft\Windows\FileHistory\File History Microsoft\Windows\Speech\SpeechModelDownloadTask Microsoft\Windows\UNP\RunUpdateNotificationMgr Microsoft\Windows\Location\Notifications"

for %%T in (%TASKS%) do (
    schtasks /Change /TN "%%T" /Disable >> "%LOGFILE%" 2>&1
    schtasks /Delete /TN "%%T" /F >> "%LOGFILE%" 2>&1
)

echo [OK] Scheduled tasks deleted.
echo [OK] Scheduled tasks deleted >> "%LOGFILE%"

:: ============================================================
:: PART 12: MAXIMUM PERFORMANCE TWEAKS
:: ============================================================
echo.
echo [12/12] APPLYING MAXIMUM PERFORMANCE...
echo [12/12] PERFORMANCE TWEAKS >> "%LOGFILE%"

powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >> "%LOGFILE%" 2>&1

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >> "%LOGFILE%" 2>&1
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f >> "%LOGFILE%" 2>&1
reg add "HKCU\Control Panel\Desktop" /v "DragFullWindows" /t REG_SZ /d "0" /f >> "%LOGFILE%" 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "2000" /f >> "%LOGFILE%" 2>&1
reg add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f >> "%LOGFILE%" 2>&1
powercfg -h off >> "%LOGFILE%" 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /va /f >> "%LOGFILE%" 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /va /f >> "%LOGFILE%" 2>&1

echo [OK] Maximum performance applied.
echo [OK] Maximum performance applied >> "%LOGFILE%"

:: ============================================================
:: CLEANUP
:: ============================================================
echo.
echo [EXTRA] Cleaning system junk...
echo [EXTRA] CLEANING JUNK >> "%LOGFILE%"

del /f /s /q "%SystemRoot%\Temp\*" >> "%LOGFILE%" 2>&1
del /f /s /q "%Temp%\*" >> "%LOGFILE%" 2>&1
del /f /s /q "%SystemRoot%\Prefetch\*" >> "%LOGFILE%" 2>&1
del /f /s /q "C:\Windows\SoftwareDistribution\Download\*" >> "%LOGFILE%" 2>&1
ipconfig /flushdns >> "%LOGFILE%" 2>&1

:: ============================================================
:: FINAL SUMMARY
:: ============================================================
cls
echo ============================================================
echo        NUCLEAR PROCESS KILLER - 100% COMPLETE
echo ============================================================
echo.
echo [DESTROYED]
echo   - 200+ Bloatware Apps
echo   - Microsoft Edge (COMPLETE)
echo   - OneDrive (COMPLETE)
echo   - Windows Update (FOREVER)
echo   - Windows Defender (COMPLETE)
echo   - Cortana (TERMINATED)
echo   - All Telemetry
echo   - All Xbox Services
echo   - All Background Apps
echo   - 80+ Windows Services
echo   - 50+ Scheduled Tasks
echo   - All Startup Items
echo   - Visual Effects
echo   - Hibernation
echo.
echo [FIXED IN THIS VERSION]
echo   - Removed dangerous svchost killer (no crashes)
echo   - All commands now execute fully
echo   - Error log saved to C:\ProcessKiller.log
echo.
echo [BACKUP LOCATION] C:\ProcessKillerBackup\
echo.
echo ============================================================
call :REBOOT_PROMPT
goto :eof

:: ############################################################
:: #  TOOL 5 : AUTO BIOS TWEAKER  (requires SCEWIN_64.exe)
:: ############################################################
:TOOL_BIOS
title GOD SERVER - Auto BIOS Tweaker
chcp 65001 >nul 2>&1
if not exist "SCEWIN_64.exe" (
    echo [WARNING] SCEWIN_64.exe was not found in this folder.
    echo           The BIOS module needs SCEWIN_64.exe to actually apply settings.
    echo           Place SCEWIN_64.exe next to this file, then run this option again.
    echo.
    pause
)
:BIOS_MENU
cls
set "b="
echo.        %b%╔══════════════════════════════════════════════════════════╗
echo.        %b%║                       WARNING                            ║  
echo.        %b%║WE RECOMMEND GIGABYTE MOTHERBOARD USERS TO NOT CONTINUE ON║ 
echo.        %b%║  GIGABYTE MOTHERBOARDS HAVE ISSUES WITH TOOLS LIKE THIS  ║ 
echo.        %b%║  STIX PC SERVICES IS NOT RESPONSIBLE FOR ANY HARM THAT   ║
echo.        %b%║    THAT MAY HAVE BEEN CAUSED FROM USING THIS PROGRAM     ║
echo.        %b%╚══════════════════════════════════════════════════════════╝

echo.
echo.
echo [1] Intel Motherboard
echo [2] AMD/Ryzen Motherboard
echo [0] Back to main menu
echo.
set "biosinput="
set /p biosinput=Choose CPU type: 
if /i "%biosinput%"=="1" goto :BIOS_INTEL
if /i "%biosinput%"=="2" goto :BIOS_AMD
if /i "%biosinput%"=="0" goto :eof
goto :BIOS_MENU
:BIOS_AMD
cls
cls
echo. Disabling C States...
SCEWIN_64.exe /i /ms "Global C-state Control" /qv 0x0 /lang en-US
cls
echo. Disabling TPM State...
SCEWIN_64.exe /i /ms "TPM State" /qv 0x0 /lang en-US
cls
echo. Disabling Secure Boot...
SCEWIN_64.exe /i /ms "Secure Boot" /qv 0x0 /lang en-US
cls
echo. Disabling BME DMA Mitigation...
SCEWIN_64.exe /i /ms "Secure Boot" /qv 0 /lang en-US
cls
echo. Disabling Fast Boot...
SCEWIN_64.exe /i /ms "Fast Boot" /qv 0x0 /lang en-US
cls
echo. Disabling Power On By Device...
SCEWIN_64.exe /i /ms "Power On By Mouse" /qv 0x0 /lang en-US
SCEWIN_64.exe /i /ms "Power On By Keyboard" /qv 0x0 /lang en-US
cls
echo. Disabling Wake On Lan...
SCEWIN_64.exe /i /ms "Wake on LAN" /qv 0x0 /lang en-US
cls
echo. Enabling Bootup NumLock State...
SCEWIN_64.exe /i /ms "Bootup NumLock State" /qv 0x1 /lang en-US
cls
echo. Disabling Csm Support...
SCEWIN_64.exe /i /ms "CSM Support" /qv 0x0 /lang en-US
cls
echo. Disabling Network Stack Driver...
SCEWIN_64.exe /i /ms "Network Stack Driver Support" /qv 0x0 /lang en-US
cls
echo. Disabling HD Audio Controller...
SCEWIN_64.exe /i /ms "HD Audio Controller" /qv 0x0 /lang en-US
cls
echo. Enabling XHCI Hand Off...
SCEWIN_64.exe /i /ms "XHCI Hand-Off" /qv 0x0 /lang en-US
cls
echo. Diasbling Legacy Usb Support...
SCEWIN_64.exe /i /ms "Legacy USB Support" /qv 0x0 /lang en-US
cls
echo. Disabling Resume By Alarm...
SCEWIN_64.exe /i /ms "Resume by Alarm" /qv 0x0 /lang en-US
cls
echo. Disabling Fullscreen Logo Display...
SCEWIN_64.exe /i /ms "Full Screen LOGO Show" /qv 0x0 /lang en-US
cls
echo. Disabling Security Device Support...
SCEWIN_64.exe /i /ms "Security Device Support" /qv 0x0 /lang en-US
cls
echo. Disabling CNVI Mode...
SCEWIN_64.exe /i /ms "CNVI Mode" /qv 0x0 /lang en-US
cls
echo. Disabling Energy Efficient P-state...
SCEWIN_64.exe /i /ms "Energy Efficient P-state" /qv 0x0 /lang en-US
cls
echo. Disabling Energy Performance Gain...
SCEWIN_64.exe /i /ms "Energy Performance Gain" /qv 0x0 /lang en-US
cls
echo. Disabling Energy Efficient Turbo...
SCEWIN_64.exe /i /ms "Energy Efficient Turbo" /qv 0x0 /lang en-US
cls
echo. Disabling BME DMA Mitigation...
SCEWIN_64.exe /i /ms "BME DMA Mitigation" /qv 0x0 /lang en-US
cls
echo. Disabling Enable RH Prevention...
SCEWIN_64.exe /i /ms "Enable RH Prevention" /qv 0x0 /lang en-US
cls
echo. Disabling "IOMMU" 
SCEWIN_64.exe /i /ms "IOMMU" /qv 0x0 /lang en-US
cls
echo. Disabling "AMD Cool'N'Quiet" 
SCEWIN_64.exe /i /ms "AMD Cool'N'Quiet" /qv 0x0 /lang en-US
cls
echo. Disabling "Serial / Parallel Port" 
SCEWIN_64.exe /i /ms "Serial / Parallel Port" /qv 0x0 /lang en-US
cls
echo. Disabling "TPM State" 
SCEWIN_64.exe /i /ms "TPM State" /qv 0x0 /lang en-US
cls
echo. Disabling "AMD fTPM switch" 
SCEWIN_64.exe /i /ms "AMD fTPM switch" /qv 0x0 /lang en-US
cls
echo. Disabling "Remote Display Feature" 
SCEWIN_64.exe /i /ms "Remote Display Feature" /qv 0x0 /lang en-US
cls
echo. Disabling "Security Device Support" 
SCEWIN_64.exe /i /ms "Security Device Support" /qv 0x0 /lang en-US
cls
echo. Disabling "PSS Support" 
SCEWIN_64.exe /i /ms "PSS Support" /qv 0x0 /lang en-US
cls
echo. Disabling "AB Clock Gating" 
SCEWIN_64.exe /i /ms "AB Clock Gating" /qv 0x0 /lang en-US
cls
echo. Disabling "PCIB Clock Run" 
SCEWIN_64.exe /i /ms "PCIB Clock Run" /qv 0x0 /lang en-US
cls
echo. Disabling "SR-IOV Support" 
SCEWIN_64.exe /i /ms "SR-IOV Support" /qv 0x0 /lang en-US
cls
echo. Disabling "Opcache Control" 
SCEWIN_64.exe /i /ms "Opcache Control" /qv 0x1 /lang en-US
cls
echo. Disabling "BME DMA Mitigation" 
SCEWIN_64.exe /i /ms "Opcache Control" /qv 0x0 /lang en-US
cls
echo. Disabling "Above 4G memory" 
SCEWIN_64.exe /i /ms "Above 4G memory" /qv 0x1 /lang en-US
cls
echo. Disabling "AB Clock Gating" 
SCEWIN_64.exe /i /ms "Adaptive S4" /qv 0x0 /lang en-US
cls
echo. Disabling "LAN Power Enable" 
SCEWIN_64.exe /i /ms "LAN Power Enable" /qv 0x0 /lang en-US
cls
echo. Disabling "PM L1 SS" 
SCEWIN_64.exe /i /ms "PM L1 SS" /qv 0x0 /lang en-US
cls
echo. Disabling "Win7 USB Wake Support" 
SCEWIN_64.exe /i /ms "Win7 USB Wake Support" /qv 0x0 /lang en-US
cls
echo. Disabling "AMD Cool&Quiet function" 
SCEWIN_64.exe /i /ms "AMD Cool&Quiet function" /qv 0x0 /lang en-US
cls
echo. Disabling "C6 Mode" 
SCEWIN_64.exe /i /ms "C6 Mode" /qv 0x0 /lang en-US
cls
echo. Disabling "PCIe Slot Configuration" 
SCEWIN_64.exe /i /ms "PCIe Slot Configuration" /qv 0x0 /lang en-US
cls
echo. Disabling "3DMark01 Enhancement" 
SCEWIN_64.exe /i /ms "3DMark01 Enhancement" /qv 0x0 /lang en-US
cls
echo. Disabling "Isochronous Support" 
SCEWIN_64.exe /i /ms "Isochronous Support" /qv 0x0 /lang en-US
cls
echo. Disabling "PS2 Devices Support" 
SCEWIN_64.exe /i /ms "PS2 Devices Support" /qv 0x0 /lang en-US
cls
echo. Disabling "Network Stack Driver Support" 
SCEWIN_64.exe /i /ms "Network Stack Driver Support" /qv 0x0 /lang en-US
cls
echo. Disabling "TPM State" 
SCEWIN_64.exe /i /ms "TPM State" /qv 0x0 /lang en-US
cls
echo. Disabling "Enable Hibernation" 
SCEWIN_64.exe /i /ms "Enable Hibernation" /qv 0x0 /lang en-US
cls
echo. Disabling "Onboard PCIE LAN PXE ROM" 
SCEWIN_64.exe /i /ms "Onboard PCIE LAN PXE ROM" /qv 0x0 /lang en-US
cls
echo. Disabling "CRB test" 
SCEWIN_64.exe /i /ms "CRB test" /qv 0x0 /lang en-US
cls
echo. Disabling "Integrated Graphics" 
SCEWIN_64.exe /i /ms "Integrated Graphics" /qv 0x0 /lang en-US
cls
echo. Disabling "AB Clock Gating" 
SCEWIN_64.exe /i /ms "AB Clock Gating" /qv 0x0 /lang en-US
cls
echo. Disabling "PCIB Clock Run" 
SCEWIN_64.exe /i /ms "PCIB Clock Run" /qv 0x0 /lang en-US
cls
echo. Disabling "Aggressive Link PM Capability" 
SCEWIN_64.exe /i /ms "Aggressive Link PM Capability" /qv 0x0 /lang en-US
cls
echo Successfully Optimized Your Bios Settings, Please Restart Your PC...
pause
goto :eof
:BIOS_INTEL
cls
echo. Disabling C States...
SCEWIN_64.exe /i /ms "Global C-state Control" /qv 0x0 /lang en-US
cls
echo. Disabling Ps2 Devices...
SCEWIN_64.exe /i /ms "PS2 Devices Support" /qv 0x0 /lang en-US
cls
echo. Disabling TPM State...
SCEWIN_64.exe /i /ms "TPM State" /qv 0x0 /lang en-US
cls
echo. Disabling Secure Boot... //this so bad for windows 11
SCEWIN_64.exe /i /ms "Secure Boot" /qv 0x0 /lang en-US
cls
echo. Disabling BME DMA Mitigation...
SCEWIN_64.exe /i /ms "Secure Boot" /qv 0 /lang en-US
cls
echo. Disabling Fast Boot...
SCEWIN_64.exe /i /ms "Fast Boot" /qv 0x0 /lang en-US
cls
echo. Disabling Power On By Device...
SCEWIN_64.exe /i /ms "Power On By Mouse" /qv 0x0 /lang en-US
SCEWIN_64.exe /i /ms "Power On By Keyboard" /qv 0x0 /lang en-US
cls
echo. Disabling Wake On Lan...
SCEWIN_64.exe /i /ms "Wake on LAN" /qv 0x0 /lang en-US
cls
echo. Enabling Bootup NumLock State...
SCEWIN_64.exe /i /ms "Bootup NumLock State" /qv 0x1 /lang en-US
cls
echo. Disabling Network Stack Driver...
SCEWIN_64.exe /i /ms "Network Stack Driver Support" /qv 0x0 /lang en-US
cls
echo. disabling XHCI Hand Off...
SCEWIN_64.exe /i /ms "XHCI Hand-Off" /qv 0x0 /lang en-US
cls
echo. disabling Legacy Usb Support...
SCEWIN_64.exe /i /ms "Legacy USB Support" /qv 0x0 /lang en-US
cls
echo. Disabling Resume By Alarm...
SCEWIN_64.exe /i /ms "Resume by Alarm" /qv 0x0 /lang en-US
cls
echo. Disabling Fullscreen Logo Display...
SCEWIN_64.exe /i /ms "Full Screen LOGO Show" /qv 0x0 /lang en-US
cls
echo. Disabling Security Device Support...
SCEWIN_64.exe /i /ms "Security Device Support" /qv 0x0 /lang en-US
cls
echo. Disabling CNVI Mode...
SCEWIN_64.exe /i /ms "CNVI Mode" /qv 0x0 /lang en-US
cls
echo. Disabling Intel RMT State...
SCEWIN_64.exe /i /ms "Intel RMT State" /qv 0x0 /lang en-US
cls
echo. Disabling Intel Ready Mode Technology...
SCEWIN_64.exe /i /ms "Intel Ready Mode Technology" /qv 0x0 /lang en-US
cls
echo. Disabling Energy Efficient P-state...
SCEWIN_64.exe /i /ms "Energy Efficient P-state" /qv 0x0 /lang en-US
cls
echo. Disabling Energy Performance Gain...
SCEWIN_64.exe /i /ms "Energy Performance Gain" /qv 0x0 /lang en-US
cls
echo. Disabling Energy Efficient Turbo...
SCEWIN_64.exe /i /ms "Energy Efficient Turbo" /qv 0x0 /lang en-US
cls
echo. Disabling BME DMA Mitigation...
SCEWIN_64.exe /i /ms "BME DMA Mitigation" /qv 0x0 /lang en-US
cls
echo. Disabling Enable RH Prevention...
SCEWIN_64.exe /i /ms "Enable RH Prevention" /qv 0x0 /lang en-US
cls
echo. Disabling Per Bank Refresh...
SCEWIN_64.exe /i /ms "Per Bank Refresh" /qv 0x0 /lang en-US
cls
echo. Disabling Intel(R) SpeedStep(tm)...
SCEWIN_64.exe /i /ms "Intel(R) SpeedStep(tm)" /qv 0x0 /lang en-US
cls
echo. Disabling cpu-states
SCEWIN_64.exe /i /ms "CPU C-States" /qv 0x0 /lang en-US
cls
echo. Disabling intel speed shift technology
SCEWIN_64.exe /i /ms "Intel(R) Speed Shift Technology" /qv 0x0 /lang en-US
cls
echo. Disabling Energy Efficient P-state
SCEWIN_64.exe /i /ms "Energy Efficient P-state" /qv 0x0 /lang en-US
cls
echo. Disabling me state
SCEWIN_64.exe /i /ms "ME State" /qv 0x0 /lang en-US
cls
echo. Disabling Power Down Mode
SCEWIN_64.exe /i /ms "Power Down Mode" /qv 0x0 /lang en-US
cls
echo.Energy Efficient Turbo
SCEWIN_64.exe /i /ms "Energy Efficient Turbo" /qv 0x0 /lang en-US
cls
echo. Disabling TPM State
SCEWIN_64.exe /i /ms "TPM State" /qv 0x0 /lang en-US
cls
echo. Disabling command Rate Support
SCEWIN_64.exe /i /ms "command Rate Support" /qv 0x0 /lang en-US
cls
echo. Disabling RC6(Render Standby)
SCEWIN_64.exe /i /ms "RC6(Render Standby)" /qv 0x0 /lang en-US
cls
echo. Disabling Type C Support
SCEWIN_64.exe /i /ms "Type C Support" /qv 0x0 /lang en-US
cls
echo. Disabling LAN Wake From DeepSx
SCEWIN_64.exe /i /ms "LAN Wake From DeepSx" /qv 0x0 /lang en-US
cls
echo. Disabling PCH Cross Throttling
SCEWIN_64.exe /i /ms "PCH Cross Throttling" /qv 0x0 /lang en-US
cls
echo. Disabling Power Down Unused Lanes
SCEWIN_64.exe /i /ms "Power Down Unused Lanes" /qv 0x0 /lang en-US
cls
echo. Disabling BME DMA Mitigation
SCEWIN_64.exe /i /ms "BME DMA Mitigation" /qv 0x0 /lang en-US
cls
echo. Disablling ACPI Standby State
SCEWIN_64.exe /i /ms "ACPI Standby State" /qv 0x0 /lang en-US
cls
echo. Disabling USB2 PHY Sus Well Power Gating
SCEWIN_64.exe /i /ms "USB2 PHY Sus Well Power Gating" /qv 0x0 /lang en-US
cls
echo. Disabling HW Notification
SCEWIN_64.exe /i /ms "HW Notification" /qv 0x0 /lang en-US
cls
echo. Disabling DMI Link ASPM Control
SCEWIN_64.exe /i /ms "DMI Link ASPM Control" /qv 0x0 /lang en-US
cls
echo. Disabling PCIe Spread Spectrum Clocking
SCEWIN_64.exe /i /ms "PCIe Spread Spectrum Clocking" /qv 0x0 /lang en-US
cls
echo. Disabling C6DRAM
SCEWIN_64.exe /i /ms "C6DRAM" /qv 0x0 /lang en-US
cls
echo. Disabling Intel Virtualization Tech
SCEWIN_64.exe /i /ms "Intel Virtualization Tech" /qv 0x0 /lang en-US
cls
echo. Disabling CPU AES Instructions
SCEWIN_64.exe /i /ms "CPU AES Instructions" /qv 0x0 /lang en-US
cls
echo. Disabling EIST
SCEWIN_64.exe /i /ms "EIST" /qv 0x0 /lang en-US
cls
echo. Disabling Enable RH Prevention
SCEWIN_64.exe /i /ms "Enable RH Prevention" /qv 0x0 /lang en-US
cls
echo. Disabling Race To Halt
SCEWIN_64.exe /i /ms "Race To Halt" /qv 0x0 /lang en-US
cls
echo. Disabling Intel RMT State
SCEWIN_64.exe /i /ms "Intel RMT State" /qv 0x0 /lang en-US
cls
echo. Disabling Intel Adaptive Thermal Monitor
SCEWIN_64.exe /i /ms "Intel Adaptive Thermal Monitor" /qv 0x0 /lang en-US
cls
echo. Disabling HDC Control
SCEWIN_64.exe /i /ms "HDC Control" /qv 0x0 /lang en-US
cls
echo. Disabling SMM Code Access Check
SCEWIN_64.exe /i /ms "SMM Code Access Check" /qv 0x0 /lang en-US
cls
echo. Disabling SMM Use Delay Indication
SCEWIN_64.exe /i /ms "SMM Use Delay Indication" /qv 0x0 /lang en-US
cls
echo Disabling SMM Use Block Indication
SCEWIN_64.exe /i /ms "SMM Use Block Indication" /qv 0x0 /lang en-US
cls
echo. Disabling SMM Use SMM en-US Indication
SCEWIN_64.exe /i /ms "SMM Use SMM en-US Indication" /qv 0x0 /lang en-US
cls
echo. Disabling LTR
SCEWIN_64.exe /i /ms "LTR" /qv 0x0 /lang en-US
cls
echo. Enabling I/O Resources Padding
SCEWIN_64.exe /i /ms "I/O Resources Padding" /qv 0x20 /lang en-US
cls
echo. Enabling MMIO 32 bit Resources Padding
SCEWIN_64.exe /i /ms "MMIO 32 bit Resources Padding" /qv 0x80 /lang en-US
cls
echo. Enabling PFMMIO 32 bit Resources Padding
SCEWIN_64.exe /i /ms "PFMMIO 32 bit Resources Padding" /qv 0x80 /lang en-US
cls
echo Enabling PFMMIO 64 bit Resources Padding
SCEWIN_64.exe /i /ms "PFMMIO 64 bit Resources Padding" /qv 0x2000 /lang en-US
cls
echo. Disabling CNVI MODE
SCEWIN_64.exe /i /ms "CNVI MODE" /qv 0x0 /lang en-US
cls
echo. Disabling CWIFI SAR 
SCEWIN_64.exe /i /ms "CWIFI SAR" /qv 0x0 /lang en-US
cls
echo. Disabling CNVI MODE
SCEWIN_64.exe /i /ms "CNVI MODE" /qv 0x0 /lang en-US
cls
echo. Disabling WWAN Reset Workaround
SCEWIN_64.exe /i /ms "WWAN Reset Workaround" /qv 0x0 /lang en-US
cls
echo. Disabling WWAN Device
SCEWIN_64.exe /i /ms "WWAN Device" /qv 0x0 /lang en-US
cls
echo. Disabling C6DRAM
SCEWIN_64.exe /i /ms "C6DRAM" /qv 0x0 /lang en-US
cls
echo. Disabling 1394 controller
SCEWIN_64.exe /i /ms "1394 controller" /qv 0x0 /lang en-US
cls
echo. Disabling Legacy USB support
SCEWIN_64.exe /i /ms "Legacy USB support" /qv 0x0 /lang en-US
cls
echo. Disabling CPU Spread Spectrum
SCEWIN_64.exe /i /ms "CPU Spread Spectrum" /qv 0x0 /lang en-US
cls
echo. Disabling Execute Disable Bit
SCEWIN_64.exe /i /ms "Execute Disable Bit" /qv 0x0 /lang en-US
cls
echo. Disabling iGPU Multi-Monitor
SCEWIN_64.exe /i /ms "iGPU Multi-Monitor" /qv 0x0 /lang en-US
cls
echo. Disabling Power Saving Features...
SCEWIN_64.exe /i /ms "PEP TBT RP" /qv 0x0 /lang en-US
SCEWIN_64.exe /i /ms "PEP LAN(GBE)" /qv 0x0 /lang en-US
SCEWIN_64.exe /i /ms "PEP CSME" /qv 0x0 /lang en-US
SCEWIN_64.exe /i /ms "PEP SDXCE" /qv 0x0 /lang en-US
SCEWIN_64.exe /i /ms "PEP EMMC" /qv 0x0 /lang en-US
pause
echo Successfully Optimized Your Bios Settings, Please Restart Your PC...
goto :eof
