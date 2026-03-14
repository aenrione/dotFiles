---
description: Run local CI checks for Ruby or Vue projects
---

# Run CircleCI checks locally

Run local CI-style checks with environment-aware behavior:

- Ruby projects: `lint`, `sorbet`, `check_model_rbis`, optional targeted `rspec`.
- Vue projects: `eslint` (affected files), `vitest`, and `build` (affected scope when available).

<user-instructions>
$ARGUMENTS
</user-instructions>

## Defaults

- Auto-detect environment:
  - Ruby if `Gemfile` exists.
  - Vue if `package.json` contains `"vue"`.
- If no arguments are provided:
  - Ruby: run `lint sorbet`.
  - Vue: run `eslint vitest build`.
- Supported checks by environment:
  - Ruby: `lint`, `sorbet`, `check_model_rbis`, `rspec`.
  - Vue: `eslint`, `vitest`, `build`.
- For Ruby `rspec`, run only user-provided spec files (never full repo).

## Detect environment (always first)

```bash
PROJECT_ENV=""

if [ -f Gemfile ]; then
  PROJECT_ENV="ruby"
elif [ -f package.json ] && grep -q '"vue"' package.json; then
  PROJECT_ENV="vue"
else
  echo "Unable to detect project environment (expected Gemfile or Vue package.json)." >&2
  exit 1
fi

echo "Detected environment: $PROJECT_ENV"
```

## Compute affected base (shared)

```bash
BASE=""
if git rev-parse --verify --quiet origin/main >/dev/null 2>&1 && git merge-base origin/main HEAD >/dev/null 2>&1; then
  BASE="origin/main"
elif git rev-parse --verify --quiet HEAD~1 >/dev/null 2>&1; then
  BASE="HEAD~1"
fi
```

## Ruby environment

Only run this section when `PROJECT_ENV=ruby`.

### Environment setup

```bash
DOPPLER="/opt/homebrew/bin/doppler"

export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"

if [ ! -x "$DOPPLER" ]; then
  echo "Doppler not found at $DOPPLER" >&2
  exit 1
fi

rbenv exec ruby -v
```

## Install dependencies

```bash
BUNDLER_VERSION=$(tail -1 Gemfile.lock | tr -d " ")
gem install bundler:$BUNDLER_VERSION
$DOPPLER run -- rbenv exec bundle _$(echo $BUNDLER_VERSION)_ install --jobs=${BUNDLE_JOBS:-4}
```

## Checks

### lint (CircleCI `lint` equivalent)

```bash
set -eo pipefail
mkdir -p tmp

if [ -n "$BASE" ]; then
  git diff --name-only --diff-filter=d "$BASE"...HEAD > tmp/files_to_lint || true
fi

if [ ! -s tmp/files_to_lint ]; then
  git ls-files > tmp/files_to_lint
fi

RB_FILES=$(grep -E '.+\.(rb)$' tmp/files_to_lint || true)
if [ -n "$RB_FILES" ]; then
  printf "%s\n" "$RB_FILES" | xargs --no-run-if-empty rbenv exec bundle exec rubocop --force-exclusion
fi

JOB_FILES=$(printf "%s\n" "$RB_FILES" | grep -E '(app/jobs/|engines/.*/app/jobs/)' || true)
if [ -n "$JOB_FILES" ]; then
  rbenv exec bundle exec rubocop --only Custom/SidekiqOptionsRetryRequired --force-exclusion $JOB_FILES
  rbenv exec bundle exec rubocop --only Custom/SidekiqOptionsQueueAsRequired --force-exclusion $JOB_FILES
fi
```

### sorbet (CircleCI `sorbet` equivalent)

```bash
$DOPPLER run -- rbenv exec bundle exec srb tc
$DOPPLER run -- rbenv exec bundle exec tapioca gems --verify

$DOPPLER run -- rbenv exec bundle exec tapioca annotations
if git status --porcelain | grep -E '\.rbi$' >/dev/null 2>&1; then
  echo "ERROR: There are new annotations rbis."
  git status --porcelain | grep -E '\.rbi$'
  exit 1
fi
```

### check_model_rbis (CircleCI `check_model_rbis` equivalent)

```bash
dockerize -wait tcp://localhost:5432 -timeout 1m
$DOPPLER run -- rbenv exec bundle exec rails db:create db:schema:load
$DOPPLER run -- rbenv exec bundle exec bin/tapioca dsl --verify --verbose --workers=1
```

### rspec (optional, targeted only)

```bash
# Example (replace with explicit files)
$DOPPLER run -- rbenv exec bundle exec rspec spec/path/to/file_spec.rb spec/other_spec.rb
```

## Notes

- Prefer aliases if you use them (`dr`, `drsx`, `drmx`, `drcl`), but keep command behavior equivalent.
- Do not run full test suite unless explicitly requested.
- If `check_model_rbis` is requested and Postgres is not running locally, fail fast and report it.

## Vue environment

Only run this section when `PROJECT_ENV=vue`.

### Environment setup

```bash
if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm is required but was not found in PATH" >&2
  exit 1
fi

pnpm install --frozen-lockfile
```

### Checks

#### eslint (affected files)

```bash
set -eo pipefail
mkdir -p tmp

if [ -n "$BASE" ]; then
  git diff --name-only --diff-filter=d "$BASE"...HEAD > tmp/files_to_lint || true
else
  git ls-files > tmp/files_to_lint
fi

ESLINT_FILES=$(grep -E '\.(vue|js|jsx|ts|tsx)$' tmp/files_to_lint || true)

if [ -n "$ESLINT_FILES" ]; then
  printf "%s\n" "$ESLINT_FILES" | xargs --no-run-if-empty pnpm exec eslint
else
  echo "No affected Vue/JS/TS files to lint."
fi
```

#### vitest

```bash
if [ -n "$BASE" ]; then
  pnpm exec vitest run --changed "$BASE"
else
  pnpm exec vitest run
fi
```

#### build

```bash
if [ -f nx.json ] && [ -n "$BASE" ]; then
  pnpm exec nx affected -t build --base="$BASE" --head=HEAD
elif [ -f turbo.json ] && [ -n "$BASE" ]; then
  pnpm turbo run build --filter="...[$BASE]"
else
  pnpm run build
fi
```

### Notes

- Vue checks should prioritize affected scope when `BASE` is available.
- If no affected baseline can be computed, fall back to full local commands.
