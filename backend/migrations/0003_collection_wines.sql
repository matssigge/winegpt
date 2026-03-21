CREATE TABLE collection_wines (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    collection_id BIGINT NOT NULL REFERENCES collections (id) ON DELETE CASCADE,
    wine_id BIGINT NOT NULL REFERENCES wines (id) ON DELETE RESTRICT,
    created_by_user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (collection_id, wine_id)
);
