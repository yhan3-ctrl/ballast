# Ballast Verification and Playtest Log

This file separates automated rule checks from human playtests. Automated checks do not establish clarity, fun, or actual completion time.

## 2026-09-21 - Automated verification, local prototype

- Tester: automated Godot test runner, not a human playtest
- Build: commit `ebf46b7` (`v0.5.1-tutorial`)
- Purpose: verify boundary rules before manual play
- Command: `Godot --headless --path . --script tests/test_runner.gd`
- Result: 48 checks passed, 0 failures

| Check | Status |
|---|---|
| Full-air contact does not consume a vent | Automated |
| A used vent cannot be collected twice | Automated |
| Drowning blocks vent collection | Automated |
| W+S charges both vertical costs | Automated |
| A checkpoint restores air only on first forward activation | Automated |
| A new checkpoint converts pre-refill air into the documented efficiency score | Automated |
| Respawn restores position and full air | Automated |
| Respawn resets current-segment vents | Automated |
| Respawn resets current-segment Glimmer state and position | Automated |
| Test room includes current and Glimmer exercises | Automated |
| Pearl collection increments once and awards the documented base score | Automated |
| At-risk pearls and pending score reset on death or `R` | Automated |
| Reset cannot combine an expensive-route pearl reward with a fresh-air efficiency reward | Automated |
| Banked pearl count and score persist through later death | Automated |
| First pearl displays an explicit anchor-banking tutorial | Automated |
| Original music and pearl event sound load as project resources | Automated |
| Coral removes 25 air, applies one hit, and can cause a clearly attributed drowning | Automated |
| Hostile Glimmer contact causes a clearly attributed drowning | Automated |
| Glimmer chase speed exceeds Yuun's top speed | Automated |
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
- [ ] Enter and exit the rip current repeatedly. Confirm it cannot push Yuun into a wall trap.
- [ ] Light a Glimmer, turn the lantern off, and die near it. Confirm attraction, return, and reset are predictable.
- [ ] Collect several pearls, press `R`, and confirm they return with no permanent score gain.
- [ ] Bank pearls at an anchor, die afterward, and confirm the banked total remains.

## Build verification

The macOS export has been launched from the exported application and reached the test room. Windows and Linux packages were created and structurally checked on macOS; they still require launch tests on their destination operating systems before release.

## Human playtest template

- Date:
- Tester relationship and prior knowledge:
- Build or commit:
- Instructions provided: controls card only
- Observer intervention: none unless the tester is stuck for more than two minutes
- Completion time:
- Time per level:
- Checkpoint, route chosen, and air remaining:
- Deaths and causes: drowning / Glimmer / coral
- First moment of confusion:
- Response to low-air warning:
- Route chosen and why:
- Did the tester turn off the lantern to escape a Glimmer without prompting?:
- Did the tester explain `AT RISK` correctly without prompting?:
- Glimmer behavior: interesting / predictable / reset reliable:
- Post-play answer — most fun moment:
- Post-play answer — most frustrating moment:
- Rule-breaking result:
- Changes made afterward and matching commit:


## 2026-09-22 — automated fairness regression (not a human playtest)

Added physics-server checks for blocked sight, blocked Glimmer motion, delayed observation completion, non-overlapping creature homes, consistent and non-repeatable exit rewards, pre-refill telemetry, final chapter timing and focus-loss pause. Original economy/restart checks remain. See `logs/improvements-test.log` for results.

For an actual outside playtest, record route choice alongside each `BALLAST_TELEMETRY` arrival/retry from Godot Output. F1 now retains the last arrival's air and duration. Do not use this automated run as a tester entry. Music/effects are independently toggled with M/N. Check that the mint observation creature can be attracted and watched returning; quick tapping must not unlock the gate.
