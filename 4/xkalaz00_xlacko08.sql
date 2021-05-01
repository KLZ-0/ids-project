---------------------------------
-- IDS - Project part 4
-- Bug Tracker
-- xkalaz00, xlacko08
---------------------------------

DROP TABLE "patch_approved_by";
DROP TABLE "patch_for_module";
DROP TABLE "bug_in_module";
DROP TABLE "ticket_references_bug";
DROP TABLE "user_knows_language";
DROP TABLE "module_in_language";
DROP TABLE "user_responsible_for_module";

DROP TABLE "bug";
DROP TABLE "language";
DROP TABLE "module";
DROP TABLE "patch" CASCADE CONSTRAINTS;
DROP TABLE "ticket";
DROP TABLE "user" CASCADE CONSTRAINTS;

DROP SEQUENCE "ticket_seq";

DROP MATERIALIZED VIEW "view_tickets";

CREATE TABLE "bug"(
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "description" VARCHAR(1023) NOT NULL,
    "vulnerability" VARCHAR(10) CHECK( "vulnerability" IN ('minor', 'major', 'critical') ),
    "fixed" CHAR(1) DEFAULT '0' CHECK( "fixed" IN ('0', '1') ) NOT NULL,
    "reward" DECIMAL(8,2) DEFAULT 0.0 NOT NULL,
    "referenced_in_patch" INT
);

CREATE TABLE "language" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "name" VARCHAR(80) NOT NULL
);

CREATE TABLE "module"(
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "description" VARCHAR(1023) NOT NULL
);

CREATE TABLE "patch"(
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "description" VARCHAR(1023) NOT NULL,
    "created" TIMESTAMP DEFAULT NULL,
    "production" TIMESTAMP DEFAULT NULL,
    "approved" CHAR(1) DEFAULT '0' CHECK( "approved" IN ('0', '1') ) NOT NULL,
    "created_by" INT NOT NULL
);

CREATE TABLE "ticket"(
    "id" INT DEFAULT NULL PRIMARY KEY,
    "title" VARCHAR(80) NOT NULL,
    "description" VARCHAR(1023) NOT NULL,
    "severity" VARCHAR(10) DEFAULT 'low' CHECK( "severity" IN ('low', 'minor', 'major', 'critical') ) NOT NULL,
    "status" VARCHAR(10) DEFAULT 'pending' CHECK( "status" IN  ('pending', 'open', 'closed') ) NOT NULL,
    "created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "created_by" INT NOT NULL
);

CREATE TABLE "user"(
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "name" VARCHAR(80) NOT NULL,
    "date_of_birth" DATE NOT NULL,
    "address_country" VARCHAR(80),
    "address_city" VARCHAR(255),
    "address_postal_code" VARCHAR(10),
    "address_street" VARCHAR(255),
    "email" VARCHAR(255) CHECK(REGEXP_LIKE("email", '^[A-Z0-9._%-]+@[A-Z0-9._%-]+\.[A-Z]{2,4}$', 'i')) NOT NULL,
    "type" VARCHAR(10) DEFAULT 'user' CHECK( "type" IN ('user', 'programmer', 'admin') ) NOT NULL
);

CREATE TABLE "patch_approved_by" (
    "user" INT NOT NULL,
    "patch" INT NOT NULL,
    CONSTRAINT "patch_approved_by.id" PRIMARY KEY ("user", "patch"),
    CONSTRAINT "patch_approved_by.user_fk" FOREIGN KEY ("user") REFERENCES "user"("id") ON DELETE CASCADE,
    CONSTRAINT "patch_approved_by.patch_fk" FOREIGN KEY ("patch") REFERENCES "patch"("id") ON DELETE CASCADE
);

CREATE TABLE "patch_for_module"(
    "module" INT NOT NULL,
    "patch" INT NOT NULL,
    CONSTRAINT "patch_for_module.id" PRIMARY KEY ("module", "patch"),
    CONSTRAINT "patch_for_module.module_fk" FOREIGN KEY ("module") REFERENCES "module"("id") ON DELETE CASCADE,
    CONSTRAINT "patch_for_module.patch_fk" FOREIGN KEY ("patch") REFERENCES "patch"("id") ON DELETE CASCADE
);

CREATE TABLE "bug_in_module"(
    "module" INT NOT NULL,
    "bug" INT NOT NULL,
    CONSTRAINT "bug_in_module.id" PRIMARY KEY ("module", "bug"),
    CONSTRAINT "bug_in_module.module_fk" FOREIGN KEY ("module") REFERENCES "module"("id") ON DELETE CASCADE,
    CONSTRAINT "bug_in_module.bug_fk" FOREIGN KEY ("bug") REFERENCES "bug"("id") ON DELETE CASCADE
);

