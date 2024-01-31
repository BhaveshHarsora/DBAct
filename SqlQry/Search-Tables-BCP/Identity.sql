DECLARE @q NVARCHAR(1000)
SELECT @q = N'USE ?
SELECT TOP (5)
DB_NAME() AS DataBaseName,
QUOTENAME(SCHEMA_NAME(t.schema_id)) + ''.'' +  QUOTENAME(t.name) AS TableName,
c.name AS ColumnName,
CASE c.system_type_id
WHEN 127 THEN ''bigint''
WHEN 56 THEN ''int''
WHEN 52 THEN ''smallint''
WHEN 48 THEN ''tinyint''
END AS ''DataType'',
IDENT_CURRENT(SCHEMA_NAME(t.schema_id)  + ''.'' + t.name) AS CurrentIdentityValue,
CASE c.system_type_id
WHEN 127 THEN (IDENT_CURRENT(SCHEMA_NAME(t.schema_id)  + ''.'' + t.name) * 100.) / 9223372036854775807
WHEN 56 THEN (IDENT_CURRENT(SCHEMA_NAME(t.schema_id)  + ''.'' + t.name) * 100.) / 2147483647
WHEN 52 THEN (IDENT_CURRENT(SCHEMA_NAME(t.schema_id)  + ''.'' + t.name) * 100.) / 32767
WHEN 48 THEN (IDENT_CURRENT(SCHEMA_NAME(t.schema_id)  + ''.'' + t.name) * 100.) / 255
END AS ''PercentageUsed''
FROM sys.columns AS c
INNER JOIN  sys.tables AS t
ON t.[object_id] = c.[object_id]
WHERE c.is_identity = 1
ORDER BY PercentageUsed DESC'

EXEC sp_MSforeachdb @q