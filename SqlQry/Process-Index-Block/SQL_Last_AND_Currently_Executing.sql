/*
Date: 23 Nov 2018

Get SQL Statements which are Currently Executing...
*/

-- What SQL Statements Are Currently Running?
SELECT [Spid] = session_Id
	, ecid
	, [Database] = DB_NAME(sp.dbid)
	, [User] = nt_username
	, [Status] = er.status
	, [Wait] = wait_type
	, [Individual Query] = SUBSTRING (qt.text, 
             er.statement_start_offset/2,
	(CASE WHEN er.statement_end_offset = -1
	       THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
		ELSE er.statement_end_offset END - 
                                er.statement_start_offset)/2)
	,[Parent Query] = qt.text
	, Program = program_name
	, Hostname
	, nt_domain
	, start_time	
	, CONVERT(varchar(8), DATEADD(ms, er.total_elapsed_time, 0), 114) AS total_elapsed_time
	, CONVERT(varchar(8), DATEADD(ms, er.cpu_time, 0), 114) AS cpu_time
	, CONVERT(varchar(8), DATEADD(ms, er.estimated_completion_time, 0), 114) AS estimated_completion_time
	, er.wait_time
FROM sys.dm_exec_requests er
INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle)as qt
WHERE 1=1
AND session_Id > 50              -- Ignore system spids.
AND session_Id NOT IN (@@SPID)     -- Ignore this current statement.
ORDER BY 1, 2


---> Last Executing Statements

SELECT TOP 100 
	dest.dbid, DB_ID('Portal')
	, dest.objectid
	, object_name(dest.objectid) aS ObjectName
	, deqs.last_execution_time AS [Time]
	, dest.text AS [Query]
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE 1=1
--and dest.dbid = DB_ID('Portal')
and dest.text LIKE '%MERGE portal.%'
ORDER BY deqs.last_execution_time DESC
