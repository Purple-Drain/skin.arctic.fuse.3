#!/usr/bin/env bash
#
# build-favourites.sh — generate a Kodi favourites.xml of installed Android apps
# by querying an Android TV / box over adb, then (optionally) push it to Kodi.
#
# Run this on a machine on the SAME network as the device (NOT from a cloud
# Claude session — that sandbox cannot reach your LAN).
#
# Usage:
#   ./build-favourites.sh [DEVICE_IP[:PORT]] [OUTPUT_FILE]
#   ./build-favourites.sh 10.1.1.30                 # writes ./favourites.xml
#   ./build-favourites.sh 10.1.1.30:5555 fav.xml
#
# Then review/rename labels and push (close Kodi first so it doesn't overwrite):
#   adb push favourites.xml \
#     /storage/emulated/0/Android/data/org.xbmc.kodi/files/.kodi/userdata/favourites.xml
#
set -euo pipefail

DEVICE="${1:-10.1.1.30}"
[[ "$DEVICE" == *:* ]] || DEVICE="${DEVICE}:5555"
OUT="${2:-favourites.xml}"

command -v adb >/dev/null || { echo "error: adb not found in PATH" >&2; exit 1; }

echo ">> connecting to $DEVICE ..."
adb connect "$DEVICE" >/dev/null
adb -s "$DEVICE" wait-for-device

echo ">> listing user-installed packages ..."
mapfile -t PKGS < <(adb -s "$DEVICE" shell pm list packages -3 \
  | sed 's/package://' | tr -d '\r' | sort -u)

[[ ${#PKGS[@]} -gt 0 ]] || { echo "no third-party packages found" >&2; exit 1; }

# Friendly labels for common Android TV apps; unknown packages fall back to the
# package name so you can rename them by hand afterwards.
declare -A NAMES=(
  [com.netflix.ninja]="Netflix"
  [com.google.android.youtube.tv]="YouTube"
  [com.google.android.youtube.tvmusic]="YouTube Music"
  [com.amazon.amazonvideo.livingroom]="Prime Video"
  [com.disney.disneyplus]="Disney+"
  [com.wbd.stream]="Max"
  [com.spotify.tv.android]="Spotify"
  [com.plexapp.android]="Plex"
  [org.jellyfin.androidtv]="Jellyfin"
  [tv.twitch.android.app]="Twitch"
  [com.apple.atve.androidtv.appletv]="Apple TV"
  [com.bbc.iplayer.bigscreen]="BBC iPlayer"
  [com.crunchyroll.crunchyroid]="Crunchyroll"
  [com.google.android.apps.youtube.kids]="YouTube Kids"
  [com.amazon.amazonvideo]="Prime Video"
)

echo ">> writing $OUT ..."
{
  echo '<favourites>'
  for p in "${PKGS[@]}"; do
    label="${NAMES[$p]:-$p}"
    printf '  <favourite name="%s">StartAndroidActivity("%s")</favourite>\n' "$label" "$p"
  done
  echo '</favourites>'
} > "$OUT"

echo ">> done. $(grep -c '<favourite ' "$OUT") apps written to $OUT"
echo "   Review labels (unknown ones use the raw package name), then push:"
echo "   adb -s $DEVICE push $OUT /storage/emulated/0/Android/data/org.xbmc.kodi/files/.kodi/userdata/favourites.xml"
echo "   (close Kodi before pushing, then reopen — Kodi rewrites this file on exit)"
