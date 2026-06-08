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

Write-Host "========================================================" -ForegroundColor Green
Write-Host "  [สำเร็จ] ปรับแต่งเวอร์ชันปลอดภัยเรียบร้อย! เล่นเกมลื่นขึ้นแน่นอน" -ForegroundColor White
Write-Host "  >> แนะนำให้ RESTART คอมพิวเตอร์ 1 ครั้ง เพื่อเริ่มใช้งาน <<" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Green
