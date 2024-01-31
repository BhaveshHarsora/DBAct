/*
:: Get Backup set informations ::
T-SQL query to get the backup info on SQL 2008+ instances

*/
SELECT	@@SERVERNAME AS Source_Server, 
		bs.database_name, 
		bs.backup_start_date, 
		bs.backup_finish_date,
		CASE bs.type 
			WHEN 'D' THEN 'Full'
			WHEN 'I' THEN 'Differential'
			WHEN 'L' THEN 'Transaction Log' 
		END AS backup_type,		
		bs.backup_size/1000000 AS backup_size_MB, 		
		bs.Compressed_Backup_size/1000000 AS Compressed_Backup_size_MB,
		DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date) AS Duration_Seconds,
		bs.database_creation_date AS database_creation_date,
		bs.recovery_model AS recovery_model,
		bmf.physical_device_name,
		bs.user_name AS user_name
FROM msdb.dbo.BackupMediaFamily AS bmf
INNER JOIN msdb.dbo.BackupSet AS bs
	ON bmf.media_set_id = bs.media_set_id 
WHERE 1=1
--AND bs.database_name IN ('DM_Network', 'DrblMsgDB')
AND (CONVERT(DATETIME, bs.backup_start_date, 102) >= GETDATE() - 7) -- Get backup sets details for Last 7 Days! 
ORDER BY  bs.database_name, bs.backup_finish_date 

/*
*/


SELECT CASE 
		WHEN Source_Server IS NULL AND tt.backup_type = 'Full'
			THEN 'ALL_Full'
		WHEN Source_Server IS NULL AND tt.backup_type = 'Transaction Log'
			THEN 'ALL_Transaction Log'
		WHEN Source_Server IS NULL AND tt.backup_type = 'Differential'
			THEN 'ALL_Differential'
		WHEN Source_Server IS NULL AND tt.backup_type IS NULL
			THEN 'ALL_Full+TransactionLog+Differential'
		ELSE Source_Server
	END AS Source_Server, database_name, backup_start_date, backup_finish_date, 
	
	CASE WHEN Source_Server IS NULL AND ISNULL(tt.backup_type, 'ALL') IN ('Full', 'Transaction Log', 'Differential', 'ALL')
		THEN 'ALL'	
		ELSE backup_type
	END backup_type,
	
	backup_size_MB, Compressed_Backup_size_MB, Duration_Seconds, 
	database_creation_date, recovery_model, physical_device_name, user_name
FROM (
	SELECT	t.Source_Server, t.database_name, t.backup_start_date, t.backup_finish_date, t.backup_type,
			SUM(t.backup_size_MB) AS backup_size_MB, 
			SUM(t.Compressed_Backup_size_MB) AS Compressed_Backup_size_MB, 
			SUM(t.Duration_Seconds) AS Duration_Seconds,
			t.database_creation_date, t.recovery_model, t.physical_device_name, t.user_name
	FROM (
		SELECT	@@SERVERNAME AS Source_Server, 
				bs.database_name, 
				bs.backup_start_date, 
				bs.backup_finish_date,
				CASE bs.type 
					WHEN 'D' THEN 'Full'
					WHEN 'I' THEN 'Differential'
					WHEN 'L' THEN 'Transaction Log' 
				END AS backup_type,		
				bs.backup_size/1000000 AS backup_size_MB, 		
				bs.Compressed_Backup_size/1000000 AS Compressed_Backup_size_MB,
				DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date) AS Duration_Seconds,
				bs.database_creation_date AS database_creation_date,
				bs.recovery_model AS recovery_model,
				bmf.physical_device_name,
				bs.user_name AS user_name
		FROM msdb.dbo.BackupMediaFamily AS bmf
		INNER JOIN msdb.dbo.BackupSet AS bs
			ON bmf.media_set_id = bs.media_set_id 
		WHERE 1=1
		AND bs.database_name IN ('DM_Network', 'DrblMsgDB')
		AND (CONVERT(DATETIME, bs.backup_start_date, 102) >= GETDATE() - 7) -- Get backup sets details for Last 7 Days! 
	) AS t	
	WHERE 1=1
	GROUP BY GROUPING SETS
	(
		(t.Source_Server, t.database_name, t.backup_start_date, t.backup_finish_date,t.backup_type, t.database_creation_date, t.recovery_model, t.physical_device_name, t.user_name), 
		(t.backup_type),
		()
	) 
) AS tt
ORDER BY Source_Server