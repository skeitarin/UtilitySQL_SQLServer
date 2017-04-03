/*
* 統計情報の更新
*/

/* DB単位で更新 */
USE <データベース名>; 
GO 
EXEC sp_updatestats; 

/* テーブル、インデックス単位で更新 */
USE <データベース名>; 
GO 
UPDATE STATISTICS <テーブル名 or インデックス付きビュー名>; 
