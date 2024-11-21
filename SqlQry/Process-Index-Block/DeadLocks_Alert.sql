--Enable the traceflag and server configuration  dbcc traceon(1222,-1)  go  sp_configure xp_cmdshell,1 

 RECONFIGURE with override
 go
 -- Create the Base table in dba database.
 USE [dba]
GO

/****** Object:  Table [dbo].[DeadlockEvents]    Script Date: 06/20/2012 12:19:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeadlockEvents]') AND type in (N'U')) BEGIN CREATE TABLE [dbo].[DeadlockEvents](  [Id] [int] IDENTITY(1,1) NOT NULL,  [AlertTime] [datetime2](7) NOT NULL,  [DeadlockGraph] [xml] NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AlertTime]') AND type = 'D') BEGIN ALTER TABLE [dbo].[DeadlockEvents] ADD  CONSTRAINT [DF_AlertTime]  DEFAULT (sysdatetime()) FOR [AlertTime] END

GO
--Create a user defined procedure in master db USE [master] GO

/****** Object:  StoredProcedure [dbo].[usp_getdeadlockinfo]    Script Date: 06/20/2012 12:26:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_getdeadlockinfo]') AND type in (N'P', N'PC')) BEGIN EXEC dbo.sp_executesql @statement = N'CREATE procedure [dbo].[usp_getdeadlockinfo] as begin set nocount on
SELECT TOP 1 [DeadlockGraph].query(''/TextData/deadlock-list'') FROM [DBA].[dbo].[DeadlockEvents] ORDER BY Id DESC   FOR XML RAW, TYPE, ELEMENTS XSINIL 
end' 
END
GO
--Set up the WMI alert for deadlock
USE [msdb]
GO

/****** Object:  Alert [Respond to DEADLOCK_GRAPH]    Script Date: 06/20/2012 12:20:58 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Respond to DEADLOCK_GRAPH') EXEC msdb.dbo.sp_add_alert @name=N'Respond to DEADLOCK_GRAPH',
  @message_id=0,
  @severity=0,
  @enabled=1,
  @delay_between_responses=120,
  @include_event_description_in=1,
  @category_name=N'[Uncategorized]',
  @wmi_namespace=N'\.rootMicrosoftSqlServerServerEventsMSSQLSERVER',
  @wmi_query=N'SELECT * FROM DEADLOCK_GRAPH',
  @job_id=N'5ae39cb7-5e46-495c-aea2-7ab2355f77de'
GO
--Set up a job to respond for the alert
--Inside the job replace the db profile, email recipients

USE [msdb]
GO

/****** Object:  Job [Capture Deadlock Graph]    Script Date: 06/20/2012 12:22:55 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 06/20/2012 12:22:55 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1) BEGIN EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
select @jobId = job_id from msdb.dbo.sysjobs where (name = N'Capture Deadlock Graph') if (@jobId is NULL) BEGIN EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Capture Deadlock Graph',
  @enabled=1,
  @notify_level_eventlog=2,
  @notify_level_email=0,
  @notify_level_netsend=0,
  @notify_level_page=0,
  @delete_level=0,
  @description=N'Job for responding to DEADLOCK_GRAPH events',
  @category_name=N'[Uncategorized (Local)]',
  @owner_login_name=N'sa', @job_id = @jobId OUTPUT IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END
/****** Object:  Step [Insert graph into DeadlockEvents]    Script Date: 06/20/2012 12:22:55 ******/
IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobsteps WHERE job_id = @jobId and step_id = 1) EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Insert graph into DeadlockEvents',
  @step_id=1,
  @cmdexec_success_code=0,
  @on_success_action=3,
  @on_success_step_id=0,
  @on_fail_action=2,
  @on_fail_step_id=0,
  @retry_attempts=0,
  @retry_interval=0,
  @os_run_priority=0, @subsystem=N'TSQL',
  @command=N'INSERT INTO dba..DeadlockEvents(DeadlockGraph)
                VALUES (N''$(ESCAPE_SQUOTE(WMI(TextData)))'')',
  @database_name=N'DBA',
  @flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [create xdl file]    Script Date: 06/20/2012 12:22:55 ******/
IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobsteps WHERE job_id = @jobId and step_id = 2) EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'create xdl file',
  @step_id=2,
  @cmdexec_success_code=0,
  @on_success_action=1,
  @on_success_step_id=0,
  @on_fail_action=2,
  @on_fail_step_id=0,
  @retry_attempts=0,
  @retry_interval=0,
  @os_run_priority=0, @subsystem=N'TSQL',
  @command=N'DECLARE @FileName varchar(50),
        @bcpCommand varchar(2000)

SET @FileName = ''D:dbatempxmlfile.xdl''
--SET @FileName = ''D:dbatempdeadlock ''+rtrim(CONVERT(char(25),GETDATE()))+''.xdl''

SET @bcpCommand = ''bcp "SELECT TOP 1 [DeadlockGraph].query(''''/TextData/deadlock-list'''') FROM [DBA].[dbo].[DeadlockEvents] ORDER BY Id DESC" queryout "''
SET @bcpCommand = @bcpCommand + @FileName + ''" -T -c -q''

EXEC master..xp_cmdshell @bcpCommand

EXEC msdb.dbo.sp_send_dbmail
    --@profile_name = ''profile@xyc.com'',
    @recipients = ''dba@xyc.com;xyz@xyc.com'',
    @query = ''exec master..usp_getdeadlockinfo'',
    @subject = ''Please find the attached Dead Lock Reports'',
    --@body_format = ''HTML'',
    @attach_query_result_as_file = 1, 
    @query_result_header = 0,
    @query_attachment_filename = ''DeadLock.xml'',
    @file_attachments  = ''D:dbatempxmlfile.xdl'',
    @query_no_truncate = 1,
    @query_result_width = 32767,
    @exclude_query_output = 1',
  @database_name=N'master',
  @flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1 IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback COMMIT TRANSACTION GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO
