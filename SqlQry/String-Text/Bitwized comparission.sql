CREATE TABLE #tblUserPermission
(
	UserId	INT,
	MenuId	INT,
	Rights	INT
)

--[Flags()]
--public enum Actions
--{
--    None = 0,
--    Add = 2,
--    Edit = 4,
--    Delete = 8,
--    View = 16
--}

INSERT INTO #tblUserPermission VALUES(1, 1, 2), (1, 2,  4), (1, 3,  8), (1, 4, 16)
									,(2, 1, 6), (2, 2, 10), (2, 3, 18), (2, 4, 26)

DECLARE @Right INT
	, @Right_Add INT = 2
	, @Right_Edit INT = 4
	, @Right_Delete INT = 8
	, @Right_View INT = 16
	
SET @Right = @Right_Edit

SELECT * FROM #tblUserPermission
SELECT * FROM #tblUserPermission WHERE Rights & @Right = @Right

DROP TABLE #tblUserPermission

/*

IN C#

from UserPermission in dbContext.UserPermission
where Rights | Actions.Add == Actions.Add 

*/