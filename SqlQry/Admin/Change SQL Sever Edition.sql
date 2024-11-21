/*
Date 9 Oct 2019
Change SQL Server Edition 
*/

/* ***********************************************

Refrence: https://www.codykonior.com/2017/11/30/upgrading-an-expired-sql-server-2016-evaluation-edition/

Run CMD in Administration mode and run below command

> sc.exe start MSSQLSERVER -m "SqlSetup" -T4022 -T4010 -T1905 -T3701 -T8015

It will now allow to run SQL Server Installer in safe mode and could change thier Edition

Now, run SQL Server Installer > Maintainance > Upgrade Edition
	Setup configuration as per wizard.
	

Success!	


********************************************** */


sc.exe start MSSQLSERVER -m "SqlSetup" -T4022 -T4010 -T1905 -T3701 -T8015