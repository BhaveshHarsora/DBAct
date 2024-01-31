;WITH cte AS (
	SELECT FkName,
		ParentTable,
		ParentColumn,
		RefferenceTable,
		RefferenceColumn
	FROM (
		SELECT  fk.name AS FkName,
				tp.name AS RefferenceTable,
				cp.name AS RefferenceColumn,
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
SELECT * FROM cte


------------



select BaseTable, BaseColumnName, ParentTable, ParentColumn, fklevel
--update a SET a.fklevel = 1 --> Increse the fkLevel by 1 on each Update 
from TablesOrder as a
where 1=1
AND ParentTable NOT IN (SELECT x.BaseTable FROM TablesOrder AS x WHERE 1=1 AND ISNULL(fklevel, 0) = 0) --> Increse the fkLevel by 1 as it Updated
AND ISNULL(fklevel, 0) = 0 --> Should always be 0


--Check
select * from TablesOrder
where FkLevel is null