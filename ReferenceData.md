# Work Wallet BI Reference Data

## General

| LocationTypeCode | LocationType |
| --- | --- |
| 1 | Job Operations Site |
| 2 | Operations Site |
| 4 | General Location |
| 8 | Job General Location |

| UnitCode | Group | Unit | UnitAcronym |
| --- | --- | --- | --- |
| 0 | None |  |  |
| 1 | Distance | Inch | in |
| 2 | Distance | Foot | ft |
| 3 | Distance | Mile | mi |
| 4 | Distance | Millimetre | mm |
| 5 | Distance | Centimetre | cm |
| 6 | Distance | Metre | m |
| 7 | Distance | Kilometre | km |
| 8 | Volume | Millilitre | ml |
| 9 | Volume | Litre | l |
| 10 | Volume | Gallon | gal |
| 11 | Volume | Cubic Metre | m³ |
| 12 | Time | Hour | hr |
| 13 | Time | Minute | min |
| 14 | Time | Second | s |
| 15 | Temperature | Fahrenheit | °F |
| 16 | Temperature | Celsius | °C |
| 17 | Temperature | Kelvin | K |
| 18 | Weight | Ounce | oz |
| 19 | Weight | Pound | lb |
| 20 | Weight | Ton | ton |
| 21 | Weight | Tonne | t |
| 22 | Weight | Gram | g |
| 23 | Weight | Kilogram | kg |
| 24 | Power | Ampere | A |
| 25 | Power | Hertz | Hz |
| 26 | Power | Ohm | Ω |
| 27 | Power | Volt | V |
| 28 | Power | Watt | W |
| 29 | Miscellaneous | Bar | bar |
| 30 | Miscellaneous | Candela | cd |
| 31 | Miscellaneous | Cycles | cycles |
| 32 | Miscellaneous | Percent | % |
| 33 | Miscellaneous | Pounds Per Square Inch | psi |

## Actions

| ActionPriorityCode | ActionPriority |
| --- | --- |
| 1 | Low |
| 2 | Medium |
| 4 | High |
| 8 | Critical |

| ActionStatusCode | ActionStatus |
| --- | --- |
| 0 | Draft |
| 1 | Open |
| 2 | In Progress |
| 3 | Closed |

| ActionTypeCode | ActionType |
| --- | --- |
| 1 | Audit |
| 2 | Issue |
| 4 | Safety Card |
| 8 | Asset |
| 16 | Briefing |

## Assets

| AssetPropertyType |
| --- |
| Number |
| Select |
| Text |

| AssetStatusCode | AssetStatus |
| --- | --- |
| 0 | Active |
| 1 | Out of Service |
| 2 | Decommissioned |
| 3 | Deleted |

## Audits

| AuditStatusCode | AuditStatus |
| --- | --- |
| 0 | Planned |
| 1 | Report In Progress |
| 2 | Ready for Review |
| 3 | Complete |
| 4 | Cancelled |
| 5 | Deleted |
| 6 | Closed |
| 7 | Archived |

## Inductions

| InductionStatusCode | InductionStatus |
| --- | --- |
| 0 | Active |
| 1 | Archived |
| 3 | Deleted |

| InductionTakenStatusCode | InductionTakenStatus |
| --- | --- |
| 1 | Passed |
| 2 | Completed |
| 3 | Failed |
| 4 | Passed Expiring Soon |
| 5 | Completed Expiring Soon |
| 6 | Expired |
| 7 | Invalid |
| 8 | Rejected |
| 9 | Deleted |

## Permits

| PermitStatusCode | PermitStatus |
| --- | --- |
| 1 | Draft |
| 2 | Pending |
| 3 | Active |
| 4 | Expired |
| 5 | Closed |
| 6 | Archived |
| 7 | Deleted |

## PPEAssignments

| PPEStatusCode | PPEStatus |
| --- | --- |
| 1 | Assigned |
| 2 | Returned |
| 3 | Replaced |
| 4 | Removed |

## PPEStockHistories

## PPEStocks

## ReportedIssues

BodyPart API representation:

| MaskIndex | Group | BodyPart |
| --- | --- | --- |
| 0 | Head | Head |
| 1 | Head | Eye - Left |
| 2 | Head | Ear - Left |
| 3 | Head | Face |
| 4 | Head | Teeth |
| 5 | Upper Body | Neck |
| 6 | Upper Body | Shoulder - Left |
| 7 | Upper Body | Arm - Left |
| 8 | Upper Body | Hand / Wrist - Left |
| 9 | Upper Body | Finger(s) - Left |
| 10 | Upper Body | Chest / Lungs |
| 11 | Upper Body | Stomach |
| 12 | Lower Body | Hip - Left |
| 13 | Lower Body | Leg - Left |
| 14 | Lower Body | Knee - Left |
| 15 | Lower Body | Ankle - Left |
| 16 | Lower Body | Foot - Left |
| 17 | Lower Body | Toe(s) - Left |
| 18 | General | Whole Body |
| 19 | Head | Nose |
| 20 | Head | Mouth |
| 21 | Upper Body | Back |
| 22 | Lower Body | Shin - Left |
| 23 | Upper Body | Elbow - Left |
| 24 | Head | Eye - Right |
| 25 | Head | Ear - Right |
| 26 | Upper Body | Shoulder - Right |
| 27 | Upper Body | Arm - Right |
| 28 | Upper Body | Elbow - Right |
| 29 | Upper Body | Hand / Wrist - Right |
| 30 | Lower Body | Hip - Right |
| 31 | Lower Body | Leg - Right |
| 32 | Lower Body | Knee - Right |
| 33 | Lower Body | Shin - Right |
| 34 | Lower Body | Ankle - Right |
| 35 | Lower Body | Foot - Right |
| 36 | Upper Body | Finger(s) - Right |
| 37 | Lower Body | Toe(s) - Right |

Each MaskIndex is a power of two, so multiple body parts can be represented as a single integer using bitwise OR.
The API sends this as a bitmask, allowing efficient storage and transmission of multiple selections.

| ReportedIssueSeverityCode | ReportedIssueSeverity |
| --- | --- |
| 1 | Low |
| 2 | Medium |
| 4 | High |
| 8 | Critical |

| ReportedIssueStatusCode | ReportedIssueStatus |
| --- | --- |
| 2 | Reported |
| 3 | Under Investigation |
| 4 | Closed |
| 6 | Closed (Archived) |
| 8 | Deleted |

| ReportedIssueRootCauseAnalysisTypeCode | ReportedIssueRootCauseAnalysisType |
| --- | --- |
| 1 | Root Cause |
| 2 | Immediate Cause |

## SafetyCards

| OccupationRoleCode | OccupationRole |
| --- | --- |
| -1 | Unknown |
| 0 | Apprentice |
| 1 | Trainee |
| 2 | Foreman |
| 3 | Supervisor |
| 4 | Manager |
| 5 | Contracts Manager / Engineer |
| 6 | Director |
| 7 | General Operative |

| SafetyCardStatusCode | SafetyCardStatus |
| --- | --- |
| 0 | Active |
| 1 | Archived |
| 3 | Deleted |

| SafetyCardTypeCode | SafetyCardType |
| --- | --- |
| 0 | Green |
| 1 | Yellow |
| 2 | Red |
