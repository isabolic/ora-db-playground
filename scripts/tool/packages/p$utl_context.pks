--------------------------------------------------------
--  DDL for Package P$UTL_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "P$UTL_CONTEXT" as 

   PROCEDURE clear_context;

   PROCEDURE set_context(p_context VARCHAR2, p_context_value VARCHAR2);

   FUNCTION get_context_value(p_context VARCHAR2) RETURN VARCHAR2;
   
   PROCEDURE set_user(p_user VARCHAR2);

end p$utl_context;

/
