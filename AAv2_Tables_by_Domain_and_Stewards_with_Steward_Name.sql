/* 
AAv2 - Tables by Domain and Stewards with Steward Name
*/

--select * from public.rdbms_tables
--select distinct object_type from public.domain_members AS dm
--select * from public.stewards

-- Table by Domain and Steward
WITH split_table AS (
  SELECT 
    object_type,
    object_id,
    name,
    title,
    steward,
    SPLIT_PART(steward, '_', 1) AS steward_id,
    SPLIT_PART(steward, '_', 2) AS steward_type
  FROM (
    SELECT 
      'table' AS object_type,
      id AS object_id, 
      name, 
      title,
      TRIM(unnest(steward)) AS steward
    FROM public.rdbms_tables 
    WHERE deleted is false
  ) subquery
),
domains AS (
  SELECT 
    dm.object_id, 
    dm.object_type_id, 
    dm.object_type, 
    dm.id, 
    domains.domain_id, 
    domains.title
  FROM public.domain_members AS dm 
  LEFT JOIN public.domains AS domains
  ON dm.domain_id = domains.id
  -- restrict to table if necessary
  WHERE object_type IN ('table')
)

SELECT 
  *,
  stewards.username
FROM split_table
LEFT JOIN domains ON domains.object_id = split_table.object_id
LEFT JOIN public.stewards ON split_table.steward_id = stewards.steward_id::text AND stewards.steward_type = split_table.steward_type
-- excludes objects without domain or steward
WHERE domain_id IS NOT NULL
AND split_table.steward_id IS NOT NULL;

