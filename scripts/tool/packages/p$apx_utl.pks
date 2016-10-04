--------------------------------------------------------
--  DDL for Package P$APX_UTL
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "P$APX_UTL" 
as
    function export(
            p_app_id       number,
            p_page_id      number default null,
            p_comp_id      number default null,
            p_workspace_id number default null,
            p_component    varchar2 default null)
        return clob;
end p$apx_utl;

/
