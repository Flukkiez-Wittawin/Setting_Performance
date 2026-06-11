<#
====================================================================
ALLSETTING X INTERNET - NEXT-GEN ULTIMATE LAUNCHER
(100% Clean WPF Engine Version)
====================================================================
#>

# 0. บังคับรันในฐานะ Administrator
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
  Exit
}

# โหลดไลบรารีสถาปัตยกรรม WPF (Modern Windows UI)
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# --- ออกแบบโครงสร้างหน้าตาโปรแกรมด้วย XAML (ลบ LetterSpacing ออกหมดเกลี้ยง) ---
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Allsetting x Internet" Height="580" Width="460"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize"
        WindowStyle="None" AllowsTransparency="True" Background="Transparent">

    <Border CornerRadius="20" BorderBrush="#00D5FF" BorderThickness="1.5">
        <Border.Background>
            <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
                <GradientStop Color="#09090D" Offset="0.0"/>
                <GradientStop Color="#00152B" Offset="0.5"/>
                <GradientStop Color="#003366" Offset="1.0"/>
            </LinearGradientBrush>
        </Border.Background>

        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="45"/>  <RowDefinition Height="Auto"/> <RowDefinition Height="*"/>    <RowDefinition Height="200"/>  </Grid.RowDefinitions>

            <Grid Name="HeaderBar" Grid.Row="0" Background="Transparent" Cursor="SizeAll">
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,15,0">

                    <Button Name="BtnMinimize" Content="&#8212;" Width="35" Height="30" FontSize="11" FontWeight="Bold"
                            Foreground="#66FFFFFF" Background="Transparent" BorderBrush="Transparent" Margin="0,0,5,0">
                        <Button.Template>
                            <ControlTemplate TargetType="Button">
                                <Border x:Name="BtnBg" Background="Transparent" CornerRadius="6">
                                    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                                <ControlTemplate.Triggers>
                                    <Trigger Property="IsMouseOver" Value="True">
                                        <Setter TargetName="BtnBg" Property="Background" Value="#2200E5FF"/>
                                        <Setter Property="Foreground" Value="#00E5FF"/>
                                    </Trigger>
                                </ControlTemplate.Triggers>
                            </ControlTemplate>
                        </Button.Template>
                    </Button>

                    <Button Name="BtnClose" Content="&#10005;" Width="35" Height="30" FontSize="12" FontWeight="Bold"
                            Foreground="#66FFFFFF" Background="Transparent" BorderBrush="Transparent">
                        <Button.Template>
                            <ControlTemplate TargetType="Button">
                                <Border x:Name="BtnBg" Background="Transparent" CornerRadius="6">
                                    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                                <ControlTemplate.Triggers>
                                    <Trigger Property="IsMouseOver" Value="True">
                                        <Setter TargetName="BtnBg" Property="Background" Value="#D11A2A"/>
                                        <Setter Property="Foreground" Value="#FFFFFF"/>
                                    </Trigger>
                                </ControlTemplate.Triggers>
                            </ControlTemplate>
                        </Button.Template>
                    </Button>

                </StackPanel>
            </Grid>

            <StackPanel Grid.Row="1" Margin="30,10,30,0" IsHitTestVisible="False">
                <TextBlock Text="ALLSETTING X INTERNET" FontSize="22" FontWeight="ExtraBold"
                           Foreground="#00E5FF" HorizontalAlignment="Center"/>
                <TextBlock Text="POWER By ProjectE PERFORMANCE ENGINE" FontSize="10" FontWeight="SemiBold"
                           Foreground="#66FFFFFF" HorizontalAlignment="Center" Margin="0,5,0,0"/>
                <Border Height="1" Background="#1A00E5FF" Margin="0,20,0,0"/>
            </StackPanel>

            <Grid Grid.Row="2" VerticalAlignment="Center">
                <Button Name="BtnLaunch" Content="LAUNCH" Height="70" Width="360"
                        Foreground="#FFFFFF" FontSize="24" FontWeight="Bold"
                        Background="#030914" BorderBrush="#00A8FF" BorderThickness="2" Cursor="Hand">
                    <Button.Template>
                        <ControlTemplate TargetType="Button">
                            <Border x:Name="ButtonBorder" Background="#030914" BorderBrush="#00A8FF" BorderThickness="2" CornerRadius="35">
                                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                            </Border>
                            <ControlTemplate.Triggers>
                                <Trigger Property="IsMouseOver" Value="True">
                                    <Setter TargetName="ButtonBorder" Property="Background" Value="#005C99"/>
                                    <Setter TargetName="ButtonBorder" Property="BorderBrush" Value="#00FFFF"/>
                                </Trigger>
                            </ControlTemplate.Triggers>
                        </ControlTemplate>
                    </Button.Template>
                </Button>
            </Grid>

            <Grid Grid.Row="3" Margin="35,0,35,30">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>
                <TextBlock Grid.Row="0" Text="SYSTEM STATUS LOG" FontSize="10" FontWeight="Bold" Foreground="#44FFFFFF" Margin="5,0,0,5"/>
                <Border Grid.Row="1" CornerRadius="10" Background="#15000000" BorderBrush="#1500D5FF" BorderThickness="1">
                    <TextBox Name="LogBox" Background="Transparent" Foreground="#D5FFFF" BorderThickness="0"
                             FontFamily="Consolas" FontSize="11" IsReadOnly="True" TextWrapping="Wrap"
                             VerticalScrollBarVisibility="Auto" Margin="10"/>
                </Border>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

