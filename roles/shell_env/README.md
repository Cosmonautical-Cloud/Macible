# shell_env

Manages a `# BEGIN/END MACIBLE MANAGED BLOCK` block in the login shell profile (`~/.zprofile` by default). The block:

- runs `brew shellenv`
- puts the keg-only Node formula (`macible_node_formula`) on `PATH`
- runs `rbenv init`
- exports `JAVA_HOME` and `ANDROID_HOME` and puts the Android emulator and platform tools on `PATH`
- appends any `shell_env_extra_lines`

The role creates the file if it's missing and leaves everything outside the block alone. Changes take effect in new login shells.

## Variables

| Variable | Default | Description |
|---|---|---|
| `shell_env_file` | `~/.zprofile` | File the block is managed in |
| `shell_env_extra_lines` | `[]` | Extra lines appended to the block |
| `homebrew_dir` | _(required)_ | Homebrew's prefix, e.g. `/opt/homebrew` |
| `macible_node_formula` | _(required)_ | Keg-only Node formula to put on `PATH`, e.g. `node@24` |
| `android_sdk_java_home` | _(required)_ | Exported as `JAVA_HOME` |
| `android_sdk_root` | _(required)_ | Exported as `ANDROID_HOME` |

Macible's playbook sets all the required variables in `playbooks/group_vars/all.yml`. Set them yourself when using the role on its own.
