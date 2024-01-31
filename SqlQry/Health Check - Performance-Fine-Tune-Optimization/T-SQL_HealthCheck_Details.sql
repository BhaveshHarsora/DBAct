DECLARE  
  @MailProfile NVARCHAR(200) = NULL,   
  @MailID NVARCHAR(2000) = NULL,  
  @Server VARCHAR(100) = NULL;

SET NOCOUNT ON;  
SET ARITHABORT ON;  
  
DECLARE @ServerName VARCHAR(100);  
SET @ServerName = ISNULL(@Server,@@SERVERNAME);  


IF OBJECT_ID('tempdb..#RebootDetails') IS NOT NULL	DROP TABLE  #RebootDetails;  
IF OBJECT_ID('tempdb..#FreeSpace') IS NOT NULL	DROP TABLE	#FreeSpace;
IF OBJECT_ID('tempdb..#BlkProcesses') IS NOT NULL	DROP TABLE  #BlkProcesses  
IF OBJECT_ID('tempdb..#ErrorLogInfo') IS NOT NULL	DROP TABLE  #ErrorLogInfo  
IF OBJECT_ID('tempdb..#CPU') IS NOT NULL	DROP TABLE  #CPU  
IF OBJECT_ID('tempdb..#Memory_BPool') IS NOT NULL	DROP TABLE  #Memory_BPool;  
IF OBJECT_ID('tempdb..#Memory_sys') IS NOT NULL	DROP TABLE  #Memory_sys;  
IF OBJECT_ID('tempdb..#Memory_process') IS NOT NULL	DROP TABLE  #Memory_process;  
IF OBJECT_ID('tempdb..#Memory') IS NOT NULL	DROP TABLE  #Memory;  
IF OBJECT_ID('tempdb..#perfmon_counters') IS NOT NULL	DROP TABLE  #perfmon_counters;  
IF OBJECT_ID('tempdb..#PerfCntr_Data') IS NOT NULL	DROP TABLE  #PerfCntr_Data;  
IF OBJECT_ID('tempdb..#Backup_Report') IS NOT NULL	DROP TABLE  #Backup_Report;  
IF OBJECT_ID('tempdb..#ConnInfo') IS NOT NULL	DROP TABLE  #ConnInfo;  
IF OBJECT_ID('tempdb..#JobInfo') IS NOT NULL	DROP TABLE  #JobInfo;  
IF OBJECT_ID('tempdb..#tempdbfileusage') IS NOT NULL	DROP TABLE  #tempdbfileusage;  
IF OBJECT_ID('tempdb..#LogSpace') IS NOT NULL	DROP TABLE  #LogSpace;  
IF OBJECT_ID('tempdb..#OpenTran_Detail') IS NOT NULL	DROP TABLE  #OpenTran_Detail;  
IF OBJECT_ID('tempdb..#Tab') IS NOT NULL	DROP TABLE  #Tab;  
IF OBJECT_ID('tempdb..#ErrorLogInfo_all') IS NOT NULL	DROP TABLE  #ErrorLogInfo_all;  
IF OBJECT_ID('tempdb..#Table_Counts') IS NOT NULL	DROP TABLE  #Table_Counts;  
IF OBJECT_ID('tempdb..#IdxFrag_Detail') IS NOT NULL	DROP TABLE  #IdxFrag_Detail;  
  
  
/*************************************************************/  
/****************** Server Reboot Details ********************/  
/*************************************************************/  
  
CREATE TABLE #RebootDetails                                
(                                
 LastRecycle datetime,                                
 CurrentDate datetime,                                
 UpTimeInDays varchar(100)                          
)                        
Insert into #RebootDetails          
SELECT sqlserver_start_time 'Last Recycle',GetDate() 'Current Date', DATEDIFF(DD, sqlserver_start_time,GETDATE())'Up Time in Days'  
FROM sys.dm_os_sys_info;  
  
/*************************************************************/  
/****************** Current Blocking Details *****************/  
/*************************************************************/  
CREATE TABLE #BlkProcesses                                
(                                
 spid  varchar(5),                                
 Blkspid  varchar(5),                                
 PrgName  varchar(100),          
 LoginName varchar(100),                                
 ObjName  varchar(100),                                
 Query  varchar(255)                                 
)    
insert into #BlkProcesses  
SELECT s.spid, BlockingSPID = s.blocked, substring(s.program_name,1,99), SUBSTRING(s.loginame,1,99),           
   ObjectName = substring( OBJECT_NAME(objectid, s.dbid),1,99), Definition = CAST(text AS VARCHAR(255))          
