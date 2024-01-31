/*
Date: 12 Aug 2019
Ref: https://support.onlineschedule.com/browse/SI-195 : gecstage.com - complete setup of restoring data and sites weekly
*/
USE [master]
GO

DECLARE @vBackupFolderPath SYSNAME = 'C:\bu\'
DECLARE @vBackupFilePath AS NVARCHAR(MAX);
DECLARE @vErrorTx AS VARCHAR(MAX)


PRINT CONCAT(GETDATE(), ' : ', 'Started Restoring database [Portal]');

DECLARE @vFiles AS TABLE
(
	subdirectory NVARCHAR(255),
	depth INT,
	[file] INT
)
INSERT INTO @vFiles (subdirectory, depth, [file])
EXEC master..xp_dirtree @vBackupFolderPath, 10, 1;

SELECT TOP 1 @vBackupFilePath = CONCAT(@vBackupFolderPath,a.subdirectory)
FROM @vFiles AS a
WHERE a.subdirectory LIKE 'Portal%'
ORDER BY a.subdirectory DESC

PRINT CONCAT(GETDATE(), ' : ', 'Backup File Path : ', @vBackupFilePath);

IF (ISNULL(@vBackupFilePath, '') = '' OR PARSENAME(@vBackupFilePath,1) NOT IN ('dat', 'bak'))
BEGIN
	SET @vErrorTx  = '~* Portal Databas Backup file not found or its not valid.  *~';
	RAISERROR(@vErrorTx , 16, 1)
	RETURN 0;
END;


ALTER DATABASE [Portal] 
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

IF @@ERROR = 0
BEGIN
	PRINT CONCAT(GETDATE(), ' : ', 'Database [Portal] set to SINGLE_USER and Started database restoring... ');

	RESTORE DATABASE [Portal] 
		FROM  DISK = @vBackupFilePath
			WITH  FILE = 1
			,  MOVE N'Portal' TO N'E:\dat\Portal.mdf'
			,  MOVE N'Portal_log' TO N'E:\log\Portal_log.ldf'
			,  NOUNLOAD
			,  REPLACE
			,  STATS = 5;

	IF @@ERROR = 0
	BEGIN
		PRINT CONCAT(GETDATE(), ' : ', 'Database [Portal] Restored Successfully!');
	END;
	ELSE	
	BEGIN
		PRINT CONCAT(GETDATE(), ' : ', 'Database [Portal] Restored failed, please see previous error.');
	END;

END;
ELSE
BEGIN
	PRINT CONCAT(GETDATE(), ' : ', 'Unable to change [Portal] database status SINGLE_USER ');
END;
GO


ALTER DATABASE [Portal] 
	SET MULTI_USER;

GO
PRINT CONCAT(GETDATE(), ' : ', 'Database [Portal] Set to MULTI_USER');
GO

GO
PRINT '~DONE~'
GO
