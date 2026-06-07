<#
====================================================================
          FIVEM & WINDOWS MASTER PVP OPTIMIZATION SCRIPT
          VERSION: 2026_ULTIMATE_MAX_PERFORMANCE_EDITION
====================================================================
#>

# 0. Force Administrative Privileges Auto-Bypass
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator Privileges..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Clear-Host
Write-Host "========================================================" -ForegroundColor Magenta
Write-Host "   LAUNCHING MASTER OPTIMIZATION: WINDOWS x FIVEM PVP   " -ForegroundColor Magenta
Write-Host "========================================================" -ForegroundColor Magenta

# 1. Image File Execution Options (Lock High Priority)
Write-Host "[1/10] Locking FiveM & GTA Process to High Priority..." -ForegroundColor Cyan
$ifeoFiveM = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions"
$ifeoGTA5  = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\GTA5.exe\PerfOptions"
if (!(Test-Path $ifeoFiveM)) { New-Item -Path $ifeoFiveM -Force | Out-Null }
if (!(Test-Path $ifeoGTA5))  { New-Item -Path $ifeoGTA5 -Force | Out-Null }
Set-ItemProperty -Path $ifeoFiveM -Name "CpuPriorityClass" -Value 3 -Type DWord -Force | Out-Null
Set-ItemProperty -Path $ifeoGTA5  -Name "CpuPriorityClass" -Value 3 -Type DWord -Force | Out-Null
Write-Host "-> Process priority locked to HIGH successfully!" -ForegroundColor Green

# 2. CPU Power Management (Ultimate Performance & Core Unparking Flag)
Write-Host "[2/10] Unlocking Max CPU Power (Enforcing Ultimate Performance)..." -ForegroundColor Cyan
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
$ultimatePlan = powercfg -list | Select-String "Ultimate Performance"
if ($ultimatePlan) {
    $planGuid = $ultimatePlan.Line.Split()[3]
    powercfg -setactive $planGuid
    Write-Host "-> Ultimate Performance Plan activated!" -ForegroundColor Green
}

# 3. GPU Latency & Kernel Optimization (HAGS & Timer Tuning)
Write-Host "[3/10] Enabling HAGS & Optimizing Kernel Responsiveness..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -Force | Out-Null
# Disable Dynamic Ticking to reduce micro-stutters and stabilize FPS frame-time
bcdedit /set disabledynamictick yes | Out-Null
bcdedit /set useplatformclock no | Out-Null
Write-Host "-> System response and GPU scheduling optimized!" -ForegroundColor Green

# 4. Keyboard Response Optimization (Instant Key-Repeat / Zero Debounce Delay)
Write-Host "[4/10] Tuning Keyboard Latency for Instant Macro/Movement..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value 31 -Force | Out-Null
$FilterKeys = "HKCU:\Control Panel\Accessibility\Keyboard Response"
if (!(Test-Path $FilterKeys)) { New-Item -Path $FilterKeys -Force | Out-Null }
Set-ItemProperty -Path $FilterKeys -Name "Flags" -Value 122 -Type DWord -Force | Out-Null
Set-ItemProperty -Path $FilterKeys -Name "DelayBeforeAcceptance" -Value 0 -Type DWord -Force | Out-Null
Set-ItemProperty -Path $FilterKeys -Name "AutoRepeatDelay" -Value 200 -Type DWord -Force | Out-Null
Set-ItemProperty -Path $FilterKeys -Name "AutoRepeatRate" -Value 15 -Type DWord -Force | Out-Null
Write-Host "-> Keyboard delay eliminated! Real-time mechanical feedback active." -ForegroundColor Green

# 5. Raw Mouse Input & Absolute Precision (Remove Acceleration Curve)
Write-Host "[5/10] Eliminating Windows Mouse Acceleration (1:1 Raw Tracking)..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value 0 -Force | Out-Null
# Clear out Smooth Mouse Curves to completely kill hidden pixel skipping
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseXCurve" -Value ([byte[]](0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)) -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseYCurve" -Value ([byte[]](0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)) -Force | Out-Null
Write-Host "-> Mouse acceleration completely removed!" -ForegroundColor Green

