-- add additional OriginalDueOn column for actions
-- (has been back-fixed in the 0007 script)

IF NOT EXISTS(select 1 from sys.columns where [Name] = N'OriginalDueOn' and Object_ID = Object_ID(N'mart.Action'))
BEGIN

    ALTER TABLE
        mart.[Action]
    ADD
        OriginalDueOn date NOT NULL CONSTRAINT DF_mart_Action_OriginalDueOn DEFAULT CAST(0 AS datetime)

    ALTER TABLE mart.[Action] DROP CONSTRAINT DF_mart_Action_OriginalDueOn;

END

GO
