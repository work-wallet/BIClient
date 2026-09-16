# PPE

[<- Back to index](../PowerBISamplesModels.md)

## PPE - Stock

```mermaid
---
config:
  theme: neutral
---
erDiagram
    "Location" {
        attr LocationType
        attr Location
        attr Company
        attr Site
        attr Area
        attr Job
        attr Department
        attr LocationExternalIdentifier
        attr AllDepartments
        attr SiteStatus
    }
    "Stock" {
        agg StockQuantity
        attr WarningQuantity
        calc Value
        calc StockSite
        calc StockLocation
    }
    "PPE Type" {
        attr PPEType
        attr PPEVariant
        agg LifespanDays
        agg Value
        attr TypeDeleted
        attr VariantDeleted
        calc Variant
        calc PPE
    }
    "PPE Type Master" {
        attr PPEType
        attr TypeDeleted
    }
    "Group" {
        attr Group
        attr Active
    }
    "Group Fact" {
    }
    "Stock" }o--|| "PPE Type" : "PPEType_key"
    "Stock" }o--|| "Location" : "Location_key"
    "PPE Type" }o--|| "PPE Type Master" : "PPETypeId"
    "Group Fact" }o--|| "Group" : "PPEGroup_key"
    "Group Fact" }o--|| "PPE Type Master" : "PPETypeId"
```

## PPE - Stock History

```mermaid
---
config:
  theme: neutral
---
erDiagram
    "Stock" {
        agg StockQuantity
        attr WarningQuantity
        calc Value
        calc StockSite
        calc StockLocation
    }
    "Stock History" {
        agg StockQuantity
        attr ActionedOn
        attr Notes
        calc StockLocation
        calc TransferredFromStockLocation
        calc StockSite
        calc Value
    }
    "PPE Type" {
        attr PPEType
        attr PPEVariant
        agg LifespanDays
        agg Value
        attr TypeDeleted
        attr VariantDeleted
        calc Variant
        calc PPE
    }
    "PPE Action" {
        attr PPEAction
    }
    "Actioned By Contact" {
        attr ContactName
        attr Email
        attr Company
    }
    "Stock" }o--|| "PPE Type" : "PPEType_key"
    "Stock History" }o--|| "PPE Action" : "PPEAction_key"
    "Stock History" }o--|| "Stock" : "PPEStock_key"
    "Stock History" }o..|| "Stock" : "TransferredFromPPEStock_key"
    "Stock History" }o--|| "Actioned By Contact" : "ActionedByContact_key"
```

## PPE - Assignments

```mermaid
---
config:
  theme: neutral
---
erDiagram
    "Stock" {
        agg StockQuantity
        attr WarningQuantity
        calc Value
        calc StockSite
        calc StockLocation
    }
    "Assignment" {
        attr AssignedOn
        attr ExpiredOn
        attr ReplacementRequestedOn
        calc AssignedCount
        calc RequireReplacement
        calc Value
        calc AssignedFromStockSite
        calc ReturnedToStockSite
    }
    "Assignment History" {
        attr ActionedOn
        calc From
        calc To
        calc AssignmentHistoryCount
    }
    "PPE Assignment Type" {
        attr PPEType
        attr PPEVariant
        attr VariantOrder
        agg LifespanDays
        agg Value
        attr TypeDeleted
        attr VariantDeleted
        calc Variant
        calc PPE
    }
    "PPE Action" {
        attr PPEAction
    }
    "PPE Status" {
        attr PPEStatus
    }
    "Assigned To Contact" {
        attr ContactName
        attr Email
        attr Company
        calc Contact
    }
    "Actioned By Contact" {
        attr ContactName
        attr Email
        attr Company
    }
    "Assignment" }o--|| "PPE Status" : "PPEStatus_key"
    "Assignment" }o..|| "Stock" : "AssignedFromPPEStock_key"
    "Assignment" }o..|| "Stock" : "ReplacementRequestedFromPPEStock_key"
    "Assignment" }o..|| "Stock" : "ReturnedToPPEStock_key"
    "Assignment History" }o--|| "PPE Action" : "PPEAction_key"
    "Assignment History" }o--|| "Assignment" : "PPEAssignment_key"
    "Assignment" }o--|| "PPE Assignment Type" : "PPEType_key"
    "Stock" }o--|| "PPE Assignment Type" : "PPEType_key"
    "Assignment History" }o--|| "Actioned By Contact" : "ActionedByContact_key"
    "Assignment" }o--|| "Assigned To Contact" : "AssignedToContact_key"
    "Assignment" }o..|| "Actioned By Contact" : "AssignedToContact_key"
    "Assignment History" }o..|| "Assigned To Contact" : "ActionedByContact_key"
```

## PPE - Properties

```mermaid
---
config:
  theme: neutral
---
erDiagram
    "PPE Type" {
        attr PPEType
        attr PPEVariant
        agg LifespanDays
        agg Value
        attr TypeDeleted
        attr VariantDeleted
        calc Variant
        calc PPE
    }
    "Property Type" {
        attr PropertyType
    }
    "Property Fact" {
        attr PropertyValue
    }
    "Property" {
        attr Property
    }
    "PPE Type Master" {
        attr PPEType
        attr TypeDeleted
    }
    "Property Fact" }o--|| "Property" : "PPEProperty_key"
    "PPE Type" }o--|| "PPE Type Master" : "PPETypeId"
    "Property Fact" }o--|| "PPE Type Master" : "PPETypeId"
    "Property" }o--|| "Property Type" : "PPEPropertyType_key"
```
