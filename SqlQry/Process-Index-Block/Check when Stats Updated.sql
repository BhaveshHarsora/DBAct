/*
BH20231101 : check when table last statistics updated.
*/

SELECT *
FROM (
	SELECT
	  OBJECT_NAME(object_id) AS TableName
	  , QUOTENAME(s.name, '[') AS IndexName
	  , (CASE s.no_recompute WHEN 1 THEN 'OFF' ELSE 'ON' END) AS AUTOSTATS
	  , AUTO_CREATED
	  , STATS_DATE(object_id, s.stats_id) AS LastUpdated
	FROM sys.stats AS s
	WHERE OBJECTPROPERTY(OBJECT_ID, 'IsSystemTable') = 0
	AND OBJECT_NAME(object_id) NOT LIKE 'ifts%'      --  COMMENT OUT IF WANT TO SEE FULLTEXT INDEXES
	AND OBJECT_NAME(object_id) NOT LIKE 'fulltext%'  --  COMMENT OUT IF WANT TO SEE FULLTEXT INDEXES
	AND AUTO_CREATED = 0                             -- COMMENT OUT IF WANT TO SEE AUTO CREATED STATS AS WELL
) AS t
WHERE 1=1
AND TableName = 'SMS_NOTIFICATION' 
ORDER BY LastUpdated DESC;


