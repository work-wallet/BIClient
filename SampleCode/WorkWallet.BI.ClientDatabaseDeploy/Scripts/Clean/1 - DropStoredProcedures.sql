DECLARE @procName varchar(500);

DECLARE cur CURSOR FOR
SELECT
    '[' + s.[name] + ']' + '.' + '[' + p.[name] + ']'
FROM
    sys.procedures AS p
    INNER JOIN sys.schemas AS s ON p.schema_id = s.schema_id
WHERE
    s.[name] = 'mart';

OPEN cur;

FETCH NEXT FROM cur INTO @procName;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC('DROP PROCEDURE ' + @procName);
    FETCH NEXT FROM cur into @procName;
END

CLOSE cur;
DEALLOCATE cur;

GO
