/*
Date: 11/17//2018

Get Size (in MB) for all the databases in a given SQL Server
*/

declare @vSqlTx AS VARCHAR(MAX)

select @vSqlTx = concat(@vSqlTx, case when database_id=6 then ' declare @vDbTbl as table (id int, DbName VARCHAR(50), DbFileName varchar(50), Size_MB DECIMAL(12,2), Size_GB DECIMAL(12,2), TypeDesc varchar(20), RecoveryModel VARCHAR(30)); ' else '' end,'
USE [', name, ']; insert into @vDbTbl (id, DbName, DbFileName, Size_MB, Size_GB, TypeDesc, RecoveryModel) select ',database_id,' as id, ''',[name],''' AS DbName, [name] AS DbFileName, (size*8)/cast(1024 as decimal(12,2)) AS Size_MB,(((size*8)/cast(1024 as decimal(12,2)))/1024) AS Size_GB, type_desc AS TypeDesc, ''',recovery_model_desc,''' AS RecoveryModel from sys.database_files;
', case when database_id = (select max(database_id) from sys.databases) then '
  select * 
  from @vDbTbl 
  WHERE 1=1
  --AND DbFileName LIKE ''%_Log%''
  ORDER BY Size_MB DESC
 ' ELSE '' end
 ) 
from sys.databases where database_id >5

print @vSqlTx;
EXEC (@vSqlTx);


--select * from sys.database_files
--select * from sys.databases

declare @vDbTbl as table (id int, DbName VARCHAR(50), DbFileName varchar(50), Size_MB DECIMAL(12,2), Size_GB DECIMAL(12,2), TypeDesc varchar(20), RecoveryModel VARCHAR(30)); 
USE acv1; insert into @vDbTbl (id, DbName, DbFileName, Size_MB, Size_GB, TypeDesc, RecoveryModel) select 7 as id, 'acv1' AS DbName, [name] AS DbFileName, (size*8)/cast(1024 as decimal(12,2)) AS Size_MB,(((size*8)/cast(1024 as decimal(12,2)))/1024) AS Size_GB, type_desc AS TypeDesc, 'SIMPLE' AS RecoveryModel from sys.database_files;
USE acv2; insert into @vDbTbl (id, DbName, DbFileName, Size_MB, Size_GB, TypeDesc, RecoveryModel) select 8 as id, 'acv2' AS DbName, [name] AS DbFileName, (size*8)/cast(1024 as decimal(12,2)) AS Size_MB,(((size*8)/cast(1024 as decimal(12,2)))/1024) AS Size_GB, type_desc AS TypeDesc, 'FULL' AS RecoveryModel from sys.database_files;
USE acreports; insert into @vDbTbl (id, DbName, DbFileName, Size_MB, Size_GB, TypeDesc, RecoveryModel) select 9 as id, 'acreports' AS DbName, [name] AS DbFileName, (size*8)/cast(1024 as decimal(12,2)) AS Size_MB,(((size*8)/cast(1024 as decimal(12,2)))/1024) AS Size_GB, type_desc AS TypeDesc, 'FULL' AS RecoveryModel from sys.database_files;
USE DailyConfBilling; insert into @vDbTbl (id, DbName, DbFileName, Size_MB, Size_GB, TypeDesc, RecoveryModel) select 9 as id, 'DailyConfBilling' AS DbName, [name] AS DbFileName, (size*8)/cast(1024 as decimal(12,2)) AS Size_MB,(((size*8)/cast(1024 as decimal(12,2)))/1024) AS Size_GB, type_desc AS TypeDesc, 'FULL' AS RecoveryModel from sys.database_files;
USE DailyConfBilling; insert into @vDbTbl (id, DbName, DbFileName, Size_MB, Size_GB, TypeDesc, RecoveryModel) select 9 as id, 'DailyConfBilling' AS DbName, [name] AS DbFileName, (size*8)/cast(1024 as decimal(12,2)) AS Size_MB,(((size*8)/cast(1024 as decimal(12,2)))/1024) AS Size_GB, type_desc AS TypeDesc, 'FULL' AS RecoveryModel from sys.database_files;
USE GC_Temp; insert into @vDbTbl (id, DbName, DbFileName, Size_MB, Size_GB, TypeDesc, RecoveryModel) select 9 as id, 'GC_Temp' AS DbName, [name] AS DbFileName, (size*8)/cast(1024 as decimal(12,2)) AS Size_MB,(((size*8)/cast(1024 as decimal(12,2)))/1024) AS Size_GB, type_desc AS TypeDesc, 'FULL' AS RecoveryModel from sys.database_files;
USE GC_DailyBilling; insert into @vDbTbl (id, DbName, DbFileName, Size_MB, Size_GB, TypeDesc, RecoveryModel) select 9 as id, 'GC_DailyBilling' AS DbName, [name] AS DbFileName, (size*8)/cast(1024 as decimal(12,2)) AS Size_MB,(((size*8)/cast(1024 as decimal(12,2)))/1024) AS Size_GB, type_desc AS TypeDesc, 'FULL' AS RecoveryModel from sys.database_files;
USE Jan24BCCMonthlyRun; insert into @vDbTbl (id, DbName, DbFileName, Size_MB, Size_GB, TypeDesc, RecoveryModel) select 9 as id, 'Jan24BCCMonthlyRun' AS DbName, [name] AS DbFileName, (size*8)/cast(1024 as decimal(12,2)) AS Size_MB,(((size*8)/cast(1024 as decimal(12,2)))/1024) AS Size_GB, type_desc AS TypeDesc, 'FULL' AS RecoveryModel from sys.database_files;
USE Jan27v2MonthlyRun; insert into @vDbTbl (id, DbName, DbFileName, Size_MB, Size_GB, TypeDesc, RecoveryModel) select 9 as id, 'Jan27v2MonthlyRun' AS DbName, [name] AS DbFileName, (size*8)/cast(1024 as decimal(12,2)) AS Size_MB,(((size*8)/cast(1024 as decimal(12,2)))/1024) AS Size_GB, type_desc AS TypeDesc, 'FULL' AS RecoveryModel from sys.database_files;
USE Jan13v1MonthlyRun; insert into @vDbTbl (id, DbName, DbFileName, Size_MB, Size_GB, TypeDesc, RecoveryModel) select 9 as id, 'Jan13v1MonthlyRun' AS DbName, [name] AS DbFileName, (size*8)/cast(1024 as decimal(12,2)) AS Size_MB,(((size*8)/cast(1024 as decimal(12,2)))/1024) AS Size_GB, type_desc AS TypeDesc, 'FULL' AS RecoveryModel from sys.database_files;
USE Oct19ACRecon; insert into @vDbTbl (id, DbName, DbFileName, Size_MB, Size_GB, TypeDesc, RecoveryModel) select 9 as id, 'Oct19ACRecon' AS DbName, [name] AS DbFileName, (size*8)/cast(1024 as decimal(12,2)) AS Size_MB,(((size*8)/cast(1024 as decimal(12,2)))/1024) AS Size_GB, type_desc AS TypeDesc, 'FULL' AS RecoveryModel from sys.database_files;
USE testCCCDB; insert into @vDbTbl (id, DbName, DbFileName, Size_MB, Size_GB, TypeDesc, RecoveryModel) select 9 as id, 'testCCCDB' AS DbName, [name] AS DbFileName, (size*8)/cast(1024 as decimal(12,2)) AS Size_MB,(((size*8)/cast(1024 as decimal(12,2)))/1024) AS Size_GB, type_desc AS TypeDesc, 'FULL' AS RecoveryModel from sys.database_files;

