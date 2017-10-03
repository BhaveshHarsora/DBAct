IF NOT EXISTS(SELECT 1 FROM sys.procedures WHERE name = 'usp_HCDM_MigSourceDbTables_Test')
BEGIN
	EXEC ('CREATE PROCEDURE usp_HCDM_MigSourceDbTables_Test AS RETURN 0;');
END;
GO

ALTER PROCEDURE usp_HCDM_MigSourceDbTables_Test
AS 
BEGIN

  SET NOCOUNT, XACT_ABORT ON; 
  SET ANSI_WARNINGS OFF;

  DECLARE @vTblBtDtlLogger AS Type_BatchDetailLogger, @vIsError AS BIT = 0;
  DECLARE @vOnErrCntd AS INT, @vDbTableName AS VARCHAR(50);
  
  EXEC usp_HCDM_GetSession 'OnErrCntd', @vOnErrCntd OUTPUT
  
  BEGIN TRANSACTION

  BEGIN TRY
	
	DECLARE @vMigrationResult AS VARCHAR(MAX) = '', @vInsertedRecordCount AS INT = 0, @vUpdatedRecordCount AS INT = 0, @vDeletedRecordCount AS INT = 0;
	DECLARE @vMaxLBPtId AS INT;

----------

	--::LOGGER:: Start: SLTC_MDSXMLData	
	SET @vDbTableName = 'SLTC_MDSXMLData'
	INSERT INTO @vTblBtDtlLogger (StatusCd, DbTableName, PrevRowCount)	
	SELECT 'COM' AS StatusCd, @vDbTableName AS DbTableName, COUNT(1) AS PrevRowCount FROM SLTC_MDSXMLData
	
	--> SimpleLTC..MDSXMLData >> HCDM..SLTC_MDSXMLData

	INSERT INTO SLTC_MDSXMLData (Id, [XML], DBName)
	SELECT a.id, a.[XML], a.DBName
	FROM (
		SELECT 'SimpleLTC' AS DBName, x.*	
		FROM SimpleLTC..MDSXMLData AS x --3154
	) AS a
	LEFT JOIN SLTC_MDSXMLData AS b
		ON b.id = a.id
	WHERE 1=1
	AND b.MDSXMLDataId IS NULL

	SET @vInsertedRecordCount = @@ROWCOUNT;	
	SET @vMigrationResult = CONCAT(@vMigrationResult, CHAR(13), ':: SimpleLTC.MDSXMLData >> SLTC_MDSXMLData  Migration Result :: Inserted: ' + CAST(@vInsertedRecordCount AS VARCHAR) ,' ; Updated: ' , CAST(@vUpdatedRecordCount AS VARCHAR), ' ; Deleted: ' + CAST(@vDeletedRecordCount AS VARCHAR));

	--::LOGGER:: End: SLTC_MDSXMLData
	SET @vDbTableName = 'SLTC_MDSXMLData'
	INSERT INTO @vTblBtDtlLogger (StatusCd, DbTableName, CurrRowCount, InsertCount)
	SELECT 'SUC' AS StatusCd, @vDbTableName AS DbTableName, COUNT(1) AS CurrRowCount, @vInsertedRecordCount AS InsertCount FROM SLTC_MDSXMLData

