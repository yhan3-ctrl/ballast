# Build Verification — 2026-09-20

Godot version: 4.7.2 stable

| Package | Structure check | Runtime check | SHA-256 |
|---|---|---|---|
| `Ballast-windows-x86_64.zip` | Valid PE32+ x86-64 executable; ZIP test passed | Windows launch pending | `d69286f4236054caf608416cc59ebe7f38e0d700bf98fac51c961af6e3cc5bfc` |
| `Ballast-windows-x86_32.zip` | Valid PE32 Intel 80386 executable; ZIP test passed | Windows launch pending | `e81010a437fc2061bdfb270f4543bef89d7b087f8ac5cfe24178fd72de13b8d9` |
| `Ballast-linux-x86_64.zip` | Valid ELF x86-64 executable; ZIP test passed | Linux launch pending | `caa991578d9731a97e69a66bde132a1b7d84be809d472cba1d4e0799dd5cb0d2` |
| `Ballast-macos-universal.zip` | Valid Mach-O universal executable with x86_64 and arm64 slices; ZIP test passed | Exported application launched headlessly into the test room, exit 0 | `814111a41e9a1029fbf3c3439ff455f00e99ddabe93f61310d2e2571f0dccc77` |

Generated packages are stored under `builds/` and intentionally excluded from Git. Export logs are stored under `logs/` and also excluded. These checks establish package integrity; they do not replace human playtesting or destination-system launch tests.
