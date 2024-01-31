select distinct DATA_TYPE from INFORMATION_SCHEMA.COLUMNS



/* Table wise Record count */
select 'select ''' + name +''' AS TableNAme,  count(1) AS RecCount from [' + name + '] UNION ALL  ',  * 
from sys.tables t
where 1=1
--AND DATA_TYPE in ('varchar') 



/* Table wise Max len and Record count */
select 'select ''' + TABLE_NAME +''' AS TableNAme,  ''' + COLUMN_NAME +''', ''' + DATA_TYPE +''', ISNULL(max(len([' + COLUMN_NAME + '])), '''') As RecordMaxLen, count(1) AS RecCount from [' + TABLE_NAME + '] UNION ALL  ',  * 
from INFORMATION_SCHEMA.COLUMNS 
where 1=1
AND DATA_TYPE in ('varchar') 



select 'select ''' + TABLE_NAME +''' AS TableNAme,  ''' + COLUMN_NAME +''', ''' + DATA_TYPE +''', count(1) AS RecCount from ' + TABLE_NAME + ' UNION ALL
 ',  * 
from INFORMATION_SCHEMA.COLUMNS 
where DATA_TYPE in ('sql_variant', 'money', 'text', 'varbinary',  'smallmoney') 







select top 100 * from INFORMATION_SCHEMA.COLUMNS where DATA_TYPE in ('nvarchar')

select max(len(cast(CustomFieldList as nvarchar(max))))   from DA_Resident_Custom_Fields_Lookup

select 'dcf901_referral' AS TableNAme,  'referral_desc', 'nvarchar', ISNULL(max(len(referral_desc)), '') As RecordMaxLen, count(1) AS RecCount from dcf901_referral UNION ALL  


select 'psa900_PatientFormSubmissionDetail' AS TableNAme,  'MDS3_XML', 'text', count(1) AS RecCount from psa900_PatientFormSubmissionDetail;

