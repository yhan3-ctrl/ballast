"""Generate Ballast's original music and pearl sound using only the standard library."""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AUDIO = ROOT / "assets" / "audio"
RATE = 22_050


def note(midi: int) -> float:
    return 440.0 * (2.0 ** ((midi - 69) / 12.0))


def write_stereo(path: Path, left: list[float], right: list[float]) -> None:
    peak = max(1.0, max(abs(v) for v in left + right) * 1.03)
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(2)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        frames = bytearray()
        for l, r in zip(left, right):
            frames += struct.pack("<hh", int(l / peak * 32767), int(r / peak * 32767))
        wav.writeframes(frames)


def make_music() -> None:
    random.seed(224)
    beat = 60.0 / 80.0
    bars = 16
    duration = bars * beat * 4.0
    count = int(duration * RATE)
    left = [0.0] * count
    right = [0.0] * count

    chords = [
        (50, 57, 61, 64),  # Dmaj9 colour
        (47, 54, 57, 62),  # Bm7
        (43, 50, 54, 59),  # Gmaj9
        (45, 52, 57, 59),  # A6/9
    ]
    melody = [69, 73, 76, 74, 71, 69, 66, 69, 74, 76, 78, 76, 73, 71, 69, 66,
              71, 74, 78, 76, 74, 71, 69, 71, 73, 76, 74, 71, 69, 66, 64, 66]

    def add_tone(start: float, length: float, freq: float, amp: float, pan: float, kind: str) -> None:
        first = int(start * RATE)
        last = min(count, int((start + length) * RATE))
        for i in range(first, last):
            local = i / RATE - start
            phase = math.tau * freq * local
            if kind == "pad":
                env = math.sin(math.pi * local / length) ** 1.4
                value = (math.sin(phase) + 0.34 * math.sin(phase * 2.003) + 0.16 * math.sin(phase * 0.501)) * env
            elif kind == "pluck":
                env = math.exp(-4.8 * local / length) * min(1.0, local * 80.0)
                value = (math.sin(phase) + 0.28 * math.sin(phase * 2.0)) * env
            else:
                env = math.sin(math.pi * local / length)
                value = math.sin(phase) * env
            left[i] += value * amp * (1.0 - pan * 0.35)
            right[i] += value * amp * (1.0 + pan * 0.35)

    for bar in range(bars):
        start = bar * beat * 4.0
        chord = chords[bar % len(chords)]
        for voice, midi in enumerate(chord):
            add_tone(start, beat * 4.0, note(midi), 0.075, -0.7 + voice * 0.45, "pad")
        add_tone(start, beat * 3.7, note(chord[0] - 12), 0.085, 0.0, "bass")
        for step in range(2):
            midi = melody[(bar * 2 + step) % len(melody)]
            add_tone(start + step * beat * 2.0, beat * 1.7, note(midi), 0.12, -0.35 if step == 0 else 0.35, "pluck")
        for step in range(4):
            add_tone(start + step * beat, beat * 0.42, note(chord[(step + 1) % 4] + 12), 0.035, 0.5 if step % 2 else -0.5, "pluck")

    # Very quiet filtered-looking water texture, deterministic and original.
    drift = 0.0
    for i in range(count):
        drift = drift * 0.995 + (random.random() * 2.0 - 1.0) * 0.005
        swell = 0.5 + 0.5 * math.sin(math.tau * i / RATE / 12.0)
        left[i] += drift * 0.018 * swell
        right[i] += drift * 0.014 * swell

    write_stereo(AUDIO / "music.wav", left, right)


def make_pearl() -> None:
    duration = 0.62
    count = int(duration * RATE)
    left = [0.0] * count
    right = [0.0] * count
    for i in range(count):
        t = i / RATE
        env = math.exp(-6.2 * t)
        shimmer = math.sin(math.tau * note(81) * t) + 0.55 * math.sin(math.tau * note(88) * t)
        left[i] = shimmer * env * 0.32
        right[i] = shimmer * env * 0.29
    write_stereo(AUDIO / "pearl.wav", left, right)


if __name__ == "__main__":
    AUDIO.mkdir(parents=True, exist_ok=True)
    make_music()
    make_pearl()
    print("Generated original Ballast music.wav and pearl.wav")
