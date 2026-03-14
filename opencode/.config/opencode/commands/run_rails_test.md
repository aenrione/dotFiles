---
description: Run Rails Test from agent
---

### Run Rails tests with absolute paths

```bash
# Absolute paths (adjust if different on your system)
DOPPLER="/opt/homebrew/bin/doppler"

# Ensure rbenv shims are available
export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"

# Run Rails tests
$DOPPLER run -- \
  rbenv exec bundle exec rails rspec
````

```

#### Notes
- `/opt/homebrew/bin/doppler` is the most common Doppler install path (Homebrew).
- `rbenv exec` ensures the correct Ruby version is used without relying on shell init.
- This works well in CI, agents, and cron where `.bashrc/.zshrc` are not loaded.

If you want, I can tailor this for **GitHub Actions**, **Buildkite**, or **a specific OS**.

- if migrations are required you may run the same exec but for `rails db:migrate` before the tests
- don't ever run rspec for all the repo but only the specs that are active for the current implementation


Note: some of the alias possible commands are
# fintoc
```
alias dr="doppler run -- "
alias drsx="doppler run --config dev_sandbox -- "
alias drmx="doppler run --config dev_mx -- "
alias drcl="doppler run --config dev_cl -- "
alias multi_migrate="drsx rails db:migrate && drmx rails db:migrate && drcl rails db:migrate"
```
