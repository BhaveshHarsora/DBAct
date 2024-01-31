DECLARE @FieldName  VARCHAR(255)
DECLARE @FieldValue VARCHAR(1000)

SET @FieldName = 'RunID'
SET @FieldValue = '933'

SELECT 
	(
		'SELECT ''' 
		+ Obj.Name + ''' AS TableName '
		+ ', COUNT(*) AS NoOfRec' 
		+ ' FROM ' + Obj.Name
		+ ' WHERE ' + Col.Name + ' = ' + @FieldValue
	) AS Query
	, Obj.Name AS ObjectName
	, ( 
		CASE Obj.XType 
			WHEN 'F'	then 'foreign keys'
			WHEN 'FN'	then 'user defined functions'
			WHEN 'TF'	then 'user defined table functions'
			WHEN 'P'	then 'stored procedures'
			WHEN 'PK'	then 'primary keys'
			WHEN 'S'	then 'system tables'
			WHEN 'TR'	then 'triggers'
			WHEN 'U'	then 'user table'
			ELSE Obj.XType
		END 
	 ) AS ObjectType
	, Col.Name AS FieldName
	, Col.xType as FieldType
	, Type_Name(Col.xType) AS FieldTypeName
	, Col.Length as FieldLength
	, Col.ColStat & 1 AS IsIdentity  
FROM SysColumns AS Col
	INNER JOIN SysObjects AS Obj ON Obj.Id = Col.Id
WHERE Col.Name like '%' + @FieldName + '%'
	AND Obj.XType = 'U'
ORDER BY ObjectType, ObjectName
