# Macible

Generic macOS roles for Apple silicon Macs, published on Ansible Galaxy as [`cosmonautical.macible`](https://galaxy.ansible.com/ui/repo/published/cosmonautical/macible/). They're meant for any Mac, whether it's a workstation or a server: [Nomadintosh](https://github.com/Cosmonautical-Cloud/Nomadintosh) uses them to provision the Nomad cluster's Macs, and this repository's playbook uses them to set up a Mac for local development.

The playbook installs the toolchain [Jellify](https://github.com/Jellify-Music/App)'s [CONTRIBUTING.md](https://github.com/Jellify-Music/App/blob/main/CONTRIBUTING.md) asks for, using the same roles [Nomadintosh](https://github.com/Cosmonautical-Cloud/Nomadintosh) uses to provision the CI runners. So this Mac and the runners get Homebrew packages, pinned Bun and the Android SDK from the same code.

## Roles

| Role | What it does |
|---|---|
| [`cosmonautical.macible.software_update`](roles/software_update/README.md) | Downloads macOS updates (without installing them), installs the newest Command Line Tools headlessly, and warns (optionally on Discord) when a restart is needed |
| [`cosmonautical.macible.homebrew_packages`](roles/homebrew_packages/README.md) | Installs Homebrew and the formulae and taps from every `additional_homebrew_packages__*` / `additional_homebrew_taps__*` list, trusting third-party taps and removing conflicting versions of `exclusive` formulae |
| [`cosmonautical.macible.homebrew_trust`](roles/homebrew_trust/README.md) | Marks third-party taps as trusted (`brew trust --tap`) so Homebrew 7+ loads them |
| [`cosmonautical.macible.release_archives`](roles/release_archives/README.md) | Installs version-pinned tools from release archives into `<dest>/<version>` with a `<dest>/current` symlink |
| [`cosmonautical.macible.android_sdk`](roles/android_sdk/README.md) | Installs a JDK and the Android SDK command-line tools, accepts SDK licenses and installs `android_sdk_packages` |
| [`cosmonautical.macible.xcode`](roles/xcode/README.md) | Installs Xcode from the App Store, selects it, accepts its license, runs its first-launch setup and downloads simulator runtimes |
| [`cosmonautical.macible.ruby`](roles/ruby/README.md) | Builds Ruby versions with rbenv and sets the rbenv global |
| [`cosmonautical.macible.shell_env`](roles/shell_env/README.md) | Manages a block in `~/.zprofile` that puts Homebrew, Node, rbenv, the JDK and the Android SDK on the shell |
| [`cosmonautical.macible.docker_desktop`](roles/docker_desktop/README.md) | Installs (`docker.enabled: true`) or removes (`false`) Docker Desktop |
| [`cosmonautical.macible.podman`](roles/podman/README.md) | Installs or removes Podman (`podman.enabled`), with a Podman machine and a LaunchAgent that keeps it running |
| [`cosmonautical.macible.container`](roles/container/README.md) | Installs or removes Apple's Container CLI (`container.enabled`), with a LaunchAgent that starts it at login |
| [`cosmonautical.macible.nfs_mounts`](roles/nfs_mounts/README.md) | Mounts `nfs_mounts_shares` from `nas_host` and keeps them mounted with a watchdog LaunchDaemon |
| [`cosmonautical.macible.clean`](roles/clean/README.md) | Runs `brew cleanup` |
| [`cosmonautical.macible.reboot`](roles/reboot/README.md) | Reboots the Mac and waits for it to come back |

Roles that write LaunchAgents, LaunchDaemons, scripts or logs expect `homebrew_dir`, `log_dir`, `config_dir`, `launch_agents_dir` and `launch_daemons_dir` to be set. [`playbooks/group_vars/all.yml`](playbooks/group_vars/all.yml) shows the usual values.

To use them in your own playbooks:

```sh
ansible-galaxy collection install cosmonautical.macible
```

```yaml
- name: Install Xcode
  ansible.builtin.include_role:
    name: cosmonautical.macible.xcode
```

## The development playbook

| Tag | Role | What it does |
|---|---|---|
| `software_update` | `software_update` | Downloads macOS updates (without installing them) and installs the Command Line Tools |
| `homebrew` | `homebrew_packages` | Installs Homebrew, the formulae in `additional_homebrew_packages__*` (git, gh, Node 24, Bun 1.4.2, Watchman, rbenv) and the casks in `homebrew_cask_apps` (Android Studio) |
| `xcode` | `xcode` | Installs Xcode from the App Store, selects it, accepts its license, runs its first-launch setup and downloads the iOS Simulator runtime |
| `ruby` | `ruby` | Builds Ruby 4.0.7 with rbenv and makes it the rbenv global |
| `android_sdk` | `android_sdk` | Installs JDK 17 and the Android SDK, accepts its licenses and installs the platform, build tools, NDK and emulator image Jellify builds with |
| `shell_env` | `shell_env` | Manages a block in `~/.zprofile` that puts Homebrew, Node 24, rbenv, `JAVA_HOME` and `ANDROID_HOME` on the shell |

Every step is idempotent, so rerun it whenever you like; `--tags` runs just part of it.

Versions live in [`playbooks/group_vars/all.yml`](playbooks/group_vars/all.yml). Renovate bumps the ones marked `# renovate:`; keep them in sync with Jellify's `package.json` (`packageManager`), `ios/.ruby-version` and `android/build.gradle`.

## Before the first run

On the Mac:

1. **Sign in to the App Store.** Xcode comes from the App Store via [mas](https://github.com/mas-cli/mas), which can't sign in on current macOS.
2. **For Semaphore runs, turn on Remote Login** (System Settings → General → Sharing → Remote Login) and add Semaphore's SSH public key to `~/.ssh/authorized_keys`.

## Running it

Install the collections first:

```sh
ansible-galaxy collection install -r collections/requirements.yml
```

### On the Mac itself

```sh
./deploy.zsh -i localhost, -c local -K
```

`-K` asks for your password, which is needed to install Homebrew and the Command Line Tools and to accept the Xcode license. `./check.zsh` takes the same arguments and does a dry run.

### From Semaphore

1. **Key Store**
   - An **SSH Key** that can log in to the Mac as your user.
   - A **Login with password** key holding your macOS user and password, for `become`.
2. **Repository**: this repository.
3. **Inventory**: a Static inventory using the SSH key, with the password key as its **Sudo Credentials**:

   ```yaml
   macbooks:
     hosts:
       macbook-pro.local:
         ansible_user: youruser
   ```

   Only the host goes here. Everything else is in `playbooks/group_vars/`, which Ansible loads whatever inventory the run uses.
4. **Task Template**: playbook `playbooks/main.yml` with that inventory. Semaphore installs `collections/requirements.yml` before each run.

If the Mac is asleep or off the network, the run fails to connect, so start it while the Mac is awake.

## Adding your own tools

Add formulae as a new `additional_homebrew_packages__<name>` list (in `playbooks/group_vars/all.yml` or the inventory); the `homebrew_packages` role merges every list with that prefix. Casks go in `homebrew_cask_apps` and App Store apps in `mas_installed_apps`. Shell lines go in `shell_env_extra_lines`.
