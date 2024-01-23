/*
GET LAST EXECUTED QUERY
*/

SELECT top 1000
		b.text,		
		object_name(objectid) AS ObjectName,
		a.creation_time,
		a.last_execution_time,
		a.total_rows,
		a.last_rows,
		a.min_rows,
		a.max_rows
FROM sys.dm_exec_query_stats a
CROSS APPLY sys.dm_exec_sql_text(sql_handle) as b
WHERE 1=1
AND b.[dbid] = 6
AND b.[text] LIKE '%usp_sliped_NDWCIRDataRefresh_package%'
ORDER BY a.creation_time DESC 	
