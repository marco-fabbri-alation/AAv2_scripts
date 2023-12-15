/*
AAv2 - Object counting for Object-base Pricing Model 


Source: https://alation.highspot.com/items/63f66c3d78ca8cbb8bc4f7d0?lfrm=srp.0#6


What is considered to be an object?
Objects are defined as all items in the catalog that are listed below.


Is an Object

RDBMS - data source, schemas, tables, columns 
BI - data source, reports, folder, fields
File System - data source, directories, files
NoSQL - data source, folders, collections, schemas
Lineage - Dataflow objects 
Content/Semantic Objects - Articles, glossaries, glossary
terms, domains
Data Governance - Policies, policy groups, data policies 
Compose/Queries - published queries 
Connected Sheets (future) - cataloged sheets 
 

Is not an Object

Trust flags
Workflows
Tags
Conversations
Filters and Joins
Templates
Query Results
Sampling/profiling
Objects in the Connected Sheets spreadsheet
 

Notes: 
The following objects are not available in AAv2 at the time of writing this query:

Lineage: Dataflow Objects 
NoSOL: Collections
Connected Sheets
 */


/*  This query will extract object total across different Alation Objects: */
select 'Last ETL job run (YYYYMMDD)' as oject,cast(replace(cast(max(date(timestamp)) as text),'-','') as int) from public.etl_checkpoint union 
select 'RDBMS: Datasources' as object, count(*) from public.rdbms_datasources where deleted is false union
select 'RDBMS: Schemas' as object, count(*) from public.rdbms_schemas where deleted is false union
select 'RDBMS: Tables' as object, count(*) from public.rdbms_tables where deleted is false union
select 'RDBMS: Columns' as object, count(*) from public.rdbms_columns where deleted is false union
select 'BI: Datasources' as object, count(*) from public.bi_server union 
select 'BI: Folder' as object, count(*) from public.bi_folder union 
select 'BI: Reports' as object, count(*) from public.bi_report union 
select 'BI: Report Columns' as object, count(*) from public.bi_report_column union 
select 'BI: Connections' as object, count(*) from public.bi_connection union
select 'BI: Connection Columns' as object, count(*) from public.bi_connection_column union
select 'BI: Datasource Columns' as object, count(*) from public.bi_datasource_columns union
select 'Filesystems: Files' as object, count(*) from public.files /*where deleted_at is null*/ union
select 'Filesystems: Directories' as object, count(*) from public.directories /*where deleted_at is null*/ union
select 'Article Groups' as object, count(*) from public.custom_glossary where deleted is false union
select 'Articles' as object, count(*) from public.article where deleted is false union
select 'Domains' as object, count(*) from public.domains where deleted_at is null union
select 'Glossaries' as object, count(*) from public.glossaries where deleted is false union
select 'Glossary Terms' as object, count(*) from public.terms where deleted is false union
select 'Policies: Data Policis' as object, count(*) from public.data_policy where deleted is false union
select 'Policies: Business Policis' as object, count(*) from public.business_policy where deleted is false union
select 'Policies: Policy Groups' as object, count(*) from public.policy_group where deleted is false union
select 'Queries: Published' as object, count(*) from public.query where published is true and discarded is false union



-- Lineage: Dataflow Objects is not available
-- NoSOL: Collections is not available
-- Connected Sheets is not available 

-- Other objects:
-- select 'Queries: Unpublished' as object, count(*) from public.query where published is false and discarded is false
-- select 'tags' as object, count(*) from public.tags union
-- select 'flags' as object, count(*) from public.flags union
-- select 'custom fields' as object, count(*) from public.customfield union
-- select 'custom templates' as object, count(*) from public.custom_template union
-- select 'catalog sets' as object, count(*) from public.catalog_set_membership where deleted is false union
-- select 'alation groups' as object, count(*) from public.alation_group union
-- select 'alation users' as object, count(*) from public.users where is_active is true union
-- select 'alation stewards' as object, count(distinct public.stewards.steward_id) from public.stewards union
-- select 'alation conversations' as object, count(*) from public.conversation where post_deleted is false union

ORDER by object;