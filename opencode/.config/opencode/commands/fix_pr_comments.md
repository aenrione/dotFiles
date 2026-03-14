# Fix PR Comments Command

Use this command to address PR review comments for the current repo and branch.

## Instructions

1. Fetch PR comments using `get_pr_comments`, always with an explicit PR source (to avoid interactive fzf):
   - Current branch PR (preferred): `get_pr_comments --current`
   - Explicit PR number: `get_pr_comments 123`
   - JSON: `get_pr_comments --json --current` or `get_pr_comments --json 123`
   - Only mine: `get_pr_comments --mine --current` or `get_pr_comments --mine 123`
   - Exclude mine: `get_pr_comments --exclude-mine --current` or `get_pr_comments --exclude-mine 123`
2. Prioritize fixing issues by severity, handling critical items first.
3. Apply feedback when it makes sense, and report which comments were addressed, skipped, or need clarification.
4. Use the tag system below to interpret priority:
   - `⚪` Nitpick - optional
   - `🟡` Something strange - likely needs change, discuss if unclear
   - `🔴` Direct change request - likely bug or critical issue
   - `❓` Question with smell of something wrong
   - `❔` Chill question, just curious
5. If a comment references a pattern or convention, search for similar usage in the codebase to align with existing practices before changing code.
6. You may use `/fintoc-best-practices` for additional context.
7. Do not commit or push any changes unless explicitly approved by the user.
8. If changes affect test behavior, re-run tests:
   - Rails: `/run_rails_test`
   - Vue: `vitest`

## Output Expectations

- Summarize which comments were resolved and how.
- Call out any unresolved comments with a short rationale or question.

## Review Consistency Reminder

Dejé unos comms, más que nada de los tests y formato de código

Ponle más ojo a estas cosas porfa. Que funcione no es suficiente, si al final gran parte de nuestra pegar es leer código, y ayuda mucho en ese aspecto que no hagamos lo mismo de formas distintas en distintas partes del código. Puede sonar chato siendo nuevo en un codebase, pero ahora más que nunca debiera ser fácil lograrlo con ayuda de un agent que planifique la implementación fijándose en implementaciones similares en el resto del codebase.

Independiente de la forma de codear, también ten más ojo con el ruido que hay en el código. En los puros tests de integración hay 4 mocks innecesario y otro innecesariamente complejo que en otros tests logramos de manera más simple (el mock del drawer). Este tipo de cosas debieras revisarlas tu mismo y cuestionarte si son necesarias o si hay una forma más simple de hacerlo.
