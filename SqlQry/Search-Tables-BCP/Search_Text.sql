--use preferredpatrondata2
--USE lottobytext_pwa
GO
 
/**************************************** SEARCH OBJECT TEXT ****************************************/
DECLARE @vForceRefresh BIT = 0;
DECLARE @vSearchText AS VARCHAR(MAX);

SET @vSearchText = '"RG1_21"'
-----------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM tempdb.sys.tables WHERE create_date > DATEADD(MINUTE,-120,GETDATE()) AND object_id=OBJECT_ID('tempdb..#tempSearchDbObjectResult'))
	OR @vForceRefresh=1 
BEGIN   
	PRINT 'Creating fresh table'
	
	IF OBJECT_ID('tempdb..#tempSearchDbObjectResult') IS NOT NULL
		DROP TABLE #tempSearchDbObjectResult
		
	SELECT t.ObjectId
		, t.ObjectType
		, t.ObjectName
		, t.DefinationText
		, t.create_date
		, t.modify_date
	INTO #tempSearchDbObjectResult
	FROM (
		SELECT 
			CAST(ObjectId AS VARCHAR(255)) AS ObjectId
			, CAST(ObjectType AS VARCHAR(512)) AS ObjectType
			, CAST(ObjectName AS VARCHAR(512)) AS ObjectName
			, CONVERT(NVARCHAR(MAX), 
				REPLACE(			
					REPLACE(	
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(
										REPLACE(DefinationText								
										, '[','') 
									, ']','') 
								, 'dbo.','')									
							, ' ','<>') 
						, '><','') 
					, '<>',' ') 			
				 , ' AS ',' ') ) AS DefinationText	
			 , create_date
			 , modify_date												
			FROM (
					SELECT O.[Object_Id] AS ObjectId
							, O.type_desc AS ObjectType				
							, O.Name AS ObjectName
							,	REPLACE(
									REPLACE(				
										REPLACE(
											REPLACE(  
												REPLACE(CONVERT(NVARCHAR(MAX),( SELECT a.[text] + N' '
																				FROM  sys.syscomments AS A
																				WHERE 1=1
																				AND A.id=O.object_id
																				ORDER BY id,colid
																				FOR XML PATH('')))
												,CHAR(13)+CHAR(10), ' ') 
											,CHAR(13), ' ') 
										, CHAR(10),' ') 
									, CHAR(9),' ') 					
								, '&#x0D;',' ') AS DefinationText
						, o.create_date
						, o.modify_date
					FROM  sys.objects AS O
					WHERE 1=1
					AND o.[schema_id] = 1
					--AND Name IN ('usp_SLIPED_BulkTermMSOUpdate','usp_SLIPED_InterMSORehomeAAVChange','usp_SLIPED_UpdateBH')
					AND O.Type IN ('P','TF','TR','TT','V','FN')
				) AS Tbl
			WHERE 1=1
			--AND Tbl.DefinationText LIKE '%'+ RTRIM(LTRIM(@ObjName))+'%'
			--AND (DefinationText LIKE '% INSERT %' OR DefinationText LIKE '% UPDATE %' OR DefinationText LIKE '% DELETE %' OR DefinationText LIKE '% MERGE %')
	) AS t 
	
	UNION ALL
	
	SELECT CAST(message_id AS VARCHAR(255)) AS ObjectId
		, 'Message' AS ObjectType
		, 'RaisError' AS ObjectName
		, [text] AS DefinationText
		, NULL, NULL
	FROM sys.messages 
	WHERE text LIKE '%'+ @vSearchText +'%'
	AND message_id > 50000
	
	UNION ALL
	
	SELECT 'JOB:: ' + CAST(j.name COLLATE DATABASE_DEFAULT AS VARCHAR(255)) AS ObjectId
		, js.subsystem COLLATE DATABASE_DEFAULT
		, js.step_name COLLATE DATABASE_DEFAULT		
		, js.command COLLATE DATABASE_DEFAULT
		, j.date_created
		, (CASE WHEN js.last_run_date > 0 
			THEN CONVERT(DATETIME, CONCAT(LEFT(CAST(js.last_run_date AS VARCHAR(10)), 4), '-', SUBSTRING(CAST(js.last_run_date AS VARCHAR(10)), 5, 2), '-', RIGHT(CAST(js.last_run_date AS VARCHAR(10)), 2)))
			ELSE NULL 
		  END) AS last_run_date
	FROM msdb.dbo.sysjobs AS j
	JOIN msdb.dbo.sysjobsteps AS js 
		ON j.job_id = js.job_id
	WHERE js.command LIKE '%' + @vSearchText + '%'
	AND js.database_name = DB_NAME()

END;


SELECT ObjectId, ObjectType, ObjectName
		--, DefinationText
		, SUBSTRING(DefinationText, CHARINDEX(@vSearchText, DefinationText) - 150, 300) AS DefinationSubset
		, create_date
		, modify_date
FROM #tempSearchDbObjectResult
WHERE 1=1
--AND DefinationText LIKE '%pRemoveBackhaulHistory%'	
AND DefinationText LIKE '%' + @vSearchText + '%'	
ORDER BY ObjectName

--SELECT * FROM sys.messages WHERE TEXT LIKE '%any more backhaul%'
