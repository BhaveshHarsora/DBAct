USE [master]
GO

-- Alter database to set query_store ON
ALTER DATABASE SLIPED SET QUERY_STORE = ON;

GO

ALTER DATABASE SLIPED SET QUERY_STORE(OPERATION_MODE = READ_WRITE)

GO

-- Alter database to set 2019 compatibility
ALTER DATABASE SLIPED SET COMPATIBILITY_LEVEL = 150;

GO

USE Sliped

GO

-- Alter database to set legacy cardinality estimation ON
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = ON;

GO

-- Alter database to set query optimizer hotfixe ON
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = ON;

GO
