# ====================================================================
#   ALLSETTING X INTERNET - FIVEM PERFORMANCE ENGINE v3.0
#   COMBAT EDITION - Ultra Low Latency + Hit Registration + Dodge Boost
#   Power By ProjectE PERFORMANCE ENGINE (Enzo UI Premium Edition)
# ====================================================================

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
  exit
}

# ================= KEY CHECK =================
# Password will be checked in UI



# ================= SCRIPT =================

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
  }
  catch { }
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
  
  if ($Mode -eq "GodMode") {
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
    Version   = "3.0"
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
  $backup["DX_MaxFrameLatency"] = Get-RegistryValue "HKLM:\SOFTWARE\Microsoft\DirectX" "MaxFrameLatency"
    
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
    
  # --- Mouse ---
  $mouseKeys = @("MouseSpeed", "MouseThreshold1", "MouseThreshold2", "MouseSensitivity", "SmoothMouseXCurve", "SmoothMouseYCurve", "MouseTrails")
  $mouseBackup = @{}
  foreach ($k in $mouseKeys) { $mouseBackup[$k] = Get-RegistryValue "HKCU:\Control Panel\Mouse" $k }
  $backup["Mouse"] = $mouseBackup
  $backup["MouseDataQueueSize"] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "MouseDataQueueSize"
  $backup["MouseDataThrottleSize"] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "MouseDataThrottleSize"
    
  # --- Keyboard ---
  $kbKeys = @("KeyboardDelay", "KeyboardSpeed")
  $kbBackup = @{}
  foreach ($k in $kbKeys) { $kbBackup[$k] = Get-RegistryValue "HKCU:\Control Panel\Keyboard" $k }
  $backup["Keyboard"] = $kbBackup
  $backup["KbDataQueueSize"] = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" "KeyboardDataQueueSize"
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
  Log-Write "   -> Network/TCP/DNS/AFD restored."
    
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
  Set-RegistryFromBackup "HKLM:\SOFTWARE\Microsoft\DirectX" "MaxFrameLatency" $backup.DX_MaxFrameLatency
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
  Log-Write "   -> Mouse settings restored."
    
  # --- Keyboard ---
  Log-Write "[ RESTORE 9 ] Restoring Keyboard settings..."
  if ($backup.Keyboard) {
    $backup.Keyboard.PSObject.Properties | ForEach-Object {
      Set-RegistryFromBackup "HKCU:\Control Panel\Keyboard" $_.Name $_.Value
    }
  }
  Set-RegistryFromBackup "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" "KeyboardDataQueueSize" $backup.KbDataQueueSize
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



[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="AllSetting x FiveM" Height="700" Width="440"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize"
        WindowStyle="None" AllowsTransparency="True" Background="Transparent">

  <Window.Resources>
    <DropShadowEffect x:Key="NeonGlow" BlurRadius="20" Color="#00A3FF" ShadowDepth="0" Opacity="0.7"/>
    <DropShadowEffect x:Key="PanelGlow" BlurRadius="30" Color="#000000" ShadowDepth="0" Opacity="0.9"/>
    <DropShadowEffect x:Key="GoldGlow" BlurRadius="20" Color="#FFD700" ShadowDepth="0" Opacity="0.7"/>
    <DropShadowEffect x:Key="PurpleGlow" BlurRadius="20" Color="#9B59B6" ShadowDepth="0" Opacity="0.7"/>
    <DropShadowEffect x:Key="GreenGlow" BlurRadius="20" Color="#2ECC71" ShadowDepth="0" Opacity="0.7"/>
    <DropShadowEffect x:Key="RedGlow" BlurRadius="20" Color="#E74C3C" ShadowDepth="0" Opacity="0.7"/>
    <DropShadowEffect x:Key="SoftGlow" BlurRadius="15" Color="#FFFFFF" ShadowDepth="0" Opacity="0.3"/>
  </Window.Resources>

  <Border CornerRadius="20" BorderBrush="#1A00A3FF" BorderThickness="1.5" Effect="{StaticResource PanelGlow}">
    <Border.Background>
      <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
        <GradientStop Color="#0F1115" Offset="0.0"/>
        <GradientStop Color="#1A1D24" Offset="0.5"/>
        <GradientStop Color="#0F1115" Offset="1.0"/>
      </LinearGradientBrush>
    </Border.Background>

    <Grid>
      <Grid.RowDefinitions>
        <RowDefinition Height="40"/>
        <RowDefinition Height="*"/>
      </Grid.RowDefinitions>

      <Grid Name="HeaderBar" Grid.Row="0" Background="#0AFFFFFF" Cursor="SizeAll">
        <TextBlock Text="ALLSETTING X FIVEM" FontSize="10" FontWeight="Bold"
                   Foreground="#00A3FF" HorizontalAlignment="Center" VerticalAlignment="Center">
          <TextBlock.Effect>
            <DropShadowEffect BlurRadius="8" Color="#00A3FF" ShadowDepth="0" Opacity="0.5"/>
          </TextBlock.Effect>
        </TextBlock>
        
        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,15,0">
          <Button Name="BtnMinimize" Content="−" Width="32" Height="28" FontSize="16" FontWeight="Bold"
                  Foreground="#80FFFFFF" Background="Transparent" BorderBrush="Transparent" Margin="0,0,6,0">
            <Button.Template>
              <ControlTemplate TargetType="Button">
                <Border x:Name="Bg" Background="Transparent" CornerRadius="6">
                  <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>
                <ControlTemplate.Triggers>
                  <Trigger Property="IsMouseOver" Value="True">
                    <Setter TargetName="Bg" Property="Background" Value="#1A00A3FF"/>
                    <Setter Property="Foreground" Value="#00A3FF"/>
                  </Trigger>
                </ControlTemplate.Triggers>
              </ControlTemplate>
            </Button.Template>
          </Button>
          
          <Button Name="BtnClose" Content="✕" Width="32" Height="28" FontSize="12" FontWeight="Bold"
                  Foreground="#80FFFFFF" Background="Transparent" BorderBrush="Transparent">
            <Button.Template>
              <ControlTemplate TargetType="Button">
                <Border x:Name="Bg" Background="Transparent" CornerRadius="6">
                  <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>
                <ControlTemplate.Triggers>
                  <Trigger Property="IsMouseOver" Value="True">
                    <Setter TargetName="Bg" Property="Background" Value="#E74C3C"/>
                    <Setter Property="Foreground" Value="#FFFFFF"/>
                  </Trigger>
                </ControlTemplate.Triggers>
              </ControlTemplate>
            </Button.Template>
          </Button>
        </StackPanel>
      </Grid>

      <Grid Grid.Row="1">
        
        <!-- LOGIN VIEW -->
        <Grid Name="ViewLogin" Visibility="Visible" Margin="30">
          <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
          </Grid.RowDefinitions>
          
          <StackPanel Grid.Row="0" VerticalAlignment="Center" HorizontalAlignment="Center">
            <TextBlock Text="ALLSETTING" FontSize="32" FontWeight="Black" HorizontalAlignment="Center">
              <TextBlock.Foreground>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                   <GradientStop Color="#00A3FF" Offset="0.0"/>
                   <GradientStop Color="#00E0FF" Offset="1.0"/>
                </LinearGradientBrush>
              </TextBlock.Foreground>
              <TextBlock.Effect>
                <DropShadowEffect BlurRadius="12" Color="#00A3FF" ShadowDepth="0" Opacity="0.6"/>
              </TextBlock.Effect>
            </TextBlock>
            <TextBlock Text="PERFORMANCE ENGINE v4.0" FontSize="12" FontWeight="Bold" Foreground="#60FFFFFF" HorizontalAlignment="Center" Margin="0,8,0,0"/>
            <Border Height="3" Width="80" CornerRadius="2" Background="#00A3FF" Margin="0,20,0,0" HorizontalAlignment="Center">
              <Border.Effect>
                <DropShadowEffect BlurRadius="8" Color="#00A3FF" ShadowDepth="0" Opacity="0.8"/>
              </Border.Effect>
            </Border>
          </StackPanel>

          <TextBlock Grid.Row="1" Text="ENTER ACCESS KEY" FontSize="11" FontWeight="SemiBold" Foreground="#80D2FF" HorizontalAlignment="Center" Margin="0,25,0,12"/>

          <Grid Grid.Row="2" Width="300" Height="50" Margin="0,0,0,18">
            <Border CornerRadius="25" BorderThickness="2" BorderBrush="#2A00A3FF" Background="#0F1115">
              <Border.Effect>
                <DropShadowEffect BlurRadius="10" Color="#00A3FF" ShadowDepth="0" Opacity="0.3"/>
              </Border.Effect>
              <PasswordBox Name="PasswordBox" FontSize="15" FontWeight="SemiBold" Foreground="#FFFFFF" 
                          Background="Transparent" BorderThickness="0" Padding="18,0,18,0" 
                          VerticalAlignment="Center" HorizontalAlignment="Stretch"
                          PasswordChar="*"/>
            </Border>
          </Grid>

          <Grid Grid.Row="3" Height="52" Margin="0,0,0,0">
            <Button Name="BtnLogin" Height="52" Width="300" Cursor="Hand" Background="Transparent" BorderThickness="0">
              <Button.Effect>
                <DropShadowEffect BlurRadius="15" Color="#00A3FF" ShadowDepth="0" Opacity="0.6"/>
              </Button.Effect>
              <Button.Template>
                <ControlTemplate TargetType="Button">
                  <Border x:Name="Bd" CornerRadius="26" BorderThickness="2" BorderBrush="#00A3FF">
                    <Border.Background>
                      <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                        <GradientStop Color="#00A3FF" Offset="0.0"/>
                        <GradientStop Color="#00E0FF" Offset="1.0"/>
                      </LinearGradientBrush>
                    </Border.Background>
                    <TextBlock Text="LOGIN" FontSize="14" FontWeight="Black" Foreground="#FFFFFF" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                  </Border>
                  <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                      <Setter TargetName="Bd" Property="BorderBrush" Value="#00E0FF"/>
                      <Setter TargetName="Bd" Property="Effect">
                        <Setter.Value>
                          <DropShadowEffect BlurRadius="20" Color="#00E0FF" ShadowDepth="0" Opacity="0.8"/>
                        </Setter.Value>
                      </Setter>
                    </Trigger>
                  </ControlTemplate.Triggers>
                </ControlTemplate>
              </Button.Template>
            </Button>
          </Grid>
        </Grid>

        <!-- START VIEW -->
        <Grid Name="ViewStart" Visibility="Collapsed" Margin="20">
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
            <TextBlock Text="PERFORMANCE ENGINE v4.0" FontSize="10" FontWeight="Bold" Foreground="#44FFFFFF" HorizontalAlignment="Center" Margin="0,4,0,0"/>
            <Border Height="2" Width="60" Background="#00A3FF" Margin="0,15,0,0" HorizontalAlignment="Center"/>
          </StackPanel>

          <Grid Grid.Row="1" Height="50" Margin="0,0,0,40">
            <Button Name="BtnStart" Height="50" Width="260" Cursor="Hand" Background="Transparent" BorderThickness="0">
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
            
            <StackPanel Name="StartProgContainer" Visibility="Collapsed" Width="260" VerticalAlignment="Center">
              <TextBlock Name="StartProgText" Text="Loading system modules..." FontSize="10" FontWeight="SemiBold" Foreground="#80D2FF" HorizontalAlignment="Center" Margin="0,0,0,8"/>
              <ProgressBar Name="StartProgBar" Height="6" Minimum="0" Maximum="100" Value="0" Background="#141923" BorderThickness="0">
                <ProgressBar.Foreground>
                  <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                    <GradientStop Color="#00A3FF" Offset="0.0"/>
                    <GradientStop Color="#00E0FF" Offset="1.0"/>
                  </LinearGradientBrush>
                </ProgressBar.Foreground>
              </ProgressBar>
            </StackPanel>
          </Grid>
        </Grid>

        <Grid Name="ViewMain" Visibility="Collapsed" Margin="18,12,18,18">
          <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="140"/>
          </Grid.RowDefinitions>

          <StackPanel Grid.Row="0" Margin="0,5,0,10">
            <TextBlock Text="GPEDIT ENZO V4" FontSize="16" FontWeight="Black" Foreground="#00A3FF" HorizontalAlignment="Center">
              <TextBlock.Effect>
                <DropShadowEffect BlurRadius="8" Color="#00A3FF" ShadowDepth="0" Opacity="0.5"/>
              </TextBlock.Effect>
            </TextBlock>
            <TextBlock Text="SELECT OPTIMIZATION MODE" FontSize="9" FontWeight="SemiBold" Foreground="#60FFFFFF" HorizontalAlignment="Center" Margin="0,4,0,0"/>
          </StackPanel>

          <!-- Mode Selector Grid -->
          <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled" Margin="0,0,0,12" MaxHeight="145">
            <WrapPanel Name="ModeGrid" HorizontalAlignment="Center">
              <!-- Mode 1 -->
              <Border Name="Mode1Card" Margin="4" Padding="10,8" CornerRadius="12" BorderThickness="2" BorderBrush="#2ECC71" Background="#0A2ECC71" Cursor="Hand">
                <Border.Effect>
                  <DropShadowEffect BlurRadius="8" Color="#2ECC71" ShadowDepth="0" Opacity="0.3"/>
                </Border.Effect>
                <StackPanel>
                  <TextBlock Text="ECO" FontSize="11" FontWeight="Black" Foreground="#2ECC71" HorizontalAlignment="Center"/>
                  <TextBlock Text="Low Power" FontSize="8" Foreground="#90FFFFFF" HorizontalAlignment="Center" Margin="0,2,0,0"/>
                </StackPanel>
              </Border>
              <!-- Mode 2 -->
              <Border Name="Mode2Card" Margin="4" Padding="10,8" CornerRadius="12" BorderThickness="2" BorderBrush="#3498DB" Background="#0A3498DB" Cursor="Hand">
                <Border.Effect>
                  <DropShadowEffect BlurRadius="8" Color="#3498DB" ShadowDepth="0" Opacity="0.3"/>
                </Border.Effect>
                <StackPanel>
                  <TextBlock Text="BALANCED" FontSize="11" FontWeight="Black" Foreground="#3498DB" HorizontalAlignment="Center"/>
                  <TextBlock Text="Daily Use" FontSize="8" Foreground="#90FFFFFF" HorizontalAlignment="Center" Margin="0,2,0,0"/>
                </StackPanel>
              </Border>
              <!-- Mode 3 -->
              <Border Name="Mode3Card" Margin="4" Padding="10,8" CornerRadius="12" BorderThickness="2" BorderBrush="#9B59B6" Background="#0A9B59B6" Cursor="Hand">
                <Border.Effect>
                  <DropShadowEffect BlurRadius="8" Color="#9B59B6" ShadowDepth="0" Opacity="0.3"/>
                </Border.Effect>
                <StackPanel>
                  <TextBlock Text="PERFORMANCE" FontSize="11" FontWeight="Black" Foreground="#9B59B6" HorizontalAlignment="Center"/>
                  <TextBlock Text="Gaming" FontSize="8" Foreground="#90FFFFFF" HorizontalAlignment="Center" Margin="0,2,0,0"/>
                </StackPanel>
              </Border>
              <!-- Mode 4 -->
              <Border Name="Mode4Card" Margin="4" Padding="10,8" CornerRadius="12" BorderThickness="2" BorderBrush="#E67E22" Background="#0AE67E22" Cursor="Hand">
                <Border.Effect>
                  <DropShadowEffect BlurRadius="8" Color="#E67E22" ShadowDepth="0" Opacity="0.3"/>
                </Border.Effect>
                <StackPanel>
                  <TextBlock Text="HIGH PERF" FontSize="11" FontWeight="Black" Foreground="#E67E22" HorizontalAlignment="Center"/>
                  <TextBlock Text="Competitive" FontSize="8" Foreground="#90FFFFFF" HorizontalAlignment="Center" Margin="0,2,0,0"/>
                </StackPanel>
              </Border>
              <!-- Mode 5 -->
              <Border Name="Mode5Card" Margin="4" Padding="10,8" CornerRadius="12" BorderThickness="2" BorderBrush="#00A3FF" Background="#1A00A3FF" Cursor="Hand">
                <Border.Effect>
                  <DropShadowEffect BlurRadius="12" Color="#00A3FF" ShadowDepth="0" Opacity="0.5"/>
                </Border.Effect>
                <StackPanel>
                  <TextBlock Text="ULTIMATE" FontSize="11" FontWeight="Black" Foreground="#00A3FF" HorizontalAlignment="Center"/>
                  <TextBlock Text="Recommended" FontSize="8" Foreground="#90FFFFFF" HorizontalAlignment="Center" Margin="0,2,0,0"/>
                </StackPanel>
              </Border>
              <!-- Mode 6 -->
              <Border Name="Mode6Card" Margin="4" Padding="10,8" CornerRadius="12" BorderThickness="2" BorderBrush="#FF6B35" Background="#0AFF6B35" Cursor="Hand">
                <Border.Effect>
                  <DropShadowEffect BlurRadius="8" Color="#FF6B35" ShadowDepth="0" Opacity="0.3"/>
                </Border.Effect>
                <StackPanel>
                  <TextBlock Text="EXTREME" FontSize="11" FontWeight="Black" Foreground="#FF6B35" HorizontalAlignment="Center"/>
                  <TextBlock Text="Max Perf" FontSize="8" Foreground="#90FFFFFF" HorizontalAlignment="Center" Margin="0,2,0,0"/>
                </StackPanel>
              </Border>
              <!-- Mode 7 -->
              <Border Name="Mode7Card" Margin="4" Padding="10,8" CornerRadius="12" BorderThickness="2" BorderBrush="#FFD700" Background="#0AFFD700" Cursor="Hand">
                <Border.Effect>
                  <DropShadowEffect BlurRadius="8" Color="#FFD700" ShadowDepth="0" Opacity="0.3"/>
                </Border.Effect>
                <StackPanel>
                  <TextBlock Text="GOD MODE" FontSize="11" FontWeight="Black" Foreground="#FFD700" HorizontalAlignment="Center"/>
                  <TextBlock Text="Enthusiast" FontSize="8" Foreground="#90FFFFFF" HorizontalAlignment="Center" Margin="0,2,0,0"/>
                </StackPanel>
              </Border>
              <!-- Mode 8 -->
              <Border Name="Mode8Card" Margin="4" Padding="10,8" CornerRadius="12" BorderThickness="2" BorderBrush="#E74C3C" Background="#0AE74C3C" Cursor="Hand">
                <Border.Effect>
                  <DropShadowEffect BlurRadius="8" Color="#E74C3C" ShadowDepth="0" Opacity="0.3"/>
                </Border.Effect>
                <StackPanel>
                  <TextBlock Text="OVERDRIVE" FontSize="11" FontWeight="Black" Foreground="#E74C3C" HorizontalAlignment="Center"/>
                  <TextBlock Text="Push Limits" FontSize="8" Foreground="#90FFFFFF" HorizontalAlignment="Center" Margin="0,2,0,0"/>
                </StackPanel>
              </Border>
              <!-- Mode 9 -->
              <Border Name="Mode9Card" Margin="4" Padding="10,8" CornerRadius="12" BorderThickness="2" BorderBrush="#C0392B" Background="#0AC0392B" Cursor="Hand">
                <Border.Effect>
                  <DropShadowEffect BlurRadius="8" Color="#C0392B" ShadowDepth="0" Opacity="0.3"/>
                </Border.Effect>
                <StackPanel>
                  <TextBlock Text="MAXIMUM" FontSize="11" FontWeight="Black" Foreground="#C0392B" HorizontalAlignment="Center"/>
                  <TextBlock Text="Absolute" FontSize="8" Foreground="#90FFFFFF" HorizontalAlignment="Center" Margin="0,2,0,0"/>
                </StackPanel>
              </Border>
              <!-- Mode 10 -->
              <Border Name="Mode10Card" Margin="4" Padding="10,8" CornerRadius="12" BorderThickness="2" BorderBrush="#8E44AD" Background="#0A8E44AD" Cursor="Hand">
                <Border.Effect>
                  <DropShadowEffect BlurRadius="8" Color="#8E44AD" ShadowDepth="0" Opacity="0.3"/>
                </Border.Effect>
                <StackPanel>
                  <TextBlock Text="INSANE" FontSize="11" FontWeight="Black" Foreground="#8E44AD" HorizontalAlignment="Center"/>
                  <TextBlock Text="Experimental" FontSize="8" Foreground="#90FFFFFF" HorizontalAlignment="Center" Margin="0,2,0,0"/>
                </StackPanel>
              </Border>
            </WrapPanel>
          </ScrollViewer>

          <!-- Mode Description -->
          <TextBlock Name="ModeDescription" Grid.Row="2" Text="Ultimate: Recommended for most users - Balanced performance and stability" 
                    FontSize="9" Foreground="#70FFFFFF" HorizontalAlignment="Center" TextWrapping="Wrap" 
                    Margin="10,6,10,6" TextAlignment="Center"/>

          <!-- Feature Tags -->
          <ScrollViewer Grid.Row="3" VerticalScrollBarVisibility="Hidden" HorizontalScrollBarVisibility="Disabled" Margin="5,0,5,10" MaxHeight="55">
            <WrapPanel Name="FeatureTags" HorizontalAlignment="Center">
              <Border Margin="2" Padding="8,4" CornerRadius="6" Background="#0F1115" BorderBrush="#2A00A3FF" BorderThickness="1">
                <TextBlock Text="Network Stack" FontSize="8" FontWeight="SemiBold" Foreground="#80D2FF"/>
              </Border>
              <Border Margin="2" Padding="8,4" CornerRadius="6" Background="#0F1115" BorderBrush="#2A00A3FF" BorderThickness="1">
                <TextBlock Text="CPU Unpark" FontSize="8" FontWeight="SemiBold" Foreground="#80D2FF"/>
              </Border>
              <Border Margin="2" Padding="8,4" CornerRadius="6" Background="#0F1115" BorderBrush="#2A00A3FF" BorderThickness="1">
                <TextBlock Text="MMCSS Game" FontSize="8" FontWeight="SemiBold" Foreground="#80D2FF"/>
              </Border>
              <Border Margin="2" Padding="8,4" CornerRadius="6" Background="#0F1115" BorderBrush="#2A00A3FF" BorderThickness="1">
                <TextBlock Text="GPU Scheduler" FontSize="8" FontWeight="SemiBold" Foreground="#80D2FF"/>
              </Border>
              <Border Margin="2" Padding="8,4" CornerRadius="6" Background="#0F1115" BorderBrush="#2A00A3FF" BorderThickness="1">
                <TextBlock Text="Combat Input" FontSize="8" FontWeight="SemiBold" Foreground="#80D2FF"/>
              </Border>
              <Border Margin="2" Padding="8,4" CornerRadius="6" Background="#0F1115" BorderBrush="#2A00A3FF" BorderThickness="1">
                <TextBlock Text="Hit Register" FontSize="8" FontWeight="SemiBold" Foreground="#80D2FF"/>
              </Border>
              <Border Margin="2" Padding="8,4" CornerRadius="6" Background="#0F1115" BorderBrush="#2A00A3FF" BorderThickness="1">
                <TextBlock Text="Timer 0.5ms" FontSize="8" FontWeight="SemiBold" Foreground="#80D2FF"/>
              </Border>
            </WrapPanel>
          </ScrollViewer>

          <Grid Grid.Row="4" Margin="0,10,0,14">
            <Button Name="BtnLaunch" Height="48" Width="340" Cursor="Hand" Background="Transparent" BorderThickness="0">
              <Button.Effect>
                <DropShadowEffect x:Name="BtnGlow" BlurRadius="18" Color="#00A3FF" ShadowDepth="0" Opacity="0.7"/>
              </Button.Effect>
              <Button.Template>
                <ControlTemplate TargetType="Button">
                  <Border x:Name="Bd" CornerRadius="24" BorderThickness="2" BorderBrush="#00A3FF">
                    <Border.Background>
                      <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                        <GradientStop Color="#00A3FF" Offset="0.0"/>
                        <GradientStop Color="#00E0FF" Offset="1.0"/>
                      </LinearGradientBrush>
                    </Border.Background>
                    <TextBlock Name="BtnText" Text="LAUNCH OPTIMIZATION" FontSize="12" FontWeight="Black" Foreground="#FFFFFF" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                  </Border>
                  <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                      <Setter TargetName="Bd" Property="Effect">
                        <Setter.Value>
                          <DropShadowEffect BlurRadius="25" Color="#00E0FF" ShadowDepth="0" Opacity="0.9"/>
                        </Setter.Value>
                      </Setter>
                    </Trigger>
                    <Trigger Property="IsEnabled" Value="False">
                      <Setter TargetName="Bd" Property="Opacity" Value="0.4"/>
                    </Trigger>
                  </ControlTemplate.Triggers>
                </ControlTemplate>
              </Button.Template>
            </Button>
          </Grid>

          <Grid Grid.Row="5" Margin="0,0,0,10">
            <Button Name="BtnRestore" Height="42" Width="340" Cursor="Hand" Background="Transparent" BorderThickness="0">
              <Button.Effect>
                <DropShadowEffect BlurRadius="12" Color="#FF6B35" ShadowDepth="0" Opacity="0.5"/>
              </Button.Effect>
              <Button.Template>
                <ControlTemplate TargetType="Button">
                  <Border x:Name="Bd" CornerRadius="21" BorderThickness="1.5" BorderBrush="#FF6B35">
                    <Border.Background>
                      <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
                        <GradientStop Color="#1AFF6B35" Offset="0"/>
                        <GradientStop Color="#05000000" Offset="1"/>
                      </LinearGradientBrush>
                    </Border.Background>
                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center">
                      <TextBlock Text="↺" FontSize="16" FontWeight="Bold" Foreground="#FF6B35" Margin="0,0,8,0"/>
                      <TextBlock Name="BtnRestoreText" Text="RESTORE DEFAULTS" FontSize="11" FontWeight="Bold" Foreground="#CCFFFFFF" VerticalAlignment="Center"/>
                    </StackPanel>
                  </Border>
                  <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                      <Setter TargetName="Bd" Property="Background" Value="#33FF6B35"/>
                      <Setter TargetName="Bd" Property="BorderBrush" Value="#FF9B6B"/>
                    </Trigger>
                    <Trigger Property="IsEnabled" Value="False">
                      <Setter TargetName="Bd" Property="Opacity" Value="0.3"/>
                    </Trigger>
                  </ControlTemplate.Triggers>
                </ControlTemplate>
              </Button.Template>
            </Button>
          </Grid>
 
          <Grid Grid.Row="5">
            <Grid.RowDefinitions>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
            <TextBlock Grid.Row="0" Text="SYSTEM DIAGNOSTIC LOG" FontSize="9" FontWeight="Bold" Foreground="#50FFFFFF" Margin="5,0,0,6"/>
            <ProgressBar Name="ProgBar" Grid.Row="1" Height="3" IsIndeterminate="True" Visibility="Collapsed" BorderThickness="0" Background="#0F1115" Margin="5,0,5,8">
              <ProgressBar.Foreground>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                  <GradientStop Color="#0055FF" Offset="0"/>
                  <GradientStop Color="#00A3FF" Offset="0.5"/>
                  <GradientStop Color="#00E0FF" Offset="1"/>
                </LinearGradientBrush>
              </ProgressBar.Foreground>
              <ProgressBar.Effect>
                <DropShadowEffect BlurRadius="6" Color="#00A3FF" ShadowDepth="0" Opacity="0.5"/>
              </ProgressBar.Effect>
            </ProgressBar>
            <Border Grid.Row="2" CornerRadius="10" BorderThickness="1.5" Background="#0F1115" BorderBrush="#2A00A3FF">
              <Border.Effect>
                <DropShadowEffect BlurRadius="8" Color="#00A3FF" ShadowDepth="0" Opacity="0.15"/>
              </Border.Effect>
              <TextBox Name="LogBox" Background="Transparent" Foreground="#90D2FF" BorderThickness="0"
                       FontFamily="Consolas" FontSize="9" IsReadOnly="True" TextWrapping="Wrap"
                       VerticalScrollBarVisibility="Auto" Margin="12,8,12,8"/>
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

$headerBar = $window.FindName("HeaderBar")
$btnMinimize = $window.FindName("BtnMinimize")
$btnClose = $window.FindName("BtnClose")
$btnStart = $window.FindName("BtnStart")
$btnLaunch = $window.FindName("BtnLaunch")
$btnRestore = $window.FindName("BtnRestore")
$viewLogin = $window.FindName("ViewLogin")
$viewStart = $window.FindName("ViewStart")
$viewMain = $window.FindName("ViewMain")
$logBox = $window.FindName("LogBox")
$progBar = $window.FindName("ProgBar")
$startProgContainer = $window.FindName("StartProgContainer")
$startProgText = $window.FindName("StartProgText")
$startProgBar = $window.FindName("StartProgBar")
$passwordBox = $window.FindName("PasswordBox")
$btnLogin = $window.FindName("BtnLogin")
$modeGrid = $window.FindName("ModeGrid")
$modeDescription = $window.FindName("ModeDescription")
$featureTags = $window.FindName("FeatureTags")
$script:selectedMode = "Mode5"

# Get all mode cards
$modeCards = @()
for ($i = 1; $i -le 10; $i++) {
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

# Mode descriptions and colors
$modeConfig = @{
  "Mode1" = @{ Description = "Eco: Low power mode for battery saving - Minimal performance impact"; Color = "#2ECC71"; Features = @("Basic Network", "Power Saving") }
  "Mode2" = @{ Description = "Balanced: Good performance with power efficiency - Daily use"; Color = "#3498DB"; Features = @("Network Stack", "Basic CPU", "MMCSS") }
  "Mode3" = @{ Description = "Performance: Enhanced performance for gaming - Recommended"; Color = "#9B59B6"; Features = @("Network", "CPU Unpark", "MMCSS", "GPU") }
  "Mode4" = @{ Description = "High Performance: Aggressive tuning for competitive gaming"; Color = "#E67E22"; Features = @("Network", "CPU", "MMCSS", "GPU", "Input") }
  "Mode5" = @{ Description = "Ultimate: Recommended for most users - Balanced performance and stability"; Color = "#00A3FF"; Features = @("Network Stack", "CPU Unpark", "MMCSS Game", "GPU Scheduler", "Combat Input", "Hit Register", "Timer 0.5ms") }
  "Mode6" = @{ Description = "Extreme: Maximum performance settings - May increase heat"; Color = "#FF6B35"; Features = @("Extreme Network", "CPU Max", "MMCSS Max", "GPU Max", "Input Max", "Timer 0.5ms", "DPC/ISR") }
  "Mode7" = @{ Description = "God Mode: Maximum aggressive tuning - For enthusiasts only"; Color = "#FFD700"; Features = @("God Network", "CPU God", "MMCSS God", "GPU God", "Input God", "Timer 0.5ms", "DPC/ISR", "Memory") }
  "Mode8" = @{ Description = "Overdrive: Push beyond limits - Risk of instability"; Color = "#E74C3C"; Features = @("Overclock Network", "CPU Overdrive", "MMCSS Over", "GPU Over", "Input Over", "Timer 0.3ms", "DPC/ISR Max") }
  "Mode9" = @{ Description = "Maximum: Absolute maximum performance - High instability risk"; Color = "#C0392B"; Features = @("Max Network", "CPU Max", "MMCSS Max", "GPU Max", "Input Max", "Timer 0.1ms", "DPC/ISR Max", "Memory Max") }
  "Mode10" = @{ Description = "Insane: Experimental extreme mode - Use at own risk!"; Color = "#8E44AD"; Features = @("Insane Network", "CPU Insane", "MMCSS Insane", "GPU Insane", "Input Insane", "Timer 0.05ms", "DPC/ISR Insane", "Memory Insane", "Bypass Limits") }
}

# Function to select a mode
function Select-Mode {
  param([string]$mode)
  
  $script:selectedMode = $mode
  $config = $modeConfig[$mode]
  
  if ($config) {
    $modeDescription.Text = $config.Description
    Update-LaunchButtonColors $mode
    Update-FeatureTags $config.Features
    
    # Update card appearances
    for ($i = 1; $i -le 10; $i++) {
      $card = $window.FindName("Mode${i}Card")
      $cardColor = $modeConfig["Mode$i"].Color
      
      if ("Mode$i" -eq $mode) {
        # Selected card - make it more prominent
        $card.BorderThickness = "3"
        $card.Background = "#1A$($cardColor.Trim('#'))"
      }
      else {
        # Unselected card
        $card.BorderThickness = "2"
        $card.Background = "#0A$($cardColor.Trim('#'))"
      }
    }
  }
}

# Add click and hover handlers to mode cards
for ($i = 1; $i -le 10; $i++) {
  $card = $window.FindName("Mode${i}Card")
  $mode = "Mode$i"
  $cardColor = $modeConfig[$mode].Color
  
  $card.Add_MouseEnter({
    param($sender, $e)
    if ($script:selectedMode -ne $mode) {
      $sender.Background = "#1A$($cardColor.Trim('#'))"
    }
  }.GetNewClosure())
  
  $card.Add_MouseLeave({
    param($sender, $e)
    if ($script:selectedMode -ne $mode) {
      $sender.Background = "#0A$($cardColor.Trim('#'))"
    }
  }.GetNewClosure())
  
  $card.Add_MouseLeftButtonUp({
    param($sender, $e)
    Select-Mode $mode
  }.GetNewClosure())
}

# Login button handler
$btnLogin.Add_Click({
  Apply-ButtonPulseAnimation $btnLogin
  $password = $passwordBox.Password
  if ($password -ne "dev") {
    [System.Windows.MessageBox]::Show("Invalid Access Key!", "Login Failed", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    $passwordBox.Password = ""
  }
  else {
    $viewLogin.Visibility = [System.Windows.Visibility]::Collapsed
    $viewStart.Visibility = [System.Windows.Visibility]::Visible
  }
})

function Update-FeatureTags {
  param([string[]]$features)
  $featureTags.Children.Clear()
  foreach ($feature in $features) {
    $border = New-Object System.Windows.Controls.Border
    $border.Margin = "2"
    $border.Padding = "8,4"
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
      $grad.StartPoint = "0,0"
      $grad.EndPoint = "0,1"
      $grad.GradientStops.Add((New-Object System.Windows.Media.GradientStop([System.Windows.Media.Color]::FromArgb(80, $color.R, $color.G, $color.B), 0)))
      $grad.GradientStops.Add((New-Object System.Windows.Media.GradientStop([System.Windows.Media.Color]::FromArgb(5, 0, 0, 0), 1)))
      $bd.Background = $grad
    }
  }
}

# --- Navigation Control with Animations ---
$btnStart.Add_Click({
    Apply-ButtonPulseAnimation $btnStart
    Start-Sleep -Milliseconds 150
    
    $btnStart.Visibility = [System.Windows.Visibility]::Collapsed
    $startProgContainer.Visibility = [System.Windows.Visibility]::Visible
    
    $stages = @(
      @{ Value = 15; Text = "Initializing components..." }
      @{ Value = 35; Text = "Checking system environment..." }
      @{ Value = 60; Text = "Loading graphics drivers..." }
      @{ Value = 85; Text = "Configuring system profiles..." }
      @{ Value = 100; Text = "Ready!" }
    )
    
    foreach ($stage in $stages) {
      $startProgText.Text = $stage.Text
      
      $currentVal = $startProgBar.Value
      $targetVal = $stage.Value
      $steps = 8
      $increment = ($targetVal - $currentVal) / $steps
      
      for ($i = 1; $i -le $steps; $i++) {
        $startProgBar.Value = $currentVal + ($increment * $i)
        
        # Refresh UI
        $frame = New-Object System.Windows.Threading.DispatcherFrame
        [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke(
          [System.Windows.Threading.DispatcherPriority]::Background,
          [Action] { $frame.Continue = $false })
        [System.Windows.Threading.Dispatcher]::PushFrame($frame)
        
        Start-Sleep -Milliseconds 25
      }
    }
    
    Start-Sleep -Milliseconds 300
    $viewStart.Visibility = [System.Windows.Visibility]::Collapsed
    $viewMain.Visibility = [System.Windows.Visibility]::Visible
    
    # Initialize launch button colors and features
    Select-Mode "Mode5"
  })

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
  
  # Map mode to intensity level (1-10)
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
    default { 5 }
  }
  
  Log-Write "[ INTENSITY ] Level: $intensity/10"

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
  
  $recvWin = 65536 * ($intensity + 1)
  $sendWin = 65536 * ($intensity + 1)
  $fastThresh = 512 * $intensity
  $transmitSize = 5120 * ($intensity + 1)
  
  Set-ItemProperty -Path $tcpParamPath -Name "DefaultReceiveWindow" -Value $recvWin -Type DWord -Force
  Set-ItemProperty -Path $tcpParamPath -Name "DefaultSendWindow" -Value $sendWin -Type DWord -Force
  Set-ItemProperty -Path $tcpParamPath -Name "FastSendDatagramThreshold" -Value $fastThresh -Type DWord -Force
  Set-ItemProperty -Path $tcpParamPath -Name "FastCopyReceiveThreshold" -Value $fastThresh -Type DWord -Force
  Set-ItemProperty -Path $tcpParamPath -Name "MaxFastTransmit" -Value (5 + $intensity) -Type DWord -Force
  Set-ItemProperty -Path $tcpParamPath -Name "FastTransmitSize" -Value $transmitSize -Type DWord -Force

  # TCP Global Parameters - Extreme optimization
  $tcpGlobal = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
  $maxDupAcks = if ($intensity -ge 7) { 2 } else { 1 }
  Set-ItemProperty -Path $tcpGlobal -Name "TcpMaxDupAcks" -Value $maxDupAcks -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "TCPInitialRTT" -Value (100 - ($intensity * 5)) -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "DefaultTTL" -Value 64 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "MaxUserPort" -Value 65534 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "TcpTimedWaitDelay" -Value (60 - ($intensity * 3)) -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "EnableICMPRedirect" -Value 0 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "EnablePMTUDiscovery" -Value 1 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "TcpWindowSize" -Value 65535 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "TcpAckFrequency" -Value 1 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "TcpNoDelay" -Value 1 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "SackOpts" -Value 1 -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "MaxFreeTcbs" -Value (8000 * $intensity) -Type DWord -Force
  Set-ItemProperty -Path $tcpGlobal -Name "MaxHashTableSize" -Value (32768 * $intensity) -Type DWord -Force
  
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
  
  # Enhance graphics settings
  Enhance-FiveM-Graphics -Mode $Mode
  
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

  # MODULE 3
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
  
  $audioPriority = 5 + [math]::Floor($intensity / 2)
  $audioGpuPriority = 7 + [math]::Floor($intensity / 2)
  $audioSfioPriority = if ($intensity -ge 7) { "Critical" } elseif ($intensity -ge 4) { "High" } else { "Normal" }
  $audioSched = if ($intensity -ge 6) { "High" } elseif ($intensity -ge 3) { "Medium" } else { "Low" }
  
  Set-ItemProperty -Path $mmAudio -Name "Clock Rate" -Value 10000 -Type DWord -Force
  Set-ItemProperty -Path $mmAudio -Name "GPU Priority" -Value $audioGpuPriority -Force
  Set-ItemProperty -Path $mmAudio -Name "Priority" -Value $audioPriority -Force
  Set-ItemProperty -Path $mmAudio -Name "Scheduling Category" -Value $audioSched -Force
  Set-ItemProperty -Path $mmAudio -Name "SFIO Priority" -Value $audioSfioPriority -Force
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

  $dvPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
  if (!(Test-Path $dvPath)) { New-Item -Path $dvPath -Force | Out-Null }
  Set-ItemProperty -Path $dvPath -Name "AllowGameDVR" -Value 0 -Force
  Log-Write "   -> Windows Game Mode optimizations configured."

  # MODULE 6
  Log-Write "[ MODULE 6 ] Combat Mouse Raw Input Pipeline..."
  $mouseQueueSize = 40 - ($intensity * 2)
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value $mouseQueueSize -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Force
  Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Force
  Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Force
  $mouseSensitivity = 5 + $intensity
  Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSensitivity" -Value $mouseSensitivity -Force
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
  Log-Write "   -> Mouse raw pipeline: 1:1, no accel, no smoothing."

  # MODULE 7
  Log-Write "[ MODULE 7 ] Combat Keyboard Response Tuning..."
  $kbQueueSize = 40 - ($intensity * 2)
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value $kbQueueSize -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value 0 -Force
  Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value 31 -Force
  $repeatDelay = 250 - ($intensity * 10)
  $repeatRate = 8 - [math]::Floor($intensity / 2)
  Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "AutoRepeatDelay" -Value $repeatDelay -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "AutoRepeatRate" -Value $repeatRate -Force -EA SilentlyContinue
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
    $targetRes = 10000 - ($intensity * 500)
    if ($targetRes -lt 500) { $targetRes = 500 }
    [TimerResolution]::NtSetTimerResolution($targetRes, $true, [ref]$currentRes) | Out-Null
    $actualMs = [math]::Round($currentRes / 10000, 2)
    Log-Write "   -> Timer resolution forced to ${actualMs}ms."
  }
  catch {
    Log-Write "   -> Timer resolution: using GlobalTimerResolution fallback."
  }
  bcdedit /set disabledynamictick yes 2>$null | Out-Null
  if ($intensity -ge 7) {
    bcdedit /set useplatformtick no 2>$null | Out-Null
    bcdedit /set tscsyncpolicy Enhanced 2>$null | Out-Null
    Log-Write "   -> Dynamic tick disabled, platform tick off (TSC forced)."
  }
  else {
    bcdedit /set useplatformtick yes 2>$null | Out-Null
    Log-Write "   -> Dynamic tick disabled, platform tick forced."
  }

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
  $adapterBuffers = 1024 * $intensity
  Get-NetAdapter | ForEach-Object {
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*ReceiveBuffers" -RegistryValue $adapterBuffers -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*TransmitBuffers" -RegistryValue $adapterBuffers -EA SilentlyContinue
    if ($intensity -ge 7) {
      # Disable Coalescing
      Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "RxIntCoalesce" -RegistryValue 0 -EA SilentlyContinue
      Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "TxIntCoalesce" -RegistryValue 0 -EA SilentlyContinue
      
      # Max Jumbo Packet
      Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*JumboPacket" -RegistryValue 9014 -EA SilentlyContinue
      
      # LSO offloading
      Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*LsoV2IPv4" -RegistryValue 1 -EA SilentlyContinue
      Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*LsoV2IPv6" -RegistryValue 1 -EA SilentlyContinue
    }
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
  $inputQueue = 80 - ($intensity * 5)
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value $inputQueue -Type DWord -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value $inputQueue -Type DWord -Force -EA SilentlyContinue
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataThrottleSize" -Value 0 -Type DWord -Force -EA SilentlyContinue
  
  # Network adapter extreme settings
  $netBuffers = 1024 * $intensity
  Get-NetAdapter | ForEach-Object {
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*ReceiveBuffers" -RegistryValue $netBuffers -EA SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*TransmitBuffers" -RegistryValue $netBuffers -EA SilentlyContinue
    if ($intensity -ge 7) {
      Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "RxIntCoalesce" -RegistryValue 0 -EA SilentlyContinue
      Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "TxIntCoalesce" -RegistryValue 0 -EA SilentlyContinue
      Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*JumboPacket" -RegistryValue 9014 -EA SilentlyContinue
    }
  }
  
  # Extreme mouse settings for faster response
  $sens = 5 + $intensity
  Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSensitivity" -Value "$sens" -Force
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
    
    $sleepSecs = if ($Mode -eq "GodMode") { 1 } else { 3 }
    
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
        [Action] { $frame.Continue = $false })
      [System.Windows.Threading.Dispatcher]::PushFrame($frame)
    }
  
    # Apply breathing glow effect to window border
    Apply-BreathingGlowEffect $window
  
    # Backup current settings before optimization
    Log-Write "[ BACKUP ] Saving current settings before optimization..."
    $backupFile = Backup-CurrentSettings
    Log-Write "   -> Backup saved: $backupFile"
    $btnRestore.IsEnabled = $true
  
    Start-FiveM-Optimization -Mode $script:selectedMode
  
    # Write optimization flag file
    $statusFile = Join-Path $script:BackupFolder "optimized.flag"
    "$($script:selectedMode) on $([DateTime]::Now.ToString('yyyy-MM-dd HH:mm:ss'))" | Set-Content -Path $statusFile -Force
    Log-Write "[ STATUS ] Optimization applied! Flag saved."
  
    if ($progBar) { $progBar.Visibility = [System.Windows.Visibility]::Collapsed }
    $tb = $btnLaunch.Template.FindName("BtnText", $btnLaunch)
    if ($tb) { $tb.Text = "$([char]0x2713) OPTIMIZED SUCCESSFULLY" }
  })

# --- Check optimization status and display in LogBox ---
$statusFile = Join-Path $script:BackupFolder "optimized.flag"
$isOptimized = Test-Path $statusFile
$latestBackup = Get-LatestBackupFile

$startupMsg = "FiveM Performance Engine v4.0 ready...`r`n`r`n"
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
      default { "Unknown" }
    }
    $optMode = "YES ($modeName - Mode $modeNum) $([char]0x2713)"
  }
  else {
    $optMode = "YES $([char]0x2713)"
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
      if ($tb) { $tb.Text = "$([char]0x2713) RESTORED SUCCESSFULLY" }
    
      $btnLaunch.IsEnabled = $true
      $tbLaunch = $btnLaunch.Template.FindName("BtnText", $btnLaunch)
      if ($tbLaunch) { $tbLaunch.Text = "LAUNCH OPTIMIZATION" }
    }
  })

$window.ShowDialog() | Out-Null
