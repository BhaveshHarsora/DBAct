	DECLARE @FileFormat VARCHAR(50)
	SET @FileFormat = '1#34#6#8#01#34#6#8#01#34#6#8#01#34#6#8#0'
	
	;WITH MyTable AS 
	(
		SELECT @FileFormat AS FileFormat
			, CHARINDEX('#', @FileFormat) + 1 AS FirstIndex
			, (
				CHARINDEX('#', SUBSTRING(@FileFormat, CHARINDEX('#', @FileFormat ) + 1, LEN( @FileFormat ) ) ) - 1
				) AS SecondIndex
		
		UNION ALL
		
		SELECT SUBSTRING( FileFormat, FirstIndex + SecondIndex + 1, LEN( FileFormat ) ) AS FileFormat
			, CHARINDEX('#', SUBSTRING( FileFormat, FirstIndex + SecondIndex + 1, LEN( FileFormat ) ) ) + 1 AS FirstIndex
			, (
				CHARINDEX('#', SUBSTRING(SUBSTRING( FileFormat, FirstIndex + SecondIndex + 1, LEN( FileFormat ) ), CHARINDEX('#', SUBSTRING( FileFormat, FirstIndex + SecondIndex + 1, LEN( FileFormat ) ) ) + 1, LEN( FileFormat ) ) ) - 1
				) AS SecondIndex
		FROM MyTable
		WHERE LEN( FileFormat ) > 0
			AND SecondIndex > 0
	)
	
	SELECT 
		(
			CASE 
				WHEN FirstIndex - 2 > 0 THEN SUBSTRING(FileFormat, 1, FirstIndex - 2)
				ELSE SUBSTRING(FileFormat, 1, LEN( FirstIndex ) )
			END
		) AS PreviousField
		,(
			CASE 
				WHEN SecondIndex > 0 THEN SUBSTRING(FileFormat, FirstIndex, SecondIndex)
				ELSE ''
			END
		) AS FieldName
	FROM MyTable
	OPTION (MAXRECURSION 0)