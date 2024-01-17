DROP TYPE IF EXISTS mart.ETL_AssetTable;
GO

CREATE TYPE mart.ETL_AssetTable AS TABLE
(
	AssetId uniqueidentifier NOT NULL
	,AssetType nvarchar(75) NOT NULL
	,AssetStatusCode int NOT NULL
	,Reference nvarchar(143) NOT NULL
	,[Name] nvarchar(75) NOT NULL
	,[Description] nvarchar(max) NOT NULL
	,CreatedOn datetimeoffset(7) NOT NULL
	,WalletId uniqueidentifier NOT NULL
	,PRIMARY KEY (CreatedOn, AssetId) -- putting CreatedOn first to order the data load
);
GO
