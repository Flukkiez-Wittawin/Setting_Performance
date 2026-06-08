Write-Host "[10/10] Wiping PowerShell Command History (Obliterating Console Footprints)..." -ForegroundColor Cyan
Clear-History -ErrorAction SilentlyContinue
if (Get-Command Get-PSReadLineOption -ErrorAction SilentlyContinue) {
    $historyPath = (Get-PSReadLineOption).HistorySavePath
    if (Test-Path $historyPath) {
        Remove-Item $historyPath -Force -ErrorAction SilentlyContinue
    }
}
Write-Host "-> Session and PSReadLine history successfully deleted!" -ForegroundColor Green
