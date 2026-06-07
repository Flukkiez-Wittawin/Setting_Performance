<#
====================================================================
          FIVEM & WINDOWS MASTER PVP OPTIMIZATION SCRIPT
          VERSION: 2026_ULTIMATE_EDITION (ALL-IN-ONE + CLEAR HISTORY)
====================================================================
#>

# 0. บังคับรันในฐานะ Administrator อัตโนมัติ
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "กำลังขอสิทธิ์ Administrator..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Clear-Host
Write-Host "========================================================" -ForegroundColor Magenta
Write-Host "   เริ่มระบบ MASTER OPTIMIZATION: WINDOWS X FIVEM PVP   " -ForegroundColor Magenta
Write-Host "========================================================" -ForegroundColor Magenta

# 1. ล็อก High Priority สำหรับ FiveM ถาวร
Write-Host "[1/10] ตั้งค่า FiveM เป็น High Priority ถาวร..." -ForegroundColor Cyan
$ifeoPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions"
if (!(Test-Path $ifeoPath)) { New-Item -Path $ifeoPath -Force | Out-Null }
Set-ItemProperty -Path $ifeoPath -Name "CpuPriorityClass" -Value 3 -Type DWord -Force | Out-Null
Write-Host "-> ล็อก High Priority เรียบร้อย! (เข้าเกมจะเป็น High ทันที)" -ForegroundColor Green

# 2. CPU Optimization - เปิดใช้งาน Ultimate Performance Plan
Write-Host "[2/10] ปลดล็อคพลังพลังงาน CPU (Ultimate Performance)..." -ForegroundColor Cyan
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
$ultimatePlan = powercfg -list | Select-String "Ultimate Performance"
if ($ultimatePlan) {
    $planGuid = $ultimatePlan.Line.Split()[3]
    powercfg -setactive $planGuid
    Write-Host "-> เปิดใช้งานแผนพลังงานประสิทธิภาพสูงสุดเรียบร้อย!" -ForegroundColor Green
}

# 3. GPU & System Latency - เปิด HAGS และตั้งค่าความตอบสนองระบบ
Write-Host "[3/10] เปิดใช้งาน HAGS และลดความหน่วงโครงสร้าง Windows..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -Force | Out-Null
Write-Host "-> ปรับแต่งค่าการ์ดจอและลดความหน่วงระบบหลักเรียบร้อย!" -ForegroundColor Green

# 4. Keyboard Response Optimization (สูตรสับ A-D สิง/รำไม้ไว ไม่ติดดีเลย์)
Write-Host "[4/10] ปรับแต่ง Latency คีย์บอร์ด (Keyboard Response Speed)..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value 31 -Force | Out-Null
$FilterKeys = "HKCU:\Control Panel\Accessibility\Keyboard Response"
if (!(Test-Path $FilterKeys)) { New-Item -Path $FilterKeys -Force | Out-Null }
Set-ItemProperty -Path $FilterKeys -Name "Flags" -Value 122 -Type DWord -Force | Out-Null
Set-ItemProperty -Path $FilterKeys -Name "DelayBeforeAcceptance" -Value 0 -Type DWord -Force | Out-Null
Set-ItemProperty -Path $FilterKeys -Name "AutoRepeatDelay" -Value 200 -Type DWord -Force | Out-Null
Set-ItemProperty -Path $FilterKeys -Name "AutoRepeatRate" -Value 15 -Type DWord -Force | Out-Null
Write-Host "-> ปลดล็อกดีเลย์คีย์บอร์ด สับปุ่มตอบสนองแบบ Real-time เรียบร้อย!" -ForegroundColor Green

# 5. Mouse Optimization (ปิดระบบเร่งความเร็วเมาส์ ให้ลากหัว/ตบไม้เมาส์นิ่งแบบ 1:1)
Write-Host "[5/10] ตั้งค่าเมาส์ตรงตามมือ (Disable Mouse Acceleration)..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value 0 -Force | Out-Null
Write-Host "-> ปิดระบบหน่วง/เร่งเมาส์ของ Windows เรียบร้อย!" -ForegroundColor Green

