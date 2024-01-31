/*
Date: 29-Jan-2018
T-SQL for Searching text acrosh all table's data.
*/	

DECLARE @SearchStr nvarchar(100)

SET @SearchStr = N'bicycles' --> ENTER text to be Searched acros all tables Data.

BEGIN
	IF OBJECT_ID('tempdb..#Results') IS NOT NULL 
		DROP TABLE #Results;
	CREATE TABLE #Results (ColumnName nvarchar(370), ColumnValue nvarchar(3630), PkColumnName VARCHAR(100), PkColumnValue VARCHAR(100))

    SET NOCOUNT ON

    DECLARE @TableName nvarchar(256), @ColumnName nvarchar(128), @SearchStr2 nvarchar(110), @pkColumnName AS VARCHAR(100)
		, @vSqlTx AS VARCHAR(MAX)
    SET  @TableName = ''
    SET @SearchStr2 = QUOTENAME('%' + @SearchStr + '%','''')

    WHILE @TableName IS NOT NULL

    BEGIN
        SET @ColumnName = ''
        SET @TableName = 
        (
            SELECT MIN(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME))
            FROM     INFORMATION_SCHEMA.TABLES
            WHERE         TABLE_TYPE = 'BASE TABLE'
                AND    QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) > @TableName
                AND    OBJECTPROPERTY(
                        OBJECT_ID(
                            QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)
                             ), 'IsMSShipped'
                               ) = 0
        )

        WHILE (@TableName IS NOT NULL) AND (@ColumnName IS NOT NULL)
        BEGIN            
			SELECT @ColumnName = '', @pkColumnName = '';

            SELECT @ColumnName = MIN(QUOTENAME(a.name))
				, @pkColumnName = ISNULL(MIN(QUOTENAME(e.COLUMN_NAME)), '')
            FROM sys.columns AS a
			JOIN sys.tables AS b
				JOIN sys.schemas AS c
					ON c.schema_id = b.schema_id
				ON a.object_id = b.object_id					
			JOIN sys.types AS d
				ON d.system_type_id = a.system_type_id
			LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS e
				JOIN sys.key_constraints AS f
					ON f.name = e.CONSTRAINT_NAME
					AND f.type = 'PK'
				ON e.CONSTRAINT_SCHEMA = c.name
				AND e.TABLE_NAME = b.name
            WHERE a.encryption_type IS NULL
			AND c.name= PARSENAME(@TableName, 2)
            AND b.name = PARSENAME(@TableName, 1)
            AND d.name IN ('char', 'varchar', 'nchar', 'nvarchar', 'int', 'decimal')
            AND QUOTENAME(a.name) > @ColumnName 
			--GROUP BY e.COLUMN_NAME

            IF @ColumnName IS NOT NULL
            BEGIN

				SET @vSqlTx =  'SELECT ''' + @TableName + '.' + @ColumnName + '''
										, LEFT(' + @ColumnName + ', 3630) 
										, ''' + @pkColumnName + '''
										, ' + CASE WHEN @pkColumnName = '' THEN '''''' ELSE 'CAST(' + @pkColumnName + ' AS VARCHAR(MAX))' END + ' 
								FROM ' + @TableName + ' (NOLOCK) ' +
								' WHERE ' + @ColumnName + ' LIKE ' + @SearchStr2
                INSERT INTO #Results
                EXEC (@vSqlTx);

				--PRINT @vSqlTx
            END
        END    
    END

    SELECT ColumnName, ColumnValue, PkColumnName, PkColumnValue FROM #Results

END;
GO