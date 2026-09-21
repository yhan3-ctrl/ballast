# Build Verification — 2026-09-20

Godot version: 4.7.2 stable

| Package | Structure check | Runtime check | SHA-256 |
|---|---|---|---|
| `Ballast-windows-x86_64.zip` | Valid PE32+ x86-64 executable; ZIP test passed | Windows launch pending | `476a863eebc562203eca97fa43dd9e4f0a4966a7d351800c161f29c51997ae2d` |
| `Ballast-windows-x86_32.zip` | Valid PE32 Intel 80386 executable; ZIP test passed | Windows launch pending | `7b37312847dbf16bf8cb8b8cc12ebaac70368a36dcd4be9e1339b578f23daea6` |
| `Ballast-linux-x86_64.zip` | Valid ELF x86-64 executable; ZIP test passed | Linux launch pending | `bdd92666953bb63ad83cfc6e83d414486b3b310b70d72f5185137ac2ba9f9ca8` |
| `Ballast-macos-universal.zip` | Valid Mach-O universal executable with x86_64 and arm64 slices; ZIP test passed | Exported application launched headlessly into the test room, exit 0 | `04f87f686a13180daa9482e0d38a334231f0b076930709425a51f4a5eddabf10` |

Generated packages are stored under `builds/` and intentionally excluded from Git. Export logs are stored under `logs/` and also excluded. These checks establish package integrity; they do not replace human playtesting or destination-system launch tests.
