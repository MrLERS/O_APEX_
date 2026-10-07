-- =============================================================================
-- install.sql
-- Fresh install of the XXAPP objects, in dependency order.
-- Run from SQLcl or SQL*Plus:   @db/install.sql
-- SQL Workshop does not support @@: upload and run each file there, in this
-- same order.
-- =============================================================================
-- XXAPP_TRUNCATE.sql is NOT part of the install. It wipes every XXAPP% table
-- and restarts every XXAPP% sequence; run it by hand when you mean to.
-- =============================================================================

@@xxapp/XXAPP_DDL.sql
@@xxapp/XXAPP_CREDENTIALS_V.sql
@@xxapp/XXAPP_APP_ROLES_V.sql
@@xxapp/XXAPP_ROLES_PKG.sql
@@xxapp/XXAPP_APP_ROLES_PKG.sql
@@xxapp/XXAPP_QUERIES_PKG.sql

-- Known not to compile yet: needs PWD in XXAPP_CREDENTIALS_V and the view
-- XXAPP_USER_INFO_V, neither of which is in this repo (docs/pendientes.md).
@@xxapp/XXAPP_AUTH_PKG.sql
