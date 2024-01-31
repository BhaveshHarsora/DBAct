
USE master
Go
EXEC sp_configure 'show advanced options'
GO
EXEC sp_configure filestream_access_level, 1
GO
RECONFIGURE WITH OVERRIDE
GO


USE [master]
GO
ALTER DATABASE [PwhcProd01] ADD FILEGROUP [H1172566_FG] CONTAINS FILESTREAM 
GO
USE [PwhcProd01]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'H1172566_FG') 
	ALTER DATABASE [PwhcProd01] MODIFY FILEGROUP [H1172566_FG] DEFAULT
GO

USE [master]
GO
RESTORE DATABASE PwhcProd01
	FROM DISK='/home/cftc/mssqlbak/H1172566.bak' 
	WITH REPLACE, RECOVERY, STATS = 5,
	MOVE 'PWHCProd01_Data' TO '/home/cftc/mssql_data_log/PwhcProd01.mdf', 	
	MOVE 'PWHCProd01_Log' TO  '/home/cftc/mssql_data_log/PwhcProd01.ldf'



--sp_who2 'active'
--dbcc inputbuffer(58)

/*
Date: 05 Feb 2019 
Last Restored on 13 Feb 2019 and its took 00:38:35 to restore

Restored new Dump of V14 
Running successful
*/

USE [master]
GO
RESTORE DATABASE PwhcProd01
	FROM DISK='C:\CFTCData\SQLBackup\H1172566.bak' 
	WITH REPLACE, RECOVERY, STATS = 5,
	MOVE 'PWHCProd01_Data' TO 'C:\CFTCData\SQLData\PwhcProd01.mdf', 	
	MOVE 'PWHCProd01_Log' TO  'C:\CFTCData\SQLData\PwhcProd01.ldf',
	MOVE 'H1172566_FG' to 'C:\CFTCData\SQLData\H1172566_FG'
	
	
	
	
