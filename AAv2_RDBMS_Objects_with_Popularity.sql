/*
AAv2 - RDBMS Objects with Popularity 

Alation Analytics query that shows all the RDBMS objects listed out by popularity and excludes Alation Analytics objects.
To exclude the Alation Analytics data source, you need to know the Datasource ID and input it at prompt. 
*/

-- List the object types in Popularity Table
-- SELECT distinct object_type from public.popularity 


-- Tables
select t.title, t.name, t.table_id as Object_ID,  'Table' AS Object_type, p.popularity 
from 
  ( 
   select * 
  from public.rdbms_tables 
  where ds_id != ${Datasource ID to exclude}
  ) t
LEFT JOIN 
  ( 
  SELECT * from public.popularity WHERE object_type = 'table'
  ) p
on p.object_id = t.table_id
where p.popularity  is not null

-- Columns
UNION ALL

select c.title, c.name, c.column_id as Object_ID,  'Column' AS Object_type, p.popularity 
from
  ( 
   select * 
  from public.rdbms_columns 
  where ds_id != ${Datasource ID to exclude}
  ) c
LEFT JOIN 
  ( 
  SELECT * from public.popularity WHERE object_type = 'attribute'
  ) p
on p.object_id = c.column_id
where p.popularity  is not null

-- Schemas
UNION

select s.title, s.name, s.schema_id as Object_ID, 'Schema' AS Object_type,  p.popularity 
from 
  ( 
  select * 
  from public.rdbms_schemas 
  where ds_id != ${Datasource ID to exclude}
  ) s
LEFT JOIN 
  ( 
  SELECT * from public.popularity WHERE object_type = 'schema'
  ) p
on p.object_id = s.schema_id
where p.popularity  is not null

-- Data sources
UNION

select ds.title, ds.name, ds.ds_id as Object_ID, 'Datasource' AS Object_type, p.popularity 
from 
  ( 
  select * 
  from public.rdbms_datasources
  where ds_id != ${Datasource ID to exclude}
  ) ds
LEFT JOIN 
  ( 
  SELECT * from public.popularity WHERE object_type = 'data'
  ) p
on p.object_id = ds.ds_id
where p.popularity  is not null