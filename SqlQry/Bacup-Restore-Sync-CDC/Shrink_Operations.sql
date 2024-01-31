sp_helpdb [TempStaging]

/*
name	fileid	filename	filegroup	size	maxsize	growth	usage
TempStaging	1	E:\SQL2016\Before 2016\TempStaging.mdf	PRIMARY	1607872 KB	Unlimited	1024 KB	data only
TempStaging_log	2	E:\SQL2016\Before 2016\TempStaging_log.ldf	NULL	7458176 KB	2147483648 KB	10%	log only

TempStaging	1	E:\SQL2016\Before 2016\TempStaging.mdf	PRIMARY	1607872 KB	Unlimited	1024 KB	data only
TempStaging_log	2	E:\SQL2016\Before 2016\TempStaging_log.ldf	NULL	9926912 KB	2147483648 KB	10%	log only
*/

select recovery_model, recovery_model_desc,* from sys.databases where name = 'tempstaging' order by 2


SELECT   
	db_name(database_id) as DbName
	, name AS LogicalName		
	, Physical_name
    , size AS Size
    , size * 8/1024 AS Size_MB
	, (size * 8/1024)/1024 AS Size_GB
FROM sys.master_files
where 1=1
AND name LIKE 'PWHCProd01_Log'
AND db_name(database_id) = 'H1172566TEST'
--AND name  like '%_log'
ORDER BY Size_MB --LogFileSize


--sp_who2

--DropShip_log	44869
--History		71195


exec sp_helpdb Products


/*
DropShip : Date 11/1/2018 11:31am
name			size		Size_MB
DropShip		295968		2312	2367744 KB
DropShip_log	5743304		44869	45946432 KB
------------------------------
Products : Date 11/1/2018 01:24pm
Products		996848	7787
Products_log	770760	6021
------------------------------
*/

------------------------------


USE tempPortal
GO
IF EXISTS(SELECT name, recovery_model_desc FROM sys.databases WHERE name = DB_NAME() AND recovery_model_desc = 'FULL') 
BEGIN 
	ALTER DATABASE tempPortal SET RECOVERY SIMPLE ;
END;
GO

DBCC SHRINKFILE (N'Portal_log' , 50, TRUNCATEONLY)
GO

IF EXISTS(SELECT name, recovery_model_desc FROM sys.databases WHERE name = DB_NAME() AND recovery_model_desc = 'SIMPLE') 
BEGIN 
	ALTER DATABASE tempPortal SET RECOVERY FULL ;
END;
GO

------------------------------

DBCC OPENTRAN 

select name, database_id,recovery_model_desc,log_reuse_wait_desc  from sys.databases where name = 'Products'

select * from sys.database_files


--DBCC SHRINKFILE (2, 100);
DBCC LOGINFO;


sp_helpdb Products
--BACKUP LOG databaseName TO DISK='C:\fileName.TRN'



USE SmartPricing
GO

DECLARE @vModelChanged AS BIT = 0;

select name from sys.database_files where type_desc = 'Log'

IF EXISTS(SELECT name, recovery_model_desc FROM sys.databases WHERE name = DB_NAME() AND recovery_model_desc = 'FULL') 
BEGIN 
	ALTER DATABASE SmartPricing SET RECOVERY SIMPLE ;
	SET @vModelChanged = 1
END;

DBCC SHRINKFILE (N'SmartPricing_log' , 10, TRUNCATEONLY)


IF EXISTS(SELECT name, recovery_model_desc FROM sys.databases WHERE name = DB_NAME() AND recovery_model_desc = 'SIMPLE' AND @vModelChanged = 1) 
BEGIN 
	ALTER DATABASE SmartPricing SET RECOVERY FULL ;
END;
GO
