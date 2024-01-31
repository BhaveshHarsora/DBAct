DECLARE @TableName as varchar(1000)  

SET @TableName = 'tbl_Login'

--------------

BEGIN  
 SET NOCOUNT ON  
   
 CREATE TABLE #SPSave  
 (  
  SPDetail VARCHAR(8000)  
 )  
   
 CREATE TABLE #SPUpdate  
 (  
  SPDetail VARCHAR(8000)  
 )  
   
 CREATE TABLE #SPSelect  
 (  
  SPDetail VARCHAR(8000)  
 )  
   
 DECLARE @TableFields VARCHAR(8000)  
 SET @TableFields = ''  
   
 DECLARE @FirstField INT   
 SET @FirstField = 1  
   
 DECLARE @FirstFieldFORUpdate INT   
 SET @FirstFieldFORUpdate = 1  
   
 DECLARE @MainKEY VARCHAR(50)  
 SET @MainKEY = ''  
   
 DECLARE @PreFix VARCHAR(10)  
 SET @PreFix = ''  
   
 DECLARE @FieldName AS Varchar(200)  
 DECLARE @FieldType as int  
 DECLARE @FieldTypeName as varchar(100)  
 DECLARE @FieldLength as int  
 DECLARE @FieldIdentity as int  
  
 INSERT INTO #SPUpdate VALUES ( '   UPDATE ' + @TableName + ' SET ' )  
 INSERT INTO #SPSelect VALUES ( '   SELECT ')  
  
 DECLARE Fields_Cursor CURSOR FOR   
  SELECT Name AS FieldName,   
   xType as FieldType,   
   Type_Name(xType) AS FieldTypeName,   
   Length as FieldLength,   
   ColStat & 1 AS IsIdentity  
  FROM SysColumns   
  WHERE ID IN ( SELECT ID FROM SysObjects WHERE Name = @TableName )  
  
 OPEN Fields_Cursor  
 FETCH NEXT FROM Fields_Cursor INTO @FieldName, @FieldType, @FieldTypeName, @FieldLength, @FieldIdentity  
  
 WHILE @@FETCH_STATUS = 0  
 BEGIN  
      
  SET @PreFix = ( CASE @FirstField WHEN 0 THEN ' , ' ELSE ' ' END )  
    
  IF ( @FirstField = 0 )  
   BEGIN  
    IF ( @TableFields != '' )  
     BEGIN  
      SET @TableFields = @TableFields + ','  
     END  
    SET @TableFields = @TableFields + '@' + @FieldName  
    IF ( @FirstFieldFORUpdate = 1 )  
     BEGIN  
      INSERT INTO #SPUpdate VALUES ( '    ' + @FieldName + ' = @' + @FieldName )  
     END  
    ELSE  
     BEGIN  
      INSERT INTO #SPUpdate VALUES ( '   ' + @PreFix + @FieldName + ' = @' + @FieldName )  
     END  
    SET @FirstFieldFORUpdate = 0  
   END  
  ELSE  
   BEGIN  
    SET @MainKEY = @FieldName  
   END  
    
  IF (   
    @FieldType = 48 OR @FieldType = 56 OR @FieldType = 127 OR @FieldType = 59 OR @FieldType = 52   -- Small Int OR Integer OR Big Integer OR Real OR SmallInt  
    OR @FieldType = 106 OR @FieldType = 108 -- Decimal OR Numeric  
    OR @FieldType = 60 OR @FieldType = 122 -- Money OR Small Money  
    OR @FieldType = 62 -- Float  
    OR @FieldType = 104  -- Bit  
   )  
   BEGIN  
    INSERT INTO #SPSelect VALUES ( '   ' + @PreFix + 'ISNULL( ' + @FieldName + ', 0) AS ' + @FieldName )  
      
    INSERT INTO #SPSave VALUES ( @PreFix + '@' + @FieldName + ' ' + @FieldTypeName )  
   END  
  ELSE IF @FieldType = 61 OR @FieldType = 58  -- Datetime OR SmallDatetime  
   BEGIN  
    INSERT INTO #SPSave VALUES ( @PreFix + '@' + @FieldName + ' ' + @FieldTypeName)  
      
    INSERT INTO #SPSelect VALUES ( '   ' + @PreFix + 'ISNULL( ' + @FieldName + ', '''') AS ' + @FieldName )  
   END  
  ELSE IF ( @FieldType = 167 OR @FieldType = 175 ) -- Varchar OR Char   
   BEGIN  
    INSERT INTO #SPSave VALUES ( @PreFix + '@' + @FieldName + ' ' + @FieldTypeName + '(' + CONVERT( VARCHAR(20), @FieldLength ) + ')' )  
      
    INSERT INTO #SPSelect VALUES ( '   ' + @PreFix + 'ISNULL( ' + @FieldName + ', '''') AS ' + @FieldName )  
   END  
  ELSE IF @FieldType = 35 OR @FieldType = 99 OR @FieldType = 239 OR @FieldType = 231 -- Text OR nText OR nChar OR nVarchar  
   BEGIN  
    INSERT INTO #SPSave VALUES ( @PreFix + '@' + @FieldName + ' VARCHAR(8000)' )  
      
    INSERT INTO #SPSelect VALUES ( '   ' +  @PreFix + 'ISNULL( ' + @FieldName + ', '''') AS ' + @FieldName )  
   END  
    
  SET @FirstField = 0  
  FETCH NEXT FROM Fields_Cursor INTO @FieldName, @FieldType, @FieldTypeName, @FieldLength, @FieldIdentity  
 END  
 CLOSE Fields_Cursor  
 DEALLOCATE Fields_Cursor  
   
 INSERT INTO #SPUpdate VALUES ( '   WHERE ' + @MainKEY + ' = @' + @MainKEY )  
 INSERT INTO #SPSelect VALUES ( '   FROM ' + @TableName)  
   
 /*****************************/  
 /* Save Data SP Genrate      */  
 /*****************************/  
 SELECT SPDetail  
 FROM   
 (  
  SELECT 'CREATE PROCEDURE ' + @TableName + '_Save( ' AS SPDetail  
    
  UNION ALL  
    
  SELECT SPDetail FROM #SPSave  
    
  UNION ALL  
    
  SELECT ' , @ReturnValue INT OUTPUT' AS SPDetail  
    
  UNION ALL  
    
  SELECT ')' AS SPDetail  
    
  UNION ALL  
    
  SELECT ' AS BEGIN' AS SPDetail  
    
  UNION ALL  
    
  SELECT ' SET NOCOUNT ON' AS SPDetail  
    
  UNION ALL  
    
  SELECT ' IF (' + @MainKEY + ' = 0 )' AS SPDetail  
    
  UNION ALL  
    
  SELECT '  BEGIN' AS SPDetail  
    
  UNION ALL  
    
  SELECT '   INSERT INTO ' + @TableName + ' VALUES (' + @TableFields + ')' AS SPDetail  
    
  UNION ALL  
    
  SELECT '' AS SPDetail  
    
  UNION ALL  
    
  SELECT '   SET @ReturnValue = SCOPE_IDENTITY()' AS SPDetail  
    
  UNION ALL  
    
  SELECT '  END' AS SPDetail  
    
  UNION ALL  
    
  SELECT ' ELSE' AS SPDetail  
    
  UNION ALL  
    
  SELECT '  BEGIN' AS SPDetail  
    
  UNION ALL  
    
  SELECT SPDetail FROM #SPUpdate  
    
  UNION ALL  
    
  SELECT '' AS SPDetail  
    
  UNION ALL  
    
  SELECT '   SET @ReturnValue = 1' AS SPDetail  
    
  UNION ALL  
    
  SELECT '  END' AS SPDetail  
    
  UNION ALL  
    
  SELECT 'END' AS SPDetail  
    
  UNION ALL  
    
  SELECT 'GO' AS SPDetail  
 ) AS SaveSPDetail  
   
   
 /*****************************/  
 /* Select Data SP Genrate    */  
 /*****************************/  
 SELECT SPDetail  
 FROM  
 (  
  SELECT 'CREATE PROCEDURE ' + @TableName + '_Select( @ID INT )' AS SPDetail  
    
  UNION ALL   
    
  SELECT ' AS BEGIN' AS SPDetail  
    
  UNION ALL   
    
  SELECT ' SET NOCOUNT ON' AS SPDetail  
    
  UNION ALL   
    
  SELECT ' IF ( @ID = 0 )' AS SPDetail  
    
  UNION ALL   
    
  SELECT '  BEGIN' AS SPDetail  
    
  UNION ALL   
    
  SELECT SPDetail FROM #SPSelect  
    
  UNION ALL   
    
  SELECT '  END' AS SPDetail  
    
  UNION ALL   
    
  SELECT ' ELSE' AS SPDetail  
    
  UNION ALL   
    
  SELECT '  BEGIN' AS SPDetail  
    
  UNION ALL   
    
  SELECT SPDetail FROM #SPSelect  
    
  UNION ALL   
    
  SELECT '   WHERE ' + @MainKEY + ' = @ID'  
    
  UNION ALL   
    
  SELECT '  END' AS SPDetail  
    
  UNION ALL   
    
  SELECT 'END' AS SPDetail  
 ) AS SelectSPDetail  
   
 DROP TABLE #SPSave  
 DROP TABLE #SPUpdate  
 DROP TABLE #SPSelect  
END  
  