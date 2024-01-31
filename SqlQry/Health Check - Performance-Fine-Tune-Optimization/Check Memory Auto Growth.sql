/*
BH20230723 :  Database File Size and Auto-growth property, Dispaly list of such files setting and Check how much times the Auto Growth triggered and its frequencey
*/
USE master
GO

-----------------------------------------------------------------------------------------------------------------------
-->  Identify databases that have default auto-grow settings
-----------------------------------------------------------------------------------------------------------------------


-- Drop temporary table if it exists
IF OBJECT_ID('tempdb..#info') IS NOT NULL
       DROP TABLE #info;

-- Create table to house database file information
CREATE TABLE #info (
     databasename VARCHAR(128)
     ,name VARCHAR(128)
    ,fileid INT
    ,filename VARCHAR(1000)
    ,filegroup VARCHAR(128)
    ,size VARCHAR(25)
    ,maxsize VARCHAR(25)
    ,growth VARCHAR(25)
    ,usage VARCHAR(25));
    
-- Get database file information for each database   
SET NOCOUNT ON; 
INSERT INTO #info
EXEC sp_MSforeachdb 'use ? 
select ''?'',name,  fileid, filename,
filegroup = filegroup_name(groupid),
''size'' = convert(nvarchar(15), convert (bigint, size) * 8) + N'' KB'',
''maxsize'' = (case maxsize when -1 then N''Unlimited''
else
convert(nvarchar(15), convert (bigint, maxsize) * 8) + N'' KB'' end),
''growth'' = (case status & 0x100000 when 0x100000 then
convert(nvarchar(15), growth) + N''%''
else
convert(nvarchar(15), convert (bigint, growth) * 8) + N'' KB'' end),
''usage'' = (case status & 0x40 when 0x40 then ''log only'' else ''data only'' end)
from sysfiles
';
 
-- Identify database files that use default auto-grow properties
SELECT databasename AS [Database Name]
      , name AS [Logical Name]
      , filename AS [Physical File Name]
      , growth AS [Auto-grow Setting] 
	  --, LTRIM(RTRIM(REPLACE(size,'KB',''))) AS SizeKB
	  , CONVERT(DECIMAL(18,4), (CAST(REPLACE(size,'KB','') AS FLOAT))/1000.0) AS SizeMB
	  , CONVERT(DECIMAL(18,4), (CAST(REPLACE(size,'KB','') AS FLOAT))/1000.0/1000.0) AS SizeGB
	  , maxsize 
FROM #info 
WHERE (usage = 'data only' AND growth = '1024 KB') 
   OR (usage = 'log only' AND growth = '10%')
ORDER BY databasename
 
-- get rid of temp table 
DROP TABLE #info;


GO

-----------------------------------------------------------------------------------------------------------------------
-->  Display Auto-growth Events Contained in the Default Trace files
-----------------------------------------------------------------------------------------------------------------------


DECLARE @filename NVARCHAR(1000);
DECLARE @bc INT;
DECLARE @ec INT;
DECLARE @bfn VARCHAR(1000);
DECLARE @efn VARCHAR(10);
 
-- Get the name of the current default trace
SELECT @filename = CAST(value AS NVARCHAR(1000))
FROM ::fn_trace_getinfo(DEFAULT)
WHERE traceid = 1 AND property = 2;
 
-- rip apart file name into pieces
SET @filename = REVERSE(@filename);
SET @bc = CHARINDEX('.',@filename);
SET @ec = CHARINDEX('_',@filename)+1;
SET @efn = REVERSE(SUBSTRING(@filename,1,@bc));
SET @bfn = REVERSE(SUBSTRING(@filename,@ec,LEN(@filename)));
 
-- set filename without rollover number
SET @filename = @bfn + @efn
 
-- process all trace files
SELECT ftg.StartTime
	, te.name AS EventName
	, DB_NAME(ftg.databaseid) AS DatabaseName  
	, ftg.Filename
	, (ftg.IntegerData*8)/1024.0 AS GrowthMB 
	, (ftg.duration/1000)AS DurMS
FROM ::fn_trace_gettable(@filename, DEFAULT) AS ftg 
INNER JOIN sys.trace_events AS te 
	ON ftg.EventClass = te.trace_event_id  
WHERE (ftg.EventClass = 92  -- Date File Auto-grow
    OR ftg.EventClass = 93) -- Log File Auto-grow
ORDER BY ftg.StartTime;

GO
PRINT '~DONE~'
GO
