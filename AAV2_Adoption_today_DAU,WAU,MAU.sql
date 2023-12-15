/*
Author: divya.bhargava
This query can be used to identify the  active users based on the parameter specified. 
If you pass 1 it will give you DAU, if you pass in 7 it will give you WAU and 30 for MAU
*/

with active_users as (
SELECT
AU.user_name as username,
MAX(DATE(AV.ts_created)) AS lastVisitDate,
CURRENT_DATE - MAX(DATE(AV.ts_created)) AS daysSinceLastLogin,
-- If a user has not logged in for more than 30 days, they can be marked as inactive
CASE
WHEN (CURRENT_DATE - MAX(DATE(AV.ts_created))) > ${Day Threshold | eg: 60 } - 1 THEN 'Inactive'
WHEN (CURRENT_DATE - MAX(DATE(AV.ts_created))) <= ${Day Threshold | eg: 60 } -1 THEN 'Active'
END AS activityFlag
FROM
public.visits AS AV
JOIN
public.users AS AU
ON
AU.user_id = AV.user_id
WHERE
AU.is_active = True
GROUP BY
AU.user_name
)
select count(activityflag) as active_users from active_users
where activityflag = 'Active' 