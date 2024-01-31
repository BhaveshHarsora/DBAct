USE Stage_CDC
GO

select * 
from Stage_CDC.dbo.employee
 

select *
from sys.columns AS z 
where object_name(z.object_id)='employee'

declare @vUpdSql AS VARCHAR(MAX);

set @vUpdSql = (select STUFF(CONVERT(VARCHAR(MAX), concat(', z.',z.name,' = a.',a.name,' ')),1,1,'')
from sys.columns AS z 
JOIN sys.columns AS a
	ON 1=1
	and object_name(z.object_id)='employee'
	and object_name(a.object_id)='stg_employee'	
	and a.name = z.name
where 1=1
and ISNULL(z.is_identity, 0) = 0
order by z.column_id
for xml path('')
)


select @vUpdSql

 z.emp_name = a.emp_name  z.salary = a.salary 



update z
	set z.emp_name = a.emp_name
		, z.salary = a.salary
--select * 
from Stage_CDC.dbo.employee AS z
JOIN Stage_CDC.dbo.stg_employee AS a
	ON z.id = a.id
WHERE a.dml_flg = 2



delete z
--select * 
from Stage_CDC.dbo.employee AS z
JOIN Stage_CDC.dbo.stg_employee AS a
	ON z.id = a.id
WHERE a.dml_flg = 3

GO





declare
	@pSrcDBNm VARCHAR(100)='Stage_CDC',
	@pSrcTblNm VARCHAR(100)='stg_employee',
	@pTrgDBNm VARCHAR(100)='Stage_CDC',
	@pTrgTblNm VARCHAR(100)='employee';
DECLARE @vUpdSql AS NVARCHAR(MAX), @vSqlTx AS NVARCHAR(MAX), @vParamSqlTx AS NVARCHAR(MAX), @vDataExists AS BIT;

SET @vParamSqlTx = ' @vDataExists AS BIT OUTPUT ';
SET @vSqlTx = CONCAT('IF EXISTS(SELECT 1 FROM ',@pTrgDBNm,'.dbo.',@pTrgTblNm,')		SET @vDataExists = 1; ELSE SET @vDataExists = 0; ');
EXEC sys.sp_executesql @vSqlTx, @vParamSqlTx, @vDataExists = @vDataExists OUTPUT
SELECT @vDataExists

EXEC dbo.usp_MCK_IsDataExists @pDBNm = @pTrgDBNm, @pTblNm = @pTrgTblNm, @pDataExists = @vDataExists OUTPUT;
SELECT  @vDataExists





SET @vSqlTx = CONCAT(
					' SET @vUpdSql = STUFF(CONVERT(VARCHAR(MAX)
											,  (select concat('', z.'',z.name,'' = a.'',a.name,'' '')
													from ',@pTrgDBName,N'.sys.columns AS z 
													JOIN ',@pSrcDBName,N'.sys.columns AS a
														ON 1=1
														and object_name(z.object_id)=''',@pTrgTblNm, N'''
														and object_name(a.object_id)=''',@pSrcTblNm, N'''	
														and a.name = z.name
													where 1=1
													and ISNULL(z.is_identity, 0) = 0
													order by z.column_id
													for xml path('''') )
											), 1, 1, '''')'
					)
	SET @vParamSqlTx = ' @vUpdSql AS NVARCHAR(MAX) OUTPUT '
	EXEC sys.sp_executesql @vSqlTx, @vParamSqlTx, @vUpdSql = @vUpdSql OUTPUT;
print @vSqlTx
SELECT @vUpdSql

 
 