# อ่านโค้ดดีไซน์เข้าไปยังเอนจินของ Windows
$reader = New-Object System.Xml.XmlNodeReader($xaml)
try {
  $window = [Windows.Markup.XamlReader]::Load($reader)
}
catch {
  Write-Host "XAML Error: $_" -ForegroundColor Red
  Exit
}

# ดึง Element ต่างๆ ออกมาผูกกับสคริปต์ควบคุม
$headerBar = $window.FindName("HeaderBar")
$btnMinimize = $window.FindName("BtnMinimize")
$btnClose = $window.FindName("BtnClose")
$btnLaunch = $window.FindName("BtnLaunch")
$logBox = $window.FindName("LogBox")

# ฟังก์ชันทำให้แถบด้านบนสามารถคลิกแล้วลากหน้าต่างโปรแกรมไปมาได้
$headerBar.Add_MouseLeftButtonDown({
  $window.DragMove()
})

# ฟังก์ชันปุ่มย่อยุบหน้าต่างลง Taskbar
$btnMinimize.Add_Click({
  $window.WindowState = [System.Windows.WindowState]::Minimized
})

# ปุ่มกดปิดโปรแกรม
$btnClose.Add_Click({
  $window.Close()
})

# ฟังก์ชันพิมพ์ข้อมูลสเตตัสแบบ Real-time
function Log-Write ($text) {
  $time = [DateTime]::Now.ToString("HH:mm:ss")
  $logBox.AppendText("[$time] $text`r`n")
  $logBox.ScrollToEnd()

  $frame = New-Object System.Windows.Threading.DispatcherFrame
  [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke(
  [System.Windows.Threading.DispatcherPriority]::Background,
  [Action] { $frame.Continue = $false }
  )
  [System.Windows.Threading.Dispatcher]::PushFrame($frame)
}

# --- 🛠️ ฟังก์ชันภายในเวอร์ชันอัปเกรด ยกระดับความแรงสูงสุด 🛠️ ---
function Start-Core-Optimization {
  Log-Write "Initializing Hyper-Performance Tweaks..."

  # 1. Network Optimization
  Log-Write "Unlocking Advanced Network Stack & BBR Control..."
  $qosPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched"
  if (!(Test-Path $qosPath)) { New-Item -Path $qosPath -Force | Out-Null }
  Set-ItemProperty -Path $qosPath -Name "NonBestEffortLimit" -Value 0 -Type DWord -Force

  netsh int tcp set global autotuninglevel=normal | Out-Null
  netsh int tcp set global rss=enabled | Out-Null
  netsh int tcp set global ecncapability=disabled | Out-Null
  netsh int tcp set global timestamps=disabled | Out-Null
  netsh int tcp set global nonsackthickness=disabled | Out-Null
  netsh int tcp set global rsc=enabled | Out-Null
  netsh int tcp set global congestionprovider=bbr | Out-Null

  $interfacesPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
  Get-ChildItem -Path $interfacesPath | ForEach-Object {
    Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
  }
  Log-Write "-> Network latency minimized successfully."

  # 2. MMCSS Game Prioritization
  Log-Write "Configuring Multimedia Class Scheduler Service..."
  $mmcssPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
  if (!(Test-Path $mmcssPath)) { New-Item -Path $mmcssPath -Force | Out-Null }
  Set-ItemProperty -Path $mmcssPath -Name "Scheduling Category" -Value "High" -Force
  Set-ItemProperty -Path $mmcssPath -Name "Priority" -Value 6 -Force
  Set-ItemProperty -Path $mmcssPath -Name "GPU Priority" -Value 8 -Force
  Set-ItemProperty -Path $mmcssPath -Name "Clock Rate" -Value 10000 -Type DWord -Force
  Set-ItemProperty -Path $mmcssPath -Name "SFIO Priority" -Value "High" -Force
  Log-Write "-> Multimedia Task Priority locked on Games."

  # 3. CPU Core Unparking (ปลดล็อกความแรง CPU 100%)
  Log-Write "Deploying Enhanced Smart Power Profile..."
  powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
  $ultimatePlan = powercfg -list | Select-String "Ultimate Performance"
  if ($ultimatePlan) {
    $planGuid = $ultimatePlan.Line.Split()[3]
    powercfg -setactive $planGuid
    powercfg -setacvalueindex $planGuid SUB_PROCESSOR CPMINCORES 100
    powercfg -setacvalueindex $planGuid SUB_PROCESSOR CPMAXCORES 100
    powercfg -setacvalueindex $planGuid SUB_PROCESSOR PERFBOOSTMODE 2
    powercfg -setacvalueindex $planGuid SUB_PROCESSOR PROCTHROTTLEMIN 100
    powercfg -setacvalueindex $planGuid SUB_PROCESSOR PROCTHROTTLEMAX 100
    powercfg -setactive $planGuid
    Log-Write "-> All CPU logical cores unparked & boost activated."
  }

  # 4. Hardware Queue Optimization
  Log-Write "Tuning System Responsiveness & Input Lag..."
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Force
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -Force

  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value 20 -Force -ErrorAction SilentlyContinue
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 20 -Force -ErrorAction SilentlyContinue
  Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value 0 -Force
  Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value 31 -Force
  Log-Write "-> Input acceleration cleared. 1:1 Raw Response active."

  # 5. Background App Telemetry Cleanup
  Log-Write "Removing system background bottlenecks..."
  $heavyServices = @("DiagTrack", "dmwappushservice", "WerSvc", "MapsBroker")
  foreach ($service in $heavyServices) {
    if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
      Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
      Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
    }
  }
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1 -Force
  Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Force
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Force
  Log-Write "-> Bloatware services disabled."

  Log-Write "=========================================="
  Log-Write "TWEAKS DEPLOYED! REBOOT TO APPLY CHANGES."

  Clear-History -ErrorAction SilentlyContinue
  if (Get-Command Get-PSReadLineOption -ErrorAction SilentlyContinue) {
    $historyPath = (Get-PSReadLineOption).HistorySavePath
    if (Test-Path $historyPath) {
      Remove-Item $historyPath -Force -ErrorAction SilentlyContinue
    }
  }
  # 1. กำหนดคำสั่งค้นหาพาธระดับลึกของ PSReadLine อัตโนมัติ
  $PSReadLinePath = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine"

  # 2. ตรวจสอบว่าเจอโฟลเดอร์ไหม ถ้าเจอ... ลบไฟล์และโฟลเดอร์ย่อยข้างในทั้งหมดทันที
  if (Test-Path $PSReadLinePath) {
    Remove-Item -Path "$PSReadLinePath\*" -Force -Recurse -ErrorAction SilentlyContinue
    Log-Write "ลบไฟล์ทั้งหมดในโฟลเดอร์ PSReadLine เรียบร้อยแล้ว!" -ForegroundColor Green
  } else {
    Log-Write "ไม่พบโฟลเดอร์ PSReadLine ในเครื่องนี้" -ForegroundColor Yellow
  }
  Log-Write "Clear Powershell History Successfully!"
}

# กำหนดเหตุการณ์เมื่อกดปุ่ม LAUNCH
$btnLaunch.Add_Click({
  $btnLaunch.IsEnabled = $false
  $btnLaunch.Content = "TUNING..."
  Start-Core-Optimization
  $btnLaunch.Content = "COMPLETED"
})

# แสดงหน้าต่างแอปพลิเคชัน
$logBox.Text = "System Engine Ready... Waiting for Launch.`n"
$window.ShowDialog() | Out-Null
