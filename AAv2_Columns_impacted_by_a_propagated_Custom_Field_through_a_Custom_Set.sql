/*

AAv2 - Columns impacted by a propagated Custom Field through a Custom Set

The query below will help to list the catalog objects "column" that have a given custom field set by a catalog set. The query is divided in 2 parts: 

Part 1: list all the custom fields
Part 2: list all the catalog objects that have a custom field propagated by a catalog set
You need to use the output of Part 1 to edit in three points of the SELECT and WHERE clause of the query statement in Part 2. 

*/

-- This query is build in 2 parts:
-- Part 1: list all the customfields that are propagated to a catalog object
-- Part 2: list all the "column" objects that are members of a catalog set and filters by the customfield 

------------
-- Part 1 --
------------


-- Define a CTE for custom fields propagated by a catalog set.
WITH CUST_FIELDS AS (
    SELECT 
        1 AS count,
        cf_map.*,
        cf.*
    FROM 
        public.otype_customfield_map cf_map
    LEFT JOIN 
        public.customfield cf ON cf.customfield_id = cf_map.field_id
    WHERE 
        otype = 'propagated_catalog_set'
)

-- Select custom fields propagated by a catalog set.
-- Use the output of this query ("field_name") to filter the select query in part 2.
SELECT 
    1 AS count,
    CF.field_name,
    CF.name_singular
FROM 
    CUST_FIELDS CF;


------------
-- Part 2 --
------------

-- Define a CTE for data objects with a certain custom field not null or empty.
WITH CATALOG_SET AS (               
    SELECT 
        1 AS count,
        AM.object_id,
        CM.*
    FROM (
        SELECT 
            OBJECT_ID,
            UNNEST(CATALOG_SET_IDS) AS CATALOG_SET_IDS
        FROM 
            PUBLIC.ALATION_SET_MEMBER
    ) AM
    INNER JOIN 
        PUBLIC.CATALOG_SET_MEMBERSHIP CM ON AM.CATALOG_SET_IDS = CM.CATALOG_SET_PROPERTY_ID
    AND 
        CM.DELETED IS FALSE
    AND 
        CM.members_object_type = 'attribute'
), 

-- Define a CTE for augmented information for columns.
COLUMNS AS (
    SELECT 
        1 AS COUNT,
        RC.COLUMN_ID,
        RC.NAME AS COLUMN_NAME,
        RC.TITLE AS COLUMN_TITLE,
        --RC.DESCRIPTION AS COLUMN_DESCRIPTION,
        RC.TABLE_ID,
        RT.NAME AS TABLE_NAME,
        --RT.DESCRIPTION AS TABLE_DESCRIPTION,
        RC.schema_id,
        RS.NAME AS SCHEMA_NAME,
        --RS.DESCRIPTION AS SCHEMA_DESCRIPTION,
        RC.DS_ID,
        RD.NAME AS SOURCE_NAME
        --,RD.description AS SOURCE_DESCRIPTION
    FROM 
        PUBLIC.RDBMS_COLUMNS RC
    LEFT JOIN 
        PUBLIC.RDBMS_SCHEMAS RS ON RC.SCHEMA_ID = RS.SCHEMA_ID AND RS.DELETED IS FALSE
    LEFT JOIN 
        PUBLIC.RDBMS_TABLES RT ON RC.TABLE_ID = RT.TABLE_ID AND RT.DELETED IS FALSE
    LEFT JOIN 
        PUBLIC.RDBMS_DATASOURCES RD ON RC.DS_ID = RD.DS_ID AND RD.DELETED IS FALSE
    WHERE 
        RC.deleted IS FALSE
)

-- Select data from catalog sets and columns.
SELECT 
    1 AS count,
    CS.CATALOG_SET_TITLE,
    CS.security_classification,
    RC.*,
    CS.*
FROM 
    CATALOG_SET CS
LEFT JOIN 
    COLUMNS RC ON CS.OBJECT_ID = RC.COLUMN_ID
WHERE 
    1=1
    -- Add/edit the custom field of your choice.
    -- Use the previous query to list the custom fields to use in the WHERE clause.
    AND CS.security_classification NOT IN ('{""}')
    AND CS.security_classification IS NOT NULL;
