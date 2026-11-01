---
description: "Make a change to one of this repo's Power BI sample reports or models (a new page, measure, visual, drillthrough, link or a full makeover), using both Power BI skills, the house style and the repo's Power BI rules."
argument-hint: "Report and change, e.g. Permits: add a page showing permits closed late by company"
agent: "agent"
---

# Power BI Change

Make the requested change to a Power BI report or semantic model in this repo.

Read these first. Load each skill's reference files when a step needs them.

- [powerbi-report-development](../skills/powerbi-report-development/SKILL.md): how to edit PBIP files safely, publish, and verify.
- [work-wallet-bi-reporting](../skills/work-wallet-bi-reporting/SKILL.md): what the Work Wallet data means, how each module behaves, and the portal's figures and links.
- [House style](../instructions/powerbi-style.instructions.md): how pages look.
- [Repo rules](../instructions/powerbi.instructions.md): the samples' rules and how to finish a change.

Then:

1. **Confirm the scope.** Identify the `PowerBISamples/<Module>` project and what should change. If either isn't clear from the request, ask before editing anything.
2. **Get access for checking.** To publish and check the result, you need the development workspace URL (and the report's link) from the user. Ask for them unless they're already in this conversation. Keep the ids out of the repo.
3. **Protect existing edits.** Run `git status`. If the project has uncommitted changes (e.g. a Power BI Desktop save), ask the user before committing them on their own, then continue.
4. **Make the change** following the skill's procedure, scaled to its size:
   - review the affected pages;
   - profile the data with DAX;
   - change the model, then the report;
   - publish, then check the measures and the rendered pages.

   For a one-visual fix, a quick review and a check of that page are enough.
5. **Finish** as the repo rules describe:
   - regenerate the model docs if the model changed;
   - update `CHANGELOG.md` if report users will notice;
   - commit the change (ask first if the user hasn't said to commit);
   - ask the user to open the `.pbip` in Power BI Desktop, refresh and save, then commit that save on its own.

End with a short summary: what changed, how it was verified, and anything that needs the user (the Desktop save, a check against the portal, open questions).
