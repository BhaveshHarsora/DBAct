/*
Date: 26-Jul-2017
BELOW T-SQL will help to find out list of database object to exists through out all the databases in underlying server in one result set.
*/


/*

*** TEST QUERY

select * from sys.objects WHERe name in (
	'dds_hubspoke_sliped', 'dds_mediumhubspoke_sliped', 'dds_microwavedata_sliped', 'dds_ndwdata_sliped', 'dds_oc_granite', 'dds_oc_sliped', 'dds_oc_spirent'
	, 'dds_oc_wo', 'gmlc_cell_esmlc', 'gmlc_cell_mlc_2g3g', 'gmlc_provisioning_data', 'gmlc_provisioning_nokia_riot_validation', 'gmlc_provisioning_riot_validation'
	, 'GMLC_SMP_ALL_CHANGES', 'KDP_WIDGET_ELEMENTS')

select * from RFP_DataMart.sys.objects WHERe (name LIKE '%dds%' OR name LIKE '%gmlc%'OR name LIKE '%kdp%')
*/


-- :: DECLARATION :: --
DECLARE @vSearchTxTbl AS TABLE (SearchTx VARCHAR(MAX));
DECLARE @vResultTbl AS TABLE (DatabaseId INT, DatabaseName VARCHAR(50), SearchedText VARCHAR(MAX), ObjectId INT, ObjectType VARCHAR(50), ObjectName VARCHAR(255));
DECLARE @vDatabaseId AS INT, @vDatabaseName AS VARCHAR(50), @vSqlTx AS VARCHAR(MAX), @vSearchTx AS VARCHAR(MAX);
-- :: DECLARATION :: --

-----------------------------------------------------------------------------------------------------------------------

--> Enter Object name here
INSERT INTO @vSearchTxTbl (SearchTx) VALUES ('dds%')
											,('gmlc%')
											,('kdp%')


-----------------------------------------------------------------------------------------------------------------------

-- :: SEARCH CODE :: --
DECLARE curDBs CURSOR 
FOR
SELECT [dbid] AS DatabaseId, [name] AS DatabaseName 
FROM master.dbo.sysdatabases 
WHERE [dbid] > 4 
AND [name] != 'ReportServer' 
AND [name] != 'ReportServerTempDB';

OPEN curDBs

FETCH NEXT FROM curDBs INTO @vDatabaseId, @vDatabaseName
WHILE @@FETCH_STATUS = 0
BEGIN

	DECLARE curSearchTx CURSOR 
	FOR
	SELECT SearchTx
	FROM @vSearchTxTbl

	OPEN curSearchTx
	FETCH NEXT FROM curSearchTx INTO @vSearchTx
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SET @vSqlTx = CONCAT('SELECT ', @vDatabaseId, ' AS DatabaseId, ''', @vDatabaseName, ''' AS DatabaseName, ''', @vSearchTx,''' AS SearchedText, a.object_id, a.type_desc, a.name FROM ', @vDatabaseName ,'.sys.objects AS a WHERE a.name LIKE ''', @vSearchTx, '''');
		
		BEGIN TRY
			PRINT @vSqlTx

			INSERT INTO @vResultTbl (DatabaseId, DatabaseName, SearchedText, ObjectId, ObjectType, ObjectName)			
			EXEC (@vSqlTx);

		END TRY
		BEGIN CATCH
			INSERT INTO @vResultTbl (DatabaseId, DatabaseName, SearchedText,  ObjectId, ObjectType, ObjectName)
			SELECT @vDatabaseId, @vDatabaseName, @vSearchTx, -1, 'Error', ERROR_MESSAGE();
		END CATCH

		--DECLARE @vID AS INT = 2, @vSqlTx2 AS VARCHAR(MAX),@vID2 AS INT = 7;
		--SET @vSqlTx2 = CONCAT('SELECT ', @vID, ', ', @vID2, ',* FROM master.dbo.sysdatabases');
		--EXEC (@vSqlTx2)

		FETCH NEXT FROM curSearchTx INTO @vSearchTx	
	END;
	CLOSE curSearchTx
	DEALLOCATE curSearchTx
	

	FETCH NEXT FROM curDBs INTO @vDatabaseId, @vDatabaseName
END;

CLOSE curDBs;
DEALLOCATE curDBs;


--> Show Result
SELECT * 
FROM @vResultTbl
ORDER BY DatabaseName, ObjectType, ObjectName;




PRINT '~ DONE ~'
GO