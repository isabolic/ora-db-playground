--------------------------------------------------------
--  DDL for Package P$APX_UTL
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "P$APX_UTL" 
as
    procedure export(
            p_app_id       number,
            p_page_id      number   default null,
            p_comp_id      number   default null,
            p_component    varchar2 default null,
            p_workspace_id number   default null,
            p_ddl_id       number   default null);
    
    procedure export_via_job (
        p_app_id       number,
        p_page_id      number   default null,
        p_comp_id      number   default null,
        p_component    varchar2 default null,
        p_workspace_id number   default null,
        p_ddl_id       number   default null
    );
end p$apx_utl;

/
