---
name: life-knowledge
description: "Use when a request concerns ongoing personal knowledge, asks to save/organize/archive a conversation, or a personal knowledge vault may be unconfigured or degraded — proactively check vault health, ask only necessary decisions, and delegate deterministic work to knowledge-base-kit."
---

# Life Knowledge

## Quick Reference

| Intent | Agent action |
|---|---|
| Relevant first request | Run read-only quick doctor once |
| Missing/degraded configuration | Offer configure now / answer first / suppress this session |
| Save or organize | Preview target and privacy impact, then confirm |
| Health check | Run doctor without confirmation |
| Upgrade/migrate/archive | Run dry-run, summarize, then confirm |
| Delete/overwrite/push | Require separate explicit confirmation |

## When to use

- A request belongs to an ongoing personal, family, travel, household technology, learning, or research topic worth retaining.
- The user asks to save, organize, continue, ingest, migrate, archive, back up, or check personal knowledge.
- A relevant request arrives before the vault/tool association is complete.
- The current workspace instructions require a session bootstrap health check.

Do not trigger for every unrelated one-off question. Do not globally interrupt ordinary software work merely because a vault exists.

## Workflow

### Step 1: Bootstrap once per relevant session

Locate the control kit and vault using the kit's discovery order: explicit input, local profile, environment configuration, common locations, then user choice. Run a read-only quick doctor through the kit. Interpret the JSON state using [the onboarding state machine](references/onboarding-state-machine.md).

```powershell
& <kit-path>/kb.ps1 doctor -Quick -Json
```

When healthy, continue silently. Remember the result for the current conversation; do not repeat the quick check on every turn.

### Step 2: Ask only for decisions

If unconfigured or degraded, present one concise question with the recommended option first:

1. Configure or repair now (recommended)
2. Answer the current question first and configure afterward
3. Do not remind again in this conversation

Automatically discover paths and inspect read-only facts. Never ask the user to copy and run command sequences that the Agent can safely execute.

### Step 3: Preserve normal question flow

For ordinary advice or analysis, answer the user's request even if the vault is unconfigured, then offer to configure/save. If the user explicitly asks to write, migrate, archive, or upgrade, configuration health is a prerequisite for that mutation.

### Step 4: Preview mutations

Invoke the kit with `-DryRun -Json`, then summarize:

- files/directories to create or change;
- files explicitly excluded;
- privacy findings and manual-review items;
- whether any overwrite, deletion, network publication, or irreversible action exists.

Ask one confirmation for ordinary writes. Use a separate explicit confirmation for destructive actions or publication.

### Step 5: Execute and verify

After confirmation, invoke the deterministic kit command. Run doctor or the relevant verifier afterward. Report the result, changed files, and any unresolved manual review. Never claim persistence if the write or verification failed.

See [intent routing](references/intent-routing.md), [confirmation policy](references/confirmation-policy.md), and [privacy policy](references/privacy-policy.md).

## Anti-patterns

| Wrong | Correct | Reason |
|---|---|---|
| Require memorized commands or trigger phrases | Infer intent and offer a short decision | Agent-first interaction |
| Prompt on every user message | Bootstrap once per relevant conversation | Avoids nagging |
| Block an ordinary answer on setup | Answer first, then offer setup | Preserves usefulness |
| Reimplement migration with ad-hoc shell commands | Invoke the versioned kit | Deterministic and testable |
| Copy raw private data into a public repository | Keep data in the private vault | Enforces the one-way boundary |
| Say a binary file is safe because text scanning found nothing | Mark it for manual review | Scanner limitations matter |

## Checklist

- [ ] Relevant-session bootstrap ran at most once
- [ ] Healthy state continued silently
- [ ] Missing/degraded state produced one concise choice
- [ ] Ordinary question was not needlessly blocked
- [ ] Mutation used dry-run and preview
- [ ] Destructive/publication action had separate confirmation
- [ ] Kit, not ad-hoc logic, performed deterministic file operations
- [ ] Verification ran and the final report matches actual persistence
