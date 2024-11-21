
SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101
SELECT * FROM sys.certificates WHERE name = 'rf_user_certi'

select * from sys.databases where is_master_key_encrypted_by_server=1

DECLARE @error_message VARCHAR(MAX)
EXEC usp_DOR_GET_USER_AUTHENTICATE @username = 'superadmin', @password='superadmin', @error_message = @error_message OUTPUT
SELECT @error_message, * FROM RF_DWH_USERS


/*** RESOLUTION ***/
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'G00df00d!1'
ALTER MASTER KEY ADD ENCRYPTION BY SERVICE MASTER KEY
CLOSE MASTER KEY
/********************************************************/

OPEN SYMMETRIC KEY rf_user_symm_key
DECRYPTION BY CERTIFICATE rf_user_certi 

SELECT	*
FROM dbo.RF_DWH_USERS AS a
WHERE user_nm = 'superadmin' COLLATE SQL_Latin1_General_CP1_CI_AS
AND CONVERT(VARCHAR(1000), DecryptByKey([password])) = 'superadmin'
and deleted_by is null;

