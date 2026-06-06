-- Location: Update Department column nvarchar(50) to match various source tables

-- Location dimension table
ALTER TABLE mart.[Location]
    ALTER COLUMN Department nvarchar(50) NOT NULL;

GO
