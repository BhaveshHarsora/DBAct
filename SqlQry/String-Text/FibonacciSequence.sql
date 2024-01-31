WITH FibonacciSequence AS
(

    SELECT 
		1 AS SrNo
		, ( CAST( 0 AS FLOAT ) ) AS c1
		, ( CAST( 1 AS FLOAT ) ) AS c2

    UNION ALL

    SELECT 
		SrNo + 1 AS SrNo
		, ( CAST( c2 AS FLOAT ) ) AS c1
		, ( CAST( ( c1 + c2 ) AS FLOAT ) ) AS c2
    FROM FibonacciSequence
    WHERE SrNo < 100

)

SELECT SrNo, c1 
FROM FibonacciSequence
OPTION (MAXRECURSION 0);