----------

	--::LOGGER:: Start: SLTC_MDSBatch	
	SET @vDbTableName = 'SLTC_MDSBatch'
	INSERT INTO @vTblBtDtlLogger (StatusCd, DbTableName, PrevRowCount)	
	SELECT 'COM' AS StatusCd, @vDbTableName AS DbTableName, COUNT(1) AS PrevRowCount FROM SLTC_MDSBatch

	--> SimpleLTC..MDSBatch >> HCDM..SLTC_MDSBatch

	INSERT INTO SLTC_MDSBatch (BatchId,Provider,FileName,Status,WebStatus,StatusDate,UploadDate,TotalRecords, CmsBatchID,DBName)
	SELECT DISTINCT a.Id,a.Provider,a.FileName,a.Status,a.WebStatus,a.StatusDate,a.UploadDate,a.totalRecords, a.CmsBatchID, a.DBName
	FROM (
		SELECT 'SimpleLTC' AS DBName, x.*	
		FROM SimpleLTC..MDSBatch AS x --3154
	) AS a
	LEFT JOIN SLTC_MDSBatch AS b
		ON b.BatchId = a.ID
	WHERE 1=1
	AND b.MDSBatchID IS NULL

	SET @vInsertedRecordCount = @@ROWCOUNT;	
	SET @vMigrationResult = CONCAT(@vMigrationResult, CHAR(13), ':: SimpleLTC.MDSBatch >> SLTC_MDSBatch  Migration Result :: Inserted: ' + CAST(@vInsertedRecordCount AS VARCHAR) ,' ; Updated: ' , CAST(@vUpdatedRecordCount AS VARCHAR), ' ; Deleted: ' + CAST(@vDeletedRecordCount AS VARCHAR));

	--::LOGGER:: End: SLTC_MDSBatch
	SET @vDbTableName = 'SLTC_MDSBatch'
	INSERT INTO @vTblBtDtlLogger (StatusCd, DbTableName, CurrRowCount, InsertCount)
	SELECT 'SUC' AS StatusCd, @vDbTableName AS DbTableName, COUNT(1) AS CurrRowCount, @vInsertedRecordCount AS InsertCount FROM SLTC_MDSBatch

----------

	--::LOGGER:: Start: SLTC_MDSAssessment	
	SET @vDbTableName = 'SLTC_MDSAssessment'
	INSERT INTO @vTblBtDtlLogger (StatusCd, DbTableName, PrevRowCount)	
	SELECT 'COM' AS StatusCd, @vDbTableName AS DbTableName, COUNT(1) AS PrevRowCount FROM SLTC_MDSAssessment

	--> SimpleLTC..MDSAssessment >> HCDM..SLTC_MDSAssessment

	INSERT INTO SLTC_MDSAssessment (PatientId, id, batchID, residentName, dateOfBirth, ssn, medicareID, medicaidID, filename, assessmentType
		, versionCode, correction, targetDate, status, a0200, a0310a, a0310b, a0310c, a0310d, a0310f, isc, DBName, RefPatientId)
	SELECT DISTINCT NULL PatientId, a.id, a.batchID, RTRIM(LTRIM(a.residentName)) AS residentName, a.dateOfBirth, a.ssn, a.medicareID, a.medicaidID, a.filename, a.assessmentType
		, a.versionCode, a.correction, a.targetDate, a.status, a.a0200, a.a0310a, a.a0310b, a.a0310c, a.a0310d, a.a0310f, a.isc, a.DBName, NULL RefPatientId
	FROM (
		SELECT 'SimpleLTC' AS DBName, x.*	
		FROM SimpleLTC..MDSAssessment AS x --3154
	) AS a
	LEFT JOIN SLTC_MDSAssessment AS b
		ON b.id = a.id
	WHERE 1=1
	AND b.SLTC_MDSAssessmentId IS NULL

	SET @vInsertedRecordCount = @@ROWCOUNT;	

	--::LOGGER:: End: SLTC_MDSAssessment
	SET @vDbTableName = 'SLTC_MDSAssessment'
	INSERT INTO @vTblBtDtlLogger (StatusCd, DbTableName, CurrRowCount, InsertCount)
	SELECT 'SUC' AS StatusCd, @vDbTableName AS DbTableName, COUNT(1) AS CurrRowCount, @vInsertedRecordCount AS InsertCount FROM SLTC_MDSAssessment


