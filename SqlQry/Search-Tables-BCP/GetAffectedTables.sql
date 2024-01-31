SELECT distinct type, type_desc
FROM sys.objects 
WHERE COALESCE(modify_date, create_date) >= CAST('27 Sep 2017' AS DATETIME)
ORDER BY COALESCE(modify_date, create_date) DESC

SELECT DISTINCT a.name
FROM sys.tables AS a
JOIN sys.sql_modules AS b
	JOIN sys.objects AS c
		ON c.object_id = b.object_id
		AND COALESCE(modify_date, create_date) >= CAST('27 Sep 2017' AS DATETIME)
		AND c.type IN ('D', 'F', 'FN', 'P', 'TT', 'U', 'V')
	ON b.definition LIKE CONCAT('%', a.name , '%')
