begin tran
	
select   * from EmpMst;


SET IDENTITY_INSERT EmpMst ON

MERGE INTO EmpMst AS a
USING (SELECT x.EmpId, x.DeptName, x.Salary, x.EmpName
		FROM Test2..EmpMSt AS x) AS b
	ON a.EmpId = b.EmpId
WHEN MATCHED THEN 
	UPDATE SET	a.DeptName = b.DeptName,
				a.Salary = b.Salary,
				a.EmpName = b.EmpName
WHEN NOT MATCHED BY TARGET THEN
	 INSERT (EmpId, DeptName, Salary, EmpName)
	 VALUES (b.EmpId, b.DeptName, b.Salary, b.EmpName)
WHEN NOT MATCHED BY SOURCE THEN 
	DELETE;


SET IDENTITY_INSERT EmpMst OFF

select * from EmpMst;
select * from test2..EmpMst;

ROLLBACK
