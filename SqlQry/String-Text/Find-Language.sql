
SELECT name, description 
FROM fn_helpcollations() 
WHERE name LIKE 'Arabic%' -- 'فرع العين' 

------------

ORDER BY  LatinCollationCol COLLATE Arabic_CI_AI_KS = N'????/????';

------------

--> UDF for Finding Language
CREATE FUNCTION dbo.DetermineLanguage(@Snippet NVARCHAR(5))
RETURNS TABLE
AS RETURN
   WITH cte AS
   (
      SELECT UNICODE(LTRIM(@Snippet)) AS [CodePoint]
   )
   SELECT CASE WHEN (cte.CodePoint BETWEEN 1536 AND 1771)
                 OR (cte.CodePoint BETWEEN 1902 AND 1917)
                    THEN 1 -- http://unicode-table.com/en/search/?q=arabic
               WHEN (cte.CodePoint BETWEEN 1425 AND 1524)
                 OR (cte.CodePoint BETWEEN 64285 AND 64335)
                    THEN 2 -- http://unicode-table.com/en/search/?q=hebrew
               WHEN (cte.CodePoint BETWEEN 65 AND 90)
                 OR (cte.CodePoint BETWEEN 97 AND 122)
                    THEN 3 -- http://asciicodes.com/ (English)
               ELSE 4
          END AS [LanguageNumber]
   FROM cte;
   

------------   

--> Test Case
SELECT data.*, num.LanguageNumber
FROM (
       SELECT N'יִﬞ ' AS [SampleText], 'Hebrew' AS [Language]
       UNION ALL
       SELECT N'öû' AS [SampleText], 'Not English' AS [Language]
       UNION ALL
       SELECT N'نݶ' AS [SampleText], 'Arabic' AS [Language]
       UNION ALL
       SELECT N'what?' AS [SampleText], 'English' AS [Language]
     ) data
CROSS APPLY dbo.DetermineLanguage(data.[SampleText]) num
ORDER BY num.LanguageNumber;