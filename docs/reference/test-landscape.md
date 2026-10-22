# Test landscape

| Kind | Location | Run | Covers |
|------|----------|-----|--------|
| Compile test | `t/00_compile.t` | `prove -l t` | `use_ok Mojo::Darkpan` |
| Route tests (Test::Mojo) | `t/01_routes.t` | `prove -l t` | Delivery of files and listings; traversal attempts return 404; `/list` on an empty repository; `/reindex` runs only when authorized (`createIndex` stubbed); `compress_index: false` in the config file |
| Publish, list and auth tests | `t/02_publish.t` | `prove -l t` | Upload and `module=` publishing, index creation and update, 400 without a module, `/list` `other_versions`, basic auth 401 versus success (username/password mode) |
| Config tests | `t/03_config.t` | `prove -l t` | Defaults, config file values, env-over-file precedence, empty `DARKPAN_COMPRESS_INDEX`, env basic auth, missing and invalid config files |

- Test dependencies: `Test::More` 0.98 (`cpanfile`); `Test::Mojo` ships with Mojolicious; `Archive::Tar` is core.
- Not covered: LDAP auth, `git+ssh` and HTTP `module` sources, `script/darkpan`.
- Coverage (Devel::Cover, `^lib`, 2026-10-22, before `t/03_config.t`): total 70.7%; `Util.pm` 90%, `Controller/Index.pm` 100%, `DirectoryHandler.pm` 83%, `Config.pm` 76%, `Controller/Publish.pm` 41% (Nice::Try source filtering may understate it). Coverage is not wired into any CI.
- CI: `.travis.yml` lists Perl 5.12 to 5.30; no other CI config is in the repo.
- Run in the image (host Perl lacks deps on macOS): `podman run --rm -v <repo>:/src:ro -w /src --entrypoint prove mojo-darkpan:test -l t`.
- Last run (2026-10-22): all 4 files, 17 tests pass.
