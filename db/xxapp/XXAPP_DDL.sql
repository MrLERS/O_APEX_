-- =============================================================================
-- XXAPP Schema - Application Manager
-- Project  : Oracle APEX Practice Environment
-- Prefix   : XXAPP
-- Suffixes : _SEQ (sequences), _TRG (triggers), _PKG (packages)
-- =============================================================================
-- Audit columns included in all tables:
--   CREATED_BY, CREATED_DATE, UPDATED_BY, UPDATED_DATE
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. XXAPP_APPS
--    Master catalog of registered applications
-- -----------------------------------------------------------------------------
CREATE TABLE XXAPP_APPS (
    APP_ID          NUMBER          NOT NULL,
    APP_CODE        VARCHAR2(50)    NOT NULL,   -- Short internal identifier (e.g. 'XXLAB')
    APP_NAME        VARCHAR2(200)   NOT NULL,   -- Display name
    APP_APEX_ID     NUMBER,                     -- Oracle APEX application ID
    APP_URL         VARCHAR2(500),              -- Base URL for SSO redirect
    IS_ENABLED       VARCHAR2(1)     DEFAULT 'Y' NOT NULL,
    DESCRIPTION     VARCHAR2(1000),
    -- Audit
    CREATED_BY      VARCHAR2(100)   NOT NULL,
    CREATED_DATE    DATE            DEFAULT SYSDATE NOT NULL,
    UPDATED_BY      VARCHAR2(100),
    UPDATED_DATE    DATE,
    -- Constraints
    CONSTRAINT XXAPP_APPS_PK        PRIMARY KEY (APP_ID),
    CONSTRAINT XXAPP_APPS_CODE_UK   UNIQUE      (APP_CODE),
    CONSTRAINT XXAPP_APPS_ACTIVE_CK CHECK       (IS_ENABLED IN ('Y','N'))
);

CREATE SEQUENCE XXAPP_APPS_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE OR REPLACE TRIGGER XXAPP_APPS_TRG
    BEFORE INSERT OR UPDATE ON XXAPP_APPS
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        IF :NEW.APP_ID IS NULL THEN
            :NEW.APP_ID := XXAPP_APPS_SEQ.NEXTVAL;
        END IF;
        :NEW.CREATED_BY   := NVL(:NEW.CREATED_BY, NVL(V('APP_USER'), USER));
        :NEW.CREATED_DATE := NVL(:NEW.CREATED_DATE, SYSDATE);
    END IF;
    IF UPDATING THEN
        :NEW.UPDATED_BY   := NVL(V('APP_USER'), USER);
        :NEW.UPDATED_DATE := SYSDATE;
    END IF;
END XXAPP_APPS_TRG;
/


-- -----------------------------------------------------------------------------
-- 2. XXAPP_USERS
--    System users (simulates a user directory in a single-schema environment)
-- -----------------------------------------------------------------------------
CREATE TABLE XXAPP_USERS (
    USER_ID         NUMBER          NOT NULL,
    USERNAME        VARCHAR2(100)   NOT NULL,   -- Must match APEX workspace username
    FULL_NAME       VARCHAR2(300),
    EMAIL           VARCHAR2(300),
    IS_ENABLED       VARCHAR2(1)     DEFAULT 'Y' NOT NULL,
    -- Audit
    CREATED_BY      VARCHAR2(100)   NOT NULL,
    CREATED_DATE    DATE            DEFAULT SYSDATE NOT NULL,
    UPDATED_BY      VARCHAR2(100),
    UPDATED_DATE    DATE,
    -- Constraints
    CONSTRAINT XXAPP_USERS_PK          PRIMARY KEY (USER_ID),
    CONSTRAINT XXAPP_USERS_USERNAME_UK UNIQUE      (USERNAME),
    CONSTRAINT XXAPP_USERS_ACTIVE_CK   CHECK       (IS_ENABLED IN ('Y','N'))
);

CREATE SEQUENCE XXAPP_USERS_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE OR REPLACE TRIGGER XXAPP_USERS_TRG
    BEFORE INSERT OR UPDATE ON XXAPP_USERS
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        IF :NEW.USER_ID IS NULL THEN
            :NEW.USER_ID := XXAPP_USERS_SEQ.NEXTVAL;
        END IF;
        :NEW.CREATED_BY   := NVL(:NEW.CREATED_BY, NVL(V('APP_USER'), USER));
        :NEW.CREATED_DATE := NVL(:NEW.CREATED_DATE, SYSDATE);
    END IF;
    IF UPDATING THEN
        :NEW.UPDATED_BY   := NVL(V('APP_USER'), USER);
        :NEW.UPDATED_DATE := SYSDATE;
    END IF;
