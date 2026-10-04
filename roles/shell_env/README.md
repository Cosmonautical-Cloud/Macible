# shell_env

Manages a `# BEGIN/END MACIBLE MANAGED BLOCK` block in the login shell profile (`~/.zprofile` by default). The block:

- runs `brew shellenv`
- puts the keg-only Node formula (`macible_node_formula`) on `PATH`
- runs `rbenv init`
- exports `JAVA_HOME` and `ANDROID_HOME` and puts the Android emulator and platform tools on `PATH`
- appends any `shell_env_extra_lines`

The role creates the file if it's missing and leaves everything outside the block alone. Changes take effect in new login shells.

## Apps opened outside a shell

Apps opened from the Dock, Finder or Spotlight don't read `~/.zprofile`; they get launchd's environment. Without help, Android Studio's Gradle sync can't find the keg-only Node and fails with `A problem occurred starting process 'command 'node''`. So, unless `shell_env_gui` is `false`, the role also installs a Launch Agent (`~/Library/LaunchAgents/cloud.cosmonautical.macible.environment.plist`) that runs `launchctl setenv` at every login, with:

- `PATH`: the Node formula, rbenv shims, Homebrew, the system directories and the Android emulator and platform tools
- `JAVA_HOME` and `ANDROID_HOME`, as in the shell block
- `LANG=en_US.UTF-8`, which CocoaPods needs
- anything in `shell_env_gui_extra_vars`

When the Launch Agent changes, the role also runs it right away, so you don't need to log out. Apps that are already open, and Gradle daemons they started (`./gradlew --stop`), need restarting to pick it up.

## Variables

| Variable | Default | Description |
|---|---|---|
| `shell_env_file` | `~/.zprofile` | File the block is managed in |
| `shell_env_extra_lines` | `[]` | Extra lines appended to the block |
| `shell_env_gui` | `true` | Also set the environment for apps opened outside a shell (see above) |
| `shell_env_gui_extra_vars` | `{}` | Extra variables for those apps, as `{NAME: value}`. Setting `PATH`, `JAVA_HOME`, `ANDROID_HOME` or `LANG` overrides the default |
| `homebrew_dir` | _(required)_ | Homebrew's prefix, e.g. `/opt/homebrew` |
| `macible_node_formula` | _(required)_ | Keg-only Node formula to put on `PATH`, e.g. `node@24` |
| `android_sdk_java_home` | _(required)_ | Exported as `JAVA_HOME` |
| `android_sdk_root` | _(required)_ | Exported as `ANDROID_HOME` |

Macible's playbook sets all the required variables in `playbooks/group_vars/all.yml`. Set them yourself when using the role on its own.
