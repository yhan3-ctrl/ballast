# Ballast — Yuun the Jadefin

By Yu Han, CSCI 5999B. Godot 4.7.2 stable, 2D Compatibility renderer.

A surge scattered the young. Rescue three baby fish in each dive and bring them to the golden house. Complete Reef, Kelp Drift and Trench in order. Pearls are optional score items, never required to survive or finish.

## Download and report

[Download Ballast 1.0.0](https://github.com/yhan3-ctrl/ballast/releases/tag/v1.0.0) 

## Start

Use the archive matching your operating system and extract it completely. Windows: launch `Ballast.exe`. Linux: launch `Ballast.x86_64` (set executable permission if your extractor does not preserve it). macOS: open `Ballast.app`. These student builds are not commercially signed/notarized; native platform acceptance is listed in `docs/BUILD-VERIFICATION.md`.

For source: import `project.godot` into Godot 4.7.2 and click Run Project. Choose Dive 1, then Start Challenge. Finishing unlocks the next chapter; cleared chapters can be replayed.

## Controls

| Input | Action |
|---|---|
| W / S | Swim up / down |
| A / D | Swim left / right |
| Space | Toggle lantern: illumination and Glimmer bait, **not protection** |
| R | Retry from the active anchor |
| Esc | Pause; Q while paused returns to map |
| M / N | Toggle music / effects |
| F1 | Diagnostics, not required to play |

## Rules you need to know

- Touch a baby to rescue it and gain up to 25 air once. It follows your trail. Rescue progress survives anchor retries.
- Babies have two health dots. Coral, active pulses and charging Glimmer remove one health; hits have a two-second grace period. Losing both dots sends the family to the anchor and restores health.
- Your air is fuel and life. Movement and light cost air; releasing input saves thrust cost. Vents restore 40 air once per segment attempt. New forward anchors refill air; revisiting an old one does not.
- Red coral removes 25 air. An active anemone pulse removes 20. A Glimmer charge removes 30. Player damage grants 0.9 seconds of immunity; zero air starts a retry.
- Glimmer flashes and tucks its tentacles for 1.2 seconds, then charges in a locked direction. Dodge sideways and pass while it rests for 1.3 seconds. It must return home before another attack. Ordinary patrol/rest contact is harmless. Light draws attention to Yuun; it does not shield anyone. There is no trajectory line.
- Anemones cycle through PASS NOW, WAIT... and PULSE! Walls block pulses and Glimmer sight/movement.
- Pearls and their chain points are AT RISK until a new anchor or home banks them. Retrying loses unbanked rewards. New anchors/home also reward remaining air ×20, once. Time is shown in results and does not affect score.
- Bring all three babies to the house to complete a chapter. You cannot finish by reaching the house alone.

## Evidence and report

- `GDD.md`: final design, learning progression, complete rules, schemas and background.
- `PLAYTEST.md`: reported feedback and automated evidence, clearly distinguished.
- `docs/ITERATIONS.md`: actual commit history and reasons for changes.
- `docs/BUILD-VERIFICATION.md`: package hashes and verification limits.
- `docs/SUBMISSION.md`: publishing and Blackboard checklist.

## Credits

Ballast was developed through iterative design and playtesting led by Yu Han. The game uses procedural artwork, synthesized event audio and original synthesized music. No commercial recordings or third-party art are included. Reproducible audio sources are in `tools/generate_audio.py` and `tools/generate_events.py`. 
