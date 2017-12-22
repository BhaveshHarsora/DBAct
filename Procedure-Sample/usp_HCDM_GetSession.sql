IF NOT EXISTS(SELECT 1 FROM sys.procedures WHERE name = 'usp_PROJ_GetSession')
BEGIN
	EXEC('CREATE PROCEDURE usp_PROJ_GetSession AS RETURN 0')
END
GO

ALTER PROCEDURE usp_PROJ_GetSession
(
	@pKeyName VARCHAR(50)
	, @pKeyValue VARCHAR(255) OUTPUT
)
AS 
BEGIN

	SET NOCOUNT ON;

	DECLARE @vSqlTx AS NVARCHAR(MAX), @vParams AS NVARCHAR(MAX); 
	DECLARE @vSTblNm AS VARCHAR(MAX), @vDBName AS VARCHAR(50);
	DECLARE @vKv AS VARCHAR(255), @vKn AS VARCHAR(50);

	SET @vDBName = CAST(DB_NAME() AS VARCHAR(50));

	IF ISNULL(@vDBName, '') NOT IN ('TSTPROJNAME')
	BEGIN
		RAISERROR('~ Unauthorised database session access ~', 16, 1)
	END;

	SET @vSTblNm = CONCAT(N'##gtmp_', LOWER(@vDBName), N'_',CAST(@@spid AS VARCHAR))

	SET @vParams = N'@vKn VARCHAR(50), @vKv VARCHAR(255) OUTPUT';
	SET @vSqlTx = CONCAT( N'
	IF EXISTS(SELECT 1 FROM tempdb.sys.tables WHERE NAME = ''', @vSTblNm, ''')
		SELECT  @vKv = xx.[key_value] FROM ' , @vSTblNm , ' AS xx WHERE xx.[key_name] = @vKn
	ELSE
		SELECT @vKv = NULL
	')

	EXEC sys.sp_executesql @vSqlTx, @vParams 
							, @vKn = @pKeyName
							, @vKv = @pKeyValue OUTPUT;


END;
GO
