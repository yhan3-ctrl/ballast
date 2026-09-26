# Final local build verification — 1.0.0

Godot 4.7.2 stable, 2D Compatibility renderer. All four release exports completed and archive CRC checks passed. Packaged macOS binary passed a 120-frame headless startup check. This is not a graphical/audio acceptance test. Windows/Linux native launch and the instructor's hardware remain unverified.

## Tests

126 rule checks passed: 74 regression, 21 rescue, 12 escort, 8 integrated charge, 8 isolated charge and 3 zero-pearl victory-condition checks. Three static route checks passed, including separation of active pulse centers from vents/home.

Three scripted physical traversals passed with actual air, collisions, active enemies, follower damage and checkpoint rules. Only pearl pickup collisions were disabled. No teleport, manual refill or invulnerability was used. The test steers with keyboard-equivalent inputs and internal map/attack knowledge; it is not a human playtest or proof that visual teaching is understood.

| Chapter | Simulated duration | Retries | Pearls |
|---|---:|---:|---:|
| Reef, including hostile charge encounter | 119.23 s | 0 | 0 |
| Kelp Drift | 147.18 s | 0 | 0 |
| Trench | 136.77 s | 0 | 0 |

Total 403.18 simulated seconds, approximately 6:43. This supports zero-pearl feasibility and a substantial route, not a measured human first-play duration. Friend feedback and subsequently supplied human timings (6/5/8 minutes, 3/0/6 deaths or retries) are documented in PLAYTEST.md.

## Final archives

| Archive | SHA-256 |
|---|---|
| builds/v1.0.0/Ballast-windows-x86_64.zip | 53a909311bf749f53998c83e5ac752d7c54caaefb8706ed0e75ee21c86e387ea |
| builds/v1.0.0/Ballast-windows-x86_32.zip | a76abf3c5e710c94341a7744dd06ed82d00749807dd81b06c615f15266009ab3 |
| builds/v1.0.0/Ballast-linux-x86_64.zip | c2927d3778c4250d79efe6fea14b2946b566c2f83c6ceca6847663ac66caea05 |
| builds/v1.0.0/macos/Ballast-macos-universal.zip | f6c3799f7cdff90575306fe96c0c3a52ae83766b3993b58dacd6faeb0ff1d440 |
