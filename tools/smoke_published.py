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
headers = {'User-Agent': 'Ballast-package-check'}
if os.environ.get('GITHUB_TOKEN'):
    headers['Authorization'] = 'Bearer ' + os.environ['GITHUB_TOKEN']
request = urllib.request.Request('https://api.github.com/repos/yhan3-ctrl/ballast/releases/tags/v1.0.0', headers=headers)
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
harness = Path('tools/smoke_campaign.gd').resolve()
env = dict(os.environ, BALLAST_SMOKE_OUTPUT=str(out))
results = []
for mode in ['headless', 'graphical']:
    command = [str(binary), '--script', str(harness), '--log-file', str(out / (mode + '.log'))]
    if mode == 'headless':
        command.append('--headless')
    elif sys.platform.startswith('linux'):
        command = ['xvfb-run', '-a'] + command
        env['LIBGL_ALWAYS_SOFTWARE'] = '1'
    try:
        process = subprocess.run(command, cwd=extract, env=env, capture_output=True, text=True, timeout=90)
        text = process.stdout + process.stderr
        if (out / (mode + '.log')).exists():
            text += (out / (mode + '.log')).read_text(encoding='utf-8', errors='replace')
        passed = process.returncode == 0 and all('CAMPAIGN_SMOKE_PASS level=' + str(n) in text for n in [1, 2, 3]) and 'SCRIPT ERROR' not in text and 'Parse Error' not in text
        results.append({'mode': mode, 'exit_code': process.returncode, 'passed': passed})
    except subprocess.TimeoutExpired as error:
        text = 'TIMEOUT: ' + str(error)
        results.append({'mode': mode, 'passed': False, 'error': 'timeout'})
    (out / (mode + '-console.txt')).write_text(text, encoding='utf-8')
    print(mode, results[-1])
    print(text[-5000:])
(out / 'result.json').write_text(json.dumps({'asset': asset_name, 'sha256': digest, 'platform': sys.platform, 'results': results, 'limits': 'Three-level initialization/physics/rendering smoke test, not full playthrough, audio listening or downloaded-app security acceptance.'}, indent=2), encoding='utf-8')
archive.unlink()
import shutil
shutil.rmtree(extract)
assert results[0]['passed'], 'Native campaign startup failed'
if sys.platform.startswith('linux'):
    assert results[1]['passed'], 'Linux virtual-display rendering failed'
print('Native campaign startup passed; see separate graphical result and limits.')
