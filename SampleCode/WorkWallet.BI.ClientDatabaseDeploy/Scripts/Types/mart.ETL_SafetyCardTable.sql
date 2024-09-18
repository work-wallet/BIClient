DROP TYPE IF EXISTS mart.ETL_SafetyCardTable;
GO

CREATE TYPE mart.ETL_SafetyCardTable AS TABLE
(
	SafetyCardId uniqueidentifier NOT NULL
	,SafetyCardReference nvarchar(50) NOT NULL
	,SafetyCardTypeCode int NOT NULL
	,ReportedByUser nvarchar(100) NOT NULL
	,ReportedDateTime datetime NOT NULL
	,SafetyCardCategoryId uniqueidentifier NOT NULL
	,Employer nvarchar(max) NOT NULL
	,Employee nvarchar(max) NOT NULL
	,InductionNumber nvarchar(500) NOT NULL
	,ReportDetails nvarchar(max) NOT NULL
	,SafetyCardStatusCode int NOT NULL
	,HasSignature bit NOT NULL
	,SignatureDate datetime NOT NULL
	,Occupation nvarchar(255) NOT NULL
	,OccupationRoleCode int NOT NULL
	,LocationId uniqueidentifier NOT NULL
	,ExternalIdentifier nvarchar(255) NOT NULL
	,WalletId uniqueidentifier NOT NULL
	,PRIMARY KEY (SafetyCardReference, SafetyCardId) -- putting SafetyCardReference first to order the data load
);
GO