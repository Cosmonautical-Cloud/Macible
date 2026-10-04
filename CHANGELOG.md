# Changelog

All notable changes to this project are documented here. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project follows [semantic versioning](https://semver.org/).

## [0.1.0] - 2026-10-04

First release on Ansible Galaxy, as the `cosmonautical.macible` collection. Macible is the generic macOS layer: roles that apply to any Apple silicon Mac, whether it's a workstation or a Nomad client. [Nomadintosh](https://github.com/Cosmonautical-Cloud/Nomadintosh) builds on it to provision its cluster.

### Added

- `xcode` role: installs Xcode from the App Store (via mas and `geerlingguy.mac.mas`), selects it with `xcode-select`, accepts its license, runs its first-launch setup, and downloads a simulator runtime for each platform in `xcode_simulator_platforms` (default `iOS`) that has none yet. Always installs Xcode itself (`xcode_mas_id`) plus any `mas_installed_apps`, so including the role on its own never falls back to `geerlingguy.mac.mas`'s demo app list. Fails with a clear message if Xcode is still missing, which means nobody has signed in to the App Store on that Mac. See [`roles/xcode/README.md`](roles/xcode/README.md).
- `ruby` role: builds each version in `ruby_versions` with rbenv and makes the first one the rbenv global.
- `shell_env` role: manages a block in `~/.zprofile` that puts Homebrew, Node, rbenv, `JAVA_HOME` and `ANDROID_HOME` on the shell, plus any `shell_env_extra_lines`.
- `playbooks/main.yml` (`cosmonautical.macible.main`): sets up a Mac for local development. It runs Software Update, Homebrew packages, Xcode, Ruby, the JDK and Android SDK, and the shell environment, with the toolchain versions Jellify's CI runners use. Each step has its own tag.
- Galaxy metadata (`galaxy.yml`, `meta/runtime.yml`), plus GitHub Actions that lint every push and pull request and publish to Galaxy on every push to `main`.

### Notes

- The collection's own dependencies are only `geerlingguy.mac` and `community.general`. `playbooks/main.yml` still uses `cosmonautical.nomadintosh`'s `software_update`, `homebrew_packages` and `android_sdk` roles until they move here. Install them with `collections/requirements.yml` rather than relying on Galaxy dependency resolution: Nomadintosh depends on Macible, so declaring the reverse would create a cycle.
