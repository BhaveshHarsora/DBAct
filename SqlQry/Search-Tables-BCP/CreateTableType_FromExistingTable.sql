DECLARE @table_name VARCHAR(500)
SELECT @table_name = 'Backhaul'

SET @table_name = 'dbo.' + REPLACE(REPLACE(REPLACE(@table_name,'[',''),']',''),'dbo.','');
DECLARE @TblList AS TABLE (TblName VARCHAR(100));
DECLARE @object_name SYSNAME, @object_id INT;


INSERT INTO @TblList
SELECT DISTINCT OBJECT_NAME(parent_id) 
FROM sys.triggers 
where name NOT LIKE '%_colaud' AND name NOT LIKE '%_rowaud' 
ORDER BY 1

--SELECT 'aav_circuit' UNION ALL
--SELECT 'backhaul' UNION ALL
--SELECT 'backhaul_attr' UNION ALL
--SELECT 'backhaul_pseudowire' UNION ALL
--SELECT 'batch_log' UNION ALL
--SELECT 'bundle_circuit' UNION ALL
--SELECT 'cellsite' UNION ALL
--SELECT 'cellsite_attr' UNION ALL
--SELECT 'cellsite_nid' UNION ALL
--SELECT 'cellsite_subnet' UNION ALL
--SELECT 'col_audit_def' UNION ALL
--SELECT 'col_audit_trail' UNION ALL
--SELECT 'comment' UNION ALL
--SELECT 'ip_host' UNION ALL
--SELECT 'mso' UNION ALL
--SELECT 'mso_grnd_mstr_pair' UNION ALL
--SELECT 'mso_ip_host' UNION ALL
--SELECT 'mso_ng_rtr_pair' UNION ALL
--SELECT 'mso_ntp_serv' UNION ALL
--SELECT 'mso_subnet' UNION ALL
--SELECT 'mso_subnet_xlation' UNION ALL
--SELECT 'mso_vendor_cir_limit' UNION ALL
--SELECT 'network' UNION ALL
--SELECT 'ng_rtr_slot' UNION ALL
--SELECT 'ng_rtr_slot_port' UNION ALL
--SELECT 'ng_rtr_slot_port_vt' UNION ALL
--SELECT 'row_audit_def' UNION ALL
--SELECT 'row_audit_trail' UNION ALL
--SELECT 'solution_subnet' UNION ALL
--SELECT 'vendor' UNION ALL
--SELECT 'vendor_mso' UNION ALL
--SELECT 'vendor_mso_bundle' UNION ALL
--SELECT 'vendor_mso_bundle_pair' UNION ALL
--SELECT 'xref_backhaul_enodeb_gm' UNION ALL
--SELECT 'xref_backhaul_mso_type' UNION ALL
--SELECT 'xref_backhaul_vt1' UNION ALL
--SELECT 'xref_cellsite_ntp_serv' UNION ALL
--SELECT 'xref_sliped_user_type' UNION ALL
--SELECT 'xref_solution_subnet_mso_ip_host'

SELECT * FROM @TblList ORDER BY 1

