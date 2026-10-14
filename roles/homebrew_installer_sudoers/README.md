# homebrew_installer_sudoers

Grants the connecting user passwordless `sudo` for `/usr/sbin/installer` only.

## Why

Homebrew refuses to run itself as root. For casks that ship a signed `.pkg`
installer (e.g. `temurin`), Homebrew's own code shells out to a bare
`sudo -u root -- /usr/sbin/installer -pkg ... -target /` from inside the
`brew install` process. That call is invoked directly by Homebrew, not by
Ansible, so it bypasses `become`/`--ask-become-pass` entirely - nothing
supplies the password it asks for, and the task hangs indefinitely.

This role writes a narrowly-scoped `/etc/sudoers.d/` drop-in so that one
binary, and only that binary, can run as root without a password. It does not
grant any broader sudo access.

## What it does

Deploys `/etc/sudoers.d/homebrew-installer-nopasswd` (mode `0440`,
`root:wheel`) via `ansible.builtin.template`, validated with `visudo -cf %s`
before it's installed so a syntax error can never break `sudo` on the host.

## Variables

| Variable | Default | Description |
|---|---|---|
| `homebrew_installer_sudoers_user` | `{{ ansible_user_id }}` | User granted NOPASSWD access to `/usr/sbin/installer` |