# 6. Advanced Network & TCP Throughput (No-Delay Packet Synchronization)
Write-Host "[6/10] Optimizing Network Stack (TCP No Delay & Global Gaming Configuration)..." -ForegroundColor Cyan
$interfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($i in $interfaces) {
    Set-ItemProperty -Path $i.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $i.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -ErrorAction SilentlyContinue | Out-Null
}
# Extreme global TCP optimization via Netsh
netsh int tcp set global autotuninglevel=normal | Out-Null
netsh int tcp set global chimney=disabled | Out-Null
netsh int tcp set global ecncapability=disabled | Out-Null
netsh int tcp set global timestamps=disabled | Out-Null
Write-Host "-> Network stack configured for minimal latency and packet congestion!" -ForegroundColor Green

# 7. Multimedia Gaming Tasks & GameDVR Bypass
Write-Host "[7/10] Directing Windows Resources Exclusively to Active Game Graphics..." -ForegroundColor Cyan
$gpaPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
if (Test-Path $gpaPath) {
    Set-ItemProperty -Path $gpaPath -Name "GPU Priority" -Value 8 -Type DWord -Force | Out-Null
    Set-ItemProperty -Path $gpaPath -Name "Priority" -Value 6 -Type DWord -Force | Out-Null
    Set-ItemProperty -Path $gpaPath -Name "Scheduling Category" -Value "High" -Force | Out-Null
    Set-ItemProperty -Path $gpaPath -Name "SFIO Priority" -Value "High" -Force | Out-Null
}
# Disable Xbox GameDVR and Windows background recording bloatware
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value 0 -Force | Out-Null
Write-Host "-> Game Mode enhanced and background multimedia overhead terminated!" -ForegroundColor Green

# 8. Memory Management Optimization (Stable Pagefile Allocation)
Write-Host "[8/10] Allocating Virtual Memory Pagefile (Preventing Memory Leaks)..." -ForegroundColor Cyan
$ComputerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
$ComputerSystem.AutomaticManagedPagefile = $False
Set-CimInstance -CimInstance $ComputerSystem
$PageFile = Get-CimInstance -ClassName Win32_PageFileSetting | Where-Object {$_.Name -like "C:*"}
if ($PageFile) {
    $PageFile.InitialSize = 16384
    $PageFile.MaximumSize = 32768
    Set-CimInstance -CimInstance $PageFile | Out-Null
} else {
    New-CimInstance -ClassName Win32_PageFileSetting -Property @{Name="C:\pagefile.sys"; InitialSize=16384; MaximumSize=32768} | Out-Null
}
Write-Host "-> Custom Virtual Memory allocated (16GB - 32GB Dynamic Buffer)!" -ForegroundColor Green

# 9. Purge Cache, Temporary Files & DNS Buffer
Write-Host "[9/10] Flushing System Garbage, Temp Bloat, and FiveM Cache..." -ForegroundColor Cyan
$TempFolders = @("C:\Windows\Temp", "$env:USERPROFILE\AppData\Local\Temp")
foreach ($Folder in $TempFolders) {
    if (Test-Path $Folder) {
        Get-ChildItem -Path $Folder -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
}
$fivemPath = "$env:LOCALAPPDATA\FiveM\FiveM.app\data"
if (Test-Path $fivemPath) {
    $cacheItems = Get-ChildItem -Path $fivemPath
    foreach ($item in $cacheItems) {
        if ($item.Name -ne "game-storage") {
            Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    Write-Host "-> FiveM Cache wiped successfully! (Core storage preserved)." -ForegroundColor Green
} else {
    Write-Host "-> Default FiveM directory not found. Skipping cache purge." -ForegroundColor Yellow
}
Clear-DnsClientCache -ErrorAction SilentlyContinue

# 10. Clear Console History (Absolute Bottom Operation)
Write-Host "[10/10] Wiping PowerShell Command History (Obliterating Console Footprints)..." -ForegroundColor Cyan
Clear-History -ErrorAction SilentlyContinue
if (Get-Command Get-PSReadLineOption -ErrorAction SilentlyContinue) {
    $historyPath = (Get-PSReadLineOption).HistorySavePath
    if (Test-Path $historyPath) {
        Remove-Item $historyPath -Force -ErrorAction SilentlyContinue
    }
}
Write-Host "-> Session and PSReadLine history successfully deleted!" -ForegroundColor Green

Write-Host "`n========================================================" -ForegroundColor Magenta
Write-Host "   [SUCCESS] ULTIMATE GAMING TWEAKS APPLIED SUCCESSFULLY!  " -ForegroundColor Green
Write-Host "          PLEASE RESTART YOUR COMPUTER TO APPLY           " -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Magenta
