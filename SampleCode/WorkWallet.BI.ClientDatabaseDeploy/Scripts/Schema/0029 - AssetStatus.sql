-- Add DisplayOrder column to existing AssetStatus table
ALTER TABLE mart.AssetStatus ADD DisplayOrder int NOT NULL CONSTRAINT [DF_mart.AssetStatus_DisplayOrder] DEFAULT 0;
GO

-- Insert missing asset status records
INSERT INTO mart.AssetStatus (AssetStatusCode, AssetStatus) VALUES (4, N'Ordered');
INSERT INTO mart.AssetStatus (AssetStatusCode, AssetStatus) VALUES (5, N'Off-Hired');
INSERT INTO mart.AssetStatus (AssetStatusCode, AssetStatus) VALUES (6, N'Lost / Write-Off');
INSERT INTO mart.AssetStatus (AssetStatusCode, AssetStatus) VALUES (7, N'Disposed');
GO

-- Update all records with DisplayOrder values
UPDATE mart.AssetStatus SET DisplayOrder = 2 WHERE AssetStatusCode = 0;
UPDATE mart.AssetStatus SET DisplayOrder = 3 WHERE AssetStatusCode = 1;
UPDATE mart.AssetStatus SET DisplayOrder = 4 WHERE AssetStatusCode = 2;
UPDATE mart.AssetStatus SET DisplayOrder = 8 WHERE AssetStatusCode = 3;
UPDATE mart.AssetStatus SET DisplayOrder = 1 WHERE AssetStatusCode = 4;
UPDATE mart.AssetStatus SET DisplayOrder = 5 WHERE AssetStatusCode = 5;
UPDATE mart.AssetStatus SET DisplayOrder = 6 WHERE AssetStatusCode = 6;
UPDATE mart.AssetStatus SET DisplayOrder = 7 WHERE AssetStatusCode = 7;
GO

-- Drop the default constraint now that all values have been set
ALTER TABLE mart.AssetStatus DROP CONSTRAINT [DF_mart.AssetStatus_DisplayOrder];
GO
