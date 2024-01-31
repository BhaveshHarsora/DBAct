/*
Date: 4/24/2018

Specifications of Different Date Format
*/

SELECT CONVERT(VARCHAR(6), GETDATE(), 112) AS DTFormat112

SELECT CONVERT(VARCHAR, GETDATE(), 100) AS DTFormat100		--Apr 26 2018  6:18PM
	, CONVERT(VARCHAR(30), GETDATE(), 101) AS DTFormat101	--04/26/2018
	, CONVERT(VARCHAR(30), GETDATE(), 102) AS DTFormat102	--2018.04.26
	, CONVERT(VARCHAR(30), GETDATE(), 103) AS DTFormat103	--26/04/2018
	, CONVERT(VARCHAR(30), GETDATE(), 104) AS DTFormat104	--26.04.2018
	, CONVERT(VARCHAR(30), GETDATE(), 105) AS DTFormat105	--26-04-2018
	, CONVERT(VARCHAR(30), GETDATE(), 106) AS DTFormat106	--26 Apr 2018
	, CONVERT(VARCHAR(30), GETDATE(), 107) AS DTFormat107	--Apr 26, 2018
	, CONVERT(VARCHAR(30), GETDATE(), 108) AS DTFormat108	--18:18:31
	, CONVERT(VARCHAR(30), GETDATE(), 109) AS DTFormat109	--Apr 26 2018  6:18:31:930PM
	, CONVERT(VARCHAR(30), GETDATE(), 110) AS DTFormat110	--04-26-2018
	, CONVERT(VARCHAR(30), GETDATE(), 111) AS DTFormat111	--2018/04/26
	, CONVERT(VARCHAR(30), GETDATE(), 112) AS DTFormat112	--20180426
	, CONVERT(VARCHAR(30), GETDATE(), 113) AS DTFormat113	--26 Apr 2018 18:18:31:930
	, CONVERT(VARCHAR(30), GETDATE(), 114)  AS DTFormat114	--18:18:31:930
	, CONVERT(VARCHAR(30), GETDATE(), 120)  AS DTFormat120	--2018-04-26 18:18:31
	, CONVERT(VARCHAR(30), GETDATE(), 121)  AS DTFormat121	--2018-04-26 18:18:31.930
	, CONVERT(VARCHAR(12), DATEADD(ms, DATEDIFF(ms, [restore_date], GETDATE()), 0), 114)  -- SEE ELAPCED TIME

------------

--> Time Duration

ALTER TABLE TableName 
	ADD ExecDuration AS CONVERT(VARCHAR(12), DATEADD(ms, DATEDIFF(ms, StartDT, EndDT), 0), 114)

------------

-- First Day Of Current Week.
select CONVERT(varchar,dateadd(week,datediff(week,0,getdate()),0),106)

-- Last Day Of Current Week.
select CONVERT(varchar,dateadd(week,datediff(week,0,getdate()),6),106)

-- First Day Of Last week.
select CONVERT(varchar,DATEADD(week,datediff(week,7,getdate()),0),106)

-- Last Day Of Last Week.
select CONVERT(varchar,dateadd(week,datediff(week,7,getdate()),6),106)

-- First Day Of Next Week.
select CONVERT(varchar,dateadd(week,datediff(week,0,getdate()),7),106)

-- Last Day Of Next Week.
select CONVERT(varchar,dateadd(week,datediff(week,0,getdate()),13),106)


-- First Day Of Current Month.
select CONVERT(varchar,dateadd(d,-(day(getdate()-1)),getdate()),106)

-- Last Day Of Current Month.
select CONVERT(varchar,dateadd(d,-(day(dateadd(m,1,getdate()))),dateadd(m,1,getdate())),106)

-- In this Example Works on Only date is 31. and remaining days are not.
-- First Day Of Last Month.
select CONVERT(varchar,dateadd(d,-(day(dateadd(m,-1,getdate()-2))),dateadd(m,-1,getdate()-1)),106)

-- Last Day Of Last Month.
select CONVERT(varchar,dateadd(d,-(day(getdate())),getdate()),106)

-- First Day Of Next Month.
select CONVERT(varchar,dateadd(d,-(day(dateadd(m,1,getdate()-1))),dateadd(m,1,getdate())),106)

-- Last Day Of Next Month.
select CONVERT(varchar,dateadd(d,-(day(dateadd(m,2,getdate()))),DATEADD(m,2,getdate())),106)

-- First Day Of Current Year.
select CONVERT(varchar,dateadd(year,datediff(year,0,getdate()),0),106)


-- Last Day Of Current Year.
select CONVERT(varchar,dateadd(ms,-2,dateadd(year,0,dateadd(year,datediff(year,0,getdate())+1,0))),106)

-- First Day of Last Year.
select CONVERT(varchar,dateadd(year,datediff(year,0,getdate())-1,0),106)

-- Last Day Of Last Year.
select CONVERT(varchar,dateadd(ms,-2,dateadd(year,0,dateadd(year,datediff(year,0,getdate()),0))),106)


-- First Day Of Next Year. 
select CONVERT(varchar,dateadd(YEAR,DATEDIFF(year,0,getdate())+1,0),106)


-- Last Day Of Next Year.
select CONVERT(varchar,dateadd(ms,-2,dateadd(year,0,dateadd(year,datediff(year,0,getdate())+2,0))),106)


------------

--> Elapsed time text.
select case 
		when CAST(LEFT(CONVERT(VARCHAR(5), DATEADD(ms, DATEDIFF(ms, AuditDate, GETDATE()), 0), 108), 2) AS INT)/24 > 0 
			then CAST(CAST(LEFT(CONVERT(VARCHAR(5), DATEADD(ms, DATEDIFF(ms, AuditDate, GETDATE()), 0), 108), 2) AS INT)/24 as varchar) + ' day(s) ' + CAST(CAST(LEFT(CONVERT(VARCHAR(5), DATEADD(ms, DATEDIFF(ms, AuditDate, GETDATE()), 0), 108), 2) AS INT)%24 as varchar) + ' Hrs. ' + CAST(CAST(RIGHT(CONVERT(VARCHAR(5), DATEADD(ms, DATEDIFF(ms, AuditDate, GETDATE()), 0), 108), 2) AS INT) as varchar) + ' Min. Ago'
		when CAST(LEFT(CONVERT(VARCHAR(5), DATEADD(ms, DATEDIFF(ms, AuditDate, GETDATE()), 0), 108), 2) AS INT) > 0 
			then CAST(CAST(LEFT(CONVERT(VARCHAR(5), DATEADD(ms, DATEDIFF(ms, AuditDate, GETDATE()), 0), 108), 2) AS INT)%24 as varchar) + ' Hrs. ' + CAST(CAST(RIGHT(CONVERT(VARCHAR(5), DATEADD(ms, DATEDIFF(ms, AuditDate, GETDATE()), 0), 108), 2) AS INT) as varchar) + ' Min. Ago'
		when CAST(RIGHT(CONVERT(VARCHAR(5), DATEADD(ms, DATEDIFF(ms, AuditDate, GETDATE()), 0), 108), 2) AS INT) > 0 
			then CAST(CAST(RIGHT(CONVERT(VARCHAR(5), DATEADD(ms, DATEDIFF(ms, AuditDate, GETDATE()), 0), 108), 2) AS INT) as varchar) + ' Min. Ago'			
		else CONVERT(VARCHAR(5), DATEADD(ms, DATEDIFF(ms, AuditDate, GETDATE()), 0), 108)
	END AS ElpStr		 
	
	
------------
