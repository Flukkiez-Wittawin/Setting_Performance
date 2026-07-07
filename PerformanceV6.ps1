# ====================================================================
#   ALLSETTING X INTERNET - FIVEM PERFORMANCE ENGINE v6.0
#   COMBAT EDITION - Ultra Low Latency + Hit Registration + Dodge Boost
#   Power By Minishawty Project PERFORMANCE ENGINE (Enzo UI Premium Edition)
# ====================================================================

# Platform check (Ensure it runs only on Windows OS)
if ($env:OS -notmatch "Windows" -and $PSVersionTable.Platform -ne "Windows" -and $true -ne $IsWindows) {
  Write-Host "This script is only compatible with Windows Operating System." -ForegroundColor Red
  exit
}

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
  exit
}

# ================= KEY CHECK =================
# Password will be checked in UI
$script:WhitelistUrl = "https://raw.githubusercontent.com/your-github-username/your-repo/main/whitelist.txt"



# ================= SCRIPT =================

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# ========== OS CMDLET COMPATIBILITY HELPERS ==========
# Ensure standard gaming/network cmdlets run safely on any Windows edition/version
if (!(Get-Command Get-NetAdapter -ErrorAction SilentlyContinue)) {
  function Get-NetAdapter { @() }
  function Set-NetAdapterAdvancedProperty { }
  function Enable-NetAdapterPowerManagement { }
  function Disable-NetAdapterPowerManagement { }
  function Restart-NetAdapter { }
}

if (!(Get-Command Get-MMAgent -ErrorAction SilentlyContinue)) {
  function Get-MMAgent { [pscustomobject]@{ MemoryCompression = $true } }
  function Disable-MMAgent { }
  function Enable-MMAgent { }
}

if (!(Get-Command Register-ScheduledTask -ErrorAction SilentlyContinue)) {    
  function New-ScheduledTaskAction { }
  function New-ScheduledTaskTrigger { }
  function New-ScheduledTaskPrincipal { }
  function New-ScheduledTaskSettingsSet { }
  function Register-ScheduledTask { }
  function Start-ScheduledTask { }
  function Unregister-ScheduledTask { }
}

if (!(Get-Command Get-CimInstance -ErrorAction SilentlyContinue)) {
  function Get-CimInstance {
    param([string]$ClassName, [string]$ErrorAction)
    if (Get-Command Get-WmiObject -ErrorAction SilentlyContinue) {
      Get-WmiObject -Class $ClassName -EA SilentlyContinue
    }
    else {
      # Fallback dummy object
      [pscustomobject]@{ Name = "Gaming Processor"; NumberOfCores = 4; NumberOfLogicalProcessors = 4 }
    }
  }
}

# ========== BUTTON ANIMATION FUNCTIONS (Enhanced) ==========
function Apply-ButtonPulseAnimation {
  param($button)
  try {
    $scaleAnim = New-Object System.Windows.Media.Animation.DoubleAnimation
    $scaleAnim.From = 1.0
    $scaleAnim.To = 1.08
    $scaleAnim.Duration = New-Object System.Windows.Duration([TimeSpan]::FromMilliseconds(120))
    $scaleAnim.AutoReverse = $true
    $scaleAnim.EasingFunction = New-Object System.Windows.Media.Animation.CubicEase
    $scaleAnim.EasingFunction.EasingMode = [System.Windows.Media.Animation.EasingMode]::EaseOut
        
    $transform = New-Object System.Windows.Media.ScaleTransform
    $button.RenderTransform = $transform
    $button.RenderTransformOrigin = [System.Windows.Point]::new(0.5, 0.5)
    $transform.BeginAnimation([System.Windows.Media.ScaleTransform]::ScaleXProperty, $scaleAnim)
    $transform.BeginAnimation([System.Windows.Media.ScaleTransform]::ScaleYProperty, $scaleAnim)
  }
  catch { }
}

function Apply-BreathingGlowEffect {
  param($control)
  try {
    $opacityAnim = New-Object System.Windows.Media.Animation.DoubleAnimation
    $opacityAnim.From = 0.65
    $opacityAnim.To = 0.95
    $opacityAnim.Duration = New-Object System.Windows.Duration([TimeSpan]::FromMilliseconds(800))
    $opacityAnim.AutoReverse = $true
    $opacityAnim.RepeatBehavior = [System.Windows.Media.Animation.RepeatBehavior]::Forever
    $opacityAnim.EasingFunction = New-Object System.Windows.Media.Animation.SineEase
    $opacityAnim.EasingFunction.EasingMode = [System.Windows.Media.Animation.EasingMode]::EaseInOut
    if ($control.Effect) {
      $control.Effect.BeginAnimation([System.Windows.Media.Effects.DropShadowEffect]::OpacityProperty, $opacityAnim)
    }
  }
  catch { }
}

function Apply-CardHoverAnimation {
  param($card, $isHovered)
  try {
    $duration = New-Object System.Windows.Duration([TimeSpan]::FromMilliseconds(150))
    
    # Scale animation (zoom in slightly on hover)
    $scaleAnimX = New-Object System.Windows.Media.Animation.DoubleAnimation
    $scaleAnimX.To = if ($isHovered) { 1.04 } else { 1.0 }
    $scaleAnimX.Duration = $duration
    $scaleAnimX.EasingFunction = New-Object System.Windows.Media.Animation.CubicEase
    
    $scaleAnimY = New-Object System.Windows.Media.Animation.DoubleAnimation
    $scaleAnimY.To = if ($isHovered) { 1.04 } else { 1.0 }
    $scaleAnimY.Duration = $duration
    $scaleAnimY.EasingFunction = New-Object System.Windows.Media.Animation.CubicEase
    
    # Translation animation (slide out to the right slightly)
    $transAnimX = New-Object System.Windows.Media.Animation.DoubleAnimation
    $transAnimX.To = if ($isHovered) { 8 } else { 0 }
    $transAnimX.Duration = $duration
    $transAnimX.EasingFunction = New-Object System.Windows.Media.Animation.CubicEase
    
    $tg = $card.RenderTransform
    if ($tg -and $tg.Children.Count -ge 2) {
      $st = $tg.Children[0]
      $tt = $tg.Children[1]
      $st.BeginAnimation([System.Windows.Media.ScaleTransform]::ScaleXProperty, $scaleAnimX)
      $st.BeginAnimation([System.Windows.Media.ScaleTransform]::ScaleYProperty, $scaleAnimY)
      $tt.BeginAnimation([System.Windows.Media.TranslateTransform]::XProperty, $transAnimX)
    }
    
    # Glow effect opacity
    if ($card.Effect) {
      # Keep active selected card glow high even when mouse leaves
      $targetOpacity = 0.3
      if ($isHovered) {
        $targetOpacity = 0.75
      }
      elseif ($card.Name -match "Mode(\d+)" -and "Mode$($Matches[1])" -eq $script:selectedMode) {
        $targetOpacity = 0.85
      }
      
      $opacityAnim = New-Object System.Windows.Media.Animation.DoubleAnimation
      $opacityAnim.To = $targetOpacity
      $opacityAnim.Duration = $duration
      $card.Effect.BeginAnimation([System.Windows.Media.Effects.DropShadowEffect]::OpacityProperty, $opacityAnim)
    }
  }
  catch { }
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
  }
  catch {
    return $false
  }
}

# ========== ADVANCED OPTIMIZATION ENHANCER ==========
function Enhance-FiveM-Graphics {
  param([string]$Mode = "Ultimate")
  # NVIDIA Optimization
  $nvPath = "HKCU:\Software\NVIDIA Corporation\Global\NVTweak"
  if (!(Test-Path $nvPath)) { New-Item -Path $nvPath -Force | Out-Null }
  Set-ItemProperty -Path $nvPath -Name "Shim_mccompat" -Value 0 -Type DWord -Force -EA SilentlyContinue
  Set-ItemProperty -Path $nvPath -Name "FXAA_Enable" -Value 0 -Type DWord -Force -EA SilentlyContinue
    
  # AMD Optimization
  $amdPath = "HKCU:\Software\AMD\CN"
  if (!(Test-Path $amdPath)) { New-Item -Path $amdPath -Force | Out-Null }
  Set-ItemProperty -Path $amdPath -Name "CSFF" -Value 0 -Type DWord -Force -EA SilentlyContinue
  
  if ($Mode -eq "GodMode" -or $Mode -eq "Mode19") {
    $amdPaths = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -ErrorAction SilentlyContinue
    foreach ($ap in $amdPaths) {
      if ($ap.PSChildName -match "^\d{4}$") {
        Set-ItemProperty -Path $ap.PSPath -Name "PP_AllPhonesPowerDownLimit" -Value 0 -Type DWord -Force -EA SilentlyContinue
        Set-ItemProperty -Path $ap.PSPath -Name "StutterMode" -Value 0 -Type DWord -Force -EA SilentlyContinue
      }
    }
  }
    
  # DirectX Optimization
  $dxPath = "HKCU:\Software\Microsoft\DirectX"
  if (!(Test-Path $dxPath)) { New-Item -Path $dxPath -Force | Out-Null }
  Set-ItemProperty -Path $dxPath -Name "UserGpuPreferences" -Value "GpuPreference=2;" -Force -EA SilentlyContinue
    
  # Windows Graphics Priority
  $gpuPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\GTA5.exe\PerfOptions"
  if (!(Test-Path $gpuPath)) { New-Item -Path $gpuPath -Force | Out-Null }
  Set-ItemProperty -Path $gpuPath -Name "CpuPriorityClass" -Value 3 -Type DWord -Force -EA SilentlyContinue
}

# ========== BACKUP & RESTORE SYSTEM ==========
$script:BackupFolder = "$env:LOCALAPPDATA\EnzoGPEDIT_Status"

function Get-RegistryValue {
  param([string]$Path, [string]$Name)
  try {
    if (Test-Path $Path) {
      $val = Get-ItemProperty -Path $Path -Name $Name -EA SilentlyContinue
      if ($null -ne $val) {
        $raw = $val.$Name
        $item = Get-Item -Path $Path -EA SilentlyContinue
        $kind = $item.GetValueKind($Name)
        return @{ Value = $raw; Kind = $kind.ToString(); Exists = $true }
      }
    }
  }
  catch { }
  return @{ Value = $null; Kind = $null; Exists = $false }
}

