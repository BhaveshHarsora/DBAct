USE [master]
GO

ALTER DATABASE [tempPortal] 
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO


IF @@ERROR = 0
BEGIN
	PRINT CONCAT(GETDATE(), ' : ', 'Database [tempPortal] set to SINGLE_USER and Started database restoring... ');

	RESTORE DATABASE [tempPortal] 
		FROM  DISK = N'C:\bu\Portal.dat' 
			WITH  FILE = 1
			,  MOVE N'Portal' TO N'C:\dat\tempPortal.mdf'
			,  MOVE N'Portal_log' TO N'C:\dat\tempPortal_log.ldf'
			,  NOUNLOAD
			,  REPLACE
			,  STATS = 5;

	IF @@ERROR = 0
	BEGIN
		PRINT CONCAT(GETDATE(), ' : ', 'Database [tempPortal] Restored Successfully!');
	END;
	ELSE
	BEGIN
		PRINT CONCAT(GETDATE(), ' : ', 'Database [tempPortal] Restored failed, please see previous error.');
	END;

END;
ELSE
BEGIN
	PRINT CONCAT(GETDATE(), ' : ', 'Unable to change [tempPortal] database status SINGLE_USER ');
END;
GO


ALTER DATABASE [tempPortal] 
	SET MULTI_USER;
GO
PRINT CONCAT(GETDATE(), ' : ', 'Database [tempPortal] Set to MULTI_USER');
GO

GO
PRINT '~DONE~'
GO
