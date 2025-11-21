BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "mock_country_data" (
    "id" bigserial PRIMARY KEY,
    "countryName" text NOT NULL,
    "isoCode" text NOT NULL,
    "isEuMember" boolean NOT NULL,
    "isNatoMember" boolean NOT NULL
);


--
-- MIGRATION VERSION FOR my_rag_project
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('my_rag_project', '20251121092631254', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251121092631254', "timestamp" = now();

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