CREATE TABLE "ticket_references_bug"(
    "ticket" INT NOT NULL,
    "bug" INT NOT NULL,
    CONSTRAINT "ticket_references_bug.id" PRIMARY KEY ("ticket", "bug"),
    CONSTRAINT "ticket_references_bug.ticket_fk" FOREIGN KEY ("ticket") REFERENCES "ticket"("id") ON DELETE CASCADE,
    CONSTRAINT "ticket_references_bug.bug_fk" FOREIGN KEY ("bug") REFERENCES "bug"("id") ON DELETE CASCADE
);

CREATE TABLE "user_knows_language"(
    "user" INT NOT NULL,
    "language" INT NOT NULL,
    CONSTRAINT "user_knows_language.id" PRIMARY KEY ("user", "language"),
    CONSTRAINT "user_knows_language.user_fk" FOREIGN KEY ("user") REFERENCES "user"("id") ON DELETE CASCADE,
    CONSTRAINT "user_knows_language.language_fk" FOREIGN KEY ("language") REFERENCES "language"("id") ON DELETE CASCADE
);

CREATE TABLE "module_in_language"(
    "module" INT NOT NULL,
    "language" INT NOT NULL,
    CONSTRAINT "module_in_language.id" PRIMARY KEY ("module", "language"),
    CONSTRAINT "module_in_language.module_fk" FOREIGN KEY ("module") REFERENCES "module"("id") ON DELETE CASCADE,
    CONSTRAINT "module_in_language.language_fk" FOREIGN KEY ("language") REFERENCES "language"("id") ON DELETE CASCADE
);

CREATE TABLE "user_responsible_for_module"(
    "user" INT NOT NULL,
    "module" INT NOT NULL,
    CONSTRAINT "user_responsible_for_module.id" PRIMARY KEY ("user", "module"),
    CONSTRAINT "user_responsible_for_module.user_fk" FOREIGN KEY ("user") REFERENCES "user"("id") ON DELETE CASCADE,
    CONSTRAINT "user_responsible_for_module.module_fk" FOREIGN KEY ("module") REFERENCES "module"("id") ON DELETE CASCADE
);

ALTER TABLE "patch"
    ADD CONSTRAINT "patch.created_by_fk"
    FOREIGN KEY ("created_by")
    REFERENCES "user"("id") ON DELETE SET NULL;

ALTER TABLE "bug"
    ADD CONSTRAINT "bug.referenced_in_patch_fk"
    FOREIGN KEY ("referenced_in_patch")
    REFERENCES "patch"("id") ON DELETE SET NULL;

ALTER TABLE "ticket"
    ADD CONSTRAINT "ticket.created_by_fk"
    FOREIGN KEY ("created_by")
    REFERENCES "user"("id") ON DELETE SET NULL;

--- Triggers

-- generate primary key for ticket
CREATE SEQUENCE "ticket_seq";
CREATE OR REPLACE TRIGGER "ticket_id_gen" BEFORE INSERT ON "ticket"
FOR EACH ROW
BEGIN
    IF :NEW."id" IS NULL THEN
        :NEW."id" := "ticket_seq".NEXTVAL;
    END IF;
END;

-- generate creation timestamp for patch
CREATE OR REPLACE TRIGGER "patch_created_gen" BEFORE INSERT ON "patch"
FOR EACH ROW
BEGIN
    IF :NEW."created" IS NULL THEN
        :NEW."created" := CURRENT_TIMESTAMP;
    END IF;
END;

--- Procedures

-- TODO

--- Insert + trigger usage

INSERT INTO "user"("name", "date_of_birth", "email", "type")
    VALUES('admin', TO_DATE('04-04-1977', 'dd/mm/yyyy'), 'admin@fake.co', 'admin');
INSERT INTO "user"("name", "date_of_birth", "email", "type")
    VALUES('programmer1', TO_DATE('04-04-1977', 'dd/mm/yyyy'), 'programmer1@fake.co', 'programmer');
INSERT INTO "user"("name", "date_of_birth", "address_country", "address_city", "address_street", "email", "type")
    VALUES('user1', TO_DATE('04-04-1977', 'dd/mm/yyyy'), 'hungary', 'nitra', 'purkynova 12', 'user1@fake.co', 'user');
INSERT INTO "user"("name", "date_of_birth", "email", "type")
    VALUES('programmer2', TO_DATE('04-04-1977', 'dd/mm/yyyy'), 'programmer2@fake.co', 'programmer');

INSERT INTO "language"("name") VALUES('C++');
INSERT INTO "language"("name") VALUES('Python');

INSERT INTO "user_knows_language"("user", "language") VALUES(2, 1);
INSERT INTO "user_knows_language"("user", "language") VALUES(2, 2);
INSERT INTO "user_knows_language"("user", "language") VALUES(3, 2);

INSERT INTO "module"("description") VALUES('Main module');
INSERT INTO "module"("description") VALUES('GUI module');
INSERT INTO "module"("description") VALUES('Utils');

INSERT INTO "user_responsible_for_module"("user", "module") VALUES(2, 1);
INSERT INTO "user_responsible_for_module"("user", "module") VALUES(2, 2);
INSERT INTO "user_responsible_for_module"("user", "module") VALUES(2, 3);

