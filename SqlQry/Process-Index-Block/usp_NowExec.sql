USE [MASTER]
GO
IF NOT EXISTS(SELECT 1 FROM sys.procedures WHERE name = 'usp_NowExec')
BEGIN
	EXEC ('CREATE PROCEDURE dbo.usp_NowExec AS BEGIN RETURN 0; END;');
END;
GO
ALTER PROCEDURE dbo.usp_NowExec
AS
BEGIN


	SELECT DISTINCT
		 r.session_id AS SpID
		,r.percent_complete AS [Percent]
		,r.open_transaction_count AS OpenTrans	
		,r.blocking_session_id AS Blocking
		,r.[Status] 
		,r.Command 		
		,object_name( t.objectid) AS ObjectName
		,(SELECT SUBSTRING(text, statement_start_offset/2 + 1,(CASE WHEN statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX),text)) * 2 ELSE statement_end_offset END - statement_start_offset)/2) FROM sys.dm_exec_sql_text(r.sql_handle)) AS [Statement]	
		,r.Reads
		,r.Logical_reads AS LogicalReads
		,r.Writes
		,s.CPU
		,DB_NAME(r.database_id) AS DBName
		,s.[HostName]
		,s.[program_name] AS ProgramName
		,s.loginame AS [Login]
		,s.login_time AS LoginTime
		,r.start_time AS StartTime
		,r.wait_type AS WaitType
		,r.wait_time  AS WaitTime
		,r.last_wait_type AS LastWaitType
	FROM sys.dm_exec_requests r
	INNER JOIN sys.sysprocesses s ON s.spid = r.session_id
	CROSS APPLY sys.dm_exec_sql_text (r.sql_handle) t
	WHERE r.session_id > 50 
	AND r.session_id <> @@spid
	AND s.[program_name] NOT LIKE 'SQL Server Profiler%'
	--AND db_name(r.database_id) NOT LIKE N'distribution'
	--AND r.wait_type IN ('SQLTRACE_LOCK', 'IO_COMPLETION', 'TRACEWRITE')
	ORDER BY s.CPU DESC;

END;
GO

GO
PRINT '~ DONE ~'
GO