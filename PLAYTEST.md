# Ballast Verification and Playtest Log

This file separates automated rule checks from human playtests. Automated checks do not establish clarity, fun, or actual completion time.

## 2026-09-20 - Automated verification, local prototype

- Tester: automated Godot test runner, not a human playtest
- Build: local working tree
- Purpose: verify boundary rules before manual play
- Command: `Godot --headless --path . --script tests/test_runner.gd`

| Check | Status |
|---|---|
| Full-air contact does not consume a vent | Automated |
| A used vent cannot be collected twice | Automated |
| Drowning blocks vent collection | Automated |
| W+S charges both vertical costs | Automated |
| A checkpoint restores air only on first forward activation | Automated |
| Respawn restores position and full air | Automated |
| Respawn resets current-segment vents | Automated |
| Respawn resets current-segment Glimmer state and position | Automated |
| Test room includes current and Glimmer exercises | Automated |
| Pause freezes the scene tree and run timer | Automated; manual motion check pending |
| Rip current cannot be overcome head-on | Automated; geometry escape check pending |
| Test room can be completed from entrance to eggs | Manual test pending |
| Movement feels controllable | Human playtest pending |
| Air changes are understandable without explanation | External human playtest pending |

## Manual rule-breaking pass

Record an observed result for every item; do not turn expectations into findings.

- [ ] Hold W and S together. Confirm net vertical thrust is neutral while both costs apply.
- [ ] Touch a vent at full air, spend air, then return. Confirm it remained available.
- [ ] Touch a vent during the drowning animation. Confirm respawn still occurs.
- [ ] Re-enter an activated checkpoint. Confirm it does not refill air.
- [ ] Pause inside a current. Confirm timer and movement stop.
- [ ] Die after consuming a vent. Confirm the current segment resets.
- [ ] Enter and exit the rip current repeatedly. Confirm it cannot push Lumen into a wall trap.
- [ ] Light a Glimmer, turn the lantern off, and die near it. Confirm attraction, return, and reset are predictable.

## Build verification

The macOS export has been launched from the exported application and reached the test room. Windows and Linux packages were created and structurally checked on macOS; they still require launch tests on their destination operating systems before release.

## Human playtest template

- Date:
- Tester relationship and prior knowledge:
- Build or commit:
- Instructions provided: controls card only
- Completion time:
- Deaths by checkpoint:
- First moment of confusion:
- Response to low-air warning:
- Route chosen and why:
- Glimmer behavior: interesting / predictable / reset reliable:
- Rule-breaking result:
- Changes made afterward and matching commit:
