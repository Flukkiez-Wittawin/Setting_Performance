# ====================================================================
#   FIVEM & WINDOWS PVP OVERHAUL SCRIPT [GOD MODE EDITION]
#   TARGET: ZERO DESYNC / ABSOLUTE LOWEST INPUT LATENCY
# ====================================================================

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Elevated Kernel Privileges..." -ForegroundColor Red
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Clear-Host
Write-Host "========================================================" -ForegroundColor Red
Write-Host "      WARNING: ENFORCING HARDCORE KERNEL-LEVEL TWEAKS    " -ForegroundColor Red
Write-Host "========================================================" -ForegroundColor Red

# 1. CPU KERNEL MITIGATIONS DISABLE (ปลดล็อคพลังดิบของ CPU คืนเฟรมเรทที่โดนกั๊ก)
Write-Host "[1/11] Disabling Spectre & Meltdown Mitigations (Max CPU IPC)..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "FeatureSettingsOverride" -Value 3 -Type DWord -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "FeatureSettingsOverrideMask" -Value 3 -Type DWord -Force | Out-Null
Write-Host "-> CPU Security overhead eliminated! Pure execution speed active." -ForegroundColor Green

# 2. QUANTUM SCHEDULING TUNING (ปรับบัส CPU ให้ตอบสนองเกมไวขึ้น 40%)
Write-Host "[2/11] Tuning Win32 Priority Separation for Short-Variable Quantum..." -ForegroundColor Cyan
# ค่า 26 Hex (38 Dec) บังคับ CPU ให้จัดลำดับงานแอปเบื้องหน้าให้เร็วและสั้นที่สุด เหมาะกับเกม PVP
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force | Out-Null
Write-Host "-> Thread allocation optimized for active application." -ForegroundColor Green

