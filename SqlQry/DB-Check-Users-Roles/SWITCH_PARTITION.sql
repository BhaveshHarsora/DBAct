/*
Date 8 Dec 2018
Switch Partition example 
*/

--> 1. SWITCH FROM NON-PARTITIONED TO NON-PARTITIONED TABLE
BEGIN 

	-- Drop objects if they already exist
	IF EXISTS (SELECT * FROM sys.tables WHERE name = N'SalesSource')
	  DROP TABLE SalesSource;
	IF EXISTS (SELECT * FROM sys.tables WHERE name = N'SalesTarget')
	  DROP TABLE SalesTarget;

	-- Create the Non-Partitioned Source Table (Heap) on the [PRIMARY] filegroup
	CREATE TABLE SalesSource (
	  SalesDate DATE,
	  Quantity INT
	) ON [PRIMARY];

	-- Insert test data (10 00 000) 1 million rows
	INSERT INTO SalesSource(SalesDate, Quantity)
	select DATEADD(DAY,dates.n-1,'2012-01-01') AS SalesDate, qty.n AS Quantity
	FROM (select top 1000 ROW_NUMBER() over (order by message_id) as n from sys.messages ) as dates
	CROSS join (select top 1000 ROW_NUMBER() over (order by message_id) as n from sys.messages ) as qty


	-- Create the Non-Partitioned Target Table (Heap) on the [PRIMARY] filegroup
	CREATE TABLE SalesTarget (
	  SalesDate DATE,
	  Quantity INT
	) ON [PRIMARY];
 
	-- Verify row count before switch
	SELECT COUNT(*) FROM SalesSource; -- 1000000 rows
	SELECT COUNT(*) FROM SalesTarget; -- 0 rows
 
	-- Turn on statistics
	SET STATISTICS TIME ON;
 
	-- Is it really that fast...?
	ALTER TABLE SalesSource SWITCH TO SalesTarget;
	-- YEP! SUPER FAST!
 
	-- Turn off statistics
	SET STATISTICS TIME OFF;
 
	-- Verify row count after switch
	SELECT COUNT(*) FROM SalesSource; -- 0 rows
	SELECT COUNT(*) FROM SalesTarget; -- 1000000 rows
 
	-- If we try to switch again we will get an error:
	ALTER TABLE SalesSource SWITCH TO SalesTarget;
	-- Msg 4905, ALTER TABLE SWITCH statement failed. The target table 'SalesTarget' must be empty.
 
	-- But if we try to switch back to the now empty Source table, it works:
	ALTER TABLE SalesTarget SWITCH TO SalesSource;
	-- (...STILL SUPER FAST!) 

END;


