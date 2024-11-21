/*
Date 20 Jul 2021
Get Server Domain and get data from registry
*/

USE MASTER
GO

-- using system functions
SELECT @@SERVERNAME AS ServerName, DEFAULT_DOMAIN() DomainName

-- 2. Also easy, but calling an xp
EXEC master..xp_loginconfig 'Default Domain'

-- 3. Way overkill, but it works
DECLARE @Domain VARCHAR(100), @key VARCHAR(100)

SET @key = 'system\controlset001\services\tcpip\parameters\'

EXEC master..xp_regread
      @rootkey = 'HKEY_LOCAL_MACHINE',
      @key = @key,
      @value_name = 'Domain',
      @value = @Domain OUTPUT

      SELECT @Domain [DomainName]
