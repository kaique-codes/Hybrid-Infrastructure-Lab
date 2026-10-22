[CmdletBinding()]
param(
    [string[]]$DnsNames = @('localhost'),
    [string[]]$Targets = @('127.0.0.1'),
    [int[]]$Ports = @(443),
    [string]$OutputDirectory = ""
)

$ErrorActionPreference = 'Continue'
$timestamp = (Get-Date).ToUniversalTime().ToString('o')
$results = [System.Collections.Generic.List[object]]::new()

foreach ($name in $DnsNames) {
    try {
        $answer = Resolve-DnsName -Name $name -ErrorAction Stop | Select-Object -First 5
        $values = ($answer | ForEach-Object { if ($_.IPAddress) { $_.IPAddress } elseif ($_.NameHost) { $_.NameHost } }) -join ', '
        $results.Add([pscustomobject]@{ TimestampUtc=$timestamp; Check='DNS'; Target=$name; Port=''; Status='OK'; Detail=$values })
    } catch {
        $results.Add([pscustomobject]@{ TimestampUtc=$timestamp; Check='DNS'; Target=$name; Port=''; Status='ERROR'; Detail=$_.Exception.Message })
    }
}

foreach ($target in $Targets) {
    foreach ($port in $Ports) {
        try {
            $test = Test-NetConnection -ComputerName $target -Port $port -WarningAction SilentlyContinue -InformationLevel Detailed
            $status = if ($test.TcpTestSucceeded) { 'OK' } else { 'FAILED' }
            $detail = "RemoteAddress={0}; Interface={1}; SourceAddress={2}" -f $test.RemoteAddress, $test.InterfaceAlias, $test.SourceAddress
            $results.Add([pscustomobject]@{ TimestampUtc=$timestamp; Check='TCP'; Target=$target; Port=$port; Status=$status; Detail=$detail })
        } catch {
            $results.Add([pscustomobject]@{ TimestampUtc=$timestamp; Check='TCP'; Target=$target; Port=$port; Status='ERROR'; Detail=$_.Exception.Message })
        }
    }
}

$results | Format-Table -AutoSize
if (-not [string]::IsNullOrWhiteSpace($OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    $outFile = Join-Path $OutputDirectory ("connectivity-{0}.csv" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    $results | Export-Csv -Path $outFile -NoTypeInformation -Encoding UTF8
    Write-Host "Relatório salvo em: $outFile"
}
