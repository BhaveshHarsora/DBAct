/*
Queries to find Open transactions
*/

DBCC OPENTRAN 

SELECT * 
FROM sys.sysprocesses 
WHERE open_tran = 1


SELECT db_id(), * 
FROM sys.dm_tran_active_transactions tat 	
INNER JOIN sys.dm_exec_requests er 
	ON tat.transaction_id = er.transaction_id
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle)

SELECT * 
FROM sys.dm_tran_session_transactions tst 
INNER JOIN sys.dm_exec_connections ec 
	ON tst.session_id = ec.session_id
CROSS APPLY sys.dm_exec_sql_text(ec.most_recent_sql_handle)

