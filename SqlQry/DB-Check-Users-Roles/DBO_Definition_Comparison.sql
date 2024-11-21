/*
BH20240403 : PP DB wise object definition matching SQL across three DBs {PP, PPD, PPD2}
DBO Definition Comparison
*/
use preferredpatron
GO

DROP TABLE IF EXISTS #TmpAllProcDef;

IF OBJECT_ID('tempdb..#TmpAllProcDef') IS NULL
BEGIN
	;WITH cte AS (
		SELECT DbName
			, SchemaName
			, ObjectId,ObjectType, ObjectName
			, LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(DefinationText								
			, '[','') 
			, ']','') 
			, SchemaName+'.','')
			, '.'+SchemaName,'')
			, ' ','<>') 
			, '><','') 
			, '<>',' ') 			
			, ' AS ',' '))) AS DefinationText													
		FROM (
				SELECT 'preferredpatron' AS DbName
						, SCHEMA_NAME(O.schema_id) AS SchemaName
						, O.[Object_Id] AS ObjectId
						, O.type_desc AS ObjectType				
						, O.Name AS ObjectName
						,	REPLACE(
								REPLACE(				
									REPLACE(
										REPLACE(  
											REPLACE(Convert(VARCHAR(MAX),( SELECT a.[text] + N' '
																			from preferredpatron.sys.syscomments AS A
																			where 1=1
																			AND A.id=O.object_id
																			order BY id,colid
																			FOR XML PATH('')))
											,CHAR(13)+CHAR(10), ' ') 
										,CHAR(13), ' ') 
									, CHAR(10),' ') 
								, CHAR(9),' ') 					
							, '&#x0D;',' ') AS DefinationText
				from preferredpatron.sys.objects AS O
				where 1=1
				AND O.[type] IN ('P','TF','TR','TT','V','FN')	
				
				UNION ALL

				SELECT 'preferredpatrondata' AS DbName
						, SCHEMA_NAME(O.schema_id) AS SchemaName
						, O.[Object_Id] AS ObjectId
						, O.type_desc AS ObjectType				
						, O.Name AS ObjectName
						,	REPLACE(
								REPLACE(				
									REPLACE(
										REPLACE(  
											REPLACE(Convert(VARCHAR(MAX),( SELECT a.[text] + N' '
																			from preferredpatrondata.sys.syscomments AS A
																			where 1=1
																			AND A.id=O.object_id
																			order BY id,colid
																			FOR XML PATH('')))
											,CHAR(13)+CHAR(10), ' ') 
										,CHAR(13), ' ') 
									, CHAR(10),' ') 
								, CHAR(9),' ') 					
							, '&#x0D;',' ') AS DefinationText
				from preferredpatrondata.sys.objects AS O
				where 1=1
				AND O.[type] IN ('P','TF','TR','TT','V','FN')	

				UNION ALL

				SELECT 'preferredpatrondata2' AS DbName
						, SCHEMA_NAME(O.schema_id) AS SchemaName
						, O.[Object_Id] AS ObjectId
						, O.type_desc AS ObjectType				
						, O.Name AS ObjectName
						,	REPLACE(
								REPLACE(				
									REPLACE(
										REPLACE(  
											REPLACE(Convert(VARCHAR(MAX),( SELECT a.[text] + N' '
																			from preferredpatrondata2.sys.syscomments AS A
																			where 1=1
																			AND A.id=O.object_id
																			order BY id,colid
																			FOR XML PATH('')))
											,CHAR(13)+CHAR(10), ' ') 
										,CHAR(13), ' ') 
									, CHAR(10),' ') 
								, CHAR(9),' ') 					
							, '&#x0D;',' ') AS DefinationText
				from preferredpatrondata2.sys.objects AS O
				where 1=1
				AND O.[type] IN ('P','TF','TR','TT','V','FN')	
			) As Tbl
		WHERE 1=1
		--AND tbl.ObjectType IN ('SQL_STORED_PROCEDURE')
		--ANd tbl.ObjectName IN ('P_APPLY_POINT_OFFERS')
	)
	select a.*
	  into #TmpAllProcDef
	from cte AS a;
END;


select *
from (
	select pp.ObjectType
		, pp.ObjectName AS DBO_ObjectName
		, CASE WHEN pp.DefinationText IS NULL THEN 'Missing' ELSE '' END AS PP -- pp.DefinationText
		, (CASE WHEN pp.DefinationText IS NOT NULL AND ppd.ObjectName IS NULL THEN 'Missing' WHEN pp.DefinationText IS NOT NULL AND pp.DefinationText = ISNULL(ppd.DefinationText, '') THEN '' ELSE 'Not Matched' END) AS ppd
		, (CASE WHEN pp.DefinationText IS NOT NULL AND ppd2.ObjectName IS NULL THEN 'Missing' WHEN pp.DefinationText IS NOT NULL AND pp.DefinationText = ISNULL(ppd2.DefinationText, '') THEN '' ELSE 'Not Matched' END) AS ppd2

		, BINARY_CHECKSUM(pp.DefinationText) AS PP_ChkSm
		, BINARY_CHECKSUM(ppd.DefinationText) AS PPD_ChkSm
		, BINARY_CHECKSUM(ppd2.DefinationText) AS PPD2_ChkSm
	FROM #TmpAllProcDef AS pp
	LEFT JOIN #TmpAllProcDef AS ppd
		ON ppd.DbName = 'preferredpatrondata'
		AND ppd.ObjectName = pp.ObjectName
	LEFT JOIN #TmpAllProcDef AS ppd2
		ON ppd2.DbName = 'preferredpatrondata2'
		AND ppd2.ObjectName = pp.ObjectName	
	WHERE 1=1	
	AND pp.DbName = 'preferredpatron'
	--ANd pp.ObjectName IN ('getswitchforapproval')
) AS t
where (ISNULL(t.ppd, '') != '' OR  ISNULL(t.ppd2, '') != '')
ORDER BY 1,2;




