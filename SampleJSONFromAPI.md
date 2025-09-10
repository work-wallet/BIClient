# Sample JSON Data from the Work Wallet API

This file contains sample JSON responses from the Work Wallet BI Extract API for each supported dataset.
The samples are indicative and may not be realistic or represent the full range of data returned by the API.

Each sample shows the standard response structure including:

- **Context**: Pagination and synchronization metadata
- **Wallets**: Wallet information for the returned data
- **Dataset-specific arrays**: The actual data for each dataset type

## Datasets

- [Actions](#actions)
- [Assets](#assets)
- [Audits](#audits)
- [Inductions](#inductions)
- [Permits](#permits)
- [PPEAssignments](#ppeassignments)
- [PPEStockHistories](#ppestockhistories)
- [PPEStocks](#ppestocks)
- [ReportedIssues](#reportedissues)
- [SafetyCards](#safetycards)

## Actions

```json
{
  "Context": {
    "Version": 1,
    "Count": 1,
    "FullCount": 1,
    "PageNumber": 1,
    "PageSize": 500,
    "LastSynchronizationVersion": 1050,
    "SynchronizationVersion": 1200,
    "MinValidSynchronizationVersion": 900,
    "Error": "",
    "UTC": "2025-09-10T12:00:00Z"
  },
  "Wallets": [
    {
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77",
      "Wallet": "Northwind Construction Ltd"
    }
  ],
  "Actions": [
    {
      "ActionId": "7e1b2c3d-4e5f-4a67-9abc-12de34f56a78",
      "ActionTypeCode": 2,
      "TargetId": "3f8b1a22-b7c4-4d2b-8a1e-5be7d6c4a1f2",
      "TargetReference": "NWC-01234",
      "Title": "Replace damaged ladder at Warehouse 3",
      "Description": "Inspect the damaged ladder reported during shift change and replace it with a certified unit. Tag out the old ladder and record disposal.",
      "AssignedTo": "Avery Example",
      "PriorityCode": 4,
      "DueOn": "2025-09-20",
      "ActionStatusCode": 2,
      "Deleted": false,
      "CreatedOn": "2025-09-01T08:30:15.1234567+00:00",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "ActionUpdates": [
    {
      "ActionUpdateId": "5a6b7c8d-90e1-42f3-a4b5-6c7d8e9f0a1b",
      "ActionId": "7e1b2c3d-4e5f-4a67-9abc-12de34f56a78",
      "Comments": "Replacement ladder delivered and installed. Old unit removed from service and tagged for disposal.",
      "ActionStatusCode": 2,
      "Deleted": false,
      "CreatedOn": "2025-09-03T14:05:00+00:00",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ]
}
```

## Assets

```json
{
  "Context": {
    "Version": 1,
    "Count": 1,
    "FullCount": 1,
    "PageNumber": 1,
    "PageSize": 500,
    "LastSynchronizationVersion": 1050,
    "SynchronizationVersion": 1200,
    "MinValidSynchronizationVersion": 900,
    "Error": "",
    "UTC": "2025-09-10T10:22:00Z"
  },
  "Wallets": [
    {
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77",
      "Wallet": "Northwind Construction Ltd"
    }
  ],
  "Assets": [
    {
      "AssetId": "2a1bdc44-6e3b-4d2c-9ab7-1e5c0b9f3a21",
      "AssetType": "Forklift Truck",
      "AssetStatusCode": 0,
      "Reference": "NWC-00421",
      "Name": "Warehouse Forklift A",
      "Description": "3.5T diesel forklift used in North Yard loading bay. Next service due Q4.",
      "CreatedOn": "2025-08-30T09:15:42.1234567+00:00",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "Properties": [
    {
      "AssetId": "2a1bdc44-6e3b-4d2c-9ab7-1e5c0b9f3a21",
      "Property": "Load Capacity (kg)",
      "PropertyType": "Number",
      "Value": "2500",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "Assignments": [
    {
      "AssetId": "2a1bdc44-6e3b-4d2c-9ab7-1e5c0b9f3a21",
      "AssignedOn": "2025-09-01T08:00:00+00:00",
      "AssignmentType": "Site",
      "AssignedTo": "Acme Utilities Ltd - North Yard",
      "CompanyId": "a1b2c3d4-1111-2222-3333-444455556666",
      "Company": "Acme Utilities Ltd",
      "SiteId": "0f1e2d3c-aaaa-bbbb-cccc-ddddeeeeffff",
      "Site": "North Yard",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ]
}
```

## Audits

```json
{
  "Context": {
    "Version": 1,
    "Count": 1,
    "FullCount": 1,
    "PageNumber": 1,
    "PageSize": 500,
    "LastSynchronizationVersion": 1050,
    "SynchronizationVersion": 1200,
    "MinValidSynchronizationVersion": 900,
    "Error": "",
    "UTC": "2025-09-10T10:12:34Z"
  },
  "Wallets": [
    {
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77",
      "Wallet": "Northwind Construction Ltd"
    }
  ],
  "Locations": [
    {
      "LocationId": "2f1d3b8a-5c2e-4f3b-9a4b-2c3d4e5f6a7b",
      "LocationTypeCode": 2,
      "LocationType": "Operations Site",
      "Location": "Northwind Construction - Warehouse 1",
      "CompanyId": "4e3c2b1a-9d8e-47f6-bb44-1a2b3c4d5e6f",
      "Company": "Northwind Construction Ltd",
      "SiteId": "7a1c2d3e-4f56-4a78-9b10-112233445566",
      "Site": "Riverside Project",
      "AreaId": "0c9c2a1b-3d4e-4f56-8a7b-223344556677",
      "Area": "Warehouse 1",
      "JobId": "00000000-0000-0000-0000-000000000000",
      "Job": "",
      "SiteLocationId": "5b4c3d2e-1f0a-413b-8c9d-7e6f5a4b3c2d",
      "Department": "Operations",
      "ExternalIdentifier": "LOC-OPS-WH1",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "GradingSetOptions": [
    {
      "GradingSetId": "b2a1c3d4-e5f6-4789-ab12-34567890abcd",
      "GradingSetVersion": 3,
      "GradingSetOptionId": "c3d4e5f6-a1b2-4c3d-9e8f-001122334455",
      "GradingSet": "Compliance",
      "GradingSetOption": "Green",
      "Value": 90,
      "ColourHex": "#4CAF50",
      "GradingSetIsPercentage": true,
      "GradingSetIsScore": false,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "AuditTypes": [
    {
      "AuditTypeId": "d1e2f3a4-b5c6-4d7e-8f90-a1b2c3d4e5f6",
      "AuditTypeVersion": 2,
      "AuditType": "Site Safety Inspection",
      "Description": "Routine workplace safety inspection covering housekeeping, equipment, and emergency preparedness.",
      "ScoringEnabled": true,
      "DisplayPercentage": true,
      "DisplayTotalScore": false,
      "DisplayAverageScore": false,
      "GradingSetId": "b2a1c3d4-e5f6-4789-ab12-34567890abcd",
      "GradingSetVersion": 3,
      "GradingSet": "Compliance",
      "GradingSetIsPercentage": true,
      "GradingSetIsScore": false,
      "ReportingEnabled": true,
      "ReportingAbbreviation": "SSI",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "Audits": [
    {
      "AuditId": "a0b1c2d3-e4f5-4a67-8b90-1c2d3e4f5a6b",
      "Reference": 1234,
      "AuditReference": "NWC-01234",
      "AuditGroupId": "11223344-5566-4777-8899-aabbccddeeff",
      "AuditGroup": "Monthly HSE",
      "AuditStatusCode": 3,
      "AuditTypeId": "d1e2f3a4-b5c6-4d7e-8f90-a1b2c3d4e5f6",
      "AuditTypeVersion": 2,
      "LocationId": "2f1d3b8a-5c2e-4f3b-9a4b-2c3d4e5f6a7b",
      "InspectedOn": "2025-09-05T09:15:00Z",
      "TotalScore": 85,
      "TotalPotentialScore": 100,
      "AverageScore": 4.5,
      "AveragePotentialScore": 5.0,
      "PercentageScore": 0.85,
      "Flags": 0,
      "GradingSetOptionId": "c3d4e5f6-a1b2-4c3d-9e8f-001122334455",
      "ExternalIdentifier": "AUD-2025-0001",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "Contacts": [
    {
      "ContactId": "0aa1bb22-cc33-4dd4-8ee5-ff6677889900",
      "Name": "Taylor Example",
      "EmailAddress": "taylor.example@example.invalid",
      "CompanyName": "Northwind Construction Ltd",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "AuditInspectors": [
    {
      "AuditId": "a0b1c2d3-e4f5-4a67-8b90-1c2d3e4f5a6b",
      "ContactId": "0aa1bb22-cc33-4dd4-8ee5-ff6677889900",
      "Name": "Taylor Example",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "AuditNumericAnswers": [
    {
      "AuditId": "a0b1c2d3-e4f5-4a67-8b90-1c2d3e4f5a6b",
      "QuestionId": "ab12cd34-ef56-4789-90ab-cdef12345678",
      "Question": "Distance to nearest emergency exit (m)",
      "Mandatory": true,
      "Scale": 2,
      "UnitCode": 6,
      "Answer": 12.5,
      "SectionId": "22334455-6677-4888-99aa-bbccddeeff00",
      "Section": "General Safety",
      "OrderInSection": 1,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "AuditDateTimeAnswers": [
    {
      "AuditId": "a0b1c2d3-e4f5-4a67-8b90-1c2d3e4f5a6b",
      "QuestionId": "bb22cc33-dd44-4ee5-9ff6-001122334466",
      "Question": "Emergency drill date and time",
      "Mandatory": false,
      "Date": true,
      "Time": true,
      "Answer": "2025-08-30T09:30:00Z",
      "SectionId": "33445566-7788-4999-aabb-ccddeeff0011",
      "Section": "Emergency Preparedness",
      "OrderInSection": 2,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "AuditChecklistAnswers": [
    {
      "AuditId": "a0b1c2d3-e4f5-4a67-8b90-1c2d3e4f5a6b",
      "ChecklistId": "cc33dd44-ee55-4666-8f77-8899aabbccdd",
      "OptionId": "dd44ee55-ff66-4777-9888-99aabbccddee",
      "Question": "PPE available and in good condition",
      "Value": "Yes",
      "Mandatory": true,
      "Order": 1,
      "SectionId": "44556677-8899-4aaa-bbcc-ddeeff001122",
      "Section": "PPE",
      "OrderInSection": 3,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "AuditBranchOptions": [
    {
      "AuditId": "a0b1c2d3-e4f5-4a67-8b90-1c2d3e4f5a6b",
      "BranchId": "ee55ff66-0011-4222-8333-445566778899",
      "OptionId": "ff66aabb-1122-4333-8444-5566778899aa",
      "Branch": "Equipment Condition",
      "Value": "Requires Maintenance",
      "Order": 2,
      "SectionId": "55667788-99aa-4bbb-ccdd-eeff00112233",
      "Section": "Equipment",
      "OrderInSection": 4,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "AuditScoredResponses": [
    {
      "AuditId": "a0b1c2d3-e4f5-4a67-8b90-1c2d3e4f5a6b",
      "BranchId": "11aa22bb-33cc-44dd-85ee-66778899aabb",
      "OptionId": "22bb33cc-44dd-46ee-86ff-778899aabbcc",
      "Branch": "Housekeeping Score",
      "Value": "Good",
      "Order": 1,
      "TotalScore": 8,
      "TotalPotentialScore": 10,
      "PercentageScore": 0.8,
      "Flag": false,
      "GradingSetOptionId": "c3d4e5f6-a1b2-4c3d-9e8f-001122334455",
      "SectionId": "66778899-aabb-4ccc-ddee-ff0011223344",
      "Section": "Housekeeping",
      "OrderInSection": 5,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "AuditScoreSections": [
    {
      "AuditId": "a0b1c2d3-e4f5-4a67-8b90-1c2d3e4f5a6b",
      "SectionId": "66778899-aabb-4ccc-ddee-ff0011223344",
      "Section": "Housekeeping",
      "DisplayScore": true,
      "Order": 1,
      "TotalScore": 40,
      "TotalPotentialScore": 50,
      "AverageScore": 4.0,
      "AveragePotentialScore": 5.0,
      "PercentageScore": 0.8,
      "Flags": 0,
      "GradingSetOptionId": "c3d4e5f6-a1b2-4c3d-9e8f-001122334455",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "AuditScoreTags": [
    {
      "AuditId": "a0b1c2d3-e4f5-4a67-8b90-1c2d3e4f5a6b",
      "TagId": "778899aa-bbcc-4dde-aaff-001122334455",
      "TagVersion": 2,
      "Tag": "Electrical Safety",
      "TotalScore": 18,
      "TotalPotentialScore": 20,
      "AverageScore": 4.5,
      "AveragePotentialScore": 5.0,
      "PercentageScore": 0.9,
      "Flags": 0,
      "GradingSetOptionId": "c3d4e5f6-a1b2-4c3d-9e8f-001122334455",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ]
}
```

## Inductions

```json
{
  "Context": {
    "Version": 1,
    "Count": 1,
    "FullCount": 1,
    "PageNumber": 1,
    "PageSize": 500,
    "LastSynchronizationVersion": 1050,
    "SynchronizationVersion": 1205,
    "MinValidSynchronizationVersion": 900,
    "Error": "",
    "UTC": "2025-09-10T10:22:00Z"
  },
  "Wallets": [
    {
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77",
      "Wallet": "Northwind Construction Ltd"
    }
  ],
  "InductionsTaken": [
    {
      "InductionTakenId": "3d1c5f77-8b5e-4f7f-a1c4-9a0f6e2d3b11",
      "InductionId": "b8f2a8a1-9a6c-4d8a-9c73-1c7e3a0b5f22",
      "InductionVersion": 3,
      "ContactId": "7f6a2e10-1c59-4db8-9b6e-1b2f3c4d5e6f",
      "Name": "Casey Example",
      "CompanyName": "Contoso Civil Ltd",
      "TakenOn": "2024-09-25T09:00:00",
      "CorrectTestQuestionCount": 18,
      "InductionTakenStatusId": 4,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "Inductions": [
    {
      "InductionId": "b8f2a8a1-9a6c-4d8a-9c73-1c7e3a0b5f22",
      "InductionVersion": 3,
      "InductionName": "Site Safety Induction (2025)",
      "ValidForDays": 365,
      "CreatedOn": "2024-04-15T09:30:00.0000000+00:00",
      "Active": true,
      "InductionStatusCode": 0,
      "TestPassMark": 80,
      "TestQuestionCount": 20,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "InductionCustomQuestions": [
    {
      "InductionTakenId": "3d1c5f77-8b5e-4f7f-a1c4-9a0f6e2d3b11",
      "AnswerId": "2a4c6e88-5d2b-4c3a-9f10-7b8a9c0d1e2f",
      "Title": "Job Role",
      "Value": "Electrician",
      "ValueId": "9b7e6d55-3c2a-4f11-8a20-6d5c4b3a2f10",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ]
}
```

## Permits

```json
{
  "Context": {
    "Version": 1,
    "Count": 1,
    "FullCount": 1,
    "PageNumber": 1,
    "PageSize": 500,
    "LastSynchronizationVersion": 987654321,
    "SynchronizationVersion": 987654400,
    "MinValidSynchronizationVersion": 987650000,
    "Error": "",
    "UTC": "2025-09-10T10:22:00Z"
  },
  "Wallets": [
    {
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77",
      "Wallet": "Northwind Construction Ltd"
    }
  ],
  "Locations": [
    {
      "LocationId": "f4b0f6a1-9f1a-4c2c-8b2c-1ee7e6f1a2b3",
      "LocationTypeCode": 2,
      "LocationType": "Operations Site",
      "Location": "Northwind Construction - Warehouse 1",
      "CompanyId": "9f7b2b0e-6c9a-4f8a-a3b4-0c2e7d9a1b22",
      "Company": "Northwind Construction Ltd",
      "SiteId": "b1c2d3e4-f5a6-47b8-9c0d-1234567890ab",
      "Site": "Northwind Construction",
      "AreaId": "f4b0f6a1-9f1a-4c2c-8b2c-1ee7e6f1a2b3",
      "Area": "Warehouse 1",
      "JobId": "00000000-0000-0000-0000-000000000000",
      "Job": "",
      "SiteLocationId": "f4b0f6a1-9f1a-4c2c-8b2c-1ee7e6f1a2b3",
      "Department": "Operations",
      "ExternalIdentifier": "EXT-LOC-0001",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "Permits": [
    {
      "PermitToWorkId": "d2a7b3e9-0c41-4da2-9c23-6a5b3c2d1e0f",
      "PermitToWorkReference": "NWC-01234",
      "CategoryId": "aa112233-4455-6677-8899-aabbccddeeff",
      "CategoryVersion": 3,
      "SiteLocationId": "f4b0f6a1-9f1a-4c2c-8b2c-1ee7e6f1a2b3",
      "Description": "Hot work in Warehouse 1 to replace a section of ducting. Fire watch and isolation in place.",
      "IssuedToCompanyId": "3c2d1e0f-6a5b-4c23-9c23-0c41d2a7b3e9",
      "IssuedToCompany": "Blue River Contractors Ltd",
      "IssuedOn": "2025-09-08T09:15:00",
      "IssuedForMinutes": 480,
      "IssuedExpiry": "2025-09-08T17:15:00",
      "ClosedOn": "1900-01-01T00:00:00",
      "StatusId": 3,
      "HasBeenExpired": false,
      "HasBeenClosed": false,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "PermitCategories": [
    {
      "CategoryId": "aa112233-4455-6677-8899-aabbccddeeff",
      "CategoryVersion": 3,
      "CategoryName": "Hot Work Permit",
      "ExpiryTypeId": 1,
      "ExpiryType": "Timelapse",
      "ValidityPeriodId": 1,
      "ValidityPeriod": "For Certain Hours",
      "ValidityPeriodMinutes": 480,
      "IssueTypeId": 2,
      "IssueType": "To a Company",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "PermitChecklistAnswers": [
    {
      "PermitToWorkId": "d2a7b3e9-0c41-4da2-9c23-6a5b3c2d1e0f",
      "ChecklistId": "0b1c2d3e-4f5a-6789-abcd-ef0123456789",
      "OptionId": "123e4567-e89b-12d3-a456-426614174000",
      "CategorySectionTypeId": 1,
      "CategorySectionType": "Assignment",
      "Question": "Confirm fire extinguishers are present, inspected, and within 10m of the work area.",
      "Option": "Yes",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ]
}
```

## PPEAssignments

```json
{
  "Context": {
    "Version": 1,
    "Count": 1,
    "FullCount": 1,
    "PageNumber": 1,
    "PageSize": 500,
    "LastSynchronizationVersion": 1050,
    "SynchronizationVersion": 1200,
    "MinValidSynchronizationVersion": 900,
    "Error": "",
    "UTC": "2025-09-10T10:15:00Z"
  },
  "Wallets": [
    {
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77",
      "Wallet": "Northwind Construction Ltd"
    }
  ],
  "Locations": [
    {
      "LocationId": "0f5a3c2b-1e2d-4c5b-9a8f-7e6d5c4b3a21",
      "LocationTypeCode": 2,
      "LocationType": "Operations Site",
      "Location": "Riverside Depot - Warehouse 1",
      "CompanyId": "f4b7d8e9-1a2b-43c4-9d5e-6f7a8b9c0d1e",
      "Company": "Northwind Construction Ltd",
      "SiteId": "12345678-90ab-cdef-1234-567890abcdef",
      "Site": "Riverside Depot",
      "AreaId": "abcdef12-3456-7890-abcd-ef1234567890",
      "Area": "Warehouse 1",
      "JobId": "00000000-0000-0000-0000-000000000000",
      "Job": "",
      "SiteLocationId": "13572468-2468-1357-2468-135724681357",
      "Department": "Operations",
      "ExternalIdentifier": "OPS-RDV-WH1",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "PPETypes": [
    {
      "PPETypeId": "11111111-2222-3333-4444-555555555555",
      "PPETypeVariantId": "66666666-7777-8888-9999-000000000001",
      "Type": "Safety Helmet",
      "Variant": "White, Size M",
      "VariantOrder": 1,
      "LifespanDays": 730,
      "Value": 35.50,
      "TypeDeleted": false,
      "VariantDeleted": false,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "PPEStocks": [
    {
      "PPEStockId": "e9b2c0a1-1f0e-4a3d-9d4e-6b5a2c1d0e9f",
      "LocationId": "0f5a3c2b-1e2d-4c5b-9a8f-7e6d5c4b3a21",
      "PPETypeId": "11111111-2222-3333-4444-555555555555",
      "PPETypeVariantId": "66666666-7777-8888-9999-000000000001",
      "StockQuantity": 24,
      "WarningQuantity": 5,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "Contacts": [
    {
      "ContactId": "c0ffee00-1234-5678-9abc-def012345678",
      "Name": "Alex Proctor",
      "EmailAddress": "alex.proctor@northwind.test",
      "CompanyName": "Northwind Construction Ltd",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "PPEAssignments": [
    {
      "PPEAssignmentId": "aa111111-bb22-cc33-dd44-ee5555555555",
      "AssignedToContactId": "c0ffee00-1234-5678-9abc-def012345678",
      "PPETypeId": "11111111-2222-3333-4444-555555555555",
      "PPETypeVariantId": "66666666-7777-8888-9999-000000000001",
      "AssignedOn": "2025-08-25",
      "ExpiredOn": null,
      "PPEStatusCode": 1,
      "AssignedFromStockId": "e9b2c0a1-1f0e-4a3d-9d4e-6b5a2c1d0e9f",
      "ReturnedToStockId": null,
      "ReplacementRequestedFromStockId": null,
      "ReplacementRequestedOn": null,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "PPEAssignmentHistories": [
    {
      "PPEAssignmentHistoryId": "deadbeef-aaaa-bbbb-cccc-111122223333",
      "PPEAssignmentId": "aa111111-bb22-cc33-dd44-ee5555555555",
      "PPEActionCode": 1,
      "ActionedByContactId": "c0ffee00-1234-5678-9abc-def012345678",
      "ActionedOn": "2025-08-25T09:15:00+00:00",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ]
}
```

## PPEStockHistories

```json
{
  "Context": {
    "Version": 1,
    "Count": 1,
    "FullCount": 1,
    "PageNumber": 1,
    "PageSize": 500,
    "LastSynchronizationVersion": 1050,
    "SynchronizationVersion": 1200,
    "MinValidSynchronizationVersion": 900,
    "Error": "",
    "UTC": "2025-09-10T10:32:00Z"
  },
  "Wallets": [
    {
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77",
      "Wallet": "Northwind Construction Ltd"
    }
  ],
  "Locations": [
    {
      "LocationId": "f3a7b2c1-9d44-4e1f-8a20-3a7f2b1c9d44",
      "LocationTypeCode": 2,
      "LocationType": "Operations Site",
      "Location": "Northwind Construction - Warehouse 1",
      "CompanyId": "b9e5c1a2-7d8f-4a1b-8c3d-5f7a9e2c1b34",
      "Company": "Northwind Construction Ltd",
      "SiteId": "7b5c1a22-1f0b-4b77-9f5a-2c1d9e77a3b1",
      "Site": "Northwind Construction",
      "AreaId": "1d2c3b4a-5e6f-7890-a1b2-c3d4e5f67890",
      "Area": "Warehouse 1",
      "JobId": "00000000-0000-0000-0000-000000000000",
      "Job": "",
      "SiteLocationId": "0a1b2c3d-4e5f-6789-a0b1-c2d3e4f5a6b7",
      "Department": "Operations",
      "ExternalIdentifier": "NW-OPS-WH1",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "PPETypes": [
    {
      "PPETypeId": "3d2c1b0a-9f8e-4d7c-b6a5-4e3f2a1b0c9d",
      "PPETypeVariantId": "6a5b4c3d-2e1f-4a0b-9c8d-7e6f5a4b3c2d",
      "Type": "Hard Hat",
      "Variant": "Yellow",
      "VariantOrder": 1,
      "LifespanDays": 1095,
      "Value": 12.50,
      "TypeDeleted": false,
      "VariantDeleted": false,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "PPEStocks": [
    {
      "PPEStockId": "9c8b7a6d-5e4f-4a3b-8c2d-1e0f9a8b7c6d",
      "LocationId": "f3a7b2c1-9d44-4e1f-8a20-3a7f2b1c9d44",
      "PPETypeId": "3d2c1b0a-9f8e-4d7c-b6a5-4e3f2a1b0c9d",
      "PPETypeVariantId": "6a5b4c3d-2e1f-4a0b-9c8d-7e6f5a4b3c2d",
      "StockQuantity": 150,
      "WarningQuantity": 25,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "Contacts": [
    {
      "ContactId": "2f1e0d3c-4b5a-6e7f-8091-a2b3c4d5e6f7",
      "Name": "Riley Example",
      "EmailAddress": "riley.example@nwind.example",
      "CompanyName": "Northwind Construction Ltd",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "PPEStockHistories": [
    {
      "PPEStockHistoryId": "a1b2c3d4-e5f6-4789-8abc-d0e1f2a3b4c5",
      "PPEStockId": "9c8b7a6d-5e4f-4a3b-8c2d-1e0f9a8b7c6d",
      "PPEActionCode": 1,
      "TransferredFromStockId": null,
      "StockQuantity": 20,
      "ActionedByContactId": "2f1e0d3c-4b5a-6e7f-8091-a2b3c4d5e6f7",
      "ActionedOn": "2025-09-09T09:15:00+00:00",
      "Notes": "Received delivery of 20 hard hats from supplier.",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ]
}
```

## PPEStocks

```json
{
  "Context": {
    "Version": 1,
    "Count": 1,
    "FullCount": 1,
    "PageNumber": 1,
    "PageSize": 500,
    "LastSynchronizationVersion": 110000,
    "SynchronizationVersion": 110250,
    "MinValidSynchronizationVersion": 108000,
    "Error": "",
    "UTC": "2025-09-10T12:34:56Z"
  },
  "Wallets": [
    {
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77",
      "Wallet": "Northwind Construction Ltd"
    }
  ],
  "Locations": [
    {
      "LocationId": "d9f9a9b1-4c6f-4e93-bf2c-5b0b9f9a1c2d",
      "LocationTypeCode": 2,
      "LocationType": "Operations Site",
      "Location": "Northwind Construction - Warehouse 1",
      "CompanyId": "b1f2c3d4-e5f6-4789-9abc-def012345678",
      "Company": "Northwind Construction Ltd",
      "SiteId": "c2d3e4f5-6789-4abc-9def-0123456789ab",
      "Site": "Northwind Construction",
      "AreaId": "a1b2c3d4-5e6f-4789-8abc-def0123456ab",
      "Area": "Warehouse 1",
      "JobId": "00000000-0000-0000-0000-000000000000",
      "Job": "",
      "SiteLocationId": "e1f2a3b4-c5d6-4e7f-8901-23456789abcd",
      "Department": "Operations",
      "ExternalIdentifier": "NWC-OPS-WH1",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "PPETypes": [
    {
      "PPETypeId": "6a7b8c9d-0e1f-4a2b-9c3d-4e5f60718293",
      "PPETypeVariantId": "7b8c9d0e-1f2a-4b3c-8d4e-5f60718293a4",
      "Type": "Safety Helmet",
      "Variant": "Blue - Medium",
      "VariantOrder": 2,
      "LifespanDays": 730,
      "Value": 19.99,
      "TypeDeleted": false,
      "VariantDeleted": false,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "PPEStocks": [
    {
      "PPEStockId": "8c9d0e1f-2a3b-4c5d-8e6f-701928374655",
      "LocationId": "d9f9a9b1-4c6f-4e93-bf2c-5b0b9f9a1c2d",
      "PPETypeId": "6a7b8c9d-0e1f-4a2b-9c3d-4e5f60718293",
      "PPETypeVariantId": "7b8c9d0e-1f2a-4b3c-8d4e-5f60718293a4",
      "StockQuantity": 120,
      "WarningQuantity": 25,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ]
}
```

## ReportedIssues

```json
{
  "Context": {
    "Version": 1,
    "Count": 1,
    "FullCount": 1,
    "PageNumber": 1,
    "PageSize": 500,
    "LastSynchronizationVersion": 12500,
    "SynchronizationVersion": 13042,
    "MinValidSynchronizationVersion": 11000,
    "Error": "",
    "UTC": "2025-09-10T10:22:00Z"
  },
  "Wallets": [
    {
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77",
      "Wallet": "Northwind Construction Ltd"
    }
  ],
  "Locations": [
    {
      "LocationId": "d76f1b5a-4c3a-4f1d-8a0d-3f0a9a2a3c11",
      "LocationTypeCode": 2,
      "LocationType": "Operations Site",
      "Location": "Northwind Construction - Warehouse 1",
      "CompanyId": "8ee2b5f6-1f1a-4d7d-9b7e-6e8ad8c2f412",
      "Company": "Northwind Construction Ltd",
      "SiteId": "2c3a4b5c-6d7e-4890-9f1a-2b3c4d5e6f70",
      "Site": "Northwind Construction",
      "AreaId": "9a1b2c3d-4e5f-4a67-9abc-12de34f56a79",
      "Area": "Warehouse 1",
      "JobId": "00000000-0000-0000-0000-000000000000",
      "Job": "",
      "SiteLocationId": "3e7a5f22-1c34-4d68-b2f1-0a9d22c1b4e0",
      "Department": "Operations",
      "ExternalIdentifier": "NW-W01",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "ReportedIssues": [
    {
      "ReportedIssueId": "7b2d1c9e-8356-4a9e-b5c1-0e2f4a6b9d31",
      "ReportedIssueReference": "NWC-01234",
      "OccurredOn": "2025-09-08T07:45:00",
      "ReportedOn": "2025-09-08T08:10:00",
      "ReportedBy": "Alex Example",
      "ReportedByCompany": "Northwind Construction Ltd",
      "ReportedIssueStatusCode": 3,
      "SubcategoryId": "0ab4c92f-6a3c-4b21-8a1f-4f2a6e9d0b55",
      "CategoryVersion": 4,
      "LocationId": "d76f1b5a-4c3a-4f1d-8a0d-3f0a9a2a3c11",
      "ReportedIssueOverview": "Near-miss: pallet shifted during manual handling; no injury sustained but potential head impact risk identified.",
      "ReportedIssueSeverityCode": 2,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77",
      "CloseDate": "0001-01-01T00:00:00+00:00"
    }
  ],
  "ReportedIssueCategories": [
    {
      "SubcategoryId": "0ab4c92f-6a3c-4b21-8a1f-4f2a6e9d0b55",
      "CategoryVersion": 4,
      "CategoryName": "Manual Handling",
      "CategoryDescription": "Incidents related to lifting, carrying, or moving loads.",
      "SubcategoryName": "Pallet Movement",
      "SubcategoryDescription": "Load shift or unstable pallet during transport/handling.",
      "SubcategoryOrder": 3,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "ReportedIssueRootCauseAnalysis": [
    {
      "ReportedIssueRootCauseAnalysisId": "5e3f2a4b-7c6d-4e1a-9b2c-1d0e4f5a6b7c",
      "ReportedIssueId": "7b2d1c9e-8356-4a9e-b5c1-0e2f4a6b9d31",
      "ReportedIssueRootCauseAnalysisTypeCode": 2,
      "RootCauseAnalysis": "Inadequate securing of load",
      "RootCauseAnalysisDescription": "Strapping not applied on rear edge; visual check missed during staging.",
      "RootCauseAnalysisOrder": 1,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "ReportedIssueBranchOptions": [
    {
      "ReportedIssueId": "7b2d1c9e-8356-4a9e-b5c1-0e2f4a6b9d31",
      "BranchId": "1f2e3d4c-5b6a-4789-8c7d-6e5f4a3b2c1d",
      "OptionId": "2a3b4c5d-6e7f-4890-9a1b-2c3d4e5f6a7b",
      "Branch": "Immediate Action Taken",
      "Option": "Area cordoned; pallet re-secured with straps",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "ReportedIssueBodyParts": [
    {
      "ReportedIssueId": "7b2d1c9e-8356-4a9e-b5c1-0e2f4a6b9d31",
      "ReportedIssueBodyPartId": "8c9d0e1f-2a3b-4c5d-9e8f-7a6b5c4d3e2f",
      "Question": "Which body parts were affected?",
      "BodyParts": 3,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "ReportedIssueOptionSelects": [
    {
      "ReportedIssueId": "7b2d1c9e-8356-4a9e-b5c1-0e2f4a6b9d31",
      "ChecklistId": "ab12cd34-ef56-4789-ab12-cd34ef56ab78",
      "OptionId": "cd34ef56-ab78-41a2-bc34-de56fa78bc12",
      "Question": "Was first aid provided?",
      "Option": "No",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "ReportedIssuePeople": [
    {
      "ReportedIssueId": "7b2d1c9e-8356-4a9e-b5c1-0e2f4a6b9d31",
      "PersonId": "0c1d2e3f-4a5b-4c6d-8e9f-0a1b2c3d4e5f",
      "OptionId": "1a2b3c4d-5e6f-47a8-9b0c-1d2e3f4a5b6c",
      "Question": "Who was involved?",
      "Option": "Site Visitor",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "ReportedIssueInvestigationBranchOptions": [
    {
      "ReportedIssueId": "7b2d1c9e-8356-4a9e-b5c1-0e2f4a6b9d31",
      "BranchId": "9f8e7d6c-5b4a-43a2-9c1d-0e2f3a4b5c6d",
      "OptionId": "8e7d6c5b-4a3f-42b1-8c0d-9e1f2a3b4c5d",
      "Branch": "Training Adequacy",
      "Option": "Refresher required for load securing",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "ReportedIssueInvestigationBodyParts": [
    {
      "ReportedIssueId": "7b2d1c9e-8356-4a9e-b5c1-0e2f4a6b9d31",
      "ReportedIssueBodyPartId": "3a4b5c6d-7e8f-4a90-8b7c-6d5e4f3a2b1c",
      "Question": "Body parts considered during investigation",
      "BodyParts": 3,
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "ReportedIssueInvestigationOptionSelects": [
    {
      "ReportedIssueId": "7b2d1c9e-8356-4a9e-b5c1-0e2f4a6b9d31",
      "ChecklistId": "de67fa90-bc12-4d34-9a56-7b8c9d0e1f2a",
      "OptionId": "fa90de67-12bc-4d34-9a56-7b8c9d0e1f2a",
      "Question": "Was PPE adequate?",
      "Option": "No",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "ReportedIssueInvestigationPeople": [
    {
      "ReportedIssueId": "7b2d1c9e-8356-4a9e-b5c1-0e2f4a6b9d31",
      "PersonId": "6b7c8d9e-0f1a-42b3-9c4d-5e6f7a8b9c0d",
      "OptionId": "7c8d9e0f-1a2b-43c4-8d9e-0f1a2b3c4d5e",
      "Question": "Interviewed",
      "Option": "Supervisor",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ]
}
```

## SafetyCards

```json
{
  "Context": {
    "Version": 1,
    "Count": 1,
    "FullCount": 1,
    "PageNumber": 1,
    "PageSize": 500,
    "LastSynchronizationVersion": 130000,
    "SynchronizationVersion": 131234,
    "MinValidSynchronizationVersion": 120000,
    "Error": "",
    "UTC": "2025-09-10T12:34:56Z"
  },
  "Wallets": [
    {
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77",
      "Wallet": "Northwind Construction Ltd"
    }
  ],
  "Locations": [
    {
      "LocationId": "5b5f6f47-31c0-4a2a-b1b5-2d87a7a9b201",
      "LocationTypeCode": 2,
      "LocationType": "Operations Site",
      "Location": "Northwind Construction - Warehouse 1",
      "CompanyId": "c7b2a1c3-8e1f-41d5-8af1-f0a5b2c3d4e5",
      "Company": "Northwind Construction Ltd",
      "SiteId": "9c2f8b10-4d3a-4a88-9f01-6f7e3b2c1a09",
      "Site": "Northwind Construction",
      "AreaId": "f12a3b45-6789-4abc-9def-0123456789ab",
      "Area": "Warehouse 1",
      "JobId": "00000000-0000-0000-0000-000000000000",
      "Job": "",
      "SiteLocationId": "a1b2c3d4-5678-49ab-90cd-ef0123456789",
      "Department": "Operations",
      "ExternalIdentifier": "NWC-OPS-001",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "SafetyCardCategories": [
    {
      "SafetyCardCategoryId": "3a4b5c6d-7e8f-49a0-b1c2-d3e4f5a6b7c8",
      "CategoryName": "Housekeeping",
      "CategoryReference": "HKP",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ],
  "SafetyCards": [
    {
      "SafetyCardId": "7e1b2c3d-4e5f-4a67-9abc-12de34f56a78",
      "SafetyCardReference": "NWC-000457",
      "SafetyCardTypeCode": 1,
      "ReportedByUser": "Jordan Example",
      "ReportedDateTime": "2025-09-09T11:45:00",
      "SafetyCardCategoryId": "3a4b5c6d-7e8f-49a0-b1c2-d3e4f5a6b7c8",
      "Employer": "Northwind Construction Ltd",
      "Employee": "Casey Worker",
      "InductionNumber": "IND-4821",
      "ReportDetails": "Loose debris found near the loading bay; area cordoned and housekeeping requested.",
      "SafetyCardStatusCode": 0,
      "HasSignature": true,
      "SignatureDate": "2025-09-09T12:00:00",
      "Occupation": "Electrician",
      "OccupationRoleCode": 3,
      "LocationId": "5b5f6f47-31c0-4a2a-b1b5-2d87a7a9b201",
      "ExternalIdentifier": "SCR-2025-000457",
      "WalletId": "a3e1c9f2-5d4b-4330-9c2f-1c2b8f0d9a77"
    }
  ]
}
```
