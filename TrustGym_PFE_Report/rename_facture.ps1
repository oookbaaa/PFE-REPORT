$dir = 'C:\Users\BEDHIAFI\Desktop\Projects\TRUSTGYM\PFE REPORT\TrustGym_PFE_Report\img\capture'
$src = Join-Path $dir 'Facture B2B.png'
if (Test-Path -LiteralPath $src) {
    Rename-Item -LiteralPath $src -NewName 'facture-b2b-detail.png'
    Write-Host "Renamed OK"
} else {
    Write-Host "File not found"
}
