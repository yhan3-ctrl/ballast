"""Original short event cues for Ballast. No sampled commercial recordings."""
import math
import random
from generate_audio import AUDIO, RATE, note, write_stereo

def cue(name, tones, duration, noise=0.0):
    count = int(duration * RATE)
    samples = [0.0] * count
    rng = random.Random(224)
    for start, length, midi, amplitude in tones:
        first = int(start * RATE)
        for i in range(first, min(count, int((start + length) * RATE))):
            t = i / RATE - start
            attack = min(1.0, t / 0.012)
            release = min(1.0, max(0.0, (length - t) / 0.06))
            envelope = attack * release * math.exp(-3.2 * t / length)
            value = math.sin(math.tau * note(midi) * t)
            samples[i] += amplitude * envelope * (value + 0.15 * math.sin(math.tau * note(midi) * 2 * t))
    for i in range(count):
        t = i / RATE
        samples[i] += noise * rng.uniform(-1, 1) * min(1, t / 0.015) * math.exp(-10 * t / duration) * min(1, (duration - t) / 0.06)
    peak = max(abs(v) for v in samples)
    if peak > 0.75:
        samples = [v * 0.75 / peak for v in samples]
    write_stereo(AUDIO / (name + '.wav'), samples, samples)

cue('pearl', [(0,.26,81,.4),(.06,.32,88,.17)], .42)
cue('vent', [(0,.28,57,.28),(.1,.3,64,.26),(.2,.4,69,.22)], .65, .035)
cue('checkpoint', [(0,.5,62,.27),(.12,.5,66,.24),(.24,.7,69,.22),(.24,.7,74,.16)], 1.0)
cue('complete', [(i*.15,.7,m,.25) for i,m in enumerate([62,66,69,74,78])], 1.35)
cue('toggle', [(0,.12,76,.22)], .16)
cue('contact', [(0,.18,43,.36),(.025,.18,44,.2)], .26, .1)
cue('drown', [(0,.42,50,.3),(.18,.48,45,.27),(.4,.6,38,.25)], 1.05)
cue('heartbeat', [(0,.13,35,.4),(.2,.16,32,.28)], .4)
cue('return', [(0,.32,57,.2),(.1,.42,62,.23)], .56)
cue('rescue', [(0,.4,69,.25),(.1,.45,76,.25),(.22,.6,81,.24)], .9)
cue('glide', [(0,.3,74,.15),(.08,.32,81,.1)], .44, .015)

print('Generated 11 original event cues')
