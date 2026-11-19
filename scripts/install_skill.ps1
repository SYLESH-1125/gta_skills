# Installs the stream-clips skill for Claude Code on Windows and runs its setup.
# Run from the repo root:  powershell -ExecutionPolicy Bypass -File scripts\install_skill.ps1
$ErrorActionPreference = "Stop"
$dest = Join-Path $env:USERPROFILE ".claude\skills"
New-Item -ItemType Directory -Force $dest | Out-Null
Copy-Item -Recurse -Force (Join-Path $PSScriptRoot "..\skills\stream-clips") $dest

foreach ($tool in "ffmpeg", "python") {
  if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) { Write-Warning "$tool not found" }
}
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) { Write-Host "Install it with: winget install Gyan.FFmpeg  (then open a new terminal)" }
if (-not ((Get-Command node -ErrorAction SilentlyContinue) -or (Get-Command deno -ErrorAction SilentlyContinue))) {
  Write-Host "YouTube downloads need a JS runtime: winget install DenoLand.Deno"
}
python (Join-Path $dest "stream-clips\scripts\streamclips.py") setup
