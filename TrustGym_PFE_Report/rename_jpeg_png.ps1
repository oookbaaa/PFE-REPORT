$dir = 'C:\Users\BEDHIAFI\Desktop\Projects\TRUSTGYM\PFE REPORT\TrustGym_PFE_Report\img\capture'
$files = @('ecran-connexion-mobile', 'seances-mobile', 'planning-seances-mobile')
foreach ($f in $files) {
    $src = Join-Path $dir "$f.jpeg"
    $dst = Join-Path $dir "$f.png"
    if (Test-Path -LiteralPath $src) {
        Rename-Item -LiteralPath $src -NewName "$f.png"
        Write-Host "Renamed: $f.jpeg -> $f.png" -ForegroundColor Green
    } elseif (Test-Path -LiteralPath $dst) {
        Write-Host "Already .png: $f.png" -ForegroundColor Yellow
    } else {
        Write-Host "Not found: $f.jpeg" -ForegroundColor Red
    }
}
