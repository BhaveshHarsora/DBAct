----------------------------------------------
USE PolarisPayroll
GO

SELECT * FROm sys.sysfiles
GO

DBCC SHRINKFILE('empay1_test_log', 1)
BACKUP LOG PolarisPayroll WITH TRUNCATE_ONLY
DBCC SHRINKFILE('empay1_test_log', 1)
GO 

SELECT * FROm sys.sysfiles
GO
----------------------------------------------

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