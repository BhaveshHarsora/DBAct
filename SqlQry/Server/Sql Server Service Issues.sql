use master
GO

/*
When data is not Syncing in HA
Check is there any open tran 
	if so, kill it 
*/

dbcc opentran()
/*
Transaction information for database 'master'.

Oldest active transaction:
    SPID (server process ID): 461s
    UID (user ID) : -1
    Name          : HaDrDbMgrDbLock
    LSN           : (13265:176:10)
    Start time    : Aug 27 2021  3:53:21:940AM
    SID           : 0x0
DBCC execution completed. If DBCC printed error messages, contact your system administrator.

*/

/*
When SQL Configuration Manager is not Loading...
	https://thebackroomtech.com/2009/12/02/fix-sql-configuration-manager-connection-to-target-machine-could-not-be-made-in-a-timely-fashion/

	services.msc
		restart > Windows Management Instrumentation (WMI)
*/

/*

When SQL Services is in "Change Pending" state
use below TSQL - which will terminate serices aburptuly
-- SHUTDOWN WITH NOWAIT
*/

DBCC INPUTBUFFER (66) 

SELECT spid
	, kpid
	, login_time
	, last_batch
	, status
	, hostname
	, nt_username
	, loginame
	, hostprocess
	, cpu
	, memusage
	, physical_io
FROM sys.sysprocesses
WHERE cmd = 'KILLED/ROLLBACK'