select * 
from @vDbTbl
order by size_mb desc


--------------

USE APIRBioConnect
GO
IF EXISTS(SELECT name, recovery_model_desc FROM sys.databases WHERE name = DB_NAME() AND recovery_model_desc = 'FULL') 
BEGIN 
	ALTER DATABASE tempPortal SET RECOVERY SIMPLE ;
	PRINT 'Set recovery mode to Simple.'
END;
GO

DBCC SHRINKFILE (N'BorgataPokerLocal_log' , 10, TRUNCATEONLY)
GO

IF EXISTS(SELECT name, recovery_model_desc FROM sys.databases WHERE name = DB_NAME() AND recovery_model_desc = 'SIMPLE') 
BEGIN 
	ALTER DATABASE tempPortal SET RECOVERY FULL ;
	PRINT 'Set recovery mode to Full.'
END;
GO

--------------



SELECT RTRIM(name) AS [Segment Name], groupid AS [Group Id], filename AS [File Name],
   CAST(size/128.0 AS DECIMAL(10,2)) AS [Allocated Size in MB],
   CAST(FILEPROPERTY(name, 'SpaceUsed')/128.0 AS DECIMAL(10,2)) AS [Space Used in MB],
   CAST([maxsize]/128.0 AS DECIMAL(10,2)) AS [Max in MB],
   CAST([maxsize]/128.0-(FILEPROPERTY(name, 'SpaceUsed')/128.0) AS DECIMAL(10,2)) AS [Available Space in MB],
   CAST((CAST(FILEPROPERTY(name, 'SpaceUsed')/128.0 AS DECIMAL(10,2))/CAST([maxsize]/128.0 AS DECIMAL(10,2)))*100 AS DECIMAL(10,2)) AS [Percent Used]
FROM sysfiles
ORDER BY groupid DESC

--------------


SELECT 
    [TYPE] = A.TYPE_DESC
    ,[FILE_Name] = A.name
    ,[FILEGROUP_NAME] = fg.name
    ,[File_Location] = A.PHYSICAL_NAME
    ,[FILESIZE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0)
    ,[USEDSPACE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - ((SIZE/128.0) - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0))
    ,[FREESPACE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0)
    ,[FREESPACE_%] = CONVERT(DECIMAL(10,2),((A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0)/(A.SIZE/128.0))*100)
    ,[AutoGrow] = 'By ' + CASE is_percent_growth WHEN 0 THEN CAST(growth/128 AS VARCHAR(10)) + ' MB -' 
        WHEN 1 THEN CAST(growth AS VARCHAR(10)) + '% -' ELSE '' END 
        + CASE max_size WHEN 0 THEN 'DISABLED' WHEN -1 THEN ' Unrestricted' 
            ELSE ' Restricted to ' + CAST(max_size/(128*1024) AS VARCHAR(10)) + ' GB' END 
        + CASE is_percent_growth WHEN 1 THEN ' [autogrowth by percent, BAD setting!]' ELSE '' END
FROM sys.database_files A LEFT JOIN sys.filegroups fg ON A.data_space_id = fg.data_space_id 
order by A.TYPE desc, A.NAME; 