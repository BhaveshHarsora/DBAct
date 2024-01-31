/*
CCD Data Dictionary
Table STRUCTURE
COLUMNS WITH DATATYPE
*/
SELECT  ROW_NUMBER() OVER (ORDER BY a.Table_name, a.Ordinal_Position) AS SrNo
	, DENSE_RANK() OVER (ORDER BY a.TABLE_CATALOG, a.TABLE_SCHEMA, a.TABLE_NAME) AS TblSrNo
	, a.Table_Name, a.Column_Name
	, UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CONCAT(a.Data_Type, '(',a.Character_Maximum_Length,')'), 'int()', 'int'), 'tinyint()', 'tinyint'), 'datetime()', 'datetime'),'BIT()', 'BIT'),'VARCHAR(-1)','VARCHAR(MAX)'),'UNIQUEIDENTIFIER()', 'UNIQUEIDENTIFIER')) AS Data_type
	, b.CONSTRAINT_NAME
	, CASE WHEN c.object_id IS NOT NULL THEN 'IDENTITY(1, 1)' ELSE '' END AS IsIdentityColumn
FROM INFORMATION_SCHEMA.COLUMNS AS a
LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS b
	ON a.TABLE_NAME = b.TABLE_NAME
	AND a.COLUMN_NAME = b.COLUMN_NAME
LEFT JOIN sys.identity_columns AS c
	ON c.object_id = object_id(a.TABLE_NAME)
	AND c.name = a.COLUMN_NAME
WHERE a.Table_Name = 'Vulnerabilities'
ORDER BY a.Table_name,  a.Ordinal_Position -- a.COLUMN_NAME--


SELECT * FROM sys.foreign_keys
SELECT * FROm sys.columns
SELECT * FROM sys.identity_columns
SELECT * FROM INFORMATION_SCHEMA.COLUMN_PRIVILEGES
--TaskWorker