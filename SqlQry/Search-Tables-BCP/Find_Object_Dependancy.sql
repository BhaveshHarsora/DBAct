DECLARE @vObjName VARCHAR(MAX) = 'vendor_mso';

SELECT DISTINCT 
	@vObjName table_name
	, c.name dependant_object
	, CASE WHEN a.selall = 1 THEN 'Uses Select *' ELSE NULL END "Select *"
	, CASE WHEN a.resultobj = 1 THEN 'Table is being manipulated' ELSE NULL END "DML Performed"
	, CASE WHEN a.readobj = 1 THEN 'Table is used in select' ELSE NULL END "Select performed"
	, a.*
FROM sys.sysdepends a
	JOIN sys.sysobjects b 
		ON b.id = a.depid
	JOIN sys.sysobjects c
		ON c.id = a.id
WHERE b.name = @vObjName
	--AND b.type = 'U'
AND a.resultobj = 1 
ORDER BY c.name

SELECT DISTINCT
	obj.name AS Object_Name
	, obj.type_desc
FROM sys.sql_modules        module
	INNER JOIN sys.objects  obj ON module.object_id = obj.object_id
WHERE module.definition Like '%' + @vObjName + '%'
	AND obj.type_desc NOT IN ('VIEW', 'SQL_SCALAR_FUNCTION', 'SQL_TABLE_VALUED_FUNCTION')
ORDER BY 1