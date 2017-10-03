IF EXISTS(SELECT 1 FROM sys.triggers WHERE name = 'trg_HCDM_DbTables_au')
	DROP TRIGGER trg_HCDM_DbTables_au 
GO

CREATE TRIGGER trg_HCDM_DbTables_au
   ON  DbTables
   AFTER UPDATE
AS 
BEGIN

	SET NOCOUNT ON;

	DECLARE  @vProcId AS INT, @vProcCode AS VARCHAR(10), @vParentProcId AS INT, @vSqlTx NVARCHAR(MAX)
	DECLARE @vProcess AS TABLE 
	(
		ProcId INT 
	  , ProcCode VARCHAR(10)
	  , ParentProcId INT
	  , SqlTx NVARCHAR(MAX)
	  , ProcSeq FLOAT
	);

	IF EXISTS(SELECT a.DbTableId, a.DatabaseId, a.TableName
				FROM INSERTED AS a
					JOIN DELETED AS b
					ON a.DbTableId = b.DbTableId
				WHERE a.IsActive = 1
					AND (ISNULL(a.PrevUpdates, 0) != ISNULL(b.PrevUpdates, 0)
						OR a.PrevUpdatedOn != b.PrevUpdatedOn))
	BEGIN

		;WITH cte AS 
		(
			SELECT DISTINCT a.ProcId, a.ProcCode, a.ParentProcId, a.SqlTx, a.ProcSeq
			FROM MigProcesses AS a
			JOIN ProcessTables AS b
				JOIN (SELECT x.DbTableId, x.DatabaseId, x.TableName
						FROM INSERTED AS x
						  JOIN DELETED AS y
							ON x.DbTableId = y.DbTableId
						WHERE x.IsActive = 1
						  AND (ISNULL(x.PrevUpdates, 0) != ISNULL(y.PrevUpdates, 0)
								OR x.PrevUpdatedOn != y.PrevUpdatedOn)
				) AS c
					ON c.DbTableId = b.DbTableId
				ON b.ProcId = a.ProcId
				 AND b.IsActive = 1
			WHERE a.IsActive =1
			--AND ISNULL(a.ParentProcId, 0) = 0

			UNION ALL

			SELECT b.ProcId, b.ProcCode, b.ParentProcId, b.SqlTx, b.ProcSeq
			FROM cte AS a
			JOIN MigProcesses AS b
				ON ISNULL(b.ProcId, 0) = ISNULL(a.ParentProcId, 0)
		)
		INSERT INTO @vProcess (ProcId, ProcCode, ParentProcId, SqlTx, ProcSeq)
		SELECT a.ProcId, a.ProcCode, a.ParentProcId, CAST(ISNULL(a.SqlTx, N'') AS NVARCHAR(MAX)) AS SqlTx, a.ProcSeq
		FROM cte AS a
		ORDER BY a.ProcSeq;		

/* MADE OBSOLATE */
		delete from @vProcess
/* MADE OBSOLATE  */

		DECLARE curProc CURSOR
		FOR 
		SELECT a.ProcId, a.ProcCode, a.ParentProcId, a.SqlTx
		 FROM @vProcess AS a
		 WHERE a.SqlTx != N''
		 ORDER BY a.ProcSeq;

		OPEN curProc;
		
		FETCH NEXT FROM curProc 
			INTO @vProcId , @vProcCode , @vParentProcId , @vSqlTx

		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			EXEC sys.sp_executesql @vSqlTx

			FETCH NEXT FROM curProc 
				INTO @vProcId , @vProcCode , @vParentProcId , @vSqlTx
		END;

		CLOSE curProc;
		DEALLOCATE curProc;

	END;

END;
GO
