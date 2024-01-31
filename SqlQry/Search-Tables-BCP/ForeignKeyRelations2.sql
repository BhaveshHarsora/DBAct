/*
Date: 06-March-2018
Get the Foreign Key Hierarchy
*/

DECLARE @vCounter AS INT = 1;

IF OBJECT_ID('tempdb..#TablesOrder') IS NOT NULL
	DROP TABLE #TablesOrder

;WITH cte AS (
	SELECT FkName,
			BaseTable,
			BaseColumn,
			ParentTable,
			ParentColumn
	FROM (
		SELECT  fk.name AS FkName,
				tp.name AS BaseTable,
				cp.name AS BaseColumn,
				tr.name As ParentTable,
				cr.name AS ParentColumn
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
) 
SELECT *, NULL AS fklevel
 INTO #TablesOrder
FROM cte;


WHILE EXISTS(SELECT 1 FROM #TablesOrder as a
				WHERE 1=1
				AND ParentTable NOT IN (SELECT x.BaseTable FROM #TablesOrder AS x WHERE 1=1 AND ISNULL(fklevel, 0) = (@vCounter-1)) --> Increse the fkLevel by 1 as it Updated
				AND ISNULL(fklevel, 0) = 0)
BEGIN 

	UPDATE a 
		SET a.fklevel = @vCounter --> Increse the fkLevel by 1 on each Update 
	FROM #TablesOrder as a
	WHERE 1=1
	AND ParentTable NOT IN (SELECT x.BaseTable FROM #TablesOrder AS x WHERE 1=1 AND ISNULL(fklevel, 0) = (@vCounter-1)) --> Increse the fkLevel by 1 as it Updated
	AND ISNULL(fklevel, 0) = 0 --> Should always be 0

	SET @vCounter = @vCounter + 1;

END;


------------

--Check
SELECT * FROM #TablesOrder 
--WHERE FkLevel is null
ORDER BY FkLevel, ParentTable, BaseTable 

------------