INSERT INTO "module_in_language"("module", "language") VALUES(1, 1);
INSERT INTO "module_in_language"("module", "language") VALUES(2, 2);
INSERT INTO "module_in_language"("module", "language") VALUES(3, 2);

INSERT INTO "bug"("description") VALUES('bug1');
INSERT INTO "bug"("description") VALUES('bug2');
INSERT INTO "bug"("description", "vulnerability") VALUES('bug3', 'major');

-- Trigger 1 -> auto-increments ids for the inserted tickets
-- id 1
INSERT INTO "ticket"("title", "description", "created_by")
    VALUES('bug report', 'found two bugs in the Main and GUI modules', 3);

-- id 2
INSERT INTO "ticket"("title", "description", "created_by", "status")
    VALUES('bug report 2', 'found bug3', 2, 'open');

-- Trigger 1 PK values
SELECT "id", "title" FROM "ticket" ORDER BY "id";

INSERT INTO "ticket_references_bug"("ticket", "bug") VALUES(1, 1);
INSERT INTO "ticket_references_bug"("ticket", "bug") VALUES(1, 2);
INSERT INTO "ticket_references_bug"("ticket", "bug") VALUES(2, 3);

INSERT INTO "bug_in_module"("bug", "module") VALUES(1,1);
INSERT INTO "bug_in_module"("bug", "module") VALUES(2,2);
INSERT INTO "bug_in_module"("bug", "module") VALUES(3,1);

-- Trigger 2 -> generate creation timestamp for the inserted patches
INSERT INTO "patch"("description", "created_by") VALUES('patch for bug1 and bug2', 3);
INSERT INTO "patch"("description", "created_by", "approved") VALUES('patch for bug3', 2, '1');

-- Trigger 2 creation timestamp values
SELECT "description", "created" FROM "patch" ORDER BY "id";

INSERT INTO "patch_approved_by"("patch", "user") VALUES(2, 2);

INSERT INTO "patch_for_module"("patch", "module") VALUES(1, 1);
INSERT INTO "patch_for_module"("patch", "module") VALUES(1, 2);
INSERT INTO "patch_for_module"("patch", "module") VALUES(2, 1);

UPDATE "bug" SET "referenced_in_patch" = 2 WHERE "id" = 3;
UPDATE "bug" SET "fixed" = 1 WHERE "id" = 3;

------------------------------
----- DATABASE POPULATED -----
------------------------------

--- Procedure usage

-- TODO

--- Explain plan

-- join two tables
-- group by with aggregate function
-- Non-approved patches which touch more than one module
EXPLAIN PLAN FOR
SELECT
       p."description" AS "patch",
       COUNT(pfm."module") AS "modules touched"
FROM "patch" p
    join "patch_for_module" pfm on p."id" = pfm."patch"
WHERE p."approved" = '0'
GROUP BY p."id", p."description"
HAVING COUNT(pfm."module") > 1
ORDER BY COUNT(pfm."module") DESC;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- create index for "approved"
CREATE INDEX "index_approved" ON "patch" ("approved");

-- re-explain plan
EXPLAIN PLAN FOR
SELECT
       p."description" AS "patch",
       COUNT(pfm."module") AS "modules touched"
FROM "patch" p
    join "patch_for_module" pfm on p."id" = pfm."patch"
WHERE p."approved" = '0'
GROUP BY p."id", p."description"
HAVING COUNT(pfm."module") > 1
ORDER BY COUNT(pfm."module") DESC;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--- Materialized view

-- materialized view of all tickets ordered by their status
CREATE MATERIALIZED VIEW "view_tickets" AS
SELECT
    t."id",
    t."title",
    t."description",
    t."status",
    u."name" AS "created_by"
FROM "ticket" t
    join "user" u on t."created_by" = u."id"
ORDER BY "status";

--- Privileges

GRANT ALL ON "bug" TO XLACKO08;
GRANT ALL ON "language" TO XLACKO08;
GRANT ALL ON "module" TO XLACKO08;
GRANT ALL ON "patch" TO XLACKO08;
GRANT ALL ON "ticket" TO XLACKO08;
GRANT ALL ON "user" TO XLACKO08;
GRANT ALL ON "patch_approved_by" TO XLACKO08;
GRANT ALL ON "patch_for_module" TO XLACKO08;
GRANT ALL ON "bug_in_module" TO XLACKO08;
GRANT ALL ON "ticket_references_bug" TO XLACKO08;
GRANT ALL ON "user_knows_language" TO XLACKO08;
GRANT ALL ON "module_in_language" TO XLACKO08;
GRANT ALL ON "user_responsible_for_module" TO XLACKO08;

-- TODO: Add privileges for procedures

GRANT ALL ON "view_tickets" TO XLACKO08;

--- Materialized view usage

-- Display the view
SELECT * FROM "view_tickets";
