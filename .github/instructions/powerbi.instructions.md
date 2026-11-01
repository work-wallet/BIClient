---
description: "Rules for this repo's Power BI sample reports and semantic models (PowerBISamples/*.pbip, PBIR visual.json, TMDL) and the Tools/PowerBI helpers: the two audiences, working with any wallet, file safety, and finishing a change (model docs, CHANGELOG, Desktop save)."
applyTo: "PowerBISamples/**, Tools/PowerBI/**"
---

# Power BI Sample Reports

## Where the guidance lives

| File | Covers | Reusable for bespoke customer reports? |
| --- | --- | --- |
| This file | Rules for this repo's samples | No |
| [`powerbi-style.instructions.md`](powerbi-style.instructions.md) | Work Wallet house style: layout, colours, fonts, wording | Yes, or replace it with a customer's style |
| `powerbi-report-development` skill | How to build and check PBIP reports and models; the `Tools/PowerBI` helpers | Yes |
| `work-wallet-bi-reporting` skill | Work Wallet data, module behaviour, portal figures and links | Yes |
| `/powerbi-change` prompt (`.github/prompts/powerbi-change.prompt.md`) | Starts a report change with all of the above loaded | Yes, with the links adjusted |

Load the skills for any report or model change (they are in `.github/skills/`). The easiest way is to start the request with `/powerbi-change`, e.g. `/powerbi-change Permits: add a page showing permits closed late by company`.

## Purpose

The samples under `PowerBISamples/` serve two audiences. Every change must work for both:

- **Work Wallet**: demonstrates reporting capabilities to customers.
- **Customers**: a baseline to copy and customise into their own reports, against their own wallet's data.

## Working with any wallet

The samples are developed against the Work Wallet demo wallet, but must not depend on it.

- **Never hard-code wallet data** in measures or visuals: no names, IDs, answer texts, locations or record types.
- **Default filters and slicers may use demo values**, as consumers are expected to reset them. Prefer no saved selection where the page still makes sense.
- **Match the portal's defaults and headline figures**, so the samples agree with what users see in Work Wallet (see the `work-wallet-bi-reporting` skill).
- **Check edge cases with DAX** before publishing: empty periods, a single item, ties, and data without an optional feature.

## Safety

- **The committed `.Report`, `.SemanticModel` and theme files are the source of truth.** Build scripts are throwaway and stay in the session workspace.
- **Never overwrite the user's Power BI Desktop edits.** Commit a Desktop save on its own before regenerating anything. The helpers refuse to write over uncommitted changes.
- **Keep workspace, report and model IDs out of the repo.**

## Theme

Every sample uses the same theme file, `StaticResources/RegisteredResources/WorkWallet.json`. Keep every copy identical: change one, then copy it to the others.

## Finishing a change

- **Regenerate the model docs** after model changes: `dotnet run --project Tools/WorkWallet.BI.PowerBIModelDocGenerator/WorkWallet.BI.PowerBIModelDocGenerator.csproj`. Never edit its output (`PowerBISamplesModels.md`, `PowerBISamplesModels/*.md`) by hand. CI runs it with `-- --check`. The generator is deliberately not in `WorkWallet.BI.Client.sln`.
- **Update `CHANGELOG.md`** at a high level; the audience is report consumers. One entry can cover a series of report changes.
- **Ask the user to open each changed `.pbip` in Power BI Desktop, refresh and save.** Review that save and commit it on its own (e.g. "Power BI Desktop save (no functional change)").
- **Keep these files current**: put new lessons in the file that covers them (see the table above). Don't record task progress or status here.
