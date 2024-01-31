/*
Date 27 Apr 2020
SQL to view Last Updated table, 
	Last Index Scanned or Index Seeks table
*/
SELECT
	DB_NAME(database_id) AS DBName
	, tbl.name as TableName
	,ius.last_user_update AS LastUpdatedOn
	,ius.user_updates as LastUpdatesCount
	,ius.last_user_seek 
	,ius.last_user_scan
	,ius.last_user_lookup
	,ius.user_seeks
	,ius.user_scans
	,ius.user_lookups
FROM sys.dm_db_index_usage_stats AS ius 
INNER JOIN sys.tables AS tbl 
	ON tbl.OBJECT_ID = ius.OBJECT_ID
WHERE 1=1
AND ius.database_id = DB_ID()
ORDER BY LastUpdatedOn desc