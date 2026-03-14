---
description: Actualiza/crea un Issue en Linear con el estilo Fintoc
allowed-tools: Bash(git:*), Read, mcp__linear__*, AskUserQuestion, Task
---

<user-instructions>
$ARGUMENTS
</user-instructions>

## Commits

Primero, asegúrate de que los commits estén ordenados de forma que sea lo más fácil posible para un humano revisar estos cambios.
Solo rehace commits si son claramente malos para revisión.

Usa formato conventional commits (e.g., `feat:`, `fix:`, `refactor:`, `test:`, `docs:`).

## Linear Issue

1. Extrae el Linear issue ID desde el nombre de la branch (ej: `onb-453-feature` → `ONB-453`). Esto NO requiere MCP.

2. Si el usuario te provee el id de un projecto, usalo como base

3. Si no hay issue ID en el nombre de la branch, pregúntale al usuario si quiere:
   - Proveer el issue ID manualmente, o
   - Usar Linear MCP para crear/encontrar uno

   Si MCP no está disponible, ofrece setearlo:
   `claude mcp add --transport sse linear https://mcp.linear.app/sse`

## Issue Content (Linear)

El objetivo es que el issue quede bien escrito y utilizable como contexto real para un reviewer/QA/PM.

**Antes de actualizar/crear el issue:** muestra al usuario el título y descripción propuestos, y pregunta:

1. Ok - proceder con la creación/actualización
2. Más conciso - acortar descripción

Solo crea/actualiza el issue después de que el usuario elija "Ok".

### Título

Debe ser breve, claro, y si existe el ID del issue, mantenerlo.

Si estás creando uno nuevo, NO incluyas el ID manualmente (Linear lo asigna).
Si estás actualizando uno existente, no cambies el ID, solo el texto.

Ejemplo:
`Use antialiased font smoothing to match Figma`

### Descripción

Debe estar en ESPAÑOL.
Usa el template base de abajo.
Debe ser un resumen breve pero suficiente para entender qué se hizo y por qué.

Usa las instrucciones del usuario para enriquecer el contexto (si existen).

**Guidelines:**
- Mantenerlo lo más corto posible sin perder info crítica
- Usar frases claras y directas
- Evitar listas largas
- Usar checkboxes (`- [x]`) si tiene sentido (ej. alcance)
- Omitir "Notas" si no hay nada relevante

## Git Context

Current branch:
`git branch --show-current`

Current changes:
`git diff main...HEAD`

Recent commits on this branch:
`git log main..HEAD --oneline`

## Template Linear Issue

```

## Contexto

Porque haremos esto

## Objetivo

Que es lo que incluye este issue

## Notas

Consideraciones extra, cosas fuera de scope, etc..

```
