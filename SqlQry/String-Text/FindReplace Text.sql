SET NOCOUNT ON

DECLARE @Table TABLE
(
	ID INT IDENTITY(1,1)
	, TableName		VARCHAR(100)
	, ColumnName	VARCHAR(100)
)
INSERT INTO @Table
	SELECT tableSchema.TABLE_SCHEMA + '.' + SysObjects.name
		, SysColumns.Name
	FROM sysobjects 
		INNER JOIN SysColumns ON SysColumns.id = sysobjects .id
			AND SysColumns.xtype IN ( 167, 175, 239, 231, 35, 99 )
		INNER JOIN information_schema.tables AS tableSchema ON tableSchema.TABLE_NAME = SysObjects.name
	WHERE sysobjects.xtype='U'
	ORDER BY sysobjects.Name, SysColumns.Name
	
DECLARE @NoOfRecord		INT = 0	
DECLARE @CurrentRecord	INT = 1
DECLARE @TableName		VARCHAR(100) = ''
DECLARE @ColumnName		VARCHAR(100) = ''
DECLARE @SQLCommand		VARCHAR(MAX) = ''
DECLARE @FindName		VARCHAR(MAX) = 'EDW Export'
DECLARE @ReplaceName	VARCHAR(MAX) = ''
DECLARE @FindOnly		BIT = 1

SELECT @NoOfRecord = MAX(ID)
FROM @Table

WHILE (@CurrentRecord <= @NoOfRecord )
	BEGIN
		BEGIN TRY
			SELECT
				@TableName	= TableName
				, @ColumnName = ColumnName
			FROM @Table
			WHERE ID = @CurrentRecord
			
			IF (@FindOnly = 1)
				BEGIN
					SET @SQLCommand = 'IF EXISTS(SELECT * FROM ' + @TableName + ' WHERE [' + @ColumnName + '] LIKE ''%' + @FindName + '%'')' +
						' BEGIN ' +
						'		PRINT ''SELECT * FROM ' + @TableName + ' WHERE [' + @ColumnName + '] LIKE ''''%' + @FindName + '%''''''' +
						' END '
				END
			ELSE
				BEGIN
					SET @SQLCommand = 'IF EXISTS(SELECT * FROM ' + @TableName + ' WHERE [' + @ColumnName + '] LIKE ''%' + @FindName + '%'')' +
						' BEGIN ' +
						'	PRINT ''UPDATE ' + @TableName +
						'	SET [' + @ColumnName + '] = REPLACE(' + @ColumnName + ', ''''' + @FindName + ''''', ''''' + @ReplaceName + ''''') ''' +
						' END '
				END
				
			--PRINT @SQLCommand
			EXECUTE(@SQLCommand)
		END TRY
		BEGIN CATCH
			PRINT 'Error : ' + @SQLCommand
		END CATCH
		SET @CurrentRecord = @CurrentRecord + 1
	END
