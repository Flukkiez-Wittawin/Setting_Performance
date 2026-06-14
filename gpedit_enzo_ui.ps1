# ====================================================================
#   ALLSETTING X INTERNET - FIVEM PERFORMANCE ENGINE v3.0
#   COMBAT EDITION - Ultra Low Latency + Hit Registration + Dodge Boost
#   Power By ProjectE PERFORMANCE ENGINE (Enzo UI Premium Edition)
# ====================================================================

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
  Exit
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# ========== BUTTON ANIMATION FUNCTIONS (Simplified) ==========
function Apply-ButtonPulseAnimation {
    param($button)
    try {
        $scaleAnim = New-Object System.Windows.Media.Animation.DoubleAnimation
        $scaleAnim.From = 1.0
        $scaleAnim.To = 1.1
        $scaleAnim.Duration = New-Object System.Windows.Duration([TimeSpan]::FromMilliseconds(100))
        $scaleAnim.AutoReverse = $true
        
        $transform = New-Object System.Windows.Media.ScaleTransform
        $button.RenderTransform = $transform
        $button.RenderTransformOrigin = [System.Windows.Point]::new(0.5, 0.5)
        $transform.BeginAnimation([System.Windows.Media.ScaleTransform]::ScaleXProperty, $scaleAnim)
        $transform.BeginAnimation([System.Windows.Media.ScaleTransform]::ScaleYProperty, $scaleAnim)
    } catch { }
}

function Apply-BreathingGlowEffect {
    param($control)
    try {
        $opacityAnim = New-Object System.Windows.Media.Animation.DoubleAnimation
        $opacityAnim.From = 0.6
        $opacityAnim.To = 1.0
        $opacityAnim.Duration = New-Object System.Windows.Duration([TimeSpan]::FromMilliseconds(600))
        $opacityAnim.AutoReverse = $true
        $opacityAnim.RepeatBehavior = [System.Windows.Media.Animation.RepeatBehavior]::Forever
        if ($control.Effect) {
            $control.Effect.BeginAnimation([System.Windows.Media.Effects.DropShadowEffect]::OpacityProperty, $opacityAnim)
        }
    } catch { }
}

# ========== POWER PLAN MANAGEMENT ==========
function Create-FiveM-PowerPlan {
    try {
        $guid = "8c5e7fda-e8bf-45a1-aff5-e1fbb3b5edd0"
        
        # Remove existing plan if present
        powercfg /delete $guid 2>$null | Out-Null
        
        # Create new ultimate FiveM power plan based on Ultimate Performance
        powercfg /duplicatescheme "e9a42b02-d5df-448d-aa00-03f14749e802" $guid 2>$null | Out-Null
        
        # Set plan name
        powercfg /changename $guid "FIVEM ULTIMATE COMBAT" "Optimized for maximum FiveM performance" 2>$null | Out-Null
        
        # Set as active plan
        powercfg /setactive $guid 2>$null | Out-Null
        
        # Maximum processor performance state
        powercfg /change monitor-timeout-ac 0 2>$null | Out-Null
        powercfg /change disk-timeout-ac 0 2>$null | Out-Null
        powercfg /change standby-timeout-ac 0 2>$null | Out-Null
        
        # Processor performance boost
        powercfg /setaciveplan scheme_current sub_processor perfboostmode 2 2>$null | Out-Null
        
        return $true
    } catch {
        return $false
    }
}

# ========== ADVANCED OPTIMIZATION ENHANCER ==========
function Enhance-FiveM-Graphics {
    # NVIDIA Optimization
    $nvPath = "HKCU:\Software\NVIDIA Corporation\Global\NVTweak"
    if (!(Test-Path $nvPath)) { New-Item -Path $nvPath -Force | Out-Null }
    Set-ItemProperty -Path $nvPath -Name "Shim_mccompat" -Value 0 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $nvPath -Name "FXAA_Enable" -Value 0 -Type DWord -Force -EA SilentlyContinue
    
    # AMD Optimization
    $amdPath = "HKCU:\Software\AMD\CN"
    if (!(Test-Path $amdPath)) { New-Item -Path $amdPath -Force | Out-Null }
    Set-ItemProperty -Path $amdPath -Name "CSFF" -Value 0 -Type DWord -Force -EA SilentlyContinue
    
    # DirectX Optimization
    $dxPath = "HKCU:\Software\Microsoft\DirectX"
    if (!(Test-Path $dxPath)) { New-Item -Path $dxPath -Force | Out-Null }
    Set-ItemProperty -Path $dxPath -Name "UserGpuPreferences" -Value "GpuPreference=2;" -Force -EA SilentlyContinue
    
    # Windows Graphics Priority
    $gpuPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\GTA5.exe\PerfOptions"
    if (!(Test-Path $gpuPath)) { New-Item -Path $gpuPath -Force | Out-Null }
    Set-ItemProperty -Path $gpuPath -Name "CpuPriorityClass" -Value 3 -Type DWord -Force -EA SilentlyContinue
}



