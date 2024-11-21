/*
Date 24 Feb 2021
Get Last Executed SP, Function or any database objects
*/

-- SELECT GETDATE() --2021-02-24 12:30:54.903

SELECT o.[type_desc] AS ObjectType
	, SCHEMA_NAME(o.schema_id) AS SchemaName
	, o.name AS ObjectName
	, ps.last_execution_time 
FROM   sys.dm_exec_procedure_stats ps 
INNER JOIN sys.objects o 
	ON ps.object_id = o.object_id 
WHERE  DB_NAME(ps.database_id) = 'Portal' 
ORDER  BY ps.last_execution_time DESC  


--------------------------------------------------------------------------------------------------------------

--> From Planned cache
SELECT qt.[text]          AS [SP Name],
       qs.last_execution_time,
       qs.execution_count AS [Execution Count]
FROM   sys.dm_exec_query_stats AS qs
       CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
WHERE  qt.dbid = DB_ID()
       AND objectid = OBJECT_ID('YourProc') 

--------------------------------------------------------------------------------------------------------------

--> Query store need to be enabled SQL2016+
SELECT 
      ObjectName = '[' + s.name + '].[' + o.Name  + ']'
    , LastModificationDate  = MAX(o.modify_date)
    , LastExecutionTime     = MAX(q.last_execution_time)
FROM sys.query_store_query q 
    INNER JOIN sys.objects o
        ON q.object_id = o.object_id
    INNER JOIN sys.schemas s
        ON o.schema_id = s.schema_id
WHERE o.type IN ('P')
GROUP BY o.name , + s.name 

