/*
BH20240411 : Sync SQL Login with Database wise SQL User accounts.
This sync is required to avoid Database context issues 
	Error E.g. The server principal "" is not able to access the database "" under the current security context.
	Resolutions:
		[1] Execute below script to sync the Logins with database users 
		[2] Check in database object definition, whether there is any cross database code written, in that case check account permission and 
			may change the code WITH EXECUTE AS [OWNER|CALLER]
*/

-------- Reset SQL user account guids ---------------------
DECLARE @UserName nvarchar(255) 
DECLARE orphanuser_cur cursor for 
      SELECT UserName = su.name 
      FROM sysusers su
      JOIN sys.server_principals sp ON sp.name = su.name
      WHERE issqluser = 1 AND
            (su.sid IS NOT NULL AND su.sid <> 0x0) AND
            suser_sname(su.sid) is null 
      ORDER BY su.name;

OPEN orphanuser_cur; 
FETCH NEXT FROM orphanuser_cur INTO @UserName; 

WHILE (@@fetch_status = 0)
BEGIN 
	PRINT @UserName + ' user name being resynced'; 
	
	EXEC sp_change_users_login 'Update_one', @UserName, @UserName; 
	
	FETCH NEXT FROM orphanuser_cur INTO @UserName;
END 

CLOSE orphanuser_cur; 
DEALLOCATE orphanuser_cur;



