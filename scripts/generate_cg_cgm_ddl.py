#!/usr/bin/env python3
"""Generate CG/CGM prev-track tables, constraints, and stored procedures."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DDL = ROOT / "nascar" / "ddl"
TABLES = DDL / "tables"
FKS = DDL / "foreign_keys"
IDX = DDL / "indexes"
UK = DDL / "unique_keys"
SP = DDL / "stored_procedures"
TRIGGERS = DDL / "triggers"

CG_TRACK_TEMPLATE = TABLES / "1040-create_agg_week_prev_track_car_generations_results_table.sql"
CGM_TRACK_TEMPLATE = TABLES / "1041-create_agg_week_prev_track_car_generation_models_results_table.sql"
CG_TYPES_TEMPLATE = TABLES / "1048-create_agg_week_prev_track_types_car_generations_results_table.sql"
CGM_TYPES_TEMPLATE = TABLES / "1049-create_agg_week_prev_track_types_car_generation_models_results_table.sql"

SOURCES = [
    {
        "source_table": "agg_week_prev_track_cars_drivers_results",
        "source_sp": "6028-create_load_agg_week_prev_track_cars_drivers_results_stored_procedure.sql",
        "cg_table": "agg_week_prev_track_cg_cars_drivers_results",
        "cgm_table": "agg_week_prev_track_cgm_cars_drivers_results",
        "abbr_cg": "awptcgcdr",
        "abbr_cgm": "awptcgmcdr",
        "entity_col": "car_driver_id",
        "entity_alias": "crrcd",
        "entity_cte": "current_race_results_cars_drivers",
        "is_types": False,
    },
    {
        "source_table": "agg_week_prev_track_cars_results",
        "source_sp": "6029-create_load_agg_week_prev_track_cars_results_stored_procedure.sql",
        "cg_table": "agg_week_prev_track_cg_cars_results",
        "cgm_table": "agg_week_prev_track_cgm_cars_results",
        "abbr_cg": "awptcgcr",
        "abbr_cgm": "awptcgmcr",
        "entity_col": "car_id",
        "entity_alias": "crrc",
        "entity_cte": "current_race_results_cars",
        "is_types": False,
    },
    {
        "source_table": "agg_week_prev_track_drivers_results",
        "source_sp": "6030-create_load_agg_week_prev_track_drivers_results_stored_procedure.sql",
        "cg_table": "agg_week_prev_track_cg_drivers_results",
        "cgm_table": "agg_week_prev_track_cgm_drivers_results",
        "abbr_cg": "awptcgdr",
        "abbr_cgm": "awptcgmdr",
        "entity_col": "driver_id",
        "entity_alias": "crrd",
        "entity_cte": "current_race_results_drivers",
        "is_types": False,
    },
    {
        "source_table": "agg_week_prev_track_manufacturers_results",
        "source_sp": "6037-create_load_agg_week_prev_track_manufacturers_results_stored_procedure.sql",
        "cg_table": "agg_week_prev_track_cg_manufacturers_results",
        "cgm_table": "agg_week_prev_track_cgm_manufacturers_results",
        "abbr_cg": "awptcgmfr",
        "abbr_cgm": "awptcgmmfr",
        "entity_col": "manufacturer_id",
        "entity_alias": "crrm",
        "entity_cte": "current_race_results_manufacturers",
        "is_types": False,
    },
    {
        "source_table": "agg_week_prev_track_teams_results",
        "source_sp": "6025-create_load_agg_week_prev_track_teams_results_stored_procedure.sql",
        "cg_table": "agg_week_prev_track_cg_teams_results",
        "cgm_table": "agg_week_prev_track_cgm_teams_results",
        "abbr_cg": "awptcgtr",
        "abbr_cgm": "awptcgmtr",
        "entity_col": "team_id",
        "entity_alias": "crrt",
        "entity_cte": "current_race_results_teams",
        "is_types": False,
    },
    {
        "source_table": "agg_week_prev_track_types_cars_drivers_results",
        "source_sp": "6033-create_load_agg_week_prev_track_types_cars_drivers_results_stored_procedure.sql",
        "cg_table": "agg_week_prev_track_types_cg_cars_drivers_results",
        "cgm_table": "agg_week_prev_track_types_cgm_cars_drivers_results",
        "abbr_cg": "awpttcgcdr",
        "abbr_cgm": "awpttcgmcdr",
        "entity_col": "car_driver_id",
        "entity_alias": "crrcd",
        "entity_cte": "current_race_results_cars_drivers",
        "is_types": True,
    },
    {
        "source_table": "agg_week_prev_track_types_cars_results",
        "source_sp": "6034-create_load_agg_week_prev_track_types_cars_results_stored_procedure.sql",
        "cg_table": "agg_week_prev_track_types_cg_cars_results",
        "cgm_table": "agg_week_prev_track_types_cgm_cars_results",
        "abbr_cg": "awpttcgcr",
        "abbr_cgm": "awpttcgmcr",
        "entity_col": "car_id",
        "entity_alias": "crrc",
        "entity_cte": "current_race_results_cars",
        "is_types": True,
    },
    {
        "source_table": "agg_week_prev_track_types_drivers_results",
        "source_sp": "6035-create_load_agg_week_prev_track_types_drivers_results_stored_procedure.sql",
        "cg_table": "agg_week_prev_track_types_cg_drivers_results",
        "cgm_table": "agg_week_prev_track_types_cgm_drivers_results",
        "abbr_cg": "awpttcgdr",
        "abbr_cgm": "awpttcgmdr",
        "entity_col": "driver_id",
        "entity_alias": "crrd",
        "entity_cte": "current_race_results_drivers",
        "is_types": True,
    },
    {
        "source_table": "agg_week_prev_track_types_manufacturers_results",
        "source_sp": "6038-create_load_agg_week_prev_track_types_manufacturers_results_stored_procedure.sql",
        "cg_table": "agg_week_prev_track_types_cg_manufacturers_results",
        "cgm_table": "agg_week_prev_track_types_cgm_manufacturers_results",
        "abbr_cg": "awpttcgmfr",
        "abbr_cgm": "awpttcgmmfr",
        "entity_col": "manufacturer_id",
        "entity_alias": "crrm",
        "entity_cte": "current_race_results_manufacturers",
        "is_types": True,
    },
    {
        "source_table": "agg_week_prev_track_types_teams_results",
        "source_sp": "6036-create_load_agg_week_prev_track_types_teams_results_stored_procedure.sql",
        "cg_table": "agg_week_prev_track_types_cg_teams_results",
        "cgm_table": "agg_week_prev_track_types_cgm_teams_results",
        "abbr_cg": "awpttcgtr",
        "abbr_cgm": "awpttcgmtr",
        "entity_col": "team_id",
        "entity_alias": "crrt",
        "entity_cte": "current_race_results_teams",
        "is_types": True,
    },
]

NEW_TABLES: list[tuple[str, str, str, bool]] = []  # (table, abbr, num, is_cgm)


def make_table(table_name: str, abbr: str, table_num: int, is_cgm: bool, is_types: bool) -> None:
    tpl = (CGM_TYPES_TEMPLATE if is_types else CGM_TRACK_TEMPLATE) if is_cgm else (
        CG_TYPES_TEMPLATE if is_types else CG_TRACK_TEMPLATE
    )
    content = tpl.read_text()
    old_name = re.search(r"CREATE TABLE `([^`]+)`", content).group(1)
    content = content.replace(f"`{old_name}`", f"`{table_name}`", 1)
    path = TABLES / f"{table_num}-create_{table_name}_table.sql"
    path.write_text(content)
    NEW_TABLES.append((table_name, abbr, str(table_num), is_cgm))


def geo_col(is_types: bool) -> tuple[str, str, str]:
    if is_types:
        return "track_type_id", "track_types", "track_type"
    return "track_id", "tracks", "track"


def write_fk_index_uk(
    table: str, abbr: str, fk_start: int, idx_start: int, uk_num: int, is_cgm: bool, is_types: bool
) -> tuple[int, int]:
    gcol, gref, glabel = geo_col(is_types)
    n = fk_start
    fks = [
        ("series_id", "series", "series_id"),
        ("season_id", "seasons", "season_id"),
        ("week_id", "weeks", "week_id"),
        (gcol, gref, gcol),
        ("car_generation_id", "car_generations", "car_generation_id"),
    ]
    if is_cgm:
        fks.append(("car_generation_model_id", "car_generation_models", "car_generation_model_id"))

    for col, ref, suffix in fks:
        (FKS / f"{n}-create_fk_{abbr}_{suffix}_foreign_key_constraint.sql").write_text(
            f"ALTER TABLE `{table}` ADD CONSTRAINT `fk_{abbr}_{suffix}` "
            f"FOREIGN KEY (`{col}`) REFERENCES `{ref}` (`id`) ON DELETE CASCADE;\n"
        )
        n += 1

    i = idx_start
    for col, ref, suffix in fks:
        (IDX / f"{i}-create_fk_{abbr}_{suffix}_index.sql").write_text(
            f"ALTER TABLE `{table}` ADD KEY `fk_{abbr}_{suffix}` (`{col}`);\n"
        )
        i += 1

    entity_col = None
    for src in SOURCES:
        if src["abbr_cg"] == abbr or src["abbr_cgm"] == abbr:
            entity_col = src["entity_col"]
            break
    if entity_col is None:
        raise ValueError(f"unknown abbr {abbr} for unique key generation")
    ent_abbr = {
        "car_driver_id": "cd",
        "car_id": "car",
        "driver_id": "drv",
        "manufacturer_id": "mfr",
        "team_id": "team",
    }[entity_col]
    geo = "sswtt" if is_types else "sswt"
    uk_cols = ["series_id", "season_id", "week_id", gcol, entity_col, "car_generation_id"]
    if is_cgm:
        uk_cols.append("car_generation_model_id")
    uk_name = f"unique_{abbr}_{geo}_{ent_abbr}_cgen"
    if is_cgm:
        uk_name += "_mdl"
    if len(uk_name) > 64:
        raise ValueError(f"unique key name too long: {uk_name} ({len(uk_name)})")
    (UK / f"{uk_num}-create_unique_{abbr}_unique_key_constraint.sql").write_text(
        f"ALTER TABLE `{table}` ADD UNIQUE KEY `{uk_name}` (`{'`,`'.join(uk_cols)}`);\n"
    )
    return n, i


def cg_cte_block(entity_cte: str, entity_alias: str, entity_col: str, is_cgm: bool) -> str:
    cols = f"{entity_alias}.{entity_col}, awr_curr.car_generation_id"
    if is_cgm:
        cols += ", awr_curr.car_generation_model_id"
    join_entity = f"join {entity_cte} {entity_alias} on awr_curr.{entity_col} = {entity_alias}.{entity_col}"
    return f"""    current_race_results_car_generations as (
        select distinct {cols}
        from nascar.agg_week_results awr_curr
        join current_week cw
          on awr_curr.week_id = cw.week_id
         and awr_curr.season_id = cw.season_id
         and awr_curr.series_id = cw.series_id
        {join_entity}
        where awr_curr.deleted_at is null
    )"""


def transform_sp(source_sp_path: Path, cfg: dict, target_table: str, is_cgm: bool, sp_num: int) -> None:
    src_table = cfg["source_table"]
    text = source_sp_path.read_text()
    proc_src = f"load_{src_table}"
    proc_tgt = f"load_{target_table}"

    text = text.replace(proc_src, proc_tgt)
    text = text.replace(f"nascar.{src_table}", f"nascar.{target_table}")
    text = text.replace(f"`{src_table}`", f"`{target_table}`")

    entity_col = cfg["entity_col"]
    entity_alias = cfg["entity_alias"]
    entity_cte = cfg["entity_cte"]
    total_old = re.search(rf"(\w+_total)", text)
    # find entity total from source - car_total, driver_total, etc.
    entity_total_match = re.search(
        rf"count\(\*\) as (\w+_total),\s*\n\s*ROUND\(AVG",
        text,
    )
    entity_total = entity_total_match.group(1) if entity_total_match else "entity_total"

    # Insert CG CTE after entity CTE
    entity_cte_end = text.find(f"    ),\n    agg_week_results as (")
    if entity_cte_end == -1:
        raise ValueError(f"Cannot find agg_week_results CTE in {source_sp_path}")
    cg_block = cg_cte_block(entity_cte, entity_alias, entity_col, is_cgm) + ",\n"
    text = text[:entity_cte_end] + "    ),\n" + cg_block + text[entity_cte_end + len("    ),\n") :]

    # Replace agg_week_results join
    old_join = f"join {entity_cte} {entity_alias} on awr.{entity_col} = {entity_alias}.{entity_col}"
    if is_cgm:
        new_join = (
            "join current_race_results_car_generations crrcg\n"
            "           on awr.car_generation_id = crrcg.car_generation_id\n"
            f"          and awr.{entity_col} = crrcg.{entity_col}\n"
            "          and awr.car_generation_model_id = crrcg.car_generation_model_id"
        )
    else:
        new_join = (
            "join current_race_results_car_generations crrcg\n"
            "           on awr.car_generation_id = crrcg.car_generation_id\n"
            f"          and awr.{entity_col} = crrcg.{entity_col}"
        )
    text = text.replace(old_join, new_join)

    # INSERT column list: replace entity cols with generation cols
    if is_cgm:
        text = re.sub(
            rf"        {entity_col},\n        {entity_total},",
            "        car_generation_id,\n        car_generation_model_id,\n        car_generation_model_total,",
            text,
            count=1,
        )
    else:
        text = re.sub(
            rf"        {entity_col},\n        {entity_total},",
            "        car_generation_id,\n        car_generation_total,",
            text,
            count=1,
        )

    # SELECT list
    if is_cgm:
        text = re.sub(
            rf"        awr\.{entity_col},\n        count\(\*\) as {entity_total},",
            "        awr.car_generation_id,\n        awr.car_generation_model_id,\n        count(*) as car_generation_model_total,",
            text,
            count=1,
        )
        text = re.sub(
            rf"group by cw\.series_id, cw\.season_id, cw\.week_id, cw\.(track_id|track_type_id), awr\.{entity_col}",
            "group by cw.series_id, cw.season_id, cw.week_id, cw.\\1, awr.car_generation_id, awr.car_generation_model_id",
            text,
            count=1,
        )
    else:
        text = re.sub(
            rf"        awr\.{entity_col},\n        count\(\*\) as {entity_total},",
            "        awr.car_generation_id,\n        count(*) as car_generation_total,",
            text,
            count=1,
        )
        text = re.sub(
            rf"group by cw\.series_id, cw\.season_id, cw\.week_id, cw\.(track_id|track_type_id), awr\.{entity_col}",
            "group by cw.series_id, cw.season_id, cw.week_id, cw.\\1, awr.car_generation_id",
            text,
            count=1,
        )

    grain = "car generation model" if is_cgm else "car generation"
    text = re.sub(
        r"COMMENT '[^']*'",
        f"COMMENT 'Aggregate prior-track-type {grain}-level stats for a race week into {target_table}.'"
        if cfg["is_types"]
        else f"COMMENT 'Aggregate prior-track {grain}-level stats for a race week into {target_table}.'",
        text,
        count=1,
    )

    out = SP / f"{sp_num}-create_{proc_tgt}_stored_procedure.sql"
    out.write_text(text)


def manufacturers_sp(track: bool, sp_num: int) -> None:
    teams_file = (
        "6025-create_load_agg_week_prev_track_teams_results_stored_procedure.sql"
        if track
        else "6036-create_load_agg_week_prev_track_types_teams_results_stored_procedure.sql"
    )
    teams = (SP / teams_file).read_text()
    table = (
        "agg_week_prev_track_manufacturers_results"
        if track
        else "agg_week_prev_track_types_manufacturers_results"
    )
    teams_table = (
        "agg_week_prev_track_teams_results"
        if track
        else "agg_week_prev_track_types_teams_results"
    )
    proc = f"load_{table}"
    text = teams.replace(f"load_{teams_table}", proc)
    text = text.replace(teams_table, table)
    text = text.replace("team-level", "manufacturer-level")
    text = text.replace("current_race_results_teams", "current_race_results_manufacturers")
    text = text.replace(
        "join nascar.teams t on c.team_id = t.id and t.deleted_at is null",
        "join nascar.manufacturers m on c.manufacturer_id = m.id and m.deleted_at is null",
    )
    text = text.replace("t.id as team_id", "m.id as manufacturer_id")
    text = text.replace("team_id", "manufacturer_id")
    text = text.replace("team_total", "manufacturer_total")
    text = text.replace("crrt", "crrm")
    if not track:
        pass  # already types
    (SP / f"{sp_num}-create_{proc}_stored_procedure.sql").write_text(text)


def patch_triggers() -> None:
    track_tables = [t[0] for t in NEW_TABLES if "prev_track_types_" not in t[0]]
    types_tables = [t[0] for t in NEW_TABLES if "prev_track_types_" in t[0]]

    def add_updates(text: str, tables: list[str], col: str) -> str:
        if not tables or tables[0] in text:
            return text
        soft_del = [
            f"        UPDATE `nascar`.`{tbl}` SET `deleted_at` = NEW.`deleted_at` "
            f"WHERE `{col}` = NEW.`id` AND `deleted_at` IS NULL;"
            for tbl in tables
        ]
        restore = [
            f"        UPDATE `nascar`.`{tbl}` SET `deleted_at` = NULL "
            f"WHERE `{col}` = NEW.`id` AND `deleted_at` IS NOT NULL;"
            for tbl in tables
        ]
        marker = "    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN"
        text = text.replace(marker, "\n".join(soft_del) + "\n" + marker, 1)
        end = "    END IF;"
        text = text.replace(end, "\n".join(restore) + "\n" + end, 1)
        return text

    for path, col, tables in [
        (TRIGGERS / "4010-create_trg_series_soft_delete_cascade_agg_week_results_trigger.sql", "series_id", track_tables + types_tables),
        (TRIGGERS / "4009-create_trg_seasons_soft_delete_cascade_agg_week_results_trigger.sql", "season_id", track_tables + types_tables),
        (TRIGGERS / "4014-create_trg_weeks_soft_delete_cascade_agg_week_results_trigger.sql", "week_id", track_tables + types_tables),
        (TRIGGERS / "4012-create_trg_tracks_soft_delete_cascade_agg_week_results_trigger.sql", "track_id", track_tables),
        (TRIGGERS / "4013-create_trg_track_types_soft_delete_cascade_trigger.sql", "track_type_id", types_tables),
        (TRIGGERS / "4015-create_trg_car_generations_soft_delete_cascade_car_generations_seasons_trigger.sql", "car_generation_id", track_tables + types_tables),
        (TRIGGERS / "4017-create_trg_car_generation_models_soft_delete_cascade_car_generation_models_seasons_trigger.sql", "car_generation_model_id", [t for t in track_tables + types_tables if "cgm_" in t]),
    ]:
        path.write_text(add_updates(path.read_text(), tables, col))


def main() -> None:
    manufacturers_sp(track=True, sp_num=6037)
    manufacturers_sp(track=False, sp_num=6038)

    table_num = 1050
    fk_num = 2147
    idx_num = 8137
    uk_num = 3046
    sp_num = 6039

    for cfg in SOURCES:
        for is_cgm, suffix, tkey in [(False, "cg", "cg_table"), (True, "cgm", "cgm_table")]:
            table = cfg[tkey]
            abbr = cfg["abbr_cg" if not is_cgm else "abbr_cgm"]
            make_table(table, abbr, table_num, is_cgm, cfg["is_types"])
            fk_num, idx_num = write_fk_index_uk(table, abbr, fk_num, idx_num, uk_num, is_cgm, cfg["is_types"])
            uk_num += 1
            table_num += 1

    for cfg in SOURCES:
        sp_path = SP / cfg["source_sp"]
        for is_cgm, tkey in [(False, "cg_table"), (True, "cgm_table")]:
            transform_sp(sp_path, cfg, cfg[tkey], is_cgm, sp_num)
            sp_num += 1

    patch_triggers()
    print(f"Generated {len(NEW_TABLES)} tables, SPs through {sp_num - 1}, FK from 2147")


if __name__ == "__main__":
    main()
