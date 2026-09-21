# Ballast: Game Design Document

**CSCI 5999B Project 1 (Graduate Section)** | Yu Han | Fall 2026
Repository: `https://github.com/<your-account>/ballast` | Engine: Godot `4.7.2 stable` | Theme: Underwater

**Document status:** design draft, revision 3 (2026-09-21). Sections marked *Hypothesis* are design intent that has not yet been verified in play. Numeric values marked *placeholder* are starting points for calibration in the first test room, not measured results.

> 中文批注：灰色引用块是给你自己的说明，**提交前整段删除**。本版相对 v1 的改动记在 §12.3，改动理由都是设计评审得出的，不是试玩结果，文档里也照实这么写。

---

## 1. Overview

| Field | Value |
|---|---|
| Title | Ballast |
| Genre | 2D physics puzzle-platformer, single player, level-based |
| Engine | Godot `4.7.2 stable` |
| Platforms | Windows (x86_64), macOS, Linux (x86_64) |
| Players | 1 |
| Target playtime | 6 to 8 minutes, to be confirmed by playtest |
| Levels | 3 (one teaching level, two application levels) |
| Pitch | A deep-sea anglerfish fry whose breath is both its engine and its life bar must descend a trench to recover a scattered clutch of eggs. |

---

## 2. Concept

Ballast is built on one tension: **the resource that keeps you alive is the same resource that moves you**. Yuun controls depth by inflating and deflating a swim bladder, and both directions cost air. Air refills only at vents, and each vent works once. Every metre of travel is therefore a spending decision, and the shortest route is usually not the cheapest one.

Two environmental systems modify that economy: **currents**, which make some directions nearly free and others expensive, and a **lantern**, which reveals obstacles in the dark but draws the attention of a light-sensitive creature.

Deliberate scope decision: the game has three verbs and no unlockable abilities. Difficulty comes from new combinations of known rules, not from new rules.

---

## 3. Background Information

### 3.1 Fiction

Yuun is a newly hatched jade-coloured anglerfish, also called the Jadefin. The name begins with `Yu` to follow creator Yu Han's English name order, takes its final `n` from Han, and keeps the doubled `u` as a visual echo of the creator's handle `hnuu`. It also connects the sounds of 玉 (jade) and 鱼 (fish) to the character's colour and form. A surge along the trench wall has scattered Yuun's siblings' eggs through three depth zones: the sunlit Reef, the mid-water Kelp Drift, and the lightless Trench. Yuun descends to bring them home. Delivered through the environment and one text card per level. No dialogue system.

### 3.2 What the grader needs to know before playing

- Keyboard only. No mouse input.
- The bar at the top left is air. It is fuel and health at the same time.
- Blue particle streams are currents. They are visible at all times, including in the dark.
- The lantern is available from the first second and is never taken away.
- There are no lives. Death returns Yuun to the last checkpoint with full air.
- Pearls are optional and are not required to finish.

### 3.3 Controls

| Input | Action |
|---|---|
| `A` / `D` | Swim left / right |
| `W` (hold) | Inflate: rise |
| `S` (hold) | Deflate: sink |
| `Space` | Toggle lantern |
| `R` | Restart from last checkpoint |
| `Esc` | Pause |

---

## 4. What the Game Teaches

Ballast does not simulate real buoyancy physics. It uses a **simplified underwater movement model** in which vertical motion in either direction costs a shared resource. This is a designed rule, not a physical claim, and the learning it targets is not physics.

**Core learning: route planning under a depleting resource.** The player learns to read a room before spending: which currents are free transport and which are a tax, where the vents are, how much of the route can be done unlit, and whether the short expensive path or the long cheap path fits the air on hand.

**Secondary learning: information has a price.** Lighting the lantern converts unknown terrain into known terrain, but it costs air and it changes how the environment responds. The player learns to buy information deliberately rather than continuously.

**Intended behaviour change by level 3:** the lantern stops being a way to see and becomes a way to move something else. *Hypothesis, to be confirmed by playtest.*

---

## 5. Genre

2D puzzle-platformer with continuous physics-based movement. Single player against a game system. Level-based, checkpointed, optional collectibles, completion timer.

---

## 6. Core Mechanics

### 6.1 Buoyancy and air

