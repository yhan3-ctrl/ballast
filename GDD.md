# Ballast — Game Design Document

**Creator:** Yu Han (CSCI 5999B)
**Engine:** Godot 4.7.2 stable, 2D Compatibility renderer
**Theme:** Underwater
**Status:** Local release candidate; no public repository or release has been published.

## Concept, genre and background

Ballast is a short, single-player underwater traversal and resource-management game. The player is Yuun the Jadefin, a small jade-coloured lantern fish travelling through reef, kelp and trench environments. The name starts with Yu and ends with Han's n, with a doubled u echoing the creator's handle hnuu. The jade/fish association connects 玉 and 鱼.

Each chapter contains three clearly drawn baby fish. Touching one rescues it automatically, restores up to 25 air once, and makes it follow Yuun. Bring all three to the visible golden house to finish. Followers use the player's recorded trail and have two health points. Coral, hostile Glimmer charges and anemone pulses remove one health, followed by two seconds of immunity. Zero health sends the family to the current anchor with restored health; rescue rewards cannot be collected again. Rescue progress survives checkpoint retries but resets on a fresh chapter attempt.

## What the game teaches

The main skill is allocating limited air between movement, illumination and optional rewards. Players learn to glide with currents, steer around coral, use light selectively around Glimmer, and decide when a pearl detour is worth its air cost. Movement is a simplified force-and-drag model, not a simulation of real buoyancy.

The Reef introduces the controls and environmental rules, including a safe optional light-response example. The Kelp Drift applies the same rules to upper/lower route choices. The Trench combines constrained passages, changes in depth and a final upward current. Luring is available as a tactic; the current geometry does not prove every passage requires it. The intended learning and 5–10 minute first-play duration must still be checked with a new human player.

## Controls and chapter flow

| Input | Action |
|---|---|
| W / S | Upward / downward thrust |
| A / D | Horizontal thrust |
| Space | Lantern toggle |
| R | Retry from the active anchor; unbanked rewards are lost |
| Escape | Pause / resume; return from an introduction to the map |
| Q while paused | Return to the map |
| M / N | Toggle music / effects |
| F1 | Developer diagnostics |
| Mouse | Choose chapters and introduction/result buttons |

The map initially unlocks only chapter 1. Finishing a chapter unlocks the next. Selecting an unlocked chapter opens its objective and two short tips. Start Challenge starts the attempt. Completion stops play and opens results with Map, Play Again and, when applicable, Next Chapter. Next Chapter opens its introduction first. Completed chapters remain replayable.

Chapter time is hidden in normal play. Results and F1 show it. Time includes checkpoint retries, but excludes pause, map, introduction and results. Starting a whole chapter resets its score, pearls, retry count and time. Time gives no score and imposes no deadline. Personal best times appear on the map only after completion. Unlocks/best times persist in game-local save data; test dives cannot unlock campaign progress. Source saves are excluded from version control and exports.

## Mechanics and rules

### Air and movement

Air begins at 100, never exceeds 100, and reaching zero begins a 1.5-second death sequence before respawn. Baseline drain is 0.5 air/second. Horizontal thrust adds 2.2, upward thrust 4, downward thrust 3, and a lit lantern 1.3. W and S together cancel vertical thrust but both costs are charged. Opposing PUSH/RIP currents doubles thrust cost, not baseline or lantern cost. Diagonal inputs apply both components and their respective costs. Drag is 3.5, thrust 470 with a small sustained-input boost; speed is capped at 235 px/second.

DRIFT carries the player, PUSH resists opposing movement, and RIP enforces at least 45 px/second along its direction while within its region. Currents remain visible without light. Walls are solid. Releasing movement saves thrust expenditure; it does not stop baseline air drain.

### Vents, anchors and retry

Each vent adds 40 air once. Full-air contact does not consume it; overflow is discarded. A used vent resets when the player retries its segment. Re-entering a vent while air is below maximum is required after a full-air contact; remaining stationary on it is not a refill loop.

Only a previously inactive forward anchor activates. Activation banks pending rewards, awards the remaining-air bonus, saves a spawn point and refills air. Re-crossing an activated anchor cannot refill air or score again. Each level exit settles rewards once using the same formula. Death or R restores full air, position and current-segment vents/creatures; pending pearls return to the room. Already banked pearls/points persist within the current chapter attempt. Retry count includes manual R. Dying players cannot collect vents/pearls or activate anchors/exits.

### Light, Glimmer and coral

The lantern illuminates nearby geometry and attracts hostile Glimmer to Yuun. It grants no protection to Yuun or babies. Rock outlines, current arrows and hostile warning lines remain visible in darkness. Use light to bait a charge away from followers, then move off the marked line.