END XXAPP_USERS_TRG;
/


-- -----------------------------------------------------------------------------
-- 3. XXAPP_ROLES
--    Role catalog (global roles, not tied to a specific app)
-- -----------------------------------------------------------------------------
CREATE TABLE XXAPP_ROLES (
    ROLE_ID         NUMBER          NOT NULL,
    ROLE_CODE       VARCHAR2(50)    NOT NULL,   -- e.g. 'ADMIN', 'COLLAB', 'VIEWER'
    ROLE_NAME       VARCHAR2(200)   NOT NULL,
    DESCRIPTION     VARCHAR2(1000),
    IS_ENABLED       VARCHAR2(1)     DEFAULT 'Y' NOT NULL,
    -- Audit
    CREATED_BY      VARCHAR2(100)   NOT NULL,
    CREATED_DATE    DATE            DEFAULT SYSDATE NOT NULL,
    UPDATED_BY      VARCHAR2(100),
    UPDATED_DATE    DATE,
    -- Constraints
    CONSTRAINT XXAPP_ROLES_PK          PRIMARY KEY (ROLE_ID),
    CONSTRAINT XXAPP_ROLES_CODE_UK     UNIQUE      (ROLE_CODE),
    CONSTRAINT XXAPP_ROLES_ACTIVE_CK   CHECK       (IS_ENABLED IN ('Y','N'))
);

CREATE SEQUENCE XXAPP_ROLES_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE OR REPLACE TRIGGER XXAPP_ROLES_TRG
    BEFORE INSERT OR UPDATE ON XXAPP_ROLES
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        IF :NEW.ROLE_ID IS NULL THEN
            :NEW.ROLE_ID := XXAPP_ROLES_SEQ.NEXTVAL;
        END IF;
        :NEW.CREATED_BY   := NVL(:NEW.CREATED_BY, NVL(V('APP_USER'), USER));
        :NEW.CREATED_DATE := NVL(:NEW.CREATED_DATE, SYSDATE);
    END IF;
    IF UPDATING THEN
        :NEW.UPDATED_BY   := NVL(V('APP_USER'), USER);
        :NEW.UPDATED_DATE := SYSDATE;
    END IF;
END XXAPP_ROLES_TRG;
/


-- -----------------------------------------------------------------------------
-- 4. XXAPP_APP_ROLES
--    Which roles are available within a given application
-- -----------------------------------------------------------------------------
CREATE TABLE XXAPP_APP_ROLES (
    APP_ROLE_ID     NUMBER          NOT NULL,
    APP_ID          NUMBER          NOT NULL,
    ROLE_ID         NUMBER          NOT NULL,
    IS_ENABLED       VARCHAR2(1)     DEFAULT 'Y' NOT NULL,
    -- Audit
    CREATED_BY      VARCHAR2(100)   NOT NULL,
    CREATED_DATE    DATE            DEFAULT SYSDATE NOT NULL,
    UPDATED_BY      VARCHAR2(100),
    UPDATED_DATE    DATE,
    -- Constraints
    CONSTRAINT XXAPP_APP_ROLES_PK       PRIMARY KEY (APP_ROLE_ID),
    CONSTRAINT XXAPP_APP_ROLES_UK       UNIQUE      (APP_ID, ROLE_ID),
    CONSTRAINT XXAPP_APP_ROLES_APP_FK   FOREIGN KEY (APP_ID)  REFERENCES XXAPP_APPS  (APP_ID),
    CONSTRAINT XXAPP_APP_ROLES_ROLE_FK  FOREIGN KEY (ROLE_ID) REFERENCES XXAPP_ROLES (ROLE_ID),
    CONSTRAINT XXAPP_APP_ROLES_ACTV_CK  CHECK       (IS_ENABLED IN ('Y','N'))
);

