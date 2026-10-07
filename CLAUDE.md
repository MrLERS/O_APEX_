# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A living guide for implementing solutions in Oracle APEX, shared with a team: conventions, how-to guides and database scripts from an APEX practice. It is not an application and has no build. Guides live under [docs/](docs/), database scripts under [db/](db/). The APEX apps themselves (pages, shared components, auth schemes) exist only in the APEX workspace (`XXLERS_DEV`) and are not exported here.

Prose is written in Spanish; database object names, columns and SQL comments are in English. Keep that split when adding content.

Teammates read this repo, so nothing environment-specific goes in: no real hosts, usernames, passwords, tokens or personal data. Use placeholders (`https://{host}/...`).

## Running things

There is no build, lint or test tooling. The `.sql` files are run by hand against the practice schema (they use `/` terminators, so they work in SQL Workshop, SQLcl or SQL*Plus). [db/install.sql](db/install.sql) runs them in dependency order from SQLcl or SQL*Plus:

1. [db/xxapp/XXAPP_DDL.sql](db/xxapp/XXAPP_DDL.sql) — tables, sequences, triggers, indexes, sample data
2. [db/xxapp/XXAPP_CREDENTIALS_V.sql](db/xxapp/XXAPP_CREDENTIALS_V.sql)
3. [db/xxapp/XXAPP_APP_ROLES_V.sql](db/xxapp/XXAPP_APP_ROLES_V.sql)
4. [db/xxapp/XXAPP_ROLES_PKG.sql](db/xxapp/XXAPP_ROLES_PKG.sql)
5. [db/xxapp/XXAPP_APP_ROLES_PKG.sql](db/xxapp/XXAPP_APP_ROLES_PKG.sql)
6. [db/xxapp/XXAPP_QUERIES_PKG.sql](db/xxapp/XXAPP_QUERIES_PKG.sql)
7. [db/xxapp/XXAPP_AUTH_PKG.sql](db/xxapp/XXAPP_AUTH_PKG.sql) — does not compile yet, see below

[db/xxapp/XXAPP_TRUNCATE.sql](db/xxapp/XXAPP_TRUNCATE.sql) is destructive and not part of the install: it truncates every `XXAPP%` table and restarts every `XXAPP%` sequence at 1.

No database is reachable from this repo, so a script written or edited here is uncompiled until someone runs it in the workspace. Say so when reporting.

## The system being built

Three APEX apps sharing one free-tier schema, with object prefixes standing in for separate schemas ([docs/bitacora.md](docs/bitacora.md) has the original brief, [docs/arquitectura.md](docs/arquitectura.md) the write-up for readers):

- **Application Manager** (`XXAPP`) — maintains apps, users, roles and page access.
- **Application Vault** (`XXVAULT`) — entry point; lists the apps a user's roles allow and shares the session with them (SSO).
- **Laboratory** (`XXLAB`) — where APEX features get practised. No `XXLAB` objects exist yet.

### Access model

`XXAPP_APPS`, `XXAPP_USERS` and `XXAPP_ROLES` are independent catalogs. Roles are global; `XXAPP_APP_ROLES` makes a role available in an app, and that `APP_ROLE_ID` is what everything else hangs off:

- `XXAPP_USER_ROLES` = user × app_role (a user is granted a role *within an app*, never a bare role)
- `XXAPP_ROLE_PAGES` = app_role × APEX page number, with `CAN_READ` / `CAN_WRITE`

`XXAPP_APPS.APP_APEX_ID` is the link to the real APEX application ID; it is how the login check and the `apex_application_pages` lookups find the current app. The IDs in the DDL sample data (100–102) are placeholders.

Every table's `_TRG` trigger fills the PK from its `_SEQ` and maintains the audit columns (`CREATED_BY/DATE`, `UPDATED_BY/DATE`, using `V('APP_USER')` with a fallback to `USER`). Inserts should omit both the ID and the audit columns, as the sample data does.

### Login flow

The APEX custom authentication scheme calls `XXAPP_AUTH_PKG.PROCESS_LOGIN`, which upper-cases the username and delegates to `HAS_ACCESS`, which looks the user up in `XXAPP_CREDENTIALS_V` for the app in `V('APP_ID')`. `PROCESS_LOGIN` has `WHEN OTHERS THEN RETURN FALSE`, so any runtime error surfaces as a plain failed login.

### Query package pattern

Report, LOV, grid and cards sources are not written inline in APEX. Each is a function in `XXAPP_QUERIES_PKG` that returns the SQL text as a `CLOB`, and the APEX region uses "Function Body returning SQL Query" (`return XXAPP_QUERIES_PKG.get_all_roles('LOV');`). A `p_type` argument selects the column shape for the consumer:

- `'LOV'` — `d` / `r` display and return columns
- `'REP'`, `'GRID'` — report or Interactive Grid columns
- `'CARDS'` — the `card_*` aliases from the Cards template in [docs/guias/cards.md](docs/guias/cards.md)
- anything else — unfiltered full select

