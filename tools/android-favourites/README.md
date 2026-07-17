# Android apps in Arctic Fuse favourites / widgets

Helpers for surfacing installed Android apps inside Arctic Fuse 3, either as a
native widget or as Kodi favourites. Use these on a machine on the **same LAN**
as your device (a cloud Claude session cannot reach a private IP like
`10.1.1.30`).

## Background

Arctic Fuse 3 already exposes installed Android apps natively. In
`shortcuts/skinvariables-shortcut-config.json` the skin defines an
**"Android Add-ons"** source (`androidapp://sources/apps/`, gated by
`System.Platform.Android`). Kodi launches an app via
`StartAndroidActivity("<package>")`.

## Route A — native widget (no adb)

1. Long-press (`C` / context menu) a home widget → **Choose widget**.
2. Path → **Add-ons** → **Android Add-ons** (visible only on Android).
3. The widget lists every installed app; selecting one launches it.

## Route B — favourites of specific apps (uses adb)

1. Enable adb on the device: Settings → Device Preferences → About → tap
   **Build** 7× → Developer options → enable **ADB / Network debugging**.
2. Generate a favourites file:
   ```bash
   ./build-favourites.sh 10.1.1.30
   ```
3. Edit `favourites.xml` — rename any entries that fell back to the raw package
   name, delete apps you don't want.
4. Close Kodi, push, reopen:
   ```bash
   adb -s 10.1.1.30:5555 push favourites.xml \
     /storage/emulated/0/Android/data/org.xbmc.kodi/files/.kodi/userdata/favourites.xml
   ```
   Kodi rewrites `favourites.xml` on exit, so it must be closed when you push.
5. Point a widget at `favourites://` to display them.

`favourites.template.xml` shows the entry format if you'd rather hand-write it.
