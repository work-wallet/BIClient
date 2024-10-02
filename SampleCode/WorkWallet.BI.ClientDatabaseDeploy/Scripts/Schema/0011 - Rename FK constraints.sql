-- remove the erroneous "dbo." for all the constraint names in the mart schema
-- this has been back-fixed into the preceding scripts

DECLARE @name nvarchar(128);

DECLARE db_cursor CURSOR FOR
SELECT
    obj.[name]
FROM
    sys.foreign_key_columns AS fkc
    INNER JOIN sys.objects AS obj ON fkc.constraint_object_id = obj.object_id
    INNER JOIN sys.schemas AS sch ON obj.schema_id = sch.schema_id
WHERE
    sch.[name] = 'mart';

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @name;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF CHARINDEX(N'dbo.mart', @name) > 0
    BEGIN
        DECLARE @oldConstraintName nvarchar(255) = N'mart.[' + @name + N']';
        DECLARE @newName nvarchar(128) = REPLACE(@name, N'dbo.mart', N'mart');

        EXEC sp_rename @oldConstraintName, @newName, N'OBJECT';
    END

    FETCH NEXT FROM db_cursor INTO @name;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

GO