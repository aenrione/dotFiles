---
description: Auto-select dashboard or pacioli reviewer-pattern diff audit
---

# Fintoc Practices Check

Run a reviewer-pattern audit on current git changes, auto-selecting the right ruleset from repository context.

## Auto-Detection

1. Detect repository with:
   - `gh repo view --json nameWithOwner`
   - Fallback: `git remote get-url origin`
2. Select mode:
   - `fintoc-com/dashboard` -> use `dashboard_practices_check` rules
   - `fintoc-com/pacioli` -> use `pacioli_practices_check` rules
3. If repo is neither dashboard nor pacioli:
   - run a lightweight generic audit
   - state that specialized rules were not available

## Dashboard Mode

Use the same weighting and checklist from `~/.config/opencode/commands/dashboard_practices_check.md`.

Priority focus:

- tests for behavior changes (filters/search/pagination)
- API/data-contract + URL sync
- readability/naming
- UI/UX/copy consistency
- loading/empty/error/null states
- Vue reactivity/watcher placement
- permission checks

## Pacioli Mode

Use the same weighting and checklist from `~/.config/opencode/commands/pacioli_practices_check.md`.

Priority focus:

- tests (including country variants)
- error/null handling
- contracts/serializers/enums
- service architecture boundaries
- org scoping + permissions
- query/scope correctness
- Sorbet typing discipline

## Process

1. Read git context:
   - `git status`
   - `git diff --staged`
   - `git diff`
2. Review changed hunks only; infer adjacent behavior where needed.
3. Use severity markers:
   - `🔴` direct change request / likely bug
   - `🟡` likely should change
   - `⚪` nitpick
   - `❓` suspicious question
   - `❔` chill question
4. Every finding must include:
   - `path:line`
   - historical reviewer-pattern mapping
   - concrete fix suggestion

## Output Format

1. Detected repository + selected mode
2. Findings by severity
3. Category scorecard (PASS/FAIL)
4. Top 3 highest-impact fixes
5. Quick wins
6. Confidence note

Keep feedback concise, specific, and action-oriented.
