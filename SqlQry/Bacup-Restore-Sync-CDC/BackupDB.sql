/*
* Database Script for FULL BACKUP 
* Change Database name appropriatly
*/
USE [MASTER] 
GO


ALTER DATABASE [HCDM] 
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

BACKUP DATABASE [HCDM] 
	TO  DISK = N'D:\SQL\Backup\HCDM_20160619.bak' WITH NOFORMAT
	, INIT
	,  NAME = N'HCDM-Full Database Backup'
	, SKIP
	, NOREWIND
	, NOUNLOAD
	, STATS = 10
GO

ALTER DATABASE HCDM
	SET MULTI_USER WITH ROLLBACK IMMEDIATE
GO

------------
USE MASTER
GO

BACKUP DATABASE Portal 
	TO DISK='\\fs-p-01.onlineschedule.com\SQL-Backups\ha\Portal_20220525_1231.bak'
	WITH COMPRESSION;
GO

PRINT '~ DONE ~'
GO

--------

USE master
GO

BACKUP DATABASE TrinDocs_Companion 
	TO  DISK = N'E:\Backups\CABE_SQL_VM\TrinDocs_Companion_20230826.bak' WITH NOFORMAT
	, INIT
	, NAME = N'TrinDocs_Companion-Full Database Backup'
	, SKIP
	, NOREWIND
	, NOUNLOAD
	, STATS = 10
GO