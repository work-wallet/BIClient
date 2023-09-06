DROP TYPE IF EXISTS mart.ETL_InductionTable;
GO

CREATE TYPE mart.ETL_InductionTable AS TABLE
(
    InductionId uniqueidentifier NOT NULL
    ,InductionVersion int NOT NULL
    ,InductionName nvarchar(100) NOT NULL
    ,ValidForDays int NOT NULL
    ,CreatedOn datetimeoffset(7) NOT NULL
    ,Active bit NOT NULL
    ,InductionStatusCode int NOT NULL
    ,TestPassMark int NOT NULL
    ,TestQuestionCount int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (CreatedOn, InductionId, InductionVersion) -- putting CreatedOn first to order the data load
);
GO