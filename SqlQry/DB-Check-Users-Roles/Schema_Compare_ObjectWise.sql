/*
Date 23 Aug 2019 
Schema wise object definition matching SQL
*/

use portal
GO

IF OBJECT_ID('tempdb..#TmpAllProcDef') IS NULL
BEGIN
	;WITH cte AS (
		SELECT  SchemaName
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
				SELECT SCHEMA_NAME(O.schema_id) AS SchemaName
						, O.[Object_Id] AS ObjectId
						, O.type_desc AS ObjectType				
						, O.Name AS ObjectName
						,	REPLACE(
								REPLACE(				
									REPLACE(
										REPLACE(  
											REPLACE(Convert(VARCHAR(MAX),( SELECT a.[text] + N' '
																			from  sys.syscomments AS A
																			where 1=1
																			AND A.id=O.object_id
																			order BY id,colid
																			FOR XML PATH('')))
											,CHAR(13)+CHAR(10), ' ') 
										,CHAR(13), ' ') 
									, CHAR(10),' ') 
								, CHAR(9),' ') 					
							, '&#x0D;',' ') AS DefinationText
				from  sys.objects AS O
				where 1=1
				--AND Name IN ('usp_SLIPED_BulkTermMSOUpdate','usp_SLIPED_InterMSORehomeAAVChange','usp_SLIPED_UpdateBH')
				AND O.[type] IN ('P','TF','TR','TT','V','FN')			
			) As Tbl
		WHERE 1=1
		AND tbl.ObjectType IN ('SQL_STORED_PROCEDURE')
		--ANd tbl.ObjectName IN ('getswitchforapproval')
	)
	select a.*
	  into #TmpAllProcDef
	from cte AS a;
END;

select db.ObjectType
	, db.ObjectName AS DBO_ObjectName
	, CASE WHEN db.DefinationText IS NULL THEN 'Missing' ELSE db.DefinationText END AS DBO
	, (CASE WHEN db.DefinationText IS NOT NULL AND ap.ObjectName IS NULL THEN 'Missing' WHEN db.DefinationText IS NOT NULL AND db.DefinationText = ISNULL(ap.DefinationText, '') THEN '' ELSE ap.DefinationText END) AS APIR
	, (CASE WHEN db.DefinationText IS NOT NULL AND tr.ObjectName IS NULL THEN 'Missing' WHEN db.DefinationText IS NOT NULL AND db.DefinationText = ISNULL(tr.DefinationText, '') THEN '' ELSE tr.DefinationText END) AS Tropac
	, (CASE WHEN db.DefinationText IS NOT NULL AND pp.ObjectName IS NULL THEN 'Missing' WHEN db.DefinationText IS NOT NULL AND db.DefinationText = ISNULL(pp.DefinationText, '') THEN '' ELSE pp.DefinationText END) AS PlayGroundPoker
	, (CASE WHEN db.DefinationText IS NOT NULL AND tv.ObjectName IS NULL THEN 'Missing' WHEN db.DefinationText IS NOT NULL AND db.DefinationText = ISNULL(tv.DefinationText, '') THEN '' ELSE tv.DefinationText END) AS Tvc

	, BINARY_CHECKSUM(db.DefinationText), BINARY_CHECKSUM(tr.DefinationText)
	--, REPLACE(ap.DefinationText, db.DefinationText,'MAtched')
FROM #TmpAllProcDef AS db
LEFT JOIN #TmpAllProcDef AS ap
	ON ap.SchemaName = 'APIR'
	AND ap.ObjectName = db.ObjectName
LEFT JOIN #TmpAllProcDef AS tr
	ON tr.SchemaName = 'Tropac'
	AND tr.ObjectName = db.ObjectName
LEFT JOIN #TmpAllProcDef AS pp
	ON pp.SchemaName = 'PlayGroundPoker'
	AND pp.ObjectName = db.ObjectName
LEFT JOIN #TmpAllProcDef AS tv
	ON tv.SchemaName = 'TVC'
	AND tv.ObjectName = db.ObjectName	
WHERE 1=1	
AND db.SchemaName = 'dbo'
ANd db.ObjectName IN ('getswitchforapproval')
ORDER BY 1

--select object_id('dbo.getswitchforapproval'), object_id('APIR.getswitchforapproval'),object_id('Tropac.getswitchforapproval'),object_id('PlayGroundPoker.getswitchforapproval'),object_id('TVC.getswitchforapproval')


--select HASHBYTES('SHA2_256','Test'), HASHBYTES('SHA2_256','Test')