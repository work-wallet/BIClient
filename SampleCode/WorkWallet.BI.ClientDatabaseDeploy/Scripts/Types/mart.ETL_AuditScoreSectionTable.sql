DROP TYPE IF EXISTS mart.ETL_AuditScoreSectionTable;
GO

CREATE TYPE mart.ETL_AuditScoreSectionTable AS TABLE
(
    AuditId uniqueidentifier NOT NULL
    ,SectionId uniqueidentifier NOT NULL
    ,Section nvarchar(100) NOT NULL
    ,DisplayScore bit NOT NULL
    ,[Order] int NOT NULL
    ,TotalScore int NOT NULL
    ,TotalPotentialScore int NOT NULL
    ,AverageScore decimal(38,6) NOT NULL
    ,AveragePotentialScore decimal(38,6) NOT NULL
    ,PercentageScore decimal(7,6) NOT NULL
    ,Flags int NOT NULL
    ,GradingSetOptionId uniqueidentifier NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (AuditId, SectionId)
);
GO
