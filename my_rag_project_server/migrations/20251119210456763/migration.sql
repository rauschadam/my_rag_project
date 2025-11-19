BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "list_panel_suplier_data" (
    "id" bigserial PRIMARY KEY,
    "vendorName" text NOT NULL,
    "countryCode" text NOT NULL,
    "category" text NOT NULL,
    "amount" text NOT NULL,
    "lastActivity" timestamp without time zone NOT NULL
);


--
-- MIGRATION VERSION FOR my_rag_project
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('my_rag_project', '20251119210456763', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251119210456763', "timestamp" = now();

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
