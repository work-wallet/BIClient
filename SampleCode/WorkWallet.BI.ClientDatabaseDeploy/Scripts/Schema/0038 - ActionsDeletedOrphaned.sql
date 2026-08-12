-- Additive, non-breaking API change: split the previously conflated Actions.Deleted flag
-- into IsDeleted (real delete) and IsOrphaned (parent/target no longer exists or was removed
-- while in progress). Deleted is kept for backward compatibility but is now deprecated.

IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE [Name] = N'IsDeleted' AND object_id = OBJECT_ID(N'mart.[Action]'))
BEGIN

    -- IsDeleted backfilled from the existing Deleted column (a DEFAULT constraint can't reference another column)
    ALTER TABLE mart.[Action]
    ADD
        IsDeleted bit NULL
        ,IsOrphaned bit NOT NULL
        CONSTRAINT [DF_mart.Action_IsOrphaned] DEFAULT (0) WITH VALUES;

END

GO

-- separate batch: IsDeleted must exist (per the ALTER above) before it can be referenced here
IF EXISTS(SELECT 1 FROM sys.columns WHERE [Name] = N'IsDeleted' AND object_id = OBJECT_ID(N'mart.[Action]') AND is_nullable = 1)
BEGIN

    UPDATE mart.[Action] SET IsDeleted = Deleted;

    ALTER TABLE mart.[Action] ALTER COLUMN IsDeleted bit NOT NULL;
    ALTER TABLE mart.[Action] DROP CONSTRAINT [DF_mart.Action_IsOrphaned];

END

GO