function Backup-CurrentSettings {
  if (!(Test-Path $script:BackupFolder)) { New-Item -Path $script:BackupFolder -ItemType Directory -Force | Out-Null }
    
  $backup = @{
    Timestamp = [DateTime]::Now.ToString("yyyy-MM-dd HH:mm:ss")
    Version   = "6.0"
  }
    
  # --- Power Plan ---
  try {
    $activePlan = powercfg /getactivescheme 2>$null
    if ($activePlan -match '([0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12})') {
      $backup["ActivePowerPlanGuid"] = $Matches[1]
    }
  }
  catch { }
    
  # --- QoS ---
  $backup["QoS_NonBestEffortLimit"] = Get-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched" "NonBestEffortLimit"
    
  # --- AFD Parameters ---
  $afdKeys = @("DefaultReceiveWindow", "DefaultSendWindow", "FastSendDatagramThreshold", "FastCopyReceiveThreshold", "MaxFastTransmit", "FastTransmitSize")
  $afdBackup = @{}
  foreach ($k in $afdKeys) { $afdBackup[$k] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters" $k }
  $backup["AFD"] = $afdBackup
    
  # --- TCP Global Parameters ---
  $tcpKeys = @("TcpMaxDupAcks", "TCPInitialRTT", "DefaultTTL", "MaxUserPort", "TcpTimedWaitDelay", "EnableICMPRedirect", "EnablePMTUDiscovery", "TcpWindowSize", "TcpAckFrequency", "TcpDelAckTicks", "TcpNoDelay", "SackOpts", "MaxFreeTcbs", "MaxHashTableSize", "DisableTaskOffload", "EnableWsd", "Tcp1323Opts", "TcpMaxDataRetransmissions", "KeepAliveTime", "KeepAliveInterval")
  $tcpBackup = @{}
  foreach ($k in $tcpKeys) { $tcpBackup[$k] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" $k }
  $backup["TCP"] = $tcpBackup
    
  # --- DNS Cache ---
  $dnsKeys = @("CacheHashTableBucketSize", "CacheHashTableSize", "MaxCacheEntryTtlLimit", "MaxSOACacheEntryTtlLimit", "NegativeCacheTtl")
  $dnsBackup = @{}
  foreach ($k in $dnsKeys) { $dnsBackup[$k] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" $k }
  $backup["DNS"] = $dnsBackup
    
  # --- Netsh TCP Global ---
  try {
    $tcpGlobalOutput = netsh int tcp show global 2>$null | Out-String
    $backup["NetshTcpGlobal"] = $tcpGlobalOutput
  }
  catch { $backup["NetshTcpGlobal"] = "" }
    
  # --- NVIDIA/AMD/DirectX ---
  $nvKeys = @("Shim_mccompat", "FXAA_Enable", "PowerMizerMode", "PerfLevelSrc")
  $nvBackup = @{}
  foreach ($k in $nvKeys) { $nvBackup[$k] = Get-RegistryValue "HKCU:\Software\NVIDIA Corporation\Global\NVTweak" $k }
  $backup["NVIDIA"] = $nvBackup
  $backup["AMD_CSFF"] = Get-RegistryValue "HKCU:\Software\AMD\CN" "CSFF"
    
  # --- MMCSS ---
  $mmBase = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
  $backup["MMCSS_SystemResponsiveness"] = Get-RegistryValue $mmBase "SystemResponsiveness"
  $backup["MMCSS_NetworkThrottlingIndex"] = Get-RegistryValue $mmBase "NetworkThrottlingIndex"
  $mmGamesKeys = @("Scheduling Category", "Priority", "GPU Priority", "Clock Rate", "SFIO Priority", "Affinity", "Background Only")
  $gamesBackup = @{}
  foreach ($k in $mmGamesKeys) { $gamesBackup[$k] = Get-RegistryValue "$mmBase\Tasks\Games" $k }
  $backup["MMCSS_Games"] = $gamesBackup
  $audioBackup = @{}
  $mmAudioKeys = @("Clock Rate", "GPU Priority", "Priority", "Scheduling Category", "SFIO Priority")
  foreach ($k in $mmAudioKeys) { $audioBackup[$k] = Get-RegistryValue "$mmBase\Tasks\Audio" $k }
  $backup["MMCSS_Audio"] = $audioBackup
    
  # --- GPU Scheduler ---
  $backup["GPU_HwSchMode"] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "HwSchMode"
  $backup["GPU_VsyncIdleTimeout"] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" "VsyncIdleTimeout"
  $backup["GPU_EnableCudaPriority"] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" "EnableCudaPriority"
  $backup["DX_MaxFrameLatency"] = Get-RegistryValue "HKLM:\SOFTWARE\Microsoft\DirectX" "MaxFrameLatency"
  $backup["DX_SwapEffectUpgrade"] = Get-RegistryValue "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences" "SwapEffectUpgrade"
  $backup["DX_DirectXUserGlobalSettings"] = Get-RegistryValue "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences" "DirectXUserGlobalSettings"
  $backup["DWM_SuperResolution"] = Get-RegistryValue "HKCU:\Software\Microsoft\Windows\DWM" "SuperResolution"
  $backup["DWM_OverlayTestMode"] = Get-RegistryValue "HKCU:\Software\Microsoft\Windows\DWM" "OverlayTestMode"
    
  # --- CPU Core Parking ---
  $parkPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583"
  $backup["CoreParking_ValueMax"] = Get-RegistryValue $parkPath "ValueMax"
  $backup["CoreParking_ValueMin"] = Get-RegistryValue $parkPath "ValueMin"
    
  # --- Game Bar / GameDVR ---
  $gbKeys = @("AllowAutoGameMode", "AutoGameModeEnabled")
  $gbBackup = @{}
  foreach ($k in $gbKeys) { $gbBackup[$k] = Get-RegistryValue "HKCU:\Software\Microsoft\GameBar" $k }
  $backup["GameBar"] = $gbBackup
  $gsKeys = @("GameDVR_Enabled", "GameDVR_FSEBehavior", "GameDVR_FSEBehaviorMode", "GameDVR_HonorUserFSEBehaviorMode")
  $gsBackup = @{}
  foreach ($k in $gsKeys) { $gsBackup[$k] = Get-RegistryValue "HKCU:\System\GameConfigStore" $k }
  $backup["GameConfigStore"] = $gsBackup
  $backup["GameDVR_AllowGameDVR"] = Get-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR"
  $backup["GameDVR_AppCaptureEnabled"] = Get-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "AppCaptureEnabled"
    
  # --- Mouse ---
  $mouseKeys = @("MouseSpeed", "MouseThreshold1", "MouseThreshold2", "MouseSensitivity", "SmoothMouseXCurve", "SmoothMouseYCurve", "MouseTrails")
  $mouseBackup = @{}
  foreach ($k in $mouseKeys) { $mouseBackup[$k] = Get-RegistryValue "HKCU:\Control Panel\Mouse" $k }
  $backup["Mouse"] = $mouseBackup
  $backup["MouseDataQueueSize"] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "MouseDataQueueSize"
  $backup["MouseDataThrottleSize"] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "MouseDataThrottleSize"
  $backup["mouclass_Wpp"] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "WppRecorder_UseTimeStamp"
  $backup["mouhid_Wpp"] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Services\mouhid\Parameters" "WppRecorder_UseTimeStamp"
    
  # --- Keyboard ---
  $kbKeys = @("KeyboardDelay", "KeyboardSpeed")
  $kbBackup = @{}
  foreach ($k in $kbKeys) { $kbBackup[$k] = Get-RegistryValue "HKCU:\Control Panel\Keyboard" $k }
  $backup["Keyboard"] = $kbBackup
  $backup["KbDataQueueSize"] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" "KeyboardDataQueueSize"
  $backup["kbdclass_Wpp"] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" "WppRecorder_UseTimeStamp"
  $backup["kbdhid_Wpp"] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Services\kbdhid\Parameters" "WppRecorder_UseTimeStamp"
  $accKeys = @("AutoRepeatDelay", "AutoRepeatRate", "DelayBeforeAcceptance", "Flags", "BounceTime")
  $accBackup = @{}
  foreach ($k in $accKeys) { $accBackup[$k] = Get-RegistryValue "HKCU:\Control Panel\Accessibility\Keyboard Response" $k }
  $backup["KeyboardAccessibility"] = $accBackup
  $backup["StickyKeys_Flags"] = Get-RegistryValue "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags"
  $backup["ToggleKeys_Flags"] = Get-RegistryValue "HKCU:\Control Panel\Accessibility\ToggleKeys" "Flags"
    
  # --- Timer ---
  $backup["GlobalTimerResolutionRequests"] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "GlobalTimerResolutionRequests"
    
  # --- Services ---
  $svcNames = @("DiagTrack", "dmwappushservice", "WerSvc", "MapsBroker", "RetailDemo", "TabletInputService", "Fax", "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "SysMain", "WSearch", "AxInstSV", "lfsvc", "PhoneSvc")
  $svcBackup = @{}
  foreach ($svc in $svcNames) {
    $s = Get-Service -Name $svc -EA SilentlyContinue
    if ($s) {
      $svcBackup[$svc] = @{ StartType = $s.StartType.ToString(); Status = $s.Status.ToString() }
    }
  }
  $backup["Services"] = $svcBackup
    
  # --- Memory Management ---
  $memKeys = @("DisablePagingExecutive", "LargeSystemCache", "SecondLevelDataCache", "IoPageLockLimit", "NonPagedPoolSize", "PagedPoolSize", "PoolUsageMaximum")
  $memBackup = @{}
  foreach ($k in $memKeys) { $memBackup[$k] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" $k }
  $backup["Memory"] = $memBackup
  $pfKeys = @("EnablePrefetcher", "EnableSuperfetch")
  $pfBackup = @{}
  foreach ($k in $pfKeys) { $pfBackup[$k] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" $k }
  $backup["Prefetch"] = $pfBackup
    
  # --- Visual Effects ---
  $backup["EnableTransparency"] = Get-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency"
  $backup["VisualFXSetting"] = Get-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting"
  $backup["AllowCortana"] = Get-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana"
    
  # --- Memory Compression ---
  try {
    $mmAgent = Get-MMAgent -EA SilentlyContinue
    $backup["MemoryCompression"] = $mmAgent.MemoryCompression
  }
  catch { $backup["MemoryCompression"] = $true }
    
  # --- Priority Control ---
  $pcKeys = @("Win32PrioritySeparation", "IRQ8Priority", "IRQ16Priority")
  $pcBackup = @{}
  foreach ($k in $pcKeys) { $pcBackup[$k] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" $k }
  $backup["PriorityControl"] = $pcBackup

  # --- File System ---
  $fsKeys = @("NtfsMftZoneReservation", "NTFSDisable8dot3NameCreation", "DontVerifyRandomDrivers", "NTFSDisableLastAccessUpdate", "ContigFileAllocSize")
  $fsBackup = @{}
  foreach ($k in $fsKeys) { $fsBackup[$k] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" $k }
  $backup["FileSystem"] = $fsBackup

  # --- Desktop Responsiveness ---
  $dtKeys = @("AutoEndTasks", "MenuShowDelay", "WaitToKillAppTimeout", "WaitToKillServiceTimeout", "HungAppTimeout", "LowLevelHooksTimeout", "ForegroundLockTimeout")
  $dtBackup = @{}
  foreach ($k in $dtKeys) { $dtBackup[$k] = Get-RegistryValue "HKCU:\Control Panel\Desktop" $k }
  $backup["Desktop"] = $dtBackup



  # --- Game fluid ---
  $gfKeys = @("FpsAll", "GameFluidity")
  $gfBackup = @{}
  foreach ($k in $gfKeys) { $gfBackup[$k] = Get-RegistryValue "HKCU:\SOFTWARE\Microsoft\Games" $k }
  $backup["GamesConfig"] = $gfBackup

  # Save to JSON
  $timestamp = [DateTime]::Now.ToString("yyyyMMdd_HHmmss")
  $backupFile = Join-Path $script:BackupFolder "backup_$timestamp.json"
  $backup | ConvertTo-Json -Depth 5 | Set-Content -Path $backupFile -Encoding UTF8 -Force
    
  # Keep only last 5 backups
  $allBackups = Get-ChildItem -Path $script:BackupFolder -Filter "backup_*.json" | Sort-Object Name -Descending
  if ($allBackups.Count -gt 5) {
    $allBackups | Select-Object -Skip 5 | Remove-Item -Force -EA SilentlyContinue
  }
    
  return $backupFile
}

function Get-LatestBackupFile {
  if (!(Test-Path $script:BackupFolder)) { return $null }
  $latest = Get-ChildItem -Path $script:BackupFolder -Filter "backup_*.json" | Sort-Object Name -Descending | Select-Object -First 1
  if ($latest) { return $latest.FullName }
  return $null
}

function Set-RegistryFromBackup {
  param([string]$Path, [string]$Name, $Entry)
  try {
    if ($null -eq $Entry -or $Entry.Exists -eq $false) {
      # Value didn't exist before - remove it
      if (Test-Path $Path) {
        Remove-ItemProperty -Path $Path -Name $Name -Force -EA SilentlyContinue
      }
      return
    }
    if (!(Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    $kindMap = @{ "DWord" = "DWord"; "QWord" = "QWord"; "String" = "String"; "ExpandString" = "ExpandString"; "MultiString" = "MultiString"; "Binary" = "Binary" }
    $regType = if ($kindMap.ContainsKey($Entry.Kind)) { $kindMap[$Entry.Kind] } else { "String" }
        
    if ($regType -eq "Binary" -and $Entry.Value -is [System.Array]) {
      Set-ItemProperty -Path $Path -Name $Name -Value ([byte[]]$Entry.Value) -Type Binary -Force
    }
    else {
      Set-ItemProperty -Path $Path -Name $Name -Value $Entry.Value -Type $regType -Force
    }
  }
  catch { }
}

function Restore-OriginalSettings {
  param([string]$BackupFile)
    
  $backup = Get-Content -Path $BackupFile -Raw -Encoding UTF8 | ConvertFrom-Json
    
  Log-Write "[ RESTORE ] Loading backup: $($backup.Timestamp)"
    
  # --- Power Plan ---
  Log-Write "[ RESTORE 1 ] Restoring Power Plan..."
  if ($backup.ActivePowerPlanGuid) {
    powercfg /setactive $backup.ActivePowerPlanGuid 2>$null | Out-Null
    Log-Write "   -> Active power plan restored."
  }
  # Remove custom FiveM power plan
  $fivemGuid = "8c5e7fda-e8bf-45a1-aff5-e1fbb3b5edd0"
  powercfg /delete $fivemGuid 2>$null | Out-Null
    
  # --- QoS ---
  Log-Write "[ RESTORE 2 ] Restoring Network Stack..."
  Set-RegistryFromBackup "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched" "NonBestEffortLimit" $backup.QoS_NonBestEffortLimit
    
  # --- AFD ---
  if ($backup.AFD) {
    $backup.AFD.PSObject.Properties | ForEach-Object {
      Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters" $_.Name $_.Value
    }
  }
    
  # --- TCP ---
  if ($backup.TCP) {
    $backup.TCP.PSObject.Properties | ForEach-Object {
      Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" $_.Name $_.Value
    }
  }
    
  # --- TCP Interface-level (remove custom values) ---
  $ifPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
  Get-ChildItem -Path $ifPath -EA SilentlyContinue | ForEach-Object {
    Remove-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Force -EA SilentlyContinue
    Remove-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Force -EA SilentlyContinue
    Remove-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks" -Force -EA SilentlyContinue
    Remove-ItemProperty -Path $_.PSPath -Name "TcpInitialRTT" -Force -EA SilentlyContinue
  }
    
  # --- DNS ---
  if ($backup.DNS) {
    $backup.DNS.PSObject.Properties | ForEach-Object {
      Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" $_.Name $_.Value
    }
  }
    
  # --- Netsh TCP Global reset ---
  netsh int tcp set global autotuninglevel=normal 2>$null | Out-Null
  netsh int tcp set global ecncapability=default 2>$null | Out-Null
  netsh int tcp set global timestamps=default 2>$null | Out-Null
  netsh int tcp set global rsc=default 2>$null | Out-Null
  netsh int tcp set global congestionprovider=default 2>$null | Out-Null
  netsh int tcp set global initialRto=3000 2>$null | Out-Null
  # --- Net Adapter restore defaults ---
  Get-NetAdapter -EA SilentlyContinue | ForEach-Object {
    $na = $_.Name
    Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*FlowControl" -RegistryValue 3 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*InterruptModeration" -RegistryValue 1 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*EEE" -RegistryValue 1 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "EEELinkAdvertisement" -RegistryValue 1 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "GreenEthernet" -RegistryValue 1 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "GreenEth" -RegistryValue 1 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "AutoPowerSaveMode" -RegistryValue 1 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*ReceiveBuffers" -RegistryValue 512 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*TransmitBuffers" -RegistryValue 512 -EA SilentlyContinue
    Enable-NetAdapterPowerManagement -Name $na -EA SilentlyContinue
  }
  Log-Write "   -> Network/TCP/DNS/AFD and Network Adapter defaults restored."
    
  # --- NVIDIA/AMD ---
  Log-Write "[ RESTORE 3 ] Restoring GPU Settings..."
  if ($backup.NVIDIA) {
    $backup.NVIDIA.PSObject.Properties | ForEach-Object {
      Set-RegistryFromBackup "HKCU:\Software\NVIDIA Corporation\Global\NVTweak" $_.Name $_.Value
    }
  }
  if ($backup.AMD_CSFF) {
    Set-RegistryFromBackup "HKCU:\Software\AMD\CN" "CSFF" $backup.AMD_CSFF
  }
  # Remove AMD GodMode tweaks
  $amdPaths = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -ErrorAction SilentlyContinue
  foreach ($ap in $amdPaths) {
    if ($ap.PSChildName -match "^\d{4}$") {
      Remove-ItemProperty -Path $ap.PSPath -Name "PP_AllPhonesPowerDownLimit" -Force -EA SilentlyContinue
      Remove-ItemProperty -Path $ap.PSPath -Name "StutterMode" -Force -EA SilentlyContinue
    }
  }
    
  # --- GPU Scheduler ---
  Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "HwSchMode" $backup.GPU_HwSchMode
  Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" "VsyncIdleTimeout" $backup.GPU_VsyncIdleTimeout
  Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" "EnableCudaPriority" $backup.GPU_EnableCudaPriority
  Set-RegistryFromBackup "HKLM:\SOFTWARE\Microsoft\DirectX" "MaxFrameLatency" $backup.DX_MaxFrameLatency
  Set-RegistryFromBackup "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences" "SwapEffectUpgrade" $backup.DX_SwapEffectUpgrade
  Set-RegistryFromBackup "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences" "DirectXUserGlobalSettings" $backup.DX_DirectXUserGlobalSettings
  Set-RegistryFromBackup "HKCU:\Software\Microsoft\Windows\DWM" "SuperResolution" $backup.DWM_SuperResolution
  Set-RegistryFromBackup "HKCU:\Software\Microsoft\Windows\DWM" "OverlayTestMode" $backup.DWM_OverlayTestMode
  Log-Write "   -> GPU/Graphics restored."
    
  # --- MMCSS ---
  Log-Write "[ RESTORE 4 ] Restoring MMCSS..."
  $mmBase = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
  Set-RegistryFromBackup $mmBase "SystemResponsiveness" $backup.MMCSS_SystemResponsiveness
  Set-RegistryFromBackup $mmBase "NetworkThrottlingIndex" $backup.MMCSS_NetworkThrottlingIndex
  if ($backup.MMCSS_Games) {
    $backup.MMCSS_Games.PSObject.Properties | ForEach-Object {
      Set-RegistryFromBackup "$mmBase\Tasks\Games" $_.Name $_.Value
    }
  }
  if ($backup.MMCSS_Audio) {
    $backup.MMCSS_Audio.PSObject.Properties | ForEach-Object {
      Set-RegistryFromBackup "$mmBase\Tasks\Audio" $_.Name $_.Value
    }
  }
  Log-Write "   -> MMCSS priority restored."
    
  # --- Core Parking ---
  Log-Write "[ RESTORE 5 ] Restoring CPU/Power Settings..."
  $parkPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583"
  Set-RegistryFromBackup $parkPath "ValueMax" $backup.CoreParking_ValueMax
  Set-RegistryFromBackup $parkPath "ValueMin" $backup.CoreParking_ValueMin
  Log-Write "   -> CPU core parking restored."
    
  # --- Process Priority (remove FiveM/GTA entries) ---
  Log-Write "[ RESTORE 6 ] Removing Process Priority overrides..."
  $gtaProcs = @("FiveM_b2060_GTAProcess.exe", "FiveM_b2189_GTAProcess.exe", "FiveM_b2545_GTAProcess.exe", "FiveM_b2699_GTAProcess.exe", "FiveM_b2802_GTAProcess.exe", "FiveM_b2944_GTAProcess.exe", "FiveM_b3095_GTAProcess.exe", "FiveM_GTAProcess.exe", "GTA5.exe", "gtav.exe")
  $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
  foreach ($proc in $gtaProcs) {
    $path = "$registryPath\$proc"
    if (Test-Path $path) { Remove-Item -Path $path -Recurse -Force -EA SilentlyContinue }
  }
  Log-Write "   -> Process priority overrides removed."
    
  # --- Game Bar / GameDVR ---
  Log-Write "[ RESTORE 7 ] Restoring Game Mode settings..."
  if ($backup.GameBar) {
    $backup.GameBar.PSObject.Properties | ForEach-Object {
      Set-RegistryFromBackup "HKCU:\Software\Microsoft\GameBar" $_.Name $_.Value
    }
  }
  if ($backup.GameConfigStore) {
    $backup.GameConfigStore.PSObject.Properties | ForEach-Object {
      Set-RegistryFromBackup "HKCU:\System\GameConfigStore" $_.Name $_.Value
    }
  }
  Set-RegistryFromBackup "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR" $backup.GameDVR_AllowGameDVR
  Set-RegistryFromBackup "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "AppCaptureEnabled" $backup.GameDVR_AppCaptureEnabled
  Log-Write "   -> Game Mode/DVR restored."
    
  # --- Mouse ---
  Log-Write "[ RESTORE 8 ] Restoring Mouse settings..."
  if ($backup.Mouse) {
    $backup.Mouse.PSObject.Properties | ForEach-Object {
      Set-RegistryFromBackup "HKCU:\Control Panel\Mouse" $_.Name $_.Value
    }
  }
  Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "MouseDataQueueSize" $backup.MouseDataQueueSize
  Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "MouseDataThrottleSize" $backup.MouseDataThrottleSize
  Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "WppRecorder_UseTimeStamp" $backup.mouclass_Wpp
  Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Services\mouhid\Parameters" "WppRecorder_UseTimeStamp" $backup.mouhid_Wpp
  Log-Write "   -> Mouse settings restored."
    
  # --- Keyboard ---
  Log-Write "[ RESTORE 9 ] Restoring Keyboard settings..."
  if ($backup.Keyboard) {
    $backup.Keyboard.PSObject.Properties | ForEach-Object {
      Set-RegistryFromBackup "HKCU:\Control Panel\Keyboard" $_.Name $_.Value
    }
  }
  Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" "KeyboardDataQueueSize" $backup.KbDataQueueSize
  Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" "WppRecorder_UseTimeStamp" $backup.kbdclass_Wpp
  Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Services\kbdhid\Parameters" "WppRecorder_UseTimeStamp" $backup.kbdhid_Wpp
  if ($backup.KeyboardAccessibility) {
    $backup.KeyboardAccessibility.PSObject.Properties | ForEach-Object {
      Set-RegistryFromBackup "HKCU:\Control Panel\Accessibility\Keyboard Response" $_.Name $_.Value
    }
  }
  Set-RegistryFromBackup "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" $backup.StickyKeys_Flags
  Set-RegistryFromBackup "HKCU:\Control Panel\Accessibility\ToggleKeys" "Flags" $backup.ToggleKeys_Flags
  Log-Write "   -> Keyboard settings restored."
    
  # --- Timer ---
  Log-Write "[ RESTORE 10 ] Restoring Timer Resolution..."
  Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "GlobalTimerResolutionRequests" $backup.GlobalTimerResolutionRequests
  bcdedit /deletevalue disabledynamictick 2>$null | Out-Null
  bcdedit /deletevalue useplatformtick 2>$null | Out-Null
  bcdedit /deletevalue tscsyncpolicy 2>$null | Out-Null
  Log-Write "   -> Timer settings restored."
    
  # --- DPC/ISR ---
  Log-Write "[ RESTORE 11 ] Restoring DPC/ISR settings..."
  bcdedit /deletevalue useplatformclock 2>$null | Out-Null
  if ($backup.MemoryCompression -eq $true) {
    Enable-MMAgent -MemoryCompression -EA SilentlyContinue | Out-Null
  }
  # Re-enable network adapter power management and restore defaults
  Get-NetAdapter -EA SilentlyContinue | ForEach-Object {
    Enable-NetAdapterPowerManagement -Name $_.Name -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*InterruptModeration" -RegistryValue 1 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*FlowControl" -RegistryValue 3 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "RxIntCoalesce" -RegistryValue 1 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "TxIntCoalesce" -RegistryValue 1 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*ReceiveBuffers" -RegistryValue 512 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*TransmitBuffers" -RegistryValue 512 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*LsoV2IPv4" -RegistryValue 1 -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*LsoV2IPv6" -RegistryValue 1 -EA SilentlyContinue
  }
  Log-Write "   -> DPC/ISR defaults restored."
    
  # --- Services ---
  Log-Write "[ RESTORE 12 ] Restoring Services..."
  if ($backup.Services) {
    $restoredCount = 0
    $backup.Services.PSObject.Properties | ForEach-Object {
      $svcName = $_.Name
      $svcInfo = $_.Value
      try {
        $startTypeMap = @{ "Automatic" = "Automatic"; "Manual" = "Manual"; "Disabled" = "Disabled"; "Boot" = "Automatic"; "System" = "Automatic" }
        $startType = if ($startTypeMap.ContainsKey($svcInfo.StartType)) { $startTypeMap[$svcInfo.StartType] } else { "Manual" }
        Set-Service -Name $svcName -StartupType $startType -EA SilentlyContinue
        if ($svcInfo.Status -eq "Running") {
          Start-Service -Name $svcName -EA SilentlyContinue
        }
        $restoredCount++
      }
      catch { }
    }
    Log-Write "   -> $restoredCount services restored."
  }
    
  # --- Memory Management ---
  Log-Write "[ RESTORE 13 ] Restoring Memory settings..."
  if ($backup.Memory) {
    $backup.Memory.PSObject.Properties | ForEach-Object {
      Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" $_.Name $_.Value
    }
  }
  if ($backup.Prefetch) {
    $backup.Prefetch.PSObject.Properties | ForEach-Object {
      Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" $_.Name $_.Value
    }
  }
  Log-Write "   -> Memory/Paging settings restored."
    
  # --- Visual Effects ---
  Set-RegistryFromBackup "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" $backup.EnableTransparency
  Set-RegistryFromBackup "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" $backup.VisualFXSetting
  Set-RegistryFromBackup "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana" $backup.AllowCortana
    
  # --- Priority Control ---
  if ($backup.PriorityControl) {
    $backup.PriorityControl.PSObject.Properties | ForEach-Object {
      Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" $_.Name $_.Value
    }
  }

  # --- File System ---
  if ($backup.FileSystem) {
    $backup.FileSystem.PSObject.Properties | ForEach-Object {
      Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" $_.Name $_.Value
    }
  }

  # --- Desktop Responsiveness ---
  if ($backup.Desktop) {
    $backup.Desktop.PSObject.Properties | ForEach-Object {
      Set-RegistryFromBackup "HKCU:\Control Panel\Desktop" $_.Name $_.Value
    }
  }

  # --- GPU Scheduler Vsync ---
  if ($backup.GPU_VsyncIdleTimeout) {
    Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" "VsyncIdleTimeout" $backup.GPU_VsyncIdleTimeout
  }

  # --- Games Config ---
  if ($backup.GamesConfig) {
    $backup.GamesConfig.PSObject.Properties | ForEach-Object {
      Set-RegistryFromBackup "HKCU:\SOFTWARE\Microsoft\Games" $_.Name $_.Value
    }
  }

  # --- Remove Scheduled Task ---
  Log-Write "[ RESTORE 14 ] Removing Combat Daemon..."
  Unregister-ScheduledTask -TaskName "FiveM_Combat_Boost_Daemon" -Confirm:$false -EA SilentlyContinue | Out-Null
  $daemonFile = "$env:LOCALAPPDATA\FiveM_Combat_Daemon.ps1"
  if (Test-Path $daemonFile) { Remove-Item -Path $daemonFile -Force -EA SilentlyContinue }
  Log-Write "   -> Combat Daemon task removed."
    
  Log-Write "=========================================="
  Log-Write " ALL SETTINGS RESTORED SUCCESSFULLY!"
  Log-Write " REBOOT recommended for full effect."
  Log-Write "=========================================="
}

# ========== SYSTEM ANALYSIS FUNCTION ==========
function Get-SystemSpecs {
  $specs = @{
    CPU             = $null
    Cores           = 0
    Threads         = 0
    RAM             = 0
    GPU             = $null
    VRAM            = 0
    Score           = 0
    RecommendedMode = "Mode5"
  }

  try {
    # CPU Info
    $cpu = Get-CimInstance -ClassName Win32_Processor
    $specs.CPU = $cpu.Name
    $specs.Cores = $cpu.NumberOfCores
    $specs.Threads = $cpu.NumberOfLogicalProcessors

    # RAM Info
    $ram = Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
    $specs.RAM = [math]::Round(($ram.Sum / 1GB), 2)

    # GPU Info
    $gpu = Get-CimInstance -ClassName Win32_VideoController | Where-Object { $_.Name -notlike "*Basic*" -and $_.Name -notlike "*Microsoft*" } | Select-Object -First 1
    if ($gpu) {
      $specs.GPU = $gpu.Name
      $specs.VRAM = [math]::Round(($gpu.AdapterRAM / 1GB), 2)
    }
  }
  catch {
    # Fallback if WMI fails
    $specs.CPU = "Unknown"
    $specs.Cores = 4
    $specs.Threads = 4
    $specs.RAM = 8
    $specs.GPU = "Unknown"
    $specs.VRAM = 2
  }

  # Calculate system score and recommend mode
  $score = 0
  
  # CPU Score (max 30)
  if ($specs.Threads -ge 16) { $score += 30 }
  elseif ($specs.Threads -ge 12) { $score += 25 }
  elseif ($specs.Threads -ge 8) { $score += 20 }
  elseif ($specs.Threads -ge 6) { $score += 15 }
  elseif ($specs.Threads -ge 4) { $score += 10 }
  else { $score += 5 }

  # RAM Score (max 30)
  if ($specs.RAM -ge 32) { $score += 30 }
  elseif ($specs.RAM -ge 24) { $score += 25 }
  elseif ($specs.RAM -ge 16) { $score += 20 }
  elseif ($specs.RAM -ge 12) { $score += 15 }
  elseif ($specs.RAM -ge 8) { $score += 10 }
  else { $score += 5 }

  # VRAM Score (max 40)
  if ($specs.VRAM -ge 12) { $score += 40 }
  elseif ($specs.VRAM -ge 8) { $score += 35 }
  elseif ($specs.VRAM -ge 6) { $score += 30 }
  elseif ($specs.VRAM -ge 4) { $score += 25 }
  elseif ($specs.VRAM -ge 3) { $score += 20 }
  elseif ($specs.VRAM -ge 2) { $score += 15 }
  else { $score += 10 }

  $specs.Score = $score

  # Recommend mode based on score
  if ($score -ge 90) { $specs.RecommendedMode = "Mode10" }
  elseif ($score -ge 80) { $specs.RecommendedMode = "Mode9" }
  elseif ($score -ge 70) { $specs.RecommendedMode = "Mode8" }
  elseif ($score -ge 60) { $specs.RecommendedMode = "Mode7" }
  elseif ($score -ge 50) { $specs.RecommendedMode = "Mode6" }
  elseif ($score -ge 40) { $specs.RecommendedMode = "Mode5" }
  elseif ($score -ge 30) { $specs.RecommendedMode = "Mode4" }
  elseif ($score -ge 20) { $specs.RecommendedMode = "Mode3" }
  elseif ($score -ge 10) { $specs.RecommendedMode = "Mode2" }
  else { $specs.RecommendedMode = "Mode1" }

  return $specs
}



[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="AllSetting x FiveM" Height="650" Width="1050"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize"
        WindowStyle="None" AllowsTransparency="True" Background="Transparent">

  <Window.Resources>
    <DropShadowEffect x:Key="NeonGlow" BlurRadius="18" Color="#00A3FF" ShadowDepth="0" Opacity="0.5"/>
    <DropShadowEffect x:Key="PanelGlow" BlurRadius="35" Color="#000000" ShadowDepth="0" Opacity="0.85"/>
    <DropShadowEffect x:Key="GoldGlow" BlurRadius="18" Color="#FFD700" ShadowDepth="0" Opacity="0.5"/>
    <DropShadowEffect x:Key="PurpleGlow" BlurRadius="18" Color="#9B59B6" ShadowDepth="0" Opacity="0.5"/>
    <DropShadowEffect x:Key="GreenGlow" BlurRadius="18" Color="#2ECC71" ShadowDepth="0" Opacity="0.5"/>
    <DropShadowEffect x:Key="RedGlow" BlurRadius="18" Color="#E74C3C" ShadowDepth="0" Opacity="0.5"/>
    <DropShadowEffect x:Key="SoftGlow" BlurRadius="12" Color="#FFFFFF" ShadowDepth="0" Opacity="0.25"/>
    <DropShadowEffect x:Key="TealGlow" BlurRadius="18" Color="#00FFA3" ShadowDepth="0" Opacity="0.5"/>
    <DropShadowEffect x:Key="OrangeGlow" BlurRadius="18" Color="#FF6B35" ShadowDepth="0" Opacity="0.5"/>

    <!-- Custom Scrollbar Template -->
    <Style TargetType="{x:Type RepeatButton}" x:Key="ScrollButton">
      <Setter Property="OverridesDefaultStyle" Value="true"/>
      <Setter Property="Focusable" Value="false"/>
      <Setter Property="IsTabStop" Value="false"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="{x:Type RepeatButton}">
            <Border Background="Transparent" />
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="{x:Type Thumb}" x:Key="ScrollThumb">
      <Setter Property="OverridesDefaultStyle" Value="true"/>
      <Setter Property="IsTabStop" Value="false"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="{x:Type Thumb}">
            <Border x:Name="rectangle" CornerRadius="3" Background="#20FFFFFF" Width="5" Height="Auto" />
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="true">
                <Setter TargetName="rectangle" Property="Background" Value="#40FFFFFF"/>
                <Setter TargetName="rectangle" Property="Width" Value="6"/>
              </Trigger>
              <Trigger Property="IsDragging" Value="true">
                <Setter TargetName="rectangle" Property="Background" Value="#8000A3FF"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="{x:Type ScrollBar}">
      <Setter Property="Background" Value="Transparent"/>
      <Setter Property="Width" Value="6"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="{x:Type ScrollBar}">
            <Grid x:Name="Bg" SnapsToDevicePixels="true" Background="Transparent">
              <Track x:Name="PART_Track" IsDirectionReversed="true" IsEnabled="{TemplateBinding IsEnabled}">
                <Track.DecreaseRepeatButton>
                  <RepeatButton Command="ScrollBar.PageUpCommand" Style="{StaticResource ScrollButton}"/>
                </Track.DecreaseRepeatButton>
                <Track.Thumb>
                  <Thumb Style="{StaticResource ScrollThumb}"/>
                </Track.Thumb>
                <Track.IncreaseRepeatButton>
                  <RepeatButton Command="ScrollBar.PageDownCommand" Style="{StaticResource ScrollButton}"/>
                </Track.IncreaseRepeatButton>
              </Track>
            </Grid>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
  </Window.Resources>

  <Border CornerRadius="24" BorderThickness="1.5" Effect="{StaticResource PanelGlow}">
    <Border.BorderBrush>
      <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
        <GradientStop Color="#2000A3FF" Offset="0"/>
        <GradientStop Color="#0800A3FF" Offset="0.5"/>
        <GradientStop Color="#1500A3FF" Offset="1"/>
      </LinearGradientBrush>
    </Border.BorderBrush>
    <Border.Background>
      <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
        <GradientStop Color="#06080C" Offset="0.0"/>
        <GradientStop Color="#0B0F16" Offset="0.5"/>
        <GradientStop Color="#070A0F" Offset="1.0"/>
      </LinearGradientBrush>
    </Border.Background>

    <Grid>
      <Grid.RowDefinitions>
        <RowDefinition Height="48"/>
        <RowDefinition Height="*"/>
      </Grid.RowDefinitions>

      <!-- ==================== HEADER BAR ==================== -->
      <Grid Name="HeaderBar" Grid.Row="0" Background="Transparent" Cursor="SizeAll">
        <Border Height="1" VerticalAlignment="Bottom">
          <Border.Background>
            <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
              <GradientStop Color="#0000A3FF" Offset="0"/>
              <GradientStop Color="#2500A3FF" Offset="0.5"/>
              <GradientStop Color="#0000A3FF" Offset="1"/>
            </LinearGradientBrush>
          </Border.Background>
        </Border>

        <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="22,0,0,0">
          <Path Data="M 13,2 L 5,11 L 11,11 L 7,18 L 15,9 L 9,9 Z" Fill="#00A3FF" Width="14" Height="14" Stretch="Uniform" Margin="0,0,8,0" VerticalAlignment="Center">
            <Path.Effect>
              <DropShadowEffect BlurRadius="8" Color="#00A3FF" ShadowDepth="0" Opacity="0.7"/>
            </Path.Effect>
          </Path>
          <TextBlock Text="MINISHAWTY" FontSize="13" FontWeight="Bold" Foreground="#00A3FF" VerticalAlignment="Center">
            <TextBlock.Effect>
              <DropShadowEffect BlurRadius="6" Color="#00A3FF" ShadowDepth="0" Opacity="0.35"/>
            </TextBlock.Effect>
          </TextBlock>
          <TextBlock Text=" PROJECT" FontSize="13" FontWeight="Normal" Foreground="#55FFFFFF" VerticalAlignment="Center"/>
          <Border CornerRadius="4" Background="#0800A3FF" BorderBrush="#1800A3FF" BorderThickness="1" Padding="7,2" Margin="10,0,0,0" VerticalAlignment="Center">
            <TextBlock Text="v6.0" FontSize="8" FontWeight="Bold" Foreground="#4000A3FF"/>
          </Border>
        </StackPanel>

        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,16,0">
          <Button Name="BtnMinimize" Width="36" Height="32" Background="Transparent" BorderBrush="Transparent" Margin="0,0,4,0">
            <Button.Template>
              <ControlTemplate TargetType="Button">
                <Border x:Name="Bg" Background="Transparent" CornerRadius="6">
                  <Rectangle x:Name="Icon" Width="11" Height="1.5" Fill="#55FFFFFF" VerticalAlignment="Center" HorizontalAlignment="Center"/>
                </Border>
                <ControlTemplate.Triggers>
                  <Trigger Property="IsMouseOver" Value="True">
                    <Setter TargetName="Bg" Property="Background" Value="#1200A3FF"/>
                    <Setter TargetName="Icon" Property="Fill" Value="#00A3FF"/>
                  </Trigger>
                </ControlTemplate.Triggers>
              </ControlTemplate>
            </Button.Template>
          </Button>
          <Button Name="BtnClose" Width="36" Height="32" Background="Transparent" BorderBrush="Transparent">
            <Button.Template>
              <ControlTemplate TargetType="Button">
                <Border x:Name="Bg" Background="Transparent" CornerRadius="6">
                  <Path x:Name="Icon" Data="M 2,2 L 10,10 M 10,2 L 2,10" Stroke="#55FFFFFF" StrokeThickness="1.5" Width="12" Height="12" Stretch="Uniform" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>
                <ControlTemplate.Triggers>
                  <Trigger Property="IsMouseOver" Value="True">
                    <Setter TargetName="Bg" Property="Background" Value="#FF4757"/>
                    <Setter TargetName="Icon" Property="Stroke" Value="#FFFFFF"/>
                  </Trigger>
                </ControlTemplate.Triggers>
              </ControlTemplate>
            </Button.Template>
          </Button>
        </StackPanel>
      </Grid>

      <Grid Grid.Row="1">

        <!-- ==================== LOGIN VIEW ==================== -->
        <Grid Name="ViewLogin" Visibility="Visible">
          <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
          </Grid.RowDefinitions>

          <StackPanel Grid.Row="1" HorizontalAlignment="Center" Width="420">
            <!-- Logo -->
            <Viewbox Width="72" Height="72" Margin="0,0,0,20" HorizontalAlignment="Center">
              <Grid>
                <Path Data="M 30,2 L 58,16 L 58,46 L 30,60 L 2,46 L 2,16 Z"
                      Stroke="#00FFD2" StrokeThickness="2.5" Fill="#0800FFD2">
                  <Path.Effect>
                    <DropShadowEffect BlurRadius="16" Color="#00FFD2" ShadowDepth="0" Opacity="0.7"/>
                  </Path.Effect>
                </Path>
                <Path Data="M 30,12 L 18,32 L 30,32 L 30,48 L 42,28 L 30,28 Z"
                      Fill="#00A3FF">
                  <Path.Effect>
                    <DropShadowEffect BlurRadius="18" Color="#00A3FF" ShadowDepth="0" Opacity="0.85"/>
                  </Path.Effect>
                </Path>
              </Grid>
            </Viewbox>

            <!-- Brand Title -->
            <TextBlock Text="MINISHAWTY PROJECT" FontSize="30" FontWeight="Bold" HorizontalAlignment="Center">
              <TextBlock.Foreground>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                  <GradientStop Color="#00A3FF" Offset="0.0"/>
                  <GradientStop Color="#00D4FF" Offset="0.5"/>
                  <GradientStop Color="#00FFA3" Offset="1.0"/>
                </LinearGradientBrush>
              </TextBlock.Foreground>
              <TextBlock.Effect>
                <DropShadowEffect BlurRadius="12" Color="#00A3FF" ShadowDepth="0" Opacity="0.4"/>
              </TextBlock.Effect>
            </TextBlock>
            <TextBlock Text="PERFORMANCE ENGINE v6.0" FontSize="11" FontWeight="Medium" Foreground="#45FFFFFF" HorizontalAlignment="Center" Margin="0,6,0,0"/>

            <!-- Accent Line -->
            <Border Height="2" Width="60" CornerRadius="1" Margin="0,22,0,0" HorizontalAlignment="Center">
              <Border.Background>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                  <GradientStop Color="#00A3FF" Offset="0"/>
                  <GradientStop Color="#00D4FF" Offset="1"/>
                </LinearGradientBrush>
              </Border.Background>
              <Border.Effect>
                <DropShadowEffect BlurRadius="10" Color="#00A3FF" ShadowDepth="0" Opacity="0.6"/>
              </Border.Effect>
            </Border>

            <!-- Access Key Label -->
            <TextBlock Text="ENTER ACCESS KEY" FontSize="10" FontWeight="Bold" Foreground="#6B8DA8" HorizontalAlignment="Center" Margin="0,28,0,14"/>

            <!-- Password Field -->
            <Grid Name="PassGrid" Height="50" Margin="0,0,0,16">
              <Border CornerRadius="25" BorderThickness="1.5" BorderBrush="#1800A3FF" Background="#0A0D12">
                <Border.Effect>
                  <DropShadowEffect BlurRadius="12" Color="#00A3FF" ShadowDepth="0" Opacity="0.15"/>
                </Border.Effect>
                <Grid>
                  <Path Data="M 6,3 L 6,9 M 3,6 L 3,9 L 9,9 L 9,6" Stroke="#3000A3FF" StrokeThickness="1.5" Width="14" Height="14" Stretch="Uniform" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="18,0,0,0"/>
                  <PasswordBox Name="PasswordBox" FontSize="14" FontWeight="Medium" Foreground="#F0F6FC"
                              Background="Transparent" BorderThickness="0" Padding="42,0,18,0"
                              VerticalAlignment="Center" HorizontalAlignment="Stretch"
                              PasswordChar="&#x25CF;"/>
                </Grid>
              </Border>
            </Grid>

            <!-- Login Button -->
            <Grid Name="BtnLoginGrid" Height="50">
              <Button Name="BtnLogin" Height="50" Cursor="Hand" Background="Transparent" BorderThickness="0">
                <Button.Effect>
                  <DropShadowEffect BlurRadius="20" Color="#00A3FF" ShadowDepth="0" Opacity="0.45"/>
                </Button.Effect>
                <Button.Template>
                  <ControlTemplate TargetType="Button">
                    <Border x:Name="Bd" CornerRadius="25" BorderThickness="0">
                      <Border.Background>
                        <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                          <GradientStop Color="#00A3FF" Offset="0.0"/>
                          <GradientStop Color="#00C8FF" Offset="0.5"/>
                          <GradientStop Color="#00D4FF" Offset="1.0"/>
                        </LinearGradientBrush>
                      </Border.Background>
                      <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center">
                        <Path Data="M 5,12 L 10,17 L 19,6" Stroke="#FFFFFF" StrokeThickness="2" Width="12" Height="12" Stretch="Uniform" Margin="0,0,8,0"/>
                        <TextBlock Text="AUTHENTICATE" FontSize="13" FontWeight="Bold" Foreground="#FFFFFF"/>
                      </StackPanel>
                    </Border>
                    <ControlTemplate.Triggers>
                      <Trigger Property="IsMouseOver" Value="True">
                        <Setter TargetName="Bd" Property="Effect">
                          <Setter.Value>
                            <DropShadowEffect BlurRadius="24" Color="#00D4FF" ShadowDepth="0" Opacity="0.5"/>
                          </Setter.Value>
                        </Setter>
                      </Trigger>
                    </ControlTemplate.Triggers>
                  </ControlTemplate>
                </Button.Template>
              </Button>
            </Grid>

            <!-- Login Progress -->
            <StackPanel Name="LoginProgContainer" Visibility="Collapsed" Margin="0,20,0,0">
              <TextBlock Name="LoginProgText" Text="Loading system modules..." FontSize="11" FontWeight="SemiBold" Foreground="#6B8DA8" HorizontalAlignment="Center" Margin="0,0,0,10"/>
              <ProgressBar Name="LoginProgBar" Height="6" Minimum="0" Maximum="100" Value="0" Background="#0D1117" BorderThickness="0">
                <ProgressBar.Foreground>
                  <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                    <GradientStop Color="#00A3FF" Offset="0.0"/>
                    <GradientStop Color="#00D4FF" Offset="1.0"/>
                  </LinearGradientBrush>
                </ProgressBar.Foreground>
                <ProgressBar.Effect>
                  <DropShadowEffect BlurRadius="8" Color="#00A3FF" ShadowDepth="0" Opacity="0.5"/>
                </ProgressBar.Effect>
              </ProgressBar>
            </StackPanel>
          </StackPanel>
        </Grid>

        <!-- ==================== MAIN VIEW ==================== -->
        <Grid Name="ViewMain" Visibility="Collapsed" Margin="14,8,14,14">
          <Grid.ColumnDefinitions>
            <ColumnDefinition Width="280"/>
            <ColumnDefinition Width="*"/>
          </Grid.ColumnDefinitions>

          <!-- ========== LEFT SIDEBAR ========== -->
          <Border Grid.Column="0" CornerRadius="14" BorderThickness="1" BorderBrush="#0CFFFFFF" Margin="0,0,8,0">
            <Border.Background>
              <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
                <GradientStop Color="#0C0F14" Offset="0"/>
                <GradientStop Color="#090C10" Offset="1"/>
              </LinearGradientBrush>
            </Border.Background>
            <Grid Margin="8,10,4,10">
              <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
              </Grid.RowDefinitions>

              <TextBlock Grid.Row="0" Text="MODE SELECTOR" FontSize="9" FontWeight="Bold" Foreground="#3CFFFFFF" Margin="10,2,0,10"/>

              <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                <StackPanel Name="ModeGrid">
                  <!-- System Analysis Card -->
                  <Border Name="AnalysisCard" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" Cursor="Hand">
                    <Border.BorderBrush>
                      <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                        <GradientStop Color="#00FFA3" Offset="0"/>
                        <GradientStop Color="#00D4FF" Offset="1"/>
                      </LinearGradientBrush>
                    </Border.BorderBrush>
                    <Border.Background>
                      <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                        <GradientStop Color="#0C00FFA3" Offset="0"/>
                        <GradientStop Color="#0800D4FF" Offset="1"/>
                      </LinearGradientBrush>
                    </Border.Background>
                    <Grid>
                      <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="26"/>
                        <ColumnDefinition Width="*"/>
                      </Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 12,12 L 17,17 M 7,12 A 5,5 0 1,1 12,7 A 5,5 0 0,1 7,12 Z" Stroke="#00FFA3" StrokeThickness="1.5" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center">
                        <TextBlock Text="SYSTEM ANALYSIS" FontSize="11" FontWeight="Bold" Foreground="#00FFA3"/>
                        <TextBlock Text="Auto-detect and recommend" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/>
                      </StackPanel>
                    </Grid>
                  </Border>

                  <!-- â”€â”€ STANDARD â”€â”€ -->
                  <StackPanel Orientation="Horizontal" Margin="8,14,0,5">
                    <Border Height="1" Width="14" Background="#20FFFFFF" VerticalAlignment="Center" Margin="0,0,6,0"/>
                    <TextBlock Text="STANDARD" FontSize="8.5" FontWeight="Bold" Foreground="#2AFFFFFF"/>
                  </StackPanel>

                  <Border Name="Mode1Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#2ECC71" Background="#082ECC71" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 4,16 C 4,16 6,6 16,4 C 16,4 14,14 4,16 M 4,16 L 12,8" Stroke="#2ECC71" StrokeThickness="1.5" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="ECO MODE" FontSize="11" FontWeight="Bold" Foreground="#2ECC71"/><TextBlock Text="Low power, energy efficient" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>
                  <Border Name="Mode2Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#3498DB" Background="#083498DB" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 3,6 L 17,6 M 10,3 L 10,17 M 6,6 L 6,12 C 6,14 14,14 14,12 L 14,6 M 10,17 L 3,17 M 10,17 L 17,17" Stroke="#3498DB" StrokeThickness="1.5" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="BALANCED" FontSize="11" FontWeight="Bold" Foreground="#3498DB"/><TextBlock Text="Default Windows config" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>
                  <Border Name="Mode3Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#9B59B6" Background="#089B59B6" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 3,15 A 8,8 0 0,1 17,15 M 10,15 L 13,9 M 10,15 A 1.5,1.5 0 1,1 8.5,13.5" Stroke="#9B59B6" StrokeThickness="1.5" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="PERFORMANCE" FontSize="11" FontWeight="Bold" Foreground="#9B59B6"/><TextBlock Text="CPU unpark, latency boost" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>
                  <Border Name="Mode4Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#E67E22" Background="#08E67E22" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 3,4 L 9,10 L 3,16 M 8,4 L 14,10 L 8,16 M 13,4 L 19,10 L 13,16" Stroke="#E67E22" StrokeThickness="1.5" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="HIGH PERFORMANCE" FontSize="11" FontWeight="Bold" Foreground="#E67E22"/><TextBlock Text="Input delay reduction" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>

                  <!-- â”€â”€ COMPETITIVE â”€â”€ -->
                  <StackPanel Orientation="Horizontal" Margin="8,14,0,5">
                    <Border Height="1" Width="14" Background="#20FFFFFF" VerticalAlignment="Center" Margin="0,0,6,0"/>
                    <TextBlock Text="COMPETITIVE" FontSize="8.5" FontWeight="Bold" Foreground="#2AFFFFFF"/>
                  </StackPanel>

                  <Border Name="Mode5Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#00A3FF" Background="#0800A3FF" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 10,2 L 10,18 M 2,10 L 18,10 M 10,10 A 5,5 0 1,1 5,10 A 5,5 0 0,1 10,10 Z" Stroke="#00A3FF" StrokeThickness="1.5" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="ULTIMATE" FontSize="11" FontWeight="Bold" Foreground="#00A3FF"/><TextBlock Text="Recommended for gaming" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>
                  <Border Name="Mode6Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#FF6B35" Background="#08FF6B35" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 13,2 L 5,11 L 11,11 L 7,18 L 15,9 L 9,9 Z" Stroke="#FF6B35" StrokeThickness="1.5" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="EXTREME" FontSize="11" FontWeight="Bold" Foreground="#FF6B35"/><TextBlock Text="Aggressive network tuning" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>
                  <Border Name="Mode7Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#FFD700" Background="#08FFD700" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 3,16 L 5,6 L 9,11 L 12,5 L 15,11 L 19,6 L 21,16 Z M 3,16 L 21,16" Stroke="#FFD700" StrokeThickness="1.5" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="GOD MODE" FontSize="11" FontWeight="Bold" Foreground="#FFD700"/><TextBlock Text="Ultra-low input latency" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>

                  <!-- â”€â”€ EXTREME â”€â”€ -->
                  <StackPanel Orientation="Horizontal" Margin="8,14,0,5">
                    <Border Height="1" Width="14" Background="#20FFFFFF" VerticalAlignment="Center" Margin="0,0,6,0"/>
                    <TextBlock Text="EXTREME" FontSize="8.5" FontWeight="Bold" Foreground="#2AFFFFFF"/>
                  </StackPanel>

                  <Border Name="Mode8Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#E74C3C" Background="#08E74C3C" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 12,2 C 12,2 17,6 17,11 C 17,14 15,16 12,16 C 9,16 7,14 7,11 C 7,6 12,2 12,2 Z M 9,16 L 6,19 M 15,16 L 18,19 M 12,16 L 12,20" Stroke="#E74C3C" StrokeThickness="1.5" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="OVERDRIVE" FontSize="11" FontWeight="Bold" Foreground="#E74C3C"/><TextBlock Text="Push to absolute limit" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>
                  <Border Name="Mode9Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#C0392B" Background="#08C0392B" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 10,2 L 18,17 L 2,17 Z M 10,6 L 10,12 M 10,14 L 10,15" Stroke="#C0392B" StrokeThickness="1.5" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="MAXIMUM" FontSize="11" FontWeight="Bold" Foreground="#C0392B"/><TextBlock Text="Experimental, highest priority" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>
                  <Border Name="Mode10Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#8E44AD" Background="#088E44AD" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 10,10 A 2,2 0 1,1 8,8 A 2,2 0 0,1 10,10 Z M 10,2 A 8,8 0 1,1 2,10 A 8,8 0 0,1 10,2 Z M 10,2 L 10,6 M 10,14 L 10,18 M 2,10 L 6,10 M 14,10 L 18,10" Stroke="#8E44AD" StrokeThickness="1.5" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="INSANE" FontSize="11" FontWeight="Bold" Foreground="#8E44AD"/><TextBlock Text="Bypass all limits (risky)" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>

                  <!-- â”€â”€ SPECIAL â”€â”€ -->
                  <StackPanel Orientation="Horizontal" Margin="8,14,0,5">
                    <Border Height="1" Width="14" Background="#20FFFFFF" VerticalAlignment="Center" Margin="0,0,6,0"/>
                    <TextBlock Text="SPECIAL" FontSize="8.5" FontWeight="Bold" Foreground="#2AFFFFFF"/>
                  </StackPanel>

                  <Border Name="Mode11Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#FF2A6D" Background="#08FF2A6D" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 12,3 L 4,6 L 4,11 C 4,16 12,21 12,21 C 12,21 20,16 20,11 L 20,6 Z" Stroke="#FF2A6D" StrokeThickness="1.5" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="SAFE PLAY" FontSize="11" FontWeight="Bold" Foreground="#FF2A6D"/><TextBlock Text="100% game compatible" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>
                  <Border Name="Mode12Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#E0A96D" Background="#08E0A96D" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 12,2 L 15,9 L 22,9 L 16,14 L 18,21 L 12,17 L 6,21 L 8,14 L 2,9 L 9,9 Z" Stroke="#E0A96D" StrokeThickness="1.5" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="VIP MODE" FontSize="11" FontWeight="Bold" Foreground="#E0A96D"/><TextBlock Text="Premium elite optimization" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>
                  <Border Name="Mode13Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#00FFD2" Background="#0800FFD2" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 3,13 L 10,6 L 17,13 M 3,18 L 10,11 L 17,18" Stroke="#00FFD2" StrokeThickness="1.5" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="FPS BOOST" FontSize="11" FontWeight="Bold" Foreground="#00FFD2"/><TextBlock Text="Frame rate focus, no registry" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>
                  <Border Name="Mode14Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#FF00EA" Background="#08FF00EA" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 2,6 H 15 V 19 H 2 Z M 6,2 H 19 V 15" Stroke="#FF00EA" StrokeThickness="1.5" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="FRAME GEN BOOST" FontSize="11" FontWeight="Bold" Foreground="#FF00EA"/><TextBlock Text="HAGS + DXGI frame gen" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>
                  <Border Name="Mode15Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#00FF87" Background="#0800FF87" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 2,12 L 8,12 L 11,5 L 14,19 L 17,12 L 22,12" Stroke="#00FF87" StrokeThickness="2" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="TCP DESYNC BOOSTER" FontSize="11" FontWeight="Bold" Foreground="#00FF87"/><TextBlock Text="Ultra low-latency network" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>

                  <!-- â”€â”€ COMBAT PRO â”€â”€ -->
                  <StackPanel Orientation="Horizontal" Margin="8,14,0,5">
                    <Border Height="1" Width="14" Background="#20FFFFFF" VerticalAlignment="Center" Margin="0,0,6,0"/>
                    <TextBlock Text="COMBAT PRO" FontSize="8.5" FontWeight="Bold" Foreground="#2AFFFFFF"/>
                  </StackPanel>

                  <Border Name="Mode16Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#FF0055" Background="#08FF0055" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 10,2 A 8,8 0 1,0 10,18 A 8,8 0 1,0 10,2 Z M 10,2 L 10,6 M 10,14 L 10,18 M 2,10 L 6,10 M 14,10 L 18,10" Stroke="#FF0055" StrokeThickness="2" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="HIT REG &amp; COMBAT PRO" FontSize="11" FontWeight="Bold" Foreground="#FF0055"/><TextBlock Text="Headshot sync and latency focus" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>

                  <Border Name="Mode17Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#FF7B00" Background="#08FF7B00" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 12,2 L 2,12 H 9 V 22 L 19,12 H 12 Z" Stroke="#FF7B00" StrokeThickness="2" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="HYBRID PRO COMBAT" FontSize="11" FontWeight="Bold" Foreground="#FF7B00"/><TextBlock Text="Max-Insane PvP fusion" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>

                  <Border Name="Mode18Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#FF003C" Background="#08FF003C" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 12,2 L 12,22 M 2,12 L 22,12 M 12,12 A 6,6 0 1,1 6,12 A 6,6 0 0,1 12,12 Z" Stroke="#FF003C" StrokeThickness="2" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="INSANE PRO COMBAT" FontSize="11" FontWeight="Bold" Foreground="#FF003C"/><TextBlock Text="Pure Insane PvP tuning" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>

                  <Border Name="Mode19Card" Margin="4,2" Padding="11,9" CornerRadius="10" BorderThickness="1.5" BorderBrush="#00FFEA" Background="#0800FFEA" Cursor="Hand">
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                      <Path Grid.Column="0" Data="M 12,2 L 12,22 M 2,12 L 22,12 M 12,12 A 6,6 0 1,1 6,12 A 6,6 0 0,1 12,12 Z" Stroke="#00FFEA" StrokeThickness="2" Width="15" Height="15" Stretch="Uniform" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                      <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="HIT TO GPEDIT" FontSize="11" FontWeight="Bold" Foreground="#00FFEA"/><TextBlock Text="Max transmission, zero desync" FontSize="8" Foreground="#6B8DA8" Margin="0,2,0,0"/></StackPanel>
                    </Grid>
                  </Border>
                </StackPanel>
              </ScrollViewer>
            </Grid>
          </Border>

          <!-- ========== RIGHT PANEL ========== -->
          <Grid Grid.Column="1" Margin="8,0,0,0">
            <Grid.RowDefinitions>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="*"/>
            </Grid.RowDefinitions>

            <!-- Zone 1: Status Bar -->
            <Grid Grid.Row="0" Margin="0,0,0,12">
              <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
              </Grid.ColumnDefinitions>
              <StackPanel Grid.Column="0">
                <TextBlock Text="PERFORMANCE DASHBOARD" FontSize="17" FontWeight="Bold" Foreground="#F0F6FC">
                  <TextBlock.Effect>
                    <DropShadowEffect BlurRadius="8" Color="#00A3FF" ShadowDepth="0" Opacity="0.3"/>
                  </TextBlock.Effect>
                </TextBlock>
                <TextBlock Text="Select a mode and launch optimization" FontSize="9" FontWeight="Medium" Foreground="#3CFFFFFF" Margin="0,3,0,0"/>
              </StackPanel>
              <Border Grid.Column="1" Name="CurrentModeBadge" CornerRadius="10" Padding="14,6" BorderThickness="1.5" BorderBrush="#FF4757" Background="#12FF4757" VerticalAlignment="Center">
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                  <TextBlock Text="ACTIVE: " FontSize="8" FontWeight="Bold" Foreground="#6B8DA8" VerticalAlignment="Center"/>
                  <TextBlock Name="CurrentModeText" Text="NO SETTING" FontSize="9.5" FontWeight="Bold" Foreground="#FF4757" VerticalAlignment="Center"/>
                </StackPanel>
              </Border>
            </Grid>

            <!-- Zone 2: Mode Detail Card -->
            <Border Grid.Row="1" CornerRadius="12" BorderThickness="1" BorderBrush="#0EFFFFFF" Padding="16,14" Margin="0,0,0,10">
              <Border.Background>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                  <GradientStop Color="#0C0F14" Offset="0"/>
                  <GradientStop Color="#090C10" Offset="1"/>
                </LinearGradientBrush>
              </Border.Background>
              <Grid>
                <Grid.ColumnDefinitions>
                  <ColumnDefinition Width="Auto"/>
                  <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                <Border Grid.Column="0" Width="48" Height="48" CornerRadius="12" Background="#0C00A3FF" Margin="0,0,16,0" VerticalAlignment="Top">
                  <Viewbox Width="24" Height="24">
                    <Path Name="SelectedModeIcon" Data="M 10,2 L 10,18 M 2,10 L 18,10 M 10,10 A 5,5 0 1,1 5,10 A 5,5 0 0,1 10,10 Z" Stroke="#00A3FF" StrokeThickness="1.5" Stretch="Uniform"/>
                  </Viewbox>
                </Border>
                <StackPanel Grid.Column="1" VerticalAlignment="Top">
                  <TextBlock Text="SELECTED MODE" FontSize="8" FontWeight="Bold" Foreground="#3000A3FF" Margin="0,0,0,5"/>
                  <TextBlock Name="ModeDescription" Text="Select a mode from the sidebar to view its details and configuration."
                             FontSize="11" FontWeight="Medium" Foreground="#C0D0DD" TextWrapping="Wrap" LineHeight="18"/>
                  <TextBlock Name="GameLaunchStatus" Text="Game Launch: Supported" FontSize="10.5" FontWeight="Bold" Foreground="#00FFA3" Margin="0,8,0,0"/>
                </StackPanel>
              </Grid>
            </Border>

            <!-- Zone 3: Two-Column Interactive Layout -->
            <Grid Grid.Row="2">
              <Grid.ColumnDefinitions>
                <ColumnDefinition Width="1.1*"/>
                <ColumnDefinition Width="12"/>
                <ColumnDefinition Width="1*"/>
              </Grid.ColumnDefinitions>

              <!-- Left Interactive Column (Features & Actions) -->
              <Grid Grid.Column="0">
                <Grid.RowDefinitions>
                  <RowDefinition Height="*"/>
                  <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <!-- Features Details Card -->
                <Border Grid.Row="0" CornerRadius="12" BorderThickness="1" BorderBrush="#0EFFFFFF" Padding="14,14" Margin="0,0,0,10">
                  <Border.Background>
                    <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                      <GradientStop Color="#0C0F14" Offset="0"/>
                      <GradientStop Color="#090C10" Offset="1"/>
                    </LinearGradientBrush>
                  </Border.Background>
                  <Grid>
                    <Grid.RowDefinitions>
                      <RowDefinition Height="Auto"/>
                      <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    
                    <TextBlock Grid.Row="0" Text="OPTIMIZED FEATURES &amp; TWEAKS" FontSize="8.5" FontWeight="Bold" Foreground="#45FFFFFF" Margin="0,0,0,12"/>
                    
                    <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                      <WrapPanel Name="FeatureTags"/>
                    </ScrollViewer>
                  </Grid>
                </Border>

                <!-- Actions buttons -->
                <Grid Grid.Row="1" Margin="0,0,0,0">
                  <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="2*"/>
                    <ColumnDefinition Width="8"/>
                    <ColumnDefinition Width="1.1*"/>
                  </Grid.ColumnDefinitions>

                  <Button Name="BtnLaunch" Grid.Column="0" Height="44" Cursor="Hand" Background="Transparent" BorderThickness="0">
                    <Button.Effect>
                      <DropShadowEffect x:Name="BtnGlow" BlurRadius="14" Color="#00A3FF" ShadowDepth="0" Opacity="0.4"/>
                    </Button.Effect>
                    <Button.Template>
                      <ControlTemplate TargetType="Button">
                        <Border x:Name="Bd" CornerRadius="10" BorderThickness="0">
                          <Border.Background>
                            <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                              <GradientStop Color="#00A3FF" Offset="0.0"/>
                              <GradientStop Color="#00C8FF" Offset="0.5"/>
                              <GradientStop Color="#00D4FF" Offset="1.0"/>
                            </LinearGradientBrush>
                          </Border.Background>
                          <TextBlock Name="BtnText" Text="LAUNCH OPTIMIZATION" FontSize="11" FontWeight="Bold" Foreground="#FFFFFF" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                          <Trigger Property="IsMouseOver" Value="True">
                            <Setter TargetName="Bd" Property="Effect">
                              <Setter.Value>
                                <DropShadowEffect BlurRadius="20" Color="#00D4FF" ShadowDepth="0" Opacity="0.55"/>
                              </Setter.Value>
                            </Setter>
                          </Trigger>
                          <Trigger Property="IsEnabled" Value="False">
                            <Setter TargetName="Bd" Property="Opacity" Value="0.35"/>
                          </Trigger>
                        </ControlTemplate.Triggers>
                      </ControlTemplate>
                    </Button.Template>
                  </Button>

                  <Button Name="BtnRestore" Grid.Column="2" Height="44" Cursor="Hand" Background="Transparent" BorderThickness="0">
                    <Button.Effect>
                      <DropShadowEffect BlurRadius="10" Color="#FF7B3D" ShadowDepth="0" Opacity="0.25"/>
                    </Button.Effect>
                    <Button.Template>
                      <ControlTemplate TargetType="Button">
                        <Border x:Name="Bd" CornerRadius="10" BorderThickness="1.5" BorderBrush="#FF7B3D">
                          <Border.Background>
                            <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
                              <GradientStop Color="#15FF7B3D" Offset="0"/>
                              <GradientStop Color="#05000000" Offset="1"/>
                            </LinearGradientBrush>
                          </Border.Background>
                          <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center">
                            <Path Data="M 13.5,8 A 5.5,5.5 0 1,1 12.1,4.1 M 12,1 L 12,4.5 L 8.5,4.5" Stroke="#FF7B3D" StrokeThickness="1.5" Width="12" Height="12" Stretch="Uniform" Margin="0,0,6,0" VerticalAlignment="Center"/>
                            <TextBlock Name="BtnRestoreText" Text="RESTORE" FontSize="10" FontWeight="Bold" Foreground="#C8D0DA" VerticalAlignment="Center"/>
                          </StackPanel>
                        </Border>
                        <ControlTemplate.Triggers>
                          <Trigger Property="IsMouseOver" Value="True">
                            <Setter TargetName="Bd" Property="Background" Value="#28FF7B3D"/>
                            <Setter TargetName="Bd" Property="BorderBrush" Value="#FFB088"/>
                          </Trigger>
                          <Trigger Property="IsEnabled" Value="False">
                            <Setter TargetName="Bd" Property="Opacity" Value="0.3"/>
                          </Trigger>
                        </ControlTemplate.Triggers>
                      </ControlTemplate>
                    </Button.Template>
                  </Button>
                </Grid>
              </Grid>

              <!-- Right Diagnostic Console Column (Console Logging) -->
              <Border Grid.Column="2" CornerRadius="12" BorderThickness="1" BorderBrush="#0EFFFFFF" Padding="14,14">
                <Border.Background>
                  <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                    <GradientStop Color="#0C0F14" Offset="0"/>
                    <GradientStop Color="#090C10" Offset="1"/>
                  </LinearGradientBrush>
                </Border.Background>
                <Grid>
                  <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                  </Grid.RowDefinitions>

                  <TextBlock Grid.Row="0" Text="SYSTEM DIAGNOSTIC LOG" FontSize="8.5" FontWeight="Bold" Foreground="#2AFFFFFF" Margin="0,0,0,8"/>

                  <ProgressBar Name="ProgBar" Grid.Row="1" Height="2" IsIndeterminate="True" Visibility="Collapsed" BorderThickness="0" Background="#0D1117" Margin="0,0,0,8">
                    <ProgressBar.Foreground>
                      <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                        <GradientStop Color="#0055FF" Offset="0"/>
                        <GradientStop Color="#00A3FF" Offset="0.5"/>
                        <GradientStop Color="#00D4FF" Offset="1"/>
                      </LinearGradientBrush>
                    </ProgressBar.Foreground>
                    <ProgressBar.Effect>
                      <DropShadowEffect BlurRadius="4" Color="#00A3FF" ShadowDepth="0" Opacity="0.4"/>
                    </ProgressBar.Effect>
                  </ProgressBar>

                  <Border Grid.Row="2" CornerRadius="10" BorderThickness="1" BorderBrush="#0CFFFFFF">
                    <Border.Background>
                      <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
                        <GradientStop Color="#0A0D12" Offset="0"/>
                        <GradientStop Color="#080B0F" Offset="1"/>
                      </LinearGradientBrush>
                    </Border.Background>
                    <TextBox Name="LogBox" Background="Transparent" Foreground="#6B8DA8" BorderThickness="0"
                             FontFamily="Consolas" FontSize="9.5" IsReadOnly="True" TextWrapping="Wrap"
                             VerticalScrollBarVisibility="Auto" Margin="12,8,12,8"/>
                  </Border>
                </Grid>
              </Border>
            </Grid>
          </Grid>
        </Grid>

        <!-- ==================== ANALYSIS MODAL ==================== -->
        <Grid Name="ViewAnalysisModal" Visibility="Collapsed" Panel.ZIndex="100">
          <Border Background="#CC030508"/>
          <Border CornerRadius="18" BorderThickness="1.5" Background="#0D1117" Width="480" Height="380" VerticalAlignment="Center" HorizontalAlignment="Center">
            <Border.BorderBrush>
              <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                <GradientStop Color="#00FFA3" Offset="0"/>
                <GradientStop Color="#00D4FF" Offset="1"/>
              </LinearGradientBrush>
            </Border.BorderBrush>
            <Border.Effect>
              <DropShadowEffect BlurRadius="35" Color="#00FFA3" ShadowDepth="0" Opacity="0.35"/>
            </Border.Effect>
            <Grid Margin="28">
              <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
              </Grid.RowDefinitions>

              <Grid Grid.Row="0" Margin="0,0,0,18">
                <Grid.ColumnDefinitions>
                  <ColumnDefinition Width="Auto"/>
                  <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                <Border Grid.Column="0" Width="36" Height="36" CornerRadius="10" Background="#0C00FFA3" Margin="0,0,12,0" VerticalAlignment="Center">
                  <Path Data="M 12,12 L 17,17 M 7,12 A 5,5 0 1,1 12,7 A 5,5 0 0,1 7,12 Z" Stroke="#00FFA3" StrokeThickness="2" Width="18" Height="18" Stretch="Uniform" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>
                <StackPanel Grid.Column="1" VerticalAlignment="Center">
                  <TextBlock Text="SYSTEM ANALYSIS" FontSize="15" FontWeight="Bold" Foreground="#00FFA3"/>
                  <TextBlock Text="Hardware detection and mode recommendation" FontSize="9" Foreground="#4CFFFFFF" Margin="0,2,0,0"/>
                </StackPanel>
              </Grid>

              <Border Grid.Row="1" CornerRadius="10" BorderThickness="1" BorderBrush="#1000FFA3" Background="#0800FFA3" Padding="18,14" Margin="0,0,0,18">
                <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                  <TextBlock Name="AnalysisSpecsText" Text="Loading system specifications..." FontSize="11.5" FontFamily="Consolas" LineHeight="19" Foreground="#D8E0E8" TextWrapping="Wrap"/>
                </ScrollViewer>
              </Border>

              <Grid Grid.Row="2">
                <Grid.ColumnDefinitions>
                  <ColumnDefinition Width="2*"/>
                  <ColumnDefinition Width="12"/>
                  <ColumnDefinition Width="1*"/>
                </Grid.ColumnDefinitions>

                <Button Name="BtnModalApply" Grid.Column="0" Height="40" Cursor="Hand" Background="Transparent" BorderThickness="0">
                  <Button.Template>
                    <ControlTemplate TargetType="Button">
                      <Border x:Name="Bd" CornerRadius="10" BorderThickness="1.5" BorderBrush="#00FFA3" Background="#0C00FFA3">
                        <TextBlock Text="APPLY RECOMMENDATION" FontSize="11" FontWeight="Bold" Foreground="#00FFA3" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                      </Border>
                      <ControlTemplate.Triggers>
                        <Trigger Property="IsMouseOver" Value="True">
                          <Setter TargetName="Bd" Property="Background" Value="#2200FFA3"/>
                        </Trigger>
                      </ControlTemplate.Triggers>
                    </ControlTemplate>
                  </Button.Template>
                </Button>

                <Button Name="BtnModalClose" Grid.Column="2" Height="40" Cursor="Hand" Background="Transparent" BorderThickness="0">
                  <Button.Template>
                    <ControlTemplate TargetType="Button">
                      <Border x:Name="Bd" CornerRadius="10" BorderThickness="1" BorderBrush="#30FFFFFF" Background="#0AFFFFFF">
                        <TextBlock Text="CLOSE" FontSize="11" FontWeight="Bold" Foreground="#A0FFFFFF" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                      </Border>
                      <ControlTemplate.Triggers>
                        <Trigger Property="IsMouseOver" Value="True">
                          <Setter TargetName="Bd" Property="Background" Value="#18FFFFFF"/>
                          <Setter TargetName="Bd" Property="BorderBrush" Value="#60FFFFFF"/>
                        </Trigger>
                      </ControlTemplate.Triggers>
                    </ControlTemplate>
                  </Button.Template>
                </Button>
              </Grid>
            </Grid>
          </Border>
        </Grid>
      </Grid>

    </Grid>
  </Border>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader($xaml)
try { $window = [Windows.Markup.XamlReader]::Load($reader) }
catch { Write-Host "XAML Error: $_" -ForegroundColor Red; Exit }

$headerBar = $window.FindName("HeaderBar")
$btnMinimize = $window.FindName("BtnMinimize")
$btnClose = $window.FindName("BtnClose")
$btnLaunch = $window.FindName("BtnLaunch")
$btnRestore = $window.FindName("BtnRestore")
$viewLogin = $window.FindName("ViewLogin")
$viewMain = $window.FindName("ViewMain")
$logBox = $window.FindName("LogBox")
$progBar = $window.FindName("ProgBar")
$passwordBox = $window.FindName("PasswordBox")
$btnLogin = $window.FindName("BtnLogin")
$modeGrid = $window.FindName("ModeGrid")
$modeDescription = $window.FindName("ModeDescription")
$gameLaunchStatus = $window.FindName("GameLaunchStatus")
$selectedModeIcon = $window.FindName("SelectedModeIcon")
$featureTags = $window.FindName("FeatureTags")
$analysisCard = $window.FindName("AnalysisCard")
$passGrid = $window.FindName("PassGrid")
$btnLoginGrid = $window.FindName("BtnLoginGrid")
$loginProgContainer = $window.FindName("LoginProgContainer")
$loginProgText = $window.FindName("LoginProgText")
$loginProgBar = $window.FindName("LoginProgBar")
$viewAnalysisModal = $window.FindName("ViewAnalysisModal")
$analysisSpecsText = $window.FindName("AnalysisSpecsText")
$btnModalApply = $window.FindName("BtnModalApply")
$btnModalClose = $window.FindName("BtnModalClose")
$currentModeBadge = $window.FindName("CurrentModeBadge")
$currentModeText = $window.FindName("CurrentModeText")
$script:selectedMode = "Mode5"

# Get all mode cards
$modeCards = @()
for ($i = 1; $i -le 19; $i++) {
  $modeCards += $window.FindName("Mode${i}Card")
}

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

# Mode descriptions, colors, and game capabilities (in English)
$modeConfig = @{
  "Mode1"  = @{ 
    Description = "Eco Mode: Optimizes power consumption for battery saving. Minimizes processor performance state and stops low-priority background events."
    GameLaunch  = "YES (Supported - Low FPS/performance due to power saving)"
    GameColor   = "#FFC000"
    Color       = "#2ECC71"
    IconData    = "M 4,16 C 4,16 6,6 16,4 C 16,4 14,14 4,16 M 4,16 L 12,8"
    Features    = @("Basic Network (TCP)", "Power Saving") 
  }
  "Mode2"  = @{ 
    Description = "Balanced Mode: Default Windows configuration with standard settings. Optimized for web browsing, office suites, and normal daily use."
    GameLaunch  = "YES (Supported - Moderate performance)"
    GameColor   = "#00FFA3"
    Color       = "#3498DB"
    IconData    = "M 3,6 L 17,6 M 10,3 L 10,17 M 6,6 L 6,12 C 6,14 14,14 14,12 L 14,6 M 10,17 L 3,17 M 10,17 L 17,17"
    Features    = @("Network Stack (TCP)", "Basic CPU", "MMCSS") 
  }
  "Mode3"  = @{ 
    Description = "Performance Mode: Enables dynamic processor unparking and network latency reductions. Ideal for standard gameplay."
    GameLaunch  = "YES (Fully Supported - Smooth performance)"
    GameColor   = "#00FFA3"
    Color       = "#9B59B6"
    IconData    = "M 3,15 A 8,8 0 0,1 17,15 M 10,15 L 13,9 M 10,15 A 1.5,1.5 0 1,1 8.5,13.5"
    Features    = @("Network (TCP)", "CPU Unpark", "MMCSS", "GPU", "CPU Unlock (Intel/AMD)") 
  }
  "Mode4"  = @{ 
    Description = "High Performance Mode: Dynamic CPU unparking, aggressive game scheduling categories, and input delay reductions."
    GameLaunch  = "YES (Fully Supported - High FPS & low latency)"
    GameColor   = "#00FFA3"
    Color       = "#E67E22"
    IconData    = "M 3,4 L 9,10 L 3,16 M 8,4 L 14,10 L 8,16 M 13,4 L 19,10 L 13,16"
    Features    = @("Network (TCP)", "CPU", "MMCSS", "GPU", "Input", "CPU Unlock (Intel/AMD)") 
  }
  "Mode5"  = @{ 
    Description = "Ultimate Mode: Recommended for competitive gaming. Combines maximum responsiveness, unparked processor states, optimized network buffers, and 1:1 input pipelines."
    GameLaunch  = "YES (Fully Supported - Peak responsiveness)"
    GameColor   = "#00FFA3"
    Color       = "#00A3FF"
    IconData    = "M 10,2 L 10,18 M 2,10 L 18,10 M 10,10 A 5,5 0 1,1 5,10 A 5,5 0 0,1 10,10 Z"
    Features    = @("Network Stack (TCP)", "CPU Unpark", "MMCSS Game", "GPU Scheduler", "Combat Input", "Hit Register", "Timer 0.5ms", "CPU Unlock (Intel/AMD)") 
  }
  "Mode6"  = @{ 
    Description = "Extreme Mode: Aggressive network tuning, forced maximum GPU preference, and disabled power management. Restricts system throttles."
    GameLaunch  = "YES (Fully Supported - Maximum raw performance)"
    GameColor   = "#00FFA3"
    Color       = "#FF6B35"
    IconData    = "M 13,2 L 5,11 L 11,11 L 7,18 L 15,9 L 9,9 Z"
    Features    = @("Extreme Network (TCP)", "CPU Max", "MMCSS Max", "GPU Max", "Input Max", "Timer 0.5ms", "DPC/ISR", "CPU Unlock (Intel/AMD)") 
  }
  "Mode7"  = @{ 
    Description = "God Mode: Enthusiast-grade aggressive tuning. Disables CPU idle states, unparks all processor cores, and enforces a raw 1:1 mouse/keyboard input pipeline."
    GameLaunch  = "YES (Fully Supported - Ultra-low input latency)"
    GameColor   = "#00FFA3"
    Color       = "#FFD700"
    IconData    = "M 3,16 L 5,6 L 9,11 L 12,5 L 15,11 L 19,6 L 21,16 Z M 3,16 L 21,16"
    Features    = @("God Network (TCP)", "CPU God", "MMCSS God", "GPU God", "Input God", "Timer 0.5ms", "DPC/ISR", "Memory", "CPU Unlock (Intel/AMD)") 
  }
  "Mode8"  = @{ 
    Description = "Overdrive Mode: Pushes network interface cards, timers, and CPU scheduling parameters to the absolute limit. Risk of minor thermal variance."
    GameLaunch  = "YES (Supported - Experimental, risk of system jitter)"
    GameColor   = "#FFC000"
    Color       = "#E74C3C"
    IconData    = "M 12,2 C 12,2 17,6 17,11 C 17,14 15,16 12,16 C 9,16 7,14 7,11 C 7,6 12,2 12,2 Z M 9,16 L 6,19 M 15,16 L 18,19 M 12,16 L 12,20"
    Features    = @("Overclock Network (TCP)", "CPU Overdrive", "MMCSS Over", "GPU Over", "Input Over", "Timer 0.3ms", "DPC/ISR Max", "CPU Unlock (Intel/AMD)") 
  }
  "Mode9"  = @{ 
    Description = "Maximum Mode: Absolute highest priority class for game processes, disabled system memory compression, and maximum thread execution parameters."
    GameLaunch  = "YES (Supported - Experimental, risk of application instability)"
    GameColor   = "#FF3366"
    Color       = "#C0392B"
    IconData    = "M 10,2 L 18,17 L 2,17 Z M 10,6 L 10,12 M 10,14 L 10,15"
    Features    = @("Max Network (TCP)", "CPU Max", "MMCSS Max", "GPU Max", "Input Max", "Timer 0.1ms", "DPC/ISR Max", "Memory Max", "CPU Unlock (Intel/AMD)") 
  }
  "Mode10" = @{ 
    Description = "Insane Mode: Experimental extreme tuning. Unlocked network speeds, aggressive system unparking, and bypasses standard system throttles. Use at own risk."
    GameLaunch  = "YES (Supported - Experimental, risk of system crash/OOM)"
    GameColor   = "#FF3366"
    Color       = "#8E44AD"
    IconData    = "M 10,10 A 2,2 0 1,1 8,8 A 2,2 0 0,1 10,10 Z M 10,2 A 8,8 0 1,1 2,10 A 8,8 0 0,1 10,2 Z M 10,2 L 10,6 M 10,14 L 10,18 M 2,10 L 6,10 M 14,10 L 18,10"
    Features    = @("Insane Network (TCP)", "CPU Insane", "MMCSS Insane", "GPU Insane", "Input Insane", "Timer 0.05ms", "DPC/ISR Insane", "Memory Insane", "Bypass Limits", "CPU Unlock (Intel/AMD)") 
  }
  "Mode11" = @{ 
    Description = "Safe Play Mode: High gaming performance with standard network protocols and service setups to ensure 100% compatibility with all multiplayer and single-player games."
    GameLaunch  = "YES (Fully Supported - Highly stable, 100% compatible)"
    GameColor   = "#00FFA3"
    Color       = "#FF2A6D"
    IconData    = "M 12,3 L 4,6 L 4,11 C 4,16 12,21 12,21 C 12,21 20,16 20,11 L 20,6 Z"
    Features    = @("Safe Network (TCP)", "CPU Boost", "MMCSS Game", "GPU Preference", "Safe Input", "CPU Unlock (Intel/AMD)") 
  }
  "Mode12" = @{ 
    Description = "Minishawty Project VIP Mode: Elite VIP gaming optimization combining unparked processors, fast filesystem response, optimized IRQ prioritization, and low-latency input."
    GameLaunch  = "YES (Fully Supported - Premium gaming experience)"
    GameColor   = "#00FFA3"
    Color       = "#E0A96D"
    IconData    = "M 12,2 L 15,9 L 22,9 L 16,14 L 18,21 L 12,17 L 6,21 L 8,14 L 2,9 L 9,9 Z"
    Features    = @("VIP Network (TCP)", "CPU Unpark Max", "MMCSS Game Max", "GPU Scheduler Max", "VIP Low Latency Input", "Win32PrioritySeparation", "File System Tweaks", "Responsive Desktop", "Timer 0.5ms", "CPU Unlock (Intel/AMD)") 
  }
  "Mode13" = @{ 
    Description = "FPS Boost Mode: Focuses on boosting FiveM frame rates, stabilizing sync and eliminating packet desync. Bypasses all aggressive system registry modifications and service shutdowns to ensure absolute system stability."
    GameLaunch  = "YES (Fully Supported - Peak FPS stability)"
    GameColor   = "#00FFA3"
    Color       = "#00FFD2"
    IconData    = "M 3,13 L 10,6 L 17,13 M 3,18 L 10,11 L 17,18"
    Features    = @("FiveM priority boost", "Active Standby RAM cleaner", "HAGS active", "DXGI Flip Model Swapchain", "Internet Sync Boost", "DeSync Eliminator", "No System Changes") 
  }
  "Mode14" = @{ 
    Description = "Frame Gen Boost Mode: Activates Hardware-Accelerated GPU Scheduling (HAGS), DirectX Flip Model Swapchain upgrades, and Desktop Window Manager (DWM) overlays. Installs the persistent startup driver enforcement daemon without modifying other system configurations."
    GameLaunch  = "YES (Fully Supported - Double gaming FPS)"
    GameColor   = "#00FFA3"
    Color       = "#FF00EA"
    IconData    = "M 2,6 L 15,6 L 15,19 L 2,19 Z M 6,2 L 19,2 L 19,15"
    Features    = @("HAGS active", "DXGI Flip Model Swapchain", "DWM Overlays", "Persistent Frame Gen Daemon", "No System Changes") 
  }
  "Mode15" = @{ 
    Description = "TCP & DeSync Booster Mode: Elite low-latency network optimizations. Enforces TCP_NODELAY, disables Nagle's algorithm, configures TCP Congestion Control, and eliminates game desynchronization for ultra-fast response."
    GameLaunch  = "YES (Fully Supported - Ultra-low network delay)"
    GameColor   = "#00FFA3"
    Color       = "#00FF87"
    IconData    = "M 2,12 L 8,12 L 11,5 L 14,19 L 17,12 L 22,12"
    Features    = @("TCP Low Latency", "No Nagle's Algorithm", "TcpAckFrequency Max", "SackOpts Active", "DeSync Eliminator", "Ping Stabilizer", "No System Service Tweaks") 
  }
  "Mode16" = @{
    Description = "Hit Registration & Combat Pro Mode: Specifically tunes network packet latency, TCP parameters, and input response to maximize hit synchronization (Hit-Reg). Eliminates packet buffer queue lag and enforces maximum process priority class so that headshots and weapon sprays register immediately in combat."
    GameLaunch  = "YES (Fully Supported - Ultra combat precision)"
    GameColor   = "#FF007F"
    Color       = "#FF0055"
    IconData    = "M 10,2 A 8,8 0 1,0 10,18 A 8,8 0 1,0 10,2 Z M 10,2 L 10,6 M 10,14 L 10,18 M 2,10 L 6,10 M 14,10 L 18,10"
    Features    = @("Headshot Sync Priority", "Zero Jitter Network (TCP)", "Input Lag Minimizer", "No Delay Packet Sending", "Maximum Game Priority Class", "MMCSS Critical priority", "Advanced CPU Unlock (5.5GHz)")
  }
  "Mode17" = @{
    Description = "Hybrid Pro Combat Mode: The ultimate PvP weapon combining Maximum (Mode 9) priorities and Insane (Mode 10) network parameters. Custom-tuned for rapid movement recovery, seamless melee swings, high-rate crouch/potion spamming, and instant hitbox registration to dominate crowded combat zones."
    GameLaunch  = "YES (Fully Supported - Peak PvP combat dominance)"
    GameColor   = "#FF5E00"
    Color       = "#FF7B00"
    IconData    = "M 12,2 L 2,12 H 9 V 22 L 19,12 H 12 Z"
    Features    = @("Hybrid Max-Insane Core", "Ultra Fast Tickrate Sync", "Raw Movement Buffer (0ms)", "Background Apps Suspended", "DirectX Flip Swapchain", "CPU Autonomous Overclock", "Zero-Queue Packet Sending", "Auto-Repeat crouch/spam")
  }
  "Mode18" = @{
    Description = "Insane Pro Combat Mode: The absolute pinnacle of PvP performance, bypassing standard OS safety margins for the ultimate competitive edge. Custom-tuned for pure insane low latency, instant melee swing registration, zero-lag character animation recovery, and the absolute fastest hitbox synchronization."
    GameLaunch  = "YES (Fully Supported - Absolute PvP supremacy)"
    GameColor   = "#FF1E27"
    Color       = "#FF003C"
    IconData    = "M 12,2 L 12,22 M 2,12 L 22,12 M 12,12 A 6,6 0 1,1 6,12 A 6,6 0 0,1 12,12 Z"
    Features    = @("Pure Insane Core", "Ultra-Low Packet Delay", "Direct Thread Injection", "System Service Deferral", "Independent Flip Upgrade", "CPU Overclock Unlimit", "Zero Buffer Transmission", "Safe FilterKeys Repeat")
  }
  "Mode19" = @{
    Description = "Hit To GPEDIT Mode: The absolute ultimate in competitive PvP gameplay. Fine-tuned for maximum packet transmission throughput, zero Receive Segment Coalescing buffer delays, high-rate key repeat, and zero position desync to maximize melee hit registration and fluid blade combat."
    GameLaunch  = "YES (Fully Supported - Absolute server sync supremacy)"
    GameColor   = "#00E5FF"
    Color       = "#00FFEA"
    IconData    = "M 12,2 L 12,22 M 2,12 L 22,12 M 12,12 A 6,6 0 1,1 6,12 A 6,6 0 0,1 12,12 Z"
    Features    = @("Max Packet Throughput", "Zero Segment Coalescing", "Zero Desync Coordinate Sync", "Melee Range Optimization", "Fluid Knife Animation", "Background App Suspend", "Short Variable Priority separation", "Insane Keyboard Repeat")
  }
}

# Function to update the Current Mode Badge
function Update-CurrentModeIndicator {
  $statusFile = Join-Path $script:BackupFolder "optimized.flag"
  $isOptimized = Test-Path $statusFile
  if ($isOptimized) {
    $flagContent = Get-Content -Path $statusFile -Raw -EA SilentlyContinue
    $modeName = "Unknown"
    $modeColor = "#00A3FF"
    if ($flagContent -match "Mode(\d+)") {
      $modeNum = $Matches[1]
      $modeKey = "Mode$modeNum"
      if ($modeConfig[$modeKey]) {
        $modeName = $modeConfig[$modeKey].Description.Split(":")[0].Replace(" Mode", "").ToUpper()
        $modeColor = $modeConfig[$modeKey].Color
      }
    }
    if ($currentModeText) {
      $currentModeText.Text = $modeName
      $currentModeText.Foreground = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.ColorConverter]::ConvertFromString($modeColor))
    }
    if ($currentModeBadge) {
      $currentModeBadge.BorderBrush = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.ColorConverter]::ConvertFromString($modeColor))
      $currentModeBadge.Background = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.ColorConverter]::ConvertFromString("#1A" + $modeColor.Trim('#')))
    }
  }
  else {
    if ($currentModeText) {
      $currentModeText.Text = "NO SETTING"
      $currentModeText.Foreground = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.ColorConverter]::ConvertFromString("#FF4A4A"))
    }
    if ($currentModeBadge) {
      $currentModeBadge.BorderBrush = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.ColorConverter]::ConvertFromString("#FF4A4A"))
      $currentModeBadge.Background = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.ColorConverter]::ConvertFromString("#15FF4A4A"))
    }
  }
}

