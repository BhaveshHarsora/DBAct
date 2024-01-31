/*
BH20230201 : T-SQL to GET LIST OF ALL LOGINS
*/
USE master
GO

SELECT sp.name as loginName
	, case sp.type_desc 
		when 'WINDOWS_GROUP' then 'GROUP' 
		when 'WINDOWS_LOGIN' then 'WINDOWS'
		when 'SQL_LOGIN' then 'SQL'		
		else sp.type_desc
	  end as login_type
	, sp.sid	
	, (case when sp.is_disabled = 1 then 'Disabled'
			else 'Enabled' 
		end) as status
FROM master.sys.server_principals AS SP 
LEFT JOIN master.sys.sql_logins AS SL 
	ON SP.principal_id = sl.principal_id
WHERE 1=1
AND sp.type not in ('R') -- 'G', 'R'
AND SP.name NOT LIKE '##%##'
ORDER BY sp.name;
