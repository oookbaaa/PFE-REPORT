$log = 'C:\Users\BEDHIAFI\Desktop\Projects\TRUSTGYM\PFE REPORT\TrustGym_PFE_Report\main.log'
$lines = Get-Content -LiteralPath $log
$matches = $lines | Select-String -Pattern 'not found|! Error|undefined reference|LaTeX Warning'
$matches | Select-Object -First 40 | ForEach-Object { $_.Line }
