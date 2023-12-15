select 1=1
    , * 
from public.popularity
where 1=1
    ,object_type = 'schema'
    and object_id in (
    
        select s.id from public.rdbms_schemas s
        where ds_id in (
            
            select ds.ID from public.rdbms_datasources ds
            where ds.id = ${Datasource ID: | type:54}
        )  
    )

