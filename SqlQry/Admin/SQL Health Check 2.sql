/*====================================================== SERVER CONFIGURATIONS ======================================================*/

/*~~~ change SQL Server name if computername changed ~~~*/
SELECT  
	HOST_NAME() AS 'host_name()',
	@@servername AS 'ServerName\InstanceName',
	SERVERPROPERTY('servername') AS 'ServerName',
	SERVERPROPERTY('machinename') AS 'Windows_Name',
	SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS 'NetBIOS_Name',
	SERVERPROPERTY('instanceName') AS 'InstanceName',
	SERVERPROPERTY('IsClustered') AS 'IsClustered'

/*~~~ Instant File Initialization ~~~*/
IF RIGHT(@@version, LEN(@@version) - 3 - CHARINDEX(' ON ', @@VERSION)) NOT LIKE 'Windows%' 
BEGIN 
	SELECT  SERVERPROPERTY('ServerName') AS [Server Name] , 
			RIGHT(@@version, 
				  LEN(@@version) - 3 - CHARINDEX(' ON ', @@VERSION)) AS [OS Info] , 
			LEFT(@@VERSION, CHARINDEX('-', @@VERSION) - 2) + ' ' 
			+ CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(300)) AS [SQL Server Version] , 
			'N/A' AS [service_account] , 
			'N/A' AS [instant_file_initialization_enabled] 
