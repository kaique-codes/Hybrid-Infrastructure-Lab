[CmdletBinding()]
param(
    [string]$OutputDirectory = ""
)

$ErrorActionPreference = 'Continue'
$timestamp = (Get-Date).ToUniversalTime().ToString('o')
$results = [System.Collections.Generic.List[object]]::new()

function Add-Result {
    param([string]$Check, [string]$Target, [string]$Status, [string]$Detail)
    $results.Add([pscustomobject]@{
        TimestampUtc = $timestamp
        Check        = $Check
        Target       = $Target
        Status       = $Status
        Detail       = $Detail
    })
}

try {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
    Add-Result -Check 'OperatingSystem' -Target $env:COMPUTERNAME -Status 'OK' -Detail ("{0}; Version={1}; LastBoot={2}" -f $os.Caption, $os.Version, $os.LastBootUpTime)
} catch {
    Add-Result -Check 'OperatingSystem' -Target $env:COMPUTERNAME -Status 'ERROR' -Detail $_.Exception.Message
}

try {
    $volumes = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction Stop
    foreach ($volume in $volumes) {
        $freePct = if ($volume.Size -gt 0) { [math]::Round(($volume.FreeSpace / $volume.Size) * 100, 1) } else { 0 }
        $status = if ($freePct -lt 10) { 'WARNING' } else { 'OK' }
        $detail = "Free={0:N1} GB; Size={1:N1} GB; FreePercent={2}" -f ($volume.FreeSpace / 1GB), ($volume.Size / 1GB), $freePct
        Add-Result -Check 'DiskSpace' -Target $volume.DeviceID -Status $status -Detail $detail
    }
} catch {
    Add-Result -Check 'DiskSpace' -Target 'LocalDisks' -Status 'ERROR' -Detail $_.Exception.Message
}

$serviceNames = @('NTDS', 'DNS', 'DHCPServer', 'Kdc', 'Netlogon', 'W32Time', 'LanmanServer')
foreach ($name in $serviceNames) {
    $service = Get-Service -Name $name -ErrorAction SilentlyContinue
    if ($null -eq $service) {
        Add-Result -Check 'WindowsService' -Target $name -Status 'NOT_INSTALLED' -Detail 'Serviço não encontrado neste host; pode ser esperado dependendo da função do servidor.'
    } else {
        $status = if ($service.Status -eq 'Running') { 'OK' } else { 'WARNING' }
        Add-Result -Check 'WindowsService' -Target $name -Status $status -Detail ("Status={0}; StartType={1}" -f $service.Status, $service.StartType)
    }
}

$results | Format-Table -AutoSize
if (-not [string]::IsNullOrWhiteSpace($OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    $outFile = Join-Path $OutputDirectory ("windows-health-{0}.csv" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    $results | Export-Csv -Path $outFile -NoTypeInformation -Encoding UTF8
    Write-Host "Relatório salvo em: $outFile"
}
