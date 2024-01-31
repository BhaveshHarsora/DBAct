/*
BH20230201 : T-SQL to Get Top rows and storage usage table list abross all the DBs
e.g. (UsedSpaceMB > 1024 MB)
*/
USe master
GO

DECLARE @vDbName AS VARCHAR(255), @vSqlTx AS NVARCHAR(MAX);
DECLARE @tTmp AS TABLE (
	DbName VARCHAR(255)
	, ObjectId VARCHAR(255)
	, SchemaName VARCHAR(255)
	, TableName VARCHAR(255)
	, TotalRecords VARCHAR(255)
	, UsedSpaceMB VARCHAR(255)
);

DECLARE curDBs CURSOR LOCAL FAST_FORWARD FOR
select name AS DbName
from sys.databases 

OPEN curDBs;
FETCH curDBs INTO @vDbName;

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @vSqlTx = CONCAT('
	USE [', @vDbName ,'];
	SELECT TOP 5 DB_NAME() AS DbName 
		, ObjectId
		, SchemaName
		, TableName
		, TotalRecords
		, UsedSpaceMB
	FROM (
		SELECT t.object_id As ObjectId, s.name AS SchemaName, t.NAME AS TableName, p.[Rows] AS TotalRecords, (sum(a.used_pages) * 8) / 1024 as UsedSpaceMB
		FROM sys.tables t WITH(NOLOCK)
		JOIN sys.schemas AS s ON s.schema_id =t.schema_id			
		INNER JOIN sys.indexes i WITH(NOLOCK) ON t.OBJECT_ID = i.object_id
		INNER JOIN sys.partitions p WITH(NOLOCK) ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
		INNER JOIN sys.allocation_units a WITH(NOLOCK) ON p.partition_id = a.container_id
		WHERE 1=1
		--AND t.schema_id = 1
		AND t.is_ms_shipped = 0
		AND i.OBJECT_ID > 255
		AND i.index_id <= 1
		GROUP BY t.object_id, s.name, t.NAME, i.object_id, i.index_id, i.name, p.[Rows],t.create_date,t.modify_date
	) AS t
	WHERE 1=1
	--AND ISNULL(TotalRecords, 0) > 0
	AND ISNULL(UsedSpaceMB, 0) > 1024
	ORDER BY TotalRecords DESC; ');
	INSERT INTO @tTmp (DbName, ObjectId, SchemaName, TableName, TotalRecords, UsedSpaceMB)
	EXEC (@vSqlTx)
	 	
	FETCH curDBs INTO @vDbName;
END;

CLOSE curDBs
DEALLOCATE curDBs

SELECT * FROM @tTmp;

GO

-----------------
/*
SELECT TOP 5 DB_NAME() AS DbName 
	, object_id
	, SchemaName
	, TableName
	, TotalRecords
	, UsedSpaceMB
FROM (
	SELECT t.object_id, s.name AS SchemaName, t.NAME AS TableName, p.[Rows] AS TotalRecords, (sum(a.used_pages) * 8) / 1024 as UsedSpaceMB
	FROM sys.tables t WITH(NOLOCK)
	JOIN sys.schemas AS s ON s.schema_id =t.schema_id			
	INNER JOIN sys.indexes i WITH(NOLOCK) ON t.OBJECT_ID = i.object_id
	INNER JOIN sys.partitions p WITH(NOLOCK) ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
	INNER JOIN sys.allocation_units a WITH(NOLOCK) ON p.partition_id = a.container_id
	WHERE 1=1
	--AND t.schema_id = 1
	AND t.is_ms_shipped = 0
	AND i.OBJECT_ID > 255
	AND i.index_id <= 1
	GROUP BY t.object_id, s.name, t.NAME, i.object_id, i.index_id, i.name, p.[Rows],t.create_date,t.modify_date
) AS t
WHERE ISNULL(TotalRecords, 0) > 0
ORDER BY TotalRecords desc
*/