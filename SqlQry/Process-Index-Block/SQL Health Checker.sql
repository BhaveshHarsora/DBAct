--Step - 1
BEGIN
	SELECT *
	FROM sys.dm_os_wait_stats
	ORDER BY wait_time_ms DESC
END

--Step - 2
BEGIN
	DBCC CHECKDB
END

BEGIN
	SELECT
		DB_NAME(database_id)
		, io_stall_read_ms/num_of_reads AS 'Disk Read Transfer/ms'
		, io_stall_write_ms/num_of_writes AS 'Disk Write Transfer/ms'
	FROM sys.dm_io_virtual_file_stats (2,1)
END
--SELECT * FROM sys.dm_os_exec_requests

BEGIN
	SELECT 
		type
		, SUM(pages_allocated_count * page_size_in_bytes) /1024 as 'KB_Used' 
	FROM sys.dm_os_memory_objects
	GROUP BY type
	ORDER BY KB_Used DESC
END

BEGIN
	SELECT AVG (work_queue_count) 
	FROM sys.dm_os_schedulers 
	WHERE status = 'VISIBLE ONLINE'
END

BEGIN
	SELECT *, pending_disk_io_count 
	FROM sys.dm_os_schedulers
END

BEGIN
	SELECT * FROM sys.dm_db_index_physical_stats(NULL, NULL, NULL, NULL, NULL)
END

BEGIN
	SELECT 
		session_id
		, command
		, total_elapsed_time
		, status
		, reads
		, writes
		, start_time
		, sql_handle 
		, b.text
	FROM sys.dm_exec_requests as a
	cross apply (select x.text from sys.dm_exec_sql_text(a.sql_handle) as x) as b
	WHERE session_id > 50
	ORDER BY total_elapsed_time DESC
END

BEGIN
	SELECT *, text 
	FROM sys.dm_exec_sql_text(0x03000C00A090EB542946E500449900000100000000000000)
END

BEGIN
	SELECT
		wait_type
		, waiting_tasks_count
		, wait_time_ms
	FROM sys.dm_os_wait_stats
	--WHERE wait_type like 'PAGEIOLATCH%'
	ORDER BY wait_type
END

BEGIN
   SELECT TOP 5
        (total_logical_reads/execution_count) as avg_logical_reads
        , (total_logical_writes/execution_count) as avg_logical_writes
        , (total_physical_reads/execution_count) as avg_phys_reads
        , Execution_count
        , statement_start_offset as stmt_start_offset
        , sql_handle
        , plan_handle
	FROM sys.dm_exec_query_stats
	ORDER BY (total_logical_reads + total_logical_writes) DESC
END

-- DMV FOR CHECKING CPU USAGE:
BEGIN
	SELECT --TOP 50   
		DB_Name(dbid) AS [DB_Name]
		, total_worker_time/execution_count AS [Avg_CPU_Time]
		, total_elapsed_time/execution_count AS [Avg_Duration]
		, total_elapsed_time AS [Total_Duration]
		, total_worker_time AS [Total_CPU_Time]
		, execution_count
		, SUBSTRING( st.text, ( qs.statement_start_offset / 2 ) + 1,
						(
							(
								CASE qs.statement_end_offset
									WHEN -1 THEN DATALENGTH(st.text)
									ELSE qs.statement_end_offset
								END - qs.statement_start_offset)/2 ) + 1 ) AS statement_text  
	FROM sys.dm_exec_query_stats AS qs  
		CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st  
	WHERE dbid in (  
					SELECT DB_ID('yourtablename') AS [Database ID]  
					)  
	ORDER BY Avg_CPU_Time DESC; 
END

-- DMV FOR CHECKING I/O USAGE
BEGIN 
	SELECT --TOP 50  
		DB_Name(dbid) AS [DB_Name]
		,  
	Execution_Count,  
	(total_logical_reads/Cast(execution_count as Decimal(38,16))) as avg_logical_reads,  
	(total_logical_writes/Cast(execution_count as Decimal(38,16))) as avg_logical_writes,  
	(total_physical_reads/Cast(execution_count as Decimal(38,16))) as avg_physical_reads,  
	max_logical_reads,  
	max_logical_writes,  
	max_physical_reads,  
	SUBSTRING(st.text, (qs.statement_start_offset/2)+1,   
	((CASE qs.statement_end_offset  
	WHEN -1 THEN DATALENGTH(st.text)  
	ELSE qs.statement_end_offset  
	END - qs.statement_start_offset)/2) + 1) AS statement_text  
	FROM sys.dm_exec_query_stats AS qs  
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st  
	WHERE dbid in (  
	SELECT DB_ID('yourtablename') AS [Database ID]  
	)  
	ORDER BY avg_logical_reads DESC;  
END

BEGIN
	SELECT TOP 50 
		  SUM(qs.total_worker_time) AS total_cpu_time, 
		  SUM(qs.execution_count) AS total_execution_count,
		  COUNT(*) AS  number_of_statements, 
		  qs.sql_handle 
	FROM sys.dm_exec_query_stats AS qs
	GROUP BY qs.sql_handle
	ORDER BY SUM(qs.total_worker_time) DESC
END

BEGIN
	SELECT 
		  total_cpu_time, 
		  total_execution_count,
		  number_of_statements,
		  s2.text
		  --(SELECT SUBSTRING(s2.text, statement_start_offset / 2, ((CASE WHEN statement_end_offset = -1 THEN (LEN(CONVERT(NVARCHAR(MAX), s2.text)) * 2) ELSE statement_end_offset END) - statement_start_offset) / 2) ) AS query_text
	FROM 
		  (SELECT TOP 50 
				SUM(qs.total_worker_time) AS total_cpu_time, 
				SUM(qs.execution_count) AS total_execution_count,
				COUNT(*) AS  number_of_statements, 
				qs.sql_handle --,
				--MIN(statement_start_offset) AS statement_start_offset, 
				--MAX(statement_end_offset) AS statement_end_offset
		  FROM 
				sys.dm_exec_query_stats AS qs
		  GROUP BY qs.sql_handle
		  ORDER BY SUM(qs.total_worker_time) DESC) AS stats
		  CROSS APPLY sys.dm_exec_sql_text(stats.sql_handle) AS s2 
END

BEGIN
	SELECT TOP 50
	total_worker_time/execution_count AS [Avg CPU Time],
	(SELECT SUBSTRING(text,statement_start_offset/2,(CASE WHEN statement_end_offset = -1 then LEN(CONVERT(nvarchar(max), text)) * 2 ELSE statement_end_offset end -statement_start_offset)/2) FROM sys.dm_exec_sql_text(sql_handle)) AS query_text, *
	FROM sys.dm_exec_query_stats 
	ORDER BY [Avg CPU Time] DESC
END

BEGIN
	select * from sys.dm_exec_query_optimizer_info
	where 
		  counter = 'optimizations'
		  or counter = 'elapsed time'
END

BEGIN
	select top 25
		  sql_text.text,
		  sql_handle,
		  plan_generation_num,
		  execution_count,
		  dbid,
		  objectid 
	from sys.dm_exec_query_stats a
		  cross apply sys.dm_exec_sql_text(sql_handle) as sql_text
	where plan_generation_num > 1
	order by plan_generation_num desc
END