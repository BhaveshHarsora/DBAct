/*
Below DB scripts is downloads all the reports from the SSRS Reporting Server

DB Script made by: Bhavesh J
Date: 13-Jun-2017
*/
USE master
GO

--------------------------------------------------------------------------------
-- Allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1
GO
-- Update the currently configured value for advanced options.
RECONFIGURE
GO
-- Enable xp_cmdshell
EXEC sp_configure 'xp_cmdshell', 1
GO
-- Update the currently configured value for xp_cmdshell
RECONFIGURE
GO-- Disallow further advanced options to be changed.
EXEC sp_configure 'show advanced options', 0
GO
-- Update the currently configured value for advanced options.
RECONFIGURE
GO  
--------------------------------------------------------------------------------



--<<<<<<<<<<<<<<<<<<<<<<<<< Configure Your Values here >>>>>>>>>>>>>>>>>>>>>>>>>

-- Crenditials
DECLARE @vSqlServerName AS VARCHAR(100), @vSqlUserName AS VARCHAR(100), @vSqlPassword AS VARCHAR(100), @vUseWindowsAuthentication AS BIT;

--Replace NULL with keywords of the ReportManager's Report Path, 
--if reports from any specific path are to be downloaded
DECLARE @FilterReportPath AS VARCHAR(500) = NULL 

--Replace NULL with the keyword matching the Report File Name,
--if any specific reports are to be downloaded
DECLARE @FilterReportName AS VARCHAR(500) = NULL

--Replace this path with the Server Location where you want the
--reports to be downloaded..
DECLARE @OutputPath AS VARCHAR(500) 

SET @vSqlServerName = 'PC7\MSSQL2012'		-- e.g. PC7\MSSQL2012
SET @vSqlUserName = 'sa';					-- e.g. sa
SET @vSqlPassword = '';						-- e.g. sa password
SET @vUseWindowsAuthentication = 1			-- e.g. {1, 0}
SET @OutputPath = 'D:\tmp\';				-- e.g. D:\Reports\Downloads\




 --<<<<<<<<<<<<<<<<<<<<<<<<< CODE NOT TO BE CHANGED >>>>>>>>>>>>>>>>>>>>>>>>>

SELECT @vSqlUserName = CONCAT('-U', @vSqlUserName) WHERE ISNULL(@vSqlUserName, '') != ''
SELECT @vSqlPassword = CONCAT('-P', @vSqlPassword) WHERE ISNULL(@vSqlPassword, '') != ''
SELECT @vSqlServerName = CONCAT('-S', @vSqlServerName) WHERE ISNULL(@vSqlServerName, '') != ''

--Used to prepare the dynamic query
DECLARE @TSQL AS NVARCHAR(MAX)

--Reset the OutputPath separator.
SET @OutputPath = REPLACE(@OutputPath,'\','/')

--Simple validation of OutputPath; this can be changed as per ones need.
IF LTRIM(RTRIM(ISNULL(@OutputPath,''))) = ''
BEGIN
  SELECT 'Invalid Output Path'
END
ELSE
BEGIN
   --Prepare the query for download.
   /*
   Please note the following points -
   1. The BCP command could be modified as per ones need. E.g. Providing UserName/Password, etc.
   2. Please update the SSRS Report Database name. Currently, it is set to default - [ReportServer$MSSQL2012]
   3. The BCP does not create missing Directories. So, additional logic could be implemented to handle that.
   4. SSRS stores the XML items (Report RDL and Data Source definitions) using the UTF-8 encoding. 
      It just so happens that UTF-8 Unicode strings do not NEED to have a BOM and in fact ideally would not have one. 
      However, you will see some report items in your SSRS that begin with a specific sequence of bytes (0xEFBBBF). 
      That sequence is the UTF-8 Byte Order Mark. It’s character representation is the following three characters, “ï»¿”. 
      While it is supported, it can cause problems with the conversion to XML, so it is removed.
   */
   SET @TSQL = STUFF((SELECT
                      ';EXEC master..xp_cmdshell ''bcp " ' +
                      ' SELECT ' +
                      ' CONVERT(VARCHAR(MAX), ' +
                      '       CASE ' +
                      '         WHEN LEFT(C.Content,3) = 0xEFBBBF THEN STUFF(C.Content,1,3,'''''''') '+
                      '         ELSE C.Content '+
                      '       END) ' +
                      ' FROM ' +
                      ' [ReportServer$MSSQL2012].[dbo].[Catalog] CL ' +
                      ' CROSS APPLY (SELECT CONVERT(VARBINARY(MAX),CL.Content) Content) C ' +
                      ' WHERE ' +
                      ' CL.ItemID = ''''' + CONVERT(VARCHAR(MAX), CL.ItemID) + ''''' " queryout "' + @OutputPath + '' + CL.Name + '.rdl" ' 					  
						--+ ' -T -c -SPC7\MSSQL2012'' '
						+ ' -T -c ' 
						+ CASE WHEN @vUseWindowsAuthentication = 1 THEN '' ELSE CONCAT(@vSqlUserName, ' ', @vSqlPassword, ' ') END
						+ @vSqlServerName 
						+ ''' '
                    FROM
                      [ReportServer$MSSQL2012].[dbo].[Catalog] CL
                    WHERE
                      CL.[Type] = 2 --Report
                      AND '/' + CL.[Path] + '/' LIKE COALESCE('%/%' + @FilterReportPath + '%/%', '/' + CL.[Path] + '/')
                      AND CL.Name LIKE COALESCE('%' + @FilterReportName + '%', CL.Name)
                    FOR XML PATH('')), 1,1,'')
  
  --SELECT @TSQL AS ExecutedTSQL
  
  --Execute the Dynamic Query
  EXEC SP_EXECUTESQL @TSQL
END
GO