`W` applies upward thrust, `S` applies downward thrust. Both accelerate rather than teleport, so inputs must be led. With no input Yuun drifts slightly downward.

| Parameter | Placeholder value |
|---|---|
| Max air | 100 |
| Rise | 4.0 air/sec |
| Sink | 3.0 air/sec |
| Horizontal swim | 2.2 air/sec |
| Lantern lit | 1.3 air/sec |
| Passive drain | 0.5 air/sec |
| Against a current | cost x2 |
| Low-air warning | at 25 |
| Vent refill | +40, single use |

**Calibration target for the test room:** one challenge segment should take 20 to 40 seconds of travel and contain zero to two vents, so that a segment's air budget is `100 + 40n`. If the placeholder costs make segments shorter than that, the costs come down, not the level.

**Low air (below 25)** produces a vignette and a heartbeat audio layer only. It does **not** reduce movement speed. Rationale in §12.3.

**At zero air** Yuun enters a drowning state: control is released, a 1.5 second animation plays, then respawn (see §7.1).

### 6.2 Currents

Directional flow volumes rendered as particle streams. **Always visible, including with the lantern off**, because they are the information the player plans with and hiding them would make planning guesswork rather than judgement.

Three strengths: drift (small assist), push (doubles cost against it), rip (cannot be moved against at all; must be entered and exited deliberately).

### 6.3 Lantern

Toggled, costs air while lit. The current procedural light has an approximately 240 px lit radius and a 60 px unlit aura. It reveals geometry, vents, pearls and the light-sensitive creature. It does **not** reveal currents, which are already visible.

### 6.4 Light-sensitive creature (Glimmer)

One passive creature type, not an enemy AI. Three states:

1. **Drift:** moves slowly along a fixed path inside a bounded area.
2. **Attracted:** while a lit lantern is within `placeholder: 220 px`, moves toward it at a fixed speed.
3. **Return:** when the lantern goes dark or leaves range, returns to the nearest point of its path and resumes drifting.

Contact with Yuun returns Yuun to the last checkpoint. When attracted, a Glimmer moves slightly faster than Yuun's maximum swim speed, so the intended escape is to turn off the lantern rather than outrun it. The creature cannot be killed, blocked or damaged. It has no search behaviour and no randomness.

> 中文批注：这只生物是全局最大的实现风险，所以它被排到第二天验证，而不是最后。验收三条：引诱是否有趣、行为是否可预测、重置是否可靠。任何一条不过关，就把它退化成纯装饰（只在第一关出现供观察），三关改为纯洋流与气量解谜，同时删掉 §9 里依赖它的论据。

### 6.5 Pearl trails and flow chains

Pearls turn traversal into a readable short-term challenge without adding a new control. They are arranged along useful current lines and alternate routes. Collecting another pearl within 3.5 seconds raises the flow chain; a pearl awards `100 × min(chain, 5)` pending points. Pearls and their points remain **at risk** until the next forward checkpoint or level exit banks them. Death or `R` returns every at-risk pearl in the current segment to its original position and clears its pending points. Banked pearls persist. Pearls never change air or movement, so the air economy remains intact while clean movement receives immediate sound, particle and score feedback.

---

## 7. Rules

Structured on the three levels defined in Salen and Zimmerman, *Rules of Play*.

### 7.1 Operational Rules

