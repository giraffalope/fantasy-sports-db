START TRANSACTION;

DROP TEMPORARY TABLE IF EXISTS tmp_null_team_car_dupe_map;

CREATE TEMPORARY TABLE tmp_null_team_car_dupe_map AS
SELECT
    d.id AS duplicate_car_id,
    k.canonical_car_id
FROM nascar.cars d
JOIN (
    SELECT
        c.number,
        c.manufacturer_id,
        MIN(c.id) AS canonical_car_id
    FROM nascar.cars c
    WHERE c.deleted_at IS NULL
      AND c.team_id IS NULL
    GROUP BY c.number, c.manufacturer_id
    HAVING COUNT(*) > 1
) k
    ON k.number = d.number
   AND k.manufacturer_id <=> d.manufacturer_id
WHERE d.deleted_at IS NULL
  AND d.team_id IS NULL
  AND d.id <> k.canonical_car_id;

-- Copy active car-driver links from duplicate cars to canonical cars.
INSERT IGNORE INTO nascar.cars_drivers (car_id, driver_id)
SELECT
    m.canonical_car_id,
    cd.driver_id
FROM nascar.cars_drivers cd
JOIN tmp_null_team_car_dupe_map m
    ON m.duplicate_car_id = cd.car_id
WHERE cd.deleted_at IS NULL;

-- Soft-delete duplicate car-driver links that still point at duplicate cars.
UPDATE nascar.cars_drivers cd
JOIN tmp_null_team_car_dupe_map m
    ON m.duplicate_car_id = cd.car_id
SET cd.deleted_at = COALESCE(cd.deleted_at, CURRENT_TIMESTAMP);

-- Soft-delete duplicate null-team car rows.
UPDATE nascar.cars c
JOIN tmp_null_team_car_dupe_map m
    ON m.duplicate_car_id = c.id
SET c.deleted_at = COALESCE(c.deleted_at, CURRENT_TIMESTAMP);

COMMIT;
