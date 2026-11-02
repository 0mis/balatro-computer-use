[CmdletBinding()]
param(
    [string]$PartsDirectory = '.',
    [string]$OutputPath = '.\Balatro-winning-run-720p.mp4'
)

$ErrorActionPreference = 'Stop'
$directory = (Resolve-Path -LiteralPath $PartsDirectory).Path
$manifestPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'assets\recording-manifest.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$outputFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
if (Test-Path -LiteralPath $outputFile) { throw "Output already exists: $outputFile" }

# Verify every downloaded part before creating the assembled file.
foreach ($part in $manifest.full_quality.parts) {
    $partPath = Join-Path $directory $part.name
    $partFile = Get-Item -LiteralPath $partPath
    if ($partFile.Length -ne $part.bytes) { throw "Size mismatch: $($part.name)" }
    if ((Get-FileHash -LiteralPath $partPath -Algorithm SHA256).Hash.ToLowerInvariant() -ne $part.sha256) {
        throw "Checksum mismatch: $($part.name)"
    }
}

$outputStream = [IO.File]::Open($outputFile, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write)
try {
    foreach ($part in $manifest.full_quality.parts) {
        $inputStream = [IO.File]::OpenRead((Join-Path $directory $part.name))
        try { $inputStream.CopyTo($outputStream) } finally { $inputStream.Dispose() }
    }
} finally { $outputStream.Dispose() }

if ((Get-Item -LiteralPath $outputFile).Length -ne $manifest.full_quality.bytes -or
    (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant() -ne $manifest.full_quality.sha256) {
    throw "Assembled file failed verification: $outputFile"
}
Write-Output "Verified recording: $outputFile"
