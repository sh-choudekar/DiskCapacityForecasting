# scripts/Collect-DriveCapacity.ps1
# ---------------------------------
param(
    [string]$ServerListPath = "C:\temp\servers.txt",
    [switch]$IncludeAllDrives,
    [string[]]$DriveLetters = @('D:\','E:\','F:\'),
    [string]$OutputFolder = "C:\Output\DriveCapacityLive",
    [datetime]$DateOverride,
    [System.Management.Automation.PSCredential]$Credential
)

$null = New-Item -Path $OutputFolder -ItemType Directory -Force -ErrorAction SilentlyContinue
$AsOf = if ($PSBoundParameters.ContainsKey('DateOverride')) { $DateOverride.Date } else { (Get-Date).Date }
$targetDeviceIds = $DriveLetters | ForEach-Object { (($_ -replace '\\','').TrimEnd(':')) + ':' }

if (-not (Test-Path $ServerListPath)) { throw "Server list not found: $ServerListPath" }
$Servers = Get-Content $ServerListPath | Where-Object { $_ } | ForEach-Object { $_.Trim() } | Select-Object -Unique
if (-not $Servers) { throw "No servers found in $ServerListPath" }

$rows = [System.Collections.Generic.List[object]]::new()

function Add-DriveRow {
    param([string]$Server,[string]$DeviceId,[double]$SizeBytes,[double]$FreeBytes)
    $totalGB = if ($SizeBytes -gt 0) { [math]::Round($SizeBytes/1GB,2) } else { 0 }
    $freeGB  = if ($FreeBytes -ge 0) { [math]::Round($FreeBytes/1GB,2) } else { 0 }
    $pct     = if ($SizeBytes -gt 0) { [math]::Round(($FreeBytes/$SizeBytes)*100,2) } else { $null }
    $rows.Add([pscustomobject]@{
        'Capture Date'        = $AsOf.ToString('yyyy-MM-dd')
        'Capture Day'         = $AsOf.ToString('dddd')
        'ServerName'          = $Server
        'Drive Letters'       = ($DeviceId.TrimEnd(':') + ':\')
        'TotalSizeDrive'      = $totalGB
        'FreeSpaceDrive'      = $freeGB
        'FreeSpacePercentage' = $pct
    }) | Out-Null
}

foreach ($s in $Servers) {
    try {
        $sess = if ($Credential) { New-CimSession -ComputerName $s -Credential $Credential -ErrorAction Stop } else { New-CimSession -ComputerName $s -ErrorAction Stop }
        $disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -CimSession $sess -ErrorAction Stop
        if (-not $IncludeAllDrives) { $disks = $disks | Where-Object { $targetDeviceIds -contains $_.DeviceID } }
        if ($disks) { foreach ($d in $disks) { Add-DriveRow -Server $s -DeviceId $d.DeviceID -SizeBytes $d.Size -FreeBytes $d.FreeSpace } } else { Write-Warning "No matching fixed drives on $s" }
    } catch { Write-Warning "Failed to query $s : $($_.Exception.Message)" } finally { if ($sess) { $sess | Remove-CimSession } }
}

$fileName = "StorageCapacity-{0}.csv" -f $AsOf.ToString('MMMM-dd-yyyy')
$rows | Export-Csv (Join-Path $OutputFolder $fileName) -NoTypeInformation -Encoding UTF8
Write-Host "Saved: " (Join-Path $OutputFolder $fileName)
