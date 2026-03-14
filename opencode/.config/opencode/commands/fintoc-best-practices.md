# Fintoc Development Best Practices

> This document compiles coding standards, patterns, and best practices extracted from PR reviews, official Notion guides, and codebase analysis. Use this as a reference when writing code for Fintoc projects (Pacioli, fintoc-rails, dashboard).

---

## Table of Contents

1. [PR & Documentation Standards](#pr--documentation-standards)
2. [Code Review Conventions](#code-review-conventions)
3. [Service Architecture Patterns](#service-architecture-patterns)
4. [Database & Migrations](#database--migrations)
5. [Testing Standards](#testing-standards)
6. [Type Safety with Sorbet](#type-safety-with-sorbet)
7. [API & Serialization](#api--serialization)
8. [Scopes & Query Patterns](#scopes--query-patterns)
9. [Error Handling](#error-handling)
10. [File Organization](#file-organization)

---

## PR & Documentation Standards

### PR Descriptions

**Keep PR descriptions concise.** Only include context that cannot be inferred from the code itself.

> "Los agentes meten mucho ruido. El 95% de los casos no es necesario tanto detalle, solo cosas que podrían no entenderse del contexto del código"

**Good PR description:**
```markdown
## Contexto
Brief explanation of WHY this change is needed (1-2 sentences)

## Que hay de nuevo?
- Bullet points of concrete changes
- Focus on non-obvious decisions

## Consideraciones
- Design decisions that need discussion
- Things intentionally left out of scope
```

**Avoid:**
- Verbose implementation details that are obvious from the code
- Auto-generated descriptions from AI agents without editing
- Repeating information already in the Linear ticket

### Commit Standards

- **Tests go in the same commit as the implementation** - Don't separate test commits from feature commits
- Keep commits atomic and focused on a single change

---

## Code Review Conventions

Fintoc uses emoji prefixes in code reviews to indicate severity:

| Emoji | Meaning |
|-------|---------|
| `⚪` | Nitpick - optional, at your discretion |
| `🟡` | Something strange - probably needs change, discuss first |
| `🔴` | Direct change request - likely a bug or something nasty |
| `❓` | Question with smell of something wrong |
| `❔` | Chill question, just curious |
| `ℹ️` | Information/suggestion, no action required |

**Example:**
```
🟡 esto tiene la pinta de método de modelo
❓ las validaciones de que sean acc numbers válidos vive en el modelo?
⚪ no need el `T.let`, viene tipado de los params
```

---

## Service Architecture Patterns

### Factory Pattern for Country-Specific Services

**Always separate logic by country** rather than using conditionals within a single service. This prevents "ifs raros" when countries diverge.

```ruby
# typed: strict

# BAD - Mixed logic with conditionals
class Dashboard::RecipientService < Service
  def find_duplicate(params)
    if @model == Mx::Recipient
      # MX logic
    else
      # CL logic
    end
  end
end

# GOOD - Separate services with factory
class Dashboard::RecipientServiceFactory < Service
  sig { params(user: User).returns(Dashboard::RecipientService) }
  def self.create(user:)
    env = PacioliEnvironment.deserialize(Constants::PACIOLI_ENV)

    case env
    when PacioliEnvironment::MX
      Dashboard::Mx::RecipientService.new(user:)
    when PacioliEnvironment::CL, PacioliEnvironment::CPF
      Dashboard::Security::RecipientService.new(user:)
    when PacioliEnvironment::SANDBOX
      sandbox_service(user:)
    else
      T.absurd(env)
    end
  end
end
```

### Abstract Base Classes

```ruby
# typed: strict

class Dashboard::RecipientService < Service
  abstract!

  sig { params(user: User).void }
  def initialize(user:)
    super()
    @user = user
    @organization = T.let(T.must(user.organization), Organization)
  end

  sig { abstract.params(id: String).returns(Recipientable) }
  def find(id:); end

  sig { abstract.params(attributes: RecipientParams).returns(Recipientable) }
  def create(attributes:); end
end
```

### Use T::Struct for Complex Parameters

**Don't use untyped hashes** - use T::Struct to make required/optional params explicit.

```ruby
# BAD - Hash with unclear structure
sig { params(recipient_params: T::Hash[Symbol, T.untyped]).returns(Integer) }
def resolve(recipient_params:)

# GOOD - Typed struct with clear contract
class RecipientParams < T::Struct
  const :account_number, String
  const :institution_id, T.nilable(String)
  const :holder_name, String
  const :holder_id, T.nilable(String)
  const :email, T.nilable(String)
  const :alias, T.nilable(String), default: nil
end

sig { params(params: RecipientParams).returns(Integer) }
def resolve(params:)
```

### Service Location

Dashboard services live in **two locations**:

| Location | Use Case |
|----------|----------|
| `engines/dashboard/app/services/dashboard/` | Feature-specific (MFA, entities, users, exports) |
| `app/services/dashboard/` | Cross-cutting concerns (transfers, recipients) |

**Country-specific implementations:**
- `dashboard/mx/` - Mexico
- `dashboard/security/` - Chile (CL) and CPF

### Separation of Responsibilities

**If testing is hard, it's a code smell.** When you find yourself needing to write to the database or having too many scenarios to test, it indicates poor separation of responsibilities.

**Extract complex queries into commands/services:**

```ruby
# BAD - Complex query as private method (hard to test)
class ProcessInvalidCredentials < PowerTypes::Command.new(:refresh_intent)
  private

  def last_intents
    AccountRefreshIntent.joins(:refresh_intent).select(
      'DISTINCT ON (refresh_intents.link_id) ...'
    ).where(refresh_intents: { link_id: links.pluck(:id) })
  end
end

# GOOD - Extract to testable command
class GetLastAccountRefreshIntents < PowerTypes::Command.new(:link_ids)
  def perform
    AccountRefreshIntent.joins(:refresh_intent).select(
      'DISTINCT ON (refresh_intents.link_id) ...'
    ).where(refresh_intents: { link_id: @link_ids })
  end
end

# Now you can stub it in main command tests
allow(GetLastAccountRefreshIntents).to receive(:for).and_return(expected_intents)
```

---

## Database & Migrations

> Based on Fintoc's internal Migration Guide and Strong Migrations best practices.

### General Rules

- ✅ Creating FKs or indexes inside `create_table` is safe
- ✅ **Don't use `safety_assured`** unless you're certain the table is small
- ✅ **Follow Strong Migrations warnings** - if it errors, follow its instructions
- ✅ **Review this guide before every schema change**

### Creating Indexes

**Problem:** Creating an index takes an `ACCESS EXCLUSIVE LOCK`, blocking all queries.

**Solution:** Use the `add_index_safely` helper:

```ruby
class AddIndexToPayments < ActiveRecord::Migration[7.0]
  include MigrationHelpers
  disable_ddl_transaction!  # Required for CONCURRENTLY

  def change
    add_index_safely(
      table_name: :payments,
      columns: :user_id,
      env_var_name: 'ADD_PAYMENTS_INDEX',
      default_timeout: 360
    )
  end
end
```

**Notes:**
- `disable_ddl_transaction!` is **mandatory**
- Operation can take a long time on large tables but doesn't block queries

### Removing Indexes

**Solution:** Use `remove_index_safely` helper:

```ruby
class RemoveIndexFromPayments < ActiveRecord::Migration[7.0]
  include MigrationHelpers
  disable_ddl_transaction!

  def change
    remove_index_safely(
      table_name: :payments,
      name: 'index_payments_on_user_id'
    )
  end
end
```

### Adding Foreign Keys

**Problem:** Creating and validating a FK blocks the table while scanning all rows.

**Solution:** Create FK without validation, validate in separate migration:

```ruby
# Migration 1 - Create FK without validation
class AddForeignKeyWithoutValidation < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :payments, :users, validate: false
  end
end

# Migration 2 - Validate FK (safe, only takes SHARE UPDATE EXCLUSIVE LOCK)
class ValidateForeignKey < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :payments, :users
  end
end
```

### Setting Column as NOT NULL

**Problem:** Requires `ACCESS EXCLUSIVE LOCK` and full table scan.

**Solution:** Use check constraint as intermediate step:

```ruby
# Migration 1 - Add check constraint without validation
class AddNotNullCheckConstraint < ActiveRecord::Migration[7.0]
  def change
    add_check_constraint :payments,
                        "status IS NOT NULL",
                        name: "payments_status_not_null",
                        validate: false
  end
end

# Migration 2 - Validate, set NOT NULL, cleanup
class ValidateAndSetNotNull < ActiveRecord::Migration[7.0]
  def change
    validate_check_constraint :payments, name: "payments_status_not_null"
    change_column_null :payments, :status, false
    remove_check_constraint :payments, name: "payments_status_not_null"
  end
end
```

### Changing Column Type

**Problem:** Changing column type requires rewriting the entire table.

**Solution:** Create new column, sync data, swap (4 steps):

```ruby
# Step 1: Add new column
add_column :payments, :description_text, :text

# Step 2: Write to both columns (in model)
before_save :sync_description_columns
def sync_description_columns
  self.description_text = description if description_changed?
end

# Step 3: Backfill existing data (use BackfillJob, NOT migration)
# Step 4: Swap columns
safety_assured do
  rename_column :payments, :description, :description_old
  rename_column :payments, :description_text, :description
end
```

### Adding Column with Volatile Default

**Volatile functions:** `gen_random_uuid()`, `now()`, `random()`, `nextval()`, etc.

**Problem:** Requires writing value to every existing row.

**Solution:** Add column without default, set default for new records, backfill with job:

```ruby
# Migration 1: Add column without default
add_column :payments, :uuid, :uuid

# Migration 2: Add default for NEW records only
change_column_default :payments, :uuid, from: nil, to: -> { "gen_random_uuid()" }

# Step 3: Create BackfillJob (NOT in migration)
class BackfillPaymentUuidsJob < ApplicationJob
  BATCH_SIZE = 1_000

  def perform(start_id, end_id)
    Payment
      .where(id: start_id..end_id, uuid: nil)
      .in_batches(of: BATCH_SIZE) do |batch|
        batch.update_all("uuid = gen_random_uuid()")
        sleep(0.1)  # Don't saturate DB
      end
  end
end
```

**For large tables (millions of rows):**
- ❌ **DON'T** use `UPDATE ... WHERE uuid IS NULL` in migration
- ✅ **DO** use BackfillJob with small batches + sleep
- ✅ Backfill can take days - that's OK

### Never Use add_reference

**Problem:** `add_reference` creates column + FK + index in one operation. If it fails, database is in inconsistent state.

**Solution:** Do each step separately following the guides above.

### Never Increase Lock Timeout Manually

```ruby
# ❌ DANGEROUS - Don't do this
safety_assured { execute "SET lock_timeout TO '360s'" }
add_column :payments, :status, :string
```

**The problem:** While waiting for `ACCESS EXCLUSIVE LOCK`, ALL queries to the table queue up, causing cascade failures.

**Solution:** Keep lock_timeout low with retries (StrongMigrations handles this via `config/initializers/strong_migrations.rb`).

**Only safe cases for higher timeout:**
- ✅ `create_index ... algorithm: :concurrently`
- ✅ `drop_index ... algorithm: :concurrently`

### Unique Index Scoping

**Always scope unique indexes by tenant:**

```ruby
# BAD - Global unique constraint
add_index :mx_recipients, [:institution_id, :account_number], unique: true

# GOOD - Scoped by entity
add_index :mx_recipients, [:entity_id, :institution_id, :account_number], unique: true
```

### Enums

**Use string enums, not integers:**

```ruby
# BAD
enum holder_type: { person: 0, company: 1, unknown: 2 }

# GOOD
enum holder_type: { person: 'person', company: 'company', unknown: 'unknown' }
```

### No Comments in Migrations

```ruby
# BAD
def change
  # Add recipient_id column for linking transfers to saved recipients
  add_column :mx_transfer_intents, :recipient_id, :bigint
end

# GOOD
def change
  add_column :mx_transfer_intents, :recipient_id, :bigint
end
```

---

## Testing Standards

> Based on Fintoc's internal Testing Guide.

### Use `build` or `build_stubbed` Instead of `create`

`create` writes to database and is **orders of magnitude slower**. Unit tests shouldn't test ActiveRecord communication.

```ruby
# BAD - Creates in database for each test
subject(:payment_intent) do
  create(:payment_intent, recipient_bank: create(:bank, :mexican))
end

# GOOD - In-memory only
subject(:payment_intent) do
  build(:payment_intent, recipient_bank: build(:bank, :mexican))
end
```

### Use `let_it_be` for Shared Test Data

When you need database records, use `let_it_be` to create once and reuse across tests:

```ruby
# BAD - Creates for each test case
let(:organization) { create(:organization) }

# GOOD - Creates once, reuses across tests
let_it_be(:organization) { create(:organization) }

# For records that get modified, use reload variant
let_it_be_with_reload(:transfer_intent) { create(:mx_transfer_intent) }
```

### Avoid `let!` Unless Necessary

`let!` executes for EVERY test, even if not used. `let` is lazy.

```ruby
# BAD - Creates fintual for every test
let!(:fintual) { create(:organization, name: 'Fintual') }

# GOOD - Only creates when referenced
let(:fintual) { create(:organization, name: 'Fintual') }
```

### Group Related Test Cases

Instead of running the same setup multiple times:

```ruby
# BAD - Runs merge 3 times with same context
context 'when there are duplicated movements' do
  it 'creates unique movement with confirmed status' do...end
  it 'creates possibly_duplicated_movement1 with status' do...end
  it 'creates possibly_duplicated_movement2 with status' do...end
end

# GOOD - Single test with multiple expectations
context 'when there are duplicated movements' do
  it 'manages possibly duplicated movements correctly' do
    perform
    # All expectations in one test
    expect(unique_movement.status).to eq('confirmed')
    expect(possibly_duplicated_movement1.status).to eq('possibly_duplicated')
    expect(possibly_duplicated_movement2.status).to eq('possibly_duplicated')
  end
end
```

### Unit Tests vs Integration Tests

**Unit tests:**
- Test ONE component in isolation
- Mock/stub external dependencies
- Fast, many cases
- Use `build_stubbed`

```ruby
# Unit test - stub external commands
before do
  allow(GetBankAccountsToReconcile).to receive(:for).and_return(bank_accounts)
  allow(GetBankAccountsInProgress).to receive(:for).and_return([])
end

it 'enqueues reconciliation jobs' do
  expect { perform }.to have_enqueued_job(RunReconciliationJob)
end
```

**Integration tests:**
- Test components working together
- Use real database
- Fewer cases, main flows + edge cases
- Use `create` with `let_it_be`

```ruby
# Integration test - real database
let_it_be(:active_bank_account) do
  bank_account = create(:bank_account)
  bank_account.update!(last_time_refreshed: Time.current, reconciled_at: 1.day.ago)
  bank_account
end

it 'enqueues correctly for eligible accounts' do
  expect { perform }.to enqueue_job(RunReconciliationJob)
    .with(active_bank_account.id)
end
```

**Rule:** Integration tests should always be fewer than unit tests.

### Factory Best Practices for Unique Objects

For objects with unique constraints (Country, Bank):

```ruby
# BAD - Forces database even with build
initialize_with { Bank.find_or_create_by(public_id: public_id) }

# BAD - Creates associations even with build
recipient_bank { create(:bank) }

# GOOD - Use to_create callback
factory :bank do
  to_create do |instance|
    existing = Bank.find_by(public_id: instance.public_id)
    if existing.nil?
      Bank.create!(instance.attributes)
    else
      instance.attributes = existing.attributes
      instance.reload
    end
  end
end

# GOOD - Pass associations manually in tests
let(:bank) { create(:bank) }
let(:link) { create(:link, financial_entity: bank) }
let(:link_intent) { create(:link_intent, link: link, financial_entity: bank) }
```

### Test Organization Scoping

Always test that resources are scoped correctly:

```ruby
context 'when recipient belongs to different organization' do
  let_it_be(:other_org) { create(:organization) }
  let_it_be(:other_recipient) { create(:mx_recipient, entity: create(:entity, organization: other_org)) }

  it 'returns 404' do
    get "/recipients/#{other_recipient.hashid}", headers: auth_headers
    expect(response).to have_http_status(:not_found)
  end
end
```

### Test Serializer Output

```ruby
it 'returns expected attributes' do
  get "/recipients/#{recipient.hashid}", headers: auth_headers
  
  expect(json_response).to include(
    'id' => recipient.hashid,
    'holder_name' => recipient.holder_name,
    'account_number' => recipient.account_number
  )
end
```

### Test Contracts

Every contract should have tests:

```ruby
RSpec.describe Dashboard::Contracts::Internal::V2::Recipients::Mx::Create do
  subject(:contract) { described_class.new }

  describe 'validations' do
    it 'requires account_number' do
      result = contract.call({})
      expect(result.errors[:account_number]).to include('is missing')
    end

    it 'validates metadata format' do
      result = contract.call(metadata: 'invalid')
      expect(result.errors[:metadata]).to be_present
    end
  end
end
```

---

## Type Safety with Sorbet

### Unnecessary T.let

Don't use `T.let` when the type comes from params:

```ruby
# BAD - Redundant typing
sig { params(user: User).void }
def initialize(user:)
  @user = T.let(user, User)  # UNNECESSARY
end

# GOOD
sig { params(user: User).void }
def initialize(user:)
  @user = user
end
```

### Use Specific Types Over T.untyped

```ruby
# BAD
sig { params(params: T::Hash[Symbol, T.untyped]).void }

# GOOD - Use struct or specific types
sig { params(params: RecipientParams).void }
```

### Exhaustive Pattern Matching

```ruby
# GOOD - T.absurd ensures all cases handled
case env
when PacioliEnvironment::MX
  # ...
when PacioliEnvironment::CL, PacioliEnvironment::CPF
  # ...
when PacioliEnvironment::SANDBOX
  # ...
else
  T.absurd(env)  # Compile error if new env added
end
```

---

## API & Serialization

### Use Public Enums for API Responses

Never expose internal values directly:

```ruby
# BAD - Exposes internal values
def account_type
  object.account_type
end

# GOOD - Use public enum serializers
def account_type
  PublicApi::AccountType.deserialize(object.account_type).serialize
end

def country
  PublicApi::Country.deserialize(object.country).serialize
end
```

### Include Mode in Responses

```ruby
def mode
  PublicApi::Mode.deserialize(object.mode).serialize
end
```

### Model Methods Over Serializer Logic

```ruby
# BAD - Business logic in serializer
class RecipientSerializer
  def institution_name
    if object.is_a?(Mx::Recipient)
      Mx::Institution.find(object.institution_id)&.name
    else
      Security::Bank.find(object.bank_public_id)&.name
    end
  end
end

# GOOD - Delegate to model
class RecipientSerializer
  def institution_name
    object.institution_name  # Model handles lookup
  end
end
```

### Contract Validations

**Don't duplicate model validations in contracts** - contracts validate structure/type, models validate business rules.

```ruby
# Contract - Structure validation
class Create < Dry::Validation::Contract
  params do
    required(:account_number).value(:string, :filled?)
    required(:holder_name).value(:string, :filled?)
    optional(:email).maybe(:string)
    optional(:metadata).maybe(:hash)
  end

  rule(:email).validate(:email_format)
  rule(:metadata).validate(:metadata_format)
end
```

### Show Contract for URL Params

Don't create show contracts for ID parameters that come from the URL:

```ruby
# UNNECESSARY - ID comes from route
class Show < Dry::Validation::Contract
  params do
    required(:id).value(:string, :filled?)
  end
end

# The route already provides /recipients/:id
```

---

## Scopes & Query Patterns

### Scopes Must Return Relations

**Never return nil from scopes:**

```ruby
# BAD - Returns nil, breaks chaining
scope :for_entity, ->(hashid) { where(entity: Entity.find_by(hashid:)) if hashid.present? }

# GOOD - Always returns relation
scope :for_entity, ->(hashid) { hashid.present? ? where(entity: Entity.find_by(hashid:)) : all }
```

### Qualify Column Names in Joins

```ruby
# BAD - Ambiguous column with joins
scope :ordered, -> { order(holder_name: :asc) }

# GOOD - Qualified with table name
scope :ordered, -> { order(arel_table[:holder_name].asc) }
```

### Consistent Scope Interfaces

```ruby
# BAD - Inconsistent: one takes instance, other takes hashid
scope :for_organization, ->(org) { joins(:entity).where(entities: { organization_id: org.id }) }
scope :for_entity, ->(hashid) { where(entity: Entity.find_by(hashid:)) }

# GOOD - Consistent interface (both take IDs or both take instances)
scope :for_organization, ->(org_id) { joins(:entity).where(entities: { organization_id: org_id }) }
scope :for_entity, ->(entity_id) { where(entity_id:) }
```

### Keep Simple Scopes Simple

Complex filtering logic should go in service/filter classes, not scopes.

---

## Error Handling

### List Endpoints Return Empty, Not 404

```ruby
# BAD - 404 for empty filter results
def list(entity_id:)
  entity = find_entity!(entity_id)  # Raises 404 if not found
  # ...
end

# GOOD - Return empty array for filters
def list(entity_id:)
  return @model.none if entity_id.present? && !entity_exists?(entity_id)
  # ... apply filters
end
```

### Specific Error Types

```ruby
raise Errors::ApiError::MissingResource.new(
  model: PublicMissingErrorModel::Recipient,
  missing_value: recipient_id
)
```

### Simplify Duplicate Detection

```ruby
# BAD - Two methods
def duplicate_error?(error)
  case error
  when ActiveRecord::RecordNotUnique
    true
  when ActiveRecord::RecordInvalid
    error.record.errors.details.any? { |_, d| d.any? { |e| e[:error] == :taken } }
  end
end

# GOOD - DB constraint is sufficient
def duplicate_error?(error)
  error.is_a?(ActiveRecord::RecordNotUnique)
end
```

---

## File Organization

### Dashboard Services Location

```
engines/dashboard/app/services/dashboard/
├── mx/                    # Mexico implementations
│   ├── account_service.rb
│   ├── recipient_service.rb
│   └── transfer_intent_service.rb
├── security/              # Chile/CPF implementations
│   ├── account_service.rb
│   ├── recipient_service.rb
│   └── transfer_intent_service.rb
├── recipient_service.rb           # Abstract base
└── recipient_service_factory.rb   # Factory
```

### Contracts Location

```
engines/dashboard/app/controllers/dashboard/contracts/internal/v2/
├── recipients/
│   ├── index.rb
│   ├── mx/
│   │   ├── create.rb
│   │   └── update.rb
│   ├── cl/
│   │   ├── create.rb
│   │   └── update.rb
│   └── sandbox/
│       ├── create.rb
│       └── update.rb
```

---

## Quick Reference: Common Patterns

### Creating a New Country-Specific Service

1. Create abstract base in `engines/dashboard/app/services/dashboard/`
2. Create MX implementation in `engines/dashboard/app/services/dashboard/mx/`
3. Create Security implementation in `engines/dashboard/app/services/dashboard/security/`
4. Create factory in same directory as base
5. Add specs for each implementation

### Adding a New API Endpoint

1. Create contract(s) for validation
2. Add policy for authorization
3. Create/update serializer with public enums
4. Add controller action
5. Add route
6. Write request specs (including org scoping tests)

### Database Changes

1. Create table migration
2. Create index migration (with `disable_ddl_transaction!` + `add_index_safely`)
3. Create FK migration (with `validate: false`)
4. Create FK validation migration
5. Update model with associations
6. Add factory
7. Add model specs

### Migration Checklist

- [ ] No `safety_assured` unless table is very small
- [ ] Indexes use `add_index_safely` with `disable_ddl_transaction!`
- [ ] FKs split into create (validate: false) + validate migrations
- [ ] NOT NULL uses check constraint pattern
- [ ] Column type changes use new column + sync + swap
- [ ] Volatile defaults use column + default + BackfillJob
- [ ] No `add_reference` - do steps separately
- [ ] No manual lock_timeout increases (except for concurrent index ops)

---

## References

- [Fintoc Testing Guide](https://www.notion.so/fintoc/Testing-Guide-5f79cd8fbc894e72ab0344a117262b0b)
- [Fintoc Migraciones Rails](https://www.notion.so/fintoc/Migraciones-Rails-2840ff41a1e98081861ff97e152a6cf3)
- [Strong Migrations](https://github.com/ankane/strong_migrations)
- [PostgreSQL Lock Modes](https://www.postgresql.org/docs/current/explicit-locking.html)
- [test-prof let_it_be](https://test-prof.evilmartians.io/#/recipes/let_it_be)
- PR Reviews: #2368, #2369, #2374, #2375, #2376, #2377, #2378, #2379, #2380
