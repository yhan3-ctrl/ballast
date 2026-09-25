# Ballast

Local development prototype for CSCI 5999B Project 1.

The player character is **Yuun the Jadefin**, a jade-coloured anglerfish named from creator Yu Han's English name order and visually linked to the personal handle `hnuu`.

Engine: Godot 4.7.2 stable, GDScript, Compatibility renderer.

Open `project.godot` with Godot and use **Play Project** for the main menu. On macOS the shortcut is `Command+B`. From the title screen, press `T` for the focused test dive.

## Controls

- `W` / `S`: rise and sink
- `A` / `D`: swim left and right
- `Space`: toggle lantern
- `R`: restart at the latest anchor
- `Esc`: pause
- `F1`: diagnostics overlay
- `T` on the title screen: open the focused test dive

Red coral removes 25 air and knocks Yuun away. Hostile Glimmers cause drowning on contact. The first test room labels both hazards before the final exercise.

Pearls collected inside the current segment are marked **AT RISK**. They and their pending score are banked only at the next anchor or level exit; death or `R` returns them to the room.

## Local verification

Run the automated boundary checks with:

`/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/test_runner.gd`

Export presets are included for Windows x86_64, Windows x86_32, Linux x86_64, and macOS Universal. Generated packages go under `builds/` and remain outside Git.

Build checks and SHA-256 values are recorded in `docs/BUILD-VERIFICATION.md`.

The current prototype uses original procedural graphics, original generated event sounds and original music. No third-party art or audio is included.

The original 48-second looping underwater theme and event sounds can be regenerated with `python3 tools/generate_audio.py`; the script and note sequence are kept in the repository as asset provenance.

Status: playable prototype. Automated checks and package creation do not count as human playtesting or validation on the destination operating systems.


### Fairness revision controls and measurement
M toggles music; N toggles effects. Losing focus pauses a running dive. F1 preserves the latest pre-refill arrival air/time. Godot Output emits `BALLAST_TELEMETRY` JSON per arrival/retry; this is measurement data, not a completed human playtest. Exit rewards now use the same settlement as anchors.


### Chapter map (v0.6.0)
Click an unlocked dive, read its objective/tips, then Start Challenge. Completing a chapter opens results and unlocks the next. Replay resets that chapter's attempt; R only retries the active anchor. Normal gameplay has no timer; results and F1 show time. Map best times appear after completion. Progress is game-local: `saves/progress.cfg` in source runs, Godot's app-specific user data in exports. Source save data is excluded from release packages.


### Event audio (v0.6.1)
Nine original synthesized event cues are reproducible with `python3 tools/generate_events.py`. They use no commercial samples. Pearl chains rise by up to four semitones; checkpoint, completion, vent, damage, drowning, return and lantern each have distinct cues. Low air/pause reduces background music by 8 dB. Effects have per-event levels, short cooldowns and at most six managed voices; mute stops active effects. Current background music remains the original generated track, not Labrinth or another commercial recording.


### Current local candidate — v0.7.0
Three differentiated layouts and three original chapter arrangements. Start via `project.godot` and F5, or the Mac archive under `builds/macos/`. Current behaviour and verification limitations are documented in `GDD.md` and `docs/FINAL-REVIEW.md`; older dated notes describe earlier iterations. No commercial song is included and no public release has been made.


### Rescue mode — v0.8.0
**Touch three baby fish, let them follow, then bring them to the golden house.** No interaction key is required. Rescuing grants up to 25 air once; rescued babies remain with you after an anchor retry. The HUD always shows rescue progress and points toward the next missing baby/home. Pearls are optional. The old Glimmer observation gate has been removed. Relaxing input in a current activates glide feedback and shows actual air drain. Old unlocks are retained; rescue best times start separately.


### v0.8.1 rescue clarity follow-up
All player-facing text remains English; Chinese UI text was removed at the creator's explicit request. The direction arrow selects the nearest unrescued baby, and reaching home early explicitly states the missing count. Followers face their direction of movement. 74 regression checks and 21 rescue checks passed; three static route checks passed. Graphical capture still exits at native startup in the current tool environment; no new visual pass is claimed.

### v0.8.2 readability update
More alternating coral creates weaving opportunities. Rock outlines and hostile warning icons stay visible with the lantern off. Upper/lower route labels clarify chapter-two forks. Hostile Glimmer contact causes a retry; coral removes 25 air. All player-facing text remains English.

### v0.9.1 — readable charge attacks
Babies have two health dots. Light illuminates and baits Glimmer; it does not shield anyone. Hostile Glimmer marks a fixed line for 1.2 seconds, charges along it, then rests harmlessly for 1.3 seconds. A charge costs Yuun 30 air or a baby one health. Ordinary patrol/recovery contact is harmless. Coral and pulse anemones still damage the family. Losing both baby dots retries at the anchor, preserving rescues and restoring health. Pearls only award optional score; they are not a victory requirement or air source.
