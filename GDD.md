# Ballast — Game Design Document

**Creator:** Yu Han (CSCI 5999B)
**Engine:** Godot 4.7.2 stable, 2D Compatibility renderer
**Theme:** Underwater
**Version:** 1.0.0 local release candidate. Publication and external acceptance status are recorded in docs/SUBMISSION.md.

## Concept, genre and background

Ballast is a short, single-player underwater traversal and resource-management game. The player is Yuun the Jadefin, a small jade-coloured lantern fish travelling through reef, kelp and trench environments. The name starts with Yu and ends with Han's n, with a doubled u echoing the creator's handle hnuu. The jade/fish association connects 玉 and 鱼.

Each chapter contains three clearly drawn baby fish. Touching one rescues it automatically, restores up to 25 air once, and makes it follow Yuun. Bring all three to the visible golden house to finish. Followers use the player's recorded trail and have two health points. Coral, hostile Glimmer charges and anemone pulses remove one health, followed by two seconds of immunity. Zero health sends the family to the current anchor with restored health; rescue rewards cannot be collected again. Rescue progress survives checkpoint retries but resets on a fresh chapter attempt.


### Background and implemented setting

A surge has scattered young fish across the reef, kelp channels and deep trench. Yuun is a lantern-bearing jade fish guiding them back to the illuminated shelters. Each dive rescues a different group of three; the campaign therefore ends with three completed rescues of three babies. The gold houses are destinations, anchors mark recovery points, vents restore the limited breath resource, and pearls are optional treasures that tempt detours away from rescue routes. Glimmer is a territorial sea creature, not a villain the player must kill. Yuun survives through movement, timing and diversion rather than combat.

The map and first introduction state the surge/rescue premise. Three visual palettes, distinct original musical arrangements, visible followers and houses implement the setting. There is no promised cutscene, inventory, boss fight or branching story. Air is an intentionally simplified game resource rather than a biological claim about real fish. The small H marking and jade colour connect the protagonist to Yu Han without changing the rescue rules.

## What the game teaches

Players also learn to recognize attack preparation, dodge a committed charge and escort vulnerable followers. The main skill is allocating limited air between movement, illumination and optional rewards. Players learn to glide with currents, steer around coral, use light selectively around Glimmer, and decide when a pearl detour is worth its air cost. Movement is a simplified force-and-drag model, not a simulation of real buoyancy.

The Reef introduces the controls and environmental rules, including a an open-space Glimmer charge encounter. The Kelp Drift applies the same rules to upper/lower route choices. The Trench combines constrained passages, changes in depth and a final upward current. Luring is available as a tactic; the current geometry does not prove every passage requires it. The intended learning and 5–10 minute first-play duration must still be checked with a new human player.

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

The lantern illuminates nearby geometry and attracts hostile Glimmer to Yuun. It grants no protection to Yuun or babies. Rock outlines, current arrows and hostile warning glows remain visible in darkness. Use light to bait a charge away from followers, then move out of its facing direction when it flashes.

Hostile Glimmer patrols/returns at 85 px/second. It prioritizes a lit player within 220 px; otherwise a rescued baby within 160 px or a nearby player within 100 px can trigger an attack, with clear wall line of sight required. It locks a wall-clipped line up to 260 px long, stops for 1.2 seconds of flashing and tucked-tentacle warning, charges at 330 px/second without retargeting, and rests harmlessly for 1.3 seconds, then must return home before targeting again. Only charging contact deals damage: 30 player air with knockback/grace, or one baby health. Walls stop the charge. Harmless observation Glimmer retains the light-attraction/return demonstration. Integrated rule tests and scripted physics traversal are recorded in BUILD-VERIFICATION.md; human usability remains a separate check.

The Reef now includes the same hostile charge rule used in later chapters, preceded by a short landmark hint. Its open encounter gives room to practice luring and dodging before the island routes and trench gates. The separate optional test room retains a harmless light-response specimen; it is not the campaign teaching substitute.

Stinging coral removes 25 air, pushes the player away, and grants 0.9 seconds of damage immunity. A lethal hit records the coral cause. Respawn grants 0.7 seconds of grace. Low air adds a vignette and heartbeat, never a movement penalty. Death text identifies the cause.

### Pulses and follower recovery

Anemones repeat a five-second cycle: 2.5 seconds safe (PASS NOW), one second warning (WAIT...), then 1.5 seconds active (PULSE!). Active pulses affect Yuun within 78 px for 20 air and knockback, with a local 1.5-second hit cooldown and normal player hit immunity. A follower within 72 px loses one health if outside its two-second hit grace. Wall line of sight is required. Pause/death stop pulse updates; retry resets pulses to their safe phase. Pulse zones are separated from essential vent/home centers.

Followers follow sampled positions from Yuun's actual trail, with shorter spacing than the earlier escort prototype. Only rescued followers take damage; unrescued babies are not killed while waiting offscreen. Coral contact, charging Glimmer and pulses each remove one of two health points, never more than once per two-second follower grace period. A zero-health follower requests a family retry, not permanent loss. Retry restores both health points and two seconds of grace to rescued followers at the anchor. Reaching a new anchor does not itself heal follower health. Lamp use never blocks damage.

### Pearls and score

Pearls are optional. Each pickup gives pending points: 100 multiplied by a chain capped at x5. Another pickup within 3.5 seconds advances the chain; timeout, banking or retry resets it. Unbanked pearls/points are displayed separately from permanent rewards. The first pickup explicitly explains banking at the next anchor. Death/R removes those pending points and restores those pearls; it does not permit farming pearl points followed by a full-air retry bonus.

