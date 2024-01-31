/*
* Database Script for RESTORE, WITH REPLACE, RECOVERY
* Change Database name appropriatly
*/
---------------------------------------------------------------------------------------------------

-- When DB was stuck in Single User Mode and has to be up on Multy User 
USE [master] 
GO
SET DEADLOCK_PRIORITY HIGH
GO
ALTER DATABASE Dashboard SET MULTI_USER WITH ROLLBACK IMMEDIATE
GO

---------------------------------------------------------------------------------------------------

USE [MASTER] 
GO
	
ALTER DATABASE [HCDM] 
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

RESTORE DATABASE [HCDM] 
	FROM  DISK = N'D:\SQL\Backup\HCDM_20160618.bak' 
		WITH  FILE = 1
		,  NOUNLOAD
		,  REPLACE
		,  STATS = 5
GO

ALTER DATABASE [HCDM] SET MULTI_USER 
	WITH ROLLBACK IMMEDIATE

GO


----------------------------------------------------------------
-- RFP_DataMart
----------------------------------------------------------------
/*
* Database Script for RESTORE, WITH REPLACE, RECOVERY
* Change Database name appropriatly
*/

USE [MASTER] 
GO

	
ALTER DATABASE RFP_DataMart 
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

RESTORE DATABASE RFP_DataMart 
	FROM  DISK = N'G:\BACKUP\prod_backup\RFP_DataMart_backup_20170620_backup_2017_10_11_030002_3893183.bak' --RFP_DataMart_backup_2017_11_22_030002_3803002.bak
		WITH  FILE = 1
		,  NOUNLOAD
		,  REPLACE
		,  STATS = 5
GO

ALTER DATABASE RFP_DataMart SET MULTI_USER 
	WITH ROLLBACK IMMEDIATE

GO



USE RFP_DataMart
GO
CREATE USER [AssetAPIUser] FOR LOGIN [AssetAPIUser]
GO
USE RFP_DataMart
GO
ALTER ROLE [db_owner] ADD MEMBER [AssetAPIUser]
GO



----------------------------------------------------------------
-- AdventureWorksDW
----------------------------------------------------------------
/*
* Database Script for RESTORE, WITH REPLACE, RECOVERY
* Change Database name appropriatly and File name
*/

USE [master]
GO

ALTER DATABASE AdventureWorksDW 
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

RESTORE DATABASE AdventureWorksDW 
	FROM  DISK = N'D:\Data\SQL-DATA\AdventureWorksDW2016CTP3.bak' 
	WITH  FILE = 1
	,  MOVE N'AdventureWorksDW2014_Data' TO N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQL2016\MSSQL\DATA\AdventureWorksDW.mdf'
	,  MOVE N'AdventureWorksDW2014_Log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQL2016\MSSQL\DATA\AdventureWorksDW.ldf'
	,  NOUNLOAD
	,  REPLACE
	,  STATS = 5
	-- ,  RECOVERY --> USE THIS OPTION WHEN DATABASE BEEN GONE INTO "Restoring..." Status.

GO


ALTER DATABASE AdventureWorksDW SET MULTI_USER 
	WITH ROLLBACK IMMEDIATE

GO

----------------------------------------------------------------
-- PwhcProd01
----------------------------------------------------------------

USE [master]
GO

ALTER DATABASE PwhcProd02 
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
PRINT 'SET to SINGLE_USER '
GO
RESTORE DATABASE PwhcProd02 
	FROM  DISK = N'/home/cftcdbuser1/PwhcProd01_backup_2018_11_28_233003_5219354.bak' 
	WITH  FILE = 1
	,  MOVE N'PWHCProd01_Data' TO N'/home/cftc/MSsqlLatesh/PwhcProd02.mdf'
	,  MOVE N'PWHCProd01_Log' TO N'/home/cftc/MSsqlLatesh/PwhcProd02.ldf'
	,  NOUNLOAD
	,  REPLACE
	,  STATS = 5

GO
PRINT 'DB Restoring Done!'
GO

ALTER DATABASE PwhcProd02 SET MULTI_USER 
	WITH ROLLBACK IMMEDIATE

GO

PRINT '~ All Done ~'
GO

----------------------------------------------------------------
SET to SINGLE_USER 
Msg 3287, Level 16, State 1, Line 17
The file ID 1 on device '/home/cftcdbuser1/PwhcProd01_backup_2018_11_28_233003_5219354.bak' is incorrectly formed and can not be read.
Msg 3013, Level 16, State 1, Line 17
RESTORE DATABASE is terminating abnormally.
DB Restoring Done!
~ All Done ~

----------------------------------------------------------------

