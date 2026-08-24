# Agent Skills

User-level agent skills shared across projects (DSH Alfred, Tactics, and any tool
that reads `~/.agents/skills`: DeepSeek Harness, Codex, OpenCode, Claude Code).

Everything in this repository is a **flat** skill: `<skill-name>/SKILL.md` at the
repository root, one level deep. Discoverers (DSH, Codex, OpenCode, Claude) scan
exactly one level under `~/.agents/skills`, so nested skill groups are invisible
and forbidden here.

## Skills

| Skill | Type | Purpose |
| --- | --- | --- |
| `grill-me` | User-invoked | Entry point that routes explicit "grill me" requests into a relentless interview |
| `grilling` | Model/user | The interview engine: grill the user about a plan or design until every branch is resolved |
| `skill-writing` | Reference | Progressive-disclosure profile for authoring good skills |
| `brainstorming` | Model/user | Explore a vague request into a confirmed design before implementation (HARD-GATE) |
| `make-dev-plan` | Model/user | Clarify P0→P3, then produce an executable development plan |
| `plan-mode-plan-writer` | Plan mode | Save a decision-complete plan to `.agents/plans/` with handoff context |
| `manual-qa-handoff` | Model/user | Maintain the manual-acceptance ledger after automated gates pass |
| `project-doc-organization` | Model/user | Keep docs/plans/knowledge short, current, discoverable |
| `knowledge-maintenance` | Model/user | Query/ingest/supersede the cross-system knowledge index (OKF-lite) |

Rules (not skills): `rules/` — `code-documentation.md`, `agent-worktree.md`,
`foreground-interaction.md`, `knowledge-maintenance.md`. Global rules such as
`foreground-interaction` default to deny and are project-configurable.

## Project conventions (defaults)

Skills reference these conventional locations; a project maps them in its own
`AGENTS.md` when it deviates:

- `.agents/docs/` — current authoritative design/usage docs (design outputs from
  `brainstorming` land here as `YYYY-MM-DD-<topic>-design.md`)
- `.agents/plans/` — decision-complete plans pending execution
- `.agents/knowledge/` — OKF-lite index bundle (`index.md`, `log.md`, concepts)
- `.agents/rules/` — project rules (the pack's `rules/` are portable defaults)

## Install (once per machine, Windows / macOS / Linux)

```powershell
# Windows
git clone git@github.com:cty41/skills.git D:\codes\agent-skills
powershell -ExecutionPolicy Bypass -File D:\codes\agent-skills\scripts\install-user.ps1

# macOS / Linux (pwsh)
git clone git@github.com:cty41/skills.git ~/codes/agent-skills
pwsh -File ~/codes/agent-skills/scripts/install-user.ps1
```

The installer creates a link per skill inside `~/.agents/skills/<name>` pointing
back into this checkout — a directory junction on Windows, a symbolic link on
macOS/Linux. It is idempotent: existing correct links are kept, broken ones are
repaired, stale ones are pruned. Re-run it after `git pull` to refresh.

No project repository is modified; every tool that reads the user-agents root
(`~/.agents/skills`) sees these skills in every working directory.

## Update

```powershell
git -C D:\codes\agent-skills pull
powershell -ExecutionPolicy Bypass -File D:\codes\agent-skills\scripts\install-user.ps1
```

## Self-test

```powershell
powershell -ExecutionPolicy Bypass -File D:\codes\agent-skills\scripts\validate.ps1   # repo health
powershell -ExecutionPolicy Bypass -File D:\codes\agent-skills\scripts\smoke.ps1      # installed state
```

`validate.ps1` runs per-skill `quick_validate` (when the skill-creator validator is
present), the flat/nesting audit, local markdown link checks, and the OKF-lite
unit tests. `smoke.ps1` verifies that `~/.agents/skills/<name>` links exist for
every skill and resolve into this checkout.

## OKF-lite scope vocabulary

`knowledge-maintenance` and `tools/okf-lite` maintain a lightweight knowledge
index bundle (OKF). Scopes are conventional names subject to change; each
project maps them in its own `AGENTS.md`. Default scopes:

- `project-documentation` — authoritative design/usage docs
- `active-plans` — plans still pending execution
- `project-known-gaps` — evidence-backed unimplemented gaps
- `code-and-tests` — implementation facts (indexed, never the source of truth)

`tools/okf-lite` implements bundle validation and a trimmed impact report/sync.
The golden rule: the index summarizes and links; it is never the source of truth
for current state.

## Authoring rules

See [AGENTS.md](AGENTS.md). In short: flat only; frontmatter is just `name` +
`description`; progressive disclosure; every new skill must pass
`quick_validate` and the nesting audit; domain-specific skills stay in their
own project repositories.

## License

[MIT](LICENSE). Ported and de-coupled from personal project `tactics`
(`.agents/skills`), MIT.