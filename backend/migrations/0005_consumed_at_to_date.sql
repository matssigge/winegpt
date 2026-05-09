ALTER TABLE wine_entries
    ALTER COLUMN consumed_at TYPE DATE USING consumed_at::DATE;
