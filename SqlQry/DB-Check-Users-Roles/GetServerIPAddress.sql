/*
Get Server IP Address / Port Number / Server Name
*/


SELECT  SERVERPROPERTY('ComputerNamePhysicalNetBios')  as 'Is_Current_Owner'
	,SERVERPROPERTY('MachineName')  as 'MachineName'
	,case when @@ServiceName = 	Right (@@Servername,len(@@ServiceName)) 
		then @@Servername 
		else @@servername +' \ ' + @@Servicename
	end as '@@Servername \ Servicename',  
	CONNECTIONPROPERTY('net_transport') AS net_transport,
	CONNECTIONPROPERTY('local_tcp_port') AS local_tcp_port,
	dec.local_tcp_port,
	CONNECTIONPROPERTY('local_net_address') AS local_net_address,
	dec.local_net_address as 'dec.local_net_address'
FROM sys.dm_exec_connections AS dec
WHERE dec.session_id = @@SPID;

