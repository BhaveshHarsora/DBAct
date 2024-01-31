/*
BH20230201 : T-SQL to Get Database and its Usage space information
*/
USe master
GO

DECLARE @vDbName AS VARCHAR(255), @vSqlTx AS NVARCHAR(MAX);
DECLARE @tTmp AS TABLE (
	[TYPE]			VARCHAR(255)
	, [FILE_Name]		VARCHAR(255)
	, FILESIZE_MB		VARCHAR(255)
	, USEDSPACE_MB	VARCHAR(255)
	, FREESPACE_MB	VARCHAR(255)
	, FREESPACE_PER		VARCHAR(255)
	, AutoGrow		VARCHAR(255)
)


DECLARE curDBs CURSOR LOCAL FAST_FORWARD FOR
select name AS DbName
from sys.databases 

OPEN curDBs;
FETCH curDBs INTO @vDbName;

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @vSqlTx = CONCAT('
	USE [', @vDbName ,'];
	SELECT 
		[TYPE] = A.TYPE_DESC
		,[FILE_Name] = A.name
		,[FILESIZE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0)
		,[USEDSPACE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - ((SIZE/128.0) - CAST(FILEPROPERTY(A.NAME, ''SPACEUSED'') AS INT)/128.0))
		,[FREESPACE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, ''SPACEUSED'') AS INT)/128.0)
		,[FREESPACE_%] = CONVERT(DECIMAL(10,2),((A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, ''SPACEUSED'') AS INT)/128.0)/(A.SIZE/128.0))*100)		
		,[AutoGrow] = ''By '' + CASE is_percent_growth WHEN 0 THEN CAST(growth/128 AS VARCHAR(10)) + '' MB -'' 
			WHEN 1 THEN CAST(growth AS VARCHAR(10)) + ''% -'' ELSE '''' END 
			+ CASE max_size WHEN 0 THEN ''DISABLED'' WHEN -1 THEN '' Unrestricted'' 
				ELSE '' Restricted to '' + CAST(max_size/(128*1024) AS VARCHAR(10)) + '' GB'' END 
			+ CASE is_percent_growth WHEN 1 THEN '' [autogrowth by percent, BAD setting!]'' ELSE '''' END
	FROM sys.database_files A 
	LEFT JOIN sys.filegroups fg 
		ON A.data_space_id = fg.data_space_id ');
	BEGIN TRY	
		INSERT INTO @tTmp ([TYPE], [FILE_Name], FILESIZE_MB, USEDSPACE_MB, FREESPACE_MB, FREESPACE_PER, AutoGrow)
		EXEC (@vSqlTx)
	END TRY
	BEGIN CATCH
		PRINT CONCAT('Unable to get data for Database [', @vDbName ,']');
	END CATCH	
	 	
	FETCH curDBs INTO @vDbName;
END;

CLOSE curDBs
DEALLOCATE curDBs

SELECT * FROM @tTmp;

GO

-----------------


/*
SELECT 
    [TYPE] = A.TYPE_DESC
    ,[FILE_Name] = A.name
    ,[FILESIZE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0)
    ,[USEDSPACE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - ((SIZE/128.0) - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0))
    ,[FREESPACE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0)
    ,[FREESPACE_%] = CONVERT(DECIMAL(10,2),((A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0)/(A.SIZE/128.0))*100)
    ,[AutoGrow] = 'By ' + CASE is_percent_growth WHEN 0 THEN CAST(growth/128 AS VARCHAR(10)) + ' MB -' 
        WHEN 1 THEN CAST(growth AS VARCHAR(10)) + '% -' ELSE '' END 
        + CASE max_size WHEN 0 THEN 'DISABLED' WHEN -1 THEN ' Unrestricted' 
            ELSE ' Restricted to ' + CAST(max_size/(128*1024) AS VARCHAR(10)) + ' GB' END 
        + CASE is_percent_growth WHEN 1 THEN ' [autogrowth by percent, BAD setting!]' ELSE '' END
FROM sys.database_files A 
LEFT JOIN sys.filegroups fg 
	ON A.data_space_id = fg.data_space_id 
*/