RESTORE DATABASE PwhcProd02
	FROM DISK='/home/cftc/mssqlbak/PwhcProd01_backup_2018_11_28_233003_5219354.bak' 
	WITH REPLACE, RECOVERY, STATS = 5,
	MOVE 'PWHCProd01_Data' TO '/home/cftc/MSsqlLatesh/PwhcProd02.mdf', 
	MOVE 'PWHCProd01_Log' TO '/home/cftc/MSsqlLatesh/PwhcProd02.ldf'
	

RESTORE VERIFYONLY FROM DISK = '/home/cftcdbuser1/PwhcProd01_backup_2018_12_19_233004_6324109.bak';


----------------------------------------------------------------
Given : 800B5D05AA6827719D035EA7C73A00CB

/home/cftcdbuser1$ md5sum PwhcProd01_backup_2018_12_19_233004_6324109.bak
303c214a67204cbe9038b47ec4662404

----------------------------------------------------------------
-- BH20210802 Remove All running process associated with DB and Refresh it.
----------------------------------------------------------------


USe master
go
declare @sql as varchar(20), @spid as int

select @spid = min(spid)  from master..sysprocesses  where dbid = db_id('Portal') 
and spid != @@spid    

while (@spid is not null)
begin
    print 'Killing process ' + cast(@spid as varchar) + ' ...'
    set @sql = 'kill ' + cast(@spid as varchar)
    exec (@sql)

    select 
        @spid = min(spid)  
    from 
        master..sysprocesses  
    where 
        dbid = db_id('Portal') 
        and spid != @@spid
end 

print 'Process completed...'

GO

alter database portal set single_user with rollback immediate
GO

BACKUP LOG [Portal] TO  
	DISK = N'C:\bu\Portal_log.trn' 
	WITH NOFORMAT, INIT
	,  NAME = N'Portal-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO


alter database portal set multi_user with rollback immediate
GO

					
----------------------------------------------------------------
-- BH20210802 Backup Refresh DB with PS script SqlServer Module
----------------------------------------------------------------
Import-Module SqlServer

Backup-SqlDatabase -Database "Portal" -ServerInstance "SQL-V-01.GECSTAGE.COM" -BackupFile "\\sql-v-02.gecstage.com\C$\bu\Portal_log.trn" -BackupAction 'Log'  -ReplaceDatabase
Backup-SqlDatabase -Database "Portal" -ServerInstance "SQL-V-01.GECSTAGE.COM" -BackupFile "\\sql-v-02.gecstage.com\C$\bu\Portal_log.trn" -BackupAction 'Log'  -NoRecovery


Restore-SqlDatabase -Database "Portal" -ServerInstance "SQL-V-01.GECSTAGE.COM" -BackupFile "\\sql-v-02.gecstage.com\C$\bu\Portal.dat" -RestoreAction Database -ReplaceDatabase
Restore-SqlDatabase -Database "Portal" -ServerInstance "SQL-V-01.GECSTAGE.COM" -BackupFile "\\sql-v-02.gecstage.com\C$\bu\Portal.dat" -RestoreAction Database -NoRecovery

----------------------------------------------------------------


---------------------------------------------------------------------------------
-- BH20210907 Backup and Restore DB among Primary and Secondary Replica in Stage
---------------------------------------------------------------------------------

--> To be executed into Primary Server:
USE MAster 
GO

BACKUP DATABASE [Dashboard] 
	TO  DISK = N'\\fs-p-01.onlineschedule.com\sql-backups\dashboard.bak' 
	WITH NOFORMAT
	, NOINIT
	, NAME = N'Dashboard-Full Database Backup'
	, SKIP
	, NOUNLOAD
	, NOREWIND
	,  STATS = 10
GO

----

BACKUP LOG [Dashboard] TO  DISK = N'\\fs-p-01.onlineschedule.com\sql-backups\dashboard.trn' 
	WITH NOFORMAT
	, NOINIT
	,  NAME = N'Dashboard-Full Database Backup'		
	, NOUNLOAD
	, NOREWIND
	,  STATS = 10
GO

------------

--> To be executed into Primary Server:

USE [master]
GO
RESTORE DATABASE [Dashboard] FROM  DISK = N'\\fs-p-01.onlineschedule.com\sql-backups\dashboard.bak' 
	WITH  FILE = 1
	,  NORECOVERY
	,  NOUNLOAD
	,  STATS = 5

GO


------------

use master
go


restore database TejstarAcc 
	from disk = N'D:\SQLDATA\Backup\tejstaracc.bak'
	With file=1
	,  MOVE N'tejstaracc' TO N'D:\SQLDATA\DATA\tejstaracc.mdf'
	,  MOVE N'tejstaracc_log' TO N'D:\SQLDATA\Log\tejstaracc_log.ldf'
	,  NOUNLOAD
	,  REPLACE
	,  STATS = 5