--------------------------------------------------------
--  DDL for Trigger DDL_TRIGGER_PLAYGROUND
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "DDL_TRIGGER_PLAYGROUND" after
create or alter or
    drop
        or rename
        or grant
        or revoke
        or comment on playground.schema declare oper ddl_log.operation%type;
    sql_text ora_name_list_t;
    i pls_integer;
    l_action ddl_log.sql_text%type := '';
    v_os_user   varchar2(2000) ;
    v_apex_user varchar2(100) ;
    v_is_object number;
    begin
         -- get OPERATION on db, CREATE, ALTER.. etc
        select ora_sysevent into oper from dual;
         
         -- get OS USER
        select osuser
          into v_os_user
          from sys.gv_$session
         where sid = sys_context('USERENV', 'SID') ;
        
        -- check if user is mapped to apex user
        begin
         select apex_user
           into v_apex_user
           from os_users_mapping
          where upper(os_user) = upper(v_os_user) ;
        exception
        when no_data_found then
            raise_application_error( - 20001,
            'No os user provided in table OS_USERS_MAPPING') ;
        end;
        
        select max(1)
          into v_is_object
          from version_control_structure 
         where code = ora_dict_obj_type;
         
         
        -- generate script
        if v_is_object is null then
            for i in 1..ora_sql_txt(sql_text)
            loop
                l_action := l_action || sql_text(i) ;
            end loop;
            l_action := replace(l_action, chr(0), '') ; -- NUL char
            
            if instr(l_action, ';') = -1 then
               l_action := l_action || ';';
            end if;
        end if;
        
        
        if oper in('CREATE', 'DROP') then
             insert into ddl_log
                      ( id
                      , operation
                      , obj_owner
                      , object_name
                      , attempt_by
                      , attempt_dt
                      , sql_text
                      , os_user
                      , is_exported                      
                      , db_object_type
                      )
             select seq_id.nextval
              , ora_sysevent
              , ora_dict_obj_owner
              , ora_dict_obj_name
              , v_apex_user
              , sysdate
              , l_action
              , v_os_user
              , 'N'
              ,ora_dict_obj_type
               from dual;
        elsif oper = 'ALTER' then
             insert into ddl_log
              ( id
                      , operation
                      , obj_owner
                      , object_name
                      , attempt_by
                      , attempt_dt
                      , sql_text
                      , os_user
                      , is_exported                      
                      , DB_OBJECT_TYPE
                      )
             select seq_id.nextval
              , ora_sysevent
              , ora_dict_obj_owner
              , ora_dict_obj_name
              , v_apex_user
              , sysdate
              , l_action
              , v_os_user
              , 'N'
              , ora_dict_obj_type
               from sys.gv_$sqltext
              where upper(sql_text) like 'ALTER%'
                and upper(sql_text) like '%NEW_TABLE%';
        else
             insert into ddl_log
              ( id
                      , operation
                      , obj_owner
                      , object_name
                      , attempt_by
                      , attempt_dt
                      , sql_text
                      , os_user
                      , is_exported                      
                      , DB_OBJECT_TYPE
                      )
             select seq_id.nextval
              , ora_sysevent
              , ora_dict_obj_owner
              , ora_dict_obj_name
              , v_apex_user
              , sysdate
              , l_action
              , v_os_user
              , 'N'
              , ora_dict_obj_type
               from dual;
        end if;
    end ddl_trigger_playground;
/
ALTER TRIGGER "DDL_TRIGGER_PLAYGROUND" ENABLE;
