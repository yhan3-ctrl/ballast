# Build Verification — 2026-09-20

Godot version: 4.7.2 stable

| Package | Structure check | Runtime check | SHA-256 |
|---|---|---|---|
| `Ballast-windows-x86_64.zip` | Valid PE32+ x86-64 executable; ZIP test passed | Windows launch pending | `7234fd16d4ec624bb224a2ccdc8c1f910a46dd8e85efb1903fc3293920c63622` |
| `Ballast-windows-x86_32.zip` | Valid PE32 Intel 80386 executable; ZIP test passed | Windows launch pending | `321831aef8cd822d40b5fdb6b06a7f696166706bb40bef682d5cf8f75e34e33d` |
| `Ballast-linux-x86_64.zip` | Valid ELF x86-64 executable; ZIP test passed | Linux launch pending | `371f38428447ee5134af1531cbbaa99355efce3bf0c958001b4d9d93f7087377` |
| `Ballast-macos-universal.zip` | Valid Mach-O universal executable with x86_64 and arm64 slices; ZIP test passed | Exported application launched headlessly into the test room, exit 0 | `29dc85c8cc603882ac4f8e6a86570be5325e7b63d105750125cb9883206965e2` |

Generated packages are stored under `builds/` and intentionally excluded from Git. Export logs are stored under `logs/` and also excluded. These checks establish package integrity; they do not replace human playtesting or destination-system launch tests.