1. The player controls one character, Yuun, in continuous 2D space.
2. `W` moves Yuun up, `S` moves Yuun down. Both consume air.
3. `A` and `D` move Yuun horizontally and consume air at a lower rate.
4. `Space` toggles the lantern, which consumes air while lit.
5. Air decreases continuously and never regenerates except at a vent or a checkpoint.
6. Touching a vent at less than full air restores up to 40, discards any overflow, and permanently consumes that vent for the current attempt.
7. Touching a vent at full air does nothing and does not consume the vent.
8. Only first activation of a new, forward checkpoint restores full air. Revisiting an activated arch does not refill air or move the active checkpoint backward.
9. On death or on pressing `R`, Yuun returns to the active checkpoint with full air, and every vent and creature in the current segment is reset to its initial state.
10. At zero air, Yuun loses control, drowns over 1.5 seconds, and respawns per rule 9. Air cannot be collected during the drowning animation.
11. Contact with a hostile Glimmer starts Yuun's drowning sequence and then respawns Yuun per rule 9.
12. Currents apply a constant force inside their volume. Rip currents cannot be moved against.
13. A Glimmer drifts on a fixed path, moves toward a lit lantern within range, and returns to its path when the lantern is dark or out of range.
14. A level ends when Yuun reaches the egg nest; the next level loads automatically.
15. Pearls are optional. Pearls collected after the active checkpoint are at risk until the next forward checkpoint or level exit; death or `R` restores those pearls to the room and removes their pending points. Once banked, pearls persist through later deaths.
16. Each pearl creates 100 pending points multiplied by the current flow chain, capped at x5. The chain resets after 3.5 seconds without a pearl or on death. Banking transfers pending pearl points into permanent score. Time, banked pearls, score and best chain are displayed at the end and have no mechanical effect.
17. Red stinging coral removes 25 air and knocks Yuun away. A 0.9-second contact grace period prevents one collision from applying repeatedly. If the damage reaches zero air, the standard drowning and checkpoint reset sequence runs.
18. First activation of a forward checkpoint converts the air remaining before refill into score at a provisional 20 points per whole air unit. This multiplier puts a 30-air route difference near a 600-point pearl detour; F1 measurements must confirm the final value.

### 7.2 Constitutive Rules

The game is a constrained traversal problem on a 2D vector field. The state is:

`S = (position, velocity, air, lantern_on, level_id, checkpoint_id, vents_used, glimmer_states, banked_pearls, pending_pearls, score, pending_score, elapsed_time)`

- Motion is integrated, not set: each frame, `acceleration = player_thrust + field_force + drag`, and `velocity` follows from it. The player never commands a position directly, which is why inputs must be led.
- Air is strictly decreasing except at discrete refill events (vents, checkpoints). A segment is solvable only if some path exists whose integrated cost is below the air available in that segment, so each segment is a bounded-budget path problem.
- Because `vents_used`, `glimmer_states`, `pending_pearls` and `pending_score` reset with the checkpoint, each segment is an independent sub-problem with a fixed initial state. This is what makes repeated attempts comparable, makes the air budget designable, and prevents restart farming from combining both route rewards.
- `lantern_on` appears in both the player's cost function and the Glimmer's transition condition. It is the only variable the player controls that is also an input to the environment's behaviour, which is the formal reason the lantern can be used as a tool and not only as a cost.

### 7.3 Implicit Rules

- The player will not edit project or save files to change air values.
- A reported completion time refers to one continuous session.
- Pausing stops play rather than serving as free observation time; the pause screen blurs the view for this reason.

> 中文批注：v1 版本把"玩家不会赖在补气点刷气"写成隐含规则，那是拿规则分类掩盖经济漏洞。现在补气点一次性，这个漏洞在操作规则层面就关掉了，隐含规则只剩下真正属于游戏之外的假设。

---

## 8. Level Design and Learning Progression

### 8.1 Structure

| Level | Learning task | Target length |
|---|---|---|
| L1 The Reef: understand the cost | Learn buoyancy, with and against current, the lantern, vents, checkpoints. Actively practise the Glimmer's light reaction in a safe enclosure. | ~2 min |
| L2 The Kelp Drift: choose the route | Every segment offers a short expensive path and a longer path that borrows a current. At least one segment must be crossed with the lantern off because a Glimmer patrols it. | ~2.5 min |
| L3 The Trench: change the conditions | Dark by default. Use the lantern to draw a Glimmer off a corridor, go dark, then take the corridor using a current. No new rules are introduced. | ~3 min |

### 8.2 Taught use versus reused use

This table is the design contract for the rubric line "learn in one level, utilize in the next for all abilities."

