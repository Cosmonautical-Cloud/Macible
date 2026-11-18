# directories

Creates directories listed in the inventory, with the owner, group and mode given there. Runs with `become`, so it can create a directory owned by the deploy user inside a root-owned location such as `/opt`, which a service running as that user (Nomad, say) can't do for itself.

Existing directories are left in place; only their owner, group and mode are corrected. Nothing is ever deleted.

## Variables

| Variable | Description |
|---|---|
| `directories` | List of `{path, owner?, group?, mode?}`. `owner` defaults to `ansible_user`, `group` to `staff`, `mode` to `0755` |
| `directories__<suffix>` | Any number of extra lists, merged in (sorted by variable name) — lets a group add directories without repeating the base list |

```yaml
directories__github_runners:
  - path: /opt/github-actions
```
