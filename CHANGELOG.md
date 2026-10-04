# Changelog

All notable changes to this project are documented here. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project follows [semantic versioning](https://semver.org/).

## [0.3.0] - 2026-10-04

### Added

- `shell_env` also sets the toolchain environment for apps opened from the Dock, Finder or Spotlight. They get launchd's environment rather than the login shell's, so Android Studio's Gradle sync couldn't find the keg-only Node (`A problem occurred starting process 'command 'node''`). A Launch Agent, `cloud.cosmonautical.macible.environment`, now runs `launchctl setenv` at every login for `PATH`, `JAVA_HOME`, `ANDROID_HOME`, `LANG=en_US.UTF-8` and any `shell_env_gui_extra_vars`. The role also applies it right away when it changes. Turn it off with `shell_env_gui: false`. See [`roles/shell_env/README.md`](roles/shell_env/README.md#apps-opened-outside-a-shell).

## [0.2.1] - 2026-10-04

### Fixed

- `xcode` no longer leaves a host where every Ansible run hangs. It used to select Xcode with `xcode-select` before accepting its license, and once an Xcode with an unaccepted license is selected, `/usr/bin/python3` (which Ansible runs every module with) stops at the license prompt. So the very next task hung, and so did every later run, at fact gathering. The license and first-launch setup now run first, against `xcode_app`'s own `xcodebuild`, and Xcode is selected after. Hosts already stuck this way need the license accepted by hand once; see [`roles/xcode/README.md`](roles/xcode/README.md#notes).

## [0.2.0] - 2026-10-04

Nomadintosh's general-purpose macOS roles now live here, so workstations and the Nomad cluster share one copy. Nomadintosh 6.0.0 uses them from this collection.

### Added

- Moved from Nomadintosh 5.0.1, unchanged apart from what's listed under Changed: `software_update`, `homebrew_packages`, `homebrew_trust`, `release_archives`, `android_sdk`, `docker_desktop`, `podman`, `container`, `nfs_mounts`, `clean` and `reboot`. Their variables keep the same names (`additional_homebrew_packages__*`, `release_archives__*`, `podman.enabled`, `nfs_mounts_shares`, `nas_host`, ...), so existing inventories keep working.
- New dependency on `cosmonautical.notify`, for `software_update`'s optional Discord notification.
- `playbooks/group_vars/all.yml` sets `log_dir`, `config_dir`, `launch_agents_dir` and `launch_daemons_dir`, which the LaunchAgent and LaunchDaemon roles expect.

### Changed

- `homebrew_packages_base_taps` now defaults to `[]`. In Nomadintosh it defaulted to `[hashicorp/tap]`, which only Consul and Nomad need, and Nomadintosh now sets that itself.
- `playbooks/main.yml` uses this collection's own roles, so `collections/requirements.yml` no longer pulls in `cosmonautical.nomadintosh`.
- Role READMEs point to Nomadintosh's `nomad` role by URL where they mention its Podman, Container and Docker driver wiring.
- Removed `importer_result.json`, a local `galaxy-importer` output that was committed by mistake and shipped in 0.1.0. It's now gitignored and in `build_ignore`.
- The NFS watchdog script's header comment now names `cosmonautical.macible`. Only the script changes; the LaunchDaemon isn't reloaded.

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
