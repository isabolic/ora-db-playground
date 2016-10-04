--------------------------------------------------------
--  DDL for Package Body P$APX_UTL
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "P$APX_UTL" 
as
    procedure init_http_buffer_for_clob
    is
        l_name_list sys.owa.vc_arr;
        l_value_list sys.owa.vc_arr;
    begin
        l_name_list(1)  := 'REQUEST_CHARSET';
        l_value_list(1) := 'AL32UTF8';
        l_name_list(2)  := 'REQUEST_IANA_CHARSET';
        l_value_list(2) := 'UTF-8';
        sys.owa.init_cgi_env(2, l_name_list, l_value_list) ;
        sys.htp.init() ;
        sys.htp.htbuf_len := 84;
    end init_http_buffer_for_clob;
    
    function get_gen_api_clob return clob
    is
        v_clob clob;
    begin
        
        apex_050000.wwv_flow_gen_api2.g_writer.flush;
        v_clob := treat( 
                     apex_050000.wwv_flow_gen_api2.g_writer as apex_050000.wwv_flow_t_clob_writer
                  ).l_clob;
        apex_050000.wwv_flow_gen_api2.g_writer := apex_050000.wwv_flow_t_htp_writer() ;
        
        return v_clob;
    end get_gen_api_clob;
    
    procedure init_gen_api_clob
      is
    begin
    
    init_http_buffer_for_clob;
    
    apex_050000.wwv_flow_gen_api2
               .g_writer := apex_050000.wwv_flow_t_clob_writer (
                                 p_cache => true,
                                 p_dur   => SYS.DBMS_LOB.session 
                                );        
    end init_gen_api_clob;

    procedure export(            
            p_app_id       number,
            p_page_id      number   default null,
            p_comp_id      number   default null,
            p_component    varchar2 default null,
            p_workspace_id number   default null,
            p_ddl_id       number   default null
            )
    as
       v_workspace_id number := p_workspace_id;
       v_admin_ws_id  number;
       v_script       clob;
    begin
    
        if v_workspace_id is null then
          select workspace_id 
            into v_workspace_id
            from apex_app_monitor
           where 1=1
             and app_id = p_app_id;
        end if;
      
        apex_050000.wwv_flow.g_flow_id := p_app_id;
        apex_050000.wwv_flow_security.g_security_group_id := v_workspace_id;

        init_gen_api_clob;

        apex_050000.wwv_flow_gen_api2
                   .export(  p_flow_id                  => p_app_id
                           , p_export_ir_public_reports => 'Y'
                           , p_component_id             => p_comp_id
                           , p_page_id                  => p_page_id
                           , p_component                => p_component
                           ) ;
        
        v_script := get_gen_api_clob;
        
        if p_ddl_id is not null then
            update ddl_log
               set sql_text =  v_script
             where id = p_ddl_id;  
        end if;
        
    end export;
    
    function null_in_str(p_val varchar2) return varchar2 is
      v_ret varchar2(200) := p_val;
    begin
       if v_ret is null then
          v_ret := 'null';
       end if;
       return v_ret;
    end;
    
    procedure export_via_job (
        p_app_id       number,
        p_page_id      number   default null,
        p_comp_id      number   default null,
        p_component    varchar2 default null,
        p_workspace_id number   default null,
        p_ddl_id       number   default null
    ) is 
      v_job_exe varchar2(32000) :=
                 'DECLARE
                  BEGIN
                    p$apx_utl.export(
                              p_app_id       => #APP_ID#,
                              p_page_id      => #PAGE_ID#,
                              p_comp_id      => #COMP_ID#, 
                              p_component    => ''#COMPONENT#'',
                              p_workspace_id => #WORKSPACE_ID#,
                              p_ddl_id       => #DDL_LOG_ID#);
                   
                   exception
                   when others then
                     null;
                     -- LOGERR TODO
                  END;';
       v_job_name varchar2(200);
     begin
        
        v_job_exe := replace(v_job_exe, '#APP_ID#'      , p_app_id);
        v_job_exe := replace(v_job_exe, '#PAGE_ID#'     , null_in_str(p_page_id));
        v_job_exe := replace(v_job_exe, '#COMP_ID#'     , null_in_str(p_comp_id));
        v_job_exe := replace(v_job_exe, '#COMPONENT#'   , null_in_str(p_component));
        v_job_exe := replace(v_job_exe, '#WORKSPACE_ID#', null_in_str(p_workspace_id));
        v_job_exe := replace(v_job_exe, '#DDL_LOG_ID#'  , null_in_str(p_ddl_id));
        
        v_job_name := 'APEX_EXPORT_' || p_app_id || '_' || p_ddl_id;
        
        dbms_output.put_line(v_job_exe);
        
        DBMS_SCHEDULER.CREATE_JOB (
           job_name                 =>  v_job_name,
           job_type                 =>  'PLSQL_BLOCK',
           job_action               =>  v_job_exe,
           enabled                  =>  true,
           auto_drop                =>  true
        );
   end;
    
    
end p$apx_utl;

/
