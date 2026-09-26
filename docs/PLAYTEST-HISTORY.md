# Playtesting record — provenance clarification

On 2026-09-25 Yu Han clarified that the earlier gameplay comments relayed in this conversation came from friends playing the game. Earlier entries that label these observations “creator feedback” describe the messenger incorrectly: classify them as **external friend playtesting, reported by Yu Han**. Yu Han identified the friend testers as Haopeng Chen, Roucheng Ou and Xuemeng Hu. Feedback is recorded as a group because individual attribution was not supplied. The observations below are qualitative; build hashes, session dates, completion times and death counts were not recorded. Automated tests remain a different evidence category.

| Reported friend observation | Resulting revision | Evidence |
|---|---|---|
| Goal/eggs/exit were unclear; play felt like endless swimming | Visible baby fish, contact rescue, follow behaviour, house and objective HUD | 3bd180b, a48e143 |
| More weaving needed; rocks/forks and dangerous jellyfish unclear | Alternating coral, persistent wall outlines, hostile visual distinction | a1f742a |
| Third chapter too simple; babies invulnerable; light unhelpful | Trench baffles, follower health, pulse hazards | 64650f5 |
| Light protected babies but not the player; difficult to understand | Removed shield, light now illuminates and baits attacks | f51bf88 |
| Faster continuous pursuit difficult to evade | Stationary warning, committed straight charge, recovery and return | f51bf88 |
| Fully displayed attack trajectory looked unnatural | Local flash, tucked tentacles and gaze replace path graphics | Final revision |
| Latest report: no current issues, overall good | Retain scope; focus on consistency and delivery checks | User report 2026-09-25 |

No numerical human duration is claimed. The 5–10 minute target has automated-route support, but still needs a timed human run. Historical wording below is retained for traceability and superseded by this provenance clarification.

---

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

Result: **61 checks, 0 failures**, implementation `6edef57`. Local macOS exported test room also passed a headless startup smoke check. No human tester or visual/audio pass is claimed.


## 2026-09-23 — chapter flow automated regression
74 checks passed, including locked launches, intro/results clock freeze, retry clock retention, fresh replay statistics, sequential unlock, best-time retention and save/load using an isolated test file. This is not a human playtest. Graphical capture failed at native application startup (exit 134) in this environment; mouse interaction and visual layout still require a graphical pass.


## 2026-09-23 — audio engineering checks
74 rule checks remain passing. All nine regenerated event WAV files are below full-scale peaks and have near-zero first/last samples. These checks do not validate subjective sound quality or the combined audible mix. Headphone/speaker audition remains pending.


## 2026-09-24 — final local revision
Second-chapter island heights and widths now vary; third chapter uses alternating wall openings and an upward finish. Separate original arrangements distinguish chapters. The GDD was rewritten against current code, explicitly removing unimplemented escort claims and separating intended learning from verified outcomes.

Rule suite: 74 checks passed. Static clearance checks: all 3 chapters' anchors, vents and exits reachable using an 18 px clearance grid after the observation gate is open. This does not include air expenditure, creature timing or player comprehension. Graphical editor was readable, but automated Run input did not produce a game window; no successful graphical playthrough is claimed.


## 2026-09-24 — direct creator feedback and rescue redesign
Tester: creator Yu Han, screenshots and comments during play, not an independent outside tester. Reported: could not identify the old egg/exit symbol, did not understand how a chapter completes, and felt they were only swimming while losing resources. No session duration or death count inferred. Response: visible baby fish/contact rescue, a golden home, persistent goal/count/direction, +25-air rescue reward, persistent rescue progress across retries, removal of the observation gate, and stronger glide feedback. New feedback requires a fresh human run; do not mark the usability issue resolved solely from tests.

Rescue regression result: **74 existing checks + 19 rescue checks passed**. Added checks include touch rescue, capped/one-time air reward, pause/death rejection, wall line of sight, retry persistence, home completion and hands-off flow feedback. Three static path checks include all baby locations. Implementation commit: `3bd180b`.


### v0.8.1 rescue clarity follow-up
All player-facing text remains English; Chinese UI text was removed at the creator's explicit request. The direction arrow selects the nearest unrescued baby, and reaching home early explicitly states the missing count. Followers face their direction of movement. 74 regression checks and 21 rescue checks passed; three static route checks passed. Graphical capture still exits at native startup in the current tool environment; no new visual pass is claimed.

### v0.8.2 — creator feedback: obstacles and readability
Yu Han requested more red obstacles for weaving, more threatening jellyfish, and clearer rocks/forks. Added alternating coral and persistent rock outlines; hostile creatures now have distinct spikes/eyes/fangs/warning icons. First placement blocked clearance to a chapter-two baby and was moved before delivery. 74 rule checks, 21 rescue checks and all three coral-avoiding static route checks pass. No new human playthrough or graphical/audio validation is claimed.

### v0.9.0 — creator feedback, not an external playtest
Yu Han reported the third chapter felt easier than the second, too few threats, invulnerable followers and little incentive to use light. Implemented alternating trench baffles, timed anemones, two-hit follower health, lantern protection and follower-seeking Glimmer. 15 new escort checks cover grace, shielding, range, wall occlusion, pause/death rejection, recovery and pulse phases. Existing 95 rule checks and three static routes pass. These tests do not establish air feasibility, complete follower safety, timing difficulty or enjoyment. A fresh human run is required.

## v0.9.1 final automated verification
126 rule checks passed (74 regression, 21 rescue, 12 escort, 8 integrated charge, 8 isolated charge, 3 zero-pearl victory). Three static routes passed, including pulse separation from vents/home.

Scripted physical traversal uses real player physics, air, enemies, follower damage and retries; only pearl collisions are disabled. Steering uses keyboard-equivalent -1/0/1 input, a grid route and a charge-line dodge heuristic. No teleporting, manual refill, invulnerability or disabled enemies in traversal. All three completed with zero pearls and zero retries:

| Chapter | Simulated seconds | Exit air | Retries | Pearls |
|---|---:|---:|---:|---:|
| Reef | 119.55 | 84.19 | 0 | 0 |
| Kelp Drift | 147.18 | 96.75 | 0 | 0 |
| Trench | 136.77 | 55.83 | 0 | 0 |

Total 403.5 seconds. This proves a tested route exists, not human first-play duration, universal route safety or fun. Earlier failed controller runs exposed a pulse/exit overlap, a vent inside a pulse zone and repeated attacks before Glimmer returned home. Those were corrected. Shorter follower spacing and 1.2-second warning improve the available dodge window.

### v0.9.2 — natural attack warning
Creator reported that the fully displayed jellyfish trajectory felt unnatural. Removed the long path line, endpoint circle and DODGE/TIRED labels; replaced them with local flashing, gaze toward the locked direction and tucked tentacles. Timing and fixed-heading attack rules are unchanged. Eight isolated charge checks pass; graphical readability still needs creator confirmation.

## 2026-09-25 — reported current feedback
Yu Han: “目前没有问题，都很好” (“No issues currently; everything is good”). This is user-reported qualitative feedback. Exact tested build, tester identity, three-chapter completion, elapsed time and deaths were not supplied, so none are inferred. Earlier friend feedback about shields/chase readability remains documented separately.
