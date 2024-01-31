USE Portal
GO

SET NOCOUNT, XACT_ABORT ON;

DECLARE @pSourceDBName AS VARCHAR(100), @pTargetDBName AS VARCHAR(100), @pSchemaName AS VARCHAR(100);

DECLARE @vLoop INT, @vColumnCSV VARCHAR(MAX), @vRowCount INT, @vTableName VARCHAR(130), @vHaveIdentityColumn AS BIT;
DECLARE @vStatusText AS VARCHAR(MAX), @vSqlTx aS NVARCHAR(MAX), @vParamTx AS NVARCHAR(MAX);
DECLARE @vLogDetailId AS INT, @vBatchName AS VARCHAR(100), @vTaskName AS VARCHAR(100), @vInsertCount AS INT, @vCurrentDT AS DATETIME, @vSchemaLogDetailId AS INT, @vBatchCode AS INT;

DECLARE @vTbl_AllSchemas AS TABLE 
(
	SchemaName VARCHAR(50), 
	StatusText VARCHAR(MAX)
);

DECLARE @vTbl_SchemasTables AS TABLE 
(
	ROWID INT, 
	TABLE_NAME VARCHAR(MAX)
);

---------------------------------------------------------------------------------------------------

--> Set Parameters here
SET @pSourceDBName	= 'tempPortal';	-- MANDATORY; Source database name
SET @pTargetDBName	= DB_NAME();	-- MANDATORY; Target database name
SET @pSchemaName		= NULL;		-- OPTIONAL; keep NULL for all Schema OR one of {'APIR', 'Tropac', 'PlayGroundPoker', 'TVC'}

---------------------------------------------------------------------------------------------------

INSERT INTO @vTbl_AllSchemas (SchemaName, StatusText)
SELECT [name] AS SchemaName, NULL AS StatusText
FROM sys.schemas AS a
WHERE a.[schema_id] BETWEEN 5 AND 100
AND (ISNULL(@pSchemaName, '') = '' OR a.[name] = @pSchemaName);

SET @vBatchName = CONCAT('REFRESH [',@pSourceDBName,'] TO [',@pTargetDBName,']' );

IF CURSOR_STATUS('global','curSchema') >= -1
BEGIN
	DEALLOCATE curSchema;
END;

DECLARE curSchema CURSOR LOCAL FOR
SELECT SchemaName 
FROM @vTbl_AllSchemas;

OPEN curSchema;

FETCH curSchema INTO @pSchemaName;

