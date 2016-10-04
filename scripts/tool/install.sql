-- SYS user install
@ 00-tool-table-space-sys.sql;
@ 01-tool-user-create-sys.sql;
@ 02-inital-grants-tool-sys.sql;
@ 03-dbms_sesion-grants-tool-sys.sql;

-- tool user
@ scripts/00.apex_comp_maping.sql;
@ scripts/01.context_tool.sql;
@ scripts/02.al_ddl_log_apx.sql;

@ triggers/ddl_apex.sql;
@ triggers/ddl_trigger_playground.sql;

@ views/v_user_ddl_log.sql;