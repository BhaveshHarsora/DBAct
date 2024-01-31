--USE FileSearchTest
/*
Date: 09/10/2019
Find text in File
Text Search in File
*/
Use FileSearchTest
GO

DECLARE @pSearchText AS VARCHAR(MAX);
DECLARE @vForceRefresh BIT=0;

-----------------------------------------------------------------------------------------------------------------------

SET @pSearchText = 'Utili' --> Search text

-----------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (select 1 from tempdb.sys.tables WHERE create_date > DATEADD(MINUTE,-120,GETDATE()) AND object_id=object_id('tempdb..#tempSearchInFileTable'))
	OR @vForceRefresh=1 
BEGIN   
	PRINT 'Creating fresh table'
	
	IF object_id('tempdb..#tempSearchInFileTable') IS NOT NULL
		DROP TABLE #tempSearchInFileTable

	;With cte AS (
		select 
			(CASE WHEN a.is_directory = 1 THEN 'Folder' ELSE 'File' END) AS [FileORFolder]
			, a.[name] AS [FileName]
			, a.file_type
			, a.creation_time
			, a.last_write_time
			, LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
					REPLACE(
						REPLACE(				
							REPLACE(
								REPLACE(  
									REPLACE(Convert(VARCHAR(MAX), a.file_stream)
									,CHAR(13)+CHAR(10), ' ') 
								,CHAR(13), ' ') 
							, CHAR(10),' ') 
						, CHAR(9),' ') 					
					, '&#x0D;',' ')
				, '[','') 
				, ']','') 			
				, ' ','<>') 
				, '><','') 
				, '<>',' ') 			
				, ' AS ',' '))) AS FileContent
		from FindInFiles as a
		where 1=1
		--and CONVERT(NVARCHAR(MAX), a.file_stream) like '%updateByControlId%'
	)
	SELECT * INTO #tempSearchInFileTable FROM cte;
END;


select 
	a.FileORFolder
	, a.[FileName]
	, a.file_type	
	, a.creation_time
	, a.last_write_time
	-- , a.FileContent
from #tempSearchInFileTable AS a
where 1=1
and a.FileContent LIKE CONCAT('%',@pSearchText,'%');


GO
PRINT '~DONE~'
GO