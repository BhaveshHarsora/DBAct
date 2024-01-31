/*
Date: 15-Jan-2018
Below T-SQL finds the Table Name and Columns used within given Procedure (@vProcName)
*/
USE RptAllscripts
GO

DECLARE @vForceRefresh BIT = 0;
DECLARE @vProcName AS VARCHAR(MAX);

SET @vProcName = 'ho_VerificationFamilyAndFriends';
-----------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS (select 1 from tempdb.sys.tables WHERE create_date > DATEADD(MINUTE,-120,GETDATE()) AND object_id=object_id('tempdb..#tempSearchDbObjectResult'))
	OR @vForceRefresh=1 
BEGIN   
	PRINT 'Creating fresh table'


	IF object_id('tempdb..#tempSearchDbObjectResult') IS NOT NULL
		DROP TABLE #tempSearchDbObjectResult
	SELECT *
	INTO #tempSearchDbObjectResult
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
					SELECT O.Object_Id AS ObjectId
							, O.type_desc AS ObjectType				
							, O.Name AS ObjectName
							,	REPLACE(
									REPLACE(				
										REPLACE(
											REPLACE(  
												REPLACE(Convert(NVARCHAR(MAX),( SELECT A.text + N' '
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
					--AND O.Type IN ('P','TF','TR','TT','V')
					AND O.Type IN ('P')
				) As Tbl
			WHERE 1=1
	) As Result1 

END;

WITH cte AS (
	SELECT * 
	FROM #tempSearchDbObjectResult
	WHERE objectType= 'SQL_STORED_PROCEDURE'
	AND objectName = @vProcName
)
select b.[name] As TableName, c.[name] AS ColumnName
from cte as a
JOIN MHC.sys.tables as b
	JOIN MHC.sys.columns AS c
		ON c.object_id = b.object_id			
	ON (a.definationText LIKE '% FROM%' + b.[name] + ' %'
		OR a.definationText LIKE '% JOIN%' + b.[name]  + ' %')
WHERE 1=1
AND ( a.definationText LIKE '%' + c.[name] + ',%'
	OR a.definationText LIKE '%' + c.[name]  + ' =%'
	OR a.definationText LIKE '%= ' +  c.[name] + '%'
	OR a.definationText LIKE '%=%.' +  c.[name] + '%'
	OR a.definationText LIKE '%' + c.[name]  + ' IS%'
	)
ORDER BY b.[name], c.[name]



