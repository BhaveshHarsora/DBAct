USE [master]
GO
/*
BH20220727 : New SP to Check and get list of Failed Login for the given Date range
*/
GO 
CREATE PROCEDURE [dbo].[sp_FailedLogins] 
(
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL
)
AS 
BEGIN
	--Failed login attempts in the last 60 minutes
	 
	IF @FromDate IS NULL BEGIN SET @FromDate = DATEADD(MINUTE,-60,GETDATE()) END
	IF @ToDate IS NULL BEGIN SET @ToDate = GETDATE() END
	 
	IF OBJECT_ID('Tempdb..#Errors') IS NOT NULL
	DROP TABLE #Errors
	 
	CREATE TABLE #Errors
	(
		Logdate Datetime,
		Processinfo Varchar(30),
		Text Varchar (255)
	)
	INSERT INTO #Errors
	EXEC xp_ReadErrorLog 0, 1, N'FAILED',N'login',@FromDate,@ToDate;
	 
	SELECT
		REPLACE(LoginErrors.Username,'''','') AS Username,
		CAST(LoginErrors.Attempts AS NVARCHAR(6)) AS Attempts,
		LatestDate.Logdate,
		Latestdate.LastError
	from (
		Select SUBSTRING(text,Patindex('%''%''%',Text),charindex('.',Text)-(Patindex('%''%''%',Text))) as Username,Count(*) AS Attempts
		From #Errors Errors
		GROUP BY SUBSTRING(text,Patindex('%''%''%',Text),charindex('.',Text)-(Patindex('%''%''%',Text)))
	) AS LoginErrors
	CROSS APPLY (
		SELECT TOP 1 Logdate,text as LastError
		FROM #Errors LatestDate
		where LoginErrors.Username = SUBSTRING(text,Patindex('%''%''%',Text),charindex('.',Text)-(Patindex('%''%''%',Text)))
		ORDER by Logdate DESC
	) AS LatestDate	 
	Order by LoginErrors.Attempts DESC
	 
END
GO
