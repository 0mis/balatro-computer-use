[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$InputPath,
    [Parameter(Mandatory = $true)][string]$OutputPath,
    [ValidateSet('Remux', 'Phone')][string]$Mode = 'Remux'
)

$ErrorActionPreference = 'Stop'
$inputFile = (Resolve-Path -LiteralPath $InputPath).Path
$outputFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
if (Test-Path -LiteralPath $outputFile) { throw "Output already exists: $outputFile" }
$ffmpeg = (Get-Command ffmpeg -ErrorAction Stop).Source

$arguments = @('-n', '-hide_banner', '-i', $inputFile, '-map', '0:v:0', '-map', '0:a:0')
if ($Mode -eq 'Phone') {
    $arguments += @('-vf', 'fps=15,scale=854:480', '-c:v', 'libx264', '-preset', 'ultrafast',
        '-threads', '4', '-b:v', '350k', '-maxrate', '350k', '-bufsize', '700k', '-c:a', 'aac', '-b:a', '48k')
} else {
    $arguments += @('-c', 'copy')
}
$arguments += @('-movflags', '+faststart', $outputFile)
& $ffmpeg @arguments
if ($LASTEXITCODE -ne 0) { throw "FFmpeg failed with exit code $LASTEXITCODE" }
Write-Output $outputFile
