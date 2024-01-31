-- Generate temporary table to hold procedure call tree
IF OBJECT_ID('tempdb..#procdeps') IS NOT NULL DROP TABLE #procdeps
CREATE TABLE #procdeps (id_child INT, name_child NVARCHAR(128), id_parent INT, name_parent NVARCHAR(128), level INT, hierarchy VARCHAR(900))
ALTER TABLE #procdeps ADD CONSTRAINT uk_child_parent UNIQUE (id_child, id_parent)
CREATE INDEX idx_hierarchy ON #procdeps (hierarchy)
GO

BEGIN
   DECLARE @proccnt INT
   DECLARE @prevcnt INT
   DECLARE @itercnt INT

   SET NOCOUNT ON
   TRUNCATE TABLE #procdeps

   -- Insert all top level procedures from sysdepends into tree table (all that are not listed as children of relationships)
   -- Initialize level and path (needed for calculating relationships afterwards)
   PRINT 'Generating procedure tree ... ' + CHAR(13) + CHAR(10) + 'Inserting top level procedures ...'
   INSERT INTO #procdeps
   SELECT obj.id, obj.name, NULL, NULL, 0, '.' + CAST(obj.id AS VARCHAR) + '.'
     FROM sysobjects obj
    WHERE obj.xtype = 'P'
      AND OBJECTPROPERTY(obj.id, 'ismsshipped') = 0
      AND obj.id NOT IN (
          SELECT depid
            FROM sysdepends)

   -- Insert all dependent procedures into tree table
   PRINT 'Inserting dependent procedures ...'
   INSERT INTO #procdeps
   SELECT obj2.id, obj2.name, obj1.id, obj1.name, NULL, NULL
     FROM sysobjects obj1,
          sysobjects obj2,
          sysdepends dep
    WHERE obj1.id = dep.id
      AND obj1.xtype = 'P'
      AND OBJECTPROPERTY(obj1.id, 'ismsshipped') = 0
      AND obj2.id = dep.depid
      AND obj2.xtype = 'P'
      AND OBJECTPROPERTY(obj2.id, 'ismsshipped') = 0

   -- Repeat until all relationships are calculated (or a cycle is detected)
   PRINT 'Calculating relationships ...'
   SET @itercnt = 0
   SET @prevcnt = 0
   SELECT @proccnt = COUNT(1) FROM #procdeps WHERE hierarchy IS NULL

   WHILE @proccnt > 0 AND @prevcnt <> @proccnt BEGIN   -- Run 10 iterations at max
      PRINT 'Iteration ' + CAST(@itercnt + 1 AS VARCHAR) + ' - ' + CAST(@proccnt AS VARCHAR) + ' Dependencies to calculate ...'

      -- Node gets level of parent + 1 (top level node gets 0)
      -- Node appends its id to path of parent (all ids delimited by dots, top level node gets just its id)
      -- Top level case is not needed here (only used if statement should calculate dependency for single rows iteratively)
      UPDATE child
         SET level = CASE
                WHEN child.id_parent IS NULL THEN 0
                ELSE parent.level + 1
             END,
             hierarchy = CASE
                WHEN child.id_parent IS NULL THEN '.'
                ELSE parent.hierarchy
             END + CAST(child.id_child AS VARCHAR) + '.'
        FROM #procdeps child LEFT OUTER JOIN
             #procdeps parent ON child.id_parent = parent.id_child

      -- Count iteration and check if missing procedures
      -- If count of procedures without hierarchy does not change between iterations a cycle is detected
      SET @prevcnt = @proccnt
      SET @itercnt = @itercnt + 1
      SELECT @proccnt = COUNT(1) FROM #procdeps WHERE hierarchy IS NULL
   END

   IF @proccnt = @prevcnt
      PRINT 'Finished (cycles detected) ...'
   ELSE
      PRINT 'Finished ...'
   PRINT CHAR(13) + CHAR(10)
END

-- Select hierarchical dependencies as pseudo graphical tree view
PRINT 'Procedure hierarchy ...'
SELECT CAST(CASE
          WHEN level = 0 THEN name_child
          ELSE REPLICATE(' | ', level) + name_child
       END AS NVARCHAR(256)) proctree
  FROM #procdeps
 WHERE hierarchy IS NOT NULL
 ORDER BY hierarchy
GO

-- Select procedures with cyclic call graph
PRINT 'Cyclic dependencies ...'
SELECT CAST(name_child + ' -> ' + name_parent AS NVARCHAR(256)) proctree
  FROM #procdeps
 WHERE hierarchy IS NULL
 ORDER BY hierarchy
GO