CREATE SEQUENCE XXAPP_APP_ROLES_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE OR REPLACE TRIGGER XXAPP_APP_ROLES_TRG
    BEFORE INSERT OR UPDATE ON XXAPP_APP_ROLES
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        IF :NEW.APP_ROLE_ID IS NULL THEN
            :NEW.APP_ROLE_ID := XXAPP_APP_ROLES_SEQ.NEXTVAL;
        END IF;
        :NEW.CREATED_BY   := NVL(:NEW.CREATED_BY, NVL(V('APP_USER'), USER));
        :NEW.CREATED_DATE := NVL(:NEW.CREATED_DATE, SYSDATE);
    END IF;
    IF UPDATING THEN
        :NEW.UPDATED_BY   := NVL(V('APP_USER'), USER);
        :NEW.UPDATED_DATE := SYSDATE;
    END IF;
END XXAPP_APP_ROLES_TRG;
/


-- -----------------------------------------------------------------------------
-- 5. XXAPP_USER_ROLES
--    Role assignments per user per application
-- -----------------------------------------------------------------------------
CREATE TABLE XXAPP_USER_ROLES (
    USER_ROLE_ID    NUMBER          NOT NULL,
    USER_ID         NUMBER          NOT NULL,
    APP_ROLE_ID     NUMBER          NOT NULL,   -- References the app+role combination
    IS_ENABLED       VARCHAR2(1)     DEFAULT 'Y' NOT NULL,
    -- Audit
    CREATED_BY      VARCHAR2(100)   NOT NULL,
    CREATED_DATE    DATE            DEFAULT SYSDATE NOT NULL,
    UPDATED_BY      VARCHAR2(100),
    UPDATED_DATE    DATE,
    -- Constraints
    CONSTRAINT XXAPP_USER_ROLES_PK        PRIMARY KEY (USER_ROLE_ID),
    CONSTRAINT XXAPP_USER_ROLES_UK        UNIQUE      (USER_ID, APP_ROLE_ID),
    CONSTRAINT XXAPP_USER_ROLES_USR_FK    FOREIGN KEY (USER_ID)     REFERENCES XXAPP_USERS     (USER_ID),
    CONSTRAINT XXAPP_USER_ROLES_APPR_FK   FOREIGN KEY (APP_ROLE_ID) REFERENCES XXAPP_APP_ROLES (APP_ROLE_ID),
    CONSTRAINT XXAPP_USER_ROLES_ACTV_CK   CHECK       (IS_ENABLED IN ('Y','N'))
);

CREATE SEQUENCE XXAPP_USER_ROLES_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE OR REPLACE TRIGGER XXAPP_USER_ROLES_TRG
    BEFORE INSERT OR UPDATE ON XXAPP_USER_ROLES
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        IF :NEW.USER_ROLE_ID IS NULL THEN
            :NEW.USER_ROLE_ID := XXAPP_USER_ROLES_SEQ.NEXTVAL;
        END IF;
        :NEW.CREATED_BY   := NVL(:NEW.CREATED_BY, NVL(V('APP_USER'), USER));
        :NEW.CREATED_DATE := NVL(:NEW.CREATED_DATE, SYSDATE);
    END IF;
    IF UPDATING THEN
        :NEW.UPDATED_BY   := NVL(V('APP_USER'), USER);
        :NEW.UPDATED_DATE := SYSDATE;
    END IF;
END XXAPP_USER_ROLES_TRG;
/


-- -----------------------------------------------------------------------------
-- 6. XXAPP_ROLE_PAGES
--    Which APEX pages are accessible for a given role within an application
-- -----------------------------------------------------------------------------
CREATE TABLE XXAPP_ROLE_PAGES (
    ROLE_PAGE_ID    NUMBER          NOT NULL,
    APP_ROLE_ID     NUMBER          NOT NULL,
    PAGE_NUMBER     NUMBER          NOT NULL,   -- APEX page number
    PAGE_ALIAS      VARCHAR2(255),              -- Optional APEX page alias
    CAN_READ        VARCHAR2(1)     DEFAULT 'Y' NOT NULL,
    CAN_WRITE       VARCHAR2(1)     DEFAULT 'N' NOT NULL,
    IS_ENABLED       VARCHAR2(1)     DEFAULT 'Y' NOT NULL,
    -- Audit
    CREATED_BY      VARCHAR2(100)   NOT NULL,
    CREATED_DATE    DATE            DEFAULT SYSDATE NOT NULL,
    UPDATED_BY      VARCHAR2(100),
    UPDATED_DATE    DATE,
    -- Constraints
    CONSTRAINT XXAPP_ROLE_PAGES_PK        PRIMARY KEY (ROLE_PAGE_ID),
    CONSTRAINT XXAPP_ROLE_PAGES_UK        UNIQUE      (APP_ROLE_ID, PAGE_NUMBER),
    CONSTRAINT XXAPP_ROLE_PAGES_APPR_FK   FOREIGN KEY (APP_ROLE_ID) REFERENCES XXAPP_APP_ROLES (APP_ROLE_ID),
    CONSTRAINT XXAPP_ROLE_PAGES_READ_CK   CHECK       (CAN_READ  IN ('Y','N')),
    CONSTRAINT XXAPP_ROLE_PAGES_WRITE_CK  CHECK       (CAN_WRITE IN ('Y','N')),
    CONSTRAINT XXAPP_ROLE_PAGES_ACTV_CK   CHECK       (IS_ENABLED IN ('Y','N'))
);

