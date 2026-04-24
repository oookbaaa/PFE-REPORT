$dir = 'C:\Users\BEDHIAFI\Desktop\Projects\TRUSTGYM\PFE REPORT\TrustGym_PFE_Report\img\capture'
$src = Join-Path $dir 'CRON Jobs terminal.png'
$dst = Join-Path $dir 'cronjobs-terminal.png'
if (Test-Path -LiteralPath $src) {
    Rename-Item -LiteralPath $src -NewName 'cronjobs-terminal.png'
    Write-Host "Renamed OK"
} elseif (Test-Path -LiteralPath $dst) {
    Write-Host "Already named correctly"
} else {
    Write-Host "File not found"
    Get-ChildItem -LiteralPath $dir | Where-Object { $_.Name -like '*CRON*' -or $_.Name -like '*ron*' } | ForEach-Object { $_.Name }
}
