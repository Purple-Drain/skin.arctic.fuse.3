#!/usr/bin/env bash
# Copy the Shield's own generated include into the repo before a release, so a skin update
# lands with it in place and script.skinvariables has nothing to rebuild (#67).
#
# Why the device's copy: script.skinvariables rebuilds when
#   make_hash(template contents + profile + "--" + current file content) != Skin.String(<hash>)
# (shortcuts/template.py, update_xml), so only a byte-identical copy of what this device last
# generated skips the rebuild. A generic default would always mismatch and rebuild anyway.
#
# Read-only on the device (adb pull and md5sum only). Refuses when this checkout's generator
# inputs (shortcuts/generator/** and shortcuts/skinvariables-generator.json) differ from the
# skin installed on the device: such a release has to rebuild anyway, and the shipped file
# would just be stale. A stale shipped file is still safe (hash mismatch, one rebuild, as
# before this change).
#
# Usage: tools/refresh-generated-include.sh [device]   (default 10.1.1.30:5555)
# Then commit 1080i/script-skinvariables-generator-includes-.xml with the release.
set -euo pipefail
DEV="${1:-10.1.1.30:5555}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKIN=/sdcard/Android/data/org.xbmc.kodi/files/.kodi/addons/skin.arctic.fuse.3
FILE=1080i/script-skinvariables-generator-includes-.xml

adb connect "$DEV" >/dev/null 2>&1 || true
adb -s "$DEV" get-state >/dev/null 2>&1 || { echo "device $DEV not reachable"; exit 1; }

# generator inputs: repo vs device
cd "$ROOT"
inputs=$(git ls-files shortcuts/generator shortcuts/skinvariables-generator.json)
local_sum=$(for f in $inputs; do printf '%s  %s\n' "$(md5sum "$f" | cut -d' ' -f1)" "$f"; done)
dev_sum=$(adb -s "$DEV" shell "cd $SKIN && md5sum $(echo $inputs | tr '\n' ' ')" 2>/dev/null | tr -d '\r' | sed 's#  \./#  #')
if [ "$local_sum" != "$dev_sum" ]; then
  echo "generator inputs differ from the skin on the device; this release rebuilds anyway, not refreshing:"
  diff <(echo "$local_sum") <(echo "$dev_sum") | head -20
  exit 2
fi

tmp=$(mktemp)
adb -s "$DEV" pull "$SKIN/$FILE" "$tmp" >/dev/null
[ -s "$tmp" ] || { echo "device has no $FILE (not built yet?)"; rm -f "$tmp"; exit 3; }
python3 -c "import sys,xml.dom.minidom;xml.dom.minidom.parse(sys.argv[1])" "$tmp" || { echo "pulled file is not valid XML"; rm -f "$tmp"; exit 4; }
mv "$tmp" "$ROOT/$FILE"
echo "refreshed $FILE ($(wc -c < "$ROOT/$FILE") bytes) from $DEV"
git -C "$ROOT" status --short -- "$FILE"
