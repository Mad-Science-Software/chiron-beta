# Installs Chiron, long-term memory for your AI agents, kept on this computer.
#   powershell -ExecutionPolicy Bypass -File install.ps1
# Downloads the latest release for this Windows PC (x64 or ARM), checks it against
# the release's checksums, puts it in %USERPROFILE%\.chiron\bin and starts it at
# login. No admin password. Set CHIRON_VERSION=0.5.0 to install a specific one.
$ErrorActionPreference = 'Stop'
# The progress bar makes downloads many times slower in Windows PowerShell 5.
$ProgressPreference = 'SilentlyContinue'

$releases = 'https://github.com/Mad-Science-Software/chiron-beta/releases'
if ($env:CHIRON_DOWNLOAD_BASE) {
    $base = $env:CHIRON_DOWNLOAD_BASE  # a local test release (CI)
} elseif ($env:CHIRON_VERSION) {
    $base = "$releases/download/v$($env:CHIRON_VERSION)"
} else {
    $base = "$releases/latest/download"
}

# The machine's own architecture, from the registry: an emulated PowerShell on an
# ARM PC reports AMD64 everywhere else, which would install the slower build.
$osArchitecture = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment').PROCESSOR_ARCHITECTURE
switch ($osArchitecture) {
    'AMD64' { $arch = 'amd64' }
    'ARM64' { $arch = 'arm64' }
    default { throw "Chiron doesn't have a release for Windows on $osArchitecture yet." }
}

$work = Join-Path ([IO.Path]::GetTempPath()) ("chiron-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $work | Out-Null
try {
    Invoke-WebRequest -UseBasicParsing "$base/checksums.txt" -OutFile (Join-Path $work 'checksums.txt')
    $checksums = Get-Content (Join-Path $work 'checksums.txt')
    # chiron.exe for the command line and agents; chironw.exe, the same program
    # without a console window, runs at login.
    foreach ($program in 'chiron', 'chironw') {
        $asset = "$program-windows-$arch.exe"
        $file = Join-Path $work "$program.exe"
        Write-Host "Downloading Chiron ($asset)..."
        Invoke-WebRequest -UseBasicParsing "$base/$asset" -OutFile $file
        $expected = $null
        foreach ($line in $checksums) {
            $fields = $line -split '\s+'
            if ($fields.Count -ge 2 -and $fields[1].TrimStart('*') -eq $asset) { $expected = $fields[0].ToLower() }
        }
        $actual = (Get-FileHash -Algorithm SHA256 $file).Hash.ToLower()
        if (-not $expected -or $expected -ne $actual) {
            throw "The download of $asset doesn't match the release's checksum; not installing it."
        }
    }
    & (Join-Path $work 'chiron.exe') install
    if ($LASTEXITCODE -ne 0) { throw "chiron install failed (exit code $LASTEXITCODE)." }
} finally {
    Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
}
Write-Host ""
Write-Host "Installed. Next: add the Claude Code plugin (see docs/setup.md), then start a new Claude Code session."
