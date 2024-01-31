--DECLARE @TableName VARCHAR(50) = 'change_type_lib'
DECLARE @TableData XML,@TableSchema XML

SELECT @TableSchema = (
    select  column_name,
            data_type,
            case(is_nullable)
                when 'YES' then 'true'
                else 'false'    
            end as is_nullable,
			CHARACTER_MAXIMUM_LENGTH as Charlen
    from information_schema.columns [column]
    where table_name = 'change_type_lib'
    for xml auto,root('Table') 
	)

SELECT @TableData = (
SELECT * 
FROM change_type_lib Row
FOR XML AUTO, BINARY BASE64,root('TableData') 
)

SELECT @TableSchema,@TableData




/*Below code converts XML to Table*/

if object_id('tempdb..#XMLColumns') is not null
drop table #XMLColumns

SELECT x.value('@column_name', 'sysname') AS column_name
,x.value('@data_type', 'sysname') AS data_type
,x.value('@is_nullable', 'VARCHAR(20)') AS is_nullable
,x.value('@Charlen', 'VARCHAR(20)') AS Charlen
into #XMLColumns
FROM @TableSchema.nodes('/Table/column') TempXML (x)

UPDATE #XMLColumns
SET Charlen = CASE WHEN ISNULL(Charlen, '') = '-1' THEN 'max' ELSE Charlen END

select * from #XMLColumns

DECLARE @SQL nVARCHAR(MAX) = 'SELECT '

SELECT @SQL = @SQL + '
x.value(''@'+column_name+''', '''+data_type+case when Charlen is null then '' else '('+Charlen+')' end + ''''+') AS ['+column_name+'],'
from #XMLColumns

SET @SQL = LEFT(@SQL, LEN(@SQL) - 1)

SELECT @SQL = @SQL + ' FROM @TableData.nodes(''/TableData/Row'') TempXML (x)'

PRINT @SQL
EXEC sp_executeSQl @SQL,N'@TableData xml',@TableData=@TableData
/*
Output:

tmpEmployee:

ID          NAME
----------- ----------------------------------------------------------------------------------------------------
1           Devi
2           Prasad

(2 row(s) affected)

@TableSchema:

<Table>
  <column column_name="ID" data_type="int" is_nullable="true" />
  <column column_name="NAME" data_type="varchar" is_nullable="true" Charlen="100" />
</Table>

@TableData:

<TableData>
  <Row ID="1" NAME="Devi" />
  <Row ID="2" NAME="Prasad" />
</TableData>

Table generated from XML:

ID          NAME
----------- ----------------------------------------------------------------------------------------------------
1           Devi
2           Prasad

(2 row(s) affected)
*/