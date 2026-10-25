# Changes in dockware/proxy

All notable changes of Dockware releases are documented in this file
using the [Keep a CHANGELOG](https://keepachangelog.com/) principles.

## [unreleased]

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

## [1.0] - 2020-12-14

### Added

  - Added initial version with NGINX 1.15.3
