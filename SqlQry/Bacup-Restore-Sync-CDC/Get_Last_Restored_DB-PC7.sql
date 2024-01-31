/*
SQL to Get Last DB restored/created.
*/

--> Get Backup/Restore Command Progress

SELECT session_id as SPID
	, Command
	, a.text AS Query
	, start_time AS StartTime
	, Percent_complete AS PercentComplete
	, dateadd(second,estimated_completion_time/1000, getdate()) AS  EstimatedCompletionTime
	, DATEADD(ms, DATEDIFF(ms, GETDATE(), DATEADD(SECOND,estimated_completion_time/1000, GETDATE())), 0) AS EstmtCompletedIn
FROM sys.dm_exec_requests AS r 
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS a
WHERE r.command in ('BACKUP DATABASE','RESTORE DATABASE')

------------

--> When DB File last created
;WITH LastRestores AS
(
SELECT
    DatabaseName = [d].[name] ,
    [d].[create_date] ,
    [d].[compatibility_level] ,
    [d].[collation_name] ,
    r.*,
    RowNum = ROW_NUMBER() OVER (PARTITION BY d.Name ORDER BY r.[restore_date] DESC)
FROM master.sys.databases d
LEFT OUTER JOIN msdb.dbo.[restorehistory] r ON r.[destination_database_name] = d.Name
)
SELECT *
FROM [LastRestores]
WHERE [RowNum] = 1
ORDER BY restore_date desc

------------

--> When DB Restored

SELECT	[rs].[destination_database_name], 
		[rs].[restore_date], 
		[bs].[backup_start_date], 
		[bs].[backup_finish_date], 
		[bs].[database_name] as [source_database_name], 
		[bmf].[physical_device_name] as [backup_file_used_for_restore]
FROM msdb..restorehistory rs
INNER JOIN msdb..backupset bs
	ON [rs].[backup_set_id] = [bs].[backup_set_id]
INNER JOIN msdb..backupmediafamily bmf 
	ON [bs].[media_set_id] = [bmf].[media_set_id] 
ORDER BY [rs].[restore_date] DESC

------------

--> Get Details with Elapsed time:
use master
GO
select retVal = count(1) from sys.databases where name in ('acv1','acv2', 'DailyBCCBilling');




--> When DB File last created
;WITH LastRestores AS
(
SELECT RowNum = ROW_NUMBER() OVER (PARTITION BY d.Name ORDER BY r.[restore_date] DESC)
    , [d].[name] AS DatabaseName
    , r.[restore_date]
    , CONVERT(VARCHAR(5), DATEADD(ms, DATEDIFF(ms, [restore_date], GETDATE()), 0), 108) AS ElpTim
    , CAST(LEFT(CONVERT(VARCHAR(5), DATEADD(ms, DATEDIFF(ms, [restore_date], GETDATE()), 0), 108), 2) AS INT) AS ElpHrs
    , CAST(RIGHT(CONVERT(VARCHAR(5), DATEADD(ms, DATEDIFF(ms, [restore_date], GETDATE()), 0), 108), 2) AS INT) AS ElpMin
FROM master.sys.databases d
LEFT OUTER JOIN msdb.dbo.[restorehistory] r ON r.[destination_database_name] = d.Name
)
SELECT *
	, case 
		when ElpHrs/24 > 0 
			then CAST(ElpHrs/24 as varchar) + ' day(s) ' + CAST(ElpHrs%24 as varchar) + ' Hrs. ' + CAST(ElpMin as varchar) + ' Min. Ago'
		when ElpHrs > 0 
			then CAST(ElpHrs%24 as varchar) + ' Hrs. ' + CAST(ElpMin as varchar) + ' Min. Ago'
		when ElpMin > 0 
			then CAST(ElpMin as varchar) + ' Min. Ago'			
		else ElpTim
	  END AS ElpStr
FROM [LastRestores]
WHERE [RowNum] = 1
--AND DatabaseName IN ('acv1','acv2', 'DailyBCCBilling')


------------






