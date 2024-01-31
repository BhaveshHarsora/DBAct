/*


-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1
GO
-- To update the currently configured value for advanced options.
RECONFIGURE
GO
-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 0
GO
-- To update the currently configured value for this feature.
RECONFIGURE
GO



*/


--> IMPORT DATA FROM BCP:
TRUNCATE TABLE TestDatabase.dbo.myNative; -- for testing

BULK INSERT TestDatabase.dbo.myNative
    FROM 'D:\BCP\myNative.bcp'
    WITH (DATAFILETYPE = 'native');

SELECT * FROM TestDatabase.dbo.myNative;

------------
	
TRUNCATE TABLE TestDatabase.dbo.myNative; -- for testing

BULK INSERT TestDatabase.dbo.myNative
   FROM 'D:\BCP\myNative.bcp'
   WITH (
        FORMATFILE = 'D:\BCP\myNative.fmt'
        );

-- review results
SELECT * FROM TestDatabase.dbo.myNative;

------------
bcp inventory.dbo.fruits out "C:\fruit\inventory.txt" -c -T 
 
/*
'SET @cmd = ''BCP "SELECT ' 
		+ STUFF(CAST((SELECT ',''''['+COLUMN_NAME+']'''''
						FROM INFORMATION_SCHEMA.COLUMNS AS a
						WHERE TABLE_NAME = ta.Name
						ORDER BY ORDINAL_POSITION
						FOR XML PATH('')) AS varchar(MAX)),1,1,'') 
		+ ' UNION ALL '
		+ ' SELECT '
		+ STUFF(CAST((SELECT ', CAST([' +COLUMN_NAME+ '] AS VARCHAR(MAX)) '
						FROM INFORMATION_SCHEMA.COLUMNS AS a
						WHERE TABLE_NAME = ta.Name
						ORDER BY ORDINAL_POSITION
						FOR XML PATH('')) AS varchar(MAX)),1,1,'') 
		+ ' FROM  MHC.' + sc.name +'.['+ ta.name + ']" '
		+ ' queryout "D:\BhaveshJ\' + ta.name + '.csv' + '" -t, -U test -P test -c''
		Exec xp_cmdshell @cmd;

		'
*/

SELECT 
'--:: ' + ta.name +' ::
SET @cmd = ''BCP "SELECT * FROM  MatrixCare.' + sc.name +'.['+ ta.name + ']" ' + ' queryout "D:\BhaveshJ\' + ta.name + '.csv' + '" -t, -U test -P test -c''
Exec xp_cmdshell @cmd;
PRINT ''DONE :: ' + ta.name + ' :: ''
'
FROM sys.tables ta
INNER JOIN sys.partitions pa
	ON pa.OBJECT_ID = ta.OBJECT_ID
INNER JOIN sys.schemas sc
	ON ta.schema_id = sc.schema_id
WHERE ta.is_ms_shipped = 0 
AND pa.index_id IN (1,0)
GROUP BY sc.name,ta.name
HAVING SUM(pa.rows) != 0
ORDER BY SUM(pa.rows) DESC