# Function to update the launch button state based on optimization status
function Update-LaunchButtonState {
  param([string]$mode = $script:selectedMode)
  
  $statusFile = Join-Path $script:BackupFolder "optimized.flag"
  $isSystemOptimized = Test-Path $statusFile
  
  $updateAction = {
    $tbLaunch = $null
    if ($btnLaunch -and $btnLaunch.Template) {
      try { $tbLaunch = $btnLaunch.Template.FindName("BtnText", $btnLaunch) } catch {}
    }
    
    if ($isSystemOptimized) {
      if ($mode -eq "Mode13" -or $mode -eq "Mode14") {
        $btnLaunch.IsEnabled = $true
        if ($tbLaunch) { $tbLaunch.Text = "LAUNCH OPTIMIZATION" }
      }
      else {
        $flagContent = Get-Content -Path $statusFile -Raw -EA SilentlyContinue
        if ($flagContent -match "($mode)") {
          $btnLaunch.IsEnabled = $false
          if ($tbLaunch) { $tbLaunch.Text = "OPTIMIZED SUCCESSFULLY" }
        }
        else {
          # Keep enabled so they can click and get the custom warning modal
          $btnLaunch.IsEnabled = $true
          if ($tbLaunch) { $tbLaunch.Text = "LAUNCH OPTIMIZATION" }
        }
      }
    }
    else {
      $btnLaunch.IsEnabled = $true
      if ($tbLaunch) { $tbLaunch.Text = "LAUNCH OPTIMIZATION" }
    }
  }
  
  try {
    # Run immediately for button IsEnabled state
    if ($btnLaunch) {
      if ($isSystemOptimized -and $mode -ne "Mode13" -and $mode -ne "Mode14") {
        $flagContent = Get-Content -Path $statusFile -Raw -EA SilentlyContinue
        if ($flagContent -match "($mode)") {
          $btnLaunch.IsEnabled = $false
        }
        else {
          $btnLaunch.IsEnabled = $true
        }
      }
      else {
        $btnLaunch.IsEnabled = $true
      }
    }
    
    # Defer template Text update to post-render queue
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke(
      [System.Windows.Threading.DispatcherPriority]::Background,
      [Action] $updateAction
    ) | Out-Null
  }
  catch {
    # Inline fallback if dispatcher is unavailable
    & $updateAction
  }
}

