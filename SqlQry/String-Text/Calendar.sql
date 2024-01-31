SET NOCOUNT ON

SET LANGUAGE FRENCH

----;with MonthData AS 
----(
----	SELECT DATEADD(MM, 11, CAST('2009/01/01' AS DATETIME) ) AS Dt
	
----	UNION ALL
	
----	SELECT DATEADD(DD, 1, Dt) AS Dt
----	FROM MonthData
----	WHERE MONTH(Dt) = MONTH(GETDATE())
----)
----SELECT * FROM MonthData

----SET LANGUAGE us_english



--SET LANGUAGE FRENCH

DECLARE @tblCalendar TABLE (Mth INT, Yr INT) 

INSERT @tblCalendar(Mth, Yr) SELECT 8, 2009 
INSERT @tblCalendar(Mth, Yr) SELECT 2, 1900 
INSERT @tblCalendar(Mth, Yr) SELECT 10,1959 

DECLARE @tblCalendarData TABLE (CalDate DATETIME) 

INSERT INTO @tblCalendarData
	SELECT DATEADD(MM, ( Mth - 1 ), CAST( ( '01/01/' + CAST( Yr AS VARCHAR(4) ) ) AS DATETIME ) )
	FROM @tblCalendar
 
;with MonthData AS 
(
	SELECT CalDate, MONTH(CalDate) AS Mth, YEAR(CalDate) AS Yr, DATEPART(DW, CalDate) AS DW, DATEPART(WW, CalDate) AS WW
	FROM @tblCalendarData
	
	UNION ALL
	
	SELECT DATEADD(DD, 1, CalDate) AS CalDate, Mth, Yr, DATEPART(DW, DATEADD(DD, 1, CalDate)) AS DW, DATEPART(WW, DATEADD(DD, 1, CalDate)) AS WW
	FROM MonthData
	WHERE MONTH(CalDate) IN ( SELECT Mth FROM @tblCalendarData )
)
, MonthView AS
(
	SELECT 
		Yr
		, Mth
		, WW
		, [1] AS W1
		, [2] AS W2
		, [3] AS W3
		, [4] AS W4
		, [5] AS W5
		, [6] AS W6
		, [7] AS W7
	FROM 
	(
		SELECT CAST( DATEPART( DAY, CalDate) AS VARCHAR(2) ) AS CalDate, WW, DW, Mth, Yr
		FROM MonthData
	) up
	PIVOT ( MIN(CalDate) FOR DW IN ( [1], [2], [3], [4], [5], [6], [7] ) ) AS pvt
)
, CalendarView AS
(
	SELECT 
		(
			'|'
			+  REPLICATE(' ', 4 - LEN( ISNULL( W1, '' ) ) ) + CAST( ISNULL( W1, '' ) AS VARCHAR(2) )
			+ REPLICATE(' ', 4 - LEN( ISNULL( W2, '' ) ) ) + CAST( ISNULL( W2, '' ) AS VARCHAR(2) )
			+ REPLICATE(' ', 4 - LEN( ISNULL( W3, '' ) ) ) + CAST( ISNULL( W3, '' ) AS VARCHAR(2) )
			+ REPLICATE(' ', 4 - LEN( ISNULL( W4, '' ) ) ) + CAST( ISNULL( W4, '' ) AS VARCHAR(2) )
			+ REPLICATE(' ', 4 - LEN( ISNULL( W5, '' ) ) ) + CAST( ISNULL( W5, '' ) AS VARCHAR(2) )
			+ REPLICATE(' ', 4 - LEN( ISNULL( W6, '' ) ) ) + CAST( ISNULL( W6, '' ) AS VARCHAR(2) )
			+ REPLICATE(' ', 4 - LEN( ISNULL( W7, '' ) ) ) + CAST( ISNULL( W7, '' ) AS VARCHAR(2) )
			+ '|'
		) AS Calender, Yr, Mth, WW
	FROM MonthView
	
	UNION ALL
	
	SELECT REPLICATE('-', 30), YEAR(CalDate) AS Yr, MONTH(CalDate) AS Mth, -3 AS WW
	FROM @tblCalendarData
	
	UNION ALL
	
	SELECT 
		(
			  REPLICATE(' ', ( 28 - LEN( DateName( mm, CalDate ) + ' ' + CAST( Year(CalDate) AS VARCHAR(4) ) ) ) /2 ) 
			+ DateName( mm, CalDate ) + ' ' + CAST( Year(CalDate) AS VARCHAR(4) ) 
		) AS Calender
		, YEAR(CalDate) AS Yr, MONTH(CalDate) AS Mth, -2 AS WW
	FROM @tblCalendarData
	
	UNION ALL
	
	SELECT '|' + REPLICATE('=', 28) + '|' AS Calender, YEAR(CalDate) AS Yr, MONTH(CalDate) AS Mth, -1 AS WW
	FROM @tblCalendarData
	
	UNION ALL
	
	SELECT '| Sun Mon Tue Wed Thu Fri Sat|' AS Calender, YEAR(CalDate) AS Yr, MONTH(CalDate) AS Mth, 0 AS WW
	FROM @tblCalendarData
	
	UNION ALL
	
	SELECT REPLICATE('=', 30) AS Calender, YEAR(CalDate) AS Yr, MONTH(CalDate) AS Mth, 999 AS WW
	FROM @tblCalendarData
)

SELECT 
	(
		CASE WW
			WHEN -2
				THEN '|' + Calender + REPLICATE(' ', (28 - LEN( RTRIM( Calender ) ) ) ) + '|'
			ELSE Calender
		END
	) AS Calender
FROM CalendarView 
ORDER BY Yr, Mth, WW
OPTION (MAXRECURSION 0)

SET LANGUAGE us_english
