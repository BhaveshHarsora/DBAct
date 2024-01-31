/*
BH20230201 : Backup Info
*/
--> Last Backup Info
SELECT TOP 100
	 d.name AS DatabaseName
	 , d.recovery_model_desc AS RecoveryModel
	 , (SELECT TOP 1 x.backup_start_date 
		FROM msdb..backupset AS x 
		INNER JOIN msdb..backupmediafamily y 
			ON x.media_set_id = y.media_set_id
		WHERE x.database_name = d.name
		AND x.recovery_model = d.recovery_model_desc COLLATE DATABASE_DEFAULT
		AND x.[type] = 'D'
		ORDER BY x.backup_start_date DESC) AS BackupStartDate
	
	, (SELECT TOP 1 x.backup_finish_date 
		FROM msdb..backupset AS x 
		WHERE x.database_name = d.name
		AND x.recovery_model = d.recovery_model_desc COLLATE DATABASE_DEFAULT
		AND x.[type] = 'D'
		ORDER BY x.backup_start_date DESC) AS BackupEndDate
	
	 , (SELECT MAX(ROUND(CAST(x.compressed_backup_size AS FLOAT)/1000/1000/1000, 2))
		FROM msdb..backupset AS x 
		INNER JOIN msdb..backupmediafamily y 
			ON x.media_set_id = y.media_set_id
		WHERE x.database_name = d.name
		AND x.[type] = 'D'
		AND x.recovery_model = d.recovery_model_desc COLLATE DATABASE_DEFAULT) AS SizeGB
	 
	 , (SELECT TOP 1 y.physical_device_name
		FROM msdb..backupset AS x 
		INNER JOIN msdb..backupmediafamily y 
			ON x.media_set_id = y.media_set_id
		WHERE x.database_name = d.name
		AND x.recovery_model = d.recovery_model_desc COLLATE DATABASE_DEFAULT
		AND x.[type] = 'D'
		ORDER BY x.backup_start_date DESC) AS [FileName]
			 
FROM sys.databases AS d