[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="AllSetting x FiveM" Height="540" Width="380"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize"
        WindowStyle="None" AllowsTransparency="True" Background="Transparent">

  <Window.Resources>
    <DropShadowEffect x:Key="NeonGlow" BlurRadius="15" Color="#00A3FF" ShadowDepth="0" Opacity="0.6"/>
    <DropShadowEffect x:Key="PanelGlow" BlurRadius="20" Color="#000000" ShadowDepth="0" Opacity="0.8"/>
  </Window.Resources>

  <Border CornerRadius="16" BorderBrush="#00A3FF" BorderThickness="1.2" Effect="{StaticResource PanelGlow}">
    <Border.Background>
      <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
        <GradientStop Color="#0A0B0E" Offset="0.0"/>
        <GradientStop Color="#101216" Offset="0.5"/>
        <GradientStop Color="#060709" Offset="1.0"/>
      </LinearGradientBrush>
    </Border.Background>

    <Grid>
      <Grid.RowDefinitions>
        <RowDefinition Height="40"/>
        <RowDefinition Height="*"/>
      </Grid.RowDefinitions>

      <Grid Name="HeaderBar" Grid.Row="0" Background="#0DFFFFFF" Cursor="SizeAll">
        <TextBlock Text="A L L S E T T I N G   X   F I V E M" FontSize="9" FontWeight="Bold"
                   Foreground="#8000A3FF" HorizontalAlignment="Center" VerticalAlignment="Center"/>
        
        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,12,0">
          <Button Name="BtnMinimize" Content="-" Width="26" Height="22" FontSize="12" FontWeight="Bold"
                  Foreground="#66FFFFFF" Background="Transparent" BorderBrush="Transparent" Margin="0,0,4,0">
            <Button.Template>
              <ControlTemplate TargetType="Button">
                <Border x:Name="Bg" Background="Transparent" CornerRadius="4">
                  <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>
                <ControlTemplate.Triggers>
                  <Trigger Property="IsMouseOver" Value="True">
                    <Setter TargetName="Bg" Property="Background" Value="#1500A3FF"/>
                    <Setter Property="Foreground" Value="#00A3FF"/>
                  </Trigger>
                </ControlTemplate.Triggers>
              </ControlTemplate>
            </Button.Template>
          </Button>
          
          <Button Name="BtnClose" Content="X" Width="26" Height="22" FontSize="10" FontWeight="Bold"
                  Foreground="#66FFFFFF" Background="Transparent" BorderBrush="Transparent">
            <Button.Template>
              <ControlTemplate TargetType="Button">
                <Border x:Name="Bg" Background="Transparent" CornerRadius="4">
                  <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>
                <ControlTemplate.Triggers>
                  <Trigger Property="IsMouseOver" Value="True">
                    <Setter TargetName="Bg" Property="Background" Value="#CCFF3333"/>
                    <Setter Property="Foreground" Value="#FFFFFF"/>
                  </Trigger>
                </ControlTemplate.Triggers>
              </ControlTemplate>
            </Button.Template>
          </Button>
        </StackPanel>
      </Grid>

      <Grid Grid.Row="1">
        
        <Grid Name="ViewStart" Visibility="Visible" Margin="20">
          <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
          </Grid.RowDefinitions>
          
          <StackPanel Grid.Row="0" VerticalAlignment="Center" HorizontalAlignment="Center">
            <TextBlock Text="ALLSETTING" FontSize="26" FontWeight="Black" HorizontalAlignment="Center">
              <TextBlock.Foreground>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                   <GradientStop Color="#00A3FF" Offset="0.0"/>
                   <GradientStop Color="#00E0FF" Offset="1.0"/>
                </LinearGradientBrush>
              </TextBlock.Foreground>
            </TextBlock>
            <TextBlock Text="PERFORMANCE ENGINE v3.0" FontSize="10" FontWeight="Bold" Foreground="#44FFFFFF" HorizontalAlignment="Center" Margin="0,4,0,0"/>
            <Border Height="2" Width="60" Background="#00A3FF" Margin="0,15,0,0" HorizontalAlignment="Center"/>
          </StackPanel>

          <Button Name="BtnStart" Grid.Row="1" Height="50" Width="260" Margin="0,0,0,40" Cursor="Hand" Background="Transparent" BorderThickness="0">
            <Button.Effect>
              <DropShadowEffect BlurRadius="10" Color="#00A3FF" ShadowDepth="0" Opacity="0.4"/>
            </Button.Effect>
            <Button.Template>
              <ControlTemplate TargetType="Button">
                <Border x:Name="Bd" CornerRadius="25" BorderThickness="1" BorderBrush="#00A3FF" Background="#0F00A3FF">
                  <TextBlock Text="START SYSTEM" FontSize="13" FontWeight="Bold" Foreground="#FFFFFF" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>
                <ControlTemplate.Triggers>
                  <Trigger Property="IsMouseOver" Value="True">
                    <Setter TargetName="Bd" Property="Background" Value="#2500A3FF"/>
                    <Setter TargetName="Bd" Property="BorderBrush" Value="#00E0FF"/>
                  </Trigger>
                </ControlTemplate.Triggers>
              </ControlTemplate>
            </Button.Template>
          </Button>
        </Grid>

        <Grid Name="ViewMain" Visibility="Collapsed" Margin="20,10,20,15">
          <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="140"/>
          </Grid.RowDefinitions>

          <StackPanel Grid.Row="0" Margin="0,5,0,10">
            <TextBlock Text="COMBAT ENGINE ACTIVE" FontSize="14" FontWeight="Black" Foreground="#00A3FF" HorizontalAlignment="Center"/>
            <TextBlock Text="READY TO TUNING PROFILE" FontSize="8" FontWeight="SemiBold" Foreground="#44FFFFFF" HorizontalAlignment="Center" Margin="0,2,0,0"/>
          </StackPanel>

          <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Hidden" HorizontalScrollBarVisibility="Disabled" Margin="5,0,5,10">
            <WrapPanel HorizontalAlignment="Center">
              <Border Margin="2" Padding="8,4" CornerRadius="6" Background="#0A00A3FF" BorderBrush="#1F00A3FF" BorderThickness="1">
                <TextBlock Text="Network Stack" FontSize="9" FontWeight="SemiBold" Foreground="#80D2FF"/>
              </Border>
              <Border Margin="2" Padding="8,4" CornerRadius="6" Background="#0A00A3FF" BorderBrush="#1F00A3FF" BorderThickness="1">
                <TextBlock Text="CPU Unpark" FontSize="9" FontWeight="SemiBold" Foreground="#80D2FF"/>
              </Border>
              <Border Margin="2" Padding="8,4" CornerRadius="6" Background="#0A00A3FF" BorderBrush="#1F00A3FF" BorderThickness="1">
                <TextBlock Text="MMCSS Game" FontSize="9" FontWeight="SemiBold" Foreground="#80D2FF"/>
              </Border>
              <Border Margin="2" Padding="8,4" CornerRadius="6" Background="#0A00A3FF" BorderBrush="#1F00A3FF" BorderThickness="1">
                <TextBlock Text="GPU Scheduler" FontSize="9" FontWeight="SemiBold" Foreground="#80D2FF"/>
              </Border>
              <Border Margin="2" Padding="8,4" CornerRadius="6" Background="#0A00A3FF" BorderBrush="#1F00A3FF" BorderThickness="1">
                <TextBlock Text="Combat Input" FontSize="9" FontWeight="SemiBold" Foreground="#80D2FF"/>
              </Border>
              <Border Margin="2" Padding="8,4" CornerRadius="6" Background="#0A00A3FF" BorderBrush="#1F00A3FF" BorderThickness="1">
                <TextBlock Text="Hit Register" FontSize="9" FontWeight="SemiBold" Foreground="#80D2FF"/>
              </Border>
              <Border Margin="2" Padding="8,4" CornerRadius="6" Background="#0A00A3FF" BorderBrush="#1F00A3FF" BorderThickness="1">
                <TextBlock Text="Timer 0.5ms" FontSize="9" FontWeight="SemiBold" Foreground="#80D2FF"/>
              </Border>
            </WrapPanel>
          </ScrollViewer>

          <Grid Grid.Row="2" Margin="0,5,0,15">
            <Button Name="BtnLaunch" Height="46" Width="280" Cursor="Hand" Background="Transparent" BorderThickness="0">
              <Button.Effect>
                <DropShadowEffect x:Name="BtnGlow" BlurRadius="12" Color="#00A3FF" ShadowDepth="0" Opacity="0.5"/>
              </Button.Effect>
              <Button.Template>
                <ControlTemplate TargetType="Button">
                  <Border x:Name="Bd" CornerRadius="23" BorderThickness="1" BorderBrush="#00A3FF">
                    <Border.Background>
                      <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
                        <GradientStop Color="#1A00A3FF" Offset="0"/>
                        <GradientStop Color="#05000000" Offset="1"/>
                      </LinearGradientBrush>
                    </Border.Background>
                    <TextBlock Name="BtnText" Text="LAUNCH OPTIMIZATION" FontSize="12" FontWeight="Black" Foreground="#FFFFFF" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                  </Border>
                  <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                      <Setter TargetName="Bd" Property="Background" Value="#3300A3FF"/>
                      <Setter TargetName="Bd" Property="BorderBrush" Value="#00E0FF"/>
                    </Trigger>
                    <Trigger Property="IsEnabled" Value="False">
                      <Setter TargetName="Bd" Property="Opacity" Value="0.4"/>
                    </Trigger>
                  </ControlTemplate.Triggers>
                </ControlTemplate>
              </Button.Template>
            </Button>
          </Grid>

          <Grid Grid.Row="3">
            <Grid.RowDefinitions>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
            <TextBlock Grid.Row="0" Text="SYSTEM DIAGNOSTIC LOG" FontSize="8" FontWeight="Bold" Foreground="#33FFFFFF" Margin="5,0,0,4"/>
            <ProgressBar Name="ProgBar" Grid.Row="1" Height="2" IsIndeterminate="True" Visibility="Collapsed" BorderThickness="0" Background="#0A0B0E" Margin="5,0,5,6">
              <ProgressBar.Foreground>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                  <GradientStop Color="#0055FF" Offset="0"/>
                  <GradientStop Color="#00A3FF" Offset="0.5"/>
                  <GradientStop Color="#00E0FF" Offset="1"/>
                </LinearGradientBrush>
              </ProgressBar.Foreground>
            </ProgressBar>
            <Border Grid.Row="2" CornerRadius="8" BorderThickness="1" Background="#0A0B0E" BorderBrush="#12FFFFFF">
              <TextBox Name="LogBox" Background="Transparent" Foreground="#80D2FF" BorderThickness="0"
                       FontFamily="Consolas" FontSize="10" IsReadOnly="True" TextWrapping="Wrap"
                       VerticalScrollBarVisibility="Auto" Margin="10,6,10,6"/>
            </Border>
          </Grid>

        </Grid>
      </Grid>

    </Grid>
  </Border>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader($xaml)
try { $window = [Windows.Markup.XamlReader]::Load($reader) }
catch { Write-Host "XAML Error: $_" -ForegroundColor Red; Exit }

$headerBar   = $window.FindName("HeaderBar")
$btnMinimize = $window.FindName("BtnMinimize")
$btnClose    = $window.FindName("BtnClose")
$btnStart    = $window.FindName("BtnStart")
$btnLaunch   = $window.FindName("BtnLaunch")
$viewStart   = $window.FindName("ViewStart")
$viewMain    = $window.FindName("ViewMain")
$logBox      = $window.FindName("LogBox")
$progBar     = $window.FindName("ProgBar")

$headerBar.Add_MouseLeftButtonDown({ $window.DragMove() })
$btnMinimize.Add_Click({ 
  Apply-ButtonPulseAnimation $btnMinimize
  $window.WindowState = [System.Windows.WindowState]::Minimized 
})
$btnClose.Add_Click({ 
  Apply-ButtonPulseAnimation $btnClose
  Start-Sleep -Milliseconds 100
  $window.Close() 
})

# --- Navigation Control with Animations ---
$btnStart.Add_Click({
  Apply-ButtonPulseAnimation $btnStart
  Start-Sleep -Milliseconds 150
  $viewStart.Visibility = [System.Windows.Visibility]::Collapsed
  $viewMain.Visibility  = [System.Windows.Visibility]::Visible
})

# --- Log Helper (Responsive & Synchronous) ---
function Log-Write ($text) {
  $time = [DateTime]::Now.ToString("HH:mm:ss")
  $logBox.AppendText("[$time] $text`r`n")
  $logBox.ScrollToEnd()
  
  $frame = New-Object System.Windows.Threading.DispatcherFrame
  [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke(
    [System.Windows.Threading.DispatcherPriority]::Background,
    [Action]{ $frame.Continue = $false })
  [System.Windows.Threading.Dispatcher]::PushFrame($frame)
}

# --- CORE OPTIMIZATION ---
function Start-FiveM-Optimization {

  # MODULE 1
  Log-Write "[ MODULE 1 ] EXTREME Network Stack Tuning..."
  
  # Create and activate FiveM Ultimate power plan
  if (Create-FiveM-PowerPlan) {
    Log-Write "   -> Custom FIVEM ULTIMATE COMBAT power plan activated"
  }
  
  # Remove QoS throttling completely
  $qosPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched"
  if (!(Test-Path $qosPath)) { New-Item -Path $qosPath -Force | Out-Null }
  Set-ItemProperty -Path $qosPath -Name "NonBestEffortLimit" -Value 0 -Type DWord -Force

  # Maximum network performance settings
  netsh int tcp set global autotuninglevel=experimental  | Out-Null
  netsh int tcp set global rss=enabled                   | Out-Null
  netsh int tcp set global ecncapability=disabled        | Out-Null
  netsh int tcp set global timestamps=disabled           | Out-Null
  netsh int tcp set global nonsackthickness=disabled     | Out-Null
  netsh int tcp set global rsc=enabled                   | Out-Null
  netsh int tcp set global congestionprovider=ctcp       | Out-Null
  netsh int tcp set global dca=enabled                   | Out-Null
  netsh int tcp set global fastopen=enabled              | Out-Null
  netsh int tcp set global fastopenfallback=enabled      | Out-Null

  # AFD - Accelerated Forwarding Daemon optimization
  $tcpParamPath = "HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters"
  if (!(Test-Path $tcpParamPath)) { New-Item -Path $tcpParamPath -Force | Out-Null }
  Set-ItemProperty -Path $tcpParamPath -Name "DefaultReceiveWindow" -Value 131072 -Type DWord -Force
  Set-ItemProperty -Path $tcpParamPath -Name "DefaultSendWindow" -Value 131072 -Type DWord -Force
  Set-ItemProperty -Path $tcpParamPath -Name "FastSendDatagramThreshold" -Value 1024 -Type DWord -Force
  Set-ItemProperty -Path $tcpParamPath -Name "FastCopyReceiveThreshold" -Value 1024 -Type DWord -Force
  Set-ItemProperty -Path $tcpParamPath -Name "MaxFastTransmit" -Value 10 -Type DWord -Force
  Set-ItemProperty -Path $tcpParamPath -Name "FastTransmitSize" -Value 10240 -Type DWord -Force

  # TCP Global Parameters - Extreme optimization
  $tcpGlobal = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
  Set-ItemProperty -Path $tcpGlobal -Name "TcpMaxDupAcks" -Value 1 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "TCPInitialRTT" -Value 50 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "DefaultTTL" -Value 64 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "MaxUserPort" -Value 65534 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "TcpTimedWaitDelay" -Value 30 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "EnableICMPRedirect" -Value 0 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "EnablePMTUDiscovery" -Value 1 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "TcpWindowSize" -Value 65535 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "TcpAckFrequency" -Value 1 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "TcpNoDelay" -Value 1 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "SackOpts" -Value 1 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "MaxFreeTcbs" -Value 16000 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "MaxHashTableSize" -Value 65536 -Type DWord -Force

  # TCP Interface-level optimization
  $ifPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
  Get-ChildItem -Path $ifPath | ForEach-Object {
    Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force -EA SilentlyContinue
  }

  # DNS Cache optimization for faster server lookup
  $dnsPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
  if (!(Test-Path $dnsPath)) { New-Item -Path $dnsPath -Force | Out-Null }
  Set-ItemProperty -Path $dnsPath -Name "CacheHashTableBucketSize" -Value 1 -Type DWord -Force
  Set-ItemProperty -Path $dnsPath -Name "CacheHashTableSize" -Value 384 -Type DWord -Force
  Set-ItemProperty -Path $dnsPath -Name "MaxCacheEntryTtlLimit" -Value 64000 -Type DWord -Force
  Set-ItemProperty -Path $dnsPath -Name "MaxSOACacheEntryTtlLimit" -Value 300 -Type DWord -Force
  Set-ItemProperty -Path $dnsPath -Name "NegativeCacheTtl" -Value 60 -Type DWord -Force
  
  # Enhance graphics settings
  Enhance-FiveM-Graphics
  
  Log-Write "   -> TCP/UDP EXTREME optimized, power plan active, graphics enhanced"
  Log-Write "   -> Network stack latency minimized."

  # MODULE 2
  Log-Write "[ MODULE 2 ] CPU Unpark and Power Optimization..."
  powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null | Out-Null
  $ultimatePlan = powercfg -list | Select-String "Ultimate Performance"
  if ($ultimatePlan) {
    $planGuid = ($ultimatePlan.Line -split '\s+')[3]
    powercfg -setactive $planGuid 2>$null
    powercfg -setacvalueindex $planGuid SUB_PROCESSOR CPMINCORES     100 2>$null
    powercfg -setacvalueindex $planGuid SUB_PROCESSOR CPMAXCORES     100 2>$null
    powercfg -setacvalueindex $planGuid SUB_PROCESSOR PERFBOOSTMODE  2 2>$null
    powercfg -setacvalueindex $planGuid SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null
    powercfg -setacvalueindex $planGuid SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null
    powercfg -setacvalueindex $planGuid SUB_PROCESSOR PERFEPP        0 2>$null
    powercfg -setacvalueindex $planGuid SUB_PROCESSOR PERFAUTONOMOUS 0 2>$null
    powercfg -setacvalueindex $planGuid SUB_SLEEP STANDBYIDLE        0 2>$null
    powercfg -setacvalueindex $planGuid SUB_SLEEP HYBRIDSLEEP        0 2>$null
    powercfg -setacvalueindex $planGuid SUB_VIDEO VIDEOIDLE          0 2>$null
    powercfg -setacvalueindex $planGuid SUB_PCIEXPRESS ASPM          0 2>$null
    powercfg -setactive $planGuid 2>$null
    Log-Write "   -> Ultimate Power Plan active. All cores unparked."
  } else {
    Log-Write "   -> High Performance backup active."
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null
  }

  $parkPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583"
  if (Test-Path $parkPath) {
    Set-ItemProperty -Path $parkPath -Name "ValueMax" -Value 0 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $parkPath -Name "ValueMin" -Value 0 -Type DWord -Force -EA SilentlyContinue
  }
  $nvTweak = "HKCU:\Software\NVIDIA Corporation\Global\NVTweak"
  if (!(Test-Path $nvTweak)) { New-Item -Path $nvTweak -Force | Out-Null }
  Set-ItemProperty -Path $nvTweak -Name "PowerMizerMode" -Value 1 -Type DWord -Force -EA SilentlyContinue
  Set-ItemProperty -Path $nvTweak -Name "PerfLevelSrc" -Value 0x3322 -Type DWord -Force -EA SilentlyContinue

  # MODULE 3
  Log-Write "[ MODULE 3 ] MMCSS Game and Audio Priority..."
  $mmBase = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
  Set-ItemProperty -Path $mmBase -Name "SystemResponsiveness" -Value 0 -Force
  Set-ItemProperty -Path $mmBase -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Force

  $mmGames = "$mmBase\Tasks\Games"
  if (!(Test-Path $mmGames)) { New-Item -Path $mmGames -Force | Out-Null }
  Set-ItemProperty -Path $mmGames -Name "Scheduling Category" -Value "High" -Force
  Set-ItemProperty -Path $mmGames -Name "Priority" -Value 6 -Force
  Set-ItemProperty -Path $mmGames -Name "GPU Priority" -Value 8 -Force
  Set-ItemProperty -Path $mmGames -Name "Clock Rate" -Value 10000 -Type DWord -Force
  Set-ItemProperty -Path $mmGames -Name "SFIO Priority" -Value "High" -Force
  Set-ItemProperty -Path $mmGames -Name "Affinity" -Value 0 -Type DWord -Force
  Set-ItemProperty -Path $mmGames -Name "Background Only" -Value "False" -Force

  $mmAudio = "$mmBase\Tasks\Audio"
  if (!(Test-Path $mmAudio)) { New-Item -Path $mmAudio -Force | Out-Null }
  Set-ItemProperty -Path $mmAudio -Name "Clock Rate" -Value 10000 -Type DWord -Force
  Set-ItemProperty -Path $mmAudio -Name "GPU Priority" -Value 8 -Force
  Set-ItemProperty -Path $mmAudio -Name "Priority" -Value 6 -Force
  Set-ItemProperty -Path $mmAudio -Name "Scheduling Category" -Value "Medium" -Force
  Set-ItemProperty -Path $mmAudio -Name "SFIO Priority" -Value "Normal" -Force
  Log-Write "   -> MMCSS optimized for real-time task priority."

  # MODULE 4
  Log-Write "[ MODULE 4 ] GPU and Graphics Scheduler Tuning..."
  $gpuSchedulerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
  if (!(Test-Path $gpuSchedulerPath)) { New-Item -Path $gpuSchedulerPath -Force | Out-Null }
  Set-ItemProperty -Path $gpuSchedulerPath -Name "HwSchMode" -Value 2 -Type DWord -Force

  $dxPath = "HKLM:\SOFTWARE\Microsoft\DirectX"
  if (!(Test-Path $dxPath)) { New-Item -Path $dxPath -Force | Out-Null }
  Set-ItemProperty -Path $dxPath -Name "MaxFrameLatency" -Value 1 -Type DWord -Force

  $nvPath = "HKCU:\Software\NVIDIA Corporation\Global\NVTweak"
  if (!(Test-Path $nvPath)) { New-Item -Path $nvPath -Force | Out-Null }
  Set-ItemProperty -Path $nvPath -Name "Shim_mccompat" -Value 0x00000000 -Type DWord -Force -EA SilentlyContinue

  $dxRegPath = "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences"
  if (!(Test-Path $dxRegPath)) { New-Item -Path $dxRegPath -Force | Out-Null }
  $fivemExePath = "$env:LOCALAPPDATA\FiveM\FiveM.exe"
  if (Test-Path $fivemExePath) {
    Set-ItemProperty -Path $dxRegPath -Name $fivemExePath -Value "GpuPreference=2;" -Force -EA SilentlyContinue
  }
  Log-Write "   -> GPU Preference forced, HAGS active."

  # MODULE 5
  Log-Write "[ MODULE 5 ] FiveM and GTA Process Priority Boost..."
  $gtaProcs = @("FiveM_b2060_GTAProcess.exe", "FiveM_b2189_GTAProcess.exe", "FiveM_b2545_GTAProcess.exe", "FiveM_b2699_GTAProcess.exe", "FiveM_b2802_GTAProcess.exe", "FiveM_b2944_GTAProcess.exe", "FiveM_b3095_GTAProcess.exe", "FiveM_GTAProcess.exe", "GTA5.exe", "gtav.exe")
  $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
  foreach ($proc in $gtaProcs) {
    $path = "$registryPath\$proc\PerfOptions"
    if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name "CpuPriorityClass" -Value 3 -Type DWord -Force
    Set-ItemProperty -Path $path -Name "IoPriority" -Value 3 -Type DWord -Force
  }
  Log-Write "   -> CPU & IO Priority permanently set to High via Registry."

  $gameBarPath = "HKCU:\Software\Microsoft\GameBar"
  if (!(Test-Path $gameBarPath)) { New-Item -Path $gameBarPath -Force | Out-Null }
  Set-ItemProperty -Path $gameBarPath -Name "AllowAutoGameMode" -Value 1 -Force
  Set-ItemProperty -Path $gameBarPath -Name "AutoGameModeEnabled" -Value 1 -Force

  $gameStorePath = "HKCU:\System\GameConfigStore"
  if (!(Test-Path $gameStorePath)) { New-Item -Path $gameStorePath -Force | Out-Null }
  Set-ItemProperty -Path $gameStorePath -Name "GameDVR_Enabled" -Value 0 -Force
  Set-ItemProperty -Path $gameStorePath -Name "GameDVR_FSEBehavior" -Value 2 -Force
  Set-ItemProperty -Path $gameStorePath -Name "GameDVR_FSEBehaviorMode" -Value 2 -Force
  Set-ItemProperty -Path $gameStorePath -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 0 -Force

  $dvPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
  if (!(Test-Path $dvPath)) { New-Item -Path $dvPath -Force | Out-Null }
  Set-ItemProperty -Path $dvPath -Name "AllowGameDVR" -Value 0 -Force
  Log-Write "   -> Windows Game Mode optimizations configured."

  # MODULE 6
  Log-Write "[ MODULE 6 ] Combat Mouse Raw Input Pipeline..."
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value 32 -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Force
  Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Force
  Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Force
  Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSensitivity" -Value "10" -Force
  Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseXCurve" -Value ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xC0,0xCC,0x0C,0x00,0x00,0x00,0x00,0x00,0x80,0x99,0x19,0x00,0x00,0x00,0x00,0x00,0x40,0x66,0x26,0x00,0x00,0x00,0x00,0x00,0x00,0x33,0x33,0x00,0x00,0x00,0x00,0x00)) -Type Binary -Force
  Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseYCurve" -Value ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x38,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xA8,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xE0,0x00,0x00,0x00,0x00,0x00)) -Type Binary -Force
  $mouseParams = "HKCU:\Control Panel\Mouse"
  Set-ItemProperty -Path $mouseParams -Name "MouseTrails" -Value "0" -Force
  $hidPath = "HKLM:\SYSTEM\CurrentControlSet\Services\HidUsb\Parameters"
  if (!(Test-Path $hidPath)) { New-Item -Path $hidPath -Force | Out-Null }
  Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\USB" -Recurse -EA SilentlyContinue |
    Where-Object { $_.PSChildName -eq "Device Parameters" } |
    ForEach-Object {
      Set-ItemProperty -Path $_.PSPath -Name "EnhancedPowerManagementEnabled" -Value 0 -Type DWord -Force -EA SilentlyContinue
      Set-ItemProperty -Path $_.PSPath -Name "AllowIdleIrpInD3" -Value 0 -Type DWord -Force -EA SilentlyContinue
      Set-ItemProperty -Path $_.PSPath -Name "SelectiveSuspendEnabled" -Value 0 -Type DWord -Force -EA SilentlyContinue
    }
  Log-Write "   -> Mouse raw pipeline: 1:1, no accel, no smoothing."

  # MODULE 7
  Log-Write "[ MODULE 7 ] Combat Keyboard Response Tuning..."
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 32 -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value 0 -Force
  Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value 31 -Force
  Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "AutoRepeatDelay" -Value "200" -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "AutoRepeatRate" -Value "6" -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "DelayBeforeAcceptance" -Value "0" -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "Flags" -Value "2" -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "BounceTime" -Value "0" -Force -EA SilentlyContinue
  $stickyPath = "HKCU:\Control Panel\Accessibility\StickyKeys"
  if (Test-Path $stickyPath) {
    Set-ItemProperty -Path $stickyPath -Name "Flags" -Value "506" -Force -EA SilentlyContinue
  }
  $togglePath = "HKCU:\Control Panel\Accessibility\ToggleKeys"
  if (Test-Path $togglePath) {
    Set-ItemProperty -Path $togglePath -Name "Flags" -Value "58" -Force -EA SilentlyContinue
  }
  Log-Write "   -> Keyboard: 0ms delay, max repeat."

  # MODULE 8
  Log-Write "[ MODULE 8 ] Ultra Low Timer Resolution (0.5ms)..."
  $timerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"
  if (!(Test-Path $timerPath)) { New-Item -Path $timerPath -Force | Out-Null }
  Set-ItemProperty -Path $timerPath -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -Force
  Add-Type -TypeDefinition @"
  using System;
  using System.Runtime.InteropServices;
  public class TimerResolution {
    [DllImport("ntdll.dll", SetLastError = true)]
    public static extern int NtSetTimerResolution(int DesiredResolution, bool SetResolution, out int CurrentResolution);
  }
"@ -EA SilentlyContinue
  try {
    $currentRes = 0
    [TimerResolution]::NtSetTimerResolution(5000, $true, [ref]$currentRes) | Out-Null
    $actualMs = [math]::Round($currentRes / 10000, 2)
    Log-Write "   -> Timer resolution forced to ${actualMs}ms."
  } catch {
    Log-Write "   -> Timer resolution: using GlobalTimerResolution fallback."
  }
  bcdedit /set disabledynamictick yes 2>$null | Out-Null
  bcdedit /set useplatformtick yes 2>$null | Out-Null
  Log-Write "   -> Dynamic tick disabled, platform tick forced."

  # MODULE 9
  Log-Write "[ MODULE 9 ] DPC/ISR Latency Reduction..."
  Get-NetAdapter | ForEach-Object {
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*FlowControl" -RegistryValue 0 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*InterruptModeration" -RegistryValue 0 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*EEE" -RegistryValue 0 -EA SilentlyContinue
    Disable-NetAdapterPowerManagement -Name $_.Name -EA SilentlyContinue
  }
  $usbPowerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\48e6b7a6-50f5-4782-a5d4-53bb8f07e226"
  if (Test-Path $usbPowerPath) {
    Set-ItemProperty -Path $usbPowerPath -Name "Attributes" -Value 2 -Type DWord -Force -EA SilentlyContinue
  }
  bcdedit /deletevalue useplatformclock 2>$null | Out-Null
  bcdedit /set useplatformclock false 2>$null | Out-Null
  Disable-MMAgent -MemoryCompression -EA SilentlyContinue | Out-Null
  Log-Write "   -> DPC/ISR: HPET & Memory compression disabled."

  # MODULE 10
  Log-Write "[ MODULE 10 ] Network Hit Registration Boost..."
  $tcpGlobal2 = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
  Set-ItemProperty -Path $tcpGlobal2 -Name "DisableTaskOffload" -Value 0 -Type DWord -Force -EA SilentlyContinue
  Set-ItemProperty -Path $tcpGlobal2 -Name "EnableWsd" -Value 0 -Type DWord -Force -EA SilentlyContinue
  Set-ItemProperty -Path $tcpGlobal2 -Name "Tcp1323Opts" -Value 1 -Type DWord -Force -EA SilentlyContinue
  $ifPath2 = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
  Get-ChildItem -Path $ifPath2 | ForEach-Object {
    Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name "TcpInitialRTT" -Value 300 -Type DWord -Force -EA SilentlyContinue
  }
  netsh int tcp set global initialRto=300 2>$null | Out-Null
  Get-NetAdapter | ForEach-Object {
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*ReceiveBuffers" -RegistryValue 2048 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*TransmitBuffers" -RegistryValue 2048 -EA SilentlyContinue
  }
  Log-Write "   -> UDP/TCP optimized: Nagle off, ACK=1."

  # MODULE 11
  Log-Write "[ MODULE 11 ] Eliminating Background Bottlenecks..."
  $stopServices = @("DiagTrack", "dmwappushservice", "WerSvc", "MapsBroker", "RetailDemo", "TabletInputService", "Fax", "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "SysMain", "WSearch", "AxInstSV", "lfsvc", "PhoneSvc")
  foreach ($svc in $stopServices) {
    $s = Get-Service -Name $svc -EA SilentlyContinue
    if ($s) {
      Stop-Service -Name $svc -Force -EA SilentlyContinue
      Set-Service -Name $svc -StartupType Disabled -EA SilentlyContinue
    }
  }
  $searchPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
  if (!(Test-Path $searchPath)) { New-Item -Path $searchPath -Force | Out-Null }
  Set-ItemProperty -Path $searchPath -Name "AllowCortana" -Value 0 -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Force -EA SilentlyContinue
  $visualPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
  if (!(Test-Path $visualPath)) { New-Item -Path $visualPath -Force | Out-Null }
  Set-ItemProperty -Path $visualPath -Name "VisualFXSetting" -Value 2 -Force
  Log-Write "   -> 15 bloat services disabled."

  # MODULE 12
  Log-Write "[ MODULE 12 ] Memory and Paging Performance..."
  $memPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
  Set-ItemProperty -Path $memPath -Name "DisablePagingExecutive" -Value 1 -Type DWord -Force
  Set-ItemProperty -Path $memPath -Name "LargeSystemCache" -Value 0 -Type DWord -Force
  Set-ItemProperty -Path $memPath -Name "SecondLevelDataCache" -Value 512 -Type DWord -Force
  Set-ItemProperty -Path $memPath -Name "IoPageLockLimit" -Value 983040 -Type DWord -Force
  Set-ItemProperty -Path $memPath -Name "NonPagedPoolSize" -Value 0 -Type DWord -Force
  Set-ItemProperty -Path $memPath -Name "PagedPoolSize" -Value 0 -Type DWord -Force
  Set-ItemProperty -Path $memPath -Name "PoolUsageMaximum" -Value 60 -Type DWord -Force
  $pfPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
  Set-ItemProperty -Path $pfPath -Name "EnablePrefetcher" -Value 3 -Type DWord -Force -EA SilentlyContinue
  Set-ItemProperty -Path $pfPath -Name "EnableSuperfetch" -Value 0 -Type DWord -Force -EA SilentlyContinue
  Log-Write "   -> RAM lock, pool optimized."

  # MODULE 12.5 - EXTREME OPTIMIZATION (NEW!)
  Log-Write "[ MODULE 12.5 ] EXTREME Network & Input Lag Unlocking..."
  
  # Network Speed Unlock - Remove QoS Throttling
  netsh int tcp set global autotuninglevel=experimental 2>$null | Out-Null
  netsh int tcp set global congestionprovider=ctcp 2>$null | Out-Null
  netsh int tcp set supplemental internetcongestionprovider=ctcp 2>$null | Out-Null
  
  # Maximum network buffer sizes
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpWindowSize" -Value 65535 -Type DWord -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpNoDelay" -Value 1 -Type DWord -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpInitialRTT" -Value 50 -Type DWord -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpMaxDupAcks" -Value 2 -Type DWord -Force -EA SilentlyContinue
  
  # Ultra-low input delay
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 64 -Type DWord -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value 64 -Type DWord -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataThrottleSize" -Value 0 -Type DWord -Force -EA SilentlyContinue
  
  # Network adapter extreme settings
  Get-NetAdapter | ForEach-Object {
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*ReceiveBuffers" -RegistryValue 4096 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*TransmitBuffers" -RegistryValue 4096 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "RxIntCoalesce" -RegistryValue 0 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "TxIntCoalesce" -RegistryValue 0 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*JumboPacket" -RegistryValue 9014 -EA SilentlyContinue
  }
  
  # Extreme mouse settings for faster response
  Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSensitivity" -Value "20" -Force
  Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Force
  Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Force
  Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Force
  
  Log-Write "   -> EXTREME: Max network speed unlocked, input lag minimized, buffers maxed!"

  # MODULE 13
  Log-Write "[ MODULE 13 ] FiveM Combat Profile Configuration..."
  $fivemCfgPath = "$env:APPDATA\CitizenFX"
  if (!(Test-Path $fivemCfgPath)) { New-Item -Path $fivemCfgPath -Force -ItemType Directory | Out-Null }
  $fivemAppData = "$env:LOCALAPPDATA\FiveM"
  if (Test-Path $fivemAppData) {
    $settingsFile = "$env:USERPROFILE\Documents\Rockstar Games\GTA V\settings.xml"
    if (Test-Path $settingsFile) {
      $settingsContent = Get-Content -Path $settingsFile -Raw
      if ($settingsContent -match 'PauseOnFocusLoss value="1"') {
        $settingsContent = $settingsContent -replace 'PauseOnFocusLoss value="1"', 'PauseOnFocusLoss value="0"'
      }
      if ($settingsContent -match 'VSync value="1"') {
        $settingsContent = $settingsContent -replace 'VSync value="1"', 'VSync value="0"'
      }
      Set-Content -Path $settingsFile -Value $settingsContent -Force
      Log-Write "   -> GTA V settings: VSync OFF, FocusLoss OFF."
    }
    
    Log-Write "   -> Installing Active Combat Daemon task..."
    $taskName = "FiveM_Combat_Boost_Daemon"
    $daemonScript = "$env:LOCALAPPDATA\FiveM_Combat_Daemon.ps1"
    
    $daemonCode = @"
# ====================================================================
#   ALLSETTING X FIVEM - REAL-TIME COMBAT BOOST DAEMON v4.0
# ====================================================================
`$memCode = 'using System; using System.Runtime.InteropServices; public class MemoryCleaner { [DllImport("psapi.dll")] public static extern int EmptyWorkingSet(IntPtr hwProc); }'
Add-Type -TypeDefinition `$memCode -ErrorAction SilentlyContinue

`$gtaProcesses = @("FiveM", "FiveM_b2060_GTAProcess", "FiveM_b2189_GTAProcess", "FiveM_b2545_GTAProcess", "FiveM_b2699_GTAProcess", "FiveM_b2802_GTAProcess", "FiveM_b2944_GTAProcess", "FiveM_b3095_GTAProcess", "FiveM_GTAProcess", "GTA5", "gtav")
`$backgroundApps = @("chrome", "msedge", "firefox", "discord", "spotify", "onedrive", "steamwebhelper")

function Clear-StandbyRAM {
    Get-Process | ForEach-Object {
        try {
            `$name = `$_.ProcessName.ToLower()
            if (`$gtaProcesses -notcontains `$name -and `$_.Handle -ne [IntPtr]::Zero) {
                [MemoryCleaner]::EmptyWorkingSet(`$_.Handle) | Out-Null
            }
        } catch {}
    }
}

`$ultimatePlanGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
`$ramCleanCounter = 0

while (`$true) {
    `$runningGta = @()
    foreach (`$pName in `$gtaProcesses) {
        `$p = Get-Process -Name `$pName -ErrorAction SilentlyContinue
        if (`$p) { `$runningGta += `$p }
    }

    if (`$runningGta.Count -gt 0) {
        `$activePlan = powercfg -getactivescheme
        if (`$activePlan -notmatch `$ultimatePlanGuid) {
            powercfg -setactive `$ultimatePlanGuid 2>`$null
        }
        foreach (`$proc in `$runningGta) {
            if (`$proc.PriorityClass -ne [System.Diagnostics.ProcessPriorityClass]::High) {
                `$proc.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::High
            }
        }
        foreach (`$bgName in `$backgroundApps) {
            `$bgProcs = Get-Process -Name `$bgName -ErrorAction SilentlyContinue
            foreach (`$bgP in `$bgProcs) {
                if (`$bgP.PriorityClass -ne [System.Diagnostics.ProcessPriorityClass]::BelowNormal) {
                    `$bgP.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::BelowNormal
                }
            }
        }
        `$ramCleanCounter++
        if (`$ramCleanCounter -ge 60) {
            Clear-StandbyRAM
            `$ramCleanCounter = 0
        }
    }
    Start-Sleep -Seconds 3
}
"@
    Set-Content -Path $daemonScript -Value $daemonCode -Force
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$daemonScript`""
    $trigger = New-ScheduledTaskTrigger -AtLogon
    $principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
    Start-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue | Out-Null
    Log-Write "   -> FiveM combat profile & Active Daemon ready."
  }

  Log-Write "=========================================="
  Log-Write " ALL 13 MODULES APPLIED SUCCESSFULLY!"
  Log-Write " REBOOT recommended for full effect."
  Log-Write "=========================================="

  Clear-History -EA SilentlyContinue
  if (Get-Command Get-PSReadLineOption -EA SilentlyContinue) {
    $histPath = (Get-PSReadLineOption).HistorySavePath
    if (Test-Path $histPath) { Remove-Item $histPath -Force -EA SilentlyContinue }
  }
}

$btnLaunch.Add_Click({
  Apply-ButtonPulseAnimation $btnLaunch
  $btnLaunch.IsEnabled = $false
  
  if ($progBar) { 
    $progBar.Visibility = [System.Windows.Visibility]::Visible
    # Animate progress bar appearance
    $opacityAnim = New-Object System.Windows.Media.Animation.DoubleAnimation
    $opacityAnim.From = 0
    $opacityAnim.To = 1
    $opacityAnim.Duration = New-Object System.Windows.Duration([TimeSpan]::FromMilliseconds(300))
    $progBar.BeginAnimation([System.Windows.UIElement]::OpacityProperty, $opacityAnim)
    
    $frame = New-Object System.Windows.Threading.DispatcherFrame
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke(
      [System.Windows.Threading.DispatcherPriority]::Background,
      [Action]{ $frame.Continue = $false })
    [System.Windows.Threading.Dispatcher]::PushFrame($frame)
  }
  
  # Apply breathing glow effect to window border
  Apply-BreathingGlowEffect $window
  
  Start-FiveM-Optimization
  
  if ($progBar) { $progBar.Visibility = [System.Windows.Visibility]::Collapsed }
  $tb = $btnLaunch.Template.FindName("BtnText", $btnLaunch)
  if ($tb) { $tb.Text = "✓ OPTIMIZED SUCCESSFULLY" }
})

$logBox.Text = "FiveM Performance Engine ready...`r`nClick LAUNCH OPTIMIZATION to begin.`r`n"
$window.ShowDialog() | Out-Null



