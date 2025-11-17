BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "chat_message" (
    "id" bigserial PRIMARY KEY,
    "message" text NOT NULL,
    "type" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "chatSessionId" bigint NOT NULL
);

-- Indexes
CREATE INDEX "chat_message_session_id_idx" ON "chat_message" USING btree ("chatSessionId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "chat_session" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint,
    "keyToken" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "chat_session_key_token_idx" ON "chat_session" USING btree ("keyToken");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "chat_message"
    ADD CONSTRAINT "chat_message_fk_0"
    FOREIGN KEY("chatSessionId")
    REFERENCES "chat_session"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR my_rag_project
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('my_rag_project', '20251117152549838', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251117152549838', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
