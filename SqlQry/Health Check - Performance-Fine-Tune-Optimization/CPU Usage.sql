/*
BH20230201 : Showing date wise statistics of SQL Server Instance CPU Usage
*/
GO
;WITH DB_CPU_Stats
AS
(
    SELECT DatabaseID, isnull(DB_Name(DatabaseID),case DatabaseID when 32767 then 'Internal ResourceDB' else CONVERT(varchar(255),DatabaseID)end) AS [DatabaseName], 
      SUM(total_worker_time) AS [CPU_Time_Ms],
      SUM(total_logical_reads)  AS [Logical_Reads],
      SUM(total_logical_writes)  AS [Logical_Writes],
      SUM(total_logical_reads+total_logical_writes)  AS [Logical_IO],
      SUM(total_physical_reads)  AS [Physical_Reads],
      SUM(total_elapsed_time)  AS [Duration_MicroSec],
      SUM(total_clr_time)  AS [CLR_Time_MicroSec],
      SUM(total_rows)  AS [Rows_Returned],
      SUM(execution_count)  AS [Execution_Count],
      count(*) 'Plan_Count'
    FROM sys.dm_exec_query_stats AS qs
    CROSS APPLY (
                    SELECT CONVERT(int, value) AS [DatabaseID] 
                  FROM sys.dm_exec_plan_attributes(qs.plan_handle)
                  WHERE attribute = N'dbid') AS F_DB
    GROUP BY DatabaseID
)
SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) AS [Rank_CPU],
       DatabaseName,
       [CPU_Time_Hr] = convert(decimal(15,2),([CPU_Time_Ms]/1000.0)/3600) ,
        CAST([CPU_Time_Ms] * 1.0 / SUM(case [CPU_Time_Ms] when 0 then 1 else [CPU_Time_Ms] end) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPU_Percent],
       [Duration_Hr] = convert(decimal(15,2),([Duration_MicroSec]/1000000.0)/3600) , 
       CAST([Duration_MicroSec] * 1.0 / SUM(case [Duration_MicroSec] when 0 then 1 else [Duration_MicroSec] end) OVER() * 100.0 AS DECIMAL(5, 2)) AS [Duration_Percent],    
       [Logical_Reads],
        CAST([Logical_Reads] * 1.0 / SUM(case [Logical_Reads] when 0 then 1 else [Logical_Reads] end) OVER() * 100.0 AS DECIMAL(5, 2)) AS [Logical_Reads_Percent],      
       [Rows_Returned],
        CAST([Rows_Returned] * 1.0 / SUM(case [Rows_Returned] when 0 then 1 else [Rows_Returned] end) OVER() * 100.0 AS DECIMAL(5, 2)) AS [Rows_Returned_Percent],
       [Reads_Per_Row_Returned] = [Logical_Reads]/(case [Rows_Returned] when 0 then 1 else [Rows_Returned] end),
       [Execution_Count],
        CAST([Execution_Count] * 1.0 / SUM(case [Execution_Count]  when 0 then 1 else [Execution_Count] end) OVER() * 100.0 AS DECIMAL(5, 2)) AS [Execution_Count_Percent],
       [Physical_Reads],
       CAST([Physical_Reads] * 1.0 / SUM(case [Physical_Reads] when 0 then 1 else [Physical_Reads] end ) OVER() * 100.0 AS DECIMAL(5, 2)) AS [Physcal_Reads_Percent], 
       [Logical_Writes],
        CAST([Logical_Writes] * 1.0 / SUM(case [Logical_Writes] when 0 then 1 else [Logical_Writes] end) OVER() * 100.0 AS DECIMAL(5, 2)) AS [Logical_Writes_Percent],
       [Logical_IO],
        CAST([Logical_IO] * 1.0 / SUM(case [Logical_IO] when 0 then 1 else [Logical_IO] end) OVER() * 100.0 AS DECIMAL(5, 2)) AS [Logical_IO_Percent],
       [CLR_Time_MicroSec],
       CAST([CLR_Time_MicroSec] * 1.0 / SUM(case [CLR_Time_MicroSec] when 0 then 1 else [CLR_Time_MicroSec] end ) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CLR_Time_Percent],
       [CPU_Time_Ms],[CPU_Time_Ms]/1000 [CPU_Time_Sec],
       [Duration_MicroSec],[Duration_MicroSec]/1000000 [Duration_Sec]
FROM DB_CPU_Stats
WHERE DatabaseID > 4 -- system databases
AND DatabaseID <> 32767 -- ResourceDB
ORDER BY [Rank_CPU] OPTION (RECOMPILE);


GO

DECLARE @ms_ticks_now BIGINT
SELECT @ms_ticks_now = ms_ticks
FROM sys.dm_os_sys_info;
SELECT TOP 10 record_id
    ,dateadd(ms, - 1 * (@ms_ticks_now - [timestamp]), GetDate()) AS EventTime
    ,[SQLProcess (%)]
    ,SystemIdle
    ,100 - SystemIdle - [SQLProcess (%)] AS [OtherProcess (%)]
FROM (
    SELECT record.value('(./Record/@id)[1]', 'int') AS record_id
        ,record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS SystemIdle
        ,record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS [SQLProcess (%)]
        ,TIMESTAMP
    FROM (
        SELECT TIMESTAMP
            ,convert(XML, record) AS record
        FROM sys.dm_os_ring_buffers
        WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
            AND record LIKE '%<SystemHealth>%'
        ) AS x
    ) AS y
ORDER BY record_id DESC;

GO
