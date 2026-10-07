#!/usr/bin/env python3
"""Generate seamless-loop white and brown noise MP3s for ambient sounds."""

from __future__ import annotations

from pathlib import Path

import lameenc
import numpy as np

SAMPLE_RATE = 44100
DURATION_SEC = 30
OUT_DIR = Path(__file__).resolve().parent.parent / "assets" / "sounds"
MAX_BYTES = int(1.5 * 1024 * 1024)


def _make_seamless_white(n: int, seed: int) -> np.ndarray:
    rng = np.random.default_rng(seed)
    return rng.standard_normal(n).astype(np.float64)


def _make_seamless_brown(n: int, seed: int) -> np.ndarray:
    white = _make_seamless_white(n, seed)
    brown = np.cumsum(white)
    # Close the loop: end sample matches start for seamless repeat.
    t = np.linspace(0.0, 1.0, n, endpoint=False)
    trend = brown[0] * (1.0 - t) + brown[-1] * t
    brown = brown - trend
    peak = np.max(np.abs(brown))
    if peak > 0:
        brown = brown / peak
    return brown


def _to_pcm16(samples: np.ndarray) -> bytes:
    clipped = np.clip(samples, -1.0, 1.0)
    pcm = (clipped * 32767.0).astype(np.int16)
    return pcm.tobytes()


def _encode_mp3(pcm_bytes: bytes, bitrate: int = 128) -> bytes:
    encoder = lameenc.Encoder()
    encoder.set_bit_rate(bitrate)
    encoder.set_in_sample_rate(SAMPLE_RATE)
    encoder.set_channels(1)
    encoder.set_quality(2)
    mp3 = encoder.encode(pcm_bytes)
    mp3 += encoder.flush()
    return mp3


def _write_mp3(path: Path, samples: np.ndarray, bitrate: int) -> None:
    pcm = _to_pcm16(samples)
    data = _encode_mp3(pcm, bitrate=bitrate)
    while len(data) > MAX_BYTES and bitrate > 64:
        bitrate -= 16
        data = _encode_mp3(pcm, bitrate=bitrate)
    path.write_bytes(data)
    size_kb = len(data) / 1024
    print(f"Wrote {path.name}: {size_kb:.1f} KB @ {bitrate} kbps")


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    n = SAMPLE_RATE * DURATION_SEC

    white = _make_seamless_white(n, seed=42)
    brown = _make_seamless_brown(n, seed=43)

    _write_mp3(OUT_DIR / "white_noise.mp3", white, bitrate=128)
    _write_mp3(OUT_DIR / "brown_noise.mp3", brown, bitrate=128)


if __name__ == "__main__":
    main()
