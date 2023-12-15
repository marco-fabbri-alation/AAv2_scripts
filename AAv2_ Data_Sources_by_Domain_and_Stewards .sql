-- Data Source by Domain and Steward
WITH split_data AS (
  SELECT 'datasources' as object,
  ds_id, 
  name, 
         TRIM(unnest(steward)) AS steward
  from public.rdbms_datasources where deleted is false
),

data_domains as (
   select dm.object_id, 
       dm.object_type_id, 
       dm.object_type, 
       dm.id, 
       domains.domain_id, 
       domains.title
    from public.domain_members AS dm 
    LEFT JOIN public.domains as domains
    on dm.domain_id = domains.id
    where object_type = 'data')

SELECT *
FROM  split_data 
LEFT JOIN data_domains 
on data_domains .object_id = split_data.ds_id