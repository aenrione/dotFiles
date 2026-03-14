---
description: Review git diff with pacioli historical reviewer patterns
---

# Pacioli Practices Check

Run a reviewer-style audit over current git changes, prioritizing patterns repeatedly flagged in historical PR comments for `fintoc-com/pacioli`.

## Goal

Identify likely review feedback before opening/updating a PR by checking the diff against recurring human-reviewer concerns.

## Historical Signals (weighted)

Use this order (derived from merged PR comments):

1. **Tests coverage** (highest): missing tests, missing country variant tests (MX/CL), or weak edge-case coverage.
2. **Error/null handling**: nilability, missing header/value handling, unsafe assumptions, fallback behavior.
3. **API/contracts/serializers**: enum usage, request/response mapping, contract validations, serializer correctness.
4. **PR hygiene**: unclear scope split, cross-PR confusion, poor reviewability/context.
5. **Service architecture**: mixed country logic, responsibility leaks, missing extraction/factory boundaries.
6. **Permissions/org scoping**: org-tenant boundaries, role/policy consistency, security-sensitive flows.
7. **Scopes/queries**: query correctness/perf, relation chaining, avoid unnecessary query count growth.
8. **Types/Sorbet discipline**: avoid unnecessary `T.let`, reduce untyped payloads, keep exhaustive typing.

## Process

1. Collect git context:
   - `git status`
   - `git diff --staged`
   - `git diff`
2. Review changed hunks and infer adjacent behavior where needed.
3. Flag findings with severity emojis:
   - `🔴` direct change request / likely bug
   - `🟡` likely should change
   - `⚪` nitpick
   - `❓` suspicious question
   - `❔` chill question
4. For each finding include:
   - `path:line`
   - why this maps to historical reviewer feedback
   - concrete fix suggestion
5. Explicitly mark each historical signal as checked even if no issues found.

## Diff Review Checklist (must run)

- [ ] Behavior changes include tests in the same PR/commit set
- [ ] Country-specific behavior has explicit coverage where relevant (MX/CL/CPF)
- [ ] Contract + serializer + enum mappings stay consistent and intentional
- [ ] Nil/null/error paths are explicitly handled (no silent assumptions)
- [ ] Services keep clear boundaries and avoid mixed-country branching smells
- [ ] Org scoping and permission checks remain enforced and tested
- [ ] Scopes/queries remain efficient and chainable (no accidental multi-query regressions)
- [ ] Sorbet typing remains strict enough (avoid unnecessary `T.let` / `T.untyped` spread)
- [ ] PR scope/context is still understandable from reviewer's perspective

## Output Format

Produce:

1. **Findings by severity** (`🔴`, `🟡`, `⚪`, `❓`, `❔`)
2. **Category scorecard** (PASS/FAIL per historical signal)
3. **Top 3 highest-impact fixes first**
4. **Quick wins** (small changes with high clarity/risk reduction)
5. **Confidence note** (what cannot be verified from diff alone)

Keep feedback concise, specific, and action-oriented.