# Function to execute the core optimization flow (without dev key validation)
function Invoke-OptimizationLaunch {
  param(
    [string]$mode = $script:selectedMode
  )
  
  if ($progBar) { 
    $progBar.Visibility = [System.Windows.Visibility]::Visible
    $opacityAnim = New-Object System.Windows.Media.Animation.DoubleAnimation
    $opacityAnim.From = 0
    $opacityAnim.To = 1
    $opacityAnim.Duration = New-Object System.Windows.Duration([TimeSpan]::FromMilliseconds(300))
    $progBar.BeginAnimation([System.Windows.UIElement]::OpacityProperty, $opacityAnim)
  
    $frame = New-Object System.Windows.Threading.DispatcherFrame
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke(
      [System.Windows.Threading.DispatcherPriority]::Background,
      [Action] { $frame.Continue = $false })
    [System.Windows.Threading.Dispatcher]::PushFrame($frame)
  }

  Apply-BreathingGlowEffect $window

  Log-Write "[ BACKUP ] Saving current settings before optimization..."
  $backupFile = Backup-CurrentSettings
  Log-Write "   -> Backup saved: $backupFile"
  $btnRestore.IsEnabled = $true

  Start-FiveM-Optimization -Mode $mode

  $statusFile = Join-Path $script:BackupFolder "optimized.flag"
  "$($mode) on $([DateTime]::Now.ToString('yyyy-MM-dd HH:mm:ss'))" | Set-Content -Path $statusFile -Force
  Log-Write "[ STATUS ] Optimization applied! Flag saved."

  if ($progBar) { $progBar.Visibility = [System.Windows.Visibility]::Collapsed }
  $tb = $null
  if ($btnLaunch -and $btnLaunch.Template) {
    try { $tb = $btnLaunch.Template.FindName("BtnText", $btnLaunch) } catch {}
  }
  if ($tb) { $tb.Text = "OPTIMIZED SUCCESSFULLY" }
  Update-CurrentModeIndicator
  Update-LaunchButtonState $mode

  if ($mode -match "Mode(\d+)" -and [int]$Matches[1] -le 12) {
    # Detect CPU name for the success message box
    $cpu = Get-CimInstance -ClassName Win32_Processor -EA SilentlyContinue
    $cpuBrand = if ($cpu -and $cpu.Name -match "Intel") { "Intel Core CPU" } else { "AMD Ryzen CPU" }
    
    Log-Write "[ REBOOT ] PC reboot required to apply registry modifications. Auto-restarting..."
    [System.Windows.MessageBox]::Show("System optimized successfully!`n`n[$cpuBrand Unlocked] CPU frequency limit unlocked up to 5.5 GHz with active thermal controls.`n`nThe PC will now restart automatically to apply all registry modifications.", "Optimization Completed", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
    shutdown /r /t 5 /f /d p:2:4 /c "Minishawty Project - Auto Restarting to apply optimizations."
  }
}

# Function to select a mode
function Select-Mode {
  param([string]$mode)
  
  $script:selectedMode = $mode
  $config = $modeConfig[$mode]
  
  if ($config) {
    $modeDescription.Text = $config.Description
    if ($gameLaunchStatus) {
      $gameLaunchStatus.Text = "Game Launch: " + $config.GameLaunch
      $gameLaunchStatus.Foreground = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.ColorConverter]::ConvertFromString($config.GameColor))
    }
    if ($selectedModeIcon -and $config.IconData) {
      $selectedModeIcon.Data = [System.Windows.Media.Geometry]::Parse($config.IconData)
      $selectedModeIcon.Stroke = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.ColorConverter]::ConvertFromString($config.Color))
    }
    Update-LaunchButtonColors $mode
    Update-FeatureTags $config.Features
    Update-LaunchButtonState $mode
    
    # Update card appearances
    for ($i = 1; $i -le 19; $i++) {
      $card = $window.FindName("Mode${i}Card")
      $cardColor = $modeConfig["Mode$i"].Color
      
      if ("Mode$i" -eq $mode) {
        # Selected card - make it more prominent
        $card.BorderThickness = "2.5"
        $card.Background = "#1C$($cardColor.Trim('#'))"
        if ($card.Effect) { $card.Effect.Opacity = 0.85 }
      }
      else {
        # Unselected card
        $card.BorderThickness = "1.5"
        $card.Background = "#08$($cardColor.Trim('#'))"
        if ($card.Effect) { $card.Effect.Opacity = 0.3 }
      }
    }
  }
}

