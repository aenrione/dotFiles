# Fintoc Code Review Command

Review the provided code or current changes following Fintoc's best practices and coding standards.

## Instructions

1. Read the Fintoc best practices document at `~/.config/opencode/commands/fintoc-best-practices.md`
2. Analyze the code provided by the user (or current staged/unstaged changes if none provided)
3. Provide feedback using Fintoc's emoji convention:
   - `⚪` Nitpick - optional, at your discretion
   - `🟡` Something strange - probably needs change, discuss first  
   - `🔴` Direct change request - likely a bug or something nasty
   - `❓` Question with smell of something wrong
   - `❔` Chill question, just curious

## Review Checklist

### Services
- [ ] Country-specific logic separated (no conditionals for MX vs CL)
- [ ] Factory pattern used for country routing
- [ ] T::Struct used instead of untyped hashes for params
- [ ] Services in correct location (engine vs app)
- [ ] Complex queries extracted into separate commands/services
- [ ] External dependencies can be stubbed for unit testing

### Database & Migrations
- [ ] No `safety_assured` unless table is very small
- [ ] Indexes use `add_index_safely` with `disable_ddl_transaction!`
- [ ] FKs split into create (validate: false) + validate migrations
- [ ] NOT NULL uses check constraint pattern (2 migrations)
- [ ] Column type changes use new column + sync + swap pattern
- [ ] Volatile defaults use column + default + BackfillJob (NOT migration update)
- [ ] No `add_reference` - do steps separately
- [ ] No manual lock_timeout increases (except for concurrent index ops)
- [ ] Unique indexes scoped by entity/organization
- [ ] String enums, not integers
- [ ] No comments in migrations

### Testing
- [ ] Using `build`/`build_stubbed` instead of `create` for unit tests
- [ ] Using `let_it_be` for shared database records
- [ ] Avoiding `let!` unless truly necessary
- [ ] Testing org scoping (can't access other org's resources)
- [ ] Contracts have tests
- [ ] Serializer output verified
- [ ] Integration tests fewer than unit tests
- [ ] Tests in same commit as implementation

### API & Serialization
- [ ] Using public enums for serialization (PublicApi::*)
- [ ] Model methods over serializer logic
- [ ] List endpoints return empty array, not 404
- [ ] No show contracts for URL params

### Scopes
- [ ] Scopes always return relations (never nil)
- [ ] Column names qualified in joins (use arel_table)
- [ ] Consistent interfaces (all IDs or all instances)

### Types (Sorbet)
- [ ] No unnecessary T.let when type comes from params
- [ ] Exhaustive pattern matching with T.absurd
- [ ] Specific types over T.untyped

### PR Description
- [ ] Concise, not auto-generated AI verbosity
- [ ] Only includes context not obvious from code
- [ ] No duplication of Linear ticket content

## Output Format

Provide feedback as inline comments on the code, then a summary of:
1. Critical issues (🔴)
2. Suggestions (🟡)
3. Nitpicks (⚪)
4. Questions (❓/❔)

Reference specific lines using `file_path:line_number` format.
