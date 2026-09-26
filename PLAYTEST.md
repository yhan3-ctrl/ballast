# Ballast — Playtesting and Iteration Summary

**Designer:** Yu Han  
**Peer testers:** Haopeng Chen, Roucheng Ou and Xuemeng Hu

## Peer playtesting

Friends played development versions of Ballast and provided feedback that Yu Han relayed during the project. Their feedback helped identify problems with goal clarity, route readability, difficulty progression and the relationship between light and enemy behaviour. The findings are summarized collectively rather than attributed to individual testers.

Early feedback showed that the original destination was difficult to recognize and that swimming alone did not give the player a clear purpose. The game was revised around a visible rescue objective: touch three baby fish, let them follow, and bring them to a golden house. The objective counter and direction indicator reinforce this goal throughout play.

Further feedback called for clearer rocks and forks, more interesting obstacle placement, and a stronger final chapter. Alternating coral, stronger wall outlines, varied trench passages and timed anemone pulses added more readable route choices. Giving followers two health points made escorting them an active responsibility.

The first protection system was confusing because light protected followers but not Yuun. Continuous pursuit also made the faster jellyfish difficult to evade. The shield was removed. Glimmer now signals an attack, commits to a fixed direction, rests and returns home before attacking again. Light serves as illumination and bait. After testers found the fully drawn trajectory unnatural, the line was replaced by a local flash, tucked tentacles and gaze cues.

The latest feedback reported no current problems and an overall positive impression. This supports the revisions qualitatively; it is not a claim that every player will find the game equally easy or enjoyable.

## Feedback-to-change record

| Finding | Response | Implementation evidence |
|---|---|---|
| Unclear goal and destination | Baby rescue, visible house, objective guidance | 3bd180b, a48e143 |
| Routes and dangers hard to read | Coral weaving, stronger walls and hostile visual identity | a1f742a |
| Final chapter too simple; escort lacked stakes | Trench baffles, follower health, timed pulses | 64650f5 |
| Shield behaviour confusing; pursuit hard to evade | Remove protection; use committed charges, rest and return | f51bf88 |
| Attack trajectory looked artificial | Natural local warning; preserve dodge opportunity | Final release revision, see ITERATIONS.md |

## Automated verification

The final candidate passed 126 rule checks and three static route checks. Scripted playthroughs used normal movement physics, air consumption, active hazards and follower damage. Pearl pickups were disabled to test optionality. All three chapters completed with zero pearls and zero retries, in 119.23, 147.18 and 136.77 simulated seconds respectively (about 6 minutes 43 seconds total).

These are automated traversal times, not human playtest measurements. Peer session times and death counts were not recorded. Build hashes, test scope and remaining platform checks are in docs/BUILD-VERIFICATION.md. Detailed development notes are retained in docs/PLAYTEST-HISTORY.md.
