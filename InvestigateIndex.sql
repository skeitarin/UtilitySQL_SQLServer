--不足インデックス取得
SELECT  TOP 20
        [Total Cost]  = ROUND(avg_total_user_cost * avg_user_impact * (user_seeks + user_scans),0) 
        , avg_user_impact
        , statement AS テーブル名
        , equality_columns   as 等号列
        , inequality_columns as 不等号列
        , included_columns   as 付加列
FROM        sys.dm_db_missing_index_groups g 
INNER JOIN    sys.dm_db_missing_index_group_stats s 
       ON s.group_handle = g.index_group_handle 
INNER JOIN    sys.dm_db_missing_index_details d 
       ON d.index_handle = g.index_handle
ORDER BY [Total Cost] DESC;


--インデックス使用状況確認
SELECT OBJECT_NAME(s.[object_id]) AS [ObjectName] , 
i.name AS [IndexName] , i.index_id , 
user_seeks + user_scans + user_lookups AS [Reads] , 
user_updates AS [Writes] , 
i.type_desc AS [IndexType] , 
i.fill_factor AS [FillFactor]
FROM sys.dm_db_index_usage_stats AS s 
INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
WHERE OBJECTPROPERTY(s.[object_id], 'IsUserTable') = 1 
AND i.index_id = s.index_id 
AND s.database_id = DB_ID()
ORDER BY OBJECT_NAME(s.[object_id]) , 
writes DESC ,
reads DESC ;

--未使用インデックス取得
SELECT OBJECT_NAME(i.[object_id]) AS [Table Name] ,
i.name
FROM sys.indexes AS i 
INNER JOIN sys.objects AS o ON i.[object_id] = o.[object_id]
WHERE i.index_id NOT IN ( SELECT s.index_id 
FROM sys.dm_db_index_usage_stats AS s 
WHERE s.[object_id] = i.[object_id] 
AND i.index_id = s.index_id 
AND database_id = DB_ID() ) 
AND o.[type] = 'U'
ORDER BY OBJECT_NAME(i.[object_id]) ASC ;

--使用頻度の少ないインデックスを取得
SELECT OBJECT_NAME(s.[object_id]) AS [Table Name] , 
i.name AS [Index Name] , 
i.index_id , 
user_updates AS [Total Writes] , 
user_seeks + user_scans + user_lookups AS [Total Reads] , 
user_updates - ( user_seeks + user_scans + user_lookups ) 
AS [Difference]
FROM sys.dm_db_index_usage_stats AS s WITH ( NOLOCK ) 
INNER JOIN sys.indexes AS i WITH ( NOLOCK ) 
ON s.[object_id] = i.[object_id] 
AND i.index_id = s.index_id
WHERE OBJECTPROPERTY(s.[object_id], 'IsUserTable') = 1 
AND s.database_id = DB_ID() 
AND user_updates > ( user_seeks + user_scans + user_lookups ) 
AND i.index_id > 1
ORDER BY [Difference] DESC , 
[Total Writes] DESC , 
[Total Reads] ASC ;


