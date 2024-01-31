/**************************************** SEARCH OBJECT TEXT ****************************************/
DECLARE @vForceRefresh BIT=0;
Declare @ObjName VARCHAR(100);

SET @ObjName ='ClaimLine';
-----------------------------------------------------------------------------------------------------------------------

SET NOCOUNT ON;

--Search for Object
SET @ObjName = ' '+ LTRIM(RTRIM(@ObjName)) + ' ';
	
IF NOT EXISTS (select 1 from tempdb.sys.tables WHERE create_date > DATEADD(MINUTE,-120,GETDATE()) AND object_id=object_id('tempdb..#tmp_searched_objects'))
	OR @vForceRefresh=1 
BEGIN   
	PRINT 'Creating fresh table'
	
	IF object_id('tempdb..#tmp_searched_objects') IS NOT NULL
		DROP TABLE #tmp_searched_objects;	
	
	SELECT ObjectId,ObjectType, ObjectName, DefinationText
	INTO #tmp_searched_objects 
	FROM 
	(
		SELECT ObjectId,ObjectType, ObjectName
			, REPLACE(				
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
			 , ' AS ',' ') AS DefinationText													
			FROM (
					SELECT O.[Object_Id] AS ObjectId
							, O.type_desc AS ObjectType				
							, O.Name AS ObjectName
							,	REPLACE(
									REPLACE(				
										REPLACE(
											REPLACE(  
												REPLACE(Convert(NVARCHAR(MAX),( SELECT a.[text] + N' '
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
					--AND Name IN ('usp_SLIPED_RunUpdateBundlePairs')
					AND O.Type IN ('P','TF','TR','TT')
				) As Tbl
			WHERE 1=1			
			AND (DefinationText LIKE '% INSERT %' OR DefinationText LIKE '% UPDATE %' OR DefinationText LIKE '% DELETE %' OR DefinationText LIKE '% MERGE %')
	) As Result1 
	WHERE 1=1			
	ORDER BY ObjectName;
END;

/*
SELECT ObjectId,ObjectType,ObjectName
		, DefinationText 
from #tmp_searched_objects
--*/

--Create Result Table
IF OBJECT_ID('tempdb..#tmp_search_result') IS NOT NULL 
	DROP TABLE #tmp_search_result;			
	
CREATE TABLE #tmp_search_result
(
	ObjectId		INT NULL,
	ObjectType		VARCHAR(255) NULL,
	ObjectName		VARCHAR(255) NULL,
	ActionName		VARCHAR(50) NULL,
	ActionText		VARCHAR(100) NULL,
	ObjectText		VARCHAR(100) NULL,
	DefinationText	VARCHAR(MAX) NULL,		
	SearchLevel		INT NULL,
);

DECLARE Scur CURSOR FOR
	SELECT ObjectId,ObjectType,ObjectName,DefinationText
	FROM #tmp_searched_objects
	WHERE 1=1
	AND DefinationText LIKE '%'+@ObjName+'%'
	ORDER BY ObjectType, ObjectName;

DECLARE @vObjectId AS INT
		, @vObjectType AS VARCHAR(100)
		, @vOName AS VARCHAR(500)
		, @vODef AS VARCHAR(MAX);

OPEN Scur;
FETCH Scur INTO @vObjectId,@vObjectType, @vOName, @vODef

WHILE @@FETCH_STATUS = 0
BEGIN
	Declare @intLookBackCnt INT = 100 
			, @strDefinationText AS VARCHAR(MAX)
			, @intObjectTextStart INT=0
			, @intFoundCnt INT=0
			, @intOT_LookingNext INT=0
			, @intActionTextStart INT=0
			, @strActionText AS VARCHAR(100)
			, @strObjectText AS VARCHAR(100);
	
	--Do proper Defination Text	
	SET @vODef = REPLACE(@vODef,CHAR(13)+CHAR(10),' ');
	SET @vODef = REPLACE(@vODef,CHAR(10)+CHAR(32),' ');
	SET @vODef = REPLACE(@vODef,CHAR(32)+CHAR(10),' ');
	SET @vODef = REPLACE(@vODef,CHAR(10),' ');
	SET @vODef = REPLACE(@vODef,CHAR(13),' ');
	SET @vODef = REPLACE(@vODef,CHAR(9),' ');	
	SET @vODef = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(@vODef,' ','<>'),'><',''),'<>',' ')));		
	SET @vODef = REPLACE(@vODef, ' '+ LTRIM(RTRIM(@ObjName))+'(' ,' '+ LTRIM(RTRIM(@ObjName))+' (');
	
	--#1 First Level Search	
	SET @intObjectTextStart = CHARINDEX('MERGE INTO'+ @ObjName +'',@vODef);	
	IF (ISNULL(@intFoundCnt,0)= 0) AND (@intObjectTextStart>0)
	BEGIN
		SET @strDefinationText = SUBSTRING(@vODef,@intObjectTextStart-50,80 )
		
		INSERT INTO #tmp_search_result (ObjectId, ObjectType, ObjectName, ActionName, ActionText, ObjectText, DefinationText,SearchLevel)
		VALUES (@vObjectId, @vObjectType, @vOName, 'MERGE','','', @strDefinationText, 1);
		
		SET @intFoundCnt=1;
	END
	
	SET @intObjectTextStart = CHARINDEX('INSERT INTO'+ @ObjName +'',@vODef);	
	IF (ISNULL(@intFoundCnt,0)= 0) AND (@intObjectTextStart>0)
	BEGIN
		SET @strDefinationText = SUBSTRING(@vODef,@intObjectTextStart-50,80 )
		
		INSERT INTO #tmp_search_result (ObjectId, ObjectType, ObjectName, ActionName, ActionText,ObjectText, DefinationText,SearchLevel)
		VALUES (@vObjectId, @vObjectType, @vOName, 'INSERT','','', @strDefinationText, 1);
		
		SET @intFoundCnt=1;
	END
	
	SET @intObjectTextStart = CHARINDEX('UPDATE'+ @ObjName +'',@vODef);	
	IF (ISNULL(@intFoundCnt,0)= 0) AND (@intObjectTextStart>0)
	BEGIN
		SET @strDefinationText = SUBSTRING(@vODef,@intObjectTextStart-50,80 )
		
		INSERT INTO #tmp_search_result (ObjectId, ObjectType, ObjectName, ActionName, ActionText, ObjectText, DefinationText,SearchLevel)
		VALUES (@vObjectId, @vObjectType, @vOName, 'UPDATE','','', @strDefinationText, 1);
		
		SET @intFoundCnt=1;
	END
	
	SET @intObjectTextStart = CHARINDEX('DELETE FROM'+ @ObjName +'',@vODef);	
	IF (ISNULL(@intFoundCnt,0)= 0) AND (@intObjectTextStart>0)
	BEGIN
		SET @strDefinationText = SUBSTRING(@vODef,@intObjectTextStart-50,80 )
		
		INSERT INTO #tmp_search_result (ObjectId, ObjectType, ObjectName, ActionName, ActionText,ObjectText, DefinationText,SearchLevel)
		VALUES (@vObjectId, @vObjectType, @vOName, 'DELETE','','', @strDefinationText, 1);
		
		SET @intFoundCnt=1;
	END
	
	
	--#2 Second Level Search		
	IF (ISNULL(@intFoundCnt,0)= 0) 
	BEGIN
		--PRINT '--->SP:	' + @vOName
			
		SET @intOT_LookingNext=1;
		WHILE @intObjectTextStart<=LEN(@vODef) AND (ISNULL(@intFoundCnt,0)= 0)
		BEGIN
			SET @intObjectTextStart = CHARINDEX(@ObjName,@vODef,@intOT_LookingNext);
			
			IF @intObjectTextStart<=0
			BEGIN
				BREAK;
			END				
			SET @intLookBackCnt=100;
			WHILE @intLookBackCnt<=2000 AND (ISNULL(@intFoundCnt,0)= 0)
			BEGIN
			
				SET @strDefinationText = SUBSTRING(@vODef,@intObjectTextStart-@intLookBackCnt, @intLookBackCnt+25 )			
				
				IF (ISNULL(@intFoundCnt,0)= 0) AND (@strDefinationText LIKE '% UPDATE % SET %')
				BEGIN
					SET @intActionTextStart = CHARINDEX(' UPDATE ',@strDefinationText);
					SET @strActionText = SUBSTRING(@strDefinationText,@intActionTextStart-5, 80);
					SET @strObjectText = RIGHT(@strDefinationText,40);
					
					INSERT INTO #tmp_search_result (ObjectId, ObjectType, ObjectName, ActionName, ActionText, ObjectText, DefinationText,SearchLevel)
					VALUES (@vObjectId, @vObjectType, @vOName, 'UPDATE', @strActionText, @strObjectText, @strDefinationText, 2);
					
					SET @intFoundCnt=1;
					
					BREAK;
				END
				
				IF (ISNULL(@intFoundCnt,0)= 0) AND (@strDefinationText LIKE '% DELETE % FROM %')
				BEGIN
					SET @intActionTextStart = CHARINDEX(' DELETE ',@strDefinationText);
					SET @strActionText = SUBSTRING(@strDefinationText,@intActionTextStart-5, 80);
					SET @strObjectText = RIGHT(@strDefinationText,40);
					
					INSERT INTO #tmp_search_result (ObjectId, ObjectType, ObjectName, ActionName, ActionText, ObjectText, DefinationText,SearchLevel)
					VALUES (@vObjectId, @vObjectType, @vOName, 'DELETE', @strActionText, @strObjectText, @strDefinationText, 2);
					
					SET @intFoundCnt=1;
					
					BREAK;
				END
				
				SET @intOT_LookingNext=@intObjectTextStart+LEN(@ObjName)+1;					
				SET @intLookBackCnt = @intLookBackCnt+200;			
			END				
		END; --while		
	END;--if
	
	FETCH Scur INTO @vObjectId,@vObjectType, @vOName, @vODef
END; --while fetch status


CLOSE Scur;
DEALLOCATE Scur;

--Showing Resut Text
SELECT object_id,1 AS SearchLevel
	, 'EVENT' AS ActionName
	, 'TRG' AS ObjectType
	, name AS ObjectName
	, '' AS ActionText 
	, '' AS ObjectText
	, '' AS DefinationText
FROM SYS.TRIGGERS 
WHERE 1=1
AND name NOT LIKE '%_colaud'	AND name NOT LIKE '%_rowaud'
AND parent_id = OBJECT_ID(RTRIM(LTRIM(@ObjName)))
UNION ALL
SELECT ObjectId
	, SearchLevel
	, ActionName
	, (	CASE WHEN ObjectType='SQL_STORED_PROCEDURE' 	
				THEN 'SP' 
			WHEN ObjectType='SQL_TRIGGER' 		
				THEN 'TRG' 
			WHEN ObjectType='SQL_TABLE_VALUED_FUNCTION'	
				THEN 'UDF'
			ELSE ObjectType 			
		END) AS ObjectType
	, ObjectName
	, ActionText
	, ObjectText
	, DefinationText	
FROM #tmp_search_result
WHERE 1=1
AND ObjectName NOT IN (SELECT name AS ObjectName 
						FROM SYS.TRIGGERS 
						WHERE 1=1
						AND name NOT LIKE '%_colaud'	AND name NOT LIKE '%_rowaud'
						AND parent_id = OBJECT_ID(RTRIM(LTRIM(@ObjName))) )
ORDER BY SearchLevel, ActionName, ObjectName; 	

DROP TABLE #tmp_search_result;

	