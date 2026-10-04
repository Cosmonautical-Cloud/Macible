# Macible

An Ansible playbook that sets up an Apple silicon Mac for local development: the toolchain [Jellify](https://github.com/Jellify-Music/App)'s [CONTRIBUTING.md](https://github.com/Jellify-Music/App/blob/main/CONTRIBUTING.md) asks for, installed the same way [Nomadable](https://github.com/Cosmonautical-Cloud/Nomadable) provisions the CI runners.

It reuses [Nomadintosh](https://github.com/Cosmonautical-Cloud/Nomadintosh)'s `software_update`, `homebrew_packages` and `android_sdk` roles, so this Mac and the Nomad runners get Homebrew packages, pinned Bun and the Android SDK from the same code.

## What it does

| Tag | Role | What it does |
|---|---|---|
| `software_update` | `cosmonautical.nomadintosh.software_update` | Downloads macOS updates (without installing them) and installs the Command Line Tools |
| `homebrew` | `cosmonautical.nomadintosh.homebrew_packages` | Installs Homebrew, the formulae in `additional_homebrew_packages__*` (git, gh, Node 24, Bun 1.4.2, Watchman, rbenv) and the casks in `homebrew_cask_apps` (Android Studio) |
| `xcode` | `xcode` | Installs Xcode from the App Store, selects it, accepts its license, runs its first-launch setup and downloads the iOS Simulator runtime |
| `ruby` | `ruby` | Builds Ruby 4.0.7 with rbenv and makes it the rbenv global |
| `android_sdk` | `cosmonautical.nomadintosh.android_sdk` | Installs JDK 17 and the Android SDK, accepts its licenses and installs the platform, build tools, NDK and emulator image Jellify builds with |
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

Add formulae as a new `additional_homebrew_packages__<name>` list (in `playbooks/group_vars/all.yml` or the inventory); Nomadintosh's `homebrew_packages` merges every list with that prefix. Casks go in `homebrew_cask_apps` and App Store apps in `mas_installed_apps`. Shell lines go in `shell_env_extra_lines`.
