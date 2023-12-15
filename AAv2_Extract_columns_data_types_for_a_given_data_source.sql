/*
AAv2 - Extract columns data types for a given data source

Objective: extract data types for all columns and tables in a given Data Source. 
I was used to collecting the data type mapping of the Alation EDW data set that is distributed with CSV files.
*/


-- Objective: extract data types for all columns and tables in a a give Data Source

select 
  ds.title as datasource_name
  ,s.name as schema_name
  ,t.name as table_name
  ,c.name as column_name
  ,c.data_type  

from public.rdbms_columns c
  join public.rdbms_datasources ds on c.ds_id = ds.ds_id
  join public.rdbms_schemas s on c.schema_id = s.schema_id
  join public.rdbms_tables t on c.table_id = t.table_id

WHERE 1=1 
  and ds.ds_id = 1
  and s.deleted = FALSE
  and t.deleted = FALSE
  and c.deleted = FALSE