# 6. Network Optimization - ปรับแต่ง TCP (ส่งดาเมจติดเซิร์ฟเวอร์ไวขึ้น ลดปิงย่อย วงนัวไม่กระตุก)
Write-Host "[6/10] ปรับแต่งระเบียบการส่งข้อมูล Network (TCP No Delay / Ack Frequency)..." -ForegroundColor Cyan
$interfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($i in $interfaces) {
    Set-ItemProperty -Path $i.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $i.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -ErrorAction SilentlyContinue | Out-Null
}
Write-Host "-> บังคับส่งข้อมูลแพ็กเก็ตเกมแบบไร้ดีเลย์สะสมเรียบร้อย!" -ForegroundColor Green

# 7. Registry Multimedia Gaming Tasks (จัดลำดับความสำคัญให้กราฟิกเกมเป็นอันดับ 1 คอมไม่แรงตีไหลขึ้น)
Write-Host "[7/10] บังคับสิทธิ์ Multimedia ให้ความสำคัญกับกราฟิกเกมสูงสุด..." -ForegroundColor Cyan
$gpaPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
if (Test-Path $gpaPath) {
    Set-ItemProperty -Path $gpaPath -Name "GPU Priority" -Value 8 -Type DWord -Force | Out-Null
    Set-ItemProperty -Path $gpaPath -Name "Priority" -Value 6 -Type DWord -Force | Out-Null
    Set-ItemProperty -Path $gpaPath -Name "Scheduling Category" -Value "High" -Force | Out-Null
    Set-ItemProperty -Path $gpaPath -Name "SFIO Priority" -Value "High" -Force | Out-Null
}
# ปรับแต่ง Windows Gaming Mode และปิดระบบอัดจอ GameDVR ที่แอบกิน CPU เบื้องหลัง
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1 -Force | Out-Null
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Force | Out-Null
Write-Host "-> ปรับแต่งลำดับความสำคัญของระบบและ Gaming Mode เรียบร้อย!" -ForegroundColor Green

# 8. RAM Optimization - ตั้งค่า Virtual Memory (Pagefile 16GB-32GB ป้องกันเกมเด้ง/แมพทะลุ)
Write-Host "[8/10] จัดการหน่วยความจำสำรอง (Virtual Memory) บนไดรฟ์ C:..." -ForegroundColor Cyan
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
Write-Host "-> ตั้งค่า Virtual Memory ป้องกัน RAM เต็มเรียบร้อย!" -ForegroundColor Green

# 9. Clean Windows Temp & FiveM Cache
Write-Host "[9/10] ทำความสะอาดไฟล์ขยะระบบและล้าง Cache FiveM..." -ForegroundColor Cyan
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
    Write-Host "-> ล้าง Cache ขยะ FiveM สำเร็จ! (เว้นไฟล์หลักปลอดภัย 100%)" -ForegroundColor Green
} else {
    Write-Host "-> ไม่พบโฟลเดอร์ FiveM ในตำแหน่งเริ่มต้น (ข้ามการล้าง Cache เกม)" -ForegroundColor Yellow
}

# 10. Clear Console History (ลบประวัติการพิมพ์คำสั่งล่างสุดตามคำขอ)
Write-Host "[10/10] กำลังลบประวัติการพิมพ์คำสั่งใน Console (Clear PSReadLine History)..." -ForegroundColor Cyan
Clear-History -ErrorAction SilentlyContinue
if (Get-Command Get-PSReadLineOption -ErrorAction SilentlyContinue) {
    $historyPath = (Get-PSReadLineOption).HistorySavePath
    if (Test-Path $historyPath) {
        Remove-Item $historyPath -Force -ErrorAction SilentlyContinue
    }
}
Write-Host "-> ลบประวัติ Console History ทั้งหมดเรียบร้อย!" -ForegroundColor Green

Write-Host "`n========================================================" -ForegroundColor Magenta
Write-Host "   [SUCCESS] รวมสูตรความแรงระดับจัดเต็ม All-In-One เรียบร้อย!" -ForegroundColor Green
Write-Host "          กรุณาทำการ Restart คอมพิวเตอร์ 1 ครั้ง          " -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Magenta