FROM  sys.sysprocesses s          
CROSS APPLY sys.dm_exec_sql_text (sql_handle)          
WHERE        s.spid > 50  AND s.blocked > 0   
  
  
/*************************************************************/  
/****************** Errors audit for last 4 Days *************/  
/*************************************************************/  
  
CREATE TABLE #ErrorLogInfo_all                                
(                                
 LogDate  datetime,  
 processinfo varchar(200),                                
 LogInfo  varchar(1000)                                 
)

CREATE TABLE #ErrorLogInfo                                
(                                
 ID INT IDENTITY PRIMARY KEY NOT NULL,
 LogDate  varchar(100),  
 LogInfo  varchar(2000)                                 
)

DECLARE @A VARCHAR(10), @B VARCHAR(10);
SELECT @A = CONVERT(VARCHAR(20),GETDATE()-1,112);
SELECT @B = CONVERT(VARCHAR(20),GETDATE()+1,112);
INSERT INTO #ErrorLogInfo_all
EXEC XP_READERRORLOG 0, 1,N'Login', N'Failed', @A,@B,'DESC';

INSERT INTO #ErrorLogInfo (LogDate,LogInfo)
select DISTINCT CONVERT(VARCHAR(20),GETDATE()+1,111) "LogDate",LogInfo  from #ErrorLogInfo_all;

  
/***********************************************************/  
/************* Windows Disk Space Details ******************/  
/***********************************************************/  

CREATE TABLE #FreeSpace (DName CHAR(1), Free_MB BIGINT, Free_GB DECIMAL(16,2))
INSERT INTO #FreeSpace (DName,Free_MB) EXEC XP_FIXEDDRIVES;
UPDATE #FreeSpace SET Free_GB = CAST(Free_MB / 1024.00 AS DECIMAL(16,2));  
  
/*************************************************************/  
/************* SQL Server CPU Usage Details ******************/  
/*************************************************************/  
Create table #CPU(               
servername varchar(100),                           
EventTime2 datetime,                            
SQLProcessUtilization varchar(50),                           
SystemIdle varchar(50),  
OtherProcessUtilization varchar(50),  
load_date datetime                            
)      
DECLARE @ts BIGINT;  DECLARE @lastNmin TINYINT;  
SET @lastNmin = 240;  
SELECT @ts =(SELECT cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info);   
insert into #CPU  
SELECT TOP 10 * FROM (  
SELECT TOP(@lastNmin)  
  @ServerName AS 'ServerName',  
  DATEADD(ms,-1 *(@ts - [timestamp]),GETDATE())AS [Event_Time],   
  SQLProcessUtilization AS [SQLServer_CPU_Utilization],   
  SystemIdle AS [System_Idle_Process],   
  100 - SystemIdle - SQLProcessUtilization AS [Other_Process_CPU_Utilization],  
  GETDATE() AS 'LoadDate'  
FROM (SELECT record.value('(./Record/@id)[1]','int')AS record_id,   
record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]','int')AS [SystemIdle],   
record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]','int')AS [SQLProcessUtilization],   
[timestamp]        
FROM (SELECT[timestamp], convert(xml, record) AS [record]               
FROM sys.dm_os_ring_buffers               
WHERE ring_buffer_type =N'RING_BUFFER_SCHEDULER_MONITOR'AND record LIKE'%%')AS x )AS y   
ORDER BY SystemIdle ASC) d  
  
/*************************************************************/  
/************* SQL Server Memory Usage Details ***************/  
/*************************************************************/  
  
CREATE TABLE #Memory_BPool (  
BPool_Committed_MB VARCHAR(50),  
BPool_Commit_Tgt_MB VARCHAR(50),  
BPool_Visible_MB VARCHAR(50));  

/****  
  
-- SQL server 2008 / 2008 R2  
INSERT INTO #Memory_BPool    
SELECT  
     (bpool_committed*8)/1024.0 as BPool_Committed_MB,  
     (bpool_commit_target*8)/1024.0 as BPool_Commit_Tgt_MB,  
     (bpool_visible*8)/1024.0 as BPool_Visible_MB  
FROM sys.dm_os_sys_info;  
****/  

-- SQL server 2012 / 2014 / 2016  
INSERT INTO #Memory_BPool   
SELECT  
      (committed_kb)/1024.0 as BPool_Committed_MB,  
      (committed_target_kb)/1024.0 as BPool_Commit_Tgt_MB,  
      (visible_target_kb)/1024.0 as BPool_Visible_MB  
FROM  sys.dm_os_sys_info;  

