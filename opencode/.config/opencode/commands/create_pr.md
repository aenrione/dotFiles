---
description: Creates a PR with the Fintoc PR style
allowed-tools: Bash(gh:*), Bash(git:*), Read, mcp__linear__*, AskUserQuestion, Task
---

<user-instructions>
$ARGUMENTS
</user-instructions>

## Commits

First, make sure commits are ordered in a way that makes it as easy as possible for a human to review these changes.
Only redo commits if they are blatantly bad for a review.

Use conventional commits format (e.g., `feat:`, `fix:`, `refactor:`, `test:`, `docs:`).

## Linear Issue

1. Extract the Linear issue ID from the branch name (e.g., `onb-453-feature` → `ONB-453`). This doesn't require MCP.

2. If no issue ID in branch name, ask the user to either:
   - Provide the issue ID manually, or
   - Use Linear MCP to create/find one (if MCP is not available, offer to set it up: `claude mcp add --transport sse linear https://mcp.linear.app/sse`)

## Pull Request

Use the `gh` CLI to interact with GitHub. Create the PR as a draft and assign me (the CLI user).

**Before creating the PR:** Show the user the proposed title and body, then ask:

1. Ok - proceed with creation
2. More concise - shorten the description

Only create the PR after user selects "Ok".

### Title

The title should be brief, start with the Linear issue ID in brackets, and summarize the PR.

Example: `[ONB-453] Use antialiased font smoothing to match Figma`

### Body

Read the PR template at `.github/pull_request_template.md` and use it to structure the body. The body should be
a brief explanation IN SPANISH that a human should be able to use as context to then read the PR and evaluate
the code critically, without missing information.

Use the user instructions to enrich the context (if present).

**Guidelines:**

- Only mention relevant changes to keep the description as brief as possible
- Use checkboxes (`- [x]`) instead of bullet points for lists
- For tests, just mention the type (e.g., "Tests unitarios") - don't enumerate each test
- Omit "Consideraciones" if there isn't anything special to mention
- End with footer: `<sup>*Created with Claude Code `/create-pr` command*</sup>`

## Git Context

Current branch:
`git branch --show-current`

Current changes:
`git diff main...HEAD`

Recent commits on this branch:
`git log main..HEAD --oneline`

## Template PR

```
## Contexto
¿Por qué?
Agregar un pequeño resumen que de contexto y explique porque es importante el cambio
que se está proponiendo.
## Que hay de nuevo?
¿Qué?
Resumen que explique que es lo que se implementó concretamente. Un punteo
de cambios específicos también es bienvenido.
- [x] Endpoint para exponer x
- [x] Se elimina configuración y
- [x] Clase Z
## Tests
¿Como nos aseguramos de que esto funciona?
- [x] Tests unitarios para x
- [x] Tests de integración entre x e y
## Consideraciones
Cosas generales que el reviewer debería tener en cuenta. Pueden ser componentes
que se ven afectados por el PR, decisiones que se tomaron para el desarrollo,
dudas para discutir con los reviewers, cosas que quedaron fuera de scope, etc.
Ej.
- Se decidió separar x funcionalidad en dos endpoints
- ¿Les parece bien este nombre para y?
- Se decidió no incluir el refactor de x en este PR
# Rollback
¿Es seguro hacer rollback?
¿Cuáles son los pasos para hacer rollback?
```
