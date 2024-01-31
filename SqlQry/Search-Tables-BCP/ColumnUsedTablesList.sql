/******************************************************************************************************************************************
-- Columns wise Tables listing query
******************************************************************************************************************************************/

DECLARE @vSchemaName AS VARCHAR(100) = 'TVC'
DECLARE @vTableName AS VARCHAR(100) = '_xTables'

-------------------------------------------------------------------------------------------------------------------------------------------

SET NOCOUNT ON;

DECLARE @vColumns AS VARCHAR(MAX), @vColumnCases AS VARCHAR(MAX),  @vColumnOrders AS VARCHAR(MAX), @vColumnSelectOrders AS VARCHAR(MAX)
DECLARE @vSqlTx AS VARCHAR(MAX)



SELECT @vColumns = STUFF( CAST(
(SELECT  ',[' + c.COLUMN_NAME + ']'
	FROM INFORMATION_SCHEMA.COLUMNS c  
	WHERE c.TABLE_NAME = @vTableName
	AND c.TABLE_SCHEMA = @vSchemaName
	ORDER BY c.ORDINAL_POSITION
	FOR XML PATH ('')) AS VARCHAR(MAX)), 1, 1, '')


SELECT @vColumnCases = STUFF( CAST(
(SELECT  ', CASE WHEN [' + c.COLUMN_NAME + '] IS NOT NULL THEN TABLE_NAME ELSE '''' END AS [' + c.COLUMN_NAME + '] '
	FROM INFORMATION_SCHEMA.COLUMNS c  
	WHERE c.TABLE_NAME = @vTableName
	AND c.TABLE_SCHEMA = @vSchemaName
	ORDER BY c.ORDINAL_POSITION
	FOR XML PATH ('')) AS VARCHAR(MAX)), 1, 1, '')

SELECT @vColumnOrders = STUFF( CAST(
(SELECT  ', [' + c.COLUMN_NAME + '_1]'
	FROM INFORMATION_SCHEMA.COLUMNS c  
	WHERE c.TABLE_NAME = @vTableName
	AND c.TABLE_SCHEMA = @vSchemaName
	ORDER BY c.ORDINAL_POSITION
	FOR XML PATH ('')) AS VARCHAR(MAX)), 1, 1, '')

SELECT @vColumnSelectOrders = STUFF( CAST(
(SELECT  ', 1 + CASE WHEN [' + c.COLUMN_NAME + '] IS NOT NULL THEN  1 ELSE 99 END AS  [' + c.COLUMN_NAME + '_1] '
	FROM INFORMATION_SCHEMA.COLUMNS c  
	WHERE c.TABLE_NAME = @vTableName
	AND c.TABLE_SCHEMA = @vSchemaName
	ORDER BY c.ORDINAL_POSITION
	FOR XML PATH ('')) AS VARCHAR(MAX)), 1, 1, '')


SET @vSqlTx = ' 
SELECT ' + @vColumns + '
FROM (
		SELECT ' + @vColumnCases + '
		, ' + @vColumnSelectOrders + '
		FROM (
			SELECT b.TABLE_NAME, c.COLUMN_NAME
			FROM INFORMATION_SCHEMA.COLUMNS c  
			LEFT JOIN INFORMATION_SCHEMA.COLUMNS AS b
				ON c.COLUMN_NAME = b.COLUMN_NAME
			WHERE c.TABLE_NAME = ''' + @vTableName +''' 
			AND c.TABLE_SCHEMA = ''' + @vSchemaName + '''
			AND b.TABLE_SCHEMA = ''' + @vSchemaName + '''
		) AS t
		PIVOT
		(
			MAX(COLUMN_NAME) FOR COLUMN_NAME IN ( ' + @vColumns + ' )
		) AS p
  ) AS a
ORDER BY ' + @vColumnOrders

PRINT @vSqlTx
--SELECT  @vColumns, @vColumnCases, @vColumnOrders, @vSqlTx

EXEC (@vSqlTx);



