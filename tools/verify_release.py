"""Build and verify local v1.0.0 archives; never publishes or uploads."""
from pathlib import Path
import subprocess, zipfile, hashlib, json
ROOT = Path(__file__).resolve().parents[1]
GODOT = '/Applications/Godot.app/Contents/MacOS/Godot'
OUT = ROOT / 'builds/v1.0.0'
OUT.mkdir(parents=True, exist_ok=True)
results = []
for preset, folder, name in [('Windows x86_64','windows-x86_64','Ballast.exe'),('Windows x86_32','windows-x86_32','Ballast.exe'),('Linux x86_64','linux-x86_64','Ballast.x86_64'),('macOS Universal','macos','Ballast-macos-universal.zip')]:
    target = OUT / folder / name
    target.parent.mkdir(parents=True, exist_ok=True)
    p = subprocess.run([GODOT,'--headless','--path',str(ROOT),'--log-file',str(ROOT/'logs'/f'final-export-{folder}.log'),'--export-release',preset,str(target)], capture_output=True,text=True,timeout=180)
    output = p.stdout+p.stderr
    (ROOT/'logs'/f'final-export-{folder}-console.log').write_text(output)
    if p.returncode or 'SCRIPT ERROR' in output: raise RuntimeError(preset+' failed: '+output[-2000:])
    archive = target if folder=='macos' else OUT/f'Ballast-{folder}.zip'
    if folder!='macos':
        with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
            for f in target.parent.iterdir():
                if f.suffix in ['.exe','.pck','.x86_64','.sh','.dll']: z.write(f,f.name)
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        assert len(z.namelist()) > 0
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    results.append({'archive':str(archive.relative_to(ROOT)), 'sha256':digest})
    print(preset, 'export + CRC PASS',flush=True)
(OUT/'SHA256SUMS.txt').write_text(''.join(x['sha256']+'  '+x['archive']+'\n' for x in results))
(OUT/'verification.json').write_text(json.dumps(results,indent=2)+'\n')
