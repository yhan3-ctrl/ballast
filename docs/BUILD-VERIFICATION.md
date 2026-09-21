# Build Verification — 2026-09-20

Godot version: 4.7.2 stable

| Package | Structure check | Runtime check | SHA-256 |
|---|---|---|---|
| `Ballast-windows-x86_64.zip` | Valid PE32+ x86-64 executable; ZIP test passed | Windows launch pending | `ea6a9ed6f2e6c03cf21a5f80b435e258b19dbf9bce65abf1d2b9ec09f5ed345c` |
| `Ballast-windows-x86_32.zip` | Valid PE32 Intel 80386 executable; ZIP test passed | Windows launch pending | `667090a23255419c3daded6f3f69499dba8410a43e16f095a64a411237dfbaec` |
| `Ballast-linux-x86_64.zip` | Valid ELF x86-64 executable; ZIP test passed | Linux launch pending | `9d53dcd02408c42bad8888b47538105deb4ee5de782fe9d77a5347125f61d111` |
| `Ballast-macos-universal.zip` | Valid Mach-O universal executable with x86_64 and arm64 slices; ZIP test passed | Exported application launched headlessly into the test room, exit 0 | `c36fe0817303a772c1db8c22bde7e006e61d7d4e5f33fd8c8d77beeb3ac3ae66` |

Generated packages are stored under `builds/` and intentionally excluded from Git. Export logs are stored under `logs/` and also excluded. These checks establish package integrity; they do not replace human playtesting or destination-system launch tests.