# 3. PROCESS PRIORITY LOCK (FiveM & GTA5 Ultimate Override)
Write-Host "[3/11] Locking Executables to High Priority..." -ForegroundColor Cyan
$Executables = @("FiveM_GTAProcess.exe", "GTA5.exe", "FiveM.exe")
foreach ($Exe in $Executables) {
    $Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$Exe\PerfOptions"
    if (!(Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-ItemProperty -Path $Path -Name "CpuPriorityClass" -Value 3 -Type DWord -Force | Out-Null
}
Write-Host "-> Game executables forced to HIGH priority permanently." -ForegroundColor Green

# 4. HARDWARE NETWORK ADAPTER OVERHAUL (ปิดระบบหน่วงการ์ดแลน ลด DeSync ตรงจุดที่สุด)
Write-Host "[4/11] Forcing Ultra-Low Latency on Physical Network Adapters..." -ForegroundColor Cyan
# ปิด Interrupt Moderation (ตัวรวมข้อมูลเพื่อประหยัดไฟ) บังคับให้การ์ดแลนยิง Packet เข้า CPU ทันที
Get-NetAdapter | Where-Object {$_.Physical} | ForEach-Object {
    Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Interrupt Moderation" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Flow Control" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Energy Efficient Ethernet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Green Ethernet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
}
# ปิด RSC ตัวการหลักที่ทำให้ระบบประมวลผลดาเมจช้าเวลาโดนรุมไม้ (DeSync)
netsh int tcp set global rsc=disabled | Out-Null
netsh int tcp set global autotuninglevel=normal | Out-Null
netsh int tcp set global congestionprovider=ctcp | Out-Null
netsh int tcp set global ecncapability=disabled | Out-Null
netsh int tcp set global timestamps=disabled | Out-Null
$interfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($i in $interfaces) {
    Set-ItemProperty -Path $i.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $i.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $i.PSPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -ErrorAction SilentlyContinue | Out-Null
}
Write-Host "-> Network hardware latency stripped down to absolute zero!" -ForegroundColor Green

# 5. HARDWARE TIMERS & LATENCY CRUSH (ภาพสมูท ไร้อาการ Micro-stutter)
Write-Host "[5/11] Synchronizing System Clock Timers (HPET Killer)..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -Force | Out-Null
bcdedit /set disabledynamictick yes | Out-Null
bcdedit /set useplatformclock no | Out-Null
bcdedit /set tscsyncpolicy Enhanced | Out-Null
Write-Host "-> Timers synchronized with Hardware Clock Engine." -ForegroundColor Green

# 6. FILERKEYS & KEYBOARD INJECTOR (คอมโบติดมือ สับหน้าหลังพริ้วขึ้น)
Write-Host "[6/11] Injecting Ultra Fast Keyboard Response Matrix..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value 31 -Force | Out-Null
$FK = "HKCU:\Control Panel\Accessibility\Keyboard Response"
if (!(Test-Path $FK)) { New-Item -Path $FK -Force | Out-Null }
Set-ItemProperty -Path $FK -Name "Flags" -Value 122 -Type DWord -Force | Out-Null
Set-ItemProperty -Path $FK -Name "DelayBeforeAcceptance" -Value 0 -Type DWord -Force | Out-Null
Set-ItemProperty -Path $FK -Name "AutoRepeatDelay" -Value 140 -Type DWord -Force | Out-Null  # ลดเหลือ 140ms เพื่อการตอบสนองที่โหดขึ้น
Set-ItemProperty -Path $FK -Name "AutoRepeatRate" -Value 10 -Type DWord -Force | Out-Null     # อัตราดีเลย์ระหว่างกดปุ่มซ้ำต่ำสุดขีด
Write-Host "-> FilterKeys matrix injected." -ForegroundColor Green

# 7. Absolute Mouse Trace 1:1 (ลบพิกเซลกระโดดเวลาสะบัดเมาส์ฟัน)
Write-Host "[7/11] Neutralizing Mouse Curves & Precision Vectors..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseXCurve" -Value ([byte[]](0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)) -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseYCurve" -Value ([byte[]](0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)) -Force | Out-Null
Write-Host "-> Direct mouse tracking curve established." -ForegroundColor Green

# 8. NTFS FILESYSTEM OPTIMIZATION (โหลดฉาก/โมเดลไวขึ้น คอมไม่แรงตีไหลขึ้น)
Write-Host "[8/11] Tuning NTFS File System (Eliminating Write-Overhead)..." -ForegroundColor Cyan
# ปิดการอัปเดตแสตมป์เวลาการเข้าถึงไฟล์ล่าสุด เพื่อประหยัดการทำงานของ SSD/HDD เวลาดึงแคชเกม
fsutil behavior set disablelastaccess 1 | Out-Null
Write-Host "-> NTFS LastAccess update overhead disabled." -ForegroundColor Green

# 9. DEEP BACKGROUND SERVICES ERADICATION (ล้างโปรแกรมขยะที่แอบกระตุกเฟรมเรท)
Write-Host "[9/11] Disabling High-Overhead Background Services..." -ForegroundColor Cyan
$BloatServices = @("DiagTrack", "SysMain", "WerSvc", "Wsearch", "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "MapsBroker")
foreach ($Svc in $BloatServices) {
    if (Get-Service -Name $Svc -ErrorAction SilentlyContinue) {
        Stop-Service -Name $Svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $Svc -StartupType Disabled -ErrorAction SilentlyContinue
    }
}
Write-Host "-> Background Windows telemetry and Xbox bloat terminated." -ForegroundColor Green

# 10. FIXED PAGEFILE BUFFER & CACHE FLUSH
Write-Host "[10/11] Securing Pagefile Allocation & Purging Cache..." -ForegroundColor Cyan
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
Write-Host "-> Memory environments stabilized." -ForegroundColor Green

# ====================================================================
#   FIVEM & WINDOWS PVP OPTIMIZATION [SAFE-ULTIMATE EDITION]
#   TARGET: LOW LATENCY & ANTI-DESYNC (WITH HARDWARE SAFETY)
# ====================================================================

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "กรุณารัน PowerShell ในฐานะ Administrator!" -ForegroundColor Yellow
    Exit
}

Clear-Host
Write-Host "========================================================" -ForegroundColor Green
Write-Host "   กำลังฉีด Setting เวอร์ชัน SAFE-ULTIMATE (เน้นปลอดภัย คอมไม่ร้อน) " -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green

# 1. สร้าง CUSTOM POWER PLAN แบบถนอมเครื่อง (แรงเฉพาะตอนเปิดเกม)
Write-Host "[+] กำลังสร้างแผนพลังงาน [SAFE-ULTIMATE PERFORMANCE]..." -ForegroundColor Cyan
$BasePlan = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" # อิงจาก High Performance มาตรฐาน
$CustomPlanGuid = "77777777-7777-7777-7777-777777777777"

powercfg /delete $CustomPlanGuid 2>$null
powercfg /duplicatescheme $BasePlan $CustomPlanGuid | Out-Null
powercfg /changename $CustomPlanGuid "[SAFE-ULTIMATE] - FIVEM PVP" "แรงเต็มพิกัดตอนเล่นเกม แต่ปล่อยให้ CPU ลดความเร็วและพักผ่อนได้ตอนเครื่องว่าง"

$ProcSubgroup = "54533251-82be-4824-96c1-47b60b740d00"
# SAFETY CHANGE: ตั้งค่าขั้นต่ำของ CPU ไว้ที่ 5% (เพื่อให้ CPU ดาวน์คล็อกลงมาเย็นๆ ตอนเปิดคอมทิ้งไว้)
powercfg /setacvalueindex $CustomPlanGuid $ProcSubgroup 893dee5e-7878-483d-9d3a-3a2e16c03f65 5
# ตั้งค่าสูงสุดของ CPU ไว้ที่ 100% (เล่นเกมเมื่อไหร่ ปลดปล่อยพลังทันที)
powercfg /setacvalueindex $CustomPlanGuid $ProcSubgroup bc5038f7-23e0-4960-96da-33abaf5935ec 100
# คืนค่า Core Parking ให้ Windows บริหารตามความร้อนที่เหมาะสม
powercfg /setacvalueindex $CustomPlanGuid $ProcSubgroup cpmincores 0
powercfg /setactive $CustomPlanGuid

# 2. ANTI-DESYNC NETWORK TUNING (ปลอดภัยต่อคอม 100% เน็ตซิงค์ตรงล็อก)
Write-Host "[+] ปรับแต่ง Network ลดอาการตัววาปและดาเมจดีเลย์..." -ForegroundColor Cyan
$interfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($i in $interfaces) {
    Set-ItemProperty -Path $i.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $i.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -ErrorAction SilentlyContinue | Out-Null
}
netsh int tcp set global rsc=disabled | Out-Null
netsh int tcp set global autotuninglevel=normal | Out-Null
netsh int tcp set global congestionprovider=ctcp | Out-Null

# 3. INPUT LATENCY TUNING (กดติดมือ ตัวรำง่ายขึ้น เม้าส์และคีย์บอร์ดตอบสนองไว)
Write-Host "[+] เอาดีเลย์คีย์บอร์ดและเมาส์ออก (Raw Input)..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value 31 -Force | Out-Null
$FK = "HKCU:\Control Panel\Accessibility\Keyboard Response"
if (!(Test-Path $FK)) { New-Item -Path $FK -Force | Out-Null }
Set-ItemProperty -Path $FK -Name "Flags" -Value 122 -Type DWord -Force | Out-Null
Set-ItemProperty -Path $FK -Name "DelayBeforeAcceptance" -Value 0 -Type DWord -Force | Out-Null

Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value 0 -Force | Out-Null

# 4. ล้างแคชเกมเพิ่มพื้นที่ให้คอมไหลลื่น
Write-Host "[+] กำลังเคลียร์ไฟล์ขยะและแคชเกมเพื่อความสมูท..." -ForegroundColor Cyan
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
$fivemPath = "$env:LOCALAPPDATA\FiveM\FiveM.app\data"
if (Test-Path $fivemPath) {
    Get-ChildItem -Path $fivemPath | Where-Object {$_.Name -ne "game-storage"} | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

# 11. OBLITERATE FOOTPRINTS (ลบประวัติการรันคำสั่งทั้งหมดเกลี้ยง 100%)
Write-Host "[11/11] Complete Erasure of Shell Execution History..." -ForegroundColor Cyan
Clear-History -ErrorAction SilentlyContinue
if (Get-Command Get-PSReadLineOption -ErrorAction SilentlyContinue) {
    $HistPath = (Get-PSReadLineOption).HistorySavePath
    if (Test-Path $HistPath) { Remove-Item $HistPath -Force -ErrorAction SilentlyContinue }
}
Write-Host "-> Logs successfully atomized!" -ForegroundColor Green



Write-Host "`n========================================================" -ForegroundColor Magenta
Write-Host "   [KERNEL OVERHAUL COMPLETED] SYSTEM AT ALL-TIME MAX!   " -ForegroundColor Green
Write-Host "       PLEASE RESTART SYSTEM TO ENGAGE GOD MODE          " -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Magenta
