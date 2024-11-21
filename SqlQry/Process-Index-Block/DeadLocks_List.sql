
SELECT
  xed.value('@timestamp', 'datetime') as Creation_Date,
  xed.query('.') AS Extend_Event
FROM
(
  SELECT CAST([target_data] AS XML) AS Target_Data
  FROM sys.dm_xe_session_targets AS xt
  INNER JOIN sys.dm_xe_sessions AS xs
	ON xs.address = xt.event_session_address
  WHERE xs.name = N'system_health'
  AND xt.target_name = N'ring_buffer'
) AS XML_Data
CROSS APPLY Target_Data.nodes('RingBufferTarget/event[@name="xml_deadlock_report"]') AS XEventData(xed)
ORDER BY Creation_Date DESC

------------

SELECT  L.request_session_id AS SPID, 
    DB_NAME(L.resource_database_id) AS DatabaseName,
    O.Name AS LockedObjectName, 
    P.object_id AS LockedObjectId, 
    L.resource_type AS LockedResource, 
    L.request_mode AS LockType,
    ST.text AS SqlStatementText,        
    ES.login_name AS LoginName,
    ES.host_name AS HostName,
    TST.is_user_transaction as IsUserTransaction,
    AT.name as TransactionName,
    CN.auth_scheme as AuthenticationMethod
FROM    sys.dm_tran_locks L
    JOIN sys.partitions P ON P.hobt_id = L.resource_associated_entity_id
    JOIN sys.objects O ON O.object_id = P.object_id
    JOIN sys.dm_exec_sessions ES ON ES.session_id = L.request_session_id
    JOIN sys.dm_tran_session_transactions TST ON ES.session_id = TST.session_id
    JOIN sys.dm_tran_active_transactions AT ON TST.transaction_id = AT.transaction_id
    JOIN sys.dm_exec_connections CN ON CN.session_id = ES.session_id
    CROSS APPLY sys.dm_exec_sql_text(CN.most_recent_sql_handle) AS ST
WHERE   1=1
--AND resource_database_id = db_id()
ORDER BY L.request_session_id

------------

SELECT CAST([target_data] AS XML) AS Target_Data
FROM sys.dm_xe_session_targets AS xt
INNER JOIN sys.dm_xe_sessions AS xs
	ON xs.address = xt.event_session_address
WHERE xs.name = N'system_health'
AND xt.target_name = N'ring_buffer'
FOR XML PATH ('')


---------------------------------------------------------------------------------------------------
-- BH20210804 Capture Deadlock Evenets with more details
---------------------------------------------------------------------------------------------------

/*
	3605 = write what we want to the error log.
	1204 = Capture Deadlock Events.
	1222 = Capture Deadlock Events with more info (SQL 2005 and higher)
*/

-- Check
DBCC TRACESTATUS (3605,1204,1222,-1)

-- Set
DBCC TRACEON (3605,1204,1222,-1)

---------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #tmpLogs;
GO

CREATE TABLE #tmpLogs
(
	LogDate DATETIME NULL,
	ProcessInfo VARCHAR(255),
	LogText NVARCHAR(MAX) 
);
GO

INSERT INTO #tmpLogs(LogDate, ProcessInfo, LogText)
EXEC master.dbo.sp_readerrorlog;
GO

SELECT *
FROM #tmpLogs AS a
WHERE 1=1
AND a.LogText LIKE '%Deadlock%'
ORDER BY LogDate DESC;

GO

---------------------------------------------------------------------------------------------------

/*
Deadlock issue on ALTER DATABASE
*/
USE master
go

SET DEADLOCK_PRIORITY HIGH
GO

ALTER DATABASE [YourDBName] SET MULTI_USER WITH ROLLBACK IMMEDIATE
GO


SELECT db_name(resource_database_id) AS DB_Name, request_session_id
FROM sys.dm_tran_locks l
WHERE resource_type = 'DATABASE'
AND EXISTS (SELECT * FROM sys.dm_exec_sessions s 
			WHERE l.request_session_id = s.session_id
			  AND s.is_user_process = 1)
AND resource_database_id = db_id('Portal')
GO


