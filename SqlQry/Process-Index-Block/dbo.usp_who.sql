USE [MASTER]
GO
IF NOT EXISTS(SELECT 1 FROM master.sys.procedures WHERE name = 'usp_who')
BEGIN
	EXEC ('CREATE PROCEDURE dbo.usp_who AS BEGIN RETURN 0; END;');
END;
GO
ALTER PROCEDURE dbo.usp_who
(
	@pStatus NVARCHAR(255) = NULL
	, @pLogin NVARCHAR(255) = NULL
	, @pHostName NVARCHAR(255) = NULL
	, @pDBName NVARCHAR(255) = NULL
	, @pBlkBy NVARCHAR(255) = NULL
	, @pProgramName NVARCHAR(1000) = NULL
)
AS
BEGIN
	
	SET NOCOUNT, XACT_ABORT ON;
	
	DECLARE @vID AS INT, @vSPID AS INT, @vSqlTx AS NVARCHAR(MAX);
	DECLARE @vEvt AS TABLE (EventType NVARCHAR(255), Params NVARCHAR(255), EventInfo NVARCHAR(MAX));

	SET @pStatus		= NULLIF(@pStatus, '');
	SET @pLogin			= NULLIF(@pLogin, '');
	SET @pHostName		= NULLIF(@pHostName, '');
	SET @pDBName		= NULLIF(@pDBName, '');
	SET @pBlkBy			= NULLIF(@pBlkBy, '');
	SET @pProgramName	= NULLIF(@pProgramName, '');
	
	IF OBJECT_ID('tempdb..#tmpSpWho2') IS NOT NULL  
	BEGIN
		DROP TABLE #tmpSpWho2;
	END;

	CREATE TABLE #tmpSpWho2
	(
		ID INT IDENTITY (1,1) 
		, SPID INT 
		, [Status] NVARCHAR(255)
		, [Login] NVARCHAR(255)	
		, HostName NVARCHAR(255)
		, BlkBy NVARCHAR(255)
		, DBName NVARCHAR(255)
		, Command NVARCHAR(255)
		--, SqlTx NVARCHAR(MAX)
		, CPUTime BIGINT
		, DiskIO BIGINT
		, LastBatch NVARCHAR(255)
		, ProgramName NVARCHAR(1000)
		, SPID2 INT 
		, REQUESTID INT
	)

	INSERT INTO #tmpSpWho2 (SPID, Status, Login, HostName, BlkBy, DBName
		, Command, CPUTime, DiskIO, LastBatch, ProgramName, SPID2, REQUESTID)
	EXEC sys.sp_who2;

------------
	
	-- Add SqlTx for each SPID
	--DECLARE curSpWho CURSOR LOCAL FAST_FORWARD FOR
	--SELECT a.ID, a.SPID FROM #tmpSpWho2 AS a WHERE a.SPID > 50;

	--OPEN curSpWho;
	
	--FETCH curSpWho INTO @vID, @vSPID;
	
	--WHILE @@FETCH_STATUS = 0
	--BEGIN
	--	SET @vSqlTx = CONCAT('DBCC INPUTBUFFER (', @vSPID, '); ');
		
	--	BEGIN TRY
	--		INSERT INTO @vEvt(EventType, Params, EventInfo)		
	--		EXEC (@vSqlTx);		
	--	END TRY
	--	BEGIN CATCH
	--		INSERT INTO @vEvt(EventType, Params, EventInfo)
	--		SELECT 'Error' AS EventType
	--			, ERROR_NUMBER() AS Params
	--			, ERROR_MESSAGE() AS EventInfo
	--	END CATCH

	--	UPDATE a
	--		SET a.SqlTx = (SELECT TOP 1 EventInfo FROM @vEvt)
	--	FROM #tmpSpWho2 AS a
	--	WHERE a.ID = @vID;

	--	FETCH curSpWho INTO @vID, @vSPID;
	--END;
	
	--CLOSE curSpWho;
	--DEALLOCATE curSpWho;

------------	

	SELECT a.SPID, a.Status, a.Login, a.HostName, a.BlkBy, a.DBName, a.Command
		--, a.SqlTx
		, a.CPUTime, a.DiskIO, a.LastBatch, a.ProgramName, a.REQUESTID
	FROM #tmpSpWho2 AS a
	WHERE [Status]	= ISNULL(@pStatus	  , a.[Status])
	AND [Login]		= ISNULL(@pLogin	  , a.[Login])
	AND HostName	= ISNULL(@pHostName	  , a.HostName)
	AND DBName		= ISNULL(@pDBName	  , a.DBName)
	AND BlkBy		= ISNULL(@pBlkBy	  , a.BlkBy)
	AND ProgramName	= ISNULL(@pProgramName, a.ProgramName);

END;
GO