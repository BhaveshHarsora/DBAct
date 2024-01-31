/*
BH20230201 : T-SQL to Get Memory Usage of each Databases 
*/
USe master
GO

DECLARE @vDbName AS VARCHAR(255), @vSqlTx AS NVARCHAR(MAX);
DECLARE @tTmp AS TABLE (
	DbName VARCHAR(255)
	, GT90 VARCHAR(255)
	, GT70 VARCHAR(255)
	, GT40 VARCHAR(255)
	, LT40 VARCHAR(255)
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
	SELECT DBName
		, SUM(CASE WHEN FragPercent > 90 THEN 1 ELSE 0 END) AS GT90
		, SUM(CASE WHEN FragPercent BETWEEN 70 AND 90 THEN 1 ELSE 0 END) AS GT70
		, SUM(CASE WHEN FragPercent BETWEEN 40 AND 70 THEN 1 ELSE 0 END) AS GT40
		, SUM(CASE WHEN FragPercent < 40 THEN 1 ELSE 0 END) AS LT40
	FROM (
		SELECT DB_NAME() AS DBName
			, OBJECT_NAME(ind.OBJECT_ID) AS TableName
			, ind.name AS IndexName
			, indexstats.index_type_desc AS IndexType
			, ROUND(indexstats.avg_fragmentation_in_percent, 0) AS FragPercent
		FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats 
		INNER JOIN sys.indexes ind 
			ON ind.object_id = indexstats.object_id 
			AND ind.index_id = indexstats.index_id 
		WHERE 1=1
		and indexstats.avg_fragmentation_in_percent > 5 --, e.g. >10, you can specify any number in percent 
		and ind.Name is not null 
	) AS t
	GROUP BY DbName; ');
	INSERT INTO @tTmp (DBName, GT90, GT70, GT40, LT40)
	EXEC (@vSqlTx)
	 	
	FETCH curDBs INTO @vDbName;
END;

CLOSE curDBs
DEALLOCATE curDBs

SELECT * FROM @tTmp;

GO

-----------------
/*

SELECT DBName
	, SUM(CASE WHEN FragPercent > 90 THEN 1 ELSE 0 END) AS GT90
	, SUM(CASE WHEN FragPercent BETWEEN 70 AND 90 THEN 1 ELSE 0 END) AS GT70
	, SUM(CASE WHEN FragPercent BETWEEN 40 AND 70 THEN 1 ELSE 0 END) AS GT40
	, SUM(CASE WHEN FragPercent < 40 THEN 1 ELSE 0 END) AS LT40
FROM (
	SELECT DB_NAME() AS DBName
		, OBJECT_NAME(ind.OBJECT_ID) AS TableName
		, ind.name AS IndexName
		, indexstats.index_type_desc AS IndexType
		, ROUND(indexstats.avg_fragmentation_in_percent, 0) AS FragPercent
	FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats 
	INNER JOIN sys.indexes ind 
		ON ind.object_id = indexstats.object_id 
		AND ind.index_id = indexstats.index_id 
	WHERE 1=1
	and indexstats.avg_fragmentation_in_percent > 5 --, e.g. >10, you can specify any number in percent 
	and ind.Name is not null 
) AS t
GROUP BY DbName;

*/