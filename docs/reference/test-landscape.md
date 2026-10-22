# Test landscape

| Kind | Location | Run | Covers |
|------|----------|-----|--------|
| Compile test | `t/00_compile.t` | `prove -l t` | `use_ok Mojo::Darkpan` |
| Route tests (Test::Mojo) | `t/01_routes.t` | `prove -l t` | Delivery of files and listings; traversal attempts return 404; `/list` on an empty repository; `/reindex` runs only when authorized (`createIndex` stubbed); `compress_index: false` in the config file |

- Test dependencies: `Test::More` 0.98 (`cpanfile`); `Test::Mojo` ships with Mojolicious.
- Not covered: `/publish` and `/authenquery`, index creation and update, successful basic-auth login, `/list` with packages.
- CI: `.travis.yml` lists Perl 5.12 to 5.30; no other CI config is in the repo.
- Run in the image (host Perl lacks deps on macOS): `podman run --rm -v <repo>:/src:ro -w /src --entrypoint prove mojo-darkpan:test -l t`.
- Last run (2026-10-22): both files pass.
