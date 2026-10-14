# Installs Chiron, long-term memory for your AI agents, kept on this computer.
#   powershell -ExecutionPolicy Bypass -File install.ps1
# Downloads the latest release for this Windows PC (x64 or ARM), checks that Mad
# Science signed the release's checksums and that the downloads match them, puts
# them in %USERPROFILE%\.chiron\bin and starts Chiron at login. No admin password.
# Set CHIRON_VERSION=0.5.0 to install a specific one.
$ErrorActionPreference = 'Stop'
# The progress bar makes downloads many times slower in Windows PowerShell 5.
$ProgressPreference = 'SilentlyContinue'

# The Ed25519 public key that `chiron update` also uses (internal/selfupdate).
$releasePublicKey = 'fgNPdtlXysFvPhPBINfTqdvpDl0wPub2O9qS3avHOm0='

$releases = 'https://github.com/Mad-Science-Software/chiron-beta/releases'
if ($env:CHIRON_DOWNLOAD_BASE) {
    $base = $env:CHIRON_DOWNLOAD_BASE  # a local test release (CI)
} elseif ($env:CHIRON_VERSION) {
    $base = "$releases/download/v$($env:CHIRON_VERSION)"
} else {
    $base = "$releases/latest/download"
}

# RFC 8032 Ed25519 verification, because Windows PowerShell 5 has no Ed25519. It
# checks that encode([S]B - [k]A) equals R, as Go's crypto/ed25519 does.
function Test-ReleaseSignature([byte[]]$Content, [string]$SignatureText, [string]$PublicKeyText) {
    Add-Type -AssemblyName System.Numerics
    try { $signature = [Convert]::FromBase64String($SignatureText.Trim()) } catch { return $false }
    $publicKey = [Convert]::FromBase64String($PublicKeyText)
    if ($signature.Length -ne 64 -or $publicKey.Length -ne 32) { return $false }

    $two = [System.Numerics.BigInteger]2
    $p = [System.Numerics.BigInteger]::Pow($two, 255) - 19
    $groupOrder = [System.Numerics.BigInteger]::Pow($two, 252) + [System.Numerics.BigInteger]::Parse('27742317777372353535851937790883648493')
    $highBit = [System.Numerics.BigInteger]::Pow($two, 255)
    function Reduce($value) {
        $remainder = [System.Numerics.BigInteger]::Remainder($value, $p)
        if ($remainder.Sign -lt 0) { $remainder += $p }
        return $remainder
    }
    function Power($value, $exponent) { return [System.Numerics.BigInteger]::ModPow((Reduce $value), $exponent, $p) }
    function FromLittleEndian([byte[]]$bytes) {
        $unsigned = New-Object byte[] ($bytes.Length + 1)
        [Array]::Copy($bytes, $unsigned, $bytes.Length)
        return New-Object System.Numerics.BigInteger (, $unsigned)
    }
    $d = Reduce ([System.Numerics.BigInteger]::Negate(121665) * (Power 121666 ($p - 2)))
    $squareRootOfMinusOne = Power 2 ([System.Numerics.BigInteger]::Divide($p - 1, 4))
    # Points in extended coordinates (X, Y, Z, T); this formula also doubles.
    function AddPoints($first, $second) {
        $a = Reduce (($first[1] - $first[0]) * ($second[1] - $second[0]))
        $b = Reduce (($first[1] + $first[0]) * ($second[1] + $second[0]))
        $c = Reduce ($first[3] * 2 * $d * $second[3])
        $zz = Reduce ($first[2] * 2 * $second[2])
        $e = $b - $a; $f = $zz - $c; $g = $zz + $c; $h = $b + $a
        return , @((Reduce ($e * $f)), (Reduce ($g * $h)), (Reduce ($f * $g)), (Reduce ($e * $h)))
    }

    $encodedR = $signature[0..31]
    $s = FromLittleEndian $signature[32..63]
    if ($s -ge $groupOrder) { return $false }
    $encodedKey = FromLittleEndian $publicKey
    $keyY = [System.Numerics.BigInteger]::Remainder($encodedKey, $highBit)
    $keySign = [System.Numerics.BigInteger]::Divide($encodedKey, $highBit)
    if ($keyY -ge $p) { return $false }
    $u = Reduce ($keyY * $keyY - 1)
    $v = Reduce ($d * $keyY * $keyY + 1)
    $x = Reduce ($u * (Power $v 3) * (Power ($u * (Power $v 7)) ([System.Numerics.BigInteger]::Divide($p - 5, 8))))
    $vxx = Reduce ($v * $x * $x)
    if ($vxx -ne $u) {
        if ($vxx -ne (Reduce (-$u))) { return $false }
        $x = Reduce ($x * $squareRootOfMinusOne)
    }
    if ($x.IsZero -and $keySign -eq 1) { return $false }
    if (([System.Numerics.BigInteger]::Remainder($x, 2)) -ne $keySign) { $x = $p - $x }
    $negativeKeyX = Reduce (-$x)
    $negativeKey = @($negativeKeyX, $keyY, [System.Numerics.BigInteger]::One, (Reduce ($negativeKeyX * $keyY)))

    $baseX = [System.Numerics.BigInteger]::Parse('15112221349535400772501151409588531511454012693041857206046113283949847762202')
    $baseY = [System.Numerics.BigInteger]::Parse('46316835694926478169428394003475163141307993866256225615783033603165251855960')
    $basePoint = @($baseX, $baseY, [System.Numerics.BigInteger]::One, (Reduce ($baseX * $baseY)))
    $basePlusNegativeKey = AddPoints $basePoint $negativeKey

    $sha512 = [System.Security.Cryptography.SHA512]::Create()
    $challenge = [byte[]]($encodedR + $publicKey + $Content)
    $k = [System.Numerics.BigInteger]::Remainder((FromLittleEndian $sha512.ComputeHash($challenge)), $groupOrder)

    $sum = @([System.Numerics.BigInteger]::Zero, [System.Numerics.BigInteger]::One, [System.Numerics.BigInteger]::One, [System.Numerics.BigInteger]::Zero)
    for ($bit = 255; $bit -ge 0; $bit--) {
        $sum = AddPoints $sum $sum
        $power = [System.Numerics.BigInteger]::Pow($two, $bit)
        $sBit = -not ([System.Numerics.BigInteger]::Divide($s, $power)).IsEven
        $kBit = -not ([System.Numerics.BigInteger]::Divide($k, $power)).IsEven
        if ($sBit -and $kBit) { $sum = AddPoints $sum $basePlusNegativeKey }
        elseif ($sBit) { $sum = AddPoints $sum $basePoint }
        elseif ($kBit) { $sum = AddPoints $sum $negativeKey }
    }
    $inverseZ = Power $sum[2] ($p - 2)
    $encodedSum = FromLittleEndian $encodedR
    $sumY = Reduce ($sum[1] * $inverseZ)
    $sumXIsOdd = -not (Reduce ($sum[0] * $inverseZ)).IsEven
    return ($sumY -eq [System.Numerics.BigInteger]::Remainder($encodedSum, $highBit)) -and
        ($sumXIsOdd -eq ([System.Numerics.BigInteger]::Divide($encodedSum, $highBit) -eq 1))
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
    Invoke-WebRequest -UseBasicParsing "$base/checksums.txt.sig" -OutFile (Join-Path $work 'checksums.txt.sig')
    $checksumsContent = [IO.File]::ReadAllBytes((Join-Path $work 'checksums.txt'))
    $signatureText = [IO.File]::ReadAllText((Join-Path $work 'checksums.txt.sig'))
    if (-not (Test-ReleaseSignature $checksumsContent $signatureText $releasePublicKey)) {
        throw "The release's checksums aren't signed by Mad Science; not installing it."
    }
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
