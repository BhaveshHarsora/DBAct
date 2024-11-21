/*
Date 27 Aug 2019 
Schema wise object definition matching SQL -- Stage

* Its takes about ~10min. to show comparision list.
*/

use portal
GO

--select * from sys.schemas where SCHEMA_ID BETWEEN 5 and 100

DECLARE @vSqlTx as varchar(max) = '', @vColumnSql AS VARCHAR(MAX) = '', @vLeftJoinSql AS VARCHAR(MAX) = '', @vDboColumnSql AS VARCHAR(MAX) = '';

SELECT 
	--@vColumnSql =  CONCAT(@vColumnSql, ' , (CASE WHEN db.DefinationText IS NOT NULL AND ',sch.[name],'.ObjectName IS NULL THEN ''Missing'' WHEN db.DefinationText IS NOT NULL AND db.DefinationText = ISNULL(',sch.[name],'.DefinationText, '''') THEN '''' ELSE ''Not Matched'' END) AS ',sch.[name],' ', CHAR(13))
	 @vColumnSql =  CONCAT(@vColumnSql, ' , (CASE WHEN db.DefinationText IS NOT NULL AND ',sch.[name],'.ObjectName IS NULL THEN ''Missing'' WHEN db.DefinationText IS NOT NULL AND db.DefinationText = ISNULL(',sch.[name],'.DefinationText, '''') THEN '''' ELSE ISNULL(',sch.[name],'.DefinationText, '''') END) AS ',sch.[name],' ', CHAR(13))
	, @vDboColumnSql =  CONCAT(@vDboColumnSql, ', (CASE WHEN db.DefinationText IS NOT NULL AND db.DefinationText = ISNULL(',sch.[name],'.DefinationText, '''') THEN NULL ELSE db.DefinationText END) ')
	, @vLeftJoinSql =  CONCAT(@vLeftJoinSql, ' LEFT JOIN #TmpAllProcDef AS ',sch.[name],' ON ',sch.[name],'.SchemaName = ''',sch.[name],''' AND ',sch.[name],'.ObjectName = db.ObjectName ', CHAR(13))
FROM sys.schemas AS sch
WHERE SCHEMA_ID BETWEEN 5 and 100
AND ISNULL(CHARINDEX('\',sch.[name]), 0) = 0; -- Remove unwanted Schemas havinig invalid name

SET @vDboColumnSql = CONCAT(' , COALESCE((CASE WHEN db.DefinationText IS NULL THEN ''Missing'' ELSE NULL END)',@vDboColumnSql,','''')  AS DBO ');
--select @vDboColumnSql

--SELECT @vColumnSql, @vLeftJoinSql

SET @vSqlTx = CONCAT('
IF OBJECT_ID(''tempdb..#TmpAllProcDef'') IS NULL
BEGIN
	PRINT ''Preparing new Definition table...'';

	;WITH cte AS (
		SELECT  SchemaName
		, ObjectId, ObjectType, ObjectName
		, (CASE WHEN tbl.DefinationText NOT IN (''D'')
			THEN LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(DefinationText								
						, ''['','''') 
						, '']'','''') 
						, SchemaName+''.'','''')
						, ''.''+SchemaName,'''')
						, '' '',''<>'') 
						, ''><'','''') 
						, ''<>'','' '') 			
						, '' AS '','' '')))
			ELSE tbl.DefinationText
		   END) AS DefinationText													
		FROM (
				SELECT SCHEMA_NAME(O.schema_id) AS SchemaName
						, O.[Object_Id] AS ObjectId
						, (CASE O.[type] 
							when ''P'' then ''PROCEDURE''
							when ''TF'' then ''FUNCTION''
							when ''TR'' then ''TRIGGER''
							when ''V'' then ''VIEW''
							when ''FN'' then ''FUNCTION''
							when ''IF'' then ''FUNCTION''
							when ''D'' then ''DEFAULT''
							else [type_desc] 
						  END) AS ObjectType				
						, O.Name AS ObjectName
						,	REPLACE(
								REPLACE(				
									REPLACE(
										REPLACE(  
											REPLACE(Convert(VARCHAR(MAX),( SELECT a.[text] + N'' ''
																			from  sys.syscomments AS A
																			where 1=1
																			AND A.id=O.object_id
																			order BY id,colid
																			FOR XML PATH('''')))
											,CHAR(13)+CHAR(10), '' '') 
										,CHAR(13), '' '') 
									, CHAR(10),'' '') 
								, CHAR(9),'' '') 					
							, ''&#x0D;'','' '') AS DefinationText
				from  sys.objects AS O
				where 1=1				
				AND O.[type] IN (''P'',''TF'',''TR'',''V'',''FN'',''IF'',''D'')
				-- AND O.Name IN (''_xAssignmentNames'')
			) As Tbl
		WHERE 1=1
		AND (tbl.ObjectName NOT LIKE ''syncobj_%'' )
		-- AND tbl.ObjectType IN (''VIEW'')		
		
	)
	, cte2 AS (
		SELECT a.SchemaName, a.ObjectId, a.ObjectType, a.ObjectName
			, (CASE WHEN a.DefinationText NOT IN (''D'')
				THEN SUBSTRING(a.DefinationText, CHARINDEX(CONCAT(''CREATE '', a.ObjectType), a.DefinationText), LEN(a.DefinationText))
				ELSE a.DefinationText
			  END) AS DefinationText
		FROM cte AS a
	)
	select a.*
	  into #TmpAllProcDef
	from cte2 AS a;
END;

select x.*
from (
	select db.ObjectType, db.ObjectName AS DBO_ObjectName		
		', @vDboColumnSql, '
		', @vColumnSql ,'
	FROM #TmpAllProcDef AS db
	', @vLeftJoinSql ,'
	WHERE 1=1	
	AND db.SchemaName = ''dbo''
) AS x
WHERE ISNULL(x.[DBO], '''') != ''''
ORDER BY 1,2;


IF OBJECT_ID(''tempdb..#TmpAllProcDef'') IS NOT NULL	DROP TABLE #TmpAllProcDef;
');

Print @vSqlTx;
--select @vSqlTx
EXEC (@vSqlTx);


