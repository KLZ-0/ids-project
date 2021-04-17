---------------------------------
-- IDS - Project part 3
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
    "created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "production" TIMESTAMP DEFAULT NULL,
    "approved" CHAR(1) DEFAULT '0' CHECK( "approved" IN ('0', '1') ) NOT NULL,
    "created_by" INT NOT NULL
);

CREATE TABLE "ticket"(
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
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



INSERT INTO "user"("name", "date_of_birth", "email", "type")
    VALUES('admin', TO_DATE('04-04-1977', 'dd/mm/yyyy'), 'admin@fake.co', 'admin');
INSERT INTO "user"("name", "date_of_birth", "email", "type")
    VALUES('programmer1', TO_DATE('04-04-1977', 'dd/mm/yyyy'), 'programmer1@fake.co', 'programmer');
INSERT INTO "user"("name", "date_of_birth", "address_country", "address_city", "address_street", "email", "type")
    VALUES('user1', TO_DATE('04-04-1977', 'dd/mm/yyyy'), 'hungary', 'nitra', 'purkynova 12', 'user1@fake.co', 'user');

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

INSERT INTO "ticket"("title", "description", "created_by")
    VALUES('bug report', 'found two bugs in the Main and GUI modules', 3);

INSERT INTO "ticket"("title", "description", "created_by", "status")
    VALUES('bug report 2', 'found bug3', 2, 'open');

INSERT INTO "ticket_references_bug"("ticket", "bug") VALUES(1, 1);
INSERT INTO "ticket_references_bug"("ticket", "bug") VALUES(1, 2);
INSERT INTO "ticket_references_bug"("ticket", "bug") VALUES(2, 3);

INSERT INTO "bug_in_module"("bug", "module") VALUES(1,1);
INSERT INTO "bug_in_module"("bug", "module") VALUES(2,2);
INSERT INTO "bug_in_module"("bug", "module") VALUES(3,1);

INSERT INTO "patch"("description", "created_by") VALUES('patch for bug1 and bug2', 3);
INSERT INTO "patch"("description", "created_by", "approved") VALUES('patch for bug3', 2, '1');

INSERT INTO "patch_approved_by"("patch", "user") VALUES(2, 2);

INSERT INTO "patch_for_module"("patch", "module") VALUES(1, 1);
INSERT INTO "patch_for_module"("patch", "module") VALUES(1, 2);
INSERT INTO "patch_for_module"("patch", "module") VALUES(2, 1);

UPDATE "bug" SET "referenced_in_patch" = 2 WHERE "id" = 3;

--- select

-- 2 tables
-- Not yet approved patches created by casual users
SELECT
       p."description" AS "patch_description",
       u."name" AS "author"
FROM "patch" p
    JOIN "user" u on u."id" = p."created_by"
WHERE u."type" = 'user'
ORDER BY p."created";

-- 2 tables
-- All bugs and in which patch were they referenced
SELECT
       b."description" AS "bug",
       p."description" AS "referencing patch"
FROM "bug" b
    JOIN "patch" p on p."id" = b."referenced_in_patch"
ORDER BY p."created";

-- 3 tables
-- Bugs related to a specific ticket
SELECT
       t."title" AS "ticket",
       b."description" AS "bug",
       b."fixed"
FROM "ticket" t
    JOIN "ticket_references_bug" trb on t."id" = trb."ticket"
    JOIN "bug" b on b."id" = trb."bug"
WHERE t."id" = 1
ORDER BY b."vulnerability";

-- 3 tables
-- Users who know Python
SELECT
    u."name"
FROM "user" u
    JOIN "user_knows_language" ukl on u."id" = ukl."user"
    JOIN "language" l on ukl."language" = l."id"
WHERE l."name" = 'Python'
ORDER BY u."id";

-- GROUP BY with aggregate function
-- Modules with more than one bug
SELECT
       m."description",
       COUNT(bim."bug") AS "bugs"
FROM "module" m
    JOIN "bug_in_module" bim on m."id" = bim."module"
GROUP BY m."id", m."description"
HAVING COUNT(bim."bug") > 1
ORDER BY COUNT(bim."bug") DESC;