CREATE TABLE #Memory_sys (  
total_physical_memory_mb VARCHAR(50),  
available_physical_memory_mb VARCHAR(50),  
total_page_file_mb VARCHAR(50),  
available_page_file_mb VARCHAR(50),  
Percentage_Used VARCHAR(50),  
system_memory_state_desc VARCHAR(50));  
  
INSERT INTO #Memory_sys  
select  
      total_physical_memory_kb/1024 AS total_physical_memory_mb,  
      available_physical_memory_kb/1024 AS available_physical_memory_mb,  
      total_page_file_kb/1024 AS total_page_file_mb,  
      available_page_file_kb/1024 AS available_page_file_mb,  
      100 - (100 * CAST(available_physical_memory_kb AS DECIMAL(18,3))/CAST(total_physical_memory_kb AS DECIMAL(18,3)))   
      AS 'Percentage_Used',  
      system_memory_state_desc  
from  sys.dm_os_sys_memory;  
  
  
CREATE TABLE #Memory_process(  
physical_memory_in_use_GB VARCHAR(50),  
locked_page_allocations_GB VARCHAR(50),  
virtual_address_space_committed_GB VARCHAR(50),  
available_commit_limit_GB VARCHAR(50),  
page_fault_count VARCHAR(50))  
  
INSERT INTO #Memory_process  
select  
      physical_memory_in_use_kb/1048576.0 AS 'Physical_Memory_In_Use(GB)',  
      locked_page_allocations_kb/1048576.0 AS 'Locked_Page_Allocations(GB)',  
      virtual_address_space_committed_kb/1048576.0 AS 'Virtual_Address_Space_Committed(GB)',  
      available_commit_limit_kb/1048576.0 AS 'Available_Commit_Limit(GB)',  
      page_fault_count as 'Page_Fault_Count'  
from  sys.dm_os_process_memory;  
  
  
CREATE TABLE #Memory(  
ID INT IDENTITY NOT NULL,
Parameter VARCHAR(200),  
Value VARCHAR(100));  
  
INSERT INTO #Memory   
SELECT 'BPool_Committed_MB',BPool_Committed_MB FROM #Memory_BPool  
UNION  
SELECT 'BPool_Commit_Tgt_MB', BPool_Commit_Tgt_MB FROM #Memory_BPool  
UNION   
SELECT 'BPool_Visible_MB', BPool_Visible_MB FROM #Memory_BPool  
UNION  
SELECT 'Total_Physical_Memory_MB',total_physical_memory_mb FROM #Memory_sys  
UNION  
SELECT 'Available_Physical_Memory_MB',available_physical_memory_mb FROM #Memory_sys
UNION  
SELECT 'Percentage_Used',Percentage_Used FROM #Memory_sys  
UNION
SELECT 'System_memory_state_desc',system_memory_state_desc FROM #Memory_sys  
UNION  
SELECT 'Total_page_file_mb',total_page_file_mb FROM #Memory_sys  
UNION  
SELECT 'Available_page_file_mb',available_page_file_mb FROM #Memory_sys  
UNION  
SELECT 'Physical_memory_in_use_GB',physical_memory_in_use_GB FROM #Memory_process  
UNION  
SELECT 'Locked_page_allocations_GB',locked_page_allocations_GB FROM #Memory_process  
UNION  
SELECT 'Virtual_Address_Space_Committed_GB',virtual_address_space_committed_GB FROM #Memory_process  
UNION  
SELECT 'Available_Commit_Limit_GB',available_commit_limit_GB FROM #Memory_process  
UNION  
SELECT 'Page_Fault_Count',page_fault_count FROM #Memory_process;  
  
  
/******************************************************************/  
/*************** Performance Counter Details **********************/  
/******************************************************************/  
  
CREATE TABLE #PerfCntr_Data(
ID INT IDENTITY NOT NULL,
Parameter VARCHAR(300),  
Value VARCHAR(100));  
  
-- Get size of SQL Server Page in bytes  
DECLARE @pg_size INT, @Instancename varchar(50)  
SELECT @pg_size = low from master..spt_values where number = 1 and type = 'E'  
  
-- Extract perfmon counters to a temporary table  
IF OBJECT_ID('tempdb..#perfmon_counters') is not null DROP TABLE #perfmon_counters  
SELECT * INTO #perfmon_counters FROM sys.dm_os_performance_counters;  
  
-- Get SQL Server instance name as it require for capturing Buffer Cache hit Ratio  
SELECT  @Instancename = LEFT([object_name], (CHARINDEX(':',[object_name])))   
FROM    #perfmon_counters   
WHERE   counter_name = 'Buffer cache hit ratio';  
  
