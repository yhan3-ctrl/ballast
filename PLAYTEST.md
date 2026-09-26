# Ballast — My Playtest Notes

## What I learned from playtesting

I asked three friends who regularly play games—Haopeng Chen, Roucheng Ou and Xuemeng Hu—to try Ballast. Their comments helped me see problems I missed because I already knew the routes and understood the rules. I also played through it myself.

| Player | Completion time | Deaths / retries |
|---|---:|---:|
| Me, already familiar with every route | About 5 minutes | 2 |
| Friend A, first playthrough | About 6 minutes | 3 |
| Friend B, first playthrough | About 5 minutes | 0 |
| Friend C, first playthrough | About 8 minutes | 6 |

The three friend results are listed in the order I recorded them, without assigning each result to a name. Their first playthroughs took 5–8 minutes, which fits my 5–10 minute target. One player finished without dying, while another retried six times. That difference matters: knowing the controls is not the same as knowing a safe route, and I need checkpoints to make mistakes recoverable.

The most useful feedback was not just whether they liked it. At first, the goal was unclear and the game felt like swimming without a purpose. I replaced the unclear objective with recognizable baby fish and a golden home, and kept the rescue count visible. This gave the movement a reason: I was bringing someone home, not just reaching the right side of the map.

My friends also wanted clearer rocks and forks, more obstacles to weave through, and a harder third chapter. I made the wall outlines easier to see, added alternating coral, varied the trench passages and introduced timed anemone pulses. I gave the babies health so that escorting them involved a risk, rather than having them follow as decoration.

Another version used light as a shield for the babies but not for Yuun. My friends found that confusing. The jellyfish also chased continuously, which made its higher speed feel unfair. I removed the shield and changed the attack to a warning, a straight charge and a recovery period. Light now has a simpler role: it helps me see and lets me draw the creature's attention. When the visible attack line looked too artificial, I replaced it with flashing, tucked tentacles and an eye-direction cue.

The latest feedback was that there were no current problems and the game felt good overall. I used that as a reason to stop adding mechanics and focus on finishing the existing game cleanly.

## How the design changed

I kept the changes in Git so I could connect each design decision to the version where I made it.

| Change I made | Why I made it | Commit |
|---|---|---|
| Bank pearls only at a new anchor or home | Players could otherwise collect pearls, retry for full air and keep both rewards | `115040b` |
| Explain AT RISK on the first pearl pickup | Losing unbanked rewards should not feel like a bug | `ebf46b7` |
| Add a chapter map, introductions and results | The three levels needed clear beginnings and endings | `c73296b` |
| Make baby rescue the main goal | The earlier objective was hard to recognize and gave little motivation | `3bd180b`, `a48e143` |
| Clarify rocks, forks and dangerous creatures | Players needed to read the route while moving | `a1f742a` |
| Add follower health and timed hazards | Make the escort and final chapter more engaging | `64650f5` |
| Remove shields and replace pursuit with fixed charges | Make the rules easier to understand and attacks possible to dodge | `f51bf88` |
| Use natural warning cues and add a Reef charge encounter | Keep the warning readable and introduce the attack before later levels reuse it | `f453aff` |

A longer version history is in `docs/ITERATIONS.md`.

## Technical checks

The 126 rule checks and the scripted zero-pearl route are separate from my friends’ playthroughs. Full technical results are in `docs/BUILD-VERIFICATION.md`. Earlier development notes remain in `docs/PLAYTEST-HISTORY.md`.
