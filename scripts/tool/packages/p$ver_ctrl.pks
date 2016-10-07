--------------------------------------------------------
--  DDL for Package P$VER_CTRL
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "P$VER_CTRL" as 
   function get_path(p_ddl_id ddl_log.id%type) return varchar2;
end p$ver_ctrl;

/