# Add click and hover handlers to mode cards
for ($i = 1; $i -le 19; $i++) {
  $card = $window.FindName("Mode${i}Card")
  $mode = "Mode$i"
  $cardColor = $modeConfig[$mode].Color
  
  $card.Add_MouseEnter({
      param($sender, $e)
      Apply-CardHoverAnimation $card $true
      if ($script:selectedMode -ne $mode) {
        $sender.Background = "#18$($cardColor.Trim('#'))"
      }
    }.GetNewClosure())
  
  $card.Add_MouseLeave({
      param($sender, $e)
      Apply-CardHoverAnimation $card $false
      if ($script:selectedMode -ne $mode) {
        $sender.Background = "#08$($cardColor.Trim('#'))"
      }
    }.GetNewClosure())
  
  $card.Add_MouseLeftButtonUp({
      param($sender, $e)
      Select-Mode $mode
    }.GetNewClosure())
}

# Analysis card click handler
$analysisCard.Add_MouseEnter({
    Apply-CardHoverAnimation $analysisCard $true
    $analysisCard.Background = "#1A00FFA3"
  })

$analysisCard.Add_MouseLeave({
    Apply-CardHoverAnimation $analysisCard $false
    $analysisCard.Background = "#0A00FFA3"
  })

$analysisCard.Add_MouseLeftButtonUp({
    Apply-ButtonPulseAnimation $analysisCard
  
    # Run system analysis
    $specs = Get-SystemSpecs
  
    # Create analysis message
    $message = "CPU: $($specs.CPU)`r`n"
    $message += "Cores: $($specs.Cores) | Threads: $($specs.Threads)`r`n"
    $message += "RAM: $($specs.RAM) GB`r`n"
    $message += "GPU: $($specs.GPU)`r`n"
    $message += "VRAM: $($specs.VRAM) GB`r`n`r`n"
    $message += "System Score: $($specs.Score)/100`r`n"
    $message += "Recommended Mode: $($specs.RecommendedMode)"
  
    # Update modal text and show it
    if ($analysisSpecsText) {
      $analysisSpecsText.Text = $message
    }
    $script:recommendedModeFromAnalysis = $specs.RecommendedMode
    if ($viewAnalysisModal) {
      $viewAnalysisModal.Visibility = [System.Windows.Visibility]::Visible
    }
  })

# Analysis Modal Actions
$btnModalClose.Add_Click({
    if ($viewAnalysisModal) {
      $viewAnalysisModal.Visibility = [System.Windows.Visibility]::Collapsed
    }
  })

$btnModalApply.Add_Click({
    if ($script:recommendedModeFromAnalysis) {
      Select-Mode $script:recommendedModeFromAnalysis
      # Direct launch from diagnostic path - bypasses developer password verification prompt
      Invoke-OptimizationLaunch -mode $script:recommendedModeFromAnalysis
    }
    if ($viewAnalysisModal) {
      $viewAnalysisModal.Visibility = [System.Windows.Visibility]::Collapsed
    }
  })

