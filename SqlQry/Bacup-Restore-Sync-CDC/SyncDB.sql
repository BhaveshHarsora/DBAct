/*
Below T-SQL used to generate INSERT data scriot for Sync Data from Source DB to Destination DB
Pass the Parameter of Soruce and Destinaion DB name and Schema name
*/
DECLARE @vSrcDBNm AS VARCHAR(255) = 'source', 
		@vDestDBNm AS VARCHAR(255) = 'destination', 
		@vSrcSchemaNm AS VARCHAR(100) = 'test', 
		@vDestSchemaNm AS VARCHAR(100) = 'test';

;WITH TablesOrder AS 
(
	SELECT FkName,
			BaseTable,
			BaseColumn,
			ParentTable,
			ParentColumn
			, 0 AS fklevel
			, create_date 
	FROM (
		SELECT  fk.name AS FkName,
				tp.name AS BaseTable,
				cp.name AS BaseColumn,
				tr.name As ParentTable,
				cr.name AS ParentColumn,
				fk.create_date
		FROM  sys.foreign_keys fk
		INNER JOIN sys.tables tp 
			ON fk.parent_object_id = tp.object_id
		INNER JOIN sys.tables tr 
			ON fk.referenced_object_id = tr.object_id
		INNER JOIN sys.foreign_key_columns fkc 
			ON fkc.constraint_object_id = fk.object_id
		INNER JOIN sys.columns cp 
			ON fkc.parent_column_id = cp.column_id AND fkc.parent_object_id = cp.object_id
		INNER JOIN sys.columns cr 
			ON fkc.referenced_column_id = cr.column_id AND fkc.referenced_object_id = cr.object_id
		WHERE 1=1
	) AS tbl
	WHERE 1=1
	--ORDER BY create_date
)
SELECT '--> ' + tt.TableName + '  
		' + tt.IdntOn + '

		INSERT INTO ' + @vDestDBNm + '.' + @vDestSchemaNm + '.' + tt.TableName + ' (' + tt.colCSV + ')
		SELECT ' + tt.colCSV2 + '
		FROM ' + @vSrcDBNm + '.' + @vSrcSchemaNm + '.' + tt.TableName + ' AS a
		LEFT OUTER JOIN ' + @vDestDBNm + '.' + @vDestSchemaNm + '.' + tt.TableName + ' AS b
			ON a.' + tt.PkCol + ' = b.' + tt.PkCol + '
		WHERE b.' + tt.PkCol + ' IS NULL;
		
		' + tt.IdntOff + '
		
		'

FROM (
	SELECT Srno,
		TableName
		, PkCol
		, (
			STUFF(
				CONVERT(VARCHAR(MAX), (SELECT ',' + x.Column_Name
										FROM INFORMATION_SCHEMA.COLUMNS AS x
										WHERE x.Table_Name = t.TableName
										ORDER BY x.ORDINAL_POSITION
										FOR XML PATH(''))
						)
				 , 1,1,'')
		) AS colCSV
		,( STUFF(
				CONVERT(VARCHAR(MAX), (SELECT ',a.' + x.Column_Name
										FROM INFORMATION_SCHEMA.COLUMNS AS x
										WHERE x.Table_Name = t.TableName
										ORDER BY x.ORDINAL_POSITION										
										FOR XML PATH(''))
						)
				 , 1,1,'')
		) AS colCSV2

		, CASE WHEN EXISTS(SELECT 1 from sys.IDENTITY_COLUMNS WHERE object_name(object_id) = t.TableName)
				THEN ' SET IDENTITY_INSERT ' + @vDestDBNm + '.' + @vDestSchemaNm + '.' + t.TableName + ' ON; '
				ELSE ''
			END AS IdntOn
		, CASE WHEN EXISTS(SELECT 1 from sys.IDENTITY_COLUMNS WHERE object_name(object_id) = t.TableName)
				THEN ' SET IDENTITY_INSERT ' + @vDestDBNm + '.' + @vDestSchemaNm + '.' + t.TableName + ' OFF; '
				ELSE ''
			END AS IdntOff
	FROM (
		SELECT ParentTable AS TableName, ParentColumn AS PkCol, ROW_NUMBER() OVER (ORDER BY create_date) AS Srno
		FROM TablesOrder
		UNION
		SELECT BaseTable, BaseColumn AS PkCol, (ROW_NUMBER() OVER (ORDER BY create_date))+9990 AS Srno
		FROM TablesOrder
		WHERE BaseTable NOT IN (SELECT ParentTable FROM TablesOrder)
	) AS t
) AS tt
ORDER BY Srno


