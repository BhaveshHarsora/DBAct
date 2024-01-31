/*GET ALL TABLES ROW COUNT*/
USE preferredpatron--data
GO

;WITH cte AS (
	SELECT object_id, SchemaName, TableName, TotalRecords, UsedSpaceMB, create_date, modify_date
	FROM (
		SELECT t.object_id, s.name AS SchemaName, t.NAME AS TableName, p.[Rows] AS TotalRecords, (sum(a.used_pages) * 8) / 1024 as UsedSpaceMB,t.create_date,t.modify_date
		FROM sys.tables t WITH(NOLOCK)
		JOIN sys.schemas AS s ON s.schema_id =t.schema_id			
		INNER JOIN sys.indexes i WITH(NOLOCK) ON t.OBJECT_ID = i.object_id
		INNER JOIN sys.partitions p WITH(NOLOCK) ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
		INNER JOIN sys.allocation_units a WITH(NOLOCK) ON p.partition_id = a.container_id
		WHERE 1=1
		--AND t.NAME NOT LIKE 'dt%'
		AND t.schema_id = 1
		AND t.is_ms_shipped = 0
		AND i.OBJECT_ID > 255
		AND i.index_id <= 1
		GROUP BY t.object_id, s.name, t.NAME, i.object_id, i.index_id, i.name, p.[Rows],t.create_date,t.modify_date
		--ORDER BY object_name(i.object_id) 
	) AS t
) 

SELECT object_id
	, SchemaName
	, TableName
	, TotalRecords, UsedSpaceMB, create_date, modify_date
	, (SELECT SUM(x.TotalRecords) FROM cte AS x) AS GrandTotalRecords
	, (SELECT SUM(x.UsedSpaceMB) FROM cte AS x) AS GrandTotalUsedSpaceMB
	, ROW_NUMBER() Over (ORDER BY TotalRecords DESC) AS SortByRec
	, (select count(1) from sys.columns as x where x.object_id = cte.object_id) AS [NoOfCols]
	, (select 'Yes' AS YN from INFORMATION_SCHEMA.TABLE_CONSTRAINTS as x where x.TABLE_NAME = cte.TableName AND x.TABLE_SCHEMA = cte.SchemaName AND x.CONSTRAINT_TYPE='PRIMARY KEY') AS IsPK
	, (select 'Yes' AS YN from INFORMATION_SCHEMA.TABLE_CONSTRAINTS as x where x.TABLE_NAME = cte.TableName AND x.TABLE_SCHEMA = cte.SchemaName AND x.CONSTRAINT_TYPE='UNIQUE') AS IsDF
FROM cte
WHERE 1=1
-- AND cte.TableName IN (
	-- SELECT DISTINCT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES-- WHERE TABLE_NAME LIKE '%cust%'
	-- EXCEPT
	-- SELECT DISTINCT TABLE_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE '%SITE_CODE%'
-- )
ORDER BY TotalRecords desc
