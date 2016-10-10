--------------------------------------------------------
--  DDL for Package Body P$VER_CTRL
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "P$VER_CTRL" as

  function get_path(p_ddl_id ddl_log.id%type) return varchar2 as
    v_is_apex     boolean := false;
    v_object_type ddl_log.db_object_type%type;
    v_path        varchar2(2000);
    v_r_ddl_log   v_user_ddl_log%rowtype;
    v_file_name   v_user_ddl_log.file_name%type;
    v_root        config.value%type;
  begin
  
    select *
      into v_r_ddl_log
      from v_user_ddl_log x
     where id = p_ddl_id;
     
     v_file_name := v_r_ddl_log.file_name;
   
    if  v_r_ddl_log.apex_app_id is not null then
         v_is_apex     := true;
         v_object_type := v_r_ddl_log.apex_component_type;
    else
         v_object_type := v_r_ddl_log.db_object_type;
    end if;

    if v_is_apex = true then       
         select path
           into v_path 
           from apex_comp_maping acmg
           join version_control_structure vcse on (acmg.id = vcse.acmg_id)
          where acmg.comp_type = v_object_type;
    else
       select path
         into v_path
         from version_control_structure
        where code = v_object_type; 
    end if;
    
    select value
      into v_root
      from config
     where code = 'VER_CON_ROOT_FOLDER';
     
    if   instr(v_root, '/', -1)  
       < length(v_root) then
       v_root := v_root || '/'; -- add backspash
    end if;
    
    p_log(v_path);
    
    if   instr(v_path, '/', -1)  
       < length(v_path) then
       v_path := v_path || '/' || v_file_name; -- add backspash
    else
       v_path := v_path || v_file_name;
    end if;
    
    v_path := replace(v_root || v_path, '//', '/');
    
    v_path := replace(v_path, '#APEX#'   , 'apex');
    v_path := replace(v_path, '#APP_ID#' , v_r_ddl_log.apex_app_id);
    v_path := replace(v_path, '#SCHEMA#' , v_r_ddl_log.obj_owner);
    v_path := replace(v_path, '#NAME#'   , lower(v_r_ddl_log.object_name));
    
    return v_path;
  end get_path;

end p$ver_ctrl;

/
