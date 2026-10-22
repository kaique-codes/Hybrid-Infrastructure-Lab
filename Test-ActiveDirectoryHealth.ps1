[CmdletBinding()]
param(
    [string]$OutputDirectory = ""
)

$ErrorActionPreference = 'Continue'
$timestamp = (Get-Date).ToUniversalTime().ToString('o')
$results = [System.Collections.Generic.List[object]]::new()

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error 'Módulo ActiveDirectory ausente. Instale/ative RSAT conforme a política da sua organização e execute novamente.'
    return
}
Import-Module ActiveDirectory -ErrorAction Stop

try {
    $controllers = Get-ADDomainController -Filter * -ErrorAction Stop
    foreach ($dc in $controllers) {
        $results.Add([pscustomobject]@{ TimestampUtc=$timestamp; Check='DomainController'; Target=$dc.HostName; Status='DISCOVERED'; Detail=("Site={0}; IPv4={1}; OperatingSystem={2}" -f $dc.Site, $dc.IPv4Address, $dc.OperatingSystem) })
    }
} catch {
    $results.Add([pscustomobject]@{ TimestampUtc=$timestamp; Check='DomainController'; Target='Domain'; Status='ERROR'; Detail=$_.Exception.Message })
}

foreach ($toolName in @('repadmin.exe', 'dcdiag.exe')) {
    $tool = Get-Command $toolName -ErrorAction SilentlyContinue
    if ($null -eq $tool) {
        $results.Add([pscustomobject]@{ TimestampUtc=$timestamp; Check='ADTool'; Target=$toolName; Status='NOT_FOUND'; Detail='Ferramenta não encontrada neste host.' })
        continue
    }
    $arguments = if ($toolName -eq 'repadmin.exe') { @('/replsummary') } else { @('/q') }
    $output = & $tool.Source @arguments 2>&1
    $exitCode = $LASTEXITCODE
    $status = if ($exitCode -eq 0) { 'COMPLETED' } else { 'REVIEW' }
    $text = ($output | Out-String).Trim()
    if ($text.Length -gt 3500) { $text = $text.Substring(0, 3500) + ' ... [saída truncada]' }
    $results.Add([pscustomobject]@{ TimestampUtc=$timestamp; Check='ADTool'; Target=$toolName; Status=$status; Detail=("ExitCode={0}; {1}" -f $exitCode, $text) })
}

$results | Format-List
if (-not [string]::IsNullOrWhiteSpace($OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    $outFile = Join-Path $OutputDirectory ("ad-health-{0}.json" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    $results | ConvertTo-Json -Depth 5 | Set-Content -Path $outFile -Encoding UTF8
    Write-Host "Relatório salvo em: $outFile"
}
