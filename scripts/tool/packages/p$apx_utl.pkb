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

    function export(            
            p_app_id       number,
            p_page_id      number default null,
            p_comp_id      number default null,
            p_workspace_id number default null,
            p_component    varchar2 default null)
        return clob
    as
       v_workspace_id number := p_workspace_id;
    begin
      if v_workspace_id is null then
          select workspace_id 
            into v_workspace_id
            from apex_app_monitor
           where 1=1
             and app_id = p_app_id;
      end if;
      
       apex_050000.WWV_FLOW_SECURITY.G_SECURITY_GROUP_ID := v_workspace_id;
       
        -- init_gen_api_clob
        init_gen_api_clob;
    
        apex_050000.wwv_flow_gen_api2
                   .export(  p_flow_id                  => p_app_id
                           , p_export_ir_public_reports => 'Y'
                           , p_component_id             => p_comp_id
                           , p_page_id                  => p_page_id
                           , p_component                => p_component
                           ) ;
        
        return get_gen_api_clob;
    end export;
    
    
end p$apx_utl;

/
