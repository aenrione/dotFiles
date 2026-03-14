---
description: Run Hermes-style PR review locally (no GitHub posting)
---

# Hermes Local PR Review

Run a local review that mirrors `fintoc-com/hermes/.github/workflows/pr-code-review.yaml` behavior, but **without posting** anything to GitHub.

<user-instructions>
$ARGUMENTS
</user-instructions>

## Goal

Produce the same kind of output the bot would generate:
- A very brief PR summary body in mild Chilean Spanish.
- Inline review comments only for real risks.
- No style/nit/refactor-only feedback.

## Scope selection

1. If user provides a PR number, use it as the source of truth:
   - `gh pr view <number> --json baseRefName,headRefName,url,title`
   - `gh pr diff <number>`
2. Otherwise review local branch changes against a reasonable base:
   - Prefer the branch base if its not `main`
      - If not found You may check if the branch has a pr and use the pr base
   - Prefer if the base is not `origin/main` if it exists, else `origin/master`.
   - Use `git diff <base>...HEAD`.
3. If there are no changes, report that clearly and stop.

## Review rules (mirror Hermes)

Comment ONLY on:
- Bugs that can break in production.
- Security vulnerabilities.
- Data loss/corruption risks.
- Important unhandled edge cases.
- Race/concurrency issues.
- Missing error handling that can silently fail.

Do NOT comment on:
- Style/formatting/naming.
- Documentation/comments.
- Logging/metrics suggestions.
- Refactor ideas that are not correctness/safety issues.
- Test coverage comments.
- Personal preference.

## Process

1. Inspect the diff thoroughly and read surrounding files when needed.
2. Validate findings with evidence from code paths (avoid guesses).
3. Build a draft review with:
   - A short summary of what changed.
   - If no issues found, end with `LGTM ✅`.
   - Line-specific findings only when there are real risks.
4. Keep responses concise and concrete.
5. Do not run tests/runtime commands for this command unless user explicitly asks.

## Output format

Return a human-friendly review message (not JSON), using this structure:

```markdown
## Resumen
<1-3 líneas en español chileno suave explicando qué cambia el PR>

## Hallazgos
- 🔴 `relative/path/to/file.rb:123` — Riesgo crítico en producción. Qué pasa y cómo corregirlo.
- 🟡 `relative/path/to/file.rb:200` — Riesgo importante/edge case. Impacto y fix sugerido.

## Veredicto
<Si no hay hallazgos: LGTM ✅>
```

Rules:
- If there are no issues, include `Sin hallazgos críticos.` in **Hallazgos** and `LGTM ✅` in **Veredicto**.
- Keep each finding short, concrete, and actionable.
- Include file path and line number in every finding.

## Important

- Never post the review to GitHub in this command.
- If user later asks to publish it, ask for confirmation and then use `gh api` in a separate step.
