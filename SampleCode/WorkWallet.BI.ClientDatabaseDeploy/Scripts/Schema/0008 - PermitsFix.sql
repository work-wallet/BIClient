-- correct the length of the PermitDescription column (has been back-fixed in the 0006 script)
IF (COL_LENGTH('mart.Permit', 'PermitDescription') <> 1500)
BEGIN
    ALTER TABLE mart.Permit ALTER COLUMN PermitDescription nvarchar(750) NOT NULL;
END

GO
