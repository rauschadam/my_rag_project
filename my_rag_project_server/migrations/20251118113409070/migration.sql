BEGIN;

--
-- CREATE VECTOR EXTENSION IF AVAILABLE
--
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'vector') THEN
    EXECUTE 'CREATE EXTENSION IF NOT EXISTS vector';
  ELSE
    RAISE EXCEPTION 'Required extension "vector" is not available on this instance. Please install pgvector. For instructions, see https://docs.serverpod.dev/upgrading/upgrade-to-pgvector.';
  END IF;
END
$$;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "list_panel_column_description" (
    "id" bigserial PRIMARY KEY,
    "distributionId" bigint NOT NULL,
    "fieldNameEng" text NOT NULL,
    "fieldNameHun" text NOT NULL,
    "descriptionHun" text NOT NULL,
    "businessDescriptionHun" text NOT NULL,
    "embedding" vector(768) NOT NULL
);

-- Indexes
CREATE INDEX "list_panel_column_embedding_idx" ON "list_panel_column_description" USING hnsw ("embedding" vector_cosine_ops);
CREATE INDEX "list_panel_column_dist_id_idx" ON "list_panel_column_description" USING btree ("distributionId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "list_panel_table_description" (
    "id" bigserial PRIMARY KEY,
    "distributionId" bigint NOT NULL,
    "nameHun" text NOT NULL,
    "descriptionHun" text NOT NULL,
    "businessDescriptionHun" text NOT NULL,
    "embedding" vector(768) NOT NULL
);

-- Indexes
CREATE INDEX "list_panel_table_embedding_idx" ON "list_panel_table_description" USING hnsw ("embedding" vector_cosine_ops);


--
-- MIGRATION VERSION FOR my_rag_project
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('my_rag_project', '20251118113409070', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251118113409070', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth', '20240520102713718', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240520102713718', "timestamp" = now();


COMMIT;
