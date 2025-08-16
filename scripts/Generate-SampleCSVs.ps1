# scripts/Generate-SampleCSVs.ps1
# --------------------------------
# Creates one CSV per Monday from Jan–Jul 2025 under C:\Output\DriveCapacitySamples

$OutputFolder = 'C:\Output\DriveCapacitySamples'
New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null

$Servers = @(
  'SQLDB-Prod-01','SQLDB-Prod-02','SQLDB-Dev-01','SQLDB-Dev-02',
  'SQLDB-Test-01','SQLDB-Test-02','SQLDB-Staging-01','SQLDB-Staging-02',
  'SQLDB-Archive-01','SQLDB-Backup-01'
)
$Drives = @('D:\','E:\','F:\')

$start = Get-Date '2025-01-01'
$end   = Get-Date '2025-07-31'
while ($start.DayOfWeek -ne 'Monday') { $start = $start.AddDays(1) }

$rand = [System.Random]::new()
$totalSizeMap = @{}
foreach ($s in $Servers) {
  foreach ($d in $Drives) {
    $size = [Math]::Round(200 + ($rand.NextDouble() * (800 - 200)), 2)
    $totalSizeMap["$s|$d"] = $size
  }
}

function Get-FreeSpaceGB([double]$total, [System.Random]$r) {
  $min = [Math]::Max(1, $total * 0.05); $max = $total * 0.90
  [Math]::Round($min + ($r.NextDouble() * ($max - $min)), 2)
}

for ($dte = $start; $dte -le $end; $dte = $dte.AddDays(7)) {
  $rows = [System.Collections.Generic.List[object]]::new()
  foreach ($s in $Servers) {
    foreach ($drv in $Drives) {
      $total = $totalSizeMap["$s|$drv"]
      $free  = Get-FreeSpaceGB -total $total -r $rand
      $rows.Add([pscustomobject]@{
        'Capture Date'        = $dte.ToString('yyyy-MM-dd')
        'Capture Day'         = $dte.DayOfWeek.ToString()
        'ServerName'          = $s
        'Drive Letters'       = $drv
        'TotalSizeDrive'      = $total
        'FreeSpaceDrive'      = $free
        'FreeSpacePercentage' = [Math]::Round(($free / $total) * 100, 2)
      }) | Out-Null
    }
  }
  $fileName = "StorageCapacity-{0}.csv" -f $dte.ToString('MMMM-dd-yyyy')
  $rows | Export-Csv (Join-Path $OutputFolder $fileName) -NoTypeInformation -Encoding UTF8
}
Write-Host "Sample files saved to $OutputFolder"
