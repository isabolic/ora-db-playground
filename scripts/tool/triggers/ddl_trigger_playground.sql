--------------------------------------------------------
--  DDL for Trigger DDL_TRIGGER_PLAYGROUND
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "DDL_TRIGGER_PLAYGROUND" 
AFTER CREATE OR ALTER OR DROP OR RENAME OR GRANT OR REVOKE OR COMMENT
ON PLAYGROUND.SCHEMA

DECLARE
 oper ddl_log.operation%TYPE;
 sql_text ora_name_list_t;
 i        PLS_INTEGER;
 l_action ddl_log.sql_text%type := '';
 v_os_user  varchar2(2000);
 v_apex_user varchar2(100);
BEGIN
  SELECT ora_sysevent
  INTO oper
  FROM DUAL;
  
  select osuser
    into v_os_user
    from sys.gv_$session 
   where sid = sys_context('USERENV', 'SID') ;
   
   begin
      select os_user
        into v_os_user
        from os_users_mapping
       where upper(os_user) = upper(v_os_user);
   exception
        when no_data_found then
        raise_application_error(-20001,'No os user provided in table OS_USERS_MAPPING');
   end;
   
  select max(apex_user)
    into v_apex_user
    from os_users_mapping
   where upper(os_user) = upper(v_os_user);
   
   --if oper = 'DROP' then
    for i in 1..sql_txt(sql_text) loop
        l_action := l_action || sql_text(i);        
   end loop;
    --else
    --   l_action := dbms_metadata.get_ddl(ora_dict_obj_type, ora_dict_obj_name, ora_dict_obj_owner); 
    --end if;

  IF oper IN ('CREATE', 'DROP') THEN
    INSERT INTO ddl_log
    SELECT ora_sysevent, ora_dict_obj_owner, 
    ora_dict_obj_name, v_apex_user, SYSDATE, l_action, v_os_user, 'N', null, null
    FROM DUAL;
  ELSIF oper = 'ALTER' THEN
    INSERT INTO ddl_log
    SELECT ora_sysevent, ora_dict_obj_owner, 
    ora_dict_obj_name, v_apex_user, SYSDATE, l_action, v_os_user, 'N', null, null
    FROM sys.gv_$sqltext
    WHERE UPPER(sql_text) LIKE 'ALTER%'
    AND UPPER(sql_text) LIKE '%NEW_TABLE%';
  else
    INSERT INTO ddl_log
    SELECT ora_sysevent, ora_dict_obj_owner, 
    ora_dict_obj_name, v_apex_user, SYSDATE, l_action, v_os_user, 'N', null, null
    FROM DUAL;  
  END IF;
  
END DDL_TRIGGER_PLAYGROUND;
/
ALTER TRIGGER "DDL_TRIGGER_PLAYGROUND" ENABLE;
