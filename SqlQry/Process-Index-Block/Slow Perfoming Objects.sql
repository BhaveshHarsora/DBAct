/*
BH20240425
T-SQL query to identify queries that are consuming a high amount of CPU and memory
*/

SELECT TOP 10
    qs.execution_count AS [Execution Count],
    qs.total_worker_time AS [Total CPU Time],
    qs.total_worker_time / qs.execution_count AS [Avg CPU Time],
    qs.total_logical_reads AS [Total Logical Reads],
    qs.total_logical_reads / qs.execution_count AS [Avg Logical Reads],
    qs.total_logical_writes AS [Total Logical Writes],
    qs.total_logical_writes / qs.execution_count AS [Avg Logical Writes],
    qs.total_physical_reads AS [Total Physical Reads],
    qs.total_physical_reads / qs.execution_count AS [Avg Physical Reads],
    SUBSTRING(st.text, (qs.statement_start_offset / 2) + 1, 
        ((CASE qs.statement_end_offset 
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset END 
            - qs.statement_start_offset) / 2) + 1) AS [Query Text],
    DB_NAME(st.dbid) AS [Database Name],
    OBJECT_NAME(st.objectid, st.dbid) AS [Object Name],
    qs.creation_time AS [Creation Time]
FROM 
    sys.dm_exec_query_stats AS qs
CROSS APPLY 
    sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY 
    qs.total_worker_time DESC;
