# php_extensions

Builds version-pinned [pecl](https://pecl.php.net/) extensions for a Homebrew PHP (`php@8.4` by default) and enables them in the `php.ini` that PHP loads.

Homebrew's PHP formulae ship without extensions such as `redis`, `apcu` or `imagick`, and the only way to add them is `pecl install`, which builds from source. This role does that in a repeatable way, so a new host gets the same extensions at the same versions as the others.

## What it does

If the merged `php_extensions` list is empty, nothing. Otherwise:

1. Installs `php_extensions_php`, the build dependencies (`autoconf`, `pkgconf`, `pcre2`) and each extension's `brew_packages` with Homebrew.
2. For each extension, asks PHP which version is loaded. If it isn't `version`, builds it with `pecl install -f <name>-<version>`, answering every configure question with its default. `CPPFLAGS` points at Homebrew's `pcre2` headers, which PHP's own headers include but pecl doesn't find (`fatal error: 'pcre2.h' file not found`).
3. Makes sure `php.ini` has `extension="<name>.so"`, at the top where pecl puts it.
4. Fails unless PHP now reports `version` for the extension.

An extension that's already at its pinned version isn't rebuilt. Processes that are already running PHP (for example a `php-fpm` started by a Nomad job) only pick up a new extension when they restart.

## Variables

| Variable | Default | Description |
|---|---|---|
| `php_extensions` | `[]` | List of `{name, version, brew_packages?}` |
| `php_extensions__<suffix>` | | Any number of extra lists, merged in (sorted by variable name) — lets a group add extensions without repeating the base list |
| `php_extensions_php` | `php@8.4` | Homebrew formula to build for |
| `php_extensions_homebrew_prefix` | `/opt/homebrew` | Homebrew prefix |
| `php_extensions_build_packages` | `[autoconf, pkgconf, pcre2]` | Formulae every build needs |

```yaml
php_extensions__nextcloud:
  - name: imagick
    version: "3.8.1"
    brew_packages: [imagemagick]
  - name: apcu
    version: "5.1.28"
  - name: redis
    version: "6.3.0"
```
