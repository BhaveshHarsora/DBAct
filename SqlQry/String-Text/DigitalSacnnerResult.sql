SET NOCOUNT ON
DECLARE @t TABLE (Id int, ScanNumber NVARCHAR(116))
 
INSERT INTO @t
SELECT  1,--> 000 007 059
' _  _  _  _  _  _  _  _  _
| || || || || |  || ||_ |_|
|_||_||_||_||_|  ||_| _| _|
                            
'
UNION
SELECT  2, --> 490 067 715
'    _  _  _  _  _  _     _
|_||_|| || ||_   |  |  ||_
  | _||_||_||_|  |  |  | _|
                            
'
UNION
SELECT  3, --> 680 X68 279
' _  _  _     _  _  _  _  _
|_ |_|| || ||_ |_| _|  ||_|
|_||_||_||_||_||_||_   | _|
                            
'
UNION
SELECT  4, --> 490 867 716
'    _  _  _  _  _  _     _
|_||_|| ||_||_   |  |  ||_
  | _||_||_||_|  |  |  ||_|
                            
'
UNION
SELECT  5, --> X90 867 716
'    _  _  _  _  _  _     _
| ||_|| ||_||_   |  |  ||_
  | _||_||_||_|  |  |  ||_|
                            
'
UNION
SELECT 6, --> 012 345 678
' _     _  _     _  _  _  _
| |  | _| _||_||_ |_   ||_|
|_|  ||_  _|  | _||_|  ||_|
                            
'

;with ScanLine as
(
	SELECT 
		ID
		, 1 AS LineNumber
		, SUBSTRING( REPLACE( ScanNumber, ' ', '$'), PATINDEX('%' + CHAR(13) + CHAR(10) + '%', ScanNumber ) + 2, LEN( ScanNumber ) ) AS ScanNumber
		, SUBSTRING( REPLACE( ScanNumber, ' ', '$'), 1, PATINDEX('%' + CHAR(13) + CHAR(10) + '%', ScanNumber ) ) AS LineString
	FROM @t
	
	UNION ALL
	
	SELECT 
		ID
		, LineNumber + 1 AS LineNumber
		, SUBSTRING( ScanNumber, PATINDEX('%' + CHAR(13) + CHAR(10) + '%', ScanNumber ) + 2, LEN( ScanNumber ) ) AS ScanNumber
		, SUBSTRING( ScanNumber, 1, PATINDEX('%' + CHAR(13) + CHAR(10) + '%', ScanNumber ) ) AS LineString
	FROM ScanLine
	WHERE LEN(LineString) > 0 
)

---- SELECT * FROM ScanLine ORDER BY Id, LineNumber OPTION (MAXRECURSION 0);

, ScanDigit AS
(
	SELECT 
		Id
		, LineNumber
		, 1 AS CharNumber
		, SUBSTRING( REPLACE( REPLACE( LineString, CHAR(13), ''), CHAR(10), ''), 4, LEN(LineString)) AS LineString
		, SUBSTRING( REPLACE( REPLACE( LineString, CHAR(13), ''), CHAR(10), ''), 1, 3) AS CharString
	FROM ScanLine 
	WHERE LineNumber <= 3
	
	UNION ALL

	SELECT 
		Id
		, LineNumber
		, CharNumber + 1 AS CharNumber
		, SUBSTRING( LineString, 4, LEN(LineString)) AS LineString
		, SUBSTRING( LineString, 1, 3) AS CharString
	FROM ScanDigit 
	WHERE LEN(LineString) > 0
)

----- SELECT * FROM ScanDigit ORDER BY ID, CharNumber, LineNumber

, ScanNumber AS 
(
	SELECT 
		DISTINCT
		ID
		, CharNumber
		, ( 
			--REPLACE( 
					--REPLACE( 
							REPLACE( (
										SELECT ',' + CharString + REPLICATE('$', 3 - LEN(CharString) )
										FROM ScanDigit AS ConcanetChar
										WHERE ConcanetChar.Id = ScanDigit.Id
											AND ConcanetChar.CharNumber = ScanDigit.CharNumber
										ORDER BY LineNumber
										FOR XML PATH('')
									), ',', '')
					--		, '&#x20;', ' ')
					--, '&#x0D;', '')
		  ) AS CharString 
	FROM ScanDigit
)

---- SELECT * FROM ScanNumber ORDER BY ID, CharNumber OPTION (MAXRECURSION 0);

, DisplayNumber AS 
(
	SELECT 
		DISTINCT
		ID
		, CharNumber
		, (
			CASE CharString
				WHEN '$_$|$||_|'	THEN '0'
				WHEN '$$$$$|$$|'	THEN '1'
				WHEN '$_$$_||_$'	THEN '2'
				WHEN '$_$$_|$_|'	THEN '3'
				WHEN '$$$|_|$$|'	THEN '4'
				WHEN '$_$|_$$_|'	THEN '5'
				WHEN '$_$|_$|_|'	THEN '6'
				WHEN '$_$$$|$$|'	THEN '7'
				WHEN '$_$|_||_|'	THEN '8'
				WHEN '$_$|_|$_|'	THEN '9'
				WHEN ''				THEN ''
				ELSE 'X'
			END
		 ) AS DisplayChar
	FROM ScanNumber
)

--- SELECT * FROM DisplayNumber ORDER BY ID, CharNumber OPTION (MAXRECURSION 0);

SELECT DISTINCT 
	ID
	, REPLACE( (
				SELECT ',' + DisplayChar
				FROM DisplayNumber AS Digit
				WHERE Digit.Id = DisplayNumber.Id
				ORDER BY CharNumber
				FOR XML PATH('')
			  ), ',', '') AS ScanNumber
FROM DisplayNumber 
ORDER BY ID
OPTION (MAXRECURSION 0);
