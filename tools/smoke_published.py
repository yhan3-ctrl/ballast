"""Test actual published packages on native OS runners (not a graphical playtest)."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import urllib.request
import zipfile

asset_name = sys.argv[1]
out = Path('smoke-output').resolve()
out.mkdir(exist_ok=True)
request = urllib.request.Request('https://api.github.com/repos/yhan3-ctrl/ballast/releases/tags/v1.0.0', headers={'User-Agent': 'Ballast-package-check'})
with urllib.request.urlopen(request, timeout=60) as response:
    release = json.load(response)
asset = next(a for a in release['assets'] if a['name'] == asset_name)
archive = out / asset_name
with urllib.request.urlopen(asset['browser_download_url'], timeout=120) as response:
    archive.write_bytes(response.read())
digest = hashlib.sha256(archive.read_bytes()).hexdigest()
assert asset['digest'] == 'sha256:' + digest, 'Published checksum mismatch'
extract = out / 'game'
extract.mkdir(exist_ok=True)
if sys.platform == 'darwin':
    subprocess.run(['ditto', '-x', '-k', str(archive), str(extract)], check=True)
    app = extract / 'Ballast.app'
    subprocess.run(['codesign', '--verify', '--deep', '--strict', str(app)], check=True)
    binary = app / 'Contents/MacOS/Ballast'
else:
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        z.extractall(extract)
    binary = next(extract.rglob('Ballast.exe' if os.name == 'nt' else 'Ballast.x86_64'))
    if os.name != 'nt':
        binary.chmod(binary.stat().st_mode | 0o111)
result = subprocess.run([str(binary), '--headless', '--quit-after', '180', '--log-file', str(out / 'game.log')], cwd=extract, capture_output=True, text=True, timeout=90)
text = result.stdout + result.stderr
(out / 'console.txt').write_text(text, encoding='utf-8')
(out / 'result.json').write_text(json.dumps({'asset': asset_name, 'sha256': digest, 'platform': sys.platform, 'exit_code': result.returncode, 'test': '180-frame native headless startup; no graphical/audio/Gatekeeper acceptance claimed'}, indent=2), encoding='utf-8')
print(text)
assert result.returncode == 0, 'Game process failed'
assert 'SCRIPT ERROR' not in text and 'Parse Error' not in text, 'Godot script error'
print('PASS: native headless startup of published package; graphical playtest still required.')
archive.unlink()
# Upload logs only, not copies of the game binaries.
import shutil
shutil.rmtree(extract)
