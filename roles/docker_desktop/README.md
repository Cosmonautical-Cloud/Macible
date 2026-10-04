# docker_desktop

Installs or removes [Docker Desktop](https://www.docker.com/products/docker-desktop/) on the host via Homebrew Cask, based on `docker.enabled`.

## What it does

- `docker.enabled: true` — installs the `docker-desktop` cask if not already present.
- `docker.enabled: false` — uninstalls it if present. On Nomadintosh hosts, the [`nomad`](https://github.com/Cosmonautical-Cloud/Nomadintosh/blob/main/roles/nomad/README.md) role's `docker` plugin config is also conditioned on `docker.enabled`, so disabling it drops that from `server.hcl` on the same run.
- `docker` absent entirely — include the role only when `docker` is defined (as Nomadintosh's `playbooks/deploy.yml` does), so a host that's never mentioned it is left alone either way.

## Host variables

| Variable | Values | Effect |
|---|---|---|
| `docker.enabled` | `true` / `false` / _(absent)_ | Install, uninstall, or don't manage Docker Desktop on this host |

## Manual setup required

Docker Desktop requires a user to **accept the licence agreement and complete the first-run setup** through the GUI before it can be used. This role does not automate that step.
