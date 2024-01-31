SET NOCOUNT ON

CREATE TABLE #TableInfo
(
	ID INT IDENTITY(1,1)
	, TableName		VARCHAR(100)
	, ColumnName	VARCHAR(100)
)
INSERT INTO #TableInfo
	( TableName, ColumnName)
	SELECT
		tableSchema.TABLE_SCHEMA + '.' + SysObjects.name
		, SysColumns.Name
	FROM sysobjects 
		INNER JOIN SysColumns ON SysColumns.id = sysobjects .id
			AND SysColumns.xtype IN ( 167, 175, 239, 231, 35, 99 )
		INNER JOIN information_schema.tables AS tableSchema ON tableSchema.TABLE_NAME = SysObjects.name
	WHERE sysobjects.xtype='U'
	ORDER BY sysobjects.Name, SysColumns.Name
	
DECLARE @NoOfRecord INT
DECLARE @CurrentRecord INT
DECLARE @TableName	VARCHAR(100)
DECLARE @ColumnName	VARCHAR(100)
DECLARE @SQLCommand VARCHAR(8000)
DECLARE @FindName	VARCHAR(8000)
DECLARE @ReplaceName VARCHAR(8000)

SET @NoOfRecord = 0	
SET @CurrentRecord = 1
SET @TableName	= ''
SET @ColumnName	= ''
SET @SQLCommand = ''
SET @FindName	= 'Eqis'
SET @ReplaceName = 'Sofweb'

SELECT @NoOfRecord = MAX(ID)
FROM #TableInfo

WHILE (@CurrentRecord <= @NoOfRecord )
	BEGIN
		SELECT
			@TableName	= TableName
			, @ColumnName = ColumnName
		FROM #TableInfo
		WHERE ID = @CurrentRecord
		
		SET @SQLCommand = 'IF EXISTS(SELECT * FROM ' + @TableName + ' WHERE ' + @ColumnName + ' LIKE ''%' + @FindName + '%'')' +
			' BEGIN ' +
			'	PRINT ''UPDATE ' + @TableName +
			'	SET ' + @ColumnName + ' = REPLACE( CAST(' + @ColumnName + ' AS VARCHAR(8000)), ''''' + @FindName + ''''', ''''' + @ReplaceName + ''''') ''' +
			' END '
			
		-- PRINT @SQLCommand
		EXECUTE(@SQLCommand)
		SET @CurrentRecord = @CurrentRecord + 1
	END
DROP TABLE #TableInfo