INSERT INTO #PerfCntr_Data  
SELECT CONVERT(VARCHAR(300),Cntr) AS Parameter, CONVERT(VARCHAR(100),Value) AS Value  
FROM  
(  
SELECT  'Page Life Expectency in seconds' as Cntr,  
        cntr_value  AS Value 
FROM    #perfmon_counters   
WHERE   object_name=@Instancename+'Buffer Manager'   
        and counter_name = 'Page life expectancy'  
UNION ALL  
SELECT  'BufferCache HitRatio'  as Cntr,  
        (a.cntr_value * 1.0 / b.cntr_value) * 100.0  AS Value 
FROM    sys.dm_os_performance_counters a  
        JOIN (SELECT cntr_value,OBJECT_NAME FROM sys.dm_os_performance_counters  
              WHERE counter_name = 'Buffer cache hit ratio base' AND   
                    OBJECT_NAME = @Instancename+'Buffer Manager') b ON   
                    a.OBJECT_NAME = b.OBJECT_NAME WHERE a.counter_name = 'Buffer cache hit ratio'   
                    AND a.OBJECT_NAME = @Instancename+'Buffer Manager'
UNION ALL
SELECT  'Total Server Memory (GB)' as Cntr,  
        (cntr_value/1048576.0) AS Value   
FROM    #perfmon_counters   
WHERE   counter_name = 'Total Server Memory (KB)'  
UNION ALL  
SELECT  'Target Server Memory (GB)',   
        (cntr_value/1048576.0)   
FROM    #perfmon_counters   
WHERE   counter_name = 'Target Server Memory (KB)'  
UNION ALL  
SELECT  'Connection Memory (MB)',   
        (cntr_value/1024.0)   
FROM    #perfmon_counters   
WHERE   counter_name = 'Connection Memory (KB)'  
UNION ALL  
SELECT  'Lock Memory (MB)',   
        (cntr_value/1024.0)   
FROM    #perfmon_counters   
WHERE   counter_name = 'Lock Memory (KB)'  
UNION ALL  
SELECT  'SQL Cache Memory (MB)',   
        (cntr_value/1024.0)   
FROM    #perfmon_counters   
WHERE   counter_name = 'SQL Cache Memory (KB)'  
UNION ALL  
SELECT  'Optimizer Memory (MB)',   
        (cntr_value/1024.0)   
FROM    #perfmon_counters   
WHERE   counter_name = 'Optimizer Memory (KB) '  
UNION ALL  
SELECT  'Granted Workspace Memory (MB)',   
        (cntr_value/1024.0)   
FROM    #perfmon_counters   
WHERE   counter_name = 'Granted Workspace Memory (KB) '  
UNION ALL  
SELECT  'Cursor memory usage (MB)',   
        (cntr_value/1024.0)   
FROM    #perfmon_counters   
WHERE   counter_name = 'Cursor memory usage' and instance_name = '_Total'  
UNION ALL  
SELECT  'Total pages Size (MB)',   
        (cntr_value*@pg_size)/1048576.0   
FROM    #perfmon_counters   
WHERE   object_name= @Instancename+'Buffer Manager'   
        and counter_name = 'Total pages'  
UNION ALL  
SELECT  'Database pages (MB)',   
        (cntr_value*@pg_size)/1048576.0   
FROM    #perfmon_counters   
WHERE   object_name = @Instancename+'Buffer Manager' and counter_name = 'Database pages'  
UNION ALL  
SELECT  'Free pages (MB)',   
        (cntr_value*@pg_size)/1048576.0   
FROM    #perfmon_counters   
WHERE   object_name = @Instancename+'Buffer Manager'   
        and counter_name = 'Free pages'  
UNION ALL  
SELECT  'Reserved pages (MB)',   
        (cntr_value*@pg_size)/1048576.0   
FROM    #perfmon_counters   
WHERE   object_name=@Instancename+'Buffer Manager'   
        and counter_name = 'Reserved pages'  
UNION ALL  
SELECT  'Stolen pages (MB)',   
        (cntr_value*@pg_size)/1048576.0   
FROM    #perfmon_counters   
WHERE   object_name=@Instancename+'Buffer Manager'   
        and counter_name = 'Stolen pages'  
UNION ALL  
SELECT  'Cache Pages (MB)',   
        (cntr_value*@pg_size)/1048576.0   
FROM    #perfmon_counters   
WHERE   object_name=@Instancename+'Plan Cache'   
        and counter_name = 'Cache Pages' and instance_name = '_Total'  
UNION ALL  
SELECT  'Free list stalls/sec',  
        cntr_value   
FROM    #perfmon_counters   
WHERE   object_name=@Instancename+'Buffer Manager'   
        and counter_name = 'Free list stalls/sec'  
UNION ALL  
SELECT  'Checkpoint pages/sec',  
        cntr_value   
FROM    #perfmon_counters   
WHERE   object_name=@Instancename+'Buffer Manager'   
        and counter_name = 'Checkpoint pages/sec'  
UNION ALL  
SELECT  'Lazy writes/sec',  
        cntr_value   
FROM    #perfmon_counters   
WHERE   object_name=@Instancename+'Buffer Manager'   
        and counter_name = 'Lazy writes/sec'  
UNION ALL  
SELECT  'Memory Grants Pending',  
        cntr_value   
FROM    #perfmon_counters   
WHERE   object_name=@Instancename+'Memory Manager'   
        and counter_name = 'Memory Grants Pending'  
UNION ALL  
SELECT  'Memory Grants Outstanding',  
        cntr_value   
FROM    #perfmon_counters   
WHERE   object_name=@Instancename+'Memory Manager'   
        and counter_name = 'Memory Grants Outstanding'  
UNION ALL  
SELECT  'Process_Physical_Memory_Low',  
        process_physical_memory_low   
FROM    sys.dm_os_process_memory WITH (NOLOCK)  
UNION ALL  
SELECT  'Process_Virtual_Memory_Low',  
        process_virtual_memory_low   
FROM    sys.dm_os_process_memory WITH (NOLOCK)  
UNION ALL  
SELECT  'Max_Server_Memory (MB)' ,  
        [value_in_use]   
FROM    sys.configurations   
WHERE   [name] = 'max server memory (MB)'  
UNION ALL  
SELECT  'Min_Server_Memory (MB)' ,  
        [value_in_use]   
FROM    sys.configurations   
WHERE   [name] = 'min server memory (MB)') AS P;  
  
  
  
