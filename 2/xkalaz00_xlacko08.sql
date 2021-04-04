---------------------------------
-- IDS - Project part 2
-- Bug Tracker
-- xkalaz00, xlacko08
---------------------------------

DROP TABLE "bug";
DROP TABLE "language";
DROP TABLE "module";
DROP TABLE "patch";
DROP TABLE "ticket";
DROP TABLE "user" CASCADE CONSTRAINTS;

CREATE TABLE "bug"(
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "description" VARCHAR(1023) NOT NULL,
    "vulnerability" VARCHAR(10) CHECK( "vulnerability" IN ('minor', 'major', 'critical') ),
    "fixed" CHAR(1) DEFAULT '0' CHECK( "fixed" IN ('0', '1') ) NOT NULL,
    "reward" DECIMAL(8,2) DEFAULT 0.0 NOT NULL
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
    "created_by" INT NOT NULL,
    "approved_by" INT
);

CREATE TABLE "ticket"(
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "title" VARCHAR(80) NOT NULL,
    "description" VARCHAR(1023) NOT NULL,
    "severity" VARCHAR(10) DEFAULT 'low' CHECK( "severity" IN ('low', 'minor', 'major', 'critical') ) NOT NULL,
    "status" VARCHAR(10) DEFAULT 'pending' CHECK( "status" IN  ('pending', 'open', 'closed') ) NOT NULL,
    "created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "user"(
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "username" VARCHAR(80) NOT NULL,
    "name" VARCHAR(80),
    "date_of_birth" DATE NOT NULL,
    "address_country" VARCHAR(80),
    "address_city" VARCHAR(255),
    "address_postal_code" VARCHAR(10),
    "address_street" VARCHAR(255),
    "email" VARCHAR(255) CHECK(REGEXP_LIKE("email", '^[A-Z0-9._%-]+@[A-Z0-9._%-]+\.[A-Z]{2,4}$', 'i')),
    "type" VARCHAR(10) DEFAULT 'user' CHECK( "type" IN ('user', 'programmer', 'admin') ) NOT NULL
);

ALTER TABLE "patch"
    ADD CONSTRAINT "created_by_fk"
    FOREIGN KEY ("created_by")
    REFERENCES "user"("id") ON DELETE SET NULL;