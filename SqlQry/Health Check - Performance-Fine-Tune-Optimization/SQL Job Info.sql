/*
BH20230201 : SQL Job Info
*/

--> Job Details
/*
BH20230201 : SQL Job Info
*/

--> Job Details
SELECT 
    [sJOB].[name] AS [JobName]
    , [sDBP].[name] AS [JobOwner]  
  , CASE [sJOB].[enabled]
        WHEN 1 THEN 'Yes'
        WHEN 0 THEN 'No'
      END AS [IsEnabled]
     , CASE
          WHEN [sSCH].[schedule_uid] IS NULL THEN 'No'
          ELSE 'Yes'
          END AS [IsScheduled]
  , case [sJSTP].Last_run_outcome
          When 0 then 'Failed'
          when 1 then 'Succeeded'
          When 2 then 'Retry'
          When 3 then 'Canceled'
          When 5 then 'Unknown'
   End as Last_Run_Status
  , Last_Run = CONVERT(DATETIME, RTRIM(run_date) + ' '
        + STUFF(STUFF(REPLACE(STR(RTRIM(h.run_time),6,0),
        ' ','0'),3,0,':'),6,0,':'))
  , Next_Run= CONVERT(DATETIME, RTRIM(NULLIF([sJOBSCH].next_run_date, 0)) + ' '
        + STUFF(STUFF(REPLACE(STR(RTRIM([sJOBSCH].next_run_time),6,0),
        ' ','0'),3,0,':'),6,0,':'))
 
FROM
    [msdb].[dbo].[sysjobs] AS [sJOB]
    LEFT JOIN [msdb].[sys].[servers] AS [sSVR]
        ON [sJOB].[originating_server_id] = [sSVR].[server_id]
    LEFT JOIN [msdb].[dbo].[syscategories] AS [sCAT]
        ON [sJOB].[category_id] = [sCAT].[category_id]
    LEFT JOIN [msdb].[dbo].[sysjobsteps] AS [sJSTP]
        ON [sJOB].[job_id] = [sJSTP].[job_id]
        AND [sJOB].[start_step_id] = [sJSTP].[step_id]
    LEFT JOIN [msdb].[sys].[database_principals] AS [sDBP]
        ON [sJOB].[owner_sid] = [sDBP].[sid]
    LEFT JOIN [msdb].[dbo].[sysjobschedules] AS [sJOBSCH]
        ON [sJOB].[job_id] = [sJOBSCH].[job_id]
    LEFT JOIN [msdb].[dbo].[sysschedules] AS [sSCH]
        ON [sJOBSCH].[schedule_id] = [sSCH].[schedule_id]

        left JOIN
    (
        SELECT job_id, instance_id = MAX(instance_id),max(run_duration) AS run_duration
            FROM msdb.dbo.sysjobhistory
            GROUP BY job_id
    ) AS l
    ON sJOB.job_id = l.job_id
left JOIN
    msdb.dbo.sysjobhistory AS h
    ON h.job_id = l.job_id
    AND h.instance_id = l.instance_id
ORDER BY [JobName]
