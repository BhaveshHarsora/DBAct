/*
Below T-SQL will generate TABLE Schema Script with FOREIGN KEY for given table or 
the specified list of tables in "TabDef" table
*/


DECLARE @pTableName AS VARCHAR(100) = 'RegionMaster'

DECLARE @vTableName AS VARCHAR(100), @vColumnName AS VARCHAR(100), @vDataType AS VARCHAR(50), @vConstName AS VARCHAR(100)
		, @vRefTableName AS VARCHAR(100), @vFKName AS VARCHAR(200), @vRefTablePKColName AS VARCHAR(100), @vTableOrder AS INT;
DECLARE @vSqlTx AS VARCHAR(MAX), @vPreCreateTableDef AS VARCHAR(MAX), @vPostCreateTableDef AS VARCHAR(MAX), @vColumnsDef AS VARCHAR(MAX)
		, @vPKDef AS VARCHAR(MAX), @vFKDropDef AS VARCHAR(MAX), @vFKCreateDef AS VARCHAR(MAX), @vAllSqlTx AS VARCHAR(MAX), @vAllFKDropDef AS VARCHAR(MAX)
		, @vLinePrecedator AS VARCHAR(500), @vLineFollower AS VARCHAR(500)
DECLARE @vIdentityCount AS INT, @vErrorTx AS VARCHAR(MAX)




DECLARE curMast CURSOR
FOR
SELECT DISTINCT TableName, TableOrder
  FROM TabDef WITH(NOLOCK)
  WHERE IsCreated = 0
  ORDER BY TableOrder

OPEN curMast

SET @vAllSqlTx  = ''
SET @vAllFKDropDef = ''

FETCH NEXT FROM curMast INTO @pTableName, @vTableOrder

WHILE @@fetch_status = 0
BEGIN

	SET @vSqlTx = ''
	SET @vColumnsDef = ''
	SET @vFKDropDef = ''
	SET @vFKCreateDef = ''
	SET @vPKDef = ''
	SET @vPreCreateTableDef = ''
	SET @vTableName = ''
	SET @vRefTableName = ''

	SELECT @vTableName = TableName
	  FROM TabDef WITH(NOLOCK)  
	  WHERE TableName = @pTableName
	  AND IsCreated = 0

	SELECT @vPreCreateTableDef = '
IF EXISTS(SELECT 1 FROM sys.tables WHERE name = ''' + TableName + ''')
BEGIN
	DROP TABLE ' + TableName + '
END

CREATE TABLE ' + TableName + '
(
'
	FROM TabDef WITH(NOLOCK)
	WHERE TableName = @vTableName
	AND IsCreated = 0

	

	DECLARE curTabDef CURSOR
	FOR 
	SELECT td.TableName, td.ColumnName, td.DataType, td.ConstName  
	  FROM TabDef td  WITH(NOLOCK)
	  WHERE TableName = @vTableName
	  AND IsCreated = 0

	OPEN curTabDef

	FETCH NEXT FROM curTabDef
	INTO @vTableName, @vColumnName, @vDataType, @vConstName

	SET @vIdentityCount = 0

	WHILE @@fetch_status = 0
	BEGIN
	
		IF @vDataType = 'DOUBLE'
			SET @vDataType = 'float'

		SET @vColumnsDef = @vColumnsDef + ',	' + @vColumnName + '	' + @vDataType  
		
		IF @vConstName LIKE '%IDENTITY%' AND @vIdentityCount = 0
		BEGIN
			SET @vColumnsDef = @vColumnsDef + '	IDENTITY(1,1) '

			SET @vIdentityCount = @vIdentityCount + 1
		END

		SET @vColumnsDef = @vColumnsDef + CHAR(13)

		IF @vConstName LIKE 'FK%'
		BEGIN
			SET @vRefTableName = STUFF(@vConstName, 1, CHARINDEX(' ',  @vConstName), '') 

			SET @vRefTablePKColName = NULL

			SELECT TOP 1 @vRefTablePKColName = COLUMN_NAME  
			FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE 
			WHERE TABLE_NAME = @vRefTableName 
			AND CONSTRAINT_NAME LIKE 'PK%' 

			IF @vRefTablePKColName IS NOT NULL
			BEGIN
				SET @vFKName = 'FK_' + @vTableName + '_' + @vRefTableName + '_' + @vColumnName +''
			
				SET @vFKDropDef = @vFKDropDef + '

IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE name = ''' + @vFKName + ''')
BEGIN							
	ALTER TABLE [' + @vTableName + '] 
		DROP CONSTRAINT [' + @vFKName +']
END;

					'
				SET @vFKCreateDef = @vFKCreateDef + '			
ALTER TABLE [' + @vTableName + ']  WITH NOCHECK
	ADD CONSTRAINT [' + @vFKName +']
	  FOREIGN KEY ([' + @vColumnName + '])
	    REFERENCES ' + @vRefTableName +'(' + @vRefTablePKColName + ')
					'
			END;
			ELSE
			BEGIN
				SET @vErrorTx = 'Foreign Key Reference Table is not defined, Base Table.Column: ' + @vTableName  + '.' + @vColumnName + ' | Referencing Table: ' + @vRefTableName + ''
				RAISERROR(@vErrorTx, 1,16);
			END;			
		END; -- @vConstName LIKE 'FK%'


		FETCH NEXT FROM curTabDef
			INTO @vTableName, @vColumnName, @vDataType, @vConstName
	END; -- WHILE curTabDef

	CLOSE curTabDef
	DEALLOCATE curTabDef


	SELECT @vPKDef = '
	CONSTRAINT [PK_' + TableName +'_' + ColumnName + '] PRIMARY KEY CLUSTERED 
	(
		[' + ColumnName + '] ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	'
	FROM TabDef WITH(NOLOCK)
	WHERE TableName	= @vTableName
	AND ConstName LIKE 'PK%' 
	AND IsCreated = 0


	SET @vColumnsDef = STUFF(@vColumnsDef, 1,1, '') + @vPKDef

	SET @vPostCreateTableDef = '
)'

	
	SET @vLinePrecedator = '
--:: TABLE DEFINATION START: ' + @vTableName +' ::---------------------------------------------------------------------

'
	SET @vLineFollower = '

--:: TABLE DEFINATION END: ' + @vTableName +' ::---------------------------------------------------------------------

'

	SET @vSqlTx = @vLinePrecedator +
				@vFKDropDef +
				@vPreCreateTableDef + 
				@vColumnsDef + 
				@vPostCreateTableDef +
				@vFKCreateDef +
				@vLineFollower


	--SELECT @vSqlTx AS OneTableDefination
	EXEC (@vSqlTx) --One Table

	IF @@ERROR = 0
	BEGIN	
		UPDATE TabDef SET IsCreated = 1 WHERE TableName = @vTableName
	END;


	SET @vAllFKDropDef = @vAllFKDropDef + @vFKDropDef

	SET @vAllSqlTx = @vAllSqlTx + @vSqlTx;

	FETCH NEXT FROM curMast INTO @pTableName, @vTableOrder
END; -- WHILE curMast

CLOSE curMast
DEALLOCATE curMast

SET @vAllSqlTx = @vAllFKDropDef + @vAllSqlTx;

SELECT @vAllSqlTx AS AllTableDefinations
--EXEC (@vAllSqlTx) --One Table
