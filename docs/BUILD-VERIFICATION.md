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
| builds/v1.0.0/macos/Ballast-macos-universal.zip | eac806cf726a8aaf3f34fcdf29bef2d8d828e2b0ce515b1d5a2da8c5b6464483 |

## macOS packaging repair, 2026-09-26

The original exported app retained an invalid template signature. The macOS archive was replaced with an ad-hoc signed package. Strict codesign verification passes after fresh extraction in a local temporary directory, and the repaired app opened its graphical chapter introduction. This is not Apple notarization or a complete graphical/audio playthrough. Cloud-backed project folders were observed to add FinderInfo metadata that interferes with signature checks; signing and verification are performed outside them. Windows/Linux packages are unchanged.

## Native published-package startup tests, 2026-09-26

Run: https://github.com/yhan3-ctrl/ballast/actions/runs/36251759276

Actual Release archives were downloaded and their SHA-256 digests verified. Windows x86_64, Windows x86_32 (on 64-bit Windows), and Linux x86_64 passed both 180-frame headless and graphical startup. Linux rendering used Xvfb and software OpenGL. macOS ARM64 passed strict package signature verification and headless startup, but graphical startup crashed in the hosted Apple virtual GPU / ANGLE driver. The overall workflow is green because macOS graphical startup is recorded but not a required gate; it must not be described as all graphical checks passing. The same repaired Mac package previously displayed its introduction locally.

These checks do not verify complete playthroughs, audible output, native 32-bit Windows, Intel Mac execution, or browser-download Gatekeeper/SmartScreen acceptance. Individual machine-readable results are in platform-checks/. Earlier failed runs include a shared API rate limit and an unsupported external-script test method; their failures are not erased.
