## How to contribute?
The image is built from the plain `Dockerfile` in the `src` folder of this repository.

Please use the provided `makefile` to build, test and analyze the image, e.g.

```bash
make install
make build version=dev
make svrunit version=dev
```

Every pull request is built and tested on amd64 and arm64 in CircleCI.
See the README section "Tests" for details and "Release Checklist" for publishing a new version.
