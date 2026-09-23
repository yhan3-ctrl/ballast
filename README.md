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