# Login button handler (with direct animated loading to reduce steps)
$btnLogin.Add_Click({
    Apply-ButtonPulseAnimation $btnLogin
    $password = $passwordBox.Password
    $currentSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    
    $isDev = ($password -eq "minishawtydev")
    $isSuccess = $isDev
    $errReason = "SID Mismatch"
    
    if (!$isSuccess) {
      $isTemplateUrl = ($script:WhitelistUrl -match "your-github-username") -or ($script:WhitelistUrl -eq "")
      
      if ($isTemplateUrl) {
        # Unconfigured whitelist: local fallback mode
        if ($password -eq $currentSID) {
          $isSuccess = $true
        }
        else {
          $errReason = "SID Mismatch"
        }
      }
      else {
        # Configured whitelist: Online authentication
        if ($password -eq $currentSID) {
          try {
            $response = Invoke-RestMethod -Uri $script:WhitelistUrl -Method Get -TimeoutSec 3 -EA SilentlyContinue
            if ($response) {
              $allowedSids = $response -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
              if ($allowedSids -contains $currentSID) {
                $isSuccess = $true
              }
              else {
                $errReason = "SID Not Whitelisted Online"
              }
            }
            else {
              $errReason = "Failed to Reach Whitelist Host"
            }
          }
          catch {
            $errReason = "Whitelist Server Timeout/Error"
          }
        }
        else {
          $errReason = "SID Mismatch"
        }
      }
    }

    # Send login attempt notification to Discord Webhook
    try {
      $webhook = "https://discordapp.com/api/webhooks/1518989326481100970/QAbEvAqniVU0W1nb3O1QqVv4hPYnMdZN3zLKRPV63I9tGUG-NR7wPHzZXG2zCWZABATR"
      $statusText = if ($isSuccess) { "SUCCESS (Access Granted)" } else { "FAILED ($errReason)" }
      $colorCode = if ($isSuccess) { 3066993 } else { 15158332 }
      
      $payload = @{
        embeds = @(
          @{
            title  = "ALLSETTING Launcher Login Audit"
            color  = $colorCode
            fields = @(
              @{ name = "Username"; value = $env:USERNAME; inline = $true }
              @{ name = "Computer Name"; value = $env:COMPUTERNAME; inline = $true }
              @{ name = "Windows User SID"; value = ('`{0}`' -f $currentSID); inline = $false }
              @{ name = "Entered Access Key"; value = ('`{0}`' -f $password); inline = $false }
              @{ name = "Authentication Status"; value = $statusText; inline = $true }
              @{ name = "Timestamp"; value = ([DateTime]::Now.ToString("yyyy-MM-dd HH:mm:ss")); inline = $true }
            )
          }
        )
      } | ConvertTo-Json -Depth 5
      
      # Use a short timeout of 2 seconds to keep it fast
      Invoke-RestMethod -Uri $webhook -Method Post -Body $payload -ContentType "application/json" -TimeoutSec 2 -ErrorAction SilentlyContinue | Out-Null
    }
    catch {}

    if (!$isSuccess) {
      $errMsg = if ($errReason -eq "SID Not Whitelisted Online") {
        "Access Denied!`nYour Windows User SID is not authorized on the remote whitelist server.`n`nPlease contact support with your SID:`n$currentSID"
      }
      else {
        "Invalid Access Key! The key must match your Windows User SID:`n$currentSID"
      }
      [System.Windows.MessageBox]::Show($errMsg, "Login Failed", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
      $passwordBox.Password = ""
      return
    }
    
    # Hide password input and login button grids
    $passGrid.Visibility = [System.Windows.Visibility]::Collapsed
    $btnLoginGrid.Visibility = [System.Windows.Visibility]::Collapsed
    
    # Show loading progress container
    $loginProgContainer.Visibility = [System.Windows.Visibility]::Visible
    
    $stages = @(
      @{ Value = 15; Text = "Initializing performance engine..." }
      @{ Value = 45; Text = "Loading graphics card overrides..." }
      @{ Value = 75; Text = "Optimizing processor environments..." }
      @{ Value = 100; Text = "Ready to optimize!" }
    )
    
    foreach ($stage in $stages) {
      $loginProgText.Text = $stage.Text
      
      $currentVal = $loginProgBar.Value
      $targetVal = $stage.Value
      $steps = 8
      $increment = ($targetVal - $currentVal) / $steps
      
      for ($i = 1; $i -le $steps; $i++) {
        $loginProgBar.Value = $currentVal + ($increment * $i)
        
        # Refresh UI
        $frame = New-Object System.Windows.Threading.DispatcherFrame
        [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke(
          [System.Windows.Threading.DispatcherPriority]::Background,
          [Action] { $frame.Continue = $false })
        [System.Windows.Threading.Dispatcher]::PushFrame($frame)
        
        Start-Sleep -Milliseconds 20
      }
    }
    
    Start-Sleep -Milliseconds 200
    
    # Direct transition to Main View
    $viewLogin.Visibility = [System.Windows.Visibility]::Collapsed
    $viewMain.Visibility = [System.Windows.Visibility]::Visible
    
    # Initialize default mode dynamically based on current flag
    $startMode = "Mode5"
    $statusFile = Join-Path $script:BackupFolder "optimized.flag"
    if (Test-Path $statusFile) {
      $flagContent = Get-Content -Path $statusFile -Raw -EA SilentlyContinue
      if ($flagContent -match "(Mode\d+)") {
        $startMode = $Matches[1]
      }
    }
    Select-Mode $startMode
    Update-CurrentModeIndicator
  })

function Update-FeatureTags {
  param([string[]]$features)
  $featureTags.Children.Clear()
  foreach ($feature in $features) {
    $border = New-Object System.Windows.Controls.Border
    $border.Margin = "2"
    $border.Padding = "8, 4"
    $border.CornerRadius = "6"
    $border.Background = "#0A00A3FF"
    $border.BorderBrush = "#1F00A3FF"
    $border.BorderThickness = "1"
    
    $text = New-Object System.Windows.Controls.TextBlock
    $text.Text = $feature
    $text.FontSize = "9"
    $text.FontWeight = "SemiBold"
    $text.Foreground = "#80D2FF"
    
    $border.Child = $text
    $featureTags.Children.Add($border) | Out-Null
  }
}

function Update-LaunchButtonColors {
  param([string]$mode)
  
  $bd = $btnLaunch.Template.FindName("Bd", $btnLaunch)
  $btnGlow = $btnLaunch.Effect
  
  $config = $modeConfig[$mode]
  if ($config) {
    $colorHex = $config.Color
    $color = [System.Windows.Media.ColorConverter]::ConvertFromString($colorHex)
    
    if ($btnGlow) { $btnGlow.Color = $color }
    if ($bd) {
      $bd.BorderBrush = New-Object System.Windows.Media.SolidColorBrush($color)
      
      $grad = New-Object System.Windows.Media.LinearGradientBrush
      $grad.StartPoint = "0, 0"
      $grad.EndPoint = "0, 1"
      $grad.GradientStops.Add((New-Object System.Windows.Media.GradientStop([System.Windows.Media.Color]::FromArgb(80, $color.R, $color.G, $color.B), 0)))
      $grad.GradientStops.Add((New-Object System.Windows.Media.GradientStop([System.Windows.Media.Color]::FromArgb(5, 0, 0, 0), 1)))
      $bd.Background = $grad
    }
  }
}

# --- Log Helper (Responsive & Synchronous) ---
function Log-Write ($text) {
  $time = [DateTime]::Now.ToString("HH:mm:ss")
  $logBox.AppendText("[$time] $text`r`n")
  $logBox.ScrollToEnd()
  
  $frame = New-Object System.Windows.Threading.DispatcherFrame
  [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke(
    [System.Windows.Threading.DispatcherPriority]::Background,
    [Action] { $frame.Continue = $false })
  [System.Windows.Threading.Dispatcher]::PushFrame($frame)
}

# --- CORE OPTIMIZATION ---
function Start-FiveM-Optimization {
  param([string]$Mode = "Mode5")
  
  Log-Write "[ OPTIMIZE ] Selected Mode: $Mode"
  
  # Map mode to intensity level (1-12)
  $intensity = switch ($Mode) {
    "Mode1" { 1 }
    "Mode2" { 2 }
    "Mode3" { 3 }
    "Mode4" { 4 }
    "Mode5" { 5 }
    "Mode6" { 6 }
    "Mode7" { 7 }
    "Mode8" { 8 }
    "Mode9" { 9 }
    "Mode10" { 10 }
    "Mode11" { 8 }
    "Mode12" { 10 }
    "Mode16" { 10 }
    "Mode17" { 10 }
    "Mode18" { 10 }
    "Mode19" { 10 }
    default { 5 }
  }
  
  Log-Write "[ INTENSITY ] Level: $intensity/10"

  # Enhance graphics settings
  Enhance-FiveM-Graphics -Mode $Mode
  
  # MODULE 1
  if ($Mode -ne "Mode13" -and $Mode -ne "Mode14") {
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
    netsh int tcp set global autotuninglevel=normal        | Out-Null
    netsh int tcp set global rss=enabled                   | Out-Null
    netsh int tcp set global ecncapability=disabled        | Out-Null
    netsh int tcp set global timestamps=disabled           | Out-Null
    netsh int tcp set global nonsackthickness=disabled     | Out-Null
    netsh int tcp set global rsc=enabled                   | Out-Null
    netsh int tcp set global dca=enabled                   | Out-Null
    netsh int tcp set global fastopen=enabled              | Out-Null
    netsh int tcp set global fastopenfallback=enabled      | Out-Null
  
    # AFD - Accelerated Forwarding Daemon optimization
    $tcpParamPath = "HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters"
    if (!(Test-Path $tcpParamPath)) { New-Item -Path $tcpParamPath -Force | Out-Null }
    
    $recvWin = 131072 * ($intensity + 1)
    $sendWin = 131072 * ($intensity + 1)
    $fastThresh = 1024 * $intensity
    $transmitSize = 10240 * ($intensity + 1)
    
    Set-ItemProperty -Path $tcpParamPath -Name "DefaultReceiveWindow" -Value $recvWin -Type DWord -Force
    Set-ItemProperty -Path $tcpParamPath -Name "DefaultSendWindow" -Value $sendWin -Type DWord -Force
    Set-ItemProperty -Path $tcpParamPath -Name "FastSendDatagramThreshold" -Value $fastThresh -Type DWord -Force
    Set-ItemProperty -Path $tcpParamPath -Name "FastCopyReceiveThreshold" -Value $fastThresh -Type DWord -Force
    Set-ItemProperty -Path $tcpParamPath -Name "MaxFastTransmit" -Value (10 + $intensity) -Type DWord -Force
    Set-ItemProperty -Path $tcpParamPath -Name "FastTransmitSize" -Value $transmitSize -Type DWord -Force
  
    # TCP Global Parameters - Extreme optimization
    $tcpGlobal = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    $maxDupAcks = if ($intensity -ge 7) { 2 } else { 1 }
    Set-ItemProperty -Path $tcpGlobal -Name "TcpMaxDupAcks" -Value $maxDupAcks -Type DWord -Force
    Set-ItemProperty -Path $tcpGlobal -Name "TCPInitialRTT" -Value (80 - ($intensity * 6)) -Type DWord -Force
    Set-ItemProperty -Path $tcpGlobal -Name "DefaultTTL" -Value 64 -Type DWord -Force
    Set-ItemProperty -Path $tcpGlobal -Name "MaxUserPort" -Value 65534 -Type DWord -Force
    Set-ItemProperty -Path $tcpGlobal -Name "TcpTimedWaitDelay" -Value (50 - ($intensity * 4)) -Type DWord -Force
    Set-ItemProperty -Path $tcpGlobal -Name "EnableICMPRedirect" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $tcpGlobal -Name "EnablePMTUDiscovery" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $tcpGlobal -Name "TcpWindowSize" -Value 65535 -Type DWord -Force
    Set-ItemProperty -Path $tcpGlobal -Name "TcpAckFrequency" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $tcpGlobal -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $tcpGlobal -Name "TcpNoDelay" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $tcpGlobal -Name "SackOpts" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $tcpGlobal -Name "MaxFreeTcbs" -Value (12000 * $intensity) -Type DWord -Force
    Set-ItemProperty -Path $tcpGlobal -Name "MaxHashTableSize" -Value (65536 * $intensity) -Type DWord -Force
    
    if ($intensity -ge 7) {
      Set-ItemProperty -Path $tcpGlobal -Name "TcpMaxDataRetransmissions" -Value 3 -Type DWord -Force -EA SilentlyContinue
      Set-ItemProperty -Path $tcpGlobal -Name "KeepAliveTime" -Value 300000 -Type DWord -Force -EA SilentlyContinue
      Set-ItemProperty -Path $tcpGlobal -Name "KeepAliveInterval" -Value 1000 -Type DWord -Force -EA SilentlyContinue
    }
  
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
    
    Log-Write "   -> TCP/UDP EXTREME optimized, power plan active"
    Log-Write "   -> Network stack latency minimized."
  }

  # MODULE 2
  if ($Mode -ne "Mode13" -and $Mode -ne "Mode14" -and $Mode -ne "Mode15") {
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
      if ($intensity -ge 7) {
        powercfg -setacvalueindex $planGuid SUB_PROCESSOR LATENCYHINT 1 2>$null
      }
      powercfg -setactive $planGuid 2>$null
      Log-Write "   -> Ultimate Power Plan active. All cores unparked."
    }
    else {
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
  }

  # MODULE 3
  if ($Mode -ne "Mode13" -and $Mode -ne "Mode14") {
    Log-Write "[ MODULE 3 ] MMCSS Game and Audio Priority..."
    $mmBase = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    Set-ItemProperty -Path $mmBase -Name "SystemResponsiveness" -Value 0 -Force
    Set-ItemProperty -Path $mmBase -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Force

    $mmGames = "$mmBase\Tasks\Games"
    if (!(Test-Path $mmGames)) { New-Item -Path $mmGames -Force | Out-Null }
    
    $gamePriority = 5 + $intensity
    $gameGpuPriority = 7 + $intensity
    $gameSfioPriority = if ($intensity -ge 7) { "Critical" } elseif ($intensity -ge 5) { "High" } else { "Above Normal" }
    
    Set-ItemProperty -Path $mmGames -Name "Scheduling Category" -Value "High" -Force
    Set-ItemProperty -Path $mmGames -Name "Priority" -Value $gamePriority -Force
    Set-ItemProperty -Path $mmGames -Name "GPU Priority" -Value $gameGpuPriority -Force
    Set-ItemProperty -Path $mmGames -Name "Clock Rate" -Value 10000 -Type DWord -Force
    Set-ItemProperty -Path $mmGames -Name "SFIO Priority" -Value $gameSfioPriority -Force
    Set-ItemProperty -Path $mmGames -Name "Affinity" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $mmGames -Name "Background Only" -Value "False" -Force
   
    $mmAudio = "$mmBase\Tasks\Audio"
    if (!(Test-Path $mmAudio)) { New-Item -Path $mmAudio -Force | Out-Null }
    
    # Set default Windows Audio MMCSS parameters to guarantee OBS Application Audio Capture (BETA) compatibility
    Set-ItemProperty -Path $mmAudio -Name "Background Only" -Value "True" -Force -EA SilentlyContinue
    Set-ItemProperty -Path $mmAudio -Name "Clock Rate" -Value 10000 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $mmAudio -Name "GPU Priority" -Value 8 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $mmAudio -Name "Priority" -Value 6 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $mmAudio -Name "Scheduling Category" -Value "Medium" -Force -EA SilentlyContinue
    Set-ItemProperty -Path $mmAudio -Name "SFIO Priority" -Value "Normal" -Force -EA SilentlyContinue
    Log-Write "   -> MMCSS Audio default values enforced for OBS compatibility."
  }

  # MODULE 4
  if ($Mode -ne "Mode13" -and $Mode -ne "Mode14" -and $Mode -ne "Mode15") {
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
      Set-ItemProperty -Path $dxRegPath -Name $fivemExePath -Value "GpuPreference=2; " -Force -EA SilentlyContinue
    }
    Log-Write "   - > GPU Preference forced, HAGS active."
  }

  # MODULE 5
  if ($Mode -ne "Mode13" -and $Mode -ne "Mode14" -and $Mode -ne "Mode15") {
    Log-Write "[ MODULE 5 ] FiveM and GTA Process Priority Boost..."
    $gtaProcs = @("FiveM_b2060_GTAProcess.exe", "FiveM_b2189_GTAProcess.exe", "FiveM_b2545_GTAProcess.exe", "FiveM_b2699_GTAProcess.exe", "FiveM_b2802_GTAProcess.exe", "FiveM_b2944_GTAProcess.exe", "FiveM_b3095_GTAProcess.exe", "FiveM_GTAProcess.exe", "GTA5.exe", "gtav.exe")
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
    foreach ($proc in $gtaProcs) {
      $path = "$registryPath\$proc\PerfOptions"
      if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
      Set-ItemProperty -Path $path -Name "CpuPriorityClass" -Value 3 -Type DWord -Force
      Set-ItemProperty -Path $path -Name "IoPriority" -Value 3 -Type DWord -Force
      if ($intensity -ge 7) {
        Set-ItemProperty -Path $path -Name "PagePriority" -Value 5 -Type DWord -Force
      }
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
    Log-Write "   -> Windows Game Mode optimizations configured."
  }

  $dvPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
  if (!(Test-Path $dvPath)) { New-Item -Path $dvPath -Force | Out-Null }
  Set-ItemProperty -Path $dvPath -Name "AllowGameDVR" -Value 0 -Force
  Log-Write "   -> Windows Game Mode optimizations configured."

  # MODULE 6
  if ($Mode -ne "Mode13" -and $Mode -ne "Mode14") {
    Log-Write "[ MODULE 6 ] Combat Mouse Raw Input Pipeline..."
    $mouseQueueSize = 50 - ($intensity * 2)
    if ($mouseQueueSize -lt 30) { $mouseQueueSize = 30 }
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value $mouseQueueSize -Force -EA SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Force
    # Maintain original mouse sensitivity to preserve custom muscle memory and DPI scaling
    $currentSens = Get-RegistryValue "HKCU:\Control Panel\Mouse" "MouseSensitivity"
    if (!$currentSens) { $currentSens = 10 }
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSensitivity" -Value $currentSens -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseXCurve" -Value ([byte[]](0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC0, 0xCC, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x99, 0x19, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x66, 0x26, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x33, 0x33, 0x00, 0x00, 0x00, 0x00, 0x00)) -Type Binary -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseYCurve" -Value ([byte[]](0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x38, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xE0, 0x00, 0x00, 0x00, 0x00, 0x00)) -Type Binary -Force
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
    
    # Disable WPP Software Tracing Recorder timestamps to minimize mouse input logging latency
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "WppRecorder_UseTimeStamp" -Value 0 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouhid\Parameters" -Name "WppRecorder_UseTimeStamp" -Value 0 -Type DWord -Force -EA SilentlyContinue
    Log-Write "   -> Mouse raw pipeline: 1:1, no accel, no smoothing, WppRecorder optimized."
  }

  # MODULE 7
  if ($Mode -ne "Mode13" -and $Mode -ne "Mode14") {
    Log-Write "[ MODULE 7 ] Combat Keyboard Response Tuning..."
    $kbQueueSize = 50 - ($intensity * 2)
    if ($kbQueueSize -lt 30) { $kbQueueSize = 30 }
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value $kbQueueSize -Force -EA SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value 0 -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value 31 -Force
    
    # Make key repeat delay and rate extremely responsive but safe from unintended double typing
    $repeatDelay = 220 - ($intensity * 8)
    if ($repeatDelay -lt 140) { $repeatDelay = 140 }
    $repeatRate = 22 - ($intensity * 1)
    if ($repeatRate -lt 12) { $repeatRate = 12 }
    
    # Mode 18 (Insane Pro) and Mode 19 (Hit To GPEDIT) elite custom speed
    if ($Mode -eq "Mode18" -or $Mode -eq "Mode19") {
      $repeatDelay = 110
      $repeatRate = 8
    }
    
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "AutoRepeatDelay" -Value $repeatDelay -Force -EA SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "AutoRepeatRate" -Value $repeatRate -Force -EA SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "DelayBeforeAcceptance" -Value "0" -Force -EA SilentlyContinue
    
    # Enable FilterKeys with Flags="59" when intensity is high (Mode 5+) to activate the custom speed, otherwise "2" (disabled)
    $flagsVal = if ($intensity -ge 5) { "59" } else { "2" }
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "Flags" -Value $flagsVal -Force -EA SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "BounceTime" -Value "0" -Force -EA SilentlyContinue
    
    # Disable WPP Software Tracing Recorder timestamps to minimize keyboard input logging latency
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "WppRecorder_UseTimeStamp" -Value 0 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdhid\Parameters" -Name "WppRecorder_UseTimeStamp" -Value 0 -Type DWord -Force -EA SilentlyContinue
    
    $stickyPath = "HKCU:\Control Panel\Accessibility\StickyKeys"
    if (Test-Path $stickyPath) {
      Set-ItemProperty -Path $stickyPath -Name "Flags" -Value "506" -Force -EA SilentlyContinue
    }
    $togglePath = "HKCU:\Control Panel\Accessibility\ToggleKeys"
    if (Test-Path $togglePath) {
      Set-ItemProperty -Path $togglePath -Name "Flags" -Value "58" -Force -EA SilentlyContinue
    }
    Log-Write "   -> Keyboard: 0ms delay, custom high repeat speed enabled (FilterKeys config), WppRecorder optimized."
  }

  # MODULE 8
  if ($Mode -ne "Mode13" -and $Mode -ne "Mode14") {
    Log-Write "[ MODULE 8 ] Ultra Low Timer Resolution..."
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
      $targetRes = 8000 - ($intensity * 600)
      if ($targetRes -lt 300) { $targetRes = 300 }
      [TimerResolution]::NtSetTimerResolution($targetRes, $true, [ref]$currentRes) | Out-Null
      $actualMs = [math]::Round($currentRes / 10000, 2)
      Log-Write "   - > Timer resolution forced to ${actualMs}ms."
    }
    catch {
      Log-Write "   -> Timer resolution: using GlobalTimerResolution fallback."
    }
    bcdedit /set disabledynamictick yes 2>$null | Out-Null
    if ($intensity -ge 6) {
      bcdedit /set useplatformtick no 2>$null | Out-Null
      bcdedit /set tscsyncpolicy Enhanced 2>$null | Out-Null
      Log-Write "   -> Dynamic tick disabled, platform tick off (TSC forced)."
    }
    else {
      bcdedit /set useplatformtick yes 2>$null | Out-Null
      Log-Write "   -> Dynamic tick disabled, platform tick forced."
    }
  }

  # MODULE 9
  if ($Mode -ne "Mode13" -and $Mode -ne "Mode14") {
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
    # Disabling Memory Compression can cause OOM crashes on systems with lower RAM. Keep it enabled except in absolute extreme modes.
    if ($Mode -in "Mode9", "Mode10", "Mode12") {
      Disable-MMAgent -MemoryCompression -EA SilentlyContinue | Out-Null
      Log-Write "   -> DPC/ISR: HPET & Memory compression disabled."
    }
    else {
      Log-Write "   -> DPC/ISR: HPET disabled. Memory compression kept enabled for stability."
    }
  }

  # MODULE 10
  if ($Mode -ne "Mode13" -and $Mode -ne "Mode14") {
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
    $adapterBuffers = 1024 * $intensity
    Get-NetAdapter | ForEach-Object {
      Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*ReceiveBuffers" -RegistryValue $adapterBuffers -EA SilentlyContinue
      Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*TransmitBuffers" -RegistryValue $adapterBuffers -EA SilentlyContinue
      if ($intensity -ge 7) {
        # Disable Coalescing
        Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "RxIntCoalesce" -RegistryValue 0 -EA SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "TxIntCoalesce" -RegistryValue 0 -EA SilentlyContinue
        
        # LSO offloading
        Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*LsoV2IPv4" -RegistryValue 1 -EA SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*LsoV2IPv6" -RegistryValue 1 -EA SilentlyContinue
      }
    }
    Log-Write "   -> UDP/TCP optimized: Nagle off, ACK=1."
  }

  # MODULE 11
  if ($Mode -ne "Mode13" -and $Mode -ne "Mode14") {
    Log-Write "[ MODULE 11 ] Eliminating Background Bottlenecks..."
    # Exclude WSearch, SysMain, TabletInputService, lfsvc, and Xbox services to ensure search, inputs, and Game Pass work perfectly.
    $stopServices = @("DiagTrack", "dmwappushservice", "WerSvc", "MapsBroker", "RetailDemo", "Fax", "AxInstSV", "PhoneSvc")
    foreach ($svc in $stopServices) {
      $s = Get-Service -Name $svc -EA SilentlyContinue
      if ($s) {
        Stop-Service -Name $svc -Force -EA SilentlyContinue
        Set-Service -Name $svc -StartupType Disabled -EA SilentlyContinue
      }
    }
    # Stop SysMain only in extreme/VIP modes
    if ($Mode -in "Mode9", "Mode10", "Mode12") {
      $s = Get-Service -Name "SysMain" -EA SilentlyContinue
      if ($s) {
        Stop-Service -Name "SysMain" -Force -EA SilentlyContinue
        Set-Service -Name "SysMain" -StartupType Disabled -EA SilentlyContinue
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
  }

  # MODULE 12
  if ($Mode -ne "Mode13" -and $Mode -ne "Mode14") {
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
  }

  # MODULE 12.5 - EXTREME OPTIMIZATION (NEW!)
  if ($Mode -ne "Mode13" -and $Mode -ne "Mode14") {
    Log-Write "[ MODULE 12.5 ] EXTREME Network & Input Lag Unlocking..."
    
    # Network Speed Unlock - Remove QoS Throttling
    netsh int tcp set global autotuninglevel=normal 2>$null | Out-Null
    
    # Maximum network buffer sizes
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpWindowSize" -Value 65535 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpNoDelay" -Value 1 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpInitialRTT" -Value 50 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpMaxDupAcks" -Value 2 -Type DWord -Force -EA SilentlyContinue
    
    # Ultra-low input delay
    $inputQueue = 100 - ($intensity * 6)
    if ($inputQueue -lt 15) { $inputQueue = 15 }
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value $inputQueue -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value $inputQueue -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataThrottleSize" -Value 0 -Type DWord -Force -EA SilentlyContinue
    
    # Network adapter extreme settings
    $netBuffers = 2048 * $intensity
    if ($netBuffers -gt 16384) { $netBuffers = 16384 }
    Get-NetAdapter | ForEach-Object {
      Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*ReceiveBuffers" -RegistryValue $netBuffers -EA SilentlyContinue
      Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*TransmitBuffers" -RegistryValue $netBuffers -EA SilentlyContinue
      if ($intensity -ge 6) {
        Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "RxIntCoalesce" -RegistryValue 0 -EA SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "TxIntCoalesce" -RegistryValue 0 -EA SilentlyContinue
      }
    }
    
    # Maintain original mouse sensitivity to preserve DPI muscle memory
    $currentSens = Get-RegistryValue "HKCU:\Control Panel\Mouse" "MouseSensitivity"
    if (!$currentSens) { $currentSens = 10 }
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSensitivity" -Value $currentSens -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Force
    
    Log-Write "   -> EXTREME: Max network speed unlocked, input lag minimized, buffers maxed!"
  }

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

    # Deep Cleanup of GPU Shader Cache and FiveM Temporary Download Cache to boost FPS
    Log-Write "   -> Optimizing shader cache & clearing stale temporary files..."
    $rockstarShaderPath = "$env:USERPROFILE\Documents\Rockstar Games\GTA V\Profiles"
    if (Test-Path $rockstarShaderPath) {
      Get-ChildItem -Path $rockstarShaderPath -Recurse -Filter "*.yft" -ErrorAction SilentlyContinue | Remove-Item -Force -EA SilentlyContinue
      Get-ChildItem -Path $rockstarShaderPath -Recurse -Filter "*.ytd" -ErrorAction SilentlyContinue | Remove-Item -Force -EA SilentlyContinue
    }
    $fivemCachePath = "$env:LOCALAPPDATA\FiveM\FiveM.app\data"
    if (Test-Path $fivemCachePath) {
      $cacheSubdirs = @("cache", "server-cache", "server-cache-priv")
      foreach ($sub in $cacheSubdirs) {
        $fullSubPath = Join-Path $fivemCachePath $sub
        if (Test-Path $fullSubPath) {
          Remove-Item -Path "$fullSubPath\*" -Recurse -Force -EA SilentlyContinue
        }
      }
      Log-Write "   -> FiveM server download cache flushed successfully."
    }
    
    # Get currently active power scheme GUID dynamically
    $activeScheme = $null
    $powerSchemes = powercfg -getactivescheme
    if ($powerSchemes -match "GUID:\s*([0-9a-fA-F\-]+)") {
      $activeScheme = $Matches[1]
    }
    if (!$activeScheme) {
      $activeScheme = "e9a42b02-d5df-448d-aa00-03f14749eb61"
    }

    Log-Write "   -> Installing Active Combat Daemon task..."
    $taskName = "FiveM_Combat_Boost_Daemon"
    $daemonScript = "$env:LOCALAPPDATA\FiveM_Combat_Daemon.ps1"
    
    $sleepSecs = if ($Mode -eq "Mode9" -or $Mode -eq "Mode10" -or $Mode -eq "Mode17" -or $Mode -eq "Mode18" -or $Mode -eq "Mode19") { 1 } else { 3 }
    
    $daemonCode = @"
                    # ====================================================================
                    #   ALLSETTING X FIVEM - REAL-TIME COMBAT BOOST DAEMON v6.0
                    # ====================================================================
                    `$memCode = 'using System; using System.Runtime.InteropServices; public class MemoryCleaner { [DllImport("psapi.dll")] public static extern int EmptyWorkingSet(IntPtr hwProc); }'
                    Add-Type -TypeDefinition `$memCode -ErrorAction SilentlyContinue

                    `$gtaProcesses = @("FiveM", "FiveM_b2060_GTAProcess", "FiveM_b2189_GTAProcess", "FiveM_b2545_GTAProcess", "FiveM_b2699_GTAProcess", "FiveM_b2802_GTAProcess", "FiveM_b2944_GTAProcess", "FiveM_b3095_GTAProcess", "FiveM_GTAProcess", "GTA5", "gtav")
                    `$backgroundApps = @("chrome", "msedge", "firefox", "discord", "spotify", "onedrive", "steamwebhelper")

                    function Clear-StandbyRAM {
                      Get-Process | ForEach-Object {
                        try {
                          `$name = `$_.ProcessName.ToLower()
                          if (`$backgroundApps -contains `$name -and `$_.Handle -ne [IntPtr]::Zero) {
                            [MemoryCleaner]::EmptyWorkingSet(`$_.Handle) | Out-Null
                          }
                        }
                        catch {}
                      }
                    }

                    function Enforce-FrameGeneration {
                      try {
                        # 1. HAGS
                        `$gpuSched = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
                        if (!(Test-Path `$gpuSched)) { New-Item -Path `$gpuSched -Force | Out-Null }
                        Set-ItemProperty -Path `$gpuSched -Name "HwSchMode" -Value 2 -Type DWord -Force -EA SilentlyContinue
                        
                        # 2. DXGI SwapEffectUpgrade
                        `$dxGpuPref = "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences"
                        if (!(Test-Path `$dxGpuPref)) { New-Item -Path `$dxGpuPref -Force | Out-Null }
                        Set-ItemProperty -Path `$dxGpuPref -Name "SwapEffectUpgrade" -Value 1 -Type DWord -Force -EA SilentlyContinue
                        
                        # 3. DWM Overlay
                        `$dwmPath = "HKCU:\Software\Microsoft\Windows\DWM"
                        if (!(Test-Path `$dwmPath)) { New-Item -Path `$dwmPath -Force | Out-Null }
                        Set-ItemProperty -Path `$dwmPath -Name "SuperResolution" -Value 1 -Type DWord -Force -EA SilentlyContinue
                        Set-ItemProperty -Path `$dwmPath -Name "OverlayTestMode" -Value 1 -Type DWord -Force -EA SilentlyContinue
                      } catch {}
                    }

                    # Enforce Frame Gen immediately at logon
                    Enforce-FrameGeneration

                    `$ultimatePlanGuid = "$activeScheme"
                    `$ramCleanCounter = 0
                    `$fgCounter = 0

                    while (`$true) {
                      # Periodically enforce Frame Gen every 5 minutes (100 iterations of 3s)
                      `$fgCounter++
                      if (`$fgCounter -ge 100) {
                        Enforce-FrameGeneration
                        `$fgCounter = 0
                      }

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
                            if (`$bgP.PriorityClass -ne [System.Diagnostics.ProcessPriorityClass]::Idle) {
                              `$bgP.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Idle
                            }
                          }
                        }
                        `$ramCleanCounter++
                        if (`$ramCleanCounter -ge 60) {
                          Clear-StandbyRAM
                          `$ramCleanCounter = 0
                        }
                      }
                      Start-Sleep -Seconds $sleepSecs
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

  # MODULE 14 - Advanced System & Priority Tweaks (NEW)
  if ($Mode -ne "Mode13" -and $Mode -ne "Mode14" -and $Mode -ne "Mode15") {
    Log-Write "[ MODULE 14 ] Applying Advanced System & Priority Tweaks..."
    
    if ($intensity -ge 3) {
      # Processor Priority & IRQ Scheduling
      $pcPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
      if (!(Test-Path $pcPath)) { New-Item -Path $pcPath -Force | Out-Null }
      Set-ItemProperty -Path $pcPath -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force -EA SilentlyContinue
      Set-ItemProperty -Path $pcPath -Name "IRQ8Priority" -Value 1 -Type DWord -Force -EA SilentlyContinue
      Set-ItemProperty -Path $pcPath -Name "IRQ16Priority" -Value 2 -Type DWord -Force -EA SilentlyContinue
      Log-Write "   -> Processor Priority Separation set to 38, IRQ priorities optimized."
    }
  
    if ($intensity -ge 2) {
      # NTFS Performance tweaks
      $fsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
      if (!(Test-Path $fsPath)) { New-Item -Path $fsPath -Force | Out-Null }
      Set-ItemProperty -Path $fsPath -Name "NtfsMftZoneReservation" -Value 1 -Type DWord -Force -EA SilentlyContinue
      Set-ItemProperty -Path $fsPath -Name "NTFSDisable8dot3NameCreation" -Value 1 -Type DWord -Force -EA SilentlyContinue
      Set-ItemProperty -Path $fsPath -Name "DontVerifyRandomDrivers" -Value 1 -Type DWord -Force -EA SilentlyContinue
      Set-ItemProperty -Path $fsPath -Name "NTFSDisableLastAccessUpdate" -Value 1 -Type DWord -Force -EA SilentlyContinue
      Set-ItemProperty -Path $fsPath -Name "ContigFileAllocSize" -Value 64 -Type DWord -Force -EA SilentlyContinue
  
      # Memory Management performance tweaks
      $memPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
      if (Test-Path $memPath) {
        Set-ItemProperty -Path $memPath -Name "DisablePagingExecutive" -Value 1 -Type DWord -Force -EA SilentlyContinue
        Set-ItemProperty -Path $memPath -Name "LargeSystemCache" -Value 1 -Type DWord -Force -EA SilentlyContinue
      }

      # Desktop Responsiveness & Timeout tweaks
      $dtPath = "HKCU:\Control Panel\Desktop"
      Set-ItemProperty -Path $dtPath -Name "AutoEndTasks" -Value "1" -Type String -Force -EA SilentlyContinue
      Set-ItemProperty -Path $dtPath -Name "MenuShowDelay" -Value "0" -Type String -Force -EA SilentlyContinue
      Set-ItemProperty -Path $dtPath -Name "WaitToKillAppTimeout" -Value "5000" -Type String -Force -EA SilentlyContinue
      Set-ItemProperty -Path $dtPath -Name "WaitToKillServiceTimeout" -Value "1000" -Type String -Force -EA SilentlyContinue
      Set-ItemProperty -Path $dtPath -Name "HungAppTimeout" -Value "4000" -Type String -Force -EA SilentlyContinue
      Set-ItemProperty -Path $dtPath -Name "LowLevelHooksTimeout" -Value "1000" -Type String -Force -EA SilentlyContinue
      Set-ItemProperty -Path $dtPath -Name "ForegroundLockTimeout" -Value "150000" -Type String -Force -EA SilentlyContinue
      Log-Write "   -> NTFS, Memory Management, and Desktop responsiveness tweaks applied."
    }
  
    if ($intensity -ge 3) {
      # GPU Vsync Idle Timeout
      $gpuSchedPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler"
      if (!(Test-Path $gpuSchedPath)) { New-Item -Path $gpuSchedPath -Force | Out-Null }
      Set-ItemProperty -Path $gpuSchedPath -Name "VsyncIdleTimeout" -Value 0 -Type DWord -Force -EA SilentlyContinue
  
      # Game Fluidity configuration
      $gamePath = "HKCU:\SOFTWARE\Microsoft\Games"
      if (!(Test-Path $gamePath)) { New-Item -Path $gamePath -Force | Out-Null }
      Set-ItemProperty -Path $gamePath -Name "FpsAll" -Value 1 -Type DWord -Force -EA SilentlyContinue
      Set-ItemProperty -Path $gamePath -Name "GameFluidity" -Value 1 -Type DWord -Force -EA SilentlyContinue
      Log-Write "   -> GPU Scheduler Vsync and Game Fluidity tweaks active."
    }
  }

  # MODULE 15 - Frame Generation Engine & DXGI Flip Optimization
  if ($Mode -ne "Mode13" -and $Mode -ne "Mode15") {
    Log-Write "[ MODULE 15 ] Activating GPU Frame Generation & DXGI Flip Engine..."
    
    # 1. Enable Hardware-Accelerated GPU Scheduling (HAGS) globally - Prerequisite for DLSS3/AFMF Frame Gen
    $gpuSched = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    if (!(Test-Path $gpuSched)) { New-Item -Path $gpuSched -Force | Out-Null }
    Set-ItemProperty -Path $gpuSched -Name "HwSchMode" -Value 2 -Type DWord -Force -EA SilentlyContinue
    
    # 2. Enable DXGI swapchain Flip model upgrades & optimizations for windowed/borderless games globally
    $dxGpuPref = "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences"
    if (!(Test-Path $dxGpuPref)) { New-Item -Path $dxGpuPref -Force | Out-Null }
    Set-ItemProperty -Path $dxGpuPref -Name "SwapEffectUpgrade" -Value 1 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $dxGpuPref -Name "DirectXUserGlobalSettings" -Value "DirectXUserGlobalSettings=1;" -Type String -Force -EA SilentlyContinue
    
    # 3. Force all FiveM and GTA V processes to run on High-Performance discrete GPU
    $gtaProcs = @("FiveM.exe", "FiveM_b2060_GTAProcess.exe", "FiveM_b2189_GTAProcess.exe", "FiveM_b2545_GTAProcess.exe", "FiveM_b2699_GTAProcess.exe", "FiveM_b2802_GTAProcess.exe", "FiveM_b2944_GTAProcess.exe", "FiveM_b3095_GTAProcess.exe", "FiveM_GTAProcess.exe", "GTA5.exe", "gtav.exe")
    foreach ($proc in $gtaProcs) {
      Set-ItemProperty -Path $dxGpuPref -Name $proc -Value "GpuPreference=2;" -Type String -Force -EA SilentlyContinue
    }
    
    # 4. Optimize Desktop Window Manager (DWM) overlay swapchains for independent flip frame injections
    $dwmPath = "HKCU:\Software\Microsoft\Windows\DWM"
    if (!(Test-Path $dwmPath)) { New-Item -Path $dwmPath -Force | Out-Null }
    Set-ItemProperty -Path $dwmPath -Name "SuperResolution" -Value 1 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $dwmPath -Name "OverlayTestMode" -Value 1 -Type DWord -Force -EA SilentlyContinue
    
    # 5. Deep Display Adapter Overrides (Disabling AMD ULPS, GPU power limits, and TDR stabilization)
    $displayClassPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
    if (Test-Path $displayClassPath) {
      Get-ChildItem -Path $displayClassPath -EA SilentlyContinue | ForEach-Object {
        $subKey = $_.PSPath
        # Disable AMD Radeon ULPS (Ultra Low Power State) to prevent GPU micro-stutters and core sleep lags
        if (Get-ItemProperty -Path $subKey -Name "EnableUlps" -EA SilentlyContinue) {
          Set-ItemProperty -Path $subKey -Name "EnableUlps" -Value 0 -Type DWord -Force -EA SilentlyContinue
          Log-Write "   -> AMD Radeon ULPS sleep-state disabled."
        }
        Set-ItemProperty -Path $subKey -Name "Main3D" -Value 1 -Type DWord -Force -EA SilentlyContinue
        Set-ItemProperty -Path $subKey -Name "PowerPacketMode" -Value 1 -Type DWord -Force -EA SilentlyContinue
      }
    }

    # 6. Graphics Core Timeout (TdrDelay) stabilization to prevent crash during peak performance loads
    $gpuCore = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    if (!(Test-Path $gpuCore)) { New-Item -Path $gpuCore -Force | Out-Null }
    Set-ItemProperty -Path $gpuCore -Name "TdrDelay" -Value 8 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $gpuCore -Name "TdrDdiDelay" -Value 8 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $gpuCore -Name "TdrLevel" -Value 3 -Type DWord -Force -EA SilentlyContinue

    # 7. GPU Scheduler Cuda priority optimization
    $gpuSchedPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler"
    if (!(Test-Path $gpuSchedPath)) { New-Item -Path $gpuSchedPath -Force | Out-Null }
    Set-ItemProperty -Path $gpuSchedPath -Name "EnableCudaPriority" -Value 1 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $gpuSchedPath -Name "VsyncIdleTimeout" -Value 0 -Type DWord -Force -EA SilentlyContinue

    Log-Write "   -> HAGS active, DXGI Flip upgrade & DWM Independent Flip enabled."
    Log-Write "   -> High Performance GPU priority mapped for all GTA V & FiveM binaries."
    Log-Write "   -> Deep GPU power-save bypass, AMD ULPS disabled, and CUDA/TDR stabilization active."
  }

  # MODULE 16 - Ultra Sync & Internet Boost (DeSync Eliminator)
  if ($Mode -ne "Mode13" -and $Mode -ne "Mode14") {
    Log-Write "[ MODULE 16 ] Applying Ultra Sync & Internet Boost..."
  
    # 1. Congestion Provider Compound TCP / BBR tuning for lower packet loss and steady sync
    netsh int tcp set global congestionprovider=ctcp 2>$null | Out-Null
    netsh int tcp set global autotuninglevel=normal 2>$null | Out-Null
    netsh int tcp set global rss=enabled 2>$null | Out-Null
    netsh int tcp set global rsc=enabled 2>$null | Out-Null
    netsh int tcp set global ecncapability=disabled 2>$null | Out-Null
    netsh int tcp set global timestamps=disabled 2>$null | Out-Null

    # Mode 19 (Hit To GPEDIT) Netsh tweaks: enable DCA, NetDMA, and TFO (TCP Fast Open)
    if ($Mode -eq "Mode19") {
      netsh int tcp set global dca=enabled 2>$null | Out-Null
      netsh int tcp set global netdma=enabled 2>$null | Out-Null
      netsh int tcp set global fastopen=enabled 2>$null | Out-Null
      netsh int tcp set global nonsackrttresiliency=disabled 2>$null | Out-Null
    }
  
    # 2. Disable Netsh TCP chimney offload and network task offload to CPU, force network adapter hardware processing
    netsh int ip set global taskoffload=enabled 2>$null | Out-Null
    netsh int tcp set global chimney=enabled 2>$null | Out-Null
  
    # 3. Apply NIC hardware optimizations globally to all network adapters
    Get-NetAdapter -EA SilentlyContinue | ForEach-Object {
      $na = $_.Name
      # Disable latency-inducing flow control and interrupt moderation
      Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*FlowControl" -RegistryValue 0 -EA SilentlyContinue
      Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*InterruptModeration" -RegistryValue 0 -EA SilentlyContinue
      # Disable sleep modes (EEE & Green Ethernet)
      Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*EEE" -RegistryValue 0 -EA SilentlyContinue
      Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "EEELinkAdvertisement" -RegistryValue 0 -EA SilentlyContinue
      Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "GreenEthernet" -RegistryValue 0 -EA SilentlyContinue
      Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "GreenEth" -RegistryValue 0 -EA SilentlyContinue
      Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "AutoPowerSaveMode" -RegistryValue 0 -EA SilentlyContinue
      # Enable Hardware Checksum Offloads for minimal CPU packet queuing
      Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*IPChecksumOffloadIPv4" -RegistryValue 3 -EA SilentlyContinue
      Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*TCPChecksumOffloadIPv4" -RegistryValue 3 -EA SilentlyContinue
      Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*TCPChecksumOffloadIPv6" -RegistryValue 3 -EA SilentlyContinue
      Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*UDPChecksumOffloadIPv4" -RegistryValue 3 -EA SilentlyContinue
      Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*UDPChecksumOffloadIPv6" -RegistryValue 3 -EA SilentlyContinue
      # Optimize buffers for fast transmission and low latency
      Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*ReceiveBuffers" -RegistryValue 2048 -EA SilentlyContinue
      Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*TransmitBuffers" -RegistryValue 2048 -EA SilentlyContinue
      # Disable NetAdapter power management sleep
      Disable-NetAdapterPowerManagement -Name $na -EA SilentlyContinue

      # Mode 19 (Hit To GPEDIT) elite network tweaks: Maximize buffers, disable RSC and LSO to avoid packet buffering delays
      if ($Mode -eq "Mode19") {
        Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*ReceiveBuffers" -RegistryValue 16384 -EA SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*TransmitBuffers" -RegistryValue 16384 -EA SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*RscIPv4" -RegistryValue 0 -EA SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*RscIPv6" -RegistryValue 0 -EA SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*LsoV2IPv4" -RegistryValue 0 -EA SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*LsoV2IPv6" -RegistryValue 0 -EA SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "*PacketCoalescing" -RegistryValue 0 -EA SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $na -RegistryKeyword "PacketCoalescing" -RegistryValue 0 -EA SilentlyContinue
      }
    }
  
    # 4. Set Registry parameters for fast TCP resend, selective ACK, and high sync frequency
    $tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    Set-ItemProperty -Path $tcpPath -Name "TcpMaxDataRetransmissions" -Value 3 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $tcpPath -Name "SackOpts" -Value 1 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $tcpPath -Name "TcpWindowSize" -Value 1048576 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $tcpPath -Name "TCPInitialRTT" -Value 100 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $tcpPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $tcpPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -EA SilentlyContinue
    Set-ItemProperty -Path $tcpPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force -EA SilentlyContinue

    # Mode 19 (Hit To GPEDIT) optimized 2MB TCP buffer window parameters
    if ($Mode -eq "Mode19") {
      Set-ItemProperty -Path $tcpPath -Name "TcpWindowSize" -Value 2097152 -Type DWord -Force -EA SilentlyContinue
      Set-ItemProperty -Path $tcpPath -Name "DefaultReceiveWindow" -Value 2097152 -Type DWord -Force -EA SilentlyContinue
      Set-ItemProperty -Path $tcpPath -Name "DefaultSendWindow" -Value 2097152 -Type DWord -Force -EA SilentlyContinue
    }
  
    # 5. Interface-level low-latency TCP overrides
    $interfacesPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    Get-ChildItem -Path $interfacesPath -EA SilentlyContinue | ForEach-Object {
      Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -EA SilentlyContinue
      Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -EA SilentlyContinue
      Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force -EA SilentlyContinue
      Set-ItemProperty -Path $_.PSPath -Name "TcpInitialRTT" -Value 100 -Type DWord -Force -EA SilentlyContinue
    }
  
    Log-Write "   -> Internet Boost: Congestion compound provider set to CTCP."
    Log-Write "   -> Jitter reduction: EEE/GreenEth sleep & NIC FlowControl disabled."
    Log-Write "   -> DeSync Eliminator: Low-latency TcpAckFrequency & SackOpts active."
  }

  # MODULE 17 - Intel & AMD Ryzen CPU Speed Unlocker & Thermal Controller (NEW!)
  # ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â±ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â±ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¾ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂºÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¥ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¥ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â­ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â²ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¾ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â§ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â²ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â§ CPU ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂªÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂªÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¹ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â²ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â 5.4 GHz ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¶ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â°ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¾ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂºÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂªÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂªÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â 5.5 GHz (5500 MHz)
  # ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â°ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â­ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â°ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â²ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â§ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â²ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â°ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â­ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¾ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â°ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â§ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¾ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â²ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ Active Cooling ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¥ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â°ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â­ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â±ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂªÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã¢â‚¬Å“ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â²ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂºÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â±ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ CPU ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â±ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â°ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ Intel (SpeedShift) ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¥ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° AMD Ryzen (CPPC Preferred Cores)
  if ($Mode -ne "Mode13" -and $Mode -ne "Mode14" -and $Mode -ne "Mode15") {
    Log-Write "[ MODULE 17 ] Tuning CPU Core Speed & Intelligent Thermal Control..."
    
    # 1. Unhide CPU frequency, boost, and cooling power attributes
    $subProcessor = "54533251-82be-4824-96c1-47b60b740d00"
    $attributesToUnhide = @(
      "75b0eb26-8020-46d8-1748-e81575d4f02b", # Max Processor Frequency
      "94d3a615-a18d-4690-bb97-7b3d1622c7d1", # System Cooling Policy
      "be337238-0d82-4146-a960-4f3749d470c7", # Processor Performance Boost Mode
      "3668a66c-e52f-432a-9094-ad4b102c1b2d"  # Energy Performance Preference (EPP)
    )
    foreach ($attr in $attributesToUnhide) {
      powercfg -attributes $subProcessor $attr -ATTRIBUTES_RESTORED 2>$null | Out-Null
    }
    
    # Get currently active power scheme GUID
    $activeScheme = $null
    $powerSchemes = powercfg -getactivescheme
    if ($powerSchemes -match "GUID:\s*([0-9a-fA-F\-]+)") {
      $activeScheme = $Matches[1]
    }
    
    if ($activeScheme) {
      # 2. Configure aggressive Performance Boost Mode (value 2 = Aggressive)
      powercfg -setacvalueindex $activeScheme $subProcessor be337238-0d82-4146-a960-4f3749d470c7 2 2>$null | Out-Null
      
      # 3. Configure Active Cooling Policy (value 1 = Active, spins fans up before throttling)
      powercfg -setacvalueindex $activeScheme $subProcessor 94d3a615-a18d-4690-bb97-7b3d1622c7d1 1 2>$null | Out-Null
      
      # 4. Set Energy Performance Preference (EPP) to Max Performance (value 0)
      powercfg -setacvalueindex $activeScheme $subProcessor 3668a66c-e52f-432a-9094-ad4b102c1b2d 0 2>$null | Out-Null
      
      # 5. Set max boost speed to unlimited (value 0) to prevent CPU speed drops and allow maximum performance
      # Value is in MHz, 0 = Unlimited
      powercfg -setacvalueindex $activeScheme $subProcessor 75b0eb26-8020-46d8-1748-e81575d4f02b 0 2>$null | Out-Null
      
      # Re-apply active scheme to enforce
      powercfg -setactive $activeScheme 2>$null | Out-Null
    }
    
    # 6. Apply processor architecture specific registers (Intel vs AMD Ryzen)
    try {
      $cpu = Get-CimInstance -ClassName Win32_Processor -EA SilentlyContinue
      $cpuName = $cpu.Name
      
      if ($cpuName -match "Intel") {
        Log-Write "   -> Intel CPU detected: Optimizing SpeedShift / SpeedStep..."
        # Force Intel SpeedShift Autonomous Mode
        $intelPM = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\8f0c770d-2e14-4fb6-ba6d-4952d76a0862"
        if (Test-Path $intelPM) {
          Set-ItemProperty -Path $intelPM -Name "Attributes" -Value 2 -Type DWord -Force -EA SilentlyContinue
        }
        Log-Write "   -> Intel Turbo Boost Max 3.0 priority scheduling active."
      }
      elseif ($cpuName -match "AMD|Ryzen") {
        Log-Write "   -> AMD Ryzen CPU detected: Optimizing CPPC preferred cores..."
        # Optimize Collaborative Power and Performance Control (CPPC)
        $amdPM = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\54533251-82be-4824-96c1-47b60b740d00"
        # Enable CPPC preferred core prioritization in registry
        $cppcPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power"
        Set-ItemProperty -Path $cppcPath -Name "CsEnabled" -Value 0 -Type DWord -Force -EA SilentlyContinue
        Log-Write "   -> AMD Ryzen CPPC preferred cores and latency profiles active."
      }
    }
    catch {}
    
    Log-Write "   -> CPU clock limits unlocked up to 5.5 GHz safely with active cooling policy."
  }

  if ($Mode -eq "Mode15") {
    Log-Write "[ RESET ] Restarting network adapters to apply low-latency TCP configurations..."
    Get-NetAdapter -EA SilentlyContinue | ForEach-Object {
      Restart-NetAdapter -Name $_.Name -Confirm:$false -EA SilentlyContinue
    }
    Log-Write "   -> Network adapters successfully restarted. Low-latency TCP active!"
  }

  Log-Write "=========================================="
  Log-Write " ALL 17 MODULES APPLIED SUCCESSFULLY!"
  Log-Write " REBOOT recommended for full effect."
  Log-Write "=========================================="

  Clear-History -EA SilentlyContinue
  if (Get-Command Get-PSReadLineOption -EA SilentlyContinue) {
    $histPath = (Get-PSReadLineOption).HistorySavePath
    if (Test-Path $histPath) { Remove-Item $histPath -Force -EA SilentlyContinue }
  }
}

# Custom styled WPF warning modal to request restoring before changing modes
function Show-RestoreWarningPrompt {
  param(
    [string]$activeModeName
  )
  $warningXml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Restore Required" Width="380" Height="190" WindowStartupLocation="CenterOwner"
        AllowsTransparency="True" WindowStyle="None" Background="Transparent" ResizeMode="NoResize">
  <Border BorderBrush="#FF7B3D" BorderThickness="1.5" CornerRadius="12" Background="#0C0E12">
    <Grid Margin="20">
      <Grid.RowDefinitions>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="*"/>
        <RowDefinition Height="Auto"/>
      </Grid.RowDefinitions>
      
      <StackPanel Grid.Row="0" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,0,0,10">
        <Path Data="M 12,2 L 2,22 H 22 Z M 12,9 V 14 M 12,17 H 12.01" Stroke="#FF7B3D" StrokeThickness="2" Width="18" Height="18" Stretch="Uniform" Margin="0,0,8,0" VerticalAlignment="Center"/>
        <TextBlock Text="RESTORE DEFAULTS REQUIRED" FontSize="12" FontWeight="Bold" Foreground="#FF7B3D" VerticalAlignment="Center"/>
      </StackPanel>
      
      <TextBlock Grid.Row="1" Text="Please restore the active mode ($activeModeName) to Windows defaults before optimizing a different mode." 
                 FontSize="11" Foreground="#CCCCCC" TextWrapping="Wrap" TextAlignment="Center" LineHeight="16" VerticalAlignment="Center"/>
      
      <Button Name="BtnWarningClose" Grid.Row="2" Content="UNDERSTOOD" Height="30" Width="120" HorizontalAlignment="Center" Background="#FF7B3D" Foreground="#FFFFFF" FontWeight="Bold">
        <Button.Template>
          <ControlTemplate TargetType="Button">
            <Border x:Name="Bg" Background="{TemplateBinding Background}" CornerRadius="6">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="Bg" Property="Background" Value="#D65A20"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Button.Template>
      </Button>
    </Grid>
  </Border>
</Window>
"@

  $stringReader = New-Object System.IO.StringReader($warningXml)
  $xmlReader = [System.Xml.XmlReader]::Create($stringReader)
  $warningWin = [System.Windows.Markup.XamlReader]::Load($xmlReader)
  $warningWin.Owner = $window
  
  $btnClose = $warningWin.FindName("BtnWarningClose")
  $btnClose.Add_Click({
      $warningWin.Close()
    }.GetNewClosure())
  
  $warningWin.ShowDialog() | Out-Null
}

# Custom styled WPF input modal to request developer key
function Show-DevKeyPrompt {
  $promptXml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Developer Verification" Width="300" Height="150" WindowStartupLocation="CenterOwner"
        AllowsTransparency="True" WindowStyle="None" Background="Transparent" ResizeMode="NoResize">
  <Border BorderBrush="#00A3FF" BorderThickness="1.5" CornerRadius="12" Background="#0C0E12">
    <Grid Margin="15">
      <Grid.RowDefinitions>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="*"/>
        <RowDefinition Height="Auto"/>
      </Grid.RowDefinitions>
      
      <TextBlock Grid.Row="0" Text="ENTER DEVELOPER KEY" FontSize="11" FontWeight="Bold" Foreground="#00A3FF" HorizontalAlignment="Center"/>
      
      <PasswordBox x:Name="PromptPass" Grid.Row="1" Height="28" Background="#151A22" BorderBrush="#303A4A" Foreground="#FFFFFF" Padding="5,2" VerticalAlignment="Center" VerticalContentAlignment="Center"/>
      
      <Grid Grid.Row="2">
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Button x:Name="BtnPromptOk" Grid.Column="0" Content="CONFIRM" Height="28" Margin="0,0,5,0" Background="#00A3FF" Foreground="#FFFFFF" FontWeight="Bold">
          <Button.Template>
            <ControlTemplate TargetType="Button">
              <Border x:Name="Bg" Background="{TemplateBinding Background}" CornerRadius="6">
                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
              </Border>
              <ControlTemplate.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                  <Setter TargetName="Bg" Property="Background" Value="#0084D1"/>
                </Trigger>
              </ControlTemplate.Triggers>
            </ControlTemplate>
          </Button.Template>
        </Button>
        <Button x:Name="BtnPromptCancel" Grid.Column="1" Content="CANCEL" Height="28" Margin="5,0,0,0" Background="#1A222D" Foreground="#80FFFFFF">
          <Button.Template>
            <ControlTemplate TargetType="Button">
              <Border x:Name="Bg" Background="{TemplateBinding Background}" CornerRadius="6">
                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
              </Border>
              <ControlTemplate.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                  <Setter TargetName="Bg" Property="Background" Value="#25303F"/>
                </Trigger>
              </ControlTemplate.Triggers>
            </ControlTemplate>
          </Button.Template>
        </Button>
      </Grid>
    </Grid>
  </Border>
</Window>
"@

  $stringReader = New-Object System.IO.StringReader($promptXml)
  $xmlReader = [System.Xml.XmlReader]::Create($stringReader)
  $promptWin = [System.Windows.Markup.XamlReader]::Load($xmlReader)
  $promptWin.Owner = $window
  
  $pb = $promptWin.FindName("PromptPass")
  $btnOk = $promptWin.FindName("BtnPromptOk")
  $btnCancel = $promptWin.FindName("BtnPromptCancel")
  
  $state = @{ result = "CANCEL" }
  
  $btnOk.Add_Click({
      if ($pb.Password -eq "dev") {
        $state.result = "SUCCESS"
      }
      else {
        $state.result = "WRONG"
      }
      $promptWin.Close()
    }.GetNewClosure())
  
  $btnCancel.Add_Click({
      $state.result = "CANCEL"
      $promptWin.Close()
    }.GetNewClosure())
  
  $pb.Add_KeyDown({
      param($sender, $e)
      if ($e.Key -eq [System.Windows.Input.Key]::Enter) {
        if ($pb.Password -eq "dev") {
          $state.result = "SUCCESS"
        }
        else {
          $state.result = "WRONG"
        }
        $promptWin.Close()
      }
    }.GetNewClosure())
  
  $promptWin.ShowDialog() | Out-Null
  return $state.result
}

$btnLaunch.Add_Click({
    Apply-ButtonPulseAnimation $btnLaunch
    
    # Check if another mode is optimized and requires restore
    $statusFile = Join-Path $script:BackupFolder "optimized.flag"
    $isSystemOptimized = Test-Path $statusFile
    if ($isSystemOptimized) {
      $flagContent = Get-Content -Path $statusFile -Raw -EA SilentlyContinue
      $activeMode = $null
      if ($flagContent -match "(Mode\d+)") {
        $activeMode = $Matches[1]
      }
      
      # If another registry mode is optimized, intercept and show warning popup
      if ($activeMode -and $activeMode -ne "Mode13" -and $activeMode -ne "Mode14" -and $script:selectedMode -ne $activeMode -and $script:selectedMode -ne "Mode13" -and $script:selectedMode -ne "Mode14") {
        $activeModeName = "Active Settings"
        if ($modeConfig[$activeMode]) {
          $activeModeName = $modeConfig[$activeMode].Description.Split(":")[0].Replace(" Mode", "").ToUpper()
        }
        Show-RestoreWarningPrompt -activeModeName $activeModeName
        return
      }
    }

    $btnLaunch.IsEnabled = $false

    while ($true) {
      $devAuth = Show-DevKeyPrompt
      if ($devAuth -eq "SUCCESS") {
        Invoke-OptimizationLaunch -mode $script:selectedMode
        break
      }
      elseif ($devAuth -eq "CANCEL") {
        $btnLaunch.IsEnabled = $true
        break
      }
      # If WRONG, the loop continues and displays the popup verification again
    }
  })

# --- Check optimization status and display in LogBox ---
$statusFile = Join-Path $script:BackupFolder "optimized.flag"
$isOptimized = Test-Path $statusFile
$latestBackup = Get-LatestBackupFile

$startupMsg = "FiveM Performance Engine v6.0 ready...`r`n`r`n"
if ($isOptimized) {
  $flagContent = Get-Content -Path $statusFile -Raw -EA SilentlyContinue
  $optMode = "YES"
  if ($flagContent -match "Mode(\d+)") {
    $modeNum = $Matches[1]
    $modeName = switch ($modeNum) {
      "1" { "Eco" }
      "2" { "Balanced" }
      "3" { "Performance" }
      "4" { "High Performance" }
      "5" { "Ultimate" }
      "6" { "Extreme" }
      "7" { "God Mode" }
      "8" { "Overdrive" }
      "9" { "Maximum" }
      "10" { "Insane" }
      "11" { "Safe Play" }
      "12" { "Minishawty Project VIP" }
      "13" { "FPS Boost" }
      "14" { "Frame Gen Boost" }
      "15" { "TCP & DeSync Booster" }
      "16" { "Hit Registration & Combat Pro" }
      "17" { "Hybrid Pro Combat" }
      "18" { "Insane Pro Combat" }
      "19" { "Hit To GPEDIT" }
      default { "Unknown" }
    }
    $optMode = "YES ($modeName - Mode $modeNum)"
  }
  else {
    $optMode = "YES"
  }
  
  $startupMsg += "[ STATUS ] SYSTEM OPTIMIZED: $optMode`r`n"
  if ($latestBackup) {
    $backupName = Split-Path $latestBackup -Leaf
    $startupMsg += "   -> Backup found: $backupName`r`n"
    $startupMsg += "   -> Click RESTORE DEFAULTS to undo changes.`r`n"
    $btnRestore.IsEnabled = $true
  }
  else {
    $startupMsg += "   -> WARNING: Backup file not found. Restore may not be possible.`r`n"
    $btnRestore.IsEnabled = $false
  }
}
else {
  $startupMsg += "[ STATUS ] SYSTEM OPTIMIZED: NO`r`n"
  if ($latestBackup) {
    $backupName = Split-Path $latestBackup -Leaf
    $startupMsg += "   -> Backup found: $backupName (Inactive)`r`n"
    $startupMsg += "   -> You can still click RESTORE DEFAULTS to restore settings.`r`n"
    $btnRestore.IsEnabled = $true
  }
  else {
    $startupMsg += "   -> No backup found. Click LAUNCH OPTIMIZATION to begin.`r`n"
    $btnRestore.IsEnabled = $false
  }
}
$logBox.Text = $startupMsg

# --- RESTORE Button Handler ---
$btnRestore.Add_Click({
    Apply-ButtonPulseAnimation $btnRestore
  
    $latestBackup = Get-LatestBackupFile
    if (!$latestBackup) {
      [System.Windows.MessageBox]::Show(
        "No backup file found.`nPlease run LAUNCH OPTIMIZATION first to create a backup.",
        "RESTORE - No Backup",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Warning
      )
      return
    }
  
    $result = [System.Windows.MessageBox]::Show(
      "Are you sure you want to restore all settings to their original values?`n`nThis will undo ALL optimizations applied by this tool.`nA system reboot will be required after restore.",
      "RESTORE DEFAULTS - Confirm",
      [System.Windows.MessageBoxButton]::YesNo,
      [System.Windows.MessageBoxImage]::Question
    )
  
    if ($result -eq [System.Windows.MessageBoxResult]::Yes) {
      $btnRestore.IsEnabled = $false
      $btnLaunch.IsEnabled = $false
    
      if ($progBar) {
        $progBar.Visibility = [System.Windows.Visibility]::Visible
        $opacityAnim = New-Object System.Windows.Media.Animation.DoubleAnimation
        $opacityAnim.From = 0
        $opacityAnim.To = 1
        $opacityAnim.Duration = New-Object System.Windows.Duration([TimeSpan]::FromMilliseconds(300))
        $progBar.BeginAnimation([System.Windows.UIElement]::OpacityProperty, $opacityAnim)
      
        $frame = New-Object System.Windows.Threading.DispatcherFrame
        [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke(
          [System.Windows.Threading.DispatcherPriority]::Background,
          [Action] { $frame.Continue = $false })
        [System.Windows.Threading.Dispatcher]::PushFrame($frame)
      }
    
      Log-Write "=========================================="
      Log-Write " STARTING RESTORE PROCESS..."
      Log-Write "=========================================="
    
      Restore-OriginalSettings -BackupFile $latestBackup
    
      # Remove optimization flag file
      $statusFile = Join-Path $script:BackupFolder "optimized.flag"
      if (Test-Path $statusFile) { Remove-Item -Path $statusFile -Force -EA SilentlyContinue }
      Log-Write "[ STATUS ] System restored to defaults. Flag removed."
    
      if ($progBar) { $progBar.Visibility = [System.Windows.Visibility]::Collapsed }
    
      $tb = $btnRestore.Template.FindName("BtnRestoreText", $btnRestore)
      if ($tb) { $tb.Text = "RESTORED SUCCESSFULLY" }
    
      $btnLaunch.IsEnabled = $true
      $tbLaunch = $btnLaunch.Template.FindName("BtnText", $btnLaunch)
      if ($tbLaunch) { $tbLaunch.Text = "LAUNCH OPTIMIZATION" }
      Update-CurrentModeIndicator
      Update-LaunchButtonState $script:selectedMode
    }
  })