| Ability | Taught in L1 | Reused in L2 | Recombined in L3 |
|---|---|---|---|
| Buoyancy and air budget | Rise and sink through a shaft; watch the meter fall; find the vent | Choose between two routes with different air costs | Budget an entire dark segment before lighting the lantern once |
| Current | Ride a drift across a gap that cannot be crossed unaided; feel the doubled cost going back | Take the longer current-assisted route as the cheap option | Use the current to cross the corridor cleared of its Glimmer |
| Lantern | Reveal a dark alcove containing the exit; then, at a safe enclosure, light it and watch a Glimmer approach, darken it and watch the Glimmer return | Travel past a Glimmer with the lantern off, using memorised geometry | Light it deliberately to pull the Glimmer away from a passage |
| Hazard reading | Avoid a labelled red coral strip in still water | Avoid coral while choosing between two current-assisted routes | Account for coral knockback while timing a Glimmer lure |

**L1's Glimmer enclosure is an active exercise, not a cutscene:** the exit does not open until the player has lit and darkened the lantern once inside the observation chamber, so the reaction cannot be walked past unnoticed.

### 8.3 Pacing rule (anti-filler)

Every chamber must introduce a use, test a use, or combine two uses. No corridor longer than one screen may exist without a decision in it. A room that fails this test is cut rather than decorated. *To be audited against the first full playthrough recording.*

---

## 9. Design Schemas (Graduate Requirement)

Three schemas from *Rules of Play*, chosen because they describe the systems this game actually contains. Each is written as definition, implementation, player decision, and evidence.

### 9.1 Games as Systems of Information

**Definition.** How information is distributed, revealed and withheld, and how that distribution shapes decisions.

**Implementation.** Four categories are deliberately separated: geometry and vents are hidden until lit; currents are always known; the Glimmer's path is discoverable but its current position outside the lit radius is not; pearls are hidden off the critical path. No ability is unlocked, so progression is entirely progression in what the player knows.

**Player decision.** Whether to buy information now or commit from memory. Lighting the lantern spends air and, near a Glimmer, spends safety. Going dark spends certainty. This is the decision the game asks most often.

**Evidence.** L2's Glimmer corridor: the geometry is learnable in one lit pass, after which the segment is cheaper to run dark. The player's second attempt should visibly differ from the first.

### 9.2 Games as Systems of Uncertainty

**Definition.** Outcomes the player cannot fully predict at the moment of committing. Salen and Zimmerman are explicit that this does not require randomness.

**Implementation.** There is no random number generation affecting play. Uncertainty is produced by limited information and by execution: the Glimmer's position inside unlit space is unknown until the lantern is lit or contact occurs, and the outcome of a route depends on whether the player's timing and thrust control match their plan. In Epstein's terms the player operates under **risk** rather than pure uncertainty: the structure is fully knowable and skill reliably reduces exposure.

**Player decision.** Whether the remaining air justifies committing to a route whose midpoint is unobserved.

**Evidence.** Deterministic systems, non-deterministic outcomes: *hypothesis, to be tested by whether two playtesters take measurably different routes through the same L2 segment.*

### 9.3 Games as Cybernetic Systems

**Definition.** A sensor, a comparator and an activator arranged so that the system's output feeds back into its own input. Salen and Zimmerman's model runs game state to scoring function to controller to game mechanical bias and back to game state, and the player is inside that loop.

**Implementation, as a closed loop rather than a component list:**

| Stage | In Ballast |
|---|---|
| Game state | Position, air, lantern state, segment |
| Sensor (scoring function) | Continuous air reading |
| Comparator (controller) | Thresholds at 25 and 0 |
| Activator (mechanical bias) | Vignette and heartbeat at 25; loss of control and respawn at 0 |
| **Back into game state** | The warning changes what the player does: darken the lantern, stop climbing, reroute to a vent, or accept the death and restart the segment cheaply. That choice changes the air curve, which the sensor reads next frame. |

The loop closes **through the player**, which is why it is a cybernetic system and not just a status bar.

**Direction of feedback, stated explicitly.** The warning branch is informational and intended to be stabilising. The respawn branch is a hard reset to a known good state, which caps the cost of failure and is also stabilising. The design deliberately contains **no** amplifying branch, because the obvious candidate (slowing the player at low air) would make failure accelerate failure. See §12.3.

**Evidence needed.** Whether players actually change behaviour at the warning, or ignore it and drown, is a playtest question. `TODO: record it.`

> 中文批注：Conflict 和 Emergent 两个 schema 本版不写。不是因为不成立，而是因为这一版的实现还给不出"具体规则 + 实现行为 + 如何影响决策"三件套的完整证据。如果试玩中真的出现了值得分析的涌现行为，再补 Emergent，届时用真实观察来写。

