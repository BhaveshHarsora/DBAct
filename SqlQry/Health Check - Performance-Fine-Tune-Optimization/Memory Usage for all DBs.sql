/*
BH20230201 : T-SQL to Get Memory Usage of each Databases 

TempDB
https://www.sqlshack.com/how-to-detect-and-prevent-unexpected-growth-of-the-tempdb-database/
*/
USe master
GO

DECLARE @vDbName AS VARCHAR(255), @vSqlTx AS NVARCHAR(MAX);
DECLARE @tTmp AS TABLE (
	database_name	VARCHAR(255)
	, database_size	VARCHAR(255)
	, unallocated_space VARCHAR(255)
	, reserved	VARCHAR(255)
	, data	VARCHAR(255)
	, index_size	VARCHAR(255)
	, unused VARCHAR(255)
)


DECLARE curDBs CURSOR LOCAL FAST_FORWARD FOR
select name AS DbName
from sys.databases 

OPEN curDBs;
FETCH curDBs INTO @vDbName;

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @vSqlTx = CONCAT('
	USE [', @vDbName ,'];
	EXEC sp_spaceused 
		 @updateusage = ''FALSE'', 
		 @mode = ''ALL'', 
		 @oneresultset = ''1''; ');
	BEGIN TRY
		INSERT INTO @tTmp (database_name, database_size, unallocated_space, reserved, data, index_size, unused)
		EXEC (@vSqlTx)
	END TRY
	BEGIN CATCH
		PRINT CONCAT('Unable to get data for Database [', @vDbName ,']');
	END CATCH	
	 	
	FETCH curDBs INTO @vDbName;
END;

CLOSE curDBs
DEALLOCATE curDBs

SELECT * FROM @tTmp;

GO

-----------------

--EXEC sp_spaceused 
--     @updateusage = 'FALSE', 
--     @mode = 'ALL', 
--     @oneresultset = '1', 
--     @include_total_xtp_storage = '1';
--GO