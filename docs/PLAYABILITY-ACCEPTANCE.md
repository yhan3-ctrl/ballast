# Playability acceptance — v0.9.1

## v0.9.1 final automated verification
126 rule checks passed (74 regression, 21 rescue, 12 escort, 8 integrated charge, 8 isolated charge, 3 zero-pearl victory). Three static routes passed, including pulse separation from vents/home.

Scripted physical traversal uses real player physics, air, enemies, follower damage and retries; only pearl collisions are disabled. Steering uses keyboard-equivalent -1/0/1 input, a grid route and a charge-line dodge heuristic. No teleporting, manual refill, invulnerability or disabled enemies in traversal. All three completed with zero pearls and zero retries:

| Chapter | Simulated seconds | Exit air | Retries | Pearls |
|---|---:|---:|---:|---:|
| Reef | 119.55 | 84.19 | 0 | 0 |
| Kelp Drift | 147.18 | 96.75 | 0 | 0 |
| Trench | 136.77 | 55.83 | 0 | 0 |

Total 403.5 seconds. This proves a tested route exists, not human first-play duration, universal route safety or fun. Earlier failed controller runs exposed a pulse/exit overlap, a vent inside a pulse zone and repeated attacks before Glimmer returned home. Those were corrected. Shorter follower spacing and 1.2-second warning improve the available dodge window.

Pending: human graphical playthrough, understanding of light bait and charge lines, audio audition and native Windows/Linux launch.
