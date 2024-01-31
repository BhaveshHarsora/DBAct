/*Get Object References*/
DECLARE @pObjectName AS VARCHAR(100);
SET @pObjectName = 'ip_host';

DECLARE @vMAX_CHAR_SEEK_LIMIT INT=800;
DECLARE @vC1 INT, @vC2 INT, @vIncrementals INT, @vSbStart INT, @vSbEnd INT;
DECLARE @vProcName AS VARCHAR(500), @vProcText AS VARCHAR(MAX), @vProcText2 AS VARCHAR(MAX);
DECLARE @vTResult AS TABLE (ProcName VARCHAR(200));
DECLARE @vtmp_ObjDepData AS TABLE (ProcName VARCHAR(200),ProcText VARCHAR(MAX));

SET @vC1 = 100;
SET @vC2 = 800;

SET @pObjectName = REPLACE(REPLACE(REPLACE(@pObjectName,'[',''),']',''),'dbo.','');

IF NOT EXISTS(SELECT 1 from sys.tables WHERE name = @pObjectName) 	
BEGIN
	RAISERROR('Table is not there', 16,1);
	RETURN;
END

  
SELECT DISTINCT tbl.ProcName,tbl.ProcText--, tbl.ProcText2
--INTO #tmp_ObjDepData
FROM (
SELECT 
RTRIM(LTRIM(so_procs.name)) AS ProcName
--REPLACE(REPLACE(REPLACE(REPLACE(SUBSTRING(sc_procs.text,CHARINDEX(' ',sc_procs.text,18),CHARINDEX(' ',sc_procs.text,20)-CHARINDEX(' ',sc_procs.text,18)),'CREATE PROCEDURE',''),'[',''),']',''),'dbo.','') as procName
, RTRIM(LTRIM(REPLACE(REPLACE(sc_procs.text,'  ',' ') ,CHAR(13)+CHAR(10), ' ')))AS ProcText
, RTRIM(LTRIM(REPLACE(SUBSTRING(sc_procs.text, CHARINDEX(@pObjectName,sc_procs.text)-@vC1,@vC1+20),'  ',' '))) AS ProcText2
--, RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(sc_procs.text, CHARINDEX(@pObjectName,sc_procs.text)-@vC2,@vC2+20),CHAR(13)+CHAR(10), ' '),'  ',' '))) AS ProcText2
FROM sysobjects so_tables  
INNER JOIN syscomments sc_procs on sc_procs.text like '%' + so_tables.name + ' %'
INNER JOIN sysobjects so_procs on sc_procs.id = so_procs.id
WHERE so_tables.type = 'U' 
AND so_procs.type = 'P'
AND so_tables.name=@pObjectName
) AS tbl
WHERE 1=1
--AND (ProcText2 LIKE '%INSERT INTO%' OR ProcText2 LIKE '%UPDATE%SET%' OR ProcText2 LIKE '%DELETE%' OR ProcText2 LIKE '%MERGE%USING%')
ORDER BY 1

--INSERT INTO @vtmp_ObjDepData (ProcName,ProcText)
--SELECT 'AA','DELETE some text here asdfjkl asf klsfalsd ahskjdfhjkasdf' UNION ALL
--SELECT 'BB','INSERT INTO klhaksdjf askjdfhkja ksdfka dkfhksjdhfkjsah kjahskdjfh ' UNION ALL
--SELECT 'CC','akjsdhfkj UPDATE hakjshdjkfl aksdhfjk haksjdhfkj asdf ashdkfh akjsdhkjf hajkshdfkj ahsf some' UNION ALL
--SELECT 'DD','hakshdfkj INSERT INTO asdfh kasdjhfk jasjd fhajks text' UNION ALL
--SELECT 'EE','ljsfjdlkaj UPDATE SET slkjdlk ajslkdjf lkajsdlkjf lkasd text kld' UNION ALL
--SELECT 'FF','text khkjahsdkjfh jkasdjk asdfhk jashdfk UPDATE SET hasdhfjka sdlf' UNION ALL
--SELECT 'GG','aksdjflk asdf jaslkdjf INSERT INTO textkljaklsjdfkljas';

--SET @pObjectName = 'text';

  
DECLARE cur1 CURSOR 
FOR 
SELECT ProcName,ProcText--, ProcText2 
FROM #tmp_ObjDepData
---FROM @vtmp_ObjDepData

OPEN cur1
FETCH NEXT FROM cur1 INTO @vProcName, @vProcText--, @vProcText2


WHILE @@FETCH_STATUS = 0 
BEGIN
	
	SET @vC2 = 0;
	SET @vIncrementals=50;
	

	SET @vC2 = @vC2+@vIncrementals;
	SET @vSbStart = CHARINDEX(@pObjectName,@vProcText)-@vC2;
	SET @vSbEnd = @vSbStart+@vC2+25;
	
	PRINT @vProcText
	
	IF (@vSbStart<0 OR @vSbStart>=@vSbEnd)
	BEGIN
		SET @vSbStart=1;
		PRINT  'OUT ____ @vSbStart = ' + CAST(@vSbStart AS VARCHAR); 
	END		
			
	WHILE (@vSbStart>0 AND @vSbStart<=@vSbEnd)
	BEGIN		
		Declare @vFlgIns INT=0;
		
		PRINT 'SUBSTRING TEXT:-  '+SUBSTRING(@vProcText,@vSbStart,@vSbEnd)
		
		IF (SUBSTRING(@vProcText,@vSbStart,@vSbEnd) LIKE '%INSERT INTO%')
		BEGIN
			SET @vFlgIns = @vFlgIns+1;
		END;	
		
		IF (SUBSTRING(@vProcText,@vSbStart,@vSbEnd) LIKE '%UDPATE%SET%')
		BEGIN
			SET @vFlgIns = @vFlgIns+1;
		END;	
		
		IF (SUBSTRING(@vProcText,@vSbStart,@vSbEnd) LIKE '%DELETE%')
		BEGIN
			SET @vFlgIns = @vFlgIns+1;
		END;	
		
		IF (SUBSTRING(@vProcText,@vSbStart,@vSbEnd) LIKE '%MERGE%USING%')
		BEGIN
			SET @vFlgIns = @vFlgIns+1;
		END;	
		
		
		IF (@vFlgIns>0 AND NOT EXISTS(SELECT 1 FROM @vTResult WHERE ProcName=@vProcName))
		BEGIN
			INSERT INTO @vTResult(ProcName)
			SELECT @vProcName;
			
			BREAK;
		END;	
		
		
		SET @vSbStart = CHARINDEX(@pObjectName,@vProcText,@vSbEnd)-@vC2;
		SET @vSbEnd = CHARINDEX(@pObjectName,@vProcText,@vSbEnd)+10;
		
		PRINT  '@vSbStart = ' + CAST(@vSbStart AS VARCHAR);
		--PRINT 'In while'
	END;		

	FETCH NEXT FROM cur1 INTO @vProcName, @vProcText--, @vProcText2
END
CLOSE cur1
DEALLOCATE cur1

DROP TABLE #tmp_ObjDepData;

SELECT * FROM @vTResult ORDER BY 1