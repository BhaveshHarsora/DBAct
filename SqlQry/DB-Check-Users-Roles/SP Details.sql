/*
BH20230926 : Query to find details of Definitions of Database objects, e.g. proceudres, functions, etc.
*/
GO
SELECT 
    SM.object_id                                                                                                                        AS O_ID
   ,OBJECT_NAME(SM.object_id)                                                                                                           AS O_NAME
   ,LEN(SM.definition) - (LEN(REPLACE(SM.definition,NCHAR(10),N'')))                                                                    AS O_NUMBER_OF_LINES
   ,LEN(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SM.definition,NCHAR(32),N''),NCHAR(9),N''),NCHAR(45),N''),NCHAR(10),N''),NCHAR(13),N'')) AS O_NUMBER_OF_CHARS
   ,(SELECT COUNT(*) FROM sys.sql_expression_dependencies SD 
     WHERE SD.referencing_id = SM.object_id
     AND OBJECT_NAME(SD.referencing_id) NOT LIKE N'DATAVIEW_%'
     AND SD.referenced_database_name IS NULL)                                                                                           AS O_INTERNAL_DEPENDENCIES
   ,(SELECT COUNT(*) FROM sys.sql_expression_dependencies SD 
     WHERE SD.referencing_id = SM.object_id
     AND SD.referenced_database_name IS NOT NULL)                                                                                       AS O_EXTERNAL_DEPENDENCIES
   ,(SELECT COUNT(*) FROM sys.sql_expression_dependencies SD 
     WHERE SD.referenced_id = SM.object_id)                                                                                             AS O_DEPENDENTS
   ,OBJECTPROPERTY(SM.object_id,'IsInlineFunction')                                                                                     AS O_IsInlineFunction
   ,OBJECTPROPERTY(SM.object_id,'IsProcedure')                                                                                          AS O_IsProcedure
   ,OBJECTPROPERTY(SM.object_id,'IsScalarFunction')                                                                                     AS O_IsScalarFunction
   ,ISNULL(OBJECTPROPERTY(SM.object_id,'IsSchemaBound'),0)                                                                              AS O_IsSchemaBound
   ,OBJECTPROPERTY(SM.object_id,'IsTableFunction')                                                                                      AS O_IsTableFunction
   ,OBJECTPROPERTY(SM.object_id,'IsTrigger')                                                                                            AS O_IsTrigger
   ,OBJECTPROPERTY(SM.object_id,'IsView')                                                                                               AS O_IsView
   ,LEN(SM.definition) - (LEN(REPLACE(SM.definition,NCHAR(45),N'')))                                                                    AS O_NUMBER_OF_HYPHEN
   ,LEN(SM.definition) - (LEN(REPLACE(SM.definition,NCHAR(42),N'')))                                                                    AS O_NUMBER_OF_ASTERISK
   ,LEN(SM.definition) - (LEN(REPLACE(SM.definition,NCHAR(59),N'')))                                                                    AS O_NUMBER_OF_SEMICOLON
   ,LEN(SM.definition) - (LEN(REPLACE(SM.definition,NCHAR(58),N'')))                                                                    AS O_NUMBER_OF_COLON
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'JOIN',N'')))) * (1.0 / (LEN(N'JOIN') + 0.0)))                            AS O_NUMBER_OF_JOIN
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'DISTINCT',N'')))) * (1.0 / (LEN(N'DISTINCT') + 0.0)))                    AS O_NUMBER_OF_DISTINCT
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'NOLOCK',N'')))) * (1.0 / (LEN(N'NOLOCK') + 0.0)))                        AS O_NUMBER_OF_NOLOCK
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'READ UNCOMMITTED',N'')))) * (1.0 / (LEN(N'READ UNCOMMITTED') + 0.0)))    AS O_NUMBER_OF_ISOLATION_READ_UNCOMMITTED
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'CURSOR',N'')))) * (1.0 / LEN(N'CURSOR')))                                AS O_NUMBER_OF_CURSOR
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'WHILE',N'')))) * (1.0 / LEN(N'WHILE')))                                  AS O_NUMBER_OF_WHILE
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'TABLE',N'')))) * (1.0 / LEN(N'TABLE')))                                  AS O_NUMBER_OF_TABLE
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'@@IDENTITY',N'')))) * (1.0 / LEN(N'@@IDENTITY')))                        AS O_NUMBER_OF_@@IDENTITY
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'SCOPE_IDENTITY',N'')))) * (1.0 / LEN(N'SCOPE_IDENTITY')))                AS O_NUMBER_OF_SCOPE_IDENTITY
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'READUNCOMMITTED',N'')))) * (1.0 / LEN(N'READUNCOMMITTED')))              AS O_NUMBER_OF_READUNCOMMITED
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'WAITFOR',N'')))) * (1.0 / LEN(N'WAITFOR')))                              AS O_NUMBER_OF_WAITFOR
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'ROWCOUNT',N'')))) * (1.0 / LEN(N'ROWCOUNT')))                            AS O_NUMBER_OF_ROWCOUNT
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'EXEC ',N'')))) * (1.0 / LEN(N'EXEC') + 1))                               AS O_NUMBER_OF_EXEC 
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'sp_executesql',N'')))) * (1.0 / LEN(N'sp_executesql')))                  AS O_NUMBER_OF_sp_executesql 
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'FASTFIRSTROW',N'')))) * (1.0 / LEN(N'FASTFIRSTROW')))                    AS O_NUMBER_OF_FASTFIRSTROW  
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'COMPUTE',N'')))) * (1.0 / LEN(N'COMPUTE')))                              AS O_NUMBER_OF_COMPUTE  
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'*=',N'')))) * (1.0 / LEN(N'*='))) +
    CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'=*',N'')))) * (1.0 / LEN(N'=*')))                                        AS O_NUMBER_OF_OLD_JOIN  
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'text',N'')))) * (1.0 / LEN(N'text')))                                    AS O_NUMBER_OF_text  
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'ntext',N'')))) * (1.0 / LEN(N'ntext')))                                  AS O_NUMBER_OF_ntext  
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'image',N'')))) * (1.0 / LEN(N'image')))                                  AS O_NUMBER_OF_image  
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'.sys',N'')))) * (1.0 / LEN(N'.sys')))                                    AS O_NUMBER_OF_sys  
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'OPENQUERY',N'')))) * (1.0 / LEN(N'OPENQUERY')))                          AS O_NUMBER_OF_OPENQUERY  
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'OPENROWSET',N'')))) * (1.0 / LEN(N'OPENROWSET')))                        AS O_NUMBER_OF_OPENROWSET  
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'CONVERT',N'')))) * (1.0 / LEN(N'CONVERT')))                              AS O_NUMBER_OF_CONVERT  
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'CAST',N'')))) * (1.0 / LEN(N'CAST')))                                    AS O_NUMBER_OF_CONVERT  
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'OUTPUT',N'')))) * (1.0 / LEN(N'OUTPUT')))                                AS O_NUMBER_OF_OUTPUT  
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'READPAST',N'')))) * (1.0 / LEN(N'READPAST')))                            AS O_NUMBER_OF_READPAST  
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'UPDATETEXT',N'')))) * (1.0 / LEN(N'UPDATETEXT')))                        AS O_NUMBER_OF_UPDATETEXT  
   ,CEILING((LEN(SM.definition) - (LEN(REPLACE(SM.definition,N'WITH',N'')))) * (1.0 / LEN(N'WITH')))                                    AS O_NUMBER_OF_WITH  
   --INTO UTIL.dbo.TBL_CODE_METRICS
FROM sys.all_sql_modules    SM
WHERE SM.object_id > 0
AND   OBJECT_NAME(SM.object_id) NOT LIKE N'DATAVIEW_%'
ORDER BY O_NAME;