use portal
GO

;with t_dbo as (
	select schema_name(t.schema_id) as SchemaName, name AS ObjectName, t.object_id, t.type_desc As ObjectType
	from sys.objects as t
	where t.schema_id = 1
	and is_ms_shipped = 0
)
, t_nondbo as (
	select schema_name(t.schema_id) as SchemaName, name AS ObjectName, t.object_id, t.type_desc AS ObjectType
	from sys.objects as t
	where t.schema_id != 1
	and is_ms_shipped = 0
)
select a.ObjectType, a.SchemaName, a.[object_id], a.ObjectName
from t_dbo as a
left join t_nondbo as b
	on a.ObjectName = b.ObjectName
where b.object_id is null
ORDER by a.ObjectType, a.SchemaName, a.ObjectName

-------------

select snm, [SQL_SCALAR_FUNCTION], [SQL_STORED_PROCEDURE], [USER_TABLE], [VIEW], [SQL_TRIGGER]
from (
	select schema_name(schema_id) as snm, [type_desc] as typdesc, count(1) as cnt 
	FROM sys.objects with(nolock)
	where 1=1
	--and schema_id =1 
	and type in ('U', 'V', 'FN', 'P', 'TR')
	GROUP by schema_name(schema_id), [type_desc]
) as t
PIVOT (	
	MAX(cnt) FOR typdesc in ([SQL_SCALAR_FUNCTION], [SQL_STORED_PROCEDURE], [USER_TABLE], [VIEW],[SQL_TRIGGER])
) as p
order by 1


-------------

select * from sys.schemas
select * from sys.tables where schema_id=1
select * from sys.views where schema_id=1
select * from sys.objects where schema_id=1 and type = 'FN'
select * from sys.procedures where schema_id=1 

select schema_name(schema_id), type, type_desc, count(1) as cnt 
FROM sys.objects with(nolock)
where 1=1
--and schema_id =1 
and type in ('U', 'V', 'FN', 'P')
GROUP by schema_name(schema_id),type, type_desc
order by 1, 2

select object_id('dbo.td_assignments')
	,object_id('TheOffice.td_assignments')
	,object_id('APIR.td_assignments')
	,object_id('Viejas.td_assignments')
	,object_id('TwinRiver.td_assignments')
	,object_id('CosmopolitanLV.td_assignments')
	



