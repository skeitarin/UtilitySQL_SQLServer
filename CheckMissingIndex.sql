--不足インデックス取得
SELECT  TOP 20
        [Total Cost]  = ROUND(avg_total_user_cost * avg_user_impact * (user_seeks + user_scans),0) 
        , avg_user_impact
        , statement AS テーブル名
        , equality_columns   as 等号列
        , inequality_columns as 不等号列
        , included_columns   as '付加列（includeで付加するとなおよし）'
FROM        sys.dm_db_missing_index_groups g 
INNER JOIN    sys.dm_db_missing_index_group_stats s 
       ON s.group_handle = g.index_group_handle 
INNER JOIN    sys.dm_db_missing_index_details d 
       ON d.index_handle = g.index_handle
ORDER BY [Total Cost] DESC; 
 
