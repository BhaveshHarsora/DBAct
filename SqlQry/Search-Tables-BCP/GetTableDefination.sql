SELECT
	obj.name as TableName 
	, col.name as ColumnName 
	, typ.name + '( ' + ( 
				CASE 
					WHEN col.xprec > 0 
						THEN CAST( col.xprec AS VARCHAR(10) ) + ',' + CAST( col.xscale AS VARCHAR(10) )
					ELSE CAST( col.length AS VARCHAR(10) ) 
				END 
			)  + ' )' as ColumnType
	, ( CASE col.isnullable WHEN 1 THEN 'Yes' ELSE 'No' END ) AS IsNullable
	, (
		CASE ISNULL( K.COLUMN_NAME, '' ) WHEN '' THEN 'No' ELSE 'Yes' END
	) AS IsPrimarykey
	--, *
FROM sysobjects as obj
	INNER JOIN syscolumns as col on col.id = obj.id
	INNER JOIN systypes as typ on typ.xtype = col.xtype
	
	LEFT OUTER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS C ON C.TABLE_NAME = obj.name
		AND C.CONSTRAINT_TYPE = 'PRIMARY KEY'
	LEFT OUTER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS K ON C.TABLE_NAME = K.TABLE_NAME
		AND C.CONSTRAINT_CATALOG = K.CONSTRAINT_CATALOG
		AND C.CONSTRAINT_SCHEMA = K.CONSTRAINT_SCHEMA
		AND C.CONSTRAINT_NAME = K.CONSTRAINT_NAME
		AND K.COLUMN_NAME = col.name
WHERE obj.xtype = 'U'
ORDER BY obj.name, col.colorder