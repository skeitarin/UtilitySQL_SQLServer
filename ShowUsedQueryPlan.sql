select * from sys.dm_exec_cached_plans
cross apply sys.dm_exec_sql_text(plan_handle) ss
cross apply sys.dm_exec_query_plan(plan_handle) -- プランもみたいときはコメント外す
--cross apply sys.dm_exec_plan_attributes(plan_handle) sb -- 細かいメタデータ見なくていいときはコメントアウト
where 
text like '%@DT_PRCSS_DATE_F%' -- ここで絞込み
and ss.dbid = DB_ID('AKT_DSUM') -- DB名指定
and not text like '%sys.dm_exec_cached_plans%' -- このクエリ自体を除外 
