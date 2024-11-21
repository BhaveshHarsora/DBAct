select * from LockTicketGroup

select @@version, @@servername,  @@servicename
EXECUTE xp_regread
        @rootkey = 'HKEY_LOCAL_MACHINE',
        @key = 'SOFTWARE\Microsoft\Microsoft SQL Server',
        @value_name = 'InstalledInstances'

SELECT CONVERT(sysname, SERVERPROPERTY('servername'));
EXECUTE xp_regread @rootkey='HKEY_LOCAL_MACHINE',
                   @key='SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQl',
                   @value_name='MSSQLSERVER'
SELECT SERVERPROPERTY ('InstanceName')


SELECT  
    SERVERPROPERTY('ServerName') AS ServerName,  
    SERVERPROPERTY('MachineName') AS MachineName,
    CASE 
        WHEN  SERVERPROPERTY('InstanceName') IS NULL THEN ''
        ELSE SERVERPROPERTY('InstanceName')
    END AS InstanceName,
    '' as Port, --need to update to strip from Servername. Note: Assumes Registered Server is named with Port
    SUBSTRING ( (SELECT @@VERSION),1, CHARINDEX('-',(SELECT @@VERSION))-1 ) as ProductName,
    SERVERPROPERTY('ProductVersion') AS ProductVersion,  
    SERVERPROPERTY('ProductLevel') AS ProductLevel,
    SERVERPROPERTY('ProductMajorVersion') AS ProductMajorVersion,
    SERVERPROPERTY('ProductMinorVersion') AS ProductMinorVersion,
    SERVERPROPERTY('ProductBuild') AS ProductBuild,
    SERVERPROPERTY('Edition') AS Edition,
    CASE SERVERPROPERTY('EngineEdition')
        WHEN 1 THEN 'PERSONAL'
        WHEN 2 THEN 'STANDARD'
        WHEN 3 THEN 'ENTERPRISE'
        WHEN 4 THEN 'EXPRESS'
        WHEN 5 THEN 'SQL DATABASE'
        WHEN 6 THEN 'SQL DATAWAREHOUSE'
    END AS EngineEdition,  
    CASE SERVERPROPERTY('IsHadrEnabled')
        WHEN 0 THEN 'The Always On Availability Groups feature is disabled'
        WHEN 1 THEN 'The Always On Availability Groups feature is enabled'
        ELSE 'Not applicable'
    END AS HadrEnabled,
    CASE SERVERPROPERTY('HadrManagerStatus')
        WHEN 0 THEN 'Not started, pending communication'
        WHEN 1 THEN 'Started and running'
        WHEN 2 THEN 'Not started and failed'
        ELSE 'Not applicable'
    END AS HadrManagerStatus,
    CASE SERVERPROPERTY('IsSingleUser') WHEN 0 THEN 'No' ELSE 'Yes' END AS InSingleUserMode,
    CASE SERVERPROPERTY('IsClustered')
        WHEN 1 THEN 'Clustered'
        WHEN 0 THEN 'Not Clustered'
        ELSE 'Not applicable'
    END AS IsClustered,
    '' as ServerEnvironment,
    '' as ServerStatus,
    '' as Comments