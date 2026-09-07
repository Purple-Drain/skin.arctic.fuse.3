#!/usr/bin/env python3
"""Build a Kodi-repository layout for this skin fork into dist/ (gitignored).

This repository root IS the add-on directory (addon.xml lives at the top), so the
zip is built from the root with repo-only files left out. Output mirrors what
TheRedWizard's tools/build-repo.sh produces for Redlight, so the same gh-pages
publishing step serves it:

  dist/addons.xml
  dist/addons.xml.md5
  dist/skin.arctic.fuse.3/skin.arctic.fuse.3-<version>.zip   (top-level dir inside)
  dist/skin.arctic.fuse.3/icon.png, fanart.jpg

Usage: python3 tools/build-repo.py            (run from anywhere)
See Purple-Drain/skin.arctic.fuse.3#31.
"""
import hashlib
import os
import re
import shutil
import sys
import xml.etree.ElementTree as ET
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'dist')
SKIP_DIRS = {'.git', '.github', '.claude', 'tools', 'dist', '__pycache__', 'android-favourites'}
SKIP_FILES = {'CLAUDE.md', '.gitattributes', '.gitignore', '.DS_Store', 'Thumbs.db'}
SKIP_SUFFIXES = ('.pyc', '.pyo', '.xcf', '~', '.sublime-snippet', '.sublime-project', '.sublime-workspace')
# Files Kodi generates at runtime; upstream gitignores them and a clone never has them,
# but keep the guard so a local build from a used skin dir stays clean.
SKIP_PATTERNS = (re.compile(r'^1080i/script-skinvariables-generator-includes.*\.xml$'),
                 re.compile(r'^1080i/script-skinvariables-skinusers\.xml$'),
                 re.compile(r'^1080i/script-skinshortcuts-includes\.xml$'))


def main():
    root_el = ET.parse(os.path.join(ROOT, 'addon.xml')).getroot()
    addon_id, version = root_el.get('id'), root_el.get('version')
    if not addon_id or not version:
        sys.exit('addon.xml has no id/version on the <addon> element')
    shutil.rmtree(OUT, ignore_errors=True)
    out_dir = os.path.join(OUT, addon_id)
    os.makedirs(out_dir)
    zip_path = os.path.join(out_dir, '%s-%s.zip' % (addon_id, version))
    count = 0
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as z:
        for cur, dirs, files in os.walk(ROOT):
            dirs[:] = sorted(d for d in dirs if d not in SKIP_DIRS)
            for f in sorted(files):
                if f in SKIP_FILES or f.endswith(SKIP_SUFFIXES):
                    continue
                full = os.path.join(cur, f)
                rel = os.path.relpath(full, ROOT).replace(os.sep, '/')
                if any(p.match(rel) for p in SKIP_PATTERNS):
                    continue
                z.write(full, addon_id + '/' + rel)
                count += 1
    for art in ('icon.png', 'fanart.jpg'):
        if os.path.isfile(os.path.join(ROOT, art)):
            shutil.copy(os.path.join(ROOT, art), os.path.join(out_dir, art))
    manifest = open(os.path.join(ROOT, 'addon.xml'), encoding='utf-8').read()
    manifest = re.sub(r'^\s*<\?xml[^>]*\?>\s*', '', manifest).rstrip()
    body = '\n'.join(('\t' + l if l.strip() else l) for l in manifest.splitlines())
    addons_xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n<addons>\n%s\n</addons>\n' % body
    ET.fromstring(addons_xml.encode('utf-8'))  # fail loudly on a malformed index
    with open(os.path.join(OUT, 'addons.xml'), 'w', encoding='utf-8') as fh:
        fh.write(addons_xml)
    with open(os.path.join(OUT, 'addons.xml.md5'), 'w') as fh:
        fh.write(hashlib.md5(addons_xml.encode('utf-8')).hexdigest())
    print('built %s (%d files, %.1f MB)' % (os.path.relpath(zip_path, ROOT), count, os.path.getsize(zip_path) / 1e6))


if __name__ == '__main__':
    main()
