-- Salary is joined at lineup time, not during ML snapshot build.

ALTER TABLE `ml_training_rows` DROP COLUMN `salary`;
