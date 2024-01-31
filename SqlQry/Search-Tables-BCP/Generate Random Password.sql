/*
BH20220121 Generate Random Passord
For Length of password, change TOP value
*/

SELECT (
	SELECT '' + Psswrd
	FROM (
		SELECT TOP 15 CHAR(Number) AS Psswrd
		FROM (
			SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Number
			FROM sys.syscolumns
		) AS t
		WHERE Number
		BETWEEN 48 AND 122
		ORDER BY NEWID()
	) AS t
	FOR XML PATH('')
) AS Psswrd;