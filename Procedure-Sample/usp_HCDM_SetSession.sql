IF NOT EXISTS(SELECT 1 FROM sys.procedures WHERE name = 'usp_HCDM_SetSession')
BEGIN
	EXEC('CREATE PROCEDURE usp_HCDM_SetSession AS RETURN 0')
END
GO

ALTER PROCEDURE usp_HCDM_SetSession
(
	@pKeyName VARCHAR(50)
	, @pKeyValue VARCHAR(255)
	, @pRemoveKeyFg BIT = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @vSqlTx AS VARCHAR(MAX), @vCreateTx AS VARCHAR(MAX), @vMergeTx AS VARCHAR(MAX), @vSTblNm AS VARCHAR(50), @vDBName AS VARCHAR(50);

	SET @vDBName = CAST(DB_NAME() AS VARCHAR(50));

	IF ISNULL(@vDBName, '') NOT IN ('HCDM')
	BEGIN
		RAISERROR('~ Unauthorised database session access ~', 16, 1)
	END;

	SET @vSTblNm = CONCAT('##gtmp_', LOWER(@vDBName) ,'_', CAST(@@spid as varchar))

	SELECT @vCreateTx = CONCAT('
	CREATE TABLE ', @vSTblNm, '
	(
		[key_name] varchar(50) PRIMARY KEY NOT NULL,
		[key_value] varchar(255) NULL
	);')
	WHERE NOT EXISTS(SELECT 1 FROM tempdb.sys.tables WHERE NAME = @vSTblNm)

	SELECT @vMergeTx = CONCAT('
	MERGE INTO ', @vSTblNm, ' AS a
	USING (SELECT ''', @pKeyName, ''' AS [key_name], ''', @pKeyValue, ''' AS [key_value]) AS b
		ON a.[key_name] = b.[key_name]
	WHEN MATCHED AND ', CAST(ISNULL(@pRemoveKeyFg, 0) AS VARCHAR), ' = 1 THEN
		DELETE
	WHEN MATCHED AND ', CAST(ISNULL(@pRemoveKeyFg, 0) AS VARCHAR), ' = 0 THEN	
		UPDATE SET a.[key_value] = b.[key_value]
	WHEN NOT MATCHED AND ', CAST(ISNULL(@pRemoveKeyFg, 0) AS VARCHAR), ' = 0 THEN	
		INSERT ([key_name], [key_value])
		VALUES(b.[key_name], b.[key_value]);	
	');

	SELECT @vSqlTx = CONCAT(@vCreateTx, @vMergeTx)
	--SELECT @vSqlTx
	
	EXEC (@vSqlTx);	
END;
GO