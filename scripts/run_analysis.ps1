param(
    [Parameter(Mandatory = $true)]
    [string]$User
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$mysqlCandidates = @(
    (Join-Path $env:ProgramFiles 'MySQL\MySQL Server 8.0\bin\mysql.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'MySQL\MySQL Server 8.0\bin\mysql.exe')
)
$mysqlExe = $mysqlCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $mysqlExe) {
    throw 'mysql.exe was not found in the standard MySQL Server 8.0 install locations. Edit $mysqlCandidates in this script to point to your client.'
}

$sqlFiles = @(
    'sql/04_beginner_analysis.sql',
    'sql/05_intermediate_analysis.sql',
    'sql/06_advanced_analysis.sql'
)

Push-Location $repositoryRoot
try {
    foreach ($relativeSql in $sqlFiles) {
        $resultName = [System.IO.Path]::GetFileNameWithoutExtension($relativeSql) + '.tsv'
        $resultPath = Join-Path $repositoryRoot (Join-Path 'results' $resultName)
        Write-Host "Running $relativeSql; MySQL will prompt for your password."

        & $mysqlExe "--user=$User" --password --batch --raw "--execute=source $relativeSql" 2>&1 |
            Tee-Object -FilePath $resultPath

        # Windows PowerShell 5.1 writes Tee-Object output as UTF-16LE by default.
        # Store the snapshots as UTF-8 text so GitHub can display the TSV files.
        $capturedOutput = [System.IO.File]::ReadAllText($resultPath)
        [System.IO.File]::WriteAllText($resultPath, $capturedOutput, [System.Text.UTF8Encoding]::new($false))

        if ($LASTEXITCODE -ne 0) {
            throw "MySQL failed while running $relativeSql (exit code $LASTEXITCODE). See $resultPath for the error output."
        }
        Write-Host "Saved actual query output to $resultPath"
    }
}
finally {
    Pop-Location
}
