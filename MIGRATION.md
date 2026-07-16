# Migrating from `shc` / `she` to the unified `hoppscotch` chart

The `hoppscotch` chart supersedes the separate `shc` (Community) and `she` (Enterprise)
charts. This guide describes how to move an existing deployment across **without losing
data**.

> `shc` and `she` remain published and are maintained for backward compatibility. There is
> no forced end-of-life — migrate when it suits you.

## Why this is not an in-place `helm upgrade`

The chart name, resource names, labels, and values schema all differ between `shc`/`she`
and `hoppscotch`, so `helm upgrade` cannot transform one release into the other. The
migration is instead a **parallel install that reuses your existing database**, followed by
a traffic cutover. Your data lives in PostgreSQL, so preserving the database (and the
encryption/JWT secrets) is what preserves the data.

## The single most important rule

Carry these three values over **unchanged**:

- `dataEncryptionKey`
- `jwtSecret`
- `sessionSecret`

They are not row data, but the application uses them to encrypt sensitive fields in the
database and to sign sessions. If they change, previously encrypted values become
unreadable and every user session is invalidated. Copy them verbatim from the old release.

## Prerequisites

- A maintenance window (brief downtime at cutover).
- A backup of the database and, for Enterprise, the ClickHouse audit data if retained.
- The old release's values: `helm get values <old-release> -n <namespace> > old-values.yaml`.

Redis (Enterprise) holds only ephemeral session/scaling state and does not need migrating.

## Migration flow

1. **Back up and freeze.**

   ```bash
   pg_dump "<existing-connection-string>" > hoppscotch-backup.sql
   ```

2. **Extract the secrets to carry over** from `old-values.yaml`
   (`config.authjwt.dataEncryptionKey`, `config.authjwt.jwtSecret`,
   `config.authjwt.sessionSecret`).

3. **Point the new chart at the same database.** Reusing the existing database in place is
   the simplest and safest option:

   ```yaml
   postgresql:
     enabled: false
   externalDatabase:
     sqlConnection: "<existing-connection-string>"
   ```

   Alternatively, restore `hoppscotch-backup.sql` into a fresh or bundled PostgreSQL and
   point `externalDatabase` / `postgresql` at that.

