--------------------------------------------------------
--  DDL for Package P$DB_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "P$DB_OBJECT" AUTHID CURRENT_USER as 

    
    procedure export(p_ddl_id ddl_log.id%type) ;
            
    procedure export_db_object_to_ddl_log (p_ddl_id ddl_log.id%type);
    
    procedure generate_db_object_script;
    
end p$db_object;

/
