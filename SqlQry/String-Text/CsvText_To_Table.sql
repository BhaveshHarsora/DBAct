--USE JustTest
GO

DECLARE @vDataText AS NVARCHAR(MAX),  @vXmlStr AS NVARCHAR(MAX), @xmlData AS xml;
SET @vDataText = '
Mailbox,E-mail,Organization,Protection Status,Last Backup Date
ABBEY LAPLANA,ABBEY.LAPLANA@hunterdouglas.com.au,hunterdouglascomau.onmicrosoft.com,Protected,12/26/2020
Documents,Documents@hunterdouglas.com.au,hunterdouglascomau.onmicrosoft.com,Protected,12/26/2020
"Human Resources & Workplace, Health & Safety",HumanResources@hunterdouglas.com.au,hunterdouglascomau.onmicrosoft.com,Protected,12/26/2020
BSManagers chat,BSManagerschat@hunterdouglas.com.au,hunterdouglascomau.onmicrosoft.com,Protected,12/26/2020
';

/*
SET @vXmlStr = '"Human Resources & Workplace, Health & Safety",HumanResources@hunterdouglas.com.au,hunterdouglascomau.onmicrosoft.com,Protected,12/26/2020';
SELECT @vXmlStr 
	, SUBSTRING(@vXmlStr, CHARINDEX('"',@vXmlStr)+1,CHARINDEX('"',@vXmlStr,CHARINDEX('"',@vXmlStr)+1)-2)
	, SUBSTRING(@vXmlStr,  CHARINDEX('",',@vXmlStr)+1, 8000)
	, REPLACE(SUBSTRING(@vXmlStr, CHARINDEX('"',@vXmlStr)+1,CHARINDEX('"',@vXmlStr,CHARINDEX('"',@vXmlStr)+1)-2),',','^')+ SUBSTRING(@vXmlStr,  CHARINDEX('",',@vXmlStr)+1, 8000)
	
"Human Resources & Workplace, Health & Safety",HumanResources@hunterdouglas.com.au,hunterdouglascomau.onmicrosoft.com,Protected,12/26/2020
Human Resources & Workplace; Health & Safety,HumanResources@hunterdouglas.com.au,hunterdouglascomau.onmicrosoft.com,Protected,12/26/2020
*/
SELECT [1] AS AccountName
	, [2] AS Organization
	, [3] AS Column3
	, [4] AS Column4
	, [5] AS Column5
	, BINARY_CHECKSUM([1],[2],[3],[4],[5]) AS ChkSm
FROM (
	SELECT t1.RowNo, t1.ColNo, t1.colData
	FROM (
		SELECT r.RowNo, c.*
		FROM (
			SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS RowNo
				, RTRIM(LTRIM(y.rowData)) AS rowData
			FROM (
				SELECT (CASE WHEN CHARINDEX('"',x.[value]) > 0
						THEN REPLACE(
									SUBSTRING(x.[value]
										, CHARINDEX('"',x.[value])+1
										, CHARINDEX('",',x.[value])-3 )
									, ',','^') + SUBSTRING(x.[value],  CHARINDEX('",',x.[value])+1, 8000)
						ELSE x.[value] 
					END) AS rowData 
				FROM STRING_SPLIT(@vDataText,CHAR(13)) AS X
			) AS Y
			WHERE ISNULL(Y.rowData, '') != ''	
		) AS r
		CROSS APPLY (
			SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS ColNo
				, REPLACE(c.[value],'^',',') AS colData
			FROM STRING_SPLIT(r.rowData,',') AS c	
			WHERE 1=1
			AND r.RowNo>1
		) AS c
		WHERE 1=1
	) AS t1
) AS t
PIVOT (
	MAX(colData) FOR t.ColNo IN ([1],[2],[3],[4],[5])
) AS p
WHERE 1=1
AND LEN(LTRIM(RTRIM(COALESCE([1],[2],[3],[4],[5],'')))) > 1

------------------------------------------------

--SELECT *
--FROM (
--	SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS RowNo
--		, RTRIM(LTRIM(y.rowData)) AS rowData
--	FROM (SELECT x.[value] AS rowData FROM STRING_SPLIT(@vDataText,CHAR(13)) AS X) AS Y
--	WHERE ISNULL(Y.rowData, '') != ''	
--) AS r
--CROSS APPLY (
--	SELECT SUBSTRING(r.rowData, 1, idx.Col1_Idx-1) AS AccountName
--		, SUBSTRING(r.rowData, idx.Col1_Idx+1, idx.Col2_Idx) AS Organization
		
--		, idx.*
--	FROM (
--		SELECT CHARINDEX(',', r.rowData) AS Col1_Idx
--			, ISNULL(NULLIF(CHARINDEX(',', r.rowData, CHARINDEX(',', r.rowData)+1), 0), 8000) AS Col2_Idx
--	) AS idx
--	WHERE r.RowNo > 1
--	AND CHARINDEX(',', r.rowData) > 1
--) AS c
--WHERE 1=1


