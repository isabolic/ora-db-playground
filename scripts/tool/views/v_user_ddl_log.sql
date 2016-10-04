--------------------------------------------------------
--  DDL for View V_USER_DDL_LOG
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "V_USER_DDL_LOG" ("OPERATION", "OBJ_OWNER", "OBJECT_NAME", "ATTEMPT_BY", "ATTEMPT_DT", "SQL_TEXT", "OS_USER", "IS_EXPORTED") AS 
  select "OPERATION","OBJ_OWNER","OBJECT_NAME","ATTEMPT_BY","ATTEMPT_DT","SQL_TEXT","OS_USER","IS_EXPORTED"
       from ddl_log
      where 1           = 1
        and is_exported = 'N'
        and attempt_by  = p$utl_context.get_context_value('USER');
