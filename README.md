## Dockware Proxy

[![MIT licensed](https://img.shields.io/github/license/dockware/dockware.svg?style=flat-square)](https://github.com/dockware/dockware/blob/master/LICENSE)

Hi guys,
thanks for visiting the dockware project (www.dockware.io)

## What is dockware?

dockware is a managed Shopware 6 docker image.

Run and explore any Shopware 6 version within minutes locally in Docker.
No more hassle and blazing fast!
With dockware it's easy to explore Shopware and start developing in a smooth and seamless environment!

With the dockware/proxy image it's easy to add a reverse proxy or load balancer in your setups.

## Quick reference

Where to get help: https://www.dockware.io

Where to file issues: https://www.dockware.io

Documentation: https://dockware.io/docs

Maintained by: dasistweb GmbH (https://www.dasistweb.de)

## Security Updates

dockware/proxy 1.1.1 ships NGINX 1.30.7 with the fixes of the NGINX security advisories of 2026-11-18.
Older images (1.1.0 with NGINX 1.30.x, 1.0.0 with NGINX 1.15.3) are affected.

To apply an update you have to pull the new image **and recreate** the container.
A plain `docker restart` keeps running the old image.

```bash
docker compose pull proxy
docker compose up -d proxy
```

If you use a fixed tag (e.g. `dockware/proxy:1.1.0`), change it explicitly to the new tag.
`latest` only moves when a release is explicitly published with it.

You can check the NGINX version of a running container with:

```bash
docker exec <container> nginx -v
```

## How to use this image

### Quick Start

If you want to start the image and give it a try, simply create a custom config for your nginx and use the following command.

```ruby
$ docker run --rm -p 80:80 -v ./my-http.conf:/etc/nginx/conf.d/my-http.conf dockware/proxy:latest
```

### Environment Variables

This image comes with different features that can be set with the ENV variables.

| Feature    | Default | Description                                                                                                                                                 |
| ---------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ACCESS_LOG | 0       | Enable (1) or disable (0) access logs.                                                                                                                      |
| CF_COUNTRY | not-set | Simulate the country header with any (ISO2) value that Cloudflare will also add. This is perfect for testing Cloudflare compatibility when developing apps. |

### Project Configuration

Please add your custom configuration for NGINX in one of these folders:

- /etc/nginx/conf.d
- /etc/nginx/conf.stream.d

The default HTTP configurations should be inside "conf.d" while any additional TCP related configuration should be added to "conf.stream.d".

### Docker Compose Template

This is a full template with everything that can be done using dockware/proxy.
Please note that not all of these settings might be necessary.

```ruby
proxy:
    image: dockware/proxy:latest
    container_name: proxy
    ports:
        - "80:80"
        - "443:443"
    environment:
        - ACCESS_LOG=1
        - CF_COUNTRY=DE
```

## Configuration Options

### NGINX Projects Configuration

The best way to use the image is to create a bind mound for the folder `/etc/nginx/conf.d`.
All files inside that folder will be read from NGINX.

The proxy is already optimized for Shopware and web related projects.
If you need to adjust things like "max-post-size", feel free to do this in your custom configuration.

### Default-SSL Certificates

If you have a local or testing server, you can use the built in selfsigned certificates `selfsigned.crt` and `selfsigned.key`.
They come out of the box and are ready to be used.

Here is a configuration sample:

```ruby
ssl_certificate /etc/nginx/ssl/selfsigned.crt;
ssl_certificate_key /etc/nginx/ssl/selfsigned.key;
```

### Custom SSL Certificates

If you want to add your own certificates, just mount them to any directory and use them in your configuration.

```ruby
volumes:
    - ./my-certs/:/etc/nginx/my-certs
```

Don't forget to update your configuration files too:

```ruby
ssl_certificate /etc/nginx/my-certs/my-cert.crt;
ssl_certificate_key /etc/nginx/my-certs/my-cert.key;
```

### Basic Auth

If you want to use basic authentication, please create a `.htpasswd` file and mount it anywhere in the container.
Now simply use it in your configuration like this:

```ruby
server {
    ...
    # BASIC AUTHENTICATION
    satisfy any;
    deny all;
    auth_basic on;
    auth_basic_user_file /etc/nginx/.htpasswd;
    ...
}
```

### IP Allow Lists

In addition to basic authentication, its also possible to allow custom IPs in NGINX.
Just use the `allow` keyword before `deny all`.

```ruby
server {
    ...
    # allow IP address
    allow x.x.x.x;
    deny all;
    ...
}
```

You can also refer to additional files like this:

```ruby
server {
    ...
    # allow IP address
    include /xx/xx/my-ip-allow-list.conf
    ...
}
```

## Features

We enhanced our Docker image with a couple of additional features that make life easier for you.
Here is a list of these features including configuration examples.

### Streams (TCP, ...)

If you want to use a TCP related configuration, a new folder has been created and exposed such as the `conf.d` directory for your configuration files.
All files placed in `conf.stream.d` will be read from NGINX.
This is perfect if you want to route MySQL connections, or even restrict connections to your database, REDIS or other services.

```ruby
volumes:
    - "./proxy/my-tcp-endpoint.conf:/etc/nginx/conf.stream.d/tcp-endpoint.conf"
```

Here is a sample on how your configuration can look like:

```ruby
server {
    listen 3306;
    # pass on to container (no http:// prefix!)
    proxy_pass db:3306;
}
```

If you now start a TCP connection to your proxy using port 3306, it will be passed on to your database container on port 3306.

### Cloudflare Country Detection

Cloudflare adds a custom header with the country ISO2 code of the visitor to the request.

If you want to simulate this, just provide the ISO2 value in the environment variable `CF_COUNTRY`.
The dockware proxy will add that request header entry exactly like Cloudflare will do it.

Attention:
This feature does only work if no custom header modifications are done within your location block configuration (no inheritance possible).

```ruby
environment:
    - CF_COUNTRY=UK
```

Sample to access the country in PHP:

```ruby
$visitorCountry = $_SERVER["HTTP_CF_IPCOUNTRY"];
```

### Load Balancing

The reverse proxy can also be used as a load balancer.
For this, please use a so called `upstream` when routing to your container.
An upstream is a list of actual server instances or IP addresses.

Normally upstreams are done directly within the server configuration files.

dockware provides you with a custom directory `/etc/nginx/conf.upstream.d` that watches all `*.conf` files in there.

The following sample shows how to configure an upstream and use it in your configuration.

```ruby
# /etc/nginx/conf.upstream.d/myapp.conf
upstream myapp1 {
    least_conn;
    server srv1.example.com;
    server srv2.example.com;
    server srv3.example.com;
}

# /etc/nginx/conf.d/http.conf
server {
    listen 80;
    location / {
        proxy_pass http://myapp1;
    }
}
```

### Dynamic Upstreams / Discovery Services

If you want to use dynamic upstreams, for features like auto-scaling, then you have to update
your upstreams and their IP addresses and reload your NGINX service.

Because the upstreams can be configured in a separate file, you only have to update these files and reload NGINX.
This is a pretty easy and convenient way to integrate with discovery services.

Once updated, just reload NGINX with this command:

```ruby
service nginx reload
```

## Development

### Requirements

  - Docker (with a running daemon)
  - PHP 8.1+ with the `xml` and `mbstring` extensions on the host (runs SVRUnit)
  - make

SVRUnit only runs on the host.
Nothing of it is installed in the dockware/proxy image.

### Build

```bash
make build version=dev
```

The build always uses `--pull --no-cache`. The base image is pinned to a tag and a digest in `src/Dockerfile`.

### Tests

The image is tested with [SVRUnit](https://github.com/svrunit/svrunit).

```bash
make install                      # installs SVRUnit into ./vendor (Composer runs in Docker)
make svrunit version=dev          # runs all tests against dockware/proxy:dev
```

  - `tests/svrunit/suite.xml` defines the suites, the YAML tests live in `tests/svrunit/tests`.
  - Every suite starts a fresh container of the image (also per ENV variant) and runs its commands inside it.
  - The command exits non-zero if any test fails.

SVRUnit only compares the output of a command and ignores its exit code.
Every test with sub commands therefore prints a marker (e.g. `SVRUNIT_PASS`) only if all of them succeeded.

### Reports

  - `.reports/report.xml` JUnit report
  - `.reports/index.html` HTML report

## Release Checklist

Releases are published by CircleCI only. Nothing is published on a normal push.

1. Check the NGINX security advisories (https://nginx.org/en/security_advisories.html) and the latest `nginx:<version>-trixie` tag.
2. Update `FROM` in `src/Dockerfile` (tag **and** digest). Get the digest with:
   ```bash
   docker buildx imagetools inspect nginx:<version>-trixie
   ```
3. Update the expected and the old vulnerable versions in `tests/svrunit/tests/defaults/runtime.yml`.
4. Run `make build version=dev && make svrunit version=dev` locally.
5. Update `CHANGELOG.md` with the new version and date.
6. Merge, wait until the `test-image` workflow is green on amd64 **and** arm64.
7. Trigger the `release-image` pipeline in CircleCI on the release commit with a **new** `imageTag` (e.g. `1.1.1`).
   Existing tags are never overwritten, the pipeline refuses them.
8. Set `setLatest=true` only on purpose, once the new version should become `latest`.
9. Verify the published image for both architectures:
   ```bash
   docker buildx imagetools inspect dockware/proxy:<tag>
   docker run --rm --platform linux/amd64 --entrypoint nginx dockware/proxy:<tag> -v
   docker run --rm --platform linux/arm64 --entrypoint nginx dockware/proxy:<tag> -v
   ```
   The digests must match the ones in the CircleCI job output (`digest-amd64`, `digest-arm64`).
10. Tell users to pull and recreate their containers (see "Security Updates").

## License

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
