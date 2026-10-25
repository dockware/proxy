# Changes in dockware/proxy

All notable changes of Dockware releases are documented in this file
using the [Keep a CHANGELOG](https://keepachangelog.com/) principles.

## [unreleased]

### Changed

  - Removed Orca, the image is now built from a plain `Dockerfile` (still NGINX 1.15.3)
  - APT sources now point to archive.debian.org, because Debian stretch is EOL

## [1.0] - 2020-12-14

### Added

  - Added initial version with NGINX 1.15.3
