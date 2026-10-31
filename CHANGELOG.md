# Changelog

All notable changes to the `ci-labs` library. Pipelines pin a tag: `@Library('ci-labs@vX.Y.Z')`.

## v1.0.0

First release.

- `labPreflight`, `labRelease`, `labDocsOnly`, `labImageRef`, `labSsh`, `labShellQuote`
- `resources/lab/docs_only.sh` and `resources/lab/image_ref.sh` with 20 tests
- `labSsh` script mode quotes arguments for both the local and the remote shell
