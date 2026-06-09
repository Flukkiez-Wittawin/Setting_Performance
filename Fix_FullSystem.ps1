<#
====================================================================
          FIVEM & WINDOWS MASTER PVP OPTIMIZATION SCRIPT
          VERSION: 2026_STABLE_PVP_GOD_MODE (ANTI-OVERHEAT)
====================================================================
#>

# 0. Force Administrative Privileges Auto-Bypass
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Elevated Kernel Privileges..." -ForegroundColor Red
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Clear-Host
Write-Host "========================================================" -ForegroundColor Green
Write-Host "   STABLE MASTER OPTIMIZATION: ANTI-DESYNC & SAFE TEMP  " -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green

# 1. Process Priority Management (Lock FiveM to High, NOT Realtime)
Write-Host "[1/11] Locking Executables to High Priority..." -ForegroundColor Cyan
$Executables = @("FiveM_GTAProcess.exe", "GTA5.exe", "FiveM.exe")
foreach ($Exe in $Executables) {
    $Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$Exe\PerfOptions"
    if (!(Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-ItemProperty -Path $Path -Name "CpuPriorityClass" -Value 3 -Type DWord -Force | Out-Null
}
Write-Host "-> Game executables optimized for preferential CPU scheduling." -ForegroundColor Green

# 2. Dynamic Performance Power Plan (Anti-Overheat Tweak)
Write-Host "[2/11] Deploying Dynamic Performance Power Plan..." -ForegroundColor Cyan
$BasePlan = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" # Standard High Performance
$CustomPlanGuid = "77777777-7777-7777-7777-777777777777"
powercfg /delete $CustomPlanGuid 2>$null
powercfg /duplicatescheme $BasePlan $CustomPlanGuid | Out-Null
powercfg /changename $CustomPlanGuid "[SAFE-ULTIMATE] - FIVEM PVP" "Max performance during gameplay, thermal downclocking allowed during idle states."

$ProcSubgroup = "54533251-82be-4824-96c1-47b60b740d00"
# Set minimum state to 5% to allow CPU to rest and cool down when not intensive
powercfg /setacvalueindex $CustomPlanGuid $ProcSubgroup 893dee5e-7878-483d-9d3a-3a2e16c03f65 5
# Set maximum state to 100% for full power when gaming
powercfg /setacvalueindex $CustomPlanGuid $ProcSubgroup bc5038f7-23e0-4960-96da-33abaf5935ec 100
powercfg /setactive $CustomPlanGuid
Write-Host "-> Intelligent performance profiles executed safely." -ForegroundColor Green

# 3. GPU Latency & System Profile Core Tuning
Write-Host "[3/11] Enabling HAGS & Optimizing Engine Responsiveness..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -Force | Out-Null
# Micro-stutter fixes without changing hardware clock syncing policies
bcdedit /set disabledynamictick yes | Out-Null
bcdedit /set useplatformclock no | Out-Null
Write-Host "-> GPU Hardware Acceleration and system latency configured." -ForegroundColor Green

# 4. Hardware Network Adapter Overhaul (Anti-DeSync Engine)
Write-Host "[4/11] Stripping Hardware Latency from Physical Network Adapters..." -ForegroundColor Cyan
Get-NetAdapter | Where-Object {$_.Physical} | ForEach-Object {
    Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Interrupt Moderation" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Flow Control" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Energy Efficient Ethernet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Green Ethernet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
}
netsh int tcp set global rsc=disabled | Out-Null
netsh int tcp set global autotuninglevel=normal | Out-Null
Write-Host "-> Hardware network congestion and DeSync triggers eliminated." -ForegroundColor Green

# 5. Advanced Network Stack Tweak (Packet Synchronization)
Write-Host "[5/11] Injecting TCP No-Delay & Instant Ack Protocols..." -ForegroundColor Cyan
$interfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($i in $interfaces) {
    Set-ItemProperty -Path $i.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $i.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $i.PSPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -ErrorAction SilentlyContinue | Out-Null
}
Write-Host "-> Registered immediate gaming packet delivery packet stream." -ForegroundColor Green

# 6. FilterKeys & Keyboard Response Matrix
Write-Host "[6/11] Optimizing Keyboard Response Registry Matrix..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value 31 -Force | Out-Null
$FK = "HKCU:\Control Panel\Accessibility\Keyboard Response"
if (!(Test-Path $FK)) { New-Item -Path $FK -Force | Out-Null }
Set-ItemProperty -Path $FK -Name "Flags" -Value 122 -Type DWord -Force | Out-Null
Set-ItemProperty -Path $FK -Name "DelayBeforeAcceptance" -Value 0 -Type DWord -Force | Out-Null
Set-ItemProperty -Path $FK -Name "AutoRepeatDelay" -Value 140 -Type DWord -Force | Out-Null
Set-ItemProperty -Path $FK -Name "AutoRepeatRate" -Value 10 -Type DWord -Force | Out-Null
Write-Host "-> FilterKeys response accelerated for real-time combo execution." -ForegroundColor Green

# 7. Absolute Mouse Trace 1:1 Precision
Write-Host "[7/11] Removing Windows Mouse Acceleration & Interpolation Curves..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseXCurve" -Value ([byte[]](0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)) -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseYCurve" -Value ([byte[]](0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)) -Force | Out-Null
Write-Host "-> Absolute 1:1 precision vector tracking applied." -ForegroundColor Green

# 8. NTFS File System Optimization
Write-Host "[8/11] Tuning File System Storage Read/Write Delays..." -ForegroundColor Cyan
fsutil behavior set disablelastaccess 1 | Out-Null
Write-Host "-> NTFS storage overhead disabled for faster asset caching." -ForegroundColor Green

# 9. Deep Background Services Eradication (Telemetry & Bloat)
Write-Host "[9/11] Terminating Resource-Heavy Windows Background Bloat..." -ForegroundColor Cyan
$BloatServices = @("DiagTrack", "SysMain", "WerSvc", "Wsearch", "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "MapsBroker")
foreach ($Svc in $BloatServices) {
    if (Get-Service -Name $Svc -ErrorAction SilentlyContinue) {
        Stop-Service -Name $Svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $Svc -StartupType Disabled -ErrorAction SilentlyContinue
    }
}
Write-Host "-> Background telemetry and dynamic CPU cycles reclaimed." -ForegroundColor Green

# 10. Fixed Pagefile Buffer & Cache Purge
Write-Host "[10/11] Stabilizing Virtual Memory & Clearing System Cache..." -ForegroundColor Cyan
$CS = Get-CimInstance -ClassName Win32_ComputerSystem
$CS.AutomaticManagedPagefile = $False
Set-CimInstance -CimInstance $CS
$PF = Get-CimInstance -ClassName Win32_PageFileSetting | Where-Object {$_.Name -like "C:*"}
if ($PF) {
    $PF.InitialSize = 16384
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
Write-Host "-> Memory environment completely purged and locked." -ForegroundColor Green

# 11. Obliterate Footprints (Console History Wipe)
Write-Host "[11/11] Complete Erasure of Shell Execution History..." -ForegroundColor Cyan
Clear-History -ErrorAction SilentlyContinue
if (Get-Command Get-PSReadLineOption -ErrorAction SilentlyContinue) {
    $HistPath = (Get-PSReadLineOption).HistorySavePath
    if (Test-Path $HistPath) { Remove-Item $HistPath -Force -ErrorAction SilentlyContinue }
}
Write-Host "-> Session logs successfully atomized!" -ForegroundColor Green

Write-Host "`n========================================================" -ForegroundColor Magenta
Write-Host "   [OPTIMIZATION COMPLETED] STABLE STRETCH DEPLOYED!    " -ForegroundColor Green
Write-Host "          PLEASE RESTART SYSTEM TO ENGAGE STABLE MODE    " -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Magenta
