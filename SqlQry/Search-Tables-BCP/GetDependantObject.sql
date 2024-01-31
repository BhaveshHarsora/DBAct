SELECT * FROM backhaul_pseudowire
Type_backhaul_pseudowire
--> Get Table Triggers
SELECT * from sys.triggers where parent_id=object_id('vendor') 

--> Get Dependant Object
select OBJECT_NAME(id) As Parent,OBJECT_NAME(depid) AS Child,* FROM sys.sysdepends 
where 1=1
and id=OBJECT_ID('usp_SLIPED_MsoGrndMstrPairChange')

--> Get Parent Object
select OBJECT_NAME(id) As Parent,OBJECT_NAME(depid) AS Child,* FROM sys.sysdepends 
where 1=1
and depid=OBJECT_ID('usp_SLIPED_MsoGrndMstrPairChange')


sp_updatestats

DECLARE @vObjectName AS VARCHAR(100);
SET @vObjectName = 'cellsite_attr' 
select DISTINCT type_desc, O.Name from sys.sql_modules as M
JOIN Sys.objects as O ON O.Object_id = M.Object_id
where 1=1
AND O.Name IN (
				select DISTINCT OBJECT_NAME(id) As Parent
				FROM sys.sysdepends 
				where 1=1
				and depid=OBJECT_ID(@vObjectName)
			  )
AND (REPLACE(M.Definition,'  ',' ') LIKE '%MERGE%' +@vObjectName+ '%')
ORDER BY type_desc, O.Name 	;



SELECT ProcName,tbl.ProcText2,LEN(tbl.ProcText2) as lentg
FROM (
SELECT RTRIM(LTRIM(so_procs.name)) AS ProcName
--,  so_tables.name as [Dependency]
, RTRIM(LTRIM(REPLACE(SUBSTRING(sc_procs.text, CHARINDEX('cellsite_attr',sc_procs.text)-100,120),'  ',' '))) AS ProcText
--, RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(sc_procs.text, CHARINDEX('cellsite_attr',sc_procs.text)-800,820),CHAR(13)+CHAR(10), ' '),'  ',' '))) AS ProcText2
, RTRIM(LTRIM(REPLACE(SUBSTRING(sc_procs.text, CHARINDEX('cellsite_attr',sc_procs.text)-800,820),'  ',' ')))AS ProcText2
FROM sysobjects so_tables  
INNER JOIN syscomments sc_procs on sc_procs.text like '%' + so_tables.name + ' %'
INNER JOIN sysobjects so_procs on sc_procs.id = so_procs.id
WHERE so_tables.type = 'U' 
AND so_procs.type = 'P'
AND so_tables.name='cellsite_attr'
) AS tbl
WHERE 1=1
--AND (ProcText2 LIKE '%INSERT INTO%' OR ProcText2 LIKE '%UPDATE%SET%' OR ProcText2 LIKE '%DELETE%' OR ProcText2 LIKE '%MERGE%USING%')
ORDER BY 1,2


SELECT * FROM backhaul as s
join Containstable('backhaul','utran_site_id_tx',N'U4A') as c on c.id = s.id

SELECT * 
from 
(select 'aaabbcccdd' as txt) AS t
where txt LIKE ('%bb%','dd')



select DISTINCT type_desc, O.Name from sys.sql_modules as M
JOIN Sys.objects as O ON O.Object_id = M.Object_id
where 1=1
AND O.name  = 'usp_FromEdw_CellsiteUpdate'
AND REPLACE(M.Definition,'  ',' ') LIKE '%MERGE%cellsite_attr%'

trg_backhaul_ad
trg_backhaul_aiu
trg_backhaul_au
trg_cellsite_attr_au_colaud
trg_cellsite_nid_aiu


select DISTINCT OBJECT_NAME(id) As Parent
FROM sys.sysdepends 
where 1=1
and depid=OBJECT_ID('cellsite_attr' )

sp_recompile 'usp_FromEdw_CellsiteUpdate'