----------
	
	--> Update PatientId, RefPatientId and DBName of SLTC_MDSAssessment as With MatrixCare Patients.
	UPDATE spm
		SET spm.PatientId = p.PatientId
			, spm.DBName = mp.DBName
			, spm.RefPatientId = mp.RefDbPatientId
	FROM SLTC_MDSAssessment AS spm
	JOIN (
		SELECT A.id, A.residentName
			, A.dateOfBirth, A.ssn, A.medicareID, A.medicaidID	
			, A.Name1 AS LastName
			, COALESCE(NULLIF(Name2,''), NULLIF(Name3,''), NULLIF(Name4,''), '') AS FirstName
			, (CASE WHEN LEN(ISNULL(Name2,'')) > 1
						THEN COALESCE(NULLIF(Name3,''), NULLIF(Name4,''), NULLIF(Name5,''), '')
					ELSE COALESCE(NULLIF(Name4,''), NULLIF(Name5,''), '')
				 END) AS MiddleName
		FROM (
			SELECT aa.id, aa.residentName
				, aa.dateOfBirth, aa.ssn, aa.medicareID, aa.medicaidID	
				, b.xnode.value('node[1]','nvarchar(100)') AS Name1
				, b.xnode.value('node[2]','nvarchar(100)') AS Name2
				, b.xnode.value('node[3]','nvarchar(100)') AS Name3
				, b.xnode.value('node[4]','nvarchar(100)') AS Name4
				, b.xnode.value('node[5]','nvarchar(100)') AS Name5
			FROM (
				SELECT xx.id, xx.residentName, xx.dateOfBirth, xx.ssn, xx.medicareID, xx.medicaidID
					,CAST('<node>' + REPLACE(REPLACE(xx.residentName, ',', '</node><node>'),' ', '</node><node>') + '</node>' AS XML) AS XVal
				FROM (
					SELECT DISTINCT id, REPLACE(residentName, '  ',' ') AS residentName, dateOfBirth, ssn, medicareID, medicaidID
					FROM SLTC_MDSAssessment 
				) AS xx
			) AS aa
			CROSS APPLY aa.XVal.nodes('.') as b(xnode) 
			--WHERE aa.Id in (49322388,49322387,49322386,49322385)
		) AS A
	) AS AA
		ON AA.id = spm.id
	LEFT JOIN PatientMaster AS p
		JOIN MPatientLookup AS mp
			ON mp.PatientId = p.PatientId
			 AND mp.DBName = 'MatrixCare'
		ON (
			(
				AA.LastName = p.LastName AND AA.FirstName = P.FirstName AND AA.MiddleName = p.MiddleName
				AND 
				 (AA.dateOfBirth = p.BirthDate OR AA.medicareID = P.MedicareNo OR AA.medicaidID = P.MedicaidNo)
			)
			OR
			(
				AA.LastName = p.LastName AND AA.FirstName = P.FirstName  AND AA.ssn = P.SSN
			)
			OR
			(
				AA.ssn = P.ssn  
				AND (AA.LastName = p.LastName OR AA.FirstName = P.FirstName OR AA.MiddleName = p.MiddleName)			
				AND (AA.medicareID = P.MedicareNo OR AA.medicaidID = P.MedicaidNo)
			)
		)
	WHERE 1=1
	AND COALESCE(spm.PatientId, spm.RefPatientId, spm.DBName) IS NULL
	AND p.PatientId IS NOT NULL

	SET @vUpdatedRecordCount = @@ROWCOUNT;	
	SET @vMigrationResult = CONCAT(@vMigrationResult, CHAR(13), ':: SimpleLTC.MDSAssessment >> SLTC_MDSAssessment  Migration Result :: Inserted: ' + CAST(@vInsertedRecordCount AS VARCHAR) ,' ; Updated: ' , CAST(@vUpdatedRecordCount AS VARCHAR), ' ; Deleted: ' + CAST(@vDeletedRecordCount AS VARCHAR));

	--::LOGGER:: End: SLTC_MDSAssessment
	SET @vDbTableName = 'SLTC_MDSAssessment'
	INSERT INTO @vTblBtDtlLogger (StatusCd, DbTableName, CurrRowCount, InsertCount, UpdateCount)
	SELECT 'SUC' AS StatusCd, @vDbTableName AS DbTableName, COUNT(1) AS CurrRowCount, @vInsertedRecordCount AS InsertCount, @vUpdatedRecordCount AS UpdateCount FROM SLTC_MDSAssessment

