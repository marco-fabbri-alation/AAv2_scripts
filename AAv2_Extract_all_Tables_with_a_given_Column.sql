/* Title: Extract all Tables with a given Column

The purpose of this query is to understand all tables that have a column matching a given name or title. The result returns the stewards, one row for each table-steward permutation. (Eg., if a table has 2 stewards, the query will return 2 rows for the same table.)

Prompt: column name or title
*/

  
WITH c_column AS (

-- Return all columns that have either Name (from DB) or Title (from Data Catalog) equal to the value inputed.Escludes columns deleted in the data source

 SELECT * FROM public.rdbms_columns c
  WHERE (
        c.name = ${Column Name or Title - case sensitive}
        OR c.title = ${Column Name or Title - case sensitive}
        )
        AND c.deleted is false

  )
  ,split_table AS (
  
  -- Collect all tables with Stewards and unnest. New key is table_id + steward.
  -- Escludes table with no Stewards.
  
  SELECT object_type
      , object_id
      , name
      , table_id
      , title
      , schema_id
      , ds_id
      , steward
      , SPLIT_PART(steward, '_', 2) AS steward_id
      , SPLIT_PART(steward, '_', 1) AS steward_type
    FROM (
      SELECT 'table' AS object_type
        , id AS object_id
        , table_id
        , name
        , title
        , schema_id
        , ds_id
-- **** Replace "steward" (once) with the field used to store the steward ****
        , TRIM(unnest(steward)) AS steward
      FROM public.rdbms_tables tt
      WHERE deleted is false
-- **** Replace "steward" (two times) with the field used to store the steward ****
      AND steward IS NOT NULL AND steward <> '{""}'
      ) subquery
      
      UNION ALL 
      
      -- Add tables with no Steward. Retrieving separately beacuse does not need unnest. 
      SELECT 'table' as object_type
      , id as object_id
      , name
      , table_id
      , title
      , schema_id
      , ds_id
      , NULL as steward
      , NULL AS steward_id
      , NULL AS steward_type
       FROM public.rdbms_tables
       
-- **** Replace "steward" (two times) with the field used to store the steward ****
      WHERE steward IS NULL OR steward = '{""}'
  )

  
--This is the main query 
SELECT 
    t.name AS Table_Name
    , t.title
    -- , tt.table_id
    -- , t.steward AS Table_Steward
    
    , u.display_name AS Table_Steward_Name
    , u.user_email AS Table_Steward_email
    -- , t.steward_id AS Table_Steward_id
    -- , t.steward_type AS Table_Steward_Type
   
    -- Column info
    , c.name AS Column_Name
    , c.title AS Column_Title 
   --, c.column_id
    -- Table info
   
    -- Schema info
    -- , s.schema_id AS Schema_ID
    , s.name AS Schema_Name
    , s.title AS Schema_Title
   
    -- Datasource info
    -- , ds.ds_id
    -- , ds.name AS DS_Name
    , ds.title AS DS_Title

  FROM c_column c
-- Add table intformation
  LEFT JOIN split_table t ON c.table_id = t.table_id
-- Add scehema intformation
  LEFT JOIN public.rdbms_schemas s ON t.schema_id = s.schema_id
-- Add Datasurce (DS) information
  LEFT JOIN public.rdbms_datasources ds ON t.ds_id = ds.ds_id
-- Add Steward Display Name  
  LEFT JOIN public.users u ON CAST(u.id AS int) = CAST(t.steward_id AS int)
