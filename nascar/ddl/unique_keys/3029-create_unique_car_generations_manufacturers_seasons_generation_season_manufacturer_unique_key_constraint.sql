ALTER TABLE `car_generation_models_seasons` ADD UNIQUE KEY `unique_cgms_cgs_manufacturer_model` (`car_generations_seasons_id`,`manufacturer_id`,`car_generation_model_id`);
