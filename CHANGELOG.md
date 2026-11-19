# Changes in dockware/proxy

All notable changes of Dockware releases are documented in this file
using the [Keep a CHANGELOG](https://keepachangelog.com/) principles.

## [1.1.1] - Unreleased

### Security

  - Updated NGINX to **1.30.7**, the patched stable release for the NGINX security advisories of 2026-11-18
    (among others CVE-2026-123007 HTTP/2 flow control, CVE-2026-118899 TLS 1.3 request body,
    CVE-2026-123633 HTTP/2 use-after-free, CVE-2026-125283 alias with try_files).
    All versions before 1.30.7 (stable) and 1.31.9 (mainline) are affected, including dockware/proxy 1.1.0 (NGINX 1.30.x) and 1.0.0 (NGINX 1.15.3).
  - The base image is now pinned to `nginx:1.30.7-trixie` including its multi-arch digest, so a build can no longer use an outdated cached base image.

### Added

  - SVRUnit test suite (`tests/svrunit`) for the image, with `make svrunit version=<tag>`
  - CircleCI tests every change on amd64 and arm64 without registry credentials.
    A release only publishes the tested images of both architectures.

### Removed

  - `make multi-push` was removed, because it built the image again after the tests. Releases are published by CircleCI only.

## [1.1.0] - 2026-10-25

### Breaking Changes

The NGINX update from 1.15.3 to 1.30 affects your custom configurations in `conf.d`, `conf.stream.d` and `conf.upstream.d`.

  - **`ssl on;` has been removed** (since NGINX 1.25.1). NGINX does not start if it is still used.
    Use the `ssl` parameter of the `listen` directive instead.
    - Example:
      ```nginx
      # before
      listen 443;
      ssl on;

      # after
      listen 443 ssl;
      ```
  - **`listen ... http2` is deprecated** (since NGINX 1.25.1). It still works, but logs a warning on every start.
    Use the separate `http2` directive instead.
    - Example:
      ```nginx
      # before
      listen 443 ssl http2;

      # after
      listen 443 ssl;
      http2 on;
      ```
  - **`libgd-dev` is no longer installed.** If your own image builds on top of `dockware/proxy` and needs it, install it yourself.

### Changed

  - Updated base image from NGINX 1.15.3 (Debian stretch, EOL) to nginx:1.30-trixie
  - Removed Orca, the image is now built from a plain `Dockerfile`

## [1.0.0] - 2020-12-14

### Added

  - Added initial version with NGINX 1.15.3