Joins that are large or reused go in a `_V` view first, then get exposed through one of these functions. Writes from Interactive Grids go through per-entity packages (`XXAPP_ROLES_PKG.add_role`, `XXAPP_APP_ROLES_PKG.add_app_role` / `save_app_role`) called from a `case :APEX$ROW_STATUS` block.

The returned string must not end in `;` — APEX wraps it as a subquery. Numeric parameters concatenated into the text go through `nvl(p, 0)` so the query stays valid while the page item is null.

## The repo is behind the database

The workspace is the source of truth and the files only partly mirror it. [docs/pendientes.md](docs/pendientes.md) is the running list; keep it current when a gap is closed or found. Check before assuming a script is complete or compiles:

- `XXAPP_APP_ROLES_V`, `XXAPP_ROLES_PKG`, `XXAPP_APP_ROLES_PKG` and five functions of `XXAPP_QUERIES_PKG` (`get_all_roles`, `get_all_registered_apps`, `get_all_roles_by_app`, `get_all_pages_by_role`, `get_all_pages_by_app_apex`) were assembled from note snippets, not exported from the workspace, and have never been compiled. The fixes applied while assembling them are tabulated in [docs/pendientes.md](docs/pendientes.md).
- [db/xxapp/XXAPP_AUTH_PKG.sql](db/xxapp/XXAPP_AUTH_PKG.sql) does not compile: `HAS_ACCESS` filters on a `PWD` column that neither `XXAPP_CREDENTIALS_V` nor `XXAPP_USERS` has in this repo, and `SAVE_CREDENTIALS` reads from `XXAPP_USER_INFO_V`, which is not in the repo. It also compares the password in plain text and would store it in session state; do not present it as a reference login.
- The Fusion practice block in [docs/guias/web-services.md](docs/guias/web-services.md) (SOAP call to a BI Publisher report, CSV loaded into an `apex_collection`) has never run end to end; its open points are listed in the guide.
- [docs/guias/mensajes-de-error.md](docs/guias/mensajes-de-error.md) references `XXFND_NEW_MESSAGES_PKG` and `getConfiguredMessage`, which come from another project.

## Conventions

Defined in [docs/convenciones.md](docs/convenciones.md); the ones that affect generated code:

**Database**

- Object names are `XX<SCHEMA>_<NAME><SUFFIX>`. Tables take no suffix; views `_V`, packages `_PKG`, triggers `_TRG`, sequences `_SEQ`, standalone procedures `_P`, functions `_F` (`_VW`, `_PRC`, `_FUN` are listed as alternates; existing objects use the short forms).
- Every table gets the four audit columns, a sequence and a trigger.
- The soft-delete flag is `IS_ENABLED` (`'Y'`/`'N'`), never `IS_ACTIVE`.
- Close subprograms with their name (`end get_all_users;`), not a bare `end;`.
- Query style in the packages: leading commas, `where 0 = 0` followed by `and` lines, and `q'~ ... ~'` quoting for SQL text unless a parameter has to be concatenated in.

**APEX**

- Page numbers: hundreds for a module's main page (100, 200, 300), tens and fives for pages inside that module (110, 115, 120). Page 1 is Home.
- Shared component LOVs: `UPPER_SNAKE_CASE` with `_LOV` suffix.
- Region and button names: lowercase preferred over `UPPER_SNAKE_CASE` (the one example in the notes is `grid-roles`; the exact format is still undecided).
- Dynamic Actions and JavaScript functions: `camelCase`.
- Ajax Callback process names: `UPPER_SNAKE_CASE`.
- Working copies: `feature/<SIGLAS>-name`, `fix/<SIGLAS>-name`, `hotfix/<SIGLAS>-name` (e.g. `feature/AJGC3-list_cards`).

## Where things go

[CONTRIBUTING.md](CONTRIBUTING.md) is the version for people. In short:

- [docs/guias/](docs/guias/) — one how-to guide per topic, started from [docs/guias/_plantilla.md](docs/guias/_plantilla.md). Each states where in APEX the thing is configured, and carries an `**Estado:**` line when it is a draft. A new guide is also added to the tables in [README.md](README.md) and [docs/temario.md](docs/temario.md).
- [db/xxapp/](db/xxapp/) — one script per database object, named after the object, and listed in [db/install.sql](db/install.sql). The script is the only copy of the code: guides link to it and quote short excerpts at most.
- [docs/apps/](docs/apps/) — per-app, per-page material, headed `<page number> - <name>`.
- [docs/convenciones.md](docs/convenciones.md) — conventions; [docs/temario.md](docs/temario.md) — topic checklist; [docs/pendientes.md](docs/pendientes.md) — known gaps and loose queries; [docs/bitacora.md](docs/bitacora.md) — log of the prompts used to generate the scripts.
