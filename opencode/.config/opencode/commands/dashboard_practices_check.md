---
description: Review git diff with dashboard historical reviewer patterns
---

# Dashboard Practices Check

Run a reviewer-style audit over the current git changes, prioritizing patterns repeatedly flagged in historical PR comments for `fintoc-com/dashboard`.

## Goal

Find likely review feedback **before** PR review by checking current diff against the most common human reviewer concerns.

## Historical Signals (weighted)

Use these as priority order (derived from merged PR comment history):

1. **Tests coverage** (most frequent): missing/weak tests for behavior changes, especially filters/search/pagination/table states.
2. **API/data-contract alignment**: params/query/cursor/filter handling, backend contract assumptions, and URL sync behavior.
3. **Readability/naming**: unclear names, confusing abstractions, mixed responsibilities, hard-to-follow control flow.
4. **UI/UX/copy consistency**: unusual layout choices, search/filter UX, label/copy clarity, consistency with existing patterns/Figma.
5. **Error/empty/loading/null states**: incomplete state handling in tables/drawers/forms.
6. **Reactivity/dataflow**: unnecessary watchers/side effects, stale computed/query interactions, debounce/pagination behavior.
7. **Permissions/auth safety**: role/permission gating and visibility/action checks.
8. **PR hygiene**: scope creep, missing context, force-push/reviewability smells.

## Process

1. Collect context from git:
   - `git status`
   - `git diff --staged`
   - `git diff`
2. Review only changed files/hunks, but infer nearby behavior when needed.
3. Flag issues using severity emojis:
   - `🔴` direct change request / likely bug
   - `🟡` likely should change
   - `⚪` nitpick
   - `❓` suspicious question
   - `❔` chill question
4. For each finding include:
   - `path:line`
   - why this maps to historical reviewer feedback
   - concrete fix (or a quick patch suggestion)
5. If no issues are found in a category, explicitly mark it as checked.

## Diff Review Checklist (must run)

- [ ] Behavior changes are covered by Vitest tests (or justified if not needed)
- [ ] Filter/search/pagination changes include edge-case tests
- [ ] API query params and response assumptions match existing contracts
- [ ] URL-synced state remains consistent (search/filter/pagination)
- [ ] Loading, empty, error, and null/undefined states are handled
- [ ] Naming and structure are easy to understand at first read
- [ ] Vue watcher placement follows project guideline (watch/watchEffect at end of script)
- [ ] Permission/role checks are preserved for gated actions/views
- [ ] UI text and interaction patterns are consistent with surrounding module

## Output Format

Produce:

1. **Findings by severity** (`🔴`, `🟡`, `⚪`, `❓`, `❔`)
2. **Category scorecard** (PASS/FAIL per historical signal)
3. **Top 3 highest-impact fixes first**
4. **Quick wins** (low effort, high clarity)
5. **Confidence note** (what could not be verified from diff alone)

Keep feedback concise, specific, and action-oriented.
