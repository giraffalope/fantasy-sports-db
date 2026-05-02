CREATE TABLE `car_generation_models_seasons` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `car_generations_seasons_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to nascar.car_generations_seasons.',
  `manufacturer_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to nascar.manufacturers.',
  `car_generation_model_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to nascar.car_generation_models.',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Bridge between car generation seasons, manufacturers, and canonical car_generation_models.';
