
--------------
-- DAU, MAU, DAU/MAU
-------------- 

-- DAU (Daily Active Users) = Active Unique Visitor of a Day
-- Average DAU = Active Unique Visitor of a Day, average 30 days rolling
 
-- MAU (Monthly Active Users) = Active Unique Visitor of a 30 days period rolling
-- Average MAU = MAU average 30 days rolling

-- DAU/MAU = represent stickiness, for example: 50% means that the application is visited 15 days out of 30
-- DAU/MAU Average = DAU/MAU average 30 days rolling




WITH 

-- List of all days from first visit to last visit
days_list AS (

    SELECT TO_CHAR(
             generate_series(
                 (select min(ts_created) AS end_date from public.visits)::date, 
                 (select max(ts_created) AS end_date from public.visits)::date, 
                 '1 day'
              )
              , 'YYYY-MM-DD') 
              AS visit_date
)

-- Sum of Each Day's Unique Users
, daily_visits AS (
    SELECT 
        visit_date
            AS visit_date
        ,COUNT(DISTINCT user_id) AS daily_visits
        ,COUNT(DISTINCT user_id) AS DAU
    FROM (SELECT TO_CHAR(DATE(ts_created), 'YYYY-MM-DD')  AS visit_date, ts_created AS visit_date_ts, user_id FROM visits) user_visit_day
    GROUP BY 1
    ORDER BY 1 DESC
)

,report_DAU_MAU AS (
  select mau.date1 AS date
    ,dv.dau AS DAU
    ,AVG(dv.dau::real) OVER (ORDER BY DATE(mau.date1) RANGE BETWEEN INTERVAL '29 days' PRECEDING AND CURRENT ROW) AS DAU_avg
    ,mau.mau_rolling AS MAU
    ,AVG(mau.mau_rolling::real) OVER (ORDER BY DATE(mau.date1) RANGE BETWEEN INTERVAL '29 days' PRECEDING AND CURRENT ROW) AS MAU_avg
    ,(dv.dau::real / mau.mau_rolling::real)::real AS dau_on_mau 
    , SUM(dv.dau::real / mau.mau_rolling::real) OVER (ORDER BY DATE(mau.date1) RANGE BETWEEN INTERVAL '29 days' PRECEDING AND CURRENT ROW) / 30 AS dau_on_mau_avg
    
    from (
      select d.date1, count(distinct u.user_id) AS mau_rolling
      
      from (
        select d1.visit_date AS date1, d2.visit_date AS date2
        from days_list d1
        left join days_list d2 on DATE(d1.visit_date) >= DATE(d2.visit_date) and DATE(d1.visit_date) - '29 DAYS'::INTERVAL <= DATE(d2.visit_date) 
      ) d
      join (SELECT distinct TO_CHAR(DATE(ts_created), 'YYYY-MM-DD') AS visit_date, user_id FROM visits) u on d.date2 = u.visit_date
      group by 1
      order by 1 asc
    ) mau
    join daily_visits dv on mau.date1 = dv.visit_date
)


SELECT date
  ,dau
  ,dau_avg
  ,mau
  ,mau_avg
  ,dau_on_mau
  ,dau_on_mau_avg

FROM report_DAU_MAU;


--------------
-- WAU
--------------
-- WAU = Sum of each week's unique users

WITH 

-- List of all days from first visit to last visit
days_list AS (

    SELECT TO_CHAR(
             generate_series(
                 (select min(ts_created) AS end_date from public.visits)::date, 
                 (select max(ts_created) AS end_date from public.visits)::date, 
                 '1 day'
              )
              , 'YYYY-MM-DD') 
              AS visit_date
)

-- Sum of Each Day's Unique Users
, daily_visits AS (
    SELECT 
        visit_date
            AS visit_date
        ,COUNT(DISTINCT user_id) AS daily_visits
        ,COUNT(DISTINCT user_id) AS DAU
    FROM (SELECT TO_CHAR(DATE(ts_created), 'YYYY-MM-DD')  AS visit_date, ts_created AS visit_date_ts, user_id FROM visits) user_visit_day
    GROUP BY 1
    ORDER BY 1 DESC
)
,report_WAU AS (
    SELECT
        TO_CHAR(DATE(visit_date), 'YYYY')|| '-' || TO_CHAR(DATE(visit_date), 'WW') AS year_week,
        SUM(daily_visits) AS weekly_visits
    FROM  (SELECT dl.visit_date, dv.daily_visits  FROM days_list dl
        LEFT JOIN daily_visits dv ON dv.visit_date = dl.visit_date) subquery
    GROUP BY 1
    ORDER BY 1 asc
)

