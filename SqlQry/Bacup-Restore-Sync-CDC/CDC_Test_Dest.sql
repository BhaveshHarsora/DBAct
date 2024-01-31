/*
Date: 15 Jul 2019
TEst queries for Destination  DB
*/
USE Stage_CDC
GO


--DROP TABLE [dbo].[cdc_states] 
CREATE TABLE [dbo].[cdc_states] 
 ([name] [nvarchar](256) NOT NULL, 
 [state] [nvarchar](256) NOT NULL) ON [PRIMARY]
GO
 
CREATE UNIQUE NONCLUSTERED INDEX [cdc_states_name] ON 
 [dbo].[cdc_states] 
 ( [name] ASC ) 
 WITH (PAD_INDEX  = OFF) ON [PRIMARY]
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

/* same schema stage table to be created at */
--drop table dbo.stg_employee
create table dbo.stg_employee
(
	id int identity not null
	, emp_name varchar(50) not null
	, salary int not null
	, dml_flg int not null
	, constraint pk_stg_employee primary key clustered (id)
)
GO
--truncate table employee_2
select * from stg_employee
select *  from employee 
select * from cdc_states
select * from employee_2
 


declare @pDataExists as bit
EXEC Stage_CDC.dbo.usp_MCK_IsDataExists @pDBNm = 'Stage_CDC', @pTblNm = 'employee_2', @pDataExists = @pDataExists OUTPUT;
select @pDataExists