DECLARE curTblList CURSOR FOR 
SELECT TblName FROM @TblList
OPEN curTblList
FETCH NEXT FROM curTblList INTO @table_name
WHILE @@FETCH_STATUS=0
BEGIN

	SET @table_name = 'dbo.' + REPLACE(REPLACE(REPLACE(@table_name,'[',''),']',''),'dbo.','');
	
	SELECT @object_name = '[' + s.name + '].[' + o.name + ']', @object_id = o.[object_id]
	FROM sys.objects o WITH (NOWAIT)
	JOIN sys.schemas s WITH (NOWAIT) ON o.[schema_id] = s.[schema_id]
	WHERE s.name + '.' + o.name = @table_name
		AND o.[type] = 'U'
		AND o.is_ms_shipped = 0

	DECLARE @SQL NVARCHAR(MAX) = '',@vTypeName AS NVARCHAR(500);
	
	SET @object_name  = REPLACE(REPLACE(REPLACE(@object_name, '[', ''),']',''),'dbo.','')
	SET @vTypeName = N'Type_' + @object_name + N'';
	SELECT @SQL = N'IF EXISTS(SELECT 1 FROM sys.table_types WHERE name = '''+ @vTypeName +''')  
	DROP TYPE ' + @vTypeName + '' + CHAR(13) + CHAR(13) + 
	'CREATE TYPE ' + @vTypeName  + N' AS TABLE' + CHAR(13)  +
	 '(' + CHAR(13) +
	STUFF(
	(
		SELECT CHAR(9) + ', [' + c.name + '] ' + 
			CASE WHEN c.is_computed = 1
				THEN (CASE WHEN UPPER(tp.name)='INT' THEN tp.name ELSE tp.name+'('+CAST(c.max_length AS varchar)+')'END) --'AS ' + cc.[definition] 
				ELSE UPPER(tp.name) + 
					CASE WHEN tp.name IN ('varchar', 'char', 'varbinary', 'binary', 'text')
						   THEN '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS VARCHAR(5)) END + ')'
						 WHEN tp.name IN ('nvarchar', 'nchar', 'ntext')
						   THEN '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length / 2 AS VARCHAR(5)) END + ')'
						 WHEN tp.name IN ('datetime2', 'time2', 'datetimeoffset') 
						   THEN '(' + CAST(c.scale AS VARCHAR(5)) + ')'
						 WHEN tp.name = 'decimal' 
						   THEN '(' + CAST(c.[precision] AS VARCHAR(5)) + ',' + CAST(c.scale AS VARCHAR(5)) + ')'
						ELSE ''
					END 
			END + CHAR(13)
		FROM sys.columns c WITH (NOWAIT)
		JOIN sys.types tp WITH (NOWAIT) ON c.user_type_id = tp.user_type_id
		LEFT JOIN sys.computed_columns cc WITH (NOWAIT) ON c.[object_id] = cc.[object_id] AND c.column_id = cc.column_id
		--LEFT JOIN sys.default_constraints dc WITH (NOWAIT) ON c.default_object_id != 0 AND c.[object_id] = dc.parent_object_id AND c.column_id = dc.parent_column_id
		--LEFT JOIN sys.identity_columns ic WITH (NOWAIT) ON c.is_identity = 1 AND c.[object_id] = ic.[object_id] AND c.column_id = ic.column_id
		WHERE c.[object_id] = @object_id
		ORDER BY c.column_id	    
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, CHAR(9) + ' ')
	    
		--+ ISNULL((SELECT CHAR(9) + ', CONSTRAINT [' + k.name + '] PRIMARY KEY (' + 
		--                (SELECT STUFF((
		--                     SELECT ', [' + c.name + '] ' + CASE WHEN ic.is_descending_key = 1 THEN 'DESC' ELSE 'ASC' END
		--                     FROM sys.index_columns ic WITH (NOWAIT)
		--                     JOIN sys.columns c WITH (NOWAIT) ON c.[object_id] = ic.[object_id] AND c.column_id = ic.column_id
		--                     WHERE ic.is_included_column = 0
		--                         AND ic.[object_id] = k.parent_object_id 
		--                         AND ic.index_id = k.unique_index_id     
		--                     FOR XML PATH(N''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, ''))
		--        + ')' + CHAR(13)
		--        FROM sys.key_constraints k WITH (NOWAIT)
		--        WHERE k.parent_object_id = @object_id 
		--            AND k.[type] = 'PK'), '')
	                 
		  + ')'  + CHAR(13)		  

PRINT (@SQL)	

	IF LEN(@SQL) > 0 AND (NOT EXISTS(SELECT 1 FROM sys.types where name = @vTypeName))
	BEGIN
		PRINT (@SQL)
		--PRINT 'Total Numbers of Characters: ' + CAST(LEN(@SQL) AS VARCHAR)
		--EXEC (@SQL)
	END	

FETCH NEXT FROM curTblList INTO @table_name
END
CLOSE curTblList
DEALLOCATE curTblList
