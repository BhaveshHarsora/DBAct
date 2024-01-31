USE [master]
GO

/****** Object:  DdlTrigger [tr_MScdc_db_ddl_event]    Script Date: 17/01/2023 5:05:57 PM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

create trigger [tr_MScdc_db_ddl_event] on all server for ALTER_DATABASE, DROP_DATABASE
		             as 
					set ANSI_NULLS ON
					set ANSI_PADDING ON
					set ANSI_WARNINGS ON
					set ARITHABORT ON
					set CONCAT_NULL_YIELDS_NULL ON
					set NUMERIC_ROUNDABORT OFF
					set QUOTED_IDENTIFIER ON

					declare @EventData xml, @retcode int
					set @EventData=EventData()  
					if object_id('sys.sp_MScdc_db_ddl_event' ) is not null
					begin 
						exec @retcode = sys.sp_MScdc_db_ddl_event @EventData
						if @@error <> 0 or @retcode <> 0 
						begin
							rollback tran
						end
					end		 
GO

ENABLE TRIGGER [tr_MScdc_db_ddl_event] ON ALL SERVER
GO