/******************************************************************/  
/*************** Database Backup Report ***************************/  
/******************************************************************/  
  
CREATE TABLE #Backup_Report(  
Database_Name VARCHAR(300),  
Last_Backup_Date VARCHAR(50));  
  
INSERT INTO #Backup_Report  
--Databases with data backup over 48 hours old   
SELECT Database_Name, last_db_backup_date AS Last_Backup_Date FROM (  
SELECT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server,   
  msdb.dbo.backupset.database_name,   
  MAX(msdb.dbo.backupset.backup_finish_date) AS last_db_backup_date,   
  DATEDIFF(hh, MAX(msdb.dbo.backupset.backup_finish_date), GETDATE()) AS [Backup Age (Hours)]   
FROM msdb.dbo.backupset   
WHERE   msdb.dbo.backupset.type = 'D'    
GROUP BY msdb.dbo.backupset.database_name   
HAVING (MAX(msdb.dbo.backupset.backup_finish_date) < DATEADD(DD, -7, GETDATE()))    
UNION    
--Databases without any backup history   
SELECT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server,    
  sd.NAME AS database_name,    
  NULL AS [Last Data Backup Date],    
  9999 AS [Backup Age (Hours)]    
FROM master.dbo.sysdatabases sd   
  LEFT JOIN msdb.dbo.backupset bs  
  ON sd.name  = bs.database_name   
WHERE bs.database_name IS NULL AND sd.name <> 'tempdb' ) AS B   
ORDER BY Database_Name;   
  
  
  
       
/*************************************************************/  
/****************** Connection Details ***********************/  
/*************************************************************/  
  
-- Number of connection on the instance grouped by hostnames  
Create table #ConnInfo(               
Hostname varchar(100),                           
NumberOfconn varchar(10)                          
)    
insert into #ConnInfo  
SELECT  Case when len(hostname)=0 Then 'Internal Process' Else hostname END,count(*)NumberOfconnections   
FROM sys.sysprocesses  
GROUP BY hostname  
  
  
/*************************************************************/  
/************** Currently Running Jobs Info ******************/  
/*************************************************************/  
Create table #JobInfo(               
spid varchar(10),                           
lastwaittype varchar(100),                           
dbname varchar(100),                           
login_time varchar(100),                           
status varchar(100),                           
opentran varchar(100),                           
hostname varchar(100),                          
JobName varchar(100),                          
command nvarchar(2000),  
domain varchar(100),   
loginname varchar(100)     
)   
insert into #JobInfo  
SELECT  distinct p.spid,p.lastwaittype,DB_NAME(p.dbid),p.login_time,p.status,p.open_tran,p.hostname,J.name,  
p.cmd,p.nt_domain,p.loginame  
FROM master..sysprocesses p  
INNER JOIN msdb..sysjobs j ON   
substring(left(j.job_id,8),7,2) + substring(left(j.job_id,8),5,2) + substring(left(j.job_id,8),3,2) + substring(left(j.job_id,8),1,2) = substring(p.program_name, 32, 8)   
Inner join msdb..sysjobactivity sj on j.job_id=sj.job_id  
WHERE program_name like'SQLAgent - TSQL JobStep (Job %' and sj.stop_execution_date is null  
  
/*************************************************************/  
/****************** Tempdb File Info *************************/  
/*************************************************************/  
-- tempdb file usage  
Create table #tempdbfileusage(               
servername varchar(100),                           
databasename varchar(100),                           
filename varchar(100),                           
physicalName varchar(100),                           
filesizeMB varchar(100),                           
availableSpaceMB varchar(100),                           
percentfull varchar(100)   
)   
  
DECLARE @TEMPDBSQL NVARCHAR(4000);  
SET @TEMPDBSQL = ' USE Tempdb;  
SELECT  CONVERT(VARCHAR(100), @@SERVERNAME) AS [server_name]  
                ,db.name AS [database_name]  
                ,mf.[name] AS [file_logical_name]  
                ,mf.[filename] AS[file_physical_name]  
                ,convert(FLOAT, mf.[size]/128) AS [file_size_mb]               
                ,convert(FLOAT, (mf.[size]/128 - (CAST(FILEPROPERTY(mf.[name], ''SpaceUsed'') AS int)/128))) as [available_space_mb]  
                ,convert(DECIMAL(38,2), (CAST(FILEPROPERTY(mf.[name], ''SpaceUsed'') AS int)/128.0)/(mf.[size]/128.0))*100 as [percent_full]      
FROM   tempdb.dbo.sysfiles mf  
JOIN      master..sysdatabases db  
ON         db.dbid = db_id()';  
--PRINT @TEMPDBSQL;  
insert into #tempdbfileusage  
EXEC SP_EXECUTESQL @TEMPDBSQL;  
  
  
/*************************************************************/  
/****************** Database Log Usage ***********************/  
/*************************************************************/  
CREATE TABLE #LogSpace(  
DBName VARCHAR(100),  
LogSize VARCHAR(50),  
LogSpaceUsed_Percent VARCHAR(100),   
LStatus CHAR(1));  
  
INSERT INTO #LogSpace  
EXEC ('DBCC SQLPERF(LOGSPACE) WITH NO_INFOMSGS;');  
  
/********************************************************************/  
/****************** Long Running Transactions ***********************/  
/********************************************************************/  
  
CREATE TABLE #OpenTran_Detail(  
 [SPID] [varchar](20) NULL,  
 [TranID] [varchar](50) NULL,  
 [User_Tran] [varchar](5) NOT NULL,  
 [DBName] [nvarchar](250) NULL,  
 [Login_Time] [varchar](60) NULL,  
 [Duration] [varchar](20) NULL,  
 [Last_Batch] [varchar](200) NULL,  
 [Status] [nvarchar](50) NULL,  
 [LoginName] [nvarchar](250) NULL,  
 [HostName] [nvarchar](250) NULL,  
 [ProgramName] [nvarchar](250) NULL,  
 [CMD] [nvarchar](50) NULL,  
 [SQL] [nvarchar](max) NULL,  
 [Blocked] [varchar](6) NULL  
);  
  
  
  
;WITH OpenTRAN AS  
(SELECT session_id,transaction_id,is_user_transaction   
FROM sys.dm_tran_session_transactions)   
INSERT INTO #OpenTran_Detail  
SELECT        
 LTRIM(RTRIM(OT.session_id)) AS 'SPID',  
 LTRIM(RTRIM(OT.transaction_id)) AS 'TranID',  
 CASE WHEN OT.is_user_transaction = '1' THEN 'Yes' ELSE 'No' END AS 'User_Tran',  
    db_name(LTRIM(RTRIM(s.dbid)))DBName,  
    LTRIM(RTRIM(login_time)) AS 'Login_Time',   
 DATEDIFF(MINUTE,login_time,GETDATE()) AS 'Duration',  
 LTRIM(RTRIM(last_batch)) AS 'Last_Batch',  
    LTRIM(RTRIM(status)) AS 'Status',  
 LTRIM(RTRIM(loginame)) AS 'LoginName',   
    LTRIM(RTRIM(hostname)) AS 'HostName',   
    LTRIM(RTRIM(program_name)) AS 'ProgramName',  
    LTRIM(RTRIM(cmd)) AS 'CMD',  
 LTRIM(RTRIM(a.text)) AS 'SQL',  
    LTRIM(RTRIM(blocked)) AS 'Blocked'  
