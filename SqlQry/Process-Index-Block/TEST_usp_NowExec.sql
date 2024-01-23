--dbcc inputbuffer(65)
--dbcc inputbuffer(59)
--sp_who2 'active'
--dbcc freeproccache
--> Currently Running SQLs
USE [master]
GO

IF exists(select 1 from sys.objects where type='FN' and name = 'udf_GetProcessName')
begin
	EXEC ('CREATE FUNCTION dbo.udf_GetProcessName(@pSpID INT) RETURNS NVARCHAR(MAX) AS BEGIN RETURN '' END;')
end;
go
ALTER FUNCTION dbo.udf_GetProcessName
(
	@pSpID INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @vTbl AS TABLE (EventType VARCHAR(255), Params VARCHAR(255), ProcName NVARCHAR(MAX))
	DECLARE @vSqlTx AS NVARCHAR(MAX), @vReturnVal AS NVARCHAR(MAX);

	SET @vSqlTx = CONCAT('DBCC INPUTBUFFER(' , @pSpID , ');');
	
	INSERT INTO @vTbl (EventType, Params, ProcName)
	EXEC (@vSqlTx);

	SELECT TOP 1 @vReturnVal = ProcName  FROM @vTbl

	RETURN @vReturnVal;

END;
GO


DECLARE @vTbl AS TABLE (EventType VARCHAR(255), Params VARCHAR(255), ProcName NVARCHAR(MAX))
	DECLARE @vSqlTx AS NVARCHAR(MAX), @vReturnVal AS NVARCHAR(MAX);

	--SET @vSqlTx = CONCAT(N'SELECT ' , 1, '');
	SET @vSqlTx = CONCAT(N'DBCC INPUTBUFFER(' , 1 , ');');
	
	INSERT INTO @vTbl (EventType, Params, ProcName)
	EXEC (@vSqlTx);
	
	select * from @vTbl

DBCC INPUTBUFFER(1)


SELECT DISTINCT
	 r.session_id AS spid
	,r.percent_complete AS [percent]
	,r.open_transaction_count AS open_trans	
	,r.blocking_session_id AS blocking
	,r.[status]
	,r.command 
	,object_name( t.objectid) AS ObjectName
	,(SELECT SUBSTRING(text, statement_start_offset/2 + 1,(CASE WHEN statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX),text)) * 2 ELSE statement_end_offset END - statement_start_offset)/2) FROM sys.dm_exec_sql_text(r.sql_handle)) AS [statement]	
	,r.reads
	,r.logical_reads
	,r.writes
	,s.cpu
	,DB_NAME(r.database_id)		AS [db_name]
	,s.[hostname]
	,s.[program_name] 
	,s.loginame 
	,s.login_time 
	,r.start_time
	,r.wait_type
	,r.wait_time 
	,r.last_wait_type
FROM sys.dm_exec_requests r
INNER JOIN sys.sysprocesses s ON s.spid = r.session_id
CROSS APPLY sys.dm_exec_sql_text (r.sql_handle) t
WHERE r.session_id > 50 
AND r.session_id <> @@spid
AND s.[program_name] NOT LIKE 'SQL Server Profiler%'
--AND db_name(r.database_id) NOT LIKE N'distribution'
--AND r.wait_type IN ('SQLTRACE_LOCK', 'IO_COMPLETION', 'TRACEWRITE')
ORDER BY s.CPU DESC;
