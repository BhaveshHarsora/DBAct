/*
Date: 5 Jun 2019
Detact the Fragmentation level and accordingly Rebuild/Reorganized Index.

	*Threashhold > 5% 
*/

--> Find Existing Indexes on a given Table
BEGIN
	;WITH cte AS (
		SELECT
			a.[name] AS IndexName
			, SCHEMA_NAME(b.schema_id) AS SchemaName
			, OBJECT_NAME(a.object_id) AS TableName
			, STUFF(CONVERT(VARCHAR(MAX), 
				(SELECT ',' + COL_NAME(x.object_id, x.column_id) 
				FROM sys.index_columns AS x   
				WHERE a.object_id = x.object_id 
				AND a.index_id = x.index_id
				AND x.is_included_column = 0
				ORDER BY x.index_column_id
				FOR XML PATH(''))),1,1,'') AS IndexedColumns
			, STUFF(CONVERT(VARCHAR(MAX), 
				(SELECT ',' + COL_NAME(x.object_id, x.column_id) 
				FROM sys.index_columns AS x   
				WHERE a.object_id = x.object_id 
				AND a.index_id = x.index_id
				AND x.is_included_column = 1
				ORDER BY x.index_column_id
				FOR XML PATH(''))),1,1,'') AS IncludedColumns			
		FROM sys.indexes AS a 
		JOIN sys.objects AS b
			ON b.[object_id] = a.[object_id]		
		WHERE 1=1
		--AND a.is_hypothetical = 0 
	)
	SELECT a.*
	FROM cte AS a
	WHERE 1=1
	AND a.TableName = 'EarlyOuts'


END;

------------


--> Find Index Usage Statistics
BEGIN
	;WITH cte AS (
		SELECT
			SCHEMA_NAME(c.schema_id) AS SchemaName
			, c.[name] AS TableName
			, b.name AS IndexName			
			, (a.user_seeks+a.user_Scans+user_lookups) AS Measures
			, a.*
		FROM sys.dm_db_index_usage_stats AS a
		JOIN sys.indexes AS b
			ON b.object_id = a.object_id
			AND b.index_id = a.index_id
		JOIN sys.objects AS c
			ON c.[object_id] = a.[object_id] 
		WHERE 1=1
		AND a.database_id = DB_ID()
	)
	SELECT a.*
	FROM cte AS a
	WHERE 1=1
	AND a.TableName = 'FormUserResponse'
	ORDER BY SchemaName, TableName, Measures DESC

END;

------------


--> Find and Create missing Indexes
BEGIN
	;WITH cte AS (
		SELECT
			migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) AS improvement_measure
			, mid.[object_id]
			, PARSENAME(mid.statement, 3) AS DBName
			, PARSENAME(mid.statement, 2) AS SchemaName
			, PARSENAME(mid.statement, 1) AS ObjectName
			, mid.equality_columns AS IndexFields
			, mid.included_columns AS IncludeFields
			, 'CREATE INDEX [idx_' + LEFT (PARSENAME(mid.statement, 1), 32) + ISNULL('_'+PARSENAME(mid.equality_columns,1),'') + ISNULL ('_'+PARSENAME(mid.inequality_columns,1), '') + ']'
				+ ' ON ' + mid.statement
				+ ' (' + ISNULL (mid.equality_columns,'')
				+ CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END
				+ ISNULL (mid.inequality_columns, '')
				+ ')'
				+ ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement
			--, mid.*	
		FROM sys.dm_db_missing_index_groups AS mig
		INNER JOIN sys.dm_db_missing_index_group_stats AS migs 
			ON migs.group_handle = mig.index_group_handle
		INNER JOIN sys.dm_db_missing_index_details AS mid 
			ON mig.index_handle = mid.index_handle
		WHERE migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) > 10
	)
	SELECT improvement_measure, a.[object_id], a.DBName, a.SchemaName, a.ObjectName, a.create_index_statement, a.IndexFields, a.IncludeFields
		--, a.index_handle, a.database_id, a.object_id, a.equality_columns, a.inequality_columns, a.included_columns, a.statement
	FROM cte AS a
	WHERE 1=1
	AND a.DBName IN ('Portal') -- {'Dashboard'}
	AND ObjectName = 'EarlyOuts'
	ORDER BY improvement_measure DESC, DBName, SchemaName, ObjectName

END;

------------



--> Find index to to need for REBUILD
BEGIN

	SELECT OBJECT_NAME(ind.OBJECT_ID) AS TableName, 
		ind.name AS IndexName, indexstats.index_type_desc AS IndexType, 
		indexstats.avg_fragmentation_in_percent,
		'ALTER INDEX ' + QUOTENAME(ind.name)  + ' ON ' +QUOTENAME(object_name(ind.object_id)) + 
			CASE    WHEN indexstats.avg_fragmentation_in_percent>30 THEN ' REBUILD ' 
				WHEN indexstats.avg_fragmentation_in_percent>=5 THEN 'REORGANIZE'
				ELSE NULL 
			END as [SQLQuery]  -- if <5 not required, so no query needed
		, CASE WHEN EXISTS(SELECT 1 FROM sys.columns AS x 
							WHERE x.object_id = ind.object_id 
							AND ind.[type_desc] = 'CLUSTERED' 
							AND (  (x.system_type_id IN (34,35,99,241) )
								OR (x.system_type_id IN (167,231,165) AND x.max_length = -1) )  )
				THEN 'OFF'
				ELSE 'ON'
			END AS IsOnline
	FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats 
	INNER JOIN sys.indexes ind 
		ON ind.object_id = indexstats.object_id 
		AND ind.index_id = indexstats.index_id 
	WHERE 1=1
	and indexstats.avg_fragmentation_in_percent > 5 --, e.g. >10, you can specify any number in percent 
	and ind.Name is not null 
	ORDER BY indexstats.avg_fragmentation_in_percent DESC

END;

-------------

UPDATE STATISTICS dbo.fact_tra_art WITH FULLSCAN;

-------------
