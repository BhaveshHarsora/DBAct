CREATE DATABASE FileSearchTest
ON PRIMARY
(
    NAME = N'FileSearchTest',
    FILENAME = N'C:\SQLData\DBFiles\FileSearchTest.mdf'
),
FILEGROUP FilestreamFG CONTAINS FILESTREAM
(
    NAME = MyFileStreamData,
    FILENAME= 'C:\SQLData\TableFiles'
)
LOG ON
(
    NAME = N'FileSearchTest_Log',
    FILENAME = N'C:\SQLData\DBFiles\FileSearchTest_log.ldf'
)
WITH FILESTREAM
(
    NON_TRANSACTED_ACCESS = FULL,
    DIRECTORY_NAME = N'FileTable'
)
GO

USE FileSearchTest
go

CREATE TABLE DBDocuments AS FileTable
WITH
(
    FileTable_Directory = 'DBDocuments',
    FileTable_Collate_Filename = database_default
);
GO