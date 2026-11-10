#!/usr/bin/env bash
# MODO 설치·업데이트 (맥). 서명 없는 앱의 '확인되지 않은 개발자' 경고 없이 설치한다 (#2)
#   curl -fsSL https://raw.githubusercontent.com/wisdom5565/modo-releases/main/install.sh | bash
# - 받는 곳은 modo-releases의 최신 릴리스뿐이다. 받은 dmg는 릴리스의 SHA256SUMS.txt와 맞춰 보고, 다르면 설치하지 않는다
# - MODO가 켜져 있으면 끈 뒤 /Applications/MODO.app을 바꾼다. 설치 뒤 실행은 하지 않는다
set -euo pipefail

REPO="wisdom5565/modo-releases"
BASE="https://github.com/$REPO/releases"

[ "$(uname -s)" = "Darwin" ] || { echo "맥에서만 쓰는 스크립트예요. 윈도는 install.ps1을 쓰세요." >&2; exit 1; }

# 최신 릴리스 태그는 /releases/latest가 넘겨 주는 주소에서 읽는다 (JSON 도구 없이)
latest=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "$BASE/latest")
tag=${latest##*/tag/}
case "$tag" in v[0-9]*.[0-9]*.[0-9]*) ;; *) echo "최신 버전을 찾지 못했어요 ($latest)" >&2; exit 1 ;; esac
ver=${tag#v}

if [ "$(uname -m)" = "arm64" ]; then dmg="MODO-$ver-arm64.dmg"; else dmg="MODO-$ver.dmg"; fi

tmp=$(mktemp -d)
mnt="$tmp/mnt"
cleanup() { hdiutil detach -quiet "$mnt" 2>/dev/null || true; rm -rf "$tmp"; [ -n "${new:-}" ] && rm -rf "$new"; }
trap cleanup EXIT

echo "MODO $ver 받는 중… ($dmg)"
curl -fsSL -o "$tmp/$dmg" "$BASE/download/$tag/$dmg"
curl -fsSL -o "$tmp/SHA256SUMS.txt" "$BASE/download/$tag/SHA256SUMS.txt"

want=$(awk -v f="$dmg" '$2 == f || $2 == "*"f { print $1 }' "$tmp/SHA256SUMS.txt")
got=$(shasum -a 256 "$tmp/$dmg" | awk '{ print $1 }')
if [ -z "$want" ] || [ "$want" != "$got" ]; then
  echo "받은 파일이 릴리스와 달라서 설치하지 않았어요. 잠시 뒤 다시 해 보거나 릴리스 페이지에서 받아 주세요." >&2
  exit 1
fi

hdiutil attach -nobrowse -quiet -mountpoint "$mnt" "$tmp/$dmg"
[ -d "$mnt/MODO.app" ] || { echo "설치 파일 안에 MODO.app이 없어요." >&2; exit 1; }

# 켜져 있으면 끄고(저장하고 닫힘) 바꾼다
if pgrep -xq MODO; then
  osascript -e 'tell application "MODO" to quit' >/dev/null 2>&1 || true
  for _ in $(seq 20); do pgrep -xq MODO || break; sleep 0.5; done
  if pgrep -xq MODO; then echo "MODO를 끄지 못했어요. 앱을 끈 뒤 다시 실행해 주세요." >&2; exit 1; fi
fi

# 새 앱을 옆에 다 복사한 뒤 옛 앱을 비켜 두고 바꾼다. 실패하면 옛 앱으로 되돌린다
# lib/selfupdate.js swapScript와 같은 순서를 지킨다 (이 파일은 curl | bash로 혼자 돌아서 글로 맞춘다)
app=/Applications/MODO.app
new="/Applications/.MODO-new-$$.app"; old="/Applications/.MODO-old-$$.app"
rm -rf "$new"
if ! ditto "$mnt/MODO.app" "$new"; then rm -rf "$new"; echo "앱을 복사하지 못했어요. 쓰던 MODO는 그대로 있어요." >&2; exit 1; fi
if [ -e "$app" ] && ! mv "$app" "$old"; then rm -rf "$new"; echo "쓰던 MODO를 옮기지 못했어요. 그대로 있어요." >&2; exit 1; fi
if ! mv "$new" "$app"; then [ -e "$old" ] && mv "$old" "$app"; rm -rf "$new"; echo "앱을 바꾸지 못해 쓰던 MODO로 되돌렸어요." >&2; exit 1; fi
rm -rf "$old" || true # 새 앱은 이미 들어갔다. 옛 앱을 못 지워도 설치는 끝낸다
xattr -dr com.apple.quarantine "$app" 2>/dev/null || true

echo "MODO $ver 를 설치했어요. 응용 프로그램에서 MODO를 열어 주세요."
