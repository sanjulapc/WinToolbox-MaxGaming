#Requires -Version 5.1
<#
================================================================================
  WinToolbox.ps1  -  All-in-one Windows utility launcher
--------------------------------------------------------------------------------
  30 tools in one script - Windows 10 and 11 aware. Built-in tools only, reversible
  where the original was reversible. Each tool keeps its original behaviour.

  TOOLS - AUTO-APPLICABLE (also run together by ApplyAll / Profile):
    1  VisualFX     - Performance Options "Custom": thumbnails + smooth fonts on
    2  Input        - Mouse/keyboard 1:1 "god mode" gaming tune
    3  PowerPlan    - Max-performance power plan manager (admin)
    4  Network      - Low-latency gaming network tune: TCP stack, Nagle off,
                     throttle off, NIC always-on, optional fast DNS (admin)
    5  CPU          - CPU scheduler/throttle tune: foreground boost, EcoQoS
                     throttle off, Games MMCSS; optional mitigations-off and
                     boot-timer tweaks behind flags (admin). NOT the power plan.
    6  GPU          - NVIDIA only: force PowerMizer max performance (registry),
                     optional HAGS, and nvidia-smi status / clock-lock / power-
                     limit (driver-shipped tool). No 3rd-party overclocking (admin)
    7  Debloat      - Disable telemetry services + scheduled tasks (curated,
                     reversible). Optional Xbox/printer/search/SysMain (admin)
    8  GameLoop     - Disable VBS / Memory Integrity / Credential Guard + boot
                     hypervisor for Android emulators; merge svchost. SECURITY
                     tradeoff, reboot, reversible (admin)
    9  GameDVR      - Game DVR / background capture off, Game Mode on; optional
                     background-apps off (admin)
   10  Storage      - fsutil TRIM/last-access/8.3 + SSD ReTrim + RAM-friendly
                     memory tweaks (admin)
   11  GameProfile  - Persistent High CPU priority for game .exe via IFEO;
                     GameLoop preset included (admin)
   12  Audio        - Disable per-endpoint enhancements + communications ducking
                     off to cut stutter (admin)
   13  Display      - Disable Fullscreen Optimizations system-wide + enable
                     windowed-games (flip model) optimization; optional MPO
                     disable for flicker/stutter (admin)
   14  NicTune      - NIC advanced props: Energy-Efficient Ethernet / Green
                     Ethernet / Flow Control / power-save off; optional Interrupt
                     Moderation + LSO off (admin)

  TOOLS - MANUAL ONLY (run each yourself; never auto-applied):
   15  PageFile     - Fixed page file / virtual memory (admin)
   16  DriveLock    - Block writes to non-system drives via NTFS deny (admin)
   17  Browsers     - Download Chrome / Brave installers
   18  WinSettings  - GUI: theme / wallpaper / lock screen / time zone
   19  TempCleaner  - GodMode+ junk cleaner (admin)
   20  Startup      - Enable/disable Run-key and Startup-folder items (Task-
                     Manager-style, reversible) (admin)
   21  Latency      - DPC/latency advisor (built-in): MSI-mode status, timer,
                     power plan, driver dates + energy report; optional MSI-mode
                     enable for GPU/NIC (admin). No 3rd-party DPC monitor.
   22  GameFocus    - Notifications/tips off (reversible) + runtime -Boost to set
                     a running game to High priority (session-only)
   23  GameRules    - Process-Lasso style: per-game CPU AFFINITY (+ re-asserted
                     priority) applied to running games by an optional background
                     watcher task. Priority alone -> use tool 11 (admin)
   24  Updates      - Block driver updates via Windows Update, no auto-restart
                     while logged on, Delivery Optimization P2P off (admin)
   25  Privacy      - Advertising ID / activity history / tailored experiences /
                     telemetry / Cortana / web search / location off (admin)
   26  Apps         - Remove OneDrive, Internet Explorer, classic Paint, Microsoft
                     Store (warned), and curated consumer bloat apps; -Revert
                     restores where Windows allows (admin)
   27  Features     - Turn OFF Print Spooler, Remote Desktop (incoming) + Remote
                     Assistance, Fax, and untick curated Windows optional features
                     (XPS, Work Folders, SMB1, PowerShell 2.0) (admin)
   28  Taskbar      - Hide taskbar search, widgets/weather, Task View button, and
                     all desktop icons (per-user; restarts Explorer to apply)
   29  WinUI        - Win10/11 UI tweaks, version-aware: classic right-click
                     menu, taskbar align left, Chat/Teams button off (Win11);
                     Meet Now + Cortana button off (Win10); Copilot off,
                     transparency off, file extensions on (both). Reversible
   30  GpuPref      - Graphics performance preference: forces the GameLoop /
                     PUBG emulator exes (AndroidEmulatorEn/Ex/AndroidEmulator,
                     GameLoop, aow_exe) onto the High-performance GPU and turns
                     on Hardware-accelerated GPU scheduling (HAGS). Reversible.
                     -AddApp <full\path.exe> adds any game; -NoHags skips HAGS

  TOOLBOX ACTIONS
   ApplyAll    - MAX: full aggressive set across tools (typed confirmation)
   Profile     - apply the recommended safe subset across tools (+restore point)
   StatusAll   - run every tool's -Status audit
   RevertAll   - undo all perf/gaming tweaks (not PageFile/DriveLock)
   Checkpoint  - create a System Restore point
   Snapshot    - save / list / restore a bundle of all per-tool backup files
   AuditLog    - view the timestamped action log (~/WinToolbox/audit.log)

  USAGE
    Interactive menu:
        powershell -ExecutionPolicy Bypass -File .\WinToolbox.ps1

    Run one tool directly (admin tools self-elevate):
        .\WinToolbox.ps1 -Tool VisualFX
        .\WinToolbox.ps1 -Tool VisualFX -Revert -RestartExplorer
        .\WinToolbox.ps1 -Tool Input
        .\WinToolbox.ps1 -Tool Input -Status
        .\WinToolbox.ps1 -Tool Input -Revert
        .\WinToolbox.ps1 -Tool PowerPlan
        .\WinToolbox.ps1 -Tool PageFile -Initial 8192 -Maximum 12288
        .\WinToolbox.ps1 -Tool PageFile -Revert
        .\WinToolbox.ps1 -Tool DriveLock -Lock -Drives D,E
        .\WinToolbox.ps1 -Tool DriveLock -Unlock
        .\WinToolbox.ps1 -Tool DriveLock -Status
        .\WinToolbox.ps1 -Tool Browsers -Chrome
        .\WinToolbox.ps1 -Tool WinSettings
        .\WinToolbox.ps1 -Tool WinSettings -Revert
        .\WinToolbox.ps1 -Tool TempCleaner -Preview -GodMode -IncludeBrowsers
        .\WinToolbox.ps1 -Tool TempCleaner -GodMode -IncludeBrowsers
        .\WinToolbox.ps1 -Tool TempCleaner -GodMode -RemoveWindowsOld -ResetBase -Force
        .\WinToolbox.ps1 -Tool TempCleaner -Schedule
        .\WinToolbox.ps1 -Tool Network                     # apply god mode
        .\WinToolbox.ps1 -Tool Network -SetDNS             # + Cloudflare DNS
        .\WinToolbox.ps1 -Tool Network -SetDNS -DnsProvider Google
        .\WinToolbox.ps1 -Tool Network -Status             # read-only audit
        .\WinToolbox.ps1 -Tool Network -Revert             # undo everything
        .\WinToolbox.ps1 -Tool Network -ResetStack         # winsock/ip reset (reboot)
        .\WinToolbox.ps1 -Tool CPU                         # scheduler + throttle tune
        .\WinToolbox.ps1 -Tool CPU -DisableMitigations     # Spectre/Meltdown off (reboot)
        .\WinToolbox.ps1 -Tool CPU -TimerTweaks            # boot timer (reboot)
        .\WinToolbox.ps1 -Tool CPU -Status                 # read-only audit
        .\WinToolbox.ps1 -Tool CPU -Revert                 # undo everything
        .\WinToolbox.ps1 -Tool GPU                         # force NVIDIA max performance
        .\WinToolbox.ps1 -Tool GPU -HAGS On                # + hardware GPU scheduling
        .\WinToolbox.ps1 -Tool GPU -LockClocks             # nvidia-smi clock lock (supported cards)
        .\WinToolbox.ps1 -Tool GPU -PowerLimit 250         # nvidia-smi power limit (supported cards)
        .\WinToolbox.ps1 -Tool GPU -Status                 # read-only audit + live stats
        .\WinToolbox.ps1 -Tool GPU -Revert                 # undo everything
        .\WinToolbox.ps1 -Tool Debloat                     # disable telemetry svc+tasks
        .\WinToolbox.ps1 -Tool Debloat -DisableXbox        # + Xbox Live services
        .\WinToolbox.ps1 -Tool Debloat -Status
        .\WinToolbox.ps1 -Tool Debloat -Revert
        .\WinToolbox.ps1 -Tool GameLoop                    # VBS/Hyper-V off (reboot)
        .\WinToolbox.ps1 -Tool GameLoop -Status
        .\WinToolbox.ps1 -Tool GameLoop -Revert
        .\WinToolbox.ps1 -Tool GameDVR                     # Game DVR off, Game Mode on
        .\WinToolbox.ps1 -Tool GameDVR -DisableBackgroundApps
        .\WinToolbox.ps1 -Tool GameDVR -Revert
        .\WinToolbox.ps1 -Tool ApplyAll                    # MAX everything (aggressive)
        .\WinToolbox.ps1 -Tool Profile                     # recommended gaming profile
        .\WinToolbox.ps1 -Tool StatusAll                   # audit everything
        .\WinToolbox.ps1 -Tool RevertAll                   # undo perf/gaming tweaks
        .\WinToolbox.ps1 -Tool Checkpoint                  # create a restore point
        .\WinToolbox.ps1 -Tool Startup                     # interactive startup manager
        .\WinToolbox.ps1 -Tool Startup -Status
        .\WinToolbox.ps1 -Tool Startup -Revert
        .\WinToolbox.ps1 -Tool Storage                     # TRIM/last-access/8.3 + RAM
        .\WinToolbox.ps1 -Tool Storage -Status
        .\WinToolbox.ps1 -Tool Storage -Revert
        .\WinToolbox.ps1 -Tool GameProfile -GameLoopPreset # High priority for GameLoop
        .\WinToolbox.ps1 -Tool GameProfile -AddGame pubgm.exe -Priority High
        .\WinToolbox.ps1 -Tool GameProfile -Status
        .\WinToolbox.ps1 -Tool GameProfile -Revert
        .\WinToolbox.ps1 -Tool Latency                     # DPC/latency advisor (read-only)
        .\WinToolbox.ps1 -Tool Latency -EnableMSI          # MSI mode for GPU/NIC (reboot)
        .\WinToolbox.ps1 -Tool Latency -Trace              # powercfg energy report
        .\WinToolbox.ps1 -Tool Latency -Revert
        .\WinToolbox.ps1 -Tool GameFocus                   # notifications/tips off
        .\WinToolbox.ps1 -Tool GameFocus -Boost AndroidEmulatorEn.exe
        .\WinToolbox.ps1 -Tool GameFocus -Revert
        .\WinToolbox.ps1 -Tool Audio                       # enhancements off, ducking off
        .\WinToolbox.ps1 -Tool Audio -Status
        .\WinToolbox.ps1 -Tool Audio -Revert
        .\WinToolbox.ps1 -Tool Display                     # FSO off + windowed-opt
        .\WinToolbox.ps1 -Tool Display -DisableMPO         # + disable MPO
        .\WinToolbox.ps1 -Tool Display -Revert
        .\WinToolbox.ps1 -Tool GameRules -GameLoopPreset     # High rules for all GameLoop engines + watcher
        .\WinToolbox.ps1 -Tool GameRules -AddRule AndroidEmulatorEn.exe -Priority High -Cores 0-5
        .\WinToolbox.ps1 -Tool GameRules -Install          # background watcher (applies rules)
        .\WinToolbox.ps1 -Tool GameRules -ApplyNow         # apply rules to running games once
        .\WinToolbox.ps1 -Tool GameRules -Status
        .\WinToolbox.ps1 -Tool GameRules -Revert           # remove watcher + clear rules
        .\WinToolbox.ps1 -Tool NicTune                     # EEE/power-save/flow off
        .\WinToolbox.ps1 -Tool NicTune -NoModeration       # + interrupt moderation/LSO off
        .\WinToolbox.ps1 -Tool NicTune -Revert
        .\WinToolbox.ps1 -Tool Updates                     # block WU drivers, P2P off
        .\WinToolbox.ps1 -Tool Updates -Revert
        .\WinToolbox.ps1 -Tool Privacy                     # privacy/background toggles
        .\WinToolbox.ps1 -Tool Privacy -Revert
        .\WinToolbox.ps1 -Tool Apps                        # interactive remover menu
        .\WinToolbox.ps1 -Tool Apps -RemoveBloat -RemoveOneDrive -RemoveIE -RemovePaint
        .\WinToolbox.ps1 -Tool Apps -Status
        .\WinToolbox.ps1 -Tool Apps -Revert
        .\WinToolbox.ps1 -Tool Features -HardenServices -DisableFeatures
        .\WinToolbox.ps1 -Tool Features -DisableFeature SMB1Protocol
        .\WinToolbox.ps1 -Tool Features -Status
        .\WinToolbox.ps1 -Tool Features -Revert
        .\WinToolbox.ps1 -Tool Taskbar                     # hide search/widgets/taskview/icons
        .\WinToolbox.ps1 -Tool Taskbar -HideSearch -HideWidgets   # hide only those two
        .\WinToolbox.ps1 -Tool Taskbar -Status
        .\WinToolbox.ps1 -Tool Taskbar -Revert
        .\WinToolbox.ps1 -Tool WinUI                       # OS-appropriate default set
        .\WinToolbox.ps1 -Tool WinUI -ClassicMenu -DisableCopilot -TaskbarLeft
        .\WinToolbox.ps1 -Tool WinUI -Status
        .\WinToolbox.ps1 -Tool WinUI -Revert
        .\WinToolbox.ps1 -Tool GpuPref                     # emulator exes -> High-perf GPU + HAGS on
        .\WinToolbox.ps1 -Tool GpuPref -NoHags             # set GPU pref only, leave HAGS as-is
        .\WinToolbox.ps1 -Tool GpuPref -AddApp "C:\Games\game.exe"
        .\WinToolbox.ps1 -Tool GpuPref -Status
        .\WinToolbox.ps1 -Tool GpuPref -Revert
        .\WinToolbox.ps1 -Tool WinSettings -WinApply       # dark + transparency off, no window
        .\WinToolbox.ps1 -Tool WinSettings                 # opens the full settings GUI
        .\WinToolbox.ps1 -Tool WinSettings -Revert
        .\WinToolbox.ps1 -Tool Startup -StartupApply       # disable heavy startup apps (silent, safe)
        .\WinToolbox.ps1 -Tool Startup -Manage             # open the interactive startup manager
        .\WinToolbox.ps1 -Tool Startup -Revert
        .\WinToolbox.ps1 -Tool Snapshot -Action Save       # bundle all backup files
        .\WinToolbox.ps1 -Tool Snapshot -Action List
        .\WinToolbox.ps1 -Tool Snapshot -Action Restore -Name 20260622_1530
        .\WinToolbox.ps1 -Tool AuditLog                    # view action log

  Built for Sanjula.
================================================================================
#>

[CmdletBinding()]
param(
    [ValidateSet('VisualFX','Input','PowerPlan','PageFile','DriveLock','Browsers','WinSettings','TempCleaner','Network','CPU','GPU','Debloat','GameLoop','GameDVR','Startup','Storage','GameProfile','Latency','GameFocus','Audio','Display','GameRules','NicTune','Updates','Privacy','Apps','Features','Taskbar','WinUI','GpuPref','Checkpoint','StatusAll','RevertAll','Profile','ApplyAll','Snapshot','AuditLog')]
    [string]$Tool,

    # PowerPlan silent re-lock path (used by its startup scheduled task)
    [switch]$Enforce,

    # GUI front-end (multi-select apply)
    [switch]$Gui,

    # internal: GUI relaunch hides its own console window
    [switch]$HideConsole,

    # Shared / common
    [switch]$Revert,
    [switch]$Status,
    [switch]$NoPause,
    [switch]$RestartExplorer,
    [switch]$Force,

    # PageFile
    [int]$Initial = 8192,
    [int]$Maximum = 12288,

    # DriveLock
    [switch]$Lock,
    [switch]$Unlock,
    [Alias('RevertLock')][switch]$Off,
    [string[]]$Drives,

    # Browsers
    [switch]$Chrome,
    [switch]$Brave,

    # WinSettings
    [string]$WallpaperDir,

    # TempCleaner
    [switch]$Preview,
    [switch]$GodMode,
    [switch]$IncludeBrowsers,
    [switch]$RemoveWindowsOld,
    [switch]$ResetBase,
    [switch]$ClearEventLogs,
    [switch]$Schedule,

    # Network
    [switch]$SetDNS,
    [ValidateSet('Cloudflare','Google','Quad9')][string]$DnsProvider = 'Cloudflare',
    [switch]$ResetStack,

    # CPU
    [switch]$DisableMitigations,
    [switch]$TimerTweaks,

    # GPU (NVIDIA)
    [switch]$LockClocks,
    [int]$PowerLimit = 0,
    [ValidateSet('On','Off')][string]$HAGS,

    # Debloat
    [switch]$DisableXbox,
    [switch]$NoPrinter,
    [switch]$DisableSearch,
    [switch]$DisableSysMain,

    # GameDVR
    [switch]$DisableBackgroundApps,

    # GameProfile (per-game IFEO priority)
    [switch]$GameLoopPreset,
    [string]$AddGame,
    [ValidateSet('High','AboveNormal','Normal','BelowNormal','Idle')][string]$Priority = 'High',

    # Latency & Interrupts
    [switch]$Trace,
    [switch]$EnableMSI,

    # Game Focus
    [string]$Boost,

    # Display & Fullscreen
    [switch]$DisableMPO,

    # NIC Tuning
    [switch]$NoModeration,

    # Apps remover
    [switch]$RemoveBloat,
    [switch]$RemoveOneDrive,
    [switch]$RemoveIE,
    [switch]$RemovePaint,
    [switch]$RemoveStore,

    # Windows features & services
    [switch]$HardenServices,
    [switch]$DisableFeatures,
    [string]$DisableFeature,

    # Taskbar & desktop
    [switch]$HideSearch,
    [switch]$HideWidgets,
    [switch]$HideTaskView,
    [switch]$HideDesktopIcons,
    [switch]$NoRestart,

    # Win10/11 UI tweaks (tool 29 - version-aware)
    [switch]$ClassicMenu,
    [switch]$TaskbarLeft,
    [switch]$HideChat,
    [switch]$DisableCopilot,
    [switch]$HideMeetNow,
    [switch]$HideCortanaButton,
    [switch]$NoTransparency,
    [switch]$ShowFileExt,

    # Game Rules (Process-Lasso style)
    [switch]$Daemon,
    [switch]$Install,
    [switch]$Uninstall,
    [switch]$ApplyNow,
    [string]$AddRule,
    [string]$RemoveRule,
    [string]$Cores,
    [int]$IntervalMin = 2,

    # Snapshot
    [ValidateSet('Save','List','Restore')][string]$Action = 'List',
    [string]$Name,

    # Tool 30 - Graphics performance preference (per-app GPU + HAGS)
    [string]$AddApp,          # full path to an .exe to force onto the high-performance GPU
    [switch]$NoHags,          # skip enabling Hardware-accelerated GPU scheduling

    # WinSettings (tool 18) - silent embedded apply (used by the GUI batch / MAX)
    [switch]$WinApply,        # apply the gaming visual defaults with no window
    [switch]$WinDark,         # force dark mode
    [switch]$WinTransparencyOff, # turn transparency effects off (perf)
    [switch]$WinTimeZone,     # set Sri Lanka Standard Time
    [switch]$WinShowUi,       # open the full interactive Windows Settings window

    # Startup (tool 20) - silent embedded apply (used by the GUI batch / MAX)
    [switch]$StartupApply,    # disable a curated set of heavy startup apps (reversible, silent)
    [switch]$Manage           # open the interactive startup manager instead
)

# ===========================================================================
#  Shared helpers
# ===========================================================================
function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Windows 10 vs 11 detection (cached). ProductName lies on Win11, so the
# build number decides: 22000+ = Windows 11.
function Get-WtxOS {
    if ($script:WtxOSCache) { return $script:WtxOSCache }
    $cv = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction SilentlyContinue
    $build = 0
    try { $build = [int]$cv.CurrentBuildNumber } catch {}
    $isWin11 = ($build -ge 22000)
    $name = [string]$cv.ProductName
    if ($isWin11 -and $name -match 'Windows 10') { $name = $name -replace 'Windows 10', 'Windows 11' }
    if (-not $name) { $name = if ($isWin11) { 'Windows 11' } else { 'Windows 10' } }
    $disp = [string]$cv.DisplayVersion
    if (-not $disp) { $disp = [string]$cv.ReleaseId }
    $script:WtxOSCache = [pscustomobject]@{ Name = $name; Build = $build; IsWin11 = $isWin11; Version = $disp }
    return $script:WtxOSCache
}

function Restart-Elevated {
    # Relaunch THIS combined script, elevated, targeting one tool.
    param([string]$ToolName, [hashtable]$Extra = @{})
    Write-Host "Requesting administrator privileges..." -ForegroundColor Yellow
    $a = @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"")
    if ($ToolName) { $a += @('-Tool', $ToolName) }
    foreach ($k in $Extra.Keys) {
        $v = $Extra[$k]
        if ($v -is [switch]) { if ($v.IsPresent) { $a += "-$k" } }
        elseif ($v -is [bool]) { if ($v) { $a += "-$k" } }
        elseif ($null -ne $v -and "$v" -ne '') {
            if ($v -is [array]) { $a += "-$k"; $a += ($v -join ',') }
            else                { $a += "-$k"; $a += "$v" }
        }
    }
    try { Start-Process powershell.exe -Verb RunAs -ArgumentList $a }
    catch { Write-Host "Elevation cancelled." -ForegroundColor Red }
}

function Pause-Any {
    param([string]$Msg = 'Press Enter to return to menu...')
    Write-Host ""
    Write-Host "  $Msg" -ForegroundColor DarkGray
    [void](Read-Host)
}

function New-RestoreCheckpoint {
    param([string]$Description = 'WinToolbox god mode')
    if (-not (Test-Admin)) { Write-Host "  [!] Restore point needs admin." -ForegroundColor Yellow; return }
    Write-Host "  [>] Creating a System Restore point..." -ForegroundColor Cyan
    try {
        # allow more than one checkpoint per day
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore' `
            -Name 'SystemRestorePointCreationFrequency' -PropertyType DWord -Value 0 -Force -ErrorAction SilentlyContinue | Out-Null
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description $Description -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop
        Write-Host "  [+] Restore point created: '$Description'" -ForegroundColor Green
    } catch {
        Write-Host "  [!] Could not create a restore point ($($_.Exception.Message))." -ForegroundColor Yellow
        Write-Host "      System Protection may be off (enable it in System Properties > System Protection)." -ForegroundColor DarkGray
    }
}

# --- audit logging -------------------------------------------------------
function Get-WtxDir {
    $d = Join-Path $env:USERPROFILE 'WinToolbox'
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    return $d
}

function Write-AuditLog {
    param([string]$Action)
    try {
        $log = Join-Path (Get-WtxDir) 'audit.log'
        $who = "$env:USERDOMAIN\$env:USERNAME"
        $adm = if (Test-Admin) { 'admin' } else { 'user' }
        $line = "{0}  [{1}/{2}]  {3}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $who, $adm, $Action
        Add-Content -Path $log -Value $line -Encoding UTF8
    } catch {}
}

function Show-AuditLog {
    $log = Join-Path (Get-WtxDir) 'audit.log'
    Write-Host ""
    if (Test-Path $log) {
        Write-Host "  Audit log: $log" -ForegroundColor Gray
        Write-Host "  --- last 40 entries ---" -ForegroundColor DarkGray
        Get-Content $log -Tail 40 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
    } else {
        Write-Host "  No audit log yet ($log)." -ForegroundColor DarkGray
    }
    Write-Host ""
}

# --- unified snapshot of all per-tool backup files -----------------------
function Get-BackupRegistry {
    @(
        @{ Tool='VisualFX';    Path=(Join-Path $env:LOCALAPPDATA 'VisualFX-Custom.backup.json') }
        @{ Tool='Input';       Path=(Join-Path $env:USERPROFILE 'Input-GodMode.backup.json') }
        @{ Tool='Input';       Path=(Join-Path $env:USERPROFILE 'Input-GodMode.power.json') }
        @{ Tool='Input';       Path=(Join-Path $env:USERPROFILE 'Input-GodMode.devpower.json') }
        @{ Tool='Network';     Path=(Join-Path $env:USERPROFILE 'Network-GodMode.backup.json') }
        @{ Tool='Network';     Path=(Join-Path $env:USERPROFILE 'Network-GodMode.dns.json') }
        @{ Tool='CPU';         Path=(Join-Path $env:USERPROFILE 'Cpu-GodMode.backup.json') }
        @{ Tool='GPU';         Path=(Join-Path $env:USERPROFILE 'Gpu-GodMode.backup.json') }
        @{ Tool='Debloat';     Path=(Join-Path $env:USERPROFILE 'Debloat.backup.json') }
        @{ Tool='GameLoop';    Path=(Join-Path $env:USERPROFILE 'GameLoop-VBS.backup.json') }
        @{ Tool='GameDVR';     Path=(Join-Path $env:USERPROFILE 'GameDVR.backup.json') }
        @{ Tool='Storage';     Path=(Join-Path $env:USERPROFILE 'Storage-Memory.backup.json') }
        @{ Tool='GameProfile'; Path=(Join-Path $env:USERPROFILE 'GameProfile-IFEO.backup.json') }
        @{ Tool='Startup';     Path=(Join-Path $env:USERPROFILE 'Startup.backup.json') }
        @{ Tool='Latency';     Path=(Join-Path $env:USERPROFILE 'Latency-MSI.backup.json') }
        @{ Tool='GameFocus';   Path=(Join-Path $env:USERPROFILE 'GameFocus.backup.json') }
        @{ Tool='Audio';       Path=(Join-Path $env:USERPROFILE 'Audio.backup.json') }
        @{ Tool='Display';     Path=(Join-Path $env:USERPROFILE 'Display.backup.json') }
        @{ Tool='GameRules';   Path=(Join-Path $env:USERPROFILE 'GameRules.json') }
        @{ Tool='NicTune';     Path=(Join-Path $env:USERPROFILE 'NicTune.backup.json') }
        @{ Tool='Updates';     Path=(Join-Path $env:USERPROFILE 'Updates.backup.json') }
        @{ Tool='Privacy';     Path=(Join-Path $env:USERPROFILE 'Privacy.backup.json') }
        @{ Tool='Apps';        Path=(Join-Path $env:USERPROFILE 'Apps-Removed.backup.json') }
        @{ Tool='Features';    Path=(Join-Path $env:USERPROFILE 'Features.backup.json') }
        @{ Tool='Taskbar';     Path=(Join-Path $env:USERPROFILE 'Taskbar.backup.json') }
        @{ Tool='WinUI';       Path=(Join-Path $env:USERPROFILE 'WinUI.backup.json') }
        @{ Tool='WinSettings'; Path=(Join-Path $env:LOCALAPPDATA 'WinSettingsManager\backup.json') }
        @{ Tool='GpuPref';     Path=(Join-Path $env:USERPROFILE 'GpuPref.backup.json') }
    )
}

function Invoke-Snapshot {
    param([ValidateSet('Save','List','Restore')][string]$Action = 'List', [string]$Name)
    $snapRoot = Join-Path (Get-WtxDir) 'snapshots'
    if (-not (Test-Path $snapRoot)) { New-Item -ItemType Directory -Path $snapRoot -Force | Out-Null }

    switch ($Action) {
        'Save' {
            $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
            $dest  = Join-Path $snapRoot $stamp
            New-Item -ItemType Directory -Path $dest -Force | Out-Null
            $n = 0
            $manifest = foreach ($b in (Get-BackupRegistry)) {
                $leaf = "{0}__{1}" -f $b.Tool, (Split-Path $b.Path -Leaf)
                $present = Test-Path $b.Path
                if ($present) { Copy-Item -LiteralPath $b.Path -Destination (Join-Path $dest $leaf) -Force; $n++ }
                @{ Tool=$b.Tool; Path=$b.Path; Leaf=$leaf; Present=$present }
            }
            $manifest | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $dest 'manifest.json') -Encoding UTF8
            Write-Host "  [+] Snapshot saved: $dest" -ForegroundColor Green
            Write-Host ("      Bundled {0} backup file(s)." -f $n) -ForegroundColor DarkGray
            Write-AuditLog "Snapshot Save -> $stamp ($n files)"
        }
        'List' {
            $snaps = Get-ChildItem $snapRoot -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending
            if (-not $snaps) { Write-Host "  No snapshots saved yet." -ForegroundColor DarkGray; return }
            Write-Host "  Saved snapshots (newest first):" -ForegroundColor Gray
            foreach ($s in $snaps) {
                $cnt = (Get-ChildItem $s.FullName -Filter '*.json' -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne 'manifest.json' }).Count
                Write-Host ("    {0}    ({1} files)" -f $s.Name, $cnt) -ForegroundColor DarkGray
            }
        }
        'Restore' {
            if (-not $Name) { Write-Host "  Specify -Name <snapshot> (use List to see names)." -ForegroundColor Yellow; return }
            $src = Join-Path $snapRoot $Name
            if (-not (Test-Path $src)) { Write-Host "  Snapshot '$Name' not found." -ForegroundColor Red; return }
            $man = Get-Content (Join-Path $src 'manifest.json') -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
            $n = 0
            foreach ($m in $man) {
                $file = Join-Path $src $m.Leaf
                if (Test-Path $file) {
                    $dir = Split-Path $m.Path -Parent
                    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
                    Copy-Item -LiteralPath $file -Destination $m.Path -Force
                    $n++
                }
            }
            Write-Host "  [+] Restored $n backup file(s) from snapshot '$Name'." -ForegroundColor Green
            Write-Host "      Now run each tool's Revert (or 'Revert All') to apply the rollback." -ForegroundColor DarkGray
            Write-AuditLog "Snapshot Restore <- $Name ($n files)"
        }
    }
}

# ===========================================================================
#  TOOL 1 - VisualFX  (no admin; run as your normal user)
# ===========================================================================
function Invoke-VisualFX {
    [CmdletBinding()]
    param(
        [switch]$Revert,
        [switch]$RestartExplorer,
        [switch]$NoPause,
        [string]$BackupPath = "$env:LOCALAPPDATA\VisualFX-Custom.backup.json"
    )

    $Settings = @(
        @{ Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'; Name='VisualFXSetting'; Type='DWord'; Apply=3 }
        @{ Path='HKCU:\Control Panel\Desktop'; Name='UserPreferencesMask'; Type='Binary'; Apply=([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) }
        @{ Path='HKCU:\Control Panel\Desktop\WindowMetrics'; Name='MinAnimate';      Type='String'; Apply='0' }
        @{ Path='HKCU:\Control Panel\Desktop';               Name='DragFullWindows'; Type='String'; Apply='0' }
        @{ Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='TaskbarAnimations';   Type='DWord'; Apply=0 }
        @{ Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='ListviewAlphaSelect'; Type='DWord'; Apply=0 }
        @{ Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='ListviewShadow';      Type='DWord'; Apply=0 }
        @{ Path='HKCU:\Software\Microsoft\Windows\DWM'; Name='EnableAeroPeek';            Type='DWord'; Apply=0 }
        @{ Path='HKCU:\Software\Microsoft\Windows\DWM'; Name='AlwaysHibernateThumbnails'; Type='DWord'; Apply=0 }
        @{ Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='IconsOnly'; Type='DWord'; Apply=0 }   # thumbnails ON
        @{ Path='HKCU:\Control Panel\Desktop'; Name='FontSmoothing';     Type='String'; Apply='2' }                             # smooth fonts ON
        @{ Path='HKCU:\Control Panel\Desktop'; Name='FontSmoothingType'; Type='DWord';  Apply=2  }
    )

    function Backup-Current {
        $data = foreach ($s in $Settings) {
            $exists=$false; $val=$null
            try {
                $val = (Get-ItemProperty -Path $s.Path -Name $s.Name -ErrorAction Stop).$($s.Name)
                if ($val -is [byte[]]) { $val = [int[]]$val }
                $exists=$true
            } catch {}
            [pscustomobject]@{ Path=$s.Path; Name=$s.Name; Type=$s.Type; Existed=$exists; Value=$val }
        }
        $data | ConvertTo-Json -Depth 4 | Set-Content -Path $BackupPath -Encoding UTF8
        Write-Host "Backup -> $BackupPath" -ForegroundColor DarkGray
    }

    function Set-Reg($Path,$Name,$Type,$Value) {
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        if ($Type -eq 'Binary') { $Value = [byte[]]$Value }
        New-ItemProperty -Path $Path -Name $Name -PropertyType $Type -Value $Value -Force | Out-Null
    }

    function Apply-Settings {
        Backup-Current
        foreach ($s in $Settings) {
            try { Set-Reg $s.Path $s.Name $s.Type $s.Apply; Write-Host ("  set  {0}" -f $s.Name) -ForegroundColor DarkGray }
            catch { Write-Warning ("FAILED {0}: {1}" -f $s.Name, $_.Exception.Message) }
        }
        Write-Host "Applied: thumbnails + smooth fonts ON, rest OFF." -ForegroundColor Green
    }

    function Revert-Settings {
        if (-not (Test-Path $BackupPath)) { Write-Warning "No backup at $BackupPath"; return }
        $data = Get-Content $BackupPath -Raw | ConvertFrom-Json
        foreach ($s in $data) {
            try {
                if ($s.Existed) {
                    $v = $s.Value
                    if ($s.Type -eq 'Binary') { $v = [byte[]]($v | ForEach-Object {[byte]$_}) }
                    Set-Reg $s.Path $s.Name $s.Type $v
                } else {
                    Remove-ItemProperty -Path $s.Path -Name $s.Name -ErrorAction SilentlyContinue
                }
            } catch { Write-Warning ("Skip {0}: {1}" -f $s.Name, $_.Exception.Message) }
        }
        Write-Host "Reverted." -ForegroundColor Yellow
    }

    function Refresh-LiveSettings {
        try { Start-Process rundll32.exe 'user32.dll,UpdatePerUserSystemParameters 1, True' -WindowStyle Hidden -Wait } catch {}
    }

    function Show-Verify {
        Write-Host "`n--- current values ---" -ForegroundColor Cyan
        foreach ($s in $Settings) {
            try {
                $v = (Get-ItemProperty -Path $s.Path -Name $s.Name -ErrorAction Stop).$($s.Name)
                if ($v -is [byte[]]) { $v = ($v | ForEach-Object { '{0:X2}' -f $_ }) -join ' ' }
                Write-Host ("  {0,-26} = {1}" -f $s.Name, $v)
            } catch {
                Write-Host ("  {0,-26} = <missing>" -f $s.Name) -ForegroundColor DarkYellow
            }
        }
    }

    try {
        if ($Revert) { Revert-Settings } else { Apply-Settings }
        Refresh-LiveSettings
        Show-Verify
        if ($RestartExplorer) {
            Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
            Start-Sleep -Milliseconds 600
            if (-not (Get-Process explorer -ErrorAction SilentlyContinue)) { Start-Process explorer }
            Write-Host "`nExplorer restarted." -ForegroundColor DarkGray
        } else {
            Write-Host "`nClose & reopen Performance Options to see it. Sign out/in (or -RestartExplorer) applies the rest." -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Host "`nERROR: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host $_.ScriptStackTrace -ForegroundColor DarkRed
    }

    if (-not $NoPause) { Read-Host "`nDone. Press Enter to close" }
}

# ===========================================================================
#  TOOL 2 - Input God Mode  (HKCU no admin; admin unlocks extra section)
# ===========================================================================
function Invoke-Input {
    [CmdletBinding()]
    param(
        [switch]$Revert,
        [switch]$Status,
        [switch]$NoPause,
        [string]$BackupPath         = (Join-Path $env:USERPROFILE 'Input-GodMode.backup.json'),
        [string]$PowerBackupPath    = (Join-Path $env:USERPROFILE 'Input-GodMode.power.json'),
        [string]$DevPowerBackupPath = (Join-Path $env:USERPROFILE 'Input-GodMode.devpower.json')
    )

    function Write-Step  ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok    ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2 ($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad   ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Head  ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    $spiSig = @'
using System;
using System.Runtime.InteropServices;
public static class SPI {
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool SystemParametersInfo(uint a, uint u, int[] p, uint w);
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool SystemParametersInfo(uint a, uint u, IntPtr p, uint w);
}
'@
    if (-not ('SPI' -as [type])) { Add-Type -TypeDefinition $spiSig }

    $SPI_SETMOUSE          = 0x0004
    $SPI_SETMOUSESPEED     = 0x0071
    $SPI_SETMOUSETRAILS    = 0x005D
    $SPI_SETKEYBOARDSPEED  = 0x000B
    $SPI_SETKEYBOARDDELAY  = 0x0017
    $SPIF_UPDATE           = 0x03

    $Tweaks = @(
        @{ Path='HKCU:\Control Panel\Mouse'; Name='MouseSensitivity'; Type='String'; Value='10' }
        @{ Path='HKCU:\Control Panel\Mouse'; Name='MouseSpeed';       Type='String'; Value='0'  }
        @{ Path='HKCU:\Control Panel\Mouse'; Name='MouseThreshold1';  Type='String'; Value='0'  }
        @{ Path='HKCU:\Control Panel\Mouse'; Name='MouseThreshold2';  Type='String'; Value='0'  }
        @{ Path='HKCU:\Control Panel\Mouse'; Name='MouseTrails';      Type='String'; Value='0'  }
        @{ Path='HKCU:\Control Panel\Mouse'; Name='MouseHoverTime';   Type='String'; Value='8'  }
        @{ Path='HKCU:\Control Panel\Mouse'; Name='SmoothMouseXCurve'; Type='Binary'; Value=@(
            0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
            0xC0,0xCC,0x0C,0x00,0x00,0x00,0x00,0x00,
            0x80,0x99,0x19,0x00,0x00,0x00,0x00,0x00,
            0x40,0x66,0x26,0x00,0x00,0x00,0x00,0x00,
            0x00,0x33,0x33,0x00,0x00,0x00,0x00,0x00) }
        @{ Path='HKCU:\Control Panel\Mouse'; Name='SmoothMouseYCurve'; Type='Binary'; Value=@(
            0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
            0x00,0x00,0x38,0x00,0x00,0x00,0x00,0x00,
            0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00,
            0x00,0x00,0xA8,0x00,0x00,0x00,0x00,0x00,
            0x00,0x00,0xE0,0x00,0x00,0x00,0x00,0x00) }
        @{ Path='HKCU:\Control Panel\Keyboard'; Name='KeyboardDelay'; Type='String'; Value='0'  }
        @{ Path='HKCU:\Control Panel\Keyboard'; Name='KeyboardSpeed'; Type='String'; Value='31' }
        @{ Path='HKCU:\Control Panel\Desktop'; Name='MenuShowDelay'; Type='String'; Value='0' }
        @{ Path='HKCU:\Control Panel\Accessibility\StickyKeys';        Name='Flags'; Type='String'; Value='506' }
        @{ Path='HKCU:\Control Panel\Accessibility\Keyboard Response'; Name='Flags'; Type='String'; Value='122' }
        @{ Path='HKCU:\Control Panel\Accessibility\ToggleKeys';        Name='Flags'; Type='String'; Value='58'  }
    )

    $AdminTweaks = @(
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters'; Name='MouseDataQueueSize';    Type='DWord'; Value=50 }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters'; Name='KeyboardDataQueueSize'; Type='DWord'; Value=50 }
    )

    function Get-RegSnapshot {
        param($Path,$Name)
        $out = @{ Path=$Path; Name=$Name; Existed=$false; Type=$null; Value=$null }
        if (Test-Path $Path) {
            $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
            if ($null -ne $item -and ($item.PSObject.Properties.Name -contains $Name)) {
                $raw = $item.$Name
                $out.Existed = $true
                if ($raw -is [byte[]]) {
                    $out.Type  = 'Binary'
                    $out.Value = [Convert]::ToBase64String($raw)
                } else {
                    $out.Type  = 'String'
                    $out.Value = [string]$raw
                }
            }
        }
        return $out
    }

    function Set-RegValue {
        param($Path,$Name,$Type,$Value)
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        switch ($Type) {
            'Binary' { $bytes = [byte[]]$Value
                       New-ItemProperty -Path $Path -Name $Name -PropertyType Binary -Value $bytes -Force | Out-Null }
            'DWord'  { New-ItemProperty -Path $Path -Name $Name -PropertyType DWord  -Value ([int]$Value) -Force | Out-Null }
            default  { New-ItemProperty -Path $Path -Name $Name -PropertyType String -Value ([string]$Value) -Force | Out-Null }
        }
    }

    function Apply-Live {
        try { [void][SPI]::SystemParametersInfo($SPI_SETMOUSE,         0,  @(0,0,0),        $SPIF_UPDATE) } catch { Write-Warn2 "SPI mouse-accel skipped: $($_.Exception.Message)" }
        try { [void][SPI]::SystemParametersInfo($SPI_SETMOUSESPEED,    0,  [IntPtr]10,      $SPIF_UPDATE) } catch { Write-Warn2 "SPI mouse-speed skipped: $($_.Exception.Message)" }
        try { [void][SPI]::SystemParametersInfo($SPI_SETMOUSETRAILS,   0,  [IntPtr]::Zero,  $SPIF_UPDATE) } catch { Write-Warn2 "SPI mouse-trails skipped: $($_.Exception.Message)" }
        try { [void][SPI]::SystemParametersInfo($SPI_SETKEYBOARDSPEED, 31, [IntPtr]::Zero,  $SPIF_UPDATE) } catch { Write-Warn2 "SPI kbd-speed skipped: $($_.Exception.Message)" }
        try { [void][SPI]::SystemParametersInfo($SPI_SETKEYBOARDDELAY, 0,  [IntPtr]::Zero,  $SPIF_UPDATE) } catch { Write-Warn2 "SPI kbd-delay skipped: $($_.Exception.Message)" }
    }

    $USB_SUB = '2a737441-1930-4402-8d77-b2bebba308a3'
    $USB_SS  = '48e6b7a6-50f5-4782-a5d4-53bb8f07e226'

    function Get-UsbSuspendState {
        $q = (powercfg /query SCHEME_CURRENT $USB_SUB $USB_SS) 2>$null | Out-String
        $ac = if ($q -match 'Current AC Power Setting Index:\s*0x([0-9A-Fa-f]+)') { [Convert]::ToInt32($Matches[1],16) } else { 1 }
        $dc = if ($q -match 'Current DC Power Setting Index:\s*0x([0-9A-Fa-f]+)') { [Convert]::ToInt32($Matches[1],16) } else { 1 }
        return @{ AC=$ac; DC=$dc }
    }

    function Set-UsbSuspend {
        param([int]$AC,[int]$DC)
        powercfg /setacvalueindex SCHEME_CURRENT $USB_SUB $USB_SS $AC | Out-Null
        powercfg /setdcvalueindex SCHEME_CURRENT $USB_SUB $USB_SS $DC | Out-Null
        powercfg /setactive SCHEME_CURRENT | Out-Null
    }

    function Get-InputPmInstanceNames {
        $ids = @()
        try { $ids = Get-PnpDevice -PresentOnly -Class Mouse,Keyboard -ErrorAction Stop |
                     Select-Object -ExpandProperty InstanceId } catch { }
        $names = @()
        try {
            $pm = Get-CimInstance -Namespace root/wmi -ClassName MSPower_DeviceEnable -ErrorAction Stop
            foreach ($p in $pm) {
                foreach ($id in $ids) {
                    if ($p.InstanceName.ToString().StartsWith($id, [System.StringComparison]::OrdinalIgnoreCase)) {
                        $names += $p.InstanceName; break
                    }
                }
            }
        } catch { }
        return ($names | Select-Object -Unique)
    }

    function Set-DevPowerEnable {
        param([string]$InstanceName,[bool]$Value)
        $done = $false
        try {
            $ci = Get-CimInstance -Namespace root/wmi -ClassName MSPower_DeviceEnable -ErrorAction Stop |
                  Where-Object { $_.InstanceName -eq $InstanceName } | Select-Object -First 1
            if ($ci) { Set-CimInstance -InputObject $ci -Property @{ Enable = $Value } -ErrorAction Stop; $done = $true }
        } catch { }
        if (-not $done -and (Get-Command Get-WmiObject -ErrorAction SilentlyContinue)) {
            try {
                $wo = Get-WmiObject -Namespace root\wmi -Class MSPower_DeviceEnable -ErrorAction Stop |
                      Where-Object { $_.InstanceName -eq $InstanceName } | Select-Object -First 1
                if ($wo) { $wo.Enable = $Value; [void]$wo.Put(); $done = $true }
            } catch { }
        }
        return $done
    }

    function Disable-InputDevicePowerOff {
        $names = Get-InputPmInstanceNames
        if (-not $names) { Write-Warn2 "No power-manageable mouse/keyboard instances exposed (normal for some devices)."; return }
        if (-not (Test-Path $DevPowerBackupPath)) {
            $pm  = Get-CimInstance -Namespace root/wmi -ClassName MSPower_DeviceEnable -ErrorAction SilentlyContinue
            $bak = foreach ($n in $names) {
                $cur = ($pm | Where-Object { $_.InstanceName -eq $n } | Select-Object -First 1).Enable
                @{ InstanceName = $n; Enable = [bool]$cur }
            }
            $bak | ConvertTo-Json | Set-Content $DevPowerBackupPath -Encoding UTF8
        }
        foreach ($n in $names) {
            $short = ($n -split '\\')[1]
            if (Set-DevPowerEnable -InstanceName $n -Value $false) { Write-Ok "Power-off disabled: $short" }
            else { Write-Warn2 "Couldn't update: $short" }
        }
    }

    function Restore-InputDevicePowerOff {
        if (-not (Test-Path $DevPowerBackupPath)) { return }
        $bak = Get-Content $DevPowerBackupPath -Raw | ConvertFrom-Json
        foreach ($b in $bak) {
            $short = ($b.InstanceName -split '\\')[1]
            if (Set-DevPowerEnable -InstanceName $b.InstanceName -Value ([bool]$b.Enable)) {
                Write-Ok "Restored power setting: $short"
            }
        }
        Remove-Item $DevPowerBackupPath -ErrorAction SilentlyContinue
    }

    function Invoke-GodMode {
        Write-Head "INPUT GOD MODE  -  applying"
        if (Test-Path $BackupPath) {
            Write-Warn2 "Existing backup found -> keeping it as the restore point."
            Write-Warn2 $BackupPath
        } else {
            Write-Step "Backing up current settings..."
            $snapshot = @()
            foreach ($t in ($Tweaks + $AdminTweaks)) { $snapshot += Get-RegSnapshot -Path $t.Path -Name $t.Name }
            $snapshot | ConvertTo-Json -Depth 5 | Set-Content -Path $BackupPath -Encoding UTF8
            Write-Ok "Backup saved -> $BackupPath"
        }

        Write-Step "Tuning mouse & keyboard..."
        foreach ($t in $Tweaks) {
            try { Set-RegValue @t; Write-Ok ("{0,-22} = {1}" -f $t.Name, ($(if($t.Type -eq 'Binary'){'<linear curve>'}else{$t.Value}))) }
            catch { Write-Bad "$($t.Name): $($_.Exception.Message)" }
        }

        if (Test-Admin) {
            Write-Step "Admin detected -> applying data-queue tuning..."
            foreach ($t in $AdminTweaks) {
                try { Set-RegValue @t; Write-Ok ("{0,-22} = {1}" -f $t.Name, $t.Value) }
                catch { Write-Bad "$($t.Name): $($_.Exception.Message)" }
            }
            Write-Warn2 "Data-queue changes need a reboot to load."

            if (-not (Test-Path $PowerBackupPath)) {
                (Get-UsbSuspendState) | ConvertTo-Json | Set-Content $PowerBackupPath -Encoding UTF8
            }
            Set-UsbSuspend -AC 0 -DC 0
            Write-Ok "USB selective suspend = OFF (input devices stay always-on)"

            Write-Step "Disabling device power-off on mouse & keyboard..."
            Disable-InputDevicePowerOff
        } else {
            Write-Warn2 "Not admin -> skipped data-queue + USB-suspend section (run as admin to include)."
        }

        Write-Step "Pushing changes into the live session..."
        Apply-Live
        Write-Ok "Mouse & keyboard updated instantly (no logoff needed)."

        Write-Host ""
        Write-Host "  ############################################################" -ForegroundColor Green
        Write-Host "  #                                                          #" -ForegroundColor Green
        Write-Host "  #              GOD MODE ACTIVATED - SUCCESS                #" -ForegroundColor Green
        Write-Host "  #                                                          #" -ForegroundColor Green
        Write-Host "  ############################################################" -ForegroundColor Green
        if (-not (Test-Admin)) {
            Write-Host ""
            Write-Warn2 "Ran WITHOUT admin: core mouse/keyboard tweaks ARE active,"
            Write-Warn2 "but USB-suspend + device power-off were skipped."
            Write-Warn2 "For the full set: re-run in an Administrator PowerShell."
        }
        Write-Host ""
        Write-Host "  Verifying what is live right now..." -ForegroundColor Gray
        Invoke-StatusInner
    }

    function Invoke-Revert {
        Write-Head "INPUT GOD MODE  -  reverting"
        if (-not (Test-Path $BackupPath)) {
            Write-Bad "No backup found at $BackupPath - nothing to restore."
            return
        }
        $snapshot = Get-Content $BackupPath -Raw | ConvertFrom-Json
        foreach ($s in $snapshot) {
            try {
                if ($s.Existed) {
                    if ($s.Type -eq 'Binary') {
                        $bytes = [Convert]::FromBase64String($s.Value)
                        Set-RegValue -Path $s.Path -Name $s.Name -Type 'Binary' -Value $bytes
                    } else {
                        Set-RegValue -Path $s.Path -Name $s.Name -Type 'String' -Value $s.Value
                    }
                    Write-Ok "Restored $($s.Name)"
                } else {
                    if (Test-Path $s.Path) {
                        Remove-ItemProperty -Path $s.Path -Name $s.Name -ErrorAction SilentlyContinue
                    }
                    Write-Ok "Removed $($s.Name) (was not set originally)"
                }
            } catch { Write-Bad "$($s.Name): $($_.Exception.Message)" }
        }

        Apply-Live

        if ((Test-Path $PowerBackupPath) -and (Test-Admin)) {
            $p = Get-Content $PowerBackupPath -Raw | ConvertFrom-Json
            Set-UsbSuspend -AC ([int]$p.AC) -DC ([int]$p.DC)
            Remove-Item $PowerBackupPath -ErrorAction SilentlyContinue
            Write-Ok "USB selective suspend restored (AC=$($p.AC) DC=$($p.DC))"
        } elseif (Test-Path $PowerBackupPath) {
            Write-Warn2 "USB-suspend backup exists but not admin -> run -Revert as admin to restore it."
        }

        if ((Test-Path $DevPowerBackupPath) -and (Test-Admin)) {
            Restore-InputDevicePowerOff
        } elseif (Test-Path $DevPowerBackupPath) {
            Write-Warn2 "Device-power backup exists but not admin -> run -Revert as admin to restore it."
        }

        Write-Warn2 "Note: your original mouse-speed notch is restored in the registry;"
        Write-Warn2 "open Settings > Mouse once if it doesn't refresh, or sign out/in."
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-Head "REVERT COMPLETE"
        Write-Host ""
    }

    function Invoke-StatusInner {
        Write-Head "INPUT GOD MODE  -  status"
        $check = @(
            @{ P='HKCU:\Control Panel\Mouse';    N='MouseSpeed';      Want='0';  Label='Mouse accel off' }
            @{ P='HKCU:\Control Panel\Mouse';    N='MouseSensitivity';Want='10'; Label='1:1 sensitivity (6/11)' }
            @{ P='HKCU:\Control Panel\Mouse';    N='MouseTrails';     Want='0';  Label='Pointer trails off' }
            @{ P='HKCU:\Control Panel\Keyboard'; N='KeyboardDelay';   Want='0';  Label='Repeat delay shortest' }
            @{ P='HKCU:\Control Panel\Keyboard'; N='KeyboardSpeed';   Want='31'; Label='Repeat rate fastest' }
            @{ P='HKCU:\Control Panel\Desktop';  N='MenuShowDelay';   Want='0';  Label='Instant menus' }
            @{ P='HKCU:\Control Panel\Accessibility\StickyKeys';        N='Flags'; Want='506'; Label='Sticky keys off' }
            @{ P='HKCU:\Control Panel\Accessibility\Keyboard Response'; N='Flags'; Want='122'; Label='Filter keys off' }
            @{ P='HKCU:\Control Panel\Accessibility\ToggleKeys';        N='Flags'; Want='58';  Label='Toggle keys off' }
        )
        foreach ($c in $check) {
            $cur = (Get-ItemProperty -Path $c.P -Name $c.N -ErrorAction SilentlyContinue).$($c.N)
            if ("$cur" -eq $c.Want) { Write-Ok ("{0,-26} OK" -f $c.Label) }
            else { Write-Bad ("{0,-26} (is '{1}', want '{2}')" -f $c.Label, $cur, $c.Want) }
        }
        $u = Get-UsbSuspendState
        if ($u.AC -eq 0 -and $u.DC -eq 0) { Write-Ok ("{0,-26} OFF" -f 'USB selective suspend') }
        else { Write-Warn2 ("{0,-26} on (AC={1} DC={2}) - run as admin to disable" -f 'USB selective suspend', $u.AC, $u.DC) }

        $names = Get-InputPmInstanceNames
        if ($names) {
            $pm = Get-CimInstance -Namespace root/wmi -ClassName MSPower_DeviceEnable -ErrorAction SilentlyContinue
            $allOff = $true
            foreach ($n in $names) {
                if (($pm | Where-Object { $_.InstanceName -eq $n } | Select-Object -First 1).Enable) { $allOff = $false }
            }
            if ($allOff) { Write-Ok ("{0,-26} OFF (always-on)" -f 'Device power-off') }
            else { Write-Warn2 ("{0,-26} on for some devices - run as admin to disable" -f 'Device power-off') }
        } else {
            Write-Warn2 ("{0,-26} not exposed by your devices" -f 'Device power-off')
        }
        Write-Host ""
    }

    function Pause-Window {
        param([string]$Msg = "Press ENTER to close")
        if ($NoPause) { return }
        Write-Host ""
        [void](Read-Host "  $Msg")
    }

    if ($Status) {
        Invoke-StatusInner
        Pause-Window
    }
    elseif ($Revert) {
        Invoke-Revert
        Pause-Window
    }
    else {
        Invoke-GodMode
        if (-not $NoPause) {
            Write-Host ""
            $ans = Read-Host "  Keep god mode? Press ENTER to KEEP, or type R then ENTER to REVERT now"
            if ($ans -match '^[Rr]') {
                Invoke-Revert
                Pause-Window
            } else {
                Write-Host "  God mode kept active. Re-run with -Revert anytime to undo." -ForegroundColor Gray
                Pause-Window
            }
        }
    }
}

# ===========================================================================
#  TOOL 3 - PowerPlan God Mode  (admin)
# ===========================================================================
function Invoke-PowerPlan {
    param([switch]$Enforce, [switch]$ApplyNow, [switch]$RevertNow)

    if (-not (Test-Admin)) {
        Restart-Elevated -ToolName 'PowerPlan' -Extra @{ Enforce = $Enforce; ApplyNow = $ApplyNow; RevertNow = $RevertNow }
        return
    }

    $PlanName = "GOD MODE"
    $PlanDesc = "Ultimate gaming performance - max CPU, no parking, no sleep, low latency"

    $ULTIMATE = "e9a42b02-d5df-448d-aa00-03f14749eb61"
    $HIGHPERF = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
    $BALANCED = "381b4222-f694-41f0-9685-ff5bb260df2e"

    $CPMINCORES  = "0cc5b647-c1df-4637-891a-dec35c318583"
    $CPMAXCORES  = "ea062031-0e34-4ff1-9b6d-eb1059334028"
    $PERFAUTON   = "8baa4a8a-14c6-4451-8e8b-14bdbd197537"
    $PERFEPP     = "36687f9e-e3a5-4dbf-b1dc-15eb381c6863"
    $PROCFREQMAX = "75b0ae3f-bce0-45a7-8c89-c9611c25e100"
    $DISTRIBUTE  = "4bdaf4e9-d103-46d7-a5f0-6280121616ef"

    $guidRegex = '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'

    $TaskName = "GodModeEnforce"
    $LockDir  = "$env:ProgramData\GodMode"
    $LockCopy = Join-Path $LockDir "WinToolbox.ps1"

    function Write-Step($msg, $color = "Gray") { Write-Host "  $msg" -ForegroundColor $color }

    function Get-ActiveGuid {
        if ((powercfg /getactivescheme) -match $guidRegex) { return $matches[0] }
        return $null
    }

    function Get-GodModeGuid {
        foreach ($line in (powercfg /list)) {
            if ($line -match [regex]::Escape($PlanName) -and $line -match $guidRegex) {
                return $matches[0]
            }
        }
        return $null
    }

    function Remove-GodMode {
        $active = Get-ActiveGuid
        foreach ($line in (powercfg /list)) {
            if ($line -match [regex]::Escape($PlanName) -and $line -match $guidRegex) {
                $g = $matches[0]
                if ($g -eq $active) { powercfg /setactive $BALANCED 2>$null | Out-Null }
                powercfg -delete $g 2>$null | Out-Null
            }
        }
    }

    function Set-Both($guid, $sub, $setting, $value) {
        powercfg -setacvalueindex $guid $sub $setting $value 2>$null | Out-Null
        powercfg -setdcvalueindex $guid $sub $setting $value 2>$null | Out-Null
    }

    function Pause-Menu {
        Write-Host "`nPress any key to return to menu..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }

    function Build-GodMode {
        Write-Host "`n=== BUILDING GOD MODE ===" -ForegroundColor Cyan
        Remove-GodMode

        $guid = $null
        foreach ($pair in @(@($ULTIMATE,"Ultimate Performance"), @($HIGHPERF,"High Performance"))) {
            $out = powercfg -duplicatescheme $pair[0] 2>$null
            if ($out -match $guidRegex) {
                $guid = $matches[0]
                Write-Step "Base = $($pair[1]) -> $guid" "Green"
                break
            }
        }
        if (-not $guid) { Write-Host "No base scheme to clone. Aborting." -ForegroundColor Red; return $null }

        powercfg -changename $guid "$PlanName" "$PlanDesc" | Out-Null
        Write-Step "Applying max-performance settings (AC + battery)..." "Yellow"

        Set-Both $guid SUB_PROCESSOR PROCTHROTTLEMIN   100
        Set-Both $guid SUB_PROCESSOR PROCTHROTTLEMAX   100
        Set-Both $guid SUB_PROCESSOR PERFBOOSTMODE     2
        Set-Both $guid SUB_PROCESSOR PERFBOOSTPOL      100
        Set-Both $guid SUB_PROCESSOR PERFINCPOL        2
        Set-Both $guid SUB_PROCESSOR PERFINCTHRESHOLD  10
        Set-Both $guid SUB_PROCESSOR PERFDECTHRESHOLD  8
        Set-Both $guid SUB_PROCESSOR LATENCYHINTPERF   99
        Set-Both $guid SUB_PROCESSOR SYSCOOLPOL        1
        Set-Both $guid SUB_PROCESSOR $PERFAUTON   0
        Set-Both $guid SUB_PROCESSOR $PERFEPP     0
        Set-Both $guid SUB_PROCESSOR $PROCFREQMAX 0
        Set-Both $guid SUB_PROCESSOR $DISTRIBUTE  0
        Set-Both $guid SUB_PROCESSOR $CPMINCORES  100
        Set-Both $guid SUB_PROCESSOR $CPMAXCORES  100
        Set-Both $guid SUB_PROCESSOR HETEROGENEOUSPOLICY 0
        Set-Both $guid SUB_DISK  DISKIDLE       0
        Set-Both $guid SUB_SLEEP STANDBYIDLE    0
        Set-Both $guid SUB_SLEEP HIBERNATEIDLE  0
        Set-Both $guid SUB_SLEEP HYBRIDSLEEP    0
        Set-Both $guid SUB_USB        USBSETTING 0
        Set-Both $guid SUB_PCIEXPRESS ASPM       0
        Set-Both $guid SUB_VIDEO      VIDEOIDLE  0

        powercfg -setactive $guid | Out-Null
        Write-Host "`nGOD MODE ACTIVE" -ForegroundColor Green
        Write-Step "CPU now holds full clocks - keep an eye on temps." "DarkGray"
        return $guid
    }

    function Invoke-LockGodModeOnly {
        $guid = Get-GodModeGuid
        if (-not $guid) { $guid = Build-GodMode; if (-not $guid) { return $null } }
        powercfg /setactive $guid | Out-Null
        foreach ($line in (powercfg /list)) {
            if ($line -match $guidRegex) {
                $g = $matches[0]
                if ($g -ne $guid) { powercfg -delete $g 2>$null | Out-Null }
            }
        }
        return $guid
    }

    function Enable-Blocker {
        New-Item -ItemType Directory -Force -Path $LockDir | Out-Null
        if ($PSCommandPath -ne $LockCopy) { Copy-Item -LiteralPath $PSCommandPath -Destination $LockCopy -Force }

        $action = New-ScheduledTaskAction -Execute "powershell.exe" `
            -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$LockCopy`" -Enforce"
        $trigger   = New-ScheduledTaskTrigger -AtStartup
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
        Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger `
            -Principal $principal -Settings $settings -Force | Out-Null
    }

    function Disable-Blocker {
        if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        }
        if (Test-Path $LockDir) { Remove-Item -LiteralPath $LockDir -Recurse -Force -ErrorAction SilentlyContinue }
    }

    # silent path used by the startup task
    if ($Enforce) { Invoke-LockGodModeOnly | Out-Null; return }

    function Invoke-FullLockdown {
        Write-Host "`n=== FULL LOCKDOWN ===" -ForegroundColor Cyan
        $guid = Invoke-LockGodModeOnly
        if (-not $guid) { return }
        Write-Step "GOD MODE is the only power plan." "Green"

        Enable-Blocker
        Write-Step "Recreate-blocker installed (auto-deletes returning plans at startup)." "Green"

        powercfg /hibernate off | Out-Null
        Write-Step "Hibernate OFF (disk freed, Fast Startup off)." "Green"

        Write-Host "`nLOCKED. GOD MODE only, blocked from recreation, survives restart." -ForegroundColor Green
        Write-Step "Undo all of this anytime with option 1." "DarkGray"
    }

    function Invoke-RevertPower {
        Write-Host "`n=== REVERT ===" -ForegroundColor Cyan
        Disable-Blocker
        Write-Step "Recreate-blocker removed." "Green"

        powercfg /hibernate on | Out-Null
        Write-Step "Hibernate ON." "Green"

        powercfg /setactive $BALANCED 2>$null | Out-Null
        Remove-GodMode
        powercfg /restoredefaultschemes | Out-Null
        powercfg /setactive $BALANCED | Out-Null
        Write-Host "`nEverything reverted. Windows defaults restored (Balanced active)." -ForegroundColor Green
    }

    function Show-PowerMenu {
        Clear-Host
        $name = "Unknown"
        $g = powercfg /getactivescheme
        if ($g -match '\((.+)\)') { $name = $matches[1] }
        $blocked = if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) { "ON" } else { "off" }

        Write-Host "================================================" -ForegroundColor DarkCyan
        Write-Host "             GOD MODE  POWER PLAN" -ForegroundColor Green
        Write-Host "================================================" -ForegroundColor DarkCyan
        Write-Host "  Active plan:      $name" -ForegroundColor White
        Write-Host "  Recreate-blocker: $blocked" -ForegroundColor White
        Write-Host ""
        Write-Host "   1.  Revert  (undo everything)" -ForegroundColor White
        Write-Host "   2.  Activate GOD MODE" -ForegroundColor White
        Write-Host "   3.  FULL LOCKDOWN  (only GOD MODE, blocked, hibernate off)" -ForegroundColor White
        Write-Host "   Q.  Quit" -ForegroundColor DarkGray
        Write-Host ""
    }

    # non-interactive paths for the orchestrators (Profile / Revert-All)
    if ($RevertNow) { Invoke-RevertPower; return }
    if ($ApplyNow)  { Build-GodMode | Out-Null; return }

    do {
        Show-PowerMenu
        $choice = Read-Host "  Select"
        switch ($choice.ToUpper()) {
            "1" { Invoke-RevertPower;       Pause-Menu }
            "2" { Build-GodMode | Out-Null; Pause-Menu }
            "3" { Invoke-FullLockdown;      Pause-Menu }
            "Q" { }
            default { Write-Host "  Invalid choice." -ForegroundColor Red; Start-Sleep 1 }
        }
    } while ($choice.ToUpper() -ne "Q")

    Write-Host "`nBye." -ForegroundColor DarkGray
}

# ===========================================================================
#  TOOL 4 - PageFile  (admin)
# ===========================================================================
function Invoke-PageFile {
    [CmdletBinding()]
    param(
        [int]$Initial = 8192,
        [int]$Maximum = 12288,
        [switch]$Revert
    )

    if (-not (Test-Admin)) {
        Restart-Elevated -ToolName 'PageFile' -Extra @{ Initial=$Initial; Maximum=$Maximum; Revert=$Revert }
        return
    }

    function Show-Current {
        $auto = (Get-WmiObject Win32_ComputerSystem).AutomaticManagedPagefile
        Write-Host "`nCurrent virtual memory state:" -ForegroundColor Cyan
        Write-Host ("  Auto-managed : {0}" -f $(if($auto){'YES (Windows-managed)'}else{'NO (custom)'}))
        $pf = Get-WmiObject Win32_PageFileSetting
        if ($pf) {
            foreach ($p in $pf) {
                Write-Host ("  {0}  ->  Initial {1} MB / Max {2} MB" -f $p.Name,$p.InitialSize,$p.MaximumSize)
            }
        } else {
            Write-Host "  (no explicit page file entry - sizes chosen by Windows)"
        }
    }

    $sysDrive = $env:SystemDrive
    $pfPath   = "$sysDrive\pagefile.sys"

    Write-Host "==========================================" -ForegroundColor DarkGray
    Write-Host "  PageFile-Set" -ForegroundColor White
    Write-Host "==========================================" -ForegroundColor DarkGray

    try {
        if ($Revert) {
            $cs = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
            if (-not $cs.AutomaticManagedPagefile) {
                $cs.AutomaticManagedPagefile = $true
                $cs.Put() | Out-Null
            }
            Get-WmiObject Win32_PageFileSetting | ForEach-Object { $_.Delete() }
            Write-Host "`n[OK] Restored automatic (Windows-managed) virtual memory." -ForegroundColor Green
        }
        else {
            if ($Maximum -lt $Initial) {
                Write-Host "`n[!] Maximum ($Maximum) is less than Initial ($Initial). Aborting." -ForegroundColor Red
                return
            }

            $cs = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
            if ($cs.AutomaticManagedPagefile) {
                $cs.AutomaticManagedPagefile = $false
                $cs.Put() | Out-Null
            }

            Get-WmiObject Win32_PageFileSetting | ForEach-Object { $_.Delete() }
            Set-WmiInstance -Class Win32_PageFileSetting -Arguments @{
                Name        = $pfPath
                InitialSize = $Initial
                MaximumSize = $Maximum
            } | Out-Null

            Write-Host ("`n[OK] Fixed page file set on {0}" -f $sysDrive) -ForegroundColor Green
            Write-Host ("     Initial {0} MB  /  Maximum {1} MB" -f $Initial,$Maximum) -ForegroundColor Green
        }

        Show-Current

        Write-Host "`n----------------------------------------" -ForegroundColor DarkGray
        Write-Host "  A REBOOT is required to apply changes." -ForegroundColor Yellow
        Write-Host "----------------------------------------" -ForegroundColor DarkGray
        $r = Read-Host "Reboot now? (y/N)"
        if ($r -match '^(y|yes)$') { Restart-Computer -Force }
    }
    catch {
        Write-Host "`n[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ===========================================================================
#  TOOL 5 - DriveLock  (admin)
# ===========================================================================
function Invoke-DriveLock {
    [CmdletBinding()]
    param(
        [switch]$Lock,
        [switch]$Unlock,
        [switch]$Status,
        [Alias("Revert")][switch]$Off,
        [string[]]$Drives
    )

    $userSpecified = $PSBoundParameters.ContainsKey('Drives') -and $Drives

    $Drives = $Drives |
        ForEach-Object { $_ -split "," } |
        ForEach-Object { $_.Trim().TrimEnd(":","\").ToUpper() } |
        Where-Object { $_ -match '^[A-Z]$' } |
        Select-Object -Unique

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Lock)            { $extra.Lock   = $true }
        if ($Unlock -or $Off) { $extra.Unlock = $true }
        if ($Status)          { $extra.Status = $true }
        if ($userSpecified)   { $extra.Drives = ($Drives -join ',') }
        Restart-Elevated -ToolName 'DriveLock' -Extra $extra
        return
    }

    if (-not $userSpecified -or -not $Drives) {
        $sys = ($env:SystemDrive).TrimEnd(':').ToUpper()
        $Drives = Get-Volume |
            Where-Object {
                $_.DriveLetter -and
                $_.DriveType -eq 'Fixed' -and
                ($_.DriveLetter.ToString().ToUpper() -ne $sys)
            } |
            ForEach-Object { $_.DriveLetter.ToString().ToUpper() } |
            Sort-Object -Unique
    }

    if (-not $Drives) {
        Write-Host "No drives found to work on (only the Windows drive exists)." -ForegroundColor Yellow
        Write-Host "Press Enter to close..." -ForegroundColor DarkGray
        [void](Read-Host); return
    }

    $account = "$env:USERDOMAIN\$env:USERNAME"

    function Lock-Drives {
        foreach ($d in $Drives) {
            $root = "${d}:\"
            if (-not (Test-Path $root)) {
                Write-Host "  [skip] $root does not exist" -ForegroundColor DarkGray
                continue
            }
            $res = icacls $root /deny "${account}:(OI)(CI)(WD,AD)" 2>&1
            if ($res -match 'write protected') {
                Write-Host "  [LOCKED]   $root  (already blocked at volume level - read-only)" -ForegroundColor Green
            } else {
                Write-Host "  [LOCKED]   $root  (no new files/folders, read still works)" -ForegroundColor Green
            }
        }
    }

    function Unlock-Drives {
        foreach ($d in $Drives) {
            $root = "${d}:\"
            if (-not (Test-Path $root)) {
                Write-Host "  [skip] $root does not exist" -ForegroundColor DarkGray
                continue
            }
            icacls $root /remove:d "$account" | Out-Null
            icacls $root /remove:d "Users"    | Out-Null
            icacls $root /remove:d "Everyone" | Out-Null
            $dp = "select volume $d`r`nattributes volume clear readonly`r`nexit"
            $dp | diskpart | Out-Null
            Write-Host "  [UNLOCKED] $root  (writing allowed again)" -ForegroundColor Cyan
        }
    }

    function Show-DriveStatus {
        foreach ($d in $Drives) {
            $root = "${d}:\"
            if (-not (Test-Path $root)) {
                Write-Host "  $root  ->  not present" -ForegroundColor DarkGray
                continue
            }
            $test = Join-Path $root ("._locktest_" + [guid]::NewGuid().ToString("N"))
            try {
                New-Item -Path $test -ItemType File -ErrorAction Stop | Out-Null
                Remove-Item $test -Force -ErrorAction SilentlyContinue
                Write-Host "  $root  ->  unlocked (writing works)" -ForegroundColor Gray
            } catch {
                Write-Host "  $root  ->  LOCKED (writing blocked)" -ForegroundColor Yellow
            }
        }
    }

    $header = "==== DriveLock  |  drives: $($Drives -join ', ')  |  user: $account ===="
    Write-Host ""
    Write-Host $header -ForegroundColor White

    if ($Lock) {
        Write-Host "Locking..."; Lock-Drives
    }
    elseif ($Unlock -or $Off) {
        Write-Host "Unlocking..."; Unlock-Drives
    }
    elseif ($Status) {
        Write-Host "Current status:"; Show-DriveStatus
    }
    else {
        do {
            Write-Host ""
            Write-Host "Current status:"
            Show-DriveStatus
            Write-Host ""
            Write-Host "  1  =  LOCK   (block adding files)"   -ForegroundColor Green
            Write-Host "  2  =  UNLOCK (allow adding files)"   -ForegroundColor Cyan
            Write-Host "  3  =  Status (check again)"          -ForegroundColor Gray
            Write-Host "  Q  =  Quit"                          -ForegroundColor DarkGray
            $choice = Read-Host "Choose"
            switch ($choice.ToUpper()) {
                "1" { Write-Host ""; Lock-Drives }
                "2" { Write-Host ""; Unlock-Drives }
                "3" { }
                "Q" { break }
                default { Write-Host "  Please type 1, 2, 3 or Q" -ForegroundColor Red }
            }
        } while ($choice.ToUpper() -ne "Q")
    }

    Write-Host ""
    Write-Host "Done." -ForegroundColor White
    Write-Host "Press Enter to close..." -ForegroundColor DarkGray
    [void](Read-Host)
}

# ===========================================================================
#  TOOL 6 - Browsers  (no admin)
# ===========================================================================
function Invoke-Browsers {
    [CmdletBinding()]
    param(
        [switch]$Chrome,
        [switch]$Brave
    )

    $ErrorActionPreference = 'Stop'
    $dest = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
    if (-not $dest) { $dest = Join-Path $env:USERPROFILE 'Downloads' }

    $browsers = @(
        [pscustomobject]@{ Name = 'Google Chrome'; Url = 'https://dl.google.com/chrome/install/latest/chrome_installer.exe'; File = 'ChromeInstaller.exe' }
        [pscustomobject]@{ Name = 'Brave Browser'; Url = 'https://laptop-updates.brave.com/latest/winx64';                  File = 'BraveInstaller.exe'  }
    )

    if ($Chrome -or $Brave) {
        $browsers = $browsers | Where-Object {
            ($Chrome -and $_.Name -eq 'Google Chrome') -or
            ($Brave  -and $_.Name -eq 'Brave Browser')
        }
    }

    function Get-Installer {
        param($Name, $Url, $File)
        $out = Join-Path $dest $File
        Write-Host "Downloading $Name ..." -ForegroundColor Cyan
        try {
            if (Get-Command Start-BitsTransfer -ErrorAction SilentlyContinue) {
                Start-BitsTransfer -Source $Url -Destination $out -DisplayName $Name -Description $File
            }
            else {
                Invoke-WebRequest -Uri $Url -OutFile $out -UseBasicParsing
            }
            Write-Host "  Saved to $out" -ForegroundColor Green
        }
        catch {
            Write-Host "  Failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    foreach ($b in $browsers) {
        Get-Installer -Name $b.Name -Url $b.Url -File $b.File
    }

    Write-Host "`nDone. Files are in $dest" -ForegroundColor Yellow
}

# ===========================================================================
#  TOOL 7 - WinSettings  (GUI; admin only for tz/lock screen)
# ===========================================================================
function Invoke-WinSettings {
    [CmdletBinding()]
    param(
        [switch]$Revert,
        [string]$WallpaperDir,
        [switch]$WinApply,           # silent embedded apply (dark on + transparency off)
        [switch]$WinDark,            # force dark mode only
        [switch]$WinTransparencyOff, # turn transparency off only
        [switch]$WinTimeZone,        # set Sri Lanka Standard Time
        [switch]$WinShowUi           # open the full interactive window (default when no flags)
    )

    if (-not $WallpaperDir) {
        if ($PSScriptRoot) { $WallpaperDir = $PSScriptRoot }
        else { $WallpaperDir = (Get-Location).Path }
    }

    $Script:BackupDir  = Join-Path $env:LOCALAPPDATA 'WinSettingsManager'
    $Script:BackupFile = Join-Path $Script:BackupDir 'backup.json'
    $Script:ThemeKey   = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    $Script:DeskKey    = 'HKCU:\Control Panel\Desktop'
    $Script:LockKey    = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'
    $Script:TimeZoneId = 'Sri Lanka Standard Time'
    $Script:ImageExt   = @('.png', '.jpg', '.jpeg', '.bmp', '.gif')

    if (-not ('Native' -as [type])) {
        Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class Native {
    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern IntPtr SendMessageTimeout(IntPtr hWnd, int Msg, IntPtr wParam,
        string lParam, int fuFlags, int uTimeout, out IntPtr lpdwResult);

    public const int SPI_SETDESKWALLPAPER = 0x0014;
    public const int SPIF_UPDATEINIFILE   = 0x01;
    public const int SPIF_SENDCHANGE      = 0x02;
    public const int HWND_BROADCAST       = 0xFFFF;
    public const int WM_SETTINGCHANGE     = 0x001A;
    public const int SMTO_ABORTIFHUNG     = 0x0002;
}
'@
    }

    function Test-IsAdmin {
        $id = [Security.Principal.WindowsIdentity]::GetCurrent()
        (New-Object Security.Principal.WindowsPrincipal $id).IsInRole(
            [Security.Principal.WindowsBuiltinRole]::Administrator)
    }

    function Get-RegDword {
        param([string]$Path, [string]$Name, [int]$Default)
        try { return [int](Get-ItemPropertyValue -Path $Path -Name $Name -ErrorAction Stop) }
        catch { return $Default }
    }

    function Get-RegString {
        param([string]$Path, [string]$Name)
        try { return [string](Get-ItemPropertyValue -Path $Path -Name $Name -ErrorAction Stop) }
        catch { return $null }
    }

    function Set-RegValue {
        param([string]$Path, [string]$Name, $Value, [string]$Type = 'DWord')
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
    }

    function Send-SettingChange {
        param([string]$LParam = 'ImmersiveColorSet')
        $r = [IntPtr]::Zero
        [Native]::SendMessageTimeout(
            [IntPtr][Native]::HWND_BROADCAST, [Native]::WM_SETTINGCHANGE,
            [IntPtr]::Zero, $LParam, [Native]::SMTO_ABORTIFHUNG, 2000, [ref]$r) | Out-Null
    }

    function Save-Backup {
        if (Test-Path $Script:BackupFile) { return }
        if (-not (Test-Path $Script:BackupDir)) {
            New-Item -ItemType Directory -Path $Script:BackupDir -Force | Out-Null
        }
        $lockPath = Get-RegString -Path $Script:LockKey -Name 'LockScreenImagePath'
        $snapshot = [ordered]@{
            Timestamp            = (Get-Date).ToString('s')
            TimeZoneId           = (Get-TimeZone).Id
            Wallpaper            = Get-RegString -Path $Script:DeskKey  -Name 'WallPaper'
            AppsUseLightTheme    = Get-RegDword  -Path $Script:ThemeKey -Name 'AppsUseLightTheme'   -Default 1
            SystemUsesLightTheme = Get-RegDword  -Path $Script:ThemeKey -Name 'SystemUsesLightTheme' -Default 1
            EnableTransparency   = Get-RegDword  -Path $Script:ThemeKey -Name 'EnableTransparency'  -Default 1
            LockScreenExisted    = [bool]$lockPath
            LockScreenImagePath  = $lockPath
        }
        $snapshot | ConvertTo-Json | Set-Content -Path $Script:BackupFile -Encoding UTF8
    }

    function Invoke-RevertAll {
        if (-not (Test-Path $Script:BackupFile)) {
            return 'No backup found - nothing to revert.'
        }
        $b = Get-Content $Script:BackupFile -Raw | ConvertFrom-Json

        Set-RegValue -Path $Script:ThemeKey -Name 'AppsUseLightTheme'    -Value $b.AppsUseLightTheme
        Set-RegValue -Path $Script:ThemeKey -Name 'SystemUsesLightTheme' -Value $b.SystemUsesLightTheme
        Set-RegValue -Path $Script:ThemeKey -Name 'EnableTransparency'   -Value $b.EnableTransparency

        if ($b.Wallpaper -and (Test-Path $b.Wallpaper)) {
            [Native]::SystemParametersInfo([Native]::SPI_SETDESKWALLPAPER, 0, $b.Wallpaper,
                [Native]::SPIF_UPDATEINIFILE -bor [Native]::SPIF_SENDCHANGE) | Out-Null
        }

        if (Test-Path $Script:LockKey) {
            if (-not $b.LockScreenExisted) {
                try {
                    Remove-ItemProperty -Path $Script:LockKey -Name 'LockScreenImagePath'   -ErrorAction SilentlyContinue
                    Remove-ItemProperty -Path $Script:LockKey -Name 'LockScreenImageStatus' -ErrorAction SilentlyContinue
                    Remove-ItemProperty -Path $Script:LockKey -Name 'LockScreenImageUrl'    -ErrorAction SilentlyContinue
                } catch { }
            } elseif ($b.LockScreenImagePath) {
                try { Set-RegValue -Path $Script:LockKey -Name 'LockScreenImagePath' -Value $b.LockScreenImagePath -Type String } catch { }
            }
        }

        try { Set-TimeZone -Id $b.TimeZoneId -ErrorAction Stop } catch { }

        Send-SettingChange
        Remove-Item $Script:BackupFile -Force -ErrorAction SilentlyContinue
        return "Reverted to settings captured $($b.Timestamp)."
    }

    function Set-Wallpaper {
        param([string]$Path)
        Save-Backup
        [Native]::SystemParametersInfo([Native]::SPI_SETDESKWALLPAPER, 0, $Path,
            [Native]::SPIF_UPDATEINIFILE -bor [Native]::SPIF_SENDCHANGE) | Out-Null
    }

    function Set-LockScreen {
        param([string]$Path)
        if (-not (Test-IsAdmin)) {
            throw 'Setting the lock screen requires running as Administrator.'
        }
        Save-Backup
        Set-RegValue -Path $Script:LockKey -Name 'LockScreenImageStatus' -Value 1
        Set-RegValue -Path $Script:LockKey -Name 'LockScreenImagePath' -Value $Path -Type String
        Set-RegValue -Path $Script:LockKey -Name 'LockScreenImageUrl'  -Value $Path -Type String
    }

    function Set-DisplayPrefs {
        param([bool]$DarkMode, [bool]$Transparency)
        Save-Backup
        $light = if ($DarkMode) { 0 } else { 1 }
        Set-RegValue -Path $Script:ThemeKey -Name 'AppsUseLightTheme'    -Value $light
        Set-RegValue -Path $Script:ThemeKey -Name 'SystemUsesLightTheme' -Value $light
        Set-RegValue -Path $Script:ThemeKey -Name 'EnableTransparency'   -Value ([int]$Transparency)
        Send-SettingChange
    }

    function Set-LocalTimeZone {
        if (-not (Test-IsAdmin)) {
            throw 'Changing the time zone requires running as Administrator.'
        }
        Save-Backup
        Set-TimeZone -Id $Script:TimeZoneId -ErrorAction Stop
    }

    function Restart-Explorer {
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 800
        if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) {
            Start-Process explorer.exe
        }
    }

    function Get-Wallpapers {
        if (-not (Test-Path $WallpaperDir)) { return @() }
        Get-ChildItem -Path $WallpaperDir -File -ErrorAction SilentlyContinue |
            Where-Object { $Script:ImageExt -contains $_.Extension.ToLower() } |
            Sort-Object Name | Select-Object -ExpandProperty Name
    }

    if ($Revert) {
        $msg = Invoke-RevertAll
        Write-Host $msg
        return
    }

    # ---- Silent embedded apply (used by the GUI batch / MAX) - no window ----
    $silent = ($WinApply -or $WinDark -or $WinTransparencyOff -or $WinTimeZone)
    if ($silent -and -not $WinShowUi) {
        Write-Host ""
        Write-Host "  [>] Windows Settings - applying gaming visual defaults (silent)..." -ForegroundColor Cyan
        # When only -WinApply is given, default to: dark ON + transparency OFF.
        $onlyApply = ($WinApply -and -not ($WinDark -or $WinTransparencyOff -or $WinTimeZone))
        $doDark  = ($WinDark            -or $onlyApply)
        $doTrans = ($WinTransparencyOff -or $onlyApply)
        try {
            Save-Backup
            if ($doDark) {
                Set-RegValue -Path $Script:ThemeKey -Name 'AppsUseLightTheme'    -Value 0
                Set-RegValue -Path $Script:ThemeKey -Name 'SystemUsesLightTheme' -Value 0
                Write-Host "  [+] Dark mode ON" -ForegroundColor Green
            }
            if ($doTrans) {
                Set-RegValue -Path $Script:ThemeKey -Name 'EnableTransparency' -Value 0
                Write-Host "  [+] Transparency effects OFF (perf)" -ForegroundColor Green
            }
            Send-SettingChange
        } catch { Write-Host "  [!] display prefs: $($_.Exception.Message)" -ForegroundColor Yellow }
        if ($WinTimeZone) {
            try { Set-LocalTimeZone; Write-Host "  [+] Time zone set to $Script:TimeZoneId" -ForegroundColor Green }
            catch { Write-Host "  [!] time zone (needs admin): $($_.Exception.Message)" -ForegroundColor Yellow }
        }
        Write-Host "  [i] Reversible with:  -Tool WinSettings -Revert" -ForegroundColor DarkGray
        Write-Host ""
        return
    }

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Windows Settings Manager'
    $form.Size = New-Object System.Drawing.Size(560, 560)
    $form.StartPosition = 'CenterScreen'
    $form.FormBorderStyle = 'FixedSingle'
    $form.MaximizeBox = $false

    function New-Group {
        param([string]$Text, [int]$Top, [int]$Height)
        $g = New-Object System.Windows.Forms.GroupBox
        $g.Text = $Text
        $g.Location = New-Object System.Drawing.Point(15, $Top)
        $g.Size = New-Object System.Drawing.Size(515, $Height)
        $form.Controls.Add($g)
        return $g
    }

    function New-Button {
        param($Parent, [string]$Text, [int]$X, [int]$Y, [int]$W = 150, [scriptblock]$OnClick)
        $b = New-Object System.Windows.Forms.Button
        $b.Text = $Text
        $b.Location = New-Object System.Drawing.Point($X, $Y)
        $b.Size = New-Object System.Drawing.Size($W, 28)
        $b.Add_Click($OnClick)
        $Parent.Controls.Add($b)
        return $b
    }

    $title = New-Object System.Windows.Forms.Label
    $title.Text = 'Windows Settings Manager'
    $title.Font = New-Object System.Drawing.Font('Segoe UI', 15, [System.Drawing.FontStyle]::Bold)
    $title.AutoSize = $true
    $title.Location = New-Object System.Drawing.Point(15, 12)
    $form.Controls.Add($title)

    $tzGroup = New-Group -Text 'Time Zone' -Top 50 -Height 70
    $tzLabel = New-Object System.Windows.Forms.Label
    $tzLabel.Text = "Target: $Script:TimeZoneId"
    $tzLabel.AutoSize = $true
    $tzLabel.Location = New-Object System.Drawing.Point(15, 25)
    $tzGroup.Controls.Add($tzLabel)
    New-Button -Parent $tzGroup -Text 'Apply Time Zone' -X 340 -Y 22 -W 160 -OnClick {
        try { Set-LocalTimeZone; Set-Status 'Time zone set to Sri Lanka Standard Time.' }
        catch { Set-Status "Time zone error: $($_.Exception.Message)" $true }
    } | Out-Null

    $wpGroup = New-Group -Text 'Wallpaper' -Top 130 -Height 130
    $wpLabel = New-Object System.Windows.Forms.Label
    $wpLabel.Text = 'Choose:'
    $wpLabel.AutoSize = $true
    $wpLabel.Location = New-Object System.Drawing.Point(15, 28)
    $wpGroup.Controls.Add($wpLabel)

    $wpCombo = New-Object System.Windows.Forms.ComboBox
    $wpCombo.Location = New-Object System.Drawing.Point(80, 24)
    $wpCombo.Size = New-Object System.Drawing.Size(420, 24)
    $wpCombo.DropDownStyle = 'DropDownList'
    $wpGroup.Controls.Add($wpCombo)

    function Update-WallpaperList {
        $wpCombo.Items.Clear()
        foreach ($w in Get-Wallpapers) { $wpCombo.Items.Add($w) | Out-Null }
        if ($wpCombo.Items.Count -gt 0) { $wpCombo.SelectedIndex = 0 }
    }

    function Get-SelectedWallpaperPath {
        if ($null -eq $wpCombo.SelectedItem) {
            Set-Status 'Select a wallpaper first.' $true; return $null
        }
        $p = Join-Path $WallpaperDir $wpCombo.SelectedItem
        if (-not (Test-Path $p)) { Set-Status 'Selected file not found.' $true; return $null }
        return $p
    }

    New-Button -Parent $wpGroup -Text 'Set as Background' -X 80 -Y 58 -OnClick {
        $p = Get-SelectedWallpaperPath
        if ($p) {
            try { Set-Wallpaper -Path $p; Set-Status "Background set to $($wpCombo.SelectedItem)." }
            catch { Set-Status "Background error: $($_.Exception.Message)" $true }
        }
    } | Out-Null
    New-Button -Parent $wpGroup -Text 'Set as Lock Screen' -X 240 -Y 58 -OnClick {
        $p = Get-SelectedWallpaperPath
        if ($p) {
            try { Set-LockScreen -Path $p; Set-Status "Lock screen set to $($wpCombo.SelectedItem)." }
            catch { Set-Status "Lock screen error: $($_.Exception.Message)" $true }
        }
    } | Out-Null
    New-Button -Parent $wpGroup -Text 'Add Custom...' -X 80 -Y 92 -OnClick {
        $dlg = New-Object System.Windows.Forms.OpenFileDialog
        $dlg.Filter = 'Image files|*.jpg;*.jpeg;*.png;*.bmp;*.gif'
        if ($dlg.ShowDialog() -eq 'OK') {
            try {
                $name = [IO.Path]::GetFileName($dlg.FileName)
                $dest = Join-Path $WallpaperDir $name
                $base = [IO.Path]::GetFileNameWithoutExtension($name)
                $ext  = [IO.Path]::GetExtension($name)
                $i = 1
                while (Test-Path $dest) {
                    $dest = Join-Path $WallpaperDir "$base`_$i$ext"; $i++
                }
                Copy-Item -Path $dlg.FileName -Destination $dest -Force
                Update-WallpaperList
                Set-Status "Added $([IO.Path]::GetFileName($dest))."
            } catch { Set-Status "Add error: $($_.Exception.Message)" $true }
        }
    } | Out-Null
    New-Button -Parent $wpGroup -Text 'Remove Selected' -X 240 -Y 92 -OnClick {
        if ($null -eq $wpCombo.SelectedItem) { Set-Status 'Select a wallpaper to remove.' $true; return }
        $sel = $wpCombo.SelectedItem
        $r = [System.Windows.Forms.MessageBox]::Show("Remove $sel? This cannot be undone.",
            'Confirm', 'YesNo', 'Warning')
        if ($r -eq 'Yes') {
            try {
                Remove-Item (Join-Path $WallpaperDir $sel) -Force
                Update-WallpaperList
                Set-Status "Removed $sel."
            } catch { Set-Status "Remove error: $($_.Exception.Message)" $true }
        }
    } | Out-Null

    $dpGroup = New-Group -Text 'Display' -Top 270 -Height 110
    $darkChk = New-Object System.Windows.Forms.CheckBox
    $darkChk.Text = 'Enable dark mode'
    $darkChk.AutoSize = $true
    $darkChk.Location = New-Object System.Drawing.Point(15, 28)
    $dpGroup.Controls.Add($darkChk)

    $transChk = New-Object System.Windows.Forms.CheckBox
    $transChk.Text = 'Enable transparency effects'
    $transChk.AutoSize = $true
    $transChk.Location = New-Object System.Drawing.Point(15, 52)
    $dpGroup.Controls.Add($transChk)

    New-Button -Parent $dpGroup -Text 'Apply Display' -X 340 -Y 70 -W 160 -OnClick {
        try {
            Set-DisplayPrefs -DarkMode $darkChk.Checked -Transparency $transChk.Checked
            Set-Status 'Display settings applied.'
        } catch { Set-Status "Display error: $($_.Exception.Message)" $true }
    } | Out-Null

    $sysGroup = New-Group -Text 'System' -Top 390 -Height 70
    New-Button -Parent $sysGroup -Text 'Restart Explorer' -X 15 -Y 25 -W 150 -OnClick {
        Set-Status 'Restarting Explorer...'; Restart-Explorer; Set-Status 'Explorer restarted.'
    } | Out-Null
    New-Button -Parent $sysGroup -Text 'Open Wallpaper Folder' -X 175 -Y 25 -W 160 -OnClick {
        if (Test-Path $WallpaperDir) { Start-Process explorer.exe $WallpaperDir }
    } | Out-Null
    $revertBtn = New-Button -Parent $sysGroup -Text 'Revert All' -X 345 -Y 25 -W 150 -OnClick {
        $r = [System.Windows.Forms.MessageBox]::Show(
            'Restore all settings to the snapshot taken before your first change?',
            'Revert All', 'YesNo', 'Question')
        if ($r -eq 'Yes') { Set-Status (Invoke-RevertAll) }
    }
    $revertBtn.ForeColor = [System.Drawing.Color]::DarkRed

    $status = New-Object System.Windows.Forms.Label
    $status.Location = New-Object System.Drawing.Point(15, 470)
    $status.Size = New-Object System.Drawing.Size(515, 40)
    $status.ForeColor = [System.Drawing.Color]::ForestGreen
    $form.Controls.Add($status)

    function Set-Status {
        param([string]$Text, [bool]$IsError = $false)
        $status.Text = $Text
        $status.ForeColor = if ($IsError) { [System.Drawing.Color]::Firebrick }
                            else { [System.Drawing.Color]::ForestGreen }
    }

    Update-WallpaperList
    $darkChk.Checked  = (Get-RegDword -Path $Script:ThemeKey -Name 'AppsUseLightTheme'  -Default 1) -eq 0
    $transChk.Checked = (Get-RegDword -Path $Script:ThemeKey -Name 'EnableTransparency' -Default 1) -eq 1

    if (Test-IsAdmin) { Set-Status 'Ready (Administrator).' }
    else { Set-Status 'Ready - run as Administrator for time zone and lock screen.' }

    [void]$form.ShowDialog()
}

# ===========================================================================
#  TOOL 8 - TempCleaner GodMode+  (admin)
# ===========================================================================
function Invoke-TempCleaner {
    [CmdletBinding()]
    param(
        [switch]$Preview,
        [switch]$GodMode,
        [switch]$IncludeBrowsers,
        [switch]$RemoveWindowsOld,
        [switch]$ResetBase,
        [switch]$ClearEventLogs,
        [switch]$Schedule,
        [switch]$Force
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        foreach ($n in 'Preview','GodMode','IncludeBrowsers','RemoveWindowsOld','ResetBase','ClearEventLogs','Schedule','Force') {
            if ((Get-Variable -Name $n -ValueOnly)) { $extra[$n] = $true }
        }
        Restart-Elevated -ToolName 'TempCleaner' -Extra $extra
        return
    }

    $stamp   = Get-Date -Format 'yyyyMMdd_HHmmss'
    $logPath = Join-Path $env:USERPROFILE "TempCleaner_$stamp.log"
    try { Start-Transcript -Path $logPath -Force | Out-Null } catch {}

    if ($Schedule) {
        Write-Host "Registering weekly Scheduled Task..." -ForegroundColor Cyan
        try {
            $a = New-ScheduledTaskAction -Execute 'powershell.exe' `
                    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Tool TempCleaner -GodMode -Force"
            $t = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 3am
            $p = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
            $s = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd
            Register-ScheduledTask -TaskName 'TempCleaner GodMode' -Action $a -Trigger $t -Principal $p -Settings $s -Force | Out-Null
            Write-Host "  [done] Task 'TempCleaner GodMode' runs every Sunday at 03:00." -ForegroundColor Green
            Write-Host "  Keep this script at: $PSCommandPath" -ForegroundColor DarkGray
        }
        catch { Write-Host "  [fail] Could not register task: $($_.Exception.Message)" -ForegroundColor Red }
        try { Stop-Transcript | Out-Null } catch {}
        return
    }

    function Format-Bytes {
        param([double]$Bytes)
        if ($Bytes -ge 1GB) { return ('{0:N2} GB' -f ($Bytes / 1GB)) }
        if ($Bytes -ge 1MB) { return ('{0:N2} MB' -f ($Bytes / 1MB)) }
        if ($Bytes -ge 1KB) { return ('{0:N2} KB' -f ($Bytes / 1KB)) }
        return ('{0} B' -f [int64]$Bytes)
    }

    function Resolve-Roots {
        param([string[]]$Paths)
        $roots = @()
        foreach ($p in $Paths) {
            if ($p -match '[\*\?]') {
                $roots += @(Resolve-Path -Path $p -ErrorAction SilentlyContinue | ForEach-Object { $_.Path })
            }
            elseif (Test-Path -LiteralPath $p) { $roots += $p }
        }
        return $roots
    }

    function Measure-Target {
        param($Target)
        $sum = [int64]0
        foreach ($root in (Resolve-Roots $Target.Paths)) {
            if (Test-Path -LiteralPath $root -PathType Leaf) {
                $sum += (Get-Item -LiteralPath $root -Force -ErrorAction SilentlyContinue).Length
                continue
            }
            $gci = @{ LiteralPath = $root; Recurse = $true; Force = $true; File = $true; ErrorAction = 'SilentlyContinue' }
            if ($Target.Filter) { $gci['Filter'] = $Target.Filter }
            $m = Get-ChildItem @gci | Measure-Object -Property Length -Sum
            if ($m.Sum) { $sum += [int64]$m.Sum }
        }
        return $sum
    }

    function Clear-Target {
        param($Target)
        if ($Target.ClearOverride) { try { & $Target.ClearOverride } catch {}; return }
        foreach ($root in (Resolve-Roots $Target.Paths)) {
            if (Test-Path -LiteralPath $root -PathType Leaf) {
                try { Remove-Item -LiteralPath $root -Force -ErrorAction Stop } catch {}
                continue
            }
            if ($Target.Filter) {
                Get-ChildItem -LiteralPath $root -Recurse -Force -Filter $Target.Filter -File -ErrorAction SilentlyContinue |
                    ForEach-Object { try { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop } catch {} }
            }
            else {
                Get-ChildItem -LiteralPath $root -Force -ErrorAction SilentlyContinue |
                    ForEach-Object { try { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction Stop } catch {} }
            }
        }
    }

    function New-Target {
        param(
            [string]$Name, [string[]]$Paths, [string]$Filter,
            [scriptblock]$PreAction, [scriptblock]$PostAction, [scriptblock]$ClearOverride
        )
        [pscustomobject]@{
            Name = $Name; Paths = $Paths; Filter = $Filter
            PreAction = $PreAction; PostAction = $PostAction; ClearOverride = $ClearOverride
        }
    }

    $targets = @()

    $targets += New-Target 'User TEMP'             @($env:TEMP)
    $targets += New-Target 'Local AppData Temp'    @("$env:LOCALAPPDATA\Temp")
    $targets += New-Target 'Windows TEMP'          @("$env:SystemRoot\Temp")
    $targets += New-Target 'INetCache (Temp Inet)' @("$env:LOCALAPPDATA\Microsoft\Windows\INetCache")
    $targets += New-Target 'Thumb/Icon cache'      @("$env:LOCALAPPDATA\Microsoft\Windows\Explorer") -Filter '*cache_*.db'
    $targets += New-Target 'Recent items'          @("$env:APPDATA\Microsoft\Windows\Recent")
    $targets += New-Target 'Local CrashDumps'      @("$env:LOCALAPPDATA\CrashDumps")

    if ($GodMode) {
        $targets += New-Target 'Prefetch'            @("$env:SystemRoot\Prefetch")
        $targets += New-Target 'Error Reporting'     @("$env:ProgramData\Microsoft\Windows\WER\ReportArchive", "$env:ProgramData\Microsoft\Windows\WER\ReportQueue")
        $targets += New-Target 'Memory / minidumps'  @("$env:SystemRoot\Minidump", "$env:SystemRoot\MEMORY.DMP", "$env:SystemRoot\LiveKernelReports")
        $targets += New-Target 'CBS / Panther logs'  @("$env:SystemRoot\Logs\CBS", "$env:SystemRoot\Panther")
        $targets += New-Target 'setupapi logs'       @("$env:SystemRoot\inf") -Filter 'setupapi*.log'
        $targets += New-Target 'All-user TEMP sweep' @("$env:SystemDrive\Users\*\AppData\Local\Temp")
        $targets += New-Target 'Windows Update cache' @("$env:SystemRoot\SoftwareDistribution\Download") `
                        -PreAction  { Stop-Service wuauserv, bits -Force -ErrorAction SilentlyContinue } `
                        -PostAction { Start-Service wuauserv, bits -ErrorAction SilentlyContinue }

        $targets += New-Target 'DirectX shader cache' @("$env:LOCALAPPDATA\D3DSCache")
        $targets += New-Target 'NVIDIA shader cache'  @("$env:LOCALAPPDATA\NVIDIA\DXCache", "$env:LOCALAPPDATA\NVIDIA\GLCache", "$env:LOCALAPPDATA\NVIDIA Corporation\NV_Cache")
        $targets += New-Target 'AMD shader cache'     @("$env:LOCALAPPDATA\AMD\DxCache", "$env:LOCALAPPDATA\AMD\DxcCache", "$env:LOCALAPPDATA\AMD\GLCache")
        $targets += New-Target 'GameLoop cache'       @("$env:LOCALAPPDATA\TxGameAssistant\Cache", "$env:LOCALAPPDATA\TxGameDownload")
        $targets += New-Target 'Steam shader cache'   @("${env:ProgramFiles(x86)}\Steam\steamapps\shadercache", "${env:ProgramFiles(x86)}\Steam\appcache\httpcache")
        $targets += New-Target 'Epic webcache'        @("$env:LOCALAPPDATA\EpicGamesLauncher\Saved\webcache", "$env:LOCALAPPDATA\EpicGamesLauncher\Saved\webcache_4147")

        $targets += New-Target 'Font cache' @("$env:SystemRoot\ServiceProfiles\LocalService\AppData\Local\FontCache", "$env:SystemRoot\System32\FNTCACHE.DAT") `
                        -PreAction  { Stop-Service FontCache, 'FontCache3.0.0.0' -Force -ErrorAction SilentlyContinue } `
                        -PostAction { Start-Service FontCache -ErrorAction SilentlyContinue }
        $targets += New-Target 'Print spooler queue' @("$env:SystemRoot\System32\spool\PRINTERS") `
                        -PreAction  { Stop-Service spooler -Force -ErrorAction SilentlyContinue } `
                        -PostAction { Start-Service spooler -ErrorAction SilentlyContinue }
    }

    if ($IncludeBrowsers) {
        $targets += New-Target 'Edge cache'    @("$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache", "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache")
        $targets += New-Target 'Chrome cache'  @("$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache", "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache")
        $targets += New-Target 'Firefox cache' @("$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\cache2")
    }

    if ($RemoveWindowsOld) {
        $targets += New-Target 'Windows.old / upgrade leftovers' `
                        @("$env:SystemDrive\Windows.old", "$env:SystemDrive\`$Windows.~BT", "$env:SystemDrive\`$Windows.~WS") `
                        -ClearOverride {
                            foreach ($wp in @("$env:SystemDrive\Windows.old", "$env:SystemDrive\`$Windows.~BT", "$env:SystemDrive\`$Windows.~WS")) {
                                if (Test-Path -LiteralPath $wp) {
                                    takeown /F "$wp" /R /D Y *> $null
                                    icacls "$wp" /grant Administrators:F /T /C *> $null
                                    Remove-Item -LiteralPath $wp -Recurse -Force -ErrorAction SilentlyContinue
                                }
                            }
                        }
    }

    $mode = if ($Preview) { 'PREVIEW (dry run)' } elseif ($GodMode) { 'GOD MODE+' } else { 'STANDARD' }
    Write-Host ''
    Write-Host '==============================================' -ForegroundColor Cyan
    Write-Host '   TempCleaner GodMode+  -  built-in only' -ForegroundColor Cyan
    Write-Host "   Mode: $mode" -ForegroundColor Cyan
    Write-Host '==============================================' -ForegroundColor Cyan
    Write-Host ''

    Write-Host 'Scanning targets...' -ForegroundColor Gray
    $rows = @(); $totalBefore = [int64]0
    foreach ($t in $targets) {
        $size = Measure-Target $t; $totalBefore += $size
        $rows += [pscustomobject]@{ Target = $t.Name; Reclaimable = (Format-Bytes $size); Bytes = $size }
    }
    $rows | Sort-Object Bytes -Descending | Format-Table Target, Reclaimable -AutoSize | Out-Host
    Write-Host ("Total reclaimable (cache targets): {0}" -f (Format-Bytes $totalBefore)) -ForegroundColor Green
    Write-Host ''

    $standalone = @()
    if ($GodMode)        { $standalone += 'DNS flush', 'Recycle Bin empty', 'Delivery Optimization cache', 'Store cache reset (wsreset)', 'Icon cache rebuild (ie4uinit)', 'WinSxS component cleanup (DISM)' }
    if ($ResetBase)      { $standalone += 'WinSxS /ResetBase (removes update uninstall ability)' }
    if ($ClearEventLogs) { $standalone += 'Clear ALL event logs (wevtutil)' }
    if ($standalone.Count) {
        Write-Host 'Standalone actions queued:' -ForegroundColor Gray
        $standalone | ForEach-Object { Write-Host "  - $_" -ForegroundColor DarkGray }
        Write-Host ''
    }

    if ($Preview) {
        Write-Host 'Preview only - nothing was changed.' -ForegroundColor Yellow
        Write-Host "Log: $logPath" -ForegroundColor DarkGray
        try { Stop-Transcript | Out-Null } catch {}
        return
    }

    if (-not $Force) {
        $warn = if ($RemoveWindowsOld -or $ResetBase -or $ClearEventLogs) { ' (includes DESTRUCTIVE flags)' } else { '' }
        $ans = Read-Host "Proceed with cleanup$warn? Cannot be undone. (y/N)"
        if ($ans -notmatch '^(y|yes)$') {
            Write-Host 'Cancelled.' -ForegroundColor Yellow
            try { Stop-Transcript | Out-Null } catch {}
            return
        }
    }

    Write-Host ''
    $totalFreed = [int64]0
    foreach ($t in $targets) {
        $before = Measure-Target $t
        if ($t.PreAction)  { try { & $t.PreAction }  catch {} }
        Clear-Target $t
        if ($t.PostAction) { try { & $t.PostAction } catch {} }
        $after = Measure-Target $t
        $freed = [Math]::Max([int64]0, $before - $after); $totalFreed += $freed
        Write-Host ("  [done] {0,-28} freed {1}" -f $t.Name, (Format-Bytes $freed)) -ForegroundColor Green
    }

    if ($GodMode) {
        Write-Host ''
        Write-Host 'GodMode extras...' -ForegroundColor Cyan

        try { ipconfig /flushdns | Out-Null; Write-Host '  [done] DNS resolver cache flushed' -ForegroundColor Green }
        catch { Write-Host '  [skip] DNS flush' -ForegroundColor DarkYellow }

        try { Clear-RecycleBin -Force -ErrorAction Stop; Write-Host '  [done] Recycle Bin emptied' -ForegroundColor Green }
        catch { Write-Host '  [skip] Recycle Bin empty/unavailable' -ForegroundColor DarkYellow }

        if (Get-Command Delete-DeliveryOptimizationCache -ErrorAction SilentlyContinue) {
            try { Delete-DeliveryOptimizationCache -Force -ErrorAction Stop; Write-Host '  [done] Delivery Optimization cache cleared' -ForegroundColor Green }
            catch { Write-Host '  [skip] Delivery Optimization cache' -ForegroundColor DarkYellow }
        }

        try { Start-Process -FilePath 'wsreset.exe' -ArgumentList '-i' -WindowStyle Hidden -ErrorAction Stop; Write-Host '  [done] Store cache reset triggered' -ForegroundColor Green }
        catch { Write-Host '  [skip] wsreset' -ForegroundColor DarkYellow }

        try { Start-Process -FilePath 'ie4uinit.exe' -ArgumentList '-show' -WindowStyle Hidden -ErrorAction Stop; Write-Host '  [done] Icon cache rebuild signalled' -ForegroundColor Green }
        catch { Write-Host '  [skip] icon cache rebuild' -ForegroundColor DarkYellow }

        $dismArgs = '/online /cleanup-image /StartComponentCleanup'
        if ($ResetBase) { $dismArgs += ' /ResetBase' }
        Write-Host "  [run ] DISM$dismArgs (may take several minutes)..." -ForegroundColor Gray
        try { Start-Process -FilePath 'dism.exe' -ArgumentList "$dismArgs /Quiet" -Wait -NoNewWindow -ErrorAction Stop
              Write-Host '  [done] WinSxS component cleanup complete' -ForegroundColor Green }
        catch { Write-Host '  [skip] DISM cleanup' -ForegroundColor DarkYellow }
    }

    if ($ClearEventLogs) {
        Write-Host ''
        Write-Host 'Clearing event logs...' -ForegroundColor Cyan
        $n = 0
        foreach ($log in (wevtutil el)) {
            try { wevtutil cl "$log" 2> $null; $n++ } catch {}
        }
        Write-Host ("  [done] Cleared {0} event logs" -f $n) -ForegroundColor Green
    }

    Write-Host ''
    Write-Host '==============================================' -ForegroundColor Cyan
    Write-Host ("  Space reclaimed (measured targets): {0}" -f (Format-Bytes $totalFreed)) -ForegroundColor Green
    Write-Host '  (WinSxS/DISM savings are measured by Windows, not counted above)' -ForegroundColor DarkGray
    Write-Host "  Log: $logPath" -ForegroundColor DarkGray
    Write-Host '==============================================' -ForegroundColor Cyan

    try { Stop-Transcript | Out-Null } catch {}
}

# ===========================================================================
#  TOOL 9 - Network God Mode  (admin)
# ===========================================================================
function Invoke-Network {
    [CmdletBinding()]
    param(
        [switch]$Revert,
        [switch]$Status,
        [switch]$SetDNS,
        [ValidateSet('Cloudflare','Google','Quad9')][string]$DnsProvider = 'Cloudflare',
        [switch]$ResetStack,
        [string]$BackupPath    = (Join-Path $env:USERPROFILE 'Network-GodMode.backup.json'),
        [string]$DnsBackupPath = (Join-Path $env:USERPROFILE 'Network-GodMode.dns.json')
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Revert)     { $extra.Revert = $true }
        if ($Status)     { $extra.Status = $true }
        if ($SetDNS)     { $extra.SetDNS = $true; $extra.DnsProvider = $DnsProvider }
        if ($ResetStack) { $extra.ResetStack = $true }
        Restart-Elevated -ToolName 'Network' -Extra $extra
        return
    }

    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    # MMCSS / multimedia network-throttle registry tunables.
    # NOTE: 0xFFFFFFFF ("throttle fully off") is a UInt32. Writing it as a DWORD
    # must go through ConvertTo-WtxDword: on PowerShell 7 the literal 0xffffffff
    # becomes a 64-bit 4294967295 which overflows a REG_DWORD, so we normalise it
    # to the equivalent signed Int32 (-1) that the .NET registry API accepts on
    # both Windows PowerShell 5.1 and PowerShell 7.
    $MMKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
    $RegTweaks = @(
        @{ Path=$MMKey; Name='NetworkThrottlingIndex'; Type='DWord'; Value=4294967295 }  # throttle off (0xFFFFFFFF)
        @{ Path=$MMKey; Name='SystemResponsiveness';   Type='DWord'; Value=10 }           # favour foreground
    )

    $DnsTable = @{
        Cloudflare = @{ V4=@('1.1.1.1','1.0.0.1');        V6=@('2606:4700:4700::1111','2606:4700:4700::1001') }
        Google     = @{ V4=@('8.8.8.8','8.8.4.4');        V6=@('2001:4860:4860::8888','2001:4860:4860::8844') }
        Quad9      = @{ V4=@('9.9.9.9','149.112.112.112'); V6=@('2620:fe::fe','2620:fe::9') }
    }

    $IfRoot = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces'

    # Normalise any integer (incl. UInt32 values > 2147483647 such as 0xFFFFFFFF)
    # into the signed Int32 the REG_DWORD writer needs, without overflowing on PS7.
    function ConvertTo-WtxDword {
        param($Value)
        $u = [uint32]([int64]$Value -band 0xffffffffL)
        return [System.BitConverter]::ToInt32([System.BitConverter]::GetBytes($u), 0)
    }

    function Get-RegSnap {
        param($Path,$Name)
        $o = @{ Path=$Path; Name=$Name; Existed=$false; Value=$null }
        try {
            $v = Get-ItemPropertyValue -Path $Path -Name $Name -ErrorAction Stop
            $o.Existed = $true; $o.Value = [int64]$v
        } catch {}
        return $o
    }

    function Get-ActiveAdapters {
        try { Get-NetAdapter -Physical -ErrorAction Stop | Where-Object { $_.Status -eq 'Up' } }
        catch { @() }
    }

    function Get-AdapterIfGuids {
        $guids = @()
        foreach ($a in (Get-ActiveAdapters)) { if ($a.InterfaceGuid) { $guids += $a.InterfaceGuid } }
        return ($guids | Select-Object -Unique)
    }

    # TCP global (best-effort parse of English netsh labels; falls back to defaults)
    function Get-TcpGlobal {
        $g = (netsh int tcp show global)     2>$null | Out-String
        $h = (netsh int tcp show heuristics) 2>$null | Out-String
        $pick = {
            param($text,$frag,$default)
            foreach ($line in ($text -split "`r?`n")) {
                if ($line -match [regex]::Escape($frag) -and $line -match ':\s*([A-Za-z0-9]+)\s*$') {
                    return $Matches[1].ToLower()
                }
            }
            return $default
        }
        [pscustomobject]@{
            AutoTuning = & $pick $g 'Auto-Tuning Level'          'normal'
            Rss        = & $pick $g 'Receive-Side Scaling'       'enabled'
            Rsc        = & $pick $g 'Receive Segment Coalescing' 'enabled'
            Heuristics = & $pick $h 'heuristics'                 'disabled'
        }
    }

    function Set-TcpGlobal {
        param($AutoTuning,$Rss,$Rsc,$Heuristics)
        if ($AutoTuning) { netsh int tcp set global autotuninglevel=$AutoTuning *> $null }
        if ($Rss)        { netsh int tcp set global rss=$Rss                     *> $null }
        if ($Rsc)        { netsh int tcp set global rsc=$Rsc                     *> $null }
        if ($Heuristics) { netsh int tcp set heuristics $Heuristics              *> $null }
    }

    # NIC power management via MSPower_DeviceEnable (same approach as Input tool, Net class)
    function Get-NetPmInstanceNames {
        $ids = @()
        try { $ids = Get-PnpDevice -PresentOnly -Class Net -ErrorAction Stop |
                     Where-Object { $_.Status -eq 'OK' } |
                     Select-Object -ExpandProperty InstanceId } catch {}
        $names = @()
        try {
            $pm = Get-CimInstance -Namespace root/wmi -ClassName MSPower_DeviceEnable -ErrorAction Stop
            foreach ($p in $pm) {
                foreach ($id in $ids) {
                    if ($p.InstanceName.ToString().StartsWith($id,[System.StringComparison]::OrdinalIgnoreCase)) {
                        $names += $p.InstanceName; break
                    }
                }
            }
        } catch {}
        return ($names | Select-Object -Unique)
    }

    function Set-NetPmEnable {
        param([string]$InstanceName,[bool]$Value)
        $done=$false
        try {
            $ci = Get-CimInstance -Namespace root/wmi -ClassName MSPower_DeviceEnable -ErrorAction Stop |
                  Where-Object { $_.InstanceName -eq $InstanceName } | Select-Object -First 1
            if ($ci) { Set-CimInstance -InputObject $ci -Property @{ Enable=$Value } -ErrorAction Stop; $done=$true }
        } catch {}
        if (-not $done -and (Get-Command Get-WmiObject -ErrorAction SilentlyContinue)) {
            try {
                $wo = Get-WmiObject -Namespace root\wmi -Class MSPower_DeviceEnable -ErrorAction Stop |
                      Where-Object { $_.InstanceName -eq $InstanceName } | Select-Object -First 1
                if ($wo) { $wo.Enable=$Value; [void]$wo.Put(); $done=$true }
            } catch {}
        }
        return $done
    }

    function Set-FastDNS {
        $prov = $DnsTable[$DnsProvider]
        if (-not $prov) { Write-Bad "Unknown DNS provider"; return }
        Write-Step "Setting DNS -> $DnsProvider ($($prov.V4 -join ', '))..."
        if (-not (Test-Path $DnsBackupPath)) {
            $bak = foreach ($a in (Get-ActiveAdapters)) {
                $cur4 = (Get-DnsClientServerAddress -InterfaceIndex $a.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses
                $dhcp = $true
                try { $dhcp = ((Get-NetIPInterface -InterfaceIndex $a.ifIndex -AddressFamily IPv4 -ErrorAction Stop).Dhcp -eq 'Enabled') } catch {}
                @{ Name=$a.Name; IfIndex=$a.ifIndex; Servers=@($cur4); Dhcp=$dhcp }
            }
            $bak | ConvertTo-Json -Depth 5 | Set-Content $DnsBackupPath -Encoding UTF8
        }
        foreach ($a in (Get-ActiveAdapters)) {
            try {
                Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ServerAddresses ($prov.V4 + $prov.V6) -ErrorAction Stop
                Write-Ok "DNS set on $($a.Name)"
            } catch { Write-Warn2 "DNS set failed on $($a.Name): $($_.Exception.Message)" }
        }
    }

    function Restore-DNS {
        if (-not (Test-Path $DnsBackupPath)) { return }
        $bak = Get-Content $DnsBackupPath -Raw | ConvertFrom-Json
        foreach ($b in $bak) {
            try {
                if ($b.Servers) {
                    Set-DnsClientServerAddress -InterfaceIndex $b.IfIndex -ServerAddresses @($b.Servers) -ErrorAction Stop
                } else {
                    Set-DnsClientServerAddress -InterfaceIndex $b.IfIndex -ResetServerAddresses -ErrorAction Stop
                }
                Write-Ok "DNS restored on $($b.Name)"
            } catch { Write-Warn2 "DNS restore failed on $($b.Name): $($_.Exception.Message)" }
        }
        Remove-Item $DnsBackupPath -ErrorAction SilentlyContinue
    }

    function Invoke-NetStatus {
        Write-Head "NETWORK GOD MODE  -  status"
        $g = Get-TcpGlobal
        if ($g.AutoTuning -eq 'normal') { Write-Ok ("{0,-26} {1}" -f 'TCP auto-tuning', $g.AutoTuning) } else { Write-Warn2 ("{0,-26} {1}" -f 'TCP auto-tuning', $g.AutoTuning) }
        if ($g.Rsc -eq 'disabled')      { Write-Ok ("{0,-26} disabled" -f 'Recv Segment Coalescing') }    else { Write-Warn2 ("{0,-26} {1}" -f 'Recv Segment Coalescing', $g.Rsc) }
        Write-Host ("      RSS={0}  heuristics={1}" -f $g.Rss, $g.Heuristics) -ForegroundColor DarkGray

        $nt = (Get-RegSnap $MMKey 'NetworkThrottlingIndex')
        if ($nt.Existed -and ([int64]$nt.Value -band 0xffffffffL) -eq 0xffffffffL) { Write-Ok ("{0,-26} disabled" -f 'Network throttling') }
        else { Write-Warn2 ("{0,-26} {1}" -f 'Network throttling', $(if($nt.Existed){'set ({0})' -f $nt.Value}else{'default (10)'})) }

        $sr = (Get-RegSnap $MMKey 'SystemResponsiveness')
        Write-Host ("      SystemResponsiveness = {0}" -f $(if($sr.Existed){$sr.Value}else{'default (20)'})) -ForegroundColor DarkGray

        $guids = Get-AdapterIfGuids
        if ($guids) {
            $nagleOn = $true
            foreach ($guid in $guids) {
                $p = Join-Path $IfRoot $guid
                $ack = (Get-RegSnap $p 'TcpAckFrequency'); $nd = (Get-RegSnap $p 'TCPNoDelay')
                if (-not ($ack.Existed -and $ack.Value -eq 1 -and $nd.Existed -and $nd.Value -eq 1)) { $nagleOn = $false }
            }
            if ($nagleOn) { Write-Ok ("{0,-26} OFF (1:1 acks)" -f 'Nagle on active NICs') }
            else { Write-Warn2 ("{0,-26} on for some NICs" -f 'Nagle on active NICs') }
        }

        $names = Get-NetPmInstanceNames
        if ($names) {
            $pm = Get-CimInstance -Namespace root/wmi -ClassName MSPower_DeviceEnable -ErrorAction SilentlyContinue
            $allOff=$true
            foreach ($n in $names) { if (($pm | Where-Object { $_.InstanceName -eq $n } | Select-Object -First 1).Enable) { $allOff=$false } }
            if ($allOff) { Write-Ok ("{0,-26} OFF (always-on)" -f 'NIC power-off') } else { Write-Warn2 ("{0,-26} on for some NICs" -f 'NIC power-off') }
        } else { Write-Warn2 ("{0,-26} not exposed by NICs" -f 'NIC power-off') }

        Write-Host ""
        Write-Host "  Active adapters & DNS:" -ForegroundColor Gray
        foreach ($a in (Get-ActiveAdapters)) {
            $dns = (Get-DnsClientServerAddress -InterfaceIndex $a.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses -join ', '
            Write-Host ("    {0,-22} {1}" -f $a.Name, $(if($dns){$dns}else{'(DHCP / none)'})) -ForegroundColor DarkGray
        }
        Write-Host ""
    }

    function Invoke-NetApply {
        Write-Head "NETWORK GOD MODE  -  applying"

        if (Test-Path $BackupPath) {
            Write-Warn2 "Existing backup kept as restore point: $BackupPath"
        } else {
            Write-Step "Backing up current network settings..."
            $tcp = Get-TcpGlobal
            $reg = @(foreach ($r in $RegTweaks) { Get-RegSnap $r.Path $r.Name })
            $ifs = @(foreach ($guid in (Get-AdapterIfGuids)) {
                $p = Join-Path $IfRoot $guid
                @{ Guid=$guid; TcpAckFrequency=(Get-RegSnap $p 'TcpAckFrequency'); TCPNoDelay=(Get-RegSnap $p 'TCPNoDelay') }
            })
            $names = Get-NetPmInstanceNames
            $pm = Get-CimInstance -Namespace root/wmi -ClassName MSPower_DeviceEnable -ErrorAction SilentlyContinue
            $nicpm = @(foreach ($n in $names) {
                @{ InstanceName=$n; Enable=[bool](($pm | Where-Object { $_.InstanceName -eq $n } | Select-Object -First 1).Enable) }
            })
            ([pscustomobject]@{ Tcp=$tcp; Reg=$reg; Ifs=$ifs; NicPm=$nicpm }) |
                ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8
            Write-Ok "Backup saved -> $BackupPath"
        }

        Write-Step "Tuning TCP stack (autotuning=normal, RSC off, RSS on, heuristics off)..."
        Set-TcpGlobal -AutoTuning 'normal' -Rss 'enabled' -Rsc 'disabled' -Heuristics 'disabled'
        Write-Ok "TCP global tuned"

        Write-Step "Disabling multimedia network throttle..."
        foreach ($r in $RegTweaks) {
            if (-not (Test-Path $r.Path)) { New-Item -Path $r.Path -Force | Out-Null }
            New-ItemProperty -Path $r.Path -Name $r.Name -PropertyType $r.Type -Value (ConvertTo-WtxDword $r.Value) -Force | Out-Null
        }
        Write-Ok "NetworkThrottlingIndex=disabled, SystemResponsiveness=10"

        Write-Step "Disabling Nagle on active adapters..."
        $n = 0
        foreach ($guid in (Get-AdapterIfGuids)) {
            $p = Join-Path $IfRoot $guid
            if (Test-Path $p) {
                New-ItemProperty -Path $p -Name 'TcpAckFrequency' -PropertyType DWord -Value 1 -Force | Out-Null
                New-ItemProperty -Path $p -Name 'TCPNoDelay'      -PropertyType DWord -Value 1 -Force | Out-Null
                $n++
            }
        }
        Write-Ok "Nagle disabled on $n adapter(s)"

        Write-Step "Keeping NICs always-on (power management off)..."
        $names = Get-NetPmInstanceNames
        if ($names) {
            foreach ($nm in $names) {
                $short = ($nm -split '\\')[1]
                if (Set-NetPmEnable -InstanceName $nm -Value $false) { Write-Ok "Power-off disabled: $short" }
                else { Write-Warn2 "Couldn't update: $short" }
            }
        } else { Write-Warn2 "No power-manageable NIC instances exposed (normal for some)." }

        if ($SetDNS) { Set-FastDNS }

        ipconfig /flushdns | Out-Null
        Write-Ok "DNS resolver cache flushed"

        Write-Host ""
        Write-Host "  ############################################################" -ForegroundColor Green
        Write-Host "  #            NETWORK GOD MODE - APPLIED                    #" -ForegroundColor Green
        Write-Host "  ############################################################" -ForegroundColor Green
        Write-Warn2 "Nagle + throttle changes fully apply after a reboot."
        Invoke-NetStatus
    }

    function Invoke-NetRevert {
        Write-Head "NETWORK GOD MODE  -  reverting"
        if (-not (Test-Path $BackupPath)) { Write-Bad "No backup at $BackupPath - nothing to restore."; Restore-DNS; return }
        $b = Get-Content $BackupPath -Raw | ConvertFrom-Json

        Set-TcpGlobal -AutoTuning $b.Tcp.AutoTuning -Rss $b.Tcp.Rss -Rsc $b.Tcp.Rsc -Heuristics $b.Tcp.Heuristics
        Write-Ok "TCP global restored"

        foreach ($r in $b.Reg) {
            if ($r.Existed) {
                if (-not (Test-Path $r.Path)) { New-Item -Path $r.Path -Force | Out-Null }
                New-ItemProperty -Path $r.Path -Name $r.Name -PropertyType DWord -Value (ConvertTo-WtxDword $r.Value) -Force | Out-Null
            } else {
                Remove-ItemProperty -Path $r.Path -Name $r.Name -ErrorAction SilentlyContinue
            }
        }
        Write-Ok "Multimedia throttle settings restored"

        foreach ($i in $b.Ifs) {
            $p = Join-Path $IfRoot $i.Guid
            foreach ($pair in @(@('TcpAckFrequency',$i.TcpAckFrequency), @('TCPNoDelay',$i.TCPNoDelay))) {
                $name = $pair[0]; $snap = $pair[1]
                if ($snap.Existed) {
                    if (Test-Path $p) { New-ItemProperty -Path $p -Name $name -PropertyType DWord -Value (ConvertTo-WtxDword $snap.Value) -Force | Out-Null }
                } else {
                    if (Test-Path $p) { Remove-ItemProperty -Path $p -Name $name -ErrorAction SilentlyContinue }
                }
            }
        }
        Write-Ok "Nagle settings restored"

        if ($b.NicPm) {
            foreach ($n in $b.NicPm) {
                $short = ($n.InstanceName -split '\\')[1]
                if (Set-NetPmEnable -InstanceName $n.InstanceName -Value ([bool]$n.Enable)) { Write-Ok "NIC power restored: $short" }
            }
        }

        Restore-DNS
        ipconfig /flushdns | Out-Null
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-Head "REVERT COMPLETE"
        Write-Warn2 "Reboot to fully clear Nagle/throttle changes."
        Write-Host ""
    }

    function Invoke-ResetStack {
        Write-Head "NETWORK STACK RESET  (repair)"
        Write-Warn2 "Resets Winsock + TCP/IP to Windows defaults and REQUIRES a reboot."
        Write-Warn2 "This is a repair action, NOT part of the reversible god-mode backup."
        $ans = Read-Host "  Type RESET to proceed"
        if ($ans -ne 'RESET') { Write-Host "  Skipped." -ForegroundColor DarkGray; return }
        netsh winsock reset  *> $null; Write-Ok "Winsock catalog reset"
        netsh int ip reset   *> $null; Write-Ok "TCP/IP (IPv4) reset"
        netsh int ipv6 reset *> $null; Write-Ok "TCP/IP (IPv6) reset"
        netsh int tcp reset  *> $null; Write-Ok "TCP global reset"
        ipconfig /flushdns | Out-Null
        Write-Warn2 "Reboot now to complete the reset."
    }

    if     ($ResetStack) { Invoke-ResetStack }
    elseif ($Status)     { Invoke-NetStatus }
    elseif ($Revert)     { Invoke-NetRevert }
    else                 { Invoke-NetApply }
}

# ===========================================================================
#  TOOL 10 - CPU God Mode  (admin)
#  Scheduler / throttle / boot-timer tuning. Does NOT touch the power plan
#  (that is Tool 3). Built-in only, JSON-backed, reversible.
# ===========================================================================
function Invoke-CPU {
    [CmdletBinding()]
    param(
        [switch]$Revert,
        [switch]$Status,
        [switch]$DisableMitigations,   # Spectre/Meltdown mitigations off - SECURITY tradeoff, reboot
        [switch]$TimerTweaks,          # bcdedit boot timer - system-dependent, reboot
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'Cpu-GodMode.backup.json')
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Revert)             { $extra.Revert = $true }
        if ($Status)             { $extra.Status = $true }
        if ($DisableMitigations) { $extra.DisableMitigations = $true }
        if ($TimerTweaks)        { $extra.TimerTweaks = $true }
        Restart-Elevated -ToolName 'CPU' -Extra $extra
        return
    }

    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    $PrioCtl = 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl'
    $PwrThr  = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling'
    $MemMgmt = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
    $Games   = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'

    # Core, reversible god-mode settings (scheduler + EcoQoS throttle + Games MMCSS)
    $Desired = @(
        @{ Path=$PrioCtl; Name='Win32PrioritySeparation'; Type='DWord';  Value=38;     Label='Foreground boost (PrioSep)' }
        @{ Path=$PwrThr;  Name='PowerThrottlingOff';      Type='DWord';  Value=1;      Label='CPU power throttling off' }
        @{ Path=$Games;   Name='GPU Priority';            Type='DWord';  Value=8;      Label='Games GPU priority' }
        @{ Path=$Games;   Name='Priority';                Type='DWord';  Value=6;      Label='Games CPU priority' }
        @{ Path=$Games;   Name='Scheduling Category';     Type='String'; Value='High'; Label='Games scheduling cat' }
        @{ Path=$Games;   Name='SFIO Priority';           Type='String'; Value='High'; Label='Games SFIO priority' }
    )
    # Mitigations are gated behind -DisableMitigations but always captured for revert.
    $Mitig = @(
        @{ Path=$MemMgmt; Name='FeatureSettingsOverride';     Type='DWord'; Value=3 }
        @{ Path=$MemMgmt; Name='FeatureSettingsOverrideMask'; Type='DWord'; Value=3 }
    )

    function Get-RegSnap {
        param($Path,$Name)
        $o = @{ Path=$Path; Name=$Name; Existed=$false; Type=$null; Value=$null }
        try {
            $raw = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
            $o.Existed = $true
            if ($raw -is [string]) { $o.Type='String'; $o.Value=[string]$raw }
            else                   { $o.Type='DWord';  $o.Value=[int64]$raw }
        } catch {}
        return $o
    }

    function Set-RegVal {
        param($Path,$Name,$Type,$Value)
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        if ($Type -eq 'String') { New-ItemProperty -Path $Path -Name $Name -PropertyType String -Value ([string]$Value) -Force | Out-Null }
        else                    { New-ItemProperty -Path $Path -Name $Name -PropertyType DWord  -Value ([int64]$Value) -Force | Out-Null }
    }

    function Get-BcdFlag {
        param([string]$Element)
        $out = (bcdedit /enum "{current}") 2>$null | Out-String
        foreach ($line in ($out -split "`r?`n")) {
            if ($line -match ('^\s*' + [regex]::Escape($Element) + '\s+(\S+)')) { return $Matches[1] }
        }
        return $null
    }

    function Show-CpuInfo {
        try {
            $c = Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -First 1
            Write-Host ("  CPU: {0}" -f $c.Name.Trim()) -ForegroundColor Gray
            Write-Host ("       {0} cores / {1} threads, base {2} MHz" -f $c.NumberOfCores, $c.NumberOfLogicalProcessors, $c.MaxClockSpeed) -ForegroundColor DarkGray
        } catch {}
    }

    function Invoke-CpuStatus {
        Write-Head "CPU GOD MODE  -  status"
        Show-CpuInfo
        Write-Host ""
        foreach ($d in $Desired) {
            $s = Get-RegSnap $d.Path $d.Name
            $cur = if ($s.Existed) { $s.Value } else { '<default>' }
            if ($s.Existed -and "$($s.Value)" -eq "$($d.Value)") { Write-Ok ("{0,-28} {1}" -f $d.Label, $cur) }
            else { Write-Warn2 ("{0,-28} {1} (want {2})" -f $d.Label, $cur, $d.Value) }
        }

        $fso = Get-RegSnap $MemMgmt 'FeatureSettingsOverride'
        if ($fso.Existed -and $fso.Value -eq 3) { Write-Warn2 ("{0,-28} ON  (mitigations DISABLED - less secure)" -f 'CPU mitigations override') }
        else { Write-Ok ("{0,-28} off (mitigations ON - default/secure)" -f 'CPU mitigations override') }

        $ddt = Get-BcdFlag 'disabledynamictick'
        $upt = Get-BcdFlag 'useplatformtick'
        Write-Host ("      boot timer: disabledynamictick={0}  useplatformtick={1}" -f $(if($ddt){$ddt}else{'default'}), $(if($upt){$upt}else{'default'})) -ForegroundColor DarkGray
        Write-Host ""
    }

    function Invoke-CpuApply {
        Write-Head "CPU GOD MODE  -  applying"
        Show-CpuInfo

        if (Test-Path $BackupPath) {
            Write-Warn2 "Existing backup kept as restore point: $BackupPath"
        } else {
            Write-Step "Backing up current CPU settings..."
            $snap = @(foreach ($d in ($Desired + $Mitig)) { Get-RegSnap $d.Path $d.Name })
            ([pscustomobject]@{ Reg = $snap }) | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8
            Write-Ok "Backup saved -> $BackupPath"
        }

        Write-Step "Applying scheduler + throttle + Games MMCSS tweaks..."
        foreach ($d in $Desired) {
            try { Set-RegVal $d.Path $d.Name $d.Type $d.Value; Write-Ok ("{0,-28} = {1}" -f $d.Label, $d.Value) }
            catch { Write-Bad ("{0}: {1}" -f $d.Label, $_.Exception.Message) }
        }

        if ($DisableMitigations) {
            Write-Host ""
            Write-Warn2 "DISABLING CPU mitigations (Spectre/Meltdown/etc)."
            Write-Warn2 "This trades security for a few % CPU. Only do this on a"
            Write-Warn2 "trusted, single-user gaming box. Reboot required."
            foreach ($m in $Mitig) {
                try { Set-RegVal $m.Path $m.Name $m.Type $m.Value; Write-Ok ("{0,-28} = {1}" -f $m.Name, $m.Value) }
                catch { Write-Bad ("{0}: {1}" -f $m.Name, $_.Exception.Message) }
            }
        }

        if ($TimerTweaks) {
            Write-Host ""
            Write-Warn2 "Applying boot timer tweaks (system-dependent; can raise OR"
            Write-Warn2 "lower DPC latency depending on hardware). Reboot required."
            bcdedit /set disabledynamictick yes *> $null; Write-Ok "disabledynamictick = yes"
            bcdedit /set useplatformtick     yes *> $null; Write-Ok "useplatformtick = yes"
        }

        Write-Host ""
        Write-Host "  ############################################################" -ForegroundColor Green
        Write-Host "  #              CPU GOD MODE - APPLIED                      #" -ForegroundColor Green
        Write-Host "  ############################################################" -ForegroundColor Green
        Write-Warn2 "Most CPU scheduler changes need a reboot to fully apply."
        Invoke-CpuStatus
    }

    function Invoke-CpuRevert {
        Write-Head "CPU GOD MODE  -  reverting"
        # Always undo boot timer tweaks back to Windows default (harmless if unset).
        bcdedit /deletevalue disabledynamictick *> $null
        bcdedit /deletevalue useplatformtick     *> $null
        Write-Ok "Boot timer settings returned to default"

        if (-not (Test-Path $BackupPath)) {
            Write-Bad "No backup at $BackupPath - registry tweaks left as-is (timer reset done)."
            Write-Host ""
            return
        }
        $b = Get-Content $BackupPath -Raw | ConvertFrom-Json
        foreach ($s in $b.Reg) {
            try {
                if ($s.Existed) {
                    Set-RegVal $s.Path $s.Name $s.Type $s.Value
                    Write-Ok "Restored $($s.Name)"
                } else {
                    if (Test-Path $s.Path) { Remove-ItemProperty -Path $s.Path -Name $s.Name -ErrorAction SilentlyContinue }
                    Write-Ok "Removed $($s.Name) (was default)"
                }
            } catch { Write-Bad "$($s.Name): $($_.Exception.Message)" }
        }
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-Head "REVERT COMPLETE"
        Write-Warn2 "Reboot to fully clear CPU scheduler/mitigation changes."
        Write-Host ""
    }

    if     ($Status) { Invoke-CpuStatus }
    elseif ($Revert) { Invoke-CpuRevert }
    else             { Invoke-CpuApply }
}

# ===========================================================================
#  TOOL 11 - NVIDIA GPU God Mode  (admin)
#  Built-in / driver-shipped only: PowerMizer "prefer max performance"
#  registry tweak, optional HAGS, and nvidia-smi (bundled with the driver,
#  not a separate download) for status + optional clock-lock / power-limit.
#  NOTE: deep tuning (voltage, fan curves, per-game 3D settings, overclock)
#  is NOT reachable without NVIDIA's own apps / NVAPI / Afterburner.
# ===========================================================================
function Invoke-GPU {
    [CmdletBinding()]
    param(
        [switch]$Revert,
        [switch]$Status,
        [switch]$LockClocks,        # nvidia-smi clock lock to max (often UNSUPPORTED on GeForce)
        [int]$PowerLimit = 0,       # nvidia-smi -pl watts (often UNSUPPORTED on GeForce); 0 = skip
        [string]$HAGS = '',         # 'On' / 'Off' - Hardware-accelerated GPU scheduling
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'Gpu-GodMode.backup.json')
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Revert)          { $extra.Revert = $true }
        if ($Status)          { $extra.Status = $true }
        if ($LockClocks)      { $extra.LockClocks = $true }
        if ($PowerLimit -gt 0){ $extra.PowerLimit = $PowerLimit }
        if ($HAGS)            { $extra.HAGS = $HAGS }
        Restart-Elevated -ToolName 'GPU' -Extra $extra
        return
    }

    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    $ClassRoot = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
    $GfxDrv    = 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers'
    # PowerMizer -> force "Prefer Maximum Performance" (stops idle/adaptive downclocking)
    $PmValues = @(
        @{ Name='PerfLevelSrc';      Value=0x2222 }
        @{ Name='PowerMizerEnable';  Value=1 }
        @{ Name='PowerMizerLevel';   Value=1 }
        @{ Name='PowerMizerLevelAC'; Value=1 }
    )

    function Get-RegSnap {
        param($Path,$Name)
        $o = @{ Path=$Path; Name=$Name; Existed=$false; Value=$null }
        try { $o.Value=[int64]((Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name); $o.Existed=$true } catch {}
        return $o
    }
    function Set-RegVal {
        param($Path,$Name,$Value)
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value ([int64]$Value) -Force | Out-Null
    }

    function Get-NvGpu {
        try { Get-CimInstance Win32_VideoController -ErrorAction Stop | Where-Object { $_.Name -match 'NVIDIA' } | Select-Object -First 1 }
        catch { $null }
    }

    function Get-NvKeys {
        $keys = @()
        Get-ChildItem $ClassRoot -ErrorAction SilentlyContinue |
            Where-Object { $_.PSChildName -match '^\d{4}$' } |
            ForEach-Object {
                $sub = Join-Path $ClassRoot $_.PSChildName
                $desc = (Get-ItemProperty -Path $sub -Name DriverDesc -ErrorAction SilentlyContinue).DriverDesc
                if ($desc -match 'NVIDIA') { $keys += $sub }
            }
        return $keys
    }

    function Get-SmiPath {
        $c = Get-Command nvidia-smi -ErrorAction SilentlyContinue
        if ($c) { return $c.Source }
        foreach ($p in @("$env:SystemRoot\System32\nvidia-smi.exe",
                         "$env:ProgramFiles\NVIDIA Corporation\NVSMI\nvidia-smi.exe")) {
            if (Test-Path $p) { return $p }
        }
        return $null
    }

    $smi = Get-SmiPath
    function Smi-Query {
        param([string]$Fields)
        if (-not $smi) { return $null }
        try {
            $out = & $smi "--query-gpu=$Fields" '--format=csv,noheader,nounits' 2>$null
            return ($out | Select-Object -First 1)
        } catch { return $null }
    }

    function Show-GpuInfo {
        $g = Get-NvGpu
        if (-not $g) { Write-Bad "No NVIDIA GPU detected."; return $false }
        Write-Host ("  GPU: {0}" -f $g.Name) -ForegroundColor Gray
        Write-Host ("       driver {0}" -f $g.DriverVersion) -ForegroundColor DarkGray
        if ($smi) {
            $q = Smi-Query 'name,driver_version,temperature.gpu,utilization.gpu,clocks.current.graphics,clocks.current.memory,power.draw,enforced.power.limit'
            if ($q) {
                $p = $q -split '\s*,\s*'
                Write-Host ("       temp {0}C  util {1}%  core {2}MHz  mem {3}MHz  power {4}/{5}W" -f $p[2],$p[3],$p[4],$p[5],$p[6],$p[7]) -ForegroundColor DarkGray
            }
        } else {
            Write-Warn2 "nvidia-smi not found - live stats / clock-lock / power-limit unavailable."
        }
        return $true
    }

    function Invoke-GpuStatus {
        Write-Head "NVIDIA GPU GOD MODE  -  status"
        if (-not (Show-GpuInfo)) { Write-Host ""; return }
        Write-Host ""
        $keys = Get-NvKeys
        if (-not $keys) { Write-Warn2 "NVIDIA adapter registry key not found." }
        foreach ($k in $keys) {
            $allMax = $true
            foreach ($v in $PmValues) {
                $s = Get-RegSnap $k $v.Name
                if (-not ($s.Existed -and $s.Value -eq $v.Value)) { $allMax = $false }
            }
            $short = Split-Path $k -Leaf
            if ($allMax) { Write-Ok ("{0,-26} max performance (forced)" -f "PowerMizer [$short]") }
            else { Write-Warn2 ("{0,-26} default/adaptive" -f "PowerMizer [$short]") }
        }
        $h = Get-RegSnap $GfxDrv 'HwSchMode'
        $hs = if (-not $h.Existed) { 'default' } elseif ($h.Value -eq 2) { 'ON' } elseif ($h.Value -eq 1) { 'off' } else { $h.Value }
        Write-Host ("      HAGS (HwSchMode) = {0}" -f $hs) -ForegroundColor DarkGray
        Write-Host ""
    }

    function Invoke-GpuApply {
        Write-Head "NVIDIA GPU GOD MODE  -  applying"
        if (-not (Show-GpuInfo)) { Write-Host ""; Write-Bad "Aborting - no NVIDIA GPU."; Write-Host ""; return }

        $keys = Get-NvKeys
        if (-not $keys) { Write-Warn2 "NVIDIA adapter registry key not found - PowerMizer tweak skipped." }

        # backup once
        if (Test-Path $BackupPath) {
            Write-Warn2 "Existing backup kept as restore point: $BackupPath"
        } else {
            Write-Step "Backing up current GPU registry settings..."
            $targets = @()
            foreach ($k in $keys) { foreach ($v in $PmValues) { $targets += @{ Path=$k; Name=$v.Name } } }
            $targets += @{ Path=$GfxDrv; Name='HwSchMode' }
            $snap = @(foreach ($t in $targets) { Get-RegSnap $t.Path $t.Name })
            ([pscustomobject]@{ Reg=$snap }) | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8
            Write-Ok "Backup saved -> $BackupPath"
        }

        # PowerMizer -> max performance
        if ($keys) {
            Write-Step "Forcing PowerMizer = Prefer Maximum Performance..."
            foreach ($k in $keys) {
                foreach ($v in $PmValues) {
                    try { Set-RegVal $k $v.Name $v.Value } catch { Write-Bad ("{0}: {1}" -f $v.Name, $_.Exception.Message) }
                }
                Write-Ok ("PowerMizer set on [{0}]" -f (Split-Path $k -Leaf))
            }
            Write-Warn2 "Raises idle clocks/temps. Needs a REBOOT (or driver restart) to take effect."
        }

        # HAGS
        if ($HAGS -eq 'On')  { Set-RegVal $GfxDrv 'HwSchMode' 2; Write-Ok 'HAGS (HwSchMode) = ON (reboot required)' }
        if ($HAGS -eq 'Off') { Set-RegVal $GfxDrv 'HwSchMode' 1; Write-Ok 'HAGS (HwSchMode) = off (reboot required)' }

        # nvidia-smi clock lock
        if ($LockClocks) {
            Write-Host ""
            if (-not $smi) { Write-Warn2 "nvidia-smi not found - cannot lock clocks." }
            else {
                $mx = Smi-Query 'clocks.max.graphics,clocks.max.memory'
                if ($mx) {
                    $p = $mx -split '\s*,\s*'; $mg=[int]$p[0]; $mm=[int]$p[1]
                    Write-Step "Locking clocks to max (core $mg MHz)..."
                    $r1 = (& $smi -lgc "$mg,$mg" 2>&1 | Out-String)
                    if ($r1 -match 'not supported|ERROR') { Write-Warn2 "Core clock lock not supported on this card." }
                    else { Write-Ok "Core clock locked at $mg MHz" }
                    $r2 = (& $smi -lmc "$mm,$mm" 2>&1 | Out-String)
                    if ($r2 -notmatch 'not supported|ERROR') { Write-Ok "Memory clock locked at $mm MHz" }
                    Write-Warn2 "Clock locks reset on reboot; use Revert to clear sooner."
                } else { Write-Warn2 "Could not read max clocks from nvidia-smi." }
            }
        }

        # nvidia-smi power limit
        if ($PowerLimit -gt 0) {
            Write-Host ""
            if (-not $smi) { Write-Warn2 "nvidia-smi not found - cannot set power limit." }
            else {
                $r = (& $smi -pl $PowerLimit 2>&1 | Out-String)
                if ($r -match 'not supported|ERROR|Insufficient') { Write-Warn2 "Power-limit change not supported on this card (typical for GeForce)." }
                else { Write-Ok "Power limit set to $PowerLimit W" }
            }
        }

        Write-Host ""
        Write-Host "  ############################################################" -ForegroundColor Green
        Write-Host "  #            NVIDIA GPU GOD MODE - APPLIED                 #" -ForegroundColor Green
        Write-Host "  ############################################################" -ForegroundColor Green
        Write-Warn2 "Reboot to apply the PowerMizer / HAGS registry changes."
        Invoke-GpuStatus
    }

    function Invoke-GpuRevert {
        Write-Head "NVIDIA GPU GOD MODE  -  reverting"
        # reset any nvidia-smi locks / power limit first (harmless if none set)
        if ($smi) {
            & $smi -rgc *> $null
            & $smi -rmc *> $null
            $def = Smi-Query 'power.default_limit'
            if ($def) { try { & $smi -pl ([int][double]$def) *> $null } catch {} }
            Write-Ok "nvidia-smi clocks/power limit reset to default"
        }

        if (-not (Test-Path $BackupPath)) {
            Write-Bad "No backup at $BackupPath - registry left as-is (smi reset done)."
            Write-Host ""
            return
        }
        $b = Get-Content $BackupPath -Raw | ConvertFrom-Json
        foreach ($s in $b.Reg) {
            try {
                if ($s.Existed) { Set-RegVal $s.Path $s.Name $s.Value; Write-Ok "Restored $($s.Name)" }
                else { if (Test-Path $s.Path) { Remove-ItemProperty -Path $s.Path -Name $s.Name -ErrorAction SilentlyContinue }; Write-Ok "Removed $($s.Name) (was default)" }
            } catch { Write-Bad "$($s.Name): $($_.Exception.Message)" }
        }
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-Head "REVERT COMPLETE"
        Write-Warn2 "Reboot to fully restore PowerMizer / HAGS behaviour."
        Write-Host ""
    }

    if     ($Status) { Invoke-GpuStatus }
    elseif ($Revert) { Invoke-GpuRevert }
    else             { Invoke-GpuApply }
}

# ===========================================================================
#  TOOL 12 - Debloat  (Services + Scheduled Tasks)  (admin)
#  Conservative, curated allowlist. Records original start type / task state
#  so every change is reversible.
# ===========================================================================
function Invoke-Debloat {
    [CmdletBinding()]
    param(
        [switch]$Revert,
        [switch]$Status,
        [switch]$DisableXbox,      # Xbox Live services - some PC games need these
        [switch]$NoPrinter,        # Print Spooler
        [switch]$DisableSearch,    # Windows Search (breaks Start search)
        [switch]$DisableSysMain,   # SysMain/Superfetch (leave on if you have RAM)
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'Debloat.backup.json')
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Revert)         { $extra.Revert = $true }
        if ($Status)         { $extra.Status = $true }
        if ($DisableXbox)    { $extra.DisableXbox = $true }
        if ($NoPrinter)      { $extra.NoPrinter = $true }
        if ($DisableSearch)  { $extra.DisableSearch = $true }
        if ($DisableSysMain) { $extra.DisableSysMain = $true }
        Restart-Elevated -ToolName 'Debloat' -Extra $extra
        return
    }

    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    # Default-safe services to set Disabled (low risk on a gaming desktop)
    $Services = [System.Collections.ArrayList]@(
        'DiagTrack'         # Connected User Experiences and Telemetry
        'dmwappushservice'  # WAP Push message routing
        'Fax'
        'RetailDemo'
        'MapsBroker'        # Downloaded Maps Manager
        'WMPNetworkSvc'     # WMP network sharing
    )
    if ($DisableXbox)    { [void]$Services.AddRange(@('XblAuthManager','XblGameSave','XboxGipSvc','XboxNetApiSvc')) }
    if ($NoPrinter)      { [void]$Services.Add('Spooler') }
    if ($DisableSearch)  { [void]$Services.Add('WSearch') }
    if ($DisableSysMain) { [void]$Services.Add('SysMain') }

    # Telemetry / CEIP scheduled tasks (full paths)
    $Tasks = @(
        '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser'
        '\Microsoft\Windows\Application Experience\ProgramDataUpdater'
        '\Microsoft\Windows\Application Experience\StartupAppTask'
        '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator'
        '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip'
        '\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask'
        '\Microsoft\Windows\Autochk\Proxy'
        '\Microsoft\Windows\Feedback\Siuf\DmClient'
        '\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload'
        '\Microsoft\Windows\Windows Error Reporting\QueueReporting'
        '\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector'
    )

    function Split-TaskPath {
        param([string]$Full)
        $i = $Full.LastIndexOf('\')
        @{ Path = $Full.Substring(0, $i + 1); Name = $Full.Substring($i + 1) }
    }

    function Invoke-DebloatStatus {
        Write-Head "DEBLOAT  -  status"
        Write-Host "  Services:" -ForegroundColor Gray
        foreach ($n in $Services) {
            $svc = Get-Service -Name $n -ErrorAction SilentlyContinue
            if (-not $svc) { Write-Host ("    {0,-22} not present" -f $n) -ForegroundColor DarkGray; continue }
            $st = "$($svc.StartType)"
            if ($st -eq 'Disabled') { Write-Ok ("{0,-22} Disabled" -f $n) } else { Write-Warn2 ("{0,-22} {1}" -f $n, $st) }
        }
        Write-Host "  Scheduled tasks:" -ForegroundColor Gray
        foreach ($t in $Tasks) {
            $sp = Split-TaskPath $t
            $task = Get-ScheduledTask -TaskPath $sp.Path -TaskName $sp.Name -ErrorAction SilentlyContinue
            if (-not $task) { continue }
            if ("$($task.State)" -eq 'Disabled') { Write-Ok ("{0,-40} Disabled" -f $sp.Name) } else { Write-Warn2 ("{0,-40} {1}" -f $sp.Name, $task.State) }
        }
        Write-Host ""
    }

    function Invoke-DebloatApply {
        Write-Head "DEBLOAT  -  applying"
        if (Test-Path $BackupPath) {
            Write-Warn2 "Existing backup kept as restore point: $BackupPath"
        } else {
            Write-Step "Backing up current service start types & task states..."
            $svcBak = foreach ($n in $Services) {
                $svc = Get-Service -Name $n -ErrorAction SilentlyContinue
                if ($svc) { @{ Name=$n; Existed=$true; StartType="$($svc.StartType)"; WasRunning=($svc.Status -eq 'Running') } }
                else      { @{ Name=$n; Existed=$false } }
            }
            $taskBak = foreach ($t in $Tasks) {
                $sp = Split-TaskPath $t
                $task = Get-ScheduledTask -TaskPath $sp.Path -TaskName $sp.Name -ErrorAction SilentlyContinue
                if ($task) { @{ Full=$t; Existed=$true; State="$($task.State)" } } else { @{ Full=$t; Existed=$false } }
            }
            ([pscustomobject]@{ Svc=@($svcBak); Tasks=@($taskBak) }) | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8
            Write-Ok "Backup saved -> $BackupPath"
        }

        Write-Step "Disabling services..."
        foreach ($n in $Services) {
            $svc = Get-Service -Name $n -ErrorAction SilentlyContinue
            if (-not $svc) { continue }
            try {
                Set-Service -Name $n -StartupType Disabled -ErrorAction Stop
                Stop-Service -Name $n -Force -ErrorAction SilentlyContinue
                Write-Ok "disabled $n"
            } catch { Write-Warn2 "$n : $($_.Exception.Message)" }
        }

        Write-Step "Disabling telemetry scheduled tasks..."
        foreach ($t in $Tasks) {
            $sp = Split-TaskPath $t
            $task = Get-ScheduledTask -TaskPath $sp.Path -TaskName $sp.Name -ErrorAction SilentlyContinue
            if (-not $task) { continue }
            try { Disable-ScheduledTask -TaskPath $sp.Path -TaskName $sp.Name -ErrorAction Stop | Out-Null; Write-Ok "disabled task $($sp.Name)" }
            catch { Write-Warn2 "task $($sp.Name): $($_.Exception.Message)" }
        }

        Write-Host ""
        Write-Host "  ############################################################" -ForegroundColor Green
        Write-Host "  #                  DEBLOAT - APPLIED                       #" -ForegroundColor Green
        Write-Host "  ############################################################" -ForegroundColor Green
        if ($DisableXbox) { Write-Warn2 "Xbox services disabled - re-enable (Revert) if a game needs Xbox Live." }
        Write-Host ""
    }

    function Invoke-DebloatRevert {
        Write-Head "DEBLOAT  -  reverting"
        if (-not (Test-Path $BackupPath)) { Write-Bad "No backup at $BackupPath - nothing to restore."; Write-Host ""; return }
        $b = Get-Content $BackupPath -Raw | ConvertFrom-Json
        foreach ($s in $b.Svc) {
            if (-not $s.Existed) { continue }
            try {
                Set-Service -Name $s.Name -StartupType $s.StartType -ErrorAction Stop
                if ($s.WasRunning -and ($s.StartType -match 'Automatic')) { Start-Service -Name $s.Name -ErrorAction SilentlyContinue }
                Write-Ok "restored $($s.Name) -> $($s.StartType)"
            } catch { Write-Warn2 "$($s.Name): $($_.Exception.Message)" }
        }
        foreach ($t in $b.Tasks) {
            if (-not $t.Existed) { continue }
            if ("$($t.State)" -eq 'Disabled') { continue }   # was already disabled - leave it
            $sp = Split-TaskPath $t.Full
            try { Enable-ScheduledTask -TaskPath $sp.Path -TaskName $sp.Name -ErrorAction Stop | Out-Null; Write-Ok "enabled task $($sp.Name)" }
            catch { Write-Warn2 "task $($sp.Name): $($_.Exception.Message)" }
        }
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-Head "REVERT COMPLETE"
        Write-Host ""
    }

    if     ($Status) { Invoke-DebloatStatus }
    elseif ($Revert) { Invoke-DebloatRevert }
    else             { Invoke-DebloatApply }
}

# ===========================================================================
#  TOOL 13 - GameLoop / VBS  (admin)
#  Disables VBS / Memory Integrity / Credential Guard and the boot hypervisor
#  for Android-emulator (GameLoop) performance, and merges svchost.
#  SECURITY TRADEOFF: VBS/HVCI/CredGuard protect against credential theft and
#  some kernel exploits. Reboot required. Fully reversible.
# ===========================================================================
function Invoke-GameLoop {
    [CmdletBinding()]
    param(
        [switch]$Revert,
        [switch]$Status,
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'GameLoop-VBS.backup.json')
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Revert) { $extra.Revert = $true }
        if ($Status) { $extra.Status = $true }
        Restart-Elevated -ToolName 'GameLoop' -Extra $extra
        return
    }

    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    $DG     = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard'
    $DGScen = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity'
    $Lsa    = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
    $Ctl    = 'HKLM:\SYSTEM\CurrentControlSet\Control'

    $Desired = @(
        @{ Path=$DGScen; Name='Enabled';                            Value=0; Label='Memory Integrity (HVCI)' }
        @{ Path=$DG;     Name='EnableVirtualizationBasedSecurity';  Value=0; Label='Virtualization-based security' }
        @{ Path=$Lsa;    Name='LsaCfgFlags';                        Value=0; Label='Credential Guard' }
    )

    function Get-RegSnap {
        param($Path,$Name)
        $o = @{ Path=$Path; Name=$Name; Existed=$false; Value=$null }
        try { $o.Value=[int64]((Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name); $o.Existed=$true } catch {}
        return $o
    }
    function Set-RegVal {
        param($Path,$Name,$Value)
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value ([int64]$Value) -Force | Out-Null
    }
    function Get-Bcd {
        param([string]$Element)
        $out = (bcdedit /enum "{current}") 2>$null | Out-String
        foreach ($line in ($out -split "`r?`n")) {
            if ($line -match ('^\s*' + [regex]::Escape($Element) + '\s+(\S+)')) { return $Matches[1] }
        }
        return $null
    }
    function Get-VbsState {
        try {
            $d = Get-CimInstance -Namespace 'root\Microsoft\Windows\DeviceGuard' -ClassName Win32_DeviceGuard -ErrorAction Stop
            switch ([int]$d.VirtualizationBasedSecurityStatus) { 0 {'off'} 1 {'configured (not running)'} 2 {'RUNNING'} default {'unknown'} }
        } catch { 'unknown' }
    }

    function Invoke-GlStatus {
        Write-Head "GAMELOOP / VBS  -  status"
        Write-Host ("  VBS runtime state: {0}" -f (Get-VbsState)) -ForegroundColor Gray
        foreach ($d in $Desired) {
            $s = Get-RegSnap $d.Path $d.Name
            $cur = if ($s.Existed) { $s.Value } else { '<not set>' }
            if ($s.Existed -and $s.Value -eq 0) { Write-Ok ("{0,-30} off" -f $d.Label) }
            else { Write-Warn2 ("{0,-30} {1}" -f $d.Label, $cur) }
        }
        $hlt = Get-Bcd 'hypervisorlaunchtype'
        if ("$hlt" -match 'Off') { Write-Ok ("{0,-30} Off" -f 'Boot hypervisor (Hyper-V)') }
        else { Write-Warn2 ("{0,-30} {1}" -f 'Boot hypervisor (Hyper-V)', $(if($hlt){$hlt}else{'Auto (default)'})) }
        $sht = (Get-RegSnap $Ctl 'SvcHostSplitThresholdInKB')
        Write-Host ("      svchost split threshold = {0}" -f $(if($sht.Existed){'{0} KB' -f $sht.Value}else{'default'})) -ForegroundColor DarkGray
        Write-Host ""
    }

    function Invoke-GlApply {
        Write-Head "GAMELOOP / VBS  -  applying"
        Write-Warn2 "SECURITY: this disables VBS / Memory Integrity / Credential Guard."
        Write-Warn2 "Only do this on a trusted, single-user gaming box. Reboot required."

        if (Test-Path $BackupPath) {
            Write-Warn2 "Existing backup kept as restore point: $BackupPath"
        } else {
            Write-Step "Backing up current settings..."
            $targets = @($Desired | ForEach-Object { @{ Path=$_.Path; Name=$_.Name } })
            $targets += @{ Path=$Ctl; Name='SvcHostSplitThresholdInKB' }
            $snap = @(foreach ($t in $targets) { Get-RegSnap $t.Path $t.Name })
            ([pscustomobject]@{ Reg=$snap }) | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8
            Write-Ok "Backup saved -> $BackupPath"
        }

        Write-Step "Disabling VBS / HVCI / Credential Guard..."
        foreach ($d in $Desired) {
            try { Set-RegVal $d.Path $d.Name $d.Value; Write-Ok ("{0} off" -f $d.Label) }
            catch { Write-Bad ("{0}: {1}" -f $d.Label, $_.Exception.Message) }
        }

        Write-Step "Disabling the boot hypervisor (frees CPU virtualization for emulators)..."
        bcdedit /set hypervisorlaunchtype off *> $null
        Write-Ok "hypervisorlaunchtype = off"

        # merge svchost processes (threshold above total RAM)
        try {
            $ramKB = [int64]((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1KB)
            $thr = [int64]($ramKB + 1048576)
            if ($thr -gt 2147483647) { $thr = 2147483647 }   # DWORD ceiling
            Set-RegVal $Ctl 'SvcHostSplitThresholdInKB' $thr
            Write-Ok "svchost split threshold raised (fewer svchost processes)"
        } catch { Write-Warn2 "svchost merge skipped: $($_.Exception.Message)" }

        Write-Host ""
        Write-Host "  ############################################################" -ForegroundColor Green
        Write-Host "  #              GAMELOOP / VBS - APPLIED                    #" -ForegroundColor Green
        Write-Host "  ############################################################" -ForegroundColor Green
        Write-Warn2 "REBOOT required for VBS/Hyper-V changes to take effect."
        Invoke-GlStatus
    }

    function Invoke-GlRevert {
        Write-Head "GAMELOOP / VBS  -  reverting"
        bcdedit /set hypervisorlaunchtype auto *> $null
        Write-Ok "Boot hypervisor returned to Auto"
        if (-not (Test-Path $BackupPath)) { Write-Bad "No backup at $BackupPath - registry left as-is (hypervisor reset done)."; Write-Host ""; return }
        $b = Get-Content $BackupPath -Raw | ConvertFrom-Json
        foreach ($s in $b.Reg) {
            try {
                if ($s.Existed) { Set-RegVal $s.Path $s.Name $s.Value; Write-Ok "Restored $($s.Name)" }
                else { if (Test-Path $s.Path) { Remove-ItemProperty -Path $s.Path -Name $s.Name -ErrorAction SilentlyContinue }; Write-Ok "Removed $($s.Name) (was default)" }
            } catch { Write-Bad "$($s.Name): $($_.Exception.Message)" }
        }
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-Head "REVERT COMPLETE"
        Write-Warn2 "Reboot to re-enable VBS / Memory Integrity / Hyper-V."
        Write-Host ""
    }

    if     ($Status) { Invoke-GlStatus }
    elseif ($Revert) { Invoke-GlRevert }
    else             { Invoke-GlApply }
}

# ===========================================================================
#  TOOL 14 - Game DVR / Game Bar  (admin; HKCU stays current-user under UAC)
# ===========================================================================
function Invoke-GameDVR {
    [CmdletBinding()]
    param(
        [switch]$Revert,
        [switch]$Status,
        [switch]$DisableBackgroundApps,   # also stop UWP apps running in background
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'GameDVR.backup.json')
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Revert)                { $extra.Revert = $true }
        if ($Status)                { $extra.Status = $true }
        if ($DisableBackgroundApps) { $extra.DisableBackgroundApps = $true }
        Restart-Elevated -ToolName 'GameDVR' -Extra $extra
        return
    }

    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    $Desired = @(
        @{ Path='HKCU:\System\GameConfigStore';                                       Name='GameDVR_Enabled';     Value=0; Label='Game DVR (record)' }
        @{ Path='HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR';            Name='AppCaptureEnabled';   Value=0; Label='Background capture' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR';                  Name='AllowGameDVR';        Value=0; Label='Game DVR (policy)' }
        @{ Path='HKCU:\SOFTWARE\Microsoft\GameBar';                                   Name='AutoGameModeEnabled'; Value=1; Label='Game Mode' }
        @{ Path='HKCU:\SOFTWARE\Microsoft\GameBar';                                   Name='AllowAutoGameMode';   Value=1; Label='Auto Game Mode' }
    )
    $BgApps = @(
        @{ Path='HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications'; Name='GlobalUserDisabled';     Value=1; Label='Background apps (user)' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy';                         Name='LetAppsRunInBackground'; Value=2; Label='Background apps (policy)' }
    )

    function Get-RegSnap {
        param($Path,$Name)
        $o = @{ Path=$Path; Name=$Name; Existed=$false; Value=$null }
        try { $o.Value=[int64]((Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name); $o.Existed=$true } catch {}
        return $o
    }
    function Set-RegVal {
        param($Path,$Name,$Value)
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value ([int64]$Value) -Force | Out-Null
    }

    function Invoke-DvrStatus {
        Write-Head "GAME DVR / GAME BAR  -  status"
        foreach ($d in ($Desired + $BgApps)) {
            $s = Get-RegSnap $d.Path $d.Name
            $cur = if ($s.Existed) { $s.Value } else { '<default>' }
            $good = $s.Existed -and $s.Value -eq $d.Value
            if ($good) { Write-Ok ("{0,-26} {1}" -f $d.Label, $cur) } else { Write-Warn2 ("{0,-26} {1} (want {2})" -f $d.Label, $cur, $d.Value) }
        }
        Write-Host ""
    }

    function Invoke-DvrApply {
        Write-Head "GAME DVR / GAME BAR  -  applying"
        $all = if ($DisableBackgroundApps) { $Desired + $BgApps } else { $Desired }
        if (Test-Path $BackupPath) {
            Write-Warn2 "Existing backup kept as restore point: $BackupPath"
        } else {
            Write-Step "Backing up current values..."
            $snap = @(foreach ($d in ($Desired + $BgApps)) { Get-RegSnap $d.Path $d.Name })
            ([pscustomobject]@{ Reg=$snap }) | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8
            Write-Ok "Backup saved -> $BackupPath"
        }
        Write-Step "Turning off Game DVR / capture, Game Mode on..."
        foreach ($d in $all) {
            try { Set-RegVal $d.Path $d.Name $d.Value; Write-Ok ("{0} = {1}" -f $d.Label, $d.Value) }
            catch { Write-Bad ("{0}: {1}" -f $d.Label, $_.Exception.Message) }
        }
        Write-Host ""
        Write-Host "  ############################################################" -ForegroundColor Green
        Write-Host "  #            GAME DVR / GAME BAR - APPLIED                 #" -ForegroundColor Green
        Write-Host "  ############################################################" -ForegroundColor Green
        Write-Host ""
    }

    function Invoke-DvrRevert {
        Write-Head "GAME DVR / GAME BAR  -  reverting"
        if (-not (Test-Path $BackupPath)) { Write-Bad "No backup at $BackupPath - nothing to restore."; Write-Host ""; return }
        $b = Get-Content $BackupPath -Raw | ConvertFrom-Json
        foreach ($s in $b.Reg) {
            try {
                if ($s.Existed) { Set-RegVal $s.Path $s.Name $s.Value; Write-Ok "Restored $($s.Name)" }
                else { if (Test-Path $s.Path) { Remove-ItemProperty -Path $s.Path -Name $s.Name -ErrorAction SilentlyContinue }; Write-Ok "Removed $($s.Name) (was default)" }
            } catch { Write-Bad "$($s.Name): $($_.Exception.Message)" }
        }
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-Head "REVERT COMPLETE"
        Write-Host ""
    }

    if     ($Status) { Invoke-DvrStatus }
    elseif ($Revert) { Invoke-DvrRevert }
    else             { Invoke-DvrApply }
}

# ===========================================================================
#  TOOL 15 - Startup manager  (admin; HKCU stays current-user under UAC)
#  Enable/disable Run-key and Startup-folder items the same way Task Manager
#  does (StartupApproved blobs), so entries are never deleted. Reversible.
# ===========================================================================
function Invoke-Startup {
    [CmdletBinding()]
    param(
        [switch]$Status,
        [switch]$Revert,
        [switch]$StartupApply,   # silent: disable a curated set of heavy startup apps (reversible)
        [switch]$Manage,         # open the interactive manager (same as no-flag default)
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'Startup.backup.json')
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Status)       { $extra.Status = $true }
        if ($Revert)       { $extra.Revert = $true }
        if ($StartupApply) { $extra.StartupApply = $true }
        if ($Manage)       { $extra.Manage = $true }
        Restart-Elevated -ToolName 'Startup' -Extra $extra
        return
    }

    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    $RunKeys = @(
        @{ Run='HKCU:\Software\Microsoft\Windows\CurrentVersion\Run';            Appr='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run';   Src='HKCU Run' }
        @{ Run='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run';            Appr='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run';   Src='HKLM Run' }
        @{ Run='HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'; Appr='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32'; Src='HKLM Run (x86)' }
    )
    $FolderItems = @(
        @{ Folder=(Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup');     Appr='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder'; Src='Startup folder (user)' }
        @{ Folder=(Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\Startup'); Appr='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder'; Src='Startup folder (all users)' }
    )

    function Get-ApprovedState {
        param($ApprKey,$ValueName)
        try {
            $blob = (Get-ItemProperty -Path $ApprKey -Name $ValueName -ErrorAction Stop).$ValueName
            if ($blob -is [byte[]] -and $blob.Length -ge 1 -and $blob[0] -eq 3) { return 'Disabled' }
        } catch {}
        return 'Enabled'
    }
    function Set-ApprovedState {
        param($ApprKey,$ValueName,[bool]$Enabled)
        if (-not (Test-Path $ApprKey)) { New-Item -Path $ApprKey -Force | Out-Null }
        $b = if ($Enabled) { [byte[]](2,0,0,0,0,0,0,0,0,0,0,0) } else { [byte[]](3,0,0,0,0,0,0,0,0,0,0,0) }
        New-ItemProperty -Path $ApprKey -Name $ValueName -PropertyType Binary -Value $b -Force | Out-Null
    }

    function Get-Entries {
        $list = @()
        foreach ($r in $RunKeys) {
            if (-not (Test-Path $r.Run)) { continue }
            $p = Get-ItemProperty -Path $r.Run -ErrorAction SilentlyContinue
            foreach ($prop in $p.PSObject.Properties) {
                if ($prop.Name -match '^PS(Path|ParentPath|ChildName|Provider|Drive)$') { continue }
                $list += [pscustomobject]@{
                    Src=$r.Src; Name=$prop.Name; Command="$($prop.Value)"
                    ApprKey=$r.Appr; ApprValue=$prop.Name
                    State=(Get-ApprovedState $r.Appr $prop.Name)
                }
            }
        }
        foreach ($f in $FolderItems) {
            if (-not (Test-Path $f.Folder)) { continue }
            Get-ChildItem -Path $f.Folder -File -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -ne 'desktop.ini' } | ForEach-Object {
                    $list += [pscustomobject]@{
                        Src=$f.Src; Name=$_.Name; Command=$_.FullName
                        ApprKey=$f.Appr; ApprValue=$_.Name
                        State=(Get-ApprovedState $f.Appr $_.Name)
                    }
                }
        }
        return $list
    }

    function Backup-Once {
        if (Test-Path $BackupPath) { return }
        $snap = foreach ($e in (Get-Entries)) {
            $existed=$false; $b64=$null
            try { $raw=(Get-ItemProperty -Path $e.ApprKey -Name $e.ApprValue -ErrorAction Stop).$($e.ApprValue)
                  if ($raw -is [byte[]]) { $existed=$true; $b64=[Convert]::ToBase64String($raw) } } catch {}
            @{ ApprKey=$e.ApprKey; ApprValue=$e.ApprValue; Existed=$existed; Blob=$b64 }
        }
        ([pscustomobject]@{ Appr=@($snap) }) | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8
        Write-Ok "Backup saved -> $BackupPath"
    }

    function Show-StartupList {
        Write-Head "STARTUP MANAGER"
        $entries = Get-Entries
        if (-not $entries) { Write-Warn2 "No startup entries found."; Write-Host ""; return @() }
        for ($i=0; $i -lt $entries.Count; $i++) {
            $e = $entries[$i]
            $tag = if ($e.State -eq 'Enabled') { '[ON ]' } else { '[off]' }
            $col = if ($e.State -eq 'Enabled') { 'Green' } else { 'DarkGray' }
            Write-Host ("  {0,2}. {1} {2,-22} {3}" -f ($i+1), $tag, $e.Name, $e.Src) -ForegroundColor $col
            $cmd = $e.Command; if ($cmd.Length -gt 70) { $cmd = $cmd.Substring(0,67) + '...' }
            Write-Host ("        $cmd") -ForegroundColor DarkGray
        }
        Write-Host ""
        return $entries
    }

    function Invoke-StartupRevert {
        Write-Head "STARTUP MANAGER  -  reverting"
        if (-not (Test-Path $BackupPath)) { Write-Warn2 "No backup at $BackupPath - nothing to restore."; Write-Host ""; return }
        $b = Get-Content $BackupPath -Raw | ConvertFrom-Json
        foreach ($s in $b.Appr) {
            try {
                if ($s.Existed) {
                    if (-not (Test-Path $s.ApprKey)) { New-Item -Path $s.ApprKey -Force | Out-Null }
                    $bytes = [Convert]::FromBase64String($s.Blob)
                    New-ItemProperty -Path $s.ApprKey -Name $s.ApprValue -PropertyType Binary -Value $bytes -Force | Out-Null
                } else {
                    if (Test-Path $s.ApprKey) { Remove-ItemProperty -Path $s.ApprKey -Name $s.ApprValue -ErrorAction SilentlyContinue }
                }
            } catch {}
        }
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-Ok "Startup states restored."
        Write-Host ""
    }

    # Silent, reversible: disable a curated set of KNOWN heavy consumer startup
    # apps only. A protect-list guards audio / GPU / peripheral / security /
    # driver / laptop-power entries so nothing essential is ever touched.
    function Invoke-StartupCuratedDisable {
        Write-Head "STARTUP MANAGER  -  disabling heavy startup apps (reversible)"
        $disableTokens = @(
            'spotify','discord','steam','epicgames','epic games','epicwebhelper','origin',
            'ea background','eadesktop','battle.net','blizzard','uplay','ubisoft','riot',
            'onedrive','teams','skype','slack','zoom','itunes','icloud','apple push','bonjour',
            'creative cloud','adobe','ccx','acrobat','googleupdate','google update','googledrive',
            'whatsapp','telegram','wechat','utorrent','qbittorrent','bittorrent','ccleaner',
            'jusched','java update','spotifywebhelper','steelseries gg'
        )
        $protectTokens = @(
            'realtek','nahimic','waves','audio','sound','dolby',
            'nvidia','nvcontainer','nvbackend','nvtray','radeon','amd ','intel','igfx','graphics','displaylink',
            'razer','logitech','ghub','logi','corsair','synapse','steelseries engine','mouse','keyboard','wacom',
            'defender','securityhealth','antivirus','eset','kaspersky','bitdefender','malwarebytes','avast','avg',
            'bluetooth','wireless','wlan','touchpad','synaptics','elan','hotkey','fn ','power manager','battery',
            'driver','firmware','vpn','citrix','remote','backup','windows security','vanguard'
        )
        $entries = Get-Entries
        if (-not $entries) { Write-Warn2 "No startup entries found."; Write-Host ""; return }
        Backup-Once
        $changed = 0
        foreach ($e in $entries) {
            if ($e.State -ne 'Enabled') { continue }
            $hay = ("{0} {1}" -f $e.Name, $e.Command).ToLower()
            $prot = $false
            foreach ($p in $protectTokens) { if ($hay.Contains($p)) { $prot = $true; break } }
            if ($prot) { continue }
            $hit = $false
            foreach ($d in $disableTokens) { if ($hay.Contains($d)) { $hit = $true; break } }
            if (-not $hit) { continue }
            Set-ApprovedState $e.ApprKey $e.ApprValue $false
            Write-Ok ("disabled: {0}  ({1})" -f $e.Name, $e.Src)
            $changed++
        }
        if ($changed -eq 0) { Write-Warn2 "No known heavy startup apps were enabled - nothing changed." }
        else { Write-Ok "$changed startup item(s) disabled. Reversible with -Revert."; Write-AuditLog "Startup curated disable ($changed items)" }
        Write-Host ""
    }

    if ($Revert)       { Invoke-StartupRevert; return }
    if ($StartupApply) { Invoke-StartupCuratedDisable; return }
    if ($Status)       { [void](Show-StartupList); return }

    # interactive toggle loop
    do {
        $entries = Show-StartupList
        if (-not $entries) { return }
        Write-Host "  Enter a number to toggle, R to revert all, Q to go back." -ForegroundColor Gray
        $sel = Read-Host "  Select"
        if ($sel -match '^[Qq]$') { return }
        elseif ($sel -match '^[Rr]$') { Invoke-StartupRevert }
        elseif ($sel -match '^\d+$' -and [int]$sel -ge 1 -and [int]$sel -le $entries.Count) {
            $e = $entries[[int]$sel - 1]
            Backup-Once
            $enable = ($e.State -ne 'Enabled')
            Set-ApprovedState $e.ApprKey $e.ApprValue $enable
            Write-Ok ("{0} -> {1}" -f $e.Name, $(if($enable){'enabled'}else{'disabled'}))
            Start-Sleep -Milliseconds 400
        } else { Write-Warn2 "Invalid selection." }
    } while ($true)
}

# ===========================================================================
#  TOOL 16 - Storage & Memory  (admin)
#  fsutil (TRIM/last-access/8.3), SSD ReTrim, and RAM-friendly memory tweaks.
# ===========================================================================
function Invoke-Storage {
    [CmdletBinding()]
    param(
        [switch]$Status,
        [switch]$Revert,
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'Storage-Memory.backup.json')
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Status) { $extra.Status = $true }
        if ($Revert) { $extra.Revert = $true }
        Restart-Elevated -ToolName 'Storage' -Extra $extra
        return
    }

    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    $MemMgmt = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
    $MemTweaks = @(
        @{ Name='DisablePagingExecutive';  Value=1; Label='Keep kernel in RAM' }
        @{ Name='ClearPageFileAtShutdown'; Value=0; Label='No pagefile wipe at shutdown' }
    )

    function Get-Fsutil {
        param([string]$Setting)
        $out = (fsutil behavior query $Setting) 2>$null | Out-String
        if ($out -match '=\s*(\d+)') { return [int]$Matches[1] }
        return $null
    }
    function Get-RegSnap {
        param($Name)
        $o = @{ Name=$Name; Existed=$false; Value=$null }
        try { $o.Value=[int64]((Get-ItemProperty -Path $MemMgmt -Name $Name -ErrorAction Stop).$Name); $o.Existed=$true } catch {}
        return $o
    }
    function Set-RegVal {
        param($Name,$Value)
        New-ItemProperty -Path $MemMgmt -Name $Name -PropertyType DWord -Value ([int64]$Value) -Force | Out-Null
    }
    function Get-SSDs {
        try { Get-PhysicalDisk -ErrorAction Stop | Where-Object { $_.MediaType -eq 'SSD' } } catch { @() }
    }

    function Invoke-StorageStatus {
        Write-Head "STORAGE & MEMORY  -  status"
        $trim = Get-Fsutil 'disabledeletenotify'
        if ($trim -eq 0) { Write-Ok ("{0,-28} enabled" -f 'TRIM (delete notify)') } else { Write-Warn2 ("{0,-28} {1}" -f 'TRIM', $trim) }
        $la = Get-Fsutil 'disablelastaccess'
        Write-Host ("      disablelastaccess = {0}   disable8dot3 = {1}" -f $la, (Get-Fsutil 'disable8dot3')) -ForegroundColor DarkGray
        foreach ($m in $MemTweaks) {
            $s = Get-RegSnap $m.Name
            $cur = if ($s.Existed) { $s.Value } else { '<default>' }
            if ($s.Existed -and $s.Value -eq $m.Value) { Write-Ok ("{0,-28} {1}" -f $m.Label, $cur) } else { Write-Warn2 ("{0,-28} {1} (want {2})" -f $m.Label, $cur, $m.Value) }
        }
        $ssd = Get-SSDs
        Write-Host ("      SSDs detected: {0}" -f $(if($ssd){($ssd.FriendlyName -join ', ')}else{'none/unknown'})) -ForegroundColor DarkGray
        Write-Host ""
    }

    function Invoke-StorageApply {
        Write-Head "STORAGE & MEMORY  -  applying"
        if (Test-Path $BackupPath) {
            Write-Warn2 "Existing backup kept as restore point: $BackupPath"
        } else {
            Write-Step "Backing up current fsutil + memory settings..."
            $fs = @{
                disabledeletenotify = (Get-Fsutil 'disabledeletenotify')
                disablelastaccess   = (Get-Fsutil 'disablelastaccess')
                disable8dot3        = (Get-Fsutil 'disable8dot3')
            }
            $reg = @(foreach ($m in $MemTweaks) { Get-RegSnap $m.Name })
            ([pscustomobject]@{ Fsutil=$fs; Reg=$reg }) | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8
            Write-Ok "Backup saved -> $BackupPath"
        }

        Write-Step "Applying filesystem tweaks (TRIM on, last-access off, no 8.3)..."
        fsutil behavior set disabledeletenotify 0 *> $null; Write-Ok "TRIM enabled"
        fsutil behavior set disablelastaccess 1   *> $null; Write-Ok "Last-access updates off"
        fsutil behavior set disable8dot3 1         *> $null; Write-Ok "8.3 short-name creation off (new files)"

        Write-Step "Applying memory tweaks..."
        foreach ($m in $MemTweaks) { try { Set-RegVal $m.Name $m.Value; Write-Ok ("{0} = {1}" -f $m.Label, $m.Value) } catch { Write-Bad ("{0}: {1}" -f $m.Label, $_.Exception.Message) } }

        $ssd = Get-SSDs
        if ($ssd) {
            Write-Step "Running ReTrim on SSD volume(s)..."
            foreach ($v in (Get-Volume | Where-Object { $_.DriveLetter -and $_.DriveType -eq 'Fixed' })) {
                try { Optimize-Volume -DriveLetter $v.DriveLetter -ReTrim -ErrorAction Stop; Write-Ok ("ReTrim {0}:" -f $v.DriveLetter) } catch {}
            }
        }

        Write-Host ""
        Write-Host "  ############################################################" -ForegroundColor Green
        Write-Host "  #              STORAGE & MEMORY - APPLIED                  #" -ForegroundColor Green
        Write-Host "  ############################################################" -ForegroundColor Green
        Write-Warn2 "Reboot for DisablePagingExecutive / filesystem flags to fully apply."
        Invoke-StorageStatus
    }

    function Invoke-StorageRevert {
        Write-Head "STORAGE & MEMORY  -  reverting"
        if (-not (Test-Path $BackupPath)) { Write-Bad "No backup at $BackupPath - nothing to restore."; Write-Host ""; return }
        $b = Get-Content $BackupPath -Raw | ConvertFrom-Json
        if ($null -ne $b.Fsutil.disabledeletenotify) { fsutil behavior set disabledeletenotify $b.Fsutil.disabledeletenotify *> $null }
        if ($null -ne $b.Fsutil.disablelastaccess)   { fsutil behavior set disablelastaccess  $b.Fsutil.disablelastaccess   *> $null }
        if ($null -ne $b.Fsutil.disable8dot3)        { fsutil behavior set disable8dot3       $b.Fsutil.disable8dot3        *> $null }
        Write-Ok "Filesystem flags restored"
        foreach ($r in $b.Reg) {
            try {
                if ($r.Existed) { Set-RegVal $r.Name ([int64]$r.Value) }
                else { Remove-ItemProperty -Path $MemMgmt -Name $r.Name -ErrorAction SilentlyContinue }
            } catch {}
        }
        Write-Ok "Memory settings restored"
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-Head "REVERT COMPLETE"
        Write-Warn2 "Reboot to fully restore."
        Write-Host ""
    }

    if     ($Status) { Invoke-StorageStatus }
    elseif ($Revert) { Invoke-StorageRevert }
    else             { Invoke-StorageApply }
}

# ===========================================================================
#  TOOL 17 - Per-game priority (IFEO)  (admin)
#  Persistently sets High CPU priority for chosen executables via Image File
#  Execution Options PerfOptions. Never touches the Debugger value. Reversible.
# ===========================================================================
function Invoke-GameProfile {
    [CmdletBinding()]
    param(
        [switch]$Status,
        [switch]$Revert,
        [switch]$GameLoopPreset,
        [string]$AddGame,
        [ValidateSet('High','AboveNormal')][string]$Priority = 'High',
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'GameProfile-IFEO.backup.json')
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Status)         { $extra.Status = $true }
        if ($Revert)         { $extra.Revert = $true }
        if ($GameLoopPreset) { $extra.GameLoopPreset = $true }
        if ($AddGame)        { $extra.AddGame = $AddGame; $extra.Priority = $Priority }
        Restart-Elevated -ToolName 'GameProfile' -Extra $extra
        return
    }

    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    $IFEO = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options'
    $PrioMap = @{ High = 3; AboveNormal = 6 }
    $GameLoopExes = @('AndroidEmulator.exe','AndroidEmulatorEx.exe','AndroidEmulatorEn.exe','GameLoop.exe','aow_exe.exe')

    function Read-Tracked {
        if (Test-Path $BackupPath) {
            try { return @((Get-Content $BackupPath -Raw | ConvertFrom-Json).Items) } catch { return @() }
        }
        return @()
    }
    function Save-Tracked {
        param($Items)
        ([pscustomobject]@{ Items=@($Items) }) | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8
    }

    function Add-Priority {
        param([string]$Exe)
        $exeKey = Join-Path $IFEO $Exe
        $perf   = Join-Path $exeKey 'PerfOptions'
        $keyExisted  = Test-Path $exeKey
        $perfExisted = Test-Path $perf
        if (-not (Test-Path $perf)) { New-Item -Path $perf -Force | Out-Null }
        New-ItemProperty -Path $perf -Name 'CpuPriorityClass' -PropertyType DWord -Value $PrioMap[$Priority] -Force | Out-Null

        $tracked = @(Read-Tracked | Where-Object { $_.Exe -ne $Exe })
        $tracked += @{ Exe=$Exe; KeyExisted=$keyExisted; PerfExisted=$perfExisted; Priority=$Priority }
        Save-Tracked $tracked
        Write-Ok ("{0} -> {1} priority" -f $Exe, $Priority)
    }

    function Remove-Priority {
        param($Entry)
        $exeKey = Join-Path $IFEO $Entry.Exe
        $perf   = Join-Path $exeKey 'PerfOptions'
        try {
            if (Test-Path $perf) { Remove-ItemProperty -Path $perf -Name 'CpuPriorityClass' -ErrorAction SilentlyContinue }
            if (-not $Entry.PerfExisted -and (Test-Path $perf)) {
                # remove PerfOptions only if it has no other values/subkeys
                $hasVals = (Get-Item $perf).Property.Count -gt 0
                $hasSubs = (Get-ChildItem $perf -ErrorAction SilentlyContinue).Count -gt 0
                if (-not $hasVals -and -not $hasSubs) { Remove-Item -Path $perf -Force -ErrorAction SilentlyContinue }
            }
            if (-not $Entry.KeyExisted -and (Test-Path $exeKey)) {
                $hasVals = (Get-Item $exeKey).Property.Count -gt 0
                $hasSubs = (Get-ChildItem $exeKey -ErrorAction SilentlyContinue).Count -gt 0
                if (-not $hasVals -and -not $hasSubs) { Remove-Item -Path $exeKey -Force -ErrorAction SilentlyContinue }
            }
            Write-Ok ("Cleared priority for {0}" -f $Entry.Exe)
        } catch { Write-Warn2 ("{0}: {1}" -f $Entry.Exe, $_.Exception.Message) }
    }

    function Invoke-GpStatus {
        Write-Head "PER-GAME PRIORITY (IFEO)  -  status"
        $tracked = Read-Tracked
        if (-not $tracked) { Write-Warn2 "No managed game priorities set."; Write-Host ""; return }
        foreach ($t in $tracked) {
            $perf = Join-Path (Join-Path $IFEO $t.Exe) 'PerfOptions'
            $val = $null
            try { $val = (Get-ItemProperty -Path $perf -Name 'CpuPriorityClass' -ErrorAction Stop).CpuPriorityClass } catch {}
            $name = ($PrioMap.GetEnumerator() | Where-Object { $_.Value -eq $val } | Select-Object -First 1).Key
            if ($val) { Write-Ok ("{0,-26} {1} (CpuPriorityClass={2})" -f $t.Exe, $name, $val) }
            else { Write-Warn2 ("{0,-26} not currently set" -f $t.Exe) }
        }
        Write-Host ""
    }

    function Invoke-GpRevert {
        Write-Head "PER-GAME PRIORITY (IFEO)  -  reverting"
        $tracked = Read-Tracked
        if (-not $tracked) { Write-Warn2 "Nothing to revert."; Write-Host ""; return }
        foreach ($t in $tracked) { Remove-Priority $t }
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-Head "REVERT COMPLETE"
        Write-Host ""
    }

    if ($Status) { Invoke-GpStatus; return }
    if ($Revert) { Invoke-GpRevert; return }

    if ($GameLoopPreset) {
        Write-Head "PER-GAME PRIORITY (IFEO)  -  GameLoop preset"
        foreach ($e in $GameLoopExes) { Add-Priority $e }
        Write-Warn2 "Applies on next launch of those processes. Use Revert to undo."
        Write-Host ""
        return
    }
    if ($AddGame) {
        Write-Head "PER-GAME PRIORITY (IFEO)"
        $exe = $AddGame.Trim()
        if ($exe -notmatch '\.exe$') { $exe = "$exe.exe" }
        Add-Priority $exe
        Write-Host ""
        return
    }

    # interactive
    do {
        Write-Head "PER-GAME PRIORITY (IFEO)"
        Write-Host "   1.  Apply GameLoop preset (High priority for GameLoop engines)"
        Write-Host "   2.  Add a custom .exe (High priority)"
        Write-Host "   3.  Status"
        Write-Host "   4.  Revert all"
        Write-Host "   Q.  Back"
        $c = Read-Host "  Select"
        switch ($c.ToUpper()) {
            '1' { foreach ($e in $GameLoopExes) { Add-Priority $e }; Pause-Any }
            '2' { $n = Read-Host "  Executable name (e.g. game.exe)"; if ($n) { $exe=$n.Trim(); if ($exe -notmatch '\.exe$'){$exe="$exe.exe"}; Add-Priority $exe }; Pause-Any }
            '3' { Invoke-GpStatus; Pause-Any }
            '4' { Invoke-GpRevert; Pause-Any }
            'Q' { return }
            default { Write-Warn2 "Invalid." }
        }
    } while ($true)
}

# ===========================================================================
#  TOOL 18 - Latency & Interrupts  (admin)
#  Read-only DPC/latency advisor (built-in only) + optional MSI-mode enable
#  for the GPU/NIC (the main reversible interrupt-latency lever).
#  There is no built-in real-time DPC monitor (that needs a 3rd-party tool);
#  this reports the factors that drive DPC latency and what to fix.
# ===========================================================================
function Invoke-Latency {
    [CmdletBinding()]
    param(
        [switch]$Status,
        [switch]$Revert,
        [switch]$Trace,        # run powercfg /energy (60s) and point to the report
        [switch]$EnableMSI,    # enable message-signaled interrupts for GPU + NIC (reboot)
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'Latency-MSI.backup.json')
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Status)    { $extra.Status = $true }
        if ($Revert)    { $extra.Revert = $true }
        if ($Trace)     { $extra.Trace = $true }
        if ($EnableMSI) { $extra.EnableMSI = $true }
        Restart-Elevated -ToolName 'Latency' -Extra $extra
        return
    }

    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    function Get-MsiPath { param([string]$Id) "HKLM:\SYSTEM\CurrentControlSet\Enum\$Id\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" }
    function Get-MsiState {
        param([string]$Id)
        $p = Get-MsiPath $Id
        try { return [int]((Get-ItemProperty -Path $p -Name MSISupported -ErrorAction Stop).MSISupported) } catch { return $null }
    }
    function Set-MsiState {
        param([string]$Id,[int]$Val)
        $p = Get-MsiPath $Id
        if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
        New-ItemProperty -Path $p -Name 'MSISupported' -PropertyType DWord -Value $Val -Force | Out-Null
    }
    function Get-TargetDevices {
        $list = @()
        foreach ($cls in @('Display','Net')) {
            try {
                Get-PnpDevice -PresentOnly -Class $cls -Status OK -ErrorAction Stop | ForEach-Object {
                    $list += [pscustomobject]@{ Name=$_.FriendlyName; Id=$_.InstanceId; Class=$cls }
                }
            } catch {}
        }
        return $list
    }
    function Get-Bcd { param([string]$E) $o=(bcdedit /enum "{current}") 2>$null | Out-String
        foreach ($l in ($o -split "`r?`n")) { if ($l -match ('^\s*'+[regex]::Escape($E)+'\s+(\S+)')) { return $Matches[1] } }; return $null }
    function To-Date { param($cim) try { [Management.ManagementDateTimeConverter]::ToDateTime($cim).ToString('yyyy-MM-dd') } catch { 'n/a' } }

    function Invoke-LatStatus {
        Write-Head "LATENCY & INTERRUPTS  -  status"
        Write-Host "  Interrupt mode (MSI = lower latency than line-based):" -ForegroundColor Gray
        foreach ($d in (Get-TargetDevices)) {
            $m = Get-MsiState $d.Id
            $txt = if ($null -eq $m) { 'line-based (default)' } elseif ($m -eq 1) { 'MSI (message-signaled)' } else { 'line-based' }
            if ($m -eq 1) { Write-Ok ("[{0}] {1} -> {2}" -f $d.Class, $d.Name, $txt) }
            else { Write-Warn2 ("[{0}] {1} -> {2}" -f $d.Class, $d.Name, $txt) }
        }
        Write-Host ""
        $hlt = Get-Bcd 'hypervisorlaunchtype'; $ddt = Get-Bcd 'disabledynamictick'; $upt = Get-Bcd 'useplatformtick'
        $sch = (powercfg /getactivescheme); $schName = if ($sch -match '\((.+)\)') { $Matches[1] } else { 'Unknown' }
        $hags = try { [int]((Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name HwSchMode -ErrorAction Stop).HwSchMode) } catch { $null }
        Write-Host ("  Power plan      : {0}" -f $schName) -ForegroundColor DarkGray
        Write-Host ("  Boot hypervisor : {0}" -f $(if($hlt){$hlt}else{'Auto'})) -ForegroundColor DarkGray
        Write-Host ("  Boot timer      : disabledynamictick={0}  useplatformtick={1}" -f $(if($ddt){$ddt}else{'default'}), $(if($upt){$upt}else{'default'})) -ForegroundColor DarkGray
        Write-Host ("  HAGS (HwSchMode): {0}" -f $(if($null -eq $hags){'default'}elseif($hags -eq 2){'on'}else{'off'})) -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Driver dates (old GPU/NIC/audio/storage drivers are common DPC offenders):" -ForegroundColor Gray
        try {
            Get-CimInstance Win32_PnPSignedDriver -ErrorAction Stop |
                Where-Object { $_.DeviceClass -in @('DISPLAY','NET','MEDIA','HDC','SCSIADAPTER') -and $_.DriverProviderName -ne 'Microsoft' } |
                Sort-Object DeviceClass | Select-Object -First 12 | ForEach-Object {
                    Write-Host ("    {0,-10} {1,-40} v{2}  {3}" -f $_.DeviceClass, ($_.DeviceName -replace '\s+',' ').Substring(0,[Math]::Min(40,($_.DeviceName).Length)), $_.DriverVersion, (To-Date $_.DriverDate)) -ForegroundColor DarkGray
                }
        } catch { Write-Warn2 "Could not enumerate drivers." }
        Write-Host ""
        Write-Host "  Tips: enable MSI (this tool), keep GPU/chipset/audio drivers current," -ForegroundColor DarkGray
        Write-Host "        use GOD MODE power plan, and run -Trace for a full energy report." -ForegroundColor DarkGray
        Write-Host ""
    }

    function Invoke-LatTrace {
        Write-Head "LATENCY  -  energy report (powercfg /energy, ~60s)"
        $out = Join-Path (Get-WtxDir) ("energy-report_{0}.html" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
        Write-Step "Tracing for 60 seconds - leave the PC idle-ish..."
        try {
            powercfg /energy /duration 60 /output "$out" *> $null
            if (Test-Path $out) {
                Write-Ok "Report saved: $out"
                Write-Host "  Open it and look for red 'Errors' (often high-DPC/ISR drivers)." -ForegroundColor DarkGray
                Write-AuditLog "Latency energy report -> $out"
            } else { Write-Warn2 "powercfg did not produce a report." }
        } catch { Write-Bad "Trace failed: $($_.Exception.Message)" }
        Write-Host ""
    }

    function Invoke-LatEnableMSI {
        Write-Head "LATENCY  -  enabling MSI (message-signaled interrupts)"
        $targets = Get-TargetDevices
        if (-not $targets) { Write-Bad "No GPU/NIC devices found."; Write-Host ""; return }
        if (Test-Path $BackupPath) {
            Write-Warn2 "Existing backup kept as restore point: $BackupPath"
        } else {
            $snap = foreach ($d in $targets) { @{ Id=$d.Id; Name=$d.Name; Class=$d.Class; Existed=($null -ne (Get-MsiState $d.Id)); Value=(Get-MsiState $d.Id) } }
            ([pscustomobject]@{ Dev=@($snap) }) | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8
            Write-Ok "Backup saved -> $BackupPath"
        }
        foreach ($d in $targets) {
            try { Set-MsiState $d.Id 1; Write-Ok ("MSI on: [{0}] {1}" -f $d.Class, $d.Name) }
            catch { Write-Warn2 ("Couldn't set MSI on [{0}] {1} (key may need ownership): {2}" -f $d.Class, $d.Name, $_.Exception.Message) }
        }
        Write-AuditLog "Latency MSI enabled (GPU/NIC)"
        Write-Warn2 "REBOOT required. If anything misbehaves, use Revert."
        Write-Host ""
    }

    function Invoke-LatRevert {
        Write-Head "LATENCY  -  reverting MSI changes"
        if (-not (Test-Path $BackupPath)) { Write-Bad "No backup at $BackupPath - nothing to restore."; Write-Host ""; return }
        $b = Get-Content $BackupPath -Raw | ConvertFrom-Json
        foreach ($d in $b.Dev) {
            try {
                if ($d.Existed) { Set-MsiState $d.Id ([int]$d.Value); Write-Ok ("Restored MSI=$($d.Value): $($d.Name)") }
                else { $p = Get-MsiPath $d.Id; if (Test-Path $p) { Remove-ItemProperty -Path $p -Name MSISupported -ErrorAction SilentlyContinue }; Write-Ok ("Removed MSI override: $($d.Name)") }
            } catch { Write-Warn2 "$($d.Name): $($_.Exception.Message)" }
        }
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-AuditLog "Latency MSI reverted"
        Write-Head "REVERT COMPLETE"
        Write-Warn2 "Reboot to apply."
        Write-Host ""
    }

    if     ($Trace)     { Invoke-LatTrace }
    elseif ($EnableMSI) { Invoke-LatEnableMSI }
    elseif ($Revert)    { Invoke-LatRevert }
    else                { Invoke-LatStatus }
}

# ===========================================================================
#  TOOL 19 - Game Focus & Priority  (no admin needed; run as admin only if the
#  game itself is elevated). Persistent distraction-reduction (notifications/
#  tips off, reversible) + a runtime -Boost to set a game to High priority.
# ===========================================================================
function Invoke-GameFocus {
    [CmdletBinding()]
    param(
        [switch]$Status,
        [switch]$Revert,
        [string]$Boost,        # runtime: set a running game (exe name) to High priority
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'GameFocus.backup.json')
    )

    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    $CDM = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
    $Desired = @(
        @{ Path='HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications'; Name='ToastEnabled';                    Value=0; Label='Toast notifications (ALL apps)' }
        @{ Path=$CDM; Name='SoftLandingEnabled';              Value=0; Label='Tips after updates' }
        @{ Path=$CDM; Name='SubscribedContent-338389Enabled'; Value=0; Label='Suggestions in Settings' }
        @{ Path=$CDM; Name='SubscribedContent-338388Enabled'; Value=0; Label='Suggestions on Start' }
        @{ Path=$CDM; Name='SubscribedContent-310093Enabled'; Value=0; Label='Windows welcome tips' }
    )

    function Get-RegSnap { param($Path,$Name) $o=@{ Path=$Path; Name=$Name; Existed=$false; Value=$null }
        try { $o.Value=[int64]((Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name); $o.Existed=$true } catch {}; return $o }
    function Set-RegVal { param($Path,$Name,$Value)
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value ([int64]$Value) -Force | Out-Null }

    function Invoke-Boost {
        Write-Head "GAME FOCUS  -  boost (runtime, this session only)"
        $name = $Boost -replace '\.exe$',''
        $procs = Get-Process -Name $name -ErrorAction SilentlyContinue
        if (-not $procs) { Write-Warn2 "No running process named '$name'. Start the game first."; Write-Host ""; return }
        foreach ($p in $procs) {
            try { $p.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::High; Write-Ok ("High priority set: {0} (PID {1})" -f $p.ProcessName, $p.Id) }
            catch { Write-Warn2 ("Couldn't set {0} (PID {1}) - run as admin if the game is elevated: {2}" -f $p.ProcessName, $p.Id, $_.Exception.Message) }
        }
        Write-Host "  (Session-only: priority resets when the game restarts. Use tool 17 for a" -ForegroundColor DarkGray
        Write-Host "   persistent High-priority setting via Image File Execution Options.)" -ForegroundColor DarkGray
        Write-Host ""
    }

    function Invoke-FocusStatus {
        Write-Head "GAME FOCUS  -  status"
        foreach ($d in $Desired) {
            $s = Get-RegSnap $d.Path $d.Name
            $cur = if ($s.Existed) { $s.Value } else { '<default on>' }
            if ($s.Existed -and $s.Value -eq 0) { Write-Ok ("{0,-30} off" -f $d.Label) } else { Write-Warn2 ("{0,-30} {1}" -f $d.Label, $cur) }
        }
        Write-Host "  Use:  -Boost game.exe   to set a running game to High priority." -ForegroundColor DarkGray
        Write-Host ""
    }

    function Invoke-FocusApply {
        Write-Head "GAME FOCUS  -  applying (notifications/tips off)"
        Write-Warn2 "This turns off ALL toast notifications (Discord/Steam pings too)."
        if (Test-Path $BackupPath) {
            Write-Warn2 "Existing backup kept as restore point: $BackupPath"
        } else {
            $snap = @(foreach ($d in $Desired) { Get-RegSnap $d.Path $d.Name })
            ([pscustomobject]@{ Reg=$snap }) | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8
            Write-Ok "Backup saved -> $BackupPath"
        }
        foreach ($d in $Desired) {
            try { Set-RegVal $d.Path $d.Name $d.Value; Write-Ok ("{0} off" -f $d.Label) }
            catch { Write-Bad ("{0}: {1}" -f $d.Label, $_.Exception.Message) }
        }
        Write-AuditLog "GameFocus distraction tweaks applied"
        Write-Host ""
        Write-Host "  Notifications/tips off. Use -Revert to restore." -ForegroundColor Green
        Write-Host ""
    }

    function Invoke-FocusRevert {
        Write-Head "GAME FOCUS  -  reverting"
        if (-not (Test-Path $BackupPath)) { Write-Bad "No backup at $BackupPath - nothing to restore."; Write-Host ""; return }
        $b = Get-Content $BackupPath -Raw | ConvertFrom-Json
        foreach ($s in $b.Reg) {
            try {
                if ($s.Existed) { Set-RegVal $s.Path $s.Name $s.Value; Write-Ok "Restored $($s.Name)" }
                else { if (Test-Path $s.Path) { Remove-ItemProperty -Path $s.Path -Name $s.Name -ErrorAction SilentlyContinue }; Write-Ok "Removed $($s.Name) (was default)" }
            } catch { Write-Bad "$($s.Name): $($_.Exception.Message)" }
        }
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-AuditLog "GameFocus distraction tweaks reverted"
        Write-Head "REVERT COMPLETE"
        Write-Host ""
    }

    if     ($Boost)  { Invoke-Boost }
    elseif ($Status) { Invoke-FocusStatus }
    elseif ($Revert) { Invoke-FocusRevert }
    else             { Invoke-FocusApply }
}

# ===========================================================================
#  TOOL 20 - Audio  (admin)
#  Disable per-endpoint audio enhancements and set communications ducking to
#  "Do nothing" to reduce stutter/glitches. Reversible.
# ===========================================================================
function Invoke-Audio {
    [CmdletBinding()]
    param(
        [switch]$Status,
        [switch]$Revert,
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'Audio.backup.json')
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Status) { $extra.Status = $true }
        if ($Revert) { $extra.Revert = $true }
        Restart-Elevated -ToolName 'Audio' -Extra $extra
        return
    }

    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    $RenderRoot   = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render'
    $RelRoot      = 'SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render'
    $FxDisableKey = '{1da5d803-d492-4edd-8c23-e0c0ffee7f0e},5'   # PKEY_AudioEndpoint_Disable_SysFx
    $NameKeys     = @('{a45c254e-df1c-4efd-8020-67d146a850e0},2','{a45c254e-df1c-4efd-8020-67d146a850e0},14')
    $DuckKey      = 'HKCU:\SOFTWARE\Microsoft\Multimedia\Audio'
    $DuckName     = 'UserDuckingPreference'

    # MMDevices Properties keys are owned by the system; an admin must take
    # ownership before writing. This enables that privilege via P/Invoke.
    try {
        if (-not ('WtxRegOwn' -as [type])) {
            Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class WtxRegOwn {
  [StructLayout(LayoutKind.Sequential)] struct LUID { public uint Lo; public int Hi; }
  [StructLayout(LayoutKind.Sequential)] struct TP { public int Count; public LUID Luid; public int Attr; }
  [DllImport("advapi32.dll", SetLastError=true)] static extern bool OpenProcessToken(IntPtr h, uint a, out IntPtr t);
  [DllImport("advapi32.dll", SetLastError=true, CharSet=CharSet.Unicode)] static extern bool LookupPrivilegeValue(string s, string n, out LUID l);
  [DllImport("advapi32.dll", SetLastError=true)] static extern bool AdjustTokenPrivileges(IntPtr t, bool d, ref TP p, int len, IntPtr prev, IntPtr rl);
  [DllImport("kernel32.dll")] static extern IntPtr GetCurrentProcess();
  public static void EnablePrivilege(string name) {
    IntPtr tok;
    if (!OpenProcessToken(GetCurrentProcess(), 0x28, out tok)) return;
    TP tp = new TP(); tp.Count = 1; tp.Attr = 0x2;
    LUID luid; if (!LookupPrivilegeValue(null, name, out luid)) return;
    tp.Luid = luid;
    AdjustTokenPrivileges(tok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
  }
}
"@
        }
    } catch {}

    function Take-Own {
        param([string]$RelPath)
        try { [WtxRegOwn]::EnablePrivilege('SeTakeOwnershipPrivilege'); [WtxRegOwn]::EnablePrivilege('SeRestorePrivilege') } catch {}
        $admins = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::BuiltinAdministratorsSid, $null)
        $k = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($RelPath, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree, [System.Security.AccessControl.RegistryRights]::TakeOwnership)
        if ($k) { $a = $k.GetAccessControl([System.Security.AccessControl.AccessControlSections]::None); $a.SetOwner($admins); $k.SetAccessControl($a); $k.Close() }
        $k2 = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($RelPath, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree, [System.Security.AccessControl.RegistryRights]::ChangePermissions)
        if ($k2) { $a2 = $k2.GetAccessControl(); $rule = New-Object System.Security.AccessControl.RegistryAccessRule($admins,'FullControl','ContainerInherit','None','Allow'); $a2.ResetAccessRule($rule); $k2.SetAccessControl($a2); $k2.Close() }
    }
    function Set-OwnedDword {
        param([string]$PropPath,[string]$RelPath,[string]$Name,[int]$Value)
        try { New-ItemProperty -Path $PropPath -Name $Name -PropertyType DWord -Value $Value -Force -ErrorAction Stop | Out-Null; return $true } catch {}
        try { Take-Own $RelPath } catch { return $false }
        try { New-ItemProperty -Path $PropPath -Name $Name -PropertyType DWord -Value $Value -Force -ErrorAction Stop | Out-Null; return $true } catch { return $false }
    }
    function Remove-Owned {
        param([string]$PropPath,[string]$RelPath,[string]$Name)
        try { Remove-ItemProperty -Path $PropPath -Name $Name -ErrorAction Stop; return $true } catch {}
        try { Take-Own $RelPath } catch { return $false }
        try { Remove-ItemProperty -Path $PropPath -Name $Name -ErrorAction SilentlyContinue; return $true } catch { return $false }
    }

    function Get-Active {
        $out = @()
        Get-ChildItem $RenderRoot -ErrorAction SilentlyContinue | ForEach-Object {
            $state = $null
            try { $state = (Get-ItemProperty -Path $_.PSPath -Name DeviceState -ErrorAction Stop).DeviceState } catch {}
            if ($state -ne 1) { return }
            $propPath = Join-Path $_.PSPath 'Properties'
            $rel = "$RelRoot\$($_.PSChildName)\Properties"
            $nm = $null
            foreach ($nk in $NameKeys) { try { $nm = (Get-ItemProperty -Path $propPath -Name $nk -ErrorAction Stop).$nk; if ($nm) { break } } catch {} }
            if (-not $nm) { $nm = $_.PSChildName }
            $out += [pscustomobject]@{ PropPath=$propPath; RelPath=$rel; Name=$nm }
        }
        return $out
    }
    function Get-FxState { param($PropPath) try { [int]((Get-ItemProperty -Path $PropPath -Name $FxDisableKey -ErrorAction Stop).$FxDisableKey) } catch { $null } }

    function Restart-Audio {
        Write-Step "Restarting the audio service..."
        try { Restart-Service -Name Audiosrv -Force -ErrorAction Stop; Write-Ok "Audio service restarted" }
        catch { Write-Warn2 "Couldn't restart Audiosrv automatically - sign out/in to apply." }
    }

    function Invoke-AudioStatus {
        Write-Head "AUDIO  -  status"
        $eps = Get-Active
        if (-not $eps) { Write-Warn2 "No active playback endpoints found." }
        foreach ($e in $eps) {
            $fx = Get-FxState $e.PropPath
            if ($fx -eq 1) { Write-Ok ("{0,-34} enhancements OFF" -f $e.Name) } else { Write-Warn2 ("{0,-34} enhancements on/default" -f $e.Name) }
        }
        $duck = try { [int]((Get-ItemProperty -Path $DuckKey -Name $DuckName -ErrorAction Stop).$DuckName) } catch { $null }
        $dtxt = switch ($duck) { 0 {'reduce 80%'} 1 {'mute others'} 3 {'do nothing (best for gaming)'} default {'default (reduce)'} }
        Write-Host ("  Communications ducking: {0}" -f $dtxt) -ForegroundColor DarkGray
        Write-Host ""
    }

    function Invoke-AudioApply {
        Write-Head "AUDIO  -  applying (enhancements off, ducking off)"
        $eps = Get-Active
        if (Test-Path $BackupPath) {
            Write-Warn2 "Existing backup kept as restore point: $BackupPath"
        } else {
            $epSnap = foreach ($e in $eps) { @{ PropPath="$($e.PropPath)"; RelPath="$($e.RelPath)"; Name=$e.Name; Existed=($null -ne (Get-FxState $e.PropPath)); Value=(Get-FxState $e.PropPath) } }
            $duckExisted = $false; $duckVal = $null
            try { $duckVal = [int]((Get-ItemProperty -Path $DuckKey -Name $DuckName -ErrorAction Stop).$DuckName); $duckExisted = $true } catch {}
            ([pscustomobject]@{ Ep=@($epSnap); DuckExisted=$duckExisted; DuckValue=$duckVal }) | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8
            Write-Ok "Backup saved -> $BackupPath"
        }

        Write-Step "Disabling enhancements on active playback devices..."
        foreach ($e in $eps) {
            if (Set-OwnedDword -PropPath $e.PropPath -RelPath $e.RelPath -Name $FxDisableKey -Value 1) { Write-Ok ("enhancements off: {0}" -f $e.Name) }
            else { Write-Warn2 ("could not write {0} (key protected) - toggle 'Disable all enhancements' in Settings > Sound for it" -f $e.Name) }
        }

        Write-Step "Setting communications ducking to 'Do nothing'..."
        try {
            if (-not (Test-Path $DuckKey)) { New-Item -Path $DuckKey -Force | Out-Null }
            New-ItemProperty -Path $DuckKey -Name $DuckName -PropertyType DWord -Value 3 -Force | Out-Null
            Write-Ok "Ducking = do nothing"
        } catch { Write-Warn2 "Couldn't set ducking: $($_.Exception.Message)" }

        Restart-Audio
        Write-AuditLog "Audio enhancements off + ducking off"
        Write-Host ""
        Write-Host "  Done. If a device is added later, re-run to cover it." -ForegroundColor Green
        Write-Host ""
    }

    function Invoke-AudioRevert {
        Write-Head "AUDIO  -  reverting"
        if (-not (Test-Path $BackupPath)) { Write-Bad "No backup at $BackupPath - nothing to restore."; Write-Host ""; return }
        $b = Get-Content $BackupPath -Raw | ConvertFrom-Json
        foreach ($e in $b.Ep) {
            $ok = if ($e.Existed) { Set-OwnedDword -PropPath $e.PropPath -RelPath $e.RelPath -Name $FxDisableKey -Value ([int]$e.Value) }
                  else            { Remove-Owned   -PropPath $e.PropPath -RelPath $e.RelPath -Name $FxDisableKey }
            if ($ok) { Write-Ok "Restored enhancements: $($e.Name)" } else { Write-Warn2 "Could not restore $($e.Name) (key protected)" }
        }
        try {
            if ($b.DuckExisted) { New-ItemProperty -Path $DuckKey -Name $DuckName -PropertyType DWord -Value ([int]$b.DuckValue) -Force | Out-Null }
            else { if (Test-Path $DuckKey) { Remove-ItemProperty -Path $DuckKey -Name $DuckName -ErrorAction SilentlyContinue } }
            Write-Ok "Restored ducking preference"
        } catch {}
        Restart-Audio
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-AuditLog "Audio settings reverted"
        Write-Head "REVERT COMPLETE"
        Write-Host ""
    }

    if     ($Status) { Invoke-AudioStatus }
    elseif ($Revert) { Invoke-AudioRevert }
    else             { Invoke-AudioApply }
}

# ===========================================================================
#  TOOL 21 - Display & Fullscreen  (admin)
#  Disable Fullscreen Optimizations system-wide, enable the flip-model
#  "optimizations for windowed games", optional MPO disable. Reversible.
# ===========================================================================
function Invoke-Display {
    [CmdletBinding()]
    param(
        [switch]$Status,
        [switch]$Revert,
        [switch]$DisableMPO,    # multi-plane overlay off (fixes some flicker/stutter)
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'Display.backup.json')
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Status)     { $extra.Status = $true }
        if ($Revert)     { $extra.Revert = $true }
        if ($DisableMPO) { $extra.DisableMPO = $true }
        Restart-Elevated -ToolName 'Display' -Extra $extra
        return
    }

    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    $GCS = 'HKCU:\System\GameConfigStore'
    $DX  = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'
    $DWM = 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm'
    $DXName  = 'DirectXUserGlobalSettings'
    $DXValue = 'SwapEffectUpgradeEnable=1;VRROptimizeEnable=1;'
    $MpoName = 'OverlayTestMode'

    $FsoDwords = @(
        @{ Name='GameDVR_FSEBehaviorMode';             Value=2; Label='Fullscreen optimizations off' }
        @{ Name='GameDVR_HonorUserFSEBehaviorMode';    Value=1; Label='Honor user FSE choice' }
        @{ Name='GameDVR_DXGIHonorFSEWindowsCompatible'; Value=1; Label='DXGI FSE compatible' }
        @{ Name='GameDVR_EFSEFeatureFlags';            Value=0; Label='EFSE feature flags' }
    )

    function Get-Snap {
        param($Path,$Name)
        $o = @{ Path=$Path; Name=$Name; Existed=$false; Type=$null; Value=$null }
        try {
            $raw = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
            $o.Existed=$true
            if ($raw -is [string]) { $o.Type='String'; $o.Value=[string]$raw } else { $o.Type='DWord'; $o.Value=[int64]$raw }
        } catch {}
        return $o
    }
    function Set-Val {
        param($Path,$Name,$Type,$Value)
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        if ($Type -eq 'String') { New-ItemProperty -Path $Path -Name $Name -PropertyType String -Value ([string]$Value) -Force | Out-Null }
        else                    { New-ItemProperty -Path $Path -Name $Name -PropertyType DWord  -Value ([int64]$Value) -Force | Out-Null }
    }

    function Invoke-DispStatus {
        Write-Head "DISPLAY & FULLSCREEN  -  status"
        foreach ($d in $FsoDwords) {
            $s = Get-Snap $GCS $d.Name
            if ($s.Existed -and $s.Value -eq $d.Value) { Write-Ok ("{0,-32} OK" -f $d.Label) } else { Write-Warn2 ("{0,-32} {1}" -f $d.Label, $(if($s.Existed){$s.Value}else{'<default>'})) }
        }
        $dx = Get-Snap $DX $DXName
        if ($dx.Existed -and $dx.Value -match 'SwapEffectUpgradeEnable=1') { Write-Ok ("{0,-32} on" -f 'Windowed-games optimization') } else { Write-Warn2 ("{0,-32} {1}" -f 'Windowed-games optimization', $(if($dx.Existed){'off'}else{'default'})) }
        $mpo = Get-Snap $DWM $MpoName
        Write-Host ("      MPO (OverlayTestMode) = {0}" -f $(if($mpo.Existed -and $mpo.Value -eq 5){'disabled'}elseif($mpo.Existed){$mpo.Value}else{'default (enabled)'})) -ForegroundColor DarkGray
        Write-Host ""
    }

    function Invoke-DispApply {
        Write-Head "DISPLAY & FULLSCREEN  -  applying"
        if (Test-Path $BackupPath) {
            Write-Warn2 "Existing backup kept as restore point: $BackupPath"
        } else {
            $snap = @()
            foreach ($d in $FsoDwords) { $snap += Get-Snap $GCS $d.Name }
            $snap += Get-Snap $DX $DXName
            $snap += Get-Snap $DWM $MpoName
            ([pscustomobject]@{ Reg=$snap }) | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8
            Write-Ok "Backup saved -> $BackupPath"
        }

        Write-Step "Disabling Fullscreen Optimizations system-wide..."
        foreach ($d in $FsoDwords) {
            try { Set-Val $GCS $d.Name 'DWord' $d.Value; Write-Ok ("{0}" -f $d.Label) } catch { Write-Bad ("{0}: {1}" -f $d.Label, $_.Exception.Message) }
        }
        Write-Step "Enabling windowed-games optimization (flip model + VRR)..."
        try { Set-Val $DX $DXName 'String' $DXValue; Write-Ok "Windowed-games optimization on" } catch { Write-Bad $_.Exception.Message }

        if ($DisableMPO) {
            Write-Step "Disabling multi-plane overlay (MPO)..."
            try { Set-Val $DWM $MpoName 'DWord' 5; Write-Ok "MPO disabled (reboot/restart DWM to apply)" } catch { Write-Bad $_.Exception.Message }
        }

        Write-AuditLog "Display/Fullscreen tweaks applied (MPO=$DisableMPO)"
        Write-Host ""
        Write-Host "  Done. Sign out/in (or reboot) so all apps pick up the FSO change." -ForegroundColor Green
        Write-Host ""
    }

    function Invoke-DispRevert {
        Write-Head "DISPLAY & FULLSCREEN  -  reverting"
        if (-not (Test-Path $BackupPath)) { Write-Bad "No backup at $BackupPath - nothing to restore."; Write-Host ""; return }
        $b = Get-Content $BackupPath -Raw | ConvertFrom-Json
        foreach ($s in $b.Reg) {
            try {
                if ($s.Existed) { Set-Val $s.Path $s.Name $s.Type $s.Value; Write-Ok "Restored $($s.Name)" }
                else { if (Test-Path $s.Path) { Remove-ItemProperty -Path $s.Path -Name $s.Name -ErrorAction SilentlyContinue }; Write-Ok "Removed $($s.Name) (was default)" }
            } catch { Write-Bad "$($s.Name): $($_.Exception.Message)" }
        }
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-AuditLog "Display/Fullscreen tweaks reverted"
        Write-Head "REVERT COMPLETE"
        Write-Host ""
    }

    if     ($Status) { Invoke-DispStatus }
    elseif ($Revert) { Invoke-DispRevert }
    else             { Invoke-DispApply }
}

# ===========================================================================
#  TOOL 22 - Game Rules (Process-Lasso-style)  (admin)
#  Persistent priority is handled by tool 17 (IFEO). This adds what IFEO can't:
#  per-game CPU AFFINITY (and re-asserted priority) applied to RUNNING games by
#  a lightweight scheduled-task watcher - the built-in equivalent of Lasso's
#  service. Default OFF; it is a background task. On a 6-core CPU affinity gains
#  are usually marginal - priority (tool 17) matters more.
# ===========================================================================
function Invoke-GameRules {
    [CmdletBinding()]
    param(
        [switch]$Status,
        [switch]$Revert,
        [switch]$Daemon,        # internal: one silent pass (the scheduled task calls this)
        [switch]$Install,       # register the background watcher task
        [switch]$Uninstall,     # remove the watcher task
        [switch]$ApplyNow,      # apply rules to running games once, right now
        [switch]$GameLoopPreset, # add High-priority rules for all GameLoop engines + install watcher
        [string]$AddRule,       # exe name to add/update a rule for
        [ValidateSet('High','AboveNormal','Normal','BelowNormal','Idle')][string]$Priority = 'High',
        [string]$Cores,         # e.g. "0-5" or "2,3,4,5" (affinity); empty = all cores
        [string]$RemoveRule,    # exe name to remove
        [int]$IntervalMin = 2,
        [string]$RulesPath = (Join-Path $env:USERPROFILE 'GameRules.json')
    )

    $TaskName = 'WinToolbox GameRules'
    # A tiny auto-generated VBScript launches the daemon fully hidden via wscript
    # //B, so the every-N-minutes watcher pass never flashes a console window
    # (powershell.exe -WindowStyle Hidden alone still flashes conhost on launch).
    $DaemonVbs = Join-Path (Get-WtxDir) 'GameRulesDaemon.vbs'

    function Read-Rules { if (Test-Path $RulesPath) { try { @((Get-Content $RulesPath -Raw | ConvertFrom-Json).Rules) } catch { @() } } else { @() } }
    function Save-Rules { param($R) ([pscustomobject]@{ Rules=@($R) }) | ConvertTo-Json -Depth 6 | Set-Content $RulesPath -Encoding UTF8 }
    function ConvertTo-Mask {
        param([string]$Spec)
        $mask = [int64]0
        foreach ($part in ($Spec -split ',')) {
            $part = $part.Trim()
            if ($part -match '^(\d+)-(\d+)$') { for ($i=[int]$Matches[1]; $i -le [int]$Matches[2]; $i++) { $mask = $mask -bor ([int64]1 -shl $i) } }
            elseif ($part -match '^\d+$')      { $mask = $mask -bor ([int64]1 -shl [int]$part) }
        }
        return $mask
    }
    function Apply-Once {
        foreach ($rule in (Read-Rules)) {
            $nm = ($rule.Exe -replace '\.exe$','')
            foreach ($p in (Get-Process -Name $nm -ErrorAction SilentlyContinue)) {
                if ($rule.Priority)     { try { $p.PriorityClass = [System.Diagnostics.ProcessPriorityClass]$rule.Priority } catch {} }
                if ($rule.AffinityMask) { $m=[int64]$rule.AffinityMask; if ($m -gt 0) { try { $p.ProcessorAffinity = [IntPtr]$m } catch {} } }
            }
        }
    }

    # Silent single pass for the scheduled task - no elevation prompt, no output.
    if ($Daemon) { Apply-Once; return }

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Status)     { $extra.Status = $true }
        if ($Revert)     { $extra.Revert = $true }
        if ($Install)    { $extra.Install = $true }
        if ($Uninstall)  { $extra.Uninstall = $true }
        if ($ApplyNow)   { $extra.ApplyNow = $true }
        if ($AddRule)    { $extra.AddRule = $AddRule; $extra.Priority = $Priority; if ($Cores) { $extra.Cores = $Cores } }
        if ($RemoveRule) { $extra.RemoveRule = $RemoveRule }
        if ($IntervalMin -ne 2) { $extra.IntervalMin = $IntervalMin }
        Restart-Elevated -ToolName 'GameRules' -Extra $extra
        return
    }

    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    function Test-WatcherInstalled { [bool](Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) }

    function New-DaemonLauncher {
        # Write the hidden launcher .vbs next to the other WinToolbox data files.
        $body = @"
' WinToolbox GameRules hidden daemon launcher (auto-generated - do not edit).
' Runs the priority/affinity pass with no visible window and no console flash.
Dim q : q = Chr(34)
CreateObject("WScript.Shell").Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File " & q & "$PSCommandPath" & q & " -Tool GameRules -Daemon", 0, False
"@
        Set-Content -Path $DaemonVbs -Value $body -Encoding ASCII
    }

    function Install-Watcher {
        $cores = [Environment]::ProcessorCount
        New-DaemonLauncher
        $action  = New-ScheduledTaskAction -Execute 'wscript.exe' `
                    -Argument "//B //Nologo `"$DaemonVbs`""
        $trigger = New-ScheduledTaskTrigger -AtLogOn
        $rep = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes $IntervalMin)
        $trigger.Repetition = $rep.Repetition
        $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Highest
        $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 1) -MultipleInstances IgnoreNew
        Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
        Write-Ok "Watcher installed: applies rules every $IntervalMin min (and at logon), fully hidden."
        Write-Warn2 "This is a background task (like Process Lasso's service). Uninstall anytime."
        Write-AuditLog "GameRules watcher installed (interval=$IntervalMin)"
    }
    function Uninstall-Watcher {
        if (Test-WatcherInstalled) { Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false; Write-Ok "Watcher removed." ; Write-AuditLog "GameRules watcher removed" }
        else { Write-Warn2 "Watcher was not installed." }
        Remove-Item $DaemonVbs -Force -ErrorAction SilentlyContinue
    }

    function Show-Rules {
        Write-Head "GAME RULES (Process-Lasso style)  -  status"
        $cores = [Environment]::ProcessorCount
        Write-Host ("  Logical processors: {0}   Watcher: {1}" -f $cores, $(if(Test-WatcherInstalled){"INSTALLED ($IntervalMin min)"}else{'not installed'})) -ForegroundColor Gray
        $rules = Read-Rules
        if (-not $rules) { Write-Host "  No rules yet. Add one with option 1 or -AddRule." -ForegroundColor DarkGray; Write-Host ""; return }
        foreach ($r in $rules) {
            $aff = if ($r.AffinityMask -and [int64]$r.AffinityMask -gt 0) { "cores=$($r.Cores)" } else { 'cores=all' }
            $running = [bool](Get-Process -Name ($r.Exe -replace '\.exe$','') -ErrorAction SilentlyContinue)
            Write-Host ("    {0,-28} priority={1,-12} {2}   {3}" -f $r.Exe, $r.Priority, $aff, $(if($running){'[running]'}else{''})) -ForegroundColor DarkGray
        }
        Write-Host ""
    }

    function Add-Rule {
        param([string]$Exe,[string]$Prio,[string]$CoreSpec)
        if ($Exe -notmatch '\.exe$') { $Exe = "$Exe.exe" }
        $mask = if ($CoreSpec) { ConvertTo-Mask $CoreSpec } else { [int64]0 }
        $rules = @(Read-Rules | Where-Object { $_.Exe -ne $Exe })
        $rules += [pscustomobject]@{ Exe=$Exe; Priority=$Prio; Cores=$CoreSpec; AffinityMask="$mask" }
        Save-Rules $rules
        Write-Ok ("Rule saved: {0}  priority={1}  cores={2}" -f $Exe, $Prio, $(if($CoreSpec){$CoreSpec}else{'all'}))
        Apply-Once
        Write-AuditLog "GameRules add $Exe (prio=$Prio cores=$CoreSpec)"
        if (-not (Test-WatcherInstalled)) { Write-Warn2 "Rule applies now; install the watcher (option 3) to re-apply on every launch." }
    }

    if ($GameLoopPreset) {
        Write-Head "GAME RULES  -  GameLoop preset (Process-Lasso style)"
        foreach ($e in @('AndroidEmulator.exe','AndroidEmulatorEx.exe','AndroidEmulatorEn.exe','GameLoop.exe','aow_exe.exe')) {
            Add-Rule -Exe $e -Prio 'High' -CoreSpec $Cores
        }
        if (-not (Test-WatcherInstalled)) { Install-Watcher }
        else { Write-Ok "Watcher already installed - rules will be re-asserted every $IntervalMin min." }
        Write-Host ""
        return
    }
    if ($AddRule)    { Add-Rule -Exe $AddRule -Prio $Priority -CoreSpec $Cores; return }
    if ($RemoveRule) { $e=$RemoveRule; if ($e -notmatch '\.exe$'){$e="$e.exe"}; Save-Rules (@(Read-Rules | Where-Object { $_.Exe -ne $e })); Write-Ok "Removed rule: $e"; return }
    if ($Install)    { Install-Watcher; return }
    if ($Uninstall)  { Uninstall-Watcher; return }
    if ($ApplyNow)   { Apply-Once; Write-Ok "Applied rules to running games."; return }
    if ($Revert)     { Uninstall-Watcher; Remove-Item $RulesPath -ErrorAction SilentlyContinue; Write-Ok "Watcher removed and rules cleared (runtime affinity resets on next game launch)."; return }
    if ($Status)     { Show-Rules; return }

    # interactive
    do {
        Show-Rules
        Write-Host "   1.  Add/update a rule (priority + affinity for a game .exe)"
        Write-Host "   2.  Remove a rule"
        Write-Host "   3.  Install background watcher  (apply rules automatically)"
        Write-Host "   4.  Uninstall watcher"
        Write-Host "   5.  Apply rules now (to running games)"
        Write-Host "   6.  Revert (remove watcher + clear rules)"
        Write-Host "   Q.  Back"
        $c = Read-Host "  Select"
        switch ($c.ToUpper()) {
            '1' {
                $e = Read-Host "  Game .exe (e.g. AndroidEmulatorEn.exe)"
                if ($e) {
                    Write-Host "  Priority: 1=High 2=AboveNormal 3=Normal 4=BelowNormal" -ForegroundColor DarkGray
                    $pp = Read-Host "  Priority [1]"
                    $prio = switch ($pp) { '2'{'AboveNormal'} '3'{'Normal'} '4'{'BelowNormal'} default {'High'} }
                    $cc = Read-Host "  Cores (e.g. 0-5 or 2,3,4,5; blank = all)"
                    Add-Rule -Exe $e -Prio $prio -CoreSpec $cc
                }
                Pause-Any
            }
            '2' { $e = Read-Host "  Exe to remove"; if ($e) { if ($e -notmatch '\.exe$'){$e="$e.exe"}; Save-Rules (@(Read-Rules | Where-Object { $_.Exe -ne $e })); Write-Ok "Removed $e" }; Pause-Any }
            '3' { Install-Watcher; Pause-Any }
            '4' { Uninstall-Watcher; Pause-Any }
            '5' { Apply-Once; Write-Ok "Applied."; Pause-Any }
            '6' { Uninstall-Watcher; Remove-Item $RulesPath -ErrorAction SilentlyContinue; Write-Ok "Reverted."; Pause-Any }
            'Q' { return }
            default { Write-Warn2 "Invalid." }
        }
    } while ($true)
}

# ===========================================================================
#  TOOL 23 - NIC Tuning  (admin)
#  Per-adapter advanced properties for latency/stutter: disable Energy-Efficient
#  Ethernet, Green Ethernet, Flow Control and NIC power-saving (safe defaults);
#  optional -NoModeration also disables Interrupt Moderation + LSO (lower latency,
#  more CPU). Reversible (original registry values captured).
# ===========================================================================
function Invoke-NicTune {
    [CmdletBinding()]
    param(
        [switch]$Status,
        [switch]$Revert,
        [switch]$NoModeration,   # also disable Interrupt Moderation + LSO (aggressive)
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'NicTune.backup.json')
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Status)       { $extra.Status = $true }
        if ($Revert)       { $extra.Revert = $true }
        if ($NoModeration) { $extra.NoModeration = $true }
        Restart-Elevated -ToolName 'NicTune' -Extra $extra
        return
    }

    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    # NDIS registry keywords (stripped of leading *) to set to 0 = disabled
    $SafeTargets = @('EEE','AdvancedEEE','EnableGreenEthernet','GigaLite','FlowControl','EnablePME','PowerSavingMode','ULPMode','AutoPowerSaveModeEnabled','EnableDynamicPowerGating','EnableSavePowerNow','EnableConnectedPowerGating')
    $AggrTargets = @('InterruptModeration','LsoV2IPv4','LsoV2IPv6')

    function Get-ActiveNics { try { Get-NetAdapter -Physical -ErrorAction Stop | Where-Object { $_.Status -eq 'Up' } } catch { @() } }

    function Get-TargetProps {
        param($NicName)
        $sel = @()
        try { $props = Get-NetAdapterAdvancedProperty -Name $NicName -AllProperties -ErrorAction Stop } catch { return @() }
        foreach ($p in $props) {
            if (-not $p.RegistryKeyword) { continue }
            $kw = $p.RegistryKeyword.TrimStart('*')
            $isSafe = $SafeTargets -contains $kw
            $isAggr = $AggrTargets -contains $kw
            if ($isSafe -or ($NoModeration -and $isAggr)) {
                $sel += [pscustomobject]@{ Keyword=$p.RegistryKeyword; Display=$p.DisplayName; Current="$($p.RegistryValue)" }
            }
        }
        return $sel
    }

    function Invoke-NicStatus {
        Write-Head "NIC TUNING  -  status"
        $nics = Get-ActiveNics
        if (-not $nics) { Write-Warn2 "No active physical adapters."; Write-Host ""; return }
        foreach ($n in $nics) {
            Write-Host ("  {0}" -f $n.Name) -ForegroundColor Gray
            $props = Get-TargetProps $n.Name
            if (-not $props) { Write-Host "    (no matching power/offload properties exposed)" -ForegroundColor DarkGray; continue }
            foreach ($p in $props) {
                $off = ($p.Current -eq '0')
                if ($off) { Write-Ok ("  {0,-28} disabled" -f $p.Display) } else { Write-Warn2 ("  {0,-28} {1}" -f $p.Display, $p.Current) }
            }
        }
        Write-Host ""
    }

    function Invoke-NicApply {
        Write-Head "NIC TUNING  -  applying"
        $nics = Get-ActiveNics
        if (-not $nics) { Write-Bad "No active physical adapters."; Write-Host ""; return }

        if (-not (Test-Path $BackupPath)) {
            $snap = @()
            foreach ($n in $nics) {
                foreach ($p in (Get-TargetProps $n.Name)) {
                    $snap += @{ Nic=$n.Name; Keyword=$p.Keyword; Value=$p.Current }
                }
            }
            ([pscustomobject]@{ Props=@($snap) }) | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8
            Write-Ok "Backup saved -> $BackupPath"
        } else { Write-Warn2 "Existing backup kept as restore point: $BackupPath" }

        Write-Warn2 "Setting NIC properties may briefly drop the network link."
        foreach ($n in $nics) {
            Write-Step ("Tuning {0}..." -f $n.Name)
            foreach ($p in (Get-TargetProps $n.Name)) {
                try { Set-NetAdapterAdvancedProperty -Name $n.Name -RegistryKeyword $p.Keyword -RegistryValue 0 -NoRestart -ErrorAction Stop; Write-Ok ("  {0} = disabled" -f $p.Display) }
                catch { Write-Warn2 ("  {0}: {1}" -f $p.Display, $_.Exception.Message) }
            }
            try { Restart-NetAdapter -Name $n.Name -ErrorAction SilentlyContinue } catch {}
        }
        Write-AuditLog "NicTune applied (NoModeration=$NoModeration)"
        Write-Host ""
        Write-Host "  Done. EEE/power-saving off reduces micro-stutters." -ForegroundColor Green
        if ($NoModeration) { Write-Warn2 "Interrupt Moderation off = lower latency but higher CPU during heavy traffic." }
        Write-Host ""
    }

    function Invoke-NicRevert {
        Write-Head "NIC TUNING  -  reverting"
        if (-not (Test-Path $BackupPath)) { Write-Bad "No backup at $BackupPath - nothing to restore."; Write-Host ""; return }
        $b = Get-Content $BackupPath -Raw | ConvertFrom-Json
        $touched = @{}
        foreach ($p in $b.Props) {
            try { Set-NetAdapterAdvancedProperty -Name $p.Nic -RegistryKeyword $p.Keyword -RegistryValue $p.Value -NoRestart -ErrorAction Stop; Write-Ok ("Restored {0} on {1} -> {2}" -f $p.Keyword, $p.Nic, $p.Value); $touched[$p.Nic]=$true }
            catch { Write-Warn2 ("{0}/{1}: {2}" -f $p.Nic, $p.Keyword, $_.Exception.Message) }
        }
        foreach ($nic in $touched.Keys) { try { Restart-NetAdapter -Name $nic -ErrorAction SilentlyContinue } catch {} }
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-AuditLog "NicTune reverted"
        Write-Head "REVERT COMPLETE"
        Write-Host ""
    }

    if     ($Status) { Invoke-NicStatus }
    elseif ($Revert) { Invoke-NicRevert }
    else             { Invoke-NicApply }
}

# ===========================================================================
#  TOOL 24 - Windows Update & Delivery  (admin)
#  Stop WU from replacing your curated GPU driver, stop auto-restart while you're
#  logged in, and turn off Delivery Optimization P2P sharing. Reversible.
# ===========================================================================
function Invoke-Updates {
    [CmdletBinding()]
    param(
        [switch]$Status,
        [switch]$Revert,
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'Updates.backup.json')
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Status) { $extra.Status = $true }
        if ($Revert) { $extra.Revert = $true }
        Restart-Elevated -ToolName 'Updates' -Extra $extra
        return
    }

    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    $WU = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
    $AU = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
    $DS = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching'
    $DO = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization'

    $Desired = @(
        @{ Path=$WU; Name='ExcludeWUDriversInQualityUpdate'; Value=1; Label='Block driver updates via WU' }
        @{ Path=$DS; Name='SearchOrderConfig';               Value=0; Label='Do not auto-search WU for drivers' }
        @{ Path=$AU; Name='NoAutoRebootWithLoggedOnUsers';   Value=1; Label='No auto-restart while logged on' }
        @{ Path=$DO; Name='DODownloadMode';                  Value=0; Label='Delivery Optimization P2P off' }
    )

    function Get-RegSnap { param($Path,$Name) $o=@{ Path=$Path; Name=$Name; Existed=$false; Value=$null }
        try { $o.Value=[int64]((Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name); $o.Existed=$true } catch {}; return $o }
    function Set-RegVal { param($Path,$Name,$Value) if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value ([int64]$Value) -Force | Out-Null }

    function Invoke-UpdStatus {
        Write-Head "WINDOWS UPDATE & DELIVERY  -  status"
        foreach ($d in $Desired) {
            $s = Get-RegSnap $d.Path $d.Name
            if ($s.Existed -and $s.Value -eq $d.Value) { Write-Ok ("{0,-34} set" -f $d.Label) } else { Write-Warn2 ("{0,-34} {1}" -f $d.Label, $(if($s.Existed){$s.Value}else{'<default>'})) }
        }
        Write-Host ""
    }
    function Invoke-UpdApply {
        Write-Head "WINDOWS UPDATE & DELIVERY  -  applying"
        if (-not (Test-Path $BackupPath)) {
            $snap = @(foreach ($d in $Desired) { Get-RegSnap $d.Path $d.Name })
            ([pscustomobject]@{ Reg=$snap }) | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8
            Write-Ok "Backup saved -> $BackupPath"
        } else { Write-Warn2 "Existing backup kept as restore point: $BackupPath" }
        foreach ($d in $Desired) {
            try { Set-RegVal $d.Path $d.Name $d.Value; Write-Ok ("{0}" -f $d.Label) } catch { Write-Bad ("{0}: {1}" -f $d.Label, $_.Exception.Message) }
        }
        Write-AuditLog "Windows Update controls applied"
        Write-Host ""
        Write-Warn2 "Security updates still install - only driver delivery + P2P + auto-restart change."
        Write-Host ""
    }
    function Invoke-UpdRevert {
        Write-Head "WINDOWS UPDATE & DELIVERY  -  reverting"
        if (-not (Test-Path $BackupPath)) { Write-Bad "No backup at $BackupPath - nothing to restore."; Write-Host ""; return }
        $b = Get-Content $BackupPath -Raw | ConvertFrom-Json
        foreach ($s in $b.Reg) {
            try {
                if ($s.Existed) { Set-RegVal $s.Path $s.Name $s.Value; Write-Ok "Restored $($s.Name)" }
                else { if (Test-Path $s.Path) { Remove-ItemProperty -Path $s.Path -Name $s.Name -ErrorAction SilentlyContinue }; Write-Ok "Removed $($s.Name) (was default)" }
            } catch { Write-Bad "$($s.Name): $($_.Exception.Message)" }
        }
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-AuditLog "Windows Update controls reverted"
        Write-Head "REVERT COMPLETE"
        Write-Host ""
    }

    if     ($Status) { Invoke-UpdStatus }
    elseif ($Revert) { Invoke-UpdRevert }
    else             { Invoke-UpdApply }
}

# ===========================================================================
#  TOOL 25 - Privacy & Background  (admin)
#  Standard privacy toggles: advertising ID, activity history, tailored
#  experiences, telemetry level, Cortana/web search, location. Mostly privacy
#  with a small reduction in background telemetry/network. Reversible.
# ===========================================================================
function Invoke-Privacy {
    [CmdletBinding()]
    param(
        [switch]$Status,
        [switch]$Revert,
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'Privacy.backup.json')
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Status) { $extra.Status = $true }
        if ($Revert) { $extra.Revert = $true }
        Restart-Elevated -ToolName 'Privacy' -Extra $extra
        return
    }

    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    $Sys = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
    $WS  = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
    $Desired = @(
        @{ Path='HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'; Name='Enabled'; Value=0; Label='Advertising ID' }
        @{ Path=$Sys; Name='EnableActivityFeed';      Value=0; Label='Activity feed' }
        @{ Path=$Sys; Name='PublishUserActivities';   Value=0; Label='Publish activities' }
        @{ Path=$Sys; Name='UploadUserActivities';    Value=0; Label='Upload activities' }
        @{ Path='HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy'; Name='TailoredExperiencesWithDiagnosticDataEnabled'; Value=0; Label='Tailored experiences' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='AllowTelemetry'; Value=1; Label='Telemetry level (Basic)' }
        @{ Path=$WS; Name='AllowCortana';            Value=0; Label='Cortana' }
        @{ Path=$WS; Name='DisableWebSearch';        Value=1; Label='Web search in Start off' }
        @{ Path=$WS; Name='ConnectedSearchUseWeb';   Value=0; Label='Connected web search off' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors'; Name='DisableLocation'; Value=1; Label='Location services off' }
    )

    function Get-RegSnap { param($Path,$Name) $o=@{ Path=$Path; Name=$Name; Existed=$false; Value=$null }
        try { $o.Value=[int64]((Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name); $o.Existed=$true } catch {}; return $o }
    function Set-RegVal { param($Path,$Name,$Value) if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value ([int64]$Value) -Force | Out-Null }

    function Invoke-PrivStatus {
        Write-Head "PRIVACY & BACKGROUND  -  status"
        foreach ($d in $Desired) {
            $s = Get-RegSnap $d.Path $d.Name
            if ($s.Existed -and $s.Value -eq $d.Value) { Write-Ok ("{0,-28} set" -f $d.Label) } else { Write-Warn2 ("{0,-28} {1}" -f $d.Label, $(if($s.Existed){$s.Value}else{'<default>'})) }
        }
        Write-Host ""
    }
    function Invoke-PrivApply {
        Write-Head "PRIVACY & BACKGROUND  -  applying"
        if (-not (Test-Path $BackupPath)) {
            $snap = @(foreach ($d in $Desired) { Get-RegSnap $d.Path $d.Name })
            ([pscustomobject]@{ Reg=$snap }) | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8
            Write-Ok "Backup saved -> $BackupPath"
        } else { Write-Warn2 "Existing backup kept as restore point: $BackupPath" }
        foreach ($d in $Desired) {
            try { Set-RegVal $d.Path $d.Name $d.Value; Write-Ok ("{0}" -f $d.Label) } catch { Write-Bad ("{0}: {1}" -f $d.Label, $_.Exception.Message) }
        }
        Write-AuditLog "Privacy tweaks applied"
        Write-Host ""
        Write-Warn2 "Mostly privacy; small background-telemetry reduction. Sign out/in to settle."
        Write-Host ""
    }
    function Invoke-PrivRevert {
        Write-Head "PRIVACY & BACKGROUND  -  reverting"
        if (-not (Test-Path $BackupPath)) { Write-Bad "No backup at $BackupPath - nothing to restore."; Write-Host ""; return }
        $b = Get-Content $BackupPath -Raw | ConvertFrom-Json
        foreach ($s in $b.Reg) {
            try {
                if ($s.Existed) { Set-RegVal $s.Path $s.Name $s.Value; Write-Ok "Restored $($s.Name)" }
                else { if (Test-Path $s.Path) { Remove-ItemProperty -Path $s.Path -Name $s.Name -ErrorAction SilentlyContinue }; Write-Ok "Removed $($s.Name) (was default)" }
            } catch { Write-Bad "$($s.Name): $($_.Exception.Message)" }
        }
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-AuditLog "Privacy tweaks reverted"
        Write-Head "REVERT COMPLETE"
        Write-Host ""
    }

    if     ($Status) { Invoke-PrivStatus }
    elseif ($Revert) { Invoke-PrivRevert }
    else             { Invoke-PrivApply }
}

# ===========================================================================
#  TOOL 26 - Apps & components remover  (admin)
#  Removes OneDrive, Internet Explorer, classic Paint, the Store (warned), and a
#  curated set of consumer bloat apps. Each removal is recorded so -Revert can
#  put it back where Windows allows (Store apps may need a Store reinstall).
# ===========================================================================
function Invoke-Apps {
    [CmdletBinding()]
    param(
        [switch]$Status,
        [switch]$Revert,
        [switch]$RemoveBloat,
        [switch]$RemoveOneDrive,
        [switch]$RemoveIE,
        [switch]$RemovePaint,
        [switch]$RemoveStore,
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'Apps-Removed.backup.json')
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Status)         { $extra.Status = $true }
        if ($Revert)         { $extra.Revert = $true }
        if ($RemoveBloat)    { $extra.RemoveBloat = $true }
        if ($RemoveOneDrive) { $extra.RemoveOneDrive = $true }
        if ($RemoveIE)       { $extra.RemoveIE = $true }
        if ($RemovePaint)    { $extra.RemovePaint = $true }
        if ($RemoveStore)    { $extra.RemoveStore = $true }
        Restart-Elevated -ToolName 'Apps' -Extra $extra
        return
    }

    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    # Curated consumer bloat - conservative (no Xbox identity / Game Pass / Teams).
    $Bloat = @(
        'Microsoft.BingNews','Microsoft.BingWeather','Microsoft.BingSearch',
        'Microsoft.MicrosoftSolitaireCollection','Microsoft.SkypeApp','Microsoft.YourPhone',
        'Microsoft.MicrosoftOfficeHub','Microsoft.GetHelp','Microsoft.Getstarted',
        'Microsoft.WindowsFeedbackHub','Microsoft.People','Microsoft.Microsoft3DViewer',
        'Microsoft.MixedReality.Portal','Microsoft.MSPaint','Microsoft.WindowsMaps',
        'Microsoft.PowerAutomateDesktop','Microsoft.Todos','Clipchamp.Clipchamp',
        'MicrosoftCorporationII.QuickAssist','Microsoft.549981C3F5F10'
    )

    function Load-Records { if (Test-Path $BackupPath) { try { @((Get-Content $BackupPath -Raw | ConvertFrom-Json).Items) } catch { @() } } else { @() } }
    function Save-Records { param($R) ([pscustomobject]@{ Items=@($R) }) | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8 }
    function Add-Record   { param($Kind,$Name) $script:rec += [pscustomobject]@{ Kind=$Kind; Name=$Name }; }

    function Get-OneDriveSetup { foreach ($p in @("$env:SystemRoot\System32\OneDriveSetup.exe","$env:SystemRoot\SysWOW64\OneDriveSetup.exe")) { if (Test-Path $p) { return $p } }; return $null }

    function Do-RemoveBloat {
        Write-Step "Removing curated consumer apps..."
        foreach ($n in $Bloat) {
            $hit = $false
            Get-AppxPackage -AllUsers -Name $n -ErrorAction SilentlyContinue | ForEach-Object {
                try { Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction Stop; $hit = $true } catch {}
            }
            Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -eq $n } | ForEach-Object {
                try { Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction Stop | Out-Null; $hit = $true } catch {}
            }
            if ($hit) { Add-Record 'Appx' $n; Write-Ok "removed: $n" }
        }
    }
    function Do-RemoveOneDrive {
        Write-Step "Uninstalling OneDrive..."
        $setup = Get-OneDriveSetup
        if (-not $setup) { Write-Warn2 "OneDriveSetup.exe not found - may already be gone."; return }
        Get-Process OneDrive -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        try { Start-Process $setup '/uninstall' -Wait -ErrorAction Stop; Add-Record 'OneDrive' $setup; Write-Ok "OneDrive uninstalled" }
        catch { Write-Bad "OneDrive uninstall failed: $($_.Exception.Message)" }
    }
    function Do-RemoveIE {
        Write-Step "Removing Internet Explorer..."
        $did = $false
        $f = Get-WindowsOptionalFeature -Online -FeatureName 'Internet-Explorer-Optional-amd64' -ErrorAction SilentlyContinue
        if ($f -and $f.State -eq 'Enabled') { try { Disable-WindowsOptionalFeature -Online -FeatureName 'Internet-Explorer-Optional-amd64' -NoRestart -ErrorAction Stop | Out-Null; Add-Record 'OptionalFeature' 'Internet-Explorer-Optional-amd64'; $did=$true } catch { Write-Warn2 $_.Exception.Message } }
        Get-WindowsCapability -Online -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'Browser.InternetExplorer*' -and $_.State -eq 'Installed' } | ForEach-Object {
            try { Remove-WindowsCapability -Online -Name $_.Name -ErrorAction Stop | Out-Null; Add-Record 'Capability' $_.Name; $did=$true } catch { Write-Warn2 $_.Exception.Message }
        }
        if ($did) { Write-Ok "Internet Explorer removed (reboot to finish)" } else { Write-Warn2 "IE not present / already removed." }
    }
    function Do-RemovePaint {
        Write-Step "Removing classic Paint..."
        $did = $false
        Get-WindowsCapability -Online -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'Microsoft.Windows.MSPaint*' -and $_.State -eq 'Installed' } | ForEach-Object {
            try { Remove-WindowsCapability -Online -Name $_.Name -ErrorAction Stop | Out-Null; Add-Record 'Capability' $_.Name; $did=$true } catch { Write-Warn2 $_.Exception.Message }
        }
        Get-AppxPackage -AllUsers -Name 'Microsoft.Paint' -ErrorAction SilentlyContinue | ForEach-Object {
            try { Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction Stop; Add-Record 'Appx' 'Microsoft.Paint'; $did=$true } catch { Write-Warn2 $_.Exception.Message }
        }
        if ($did) { Write-Ok "Paint removed" } else { Write-Warn2 "Paint not present / already removed." }
    }
    function Do-RemoveStore {
        Write-Warn2 "Removing the Store breaks app install/updates and is hard to undo cleanly."
        $c = Read-Host "  Type STORE to confirm"
        if ($c -ne 'STORE') { Write-Host "  Skipped." -ForegroundColor DarkGray; return }
        Get-AppxPackage -AllUsers -Name 'Microsoft.WindowsStore' -ErrorAction SilentlyContinue | ForEach-Object {
            try { Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction Stop } catch { Write-Warn2 $_.Exception.Message }
        }
        Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -eq 'Microsoft.WindowsStore' } | ForEach-Object {
            try { Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction Stop | Out-Null } catch {}
        }
        Add-Record 'Store' 'Microsoft.WindowsStore'
        Write-Ok "Store removed. Reinstall later with: wsreset -i (or via Settings)."
    }

    function Invoke-AppsStatus {
        Write-Head "APPS & COMPONENTS  -  status"
        $present = @(); foreach ($n in $Bloat) { if (Get-AppxPackage -Name $n -ErrorAction SilentlyContinue) { $present += $n } }
        Write-Host ("  Curated bloat still installed : {0} of {1}" -f $present.Count, $Bloat.Count) -ForegroundColor DarkGray
        if ($present) { Write-Host ("    " + ($present -join ', ')) -ForegroundColor DarkGray }
        $od = [bool](Get-OneDriveSetup) -and (Test-Path "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe")
        Write-Host ("  OneDrive installed            : {0}" -f $(if($od){'yes'}else{'no'})) -ForegroundColor DarkGray
        $ie = Get-WindowsOptionalFeature -Online -FeatureName 'Internet-Explorer-Optional-amd64' -ErrorAction SilentlyContinue
        $iecap = Get-WindowsCapability -Online -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'Browser.InternetExplorer*' -and $_.State -eq 'Installed' }
        Write-Host ("  Internet Explorer present     : {0}" -f $(if(($ie -and $ie.State -eq 'Enabled') -or $iecap){'yes'}else{'no'})) -ForegroundColor DarkGray
        $paint = (Get-AppxPackage -Name 'Microsoft.Paint' -ErrorAction SilentlyContinue) -or (Get-WindowsCapability -Online -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'Microsoft.Windows.MSPaint*' -and $_.State -eq 'Installed' })
        Write-Host ("  Classic Paint present         : {0}" -f $(if($paint){'yes'}else{'no'})) -ForegroundColor DarkGray
        $store = Get-AppxPackage -Name 'Microsoft.WindowsStore' -ErrorAction SilentlyContinue
        Write-Host ("  Microsoft Store present       : {0}" -f $(if($store){'yes'}else{'no'})) -ForegroundColor DarkGray
        Write-Host ""
    }

    function Invoke-AppsRevert {
        Write-Head "APPS & COMPONENTS  -  reverting (restoring where possible)"
        $records = Load-Records
        if (-not $records) { Write-Bad "No removal history at $BackupPath - nothing to restore."; Write-Host ""; return }
        $storeApps = @()
        foreach ($r in $records) {
            switch ($r.Kind) {
                'OptionalFeature' { try { Enable-WindowsOptionalFeature -Online -FeatureName $r.Name -All -NoRestart -ErrorAction Stop | Out-Null; Write-Ok "re-enabled feature: $($r.Name)" } catch { Write-Warn2 "$($r.Name): $($_.Exception.Message)" } }
                'Capability'      { try { Add-WindowsCapability -Online -Name $r.Name -ErrorAction Stop | Out-Null; Write-Ok "restored: $($r.Name)" } catch { Write-Warn2 "$($r.Name): $($_.Exception.Message)" } }
                'OneDrive'        { try { Start-Process $r.Name -ErrorAction Stop; Write-Ok "OneDrive reinstaller launched" } catch { Write-Warn2 "OneDrive: run OneDriveSetup.exe manually" } }
                'Store'           { Write-Warn2 "Store: reinstall with 'wsreset -i' or from Settings (cannot auto-restore)." }
                'Appx'            { $storeApps += $r.Name }
                default {}
            }
        }
        if ($storeApps) {
            Write-Warn2 ("These apps were removed - reinstall from the Store if wanted:")
            Write-Host ("    " + ($storeApps -join ', ')) -ForegroundColor DarkGray
            $o = Read-Host "  Open Microsoft Store now? (y/N)"
            if ($o -match '^[Yy]') { Start-Process 'ms-windows-store://home' -ErrorAction SilentlyContinue }
        }
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-AuditLog "Apps remover reverted"
        Write-Head "REVERT DONE"
        Write-Host ""
    }

    if ($Status) { Invoke-AppsStatus; return }
    if ($Revert) { Invoke-AppsRevert; return }

    $script:rec = @(Load-Records)
    $any = $false
    if ($RemoveBloat)    { Do-RemoveBloat;    $any=$true }
    if ($RemoveOneDrive) { Do-RemoveOneDrive; $any=$true }
    if ($RemoveIE)       { Do-RemoveIE;       $any=$true }
    if ($RemovePaint)    { Do-RemovePaint;    $any=$true }
    if ($RemoveStore)    { Do-RemoveStore;    $any=$true }

    if (-not $any) {
        # interactive
        do {
            Write-Head "APPS & COMPONENTS REMOVER"
            Write-Host "   1.  Remove curated bloat apps (News/Weather/Solitaire/Skype/...)"
            Write-Host "   2.  Remove OneDrive"
            Write-Host "   3.  Remove Internet Explorer"
            Write-Host "   4.  Remove classic Paint"
            Write-Host "   5.  Remove Microsoft Store   (WARNING - breaks app install)"
            Write-Host "   6.  Status"
            Write-Host "   7.  Revert (restore removed items)"
            Write-Host "   Q.  Back"
            $c = Read-Host "  Select"
            switch ($c.ToUpper()) {
                '1' { $script:rec=@(Load-Records); Do-RemoveBloat;    Save-Records $script:rec; Pause-Any }
                '2' { $script:rec=@(Load-Records); Do-RemoveOneDrive; Save-Records $script:rec; Pause-Any }
                '3' { $script:rec=@(Load-Records); Do-RemoveIE;       Save-Records $script:rec; Pause-Any }
                '4' { $script:rec=@(Load-Records); Do-RemovePaint;    Save-Records $script:rec; Pause-Any }
                '5' { $script:rec=@(Load-Records); Do-RemoveStore;    Save-Records $script:rec; Pause-Any }
                '6' { Invoke-AppsStatus; Pause-Any }
                '7' { Invoke-AppsRevert; Pause-Any }
                'Q' { return }
                default { Write-Warn2 "Invalid." }
            }
        } while ($true)
    } else {
        Save-Records $script:rec
        Write-AuditLog "Apps remover ran (bloat=$RemoveBloat od=$RemoveOneDrive ie=$RemoveIE paint=$RemovePaint store=$RemoveStore)"
        Write-Warn2 "Reboot recommended so component removals finish."
        Write-Host ""
    }
}

# ===========================================================================
#  TOOL 27 - Windows features & services  (admin)
#  Turns OFF unwanted components (not uninstall): Print Spooler, Remote Desktop
#  (incoming) + Remote Assistance, Fax, and unticks curated Windows optional
#  features (XPS, Work Folders, SMB1, PowerShell 2.0). All reversible.
# ===========================================================================
function Invoke-Features {
    [CmdletBinding()]
    param(
        [switch]$Status,
        [switch]$Revert,
        [switch]$HardenServices,   # Spooler/RDP/RemoteAssist/Fax off
        [switch]$DisableFeatures,  # untick curated optional features
        [string]$DisableFeature,   # disable one named optional feature
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'Features.backup.json')
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Status)          { $extra.Status = $true }
        if ($Revert)          { $extra.Revert = $true }
        if ($HardenServices)  { $extra.HardenServices = $true }
        if ($DisableFeatures) { $extra.DisableFeatures = $true }
        if ($DisableFeature)  { $extra.DisableFeature = $DisableFeature }
        Restart-Elevated -ToolName 'Features' -Extra $extra
        return
    }

    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    $TS = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
    $RA = 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance'
    $Services = @('Spooler','Fax')
    $CuratedFeatures = @('Printing-XPSServices-Features','WorkFolders-Client','SMB1Protocol','MicrosoftWindowsPowerShellV2Root','FaxServicesClientPackage')

    function Load-B { if (Test-Path $BackupPath) { try { Get-Content $BackupPath -Raw | ConvertFrom-Json } catch { $null } } else { $null } }
    function Save-B { param($O) $O | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8 }

    function Do-Harden {
        Write-Step "Disabling component services + remote access..."
        $b = Load-B; if (-not $b) { $b = [pscustomobject]@{ Svc=@(); Rdp=$null; RemoteAssist=$null } }
        $svcRec = @($b.Svc)
        foreach ($s in $Services) {
            $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
            if (-not $svc) { continue }
            if (-not ($svcRec | Where-Object { $_.Name -eq $s })) {
                $st = (Get-CimInstance Win32_Service -Filter "Name='$s'" -ErrorAction SilentlyContinue).StartMode
                $svcRec += [pscustomobject]@{ Name=$s; StartMode=$st }
            }
            try { Stop-Service -Name $s -Force -ErrorAction SilentlyContinue; Set-Service -Name $s -StartupType Disabled -ErrorAction Stop; Write-Ok "service off: $s" }
            catch { Write-Warn2 "${s}: $($_.Exception.Message)" }
        }
        if ($null -eq $b.Rdp) { $cur = (Get-ItemProperty -Path $TS -Name fDenyTSConnections -ErrorAction SilentlyContinue).fDenyTSConnections; $b.Rdp = $(if($null -eq $cur){-1}else{[int]$cur}) }
        try { New-ItemProperty -Path $TS -Name fDenyTSConnections -PropertyType DWord -Value 1 -Force | Out-Null; Write-Ok "Remote Desktop (incoming) denied" } catch { Write-Warn2 $_.Exception.Message }
        try { Disable-NetFirewallRule -DisplayGroup 'Remote Desktop' -ErrorAction SilentlyContinue } catch {}
        if ($null -eq $b.RemoteAssist) { $cur = (Get-ItemProperty -Path $RA -Name fAllowToGetHelp -ErrorAction SilentlyContinue).fAllowToGetHelp; $b.RemoteAssist = $(if($null -eq $cur){-1}else{[int]$cur}) }
        try { if (-not (Test-Path $RA)) { New-Item -Path $RA -Force | Out-Null }; New-ItemProperty -Path $RA -Name fAllowToGetHelp -PropertyType DWord -Value 0 -Force | Out-Null; Write-Ok "Remote Assistance off" } catch { Write-Warn2 $_.Exception.Message }
        $b.Svc = @($svcRec)
        Save-B $b
        Write-AuditLog "Features: services hardened (spooler/rdp/ra/fax)"
    }

    function Disable-OneFeature {
        param([string]$Name)
        $f = Get-WindowsOptionalFeature -Online -FeatureName $Name -ErrorAction SilentlyContinue
        if (-not $f) { Write-Warn2 "feature not found: $Name"; return }
        if ($f.State -ne 'Enabled') { Write-Warn2 "$Name already disabled."; return }
        $b = Load-B; if (-not $b) { $b = [pscustomobject]@{ Svc=@(); Rdp=$null; RemoteAssist=$null; Feat=@() } }
        $featRec = @(); if ($b.PSObject.Properties.Name -contains 'Feat' -and $b.Feat) { $featRec = @($b.Feat | Where-Object { $_ }) }
        if ($featRec -notcontains $Name) { $featRec += $Name }
        try { Disable-WindowsOptionalFeature -Online -FeatureName $Name -NoRestart -ErrorAction Stop | Out-Null; Write-Ok "feature off: $Name" ; $b | Add-Member -NotePropertyName Feat -NotePropertyValue @($featRec) -Force; Save-B $b }
        catch { Write-Warn2 "${Name}: $($_.Exception.Message)" }
    }
    function Do-DisableFeatures {
        Write-Step "Unticking curated optional features..."
        foreach ($f in $CuratedFeatures) { Disable-OneFeature -Name $f }
        Write-AuditLog "Features: curated optional features disabled"
    }

    function Invoke-FeatStatus {
        Write-Head "WINDOWS FEATURES & SERVICES  -  status"
        foreach ($s in $Services) {
            $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
            if ($svc) { $sm = (Get-CimInstance Win32_Service -Filter "Name='$s'" -ErrorAction SilentlyContinue).StartMode
                if ($svc.StartType -eq 'Disabled' -or $sm -eq 'Disabled') { Write-Ok ("{0,-22} disabled" -f $s) } else { Write-Warn2 ("{0,-22} {1}/{2}" -f $s, $svc.Status, $svc.StartType) } }
        }
        $rdp = (Get-ItemProperty -Path $TS -Name fDenyTSConnections -ErrorAction SilentlyContinue).fDenyTSConnections
        Write-Host ("  Remote Desktop incoming : {0}" -f $(if($rdp -eq 1){'denied'}else{'allowed/default'})) -ForegroundColor DarkGray
        $ra = (Get-ItemProperty -Path $RA -Name fAllowToGetHelp -ErrorAction SilentlyContinue).fAllowToGetHelp
        Write-Host ("  Remote Assistance       : {0}" -f $(if($ra -eq 0){'off'}else{'on/default'})) -ForegroundColor DarkGray
        Write-Host "  Curated optional features:" -ForegroundColor DarkGray
        foreach ($f in $CuratedFeatures) {
            $st = (Get-WindowsOptionalFeature -Online -FeatureName $f -ErrorAction SilentlyContinue).State
            Write-Host ("    {0,-40} {1}" -f $f, $(if($st){$st}else{'n/a'})) -ForegroundColor DarkGray
        }
        Write-Host ""
    }

    function Invoke-FeatRevert {
        Write-Head "WINDOWS FEATURES & SERVICES  -  reverting"
        $b = Load-B
        if (-not $b) { Write-Bad "No backup at $BackupPath - nothing to restore."; Write-Host ""; return }
        foreach ($s in @($b.Svc)) {
            $mode = switch ($s.StartMode) { 'Auto' {'Automatic'} 'Manual' {'Manual'} 'Disabled' {'Disabled'} default {'Manual'} }
            try { Set-Service -Name $s.Name -StartupType $mode -ErrorAction Stop; Write-Ok "restored service $($s.Name) -> $mode" } catch { Write-Warn2 "$($s.Name): $($_.Exception.Message)" }
        }
        if ($null -ne $b.Rdp) {
            if ([int]$b.Rdp -eq -1) { Remove-ItemProperty -Path $TS -Name fDenyTSConnections -ErrorAction SilentlyContinue }
            else { New-ItemProperty -Path $TS -Name fDenyTSConnections -PropertyType DWord -Value ([int]$b.Rdp) -Force | Out-Null }
            try { if ([int]$b.Rdp -eq 0) { Enable-NetFirewallRule -DisplayGroup 'Remote Desktop' -ErrorAction SilentlyContinue } } catch {}
            Write-Ok "Remote Desktop setting restored"
        }
        if ($null -ne $b.RemoteAssist) {
            if ([int]$b.RemoteAssist -eq -1) { Remove-ItemProperty -Path $RA -Name fAllowToGetHelp -ErrorAction SilentlyContinue }
            else { New-ItemProperty -Path $RA -Name fAllowToGetHelp -PropertyType DWord -Value ([int]$b.RemoteAssist) -Force | Out-Null }
            Write-Ok "Remote Assistance setting restored"
        }
        if ($b.PSObject.Properties.Name -contains 'Feat') {
            foreach ($f in @($b.Feat | Where-Object { $_ })) { try { Enable-WindowsOptionalFeature -Online -FeatureName $f -All -NoRestart -ErrorAction Stop | Out-Null; Write-Ok "re-enabled feature: $f" } catch { Write-Warn2 "${f}: $($_.Exception.Message)" } }
        }
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-AuditLog "Features reverted"
        Write-Head "REVERT COMPLETE"
        Write-Warn2 "Reboot to finish feature changes."
        Write-Host ""
    }

    if ($Status)          { Invoke-FeatStatus; return }
    if ($Revert)          { Invoke-FeatRevert; return }
    if ($DisableFeature)  { Disable-OneFeature -Name $DisableFeature; return }
    if ($HardenServices -or $DisableFeatures) {
        if ($HardenServices)  { Do-Harden }
        if ($DisableFeatures) { Do-DisableFeatures }
        Write-Warn2 "Reboot recommended."
        Write-Host ""
        return
    }

    # interactive
    do {
        Write-Head "WINDOWS FEATURES & SERVICES"
        Write-Host "   1.  Turn off services (Print Spooler, Fax) + Remote Desktop/Assistance"
        Write-Host "   2.  Untick curated optional features (XPS, Work Folders, SMB1, PSv2)"
        Write-Host "   3.  Disable one optional feature by name"
        Write-Host "   4.  Status"
        Write-Host "   5.  Revert"
        Write-Host "   Q.  Back"
        $c = Read-Host "  Select"
        switch ($c.ToUpper()) {
            '1' { Do-Harden; Pause-Any }
            '2' { Do-DisableFeatures; Pause-Any }
            '3' { $n = Read-Host "  Feature name (see Status for names)"; if ($n) { Disable-OneFeature -Name $n }; Pause-Any }
            '4' { Invoke-FeatStatus; Pause-Any }
            '5' { Invoke-FeatRevert; Pause-Any }
            'Q' { return }
            default { Write-Warn2 "Invalid." }
        }
    } while ($true)
}

# ===========================================================================
#  TOOL 28 - Taskbar & desktop  (no admin needed - HKCU)
#  Hide the taskbar Search box, Widgets/weather, Task View button, and all
#  desktop icons. Reversible. Restarts Explorer to apply (skip with -NoRestart).
# ===========================================================================
function Invoke-Taskbar {
    [CmdletBinding()]
    param(
        [switch]$Status,
        [switch]$Revert,
        [switch]$HideSearch,
        [switch]$HideWidgets,
        [switch]$HideTaskView,
        [switch]$HideDesktopIcons,
        [switch]$NoRestart,
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'Taskbar.backup.json')
    )

    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    $Adv    = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    $Search = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'
    $Feeds  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds'

    $Items = @(
        [pscustomobject]@{ Key='Search';       Path=$Search; Name='SearchboxTaskbarMode';      Off=0; Label='Taskbar search' }
        [pscustomobject]@{ Key='Widgets';      Path=$Adv;    Name='TaskbarDa';                 Off=0; Label='Widgets / weather (Win11)' }
        [pscustomobject]@{ Key='Feeds';        Path=$Feeds;  Name='ShellFeedsTaskbarViewMode'; Off=2; Label='News & interests (Win10)' }
        [pscustomobject]@{ Key='TaskView';     Path=$Adv;    Name='ShowTaskViewButton';        Off=0; Label='Task View button' }
        [pscustomobject]@{ Key='DesktopIcons'; Path=$Adv;    Name='HideIcons';                 Off=1; Label='All desktop icons' }
    )

    function Get-Selected {
        if (-not ($HideSearch -or $HideWidgets -or $HideTaskView -or $HideDesktopIcons)) { return $Items }
        $sel = @()
        if ($HideSearch)       { $sel += $Items | Where-Object { $_.Key -eq 'Search' } }
        if ($HideWidgets)      { $sel += $Items | Where-Object { $_.Key -eq 'Widgets' -or $_.Key -eq 'Feeds' } }
        if ($HideTaskView)     { $sel += $Items | Where-Object { $_.Key -eq 'TaskView' } }
        if ($HideDesktopIcons) { $sel += $Items | Where-Object { $_.Key -eq 'DesktopIcons' } }
        return $sel
    }
    function Get-Snap { param($Path,$Name) $o=@{ Path=$Path; Name=$Name; Existed=$false; Value=$null }
        try { $o.Value=[int64]((Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name); $o.Existed=$true } catch {}; return $o }
    function Set-Val  { param($Path,$Name,$Value) if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value ([int64]$Value) -Force | Out-Null }

    function Restart-Shell {
        if ($NoRestart) { Write-Warn2 "Sign out/in (or restart Explorer) to see the changes."; return }
        Write-Step "Restarting Explorer to apply (taskbar will blink)..."
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) { Start-Process explorer.exe }
        Write-Ok "Explorer restarted."
    }

    function Invoke-TbStatus {
        Write-Head "TASKBAR & DESKTOP  -  status"
        foreach ($i in $Items) {
            $s = Get-Snap $i.Path $i.Name
            $hidden = $s.Existed -and ([int64]$s.Value -eq [int64]$i.Off)
            if ($hidden) { Write-Ok ("{0,-28} hidden" -f $i.Label) } else { Write-Warn2 ("{0,-28} {1}" -f $i.Label, $(if($s.Existed){"shown ($($s.Value))"}else{'shown (default)'})) }
        }
        Write-Host ""
    }

    function Invoke-TbApply {
        $sel = Get-Selected
        Write-Head "TASKBAR & DESKTOP  -  hiding"
        if (-not (Test-Path $BackupPath)) {
            $snap = @(foreach ($i in $Items) { Get-Snap $i.Path $i.Name })
            ([pscustomobject]@{ Reg=$snap }) | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8
            Write-Ok "Backup saved -> $BackupPath"
        } else { Write-Warn2 "Existing backup kept as restore point: $BackupPath" }
        foreach ($i in $sel) {
            try { Set-Val $i.Path $i.Name $i.Off; Write-Ok ("{0} hidden" -f $i.Label) } catch { Write-Bad ("{0}: {1}" -f $i.Label, $_.Exception.Message) }
        }
        Write-AuditLog "Taskbar/desktop hide applied"
        Restart-Shell
        Write-Host ""
    }

    function Invoke-TbRevert {
        Write-Head "TASKBAR & DESKTOP  -  reverting"
        if (-not (Test-Path $BackupPath)) { Write-Bad "No backup at $BackupPath - nothing to restore."; Write-Host ""; return }
        $b = Get-Content $BackupPath -Raw | ConvertFrom-Json
        foreach ($s in $b.Reg) {
            try {
                if ($s.Existed) { Set-Val $s.Path $s.Name $s.Value; Write-Ok "Restored $($s.Name)" }
                else { if (Test-Path $s.Path) { Remove-ItemProperty -Path $s.Path -Name $s.Name -ErrorAction SilentlyContinue }; Write-Ok "Removed $($s.Name) (was default)" }
            } catch { Write-Bad "$($s.Name): $($_.Exception.Message)" }
        }
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-AuditLog "Taskbar/desktop hide reverted"
        Restart-Shell
        Write-Head "REVERT COMPLETE"
        Write-Host ""
    }

    if     ($Status) { Invoke-TbStatus }
    elseif ($Revert) { Invoke-TbRevert }
    else             { Invoke-TbApply }
}

# ===========================================================================
#  TOOL 29 - Win10/11 UI tweaks  (per-user; version-aware; reversible)
#  Windows 11: classic right-click context menu, taskbar align left, hide the
#  Chat/Teams button. Windows 10: hide Meet Now + the Cortana button.
#  Both: disable Copilot (policy + taskbar button), transparency off (small
#  perf win), show file extensions. Items that don't apply to the detected
#  OS are skipped with a note. JSON backup + -Revert, like the other tools.
# ===========================================================================
function Invoke-WinUI {
    [CmdletBinding()]
    param(
        [switch]$Status,
        [switch]$Revert,
        [switch]$ClassicMenu,
        [switch]$TaskbarLeft,
        [switch]$HideChat,
        [switch]$DisableCopilot,
        [switch]$HideMeetNow,
        [switch]$HideCortanaButton,
        [switch]$NoTransparency,
        [switch]$ShowFileExt,
        [switch]$NoRestart,
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'WinUI.backup.json')
    )

    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    $os   = Get-WtxOS
    $Adv  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    $Pers = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    $PolE = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    $Cop  = 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot'
    $Cls  = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}'

    # Win = '11' / '10' / '' (both). Kind 'key' = the classic-menu CLSID key.
    $Items = @(
        [pscustomobject]@{ Key='ClassicMenu';       Kind='key';   Win='11'; Path=$Cls;  Name='';                        Off=$null; Label='Classic right-click menu (Win11)' }
        [pscustomobject]@{ Key='TaskbarLeft';       Kind='dword'; Win='11'; Path=$Adv;  Name='TaskbarAl';               Off=0;     Label='Taskbar aligned left (Win11)' }
        [pscustomobject]@{ Key='HideChat';          Kind='dword'; Win='11'; Path=$Adv;  Name='TaskbarMn';               Off=0;     Label='Chat / Teams button hidden (Win11)' }
        [pscustomobject]@{ Key='DisableCopilot';    Kind='dword'; Win='';   Path=$Cop;  Name='TurnOffWindowsCopilot';   Off=1;     Label='Copilot disabled (policy)' }
        [pscustomobject]@{ Key='DisableCopilot';    Kind='dword'; Win='';   Path=$Adv;  Name='ShowCopilotButton';       Off=0;     Label='Copilot taskbar button hidden' }
        [pscustomobject]@{ Key='HideMeetNow';       Kind='dword'; Win='10'; Path=$PolE; Name='HideSCAMeetNow';          Off=1;     Label='Meet Now icon hidden (Win10)' }
        [pscustomobject]@{ Key='HideCortanaButton'; Kind='dword'; Win='10'; Path=$Adv;  Name='ShowCortanaButton';       Off=0;     Label='Cortana button hidden (Win10)' }
        [pscustomobject]@{ Key='NoTransparency';    Kind='dword'; Win='';   Path=$Pers; Name='EnableTransparency';      Off=0;     Label='Transparency effects off (perf)' }
        [pscustomobject]@{ Key='ShowFileExt';       Kind='dword'; Win='';   Path=$Adv;  Name='HideFileExt';             Off=0;     Label='File extensions shown' }
    )

    function Test-OsFit { param($i)
        if ($i.Win -eq '')   { return $true }
        if ($i.Win -eq '11') { return $os.IsWin11 }
        return (-not $os.IsWin11)
    }

    function Get-Selected {
        $any = ($ClassicMenu -or $TaskbarLeft -or $HideChat -or $DisableCopilot -or `
                $HideMeetNow -or $HideCortanaButton -or $NoTransparency -or $ShowFileExt)
        if (-not $any) {
            # Curated OS-appropriate default set (transparency + taskbar-left stay opt-in)
            $def = @('DisableCopilot','ShowFileExt')
            if ($os.IsWin11) { $def += @('ClassicMenu','HideChat') } else { $def += @('HideMeetNow','HideCortanaButton') }
            return @($Items | Where-Object { $def -contains $_.Key })
        }
        $sel = @()
        foreach ($i in $Items) {
            $on = switch ($i.Key) {
                'ClassicMenu'       { $ClassicMenu }
                'TaskbarLeft'       { $TaskbarLeft }
                'HideChat'          { $HideChat }
                'DisableCopilot'    { $DisableCopilot }
                'HideMeetNow'       { $HideMeetNow }
                'HideCortanaButton' { $HideCortanaButton }
                'NoTransparency'    { $NoTransparency }
                'ShowFileExt'       { $ShowFileExt }
                default             { $false }
            }
            if ($on) { $sel += $i }
        }
        return $sel
    }

    function Get-Snap { param($Path,$Name) $o=@{ Path=$Path; Name=$Name; Existed=$false; Value=$null }
        try { $o.Value=[int64]((Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name); $o.Existed=$true } catch {}; return $o }
    function Set-Val  { param($Path,$Name,$Value) if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value ([int64]$Value) -Force | Out-Null }

    function Restart-Shell {
        if ($NoRestart) { Write-Warn2 "Restart Explorer (or sign out/in) to see the changes."; return }
        Write-Step "Restarting Explorer to apply (taskbar will blink)..."
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) { Start-Process explorer.exe }
        Write-Ok "Explorer restarted."
    }

    function Invoke-WuStatus {
        Write-Head ("WIN10/11 UI  -  status   [{0} {1} build {2}]" -f $os.Name, $os.Version, $os.Build)
        foreach ($i in $Items) {
            if (-not (Test-OsFit $i)) { Write-Host ("  [-] {0,-38} n/a on this OS" -f $i.Label) -ForegroundColor DarkGray; continue }
            if ($i.Kind -eq 'key') {
                $set = Test-Path (Join-Path $i.Path 'InprocServer32')
                if ($set) { Write-Ok ("{0,-38} set" -f $i.Label) } else { Write-Warn2 ("{0,-38} default" -f $i.Label) }
            } else {
                $s = Get-Snap $i.Path $i.Name
                $set = $s.Existed -and ([int64]$s.Value -eq [int64]$i.Off)
                if ($set) { Write-Ok ("{0,-38} set" -f $i.Label) }
                else { Write-Warn2 ("{0,-38} {1}" -f $i.Label, $(if($s.Existed){"($($s.Value))"}else{'default'})) }
            }
        }
        Write-Host ""
    }

    function Invoke-WuApply {
        $sel = @(Get-Selected)
        Write-Head ("WIN10/11 UI  -  applying   [{0} build {1}]" -f $os.Name, $os.Build)
        if (-not (Test-Path $BackupPath)) {
            $snap = @(foreach ($i in $Items) {
                if ($i.Kind -eq 'key') { @{ Kind='key'; Path=$i.Path; Existed=[bool](Test-Path $i.Path) } }
                else { $r = Get-Snap $i.Path $i.Name; $r.Kind='dword'; $r }
            })
            ([pscustomobject]@{ Reg=$snap }) | ConvertTo-Json -Depth 6 | Set-Content $BackupPath -Encoding UTF8
            Write-Ok "Backup saved -> $BackupPath"
        } else { Write-Warn2 "Existing backup kept as restore point: $BackupPath" }

        $needShell = $false
        foreach ($i in $sel) {
            if (-not (Test-OsFit $i)) { Write-Warn2 ("{0}: skipped (not applicable on {1})" -f $i.Label, $os.Name); continue }
            try {
                if ($i.Kind -eq 'key') {
                    $ip = Join-Path $i.Path 'InprocServer32'
                    if (-not (Test-Path $ip)) { New-Item -Path $ip -Force | Out-Null }
                    Set-ItemProperty -Path $ip -Name '(default)' -Value ''
                } else {
                    Set-Val $i.Path $i.Name $i.Off
                }
                $needShell = $true
                Write-Ok $i.Label
            } catch { Write-Bad ("{0}: {1}" -f $i.Label, $_.Exception.Message) }
        }
        Write-AuditLog "WinUI tweaks applied"
        if ($needShell) { Restart-Shell }
        Write-Host ""
    }

    function Invoke-WuRevert {
        Write-Head "WIN10/11 UI  -  reverting"
        if (-not (Test-Path $BackupPath)) { Write-Bad "No backup at $BackupPath - nothing to restore."; Write-Host ""; return }
        $b = Get-Content $BackupPath -Raw | ConvertFrom-Json
        foreach ($s in $b.Reg) {
            try {
                if ($s.Kind -eq 'key') {
                    if (-not $s.Existed -and (Test-Path $s.Path)) { Remove-Item -Path $s.Path -Recurse -Force -ErrorAction SilentlyContinue; Write-Ok "Removed classic-menu key (was default)" }
                    elseif ($s.Existed) { Write-Ok "Classic-menu key kept (existed before)" }
                }
                elseif ($s.Existed) { Set-Val $s.Path $s.Name $s.Value; Write-Ok "Restored $($s.Name)" }
                else { if (Test-Path $s.Path) { Remove-ItemProperty -Path $s.Path -Name $s.Name -ErrorAction SilentlyContinue }; Write-Ok "Removed $($s.Name) (was default)" }
            } catch { Write-Bad "$($s.Name): $($_.Exception.Message)" }
        }
        Remove-Item $BackupPath -ErrorAction SilentlyContinue
        Write-AuditLog "WinUI tweaks reverted"
        Restart-Shell
        Write-Head "REVERT COMPLETE"
        Write-Host ""
    }

    if     ($Status) { Invoke-WuStatus }
    elseif ($Revert) { Invoke-WuRevert }
    else             { Invoke-WuApply }
}

# ===========================================================================
#  TOOL 30 - Graphics performance preference  (per-app GPU + HAGS)  (admin)
#  Forces game executables onto the HIGH-PERFORMANCE GPU (the "Graphics
#  performance preference" list in Settings > System > Display > Graphics) and
#  turns on Hardware-accelerated GPU scheduling. Auto-detects the GameLoop
#  emulator exes (AndroidEmulatorEn/Ex/AndroidEmulator, GameLoop, aow_exe) and
#  accepts -AddApp for any other game. Reversible via JSON backup.
# ===========================================================================
function Invoke-GpuPref {
    [CmdletBinding()]
    param(
        [switch]$Status,
        [switch]$Revert,
        [switch]$NoHags,          # skip enabling Hardware-accelerated GPU scheduling
        [string]$AddApp,          # full path to an extra .exe to force high-performance
        [string]$BackupPath = (Join-Path $env:USERPROFILE 'GpuPref.backup.json')
    )

    if (-not (Test-Admin)) {
        $extra = @{}
        if ($Status) { $extra.Status = $true }
        if ($Revert) { $extra.Revert = $true }
        if ($NoHags) { $extra.NoHags = $true }
        if ($AddApp) { $extra.AddApp = $AddApp }
        Restart-Elevated -ToolName 'GpuPref' -Extra $extra
        return
    }

    function Write-Ok   ($m){ Write-Host "  [+] $m" -ForegroundColor Green }
    function Write-Warn2($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
    function Write-Bad  ($m){ Write-Host "  [x] $m" -ForegroundColor Red }
    function Write-Step ($m){ Write-Host "  [>] $m" -ForegroundColor Cyan }
    function Write-Head ($m){
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
        Write-Host "   $m" -ForegroundColor White
        Write-Host "  ============================================================" -ForegroundColor DarkCyan
    }

    $PrefKey  = 'HKCU:\SOFTWARE\Microsoft\DirectX\UserGpuPreferences'
    $GfxKey   = 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers'
    $HighPerf = 'GpuPreference=2;'   # 2 = High performance | 1 = Power saving | 0 = Windows decides
    # The three names the user asked for, plus the GameLoop shells, are all covered.
    $EmuNames = @('AndroidEmulatorEn.exe','AndroidEmulator.exe','AndroidEmulatorEx.exe','GameLoop.exe','aow_exe.exe')

    function Get-Hags {
        try { return [int](Get-ItemPropertyValue -Path $GfxKey -Name 'HwSchMode' -ErrorAction Stop) } catch { return $null }
    }

    function Find-EmuExes {
        $roots = @()
        foreach ($drv in (Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue)) {
            if (-not $drv.Root) { continue }
            foreach ($pf in @('Program Files','Program Files (x86)')) {
                $roots += (Join-Path $drv.Root (Join-Path $pf 'TxGameAssistant'))
            }
        }
        $roots = $roots | Where-Object { Test-Path $_ } | Select-Object -Unique
        $found = @()
        foreach ($r in $roots) {
            try {
                Get-ChildItem -Path $r -Recurse -File -Include $EmuNames -ErrorAction SilentlyContinue |
                    ForEach-Object { $found += $_.FullName }
            } catch {}
        }
        return @($found | Select-Object -Unique)
    }

    function Load-Backup {
        if (Test-Path $BackupPath) { try { return (Get-Content $BackupPath -Raw | ConvertFrom-Json) } catch {} }
        return $null
    }

    # ------------------------------ STATUS ------------------------------
    if ($Status) {
        Write-Head "GRAPHICS PREFERENCE  -  status"
        $h = Get-Hags
        $hs = switch ($h) { 2 { 'ON (2)' } 1 { 'off (1)' } default { 'not set (driver default)' } }
        Write-Host ("  Hardware-accelerated GPU scheduling: {0}" -f $hs) -ForegroundColor Gray
        if (Test-Path $PrefKey) {
            $props = @((Get-ItemProperty -Path $PrefKey -ErrorAction SilentlyContinue).PSObject.Properties |
                       Where-Object { $_.Name -notmatch '^PS(Path|ParentPath|ChildName|Provider|Drive)$' })
            if ($props.Count) {
                Write-Host "  Per-app GPU preferences:" -ForegroundColor Gray
                foreach ($p in $props) {
                    $tag = if ("$($p.Value)" -match 'GpuPreference=2') { 'HIGH PERF' } elseif ("$($p.Value)" -match 'GpuPreference=1') { 'power save' } else { 'auto' }
                    Write-Host ("    [{0,-9}] {1}" -f $tag, $p.Name) -ForegroundColor DarkGray
                }
            } else { Write-Host "  No per-app GPU preferences set yet." -ForegroundColor DarkGray }
        } else { Write-Host "  No per-app GPU preferences set yet." -ForegroundColor DarkGray }
        Write-Host ""
        return
    }

    # ------------------------------ REVERT ------------------------------
    if ($Revert) {
        Write-Head "GRAPHICS PREFERENCE  -  reverting"
        $b = Load-Backup
        if (-not $b) { Write-Warn2 "No backup at $BackupPath - nothing to revert."; Write-Host ""; return }
        if ($b.Added -and (Test-Path $PrefKey)) {
            foreach ($name in @($b.Added)) {
                if (-not $name) { continue }
                try { Remove-ItemProperty -Path $PrefKey -Name $name -ErrorAction SilentlyContinue; Write-Ok ("removed pref: {0}" -f (Split-Path $name -Leaf)) } catch {}
            }
        }
        if ($null -ne $b.HwSchModeExisted) {
            if (-not (Test-Path $GfxKey)) { New-Item -Path $GfxKey -Force | Out-Null }
            if ($b.HwSchModeExisted) {
                Set-ItemProperty -Path $GfxKey -Name 'HwSchMode' -Value ([int]$b.HwSchMode) -Type DWord -Force
                Write-Ok ("HwSchMode restored to {0}" -f $b.HwSchMode)
            } else {
                Remove-ItemProperty -Path $GfxKey -Name 'HwSchMode' -ErrorAction SilentlyContinue
                Write-Ok "HwSchMode removed (was not set before)"
            }
        }
        Remove-Item $BackupPath -Force -ErrorAction SilentlyContinue
        Write-Warn2 "Reboot for the GPU scheduling change to take effect."
        Write-Host ""
        return
    }

    # ------------------------------- APPLY ------------------------------
    Write-Head "GRAPHICS PREFERENCE  -  MAX (high-performance GPU for games)"
    if (-not (Test-Path $PrefKey)) { New-Item -Path $PrefKey -Force | Out-Null }
    if (-not (Test-Path $GfxKey))  { New-Item -Path $GfxKey  -Force | Out-Null }

    # Carry forward any previous backup so revert always removes exactly our set.
    $added   = New-Object System.Collections.Generic.List[string]
    $curHags = Get-Hags
    $prev    = Load-Backup
    if ($prev) {
        $hwExisted = [bool]$prev.HwSchModeExisted
        $hwVal     = [int]$prev.HwSchMode
        foreach ($x in @($prev.Added)) { if ($x) { [void]$added.Add([string]$x) } }
    } else {
        $hwExisted = ($null -ne $curHags)
        $hwVal     = $(if ($null -ne $curHags) { [int]$curHags } else { 0 })
    }
    ([pscustomobject]@{ HwSchModeExisted = $hwExisted; HwSchMode = $hwVal; Added = @($added.ToArray()) }) |
        ConvertTo-Json | Set-Content $BackupPath -Encoding UTF8
    if (-not $prev) { Write-Ok "Backup saved -> $BackupPath" }

    # Build the target list: discovered GameLoop exes (+ standard-path seeds) + -AddApp
    $targets = New-Object System.Collections.Generic.List[string]
    foreach ($p in (Find-EmuExes)) { [void]$targets.Add($p) }
    if ($targets.Count -eq 0) {
        Write-Warn2 "GameLoop not found under Program Files\TxGameAssistant - seeding standard paths."
        $seed = Join-Path $env:ProgramFiles 'TxGameAssistant\ui'
        foreach ($n in @('AndroidEmulatorEn.exe','AndroidEmulator.exe','AndroidEmulatorEx.exe','GameLoop.exe')) {
            [void]$targets.Add((Join-Path $seed $n))
        }
    }
    if ($AddApp) { $ap = $AddApp.Trim('"'); if ($ap) { [void]$targets.Add($ap) } }

    $set = 0
    foreach ($exe in ($targets | Select-Object -Unique)) {
        try {
            New-ItemProperty -Path $PrefKey -Name $exe -Value $HighPerf -PropertyType String -Force | Out-Null
            if (-not $added.Contains($exe)) { [void]$added.Add($exe) }
            $mark = if (Test-Path $exe) { '' } else { '  (seeded; applies when the exe exists)' }
            Write-Ok ("high-performance GPU -> {0}{1}" -f (Split-Path $exe -Leaf), $mark)
            $set++
        } catch { Write-Bad ("{0}: {1}" -f (Split-Path $exe -Leaf), $_.Exception.Message) }
    }
    Write-Ok "$set app(s) set to High performance."

    # Persist the updated added-list so -Revert removes exactly what we wrote.
    ([pscustomobject]@{ HwSchModeExisted = $hwExisted; HwSchMode = $hwVal; Added = @($added.ToArray()) }) |
        ConvertTo-Json | Set-Content $BackupPath -Encoding UTF8

    if (-not $NoHags) {
        try {
            Set-ItemProperty -Path $GfxKey -Name 'HwSchMode' -Value 2 -Type DWord -Force
            Write-Ok "Hardware-accelerated GPU scheduling: ON (reboot required)"
        } catch { Write-Bad ("HAGS: {0}" -f $_.Exception.Message) }
    } else {
        Write-Warn2 "HAGS left unchanged (-NoHags)."
    }

    Write-AuditLog "GpuPref applied ($set apps, HAGS=$(if($NoHags){'skip'}else{'on'}))"
    Write-Host ""
    Write-Host "  Done. Reboot for GPU scheduling to take effect." -ForegroundColor Green
    Write-Host "  Reversible:  -Tool GpuPref -Revert" -ForegroundColor DarkGray
    Write-Host ""
}

# ===========================================================================
#  Toolbox orchestrators
# ===========================================================================
function Invoke-Checkpoint {
    if (-not (Test-Admin)) { Restart-Elevated -ToolName 'Checkpoint'; return }
    New-RestoreCheckpoint -Description 'WinToolbox manual checkpoint'
}

function Invoke-StatusAll {
    if (-not (Test-Admin)) { Restart-Elevated -ToolName 'StatusAll'; return }
    Write-Host ""
    Write-Host "================ FULL STATUS SWEEP ================" -ForegroundColor Green
    Invoke-Input   -Status -NoPause
    Invoke-Debloat -Status
    Invoke-GameLoop -Status
    Invoke-GameDVR -Status
    Invoke-Network -Status
    Invoke-CPU     -Status
    Invoke-GPU     -Status
    Invoke-GpuPref -Status
    Invoke-Storage -Status
    Invoke-Startup -Status
    Invoke-GameProfile -Status
    Invoke-Latency -Status
    Invoke-GameFocus -Status
    Invoke-Audio   -Status
    Invoke-Display -Status
    Invoke-GameRules -Status
    Invoke-NicTune -Status
    Invoke-Updates -Status
    Invoke-Privacy -Status
    Write-Host "================ END OF SWEEP =====================" -ForegroundColor Green
}

function Invoke-RevertAll {
    if (-not (Test-Admin)) { Restart-Elevated -ToolName 'RevertAll'; return }
    Write-Host ""
    Write-Host "================ REVERT ALL (perf/gaming tweaks) ================" -ForegroundColor Yellow
    Write-Host "  (DriveLock and PageFile are NOT touched - revert those manually)" -ForegroundColor DarkGray
    Invoke-VisualFX  -Revert -NoPause
    Invoke-Input     -Revert -NoPause
    Invoke-PowerPlan -RevertNow
    Invoke-CPU       -Revert
    Invoke-GPU       -Revert
    Invoke-GpuPref   -Revert
    Invoke-Network   -Revert
    Invoke-Debloat   -Revert
    Invoke-GameDVR   -Revert
    Invoke-GameLoop  -Revert
    Invoke-Storage   -Revert
    Invoke-GameProfile -Revert
    Invoke-Startup   -Revert
    Invoke-Audio     -Revert
    Invoke-GameFocus -Revert
    Invoke-Latency   -Revert
    Invoke-Display   -Revert
    Invoke-GameRules -Revert
    Invoke-NicTune   -Revert
    Invoke-Updates   -Revert
    Invoke-Privacy   -Revert
    Write-Host ""
    Write-Host "================ REVERT ALL COMPLETE ================" -ForegroundColor Green
    Write-Host "  Reboot recommended to fully restore everything." -ForegroundColor DarkGray
}

function Invoke-Profile {
    if (-not (Test-Admin)) { Restart-Elevated -ToolName 'Profile'; return }
    Write-Host ""
    Write-Host "##############################################################" -ForegroundColor Green
    Write-Host "#          APPLYING RECOMMENDED GAMING PROFILE               #" -ForegroundColor Green
    Write-Host "#   Safe subset across tools. Restore point created first.   #" -ForegroundColor Green
    Write-Host "##############################################################" -ForegroundColor Green

    New-RestoreCheckpoint -Description 'WinToolbox gaming profile'

    Invoke-VisualFX  -NoPause
    Invoke-Input     -NoPause
    Invoke-PowerPlan -ApplyNow
    Invoke-CPU
    Invoke-GPU
    Invoke-Network
    Invoke-Debloat
    Invoke-GameDVR
    Invoke-Storage
    Invoke-Audio
    Invoke-Display
    Invoke-NicTune
    Invoke-GameProfile -GameLoopPreset
    Invoke-GpuPref

    Write-Host ""
    $g = Read-Host "  Also disable VBS/Hyper-V for GameLoop? (security tradeoff, reboot) (y/N)"
    if ($g -match '^(y|yes)$') { Invoke-GameLoop }

    Write-Host ""
    Write-Host "##############################################################" -ForegroundColor Green
    Write-Host "#                 GAMING PROFILE APPLIED                     #" -ForegroundColor Green
    Write-Host "##############################################################" -ForegroundColor Green
    Write-Host "  REBOOT to apply everything. Use 'Revert All' (R) to undo." -ForegroundColor DarkGray
    Write-Host "  Not included: PageFile, DriveLock, TempCleaner, Startup (run separately)." -ForegroundColor DarkGray
    Write-Host ""
}

function Invoke-ApplyAll {
    if (-not (Test-Admin)) { Restart-Elevated -ToolName 'ApplyAll'; return }
    Write-Host ""
    Write-Host "##############################################################" -ForegroundColor Red
    Write-Host "#            APPLY ALL  -  MAX PERFORMANCE                   #" -ForegroundColor Red
    Write-Host "##############################################################" -ForegroundColor Red
    Write-Host ""
    Write-Host "  This applies the FULL aggressive set across tools:" -ForegroundColor White
    Write-Host "    - Visual effects (perf), Input 1:1, Power plan GOD MODE" -ForegroundColor Gray
    Write-Host "    - CPU scheduler + mitigations OFF (security tradeoff)" -ForegroundColor Gray
    Write-Host "    - NVIDIA max performance, Network low-latency tune" -ForegroundColor Gray
    Write-Host "    - Storage/SSD + RAM tweaks, Audio enhancements off, Debloat" -ForegroundColor Gray
    Write-Host "    - Game DVR off + background apps off, Fullscreen-opt off" -ForegroundColor Gray
    Write-Host "    - GameLoop: VBS / Hyper-V OFF (security tradeoff)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  NOT included (run manually if you want them):" -ForegroundColor DarkYellow
    Write-Host "    - CPU boot-timer tweaks (can RAISE latency = worse)" -ForegroundColor DarkGray
    Write-Host "    - Fast DNS change, Xbox-service disable" -ForegroundColor DarkGray
    Write-Host "    - PageFile, DriveLock, Temp Cleaner, Power-plan lockdown" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Reduces security (mitigations + VBS off). Single-user gaming box only." -ForegroundColor Yellow
    Write-Host "  A restore point + backup snapshot are made first. Everything is reversible (R)." -ForegroundColor DarkGray
    Write-Host ""
    $c = Read-Host "  Type APPLY to proceed (anything else cancels)"
    if ($c -ne 'APPLY') { Write-Host "  Cancelled." -ForegroundColor DarkGray; Write-Host ""; return }

    Write-AuditLog "APPLY ALL (max) started"
    New-RestoreCheckpoint -Description 'WinToolbox APPLY ALL (max)'
    Invoke-Snapshot -Action Save | Out-Null

    Invoke-VisualFX    -NoPause
    Invoke-Input       -NoPause
    Invoke-PowerPlan   -ApplyNow
    Invoke-CPU         -DisableMitigations
    Invoke-GPU
    Invoke-Network
    Invoke-Storage
    Invoke-Audio
    Invoke-Display
    Invoke-NicTune     -NoModeration
    Invoke-Debloat
    Invoke-GameDVR     -DisableBackgroundApps
    Invoke-GameProfile -GameLoopPreset
    Invoke-GpuPref
    Invoke-GameLoop

    Write-AuditLog "APPLY ALL (max) complete"
    Write-Host ""
    Write-Host "##############################################################" -ForegroundColor Green
    Write-Host "#                 APPLY ALL  -  COMPLETE                     #" -ForegroundColor Green
    Write-Host "##############################################################" -ForegroundColor Green
    Write-Host "  REBOOT to apply everything (mitigations / VBS / scheduler)." -ForegroundColor Yellow
    Write-Host "  Undo it all anytime with 'Revert All' (R)." -ForegroundColor DarkGray
    Write-Host ""
}

# ===========================================================================
#  Master interactive menu
# ===========================================================================
function Show-MainMenu {
    do {
        Clear-Host
        Write-Host "==================================================" -ForegroundColor DarkCyan
        Write-Host "            Windows Toolbox  (Sanjula)            " -ForegroundColor Green
        Write-Host "==================================================" -ForegroundColor DarkCyan
        $adm = if (Test-Admin) { 'Administrator' } else { 'standard user' }
        $os  = Get-WtxOS
        Write-Host "  Running as: $adm   |   $($os.Name) $($os.Version) (build $($os.Build))" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  -- AUTO-APPLICABLE  (these are what M / P run together) ----" -ForegroundColor DarkCyan
        Write-Host "   1.  Visual Effects   (thumbnails + smooth fonts only)"
        Write-Host "   2.  Input God Mode   (mouse/keyboard 1:1 gaming tune)"
        Write-Host "   3.  Power Plan       (max-performance plan manager)        *"
        Write-Host "   4.  Network God Mode (low-latency TCP/Nagle tune)          *"
        Write-Host "   5.  CPU God Mode     (scheduler/throttle tune)             *"
        Write-Host "   6.  NVIDIA GPU       (force max perf / HAGS / nvidia-smi)  *"
        Write-Host "   7.  Debloat          (disable telemetry services + tasks) *"
        Write-Host "   8.  GameLoop / VBS   (disable VBS/Hyper-V for emulators)   *"
        Write-Host "   9.  Game DVR         (Game DVR off, Game Mode on)          *"
        Write-Host "  10.  Storage & Memory (TRIM/last-access/8.3 + RAM tweaks)   *"
        Write-Host "  11.  Per-game priority(High CPU priority for game .exe)     *"
        Write-Host "  12.  Audio            (enhancements off, ducking off)       *"
        Write-Host "  13.  Display/Fullscrn (FSO off, windowed-opt, MPO option)   *"
        Write-Host "  14.  NIC Tuning       (EEE/power-save/interrupt-mod off)    *"
        Write-Host "  30.  Graphics Pref    (game exes -> High-perf GPU + HAGS)   *"
        Write-Host ""
        Write-Host "  -- MANUAL ONLY  (run each yourself; not in M / P) ----------" -ForegroundColor DarkCyan
        Write-Host "  15.  Page File        (fixed virtual memory)               *"
        Write-Host "  16.  Drive Lock       (block writes to D:/E:/...)          *"
        Write-Host "  17.  Download Browsers (Chrome / Brave)"
        Write-Host "  18.  Windows Settings (theme / wallpaper / lock / tz GUI)"
        Write-Host "  19.  Temp Cleaner     (GodMode+ junk cleaner)              *"
        Write-Host "  20.  Startup manager  (enable/disable startup items)       *"
        Write-Host "  21.  Latency/Interrupt(DPC advisor + MSI mode for GPU/NIC)  *"
        Write-Host "  22.  Game Focus       (notifications off + runtime priority)"
        Write-Host "  23.  Game Rules       (Lasso-style affinity+priority watcher)*"
        Write-Host "  24.  Windows Update   (block driver updates, no auto-restart)*"
        Write-Host "  25.  Privacy          (ad ID/activity/telemetry/Cortana off) *"
        Write-Host "  26.  Apps remover     (OneDrive/IE/Paint/Store/bloat removal)*"
        Write-Host "  27.  Features/services(Spooler/RDP off, untick win features) *"
        Write-Host "  28.  Taskbar/desktop  (hide search/widgets/taskview/icons)"
        Write-Host "  29.  Win10/11 UI      (classic menu/Copilot off/taskbar left)"
        Write-Host ""
        Write-Host "   M.  APPLY ALL  (MAX everything - aggressive, security tradeoffs) *" -ForegroundColor Red
        Write-Host "   P.  APPLY GAMING PROFILE  (recommended safe subset)         *" -ForegroundColor Green
        Write-Host "   A.  Status - All         (audit every tool)                 *"
        Write-Host "   R.  Revert - All         (undo perf/gaming tweaks)          *"
        Write-Host "   C.  Create Restore Point                                    *"
        Write-Host "   S.  Snapshot backups     (save/list/restore all backups)"
        Write-Host "   L.  View audit log"
        Write-Host "   Q.  Quit"
        Write-Host ""
        Write-Host "   (* needs admin - will prompt for elevation in a new window)" -ForegroundColor DarkGray
        Write-Host ""
        $c = Read-Host "  Select"
        if ($c) { Write-AuditLog "menu: $c" }

        switch ($c.ToUpper()) {
            '1' {
                $r = Read-Host "  Apply or Revert? (A/R)"
                if ($r -match '^[Rr]') { Invoke-VisualFX -Revert } else { Invoke-VisualFX }
            }
            '2' {
                $r = Read-Host "  Apply / Revert / Status? (A/R/S)"
                if     ($r -match '^[Rr]') { Invoke-Input -Revert }
                elseif ($r -match '^[Ss]') { Invoke-Input -Status }
                else                       { Invoke-Input }
            }
            '3' { Invoke-PowerPlan }
            '15' {
                $r = Read-Host "  Set fixed page file (S) or Revert to Windows-managed (R)? (S/R)"
                if ($r -match '^[Rr]') {
                    Invoke-PageFile -Revert
                } else {
                    $i = Read-Host "  Initial MB [8192]"
                    $m = Read-Host "  Maximum MB [12288]"
                    if (-not $i) { $i = 8192 }
                    if (-not $m) { $m = 12288 }
                    Invoke-PageFile -Initial ([int]$i) -Maximum ([int]$m)
                }
            }
            '16' { Invoke-DriveLock }
            '17' {
                $r = Read-Host "  Both / Chrome only / Brave only? (B/C/V)"
                if     ($r -match '^[Cc]') { Invoke-Browsers -Chrome }
                elseif ($r -match '^[Vv]') { Invoke-Browsers -Brave }
                else                       { Invoke-Browsers }
                Pause-Any
            }
            '18' { Invoke-WinSettings }
            '19' {
                Write-Host ""
                Write-Host "   a.  Preview (scan only, nothing deleted)"
                Write-Host "   b.  GodMode clean"
                Write-Host "   c.  GodMode clean + browser caches"
                $t = Read-Host "  Choose (a/b/c)"
                switch ($t.ToLower()) {
                    'a' { Invoke-TempCleaner -Preview -GodMode -IncludeBrowsers }
                    'b' { Invoke-TempCleaner -GodMode }
                    'c' { Invoke-TempCleaner -GodMode -IncludeBrowsers }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
            }
            '4' {
                Write-Host ""
                Write-Host "   a.  Apply god mode"
                Write-Host "   b.  Apply god mode + fast DNS (Cloudflare)"
                Write-Host "   c.  Status (read-only)"
                Write-Host "   d.  Revert"
                Write-Host "   e.  Reset stack (repair - needs reboot)"
                $t = Read-Host "  Choose (a/b/c/d/e)"
                switch ($t.ToLower()) {
                    'a' { Invoke-Network }
                    'b' { Invoke-Network -SetDNS -DnsProvider Cloudflare }
                    'c' { Invoke-Network -Status }
                    'd' { Invoke-Network -Revert }
                    'e' { Invoke-Network -ResetStack }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
                Pause-Any
            }
            '5' {
                Write-Host ""
                Write-Host "   a.  Apply CPU god mode (scheduler + throttle off)"
                Write-Host "   b.  Apply + disable CPU mitigations (Spectre/Meltdown - LESS SECURE)"
                Write-Host "   c.  Apply + boot timer tweaks (system-dependent)"
                Write-Host "   d.  Status (read-only)"
                Write-Host "   e.  Revert"
                $t = Read-Host "  Choose (a/b/c/d/e)"
                switch ($t.ToLower()) {
                    'a' { Invoke-CPU }
                    'b' { Invoke-CPU -DisableMitigations }
                    'c' { Invoke-CPU -TimerTweaks }
                    'd' { Invoke-CPU -Status }
                    'e' { Invoke-CPU -Revert }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
                Pause-Any
            }
            '6' {
                Write-Host ""
                Write-Host "   a.  Apply GPU god mode (force max performance / PowerMizer)"
                Write-Host "   b.  Apply + enable HAGS"
                Write-Host "   c.  Apply + lock clocks high (needs a supported card)"
                Write-Host "   d.  Status (read-only)"
                Write-Host "   e.  Revert"
                $t = Read-Host "  Choose (a/b/c/d/e)"
                switch ($t.ToLower()) {
                    'a' { Invoke-GPU }
                    'b' { Invoke-GPU -HAGS On }
                    'c' { Invoke-GPU -LockClocks }
                    'd' { Invoke-GPU -Status }
                    'e' { Invoke-GPU -Revert }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
                Pause-Any
            }
            '7' {
                Write-Host ""
                Write-Host "   a.  Apply (safe defaults)"
                Write-Host "   b.  Apply + disable Xbox services (may affect some games)"
                Write-Host "   c.  Status"
                Write-Host "   d.  Revert"
                $t = Read-Host "  Choose (a/b/c/d)"
                switch ($t.ToLower()) {
                    'a' { Invoke-Debloat }
                    'b' { Invoke-Debloat -DisableXbox }
                    'c' { Invoke-Debloat -Status }
                    'd' { Invoke-Debloat -Revert }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
                Pause-Any
            }
            '8' {
                Write-Host ""
                Write-Host "   a.  Apply (disable VBS/Hyper-V - security tradeoff, reboot)"
                Write-Host "   c.  Status"
                Write-Host "   d.  Revert"
                $t = Read-Host "  Choose (a/c/d)"
                switch ($t.ToLower()) {
                    'a' { Invoke-GameLoop }
                    'c' { Invoke-GameLoop -Status }
                    'd' { Invoke-GameLoop -Revert }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
                Pause-Any
            }
            '9' {
                Write-Host ""
                Write-Host "   a.  Apply (Game DVR off, Game Mode on)"
                Write-Host "   b.  Apply + disable background apps"
                Write-Host "   c.  Status"
                Write-Host "   d.  Revert"
                $t = Read-Host "  Choose (a/b/c/d)"
                switch ($t.ToLower()) {
                    'a' { Invoke-GameDVR }
                    'b' { Invoke-GameDVR -DisableBackgroundApps }
                    'c' { Invoke-GameDVR -Status }
                    'd' { Invoke-GameDVR -Revert }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
                Pause-Any
            }
            '20' { Invoke-Startup }
            '10' {
                Write-Host ""
                Write-Host "   a.  Apply (TRIM on, last-access off, 8.3 off, RAM tweaks, ReTrim)"
                Write-Host "   c.  Status"
                Write-Host "   d.  Revert"
                $t = Read-Host "  Choose (a/c/d)"
                switch ($t.ToLower()) {
                    'a' { Invoke-Storage }
                    'c' { Invoke-Storage -Status }
                    'd' { Invoke-Storage -Revert }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
                Pause-Any
            }
            '11' { Invoke-GameProfile }
            '21' {
                Write-Host ""
                Write-Host "   a.  Status / advisor (read-only)"
                Write-Host "   b.  Enable MSI mode for GPU + NIC (reboot)"
                Write-Host "   c.  Energy report (powercfg /energy, ~60s)"
                Write-Host "   d.  Revert MSI changes"
                $t = Read-Host "  Choose (a/b/c/d)"
                switch ($t.ToLower()) {
                    'a' { Invoke-Latency -Status }
                    'b' { Invoke-Latency -EnableMSI }
                    'c' { Invoke-Latency -Trace }
                    'd' { Invoke-Latency -Revert }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
                Pause-Any
            }
            '22' {
                Write-Host ""
                Write-Host "   a.  Apply (notifications/tips off)"
                Write-Host "   b.  Boost a running game to High priority"
                Write-Host "   c.  Status"
                Write-Host "   d.  Revert"
                $t = Read-Host "  Choose (a/b/c/d)"
                switch ($t.ToLower()) {
                    'a' { Invoke-GameFocus }
                    'b' { $exe = Read-Host "  Game .exe name (e.g. AndroidEmulatorEn.exe)"; if ($exe) { Invoke-GameFocus -Boost $exe } }
                    'c' { Invoke-GameFocus -Status }
                    'd' { Invoke-GameFocus -Revert }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
                Pause-Any
            }
            '12' {
                Write-Host ""
                Write-Host "   a.  Apply (enhancements off, ducking off)"
                Write-Host "   c.  Status"
                Write-Host "   d.  Revert"
                $t = Read-Host "  Choose (a/c/d)"
                switch ($t.ToLower()) {
                    'a' { Invoke-Audio }
                    'c' { Invoke-Audio -Status }
                    'd' { Invoke-Audio -Revert }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
                Pause-Any
            }
            '13' {
                Write-Host ""
                Write-Host "   a.  Apply (FSO off + windowed optimization)"
                Write-Host "   b.  Apply + disable MPO (for flicker/stutter)"
                Write-Host "   c.  Status"
                Write-Host "   d.  Revert"
                $t = Read-Host "  Choose (a/b/c/d)"
                switch ($t.ToLower()) {
                    'a' { Invoke-Display }
                    'b' { Invoke-Display -DisableMPO }
                    'c' { Invoke-Display -Status }
                    'd' { Invoke-Display -Revert }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
                Pause-Any
            }
            '23' { Invoke-GameRules }
            '14' {
                Write-Host ""
                Write-Host "   a.  Apply (EEE/Green/Flow-control/power-save off)"
                Write-Host "   b.  Apply + disable Interrupt Moderation & LSO (aggressive)"
                Write-Host "   c.  Status"
                Write-Host "   d.  Revert"
                $t = Read-Host "  Choose (a/b/c/d)"
                switch ($t.ToLower()) {
                    'a' { Invoke-NicTune }
                    'b' { Invoke-NicTune -NoModeration }
                    'c' { Invoke-NicTune -Status }
                    'd' { Invoke-NicTune -Revert }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
                Pause-Any
            }
            '24' {
                Write-Host ""
                Write-Host "   a.  Apply (block WU drivers, P2P off, no auto-restart)"
                Write-Host "   c.  Status"
                Write-Host "   d.  Revert"
                $t = Read-Host "  Choose (a/c/d)"
                switch ($t.ToLower()) {
                    'a' { Invoke-Updates }
                    'c' { Invoke-Updates -Status }
                    'd' { Invoke-Updates -Revert }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
                Pause-Any
            }
            '25' {
                Write-Host ""
                Write-Host "   a.  Apply (privacy/background toggles)"
                Write-Host "   c.  Status"
                Write-Host "   d.  Revert"
                $t = Read-Host "  Choose (a/c/d)"
                switch ($t.ToLower()) {
                    'a' { Invoke-Privacy }
                    'c' { Invoke-Privacy -Status }
                    'd' { Invoke-Privacy -Revert }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
                Pause-Any
            }
            '26' { Invoke-Apps }
            '27' { Invoke-Features }
            '28' {
                Write-Host ""
                Write-Host "   a.  Hide all (search + widgets/weather + task view + desktop icons)"
                Write-Host "   b.  Pick what to hide"
                Write-Host "   c.  Status"
                Write-Host "   d.  Revert (show everything again)"
                $t = Read-Host "  Choose (a/b/c/d)"
                switch ($t.ToLower()) {
                    'a' { Invoke-Taskbar }
                    'b' {
                        $s = (Read-Host "  Hide taskbar search? (y/N)")      -match '^[Yy]'
                        $w = (Read-Host "  Hide widgets / weather? (y/N)")    -match '^[Yy]'
                        $v = (Read-Host "  Hide Task View button? (y/N)")     -match '^[Yy]'
                        $i = (Read-Host "  Hide all desktop icons? (y/N)")    -match '^[Yy]'
                        if ($s -or $w -or $v -or $i) { Invoke-Taskbar -HideSearch:$s -HideWidgets:$w -HideTaskView:$v -HideDesktopIcons:$i }
                        else { Write-Host "  Nothing selected." -ForegroundColor DarkGray }
                    }
                    'c' { Invoke-Taskbar -Status }
                    'd' { Invoke-Taskbar -Revert }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
                Pause-Any
            }
            '29' {
                Write-Host ""
                Write-Host "   a.  Apply recommended set for this OS (Copilot off, file ext on,"
                Write-Host "       + classic menu/Chat-off on Win11, Meet-Now/Cortana-off on Win10)"
                Write-Host "   b.  Pick items"
                Write-Host "   c.  Status"
                Write-Host "   d.  Revert"
                $t = Read-Host "  Choose (a/b/c/d)"
                switch ($t.ToLower()) {
                    'a' { Invoke-WinUI }
                    'b' {
                        $cm = (Read-Host "  Classic right-click menu (Win11)? (y/N)") -match '^[Yy]'
                        $tl = (Read-Host "  Taskbar align left (Win11)? (y/N)")       -match '^[Yy]'
                        $hc = (Read-Host "  Hide Chat/Teams button (Win11)? (y/N)")   -match '^[Yy]'
                        $dc = (Read-Host "  Disable Copilot? (y/N)")                  -match '^[Yy]'
                        $mn = (Read-Host "  Hide Meet Now (Win10)? (y/N)")            -match '^[Yy]'
                        $cb = (Read-Host "  Hide Cortana button (Win10)? (y/N)")      -match '^[Yy]'
                        $tr = (Read-Host "  Transparency effects off? (y/N)")         -match '^[Yy]'
                        $fe = (Read-Host "  Show file extensions? (y/N)")             -match '^[Yy]'
                        if ($cm -or $tl -or $hc -or $dc -or $mn -or $cb -or $tr -or $fe) {
                            Invoke-WinUI -ClassicMenu:$cm -TaskbarLeft:$tl -HideChat:$hc -DisableCopilot:$dc `
                                -HideMeetNow:$mn -HideCortanaButton:$cb -NoTransparency:$tr -ShowFileExt:$fe
                        } else { Write-Host "  Nothing selected." -ForegroundColor DarkGray }
                    }
                    'c' { Invoke-WinUI -Status }
                    'd' { Invoke-WinUI -Revert }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
                Pause-Any
            }
            '30' {
                Write-Host ""
                Write-Host "   a.  Apply (game exes -> High-performance GPU + HAGS on)"
                Write-Host "   b.  Apply GPU pref only (skip HAGS)"
                Write-Host "   c.  Add a custom game .exe to High-performance GPU"
                Write-Host "   d.  Status"
                Write-Host "   e.  Revert"
                $t = Read-Host "  Choose (a/b/c/d/e)"
                switch ($t.ToLower()) {
                    'a' { Invoke-GpuPref }
                    'b' { Invoke-GpuPref -NoHags }
                    'c' {
                        $p = Read-Host "  Full path to the .exe"
                        if ($p) { Invoke-GpuPref -AddApp $p } else { Write-Host "  Nothing entered." -ForegroundColor DarkGray }
                    }
                    'd' { Invoke-GpuPref -Status }
                    'e' { Invoke-GpuPref -Revert }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
                Pause-Any
            }
            'M' { Invoke-ApplyAll;   Pause-Any }
            'P' { Invoke-Profile;    Pause-Any }
            'A' { Invoke-StatusAll;  Pause-Any }
            'R' {
                $c2 = Read-Host "  Revert ALL perf/gaming tweaks? (y/N)"
                if ($c2 -match '^(y|yes)$') { Invoke-RevertAll } else { Write-Host "  Cancelled." -ForegroundColor DarkGray }
                Pause-Any
            }
            'C' { Invoke-Checkpoint; Pause-Any }
            'S' {
                Write-Host ""
                Write-Host "   a.  Save snapshot (bundle all current backups)"
                Write-Host "   b.  List snapshots"
                Write-Host "   c.  Restore a snapshot"
                $t = Read-Host "  Choose (a/b/c)"
                switch ($t.ToLower()) {
                    'a' { Invoke-Snapshot -Action Save }
                    'b' { Invoke-Snapshot -Action List }
                    'c' { Invoke-Snapshot -Action List; $nm = Read-Host "  Snapshot name to restore"; if ($nm) { Invoke-Snapshot -Action Restore -Name $nm } }
                    default { Write-Host "  Skipped." -ForegroundColor DarkGray }
                }
                Pause-Any
            }
            'L' { Show-AuditLog; Pause-Any }
            'Q' { return }
            default { Write-Host "  Invalid choice." -ForegroundColor Red; Start-Sleep 1 }
        }
    } while ($true)
}

# ===========================================================================
#  GUI front-end  (multi-select -> one RUN SELECTED button, runs silently)
#  Launch with:  powershell -ExecutionPolicy Bypass -File .\WinToolbox.ps1 -Gui
#  The whole GUI self-elevates ONCE; every tool then runs elevated with no
#  extra UAC prompts. Each tool runs as a hidden child process; its console
#  output is streamed into the log box. Tools that are inherently interactive
#  (Windows Settings, Startup manager) open their own window on Apply.
#  Each tool with multiple flags has an "Options..." button exposing ALL of
#  its switches in a per-tool dialog, so nothing is hidden.
# ===========================================================================

$script:WtxCat  = $null      # tool catalog (array of pscustomobject)
$script:WtxCtl  = @{}        # references to the controls handlers need
$script:WtxPath = $null      # full path of this script
$script:WtxTip  = $null      # shared tooltip
$script:WtxBusy = $false     # true while a batch is running

function Write-WtxLog {
    param([string]$Text)
    $box = $script:WtxCtl.Log
    if ($null -eq $box) { return }
    $box.AppendText($Text + "`r`n")
    $box.SelectionStart = $box.TextLength
    $box.ScrollToCaret()
}

# Build the full powershell.exe argument string for one tool invocation.
function Get-WtxArgString {
    param([string]$Key, $Extra)
    $a = "-NoProfile -ExecutionPolicy Bypass -File `"$($script:WtxPath)`" -Tool $Key -NoPause"
    if ($Extra) {
        foreach ($t in $Extra) { if ($null -ne $t -and "$t" -ne '') { $a += " $t" } }
    }
    return $a
}

# Run a tool hidden, capture its console output, write it into the log.
# stdin is closed so any stray prompt returns immediately (never hangs).
# stderr is read async while stdout is read sync -> no redirect deadlock.
function Invoke-WtxHidden {
    param([string]$ArgString)
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName               = 'powershell.exe'
    $psi.Arguments              = $ArgString
    $psi.UseShellExecute        = $false
    $psi.CreateNoWindow         = $true
    $psi.WindowStyle            = 'Hidden'
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.RedirectStandardInput  = $true

    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $psi
    try {
        [void]$p.Start()
        try { $p.StandardInput.Close() } catch {}
        $errTask = $p.StandardError.ReadToEndAsync()
        $out = $p.StandardOutput.ReadToEnd()
        $p.WaitForExit()
        $err = ''
        try { $err = $errTask.Result } catch {}
        if ($out) { foreach ($ln in ($out -split "`r?`n")) { if ($ln -ne '') { Write-WtxLog $ln } } }
        if ($err) { foreach ($ln in ($err -split "`r?`n")) { if ($ln.Trim() -ne '') { Write-WtxLog ("  [err] " + $ln) } } }
    } catch {
        Write-WtxLog ("  [err] " + $_.Exception.Message)
    } finally {
        try { $p.Dispose() } catch {}
    }
}

# Run a tool in its own visible window (for interactive tools) and wait.
# UseShellExecute = $true is REQUIRED here: with it off the child shares the
# GUI's console, which is HIDDEN when launched via the .vbs - the interactive
# tool would be invisible. ShellExecute gives it a fresh visible console.
function Invoke-WtxVisible {
    param([string]$ArgString)
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName        = 'powershell.exe'
    $psi.Arguments       = $ArgString
    $psi.UseShellExecute = $true
    $psi.WindowStyle     = 'Normal'
    $p = [System.Diagnostics.Process]::Start($psi)
    while (-not $p.HasExited) { [System.Windows.Forms.Application]::DoEvents(); Start-Sleep -Milliseconds 80 }
    try { $p.Dispose() } catch {}
}

# Turn an item's per-option state into a flat token list.
function Compute-WtxOptTokens {
    param($Item)
    $toks = @()
    foreach ($s in $Item.OptSpec) {
        $v = $Item.OptState[$s.T]
        switch ($s.Kind) {
            'check' { if ($v) { foreach ($t in $s.Flag) { $toks += $t } } }
            'text'  {
                $sv = "$v".Trim()
                if ($sv -ne '') {
                    if ($s.Numeric -and ($sv -notmatch '^\d+$')) { }
                    else { $toks += $s.Flag; $toks += $sv }
                }
            }
            'choice' {
                $ok = $true
                if ($s.GateT) { $ok = [bool]$Item.OptState[$s.GateT] }
                $sv = "$v"
                if ($ok -and $sv -ne '') { $toks += $s.Flag; $toks += $sv }
            }
        }
    }
    return ,$toks
}

# Recursively apply the gaming dark theme to a control tree.
function Set-WtxThemeDeep {
    param($root)
    if (-not $script:WtxTheme) { return }
    foreach ($c in $root.Controls) {
        $t = $c.GetType().Name
        if     ($t -eq 'Label')    { $c.ForeColor = $script:WtxTheme.Dim; $c.BackColor = [System.Drawing.Color]::Transparent }
        elseif ($t -eq 'CheckBox') { $c.ForeColor = $script:WtxTheme.Fg;  $c.BackColor = [System.Drawing.Color]::Transparent }
        elseif ($t -eq 'Button')   { $c.FlatStyle = 'Flat'; $c.BackColor = $script:WtxTheme.Ctl; $c.ForeColor = $script:WtxTheme.Fg; $c.FlatAppearance.BorderColor = $script:WtxTheme.Border }
        elseif ($t -eq 'ComboBox') { $c.BackColor = $script:WtxTheme.Ctl; $c.ForeColor = $script:WtxTheme.Fg; $c.FlatStyle = 'Flat' }
        elseif ($t -eq 'TextBox')  { if (-not $c.ReadOnly) { $c.BackColor = $script:WtxTheme.Ctl; $c.ForeColor = $script:WtxTheme.Fg }; $c.BorderStyle = 'FixedSingle' }
        elseif ($t -eq 'GroupBox') { $c.ForeColor = $script:WtxTheme.Accent }
        elseif ($t -eq 'Panel')    { $c.BackColor = $script:WtxTheme.Panel }
        elseif ($t -eq 'FlowLayoutPanel') { $c.BackColor = [System.Drawing.Color]::Transparent }
        if ($c.Controls.Count -gt 0) { Set-WtxThemeDeep $c }
    }
}

# MAX mode: tick EVERY tool with the FULL option set, except 16 Drive Lock and
# 17 Browsers. GameRules is set to the GameLoop (Process-Lasso) preset. The
# 'Boot timer tweaks' option stays OFF because it can RAISE latency.
function Set-WtxMaxAll {
    foreach ($it in $script:WtxCat) {
        if ($it.Key -eq 'DriveLock' -or $it.Key -eq 'Browsers') { $it.CB.Checked = $false; Update-WtxRow $it; continue }
        $it.CB.Checked = $true
        if ($it.Key -eq 'GameRules' -and $it.Combo.Items.Contains('GameLoop preset')) { $it.Combo.SelectedItem = 'GameLoop preset' }
        elseif ($it.Combo.Items.Contains('Apply')) { $it.Combo.SelectedItem = 'Apply' }
        if ($it.OptSpec.Count -gt 0) {
            foreach ($s in $it.OptSpec) {
                if ($s.Kind -eq 'check') {
                    $on = $true
                    if ($s.T -match 'Boot timer') { $on = $false }
                    if ($s.T -match 'Skip HAGS')  { $on = $false }   # MAX wants HAGS ON
                    if ($s.T -match 'time zone')  { $on = $false }   # not a perf tweak - leave off
                    $it.OptState[$s.T] = $on
                }
            }
            $it.OptTokens = Compute-WtxOptTokens $it
        }
        Update-WtxRow $it
    }
    Write-WtxLog "[MAX] Everything ticked with FULL options - except 16 Drive Lock and 17 Browsers."
    Write-WtxLog "[MAX] GameRules set to 'GameLoop preset' (High priority rules + watcher, Process-Lasso style)."
    Write-WtxLog "[MAX] 'Boot timer tweaks' left OFF (can RAISE latency) - enable via CPU Options... if you want it."
    Write-WtxLog "[MAX] Review the ticks, then press RUN SELECTED."
}

# Per-tool options dialog: renders every switch the tool supports.
function Show-WtxOptions {
    param($Item)
    $specs = $Item.OptSpec
    $rowH = 28
    $f = New-Object System.Windows.Forms.Form
    $f.Text = $Item.Name + '  -  options'
    $f.FormBorderStyle = 'FixedDialog'
    $f.StartPosition = 'CenterScreen'
    $f.MaximizeBox = $false
    $f.MinimizeBox = $false
    $f.Font = New-Object System.Drawing.Font('Segoe UI', 9)
    $f.ClientSize = New-Object System.Drawing.Size(440, (16 + ($rowH * $specs.Count) + 54))

    $y = 12
    $ctrls = @()
    foreach ($s in $specs) {
        if ($s.Kind -eq 'check') {
            $c = New-Object System.Windows.Forms.CheckBox
            $c.Text = $s.T; $c.AutoSize = $true
            $c.Location = New-Object System.Drawing.Point(16, $y)
            $c.Checked = [bool]$Item.OptState[$s.T]
            $f.Controls.Add($c); $ctrls += @{ Spec = $s; Ctrl = $c }
        }
        elseif ($s.Kind -eq 'text') {
            $l = New-Object System.Windows.Forms.Label; $l.Text = $s.T; $l.AutoSize = $true; $l.Location = New-Object System.Drawing.Point(16, ($y + 3)); $f.Controls.Add($l)
            $w = 60; if ($s.Width) { $w = $s.Width }
            $t = New-Object System.Windows.Forms.TextBox; $t.Size = New-Object System.Drawing.Size($w, 22); $t.Location = New-Object System.Drawing.Point((430 - $w - 10), $y); $t.Text = [string]$Item.OptState[$s.T]; $f.Controls.Add($t); $ctrls += @{ Spec = $s; Ctrl = $t }
        }
        elseif ($s.Kind -eq 'choice') {
            $l = New-Object System.Windows.Forms.Label; $l.Text = $s.T; $l.AutoSize = $true; $l.Location = New-Object System.Drawing.Point(16, ($y + 3)); $f.Controls.Add($l)
            $cb = New-Object System.Windows.Forms.ComboBox; $cb.DropDownStyle = 'DropDownList'; $cb.Size = New-Object System.Drawing.Size(130, 22); $cb.Location = New-Object System.Drawing.Point(300, $y)
            foreach ($o in $s.Choices) { [void]$cb.Items.Add($o) }
            $cur = [string]$Item.OptState[$s.T]
            if ($cb.Items.Contains($cur)) { $cb.SelectedItem = $cur } elseif ($cb.Items.Count) { $cb.SelectedIndex = 0 }
            $f.Controls.Add($cb); $ctrls += @{ Spec = $s; Ctrl = $cb }
        }
        $y += $rowH
    }

    $ok = New-Object System.Windows.Forms.Button
    $ok.Text = 'OK'; $ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $ok.Size = New-Object System.Drawing.Size(80, 28); $ok.Location = New-Object System.Drawing.Point(260, ($y + 8))
    $f.Controls.Add($ok); $f.AcceptButton = $ok
    $cn = New-Object System.Windows.Forms.Button
    $cn.Text = 'Cancel'; $cn.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $cn.Size = New-Object System.Drawing.Size(80, 28); $cn.Location = New-Object System.Drawing.Point(346, ($y + 8))
    $f.Controls.Add($cn); $f.CancelButton = $cn

    if ($script:WtxTheme) {
        $f.BackColor = $script:WtxTheme.Bg
        $f.ForeColor = $script:WtxTheme.Fg
        Set-WtxThemeDeep $f
        $ok.BackColor = $script:WtxTheme.Accent
        $ok.ForeColor = [System.Drawing.Color]::White
        $ok.FlatAppearance.BorderColor = $script:WtxTheme.Accent
    }

    $res = $f.ShowDialog()
    if ($res -eq [System.Windows.Forms.DialogResult]::OK) {
        foreach ($e in $ctrls) {
            $s = $e.Spec; $c = $e.Ctrl
            switch ($s.Kind) {
                'check'  { $Item.OptState[$s.T] = [bool]$c.Checked }
                'text'   { $Item.OptState[$s.T] = [string]$c.Text }
                'choice' { $Item.OptState[$s.T] = [string]$c.SelectedItem }
            }
        }
        $Item.OptTokens = Compute-WtxOptTokens $Item
    }
    $f.Dispose()
}

# Decide the arguments for one tool, based on its dropdown + options.
# Returns: $null (nothing) | '__SKIP__:reason' | @{ Tokens = <string[]> }
function Get-WtxToolArgs {
    param($Item)
    $mode = [string]$Item.Combo.SelectedItem
    if ($mode -eq '' -or $mode -eq 'Skip') { return $null }
    if ($mode -eq 'Status') { return @{ Tokens = @('-Status') } }
    if ($mode -eq 'Revert') { return @{ Tokens = $Item.RevertArgs } }

    if ($Item.ExtraMap.Contains($mode)) {
        $toks = @()
        foreach ($t in $Item.ExtraMap[$mode]) {
            if ($t -eq '__EXE__') {
                $exe = ''
                if ($Item.FxExe) { $exe = ([string]$Item.FxExe.Text).Trim() }
                if ($exe -eq '') { return '__SKIP__:' + $Item.Name + ' needs the .exe name' }
                $toks += $exe
            } else { $toks += $t }
        }
        return @{ Tokens = $toks }
    }

    # --- Apply ---
    $extra = @()
    foreach ($b in $Item.ApplyBase) { $extra += $b }
    switch ($Item.Key) {
        'PageFile' {
            $i = ([string]$Item.PfInit.Text).Trim()
            $m = ([string]$Item.PfMax.Text).Trim()
            if ($i -notmatch '^\d+$' -or $m -notmatch '^\d+$') { return '__SKIP__:PageFile needs numeric Init/Max MB' }
            $extra += @('-Initial', $i, '-Maximum', $m)
        }
        'DriveLock' {
            $d = ([string]$Item.DlDrives.Text).Trim()
            if ($d -eq '') { return '__SKIP__:DriveLock needs drive letters (e.g. D,E)' }
            $extra += @('-Lock', '-Drives', $d)
        }
        'GameProfile' { $extra += @('-GameLoopPreset') }
        'GameRules'   { $extra += @('-ApplyNow') }
        'Latency'     { $extra += @('-Status') }
        default { }
    }
    if ($Item.OptSpec.Count -gt 0) { foreach ($t in $Item.OptTokens) { $extra += $t } }
    if ($Item.NeedOpt -and (@($Item.OptTokens).Count -eq 0)) {
        return '__SKIP__:' + $Item.Name + ' - open Options... and tick at least one item'
    }
    return @{ Tokens = $extra }
}

# Enable/disable a row's input boxes + Options button per the chosen mode.
function Update-WtxRow {
    param($Item)
    if ($null -eq $Item) { return }
    $mode = [string]$Item.Combo.SelectedItem
    $isApply = ($mode -eq 'Apply')
    if ($Item.PfInit)   { $Item.PfInit.Enabled  = $isApply; $Item.PfMax.Enabled = $isApply }
    if ($Item.DlDrives) { $Item.DlDrives.Enabled = $isApply }
    if ($Item.OptBtn)   { $Item.OptBtn.Enabled   = $isApply }
    if ($Item.FxExe) {
        $Item.FxExe.Enabled = ($Item.ExtraMap.Contains($mode) -and (@($Item.ExtraMap[$mode]) -contains '__EXE__'))
    }
}

# Bulk-set every CHECKED tool's dropdown to a mode (if that tool supports it).
function Set-WtxAllChecked {
    param([string]$Mode)
    foreach ($it in $script:WtxCat) {
        if (-not $it.CB.Checked) { continue }
        if ($it.Combo.Items.Contains($Mode)) { $it.Combo.SelectedItem = $Mode; Update-WtxRow $it }
    }
}

# The main button: gather checked tools, run each in order, silently.
function Invoke-WtxRun {
    if ($script:WtxBusy) { return }
    $jobs  = New-Object System.Collections.ArrayList
    $skips = New-Object System.Collections.ArrayList
    $anyApply = $false

    foreach ($it in $script:WtxCat) {
        if (-not $it.CB.Checked) { continue }
        $r = Get-WtxToolArgs -Item $it
        if ($null -eq $r) { continue }
        if ($r -is [string]) { [void]$skips.Add($r.Substring(8)); continue }
        $mode = [string]$it.Combo.SelectedItem
        if ($mode -eq 'Apply') { $anyApply = $true }
        $interactive = ($it.Interactive -and $mode -eq 'Apply') -or ($it.VisibleModes -contains $mode)
        [void]$jobs.Add(@{ Key = $it.Key; Name = $it.Name; Mode = $mode; Tokens = $r.Tokens; Interactive = $interactive })
    }

    if ($jobs.Count -eq 0) {
        $msg = "Tick at least one tool first."
        if ($skips.Count) { $msg += "`r`n`r`nSkipped:`r`n - " + ($skips -join "`r`n - ") }
        [System.Windows.Forms.MessageBox]::Show($msg, 'WinToolbox', 'OK', 'Information') | Out-Null
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show("Run $($jobs.Count) selected tool(s) now?", 'WinToolbox', 'YesNo', 'Question')
    if ($confirm -ne 'Yes') { return }

    $script:WtxBusy = $true
    $script:WtxCtl.Run.Enabled = $false
    $script:WtxCtl.Log.Clear()
    if ($script:WtxCtl.Bar) { $script:WtxCtl.Bar.Minimum = 0; $script:WtxCtl.Bar.Maximum = $jobs.Count; $script:WtxCtl.Bar.Value = 0 }
    Write-WtxLog ("===== WinToolbox  -  $($jobs.Count) tool(s)  -  " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + " =====")
    Write-WtxLog ""

    if ($anyApply -and $script:WtxCtl.Rp.Checked) {
        Write-WtxLog "[*] Creating a System Restore point first..."
        Invoke-WtxHidden (Get-WtxArgString -Key 'Checkpoint' -Extra @())
        Write-WtxLog ""
    }

    $k = 0
    foreach ($j in $jobs) {
        $k++
        $script:WtxCtl.Prog.Text = "Running $k / $($jobs.Count):  $($j.Name)  ($($j.Mode))"
        Write-WtxLog ("[$k/$($jobs.Count)] ===== $($j.Name)  -  $($j.Mode) =====")
        $tokStr = ''
        if ($j.Tokens) { $tokStr = ($j.Tokens -join ' ') }
        Write-WtxLog ("        -Tool $($j.Key) $tokStr")
        [System.Windows.Forms.Application]::DoEvents()
        $argString = Get-WtxArgString -Key $j.Key -Extra $j.Tokens
        try {
            if ($j.Interactive) {
                Write-WtxLog "        (this tool opens its own window - use it, then it returns here)"
                Invoke-WtxVisible $argString
            } else {
                Invoke-WtxHidden $argString
            }
        } catch {
            Write-WtxLog ("  [err] " + $_.Exception.Message)
        }
        if ($script:WtxCtl.Bar) { $script:WtxCtl.Bar.Value = $k }
        Write-WtxLog ""
    }

    foreach ($s in $skips) { Write-WtxLog ("[skipped] " + $s) }
    Write-WtxLog "===== DONE.  Reboot recommended for some tweaks to fully apply. ====="
    $script:WtxCtl.Prog.Text = "Done."
    if ($script:WtxCtl.Bar) { $script:WtxCtl.Bar.Value = $script:WtxCtl.Bar.Maximum }
    $script:WtxCtl.Run.Enabled = $true
    $script:WtxBusy = $false

    if ($anyApply) {
        $ask = [System.Windows.Forms.MessageBox]::Show(
            "Finished $($jobs.Count) tool(s).`r`n`r`nSome changes (HAGS, GPU scheduling, timers, network, drivers) only take full effect after a restart.`r`n`r`nRestart now?",
            'WinToolbox - done', 'YesNo', 'Question')
        if ($ask -eq 'Yes') {
            Write-WtxLog ""
            Write-WtxLog "[*] Restarting in 5 seconds to apply changes..."
            try {
                Start-Process 'shutdown.exe' -ArgumentList '/r','/t','5','/c','WinToolbox: restarting to apply changes' -WindowStyle Hidden
            } catch {
                Write-WtxLog ("  [err] could not schedule restart: " + $_.Exception.Message)
                [System.Windows.Forms.MessageBox]::Show("Couldn't start the restart automatically. Please reboot manually.", 'WinToolbox', 'OK', 'Warning') | Out-Null
            }
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Finished $($jobs.Count) tool(s).", 'WinToolbox - done', 'OK', 'Information') | Out-Null
    }
}

# Toolbox quick-action buttons (Restore point / Revert all / Profile / etc.)
function Invoke-WtxAction {
    param([string]$Key, $Extra, [bool]$Interactive, [string]$Confirm)
    if ($script:WtxBusy) { return }
    if ($Confirm) {
        $r = [System.Windows.Forms.MessageBox]::Show($Confirm, 'WinToolbox', 'YesNo', 'Warning')
        if ($r -ne 'Yes') { return }
    }
    $script:WtxBusy = $true
    $script:WtxCtl.Run.Enabled = $false
    $argString = Get-WtxArgString -Key $Key -Extra $Extra
    Write-WtxLog ("[action] -Tool $Key " + ($Extra -join ' '))
    [System.Windows.Forms.Application]::DoEvents()
    try {
        if ($Interactive) { Write-WtxLog "        (opens its own window)"; Invoke-WtxVisible $argString }
        else { Invoke-WtxHidden $argString }
    } catch {
        Write-WtxLog ("  [err] " + $_.Exception.Message)
    }
    Write-WtxLog ""
    $script:WtxCtl.Run.Enabled = $true
    $script:WtxBusy = $false
}

# ---- profiles (save/restore the whole GUI selection to JSON next to script) ----
function Get-WtxProfileDir {
    Join-Path (Split-Path $script:WtxPath) 'WinToolbox.profiles'
}

function Save-WtxProfile {
    param([string]$Name)
    $data = @{ RestorePoint = [bool]$script:WtxCtl.Rp.Checked; Tools = @{} }
    foreach ($it in $script:WtxCat) {
        $entry = @{
            Checked = [bool]$it.CB.Checked
            Mode    = [string]$it.Combo.SelectedItem
        }
        if ($it.OptSpec.Count -gt 0) { $entry.Opt = $it.OptState }
        if ($it.PfInit)   { $entry.PfInit = [string]$it.PfInit.Text; $entry.PfMax = [string]$it.PfMax.Text }
        if ($it.DlDrives) { $entry.Drives = [string]$it.DlDrives.Text }
        if ($it.FxExe)    { $entry.Exe    = [string]$it.FxExe.Text }
        $data.Tools[$it.Key] = $entry
    }
    $dir = Get-WtxProfileDir
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $path = Join-Path $dir ($Name + '.json')
    $data | ConvertTo-Json -Depth 6 | Set-Content -Path $path -Encoding UTF8
}

function Load-WtxProfile {
    param([string]$Name)
    $path = Join-Path (Get-WtxProfileDir) ($Name + '.json')
    if (-not (Test-Path $path)) { return $false }
    $data = Get-Content $path -Raw | ConvertFrom-Json
    if ($null -ne $data.RestorePoint) { $script:WtxCtl.Rp.Checked = [bool]$data.RestorePoint }
    foreach ($it in $script:WtxCat) {
        $e = $data.Tools.$($it.Key)
        if ($null -eq $e) { continue }
        $it.CB.Checked = [bool]$e.Checked
        if ($e.Mode -and $it.Combo.Items.Contains([string]$e.Mode)) { $it.Combo.SelectedItem = [string]$e.Mode }
        if ($it.OptSpec.Count -gt 0 -and $e.Opt) {
            foreach ($s in $it.OptSpec) {
                $prop = $e.Opt.PSObject.Properties[$s.T]
                if ($prop) {
                    if ($s.Kind -eq 'check') { $it.OptState[$s.T] = [bool]$prop.Value }
                    else { $it.OptState[$s.T] = [string]$prop.Value }
                }
            }
            $it.OptTokens = Compute-WtxOptTokens $it
        }
        if ($it.PfInit -and $null -ne $e.PfInit) { $it.PfInit.Text = [string]$e.PfInit; $it.PfMax.Text = [string]$e.PfMax }
        if ($it.DlDrives -and $null -ne $e.Drives) { $it.DlDrives.Text = [string]$e.Drives }
        if ($it.FxExe -and $null -ne $e.Exe) { $it.FxExe.Text = [string]$e.Exe }
        Update-WtxRow $it
    }
    return $true
}

function Refresh-WtxProfiles {
    $cmb = $script:WtxCtl.ProfCombo
    if ($null -eq $cmb) { return }
    $cur = [string]$cmb.Text
    $cmb.Items.Clear()
    $dir = Get-WtxProfileDir
    if (Test-Path $dir) {
        Get-ChildItem -Path $dir -Filter '*.json' -ErrorAction SilentlyContinue | Sort-Object Name | ForEach-Object {
            [void]$cmb.Items.Add([System.IO.Path]::GetFileNameWithoutExtension($_.Name))
        }
    }
    $cmb.Text = $cur
}

function Show-Gui {
    # one-time self-elevation for the whole GUI
    if (-not (Test-Admin)) {
        Write-Host "Requesting administrator privileges for the GUI..." -ForegroundColor Yellow
        try {
            Start-Process powershell.exe -Verb RunAs -ArgumentList @(
                '-WindowStyle','Hidden','-NoProfile','-ExecutionPolicy','Bypass','-File',("`"$PSCommandPath`""),'-Gui','-HideConsole')
        } catch { Write-Host "Elevation cancelled." -ForegroundColor Red }
        return
    }

    $script:WtxPath = $PSCommandPath
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()

    # ---- gaming dark theme palette ----
    $script:WtxTheme = @{
        Bg     = [System.Drawing.Color]::FromArgb(16, 16, 20)
        Panel  = [System.Drawing.Color]::FromArgb(24, 24, 30)
        Ctl    = [System.Drawing.Color]::FromArgb(45, 45, 54)
        Fg     = [System.Drawing.Color]::FromArgb(235, 235, 240)
        Dim    = [System.Drawing.Color]::FromArgb(150, 150, 160)
        Accent = [System.Drawing.Color]::FromArgb(248, 86, 6)
        Green  = [System.Drawing.Color]::FromArgb(46, 204, 113)
        Border = [System.Drawing.Color]::FromArgb(70, 70, 80)
    }

    function New-WtxItem {
        param(
            [string]$Key, [string]$Name, [string]$Group, [string]$Desc,
            [bool]$HasStatus = $true, [bool]$HasRevert = $true,
            [string[]]$RevertArgs = @('-Revert'), [bool]$Interactive = $false,
            $ExtraMap = $null, [string]$ExeDefault = $null,
            $OptSpec = @(), $ApplyBase = @(), [bool]$NeedOpt = $false,
            [string[]]$VisibleModes = @()
        )
        [pscustomobject]@{
            Key = $Key; Name = $Name; Group = $Group; Desc = $Desc
            HasStatus = $HasStatus; HasRevert = $HasRevert; RevertArgs = $RevertArgs
            Interactive = $Interactive
            ExtraMap = $(if ($null -eq $ExtraMap) { [ordered]@{} } else { $ExtraMap }); ExeDefault = $ExeDefault
            OptSpec = $OptSpec; ApplyBase = $ApplyBase; NeedOpt = $NeedOpt
            VisibleModes = $VisibleModes
            OptState = @{}; OptTokens = @()
            CB = $null; Combo = $null; OptBtn = $null; PfInit = $null; PfMax = $null; DlDrives = $null; FxExe = $null
        }
    }

    $cat = @(
        # ----- AUTO-APPLICABLE -----
        (New-WtxItem 'VisualFX'    '1. Visual Effects'     'Auto' 'thumbnails + smooth fonts' -HasStatus:$false),
        (New-WtxItem 'Input'       '2. Input God Mode'     'Auto' 'mouse/keyboard 1:1 gaming tune'),
        (New-WtxItem 'PowerPlan'   '3. Power Plan'         'Auto' 'max-performance power plan' -HasStatus:$false),
        (New-WtxItem 'Network'     '4. Network God Mode'   'Auto' 'low-latency TCP / Nagle off' `
            -ExtraMap ([ordered]@{ 'Reset stack' = @('-ResetStack') }) `
            -OptSpec @(
                @{ T='Set fast DNS';  Kind='check';  Flag=@('-SetDNS'); Default=$false },
                @{ T='DNS provider';  Kind='choice'; Flag='-DnsProvider'; Choices=@('Cloudflare','Google','Quad9'); Default='Cloudflare'; GateT='Set fast DNS' }
            )),
        (New-WtxItem 'CPU'         '5. CPU God Mode'       'Auto' 'scheduler / throttle tune' `
            -OptSpec @(
                @{ T='Disable CPU mitigations (Spectre/Meltdown - less secure)'; Kind='check'; Flag=@('-DisableMitigations'); Default=$false },
                @{ T='Boot timer tweaks (system-dependent)';                     Kind='check'; Flag=@('-TimerTweaks');        Default=$false }
            )),
        (New-WtxItem 'GPU'         '6. NVIDIA GPU'         'Auto' 'force max performance' `
            -OptSpec @(
                @{ T='Enable HAGS';                       Kind='check'; Flag=@('-HAGS','On');   Default=$false },
                @{ T='Lock clocks high (supported cards)'; Kind='check'; Flag=@('-LockClocks'); Default=$false },
                @{ T='Power limit (W)';                   Kind='text';  Flag='-PowerLimit'; Default=''; Numeric=$true; Width=60 }
            )),
        (New-WtxItem 'Debloat'     '7. Debloat'            'Auto' 'telemetry services + tasks off' `
            -OptSpec @(
                @{ T='Disable Xbox services';        Kind='check'; Flag=@('-DisableXbox');    Default=$false },
                @{ T='Disable SysMain (Superfetch)'; Kind='check'; Flag=@('-DisableSysMain'); Default=$false },
                @{ T='Disable Print Spooler';        Kind='check'; Flag=@('-NoPrinter');      Default=$false },
                @{ T='Disable Windows Search index'; Kind='check'; Flag=@('-DisableSearch');  Default=$false }
            )),
        (New-WtxItem 'GameLoop'    '8. GameLoop / VBS'     'Auto' 'VBS / Hyper-V off (reboot)'),
        (New-WtxItem 'GameDVR'     '9. Game DVR'           'Auto' 'DVR off, Game Mode on' `
            -OptSpec @(
                @{ T='Disable background apps'; Kind='check'; Flag=@('-DisableBackgroundApps'); Default=$false }
            )),
        (New-WtxItem 'Storage'     '10. Storage & Memory'  'Auto' 'TRIM / 8.3 off + RAM tweaks'),
        (New-WtxItem 'GameProfile' '11. Per-game priority' 'Auto' 'Apply = GameLoop preset; Add game = set an exe to High' `
            -ExtraMap ([ordered]@{ 'Add game' = @('-AddGame','__EXE__','-Priority','High') }) -ExeDefault 'AndroidEmulatorEn.exe'),
        (New-WtxItem 'Audio'       '12. Audio'             'Auto' 'enhancements / ducking off'),
        (New-WtxItem 'Display'     '13. Display/Fullscreen' 'Auto' 'FSO off + windowed-opt' `
            -OptSpec @(
                @{ T='Disable MPO (fixes flicker/stutter)'; Kind='check'; Flag=@('-DisableMPO'); Default=$false }
            )),
        (New-WtxItem 'NicTune'     '14. NIC Tuning'        'Auto' 'EEE / power-save off' `
            -OptSpec @(
                @{ T='Disable interrupt moderation & LSO (aggressive)'; Kind='check'; Flag=@('-NoModeration'); Default=$false }
            )),
        (New-WtxItem 'GpuPref'     '30. Graphics Pref'     'Auto' 'game exes -> High performance GPU + HAGS on' `
            -OptSpec @(
                @{ T='Skip HAGS (leave GPU scheduling as-is)'; Kind='check'; Flag=@('-NoHags'); Default=$false }
            )),
        # ----- MANUAL ONLY -----
        (New-WtxItem 'PageFile'    '15. Page File'         'Manual' 'fixed virtual memory' -HasStatus:$false),
        (New-WtxItem 'DriveLock'   '16. Drive Lock'        'Manual' 'block writes to D:/E:/...' -RevertArgs @('-Unlock')),
        (New-WtxItem 'Browsers'    '17. Download Browsers' 'Manual' 'pick which browsers to fetch' -HasStatus:$false -HasRevert:$false -NeedOpt:$true `
            -OptSpec @(
                @{ T='Google Chrome'; Kind='check'; Flag=@('-Chrome'); Default=$true },
                @{ T='Brave';         Kind='check'; Flag=@('-Brave');  Default=$true }
            )),
        (New-WtxItem 'WinSettings' '18. Windows Settings'  'Manual' 'Apply = dark + transparency off (silent); Open settings = full GUI' -HasStatus:$false -HasRevert:$true `
            -ApplyBase @('-WinApply') `
            -ExtraMap ([ordered]@{ 'Open settings' = @('-WinShowUi') }) -VisibleModes @('Open settings') `
            -OptSpec @(
                @{ T='Dark mode';                 Kind='check'; Flag=@('-WinDark');            Default=$true },
                @{ T='Transparency effects off';  Kind='check'; Flag=@('-WinTransparencyOff'); Default=$true },
                @{ T='Set Sri Lanka time zone';   Kind='check'; Flag=@('-WinTimeZone');        Default=$false }
            )),
        (New-WtxItem 'TempCleaner' '19. Temp Cleaner'      'Manual' 'Apply = GodMode clean; Preview = scan only' -HasStatus:$false -HasRevert:$false `
            -ExtraMap ([ordered]@{ 'Preview' = @('-Preview') }) -ApplyBase @('-GodMode','-Force') `
            -OptSpec @(
                @{ T='Include browser caches';            Kind='check'; Flag=@('-IncludeBrowsers');  Default=$false },
                @{ T='Remove Windows.old';                Kind='check'; Flag=@('-RemoveWindowsOld'); Default=$false },
                @{ T='Reset component store (DISM, slow)'; Kind='check'; Flag=@('-ResetBase');        Default=$false },
                @{ T='Clear event logs';                  Kind='check'; Flag=@('-ClearEventLogs');   Default=$false }
            )),
        (New-WtxItem 'Startup'     '20. Startup manager'   'Manual' 'Apply = disable heavy startup apps (silent, safe); Open manager = full list' `
            -ApplyBase @('-StartupApply') `
            -ExtraMap ([ordered]@{ 'Open manager' = @('-Manage') }) -VisibleModes @('Open manager')),
        (New-WtxItem 'Latency'     '21. Latency/Interrupt' 'Manual' 'Apply = DPC advisor; modes: Enable MSI / Energy report' -HasStatus:$false `
            -ExtraMap ([ordered]@{ 'Enable MSI' = @('-EnableMSI'); 'Energy report' = @('-Trace') })),
        (New-WtxItem 'GameFocus'   '22. Game Focus'        'Manual' 'Apply = notifications off; Boost = game to High priority' `
            -ExtraMap ([ordered]@{ 'Boost' = @('-Boost','__EXE__') }) -ExeDefault 'AndroidEmulatorEn.exe'),
        (New-WtxItem 'GameRules'   '23. Game Rules'        'Manual' 'Apply = run rules now; Install / Uninstall the watcher' `
            -ExtraMap ([ordered]@{ 'GameLoop preset' = @('-GameLoopPreset'); 'Install watcher' = @('-Install'); 'Uninstall watcher' = @('-Uninstall') })),
        (New-WtxItem 'Updates'     '24. Windows Update'    'Manual' 'block driver updates, P2P off'),
        (New-WtxItem 'Privacy'     '25. Privacy'           'Manual' 'ad ID / activity / telemetry off'),
        (New-WtxItem 'Apps'        '26. Apps remover'      'Manual' 'pick what to remove' -NeedOpt:$true `
            -OptSpec @(
                @{ T='Remove general bloat';       Kind='check'; Flag=@('-RemoveBloat');     Default=$true },
                @{ T='Remove OneDrive';            Kind='check'; Flag=@('-RemoveOneDrive');  Default=$true },
                @{ T='Remove Internet Explorer';   Kind='check'; Flag=@('-RemoveIE');        Default=$true },
                @{ T='Remove Paint / Paint 3D';    Kind='check'; Flag=@('-RemovePaint');     Default=$true },
                @{ T='Remove Microsoft Store (advanced)'; Kind='check'; Flag=@('-RemoveStore'); Default=$false }
            )),
        (New-WtxItem 'Features'    '27. Features/services' 'Manual' 'pick what to harden' -NeedOpt:$true `
            -OptSpec @(
                @{ T='Harden/disable risky services (Spooler/RDP etc.)'; Kind='check'; Flag=@('-HardenServices');  Default=$true },
                @{ T='Untick optional Windows features';                 Kind='check'; Flag=@('-DisableFeatures'); Default=$true }
            )),
        (New-WtxItem 'Taskbar'     '28. Taskbar/desktop'   'Manual' 'pick what to hide' -NeedOpt:$true `
            -OptSpec @(
                @{ T='Hide search box';       Kind='check'; Flag=@('-HideSearch');       Default=$true },
                @{ T='Hide Widgets / News';   Kind='check'; Flag=@('-HideWidgets');      Default=$true },
                @{ T='Hide Task View button'; Kind='check'; Flag=@('-HideTaskView');     Default=$true },
                @{ T='Hide desktop icons';    Kind='check'; Flag=@('-HideDesktopIcons'); Default=$false }
            )),
        (New-WtxItem 'WinUI'       '29. Win10/11 UI'       'Manual' 'classic menu / Copilot off / taskbar left - items not for your OS are skipped' -NeedOpt:$true `
            -OptSpec @(
                @{ T='Classic right-click menu (Win11)';  Kind='check'; Flag=@('-ClassicMenu');       Default=$true },
                @{ T='Taskbar align left (Win11)';        Kind='check'; Flag=@('-TaskbarLeft');       Default=$false },
                @{ T='Hide Chat/Teams button (Win11)';    Kind='check'; Flag=@('-HideChat');          Default=$true },
                @{ T='Disable Copilot';                   Kind='check'; Flag=@('-DisableCopilot');    Default=$true },
                @{ T='Hide Meet Now icon (Win10)';        Kind='check'; Flag=@('-HideMeetNow');       Default=$true },
                @{ T='Hide Cortana button (Win10)';       Kind='check'; Flag=@('-HideCortanaButton'); Default=$true },
                @{ T='Transparency effects off (perf)';   Kind='check'; Flag=@('-NoTransparency');    Default=$false },
                @{ T='Show file extensions';              Kind='check'; Flag=@('-ShowFileExt');       Default=$true }
            ))
    )
    $script:WtxCat  = $cat
    $script:WtxTip  = New-Object System.Windows.Forms.ToolTip
    $script:WtxBusy = $false

    function New-Btn {
        param([string]$Text, [int]$X, [int]$Y, [int]$W, $OnClick)
        $b = New-Object System.Windows.Forms.Button
        $b.Text = $Text
        $b.Location = New-Object System.Drawing.Point($X, $Y)
        $b.Size = New-Object System.Drawing.Size($W, 26)
        if ($OnClick) { $b.Add_Click($OnClick) }
        return $b
    }

    function Add-WtxRow {
        param($parent, $item, [int]$y)

        # seed option state from defaults (so Apply works even if dialog never opened)
        if ($item.OptSpec.Count -gt 0 -and $item.OptState.Count -eq 0) {
            foreach ($s in $item.OptSpec) {
                if ($s.Kind -eq 'check') { $item.OptState[$s.T] = [bool]$s.Default }
                else { $item.OptState[$s.T] = [string]$s.Default }
            }
            $item.OptTokens = Compute-WtxOptTokens $item
        }

        $cb = New-Object System.Windows.Forms.CheckBox
        $cb.Location = New-Object System.Drawing.Point(6, $y)
        $cb.Size = New-Object System.Drawing.Size(186, 22)
        $cb.Text = $item.Name
        $cb.Font = New-Object System.Drawing.Font('Segoe UI', 9)
        $parent.Controls.Add($cb)
        $item.CB = $cb
        $script:WtxTip.SetToolTip($cb, $item.Desc)

        $combo = New-Object System.Windows.Forms.ComboBox
        $combo.DropDownStyle = 'DropDownList'
        $combo.Location = New-Object System.Drawing.Point(196, ($y - 1))
        $combo.Size = New-Object System.Drawing.Size(74, 22)
        [void]$combo.Items.Add('Apply')
        if ($item.HasRevert) { [void]$combo.Items.Add('Revert') }
        if ($item.HasStatus) { [void]$combo.Items.Add('Status') }
        foreach ($em in $item.ExtraMap.Keys) { [void]$combo.Items.Add($em) }
        $combo.SelectedItem = 'Apply'
        $combo.Tag = $item
        $combo.Add_SelectedIndexChanged({ Update-WtxRow $this.Tag })
        $parent.Controls.Add($combo)
        $item.Combo = $combo

        $x = 278
        if ($item.Key -eq 'PageFile') {
            $l1 = New-Object System.Windows.Forms.Label; $l1.Text = 'Init'; $l1.AutoSize = $true; $l1.Location = New-Object System.Drawing.Point($x, ($y + 3)); $parent.Controls.Add($l1)
            $t1 = New-Object System.Windows.Forms.TextBox; $t1.Text = '8192'; $t1.Size = New-Object System.Drawing.Size(52, 22); $t1.Location = New-Object System.Drawing.Point(($x + 26), $y); $parent.Controls.Add($t1); $item.PfInit = $t1
            $l2 = New-Object System.Windows.Forms.Label; $l2.Text = 'Max'; $l2.AutoSize = $true; $l2.Location = New-Object System.Drawing.Point(($x + 84), ($y + 3)); $parent.Controls.Add($l2)
            $t2 = New-Object System.Windows.Forms.TextBox; $t2.Text = '12288'; $t2.Size = New-Object System.Drawing.Size(56, 22); $t2.Location = New-Object System.Drawing.Point(($x + 114), $y); $parent.Controls.Add($t2); $item.PfMax = $t2
        }
        elseif ($item.Key -eq 'DriveLock') {
            $l1 = New-Object System.Windows.Forms.Label; $l1.Text = 'Drives'; $l1.AutoSize = $true; $l1.Location = New-Object System.Drawing.Point($x, ($y + 3)); $parent.Controls.Add($l1)
            $t1 = New-Object System.Windows.Forms.TextBox; $t1.Text = 'D,E'; $t1.Size = New-Object System.Drawing.Size(60, 22); $t1.Location = New-Object System.Drawing.Point(($x + 44), $y); $parent.Controls.Add($t1); $item.DlDrives = $t1
        }
        elseif ($item.ExeDefault) {
            $l1 = New-Object System.Windows.Forms.Label; $l1.Text = 'exe'; $l1.AutoSize = $true; $l1.Location = New-Object System.Drawing.Point($x, ($y + 3)); $parent.Controls.Add($l1)
            $t1 = New-Object System.Windows.Forms.TextBox; $t1.Text = $item.ExeDefault; $t1.Size = New-Object System.Drawing.Size(184, 22); $t1.Location = New-Object System.Drawing.Point(($x + 26), $y); $parent.Controls.Add($t1); $item.FxExe = $t1
        }
        elseif ($item.OptSpec.Count -gt 0) {
            $ob = New-Object System.Windows.Forms.Button
            $ob.Text = 'Options...'
            $ob.Size = New-Object System.Drawing.Size(88, 22)
            $ob.Location = New-Object System.Drawing.Point($x, ($y - 1))
            $ob.Tag = $item
            $ob.Add_Click({ Show-WtxOptions $this.Tag })
            $parent.Controls.Add($ob)
            $item.OptBtn = $ob
        }
        Update-WtxRow $item
    }

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'WinToolbox  -  Windows 10/11 gaming toolbox'
    $form.ClientSize = New-Object System.Drawing.Size(1120, 760)
    $form.StartPosition = 'CenterScreen'
    $form.FormBorderStyle = 'FixedSingle'
    $form.MaximizeBox = $false
    $form.Font = New-Object System.Drawing.Font('Segoe UI', 9)

    $wtxOS = Get-WtxOS

    $title = New-Object System.Windows.Forms.Label
    $title.Text = 'WINTOOLBOX  |  MAX GAMING'
    $title.Font = New-Object System.Drawing.Font('Segoe UI', 14, [System.Drawing.FontStyle]::Bold)
    $title.AutoSize = $true
    $title.Location = New-Object System.Drawing.Point(14, 8)
    $form.Controls.Add($title)

    $osLbl = New-Object System.Windows.Forms.Label
    $osLbl.Text = ("{0} {1} (build {2})   -   Administrator" -f $wtxOS.Name, $wtxOS.Version, $wtxOS.Build)
    $osLbl.AutoSize = $true
    $osLbl.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
    $osLbl.ForeColor = [System.Drawing.Color]::FromArgb(33, 115, 70)
    $osLbl.Location = New-Object System.Drawing.Point(224, 16)
    $form.Controls.Add($osLbl)

    $adm = New-Object System.Windows.Forms.Label
    $adm.Text = 'Tick tools, pick a mode per tool, Options... shows every switch. MAX = full-tick everything (except Drive Lock / Browsers), then RUN SELECTED.'
    $adm.AutoSize = $true
    $adm.ForeColor = [System.Drawing.Color]::Gray
    $adm.Location = New-Object System.Drawing.Point(16, 40)
    $form.Controls.Add($adm)

    $form.Controls.Add( (New-Btn 'All'    16  62 48 { foreach ($i in $script:WtxCat) { $i.CB.Checked = $true } }) )
    $form.Controls.Add( (New-Btn 'Auto'   68  62 56 { foreach ($i in $script:WtxCat) { $i.CB.Checked = ($i.Group -eq 'Auto') } }) )
    $form.Controls.Add( (New-Btn 'Manual' 128 62 64 { foreach ($i in $script:WtxCat) { $i.CB.Checked = ($i.Group -eq 'Manual') } }) )
    $form.Controls.Add( (New-Btn 'Clear'  196 62 52 { foreach ($i in $script:WtxCat) { $i.CB.Checked = $false } }) )
    $btnMax = New-Btn 'MAX' 252 62 64 { Set-WtxMaxAll }
    $btnMax.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($btnMax)
    $script:WtxTip.SetToolTip($btnMax, 'Tick EVERYTHING with full options (except 16 Drive Lock, 17 Browsers), then press RUN SELECTED')

    $sep = New-Object System.Windows.Forms.Label
    $sep.Text = 'Checked ->'
    $sep.AutoSize = $true
    $sep.Location = New-Object System.Drawing.Point(324, 67)
    $form.Controls.Add($sep)
    $form.Controls.Add( (New-Btn 'Apply'  392 62 60 { Set-WtxAllChecked 'Apply' }) )
    $form.Controls.Add( (New-Btn 'Revert' 456 62 60 { Set-WtxAllChecked 'Revert' }) )
    $form.Controls.Add( (New-Btn 'Status' 520 62 60 { Set-WtxAllChecked 'Status' }) )

    $chkRP = New-Object System.Windows.Forms.CheckBox
    $chkRP.Text = 'Create Restore Point first'
    $chkRP.Checked = $true
    $chkRP.AutoSize = $true
    $chkRP.Location = New-Object System.Drawing.Point(600, 65)
    $form.Controls.Add($chkRP)

    $lblP = New-Object System.Windows.Forms.Label
    $lblP.Text = 'Profile:'; $lblP.AutoSize = $true
    $lblP.Location = New-Object System.Drawing.Point(800, 66)
    $form.Controls.Add($lblP)
    $cmbProf = New-Object System.Windows.Forms.ComboBox
    $cmbProf.DropDownStyle = 'DropDown'
    $cmbProf.Size = New-Object System.Drawing.Size(130, 22)
    $cmbProf.Location = New-Object System.Drawing.Point(852, 63)
    $form.Controls.Add($cmbProf)
    $form.Controls.Add( (New-Btn 'Save' 988 62 54 {
        $nm = ([string]$script:WtxCtl.ProfCombo.Text).Trim()
        if ($nm -eq '') { [System.Windows.Forms.MessageBox]::Show('Type a profile name first.', 'WinToolbox', 'OK', 'Information') | Out-Null; return }
        $nm = ($nm -replace '[\\/:*?"<>|]', '_')
        Save-WtxProfile $nm
        Refresh-WtxProfiles
        $script:WtxCtl.ProfCombo.Text = $nm
        Write-WtxLog "[profile] saved '$nm'"
    }) )
    $form.Controls.Add( (New-Btn 'Load' 1046 62 54 {
        $nm = ([string]$script:WtxCtl.ProfCombo.Text).Trim()
        if ($nm -eq '') { [System.Windows.Forms.MessageBox]::Show('Pick or type a profile to load.', 'WinToolbox', 'OK', 'Information') | Out-Null; return }
        if (Load-WtxProfile $nm) { Write-WtxLog "[profile] loaded '$nm'" }
        else { [System.Windows.Forms.MessageBox]::Show("Profile '$nm' not found.", 'WinToolbox', 'OK', 'Warning') | Out-Null }
    }) )

    $gbA = New-Object System.Windows.Forms.GroupBox
    $gbA.Text = 'AUTO-APPLICABLE'
    $gbA.Location = New-Object System.Drawing.Point(14, 92)
    $gbA.Size = New-Object System.Drawing.Size(546, 424)
    $form.Controls.Add($gbA)
    $pA = New-Object System.Windows.Forms.Panel
    $pA.Location = New-Object System.Drawing.Point(8, 18)
    $pA.Size = New-Object System.Drawing.Size(530, 398)
    $pA.AutoScroll = $true
    $gbA.Controls.Add($pA)

    $gbM = New-Object System.Windows.Forms.GroupBox
    $gbM.Text = 'MANUAL ONLY'
    $gbM.Location = New-Object System.Drawing.Point(566, 92)
    $gbM.Size = New-Object System.Drawing.Size(540, 424)
    $form.Controls.Add($gbM)
    $pM = New-Object System.Windows.Forms.Panel
    $pM.Location = New-Object System.Drawing.Point(8, 18)
    $pM.Size = New-Object System.Drawing.Size(524, 398)
    $pM.AutoScroll = $true
    $gbM.Controls.Add($pM)

    $yA = 4; $yM = 4
    foreach ($it in $cat) {
        if ($it.Group -eq 'Auto') { Add-WtxRow $pA $it $yA; $yA += 26 }
        else { Add-WtxRow $pM $it $yM; $yM += 26 }
    }

    $btnRun = New-Object System.Windows.Forms.Button
    $btnRun.Text = 'RUN  SELECTED'
    $btnRun.Location = New-Object System.Drawing.Point(14, 524)
    $btnRun.Size = New-Object System.Drawing.Size(240, 38)
    $btnRun.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
    $btnRun.BackColor = [System.Drawing.Color]::FromArgb(33, 150, 83)
    $btnRun.ForeColor = [System.Drawing.Color]::White
    $btnRun.FlatStyle = 'Flat'
    $btnRun.Add_Click({ Invoke-WtxRun })
    $form.Controls.Add($btnRun)

    $bar = New-Object System.Windows.Forms.ProgressBar
    $bar.Location = New-Object System.Drawing.Point(266, 526)
    $bar.Size = New-Object System.Drawing.Size(284, 12)
    $bar.Minimum = 0; $bar.Maximum = 1; $bar.Value = 0
    $form.Controls.Add($bar)

    $prog = New-Object System.Windows.Forms.Label
    $prog.Text = 'Idle.'
    $prog.AutoSize = $true
    $prog.Location = New-Object System.Drawing.Point(266, 544)
    $form.Controls.Add($prog)

    $fl = New-Object System.Windows.Forms.FlowLayoutPanel
    $fl.Location = New-Object System.Drawing.Point(566, 520)
    $fl.Size = New-Object System.Drawing.Size(540, 44)
    $fl.FlowDirection = 'LeftToRight'
    $fl.WrapContents = $false
    $form.Controls.Add($fl)
    $fl.Controls.Add( (New-Btn 'Restore Pt' 0 0 74 { Invoke-WtxAction 'Checkpoint' @() $false $null }) )
    $fl.Controls.Add( (New-Btn 'Snapshot'   0 0 72 { Invoke-WtxAction 'Snapshot' @('-Action','Save') $false $null }) )
    $fl.Controls.Add( (New-Btn 'Status All' 0 0 72 { Invoke-WtxAction 'StatusAll' @() $false $null }) )
    $fl.Controls.Add( (New-Btn 'Revert All' 0 0 72 { Invoke-WtxAction 'RevertAll' @() $false 'Revert ALL perf/gaming tweaks now?' }) )
    $fl.Controls.Add( (New-Btn 'Profile'    0 0 64 { Invoke-WtxAction 'Profile' @() $true $null }) )
    $fl.Controls.Add( (New-Btn 'Apply-All'  0 0 70 { Invoke-WtxAction 'ApplyAll' @() $true $null }) )
    $fl.Controls.Add( (New-Btn 'Audit'      0 0 56 { Invoke-WtxAction 'AuditLog' @() $false $null }) )

    $logLbl = New-Object System.Windows.Forms.Label
    $logLbl.Text = 'Log'
    $logLbl.AutoSize = $true
    $logLbl.Location = New-Object System.Drawing.Point(14, 574)
    $form.Controls.Add($logLbl)

    $txtLog = New-Object System.Windows.Forms.TextBox
    $txtLog.Multiline = $true
    $txtLog.ReadOnly = $true
    $txtLog.ScrollBars = 'Vertical'
    $txtLog.WordWrap = $false
    $txtLog.Location = New-Object System.Drawing.Point(14, 592)
    $txtLog.Size = New-Object System.Drawing.Size(1092, 156)
    $txtLog.Font = New-Object System.Drawing.Font('Consolas', 9)
    $txtLog.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
    $txtLog.ForeColor = [System.Drawing.Color]::FromArgb(220, 220, 220)
    $form.Controls.Add($txtLog)

    $form.Controls.Add( (New-Btn 'Copy log'  962 565 68 {
        $t = $script:WtxCtl.Log.Text
        if ($t) { try { [System.Windows.Forms.Clipboard]::SetText($t) } catch {} }
    }) )
    $form.Controls.Add( (New-Btn 'Clear log' 1036 565 70 { $script:WtxCtl.Log.Clear() }) )

    $script:WtxCtl = @{ Log = $txtLog; Run = $btnRun; Prog = $prog; Rp = $chkRP; ProfCombo = $cmbProf; Bar = $bar }

    # ---- apply the gaming dark theme, then re-assert the feature colors ----
    $form.BackColor = $script:WtxTheme.Bg
    $form.ForeColor = $script:WtxTheme.Fg
    Set-WtxThemeDeep $form
    $title.ForeColor  = $script:WtxTheme.Accent
    $osLbl.ForeColor  = $script:WtxTheme.Green
    $btnRun.BackColor = $script:WtxTheme.Accent
    $btnRun.ForeColor = [System.Drawing.Color]::White
    $btnRun.FlatAppearance.BorderColor = $script:WtxTheme.Accent
    $btnMax.BackColor = [System.Drawing.Color]::FromArgb(150, 32, 32)
    $btnMax.ForeColor = [System.Drawing.Color]::White
    $btnMax.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(200, 60, 60)

    $form.Add_FormClosing({
        if ($script:WtxBusy) {
            $_.Cancel = $true
            [System.Windows.Forms.MessageBox]::Show('A run is in progress. Please wait for it to finish.', 'WinToolbox', 'OK', 'Warning') | Out-Null
        }
    })

    Refresh-WtxProfiles

    if ($HideConsole) {
        try {
            if (-not ('WtxNative.Win' -as [type])) {
                Add-Type -Namespace WtxNative -Name Win -MemberDefinition @'
[System.Runtime.InteropServices.DllImport("kernel32.dll")] public static extern System.IntPtr GetConsoleWindow();
[System.Runtime.InteropServices.DllImport("user32.dll")] public static extern bool ShowWindow(System.IntPtr hWnd, int nCmdShow);
'@
            }
            $h = [WtxNative.Win]::GetConsoleWindow()
            if ($h -ne [System.IntPtr]::Zero) { [void][WtxNative.Win]::ShowWindow($h, 0) }
        } catch {}
    }

    [void]$form.ShowDialog()
    $form.Dispose()
}

# ===========================================================================
#  Entry point / router
# ===========================================================================

# PowerPlan startup task re-runs this script with -Enforce (as SYSTEM)
if ($Enforce) { Invoke-PowerPlan -Enforce; return }

if ($Gui) { Show-Gui; return }

if ($Tool) {
    Write-AuditLog "Tool=$Tool$(if($Revert){' -Revert'})$(if($Status){' -Status'})$(if($Action -and $Tool -eq 'Snapshot'){" -Action $Action"})"
    switch ($Tool) {
        'VisualFX'    { Invoke-VisualFX -Revert:$Revert -RestartExplorer:$RestartExplorer -NoPause:$NoPause }
        'Input'       { Invoke-Input -Revert:$Revert -Status:$Status -NoPause:$NoPause }
        'PowerPlan'   { if ($Revert) { Invoke-PowerPlan -RevertNow } else { Invoke-PowerPlan -ApplyNow } }
        'PageFile'    { Invoke-PageFile -Initial $Initial -Maximum $Maximum -Revert:$Revert }
        'DriveLock'   {
            if ($PSBoundParameters.ContainsKey('Drives')) {
                Invoke-DriveLock -Lock:$Lock -Unlock:$Unlock -Status:$Status -Off:$Off -Drives $Drives
            } else {
                Invoke-DriveLock -Lock:$Lock -Unlock:$Unlock -Status:$Status -Off:$Off
            }
        }
        'Browsers'    { Invoke-Browsers -Chrome:$Chrome -Brave:$Brave }
        'WinSettings' { Invoke-WinSettings -Revert:$Revert -WallpaperDir $WallpaperDir -WinApply:$WinApply -WinDark:$WinDark -WinTransparencyOff:$WinTransparencyOff -WinTimeZone:$WinTimeZone -WinShowUi:$WinShowUi }
        'TempCleaner' {
            Invoke-TempCleaner -Preview:$Preview -GodMode:$GodMode -IncludeBrowsers:$IncludeBrowsers `
                -RemoveWindowsOld:$RemoveWindowsOld -ResetBase:$ResetBase -ClearEventLogs:$ClearEventLogs `
                -Schedule:$Schedule -Force:$Force
            if (-not $Schedule -and -not $Force -and -not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'Network'     {
            Invoke-Network -Revert:$Revert -Status:$Status -SetDNS:$SetDNS -DnsProvider $DnsProvider -ResetStack:$ResetStack
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'CPU'         {
            Invoke-CPU -Revert:$Revert -Status:$Status -DisableMitigations:$DisableMitigations -TimerTweaks:$TimerTweaks
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'GPU'         {
            Invoke-GPU -Revert:$Revert -Status:$Status -LockClocks:$LockClocks -PowerLimit $PowerLimit -HAGS $HAGS
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'Debloat'     {
            Invoke-Debloat -Revert:$Revert -Status:$Status -DisableXbox:$DisableXbox -NoPrinter:$NoPrinter -DisableSearch:$DisableSearch -DisableSysMain:$DisableSysMain
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'GameLoop'    {
            Invoke-GameLoop -Revert:$Revert -Status:$Status
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'GameDVR'     {
            Invoke-GameDVR -Revert:$Revert -Status:$Status -DisableBackgroundApps:$DisableBackgroundApps
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'Checkpoint'  { Invoke-Checkpoint; if (-not $NoPause) { Pause-Any 'Press Enter to close...' } }
        'StatusAll'   { Invoke-StatusAll; if (-not $NoPause) { Pause-Any 'Press Enter to close...' } }
        'RevertAll'   { Invoke-RevertAll; if (-not $NoPause) { Pause-Any 'Press Enter to close...' } }
        'Profile'     { Invoke-Profile;   if (-not $NoPause) { Pause-Any 'Press Enter to close...' } }
        'ApplyAll'    { Invoke-ApplyAll;  if (-not $NoPause) { Pause-Any 'Press Enter to close...' } }
        'Startup'     {
            Invoke-Startup -Status:$Status -Revert:$Revert -StartupApply:$StartupApply -Manage:$Manage
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'Storage'     {
            Invoke-Storage -Status:$Status -Revert:$Revert
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'GameProfile' {
            Invoke-GameProfile -Status:$Status -Revert:$Revert -GameLoopPreset:$GameLoopPreset -AddGame $AddGame -Priority $Priority
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'Latency'     {
            Invoke-Latency -Status:$Status -Revert:$Revert -Trace:$Trace -EnableMSI:$EnableMSI
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'GameFocus'   {
            Invoke-GameFocus -Status:$Status -Revert:$Revert -Boost $Boost
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'Audio'       {
            Invoke-Audio -Status:$Status -Revert:$Revert
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'Display'     {
            Invoke-Display -Status:$Status -Revert:$Revert -DisableMPO:$DisableMPO
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'GameRules'   {
            Invoke-GameRules -Status:$Status -Revert:$Revert -Daemon:$Daemon -Install:$Install -Uninstall:$Uninstall -ApplyNow:$ApplyNow -GameLoopPreset:$GameLoopPreset -AddRule $AddRule -RemoveRule $RemoveRule -Priority $Priority -Cores $Cores -IntervalMin $IntervalMin
            if (-not $Daemon) { if (-not $NoPause) { Pause-Any 'Press Enter to close...' } }
        }
        'NicTune'     {
            Invoke-NicTune -Status:$Status -Revert:$Revert -NoModeration:$NoModeration
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'Updates'     {
            Invoke-Updates -Status:$Status -Revert:$Revert
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'Privacy'     {
            Invoke-Privacy -Status:$Status -Revert:$Revert
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'Apps'        {
            Invoke-Apps -Status:$Status -Revert:$Revert -RemoveBloat:$RemoveBloat -RemoveOneDrive:$RemoveOneDrive -RemoveIE:$RemoveIE -RemovePaint:$RemovePaint -RemoveStore:$RemoveStore
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'Features'    {
            Invoke-Features -Status:$Status -Revert:$Revert -HardenServices:$HardenServices -DisableFeatures:$DisableFeatures -DisableFeature $DisableFeature
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'Taskbar'     {
            Invoke-Taskbar -Status:$Status -Revert:$Revert -HideSearch:$HideSearch -HideWidgets:$HideWidgets -HideTaskView:$HideTaskView -HideDesktopIcons:$HideDesktopIcons -NoRestart:$NoRestart
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'WinUI'       {
            Invoke-WinUI -Status:$Status -Revert:$Revert -ClassicMenu:$ClassicMenu -TaskbarLeft:$TaskbarLeft -HideChat:$HideChat -DisableCopilot:$DisableCopilot -HideMeetNow:$HideMeetNow -HideCortanaButton:$HideCortanaButton -NoTransparency:$NoTransparency -ShowFileExt:$ShowFileExt -NoRestart:$NoRestart
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'GpuPref'     {
            Invoke-GpuPref -Status:$Status -Revert:$Revert -NoHags:$NoHags -AddApp $AddApp
            if (-not $NoPause) { Pause-Any 'Press Enter to close...' }
        }
        'Snapshot'    { Invoke-Snapshot -Action $Action -Name $Name; if (-not $NoPause) { Pause-Any 'Press Enter to close...' } }
        'AuditLog'    { Show-AuditLog; if (-not $NoPause) { Pause-Any 'Press Enter to close...' } }
    }
    return
}

Show-MainMenu
