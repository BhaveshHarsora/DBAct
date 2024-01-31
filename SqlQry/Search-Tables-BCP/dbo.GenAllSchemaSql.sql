USE [LogDB]
GO

/****** Object:  UserDefinedFunction [dbo].[GenAllSchemaSql]    Script Date: 2/23/2021 7:17:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[GenAllSchemaSql] 
(
	@pSqlTx AS VARCHAR(MAX)
	, @pReplSchemaName AS VARCHAR(50)
) 
RETURNS XML
AS 
BEGIN 
	declare @vXml as XML, @vXmlStr as varchar(max);
	
	set @pSqlTx = concat(@pSqlTx ,'
	');

	set @vXml= --replace(replace(convert(varchar(max),
		(select REPLACE(@pSqlTx, @pReplSchemaName, a.SchemaName)
			from  (
				select distinct x.SchemaName
				from Dashboard.dbo.casinos AS x
			) as a
		for xml PATH(''))
		--),'&gt;','>'),'&lt;','<')
		;
	
	 --set @vXml = convert(xml, concat('<xmlData>',@vXmlStr,'</xmlData>'));	

	RETURN @vXml;
END;
GO

