USE CDC_Test
GO

declare @rc int

exec @rc = sys.sp_cdc_enable_db
select @rc
-- new column added to sys.databases: is_cdc_enabled
select name, is_cdc_enabled from sys.databases
GO
--drop table dbo.employee
create table dbo.employee
(
	id int identity not null
	, emp_name varchar(50) not null
	, salary int not null
	, constraint pk_employee primary key clustered (id)
)
GO



exec sys.sp_cdc_enable_table 
    @source_schema = 'dbo', 
    @source_name = 'employee' ,
    @role_name = NULL,
    @supports_net_changes = 1
select name, type, type_desc, is_tracked_by_cdc 
from sys.tables
where is_tracked_by_cdc = 1
GO


select o.name, o.type, o.type_desc 
from sys.objects o
join sys.schemas  s 
	on s.schema_id = o.schema_id
where s.name = 'cdc'
GO

--> CDC Tables 
select * from [cdc].[captured_columns]
select * from [cdc].[change_tables]
select * from [cdc].[index_columns]
select * from [cdc].[lsn_time_mapping]
select * from [cdc].[ddl_history]
select * from [dbo].[systranschemas]
GO


/*
--> For disable at Table level


exec sys.sp_cdc_disable_table 
  @source_schema = 'dbo', 
  @source_name = 'customer',
  @capture_instance = 'dbo_customer' -- or 'all'


--> Disable at DB 
declare @rc int
exec @rc = sys.sp_cdc_disable_db
select @rc
-- show databases and their CDC setting
select name, is_cdc_enabled from sys.databases
*/

select * from employee
select * from [cdc].[dbo_employee_CT]
GO


INSERT INTO employee(emp_name, salary)
select 'Jack Mack',789456
UNION select 'Bindo Quin',16585
UNION select 'Charlese Brened',78546
UNION select 'Depomatic Froud',63542
UNION select 'Elegent grom',45682
UNION select 'Groun Jack',89547

--UPDATE employee SET emp_name = emp_name+'_2' WHERE id = 2
 