----------
	
	--::LOGGER:: Start: LBPatientMaster	
	SET @vDbTableName = 'LBPatientMaster'
	INSERT INTO @vTblBtDtlLogger (StatusCd, DbTableName, PrevRowCount)	
	SELECT 'COM' AS StatusCd, @vDbTableName AS DbTableName, COUNT(1) AS PrevRowCount FROM LBPatientMaster
	
	--> LoopBack..patient_coaching_logs >> HCDM..LBPatientMaster
		
	SELECT @vMaxLBPtId = ISNULL(MAX(a.RefPatientId), 0) FROM LBPatientMaster AS a
	
	INSERT INTO LBPatientMaster (RefPatientId, CustomerId)
	SELECT A.RefPatientID, A.CustomerId
	FROM (
		SELECT (@vMaxLBPtId + ROW_NUMBER() OVER(ORDER BY xx.customerID)) AS RefPatientID
				, CONVERT(VARCHAR(200),xx.customerid) as CustomerId
		FROM (
			SELECT x.customerid, x.LastName, x.FirstName, x.BirthDate, x.Address,x.City,x.Gender,x.State,x.ZipCode,x.MedicareId
				, ROW_NUMBER() OVER (PARTITION BY customerid ORDER BY customerid) AS C1
			FROM LoopBack..patient_coaching_logs AS x
		) AS xx
		WHERE xx.C1 = 1
	) AS A
	LEFT JOIN LBPatientMaster AS b
		ON b.CustomerId = A.CustomerId
		 AND b.RefPatientId = A.RefPatientID	
	WHERE b.LBPatientMasterId IS NULL
	ORDER BY A.RefPatientID

	--::LOGGER:: End: LBPatientMaster
	SET @vDbTableName = 'LBPatientMaster'
	INSERT INTO @vTblBtDtlLogger (StatusCd, DbTableName, CurrRowCount, InsertCount)
	SELECT 'SUC' AS StatusCd, @vDbTableName AS DbTableName, COUNT(1) AS CurrRowCount, @vInsertedRecordCount AS InsertCount FROM LBPatientMaster
	
----------

	PRINT @vMigrationResult;

	COMMIT;
  END TRY
  BEGIN CATCH
	
	DECLARE @vErrorTx AS VARCHAR(MAX);
	
	SELECT @vIsError = 1, @vErrorTx = dbo.udf_HCDM_GetDBError(':: SimpleLTC Data Migration Error :: ');
	
	--::LOGGER:: Error
	INSERT INTO @vTblBtDtlLogger (StatusCd, DbTableName, RemarkTx)
	SELECT 'ERR' AS StatusCd, @vDbTableName AS DbTableName, @vErrorTx AS RemarkTx;

	IF XACT_STATE() != 0 AND ISNULL(@vOnErrCntd, 0) = 0
	BEGIN
		ROLLBACK TRANSACTION;
	END;

	IF ISNULL(@vOnErrCntd, 0) = 0
		RAISERROR(@vErrorTx, 16, 1)

  END CATCH;

	--:: SET/SAVE LOGGER ::
	IF (@vIsError = 1 AND ISNULL(@vOnErrCntd, 0) = 0) OR (ISNULL(@vIsError, 0) = 0) 
	BEGIN
		EXEC usp_HCDM_LogBatchDetails @pLogMode = 'SAVELOG', @pTblBtDtlLogger = @vTblBtDtlLogger;
	END;
	ELSE
	BEGIN
		EXEC usp_HCDM_LogBatchDetails @pLogMode = 'SETLOG', @pTblBtDtlLogger = @vTblBtDtlLogger;
	END;

END;
GO