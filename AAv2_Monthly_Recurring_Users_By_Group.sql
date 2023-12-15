AAv2 - Monthly Recurring Users By Group

--  “monthly recurring users” by group
-- Users with at 5-9 days active previous month

WITH visits as (
SELECT v.user_id,
v.ts_created
FROM public.visits v
),

daily_visits as (

SELECT DISTINCT (u.user_name),
DATE(v.ts_created) as visit_date,
u.user_type
FROM public.users u
JOIN visits v 
ON v.user_id = u.user_id
WHERE DATE(v.ts_created) >= date_trunc('month', current_date - interval '1' month)
AND DATE(v.ts_created) < date_trunc('month', current_date)
GROUP BY 1, 2, 3
ORDER BY user_name, visit_date ASC
),

count_of_visits as (
-- count the number of daily visits by user
  SELECT user_name,
  user_type,
  uers_id
  COUNT(*) AS visits
  FROM daily_visits
  GROUP BY user_name, user_type
),

user_group_tmp as (
-- collect group names associated with users
  SELECT u.user_id
    ,u.user_name
    ,u.user_type
    ,g.group_name 
  FROM public.users u
    JOIN public.user_group_membership m ON u.user_id = m.user_id
    JOIN public.alation_group g ON m.group_id = g.group_id
)



SELECT user_name
,user_type
,visits
FROM count_of_visits cv
JOIN user_group_tmp ug ON cv.user_id = ug.user_id
WHERE visits >= 5
AND visits < 10
GROUP BY user_name, user_type, visits;


