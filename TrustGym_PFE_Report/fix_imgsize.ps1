$chaptersDir = "C:\Users\BEDHIAFI\Desktop\Projects\TRUSTGYM\PFE REPORT\TrustGym_PFE_Report\chapters"
$old = "[width=\textwidth]{capture/"
$new = "[width=\textwidth, height=0.75\textheight, keepaspectratio]{capture/"

Get-ChildItem -Path $chaptersDir -Filter "*.tex" | ForEach-Object {
    $content = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8
    if ($content.Contains($old)) {
        $updated = $content.Replace($old, $new)
        [System.IO.File]::WriteAllText($_.FullName, $updated, [System.Text.Encoding]::UTF8)
        Write-Host "Updated: $($_.Name)" -ForegroundColor Green
    } else {
        Write-Host "Skipped: $($_.Name)" -ForegroundColor Yellow
    }
}
Write-Host "Done." -ForegroundColor Cyan
