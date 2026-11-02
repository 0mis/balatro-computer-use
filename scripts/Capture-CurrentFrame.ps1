[CmdletBinding()]
param(
    [string]$RecordingDirectory = '.',
    [string]$OutputPath = '.\current-game.png'
)

$ErrorActionPreference = 'Stop'
$directory = (Resolve-Path -LiteralPath $RecordingDirectory).Path
$recording = Get-ChildItem -LiteralPath $directory -Filter '*.mkv' -File |
    Sort-Object CreationTimeUtc -Descending | Select-Object -First 1
if (-not $recording) { throw 'No MKV recording found' }
$ffmpeg = (Get-Command ffmpeg -ErrorAction Stop).Source
$imagePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
if ([IO.Path]::GetExtension($imagePath) -ne '.png') { throw 'OutputPath must end in .png' }
$before = if (Test-Path -LiteralPath $imagePath) {
    (Get-Item -LiteralPath $imagePath).LastWriteTimeUtc
} else { [DateTime]::MinValue }

Start-Sleep -Milliseconds 3000
$seek = [math]::Max(0, ([DateTime]::UtcNow - $recording.CreationTimeUtc).TotalSeconds - 8)
& $ffmpeg -hide_banner -loglevel fatal -ss $seek.ToString('0.000', [Globalization.CultureInfo]::InvariantCulture) `
    -i $recording.FullName -vf 'fps=4,reverse' -frames:v 1 -y $imagePath
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $imagePath)) {
    throw 'FFmpeg could not extract a recent frame'
}
if ((Get-Item -LiteralPath $imagePath).LastWriteTimeUtc -le $before) { throw 'No fresh recorded frame was produced' }
Write-Output $imagePath
