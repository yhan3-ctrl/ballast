# Build Verification — 2026-09-20

Godot version: 4.7.2 stable

| Package | Structure check | Runtime check | SHA-256 |
|---|---|---|---|
| `Ballast-windows-x86_64.zip` | Valid PE32+ x86-64 executable; ZIP test passed | Windows launch pending | `9258ebfb2d5503709e31b8d2e64cb07a863962ff45406a2d49b19f81b6eb3b10` |
| `Ballast-windows-x86_32.zip` | Valid PE32 Intel 80386 executable; ZIP test passed | Windows launch pending | `a745a33e84cf875654305179af0320c54c6942658896ec730eb07f89113770a9` |
| `Ballast-linux-x86_64.zip` | Valid ELF x86-64 executable; ZIP test passed | Linux launch pending | `608a8fdd3b2ae1c69791fcbbb96850991b974cd2543d2ec9834c5c97af3ac54f` |
| `Ballast-macos-universal.zip` | Valid Mach-O universal executable with x86_64 and arm64 slices; ZIP test passed | Exported application launched headlessly into the test room, exit 0 | `07f55c1f710caf4251a377468b422d5042bba3994608b49493797105b82aac46` |

Generated packages are stored under `builds/` and intentionally excluded from Git. Export logs are stored under `logs/` and also excluded. These checks establish package integrity; they do not replace human playtesting or destination-system launch tests.