Hostile Glimmer patrols/returns at 85 px/second. It prioritizes a lit player within 220 px; otherwise a rescued baby within 160 px or a nearby player within 100 px can trigger an attack, with clear wall line of sight required. It locks a wall-clipped line up to 260 px long, stops for 1.2 seconds of visible warning, charges at 330 px/second without retargeting, and rests harmlessly for 1.3 seconds, then must return home before targeting again. Only charging contact deals damage: 30 player air with knockback/grace, or one baby health. Walls stop the charge. Harmless observation Glimmer retains the light-attraction/return demonstration. Integrated rule tests and scripted physics traversal are recorded in BUILD-VERIFICATION.md; human usability remains a separate check.

The mint-coloured Reef observation specimen is harmless. Observing attraction and return can trigger a learning acknowledgement, but no door or completion condition depends on it. The former observation gate was removed after the player could not understand why the exit was blocked.

Stinging coral removes 25 air, pushes the player away, and grants 1.2 seconds of damage immunity. A lethal hit records the coral cause. Respawn grants 0.7 seconds of grace. Low air adds a vignette and heartbeat, never a movement penalty. Death text identifies the cause.

### Pearls and score

Pearls are optional. Each pickup gives pending points: 100 multiplied by a chain capped at x5. Another pickup within 3.5 seconds advances the chain; timeout, banking or retry resets it. Unbanked pearls/points are displayed separately from permanent rewards. The first pickup explicitly explains banking at the next anchor. Death/R removes those pending points and restores those pearls; it does not permit farming pearl points followed by a full-air retry bonus.

New anchors and the exit add `round(remaining_air) × 20` points before refill. The multiplier is provisional: alternate routes need measured air/reward comparisons, not an assumption that every route is balanced. Best chain can include a chain from a failed attempt; it is descriptive and awards no extra points.

## Three chapters

| Chapter | Layout and learning role | Identity |
|---|---|---|
| Reef | Broad slalom, vents, current exercises, coral avoidance, safe optional light observation, three baby rescues | Blue-green, slower original arrangement |
| Kelp Drift | Three islands with different heights/widths; upper pearl detours and lower current-assisted routes near Glimmer | Green, stronger rhythmic original arrangement |
| Trench | Low/high/low wall openings, Glimmer near approach routes, changes of depth and final upward flow to the elevated destination | Violet, fastest original arrangement |

Each chapter has three anchor segments. The map, introduction and result screen separate chapters. Scene text is shortened to landmarks; the observation retains its brief actionable instruction. There is no countdown, combat, random search AI, breakable wall or moving-door system.

## Design schemas

### Information

**Definition:** Decisions depend on what players can perceive and learn. **Implementation:** currents and glowing pearls provide persistent route cues, while illumination improves nearby terrain/creature visibility and simultaneously attracts Glimmer. **Decision:** spend air and risk attention for a better view, or travel using known terrain. **Evidence:** lantern state, light radius, sight checks and chapter layouts implement the tradeoff. Whether new players use it as intended remains a human-playtest hypothesis.

### Uncertainty

**Definition:** Outcomes can be uncertain because knowledge or execution is incomplete. **Implementation:** Glimmer rules are deterministic; the uncertainty is the player's incomplete view and ability to time/control movement under an air budget. Decorative randomness has no gameplay effect. **Decision:** explore an optional route, commit from memory, or take a familiar current. **Evidence:** repeated inputs and known creature rules are learnable; this is not a claim of random enemy behaviour.

### Cybernetic systems

**Definition:** A feedback loop observes state, compares it with a goal and acts to change the state. **Implementation:** player air is observed through the meter and low-air cues; the player compares it with perceived route cost/survival needs, then changes thrust, light or route. The resulting air curve closes the loop. Thresholds alone are not claimed to constitute the complete controller. **Decision:** respond to low air by reducing expenditure or seeking a vent. **Evidence:** drain, HUD warning and refill rules are implemented. Stabilisation depends on a suitable player response; the design does not guarantee a successful recovery and avoids low-air slowdown that would amplify failure.

## Presentation and audio

Yuun has procedural idle/swim/death animation, a lantern and an H-shaped jade marking. Glimmer pulses and moves its tentacles, changes colour when attracted, and displays a brief warning ring. Water particles, kelp silhouettes, fish schools, pickup bursts and movement trails supply motion.

All audio is original procedural synthesis. Three chapter arrangements share a musical theme with differing tempos and rhythmic emphasis. Events distinguish pearls, vents, banking, completion, impact, drowning, return, lantern and heartbeat. Low air and pause reduce music by 8 dB. Per-event cooldowns, voice limits and priority for major cues limit masking. Commercial song recordings are not included. Numerical audio checks do not substitute for a listening pass.

## Iteration evidence

