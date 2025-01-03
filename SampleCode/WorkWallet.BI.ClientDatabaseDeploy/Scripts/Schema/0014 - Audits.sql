CREATE TABLE mart.AuditStatus
(
    AuditStatus_key int IDENTITY
    ,AuditStatusCode int NOT NULL /* business key */
    ,AuditStatus nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditStatus__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditStatus] PRIMARY KEY (AuditStatus_key)
    ,CONSTRAINT [UQ_mart.AuditStatus_AuditStatusCode] UNIQUE (AuditStatusCode)
);

INSERT INTO mart.AuditStatus (AuditStatusCode, AuditStatus) VALUES (0, N'Planned');
INSERT INTO mart.AuditStatus (AuditStatusCode, AuditStatus) VALUES (1, N'Report In Progress');
INSERT INTO mart.AuditStatus (AuditStatusCode, AuditStatus) VALUES (2, N'Ready For Review');
INSERT INTO mart.AuditStatus (AuditStatusCode, AuditStatus) VALUES (3, N'Complete');
INSERT INTO mart.AuditStatus (AuditStatusCode, AuditStatus) VALUES (4, N'Cancelled');
INSERT INTO mart.AuditStatus (AuditStatusCode, AuditStatus) VALUES (5, N'Deleted');
INSERT INTO mart.AuditStatus (AuditStatusCode, AuditStatus) VALUES (6, N'Closed');
INSERT INTO mart.AuditStatus (AuditStatusCode, AuditStatus) VALUES (7, N'Archived');

CREATE TABLE mart.Unit
(
    Unit_key int IDENTITY
    ,UnitCode int NOT NULL /* business key */
    ,[Group] nvarchar(50) NOT NULL
    ,Unit nvarchar(50) NOT NULL
    ,UnitAcronym nvarchar(10) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.Unit__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.Unit] PRIMARY KEY (Unit_key)
    ,CONSTRAINT [UQ_mart.Unit_UnitCode] UNIQUE (UnitCode)
);

INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (0,  N'None',          N'',                       N'');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (1,  N'Distance',      N'Inch',                   N'in');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (2,  N'Distance',      N'Foot',                   N'ft');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (3,  N'Distance',      N'Mile',                   N'mi');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (4,  N'Distance',      N'Millimetre',             N'mm');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (5,  N'Distance',      N'Centimetre',             N'cm');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (6,  N'Distance',      N'Metre',                  N'm');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (7,  N'Distance',      N'Kilometre',              N'km');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (8,  N'Volume',        N'Millilitre',             N'ml');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (9,  N'Volume',        N'Litre',                  N'l');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (10, N'Volume',        N'Gallon',                 N'gal');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (11, N'Volume',        N'Cubic Metre',            N'm³');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (12, N'Time',          N'Hour',                   N'hr');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (13, N'Time',          N'Minute',                 N'min');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (14, N'Time',          N'Second',                 N's');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (15, N'Temperature',   N'Fahrenheit',             N'°F');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (16, N'Temperature',   N'Celsius',                N'°C');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (17, N'Temperature',   N'Kelvin',                 N'K');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (18, N'Weight',        N'Ounce',                  N'oz');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (19, N'Weight',        N'Pound',                  N'lb');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (20, N'Weight',        N'Ton',                    N'ton');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (21, N'Weight',        N'Tonne',                  N't');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (22, N'Weight',        N'Gram',                   N'g');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (23, N'Weight',        N'Kilogram',               N'kg');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (24, N'Power',         N'Ampere',                 N'A');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (25, N'Power',         N'Hertz',                  N'Hz');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (26, N'Power',         N'Ohm',                    N'Ω');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (27, N'Power',         N'Volt',                   N'V');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (28, N'Power',         N'Watt',                   N'W');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (29, N'Miscellaneous', N'Bar',                    N'bar');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (30, N'Miscellaneous', N'Candela',                N'cd');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (31, N'Miscellaneous', N'Cycles',                 N'cycles');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (32, N'Miscellaneous', N'Percent',                N'%');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (33, N'Miscellaneous', N'Pounds Per Square Inch', N'psi');

GO