---

## 10. Fun Checklist (Koster)

| Element | How Ballast addresses it |
|---|---|
| Preparation | Surveying a room with the lantern before spending air |
| Sense of space | Three depth zones; vertical descent as the through-line |
| Solid core mechanic | Spend air to move; everything else modifies that |
| Range of challenges | Same rules, varied parameters: current strength, vent spacing, light level, Glimmer placement |
| Range of abilities required | L2 and L3 segments are designed to need more than one; *to be audited, not asserted* |
| Skill required | Leading inputs, judging drift, committing to a route with a known budget |
| Variable feedback | Pearls, elapsed time, air remaining at the nest |
| Mastery problem | Skilled players finish with air to spare and can attempt all-pearl runs |
| Failure has a cost | Lost time and replay of the current segment |

---

## 11. Art and Audio Requirements

**Animations:** Yuun idle, swim, rise, sink, drown; Glimmer drift and attracted. Loop counts are a scope choice, not an assignment requirement; AnimatedSprite2D loops are sufficient.

**Audio events (the assignment names pickups, attacks and damage as examples):** pearl pickup, vent refill, lantern toggle, low-air heartbeat, drowning, Glimmer contact, checkpoint activated, level complete, ambient bed. Ambient music is optional and does not substitute for event audio.

The current prototype uses original procedural graphics, original generated event sounds and an original 48-second looping underwater theme. The music generator and note sequence are stored in `tools/generate_audio.py` as provenance. No third-party art or audio is included. Any later third-party asset must be credited with its licence in README before release.

---

## 12. Iteration and Playtesting

> 中文批注：评分表这一项要求"描述的改动和 git push 对应"。每一行都要能指回一个 commit 或 tag，开发过程中随手填。

### 12.1 Playtest protocol

Each human round will use the controls card only, without verbal guidance. Record the number of testers, time per segment, deaths per checkpoint, the first moment of confusion, whether the player reacted to the low-air warning, and whether the alternate route was found unprompted. Automated rule checks are recorded separately and are not presented as human playtests.

**Rule-breaking pass (Rules of Play, ch. on breaking the rules).** Each round must also include deliberate abuse: hold `W` and `S` together; touch a vent at exactly full air; touch a vent during the drowning animation; die on the same frame as touching a checkpoint; pause during a current; die and confirm that vents and Glimmers in the segment reset; enter and leave a rip current repeatedly; stand still with the lantern lit next to a Glimmer.

### 12.2 Iteration log

| Version | Date | Commits / tag | What changed | Why |
|---|---|---|---|---|
| v0.1-prototype | 2026-09-20 | `881832c` | Playable test room plus first three-level blockout: buoyancy, air, drift and rip currents, one-use vents, forward checkpoints, respawn, lantern, Glimmer, animation, event audio and diagnostics | Verify the complete rule loop early; automated boundary checks passed, while human clarity and timing tests remain pending |
| v0.2-fun-pass | 2026-09-20 | `78c4961` | Added an explicit hold-key tutorial, current-aligned pearl trails, timed flow-chain scoring, movement trails, pickup bursts, background schools and rays, an original looping theme, and a distinct pearl sound | Respond to the first direct player reaction that the rule prototype was unclear, static and not yet fun; preserve the air economy while adding short-term goals and feedback |
| v0.3-danger-pass | 2026-09-20 | `1c40cc4` | Rebalanced a continuously swimming air tank to roughly 40–55 seconds; added labelled stinging coral with air damage and knockback; made hostile Glimmer contact use the visible drowning sequence; added a dangerous final test-room exercise | Direct play feedback showed that the safe prototype felt like consequence-free swimming, so failure had to become visible, attributable and avoidable |
| v0.4-budget-pass | 2026-09-21 | `022ba4a` | Named the jade-coloured player Yuun; reduced continuous horizontal endurance from roughly 54 to 37 seconds; made Glimmer faster than Yuun; reduced coral damage to 25; weighted more pearls toward the expensive route; added checkpoint air-efficiency scoring | Make air and route choice constrain play without adding another control or punishing one mistake; reward both efficient travel and deliberate pearl risk |
| v1.0 | `TODO` | `TODO` | Art, animation, audio, three-platform export | Release |

