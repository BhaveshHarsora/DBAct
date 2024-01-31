	DECLARE @TableA TABLE (Name VARCHAR(100) )
	INSERT INTO @TableA VALUES ('MARY,MA,JENNY')

	DECLARE @TableB TABLE (Name VARCHAR(100), DISTRICT_NO INT )
	INSERT INTO @TableB VALUES ('MARY', 2)
	INSERT INTO @TableB VALUES ('YY', 3)
	INSERT INTO @TableB VALUES ('JOHN', 4)

	DECLARE @XML XML

	SELECT @XML = CAST( (
							SELECT '<Name>' + REPLACE(Name, ',', '</Name><Name>') + '</Name>' 
							FROM @TableA
							
						  )	AS XML
						)


	SELECT * 
	FROM @TableB AS TableB
		INNER JOIN (
						SELECT 
							TableA.value('.', 'VARCHAR(100)') AS Name
						FROM @XML.nodes('Name')e(TableA)
					) AS TableA ON TableA.Name = TableB.Name


