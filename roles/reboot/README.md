# reboot

Reboots the host and waits for it to come back online.

## What it does

1. Issues a reboot via Ansible's `reboot` module with a 5-minute timeout for the host to return.

## Usage

Nomadintosh's `playbooks/reboot.yml` (`./reboot.zsh`) runs this role one host at a time (`serial: 1`), so a cluster never loses more than one node at once.

```bash
./reboot.zsh
```

## No manual setup required

No configuration is needed.
