-- Default charset for new objects. Existing DBs created without this: run
-- ALTER DATABASE `nascar` CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci;
CREATE OR REPLACE DATABASE `nascar`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_uca1400_ai_ci;
