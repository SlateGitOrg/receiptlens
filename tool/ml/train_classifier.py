#!/usr/bin/env python3
"""Trains the tiny bag-of-words line-item category classifier used by
ReceiptLens and exports it in two equivalent forms:

  1. assets/model/category_classifier.tflite  - real TFLite model used by
     the production on-device inference path (tflite_flutter).
  2. assets/model/weights.json                - the exact same trained
     weights, laid out so a pure-Dart forward pass can reproduce identical
     predictions. This lets unit tests (and Dart environments where the
     native TFLite runtime is unavailable, e.g. `flutter test`) exercise
     the real, trained decision boundary deterministically and offline.

Everything here runs fully offline against the bundled
tool/ml/training_data.csv fixture. No network access is used or required.

Usage:
    python3 tool/ml/train_classifier.py
"""
from __future__ import annotations

import csv
import json
import os
import re

os.environ.setdefault("TF_USE_LEGACY_KERAS", "1")
os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")

import numpy as np
import tensorflow as tf

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
DATA_CSV = os.path.join(HERE, "training_data.csv")
ASSET_DIR = os.path.join(ROOT, "assets", "model")

VOCAB_SIZE = 220
HIDDEN_UNITS = 16
SEED = 7

TOKEN_RE = re.compile(r"[a-z0-9]+")


def tokenize(text: str) -> list[str]:
    return TOKEN_RE.findall(text.lower())


def load_rows() -> list[tuple[str, str]]:
    rows: list[tuple[str, str]] = []
    with open(DATA_CSV, newline="", encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        for row in reader:
            rows.append((row["text"], row["category"]))
    return rows


def build_vocab(rows: list[tuple[str, str]]) -> list[str]:
    counts: dict[str, int] = {}
    for text, _ in rows:
        for tok in set(tokenize(text)):
            counts[tok] = counts.get(tok, 0) + 1
    ranked = sorted(counts.items(), key=lambda kv: (-kv[1], kv[0]))
    return [tok for tok, _ in ranked[:VOCAB_SIZE]]


def vectorize(text: str, vocab_index: dict[str, int]) -> np.ndarray:
    vec = np.zeros(len(vocab_index), dtype=np.float32)
    toks = tokenize(text)
    if not toks:
        return vec
    for tok in toks:
        idx = vocab_index.get(tok)
        if idx is not None:
            vec[idx] += 1.0
    # L1-normalize so line-item length doesn't skew the signal.
    total = vec.sum()
    if total > 0:
        vec /= total
    return vec


def main() -> None:
    os.makedirs(ASSET_DIR, exist_ok=True)
    rows = load_rows()
    vocab = build_vocab(rows)
    vocab_index = {tok: i for i, tok in enumerate(vocab)}

    categories = sorted({cat for _, cat in rows})
    cat_index = {cat: i for i, cat in enumerate(categories)}

    x = np.stack([vectorize(text, vocab_index) for text, _ in rows])
    y = np.array([cat_index[cat] for _, cat in rows], dtype=np.int32)

    tf.random.set_seed(SEED)
    np.random.seed(SEED)

    model = tf.keras.Sequential(
        [
            tf.keras.layers.Input(shape=(len(vocab),), name="bow_features"),
            tf.keras.layers.Dense(HIDDEN_UNITS, activation="relu", name="hidden"),
            tf.keras.layers.Dense(len(categories), activation="softmax", name="category"),
        ]
    )
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.02),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )
    model.fit(x, y, epochs=200, batch_size=16, verbose=0)

    loss, acc = model.evaluate(x, y, verbose=0)
    print(f"final training accuracy: {acc:.4f} (loss {loss:.4f})")

    # --- Export 1: real TFLite model for on-device production inference ---
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()
    tflite_path = os.path.join(ASSET_DIR, "category_classifier.tflite")
    with open(tflite_path, "wb") as fh:
        fh.write(tflite_model)
    print(f"wrote {tflite_path} ({len(tflite_model)} bytes)")

    # --- Export 2: raw weights for the pure-Dart reference implementation ---
    dense1, dense2 = model.get_layer("hidden"), model.get_layer("category")
    w1, b1 = dense1.get_weights()
    w2, b2 = dense2.get_weights()

    weights = {
        "vocabSize": len(vocab),
        "hiddenUnits": HIDDEN_UNITS,
        "numCategories": len(categories),
        "w1": w1.T.tolist(),  # [hidden][vocab]
        "b1": b1.tolist(),
        "w2": w2.T.tolist(),  # [categories][hidden]
        "b2": b2.tolist(),
    }
    weights_path = os.path.join(ASSET_DIR, "weights.json")
    with open(weights_path, "w", encoding="utf-8") as fh:
        json.dump(weights, fh)
    print(f"wrote {weights_path}")

    vocab_path = os.path.join(ASSET_DIR, "vocab.json")
    with open(vocab_path, "w", encoding="utf-8") as fh:
        json.dump({"tokens": vocab}, fh)
    print(f"wrote {vocab_path}")

    categories_path = os.path.join(ASSET_DIR, "categories.json")
    with open(categories_path, "w", encoding="utf-8") as fh:
        json.dump({"categories": categories}, fh)
    print(f"wrote {categories_path}")


if __name__ == "__main__":
    main()
