# FileShare

FileShare is a Rails application for uploading files and sharing them with private, internal, or public visibility. Users sign in with Microsoft Entra ID, uploads are stored with Active Storage, and expired uploads are removed by a scheduled Solid Queue job.

## Requirements

- Ruby 4.0.5, as configured in `mise.toml`
- Bundler
- Yarn
- SQLite 3
- libvips, for Active Storage image processing

## Setup

Install dependencies and prepare the database:

```sh
bin/setup --skip-server
```

Create a local `.env` file for development secrets. At minimum, Entra authentication needs:

```sh
ENTRA_CLIENT_ID=your-client-id
ENTRA_CLIENT_SECRET=your-client-secret
ENTRA_TENANT_ID=your-tenant-id
```

`ENTRA_TENANT_ID` can be omitted to use `common`, but a tenant-specific value is usually preferred for an organization-owned app.

## Running Locally

Start the Rails server, CSS watcher, and Solid Queue worker:

```sh
bin/dev
```

The app runs at `http://localhost:3000` by default. Override the port with:

```sh
PORT=3001 bin/dev
```

## Tests

Run the test suite:

```sh
bin/rails test
```

Run CI checks:

```sh
bin/ci
```

## Background Jobs

The project uses Solid Queue. In development, `Procfile.dev` starts the worker with:

```sh
bin/jobs
```

`config/recurring.yml` schedules `FileCleanupJob` in development to delete uploads with `expires_at` before the current date.

## Storage

Development and test use local disk storage.

Production defaults to Azure Blob Storage through:

```sh
ACTIVE_STORAGE_SERVICE=azure
```

The Azure container name is configured as `fileshare` in `config/storage.yml`.

## Environment Variables

### Required

| Name | Required when | Description |
| --- | --- | --- |
| `ENTRA_CLIENT_ID` | Development and production authentication | Microsoft Entra application client ID used by OmniAuth. |
| `ENTRA_CLIENT_SECRET` | Development and production authentication | Microsoft Entra application client secret used by OmniAuth. |
| `RAILS_MASTER_KEY` | Production | Decrypts Rails credentials. Required by the production Docker image and Rails encrypted credentials. |
| `AZ_STORAGE_ACCOUNT` | Production when `ACTIVE_STORAGE_SERVICE=azure` | Azure Storage account name for Active Storage. |
| `AZ_STORAGE_ACCESS_KEY` | Production when `ACTIVE_STORAGE_SERVICE=azure` | Azure Storage account access key for Active Storage. |

### Optional

| Name | Default | Description |
| --- | --- | --- |
| `ENTRA_TENANT_ID` | `common` | Microsoft Entra tenant ID. Use a tenant-specific value to restrict sign-in to one tenant. |
| `ACTIVE_STORAGE_SERVICE` | `azure` in production | Active Storage service name. Set to `local` for disk-backed production storage if needed. |
| `RAILS_MAX_THREADS` | `5` | Database connection pool size and Rails thread count input. |
| `PORT` | `3000` in development | Local server port used by `bin/dev`. |
| `WEB_CONCURRENCY` | unset | Puma worker count. |
| `SOLID_QUEUE_IN_PUMA` | unset | Enables the Solid Queue Puma plugin when present. |
| `PIDFILE` | unset | Puma PID file path. |
| `CI` | unset | Enables eager loading in the test environment when present. |

## Useful Commands

Check Entra environment configuration:

```sh
ruby script/check_entra_config.rb
```

Build CSS once:

```sh
yarn build:css
```

Run only the file cleanup job test:

```sh
bin/rails test test/jobs/file_cleanup_job_test.rb
```
