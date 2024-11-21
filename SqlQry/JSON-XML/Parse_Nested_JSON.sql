/*
Date 9 Nov 2021
SQL Server OPENJSON read nested json

https://stackoverflow.com/questions/37218254/sql-server-openjson-read-nested-json
*/

declare @json nvarchar(max)
set @json = '
[
   {
      "IdProject":"97A76363-095D-4FAB-940E-9ED2722DBC47",
      "Name":"Test Project",
      "structures":[
         {
            "IdStructure":"CB0466F9-662F-412B-956A-7D164B5D358F",
            "IdProject":"97A76363-095D-4FAB-940E-9ED2722DBC47",
            "Name":"Test Structure",
            "BaseStructure":"Base Structure",
            "DatabaseSchema":"dbo",
            "properties":[
               {
                  "IdProperty":"618DC40B-4D04-4BF8-B1E6-12E13DDE86F4",
                  "IdStructure":"CB0466F9-662F-412B-956A-7D164B5D358F",
                  "Name":"Test Property 2",
                  "DataType":1,
                  "Precision":0,
                  "Scale":0,
                  "IsNullable":false,
                  "ObjectName":"Test Object",
                  "DefaultType":1,
                  "DefaultValue":""
               },
               {
                  "IdProperty":"FFF433EC-0BB5-41CD-8A71-B5F09B97C5FC",
                  "IdStructure":"CB0466F9-662F-412B-956A-7D164B5D358F",
                  "Name":"Test Property 1",
                  "DataType":1,
                  "Precision":0,
                  "Scale":0,
                  "IsNullable":false,
                  "ObjectName":"Test Object",
                  "DefaultType":1,
                  "DefaultValue":""
               }
            ]
         }
      ]
   }
]';

select
    Projects.IdProject, Projects.Name as NameProject,
    Structures.IdStructure, Structures.Name as NameStructure, Structures.BaseStructure, Structures.DatabaseSchema,
    Properties.*    
from   openjson (@json)
with
(
    IdProject uniqueidentifier,
    Name nvarchar(100),
    structures nvarchar(max) as json
)
as Projects
cross apply openjson (Projects.structures)
with
(
    IdStructure uniqueidentifier,
    Name nvarchar(100),
    BaseStructure nvarchar(100),
    DatabaseSchema sysname,
    properties nvarchar(max) as json
) as Structures
cross apply openjson (Structures.properties)
with
(
    IdProperty uniqueidentifier,
    NamePreoperty nvarchar(100) '$.Name',
    DataType int,
    [Precision] int,
    [Scale] int,
    IsNullable bit,
    ObjectName nvarchar(100),
    DefaultType int,
    DefaultValue nvarchar(100)
)
as Properties