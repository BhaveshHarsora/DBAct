drop table if exists #MqConfig ;

create table #MqConfig
(
	Environment VARCHAR(50)
	, ConfigKey VARCHAR(255)
	, ConfigValue NVARCHAR(MAX)
);

insert into #MqConfig (Environment,ConfigKey,ConfigValue)
select 'dev', 'username', 'u1'
union select 'dev', 'password', 'p1'
union select 'dev', 'hostname', 'h1'
union select 'dev', 'queueName', 'q1'

select * from #MqConfig;

declare @vcolCSV as varchar(max), @vSqlTx as nvarchar(max), @vParamTx as nvarchar(max), @vJsonTx as nvarchar(max);

set @vcolCSV = stuff(convert(varchar(max), 
		(select concat(',[',  ConfigKey,']')
		from #MqConfig
		where Environment = 'Dev'
		for XML path(''))),1,1,'');

print @vcolCSV

set @vParamTx = ' @vJsonTx nvarchar(max) output '
set @vSqlTx = concat('
	set @vJsonTx = convert(nvarchar(max), 
						(select ', @vcolCSV, '
						from (
							select ConfigKey,ConfigValue
							from #MqConfig
						) as t
						PIVOT (
							max(ConfigValue) for ConfigKey in (', @vcolCSV, ')
						) as p
						for json path, without_array_wrapper) ); ');

exec sys.sp_executesql @vSqlTx, @vParamTx, @vJsonTx = @vJsonTx OUTPUT;

select @vJsonTx;