FROM sys.sysprocesses AS s  
CROSS APPLY sys.dm_exec_sql_text(s.sql_handle)a  
INNER JOIN OpenTRAN AS OT ON OT.session_id = s.spid   
WHERE s.spid <> @@spid AND s.dbid>4;  



/********************************************************************/  
/****************** Top 20 Tables ***********************/  
/********************************************************************/  
  
	CREATE TABLE #Tab (
			[Name]		 NVARCHAR(128),    
			[Rows]		 CHAR(11),    
			[Reserved]	 VARCHAR(18),  
			[Data]		 VARCHAR(18),     
			[Index_size] VARCHAR(18),    
			[Unused]	 VARCHAR(18)); 

	CREATE TABLE #Table_Counts (
			ID			 INT IDENTITY NOT NULL PRIMARY KEY,
			[Table_Name]	 NVARCHAR(128),    
			[Row_Count]		 VARCHAR(100),    
			[TotalSize(MB)]	 VARCHAR(18),
			[TotalSize(GB)]	 VARCHAR(18),
			[Data(MB)]		 VARCHAR(18),     
			[Index_Size(MB)] VARCHAR(18), 
			[UnUsed(MB)]	 VARCHAR(18)); 


	--Capture all tables data allocation information 
	INSERT #Tab 
	EXEC sp_msForEachTable 'EXEC sp_spaceused ''?''' ;

	--Alter Rows column datatype to BIGINT to get the result in sorted order
	ALTER TABLE #Tab ALTER COLUMN [ROWS] BIGINT  ;

	-- Get the final result: Remove KB and convert it into MB
	INSERT INTO #Table_Counts ([Table_Name],[Row_Count],[TotalSize(MB)],[TotalSize(GB)],[Data(MB)],[Index_Size(MB)],[UnUsed(MB)])
	SELECT	TOP 20
	     Name,
		[Rows],
		CAST(CAST(LTRIM(RTRIM(REPLACE(Reserved,'KB',''))) AS BIGINT)/1024.0 AS DECIMAL(18,2)) AS 'TotalSize MB',
		CAST(CAST(LTRIM(RTRIM(REPLACE(Reserved,'KB',''))) AS BIGINT)/(1024.0*1024.0) AS DECIMAL(18,2)) AS 'TotalSize GB',
		CAST(CAST(LTRIM(RTRIM(REPLACE(Data,'KB',''))) AS BIGINT)/1024.0 AS DECIMAL(18,2)) AS 'Data MB',
		CAST(CAST(LTRIM(RTRIM(REPLACE(Index_Size,'KB',''))) AS BIGINT)/1024.0 AS DECIMAL(18,2)) AS 'Index_Size MB',
		CAST(CAST(LTRIM(RTRIM(REPLACE(Unused,'KB',''))) AS BIGINT)/1024.0 AS DECIMAL(18,2)) AS 'Unused MB'
	FROM #Tab 
	ORDER BY CAST(CAST(LTRIM(RTRIM(REPLACE(Reserved,'KB',''))) AS BIGINT)/1024.0 AS DECIMAL(18,2)) DESC;



/********************************************************************/  
/****************** Index Fragmentation Details ***********************/  
/********************************************************************/  
  
CREATE TABLE #IdxFrag_Detail(  
ID INT IDENTITY PRIMARY KEY NOT NULL,
[SCHEMA]   NVARCHAR(250),
[TABLE]	   NVARCHAR(250),
[INDEX]    NVARCHAR(250),
[FRAGMENTATION] NVARCHAR(250),
[PAGE_COUNT] NVARCHAR(500), 
[STATUS] NVARCHAR(250));

INSERT INTO #IdxFrag_Detail ([SCHEMA],[TABLE],[INDEX],[FRAGMENTATION],[PAGE_COUNT],[STATUS])
SELECT	TOP 50
		object_schema_name(ips.object_id)	AS 'Schema_Name',
		object_name (ips.object_id)		AS 'Object_Name',
		i.name					AS 'Index_Name',
		ips.avg_fragmentation_in_percent	AS 'Avg_Fragmentation%',
		ips.page_count				AS 'Page_Count',
		CASE	WHEN (ips.avg_fragmentation_in_percent BETWEEN 5 AND 30) AND ips.page_count > 1000
			THEN 'Reorganize'
		WHEN ips.avg_fragmentation_in_percent > 30 AND ips.page_count > 1000 
			THEN 'Rebuild'
		ELSE	     'Healthy'
		END AS 'Index_Status'
