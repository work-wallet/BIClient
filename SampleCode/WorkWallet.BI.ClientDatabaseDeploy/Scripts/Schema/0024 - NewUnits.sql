-- Add new units of measure to mart.Unit table
-- UnitCode 34-41: Area and Currency units

INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (34, N'Area',     N'Square Meters',     N'm²');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (35, N'Area',     N'Square Kilometers', N'km²');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (36, N'Area',     N'Square Feet',       N'ft²');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (37, N'Power',    N'Kilowatt Hour',     N'kWh');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (38, N'Currency', N'Pound',             N'£');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (39, N'Currency', N'Dollar',            N'$');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (40, N'Currency', N'Euro',              N'€');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (41, N'Currency', N'Yen',               N'¥');

GO