4. **Translate the values** using the [mapping](#values-mapping) below. Pay attention to the
   [format changes](#format-changes-that-silently-break-things).

5. **Install `hoppscotch` as a new, parallel release with routing disabled** so the old
   release keeps serving traffic:

   ```bash
   helm upgrade --install hoppscotch hoppscotch/hoppscotch \
     -n <namespace> -f new-values.yaml \
     --set aio.ingress.enabled=false --set aio.route.enabled=false
   ```

   The migrations Job runs `prisma migrate deploy`, which is idempotent and upgrades the
   schema on top of your existing data.

6. **Validate against the same data** (via a temporary host or `kubectl port-forward`):
   - Logging in works → the secrets were carried over correctly.
   - Existing workspaces, collections and history are present → the database was reused
     correctly.

7. **Cut over.** Point your hostname / Ingress / Route at the new release
   (`aio.ingress.enabled=true` or `aio.route.enabled=true`) and verify end to end.

8. **Decommission** the old release once you are confident — but only after confirming its
   PVCs are not the database you are still using:

   ```bash
   helm uninstall <old-release> -n <namespace>
   ```

## Rollback

Because the old release stays running until cutover, rollback is simply re-pointing traffic
back to it. Keep the old release and its PVCs for a few days after cutover.

## Values mapping

| `shc` / `she` (old)                                   | `hoppscotch` (new)                                                       | Notes |
| ----------------------------------------------------- | ------------------------------------------------------------------------ | ----- |
| `global.namespace`                                    | `-n <ns>` / `namespaceOverride`                                          | |
| `community`/`enterprise.replicas`                     | `aio.replicaCount` (or per-component `replicaCount`)                     | |
| `community`/`enterprise.image.*`                      | `aio.image.*` (or `frontend`/`backend`/`admin.image.*`)                  | |
| `config.database.external` / `config.database.url`    | `externalDatabase.sqlConnection` (or `postgresql.enabled`)              | |
| `config.postgresql.*`                                 | `postgresql.auth.*` + `postgresql.primary.persistence.*`                | Bitnami subchart |
| `config.authjwt.dataEncryptionKey`                    | `hoppscotch.backend.dataEncryptionKey`                                   | **carry over** |
| `config.authjwt.jwtSecret`                            | `hoppscotch.backend.authToken.jwtSecret`                                 | **carry over** |
| `config.authjwt.sessionSecret`                        | `hoppscotch.backend.authToken.sessionSecret`                            | **carry over** |
| `config.authjwt.tokenSaltComplexity`                  | `hoppscotch.backend.authToken.tokenSaltComplexity`                      | |
| `config.authjwt.magicLinkTokenValidity`              | `hoppscotch.backend.authToken.magicLinkTokenValidity`                  | days |
| `config.authjwt.refreshTokenValidity`                 | `hoppscotch.backend.authToken.refreshTokenValidity`                    | convert to **ms** |
| `config.authjwt.accessTokenValidity`                  | `hoppscotch.backend.authToken.accessTokenValidity`                     | convert to **ms** |
| `config.urls.base`                                    | `hoppscotch.frontend.baseUrl`                                            | |
| `config.urls.shortcode`                               | `hoppscotch.frontend.shortcodeBaseUrl`                                   | |
| `config.urls.admin`                                   | `hoppscotch.frontend.adminUrl`                                           | |
| `config.urls.backend.gql` / `.ws` / `.api`            | `hoppscotch.frontend.backendGqlUrl` / `backendWsUrl` / `backendApiUrl`  | |
| `config.urls.redirect`                                | `hoppscotch.backend.redirectUrl`                                         | |
| `config.urls.whitelistedOrigins` (CSV)                | `hoppscotch.backend.whitelistedOrigins` (YAML list)                    | split CSV → list |
| `config.auth.allowedProviders` (e.g. `GOOGLE,EMAIL`)  | `hoppscotch.backend.auth.allowedProviders` (e.g. `[google, email]`)    | lowercase list |
| `config.auth.google.*`                                | `hoppscotch.backend.auth.google.*`                                      | `scope` CSV → list |
| `config.auth.github.*`                                | `hoppscotch.backend.auth.github.*` (+ `githubEnterprise.*`)            | |
| `config.auth.microsoft.*`                             | `hoppscotch.backend.auth.microsoft.*`                                   | |
| `config.auth.oidc.*` (Enterprise)                     | `hoppscotch.backend.auth.oidc.*`                                        | |
| `config.auth.saml.*` (Enterprise)                     | `hoppscotch.backend.auth.saml.*`                                        | |
| `config.mailer.enable`                                | `hoppscotch.backend.mailer.smtpEnabled`                                 | |
| `config.mailer.smtp.*`                                | `hoppscotch.backend.mailer.smtpUrl` / `smtpHost` / `smtpPort` / …       | |
| `config.rateLimit.*`                                  | `hoppscotch.backend.rateLimit.*`                                        | |
| `config.community/enterprise.enableSubpathBasedAccess`| `hoppscotch.frontend.enableSubpathBasedAccess`                         | |
| `config.enterprise.licenseKey` (Enterprise)           | `hoppscotch.backend.enterpriseLicenseKey`                              | |
| `config.horizontalScaling.enabled` (Enterprise)       | `hoppscotch.backend.horizontalScalingEnabled` (+ `autoscaling.*`)      | |
| `config.redis.*` (Enterprise)                         | `redis.*` (Bitnami) or `externalRedis.*`                               | |
| `config.clickhouse.*` (Enterprise)                    | `clickhouse.*` / `externalClickhouse.*`; `allowAuditLogs` → `hoppscotch.backend.allowAuditLogs` | |
| `config.links.tos` / `config.links.privacyPolicy`     | `hoppscotch.frontend.appTosLink` / `appPrivacyPolicyLink`              | |
| `service.ingress.{mainHost,adminHost,backendHost,className}` | `aio.ingress.*` (or per-component `ingress.*`)                  | |
| `service.tls.*`                                       | `aio.ingress.tls` / `extraTls`                                          | |
| `serviceAccount.*`                                    | `serviceAccount.*`                                                      | |

## Format changes that silently break things

These change shape between the charts and will not error — they just misbehave if missed:

- **Token validity** is now in **milliseconds**, not duration strings. `"1d"` → `"86400000"`,
  one week → `"604800000"`.
- **`allowedProviders`** is a **lowercase YAML list**, not an uppercase CSV string:
  `"GOOGLE,EMAIL"` → `[google, email]`.
- **`whitelistedOrigins`** is a **YAML list**, not a comma-separated string.
- OAuth **`scope`** fields are lists, not CSV strings.

## Deployment mode

`shc`/`she` run the all-in-one image, so the closest equivalent is `deploymentMode: aio`
with `hoppscotch.frontend.enableSubpathBasedAccess` matching your old
`enableSubpathBasedAccess`. Switching to `deploymentMode: distributed` (separate
frontend/backend/admin) is a good opportunity for higher availability, but is optional and
independent of the data migration.

## Validation checklist

- [ ] Database backed up before starting.
- [ ] `dataEncryptionKey`, `jwtSecret`, `sessionSecret` copied verbatim.
- [ ] New release points at the existing database (or a restored copy).
- [ ] Token validity converted to milliseconds; `allowedProviders` / `whitelistedOrigins` /
      `scope` converted to lists.
- [ ] Migrations Job `Completed`.
- [ ] Login works and existing collections/workspaces are visible.
- [ ] Traffic cut over; old release kept running until verified.
