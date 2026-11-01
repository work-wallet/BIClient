# Claude Code instructions

This repo shares its agent guidance with GitHub Copilot. The files under `.github/` are the single source of truth; edit them there, not here.

@.github/copilot-instructions.md

Commit messages:

@.github/commit-instructions.md

Power BI samples (these apply when working under `PowerBISamples/` or `Tools/PowerBI/`):

@.github/instructions/powerbi.instructions.md
@.github/instructions/powerbi-style.instructions.md

Skills live in `.github/skills/`. Read the relevant `SKILL.md` there when a task matches its description, and its `references/` files when a step needs them:

- `.github/skills/powerbi-report-development/SKILL.md`: building, redesigning or editing Power BI reports and semantic models (PBIR, TMDL), publishing to a development workspace, checking measures with DAX and pages in the browser, and handling Power BI Desktop saves.
- `.github/skills/work-wallet-bi-reporting/SKILL.md`: what Work Wallet data means in reports (status codes, placeholder values, deleted records, identifying people), how each module behaves, and the Work Wallet portal's figures and deep links.

Prompts live in `.github/prompts/`. When asked to run one (e.g. `/powerbi-change`), read the `.prompt.md` file and follow it, treating the rest of the request as its input:

- `.github/prompts/powerbi-change.prompt.md`: make a change to a Power BI sample report or model, using both skills.
