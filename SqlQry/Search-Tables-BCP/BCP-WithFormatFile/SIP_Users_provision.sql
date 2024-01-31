/*
   Script (one-time use) for moving a set of users from one org to another.
   Instructions:
   copy the data directory as C:\temp\data\ (or modify this script)
   copy the input user-list as C:\temp\data\SIP_Users_provision.CSV
   The user list consists of tab-separated entries : user's UPN 
   If a different format is desired, update the SIP_Users_provision.fmt file. 
*/


declare @SRC TABLE (
   row_num int identity(1,1),
   UPN VARCHAR(100)  NULL
	  )
	  
INSERT INTO @SRC(UPN
)
SELECT UPN
FROM  OPENROWSET(BULK  'C:\temp\data\SIP_Users_provision.csv', FORMATFILE='C:\temp\data\users_upn.fmt', MAXERRORS = 100 ) AS T1;


UPDATE PEC
SET PEC.RAISED=1 
from @src s
inner join USER_STUB U on u.UPN=S.UPN and (u.STATUS <> 2)
inner join ADDR ADDR ON U.ADDR_ID = ADDR.ID 
inner join PROV_ENQ_CACHE PEC on PEC.ENTITY_REF=u.id AND (PEC.RAISED <> 1);



