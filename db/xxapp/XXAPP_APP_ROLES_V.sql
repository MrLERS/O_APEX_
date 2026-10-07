-- =============================================================================
-- XXAPP_APP_ROLES_V
-- Roles available in each application (app x role), enabled rows only.
-- Exposed to APEX through XXAPP_QUERIES_PKG.get_all_roles_by_app.
-- =============================================================================
-- Columns:
--   APP_ID, APP_CODE, APP_NAME, APP_APEX_ID, APP_DESC -> XXAPP_APPS
--   APP_ROLE_ID                                       -> XXAPP_APP_ROLES
--   ROLE_ID, ROLE_CODE, ROLE_NAME, ROLE_DESC          -> XXAPP_ROLES
-- =============================================================================

CREATE OR REPLACE FORCE EDITIONABLE VIEW "XXAPP_APP_ROLES_V" ("APP_ID", "APP_CODE", "APP_NAME", "APP_APEX_ID", "APP_DESC", "APP_ROLE_ID", "ROLE_ID", "ROLE_CODE", "ROLE_NAME", "ROLE_DESC") AS
select
    a.APP_ID
    , a.APP_CODE
    , a.APP_NAME
    , a.APP_APEX_ID
    , a.DESCRIPTION as APP_DESC
    , ar.APP_ROLE_ID
    , r.ROLE_ID
    , r.ROLE_CODE
    , r.ROLE_NAME
    , r.DESCRIPTION as ROLE_DESC
from XXAPP_APPS a
join XXAPP_APP_ROLES ar
  on ar.APP_ID = a.APP_ID
join XXAPP_ROLES r
  on r.ROLE_ID = ar.ROLE_ID
where 0 = 0
 and a.IS_ENABLED = 'Y'
 and ar.IS_ENABLED = 'Y'
 and r.IS_ENABLED = 'Y';
