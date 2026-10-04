# ruby

Builds Ruby versions with [rbenv](https://github.com/rbenv/rbenv) and makes the first one the rbenv global.

1. Runs `rbenv install --skip-existing` for each version in `ruby_versions` that isn't already in `~/.rbenv/versions`. It builds against Homebrew's `openssl@3` and `libyaml`.
2. Sets the rbenv global to the first entry in `ruby_versions`, only if it isn't already.

No gems are installed globally. Projects pick their own version from `.ruby-version`, and Bundler ships with Ruby.

## Requirements

`rbenv`, `ruby-build`, `openssl@3`, `libyaml` and `gmp` installed with Homebrew. Macible's playbook installs them in its `homebrew` step.

## Variables

| Variable | Default | Description |
|---|---|---|
| `ruby_versions` | `["{{ macible_ruby_version }}"]` | Versions to build. The first is the rbenv global. Set it yourself when using the role outside Macible's playbook, which is what defines `macible_ruby_version` |
| `homebrew_dir` | _(required)_ | Homebrew's prefix, e.g. `/opt/homebrew` |
