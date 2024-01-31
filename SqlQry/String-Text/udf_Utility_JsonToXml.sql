IF OBJECT_ID('dbo.udf_Utility_JsonToXml','FN') IS NOT NULL
	DROP FUNCTION dbo.udf_Utility_JsonToXml
GO
CREATE FUNCTION dbo.udf_Utility_JsonToXml
(
    @pJSON VARCHAR(MAX)
)
RETURNS XML
AS
BEGIN
    DECLARE @output varchar(max), @key varchar(max), @value varchar(max),
        @recursion_counter int, @offset int, @nested bit, @array bit,
        @tab char(1)=CHAR(9), @cr char(1)=CHAR(13), @lf char(1)=CHAR(10);

    --- Clean up the JSON syntax by removing line breaks and tabs and
    --- trimming the results of leading and trailing spaces:
    SET @pJSON=LTRIM(RTRIM(
        REPLACE(REPLACE(REPLACE(@pJSON, @cr, ''), @lf, ''), @tab, '')));

    --- Sanity check: If this is not valid JSON syntax, exit here.
    IF (LEFT(@pJSON, 1)!='{' OR RIGHT(@pJSON, 1)!='}')
        RETURN '';

    --- Because the first and last characters will, by definition, be
    --- curly brackets, we can remove them here, and trim the result.
    SET @pJSON=LTRIM(RTRIM(SUBSTRING(@pJSON, 2, LEN(@pJSON)-2)));

    SELECT @output='';
    WHILE (@pJSON!='') BEGIN;

        --- Look for the first key which should start with a quote.
        IF (LEFT(@pJSON, 1)!='"')
            RETURN 'Expected quote (start of key name). Found "'+
                LEFT(@pJSON, 1)+'"';

        --- .. and end with the next quote (that isn't escaped with
        --- and backslash).
        SET @key=SUBSTRING(@pJSON, 2,
            PATINDEX('%[^\\]"%', SUBSTRING(@pJSON, 2, LEN(@pJSON))+' "'));

        --- Truncate @pJSON with the length of the key.
        SET @pJSON=LTRIM(SUBSTRING(@pJSON, LEN(@key)+3, LEN(@pJSON)));

        --- The next character should be a colon.
        IF (LEFT(@pJSON, 1)!=':')
            RETURN 'Expected ":" after key name, found "'+
                LEFT(@pJSON, 1)+'"!';

        --- Truncate @pJSON to skip past the colon:
        SET @pJSON=LTRIM(SUBSTRING(@pJSON, 2, LEN(@pJSON)));

        --- If the next character is an angle bracket, this is an array.
        IF (LEFT(@pJSON, 1)='[')
            SELECT @array=1, @pJSON=LTRIM(SUBSTRING(@pJSON, 2, LEN(@pJSON)));

        IF (@array IS NULL) SET @array=0;
        WHILE (@array IS NOT NULL) BEGIN;

            SELECT @value=NULL, @nested=0;
            --- The first character of the remainder of @pJSON indicates
            --- what type of value this is.

            --- Set @value, depending on what type of value we're looking at:
            ---
            --- 1. A new JSON object:
            ---    To be sent recursively back into the parser:
            IF (@value IS NULL AND LEFT(@pJSON, 1)='{') BEGIN;
                SELECT @recursion_counter=1, @offset=1;
                WHILE (@recursion_counter!=0 AND @offset<LEN(@pJSON)) BEGIN;
                    SET @offset=@offset+
                        PATINDEX('%[{}]%', SUBSTRING(@pJSON, @offset+1,
                            LEN(@pJSON)));
                    SET @recursion_counter=@recursion_counter+
                        (CASE SUBSTRING(@pJSON, @offset, 1)
                            WHEN '{' THEN 1
                            WHEN '}' THEN -1 END);
                END;

                SET @value=CAST(
						dbo.udf_Utility_JsonToXml(LEFT(@pJSON, @offset))
                        AS varchar(max));
                SET @pJSON=SUBSTRING(@pJSON, @offset+1, LEN(@pJSON));
                SET @nested=1;
            END

            --- 2a. Blank text (quoted)
            IF (@value IS NULL AND LEFT(@pJSON, 2)='""')
                SELECT @value='', @pJSON=LTRIM(SUBSTRING(@pJSON, 3,
                    LEN(@pJSON)));

            --- 2b. Other text (quoted, but not blank)
            IF (@value IS NULL AND LEFT(@pJSON, 1)='"') BEGIN;
                SET @value=SUBSTRING(@pJSON, 2,
                    PATINDEX('%[^\\]"%',
                        SUBSTRING(@pJSON, 2, LEN(@pJSON))+' "'));
                SET @pJSON=LTRIM(
                    SUBSTRING(@pJSON, LEN(@value)+3, LEN(@pJSON)));
            END;

            --- 3. Blank (not quoted)
            IF (@value IS NULL AND LEFT(@pJSON, 1)=',')
                SET @value='';

            --- 4. Or unescaped numbers or text.
            IF (@value IS NULL) BEGIN;
                SET @value=LEFT(@pJSON,
                    PATINDEX('%[,}]%', REPLACE(@pJSON, ']', '}')+'}')-1);
                SET @pJSON=SUBSTRING(@pJSON, LEN(@value)+1, LEN(@pJSON));
            END;

            --- Append @key and @value to @output:
            SET @output=@output+@lf+@cr+
                REPLICATE(@tab, @@NESTLEVEL-1)+
                '<'+@key+'>'+
                    ISNULL(REPLACE(
                        REPLACE(@value, '\"', '"'), '\\', '\'), '')+
                    (CASE WHEN @nested=1
                        THEN @lf+@cr+REPLICATE(@tab, @@NESTLEVEL-1)
                        ELSE ''
                    END)+
                '</'+@key+'>';

            --- And again, error checks:
            ---
            --- 1. If these are multiple values, the next character
            ---    should be a comma:
            IF (@array=0 AND @pJSON!='' AND LEFT(@pJSON, 1)!=',')
                RETURN @output+'Expected "," after value, found "'+
                    LEFT(@pJSON, 1)+'"!';

            --- 2. .. or, if this is an array, the next character
            --- should be a comma or a closing angle bracket:
            IF (@array=1 AND LEFT(@pJSON, 1) NOT IN (',', ']'))
                RETURN @output+'In array, expected "]" or "," after '+
                    'value, found "'+LEFT(@pJSON, 1)+'"!';

            --- If this is where the array is closed (i.e. if it's a
            --- closing angle bracket)..
            IF (@array=1 AND LEFT(@pJSON, 1)=']') BEGIN;
                SET @array=NULL;
                SET @pJSON=LTRIM(SUBSTRING(@pJSON, 2, LEN(@pJSON)));

                --- After a closed array, there should be a comma:
                IF (LEFT(@pJSON, 1) NOT IN ('', ',')) BEGIN
                    RETURN 'Closed array, expected ","!';
                END;
            END;

            SET @pJSON=LTRIM(SUBSTRING(@pJSON, 2, LEN(@pJSON)+1));
            IF (@array=0) SET @array=NULL;

        END;
    END;

    --- Return the output:
	RETURN CAST(@output AS xml);

END;
GO