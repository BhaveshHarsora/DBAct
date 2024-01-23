/*
Date 23 Jan 2020
Below T-SQL will pritn/execute UPDATE STATISTICS for tables wherever its required based on sampling
*/
SET NOCOUNT ON;

DECLARE @vExecFlg AS BIT, @vPrintFlg AS BIT;

SET @vPrintFlg = 1;		--> Set the Print flag True, if wanted to pritn executable statemens in message window.
SET @vExecFlg = 0;		--> Set the execute flag True, if need to apply changes into DB

--------------------------------------------------------------------------------------------------

drop table if exists #stats_table

create table #stats_table (
    DatabaseName varchar(256),
    SchemaName varchar(256),
    TableName varchar(256),
    NumberOfRows bigint,
    Min_stats_date datetime,
    Rowmodctr bigint
)

insert into #stats_table(
     DatabaseName
    ,SchemaName
    ,TableName
    ,NumberOfRows
    ,Min_stats_date
    ,Rowmodctr
) exec sp_MSforeachdb
'USE [?]
IF ( DB_ID(db_name ()) > 4 
        and DB_Name() not like ''ReportSer%''
        and DATABASEPROPERTYEX ( db_name (), ''Status'') = ''online''
        and DATABASEPROPERTYEX ( db_name() , ''IsInStandBy'') = 0
        and DATABASEPROPERTYEX(db_name(), ''Updateability'')=''READ_WRITE'')
BEGIN
    declare @threshold_rows_updated int = 1000
    select
         db_name() as Databasename
        ,ss.name as SchemaName
        ,so.name as TableName
        ,size.numberofrows as NumberOfRows
        ,st.min_stats_date
        ,rowmod.rowmodctr
    from sys.objects so
        inner join (
            select
                 si.id as object_id
                ,SUM(sp.rows) as numberofrows
            from sys.sysindexes si
                inner join sys.partitions sp on si.id=sp.object_id and si.indid=sp.index_id
            where si.indid in (0,1)
            group by si.id
        ) size on size.object_id = so.object_id 
        inner join sys.schemas ss on so.schema_id=ss.schema_id
        inner join (
            select
                id
                ,max(rowmodctr) as rowmodctr
            from sys.sysindexes
            where name is not null
            group by id
         ) rowmod on rowmod.id=so.object_id
         inner join (
            select
                 st.object_id
                ,MIN(isnull(STATS_DATE(st.object_id, st.stats_id),getdate())) as min_stats_date
            from sys.stats st
            group by st.object_id
         ) st on so.object_id=st.object_id
    where (rowmod.rowmodctr > @threshold_rows_updated or ISNULL(st.min_stats_date, ''19000101'')<=DATEADD(hour,-24,GETDATE()))
      and so.type=''U''
END'

declare Command cursor for
select Databasename, SchemaName, TableName, NumberOfrows from #stats_table;
open command;

declare
   @DatabaseName varchar(256)
  ,@SchemaName varchar(256)
  ,@TableName varchar(256)
  ,@NumberOfRows bigint
  ,@sample varchar(256)
  ,@ErrorMsg varchar(500)
  ,@sqlstatement varchar(8000) = ''

fetch next from command into @DatabaseName,@SchemaName,@TableName,@NumberOfRows
WHILE (@@FETCH_STATUS <> -1)
begin
    select @sample=
    case
           when @NumberOfRows between 0 and 10000 then ' with fullscan'
           when @NumberOfRows between 10000 and 100000 then ' with sample 30 percent'
           when @NumberOfRows between 100000 and 1000000 then ' with sample 10 percent'
           when @NumberOfRows between 1000000 and 10000000 then ' with sample 1 percent'
           when @NumberOfRows between 10000000 and 100000000 then ' with sample ' + convert(varchar(20),@NumberOfRows/300) + ' rows'
           when @NumberOfRows > 100000000 then ' with sample ' + convert(varchar(20),@NumberOfRows/1000) + ' rows'
    end
    set @sqlstatement = 'UPDATE STATISTICS ['+ @DatabaseName +'].['+@SchemaName+'].['+@TableName+'] '+@sample
    begin try
        IF @vPrintFlg = 1	PRINT (@sqlstatement);
        IF @vExecFlg = 1	EXECUTE (@sqlstatement);
    end try

    begin catch
        SET @ErrorMsg = error_message()
        Print @ErrorMsg
    end catch

    fetch next from command into @DatabaseName,@SchemaName,@TableName,@NumberOfRows
end;
close command;
deallocate command

drop table if exists #stats_table

