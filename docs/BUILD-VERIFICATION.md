# Build Verification — 2026-09-20

Godot version: 4.7.2 stable

| Package | Structure check | Runtime check | SHA-256 |
|---|---|---|---|
| `Ballast-windows-x86_64.zip` | Valid PE32+ x86-64 executable; ZIP test passed | Windows launch pending | `5e865d40692844ee9d01118bc90c17d3c46604c60625d242b608631b4c588e0c` |
| `Ballast-windows-x86_32.zip` | Valid PE32 Intel 80386 executable; ZIP test passed | Windows launch pending | `bf576d57ad9108084b762c2ac4ad4e7036ffaf728934f00f54e9d0f4a59e4e54` |
| `Ballast-linux-x86_64.zip` | Valid ELF x86-64 executable; ZIP test passed | Linux launch pending | `4abe76afb9ce0a7b820c8d3e404ecd405072d614e30fa8c58bb63435de17aedb` |
| `Ballast-macos-universal.zip` | Valid Mach-O universal executable with x86_64 and arm64 slices; ZIP test passed | Exported application launched headlessly into the test room, exit 0 | `b3615c3685933071773e6493c635f86ea41e0375bdcce8ae2c5f460aa6cbfb35` |

Generated packages are stored under `builds/` and intentionally excluded from Git. Export logs are stored under `logs/` and also excluded. These checks establish package integrity; they do not replace human playtesting or destination-system launch tests.