SELECT * FROM report_WAU;


--------------
--  MONTHLY MAU (Not rolling)
--------------

WITH


-- List of all days from first visit to last visit
days_list AS (

    SELECT TO_CHAR(
            generate_series(
                (select min(ts_created) AS end_date from public.visits)::date, 
                (select max(ts_created) AS end_date from public.visits)::date, 
                '1 day'
              )
              , 'YYYY-MM-DD') 
              AS visit_date
)

-- Sum of Each Day's Unique Users
,daily_visits AS (
    SELECT 
        visit_date
            AS visit_date
        ,COUNT(DISTINCT user_id) AS daily_visits
        ,COUNT(DISTINCT user_id) AS DAU
    FROM (SELECT TO_CHAR(DATE(ts_created), 'YYYY-MM-DD')  AS visit_date, ts_created AS visit_date_ts, user_id FROM visits) user_visit_day
    GROUP BY 1
    ORDER BY 1 DESC
)

-- ,avg_rolling_dau AS (
--     SELECT 
--         visit_date,
--         daily_visits,
--         SUM(daily_visits) OVER (ORDER BY DATE(visit_date) RANGE BETWEEN INTERVAL '29 days' PRECEDING AND CURRENT ROW) AS sum_visits_30day_rolling,
--         SUM(daily_visits) OVER (ORDER BY DATE(visit_date) RANGE BETWEEN INTERVAL '29 days' PRECEDING AND CURRENT ROW) / 30 AS avg_visits_30day_rolling
--     FROM (SELECT dl.visit_date, dv.daily_visits  FROM days_list dl
--     LEFT JOIN daily_visits dv ON dv.visit_date = dl.visit_date) subquery
--     ORDER BY 
--         1 ASC
--     )
  
-- Monthly visists (first day of the month)
,monthly_visits AS (
    SELECT 
        visit_date || '-01'
              AS visit_date, 
        COUNT (DISTINCT user_id) 
              AS monthly_visits
    FROM (SELECT TO_CHAR(DATE(ts_created), 'YYYY-MM') AS visit_date, user_id FROM visits) user_visit_month

    GROUP BY 1  
)

-- Number of Days in the Month
,days_in_a_month AS (
            SELECT 
                TO_CHAR(month_start, 'YYYY-MM') || '-01' AS visit_date,
                    DATE_PART('days', 
                    DATE_TRUNC('month', month_start
                    ) 
                    + '1 MONTH'::INTERVAL 
                    - '1 DAY'::INTERVAL
                ) days_in_month
            FROM 
                (SELECT 
                      DATE_TRUNC('month', generate_series((select min(ts_created) AS end_date from public.visits)::date, (select max(ts_created) AS end_date from public.visits)::date, '1 month')) AS month_start) months
)

-- Average DAU Calculation: monthly DAU / Days in a month
-- ,average_monthly_dau AS (
--     SELECT 
--         mv.visit_date,
--         mv.monthly_visits,
--         mday.days_in_month, 
--         mv.monthly_visits / mday.days_in_month AS avg_monthly_visits
--     FROM monthly_visits mv
--     LEFT JOIN days_in_a_month mday on mv.visit_date = mday.visit_date
-- )


,report_MAU AS (
    SELECT 
        dl.visit_date
        ,mv.monthly_visits AS MAU
        -- ,amd.avg_monthly_visits AS DAU_avg_monthly
        --,amd.days_in_month 
  
    FROM days_list dl
    LEFT JOIN monthly_visits mv on mv.visit_date = dl.visit_date
    -- LEFT JOIN average_monthly_dau amd on amd.visit_date = dl.visit_date
    WHERE mv.monthly_visits is not null
)


-- , report_DAU AS (
--     SELECT dl.visit_date
--         ,COALESCE(dv.daily_visits, 0) AS DAU
--         ,ard.avg_visits_30day_rolling AS DAU_avg_30d_rolling
--         ,ard.sum_visits_30day_rolling  AS MAU_30d_rolling
--         ,COALESCE(dv.daily_visits, 0) / ard.avg_visits_30day_rolling AS DAU_MAU_rolling
        
--     FROM days_list dl
--     LEFT JOIN daily_visits dv ON dv.visit_date = dl.visit_date
--     LEFT JOIN avg_rolling_dau ard ON ard.visit_date = dl.visit_date
-- )

select * from report_MAU;