### 12.3 Design decisions recorded before implementation (2026-09-20 review)

These are design-review outcomes, not playtest results, and are labelled as such.

1. **Rejected: speed penalty at low air.** It would form an amplifying loop (less air, slower movement, longer travel, less air) that makes failure accelerate failure. The warning is now informational only.
2. **Rejected: extra vents spawned after repeated deaths.** A dynamic difficulty adjustment is defensible, but it adds a system that would have to be explained, tuned and playtested, and its fairness is exactly the case Salen and Zimmerman flag as feeling like cheating. Cut for scope.
3. **Changed: vents are single use.** Repeatable vents made waiting at a vent a viable strategy, which risks the "noticeable filler" failure and makes segment air budgets uncomputable.
4. **Changed: currents are always visible.** The earlier draft had them visible in one section and lantern-dependent in another. Planning information should not be hidden; the lantern reveals obstacles instead.
5. **Cut: cycling clam gates, creature-triggered rock breaking, creatures carried by currents, timed final ascent, randomised creature search.** Each was a named mechanic with no defined rules, and each represented real implementation work that the schedule does not support.
6. **Added: the L1 observation chamber gates its exit** on the player toggling the lantern, because a demonstration the player can walk past does not satisfy "learn in one level, use in the next".

### 12.4 Emergent rule interaction found in design review (2026-09-21)

The first efficiency-score implementation combined three individually reasonable rules: pearls persisted through death, restart restored full air, and checkpoint score depended on remaining air. Together they created an unintended dominant strategy: collect every expensive-route pearl, restart for full air, then take the efficient route and receive both rewards. The fix makes segment pearls and their score pending until the next checkpoint or exit; restart returns them to the room. An automated regression test deliberately collects a pearl, restarts, and verifies that the pearl returns while permanent score remains unchanged. This is a real emergent interaction discovered by attempting to break the rules, not a hypothetical example.

---

## 13. Build and Run Instructions

Built with Godot `4.7.2 stable`. Releases are attached to the GitHub Releases page.

- **Windows (x86_64):** download `ballast-windows-x86_64.zip`, extract, run `Ballast.exe`. If SmartScreen appears, choose More info then Run anyway.
- **Linux (x86_64):** download `ballast-linux-x86_64.zip`, extract, then `chmod +x Ballast.x86_64 && ./Ballast.x86_64`.
- **macOS:** download `ballast-macos.zip` and extract. The app is unsigned. Right-click the app and choose Open, or run `xattr -dr com.apple.quarantine Ballast.app` first.

From source: clone the repository, open `project.godot` in Godot `4.7.2 stable`, then Project > Export with matching export templates installed.

---

## 14. Rubric Self-Check (internal)

| Rubric line | Where satisfied | Done |
|---|---|---|
| Playable from provided release | §13; tested on a machine that is not mine | [ ] |
| 2D and made in Godot | §1 | [ ] |
| Progression in learning | §8.1, §8.2; all three abilities taught in L1, reused in L2, recombined in L3 | [ ] |
| Substantial, 5 to 10 min, no filler | §8.1, §8.3; measured, not assumed | [ ] |
| Fun | §10 | [ ] |
| What the game teaches | §4 | [ ] |
| Core mechanics and how to play | §3.3, §6 | [ ] |
| Defined rules | §7, all three levels | [ ] |
| Concept, genre, background described and implemented | §2, §3, §5 | [ ] |
| Iteration described and matching git history | §12 | [ ] |
| Grad: schemas explicit | §9 | [ ] |
| Grad: third level | §8.1 | [ ] |
| Grad: animation and event audio | §11 | [ ] |
| Repo public, `cwwalterOleMiss` invited | `TODO` | [ ] |
| Blackboard: report and repo link | `TODO` | [ ] |

---

## 15. Known Issues and Future Work

- The three level layouts are a first playable blockout and have not yet been validated for a 5–10 minute completion time.
- External human playtesting has not yet been completed; clarity and fun remain unverified.
- Windows and Linux packages have been created but not launched on their destination operating systems.
- Procedural art has received an initial feedback pass, but final visual polish still depends on human playtest observations.
