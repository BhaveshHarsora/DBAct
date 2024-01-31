DECLARE @strSQL NVARCHAR(1000)
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TRY_CAST]'))
BEGIN
	SET @strSQL = 'CREATE FUNCTION [dbo].[TRY_CAST] () RETURNS INT AS BEGIN RETURN 0 END'
	EXEC sys.sp_executesql @strSQL
END
GO
ALTER FUNCTION dbo.TRY_CAST
(
	@pExpression AS VARCHAR(8000),
	@pData_Type AS VARCHAR(8000),
	@pReturnValueIfErrorCast AS SQL_VARIANT = NULL
)
RETURNS SQL_VARIANT
AS
BEGIN
	--------------------------------------------------------------------------------
	--	INT	
	--------------------------------------------------------------------------------
	
	IF @pData_Type = 'INT'
	BEGIN
		IF ISNUMERIC(@pExpression) = 1 AND @pExpression NOT IN ('-','+','$','.',',','\')	--JEPM20170216
		BEGIN
			DECLARE @pExpressionINT AS FLOAT = CAST(@pExpression AS FLOAT)
			IF @pExpressionINT BETWEEN - 2147483648.0 AND 2147483647.0
			BEGIN
				RETURN CAST(@pExpressionINT as INT)
			END
			ELSE
			BEGIN
				RETURN @pReturnValueIfErrorCast
			END --FIN IF @pExpressionINT BETWEEN - 2147483648.0 AND 2147483647.0
		END
		ELSE
		BEGIN
			RETURN @pReturnValueIfErrorCast
		END -- FIN IF ISNUMERIC(@pExpression) = 1
	END -- FIN IF @pData_Type = 'INT'
	
	--------------------------------------------------------------------------------
	--	DATE	
	--------------------------------------------------------------------------------
	
	IF @pData_Type IN ('DATE','DATETIME')
	BEGIN
		IF ISDATE(@pExpression) = 1
		BEGIN
			
			DECLARE @pExpressionDATE AS DATETIME = cast(@pExpression AS DATETIME)
			IF @pData_Type = 'DATE'
			BEGIN
				RETURN cast(@pExpressionDATE as DATE)
			END
			
			IF @pData_Type = 'DATETIME'
			BEGIN
				RETURN cast(@pExpressionDATE as DATETIME)
			END
			
		END
		ELSE 
		BEGIN
			
			DECLARE @pExpressionDATEReplaced AS VARCHAR(50) = REPLACE(REPLACE(REPLACE(@pExpression,'\',''),'/',''),'-','')
			
			IF ISDATE(@pExpressionDATEReplaced) = 1
			BEGIN
				IF @pData_Type = 'DATE'
				BEGIN
					RETURN cast(@pExpressionDATEReplaced as DATE)
				END
			
				IF @pData_Type = 'DATETIME'
				BEGIN
					RETURN cast(@pExpressionDATEReplaced as DATETIME)
				END
			END
			ELSE
			BEGIN
				RETURN @pReturnValueIfErrorCast
			END
		END --FIN IF ISDATE(@pExpression) = 1
	END --FIN IF @pData_Type = 'DATE'
	--------------------------------------------------------------------------------
	--	NUMERIC	
	--------------------------------------------------------------------------------
	
	IF @pData_Type LIKE 'NUMERIC%'
	BEGIN
		IF ISNUMERIC(@pExpression) = 1
		BEGIN
			
			DECLARE @TotalDigitsOfType AS INT = SUBSTRING(@pData_Type,CHARINDEX('(',@pData_Type)+1,  CHARINDEX(',',@pData_Type) - CHARINDEX('(',@pData_Type) - 1)
				, @TotalDecimalsOfType AS INT = SUBSTRING(@pData_Type,CHARINDEX(',',@pData_Type)+1,  CHARINDEX(')',@pData_Type) - CHARINDEX(',',@pData_Type) - 1)
				, @TotalDigitsOfValue AS INT 
				, @TotalDecimalsOfValue AS INT 
				, @TotalWholeDigitsOfType AS INT 
				, @TotalWholeDigitsOfValue AS INT 
			SET @pExpression = REPLACE(@pExpression, ',','.')
			SET @TotalDigitsOfValue = LEN(REPLACE(@pExpression, '.',''))
			SET @TotalDecimalsOfValue = CASE Charindex('.', @pExpression)
										WHEN 0
											THEN 0
										ELSE Len(Cast(Cast(Reverse(CONVERT(VARCHAR(50), @pExpression, 128)) AS FLOAT) AS BIGINT))
										END 
			SET @TotalWholeDigitsOfType = @TotalDigitsOfType - @TotalDecimalsOfType
			SET @TotalWholeDigitsOfValue = @TotalDigitsOfValue - @TotalDecimalsOfValue
			-- The total digits can not be greater than the p part of NUMERIC (p, s)
			-- The total of decimals can not be greater than the part s of NUMERIC (p, s)
			-- The total digits of the whole part can not be greater than the subtraction between p and s
			IF (@TotalDigitsOfValue <= @TotalDigitsOfType) AND (@TotalDecimalsOfValue <= @TotalDecimalsOfType) AND (@TotalWholeDigitsOfValue <= @TotalWholeDigitsOfType)
			BEGIN
				DECLARE @pExpressionNUMERIC AS FLOAT
				SET @pExpressionNUMERIC = CAST (ROUND(@pExpression, @TotalDecimalsOfValue) AS FLOAT) 
				
				RETURN @pExpressionNUMERIC --Returns type FLOAT
			END 
			else
			BEGIN
				RETURN @pReturnValueIfErrorCast
			END-- FIN IF (@TotalDigitisOfValue <= @TotalDigits) AND (@TotalDecimalsOfValue <= @TotalDecimals) 
		END
		ELSE 
		BEGIN
			RETURN @pReturnValueIfErrorCast
		END --FIN IF ISNUMERIC(@pExpression) = 1
	END --IF @pData_Type LIKE 'NUMERIC%'
	
	--------------------------------------------------------------------------------
	--	BIT	
	--------------------------------------------------------------------------------
	
	IF @pData_Type LIKE 'BIT'
	BEGIN
		IF ISNUMERIC(@pExpression) = 1
		BEGIN
			RETURN CAST(@pExpression AS BIT) 
		END
		ELSE 
		BEGIN
			RETURN @pReturnValueIfErrorCast
		END --FIN IF ISNUMERIC(@pExpression) = 1
	END --IF @pData_Type LIKE 'BIT'
	--------------------------------------------------------------------------------
	--	FLOAT	
	--------------------------------------------------------------------------------
	
	IF @pData_Type LIKE 'FLOAT'
	BEGIN
		IF ISNUMERIC(REPLACE(REPLACE(@pExpression, CHAR(13), ''), CHAR(10), '')) = 1
		BEGIN
			RETURN CAST(@pExpression AS FLOAT) 
		END
		ELSE 
		BEGIN
			
			IF REPLACE(@pExpression, CHAR(13), '') = '' --Only white spaces are replaced, not new lines
			BEGIN
				RETURN 0
			END
			ELSE 
			BEGIN
				RETURN @pReturnValueIfErrorCast
			END --IF REPLACE(@pExpression, CHAR(13), '') = '' 
			
		END --FIN IF ISNUMERIC(@pExpression) = 1
	END --IF @pData_Type LIKE 'FLOAT'
	--------------------------------------------------------------------------------
	--	Any other unsupported data type will return NULL or the value assigned by the user to @pReturnValueIfErrorCast	
	--------------------------------------------------------------------------------
	
	RETURN @pReturnValueIfErrorCast
		
END