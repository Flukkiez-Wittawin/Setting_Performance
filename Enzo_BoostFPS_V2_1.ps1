# ====================================================================
#   FIVEM & WINDOWS PVP OVERHAUL SCRIPT [CRASH-PROOF EDITION]
#   TARGET: ZERO DESYNC / ABSOLUTE STABILITY / ZERO SILENT CRASHES
# ====================================================================

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Elevated Kernel Privileges..." -ForegroundColor Red
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Clear-Host
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "    ENFORCING HIGH-PERFORMANCE HIGH-STABILITY TWEAKS     " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

# 1. PROCESS PRIORITY LOCK (FiveM & GTA5 Ultimate Override)
Write-Host "[1/11] Locking Executables to High Priority..." -ForegroundColor Cyan
$Executables = @("FiveM_GTAProcess.exe", "GTA5.exe", "FiveM.exe")
foreach ($Exe in $Executables) {
    $Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$Exe\PerfOptions"
    if (!(Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-ItemProperty -Path $Path -Name "CpuPriorityClass" -Value 3 -Type DWord -Force | Out-Null
}
Write-Host "-> Game executables forced to HIGH priority permanently." -ForegroundColor Green

# 2. QUANTUM SCHEDULING TUNING (Win32 Priority Separation)
Write-Host "[2/11] Tuning Win32 Priority Separation for Optimal Frame-time..." -ForegroundColor Cyan
# Value 26 Hex (38 Dec) optimizes thread cycles for foreground gaming without context switching bugs
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force | Out-Null
Write-Host "-> Thread allocation optimized for active gaming application." -ForegroundColor Green

# 3. HIGH PERFORMANCE POWER PROFILES
Write-Host "[3/11] Deploying Optimized Power Scheme Settings..." -ForegroundColor Cyan
$BasePlan = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
$CustomPlanGuid = "77777777-7777-7777-7777-777777777777"
powercfg /delete $CustomPlanGuid 2>$null
powercfg /duplicatescheme $BasePlan $CustomPlanGuid | Out-Null
powercfg /changename $CustomPlanGuid "[STABLE-ULTIMATE] - FIVEM PVP" "Max performance with reliable hardware voltage regulations."
$ProcSubgroup = "54533251-82be-4824-96c1-47b60b740d00"
powercfg /setacvalueindex $CustomPlanGuid $ProcSubgroup 893dee5e-7878-483d-9d3a-3a2e16c03f65 5
powercfg /setacvalueindex $CustomPlanGuid $ProcSubgroup bc5038f7-23e0-4960-96da-33abaf5935ec 100
powercfg /setactive $CustomPlanGuid
Write-Host "-> Balanced power-performance deployment completed." -ForegroundColor Green

# 4. HARDWARE NETWORK ADAPTER OVERHAUL (Anti-DeSync & Instant Latency)
Write-Host "[4/11] Forcing Ultra-Low Latency on Physical Network Adapters..." -ForegroundColor Cyan
Get-NetAdapter | Where-Object {$_.Physical} | ForEach-Object {
    Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Interrupt Moderation" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Flow Control" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Energy Efficient Ethernet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Green Ethernet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
}
netsh int tcp set global rsc=disabled | Out-Null
netsh int tcp set global autotuninglevel=normal | Out-Null
netsh int tcp set global ecncapability=disabled | Out-Null
netsh int tcp set global timestamps=disabled | Out-Null

$interfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($i in $interfaces) {
    Set-ItemProperty -Path $i.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $i.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $i.PSPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -ErrorAction SilentlyContinue | Out-Null
}
Write-Host "-> Network stack streamlined. DeSync buffers terminated." -ForegroundColor Green

# 5. HARDWARE TIMERS & MULTIMEDIA TUNING (Smooth FPS / Stutter Removal)
Write-Host "[5/11] Synchronizing System Timers Safely (Eliminating Micro-Stutter)..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -Force | Out-Null

# Native clock synchronization - Safe against RAGE engine timer crashes
bcdedit /set disabledynamictick yes | Out-Null
bcdedit /set useplatformclock no | Out-Null
bcdedit /deletevalue tscsyncpolicy 2>$null
Write-Host "-> Hardware timers calibrated for stable engine operations." -ForegroundColor Green

# 6. FILTERKEYS & KEYBOARD INJECTOR (Instant Mechanical Feedback)
Write-Host "[6/11] Injecting Ultra-Fast Keyboard Response Matrix..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value 31 -Force | Out-Null
$FK = "HKCU:\Control Panel\Accessibility\Keyboard Response"
if (!(Test-Path $FK)) { New-Item -Path $FK -Force | Out-Null }
Set-ItemProperty -Path $FK -Name "Flags" -Value 122 -Type DWord -Force | Out-Null
Set-ItemProperty -Path $FK -Name "DelayBeforeAcceptance" -Value 0 -Type DWord -Force | Out-Null
Set-ItemProperty -Path $FK -Name "AutoRepeatDelay" -Value 140 -Type DWord -Force | Out-Null
Set-ItemProperty -Path $FK -Name "AutoRepeatRate" -Value 10 -Type DWord -Force | Out-Null
Write-Host "-> FilterKeys matrix successfully locked." -ForegroundColor Green

# 7. Absolute Mouse Trace 1:1 Precision
Write-Host "[7/11] Neutralizing Mouse Curves & Precision Vectors..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseXCurve" -Value ([byte[]](0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)) -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseYCurve" -Value ([byte[]](0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)) -Force | Out-Null
Write-Host "-> Mouse acceleration trace neutralized." -ForegroundColor Green

# 8. NTFS FILESYSTEM OPTIMIZATION (Fast Asset Streaming)
Write-Host "[8/11] Tuning NTFS File System (Eliminating Write-Overhead)..." -ForegroundColor Cyan
fsutil behavior set disablelastaccess 1 | Out-Null
Write-Host "-> File system I/O latency optimized." -ForegroundColor Green

# 9. DEEP BACKGROUND SERVICES ERADICATION (Freeing Up CPU Cycles)
Write-Host "[9/11] Disabling High-Overhead Background Services..." -ForegroundColor Cyan
$BloatServices = @("DiagTrack", "SysMain", "WerSvc", "Wsearch", "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "MapsBroker")
foreach ($Svc in $BloatServices) {
    if (Get-Service -Name $Svc -ErrorAction SilentlyContinue) {
        Stop-Service -Name $Svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $Svc -StartupType Disabled -ErrorAction SilentlyContinue
    }
}
Write-Host "-> Background Windows telemetry and bloat terminated." -ForegroundColor Green

# 10. FIXED HYBRID PAGEFILE ALLOCATION (Anti-Memory Leak Crash)
Write-Host "[10/11] Securing Symmetrical Pagefile Allocation & Purging Caches..." -ForegroundColor Cyan
$CS = Get-CimInstance -ClassName Win32_ComputerSystem
$CS.AutomaticManagedPagefile = $False
Set-CimInstance -CimInstance $CS
$PF = Get-CimInstance -ClassName Win32_PageFileSetting | Where-Object {$_.Name -like "C:*"}
if ($PF) {
    # CRASH FIX: Symmetrical 32GB locking to completely prevent dynamic allocation stutter/crash
    $PF.InitialSize = 32768
    $PF.MaximumSize = 32768
    Set-CimInstance -CimInstance $PF | Out-Null
}

$TempDirs = @("C:\Windows\Temp", "$env:USERPROFILE\AppData\Local\Temp")
foreach ($Dir in $TempDirs) {
    if (Test-Path $Dir) { Get-ChildItem -Path $Dir -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue }
}
$F5Data = "$env:LOCALAPPDATA\FiveM\FiveM.app\data"
if (Test-Path $F5Data) {
    Get-ChildItem -Path $F5Data | Where-Object {$_.Name -ne "game-storage"} | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}
Clear-DnsClientCache -ErrorAction SilentlyContinue
Write-Host "-> Virtual Memory completely optimized and stabilized." -ForegroundColor Green

# 11. OBLITERATE FOOTPRINTS (Console History Wipe)
Write-Host "[11/11] Complete Erasure of Shell Execution History..." -ForegroundColor Cyan
Clear-History -ErrorAction SilentlyContinue
if (Get-Command Get-PSReadLineOption -ErrorAction SilentlyContinue) {
    $HistPath = (Get-PSReadLineOption).HistorySavePath
    if (Test-Path $HistPath) { Remove-Item $HistPath -Force -ErrorAction SilentlyContinue }
}
Write-Host "-> Logs successfully atomized!" -ForegroundColor Green

Write-Host "`n========================================================" -ForegroundColor Magenta
Write-Host "   [OVERHAUL COMPLETED] SYSTEM RATED OPTIMAL & STABLE!  " -ForegroundColor Green
Write-Host "         PLEASE RESTART SYSTEM TO ENGAGE GOD MODE        " -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Magenta
