/*
* 断片化率の調査
*/

USE <データベース名>; 
GO 
SELECT ‘ALTER INDEX ‘ + ‘[‘ + C.name + ‘]’ + ‘ ON [‘ + D.name + ‘].[‘ + B.name + ‘] REBUILD’ cmd,      
             D.name AS schemaname,      
             B.name AS table_name,      
             C.name AS index_name,      
             C.index_id, 
             A.partition_number, 
             A.avg_fragmentation_in_percent, 
             A.page_count 
  FROM sys.dm_db_index_physical_stats (DB_ID(),null,null,null,null) as A 
    JOIN  sys.objects AS B 
      ON  A.object_id = B.object_id 
    JOIN  sys.indexes AS C 
      ON  A.object_id = C.object_id  AND A.index_id = C.index_id 
    JOIN  sys.schemas D 
      ON  B.schema_id = D.schema_id 
WHERE B.type = ‘U’ 
      and C.index_id > 0 
      and A.page_count > 1000 　　　　　　　　　　-- ページ数
      and A.avg_fragmentation_in_percent > 30   -- 断片化率
ORDER BY A.avg_fragmentation_in_percent DESC; 
GO
