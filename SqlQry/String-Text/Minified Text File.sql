/*
Date: 30 Aug 2019

Minimfied Text file.

*** below method will remove extra spaces, carriege return, tab, enter characters.

*/


DECLARE @vSqlTx as varchar(max);
SET @vSqlTx  = '
SELECT t.[Date]
	, t.controlid
	, t.jobname
	, t.JobNumber
	, t.DepartmentNumber
	, t.DepartmentName
	, SUM(t.usercount) AS UserCount
	, SUM(t.AssignmentCount) AS AssignmentCount	
	, SUM(t.ShiftCreated) AS ShiftCreated
	, SUM(t.ShiftFilled) AS ShiftFilled	
	, SUM(t.Callouts) AS Callouts
	, COUNT(CASE WHEN t.TardyMinutes > 0 THEN 1 END) AS LateCount 
FROM (
	SELECT DISTINCT S.[Date]
		, S.controlid
		, J.JobNumber
		, J.JobName
		, dept.DepartmentNumber
		, dept.DepartmentName
		
		, COUNT(S.UserId) AS UserCount
		, COUNT(S.Assignment) AS AssignmentCount		
		, SUM(CASE WHEN ISNULL(S.AssignmentId, 0) != 0  AND ISNULL(S.ShiftID, 0) != 0  THEN S.ShiftID ELSE NULL END) AS ShiftCreated
		, SUM(CASE WHEN ASG.AssignmentNumber IS NOT NULL AND ISNULL(S.UserId,0) > 0 AND ISNULL(ASG.[Shift], 0) != 0  THEN ASG.[Shift] ELSE NULL END) AS ShiftFilled
		, COUNT(CASE WHEN CO.callOutID > 0 THEN 1 ELSE NULL END) AS Callouts
		, d.TardyMinutes
	FROM Schedule AS  S
	INNER JOIN [UserControl] AS UC 
		ON UC.UserId=S.UserId
	INNER JOIN _xJobs AS J 
		ON J.JobNumber=Uc.JobNumber
	INNER JOIN Departments  AS dept 
		ON dept.ControlId = s.ControlId
	LEFT JOIN DaysOffLog AS D 
		ON D.UserID=S.UserId and date=D.StartDate 
	LEFT JOIN _xAssignments AS ASG
		ON ASG.AssignmentNumber = S.AssignmentId
		AND ASG.controlID = S.ControlId	
		AND ASG.Shift = S.ShiftID
	LEFT JOIN callOuts AS CO
		ON CO.assignmentID = ASG.AssignmentNumber
		AND CO.controlID = S.ControlId
		ANd CO.controlID = S.ControlId
		AND CO.userID = S.UserId
	GROUP BY [Date],J.JobName,J.JobNumber,S.controlid,D.TardyMinutes , uc.DepartmentNumber, dept.DepartmentName, dept.DepartmentNumber, CO.assignmentStartDate
) AS t
WHERE 1=1
GROUP BY t.[Date], t.controlid, t.JobName,t.JobNumber, t.DepartmentNumber, t.DepartmentName
ORDER BY t.[Date], t.controlid
';

set @vSqlTx = REPLACE(REPLACE(REPLACE(@vSqlTx
					, CHAR(13), ' ') 
					, CHAR(10), ' ') 
					, CHAR(9), ' ');

WHILE CHARINDEX('  ', @vSqlTx) > 0	SET @vSqlTx = REPLACE(@vSqlTx, '  ', ' ');

PRINT @vSqlTx;



GO
PRINT '~DONE~'
GO
