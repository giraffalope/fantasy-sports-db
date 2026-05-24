"""CG/CGM aggregate tables must unique-key entity FK + generation grain."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UK_DIR = ROOT / "nascar" / "ddl" / "unique_keys"

EXPECTED: list[tuple[str, str]] = [
    ("3046", "car_driver_id"),
    ("3047", "car_driver_id"),
    ("3048", "car_id"),
    ("3049", "car_id"),
    ("3050", "driver_id"),
    ("3051", "driver_id"),
    ("3052", "manufacturer_id"),
    ("3053", "manufacturer_id"),
    ("3054", "team_id"),
    ("3055", "team_id"),
    ("3056", "car_driver_id"),
    ("3057", "car_driver_id"),
    ("3058", "car_id"),
    ("3059", "car_id"),
    ("3060", "driver_id"),
    ("3061", "driver_id"),
    ("3062", "manufacturer_id"),
    ("3063", "manufacturer_id"),
    ("3064", "team_id"),
    ("3065", "team_id"),
]


def _uk_file(num: str) -> Path:
    matches = sorted(UK_DIR.glob(f"{num}-create_unique_*"))
    assert len(matches) == 1, f"expected one UK file for {num}, got {matches}"
    return matches[0]


def test_cg_cgm_unique_keys_include_entity_column() -> None:
    for num, entity_col in EXPECTED:
        path = _uk_file(num)
        sql = path.read_text()
        cols_match = re.search(r"UNIQUE KEY[^(]+\(([^)]+)\)", sql)
        assert cols_match is not None, path.name
        cols = [c.strip().strip("`") for c in cols_match.group(1).split(",")]
        assert entity_col in cols, f"{path.name} missing {entity_col}: {cols}"
        assert cols.index(entity_col) < cols.index("car_generation_id")