CREATE SEQUENCE XXAPP_ROLE_PAGES_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE OR REPLACE TRIGGER XXAPP_ROLE_PAGES_TRG
    BEFORE INSERT OR UPDATE ON XXAPP_ROLE_PAGES
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        IF :NEW.ROLE_PAGE_ID IS NULL THEN
            :NEW.ROLE_PAGE_ID := XXAPP_ROLE_PAGES_SEQ.NEXTVAL;
        END IF;
        :NEW.CREATED_BY   := NVL(:NEW.CREATED_BY, NVL(V('APP_USER'), USER));
        :NEW.CREATED_DATE := NVL(:NEW.CREATED_DATE, SYSDATE);
    END IF;
    IF UPDATING THEN
        :NEW.UPDATED_BY   := NVL(V('APP_USER'), USER);
        :NEW.UPDATED_DATE := SYSDATE;
    END IF;
END XXAPP_ROLE_PAGES_TRG;
/


-- =============================================================================
-- INDEXES (foreign keys not covered by PKs/UKs)
-- =============================================================================
CREATE INDEX XXAPP_APP_ROLES_APP_IX    ON XXAPP_APP_ROLES  (APP_ID);
CREATE INDEX XXAPP_APP_ROLES_ROLE_IX   ON XXAPP_APP_ROLES  (ROLE_ID);
CREATE INDEX XXAPP_USER_ROLES_USR_IX   ON XXAPP_USER_ROLES (USER_ID);
CREATE INDEX XXAPP_USER_ROLES_APPR_IX  ON XXAPP_USER_ROLES (APP_ROLE_ID);
CREATE INDEX XXAPP_ROLE_PAGES_APPR_IX  ON XXAPP_ROLE_PAGES (APP_ROLE_ID);


-- =============================================================================
-- SAMPLE DATA
-- =============================================================================

-- Applications
INSERT INTO XXAPP_APPS (APP_CODE, APP_NAME, APP_APEX_ID, IS_ENABLED, DESCRIPTION)
VALUES ('XXAPP', 'Application Manager', 100, 'Y', 'Manages apps, users, roles and page access');

INSERT INTO XXAPP_APPS (APP_CODE, APP_NAME, APP_APEX_ID, IS_ENABLED, DESCRIPTION)
VALUES ('XXVAULT', 'Application Vault (SSO Hub)', 101, 'Y', 'Entry point and SSO session broker');

INSERT INTO XXAPP_APPS (APP_CODE, APP_NAME, APP_APEX_ID, IS_ENABLED, DESCRIPTION)
VALUES ('XXLAB', 'Laboratory', 102, 'Y', 'APEX practice and BPM exercises');

-- Roles
INSERT INTO XXAPP_ROLES (ROLE_CODE, ROLE_NAME, DESCRIPTION)
VALUES ('ADMIN', 'Administrator', 'Full access to all applications and configuration');

INSERT INTO XXAPP_ROLES (ROLE_CODE, ROLE_NAME, DESCRIPTION)
VALUES ('COLLAB', 'Collaborator', 'Limited access, assigned per application');

INSERT INTO XXAPP_ROLES (ROLE_CODE, ROLE_NAME, DESCRIPTION)
VALUES ('VIEWER', 'Viewer', 'Read-only access');

COMMIT;