WHILE @@FETCH_STATUS = 0
BEGIN
	
	SET @vSchemaLogDetailId = NULL;
	SET @vTaskName = @pSchemaName;		
	EXEC LogDB.dbo.usp_LogDB_UpdateLogDetails
				@pBatchName= @vBatchName,
				@pTaskName = @vTaskName,
				@pStatusCd = 'Started',
				@pLogDetailId = @vSchemaLogDetailId OUTPUT,
				@pBatchCode = @vBatchCode OUTPUT;

	BEGIN TRY
		
		UPDATE @vTbl_AllSchemas SET StatusText = 'STARTED:~ Tables are started refreshing...' WHERE SchemaName = @pSchemaName;
	

		EXEC('ALTER TABLE [' + @pTargetDBName + '].[' + @pSchemaName   +']._xEmployees DISABLE TRIGGER ti_employees;')
		EXEC('ALTER TABLE [' + @pTargetDBName + '].[' + @pSchemaName   +']._xAssignments DISABLE TRIGGER ti_assignments;')
		
		DELETE FROM @vTbl_SchemasTables;		

		SET @vSqlTx = ' SELECT 
							ROWID = ROW_NUMBER() OVER (ORDER BY a.TABLE_NAME), a.TABLE_NAME   		
						FROM  [' + @pTargetDBName + '].INFORMATION_SCHEMA.TABLES AS a
						JOIN [' + @pSourceDBName + '].INFORMATION_SCHEMA.TABLES AS b
							ON a.TABLE_SCHEMA = b.TABLE_SCHEMA
							AND a.TABLE_NAME = b.TABLE_NAME
						WHERE a.TABLE_SCHEMA = ''' + @pSchemaName + ''' 
						AND a.TABLE_NAME NOT IN (''RowImported'',
											   ''privilegeAPIMappings'',
											   ''TimeLogStatusTypes'',
											   ''TimePieceSettings'',
											   ''TimePieceSettingsExtended'',
											   ''tpEmployeeFileNumber'',
											   ''tpTemplateFields'',
											   ''DisciplinaryThresholdNames'',
											   ''privilegeSubPrivilege'',
   											   ''Privilege'',
											   ''PrivilegeCategories'',
											   ''Tally'')
						AND a.TABLE_TYPE=''BASE TABLE''
						ORDER BY a.TABLE_NAME; '

		INSERT INTO @vTbl_SchemasTables (ROWID, TABLE_NAME)
		EXEC (@vSqlTx);

		SET @vRowCount = @@ROWCOUNT    
		SET @vLoop = 1    

		WHILE @vLoop <= @vRowCount   
		BEGIN     
			SELECT @vTableName = TABLE_NAME 
			FROM @vTbl_SchemasTables 
			WHERE ROWID = @vLoop;
				
			SET @vTaskName = CONCAT('[',@pSchemaName,'].[',@vTableName,']');
			SET @vInsertCount = NULL;
			SET @vLogDetailId = NULL;
			
			EXEC LogDB.dbo.usp_LogDB_UpdateLogDetails
						@pBatchCode = @vBatchCode,
						@pBatchName= @vBatchName,
						@pTaskName = @vTaskName,
						@pStatusCd = 'Started',						
						@pLogDetailId = @vLogDetailId OUTPUT;

		   BEGIN TRY	

				SET @vColumnCSV = '';		   
				SET @vSqlTx = ' SELECT @vColumnCSV = ISNULL(@vColumnCSV,'''') + '',['' + a.COLUMN_NAME + '']''     
							FROM [' + @pTargetDBName + '].INFORMATION_SCHEMA.COLUMNS AS a
							JOIN [' + @pSourceDBName + '].INFORMATION_SCHEMA.COLUMNS AS b
								ON a.TABLE_SCHEMA = b.TABLE_SCHEMA
								AND a.TABLE_NAME = b.TABLE_NAME
								AND a.COLUMN_NAME = b.COLUMN_NAME
							WHERE a.TABLE_NAME = ''' + @vTableName + '''
							AND a.TABLE_SCHEMA = ''' + @pSchemaName + '''
							ORDER BY a.ORDINAL_POSITION; ';

			
				SET @vParamTx = ' @vColumnCSV VARCHAR(MAX) OUTPUT';
			
				--PRINT @vSqlTx
				EXEC sp_executesql @vSqlTx, @vParamTx, @vColumnCSV = @vColumnCSV OUTPUT;
			
				PRINT CONCAT('', GETDATE(), ' :: Exporting table '+ @pSchemaName + '.' + @vTableName +'');

				SET @vColumnCSV = SUBSTRING(@vColumnCSV,2,LEN(@vColumnCSV)) ;
				SET @vHaveIdentityColumn = 0;
				
				SELECT @vHaveIdentityColumn = 1 
				FROM sys.identity_columns 
				WHERE object_id = OBJECT_ID(CONCAT('[', @pSchemaName, '].[', @vTableName, ']'))  
				AND CONCAT(',',@vColumnCSV,',') LIKE CONCAT('%,^[',[name],'^],%')  ESCAPE '^';
				
				-- PRINT CONCAT('@pSchemaName:', @pSchemaName, ' | @vTableName:', @vTableName,' | @vHaveIdentityColumn: ', @vHaveIdentityColumn, ' | @vColumnCSV: ', @vColumnCSV);

				SET @vSqlTx =  CONCAT('
								TRUNCATE TABLE [' , @pTargetDBName , '].[', @pSchemaName , '].[' , @vTableName  , '];   
								 
								IF ISNULL(@vHaveIdentityColumn, 0) = 1
								BEGIN
									SET IDENTITY_INSERT [' , @pTargetDBName , '].[' ,  @pSchemaName  , '].[' , @vTableName  , '] ON;  
								END;

								INSERT INTO [' , @pTargetDBName , '].[' ,  @pSchemaName  ,'].[' , @vTableName  , '] ('  , @vColumnCSV , ')   
								SELECT ' , @vColumnCSV ,'   
								FROM [' , @pSourceDBName , '].[' ,  @pSchemaName  ,'].[' , @vTableName  , ']; 
								 
								SET @vInsertCount = @@ROWCOUNT;

								IF ISNULL(@vHaveIdentityColumn, 0) = 1
								BEGIN
									SET IDENTITY_INSERT [' , @pTargetDBName , '].[' ,  @pSchemaName  ,'].[' , @vTableName  , '] OFF; 
								END;
								 ');

				SET @vParamTx = ' @vHaveIdentityColumn AS BIT, @vInsertCount AS INT OUTPUT ';
				
				--PRINT @vSqlTx;
				EXEC sp_executesql @vSqlTx
								, @vParamTx
								, @vHaveIdentityColumn =  @vHaveIdentityColumn
								, @vInsertCount = @vInsertCount OUTPUT;
				 
				
				SET @vCurrentDT = GETDATE();
				EXEC LogDB.dbo.usp_LogDB_UpdateLogDetails
						@pBatchCode = @vBatchCode,
						@pStatusCd = 'Success',	
						@pEndDT = @vCurrentDT,
						@pInsertCnt = @vInsertCount,
						@pLogDetailId = @vLogDetailId OUTPUT;

			END TRY
			BEGIN CATCH
				SET @vCurrentDT = GETDATE();
				SET @vStatusText = CONCAT(ERROR_NUMBER(), '#', ERROR_MESSAGE(), ' at Line: ', ERROR_LINE(), '.');
				PRINT CONCAT('', GETDATE(), ' :: ERROR: ',@vStatusText);

				EXEC LogDB.dbo.usp_LogDB_UpdateLogDetails
						@pBatchCode = @vBatchCode,
						@pStatusCd = 'Error',	
						@pStatusTx = @vStatusText,
						@pEndDT = @vCurrentDT,
						@pInsertCnt = @vInsertCount,
						@pLogDetailId = @vLogDetailId OUTPUT;

			END CATCH

			SET @vLoop = @vLoop + 1;  
		END;

		EXEC('ALTER TABLE [' + @pTargetDBName + '].[' + @pSchemaName   +']._xEmployees ENABLE TRIGGER ti_employees;')	
		EXEC('ALTER TABLE [' + @pTargetDBName + '].[' + @pSchemaName   +']._xAssignments DISABLE TRIGGER ti_assignments;')

		UPDATE @vTbl_AllSchemas SET StatusText = 'DONE:~ Tables refresh operation completed!' WHERE SchemaName = @pSchemaName;
		
		SET @vCurrentDT = GETDATE();
		EXEC LogDB.dbo.usp_LogDB_UpdateLogDetails						
				@pBatchCode = @vBatchCode,
				@pStatusCd = 'Success',	
				@pEndDT = @vCurrentDT,				
				@pLogDetailId = @vSchemaLogDetailId OUTPUT;

	END TRY
	BEGIN CATCH
		SET @vStatusText = CONCAT('ERROR:~ ', ERROR_NUMBER(), '#', ERROR_MESSAGE(), ' at Line: ', ERROR_LINE(), '.');
		
		UPDATE @vTbl_AllSchemas SET StatusText = @vStatusText WHERE SchemaName = @pSchemaName;
		PRINT @vStatusText;

		SET @vStatusText = CONCAT(ERROR_NUMBER(), '#', ERROR_MESSAGE(), ' at Line: ', ERROR_LINE(), '.');
		
		SET @vCurrentDT = GETDATE();
		EXEC LogDB.dbo.usp_LogDB_UpdateLogDetails						
				@pBatchCode = @vBatchCode,
				@pStatusCd = 'Error',	
				@pStatusTx = @vStatusText,
				@pEndDT = @vCurrentDT,
				@pLogDetailId = @vSchemaLogDetailId OUTPUT;
	END CATCH
	
	FETCH curSchema INTO @pSchemaName;
END;

CLOSE curSchema;
DEALLOCATE curSchema;

---------------------------------------------------------------------------------------------------

--> Result
SELECT * FROM @vTbl_AllSchemas;

---------------------------------------------------------------------------------------------------

GO
PRINT '~DONE~'
GO

