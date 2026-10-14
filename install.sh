#!/bin/sh
# Installs Chiron, long-term memory for your AI agents, kept on this computer.
#   curl -fsSL https://github.com/Mad-Science-Software/chiron-beta/releases/latest/download/install.sh | sh
# Downloads the latest release for this Mac or Linux machine, checks that Mad Science
# signed the release's checksums and that the download matches them, puts it in
# ~/.chiron/bin and starts it at login. No admin password. Set CHIRON_VERSION=0.4.0
# to install a specific one.
set -eu

# The Ed25519 public key that `chiron update` also uses (internal/selfupdate).
release_public_key="fgNPdtlXysFvPhPBINfTqdvpDl0wPub2O9qS3avHOm0="

releases="https://github.com/Mad-Science-Software/chiron-beta/releases"
if [ -n "${CHIRON_DOWNLOAD_BASE:-}" ]; then
  base="$CHIRON_DOWNLOAD_BASE" # a local test release
elif [ -n "${CHIRON_VERSION:-}" ]; then
  base="$releases/download/v$CHIRON_VERSION"
else
  base="$releases/latest/download"
fi

case "$(uname -s)/$(uname -m)" in
  Darwin/*)              asset="chiron-darwin-universal" ;;
  Linux/x86_64)          asset="chiron-linux-amd64" ;;
  Linux/aarch64|Linux/arm64) asset="chiron-linux-arm64" ;;
  *) echo "Chiron doesn't have a release for $(uname -s) $(uname -m) yet." >&2; exit 1 ;;
esac

decode_base64() {
  if printf 'YQ==' | base64 -d >/dev/null 2>&1; then
    tr -d ' \r\n' < "$1" | base64 -d
  else
    tr -d ' \r\n' < "$1" | openssl base64 -d -A
  fi
}

sha_hex() {
  bits="$1"
  if command -v "sha${bits}sum" >/dev/null 2>&1; then
    "sha${bits}sum" < "$2" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a "$bits" < "$2" | awk '{print $1}'
  else
    openssl dgst "-sha$bits" -r < "$2" | awk '{print $1}'
  fi
}

hex_of_file() {
  od -An -v -tx1 "$1" | tr -d ' \n'
}

# Hexadecimal bytes in little-endian order, as one uppercase number for bc.
little_endian_number() {
  printf '0'
  awk '{ for (position = length($0) - 1; position >= 1; position -= 2) printf "%s", toupper(substr($0, position, 2)) }'
}

# OpenSSL 3 verifies Ed25519 itself. LibreSSL (macOS) and OpenSSL 1.1 do not.
openssl_verifies_ed25519() {
  command -v openssl >/dev/null 2>&1 && openssl version 2>/dev/null | grep -q '^OpenSSL [3-9]\.'
}

verify_with_openssl() {
  # The fixed DER prefix of an Ed25519 public key, then the 32 key bytes.
  { printf '\060\052\060\005\006\003\053\145\160\003\041\000'; cat "$work/public-key.bin"; } > "$work/public-key.der"
  openssl pkeyutl -verify -pubin -keyform DER -inkey "$work/public-key.der" -rawin \
    -in "$work/checksums.txt" -sigfile "$work/signature.bin" >/dev/null 2>&1
}

# RFC 8032 Ed25519 verification in bc, for machines without OpenSSL 3: it checks that
# encode([S]B - [k]A) equals R, as Go's crypto/ed25519 does.
verify_with_bc() {
  head -c 32 "$work/signature.bin" > "$work/signature-r.bin"
  tail -c 32 "$work/signature.bin" > "$work/signature-s.bin"
  cat "$work/signature-r.bin" "$work/public-key.bin" "$work/checksums.txt" > "$work/challenge.bin"
  result="$(BC_LINE_LENGTH=0 bc <<BC_PROGRAM
define m(a) {
  a = a % p
  if (a < 0) a = a + p
  return (a)
}
define pw(b, e) {
  auto r
  r = 1
  b = m(b)
  while (e > 0) {
    if (e % 2 == 1) r = m(r * b)
    b = m(b * b)
    e = e / 2
  }
  return (r)
}
define add() {
  auto a, b, c, e, f, g, h, dd
  a = m((y1 - x1) * (y2 - x2))
  b = m((y1 + x1) * (y2 + x2))
  c = m(t1 * 2 * d * t2)
  dd = m(z1 * 2 * z2)
  e = b - a
  f = dd - c
  g = dd + c
  h = b + a
  x3 = m(e * f)
  y3 = m(g * h)
  t3 = m(e * h)
  z3 = m(f * g)
  return (0)
}
define addq(px, py, pz, pt) {
  x1 = qx
  y1 = qy
  z1 = qz
  t1 = qt
  x2 = px
  y2 = py
  z2 = pz
  t2 = pt
  unused = add()
  qx = x3
  qy = y3
  qz = z3
  qt = t3
  return (0)
}
define decompress(y, sign) {
  auto u, v, x, vxx
  if (y >= p) return (0)
  u = m(y * y - 1)
  v = m(d * y * y + 1)
  x = m(u * pw(v, 3) * pw(u * pw(v, 7), (p - 5) / 8))
  vxx = m(v * x * x)
  if (vxx != u) {
    if (vxx != m(0 - u)) return (0)
    x = m(x * sqrtm1)
  }
  if (x == 0) {
    if (sign == 1) return (0)
  }
  if (x % 2 != sign) x = p - x
  ax = x
  ay = y
  return (1)
}
p = 2^255 - 19
l = 2^252 + 27742317777372353535851937790883648493
d = m(0 - 121665 * pw(121666, p - 2))
sqrtm1 = pw(2, (p - 1) / 4)
bx = 15112221349535400772501151409588531511454012693041857206046113283949847762202
by = 46316835694926478169428394003475163141307993866256225615783033603165251855960
ibase = 16
rr = $(hex_of_file "$work/signature-r.bin" | little_endian_number)
s = $(hex_of_file "$work/signature-s.bin" | little_endian_number)
aa = $(hex_of_file "$work/public-key.bin" | little_endian_number)
k = $(sha_hex 512 "$work/challenge.bin" | little_endian_number)
ibase = A
ok = 1
if (s >= l) ok = 0
if (decompress(aa % 2^255, aa / 2^255) == 0) ok = 0
k = k % l
bt = m(bx * by)
nx = m(0 - ax)
ny = ay
nt = m(nx * ny)
qx = bx
qy = by
qz = 1
qt = bt
unused = addq(nx, ny, 1, nt)
bnx = qx
bny = qy
bnz = qz
bnt = qt
qx = 0
qy = 1
qz = 1
qt = 0
for (bit = 255; bit >= 0; bit--) {
  unused = addq(qx, qy, qz, qt)
  power = 2^bit
  sbit = (s / power) % 2
  kbit = (k / power) % 2
  if (sbit == 1) {
    if (kbit == 1) unused = addq(bnx, bny, bnz, bnt)
    if (kbit == 0) unused = addq(bx, by, 1, bt)
  }
  if (sbit == 0) {
    if (kbit == 1) unused = addq(nx, ny, 1, nt)
  }
}
zi = pw(qz, p - 2)
if (m(qy * zi) != rr % 2^255) ok = 0
if (m(qx * zi) % 2 != rr / 2^255) ok = 0
ok
BC_PROGRAM
)"
  [ "$result" = 1 ]
}

verify_signature() {
  printf '%s' "$release_public_key" > "$work/public-key.base64"
  decode_base64 "$work/public-key.base64" > "$work/public-key.bin"
  decode_base64 "$work/checksums.txt.sig" > "$work/signature.bin" 2>/dev/null || return 1
  [ "$(wc -c < "$work/signature.bin" | tr -d ' ')" = 64 ] || return 1
  if openssl_verifies_ed25519; then
    verify_with_openssl
  elif command -v bc >/dev/null 2>&1; then
    verify_with_bc
  else
    echo "Checking the release's signature needs bc or OpenSSL 3. Install one of them, then run this again." >&2
    exit 1
  fi
}

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
echo "Downloading Chiron ($asset)…"
curl -fsSL "$base/$asset" -o "$work/$asset"
curl -fsSL "$base/checksums.txt" -o "$work/checksums.txt"
curl -fsSL "$base/checksums.txt.sig" -o "$work/checksums.txt.sig"

if ! verify_signature; then
  echo "The release's checksums aren't signed by Mad Science; not installing it." >&2
  exit 1
fi
expected="$(awk -v name="$asset" '$2 == name || $2 == "*"name { print $1 }' "$work/checksums.txt")"
actual="$(sha_hex 256 "$work/$asset")"
if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
  echo "The download doesn't match the release's checksum; not installing it." >&2
  exit 1
fi

chmod 755 "$work/$asset"
"$work/$asset" install
echo
echo "Installed. Next: add the Claude Code plugin (see docs/setup.md), then start a new Claude Code session."
