# Commit Message Instructions

Use **Conventional Commits** format:

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Types

| Type | When to use |
| --- | --- |
| `feat` | New dataset support, new fields captured, new Power BI sample |
| `fix` | Bug fix, schema correction, column length fix, data issue |
| `chore` | Dependency upgrades, .NET version bumps, tooling changes |
| `docs` | README, CHANGELOG, ReferenceData, SampleJSON, PowerBISamplesModels updates |
| `refactor` | Code restructure with no behaviour change |
| `perf` | Performance improvement to stored procedures or HTTP paging |
| `test` | Test changes only |
| `ci` | GitHub Actions or build pipeline changes |
| `build` | Project file, NuGet, or solution file changes |

## Scopes

Use a scope to indicate what area was changed. Suggested scopes:

**Datasets:** `actions`, `assets`, `asset-inspections`, `asset-observations`, `audits`, `inductions`, `permits`, `ppe`, `reported-issues`, `safety-cards`

**Database objects:** `dimensions`, `facts`, `schema`, `types`, `etl`

**Shared entities:** `locations`, `users`, `site`

**Projects:** `core`, `services`, `sample`, `function`, `database-deploy`

**Power BI:** `power-bi`

**Docs:** `docs`, `changelog`, `readme`

## Rules

- Description is lowercase, imperative mood, no trailing period.
- Keep the subject line under 72 characters.
- If a DB deploy is required, note it in the body: `DB deploy required.`
- If a full data reload is recommended, note it: `Full reload recommended.`
- Breaking changes use `!` after the type/scope and a `BREAKING CHANGE:` footer.

## Examples

```text
fix(locations): increase Department column length to 50

Matches updated field length in the Work Wallet source solution.
DB deploy required.
```

```text
feat(reported-issues): capture additional response fields

DB deploy required. Full reload recommended.
```

```text
chore: upgrade to .NET 10
```

```text
docs(changelog): add 4.5.0 unreleased placeholder
```

```text
fix(audits)!: change primary key type on AuditFact

BREAKING CHANGE: existing databases must be migrated before deploying.
DB deploy required. Full reload required.
```