New anchors and the exit add `round(remaining_air) × 20` points before refill. The multiplier is provisional: alternate routes need measured air/reward comparisons, not an assumption that every route is balanced. Best chain can include a chain from a failed attempt; it is descriptive and awards no extra points.

## Three chapters

| Chapter | Layout and learning role | Identity |
|---|---|---|
| Reef | Broad slalom, vents, current exercises, coral avoidance, open-space charge practice, three baby rescues | Blue-green, slower original arrangement |
| Kelp Drift | Three islands with different heights/widths; upper pearl detours and lower current-assisted routes near Glimmer | Green, stronger rhythmic original arrangement |
| Trench | Low/high/low wall openings, Glimmer near approach routes, changes of depth and final upward flow to the elevated destination | Violet, fastest original arrangement |

Each chapter has three anchor segments. The map, introduction and result screen separate chapters. Scene text is shortened to landmarks; the observation retains its brief actionable instruction. There is no countdown, combat, random search AI, breakable wall or moving-door system.


### Learning progression by mechanic

| Mechanic / decision | Reef: introduction and use | Kelp Drift: transfer | Trench: combined application |
|---|---|---|---|
| Thrust, air and refill | Swim to babies, use vents and forward anchors | Choose upper/lower routes with different motion costs | Manage depth changes and final ascent |
| Currents and releasing input | Visible DRIFT, PUSH and RIP regions; glide feedback | Use lower currents or pay for upper detours | Combine currents with narrow gates |
| Rescue and escort health | Touch babies; visible health dots; coral/pulse exposure | Carry followers through branching routes and Glimmer | Protect a longer group through constrained passages |
| Light, warning and dodge | Short SPACE/lure hint and an actual hostile Glimmer encounter | Reuse the fixed-charge rule near route choices | Bait/dodge with less lateral space |
| Timed hazards | One pulse anemone with safe/warning/active states | Repeat timing in each segment | Combine timing with vertical navigation |
| Optional pearl banking | First pickup shows the banking rule; anchors settle rewards | Optional upper pearls versus lower current routes | Detours compete with escort and air priorities |

No new player control or hazard rule is introduced only in the final chapter. This is a design mapping, not proof every player will notice or learn every mechanic. Players may skip optional pearls or bypass a threat successfully; human observation is needed to confirm understanding.

## Design schemas

### Information

**Definition:** Decisions depend on what players can perceive and learn. **Implementation:** currents and glowing pearls provide persistent route cues, while illumination improves nearby terrain/creature visibility and simultaneously attracts Glimmer. **Decision:** spend air and risk attention for a better view, or travel using known terrain. **Evidence:** lantern state, light radius, sight checks and chapter layouts implement the tradeoff. Whether new players use it as intended remains a human-playtest hypothesis.

### Uncertainty

**Definition:** Outcomes can be uncertain because knowledge or execution is incomplete. **Implementation:** Glimmer rules are deterministic; the uncertainty is the player's incomplete view and ability to time/control movement under an air budget. Decorative randomness has no gameplay effect. **Decision:** explore an optional route, commit from memory, or take a familiar current. **Evidence:** repeated inputs and known creature rules are learnable; this is not a claim of random enemy behaviour.

### Cybernetic systems

**Definition:** A feedback loop observes state, compares it with a goal and acts to change the state. **Implementation:** player air is observed through the meter and low-air cues; the player compares it with perceived route cost/survival needs, then changes thrust, light or route. The resulting air curve closes the loop. Thresholds alone are not claimed to constitute the complete controller. **Decision:** respond to low air by reducing expenditure or seeking a vent. **Evidence:** drain, HUD warning and refill rules are implemented. Stabilisation depends on a suitable player response; the design does not guarantee a successful recovery and avoids low-air slowdown that would amplify failure.

## Presentation and audio

Yuun has procedural idle/swim/death animation, a lantern and an H-shaped jade marking. Glimmer pulses and moves its tentacles, flashes and contracts its tentacles during charge preparation, and looks toward the locked direction. No future trajectory is drawn. Water particles, kelp silhouettes, fish schools, pickup bursts and movement trails supply motion.

All audio is original procedural synthesis. Three chapter arrangements share a musical theme with differing tempos and rhythmic emphasis. Events distinguish pearls, vents, banking, completion, impact, drowning, return, lantern and heartbeat. Low air and pause reduce music by 8 dB. Per-event cooldowns, voice limits and priority for major cues limit masking. Commercial song recordings are not included. Numerical audio checks do not substitute for a listening pass.

## Iteration evidence and verification

See docs/ITERATIONS.md for real commits, rationale and version mapping, and PLAYTEST.md for friend-playtest reports relayed by Yu Han kept separate from automation. The local Git history preserves the actual iterations; no pushes or outside tests are claimed until performed.

The automated checks validate rule boundaries, physics routes and zero-pearl feasibility. They do not establish enjoyment, human first-play duration, or native Windows/Linux compatibility. See docs/BUILD-VERIFICATION.md for final build hashes and verified results. Outstanding submission actions are explicitly listed in docs/SUBMISSION.md.

## Playtest-driven changes
Yu Han clarified that the earlier gameplay observations came from friends playing the game. Reported problems with the unclear goal, route readability, third-chapter simplicity, confusing shields and continuous pursuit drove the rescue redesign, clearer geometry, vulnerable escort, fixed charges and local attack warnings. The latest reported feedback is positive with no current issues. The reported testers are Haopeng Chen, Roucheng Ou and Xuemeng Hu. Individual comment attribution, exact tested builds, timings and death counts were not recorded; no numerical human session is invented. PLAYTEST.md maps the qualitative observations to real implementation commits.
