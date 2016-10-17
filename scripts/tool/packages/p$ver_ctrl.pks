--------------------------------------------------------
--  DDL for Package P$VER_CTRL
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "P$VER_CTRL" as 
   
   g_script_file_type varchar2(10) := 'sql';
    
   function get_path(  p_ddl_id ddl_log.id%type
                     , withFile varchar2 default 'Y') return varchar2;
   
   procedure upd_export_status_all;
   
   procedure upd_export_status(
        p_ddl_id ddl_log.id%type
    );
    
    function f_get_file_name (
        p_ddl_id      ddl_log.id%type
    )  return varchar2 ;
 
    function are_job_exports_done 
       return number;
end p$ver_ctrl;

/