| Implementation commit | Change | Reason |
|---|---|---|
| `022ba4a` | Air budget, Yuun identity, chase speed, coral damage and air scoring | Make route decisions and danger matter |
| `115040b` | Pending pearl banking and retry reset | Fix pearl farming combined with full-air efficiency scoring |
| `ebf46b7` | First-pearl rule hint | Explain the new at-risk reward contract |
| `6edef57` | Wall-aware Glimmer, actual return observation, exit settlement and telemetry | Correct fairness and consistency defects |
| `c73296b` | Map, locks, introductions, results and saved best times | Make chapter boundaries explicit and remove live time pressure |
| `a1f1572` | Varied chapter geometry and original arrangements | Distinguish the three chapters |
| `8735460` | Original event cues and controlled mixing | Differentiate consequences without audio clutter |

The current final-pass commit is recorded in `docs/FINAL-REVIEW.md`. These are local implementation/design-review iterations, not fabricated human playtests or GitHub pushes. `PLAYTEST.md` distinguishes automated checks from human observations.

## Verification and submission status

Rule regressions cover economy, banking/retry integrity, Glimmer wall interactions, observation completion, pause, chapter locks, timing and save/load. Static route checks include the player's clearance to anchors, vents and exits including all three baby locations. They do not prove difficulty, fun, dynamic puzzle success or duration.

Remaining acceptance evidence: an unfamiliar player's complete three-chapter run with timing/confusion/death notes, audible/visual review, and actual Windows/Linux launches. Public GitHub repository/release and Blackboard submission remain unperformed because only local work has been authorised. The instructor collaborator invitation is recommended in the assignment, not mandatory. Builds and their exact verification status are listed in `docs/BUILD-VERIFICATION.md`.


## Rescue redesign — 2026-09-24
Direct player feedback: the exit was unclear, the old egg symbol was not recognizable, and traversal felt purposeless. The revised objective is explicit on the introduction and HUD: touch three baby fish and bring them to the golden house. An English introduction explains contact rescue; no new action key is required. The HUD shows rescued count and a direction arrow to the next missing baby, or home when all are found. The arrow is a direction hint, not a collision-free navigation path.

Rescue requires proximity within 48 px and clear wall line of sight. Dead, paused or respawning players cannot rescue. Each baby awards up to 25 air only once per attempt, reports the actual gain and emits a celebratory cue. Rescued babies remain safe through retries; optional pearl banking still follows its existing risk rules. At home, fewer than three babies cannot complete the chapter; all three trigger settlement once, without any observation prerequisite. Existing chapter unlocks remain; old speed records are preserved separately and are not shown as rescue-mode records.

Hands-off motion with a current now produces a brighter wake, a visible ring, a short sound and a live drain indicator. It does not secretly increase force or award free air: the positive feedback makes the existing reduced thrust expenditure perceptible. Holding thrust removes the glide cue.

Rescue implementation: `3bd180b` (`v0.8.0-rescue`). 74 regression checks, 19 rescue checks and three static route checks passed. These validate implementation boundaries, not subjective fun.


### v0.8.1 rescue clarity follow-up
All player-facing text remains English; Chinese UI text was removed at the creator's explicit request. The direction arrow selects the nearest unrescued baby, and reaching home early explicitly states the missing count. Followers face their direction of movement. 74 regression checks and 21 rescue checks passed; three static route checks passed. Graphical capture still exits at native startup in the current tool environment; no new visual pass is claimed.

### v0.8.2 — obstacle and route readability
Creator feedback requested more weaving and clearer dangers. Added alternating ceiling/floor coral and upper/lower route obstacles, brighter rock outlines, explicit fork labels, and hostile Glimmer spikes, slanted eyes, fangs and an always-visible warning icon. Safe observation creatures retain round eyes. Damage rules are unchanged. Static clearance checks now avoid inflated coral bounds as well as rocks; all three chapters pass. This proves geometric reachability, not air-budget feasibility or human difficulty.

### v0.9.0 — active escort and timed obstacles
Creator feedback: chapter three felt easier than chapter two, followers faced no danger, and light had little purpose. Third-chapter baffles now require repeated depth changes. Pulse anemones run a five-second cycle: 2.5 seconds safe, one second warning, then 1.5 seconds active. A pulse deals 20 player air damage with knockback and a 1.5-second local cooldown, or one baby health (the lantern shield was removed in the subsequent charge revision). Walls block pulses. Retry resets all pulses to their safe phase and restores followers with two seconds of grace. Waiting, steering and light timing replace arbitrary score penalties. Difficulty progression and actual escort enjoyment remain hypotheses pending human play.

### v0.9.1 charge revision — automated verification
Reported friend feedback: light protection was confusing and continuous pursuit felt hard to evade. Removed shielding and introduced a fixed telegraphed attack with 1.2-second warning, 1.3-second rest and mandatory return home before rearming. Followers have shorter trail spacing. Moved the trench refill and kelp pulse to separate essential destinations from active hazards. 126 rule checks, three static routes and three zero-pearl physics traversals passed. All three traversals completed without retries in 403.5 simulated seconds total. This is automated evidence, not an independent human playtest or proof of subjective difficulty. See docs/BUILD-VERIFICATION.md.
