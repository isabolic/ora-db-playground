--------------------------------------------------------
--  DDL for View V_USER_DDL_LOG
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_USER_DDL_LOG" ("ID", "OPERATION", "OBJ_OWNER", "OBJECT_NAME", "FILE_NAME", "ATTEMPT_BY", "ATTEMPT_DT", "SQL_TEXT", "OS_USER", "IS_EXPORTED", "APEX_APP_ID", "APEX_PAGE_ID", "APEX_COMP_ID", "APEX_WORKSPACE_ID", "APEX_COMPONENT_TYPE", "DB_OBJECT_TYPE") AS 
  select id
  , operation
  , obj_owner
  , object_name
  , p$ver_ctrl.f_get_file_name(id) as file_name   
  , attempt_by
  , attempt_dt
  , sql_text
  , os_user
  , is_exported
  , apex_app_id
  , apex_page_id
  , apex_comp_id
  , apex_workspace_id
  , apex_component_type
  , db_object_type
   from ddl_log
  where 1           = 1
    and is_exported = 'N'
    and attempt_by  = p$utl_context.get_context_value('USER')
    order by attempt_dt, decode(operation, 'CREATE', 1, 'UPDATE', 2, 'DELETE', 3, 4);
