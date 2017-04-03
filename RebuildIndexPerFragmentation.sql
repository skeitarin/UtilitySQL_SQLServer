/*
* 断片化率に応じてインデックスリビルドを行う
* 　断片化率が10~30%：インデックスの再構成
* 　断片化率が30%~：インデックスの再構築
*/


DECLARE
	@SchemaName                     varchar(100)
	, @ObjectName                   varchar(100)
	, @IndexName                    varchar(100)
	, @avg_fragmentation_in_percent int
	, @Sql                          varchar(max)

DECLARE DEFLAG_LIST INSENSITIVE CURSOR FOR
	SELECT   
		D.name AS schemaname,      
		B.name AS table_name,      
		C.name AS index_name,      
		A.avg_fragmentation_in_percent
	FROM sys.dm_db_index_physical_stats (DB_ID(),null,null,null,null) as A 
	    JOIN  sys.objects AS B 
	      ON  A.object_id = B.object_id 
	    JOIN  sys.indexes AS C 
	      ON  A.object_id = C.object_id  AND A.index_id = C.index_id 
	    JOIN  sys.schemas D 
	      ON  B.schema_id = D.schema_id 
	WHERE B.type = 'U'
	      and C.index_id > 0 
	      and A.page_count > 1000 
	      and A.avg_fragmentation_in_percent > 10
	ORDER BY A.avg_fragmentation_in_percent DESC; 

OPEN DEFLAG_LIST;

FETCH NEXT FROM
	DEFLAG_LIST
INTO
	@SchemaName
	,@ObjectName
	,@IndexName
	,@avg_fragmentation_in_percent
;

WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @avg_fragmentation_in_percent < 30.0
		BEGIN
			SET @Sql = N'ALTER INDEX ' + @IndexName + N' ON ' + @SchemaName + N'.' + @ObjectName + N' REORGANIZE';
		END
		ELSE
		BEGIN
		    SET @Sql = N'ALTER INDEX ' + @IndexName + N' ON ' + @SchemaName + N'.' + @ObjectName + N' REBUILD';
		END
		print(@Sql);
		EXEC (@Sql);
		
		BEGIN
			/* 次の件数へ */
			FETCH NEXT FROM
				DEFLAG_LIST
			INTO
				@SchemaName
				,@ObjectName
				,@IndexName
				,@avg_fragmentation_in_percent
			;
			CONTINUE;
		END;
	END;

CLOSE DEFLAG_LIST;
DEALLOCATE DEFLAG_LIST;