# Configure cards dynamically with card-game selection transforms, origin and drop shadows
$allCards = @("AnalysisCard")
for ($i = 1; $i -le 19; $i++) { $allCards += "Mode${i}Card" }

foreach ($cardName in $allCards) {
  $c = $window.FindName($cardName)
  if ($c) {
    $c.RenderTransformOrigin = New-Object System.Windows.Point(0.5, 0.5)
    
    # Create TransformGroup with ScaleTransform and TranslateTransform
    $tg = New-Object System.Windows.Media.TransformGroup
    $st = New-Object System.Windows.Media.ScaleTransform
    $st.ScaleX = 1.0
    $st.ScaleY = 1.0
    $tt = New-Object System.Windows.Media.TranslateTransform
    $tt.X = 0.0
    $tt.Y = 0.0
    
    $tg.Children.Add($st) | Out-Null
    $tg.Children.Add($tt) | Out-Null
    $c.RenderTransform = $tg
    
    # Configure DropShadow color dynamically
    $colorHex = "#00A3FF"
    if ($cardName -eq "AnalysisCard") {
      $colorHex = "#00FFA3"
    }
    else {
      $modeKey = $cardName.Replace("Card", "")
      if ($modeConfig[$modeKey]) { $colorHex = $modeConfig[$modeKey].Color }
    }
    
    $ds = New-Object System.Windows.Media.Effects.DropShadowEffect
    $ds.BlurRadius = 12
    $ds.Color = [System.Windows.Media.ColorConverter]::ConvertFromString($colorHex)
    $ds.ShadowDepth = 0
    $ds.Opacity = 0.3
    $c.Effect = $ds
  }
}

$window.ShowDialog() | Out-Null





