FROM	sys.dm_db_index_physical_stats(db_id(), null, null, null, null) ips
INNER JOIN sys.indexes i ON i.object_id = ips.object_id 
		   AND i.index_id = ips.index_id
WHERE	ips.index_id > 0
ORDER BY avg_fragmentation_in_percent DESC;

------------

SELECT 'RebootDetails' AS DSName, * FROM #RebootDetails  
SELECT 'FreeSpace' AS DSName, * FROM #FreeSpace;
SELECT 'BlkProcesses' AS DSName, * FROM #BlkProcesses  
SELECT 'ErrorLogInfo' AS DSName, * FROM #ErrorLogInfo  
SELECT 'CPU' AS DSName, * FROM #CPU  
SELECT 'Memory_BPool' AS DSName, * FROM #Memory_BPool;  
SELECT 'Memory_sys' AS DSName, * FROM #Memory_sys;  
SELECT 'Memory_process' AS DSName, * FROM #Memory_process;  
SELECT 'Memory' AS DSName, * FROM #Memory;  
SELECT 'perfmon_counters' AS DSName, * FROM #perfmon_counters;  
SELECT 'PerfCntr_Data' AS DSName, * FROM #PerfCntr_Data;  
SELECT 'Backup_Report' AS DSName, * FROM #Backup_Report;  
SELECT 'ConnInfo' AS DSName, * FROM #ConnInfo;  
SELECT 'JobInfo' AS DSName, * FROM #JobInfo;  
SELECT 'tempdbfileusage' AS DSName, * FROM #tempdbfileusage;  
SELECT 'LogSpace' AS DSName, * FROM #LogSpace;  
SELECT 'OpenTranDetail' AS DSName, * FROM #OpenTran_Detail;  


------------
  

IF OBJECT_ID('tempdb..#RebootDetails') IS NOT NULL	DROP TABLE  #RebootDetails;  
IF OBJECT_ID('tempdb..#FreeSpace') IS NOT NULL	DROP TABLE	#FreeSpace;
IF OBJECT_ID('tempdb..#BlkProcesses') IS NOT NULL	DROP TABLE  #BlkProcesses  
IF OBJECT_ID('tempdb..#ErrorLogInfo') IS NOT NULL	DROP TABLE  #ErrorLogInfo  
IF OBJECT_ID('tempdb..#CPU') IS NOT NULL	DROP TABLE  #CPU  
IF OBJECT_ID('tempdb..#Memory_BPool') IS NOT NULL	DROP TABLE  #Memory_BPool;  
IF OBJECT_ID('tempdb..#Memory_sys') IS NOT NULL	DROP TABLE  #Memory_sys;  
IF OBJECT_ID('tempdb..#Memory_process') IS NOT NULL	DROP TABLE  #Memory_process;  
IF OBJECT_ID('tempdb..#Memory') IS NOT NULL	DROP TABLE  #Memory;  
IF OBJECT_ID('tempdb..#perfmon_counters') IS NOT NULL	DROP TABLE  #perfmon_counters;  
IF OBJECT_ID('tempdb..#PerfCntr_Data') IS NOT NULL	DROP TABLE  #PerfCntr_Data;  
IF OBJECT_ID('tempdb..#Backup_Report') IS NOT NULL	DROP TABLE  #Backup_Report;  
IF OBJECT_ID('tempdb..#ConnInfo') IS NOT NULL	DROP TABLE  #ConnInfo;  
IF OBJECT_ID('tempdb..#JobInfo') IS NOT NULL	DROP TABLE  #JobInfo;  
IF OBJECT_ID('tempdb..#tempdbfileusage') IS NOT NULL	DROP TABLE  #tempdbfileusage;  
IF OBJECT_ID('tempdb..#LogSpace') IS NOT NULL	DROP TABLE  #LogSpace;  
IF OBJECT_ID('tempdb..#OpenTran_Detail') IS NOT NULL	DROP TABLE  #OpenTran_Detail;  
IF OBJECT_ID('tempdb..#Tab') IS NOT NULL	DROP TABLE  #Tab;  
IF OBJECT_ID('tempdb..#ErrorLogInfo_all') IS NOT NULL	DROP TABLE  #ErrorLogInfo_all;  
IF OBJECT_ID('tempdb..#Table_Counts') IS NOT NULL	DROP TABLE  #Table_Counts;  
IF OBJECT_ID('tempdb..#IdxFrag_Detail') IS NOT NULL	DROP TABLE  #IdxFrag_Detail;  
  
  
SET NOCOUNT OFF;  
SET ARITHABORT OFF;  

GO


  
  