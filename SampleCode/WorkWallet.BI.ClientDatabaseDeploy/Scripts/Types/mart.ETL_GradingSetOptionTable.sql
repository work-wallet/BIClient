DROP TYPE IF EXISTS mart.ETL_GradingSetOptionTable;
GO

CREATE TYPE mart.ETL_GradingSetOptionTable AS TABLE
(
    GradingSetId uniqueidentifier NOT NULL
    ,GradingSetVersion int NOT NULL
    ,GradingSetOptionId uniqueidentifier NOT NULL
    ,GradingSet nvarchar(100) NOT NULL
    ,GradingSetOption nvarchar(250) NOT NULL
    ,[Value] int NOT NULL
    ,ColourHex nvarchar(7) NOT NULL
    ,GradingSetIsPercentage bit NOT NULL
    ,GradingSetIsScore bit NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (GradingSet, [Value], GradingSetOptionId) -- putting GradingSet, [Value] first to order the data for better readability
);
GO
