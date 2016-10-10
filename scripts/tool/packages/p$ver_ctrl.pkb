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
         from (
           select path
             from version_control_structure
            where code = v_object_type
            union all
           select path
             from version_control_structure
            where code = 'SCRIPT'
              and not exists(select 1 
                               from version_control_structure
                              where code = v_object_type)
        );
    end if;
    
    select value
      into v_root
      from config
     where code = 'VER_CON_ROOT_FOLDER';
     
    if   instr(v_root, '/', -1)  
       < length(v_root) then
       v_root := v_root || '/'; -- add backspash
    end if;    
    
    if   instr(v_path, '/', -1)  
       < length(v_path) then
       v_path := v_path || '/' || v_file_name; -- add backspash
    else
       v_path := v_path || v_file_name;
    end if;
    
    v_path := replace(v_root || v_path, '//', '/');
    
    v_path := replace(v_path, '#APEX#'   , 'apex');
    v_path := replace(v_path, '#APP_ID#' , v_r_ddl_log.apex_app_id);
    v_path := replace(v_path, '#SCHEMA#' , lower(v_r_ddl_log.obj_owner));
    v_path := replace(v_path, '#NAME#'   , lower(v_r_ddl_log.object_name));
    
    return v_path;
  end get_path;
  
  procedure upd_export_status(p_ddl_id ddl_log.id%type) is
    begin
      update ddl_log
         set is_exported = 'Y'
       where id = p_ddl_id;
    end upd_export_status;
    
    function f_get_file_name (
        p_ddl_id      ddl_log.id%type
    ) return varchar2 
    is
        v_ddl_row      ddl_log%rowtype;
        v_name         varchar2(200);
        v_vcse_id      version_control_structure.id%type;
        v_file_ext     version_control_structure.file_ext%type := g_script_file_type;
    begin
     
     select * 
         into v_ddl_row
         from ddl_log
        where 1=1
          and id = p_ddl_id;
    
    -- apex      
    if v_ddl_row.obj_owner = 'APEX' then
       -- page   
       if v_ddl_row.apex_page_id is null then
          v_name := lower(
                      translate
                      (
                        (
                          'f' || v_ddl_row.apex_app_id || '_' || 
                           v_ddl_row.apex_component_type  || '_' || 
                           v_ddl_row.object_name || '.' || 
                           v_file_ext
                        ),
                        ' ', '_'
                      )
                    );
       -- sh. comp.
       else
          v_name := lower(
                      translate
                      (
                        ( 
                          'f' || v_ddl_row.apex_app_id || '_page_' || 
                           v_ddl_row.apex_page_id || '.' || v_file_ext
                         )
                        , ' ', '_'
                      )
                    );
       end if;
    else
       -- ddl objects
       select max(id), max(file_ext)
         into v_vcse_id, v_file_ext
         from version_control_structure 
        where 1=1
          and code = v_ddl_row.db_object_type;
          
      if v_file_ext is null then
         v_file_ext := g_script_file_type;
      end if;

      if v_vcse_id is not null then
          v_name := lower(v_ddl_row.object_name || '.' || v_file_ext );
      else
          v_name := lower(
                      translate
                      ( 
                        (
                          v_ddl_row.id          || '_' || 
                          v_ddl_row.operation   || '_' || 
                          v_ddl_row.object_name || '.' || v_file_ext
                        )
                         ,' ', '_' 
                      )                      
                   );                      
      end if;
    end if;

    return v_name;
    end f_get_file_name;

end p$ver_ctrl;

/
