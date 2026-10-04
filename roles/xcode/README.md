# xcode

Installs Xcode from the App Store and gets it ready for headless builds and simulators:

1. Installs [mas](https://github.com/mas-cli/mas) and, through [`geerlingguy.mac.mas`](https://github.com/geerlingguy/ansible-collection-mac), Xcode (`xcode_mas_id`) plus any apps in `mas_installed_apps`.
2. Fails if `xcode_app` still doesn't exist. mas can't sign in on current macOS, so this usually means nobody has signed in to the App Store on that Mac yet.
3. Accepts the Xcode license and runs Xcode's first-launch setup (`xcodebuild -runFirstLaunch`), both only if needed. These run against `xcode_app`'s own `xcodebuild`, before it's selected (see [Notes](#notes)).
4. Points `xcode-select` at `xcode_app`. The Command Line Tools select themselves when they're installed, and `xcodebuild` only works against a full Xcode.
5. Downloads a simulator runtime (`xcodebuild -downloadPlatform`) for each platform in `xcode_simulator_platforms` that has none installed yet.

Every step checks first, so reruns report no change.

## Before the first run

Sign in to the App Store on the Mac, in its GUI, as the user Ansible connects as.

## Variables

| Variable | Default | Description |
|---|---|---|
| `xcode_app` | `/Applications/Xcode.app` | Where Xcode is installed |
| `xcode_mas_id` | `497799835` | Xcode's App Store ID |
| `xcode_mas_path` | `{{ homebrew_dir }}/bin/mas` (`/opt/homebrew/bin/mas` if `homebrew_dir` isn't set) | Used to skip the App Store step in check mode before mas is installed |
| `xcode_simulator_platforms` | `[iOS]` | Platforms to download a simulator runtime for. A platform that already has any runtime is left alone; the role doesn't pin or upgrade runtime versions |
| `mas_installed_apps` | _(unset)_ | Extra App Store apps (`{id, name}`) to install alongside Xcode. Unset means just Xcode (not `geerlingguy.mac.mas`'s own demo list) |

## Notes

- mas installs whatever Xcode is current and doesn't upgrade it on later runs. Set `mas_upgrade_all_apps: true` if you want every run to upgrade App Store apps.
- Once `xcode-select` points at an Xcode whose license isn't accepted, the `/usr/bin` developer tool shims stop at the license prompt. That includes `/usr/bin/python3`, which Ansible runs every module with, so every Ansible run on the host hangs at fact gathering. That's why the license is accepted before Xcode is selected. To recover a host that's already stuck that way (from 0.2.0, which selected Xcode first), run `sudo xcodebuild -license accept && sudo xcodebuild -runFirstLaunch` on it and kill the stuck `xcodebuild -license check` processes.
- Requires `become` for `xcode-select --switch`, the license and first-launch setup, and App Store installs.
