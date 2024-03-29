DECLARE @vSrcTblNm AS VARCHAR(50), @vTrgTblNm AS VARCHAR(50), @vPkIdColNm AS VARCHAR(50),
		@vColCSV AS VARCHAR(MAX), @vXColCSV AS VARCHAR(MAX), @vBColCSV AS VARCHAR(MAX), @vUpdtColCSV AS VARCHAR(MAX);

SET @vSrcTblNm = 'Test2..EmpMSt';
SET @vTrgTblNm = 'EmpMSt';

;WITH cte AS (
	SELECT c.TABLE_NAME, c.COLUMN_NAME, pc.COLUMN_NAME AS PK_COLUMN_NAME
	FROM INFORMATION_SCHEMA.COLUMNS AS c
	LEFT JOIN (SELECT cc.TABLE_NAME, cc.COLUMN_NAME 
				FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS cc
				JOIN sys.key_constraints AS sk
					ON sk.name = cc.CONSTRAINT_NAME
					AND sk.type = 'PK'
		) AS pc
		ON pc.TABLE_NAME = c.TABLE_NAME
		AND pc.COLUMN_NAME = c.COLUMN_NAME
	WHERE c.TABLE_NAME = 'EmpMSt'
)
SELECT *
FROM cte


SELECT * FROM sys.objects WHERE name = 'salary'
SELECT * FROM sys.key_constraints
SELECT * FROM sys.tables



select OBJECT_NAME(245575913)