------------------------------------------------

--SET @vXmlStr = REPLACE(@vDataText,CHAR(13),'</orgNm></xrow><xrow><accNm>');
--SET @vXmlStr = CONCAT('<xdata><xrow><accNm>',REPLACE(@vXmlStr,',','</accNm><orgNm>'),'</orgNm></xrow></xdata>');


--SET @xmlData = '
--<xdata>
--	<xrow>
--		<accNm>matt.ryan@sport.nsw.gov.au</accNm>
--		<orgNm>sportnswgov.onmicrosoft.com</orgNm>
--	</xrow>
--	<xrow>
--		<accNm>caitlin.johnson@sport.nsw.gov.auu</accNm>
--		<orgNm>sportnswgov.onmicrosoft.com</orgNm>
--	</xrow>
--</xdata> ';

--PRINT @vXmlStr;

--SELECT tbl.col.value('accNm[1]', 'NVARCHAR(MAX)') AS accNm
--	, tbl.col.value('orgNm[1]', 'NVARCHAR(MAX)') AS orgNm
--FROM @xmlData.nodes('xdata/xrow') tbl(col)

------------------------------------------------


--declare @myJson nvarchar(MAX)
--SET @myJson = '[['+  replace(@vDataText, Char(13)+Char(10), '],[' )  +']]'
---- set @myJson = replace(@myJson, ';',',')         -- Optional: ensure coma delimiters for json if the current delimiter differs
----  set @myJson = replace(@myJson, ',,',',null,')   -- Optional: empty in between
----  set @myJson = replace(@myJson, ',]',',null]')   -- Optional: empty before linebreak
--PRINT @myJson    
--SELECT
--    ROW_NUMBER() OVER (ORDER BY (SELECT 0))-1 AS LineNumber, *
--    FROM   OPENJSON( @myJson ) 
--    with (
--         col0   varchar(255)    '$[0]'
--        ,col1   varchar(255)    '$[1]'
--        ,col2   varchar(255)    '$[2]'
--        ,col3   varchar(255)    '$[3]'
--        ,col4   varchar(255)    '$[4]'
--        ,col5   varchar(255)    '$[5]'
--        ,col6   varchar(255)    '$[6]'
--        ,col7   varchar(255)    '$[7]'
--        ,col8   varchar(255)    '$[8]'  
--        ,col9   varchar(255)    '$[9]'
--        --any name column count is possible
--    ) csv
--    order by (SELECT 0) OFFSET 1 ROWS --hide header row

--SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS RowNo
--		, x.[value] AS rowData 
--	FROM STRING_SPLIT(@vDataText,CHAR(13)) AS x
--SELECT * FROM STRING_SPLIT('matt.ryan@sport.nsw.gov.au,sportnswgov.onmicrosoft.com',',')

------------------------------------------------


--SELECT *
--FROM (
--	SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS RowNo, y.rowData
--	FROM (SELECT x.[value] AS rowData FROM STRING_SPLIT(@vDataText,CHAR(13)) AS X) AS Y
--	WHERE ISNULL(Y.rowData, '') != ''
--) AS r
--CROSS APPLY (
--	SELECT CAST( (CONCAT( '<Name>' , REPLACE(r.rowData, ',', '</Name><Name>') , '</Name>') ) AS XML) AS xmlData
--) AS c
--CROSS APPLY (
--	SELECT TableA.value('.', 'VARCHAR(100)') AS Name
--	FROM c.xmlData.nodes('Name')e(TableA)
--) AS d
--WHERE 1=1


--DECLARE @XML XML;
--SET @XML = CAST( (CONCAT( '<Name>' , REPLACE(@vDataText, ',', '</Name><Name>') , '</Name>') ) AS XML)


--SELECT * 
--FROM (SELECT 1 AS id) AS a
--CROSS APPLY (
--	SELECT TableA.value('.', 'VARCHAR(100)') AS Name
--	FROM @XML.nodes('Name')e(TableA)
--) AS t


------------------------------------------------