END 
ELSE 
BEGIN 
	IF EXISTS ( SELECT  0 
				FROM    sys.all_objects AO 
						INNER JOIN sys.all_columns AC ON AC.object_id = AO.object_id 
				WHERE   AO.name LIKE '%dm_server_services%' 
						AND AC.name = 'instant_file_initialization_enabled' ) 
		BEGIN 
			EXEC('   SELECT  SERVERPROPERTY(''ServerName'') AS [Server Name] , 
			RIGHT(@@version, LEN(@@version) - 3 - CHARINDEX('' ON '', @@VERSION)) AS [OS Info] , 
			LEFT(@@VERSION, CHARINDEX(''-'', @@VERSION) - 2)  + '' '' +  CAST(SERVERPROPERTY(''ProductVersion'') AS NVARCHAR(300) ) AS [SQL Server Version], 
			service_account , 
			instant_file_initialization_enabled 
			FROM    sys.dm_server_services 
			WHERE   servicename LIKE ''SQL Server (%''') 
		END 
	ELSE 
		BEGIN 
			SELECT  SERVERPROPERTY('ServerName') AS [Server Name] , 
					RIGHT(@@version, 
						  LEN(@@version) - 3 - CHARINDEX(' ON ', @@VERSION)) AS [OS Info] , 
					LEFT(@@VERSION, CHARINDEX('-', @@VERSION) - 2) + ' ' 
					+ CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(300)) AS [SQL Server Version] , 
					service_account AS [service_account] , 
					'N/A' AS [instant_file_initialization_enabled] 
			FROM    sys.dm_server_services 
			WHERE   servicename LIKE 'SQL Server (%' 
		END   
END 



		
/*~~~ Check any jobs not owned by SA ~~~*/
SELECT j.name as [NON-SA-JOB], suser_sname(owner_sid) as [OWNER]
FROM msdb.dbo.sysjobs AS j
INNER JOIN msdb.dbo.syscategories AS C ON j.category_id = C.category_id
WHERE j.owner_sid <> 0x01 and C.name <> 'Report Server';
GO

Declare 
@Job_OWNERSCMD nVarchar(Max)
Set @Job_OWNERSCMD = 'Use master;

-- Jobs with NON-SA-OWNERS
	'
	Select @Job_OWNERSCMD  = @Job_OWNERSCMD + 
	'USE msdb; EXEC msdb.dbo.sp_update_job @job_name = ' + QUOTENAME(j.name) + ', @owner_login_name = ''sa'';' +  CHAR(10)
	FROM msdb.dbo.sysjobs AS j
	INNER JOIN msdb.dbo.syscategories AS C ON j.category_id = C.category_id
	WHERE j.owner_sid <> 0x01 and C.name <> 'Report Server';  			
	 
Print @Job_OWNERSCMD
--Exec (@Job_OWNERSCMD)
		
	
/*~~~ Number of CPUs ~~~*/
SELECT cpu_count
FROM [sys].[dm_os_sys_info]	

/*~~~ Check number of TempDB files ~~~*/
-- = CPU up to 8
use tempdb
SELECT file_id, type_desc, name, physical_name, state_desc
FROM sys.database_files
GO
	
/*~~~ Configuration Options ~~~*/
Select  
	name,  
	value,  
	value_in_use,  
	is_dynamic,  
	is_advanced 
from  
	sys.configurations  
where  
	name in ('cost threshold for parallelism', 'backup checksum default', 'max degree of parallelism', 'max server memory (MB)', 'optimize for ad hoc workloads', 'remote admin connections', 'show advanced options', 'backup compression default')  
order by  
	name; 

/*~~~ Alerts/ Traces ~~~*/ 
dbcc tracestatus() 
	/* looking for trace 3226 1117, and 1118 */
	--DBCC TRACEON (3226, -1);
	--DBCC TRACEON (1117, -1);
	--DBCC TRACEON (1118, -1);

	-- Needs to be added as a startup parameter in SQL configuration manager (-T3226)

SELECT [name] 
FROM [dbo].[sysalerts] 
where name not like 'Replication%' and (name not Like 'deadlock%') 
GO 
	/* Looking for errors 16-25 and 823,824, and 825 */
		
/*===================================================== DATABASE CONFIGURATIONS =====================================================*/

/*~~~ Find Current Location of Data and Log File of All the Database ~~~*/
SELECT @@servername, TYPE_DESC, name, physical_name AS current_file_location, state_desc /*comment out here if the query fails*/, (size*8)/1024 SizeMB, (growth*8)/1024 GrowthSizeMB
FROM sys.master_files order by name;
	
/*~~~ Check for % autogrowth ~~~*/
SELECT 
DB_name(S.database_id) AS [Database Name] 
	,	S.[name] AS [Logical Name]
	,	S.[physical_name] AS [File Name] 
	,	CONVERT(VARCHAR(10),S.growth) +'%' AS [Growth] 
FROM sys.master_files AS S 
WHERE S.is_percent_growth = 1;
	

/*~~~ Auto Close, Auto Shrink, Page Verify, Recovery Model, DB owner, Compat Level~~~*/
SELECT 
	name as [Database Name]
	,	is_auto_close_on as [Auto Close]
	,	is_auto_shrink_on as [Auto Shrink]
	,   page_verify_option_desc as [Should be Checksum]
	,	recovery_model_desc as [Recovery Model]
	,	suser_sname(owner_sid) as [owner name]
	,	target_recovery_time_in_seconds as [Recovery Target (should be 60)]
from sys.databases
where state_desc = 'ONLINE'
order by name

/*~~~ Autogrowth changes NEEDED ~~~*/
/* Dynamic Auto Grow for Data Files */

Declare 
@auto_growCMD0 nVarchar(Max)
Set @auto_growCMD0 = 'Use master;
-- Data Files with % Growth
	
	'
	Select @auto_growCMD0  = @auto_growCMD0 + 
	'ALTER DATABASE ['+DB_NAME(database_id)+'] MODIFY FILE ( NAME = N'''+name+''', FILEGROWTH = 128MB );' + CHAR(10)
	from sys.master_files
	Where type = 0 and state_desc = 'ONLINE' and is_percent_growth = 1  ; 
	SET @auto_growCMD0  = @auto_growCMD0 + '
	
-- Log Files with % Growth
	'
	Select @auto_growCMD0  = @auto_growCMD0 + 
	'ALTER DATABASE ['+DB_NAME(database_id)+'] MODIFY FILE ( NAME = N'''+name+''', FILEGROWTH = 64MB );' +  CHAR(10)
	from sys.master_files
	Where type = 1 and state_desc = 'ONLINE' and is_percent_growth = 1 ;

	 
Print @auto_growCMD0
--Exec (@auto_growCMD0)
		
/*~~~~~ Verify Last good CheckDB~~~~~~*/
SET NOCOUNT ON
CREATE TABLE #DBInfo_LastKnownGoodCheckDB
	(
		ParentObject varchar(1000) NULL,
		Object varchar(1000) NULL,
		Field varchar(1000) NULL,
		Value varchar(1000) NULL,
		DatabaseName varchar(1000) NULL
	
	)
DECLARE csrDatabases CURSOR FAST_FORWARD LOCAL FOR
-- Excludes tempdb and any offline databases
SELECT name FROM sys.databases WHERE name NOT IN ('tempdb') and state_desc = 'ONLINE'
OPEN csrDatabases
DECLARE 
	@DatabaseName varchar(1000),
	@SQL varchar(8000)
FETCH NEXT FROM csrDatabases INTO @DatabaseName
WHILE @@FETCH_STATUS = 0
BEGIN
	--Create dynamic SQL to be inserted into temp table
	SET @SQL = 'DBCC DBINFO (' + CHAR(39) + @DatabaseName + CHAR(39) + ') WITH TABLERESULTS'
	--Insert the results of the DBCC DBINFO command into the temp table
	INSERT INTO #DBInfo_LastKnownGoodCheckDB
	(ParentObject, Object, Field, Value) EXEC(@SQL)
	--Set the database name where it has yet to be set
	UPDATE #DBInfo_LastKnownGoodCheckDB
	SET DatabaseName = @DatabaseName
	WHERE DatabaseName IS NULL
FETCH NEXT FROM csrDatabases INTO @DatabaseName
END
--Get rid of the rows that I don't care about
DELETE FROM #DBInfo_LastKnownGoodCheckDB
WHERE Field <> 'dbi_dbccLastKnownGood'
SELECT 
	DatabaseName, 
	CAST(Value AS datetime) AS LastGoodCheckDB,
	DATEDIFF(dd, CAST(Value AS datetime), GetDate()) AS DaysSinceGoodCheckDB,
	DATEDIFF(hh, CAST(Value AS datetime), GetDate()) AS HoursSinceGoodCheckDB
FROM #DBInfo_LastKnownGoodCheckDB
ORDER BY DaysSinceGoodCheckDB DESC

DROP TABLE #DBInfo_LastKnownGoodCheckDB

/*~~~~~ Verify FUll/DIFF frequency over the past 14 days ~~~~~*/
SELECT distinct
	b.server_name as 'Source_Server',
	b.database_name
	,b.is_copy_only,
	b.backup_start_date, --b.backup_start_date as [time],
	b.backup_finish_date, --b.backup_finish_date as [time],
	convert(decimal, (b.backup_size/1024/1024)) as [Size in MB], --Backup Size in MB
	convert(decimal, (b.backup_size/1024/1024/1024)) as [Size in GB], --Backup Size in Gb
	CASE WHEN b.type = 'D' then 'Full'
	WHEN b.type = 'I' then 'Differential'
	ELSE b.type
	END as 'backup_type',
	datediff(Mi, b.backup_start_date,b.backup_finish_date) as 'duration_min',
	b.recovery_model,
	f.physical_device_name,
	b.user_name
FROM msdb.dbo.backupmediafamily f
INNER JOIN msdb.dbo.backupset b ON f.media_set_id = b.media_set_id
WHERE b.type in ('D') and database_name not in ('master','MSDB','Model')
and (b.backup_start_date >=CONVERT(VARCHAR(10),dateadd(day,-14,getdate()),120))and is_copy_only = 0 -- and b.backup_start_date < CONVERT(VARCHAR(10),GETDATE(),120))
--and database_name ='DataMart_master'--'DM_1007_NestleUSAllOpcos'
Order by b.database_name, backup_start_date desc,backup_type

SELECT distinct
	b.server_name as 'Source_Server',
	b.database_name
	,b.is_copy_only,
	b.backup_start_date, --b.backup_start_date as [time],
	b.backup_finish_date, --b.backup_finish_date as [time],
	convert(decimal, (b.backup_size/1024/1024)) as [Size in MB], --Backup Size in MB
	convert(decimal, (b.backup_size/1024/1024/1024)) as [Size in GB], --Backup Size in Gb
	CASE WHEN b.type = 'D' then 'Full'
	WHEN b.type = 'I' then 'Differential'
	ELSE b.type
	END as 'backup_type',
	datediff(Mi, b.backup_start_date,b.backup_finish_date) as 'duration_min',
	b.recovery_model,
	f.physical_device_name,
	b.user_name
FROM msdb.dbo.backupmediafamily f
INNER JOIN msdb.dbo.backupset b ON f.media_set_id = b.media_set_id
WHERE b.type in ('I') and database_name not in ('master','MSDB','Model')
and (b.backup_start_date >=CONVERT(VARCHAR(10),dateadd(day,-14,getdate()),120))and is_copy_only = 0 -- and b.backup_start_date < CONVERT(VARCHAR(10),GETDATE(),120))
--and database_name ='DataMart_master'--'DM_1007_NestleUSAllOpcos'
Order by b.database_name, backup_start_date desc,backup_type

/*~~~~~ Verify LOG frequency over the past 1 days ~~~~~*/
SELECT distinct
	b.server_name as 'Source_Server',
	b.database_name
	,b.is_copy_only,
	b.backup_start_date, --b.backup_start_date as [time],
	b.backup_finish_date, --b.backup_finish_date as [time],
	convert(decimal, (b.backup_size/1024/1024)) as [Size in MB], --Backup Size in MB
	convert(decimal, (b.backup_size/1024/1024/1024)) as [Size in GB], --Backup Size in Gb
	CASE WHEN b.type = 'D' then 'Full'
	WHEN b.type = 'I' then 'Differential'
	ELSE b.type
	END as 'backup_type',
	datediff(Mi, b.backup_start_date,b.backup_finish_date) as 'duration_min',
	b.recovery_model,
	f.physical_device_name,
	b.user_name
FROM msdb.dbo.backupmediafamily f
INNER JOIN msdb.dbo.backupset b ON f.media_set_id = b.media_set_id
WHERE b.type in ('L') and database_name not in ('master','MSDB','Model')
and (b.backup_start_date >=CONVERT(VARCHAR(10),dateadd(day,-1,getdate()),120))and is_copy_only = 0 -- and b.backup_start_date < CONVERT(VARCHAR(10),GETDATE(),120))
--and database_name ='DataMart_master'--'DM_1007_NestleUSAllOpcos'
Order by b.database_name, backup_start_date desc,backup_type
    

/*~~~~~ Verify FUll backup frequency for system databases over the past 14 days ~~~~~*/
SELECT distinct
	b.server_name as 'Source_Server',
	b.database_name
	,b.is_copy_only,
	b.backup_start_date, --b.backup_start_date as [time],
	b.backup_finish_date, --b.backup_finish_date as [time],
	convert(decimal, (b.backup_size/1024/1024)) as [Size in MB], --Backup Size in MB
	convert(decimal, (b.backup_size/1024/1024/1024)) as [Size in GB], --Backup Size in Gb
	CASE WHEN b.type = 'D' then 'Full'
	WHEN b.type = 'I' then 'Differential'
	ELSE b.type
	END as 'backup_type',
	datediff(Mi, b.backup_start_date,b.backup_finish_date) as 'duration_min',
	b.recovery_model,
	f.physical_device_name,
	b.user_name
FROM msdb.dbo.backupmediafamily f
INNER JOIN msdb.dbo.backupset b ON f.media_set_id = b.media_set_id
WHERE b.type in ('D') and database_name in ('master','MSDB','Model')
and (b.backup_start_date >=CONVERT(VARCHAR(10),dateadd(day,-7,getdate()),120)) and is_copy_only = 0 -- and b.backup_start_date < CONVERT(VARCHAR(10),GETDATE(),120))
--and database_name ='DataMart_master'--'DM_1007_NestleUSAllOpcos'
Order by b.database_name, backup_start_date desc,backup_type



