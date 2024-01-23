
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
DBCC TRACEON (3605,1204,1222,-1)

EXEC master.dbo.sp_readerrorlog

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


